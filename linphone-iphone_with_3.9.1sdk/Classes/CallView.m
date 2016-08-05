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
#import "LPSystemUser.h"
#import "LPSystemSetting.h"

#import "UIViewController+RDRTipAndAlert.h"

#import "UICallBar.h"
#import "ShowInviteView.h"
#import "RDRAllJoinersView.h"
#import "ShowMeetingLayoutView.h"
#import "RDRMeetingTypeRequestModel.h"

#import "RDRInviteRequestModel.h"
#import "RDRInviteResponseModel.h"

#import "RDRLockReqeustModel.h"
#import "RDRLockResponseModel.h"

#import "RDRReocrdRequestModel.h"
#import "RDRRecordResponseModel.h"

#import "RDRMeetingLayoutRequestModel.h"
#import "RDRMeetingLayoutSubRequestModel.h"
#import "RDRMeetingTypeResponseModel.h"

#import "RDRTerminalRequestModel.h"
#import "RDRTerminalResponseModel.h"

@interface CallView ()

@property (nonatomic, strong) UIView *popControlView;       // 弹出的按钮控件的背景

@property (nonatomic, assign) BOOL meetingLockedStatus;     // 会议被锁定?，默认为No
@property (nonatomic, assign) BOOL meetingIsRecording;      // 会议是否正在录制，默认NO

@property (nonatomic, assign) MeetingType curMeetingType;

@end

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
                                                   supportLandscapeMode:NO];
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

    [self setAllBtns];
    
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

- (void)dataFillToPreview {
    // 执行请求会议室类型的请求
    [self requestMeetingType];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	LinphoneManager.instance.nextCallIsTransfer = NO;

	// Update on show
	[self hidePad:TRUE animated:FALSE];
	[self onCurrentCallChange];
	// Set windows (warn memory leaks)
	linphone_core_set_native_video_window_id(LC, (__bridge void *)(_videoView));
	linphone_core_set_native_preview_window_id(LC, (__bridge void *)(_videoPreview));

	[self previewTouchLift];

    // 填充参数，并请求查询当前会议类型
    [self dataFillToPreview];
    
	// Enable tap
	[singleFingerTap setEnabled:TRUE];

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
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	[self previewTouchLift];
	[self hideStatusBar:!videoHidden];
}

- (UIView *)popControlView {
    if (_popControlView == nil) {
        _popControlView = [[UIView alloc] initWithFrame:CGRectZero];
        _popControlView.backgroundColor = [UIColor clearColor];
        
        UIView *littleBgView = [[UIView alloc] initWithFrame:CGRectZero];
        littleBgView.backgroundColor = [UIColor grayColor];
        littleBgView.alpha = 0.3;
        [_popControlView addSubview:littleBgView];
        littleBgView.tag = 1000;
        
        [self.view addSubview:_popControlView];
        _popControlView.hidden = YES;
    }
    
    return _popControlView;
}

- (void)popWithButtons:(NSArray *)btns {
    if (self.numpadView.hidden == NO) {
        self.numpadView.hidden = YES;
    }
    
    // 先重置位置
    self.popControlView.frame = self.bottomBar.frame;
    UIView *theBgView = [self.popControlView viewWithTag:1000];
    theBgView.frame = self.popControlView.bounds;
    
    self.popControlView.ott_bottom = self.bottomBar.ott_top;
    
    self.popControlView.hidden = NO;
    self.popControlView.alpha = 1.0;
    
    // 移除上面的按钮
    for (UIView *subView in self.popControlView.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            [subView removeFromSuperview];
        }
    }
    
    // 添加按钮
    for (NSInteger i=0; i<btns.count; i++) {
        UIButton *btn = btns[i];
        [self.popControlView addSubview:btn];
        CGFloat eachBtnWidth = self.popControlView.ott_width/btns.count;
        btn.frame = CGRectMake(i*eachBtnWidth, 0, eachBtnWidth, self.popControlView.ott_height);
    }
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
//	[self hideControls:!controlsHidden sender:sender];
    
    [UIView animateWithDuration:.35 animations:^{
        if (controlsHidden == YES) {
            // 之前是隐藏的，现在展示出来
            _bottomBar.alpha = 1.0;
            
            self.numpadButton.hidden = NO;
            self.quitCallBtn.hidden = NO;
        }else {
            // 之前是显示出来的，现在隐藏住
            _bottomBar.alpha = 0.0;
            self.numpadButton.hidden = YES;
            self.quitCallBtn.hidden = YES;
        }
        
        // 不管如何，点击后均会隐藏底部的弹出的菜单项
        [self hideAllBottomBgView];
        
        // 不管如何，点击后，均会隐藏弹出的数字键盘，数字键盘仅被9键按钮点出来
        self.numpadView.hidden = YES;
    }];
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

//	[self hideControls:!disabled sender:nil];

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

#pragma mark - Event Functions

static BOOL systemOpenCamera = NO;

- (void)checkIsNeedToOpenCamera {
    if (systemOpenCamera == NO) {
        LinphoneCall* currentCall = linphone_core_get_current_call(LC);
        
        if( linphone_core_video_enabled(LC)
           && currentCall
           && !linphone_call_media_in_progress(currentCall)
           && linphone_call_get_state(currentCall) == LinphoneCallStreamsRunning) {
            
            systemOpenCamera = YES;
            
            // 打开摄像头
            NSLog(@"____________________start camera");
            [self openCamera:nil];
        }
    }
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
    
    [self checkIsNeedToOpenCamera];

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
            [self configTheSilenceOperation];
            
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
                
                // 直接打开视频， 这里最新的代码是弹出倒计时提示询问用户是否允许打开视频，下面为了简化，直接打开视频处理
                [self openCamera:nil];
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
            break;
        case LinphoneCallOutgoingRinging:
            [self configTheSilenceOperation];
            break;
		default:
			break;
	}
}

- (void)configTheSilenceOperation {
    // 设置当前的静音操作
    if ([LPSystemSetting sharedSetting].defaultSilence == YES) {
        // 要求静音
        linphone_core_enable_mic([LinphoneManager getLc], true);
        
        [self.bottomCallMicroButton setImage:[UIImage imageNamed:@"m_mic_disable"] forState:UIControlStateNormal];
        [self.bottomCallMicroButton setImage:[UIImage imageNamed:@"m_mic_enable"] forState:UIControlStateDisabled];
    }else {
        // 要求不静音
        linphone_core_enable_mic([LinphoneManager getLc], false);
        
        [self.bottomCallMicroButton setImage:[UIImage imageNamed:@"m_mic_enable"] forState:UIControlStateNormal];
        [self.bottomCallMicroButton setImage:[UIImage imageNamed:@"m_mic_disable"] forState:UIControlStateDisabled];
    }
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

- (void)changeBtn:(UIButton *)btn {
    btn.titleLabel.font = [UIFont systemFontOfSize:11.0];
    
    [btn.titleLabel sizeToFit];
    CGSize titleSize = btn.titleLabel.frame.size;// [btn.titleLabel.text sizeWithFont:btn.titleLabel.font];
    [btn.imageView setContentMode:UIViewContentModeCenter];
    [btn setImageEdgeInsets:UIEdgeInsetsMake(-12.0,
                                             0.0,
                                             0.0,
                                             -titleSize.width)];
    
    [btn.titleLabel setContentMode:UIViewContentModeCenter];
    [btn.titleLabel setBackgroundColor:[UIColor clearColor]];
    [btn.imageView sizeToFit];
    CGSize imgSize = btn.imageView.frame.size;
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(34.0,
                                             -imgSize.width,
                                             0.0,
                                             0.0)];
}

- (void)setAllBtns {
    [self.bottomCallMicroButton setImage:[UIImage imageNamed:@"m_mic_enable"] forState:UIControlStateNormal];
    [self.bottomCallVideoButton setImage:[UIImage imageNamed:@"m_video_enabled"] forState:UIControlStateNormal];
    [self.bottomCallInviteBtn setImage:[UIImage imageNamed:@"m_invite"] forState:UIControlStateNormal];
    [self.bottomCallJoinerBtn setImage:[UIImage imageNamed:@"m_man"] forState:UIControlStateNormal];
    [self.bottomCallMoreBtn setImage:[UIImage imageNamed:@"m_options"] forState:UIControlStateNormal];
    
    [self.bottomCallMicroButton setImage:[UIImage imageNamed:@"m_mic_disable"] forState:UIControlStateDisabled];
    [self.bottomCallVideoButton setImage:[UIImage imageNamed:@"m_video_disable"] forState:UIControlStateDisabled];
    [self.bottomCallInviteBtn setImage:[UIImage imageNamed:@"m_invite_highlight"] forState:UIControlStateHighlighted];
    [self.bottomCallJoinerBtn setImage:[UIImage imageNamed:@"m_man_highlight"] forState:UIControlStateHighlighted];
    [self.bottomCallMoreBtn setImage:[UIImage imageNamed:@"m_options_highlight"] forState:UIControlStateHighlighted];
    
    [self.bottomCallMicroButton setTitle:@"声音" forState:UIControlStateNormal];
    [self.bottomCallVideoButton setTitle:@"视频" forState:UIControlStateNormal];
    [self.bottomCallInviteBtn setTitle:@"邀请" forState:UIControlStateNormal];
    [self.bottomCallJoinerBtn setTitle:@"与会者" forState:UIControlStateNormal];
    [self.bottomCallMoreBtn setTitle:@"管理" forState:UIControlStateNormal];
    
    [self.bottomCallMicroButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.bottomCallVideoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.bottomCallInviteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.bottomCallJoinerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.bottomCallMoreBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    // 调整布局
    [self changeBtn:self.bottomCallMicroButton];
    [self changeBtn:self.bottomCallVideoButton];
    [self changeBtn:self.bottomCallInviteBtn];
    [self changeBtn:self.bottomCallJoinerBtn];
    [self changeBtn:self.bottomCallMoreBtn];
}

// 隐藏底部弹出的菜单
- (void)hideAllBottomBgView {
    if (self.popControlView.hidden == NO) {
        // 隐藏它
        self.popControlView.alpha = 1.0;
        [UIView animateWithDuration:0.3 animations:^{
            self.popControlView.alpha = 0.0;
        } completion:^(BOOL finished) {
            // 然后移除掉上面的按钮，除这个背景外的其它按钮
            NSMutableArray *subs = [NSMutableArray array];
            for (UIView *subV in self.popControlView.subviews) {
                if (subV.tag != 1000) {
                    [subs addObject:subV];
                }
            }
            
            for (UIView *eachSub in subs) {
                [eachSub removeFromSuperview];
            }
            
            self.popControlView.hidden = YES;
        }];
    }
}

// 打开视频镜头
- (void)openCamera:(UIButton *)sender {
    [self hideAllBottomBgView];
    
    // 下面这行代码是从老的地方来的，不确定是否一定需要调用，不过感觉这里就算打开了，也没有什么影响，所以这里还是保留了这部分代码
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
        linphone_core_update_call(LC, call, call_params);      //  linphone_core_accept_call_update(LC, call, call_params);
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
    [self hideAllBottomBgView];
    
    // 然后执行不同的操作
    if (linphone_core_mic_enabled([LinphoneManager getLc]) == YES) {
        // 当前静音，点击后，则取消静音
        linphone_core_enable_mic([LinphoneManager getLc], false);
        
        [self.bottomCallMicroButton setImage:[UIImage imageNamed:@"m_mic_enable"] forState:UIControlStateNormal];
        [self.bottomCallMicroButton setImage:[UIImage imageNamed:@"m_mic_disable"] forState:UIControlStateDisabled];
    }else {
        // 当前没有静音， 点击后，则进行静音
        linphone_core_enable_mic([LinphoneManager getLc], true);
        
        [self.bottomCallMicroButton setImage:[UIImage imageNamed:@"m_mic_disable"] forState:UIControlStateNormal];
        [self.bottomCallMicroButton setImage:[UIImage imageNamed:@"m_mic_enable"] forState:UIControlStateDisabled];
    }
}

// 底部视频按钮
- (IBAction)bottomVedioBtnClicked:(id)sender {
    [self hideAllBottomBgView];
    
    // 点击都弹出选择界面
    UIButton *frontTailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    frontTailBtn.showsTouchWhenHighlighted = YES;
    [frontTailBtn addTarget:self action:@selector(bmChangeFrontAndTail:) forControlEvents:UIControlEventTouchUpInside];
    [frontTailBtn setTitle:@"前置/后置摄像头" forState:UIControlStateNormal];
    
    UIButton *closeCameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeCameraBtn.showsTouchWhenHighlighted = YES;
    [closeCameraBtn addTarget:self action:@selector(closeCamera:) forControlEvents:UIControlEventTouchUpInside];
    [closeCameraBtn setTitle:@"关闭摄像头" forState:UIControlStateNormal];
    
    UIButton *openCameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    openCameraBtn.showsTouchWhenHighlighted = YES;
    [openCameraBtn addTarget:self action:@selector(openCamera:) forControlEvents:UIControlEventTouchUpInside];
    [openCameraBtn setTitle:@"打开摄像头" forState:UIControlStateNormal];
    
    LinphoneCall* currentCall = linphone_core_get_current_call([LinphoneManager getLc]);
    bool video_enabled = linphone_call_params_video_enabled(linphone_call_get_current_params(currentCall));
    
    if (video_enabled == YES) {
        // 当前在会议中
        [self popWithButtons:@[frontTailBtn, closeCameraBtn]];
    }else {
        // 当前不在会议中
        [self popWithButtons:@[frontTailBtn, openCameraBtn]];
    }
}


// 底部邀请按钮
- (IBAction)bottomInviteBtnClicked:(id)sender {
    UIButton *mailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    mailBtn.showsTouchWhenHighlighted = YES;
    [mailBtn addTarget:self action:@selector(sendMailBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [mailBtn setTitle:@"发邮件" forState:UIControlStateNormal];
    
    UIButton *smsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    smsBtn.showsTouchWhenHighlighted = YES;
    [smsBtn addTarget:self action:@selector(sendSMSBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [smsBtn setTitle:@"发短信" forState:UIControlStateNormal];
    
    UIButton *callPhoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    callPhoneBtn.showsTouchWhenHighlighted = YES;
    [callPhoneBtn addTarget:self action:@selector(sendCallBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [callPhoneBtn setTitle:@"呼号" forState:UIControlStateNormal];
    
    UIButton *copyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    copyBtn.showsTouchWhenHighlighted = YES;
    [copyBtn addTarget:self action:@selector(sendCopyAddressBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [copyBtn setTitle:@"复制地址" forState:UIControlStateNormal];
    
    [self popWithButtons:@[mailBtn, smsBtn, callPhoneBtn, copyBtn]];
}

// 发邮件
- (IBAction)sendMailBtnClicked:(id)sender {
    [self inviteMenBy:InvityTypeEmail];
    [self hideAllBottomBgView];
}
// 发短信
- (IBAction)sendSMSBtnClicked:(id)sender {
    [self inviteMenBy:InvityTypeSMS];
    [self hideAllBottomBgView];
}
// 呼号
- (IBAction)sendCallBtnClicked:(id)sender {
    [self inviteMenBy:InvityTypePhoneCall];
    [self hideAllBottomBgView];
}

// 复制地址
- (IBAction)sendCopyAddressBtnClicked:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:[self curMeetingAddr]];
    
    [self hideAllBottomBgView];
    
    [self showToastWithMessage:@"复制地址成功"];
}

// 取纯111111, 不是sip:111111@120.138.....
- (NSString *)curMeetingAddr {
    NSMutableString *addr = [NSMutableString stringWithString:[LPSystemUser sharedUser].curMeetingAddr];
    
    NSString *serverAddr = [LPSystemSetting sharedSetting].sipDomainStr;
    NSString *serverTempStr = [NSString stringWithFormat:@"@%@", serverAddr];
    
    // 移掉后部
    if ([addr replaceOccurrencesOfString:serverTempStr withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [addr length])] != 0) {
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
    
    if (addr.length == 0) {
        [self showToastWithMessage:@"会议室号码错误，请检查"];
        return @"";
    }else {
        return addr;
    }
}

- (void)inviteMenBy:(InvityType)type {
    // 弹出一个输入框
    [ShowInviteView showWithType:type withDoneBlock:^(NSString *text) {
        [self inviteByType:type withContent:text];
    } withCancelBlock:^{
        NSLog(@"cancel");
    } withNoInput:^{
        [self showToastWithMessage:@"数据为空"];
    }];
}

// 邀请
- (void)inviteByType:(InvityType)type withContent:(NSString *)content {
    
    [self showToastWithMessage:@"邀请中..."];
    
    RDRInviteRequestModel *reqModel = [RDRInviteRequestModel requestModel];
    reqModel.uid = [[LPSystemUser sharedUser].settingsStore stringForKey:@"account_userid_preference"];;
    reqModel.addr = [self curMeetingAddr];
    reqModel.type = @(type);
    reqModel.to = content;
    RDRRequest *req = [RDRRequest requestWithURLPath:nil model:reqModel];
    [RDRNetHelper GET:req responseModelClass:[RDRInviteResponseModel class]
              success:^(NSURLSessionDataTask *operation, id responseObject) {
                  RDRInviteResponseModel *model = responseObject;

                  if ([model codeCheckSuccess] == YES) {
                      [self showToastWithMessage:@"邀请成功"];
                  }else {
                      NSString *tipStr = [NSString stringWithFormat:@"邀请失败，msg=%@", model.msg];
                      [self showToastWithMessage:tipStr];
                  }

              } failure:^(NSURLSessionDataTask *operation, NSError *error) {
                  //请求出错
                  NSLog(@"邀请失败, %s, error=%@", __FUNCTION__, error);
                  NSString *tipStr = [NSString stringWithFormat:@"邀请失败，服务器错误"];
                  [self showToastWithMessage:tipStr];
              }];
}

// 底部参与人按钮
- (IBAction)bottomJoinerBtnClicked:(id)sender {
    [self hideAllBottomBgView];
    
    [RDRAllJoinersView showTableTitle:@"全部参与人员" withPostBlock:^(NSString *text) {
        [self showToastWithMessage:text];
    }];
}

// 底部更多按钮
- (IBAction)bottomMoreBtnClicked:(id)sender {
    UIButton *lockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    lockBtn.showsTouchWhenHighlighted = YES;
    [lockBtn addTarget:self action:@selector(moreLockMeetingBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [lockBtn setTitle:@"锁定会议室" forState:UIControlStateNormal];
    
    UIButton *unlockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    unlockBtn.showsTouchWhenHighlighted = YES;
    [unlockBtn addTarget:self action:@selector(moreUnlockMeetingBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [unlockBtn setTitle:@"解锁会议室" forState:UIControlStateNormal];
    
    UIButton *startRecordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    startRecordBtn.showsTouchWhenHighlighted = YES;
    [startRecordBtn addTarget:self action:@selector(moreStartRecordClicked:) forControlEvents:UIControlEventTouchUpInside];
    [startRecordBtn setTitle:@"录播" forState:UIControlStateNormal];
    
    UIButton *stopRecordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    stopRecordBtn.showsTouchWhenHighlighted = YES;
    [stopRecordBtn addTarget:self action:@selector(moreStopRecordClicked:) forControlEvents:UIControlEventTouchUpInside];
    [stopRecordBtn setTitle:@"停止录播" forState:UIControlStateNormal];
    
    UIButton *layoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    layoutBtn.showsTouchWhenHighlighted = YES;
    [layoutBtn addTarget:self action:@selector(moreLayoutBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [layoutBtn setTitle:@"布局设置" forState:UIControlStateNormal];
    
    UIButton *endBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    endBtn.showsTouchWhenHighlighted = YES;
    [endBtn addTarget:self action:@selector(moreEndMeetingBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [endBtn setTitle:@"结束会议" forState:UIControlStateNormal];
    
    // 判断当前会议的状态， 是被锁定还是怎么的
    if (self.meetingLockedStatus == YES) {     // 当前是锁定状态
        if (self.meetingIsRecording == YES) {       // 正在录制
            [self popWithButtons:@[layoutBtn, unlockBtn, stopRecordBtn, endBtn]];
        }else {                                     // 没有录制
            [self popWithButtons:@[layoutBtn, unlockBtn, startRecordBtn, endBtn]];
        }
    }else {
        if (self.meetingIsRecording == YES) {       // 正在录制
            [self popWithButtons:@[layoutBtn, lockBtn, stopRecordBtn, endBtn]];
        }else {                                     // 没有录制
            [self popWithButtons:@[layoutBtn, lockBtn, startRecordBtn, endBtn]];
        }
    }
}

// 锁定会议，或者解锁
- (IBAction)moreUnlockMeetingBtnClicked:(id)sender {
    [self hideAllBottomBgView];
    
    [ShowPinView showTitle:@"请输入PIN码以解锁会议" withDoneBlock:^(NSString *text) {
        [self doUnlockMeetingWithPin:text];
    } withCancelBlock:^{
        
    } withNoInput:^{
        [self showToastWithMessage:@"请输入PIN码"];
    }];
}

- (void)doUnlockMeetingWithPin:(NSString *)pinStr {
    [self showToastWithMessage:@"解锁中..."];
    
    RDRLockReqeustModel *reqModel = [RDRLockReqeustModel requestModel];
    reqModel.addr = [self curMeetingAddr];
    reqModel.lock = @(0);
    reqModel.pin = pinStr;
    RDRRequest *req = [RDRRequest requestWithURLPath:nil model:reqModel];
    [RDRNetHelper GET:req responseModelClass:[RDRLockResponseModel class]
              success:^(NSURLSessionDataTask *operation, id responseObject) {
                  RDRLockResponseModel *model = responseObject;

                  if ([model codeCheckSuccess] == YES) {
                      [self showToastWithMessage:@"解锁成功"];
                      self.meetingLockedStatus = NO;
                  }else {
                      NSString *tipStr = [NSString stringWithFormat:@"解锁失败，msg=%@", model.msg];
                      [self showToastWithMessage:tipStr];
                  }

              } failure:^(NSURLSessionDataTask *operation, NSError *error) {

                  //请求出错
                  NSLog(@"解锁失败, %s, error=%@", __FUNCTION__, error);
                  NSString *tipStr = [NSString stringWithFormat:@"解锁失败，服务器错误"];
                  [self showToastWithMessage:tipStr];
              }];
}

// 锁定会议，或者解锁
- (IBAction)moreLockMeetingBtnClicked:(id)sender {
    [self hideAllBottomBgView];
    
    [ShowPinView showTitle:@"请输入PIN码以锁定会议" withDoneBlock:^(NSString *text) {
        [self doLockMeetingWithPin:text];
    } withCancelBlock:^{
        
    } withNoInput:^{
        [self showToastWithMessage:@"请输入PIN码"];
    }];
}

- (void)doLockMeetingWithPin:(NSString *)pinStr {
    
    [self showToastWithMessage:@"锁定中..."];
    
    RDRLockReqeustModel *reqModel = [RDRLockReqeustModel requestModel];
    reqModel.addr = [self curMeetingAddr];
    reqModel.lock = @(1);
    reqModel.pin = pinStr;
    RDRRequest *req = [RDRRequest requestWithURLPath:nil model:reqModel];
    [RDRNetHelper GET:req responseModelClass:[RDRLockResponseModel class]
              success:^(NSURLSessionDataTask *operation, id responseObject) {

                  RDRLockResponseModel *model = responseObject;

                  if ([model codeCheckSuccess] == YES) {
                      [self showToastWithMessage:@"锁定成功"];
                      self.meetingLockedStatus = YES;
                  }else {
                      NSString *tipStr = [NSString stringWithFormat:@"锁定失败，msg=%@", model.msg];
                      [self showToastWithMessage:tipStr];
                  }
              } failure:^(NSURLSessionDataTask *operation, NSError *error) {

                  //请求出错
                  NSLog(@"锁定失败, %s, error=%@", __FUNCTION__, error);
                  NSString *tipStr = [NSString stringWithFormat:@"锁定失败，服务器错误"];
                  [self showToastWithMessage:tipStr];
              }];
}

- (void)moreStartRecordClicked:(id)sender {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"录制" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self doRecordOperation:0];
    }]];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"直播" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self doRecordOperation:1];
    }]];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"录制+直播" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self doRecordOperation:2];
    }]];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertVC animated:YES completion:nil];
    
    [self hideAllBottomBgView];
}

- (void)doRecordOperation:(NSInteger)type {
    [ShowPinView showTitle:@"请输入PIN码" withDoneBlock:^(NSString *text) {
        NSString *commandStr = nil;
        NSString *tipStr = nil;
        switch (type) {
            case 0:
                commandStr = @"record";
                tipStr = @"启动录制";
                break;
            case 1:
                commandStr = @"live";
                tipStr = @"启动直播";
                break;
            case 2:
                commandStr = @"both";
                tipStr = @"启动录制和直播";
                break;
            case 3:
                commandStr = @"stop";
                tipStr = @"停止录制或直播";
                break;
            default:
                break;
        }
        
        [self doRecordCommandWithPin:text withCommandStr:commandStr withTipStr:tipStr commandType:type];
    } withCancelBlock:^{
        
    } withNoInput:^{
        [self showToastWithMessage:@"请输入PIN码"];
    }];
    
}

- (void)moreStopRecordClicked:(id)sender {
    [self doRecordOperation:3];
}

- (void)doRecordCommandWithPin:(NSString *)pinStr withCommandStr:(NSString *)commandStr withTipStr:(NSString *)tipStr commandType:(NSInteger)type {
    [self showToastWithMessage:@"请稍等..."];
    
    RDRReocrdRequestModel *reqModel = [RDRReocrdRequestModel requestModel];
    reqModel.addr = [self curMeetingAddr];
    reqModel.action = commandStr;
    reqModel.pin = pinStr;
    RDRRequest *req = [RDRRequest requestWithURLPath:nil model:reqModel];
    [RDRNetHelper GET:req responseModelClass:[RDRRecordResponseModel class]
              success:^(NSURLSessionDataTask *operation, id responseObject) {
                  RDRRecordResponseModel *model = responseObject;

                  if ([model codeCheckSuccess] == YES) {
                      [self showToastWithMessage:[NSString stringWithFormat:@"%@成功", tipStr]];

                      switch (type) {
                          case 0:
                              self.meetingIsRecording = YES;
                              break;
                          case 1:
                              self.meetingIsRecording = YES;
                              break;
                          case 2:
                              self.meetingIsRecording = YES;
                              break;
                          case 3:
                              self.meetingIsRecording = NO;
                              break;
                          default:
                              break;
                      }
                  }else {
                      NSString *tempTipStr = [NSString stringWithFormat:@"%@失败，msg=%@", tipStr, model.msg];
                      [self showToastWithMessage:tempTipStr];
                  }

              } failure:^(NSURLSessionDataTask *operation, NSError *error) {

                  //请求出错
                  NSLog(@"失败, %s, error=%@", __FUNCTION__, error);
                  NSString *tempTipStr = [NSString stringWithFormat:@"%@失败，服务器错误", tipStr];
                  [self showToastWithMessage:tempTipStr];
              }];
}

// 会议布局
- (void)moreLayoutBtnClicked:(id)sender {
    [self hideAllBottomBgView];
    
    [ShowMeetingLayoutView showLayoutType:self.curMeetingType
                            withDoneBlock:^(NSDictionary *settingDic) {
                                
                                NSDictionary *usedDic = [NSDictionary dictionaryWithDictionary:settingDic];
                                NSLog(@"mutDic=%@ ,usedDic=%@", settingDic, usedDic);
                                
                                MeetingType usedType = self.curMeetingType;
                                
                                __block CallView *weakSelf = self;
                                
                                // 准备弹出pin界面进行输入密码
                                [ShowPinView showTitle:@"请输入PIN码修改布局" withDoneBlock:^(NSString *text) {
                                    // 根据这里的设置进行操作。
                                    NSLog(@"ping is %@, usedDIc=%@", text, usedDic);
                                    
                                    [weakSelf showToastWithMessage:@"设置布局中"];
                                    
                                    RDRRequest *req = nil;
                                    if (usedType == MeetingTypeLesson) {
                                        RDRMeetingLayoutRequestModel *reqModel = [RDRMeetingLayoutRequestModel requestModel];
                                        reqModel.addr = [self curMeetingAddr];
                                        reqModel.pin = text;
                                        reqModel.subtitle = ((NSNumber *)(usedDic[@"zimuGround"])).integerValue;
                                        reqModel.layout = ((NSNumber *)(usedDic[@"zcrGround"])).integerValue;
                                        reqModel.layout2 = ((NSNumber *)(usedDic[@"jkGround"])).integerValue;
                                        
                                        req = [RDRRequest requestWithURLPath:nil model:reqModel];
                                        
                                    }else {
                                        RDRMeetingLayoutSubRequestModel *subModel = [RDRMeetingLayoutSubRequestModel requestModel];
                                        subModel.addr = [self curMeetingAddr];
                                        subModel.pin = text;
                                        subModel.subtitle = ((NSNumber *)(usedDic[@"zimuGround"])).integerValue;
                                        subModel.layout = ((NSNumber *)(usedDic[@"zcrGround"])).integerValue;
                                        
                                        req = [RDRRequest requestWithURLPath:nil model:subModel];
                                    }
                                    
                                    //            [RDRNetHelper GET:req responseModelClass:[RDRMeetingLayoutResponseModel class]
                                    //                      success:^(NSURLSessionDataTask *operation, id responseObject) {
                                    //                          [weakSelf retain];
                                    //
                                    //                          RDRMeetingLayoutResponseModel *model = responseObject;
                                    //
                                    //                          if ([model codeCheckSuccess] == YES) {
                                    //                              [weakSelf showToastWithMessage:@"布局设置成功"];
                                    //                          }else {
                                    //                              NSString *tipStr = [NSString stringWithFormat:@"布局设置失败，msg=%@", model.msg];
                                    //                              [weakSelf showToastWithMessage:tipStr];
                                    //                          }
                                    //                          [weakSelf release];
                                    //                          
                                    //                      } failure:^(NSURLSessionDataTask *operation, NSError *error) {
                                    //                          [weakSelf retain];
                                    //                          
                                    //                          //请求出错
                                    //                          NSLog(@"布局设置失败, %s, error=%@", __FUNCTION__, error);
                                    //                          NSString *tipStr = [NSString stringWithFormat:@"布局设置失败，服务器错误"];
                                    //                          [weakSelf showToastWithMessage:tipStr];
                                    //                          [weakSelf release];
                                    //                          
                                    //                      }];
                                    
                                } withCancelBlock:^{
                                    // do nothing
                                } withNoInput:^{
                                    [self showToastWithMessage:@"请输入PIN码"];
                                }];
                                
                            } withCancelBlock:^{
                                NSLog(@"界面被取消");
                            }];
}

// 请求当前会议的类型
- (void)requestMeetingType {
    
    RDRMeetingTypeRequestModel *reqModel = [RDRMeetingTypeRequestModel requestModel];
    reqModel.addr = [self curMeetingAddr];
    
        RDRRequest *req = [RDRRequest requestWithURLPath:nil model:reqModel];
        [RDRNetHelper GET:req responseModelClass:[RDRMeetingTypeResponseModel class]
                  success:^(NSURLSessionDataTask *operation, id responseObject) {
    
                      RDRMeetingTypeResponseModel *model = responseObject;
    
                      if ([model codeCheckSuccess] == YES) {
                          NSLog(@"会议室类型查询success, model=%@", model);
    
                          if (model.type == 0) {
                              self.curMeetingType = MeetingTypeLesson;
                          }else {
                              self.curMeetingType = MeetingTypeMeeting;
                          }
                      }else {
                          NSLog(@"会议室类型查询失败, msg=%@", model.msg);
                          NSString *tipStr = [NSString stringWithFormat:@"会议室类型查询失败，msg=%@", model.msg];
                          [self showToastWithMessage:tipStr];
                      }
                  } failure:^(NSURLSessionDataTask *operation, NSError *error) {
    
                      //请求出错
                      NSLog(@"会议室类型查询失败, %s, error=%@", __FUNCTION__, error);
                      NSString *tipStr = [NSString stringWithFormat:@"会议室类型查询失败，服务器错误"];
                      [self showToastWithMessage:tipStr];
                  }];
}

// 结束会议
- (void)moreEndMeetingBtnClicked:(id)sender {
    [self hideAllBottomBgView];
    
    [ShowPinView showTitle:@"请输入PIN码以结束会议" withDoneBlock:^(NSString *text) {
        [self endMeetingByPin:text];
    } withCancelBlock:^{
        
    } withNoInput:^{
        [self showToastWithMessage:@"请输入PIN码"];
    }];
}

- (void)endMeetingByPin:(NSString *)pinStr {
    [self showToastWithMessage:@"结束会议中..."];
    
    RDRTerminalRequestModel *reqModel = [RDRTerminalRequestModel requestModel];
    reqModel.addr = [self curMeetingAddr];
    reqModel.pin = pinStr;
    RDRRequest *req = [RDRRequest requestWithURLPath:nil model:reqModel];
    [RDRNetHelper GET:req responseModelClass:[RDRTerminalResponseModel class]
              success:^(NSURLSessionDataTask *operation, id responseObject) {
                  RDRTerminalResponseModel *model = responseObject;

                  if ([model codeCheckSuccess] == YES) {
                      [self showToastWithMessage:@"结束会议成功"];
                  }else {
                      NSString *tipStr = [NSString stringWithFormat:@"结束会议失败，msg=%@", model.msg];
                      [self showToastWithMessage:tipStr];
                  }

              } failure:^(NSURLSessionDataTask *operation, NSError *error) {

                  //请求出错
                  NSLog(@"结束会议失败, %s, error=%@", __FUNCTION__, error);
                  NSString *tipStr = [NSString stringWithFormat:@"结束会议失败，服务器错误"];
                  [self showToastWithMessage:tipStr];
              }];
}

// 退出会议
- (IBAction)quitCallBtnClicked:(id)sender {
    self.meetingLockedStatus = NO;
    self.meetingIsRecording = NO;

    systemOpenCamera = NO;

    
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

@end
