//
//  GAVideoPlayVC.h
//  GetArts
//
//  Created by yoever on 14-9-13.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

#define space 10.f


typedef enum{
    directionPortrait,
    directionLandLeft,
    directionLandRight
}ViewDirection;


// 该播放器仅支持ios 7.0及以上版本
@interface GAVideoPlayVC : UIViewController

- (void)showTitle:(NSString *)title andUrlStr:(NSString *)urlstr;

@end
