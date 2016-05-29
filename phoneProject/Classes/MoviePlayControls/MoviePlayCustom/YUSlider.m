//
//  YUSlider.m
//  YUSlider
//
//  Created by Yoever on 14-5-29.
//  Copyright (c) 2014年 Yoever. All rights reserved.
//

#import "YUSlider.h"

#define thumbWidth 20
#define thumbHeight 20

@interface YUSlider ()
{
    UIView      *minView;
    UIView      *maxView;
    UIView      *thumbView;
    
    id          userTarget;
    SEL         userSelector;
    float       maxValue;
    float       minValue;
    BOOL        isVertical;
    BOOL        correctTouch;
    CGPoint     center;
}
@end

@implementation YUSlider

@synthesize value,isDragging;

-(id)initWithFrame:(CGRect)frame withVertical:(BOOL)vertical
{
    self = [super initWithFrame:frame];
    if (self) {
        isVertical = vertical;
        center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        self.backgroundColor = [UIColor clearColor];
        [self initDefaultSubViewsAndValue];
        [self addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"frame"]) {
        
    }else if ([keyPath isEqualToString:@"value"]){
        
    }
    [self refreshSubViewsAfterNewFrame];
}

//初始化视图
-(void)initDefaultSubViewsAndValue
{
    value = 0;
    maxValue = 1;
    minValue = 0;
    
    maxView = [[UIView alloc]initWithFrame:CGRectMake(0, center.y-1, self.frame.size.width, 2)];
    maxView.backgroundColor = [UIColor orangeColor];
    
    minView = [[UIView alloc]initWithFrame:CGRectMake(0, center.y-1, 1, 2)];
    minView.backgroundColor = [UIColor blueColor];
    
    thumbView = [[UIView alloc]initWithFrame:CGRectMake(0, center.y-thumbHeight/2, thumbWidth, thumbHeight)];
    [thumbView.layer setCornerRadius:thumbWidth/2];
    thumbView.backgroundColor = [UIColor magentaColor];
    [thumbView setClipsToBounds:YES];
    
    if (isVertical) {
        [self addSubview:minView];
        [self addSubview:maxView];
        [self addSubview:thumbView];
    }else{
        [self addSubview:maxView];
        [self addSubview:minView];
        [self addSubview:thumbView];
    }
    [self refreshSubViewsAfterNewFrame];
}

/************根据当前的value值来修改坐标***************/
-(void)refreshSubViewsAfterNewFrame
{
    if (isVertical) {
        float newValue = (1-(self.value-minValue)/(maxValue-minValue))*self.frame.size.height;
        minView.frame = CGRectMake((self.frame.size.width-minView.frame.size.width)*0.5, 0, minView.frame.size.width, self.frame.size.height);
        maxView.frame = CGRectMake((self.frame.size.width-maxView.frame.size.width)*0.5, 0, maxView.frame.size.width,newValue);
        thumbView.frame = CGRectMake((self.frame.size.width-thumbWidth)*0.5, newValue-thumbHeight/2, thumbWidth, thumbHeight);
    }else{
        float newValue = ((self.value-minValue)/(maxValue-minValue))*self.frame.size.width;
        minView.frame = CGRectMake(0, (self.frame.size.height-minView.frame.size.height)*0.5, newValue, minView.frame.size.height);
        maxView.frame = CGRectMake(0, (self.frame.size.height-maxView.frame.size.height)*0.5, self.frame.size.width, maxView.frame.size.height);
        thumbView.frame = CGRectMake(newValue-thumbWidth/2, (self.frame.size.height-thumbView.frame.size.height)*0.5, thumbWidth, thumbHeight);
    }
}

//滑动滑块到特定位置
-(void)slideToPosition:(float)position
{
    if (isVertical) {
        value = (maxValue-minValue)*((self.frame.size.height-position)/self.frame.size.height)+minValue;
    }else{
        value = (maxValue-minValue)*(position/self.frame.size.width)+minValue;
    }
    [self refreshSubViewsAfterNewFrame];
}

#pragma mark - Touch时间处理
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject]locationInView:self];
    float thumbDistanceX = floorf((thumbView.center.x-point.x));
    float thumbDistanceY = floorf((thumbView.center.y-point.y));
    if (thumbDistanceX<=thumbWidth && thumbDistanceY<=thumbHeight) {
        correctTouch = YES;
    }else{
        correctTouch = NO;
    }
    isDragging = YES;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject]locationInView:self];
    
    if (isVertical) {
        if (correctTouch&&point.y>=thumbHeight/2&&point.y<=self.frame.size.height-thumbHeight/2) {
            [self slideToPosition:point.y];
        }
    }else{
        if (correctTouch&&point.x>=thumbWidth/2&&point.x<=self.frame.size.width-thumbWidth/2) {
            [self slideToPosition:point.x];
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (&correctTouch&&userSelector&&userTarget) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [userTarget performSelector:userSelector withObject:self];
#pragma clang diagnostic pop
    }
    correctTouch = NO;
    isDragging = NO;
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    isDragging = NO;
    correctTouch = NO;
}

#pragma mark - 设置相关参数
//进度条高度
-(void)setProgressThick:(float)height
{
    if (isVertical) {
        if (height>self.frame.size.width) {
            NSLog(@"YUSlider:进度条太宽");
            return;
        }
        CGRect frame = maxView.frame;
        CGRect rect = minView.frame;
        frame.size.width = height;
        rect.size.width = height;
        maxView.frame = frame;
        minView.frame = rect;
    }else{
        if (height>self.frame.size.height) {
            NSLog(@"YUSlider:进度条太高");
            return;
        }
        CGRect frame = maxView.frame;
        CGRect rect = minView.frame;
        frame.size.height = height;
        rect.size.height = height;
        maxView.frame = frame;
        minView.frame = rect;
    }
    [self refreshSubViewsAfterNewFrame];
}

//进度图片
-(void)setThumbImage:(UIImage*)image
{
    if (image) {
        [thumbView.layer setCornerRadius:0];
        thumbView.backgroundColor = [UIColor clearColor];
        UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
        imageView.frame = CGRectMake(0, 0, thumbWidth, thumbHeight);
        [thumbView addSubview:imageView];
    }
}

//最大值的图片(Right)
-(void)setMaxImage:(UIImage*)image
{
    if (image) {
        maxView.backgroundColor = [UIColor clearColor];
        UIImageView *imageView = nil;
        imageView = [[UIImageView alloc]initWithImage:image];
        if (isVertical) {
            imageView.frame = CGRectMake(0, 0, maxView.frame.size.width, self.frame.size.height);
        }else{
            imageView.frame = CGRectMake(0, 0, self.frame.size.width, maxView.frame.size.height);
        }
        [maxView addSubview:imageView];
    }
}

//最小值的图片(Left)
-(void)setMinImage:(UIImage*)image
{
    if (image) {
        minView.backgroundColor = [UIColor clearColor];
        UIImageView *imageView = nil;
        imageView = [[UIImageView alloc]initWithImage:image];
        if (isVertical) {
            imageView.frame = CGRectMake(0, 0, minView.frame.size.width, self.frame.size.height);
        }else{
            imageView.frame = CGRectMake(0, 0, self.frame.size.width, minView.frame.size.height);
        }
        [maxView addSubview:minView];
    }
}

//进度条最大值填充颜色
-(void)setMaxTintColor:(UIColor*)color
{
    if (color) {
        maxView.backgroundColor = color;
    }
    
}

//进度条最小值填充颜色
-(void)setMinTintColor:(UIColor*)color
{
    if (color) {
        minView.backgroundColor = color;
    }
}

//进度填充颜色
-(void)setThumbTintColor:(UIColor*)color
{
    if (color) {
        thumbView.backgroundColor = color;
    }
}

//最大值
-(void)setMaxValue:(float)newValue
{
    if (newValue>0) {
        maxValue=newValue;
    }
}
//最小值
-(void)setMinValue:(float)newValue
{
    if (newValue>0) {
        minValue=newValue;
    }
}

//设置默认值
-(void)setCurrentValue:(float)newValue
{
    if(newValue){
        self.value = newValue;
        [self refreshSubViewsAfterNewFrame];
    }
}

//添加方法
-(void)addTarget:(id)target andSelector:(SEL)selector
{
    if (target) {
        userTarget = target;
    }
    if (selector) {
        userSelector = selector;
    }
}

-(void) setNewFrame:(CGRect)rect
{
    self.frame = rect;
}

@end
