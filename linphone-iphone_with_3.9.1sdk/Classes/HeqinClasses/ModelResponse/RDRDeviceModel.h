//
//  RDRDeviceModel.h
//  linphone
//
//  Created by baidu on 15/12/4.
//
//

#import "MTLModel.h"
#import "MTLJSONAdapter.h"

@interface RDRDeviceModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *uid;          // 用户帐号
@property (nonatomic, copy) NSString *name;         // 显示名称
@property (nonatomic, copy) NSString *desc;         // 描述

@end
