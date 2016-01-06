//
//  LPPhoneListView.m
//  linphone
//
//  Created by baidu on 16/1/6.
//
//

#import "LPPhoneListView.h"
#import "UIView+Frame.h"

typedef void(^joinMeetingBlock)(NSString *sipAddr);

@interface LPPhoneListView () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UITextField *searchTextField;

@property (nonatomic, strong) UIView *redBarView;       // 红色条而已， 用来显示当前处于企业通讯录还是私人通讯录

@property (nonatomic, strong) UITableView *companyTableView;
@property (nonatomic, strong) UITableView *privateTableView;
@property (nonatomic, strong) UITableView *searchTableView;

@property (nonatomic, strong) NSMutableArray *companyPhoneList;
@property (nonatomic, strong) NSMutableArray *privatePhoneList;
@property (nonatomic, strong) NSMutableArray *searchPhoneList;

@property (nonatomic, strong) UIButton *confirmBtn;
@property (nonatomic, strong) UIButton *cancelBtn;

@property (nonatomic, assign) NSInteger forJoinMeeting;     // 1:用于加入会议界面, 0:用于安排会议界面

@end

@implementation LPPhoneListView

+ (instancetype)phoneListForJoinMeeting:(CGRect)frame withBlock:(joinMeetingBlock)block {
    LPPhoneListView *listView = [[LPPhoneListView alloc] initWithFrame:frame];
    listView.forJoinMeeting = 1;
    return listView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 44)];
        _searchTextField.delegate = self;
        [self addSubview:_searchTableView];
        
        UIImageView *topBtnsBgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, _searchTextField.ott_bottom, _searchTextField.ott_width, 44)];
        topBtnsBgImgView.image = [UIImage imageNamed:@"navbarBg"];
        topBtnsBgImgView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:topBtnsBgImgView];
        
        UIButton *companyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        companyBtn.frame = CGRectMake(0, topBtnsBgImgView.ott_bottom, topBtnsBgImgView.ott_width/2.0, topBtnsBgImgView.ott_height);
        [companyBtn setTitle:@"企业通讯录" forState:UIControlStateNormal];
        [companyBtn addTarget:self action:@selector(companyBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:companyBtn];
        
        UIButton *privateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        privateBtn.frame = CGRectMake(topBtnsBgImgView.ott_width/2.0, topBtnsBgImgView.ott_bottom, topBtnsBgImgView.ott_width/2.0, topBtnsBgImgView.ott_height);
        [privateBtn setTitle:@"私人通讯录" forState:UIControlStateNormal];
        [privateBtn addTarget:self action:@selector(privateBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:privateBtn];

        _redBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, companyBtn.ott_width, 4)];
        _redBarView.ott_bottom = companyBtn.ott_bottom;
        _redBarView.backgroundColor = [UIColor redColor];
        [self addSubview:_redBarView];
        
        _companyTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _redBarView.ott_bottom, frame.size.width, frame.size.height-_redBarView.ott_bottom) style:UITableViewStylePlain];
        _companyTableView.delegate = self;
        _companyTableView.dataSource = self;
        [self addSubview:_companyTableView];
        
        _privateTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _redBarView.ott_bottom, frame.size.width, frame.size.height-_redBarView.ott_bottom) style:UITableViewStylePlain];
        _privateTableView.dataSource = self;
        _privateTableView.delegate = self;
        _privateTableView.hidden = YES;
        [self addSubview:_privateTableView];
        
        _searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _redBarView.ott_bottom, frame.size.width, frame.size.height-_redBarView.ott_bottom) style:UITableViewStylePlain];
        _searchTableView.dataSource = self;
        _searchTableView.delegate = self;
        _searchTableView.hidden = YES;
        [self addSubview:_searchTableView];
        
        _companyPhoneList = [NSMutableArray array];
        _privatePhoneList = [NSMutableArray array];
        _searchPhoneList = [NSMutableArray array];
        
        _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmBtn.frame = CGRectMake(10, frame.size.height-44, frame.size.width/2.0-5, 40);
        _confirmBtn.backgroundColor = yellowSubjectColor;
        [_confirmBtn addTarget:self action:@selector(confirmBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        _confirmBtn.layer.cornerRadius = 5;
        _confirmBtn.clipsToBounds = YES;
        _confirmBtn.hidden = YES;
        
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.frame = CGRectMake(frame.size.width/2.0+5, frame.size.height-44, frame.size.width/2.0-5, 40);
        _cancelBtn.backgroundColor = yellowSubjectColor;
        [_cancelBtn addTarget:self action:@selector(cancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        _cancelBtn.layer.cornerRadius = 5;
        _cancelBtn.clipsToBounds = YES;
        _cancelBtn.hidden = YES;
    }
    
    return self;
}

- (void)setForJoinMeeting:(NSInteger)type {
    _forJoinMeeting = type;
    
    [self setNeedsLayout];  // 重新布局
}

- (void)companyBtnClicked:(id)sender {
    [self moveRedBarToLeft:YES];
    
    self.companyTableView.hidden = NO;
    self.privateTableView.hidden = YES;
    self.searchTableView.hidden = YES;
}

- (void)privateBtnClicked:(id)sender {
    [self moveRedBarToLeft:NO];
    
    self.companyTableView.hidden = YES;
    self.privateTableView.hidden = NO;
    self.searchTableView.hidden = YES;

}

- (void)moveRedBarToLeft:(BOOL)toLeft {
    if (toLeft == YES) {
        [UIView animateWithDuration:0.3 animations:^{
            self.redBarView.ott_left = 0.0;
        } completion:^(BOOL finished) {
            self.redBarView.ott_left = 0.0;
        }];
    }else {
        [UIView animateWithDuration:0.3 animations:^{
            self.redBarView.ott_left = self.companyTableView.ott_width/2.0;;
        } completion:^(BOOL finished) {
            self.redBarView.ott_left = self.companyTableView.ott_width/2.0;;
        }];
    }
}

- (void)confirmBtnClicked:(id)sender {
    // 确定按钮
    
}

- (void)cancelBtnClicked:(id)sender {
    // 取消按钮
    
}

- (void)layoutSubviews {
    // 隐藏底部的确定和取消按钮
    // 同时控制TableView的高度
    if (self.forJoinMeeting == 1) {
        self.confirmBtn.hidden = YES;
        self.cancelBtn.hidden = YES;
        
        self.companyTableView.ott_height = self.ott_height - self.companyTableView.ott_top;
        self.privateTableView.ott_height = self.ott_height - self.privateTableView.ott_height;
        self.searchTableView.ott_height = self.ott_height - self.searchTableView.ott_height;
    }else {
        // 显示底部的确定和取消按钮
        self.confirmBtn.hidden = NO;
        self.cancelBtn.hidden = NO;
        
        self.companyTableView.ott_height = self.confirmBtn.ott_top - self.companyTableView.ott_top;
        self.privateTableView.ott_height = self.confirmBtn.ott_top - self.privateTableView.ott_height;
        self.searchTableView.ott_height = self.confirmBtn.ott_top - self.searchTableView.ott_height;
    }
}


@end
