//
//  RDRRecordVideoModel.h
//  linphone
//
//  Created by heqin on 16/5/7.
//
//

#import "MTLModel.h"
#import "MTLJSONAdapter.h"

@interface RDRRecordVideoModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *desc;

@property (nonatomic, copy) NSString *date;

@property (nonatomic, assign) NSInteger live;       // 0点播，1直播
@property (nonatomic, assign) NSInteger sec;   // 是否加密，0没有，1加密

@property (nonatomic, copy) NSString *url;      // 没有加密码的视频地址

@end
