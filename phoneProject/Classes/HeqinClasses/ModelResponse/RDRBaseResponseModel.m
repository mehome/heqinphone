//
//  RDRBaseResponseModel.m
//  RedDrive
//
//  Created by heqin on 15/8/19.
//  Copyright (c) 2015年 Wunelli. All rights reserved.
//

#import "RDRBaseResponseModel.h"
#import "NSDictionary+MTLMappingAdditions.h"

@implementation RDRBaseResponseModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return [NSDictionary mtl_identityPropertyMapWithModel:[self class]];
}


- (BOOL)codeCheckSuccess {
    return (self.code == 200);
}

@end
