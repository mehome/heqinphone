//
//  ShowMeetingLayoutView.m
//  linphone
//
//  Created by baidu on 16/6/6.
//
//

#import "ShowMeetingLayoutView.h"
#import "RadioButton.h"
#import "BTMToast.h"

@interface ShowMeetingLayoutView ()

@property (nonatomic, assign) MeetingType curType;
@property (readwrite, nonatomic, copy) meetingLayoutOkBlock confirmDone;
@property (readwrite, nonatomic, copy) meetingLayoutCancelBlock cancelDone;

@property (nonatomic, strong) UIView *zimuContainerView;
@property (nonatomic, strong) UIView *zcrContainerView;
@property (nonatomic, strong) UIView *fkContainerView;

@property (nonatomic, strong) UIButton *doneBtn;
@property (nonatomic, strong) UIButton *cancelBtn;

@property (nonatomic, strong) NSMutableDictionary *mutDic;

@end

@implementation ShowMeetingLayoutView
@synthesize zimuContainerView;
@synthesize zcrContainerView;
@synthesize fkContainerView;

+ (ShowMeetingLayoutView *)showLayoutType:(MeetingType)type withDoneBlock:(meetingLayoutOkBlock)
doneBlock withCancelBlock:(meetingLayoutCancelBlock)cancelBlock {
    UIView *bgView = [[UIView alloc] initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    bgView.backgroundColor = [UIColor grayColor];
    bgView.alpha = 0.5;

    [[UIApplication sharedApplication].keyWindow addSubview:bgView];

    ShowMeetingLayoutView *pinView = [[ShowMeetingLayoutView alloc] initWithFrame:CGRectMake(20, 60, bgView.ott_width-20*2, 130) withType:type];
    [[UIApplication sharedApplication].keyWindow addSubview:pinView];
    pinView.backgroundColor = [UIColor whiteColor];
    pinView.layer.cornerRadius = 5.0;
    pinView.rd_userInfo = @{@"bgView":bgView};

    pinView.confirmDone = doneBlock;
    pinView.cancelDone = cancelBlock;
    
//    [pinView updateFrameAndReset];

    return pinView;
}

#define kFengxie 5
#define offsetX 10

- (instancetype)initWithFrame:(CGRect)frame withType:(MeetingType)type {
    CGFloat curYlocation = 0.0;

    if (self = [super initWithFrame:frame]) {
        _curType = type;
        
        // 添加显示字幕
        zimuContainerView = [[UIView alloc] initWithFrame:CGRectMake(10, curYlocation, 200, 50)];
        zimuContainerView.userInteractionEnabled = YES;
        
        UILabel *zimuLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kFengxie, zimuContainerView.ott_width-2*kFengxie, 22)];
        zimuLabel.textAlignment = NSTextAlignmentCenter;
        zimuLabel.backgroundColor = [UIColor grayColor];
        zimuLabel.textAlignment = NSTextAlignmentCenter;
        zimuLabel.text = @"显示字幕";
        [zimuContainerView addSubview:zimuLabel];

        RadioButton *rb0 = [[RadioButton alloc] initWithGroupId:@"zimuGround" index:1];
        RadioButton *rb1 = [[RadioButton alloc] initWithGroupId:@"zimuGround" index:0];
        rb0.frame = CGRectMake(0, zimuLabel.ott_bottom, 22, 22);
        rb1.frame = CGRectMake(60, zimuLabel.ott_bottom, 22, 22);
        [zimuContainerView addSubview:rb0];
        [zimuContainerView addSubview:rb1];
        
        UILabel *tp0 = [[UILabel alloc] initWithFrame:CGRectMake(rb0.ott_right, rb0.ott_posY, 50, rb0.ott_height)];
        tp0.text = @"显示";
        tp0.font = [UIFont systemFontOfSize:13];
        [zimuContainerView addSubview:tp0];
        
        UILabel *tp1 = [[UILabel alloc] initWithFrame:CGRectMake(rb1.ott_right, rb1.ott_posY, 50, rb1.ott_height)];
        tp1.text = @"不显示";
        tp1.font = [UIFont systemFontOfSize:13];
        [zimuContainerView addSubview:tp1];
        
        zimuContainerView.ott_height = tp1.ott_bottom;
        
        [self addSubview:zimuContainerView];
        
        curYlocation += zimuContainerView.ott_height + 10;
        
        // 添加主持人布局
        zcrContainerView = [[UIView alloc] initWithFrame:CGRectMake(10, curYlocation, 125, 100)];
        
        UILabel *zcrLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kFengxie, zcrContainerView.ott_width-2*kFengxie, 22)];
        zcrLabel.textAlignment = NSTextAlignmentCenter;
        zcrLabel.backgroundColor = [UIColor grayColor];
        zcrLabel.text = @"主持人布局";
        [zcrContainerView addSubview:zcrLabel];
        
    {
        // 添加显示字幕
        RadioButton *k0 = [[RadioButton alloc] initWithGroupId:@"zcrGround" index:0];
        RadioButton *k1 = [[RadioButton alloc] initWithGroupId:@"zcrGround" index:1];
        RadioButton *k2 = [[RadioButton alloc] initWithGroupId:@"zcrGround" index:2];
        RadioButton *k3 = [[RadioButton alloc] initWithGroupId:@"zcrGround" index:3];
        RadioButton *k4 = [[RadioButton alloc] initWithGroupId:@"zcrGround" index:4];
        k0.frame = CGRectMake(0, zcrLabel.ott_bottom, 22, 22);
        k1.frame = CGRectMake(0, k0.ott_bottom, 22, 22);
        k2.frame = CGRectMake(0, k1.ott_bottom, 22, 22);
        k3.frame = CGRectMake(0, k2.ott_bottom, 22, 22);
        k4.frame = CGRectMake(0, k3.ott_bottom, 22, 22);

        [zcrContainerView addSubview:k0];
        [zcrContainerView addSubview:k1];
        [zcrContainerView addSubview:k2];
        [zcrContainerView addSubview:k3];
        [zcrContainerView addSubview:k4];
        
        UILabel *j0 = [[UILabel alloc] initWithFrame:CGRectMake(k0.ott_right, k0.ott_posY, 100, k0.ott_height)];
        j0.text = @"一个主持人大屏";
        j0.font = [UIFont systemFontOfSize:13];
        [zcrContainerView addSubview:j0];
        
        UILabel *j1 = [[UILabel alloc] initWithFrame:CGRectMake(k1.ott_right, k1.ott_posY, 100, k1.ott_height)];
        j1.text = @"1等分屏";
        j1.font = [UIFont systemFontOfSize:13];
        [zcrContainerView addSubview:j1];

        UILabel *j2 = [[UILabel alloc] initWithFrame:CGRectMake(k2.ott_right, k2.ott_posY, 100, k2.ott_height)];
        j2.text = @"1大7小布局";
        j2.font = [UIFont systemFontOfSize:13];
        [zcrContainerView addSubview:j2];

        UILabel *j3 = [[UILabel alloc] initWithFrame:CGRectMake(k3.ott_right, k3.ott_posY, 100, k3.ott_height)];
        j3.text = @"1大21小布局";
        j3.font = [UIFont systemFontOfSize:13];
        [zcrContainerView addSubview:j3];
        
        UILabel *j4 = [[UILabel alloc] initWithFrame:CGRectMake(k4.ott_right, k4.ott_posY, 100, k4.ott_height)];
        j4.text = @"2大21小布局";
        j4.font = [UIFont systemFontOfSize:13];
        [zcrContainerView addSubview:j4];
        
        zcrContainerView.ott_height = j4.ott_bottom;
        
        [self addSubview:zcrContainerView];
    }
        curYlocation += zcrContainerView.ott_height + 10;

        // 添加访客布局
        if (type == MeetingTypeLesson) {
            fkContainerView = [[UIView alloc] initWithFrame:CGRectMake(10, curYlocation, zcrContainerView.ott_width, zcrContainerView.ott_height)];
            
            UILabel *fkLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kFengxie, fkContainerView.ott_width, 22)];
            fkLabel.textAlignment = NSTextAlignmentCenter;
            fkLabel.backgroundColor = [UIColor grayColor];
            fkLabel.text = @"访客布局";
            [fkContainerView addSubview:fkLabel];
            
            // 添加显示字幕
            RadioButton *m0 = [[RadioButton alloc] initWithGroupId:@"jkGround" index:0];
            RadioButton *m1 = [[RadioButton alloc] initWithGroupId:@"jkGround" index:1];
            RadioButton *m2 = [[RadioButton alloc] initWithGroupId:@"jkGround" index:2];
            RadioButton *m3 = [[RadioButton alloc] initWithGroupId:@"jkGround" index:3];
            RadioButton *m4 = [[RadioButton alloc] initWithGroupId:@"jkGround" index:4];
            m0.frame = CGRectMake(0, fkLabel.ott_bottom, 22, 22);
            m1.frame = CGRectMake(0, m0.ott_bottom, 22, 22);
            m2.frame = CGRectMake(0, m1.ott_bottom, 22, 22);
            m3.frame = CGRectMake(0, m2.ott_bottom, 22, 22);
            m4.frame = CGRectMake(0, m3.ott_bottom, 22, 22);
            
            [fkContainerView addSubview:m0];
            [fkContainerView addSubview:m1];
            [fkContainerView addSubview:m2];
            [fkContainerView addSubview:m3];
            [fkContainerView addSubview:m4];
            
            UILabel *j0 = [[UILabel alloc] initWithFrame:CGRectMake(m0.ott_right, m0.ott_posY, 100, m0.ott_height)];
            j0.text = @"一个主持人大屏";
            j0.font = [UIFont systemFontOfSize:13];
            [fkContainerView addSubview:j0];
            
            UILabel *j1 = [[UILabel alloc] initWithFrame:CGRectMake(m1.ott_right, m1.ott_posY, 100, m1.ott_height)];
            j1.text = @"1等分屏";
            j1.font = [UIFont systemFontOfSize:13];
            [fkContainerView addSubview:j1];
            
            UILabel *j2 = [[UILabel alloc] initWithFrame:CGRectMake(m2.ott_right, m2.ott_posY, 100, m2.ott_height)];
            j2.text = @"1大7小布局";
            j2.font = [UIFont systemFontOfSize:13];
            [fkContainerView addSubview:j2];
            
            UILabel *j3 = [[UILabel alloc] initWithFrame:CGRectMake(m3.ott_right, m3.ott_posY, 100, m3.ott_height)];
            j3.text = @"1大21小布局";
            j3.font = [UIFont systemFontOfSize:13];
            [fkContainerView addSubview:j3];
            
            UILabel *j4 = [[UILabel alloc] initWithFrame:CGRectMake(m4.ott_right, m4.ott_posY, 100, m4.ott_height)];
            j4.text = @"2大21小布局";
            j4.font = [UIFont systemFontOfSize:13];
            [fkContainerView addSubview:j4];
            
            fkContainerView.ott_height = j4.ott_bottom;
            
            [self addSubview:fkContainerView];

            curYlocation += fkContainerView.ott_height + 10;
        }else {
            // 会议模式只有一个设置
        }
        
        [RadioButton addObserverForGroupId:@"zimuGround" observer:self];
        [RadioButton addObserverForGroupId:@"zcrGround" observer:self];
        [RadioButton addObserverForGroupId:@"jkGround" observer:self];

        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.frame = CGRectMake(offsetX, curYlocation + offsetX, (self.ott_width - 2*offsetX)/2.0, 40);
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(cancelClicked:) forControlEvents:UIControlEventTouchUpInside];
        _cancelBtn.backgroundColor = [UIColor blueColor];
        _cancelBtn.layer.cornerRadius = 10.0;
        [self addSubview:_cancelBtn];
        
        _doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _doneBtn.frame = CGRectMake(self.cancelBtn.ott_right + offsetX, self.cancelBtn.ott_top, self.cancelBtn.ott_width, self.cancelBtn.ott_height);
        [_doneBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_doneBtn addTarget:self action:@selector(doneClicked:) forControlEvents:UIControlEventTouchUpInside];
        _doneBtn.backgroundColor = [UIColor blueColor];
        _doneBtn.layer.cornerRadius = 10.0;
        [self addSubview:_doneBtn];
        
        curYlocation += _cancelBtn.ott_height;
    }
    
    self.ott_height = curYlocation + 10;
    
    _mutDic = [NSMutableDictionary dictionary];
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 动态调整布局
    [self updateFrameAndReset];
}

- (void)updateFrameAndReset {
//    self.tipLabel.frame = CGRectMake(offsetX, offsetX, self.ott_width - 2 * offsetX, 40);
//    
//    self.inputField.frame = CGRectMake(offsetX, self.tipLabel.ott_bottom, self.tipLabel.ott_width, 30);
//    
//    self.cancelBtn.frame = CGRectMake(offsetX, self.inputField.ott_bottom + offsetX, (self.tipLabel.ott_width - offsetX)/2.0, 40);
//    self.doneBtn.frame = CGRectMake(self.cancelBtn.ott_right + offsetX, self.cancelBtn.ott_top, self.cancelBtn.ott_width, self.cancelBtn.ott_height);
//    self.ott_height = self.doneBtn.ott_bottom + offsetX;
    
    // 最后把自己放在背景界面中进行居中处理
    UIView *bgView = [self.rd_userInfo objectForKey:@"bgView"];
    bgView.frame = [UIApplication sharedApplication].keyWindow.bounds;
    
//    self.frame = CGRectMake(20, 60, MIN(bgView.ott_width, bgView.ott_height)-20*2, 130);
    self.ott_left = (bgView.ott_width-self.ott_width) /2.0;
    
    if (bgView.ott_width > bgView.ott_height) {
        // 横屏
        // 然后再把上面的几个container分别进行居中处理
        self.zimuContainerView.ott_centerX = self.ott_width/2.0;
        
        CGFloat bothWidth = self.zcrContainerView.ott_width + self.fkContainerView.ott_width;
        self.zcrContainerView.ott_left = (self.ott_width-bothWidth)/2.0;
        self.fkContainerView.ott_left = self.zcrContainerView.ott_right;
        
        self.zcrContainerView.ott_top = self.zimuContainerView.ott_bottom;
        self.fkContainerView.ott_top = self.zcrContainerView.ott_top;
        
    }else {
        // 竖屏
        // 然后再把上面的几个container分别进行居中处理
        self.zimuContainerView.ott_centerX = self.ott_width/2.0;
        self.zcrContainerView.ott_centerX = self.ott_width/2.0;
        self.fkContainerView.ott_centerX = self.ott_width/2.0;
        
        self.zcrContainerView.ott_top = self.zimuContainerView.ott_bottom;
        self.fkContainerView.ott_top = self.zcrContainerView.ott_bottom;
    }
    
    if (self.curType == MeetingTypeLesson) {
        // 有讲师与访客
        self.cancelBtn.ott_top = self.fkContainerView.ott_bottom;
    }else {
        // 只有讲师
        self.cancelBtn.ott_top = self.zcrContainerView.ott_bottom;
    }
    
    self.cancelBtn.ott_left = (self.ott_width-2*self.cancelBtn.ott_width)/2.0;
    
    self.doneBtn.ott_left = self.cancelBtn.ott_right;
    self.doneBtn.ott_top = self.cancelBtn.ott_top;
    
    self.ott_height = self.doneBtn.ott_bottom;
}

- (void)clear {
    [self.mutDic removeAllObjects];
}

//代理方法
-(void)radioButtonSelectedAtIndex:(NSUInteger)index inGroup:(NSString*)groupId {
    [self.mutDic setObject:@(index) forKey:groupId];
}

- (void)doneClicked:(UIButton *)sender {

    // 判断是否都进行了选择，如果没有进行选择，则进行tip提示
    if ([self.mutDic objectForKey:@"zimuGround"] == nil) {
        // 未选择是否显示字幕
        [[BTMToast sharedInstance] showToast:@"请设置是否显示字幕"];
        return;
    }
    
    if ([self.mutDic objectForKey:@"zcrGround"] == nil) {
        [[BTMToast sharedInstance] showToast:@"请选择主持人布局"];
        // 未选择主持人布局
        return;
    }
    
    if (self.curType == MeetingTypeLesson && ([self.mutDic objectForKey:@"jkGround"] == nil)) {
        // 未选择访客布局
        [[BTMToast sharedInstance] showToast:@"请设置访客布局"];
        return;
    }
    
    if (self.confirmDone) {
        self.confirmDone(self.mutDic);
    }
    
    [self removeZYRadioObservers];
    
    UIView *bgView = [self.rd_userInfo objectForKey:@"bgView"];
    if ([bgView isKindOfClass:[UIView class]] && bgView != nil) {
        [bgView removeFromSuperview];
    }
    [self removeFromSuperview];
}

- (void)cancelClicked:(UIButton *)sender {
    [self removeZYRadioObservers];
    
    if (self.cancelDone != nil) {
        self.cancelDone();
    }
    
    UIView *bgView = [self.rd_userInfo objectForKey:@"bgView"];
    if ([bgView isKindOfClass:[UIView class]] && bgView != nil) {
        [bgView removeFromSuperview];
    }
    [self removeFromSuperview];
}

- (void)removeZYRadioObservers {
    [RadioButton removeObserverForGroupId:@"zimuGround"];
    [RadioButton removeObserverForGroupId:@"zcrGround"];
    [RadioButton removeObserverForGroupId:@"jkGround"];
    
    [RadioButton clearAllRadioBtn];
    
    [self.mutDic removeAllObjects];
}

@end
