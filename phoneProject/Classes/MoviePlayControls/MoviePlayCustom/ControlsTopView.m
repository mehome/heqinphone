//
//  ControlsTopView.m
//  GetArtsVideoPlayer
//
//  Created by Yoever on 14-5-12.
//  Copyright (c) 2014年 Yoever. All rights reserved.
//

#import "ControlsTopView.h"
#import "GAImageManager.h"

@interface ControlsTopView ()
{
    UIView          *grayBackGround;
}
@end

@implementation ControlsTopView

@synthesize delegate,buttonQuit,titleLabel,buttonVideoQuality,buttonAirPlay,buttonTransmit;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        grayBackGround = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        grayBackGround.backgroundColor = [UIColor blackColor];
        grayBackGround.alpha = 0.5f;
        [self addSubview:grayBackGround];
        [self initBasicControlItems];
    }
    return self;
}
-(void)initBasicControlItems
{
    buttonQuit = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonQuit setFrame:CGRectMake(10, self.frame.size.height-30, 40, 20)];
    [buttonQuit setTitle:@"返回" forState:UIControlStateNormal];
    [buttonQuit addTarget:self action:@selector(quitAction) forControlEvents:UIControlEventTouchUpInside];
    
    titleLabel = [[UILabel alloc]initWithFrame:CGRectMake((self.frame.size.width-280)/2, self.frame.size.height-30, 280, 20)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:20];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"测试视频的title在这儿";
    
    buttonVideoQuality = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonVideoQuality setFrame:CGRectMake(self.frame.size.width-130, self.frame.size.height-30, 30, 20)];
    buttonVideoQuality.titleLabel.font = [UIFont systemFontOfSize:12];
    [buttonVideoQuality setTitle:@"高清" forState:UIControlStateNormal];
    [buttonVideoQuality addTarget:self action:@selector(videoQualityAction) forControlEvents:UIControlEventTouchUpInside];
    [buttonVideoQuality.layer setCornerRadius:4];
    [buttonVideoQuality.layer setBorderColor:[UIColor whiteColor].CGColor];
    [buttonVideoQuality.layer setBorderWidth:1.0f];
    [buttonVideoQuality.layer setMasksToBounds:YES];
    [buttonVideoQuality setClipsToBounds:YES];
    
    buttonAirPlay = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonAirPlay setFrame:CGRectMake(self.frame.size.width-80, self.frame.size.height-35, 30, 30)];
    [buttonAirPlay setImage:[GAImageManager moviePlayAridrImg] forState:UIControlStateNormal];
    [buttonAirPlay addTarget:self action:@selector(airPlayAction) forControlEvents:UIControlEventTouchUpInside];
    
    buttonTransmit = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonTransmit setFrame:CGRectMake(self.frame.size.width-35, self.frame.size.height-35, 30, 30)];
    [buttonTransmit setImage:[GAImageManager moviePlayZhuanfaImg] forState:UIControlStateNormal];
    [buttonTransmit addTarget:self action:@selector(transmitAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:buttonQuit];
    [self addSubview:titleLabel];
//    [self addSubview:buttonVideoQuality];
//    [self addSubview:buttonAirPlay];
    [self addSubview:buttonTransmit];
}
-(void)quitAction
{
    if (delegate && [delegate respondsToSelector:@selector(topQuitAction)]) {
        [delegate topQuitAction];
    }
}
-(void)videoQualityAction
{
    if (delegate && [delegate respondsToSelector:@selector(topVideoQualityAction)]) {
        [delegate topVideoQualityAction];
    }
}
-(void)airPlayAction
{
    if (delegate && [delegate respondsToSelector:@selector(topAirPlayAction)]) {
        [delegate topAirPlayAction];
    }
}
-(void)transmitAction
{
    if (delegate && [delegate respondsToSelector:@selector(topTransmitAction)]) {
        [delegate topTransmitAction];
    }
}
-(void)setTitle:(NSString *)string
{
    titleLabel.text = string;
}
-(void)setVideoQualityButtonText:(NSString*)text
{
    [buttonVideoQuality setTitle:text forState:UIControlStateNormal];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
