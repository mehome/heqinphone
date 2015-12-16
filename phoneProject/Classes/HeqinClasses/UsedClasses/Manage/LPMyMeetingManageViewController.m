//
//  LPMyMeetingManageViewController.m
//  linphone
//
//  Created by baidu on 15/11/16.
//
//

#import "LPMyMeetingManageViewController.h"
#import "LPCellJoinManageTableViewCell.h"
#import "PhoneMainView.h"
#import "LPMyManageSingleViewController.h"
#import "UIViewController+RDRTipAndAlert.h"
#import "LPSystemUser.h"
#import "LPMyManageSingleViewController.h"

@interface LPMyMeetingManageViewController () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *searchBtn;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UITableView *searchTable;
@property (nonatomic, retain) UIView *floatView;                // 遮照层

@property (nonatomic, assign) BOOL showMyMeeting;               // 显示我的会议室
@property (nonatomic, retain) NSMutableArray *filterMyMeetings;             // 我的会议室

@end

@implementation LPMyMeetingManageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.floatView = [[UIView alloc] initWithFrame:self.searchTable.bounds];
    self.floatView.backgroundColor = [UIColor grayColor];
    self.floatView.alpha = 0.3;
    self.floatView.hidden = YES;
    [self.searchTable addSubview:self.floatView];
    self.floatView.userInteractionEnabled = NO;
    [self.floatView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgTap:)]];
    
    self.showMyMeeting = YES;
    self.filterMyMeetings = [NSMutableArray array];
}

- (IBAction)searchBtnClicked:(id)sender {
    self.floatView.hidden = YES;
    [self.searchTextField resignFirstResponder];
    
    NSString *searchStr = [self.searchTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [self filterWithStr:searchStr];
}

- (void)bgTap:(UITapGestureRecognizer *)tapGesture {
    self.floatView.hidden = YES;
    [self.searchTextField resignFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([LPSystemUser sharedUser].hasGetMeetingData == NO) {
        [self searchMyMeetingInfo];
    }else {
        [self resetAllData];
        [self.searchTable reloadData];
    }
}

- (void)resetAllData {
    self.filterMyMeetings = [NSMutableArray arrayWithArray:[LPSystemUser sharedUser].myMeetingsRooms];
}

- (void)searchMyMeetingInfo {
    
    [self showLoadingView];
    
    __weak LPMyMeetingManageViewController *weakSelf = self;
    [LPSystemUser requesteFav:^(BOOL success, NSArray *sheduleMeetings, NSArray *rooms, NSArray *favMeetings, NSString *tipStr) {
        
        [weakSelf hideHudAndIndicatorView];
        
        if (success == YES) {
            // 取数据成功
            [weakSelf.searchTable reloadData];
        }else {
            // 显示错误提示信息
            [weakSelf showToastWithMessage:tipStr];
            
            [LPSystemUser sharedUser].hasGetMeetingData = NO;
        }
    }];
}

#pragma mark - UICompositeViewDelegate Functions

static UICompositeViewDescription *compositeDescription = nil;

+ (UICompositeViewDescription *)compositeViewDescription {
    if(compositeDescription == nil) {
        compositeDescription = [[UICompositeViewDescription alloc] init:@"ManageMeeting"
                                                                content:@"LPMyMeetingManageViewController"
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

#pragma mark UITableView delegate & datasource

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath NS_AVAILABLE_IOS(7_0) {
    return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *pareView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    pareView.backgroundColor = [UIColor grayColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.frame = CGRectMake(20, 0, pareView.ott_width-20, 44);
    btn.backgroundColor = [UIColor clearColor];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    [btn addTarget:self action:@selector(sectionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    if (self.showMyMeeting == YES) {
        [btn setTitle:@"我的会议室 收起" forState:UIControlStateNormal];
    }else {
        [btn setTitle:@"我的会议室 展开" forState:UIControlStateNormal];
    }
    
    [pareView addSubview:btn];
    btn.ott_centerY = pareView.ott_centerY;
    
    return pareView;
}

- (void)sectionBtnClicked:(UIButton *)btn {
    // 我的会议室
    self.showMyMeeting = !self.showMyMeeting;
    if (self.showMyMeeting == YES) {
        [btn setTitle:@"我的会议室 收起" forState:UIControlStateNormal];
    }else {
        [btn setTitle:@"我的会议室 展开" forState:UIControlStateNormal];
    }
    
    [self.searchTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.filterMyMeetings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *tableCell = [tableView dequeueReusableCellWithIdentifier:@"reusedCell"];
    
    if (tableCell == nil) {
        tableCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reusedCell"];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 160, 40)];
        [tableCell.contentView addSubview:titleLabel];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.tag = 9000;
        
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 0, 160, 40)];
        [tableCell.contentView addSubview:dateLabel];
        dateLabel.font = [UIFont systemFontOfSize:14.0];
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.tag = 9001;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = tableCell.contentView.bounds;
        [tableCell.contentView addSubview:btn];
        [btn addTarget:self action:@selector(cellBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        btn.backgroundColor = [UIColor clearColor];
        btn.tag = 9002;
    }
    
    UIButton *btn = [tableCell.contentView viewWithTag:9002];
    btn.frame = tableCell.contentView.bounds;
    btn.rd_userInfo = @{@"indexPath":indexPath};
    
    NSString *firstStr = nil;
    NSString *secondStr = nil;
    RDRJoinMeetingModel *curMeetingModel = [self.filterMyMeetings objectAtIndex:indexPath.row];
    firstStr = curMeetingModel.name.length>0 ? curMeetingModel.name : curMeetingModel.addr;
    secondStr = curMeetingModel.time;
    
    UILabel *firstLabel = (UILabel *)[tableCell.contentView viewWithTag:9000];
    UILabel *secondLabel = (UILabel *)[tableCell.contentView viewWithTag:9001];
    
    firstLabel.ott_width = tableCell.contentView.ott_width / 2.0;
    firstLabel.ott_centerY = tableCell.contentView.ott_height / 2.0;
    
    secondLabel.ott_width = tableCell.contentView.ott_width / 2.0;
    secondLabel.ott_left = firstLabel.ott_right;
    secondLabel.ott_centerY = tableCell.contentView.ott_height / 2.0;
    
    firstLabel.text = firstStr;
    secondLabel.text = secondStr;
    
    return tableCell;
}

- (void)cellBtnClicked:(UIButton *)sender {
    NSIndexPath *btnIndexPath = (NSIndexPath *)[sender.rd_userInfo objectForKey:@"indexPath"];
    [self goIndexPath:btnIndexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)goIndexPath:(NSIndexPath *)indexPath {
    RDRJoinMeetingModel *curMeetingModel = [self.filterMyMeetings objectAtIndex:indexPath.row];
    
    // 进入到管理界面，可设置PIN码和GUEST码
    LPMyManageSingleViewController *controller = DYNAMIC_CAST([[PhoneMainView instance] changeCurrentView:[LPMyManageSingleViewController compositeViewDescription]], DialerViewController);
    if (controller != nil) {
        NSLog(@"进入会议管理中, idNum=%@, name=%@, addr=%@", curMeetingModel.idNum, curMeetingModel.name, curMeetingModel.addr);
        [controller updateWithModel:curMeetingModel];
    }
    
    return;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.floatView.hidden = NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

- (void)filterWithStr:(NSString *)curStr {
    if (curStr.length > 0) {
        self.floatView.hidden = YES;
    }else {
        self.floatView.hidden = NO;
    }
    
    // 先重置好所有的数据
    [self resetAllData];
    if (curStr.length == 0) {
        [self.searchTable reloadData];
        return;
    }
    
    NSMutableArray *tmpArr = [NSMutableArray array];
    
    // 进行过滤操作1
    for (NSInteger i=0; i<self.filterMyMeetings.count; i++) {
        RDRJoinMeetingModel *curModel = [self.filterMyMeetings objectAtIndex:i];
        if ([curModel.name rangeOfString:curStr].location != NSNotFound ||
            [curModel.addr rangeOfString:curStr].location != NSNotFound||
            [[curModel.idNum stringValue] rangeOfString:curStr].location != NSNotFound) {
        }else {
            [tmpArr addObject:curModel];
        }
    }
    if (tmpArr.count > 0) {
        [self.filterMyMeetings removeObjectsInArray:tmpArr];
    }
    [tmpArr removeAllObjects];
    
    [self.searchTable reloadData];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self.searchTextField resignFirstResponder];
    self.floatView.hidden = YES;
    
    [self resetAllData];
    [self.searchTable reloadData];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [self.searchTextField resignFirstResponder];
    self.floatView.hidden = YES;
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSString *searchStr = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [self filterWithStr:searchStr];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.searchTextField resignFirstResponder];
    self.floatView.hidden = YES;
    return YES;
}

@end
