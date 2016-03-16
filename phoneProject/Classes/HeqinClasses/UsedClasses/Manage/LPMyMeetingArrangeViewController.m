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

#import "RDRCellsSelectView.h"

#import "RDRParticipant.h"

#import "LPPhoneListView.h"
#import "RDRPhoneModel.h"

@interface LPMyMeetingArrangeViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *timeField;
@property (weak, nonatomic) IBOutlet UITextField *joinerField;
//@property (weak, nonatomic) IBOutlet UITextField *terminalField;
@property (weak, nonatomic) IBOutlet UITextField *roomsField;

@property (weak, nonatomic) IBOutlet UISwitch *repeatSwitch;

@property (nonatomic, strong) NSArray *selectedJoiners;
@property (nonatomic, strong) NSArray *selectedRooms;

@property (nonatomic, strong) UIDatePicker *datePicker;

@property (nonatomic, strong) NSDateFormatter *dateForm;

@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;

@end

@implementation LPMyMeetingArrangeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initControls];
    
    [self getDatas];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchMan:) name:kSearchNumbersDatasForArrangeMeeting object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginOut:) name:@"kCurUserLoginOutNotification" object:nil];
}

- (void)loginOut:(NSNotification *)notifi {
    self.selectedJoiners = @[];
    self.selectedRooms = @[];
    
    self.timeField.text = @"";
    self.joinerField.text = @"";
    self.roomsField.text = @"";
}

- (void)collapseAllTextField {
    [self.timeField resignFirstResponder];
    [self.joinerField resignFirstResponder];
    [self.roomsField resignFirstResponder];
}

- (NSDateFormatter *)dateForm {
    if (_dateForm == nil) {
        _dateForm = [[NSDateFormatter alloc] init];
        [_dateForm setTimeStyle:NSDateFormatterMediumStyle];
        [_dateForm setDateStyle:NSDateFormatterMediumStyle];
        _dateForm.dateFormat = @"yyyy-MM-dd HH:mm";
        [_dateForm setLocale:[NSLocale currentLocale]];
    }
    
    return _dateForm;
}

// 初始化控件
- (void)initControls {
    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    self.timeField.inputView = self.datePicker;
    [self.datePicker addTarget:self action:@selector(dateChange:) forControlEvents:UIControlEventValueChanged];
    self.datePicker.date = [NSDate date];
    
    // 初始化时间设置为明天同一时刻
    NSString *curStr = [self.dateForm stringFromDate:[[NSDate date] dateByAddingTimeInterval:24 * 60 * 60]];
    self.timeField.text = curStr;
    
    self.joinerField.enabled = NO;
    self.roomsField.enabled = NO;
    
    self.selectedJoiners = [NSArray array];
    self.selectedRooms = [NSArray array];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgTapped:)]];
    
    self.confirmBtn.backgroundColor = yellowSubjectColor;
    self.confirmBtn.layer.cornerRadius = 5.0;
    self.confirmBtn.clipsToBounds = YES;
}

- (void)dateChange:(UIDatePicker *)dp {
    NSDate *changeDate = dp.date;
    NSString *changeStr = [self.dateForm stringFromDate:changeDate];
    self.timeField.text = changeStr;
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
        reqModel.uid = [[LPSystemUser sharedUser].settingsStore stringForKey:@"userid_preference"];
        
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
        reqModel.uid = [[LPSystemUser sharedUser].settingsStore stringForKey:@"userid_preference"];
        
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
    UIWindow *superView = [[UIApplication sharedApplication] keyWindow];

    UIView *bgView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    bgView.tag = 1000201;
    bgView.backgroundColor = [UIColor clearColor];
    [superView addSubview:bgView];
    
    UIView *grayBgView = [[UIView alloc] initWithFrame:bgView.bounds];
    grayBgView.backgroundColor = [UIColor grayColor];
    grayBgView.alpha = 0.5;
    [bgView addSubview:grayBgView];
    
    LPPhoneListView *listView = [[LPPhoneListView alloc] initWithFrame:CGRectInset(bgView.frame, 10, 40)];
    [listView setForJoinMeeting:0];
    [bgView addSubview:listView];
    
    [grayBgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(listViewbgTapped:)]];
}

- (void)listViewbgTapped:(UITapGestureRecognizer *)tapGesture {
    UIWindow *superView = [[UIApplication sharedApplication] keyWindow];

    if ([superView viewWithTag:1000201] != nil) {
        [[superView viewWithTag:1000201] removeFromSuperview];
    }
}

// 选择了对应的通讯录人员和终端
- (void)searchMan:(NSNotification *)notif {
    NSLog(@"notifi.user=%@", notif.userInfo);
    NSLog(@"notifi.object=%@", notif.object);
    
    NSArray *models = notif.object;
    if (models == nil) {
        
    }else {
        NSMutableArray *parts = [NSMutableArray array];
        for (NSInteger i=0; i<models.count; i++) {
            RDRPhoneModel *model = [models objectAtIndex:i];
            
            RDRContactModel *usedModel = [[RDRContactModel alloc] init];
            usedModel.uid = model.uid;
            usedModel.name = model.name;
            
            [parts addObject:usedModel];
        }

        self.selectedJoiners = [NSArray arrayWithArray:parts];
        // 更新与会者输入框
        [self updateJoinerField];
    }
    
    [self listViewbgTapped:nil];
}


- (IBAction)testphoneBookClicked:(id)sender {
    // 显示通讯录
    if ([LPSystemUser sharedUser].contactsList.count == 0) {
        [self showToastWithMessage:@"当前用户通讯录为空"];
        return;
    }
    
    [RDRCellsSelectView showSelectViewWith:@"请选择与会者"
                                   withArr:[LPSystemUser sharedUser].contactsList
                            hasSelectedArr:self.selectedJoiners
                          withConfirmBlock:^(NSArray *selectedDatas) {
                              NSLog(@"selected datas=%@", selectedDatas);
                              self.selectedJoiners = [NSArray arrayWithArray:selectedDatas];
                              // 更新与会者输入框
                              [self updateJoinerField];
                          }
                           withCancelBlcok:^{
                               NSLog(@"取消选择");
                           }
                              singleChoose:NO];
}

- (void)updateJoinerField {
    NSMutableString *str = [NSMutableString stringWithString:@""];
    for (NSInteger i=0; i<self.selectedJoiners.count; i++) {
        RDRContactModel *contactModel = [self.selectedJoiners objectAtIndex:i];
        [str appendString:contactModel.name];
        [str appendString:@","];
    }
    
    if (str.length > 0) {
        [str deleteCharactersInRange:NSMakeRange(str.length-1, 1)];
    }
    
    self.joinerField.text = str;
}

//- (IBAction)myTerminalsClicked:(id)sender {
//    // 显示的我的收藏的终端
//    if ([LPSystemUser sharedUser].devicesList.count == 0) {
//        [self showToastWithMessage:@"收藏的终端列表为空"];
//        return;
//    }
//    
//    [RDRCellsSelectView showSelectViewWith:@"请选择终端列表" withArr:[LPSystemUser sharedUser].devicesList
//                            hasSelectedArr:self.selectedDevices
//                          withConfirmBlock:^(NSArray *selectedDatas) {
//        NSLog(@"selected devie=%@", selectedDatas);
//                              self.selectedDevices = [NSArray arrayWithArray:selectedDatas];
//                              // 更新终端输入框
//                              [self updateDeviceField];
//    } withCancelBlcok:^{
//        NSLog(@"取消终端选择");
//    } singleChoose:NO];
//}

//- (void)updateDeviceField {
//    NSMutableString *str = [NSMutableString stringWithString:@""];
//    for (NSInteger i=0; i<self.selectedDevices.count; i++) {
//        RDRDeviceModel *deviceModel = [self.selectedDevices objectAtIndex:i];
//        [str appendString:deviceModel.name];
//        [str appendString:@","];
//    }
//    
//    if (str.length > 0) {
//        [str deleteCharactersInRange:NSMakeRange(str.length-1, 1)];
//    }
//    
//    self.terminalField.text = str;
//}

- (IBAction)myRoomsClicked:(id)sender {
    // 判断有无获取到收藏的会议室列表
    // 调用接口进行获取
    [self showLoadingView];
    
    __weak LPMyMeetingArrangeViewController *weakSelf = self;
    
    RDRMyMeetingArrangeRoomsModel *reqModel = [RDRMyMeetingArrangeRoomsModel requestModel];
    reqModel.uid = [[LPSystemUser sharedUser].settingsStore stringForKey:@"userid_preference"];
    
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
                      
                      // 显示我的收藏的会议室
                      if ([LPSystemUser sharedUser].favMeetingRoomsList.count == 0) {
                          [self showToastWithMessage:@"收藏的会议室为空，快去收藏一些吧"];
                          return;
                      }else {
                          [self askForSelectMeetingRoom];
                      }
                      
                  }else {
                      NSLog(@"请求收藏的会议室列表服务器请求出错, model=%@, msg=%@", model, model.msg);
                  }
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  [weakSelf hideHudAndIndicatorView];
                  
                  //请求出错
                  NSLog(@"请求收藏的会议室列表, %s, error=%@", __FUNCTION__, error);
              }];
    
}

- (void)askForSelectMeetingRoom {
    [RDRCellsSelectView showSelectViewWith:@"请选择收藏的会议室" withArr:[LPSystemUser sharedUser].favMeetingRoomsList
                            hasSelectedArr:self.selectedRooms
                          withConfirmBlock:^(NSArray *selectedDatas) {
                              NSLog(@"selected room=%@", selectedDatas);
                              self.selectedRooms = [NSArray arrayWithArray:selectedDatas];
                              // 更新会议室输入框
                              [self updateRoomField];
                          } withCancelBlcok:^{
                              NSLog(@"取消会议室选择");
                          } singleChoose:YES];
}

- (void)updateRoomField {
    NSMutableString *str = [NSMutableString stringWithString:@""];
    for (NSInteger i=0; i<self.selectedRooms.count; i++) {
        RDRArrangeRoomModel *roomModel = [self.selectedRooms objectAtIndex:i];
        [str appendString:roomModel.name];
        [str appendString:@","];
    }
    
    if (str.length > 0) {
        [str deleteCharactersInRange:NSMakeRange(str.length-1, 1)];
    }
    
    self.roomsField.text = str;
}

- (IBAction)confirmBtnClicked:(id)sender {
    
    NSMutableArray *parts = [NSMutableArray array];
    for (NSInteger i=0; i<self.selectedJoiners.count; i++) {
        RDRContactModel *model = [self.selectedJoiners objectAtIndex:i];
        
        RDRParticipant *cipant = [[RDRParticipant alloc] init];
        cipant.uid = model.uid;
        cipant.name = model.name;
        [parts addObject:cipant];
    }
    
//    for (NSInteger i=0; i<self.selectedDevices.count; i++) {
//        RDRDeviceModel *model = [self.selectedDevices objectAtIndex:i];
//        
//        RDRParticipant *cipant = [[RDRParticipant alloc] init];
//        cipant.uid = model.uid;
//        cipant.name = model.name;
//        [parts addObject:cipant];
//    }

    if (parts.count == 0) {
        [self showToastWithMessage:@"请选择参会人员"];
        return;
    }
    
    if (self.selectedRooms.count == 0) {
        [self showToastWithMessage:@"请选择开会的地点"];
        return;
    }
    
    [self showLoadingView];
    
    // 判断有没有安排会议室，无会议室，是没法安排的
    RDRMyMeetingArrangeModel *reqModel = [RDRMyMeetingArrangeModel requestModel];
    reqModel.uid = [[LPSystemUser sharedUser].settingsStore stringForKey:@"userid_preference"];
    reqModel.pwd = [[LPSystemUser sharedUser].settingsStore stringForKey:@"password_preference"];
    reqModel.time = self.timeField.text;
    reqModel.repeat = self.repeatSwitch.on ? @"1":@"0";
    reqModel.participants = [NSArray arrayWithArray:parts];     // 添加与会者名单
    
    RDRArrangeRoomModel *roomModel = self.selectedRooms.firstObject;
    reqModel.addr = roomModel.addr;
    
    RDRRequest *req = [RDRRequest requestWithURLPath:nil model:reqModel];
    __weak LPMyMeetingArrangeViewController *weakSelf = self;
    [RDRNetHelper POST:req responseModelClass:[RDRMyMeetingArrangeResponseModel class] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [weakSelf hideHudAndIndicatorView];
        RDRMyMeetingArrangeResponseModel *model = responseObject;

        if ([model codeCheckSuccess] == YES) {
            NSLog(@"安排会议室success, model=%@", model);
            [weakSelf showToastWithMessage:@"安排会议成功"];
        }else {
            NSString *tipStr = [NSString stringWithFormat:@"安排会议室请求出错, msg=%@", model.msg];
            [weakSelf showToastWithMessage:tipStr];
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
