//
//  RDRJoinMeetingModel.h
//  linphone
//
//  Created by baidu on 15/11/12.
//
//

#import "MTLModel.h"
#import "MTLJSONAdapter.h"

@interface RDRJoinMeetingModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSNumber *idNum;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *addr;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *desc;

@end
