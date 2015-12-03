//
//  RDRArrangeRoomModel.h
//  linphone
//
//  Created by baidu on 15/12/4.
//
//

#import "MTLModel.h"
#import "MTLJSONAdapter.h"

@interface RDRArrangeRoomModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSNumber *idNum;          // 会议id
@property (nonatomic, copy) NSString *name;             // 会议显示名称
@property (nonatomic, copy) NSString *addr;             // 与会地址
@property (nonatomic, strong) NSNumber *closed;         // 是否已关闭
@property (nonatomic, copy) NSString *desc;             // 描述

@end
