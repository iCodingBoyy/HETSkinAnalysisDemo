//
//  HSACloudAnalysisViewController.m
//  HETSkinAnalysisDemo
//
//  Created by 远征 马 on 2019/7/19.
//  Copyright © 2019 马远征. All rights reserved.
//

#import "HSACloudAnalysisViewController.h"
#import <HETSkinAnalysis/HETSkinAnalysis.h>
#import <YYKit/YYKit.h>
#import <Masonry/Masonry.h>

@interface HSACloudAnalysisViewController ()
@property (nonatomic, strong) HETSkinAnalysisDataEngine *dataEngine;
@property (nonatomic, strong) UITextView *textView;
@end

@implementation HSACloudAnalysisViewController
- (void)dealloc
{
    NSLog(@"---%s---",__FUNCTION__);
}



- (void)makeConstraints
{
    _textView = [[UITextView alloc]init];
    _textView.backgroundColor = [UIColor clearColor];
    _textView.font = [UIFont systemFontOfSize:16];
    _textView.textColor = [UIColor redColor];
    _textView.editable = NO;
    [self.view addSubview:_textView];
    
    @weakify(self);
    [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.mas_topLayoutGuide);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleView.title = @"肤质分析";
    self.view.backgroundColor = [UIColor whiteColor];
    [self makeConstraints];
    // Do any additional setup after loading the view.
    
    _dataEngine = [[HETSkinAnalysisDataEngine alloc]init];
    // 进入大数据分析页面
    if (self.image) {
        
        [QMUITips showLoading:@"正在进行肤质分析" inView:self.view];
        NSString *urlString = @"https://dev-mdm-s3-website.mkmobileapp.com/UAT/NTS/SkinAnalyzerNative-iOS-SG/fbdcf76d-7f43-4a61-98d8-c496b35d94d9/5B3F0B12-C2C4-4BF7-AFF0-E54E80AD0D43/C8BCB08E-B63E-4E70-819D-3083FD2EA17A.jpg";
        [self.dataEngine analysisImage:urlString result:^(HETSkinAnalysisResult *skinAnalysisResult, id responseJSON, NSError *error) {
            [QMUITips hideAllTips];
//            NSLog(@"----responseJSON----%@",responseJSON);
            NSLog(@"----skinAnalysisResult----%@",skinAnalysisResult.modelDescription);
            // 对原始加密图像进行解密
            HETSkinAnalysisDecryptURL(skinAnalysisResult.originalImageUrl, ^(NSString *decryptedURL) {
                NSLog(@"----解密结果----%@",decryptedURL);
            });
            if (error) {
                [QMUITips showError:error.localizedDescription];
            }
            else
            {
                [QMUITips showSucceed:@"肤质信息分析成功"];
                if (responseJSON && [responseJSON isKindOfClass:[NSDictionary class]]) {
                    NSString *string = [responseJSON modelDescription];
                    self.textView.text = string;
                }
                // 将结果进行展示
            }
        }];
    }
}


@end
