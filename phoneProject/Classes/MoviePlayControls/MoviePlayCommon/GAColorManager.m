//
//  GAColorManager.m
//  GetArts
//
//  Created by mac on 14-8-7.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import "GAColorManager.h"
#import "Resource_Color.h"

@implementation UIBarButtonItem (GaiYiBlue)

-(void)gaiyiBlue
{
    NSDictionary* textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:[GAColorManager gaiyiBlue],NSForegroundColorAttributeName, nil];
    [self setTitleTextAttributes:textAttributes forState:0];
}
@end

@implementation GAColorManager
+(UIColor*)gaiyiBlue
{
    return GetColorFromCSSHex(@"#00aeca");
}

@end
