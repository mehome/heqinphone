//
//  XXNetworkAPICache.m
//  SpecialXX
//
//  Created by heqin on 15-3-9.
//  Copyright (c) 2015年 heqin. All rights reserved.
//

#import "RDRNetworkAPICache.h"

@implementation RDRNetworkAPICache

+ (instancetype)sharedCache {
    static RDRNetworkAPICache *_cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cache = [[self alloc] initWithNamespace:@"heqinPhone"];
    });
    return _cache;
}

@end
