//
//  HETVoicePlayer.m
//  HETSkinAnalysis
//
//  Created by 远征 马 on 2019/7/23.
//  Copyright © 2019 马远征. All rights reserved.
//

#import "HETVoicePlayer.h"
#import "HETSkinAnalysisDefinePrivate.h"

@interface HETVoicePlayer () <AVAudioPlayerDelegate>
@property (nonatomic, strong) NSString *voiceFile;
@end

@implementation HETVoicePlayer
@synthesize playing = _playing;
@synthesize player = _player;

- (BOOL)isPlaying
{
    if (self.player) {
        return (_playing = self.player.isPlaying);
    }
    return (_playing = NO);
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)play:(NSString*)vocieFile
{
    [self stop];
    if (!vocieFile)
    {
        het_dispatch_async_main(^{
            if (self.delegate && [self.delegate respondsToSelector:@selector(voicePlayer:error:)]) {
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"voice file为空，语音文件不可用"};
                NSError *error = [NSError errorWithDomain:@"HETVoicePlayErrorDomain" code:107100002 userInfo:userInfo];
                [self.delegate voicePlayer:self error:error];
            }
        });
        return;
    }
    // 开始准备播放
    NSURL *url = [NSURL fileURLWithPath:self.voiceFile];
    if (!url)
    {
        het_dispatch_async_main(^{
            if (self.delegate && [self.delegate respondsToSelector:@selector(voicePlayer:error:)]) {
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"无效的Voice URL"};
                NSError *error = [NSError errorWithDomain:@"HETVoicePlayErrorDomain" code:107100003 userInfo:userInfo];
                [self.delegate voicePlayer:self error:error];
            }
        });
        return;
    }
    NSError *error;
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (error) {
        NSLog(@"---AVAudioPlayer init失败---%@",error);
        het_dispatch_async_main(^{
            if (self.delegate && [self.delegate respondsToSelector:@selector(voicePlayer:error:)]) {
                [self.delegate voicePlayer:self error:error];
            }
        });
        return;
    }
    _player.delegate = self;
    [self play];
}

- (void)play
{
    het_dispatch_async_main(^{
        if (self.player && !self.player.isPlaying) {
            [self.player play];
        }
    });
}

- (void)stop
{
    het_dispatch_async_main(^{
        if (self.player && self.player.isPlaying) {
            [self.player stop];
        }
    });
}

- (void)destory
{
    if (self.player) {
        if (self.player.isPlaying) {
            [self.player stop];
        }
        _player.delegate = nil;
        _player = nil;
        self.delegate = nil;
    }
    self.voiceFile = nil;
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    het_dispatch_async_main(^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(voicePlayer:successfully:)]) {
            [self.delegate voicePlayer:self successfully:flag];
        }
    });
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error
{
    het_dispatch_async_main(^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(voicePlayer:error:)]) {
            [self.delegate voicePlayer:self error:error];
        }
    });
}

@end
