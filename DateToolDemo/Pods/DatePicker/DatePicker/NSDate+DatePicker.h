//
//  NSDate+DatePicker.h
//  DatePickerDeomo
//
//  Created by LYPC on 03/12/17.
//  Copyright © 2017 LYPC. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kDateFormatYYYYMMDD;
extern NSString *const kDateFormatYYMMDDTHHmmss;


@interface NSDate (DatePicker)

+ (NSDateFormatter *)shareDateFormatter;

- (NSInteger)daysBetween:(NSDate *)aDate;

- (NSDate *)dateByAddingDays:(NSInteger)days;

- (NSString *)stringForFormat:(NSString *)format;

@end

@interface NSCalendar (AT)

+ (instancetype)sharedCalendar;

@end
