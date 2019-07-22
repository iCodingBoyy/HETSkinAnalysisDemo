//
//  HSAFaceFrame.m
//  HETSkinAnalysisDemo
//
//  Created by 远征 马 on 2019/7/15.
//  Copyright © 2019 马远征. All rights reserved.
//

#import "HSAFaceFrame.h"

@implementation HSAFaceFrame

- (void)drawRect:(CGRect)rect
{
    [[UIColor orangeColor]setStroke];
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:CGRectInset(rect, 5, 5)];
    bezierPath.lineWidth = 5.0;
    [bezierPath stroke];
}

@end
