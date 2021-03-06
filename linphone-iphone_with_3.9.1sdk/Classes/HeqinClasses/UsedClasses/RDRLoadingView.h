//
//  RDRLoadingView.h
//  linphone
//
//  Created by baidu on 15/12/20.
//
//

#import <UIKit/UIKit.h>

@interface RDRLoadingView : UIView

+ (RDRLoadingView *)showLoadingWithTitle:(NSString *)title inFrame:(CGRect)frame;

- (void)resetTipStr:(NSString *)tipStr;
- (void)updateLoadingFrameAndReset;

@end
