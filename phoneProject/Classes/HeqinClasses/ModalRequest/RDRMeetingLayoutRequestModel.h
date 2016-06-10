//
//  RDRMeetingLayoutRequestModel.h
//  linphone
//
//  Created by baidu on 16/6/8.
//
//

#import "RDRBaseRequestModel.h"

@interface RDRMeetingLayoutRequestModel : RDRBaseRequestModel

@property (nonatomic, copy) NSString *addr;
@property (nonatomic, copy) NSString *pin;
@property (nonatomic, assign) NSInteger subtitle;
@property (nonatomic, assign) NSInteger layout;
@property (nonatomic, assign) NSInteger layout2;

@end
