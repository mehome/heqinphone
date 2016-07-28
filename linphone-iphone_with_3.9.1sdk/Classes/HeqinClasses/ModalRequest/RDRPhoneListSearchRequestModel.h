//
//  RDRPhoneListSearchRequestModel.h
//  linphone
//
//  Created by baidu on 16/1/7.
//
//

#import "RDRBaseRequestModel.h"

@interface RDRPhoneListSearchRequestModel : RDRBaseRequestModel

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *name;

@end
