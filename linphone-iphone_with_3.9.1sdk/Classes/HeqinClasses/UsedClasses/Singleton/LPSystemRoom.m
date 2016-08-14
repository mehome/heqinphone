//
//  LPSystemRoom.m
//  linphone
//
//  Created by heqin on 15/11/7.
//
//

#import "LPSystemRoom.h"

@implementation LPSystemRoom

+ (instancetype)sharedRoom {
    static LPSystemRoom *instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
    }
    
    return self;
}

@end
