//
//  HSASkinCameraViewController.m
//  HETSkinAnalysisDemo
//
//  Created by 远征 马 on 2019/7/9.
//  Copyright © 2019 马远征. All rights reserved.
//

#import "HSASkinCameraViewController.h"
#import <HETSkinAnalysis/HETSkinAnalysis.h>
#import <Masonry/Masonry.h>
#import <YYKit/YYKit.h>
#import "HSAFaceFrame.h"
#import "HSAFace.h"
#import "HSACameraImageAnalysisViewController.h"
#import "HSAContant.h"
#import "HETSkinAnalysisConfig.h"

@interface HSASkinCameraViewController ()
@property (nonatomic, strong) UIView *cameraPreView;
@property (nonatomic, strong) HETSkinAnalysisCaptureDevice *captureDevice;
@property (nonatomic, strong) HETSkinAnalysisDataEngine *dataEngine;
@property (nonatomic, strong) HETSkinAnalysisFaceEngine *faceEngine;
@property (nonatomic, strong) NSMutableArray *faceViewArray;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, assign) BOOL shouldAutoTakePhotos;
@property (nonatomic, strong) HSAFace *faceView;
@end

@implementation HSASkinCameraViewController

- (void)dealloc
{
    NSLog(@"----dealloc---%s",__FUNCTION__);
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self clearDevice];
}

#pragma mark - 按钮交互

- (void)handBackButtonEvent:(id)sender
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self clearDevice];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickToSwicthCamera:(UIButton*)sender
{
    AVCaptureDevicePosition position = [self.captureDevice swicthCamera];
    sender.selected = (position == AVCaptureDevicePositionBack);
}


- (void)clickToTakePhotos:(UIButton*)sender
{
    NSLog(@"---开始拍照--");
    @weakify(self);
    [self.captureDevice captureStillImageAsynchronously:YES result:^(UIImage *image, NSError *error) {
        if (image) {
            @strongify(self);
            NSLog(@"---拍照成功--");
            [self.captureDevice stopRuning];
            NSError *aError;
            BOOL ret = [self.faceEngine isValidImageForSkinAnalysis:image error:&aError];
            if (ret) {
                // 改为静态图片识别
                ret = [self.faceEngine changeFaceDetectMode:HETFaceDetectModeImage];
                if (ret)
                {
//                    // 进入图像分析页面
                    HSACameraImageAnalysisViewController *imageAnalysis = [[HSACameraImageAnalysisViewController alloc]init];
                    imageAnalysis.cameraImage = image;
                    imageAnalysis.faceEngine = self.faceEngine;
                    [self.navigationController pushViewController:imageAnalysis animated:YES];
                }
                else
                {
                    NSLog(@"--无法修改人脸检测模式--");
                }
            }
            else
            {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:aError.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self.captureDevice startRuning];
                }]];
                [self.navigationController presentViewController:alertController animated:YES completion:^{

                }];
            }
        }
        else
        {
            NSLog(@"--拍照错误-error----%@",error);
        }
    }];
}

- (void)switchChangedToSetMute:(UISwitch*)sender
{
    [HETSkinAnalysisConfiguration setMute:sender.isOn];
}

- (void)switchChangedToOpenAutoTakePhoto:(UISwitch*)sender
{
    self.shouldAutoTakePhotos = sender.isOn;
}

#pragma mark - layout

- (void)makeConstraints
{
    @weakify(self);
    _cameraPreView = [[UIView alloc]init];
    _cameraPreView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_cameraPreView];
    [self.cameraPreView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.edges.equalTo(self.view);
    }];
    
    HETSkinAnalysisConfig *dbConfig = [[HETSkinAnalysisConfig allObjects]firstObject];
    HSAFaceFrame *faceFrameView = [[HSAFaceFrame alloc]init];
    faceFrameView.backgroundColor = [UIColor clearColor];
    [self.cameraPreView addSubview:faceFrameView];
    CGRect rect = CGRectInset(UIScreen.mainScreen.bounds,
                              dbConfig.faceDetectionBoundsInsetDx,
                              dbConfig.faceDetectionBoundsInsetDy);
    [faceFrameView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.cameraPreView).offset(rect.origin.x);
        make.top.equalTo(self.cameraPreView).offset(rect.origin.y);
        make.width.equalTo(@(rect.size.width));
        make.height.equalTo(@(rect.size.height));
    }];
    
    _faceView = [[HSAFace alloc]init];
    [self.cameraPreView addSubview:_faceView];
    [_faceView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.edges.equalTo(self.cameraPreView);
    }];
    
    _textView = [[UITextView alloc]init];
    _textView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
    _textView.font = [UIFont systemFontOfSize:16];
    _textView.textColor = [UIColor redColor];
    _textView.editable = NO;
    [self.view addSubview:_textView];
    [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.mas_topLayoutGuide);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    UILabel *muteLabel = [[UILabel alloc]init];
    muteLabel.textColor = [UIColor redColor];
    muteLabel.text = @"静音开关";
    [self.view addSubview:muteLabel];
    [muteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.view).offset(20);
        make.bottom.equalTo(self.view.mas_bottom).offset(-160);
        make.height.equalTo(@(20));
    }];
    
    UISwitch *muteSwitch = [[UISwitch alloc]init];
    muteSwitch.onTintColor = [UIColor orangeColor];
    [muteSwitch addTarget:self action:@selector(switchChangedToSetMute:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:muteSwitch];
    [muteSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
//        @strongify(self);
        make.left.equalTo(muteLabel.mas_right).offset(5);
        make.centerY.equalTo(muteLabel.mas_centerY);
    }];
    
    UILabel *autoTakePhotoLabel = [[UILabel alloc]init];
    autoTakePhotoLabel.textColor = [UIColor redColor];
    autoTakePhotoLabel.text = @"自动拍照";
    [self.view addSubview:autoTakePhotoLabel];
    [autoTakePhotoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.view).offset(20);
        make.top.equalTo(muteLabel.mas_bottom).offset(10);
        make.height.equalTo(@(20));
    }];
    
    UISwitch *autoTakePhotoSwitch = [[UISwitch alloc]init];
    autoTakePhotoSwitch.onTintColor = [UIColor orangeColor];
    [autoTakePhotoSwitch addTarget:self action:@selector(switchChangedToOpenAutoTakePhoto:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:autoTakePhotoSwitch];
    [autoTakePhotoSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(autoTakePhotoLabel.mas_right).offset(5);
        make.centerY.equalTo(autoTakePhotoLabel.mas_centerY);
    }];
    
    QMUIFillButton *switchButton = [[QMUIFillButton alloc]init];
    switchButton.titleTextColor = [UIColor whiteColor];
    switchButton.fillColor = [UIColor redColor];
    [switchButton setTitle:@"后置摄像头" forState:UIControlStateNormal];
    [switchButton setTitle:@"前置摄像头" forState:UIControlStateSelected];
    AVCaptureDevicePosition position = [HETSkinAnalysisConfiguration getDefaultCaptureDevicePosition];
    switchButton.selected = (position == AVCaptureDevicePositionBack);
    [switchButton addTarget:self action:@selector(clickToSwicthCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:switchButton];
    [switchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-20);
        make.bottom.equalTo(self.view).offset(-34);
        make.width.equalTo(@(120));
        make.height.equalTo(@(40));
    }];
    
    QMUIFillButton *snapButton = [[QMUIFillButton alloc]init];
    snapButton.titleTextColor = [UIColor whiteColor];
    snapButton.fillColor = [UIColor redColor];
    [snapButton setTitle:@"拍摄照片" forState:UIControlStateNormal];
    [snapButton addTarget:self action:@selector(clickToTakePhotos:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:snapButton];
    [snapButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.bottom.equalTo(self.view).offset(-34);
        make.width.equalTo(@(120));
        make.height.equalTo(@(40));
    }];
    
    [UIView performWithoutAnimation:^{
        [self.view layoutIfNeeded];
    }];
}



#pragma mark - life cycle

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    // 调整相机的frame
    if (self.captureDevice && self.captureDevice.isCaptureDevicePrepared) {
        self.captureDevice.captureVideoPreviewLayer.frame = self.cameraPreView.bounds;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self makeConstraints];
    _faceViewArray = [[NSMutableArray alloc]init];
    [self sdkConfig];
    [self configFaceEngine];
}

- (void)sdkConfig
{
    HETSkinAnalysisConfig *dbConfig = [[HETSkinAnalysisConfig allObjects]firstObject];
    
    // 设置非静音，如果设置了静音，人脸识别将停止语音播报
        [HETSkinAnalysisConfiguration setMute:NO];
        
        // 正式环境
        NSString *appId = @"31374";
        NSString *appSecret = @"705955fd634147d58f1be9f56b76e43f";
        // 玫琳凯项目
    //    NSString *appId = @"31377";
    //    NSString *appSecret = @"abbdbfa1ce8d43d9a6f9aad1ef596b8d";
        // 预发布环境
    //    NSString *appId = @"31298";
    //    NSString *appSecret = @"145a2540f00147e89dc5e33b6842f74c";
        // 初始化自定义配置
        HETSkinAnalysisConfiguration *config = [HETSkinAnalysisConfiguration defaultConfiguration];
        [config registerWithAppId:appId andSecret:appSecret];
        // 设置一个人脸识别引擎，如不设置将使用默认引擎
        [config setFaceDetectionEngine:HETFaceDetectionEngineDefault];
        // 设置初始化调用摄像头的位置
        [config setDefaultCaptureDevicePosition:AVCaptureDevicePositionFront];
        // 设置检测距离阈值
        [config setMaxDetectionDistance:dbConfig.maxDetectionDistance];
        [config setMinDetectionDistance:dbConfig.minDetectionDistance];
        // 设置亮度检测阈值
        [config setMinYUVLight:dbConfig.minYUVLight];
        [config setMaxYUVLight:dbConfig.maxYUVLight];
        // 设置侦测项
        [config setFaceBoundsDetectionEnable:dbConfig.faceBoundsDetectionEnable];
        [config setStandardFaceCheckEnable:dbConfig.standardFaceCheckEnable];
        [config setYuvLightDetectionEnable:dbConfig.yuvLightDetectionEnable];
        [config setDistanceDetectionEnable:dbConfig.distanceDetectionEnable];
        
        // 设置语音播报文件，你可以根据需要自定义语音，这里使用默认语音
        [config setCustomVoice:[[HETSkinAnalysisVoice alloc]init]];
        // 设置人脸检测边界框，你可根据自己的需要绘制合适的人脸框来限制人脸捕捉区域，如果不设置，则使用全局视频区域
        [config setFaceDetectionBounds:CGRectInset(UIScreen.mainScreen.bounds, dbConfig.faceDetectionBoundsInsetDx, dbConfig.faceDetectionBoundsInsetDy)];
        // 设置相机边界，人脸坐标转换需要参考此数值，如果不设置将无法转换人脸坐标到view窗口坐标系
        [config setCameraBounds:[UIScreen mainScreen].bounds];
        [config setJsonToModelBlock:^id(__unsafe_unretained Class aClass, id obj) {
            id model =  [aClass modelWithJSON:obj];
            return model;
        }];
        [HETSkinAnalysisConfiguration setDefaultConfiguration:config];
}
#pragma mark - engine
- (void)configFaceEngine
{
    _faceEngine = [[HETSkinAnalysisFaceEngine alloc]init];
        // 如果config的人脸侦测引擎为HETFaceDetectionEngineCustom,请优先配置自定义引擎，否则无法进行肤质分析
    //    id<HETSkinAnalysisFaceEngineDelegate> myEngine = [[MyCustomEngine alloc]init];
    //    [_faceEngine setCustomFaceEngine:myEngine];
        
        if ([_faceEngine activeEngine:HETFaceDetectModeVideo]) {
            [self initCaptureDevice];
        }
        else
        {
            NSLog(@"--人脸识别引擎无法激活--");
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"人脸识别引擎无法激活" preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popViewControllerAnimated:YES];
            }]];
            [self.navigationController presentViewController:alertController animated:YES completion:^{
                
            }];
        }
}

#pragma mark - device

- (void)initCaptureDevice
{
    // 请求相机授权
    AVAuthorizationStatus status = [AVCaptureDevice hetGetCameraAuthStatus];
    if (status != AVAuthorizationStatusAuthorized) {
        [AVCaptureDevice hetRequestAccessForCamera:^(BOOL granted) {
            if (granted) {
                [self prepareCaptureDevice];
            }
            else
            {
                // 弹框提示无法访问相机
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"无相机访问许可，请更改隐私设置允许访问相机" preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self.navigationController popViewControllerAnimated:YES];
                }]];
                [self.navigationController presentViewController:alertController animated:YES completion:^{
                    
                }];
            }
        }];
    }
    else
    {
        [self prepareCaptureDevice];
    }
}

- (void)prepareCaptureDevice
{
    NSError *error;
    _captureDevice = [[HETSkinAnalysisCaptureDevice alloc]init];
    BOOL ret = [_captureDevice prepareCaptureDevice:&error];
    if (!ret) {
        NSLog(@"---相机设备初始化失败--%@",error);
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"调用相机出错，请重试" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }]];
        [self.navigationController presentViewController:alertController animated:YES completion:^{
            
        }];
        return;
    }
    // 设置buffer流输出回调
    @weakify(self);
    [_captureDevice setCaptureSampleBufferOutputBlock:^(AVCaptureOutput *output, CMSampleBufferRef sampleBuffer, AVCaptureConnection *connection) {
        // 对buffer的视频帧进行人脸识别与相关参数检测
        @strongify(self);
        [self.faceEngine processVideoFrameBuffer:sampleBuffer faceInfoCallback:^(HETFaceAnalysisResult *analysisResult) {
            if (analysisResult) {
                self.textView.text = analysisResult.printString;
                // 绘制人脸框
                NSArray *faces = analysisResult.faces;
                [self.faceView drawFace:faces];
            }
        } result:^{
            if (self.shouldAutoTakePhotos) {
                // 正常状态可以拍照
                [self clickToTakePhotos:nil];
            }
            else
            {
                NSLog(@"---未打开自动拍照--");
            }
        }];
    }];
    // 调整相机的frame
    if (self.captureDevice && self.captureDevice.isCaptureDevicePrepared) {
        self.captureDevice.captureVideoPreviewLayer.frame = self.cameraPreView.bounds;
    }
    [self.cameraPreView.layer insertSublayer:self.captureDevice.captureVideoPreviewLayer atIndex:0]; 
    [self.captureDevice startRuning];
}

- (void)clearDevice
{
    if (self.captureDevice) {
        [self.captureDevice stopRuning];
        [self.captureDevice clearCaptureDevice];
        _cameraPreView = nil;
    }
    if (_faceEngine) {
        [_faceEngine destoryEngine];
        _faceEngine = nil;
    }
    
}



- (BOOL)preferredNavigationBarHidden
{
    return YES;
}
@end
