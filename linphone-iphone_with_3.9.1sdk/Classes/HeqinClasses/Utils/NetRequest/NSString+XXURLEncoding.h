//
//  NSString+XXURLEncoding.h
//  SpecialXX
//
//  Created by Richie Liu on 14-4-9.
//  Copyright (c) 2014年. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (XXURLEncoding)

- (NSString *)URLEncodedString;
- (NSString *)URLDecodedString;

@end
