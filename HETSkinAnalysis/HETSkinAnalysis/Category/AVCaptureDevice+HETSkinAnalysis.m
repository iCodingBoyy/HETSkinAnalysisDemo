//
//  AVCaptureDevice+HETSkinAnalysis.m
//  HETSkinAnalysis
//
//  Created by 远征 马 on 2019/6/28.
//  Copyright © 2019 马远征. All rights reserved.
//

#import "AVCaptureDevice+HETSkinAnalysis.h"
#import "HETSkinAnalysisDefinePrivate.h"
#import <UIKit/UIKit.h>
#import <sys/utsname.h>

@implementation AVCaptureDevice (HETSkinAnalysis)

+ (AVAuthorizationStatus)hetGetCameraAuthStatus
{
    return [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
}

+ (void)hetRequestAccessForCamera:(void(^)(BOOL granted))retHandler
{
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        het_dispatch_async_main(^{
            if (retHandler) {
                retHandler(granted);
            }
        });
    }];
}


+ (AVCaptureDevice*)hetGetCaptureDeviceWithPosition:(AVCaptureDevicePosition )position
{
    NSArray *cameras = nil;
    if (@available(iOS 10.0, *)) {
        AVCaptureDeviceDiscoverySession *discoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionUnspecified];
        cameras = discoverySession.devices;
    }
    else
    {
        // Fallback on earlier versions
        cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    }
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position] == position) {
            return camera;
        }
    }
    return nil;
}

+ (NSUInteger)hetGetCameraCount
{
    NSUInteger cameraCount = 0;
    if (@available(iOS 10.0, *)) {
        AVCaptureDeviceDiscoverySession *deviceSession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionUnspecified];
        cameraCount = deviceSession.devices.count;
    }
    else
    {
        cameraCount = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count;
    }
    return cameraCount;
}

+ (BOOL)hetIsValidPixelForDevice
{
    BOOL ret = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (!ret) {
        return NO;
    }
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    if ([platform isEqualToString:@"i386"]) {
        return NO;
    }
    else if ([platform isEqualToString:@"x86_64"]) {
        return NO;
    }
    NSUInteger location = [platform rangeOfString:@","].location;
    if (location < 6) {
        return NO;
    }
    NSInteger version = [[platform substringWithRange:NSMakeRange(6, location-6)] integerValue];
    if ([platform containsString:@"iPhone"] && version < 8) {
        return NO;
    }
    if ([platform isEqualToString:@"iPhone8,4"]) {
        return NO;
    }
    return YES;
}
@end
