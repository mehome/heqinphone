//
//  LPMeetingRoom.m
//  linphone
//
//  Created by heqin on 15/11/7.
//
//

#import "LPMeetingRoom.h"

@implementation LPMeetingRoom

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.meetingIdStr forKey:@"meetingId"];
    [aCoder encodeObject:self.meetingName forKey:@"meetingName"];
    [aCoder encodeObject:self.meetingInLastDateStr forKey:@"meetingLastDate"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.meetingIdStr = [aDecoder decodeObjectForKey:@"meetingId"];
        self.meetingName = [aDecoder decodeObjectForKey:@"meetingName"];
        self.meetingInLastDateStr = [aDecoder decodeObjectForKey:@"meetingLastDate"];
    }
    return self;
}

@end
