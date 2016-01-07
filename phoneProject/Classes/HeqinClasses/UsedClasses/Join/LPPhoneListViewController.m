//
//  LPPhoneListViewController.m
//  linphone
//
//  Created by baidu on 16/1/7.
//
//

#import "LPPhoneListViewController.h"
#import "LPPhoneListView.h"

@interface LPPhoneListViewController ()

@property (nonatomic, strong) LPPhoneListView *phoneView;

@end

@implementation LPPhoneListViewController

#pragma mark - UICompositeViewDelegate Functions

static UICompositeViewDescription *compositeDescription = nil;

+ (UICompositeViewDescription *)compositeViewDescription {
    if(compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:@"JoinPhoneList"
                                                                content:@"LPPhoneListViewController"
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

- (void)viewDidLoad {
    [super viewDidLoad];

    self.phoneView = [[LPPhoneListView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.phoneView];
}

- (void)viewWillAppear:(BOOL)animated {
    self.phoneView.frame = self.view.bounds;
    [self.phoneView setForJoinMeeting:1];
}

@end
