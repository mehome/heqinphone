//
//  LPPhoneListView.h
//  linphone
//
//  Created by baidu on 16/1/6.
//
//

#import <UIKit/UIKit.h>

#define kSearchNumbersDatasForJoineMeeting @"kSearchNumbersJoinMeetingDatas"
#define kSearchNumbersDatasForArrangeMeeting @"kSearchNumbersArrangeMeetingDatas"



@interface LPPhoneListView : UIView

@property (nonatomic, assign) NSInteger forJoinMeeting;

- (void)setForJoinMeeting:(NSInteger)type;         // 1:用于加入会议界面, 0:用于安排会议界面

@end
