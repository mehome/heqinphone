//
//  HQPlayerViewController.h
//  AVPlayer
//
//  Created by ClaudeLi on 16/4/13.
//  Copyright © 2016年 ClaudeLi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HQVideoPlayer.h"

@interface HQPlayerViewController : UIViewController


- (void)specifyTitle:(NSString *)title andMediaUrlStr:(NSString *)urlStr;

+ (void)playMovieWithTitle:(NSString *)title mediaUrlStr:(NSString *)urlStr;

@end
