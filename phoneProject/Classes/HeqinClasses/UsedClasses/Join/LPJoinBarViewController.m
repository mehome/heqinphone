//
//  LPJoinBarViewController.m
//  linphone
//
//  Created by heqin on 15/11/7.
//
//

#import "LPJoinBarViewController.h"
#import "PhoneMainView.h"
#import "LPJoinMettingViewController.h"
#import "LPJoinManageMeetingViewController.h"
#import "LPSystemUser.h"
#import "LPLoginViewController.h"
#import "LPSettingViewController.h"
#import "LPMyMeetingManageViewController.h"
#import "LPMyMeetingArrangeViewController.h"
#import "LPRecordAndPlayViewController.h"
#import "LPBottomButton.h"
#import "UIButton+LPUIButtonImageWithLable.h"

#define kChangeStateNotification @"StateChangeNotifcation"

@implementation LPSButton

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initNotification];
    }
    
    return self;
}

- (void)initNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeStateNotification:) name:kChangeStateNotification object:nil];
}

- (void)changeStateNotification:(NSNotification *)notif {
    if (notif.object != self) {
        [self setSelected:NO];
    }else {
        [self setSelected:YES];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initNotification];
    }
    
    return self;
}

- (void)layoutSubviews {
    // 动态设置图片与文字的位置
//    self.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
//    self.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

@interface LPJoinBarViewController ()

@property (weak, nonatomic) IBOutlet UIButton *firstBtn;
@property (weak, nonatomic) IBOutlet UIButton *secondBtn;
@property (weak, nonatomic) IBOutlet UIButton *thirdBtn;
@property (strong, nonatomic) IBOutlet UIButton *recordBtn;
@property (weak, nonatomic) IBOutlet UIButton *forthBtn;

@end


@implementation LPJoinBarViewController

- (void)changeBtn:(UIButton *)btn {
    btn.titleLabel.font = [UIFont systemFontOfSize:11.0];
    
    [btn.titleLabel sizeToFit];
    CGSize titleSize = btn.titleLabel.frame.size;// [btn.titleLabel.text sizeWithFont:btn.titleLabel.font];
    [btn.imageView setContentMode:UIViewContentModeCenter];
    [btn setImageEdgeInsets:UIEdgeInsetsMake(-12.0,
                                              0.0,
                                              0.0,
                                              -titleSize.width)];

    [btn.titleLabel setContentMode:UIViewContentModeCenter];
    [btn.titleLabel setBackgroundColor:[UIColor clearColor]];
    [btn.imageView sizeToFit];
    CGSize imgSize = btn.imageView.frame.size;
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(34.0,
                                              -imgSize.width,
                                              0.0,
                                              0.0)];
}

- (void)setAllBtns {
    [self.firstBtn setImage:[UIImage imageNamed:@"b_joinMetting.png"] forState:UIControlStateNormal];
    [self.secondBtn setImage:[UIImage imageNamed:@"b_meetingSetting.png"] forState:UIControlStateNormal];
    [self.thirdBtn setImage:[UIImage imageNamed:@"b_meetingSetting.png"] forState:UIControlStateNormal];
    [self.recordBtn setImage:[UIImage imageNamed:@"b_record.png"] forState:UIControlStateNormal];
    [self.forthBtn setImage:[UIImage imageNamed:@"b_settings.png"] forState:UIControlStateNormal];
    
    [self.firstBtn setImage:[UIImage imageNamed:@"b_joinMetting.png"] forState:UIControlStateHighlighted];
    [self.secondBtn setImage:[UIImage imageNamed:@"b_meetingSetting.png"] forState:UIControlStateHighlighted];
    [self.thirdBtn setImage:[UIImage imageNamed:@"b_meetingSetting.png"] forState:UIControlStateHighlighted];
    [self.recordBtn setImage:[UIImage imageNamed:@"b_record.png"] forState:UIControlStateHighlighted];
    [self.forthBtn setImage:[UIImage imageNamed:@"b_settings.png"] forState:UIControlStateHighlighted];
    
    [self.firstBtn setTitle:@"加入会议" forState:UIControlStateNormal];
    [self.secondBtn setTitle:@"会议管理" forState:UIControlStateNormal];
    [self.thirdBtn setTitle:@"安排会议" forState:UIControlStateNormal];
    [self.recordBtn setTitle:@"录像" forState:UIControlStateNormal];
    [self.forthBtn setTitle:@"设置" forState:UIControlStateNormal];
    
    [self.firstBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.secondBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.thirdBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.recordBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.forthBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.firstBtn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    [self.secondBtn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    [self.thirdBtn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    [self.recordBtn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    [self.forthBtn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
    
    // 调整布局
    [self changeBtn:self.firstBtn];
    [self changeBtn:self.secondBtn];
    [self changeBtn:self.thirdBtn];
    [self changeBtn:self.recordBtn];
    [self changeBtn:self.forthBtn];

    [self.firstBtn setSelected:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(btnStateChanged:) name:kChangeStateNotification object:nil];
}

- (void)btnStateChanged:(NSNotification *)noti {
    NSLog(@"notif.obj=%@, userInfo=%@", noti.object, noti.userInfo);
    
    [self.firstBtn setSelected:(self.firstBtn==noti.object)];
    [self.secondBtn setSelected:(self.secondBtn==noti.object)];
    [self.thirdBtn setSelected:(self.thirdBtn==noti.object)];
    [self.recordBtn setSelected:(self.recordBtn==noti.object)];
    [self.forthBtn setSelected:(self.forthBtn==noti.object)];
}

- (id)init {
    return [super initWithNibName:@"LPJoinBarViewController" bundle:[NSBundle mainBundle]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    [self.firstBtn setImage:[UIImage imageNamed:@"b_joinMetting.png"]
//                  withTitle:@"参加会议"
//                   forState:UIControlStateNormal];
//    [self.secondBtn setImage:[UIImage imageNamed:@"b_meetingSetting.png"]
//                  withTitle:@"管理会议"
//                   forState:UIControlStateNormal];
//    [self.thirdBtn setImage:[UIImage imageNamed:@"b_meetingSetting.png"]
//                   withTitle:@"安排会议"
//                    forState:UIControlStateNormal];
//    [self.forthBtn setImage:[UIImage imageNamed:@"b_settings.png"]
//                   withTitle:@"设置"
//                    forState:UIControlStateNormal];
    
    [self setAllBtns];
}

// 参加会议
- (IBAction)joinMeetingBtnClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kChangeStateNotification object:sender];

    [[PhoneMainView instance] changeCurrentView:[LPJoinMettingViewController compositeViewDescription]];
}

// 管理我的会议
- (IBAction)joinManageMeetingBtnClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kChangeStateNotification object:sender];
    
    // 切换到首页的会议
    // 判断用户是否登录，未登录，则弹出登录界面
    if ( kNotLoginCheck ) {
        [[PhoneMainView instance] changeCurrentView:[LPLoginViewController compositeViewDescription] push:YES];
    }else {
        // 进入到管理我的会议界面
        [[PhoneMainView instance] changeCurrentView:[LPMyMeetingManageViewController compositeViewDescription]];
    }
}

// 安排会议
- (IBAction)arrangeBtnClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kChangeStateNotification object:sender];

    if ( kNotLoginCheck) {
        [[PhoneMainView instance] changeCurrentView:[LPLoginViewController compositeViewDescription] push:YES];
    }else {
        // 进入到会议安排界面
        [[PhoneMainView instance] changeCurrentView:[LPMyMeetingArrangeViewController compositeViewDescription]];
    }
}

// 录像
- (IBAction)recordBtnClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kChangeStateNotification object:sender];
    
    if ( kNotLoginCheck) {
        [[PhoneMainView instance] changeCurrentView:[LPLoginViewController compositeViewDescription] push:YES];
    }else {
        // 进入到会议安排界面
        [[PhoneMainView instance] changeCurrentView:[LPRecordAndPlayViewController compositeViewDescription]];
    }
}

// 设置
- (IBAction)settingBtnClicked:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kChangeStateNotification object:sender];

    [[PhoneMainView instance] changeCurrentView:[LPSettingViewController compositeViewDescription]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
