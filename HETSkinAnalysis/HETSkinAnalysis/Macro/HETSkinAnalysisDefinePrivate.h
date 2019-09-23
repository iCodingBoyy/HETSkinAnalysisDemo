//
//  HETSkinAnalysisDefinePrivate.h
//  HETSkinAnalysis
//
//  Created by 远征 马 on 2019/6/28.
//  Copyright © 2019 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef hetWeakify
    #if DEBUG
        #if __has_feature(objc_arc)
            #define hetWeakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
        #else
            #define hetWeakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
        #endif
    #else
        #if __has_feature(objc_arc)
            #define hetWeakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
        #else
            #define hetWeakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
        #endif
    #endif
#endif

#ifndef hetStrongify
    #if DEBUG
        #if __has_feature(objc_arc)
            #define hetStrongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
        #else
            #define hetStrongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
        #endif
    #else
        #if __has_feature(objc_arc)
            #define hetStrongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
        #else
            #define hetStrongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
        #endif
    #endif
#endif


FOUNDATION_EXPORT NSString *HETGetVoiceFile(NSString *fileName);

static inline void het_dispatch_async_main(dispatch_block_t block)
{
    if ([NSThread isMainThread]) {
        block();
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

static inline void het_dispatch_async(dispatch_queue_t queue, dispatch_block_t block)
{
    if (queue && block) {
        dispatch_async(queue, block);
    }
}

static inline void het_dispatch_sync(dispatch_queue_t queue, dispatch_block_t block)
{
    if (queue && block) {
        dispatch_sync(queue, block);
    }
}
static inline void het_dispatch_after(NSTimeInterval delayInSeconds, dispatch_block_t block)
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), block);
}



FOUNDATION_EXPORT NSString *HETGetURLDomain(void);


@interface HETSkinAnalysisDefinePrivate : NSObject

@end


