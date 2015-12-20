//
//  RDRMyMeetingArrangeModel.m
//  linphone
//
//  Created by baidu on 15/12/6.
//
//

#import "RDRMyMeetingArrangeModel.h"
#import "RDRParticipant.h"

@implementation RDRMyMeetingArrangeModel

- (NSString *)requestModelURLPath{
    return @"api/arrange";
}

+ (NSValueTransformer *)participantsJSONTransformer{
    return [MTLJSONAdapter arrayTransformerWithModelClass:[RDRParticipant class]];
}

@end
