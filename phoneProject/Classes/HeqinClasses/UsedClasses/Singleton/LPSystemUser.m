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
#import "UILinphone.h"
#import "Utils.h"
#import "RDRMyMeetingRequestModel.h"
#import "RDRRequest.h"
#import "RDRMyMeetingResponseModel.h"
#import "RDRNetHelper.h"
#import "LPSystemSetting.h"

@interface LPSystemUser ()

@property (nonatomic, assign) BOOL missedFilter;        // 为了保留原始的Linphone代码而兼容，原代码中有选择是显示全部还是显示未接电话

@end

@implementation LPSystemUser

+ (void)resetToAnonimousLogin {
    // 在用户未登录时， 强制进行添加
    [[LPSystemUser sharedUser].settingsStore setObject:@"yunphone.iphone@unknown-host"   forKey:@"username_preference"];
    [[LPSystemUser sharedUser].settingsStore setObject:[LPSystemSetting sharedSetting].sipTmpProxy forKey:@"domain_preference"];
    [[LPSystemUser sharedUser].settingsStore setObject:[[LPSystemSetting sharedSetting].sipDomainStr stringByAppendingString:@":80"] forKey:@"proxy_preference"];
    [[LPSystemUser sharedUser].settingsStore setObject:@""   forKey:@"password_preference"];
    [[LPSystemUser sharedUser].settingsStore setBool:TRUE   forKey:@"outbound_proxy_preference"];

    [[LPSystemUser sharedUser].settingsStore synchronize];
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
        
        _hasGetMeetingData = NO;
        
        _missedFilter = NO;         // 用来做为是否只显示错过的电话，这里直接设置为ＮＯ， 表示显示全部电话
        _callLogs = [[NSMutableArray alloc] init];
        
        _settingsStore = [[LinphoneCoreSettingsStore alloc] init];
        [_settingsStore transformLinphoneCoreToKeys];
        
        [self loadHistoryData];
        
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
        reqModel.uid = [[LPSystemUser sharedUser].settingsStore stringForKey:@"userid_preference"];
        
        RDRRequest *req = [RDRRequest requestWithURLPath:nil model:reqModel];
        
        [RDRNetHelper GET:req responseModelClass:[RDRMyMeetingResponseModel class]
                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                      
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
                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      //请求出错
                      NSLog(@"请求Meeting Info出错, %s, error=%@", __FUNCTION__, error);
                      finishBlock(false, nil, nil, nil, error.localizedFailureReason);
                  }];
    }
}

@end
