//
//  RDROperationJoinerModel.m
//  linphone
//
//  Created by baidu on 15/12/20.
//
//

#import "RDROperationJoinerModel.h"
#import "NSDictionary+MTLMappingAdditions.h"

@implementation RDROperationJoinerModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    NSMutableDictionary *mutDic = [[NSDictionary mtl_identityPropertyMapWithModel:[self class]] mutableCopy];
    
    return mutDic;
}

@end
