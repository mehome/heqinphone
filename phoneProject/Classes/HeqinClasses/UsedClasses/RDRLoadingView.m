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

@end

@implementation RDRLoadingView

+ (RDRLoadingView *)showLoadingWithTitle:(NSString *)title inFrame:(CGRect)frame {
    RDRLoadingView *loadingView = [[RDRLoadingView alloc] initWithFrame:frame];
    loadingView.backgroundColor = [UIColor lightGrayColor];

    loadingView.tipLabel.text = title;
    [loadingView.indicatorView startAnimating];
    
    [loadingView updateLoadingFrameAndReset];
    
    return loadingView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self addSubview:_indicatorView];
        
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_tipLabel];
    }
    
    return self;
}

#define offsetX 10

- (void)updateLoadingFrameAndReset {
    self.indicatorView.frame = CGRectMake(0, 0, 40, 40);
    self.tipLabel.frame = CGRectMake(0, 0, self.ott_width, 30);
    
    self.indicatorView.center = CGPointMake(self.ott_width/2.0, self.ott_height/2.0);
    self.tipLabel.ott_top = self.indicatorView.ott_bottom + 10;
    
    [self.indicatorView startAnimating];
}

- (void)resetTipStr:(NSString *)tipStr {
    self.tipLabel.text = tipStr;
}

@end
