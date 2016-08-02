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

#import "CallView.h"
#import "LinphoneManager.h"
#import "PhoneMainView.h"
#import "Utils.h"

#include "linphone/linphonecore.h"

const NSInteger SECURE_BUTTON_TAG = 5;

@implementation CallView {
	BOOL hiddenVolume;
}

#pragma mark - Lifecycle Functions

- (id)init {
	self = [super initWithNibName:NSStringFromClass(self.class) bundle:[NSBundle mainBundle]];
	if (self != nil) {
		singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleControls:)];
		videoZoomHandler = [[VideoZoomHandler alloc] init];
		videoHidden = TRUE;
	}
	return self;
}

#pragma mark - UICompositeViewDelegate Functions

static UICompositeViewDescription *compositeDescription = nil;

+ (UICompositeViewDescription *)compositeViewDescription {
	if (compositeDescription == nil) {
		compositeDescription = [[UICompositeViewDescription alloc] init:self.class
															  statusBar:nil
																 tabBar:nil
															   sideMenu:nil
															 fullscreen:false
														 isLeftFragment:YES
														   fragmentWith:nil
                                                   supportLandscapeMode:YES];
		compositeDescription.darkBackground = true;
	}
	return compositeDescription;
}

- (UICompositeViewDescription *)compositeViewDescription {
	return self.class.compositeViewDescription;
}

#pragma mark - ViewController Functions

- (void)viewDidLoad {
	[super viewDidLoad];

// TODO: fixme! video preview frame is too big compared to openGL preview
// frame, so until this is fixed, temporary disabled it.
#if 0
	_videoPreview.layer.borderColor = UIColor.whiteColor.CGColor;
	_videoPreview.layer.borderWidth = 1;
#endif
	[singleFingerTap setNumberOfTapsRequired:1];
	[singleFingerTap setCancelsTouchesInView:FALSE];
	[self.videoView addGestureRecognizer:singleFingerTap];

	[videoZoomHandler setup:_videoGroup];
	_videoGroup.alpha = 0;

	UIPanGestureRecognizer *dragndrop = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveVideoPreview:)];
	dragndrop.minimumNumberOfTouches = 1;
	[_videoPreview addGestureRecognizer:dragndrop];

	[_zeroButton setDigit:'0'];
	[_zeroButton setDtmf:true];
	[_oneButton setDigit:'1'];
	[_oneButton setDtmf:true];
	[_twoButton setDigit:'2'];
	[_twoButton setDtmf:true];
	[_threeButton setDigit:'3'];
	[_threeButton setDtmf:true];
	[_fourButton setDigit:'4'];
	[_fourButton setDtmf:true];
	[_fiveButton setDigit:'5'];
	[_fiveButton setDtmf:true];
	[_sixButton setDigit:'6'];
	[_sixButton setDtmf:true];
	[_sevenButton setDigit:'7'];
	[_sevenButton setDtmf:true];
	[_eightButton setDigit:'8'];
	[_eightButton setDtmf:true];
	[_nineButton setDigit:'9'];
	[_nineButton setDtmf:true];
	[_starButton setDigit:'*'];
	[_starButton setDtmf:true];
	[_hashButton setDigit:'#'];
	[_hashButton setDtmf:true];
}

- (void)dealloc {
	[PhoneMainView.instance.view removeGestureRecognizer:singleFingerTap];
	// Remove all observer
	[NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	LinphoneManager.instance.nextCallIsTransfer = NO;

	// Update on show
	[self hidePad:TRUE animated:FALSE];
	[self hideSpeaker:LinphoneManager.instance.bluetoothAvailable];
	[self onCurrentCallChange];
	// Set windows (warn memory leaks)
	linphone_core_set_native_video_window_id(LC, (__bridge void *)(_videoView));
	linphone_core_set_native_preview_window_id(LC, (__bridge void *)(_videoPreview));

	[self previewTouchLift];

	// Enable tap
	[singleFingerTap setEnabled:TRUE];

	[NSNotificationCenter.defaultCenter addObserver:self
										   selector:@selector(bluetoothAvailabilityUpdateEvent:)
											   name:kLinphoneBluetoothAvailabilityUpdate
											 object:nil];
	[NSNotificationCenter.defaultCenter addObserver:self
										   selector:@selector(callUpdateEvent:)
											   name:kLinphoneCallUpdate
											 object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	UIDevice.currentDevice.proximityMonitoringEnabled = YES;

	[PhoneMainView.instance setVolumeHidden:TRUE];
	hiddenVolume = TRUE;

	// we must wait didAppear to reset fullscreen mode because we cannot change it in viewwillappear
	LinphoneCall *call = linphone_core_get_current_call(LC);
	LinphoneCallState state = (call != NULL) ? linphone_call_get_state(call) : 0;
	[self callUpdate:call state:state animated:FALSE];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	[self disableVideoDisplay:TRUE animated:NO];

	if (hideControlsTimer != nil) {
		[hideControlsTimer invalidate];
		hideControlsTimer = nil;
	}

	if (hiddenVolume) {
		[PhoneMainView.instance setVolumeHidden:FALSE];
		hiddenVolume = FALSE;
	}

	if (videoDismissTimer) {
		[self dismissVideoActionSheet:videoDismissTimer];
		[videoDismissTimer invalidate];
		videoDismissTimer = nil;
	}

	// Remove observer
	[NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];

	[[UIApplication sharedApplication] setIdleTimerDisabled:false];
	UIDevice.currentDevice.proximityMonitoringEnabled = NO;

	[PhoneMainView.instance fullScreen:false];
	// Disable tap
	[singleFingerTap setEnabled:FALSE];

	if (linphone_core_get_calls_nb(LC) == 0) {
		// reseting speaker button because no more call
		_speakerButton.selected = FALSE;
	}
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	[self previewTouchLift];
	[self hideStatusBar:!videoHidden];
}

#pragma mark - UI modification

- (void)hideSpinnerIndicator:(LinphoneCall *)call {
	_videoWaitingForFirstImage.hidden = TRUE;
}

static void hideSpinner(LinphoneCall *call, void *user_data) {
	CallView *thiz = (__bridge CallView *)user_data;
	[thiz hideSpinnerIndicator:call];
}

- (void)updateBottomBar:(LinphoneCall *)call state:(LinphoneCallState)state {
	[_speakerButton update];
	[_microButton update];

	_optionsButton.enabled = (!call || !linphone_core_sound_resources_locked(LC));


	switch (state) {
		case LinphoneCallEnd:
		case LinphoneCallError:
		case LinphoneCallIncoming:
		case LinphoneCallOutgoing:
			[self hidePad:TRUE animated:TRUE];
		default:
			break;
	}
}

- (void)toggleControls:(id)sender {
	bool controlsHidden = (_bottomBar.alpha == 0.0);
	[self hideControls:!controlsHidden sender:sender];
}

- (void)timerHideControls:(id)sender {
	[self hideControls:TRUE sender:sender];
}

- (void)hideControls:(BOOL)hidden sender:(id)sender {
	if (videoHidden && hidden)
		return;

	if (hideControlsTimer) {
		[hideControlsTimer invalidate];
		hideControlsTimer = nil;
	}

	if ([[PhoneMainView.instance currentView] equal:CallView.compositeViewDescription]) {
		// show controls
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.35];
		_numpadView.alpha = _bottomBar.alpha = (hidden ? 0 : 1);

		[self hideStatusBar:hidden];

		[UIView commitAnimations];

		[PhoneMainView.instance hideTabBar:hidden];

		if (!hidden) {
			// hide controls in 5 sec
			hideControlsTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
																 target:self
															   selector:@selector(timerHideControls:)
															   userInfo:nil
																repeats:NO];
		}
	}
}

- (void)disableVideoDisplay:(BOOL)disabled animated:(BOOL)animation {
	if (disabled == videoHidden && animation)
		return;
	videoHidden = disabled;

	if (!disabled) {
		[videoZoomHandler resetZoom];
	}
	if (animation) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:1.0];
	}

	[_videoGroup setAlpha:disabled ? 0 : 1];

	[self hideControls:!disabled sender:nil];

	if (animation) {
		[UIView commitAnimations];
	}

	// only show camera switch button if we have more than 1 camera
	_videoPreview.hidden = (disabled || !linphone_core_self_view_enabled(LC));

	if (hideControlsTimer != nil) {
		[hideControlsTimer invalidate];
		hideControlsTimer = nil;
	}

	[PhoneMainView.instance fullScreen:!disabled];
	[PhoneMainView.instance hideTabBar:!disabled];

	if (!disabled) {
#ifdef TEST_VIDEO_VIEW_CHANGE
		[NSTimer scheduledTimerWithTimeInterval:5.0
										 target:self
									   selector:@selector(_debugChangeVideoView)
									   userInfo:nil
										repeats:YES];
#endif
		// [self batteryLevelChanged:nil];

		[_videoWaitingForFirstImage setHidden:NO];
		[_videoWaitingForFirstImage startAnimating];

		LinphoneCall *call = linphone_core_get_current_call(LC);
		// linphone_call_params_get_used_video_codec return 0 if no video stream enabled
		if (call != NULL && linphone_call_params_get_used_video_codec(linphone_call_get_current_params(call))) {
			linphone_call_set_next_video_frame_decoded_callback(call, hideSpinner, (__bridge void *)(self));
		}
	}
}

- (void)displayVideoCall:(BOOL)animated {
	[self disableVideoDisplay:FALSE animated:animated];
}

- (void)displayAudioCall:(BOOL)animated {
	[self disableVideoDisplay:TRUE animated:animated];
}

- (void)hideStatusBar:(BOOL)hide {
	/* we cannot use [PhoneMainView.instance show]; because it will automatically
	 resize current view to fill empty space, which will resize video. This is
	 indesirable since we do not want to crop/rescale video view */
	PhoneMainView.instance.mainViewController.statusBarView.hidden = hide;
}

- (void)onCurrentCallChange {
	LinphoneCall *call = linphone_core_get_current_call(LC);
//    BOOL curIsHidden = (call || linphone_core_is_in_conference(LC));    // 用来判断当前是否在会议中
    
	_callView.hidden = !call;
}

- (void)hidePad:(BOOL)hidden animated:(BOOL)animated {
	if (hidden) {
		[_numpadButton setOff];
	} else {
		[_numpadButton setOn];
	}
	if (hidden != _numpadView.hidden) {
		if (animated) {
			[self hideAnimation:hidden forView:_numpadView completion:nil];
		} else {
			[_numpadView setHidden:hidden];
		}
	}
}

- (void)hideSpeaker:(BOOL)hidden {
	_speakerButton.hidden = hidden;
}

#pragma mark - Event Functions

- (void)bluetoothAvailabilityUpdateEvent:(NSNotification *)notif {
	bool available = [[notif.userInfo objectForKey:@"available"] intValue];
	[self hideSpeaker:available];
}

- (void)callUpdateEvent:(NSNotification *)notif {
	LinphoneCall *call = [[notif.userInfo objectForKey:@"call"] pointerValue];
	LinphoneCallState state = [[notif.userInfo objectForKey:@"state"] intValue];
	[self callUpdate:call state:state animated:TRUE];
}

- (void)callUpdate:(LinphoneCall *)call state:(LinphoneCallState)state animated:(BOOL)animated {
	[self updateBottomBar:call state:state];
	if (hiddenVolume) {
		[PhoneMainView.instance setVolumeHidden:FALSE];
		hiddenVolume = FALSE;
	}

	static LinphoneCall *currentCall = NULL;
	if (!currentCall || linphone_core_get_current_call(LC) != currentCall) {
		currentCall = linphone_core_get_current_call(LC);
		[self onCurrentCallChange];
	}

	// Fake call update
	if (call == NULL) {
		return;
	}

	BOOL shouldDisableVideo = (!currentCall || !linphone_call_params_video_enabled(linphone_call_get_current_params(currentCall)));
	if (videoHidden != shouldDisableVideo) {
		if (!shouldDisableVideo) {
			[self displayVideoCall:animated];
		} else {
			[self displayAudioCall:animated];
		}
	}

	switch (state) {
		case LinphoneCallIncomingReceived:
		case LinphoneCallOutgoingInit:
		case LinphoneCallConnected:
		case LinphoneCallStreamsRunning: {
			// check video
			if (!linphone_call_params_video_enabled(linphone_call_get_current_params(call))) {
				const LinphoneCallParams *param = linphone_call_get_current_params(call);
				const LinphoneCallAppData *callAppData =
					(__bridge const LinphoneCallAppData *)(linphone_call_get_user_pointer(call));
				if (state == LinphoneCallStreamsRunning && callAppData->videoRequested &&
					linphone_call_params_low_bandwidth_enabled(param)) {
					// too bad video was not enabled because low bandwidth
					UIAlertView *alert = [[UIAlertView alloc]
							initWithTitle:NSLocalizedString(@"Low bandwidth", nil)
								  message:NSLocalizedString(@"Video cannot be activated because of low bandwidth "
															@"condition, only audio is available",
															nil)
								 delegate:nil
						cancelButtonTitle:NSLocalizedString(@"Continue", nil)
						otherButtonTitles:nil];
					[alert show];
					callAppData->videoRequested = FALSE; /*reset field*/
				}
			}
			break;
		}
		case LinphoneCallUpdatedByRemote: {
			const LinphoneCallParams *current = linphone_call_get_current_params(call);
			const LinphoneCallParams *remote = linphone_call_get_remote_params(call);

			/* remote wants to add video */
			if (linphone_core_video_display_enabled(LC) && !linphone_call_params_video_enabled(current) &&
				linphone_call_params_video_enabled(remote) &&
				!linphone_core_get_video_policy(LC)->automatically_accept) {
				linphone_core_defer_call_update(LC, call);
				[self displayAskToEnableVideoCall:call];
			} else if (linphone_call_params_video_enabled(current) && !linphone_call_params_video_enabled(remote)) {
				[self displayAudioCall:animated];
			}
			break;
		}
		case LinphoneCallPausing:
		case LinphoneCallPaused:
			[self displayAudioCall:animated];
			break;
		case LinphoneCallPausedByRemote:
			[self displayAudioCall:animated];
			break;
		case LinphoneCallEnd:
		case LinphoneCallError:
		default:
			break;
	}
}

#pragma mark - ActionSheet Functions

- (void)displayAskToEnableVideoCall:(LinphoneCall *)call {
	if (linphone_core_get_video_policy(LC)->automatically_accept)
		return;

	NSString *username = [FastAddressBook displayNameForAddress:linphone_call_get_remote_address(call)];
	NSString *title = [NSString stringWithFormat:NSLocalizedString(@"%@ would like to enable video", nil), username];
	UIConfirmationDialog *sheet = [UIConfirmationDialog ShowWithMessage:title
		cancelMessage:nil
		confirmMessage:NSLocalizedString(@"ACCEPT", nil)
		onCancelClick:^() {
		  LOGI(@"User declined video proposal");
		  if (call == linphone_core_get_current_call(LC)) {
			  LinphoneCallParams *paramsCopy = linphone_call_params_copy(linphone_call_get_current_params(call));
			  linphone_core_accept_call_update(LC, call, paramsCopy);
			  linphone_call_params_destroy(paramsCopy);
			  [videoDismissTimer invalidate];
			  videoDismissTimer = nil;
		  }
		}
		onConfirmationClick:^() {
		  LOGI(@"User accept video proposal");
		  if (call == linphone_core_get_current_call(LC)) {
			  LinphoneCallParams *paramsCopy = linphone_call_params_copy(linphone_call_get_current_params(call));
			  linphone_call_params_enable_video(paramsCopy, TRUE);
			  linphone_core_accept_call_update(LC, call, paramsCopy);
			  linphone_call_params_destroy(paramsCopy);
			  [videoDismissTimer invalidate];
			  videoDismissTimer = nil;
		  }
		}
		inController:self];
	videoDismissTimer = [NSTimer scheduledTimerWithTimeInterval:30
														 target:self
													   selector:@selector(dismissVideoActionSheet:)
													   userInfo:sheet
														repeats:NO];
}

- (void)dismissVideoActionSheet:(NSTimer *)timer {
	UIConfirmationDialog *sheet = (UIConfirmationDialog *)timer.userInfo;
	[sheet dismiss];
}

#pragma mark VideoPreviewMoving

- (void)moveVideoPreview:(UIPanGestureRecognizer *)dragndrop {
	CGPoint center = [dragndrop locationInView:_videoPreview.superview];
	_videoPreview.center = center;
	if (dragndrop.state == UIGestureRecognizerStateEnded) {
		[self previewTouchLift];
	}
}

- (CGFloat)coerce:(CGFloat)value betweenMin:(CGFloat)min andMax:(CGFloat)max {
	return MAX(min, MIN(value, max));
}

- (void)previewTouchLift {
	CGRect previewFrame = _videoPreview.frame;
	previewFrame.origin.x = [self coerce:previewFrame.origin.x
							  betweenMin:5
								  andMax:(UIScreen.mainScreen.bounds.size.width - 5 - previewFrame.size.width)];
	previewFrame.origin.y = [self coerce:previewFrame.origin.y
							  betweenMin:5
								  andMax:(UIScreen.mainScreen.bounds.size.height - 5 - previewFrame.size.height)];

	if (!CGRectEqualToRect(previewFrame, _videoPreview.frame)) {
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		  [UIView animateWithDuration:0.3
						   animations:^{
							 LOGD(@"Recentering preview to %@", NSStringFromCGRect(previewFrame));
							 _videoPreview.frame = previewFrame;
						   }];
		});
	}
}

#pragma mark - Action Functions

- (IBAction)onNumpadClick:(id)sender {
	if ([_numpadView isHidden]) {
		[self hidePad:FALSE animated:ANIMATED];
	} else {
		[self hidePad:TRUE animated:ANIMATED];
	}
}

#pragma mark - Animation

- (void)hideAnimation:(BOOL)hidden forView:(UIView *)target completion:(void (^)(BOOL finished))completion {
	if (hidden) {
	int original_y = target.frame.origin.y;
	CGRect newFrame = target.frame;
	newFrame.origin.y = self.view.frame.size.height;
	[UIView animateWithDuration:0.5
		delay:0.0
		options:UIViewAnimationOptionCurveEaseIn
		animations:^{
		  target.frame = newFrame;
		}
		completion:^(BOOL finished) {
		  CGRect originFrame = target.frame;
		  originFrame.origin.y = original_y;
		  target.hidden = YES;
		  target.frame = originFrame;
		  if (completion)
			  completion(finished);
		}];
	} else {
		CGRect frame = target.frame;
		int original_y = frame.origin.y;
		frame.origin.y = self.view.frame.size.height;
		target.frame = frame;
		frame.origin.y = original_y;
		target.hidden = NO;

		[UIView animateWithDuration:0.5
			delay:0.0
			options:UIViewAnimationOptionCurveEaseOut
			animations:^{
			  target.frame = frame;
			}
			completion:^(BOOL finished) {
			  target.frame = frame; // in case application did not finish
			  if (completion)
				  completion(finished);
			}];
	}
}

//////////////////////////////////////////////// 自已添加的新方法,
// 挂断电话
- (void)terminalCall {
    LinphoneCall *currentcall = linphone_core_get_current_call(LC);
    if (linphone_core_is_in_conference(LC) || (linphone_core_get_conference_size(LC) > 0) ) { // Only one conf
        linphone_core_terminate_conference(LC);
    } else if (currentcall != NULL) { // In a call
        linphone_core_terminate_call(LC, currentcall);
    } else {
        const MSList *calls = linphone_core_get_calls(LC);
        if (ms_list_size(calls) == 1) { // Only one call
            linphone_core_terminate_call(LC, (LinphoneCall *)(calls->data));
        }
    }
}

- (void)hideAllBottomBgView {
//    if (self.popControlView.hidden == NO) {
//        // 隐藏它
//        self.popControlView.alpha = 1.0;
//        [UIView animateWithDuration:0.3 animations:^{
//            self.popControlView.alpha = 0.0;
//        } completion:^(BOOL finished) {
//            NSMutableArray *subs = [NSMutableArray array];
//            for (UIView *subV in self.popControlView.subviews) {
//                if (subV.tag != 1000) {
//                    [subs addObject:subV];
//                }
//            }
//            
//            for (UIView *eachSub in subs) {
//                [eachSub removeFromSuperview];
//            }
//            
//            self.popControlView.hidden = YES;
//        }];
//    }
}

// 打开视频镜头
- (void)openCamera:(UIButton *)sender {
    [self hideAllBottomBgView];
    
    // 下面这行代码是从老的地方来的，不确定是否一定需要调用
    if (!linphone_core_video_enabled(LC)) {
        linphone_core_enable_video_capture(LC, true);
        linphone_core_enable_video_display(LC, true);
    }
    
    LinphoneCall *call = linphone_core_get_current_call(LC);
    if (call) {
        LinphoneCallAppData *callAppData = (__bridge LinphoneCallAppData *)linphone_call_get_user_pointer(call);
        callAppData->videoRequested =
        TRUE; /* will be used later to notify user if video was not activated because of the linphone core*/
        LinphoneCallParams *call_params = linphone_call_params_copy(linphone_call_get_current_params(call));
        linphone_call_params_enable_video(call_params, TRUE);
        linphone_core_update_call(LC, call, call_params);
        linphone_call_params_destroy(call_params);
    } else {
        LOGW(@"Cannot toggle video button, because no current call");
    }
    
    // TODO 这里可以先让一个屏幕提示界面正在等待
    // 然后可以执行一个定时器，0.3秒后，把正在等待界面隐藏掉
}

// 关闭摄像头
- (void)closeCamera:(UIButton *)sender {
    [self hideAllBottomBgView];
    
    if (!linphone_core_video_display_enabled(LC))
        return;
    
    if (!linphone_core_video_enabled(LC))
        return;
    
    LinphoneCall *call = linphone_core_get_current_call(LC);
    if (call) {
        LinphoneCallParams *call_params = linphone_call_params_copy(linphone_call_get_current_params(call));
        linphone_call_params_enable_video(call_params, FALSE);
        linphone_core_update_call(LC, call, call_params);
        linphone_call_params_destroy(call_params);
    } else {
        LOGW(@"Cannot toggle video button, because no current call");
    }
}

// 点击切换前后摄像头
- (void)bmChangeFrontAndTail:(UIButton *)sender {
    [self hideAllBottomBgView];
    
    const char *currentCamId = (char *)linphone_core_get_video_device(LC);
    const char **cameras = linphone_core_get_video_devices(LC);
    const char *newCamId = NULL;
    int i;
    
    for (i = 0; cameras[i] != NULL; ++i) {
        if (strcmp(cameras[i], "StaticImage: Static picture") == 0)
            continue;
        if (strcmp(cameras[i], currentCamId) != 0) {
            newCamId = cameras[i];
            break;
        }
    }
    if (newCamId) {
        LOGI(@"Switching from [%s] to [%s]", currentCamId, newCamId);
        linphone_core_set_video_device(LC, newCamId);
        LinphoneCall *call = linphone_core_get_current_call(LC);
        if (call != NULL) {
            linphone_core_update_call(LC, call, NULL);
        }
    }
}

// 麦克风按钮点击
- (IBAction)bottomMicBtnClicked:(id)sender {
//
//    [self hideAllBottomBgView];
//    
//    // 然后执行不同的操作
//    if (linphone_core_mic_enabled([LinphoneManager getLc]) == YES) {
//        // 当前静音，点击后，则取消静音
//        linphone_core_enable_mic([LinphoneManager getLc], false);
//        
//        [self.bmMicroButton setImage:[UIImage imageNamed:@"m_mic_enable"] forState:UIControlStateNormal];
//        [self.bmMicroButton setImage:[UIImage imageNamed:@"m_mic_disable"] forState:UIControlStateDisabled];
//    }else {
//        // 当前没有静音， 点击后，则进行静音
//        linphone_core_enable_mic([LinphoneManager getLc], true);
//        
//        [self.bmMicroButton setImage:[UIImage imageNamed:@"m_mic_disable"] forState:UIControlStateNormal];
//        [self.bmMicroButton setImage:[UIImage imageNamed:@"m_mic_enable"] forState:UIControlStateDisabled];
//    }
}

// 底部视频按钮
- (IBAction)bottomVedioBtnClicked:(id)sender {
    [self hideAllBottomBgView];
    
//    // 点击都弹出选择界面
//    UIButton *frontTailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    frontTailBtn.showsTouchWhenHighlighted = YES;
//    [frontTailBtn addTarget:self action:@selector(bmChangeFrontAndTail:) forControlEvents:UIControlEventTouchUpInside];
//    [frontTailBtn setTitle:@"前置/后置摄像头" forState:UIControlStateNormal];
//    
//    UIButton *closeCameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    closeCameraBtn.showsTouchWhenHighlighted = YES;
//    [closeCameraBtn addTarget:self action:@selector(closeCamera:) forControlEvents:UIControlEventTouchUpInside];
//    [closeCameraBtn setTitle:@"关闭摄像头" forState:UIControlStateNormal];
//    
//    UIButton *openCameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    openCameraBtn.showsTouchWhenHighlighted = YES;
//    [openCameraBtn addTarget:self action:@selector(openCamera:) forControlEvents:UIControlEventTouchUpInside];
//    [openCameraBtn setTitle:@"打开摄像头" forState:UIControlStateNormal];
//    
//    LinphoneCall* currentCall = linphone_core_get_current_call([LinphoneManager getLc]);
//    bool video_enabled = linphone_call_params_video_enabled(linphone_call_get_current_params(currentCall));
//    
//    //    if( linphone_core_video_enabled([LinphoneManager getLc])
//    //       && currentCall
//    //       && !linphone_call_media_in_progress(currentCall)
//    //       && linphone_call_get_state(currentCall) == LinphoneCallStreamsRunning) {
//    //        video_enabled = TRUE;
//    //    }
//    
//    if (video_enabled == YES) {
//        // 当前在会议中
//        [self popWithButtons:@[frontTailBtn, closeCameraBtn]];
//    }else {
//        // 当前不在会议中
//        [self popWithButtons:@[frontTailBtn, openCameraBtn]];
//    }
}


// 底部邀请按钮
- (IBAction)bottomInviteBtnClicked:(id)sender {
//    UIButton *mailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    mailBtn.showsTouchWhenHighlighted = YES;
//    [mailBtn addTarget:self action:@selector(sendMailBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [mailBtn setTitle:@"发邮件" forState:UIControlStateNormal];
//    
//    UIButton *smsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    smsBtn.showsTouchWhenHighlighted = YES;
//    [smsBtn addTarget:self action:@selector(sendSMSBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [smsBtn setTitle:@"发短信" forState:UIControlStateNormal];
//    
//    UIButton *callPhoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    callPhoneBtn.showsTouchWhenHighlighted = YES;
//    [callPhoneBtn addTarget:self action:@selector(callBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [callPhoneBtn setTitle:@"呼号" forState:UIControlStateNormal];
//    
//    UIButton *copyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    copyBtn.showsTouchWhenHighlighted = YES;
//    [copyBtn addTarget:self action:@selector(copyAddressBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [copyBtn setTitle:@"复制地址" forState:UIControlStateNormal];
//    
//    [self popWithButtons:@[mailBtn, smsBtn, callPhoneBtn, copyBtn]];
}

// 底部参与人按钮
- (IBAction)bottomJoinerBtnClicked:(id)sender {
    [self hideAllBottomBgView];
    
//    [RDRAllJoinersView showTableTitle:@"全部参与人员" withPostBlock:^(NSString *text) {
//        [self showToastWithMessage:text];
//    }];
}

// 底部更多按钮
- (IBAction)bottomMoreBtnClicked:(id)sender {
//    UIButton *lockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    lockBtn.showsTouchWhenHighlighted = YES;
//    [lockBtn addTarget:self action:@selector(lockMeetingBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [lockBtn setTitle:@"锁定会议室" forState:UIControlStateNormal];
//    
//    UIButton *unlockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    unlockBtn.showsTouchWhenHighlighted = YES;
//    [unlockBtn addTarget:self action:@selector(unlockMeetingBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [unlockBtn setTitle:@"解锁会议室" forState:UIControlStateNormal];
//    
//    UIButton *startRecordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    startRecordBtn.showsTouchWhenHighlighted = YES;
//    [startRecordBtn addTarget:self action:@selector(startRecordClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [startRecordBtn setTitle:@"录播" forState:UIControlStateNormal];
//    
//    UIButton *stopRecordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    stopRecordBtn.showsTouchWhenHighlighted = YES;
//    [stopRecordBtn addTarget:self action:@selector(stopRecordClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [stopRecordBtn setTitle:@"停止录播" forState:UIControlStateNormal];
//    
//    UIButton *layoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    layoutBtn.showsTouchWhenHighlighted = YES;
//    [layoutBtn addTarget:self action:@selector(meetingLayoutBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [layoutBtn setTitle:@"布局设置" forState:UIControlStateNormal];
//    
//    UIButton *endBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    endBtn.showsTouchWhenHighlighted = YES;
//    [endBtn addTarget:self action:@selector(endMeetingBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [endBtn setTitle:@"结束会议" forState:UIControlStateNormal];
//    
//    // 判断当前会议的状态， 是被锁定还是怎么的
//    if (self.meetingLockedStatus == YES) {     // 当前是锁定状态
//        if (self.meetingIsRecording == YES) {       // 正在录制
//            [self popWithButtons:@[layoutBtn, unlockBtn, stopRecordBtn, endBtn]];
//        }else {                                     // 没有录制
//            [self popWithButtons:@[layoutBtn, unlockBtn, startRecordBtn, endBtn]];
//        }
//    }else {
//        if (self.meetingIsRecording == YES) {       // 正在录制
//            [self popWithButtons:@[layoutBtn, lockBtn, stopRecordBtn, endBtn]];
//        }else {                                     // 没有录制
//            [self popWithButtons:@[layoutBtn, lockBtn, startRecordBtn, endBtn]];
//        }
//    }
}

- (IBAction)quitCallBtnClicked:(id)sender {

}

@end
