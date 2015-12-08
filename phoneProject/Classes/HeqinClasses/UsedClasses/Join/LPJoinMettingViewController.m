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
#import "UIHistoryCell.h"
#import "UACellBackgroundView.h"
#import "UILinphone.h"
#import "DialerViewController.h"

@interface LPJoinMettingViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
}

@property (nonatomic, weak) IBOutlet UITableView *historyTable;
@property (weak, nonatomic) IBOutlet UITextField *joinNameField;
@property (weak, nonatomic) IBOutlet UITextField *joinMeetingNumberField;

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UILabel *loginTipLabel;
@property (weak, nonatomic) IBOutlet UIButton *joinBtn;

@end

@implementation LPJoinMettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [LPSystemUser sharedUser];      // 进行初始化，以防后面没有进行初始化
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgTapRecognizered:)]];
    
    self.joinNameField.text = [LPSystemSetting sharedSetting].joinerName;
    
    self.historyTable.tableFooterView = [[UIView alloc] init];
    self.historyTable.tableHeaderView = [[UIView alloc] init];
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
    
    [[NSNotificationCenter defaultCenter]	removeObserver:self
                                                    name:kLinphoneRegistrationUpdate
                                                  object:nil];
    [[NSNotificationCenter defaultCenter]	removeObserver:self
                                                    name:kLinphoneGlobalStateUpdate
                                                  object:nil];
    
    // 每次回到这个界面进行刷新， 因为历史会议数据可能已经更新
    [self.historyTable reloadData];
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
            case LinphoneRegistrationOk: {
                message = @"已注册";
                self.loginBtn.enabled = YES;
                [self.loginBtn setTitle:@"退出" forState:UIControlStateNormal];
                
                self.joinBtn.enabled = YES;
                
                [LPSystemUser sharedUser].hasLogin = YES;                
                
                // 取出存储在settingsStore中的用户名和用户id信息
                NSString *nameStr = [[LPSystemUser sharedUser].settingsStore stringForKey:@"username_preference"];
                NSString *idStr = [[LPSystemUser sharedUser].settingsStore stringForKey:@"userid_preference"];
                
                [LPSystemUser sharedUser].loginUserId = idStr;
                [LPSystemUser sharedUser].loginUserName = nameStr;
                break;
            }
            case LinphoneRegistrationNone:
            case LinphoneRegistrationCleared:
                self.loginBtn.enabled = YES;
                [self.loginBtn setTitle:@"登录" forState:UIControlStateNormal];
                message = @"未注册";
                
                [LPSystemUser sharedUser].hasLogin = NO;
                
                self.joinBtn.enabled = NO;

                break;
            case LinphoneRegistrationFailed:
                self.loginBtn.enabled = YES;
                [self.loginBtn setTitle:@"登录." forState:UIControlStateNormal];
                message = @"注册失败";
                
                self.joinBtn.enabled = NO;
                
                [LPSystemUser sharedUser].hasLogin = NO;
                break;
            case LinphoneRegistrationProgress:
                self.loginBtn.enabled = NO;
                [self.loginBtn setTitle:@"登录中" forState:UIControlStateNormal];
                message = @"注册中";
                
                self.joinBtn.enabled = NO;

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
    }
}

- (IBAction)changeNameBtnClicked:(id)sender {
    [self resignKeyboard];

    [LPSystemSetting sharedSetting].joinerName = self.joinNameField.text;
    
    LinphoneCore *lc=[LinphoneManager getLc];
    LinphoneAddress *parsed = linphone_core_get_primary_contact_parsed(lc);
    if(parsed != NULL) {
        linphone_address_set_display_name(parsed,[self.joinNameField.text cStringUsingEncoding:[NSString defaultCStringEncoding]]);
    }
}

- (IBAction)joinBtnClicked:(id)sender {
    if (self.joinMeetingNumberField.text.length == 0) {
        [self showToastWithMessage:@"请输入会议号码"];
        
        [self.joinMeetingNumberField becomeFirstResponder];
    }else {
        [self resignKeyboard];
        
        // 取设置的名字
        NSString *address = self.joinMeetingNumberField.text;
        NSString *displayName = self.joinNameField.text.length > 0 ? self.joinNameField.text : nil;
        
        [self joinMeeting:address withDisplayName:displayName];
    }
}

- (void)joinMeeting:(NSString *)address withDisplayName:(NSString *)displayName {
    if (address.length == 0) {
        [self showToastWithMessage:@"无效的地址，请重新输入"];
        return;
    }
    
    // 进入到会议中
    DialerViewController *controller = DYNAMIC_CAST([[PhoneMainView instance] changeCurrentView:[DialerViewController compositeViewDescription]], DialerViewController);
    if (controller != nil) {
        NSLog(@"进入会议中, addres=%@, displayName=%@", address, displayName);
        [controller call:address displayName:displayName];
    }
}

#pragma mark UITabelView delegate & datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectio {
//    return [LPSystemSetting sharedSetting].historyMeetings.count;
    
    return [LPSystemUser sharedUser].callLogs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *kCellId = @"UIHistoryCell";
    UIHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    if (cell == nil) {
        cell = [[UIHistoryCell alloc] initWithIdentifier:kCellId];
        // Background View
        UACellBackgroundView *selectedBackgroundView = [[UACellBackgroundView alloc] initWithFrame:CGRectZero];
        cell.selectedBackgroundView = selectedBackgroundView;
        [selectedBackgroundView setBackgroundColor:LINPHONE_TABLE_CELL_BACKGROUND_COLOR];
    }
    
    LinphoneCallLog *log = [[ [LPSystemUser sharedUser].callLogs objectAtIndex:[indexPath row]] pointerValue];
    [cell setCallLog:log];
    
    return cell;

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"历史会议(点击直接进入)";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    LinphoneCallLog *callLog = [[ [LPSystemUser sharedUser].callLogs objectAtIndex:[indexPath row]] pointerValue];
    LinphoneAddress* addr;
    if (linphone_call_log_get_dir(callLog) == LinphoneCallIncoming) {
        addr = linphone_call_log_get_from(callLog);
    } else {
        addr = linphone_call_log_get_to(callLog);
    }
    
    NSString* displayName = nil;
    NSString* address = nil;
    if(addr != NULL) {
        BOOL useLinphoneAddress = true;
        // contact name
        char* lAddress = linphone_address_as_string_uri_only(addr);
        if(lAddress) {
            address = [NSString stringWithUTF8String:lAddress];
            NSString *normalizedSipAddress = [FastAddressBook normalizeSipURI:address];
            ABRecordRef contact = [[[LinphoneManager instance] fastAddressBook] getContact:normalizedSipAddress];
            if(contact) {
                displayName = [FastAddressBook getContactDisplayName:contact];
                useLinphoneAddress = false;
            }
            ms_free(lAddress);
        }
        if(useLinphoneAddress) {
            const char* lDisplayName = linphone_address_get_display_name(addr);
            if (lDisplayName)
                displayName = [NSString stringWithUTF8String:lDisplayName];
        }
    }
    
    [self joinMeeting:address withDisplayName:displayName];
}

@end
