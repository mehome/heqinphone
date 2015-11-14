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

@interface LPJoinManageMeetingViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *meetingTable;

@end

@implementation LPJoinManageMeetingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self searchMyMeetingInfo];
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
    NSString *userId = [LPSystemUser sharedUser].loginUserId;
    userId = @"qin.he@zijingcloud.com";
    
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
                       
                   }else {
                       NSLog(@"请求sipDoamin 服务器请求出错, model=%@", model);
                   }
               } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                   [weakSelf hideHudAndIndicatorView];

                   //请求出错
                   NSLog(@"请求sipDoamin出错, %s, error=%@", __FUNCTION__, error);
               }];
}

@end
