//
//  RDRAskSecRequestModel.h
//  linphone
//
//  Created by heqin on 16/5/7.
//
//

#import "RDRBaseRequestModel.h"

@interface RDRAskSecRequestModel : RDRBaseRequestModel

@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *pwd;        // 视频密码

@end
