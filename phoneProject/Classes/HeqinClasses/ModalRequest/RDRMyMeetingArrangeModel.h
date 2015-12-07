//
//  RDRMyMeetingArrangeModel.h
//  linphone
//
//  Created by baidu on 15/12/6.
//
//

#import "RDRBaseRequestModel.h"
#import "RDRContactModel.h"

@interface RDRMyMeetingArrangeModel : RDRBaseRequestModel

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *pwd;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *repeat;       // 是否重复， 重复为1,不同复为0
@property (nonatomic, copy) NSString *addr;         // 与会地址
@property (nonatomic, strong) NSArray *participants;    // 与会者名单

@end
