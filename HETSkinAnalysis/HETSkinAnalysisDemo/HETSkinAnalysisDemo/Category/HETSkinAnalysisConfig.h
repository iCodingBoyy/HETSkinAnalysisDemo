//
//  HETSkinAnalysisConfig.h
//  HETSkinAnalysisDemo
//
//  Created by 远征 马 on 2019/9/23.
//  Copyright © 2019 马远征. All rights reserved.
//

#import <Realm/Realm.h>

@interface HETSkinAnalysisConfig : RLMObject
@property BOOL faceBoundsDetectionEnable;
@property BOOL yuvLightDetectionEnable;
@property BOOL distanceDetectionEnable;
@property BOOL standardFaceCheckEnable;
@property float maxDetectionDistance;
@property float minDetectionDistance;
@property int maxYUVLight;
@property int minYUVLight;
// 面部检测边界X偏移
@property float faceDetectionBoundsInsetDx;
// 面部检测边界y偏移
@property float faceDetectionBoundsInsetDy;
@end

