//
//  NSDateFormatter+UTCTimeZone.m
//  DateToolDemo
//
//  Created by LYPC on 2017/12/4.
//  Copyright © 2017年 LYPC. All rights reserved.
//

#import "NSDateFormatter+UTCTimeZone.h"

@implementation NSDateFormatter (UTCTimeZone)

+ (NSDateFormatter *)creatDateFormatter {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    return dateFormatter;
}

@end
