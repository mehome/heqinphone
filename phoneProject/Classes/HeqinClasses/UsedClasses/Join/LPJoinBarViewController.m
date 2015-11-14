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
        [[PhoneMainView instance] changeCurrentView:[LPJoinManageMeetingViewController compositeViewDescription]];
    }
}

- (IBAction)settingBtnClicked:(id)sender {
    NSLog(@"third");
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
