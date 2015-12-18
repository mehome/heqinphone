//
//  ShowLoginView.m
//  linphone
//
//  Created by baidu on 15/12/19.
//
//

#import "ShowLoginView.h"

@interface ShowLoginView () <UITextFieldDelegate>

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *pwdLabel;

@property (nonatomic, strong) UITextField *nameField;
@property (nonatomic, strong) UITextField *pwdField;

@property (nonatomic, strong) UIButton *forgetBtn;
@property (nonatomic, strong) UIButton *loginBtn;

@end

@implementation ShowLoginView

+ (void)showLogin:

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _pwdLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:_nameLabel];
        [self addSubview:_pwdLabel];
        
        _nameField = [[UITextField alloc] initWithFrame:CGRectZero];
        _nameField.delegate = self;
        _nameField.placeholder = @"请输入用户名";
        
        _pwdField = [[UITextField alloc] initWithFrame:CGRectZero];
        _pwdField.delegate = self;
        _pwdField.placeholder = @"请输入密码";
        [self addSubview:_nameField];
        [self addSubview:_pwdField];
        
        _forgetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _forgetBtn.backgroundColor = [UIColor blueColor];
        [_forgetBtn setTitle:@"忘记密码" forState:UIControlStateNormal];
        [_forgetBtn addTarget:self action:@selector(forgetClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_forgetBtn];
        
        _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _loginBtn.backgroundColor = [UIColor grayColor];
        [_loginBtn setTitle:@"登录" forState:UIControlStateNormal];
        [_loginBtn addTarget:self action:@selector(loginClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_loginBtn];
    }
    
    return self;
}

- (void)replaceAllControls {
    
}

- (void)forgetClicked:(UIButton *)sender {

}

- (void)loginClicked:(UIButton *)sender {

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
