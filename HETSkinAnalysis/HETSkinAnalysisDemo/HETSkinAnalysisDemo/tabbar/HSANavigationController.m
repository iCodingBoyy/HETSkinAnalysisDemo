//
//  HSANavigationController.m
//  HETSkinAnalysisDemo
//
//  Created by 远征 马 on 2019/7/9.
//  Copyright © 2019 马远征. All rights reserved.
//

#import "HSANavigationController.h"

@interface HSANavigationController ()

@end

@implementation HSANavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    QMUICMI.tableViewCellCheckmarkImage = [UIImage qmui_imageWithShape:QMUIImageShapeCheckmark size:CGSizeMake(15, 12) tintColor:[UIColor orangeColor]];
}

- (nullable UIColor *)navigationBarTintColor
{
    return [UIColor blackColor];
}

- (BOOL)preferredNavigationBarHidden
{
    return YES;
}

- (BOOL)shouldCustomizeNavigationBarTransitionIfHideable
{
    return YES;
}

@end
