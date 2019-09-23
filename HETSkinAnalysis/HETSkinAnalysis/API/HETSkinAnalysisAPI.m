//
//  HETSkinAnalysisAPI.m
//  HETSkinAnalysis
//
//  Created by 远征 马 on 2019/7/17.
//  Copyright © 2019 马远征. All rights reserved.
//

#import "HETSkinAnalysisAPI.h"
#import "HETSkinAnalysisConfiguration+HETPrivate.h"
#import "NSDictionary+HETSkinAnalysis.h"
#import <AdSupport/AdSupport.h>
#import "NSString+HETSkinAnalysis.h"
#import "HETSkinAnalysisDefinePrivate.h"
#import "HETSkinAnalysisURL.h"
#import "HETSkinAnalysisDefine.h"

static NSString *KAccessTokenStoreKey = @"com.skinAnalysis.store.accesstoken";


FOUNDATION_EXTERN_INLINE NSString *HETGETValidAccessToken(void)
{
    return nil;
//    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
//    NSDictionary *param = [standardUserDefaults objectForKey:KAccessTokenStoreKey];
//    if (param) {
//        NSNumber *expiresIn = HETSafeNumberForKeyInDict(param, @"expiresIn");
//        if (expiresIn.doubleValue > [NSDate.date timeIntervalSince1970]) {
//            return  HETSafeStringForKeyInDict(param, @"accessToken");
//        }
//    }
//    return nil;
}

FOUNDATION_EXTERN_INLINE BOOL HETSaveAuthData(id object, NSString *key)
{
    if (key && object) {
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        [standardUserDefaults setObject:object forKey:key];
        return [standardUserDefaults synchronize];
    }
    return NO;
}

FOUNDATION_EXTERN_INLINE NSString *HETGETValidURLSignature(NSString *key)
{
    return nil;
//    if (!key) {
//        return nil;
//    }
//    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
//    NSDictionary *param = [standardUserDefaults objectForKey:key];
//    if (param) {
//        NSNumber *expiredTime = HETSafeNumberForKeyInDict(param, @"expiredTime");
//        if (expiredTime.doubleValue > [NSDate.date timeIntervalSince1970]) {
//            return HETSafeStringForKeyInDict(param, @"sign");
//        }
//    }
//    return nil;
}

FOUNDATION_EXTERN_INLINE BOOL HETSaveURLSignatureData(id object,NSString *key)
{
    if (object && key) {
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        [standardUserDefaults setObject:object forKey:key];
        return [standardUserDefaults synchronize];
    }
    return NO;
}

@implementation HETSkinAnalysisAPI

#pragma mark - 获取HET授权凭证

+ (NSURLSessionDataTask*)getAccessToken:(void(^)(NSString *accessToken, NSError *error))retHandler
{
    HETSkinAnalysisConfiguration *config = [HETSkinAnalysisConfiguration rawDefaultConfiguration];
    NSAssert(config.appId != nil && config.appSecret != nil, @"大数据肤质分析需要设置一个可用的AppId和秘钥，请前往clife平台申请！");
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSString *urlString = [HETGetURLDomain() stringByAppendingString:HETAccessTokenURLPath()];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:30.0];
    [request setHTTPMethod:@"POST"];
    
    NSMutableArray *tmpArray = [NSMutableArray array];
    [tmpArray addObject:[NSString stringWithFormat:@"appId=%@",config.appId]];
    [tmpArray addObject:[NSString stringWithFormat:@"appSecret=%@",config.appSecret]];
    NSTimeInterval timeStamp = [NSDate.date timeIntervalSince1970];
    [tmpArray addObject:[NSString stringWithFormat:@"timestamp=%@",@((long long)(timeStamp*1000))]];
    NSString *parameterString = [tmpArray componentsJoinedByString:@"&"];
    NSData *parametersData = [parameterString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:parametersData];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if (retHandler) {
                retHandler(nil, error);
            }
            return ;
        }
        
        NSError *aError;
        id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&aError];
        if (aError) {
            if (retHandler) {
                retHandler(nil, aError);
            }
            return;
        }
        
        if (object && [object isKindOfClass:[NSDictionary class]])
        {
            if (HETSafeIntegerForKeyInDict(object, @"code") == 0)
            {
//                data =     {
//                    accessToken = 06de373cd1634d4e8be9c0ced3ad40e5;
//                    expiresIn = 28800;
//                };
//                NSLog(@"---object-%@--",object);
                NSDictionary *data = HETSafeDictionaryForKeyInDict(object, @"data");
                NSNumber *expiresIn = HETSafeNumberForKeyInDict(data, @"expiresIn");
                NSTimeInterval expiresTimeStamp = [NSDate.date timeIntervalSince1970] + expiresIn.integerValue;
                NSString *accessToken = HETSafeStringForKeyInDict(data, @"accessToken");
                if (accessToken) {
                    HETSaveAuthData(@{@"accessToken":accessToken,
                                      @"expiresIn":@(expiresTimeStamp)}, KAccessTokenStoreKey);
                }
                
                if (retHandler) {
                    retHandler(accessToken, nil);
                }
            }
            else
            {
                NSString *errorMsg = HETSafeStringForKeyInDict(object, @"msg");
                NSError *error = [NSError errorWithDomain:HETNetworkErrorDomain
                                                     code:HETSkinAnalysisErrorCodeDataParsingFailed
                                                 userInfo:@{NSLocalizedDescriptionKey:HETSafeNonNilString(errorMsg)}];
                if (retHandler) {
                    retHandler(nil,error);
                }
            }
        }
        else
        {
            NSError *error = [NSError errorWithDomain:HETNetworkErrorDomain
                                                 code:HETSkinAnalysisErrorCodeDataParsingFailed
                                             userInfo:@{NSLocalizedDescriptionKey:@"错误的响应结果"}];
            if (retHandler) {
                retHandler(nil,error);
            }
        }
    }];
    [dataTask resume];
    return dataTask;
}

#pragma mark - 获取腾讯云凭证

+ (NSURLSessionDataTask*)getQCloudCredential:(NSString*)accessToken result:(void(^)(id responseObject, NSError *error))retHandler
{
    if (!accessToken) {
        NSError *error = [NSError errorWithDomain:HETNetworkErrorDomain
                                             code:HETSkinAnalysisErrorCodeMissingParameters
                                         userInfo:@{NSLocalizedDescriptionKey:@"accessToken不可空"}];
        if (retHandler) {
            retHandler(nil, error);
        }
        return nil;
    }
    HETSkinAnalysisConfiguration *config = [HETSkinAnalysisConfiguration rawDefaultConfiguration];
    NSAssert(config.appId != nil && config.appSecret != nil, @"大数据肤质分析需要设置一个可用的AppId和秘钥，请前往clife平台申请！");
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSString *urlString = [HETGetURLDomain() stringByAppendingString:HETQCloudCredentialURLPath()];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:30.0];
    [request setHTTPMethod:@"POST"];
    
    NSMutableArray *tmpArray = [NSMutableArray array];
    [tmpArray addObject:[NSString stringWithFormat:@"appId=%@",config.appId]];
    [tmpArray addObject:[NSString stringWithFormat:@"accessToken=%@",accessToken]];
    
    NSString *parameterString = [tmpArray componentsJoinedByString:@"&"];
    NSData *parametersData = [parameterString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:parametersData];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if (retHandler) {
                retHandler(nil, error);
            }
            return ;
        }
        NSError *aError;
        id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&aError];
        if (aError) {
            if (retHandler) {
                retHandler(nil, aError);
            }
            return;
        }
        
        if (object && [object isKindOfClass:[NSDictionary class]])
        {
            if (HETSafeIntegerForKeyInDict(object, @"code") == 0)
            {
                NSDictionary *responseDict = HETSafeDictionaryForKeyInDict(object, @"data");
                if (retHandler) {
                    retHandler(responseDict, nil);
                }
            }
            else
            {
                NSString *errorMsg = HETSafeStringForKeyInDict(object, @"message");
                NSError *error = [NSError errorWithDomain:HETNetworkErrorDomain
                                                     code:HETSkinAnalysisErrorCodeDataParsingFailed
                                                 userInfo:@{NSLocalizedDescriptionKey:HETSafeNonNilString(errorMsg)}];
                if (retHandler) {
                    retHandler(nil,error);
                }
            }
        }
        else
        {
            NSError *error = [NSError errorWithDomain:HETNetworkErrorDomain
                                                 code:HETSkinAnalysisErrorCodeDataParsingFailed
                                             userInfo:@{NSLocalizedDescriptionKey:@"错误的响应结果"}];
            if (retHandler) {
                retHandler(nil,error);
            }
        }
    }];
    [dataTask resume];
    return dataTask;
}


#pragma mark - 提交大数据分析
+ (NSURLSessionDataTask*)getSkinAnalysisData:(NSString*)accessToken imageUrl:(NSString*)imageUrl result:(void(^)(id responseObject, NSError *error))retHandler
{
    if (!accessToken) {
        NSError *error = [NSError errorWithDomain:HETNetworkErrorDomain
                                             code:HETSkinAnalysisErrorCodeMissingParameters
                                         userInfo:@{NSLocalizedDescriptionKey:@"accessToken不可空"}];
        if (retHandler) {
            retHandler(nil, error);
        }
        return nil;
    }
    HETSkinAnalysisConfiguration *config = [HETSkinAnalysisConfiguration rawDefaultConfiguration];
    NSAssert(config.appId != nil && config.appSecret != nil, @"大数据肤质分析需要设置一个可用的AppId和秘钥，请前往clife平台申请！");
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSString *urlString =  [HETGetURLDomain() stringByAppendingString:HETSkinAnalysisURLPath()];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setSafeObject:accessToken forKey:@"accessToken"];
    [param setSafeObject:config.appId forKey:@"appId"];
    NSTimeInterval timeStamp = [NSDate.date timeIntervalSince1970];
    [param setSafeObject:@((long long)(timeStamp*1000)) forKey:@"timestamp"];
    [param setSafeObject:@(4) forKey:@"appType"];
    [param setSafeObject:imageUrl forKey:@"imageUrl"];
    NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    [param setSafeObject:idfa forKey:@"deviceMac"];
    
    NSString *code = [NSString stringWithFormat:@"%@%@",config.appSecret,config.appId];
    NSData *codeData =[code dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64Code = [codeData base64EncodedStringWithOptions:0];
    NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];//@"com.marykay.cn.xiaofu";//@"com.marykay.ap.sellingtools";
    NSString *md5Code = [[base64Code stringByAppendingFormat:@"%@",bundleId]md5String];
    [param setSafeObject:md5Code forKey:@"authMsg"];
    
    NSString *sortedParamstring = [param sortedParamsString];
    NSString *unsignedString = [NSString stringWithFormat:@"POST%@%@&%@",urlString,sortedParamstring,config.appSecret];
    NSString *sign = [unsignedString md5String];
    [param setSafeObject:sign forKey:@"sign"];
    
    NSString *postString = [param sortedParamsString];
    NSData *parametersData = [postString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:parametersData];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"--response--[%@]==%@",error,data);
        if (error) {
            if (retHandler) {
                retHandler(nil, error);
            }
            return ;
        }
        
        NSError *aError;
        id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&aError];
        if (aError) {
            if (retHandler) {
                retHandler(nil, aError);
            }
            return;
        }
        NSLog(@"--response--[%@]==%@",error,object);
        if (object && [object isKindOfClass:[NSDictionary class]])
        {
            if (HETSafeIntegerForKeyInDict(object, @"code") == 0)
            {
                NSDictionary *responseDict = HETSafeDictionaryForKeyInDict(object, @"data");
                NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:responseDict];
                [dictionary setSafeObject:imageUrl forKey:@"originalImageUrl"];
                if (retHandler) {
                    retHandler(dictionary, nil);
                }
            }
            else
            {
                NSString *errorMsg = HETSafeStringForKeyInDict(object, @"msg");
                NSError *error = [NSError errorWithDomain:HETNetworkErrorDomain
                                                     code:HETSkinAnalysisErrorCodeDataParsingFailed
                                                 userInfo:@{NSLocalizedDescriptionKey:HETSafeNonNilString(errorMsg)}];
                if (retHandler) {
                    retHandler(nil,error);
                }
            }
        }
        else
        {
            NSError *error = [NSError errorWithDomain:HETNetworkErrorDomain
                                                 code:HETSkinAnalysisErrorCodeDataParsingFailed
                                             userInfo:@{NSLocalizedDescriptionKey:@"错误的响应结果"}];
            if (retHandler) {
                retHandler(nil,error);
            }
        }
    }];
    [dataTask resume];
    return dataTask;
}

#pragma mark - 签名提取

+ (NSURLSessionDataTask*)getJSONApiSignature:(NSString*)accessToken
                                   bucketUrl:(NSString*)bucketUrl
                                      result:(void(^)(id responseObject, NSError *error))retHandler
{
    if (!accessToken || !bucketUrl) {
        NSError *error = [NSError errorWithDomain:HETNetworkErrorDomain
                                             code:HETSkinAnalysisErrorCodeMissingParameters
                                         userInfo:@{NSLocalizedDescriptionKey:@"accessToken或者bucketUrl不可空"}];
        if (retHandler) {
            retHandler(nil, error);
        }
        return nil;
    }
    HETSkinAnalysisConfiguration *config = [HETSkinAnalysisConfiguration rawDefaultConfiguration];
    NSAssert(config.appId != nil, @"大数据肤质分析需要设置一个可用的AppId和秘钥，请前往clife平台申请！");
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSString *urlString =  [HETGetURLDomain() stringByAppendingString:HETJSONApiSignatureURLPath()];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    
    NSMutableArray *tmpArray = [NSMutableArray array];
    [tmpArray addObject:[NSString stringWithFormat:@"accessToken=%@",accessToken]];
    [tmpArray addObject:[NSString stringWithFormat:@"appId=%@",config.appId]];
    [tmpArray addObject:[NSString stringWithFormat:@"bucketUrl=%@",bucketUrl]];
    
    NSString *parameterString = [tmpArray componentsJoinedByString:@"&"];
    NSData *parametersData = [parameterString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:parametersData];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if (retHandler) {
                retHandler(nil, error);
            }
            return ;
        }
        NSError *aError;
        id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&aError];
        if (aError) {
            if (retHandler) {
                retHandler(nil, aError);
            }
            return;
        }
        if (object && [object isKindOfClass:[NSDictionary class]])
        {
            if (HETSafeIntegerForKeyInDict(object, @"code") == 0)
            {
                NSDictionary *responseDict = HETSafeDictionaryForKeyInDict(object, @"data");
                if (retHandler) {
                    retHandler(responseDict, nil);
                }
            }
            else
            {
                NSString *errorMsg = HETSafeStringForKeyInDict(object, @"msg");
                NSError *error = [NSError errorWithDomain:HETNetworkErrorDomain
                                                     code:HETSkinAnalysisErrorCodeDataParsingFailed
                                                 userInfo:@{NSLocalizedDescriptionKey:HETSafeNonNilString(errorMsg)}];
                if (retHandler) {
                    retHandler(nil,error);
                }
            }
        }
        else
        {
            NSError *error = [NSError errorWithDomain:HETNetworkErrorDomain
                                                 code:HETSkinAnalysisErrorCodeDataParsingFailed
                                             userInfo:@{NSLocalizedDescriptionKey:@"错误的响应结果"}];
            if (retHandler) {
                retHandler(nil,error);
            }
        }
    }];
    [dataTask resume];
    return dataTask;
}
@end
