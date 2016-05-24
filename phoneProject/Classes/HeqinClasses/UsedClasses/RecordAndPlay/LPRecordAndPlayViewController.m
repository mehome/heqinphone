//
//  LPRecordAndPlayViewController.m
//  linphone
//
//  Created by heqin on 16/5/7.
//
//

#import "LPRecordAndPlayViewController.h"
#import "UIViewController+RDRTipAndAlert.h"

#import "UIView+Frame.h"
#import "MJRefresh.h"

#import "RDRRequest.h"
#import "RDRNetHelper.h"

#import "LPSystemUser.h"

// 7天，和30天
#import "RDRRecordPlayRequstModel.h"
#import "RDRRecordAndPlayResponseModel.h"

// 关键字搜索
#import "RDRRecordSearchRequestModel.h"
#import "RDRRecordSearchResponseModel.h"

// 获取加密视频地址
#import "RDRAskSecRequestModel.h"
#import "RDRAskSecResponseModel.h"

#import "RDRRecordVideoModel.h"

#import "LPVideoClickToPlayCell.h"

typedef void(^requestSuccessBlock)(RDRRecordAndPlayResponseModel *responseModel);
typedef void(^requestKeywordsSuccessBlock)(RDRRecordSearchResponseModel *responseModel);
typedef void(^requestFailedBlock)(NSError *theError);

#define kSeventDays 7
#define kThirtyDays 30

@interface LPRecordAndPlayViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIView *topBgView;

@property (strong, nonatomic) IBOutlet UIButton *sevenDayBtn;

@property (strong, nonatomic) IBOutlet UIView *redLineView;

@property (nonatomic, strong) UITableView *sevenTable;
@property (nonatomic, strong) UITableView *thirtyTable;
@property (nonatomic, strong) UITableView *searchTable;

@property (nonatomic, strong) UIView *searchTopView;
@property (nonatomic, strong) UITextField *searchTextField;

@property (nonatomic, assign) NSInteger curSelected;

@property (nonatomic, strong) NSMutableArray *sevenList;
@property (nonatomic, strong) NSMutableArray *thirtyList;
@property (nonatomic, strong) NSMutableArray *searchList;

@property (nonatomic, assign) NSInteger curPageSeventDays;
@property (nonatomic, assign) NSInteger curPageThirtyDays;

@end

@implementation LPRecordAndPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.curSelected = 0;
    self.curPageSeventDays = 1;
    self.curPageThirtyDays = 1;
    
    self.sevenList = [NSMutableArray array];
    self.thirtyList = [NSMutableArray array];
    self.searchList = [NSMutableArray array];
    
    [self refreshRedLinePlace];

    [self initAllConstrols];
    
    [self decideWhichTableShow];
    
    [self initSevenRequest];
}

- (void)initAllConstrols {
    self.searchTopView = [[UIView alloc] initWithFrame:CGRectMake(0, self.topBgView.ott_bottom, [UIScreen mainScreen].bounds.size.width, 40)];
    self.searchTopView.backgroundColor = [UIColor lightTextColor];
    
    self.searchTextField = [[UITextField alloc] initWithFrame:self.searchTopView.bounds];
    self.searchTextField.keyboardType = UIKeyboardTypeASCIICapable;
    self.searchTextField.returnKeyType = UIReturnKeySearch;
    self.searchTextField.borderStyle = UITextBorderStyleBezel;
    self.searchTextField.delegate = self;
    self.searchTextField.enablesReturnKeyAutomatically = YES;
    self.searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.searchTextField.placeholder = @"输入关键字进行搜索";
    [self.searchTopView addSubview:self.searchTextField];

    // 添加各个表
    self.sevenTable = [[UITableView alloc] initWithFrame:CGRectMake(0, self.topBgView.ott_bottom, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - self.topBgView.ott_bottom - 49) style:UITableViewStylePlain];
    self.sevenTable.delegate = self;
    self.sevenTable.dataSource = self;
    self.sevenTable.hidden = NO;
    [self.view addSubview:self.sevenTable];
    self.sevenTable.tableFooterView = nil;
    self.sevenTable.tableHeaderView = nil;
    
    self.thirtyTable = [[UITableView alloc] initWithFrame:CGRectMake(0, self.topBgView.ott_bottom, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - self.topBgView.ott_bottom - 49) style:UITableViewStylePlain];
    self.thirtyTable.delegate = self;
    self.thirtyTable.dataSource = self;
    self.thirtyTable.hidden = YES;
    [self.view addSubview:self.thirtyTable];
    self.thirtyTable.tableHeaderView = nil;
    self.thirtyTable.tableFooterView = nil;
    
    self.searchTable = [[UITableView alloc] initWithFrame:CGRectMake(0, self.topBgView.ott_bottom, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - self.topBgView.ott_bottom - 49) style:UITableViewStylePlain];
    self.searchTable.delegate = self;
    self.searchTable.dataSource = self;
    self.searchTable.hidden = YES;
    [self.view addSubview:self.searchTable];
    self.searchTable.tableFooterView = nil;
    self.searchTable.tableHeaderView = self.searchTopView;
    
    [self.sevenTable registerClass:[LPVideoClickToPlayCell class] forCellReuseIdentifier:@"customCell"];
    [self.thirtyTable registerClass:[LPVideoClickToPlayCell class] forCellReuseIdentifier:@"customCell"];
    [self.thirtyTable registerClass:[LPVideoClickToPlayCell class] forCellReuseIdentifier:@"customCell"];
}

- (void)decideWhichTableShow {
    switch (self.curSelected) {
        case 0:
            self.sevenTable.hidden = NO;
            self.thirtyTable.hidden = YES;
            self.searchTable.hidden = YES;
            break;
        case 1:
            self.sevenTable.hidden = YES;
            self.thirtyTable.hidden = NO;
            self.searchTable.hidden = YES;
            break;
        case 2:
            self.sevenTable.hidden = YES;
            self.thirtyTable.hidden = YES;
            self.searchTable.hidden = NO;
            break;
        default:
            break;
    }
    
    [self.searchTextField resignFirstResponder];
}

- (void)refreshRedLinePlace {
    [UIView animateWithDuration:0.2 animations:^{
        self.redLineView.ott_left = self.sevenDayBtn.ott_width * self.curSelected;
    }];
}

#pragma mark - UICompositeViewDelegate Functions
static UICompositeViewDescription *compositeDescription = nil;

+ (UICompositeViewDescription *)compositeViewDescription {
    if(compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:@"RecordingAndPlay"
                                                                content:@"LPRecordAndPlayViewController"
                                                               stateBar:nil
                                                        stateBarEnabled:false
                                                                 tabBar:@"LPJoinBarViewController"
                                                          tabBarEnabled:true
                                                             fullscreen:false
                                                          landscapeMode:[LinphoneManager runningOnIpad]
                                                           portraitMode:true];
        compositeDescription.darkBackground = true;
    }
    return compositeDescription;
}

- (IBAction)sevenDayBtnClicked:(id)sender {
    if (self.curSelected == 0) {
        return;
    }else {
        self.curSelected = 0;
        [self refreshRedLinePlace];
        [self decideWhichTableShow];
        
        // 决定是否需要请求数据
        if (self.sevenList.count != 0) {
            // 不进行请求
        }else {
            // 进行请求
            [self initSevenRequest];
        }
    }
}

- (IBAction)thirtyDayBtnClicked:(id)sender {
    if (self.curSelected == 1) {
        return;
    }else {
        self.curSelected = 1;
        [self refreshRedLinePlace];
        [self decideWhichTableShow];
        
        // 决定是否需要请求数据
        if (self.thirtyList.count != 0) {
            // 不进行请求
        }else {
            // 进行请求
            if (self.thirtyTable.mj_header == nil) {
                __unsafe_unretained LPRecordAndPlayViewController *weakSelf = self;
                self.thirtyTable.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
                    // 请求
                    [weakSelf firstRequestThirtyDaysData];
                }];
            }
            
            [self firstRequestThirtyDaysData];
        }
    }
}

- (void)firstRequestThirtyDaysData {
    __unsafe_unretained LPRecordAndPlayViewController *weakSelf = self;
    
    [self showToastWithMessage:@"加载30天内数据中"];
    
    self.curPageThirtyDays = 1;
    [self requestDays:kThirtyDays andRecordPage:self.curPageThirtyDays withSuccessBlock:^(RDRRecordAndPlayResponseModel *responseModel) {
        [weakSelf.thirtyTable.mj_header endRefreshing];
        weakSelf.curPageThirtyDays = responseModel.page;
        
        [weakSelf.thirtyList removeAllObjects];
        [weakSelf.thirtyList addObjectsFromArray:responseModel.videos];
        
        if (responseModel.page <= responseModel.total ) {
            // 没有更多了
            weakSelf.thirtyTable.mj_footer = nil;
        }else {
            // 还有更多
            [weakSelf hasMoreForThirtyDays];
        }
        [weakSelf.thirtyTable reloadData];
        
    } withFailBlock:^(NSError *theError) {
        [weakSelf.thirtyTable.mj_header endRefreshing];
        
        // 弹出出错提示
        [weakSelf showToastWithMessage:[NSString stringWithFormat:@"服务器出错:%@", theError]];
    }];
}

- (void)hasMoreForThirtyDays {
    __unsafe_unretained LPRecordAndPlayViewController *weakSelf = self;
    
    self.thirtyTable.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weakSelf showToastWithMessage:@"加载更多30天内的数据中"];
        
        // 请求
        [weakSelf requestDays:kThirtyDays andRecordPage:weakSelf.curPageThirtyDays+1 withSuccessBlock:^(RDRRecordAndPlayResponseModel *responseModel) {
            [weakSelf.thirtyTable.mj_footer endRefreshing];
            weakSelf.curPageThirtyDays = responseModel.page;
            
            [weakSelf.thirtyList addObjectsFromArray:responseModel.videos];
            
            if (responseModel.page <= responseModel.total ) {
                // 还有更多
            }else {
                // 没有更多
                weakSelf.thirtyTable.mj_footer = nil;
            }
            [weakSelf.thirtyTable reloadData];
        } withFailBlock:^(NSError *theError) {
            [weakSelf.thirtyTable.mj_footer endRefreshing];
            
            // 弹出出错提示
            [weakSelf showToastWithMessage:[NSString stringWithFormat:@"服务器出错:%@", theError]];
        }];
    }];

}

- (void)initSevenRequest {
    if (self.sevenTable.mj_header == nil) {
        __unsafe_unretained LPRecordAndPlayViewController *weakSelf = self;
        
        self.sevenTable.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            // 请求
            [weakSelf firstRequestSeventDaysData];
        }];
    }
    
    [self firstRequestSeventDaysData];
}

- (void)firstRequestSeventDaysData {
    __unsafe_unretained LPRecordAndPlayViewController *weakSelf = self;
    
    [self showToastWithMessage:@"加载7天内数据中"];
    
    self.curPageSeventDays = 1;
    [self requestDays:kSeventDays andRecordPage:self.curPageSeventDays withSuccessBlock:^(RDRRecordAndPlayResponseModel *responseModel) {
        [weakSelf.sevenTable.mj_header endRefreshing];
        weakSelf.curPageSeventDays = responseModel.page;

        [weakSelf.sevenList removeAllObjects];
        [weakSelf.sevenList addObjectsFromArray:responseModel.videos];
        
        if (responseModel.page <= responseModel.total ) {
            // 没有更多了
            weakSelf.sevenTable.mj_footer = nil;
        }else {
            // 还有更多
            [weakSelf hasMoreForSevenDays];
        }
        [weakSelf.sevenTable reloadData];
        
    } withFailBlock:^(NSError *theError) {
        [weakSelf.sevenTable.mj_header endRefreshing];

        // 弹出出错提示
        [weakSelf showToastWithMessage:[NSString stringWithFormat:@"服务器出错:%@", theError]];
    }];
}

- (void)hasMoreForSevenDays {
    __unsafe_unretained LPRecordAndPlayViewController *weakSelf = self;
    
    self.sevenTable.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [weakSelf showToastWithMessage:@"加载更多7天内的数据中"];
        
        // 请求
        [weakSelf requestDays:kSeventDays andRecordPage:weakSelf.curPageSeventDays+1 withSuccessBlock:^(RDRRecordAndPlayResponseModel *responseModel) {
            [weakSelf.sevenTable.mj_footer endRefreshing];
            weakSelf.curPageSeventDays = responseModel.page;
            
            [weakSelf.sevenList addObjectsFromArray:responseModel.videos];
            
            if (responseModel.page <= responseModel.total ) {
                // 还有更多
            }else {
                // 没有更多
                weakSelf.sevenTable.mj_footer = nil;
            }
            [weakSelf.sevenTable reloadData];
        } withFailBlock:^(NSError *theError) {
            [weakSelf.sevenTable.mj_footer endRefreshing];
            
            // 弹出出错提示
            [weakSelf showToastWithMessage:[NSString stringWithFormat:@"服务器出错:%@", theError]];
        }];
    }];
}

- (void)requestDays:(NSInteger)days andRecordPage:(NSInteger)page withSuccessBlock:(requestSuccessBlock)block withFailBlock:(requestFailedBlock)failBlock {
    RDRRecordPlayRequstModel *reqModel = [RDRRecordPlayRequstModel requestModel];
    reqModel.uid = [[LPSystemUser sharedUser].settingsStore stringForKey:@"userid_preference"];
    reqModel.page = page;
    reqModel.day = days;
    
    RDRRequest *req = [RDRRequest requestWithURLPath:nil model:reqModel];
    
    [RDRNetHelper GET:req responseModelClass:[RDRRecordAndPlayResponseModel class]
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  
                  RDRRecordAndPlayResponseModel *model = responseObject;
                  
                  if ([model codeCheckSuccess] == YES) {
                      NSLog(@"请求录制视频列表, success, model=%@", model);
                      if (block) {
                          block(model);
                      }
                  }else {
                      NSLog(@"请求录制视频列表, model=%@, msg=%@", model, model.msg);
                      if (failBlock) {
                          failBlock([[NSError alloc] initWithDomain:@"录制视频列表为错误" code:1000 userInfo:@{@"reason":@"返回码不为200"}]);
                      }
                  }
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  //请求出错
                  NSLog(@"请求录制视频列表, %s, error=%@", __FUNCTION__, error);
                  if (failBlock) {
                      failBlock(error);
                  }
              }];
}

- (IBAction)searchBtnClicked:(id)sender {
    if (self.curSelected == 2) {
        return;
    }else {
        self.curSelected = 2;
        [self refreshRedLinePlace];
        [self decideWhichTableShow];
        
        // 直接显示搜索列表即可
    }
}

#pragma mark TableView delegate & datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.sevenTable) {
        return self.sevenList.count;
    }else if (tableView == self.thirtyTable) {
        return self.thirtyList.count;
    }else if (tableView == self.searchTable) {
        return self.searchList.count;
    }else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LPVideoClickToPlayCell *cell = [tableView dequeueReusableCellWithIdentifier:@"customCell" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    RDRRecordVideoModel *curModel = nil;
    if (tableView == self.sevenTable) {
        curModel = [self.sevenList objectAtIndex:indexPath.row];
    }else if (tableView == self.thirtyTable) {
        curModel = [self.thirtyList objectAtIndex:indexPath.row];
    }else {
        curModel = [self.searchList objectAtIndex:indexPath.row];
    }
    
    // cell进行加载
    cell.isLiveVideo = (curModel.live == 1);
    cell.videoNameLabel.text = curModel.name;
    cell.videoDescLabel.text = curModel.desc;
    cell.videoDateLabel.text = curModel.date;
    cell.isSec = (curModel.sec == 1);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    RDRRecordVideoModel *curModel = nil;
    if (tableView == self.sevenTable) {
        curModel = [self.sevenList objectAtIndex:indexPath.row];
    }else if (tableView == self.thirtyTable) {
        curModel = [self.thirtyList objectAtIndex:indexPath.row];
    }else {
        curModel = [self.searchList objectAtIndex:indexPath.row];
    }
    
    if (curModel.sec == 0) {
        // 未加密， 直接取url
        [[NSNotificationCenter defaultCenter] postNotificationName:kPlayVideoNotification object:curModel.url];
    }else {
        // 加密过的，需要弹出界面问取密码
        [self askToDesec:curModel.id];
    }
}

- (void)askToDesec:(NSString *)videoIdStr {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"请输入密码" message:@"该视频为加密视频" preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:textField];
        
    }];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *passwordTextField = alertVC.textFields.firstObject;
        [self decodeVideoId:videoIdStr withPassword:passwordTextField.text];
    }]];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}


- (void)handleTextFieldTextDidChangeNotification:(NSNotification *)notification {
//    UITextField *textField = notification.object;
//    
//    // Enforce a minimum length of >= 5 characters for secure text alerts.
//    self.secureTextAlertAction.enabled = textField.text.length >= 5;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchTextField resignFirstResponder];
}

- (void)decodeVideoId:(NSString *)idStr withPassword:(NSString *)passwordStr {
    if (passwordStr.length == 0) {
        [self showToastWithMessage:@"密码不能为空"];
        return;
    }
    
    [self showToastWithMessage:@"解密中,请稍候..."];
    
    [self showLoadingView];
    __weak LPRecordAndPlayViewController *weakSelf = self;

    RDRAskSecRequestModel *reqModel = [RDRAskSecRequestModel requestModel];
    reqModel.id = idStr;
    reqModel.pwd = passwordStr;
    
    RDRRequest *req = [RDRRequest requestWithURLPath:nil model:reqModel];
    
    [RDRNetHelper GET:req responseModelClass:[RDRAskSecResponseModel class]
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  [weakSelf hideHudAndIndicatorView];

                  RDRAskSecResponseModel *model = responseObject;
                  
                  if ([model codeCheckSuccess] == YES) {
                      NSLog(@"解密视频, success, model=%@", model);
                      [weakSelf handleAskSecModel:model];
                  }else {
                      NSLog(@"解密视频, model=%@, msg=%@", model, model.msg);
                      [weakSelf showToastWithMessage:[NSString stringWithFormat:@"解密失败，%@", model.msg]];
                  }
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  //请求出错
                  [weakSelf hideHudAndIndicatorView];

                  NSLog(@"解密视频, %s, error=%@", __FUNCTION__, error);
                  [weakSelf showToastWithMessage:[NSString stringWithFormat:@"解密失败，%@", error]];
              }];
}

- (void)handleAskSecModel:(RDRAskSecResponseModel *)model {
    if (model.url.length == 0) {
        [self showToastWithMessage:@"获取视频地址失败"];
    }else {
        [self showToastWithMessage:@"解密成功"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kPlayVideoNotification object:model.url];
    }
}

#pragma mark -- textField delegate
#pragma mark UITextField delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField != self.searchTextField) {
        return;
    }
    
    [self.searchList removeAllObjects];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];

    if (textField != self.searchTextField) {
        return YES;
    }
    
    if (textField.text.length == 0) {
        [self.searchList removeAllObjects];
        [self.searchTable reloadData];
    }else {
        // 准备发起请求
        // 遮照
        [self showLoadingView];
        
        __weak LPRecordAndPlayViewController *weakSelf = self;
        [self requestForKeywords:textField.text withSuccessBlock:^(RDRRecordSearchResponseModel *responseModel) {
            [weakSelf hideHudAndIndicatorView];
            
            [weakSelf.searchList removeAllObjects];
            [weakSelf.searchList addObjectsFromArray:responseModel.videos];
            [weakSelf.searchTable reloadData];
            
        } withFailBlock:^(NSError *theError) {
            [weakSelf hideHudAndIndicatorView];
            
            [weakSelf showToastWithMessage:[NSString stringWithFormat:@"%@", theError]];
        }];
    }
    
    return YES;
}

- (void)requestForKeywords:(NSString *)keywords withSuccessBlock:(requestKeywordsSuccessBlock)block withFailBlock:(requestFailedBlock)failBlock {
    RDRRecordSearchRequestModel *reqModel = [RDRRecordSearchRequestModel requestModel];
    reqModel.uid = [[LPSystemUser sharedUser].settingsStore stringForKey:@"userid_preference"];
    reqModel.key = keywords;
    
    RDRRequest *req = [RDRRequest requestWithURLPath:nil model:reqModel];
    
    [RDRNetHelper GET:req responseModelClass:[RDRRecordSearchResponseModel class]
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  
                  RDRRecordSearchResponseModel *model = responseObject;
                  
                  if ([model codeCheckSuccess] == YES) {
                      NSLog(@"请求搜索视频列表, success, model=%@", model);
                      if (block) {
                          block(model);
                      }
                  }else {
                      NSLog(@"请求搜索视频列表, model=%@, msg=%@", model, model.msg);
                      if (failBlock) {
                          failBlock([[NSError alloc] initWithDomain:@"搜索视频列表为错误" code:1000 userInfo:@{@"reason":@"返回码不为200"}]);
                      }
                  }
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  //请求出错
                  NSLog(@"请求搜索视频列表, %s, error=%@", __FUNCTION__, error);
                  if (failBlock) {
                      failBlock(error);
                  }
              }];
}


@end
