//
//  RDRBaseResponseModel.h
//  RedDrive
//
//  Created by heqin on 15/8/19.
//  Copyright (c) 2015年 Wunelli. All rights reserved.
//

#import "MTLModel.h"
#import "MTLJSONAdapter.h"
#import "NSDictionary+MTLMappingAdditions.h"

@interface RDRBaseResponseModel : MTLModel <MTLJSONSerializing>

@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) NSString *msg;

// 返回码检查
- (BOOL)codeCheckSuccess;

@end
