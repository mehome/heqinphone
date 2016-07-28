//
//  RDRTerminalRequestModel.h
//  linphone
//
//  Created by baidu on 15/12/19.
//
//

#import "RDRBaseRequestModel.h"

@interface RDRTerminalRequestModel : RDRBaseRequestModel

@property (nonatomic, copy) NSString *addr;
@property (nonatomic, copy) NSString *pin;

@end
