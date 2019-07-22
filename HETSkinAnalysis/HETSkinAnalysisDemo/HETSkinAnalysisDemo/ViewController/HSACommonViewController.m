//
//  HSACommonViewController.m
//  HETSkinAnalysisDemo
//
//  Created by 远征 马 on 2019/7/9.
//  Copyright © 2019 马远征. All rights reserved.
//

#import "HSACommonViewController.h"

@interface HSACommonViewController ()

@end

@implementation HSACommonViewController

- (void)handBackButtonEvent:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.navigationController.qmui_rootViewController && self.navigationController.qmui_rootViewController != self) {
        self.navigationItem.leftBarButtonItem = [UIBarButtonItem qmui_backItemWithTarget:self action:@selector(handBackButtonEvent:)];
//        self.navigationItem.leftBarButtonItem =  [UIBarButtonItem qmui_itemWithImage:[UIImage imageNamed:@"ico_nav_back"] target:self action:@selector(handBackButtonEvent:)];
    }
}

#pragma mark - delegate

- (nullable UIColor *)navigationBarTintColor
{
    return [UIColor orangeColor];
}

- (UIImage*)navigationBarBackgroundImage
{
    UIImage *image = [UIImage qmui_imageWithColor:[UIColor whiteColor]
                                             size:CGSizeMake(SCREEN_WIDTH, 88)
                                     cornerRadius:0];
    return image;
}

- (UIImage*)navigationBarShadowImage
{
    UIColor *color = [UIColor colorWithRed:0.898 green:0.898 blue:0.898 alpha:1.0];
    UIImage *image = [UIImage qmui_imageWithColor:color
                                             size:CGSizeMake(SCREEN_WIDTH, 0.5)
                                     cornerRadius:0];
    return image;
}

- (BOOL)preferredNavigationBarHidden
{
    return NO;
}

- (BOOL)shouldCustomizeNavigationBarTransitionIfHideable
{
    return YES;
}

- (BOOL)shouldHideKeyboardWhenTouchInView:(UIView *)view
{
    return YES;
}

- (BOOL)forceEnableInteractivePopGestureRecognizer
{
    return YES;
}
@end
