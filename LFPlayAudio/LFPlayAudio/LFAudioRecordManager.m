//
//  LFAudioRecordManager.m
//  LFPlayAudio
//
//  Created by Farben on 2020/7/31.
//  Copyright © 2020 Farben. All rights reserved.
//

#import "LFAudioRecordManager.h"
#import <AVFoundation/AVFoundation.h>

#define voiceDirectory

@interface LFAudioRecordManager ()<AVAudioRecorderDelegate>
//转码后 的音频路径
@property (nonatomic,copy) NSString *audioPath;
@property (nonatomic,assign) NSInteger recordTime;
@property (nonatomic,strong) NSTimer *timer;
@property (nonatomic,strong) AVAudioRecorder *recorder;

@end

@implementation LFAudioRecordManager

- (AVAudioRecorder *)recorder {
    NSString *fileName = [NSString stringWithFormat:@"%@.caf",self.accessoryName];
    NSURL *url = [NSURL fileURLWithPath:[self getRecordPath:fileName]];
    NSDictionary *settings = @{AVNumberOfChannelsKey:@2,AVSampleRateKey:@44100};
    NSError *error;
    if (!_recorder) {
        _recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
        _recorder.delegate = self;
    }
    if (error != nil) {
        //录音机初始化失败
        if (self.delegate && [self.delegate respondsToSelector:@selector(recordManagerDidFailCreateRecorder)]) {
            [self.delegate recordManagerDidFailCreateRecorder];
        }
        NSLog(@"创建录音机错误  %@",error);
    }
    return _recorder;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.recordTime = 0;
       NSInteger timeInterval = (int)[[NSDate date] timeIntervalSince1970] + (arc4random() % 100);
        self.accessoryName = [NSString stringWithFormat:@"%ld",timeInterval];
        self.recordName = [NSString stringWithFormat:@"%@.caf",self.accessoryName];
    }
    return self;
}

- (BOOL) startRecording {
    if (self.timer) {
        [self.timer invalidate];
    }
    //录音模式
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
    if ([self.recorder record]) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateRecordTime:) userInfo:nil repeats:YES];
        return YES;
    }else {
        return NO;
    }
}

//停止录音
- (void)stopRecording {
    [self.timer invalidate];
    [self.recorder stop];
}

- (BOOL)isRecording {
    return self.recorder.isRecording;
}

- (void) updateRecordTime:(NSTimer *)sender {
    if (![self.recorder isRecording]) {
        [self.timer invalidate];
    }
    if (self.recorder != nil) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(recordManager:)]) {
            [self.delegate recordManager:self.recorder.currentTime];
        }
    }
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    [self.timer invalidate];
    if (flag) {
        self.audioPath = recorder.url.path;
    }else {
        self.audioPath = nil;
    }
    NSError *error;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:&error];
    if (!error) {
        self.recordTime = (int)player.duration;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordManagerDidFinishRecording:)]) {
        [self.delegate recordManagerDidFinishRecording:self.audioPath];
    }
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    [self.timer invalidate];
    self.audioPath = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordManagerDidFinishRecording:)]) {
        [self.delegate recordManagerDidFinishRecording:self.audioPath];
    }
}

//获取录制音频的存储路径
- (NSString *)getRecordPath:(NSString *)fileName {
    NSString *bundleId = [NSBundle mainBundle].bundleIdentifier ? [NSBundle mainBundle].bundleIdentifier : @"no.bundle.id";
    NSString *caches_audio = [NSString stringWithFormat:@"%@/Library/Caches/%@/audio",NSHomeDirectory(),bundleId];
    NSString *path = [NSString stringWithFormat:@"%@/post/voice",caches_audio];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [NSString stringWithFormat:@"%@/",fileName];
}

@end
