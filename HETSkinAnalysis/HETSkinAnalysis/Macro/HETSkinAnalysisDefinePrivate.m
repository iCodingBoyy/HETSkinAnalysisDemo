//
//  HETSkinAnalysisDefinePrivate.m
//  HETSkinAnalysis
//
//  Created by 远征 马 on 2019/6/28.
//  Copyright © 2019 马远征. All rights reserved.
//

#import "HETSkinAnalysisDefinePrivate.h"
#import "NSBundle+HETSkinAnalysis.h"



FOUNDATION_EXTERN_INLINE NSString *HETGetVoiceFile(NSString *fileName)
{
    if (!fileName) {
        return nil;
    }
    NSBundle *bundle = [NSBundle hetResourceBundle];
    NSString *filePath = [bundle pathForResource:fileName ofType:nil];
    return filePath;
}


//#ifndef KHETNetWorkTypePreRelease
//    #define KHETNetWorkTypePreRelease 1
//#endif


FOUNDATION_EXTERN_INLINE NSString *HETGetURLDomain(void)
{
#if defined(KHETNetWorkTypePreRelease)
    return @"https://pre.open.api.clife.cn";
#else
    return @"https://open.api.clife.cn";
#endif
}

@implementation HETSkinAnalysisDefinePrivate

@end
