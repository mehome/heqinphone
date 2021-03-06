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
        // 用一些初始化的操作
        // 从本地读取属性值
        //        NSString *cachedSipStr = [[NSUserDefaults standardUserDefaults] stringForKey:@"sipDomain"];
        //        if (cachedSipStr.length > 0) {
        //            _sipDomainStr = cachedSipStr;
        //        }else {
        //            _sipDomainStr = @"";
        //        }
    }
    
    return self;
}

@end
