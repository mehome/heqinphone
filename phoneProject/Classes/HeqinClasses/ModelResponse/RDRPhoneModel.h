//
//  RDRPhoneModel.h
//  linphone
//
//  Created by baidu on 16/1/7.
//
//

#import "MTLModel.h"
#import "MTLJSONAdapter.h"

@interface RDRPhoneModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *desc;

@property (nonatomic, assign) NSInteger type;   // 0联系人，1设备

@property (nonatomic, copy) NSString *pro;      // 协议:sip、H323

@end
