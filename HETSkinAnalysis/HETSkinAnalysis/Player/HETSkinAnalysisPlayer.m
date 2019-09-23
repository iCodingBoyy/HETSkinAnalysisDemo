//
//  HETSkinAnalysisPlayer.m
//  HETSkinAnalysis
//
//  Created by 远征 马 on 2019/7/1.
//  Copyright © 2019 马远征. All rights reserved.
//

#import "HETSkinAnalysisPlayer.h"
#import "NSString+HETSkinAnalysis.h"
#import "NSBundle+HETSkinAnalysis.h"
#import "HETSkinAnalysisDefinePrivate.h"
#import "HETSkinAnalysisConfiguration+HETPrivate.h"

@interface HETSkinAnalysisPlayerCallbackHandler : NSObject
@property (nonatomic, strong) NSString *voiceFile;
@property (nonatomic, strong) NSString *identifer;
@property (nonatomic,   copy) HETVoicePlayerPlayResultBlock callbackBlock;
@end

@implementation HETSkinAnalysisPlayerCallbackHandler
@end

@interface HETSkinAnalysisPlayer () <AVAudioPlayerDelegate>
@property (nonatomic, strong) NSString *voiceFile;
@property (nonatomic, strong) NSMutableDictionary *voicePlayCallbackContainer;
@property (nonatomic, strong) NSDate *playFinishedDate;
@property (nonatomic, assign) BOOL isPausing;
@end

@implementation HETSkinAnalysisPlayer
@synthesize playing = _playing;
@synthesize audoPlayer = _audoPlayer;

+ (instancetype)defaultPlayer
{
    static HETSkinAnalysisPlayer *playerInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        playerInstance = [[self alloc]init];
    });
    return playerInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _voicePlayCallbackContainer = [[NSMutableDictionary alloc]init];
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
    if (note && note.userInfo) {
        if ([note.userInfo.allKeys containsObject:AVAudioSessionSilenceSecondaryAudioHintTypeKey]) {
            NSNumber *type = note.userInfo[AVAudioSessionSilenceSecondaryAudioHintTypeKey];
            if (type.intValue == AVAudioSessionSilenceSecondaryAudioHintTypeBegin) {
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
    }
}

- (BOOL)isPlaying
{
    if (self.audoPlayer) {
        return (_playing = self.audoPlayer.isPlaying);
    }
    return (_playing = NO) ;
}

- (void)playVoice:(NSString*)voiceFile result:(HETVoicePlayerPlayResultBlock)retHandler
{
    [self playVoice:voiceFile shouldDelay:YES result:retHandler];
}

// 新的语音文件延时300ms开始播放。同样的语音文件，待上一个语音播放完成3s后开始播放
- (void)playVoice:(NSString*)voiceFile shouldDelay:(BOOL)canDelay result:(HETVoicePlayerPlayResultBlock)retHandler
{
//    HETSkinAnalysisConfiguration *config = [HETSkinAnalysisConfiguration rawDefaultConfiguration];
//    id<HETSkinAnalysisVoiceDelegate> voiceConfig = [config getVoiceConfig];
//    BOOL shouldPlayShutterVoice = [[voiceConfig getPhotoShutterVoice] isEqualToString:voiceFile];
//    BOOL shouldPlayTakePhotoSuccessVoice = [[voiceConfig getTakePhotoSuccessVoice] isEqualToString:voiceFile];
//    if (self.isPausing && !(shouldPlayShutterVoice || shouldPlayTakePhotoSuccessVoice )) {
    if (self.isPausing) {
//        NSLog(@"---暂停播放--");
        return;
    }
    
    if (!voiceFile)
    {
        if (retHandler) {
            [self stop];
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"voice file为空，语音文件不可用"};
            NSError *error = [NSError errorWithDomain:@"HETVoicePlayErrorDomain" code:107100002 userInfo:userInfo];
            het_dispatch_async_main(^{
                retHandler(0, error);
            });
        }
        return;
    }
    
    HETSkinAnalysisPlayerCallbackHandler *callbackHandler = self.voicePlayCallbackContainer[voiceFile];
    if (!callbackHandler) {
        callbackHandler = [[HETSkinAnalysisPlayerCallbackHandler alloc]init];
        callbackHandler.identifer = [NSString getUUIDString];
        self.voicePlayCallbackContainer[voiceFile] = callbackHandler;
    }
    callbackHandler.voiceFile = voiceFile;
    callbackHandler.callbackBlock = [retHandler copy];
    
    if (!self.voiceFile) {
        // 首次播放,延时300ms开始
        [self stop];
        self.voiceFile = voiceFile;
        if (canDelay)
        {
            [self performSelector:@selector(playVoice) withObject:nil afterDelay:0.3];
        }
        else
        {
            [self playVoice];
        }
        return;
    }
    
    // 非首次播放
    if (![self.voiceFile isEqualToString:voiceFile]) {
        // 移除老的代理回调
//        if ([self.voicePlayCallbackContainer.allKeys containsObject:self.voiceFile]) {
//            [self.voicePlayCallbackContainer removeObjectForKey:self.voiceFile];
//        }
        // 停止当前音频播放
        [self stop];
        self.voiceFile = voiceFile;
        // 延时300ms进行新的音频播放
        if (canDelay) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playVoice) object:nil];
            [self performSelector:@selector(playVoice) withObject:nil afterDelay:0.3];
        }
        else
        {
            [self playVoice];
        }
        return;
    }
    
    if (self.audoPlayer.isPlaying) {
        // 正在播放，不做处理
//        NSLog(@"---正在播放，不做处理---");
        return;
    }
    // 播放相同的音频，等待上一个音频播放完成3s后开始播放
    if (canDelay) {
        NSTimeInterval timeInterval = [NSDate.date timeIntervalSince1970] - self.playFinishedDate.timeIntervalSince1970;
        if (fabs(timeInterval) > 3) {
            [self playVoice];
        }
    }
    else
    {
        [self playVoice];
    }
}

- (void)playVoice
{
    if (!self.voiceFile) {
        // 正在播放，不做处理
        NSLog(@"---语音文件不存在---");
        return;
    }
    
    NSError *error;
    NSURL *url = [NSURL fileURLWithPath:self.voiceFile];
    if (!url) {
        HETSkinAnalysisPlayerCallbackHandler *handler = [self getPlayerCallbackHandler];
        if (handler && handler.callbackBlock) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"无效的Voice URL"};
            NSError *error = [NSError errorWithDomain:@"HETVoicePlayErrorDomain" code:107100003 userInfo:userInfo];
            het_dispatch_async_main(^{
                 handler.callbackBlock(0, error);
            });
        }
        return;
    }
    _audoPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (error) {
        NSLog(@"---AVAudioPlayer init失败---%@",error);
        HETSkinAnalysisPlayerCallbackHandler *handler = [self getPlayerCallbackHandler];
        if (handler && handler.callbackBlock) {
            het_dispatch_async_main(^{
                handler.callbackBlock(0, error);
            });
        }
        return;
    }
    _audoPlayer.delegate = self;
    [self play];
}

#pragma mark - 播放控制

- (void)pause
{
    if (self.isPausing) {
        return;
    }
    [self stop];
    self.isPausing = YES;
//    het_dispatch_after(3, ^{
//        self.isPausing = NO;
//    });
}

- (void)resume
{
    self.isPausing = NO;
}


- (void)play
{
    het_dispatch_async_main(^{
        if (self.audoPlayer && !self.audoPlayer.isPlaying) {
            [self.audoPlayer play];
        }
    });
}

- (void)stop
{
    het_dispatch_async_main(^{
        if (self.audoPlayer && self.audoPlayer.isPlaying) {
            [self.audoPlayer stop];
        }
    });
}


- (void)destoryPlayer
{
    if (_audoPlayer) {
        if (_audoPlayer.isPlaying) {
            [_audoPlayer stop];
        }
        _audoPlayer.delegate = nil;
        _audoPlayer = nil;
    }
    self.isPausing = NO;
    self.voiceFile = nil;
    [self.voicePlayCallbackContainer removeAllObjects];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playVoice) object:nil];
}

- (HETSkinAnalysisPlayerCallbackHandler*)getPlayerCallbackHandler
{
    if (!self.voiceFile) {
        return nil;
    }
    HETSkinAnalysisPlayerCallbackHandler *handler = self.voicePlayCallbackContainer[self.voiceFile];
//    [self.voicePlayCallbackContainer removeObjectForKey:self.voiceFile];
    return handler;
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    self.playFinishedDate = [NSDate date];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playVoice) object:nil];
    HETSkinAnalysisPlayerCallbackHandler *handler = [self getPlayerCallbackHandler];
    if (handler && handler.callbackBlock) {
        het_dispatch_async_main(^{
            handler.callbackBlock(flag, nil);
        });
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error
{
    self.playFinishedDate = [NSDate date];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playVoice) object:nil];
    HETSkinAnalysisPlayerCallbackHandler *handler = [self getPlayerCallbackHandler];
    if (handler && handler.callbackBlock) {
        het_dispatch_async_main(^{
            handler.callbackBlock(0, error);
        });
    }
}
@end
