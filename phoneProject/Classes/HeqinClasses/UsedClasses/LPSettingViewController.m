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
#import "LPJoinMettingViewController.h"
#import "PhoneMainView.h"

@interface LPSettingViewController () <UITextFieldDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *accountField;
@property (weak, nonatomic) IBOutlet UITextField *companyField;

@property (weak, nonatomic) IBOutlet UILabel *serverAddressLabel;

@property (weak, nonatomic) IBOutlet UISwitch *defaultSilentVoiceSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *defaultSilentMovieSwitch;

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

#define kLogoutAlertTag 90902

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

- (void)initDynamicInfos {
    self.nameField.text = [[LPSystemUser sharedUser].settingsStore stringForKey:@"userid_preference"];
    self.accountField.text = [[LPSystemUser sharedUser].settingsStore stringForKey:@"userid_preference"];
    
    self.companyField.text = @"企业信息";
    self.logoutBtn.enabled = YES;

    self.logoutBtn.backgroundColor = yellowSubjectColor;
    self.logoutBtn.layer.cornerRadius = 5.0;
    self.logoutBtn.clipsToBounds = YES;
    
    if (kNotLoginCheck ) {
        // 当前已经注销
        self.logoutBtn.enabled = NO;
        
        self.nameField.text = @"";
        self.accountField.text = @"";
        self.companyField.text = @"";

    }else {
        // 当前已经登录
        self.logoutBtn.enabled = YES;
    }
}

- (void)initControls {
    [self initDynamicInfos];
    
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
    if ( kNotLoginCheck) {
        return;
    }
    
    UIAlertView *tipAlert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您确认要注销么？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    tipAlert.tag = kLogoutAlertTag;
    [tipAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex NS_DEPRECATED_IOS(2_0, 9_0) {
    if (alertView.tag == kLogoutAlertTag) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            // 执行注销操作
            [self clearAccountFromSetting];
            
            // 刷新当前界面顶部的用户信息即可
            [self initDynamicInfos];
        }
    }
}

// 从之前代码中拉出来的，点击Clear Account后的操作
- (void)clearAccountFromSetting {
    LinphoneCore* lc = [LinphoneManager getLc];
    linphone_core_clear_proxy_config(lc);
    linphone_core_clear_all_auth_info(lc);
    
    [[LPSystemUser sharedUser].settingsStore transformLinphoneCoreToKeys];
    
    [LPSystemUser sharedUser].hasLoginSuccess = NO;
    
    [LPSystemUser sharedUser].hasGetMeetingData = NO;
    [LPSystemUser sharedUser].myScheduleMeetings = @[];
    [LPSystemUser sharedUser].myMeetingsRooms = @[];
    [LPSystemUser sharedUser].myFavMeetings = @[];
}

// 重置帐号信息，相当于是退出操作
- (void)resetAccount {
    [self clearProxyConfig];
    
    [[LinphoneManager instance] lpConfigSetBool:FALSE forKey:@"pushnotification_preference"];
    
    LinphoneCore *lc = [LinphoneManager getLc];
//    LCSipTransports transportValue={5060,5060,-1,-1};
    
    UseTheTCP80Port
    LCSipTransports transportValue={80,80,-1,-1};
    
    if (linphone_core_set_sip_transports(lc, &transportValue)) {
        [LinphoneLogger logc:LinphoneLoggerError format:"cannot set transport"];
    }
    
    [[LinphoneManager instance] lpConfigSetString:@"" forKey:@"sharing_server_preference"];
    [[LinphoneManager instance] lpConfigSetBool:FALSE forKey:@"ice_preference"];
    [[LinphoneManager instance] lpConfigSetString:@"" forKey:@"stun_preference"];
    
    linphone_core_set_stun_server(lc, NULL);
    linphone_core_set_firewall_policy(lc, LinphonePolicyNoFirewall);
}

- (void)clearProxyConfig {
    linphone_core_clear_proxy_config([LinphoneManager getLc]);
    linphone_core_clear_all_auth_info([LinphoneManager getLc]);
}

// 静音
- (IBAction)defaultVoiceSwitched:(id)sender {
    [LPSystemSetting sharedSetting].defaultSilence = ((UISwitch *)sender).on;
}

// 静画
- (IBAction)defaultMovieSwitched:(id)sender {
    [LPSystemSetting sharedSetting].defaultNoVideo = ((UISwitch *)sender).on;
    
    [[LPSystemUser sharedUser].settingsStore setBool:!([LPSystemSetting sharedSetting].defaultNoVideo) forKey:@"enable_video_preference"];

    
    LinphoneCore *lc=[LinphoneManager getLc];
    
    bool enableVideo = [LPSystemSetting sharedSetting].defaultNoVideo;
    linphone_core_enable_video(lc, enableVideo, enableVideo);

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
