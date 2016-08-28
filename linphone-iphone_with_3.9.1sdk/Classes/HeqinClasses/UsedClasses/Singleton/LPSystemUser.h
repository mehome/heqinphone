//
//  LPUser.h
//  linphone
//
//  Created by heqin on 15/11/7.
//
//

#import <Foundation/Foundation.h>
#import "LinphoneCoreSettingsStore.h"

typedef void(^BlockRequestFavMeetings)(BOOL success,NSArray *sheduleMeetings, NSArray *rooms, NSArray *favMeetings, NSString *tipStr);

@interface LPSystemUser : NSObject

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

@property (nonatomic, strong) NSString *curMeetingAddr;         // 存储当前会议的地址，用来在会议中执行收藏操作

@property (nonatomic, strong) LinphoneCoreSettingsStore *settingsStore;     // 用来存取帐号信息

@property (nonatomic, assign) BOOL hasLoginSuccess;         // 用来记录登录状态，默认为NO

+ (instancetype)sharedUser;

+ (void)requesteFav:(BlockRequestFavMeetings)finishBlock;

+ (void)resetToAnonimousLogin;      // 置成匿名登录

// 抽离出纯的呼叫地址， 如地址为：feng.wang@zijingcloud.com， 抽出来后，为feng.wang
+ (NSString *)takePureAddrFrom:(NSString *)address;

- (NSDictionary *) tryToLoginWithUserName:(NSString*)username userId:(NSString *)userIdStr password:(NSString*)password displayName:(NSString *)displayName domain:(NSString *)domainStr;

@end
