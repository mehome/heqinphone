//
//  RDRDeviceModel.m
//  linphone
//
//  Created by baidu on 15/12/4.
//
//

#import "RDRDeviceModel.h"
#import "NSDictionary+MTLMappingAdditions.h"

@implementation RDRDeviceModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    NSMutableDictionary *mutDic = [[NSDictionary mtl_identityPropertyMapWithModel:[self class]] mutableCopy];
    
    return mutDic;
}

@end
