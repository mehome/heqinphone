//
//  RDROperationMuteVideoRequestModel.h
//  linphone
//
//  Created by baidu on 15/12/20.
//
//

#import "RDRBaseRequestModel.h"

@interface RDROperationMuteVideoRequestModel : RDRBaseRequestModel

@property (nonatomic, copy) NSString *pin;
@property (nonatomic, copy) NSString *uid;      // 静画对象
@property (nonatomic, copy) NSString *addr;     // 与会地址
@property (nonatomic, strong) NSNumber *mute;     // 是否静画

@end
