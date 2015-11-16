//
//  LPCellJoinManageTableViewCell.m
//  linphone
//
//  Created by heqin on 15/11/16.
//
//

#import "LPCellJoinManageTableViewCell.h"

@interface LPCellJoinManageTableViewCell ()

@property (nonatomic, weak) IBOutlet UILabel *nameLabe;
@property (nonatomic, weak) IBOutlet UILabel *idLabe;
@property (nonatomic, weak) IBOutlet UILabel *addrLabe;
@property (nonatomic, weak) IBOutlet UILabel *timeLabe;
@property (nonatomic, weak) IBOutlet UILabel *descLabe;

@end

@implementation LPCellJoinManageTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)updateWithObject:(RDRJoinMeetingModel *)model {
    self.nameLabe.text = model.name;
    self.idLabe.text = [NSString stringWithFormat:@"%@", model.idNum];
    self.addrLabe.text = model.addr;
    self.timeLabe.text = model.time;
    self.descLabe.text = model.desc;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
