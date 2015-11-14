//
//  RDRBaseRequestModel.m
//  RedDrive
//
//  Created by heqin on 15/8/19.
//  Copyright (c) 2015年 Wunelli. All rights reserved.
//

#import "RDRBaseRequestModel.h"

@implementation RDRBaseRequestModel


+ (instancetype)requestModel{
    return [[self alloc] init];
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    
    return [NSDictionary mtl_identityPropertyMapWithModel:[self class]];
}

- (NSString *)requestModelURLPath{
    //
    return nil;
}


@end
