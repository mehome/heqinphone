//
//  RDRLoadingView.m
//  linphone
//
//  Created by baidu on 15/12/20.
//
//

#import "RDRLoadingView.h"

@interface RDRLoadingView ()

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UILabel *tipLabel;

@property (nonatomic, strong) UILabel *cancelLabel;

@property (nonatomic, assign) BOOL touchCloseSelf;

@end

@implementation RDRLoadingView

+ (void)showLoadingWithTitle:(NSString *)title canBeCanceld:(BOOL)cancel inFrame:(CGRect)frame {
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

}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self addSubview:_indicatorView];
        
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_tipLabel];
        
        _cancelLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _cancelLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_cancelLabel];
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgTapped:)]];
        
        _touchCloseSelf = NO;
    }
    
    return self;
}

- (void)bgTapped:(UITapGestureRecognizer *)tapped {
    if (self.touchCloseSelf == YES) {
        UIView *bgView = [self.rd_userInfo objectForKey:@"bgView"];
        if ([bgView isKindOfClass:[UIView class]] && bgView != nil) {
            [bgView removeFromSuperview];
        }
        [self removeFromSuperview];
    }
}


#define offsetX 10

- (void)updateFrameAndReset {
    self.indicatorView.frame = CGRectMake(offsetX, offsetX, self.ott_width - 2 * offsetX, 40);
    
    self.tipLabel.frame = CGRectMake(offsetX, self.tipLabel.ott_bottom, self.tipLabel.ott_width, 30);
    
    self.cancelLabel.frame = CGRectMake(offsetX, self.tipLabel.ott_bottom + offsetX, (self.tipLabel.ott_width - offsetX)/2.0, 40);
}

@end
