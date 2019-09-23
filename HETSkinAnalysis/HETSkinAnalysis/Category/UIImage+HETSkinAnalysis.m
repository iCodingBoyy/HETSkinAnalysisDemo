//
//  UIImage+HETSkinAnalysis.m
//  HETSkinAnalysis
//
//  Created by 远征 马 on 2019/6/28.
//  Copyright © 2019 马远征. All rights reserved.
//

#import "UIImage+HETSkinAnalysis.h"
#import "NSBundle+HETSkinAnalysis.h"

#define clamp(a) ( a > 255 ? 255 :( a < 0 ? 0 : a ))

NSData *HETCompressImage(UIImage *image, CGFloat compressionQuality)
{
    if (!image) {
        return nil;
    }
    NSData *data = UIImageJPEGRepresentation(image,compressionQuality);
    if(data.length > 1.5*1024*1024)
    {
        if(compressionQuality >= 0.0)
        {
//            NSLog(@"我在压缩！");
            NSData *data = nil;
            data = UIImageJPEGRepresentation(image, compressionQuality);
            return HETCompressImage(image, compressionQuality-0.1);
        }
        else
        {
//            NSLog(@"图片已经不能再压缩了！！！");
            return data;
        }
        
    }
    else
    {
        return data;
    }
}


@implementation UIImage (HETSkinAnalysis)
+ (UIImage*)hetImageNamed:(NSString*)imageName
{
    if (!imageName) {
        return nil;
    }
    NSBundle *bundle = [NSBundle hetResourceBundle];
    CGFloat scale = [UIScreen mainScreen].scale;
    if (ABS(scale-3) <= 0.001) {
        // 优先加载三倍图
        if (![imageName containsString:@"@"]) {
            imageName = [imageName stringByAppendingString:@"@3x"];
        }
    }
    else if (ABS(scale-2) <= 0.001) {
        // 加载二倍图
        if (![imageName containsString:@"@"]) {
            imageName = [imageName stringByAppendingString:@"@2x"];
        }
    }
    else {
        // 默认加载二倍图
        if (![imageName containsString:@"@"]) {
            imageName = [imageName stringByAppendingString:@"@2x"];
        }
    }
    //    NSLog(@"--加载图片---[%@]:%@",bundle,imageName);
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
    return [UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil];
#elif __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0
    return [UIImage imageWithContentsOfFile:[bundle pathForResource:imageName ofType:@"png"]];
#else
    if ([UIImage respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)]) {
        return [UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil];
    }
    else
    {
        return [UIImage imageWithContentsOfFile:[bundle pathForResource:imageName ofType:@"png"]];
    }
#endif
}

#pragma mark - RGB Image

+ (UIImage*)hetRGBImageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    uint8_t *yBuffer = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
    size_t yPitch = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
    uint8_t *cbCrBuffer = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 1);
    size_t cbCrPitch = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 1);
    
    int bytesPerPixel = 4;
    uint8_t *rgbBuffer = malloc(width * height * bytesPerPixel);
    
    for (int y = 0; y < height; y++)
    {
        uint8_t *rgbBufferLine = &rgbBuffer[y * width * bytesPerPixel];
        uint8_t *yBufferLine = &yBuffer[y * yPitch];
        uint8_t *cbCrBufferLine = &cbCrBuffer[(y >> 1) * cbCrPitch];
        
        for (int x = 0; x < width; x++)
        {
            int16_t y = yBufferLine[x];
            int16_t cb = cbCrBufferLine[x & ~1] - 128;
            int16_t cr = cbCrBufferLine[x | 1] - 128;
            
            uint8_t *rgbOutput = &rgbBufferLine[x*bytesPerPixel];
            
            int16_t r = (int16_t)roundf( y + cr *  1.4 );
            int16_t g = (int16_t)roundf( y + cb * -0.343 + cr * -0.711 );
            int16_t b = (int16_t)roundf( y + cb *  1.765);
            
            rgbOutput[0] = 0xff;
            rgbOutput[1] = clamp(b);
            rgbOutput[2] = clamp(g);
            rgbOutput[3] = clamp(r);
        }
    }
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbBuffer, width, height, 8, width * bytesPerPixel, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(quartzImage);
    free(rgbBuffer);
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    return image;
}


#pragma mark - YUV Image

+ (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    
    CVPixelBufferRef pxbuffer = NULL;
    
    CGFloat frameWidth = CGImageGetWidth(image);
    CGFloat frameHeight = CGImageGetHeight(image);
    
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          frameWidth,
                                          frameHeight,
                                          kCVPixelFormatType_32ARGB,
                                          (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pxdata,
                                                 frameWidth,
                                                 frameHeight,
                                                 8,
                                                 CVPixelBufferGetBytesPerRow(pxbuffer),
                                                 rgbColorSpace,
                                                 (CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    CGContextConcatCTM(context, CGAffineTransformIdentity);
    CGContextDrawImage(context, CGRectMake(0,
                                           0,
                                           frameWidth,
                                           frameHeight),
                       image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    return pxbuffer;
}

+ (NSInteger)hetYUVLightFromImage:(UIImage*)image faceRect:(CGRect)rect imageWidth:(NSInteger)imageWidth
{
    CVImageBufferRef imageBuffer = [self pixelBufferFromCGImage:image.CGImage];
    NSLog(@"---imageBuffer---%@",imageBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    // Get the number of bytes per row for the plane pixel buffer
    void *imageAddress = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
    
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    //    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    
    Byte *buf = malloc(width * height * 3/ 2);//yuv格式
    memcpy(buf, imageAddress, width * height);
    size_t a = width * height;
    size_t b = width * height * 5 / 4;
    for (NSInteger i = 0; i < width * height/ 2; i ++) {
        memcpy(buf + a, imageAddress + width * height + i , 1);
        a++;
        i++;
        memcpy(buf + b, imageAddress + width * height + i, 1);
        b++;
    }
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    NSInteger sum = 0;
    NSInteger index = 0;
    CGFloat maxX = CGRectGetMaxX(rect);
    CGFloat maxY = CGRectGetMaxY(rect);
    if (rect.origin.y < 0 || rect.origin.x < 0 || rect.origin.x > imageWidth || maxX > imageWidth)
    {
        free(buf);
        return 0;
    }
    for (int i = rect.origin.x; i < maxX; )
    {
        for (int j = rect.origin.y; j < maxY; )
        {
            sum += (0xFF & buf[i * imageWidth + j]);
            j += 100;
            index ++;
        }
        i += 100;
    }
    
    if (sum == 0 || index == 0)
    {
        free(buf);
        return 0;
    }
    NSInteger yuvlight = sum / index;
    free(buf);
    return yuvlight;
}

+ (NSInteger)hetYUVLightFromSampleBuffer:(CMSampleBufferRef)sampleBuffer faceRect:(CGRect)rect inputImageWidth:(NSInteger)imageWidth
{
    if (!sampleBuffer || CGRectEqualToRect(rect, CGRectZero)) {
        return 0;
    }
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    // Get the number of bytes per row for the plane pixel buffer
    void *imageAddress = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
    
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    //    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    
    Byte *buf = malloc(width * height * 3/ 2);//yuv格式
    memcpy(buf, imageAddress, width * height);
    size_t a = width * height;
    size_t b = width * height * 5 / 4;
    for (NSInteger i = 0; i < width * height/ 2; i ++) {
        memcpy(buf + a, imageAddress + width * height + i , 1);
        a++;
        i++;
        memcpy(buf + b, imageAddress + width * height + i, 1);
        b++;
    }
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    NSInteger sum = 0;
    NSInteger index = 0;
    CGFloat maxX = CGRectGetMaxX(rect);
    CGFloat maxY = CGRectGetMaxY(rect);
    if (rect.origin.y < 0 || rect.origin.x < 0 || rect.origin.x > imageWidth || maxX > imageWidth)
    {
        free(buf);
        return 0;
    }
    for (int i = rect.origin.x; i < maxX; )
    {
        for (int j = rect.origin.y; j < maxY; )
        {
            sum += (0xFF & buf[i * imageWidth + j]);
            j += 100;
            index ++;
        }
        i += 100;
    }
    
    if (sum == 0 || index == 0)
    {
        free(buf);
        return 0;
    }
    NSInteger yuvlight = sum / index;
    free(buf);
    return yuvlight;
}

#pragma mark - 检测人脸

- (NSArray*)hetGetFaceFeatures
{
//    NSDictionary *options = @{CIDetectorAccuracy: CIDetectorAccuracyHigh,
//                              CIDetectorTracking:@(YES),
//                              CIDetectorMinFeatureSize:@(0.35)};
    NSDictionary *options = @{CIDetectorAccuracy: CIDetectorAccuracyHigh};
    CIDetector *faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace
                                                  context:nil
                                                  options:options];
    CIImage *ciImage = [CIImage imageWithCGImage:self.CGImage];
    return [faceDetector featuresInImage:ciImage];
}


#pragma mark - 方向修正
- (UIImage*)hetFixedOrientationImage
{
    if (self.imageOrientation == UIImageOrientationUp) {
        return self;
    }
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (self.imageOrientation) {
            case UIImageOrientationDown:
            case UIImageOrientationDownMirrored: {
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
        }
            break;
            
            case UIImageOrientationLeft:
            case UIImageOrientationLeftMirrored: {
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
        }
            break;
            
            case UIImageOrientationRight:
            case UIImageOrientationRightMirrored: {
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
        }
            break;
        default:
            break;
    }
    
    switch (self.imageOrientation) {
            case UIImageOrientationUpMirrored:
            case UIImageOrientationDownMirrored: {
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
        }
            break;
            case UIImageOrientationLeftMirrored:
            case UIImageOrientationRightMirrored:{
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
        }
            break;
        default:
            break;
    }
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
            case UIImageOrientationLeft:
            case UIImageOrientationLeftMirrored:
            case UIImageOrientationRight:
            case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (UIImage *)hetFixeImage
{
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 2);
    CGContextRef cuttentContext = UIGraphicsGetCurrentContext();
    CGContextClipToRect(cuttentContext, rect);
    CGContextRotateCTM(cuttentContext, M_PI);
    CGContextTranslateCTM(cuttentContext, -rect.size.width, -rect.size.height);
    CGContextDrawImage(cuttentContext, rect, self.CGImage);
    
    UIImage *drawImage = UIGraphicsGetImageFromCurrentImageContext();
    UIImage *newImage = [UIImage imageWithCGImage:drawImage.CGImage scale:self.scale orientation:self.imageOrientation];
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - 图像缩放

- (UIImage *)hetResizeImageToSize:(CGSize)size
{
    if (size.width <= 0 || size.height <= 0) {
        return nil;
    }
    UIGraphicsBeginImageContextWithOptions(size, NO, self.scale);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)hetResizeImageToSize:(CGSize)size contentMode:(UIViewContentMode)contentMode
{
    if (size.width <= 0 || size.height <= 0) {
        return nil;
    }
    UIGraphicsBeginImageContextWithOptions(size, NO, self.scale);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height) withContentMode:contentMode clipsToBounds:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)drawInRect:(CGRect)rect withContentMode:(UIViewContentMode)contentMode clipsToBounds:(BOOL)clips
{
    CGRect drawRect = HETCGRectFitWithContentMode(rect, self.size, contentMode);
    if (drawRect.size.width == 0 || drawRect.size.height == 0) return;
    if (clips) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        if (context) {
            CGContextSaveGState(context);
            CGContextAddRect(context, rect);
            CGContextClip(context);
            [self drawInRect:drawRect];
            CGContextRestoreGState(context);
        }
    }
    else {
        [self drawInRect:drawRect];
    }
}


CGRect HETCGRectFitWithContentMode(CGRect rect, CGSize size, UIViewContentMode mode) {
    rect = CGRectStandardize(rect);
    size.width = size.width < 0 ? -size.width : size.width;
    size.height = size.height < 0 ? -size.height : size.height;
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    switch (mode) {
            case UIViewContentModeScaleAspectFit:
            case UIViewContentModeScaleAspectFill: {
                if (rect.size.width < 0.01 || rect.size.height < 0.01 ||
                    size.width < 0.01 || size.height < 0.01) {
                    rect.origin = center;
                    rect.size = CGSizeZero;
                }
                else {
                    CGFloat scale;
                    if (mode == UIViewContentModeScaleAspectFit) {
                        if (size.width / size.height < rect.size.width / rect.size.height) {
                            scale = rect.size.height / size.height;
                        } else {
                            scale = rect.size.width / size.width;
                        }
                    }
                    else {
                        if (size.width / size.height < rect.size.width / rect.size.height) {
                            scale = rect.size.width / size.width;
                        } else {
                            scale = rect.size.height / size.height;
                        }
                    }
                    size.width *= scale;
                    size.height *= scale;
                    rect.size = size;
                    rect.origin = CGPointMake(center.x - size.width * 0.5, center.y - size.height * 0.5);
                }
            }
            break;
            case UIViewContentModeCenter: {
                rect.size = size;
                rect.origin = CGPointMake(center.x - size.width * 0.5, center.y - size.height * 0.5);
            }
            break;
            case UIViewContentModeTop: {
                rect.origin.x = center.x - size.width * 0.5;
                rect.size = size;
            }
            break;
            case UIViewContentModeBottom: {
                rect.origin.x = center.x - size.width * 0.5;
                rect.origin.y += rect.size.height - size.height;
                rect.size = size;
            }
            break;
            case UIViewContentModeLeft: {
                rect.origin.y = center.y - size.height * 0.5;
                rect.size = size;
            }
            break;
            case UIViewContentModeRight: {
                rect.origin.y = center.y - size.height * 0.5;
                rect.origin.x += rect.size.width - size.width;
                rect.size = size;
            }
            break;
            case UIViewContentModeTopLeft: {
                rect.size = size;
            }
            break;
            case UIViewContentModeTopRight: {
                rect.origin.x += rect.size.width - size.width;
                rect.size = size;
            } break;
            case UIViewContentModeBottomLeft: {
                rect.origin.y += rect.size.height - size.height;
                rect.size = size;
            }
            break;
            case UIViewContentModeBottomRight: {
                rect.origin.x += rect.size.width - size.width;
                rect.origin.y += rect.size.height - size.height;
                rect.size = size;
            }
            break;
            case UIViewContentModeScaleToFill:
            case UIViewContentModeRedraw:
        default: {
            rect = rect;
        }
    }
    return rect;
}
@end
