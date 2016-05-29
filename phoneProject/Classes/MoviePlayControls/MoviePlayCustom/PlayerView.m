//
//  PlayerView.m
//  StreamPlayer
//
//  Created by Yoever on 14-3-20.
//  Copyright (c) 2014年 Yoever. All rights reserved.
//

#import "PlayerView.h"

@interface PlayerView ()
{
    CGPoint beginLocation;
    CGPoint endLocation;
    UIView *gestureView;
}

@end

@implementation PlayerView
@synthesize player,delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor blackColor];
        
        CGFloat height = frame.size.height-40;
        CGFloat width = frame.size.width;
        CGFloat orignX = frame.origin.x;
        CGFloat orignY = frame.origin.y;

        gestureView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        gestureView.backgroundColor = [UIColor clearColor];
        [self addSubview:gestureView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        [gestureView addGestureRecognizer:tap];
//        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(swipeAction:)];
//        [gestureView addGestureRecognizer:pan];
    }
    return self;
}

-(void)changeGestureViewFrame:(CGRect)frame isLandScape:(BOOL)isLandScape
{
    CGFloat height = frame.size.height-40;
    CGFloat width = frame.size.width;
    CGFloat orignX = frame.origin.x;
    CGFloat orignY = frame.origin.y;
    
    if (isLandScape) {
       orignY  = frame.origin.y;
    }else{
        orignY  = frame.origin.y-62;
    }

//    gestureView.frame = CGRectMake(orignX, orignY, width, height);
    gestureView.frame = CGRectMake(0, 0, width, height);
}

+(Class)layerClass{
    return [AVPlayerLayer class];
}
-(AVPlayer*)player{
    return [(AVPlayerLayer*)[self layer]player];
}

-(void)setPlayer:(AVPlayer *)thePlayer{
    [(AVPlayerLayer*)[self layer]setPlayer:thePlayer];
}

-(void)tapAction:(UITapGestureRecognizer*)tap
{
    if (delegate && [delegate respondsToSelector:@selector(playerViewDidTapped)]) {
        [delegate playerViewDidTapped];
    }
}

-(void)swipeAction:(UIPanGestureRecognizer*)pan
{
    if ([pan isKindOfClass:[UISlider class]]) {

    }
    if (![pan isKindOfClass:[UIPanGestureRecognizer class]]) {
        return;
    }
    if (pan.state == UIGestureRecognizerStateBegan) {
        CGPoint location = [pan locationInView:self];
        beginLocation = location;
    }
    
    else if (pan.state == UIGestureRecognizerStateEnded){
        endLocation = [pan locationInView:self];
        int distanceY = (int)endLocation.y-beginLocation.y;
        int distanceX = (int)endLocation.x-beginLocation.x;
        if (distanceY<=60&&distanceY>=-60) {
            if (distanceX>=0) {
                if (delegate && [delegate respondsToSelector:@selector(playerDragedForwardDistance:endDistance:)]) {
                    [delegate playerDragedForwardDistance:distanceX endDistance:(float)endLocation.x];
                }
            }else{
                if (delegate && [delegate respondsToSelector:@selector(playerDragedForwardDistance:endDistance:)]) {
                    [delegate playerDragedForwardDistance:distanceX endDistance:(float)endLocation.x];
                }
                
            }
        }
        
        beginLocation = CGPointMake(0, 0);
        endLocation = CGPointMake(0, 0);
    }
}

@end