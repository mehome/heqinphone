//
//  PlayerVolumeRegulationView.m
//  GetArtsVideoPlayer
//
//  Created by Yoever on 14-5-12.
//  Copyright (c) 2014年 Yoever. All rights reserved.
//

#import "PlayerVolumeRegulationView.h"
#import "GAImageManager.h"
#import "Resource_Color.h"

@interface PlayerVolumeRegulationView ()
{
//    UIView      *backGround;
    BOOL        isMute;
}
@end

@implementation PlayerVolumeRegulationView

@synthesize delegate,volumeMuteButton,volumeSlider;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        backGround = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
//        backGround.backgroundColor = [UIColor blackColor];
//        backGround.alpha = 0.5f;
//        [self addSubview:backGround];
        
        [self.layer setCornerRadius:4];
        [self setClipsToBounds:YES];
        [self initSubViews];
    }
    return self;
}

-(void)initSubViews
{
    volumeSlider = [[YUSlider alloc]initWithFrame:CGRectMake(0, 10, self.frame.size.width, self.frame.size.height-50) withVertical:YES];
    [volumeSlider setMaxTintColor:GetColorFromCSSHex(@"#666666")];
    [volumeSlider setMinTintColor:GetColorFromCSSHex(@"#00AECE")];
    [volumeSlider setThumbImage:[GAImageManager moviePlayJinduImg]];
    [volumeSlider setProgressThick:4];
    [volumeSlider setCurrentValue:1.0];
//    volumeSlider.hidden = NO;
    
    // 目前声音的控制显示尚没有研究清楚，所以这时暂时把这个控制给隐藏掉。--heqin.
    volumeSlider.hidden = YES;
    
    [volumeSlider addTarget:self andSelector:@selector(sliderChangedValue:)];

    volumeMuteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    volumeMuteButton.frame = CGRectMake((self.frame.size.width-30)*0.5, self.frame.size.height-35, 30, 30);
    [volumeMuteButton setImage:[GAImageManager moviePlayShengyingImg] forState:UIControlStateNormal];
    [volumeMuteButton addTarget: self action:@selector(muteButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self addSubview:volumeMuteButton];
    [self addSubview:volumeSlider];
}

-(void)muteButtonAction
{
    isMute = !isMute;
    if (isMute) {
        [volumeMuteButton setImage:[GAImageManager moviePlayJingyinImg] forState:UIControlStateNormal];
//        volumeSlider.hidden = YES;
    }else{
        [volumeMuteButton setImage:[GAImageManager moviePlayShengyingImg] forState:UIControlStateNormal];
//        volumeSlider.hidden = NO;
    }
    [delegate volumeSetMute:isMute];
}

-(void)sliderChangedValue:(UISlider*)slider
{
    [delegate volumeSetNewValue:slider.value];
}

@end
