//
//  XXCache.h
//  SpecialXX
//
//  Created by heqin on 15-3-9.
//  Copyright (c) 2015年 heqin. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  缓存类型
 */
typedef enum : NSUInteger {
    XXCacheTypeNone,
    XXCacheTypeDisk,
    XXCacheTypeMemory
}XXCacheType;

typedef void(^XXCacheQueryCompletedBlock)(NSData *data, XXCacheType cachedType);

@interface XXCache : NSObject

@property (nonatomic, assign) NSUInteger maxMemoryCost;
@property (nonatomic, assign, readonly) BOOL usingMemoryCache;

@property (nonatomic, assign) NSInteger maxCacheAge;
@property (nonatomic, assign) NSUInteger maxCacheSize;

- (instancetype)initWithNamespace:(NSString *)ns;

- (instancetype)initWithNamespace:(NSString *)ns
                 usingMemoryCache:(BOOL)usingMemoryCache;

//
- (void)storeCachedData:(NSData *)data forKey:(NSString *)key;
- (void)storeCachedData:(NSData *)data forKey:(NSString *)key withGroup:(NSString *)group;

//
- (void)storeCachedData:(NSData *)data forKey:(NSString *)key toDisk:(BOOL)toDisk;
- (void)storeCachedData:(NSData *)data forKey:(NSString *)key withGroup:(NSString *)group toDisk:(BOOL)toDisk;

//
- (NSOperation *)queryDiskCacheForKey:(NSString *)key
                                 done:(XXCacheQueryCompletedBlock)doneBlock;
- (NSOperation *)queryDiskCacheForKey:(NSString *)key
                            withGroup:(NSString *)group
                                 done:(XXCacheQueryCompletedBlock)doneBlock;

//
- (BOOL)diskCacheDataExistsForKey:(NSString *)key;
- (BOOL)diskCacheDataExistsForKey:(NSString *)key withGroup:(NSString *)group;

//
- (NSData *)cachedDataFromMemoryForKey:(NSString *)key;
- (NSData *)cachedDataFromDiskForKey:(NSString *)key;
- (NSData *)cachedDataFromDiskForKey:(NSString *)key withGroup:(NSString *)group;

//
- (NSDate *)lastModifyDateOfCacheDataForKey:(NSString *)key;
- (NSDate *)lastModifyDateOfCacheDataForKey:(NSString *)key withGroup:(NSString *)group;

//
- (void)removeCachedDataForKey:(NSString *)key;
- (void)removeCachedDataForKey:(NSString *)key fromDisk:(BOOL)fromDisk;
- (void)removeCachedDataForKey:(NSString *)key withGroup:(NSString *)group fromDisk:(BOOL)fromDisk;
- (void)removeCachedDataFromDiskForGroup:(NSString *)group;

//
- (void)clearMemory;
- (void)clearDiskOnCompletion:(void (^)())completion;
- (void)clearDisk;

//
- (void)cleanDisk;
- (void)cleanDiskWithCompletionBlock:(void (^)())completion;
- (void)backgroundCleanDisk;

//
- (NSUInteger)getSize;
- (NSUInteger)getDiskCount;
- (void)calculateSizeWithCompletionBlock:(void (^)(NSUInteger fileCount, NSUInteger totalSize))completion;

@end
