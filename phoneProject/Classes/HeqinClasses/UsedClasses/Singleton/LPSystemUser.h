//
//  LPUser.h
//  linphone
//
//  Created by heqin on 15/11/7.
//
//

#import <Foundation/Foundation.h>

@interface LPSystemUser : NSObject

@property (nonatomic, assign) BOOL hasLogin;
@property (nonatomic, copy) NSString *aliasName;                // 用户自己给自己添加的名字
@property (nonatomic, copy) NSString *loginUserName;            // 登录使用的名字
@property (nonatomic, copy) NSString *loginUserId;              // 登录时使用的用户id
@property (nonatomic, copy) NSString *loginUserPassword;        // 登录使用的密码

+ (instancetype)sharedUser;

@end
