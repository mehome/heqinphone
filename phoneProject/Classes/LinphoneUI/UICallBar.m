/* UICallBar.m
 *
 * Copyright (C) 2012  Belledonne Comunications, Grenoble, France
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or   
 *  (at your option) any later version.                                 
 *                                                                      
 *  This program is distributed in the hope that it will be useful,     
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of      
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the       
 *  GNU Library General Public License for more details.                
 *                                                                      
 *  You should have received a copy of the GNU General Public License   
 *  along with this program; if not, write to the Free Software         
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */ 

#import "UICallBar.h"
#import "LinphoneManager.h"
#import "PhoneMainView.h"
#import "Utils.h"
#import "CAAnimation+Blocks.h"

#include "linphone/linphonecore.h"

@interface UICallBar ()

@property (retain, nonatomic) IBOutlet UIButton *bottomSoundBtn;
@property (retain, nonatomic) IBOutlet UIButton *bottomVedioBtn;
@property (retain, nonatomic) IBOutlet UIButton *bottomInviteBtn;
@property (retain, nonatomic) IBOutlet UIButton *bottomJoinerBtn;
@property (retain, nonatomic) IBOutlet UIButton *bottomMoreBtn;

@property (retain, nonatomic) IBOutlet UIView *voiceBgView;
@property (retain, nonatomic) IBOutlet UIView *cameraBgView;
@property (retain, nonatomic) IBOutlet UIView *moreBgView;
@property (retain, nonatomic) IBOutlet UIView *inviteBgView;

@property (retain, nonatomic) IBOutlet UIButton *popVoiceSiclenBtn;
@property (retain, nonatomic) IBOutlet UIButton *popVoiceNoSilenceBtn;
@property (retain, nonatomic) IBOutlet UIButton *popCameraFrontBtn;
@property (retain, nonatomic) IBOutlet UIButton *popCameraTailBtn;
@property (retain, nonatomic) IBOutlet UIButton *popCameraCloseBtn;
@property (retain, nonatomic) IBOutlet UIButton *popInviteMailBtn;
@property (retain, nonatomic) IBOutlet UIButton *popInviteSMSBtn;
@property (retain, nonatomic) IBOutlet UIButton *popInviteCallBtn;
@property (retain, nonatomic) IBOutlet UIButton *popInviteCopyAddBtn;
@property (retain, nonatomic) IBOutlet UIButton *popMoreOnlyShareStreamBtn;
@property (retain, nonatomic) IBOutlet UIButton *popMoreOnlyShareVedioBtn;
@property (retain, nonatomic) IBOutlet UIButton *popMoreLockMeetingBtn;
@property (retain, nonatomic) IBOutlet UIButton *popMoreCloseMeetingBtn;

@property (retain, nonatomic) IBOutlet UIButton *collectionBtn;
@property (retain, nonatomic) IBOutlet UIButton *quitBtn;

@end

@implementation UICallBar

@synthesize pauseButton;
@synthesize conferenceButton;
@synthesize videoButton;
@synthesize microButton;
@synthesize speakerButton;
@synthesize routesButton;
@synthesize optionsButton;
@synthesize hangupButton;
@synthesize routesBluetoothButton;
@synthesize routesReceiverButton;
@synthesize routesSpeakerButton;
@synthesize optionsAddButton;
@synthesize optionsTransferButton;
@synthesize dialerButton;

@synthesize routesView;
@synthesize optionsView;

#pragma mark - Lifecycle Functions

- (id)init {
    return [super initWithNibName:@"UICallBar" bundle:[NSBundle mainBundle]];
}

- (void)dealloc {
    [pauseButton release];
    [conferenceButton release];
    [videoButton release];
    [microButton release];
    [speakerButton release];
    [routesButton release];
    [optionsButton release];
    [routesBluetoothButton release];
    [routesReceiverButton release];
    [routesSpeakerButton release];
    [optionsAddButton release];
    [optionsTransferButton release];
    [dialerButton release];
    
    [routesView release];
    [optionsView release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

#pragma mark - ViewController Functions

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(callUpdateEvent:) 
                                                 name:kLinphoneCallUpdate
                                               object:nil];
    // Update on show
    LinphoneCall* call = linphone_core_get_current_call([LinphoneManager getLc]);
    LinphoneCallState state = (call != NULL)?linphone_call_get_state(call): 0;
    
    [self callUpdate:call state:state];
    [self hideRoutes:FALSE];
    [self hideOptions:FALSE];
    [self hidePad:FALSE];
    [self showSpeaker];
    
    [self showAllBottomBgView];
}

- (void)hideAllBottomBgView {
    [self hideControlsVoiceBgView:YES];
    [self hideControlsCameraBgView:YES];
    [self hideControlsInviteBgView:YES];
    [self hideControlsMoreBgView:YES];
}

- (void)showAllBottomBgView {
    [self hideControlsVoiceBgView:NO];
    [self hideControlsCameraBgView:NO];
    [self hideControlsInviteBgView:NO];
    [self hideControlsMoreBgView:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:kLinphoneCallUpdate
                                                  object:nil];
	if (linphone_core_get_calls_nb([LinphoneManager getLc]) == 0) {
		//reseting speaker button because no more call
		speakerButton.selected=FALSE; 
	}
}

// 底部声音按钮
- (IBAction)soundBtnClicked:(id)sender {
    [self hideControlsCameraBgView:YES];
    [self hideControlsInviteBgView:YES];
    [self hideControlsMoreBgView:YES];
    
    if (self.voiceBgView.hidden == YES) {
        // 显示出来
        [self hideControlsVoiceBgView:NO];
    }else {
        // 隐藏
        [self hideControlsVoiceBgView:YES];
    }
}

// 底部视频按钮
- (IBAction)vedioBtnClicked:(id)sender {
    [self hideControlsVoiceBgView:YES];
    [self hideControlsInviteBgView:YES];
    [self hideControlsMoreBgView:YES];

    if (self.cameraBgView.hidden == YES) {
        [self hideControlsCameraBgView:NO];
    }else {
        [self hideControlsCameraBgView:YES];
    }
}

// 底部邀请按钮
- (IBAction)inviteBtnClicked:(id)sender {
    [self hideControlsVoiceBgView:YES];
    [self hideControlsCameraBgView:YES];
    [self hideControlsMoreBgView:YES];

    if (self.inviteBgView.hidden == YES) {
        [self hideControlsInviteBgView:NO];
    }else {
        [self hideControlsInviteBgView:YES];
    }
}

// 底部参与人按钮
- (IBAction)joinerBtnClicked:(id)sender {
    [self hideControlsVoiceBgView:YES];
    [self hideControlsCameraBgView:YES];
    [self hideControlsInviteBgView:YES];
    [self hideControlsMoreBgView:YES];

    NSLog(@"joiner btn clicked");
}

// 底部更多按钮
- (IBAction)moreBtnClicked:(id)sender {
    [self hideControlsVoiceBgView:YES];
    [self hideControlsCameraBgView:YES];
    [self hideControlsInviteBgView:YES];
    
    if (self.moreBgView.hidden == YES) {
        [self hideControlsMoreBgView:NO];
    }else {
        [self hideControlsMoreBgView:YES];
    }
}

// 收藏按钮
- (IBAction)collectionBtnClicked:(id)sender {
    [self hideAllBottomBgView];
    // TODO
}

// 退出按钮
- (IBAction)quitBtnClicked:(id)sender {
    [self hideAllBottomBgView];

    LinphoneCore* lc = [LinphoneManager getLc];
    LinphoneCall* currentcall = linphone_core_get_current_call(lc);
    if (linphone_core_is_in_conference(lc) || // In conference
        (linphone_core_get_conference_size(lc) > 0 && [UICallBar callCount:lc] == 0) // Only one conf
        ) {
        linphone_core_terminate_conference(lc);
    } else if(currentcall != NULL) { // In a call
        linphone_core_terminate_call(lc, currentcall);
    } else {
        const MSList* calls = linphone_core_get_calls(lc);
        if (ms_list_size(calls) == 1) { // Only one call
            linphone_core_terminate_call(lc,(LinphoneCall*)(calls->data));
        }
    }
}

// 静音
- (IBAction)popVoiceOff:(id)sender {
    linphone_core_mute_mic([LinphoneManager getLc], true);
}

// 关闭静音
- (IBAction)popVoiceOn:(id)sender {
    linphone_core_mute_mic([LinphoneManager getLc], false);
}

// 打开前摄像头
- (IBAction)popCameraFront:(id)sender {
    LinphoneCore* lc = [LinphoneManager getLc];
    
    if (!linphone_core_video_enabled(lc))
        return;
    
    LinphoneCall* call = linphone_core_get_current_call([LinphoneManager getLc]);
    if (call) {
        LinphoneCallAppData* callAppData = (LinphoneCallAppData*)linphone_call_get_user_pointer(call);
        callAppData->videoRequested=TRUE; /* will be used later to notify user if video was not activated because of the linphone core*/
        LinphoneCallParams* call_params =  linphone_call_params_copy(linphone_call_get_current_params(call));
        linphone_call_params_enable_video(call_params, TRUE);
        linphone_core_update_call(lc, call, call_params);
        linphone_call_params_destroy(call_params);
    } else {
        [LinphoneLogger logc:LinphoneLoggerWarning format:"Cannot toggle video button, because no current call"];
    }
    
    [self hideAllBottomBgView];
}

// 打开后摄像头，实际上是一段切换镜头的操作
// TODO，应该尝试去只选择性地控制前后摄像头
- (IBAction)popCameraTail:(id)sender {
    const char *currentCamId = (char*)linphone_core_get_video_device([LinphoneManager getLc]);
    const char **cameras=linphone_core_get_video_devices([LinphoneManager getLc]);
    
    const char *newCamId=NULL;
    int i;
    
    for (i=0;cameras[i]!=NULL;++i){
        if (strcmp(cameras[i],"StaticImage: Static picture")==0) continue;
        if (strcmp(cameras[i],currentCamId)!=0){
            newCamId=cameras[i];
            break;
        }
    }
    if (newCamId){
        [LinphoneLogger logc:LinphoneLoggerLog format:"Switching from [%s] to [%s]", currentCamId, newCamId];
        linphone_core_set_video_device([LinphoneManager getLc], newCamId);
        LinphoneCall *call = linphone_core_get_current_call([LinphoneManager getLc]);
        if(call != NULL) {
            linphone_core_update_call([LinphoneManager getLc], call, NULL);
        }
    }
    
    [self hideAllBottomBgView];
}

// 关闭摄像头
- (IBAction)popCameraClose:(id)sender {
    LinphoneCore* lc = [LinphoneManager getLc];
    
    if (!linphone_core_video_enabled(lc))
        return;
    
//    [self setEnabled: FALSE];
//    [waitView startAnimating];
    
    LinphoneCall* call = linphone_core_get_current_call([LinphoneManager getLc]);
    if (call) {
        LinphoneCallParams* call_params =  linphone_call_params_copy(linphone_call_get_current_params(call));
        linphone_call_params_enable_video(call_params, FALSE);
        linphone_core_update_call(lc, call, call_params);
        linphone_call_params_destroy(call_params);
    } else {
        [LinphoneLogger logc:LinphoneLoggerWarning format:"Cannot toggle video button, because no current call"];
    }
}

// 发邮件
- (IBAction)sendMailBtnClicked:(id)sender {
}
// 发短信
- (IBAction)sendSMSBtnClicked:(id)sender {
}
// 呼号
- (IBAction)callBtnClicked:(id)sender {
}
// 复制地址
- (IBAction)copyAddressBtnClicked:(id)sender {
}

// 仅共享流
- (IBAction)shareStreamBtnClicked:(id)sender {
}
// 仅共享视频
- (IBAction)shareVedioBtnClicked:(id)sender {
}
// 锁定会议
- (IBAction)lockMeetingBtnClicked:(id)sender {
}
// 结束会议
- (IBAction)endMeetingBtnClicked:(id)sender {
}

+ (int)callCount:(LinphoneCore*) lc {
    int count = 0;
    const MSList* calls = linphone_core_get_calls(lc);
    
    while (calls != 0) {
        if (![UICallBar isInConference:((LinphoneCall*)calls->data)]) {
            count++;
        }
        calls = calls->next;
    }
    return count;
}

+ (bool)isInConference:(LinphoneCall*) call {
    if (!call)
        return false;
    return linphone_call_is_in_conference(call);
}

- (void)hideControlsVoiceBgView:(BOOL)hide {
    if (hide == YES) {
        // 隐藏
        if (self.voiceBgView.hidden == YES) {
            // 当前已经隐藏
        }else {
            // 进行隐藏
            [self hideAnimation:@"hide" target:self.voiceBgView completion:^(BOOL finished){}];
        }
    }else {
        // 显示
        if (self.voiceBgView.hidden == NO) {
            // 当前已经显示
        }else {
            // 进行显示
            [self showAnimation:@"show" target:self.voiceBgView completion:^(BOOL finished){}];
        }
    }
}

- (void)hideControlsCameraBgView:(BOOL)hide {
    if (hide == YES) {
        // 隐藏
        if (self.cameraBgView.hidden == YES) {
            // 当前已经隐藏
        }else {
            // 进行隐藏
            [self hideAnimation:@"hide" target:self.cameraBgView completion:^(BOOL finished){}];
        }
    }else {
        // 显示
        if (self.cameraBgView.hidden == NO) {
            // 当前已经显示
        }else {
            // 进行显示
            [self showAnimation:@"show" target:self.cameraBgView completion:^(BOOL finished){}];
        }
    }
}

- (void)hideControlsInviteBgView:(BOOL)hide {
    if (hide == YES) {
        // 隐藏
        if (self.inviteBgView.hidden == YES) {
            // 当前已经隐藏
        }else {
            // 进行隐藏
            [self hideAnimation:@"hide" target:self.inviteBgView completion:^(BOOL finished){}];
        }
    }else {
        // 显示
        if (self.inviteBgView.hidden == NO) {
            // 当前已经显示
        }else {
            // 进行显示
            [self showAnimation:@"show" target:self.inviteBgView completion:^(BOOL finished){}];
        }
    }
}

- (void)hideControlsMoreBgView:(BOOL)hide {
    if (hide == YES) {
        // 隐藏
        if (self.moreBgView.hidden == YES) {
            // 当前已经隐藏
        }else {
            // 进行隐藏
            [self hideAnimation:@"hide" target:self.moreBgView completion:^(BOOL finished){}];
        }
    }else {
        // 显示
        if (self.moreBgView.hidden == NO) {
            // 当前已经显示
        }else {
            // 进行显示
            [self showAnimation:@"show" target:self.moreBgView completion:^(BOOL finished){}];
        }
    }
}

#pragma mark - Event Functions

- (void)callUpdateEvent:(NSNotification*)notif {
    LinphoneCall *call = [[notif.userInfo objectForKey: @"call"] pointerValue];
    LinphoneCallState state = [[notif.userInfo objectForKey: @"state"] intValue];
    [self callUpdate:call state:state];
}

#pragma mark - 

- (void)callUpdate:(LinphoneCall*)call state:(LinphoneCallState)state {  
    LinphoneCore* lc = [LinphoneManager getLc]; 

    [speakerButton update];
    [microButton update];
    [pauseButton update];
    [videoButton update];
    [hangupButton update];
    
    
//    // Show Pause/Conference button following call count
//    if(linphone_core_get_calls_nb(lc) > 1) {
//        if(![pauseButton isHidden]) {
//            [pauseButton setHidden:true];
//            [conferenceButton setHidden:false];
//        }
//        bool enabled = true;
//        const MSList *list = linphone_core_get_calls(lc);
//        while(list != NULL) {
//            LinphoneCall *call = (LinphoneCall*) list->data;
//            LinphoneCallState state = linphone_call_get_state(call);
//            if(state == LinphoneCallIncomingReceived ||
//               state == LinphoneCallOutgoingInit ||
//               state == LinphoneCallOutgoingProgress ||
//               state == LinphoneCallOutgoingRinging ||
//               state == LinphoneCallOutgoingEarlyMedia ||
//               state == LinphoneCallConnected) {
//                enabled = false;
//            }
//            list = list->next;
//        }
//        [conferenceButton setEnabled:enabled];
//    } else {
//        if([pauseButton isHidden]) {
//            [pauseButton setHidden:false];
//            [conferenceButton setHidden:true];
//        }
//    }

//    // Disable transfert in conference
//    if(linphone_core_get_current_call(lc) == NULL) {
//        [optionsTransferButton setEnabled:FALSE];
//    } else {
//        [optionsTransferButton setEnabled:TRUE];
//    }
    
    switch(state) {
        case LinphoneCallEnd:
        case LinphoneCallError:
        case LinphoneCallIncoming:
        case LinphoneCallOutgoing:
            [self hidePad:TRUE];
            [self hideOptions:TRUE];
            [self hideRoutes:TRUE];
        default:
            break;
    }
}

- (void)bluetoothAvailabilityUpdate:(bool)available {
    if (available) {
        [self hideSpeaker];
    } else {
        [self showSpeaker];
    }
}


#pragma mark -

- (void)showAnimation:(NSString*)animationID target:(UIView*)target completion:(void (^)(BOOL finished))completion {
    CGRect frame = [target frame];
    int original_y = frame.origin.y;
    frame.origin.y = [[self view] frame].size.height;
    [target setFrame:frame];
    [target setHidden:FALSE];
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         CGRect frame = [target frame];
                         frame.origin.y = original_y;
                         [target setFrame:frame];
                     }
                     completion:^(BOOL finished){
                         CGRect frame = [target frame];
                         frame.origin.y = original_y;
                         [target setFrame:frame];
                         completion(finished);
                     }];
}

- (void)hideAnimation:(NSString*)animationID target:(UIView*)target completion:(void (^)(BOOL finished))completion {
    CGRect frame = [target frame];
    int original_y = frame.origin.y;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         CGRect frame = [target frame];
                         frame.origin.y = [[self view] frame].size.height;
                         [target setFrame:frame];
                     }
                     completion:^(BOOL finished){
                         CGRect frame = [target frame];
                         frame.origin.y = original_y;
                         [target setHidden:TRUE];
                         [target setFrame:frame];
                         completion(finished);
                     }];
}

- (void)showPad:(BOOL)animated {
    [dialerButton setOn];
}

- (void)hidePad:(BOOL)animated {
    [dialerButton setOff];
}

- (void)showRoutes:(BOOL)animated {
    if (![LinphoneManager runningOnIpad]) {
        [routesButton setOn];
        [routesBluetoothButton setSelected:[[LinphoneManager instance] bluetoothEnabled]];
        [routesSpeakerButton setSelected:[[LinphoneManager instance] speakerEnabled]];
        [routesReceiverButton setSelected:!([[LinphoneManager instance] bluetoothEnabled] || [[LinphoneManager instance] speakerEnabled])];
        if([routesView isHidden]) {
            if(animated) {
                [self showAnimation:@"show" target:routesView completion:^(BOOL finished){}];
            } else {
                [routesView setHidden:FALSE];
            }
        }
    }
}

- (void)hideRoutes:(BOOL)animated {
    if (![LinphoneManager runningOnIpad]) {
        [routesButton setOff];
        if(![routesView isHidden]) {
            if(animated) {
                [self hideAnimation:@"hide" target:routesView completion:^(BOOL finished){}];
            } else {
                [routesView setHidden:TRUE];
            }
        }
    }
}

- (void)showOptions:(BOOL)animated {
    [optionsButton setOn];
    if([optionsView isHidden]) {
        if(animated) {
            [self showAnimation:@"show" target:optionsView completion:^(BOOL finished){}];
        } else {
            [optionsView setHidden:FALSE];
        }
    }
}

- (void)hideOptions:(BOOL)animated {
    [optionsButton setOff];
    if(![optionsView isHidden]) {
        if(animated) {
            [self hideAnimation:@"hide" target:optionsView completion:^(BOOL finished){}];
        } else {
            [optionsView setHidden:TRUE];
        }
    }
}

- (void)showSpeaker {
    if (![LinphoneManager runningOnIpad]) {
        [speakerButton setHidden:FALSE];
        [routesButton setHidden:TRUE];
    }
}

- (void)hideSpeaker {
    if (![LinphoneManager runningOnIpad]) {
        [speakerButton setHidden:TRUE];
        [routesButton setHidden:FALSE];
    }
}


#pragma mark - Action Functions

- (IBAction)onPadClick:(id)sender {
    // 点击键盘来弹出数字键盘
}

- (IBAction)onRoutesBluetoothClick:(id)sender {
    [self hideRoutes:TRUE];
    [[LinphoneManager instance] setBluetoothEnabled:TRUE];
}

- (IBAction)onRoutesReceiverClick:(id)sender {
    [self hideRoutes:TRUE];
    [[LinphoneManager instance] setSpeakerEnabled:FALSE];
    [[LinphoneManager instance] setBluetoothEnabled:FALSE];
}

- (IBAction)onRoutesSpeakerClick:(id)sender {
    [self hideRoutes:TRUE];
    [[LinphoneManager instance] setSpeakerEnabled:TRUE];
}

- (IBAction)onRoutesClick:(id)sender {
    if([routesView isHidden]) {
        [self showRoutes:[[LinphoneManager instance] lpConfigBoolForKey:@"animations_preference"]];
    } else {
        [self hideRoutes:[[LinphoneManager instance] lpConfigBoolForKey:@"animations_preference"]];
    }
}

- (IBAction)onOptionsTransferClick:(id)sender {
    [self hideOptions:TRUE];
    // Go to dialer view   
    DialerViewController *controller = DYNAMIC_CAST([[PhoneMainView instance] changeCurrentView:[DialerViewController compositeViewDescription]], DialerViewController);
    if(controller != nil) {
        [controller setAddress:@""];
        [controller setTransferMode:TRUE];
    }
}

- (IBAction)onOptionsAddClick:(id)sender {
    [self hideOptions:TRUE];
    // Go to dialer view   
    DialerViewController *controller = DYNAMIC_CAST([[PhoneMainView instance] changeCurrentView:[DialerViewController compositeViewDescription]], DialerViewController);
    if(controller != nil) {
        [controller setAddress:@""];
        [controller setTransferMode:FALSE];
    }
}

- (IBAction)onOptionsClick:(id)sender {
    if([optionsView isHidden]) {
        [self showOptions:[[LinphoneManager instance] lpConfigBoolForKey:@"animations_preference"]];
    } else {
        [self hideOptions:[[LinphoneManager instance] lpConfigBoolForKey:@"animations_preference"]];
    }
}

// 暂停会议
- (IBAction)onConferenceClick:(id)sender {
    linphone_core_add_all_to_conference([LinphoneManager getLc]);
}


#pragma mark - TPMultiLayoutViewController Functions

- (NSDictionary*)attributesForView:(UIView*)view {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];

    [attributes setObject:[NSValue valueWithCGRect:view.frame] forKey:@"frame"];
    [attributes setObject:[NSValue valueWithCGRect:view.bounds] forKey:@"bounds"];
    if([view isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)view;    
		[LinphoneUtils buttonMultiViewAddAttributes:attributes button:button];
	} else if (view.tag ==self.leftPadding.tag || view.tag == self.rightPadding.tag){
        if ([view isKindOfClass:[UIImageView class]]) {
            UIImage* image = [(UIImageView*)view image];
            if( image ){
                [attributes setObject:image forKey:@"image"];
            }
        }
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
    } else if (view.tag ==self.leftPadding.tag || view.tag == self.rightPadding.tag){
        if ([view isKindOfClass:[UIImageView class]]) {
            [(UIImageView*)view setImage:[attributes objectForKey:@"image"]];
        }
    }
    view.autoresizingMask = [[attributes objectForKey:@"autoresizingMask"] integerValue];
}

@end
