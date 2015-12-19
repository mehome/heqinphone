//
//  ShowInviteView.m
//  linphone
//
//  Created by baidu on 15/12/19.
//
//

#import "ShowInviteView.h"

@interface ShowInviteView () <UITextFieldDelegate>

@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UITextField *inputField;

@end

@implementation ShowInviteView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:_tipLabel];
        
        _inputField = [[UITextField alloc] initWithFrame:CGRectZero];
        [self addSubview:_inputField];
    }
    
    return self;
}

+ (void)showWithType:(NSInteger)typeInt {
    
    UIView *bgView = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    bgView.backgroundColor = [UIColor grayColor];
    bgView.alpha = 0.5;
    
    [[UIApplication sharedApplication].keyWindow addSubview:bgView];
    
    ShowInviteView *inviteView = [[ShowInviteView alloc] initWithFrame:<#(CGRect)#>];
}

#pragma mark UITextField delegate
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


@end
