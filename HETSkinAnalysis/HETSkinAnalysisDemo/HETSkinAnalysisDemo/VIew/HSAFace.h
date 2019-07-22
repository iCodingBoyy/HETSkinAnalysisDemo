//
//  HSAFace.h
//  HETSkinAnalysisDemo
//
//  Created by 远征 马 on 2019/7/15.
//  Copyright © 2019 马远征. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HETSkinAnalysis/HETSkinAnalysis.h>

NS_ASSUME_NONNULL_BEGIN

@interface HSAFace : UIView
@property (nonatomic, assign) BOOL drawStillImageFace;
@property (nonatomic, weak) UIImageView *imageView;
- (void)drawFace:(NSArray<id<HETFaceAnalysisResultDelegate>>*)faces;
@end

NS_ASSUME_NONNULL_END
