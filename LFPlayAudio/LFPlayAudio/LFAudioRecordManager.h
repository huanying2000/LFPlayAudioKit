//
//  LFAudioRecordManager.h
//  LFPlayAudio
//
//  Created by Farben on 2020/7/31.
//  Copyright © 2020 Farben. All rights reserved.
//  //录音控件

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LFAudioRecordManagerDelegate <NSObject>

//创建录音器失败
- (void) recordManagerDidFailCreateRecorder;
//结束录音 path 录音保存的路径
- (void) recordManagerDidFinishRecording:(NSString *)path;
//录音时间回调
- (void) recordManager:(NSTimeInterval)recordTime;

@end

@interface LFAudioRecordManager : NSObject
//附件名 时间戳+100以内的随机数 .mp3
@property (nonatomic,copy) NSString *accessoryName;
//转码前录音文件的文件名
@property (nonatomic,copy) NSString *recordName;

@property (nonatomic,weak) id <LFAudioRecordManagerDelegate>delegate;

//开始录音
- (BOOL) startRecording;

//停止录音
- (void) stopRecording;

//是否正在录音
@property (nonatomic,assign) BOOL isRecording;




@end

NS_ASSUME_NONNULL_END
