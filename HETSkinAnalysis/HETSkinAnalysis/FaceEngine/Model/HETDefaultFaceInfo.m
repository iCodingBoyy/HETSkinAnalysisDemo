//
//  HETDefaultFaceInfo.m
//  HETSkinAnalysis
//
//  Created by 远征 马 on 2019/7/21.
//  Copyright © 2019 马远征. All rights reserved.
//

#import "HETDefaultFaceInfo.h"
#import "HETSkinAnalysisConfiguration+HETPrivate.h"

@implementation HETDefaultFaceInfo

- (instancetype)copyWithZone:(NSZone *)zone
{
    HETDefaultFaceInfo *copyObj = [[[self class] allocWithZone:zone] init];
    copyObj.faceBounds = self.faceBounds;
    copyObj.faceAngle = self.faceAngle;
    copyObj.hasRollAngleValue = self.hasRollAngleValue;
    copyObj.rollAngle = self.rollAngle;
    copyObj.hasYawAngleValue = self.hasYawAngleValue;
    copyObj.yawAngle = self.yawAngle;
    copyObj.hasLeftEyePosition = self.hasLeftEyePosition;
    copyObj.leftEyePosition = self.leftEyePosition;
    copyObj.hasRightEyePosition = self.hasRightEyePosition;
    copyObj.rightEyePosition = self.rightEyePosition;
    copyObj.hasMouthPosition = self.hasMouthPosition;
    copyObj.mouthPosition = self.mouthPosition;
    return copyObj;
}



#pragma mark - age

- (BOOL)supportAge {
    return NO;
}

- (NSInteger)getAge
{
    return 0;
}

#pragma mark - face status

- (BOOL)supportFaceStatus {
    return NO;
}


- (NSInteger)getFaceStatus {
    return 0;
}

#pragma mark - gender

- (BOOL)supportGender {
    return NO;
}

- (NSInteger)getGender {
    return 0;
}

#pragma mark - face angle

- (BOOL)hasFaceAngle
{
    return self.hasFaceAngleValue;
}

- (CGFloat)getFaceAngle
{
    return self.faceAngle;
}

#pragma mark - pitch angle

- (BOOL)hasPitchAngle {
    return NO;
}

- (CGFloat)getPitchAngle {
    return 0.0;
}

#pragma mark - roll angle

- (BOOL)hasRollAngle {
    return self.hasRollAngleValue;
}


- (CGFloat)getRallAngle {
    return self.rollAngle;
}

- (BOOL)hasYawAngle {
    return self.hasYawAngleValue;
}

#pragma mark - yaw angle

- (CGFloat)getYawAngle {
    return self.yawAngle;
}

- (BOOL)isStandardFace {
    if (self.hasLeftEyePosition && self.hasRightEyePosition && self.hasMouthPosition) {
        return YES;
    }
    return NO;
}

#pragma mark - face bounds

- (CGRect)getfaceBounds {
    return self.faceBounds;
}

- (CGRect)getFaceBoxBounds
{
    HETSkinAnalysisConfiguration *config = [HETSkinAnalysisConfiguration rawDefaultConfiguration];
    return self.faceBoxBounds = [self realFaceBoundsInCameraBounds:config.cameraDetectionBounds];
}

// 获取当前视频帧图像的尺寸，用于人脸边界的计算
- (CGSize)getVideoBufferImageSize
{
    return self.videoBufferImageSize;
}

- (CGRect)realFaceBoundsInCameraBounds:(CGRect)cameraBounds
{
    if (self.videoBufferImageSize.width <= 0 || self.videoBufferImageSize.height <= 0) {
        return CGRectZero;
    }
    CGSize size = self.videoBufferImageSize;
    CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, -1);
    transform = CGAffineTransformTranslate(transform,0,-size.height);
    CGSize viewSize = cameraBounds.size;
//    CGFloat scale = MIN(viewSize.width / size.width,viewSize.height / size.height);
//    CGFloat offsetX = (viewSize.width - size.width * scale) / 2;
//    CGFloat offsetY = (viewSize.height - size.height * scale) / 2;
    CGFloat xScale = viewSize.width / size.width;
    CGFloat yScale = viewSize.height / size.height;
    CGFloat offsetX = (viewSize.width - size.width * xScale) / 2;
    CGFloat offsetY = (viewSize.height - size.height * yScale) / 2;
    // 缩放
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(xScale, yScale);
    //获取人脸的frame
    CGRect faceViewBounds = CGRectApplyAffineTransform(self.faceBounds, transform);
    // 修正
    faceViewBounds = CGRectApplyAffineTransform(faceViewBounds,scaleTransform);
    faceViewBounds.origin.x += offsetX;
    faceViewBounds.origin.y += offsetY;
    return faceViewBounds;
    
//    CGAffineTransform transform = CGAffineTransformMakeScale(1, -1);
//    transform = CGAffineTransformTranslate(transform, 0, -self.videoBufferImageSize.height);
//    CGRect faceBounds = CGRectApplyAffineTransform(self.faceBounds, transform);
//    CGSize cameraSize = cameraBounds.size;
//    CGFloat xScale = cameraSize.width / self.videoBufferImageSize.width;
//    CGFloat yScale = cameraSize.height / self.videoBufferImageSize.height;
//    CGFloat offsetX = (cameraSize.width - self.videoBufferImageSize.width * xScale) / 2;
//    CGFloat offsetY = (cameraSize.height - self.videoBufferImageSize.height * yScale) / 2;
//    faceBounds = CGRectApplyAffineTransform(faceBounds, CGAffineTransformMakeScale(xScale, yScale));
//    faceBounds.origin.x += offsetX;
//    faceBounds.origin.y += offsetY;
//    return faceBounds;
//    CGRect frameFaceRect = {0};
//    frameFaceRect.size.width = CGRectGetWidth(cameraBounds)*self.faceBounds.size.width/self.videoBufferImageSize.width;
//    frameFaceRect.size.height = CGRectGetHeight(cameraBounds)*self.faceBounds.size.height/self.videoBufferImageSize.height;
//    frameFaceRect.origin.x = CGRectGetWidth(cameraBounds)*self.faceBounds.origin.x/self.videoBufferImageSize.width;
//    frameFaceRect.origin.y = CGRectGetHeight(cameraBounds)*self.faceBounds.origin.y/self.videoBufferImageSize.height;
//    return frameFaceRect;
}

- (CGRect)realFaceBoundsInImageView:(UIImageView *)imageView
{
    if (!imageView || !imageView.image) {
        return CGRectZero;
    }
    CGSize imageSize = imageView.image.size;
    if (imageSize.width < 0 || imageSize.height < 0)
    {
        return CGRectZero;
    }
    CGRect imageRect = imageView.bounds;
//    CGRect frameFaceRect = {0};
//    frameFaceRect.size.width = CGRectGetWidth(imageRect)*self.faceBounds.size.width/imageSize.width;
//    frameFaceRect.size.height = CGRectGetHeight(imageRect)*self.faceBounds.size.height/imageSize.height;
//    frameFaceRect.origin.x = CGRectGetWidth(imageRect)*self.faceBounds.origin.x/imageSize.width;
//    frameFaceRect.origin.y = CGRectGetHeight(imageRect)*self.faceBounds.origin.y/imageSize.height;
//    return frameFaceRect;
    
    CGAffineTransform transform = CGAffineTransformMakeScale(1, -1);
    transform = CGAffineTransformTranslate(transform, 0, -imageSize.height);
    CGRect faceBounds = CGRectApplyAffineTransform(self.faceBounds, transform);
    CGSize cameraSize = imageRect.size;
    CGFloat xScale = cameraSize.width / imageSize.width;
    CGFloat yScale = cameraSize.height / imageSize.height;
    CGFloat offsetX = (cameraSize.width - imageSize.width * xScale) / 2;
    CGFloat offsetY = (cameraSize.height - imageSize.height * yScale) / 2;
    faceBounds = CGRectApplyAffineTransform(faceBounds, CGAffineTransformMakeScale(xScale, yScale));
    faceBounds.origin.x += offsetX;
    faceBounds.origin.y += offsetY;
    return faceBounds;
}

#pragma mark - log

- (NSDictionary*)params
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:NSStringFromCGRect(self.faceBounds) forKey:@"faceBounds"];
    [dictionary setObject:@(self.faceAngle) forKey:@"faceAngle"];
    [dictionary setObject:@([self isStandardFace]) forKey:@"isStandardFace"];
    [dictionary setObject:@(self.hasRollAngleValue) forKey:@"hasRollAngleValue"];
    [dictionary setObject:@(self.rollAngle) forKey:@"rollAngle"];
    [dictionary setObject:@(self.hasYawAngleValue) forKey:@"hasYawAngleValue"];
    [dictionary setObject:@(self.yawAngle) forKey:@"yawAngle"];
    [dictionary setObject:@(self.hasLeftEyePosition) forKey:@"hasLeftEyePosition"];
    [dictionary setObject:NSStringFromCGPoint(self.leftEyePosition) forKey:@"leftEyePosition"];
    [dictionary setObject:@(self.hasRightEyePosition) forKey:@"hasRightEyePosition"];
    [dictionary setObject:NSStringFromCGPoint(self.rightEyePosition) forKey:@"rightEyePosition"];
    [dictionary setObject:@(self.hasMouthPosition) forKey:@"hasMouthPosition"];
    [dictionary setObject:NSStringFromCGPoint(self.mouthPosition) forKey:@"mouthPosition"];
    return dictionary;
}

- (NSString*)description
{
    NSDictionary *dictionary = [self params];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    if (!jsonData) {
        return nil;
    }
    NSString *result = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return result;
}


- (NSString *)logString
{
    NSMutableString *print = [[NSMutableString alloc]init];
    [print appendString:@"\t|---------人脸信息-----\n"];
    [print appendFormat:@"\t|---人脸边界：%@\n",NSStringFromCGRect(self.faceBounds)];
    if (self.hasFaceAngle) {
        [print appendFormat:@"\t|---人脸角度：%@\n",@([self getFaceAngle])];
    }
    if (self.supportAge) {
        [print appendFormat:@"\t|---年龄：%@\n",@([self getAge])];
    }
    if (self.supportGender) {
        [print appendFormat:@"\t|---性别：%@\n",@([self getGender])];
    }
    if (self.hasYawAngleValue) {
        [print appendFormat:@"\t|---偏航角：%@\n",@([self getYawAngle])];
    }
    if (self.hasRollAngleValue) {
        [print appendFormat:@"\t|---横滚角：%@\n",@([self getRallAngle])];
    }
    if (self.hasPitchAngle) {
        [print appendFormat:@"\t|---俯仰角：%@\n",@([self getPitchAngle])];
    }
    if (self.supportFaceStatus) {
        [print appendFormat:@"\t|---人脸状态：%@\n",@([self getFaceStatus])];
    }
    return [NSString stringWithString:print];
}
@end
