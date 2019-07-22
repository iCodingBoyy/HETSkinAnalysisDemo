//
//  HSAFace.m
//  HETSkinAnalysisDemo
//
//  Created by 远征 马 on 2019/7/15.
//  Copyright © 2019 马远征. All rights reserved.
//

#import "HSAFace.h"
#import <YYKit/YYKit.h>
#import "HSAContant.h"

@interface HSAFace ()
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) UIBezierPath *bezierPath;
@property (nonatomic, strong) NSArray <id<HETFaceAnalysisResultDelegate>>*faceInfoArray;
@end

@implementation HSAFace

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setUp];
}

- (void)setUp
{
    self.backgroundColor = [UIColor clearColor];
    _shapeLayer = [CAShapeLayer layer];
    _shapeLayer.backgroundColor = [UIColor clearColor].CGColor;
    _shapeLayer.strokeColor = [UIColor redColor].CGColor;
    _shapeLayer.fillColor = [UIColor clearColor].CGColor;
    _shapeLayer.lineWidth = 2.0;
    [self.layer addSublayer:_shapeLayer];
    
    _bezierPath = [UIBezierPath bezierPath];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.shapeLayer.frame = self.bounds;
}


static dispatch_queue_t face_draw_serial_queue() {
    static dispatch_queue_t hsa_face_draw_serial_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hsa_face_draw_serial_queue = dispatch_queue_create("com.hsa.face.draw", DISPATCH_QUEUE_SERIAL);
    });
    return hsa_face_draw_serial_queue;
}

- (void)drawFace:(NSArray<id<HETFaceAnalysisResultDelegate>>*)faces
{
    hsa_dispatch_async(face_draw_serial_queue(), ^{
        [self.bezierPath removeAllPoints];
        if (faces.count <= 0) {
            hsa_dispatch_async_main(^{
                self.shapeLayer.path = self.bezierPath.CGPath;
            });
            return;
        }
        @weakify(self);
        [faces enumerateObjectsUsingBlock:^(id<HETFaceAnalysisResultDelegate>  _Nonnull faceInfo, NSUInteger idx, BOOL * _Nonnull stop) {
            @strongify(self);
            __block CGRect rect = CGRectZero;
            hsa_dispatch_sync_main(^{
                if (self.drawStillImageFace) {
                    rect = [faceInfo realFaceBoundsInImageView:self.imageView];
                }
                else
                {
                    rect =  [faceInfo getFaceBoxBounds]; //[faceInfo realFaceBoundsInCameraBounds:[UIScreen mainScreen].bounds];
                }
            });
            [self.bezierPath moveToPoint:CGPointMake(rect.origin.x, rect.origin.y)];
            [self.bezierPath addLineToPoint:CGPointMake(rect.origin.x + CGRectGetWidth(rect), rect.origin.y)];
            [self.bezierPath addLineToPoint:CGPointMake(rect.origin.x + CGRectGetWidth(rect), rect.origin.y+CGRectGetHeight(rect))];
            [self.bezierPath addLineToPoint:CGPointMake(rect.origin.x, rect.origin.y+CGRectGetHeight(rect))];
            [self.bezierPath addLineToPoint:CGPointMake(rect.origin.x, rect.origin.y)];
        }];
        hsa_dispatch_async_main(^{
            self.shapeLayer.path = self.bezierPath.CGPath;
        });
    });
}


@end
