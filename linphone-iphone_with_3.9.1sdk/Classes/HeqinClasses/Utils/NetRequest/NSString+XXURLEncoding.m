//
//  NSString+XXURLEncoding.m
//  SpecialXX
//
//  Created by Richie Liu on 14-4-9.
//  Copyright (c) 2014年. All rights reserved.
//

#import "NSString+XXURLEncoding.h"

@implementation NSString (XXURLEncoding)

- (NSString *)URLEncodedString
{
	__autoreleasing NSString *encodedString;
	NSString *originalString = (NSString *)self;
	encodedString = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
	        NULL,
	        (__bridge CFStringRef)originalString,
	        NULL,
	        (CFStringRef)@":!*();@/&?#[]+$,='%’\"",
	        kCFStringEncodingUTF8
	        );
	return encodedString;
}

- (NSString *)URLDecodedString
{
	__autoreleasing NSString *decodedString;
	NSString *originalString = (NSString *)self;
	decodedString = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
	        NULL,
	        (__bridge CFStringRef)originalString,
	        CFSTR(""),
	        kCFStringEncodingUTF8
	        );
	return decodedString;
}

@end
