//
//  LPSystemSetting.m
//  linphone
//
//  Created by heqin on 15/11/7.
//
//

#import "LPSystemSetting.h"

////////////////////////系统设置//////////////////////////
@interface LPSystemSetting () {
    NSString *innerTmpProxy;
    BOOL _defaultSilence;
    BOOL _defaultNoVideo;
}

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

- (NSString *)sipDomainStr {
    return @"zijingcloud.com";
}

- (void)setSipTmpProxy:(NSString *)sipTmpProxyParam {
    innerTmpProxy = sipTmpProxyParam;
    
    [[NSUserDefaults standardUserDefaults] setObject:innerTmpProxy forKey:@"keyTmpProxy"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)sipTmpProxy {
    if (innerTmpProxy == nil) {
        
        innerTmpProxy = [[NSUserDefaults standardUserDefaults] objectForKey:@"keyTmpProxy"];
        if (![innerTmpProxy isKindOfClass:[NSString class]] || innerTmpProxy.length == 0) {
            innerTmpProxy = @"sip.myvmr.cn:80";
        }
    }
    return innerTmpProxy;
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
        
        _defaultSilence = [[NSUserDefaults standardUserDefaults] boolForKey:@"meetingDefaultSilent"];
        _defaultNoVideo = [[NSUserDefaults standardUserDefaults] boolForKey:@"meetingDefaultNoVide"];
        
        _videoSizeType = [[NSUserDefaults standardUserDefaults] integerForKey:@"settingVideoSizeType"];
        _videoFrameType = [[NSUserDefaults standardUserDefaults] integerForKey:@"settingVideoFrameType"];
    }
    
    return self;
}

- (void)setDefaultSilence:(BOOL)defaultSilence {
    _defaultSilence = defaultSilence;
    
    [[NSUserDefaults standardUserDefaults] setBool:defaultSilence forKey:@"meetingDefaultSilent"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setDefaultNoVideo:(BOOL)defaultNoVideo {
    _defaultNoVideo = defaultNoVideo;
    
    [[NSUserDefaults standardUserDefaults] setBool:defaultNoVideo forKey:@"meetingDefaultNoVide"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)getHistoryMeetingFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"system.plist"];
    return path;
}

- (void)readCacheSetting {
    // 从本地读取属性值
    NSString *cachedSipProxyStr = [[NSUserDefaults standardUserDefaults] stringForKey:@"sipProxy"];
    if ([cachedSipProxyStr isKindOfClass:[NSString class]] && cachedSipProxyStr.length > 0) {
        self.sipTmpProxy = cachedSipProxyStr;
    }else {
        self.sipTmpProxy = @"sip.myvmr.cn";//@"120.132.87.180";        如果本地没有读取到，则使用这个, 这里暂时没有写成sip.myvmr.cn:80
        NSLog(@"使用设定的默认值，通常来说是不会运行到这时来的，只有第一次可能会到这里来");
    }
    
    self.joinerName = [[NSUserDefaults standardUserDefaults] stringForKey:@"joinerName"];
    if (self.joinerName.length == 0) {
        self.joinerName = @"noName";
    }
}

- (void)saveCacheSetting {
    if (self.sipTmpProxy.length > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:self.sipTmpProxy forKey:@"sipProxy"];
    }
    
    if (self.joinerName.length > 0) {
        [[NSUserDefaults standardUserDefaults] setObject:self.joinerName forKey:@"joinerName"];
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:self.videoSizeType forKey:@"settingVideoSizeType"];
    [[NSUserDefaults standardUserDefaults] setInteger:self.videoFrameType forKey:@"settingVideoFrameType"];

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


