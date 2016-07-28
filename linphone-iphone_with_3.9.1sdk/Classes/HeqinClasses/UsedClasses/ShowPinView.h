//
//  ShowInviteView.h
//  linphone
//
//  Created by baidu on 15/12/19.
//
//

#import <UIKit/UIKit.h>

typedef void(^pinConfirmBlock)(NSString *text);
typedef void(^pinCancelBlock)();
typedef void(^noContentInput)();

@interface ShowPinView : UIView

+ (ShowPinView *)showTitle:(NSString *)title withDoneBlock:(pinConfirmBlock)doneBlock withCancelBlock:(pinCancelBlock)cancelBlock withNoInput:(noContentInput)noContent;

@end
