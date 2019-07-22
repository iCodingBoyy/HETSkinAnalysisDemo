//
//  HSAContant.h
//  HETSkinAnalysisDemo
//
//  Created by 远征 马 on 2019/7/19.
//  Copyright © 2019 马远征. All rights reserved.
//

#import <Foundation/Foundation.h>

static dispatch_queue_t face_frame_draw_serial_queue() {
    static dispatch_queue_t hsa_face_frame_draw_serial_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hsa_face_frame_draw_serial_queue = dispatch_queue_create("com.hsa.face.frame.draw", DISPATCH_QUEUE_SERIAL);
    });
    return hsa_face_frame_draw_serial_queue;
}

static inline void hsa_dispatch_async_main(dispatch_block_t block)
{
    if ([NSThread isMainThread]) {
        block();
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

static inline void hsa_dispatch_sync_main(dispatch_block_t block)
{
    if ([NSThread isMainThread]) {
        block();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

static inline void hsa_dispatch_async(dispatch_queue_t queue, dispatch_block_t block)
{
    if (queue && block) {
        dispatch_async(queue, block);
    }
}

static inline void hsa_dispatch_sync(dispatch_queue_t queue, dispatch_block_t block)
{
    if (queue && block) {
        dispatch_sync(queue, block);
    }
}

NS_ASSUME_NONNULL_BEGIN

@interface HSAContant : NSObject

@end

NS_ASSUME_NONNULL_END
