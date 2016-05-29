//
//  ControlsTopView.h
//  GetArtsVideoPlayer
//
//  Created by Yoever on 14-5-12.
//  Copyright (c) 2014年 Yoever. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol ControlsTopDelegate <NSObject>

@optional

-(void)topQuitAction;
-(void)topVideoQualityAction;
-(void)topAirPlayAction;
-(void)topTransmitAction;

@end

@interface ControlsTopView : UIView

@property(weak,nonatomic)id<ControlsTopDelegate>delegate;
//返回(退出)按钮
@property(retain,nonatomic)UIButton     *buttonQuit;
//视频title
@property(retain,nonatomic)UILabel      *titleLabel;
//视频质量
@property(retain,nonatomic)UIButton     *buttonVideoQuality;
//AirPlay
@property(retain,nonatomic)UIButton     *buttonAirPlay;
//转发
@property(retain,nonatomic)UIButton     *buttonTransmit;

-(void)setVideoQualityButtonText:(NSString*)text;
-(void)setTitle:(NSString *)string;
@end
