//
//  LPMyManageSingleViewController.m
//  linphone
//
//  Created by baidu on 15/11/16.
//
//

#import "LPMyManageSingleViewController.h"
//#import "RDRManageLockMeetingRequestModel.h"
//#import "RDRManageLockMeetingResponseModel.h"
#import "UIViewController+RDRTipAndAlert.h"
#import "RDRRequest.h"
#import "RDRNetHelper.h"

#import "RDRManageSettingMeetingRequestModel.h"
#import "RDRManageSeetingMeetingResponseModel.h"

#import "RDRManageCloseMeetingRequsetModel.h"
#import "RDRManageCloseMeetingResponseModel.h"

#import "LPSystemUser.h"

@interface LPMyManageSingleViewController () <UITextFieldDelegate>

@property (nonatomic, strong) RDRJoinMeetingModel *model;

@property (weak, nonatomic) IBOutlet UILabel *meetingNameLabel;

@property (weak, nonatomic) IBOutlet UITextField *hostPinTextField;
@property (weak, nonatomic) IBOutlet UITextField *guestPinTextField;
@property (weak, nonatomic) IBOutlet UITextField *statusTextField;

@property (weak, nonatomic) IBOutlet UIButton *statusBtn;

@end

@implementation LPMyManageSingleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.statusTextField.userInteractionEnabled = NO;
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgTap:)]];
}

- (void)collapseKeyboard {
    [self.hostPinTextField resignFirstResponder];
    [self.guestPinTextField resignFirstResponder];
}

- (void)bgTap:(UITapGestureRecognizer *)tapGesture {
    [self collapseKeyboard];
}

- (void)updateWithModel:(RDRJoinMeetingModel *)model {
    self.model = model;
    
    self.meetingNameLabel.text = model.name.length>0 ? model.name : model.addr;
    self.hostPinTextField.text = self.model.hostPinStr;
    self.guestPinTextField.text = self.model.guestPinStr;
 
    [self updateLockStatus];
}

#pragma mark - UICompositeViewDelegate Functions

static UICompositeViewDescription *compositeDescription = nil;

+ (UICompositeViewDescription *)compositeViewDescription {
    if(compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:@"SingleManage"
                                                                content:@"LPMyManageSingleViewController"
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

- (void)updateLockStatus {
    if (self.model.meetingStatus == 0) {
        [self.statusBtn setTitle:@"关闭" forState:UIControlStateNormal];
        self.statusTextField.text = @"当前会议室开放";
    }else if(self.model.meetingStatus == 1) {
        self.statusTextField.text = @"当前会议室关闭";
        [self.statusBtn setTitle:@"打开" forState:UIControlStateNormal];
    }else {
        self.statusTextField.text = @"当前会议室状态未知";
        [self.statusBtn setTitle:@"打开" forState:UIControlStateNormal];
    }
}

- (IBAction)lockBtnClicked:(id)sender {
    NSLog(@"关闭按钮触发");
    [self collapseKeyboard];

    NSInteger closeStatus = 0;
    if (self.model.meetingStatus == 0) {
        // 将进行关闭
        closeStatus = 1;
    }else {
        // 将进行打开
        closeStatus = 0;
    }
    
    // 向服务器进行请求
    [self showLoadingView];
    
    __weak LPMyManageSingleViewController *weakSelf = self;
    
    RDRManageCloseMeetingRequsetModel *reqModel = [RDRManageCloseMeetingRequsetModel requestModel];
    reqModel.close = [NSString stringWithFormat:@"%d", closeStatus];
    reqModel.addr = self.model.addr;
    
    [[LPSystemUser sharedUser].settingsStore transformLinphoneCoreToKeys];
    NSString *idStr = [[LPSystemUser sharedUser].settingsStore stringForKey:@"userid_preference"];
    NSString *loginUserPassword = [[LPSystemUser sharedUser].settingsStore stringForKey:@"password_preference"];
    
    reqModel.uid = idStr;
    reqModel.pwd = loginUserPassword;
    
    RDRRequest *req = [RDRRequest requestWithURLPath:nil model:reqModel];
    
    [RDRNetHelper GET:req responseModelClass:[RDRManageCloseMeetingResponseModel class]
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  [weakSelf hideHudAndIndicatorView];
                  
                  RDRManageCloseMeetingResponseModel *model = responseObject;
                  
                  if ([model codeCheckSuccess] == YES) {
                      NSLog(@"请求关闭会议与否成功, model=%@", model);
                      
                      if (closeStatus == 0) {
                          [weakSelf showToastWithMessage:@"打开会议室成功"];
                      }else {
                          [weakSelf showToastWithMessage:@"关闭会议室成功"];
                      }
                      
                      weakSelf.model.meetingStatus = closeStatus;
                      
                      // 刷新界面
                      [weakSelf updateLockStatus];
                  }else {
                      NSLog(@"请求关闭会议与否成功, 服务器请求出错, model=%@, msg=%@", model, model.msg);
                      if (closeStatus == 0) {
                          [weakSelf showToastWithMessage:@"打开会议室失败，服务器检查值错误"];
                      }else {
                          [weakSelf showToastWithMessage:@"关闭会议室失败，服务器检查值错误"];
                      }
                  }
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  [weakSelf hideHudAndIndicatorView];
                  
                  if (closeStatus == 0) {
                      [weakSelf showToastWithMessage:@"打开会议室失败，服务器错误"];
                  }else {
                      [weakSelf showToastWithMessage:@"关闭会议室失败，服务器错误"];
                  }
                  
                  //请求出错
                  NSLog(@"请求锁定会议与否成功, %s, error=%@", __FUNCTION__, error);
              }];
}

- (IBAction)setBtnClicked:(id)sender {
    NSLog(@"设置按钮触发");
    [self collapseKeyboard];
    
    NSString *setHostPin = self.hostPinTextField.text.length == 0 ? @"" : self.hostPinTextField.text;
    NSString *setGuestPin = self.guestPinTextField.text.length == 0 ? @"" : self.guestPinTextField.text;
    
    [self showLoadingView];
    
    __weak LPMyManageSingleViewController *weakSelf = self;
    
    RDRManageSettingMeetingRequestModel *reqModel = [RDRManageSettingMeetingRequestModel requestModel];
    reqModel.pin = setHostPin;
    reqModel.guestpin = setGuestPin;
    reqModel.addr = self.model.addr;
    
    [[LPSystemUser sharedUser].settingsStore transformLinphoneCoreToKeys];
    NSString *idStr = [[LPSystemUser sharedUser].settingsStore stringForKey:@"userid_preference"];
    NSString *loginUserPassword = [[LPSystemUser sharedUser].settingsStore stringForKey:@"password_preference"];
    
    reqModel.uid = idStr;
    reqModel.pwd = loginUserPassword;
    
    // 需要设置PIN码，看是以什么形式来输入这个PIN码
    //    reqModel.meetingPin = self.model.
    RDRRequest *req = [RDRRequest requestWithURLPath:nil model:reqModel];
    
    [RDRNetHelper GET:req responseModelClass:[RDRManageSeetingMeetingResponseModel class]
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  [weakSelf hideHudAndIndicatorView];
                  
                  RDRManageSeetingMeetingResponseModel *model = responseObject;
                  
                  if ([model codeCheckSuccess] == YES) {
                      NSLog(@"请求设置会议与否成功, model=%@", model);
                      
                      [weakSelf showToastWithMessage:@"设置会议室成功"];
                      
                      weakSelf.model.hostPinStr = setHostPin;
                      weakSelf.model.guestPinStr = setGuestPin;
                  }else {
                      NSLog(@"请求设置会议与否成功, 服务器请求出错, model=%@, msg=%@", model, model.msg);
                      [weakSelf showToastWithMessage:@"设置会议室失败，服务器检查值出错"];
                  }
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  [weakSelf hideHudAndIndicatorView];
                  
                  [weakSelf showToastWithMessage:@"设置会议室失败，服务器错误"];
                  
                  //请求出错
                  NSLog(@"请求锁定会议与否成功, %s, error=%@", __FUNCTION__, error);
              }];
}

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