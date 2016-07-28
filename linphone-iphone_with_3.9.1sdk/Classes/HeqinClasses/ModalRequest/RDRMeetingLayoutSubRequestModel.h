//
//  RDRMeetingLayoutSubRequestModel.h
//  linphone
//
//  Created by baidu on 16/6/8.
//
//

#import "RDRBaseRequestModel.h"

// 就是会议模式，不带访客布局
@interface RDRMeetingLayoutSubRequestModel : RDRBaseRequestModel

@property (nonatomic, copy) NSString *addr;
@property (nonatomic, copy) NSString *pin;
@property (nonatomic, assign) NSInteger subtitle;
@property (nonatomic, assign) NSInteger layout;

@end
