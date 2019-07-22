//
//  HSACameraImageAnalysisViewController.m
//  HETSkinAnalysisDemo
//
//  Created by 远征 马 on 2019/7/19.
//  Copyright © 2019 马远征. All rights reserved.
//

#import "HSACameraImageAnalysisViewController.h"
#import <HETSkinAnalysis/HETSkinAnalysis.h>
#import <Masonry/Masonry.h>
#import <YYKit/YYKit.h>
#import "HSACloudAnalysisViewController.h"
#import "HSAFace.h"


@interface HSACameraImageAnalysisViewController ()
@property (nonatomic, strong) UIView *imageContainerView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *alphaView;
@property (nonatomic, strong) UITextView *analysisResultTextView;
@property (nonatomic, strong) HSAFace *faceView;
@end

@implementation HSACameraImageAnalysisViewController


#pragma mark - 按钮交互

- (void)clickToAnalysisSkin
{
    if (!self.imageView.image) {
        return;
    }
    if (![self.faceEngine isValidEngine]) {
        return;
    }
    NSError *error;
    BOOL ret = [self.faceEngine isValidImageForSkinAnalysis:self.imageView.image error:&error];
    if (!ret) {
        NSLog(@"---error---%@",error);
        QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:@"提示" message:error.localizedDescription preferredStyle:QMUIAlertControllerStyleAlert];
        [alertController addAction:[QMUIAlertAction actionWithTitle:@"确定" style:QMUIAlertActionStyleDefault handler:^(__kindof QMUIAlertController *aAlertController, QMUIAlertAction *action) {
            
        }]];
        [alertController showWithAnimated:YES];
        return;
    }
    
    HSACloudAnalysisViewController *cloudAnalysis = [[HSACloudAnalysisViewController alloc]init];
    cloudAnalysis.image = self.imageView.image;
    [self.navigationController pushViewController:cloudAnalysis animated:YES];
}

- (void)handBackButtonEvent:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - life cycle

- (void)makeConstraints
{
    @weakify(self);
    QMUIFillButton *skinAnalysisButton = [[QMUIFillButton alloc]init];
    skinAnalysisButton.titleTextColor = [UIColor whiteColor];
    skinAnalysisButton.fillColor = [UIColor redColor];
    [skinAnalysisButton setTitle:@"肤质分析" forState:UIControlStateNormal];
    [skinAnalysisButton setTitle:@"肤质分析" forState:UIControlStateSelected];
    [skinAnalysisButton addTarget:self action:@selector(clickToAnalysisSkin) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:skinAnalysisButton];
    [skinAnalysisButton mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.mas_bottomLayoutGuide).offset(-34);
        make.width.equalTo(@(120));
        make.height.equalTo(@(40));
    }];
    
    _imageContainerView = [[UIView alloc]init];
    _imageContainerView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:_imageContainerView];
    [_imageContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.view).offset(20);
        make.bottom.equalTo(skinAnalysisButton.mas_top).offset(-20);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
    }];
    
    // 对图像对齐处理
    UIImage *alignImage = [self alignImageWidthAndHeight:self.cameraImage];
    _imageView = [[UIImageView alloc]initWithImage:alignImage];
    [self.imageContainerView addSubview:_imageView];
    
    CGSize imageSize = alignImage.size;
    if (imageSize.width > imageSize.height) {
        CGFloat multipliedByValue = imageSize.height/imageSize.width;
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            @strongify(self);
            make.left.right.equalTo(self.imageContainerView);
            make.centerY.equalTo(self.imageContainerView.mas_centerY);
            make.height.equalTo(self.imageContainerView.mas_height).multipliedBy(multipliedByValue);
        }];
    }
    else
    {
        CGFloat multipliedByValue = imageSize.width/imageSize.height;
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            @strongify(self);
            make.top.bottom.equalTo(self.imageContainerView);
            make.centerX.equalTo(self.imageContainerView.mas_centerX);
            make.width.equalTo(self.imageContainerView.mas_width).multipliedBy(multipliedByValue);
        }];
    }
    
    _faceView = [[HSAFace alloc]init];
    _faceView.drawStillImageFace = YES;
    _faceView.imageView = _imageView;
    [_imageView addSubview:_faceView];
    [_faceView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.edges.equalTo(self.imageView);
    }];
    
    
    _alphaView = [[UIView alloc]init];
    _alphaView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    [self.imageContainerView addSubview:_alphaView];
    [_alphaView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.height.equalTo(self.imageContainerView.mas_height).multipliedBy(0.5);
        make.bottom.equalTo(self.imageContainerView.mas_bottom);
        make.left.right.equalTo(self.imageContainerView);
    }];
    
    _analysisResultTextView = [[UITextView alloc]init];
    _analysisResultTextView.backgroundColor = [UIColor clearColor];
    _analysisResultTextView.font = [UIFont systemFontOfSize:16];
    _analysisResultTextView.textColor = [UIColor whiteColor];
    _analysisResultTextView.editable = NO;
    [self.alphaView addSubview:_analysisResultTextView];
    [_analysisResultTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.edges.equalTo(self.alphaView);
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleView.title = @"人脸图片分析";
    self.view.backgroundColor = [UIColor whiteColor];
    [self makeConstraints];
    if (self.faceEngine) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [QMUITips showLoading:@"人脸信息检测中" inView:window];
        [self performSelector:@selector(processFaceImage) withObject:nil afterDelay:2];
        return;
    }
    
    _faceEngine = [[HETSkinAnalysisFaceEngine alloc]init];
    if ([_faceEngine activeEngine:HETFaceDetectModeImage]) {
        NSLog(@"--人脸识别引擎初始化成功--");
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [QMUITips showLoading:@"人脸信息检测中" inView:window];
        [self performSelector:@selector(processFaceImage) withObject:nil afterDelay:2];
    }
    else
    {
        NSLog(@"--人脸识别引擎无法激活--");
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"无法激活人脸识别引擎，请返回重试" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }]];
        [self.navigationController presentViewController:alertController animated:YES completion:^{
            
        }];
    }
}

- (void)processFaceImage
{
    
    for (UIView *view in self.imageContainerView.subviews) {
        if ([view isKindOfClass:[HSAFace class]]) {
            [view removeFromSuperview];
        }
    }
    @weakify(self);
    [self.faceEngine processFaceImage:self.imageView.image result:^(HETFaceAnalysisResult *analysisResult) {
        if (analysisResult) {
            @strongify(self);
            self.analysisResultTextView.text = analysisResult.printString;
            [self.faceView drawFace:analysisResult.faces];
        }
        [QMUITips hideAllTips];
    }];
}

#pragma mark - private

- (UIImage *)alignImageWidthAndHeight:(UIImage*)image
{
    // 对图片宽高对齐处理
    int imageWidth = image.size.width;
    int imageHeight = image.size.width;
    if (imageWidth % 4 != 0) {
        imageWidth = imageWidth - (imageWidth % 4);
    }
    if (imageHeight % 2 != 0) {
        imageHeight = imageHeight - (imageHeight % 2);
    }
    CGRect rect = CGRectMake(0, 0, imageWidth, imageHeight);
    return [self clipWithImageRect:rect clipImage:image];
}

- (UIImage *)clipWithImageRect:(CGRect)clipRect clipImage:(UIImage *)clipImage
{
    UIGraphicsBeginImageContext(clipRect.size);
    [clipImage drawInRect:CGRectMake(0,0,clipRect.size.width,clipRect.size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return  newImage;
}



- (BOOL)forceEnableInteractivePopGestureRecognizer
{
    return NO;
}

@end
