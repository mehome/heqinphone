//
//  RDRRecordAndPlayResponseModel.m
//  linphone
//
//  Created by heqin on 16/5/7.
//
//

#import "RDRRecordAndPlayResponseModel.h"
#import "RDRRecordVideoModel.h"

@implementation RDRRecordAndPlayResponseModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    
    NSMutableDictionary *mutDic = [[NSDictionary mtl_identityPropertyMapWithModel:[self class]] mutableCopy];
    
    return mutDic;
}

+ (NSValueTransformer *)videosJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[RDRRecordVideoModel class]];
}

@end
