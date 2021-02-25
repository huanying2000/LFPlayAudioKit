//
//  LFPlayAudioKit.h
//  LFPlayAudio
//
//  Created by Farben on 2020/7/30.
//  Copyright © 2020 Farben. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

//当前时间和进度的回调
typedef void(^ProgressTimeBlock)(NSString *currentTime,CGFloat progress);
//总时间
typedef void(^TotalTimeBlock)(NSString *totalTime);


//播放器的状态
//因为UI界面需要加载状态显示 所以需要提供加载状态
typedef NS_ENUM(NSInteger,LFPlayerState) {
    //未知(比如都没有开始播放音视频资源)
    LFPlayerStateUnknown = 0,
    //正在加载
    LFPlayerStateLoading = 1,
    //正在播放
    LFPlayerStatePlaying = 2,
    //停止
    LFPlayerStateStopped = 3,
    //暂停
    LFPlayerStatePause = 4,
    //失败(比如没有网络缓存失败 地址找不到)
    LFPlayerStateFailed = 5
};

//当前播放状态的回调
typedef void(^PlayerStateBlock)(LFPlayerState state,NSURL *url);

@interface LFPlayAudioKit : NSObject

+ (instancetype) shared;

//播放器
@property (nonatomic,strong,nullable) AVPlayer *player;
//播放音频 上一首 下一首 把对应的URL传进来即可
- (void) playerWithUrl:(NSURL *)url;
//暂停播放
- (void)pause;
//继续播放
- (void)resume;
//停止播放
- (void)stop;
//快进 timeDiffer快进的时间
- (void)seekWithTimeDiffer:(NSTimeInterval)timeDiffer;
//指定播放进度
- (void)seekWithTimeProgress:(float)progress finish:(void(^)(void))finish;

//是否静音
@property (nonatomic,assign) BOOL muted;

//音量调整
@property (nonatomic,assign) float volume;
//倍速值
@property (nonatomic,assign) float rate;
//总时长
@property (nonatomic,assign,readonly) NSTimeInterval totalTime;
//格式化后的 总时间00:00
@property (nonatomic,strong,readonly) NSString *totalTimeFormat;
//当前播放的时长
@property (nonatomic,assign,readonly) NSTimeInterval currentTime;
//格式化后的当前时间
@property (nonatomic,strong,readonly) NSString *currentTimeFormat;
//当前播放的url地址
@property (nonatomic,strong,readonly) NSURL *url;
//当前播放的进度
@property (nonatomic,assign,readonly) float progress;
//当前已经缓冲的进度
@property (nonatomic,assign,readonly) float loadDataProgress;
//播放的状态
@property (nonatomic,assign,readonly) LFPlayerState state;
//播放的界面
@property (nonatomic,strong) AVPlayerLayer *playerLayer;
//返回
@property (nonatomic,strong) ProgressTimeBlock progressTimeBlock;
//返回总的时间
@property (nonatomic,strong) TotalTimeBlock totalTimeBlock;
//播放状态的回调
@property (nonatomic,strong) PlayerStateBlock playerStateBlock;


@end

NS_ASSUME_NONNULL_END
