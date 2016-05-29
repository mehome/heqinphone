//
//  PlayerView.h
//  StreamPlayer
//
//  Created by Yoever on 14-3-20.
//  Copyright (c) 2014年 Yoever. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol PlayerDelegate <NSObject>

@optional

-(void)playerDragedForwardDistance:(int)distance endDistance:(float)endDistance;
-(void)playerViewDidTapped;

@end


@interface PlayerView : UIView


@property (strong,nonatomic)AVPlayer *player;
@property (assign,nonatomic)id<PlayerDelegate>delegate;

-(void)setPlayer:(AVPlayer *)thePlayer;
-(void)changeGestureViewFrame:(CGRect)frame isLandScape:(BOOL)isLandScape;

@end
