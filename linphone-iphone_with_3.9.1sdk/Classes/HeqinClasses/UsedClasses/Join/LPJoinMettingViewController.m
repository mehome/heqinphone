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
//#import "DialerViewController.h"
#import "NSObject+RDRCommon.h"
#import "LPJoinManageMeetingViewController.h"
#import "LPPhoneListView.h"
#import "RDRPhoneModel.h"
#import "LPJoinMeetingCell.h"
#import "RDRAddFavRequestModel.h"
#import "RDRRequest.h"
#import "RDRNetHelper.h"
#import "RDRAddFavResponseModel.h"

@interface LPJoinMettingViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
}

@property (nonatomic, weak) IBOutlet UITableView *historyTable;
@property (weak, nonatomic) IBOutlet UILabel *tableTipLabel;

@property (weak, nonatomic) IBOutlet UITextField *joinNameField;
@property (weak, nonatomic) IBOutlet UITextField *joinMeetingNumberField;

@property (weak, nonatomic) IBOutlet UILabel *loginTipLabel;

@property (weak, nonatomic) IBOutlet UIButton *joinBtn;
@property (weak, nonatomic) IBOutlet UILabel *btnTipLabel;

@property (weak, nonatomic) IBOutlet UIButton *changeNameBtn;

@property (retain, nonatomic) NSDateFormatter *dateFormatter;

@property (retain, nonatomic) NSMutableArray *callLogs;

@end

@implementation LPJoinMettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [LPSystemUser sharedUser];      // 进行初始化，以防后面没有进行初始化
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgTapRecognizered:)]];
    
    self.joinNameField.text = [LPSystemSetting sharedSetting].joinerName;
    
    self.historyTable.tableFooterView = [[UIView alloc] init];
    self.historyTable.tableHeaderView = [[UIView alloc] init];
    
    [self.historyTable registerClass:[LPJoinMeetingCell class] forCellReuseIdentifier:@"reusedCell"];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    self.dateFormatter.dateFormat = @"yyyy年MM月dd日";
    NSLocale *locale = [NSLocale currentLocale];
    [self.dateFormatter setLocale:locale];
    
    self.tableTipLabel.text = @"暂时还没有历史会议";
    self.tableTipLabel.backgroundColor = [UIColor whiteColor];
    
    self.callLogs = [[NSMutableArray alloc] init];
    
    self.changeNameBtn.backgroundColor = yellowSubjectColor;
    self.changeNameBtn.layer.cornerRadius = 5.0;
    self.changeNameBtn.clipsToBounds = YES;
    
    self.joinBtn.backgroundColor = yellowSubjectColor;
    self.joinBtn.layer.cornerRadius = 5.0;
    self.joinBtn.clipsToBounds = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getphoneNotification:) name:kSearchNumbersDatasForJoineMeeting object:nil];
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
    
    [self.callLogs removeAllObjects];
    
    const MSList * logs = linphone_core_get_call_logs([LinphoneManager getLc]);
    while(logs != NULL) {
        LinphoneCallLog*  log = (LinphoneCallLog *) logs->data;
        [self.callLogs addObject:[NSValue valueWithPointer: log]];
        
        logs = ms_list_next(logs);
    }
    
    // 判断当前有没有历史数据
    if (self.callLogs.count == 0) {
        // 说明当前没有历史会议, 添加一个遮盖层
        self.tableTipLabel.hidden = NO;
    }else {
        // 每次回到这个界面进行刷新， 因为历史会议数据可能已经更新
        self.tableTipLabel.hidden = YES;
        [self.historyTable reloadData];
    }
    
    if ( kNotLoginCheck ) {
        // 未登录
        self.btnTipLabel.text = @"未登录";
    }else {
        // 已登录
        self.btnTipLabel.text = @"已登录";
    }
}

- (void)getphoneNotification:(NSNotification *)notification {
    NSLog(@"notification=%@", notification);
    RDRPhoneModel *model = notification.object;
    if (model == nil) {
        [self showToastWithMessage:@"获取的信息为空"];
    }else {
        self.joinMeetingNumberField.text = model.uid;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter]	removeObserver:self
                                                    name:kLinphoneRegistrationUpdate
                                                  object:nil];
}

- (void)registrationUpdate: (NSNotification*) notif {
    LinphoneProxyConfig* config = NULL;
    config = linphone_core_get_default_proxy_config([LinphoneManager getLc]);
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
                
                [LPSystemUser sharedUser].hasLoginSuccess = YES;

                // 把值同步进去
                [[LPSystemUser sharedUser].settingsStore transformLinphoneCoreToKeys];
                
                self.joinNameField.text = [[LPSystemUser sharedUser].settingsStore stringForKey:@"account_userid_preference"];
                self.btnTipLabel.text = @"已登录";
                break;
            }
            case LinphoneRegistrationNone:
            case LinphoneRegistrationCleared:
                message = @"未注册";
                self.btnTipLabel.text = @"未登录";
                [LPSystemUser sharedUser].hasLoginSuccess = NO;
                NSLog(@"登出成功");
                break;
            case LinphoneRegistrationFailed:
                message = @"注册失败";
                self.btnTipLabel.text = @"未登录";
                [LPSystemUser sharedUser].hasLoginSuccess = NO;

                break;
            case LinphoneRegistrationProgress:
                message = @"注册中";

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

- (UICompositeViewDescription *)compositeViewDescription {
    return self.class.compositeViewDescription;
}

+ (UICompositeViewDescription *)compositeViewDescription {
    if(compositeDescription == nil) {
//        compositeDescription = [[UICompositeViewDescription alloc] init:@"Join"
//                                                                content:@"LPJoinMettingViewController"
//                                                               stateBar:nil
//                                                        stateBarEnabled:false
//                                                                 tabBar:@"LPJoinBarViewController"
//                                                          tabBarEnabled:true
//                                                             fullscreen:false
//                                                          landscapeMode:[LinphoneManager runningOnIpad]
//                                                           portraitMode:true];
        compositeDescription = [[UICompositeViewDescription alloc] init:self.class
                                                              statusBar:nil
                                                                 tabBar:LPJoinBarViewController.class
                                                               sideMenu:nil
                                                             fullscreen:false
                                                         isLeftFragment:false
                                                           fragmentWith:nil
                                                   supportLandscapeMode:false];

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
}

- (IBAction)loginBtnClicked:(id)sender {
    [self resignKeyboard];
    
    // 判断当前是否登录过
    if ( kNotLoginCheck ) {
        // 未登录
        [[PhoneMainView instance] changeCurrentView:[LPLoginViewController compositeViewDescription]];
    }else {
        // 已登录
        [[PhoneMainView instance] changeCurrentView:[LPJoinManageMeetingViewController compositeViewDescription]];
    }
}

- (IBAction)changeNameBtnClicked:(id)sender {
    [self resignKeyboard];

    NSString *tempStr = self.joinNameField.text;
    [LPSystemSetting sharedSetting].joinerName = tempStr;
    
    LinphoneCore *lc=[LinphoneManager getLc];
    LinphoneAddress *parsed = linphone_core_get_primary_contact_parsed(lc);
    if(parsed != NULL) {
        linphone_address_set_display_name(parsed,[tempStr UTF8String]);
        linphone_address_set_username(parsed, [tempStr UTF8String]);
        
        const char *aftershowName = linphone_address_get_display_name(parsed);
        NSString *afterNameStr = [NSString stringWithCString:aftershowName encoding:NSUTF8StringEncoding];
        
        const char *afterShowUser = linphone_address_get_username(parsed);
        NSString *afterUserStr = [NSString stringWithCString:afterShowUser encoding:NSUTF8StringEncoding];
        
        NSLog(@"after change displayNameStr=%@, showUserStr=%@", afterNameStr, afterUserStr);
    }
    
    char *contact = linphone_address_as_string(parsed);
    linphone_core_set_primary_contact(lc, contact);
    ms_free(contact);
    
    linphone_address_destroy(parsed);
    
    [self showToastWithMessage:@"更改成功"];
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
//    if (address.length == 0) {
//        [self showToastWithMessage:@"无效的地址，请重新输入"];
//        return;
//    }
//    
//    NSString *callStr = address;
//    
//    NSString *domainStr = [LPSystemSetting sharedSetting].sipTmpProxy;
//    if (![address hasSuffix:domainStr] && domainStr.length>0) {
//        callStr = [NSString stringWithFormat:@"%@@%@", callStr, domainStr];
//    }
//    
//    [LPSystemUser sharedUser].curMeetingAddr = callStr;
//    if (callStr.length > 0) {
//        LinphoneAddress *addr = [LinphoneUtils normalizeSipOrPhoneAddress:callStr];
//        [LinphoneManager.instance call:addr];
//        if (addr)
//            linphone_address_destroy(addr);
//    }
    
    if (address.length == 0) {
        [self showToastWithMessage:@"无效的地址，请重新输入"];
        return;
    }
    NSString *callStr = address;
    
    NSString *domainStr = [LPSystemSetting sharedSetting].sipDomainStr;
    if (![address hasSuffix:domainStr] && domainStr.length>0) {
        callStr = [NSString stringWithFormat:@"%@@%@", callStr, domainStr];
    }
    // 拼成1066@sip.myvmr.cn后
    
    [LPSystemUser sharedUser].curMeetingAddr = callStr;
    if (callStr.length > 0) {
        LinphoneAddress *addr = [LinphoneUtils normalizeSipOrPhoneAddress:callStr];
        [LinphoneManager.instance call:addr];
    }
}

#pragma mark UITabelView delegate & datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectio {
//    return [LPSystemSetting sharedSetting].historyMeetings.count;
    
//    NSInteger number = 0;
//    const MSList * logs = linphone_core_get_call_logs([LinphoneManager getLc]);
//    while(logs != NULL) {
////        LinphoneCallLog*  log = (LinphoneCallLog *) logs->data;
//        logs = ms_list_next(logs);
//        number++;
//    }
//
//    return number;
    
    return self.callLogs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LPJoinMeetingCell *tableCell = (LPJoinMeetingCell *)[tableView dequeueReusableCellWithIdentifier:@"reusedCell" forIndexPath:indexPath];
    
    UILabel *mainLabel = tableCell.leftLabel;
    UILabel *dateLabel = tableCell.rightLabel;
    UIButton *callBtn = tableCell.topBtn;
    UIButton *addFavBtn = tableCell.favBtn;
    [addFavBtn addTarget:self action:@selector(addFavMeeting:) forControlEvents:UIControlEventTouchUpInside];
    
    [callBtn addTarget:self action:@selector(cellBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    callBtn.rd_userInfo = @{@"indexPath":indexPath};
    
    LinphoneCallLog *log = [[self.callLogs objectAtIndex:[indexPath row]] pointerValue];
    
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
            NSString *normalizedSipAddress = [FastAddressBook displayNameForAddress:addr];
//            ABRecordRef contact = [[[LinphoneManager instance] fastAddressBook] getContact:normalizedSipAddress];
//            if(contact) {
//                address = [FastAddressBook getContactDisplayName:contact];
//                useLinphoneAddress = false;
//            }
            
            if (normalizedSipAddress.length > 0) {
                address = normalizedSipAddress;
                useLinphoneAddress = false;
            }
            
            ms_free(lAddress);
        }
        if(useLinphoneAddress) {
            const char* lDisplayName = linphone_address_get_display_name(addr);
            const char* lUserName = linphone_address_get_username(addr);
            if(lUserName)
                address = [NSString stringWithUTF8String:lUserName];
            else if (lDisplayName)
                address = [NSString stringWithUTF8String:lDisplayName];
        }
    }
    if(address == nil) {
        address = NSLocalizedString(@"Unknown", nil);
    }
    
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectRowAtIndexPath=%@", indexPath);
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)goIndexPath:(NSIndexPath *)indexPath {
    LinphoneCallLog *callLog = [[self.callLogs objectAtIndex:[indexPath row]] pointerValue];
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
            NSString *normalizedSipAddress = [FastAddressBook displayNameForAddress:addr];
            if(normalizedSipAddress.length > 0) {
                displayName = normalizedSipAddress;
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

- (void)cellBtnClicked:(id)sender {
    UIButton *callBtn = sender;
    
    NSIndexPath *btnIndexPath = (NSIndexPath *)[callBtn.rd_userInfo objectForKey:@"indexPath"];
    [self goIndexPath:btnIndexPath];
}

- (void)addFavMeeting:(id)sender {
    UIButton *favBtn = sender;
    
    if ( kNotLoginCheck ) {
        // 未登录
        [self showToastWithMessage:@"未登录，请先登录"];
    }else {
        // 已登录        
        __weak LPJoinMettingViewController *weakSelf = self;
        [weakSelf showToastWithMessage:@"收藏会议室中..."];
        
        RDRAddFavRequestModel *reqModel = [RDRAddFavRequestModel requestModel];
        reqModel.uid = [[LPSystemUser sharedUser].settingsStore stringForKey:@"account_userid_preference"];;
        
        NSIndexPath *btnIndexPath = (NSIndexPath *)[favBtn.rd_userInfo objectForKey:@"indexPath"];
        LinphoneCallLog *callLog = [[self.callLogs objectAtIndex:[btnIndexPath row]] pointerValue];
        LinphoneAddress* addr;
        if (linphone_call_log_get_dir(callLog) == LinphoneCallIncoming) {
            addr = linphone_call_log_get_from(callLog);
        } else {
            addr = linphone_call_log_get_to(callLog);
        }
        NSString* address = nil;
        if(addr != NULL) {
            BOOL useLinphoneAddress = true;
            // contact name
            char* lAddress = linphone_address_as_string_uri_only(addr);
            if(lAddress) {
                NSString *normalizedSipAddress = [FastAddressBook displayNameForAddress:addr];
                if(normalizedSipAddress.length > 0) {
                    address = normalizedSipAddress;
                    useLinphoneAddress = false;
                }
                ms_free(lAddress);
            }
            if(useLinphoneAddress) {
                const char* lDisplayName = linphone_address_get_display_name(addr);
                const char* lUserName = linphone_address_get_username(addr);
                if(lUserName)
                    address = [NSString stringWithUTF8String:lUserName];
                else if (lDisplayName)
                    address = [NSString stringWithUTF8String:lDisplayName];
            }
        }
        if(address == nil) {
            address = NSLocalizedString(@"Unknown", nil);
        }
        
        reqModel.addr = address;
        
//        RDRRequest *req = [RDRRequest requestWithURLPath:nil model:reqModel];
//        [RDRNetHelper GET:req responseModelClass:[RDRAddFavResponseModel class]
//                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                      RDRAddFavResponseModel *model = responseObject;
//                      if ([model codeCheckSuccess] == YES) {
//                          NSLog(@"收藏会议室成功, model=%@", model);
//                          [weakSelf showToastWithMessage:@"收藏会议室成功"];
//                      }else {
//                          NSString *tipStr = [NSString stringWithFormat:@"收藏会议室失败，%@(%ld)", model.msg, (long)model.code];
//                          NSLog(@"%@", tipStr);
//
//                          [weakSelf showToastWithMessage:tipStr];
//                      }
//                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                      [weakSelf hideHudAndIndicatorView];
//                      
//                      //请求出错
//                      NSLog(@"收藏会议室失败, %s, error=%@", __FUNCTION__, error);
//                      NSString *tipStr = [NSString stringWithFormat:@"收藏会议室失败，服务器错误"];
//                      [weakSelf showToastWithMessage:tipStr];
//                  }];
    }
}

@end
