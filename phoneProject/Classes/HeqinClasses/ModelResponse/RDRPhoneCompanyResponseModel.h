//
//  RDRPhoneCompanyResponseModel.h
//  linphone
//
//  Created by baidu on 16/1/7.
//
//

#import "RDRBaseResponseModel.h"

@interface RDRPhoneCompanyResponseModel : RDRBaseResponseModel

@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger total;
@property (nonatomic, strong) NSArray *contacts;        // 联系人列表

@end
