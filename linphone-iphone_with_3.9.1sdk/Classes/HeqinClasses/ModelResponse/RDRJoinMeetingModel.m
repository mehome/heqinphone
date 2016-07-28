//
//  RDRJoinMeetingModel.m
//  linphone
//
//  Created by baidu on 15/11/12.
//
//

#import "RDRJoinMeetingModel.h"
#import "NSDictionary+MTLMappingAdditions.h"

@implementation RDRJoinMeetingModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    NSMutableDictionary *mutDic = [[NSDictionary mtl_identityPropertyMapWithModel:[self class]] mutableCopy];
    
    [mutDic setObject:@"id" forKey:@"idNum"];
    
    return mutDic;
}

@end
