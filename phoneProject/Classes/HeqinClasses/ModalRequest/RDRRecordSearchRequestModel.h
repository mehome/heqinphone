//
//  RDRRecordSearchRequestModel.h
//  linphone
//
//  Created by heqin on 16/5/7.
//
//

#import "RDRBaseRequestModel.h"

@interface RDRRecordSearchRequestModel : RDRBaseRequestModel

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *key;        // 关键字

@end
