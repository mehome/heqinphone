//
//  RDRMyMeetingResponseModel.h
//  linphone
//
//  Created by baidu on 15/11/12.
//
//

#import "RDRBaseResponseModel.h"

@interface RDRMyMeetingResponseModel : RDRBaseResponseModel

@property (nonatomic, strong) NSArray *schedule;        // 我的会议安排
@property (nonatomic, strong) NSArray *rooms;           // 我的会议室
@property (nonatomic, strong) NSArray *fav;             // 我的收藏

@end
