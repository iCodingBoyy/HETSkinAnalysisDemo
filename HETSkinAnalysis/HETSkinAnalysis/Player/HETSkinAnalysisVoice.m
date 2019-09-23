//
//  HETSkinAnalysisVoice.m
//  HETSkinAnalysis
//
//  Created by 远征 马 on 2019/7/2.
//  Copyright © 2019 马远征. All rights reserved.
//

#import "HETSkinAnalysisVoice.h"
#import "HETSkinAnalysisDefinePrivate.h"

static NSMutableDictionary *HETVoiceFilePathContainer(void) {
    static NSMutableDictionary *voiceFilePathContainer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        voiceFilePathContainer = [NSMutableDictionary dictionary];
    });
    return voiceFilePathContainer;
}

FOUNDATION_EXTERN_INLINE void HETRemoveAllVoiceFilePathCache(void)
{
    NSMutableDictionary *container = HETVoiceFilePathContainer();
    if (container) {
        [container removeAllObjects];
    }
}



@implementation HETSkinAnalysisVoice

- (NSString*)getVoiceFile:(NSString*)fileName
{
    if (!fileName) {
        return nil;
    }
    NSMutableDictionary *container = HETVoiceFilePathContainer();
    if (container && [container.allKeys containsObject:fileName]) {
        return container[fileName];
    }
    NSString *filePath =  HETGetVoiceFile(fileName);
    if (filePath) {
        container[fileName] = filePath;
    }
    return filePath;
}

- (NSString*)getFrontCameraTakePhotoPromptVoice
{
    NSString *fileName = @"take_photo_prompt_front.mp3";
    return [self getVoiceFile:fileName];
}

- (NSString*)getFrontCameraTakePhotoPromptVoiceText
{
    return @"请平视前置摄像头";
}


- (NSString*)getRearCameraTakePhotoPromptVoice
{
    NSString *fileName = @"take_photo_prompt_back.mp3";
    return [self getVoiceFile:fileName];
}

- (NSString*)getRearCameraTakePhotoPromptVoiceText
{
    return @"请平视后置摄像头";
}


- (NSString*)getKeepFaceInCenterFrameVoice
{
    NSString *fileName = @"distance_center.mp3";
    return [self getVoiceFile:fileName];
}

- (NSString*)getKeepFaceInCenterFrameVoiceText
{
    return @"请将脸部对准示意框";
}

- (NSString*)getWillTakePhotoVoice
{
    NSString *fileName = @"take_photo_prepare.mp3";
    return [self getVoiceFile:fileName];
}

- (NSString*)getWillTakePhotoVoiceText
{
    return @"符合条件的人脸";
}


- (NSString*)getKeepStandardFaceVoice
{
    NSString *fileName = @"stand_face.mp3";
    return [self getVoiceFile:fileName];
}

- (NSString*)getKeepStandardFaceVoiceText
{
    return @"不是标准脸";
}

- (NSString*)getMultipleFaceVoice
{
    NSString *fileName = @"multiple_face.mp3";
    return [self getVoiceFile:fileName];
}

- (NSString*)getMultipleFaceVoiceText
{
    return @"识别到多个人脸";
}


- (NSString*)getNoFaceDetectedVoice
{
    NSString *fileName = @"not_detector_face.mp3";
    return [self getVoiceFile:fileName];
}

- (NSString*)getNoFaceDetectedVoiceText
{
    return @"未检测到人脸";
}

- (NSString*)getPhotoShutterVoice
{
    NSString *fileName = @"photoShutter2.caf";//@"shutterSound.mp3";
    return [self getVoiceFile:fileName];
}



- (NSString*)getLightDimVoice
{
    NSString *fileName = @"light_dim.mp3";
    return [self getVoiceFile:fileName];
}

- (NSString*)getLightDimVoiceText
{
    return @"光线不足";
}

- (NSString*)getLightBrightVoice
{
    NSString *fileName = @"light_bright.mp3";
    return [self getVoiceFile:fileName];
}

- (NSString*)getLightBrightVoiceText
{
    return @"光线偏亮";
}


- (NSString*)getDistanceNearVoice
{
    NSString *fileName = @"distance_far.mp3";
    return [self getVoiceFile:fileName];
}

- (NSString*)getDistanceNearVoiceText
{
    return @"远一点";
}



- (NSString*)getDistanceFarVoice
{
    NSString *fileName = @"distance_near.mp3";
    return [self getVoiceFile:fileName];
}

- (NSString*)getDistanceFarVoiceText
{
    return @"近一点";
}


- (NSString*)getTakePhotoSuccessVoice
{
    NSString *fileName = @"take_photo_success.mp3";
    return [self getVoiceFile:fileName];
}



@end
