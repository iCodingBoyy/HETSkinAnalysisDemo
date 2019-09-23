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
#import "RLMRealm+RLMDB.h"
#import "HETSkinAnalysisConfig.h"
#import "HSASettingViewController.h"

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
    [RLMRealm setDefaultRealmWithUser:@"LocalDB"];
    
    NSString *string = [NSString hetEncryptString:@"123456"];
    NSLog(@"----string----%@",string);
    
    HETSkinAnalysisConfig *config = [[HETSkinAnalysisConfig allObjects]firstObject];
    if (!config) {
        config = [[HETSkinAnalysisConfig alloc]init];
        config.faceBoundsDetectionEnable = YES;
        config.yuvLightDetectionEnable = YES;
        config.distanceDetectionEnable = YES;
        config.standardFaceCheckEnable = YES;
        config.maxDetectionDistance = 0.85;
        config.minDetectionDistance = 0.65;
        config.maxYUVLight = 220;
        config.minYUVLight = 80;
        config.faceDetectionBoundsInsetDx = 20;
        config.faceDetectionBoundsInsetDy = 30;
        [RLMRealm rlmTransactionWithBlock:^(RLMRealm *defaultRealm) {
            [defaultRealm addObject:config];
        }];
    }
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
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
    else
    {
        cell.textLabel.text = @"设置";
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
    else
    {
        // 设置
        HSASettingViewController *settingVC = [[HSASettingViewController alloc]init];
        [self.navigationController pushViewController:settingVC animated:YES];
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
