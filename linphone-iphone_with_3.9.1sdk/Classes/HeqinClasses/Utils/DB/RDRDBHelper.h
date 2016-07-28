//
//  RDRDBHelper.h
//  RedDrive
//
//  Created by heqin on 15/8/19.
//  Copyright (c) 2015年 Wunelli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@interface RDRDBHelper : NSObject

@property (nonatomic, strong) FMDatabaseQueue *dbQueue;     // github上说使用这个queue是多线程安全的，推荐使用

+ (instancetype)defaultHelper;

@end
