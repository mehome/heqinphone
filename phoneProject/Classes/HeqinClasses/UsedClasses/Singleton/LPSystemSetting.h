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

@property (nonatomic, copy) NSString *sipDomainStr;                 // 记录上次使用的domain值，该值目前直接强制设定成120.132.87.181

@property (nonatomic, copy) NSString *joinerName;               // 参会名称，是用户可以直接进行设置的

@property (nonatomic, strong) NSMutableArray *historyMeetings;     // 历史会议

@property (nonatomic, strong, readonly) NSDateFormatter *unifyDateformatter;      // 统一使用的日期格式

+ (instancetype)sharedSetting;
- (void)saveSystem;

@end


