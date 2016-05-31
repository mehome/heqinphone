//
//  HQPlayerViewController.m
//  AVPlayer
//
//  Created by ClaudeLi on 16/4/13.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import "HQPlayerViewController.h"
#import "HQRotatingScreen.h"
#define MovieURL @"http://video.getarts.cn/20160201/yufang2.mp4.mp4"

#define KTabBarHeight 49.0f // tabBar高度
#define KNavigatHeight  64.f // 导航栏高度
#define KStateHeight 20.0f // 状态栏
#define NavHeight (KNavigatHeight - KStateHeight)


@interface HQPlayerViewController ()
{
    UIInterfaceOrientation   _lastOrientation;      // 可以用来存储之前的旋转方向
}

@property (nonatomic, copy) NSString *mediaUrlStr;
@property (nonatomic, copy) NSString *mediaTitle;

@property (weak, nonatomic) IBOutlet UIView *downBGView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet HQVideoPlayer *videoPlayer;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerHeight;

@end

@implementation HQPlayerViewController

+ (void)playMovieWithTitle:(NSString *)title mediaUrlStr:(NSString *)urlStr {
    HQPlayerViewController *vc = [[HQPlayerViewController alloc] init];

    [vc specifyTitle:title andMediaUrlStr:urlStr];

    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:vc animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 播放指定视频
    [self.videoPlayer updatePlayerWith:[NSURL URLWithString:self.mediaUrlStr]];

    // 指定显示的Title.
    self.titleLabel.text = self.mediaTitle;
    [self.videoPlayer specialTitle:self.mediaTitle];

    // 强制转屏
    [HQRotatingScreen forceOrientation: UIInterfaceOrientationPortrait];
}

- (void)specifyTitle:(NSString *)title andMediaUrlStr:(NSString *)urlStr {
    self.mediaTitle = title;
    self.mediaUrlStr = urlStr;
}


- (IBAction)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//iOS8旋转动作的具体执行
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator: coordinator];
    // 监察者将执行： 1.旋转前的动作  2.旋转后的动作（completion）
    [coordinator animateAlongsideTransition: ^(id<UIViewControllerTransitionCoordinatorContext> context)
     {
         if ([HQRotatingScreen isOrientationLandscape]) {
             _lastOrientation = [UIApplication sharedApplication].statusBarOrientation;
             [self p_prepareFullScreen];
         }
         else {
             [self p_prepareSmallScreen];
         }
     } completion: ^(id<UIViewControllerTransitionCoordinatorContext> context) {
     }];    
}

//iOS7旋转动作的具体执行
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if (toInterfaceOrientation == UIDeviceOrientationLandscapeRight || toInterfaceOrientation == UIDeviceOrientationLandscapeLeft) {
        _lastOrientation = [UIApplication sharedApplication].statusBarOrientation;
        [self p_prepareFullScreen];
    }
    else {
        [self p_prepareSmallScreen];
    }
}

#pragma mark - Private

// 切换成全屏的准备工作
- (void)p_prepareFullScreen {
    self.downBGView.hidden = YES;
    _headerHeight.constant = 0;
    [self.videoPlayer setlandscapeLayout];
}

// 切换成小屏的准备工作
- (void)p_prepareSmallScreen {
    self.downBGView.hidden = NO;
    _headerHeight.constant = KNavigatHeight;
    [self.videoPlayer setPortraitLayout];
}

- (BOOL)shouldAutorotate{
    return !self.videoPlayer.isLockScreen;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [self.videoPlayer removeObserverAndNotification];
}

@end
