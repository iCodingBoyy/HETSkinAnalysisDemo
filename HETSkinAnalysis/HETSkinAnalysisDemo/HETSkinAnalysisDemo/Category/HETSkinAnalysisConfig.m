//
//  HETSkinAnalysisConfig.m
//  HETSkinAnalysisDemo
//
//  Created by 远征 马 on 2019/9/23.
//  Copyright © 2019 马远征. All rights reserved.
//

#import "HETSkinAnalysisConfig.h"

@implementation HETSkinAnalysisConfig
+ (nullable NSDictionary *)defaultPropertyValues
{
    return @{@"maxDetectionDistance":@(0.85f),
             @"minDetectionDistance":@(0.65),
             @"maxYUVLight":@(220),
             @"minYUVLight":@(80)};
}
@end
