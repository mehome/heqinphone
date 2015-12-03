//
//  LPMyManageSingleViewController.m
//  linphone
//
//  Created by baidu on 15/11/16.
//
//

#import "LPMyManageSingleViewController.h"

@interface LPMyManageSingleViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *meetingNameLabel;

@property (weak, nonatomic) IBOutlet UITextField *hostPinTextField;
@property (weak, nonatomic) IBOutlet UITextField *guestPinTextField;
@property (weak, nonatomic) IBOutlet UITextField *statusTextField;

@property (weak, nonatomic) IBOutlet UIButton *statusBtn;

@end

@implementation LPMyManageSingleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)settingBtnClicked:(id)sender {
}

#pragma mark - UICompositeViewDelegate Functions

static UICompositeViewDescription *compositeDescription = nil;

+ (UICompositeViewDescription *)compositeViewDescription {
    if(compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:@"SingleManage"
                                                                content:@"LPMyManageSingleViewController"
                                                               stateBar:nil
                                                        stateBarEnabled:false
                                                                 tabBar:@"LPMyMeetingBarViewController"
                                                          tabBarEnabled:true
                                                             fullscreen:false
                                                          landscapeMode:[LinphoneManager runningOnIpad]
                                                           portraitMode:true];
        compositeDescription.darkBackground = true;
    }
    return compositeDescription;
}

- (IBAction)lockBtnClicked:(id)sender {
    NSLog(@"锁定按钮触发");
}

- (IBAction)setBtnClicked:(id)sender {
    NSLog(@"设置按钮触发");
}

@end