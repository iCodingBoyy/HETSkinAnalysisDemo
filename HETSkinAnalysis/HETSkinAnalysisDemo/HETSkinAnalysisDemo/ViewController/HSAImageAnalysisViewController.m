//
//  HSAImageAnalysisViewController.m
//  HETSkinAnalysisDemo
//
//  Created by 远征 马 on 2019/7/9.
//  Copyright © 2019 马远征. All rights reserved.
//

#import "HSAImageAnalysisViewController.h"
#import <HETSkinAnalysis/HETSkinAnalysis.h>
#import <Masonry/Masonry.h>
#import "HSAFace.h"
#import "HSACloudAnalysisViewController.h"
#import <YYKit/YYKit.h>

@interface HSAImageAnalysisViewController () <UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (nonatomic, strong) UIView *imageContainerView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *alphaView;
@property (nonatomic, strong) UITextView *analysisResultTextView;
@property (nonatomic, strong) HETSkinAnalysisFaceEngine *faceEngine;
@property (nonatomic, strong) HSAFace *faceView;
@end

@implementation HSAImageAnalysisViewController

- (void)dealloc
{
   NSLog(@"---%s---",__FUNCTION__);

    if (_faceEngine) {
        [_faceEngine destoryEngine];
        _faceEngine = nil;
    }
}

#pragma mark - 按钮交互

- (void)clickToSelectImage
{
    [self showActionSheet];
}

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


#pragma mark - life cycle

- (void)makeConstraints
{
    @weakify(self);
    QMUIFillButton *imageSelectButton = nil;
    imageSelectButton = [[QMUIFillButton alloc]init];
    imageSelectButton.titleTextColor = [UIColor whiteColor];
    imageSelectButton.fillColor = [UIColor redColor];
    [imageSelectButton setTitle:@"选取照片" forState:UIControlStateNormal];
    [imageSelectButton setTitle:@"选取照片" forState:UIControlStateSelected];
    [imageSelectButton addTarget:self action:@selector(clickToSelectImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:imageSelectButton];
    [imageSelectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.mas_topLayoutGuide).offset(20);
        make.width.equalTo(@(120));
        make.height.equalTo(@(40));
    }];
    
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
        make.top.equalTo(imageSelectButton.mas_bottom ).offset(20);
        make.bottom.equalTo(skinAnalysisButton.mas_top).offset(-20);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
    }];
    
    UIImage *image = [UIImage imageNamed:@"default"];
    // 对图像对齐处理
    UIImage *alignImage = [self alignImageWidthAndHeight:image];
    NSLog(@"---alignImage---%@",NSStringFromCGSize(alignImage.size));
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
        NSLog(@"---multipliedByValue---%@",@(multipliedByValue));
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
    self.titleView.title = @"静态人脸图片分析";
    self.view.backgroundColor = [UIColor whiteColor];
    [self makeConstraints];
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

#pragma mark - imagePicker

- (void)showActionSheet
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        QMUIAlertAction *action1 = [QMUIAlertAction actionWithTitle:@"取消" style:QMUIAlertActionStyleCancel handler:^(QMUIAlertController *aAlertController, QMUIAlertAction *action) {
        }];
        QMUIAlertAction *action2 = [QMUIAlertAction actionWithTitle:@"拍照" style:QMUIAlertActionStyleDestructive handler:^(QMUIAlertController *aAlertController, QMUIAlertAction *action) {
            [self showImagePickerWithSourceType:UIImagePickerControllerSourceTypeCamera];
        }];
        QMUIAlertAction *action3 = [QMUIAlertAction actionWithTitle:@"从手机相册选择" style:QMUIAlertActionStyleDestructive handler:^(QMUIAlertController *aAlertController, QMUIAlertAction *action) {
            [self showImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        }];
        QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:QMUIAlertControllerStyleActionSheet];
        [alertController addAction:action1];
        [alertController addAction:action2];
        [alertController addAction:action3];
        [alertController showWithAnimated:YES];
    }
    else
    {
        QMUIAlertAction *action1 = [QMUIAlertAction actionWithTitle:@"取消" style:QMUIAlertActionStyleCancel handler:^(QMUIAlertController *aAlertController, QMUIAlertAction *action) {
        }];
        QMUIAlertAction *action2 = [QMUIAlertAction actionWithTitle:@"从手机相册选择" style:QMUIAlertActionStyleDestructive handler:^(QMUIAlertController *aAlertController, QMUIAlertAction *action) {
            [self showImagePickerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        }];
        QMUIAlertController *alertController = [QMUIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:QMUIAlertControllerStyleActionSheet];
        [alertController addAction:action1];
        [alertController addAction:action2];
        [alertController showWithAnimated:YES];
    }
}

- (void)showImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.sourceType = sourceType;
    imagePicker.allowsEditing = NO;//[[UIDevice currentDevice]isPad] ? NO:YES;
    imagePicker.delegate = self;
    [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerController
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    hsa_dispatch_async_main(^{
        if (IS_IPAD)
        {
            UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
            self.imageView.image = [self alignImageWidthAndHeight:originalImage];
            NSLog(@"---alignImage---%@",NSStringFromCGSize(self.imageView.image.size));
        }
        else
        {
            UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
            
            self.imageView.image = [self alignImageWidthAndHeight:originalImage];
            NSLog(@"---alignImage---%@",NSStringFromCGSize(self.imageView.image.size));
        }
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [QMUITips showLoading:@"人脸信息检测中" inView:window];
        [self processFaceImage];
    });
}


static inline void hsa_dispatch_async_main(dispatch_block_t block)
{
    if ([NSThread isMainThread]) {
        block();
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

@end
