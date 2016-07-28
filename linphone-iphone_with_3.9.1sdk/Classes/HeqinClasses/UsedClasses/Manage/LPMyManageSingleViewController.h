//
//  LPMyManageSingleViewController.h
//  linphone
//
//  Created by baidu on 15/11/16.
//
//

#import <UIKit/UIKit.h>
#import "UICompositeViewController.h"
#import "RDRJoinMeetingModel.h"

@interface LPMyManageSingleViewController : UIViewController <UICompositeViewDelegate>

- (void)updateWithModel:(RDRJoinMeetingModel *)model;

@end
