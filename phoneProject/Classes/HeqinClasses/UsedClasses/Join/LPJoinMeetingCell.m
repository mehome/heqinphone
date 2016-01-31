//
//  LPJoinMeetingCell.m
//  linphone
//
//  Created by heqin on 16/1/30.
//
//

#import "LPJoinMeetingCell.h"

@interface LPJoinMeetingCell ()

@end

@implementation LPJoinMeetingCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 44)];
        self.leftLabel.font = [UIFont systemFontOfSize:17.0];
        
        self.rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 0, 120, 44)];
        self.rightLabel.font = [UIFont systemFontOfSize:15.0];
        
        self.favBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.favBtn.frame = CGRectMake(0, 0, 44, 44);
        [self.favBtn setImage:[UIImage imageNamed:@"fav"] forState:UIControlStateNormal];
        
        self.topBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [self.contentView addSubview:self.leftLabel];
        [self.contentView addSubview:self.rightLabel];
        [self.contentView addSubview:self.favBtn];
        [self.contentView addSubview:self.topBtn];
        
#if inDebugTest
        self.leftLabel.backgroundColor = [UIColor blueColor];
        self.rightLabel.backgroundColor = [UIColor greenColor];
        self.favBtn.backgroundColor = [UIColor yellowColor];
        self.topBtn.backgroundColor = [UIColor redColor];
#endif
        
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

    self.leftLabel.ott_width = self.ott_width/3.0;
    self.favBtn.ott_left = self.ott_width - self.favBtn.ott_width;
    self.rightLabel.ott_right = self.favBtn.ott_left - 10;
    
    self.topBtn.frame = CGRectMake(0, 0, self.favBtn.ott_left-10, self.ott_height);
}

@end
