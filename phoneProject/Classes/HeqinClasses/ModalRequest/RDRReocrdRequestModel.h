//
//  RDRReocrdRequestModel.h
//  linphone
//
//  Created by heqin on 16/5/7.
//
//

#import "RDRBaseRequestModel.h"

@interface RDRReocrdRequestModel : RDRBaseRequestModel

@property (nonatomic, copy) NSString *addr;
@property (nonatomic, copy) NSString *action;
@property (nonatomic, copy) NSString *pin;

@end
