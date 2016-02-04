//
//  ShowPinView.m
//  linphone
//
//  Created by baidu on 15/12/19.
//
//

#import "ShowPinView.h"

@interface ShowPinView () <UITextFieldDelegate>

@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UITextField *inputField;

@property (readwrite, nonatomic, copy) pinConfirmBlock confirmDone;
@property (readwrite, nonatomic, copy) pinCancelBlock cancelDone;
@property (readwrite, nonatomic, copy) noContentInput noInput;

@property (nonatomic, strong) UIButton *doneBtn;
@property (nonatomic, strong) UIButton *cancelBtn;

@end

@implementation ShowPinView

+ (ShowPinView *)showTitle:(NSString *)title withDoneBlock:(pinConfirmBlock)doneBlock withCancelBlock:(pinCancelBlock)cancelBlock withNoInput:(noContentInput)noContent {

    UIView *bgView = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    bgView.backgroundColor = [UIColor grayColor];
    bgView.alpha = 0.5;
    
    [[UIApplication sharedApplication].keyWindow addSubview:bgView];
    
    ShowPinView *pinView = [[ShowPinView alloc] initWithFrame:CGRectMake(20, 60, bgView.ott_width-20*2, 130)];
    [[UIApplication sharedApplication].keyWindow addSubview:pinView];
    pinView.backgroundColor = [UIColor whiteColor];
    pinView.layer.cornerRadius = 5.0;
    pinView.rd_userInfo = @{@"bgView":bgView};
    
    pinView.confirmDone = doneBlock;
    pinView.cancelDone = cancelBlock;
    pinView.noInput = noContent;
    
    pinView.inputField.keyboardType = UIKeyboardTypeNumberPad;
    pinView.tipLabel.text = title;
    
    [pinView updateFrameAndReset];
    [pinView.inputField becomeFirstResponder];
    
    return pinView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_tipLabel];
        
        _inputField = [[UITextField alloc] initWithFrame:CGRectZero];
        _inputField.delegate = self;
        _inputField.borderStyle = UITextBorderStyleRoundedRect;
        _inputField.backgroundColor = [UIColor clearColor];
        [self addSubview:_inputField];
        
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.frame = CGRectZero;
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(cancelClicked:) forControlEvents:UIControlEventTouchUpInside];
        _cancelBtn.backgroundColor = [UIColor blueColor];
        _cancelBtn.layer.cornerRadius = 10.0;
        [self addSubview:_cancelBtn];
        
        _doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _doneBtn.frame = CGRectZero;
        [_doneBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_doneBtn addTarget:self action:@selector(doneClicked:) forControlEvents:UIControlEventTouchUpInside];
        _doneBtn.backgroundColor = [UIColor blueColor];
        _doneBtn.layer.cornerRadius = 10.0;
        [self addSubview:_doneBtn];
    }
    
    return self;
}

#define offsetX 10

- (void)updateFrameAndReset {
    self.tipLabel.frame = CGRectMake(offsetX, offsetX, self.ott_width - 2 * offsetX, 40);
    
    self.inputField.frame = CGRectMake(offsetX, self.tipLabel.ott_bottom, self.tipLabel.ott_width, 30);
    
    self.cancelBtn.frame = CGRectMake(offsetX, self.inputField.ott_bottom + offsetX, (self.tipLabel.ott_width - offsetX)/2.0, 40);
    self.doneBtn.frame = CGRectMake(self.cancelBtn.ott_right + offsetX, self.cancelBtn.ott_top, self.cancelBtn.ott_width, self.cancelBtn.ott_height);
    self.ott_height = self.doneBtn.ott_bottom + offsetX;
}

- (void)cancelClicked:(UIButton *)sender {
    if (self.cancelDone != nil) {
        self.cancelDone();
    }
    
    UIView *bgView = [self.rd_userInfo objectForKey:@"bgView"];
    if ([bgView isKindOfClass:[UIView class]] && bgView != nil) {
        [bgView removeFromSuperview];
    }
    [self removeFromSuperview];
}

- (void)doneClicked:(UIButton *)sender {
    NSString *str = [self.inputField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//    if (str.length == 0) {        // 由于他们支持无输入要求，所以这里把无输入的情况也认为是正常的输入.
//        // do nothing.
//        if (self.noInput) {
//            self.noInput();
//            [self.inputField becomeFirstResponder];
//        }
//        return;
//    }else {
        if (self.confirmDone) {
            NSString *contentStr = (str.length == 0) ? @"":str;
            self.confirmDone(contentStr);
        }
//    }
    
    UIView *bgView = [self.rd_userInfo objectForKey:@"bgView"];
    if ([bgView isKindOfClass:[UIView class]] && bgView != nil) {
        [bgView removeFromSuperview];
    }
    [self removeFromSuperview];
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
