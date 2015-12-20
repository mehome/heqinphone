//
//  RDROperationGetJoinersResponseModel.h
//  linphone
//
//  Created by baidu on 15/12/20.
//
//

#import "RDRBaseResponseModel.h"

@interface RDROperationGetJoinersResponseModel : RDRBaseResponseModel

@property (nonatomic, strong) NSArray *data;        // 参与人员

@end
