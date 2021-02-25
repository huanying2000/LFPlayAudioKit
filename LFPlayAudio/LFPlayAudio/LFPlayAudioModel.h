//
//  LFPlayAudioModel.h
//  LFPlayAudio
//
//  Created by Farben on 2020/7/30.
//  Copyright © 2020 Farben. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LFPlayAudioModel : NSObject

@property (nonatomic,strong) NSString *audioUrl;

@property (nonatomic,strong) NSString *audioTitle;

@property (nonatomic,strong) NSString *audioImageUrl;

@property (nonatomic,strong) NSString *subTitle;

@end

NS_ASSUME_NONNULL_END
