//
//  RDROperationMuteRequestModel.h
//  linphone
//
//  Created by baidu on 15/12/20.
//
//

#import "RDRBaseRequestModel.h"

@interface RDROperationMuteRequestModel : RDRBaseRequestModel

@property (nonatomic, copy) NSString *pin;
@property (nonatomic, copy) NSString *uid;      // 静音对象，为空则静音访客们
@property (nonatomic, copy) NSString *addr;     // 与会地址
@property (nonatomic, strong) NSNumber *mute;     // 是否静音

@end
