//
//  UIImage+HETSkinAnalysis.h
//  HETSkinAnalysis
//
//  Created by 远征 马 on 2019/6/28.
//  Copyright © 2019 马远征. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>
#import <CoreMedia/CoreMedia.h>

NSData *HETCompressImage(UIImage *image, CGFloat compressionQuality);


@interface UIImage (HETSkinAnalysis)


#pragma mark - Image Load
/**
 从默认bundle加载图像

 @param imageName 图像名称
 @return UIImage对象
 */
+ (UIImage*)hetImageNamed:(NSString*)imageName;

#pragma mark - RGB Image
/**
 将视频帧转换为RGB图像

 @param sampleBuffer 视频帧buffer
 @return RGB image
 */
+ (UIImage *)hetRGBImageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;



#pragma mark - YUV Light
+ (NSInteger)hetYUVLightFromImage:(UIImage*)image faceRect:(CGRect)rect imageWidth:(NSInteger)imageWidth;
/**
 从buffer获取视频帧图像亮度

 @param sampleBuffer 视频帧buffer
 @param rect 侦测到的人脸区域
 @param imageWidth 输入的帧图像RBG image宽度
 @return 当前帧图像亮度
 */
+ (NSInteger)hetYUVLightFromSampleBuffer:(CMSampleBufferRef)sampleBuffer faceRect:(CGRect)rect inputImageWidth:(NSInteger)imageWidth;



#pragma mark - face detect
/**
 检测image上的人脸特征

 @return features
 */
- (NSArray*)hetGetFaceFeatures;



#pragma mark - Fix O
/**
 修复图像的方向并返回修复了方向的新图像

 @return 修复了方向的新图片
 */
- (UIImage *)hetFixedOrientationImage;


/**
 前置摄像头拍照需要翻转方向

 @return 修复的照片
 */
- (UIImage *)hetFixeImage;

#pragma mark - Resize
/**
 缩放图像到指定size

 @param size 指定图像的size
 @return 缩放后的图像
 */
- (UIImage *)hetResizeImageToSize:(CGSize)size;


/**
 缩放图像到指定size

 @param size 指定图像的size
 @param contentMode 内容填充模式
 @return 缩放后的图像
 */
- (UIImage *)hetResizeImageToSize:(CGSize)size contentMode:(UIViewContentMode)contentMode;
@end

