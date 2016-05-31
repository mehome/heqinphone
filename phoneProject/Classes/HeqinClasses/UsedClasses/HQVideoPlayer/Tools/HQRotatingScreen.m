//
//  HQRotatingScreen.m
//  tiaooo
//
//  Created by ClaudeLi on 16/3/31.
//  Copyright © 2016年 dali. All rights reserved.
//

#import "HQRotatingScreen.h"

@implementation HQRotatingScreen

/**
 *  下面这种方式来强制横竖屏，效果非常好。
 *
 *  @param orientation
 */
+ (void)forceOrientation: (UIInterfaceOrientation)orientation {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget: [UIDevice currentDevice]];
        int val = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

+ (BOOL)isOrientationLandscape {
    //if (UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation])) {
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        return YES;
    } else {
        return NO;
    }
}

@end
