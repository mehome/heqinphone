//
//  LPMyMeetingArrangeViewController.m
//  linphone
//
//  Created by baidu on 15/11/16.
//
//

#import "LPMyMeetingArrangeViewController.h"
#import "LPSystemUser.h"
#import "RDRMyMeetingArrangeContactsModel.h"
#import "UIViewController+RDRTipAndAlert.h"
#import "RDRRequest.h"
#import "RDRNetHelper.h"
#import "RDRMyMeetingArrangeContactsResponseModel.h"
#import "RDRContactModel.h"
#import "RDRDeviceModel.h"


#import "RDRMyMeetingArrangeRoomsModel.h"
#import "RDRArrangeRoomModel.h"
#import "RDRMyMeetingArrangeRoomResponseModel.h"

#import "RDRMyMeetingArrangeModel.h"
#import "RDRMyMeetingArrangeResponseModel.h"

@interface LPMyMeetingArrangeViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *timeField;
@property (weak, nonatomic) IBOutlet UITextField *joinerField;
@property (weak, nonatomic) IBOutlet UITextField *terminalField;
@property (weak, nonatomic) IBOutlet UITextField *roomsField;

@property (weak, nonatomic) IBOutlet UISwitch *repeatSwitch;


@property (nonatomic, strong) UIDatePicker *datePicker;

@end

@implementation LPMyMeetingArrangeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initControls];
    
    [self getDatas];
}

- (void)collapseAllTextField {
    [self.timeField resignFirstResponder];
    [self.joinerField resignFirstResponder];
    [self.terminalField resignFirstResponder];
    [self.roomsField resignFirstResponder];
}

// 初始化控件
- (void)initControls {
    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    self.timeField.inputView = self.datePicker;
    self.datePicker.date = [NSDate date];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgTapped:)]];
}

- (void)bgTapped:(UITapGestureRecognizer *)tapGesture {
    [self collapseAllTextField];
}

// 获取数据
- (void)getDatas {
    // 判断如果未取到通信录，则进行获取
    if ([LPSystemUser sharedUser].hasGetContacts == NO) {
        // 调用接口进行获取
        
        [self showLoadingView];
        
        __weak LPMyMeetingArrangeViewController *weakSelf = self;
        
        RDRMyMeetingArrangeContactsModel *reqModel = [RDRMyMeetingArrangeContactsModel requestModel];
        reqModel.uid = [LPSystemUser sharedUser].loginUserId;
        
        RDRRequest *req = [RDRRequest requestWithURLPath:nil model:reqModel];
        
        [RDRNetHelper GET:req responseModelClass:[RDRMyMeetingArrangeContactsResponseModel class]
                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                      [weakSelf hideHudAndIndicatorView];
                      
                      RDRMyMeetingArrangeContactsResponseModel *model = responseObject;
                      
                      if ([model codeCheckSuccess] == YES) {
                          NSLog(@"请求通讯录及终端设备列表success, model=%@", model);
                          
                          // 解析model数据
                          [LPSystemUser sharedUser].hasGetContacts = YES;
                          [LPSystemUser sharedUser].contactsList = [model.contacts mutableCopy];                          
                          [LPSystemUser sharedUser].devicesList = [model.devices mutableCopy];
                          
                          [weakSelf getDatas];
                      }else {
                          NSLog(@"请求通讯录及终端设备列表 服务器请求出错, model=%@, msg=%@", model, model.msg);
                      }
                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      [weakSelf hideHudAndIndicatorView];
                      
                      //请求出错
                      NSLog(@"请求通讯录及终端设备列表, %s, error=%@", __FUNCTION__, error);
                  }];
        return;
    }
    
    // 判断有无获取到收藏的会议室列表
    if ([LPSystemUser sharedUser].hasGetFavMeetingRooms == NO) {
        // 调用接口进行获取
        [self showLoadingView];
        
        __weak LPMyMeetingArrangeViewController *weakSelf = self;
        
        RDRMyMeetingArrangeRoomsModel *reqModel = [RDRMyMeetingArrangeRoomsModel requestModel];
        reqModel.uid = [LPSystemUser sharedUser].loginUserId;
        
        RDRRequest *req = [RDRRequest requestWithURLPath:nil model:reqModel];
        
        [RDRNetHelper GET:req responseModelClass:[RDRMyMeetingArrangeRoomResponseModel class]
                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                      [weakSelf hideHudAndIndicatorView];
                      
                      RDRMyMeetingArrangeRoomResponseModel *model = responseObject;
                      
                      if ([model codeCheckSuccess] == YES) {
                          NSLog(@"请求收藏的会议室列表success, model=%@", model);
                          
                          // 解析model数据
                          [LPSystemUser sharedUser].hasGetFavMeetingRooms = YES;
                          [LPSystemUser sharedUser].favMeetingRoomsList = [model.fav mutableCopy];
                          
                          [self showToastWithMessage:@"请安排会议"];
                          
                      }else {
                          NSLog(@"请求收藏的会议室列表服务器请求出错, model=%@, msg=%@", model, model.msg);
                      }
                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      [weakSelf hideHudAndIndicatorView];
                      
                      //请求出错
                      NSLog(@"请求收藏的会议室列表, %s, error=%@", __FUNCTION__, error);
                  }];
    }
}

#pragma mark - UICompositeViewDelegate Functions
static UICompositeViewDescription *compositeDescription = nil;

+ (UICompositeViewDescription *)compositeViewDescription {
    if(compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:@"MeetingArrange"
                                                                content:@"LPMyMeetingArrangeViewController"
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

- (IBAction)phoneBookClicked:(id)sender {
    
}

- (IBAction)myTerminalsClicked:(id)sender {
}

- (IBAction)myRoomsClicked:(id)sender {
}

- (IBAction)confirmBtnClicked:(id)sender {
    [self showLoadingView];

    RDRMyMeetingArrangeModel *reqModel = [RDRMyMeetingArrangeModel requestModel];
    reqModel.uid = [LPSystemUser sharedUser].loginUserId;
    reqModel.pwd = [LPSystemUser sharedUser].loginUserPassword;
    reqModel.time = self.timeField.text;
    reqModel.repeat = self.repeatSwitch.on ? @"1":@"0";
    reqModel.addr = self.roomsField.text;
    reqModel.participants = @[];     // 添加与会者名单
    // TODO
    
    RDRRequest *req = [RDRRequest requestWithURLPath:nil model:reqModel];
    __weak LPMyMeetingArrangeViewController *weakSelf = self;
    [RDRNetHelper POST:req responseModelClass:[RDRMyMeetingArrangeResponseModel class] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [weakSelf hideHudAndIndicatorView];
        RDRMyMeetingArrangeResponseModel *model = responseObject;

        if ([model codeCheckSuccess] == YES) {
            NSLog(@"安排会议室success, model=%@", model);
            [self showToastWithMessage:@"安排会议成功"];
        }else {
            NSLog(@"安排会议室请求出错, model=%@, msg=%@", model, model.msg);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [weakSelf hideHudAndIndicatorView];
            
        //请求出错
        NSLog(@"安排会议室出错, %s, error=%@", __FUNCTION__, error);
    }];
}

#pragma mark UITextField delegate
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
