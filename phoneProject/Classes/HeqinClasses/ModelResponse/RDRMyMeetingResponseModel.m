//
//  RDRMyMeetingResponseModel.m
//  linphone
//
//  Created by baidu on 15/11/12.
//
//

#import "RDRMyMeetingResponseModel.h"
#import "RDRJoinMeetingModel.h"

@implementation RDRMyMeetingResponseModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    
    NSMutableDictionary *mutDic = [[NSDictionary mtl_identityPropertyMapWithModel:[self class]] mutableCopy];
    
    return mutDic;
}

+ (NSValueTransformer *)roomsJSONTransformer{
    return [MTLJSONAdapter arrayTransformerWithModelClass:[RDRJoinMeetingModel class]];
}

@end
