//
//  HETSkinAnalysisConfiguration.m
//  HETSkinAnalysis
//
//  Created by 远征 马 on 2019/6/28.
//  Copyright © 2019 马远征. All rights reserved.
//

#import "HETSkinAnalysisConfiguration.h"
#import "HETSkinAnalysisConfiguration+HETPrivate.h"
#import "HETSkinAnalysisVoice.h"
#import "HETDefaultFaceEngine.h"
#import "HETSkinAnalysisPlayer.h"

static NSString *const skc_defaultConfiFileName = @"default.skinAnalysis.config";
HETSkinAnalysisConfiguration *skc_defaultConfiguration;


@implementation HETSkinAnalysisConfiguration

- (instancetype)init
{
    self = [super init];
    if (self) {
        _playVoiceEnable = YES;
        _maxDetectionDistance = 0.85;
        _minDetectionDistance = 0.65;
        _maxYUVLight = 220;
        _minYUVLight = 80;
        _standardFaceCheckEnable = YES;
        _faceBoundsDetectionEnable = YES;
        _yuvLightDetectionEnable = YES;
        _distanceDetectionEnable = YES;
    }
    return self;
}

#pragma mark - auth 

- (void)registerWithAppId:(NSString*)appId andSecret:(NSString*)appSecret
{
    NSAssert(appId != nil && appSecret != nil, @"大数据肤质分析需要设置一个可用的AppId和秘钥，请前往clife平台申请！");
    self.appId = appId;
    self.appSecret = appSecret;
}


#pragma mark - Mute

+ (BOOL)setMute:(BOOL)muted
{
    HETSkinAnalysisConfiguration *config = [HETSkinAnalysisConfiguration rawDefaultConfiguration];
    config.playVoiceEnable = !muted;
    if (muted) {
        [[HETSkinAnalysisPlayer defaultPlayer]stop];
    }
    return YES;
}


+ (BOOL)isMuted
{
    HETSkinAnalysisConfiguration *config = [HETSkinAnalysisConfiguration rawDefaultConfiguration];
    return config.playVoiceEnable;
}

#pragma mark - 设置默认摄像头方向
/**
 设置默认摄像头方向，用于语音播放识别
 
 */
+ (void)setDefaultCaptureDevicePosition:(AVCaptureDevicePosition)position
{
    HETSkinAnalysisConfiguration *config = [HETSkinAnalysisConfiguration rawDefaultConfiguration];
    config.captureDevicePosition = position;
}

- (void)setDefaultCaptureDevicePosition:(AVCaptureDevicePosition)position
{
    self.captureDevicePosition = position;
}

+ (AVCaptureDevicePosition)getDefaultCaptureDevicePosition
{
    HETSkinAnalysisConfiguration *config = [HETSkinAnalysisConfiguration rawDefaultConfiguration];
    return config.captureDevicePosition;
}

#pragma mark - 人脸检测引擎

- (void)setFaceDetectionEngine:(HETFaceDetectionEngine)engine
{
    if (engine != _faceDetectionEngine ) {
        _faceDetectionEngine = engine;
    }
}

#pragma mark - 检测边界

- (void)setCameraBounds:(CGRect)bounds
{
    if (![self isValidBounds:bounds]) {
        _cameraDetectionBounds = CGRectZero;
        return;
    }
    self.cameraDetectionBounds = bounds;
}

- (BOOL)isValidBounds:(CGRect)bounds
{
    return (bounds.size.width > 0 && bounds.size.height > 0);
}


+ (CGRect)getCameraBounds
{
    HETSkinAnalysisConfiguration *config = [HETSkinAnalysisConfiguration rawDefaultConfiguration];
    if ([config isValidBounds:config.cameraDetectionBounds]) {
        return config.cameraDetectionBounds;
    }
    return CGRectZero;
}

- (void)setFaceDetectionBounds:(CGRect)bounds
{
    // 对于不符合要求的检测边界，将使用无边界设置
    if (![self isValidBounds:bounds])
    {
        _faceDetectionBounds = CGRectZero;
        return;
    }
    _faceDetectionBounds = bounds;
}

+ (CGRect)getFaceDetectionBounds
{
    HETSkinAnalysisConfiguration *config = [HETSkinAnalysisConfiguration rawDefaultConfiguration];
    if ([config isValidBounds:config.faceDetectionBounds]) {
        return config.faceDetectionBounds;
    }
    return CGRectZero;
}

#pragma mark - 相机参数设置

- (void)setCaptureDeviceConfig:(id<HETCaptureDeviceConfigDelegate>)captureDeviceConfig
{
    if (!captureDeviceConfig) {
        return;
    }
    self.videoConfig = captureDeviceConfig;
    self.faceDetectionEngine = HETFaceDetectionEngineCustom;
}

- (id<HETCaptureDeviceConfigDelegate>)getCaptureDeviceConfig
{
    if (_videoConfig) {
        return _videoConfig;
    }
    if (self.faceDetectionEngine == HETFaceDetectionEngineDefault) {
        _videoConfig = [[HETDefaultFaceEngineVideoConfig alloc]init];
    }
    else
    {
        _videoConfig = [[HETCaptureDeviceConfig alloc]init];
    }
    return _videoConfig;
}

#pragma mark - Voice Config

- (id<HETSkinAnalysisVoiceDelegate>)getVoiceConfig
{
    if (self.voiceConfig) {
        return self.voiceConfig;
    }
    self.voiceConfig = [[HETSkinAnalysisVoice alloc]init];
    return self.voiceConfig;
}

- (void)setCustomVoice:(id<HETSkinAnalysisVoiceDelegate>)voiceConfig
{
    if (!voiceConfig) {
        self.voiceConfig = [[HETSkinAnalysisVoice alloc]init];
    }
    else
    {
        self.voiceConfig = voiceConfig;
    }
}


+ (instancetype)defaultConfiguration
{
    return [[self rawDefaultConfiguration] copy];
}

+ (void)setDefaultConfiguration:(HETSkinAnalysisConfiguration *)configuration
{
    if (!configuration) {
        //        @throw NSException(@"Cannot set the default configuration to nil.");
        @throw [NSException exceptionWithName:@"Warning" reason:@"Cannot set the default configuration to nil." userInfo:nil];
    }
    @synchronized(skc_defaultConfiFileName) {
        skc_defaultConfiguration = [configuration copy];
    }
}

+ (HETSkinAnalysisConfiguration *)rawDefaultConfiguration
{
    HETSkinAnalysisConfiguration *configuration;
    @synchronized(skc_defaultConfiFileName) {
        if (!skc_defaultConfiguration) {
            skc_defaultConfiguration = [[HETSkinAnalysisConfiguration alloc]init];
        }
        configuration = skc_defaultConfiguration;
    }
    return configuration;
}

+ (void)resetConfigurationState {
    @synchronized(skc_defaultConfiFileName) {
        skc_defaultConfiguration = nil;
    }
}


- (instancetype)copyWithZone:(NSZone *)zone
{
    HETSkinAnalysisConfiguration *configuration = [[[self class] allocWithZone:zone] init];
    configuration.voiceConfig = self.voiceConfig;
    configuration.videoConfig = self.videoConfig;
    configuration.faceDetectionEngine = self.faceDetectionEngine;
    configuration.faceDetectionBounds = self.faceDetectionBounds;
    configuration.cameraDetectionBounds = self.cameraDetectionBounds;
    configuration.playVoiceEnable = self.playVoiceEnable;
    configuration.captureDevicePosition = self.captureDevicePosition;
    configuration.appId = self.appId;
    configuration.appSecret = self.appSecret;
    configuration.accessToken = self.accessToken;
    configuration.jsonToModelBlock = self.jsonToModelBlock;
    configuration.modelToJSONBlock = self.modelToJSONBlock;
    configuration.faceBoundsDetectionEnable = self.faceBoundsDetectionEnable;
    configuration.yuvLightDetectionEnable = self.yuvLightDetectionEnable;
    configuration.distanceDetectionEnable = self.distanceDetectionEnable;
    configuration.standardFaceCheckEnable = self.standardFaceCheckEnable;
    configuration.maxDetectionDistance = self.maxDetectionDistance;
    configuration.minDetectionDistance = self.minDetectionDistance;
    configuration.maxYUVLight = self.maxYUVLight;
    configuration.minYUVLight = self.minYUVLight;
    return configuration;
}
@end
