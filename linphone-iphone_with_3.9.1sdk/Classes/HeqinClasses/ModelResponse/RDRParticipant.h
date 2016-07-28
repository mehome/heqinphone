//
//  RDRParticipant.h
//  linphone
//
//  Created by baidu on 15/12/19.
//
//

#import "MTLModel.h"
#import "MTLJSONAdapter.h"

@interface RDRParticipant : MTLModel <MTLJSONSerializing>

@property (nonatomic,copy)NSString *uid;
@property (nonatomic,copy)NSString *name;

@end
