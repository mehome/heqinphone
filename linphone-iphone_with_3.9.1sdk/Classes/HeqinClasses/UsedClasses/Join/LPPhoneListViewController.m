//
//  LPPhoneListViewController.m
//  linphone
//
//  Created by baidu on 16/1/7.
//
//

#import "LPPhoneListViewController.h"
#import "LPPhoneListView.h"
#import "PhoneMainView.h"
#import "LPJoinMettingViewController.h"

@interface LPPhoneListViewController ()

@property (nonatomic, strong) LPPhoneListView *phoneView;

@end

@implementation LPPhoneListViewController

#pragma mark - UICompositeViewDelegate Functions

static UICompositeViewDescription *compositeDescription = nil;

- (UICompositeViewDescription *)compositeViewDescription {
    return self.class.compositeViewDescription;
}

+ (UICompositeViewDescription *)compositeViewDescription {
    if(compositeDescription == nil) {
//        compositeDescription = [[UICompositeViewDescription alloc] init:@"JoinPhoneList"
//                                                                content:@"LPPhoneListViewController"
//                                                               stateBar:nil
//                                                        stateBarEnabled:false
//                                                                 tabBar:@"LPJoinBarViewController"
//                                                          tabBarEnabled:true
//                                                             fullscreen:false
//                                                          landscapeMode:[LinphoneManager runningOnIpad]
//                                                           portraitMode:true];
        compositeDescription = [[UICompositeViewDescription alloc] init:self.class
                                                              statusBar:nil
                                                                 tabBar:[LPJoinBarViewController class]
                                                               sideMenu:nil
                                                             fullscreen:NO
                                                         isLeftFragment:NO
                                                           fragmentWith:nil
                                                   supportLandscapeMode:NO];

        compositeDescription.darkBackground = true;
    }
    return compositeDescription;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)phoneNotification:(NSNotification *)notifi {
    NSLog(@"phonelist notifi =%@", notifi);
    
    [[PhoneMainView instance] changeCurrentView:[LPJoinMettingViewController compositeViewDescription]];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.phoneView = [[LPPhoneListView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.phoneView];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(phoneNotification:) name:kSearchNumbersDatasForJoineMeeting object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    self.phoneView.frame = self.view.bounds;
    [self.phoneView setForJoinMeeting:1];
}

@end
