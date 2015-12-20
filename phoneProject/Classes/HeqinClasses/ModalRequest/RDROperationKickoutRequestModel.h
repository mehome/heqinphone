//
//  RDROperationKickoutRequestModel.h
//  linphone
//
//  Created by baidu on 15/12/20.
//
//

#import "RDRBaseRequestModel.h"

@interface RDROperationKickoutRequestModel : RDRBaseRequestModel

@property (nonatomic, copy) NSString *pin;
@property (nonatomic, copy) NSString *uid;      // 被踢者
@property (nonatomic, copy) NSString *addr;     // 与会地址

@end
