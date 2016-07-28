//
//  RDRMyMeetingArrangeRoomResponseModel.m
//  linphone
//
//  Created by baidu on 15/12/4.
//
//

#import "RDRMyMeetingArrangeRoomResponseModel.h"
#import "RDRArrangeRoomModel.h"

@implementation RDRMyMeetingArrangeRoomResponseModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    
    NSMutableDictionary *mutDic = [[NSDictionary mtl_identityPropertyMapWithModel:[self class]] mutableCopy];
    
    return mutDic;
}

+ (NSValueTransformer *)favJSONTransformer{
    return [MTLJSONAdapter arrayTransformerWithModelClass:[RDRArrangeRoomModel class]];
}

@end
