//
//  LPCellJoinManageTableViewCell.h
//  linphone
//
//  Created by heqin on 15/11/16.
//
//

#import <UIKit/UIKit.h>
#import "RDRJoinMeetingModel.h"

@interface LPCellJoinManageTableViewCell : UITableViewCell

- (void)updateWithObject:(RDRJoinMeetingModel *)model;

@end
