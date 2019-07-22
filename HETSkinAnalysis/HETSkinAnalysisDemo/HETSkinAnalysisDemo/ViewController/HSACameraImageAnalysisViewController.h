//
//  HSACameraImageAnalysisViewController.h
//  HETSkinAnalysisDemo
//
//  Created by 远征 马 on 2019/7/19.
//  Copyright © 2019 马远征. All rights reserved.
//

#import "HSACommonViewController.h"

@class HETSkinAnalysisFaceEngine;
NS_ASSUME_NONNULL_BEGIN

@interface HSACameraImageAnalysisViewController : HSACommonViewController
@property (nonatomic, strong) UIImage *cameraImage;
@property (nonatomic, strong) HETSkinAnalysisFaceEngine *faceEngine;
@end

NS_ASSUME_NONNULL_END
