//
//  Resource_Size.h
//  GetArts
//
//  Created by mac on 14-11-13.
//  Copyright (c) 2014年 mac. All rights reserved.
//
#import <Foundation/Foundation.h>

#pragma mark - 宏
#pragma mark- -----尺寸相关----
//屏幕高度
#define SCREEN_HEIGHT ([[UIScreen mainScreen]bounds].size.height)
//屏幕宽度
#define SCREEN_WIDTH ([[UIScreen mainScreen]bounds].size.width)
//屏幕半高
#define HALF_SCREEN_WIDTH SCREEN_WIDTH/2
//屏幕半宽
#define HALF_SCREEN_HEIGHT SCREEN_HEIGHT/2
//屏幕尺寸
#define SCREEN_SIZE [[UIScreen mainScreen]bounds].size
//TABBAR高度
#define TABBAR_HEIGHT  44.0f
//导航栏高度
#define NAVGATION_HEIGHT 64
//状态栏高度
#define StatusBar_Height 20.0f

#pragma mark - 函数
#pragma mark - 计算字符串大小
static inline CGSize sizeWithFont(NSString* string,UIFont* font)
{
    return [string sizeWithAttributes: @{NSFontAttributeName:font}];
}
#pragma mark - 计算字符串大小
static inline CGSize sizeWithFont3(NSString* string,UIFont* font,CGSize contrainsSize)
{
    return [string boundingRectWithSize:contrainsSize options:NSStringDrawingUsesLineFragmentOrigin
                             attributes:@{NSFontAttributeName:font} context:nil].size;
}

//
inline static float getHeightFromAttributes(NSString* string,UILabel* label,CGFloat maxWidth){
    if (!maxWidth || maxWidth<=0 || !string || !label) {
        return 0;
    }
    label.lineBreakMode = NSLineBreakByCharWrapping;
    int lineNumber = 1;
    float width = 0;
    
    for (int index = 0; index<[string length]; index++) {
        NSString *str = [string substringWithRange:NSMakeRange(index,1)];
        CGSize size = sizeWithFont(str,label.font);
        width += size.width;
        if (width>maxWidth) {
            lineNumber ++;
            width = size.width;
        }if ([str isEqualToString:@"\n"]&&width<maxWidth) {
            lineNumber ++;
            width = 0;
        }
    }
    label.numberOfLines = lineNumber;
    float height = sizeWithFont(string,label.font).height * lineNumber;
    height = (height < 16) ? 16 : height;
    return height;
}

#pragma mark -
inline static float getWidthFromAttributes(NSString* string,UILabel* label,CGFloat maxWidth){
    CGSize size = sizeWithFont(string,label.font); //iOS7已经弃用这个方法
    if (size.width>maxWidth) {
        return maxWidth;
    }
    return size.width;
}
