//
//  LPJoinBarViewController.m
//  linphone
//
//  Created by heqin on 15/11/7.
//
//

#import "LPJoinBarViewController.h"
#import "PhoneMainView.h"
#import "LPJoinMettingViewController.h"
#import "LPJoinManageMeetingViewController.h"
#import "LPSystemUser.h"
#import "LPLoginViewController.h"
#import "LPSettingViewController.h"
#import "LPMyMeetingManageViewController.h"
#import "LPMyMeetingArrangeViewController.h"

@interface LPJoinBarViewController ()

@end

@implementation LPJoinBarViewController

- (id)init {
    return [super initWithNibName:@"LPJoinBarViewController" bundle:[NSBundle mainBundle]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

// 参加会议
- (IBAction)joinMeetingBtnClicked:(id)sender {
    // 如果未登录，则显示第一个界面
    if ([LPSystemUser sharedUser].hasLogin == YES) {
        // 如果已登录，则显示所有会议界面
        [[PhoneMainView instance] changeCurrentView:[LPJoinManageMeetingViewController compositeViewDescription]];
    }else {
        // 未登录， 进入首界面
        [[PhoneMainView instance] changeCurrentView:[LPJoinMettingViewController compositeViewDescription]];
    }
}

// 管理我的会议
- (IBAction)joinManageMeetingBtnClicked:(id)sender {
    // 切换到首页的会议
    // 判断用户是否登录，未登录，则弹出登录界面
    if ([LPSystemUser sharedUser].hasLogin == NO) {
        [[PhoneMainView instance] changeCurrentView:[LPLoginViewController compositeViewDescription] push:YES];
    }else {
        // 进入到管理我的会议界面
        [[PhoneMainView instance] changeCurrentView:[LPMyMeetingManageViewController compositeViewDescription]];
    }
}

// 安排会议
- (IBAction)arrangeBtnClicked:(id)sender {
    if ([LPSystemUser sharedUser].hasLogin == NO) {
        [[PhoneMainView instance] changeCurrentView:[LPLoginViewController compositeViewDescription] push:YES];
    }else {
        // 进入到会议安排界面
        [[PhoneMainView instance] changeCurrentView:[LPMyMeetingArrangeViewController compositeViewDescription]];
    }
}

// 设置
- (IBAction)settingBtnClicked:(id)sender {
    [[PhoneMainView instance] changeCurrentView:[LPSettingViewController compositeViewDescription]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
