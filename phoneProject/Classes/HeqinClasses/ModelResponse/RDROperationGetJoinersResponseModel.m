//
//  RDROperationGetJoinersResponseModel.m
//  linphone
//
//  Created by baidu on 15/12/20.
//
//

#import "RDROperationGetJoinersResponseModel.h"
#import "RDROperationJoinerModel.h"

@implementation RDROperationGetJoinersResponseModel


+ (NSDictionary *)JSONKeyPathsByPropertyKey {    
    NSMutableDictionary *mutDic = [[NSDictionary mtl_identityPropertyMapWithModel:[self class]] mutableCopy];
    
    return mutDic;
}

+ (NSValueTransformer *)dataJSONTransformer{
    return [MTLJSONAdapter arrayTransformerWithModelClass:[RDROperationJoinerModel class]];
}

@end
