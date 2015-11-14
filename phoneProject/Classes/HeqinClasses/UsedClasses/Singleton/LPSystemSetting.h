//
//  LPSystemSetting.h
//  linphone
//
//  Created by heqin on 15/11/7.
//
//

#import <Foundation/Foundation.h>

@interface LPSystemSetting : NSObject

@property (nonatomic, copy) NSString *sipDomainStr;

@property (nonatomic, strong) NSArray *historyMeetings;     // 历史会议



+ (instancetype)sharedSetting;
- (void)saveSystem;

@end
