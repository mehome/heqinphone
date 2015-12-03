//
//  LPUser.h
//  linphone
//
//  Created by heqin on 15/11/7.
//
//

#import <Foundation/Foundation.h>

@interface LPSystemUser : NSObject

@property (nonatomic, assign) BOOL hasLogin;
@property (nonatomic, copy) NSString *loginUserName;            // 登录后服务器返回的名字
@property (nonatomic, copy) NSString *loginUserId;              // 登录时使用的用户id
@property (nonatomic, copy) NSString *loginUserPassword;        // 登录使用的密码

@property (nonatomic, assign) BOOL hasGetMeetingData;               // 是否获取到会议数据
@property (nonatomic, strong) NSArray *myScheduleMeetings;          // 我的会议-> 会议安排
@property (nonatomic, strong) NSArray *myMeetingsRooms;             // 我的会议-> 我的会议室
@property (nonatomic, strong) NSArray *myFavMeetings;               // 我的会议-> 我的收藏会议室
@property (nonatomic, strong) NSArray *myHistoryMeetings;           // 我的会议-> 我的历史会议室

+ (instancetype)sharedUser;

@end
