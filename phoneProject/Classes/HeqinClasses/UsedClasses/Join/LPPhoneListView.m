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

@property (nonatomic, strong) UIView *redBarView;       // 红色条而已， 用来显示当前处于企业通讯录还是私人通讯录

@property (nonatomic, strong) UITableView *companyTableView;
@property (nonatomic, strong) UITableView *privateTableView;
@property (nonatomic, strong) UITableView *searchTableView;

@property (nonatomic, strong) NSMutableArray *companyPhoneList;
@property (nonatomic, strong) NSMutableArray *privatePhoneList;
@property (nonatomic, strong) NSMutableArray *searchPhoneList;

@property (nonatomic, strong) NSMutableArray *searchSelectedNumbers;

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
        
        _companyCurPage = 1;
        _privateCurPage = 1;
        
        _searchSelectedNumbers = [NSMutableArray array];
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
    
    self.searchSelectedNumbers = [NSMutableArray array];
    
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

    self.searchSelectedNumbers = [NSMutableArray array];

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
    // 确定按钮
    if (self.searchSelectedNumbers.count == 0) {
        [UIViewController showToastWithmessage:@"没有选择联系人或者设备"];
        return;
    }else {
        // 取当前的数据，然后返回
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kSearchNumbersDatas" object:self.searchSelectedNumbers];
        [self removeFromSuperview];
    }
}

- (void)cancelBtnClicked:(id)sender {
    // 取消按钮
    // 直接返回，什么都不做
    [self removeFromSuperview];
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

- (void)requestCompanyPage:(NSInteger)page withSuccessBlock:(requestSucceBlock)sucBlock withFailBlock:(requestFailBlock)failBlock {
    RDRPhoneListCompanyRequestModel *reqModel = [RDRPhoneListCompanyRequestModel requestModel];
    reqModel.uid = [[LPSystemUser sharedUser].settingsStore stringForKey:@"userid_preference"];
    reqModel.page = page;
    
    RDRRequest *req = [RDRRequest requestWithURLPath:nil model:reqModel];
    
    __unsafe_unretained LPPhoneListView *weakListView = self;
    [RDRNetHelper GET:req responseModelClass:[RDRPhoneCompanyResponseModel class]
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  
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
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  //请求出错
                  NSLog(@"请求公司通讯录出错, %s, error=%@", __FUNCTION__, error);
                  if (failBlock) {
                      failBlock();
                  }
              }];
}

- (void)requestPrivatePage:(NSInteger)page withSuccessBlock:(requestSucceBlock)sucBlock withFailBlock:(requestFailBlock)failBlock {
    RDRPhoneListPrivateRequestModel *reqModel = [RDRPhoneListPrivateRequestModel requestModel];
    reqModel.uid = [[LPSystemUser sharedUser].settingsStore stringForKey:@"userid_preference"];
    reqModel.page = page;
    
    RDRRequest *req = [RDRRequest requestWithURLPath:nil model:reqModel];
    
    __unsafe_unretained LPPhoneListView *weakListView = self;
    [RDRNetHelper GET:req responseModelClass:[RDRPhoneCompanyResponseModel class]
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  
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
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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
    reqModel.uid = [[LPSystemUser sharedUser].settingsStore stringForKey:@"userid_preference"];
    reqModel.name = searchText;
    
    RDRRequest *req = [RDRRequest requestWithURLPath:nil model:reqModel];
    
    __unsafe_unretained LPPhoneListView *weakListView = self;
    [RDRNetHelper GET:req responseModelClass:[RDRPhoneCompanyResponseModel class]
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  
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
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
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
    
    [self.searchSelectedNumbers removeAllObjects];
    [self.searchPhoneList removeAllObjects];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length == 0) {
        [self.searchSelectedNumbers removeAllObjects];
        [self.searchPhoneList removeAllObjects];
        [self.searchTableView reloadData];
    }else {
        // 准备发起请求
        [self requestSearchText:textField.text withSuccessBlock:^{
            
        } withFailBlock:^{
            
        }];
    }
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
    if (self.forJoinMeeting == 1) {
        // 只有一行title数据
    }else {
        // 左边是title数据，右边是对勾
    }
    
    
    static NSString *ID = @"example";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    UITableViewCell *cellS = [[UITableViewCell alloc] initWithStyle:<#(UITableViewCellStyle)#> reuseIdentifier:<#(nullable NSString *)#>];
    MJExample *exam = self.examples[indexPath.section];
    cell.textLabel.text = exam.titles[indexPath.row];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@", exam.vcClass, exam.methods[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MJExample *exam = self.examples[indexPath.section];
    UIViewController *vc = [[exam.vcClass alloc] init];
    vc.title = exam.titles[indexPath.row];
    [vc setValue:exam.methods[indexPath.row] forKeyPath:@"method"];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
