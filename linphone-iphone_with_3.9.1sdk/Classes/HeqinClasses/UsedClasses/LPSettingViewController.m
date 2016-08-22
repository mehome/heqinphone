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
#import "LPLoginViewController.h"

@interface LPSettingViewController () <UITextFieldDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;

@property (weak, nonatomic) IBOutlet UILabel *nameField;
@property (weak, nonatomic) IBOutlet UILabel *accountField;
@property (weak, nonatomic) IBOutlet UILabel *companyField;

@property (weak, nonatomic) IBOutlet UILabel *serverAddressLabel;

@property (weak, nonatomic) IBOutlet UISwitch *defaultSilentVoiceSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *defaultSilentMovieSwitch;

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@property (strong, nonatomic) IBOutlet UIButton *videoSizeBtn;
@property (strong, nonatomic) IBOutlet UIButton *videoFrameBtn;

@end

#define kLogoutAlertTag 90902

@implementation LPSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgTap:)]];
    
    self.logoutBtn.backgroundColor = yellowSubjectColor;
    self.logoutBtn.layer.cornerRadius = 5.0;
    self.logoutBtn.clipsToBounds = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(allLifetimeSettingRegistrationUpdateEvent:)
                                                 name:kLinphoneRegistrationUpdate
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 初始化各个界面信息
    [self initDynamicInfos];
    
    [self refrshVideoSettings];
}

- (void)initDynamicInfos {
    self.defaultSilentVoiceSwitch.on = [LPSystemSetting sharedSetting].defaultSilence;
    self.defaultSilentMovieSwitch.on = [LPSystemSetting sharedSetting].defaultNoVideo;
    
    // 显示服务器地址
    self.serverAddressLabel.text = [LPSystemSetting sharedSetting].sipTmpProxy;
    
    self.versionLabel.text = [NSString stringWithFormat:@"%@ (%@)",
                              [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                              [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
    
    if (kNotLoginCheck ) {
        // 当前已经注销
        [self.logoutBtn setTitle:@"登录" forState:UIControlStateNormal];
        self.nameField.text = @"";
        self.accountField.text = @"";
        self.companyField.text = @"";

    }else {
        // 当前已经登录
        [self.logoutBtn setTitle:@"注销" forState:UIControlStateNormal];
        self.nameField.text = [[LPSystemUser sharedUser].settingsStore stringForKey:@"account_userid_preference"];
        self.accountField.text = [[LPSystemUser sharedUser].settingsStore stringForKey:@"account_userid_preference"];
        self.companyField.text = @"企业信息";
    }
}

- (void)refrshVideoSettings {
    NSInteger videoFrameInt = [LPSystemSetting sharedSetting].videoFrameType;
    if (videoFrameInt == 0) {
        [self.videoFrameBtn setTitle:@"20" forState:UIControlStateNormal];
    }else if (videoFrameInt == 15) {
        [self.videoFrameBtn setTitle:@"15" forState:UIControlStateNormal];
    }else if (videoFrameInt == 20) {
        [self.videoFrameBtn setTitle:@"20" forState:UIControlStateNormal];
    }else if (videoFrameInt == 30) {
        [self.videoFrameBtn setTitle:@"30" forState:UIControlStateNormal];
    }else {
        [self.videoFrameBtn setTitle:@"20" forState:UIControlStateNormal];
    }
    
    NSInteger vidoeSizeInt  = [LPSystemSetting sharedSetting].videoSizeType;
    if (vidoeSizeInt == 0) {
        [self.videoSizeBtn setTitle:@"标清(CIF) >" forState:UIControlStateNormal];
    }else if (vidoeSizeInt == 1) {
        [self.videoSizeBtn setTitle:@"高清(720P) >" forState:UIControlStateNormal];
    }else if (vidoeSizeInt == 2) {
        [self.videoSizeBtn setTitle:@"超高清(1020P) >" forState:UIControlStateNormal];
    }else {
        [self.videoSizeBtn setTitle:@"标清(CIF) >" forState:UIControlStateNormal];
    }
}

- (void)bgTap:(UITapGestureRecognizer *)tapGesture {
}

- (void)allLifetimeSettingRegistrationUpdateEvent:(NSNotification *)notif {
    LinphoneRegistrationState stateInt = [(NSNumber *)[notif.userInfo objectForKey: @"state"] intValue];
    switch (stateInt) {
        case LinphoneRegistrationOk:
        case LinphoneRegistrationNone:
        case LinphoneRegistrationCleared:
        case LinphoneRegistrationFailed:
            [self initDynamicInfos];
            // 注册失败
            break;
        case LinphoneRegistrationProgress:
            // 注册中
            break;
        default: break;
    }
}

- (IBAction)videoSizeClicked:(id)sender {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"视频清晰度" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertVC addAction:[UIAlertAction actionWithTitle:@"标清(CIF)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self setupVideoSize:0];
    }]];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"高清(720P)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self setupVideoSize:1];
    }]];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"超高清(1020P)" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self setupVideoSize:2];
    }]];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];

    [self presentViewController:alertVC animated:YES completion:nil];
}

- (IBAction)videoFrameClicked:(id)sender {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"视频帧率" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertVC addAction:[UIAlertAction actionWithTitle:@"15" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self setupVideoFrame:15];
    }]];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"20" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self setupVideoFrame:20];
    }]];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"30" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self setupVideoFrame:30];
    }]];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];

    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)setupVideoSize:(NSInteger)sizeInt {
    MSVideoSize vsize;
    if (sizeInt == 0) {
        MS_VIDEO_SIZE_ASSIGN(vsize, CIF);
   }else if (sizeInt == 1) {
       MS_VIDEO_SIZE_ASSIGN(vsize, 720P);
    }else if (sizeInt == 2){
        MS_VIDEO_SIZE_ASSIGN(vsize, 1024);
    }else {
        MS_VIDEO_SIZE_ASSIGN(vsize, CIF);
    }

    linphone_core_set_preferred_video_size(LC, vsize);

    [LPSystemSetting sharedSetting].videoSizeType = sizeInt;
    [[LPSystemSetting sharedSetting] saveCacheSetting];
    
    [self refrshVideoSettings];
}

- (void)setupVideoFrame:(NSInteger)frameType {
    linphone_core_set_preferred_framerate(LC, frameType);

    [LPSystemSetting sharedSetting].videoFrameType = frameType;
    [[LPSystemSetting sharedSetting] saveCacheSetting];
    
    [self refrshVideoSettings];
}

// 注销按钮
- (IBAction)logoutBtnClicked:(id)sender {
    if ( kNotLoginCheck) {      // 执行登录操作
        [[PhoneMainView instance] changeCurrentView:[LPLoginViewController compositeViewDescription]];
    }else {         // 执行注销提示
        UIAlertView *tipAlert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您确认要注销么？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        tipAlert.tag = kLogoutAlertTag;
        [tipAlert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex NS_DEPRECATED_IOS(2_0, 9_0) {
    if (alertView.tag == kLogoutAlertTag) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            // 执行注销操作
            [self clearAccountFromSetting];
            
            // 刷新当前界面顶部的用户信息即可
            [self initDynamicInfos];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"kCurUserLoginOutNotification" object:nil];
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
        LOGE(@"cannot set transport");
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

// 默认静音
- (IBAction)defaultVoiceSwitched:(id)sender {
    [LPSystemSetting sharedSetting].defaultSilence = ((UISwitch *)sender).on;
}

// 默认静画
- (IBAction)defaultMovieSwitched:(id)sender {
    [LPSystemSetting sharedSetting].defaultNoVideo = ((UISwitch *)sender).on;
    
    [[LPSystemUser sharedUser].settingsStore setBool:!([LPSystemSetting sharedSetting].defaultNoVideo) forKey:@"enable_video_preference"];

    
    LinphoneCore *lc=[LinphoneManager getLc];
    
    bool enableVideo = [LPSystemSetting sharedSetting].defaultNoVideo;
//    linphone_core_enable_video(lc, enableVideo, enableVideo);
    linphone_core_enable_video_capture(lc, enableVideo);
    linphone_core_enable_video_display(lc, enableVideo);

}

#pragma mark - UICompositeViewDelegate Functions

static UICompositeViewDescription *compositeDescription = nil;

- (UICompositeViewDescription *)compositeViewDescription {
    return self.class.compositeViewDescription;
}

+ (UICompositeViewDescription *)compositeViewDescription {
    if(compositeDescription == nil) {
//        compositeDescription = [[UICompositeViewDescription alloc] init:@"Setting"
//                                                                content:@"LPSettingViewController"
//                                                               stateBar:nil
//                                                        stateBarEnabled:false
//                                                                 tabBar:@"LPJoinBarViewController"
//                                                          tabBarEnabled:true
//                                                             fullscreen:false
//                                                          landscapeMode:[LinphoneManager runningOnIpad]
//                                                           portraitMode:true];
        compositeDescription = [[UICompositeViewDescription alloc] init:self.class
                                                              statusBar:nil
                                                                 tabBar:[LPJoinBarViewController class]
                                                               sideMenu:nil
                                                             fullscreen:NO
                                                         isLeftFragment:NO
                                                           fragmentWith:nil
                                                   supportLandscapeMode:NO];

        compositeDescription.darkBackground = true;
    }
    return compositeDescription;
}

@end
