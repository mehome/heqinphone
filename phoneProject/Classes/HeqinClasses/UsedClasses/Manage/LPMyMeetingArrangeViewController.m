//
//  LPMyMeetingArrangeViewController.m
//  linphone
//
//  Created by baidu on 15/11/16.
//
//

#import "LPMyMeetingArrangeViewController.h"

@interface LPMyMeetingArrangeViewController ()

@property (weak, nonatomic) IBOutlet UITextField *timeField;
@property (weak, nonatomic) IBOutlet UITextField *joinerField;
@property (weak, nonatomic) IBOutlet UITextField *terminalField;
@property (weak, nonatomic) IBOutlet UITextField *roomsField;

@property (weak, nonatomic) IBOutlet UISwitch *repeatSwitch;
@end

@implementation LPMyMeetingArrangeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICompositeViewDelegate Functions

static UICompositeViewDescription *compositeDescription = nil;

+ (UICompositeViewDescription *)compositeViewDescription {
    if(compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:@"MeetingArrange"
                                                                content:@"LPMyMeetingArrangeViewController"
                                                               stateBar:nil
                                                        stateBarEnabled:false
                                                                 tabBar:@"LPMyMeetingBarViewController"
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
    
}

@end
