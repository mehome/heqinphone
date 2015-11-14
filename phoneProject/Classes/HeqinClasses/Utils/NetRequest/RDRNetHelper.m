//
//  RDRNetHelper.m
//  RedDrive
//
//  Created by heqin on 15/8/19.
//  Copyright (c) 2015年 Wunelli. All rights reserved.
//

#import "RDRNetHelper.h"
#import "AFHTTPRequestOperationManager.h"
#import "XXCache.h"
#import "RDRNetworkAPICache.h"
#import "NSDictionary+XXQueryString.h"

@interface RDRNetHelper ()

@property (nonatomic, strong) AFHTTPRequestOperationManager *requestManager;

// http cache
@property (nonatomic, strong) RDRNetworkAPICache *httpCache;

// 公共参数保存
@property (nonatomic, strong) NSMutableDictionary *commonParametersCache;

// cache时需要排除的公共参数列表
@property (nonatomic, strong) NSArray *excludeCommonParameters;


@end

@implementation RDRNetHelper

- (id)initDefaultHelper
{
    if (self = [super init]) {
        self.requestManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kHeqinLinphoneServerAddress]];
        self.requestManager.requestSerializer=[AFJSONRequestSerializer serializer];
        _commonParametersCache=[[NSMutableDictionary alloc] init];
    }
    
    return self;
}

+ (instancetype)defaultHelper
{
    static RDRNetHelper *__helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __helper = [[self alloc] initDefaultHelper];
    });
    return __helper;
}

+ (void)setToken:(NSString *)tokenStr andPassword:(NSString *)password {
    if (tokenStr.length == 0 || password.length == 0) {
        [[RDRNetHelper defaultHelper].requestManager.requestSerializer clearAuthorizationHeader];
    }else {
        [[RDRNetHelper defaultHelper].requestManager.requestSerializer setAuthorizationHeaderFieldWithUsername:tokenStr password:password];
    }
}

+ (void)clearCommonParametersCache {
    [((RDRNetHelper *)[self defaultHelper]).commonParametersCache removeObjectForKey:@"usertoken"];
}

+ (void)addValueToCommonParametersCache:(NSString *)value key:(NSString *)key{
    if (value && key) {
        [((RDRNetHelper *)[self defaultHelper]).commonParametersCache setObject:value forKey:key];
    }
}


//- (AFHTTPRequestOperation *)POST:(NSString *)URLString
//                      parameters:(id)parameters
//                         success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
//                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;


+ (AFHTTPRequestOperation *)GET:(RDRRequest *)aModel
             responseModelClass:(Class)responseModelClass
                        success:(BlockRDRHTTPRequestSuccess)success
                        failure:(BlockRDRHTTPRequestFailure)failure {
    return [[RDRNetHelper defaultHelper] GET:aModel responseModelClass:responseModelClass success:success failure:failure];
}

- (AFHTTPRequestOperation *)GET:(RDRRequest *)aModel
                 responseModelClass:(Class)responseModelClass
                        success:(BlockRDRHTTPRequestSuccess)success
                        failure:(BlockRDRHTTPRequestFailure)failure
{
    return [self request:aModel
              httpMethod:@"GET"
      responseModelClass:responseModelClass
                 success:success
                 failure:failure constructingBodyWithBlock:nil uploadProgressBlock:nil];
}

+ (AFHTTPRequestOperation *)POST:(RDRRequest *)aModel
              responseModelClass:(Class)responseModelClass
                         success:(BlockRDRHTTPRequestSuccess)success
                         failure:(BlockRDRHTTPRequestFailure)failure
{
    return [[RDRNetHelper defaultHelper] POST:aModel
   responseModelClass:responseModelClass
              success:success
              failure:failure];
}


+ (AFHTTPRequestOperation *)POST:(RDRRequest *)aModel responseModelClass:(Class)responseModelClass success:(BlockRDRHTTPRequestSuccess)success failure:(BlockRDRHTTPRequestFailure)failure constructingBodyWithBlock:(BlockRDRHTTPRequestConstructingBody)bodyBlock uploadProgressBlock:(BlockRDRHTTPRequestUploadProgress)uploadBlock{
    
    return [[RDRNetHelper defaultHelper] request:aModel httpMethod:@"POST" responseModelClass:responseModelClass success:success failure:failure constructingBodyWithBlock:bodyBlock uploadProgressBlock:uploadBlock];
    
}


+ (AFHTTPRequestOperation *)request:(NSURLRequest *)request responseModelClass:(Class)responseModelClass success:(BlockRDRHTTPRequestSuccess)success failure:(BlockRDRHTTPRequestFailure)failure uploadProgressBlock:(BlockRDRHTTPRequestUploadProgress)uploadBlock downloadProgressBlock:(BlockRDRHTTPRequestDownloadProgress)downloadProgress{

    return [[RDRNetHelper defaultHelper] request:request responseModelClass:responseModelClass success:success failure:failure uploadProgressBlock:uploadBlock downloadProgressBlock:downloadProgress];
    
}





- (AFHTTPRequestOperation *)POST:(RDRRequest *)aModel
                  responseModelClass:(Class)responseModelClass
                         success:(BlockRDRHTTPRequestSuccess)success
                         failure:(BlockRDRHTTPRequestFailure)failure
{
    return [self request:aModel
              httpMethod:@"POST"
      responseModelClass:responseModelClass
                 success:success
                 failure:failure constructingBodyWithBlock:nil uploadProgressBlock:nil];
}


/**
 *  发送请求
 *
 *  @param requestModel       请求和参数Model
 *  @param httpMethod         请求类型
 *  @param responseModelClass 响应解析的JSONModel
 *  @param onCache            获取缓存回调
 *  @param success            成功回调
 *  @param failure            失败回调
 *
 *  @return 已发送的request 可以为nil
 */
- (AFHTTPRequestOperation *)request:(RDRRequest *)requestModel
                         httpMethod:(NSString *)httpMethod
                 responseModelClass:(Class)responseModelClass
                            success:(BlockRDRHTTPRequestSuccess)success
                            failure:(BlockRDRHTTPRequestFailure)failure
          constructingBodyWithBlock:(BlockRDRHTTPRequestConstructingBody)bodyBlock uploadProgressBlock:(BlockRDRHTTPRequestUploadProgress)uploadBlock{
    NSString *aURL = requestModel.urlPath;
    
    NSDictionary *dictionary = [self finalParametersFromRequestModel:requestModel];
    
    return [self requestWithURLStr:aURL
                                               httpMethod:httpMethod
                                           withParameters:dictionary
                                       responseModelClass:responseModelClass
                                                  success:success
                                                  failure:failure constructingBodyWithBlock:bodyBlock uploadProgressBlock:uploadBlock];
}

#pragma mark -
#pragma mark 封装公共参数
// 下面这个方法只是留在这里说明这里的一个多线程崩溃的问题
- (void)refreshCommonParametersCache
{
    NSString *netStatus = @"";
    if([[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus] == AFNetworkReachabilityStatusReachableViaWiFi) {
        netStatus = @"wifi";
    } else if ([[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus] == AFNetworkReachabilityStatusReachableViaWWAN) {
        netStatus = @"3G";
    }
    [self.commonParametersCache setObject:netStatus forKey:@"net"];
    
    // 还可能刷新其它参数，如一些实时的参数，如用户的登陆状态，用户名等这些可能会随用户的登陆退出而变化的数据
}

- (NSDictionary *)finalParametersFromRequestModel:(RDRRequest *)request {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
   
    
    if (request.requestModel) {
        
        NSDictionary *modelDictionary=[MTLJSONAdapter JSONDictionaryFromModel:request.requestModel error:nil];
        if (modelDictionary) {
            [dictionary addEntriesFromDictionary:modelDictionary];
        }
        
    }
    
    if (request.isAddCommonParameters == NO && self.commonParametersCache) {
        
        [dictionary addEntriesFromDictionary:self.commonParametersCache];
        
    }
    
    // heqin:屏掉下面这行代码是为了避免多个线程回来时，执行下面这个方法可能会同时执行这个方法，而这个方法会同时向同一个属性做写操作，从而会导致偶然的崩溃问题
    //    [self refreshCommonParametersCache];
    
    // 为了避免上面说到的这个偶然崩溃的问题， 因为多线程同时修改同一个变量，所以可能导致崩溃发生。所以应该像下面代码处理
    // 下面的代码相当于多个线程是没有在这个commonParametersCache上同时修改，只是取出这个变量到各自的临时变量dictionary，然后修改各自的临时变量dictionary.
   
    
    
    /*
    
    {
        NSString *netStatus = @"";
        if([[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus] == AFNetworkReachabilityStatusReachableViaWiFi) {
            netStatus = @"wifi";
        } else if ([[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus] == AFNetworkReachabilityStatusReachableViaWWAN) {
            netStatus = @"3G";
        }
        [dictionary setObject:netStatus forKey:@"net"];
        
        // 还可能刷新其它参数，如一些实时的参数，如用户的登陆状态，用户名等这些可能会随用户的登陆退出而变化的数据
    }
     */
    
    // 分解每个用户参数， 注，如果与公共参数相同，则会覆盖公共参数
    // TODO...
//    if ([requestModel toDictionary]) {
//        [dictionary addEntriesFromDictionary:[requestModel toDictionary]];
//    } else {
//        NSLog(@"[requestModel toDictionary]:%@", [requestModel toDictionary]);
//    }
    
    // timestamp
//    [dictionary setObject:[NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970] * 1000] forKey:@"timestamp"];
//    dictionary = [[self excludeNullInParam:dictionary] mutableCopy];
    
    return dictionary;
}

#pragma mark -


//- (AFHTTPRequestOperation *)requestWithURLStr:(NSString *)aURL
//                                   httpMethod:(NSString *)httpMethod
//                               withParameters:(NSDictionary *)parameters
//                           responseModelClass:(Class)responseModelClass
//                                      success:(BlockRDRHTTPRequestSuccess)success
//                                      failure:(BlockRDRHTTPRequestFailure)failure
//                    constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))bodyBlock uploadProgressBlock:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))uploadBlock



- (AFHTTPRequestOperation *)request:(NSURLRequest *)request responseModelClass:(Class)responseModelClass success:(BlockRDRHTTPRequestSuccess)success failure:(BlockRDRHTTPRequestFailure)failure uploadProgressBlock:(BlockRDRHTTPRequestUploadProgress)uploadBlock downloadProgressBlock:(BlockRDRHTTPRequestDownloadProgress)downloadProgress{

    
    AFHTTPRequestOperation * operation = [self.requestManager  HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject){
        
        
        //
        NSError *error = nil;
        NSData *dataResponse = (NSData *)responseObject;
        
        //
        if (responseModelClass != nil) {
            NSDictionary *dict = [RDRNetHelper dictionaryFromResponseData:dataResponse];
            
            RDRBaseResponseModel *aModel = [MTLJSONAdapter modelOfClass:responseModelClass
                                                     fromJSONDictionary:dict
                                                                  error:&error];
            
            if (error == nil) {
                
                if (success != NULL) {
                    // 可以做一些公用的操作， 比如打印log
                    
                    //
                    success(operation, aModel);
                }
            }
            else
            {
                NSLog(@"%@",error);
                if (failure != NULL) {
                    failure(operation, error);
                }
            }
            
        }
        else
        {
            if (success != NULL) {
                success(operation, dataResponse);
            }
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        failure ? failure(operation, error) : nil;
    }];
    
    if (downloadProgress) {
        [operation setDownloadProgressBlock:downloadProgress];
    }
    if (uploadBlock) {
        [operation setUploadProgressBlock:uploadBlock];
    }
    
    [operation start];
    
    return operation;
    
    
}
- (AFHTTPRequestOperation *)requestWithURLStr:(NSString *)aURL
                                   httpMethod:(NSString *)httpMethod
                               withParameters:(NSDictionary *)parameters
                           responseModelClass:(Class)responseModelClass
                                      success:(BlockRDRHTTPRequestSuccess)success
                                      failure:(BlockRDRHTTPRequestFailure)failure
                    constructingBodyWithBlock:(BlockRDRHTTPRequestConstructingBody)bodyBlock uploadProgressBlock:(BlockRDRHTTPRequestUploadProgress)uploadBlock
{
 
    if (!([httpMethod isKindOfClass:[NSString class]] && httpMethod.length > 0)) {
        NSLog(@"something wrong with httpMethod=%@", httpMethod);
        return nil;
    }
    
    AFHTTPRequestOperation *requestOperation = nil;
    if ([httpMethod isEqualToString:@"GET"]) {
        
        requestOperation = [self.requestManager GET:aURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //
            NSError *error = nil;
            NSData *dataResponse = (NSData *)responseObject;
            
            //
            if (responseModelClass != nil) {
                
                NSDictionary *dict = [RDRNetHelper dictionaryFromResponseData:dataResponse];
                
                RDRBaseResponseModel *aModel = [MTLJSONAdapter modelOfClass:responseModelClass
                                                         fromJSONDictionary:dict
                                                                      error:&error];
                
                if (error == nil) {
                    
                    if (success != NULL) {
                        // 可以做一些公用的操作， 比如打印log
                        
                        //
                        success(operation, aModel);
                    }
                }
                else
                {
                    if (failure != NULL) {
                        failure(operation, error);
                    }
                }
                
            }
            else
            {
                if (success != NULL) {
                    success(operation, dataResponse);
                }
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            failure ? failure(operation, error) : nil;
        }];
        
    }else if ([httpMethod isEqualToString:@"POST"]) {
        
        
        if (bodyBlock) {
            

            requestOperation = [self.requestManager POST:aURL parameters:parameters constructingBodyWithBlock:bodyBlock success: ^(AFHTTPRequestOperation *operation, id responseObject){
                
                
                //
                NSError *error = nil;
                NSData *dataResponse = (NSData *)responseObject;
                
                //
                if (responseModelClass != nil) {
                    NSDictionary *dict = [RDRNetHelper dictionaryFromResponseData:dataResponse];
                    
                    RDRBaseResponseModel *aModel = [MTLJSONAdapter modelOfClass:responseModelClass
                                                             fromJSONDictionary:dict
                                                                          error:&error];
                    
                    if (error == nil) {
                        
                        if (success != NULL) {
                            // 可以做一些公用的操作， 比如打印log
                            
                            //
                            success(operation, aModel);
                        }
                    }
                    else
                    {
                        NSLog(@"%@",error);
                        if (failure != NULL) {
                            failure(operation, error);
                        }
                    }
                    
                }
                else
                {
                    if (success != NULL) {
                        success(operation, dataResponse);
                    }
                }
                
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error){
                failure ? failure(operation, error) : nil;
            }];
        }else{

            requestOperation = [self.requestManager POST:aURL parameters:parameters success: ^(AFHTTPRequestOperation *operation, id responseObject){
                
                
                //
                NSError *error = nil;
                NSData *dataResponse = (NSData *)responseObject;
                
                //
                if (responseModelClass != nil) {
                    NSDictionary *dict = [RDRNetHelper dictionaryFromResponseData:dataResponse];
                    
                    RDRBaseResponseModel *aModel = [MTLJSONAdapter modelOfClass:responseModelClass
                                                             fromJSONDictionary:dict
                                                                          error:&error];
                    
                    if (error == nil) {
                        
                        if (success != NULL) {
                            // 可以做一些公用的操作， 比如打印log
                            
                            //
                            success(operation, aModel);
                        }
                    }
                    else
                    {
                        NSLog(@"%@",error);
                        if (failure != NULL) {
                            failure(operation, error);
                        }
                    }
                    
                }
                else
                {
                    if (success != NULL) {
                        success(operation, dataResponse);
                    }
                }
                
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error){
                failure ? failure(operation, error) : nil;
            }];
        }
        
        if (uploadBlock) {
            [requestOperation setUploadProgressBlock:uploadBlock];
        }
        
        
    }else {
    
    }
    
    return requestOperation;
}


#pragma mark -
#pragma mark - 容错
/**
 *  把里面键值可能对应的值为空的，都进行移除掉，否则可能会引起崩溃
 *
 *  @param inDict
 *
 *  @return 返回修改过的字典
 */
- (NSDictionary *)excludeNullInParam:(NSDictionary *)inDict
{
    NSMutableDictionary *tmpDict = [inDict mutableCopy];
    NSArray *paramKeys = [tmpDict allKeys];
    for (NSString *tmpKey in paramKeys) {
        if ([tmpDict[tmpKey] isKindOfClass:[NSNull class]]) {
            tmpDict[tmpKey] = @"";
        }
    }
    return tmpDict;
}

#pragma mark -
#pragma mark 数据解析

+ (NSDictionary *)dictionaryFromResponseData:(NSData *)responseData
{
    if ([responseData isKindOfClass:[NSData class]]) {
        return [NSJSONSerialization JSONObjectWithData:responseData options:0 error:NULL];
    }else if ([responseData isKindOfClass:[NSDictionary class]]) {
        return (NSDictionary *)responseData;
    }
    return nil;
}


+ (BOOL)isCancelledHTTPRequestError:(NSError *)error {
    return [error isKindOfClass:[NSError class]] && [error code] == NSURLErrorCancelled;
}


@end
