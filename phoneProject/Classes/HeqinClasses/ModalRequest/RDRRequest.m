//
//  RDRRequestModel.m
//  RedDrive
//
//  Created by YDJ on 15/8/23.
//  Copyright (c) 2015年 Wunelli. All rights reserved.
//

#import "RDRRequest.h"

@implementation RDRRequest

+ (instancetype)request{
    return [self requestWithURLPath:nil model:nil];
}

+ (instancetype)requestWithURLPath:(NSString *)urlPath model:(id<MTLJSONSerializing>)model{
    return [[self alloc] initWithURLPath:urlPath model:model];
}


- (instancetype)initWithURLPath:(NSString *)urlPath model:(id<MTLJSONSerializing>)model{
    self=[super init];
    if (self) {
        [self setUrlPath:urlPath];
        [self setRequestModel:model];
    }
    return self;
}


- (NSString *)urlPath{
    if (!_urlPath) {
        if ([self.requestModel respondsToSelector:@selector(requestModelURLPath)]) {
            NSString *url=[self.requestModel performSelector:@selector(requestModelURLPath)];
            _urlPath=[url copy];
        }
    }
    return _urlPath;
}

@end
