//
//  RDRCellsSelectView.m
//  linphone
//
//  Created by baidu on 15/12/18.
//
//

#import "RDRCellsSelectView.h"

@interface RDRCellsSelectView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy) NSString *sectionTitle;

@property (nonatomic, strong) UITableView *selectedTableView;
@property (nonatomic, strong) UIButton *confirmBtn;
@property (nonatomic, strong) UIButton *cancelBtn;

@property (readwrite, nonatomic, copy) confirmBlock confirmDone;
@property (readwrite, nonatomic, copy) cancelBlock cancelDone;

@property (nonatomic, strong) NSArray *allDatasArr;
@property (nonatomic, strong) NSMutableArray *selectedDatasArr;

@property (nonatomic, assign) BOOL singleChoosed;               // 决定是多选还是单选

@end

@implementation RDRCellsSelectView

+ (void)showSelectViewWith:(NSString *)title withArr:(NSArray *)datas hasSelectedArr:(NSArray *)selectedArr withConfirmBlock:(confirmBlock)doneBlock withCancelBlcok:(cancelBlock)cancelBlock singleChoose:(BOOL)singleChoose {
    UIView *bgView = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    bgView.backgroundColor = [UIColor grayColor];
    bgView.alpha = 0.3;
    [[UIApplication sharedApplication].keyWindow addSubview:bgView];
    
    RDRCellsSelectView *usedView = [[RDRCellsSelectView alloc] initWithFrame:CGRectInset(bgView.bounds, 10, 50)];
    usedView.backgroundColor = [UIColor whiteColor];
    usedView.rd_userInfo = @{@"bgView":bgView};
    [[UIApplication sharedApplication].keyWindow addSubview:usedView];
    
    usedView.confirmDone = doneBlock;
    usedView.cancelDone = cancelBlock;
    
    usedView.sectionTitle = title;
    usedView.allDatasArr = datas;
    [usedView.selectedDatasArr removeAllObjects];
    
    if (singleChoose == YES) {
        if (selectedArr.count > 1) {
            NSLog(@"出错了，已选的会议室有且仅有一个");
            [usedView.selectedDatasArr addObject:selectedArr.firstObject];
        }else {
            [usedView.selectedDatasArr addObjectsFromArray:selectedArr];
        }
    }else {
        [usedView.selectedDatasArr addObjectsFromArray:selectedArr];
    }
    
    usedView.singleChoosed = singleChoose;
    
    [usedView updateFrameOfAll];
    
    [usedView.selectedTableView reloadData];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _selectedTableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _selectedTableView.delegate = self;
        _selectedTableView.tableFooterView = [[UIView alloc] init];
        _selectedTableView.tableHeaderView = [[UIView alloc] init];
        _selectedTableView.dataSource = self;
        [self addSubview:_selectedTableView];
        
        _confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmBtn.backgroundColor = yellowSubjectColor;
        _confirmBtn.frame = CGRectMake(10, 0, frame.size.width/2.0-15, 40);
        [_confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_confirmBtn addTarget:self action:@selector(confirmBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        _confirmBtn.layer.cornerRadius = 10.0;
        [self addSubview:_confirmBtn];
        
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.backgroundColor = yellowSubjectColor;
        _cancelBtn.frame = CGRectMake(frame.size.width/2.0+5, 0, frame.size.width/2.0-15, 40);
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(cancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        _cancelBtn.layer.cornerRadius = 10.0;
        [self addSubview:_cancelBtn];

        
        _selectedDatasArr = [NSMutableArray array];
    }
    
    return self;
}

- (void)updateFrameOfAll {
    self.selectedTableView.frame = CGRectMake(0, 0, self.ott_width, self.ott_height - 40);
    self.confirmBtn.frame = CGRectMake(10, self.selectedTableView.ott_bottom, self.ott_width/2.0-15, 40);
    self.cancelBtn.frame = CGRectMake(self.ott_width/2.0+5, self.selectedTableView.ott_bottom, self.ott_width/2.0-15, 40);
}

- (void)cancelBtnClicked:(UIButton *)btn {
    if (self.cancelDone) {
        NSLog(@"cancel block done");
        self.cancelDone();
    }
    
    UIView *bgView = [self.rd_userInfo objectForKey:@"bgView"];
    if ([bgView isKindOfClass:[UIView class]] && bgView != nil) {
        [bgView removeFromSuperview];
    }
    [self removeFromSuperview];
}

- (void)confirmBtnClicked:(UIButton *)btn {
    if (self.confirmDone) {
        NSLog(@"confirm done");
        self.confirmDone(self.selectedDatasArr);
    }
    
    UIView *bgView = [self.rd_userInfo objectForKey:@"bgView"];
    if ([bgView isKindOfClass:[UIView class]] && bgView != nil) {
        [bgView removeFromSuperview];
    }
    [self removeFromSuperview];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allDatasArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *tableCell = [tableView dequeueReusableCellWithIdentifier:@"reusedCell"];
    
    if (tableCell == nil) {
        tableCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reusedCell"];
    }
    
    UIButton *btn = [tableCell.contentView viewWithTag:9002];
    btn.frame = tableCell.contentView.bounds;
    btn.rd_userInfo = @{@"indexPath":indexPath};
    
    NSObject *eachModel = [self.allDatasArr objectAtIndex:indexPath.row];
    if ([self.selectedDatasArr containsObject:eachModel]) {
        // 选中
        tableCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else {
        tableCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    NSString *titleUsed = @"";
    if ([eachModel respondsToSelector:@selector(name)]) {
        titleUsed = [eachModel performSelector:@selector(name)];
    }
    
//    if (titleUsed.length == 0) {
//        if ([eachModel respondsToSelector:@selector(addr)]) {
//            titleUsed = [eachModel performSelector:@selector(addr)];
//        }
//    }
//    
//    if (titleUsed.length == 0) {
//        if ([eachModel respondsToSelector:@selector(desc)]) {
//            titleUsed = [eachModel performSelector:@selector(desc)];
//        }
//    }
    
    tableCell.textLabel.text = titleUsed;
    
    return tableCell;
}

- (void)cellBtnClicked:(UIButton *)sender {
    NSInteger cellIndexRow = ((NSIndexPath *)[sender.rd_userInfo objectForKey:@"indexPath"]).row;
    NSObject *rowModel = [self.allDatasArr objectAtIndex:cellIndexRow];
    if ([self.selectedDatasArr containsObject:rowModel]) {
        // 移除
        [self.selectedDatasArr removeObject:rowModel];
    }else {
        [self.selectedDatasArr addObject:rowModel];
    }

    [self.selectedTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:cellIndexRow inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sectionTitle;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSObject *rowModel = [self.allDatasArr objectAtIndex:indexPath.row];
    if (self.singleChoosed == YES) {
        // 单选
        if ([self.selectedDatasArr containsObject:rowModel]) {
            // 移除
            [self.selectedDatasArr removeAllObjects];
        }else {
            // 添加
            [self.selectedDatasArr removeAllObjects];
            [self.selectedDatasArr addObject:rowModel];
        }
        [self.selectedTableView reloadData];
    }else {
        // 多选
        if ([self.selectedDatasArr containsObject:rowModel]) {
            // 移除
            [self.selectedDatasArr removeObject:rowModel];
        }else {
            // 添加
            [self.selectedDatasArr addObject:rowModel];
        }
    }
    
    [self.selectedTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
