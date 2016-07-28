//
//  RDRMyMeetingArrangeContactsResponseModel.m
//  linphone
//
//  Created by baidu on 15/12/4.
//
//

#import "RDRMyMeetingArrangeContactsResponseModel.h"
#import "RDRContactModel.h"
#import "RDRDeviceModel.h"

@implementation RDRMyMeetingArrangeContactsResponseModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    
    NSMutableDictionary *mutDic = [[NSDictionary mtl_identityPropertyMapWithModel:[self class]] mutableCopy];
    
    return mutDic;
}

+ (NSValueTransformer *)contactsJSONTransformer{
    return [MTLJSONAdapter arrayTransformerWithModelClass:[RDRContactModel class]];
}

+ (NSValueTransformer *)devicesJSONTransformer{
    return [MTLJSONAdapter arrayTransformerWithModelClass:[RDRDeviceModel class]];
}

@end
