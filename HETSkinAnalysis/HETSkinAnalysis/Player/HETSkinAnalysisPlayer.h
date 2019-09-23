//
//  HETSkinAnalysisPlayer.h
//  HETSkinAnalysis
//
//  Created by 远征 马 on 2019/7/1.
//  Copyright © 2019 马远征. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^HETVoicePlayerPlayResultBlock)(BOOL flag, NSError *error);
/**
 语音播报
 */
@interface HETSkinAnalysisPlayer : NSObject
@property (nonatomic, strong, readonly) AVAudioPlayer *audoPlayer;
@property (nonatomic, readonly, getter=isPlaying) BOOL playing;
@property (nonatomic, assign) NSTimeInterval playDelyTime;
+ (instancetype)defaultPlayer;

/**
 语音播放
 上次播放的语音文件和即将播放的不同则新语音文件延时300ms开始播放。
 同样的语音文件，待上一个语音播放完成3s后开始播放
 
 @param voiceFile 语音文件路径
 @param retHandler 播放结果回调
 */
- (void)playVoice:(NSString*)voiceFile result:(HETVoicePlayerPlayResultBlock)retHandler;

/**
 语音播放
 如果允许延时播放则：
 上次播放的语音文件和即将播放的不同则新语音文件延时300ms开始播放。
 同样的语音文件，待上一个语音播放完成3s后开始播放
 
 @param voiceFile 语音文件路径
 @param canDelay 播放延时
 @param retHandler 播放结果回调
 */
- (void)playVoice:(NSString*)voiceFile shouldDelay:(BOOL)canDelay result:(HETVoicePlayerPlayResultBlock)retHandler;

/**
 停止当前语音播放
 */
- (void)stop;

/**
 暂停当前语音播放，并于15s后自动恢复播放
 暂停播放并不影响拍照快照和拍照成功语音
 */
- (void)pause;

/**
 暂停当前语音播放，并于4s后自动恢复播放
 恢复播放，当前语音将能够重新触发播放操作
 */
- (void)resume;

/**
 销毁播放器
 */
- (void)destoryPlayer;
@end
