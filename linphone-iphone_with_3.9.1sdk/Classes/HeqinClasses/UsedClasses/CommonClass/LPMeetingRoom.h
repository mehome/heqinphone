//
//  LPMeetingRoom.h
//  linphone
//
//  Created by heqin on 15/11/7.
//
//

#import <Foundation/Foundation.h>

////////////////////单个会议数据/////////////////////
@interface LPMeetingRoom : NSObject <NSCoding>

@property (nonatomic, copy) NSString *meetingIdStr;         // 会议id
@property (nonatomic, copy) NSString *meetingName;          // 会议名称，销售1部
@property (nonatomic, copy) NSString *meetingInLastDateStr;       // 上次会议时间

@end
