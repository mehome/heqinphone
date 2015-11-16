//
//  LPMyMeetingBarViewController.m
//  linphone
//
//  Created by baidu on 15/11/16.
//
//

#import "LPMyMeetingBarViewController.h"
#import "PhoneMainView.h"
#import "LPMyMeetingManageViewController.h"
#import "LPMyMeetingArrangeViewController.h"

@interface LPMyMeetingBarViewController ()

@end

@implementation LPMyMeetingBarViewController

- (id)init {
    return [super initWithNibName:@"LPMyMeetingBarViewController" bundle:[NSBundle mainBundle]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

// 管理会议室
- (IBAction)manageBtnClicked:(id)sender {
    [[PhoneMainView instance] changeCurrentView:[LPMyMeetingManageViewController compositeViewDescription]];
}

// 安排会议室
- (IBAction)arrangeBtnClicked:(id)sender {
    [[PhoneMainView instance] changeCurrentView:[LPMyMeetingArrangeViewController compositeViewDescription]];
}

// 设置
- (IBAction)settingBtnClicked:(id)sender {
    NSLog(@"MyMeeting setting.");
}

@end
