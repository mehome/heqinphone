//
//  RDROperationGetJoinersRequestModel.h
//  linphone
//
//  Created by baidu on 15/12/20.
//
//

#import "RDRBaseRequestModel.h"

@interface RDROperationGetJoinersRequestModel : RDRBaseRequestModel

@property (nonatomic, copy) NSString *addr;     // 与会地址

@end
