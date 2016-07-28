//
//  RDRAllJoinersView.h
//  linphone
//
//  Created by baidu on 15/12/20.
//
//

#import <UIKit/UIKit.h>

typedef void(^postInfoBlock)(NSString *text);

@interface RDRAllJoinersView : UIView

+ (void)showTableTitle:(NSString *)title withPostBlock:(postInfoBlock)postBlock;

@end
