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

@end

@implementation LPLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgTapGestured:)]];
    
    // 控制返回按钮的显示和隐藏
//    self.backBtn.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(registrationUpdateEvent:)
                                                 name:kLinphoneRegistrationUpdate
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(configuringUpdate:)
                                                 name:kLinphoneConfiguringStateUpdate
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kLinphoneRegistrationUpdate
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kLinphoneConfiguringStateUpdate
                                                  object:nil];
}


#pragma mark - Event Functions
- (void)registrationUpdateEvent:(NSNotification*)notif {
    [self registrationUpdate:[[notif.userInfo objectForKey: @"state"] intValue]];
}

- (void)registrationUpdate:(LinphoneRegistrationState)state {
    NSLog(@"registrationUpdate state=%d", state);
    switch (state) {
        case LinphoneRegistrationOk: {
            [[LinphoneManager instance] lpConfigSetBool:FALSE forKey:@"enable_first_login_view_preference"];
            
            [self hideHudAndIndicatorView];
            NSLog(@"registration ok.");
            [LPSystemUser sharedUser].hasLogin = YES;
            
            // 取出其中的值
            [[LPSystemUser sharedUser].settingsStore transformLinphoneCoreToKeys];
            
            NSString *nameStr = [[LPSystemUser sharedUser].settingsStore stringForKey:@"username_preference"];
            NSString *idStr = [[LPSystemUser sharedUser].settingsStore stringForKey:@"userid_preference"];
            
            [LPSystemUser sharedUser].loginUserId = idStr;
            [LPSystemUser sharedUser].loginUserName = nameStr;
            
            // 登录成功，切换到LPJoinManageMeetingViewController页
            [[PhoneMainView instance] changeCurrentView:[LPJoinManageMeetingViewController compositeViewDescription]];
            break;
        }
        case LinphoneRegistrationNone:
        case LinphoneRegistrationCleared: {
            [LPSystemUser sharedUser].hasLogin = NO;

            [self hideHudAndIndicatorView];
            break;
        }
        case LinphoneRegistrationFailed: {
            [LPSystemUser sharedUser].hasLogin = NO;

            [self hideHudAndIndicatorView];
            
            //erase uername passwd
            [[LinphoneManager instance] lpConfigSetString:nil forKey:@"wizard_username"];
            [[LinphoneManager instance] lpConfigSetString:nil forKey:@"wizard_password"];
            break;
        }
        case LinphoneRegistrationProgress: {
            [self showLoadingView];

            break;
        }
        default: break;
    }
}

- (void)configuringUpdate:(NSNotification *)notif {
    [self hideHudAndIndicatorView];

    LinphoneConfiguringState status = (LinphoneConfiguringState)[[notif.userInfo valueForKey:@"state"] integerValue];
    NSLog(@"login interface status=%d", status);
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
    if( textField == self.userNameField ){
        NSRegularExpression *regex = [NSRegularExpression
                                      regularExpressionWithPattern:@"^[a-z0-9-_\\.]*$"
                                      options:NSRegularExpressionCaseInsensitive
                                      error:nil];
        NSArray* matches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
        if ([matches count] == 0) {
            
            [self showToastWithMessage:NSLocalizedString(@"Illegal character in username: %@", nil)];
            
            return NO;
        }
    }
    return YES;
}

#pragma mark - UICompositeViewDelegate Functions

static UICompositeViewDescription *compositeDescription = nil;

+ (UICompositeViewDescription *)compositeViewDescription {
    if(compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:@"Login"
                                                                content:@"LPLoginViewController"
                                                               stateBar:nil
                                                        stateBarEnabled:false
                                                                 tabBar:nil
                                                          tabBarEnabled:false
                                                             fullscreen:false
                                                          landscapeMode:[LinphoneManager runningOnIpad]
                                                           portraitMode:true];
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
    
    [[PhoneMainView instance] changeCurrentView:[LPJoinMettingViewController compositeViewDescription]];
}


- (IBAction)backBtnClicked:(id)sender {
    [self jumpToMettingViewController];
}

- (IBAction)forgetBtnClicked:(id)sender {
    [self resignKeyboard];
}

- (IBAction)loginBtnClicked:(id)sender {
    [self resignKeyboard];
    
    // 进行SIP注册功能
//    NSString *username = self.userNameField.text;
//    NSString *userId = [NSString stringWithFormat:@"%@@zijingcloud.com", username];
//    NSString *password = self.userPasswordField.text;
//    NSString *transport = @"UDP";
    
    NSString *username = @"feng.wang";
    NSString *userId = @"feng.wang@zijingcloud.com";
    NSString *password = @"wang@2015";
    NSString *transport = @"UDP";
    
    [self verificationSignInWithUsername:username userId:userId password:password domain:[LPSystemSetting sharedSetting].sipDomainStr withTransport:transport];
}

- (void) verificationSignInWithUsername:(NSString*)username userId:(NSString *)userIdStr password:(NSString*)password domain:(NSString*)domain withTransport:(NSString*)transport {
    NSLog(@"verificationSignInWithUsername username=%@, userIdStr=%@, password=%@, domain=%@, transport=%@",
          username, userIdStr, password, domain, transport);
    NSMutableString *errors = [NSMutableString string];
    if ([username length] == 0) {
        [errors appendString:[NSString stringWithFormat:NSLocalizedString(@"Please enter a valid username.\n", nil)]];
    }
    
    if (domain != nil && [domain length] == 0) {
        [errors appendString:[NSString stringWithFormat:NSLocalizedString(@"Please enter a valid domain.\n", nil)]];
    }
    
    if([errors length] > 0) {
        UIAlertView* errorView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Check error(s)",nil)
                                                            message:[errors substringWithRange:NSMakeRange(0, [errors length] - 1)]
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"Continue",nil)
                                                  otherButtonTitles:nil,nil];
        [errorView show];
        
    } else {
        [self showLoadingView];
        
        if ([LinphoneManager instance].connectivity == none) {
            [self showAlertWithTitle:@"提示" andMessage:NSLocalizedString(@"No connectivity", nil)];
        } else {
            
            BOOL success = [self addProxyConfig:username password:password userIdStr:userIdStr domain:domain withTransport:transport];
            if (success == YES) {
                // 登录成功
                [self showToastWithMessage:@"登录成功"];
                
                //            [[LPSystemUser sharedUser].settingsStore setObject:username forKey:@"username_preference"];
                //            [[LPSystemUser sharedUser].settingsStore setObject:userIdStr forKey:@"userid_preference"];
                //            [[LPSystemUser sharedUser].settingsStore setObject:password forKey:@"password_preference"];
                //            [[LPSystemUser sharedUser].settingsStore setObject:domain forKey:@"domain_preference"];
                //            [[LPSystemUser sharedUser].settingsStore setObject:transport forKey:@"transport_preference"];
                //
                //            [[LPSystemUser sharedUser].settingsStore synchronize];

                
                // 存储下来
                [LPSystemUser sharedUser].hasLogin = YES;
                [LPSystemUser sharedUser].loginUserName = username;
                [LPSystemUser sharedUser].loginUserPassword = password;
                [LPSystemUser sharedUser].loginUserId = userIdStr;
                
                // 返回到首页
                [self jumpToMettingViewController];
                
            }else {
                // 登录失败
                [self showToastWithMessage:@"登录失败"];
            }
        }
    }
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
        identity = "sip:user@example.com";
    }
    
    LinphoneAddress* linphoneAddress = linphone_address_new(identity);
    linphone_address_set_username(linphoneAddress, normalizedUserName);
    
    if( domain && [domain length] != 0) {
        if( transport != nil ){
            server_address = [NSString stringWithFormat:@"%@;transport=%@", server_address, [transport lowercaseString]];
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
    
    // 把没有添加的userId给添加上。
    if ([userIdStr hasSuffix:@"zijingcloud.com"] == NO) {
        userIdStr = [NSString stringWithFormat:@"%@@zijingcloud.com", username];
    }
    
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

- (void)setDefaultSettings:(LinphoneProxyConfig*)proxyCfg {
    LinphoneManager* lm = [LinphoneManager instance];
    
    [lm configurePushTokenForProxyConfig:proxyCfg];
}

- (void)clearProxyConfig {
    linphone_core_clear_proxy_config([LinphoneManager getLc]);
    linphone_core_clear_all_auth_info([LinphoneManager getLc]);
}


@end
