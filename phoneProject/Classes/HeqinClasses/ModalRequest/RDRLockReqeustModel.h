//
//  RDRLockReqeustModel.h
//  linphone
//
//  Created by baidu on 15/12/19.
//
//

#import "RDRBaseRequestModel.h"

@interface RDRLockReqeustModel : RDRBaseRequestModel

@property (nonatomic, copy) NSString *addr;
@property (nonatomic, strong) NSNumber *lock;
@property (nonatomic, copy) NSString *pin;

@end
