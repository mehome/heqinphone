//
//  RDRMyMeetingArrangeContactsResponseModel.h
//  linphone
//
//  Created by baidu on 15/12/4.
//
//

#import "RDRBaseResponseModel.h"

@interface RDRMyMeetingArrangeContactsResponseModel : RDRBaseResponseModel

@property (nonatomic, strong) NSArray *contacts;        // 我的通讯录
@property (nonatomic, strong) NSArray *devices;         // 我的终端列表

@end
