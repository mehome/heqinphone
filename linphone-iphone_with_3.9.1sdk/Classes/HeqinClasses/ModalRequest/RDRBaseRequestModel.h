//
//  RDRBaseRequestModel.h
//  RedDrive
//
//  Created by heqin on 15/8/19.
//  Copyright (c) 2015年 Wunelli. All rights reserved.
//

#import "Mantle.h"

@interface RDRBaseRequestModel : MTLModel <MTLJSONSerializing>

+ (instancetype)requestModel;

//子类可从写该方法，返回相应的urlPath
- (NSString *)requestModelURLPath;

@end
