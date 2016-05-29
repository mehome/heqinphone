//
//  ControlsBelowView.h
//  GetArtsVideoPlayer
//
//  Created by Yoever on 14-5-12.
//  Copyright (c) 2014年 Yoever. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YUSlider.h"

@protocol ControlsBelowDelegate <NSObject>
@optional

-(void)belowPlayOrPauseAction;
-(void)belowProgressSliderChangedValuePercent:(float)percentValue;
-(void)belowLockScreenAction;
-(void)belowFullScreenAction;

@end


@interface ControlsBelowView : UIView


@property(weak,nonatomic)id<ControlsBelowDelegate>delegate;
//视频总时间
@property(retain,nonatomic)UILabel      *labelTotalTimes;
//当前进度的时间
@property(retain,nonatomic)UILabel      *labelCurrentTimes;
//进度条
@property(retain,nonatomic)YUSlider     *sliderProgress;
//暂停播放按钮
@property(retain,nonatomic)UIButton     *buttonPlayOrPause;
//锁屏按钮
@property(retain,nonatomic)UIButton     *buttonLockScreen;
//全屏按钮
@property(retain,nonatomic)UIButton     *buttonFullScreen;

@property(assign,nonatomic)BOOL        isPlaying;
@property(assign,nonatomic)BOOL        isQuanPing;
@property(assign,nonatomic)BOOL        isLocked;
@property(assign,nonatomic)BOOL         isFullScreenStatus;

- (id)initWithFrame:(CGRect)frame isFullScreen:(BOOL)fullScreen;
-(void)changeSubViewsIsFullScreen:(BOOL)isFull;
-(void)setVideoItemIsPlaying:(BOOL)Playing;

@end
