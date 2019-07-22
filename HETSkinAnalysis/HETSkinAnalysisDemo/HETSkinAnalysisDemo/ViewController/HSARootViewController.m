//
//  HSARootViewController.m
//  HETSkinAnalysisDemo
//
//  Created by 远征 马 on 2019/7/9.
//  Copyright © 2019 马远征. All rights reserved.
//

#import "HSARootViewController.h"
#import <Masonry.h>
#import <YYKit/YYKit.h>
#import "HSASkinCameraViewController.h"
#import "HSAImageAnalysisViewController.h"
#import <HETSkinAnalysis/HETSkinAnalysis.h>

@interface HSARootViewController () <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation HSARootViewController

- (void)makeConstraints
{
    @weakify(self);
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.mas_topLayoutGuide);
        make.left.right.bottom.equalTo(self.view);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleView.title = @"拍照测肤";
    [self makeConstraints];
    
    // 设置非静音，如果设置了静音，人脸识别将停止语音播报
    [HETSkinAnalysisConfiguration setMute:NO];
    
    // 正式环境
    NSString *appId = @"31374";
    NSString *appSecret = @"705955fd634147d58f1be9f56b76e43f";
    // 预发布环境
//    NSString *appId = @"31298";
//    NSString *appSecret = @"145a2540f00147e89dc5e33b6842f74c";
    // 初始化自定义配置
    HETSkinAnalysisConfiguration *config = [HETSkinAnalysisConfiguration defaultConfiguration];
    [config registerWithAppId:appId andSecret:appSecret];
    // 设置一个人脸识别引擎，如不设置将使用默认引擎
    [config setFaceDetectionEngine:HETFaceDetectionEngineDefault];
    // 设置语音播报文件，你可以根据需要自定义语音，这里使用默认语音
    [config setCustomVoice:[[HETSkinAnalysisVoice alloc]init]];
    // 设置人脸检测边界框，你可根据自己的需要绘制合适的人脸框来限制人脸捕捉区域，如果不设置，则使用全局视频区域
    [config setFaceDetectionBounds:CGRectInset(UIScreen.mainScreen.bounds, 20, 100)];
    // 设置相机边界，人脸坐标转换需要参考此数值，如果不设置将无法转换人脸坐标到view窗口坐标系
    [config setCameraBounds:[UIScreen mainScreen].bounds];
    [config setJsonToModelBlock:^id(__unsafe_unretained Class aClass, id obj) {
        id model =  [aClass modelWithJSON:obj];
        return model;
    }];
    [HETSkinAnalysisConfiguration setDefaultConfiguration:config];
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.row == 0) {
        cell.textLabel.text = @"动态拍照测肤";
    }
    else if (indexPath.row == 1)
    {
        cell.textLabel.text = @"静态人脸图片分析";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        if ([AVCaptureDevice hetIsValidPixelForDevice]) {
            HSASkinCameraViewController *skinCamera = [[HSASkinCameraViewController alloc]init];
            [self.navigationController pushViewController:skinCamera animated:YES];
        }
        else
        {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"设备像素过低不支持拍照测肤" preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.navigationController popViewControllerAnimated:YES];
            }]];
            [self.navigationController presentViewController:alertController animated:YES completion:^{
                
            }];
        }
    }
    else if (indexPath.row == 1)
    {
        HSAImageAnalysisViewController *imageAnalysis = [[HSAImageAnalysisViewController alloc]init];
        [self.navigationController pushViewController:imageAnalysis animated:YES];
    }
}

#pragma mark - Getter

- (UITableView*)tableView
{
    if (_tableView) {
        return _tableView;
    }
    _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    //    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.separatorColor = [UIColor colorWithRed:0.898 green:0.898 blue:0.898 alpha:1.0];
    _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.estimatedRowHeight = 0.0;
    _tableView.estimatedSectionHeaderHeight = 0.0;
    _tableView.estimatedSectionFooterHeight = 0.0;
    if (@available(iOS 11.0, *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    return _tableView;
}
@end
