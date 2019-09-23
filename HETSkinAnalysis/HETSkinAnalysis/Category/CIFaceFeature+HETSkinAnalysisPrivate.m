//
//  CIFaceFeature+HETSkinAnalysisPrivate.m
//  HETSkinAnalysis
//
//  Created by 远征 马 on 2019/7/19.
//  Copyright © 2019 马远征. All rights reserved.
//

#import "CIFaceFeature+HETSkinAnalysisPrivate.h"

@implementation CIFaceFeature (HETSkinAnalysisPrivate)
- (BOOL)hetIsStandardFace
{
    if (self.hasLeftEyePosition && self.hasRightEyePosition && self.hasMouthPosition) {
        return YES;
    }
    return NO;
}
@end
