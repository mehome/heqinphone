//
//  RDRContactModel.m
//  linphone
//
//  Created by baidu on 15/12/4.
//
//

#import "RDRContactModel.h"
#import "NSDictionary+MTLMappingAdditions.h"

@implementation RDRContactModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    NSMutableDictionary *mutDic = [[NSDictionary mtl_identityPropertyMapWithModel:[self class]] mutableCopy];
    
    return mutDic;
}

@end
