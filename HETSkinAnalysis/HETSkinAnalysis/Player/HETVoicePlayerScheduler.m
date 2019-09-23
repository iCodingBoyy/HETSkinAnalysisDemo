//
//  HETVoicePlayerScheduler.m
//  HETSkinAnalysis
//
//  Created by 远征 马 on 2019/7/23.
//  Copyright © 2019 马远征. All rights reserved.
//

#import "HETVoicePlayerScheduler.h"
#import "HETVoicePlayer.h"

@interface HETVoicePlayerScheduler ()
@property (nonatomic, strong) NSMutableDictionary *playerContainer;
@property (nonatomic, strong) NSDate *playFinishedDate;
@property (nonatomic, assign) BOOL isPausing;
@end


@implementation HETVoicePlayerScheduler
+ (instancetype)defaultScheduler
{
    static HETVoicePlayerScheduler *schedulerInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        schedulerInstance = [[self alloc]init];
    });
    return schedulerInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _playerContainer = [[NSMutableDictionary alloc]init];
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if (![audioSession.category isEqualToString:AVAudioSessionCategoryPlayback]) {
            NSError *error;
            BOOL ret = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
            if (!ret) {
                NSLog(@"---AVAudioSessionCategoryPlayback设置失败---%@",error);
            }
        }
        NSError *error;
        BOOL ret = [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
        if (!ret) {
            NSLog(@"---AVAudioSession Active失败---%@",error);
        }
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(audioSessionSilenceSecondaryAudioHint:) name:AVAudioSessionSilenceSecondaryAudioHintNotification object:nil];
    }
    return self;
}

- (void)audioSessionSilenceSecondaryAudioHint:(NSNotification*)note
{
    if (!note || !note.userInfo) {
        return;
    }
    if (![note.userInfo.allKeys containsObject:AVAudioSessionSilenceSecondaryAudioHintTypeKey])
    {
        return;
    }
    NSNumber *type = note.userInfo[AVAudioSessionSilenceSecondaryAudioHintTypeKey];
    if (type.intValue == AVAudioSessionSilenceSecondaryAudioHintTypeBegin)
    {
        [self stop];
    }
    else
    {
        NSError *error;
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        BOOL ret = [audioSession setActive:YES withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:&error];
        if (!ret) {
            NSLog(@"---AVAudioSession Active失败---%@",error);
        }
    }
}

- (void)stop
{
    
}

@end
