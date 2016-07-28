//
//  MTLModel+RDRNilForBasedataType.m
//  RedDrive
//
//  Created by heqin on 15/8/20.
//  Copyright (c) 2015年 Wunelli. All rights reserved.
//

#import "MTLModel+RDRNilForBasedataType.h"

@implementation MTLModel (RDRNilForBasedataType)

- (void)setNilValueForKey:(NSString *)key {
    [self setValue:@(0) forKey:key];
}

@end
