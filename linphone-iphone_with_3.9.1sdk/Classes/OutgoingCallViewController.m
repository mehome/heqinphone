//
//  OutgoingCallViewController.m
//  linphone
//
//  Created by heqin on 16/8/2.
//
//

#import "OutgoingCallViewController.h"
#import "LPSystemUser.h"
#import "LPSystemSetting.h"

@interface OutgoingCallViewController ()

@property (strong, nonatomic) IBOutlet UILabel *callTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *callSubtitleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *callHeaderImgView;

@end

@implementation OutgoingCallViewController

static UICompositeViewDescription *compositeDescription = nil;

+ (UICompositeViewDescription *)compositeViewDescription {
    if (compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:self.class
                                                              statusBar:nil
                                                                 tabBar:nil
                                                               sideMenu:nil
                                                             fullscreen:YES
                                                         isLeftFragment:NO
                                                           fragmentWith:nil
                                                   supportLandscapeMode:NO];
        
        compositeDescription.darkBackground = true;
    }
    return compositeDescription;
}

- (UICompositeViewDescription *)compositeViewDescription {
    return self.class.compositeViewDescription;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self dataFillToPreview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)dataFillToPreview {
    NSMutableString *addr = [NSMutableString stringWithString:[LPSystemUser sharedUser].curMeetingAddr ?:@""];
    self.callSubtitleLabel.text = [[NSString stringWithString:addr] copy];
    
    NSString *proxyTempStr = [NSString stringWithFormat:@"@%@", [LPSystemSetting sharedSetting].sipTmpProxy];
    
    // 移掉后部
    if ([addr replaceOccurrencesOfString:proxyTempStr withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [addr length])] != 0) {
        NSLog(@"remove server address done");
    }else {
        NSLog(@"remove server address failed");
    }
    
    // 移掉前面的sip:
    if ([addr replaceOccurrencesOfString:@"sip:" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [addr length])] != 0) {
        NSLog(@"remove sip done");
    }else {
        NSLog(@"remove sip failed");
    }
    
    self.callTitleLabel.text = [NSString stringWithString:addr];
}

- (IBAction)endCallBtnClicked:(UIButton *)sender {
    LinphoneCall *call = linphone_core_get_current_call(LC);
    if (call) {
        linphone_core_terminate_call(LC, call);
    }
}

- (NSDictionary*)attributesForView:(UIView*)view {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    
    [attributes setObject:[NSValue valueWithCGRect:view.frame] forKey:@"frame"];
    [attributes setObject:[NSValue valueWithCGRect:view.bounds] forKey:@"bounds"];
    if([view isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)view;
        [LinphoneUtils buttonMultiViewAddAttributes:attributes button:button];
    }
    [attributes setObject:[NSNumber numberWithInteger:view.autoresizingMask] forKey:@"autoresizingMask"];
    
    return attributes;
}

- (void)applyAttributes:(NSDictionary*)attributes toView:(UIView*)view {
    view.frame = [[attributes objectForKey:@"frame"] CGRectValue];
    view.bounds = [[attributes objectForKey:@"bounds"] CGRectValue];
    if([view isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)view;
        [LinphoneUtils buttonMultiViewApplyAttributes:attributes button:button];
    }
    view.autoresizingMask = [[attributes objectForKey:@"autoresizingMask"] integerValue];
}


@end
