//
//  LPSettingViewController.m
//  linphone
//
//  Created by heqin on 15/11/7.
//
//

#import "LPSettingViewController.h"

@interface LPSettingViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *accountField;
@property (weak, nonatomic) IBOutlet UITextField *companyField;

@property (weak, nonatomic) IBOutlet UILabel *serverAddressLabel;

@property (weak, nonatomic) IBOutlet UISwitch *defaultSilentVoiceSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *defaultSilentMovieSwitch;

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation LPSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgTap:)]];
    
    // 初始化各个界面信息
}

- (void)bgTap:(UITapGestureRecognizer *)tapGesture {
    [self.nameField resignFirstResponder];
    [self.accountField resignFirstResponder];
    [self.companyField resignFirstResponder];
}

// 注销按钮
- (IBAction)logoutBtnClicked:(id)sender {
    
}

// 确定输入的信息
- (IBAction)confimPersonalBtnClicked:(id)sender {
    
}

// 静音
- (IBAction)defaultVoiceSwitched:(id)sender {
}

// 静画
- (IBAction)defaultMovieSwitched:(id)sender {
}

#pragma mark - UICompositeViewDelegate Functions

static UICompositeViewDescription *compositeDescription = nil;

+ (UICompositeViewDescription *)compositeViewDescription {
    if(compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:@"Setting"
                                                                content:@"LPSettingViewController"
                                                               stateBar:nil
                                                        stateBarEnabled:false
                                                                 tabBar:@"LPJoinBarViewController"
                                                          tabBarEnabled:true
                                                             fullscreen:false
                                                          landscapeMode:[LinphoneManager runningOnIpad]
                                                           portraitMode:true];
        compositeDescription.darkBackground = true;
    }
    return compositeDescription;
}

@end
