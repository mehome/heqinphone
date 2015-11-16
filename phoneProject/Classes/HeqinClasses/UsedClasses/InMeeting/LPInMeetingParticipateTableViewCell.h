//
//  LPInMeetingParticipateTableViewCell.h
//  linphone
//
//  Created by baidu on 15/11/16.
//
//

#import <UIKit/UIKit.h>

@interface LPInMeetingParticipateTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *silentSoundBtn;
@property (weak, nonatomic) IBOutlet UIButton *silentMovieBtn;
@property (weak, nonatomic) IBOutlet UIButton *kickOffBtn;

@end
