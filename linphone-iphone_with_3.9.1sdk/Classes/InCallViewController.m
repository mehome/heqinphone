/* InCallViewController.h
 *
 * Copyright (C) 2009  Belledonne Comunications, Grenoble, France
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or   
 *  (at your option) any later version.                                 
 *                                                                      
 *  This program is distributed in the hope that it will be useful,     
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of      
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the       
 *  GNU General Public License for more details.                
 *                                                                      
 *  You should have received a copy of the GNU General Public License   
 *  along with this program; if not, write to the Free Software         
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */  

#import <AudioToolbox/AudioToolbox.h>
#import <AddressBook/AddressBook.h>
#import <QuartzCore/CAAnimation.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>

#import "IncallViewController.h"
#import "LinphoneManager.h"
#import "PhoneMainView.h"
#import "DTActionSheet.h"

#import "UICallBar.h"

#include "linphone/linphonecore.h"


@implementation InCallViewController {
    BOOL hiddenVolume;
}

@synthesize videoGroup;
@synthesize videoView;
@synthesize videoPreview;
@synthesize videoCameraSwitch;
@synthesize videoWaitingForFirstImage;
@synthesize loadingImgView;
#ifdef TEST_VIDEO_VIEW_CHANGE
@synthesize testVideoView;
#endif


#pragma mark - Lifecycle Functions

- (id)init {
    self = [super initWithNibName:@"InCallViewController" bundle:[NSBundle mainBundle]];
    if(self != nil) {
        self->videoZoomHandler = [[VideoZoomHandler alloc] init];
    }
    return self;
}

- (void)dealloc {
    // Remove all observer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UICompositeViewDelegate Functions

static UICompositeViewDescription *compositeDescription = nil;

- (UICompositeViewDescription *)compositeViewDescription {
    return self.class.compositeViewDescription;
}

+ (UICompositeViewDescription *)compositeViewDescription {
    if(compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:self.class
                                                              statusBar:nil
                                                                 tabBar:[UICallBar class]
                                                               sideMenu:nil
                                                             fullscreen:false
                                                         isLeftFragment:false
                                                           fragmentWith:nil
                                                   supportLandscapeMode:NO];
        compositeDescription.darkBackground = true;
    }
    return compositeDescription;
}

#pragma mark - ViewController Functions

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    UIDevice *device = [UIDevice currentDevice];
    device.proximityMonitoringEnabled = YES;

    [[PhoneMainView instance] setVolumeHidden:TRUE];
    hiddenVolume = TRUE;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if( hiddenVolume ) {
        [[PhoneMainView instance] setVolumeHidden:FALSE];
        hiddenVolume = FALSE;
    }
    
    // Remove observer
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                 name:kLinphoneCallUpdate
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Set observer
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(callUpdateEvent:) 
                                                 name:kLinphoneCallUpdate
                                               object:nil];
    
    // Update on show
    LinphoneCall* call = linphone_core_get_current_call([LinphoneManager getLc]);
    LinphoneCallState state = (call != NULL)?linphone_call_get_state(call): 0;
    [self callUpdate:call state:state animated:FALSE];

    // Set windows (warn memory leaks)
    linphone_core_set_native_video_window_id(LC, (__bridge void *)(videoView));
    linphone_core_set_native_preview_window_id(LC, (__bridge void *)(videoPreview));

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
	[[UIApplication sharedApplication] setIdleTimerDisabled:false];
	UIDevice *device = [UIDevice currentDevice];
    device.proximityMonitoringEnabled = NO;

    [[PhoneMainView instance] fullScreen:false];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [videoZoomHandler setup:videoGroup];
    videoGroup.alpha = 0;
    
    [videoCameraSwitch setAlpha:1.0];
    
    [videoCameraSwitch setPreview:videoPreview];
    
    
    [videoWaitingForFirstImage setHidden: NO];
    [videoWaitingForFirstImage startAnimating];
    [loadingImgView setHidden:NO];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
// in mode display_filter_auto_rotate=0, no need to rotate the preview
}


#pragma mark -

- (void)callUpdate:(LinphoneCall *)call state:(LinphoneCallState)state animated:(BOOL)animated {
	LinphoneCore *lc = [LinphoneManager getLc];

    if( hiddenVolume ){
        [[PhoneMainView instance] setVolumeHidden:FALSE];
        hiddenVolume = FALSE;
    }
    
    // Fake call update
    if(call == NULL) {
        return;
    }

	switch (state) {					
		case LinphoneCallIncomingReceived: 
		case LinphoneCallOutgoingInit: 
        {
            if(linphone_core_get_calls_nb(lc) > 1) {
            }
        }
		case LinphoneCallConnected:
		case LinphoneCallStreamsRunning:
        {
			//check video
			if (linphone_call_params_video_enabled(linphone_call_get_current_params(call))) {
			} else {
				[self displayTableCall:animated];
                const LinphoneCallParams* param = linphone_call_get_current_params(call);
                const LinphoneCallAppData *callAppData = (__bridge const LinphoneCallAppData *)(linphone_call_get_user_pointer(call));
				if(state == LinphoneCallStreamsRunning
				   && callAppData->videoRequested
				   && linphone_call_params_low_bandwidth_enabled(param)) {
					//too bad video was not enabled because low bandwidth
					UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Low bandwidth", nil)
																	message:NSLocalizedString(@"Video cannot be activated because of low bandwidth condition, only audio is available", nil)
																   delegate:nil
														  cancelButtonTitle:NSLocalizedString(@"Continue", nil)
														  otherButtonTitles:nil];
					[alert show];
					callAppData->videoRequested=FALSE; /*reset field*/
				}
            }
			break;
        }
        case LinphoneCallUpdatedByRemote:
        {
            const LinphoneCallParams* current = linphone_call_get_current_params(call);
            const LinphoneCallParams* remote = linphone_call_get_remote_params(call);
            
            /* remote wants to add video */
            if (linphone_core_video_enabled(lc) && !linphone_call_params_video_enabled(current) &&
                linphone_call_params_video_enabled(remote) && 
                !linphone_core_get_video_policy(lc)->automatically_accept) {
                linphone_core_defer_call_update(lc, call);
                [self displayAskToEnableVideoCall:call];
            } else if (linphone_call_params_video_enabled(current) && !linphone_call_params_video_enabled(remote)) {
                [self displayTableCall:animated];
            }
            break;
        }
        case LinphoneCallPausing:
        case LinphoneCallPaused:
        case LinphoneCallPausedByRemote:
        {
            [self displayTableCall:animated];
            break;
        }
        case LinphoneCallEnd:
        case LinphoneCallError:
        {
            if(linphone_core_get_calls_nb(lc) <= 2 && !videoShown) {
            }
            break;
        }
        default:
            break;
	}
    
}


#ifdef TEST_VIDEO_VIEW_CHANGE
// Define TEST_VIDEO_VIEW_CHANGE in IncallViewController.h to enable video view switching testing
- (void)_debugChangeVideoView {
    static bool normalView = false;
    if (normalView) {
        linphone_core_set_native_video_window_id([LinphoneManager getLc], (unsigned long)videoView);
    } else {
        linphone_core_set_native_video_window_id([LinphoneManager getLc], (unsigned long)testVideoView);
    }
    normalView = !normalView;
}
#endif

- (void)disableVideoDisplay:(BOOL)animation {
    if(!videoShown && animation)
        return;
    
    videoShown = false;
    if(animation) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:1.0];
    }
    
    [videoGroup setAlpha:0.0];

    [videoCameraSwitch setHidden:TRUE];
    
    if(animation) {
        [UIView commitAnimations];
    }
    
    [[PhoneMainView instance] fullScreen:false];
}

- (void)displayTableCall:(BOOL)animated {
    [self disableVideoDisplay:animated];
}


#pragma mark - Spinner Functions

- (void)hideSpinnerIndicator: (LinphoneCall*)call {
    videoWaitingForFirstImage.hidden = TRUE;
    loadingImgView.hidden = TRUE;
}

static void hideSpinner(LinphoneCall* call, void* user_data) {
    InCallViewController* thiz = (__bridge InCallViewController*) user_data;
    [thiz hideSpinnerIndicator:call];
}


#pragma mark - Event Functions

- (void)callUpdateEvent: (NSNotification*) notif {
    LinphoneCall *call = [[notif.userInfo objectForKey: @"call"] pointerValue];
    LinphoneCallState state = [[notif.userInfo objectForKey: @"state"] intValue];
    [self callUpdate:call state:state animated:TRUE];
}


#pragma mark - ActionSheet Functions

- (void)displayAskToEnableVideoCall:(LinphoneCall*) call {
    if (linphone_core_get_video_policy([LinphoneManager getLc])->automatically_accept)
        return;
    
    const char* lUserNameChars = linphone_address_get_username(linphone_call_get_remote_address(call));
    NSString* lUserName = lUserNameChars?[[NSString alloc] initWithUTF8String:lUserNameChars]:NSLocalizedString(@"Unknown",nil);
    const char* lDisplayNameChars =  linphone_address_get_display_name(linphone_call_get_remote_address(call));        
	NSString* lDisplayName = lDisplayNameChars?[[NSString alloc] initWithUTF8String:lDisplayNameChars]:@"";
    
    NSString* title = [NSString stringWithFormat : NSLocalizedString(@"'%@' would like to enable video",nil), ([lDisplayName length] > 0)?lDisplayName:lUserName];
    DTActionSheet *sheet = [[DTActionSheet alloc] initWithTitle:title];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(dismissVideoActionSheet:) userInfo:sheet repeats:NO];
    [sheet addButtonWithTitle:NSLocalizedString(@"Accept", nil)  block:^() {
        LOGI(@"User accept video proposal");
        LinphoneCallParams* paramsCopy = linphone_call_params_copy(linphone_call_get_current_params(call));
        linphone_call_params_enable_video(paramsCopy, TRUE);
        linphone_core_accept_call_update([LinphoneManager getLc], call, paramsCopy);
        linphone_call_params_destroy(paramsCopy);
        [timer invalidate];
    }];
    DTActionSheetBlock cancelBlock = ^() {
        LOGI(@"User declined video proposal");
        LinphoneCallParams* paramsCopy = linphone_call_params_copy(linphone_call_get_current_params(call));
        linphone_core_accept_call_update([LinphoneManager getLc], call, paramsCopy);
        linphone_call_params_destroy(paramsCopy);
        [timer invalidate];
    };
    [sheet addDestructiveButtonWithTitle:NSLocalizedString(@"Decline", nil)  block:cancelBlock];
    if([LinphoneManager runningOnIpad]) {
        [sheet addCancelButtonWithTitle:NSLocalizedString(@"Decline", nil)  block:cancelBlock];
    }
    [sheet showInView:[PhoneMainView instance].view];
}

- (void)dismissVideoActionSheet:(NSTimer*)timer {
     DTActionSheet *sheet = (DTActionSheet *)timer.userInfo;
    [sheet dismissWithClickedButtonIndex:sheet.destructiveButtonIndex animated:TRUE];
}


@end
