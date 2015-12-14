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
@property (weak, nonatomic) IBOutlet UILabel *tableTipLabel;

@property (weak, nonatomic) IBOutlet UITextField *joinNameField;
@property (weak, nonatomic) IBOutlet UITextField *joinMeetingNumberField;

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UILabel *loginTipLabel;
@property (weak, nonatomic) IBOutlet UIButton *joinBtn;

@property (retain, nonatomic) NSDateFormatter *dateFormatter;



@end

@implementation LPJoinMettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [LPSystemUser sharedUser];      // 进行初始化，以防后面没有进行初始化
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgTapRecognizered:)]];
    
    self.joinNameField.text = [LPSystemSetting sharedSetting].joinerName;
    
    self.historyTable.tableFooterView = [[UIView alloc] init];
    self.historyTable.tableHeaderView = [[UIView alloc] init];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    NSLocale *locale = [NSLocale currentLocale];
    [self.dateFormatter setLocale:locale];
    
    self.tableTipLabel.text = @"暂时还没有历史会议";
    self.tableTipLabel.backgroundColor = [UIColor whiteColor];
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
    
    // 刷新控件的显示
    [self updateControls];
    
    // 判断当前有没有历史数据
    NSInteger number = 0;
    const MSList * logs = linphone_core_get_call_logs([LinphoneManager getLc]);
    while(logs != NULL) {
        logs = ms_list_next(logs);
        number++;
    }
    if (number == 0) {
        // 说明当前没有历史会议, 添加一个遮盖层
        self.tableTipLabel.hidden = NO;
    }else {
        // 每次回到这个界面进行刷新， 因为历史会议数据可能已经更新
        self.tableTipLabel.hidden = YES;
        [self.historyTable reloadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
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

- (void)updateControls {
    LinphoneCore* lc = [LinphoneManager getLc];
    if ( linphone_core_get_default_proxy_config(lc) == NULL ) {
        // 当前处于登出状态
        self.joinNameField.text = @"noName";
        self.joinMeetingNumberField.text = @"";
        
        self.loginTipLabel.text = @"未登录";
        
        self.loginBtn.enabled = YES;
    }else {
        // 当前已处于登录状态
        [[LPSystemUser sharedUser].settingsStore transformLinphoneCoreToKeys];
        
        self.loginTipLabel.text = @"已登录";

        self.joinNameField.text = [[LPSystemUser sharedUser].settingsStore stringForKey:@"username_preference"];
        self.loginBtn.enabled = NO;
    }
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
                self.loginBtn.enabled = NO;
                
                self.joinBtn.enabled = YES;
                
                // 把值同步进去
                [[LPSystemUser sharedUser].settingsStore transformLinphoneCoreToKeys];
                
                [LPSystemUser sharedUser].hasLogin = YES;                
                
                // 取出存储在settingsStore中的用户名和用户id信息
                NSString *nameStr = [[LPSystemUser sharedUser].settingsStore stringForKey:@"username_preference"];
                NSString *idStr = [[LPSystemUser sharedUser].settingsStore stringForKey:@"userid_preference"];
                
                [LPSystemUser sharedUser].loginUserId = idStr;
                [LPSystemUser sharedUser].loginUserName = nameStr;
                [LPSystemUser sharedUser].loginUserPassword = [[LPSystemUser sharedUser].settingsStore stringForKey:@"password_preference"];
                
                break;
            }
            case LinphoneRegistrationNone:
            case LinphoneRegistrationCleared:
                self.loginBtn.enabled = YES;
                message = @"未注册";
                
                [LPSystemUser sharedUser].hasLogin = NO;
                
                self.joinBtn.enabled = NO;

                NSLog(@"登出成功");
                
                break;
            case LinphoneRegistrationFailed:
                self.loginBtn.enabled = YES;
                message = @"注册失败";
                
                self.joinBtn.enabled = NO;
                
                [LPSystemUser sharedUser].hasLogin = NO;
                break;
            case LinphoneRegistrationProgress:
                self.loginBtn.enabled = NO;
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
    
    linphone_address_set_display_name(parsed, [self.joinNameField.text cStringUsingEncoding:[NSString defaultCStringEncoding]]);
    linphone_address_set_username(parsed, [self.joinNameField.text cStringUsingEncoding:[NSString defaultCStringEncoding]]);
    
    char *contact = linphone_address_as_string(parsed);
    linphone_core_set_primary_contact(lc, contact);
    ms_free(contact);
    
    const char *aftershowName = linphone_address_get_display_name(parsed);
    NSString *afterNameStr = [NSString stringWithUTF8String:aftershowName];
    
    const char *afterShowUser = linphone_address_get_username(parsed);
    NSString *afterUserStr = [NSString stringWithUTF8String:afterShowUser];

    NSLog(@"after cur afterNameStr=%@, afterUserStr=%@", afterNameStr, afterUserStr);
    
    linphone_address_destroy(parsed);
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
    
    NSString *callStr = address;
    NSString *domainStr = [LPSystemSetting sharedSetting].sipDomainStr;
    if (![address hasSuffix:domainStr]) {
        callStr = [NSString stringWithFormat:@"%@@%@", callStr, domainStr];
    }
    
    // 进入到会议中
    DialerViewController *controller = DYNAMIC_CAST([[PhoneMainView instance] changeCurrentView:[DialerViewController compositeViewDescription]], DialerViewController);
    if (controller != nil) {
        NSLog(@"进入会议中, callStr=%@, displayName=%@", callStr, displayName);
        [controller call:callStr displayName:displayName];
    }
}

#pragma mark UITabelView delegate & datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectio {
//    return [LPSystemSetting sharedSetting].historyMeetings.count;
    
    NSInteger number = 0;
    const MSList * logs = linphone_core_get_call_logs([LinphoneManager getLc]);
    while(logs != NULL) {
//        LinphoneCallLog*  log = (LinphoneCallLog *) logs->data;
        logs = ms_list_next(logs);
        number++;
    }

    return number;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *tableCell = [tableView dequeueReusableCellWithIdentifier:@"reusedCell"];
    if (tableCell == nil) {
        tableCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reusedCell"];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 160, 40)];
        [tableCell.contentView addSubview:titleLabel];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.tag = 9000;
        
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 0, 160, 40)];
        [tableCell.contentView addSubview:dateLabel];
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.tag = 9001;
    }
    
    
    LinphoneCallLog *log = [[ [LPSystemUser sharedUser].callLogs objectAtIndex:[indexPath row]] pointerValue];
    
    // Set up the cell...
    LinphoneAddress* addr;
    if (linphone_call_log_get_dir(log) == LinphoneCallIncoming) {
        addr = linphone_call_log_get_from(log);
    } else {
        addr = linphone_call_log_get_to(log);
    }
    
    NSString* address = nil;
    if(addr != NULL) {
        BOOL useLinphoneAddress = true;
        // contact name
        char* lAddress = linphone_address_as_string_uri_only(addr);
        if(lAddress) {
            NSString *normalizedSipAddress = [FastAddressBook normalizeSipURI:[NSString stringWithUTF8String:lAddress]];
            ABRecordRef contact = [[[LinphoneManager instance] fastAddressBook] getContact:normalizedSipAddress];
            if(contact) {
                address = [FastAddressBook getContactDisplayName:contact];
                useLinphoneAddress = false;
            }
            ms_free(lAddress);
        }
        if(useLinphoneAddress) {
            const char* lDisplayName = linphone_address_get_display_name(addr);
            const char* lUserName = linphone_address_get_username(addr);
            if (lDisplayName)
                address = [NSString stringWithUTF8String:lDisplayName];
            else if(lUserName)
                address = [NSString stringWithUTF8String:lUserName];
        }
    }
    if(address == nil) {
        address = NSLocalizedString(@"Unknown", nil);
    }
    
    UILabel *mainLabel = [tableCell.contentView viewWithTag:9000];
    UILabel *dateLabel = [tableCell.contentView viewWithTag:9001];
    mainLabel.text = address;
    
    NSDate *startData = [NSDate dateWithTimeIntervalSince1970:linphone_call_log_get_start_date(log)];
    dateLabel.text = [self.dateFormatter stringFromDate:startData];
    
    return tableCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"历史会议";
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
