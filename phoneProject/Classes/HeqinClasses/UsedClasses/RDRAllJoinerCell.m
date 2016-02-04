//
//  RDRAllJoinerCell.m
//  linphone
//
//  Created by heqin on 16/2/2.
//
//

#import "RDRAllJoinerCell.h"

@interface RDRAllJoinerCell ()



@end

@implementation RDRAllJoinerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.manTypeImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 4, 36, 36)];
        
        self.manNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
        
        self.voiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.voiceBtn.frame = CGRectMake(0, 0, 60, 44);
        self.voiceBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [self.voiceBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.voiceBtn setTitle:@"静音" forState:UIControlStateNormal];
        
        self.videoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.videoBtn.frame = CGRectMake(0, 0, 60, 44);
        self.videoBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [self.videoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.videoBtn setTitle:@"静画" forState:UIControlStateNormal];
        
        self.kickBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.kickBtn.frame = CGRectMake(0, 0, 60, 44);
        self.kickBtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [self.kickBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.kickBtn setTitle:@"踢出" forState:UIControlStateNormal];
        
        [self.contentView addSubview:self.manTypeImgView];
        [self.contentView addSubview:self.manNameLabel];
        [self.contentView addSubview:self.voiceBtn];
        [self.contentView addSubview:self.videoBtn];
        [self.contentView addSubview:self.kickBtn];
        
#if inDebugTest
        self.manTypeImgView.backgroundColor = [UIColor blueColor];
        self.manNameLabel.backgroundColor = [UIColor greenColor];
        self.voiceBtn.backgroundColor = [UIColor redColor];
        self.videoBtn.backgroundColor = [UIColor yellowColor];
        self.kickBtn.backgroundColor = [UIColor blueColor];
#else
        self.manTypeImgView.backgroundColor = [UIColor clearColor];
        self.manNameLabel.backgroundColor = [UIColor clearColor];
        self.voiceBtn.backgroundColor = [UIColor clearColor];
        self.videoBtn.backgroundColor = [UIColor clearColor];
        self.kickBtn.backgroundColor = [UIColor clearColor];
#endif
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.manTypeImgView.ott_left = 0;
    self.manNameLabel.ott_left = self.manTypeImgView.ott_right;
    
    self.kickBtn.ott_left = self.ott_width-self.kickBtn.ott_width;
    self.videoBtn.ott_left = self.kickBtn.ott_left-self.videoBtn.ott_width;
    self.voiceBtn.ott_left = self.videoBtn.ott_left - self.voiceBtn.ott_width;
    
    self.manNameLabel.ott_width = self.voiceBtn.ott_left - self.manNameLabel.ott_left;
}

@end
