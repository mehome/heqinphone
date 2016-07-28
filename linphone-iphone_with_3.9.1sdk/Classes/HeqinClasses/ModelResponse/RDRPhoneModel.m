//
//  RDRPhoneModel.m
//  linphone
//
//  Created by baidu on 16/1/7.
//
//

#import "RDRPhoneModel.h"
#import "NSDictionary+MTLMappingAdditions.h"

@implementation RDRPhoneModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    NSMutableDictionary *mutDic = [[NSDictionary mtl_identityPropertyMapWithModel:[self class]] mutableCopy];
    
    return mutDic;
}

@end
