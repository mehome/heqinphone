//
//  LPPhoneListView.m
//  linphone
//
//  Created by baidu on 16/1/6.
//
//

#import "LPPhoneListView.h"
#import "UIView+Frame.h"
#import "MJRefresh.h"
// https://github.com/CoderMJLee/MJRefresh

#import "LPSystemUser.h"
#import "RDRRequest.h"
#import "RDRNetHelper.h"

#import "RDRPhoneListCompanyRequestModel.h"
#import "RDRPhoneListPrivateRequestModel.h"
#import "RDRPhoneListSearchRequestModel.h"

#import "RDRPhoneCompanyResponseModel.h"
#import "RDRPhoneModel.h"

#import "UIViewController+RDRTipAndAlert.h"

typedef void(^joinMeetingBlock)(NSString *sipAddr);

typedef void(^requestSucceBlock)();
typedef void(^requestFailBlock)();

@interface LPPhoneListView () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UITextField *searchTextField;

@property (nonatomic, strong) UIImageView *topBtnsBgImgView;
@property (nonatomic, strong) UIButton *companyBtn;
@property (nonatomic, strong) UIButton *privateBtn;
@property (nonatomic, strong) UIView *redBarView;       // 红色条而已， 用来显示当前处于企业通讯录还是私人通讯录

@property (nonatomic, strong) UITableView *companyTableView;
@property (nonatomic, strong) UITableView *privateTableView;
@property (nonatomic, strong) UITableView *searchTableView;

@property (nonatomic, strong) NSMutableArray *companyPhoneList;
@property (nonatomic, strong) NSMutableArray *privatePhoneList;
@property (nonatomic, strong) NSMutableArray *searchPhoneList;

@property (nonatomic, strong) NSMutableArray *selectedCompanyNumbers;
@property (nonatomic, strong) NSMutableArray *selectedPrivateNumbers;
@property (nonatomic, strong) NSMutableArray *selectedSearchNumbers;

@property (nonatomic, assign) NSInteger companyCurPage;
@property (nonatomic, assign) NSInteger companyTotalPage;

@property (nonatomic, assign) NSInteger privateCurPage;
@property (nonatomic, assign) NSInteger privateTotalPage;

@property (nonatomic, strong) UIButton *confirmBtn;
@property (nonatomic, strong) UIButton *cancelBtn;


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
        _searchTextField.borderStyle = UITextBorderStyleRoundedRect;
        _searchTextField.clearButtonMode = UITextFieldViewModeAlways;
        _searchTextField.backgroundColor = [UIColor whiteColor];
        _searchTextField.placeholder = @"请输入名称";
        _searchTextField.delegate = self;
        [self addSubview:_searchTextField];
        
        _topBtnsBgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, _searchTextField.ott_bottom, _searchTextField.ott_width, 44)];
        _topBtnsBgImgView.image = [UIImage imageNamed:@"navbarBg"];
        _topBtnsBgImgView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:_topBtnsBgImgView];
        
        _companyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _companyBtn.frame = CGRectMake(0, _topBtnsBgImgView.ott_bottom, _topBtnsBgImgView.ott_width/2.0, _topBtnsBgImgView.ott_height);
        [_companyBtn setTitle:@"企业通讯录" forState:UIControlStateNormal];
        [_companyBtn addTarget:self action:@selector(companyBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_companyBtn];
        
        _privateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _privateBtn.frame = CGRectMake(_topBtnsBgImgView.ott_width/2.0, _topBtnsBgImgView.ott_bottom, _topBtnsBgImgView.ott_width/2.0, _topBtnsBgImgView.ott_height);
        [_privateBtn setTitle:@"私人通讯录" forState:UIControlStateNormal];
        [_privateBtn addTarget:self action:@selector(privateBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_privateBtn];

        _redBarView = [[UIView alloc] initWithFrame:CGRectMake(0, _companyBtn.ott_bottom-4, _companyBtn.ott_width, 4)];
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
        
        [_companyTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"customCell"];
        [_privateTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"customCell"];
        [_searchTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"customCell"];
        
        _companyPhoneList = [NSMutableArray array];
        _privatePhoneList = [NSMutableArray array];
        _searchPhoneList = [NSMutableArray array];
        
        _selectedCompanyNumbers = [NSMutableArray array];
        _selectedPrivateNumbers = [NSMutableArray array];
        _selectedSearchNumbers = [NSMutableArray array];
        
        _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmBtn.frame = CGRectMake(0, frame.size.height-44, frame.size.width/2.0-5, 40);
        _confirmBtn.backgroundColor = yellowSubjectColor;
        [_confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_confirmBtn addTarget:self action:@selector(confirmBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        _confirmBtn.layer.cornerRadius = 5;
        _confirmBtn.clipsToBounds = YES;
        _confirmBtn.hidden = YES;
        [self addSubview:_confirmBtn];
        
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.frame = CGRectMake(frame.size.width/2.0+5, frame.size.height-44, frame.size.width/2.0-5, 40);
        _cancelBtn.backgroundColor = yellowSubjectColor;
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(cancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        _cancelBtn.layer.cornerRadius = 5;
        _cancelBtn.clipsToBounds = YES;
        _cancelBtn.hidden = YES;
        [self addSubview:_cancelBtn];
        
        _companyCurPage = 1;
        _privateCurPage = 1;
    }
    
    return self;
}

- (void)setForJoinMeeting:(NSInteger)type {
    _forJoinMeeting = type;
    
    [self setNeedsLayout];  // 重新布局
    
    [self resetAllDatas];
}

- (void)companyBtnClicked:(id)sender {
    [self moveRedBarToLeft:YES];
    
    [self.searchTextField resignFirstResponder];
    
    [self.selectedCompanyNumbers removeAllObjects];
    [self.selectedPrivateNumbers removeAllObjects];
    [self.selectedSearchNumbers removeAllObjects];
    
    self.companyTableView.hidden = NO;
    self.privateTableView.hidden = YES;
    self.searchTableView.hidden = YES;
    
    // 准备数据
    __unsafe_unretained LPPhoneListView *weakListView = self;
    if (self.companyPhoneList.count == 0) {
        // 请求数据
        [weakListView requestCompanyPage:weakListView.companyCurPage withSuccessBlock:^{
            // 请求结束后，
            [weakListView.companyTableView reloadData];
            [weakListView.companyTableView.mj_header endRefreshing];
        } withFailBlock:^{
            // 请求结束后，
            [weakListView.companyTableView.mj_header endRefreshing];
        }];
    }else {
        // 直接显示即可
        [weakListView.companyTableView reloadData];
    }
}

- (void)privateBtnClicked:(id)sender {
    [self moveRedBarToLeft:NO];
    
    [self.searchTextField resignFirstResponder];

    [self.selectedCompanyNumbers removeAllObjects];
    [self.selectedPrivateNumbers removeAllObjects];
    [self.selectedSearchNumbers removeAllObjects];

    self.companyTableView.hidden = YES;
    self.privateTableView.hidden = NO;
    self.searchTableView.hidden = YES;

    // 准备数据
    __unsafe_unretained LPPhoneListView *weakListView = self;
    if (self.privatePhoneList.count == 0) {
        // 请求数据
        [weakListView requestPrivatePage:weakListView.privateCurPage withSuccessBlock:^{
            // 请求结束后，
            [weakListView.privateTableView reloadData];
            [weakListView.privateTableView.mj_header endRefreshing];
        } withFailBlock:^{
            // 请求结束后，
            [weakListView.privateTableView.mj_header endRefreshing];
        }];
    }else {
        // 直接显示即可
        [weakListView.privateTableView reloadData];
    }
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
    if (self.forJoinMeeting == 1) {
        [UIViewController showToastWithmessage:@"当前模式不对"];
        return;
    }
    
    if (self.companyTableView.hidden == NO) {
        if (self.selectedCompanyNumbers.count == 0) {
            [UIViewController showToastWithmessage:@"没有选择企业通讯录中的联系人或者设备"];
        }else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kSearchNumbersDatasForArrangeMeeting object:self.selectedCompanyNumbers];
        }
        return;
    }else if (self.privateTableView.hidden == NO) {
        if (self.selectedPrivateNumbers.count == 0) {
            [UIViewController showToastWithmessage:@"没有选择私人通讯录中的联系人或者设备"];
        }else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kSearchNumbersDatasForArrangeMeeting object:self.selectedPrivateNumbers];
        }
        return;
    }else {
        if (self.selectedSearchNumbers.count == 0) {
            [UIViewController showToastWithmessage:@"没有选择联系人或者设备"];
        }else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kSearchNumbersDatasForArrangeMeeting object:self.selectedSearchNumbers];
        }
        return;
    }
}

- (void)cancelBtnClicked:(id)sender {
    // 取消按钮
    [[NSNotificationCenter defaultCenter] postNotificationName:kSearchNumbersDatasForArrangeMeeting object:nil];
}

- (void)layoutSubviews {
    _searchTextField.frame = CGRectMake(0, 0, self.ott_width, 44);
    _topBtnsBgImgView.frame = CGRectMake(0, _searchTextField.ott_bottom, _searchTextField.ott_width, 44);
    _companyBtn.frame = CGRectMake(0, _searchTextField.ott_bottom, _searchTextField.ott_width/2.0, _topBtnsBgImgView.ott_height);
    _privateBtn.frame = CGRectMake(_searchTextField.ott_width/2.0, _searchTextField.ott_bottom, _topBtnsBgImgView.ott_width/2.0, _topBtnsBgImgView.ott_height);

    _redBarView.frame = CGRectMake(0, _companyBtn.ott_bottom-4, _companyBtn.ott_width, 4);

    _confirmBtn.frame = CGRectMake(0, self.ott_height-44, self.ott_width/2.0-5, 40);
    _cancelBtn.frame = CGRectMake(self.ott_width/2.0+5, self.ott_height-44, self.ott_width/2.0-5, 40);
    
    if (self.forJoinMeeting == 1) {
        _confirmBtn.hidden = YES;
        _cancelBtn.hidden = YES;
        
        _companyTableView.frame = CGRectMake(0, _redBarView.ott_bottom, self.ott_width, self.ott_height -_redBarView.ott_bottom);
        _privateTableView.frame = CGRectMake(0, _redBarView.ott_bottom, self.ott_width, self.ott_height -_redBarView.ott_bottom);
        _searchTableView.frame = CGRectMake(0, _redBarView.ott_bottom, self.ott_width, self.ott_height -_redBarView.ott_bottom);
    }else {
        _confirmBtn.hidden = NO;
        _cancelBtn.hidden = NO;
        
        _companyTableView.frame = CGRectMake(0, _redBarView.ott_bottom, self.ott_width, self.confirmBtn.ott_top -_redBarView.ott_bottom);
        _privateTableView.frame = CGRectMake(0, _redBarView.ott_bottom, self.ott_width, self.confirmBtn.ott_top -_redBarView.ott_bottom);
        _searchTableView.frame = CGRectMake(0, _redBarView.ott_bottom, self.ott_width, self.confirmBtn.ott_top -_redBarView.ott_bottom);
    }
}

- (void)requestCompanyPage:(NSInteger)page withSuccessBlock:(requestSucceBlock)sucBlock withFailBlock:(requestFailBlock)failBlock {
    RDRPhoneListCompanyRequestModel *reqModel = [RDRPhoneListCompanyRequestModel requestModel];
    
    NSString *curUsedDomain = [[LPSystemUser sharedUser].settingsStore stringForKey:@"account_mandatory_domain_preference"];
    NSString *curUsedUserIdStr = [[LPSystemUser sharedUser].settingsStore stringForKey:@"account_userid_preference"];
    reqModel.uid = [curUsedUserIdStr stringByAppendingFormat:@"@%@", curUsedDomain];

    reqModel.page = page;
    
    RDRRequest *req = [RDRRequest requestWithURLPath:nil model:reqModel];
    
    __unsafe_unretained LPPhoneListView *weakListView = self;
    [RDRNetHelper GET:req responseModelClass:[RDRPhoneCompanyResponseModel class]
              success:^(NSURLSessionDataTask *operation, id responseObject) {
                  
                  RDRPhoneCompanyResponseModel *model = responseObject;
                  
                  if ([model codeCheckSuccess] == YES) {
                      NSLog(@"请求公司通讯录, success, model=%@", model);
                      // 解析model数据
                      weakListView.companyCurPage = model.page;
                      weakListView.companyTotalPage = model.total;
                      
                      [weakListView.companyPhoneList addObjectsFromArray:model.contacts];
                      
                      if (weakListView.companyTotalPage <= weakListView.companyCurPage) {
                          // 没有数据了
                          weakListView.companyTableView.mj_footer = nil;
                      }
                      
                      if (sucBlock) {
                          sucBlock();
                      }
                  }else {
                      NSLog(@"请求公司通讯录出错, model=%@, msg=%@", model, model.msg);
                      if (failBlock) {
                          failBlock();
                      }
                  }
              } failure:^(NSURLSessionDataTask *operation, NSError *error) {
                  //请求出错
                  NSLog(@"请求公司通讯录出错, %s, error=%@", __FUNCTION__, error);
                  if (failBlock) {
                      failBlock();
                  }
              }];
}

- (void)requestPrivatePage:(NSInteger)page withSuccessBlock:(requestSucceBlock)sucBlock withFailBlock:(requestFailBlock)failBlock {
    RDRPhoneListPrivateRequestModel *reqModel = [RDRPhoneListPrivateRequestModel requestModel];
    
    NSString *curUsedDomain = [[LPSystemUser sharedUser].settingsStore stringForKey:@"account_mandatory_domain_preference"];
    NSString *curUsedUserIdStr = [[LPSystemUser sharedUser].settingsStore stringForKey:@"account_userid_preference"];
    reqModel.uid = [curUsedUserIdStr stringByAppendingFormat:@"@%@", curUsedDomain];

    reqModel.page = page;
    
    RDRRequest *req = [RDRRequest requestWithURLPath:nil model:reqModel];
    
    __unsafe_unretained LPPhoneListView *weakListView = self;
    [RDRNetHelper GET:req responseModelClass:[RDRPhoneCompanyResponseModel class]
              success:^(NSURLSessionDataTask *operation, id responseObject) {
                  
                  RDRPhoneCompanyResponseModel *model = responseObject;
                  
                  if ([model codeCheckSuccess] == YES) {
                      NSLog(@"请求私人通讯录, success, model=%@", model);
                      // 解析model数据
                      weakListView.privateCurPage = model.page;
                      weakListView.privateTotalPage = model.total;
                      
                      [weakListView.privatePhoneList addObjectsFromArray:model.contacts];
                      
                      if (weakListView.privateTotalPage <= weakListView.privateCurPage) {
                          // 没有数据了
                          weakListView.privateTableView.mj_footer = nil;
                      }
                      
                      if (sucBlock) {
                          sucBlock();
                      }
                  }else {
                      NSLog(@"请求公司通讯录出错, model=%@, msg=%@", model, model.msg);
                      if (failBlock) {
                          failBlock();
                      }
                  }
              } failure:^(NSURLSessionDataTask *operation, NSError *error) {
                  //请求出错
                  NSLog(@"请求公司通讯录出错, %s, error=%@", __FUNCTION__, error);
                  if (failBlock) {
                      failBlock();
                  }
              }];
}

- (void)requestSearchText:(NSString *)searchText withSuccessBlock:(requestSucceBlock)sucBlock withFailBlock:(requestFailBlock)failBlock {
    [self.searchPhoneList removeAllObjects];
    
    RDRPhoneListSearchRequestModel *reqModel = [RDRPhoneListSearchRequestModel requestModel];
    
    NSString *curUsedDomain = [[LPSystemUser sharedUser].settingsStore stringForKey:@"account_mandatory_domain_preference"];
    NSString *curUsedUserIdStr = [[LPSystemUser sharedUser].settingsStore stringForKey:@"account_userid_preference"];
    reqModel.uid = [curUsedUserIdStr stringByAppendingFormat:@"@%@", curUsedDomain];

    reqModel.name = searchText;
    
    RDRRequest *req = [RDRRequest requestWithURLPath:nil model:reqModel];
    
    __unsafe_unretained LPPhoneListView *weakListView = self;
    [RDRNetHelper GET:req responseModelClass:[RDRPhoneCompanyResponseModel class]
              success:^(NSURLSessionDataTask *operation, id responseObject) {
                  
                  RDRPhoneCompanyResponseModel *model = responseObject;
                  
                  if ([model codeCheckSuccess] == YES) {
                      NSLog(@"搜索关键字通讯录, success, model=%@", model);
                      // 解析model数据
                      [weakListView.searchPhoneList addObjectsFromArray:model.contacts];
                      if (sucBlock) {
                          sucBlock();
                      }
                  }else {
                      NSLog(@"搜索关键字出错, model=%@, msg=%@", model, model.msg);
                      if (failBlock) {
                          failBlock();
                      }
                  }
              } failure:^(NSURLSessionDataTask *operation, NSError *error) {
                  //请求出错
                  NSLog(@"搜索关键字通讯录出错, %s, error=%@", __FUNCTION__, error);
                  if (failBlock) {
                      failBlock();
                  }
              }];
}

- (void)resetAllDatas {
    [self.companyPhoneList removeAllObjects];
    [self.privatePhoneList removeAllObjects];
    [self.searchPhoneList removeAllObjects];
    
    [self.selectedCompanyNumbers removeAllObjects];
    [self.selectedPrivateNumbers removeAllObjects];
    [self.selectedSearchNumbers removeAllObjects];
    
    __unsafe_unretained UITableView *theCompanytableView = self.companyTableView;
    __unsafe_unretained UITableView *thePrivatetableView = self.companyTableView;
    __unsafe_unretained UITableView *theSearchtableView = self.companyTableView;
    
    __unsafe_unretained LPPhoneListView *weakListView = self;
    
    // 公司通讯录
    self.companyTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 请求
        [weakListView requestCompanyPage:weakListView.companyCurPage withSuccessBlock:^{
            // 请求结束后，
            [theCompanytableView reloadData];
            [theCompanytableView.mj_header endRefreshing];
        } withFailBlock:^{
            // 请求结束后，
            [theCompanytableView.mj_header endRefreshing];
        }];
    }];
    
    self.companyTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        // 请求
        [weakListView requestCompanyPage:weakListView.companyCurPage+1 withSuccessBlock:^{
            // 请求结束后，
            [theCompanytableView reloadData];
            [theCompanytableView.mj_header endRefreshing];
        } withFailBlock:^{
            // 请求结束后，
            [theCompanytableView.mj_header endRefreshing];
        }];
    }];
    
    // 私人通讯录
    self.privateTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 请求
        [weakListView requestPrivatePage:weakListView.privateCurPage withSuccessBlock:^{
            // 请求结束后，
            [thePrivatetableView reloadData];
            [thePrivatetableView.mj_header endRefreshing];
        } withFailBlock:^{
            // 请求结束后，
            [thePrivatetableView.mj_header endRefreshing];
        }];
    }];
    
    self.privateTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        // 请求
        [weakListView requestPrivatePage:weakListView.privateCurPage+1 withSuccessBlock:^{
            // 请求结束后，
            [thePrivatetableView reloadData];
            [thePrivatetableView.mj_header endRefreshing];
        } withFailBlock:^{
            // 请求结束后，
            [thePrivatetableView.mj_header endRefreshing];
        }];
    }];
    
    theSearchtableView.tableFooterView = [[UIView alloc] init];
    theSearchtableView.tableHeaderView = [[UIView alloc] init];
    
    // 请求数据
    [self companyBtnClicked:nil];
}

#pragma mark UITextField delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.companyTableView.hidden = YES;
    self.privateTableView.hidden = YES;
    self.searchTableView.hidden = NO;
    
    [self.selectedCompanyNumbers removeAllObjects];
    [self.selectedPrivateNumbers removeAllObjects];
    [self.selectedSearchNumbers removeAllObjects];

    [self.searchPhoneList removeAllObjects];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    if (textField.text.length == 0) {
        [self.selectedSearchNumbers removeAllObjects];
        [self.searchPhoneList removeAllObjects];
        [self.searchTableView reloadData];
    }else {
        // 准备发起请求
        // 遮照
        [self requestSearchText:textField.text withSuccessBlock:^{
            // 移除遮照
        } withFailBlock:^{
            // 移除遮照，并提示原因
        }];
    }
    
    return YES;
}

#pragma mark TableView delegate & datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.companyTableView) {
        return self.companyPhoneList.count;
    }else if (tableView == self.privateTableView) {
        return self.privatePhoneList.count;
    }else if (tableView == self.searchTableView) {
        return self.searchPhoneList.count;
    }else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"customCell" forIndexPath:indexPath];
    
    if (self.forJoinMeeting == 1) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        RDRPhoneModel *curModel = nil;
        if (tableView == self.companyTableView) {
            curModel = [self.companyPhoneList objectAtIndex:indexPath.row];
        }else if (tableView == self.privateTableView) {
            curModel = [self.privatePhoneList objectAtIndex:indexPath.row];
        }else {
            curModel = [self.searchPhoneList objectAtIndex:indexPath.row];
        }
        
        cell.textLabel.text = curModel.name;
    }else {
        // 判断当前是否被选中
        RDRPhoneModel *curModel = nil;
        if (tableView == self.companyTableView) {
            curModel = [self.companyPhoneList objectAtIndex:indexPath.row];
            cell.accessoryType = [self.selectedCompanyNumbers containsObject:curModel] ? UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
        }else if (tableView == self.privateTableView) {
            curModel = [self.privatePhoneList objectAtIndex:indexPath.row];
            cell.accessoryType = [self.selectedPrivateNumbers containsObject:curModel] ? UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
        }else {     // searchTableView
            curModel = [self.searchPhoneList objectAtIndex:indexPath.row];
            cell.accessoryType = [self.selectedSearchNumbers containsObject:curModel] ? UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
        }
        cell.textLabel.text = curModel.name;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (self.forJoinMeeting == 1) {
        // 点击后直接发起通知
        RDRPhoneModel *curModel = nil;
        if (tableView == self.companyTableView) {
            curModel = [self.companyPhoneList objectAtIndex:indexPath.row];
        }else if (tableView == self.privateTableView) {
            curModel = [self.privatePhoneList objectAtIndex:indexPath.row];
        }else {
            curModel = [self.searchPhoneList objectAtIndex:indexPath.row];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kSearchNumbersDatasForJoineMeeting object:curModel];
    }else {
        // 点击后只是加入到当前select中
        
        RDRPhoneModel *curModel = nil;
        if (tableView == self.companyTableView) {
            curModel = [self.companyPhoneList objectAtIndex:indexPath.row];
            if ([self.selectedCompanyNumbers containsObject:curModel]) {
                [self.selectedCompanyNumbers removeObject:curModel];
            }else {
                [self.selectedCompanyNumbers addObject:curModel];
            }
        }else if (tableView == self.privateTableView) {
            curModel = [self.privatePhoneList objectAtIndex:indexPath.row];
            if ([self.selectedPrivateNumbers containsObject:curModel]) {
                [self.selectedPrivateNumbers removeObject:curModel];
            }else {
                [self.selectedPrivateNumbers addObject:curModel];
            }
        }else {     // searchTableView
            curModel = [self.searchPhoneList objectAtIndex:indexPath.row];
            if ([self.selectedSearchNumbers containsObject:curModel]) {
                [self.selectedSearchNumbers removeObject:curModel];
            }else {
                [self.selectedSearchNumbers addObject:curModel];
            }
        }
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchTextField resignFirstResponder];
}

@end
