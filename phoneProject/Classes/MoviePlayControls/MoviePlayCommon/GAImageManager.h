//
//  GAImageManager.h
//  GetArts
//
//  Created by yoever on 14-7-14.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GAImageManager : NSObject

//导航栏返回箭头
+(UIImage *)moviePlayGetBackArrowImage;
//导航栏返回键高亮状态
+(UIImage *)moviePlayGetBackArrowImageHighLight;
//全屏按钮
+(UIImage *)moviePlayGetFullScreenButtonImage;
//收起全屏
+(UIImage *)moviePlayGetFullScreenPickupButtonImage;

+(UIImage *)moviePlayToolButtonBlack;
+(UIImage *)moviePlayToolButtonAttend;
+(UIImage *)moviePlayToolButtonPrivate;


// 声音
+ (UIImage *)moviePlayShengyingImg;
// 静音
+ (UIImage *)moviePlayJingyinImg;

// 进度
+ (UIImage *)moviePlayJinduImg;
// 锁定
+ (UIImage *)moviePlaySuodingImg;
// 锁屏
+ (UIImage *)moviePlaySuopingImg;
// 转发
+ (UIImage *)moviePlayZhuanfaImg;

// 停止
+ (UIImage *)moviePlayStopImg;
// 播放
+ (UIImage *)moviePlayPlayImg;
// Air play
+ (UIImage *)moviePlayAridrImg;

@end
