//
//  RDRRecordPlayRequstModel.h
//  linphone
//
//  Created by heqin on 16/5/7.
//
//

#import "RDRBaseRequestModel.h"

@interface RDRRecordPlayRequstModel : RDRBaseRequestModel

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, assign) NSInteger day;        // 天数， 7天，或者30天
@property (nonatomic, assign) NSInteger page;       // 翻页码

@end
