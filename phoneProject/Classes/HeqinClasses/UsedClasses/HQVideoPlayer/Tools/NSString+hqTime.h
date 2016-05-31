//
//  NSString+hqTime.h
//  AudioPlayer
//
//  Created by ClaudeLi on 16/4/12.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface NSString (hqTime)

// 播放器_时间转换
+ (NSString *)hqConvertTime:(CGFloat)second;

@end
