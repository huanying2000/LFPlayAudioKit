//
//  LFPlayAudioKit.m
//  LFPlayAudio
//
//  Created by Farben on 2020/7/30.
//  Copyright © 2020 Farben. All rights reserved.
//

#import "LFPlayAudioKit.h"

@interface LFPlayAudioKit () {
    // 用户是否选择了手动暂停
    BOOL isUserPause;
}

@property (nonatomic, strong) id timeObserver;

@property (nonatomic,strong) AVPlayerItem *playerItem;

@end

@implementation LFPlayAudioKit

static id instance;

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

- (id)copy {
    return instance;
}

- (id)mutableCopy {
    return instance;
}

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

//播放视频
- (void) playerWithUrl:(NSURL *)url {
    //判断要播放的URL 与 之前播放的 url是否相等
    NSURL *currentUrl = [(AVURLAsset *)self.player.currentItem.asset URL];
    if ([url isEqual:currentUrl]) {
        if (self.state == LFPlayerStatePlaying) {
            return;
        }
        if (self.state == LFPlayerStatePause) {
            [self resume]; //继续播放
            return;
        }
        if (self.state == LFPlayerStateLoading) {
            return;
        }
        if (self.currentTime == self.totalTime) {
            //当前播放完成后 再次点击播放进度从0开始
            [self seekWithTimeProgress:0 finish:^{
                
            }];
        }
        [self resume];
        return;
    }
    if (self.player.currentItem) {
        [self removeObserver];
    }
    
    _url = url;
    //资源请求
    AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    //资源的组织(当资源的组织者告诉我们资源准备好了之后 我们再去播放)
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    self.playerItem = playerItem;
    //监听播放结束
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    //播放被打断
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playInterrupt) name:AVPlayerItemPlaybackStalledNotification object:nil];
    //给播放器资源的播放
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    //播放中的监听 更新播放进度
    __weak typeof(self)weakSelf = self;
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 30) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        if (weakSelf.progressTimeBlock) {
            weakSelf.progressTimeBlock(weakSelf.currentTimeFormat, weakSelf.progress);
        }
    }];
}

#pragma mark KVO 监听
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        if (status == AVPlayerItemStatusReadyToPlay) {
            //资源准备好了 可以进行播放
            if (self.totalTimeBlock) {
                self.totalTimeBlock(self.totalTimeFormat);
            }
            [self resume];
        }else {
            //状态未知
            self.state = LFPlayerStateFailed;
        }
    }else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]){
        BOOL pToKeepUp = [change[NSKeyValueChangeNewKey] boolValue];
        if (pToKeepUp) {
            //指有可缓冲好的资源去播放
            if (!isUserPause) {
                [self resume];
            }
        }else {
            //资源在准备中 也就是正在加载
            self.state = LFPlayerStateLoading;
        }
    }
}

//播放结束
- (void) playEnd {
    NSLog(@"播放结束");
    self.state = LFPlayerStateStopped;
}

//播放被打断
- (void) playInterrupt {
    NSLog(@"播放被打断");
    // 可能是来电话 或者 资源加载跟不上
    self.state = LFPlayerStateStopped;
}

#pragma mark 移除监听
- (void) removeObserver {
    // status
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    // playbackLikelyToKeepUp
    [self.player.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
}

//暂停播放
- (void) pause {
    [self.player pause];
    //手动暂停
    isUserPause = YES;
    //先判断播放器是否存在
    if (self.player) {
        self.state = LFPlayerStatePause;
    }
}

//继续播放
- (void) resume {
    [self.player play];
    isUserPause = NO;
    if (self.player && self.player.currentItem.playbackLikelyToKeepUp) {
        self.state = LFPlayerStatePlaying;
    }
}

//停止播放
- (void) stop {
    [self.player pause];
    if (self.player) {
        self.state = LFPlayerStateStopped;
    }
    self.player = nil;
}

//快进
- (void) seekWithTimeDiffer:(NSTimeInterval)timeDiffer {
    //当前音频资源的总时长
    NSTimeInterval totalSecond = [self totalTime];
    NSTimeInterval playTimeSecond = [self currentTime];
    playTimeSecond += timeDiffer;
    [self seekWithTimeProgress:(float)playTimeSecond / totalSecond finish:^{
        
    }];
}

//指定播放进度
- (void) seekWithTimeProgress:(float)progress finish:(void (^)(void))finish {
    if (progress < 0 || progress > 1) {
        return;
    }
    
    NSTimeInterval totalSecond = [self totalTime];
    NSTimeInterval playTimeSecond = totalSecond * progress;
    CMTime currentTime = CMTimeMake(playTimeSecond, 1);
    [self.player seekToTime:currentTime completionHandler:^(BOOL finished) {
        if (finished) {
            if (finish) {
                finish();
            }
        }
    }];
}

//倍速播放
- (void) setRate:(float)rate {
    [self.player setRate:rate];
}

-(float)rate {
    return self.player.rate;
}

//是否静音
- (void) setMuted:(BOOL)muted {
    self.player.muted = muted;
}

- (BOOL)muted {
    return self.player.muted;
}

//音量调整
- (void) setVolume:(float)volume {
    if (volume < 0 || volume > 1) {
           return;
    }
       
    if (volume > 0) {
        // 音量大于0,取消静音
        [self setMuted:NO];
    }
    self.player.volume = volume;
}

-(float)volume {
    return self.player.volume;
}

#pragma mark 播放器事件&数据提供
- (NSTimeInterval)totalTime {
    //1.当前音频资源的总时长
    CMTime totalTime = self.player.currentItem.duration;
    //2.资源总描述
    NSTimeInterval totalSecond = CMTimeGetSeconds(totalTime);
    if (isnan(totalSecond)) {
        return 0;
    }
    return totalSecond;
}

- (NSString *)totalTimeFormat {
     return [NSString stringWithFormat:@"%02d:%02d",(int)self.totalTime/60,(int)self.totalTime % 60];
}

- (NSTimeInterval)currentTime {
    CMTime playTime = self.player.currentItem.currentTime;
    NSTimeInterval playTimeSecond = CMTimeGetSeconds(playTime);
    if (isnan(playTimeSecond)) {
        return 0;
    }
    return playTimeSecond;
}

- (NSString *)currentTimeFormat {
    return [NSString stringWithFormat:@"%02d:%02d",(int)self.currentTime/60,(int)self.currentTime % 60];
}

- (float)progress {
    if (self.totalTime == 0) {
        return 0;
    }
    return self.currentTime / self.totalTime;
}

//缓存的时长
- (float)loadDataProgress {
    if (self.totalTime == 0) {
        return 0;
    }
    //获取加载的时间区间
    CMTimeRange timeRang = [[self.player.currentItem loadedTimeRanges].lastObject CMTimeRangeValue];
    //开始时间和缓存时间和
    CMTime loadTime = CMTimeAdd(timeRang.start, timeRang.duration);
    //转化成秒
    NSTimeInterval loadTimeSecond = CMTimeGetSeconds(loadTime);
    return loadTimeSecond / self.totalTime;
}

//播放的状态
- (void) setState:(LFPlayerState)state {
    _state = state;
    // 告诉外界现在的状态
    if (self.playerStateBlock) {
        self.playerStateBlock(_state, self.url);
    }
}

- (void) setUrl:(NSURL * _Nonnull)url {
    _url = url;
    if (self.url) {
        if (self.playerStateBlock) {
            self.playerStateBlock(self.state, self.url);
        }
    }
}

- (void)dealloc {
    [self removeObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
