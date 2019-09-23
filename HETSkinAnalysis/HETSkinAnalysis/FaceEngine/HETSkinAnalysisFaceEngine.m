//
//  HETSkinAnalysisFaceEngine.m
//  HETSkinAnalysis
//
//  Created by 远征 马 on 2019/7/12.
//  Copyright © 2019 马远征. All rights reserved.
//

#import "HETSkinAnalysisFaceEngine.h"
#import "HETSkinAnalysisConfiguration+HETPrivate.h"
#import "HETSkinAnalysisPlayer.h"
#import "UIImage+HETSkinAnalysis.h"
#import "HETFaceAnalysisResult.h"
#import "HETSkinAnalysisDefinePrivate.h"
#import "HETDefaultFaceEngine.h"

// 拍照就绪连续检测次数
static NSInteger KMaxContinDetectionCount = 50;

@interface HETSkinAnalysisFaceEngine ()
@property (nonatomic, strong) HETSkinAnalysisPlayer *voicePlayer;
@property (nonatomic, assign) HETFaceDetectMode faceDetectMode;
@property (nonatomic, assign) HETFaceAnalysisStatus faceAnalysisStatus;
@property (nonatomic, assign) NSInteger videoBufferNormalStatusCallbackCount;
@property (nonatomic, strong) id<HETSkinAnalysisFaceEngineDelegate> faceEngine;
@end

@implementation HETSkinAnalysisFaceEngine

- (instancetype)init
{
    self = [super init];
    if (self) {
        _voicePlayer = [[HETSkinAnalysisPlayer alloc]init];
    }
    return self;
}

- (BOOL)isValidEngine
{
    return (self.faceEngine ? [self.faceEngine isValidEngine] : NO);
}

- (BOOL)activeEngine:(HETFaceDetectMode)faceDetectMode
{
    self.faceDetectMode = faceDetectMode;
    HETSkinAnalysisConfiguration *config = [HETSkinAnalysisConfiguration rawDefaultConfiguration];
    if (config.faceDetectionEngine == HETFaceDetectionEngineDefault) {
        _faceEngine = [[HETDefaultFaceEngine alloc]init];
        return [_faceEngine activeEngine:faceDetectMode];
    }
    else
    {
        if (_faceEngine) {
            return [_faceEngine activeEngine:faceDetectMode];
        }
        NSAssert(_faceEngine != nil, @"请先设置一个自定义引擎，see接口<i>setCustomFaceEngine:<i/>");
    }
    return NO;
}

- (void)setCustomFaceEngine:(id<HETSkinAnalysisFaceEngineDelegate>)faceEngine
{
    if (faceEngine != _faceEngine) {
        // 销毁老的人脸识别引擎
        [_faceEngine destoryEngine];
        _faceEngine = nil;
    }
    _faceEngine = faceEngine;
    HETSkinAnalysisConfiguration *config = [HETSkinAnalysisConfiguration rawDefaultConfiguration];
    config.faceDetectionEngine = HETFaceDetectionEngineCustom;
}

- (BOOL)changeFaceDetectMode:(HETFaceDetectMode)faceDetectMode
{
    if (_faceEngine) {
        return [_faceEngine changeFaceDetectMode:faceDetectMode];
    }
    return NO;
}

- (void)destoryEngine
{
    if (_faceEngine) {
        [_faceEngine destoryEngine];
        _faceEngine = nil;
    }
    _voicePlayer = nil;
    [[HETSkinAnalysisPlayer defaultPlayer]destoryPlayer];
    // 移除所有缓存的文件路径
    HETRemoveAllVoiceFilePathCache();
}

- (NSArray<id<HETFaceAnalysisResultDelegate>> *)getFaceFeaturesFromStillImage:(UIImage *)image {
    if (self.faceEngine) {
        return [self.faceEngine getFaceFeaturesFromStillImage:image];
    }
    return nil;
}

- (UIImage*)getVideoBufferImageFromVideoBuffer:(CMSampleBufferRef)sampleBuffer
{
    if (self.faceEngine) {
        return [self.faceEngine getVideoBufferImageFromVideoBuffer:sampleBuffer];
    }
    return nil;
}

- (NSArray<id<HETFaceAnalysisResultDelegate>>*)getFaceFeaturesFromVideoBufferImage:(UIImage*)image {
    if (self.faceEngine) {
        return [self.faceEngine getFaceFeaturesFromVideoBufferImage:image];
    }
    return nil;
}

- (NSArray<id<HETFaceAnalysisResultDelegate>> *)getFaceFeaturesFromVideoBuffer:(CMSampleBufferRef)sampleBuffer
{
    if (self.faceEngine) {
        return [self.faceEngine getFaceFeaturesFromVideoBuffer:sampleBuffer];
    }
    return nil;
}


#pragma mark - 判断图像是否可用

- (BOOL)isValidImageForSkinAnalysis:(UIImage*)image error:(NSError**)error
{
    NSAssert(image != nil, @"image不可为空，请传入一个可用的人脸图像");
    // 视频侦测模式需要检测图像大小和方向
    if (self.faceDetectMode == HETFaceDetectModeVideo) {
        CGFloat width = image.size.width;
        CGFloat height = image.size.height;
//        if (width > height) {
//            // 横屏拍摄无法识别人脸
//            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"横屏拍摄无法识别人脸,请确保竖屏拍摄"};
//            *error = [NSError errorWithDomain:HETFaceDetectErrorDomain
//                                         code:HETSkinAnalysisErrorCodeWrongImageAspectRatio
//                                     userInfo:userInfo];
//            return NO;
//        }
        if (width < 1500 || height < 2000) {
            // 照片太小识别失败，建议切换后置拍照
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"照片太小识别失败，建议切换后置拍照"};
            *error = [NSError errorWithDomain:HETFaceDetectErrorDomain
                                         code:HETSkinAnalysisErrorCodeLowPixel
                                     userInfo:userInfo];
            return NO;
        }
    }
    NSArray *faceInfoArray = [self getFaceFeaturesFromStillImage:image];
    if (faceInfoArray.count <= 0) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"识别失败，没有检测到人脸"};
        *error = [NSError errorWithDomain:HETFaceDetectErrorDomain
                                     code:HETSkinAnalysisErrorCodeNoFace
                                 userInfo:userInfo];
        return NO;
    }
//    识别失败，没有检测到正面清晰的人脸
    if (faceInfoArray.count > 1) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"检测到多张人脸"};
        *error = [NSError errorWithDomain:HETFaceDetectErrorDomain
                                     code:HETSkinAnalysisErrorCodeMultipleFace
                                 userInfo:userInfo];
        return NO;
    }
    
    id<HETFaceAnalysisResultDelegate> faceFeature = [faceInfoArray firstObject];
    if (![faceFeature isStandardFace])
    {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"人脸角度不符合要求，没有检测到正面清晰的人脸"};
        *error = [NSError errorWithDomain:HETFaceDetectErrorDomain
                                     code:HETSkinAnalysisErrorCodeNonStandardFace
                                 userInfo:userInfo];
        return NO;
    }
    return YES;
}


#pragma mark - 图像分析

- (void)processFaceImage:(UIImage*)image result:(void(^)(HETFaceAnalysisResult *analysisResult))retHandler
{
    NSAssert(image != nil, @"image不可为空，请传入一个可用的人脸图像");
    NSArray *arrayFaceInfo = [self getFaceFeaturesFromStillImage:image];
//    NSLog(@"---arrayFaceInfo--%@",arrayFaceInfo);
    
    HETSkinAnalysisConfiguration *config = [HETSkinAnalysisConfiguration rawDefaultConfiguration];
    id<HETSkinAnalysisVoiceDelegate> voiceConfig = [config getVoiceConfig];
    // 没有识别到人脸返回无人脸信息
    if (arrayFaceInfo.count <= 0)
    {
        HETFaceAnalysisResult *analysisResult = [[HETFaceAnalysisResult alloc]init];
        analysisResult.status = HETFaceAnalysisStatusNoFace;
        analysisResult.faces = arrayFaceInfo;
        analysisResult.statusDesc = [voiceConfig getNoFaceDetectedVoiceText];
        het_dispatch_async_main(^{
            if (retHandler) {
                retHandler(analysisResult);
            }
        });
        return;
    }
    else if (arrayFaceInfo.count > 1)
    {
        // 检测到多个人脸，返回多个人脸信息
        HETFaceAnalysisResult *analysisResult = [[HETFaceAnalysisResult alloc]init];
        analysisResult.status = HETFaceAnalysisStatusMultipleFace;
        analysisResult.faces = arrayFaceInfo;
        analysisResult.statusDesc = [voiceConfig getMultipleFaceVoiceText];
        het_dispatch_async_main(^{
            if (retHandler) {
                retHandler(analysisResult);
            }
        });
        return;
    }
    id<HETFaceAnalysisResultDelegate> faceInfo = arrayFaceInfo[0];
    // 只有一个人脸，计算距离和亮度，返回结果
    UIImage *newImage = [UIImage imageWithCGImage:image.CGImage scale:1.0 orientation:UIImageOrientationLeftMirrored];
    // 修正图片方向
    UIImage *fixedImage = [newImage hetFixedOrientationImage];
    CGFloat imageWidth = fixedImage.size.width;
    if (imageWidth > fixedImage.size.height) {
        imageWidth = fixedImage.size.height;
    }
    CGFloat faceWidth = CGRectGetWidth([faceInfo getfaceBounds]);
    // 计算距离
    CGFloat distance = faceWidth/imageWidth;
    HETFaceAnalysisResult *analysisResult = [[HETFaceAnalysisResult alloc]init];
    analysisResult.faces = arrayFaceInfo;
    analysisResult.distance = distance;
    analysisResult.status = HETFaceAnalysisStatusCanTakePhoto;
    analysisResult.statusDesc = [voiceConfig getWillTakePhotoVoiceText];
    het_dispatch_async_main(^{
        if (retHandler) {
            retHandler(analysisResult);
        }
    });
}

#pragma mark - 视频帧处理

- (void)processVideoFrameBuffer:(CMSampleBufferRef)sampleBuffer
               faceInfoCallback:(void(^)(HETFaceAnalysisResult *analysisResult))callback
                         result:(dispatch_block_t)retHandler
{
    
    // 每3帧丢弃2帧
//    static NSInteger discardFrameCount = 0;
//    if (discardFrameCount < 2) {
//        discardFrameCount ++;
//        return;
//    }
//    discardFrameCount = 0;
    HETSkinAnalysisConfiguration *config = [HETSkinAnalysisConfiguration rawDefaultConfiguration];
    NSArray *arrayFaceInfo = nil;
    UIImage *fixedImage = nil;
    fixedImage = [self getVideoBufferImageFromVideoBuffer:sampleBuffer];
    arrayFaceInfo = [self getFaceFeaturesFromVideoBufferImage:fixedImage];
    
    id<HETSkinAnalysisVoiceDelegate> voiceConfig = [config getVoiceConfig];
    
    if (arrayFaceInfo.count <= 0)
    {
        HETFaceAnalysisResult *analysisResult = [[HETFaceAnalysisResult alloc]init];
        analysisResult.status = HETFaceAnalysisStatusNoFace;
        analysisResult.faces = arrayFaceInfo;
        AVCaptureDevicePosition position = config.captureDevicePosition;
        NSString *voiceFile = [voiceConfig getNoFaceDetectedVoice];
        analysisResult.statusDesc = [voiceConfig getNoFaceDetectedVoiceText];
        if (position == AVCaptureDevicePositionFront) {
            voiceFile = [voiceConfig getFrontCameraTakePhotoPromptVoice];
            analysisResult.statusDesc = [voiceConfig getFrontCameraTakePhotoPromptVoiceText];
        }
        else if (position == AVCaptureDevicePositionBack)
        {
            voiceFile = [voiceConfig getRearCameraTakePhotoPromptVoice];
            analysisResult.statusDesc = [voiceConfig getRearCameraTakePhotoPromptVoiceText];
        }
        self.faceAnalysisStatus = analysisResult.status;
        het_dispatch_async_main(^{
            if (config.playVoiceEnable) {
                [[HETSkinAnalysisPlayer defaultPlayer]playVoice:voiceFile result:nil];
            }
            if (callback) {
                callback(analysisResult);
            }
        });
        return;
    }
    else if (arrayFaceInfo.count > 1)
    {
        // 检测到多个人脸，返回多个人脸信息
        HETFaceAnalysisResult *analysisResult = [[HETFaceAnalysisResult alloc]init];
        analysisResult.status = HETFaceAnalysisStatusMultipleFace;
        analysisResult.faces = arrayFaceInfo;
        analysisResult.statusDesc = [voiceConfig getMultipleFaceVoiceText];
        self.faceAnalysisStatus = analysisResult.status;
        het_dispatch_async_main(^{
            if (config.playVoiceEnable) {
                [[HETSkinAnalysisPlayer defaultPlayer]playVoice:[voiceConfig getMultipleFaceVoice] result:nil];
            }
            if (callback) {
                callback(analysisResult);
            }
        });
        return;
    }
    id<HETFaceAnalysisResultDelegate> faceInfo = arrayFaceInfo[0];
    // 标准人脸姿势识别
    if (config.standardFaceCheckEnable && ![faceInfo isStandardFace])
    {
        HETFaceAnalysisResult *analysisResult = [[HETFaceAnalysisResult alloc]init];
        analysisResult.status = HETFaceAnalysisStatusNonStandardFace;
        analysisResult.faces = arrayFaceInfo;
        analysisResult.statusDesc = [voiceConfig getKeepStandardFaceVoiceText];
        self.faceAnalysisStatus = analysisResult.status;
        het_dispatch_async_main(^{
            if (config.playVoiceEnable) {
                [[HETSkinAnalysisPlayer defaultPlayer]playVoice:[voiceConfig getKeepStandardFaceVoice] result:nil];
            }
            if (callback) {
                callback(analysisResult);
            }
        });
        return;
    }
    // 只有一个人脸，判断人脸是否位于当前区域框
    if (config.faceBoundsDetectionEnable &&
        !CGRectEqualToRect(config.faceDetectionBounds, CGRectZero) &&
        !CGRectEqualToRect(config.cameraDetectionBounds, CGRectZero))
    {
        if (!CGRectContainsRect(config.faceDetectionBounds, [faceInfo getFaceBoxBounds]))
        {
            HETFaceAnalysisResult *analysisResult = [[HETFaceAnalysisResult alloc]init];
            analysisResult.status = HETFaceAnalysisStatusOutOfBounds;
            analysisResult.faces = arrayFaceInfo;
            analysisResult.statusDesc = [voiceConfig getKeepFaceInCenterFrameVoiceText];
            self.faceAnalysisStatus = analysisResult.status;
            het_dispatch_async_main(^{
                if (config.playVoiceEnable) {
                    [[HETSkinAnalysisPlayer defaultPlayer]playVoice:[voiceConfig getKeepFaceInCenterFrameVoice] result:nil];
                }
                if (callback) {
                    callback(analysisResult);
                }
            });
            return;
        }
    }
    // 只有一个人脸，计算距离和亮度，返回结果
    if (!fixedImage) {
        fixedImage = [self getVideoBufferImageFromVideoBuffer:sampleBuffer];
    }
    if (config.faceDetectionEngine == HETFaceDetectionEngineDefault) {
        UIImage *newImage = [UIImage imageWithCGImage:fixedImage.CGImage scale:1.0 orientation:UIImageOrientationLeftMirrored];
        fixedImage = [newImage hetFixedOrientationImage];
    }
    
    CGFloat imageWidth = fixedImage.size.width;
    if (imageWidth > fixedImage.size.height) {
        imageWidth = fixedImage.size.height;
    }
    // 计算距离和亮度
    CGFloat faceWidth = CGRectGetWidth([faceInfo getfaceBounds]);
    CGFloat distance = 0;
    if (config.distanceDetectionEnable) {
        distance = faceWidth/imageWidth;
    }
    NSInteger yuvLight = 0;
    if (config.yuvLightDetectionEnable) {
        yuvLight = [UIImage hetYUVLightFromSampleBuffer:sampleBuffer faceRect:[faceInfo getfaceBounds] inputImageWidth:imageWidth];
    }

    HETFaceAnalysisResult *analysisResult = [[HETFaceAnalysisResult alloc]init];
    analysisResult.faces = arrayFaceInfo;
    analysisResult.light = yuvLight;
    analysisResult.distance = distance;
    
    // 最小亮度检测
    if (config.yuvLightDetectionEnable && yuvLight < config.minYUVLight)
    {
        analysisResult.status = HETFaceAnalysisStatusLightDim;
        analysisResult.statusDesc = [voiceConfig getLightDimVoiceText];
        self.faceAnalysisStatus = analysisResult.status;
        het_dispatch_async_main(^{
            if (config.playVoiceEnable) {
                [[HETSkinAnalysisPlayer defaultPlayer]playVoice:[voiceConfig getLightDimVoice] result:nil];
            }
            if (callback) {
                callback(analysisResult);
            }
        });
        return;
    }
    
    // 最大亮度检测
    if (config.yuvLightDetectionEnable && yuvLight > config.maxYUVLight)
    {
        analysisResult.status = HETFaceAnalysisStatusLightBright;
        analysisResult.statusDesc = [voiceConfig getLightBrightVoiceText];
        self.faceAnalysisStatus = analysisResult.status;
        het_dispatch_async_main(^{
            if (config.playVoiceEnable) {
                [[HETSkinAnalysisPlayer defaultPlayer]playVoice:[voiceConfig getLightBrightVoice] result:nil];
            }
            if (callback) {
                callback(analysisResult);
            }
        });
        return;
    }
    
    // 最小距离侦测
    if (config.distanceDetectionEnable && distance < config.minDetectionDistance) // 720 405
    {
        analysisResult.status = HETFaceAnalysisStatusDistanceFar;
        analysisResult.statusDesc = [voiceConfig getDistanceFarVoiceText];
        self.faceAnalysisStatus = analysisResult.status;
        het_dispatch_async_main(^{
            if (config.playVoiceEnable) {
                [[HETSkinAnalysisPlayer defaultPlayer]playVoice:[voiceConfig getDistanceFarVoice] result:nil];
            }
            if (callback) {
                callback(analysisResult);
            }
        });
        return;
    }
    
    // 最大距离侦测
    if(config.distanceDetectionEnable && distance > config.maxDetectionDistance) // 720 666
    {
        analysisResult.status = HETFaceAnalysisStatusDistanceNear;
        analysisResult.statusDesc = [voiceConfig getDistanceNearVoiceText];
        self.faceAnalysisStatus = analysisResult.status;
        het_dispatch_async_main(^{
            if (config.playVoiceEnable) {
                [[HETSkinAnalysisPlayer defaultPlayer]playVoice:[voiceConfig getDistanceNearVoice] result:nil];
            }
            if (callback) {
                callback(analysisResult);
            }
        });
        return;
    }
    analysisResult.status = HETFaceAnalysisStatusCanTakePhoto;
    analysisResult.statusDesc = [voiceConfig getWillTakePhotoVoiceText];
    if (self.faceAnalysisStatus != HETFaceAnalysisStatusCanTakePhoto) {
        // 声音切换则停止当前声音播放
        [[HETSkinAnalysisPlayer defaultPlayer]stop];
    }
    het_dispatch_async_main(^{
        if (callback) {
            callback(analysisResult);
        }
    });
    
    // 连续五十次检测到人脸才输出状态,防止误拍
    if (self.videoBufferNormalStatusCallbackCount <= KMaxContinDetectionCount) {
        self.videoBufferNormalStatusCallbackCount ++;
        return;
    }
    self.videoBufferNormalStatusCallbackCount = 0;
    if (self.faceAnalysisStatus == HETFaceAnalysisStatusCanTakePhoto) {
        // 返回相同的状态不做处理
        return;
    }
    self.faceAnalysisStatus = HETFaceAnalysisStatusCanTakePhoto;
    het_dispatch_async_main(^{
        if (config.playVoiceEnable) {
            // 语音播放完成回调数据
            [[HETSkinAnalysisPlayer defaultPlayer]playVoice:[voiceConfig getWillTakePhotoVoice] result:^(BOOL flag, NSError *error) {
                het_dispatch_async_main(^{
                    if (retHandler) {
                        retHandler();
                    }
                });
            }];
        }
        else
        {
            // 返回相机状态、人脸距离、照片亮度、人脸边界特征等参数
            if (retHandler) {
                retHandler();
            }
        }
    });
}
@end
