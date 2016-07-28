//
//  ShowMeetingLayoutView.h
//  linphone
//
//  Created by baidu on 16/6/6.
//
//

#import <UIKit/UIKit.h>
#import "UICallBar.h"

typedef void(^meetingLayoutOkBlock)(NSDictionary *settingDic);
typedef void(^meetingLayoutCancelBlock)();

@interface ShowMeetingLayoutView : UIView

+ (ShowMeetingLayoutView *)showLayoutType:(MeetingType)type withDoneBlock:(meetingLayoutOkBlock)doneBlock withCancelBlock:(meetingLayoutCancelBlock)cancelBlock;

@end
