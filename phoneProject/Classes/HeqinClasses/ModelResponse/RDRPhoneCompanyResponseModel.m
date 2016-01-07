//
//  RDRPhoneCompanyResponseModel.m
//  linphone
//
//  Created by baidu on 16/1/7.
//
//

#import "RDRPhoneCompanyResponseModel.h"
#import "RDRPhoneModel.h"

@implementation RDRPhoneCompanyResponseModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    
    NSMutableDictionary *mutDic = [[NSDictionary mtl_identityPropertyMapWithModel:[self class]] mutableCopy];
    
    return mutDic;
}

+ (NSValueTransformer *)contactsJSONTransformer{
    return [MTLJSONAdapter arrayTransformerWithModelClass:[RDRPhoneModel class]];
}

@end
