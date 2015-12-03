//
//  LPSettingViewController.h
//  linphone
//
//  Created by heqin on 15/11/7.
//
//

#import <UIKit/UIKit.h>
#import "UICompositeViewController.h"

@interface LPSettingViewController : UIViewController <UICompositeViewDelegate>

@property (nonatomic, assign) BOOL fromLoginInterface;      // 从登录界面过来

@end
