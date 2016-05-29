
//  ControlsBelowView.m
//  GetArtsVideoPlayer
//
//  Created by Yoever on 14-5-12.
//  Copyright (c) 2014年 Yoever. All rights reserved.
//

#import "ControlsBelowView.h"
#import "GAImageManager.h"
#import "Resource_Color.h"

@interface ControlsBelowView ()
{
    BOOL        isFullScreen;
    UIView      *grayBackGround;
}
@end

@implementation ControlsBelowView

@synthesize delegate,buttonPlayOrPause,labelCurrentTimes,sliderProgress,labelTotalTimes,buttonFullScreen,buttonLockScreen,isPlaying,isLocked,isQuanPing;

- (id)initWithFrame:(CGRect)frame isFullScreen:(BOOL)fullScreen
{
    self = [super initWithFrame:frame];
    if (self) {
        isFullScreen = fullScreen;
        grayBackGround = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        grayBackGround.backgroundColor = [UIColor blackColor];
        grayBackGround.alpha = 0.5f;
        [self addSubview:grayBackGround];
        [self initSubViews];
    }
    return self;
}

-(void)initSubViews
{
    if (isFullScreen) {
        isQuanPing = YES;
    }
    isPlaying = YES;
    
    buttonPlayOrPause = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonPlayOrPause.frame = CGRectMake(10, self.frame.size.height/2-15, 30, 30);
    [buttonPlayOrPause setImage:[GAImageManager moviePlayStopImg] forState:UIControlStateNormal];
    [buttonPlayOrPause addTarget:self action:@selector(playOrPauseButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    labelCurrentTimes = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(buttonPlayOrPause.frame), self.frame.size.height/2-10, 60, 20)];
    labelCurrentTimes .backgroundColor = [UIColor clearColor];
    labelCurrentTimes.textColor = GetColorFromCSSHex(@"#FFFFFF");
    labelCurrentTimes.textAlignment = NSTextAlignmentCenter;
    labelCurrentTimes.font = [UIFont systemFontOfSize:12];
    labelCurrentTimes.text = @"00:00";
    
    sliderProgress = [[YUSlider alloc]initWithFrame:CGRectMake(CGRectGetMaxX(labelCurrentTimes.frame), 0, [[UIScreen mainScreen]bounds].size.width-240, self.frame.size.height) withVertical:NO];
    [sliderProgress setMaxTintColor:GetColorFromCSSHex(@"#666666")];
    [sliderProgress setMinTintColor:GetColorFromCSSHex(@"#00AECE")];
    [sliderProgress setThumbImage:[GAImageManager moviePlayJinduImg]];
    [sliderProgress setProgressThick:4];
    [sliderProgress addTarget:self andSelector:@selector(sliderProgressAction:)];
    
    labelTotalTimes = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(sliderProgress.frame), self.frame.size.height/2-10, 60, 20)];
    labelTotalTimes .backgroundColor = [UIColor clearColor];
    labelTotalTimes.textColor = [UIColor whiteColor];
    labelTotalTimes.textAlignment = NSTextAlignmentCenter;
    labelTotalTimes.font = [UIFont systemFontOfSize:12];
    labelTotalTimes.text = @"00:00";
    
    UIImage *image = [GAImageManager moviePlayGetFullScreenButtonImage];
    if (isFullScreen) {
        image = [GAImageManager moviePlayGetFullScreenPickupButtonImage];
    }
    buttonFullScreen = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonFullScreen.frame = CGRectMake(self.frame.size.width-40, self.frame.size.height/2-15, 30, 30);
    [buttonFullScreen setImage:image forState:UIControlStateNormal];
    [buttonFullScreen addTarget:self action:@selector(fullScreenButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    buttonLockScreen = [UIButton buttonWithType:UIButtonTypeCustom];
    buttonLockScreen.frame = CGRectMake(self.frame.size.width-80, self.frame.size.height/2-15, 30, 30);
    [buttonLockScreen setImage:[GAImageManager moviePlaySuopingImg] forState:UIControlStateNormal];
    [buttonLockScreen addTarget:self action:@selector(lockScreenButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self changeSubViewsIsFullScreen:isFullScreen];
    
    [self addSubview:buttonPlayOrPause];
    [self addSubview:labelCurrentTimes];
    [self addSubview:sliderProgress];
    [self addSubview:labelTotalTimes];
    [self addSubview:buttonLockScreen];
//    [self addSubview:buttonFullScreen];     // 全屏按钮，暂时屏掉，还没有想好放在哪个位置，现在这个位置与声音的位置重合. --heqin
    
}
-(void)playOrPauseButtonAction
{
    isPlaying = !isPlaying;
    [self setVideoItemIsPlaying:isPlaying];
    
    if (delegate && [delegate respondsToSelector:@selector(belowPlayOrPauseAction)]) {
        [delegate belowPlayOrPauseAction];
    }
}

-(void)fullScreenButtonAction
{
    isFullScreen = !isFullScreen;
    if (isFullScreen) {
        [buttonFullScreen setImage:[GAImageManager moviePlayGetFullScreenPickupButtonImage]
                          forState:UIControlStateNormal];
    }else{
        [buttonFullScreen setImage:[GAImageManager moviePlayGetFullScreenButtonImage]
                          forState:UIControlStateNormal];
    }
    if (delegate && [delegate respondsToSelector:@selector(belowFullScreenAction)]) {
        [delegate belowFullScreenAction];
    }
}

-(void)lockScreenButtonAction
{
    isLocked = !isLocked;
    if (isLocked) {
        [buttonLockScreen setImage:[GAImageManager moviePlaySuodingImg] forState:UIControlStateNormal];
    }else{
        [buttonLockScreen setImage:[GAImageManager moviePlaySuopingImg] forState:UIControlStateNormal];
    }
    if (delegate && [delegate respondsToSelector:@selector(belowLockScreenAction)]) {
        [delegate belowLockScreenAction];
    }
}

-(void)sliderProgressAction:(YUSlider*)slider
{
    if (delegate && [delegate respondsToSelector:@selector(belowProgressSliderChangedValuePercent:)]) {
        [delegate belowProgressSliderChangedValuePercent:slider.value];
    }
}
-(void)changeSubViewsIsFullScreen:(BOOL)isFull
{
    if (!isFull) {
        buttonLockScreen.hidden = YES;
        [sliderProgress setNewFrame:CGRectMake(buttonPlayOrPause.frame.size.width+labelCurrentTimes.frame.size.width+10, 0, [[UIScreen mainScreen]bounds].size.width-2*(buttonPlayOrPause.frame.size.width+labelCurrentTimes.frame.size.width)-10, self.frame.size.height)];
        buttonFullScreen.frame = CGRectMake(self.frame.size.width-40, self.frame.size.height/2-15, buttonFullScreen.frame.size.width, buttonFullScreen.frame.size.height);
        [buttonFullScreen setImage:[GAImageManager moviePlayGetFullScreenButtonImage]
                          forState:UIControlStateNormal];
    }else
    {
        [sliderProgress setNewFrame:CGRectMake(CGRectGetMaxX(labelCurrentTimes.frame), 0, self.frame.size.width-(buttonPlayOrPause.frame.size.width*2+labelCurrentTimes.frame.size.width*2+20), self.frame.size.height)];
        buttonLockScreen.hidden = YES;
        buttonFullScreen.frame = CGRectMake([[UIScreen mainScreen] bounds].size.height-40, self.frame.size.height/2-15, buttonFullScreen.frame.size.width, buttonFullScreen.frame.size.height);
        [buttonFullScreen setImage:[GAImageManager moviePlayGetFullScreenPickupButtonImage]
                          forState:UIControlStateNormal];
    }
    labelTotalTimes.frame = CGRectMake(CGRectGetMaxX(sliderProgress.frame), self.frame.size.height/2-10, 60, 20);
    grayBackGround.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}
-(void)setIsFullScreenStatus:(BOOL)isFullScreenStatus
{
    _isFullScreenStatus = isFullScreenStatus;
    if (isFullScreenStatus) {
        [buttonFullScreen setImage:[GAImageManager moviePlayGetFullScreenPickupButtonImage]
                          forState:UIControlStateNormal];
    }else{
        [buttonFullScreen setImage:[GAImageManager moviePlayGetFullScreenButtonImage]
                          forState:UIControlStateNormal];
    }
}
-(void)setVideoItemIsPlaying:(BOOL)Playing
{
    isPlaying = Playing;
    if (isPlaying) {
        [buttonPlayOrPause setImage:[GAImageManager moviePlayStopImg] forState:UIControlStateNormal];
    }else{
        [buttonPlayOrPause setImage:[GAImageManager moviePlayPlayImg] forState:UIControlStateNormal];
    }
}

@end
