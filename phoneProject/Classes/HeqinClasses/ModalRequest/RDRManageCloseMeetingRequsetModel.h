//
//  RDRManageCloseMeetingRequsetModel.h
//  linphone
//
//  Created by baidu on 15/12/16.
//
//

#import "RDRBaseRequestModel.h"

@interface RDRManageCloseMeetingRequsetModel : RDRBaseRequestModel

@property (nonatomic, copy) NSString *close;          // 关闭会议状态， 1＝关闭，0=打开
@property (nonatomic, copy) NSString *addr;      // 会议室地址
@property (nonatomic, copy) NSString *uid;       // 用户帐号
@property (nonatomic, copy) NSString *pwd;      // 用户密码

@end
