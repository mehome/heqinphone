//
//  LPLoginViewController.m
//  linphone
//
//  Created by heqin on 15/11/7.
//
//

#import "LPLoginViewController.h"
#import "PhoneMainView.h"
#import "LPJoinMettingViewController.h"
#import "UIViewController+RDRTipAndAlert.h"
#import "LPSystemUser.h"
#import "LPSystemSetting.h"
#import "LPJoinManageMeetingViewController.h"

@interface LPLoginViewController () <UITextFieldDelegate> {
}

@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *userPasswordField;

@property (weak, nonatomic) UITextField *activeTextField;

@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@end

@implementation LPLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgTapGestured:)]];
    
    self.backBtn.backgroundColor = yellowSubjectColor;
    self.backBtn.layer.cornerRadius = 5.0;
    self.backBtn.clipsToBounds = YES;

    self.loginBtn.backgroundColor = yellowSubjectColor;
    self.loginBtn.layer.cornerRadius = 5.0;
    self.loginBtn.clipsToBounds = YES;

    // 控制返回按钮的显示和隐藏
//    self.backBtn.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(allLifetimeRegistrationUpdateEvent:)
                                                 name:kLinphoneRegistrationUpdate
                                               object:nil];
}

static BOOL loginIsTheTopVC = NO;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    loginIsTheTopVC = YES;
    
    //
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(registrationUpdateEvent:)
//                                                 name:kLinphoneRegistrationUpdate
//                                               object:nil];
    
    if ( kNotLoginCheck ) {
        // 当前处于登出状态
//        self.userNameField.text = @"feng.wang@zijingcloud.com";
//        self.userPasswordField.text = @"wang@2015";
        
//        self.userNameField.text = @"hbuc3@meeting123.net";
//        self.userPasswordField.text = @"1234";


//        self.userNameField.text = @"client@zijingcloud.com";
//        self.userPasswordField.text = @"test&temp";

//        self.userNameField.text = @"qin.he@zijingcloud.com";
//        self.userPasswordField.text = @"he@2015";
        
    }else {
        // 当前已处于登录状态
        [[LPSystemUser sharedUser].settingsStore transformLinphoneCoreToKeys];
        self.userNameField.text = [[LPSystemUser sharedUser].settingsStore stringForKey:@"account_mandatory_username_preference"];
        self.userPasswordField.text = @"xxxxxx";
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:kLinphoneRegistrationUpdate
//                                                  object:nil];
    loginIsTheTopVC = NO;
}

// 解决有时出现的界面隐藏功能一直没有去掉的问题.
- (void)allLifetimeRegistrationUpdateEvent:(NSNotification *)notif {
    [self registrationUpdate:[[notif.userInfo objectForKey: @"state"] intValue]];
    return;
}

#pragma mark - Event Functions
- (void)registrationUpdateEvent:(NSNotification*)notif {
    [self registrationUpdate:[[notif.userInfo objectForKey: @"state"] intValue]];
}

- (void)registrationUpdate:(LinphoneRegistrationState)state {
    NSLog(@"registrationUpdate state=%d", state);
    switch (state) {
        case LinphoneRegistrationOk: {
            
            // 把值同步进去，进行存储
//            [[LPSystemUser sharedUser].settingsStore transformLinphoneCoreToKeys];

            [[LinphoneManager instance] lpConfigSetBool:FALSE forKey:@"enable_first_login_view_preference"];
            
            [LPSystemUser sharedUser].hasLoginSuccess = YES;
            
            NSLog(@"registration ok.");
            [self hideHudAndIndicatorView];

            // 存储其中的值
            // 登录成功，切换到LPJoinManageMeetingViewController页
            
            if (loginIsTheTopVC == YES) {
                [[PhoneMainView instance] changeCurrentView:[LPJoinManageMeetingViewController compositeViewDescription]];
            }else {
                NSLog(@"在后台， 什么都不做");
            }
            break;
        }
        case LinphoneRegistrationNone:
        case LinphoneRegistrationCleared:
            [self hideHudAndIndicatorView];

            break;
        case LinphoneRegistrationFailed: {
            [self hideHudAndIndicatorView];

            [LPSystemUser sharedUser].hasLoginSuccess = NO;

            //erase uername passwd
            [[LinphoneManager instance] lpConfigSetString:nil forKey:@"wizard_username"];
            [[LinphoneManager instance] lpConfigSetString:nil forKey:@"wizard_password"];
            
            break;
        }
        case LinphoneRegistrationProgress: {
            break;
        }
        default: break;
    }
}

#pragma mark - UITextfield Event Functions
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeTextField = textField;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // only validate the username when creating a new account
//    if( textField == self.userNameField ){
//        NSRegularExpression *regex = [NSRegularExpression
//                                      regularExpressionWithPattern:@"^[a-z0-9-_\\.]*$"
//                                      options:NSRegularExpressionCaseInsensitive
//                                      error:nil];
//        NSArray* matches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
//        if ([matches count] == 0) {
//            
//            [self showToastWithMessage:NSLocalizedString(@"Illegal character in username: %@", nil)];
//            
//            return NO;
//        }
//    }
    return YES;
}

#pragma mark - UICompositeViewDelegate Functions

static UICompositeViewDescription *compositeDescription = nil;

- (UICompositeViewDescription *)compositeViewDescription {
    return self.class.compositeViewDescription;
}

+ (UICompositeViewDescription *)compositeViewDescription {
    if(compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:self.class
                                                              statusBar:nil
                                                                 tabBar:[LPJoinBarViewController class]
                                                               sideMenu:nil
                                                             fullscreen:false
                                                         isLeftFragment:false
                                                           fragmentWith:nil
                                                   supportLandscapeMode:NO];

        compositeDescription.darkBackground = true;
    }
    return compositeDescription;
}

- (void)resignKeyboard {
    [self.userNameField resignFirstResponder];
    [self.userPasswordField resignFirstResponder];
}

-  (void)bgTapGestured:(UITapGestureRecognizer *)tapGesture {
    [self resignKeyboard];
}

// 跳转到首页
- (void)jumpToMettingViewController {
    [self resignKeyboard];
    
    if ([[PhoneMainView instance] popCurrentView] == nil) {
        // 则说明当前层为登录层，返回到加入会议层
        [[PhoneMainView instance] changeCurrentView:[LPJoinMettingViewController compositeViewDescription]];
    }
}

- (IBAction)backBtnClicked:(id)sender {
    [self jumpToMettingViewController];
}

- (IBAction)forgetBtnClicked:(id)sender {
    [self resignKeyboard];
}

- (IBAction)loginBtnClicked:(id)sender {
    [self resignKeyboard];
    
    if (self.userNameField.text.length == 0) {
        [self showToastWithMessage:@"请输入有效的用户名"];
        [self.userNameField becomeFirstResponder];
        return;
    }
    
    if (self.userPasswordField.text.length == 0) {
        [self showToastWithMessage:@"请输入用户密码"];
        [self.userPasswordField becomeFirstResponder];
        return;
    }
    
    // 清除操作
    [LPSystemUser sharedUser].hasGetMeetingData = NO;
    [LPSystemUser sharedUser].myScheduleMeetings = @[];
    [LPSystemUser sharedUser].myMeetingsRooms = @[];
    [LPSystemUser sharedUser].myFavMeetings = @[];
    
    // 进行SIP注册功能
    NSString *userIdStr = self.userNameField.text;
    NSString *password = self.userPasswordField.text;
    NSString *userName = [userIdStr copy];
    NSString *userDisplayName = [LPSystemSetting sharedSetting].joinerName;
    NSString *usedDomainStr = [LPSystemSetting sharedSetting].sipDomainStr;
    
    // 分割出userName， 域名
    if ([userIdStr containsString:@"@"]) {
        NSArray *componseArr = [userIdStr componentsSeparatedByString:@"@"];
        userName = componseArr[0];
        userIdStr = componseArr[0];
        usedDomainStr = componseArr[1];
    }else {
        // 不包含@，则直接使用当前输入为用户名，使用默认的domain
    }
    
    // 准备进行登录操作
    [self showLoadingView];
 
    NSDictionary *loginResult = [[LPSystemUser sharedUser] tryToLoginWithUserName:userName userId:userIdStr password:password displayName:userDisplayName domain:usedDomainStr];
    if (((NSNumber *)(loginResult[@"success"])).boolValue == NO) {
        NSString *failReasonStr = loginResult[@"reason"];
        NSLog(@"failReason=%@", failReasonStr);
        [self hideHudAndIndicatorView];
        
        [LPSystemUser sharedUser].hasLoginSuccess = NO;
    }else {
        // 等待登录的回调通知事件
    }
}

- (void)setDefaultSettings:(LinphoneProxyConfig*)proxyCfg {
    LinphoneManager* lm = [LinphoneManager instance];
    
    [lm configurePushTokenForProxyConfig:proxyCfg];
}

- (void)clearProxyConfig {
    linphone_core_clear_proxy_config([LinphoneManager getLc]);
    linphone_core_clear_all_auth_info([LinphoneManager getLc]);
}

- (BOOL)addProxyConfig:(NSString*)username password:(NSString*)password userIdStr:(NSString *)userIdStr domain:(NSString*)domain withTransport:(NSString*)transport {
    LinphoneCore* lc = [LinphoneManager getLc];
    LinphoneProxyConfig* proxyCfg = linphone_core_create_proxy_config(lc);
    NSString* server_address = domain;
    
    char normalizedUserName[256];
    linphone_proxy_config_normalize_number(proxyCfg, [username cStringUsingEncoding:[NSString defaultCStringEncoding]], normalizedUserName, sizeof(normalizedUserName));
    
    // TODO
    // 这里感觉应该是使用userIdStr, he.qin@zijingcloud.com来代替
    const char* identity = linphone_proxy_config_get_identity(proxyCfg);
    if( !identity || !*identity ) {
        identity = "sip:user@zijingcloud.com";
    }
    
    //    const char *identity = [@"sip:User name@IP:端口" cStringUsingEncoding:NSUTF8StringEncoding];   感觉这里应该弄成sip:qin.he@sip.myvmr.cn:80
    
    LinphoneAddress* linphoneAddress = linphone_address_new(identity);
    linphone_address_set_username(linphoneAddress, normalizedUserName);
    
    if( domain && [domain length] != 0) {
        if( transport != nil ){
            server_address = [NSString stringWithFormat:@"%@;transport=%@", server_address, [transport lowercaseString]];
            
            //            server_address = [NSString stringWithFormat:@"%@:%@;transport=%@", server_address, @"端口号", [transport lowercaseString]];
        }
        // when the domain is specified (for external login), take it as the server address
        linphone_proxy_config_set_server_addr(proxyCfg, [server_address UTF8String]);
        linphone_address_set_domain(linphoneAddress, [domain UTF8String]);
    }
    
    char* extractedAddres = linphone_address_as_string_uri_only(linphoneAddress);
    
    LinphoneAddress* parsedAddress = linphone_address_new(extractedAddres);
    ms_free(extractedAddres);
    
    if( parsedAddress == NULL || !linphone_address_is_sip(parsedAddress) ){
        if( parsedAddress ) linphone_address_destroy(parsedAddress);
        UIAlertView* errorView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Check error(s)",nil)
                                                            message:NSLocalizedString(@"Please enter a valid username", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Continue",nil)
                                                  otherButtonTitles:nil,nil];
        [errorView show];
        return FALSE;
    }
    
    char *c_parsedAddress = linphone_address_as_string_uri_only(parsedAddress);
    
    linphone_proxy_config_set_identity(proxyCfg, c_parsedAddress);
    
    linphone_address_destroy(parsedAddress);
    ms_free(c_parsedAddress);
    
    //    // 把没有添加的userId给添加上。
    //    if ([userIdStr hasSuffix:@"zijingcloud.com"] == NO) {
    //        userIdStr = [NSString stringWithFormat:@"%@@zijingcloud.com", username];
    //    }
    
    LinphoneAuthInfo* info = linphone_auth_info_new([username UTF8String],
                                                    [userIdStr UTF8String],
                                                    [password UTF8String]
                                                    , NULL
                                                    , NULL
                                                    ,linphone_proxy_config_get_domain(proxyCfg));
    
    [self setDefaultSettings:proxyCfg];
    
    [self clearProxyConfig];
    
    linphone_proxy_config_enable_register(proxyCfg, true);
    linphone_core_add_auth_info(lc, info);
    linphone_core_add_proxy_config(lc, proxyCfg);
    linphone_core_set_default_proxy_config(lc, proxyCfg);
    
    return TRUE;
}


@end
