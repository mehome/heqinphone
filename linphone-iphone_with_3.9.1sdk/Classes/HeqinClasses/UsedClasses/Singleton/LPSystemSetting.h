//
//  LPSystemSetting.h
//  linphone
//
//  Created by heqin on 15/11/7.
//
//

#import <Foundation/Foundation.h>
#import "LPMeetingRoom.h"


@interface LPSystemSetting : NSObject

@property (nonatomic, copy, readonly) NSString *sipDomainStr; // 写死的zijingcloud.com

@property (nonatomic, copy) NSString *sipTmpProxy;// 来自于服务器的返回值，应该为sip.myvmr.cn, 不一定会有80端口，可以看根据需要来添加80端口

@property (nonatomic, copy) NSString *joinerName;               // 参会者名称，是用户可以直接进行设置的

@property (nonatomic, strong) NSMutableArray *historyMeetings;     // 历史会议

@property (nonatomic, strong, readonly) NSDateFormatter *unifyDateformatter;      // 统一使用的日期格式

@property (nonatomic, assign) BOOL defaultSilence;          // 缺省静音
@property (nonatomic, assign) BOOL defaultNoVideo;          // 缺省静画

+ (instancetype)sharedSetting;
- (void)saveSystem;

@end


