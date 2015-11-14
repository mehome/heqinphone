//
//  RDRUserScoreResponseModel.m
//  RedDrive
//
//  Created by YDJ on 15/8/28.
//  Copyright (c) 2015年 Wunelli. All rights reserved.
//

#import "RDRSystemConfigResponseModel.h"

@implementation RDRSystemConfigResponseModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    NSMutableDictionary *mutDic = [[NSDictionary mtl_identityPropertyMapWithModel:[self class]] mutableCopy];
    
    [mutDic setObject:@"domain" forKey:@"domainStr"];
    
    return mutDic;
}

@end
