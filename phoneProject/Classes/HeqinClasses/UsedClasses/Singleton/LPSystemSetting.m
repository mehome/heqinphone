//
//  LPSystemSetting.m
//  linphone
//
//  Created by heqin on 15/11/7.
//
//

#import "LPSystemSetting.h"

////////////////////////系统设置//////////////////////////
@interface LPSystemSetting ()

@property (nonatomic, strong, readwrite) NSDateFormatter *unifyDateformatter;

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

- (NSDateFormatter *)unifyDateformatter {
    if (!_unifyDateformatter) {
        _unifyDateformatter=[[NSDateFormatter alloc] init];
        [_unifyDateformatter setDateFormat:@"yyyy-MM-dd"];
    }
    return _unifyDateformatter;
}

- (instancetype)init {
    if (self = [super init]) {
        // 用一些初始化的操作
        [self readCacheSetting];
        
        // 从一个plist中读出历史会议
        [self readHistoryMeetingData];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
    }
    
    return self;
}

- (NSString *)getHistoryMeetingFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"system.plist"];
    return path;
}

- (void)readCacheSetting {
    // 从本地读取属性值
    NSString *cachedSipStr = [[NSUserDefaults standardUserDefaults] stringForKey:@"sipDomain"];
    if (cachedSipStr.length > 0) {
        self.sipDomainStr = cachedSipStr;
    }else {
        self.sipDomainStr = @"sip.myvmr.cn";//@"120.132.87.180";
    }
    
    self.joinerName = [[NSUserDefaults standardUserDefaults] stringForKey:@"joinerName"];
    if (self.joinerName.length == 0) {
        self.joinerName = @"noName";
    }
}

- (void)saveCacheSetting {
    if (self.sipDomainStr.length > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:self.sipDomainStr forKey:@"sipDomain"];
    }
    
    if (self.joinerName.length > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:self.joinerName forKey:@"joinerName"];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)readHistoryMeetingData {
    self.historyMeetings = [NSMutableArray array];

    NSString *path = [self getHistoryMeetingFilePath];
    NSArray *arr = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    if (arr.count > 0) {
        [self.historyMeetings addObjectsFromArray:arr];
    }
}

- (void)saveHistoryMeetingData {
    NSString *path = [self getHistoryMeetingFilePath];

    BOOL saveResult = [NSKeyedArchiver archiveRootObject:self.historyMeetings toFile:path];
    NSLog(@"save result = %@", saveResult?@"Success":@"Fail");
}

- (void)saveSystem {
    [self saveCacheSetting];
    
    [self saveHistoryMeetingData];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [self saveSystem];
}

@end


