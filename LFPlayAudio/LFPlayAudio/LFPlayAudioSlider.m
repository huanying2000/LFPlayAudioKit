//
//  LFPlayAudioSlider.m
//  LFPlayAudio
//
//  Created by Farben on 2020/7/30.
//  Copyright © 2020 Farben. All rights reserved.
//

#import "LFPlayAudioSlider.h"

@implementation LFPlayAudioSlider

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void) setup {
    //当值可以改变时 滑块可以滑动到的最小位置的值 默认0.0
    self.minimumValue = 0.0;
    //当值改变时 滑块可以滑动到最大位置的值 默认为1.0
    self.maximumValue = 1.0;
    //当前值
    self.value = 0;
    //小于滑块当前值滑块条的颜色 默认为蓝色
    self.minimumTrackTintColor = [UIColor whiteColor];
    //大于滑块当前值滑块条的颜色 默认为白色
    self.maximumTrackTintColor = [UIColor yellowColor];
    //滑块处最大值设置的图片
    UIImage *thumbNormalImage = [self originImage:[UIImage imageNamed:@"fm_audio_thumbImage"] scaleToSize:CGSizeMake(14, 14)];
    UIImage *thumbHighlightedImage = [self originImage:[UIImage imageNamed:@"fm_audio_thumbImage"] scaleToSize:CGSizeMake(28, 28)];
    //通常状态下
    [self setThumbImage:thumbNormalImage forState:UIControlStateNormal];
    //滑动状态下
    [self setThumbImage:thumbHighlightedImage forState:UIControlStateHighlighted];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTapGesture:)];
    [self addGestureRecognizer:tapGesture];
}



//对原来的图片的大小进行处理
- (UIImage *)originImage:(UIImage *)image scaleToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaleImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaleImage;
}

//两边有空隙 修改方法
- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    //w 和 h是滑块可触摸的范围的大小 跟通过图片改变的滑块大小应该一致
    rect.origin.x = rect.origin.x - 5;
    rect.size.width = rect.size.width + 10;
    return CGRectInset([super thumbRectForBounds:bounds trackRect:rect value:value], 5, 5);
}

- (void) actionTapGesture:(UITapGestureRecognizer *)sender {
    CGPoint touchPoint = [sender locationInView:self];
    CGFloat value = (self.maximumValue - self.minimumValue) * (touchPoint.x / self.frame.size.width);
    [self setValue:value animated:YES];
}
@end
