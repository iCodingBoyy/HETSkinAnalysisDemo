//
//  UIColor+HETSkinAnalysis.h
//  HETSkinAnalysis
//
//  Created by 远征 马 on 2019/6/28.
//  Copyright © 2019 马远征. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIColor (HETSkinAnalysis)

/**
 将hex string的颜色值转换为UIColor对象，你可以设置指定的alpha

 @param color 颜色字符串
 @param alpha alpha 0.0~1.0
 @return UIColor对象
 */
+ (UIColor *)hetColorWithHexString:(NSString *)color alpha:(CGFloat)alpha;


/**
 将hex string的颜色值转换为UIColor对象
 
 @param color 颜色字符串
 @return UIColor对象
 */
+ (UIColor *)hetColorWithHexString:(NSString *)color;
@end

