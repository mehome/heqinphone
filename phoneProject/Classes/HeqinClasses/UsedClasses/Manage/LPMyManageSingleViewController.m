//
//  LPMyManageSingleViewController.m
//  linphone
//
//  Created by baidu on 15/11/16.
//
//

#import "LPMyManageSingleViewController.h"

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
}

- (void)updateWithModel:(RDRJoinMeetingModel *)model {
    self.model = model;
    
    self.meetingNameLabel.text = model.name.length>0 ? model.name : model.addr;
    self.hostPinTextField.text = self.model.hostPinStr;
    self.guestPinTextField.text = self.model.guestPinStr;
    
    if (self.model.meetingStatus == 0) {
        self.statusTextField.text = @"锁定";
    }else if(self.model.meetingStatus == 1) {
        self.statusTextField.text = @"开放";
    }else if(self.model.meetingStatus == 2) {
        self.statusTextField.text = @"关闭";
    }else {
        self.statusTextField.text = @"未知";
    }
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

- (IBAction)settingBtnClicked:(id)sender {
    
}

- (IBAction)lockBtnClicked:(id)sender {
    NSLog(@"锁定按钮触发");
}

- (IBAction)setBtnClicked:(id)sender {
    NSLog(@"设置按钮触发");
}

@end