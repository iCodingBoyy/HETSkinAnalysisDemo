//
//  HETVoicePlayer.h
//  HETSkinAnalysis
//
//  Created by 远征 马 on 2019/7/23.
//  Copyright © 2019 马远征. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class HETVoicePlayer;
@protocol HETVoicePlayerDelegate <NSObject>
- (void)voicePlayer:(HETVoicePlayer*)voicePlayer  successfully:(BOOL)flag;
- (void)voicePlayer:(HETVoicePlayer*)voicePlayer  error:(NSError *)error;
@end

@interface HETVoicePlayer : NSObject
@property (nonatomic, strong, readonly) AVAudioPlayer *player;
@property (nonatomic, readonly, getter=isPlaying) BOOL playing;
@property (nonatomic,  weak) id<HETVoicePlayerDelegate> delegate;
- (void)play:(NSString*)vocieFile;
- (void)stop;
- (void)destory;
@end

