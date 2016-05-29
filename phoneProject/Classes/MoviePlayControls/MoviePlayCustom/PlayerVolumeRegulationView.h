//
//  PlayerVolumeRegulationView.h
//  GetArtsVideoPlayer
//
//  Created by Yoever on 14-5-12.
//  Copyright (c) 2014年 Yoever. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "YUSlider.h"

@protocol PlayerVolumeDelegate <NSObject>

@optional

-(void)volumeSetMute:(BOOL)isMute;
-(void)volumeSetNewValue:(float)value;

@end

@interface PlayerVolumeRegulationView : UIView

@property(retain,nonatomic)YUSlider     *volumeSlider;
@property(retain,nonatomic)UIButton     *volumeMuteButton;
@property(weak,nonatomic)id<PlayerVolumeDelegate>delegate;

@end
