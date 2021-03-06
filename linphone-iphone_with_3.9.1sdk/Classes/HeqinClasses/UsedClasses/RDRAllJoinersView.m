//
//  RDRAllJoinersView.m
//  linphone
//
//  Created by baidu on 15/12/20.
//
//

#import "RDRAllJoinersView.h"
#import "RDRLoadingView.h"

#import "RDRRequest.h"
#import "RDRNetHelper.h"

#import "LPSystemSetting.h"
#import "LPSystemUser.h"

#import "ShowPinView.h"

#import "RDROperationGetJoinersRequestModel.h"
#import "RDROperationMuteRequestModel.h"
#import "RDROperationMuteVideoRequestModel.h"
#import "RDROperationKickoutRequestModel.h"

#import "RDROperationGetJoinersResponseModel.h"
#import "RDROperationJoinerModel.h"
#import "RDROperationMuteResponseModel.h"
#import "RDROperationMuteVideoResponseModel.h"
#import "RDROperationKickoutResponseModel.h"
#import "RDRAllJoinerCell.h"

typedef void(^doneAfterPinBlock)(NSString *pinStr);

@interface RDRAllJoinersView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UIButton *closeBtn;

@property (nonatomic, strong) UITableView *theTable;
@property (nonatomic, strong) UIButton *allSilenceBtn;

@property (nonatomic, strong) RDRLoadingView *loadingView;

@property (readwrite, nonatomic, copy) postInfoBlock postBlock;

@property (nonatomic, strong) NSArray *joiners;     // 全部参会人员

@end

@implementation RDRAllJoinersView

+ (void)showTableTitle:(NSString *)title withPostBlock:(postInfoBlock)postBlock {
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
    
    joinersView.postBlock = postBlock;
    
    joinersView.tipLabel.text = title;
    
    [joinersView updateFrameAndReset];
    
    [joinersView startRequestGetJoiners];
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
        [_theTable registerClass:[RDRAllJoinerCell class] forCellReuseIdentifier:@"reusedCell"];
        _theTable.dataSource = self;
        _theTable.tableFooterView = [[UIView alloc] init];
        _theTable.tableHeaderView = [[UIView alloc] init];
        _theTable.delegate = self;
        [self addSubview:_theTable];
        
        _allSilenceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _allSilenceBtn.frame = CGRectZero;
        [_allSilenceBtn setTitle:@"全部静音" forState:UIControlStateNormal];
        [_allSilenceBtn addTarget:self action:@selector(allSilenceBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        _allSilenceBtn.backgroundColor = [UIColor blueColor];
        _allSilenceBtn.layer.cornerRadius = 10.0;
        [self addSubview:_allSilenceBtn];
        
        _loadingView = [RDRLoadingView showLoadingWithTitle:@"正在获取参与者数据，请稍候" inFrame:CGRectZero];
        _loadingView.hidden = YES;
        [self addSubview:_loadingView];
    }
    
    return self;
}

// 纯111111, 不是sip:111111@zijingcloud.com
- (NSString *)joinerCurMeetingAddr {
    return [LPSystemUser takePureAddrFrom:[LPSystemUser sharedUser].curMeetingAddr];
}

- (void)showToastWithMessage:(NSString *)msg {
    if (self.postBlock) {
        self.postBlock(msg);
    }
}

- (void)hideHudAndIndicatorView {
    self.loadingView.hidden = YES;
}

- (void)startRequestGetJoiners {
    [self.loadingView resetTipStr:@"正在获取参与者数据，请稍候"];
    self.loadingView.frame = CGRectMake(self.theTable.ott_left, self.theTable.ott_top, self.theTable.ott_width, self.allSilenceBtn.ott_bottom - self.theTable.ott_top);
    [self.loadingView updateLoadingFrameAndReset];
    self.loadingView.hidden = NO;
    
    __weak RDRAllJoinersView *weakSelf = self;
//     发起请求
    RDROperationGetJoinersRequestModel *reqModel = [RDROperationGetJoinersRequestModel requestModel];
    reqModel.addr = [self joinerCurMeetingAddr];
    
    RDRRequest *req = [RDRRequest requestWithURLPath:nil model:reqModel];
    [RDRNetHelper GET:req responseModelClass:[RDROperationGetJoinersResponseModel class]
              success:^(NSURLSessionDataTask *operation, id responseObject) {
                  [weakSelf hideHudAndIndicatorView];
                  
                  RDROperationGetJoinersResponseModel *model = responseObject;
                  
                  if ([model codeCheckSuccess] == YES) {
                      NSLog(@"获取参会人员成功, model=%@", model);
                      [weakSelf showToastWithMessage:@"获取参会人员成功"];
                      weakSelf.joiners = [NSArray arrayWithArray:model.data];
                      
                      [weakSelf reloadAllData];
                  }else {
                      NSLog(@"获取参会人员失败, msg=%@", model.msg);
                      NSString *tipStr = [NSString stringWithFormat:@"获取参会人员失败, %@", model.msg];
                      [weakSelf showToastWithMessage:tipStr];
                  }
              } failure:^(NSURLSessionDataTask *operation, NSError *error) {
                  [weakSelf hideHudAndIndicatorView];
                  
                  //请求出错
                  NSLog(@"获取参会人员失败, %s, error=%@", __FUNCTION__, error);
                  NSString *tipStr = [NSString stringWithFormat:@"获取参会人员失败，服务器错误"];
                  [weakSelf showToastWithMessage:tipStr];
              }];
}

- (void)reloadAllData {
    BOOL allSilence = [self allBeenSilent];
    if (allSilence == YES) {
        [self.allSilenceBtn setTitle:@"全部取消静音" forState:UIControlStateNormal];
    }else {
        [self.allSilenceBtn setTitle:@"全部静音" forState:UIControlStateNormal];
    }
    
    [self.theTable reloadData];
}

- (void)closeClicked:(UIButton *)sender {
    UIView *bgView = [self.rd_userInfo objectForKey:@"bgView"];
    if ([bgView isKindOfClass:[UIView class]] && bgView != nil) {
        [bgView removeFromSuperview];
    }
    [self removeFromSuperview];
}

- (void)showPinInput:(doneAfterPinBlock)doneBlock {
    [ShowPinView showTitle:@"请输入PIN码" withDoneBlock:^(NSString *text) {
        if (doneBlock) {
            doneBlock(text);
        }
    } withCancelBlock:^{
        
    } withNoInput:^{
        [self showToastWithMessage:@"请输入PIN码"];
    }];
}

- (BOOL)allBeenSilent {
    // 先判断是否全部都被静音
    NSInteger i=0;
    for (; i<self.joiners.count; i++) {
        RDROperationJoinerModel *eachJoiner = [self.joiners objectAtIndex:i];
        if (eachJoiner.audio.integerValue == 1) {
            // 目前被静音
        }else {
            break;
        }
    }
    if (i == self.joiners.count) {
        // 全部被静音
        return YES;
    }else {
        // 部分被静音
        return NO;
    }
}

- (void)allSilenceBtnClicked:(UIButton *)sender {
    if ([self allBeenSilent]) {
        // 执行全部取消静音
        [self silenceWithUid:@"" doSilience:NO];
    }else {
        // 执行全部静音
        [self silenceWithUid:@"" doSilience:YES];
    }
}

- (void)silenceWithUid:(NSString *)uid doSilience:(BOOL)silenceOperation {
    
    [self showPinInput:^(NSString *pinStr) {
        RDROperationMuteRequestModel *reqModel = [RDROperationMuteRequestModel requestModel];
        reqModel.addr = [self joinerCurMeetingAddr];

        if (silenceOperation == YES) {
            reqModel.mute = @(1);
        }else {
            reqModel.mute = @(0);
        }
        
        if (uid.length == 0) {
            if (silenceOperation == YES) {
                [self.loadingView resetTipStr:@"正在全部静音，请稍候"];
            }else {
                [self.loadingView resetTipStr:@"正在取消全部静音，请稍候"];
            }
        }else {
            if (silenceOperation == YES) {
                [self.loadingView resetTipStr:@"正在静音，请稍候"];
            }else {
                [self.loadingView resetTipStr:@"正在取消静音，请稍候"];
            }
        }
        reqModel.uid = uid;
        reqModel.pin = pinStr;
        
        self.loadingView.frame = CGRectMake(self.theTable.ott_left, self.theTable.ott_top, self.theTable.ott_width, self.allSilenceBtn.ott_bottom - self.theTable.ott_top);
        [self.loadingView updateLoadingFrameAndReset];
        self.loadingView.hidden = NO;
        
        __weak RDRAllJoinersView *weakSelf = self;
//         发起请求
        RDRRequest *req = [RDRRequest requestWithURLPath:nil model:reqModel];
        [RDRNetHelper GET:req responseModelClass:[RDROperationMuteResponseModel class]
                  success:^(NSURLSessionDataTask *operation, id responseObject) {
                      weakSelf.loadingView.hidden = YES;
                      
                      RDROperationMuteResponseModel *model = responseObject;
                      
                      if ([model codeCheckSuccess] == YES) {
                          NSLog(@"操作音频成功, model=%@", model);
                          [weakSelf showToastWithMessage:@"操作成功"];
                          
                          [weakSelf updateModelAndReloadTableWithUid:uid withSilence:silenceOperation];
                      }else {
                          NSLog(@"操作音频失败, msg=%@", model.msg);
                          NSString *tipStr = [NSString stringWithFormat:@"操作失败, %@", model.msg];
                          [weakSelf showToastWithMessage:tipStr];
                      }
                  } failure:^(NSURLSessionDataTask *operation, NSError *error) {
                      weakSelf.loadingView.hidden = YES;
                      
                      //请求出错
                      NSLog(@"操作音频失败, %s, error=%@", __FUNCTION__, error);
                      NSString *tipStr = [NSString stringWithFormat:@"操作失败，服务器错误"];
                      [weakSelf showToastWithMessage:tipStr];
                  }];
    }];
}

- (void)updateModelAndReloadTableWithUid:(NSString *)uidStr withSilence:(BOOL)silence {
    // 修改所操作的model的数据
    if (uidStr.length == 0) {
        // 全部操作
        for (RDROperationJoinerModel *eachJoiner in self.joiners) {
            if (silence == YES) {
                // 全部静音
                eachJoiner.audio = @(1);
            }else {
                // 全部取消静音
                eachJoiner.audio = @(0);
            }
        }
    }else {
        // 单独操作
        for (RDROperationJoinerModel *eachJoiner in self.joiners) {
            if ([eachJoiner.uid isEqualToString:uidStr]) {
                if (silence == YES) {
                    // 单个静音
                    eachJoiner.audio = @(1);
                }else {
                    // 单个取消静音
                    eachJoiner.audio = @(0);
                }
                break;
            }
        }
    }
    
    [self reloadAllData];
}

#define offsetX 10

- (void)updateFrameAndReset {
    self.tipLabel.frame = CGRectMake(offsetX, offsetX, self.ott_width - 2 * offsetX, 40);
    self.closeBtn.frame = CGRectMake(self.ott_width - 80, offsetX, 60, 40);
    
    self.allSilenceBtn.frame = CGRectMake(offsetX, self.ott_height - 40 - offsetX, self.tipLabel.ott_width, 40);
    
    self.theTable.frame = CGRectMake(offsetX, self.closeBtn.ott_bottom + offsetX, self.tipLabel.ott_width, self.allSilenceBtn.ott_top - offsetX - (self.closeBtn.ott_bottom + offsetX));
    
    self.loadingView.frame = CGRectMake(self.theTable.ott_left, self.theTable.ott_top, self.theTable.ott_width, self.allSilenceBtn.ott_bottom - self.theTable.ott_top);
    [self.loadingView updateLoadingFrameAndReset];
}

#pragma mark UITabelView delegate & datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectio {
    return self.joiners.count;
}

#define kCellBtnWidth 30
#define kBtnInterval 30

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RDRAllJoinerCell *tableCell = (RDRAllJoinerCell *)[tableView dequeueReusableCellWithIdentifier:@"reusedCell" forIndexPath:indexPath];
    
    UIImageView *manImgView = tableCell.manTypeImgView;
    UILabel *nameLabel = tableCell.manNameLabel;
    UIButton *cellMuteVoiceBtn = tableCell.voiceBtn;
    [cellMuteVoiceBtn addTarget:self action:@selector(muteVoiceBtnClicked:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *cellMuteVedioBtn = tableCell.videoBtn;
    [cellMuteVedioBtn addTarget:self action:@selector(muteVideoBtnClicked:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *cellKickBtn = tableCell.kickBtn;
    [cellKickBtn addTarget:self action:@selector(kickBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    // 取出当前的model
    RDROperationJoinerModel *curJoiner = [self.joiners objectAtIndex:indexPath.row];
    
    manImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", (curJoiner.role.integerValue == 1) ? @"joiner_host":@"joiner_guest"]];
    nameLabel.text = curJoiner.name;
    
    cellMuteVoiceBtn.rd_userInfo = @{@"joinerModel":curJoiner};
    [cellMuteVoiceBtn setImage:[UIImage imageNamed:(curJoiner.audio.integerValue == 1 ? @"mz_muteaudio_default" : @"mz_muteaudio_on_default")] forState:UIControlStateNormal];
    [cellMuteVoiceBtn setImage:[UIImage imageNamed:(curJoiner.audio.integerValue == 1 ? @"mz_muteaudio_over" : @"mz_muteaudio_on_over")] forState:UIControlStateHighlighted];
    
    cellMuteVedioBtn.rd_userInfo = @{@"joinerModel":curJoiner};
    [cellMuteVedioBtn setImage:[UIImage imageNamed:(curJoiner.video.integerValue == 1 ? @"mz_mutevideo_default" : @"mz_mutevideo_on_default")] forState:UIControlStateNormal];
    [cellMuteVedioBtn setImage:[UIImage imageNamed:(curJoiner.video.integerValue == 1 ? @"mz_mutevideo_over" : @"mz_mutevideo_on_over")] forState:UIControlStateHighlighted];

    cellKickBtn.rd_userInfo = @{@"joinerModel":curJoiner};
    [cellKickBtn setImage:[UIImage imageNamed:@"mz_kickout_default"] forState:UIControlStateNormal];
    [cellKickBtn setImage:[UIImage imageNamed:@"mz_kickout_over"] forState:UIControlStateHighlighted];

    return tableCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)muteVoiceBtnClicked:(UIButton *)sender {
    RDROperationJoinerModel *curJoiner = (RDROperationJoinerModel *)[sender.rd_userInfo objectForKey:@"joinerModel"];
    
    [self silenceWithUid:curJoiner.uid doSilience:(curJoiner.audio.integerValue == 0)];
}

- (void)muteVideoBtnClicked:(UIButton *)sender {
    RDROperationJoinerModel *curJoiner = (RDROperationJoinerModel *)[sender.rd_userInfo objectForKey:@"joinerModel"];

    [self showPinInput:^(NSString *pinStr) {
        RDROperationMuteVideoRequestModel *reqModel = [RDROperationMuteVideoRequestModel requestModel];
        reqModel.addr = [self joinerCurMeetingAddr];
        
        if (curJoiner.video.integerValue == 0) {
            reqModel.mute = @(1);
            [self.loadingView resetTipStr:@"正在静止画面，请稍候"];
        }else {
            reqModel.mute = @(0);
            [self.loadingView resetTipStr:@"正在打开画面，请稍候"];
        }
        
        reqModel.uid = curJoiner.uid;
        reqModel.pin = pinStr;
        
        self.loadingView.frame = CGRectMake(self.theTable.ott_left, self.theTable.ott_top, self.theTable.ott_width, self.allSilenceBtn.ott_bottom - self.theTable.ott_top);
        [self.loadingView updateLoadingFrameAndReset];
        self.loadingView.hidden = NO;
        
        __weak RDRAllJoinersView *weakSelf = self;        
//         发起请求
        RDRRequest *req = [RDRRequest requestWithURLPath:nil model:reqModel];
        [RDRNetHelper GET:req responseModelClass:[RDROperationMuteVideoResponseModel class]
                  success:^(NSURLSessionDataTask *operation, id responseObject) {
                      weakSelf.loadingView.hidden = YES;
                      
                      RDROperationMuteVideoResponseModel *model = responseObject;
                      
                      if ([model codeCheckSuccess] == YES) {
                          NSLog(@"操作画面成功, model=%@", model);
                          [weakSelf showToastWithMessage:@"操作成功"];
                          
                          [weakSelf updateModelAndReloadTable:curJoiner];
                      }else {
                          NSLog(@"操作画面失败, msg=%@", model.msg);
                          NSString *tipStr = [NSString stringWithFormat:@"操作失败, %@", model.msg];
                          [weakSelf showToastWithMessage:tipStr];
                      }
                  } failure:^(NSURLSessionDataTask *operation, NSError *error) {
                      weakSelf.loadingView.hidden = YES;
                      
                      //请求出错
                      NSLog(@"操作画面失败, %s, error=%@", __FUNCTION__, error);
                      NSString *tipStr = [NSString stringWithFormat:@"操作失败，服务器错误"];
                      [weakSelf showToastWithMessage:tipStr];
                  }];
    }];
}

- (void)updateModelAndReloadTable:(RDROperationJoinerModel *)model {
    if (model.video.integerValue == 0) {
        model.video = @(1);
    }else {
        model.video = @(0);
    }
    
    [self.theTable reloadData];
}

- (void)kickBtnClicked:(UIButton *)sender {
    RDROperationJoinerModel *curJoiner = (RDROperationJoinerModel *)[sender.rd_userInfo objectForKey:@"joinerModel"];
    
    [self showPinInput:^(NSString *pinStr) {
        RDROperationKickoutRequestModel *reqModel = [RDROperationKickoutRequestModel requestModel];
        reqModel.addr = [self joinerCurMeetingAddr];
        
        [self.loadingView resetTipStr:@"正在踢出该参会者，请稍候"];
        
        reqModel.uid = curJoiner.uid;
        reqModel.pin = pinStr;
        
        self.loadingView.frame = CGRectMake(self.theTable.ott_left, self.theTable.ott_top, self.theTable.ott_width, self.allSilenceBtn.ott_bottom - self.theTable.ott_top);
        [self.loadingView updateLoadingFrameAndReset];
        self.loadingView.hidden = NO;
        
        __weak RDRAllJoinersView *weakSelf = self;        
//         发起请求
        RDRRequest *req = [RDRRequest requestWithURLPath:nil model:reqModel];
        [RDRNetHelper GET:req responseModelClass:[RDROperationKickoutResponseModel class]
                  success:^(NSURLSessionDataTask *operation, id responseObject) {
                      weakSelf.loadingView.hidden = YES;
                      
                      RDROperationKickoutResponseModel *model = responseObject;
                      
                      if ([model codeCheckSuccess] == YES) {
                          NSLog(@"踢出该会议者成功, model=%@", model);
                          [weakSelf showToastWithMessage:@"踢出该会议者成功"];
                          
                          [weakSelf kickOutSuccessAndReloadTable:curJoiner];
                      }else {
                          NSLog(@"踢出该会议者失败, msg=%@", model.msg);
                          NSString *tipStr = [NSString stringWithFormat:@"操作失败, %@", model.msg];
                          [weakSelf showToastWithMessage:tipStr];
                      }
                  } failure:^(NSURLSessionDataTask *operation, NSError *error) {
                      weakSelf.loadingView.hidden = YES;
                      
                      //请求出错
                      NSLog(@"踢出该会议者失败, %s, error=%@", __FUNCTION__, error);
                      NSString *tipStr = [NSString stringWithFormat:@"操作失败，服务器错误"];
                      [weakSelf showToastWithMessage:tipStr];
                  }];
    }];
}

- (void)kickOutSuccessAndReloadTable:(RDROperationJoinerModel *)model {
    NSUInteger index = [self.joiners indexOfObject:model];
    if (index == NSNotFound) {
        // 未找到，出错处理
    }else {
        // 找到，移除掉
        NSMutableArray *oldArr = [NSMutableArray arrayWithArray:self.joiners];
        [oldArr removeObjectAtIndex:index];
        
        self.joiners = [NSArray arrayWithArray:oldArr];
        [self.theTable reloadData];
    }
}

@end
