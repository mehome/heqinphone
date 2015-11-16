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

@interface LPJoinManageMeetingViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *topBgView;
@property (nonatomic, weak) IBOutlet UITableView *meetingTable;

@property (nonatomic, strong) NSArray *arrangeMeetings;
@property (nonatomic, strong) NSArray *myMeetings;
@property (nonatomic, strong) NSArray *myCollectionMeetings;
@property (nonatomic, strong) NSArray *historyMeetings;

@end

@implementation LPJoinManageMeetingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self searchMyMeetingInfo];
    
//    [self.meetingTable registerClass:[LPJoinManageCell class] forCellReuseIdentifier:@"joinmeetingcell"];
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
    // TODO 这里应该直接去取存储的UserId信息
    NSString *userId = [LPSystemUser sharedUser].loginUserId;
    userId = @"feng.wang@zijingcloud.com";
    
    [self showLoadingView];

    __weak LPJoinManageMeetingViewController *weakSelf = self;
    RDRMyMeetingRequestModel *reqModel = [RDRMyMeetingRequestModel requestModel];
    reqModel.uid = userId;
    
    RDRRequest *req = [RDRRequest requestWithURLPath:nil model:reqModel];
    
    [RDRNetHelper GET:req responseModelClass:[RDRMyMeetingResponseModel class]
               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                   [weakSelf hideHudAndIndicatorView];
                   
                   RDRMyMeetingResponseModel *model = responseObject;
                   
                   if ([model codeCheckSuccess] == YES) {
                       NSLog(@"请求Meeting Info, success, model=%@", model);
                       
                       // 解析model数据
                       self.myMeetings = [model.rooms mutableCopy];
                       
                       [self.meetingTable reloadData];
                   }else {
                       NSLog(@"请求Meeting Info 服务器请求出错, model=%@, msg=%@", model, model.msg);
                   }
               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                   [weakSelf hideHudAndIndicatorView];

                   //请求出错
                   NSLog(@"请求Meeting Info出错, %s, error=%@", __FUNCTION__, error);
               }];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(7_0) {
//    if (IS_IOS8_OR_ABOVE) {
//        return UITableViewAutomaticDimension;
//    }
    
    return 130;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (IS_IOS8_OR_ABOVE) {
//        return UITableViewAutomaticDimension;
//    }

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
        return self.arrangeMeetings.count;
    }else if (section == 1) {
        return self.myMeetings.count;
    }else if (section == 2) {
        return self.myCollectionMeetings.count;
    }else if (section == 3) {
        return self.historyMeetings.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    LPCellJoinManageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"joinmeetingcell"];
    if (cell == nil) {
        NSArray *arr = [[NSBundle mainBundle] loadNibNamed:@"LPCellJoinManageTableViewCell" owner:self options:nil];
        cell = [arr  objectAtIndex:0];
    }

    RDRJoinMeetingModel *curMeetingModel = nil;
    
    switch (indexPath.section) {
        case 0:
            curMeetingModel = [self.arrangeMeetings objectAtIndex:indexPath.row];
            break;
        case 1:
            curMeetingModel = [self.myMeetings objectAtIndex:indexPath.row];
            break;
        case 2:
            curMeetingModel = [self.myCollectionMeetings objectAtIndex:indexPath.row];
            break;
        case 3:
            curMeetingModel = [self.historyMeetings objectAtIndex:indexPath.row];
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
            curMeetingModel = [self.arrangeMeetings objectAtIndex:indexPath.row];
            break;
        case 1:
            curMeetingModel = [self.myMeetings objectAtIndex:indexPath.row];
            break;
        case 2:
            curMeetingModel = [self.myCollectionMeetings objectAtIndex:indexPath.row];
            break;
        case 3:
            curMeetingModel = [self.historyMeetings objectAtIndex:indexPath.row];
            break;
            
        default:
            curMeetingModel = nil;
            break;
    }

    NSLog(@"进入会议室，current select model=%@", curMeetingModel);
    // 进入会议室
    
    return;
}


@end
