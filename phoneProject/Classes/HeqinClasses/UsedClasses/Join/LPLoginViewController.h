//
//  LPLoginViewController.h
//  linphone
//
//  Created by heqin on 15/11/7.
//
//

#import <UIKit/UIKit.h>
#import "UICompositeViewController.h"

@interface LPLoginViewController : UIViewController <UICompositeViewDelegate>

+ (UICompositeViewDescription *)compositeViewDescription;

@end
