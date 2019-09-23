//
//  HETSkinAnalysisConfiguration+HETPrivate.h
//  HETSkinAnalysis
//
//  Created by 远征 马 on 2019/7/2.
//  Copyright © 2019 马远征. All rights reserved.
//

#import "HETSkinAnalysisConfiguration.h"

NS_ASSUME_NONNULL_BEGIN
@interface HETSkinAnalysisConfiguration ()
@property (nonatomic, strong) NSString *appId;
@property (nonatomic, strong) NSString *appSecret;
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, assign) AVCaptureDevicePosition captureDevicePosition;
@property (nonatomic, assign) BOOL playVoiceEnable;
@property (nonatomic, assign) BOOL isTakeingPhotos;
@property (nonatomic, assign) CGRect faceDetectionBounds;
@property (nonatomic, assign) CGRect cameraDetectionBounds;
@property (nonatomic, assign) HETFaceDetectionEngine faceDetectionEngine;
@property (nonatomic, strong) id<HETSkinAnalysisVoiceDelegate> voiceConfig;
@property (nonatomic, strong) id<HETCaptureDeviceConfigDelegate> videoConfig;

+ (HETSkinAnalysisConfiguration *)rawDefaultConfiguration;
- (id<HETCaptureDeviceConfigDelegate>)getCaptureDeviceConfig;
/**
 获取拍照测肤语音配置
 
 @warning 如果没有调用 <i>setCustomVoice：</i>接口设置，则使用默认HETSkinAnalysisVoice初始化
 @return HETSkinAnalysisVoiceDelegate协议实例
 */
- (id<HETSkinAnalysisVoiceDelegate>)getVoiceConfig;
+ (void)resetConfigurationState;
@end
NS_ASSUME_NONNULL_END
