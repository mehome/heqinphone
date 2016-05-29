//
//  Resource_Date.h
//  GetArts
//
//  Created by mac on 14-11-13.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *
 *  @param compareDate 比较日期
 *  @return 时间
 */
inline static NSString * compareCurrentTime(NSDate* compareDate)
//
{
    NSTimeInterval  timeInterval = [compareDate timeIntervalSinceNow];
    timeInterval = -timeInterval;
    long temp = 0;
    NSString *result;
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    if (timeInterval < 60) {
        result = [NSString stringWithFormat:@"刚刚"];
    }
    else if((temp = timeInterval/60) <60){
        result = [NSString stringWithFormat:@"%ld分钟前",temp];
    }
    
    else if((temp = temp/60) <24){
        result = [NSString stringWithFormat:@"%ld小时前",temp];
    }
    
    else if((temp = temp/24) <30){
        // result = [NSString stringWithFormat:@"%ld天前",temp];
        [formatter setDateFormat:@"MM"];
        NSString* monthString = [formatter stringFromDate:compareDate];
        int month = [monthString intValue];
        if (month < 10) {
            [formatter setDateFormat:@"M月dd日"];
        }
        else
        {
            [formatter setDateFormat:@"MM月dd日"];
        }
        result = [formatter stringFromDate:compareDate];
    }
    
    else if((temp = temp/30) <12){
        [formatter setDateFormat:@"MM"];
        NSString* monthString = [formatter stringFromDate:compareDate];
        int month = [monthString intValue];
        if (month < 10) {
            [formatter setDateFormat:@"M月dd日"];
        }
        else
        {
            [formatter setDateFormat:@"MM月dd日"];
        }
        //result = [NSString stringWithFormat:@"%ld月前",temp];
        [formatter setDateFormat:@"MM月dd日"];
        result = [formatter stringFromDate:compareDate];
    }
    else{
        temp = temp/12;
        //result = [NSString stringWithFormat:@"%ld年前",temp];
        [formatter setDateFormat:@"yyyy年MM月dd日"];
        result = [formatter stringFromDate:compareDate];
    }
    
    return  result;
}


inline static NSString *getPersonCenterTimeStringFromTimestamp(NSString *timestamp)
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timestamp floatValue]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"MM月dd"];
    NSString *resultString = [formatter stringFromDate:date];
    return resultString;
}
inline static NSString* getStandaredTimeStringFromTimestamp(NSString *timeStamp)
{
    float times = [timeStamp floatValue];
    
    NSString *returnString = @"";
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:times];
    
    returnString = compareCurrentTime(date);
    return returnString;
}
inline static NSString *getStandaredTimeOfYearMonthDayFromtimeStamp(NSString *timestamp)
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timestamp floatValue]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy年MM月dd日"];
    NSString *resultString = [formatter stringFromDate:date];
    return resultString;
}

//获取当前时间时间戳
inline static NSString *getNowTimeLine()
{
    NSDate* now = [NSDate date];
    NSTimeInterval ttt=[now timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%f", ttt];
    return timeString;
}