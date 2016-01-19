//
//  RDROperationJoinerModel.h
//  linphone
//
//  Created by baidu on 15/12/20.
//
//

#import "MTLModel.h"
#import "MTLJSONAdapter.h"

@interface RDROperationJoinerModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSNumber *audio;      // 是否有声音
@property (nonatomic, strong) NSNumber *video;      // 是否有画面
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, strong) NSNumber *role;       // 是否为host, 1:host, 0:guest

@end
