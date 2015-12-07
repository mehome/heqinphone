//
//  LPMyMeetingManageViewController.m
//  linphone
//
//  Created by baidu on 15/11/16.
//
//

#import "LPMyMeetingManageViewController.h"
#import "LPCellJoinManageTableViewCell.h"
#import "PhoneMainView.h"
#import "LPMyManageSingleViewController.h"
#import "UIViewController+RDRTipAndAlert.h"
#import "LPSystemUser.h"

@interface LPMyMeetingManageViewController () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *searchBtn;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UITableView *searchTable;

@end

@implementation LPMyMeetingManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
}

- (void)searchMyMeetingInfo {
    
    [self showLoadingView];
    
    __weak LPMyMeetingManageViewController *weakSelf = self;
    [LPSystemUser requesteFav:^(BOOL success, NSArray *sheduleMeetings, NSArray *rooms, NSArray *favMeetings, NSString *tipStr) {
        [weakSelf hideHudAndIndicatorView];
        
        if (success == YES) {
            // 取数据成功
            [weakSelf.searchTable reloadData];
        }else {
            // 显示错误提示信息
            [weakSelf showToastWithMessage:tipStr];
        }
    }];
}


#pragma mark - UICompositeViewDelegate Functions

static UICompositeViewDescription *compositeDescription = nil;

+ (UICompositeViewDescription *)compositeViewDescription {
    if(compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:@"ManageMeeting"
                                                                content:@"LPMyMeetingManageViewController"
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

#pragma mark UITableView delegate & datasource

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(7_0) {
    return 130;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 130.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"我的会议室";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [LPSystemUser sharedUser].myMeetingsRooms.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    LPCellJoinManageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"joinmeetingcell"];
    if (cell == nil) {
        NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"LPCellJoinManageTableViewCell" owner:self options:nil];
        cell = [arr  objectAtIndex:0];
    }
    
    RDRJoinMeetingModel *curMeetingModel = [[LPSystemUser sharedUser].myMeetingsRooms objectAtIndex:indexPath.row];
    [cell updateWithObject:curMeetingModel];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    RDRJoinMeetingModel *curMeetingModel = [[LPSystemUser sharedUser].myMeetingsRooms objectAtIndex:indexPath.row];
    NSLog(@"管理会议室进入current select model=%@", curMeetingModel);
    
    LPMyManageSingleViewController *curController = DYNAMIC_CAST([[PhoneMainView instance] changeCurrentView:[LPMyManageSingleViewController compositeViewDescription] push:YES], LPMyManageSingleViewController);
    if (curController != nil) {
        curController.model = curMeetingModel;
    }
}

@end
