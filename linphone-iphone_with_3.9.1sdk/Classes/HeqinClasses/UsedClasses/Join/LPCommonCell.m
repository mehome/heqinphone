//
//  LPCommonCell.m
//  linphone
//
//  Created by heqin on 16/1/30.
//
//

#import "LPCommonCell.h"

@implementation LPCommonCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 44)];
        self.leftLabel.font = [UIFont systemFontOfSize:17.0];
        
        self.rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 0, 120, 44)];
        self.rightLabel.font = [UIFont systemFontOfSize:15.0];
      
        self.topBtn = [UIButton buttonWithType:UIButtonTypeCustom];

        [self.contentView addSubview:self.leftLabel];
        [self.contentView addSubview:self.rightLabel];
        [self.contentView addSubview:self.topBtn];
        
#if inDebugTest
        self.leftLabel.backgroundColor = [UIColor blueColor];
        self.rightLabel.backgroundColor = [UIColor greenColor];
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
    
    self.leftLabel.ott_width = self.ott_width/2.0;
    self.leftLabel.ott_height = self.ott_height;
    
    self.rightLabel.ott_left = self.leftLabel.ott_right;
    self.rightLabel.ott_height = self.ott_height;
    
    self.rightLabel.ott_width = self.ott_width/2.0;
    
    self.topBtn.frame = CGRectMake(0, 0, self.ott_width, self.ott_height);
}

@end
