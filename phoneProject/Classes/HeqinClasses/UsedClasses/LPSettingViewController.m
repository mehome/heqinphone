//
//  LPSettingViewController.m
//  linphone
//
//  Created by heqin on 15/11/7.
//
//

#import "LPSettingViewController.h"
#import "LPSystemUser.h"
#import "LPSystemSetting.h"

@interface LPSettingViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;

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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 初始化各个界面信息
    [self initControls];
}

- (void)initControls {
    if ([LPSystemUser sharedUser].hasLogin == YES) {
        self.nameField.text = [LPSystemUser sharedUser].loginUserName;
        self.accountField.text = @"个人帐号";
        self.companyField.text = @"企业信息";
        
        self.logoutBtn.enabled = YES;
    }else {
        self.nameField.text = @"未登录";
        self.accountField.text = @"";
        self.companyField.text = @"";
        
        self.logoutBtn.enabled = NO;
    }
    
    self.defaultSilentVoiceSwitch.on = [LPSystemSetting sharedSetting].defaultSilence;
    self.defaultSilentMovieSwitch.on = [LPSystemSetting sharedSetting].defaultNoVideo;
    
    self.nameField.enabled = NO;
    self.accountField.enabled = NO;
    self.companyField.enabled = NO;
    
    // 显示服务器地址
    self.serverAddressLabel.text = [LPSystemSetting sharedSetting].sipDomainStr;
    
    self.versionLabel.text = [NSString stringWithFormat:@"%@ (%@)",
                              [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                              [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
}

- (void)bgTap:(UITapGestureRecognizer *)tapGesture {
    [self.nameField resignFirstResponder];
    [self.accountField resignFirstResponder];
    [self.companyField resignFirstResponder];
}

// 注销按钮
- (IBAction)logoutBtnClicked:(id)sender {
    
}

// 静音
- (IBAction)defaultVoiceSwitched:(id)sender {
    [LPSystemSetting sharedSetting].defaultSilence = ((UISwitch *)sender).on;
}

// 静画
- (IBAction)defaultMovieSwitched:(id)sender {
    [LPSystemSetting sharedSetting].defaultNoVideo = ((UISwitch *)sender).on;
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
