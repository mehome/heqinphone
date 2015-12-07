//
//  LPUser.h
//  linphone
//
//  Created by heqin on 15/11/7.
//
//

#import <Foundation/Foundation.h>

typedef void(^BlockRequestFavMeetings)(BOOL success,NSArray *sheduleMeetings, NSArray *rooms, NSArray *favMeetings, NSString *tipStr);

@interface LPSystemUser : NSObject

@property (nonatomic, assign) BOOL hasLogin;
@property (nonatomic, copy) NSString *loginUserName;            // 登录后服务器返回的名字
@property (nonatomic, copy) NSString *loginUserId;              // 登录时使用的用户id
@property (nonatomic, copy) NSString *loginUserPassword;        // 登录使用的密码

// 会议
@property (nonatomic, assign) BOOL hasGetMeetingData;               // 是否获取到会议数据
@property (nonatomic, strong) NSArray *myScheduleMeetings;          // 我的会议-> 会议安排
@property (nonatomic, strong) NSArray *myMeetingsRooms;             // 我的会议-> 我的会议室
@property (nonatomic, strong) NSArray *myFavMeetings;               // 我的会议-> 我的收藏会议室

// 当前用户的通讯录
@property (nonatomic, assign) BOOL hasGetContacts;                  // 是否获取到通讯录及设备列表
@property (nonatomic, strong) NSArray *contactsList;                // 通讯录中的联系人
@property (nonatomic, strong) NSArray *devicesList;                 // 当前用户的设备列表

// 当前用户收藏的会议室列表
@property (nonatomic, assign) BOOL hasGetFavMeetingRooms;           // 是否获取到收藏的会议室列表
@property (nonatomic, strong) NSArray *favMeetingRoomsList;         // 收藏的会议室列表

@property (nonatomic, strong) NSMutableArray *callLogs;             // 呼号历史，用来做为历史通话

+ (instancetype)sharedUser;


+ (void)requesteFav:(BlockRequestFavMeetings)finishBlock;

@end
