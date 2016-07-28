//
//  RDRInviteRequestModel.h
//  linphone
//
//  Created by baidu on 15/12/19.
//
//

#import "RDRBaseRequestModel.h"

@interface RDRInviteRequestModel : RDRBaseRequestModel

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *addr;
@property (nonatomic, strong) NSNumber *type;
@property (nonatomic, copy) NSString *to;

@end
