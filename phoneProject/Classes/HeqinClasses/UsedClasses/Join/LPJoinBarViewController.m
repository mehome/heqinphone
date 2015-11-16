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

@interface LPJoinBarViewController ()

@property (nonatomic, assign) BOOL hasEnterManagerMeeting;

@end

@implementation LPJoinBarViewController

- (id)init {
    return [super initWithNibName:@"LPJoinBarViewController" bundle:[NSBundle mainBundle]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)joinMeetingBtnClicked:(id)sender {
    // 切换到首页
    [[PhoneMainView instance] changeCurrentView:[LPJoinMettingViewController compositeViewDescription]];
}

- (IBAction)joinManageMeetingBtnClicked:(id)sender {
    // 切换到首页的会议
    // 判断用户是否登录，未登录，则弹出登录界面
    if ([LPSystemUser sharedUser].hasLogin == NO) {
        [[PhoneMainView instance] changeCurrentView:[LPLoginViewController compositeViewDescription]];
    }else {
        // 记录这次点击， 下次点击则切换到管理会议室，安排会议室，以及设置界面
        if (self.hasEnterManagerMeeting == YES) {
            // 进入到管理界面
            [[PhoneMainView instance] changeCurrentView:[LPMyMeetingManageViewController compositeViewDescription]];
        }else {
            [[PhoneMainView instance] changeCurrentView:[LPJoinManageMeetingViewController compositeViewDescription]];
        }
        
        self.hasEnterManagerMeeting = YES;
    }
}

- (IBAction)settingBtnClicked:(id)sender {
    [[PhoneMainView instance] changeCurrentView:[LPSettingViewController compositeViewDescription]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
