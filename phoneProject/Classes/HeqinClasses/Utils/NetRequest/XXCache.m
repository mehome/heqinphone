//
//  XXCache.m
//  SpecialXX
//
//  Created by heqin on 15-3-9.
//  Copyright (c) 2015年 heqin. All rights reserved.
//

#import "XXCache.h"
#import <CommonCrypto/CommonDigest.h>

static const NSInteger kBDNDefaultCacheMaxCacheAge = 60 * 60 * 24 * 7; // 1 week
static const NSInteger kBDNDefaultCacheLimitSize = 10 * 1024 * 1024; // 10MB

@interface XXCache ()

@property (nonatomic, retain) NSCache *memoryCache;
@property (nonatomic, copy  ) NSString *diskCachePath;
@property (nonatomic, retain) NSMutableArray *customPaths;
@property (nonatomic, retain) NSFileManager *fileManager;

@property (nonatomic, retain) dispatch_queue_t ioQueue;

//
@property (nonatomic, assign, readwrite) BOOL usingMemoryCache;

@end

@implementation XXCache

- (void)dealloc {
    
    //
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (instancetype)init {
    return [self initWithNamespace:@"Default"];
}


- (instancetype)initWithNamespace:(NSString *)ns {
    return [self initWithNamespace:ns usingMemoryCache:NO];
}


- (instancetype)initWithNamespace:(NSString *)ns
                 usingMemoryCache:(BOOL)usingMemoryCache {
    
    if (self = [super init]) {
        
        //
        NSString *fullNamespace = [@"COM.XX.Cache." stringByAppendingString:ns];
        
        // Create IO serial queue
        self.ioQueue = dispatch_queue_create("com.xx.cache_ioQueue", DISPATCH_QUEUE_SERIAL);
        
        //
        self.maxCacheAge = kBDNDefaultCacheMaxCacheAge;
        self.maxCacheSize = kBDNDefaultCacheLimitSize;
        self.usingMemoryCache = usingMemoryCache;
        
        // Init the memory cache
        if (self.usingMemoryCache) {
            self.memoryCache = [[NSCache alloc] init];
            self.memoryCache.name = fullNamespace;
        }
        
        // Init the disk cache
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        self.diskCachePath = [paths[0] stringByAppendingPathComponent:fullNamespace];
        
        dispatch_sync(self.ioQueue, ^{
            self.fileManager = [[NSFileManager alloc] init];
        });
        
        //
#if TARGET_OS_IPHONE
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(backgroundCleanDisk)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        
#endif
        
        //
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearMemory)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    
    return self;
}


#pragma mark -
#pragma mark Property

- (void)setMaxMemoryCost:(NSUInteger)maxMemoryCost {
    self.memoryCache.totalCostLimit = maxMemoryCost;
}


- (NSUInteger)maxMemoryCost {
    return self.memoryCache.totalCostLimit;
}


#pragma mark -
#pragma mark Cache File Path

- (NSString *)cachePathForKey:(NSString *)key inPath:(NSString *)path {
    return [self cachePathForKey:key inPath:path withGroup:nil];
}


- (NSString *)cachePathForGroup:(NSString *)group inPath:(NSString *)path {
    if (path != nil) {
        return [path stringByAppendingPathComponent:group];
    }
    return nil;
}


- (NSString *)cachePathForKey:(NSString *)key inPath:(NSString *)path withGroup:(NSString *)group {
    NSString *fileName = [self cachedFileNameForKey:key];
    if (group != nil) {
        return [[path stringByAppendingPathComponent:group] stringByAppendingPathComponent:fileName];
    } else {
        return [path stringByAppendingPathComponent:fileName];
    }
}


- (NSString *)defaultCachePathForKey:(NSString *)key {
    return [self defaultCachePathForKey:key withGroup:nil];
}


- (NSString *)defaultCachePathForGroup:(NSString *)group {
    return [self cachePathForGroup:group inPath:self.diskCachePath];
}


- (NSString *)defaultCachePathForKey:(NSString *)key withGroup:(NSString *)group {
    return [self cachePathForKey:key inPath:self.diskCachePath withGroup:group];
}


- (NSString *)cachedFileNameForKey:(NSString *)key {
    const char *str = [key UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    
    return filename;
}


#pragma mark -
#pragma mark Data Store

- (void)storeCachedData:(NSData *)data forKey:(NSString *)key {
    [self storeCachedData:data forKey:key withGroup:nil];
}


- (void)storeCachedData:(NSData *)data forKey:(NSString *)key withGroup:(NSString *)group {
    [self storeCachedData:data forKey:key withGroup:group toDisk:YES];
}


- (void)storeCachedData:(NSData *)data forKey:(NSString *)key toDisk:(BOOL)toDisk {
    [self storeCachedData:data forKey:key withGroup:nil toDisk:toDisk];
}


- (void)storeCachedData:(NSData *)data forKey:(NSString *)key withGroup:(NSString *)group toDisk:(BOOL)toDisk {
    
    if (!data || !key) {
        return;
    }
    
    [self.memoryCache setObject:data forKey:key];
    
    if (toDisk) {
        dispatch_async(self.ioQueue, ^{
            if (data) {
                if (![self.fileManager fileExistsAtPath:self.diskCachePath]) {
                    [self.fileManager createDirectoryAtPath:self.diskCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
                }
                if (group != nil) {
                    NSString *groupPath = [self defaultCachePathForGroup:group];
                    if (![self.fileManager fileExistsAtPath:groupPath]) {
                        [self.fileManager createDirectoryAtPath:groupPath withIntermediateDirectories:YES attributes:nil error:NULL];
                    }
                }
                [self.fileManager createFileAtPath:[self defaultCachePathForKey:key withGroup:group] contents:data attributes:nil];
            }
        });
    }
}


#pragma mark -
#pragma mark Data Read

- (BOOL)diskCacheDataExistsForKey:(NSString *)key {
    return [self diskCacheDataExistsForKey:key withGroup:nil];
}

// Toheqin, 这里看起来有问题， 因为没有使用group进行拼凑路径再进行查询， 而只是查询了默认的路径
- (BOOL)diskCacheDataExistsForKey:(NSString *)key withGroup:(NSString *)group {
    __block BOOL exists = NO;
    dispatch_sync(self.ioQueue, ^{
//        exists = [self.fileManager fileExistsAtPath:[self defaultCachePathForKey:key]];       // 原来的代码是这样的
        exists = [self.fileManager fileExistsAtPath:[self defaultCachePathForKey:key withGroup:group]];
    });
    return exists;
}


- (NSOperation *)queryDiskCacheForKey:(NSString *)key
                                 done:(XXCacheQueryCompletedBlock)doneBlock {
    
    return [self queryDiskCacheForKey:key withGroup:nil done:doneBlock];
}


- (NSOperation *)queryDiskCacheForKey:(NSString *)key
                            withGroup:(NSString *)group
                                 done:(XXCacheQueryCompletedBlock)doneBlock {
    
    NSOperation *operation = [NSOperation new];
    
    if (!doneBlock) return nil;
    
    if (!key) {
        doneBlock(nil, XXCacheTypeNone); return nil;
    }
    
    // First check the in-memory cache...
    NSData *data = [self cachedDataFromMemoryForKey:key];
    if (data) {
        doneBlock(data, XXCacheTypeMemory); return nil;
    }
    
    dispatch_async(self.ioQueue, ^{
        
        if (operation.isCancelled) {
            return;
        }
        
        @autoreleasepool {
            
            NSData *diskData = [self cachedDataFromDiskForKey:key withGroup:group];
            
            if (diskData) {
                [self.memoryCache setObject:diskData forKey:key];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                doneBlock(diskData, XXCacheTypeDisk);
            });
        }
    });
    
    return operation;
}


- (NSData *)cachedDataFromMemoryForKey:(NSString *)key {
    return [self.memoryCache objectForKey:key];
}


- (NSData *)cachedDataFromDiskForKey:(NSString *)key {
    return [self cachedDataFromDiskForKey:key withGroup:nil];
}


- (NSData *)cachedDataFromDiskForKey:(NSString *)key withGroup:(NSString *)group {
    return [NSData dataWithContentsOfFile:[self defaultCachePathForKey:key withGroup:group]];
}


#pragma mark -
#pragma mark Cache data last modify time

//
- (NSDate *)lastModifyDateOfCacheDataForKey:(NSString *)key {
    return [self lastModifyDateOfCacheDataForKey:key withGroup:nil];
}


- (NSDate *)lastModifyDateOfCacheDataForKey:(NSString *)key withGroup:(NSString *)group {
    __block NSDate *lastModify = nil;
    dispatch_sync(self.ioQueue, ^{
        NSString *filePath = [self defaultCachePathForKey:key withGroup:group];
        if (filePath != nil) {
            NSDictionary *attrs = [self.fileManager attributesOfItemAtPath:filePath error:nil];
            // 判断数据是否异常
            if ([attrs fileSize] > 0) {
                lastModify = [attrs fileModificationDate];
            }
        }
    });
    return lastModify;
}


#pragma mark -
#pragma mark Cache Remove

- (void)removeCachedDataForKey:(NSString *)key {
    [self removeCachedDataForKey:key fromDisk:YES];
}


- (void)removeCachedDataForKey:(NSString *)key fromDisk:(BOOL)fromDisk {
    [self removeCachedDataForKey:key withGroup:nil fromDisk:fromDisk];
    
}


- (void)removeCachedDataForKey:(NSString *)key withGroup:(NSString *)group fromDisk:(BOOL)fromDisk {
    
    if (key == nil) {
        return;
    }
    
    [self.memoryCache removeObjectForKey:key];
    
    //
    if (fromDisk) {
        dispatch_async(self.ioQueue, ^{
            [self.fileManager removeItemAtPath:[self defaultCachePathForKey:key withGroup:group] error:nil];
        });
    }
}


- (void)removeCachedDataFromDiskForGroup:(NSString *)group {
    
    if (group == nil) {
        return;
    }
    
    dispatch_async(self.ioQueue, ^{
        [self.fileManager removeItemAtPath:[self defaultCachePathForGroup:group] error:nil];
    });
}


#pragma mark -
#pragma mark Cache Clear

- (void)clearMemory {
    [self.memoryCache removeAllObjects];
}


- (void)clearDisk {
    [self clearDiskOnCompletion:NULL];
}


- (void)clearDiskOnCompletion:(void (^)())completion {
    dispatch_async(self.ioQueue, ^{
        [self.fileManager removeItemAtPath:self.diskCachePath error:nil];
        [self.fileManager createDirectoryAtPath:self.diskCachePath
                    withIntermediateDirectories:YES
                                     attributes:nil
                                          error:NULL];
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
}


#pragma mark -
#pragma mark Cache Clean

- (void)cleanDisk {
    [self cleanDiskWithCompletionBlock:nil];
}


- (void)cleanDiskWithCompletionBlock:(void (^)())completion {
    
    dispatch_async(self.ioQueue, ^{
        
        //
        NSURL *diskCacheURL = [NSURL fileURLWithPath:self.diskCachePath isDirectory:YES];
        NSArray *resourceKeys = @[NSURLIsDirectoryKey, NSURLContentModificationDateKey, NSURLTotalFileAllocatedSizeKey];
        
        // This enumerator prefetches useful properties for our cache files.
        NSDirectoryEnumerator *fileEnumerator = [self.fileManager enumeratorAtURL:diskCacheURL
                                                       includingPropertiesForKeys:resourceKeys
                                                                          options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                     errorHandler:NULL];
        
        NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-self.maxCacheAge];
        NSMutableDictionary *cacheFiles = [NSMutableDictionary dictionary];
        NSUInteger currentCacheSize = 0;
        
        // Enumerate all of the files in the cache directory.  This loop has two purposes:
        //
        //  1. Removing files that are older than the expiration date.
        //  2. Storing file attributes for the size-based cleanup pass.
        for (NSURL *fileURL in fileEnumerator) {
            
            //
            NSDictionary *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:NULL];
            
            // Remove files that are older than the expiration date; include directories (cache group)
            NSDate *modificationDate = resourceValues[NSURLContentModificationDateKey];
            if ([[modificationDate laterDate:expirationDate] isEqualToDate:expirationDate]) {
                [self.fileManager removeItemAtURL:fileURL error:nil];
                continue;
            }
            
            // Skip directories.
            if ([resourceValues[NSURLIsDirectoryKey] boolValue]) {
                continue;
            }
            
            // Store a reference to this file and account for its total size.
            NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
            currentCacheSize += [totalAllocatedSize unsignedIntegerValue];
            [cacheFiles setObject:resourceValues forKey:fileURL];
        }
        
        // If our remaining disk cache exceeds a configured maximum size, perform a second
        // size-based cleanup pass.  We delete the oldest files first.
        if (self.maxCacheSize > 0 && currentCacheSize > self.maxCacheSize) {
            // Target half of our maximum cache size for this cleanup pass.
            const NSUInteger desiredCacheSize = self.maxCacheSize / 2;
            
            // Sort the remaining cache files by their last modification time (oldest first).
            NSArray *sortedFiles = [cacheFiles keysSortedByValueWithOptions:NSSortConcurrent
                                                            usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                                                return [obj1[NSURLContentModificationDateKey] compare:obj2[NSURLContentModificationDateKey]];
                                                            }];
            
            // Delete files until we fall below our desired cache size.
            for (NSURL *fileURL in sortedFiles) {
                if ([self.fileManager removeItemAtURL:fileURL error:nil]) {
                    NSDictionary *resourceValues = cacheFiles[fileURL];
                    NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
                    currentCacheSize -= [totalAllocatedSize unsignedIntegerValue];
                    
                    if (currentCacheSize < desiredCacheSize) {
                        break;
                    }
                }
            }
        }
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion();
            });
        }
    });
}


- (void)backgroundCleanDisk {
    
    //
    UIApplication *application = [UIApplication sharedApplication];
    __block UIBackgroundTaskIdentifier bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        // Clean up any unfinished task business by marking where you
        // stopped or ending the task outright.
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    // 缓存空间超过限制 清理缓存
    NSUInteger cSize = [self getSize];
    
    if (cSize >= self.maxCacheSize) {
        // Start the long-running task and return immediately.
        [self cleanDiskWithCompletionBlock:^{
            [application endBackgroundTask:bgTask];
            bgTask = UIBackgroundTaskInvalid;
        }];
    }
}


#pragma mark -
#pragma mark Cache Size

- (NSUInteger)getSize {
    
    __block NSUInteger totalSize = 0;
    
    //
    dispatch_sync(self.ioQueue, ^{
        
        NSURL *diskCacheURL = [NSURL fileURLWithPath:self.diskCachePath isDirectory:YES];
        
        NSDirectoryEnumerator *fileEnumerator = [self.fileManager enumeratorAtURL:diskCacheURL
                                                       includingPropertiesForKeys:@[NSFileSize]
                                                                          options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                     errorHandler:NULL];
        
        for (NSURL *fileURL in fileEnumerator) {
            NSNumber *fileSize;
            [fileURL getResourceValue:&fileSize forKey:NSURLFileSizeKey error:NULL];
            totalSize += [fileSize unsignedIntegerValue];
        }
    });
    
    //
    return totalSize;
}


- (NSUInteger)getDiskCount {
    __block NSUInteger count = 0;
    dispatch_sync(self.ioQueue, ^{
        NSDirectoryEnumerator *fileEnumerator = [self.fileManager enumeratorAtPath:self.diskCachePath];
        for (__unused NSString *fileName in fileEnumerator) {
            count += 1;
        }
    });
    return count;
}


- (void)calculateSizeWithCompletionBlock:(void (^)(NSUInteger fileCount, NSUInteger totalSize))completion {
    
    NSURL *diskCacheURL = [NSURL fileURLWithPath:self.diskCachePath isDirectory:YES];
    
    dispatch_async(self.ioQueue, ^{
        
        NSUInteger fileCount = 0;
        NSUInteger totalSize = 0;
        
        NSDirectoryEnumerator *fileEnumerator = [self.fileManager enumeratorAtURL:diskCacheURL
                                                       includingPropertiesForKeys:@[NSFileSize]
                                                                          options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                     errorHandler:NULL];
        
        for (NSURL *fileURL in fileEnumerator) {
            NSNumber *fileSize;
            [fileURL getResourceValue:&fileSize forKey:NSURLFileSizeKey error:NULL];
            totalSize += [fileSize unsignedIntegerValue];
            fileCount += 1;
        }
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(fileCount, totalSize);
            });
        }
    });
}


@end
