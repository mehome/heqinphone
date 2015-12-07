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

@interface LPJoinManageMeetingViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *topBgView;
@property (nonatomic, weak) IBOutlet UITableView *meetingTable;

@end

@implementation LPJoinManageMeetingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    if ([LPSystemUser sharedUser].hasGetMeetingData == NO) {
        [self searchMyMeetingInfo];
    }else {
        [self.meetingTable reloadData];
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
            [weakSelf.meetingTable reloadData];
        }else {
            // 显示错误提示信息
            [weakSelf showToastWithMessage:tipStr];
        }
    }];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(7_0) {
    return 130;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 130.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"会议安排";
    }else if (section == 1) {
        return @"我的会议室";
    }else if (section == 2) {
        return @"我的收藏";
    }else if (section == 3) {
        return @"历史会议";
    }
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return [LPSystemUser sharedUser].myScheduleMeetings.count;
    }else if (section == 1) {
        return [LPSystemUser sharedUser].myMeetingsRooms.count;
    }else if (section == 2) {
        return [LPSystemUser sharedUser].myFavMeetings.count;
    }else if (section == 3) {
        return [LPSystemUser sharedUser].callLogs.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    // 历史拨打纪录
    if (indexPath.section == 3) {
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
    
    LPCellJoinManageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"joinmeetingcell"];
    if (cell == nil) {
        NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"LPCellJoinManageTableViewCell" owner:self options:nil];
        cell = [arr  objectAtIndex:0];
    }

    RDRJoinMeetingModel *curMeetingModel = nil;
    
    switch (indexPath.section) {
        case 0:
            curMeetingModel = [[LPSystemUser sharedUser].myScheduleMeetings objectAtIndex:indexPath.row];
            break;
        case 1:
            curMeetingModel = [[LPSystemUser sharedUser].myMeetingsRooms objectAtIndex:indexPath.row];
            break;
        case 2:
            curMeetingModel = [[LPSystemUser sharedUser].myFavMeetings objectAtIndex:indexPath.row];
            break;
        case 3:
            NSLog(@"program can't come here");
            curMeetingModel = nil;
            break;
            
        default:
            curMeetingModel = nil;
            break;
    }
    
    [cell updateWithObject:curMeetingModel];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RDRJoinMeetingModel *curMeetingModel = nil;
    
    switch (indexPath.section) {
        case 0:
            curMeetingModel = [[LPSystemUser sharedUser].myScheduleMeetings objectAtIndex:indexPath.row];
            break;
        case 1:
            curMeetingModel = [[LPSystemUser sharedUser].myMeetingsRooms objectAtIndex:indexPath.row];
            break;
        case 2:
            curMeetingModel = [[LPSystemUser sharedUser].myFavMeetings objectAtIndex:indexPath.row];
            break;
        case 3: {
            LinphoneCallLog *callLog = [[[LPSystemUser sharedUser].callLogs objectAtIndex:[indexPath row]] pointerValue];
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
    
    // 进入到会议中
    DialerViewController *controller = DYNAMIC_CAST([[PhoneMainView instance] changeCurrentView:[DialerViewController compositeViewDescription]], DialerViewController);
    if (controller != nil) {
        NSLog(@"进入会议中, addres=%@, displayName=%@", address, displayName);
        [controller call:address displayName:displayName];
    }
}

@end
