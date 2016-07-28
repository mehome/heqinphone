//
//  LPVideoClickToPlayCell.h
//  linphone
//
//  Created by heqin on 16/5/19.
//
//

#import <UIKit/UIKit.h>

@interface LPVideoClickToPlayCell : UITableViewCell

@property (nonatomic, strong) UILabel *videoNameLabel;
@property (nonatomic, strong) UILabel *videoDescLabel;
@property (nonatomic, strong) UILabel *videoDateLabel;

@property (nonatomic, assign) BOOL isLiveVideo;     // 是否为直播
@property (nonatomic, assign) BOOL isSec;           // 是否进行加密

@end
