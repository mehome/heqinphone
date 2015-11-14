//
//  NSDictionary+XXQueryString.h
//  SpecialXX
//
//  Created by Richie Liu on 14-4-9.
//  Copyright (c) 2014年. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (XXQueryString)

+ (NSDictionary *)dictionaryWithQueryString:(NSString *)queryString;
- (NSString *)queryStringValue;
- (NSString *)sortedQuerayString;


@end
