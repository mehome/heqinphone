//
//  LPJoinManageMeetingViewController.m
//  linphone
//
//  Created by heqin on 15/11/7.
//
//

#import "LPJoinManageMeetingViewController.h"
#import "LPSystemUser.h"
#import "UIViewController+RDRTipAndAlert.h"
#import "RDRMyMeetingRequestModel.h"
#import "RDRMyMeetingResponseModel.h"
#import "RDRRequest.h"
#import "RDRNetHelper.h"
#import "RDRJoinMeetingModel.h"
#import "LPCellJoinManageTableViewCell.h"
#import "LPSystemUser.h"
#import "UIHistoryCell.h"
#import "UACellBackgroundView.h"
#import "UILinphone.h"
#import "DialerViewController.h"
#import "PhoneMainView.h"
#import "LPSystemSetting.h"

@interface LPJoinManageMeetingViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *meetingField;

@property (weak, nonatomic) IBOutlet UIView *topBgView;
@property (nonatomic, weak) IBOutlet UITableView *meetingTable;

@property (nonatomic, assign) BOOL showAllMeetingArange;        // 显示会议安排
@property (nonatomic, assign) BOOL showMyMeeting;               // 显示我的会议室
@property (nonatomic, assign) BOOL showMyCollection;            // 显示我的收藏会议室
@property (nonatomic, assign) BOOL showHistoryMeeing;           // 显示历史会议

@property (nonatomic, retain) UIView *floatView;                // 遮照层

@property (nonatomic, retain) NSMutableArray *filterAllMeetings;            // 会议安排
@property (nonatomic, retain) NSMutableArray *filterMyMeetings;             // 我的会议室
@property (nonatomic, retain) NSMutableArray *filterMyCollections;          // 我的收藏会议室
@property (nonatomic, retain) NSMutableArray *filterHistoryMeetings;        // 历史会议

@property (retain, nonatomic) NSDateFormatter *dateFormatter;

@end


@implementation LPJoinManageMeetingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.showAllMeetingArange = YES;
    self.showMyMeeting = YES;
    self.showMyCollection = YES;
    self.showHistoryMeeing = YES;
    
    self.floatView = [[UIView alloc] initWithFrame:self.meetingTable.bounds];
    self.floatView.backgroundColor = [UIColor grayColor];
    self.floatView.alpha = 0.3;
    self.floatView.hidden = YES;
    [self.meetingTable addSubview:self.floatView];
    self.floatView.userInteractionEnabled = NO;
    
    [self.floatView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgTap:)]];
    [self.meetingTable addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableTap:)]];
    
    self.meetingTable.tableFooterView = [[UIView alloc] init];
    self.meetingTable.tableHeaderView = [[UIView alloc] init];
    
    self.filterAllMeetings = [NSMutableArray array];
    self.filterMyMeetings = [NSMutableArray array];
    self.filterMyCollections = [NSMutableArray array];
    self.filterHistoryMeetings = [NSMutableArray array];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    self.dateFormatter.dateFormat = @"yyyy年MM月dd日";
    NSLocale *locale = [NSLocale currentLocale];
    [self.dateFormatter setLocale:locale];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([LPSystemUser sharedUser].hasGetMeetingData == NO) {
        [self searchMyMeetingInfo];
    }else {
        [self resetAllData];
        [self.meetingTable reloadData];
    }
}

- (IBAction)searchBtnClicked:(id)sender {
    self.floatView.hidden = YES;
    [self.meetingField resignFirstResponder];
    
    NSString *searchStr = [self.meetingField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [self filterWithStr:searchStr];
}

- (void)bgTap:(UITapGestureRecognizer *)tapGesture {
    self.floatView.hidden = YES;
    [self.meetingField resignFirstResponder];
}

- (void)tableTap:(UITapGestureRecognizer *)tapGesture {
    self.floatView.hidden = YES;
    [self.meetingField resignFirstResponder];
}

- (void)resetAllData {
    self.filterAllMeetings = [NSMutableArray arrayWithArray:[LPSystemUser sharedUser].myScheduleMeetings];
    self.filterMyMeetings = [NSMutableArray arrayWithArray:[LPSystemUser sharedUser].myMeetingsRooms];
    self.filterMyCollections = [NSMutableArray arrayWithArray:[LPSystemUser sharedUser].myFavMeetings];
    
    [self.filterHistoryMeetings removeAllObjects];
    
    const MSList * logs = linphone_core_get_call_logs([LinphoneManager getLc]);
    while(logs != NULL) {
        LinphoneCallLog*  log = (LinphoneCallLog *) logs->data;
        [self.filterHistoryMeetings addObject:[NSValue valueWithPointer: log]];
        logs = ms_list_next(logs);
    }
}

#pragma mark - UICompositeViewDelegate Functions

static UICompositeViewDescription *compositeDescription = nil;

+ (UICompositeViewDescription *)compositeViewDescription {
    if(compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:@"JoinManage"
                                                                content:@"LPJoinManageMeetingViewController"
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

- (void)searchMyMeetingInfo {
    
    [self showLoadingView];
    
    __weak LPJoinManageMeetingViewController *weakSelf = self;
    [LPSystemUser requesteFav:^(BOOL success, NSArray *sheduleMeetings, NSArray *rooms, NSArray *favMeetings, NSString *tipStr) {
        [weakSelf hideHudAndIndicatorView];
        if (success == YES) {
            // 取数据成功
            [self resetAllData];
            [weakSelf.meetingTable reloadData];
        }else {
            // 显示错误提示信息
            [weakSelf showToastWithMessage:tipStr];
        }
    }];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(7_0) {
    return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *pareView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    pareView.backgroundColor = [UIColor grayColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.frame = CGRectMake(20, 0, pareView.ott_width-20, 44);
    btn.backgroundColor = [UIColor clearColor];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    [btn addTarget:self action:@selector(sectionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = 1000 + section;
    
    switch (section) {
        case 0:
            // 会议安排
            if (self.showAllMeetingArange == YES) {
                [btn setTitle:@"会议安排 收起" forState:UIControlStateNormal];
            }else {
                [btn setTitle:@"会议安排 展开" forState:UIControlStateNormal];
            }
            break;
        case 1:
            // 我的会议室
            if (self.showMyMeeting == YES) {
                [btn setTitle:@"我的会议室 收起" forState:UIControlStateNormal];
            }else {
                [btn setTitle:@"我的会议室 展开" forState:UIControlStateNormal];
            }
            break;
        case 2:
            // 我的收藏
            if (self.showMyCollection == YES) {
                [btn setTitle:@"我的收藏 收起" forState:UIControlStateNormal];
            }else {
                [btn setTitle:@"我的收藏 展开" forState:UIControlStateNormal];
            }
            break;
        case 3:
            // 历史会议
            if (self.showHistoryMeeing == YES) {
                [btn setTitle:@"历史会议 收起" forState:UIControlStateNormal];
            }else {
                [btn setTitle:@"历史会议 展开" forState:UIControlStateNormal];
            }
            break;
            
        default:
            break;
    }
    
    [pareView addSubview:btn];
    btn.ott_centerY = pareView.ott_centerY;
    
    return pareView;
}

- (void)sectionBtnClicked:(UIButton *)btn {
    switch (btn.tag - 1000) {
        case 0:
            // 会议安排
            self.showAllMeetingArange = !self.showAllMeetingArange;
            if (self.showAllMeetingArange == YES) {
                [btn setTitle:@"会议安排 收起" forState:UIControlStateNormal];
            }else {
                [btn setTitle:@"会议安排 展开" forState:UIControlStateNormal];
            }
            break;
        case 1:
            // 我的会议室
            self.showMyMeeting = !self.showMyMeeting;
            if (self.showMyMeeting == YES) {
                [btn setTitle:@"我的会议室 收起" forState:UIControlStateNormal];
            }else {
                [btn setTitle:@"我的会议室 展开" forState:UIControlStateNormal];
            }
            break;
        case 2:
            // 我的收藏
            self.showMyCollection = !self.showMyCollection;
            if (self.showMyCollection == YES) {
                [btn setTitle:@"我的收藏 收起" forState:UIControlStateNormal];
            }else {
                [btn setTitle:@"我的收藏 展开" forState:UIControlStateNormal];
            }
            break;
        case 3:
            // 历史会议
            self.showHistoryMeeing = !self.showHistoryMeeing;
            if (self.showHistoryMeeing == YES) {
                [btn setTitle:@"历史会议 收起" forState:UIControlStateNormal];
            }else {
                [btn setTitle:@"历史会议 展开" forState:UIControlStateNormal];
            }
            break;
            
        default:
            break;
    }
    
    [self.meetingTable reloadSections:[NSIndexSet indexSetWithIndex:(btn.tag - 1000)] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            if (self.showAllMeetingArange == YES) {
                return self.filterAllMeetings.count;
            }else {
                return 0;
            }
            break;
        case 1:
            if (self.showMyMeeting == YES) {
                return self.filterMyMeetings.count;
            }else {
                return 0;
            }
            break;
        case 2:
            if (self.showMyCollection == YES) {
                return self.filterMyCollections.count;
            }else {
                return 0;
            }
            break;
        case 3:
            if (self.showHistoryMeeing == YES) {
                return self.filterHistoryMeetings.count;
            }else {
                return 0;
            }
            break;
            
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *tableCell = [tableView dequeueReusableCellWithIdentifier:@"reusedCell"];
    
    if (tableCell == nil) {
        tableCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reusedCell"];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 160, 40)];
        [tableCell.contentView addSubview:titleLabel];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.tag = 9000;
        
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 0, 160, 40)];
        [tableCell.contentView addSubview:dateLabel];
        dateLabel.font = [UIFont systemFontOfSize:14.0];
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.tag = 9001;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = tableCell.contentView.bounds;
        [tableCell.contentView addSubview:btn];
        [btn addTarget:self action:@selector(cellBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        btn.backgroundColor = [UIColor clearColor];
        btn.tag = 9002;
    }
    
    UIButton *btn = [tableCell.contentView viewWithTag:9002];
    btn.frame = tableCell.contentView.bounds;
    btn.rd_userInfo = @{@"indexPath":indexPath};
    
    NSString *firstStr = nil;
    NSString *secondStr = nil;
    RDRJoinMeetingModel *curMeetingModel = nil;
    switch (indexPath.section) {
        case 0:
            curMeetingModel = [self.filterAllMeetings objectAtIndex:indexPath.row];
            firstStr = curMeetingModel.name.length>0 ? curMeetingModel.name : curMeetingModel.addr;
            secondStr = curMeetingModel.time;
            break;
        case 1:
            curMeetingModel = [self.filterMyMeetings objectAtIndex:indexPath.row];
            firstStr = curMeetingModel.name.length>0 ? curMeetingModel.name : curMeetingModel.addr;
            secondStr = curMeetingModel.time;
            break;
        case 2:
            curMeetingModel = [self.filterMyCollections objectAtIndex:indexPath.row];
            firstStr = curMeetingModel.name.length>0 ? curMeetingModel.name : curMeetingModel.addr;
            secondStr = curMeetingModel.time;
            break;
        case 3: {
            curMeetingModel = nil;
            LinphoneCallLog *callLog = [[self.filterHistoryMeetings objectAtIndex:[indexPath row]] pointerValue];
            
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
                    if(lUserName)
                        address = [NSString stringWithUTF8String:lUserName];
                    else if (lDisplayName)
                        address = [NSString stringWithUTF8String:lDisplayName];                    
                }
            }
            if(address == nil) {
                address = NSLocalizedString(@"Unknown", nil);
            }
            
            firstStr = address;
            NSDate *startData = [NSDate dateWithTimeIntervalSince1970:linphone_call_log_get_start_date(callLog)];
            secondStr = [self.dateFormatter stringFromDate:startData];
        }
            break;
        default:
            curMeetingModel = nil;
            break;
    }

    UILabel *firstLabel = (UILabel *)[tableCell.contentView viewWithTag:9000];
    UILabel *secondLabel = (UILabel *)[tableCell.contentView viewWithTag:9001];
    
    firstLabel.ott_width = tableCell.contentView.ott_width / 2.0;
    firstLabel.ott_centerY = tableCell.contentView.ott_height / 2.0;
    
    secondLabel.ott_width = tableCell.contentView.ott_width / 2.0;
    secondLabel.ott_left = firstLabel.ott_right;
    secondLabel.ott_centerY = tableCell.contentView.ott_height / 2.0;

    firstLabel.text = firstStr;
    secondLabel.text = secondStr;
    
    return tableCell;
}

- (void)cellBtnClicked:(UIButton *)sender {
    NSIndexPath *btnIndexPath = (NSIndexPath *)[sender.rd_userInfo objectForKey:@"indexPath"];
    [self goIndexPath:btnIndexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)goIndexPath:(NSIndexPath *)indexPath {
    RDRJoinMeetingModel *curMeetingModel = nil;
    
    switch (indexPath.section) {
        case 0:
            curMeetingModel = [self.filterAllMeetings objectAtIndex:indexPath.row];
            break;
        case 1:
            curMeetingModel = [self.filterMyMeetings objectAtIndex:indexPath.row];
            break;
        case 2:
            curMeetingModel = [self.filterMyCollections objectAtIndex:indexPath.row];
            break;
        case 3: {
            LinphoneCallLog *callLog = [[self.filterHistoryMeetings objectAtIndex:[indexPath row]] pointerValue];
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
            return;
        }

            break;
            
        default:
            curMeetingModel = nil;
            break;
    }

    NSLog(@"进入会议室，current select model=%@", curMeetingModel);
    // 进入会议室
    [self joinMeeting:curMeetingModel.addr withDisplayName:nil];
    
    return;
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

#pragma mark UITextField delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.floatView.hidden = NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

- (void)filterWithStr:(NSString *)curStr {
    if (curStr.length > 0) {
        self.floatView.hidden = YES;
    }else {
        self.floatView.hidden = NO;
    }
    
    // 先重置好所有的数据
    [self resetAllData];
    if (curStr.length == 0) {
        [self.meetingTable reloadData];
        return;
    }
    
    NSMutableArray *tmpArr = [NSMutableArray array];
    
    // 进行过滤操作0
    for (NSInteger i=0; i<self.filterAllMeetings.count; i++) {
        RDRJoinMeetingModel *curModel = [self.filterAllMeetings objectAtIndex:i];
        if ([curModel.name rangeOfString:curStr].location != NSNotFound ||
            [curModel.addr rangeOfString:curStr].location != NSNotFound||
            [[curModel.idNum stringValue] rangeOfString:curStr].location != NSNotFound) {
            
        }else {
            [tmpArr addObject:curModel];
        }
    }
    if (tmpArr.count > 0) {
        [self.filterAllMeetings removeObjectsInArray:tmpArr];
    }
    [tmpArr removeAllObjects];
    
    // 进行过滤操作1
    for (NSInteger i=0; i<self.filterMyMeetings.count; i++) {
        RDRJoinMeetingModel *curModel = [self.filterMyMeetings objectAtIndex:i];
        if ([curModel.name rangeOfString:curStr].location != NSNotFound ||
            [curModel.addr rangeOfString:curStr].location != NSNotFound||
            [[curModel.idNum stringValue] rangeOfString:curStr].location != NSNotFound) {
            
        }else {
            [tmpArr addObject:curModel];
        }
    }
    if (tmpArr.count > 0) {
        [self.filterMyMeetings removeObjectsInArray:tmpArr];
    }
    [tmpArr removeAllObjects];
    
    // 进行过滤操作2
    for (NSInteger i=0; i<self.filterMyCollections.count; i++) {
        RDRJoinMeetingModel *curModel = [self.filterMyCollections objectAtIndex:i];
        if ([curModel.name rangeOfString:curStr].location != NSNotFound ||
            [curModel.addr rangeOfString:curStr].location != NSNotFound||
            [[curModel.idNum stringValue] rangeOfString:curStr].location != NSNotFound) {
            
        }else {
            [tmpArr addObject:curModel];
        }
    }
    if (tmpArr.count > 0) {
        [self.filterMyCollections removeObjectsInArray:tmpArr];
    }
    [tmpArr removeAllObjects];

    NSMutableIndexSet *set=[NSMutableIndexSet indexSet];
    // 进行过滤操作3
    for (NSInteger i=0; i<self.filterHistoryMeetings.count; i++) {
        LinphoneCallLog *callLog = [[self.filterHistoryMeetings objectAtIndex:i] pointerValue];
        LinphoneAddress* addr;
        if (linphone_call_log_get_dir(callLog) == LinphoneCallIncoming) {
            addr = linphone_call_log_get_from(callLog);
        } else {
            addr = linphone_call_log_get_to(callLog);
        }
        
        NSString* address = @"";
        if(addr != NULL) {
            char* lAddress = linphone_address_as_string_uri_only(addr);
            if(lAddress) {
                address = [NSString stringWithUTF8String:lAddress];
            }
        }
        
        if ([address rangeOfString:curStr].location != NSNotFound) {
            
        }else {
            [set addIndex:i];
        }
    }
    
    [self.filterHistoryMeetings removeObjectsAtIndexes:set];
    
    [self.meetingTable reloadData];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self.meetingField resignFirstResponder];
    self.floatView.hidden = YES;

    [self resetAllData];
    [self.meetingTable reloadData];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [self.meetingField resignFirstResponder];
    self.floatView.hidden = YES;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSString *searchStr = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [self filterWithStr:searchStr];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.meetingField resignFirstResponder];
    self.floatView.hidden = YES;
    return YES;
}

@end
