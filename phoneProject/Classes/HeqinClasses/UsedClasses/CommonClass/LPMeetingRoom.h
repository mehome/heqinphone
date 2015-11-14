//
//  LPMeetingRoom.h
//  linphone
//
//  Created by heqin on 15/11/7.
//
//

#import <Foundation/Foundation.h>

@interface LPMeetingRoom : NSObject

@property (nonatomic, copy) NSString *meetingName;
@property (nonatomic, copy) NSString *meetingId;
@property (nonatomic, strong) NSDate *meetingCallTime;      // 历史会议的时间

@end
