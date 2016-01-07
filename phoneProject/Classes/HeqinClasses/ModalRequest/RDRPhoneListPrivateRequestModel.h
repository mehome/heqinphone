//
//  RDRPhoneListPrivateRequestModel.h
//  linphone
//
//  Created by baidu on 16/1/7.
//
//

#import "RDRBaseRequestModel.h"

@interface RDRPhoneListPrivateRequestModel : RDRBaseRequestModel

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, assign) NSInteger page;

@end
