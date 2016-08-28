//
//  LPUser.m
//  linphone
//
//  Created by heqin on 15/11/7.
//
//

#import "LPSystemUser.h"
#import "LinphoneManager.h"
#import "PhoneMainView.h"
#import "Utils.h"
#import "RDRMyMeetingRequestModel.h"
#import "RDRRequest.h"
#import "RDRMyMeetingResponseModel.h"
#import "RDRNetHelper.h"
#import "LPSystemSetting.h"

@interface LPSystemUser () {
    
    LinphoneAccountCreator *account_creator;
    LinphoneProxyConfig *new_config;

}

@property (nonatomic, assign) BOOL missedFilter;        // 为了保留原始的Linphone代码而兼容，原代码中有选择是显示全部还是显示未接电话

@end

@implementation LPSystemUser

+ (NSString *)takePureAddrFrom:(NSString *)address {
    if (address.length == 0) {
        NSLog(@"地址号码错误，输入有误, address=%@", address);
        return @"";
    }
    
    NSMutableString *addr = [NSMutableString stringWithString:address];
    
    NSString *domainTmpStr = [NSString stringWithFormat:@"@%@",
                              [LPSystemSetting sharedSetting].sipDomainStr];     // 为@zijingcloud.com
    
    // 移掉后部
    if ([addr replaceOccurrencesOfString:domainTmpStr
                              withString:@""
                                 options:NSCaseInsensitiveSearch
                                   range:NSMakeRange(0, [addr length])] != 0) {
        NSLog(@"地址中移除zijingcloud.com成功");
    }else {
        NSLog(@"地址中移除zijingcloud.com失败");
    }
    
    // 移掉前面的sip:
    if ([addr replaceOccurrencesOfString:@"sip:" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [addr length])] != 0) {
        NSLog(@"地址中移除sip:成功");
    }else {
        NSLog(@"地址中移除sip:失败");
    }
    
    if (addr.length == 0) {
        NSLog(@"地址号码错误，请检查，输入地址为:%@", address);
        return @"";
    }else {
        return addr;
    }
}

+ (instancetype)sharedUser {
    static LPSystemUser *instance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        // 用一些初始化的操作
        _myScheduleMeetings = @[];
        _myMeetingsRooms = @[];
        _myFavMeetings = @[];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
        
        _hasGetMeetingData = NO;
        
        _missedFilter = NO;         // 用来做为是否只显示错过的电话，这里直接设置为ＮＯ， 表示显示全部电话
        _callLogs = [[NSMutableArray alloc] init];
        
        _settingsStore = [[LinphoneCoreSettingsStore alloc] init];
        
        [_settingsStore setBool:!([LPSystemSetting sharedSetting].defaultNoVideo) forKey:@"enable_video_preference"];
        
        _hasLoginSuccess = [[NSUserDefaults standardUserDefaults] boolForKey:@"systemLoginStatus"];
        
        [self loadHistoryData];        
    }
    
    return self;
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [[NSUserDefaults standardUserDefaults] setBool:self.hasLoginSuccess forKey:@"systemLoginStatus"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 可以做为外部调用，做为刷新操作
- (void)loadHistoryData {
    [self.callLogs removeAllObjects];
    const MSList * logs = linphone_core_get_call_logs([LinphoneManager getLc]);
    while(logs != NULL) {
        LinphoneCallLog*  log = (LinphoneCallLog *) logs->data;
        if(self.missedFilter) {
            if (linphone_call_log_get_status(log) == LinphoneCallMissed) {
                [self.callLogs addObject:[NSValue valueWithPointer: log]];
            }
        } else {
            [self.callLogs addObject:[NSValue valueWithPointer: log]];
        }
        logs = ms_list_next(logs);
    }
    
    // 加载完毕
}

+ (void)requesteFav:(BlockRequestFavMeetings)finishBlock {
    if ([LPSystemUser sharedUser].hasGetMeetingData == YES) {
        // 已经取到数据
        finishBlock(true, [LPSystemUser sharedUser].myScheduleMeetings, [LPSystemUser sharedUser].myMeetingsRooms, [LPSystemUser sharedUser].myFavMeetings, @"从本地获取成功");
    }else {
        // 未取到数据， 进行请求
        RDRMyMeetingRequestModel *reqModel = [RDRMyMeetingRequestModel requestModel];
        
        NSString *curUsedDomain = [[LPSystemUser sharedUser].settingsStore stringForKey:@"account_mandatory_domain_preference"];
        NSString *curUsedUserIdStr = [[LPSystemUser sharedUser].settingsStore stringForKey:@"account_userid_preference"];
        reqModel.uid = [curUsedUserIdStr stringByAppendingFormat:@"@%@", curUsedDomain];
        
        RDRRequest *req = [RDRRequest requestWithURLPath:nil model:reqModel];
        
        [RDRNetHelper GET:req responseModelClass:[RDRMyMeetingResponseModel class]
                  success:^(NSURLSessionDataTask *operation, id responseObject) {
                      
                      RDRMyMeetingResponseModel *model = responseObject;
                      
                      if ([model codeCheckSuccess] == YES) {
                          NSLog(@"请求Meeting Info, success, model=%@", model);
                          
                          // 解析model数据
                          [LPSystemUser sharedUser].hasGetMeetingData = YES;
                          [LPSystemUser sharedUser].myScheduleMeetings = [model.schedule mutableCopy];
                          [LPSystemUser sharedUser].myMeetingsRooms = [model.rooms mutableCopy];
                          [LPSystemUser sharedUser].myFavMeetings = [model.fav mutableCopy];

                          finishBlock(true, [LPSystemUser sharedUser].myScheduleMeetings, [LPSystemUser sharedUser].myMeetingsRooms, [LPSystemUser sharedUser].myFavMeetings, @"网络请求成功");
                      }else {
                          NSLog(@"请求Meeting Info 服务器请求出错, model=%@, msg=%@", model, model.msg);
                          finishBlock(false, nil, nil, nil, model.msg);
                      }
                  } failure:^(NSURLSessionDataTask *operation, NSError *error) {
                      //请求出错
                      NSLog(@"请求Meeting Info出错, %s, error=%@", __FUNCTION__, error);
                      finishBlock(false, nil, nil, nil, error.localizedFailureReason);
                  }];
    }
}

+ (void)resetToAnonimousLogin {
    // 在用户未登录时， 强制进行添加
//    [[LPSystemUser sharedUser].settingsStore setObject:@"zijing@unknown-host"   forKey:@"account_mandatory_username_preference"];
//    
//    [[LPSystemUser sharedUser].settingsStore setObject:[LPSystemSetting sharedSetting].sipTmpProxy forKey:@"account_proxy_preference"];
//    [[LPSystemUser sharedUser].settingsStore setObject:[LPSystemSetting sharedSetting].sipDomainStr forKey:@"account_mandatory_domain_preference"];
//    
//    [[LPSystemUser sharedUser].settingsStore setObject:@""   forKey:@"account_mandatory_password_preference"];
//    [[LPSystemUser sharedUser].settingsStore setBool:YES   forKey:@"account_outbound_proxy_preference"];
//    
//    [[LPSystemUser sharedUser].settingsStore synchronize];
    
    NSString *anolymousName = @"anolymous";
    NSString *anolymousUserId = @"anolymous";
    NSString *anolymousPassword = @"";
    NSString *anolymousDisplayName = [LPSystemSetting sharedSetting].joinerName;
    NSString *anolymousDomain = [LPSystemSetting sharedSetting].sipDomainStr;
    
    NSDictionary *loginResult = [[LPSystemUser sharedUser] tryToLoginWithUserName:anolymousName userId:anolymousUserId password:anolymousPassword displayName:anolymousDisplayName domain:anolymousDomain];
    NSLog(@"loginResult=%@", loginResult);
}


// 传参为:userName=qin.he, userId=qin.he, password=he@2015, domain=zijingcloud.com
// 或者外部把输入的用户名为:test@jingkong.hk.com, 则拆分为userName=test, userId=test, passowrd="", domain=jingkong.hk.com
// displayName为特定字段，可随意指定
- (NSDictionary *) tryToLoginWithUserName:(NSString*)username userId:(NSString *)userIdStr password:(NSString*)password displayName:(NSString *)displayName domain:(NSString *)domainStr {
    NSLog(@"verificationSignInWithUsername username=%@, userIdStr=%@, password=%@, domain=%@",
          username, userIdStr, password, domainStr);
    
    // 发现在程序刚启动时，使用下面的这个判断，居然会判断为无网，不知何故，所以这里把它们进行屏掉. 2016.8.28
//    if ([LinphoneManager instance].connectivity == none) {
//        return @{@"success":@NO, @"reason":NSLocalizedString(@"No connectivity", nil)};
//    } else {
    
        [self loadAssistantConfig:@"assistant_external_sip.rc"];
        [self resetLiblinphone];
        [self fillAccountCreatorWith:userIdStr withPassword:password withDomain:domainStr];
        
        NSDictionary *configResult = [self configureProxyConfig];
        if (((NSNumber *)(configResult[@"success"])).boolValue == NO) {
            return configResult;
        }
        
        NSString *usedProxyStr = [LPSystemSetting sharedSetting].sipTmpProxy;
        [self loginWith:username withDisplayName:displayName withUserId:userIdStr withPassword:password withDomain:domainStr withProxy:usedProxyStr];
        // 然后就等待登录成功或者失败的回调.
        
        return @{@"success":@YES};
//    }
}

////////////////////////// 新版登录方式//////////////////////
- (void)loadAssistantConfig:(NSString *)rcFilename {
    NSString *fullPath = [@"file://" stringByAppendingString:[LinphoneManager bundleFile:rcFilename]];
    linphone_core_set_provisioning_uri(LC, fullPath.UTF8String);
    [LinphoneManager.instance lpConfigSetInt:1 forKey:@"transient_provisioning" inSection:@"misc"];
}

- (void)resetLiblinphone {
    if (account_creator) {
        linphone_account_creator_unref(account_creator);
        account_creator = NULL;
    }
    [LinphoneManager.instance resetLinphoneCore];
    account_creator = linphone_account_creator_new(
                                                   LC, [LinphoneManager.instance lpConfigStringForKey:@"xmlrpc_url" inSection:@"assistant" withDefault:@""]
                                                   .UTF8String);
    linphone_account_creator_set_user_data(account_creator, (__bridge void *)(self));
}

- (void)fillAccountCreatorWith:(NSString *)userId withPassword:(NSString *)password withDomain:(NSString *)domain {
    // 然后赋各个参数
    //    LinphoneAccountCreatorStatus s = linphone_account_creator_set_username(account_creator, @"qin.he@zijingcloud.com".UTF8String);
    LinphoneAccountCreatorStatus s = linphone_account_creator_set_username(account_creator, userId.UTF8String);
    NSLog(@"set userId=%d", s);
    //    s = linphone_account_creator_set_password(account_creator, @"he@2015".UTF8String);
    s = linphone_account_creator_set_password(account_creator, password.UTF8String);
    NSLog(@"set password=%d", s);
    //    s = linphone_account_creator_set_domain(account_creator, @"zijingcloud.com".UTF8String);
    s = linphone_account_creator_set_domain(account_creator, domain.UTF8String);
    NSLog(@"set domain=%d", s);
    
    s = linphone_account_creator_set_transport(account_creator, LinphoneTransportTcp);//linphone_transport_parse(@"tcp".UTF8String));
    NSLog(@"set transport=%d", s);
}

- (NSDictionary *)configureProxyConfig {
    LinphoneManager *lm = LinphoneManager.instance;
    
    // remove previous proxy config, if any
    if (new_config != NULL) {
        const LinphoneAuthInfo *auth = linphone_proxy_config_find_auth_info(new_config);
        linphone_core_remove_proxy_config(LC, new_config);
        if (auth) {
            linphone_core_remove_auth_info(LC, auth);
        }
        new_config = NULL;
    }
    
    const char *pssword = linphone_account_creator_get_username(account_creator);
    NSLog(@"userName=%s", pssword);
    
    const char *paname = linphone_account_creator_get_password(account_creator);
    NSLog(@"password=%s", paname);
    
    const char *padomain = linphone_account_creator_get_domain(account_creator);
    NSLog(@"padomain=%s", padomain);
    
    LinphoneTransportType portType = linphone_account_creator_get_transport(account_creator);
    NSLog(@"portType=%d", portType);
    
    const char *paRoute = linphone_account_creator_get_route(account_creator);
    NSLog(@"paRoute=%s", paRoute);

    new_config = linphone_account_creator_configure(account_creator);
    
    if (new_config) {
        [lm configurePushTokenForProxyConfig:new_config];
        linphone_core_set_default_proxy_config(LC, new_config);
        return @{@"success":@YES};
    } else {
        return @{@"success":@NO, @"reason":NSLocalizedString(@"Could not configure your account, please check parameters or try again later", nil)};
    }
}

- (void)loginWith:(NSString *)userName withDisplayName:(NSString *)displayName withUserId:(NSString *)userId withPassword:(NSString *)password withDomain:(NSString *)domainStr withProxy:(NSString *)proxyParamStr {
    
    [[LPSystemUser sharedUser].settingsStore transformLinphoneCoreToKeys];
    [[LPSystemUser sharedUser].settingsStore transformAccountToKeys:userName];
    
    // 用户名
    [[LPSystemUser sharedUser].settingsStore setObject:userName forKey:@"account_mandatory_username_preference"];
    [[LPSystemUser sharedUser].settingsStore setObject:displayName forKey:@"account_display_name_preference"];
    [[LPSystemUser sharedUser].settingsStore setObject:userId forKey:@"account_userid_preference"];
    [[LPSystemUser sharedUser].settingsStore setObject:password forKey:@"account_mandatory_password_preference"];
    
    [[LPSystemUser sharedUser].settingsStore setObject:domainStr forKey:@"account_mandatory_domain_preference"];
    [[LPSystemUser sharedUser].settingsStore setObject:proxyParamStr forKey:@"account_proxy_preference"];
    
    [[LPSystemUser sharedUser].settingsStore setBool:YES   forKey:@"account_outbound_proxy_preference"];
    
    [[LPSystemUser sharedUser].settingsStore synchronize];
    // 登录完成，等通知吧
}



@end
