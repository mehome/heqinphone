//
//  LPSystemSetting.m
//  linphone
//
//  Created by heqin on 15/11/7.
//
//

#import "LPSystemSetting.h"

@interface LPSystemSetting ()

// 添加一些变量

@end

@implementation LPSystemSetting

+ (instancetype)sharedSetting {
    static LPSystemSetting *instance;
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
        NSString *cachedSipStr = [[NSUserDefaults standardUserDefaults] stringForKey:@"sipDomain"];
        if (cachedSipStr.length > 0) {
            _sipDomainStr = cachedSipStr;
        }else {
            _sipDomainStr = @"";
        }
    }
    
    return self;
}

- (void)saveSystem {
    [[NSUserDefaults standardUserDefaults] setObject:self.sipDomainStr forKey:@"sipDomain"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
