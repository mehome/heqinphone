//
//  RDRNetHelper.h
//  RedDrive
//
//  Created by heqin on 15/8/19.
//  Copyright (c) 2015年 Wunelli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "RDRRequest.h"
#import "RDRBaseResponseModel.h"

/**
 *  Cache策略
 */
typedef enum : NSUInteger {
    // 不使用缓存
    RDRURLCachePolicyNone = 0,
    
    // 忽略本地缓存
    RDRURLCachePolicyIgnoringLocalCacheData = RDRURLCachePolicyNone,
    
    // 数据请求失败时使用缓存
    RDRURLCachePolicyReturnCacheDataOnError,
    
    // 先使用缓存同时再请求数据
    RDRURLCachePolicyReturnCacheDataAndRequestNetwork,
    
} RDRURLCachePolicy;


typedef void (^BlockRDRHTTPRequestCache)(AFHTTPRequestOperation *operation, id responseObject, RDRURLCachePolicy cachePolicy);
typedef void (^BlockRDRHTTPRequestSuccess)(AFHTTPRequestOperation *operation, id responseObject);
typedef void (^BlockRDRHTTPRequestFailure)(AFHTTPRequestOperation *operation, NSError *error);


typedef void (^BlockRDRHTTPRequestDownloadProgress)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead);
typedef void (^BlockRDRHTTPRequestUploadProgress)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite);
typedef void(^BlockRDRHTTPRequestConstructingBody)(id <AFMultipartFormData> formData);


@interface RDRNetHelper : NSObject

// 登陆成功后设置Token和guid， 注销时传一个空值，即会清空Token和Password
+ (void)setToken:(NSString *)tokenStr andPassword:(NSString *)password;

//添加公共参数到字典中
+ (void)addValueToCommonParametersCache:(NSString *)value key:(NSString *)key;

// 清除公共参数，以便登出时调用重置
+ (void)clearCommonParametersCache;


+ (AFHTTPRequestOperation *)GET:(RDRRequest *)aModel
             responseModelClass:(Class)responseModelClass
                        success:(BlockRDRHTTPRequestSuccess)success
                        failure:(BlockRDRHTTPRequestFailure)failure;

+ (AFHTTPRequestOperation *)POST:(RDRRequest *)aModel
              responseModelClass:(Class)responseModelClass
                         success:(BlockRDRHTTPRequestSuccess)success
                         failure:(BlockRDRHTTPRequestFailure)failure;


+ (AFHTTPRequestOperation *)POST:(RDRRequest *)aModel responseModelClass:(Class)responseModelClass success:(BlockRDRHTTPRequestSuccess)success failure:(BlockRDRHTTPRequestFailure)failure constructingBodyWithBlock:(BlockRDRHTTPRequestConstructingBody)bodyBlock uploadProgressBlock:(BlockRDRHTTPRequestUploadProgress)uploadBlock;



+ (AFHTTPRequestOperation *)request:(NSURLRequest *)request responseModelClass:(Class)responseModelClass success:(BlockRDRHTTPRequestSuccess)success failure:(BlockRDRHTTPRequestFailure)failure uploadProgressBlock:(BlockRDRHTTPRequestUploadProgress)uploadBlock downloadProgressBlock:(BlockRDRHTTPRequestDownloadProgress)downloadProgress;

@end
