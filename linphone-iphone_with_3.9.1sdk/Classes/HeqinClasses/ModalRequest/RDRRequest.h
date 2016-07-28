//
//  RDRRequestModel.h
//  RedDrive
//
//  Created by YDJ on 15/8/23.
//  Copyright (c) 2015年 Wunelli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mantle.h"

@interface RDRRequest : NSObject

@property (nonatomic,copy)NSString *urlPath;

@property (nonatomic,strong)id<MTLJSONSerializing>  requestModel;

// 添加公共参数，默认不添加.
@property (nonatomic,assign)BOOL isAddCommonParameters;

+ (instancetype)request;

+ (instancetype)requestWithURLPath:(NSString *)urlPath model:(id<MTLJSONSerializing>)model;

@end
