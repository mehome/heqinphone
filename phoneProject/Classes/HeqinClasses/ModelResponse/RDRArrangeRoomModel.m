//
//  RDRArrangeRoomModel.m
//  linphone
//
//  Created by baidu on 15/12/4.
//
//

#import "RDRArrangeRoomModel.h"
#import "NSDictionary+MTLMappingAdditions.h"

@implementation RDRArrangeRoomModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    NSMutableDictionary *mutDic = [[NSDictionary mtl_identityPropertyMapWithModel:[self class]] mutableCopy];
    
    [mutDic setObject:@"id" forKey:@"idNum"];
    
    return mutDic;
}

@end
