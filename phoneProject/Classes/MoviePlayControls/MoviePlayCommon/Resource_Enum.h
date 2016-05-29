//
//  Resource_Enum.h
//  GetArts
//
//  Created by mac on 14-11-13.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark -分享枚举类型
typedef  enum
{
    //微博
    GAShareMsgTypeWeibo = 1<<1,
    //豆瓣
    GAShareMsgTypeDouban = 1<<2,
    //腾讯QQ
    GAShareMsgTypeQQ = 1<<3,
    //微信
    GAShareMsgTypeWeiXin = 1<<4,
    //人人
    GAShareMsgTypeRenRen = 1<<5
} GAShareMsgType;

typedef  enum
{
    //链接形式分享
    GAshareLink = 1<<1,
    //视频形式分享
    GAShareVideo = 1<<2,
    //文字形式分享
    GAShareText = 1<<3,
    //图片形式分享
    GAShareImage = 1<<4,
    //通知形式(目前只有人人)
    GAShareNotice = 1<<5,
    //多张图片上传(目前只有新浪微博)
    GAShareMutImage = 1<<6,
    
} GAshareType;

#pragma mark - 方向
enum{
    portrait,
    left,
    right,
    upsidedown
}Direction;

