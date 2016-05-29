//
//  GAVideoPlayVC.m
//  GetArts
//
//  Created by yoever on 14-9-13.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import "GAVideoPlayVC.h"
#import "PlayerView.h"
#import "Configmanager.h"
#import "ControlsBelowView.h"
#import "ControlsTopView.h"
#import "PlayerVolumeRegulationView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "GAImageManager.h"

@interface GAVideoPlayVC ()
<PlayerDelegate,
ControlsBelowDelegate,
ControlsTopDelegate,
PlayerVolumeDelegate>
{
    /* 导航 */
    UIView              *navigationView;
    UIButton            *backButton;
    UILabel             *titleLabel;
    UIButton            *transmitButton;
    
    /* video player */
    PlayerView          *playerView;
    ControlsBelowView   *controlsBelow;
    ControlsTopView     *controlsTop;
    PlayerVolumeRegulationView *controlsVolume;
    UIActivityIndicatorView *indicator;
    
    float               videoTotalTimes;
    
    BOOL                isPlaying;
    
    __block ViewDirection       currentDirection;
    
    __block BOOL                motionLocked;
    
    __block ViewDirection       lastLandDirection;
}

@property (nonatomic, strong) NSURL *playUrl;

@end

@implementation GAVideoPlayVC

#pragma mark - viewDidLoad
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor grayColor];
    
    //导航栏
    [self initialNavigationView];
    
    //播放器
    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width * (VIDEO_PREVIEW_HEIGHT/VIDEO_PREVIEW_WIDTH));
    playerView  = [[PlayerView alloc]initWithFrame:frame];
    playerView.delegate = self;
    [self.view addSubview:playerView];
    
    [self setPlayerBeginToPlay];
    
    [self rotateSubViewsToPortrait];
}

- (void)showTitle:(NSString *)title andUrlStr:(NSString *)urlstr {
    self.title = title;
    
//    self.playUrl = [NSURL URLWithString:urlstr];
    self.playUrl = [NSURL URLWithString:@"http://video.getarts.cn/20160201/yufang2.mp4.mp4"];
}

#pragma mark - 导航栏
-(void)initialNavigationView
{
    CGFloat height = 64;
    navigationView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, height)];
    navigationView.backgroundColor = [UIColor blackColor];
    navigationView.hidden = NO;
    [self.view addSubview:navigationView];
    
    backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    float y = 20;
    backButton.frame = CGRectMake(10, y+(44-19)/2, 19, 19);
    [backButton setImage:[GAImageManager moviePlayGetBackArrowImage] forState:UIControlStateNormal];
    [backButton setImage:[GAImageManager moviePlayGetBackArrowImageHighLight] forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(navBackButtonAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];
    
    UIButton *navBack = [UIButton buttonWithType:UIButtonTypeCustom];
    navBack.frame = CGRectMake(10, y+(44-19)/2, 19, 19);
    [navBack setImage:[GAImageManager moviePlayGetBackArrowImage] forState:UIControlStateNormal];
    [navBack setImage:[GAImageManager moviePlayGetBackArrowImageHighLight] forState:UIControlStateHighlighted];
    [navBack addTarget:self action:@selector(navBackButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [navigationView addSubview:navBack];
    
    titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(backButton.frame), y+(44-20)/2, SCREEN_WIDTH-CGRectGetMaxX(backButton.frame)-40, 20)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = @"自定义标题";
    titleLabel.font = [UIFont systemFontOfSize:17];
    titleLabel.textColor = [UIColor whiteColor];
    
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [navigationView addSubview:titleLabel];
    
    // 右侧的分享功能
//    transmitButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [transmitButton setFrame:CGRectMake(SCREEN_WIDTH-40, y+(44-30)/2, 30, 30)];
//    [transmitButton setImage:[GAImageManager moviePlayZhuanfaImg] forState:UIControlStateNormal];
//    [transmitButton addTarget:self action:@selector(transmitAction) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:transmitButton];
//    
//    UIButton *navTransmit = [UIButton buttonWithType:UIButtonTypeCustom];
//    [navTransmit setFrame:CGRectMake(SCREEN_WIDTH-40, y+(44-30)/2, 30, 30)];
//    [navTransmit setImage:[GAImageManager moviePlayZhuanfaImg] forState:UIControlStateNormal];
//    [navTransmit addTarget:self action:@selector(transmitAction) forControlEvents:UIControlEventTouchUpInside];;
//    [navigationView addSubview:navTransmit];
//    navigationView.hidden = YES;
}

#pragma mark - 初始化播放器
-(void)setPlayerBeginToPlay
{
    [self addControlItemsView];
    
//    NSURL *url = [NSURL URLWithString:@"http://file.myvmr.cn:8090/2016-05-16/1088_103028.mp4"];
//    NSURL *url = [NSURL URLWithString:@"http://video.getarts.cn/20160201/yufang2.mp4.mp4"];
    
    if (self.playUrl == nil) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"视频地址为空，请检查" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alertVC animated:YES completion:nil];
        return;
    }
    
    AVPlayerItem *playerItem = [[AVPlayerItem alloc]initWithURL:self.playUrl];
    AVPlayer *player = [[AVPlayer alloc]initWithPlayerItem:playerItem];
    
//    [player setUsesExternalPlaybackWhileExternalScreenIsActive:NO];
//    [player setAllowsExternalPlayback:NO];
    player.volume = 1.0f;
    
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indicator.frame = CGRectMake(playerView.frame.size.width/2-20, playerView.frame.size.height/2-20+playerView.frame.origin.y, 40, 40);
    
    [playerView setPlayer:player];
    [playerView.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playerDidFinishPlay) name:AVPlayerItemDidPlayToEndTimeNotification object:playerView.player.currentItem];
    
    [playerView.player play];
}

//初始化播放器相关控件
-(void)addControlItemsView
{
    //视频播放页面顶部，视频质量，Airplay
    controlsTop = [[ControlsTopView alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.height, 64)];
    controlsTop.delegate = self;
    [controlsTop setTitle:@"视频顶部的提示"];
    controlsTop.hidden = YES;
    
    //视频播放页面底部，进度条，时间，暂停，播放键
    controlsBelow = [[ControlsBelowView alloc]initWithFrame:CGRectMake(0, playerView.frame.size.height-40, playerView.frame.size.width, 40) isFullScreen:Video_FullScreen_Play];
    controlsBelow.delegate = self;
    controlsBelow.hidden = YES;
    
    //视频播放页面音量和静音
    controlsVolume = [[PlayerVolumeRegulationView alloc]initWithFrame:CGRectMake(playerView.frame.size.width - 50,
                                                                                 playerView.frame.size.height - 100,
                                                                                 50,
                                                                                 100)];
    controlsVolume.delegate = self;
    controlsVolume.hidden = YES;
    [controlsVolume.volumeSlider setCurrentValue:1];
    controlsVolume.backgroundColor = [UIColor clearColor];
    
    [playerView addSubview:controlsTop];
    [playerView addSubview:controlsBelow];
    [playerView addSubview:controlsVolume];
}

#pragma mark --返回
-(void)navBackButtonAction
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:playerView.player.currentItem];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    self.navigationController.navigationBarHidden = NO;
    [[UIApplication sharedApplication ]setNetworkActivityIndicatorVisible:NO];

    [playerView.player pause];
    [playerView.player.currentItem cancelPendingSeeks];
    [playerView.player cancelPendingPrerolls];
    [playerView.player.currentItem removeObserver:self forKeyPath:@"status"];
    [playerView removeFromSuperview];
    [indicator stopAnimating];
    
//    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - VideoPlayer Methods
//播放器监听
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"]) {
        
        [indicator stopAnimating];
        
        if (playerView.player.currentItem.status==AVPlayerItemStatusReadyToPlay)
        {
            CMTime time = playerView.player.currentItem.duration;
            float totalTime = time.value/time.timescale;
            videoTotalTimes = totalTime;
            controlsBelow.labelTotalTimes.text = [NSString stringWithFormat:@"%@",[self converTimeFromFloatTime:totalTime]];
            __weak GAVideoPlayVC* WeakSelf = self;
            __weak ControlsBelowView *below = controlsBelow;
            __weak PlayerView *weakPlayer = playerView;
            [playerView.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:nil usingBlock:^(CMTime time){
                if (!WeakSelf || ![WeakSelf.navigationController.visibleViewController isKindOfClass:[GAVideoPlayVC class]]) {
                    return;
                }
                CMTime current = weakPlayer.player.currentItem.currentTime;
                float currrentTime = current.value/current.timescale;
                
                below.labelCurrentTimes.text = [WeakSelf converTimeFromFloatTime:currrentTime];
                if (!below.sliderProgress.isDragging) {
                    [below.sliderProgress setCurrentValue:currrentTime/totalTime];
                    below.sliderProgress.value = currrentTime/totalTime;
                }
                
                below.labelCurrentTimes.text = [WeakSelf converTimeFromFloatTime:currrentTime];
            }];
            
            if ([self.navigationController.visibleViewController isKindOfClass:[GAVideoPlayVC class]]) {
                [playerView.player play];
                [controlsBelow setVideoItemIsPlaying:YES];
                isPlaying = YES;
            }
        }else if (playerView.player.currentItem.status==AVPlayerItemStatusFailed)
        {
            NSLog(@"视频加载失败");
        }else if (playerView.player.currentItem.status==AVPlayerItemStatusUnknown)
        {
            NSLog(@"未知错误");
        }
    }
}

//时间转换
-(NSString *)converTimeFromFloatTime:(float)value
{
    int newValue = (int)value;
    
    int seconds = newValue % 60;
    int minutes = (newValue / 60) % 60;
    int hours = newValue / 3600;
    
    if (hours == 0) {
        return [NSString stringWithFormat:@"%02d:%02d",minutes, seconds];
    }
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}

-(void)playerDidFinishPlay
{
    [playerView.player seekToTime:CMTimeMake(0, 1)];
    [playerView.player pause];
    isPlaying = NO;
    
    [controlsBelow setVideoItemIsPlaying:NO];
}

//跳到指定位置开始播放
-(void)jumpToNewPosition:(CMTime)time
{
    [indicator startAnimating];
    [playerView.player pause];
    [controlsBelow setVideoItemIsPlaying:NO];
    
    [playerView.player seekToTime:time completionHandler:^(BOOL finish){
        [indicator stopAnimating];
        [playerView.player play];
        [controlsBelow setVideoItemIsPlaying:YES];
    }];
}

#pragma mark - Player Delegate
-(void)playerViewDidTapped
{
    if (currentDirection == directionPortrait) {
        controlsTop.hidden = YES;
        if (controlsBelow.hidden) {
            
            controlsBelow.alpha = 0;
            controlsBelow.hidden = NO;
            
            controlsVolume.alpha = 0;
            controlsVolume.hidden = NO;
            
            [UIView animateWithDuration:0.2f animations:^{
                controlsBelow.alpha = 1;
                controlsVolume.alpha = 1;
            }];
            
        }else {
            controlsBelow.alpha = 1;
            controlsVolume.alpha = 1;

            [UIView animateWithDuration:0.2f animations:^{
                controlsBelow.alpha = 0;
                controlsVolume.alpha = 0;
                
            } completion:^(BOOL finished) {
                controlsBelow.hidden = YES;
                controlsVolume.hidden = YES;
            }];
        }
    }else {
        if (controlsBelow.hidden) {
            controlsBelow.alpha = 0;
            controlsTop.alpha = 0;
            controlsVolume.alpha = 0;
            controlsBelow.hidden = NO;
            controlsTop.hidden = NO;
            controlsVolume.hidden = NO;
            [UIView animateWithDuration:0.2f animations:^{
                controlsBelow.alpha = 1;
                controlsTop.alpha = 1;
                controlsVolume.alpha = 1;
            }];
        }else {
            controlsBelow.alpha = 1;
            controlsTop.alpha = 1;
            controlsVolume.alpha = 1;
            [UIView animateWithDuration:0.2f animations:^{
                controlsBelow.alpha = 0;
                controlsTop.alpha = 0;
                controlsVolume.alpha = 0;
            } completion:^(BOOL finished) {
                controlsBelow.hidden = YES;
                controlsTop.hidden = YES;
                controlsVolume.hidden = YES;
            }];
        }
    }
}

-(void)playerDragedForwardDistance:(int)distance endDistance:(float)endDistance
{
    endDistance = endDistance/SCREEN_WIDTH;
    NSLog(@"player forward backward:%d",distance);
    [self belowProgressSliderChangedValuePercent:endDistance];
}

#pragma mark - 底部控制按钮回调
-(void)belowPlayOrPauseAction {
    if (isPlaying) {
        [playerView.player pause];
        isPlaying = NO;
    }else {
        [playerView.player play];
        isPlaying = YES;
    }
}

-(void)belowProgressSliderChangedValuePercent:(float)percentValue {
    float currentTime = percentValue * videoTotalTimes;
    controlsBelow.labelCurrentTimes.text = [self converTimeFromFloatTime:currentTime];
    CMTime time = CMTimeMake(currentTime, 1);
    [self jumpToNewPosition:time];
}

-(void)belowLockScreenAction {
    if ([UIDevice currentDevice].orientation==UIInterfaceOrientationPortrait) {
        Direction = portrait;
    }else if ([UIDevice currentDevice].orientation==UIInterfaceOrientationLandscapeLeft) {
        Direction = left;
    }else if ([UIDevice currentDevice].orientation==UIInterfaceOrientationLandscapeRight) {
        Direction = right;
    }else {
        Direction = upsidedown;
    }
}

-(void)belowFullScreenAction {
    motionLocked = YES;
    if (currentDirection == directionLandLeft) {
        currentDirection = directionPortrait;
        self.view.transform = CGAffineTransformMakeRotation(0);
        [self rotateSubViewsToPortrait];
    }else if (currentDirection == directionPortrait) {
        if (lastLandDirection==directionLandLeft) {
            currentDirection = directionLandLeft;
            self.view.transform = CGAffineTransformMakeRotation(M_PI/2);
            [self rotateSubViewsToFullScreen];
        }else {
            currentDirection = directionLandRight;
            self.view.transform = CGAffineTransformMakeRotation(-M_PI/2);
            [self rotateSubViewsToFullScreen];
        }
    }else if (currentDirection == directionLandRight) {
        currentDirection = directionPortrait;
        self.view.transform = CGAffineTransformMakeRotation(0);
        [self rotateSubViewsToPortrait];
    }
}

#pragma mark - 音量控制
-(void)volumeSetMute:(BOOL)isMute {
    [playerView.player setMuted:isMute];
}

-(void)volumeSetNewValue:(float)value {
    [playerView.player setVolume:value];
}

-(void)topQuitAction {
    [self belowFullScreenAction];
}

#pragma mark - 分享
-(void)topTransmitAction {
    [self transmitAction];
}

#pragma mark --转发
-(void)transmitAction {
    NSString *protri = @"vertical up";
    if (currentDirection == directionLandLeft) {
        protri = @"left";
    }else if (currentDirection == directionLandRight){
        protri = @"right";
    }
    
    NSLog(@"转发按钮点击：%@", protri);
}

#pragma mark - 旋转视图(ROTATE VIEW)
// 旋转到全屏(rotate to fullScreen)
-(void)rotateSubViewsToFullScreen {
    [UIView animateWithDuration:0.3f animations:^{
        navigationView.hidden = YES;
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        self.navigationController.navigationBarHidden = YES;
        
        controlsTop.hidden = controlsBelow.hidden;
        controlsBelow.hidden = YES;
        controlsVolume.hidden = controlsBelow.hidden;

        self.view.bounds = CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.height, [[UIScreen mainScreen]bounds].size.width);
        playerView.frame = CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.height, [[UIScreen mainScreen]bounds].size.width);

        //改变手势层的frame
        [playerView changeGestureViewFrame:playerView.frame isLandScape:YES];
        
        indicator.frame = CGRectMake(playerView.frame.size.width/2-20, playerView.frame.origin.y+playerView.frame.size.height/2-20, 40, 40);
        controlsBelow.frame = CGRectMake(0, playerView.frame.size.height-40+playerView.frame.origin.y, playerView.frame.size.width, 40);
        [controlsBelow changeSubViewsIsFullScreen:YES];
        [self reCalculateContentSubviewsFrames];
    }];
}

// 旋转到竖屏(rotate to portrait)
-(void)rotateSubViewsToPortrait {
    [UIView animateWithDuration:0.3f animations:^{
        controlsBelow.hidden = NO;
        controlsTop.hidden = YES;
        controlsVolume.hidden = controlsBelow.hidden;

//        self.view.bounds = CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height);
//        playerView.frame = CGRectMake(0, 64, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.width * (VIDEO_PREVIEW_HEIGHT/VIDEO_PREVIEW_WIDTH));
        
        CGFloat videoHeight = [[UIScreen mainScreen]bounds].size.width * (VIDEO_PREVIEW_HEIGHT/VIDEO_PREVIEW_WIDTH);
        playerView.frame = CGRectMake(0, ([[UIScreen mainScreen]bounds].size.height-videoHeight)/2.0, [[UIScreen mainScreen]bounds].size.width, videoHeight);

        //改变手势层的frame
        [playerView changeGestureViewFrame:playerView.frame isLandScape:NO];
        
        indicator.frame = CGRectMake(playerView.frame.size.width/2-20, playerView.frame.size.height/2-20, 40, 40);
        controlsBelow.frame = CGRectMake(0, playerView.frame.size.height-40, playerView.frame.size.width, 40);
        [controlsBelow changeSubViewsIsFullScreen:NO];
        
        [self reCalculateContentSubviewsFrames];
        if (self.interfaceOrientation == UIInterfaceOrientationPortrait) {
            navigationView.hidden = YES;
            [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
            self.navigationController.navigationBarHidden = NO;
        }else {
            navigationView.hidden = NO;
            [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
            self.navigationController.navigationBarHidden = YES;
        }
    }];
}

// 旋转后重新计算坐标(recalculate frames after rotate)
-(void)reCalculateContentSubviewsFrames {
    navigationView.frame = CGRectMake(0, 0, playerView.frame.size.width, NAVGATION_HEIGHT);
}

@end
