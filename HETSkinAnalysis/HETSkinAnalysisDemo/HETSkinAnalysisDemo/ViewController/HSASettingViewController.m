//
//  HSASettingViewController.m
//  HETSkinAnalysisDemo
//
//  Created by 远征 马 on 2019/9/23.
//  Copyright © 2019 马远征. All rights reserved.
//

#import "HSASettingViewController.h"
#import "HETSkinAnalysisConfig.h"
#import <Masonry.h>
#import <YYKit.h>
#import <QMUIKit.h>
#import "RLMRealm+RLMDB.h"

@interface HSASettingViewController ()
@property (nonatomic, strong) UISwitch *faceBoundsDetectSwitch;
@property (nonatomic, strong) UISwitch *yuvLightDetectSwitch;
@property (nonatomic, strong) UISwitch *distanceDetectSwitch;
@property (nonatomic, strong) UISwitch *standardFaceCheckSwitch;
@property (nonatomic, strong) QMUISlider *maxDistanceSlider;
@property (nonatomic, strong) QMUISlider *minDistanceSlider;
@property (nonatomic, strong) QMUISlider *maxYUVLightSlider;
@property (nonatomic, strong) QMUISlider *minYUVLightSlider;
@property (nonatomic, strong) QMUISlider *faceDetectionBoundsInsetDxSlider;
@property (nonatomic, strong) QMUISlider *faceDetectionBoundsInsetDySlider;
@property (nonatomic, strong) UILabel *maxDetectionDistanceLabel;
@property (nonatomic, strong) UILabel *minDetectionDistanceLabel;
@property (nonatomic, strong) UILabel *maxYUVLightLabel;
@property (nonatomic, strong) UILabel *minYUVLightLabel;
@property (nonatomic, strong) UILabel *insetDxLabel;
@property (nonatomic, strong) UILabel *insetDyLabel;
@end

@implementation HSASettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.titleView.title = @"设置";
    [self makeConstraints];
}

- (void)faceBoundsDetectSwitchValueChanged:(UISwitch*)sender
{
    HETSkinAnalysisConfig *config = [[HETSkinAnalysisConfig allObjects]firstObject];
    [RLMRealm rlmTransactionWithBlock:^(RLMRealm *defaultRealm) {
        if (config) {
            config.faceBoundsDetectionEnable = sender.isOn;
        }
    }];
}

- (void)yuvLightDetectSwitchValueChanged:(UISwitch*)sender
{
    HETSkinAnalysisConfig *config = [[HETSkinAnalysisConfig allObjects]firstObject];
    [RLMRealm rlmTransactionWithBlock:^(RLMRealm *defaultRealm) {
        if (config) {
            config.yuvLightDetectionEnable = sender.isOn;
        }
    }];
}

- (void)distanceDetectSwitchValueChanged:(UISwitch*)sender
{
    HETSkinAnalysisConfig *config = [[HETSkinAnalysisConfig allObjects]firstObject];
    [RLMRealm rlmTransactionWithBlock:^(RLMRealm *defaultRealm) {
        if (config) {
            config.distanceDetectionEnable = sender.isOn;
        }
    }];
}

- (void)standardFaceCheckSwitchValueChanged:(UISwitch*)sender
{
    HETSkinAnalysisConfig *config = [[HETSkinAnalysisConfig allObjects]firstObject];
    [RLMRealm rlmTransactionWithBlock:^(RLMRealm *defaultRealm) {
        if (config) {
            config.standardFaceCheckEnable = sender.isOn;
        }
    }];
}

- (void)makeConstraints
{
    HETSkinAnalysisConfig *config = [[HETSkinAnalysisConfig allObjects]firstObject];
    @weakify(self);
    UILabel *faceBoundsDetectLabel = [[UILabel alloc]init];
    faceBoundsDetectLabel.font = [UIFont systemFontOfSize:16];
    faceBoundsDetectLabel.textColor = [UIColor qmui_colorWithHexString:@"#333333"];
    faceBoundsDetectLabel.text = @"人脸边界检测";
    [self.view addSubview:faceBoundsDetectLabel];
    [faceBoundsDetectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.mas_topLayoutGuide).offset(40);
        make.left.equalTo(self.view).offset(10);
    }];
    
    _faceBoundsDetectSwitch = [[UISwitch alloc]init];
    _faceBoundsDetectSwitch.on = config.faceBoundsDetectionEnable;
    [_faceBoundsDetectSwitch addTarget:self action:@selector(faceBoundsDetectSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_faceBoundsDetectSwitch];
    [_faceBoundsDetectSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(faceBoundsDetectLabel.mas_centerY);
        make.left.equalTo(faceBoundsDetectLabel.mas_right).offset(10);
    }];
    
    UILabel *yuvLightDetectLabel = [[UILabel alloc]init];
    yuvLightDetectLabel.font = [UIFont systemFontOfSize:16];
    yuvLightDetectLabel.textColor = [UIColor qmui_colorWithHexString:@"#333333"];
    yuvLightDetectLabel.text = @"YUV亮度检测";
    [self.view addSubview:yuvLightDetectLabel];
    [yuvLightDetectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(faceBoundsDetectLabel.mas_bottom).offset(20);
        make.left.equalTo(self.view).offset(10);
    }];
    
    _yuvLightDetectSwitch = [[UISwitch alloc]init];
    _yuvLightDetectSwitch.on = config.yuvLightDetectionEnable;
    [_yuvLightDetectSwitch addTarget:self action:@selector(yuvLightDetectSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_yuvLightDetectSwitch];
    [_yuvLightDetectSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(yuvLightDetectLabel.mas_centerY);
        make.left.equalTo(yuvLightDetectLabel.mas_right).offset(10);
    }];
    
    UILabel *distanceDetectLabel = [[UILabel alloc]init];
    distanceDetectLabel.font = [UIFont systemFontOfSize:16];
    distanceDetectLabel.textColor = [UIColor qmui_colorWithHexString:@"#333333"];
    distanceDetectLabel.text = @"人脸距离检测";
    [self.view addSubview:distanceDetectLabel];
    [distanceDetectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(yuvLightDetectLabel.mas_bottom).offset(20);
        make.left.equalTo(self.view).offset(10);
    }];
    
    _distanceDetectSwitch = [[UISwitch alloc]init];
    _distanceDetectSwitch.on = config.distanceDetectionEnable;
    [_distanceDetectSwitch addTarget:self action:@selector(distanceDetectSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_distanceDetectSwitch];
    [_distanceDetectSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(distanceDetectLabel.mas_centerY);
        make.left.equalTo(distanceDetectLabel.mas_right).offset(10);
    }];
    
    UILabel *standardFaceCheckLabel = [[UILabel alloc]init];
    standardFaceCheckLabel.font = [UIFont systemFontOfSize:16];
    standardFaceCheckLabel.textColor = [UIColor qmui_colorWithHexString:@"#333333"];
    standardFaceCheckLabel.text = @"标准人脸检测";
    [self.view addSubview:standardFaceCheckLabel];
    [standardFaceCheckLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(distanceDetectLabel.mas_bottom).offset(20);
        make.left.equalTo(self.view).offset(10);
    }];
    
    _standardFaceCheckSwitch = [[UISwitch alloc]init];
    _standardFaceCheckSwitch.on = config.standardFaceCheckEnable;
    [_standardFaceCheckSwitch addTarget:self action:@selector(standardFaceCheckSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_standardFaceCheckSwitch];
    [_standardFaceCheckSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(standardFaceCheckLabel.mas_centerY);
        make.left.equalTo(standardFaceCheckLabel.mas_right).offset(10);
    }];
    
    _maxDetectionDistanceLabel = [[UILabel alloc]init];
    _maxDetectionDistanceLabel.font = [UIFont systemFontOfSize:16];
    _maxDetectionDistanceLabel.textColor = [UIColor qmui_colorWithHexString:@"#333333"];
    _maxDetectionDistanceLabel.text = [NSString stringWithFormat:@"最大检测距离 %.2f",config.maxDetectionDistance];;
    [self.view addSubview:_maxDetectionDistanceLabel];
    [_maxDetectionDistanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(standardFaceCheckLabel.mas_bottom).offset(20);
        make.left.equalTo(self.view).offset(10);
    }];
    _maxDistanceSlider = [[QMUISlider alloc]init];
    _maxDistanceSlider.thumbSize = CGSizeMake(20, 20);
    _maxDistanceSlider.maximumValue = 100.0;
    _maxDistanceSlider.minimumValue = 85.0;
    _maxDistanceSlider.value = config.maxDetectionDistance*100;
    [_maxDistanceSlider addTarget:self action:@selector(maxDistanceSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_maxDistanceSlider];
    [_maxDistanceSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerY.equalTo(self.maxDetectionDistanceLabel.mas_centerY);
        make.left.equalTo(self.maxDetectionDistanceLabel.mas_right).offset(10);
        make.right.equalTo(self.view).offset(-10);
    }];
    
    _minDetectionDistanceLabel = [[UILabel alloc]init];
    _minDetectionDistanceLabel.font = [UIFont systemFontOfSize:16];
    _minDetectionDistanceLabel.textColor = [UIColor qmui_colorWithHexString:@"#333333"];
    _minDetectionDistanceLabel.text = [NSString stringWithFormat:@"最小检测距离 %.2f",config.minDetectionDistance];;
    [self.view addSubview:_minDetectionDistanceLabel];
    [_minDetectionDistanceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.maxDetectionDistanceLabel.mas_bottom).offset(20);
        make.left.equalTo(self.view).offset(10);
    }];
    _minDistanceSlider = [[QMUISlider alloc]init];
    _minDistanceSlider.thumbSize = CGSizeMake(20, 20);
    _minDistanceSlider.maximumValue = 65.0;
    _minDistanceSlider.minimumValue = 0.0;
    _minDistanceSlider.value = config.minDetectionDistance*100;
    [_minDistanceSlider addTarget:self action:@selector(minDistanceSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_minDistanceSlider];
    [_minDistanceSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerY.equalTo(self.minDetectionDistanceLabel.mas_centerY);
        make.left.equalTo(self.minDetectionDistanceLabel.mas_right).offset(10);
        make.right.equalTo(self.view).offset(-10);
    }];
    
    _maxYUVLightLabel = [[UILabel alloc]init];
    _maxYUVLightLabel.font = [UIFont systemFontOfSize:16];
    _maxYUVLightLabel.textColor = [UIColor qmui_colorWithHexString:@"#333333"];
    _maxYUVLightLabel.text = [NSString stringWithFormat:@"最大YUV亮度 %d",config.maxYUVLight];;
    [self.view addSubview:_maxYUVLightLabel];
    [_maxYUVLightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.minDetectionDistanceLabel.mas_bottom).offset(20);
        make.left.equalTo(self.view).offset(10);
    }];
    _maxYUVLightSlider = [[QMUISlider alloc]init];
    _maxYUVLightSlider.thumbSize = CGSizeMake(20, 20);
    _maxYUVLightSlider.maximumValue = 1000.0;
    _maxYUVLightSlider.minimumValue = 220.0;
    _maxYUVLightSlider.value = config.maxYUVLight;
    [_maxYUVLightSlider addTarget:self action:@selector(maxYUVLightSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_maxYUVLightSlider];
    [_maxYUVLightSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerY.equalTo(self.maxYUVLightLabel.mas_centerY);
        make.left.equalTo(self.maxYUVLightLabel.mas_right).offset(10);
        make.right.equalTo(self.view).offset(-10);
    }];
    
    _minYUVLightLabel = [[UILabel alloc]init];
    _minYUVLightLabel.font = [UIFont systemFontOfSize:16];
    _minYUVLightLabel.textColor = [UIColor qmui_colorWithHexString:@"#333333"];
    _minYUVLightLabel.text = [NSString stringWithFormat:@"最小YUV亮度 %d",config.minYUVLight];;
    [self.view addSubview:_minYUVLightLabel];
    [_minYUVLightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.maxYUVLightLabel.mas_bottom).offset(20);
        make.left.equalTo(self.view).offset(10);
    }];
    _minYUVLightSlider = [[QMUISlider alloc]init];
    _minYUVLightSlider.thumbSize = CGSizeMake(20, 20);
    _minYUVLightSlider.maximumValue = 80.0;
    _minYUVLightSlider.minimumValue = 0.0;
    _minYUVLightSlider.value = config.minYUVLight;
    [_minYUVLightSlider addTarget:self action:@selector(minYUVLightSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_minYUVLightSlider];
    [_minYUVLightSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerY.equalTo(self.minYUVLightLabel.mas_centerY);
        make.left.equalTo(self.minYUVLightLabel.mas_right).offset(10);
        make.right.equalTo(self.view).offset(-10);
    }];
    
    _insetDxLabel = [[UILabel alloc]init];
    _insetDxLabel.font = [UIFont systemFontOfSize:16];
    _insetDxLabel.textColor = [UIColor qmui_colorWithHexString:@"#333333"];
    _insetDxLabel.text = [NSString stringWithFormat:@"人脸检测框左右边界值 %.2f",config.faceDetectionBoundsInsetDx];
    [self.view addSubview:_insetDxLabel];
    [_insetDxLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.minYUVLightLabel.mas_bottom).offset(20);
        make.left.equalTo(self.view).offset(10);
    }];
    _faceDetectionBoundsInsetDxSlider = [[QMUISlider alloc]init];
    _faceDetectionBoundsInsetDxSlider.thumbSize = CGSizeMake(20, 20);
    _faceDetectionBoundsInsetDxSlider.maximumValue = 100.0;
    _faceDetectionBoundsInsetDxSlider.minimumValue = 0.0;
    _faceDetectionBoundsInsetDxSlider.value = config.faceDetectionBoundsInsetDx;
    [_faceDetectionBoundsInsetDxSlider addTarget:self action:@selector(faceDetectionBoundsInsetDxSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_faceDetectionBoundsInsetDxSlider];
    [_faceDetectionBoundsInsetDxSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerY.equalTo(self.insetDxLabel.mas_centerY);
        make.left.equalTo(self.insetDxLabel.mas_right).offset(10);
        make.right.equalTo(self.view).offset(-10);
    }];
    
    _insetDyLabel = [[UILabel alloc]init];
    _insetDyLabel.font = [UIFont systemFontOfSize:16];
    _insetDyLabel.textColor = [UIColor qmui_colorWithHexString:@"#333333"];
    _insetDyLabel.text = [NSString stringWithFormat:@"人脸检测框上下边界值 %.2f",config.faceDetectionBoundsInsetDy];
    [self.view addSubview:_insetDyLabel];
    [_insetDyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.insetDxLabel.mas_bottom).offset(20);
        make.left.equalTo(self.view).offset(10);
    }];
    _faceDetectionBoundsInsetDySlider = [[QMUISlider alloc]init];
    _faceDetectionBoundsInsetDySlider.thumbSize = CGSizeMake(20, 20);
    _faceDetectionBoundsInsetDySlider.maximumValue = 100.0;
    _faceDetectionBoundsInsetDySlider.minimumValue = 0.0;
    _faceDetectionBoundsInsetDySlider.value = config.faceDetectionBoundsInsetDy;
    [_faceDetectionBoundsInsetDySlider addTarget:self action:@selector(faceDetectionBoundsInsetDySliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_faceDetectionBoundsInsetDySlider];
    [_faceDetectionBoundsInsetDySlider mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerY.equalTo(self.insetDyLabel.mas_centerY);
        make.left.equalTo(self.insetDyLabel.mas_right).offset(10);
        make.right.equalTo(self.view).offset(-10);
    }];
}

- (void)maxDistanceSliderValueChanged:(UISlider*)sender
{
    self.maxDetectionDistanceLabel.text = [NSString stringWithFormat:@"最大检测距离 %.2f",sender.value/100.0];
    HETSkinAnalysisConfig *config = [[HETSkinAnalysisConfig allObjects]firstObject];
    [RLMRealm rlmTransactionWithBlock:^(RLMRealm *defaultRealm) {
        if (config) {
            config.maxDetectionDistance = sender.value/100.0;
        }
    }];
}

- (void)minDistanceSliderValueChanged:(UISlider*)sender
{
    self.minDetectionDistanceLabel.text = [NSString stringWithFormat:@"最小检测距离 %.2f",sender.value/100.0];
    HETSkinAnalysisConfig *config = [[HETSkinAnalysisConfig allObjects]firstObject];
    [RLMRealm rlmTransactionWithBlock:^(RLMRealm *defaultRealm) {
        if (config) {
            config.minDetectionDistance = sender.value/100.0;
        }
    }];
}

- (void)maxYUVLightSliderValueChanged:(UISlider*)sender
{
    self.maxYUVLightLabel.text = [NSString stringWithFormat:@"最大YUV亮度 %d",(int)sender.value];
    HETSkinAnalysisConfig *config = [[HETSkinAnalysisConfig allObjects]firstObject];
    [RLMRealm rlmTransactionWithBlock:^(RLMRealm *defaultRealm) {
        if (config) {
            config.maxYUVLight = (int)sender.value;
        }
    }];
}

- (void)minYUVLightSliderValueChanged:(UISlider*)sender
{
    self.minYUVLightLabel.text = [NSString stringWithFormat:@"最小YUV亮度 %d",(int)sender.value];
    HETSkinAnalysisConfig *config = [[HETSkinAnalysisConfig allObjects]firstObject];
    [RLMRealm rlmTransactionWithBlock:^(RLMRealm *defaultRealm) {
        if (config) {
            config.minYUVLight = (int)sender.value;
        }
    }];
}

- (void)faceDetectionBoundsInsetDxSliderValueChanged:(UISlider*)sender
{
    self.insetDxLabel.text = [NSString stringWithFormat:@"人脸检测框左右边界值 %.2f",sender.value];
    HETSkinAnalysisConfig *config = [[HETSkinAnalysisConfig allObjects]firstObject];
    [RLMRealm rlmTransactionWithBlock:^(RLMRealm *defaultRealm) {
        if (config) {
            config.faceDetectionBoundsInsetDx = sender.value;
        }
    }];
}

- (void)faceDetectionBoundsInsetDySliderValueChanged:(UISlider*)sender
{
    self.insetDyLabel.text = [NSString stringWithFormat:@"人脸检测框上下边界值 %.2f",sender.value];
    HETSkinAnalysisConfig *config = [[HETSkinAnalysisConfig allObjects]firstObject];
    [RLMRealm rlmTransactionWithBlock:^(RLMRealm *defaultRealm) {
        if (config) {
            config.faceDetectionBoundsInsetDy = sender.value;
        }
    }];
}

@end
