//
//  ShowInviteView.h
//  linphone
//
//  Created by baidu on 15/12/19.
//
//

#import <UIKit/UIKit.h>

typedef void(^inviteConfirmBlock)(NSString *text);
typedef void(^inviteCancelBlock)();
typedef void(^noContentInput)();

@interface ShowInviteView : UIView

+ (void)showWithType:(NSInteger)typeInt withDoneBlock:(inviteConfirmBlock)doneBlock withCancelBlock:(inviteCancelBlock)cancelBlock withNoInput:(noContentInput)noContent;

@end
