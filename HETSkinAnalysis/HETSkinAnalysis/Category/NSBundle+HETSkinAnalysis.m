//
//  NSBundle+HETSkinAnalysis.m
//  HETSkinAnalysis
//
//  Created by 远征 马 on 2019/6/28.
//  Copyright © 2019 马远征. All rights reserved.
//

#import "NSBundle+HETSkinAnalysis.h"

@implementation NSBundle (HETSkinAnalysis)
+ (NSBundle*)hetResourceBundle
{
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *bundlePath = [[NSBundle mainBundle]pathForResource:@"HETSkinAnalysisBundle" ofType:@"bundle"];
        if (bundlePath) {
            bundle = [NSBundle bundleWithPath:bundlePath];
        }
    });
    return bundle;
}
@end
