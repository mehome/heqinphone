//
//  RDRManageSettingMeetingRequestModel.h
//  linphone
//
//  Created by baidu on 15/12/16.
//
//

#import "RDRBaseRequestModel.h"

@interface RDRManageSettingMeetingRequestModel : RDRBaseRequestModel

@property (nonatomic, copy) NSString *pin;          // pin码
@property (nonatomic, copy) NSString *guestpin;
@property (nonatomic, copy) NSString *addr;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *pwd;

@end
