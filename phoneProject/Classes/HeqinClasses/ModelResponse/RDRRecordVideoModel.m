//
//  RDRRecordVideoModel.m
//  linphone
//
//  Created by heqin on 16/5/7.
//
//

#import "RDRRecordVideoModel.h"
#import "NSDictionary+MTLMappingAdditions.h"

@implementation RDRRecordVideoModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey{
    NSMutableDictionary *mutDic = [[NSDictionary mtl_identityPropertyMapWithModel:[self class]] mutableCopy];
    
    return mutDic;
}

@end
