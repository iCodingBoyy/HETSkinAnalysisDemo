//
//  HETDefaultFaceEngine.m
//  HETSkinAnalysis
//
//  Created by 远征 马 on 2019/7/20.
//  Copyright © 2019 马远征. All rights reserved.
//

#import "HETDefaultFaceEngine.h"
#import "HETDefaultFaceInfo.h"
#import "HETSkinAnalysisConfiguration+HETPrivate.h"
#import "UIImage+HETSkinAnalysis.h"

@interface HETDefaultFaceEngine ()
@property (nonatomic, assign) BOOL faceEngineInitSuccessd;
@property (nonatomic, assign) HETFaceDetectMode faceDetectMode;
@property (nonatomic, strong) NSDictionary *options;
@property (nonatomic, strong) CIDetector *faceDetector;
@end


@implementation HETDefaultFaceEngine

- (instancetype)init {
    self = [super init];
    if(self) {
        NSDictionary *options = @{CIDetectorAccuracy: CIDetectorAccuracyHigh,
                                  CIDetectorTracking:@(YES),
                                  CIDetectorMinFeatureSize:@(0.35)};
        _options = options;
        _faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace
                                           context:nil
                                           options:_options];
    }
    return self;
}


- (BOOL)isValidEngine {
    return self.faceEngineInitSuccessd;
}

- (BOOL)activeEngine:(HETFaceDetectMode)faceDetectMode
{
    self.faceDetectMode = faceDetectMode;
    self.faceEngineInitSuccessd = YES;
    return YES;
}

- (BOOL)changeFaceDetectMode:(HETFaceDetectMode)faceDetectMode
{
    self.faceDetectMode = faceDetectMode;
    return YES;
}

- (void)destoryEngine {
    _options = nil;
    _faceDetector = nil;
    _faceEngineInitSuccessd = YES;
}


- (NSArray<id<HETFaceAnalysisResultDelegate>> *)getFaceFeaturesFromStillImage:(UIImage *)image {
    if (!image) {
        return nil;
    }
    CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
    _faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace
                                       context:nil
                                       options:_options];
    NSArray *faceFeaturesArray = [self.faceDetector featuresInImage:ciImage];
    
    NSMutableArray *tmpArray = [[NSMutableArray alloc]init];
    for (CIFeature *feature in faceFeaturesArray) {
        if ([feature isKindOfClass:[CIFaceFeature class]]) {
            CIFaceFeature *faceFeature = (CIFaceFeature*)feature;
            HETDefaultFaceInfo *faceInfo = [[HETDefaultFaceInfo alloc]init];
            faceInfo.faceBounds = faceFeature.bounds;
            faceInfo.hasFaceAngleValue = faceFeature.hasFaceAngle;
            faceInfo.faceAngle = faceFeature.faceAngle;
            faceInfo.hasLeftEyePosition = faceFeature.hasLeftEyePosition;
            faceInfo.leftEyePosition = faceFeature.leftEyePosition;
            faceInfo.hasRightEyePosition = faceFeature.hasRightEyePosition;
            faceInfo.rightEyePosition = faceFeature.rightEyePosition;
            faceInfo.hasMouthPosition = faceFeature.hasMouthPosition;
            faceInfo.mouthPosition = faceFeature.mouthPosition;
            [tmpArray addObject:faceInfo];
        }
    }
    return [NSArray arrayWithArray:tmpArray];
}

- (UIImage*)getVideoBufferImageFromVideoBuffer:(CMSampleBufferRef)sampleBuffer
{
    UIImage *rgbImage = [UIImage hetRGBImageFromSampleBuffer:sampleBuffer];
    return rgbImage;
}

- (NSArray<id<HETFaceAnalysisResultDelegate>>*)getFaceFeaturesFromVideoBufferImage:(UIImage*)image
{
    if (!image) {
        return nil;
    }
    CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
    _faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace
                                       context:nil
                                       options:_options];
    NSArray *faceFeaturesArray = [self.faceDetector featuresInImage:ciImage];
    
    NSMutableArray *tmpArray = [[NSMutableArray alloc]init];
    for (CIFeature *feature in faceFeaturesArray) {
        if ([feature isKindOfClass:[CIFaceFeature class]])
        {
            CIFaceFeature *faceFeature = (CIFaceFeature*)feature;
            HETDefaultFaceInfo *faceInfo = [[HETDefaultFaceInfo alloc]init];
            faceInfo.faceBounds = faceFeature.bounds;
            faceInfo.videoBufferImageSize = ciImage.extent.size;
            faceInfo.hasFaceAngleValue = faceFeature.hasFaceAngle;
            faceInfo.faceAngle = faceFeature.faceAngle;
            faceInfo.hasLeftEyePosition = faceFeature.hasLeftEyePosition;
            faceInfo.leftEyePosition = faceFeature.leftEyePosition;
            faceInfo.hasRightEyePosition = faceFeature.hasRightEyePosition;
            faceInfo.rightEyePosition = faceFeature.rightEyePosition;
            faceInfo.hasMouthPosition = faceFeature.hasMouthPosition;
            faceInfo.mouthPosition = faceFeature.mouthPosition;
            [tmpArray addObject:faceInfo];
        }
    }
    return [NSArray arrayWithArray:tmpArray];
}

/**
 直接从buffer提取图像
 */
- (NSArray<id<HETFaceAnalysisResultDelegate>> *)getFaceFeaturesFromVideoBuffer:(CMSampleBufferRef)sampleBuffer
{
    UIImage *image = [self getVideoBufferImageFromVideoBuffer:sampleBuffer];
    return [self getFaceFeaturesFromVideoBufferImage:image];
}
@end


@implementation HETDefaultFaceEngineVideoConfig
- (NSDictionary*)getVideoSettings
{
    NSDictionary *dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    return dic;
}


- (AVCaptureSessionPreset)getCaptureSessionPreset
{
    return AVCaptureSessionPresetPhoto;
}
@end
