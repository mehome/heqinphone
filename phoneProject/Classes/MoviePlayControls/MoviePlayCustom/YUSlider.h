//
//  YUSlider.h
//  YUSlider
//
//  Created by Yoever on 14-5-29.
//  Copyright (c) 2014年 Yoever. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface YUSlider : UIView


@property(assign,nonatomic)float value;
@property(assign,nonatomic)BOOL  isDragging;
//初始化的时候传递是否竖向参数
-(id)initWithFrame:(CGRect)frame withVertical:(BOOL)vertical;
//进度条高度
-(void)setProgressThick:(float)height;
//进度图片
-(void)setThumbImage:(UIImage*)image;
//最大值的图片(Right)
-(void)setMaxImage:(UIImage*)image;
//最小值的图片(Left)
-(void)setMinImage:(UIImage*)image;
//进度条最大值填充颜色
-(void)setMaxTintColor:(UIColor*)color;
//进度条最小值填充颜色
-(void)setMinTintColor:(UIColor*)color;
//进度填充颜色
-(void)setThumbTintColor:(UIColor*)color;
//最大值
-(void)setMaxValue:(float)newValue;
//最小值
-(void)setMinValue:(float)newValue;
//设置默认值
-(void)setCurrentValue:(float)newValue;
//添加方法
-(void)addTarget:(id)target andSelector:(SEL)selector;
-(void) setNewFrame:(CGRect)rect;
@end
