//
//  GAImageManager.m
//  GetArts
//
//  Created by yoever on 14-7-14.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import "GAImageManager.h"

@implementation GAImageManager

//导航栏返回键
+(UIImage *)moviePlayGetBackArrowImage
{
    return [UIImage imageNamed:@"systemBackArrow"];
}
//导航栏返回键高亮状态
+(UIImage *)moviePlayGetBackArrowImageHighLight
{
    return [UIImage imageNamed:@"systemBackArrowHighLight"];
}
//概视频播放全屏按钮
+(UIImage *)moviePlayGetFullScreenButtonImage
{
    return [UIImage imageNamed:@"zhankai"];
}
//概视频全屏缩小
+(UIImage *)moviePlayGetFullScreenPickupButtonImage
{
    return [UIImage imageNamed:@"shouqi"];
}
 

+ (UIImage *)moviePlayShengyingImg {
    return [UIImage imageNamed:@"shengying"];
}

+ (UIImage *)moviePlayJingyinImg {
    return [UIImage imageNamed:@"jingyin"];
}

+ (UIImage *)moviePlayJinduImg {
    return [UIImage imageNamed:@"jindu"];
}

+ (UIImage *)moviePlaySuodingImg {
    return [UIImage imageNamed:@"suoding"];
}

+ (UIImage *)moviePlaySuopingImg {
    return [UIImage imageNamed:@"suoping"];
}

+ (UIImage *)moviePlayZhuanfaImg {
    return [UIImage imageNamed:@"zhuanfa"];
}

+ (UIImage *)moviePlayStopImg {
    return [UIImage imageNamed:@"stop"];
}

+ (UIImage *)moviePlayPlayImg {
    return [UIImage imageNamed:@"play"];
}

+ (UIImage *)moviePlayAridrImg {
    return [UIImage imageNamed:@"aridr"];
}

// Tool
+(UIImage *)moviePlayToolButtonBlack
{
    return [UIImage imageNamed:@"tb_lahei"];
}
+(UIImage *)moviePlayToolButtonAttend
{
    return [UIImage imageNamed:@"tb_jiaguanzhg"];
}
+(UIImage *)moviePlayToolButtonPrivate
{
    return [UIImage imageNamed:@"tb_pinglun"];
}

@end