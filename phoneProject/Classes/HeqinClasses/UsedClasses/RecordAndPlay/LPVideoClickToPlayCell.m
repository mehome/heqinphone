//
//  LPVideoClickToPlayCell.m
//  linphone
//
//  Created by heqin on 16/5/19.
//
//

#import "LPVideoClickToPlayCell.h"

@interface LPVideoClickToPlayCell ()

@property (nonatomic, strong) UIImageView *typeMrkImgView;
@property (nonatomic, strong) UIImageView *secMarkImgView;

@end

@implementation LPVideoClickToPlayCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.typeMrkImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 24, 24)];
        
        self.videoNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, 5, 150, 17)];
        self.videoNameLabel.backgroundColor = [UIColor clearColor];
        self.videoNameLabel.font = [UIFont systemFontOfSize:15.0];
        
        self.videoDescLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, 25, 150, 13)];
        self.videoDescLabel.backgroundColor = [UIColor clearColor];
        self.videoDescLabel.font = [UIFont systemFontOfSize:13.0];
        self.videoDescLabel.textColor = [UIColor grayColor];
        
        self.videoDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 5, 200, 13)];
        self.videoDateLabel.textAlignment = NSTextAlignmentRight;
        self.videoDateLabel.backgroundColor = [UIColor clearColor];
        self.videoDateLabel.font = [UIFont systemFontOfSize:13.0];
        
        self.secMarkImgView = [[UIImageView alloc] initWithFrame:CGRectMake(290, 17, 20, 20)];
        self.secMarkImgView.image = [UIImage imageNamed:@"videoLock"];
        
        [self.contentView addSubview:self.typeMrkImgView];
        [self.contentView addSubview:self.videoNameLabel];
        [self.contentView addSubview:self.videoDescLabel];
        [self.contentView addSubview:self.videoDateLabel];
        [self.contentView addSubview:self.secMarkImgView];
        
#if inDebugTest
        self.typeMrkImgView.backgroundColor = [UIColor blueColor];
        self.videoNameLabel.backgroundColor = [UIColor greenColor];
        self.videoDescLabel.backgroundColor = [UIColor yellowColor];
        self.videoDateLabel.backgroundColor = [UIColor redColor];
        self.secMarkImgView.backgroundColor = [UIColor grayColor];
#endif
    }
    
    return self;
}

- (void)setIsLiveVideo:(BOOL)isLiveVideo {
    _isLiveVideo = isLiveVideo;
    
    if (_isLiveVideo == YES) {
        self.typeMrkImgView.image = [UIImage imageNamed:@"live"];
    }else {
        self.typeMrkImgView.image = [UIImage imageNamed:@"movie"];
    }
}

- (void)setIsSec:(BOOL)isSec {
    _isSec = isSec;
    
    if (_isSec == YES) {
        self.secMarkImgView.hidden = NO;
    }else {
        self.secMarkImgView.hidden = YES;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.videoDateLabel.ott_right = self.ott_width - 10;
    self.secMarkImgView.ott_right = self.ott_width - 10;
}

@end
