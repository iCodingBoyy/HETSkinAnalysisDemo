//
//  HETCaptureDeviceConfig.m
//  HETSkinAnalysis
//
//  Created by 远征 马 on 2019/7/21.
//  Copyright © 2019 马远征. All rights reserved.
//

#import "HETCaptureDeviceConfig.h"

@implementation HETCaptureDeviceConfig
- (NSDictionary*)getVideoSettings
{
    NSDictionary *dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    return dic;
}


- (AVCaptureSessionPreset)getCaptureSessionPreset
{
    return AVCaptureSessionPresetPhoto;
}
@end
