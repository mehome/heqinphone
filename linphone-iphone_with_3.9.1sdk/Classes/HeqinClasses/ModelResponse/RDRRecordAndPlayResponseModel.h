//
//  RDRRecordAndPlayResponseModel.h
//  linphone
//
//  Created by heqin on 16/5/7.
//
//

#import "RDRBaseResponseModel.h"

@interface RDRRecordAndPlayResponseModel : RDRBaseResponseModel

@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger total;
@property (nonatomic, strong) NSArray *videos;        // 视频列表

@end
