//
//  HETSkinAnalysisDataEngine.m
//  HETSkinAnalysis
//
//  Created by 远征 马 on 2019/7/4.
//  Copyright © 2019 马远征. All rights reserved.
//

#import "HETSkinAnalysisDataEngine.h"
#import "QCloudCore.h"
#import "QCloudCOSXML.h"
#import "HETSkinAnalysisAPI.h"
#import "NSString+HETSkinAnalysis.h"
#import "NSDictionary+HETSkinAnalysis.h"
#import "HETSkinAnalysisConfiguration+HETPrivate.h"
#import "UIImage+HETSkinAnalysis.h"
#import "HETSkinAnalysisDefinePrivate.h"
#import "HETSkinAnalysisResult.h"

static NSString *KQCloudAppId = @"1251053011";
static NSString *KQCloudRegionName = @"ap-guangzhou";
static NSString *KQCloudBucket = @"clife-cos";
static NSString *KBucketURL = @"http://cos.clife.net";

@interface HETSkinAnalysisDataEngine () <QCloudSignatureProvider,QCloudCredentailFenceQueueDelegate>
@property (nonatomic, strong) QCloudCredentailFenceQueue *credentialFenceQueue;
@end

@implementation HETSkinAnalysisDataEngine

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        // 初始化云服务
        QCloudServiceConfiguration* configuration = [QCloudServiceConfiguration new];
        configuration.appID = KQCloudAppId;
        configuration.signatureProvider = self;
        QCloudCOSXMLEndPoint* endpoint = [[QCloudCOSXMLEndPoint alloc] init];
        endpoint.regionName = KQCloudRegionName;
        configuration.endpoint = endpoint;
        [QCloudCOSXMLService registerDefaultCOSXMLWithConfiguration:configuration];
        [QCloudCOSTransferMangerService registerDefaultCOSTransferMangerWithConfiguration:configuration];
        
        _credentialFenceQueue = [QCloudCredentailFenceQueue new];
        _credentialFenceQueue.delegate = self;
    }
    return self;
}

- (void)dealloc
{
    [[QCloudCOSTransferMangerService defaultCOSTransferManager].sessionManager cancelAllRequest];
    
}

#pragma mark - 照片分析

- (void)analysisImage:(UIImage*)image
             progress:(void(^)(HETImageAnalysisStep step, CGFloat progress))progress
               result:(void(^)( HETSkinAnalysisResult *skinAnalysisResult,id responseJSON, NSError *error))retHandler
{
    @hetWeakify(self);
    dispatch_queue_t queue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    het_dispatch_async(queue, ^{
        // 压缩图像
        NSData *imageData = HETCompressImage(image, 1.0);
        @hetStrongify(self);
        het_dispatch_async_main(^{
            // 上传到腾讯云
            [self uploadImageToQCloud:imageData progress:progress result:^(QCloudUploadObjectResult *result, NSError *error) {
                if (result) {
                    // het大数据分析
                    [self analysisSkin:result progress:progress result:^(id responseJSON, NSError *error) {
                        
                        HETSkinAnalysisConfiguration *config = [HETSkinAnalysisConfiguration rawDefaultConfiguration];
                        HETSkinAnalysisResult *analysisResult = nil;
                        if (config && config.jsonToModelBlock) {
                            analysisResult = config.jsonToModelBlock(HETSkinAnalysisResult.class, responseJSON);
                        }
                        else
                        {
                            analysisResult = [HETSkinAnalysisResult modelWithJSON:responseJSON];
                        }
                        if (retHandler)
                        {
                            retHandler(analysisResult, responseJSON, error);
                        }
                    }];
                }
                else
                {
                    het_dispatch_async_main(^{
                        if (retHandler) {
                            retHandler( nil, nil, error);
                        }
                    });
                }
            }];
        });
    });
}

#pragma mark - private

- (void)analysisSkin:(QCloudUploadObjectResult *)result progress:(void (^)(HETImageAnalysisStep, CGFloat))progress result:(void (^)(id responseJSON, NSError *))retHandler
{
    [self getAccessToken:^(NSString *accessToken, NSError *error) {
        if (accessToken) {
            NSString *urlString = [KBucketURL stringByAppendingFormat:@"/%@",result.key];
            het_dispatch_async_main(^{
                if (progress) {
                    progress(HETImageAnalysisStepCloudAnalysis, 0.0);
                }
            });
            
            [HETSkinAnalysisAPI getSkinAnalysisData:accessToken imageUrl:urlString result:^(id responseObject, NSError *error) {
                het_dispatch_async_main(^{
                    if (error) {
                        if (retHandler) {
                            retHandler(nil, error);
                        }
                    }
                    else
                    {
                        if (retHandler) {
                            retHandler(responseObject, nil);
                        }
                    }
                });
            }];
        }
        else
        {
            het_dispatch_async_main(^{
                if (retHandler) {
                    retHandler(nil, error);
                }
            });
        }
    }];
}

#pragma mark - QCloudCredentailFenceQueueDelegate

- (void)uploadImageToQCloud:(NSData*)imageData progress:(void(^)(HETImageAnalysisStep step, CGFloat progress))progress result:(void(^)(QCloudUploadObjectResult *result, NSError *error))retHandler
{
    QCloudCOSXMLUploadObjectRequest *put = [QCloudCOSXMLUploadObjectRequest new];
    NSString *fileName = [NSString getUUIDString];
    put.object = [NSString stringWithFormat:@"%@.jpeg",fileName];
    put.bucket = KQCloudBucket;
    put.body =  imageData;
    [put setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        // 回调上传进度
        CGFloat progressValue = (CGFloat)totalBytesSent/totalBytesExpectedToSend;
        if (progress) {
            progress(HETImageAnalysisStepUpload, progressValue);
        }
    }];
    [put setFinishBlock:^(id outputObject, NSError* error) {
        if (error) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"图片上传失败"};
            error = [NSError errorWithDomain:HETNetworkErrorDomain code:HETSkinAnalysisErrorCodeUploadImageFailed userInfo:userInfo];
            if (retHandler) {
                retHandler(nil, error);
            }
        }
        else
        {
            QCloudUploadObjectResult *uploadResult = (QCloudUploadObjectResult*)outputObject;
            if (retHandler) {
                retHandler(uploadResult, nil);
            }
        }
    }];
    [[QCloudCOSTransferMangerService defaultCOSTransferManager]UploadObject:put];
}

- (void)getAccessToken:(void(^)(NSString *accessToken, NSError *error))retHandler
{
    NSString *token = HETGETValidAccessToken();
    if (token) {
//        NSLog(@"---token---%@",token);
        if (retHandler) {
            retHandler(token,nil);
        }
        return;
    }
    [HETSkinAnalysisAPI getAccessToken:^(NSString *accessToken, NSError *error) {
        if (retHandler) {
            retHandler(accessToken,error);
        }
    }];
}

- (void)fenceQueue:(QCloudCredentailFenceQueue *)queue requestCreatorWithContinue:(QCloudCredentailFenceQueueContinue)continueBlock
{
    
    [self getAccessToken:^(NSString *accessToken, NSError *error) {
        if (accessToken) {
            [HETSkinAnalysisAPI getQCloudCredential:accessToken result:^(id responseObject, NSError *error) {
                if (responseObject && [responseObject isKindOfClass:[NSDictionary class]])
                {
                    NSDictionary *credentialDict = HETSafeDictionaryForKeyInDict(responseObject, @"credentials");
                    QCloudCredential* credential = [QCloudCredential new];
                    credential.secretID = HETSafeStringForKeyInDict(credentialDict, @"tmpSecretId");
                    credential.secretKey = HETSafeStringForKeyInDict(credentialDict, @"tmpSecretKey");
                    NSTimeInterval expiredTime = [HETSafeNumberForKeyInDict(responseObject, @"expiredTime") doubleValue];
                    credential.experationDate = [NSDate dateWithTimeIntervalSince1970:expiredTime];
                    credential.token = HETSafeStringForKeyInDict(credentialDict, @"sessionToken");
                    QCloudAuthentationV5Creator* creator = [[QCloudAuthentationV5Creator alloc] initWithCredential:credential];
                    continueBlock(creator, nil);
                }
                else
                {
                    if (continueBlock) {
                        continueBlock(nil,error);
                    }
                }
            }];
        }
        else
        {
            if (continueBlock) {
                continueBlock(nil,error);
            }
        }
    }];
}


#pragma mark - QCloudSignatureProvider

- (void) signatureWithFields:(QCloudSignatureFields*)fileds
                     request:(QCloudBizHTTPRequest*)request
                  urlRequest:(NSURLRequest*)urlRequst
                   compelete:(QCloudHTTPAuthentationContinueBlock)continueBlock
{
    [self.credentialFenceQueue performAction:^(QCloudAuthentationCreator *creator, NSError *error) {
        if (error)
        {
            continueBlock(nil, error);
        }
        else
        {
            QCloudSignature* signature =  [creator signatureForData:urlRequst];
            continueBlock(signature, nil);
        }
    }];
}
@end
