//
//  LPJoinMettingViewController.m
//  linphone
//
//  Created by heqin on 15/11/7.
//
//

#import "LPJoinMettingViewController.h"
#import "LPMeetingRoom.h"
#import "LPSystemSetting.h"
#import "LPLoginViewController.h"
#import "PhoneMainView.h"
#import "LPSystemUser.h"
#import "UIViewController+RDRTipAndAlert.h"

@interface LPJoinMettingViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITableView *historyTable;
@property (weak, nonatomic) IBOutlet UITextField *joinNameField;
@property (weak, nonatomic) IBOutlet UITextField *joinMeetingNumberField;

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UILabel *loginTipLabel;

@end

@implementation LPJoinMettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgTapRecognizered:)]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Set observer
    [[NSNotificationCenter defaultCenter]	addObserver:self
                                             selector:@selector(registrationUpdate:)
                                                 name:kLinphoneRegistrationUpdate
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter]	addObserver:self
                                             selector:@selector(globalStateUpdate:)
                                                 name:kLinphoneGlobalStateUpdate
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    
    // Remove observer
    [[NSNotificationCenter defaultCenter]	removeObserver:self
                                                    name:kLinphoneRegistrationUpdate
                                                  object:nil];
    [[NSNotificationCenter defaultCenter]	removeObserver:self
                                                    name:kLinphoneGlobalStateUpdate
                                                  object:nil];
}

- (void)registrationUpdate: (NSNotification*) notif {
    LinphoneProxyConfig* config = NULL;
    linphone_core_get_default_proxy([LinphoneManager getLc], &config);
    [self proxyConfigUpdate:config];
}

- (void) globalStateUpdate:(NSNotification*) notif {
    [self registrationUpdate:notif];
}

- (void)proxyConfigUpdate: (LinphoneProxyConfig*) config {
    LinphoneRegistrationState state = LinphoneRegistrationNone;
    
    NSString* message = nil;
    UIImage* image = nil;
    
    LinphoneCore* lc = [LinphoneManager getLc];
    LinphoneGlobalState gstate = linphone_core_get_global_state(lc);
    
    if( gstate == LinphoneGlobalConfiguring ){
        message = NSLocalizedString(@"Fetching remote configuration", nil);
    } else if (config == NULL) {
        state = LinphoneRegistrationNone;
        if(linphone_core_is_network_reachable([LinphoneManager getLc]))
            message = NSLocalizedString(@"No SIP account configured", nil);
        else
            message = NSLocalizedString(@"Network down", nil);
    } else {
        state = linphone_proxy_config_get_state(config);
        
        switch (state) {
            case LinphoneRegistrationOk:
                message = NSLocalizedString(@"Registered", nil);
                self.loginBtn.enabled = YES;
                [self.loginBtn setTitle:@"退出" forState:UIControlStateNormal];
                
                [LPSystemUser sharedUser].hasLogin = YES;                

                break;
            case LinphoneRegistrationNone:
            case LinphoneRegistrationCleared:
                self.loginBtn.enabled = YES;
                [self.loginBtn setTitle:@"登录" forState:UIControlStateNormal];
                message =  NSLocalizedString(@"Not registered", nil);
                
                [LPSystemUser sharedUser].hasLogin = NO;
                break;
            case LinphoneRegistrationFailed:
                self.loginBtn.enabled = YES;
                [self.loginBtn setTitle:@"登录." forState:UIControlStateNormal];
                message =  NSLocalizedString(@"Registration failed", nil);
                
                [LPSystemUser sharedUser].hasLogin = NO;
                break;
            case LinphoneRegistrationProgress:
                self.loginBtn.enabled = NO;
                [self.loginBtn setTitle:@"登录中" forState:UIControlStateNormal];
                message =  NSLocalizedString(@"Registration in progress", nil);
                break;
            default: break;
        }
    }
    
    self.loginTipLabel.text = message;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UICompositeViewDelegate Functions

static UICompositeViewDescription *compositeDescription = nil;

+ (UICompositeViewDescription *)compositeViewDescription {
    if(compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:@"Join"
                                                                content:@"LPJoinMettingViewController"
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

- (void)bgTapRecognizered:(UITapGestureRecognizer *)tapGesture {
    [self resignKeyboard];
}

- (void)resignKeyboard {
    [self.joinNameField resignFirstResponder];
    [self.joinMeetingNumberField resignFirstResponder];
}

- (IBAction)revokeToOldVersionBtnClicked:(id)sender {
    [self resignKeyboard];

    WizardViewController *controller = DYNAMIC_CAST([[PhoneMainView instance] changeCurrentView:[WizardViewController compositeViewDescription]], WizardViewController);
    if(controller != nil) {
        [controller reset];
    }
}

- (IBAction)loginBtnClicked:(id)sender {
    [self resignKeyboard];

    NSString *btnTitle = [((UIButton *)sender) titleForState:UIControlStateNormal];
    if ([btnTitle isEqualToString:@"登录中"]) {
        NSLog(@"current is logining...");
        return;
    }else if ([btnTitle isEqualToString:@"登录."] || [btnTitle isEqualToString:@"登录"]) {
        // 进入正常的登录界面
        NSLog(@"ask for login");
        [[PhoneMainView instance] changeCurrentView:[LPLoginViewController compositeViewDescription]];
    }else if ([btnTitle isEqualToString:@"退出"]) {
        NSLog(@"ask for login out");
        // 先置数据为空
        // 需要把settingsStore中的数据进行清空
//        [settingsStore setObject:username forKey:@"username_preference"];
//        [settingsStore setObject:userIdStr forKey:@"userid_preference"];
//        [settingsStore setObject:password forKey:@"password_preference"];
//        [settingsStore setObject:domain forKey:@"domain_preference"];
//        [settingsStore setObject:transport forKey:@"transport_preference"];
        // 然后再执行
//        [settingsStore synchronize];
        
        // 另外，还应该让其暂时不去进行登录尝试，否则会一直尝试中
        
        // 再进行退出
//        [[LinphoneManager instance] resetLinphoneCore];
    }
}

- (IBAction)changeNameBtnClicked:(id)sender {
    [self resignKeyboard];
}

- (IBAction)joinBtnClicked:(id)sender {
    if (self.joinMeetingNumberField.text.length == 0) {
        [self showToastWithMessage:@"请输入会议号码"];
        
        [self.joinMeetingNumberField becomeFirstResponder];
    }else {
        [self resignKeyboard];
        
        // 进入到会议中
        DialerViewController *controller = DYNAMIC_CAST([[PhoneMainView instance] changeCurrentView:[DialerViewController compositeViewDescription]], DialerViewController);
        if (controller != nil) {
            controller.addressField.text = self.joinMeetingNumberField.text;
            controller.transferMode = YES;
            
            [controller.callButton touchUp:nil];

            NSLog(@"heqin will dispatch after");
        }
    }
}

#pragma mark UITabelView delegate & datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectio {
    return [LPSystemSetting sharedSetting].historyMeetings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellId = @"UIJoinHistoryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:kCellId];
    }
    
    LPMeetingRoom *curRoom = nil;
    if ([LPSystemSetting sharedSetting].historyMeetings.count <= indexPath.row) {
        curRoom = [[LPMeetingRoom alloc] init];
        curRoom.meetingName = @"无数据Meeting";
        curRoom.meetingId = 0;
        curRoom.meetingCallTime = [NSDate dateWithTimeIntervalSinceNow:(- 60 * 60 * 24)];
    }else {
        curRoom = [[LPSystemSetting sharedSetting].historyMeetings objectAtIndex:indexPath.row];
    }
    
    cell.textLabel.text = curRoom.meetingName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", curRoom.meetingCallTime];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"历史会议";
}

@end
