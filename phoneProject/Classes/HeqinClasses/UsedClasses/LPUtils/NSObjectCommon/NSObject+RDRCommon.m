//
//  NSObject+RDRCommon.m
//  RedDrive
//
//  Created by YuDejian on 15/2/23.
//  Copyright (c) 2015年 Wunelli. All rights reserved.
//

#import "NSObject+RDRCommon.h"
#import <objc/runtime.h>


@implementation NSObject (RDRCommon)

-(void)setRd_userInfo:(NSDictionary *)newUserInfo_Ext
{
    objc_setAssociatedObject(self, @"rd_userInfo", newUserInfo_Ext, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(id)rd_userInfo
{
    return objc_getAssociatedObject(self, @"rd_userInfo");
}



@end
