//
//  Resource_Color.h
//  GetArts
//
//  Created by mac on 14-11-13.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma mark - 常用颜色值

#define GAIYICOLOR_G1 GetColorFromCSSHex(@"#00AECA")

#define GAIYICOLOR_G2 GetColorFromCSSHex(@"#6F9BA7")

#define GAIYICOLOR_B1 GetColorFromCSSHex(@"#F9F9F9")

#define GAIYICOLOR_L1 GetColorFromCSSHex(@"#E2E1E4")

#define GAIYICOLOR_L2 GetColorFromCSSHex(@"#C8C7CC")

#define GAIYICOLOR_F1 GetColorFromCSSHex(@"#999999")

#define GAIYICOLOR_F2 GetColorFromCSSHex(@"#555555")

#define GAIYICOLOR_F3 GetColorFromCSSHex(@"#333333")

#pragma mark - 函数
#pragma mark - 十进制颜色
static inline UIColor* COLOR(float r,float g,float b)

{
    return  [UIColor colorWithRed:r/255.f green:g/255.f blue:b/255.f alpha:1.f];
}
#pragma mark - 小数颜色
static inline UIColor* fCOLOR(float r,float g,float b)
{
    return [UIColor colorWithRed:r green:g blue:b alpha:1.f];
}
#pragma mark - 灰色十进制
static inline UIColor* GCOLOR(float r)
{
    return COLOR(r,r,r);
}
#pragma mark - 灰色小数
static inline UIColor* fGCOLOR(float r)
{
    return fCOLOR(r,r,r);
}

#pragma mark - 白色十进制透明度
static inline UIColor* WCOLOR2(float r,float alpha)
{
    return [UIColor colorWithWhite:r/255.f alpha:alpha];
}
#pragma mark - 白色小数透明度
static inline UIColor* fWCOLOR2(float r,float alpha)
{
    return [UIColor colorWithWhite:r alpha:alpha];
}
#pragma mark - 白色小数
static inline UIColor* fWCOLOR(float r)
{
    return fWCOLOR2(r,1.0);
}
#pragma mark - 白色十进制
static inline UIColor* WCOLOR(float r)
{
    return WCOLOR2(r,1.0);
}

#pragma mark- RGB颜色转换成十六进制颜色
inline static NSString* GetCSSHexFromColor(UIColor *color) {
    if (color == nil) {
        return nil;
    }
    NSString *strColor = nil;
    CGColorRef cgColor = [color CGColor];
    //int num = CGColorGetNumberOfComponents(cgColor);
    const CGFloat *colors = CGColorGetComponents(cgColor);//RGB
    int r = colors[0] * 255.0f;
    int g = colors[1] * 255.0f;
    int b = colors[2] * 255.0f;
    strColor = [NSString stringWithFormat:@"#%02x%02x%02x", r, g, b];//RGB
    return strColor;
}

#pragma mark- 十六进制颜色转换成RGB颜色
inline static UIColor* GetColorFromCSSHex(NSString *hexColor) { // #FF3300
    if (hexColor == nil || [hexColor isEqualToString:@""]) {
        return nil;
    }
    if ([hexColor length] != 7) {
        return nil;
    }
    unsigned int red = 255, green = 255, blue = 255;
    NSRange range;
    range.length = 2;
    range.location = 1;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&red];
    range.location = 3;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&green];
    range.location = 5;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&blue];
    return [UIColor colorWithRed:(float)(red/255.0f) green:(float)(green/255.0f) blue:(float)(blue/255.0f) alpha:1.0f];
}
