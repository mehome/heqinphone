//
//  NSDictionary+XXQueryString.m
//  SpecialXX
//
//  Created by Richie Liu on 14-4-9.
//  Copyright (c) 2014年. All rights reserved.
//

#import "NSDictionary+XXQueryString.h"
#import "NSString+XXURLEncoding.h"

@implementation NSDictionary (XXQueryString)

+ (NSDictionary *)dictionaryWithQueryString:(NSString *)queryString {
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	NSArray *pairs = [queryString componentsSeparatedByString:@"&"];

	for (NSString *pair in pairs) {
		NSArray *elements = [pair componentsSeparatedByString:@"="];
		if (elements.count == 2) {
			NSString *key = elements[0];
			NSString *value = elements[1];
			NSString *decodedKey = [key URLDecodedString];
			NSString *decodedValue = [value URLDecodedString];

			if (![key isEqualToString:decodedKey])
				key = decodedKey;

			if (![value isEqualToString:decodedValue])
				value = decodedValue;

			[dictionary setObject:value forKey:key];
		}
	}

	return [NSDictionary dictionaryWithDictionary:dictionary];
}

- (NSString *)queryStringValue {
	NSMutableArray *pairs = [NSMutableArray array];
	for (NSString *key in[self keyEnumerator]) {
		id value = [self objectForKey:key];
		NSString *escapedValue = [value URLEncodedString];
		[pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escapedValue]];
	}

	return [pairs componentsJoinedByString:@"&"];
}

- (NSString *)sortedQuerayString {
    NSMutableArray *pairs = [NSMutableArray array];
    NSMutableArray *allKeys = [[NSMutableArray alloc] initWithArray:[self allKeys]];
    [allKeys sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    for (NSString *key in allKeys) {
        id value = [self objectForKey:key];
        if ([value isKindOfClass:[NSString class]]) {
            value = [value URLEncodedString];
        }
		[pairs addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
    }
    
    return [pairs componentsJoinedByString:@"&"];
}

@end
