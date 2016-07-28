//
//  RDRDBHelper.m
//  RedDrive
//
//  Created by heqin on 15/8/19.
//  Copyright (c) 2015年 Wunelli. All rights reserved.
//

#import "RDRDBHelper.h"
#import "FMDB.h"

@interface RDRDBHelper ()



@end

@implementation RDRDBHelper

- (id)initDefaultHelper
{
    if (self = [super init]) {
        // 判断是否已经存在表，不存在则进行创建
        NSString* docsdir = [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *dbPath = [docsdir stringByAppendingPathComponent:@"xinan.sqlite"];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:dbPath] == YES) {
            // 存在这个表
        }else {
            // 不存在这个表，执行创建表的语句
            // TODO
        }
        
        // 创建db， 如果这个db没有的话
        if (!self.dbQueue) {
            self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
        }
        
        // 先打开DB
        if (![self.dbQueue openFlags]) {
            NSLog(@"数据库打开失败， 请检查");
            return nil;
        }
    }
    
    return self;
}

+ (instancetype)defaultHelper
{
    static RDRDBHelper *__helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __helper = [[self alloc] initDefaultHelper];
    });
    return __helper;
}

@end
