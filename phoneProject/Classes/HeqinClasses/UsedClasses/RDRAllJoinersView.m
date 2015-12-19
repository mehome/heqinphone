//
//  RDRAllJoinersView.m
//  linphone
//
//  Created by baidu on 15/12/20.
//
//

#import "RDRAllJoinersView.h"

@interface RDRAllJoinersView ()

@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UIButton *closeBtn;

@property (nonatomic, strong) UITableView *theTable;
@property (nonatomic, strong) UIButton *allSilenceBtn;

@property (nonatomic, )

@end

@implementation RDRAllJoinersView

+ (void)showTableTitle:(NSString *)title {
    UIView *bgView = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    bgView.backgroundColor = [UIColor grayColor];
    bgView.alpha = 0.5;
    
    [[UIApplication sharedApplication].keyWindow addSubview:bgView];
    
    RDRAllJoinersView *joinersView = [[RDRAllJoinersView alloc] initWithFrame:CGRectZero];
    [[UIApplication sharedApplication].keyWindow addSubview:joinersView];
    joinersView.frame = CGRectInset(bgView.bounds, 10, 20);
    joinersView.backgroundColor = [UIColor whiteColor];
    joinersView.layer.cornerRadius = 5.0;
    joinersView.rd_userInfo = @{@"bgView":bgView};
    
    joinersView.tipLabel.text = title;
    
    [joinersView updateFrameAndReset];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_tipLabel];
        
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeBtn.frame = CGRectZero;
        [_closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeClicked:) forControlEvents:UIControlEventTouchUpInside];
        _closeBtn.backgroundColor = [UIColor blueColor];
        _closeBtn.layer.cornerRadius = 10.0;
        [self addSubview:_closeBtn];

        _theTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _theTable.dataSource = self;
        _theTable.delegate = self;
        [self addSubview:_theTable];
        
        _allSilenceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _allSilenceBtn.frame = CGRectZero;
        [_allSilenceBtn setTitle:@"全部静音" forState:UIControlStateNormal];
        [_allSilenceBtn addTarget:self action:@selector(allSilence:) forControlEvents:UIControlEventTouchUpInside];
        _allSilenceBtn.backgroundColor = [UIColor blueColor];
        _allSilenceBtn.layer.cornerRadius = 10.0;
        [self addSubview:_allSilenceBtn];
        
        _hud = [MBProgressHUD HUDForView:self];
        
    }
    
    return self;
}

- (void)closeClicked:(UIButton *)sender {
    UIView *bgView = [self.rd_userInfo objectForKey:@"bgView"];
    if ([bgView isKindOfClass:[UIView class]] && bgView != nil) {
        [bgView removeFromSuperview];
    }
    [self removeFromSuperview];
}

- (void)allSilence:(UIButton *)sender {
    
}

#define offsetX 10

- (void)updateFrameAndReset {
    self.tipLabel.frame = CGRectMake(offsetX, offsetX, self.ott_width - 2 * offsetX, 40);
    self.closeBtn.frame = CGRectMake(self.ott_width - 80, offsetX, 60, 40);
    
    self.allSilenceBtn.frame = CGRectMake(offsetX, self.ott_height - 40 - offsetX, self.tipLabel.ott_width, 40);
    
    self.theTable.frame = CGRectMake(offsetX, self.closeBtn.ott_bottom + offsetX, self.tipLabel.ott_width, self.allSilenceBtn.ott_top - offsetX - (self.closeBtn.ott_bottom + offsetX));
}

#pragma mark UITabelView delegate & datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectio {
    //    return [LPSystemSetting sharedSetting].historyMeetings.count;
    
    //    NSInteger number = 0;
    //    const MSList * logs = linphone_core_get_call_logs([LinphoneManager getLc]);
    //    while(logs != NULL) {
    ////        LinphoneCallLog*  log = (LinphoneCallLog *) logs->data;
    //        logs = ms_list_next(logs);
    //        number++;
    //    }
    //
    //    return number;
    
    return self.callLogs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
    
    
    UILabel *mainLabel = [tableCell.contentView viewWithTag:9000];
    UILabel *dateLabel = [tableCell.contentView viewWithTag:9001];
    
    mainLabel.ott_width = tableCell.contentView.ott_width / 2.0;
    mainLabel.ott_centerY = tableCell.contentView.ott_height / 2.0;
    
    dateLabel.ott_width = tableCell.contentView.ott_width / 2.0;
    dateLabel.ott_left = mainLabel.ott_right;
    dateLabel.ott_centerY = tableCell.contentView.ott_height / 2.0;
    
    LinphoneCallLog *log = [[self.callLogs objectAtIndex:[indexPath row]] pointerValue];
    
    // Set up the cell...
    LinphoneAddress* addr;
    if (linphone_call_log_get_dir(log) == LinphoneCallIncoming) {
        addr = linphone_call_log_get_from(log);
    } else {
        addr = linphone_call_log_get_to(log);
    }
    
    NSString* address = nil;
    if(addr != NULL) {
        BOOL useLinphoneAddress = true;
        // contact name
        char* lAddress = linphone_address_as_string_uri_only(addr);
        if(lAddress) {
            NSString *normalizedSipAddress = [FastAddressBook normalizeSipURI:[NSString stringWithUTF8String:lAddress]];
            ABRecordRef contact = [[[LinphoneManager instance] fastAddressBook] getContact:normalizedSipAddress];
            if(contact) {
                address = [FastAddressBook getContactDisplayName:contact];
                useLinphoneAddress = false;
            }
            ms_free(lAddress);
        }
        if(useLinphoneAddress) {
            const char* lDisplayName = linphone_address_get_display_name(addr);
            const char* lUserName = linphone_address_get_username(addr);
            if (lDisplayName)
                address = [NSString stringWithUTF8String:lDisplayName];
            else if(lUserName)
                address = [NSString stringWithUTF8String:lUserName];
        }
    }
    if(address == nil) {
        address = NSLocalizedString(@"Unknown", nil);
    }
    
    mainLabel.text = address;
    
    NSDate *startData = [NSDate dateWithTimeIntervalSince1970:linphone_call_log_get_start_date(log)];
    dateLabel.text = [self.dateFormatter stringFromDate:startData];
    
    return tableCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"历史会议";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectRowAtIndexPath=%@", indexPath);
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)goIndexPath:(NSIndexPath *)indexPath {
    LinphoneCallLog *callLog = [[self.callLogs objectAtIndex:[indexPath row]] pointerValue];
    LinphoneAddress* addr;
    if (linphone_call_log_get_dir(callLog) == LinphoneCallIncoming) {
        addr = linphone_call_log_get_from(callLog);
    } else {
        addr = linphone_call_log_get_to(callLog);
    }
    
    NSString* displayName = nil;
    NSString* address = nil;
    if(addr != NULL) {
        BOOL useLinphoneAddress = true;
        // contact name
        char* lAddress = linphone_address_as_string_uri_only(addr);
        if(lAddress) {
            address = [NSString stringWithUTF8String:lAddress];
            NSString *normalizedSipAddress = [FastAddressBook normalizeSipURI:address];
            ABRecordRef contact = [[[LinphoneManager instance] fastAddressBook] getContact:normalizedSipAddress];
            if(contact) {
                displayName = [FastAddressBook getContactDisplayName:contact];
                useLinphoneAddress = false;
            }
            ms_free(lAddress);
        }
        if(useLinphoneAddress) {
            const char* lDisplayName = linphone_address_get_display_name(addr);
            if (lDisplayName)
                displayName = [NSString stringWithUTF8String:lDisplayName];
        }
    }
    
    [self joinMeeting:address withDisplayName:displayName];
}



@end
