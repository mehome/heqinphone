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

@interface LPLoginViewController () <UITextFieldDelegate> {
    LinphoneCoreSettingsStore *settingsStore;
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
    settingsStore = [[LinphoneCoreSettingsStore alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [settingsStore transformLinphoneCoreToKeys]; // Sync settings with linphone core settings

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
//            [[PhoneMainView instance] changeCurrentView:[DialerViewController compositeViewDescription]];
            
            [LPSystemUser sharedUser].hasLogin = YES;
            
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
                                                                 tabBar:@"LPJoinBarViewController"
                                                          tabBarEnabled:true
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

- (IBAction)backBtnClicked:(id)sender {
    [self resignKeyboard];
    
    // 回到首页
    [[PhoneMainView instance] changeCurrentView:[LPJoinMettingViewController compositeViewDescription]];
}

- (IBAction)forgetBtnClicked:(id)sender {
    [self resignKeyboard];
}

- (IBAction)loginBtnClicked:(id)sender {
    [self resignKeyboard];
    
    // 进行SIP注册功能
    NSString *username  = @"feng.wang";   //self.userNameField.text;
    NSString *userId = @"feng.wang@zijingcloud.com";
    NSString *password  = @"wang@2015";  //self.userPasswordField.text;
    NSString *domain    = @"120.132.87.181";
    NSString *transport = @"UDP";
    
    [self verificationSignInWithUsername:username userId:userId password:password domain:domain withTransport:transport];
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
            // 存储下来
            [LPSystemUser sharedUser].hasLogin = NO;
            [LPSystemUser sharedUser].loginUserName = username;
            [LPSystemUser sharedUser].loginUserId = userIdStr;
            [LPSystemUser sharedUser].loginUserPassword = password;
            
            [settingsStore setObject:username forKey:@"username_preference"];
            [settingsStore setObject:userIdStr forKey:@"userid_preference"];
            [settingsStore setObject:password forKey:@"password_preference"];
            [settingsStore setObject:domain forKey:@"domain_preference"];
            [settingsStore setObject:transport forKey:@"transport_preference"];

//            [settingsStore setString:username forKey:@"username_preference"];
            
            [settingsStore synchronize];

//            BOOL success = [self addProxyConfig:username password:password domain:domain withTransport:transport];
//            if( !success ){
//                [self hideHudAndIndicatorView];
//            }
            
        }
    }
}

@end
