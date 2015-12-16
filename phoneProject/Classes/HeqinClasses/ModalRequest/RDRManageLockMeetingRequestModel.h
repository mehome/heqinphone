//
//  RDRManageLockMeetingRequestModel.h
//  linphone
//
//  Created by baidu on 15/12/16.
//
//

#import "RDRBaseRequestModel.h"

@interface RDRManageLockMeetingRequestModel : RDRBaseRequestModel

@property (nonatomic, copy) NSString *lockStr;          // 锁定状态
@property (nonatomic, copy) NSString *meetingAddr;      // 会议室地址
@property (nonatomic, copy) NSString *meetingPin;       // 会议室管理密码

@end
