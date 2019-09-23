//
//  HETSkinAnalysisCaptureDevice.m
//  HETSkinAnalysis
//
//  Created by 远征 马 on 2019/7/1.
//  Copyright © 2019 马远征. All rights reserved.
//

#import "HETSkinAnalysisCaptureDevice.h"
#import "AVCaptureDevice+HETSkinAnalysis.h"
#import "UIImage+HETSkinAnalysis.h"
#import "HETSkinAnalysisDefine.h"
#import "HETSkinAnalysisDefinePrivate.h"
#import "HETSkinAnalysisConfiguration+HETPrivate.h"
#import "HETSkinAnalysisPlayer.h"

static dispatch_queue_t HETCapture_device_session_queue() {
    static dispatch_queue_t capture_device_session_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        capture_device_session_queue = dispatch_queue_create("com.SkinAnalysis.videoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    });
    return capture_device_session_queue;
}

@interface HETSkinAnalysisCaptureDevice() <AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDevice *captureDevice;
@property (nonatomic, strong) AVCaptureDeviceInput *captureDeviceInput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *captureVideoDataOutput;
@property (nonatomic, strong) AVCaptureStillImageOutput *captureStillImageOutput;
@property (nonatomic, strong) AVCaptureConnection *captureConnection;
@property (nonatomic, strong) AVCaptureConnection *videoConnection;
@property (nonatomic, strong) HETSkinAnalysisPlayer *voicePlayer;
@end

@implementation HETSkinAnalysisCaptureDevice
@synthesize captureVideoPreviewLayer = _captureVideoPreviewLayer;
@synthesize capturingStillImage = _capturingStillImage;

- (BOOL)isCapturingStillImage
{
    return _capturingStillImage = self.captureStillImageOutput.capturingStillImage;
}

- (void)setCapturingStillImage:(BOOL)capturingStillImage
{
    _capturingStillImage = capturingStillImage;
}

- (BOOL)prepareCaptureDevice:(NSError *__autoreleasing *)error
{
    self.isCaptureDevicePrepared = NO;
    // 使用默认摄像头的方向
    HETSkinAnalysisConfiguration *config = [HETSkinAnalysisConfiguration rawDefaultConfiguration];
    AVCaptureDevicePosition devicePosition = config.captureDevicePosition;
    if (devicePosition != AVCaptureDevicePositionBack) {
        devicePosition = AVCaptureDevicePositionFront;
    }
    _captureDevice = [AVCaptureDevice hetGetCaptureDeviceWithPosition:devicePosition];
    if (!_captureDevice)
    {
        // 如果获取指定的摄像头方向出错，则调取另外一个摄像头
        devicePosition = (devicePosition == AVCaptureDevicePositionBack ? AVCaptureDevicePositionFront :AVCaptureDevicePositionBack);
        _captureDevice = [AVCaptureDevice hetGetCaptureDeviceWithPosition:devicePosition];
        if (!_captureDevice)
        {
            NSLog(@"---AVCaptureDevice设备获取出错---");
            *error = [NSError errorWithDomain:HETCaptureDeviceErrorDomain
                                         code:HETSkinAnalysisErrorCodeNoCaptureDeviceFound
                                     userInfo:@{NSLocalizedDescriptionKey:@"获取capture device 出错"}];
            return NO;
        }
    }
    [config setDefaultCaptureDevicePosition:devicePosition];
    NSError *aError;
    //根据输入设备初始化设备输入对象，用于获得输入数据
    _captureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:_captureDevice error:&aError];
    if (!_captureDeviceInput) {
        NSLog(@"--AVCaptureDeviceInput 初始化错误----%@",aError);
        *error = aError;
        return NO;
    }
    [self.captureSession beginConfiguration];
    if ([self.captureSession canAddInput:_captureDeviceInput]) {
        [self.captureSession addInput:_captureDeviceInput];
    }
    if ([self.captureSession canAddOutput:self.captureVideoDataOutput]) {
        [self.captureSession addOutput:self.captureVideoDataOutput];
    }
    
    // 添加输出设备
    if ([self.captureSession canAddOutput:self.captureStillImageOutput]) {
        [self.captureSession addOutput:self.captureStillImageOutput];
    }
    
    [self updateVideoConnection];
    
    id <HETCaptureDeviceConfigDelegate> captureDeviceConfig = [config getCaptureDeviceConfig];
    AVCaptureSessionPreset sessionPreset = [captureDeviceConfig getCaptureSessionPreset];
    if ([self.captureSession canSetSessionPreset:sessionPreset]) {
        self.captureSession.sessionPreset = sessionPreset;
    }
    [self.captureSession commitConfiguration];
    self.isCaptureDevicePrepared = YES;
    return YES;
}

- (void)updateVideoConnection
{
    _videoConnection = [_captureVideoDataOutput connectionWithMediaType:AVMediaTypeVideo];
    if (_videoConnection.supportsVideoMirroring) {
        BOOL isVideoMirrored = ([self getCaptureDevicePosition] == AVCaptureDevicePositionFront);
        _videoConnection.videoMirrored = isVideoMirrored;
    }
    if ([_videoConnection isVideoOrientationSupported]) {
        UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
        AVCaptureVideoOrientation videoOrientation = (AVCaptureVideoOrientation)curDeviceOrientation;
        if ( videoOrientation == UIDeviceOrientationLandscapeLeft ) {
            videoOrientation = AVCaptureVideoOrientationLandscapeRight;
        }
        else if ( videoOrientation == UIDeviceOrientationLandscapeRight ) {
            videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
        }
        [_videoConnection setVideoOrientation:videoOrientation];
    }
}

- (AVCaptureDevicePosition)swicthCamera
{
    NSUInteger cameraCount = [AVCaptureDevice hetGetCameraCount];
    if (cameraCount <= 1) {
        return NO;
    }
    if (!self.captureSession.isRunning) {
        [self.captureSession startRunning];
    }
    AVCaptureDevice *newCamera = nil;
    AVCaptureDeviceInput *newInput = nil;
    AVCaptureDevicePosition position = self.captureDeviceInput.device.position;
    if (position != AVCaptureDevicePositionBack)
    {
        newCamera = [AVCaptureDevice hetGetCaptureDeviceWithPosition:AVCaptureDevicePositionBack];
    }
    else {
        newCamera = [AVCaptureDevice hetGetCaptureDeviceWithPosition:AVCaptureDevicePositionFront];
    }
    NSError *error;
    newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:&error];
    // beginConfiguration ensures that pending changes are not applied immediately
    if (!newInput) {
        NSLog(@"---error---%@",error);
        return position;
    }
    [self.captureSession beginConfiguration];
    [self.captureSession removeInput:self.captureDeviceInput];
    if ([self.captureSession canAddInput:newInput]) {
        [self.captureSession addInput:newInput];
        self.captureDeviceInput = newInput;
        [self updateVideoConnection];
    }
    else
    {
        [self.captureSession addInput:self.captureDeviceInput];
    }
    [self.captureSession commitConfiguration];
    position = self.captureDeviceInput.device.position;
    HETSkinAnalysisConfiguration *config = [HETSkinAnalysisConfiguration rawDefaultConfiguration];
    [config setDefaultCaptureDevicePosition:position];
    return position;
}

- (AVCaptureDevicePosition)getCaptureDevicePosition
{
    if (_captureDevice) {
        return _captureDevice.position;
    }
    return AVCaptureDevicePositionUnspecified;
}

#pragma mark - 拍摄静态照片

- (AVCaptureConnection*)videoConnection
{
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.captureStillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                if (videoConnection.supportsVideoMirroring) {
                    BOOL isVideoMirrored = ([self getCaptureDevicePosition] == AVCaptureDevicePositionFront);
                    videoConnection.videoMirrored = isVideoMirrored;
                }
                if ([videoConnection isVideoOrientationSupported]) {
                    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
                    AVCaptureVideoOrientation videoOrientation = (AVCaptureVideoOrientation)curDeviceOrientation;
                    if ( videoOrientation == UIDeviceOrientationLandscapeLeft ) {
                        videoOrientation = AVCaptureVideoOrientationLandscapeRight;
                    }
                    else if ( videoOrientation == UIDeviceOrientationLandscapeRight ) {
                        videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
                    }
                    [videoConnection setVideoOrientation:videoOrientation];
                }
                break;
            }
        }
    }
    return videoConnection;
}

- (void)captureStillImageAsynchronously:(BOOL)autoFixImage result:(void(^)(UIImage *image, NSError *error))retHandler
{
    if (self.captureStillImageOutput.isCapturingStillImage) {
        NSLog(@"---正在拍摄照片---");
        return ;
    }
    HETSkinAnalysisConfiguration *config = [HETSkinAnalysisConfiguration rawDefaultConfiguration];
    AVCaptureConnection *videoConnection = [self videoConnection];
    if (!videoConnection) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"captureConnection获取失败，无法完成拍照"};
        NSError *error = [NSError errorWithDomain:HETCaptureDeviceErrorDomain
                                             code:HETSkinAnalysisErrorCodeMissingParameters
                                         userInfo:userInfo];
        het_dispatch_async_main(^{
            if (retHandler) {
                retHandler(nil, error);
            }
        });
        return;
    }
    
    id<HETSkinAnalysisVoiceDelegate> voiceConfig = [config getVoiceConfig];
    if (config.playVoiceEnable) {
        // 暂停人脸识别播放器播放
        [[HETSkinAnalysisPlayer defaultPlayer]pause];
        // 启用新的播放器播放语音
        NSString *voiceFile = [voiceConfig getPhotoShutterVoice];
        if (!_voicePlayer) {
            _voicePlayer = [[HETSkinAnalysisPlayer alloc]init];
        }
        @hetWeakify(self);
        [_voicePlayer playVoice:voiceFile shouldDelay:NO result:^(BOOL flag, NSError *error) {
            @hetStrongify(self);
            [self captureStillImage:autoFixImage fromConnection:videoConnection result:retHandler];
        }];
    }
    else
    {
        [self captureStillImage:autoFixImage fromConnection:videoConnection result:retHandler];
    }
}

- (void)captureStillImage:(BOOL)autoFixImage fromConnection:(AVCaptureConnection *)videoConnection result:(void(^)(UIImage *image, NSError *error))retHandler
{
    @hetWeakify(self);
    [self.captureStillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef  _Nullable imageDataSampleBuffer, NSError * _Nullable error) {
        @hetStrongify(self);
        if (imageDataSampleBuffer)
        {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image = [UIImage imageWithData:imageData];
            image = [image hetFixedOrientationImage];
            if (autoFixImage) {
                // 缩放到指定的尺寸
                CGSize imageSize = image.size;
                if (imageSize.width * imageSize.height > 5000000)
                {
                    CGSize scaleSize = CGSizeMake(2000, 2500);
                    scaleSize.height = imageSize.height*(scaleSize.width/imageSize.width);
                    image = [image hetResizeImageToSize:scaleSize];
                }
                
                // 前置摄像头的时候要转成镜像图片
                if ([self getCaptureDevicePosition] == AVCaptureDevicePositionFront) {
                    image = [image hetFixeImage];
                }
            }
            HETSkinAnalysisConfiguration *config = [HETSkinAnalysisConfiguration rawDefaultConfiguration];
            id<HETSkinAnalysisVoiceDelegate> voiceConfig = [config getVoiceConfig];
            if (config.playVoiceEnable)
            {
                NSString *takePhotoSuccessVoice = [voiceConfig getTakePhotoSuccessVoice];
                [self.voicePlayer playVoice:takePhotoSuccessVoice shouldDelay:NO result:^(BOOL flag, NSError *error) {
                    het_dispatch_async_main(^{
                        if (retHandler) {
                            retHandler(image, nil);
                        }
                    });
                }];
            }
            else
            {
                het_dispatch_async_main(^{
                    if (retHandler) {
                        retHandler(image, nil);
                    }
                });
            }
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


#pragma mark - running

- (void)startRuning
{
    if (_captureSession && !_captureSession.isRunning) {
        [_captureSession startRunning];
        [[HETSkinAnalysisPlayer defaultPlayer]resume];
    }
}

- (void)stopRuning
{
    if (_captureSession && _captureSession.isRunning) {
        [_captureSession stopRunning];
        [[HETSkinAnalysisPlayer defaultPlayer]pause];
    }
}

#pragma mark - clear

- (void)clearCaptureDevice
{
    if (_captureSession && _captureSession.isRunning) {
        [_captureSession stopRunning];
    }
    _captureSession = nil;
    [_captureVideoPreviewLayer removeFromSuperlayer];
    _captureVideoDataOutput = nil;
    _captureStillImageOutput = nil;
    _captureDeviceInput = nil;
    self.isCaptureDevicePrepared = NO;
    HETSkinAnalysisConfiguration *config = [HETSkinAnalysisConfiguration rawDefaultConfiguration];
    config.isTakeingPhotos = NO;
}



#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if (connection != _videoConnection) {
        return;
    }
    // 输出视频帧buffer
    if (self.captureSampleBufferOutputBlock) {
        self.captureSampleBufferOutputBlock(output, sampleBuffer, connection);
    }
}



#pragma mark - AVCapture

- (AVCaptureVideoPreviewLayer*)captureVideoPreviewLayer
{
    if (_captureVideoPreviewLayer) {
        return _captureVideoPreviewLayer;
    }
    _captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    return _captureVideoPreviewLayer;
}

- (AVCaptureSession*)captureSession
{
    if (_captureSession) {
        return _captureSession;
    }
    _captureSession = [[AVCaptureSession alloc]init];
    return _captureSession;
}

- (AVCaptureStillImageOutput*)captureStillImageOutput
{
    if (_captureStillImageOutput) {
        return _captureStillImageOutput;
    }
    _captureStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    _captureStillImageOutput.highResolutionStillImageOutputEnabled = YES;
    NSDictionary *outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    [_captureStillImageOutput setOutputSettings:outputSettings];
    return _captureStillImageOutput;
}

- (AVCaptureVideoDataOutput*)captureVideoDataOutput
{
    if (_captureVideoDataOutput) {
        return _captureVideoDataOutput;
    }
    _captureVideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    _captureVideoDataOutput.alwaysDiscardsLateVideoFrames = YES;
    
//    dispatch_queue_t queue = dispatch_queue_create("com.SkinAnalysis.videoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    [_captureVideoDataOutput setSampleBufferDelegate:self queue:HETCapture_device_session_queue()];
    
//    NSString *key = (NSString *)kCVPixelBufferPixelFormatTypeKey;
//    NSNumber *value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange];
//    NSDictionary *settings = @{key:value};
//    [_captureVideoDataOutput setVideoSettings:settings];
    HETSkinAnalysisConfiguration *config = [HETSkinAnalysisConfiguration rawDefaultConfiguration];
    id <HETCaptureDeviceConfigDelegate> captureDeviceConfig = [config getCaptureDeviceConfig];
//#ifdef __OUTPUT_BGRA__
//    NSDictionary *dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
//#else
//    NSDictionary *dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
//#endif
    [_captureVideoDataOutput setVideoSettings:[captureDeviceConfig getVideoSettings]];
    return _captureVideoDataOutput;
}

@end
