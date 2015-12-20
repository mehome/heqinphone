//
//  RDRAddFavRequestModel.h
//  linphone
//
//  Created by baidu on 15/12/19.
//
//

#import "RDRBaseRequestModel.h"

@interface RDRAddFavRequestModel : RDRBaseRequestModel

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *addr;

@end
