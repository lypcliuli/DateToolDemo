//
//  DatePicker.h
//  DatePicker
//
//  Created by LYPC on 03/12/17.
//  Copyright © 2017 LYPC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSDate+DatePicker.h"
#import "NSDateFormatter+UTCTimeZone.h"

//屏幕的size，宽，高
#define SCREEN ([[UIScreen mainScreen] bounds].size)
#define SCREEN_H SCREEN.height
#define SCREEN_W SCREEN.width

typedef void (^selectedResult)(NSDate *selectDate, NSString *dateStyle);

typedef NS_ENUM(NSInteger,DatePickerMode) {
    DatePickerModeTime,    // Displays hour, minute, and optionally AM/PM designation depending on the locale setting (e.g. 6 | 53 | PM)
    DatePickerModeDate,     // Displays month, day, and year depending on the locale setting (e.g. November | 15 | 2007)
    DatePickerModeDateAndTime, // Displays date, hour, minute, and optionally AM/PM designation depending on the locale setting (e.g. Wed Nov 15 | 6 | 53 | PM)
    DatePickerModeYearAndMonth // Displays Year, Month,  designation depending on the locale setting (e.g. November | 2007)
};

@class DatePicker;

@protocol DatePickerDelegate<NSObject>
@optional
- (void)datePicker:(DatePicker *)datePicker dateDidChange:(NSDate *)date;
- (void)datePicker:(DatePicker *)datePicker didCancel:(UIButton *)sender;

/**
 获取选择的时间

 @param dataPicker 时间选择器对象
 @param date 所选的时间
 @param dateStyle ""/"开始时间"/"结束时间"
 */
- (void)datePicker:(DatePicker *)dataPicker didSelectedDate:(NSDate *)date dateStyle:(NSString *)dateStyle;
@end

@interface DatePicker : UIControl
/**
 *  Title on the top of DatePicker
 */
@property (nonatomic, copy) NSString *title;

/**
 展示开始时间／结束时间（不设置 默认不展示）
 */
@property (nonatomic, copy) NSString *dateStyle;

@property (nonatomic, strong) NSDate *date;
/**
 *  specify min/max date range. default is nil. When min > max, the values are ignored.
 */
@property (nonatomic, strong) NSDate *minimumDate;

@property (nonatomic, strong) NSDate *maximumDate;
@property (nonatomic, strong) NSDate *currentDate;
/**
 * default is DatePickerModeDate. setting nil returns to default
 */
@property (nonatomic, assign) DatePickerMode datePickerMode;
/**
 *  default is [NSLocale currentLocale]. setting nil returns to default
 */
@property(nonatomic,strong) NSLocale      *locale;
/**
 *  default is [NSCalendar currentCalendar]. setting nil returns to default
 */
@property(nonatomic,copy)   NSCalendar    *calendar;
/**
 *   default is nil. use current time zone or time zone from calendar
 */
@property(nonatomic,strong) NSTimeZone    *timeZone;
/**
 *  read only property, indicate in datepicker is open.
 */
@property(nonatomic,readonly) BOOL        isOpen;

+ (instancetype)shareInstans;


/**
  设置默认显示的时间为当前时间

 @param date 时间
 @param animated 动画效果
 */
- (void)setDate:(NSDate *)date animated:(BOOL)animated;

- (void)setTintColor:(UIColor *)tintColor;

- (void)setHighlightColor:(UIColor *)highlightColor;


/**
 展示选择器

 @param datePickerMode 展示模式
 @param minimumDate 开始时间
 @param maximumDate 结束时间
 @param currentDate 当前展示的时间
 @param handle 代理对象
 */
- (void)showDatePickerMode:(DatePickerMode)datePickerMode minDate:(NSDate *)minimumDate maxMamDate:(NSDate *)maximumDate currentDate:(NSDate *)currentDate handle:(id)handle;


- (void)showDatePickerMode:(DatePickerMode)datePickerMode minDate:(NSDate *)minimumDate maxMamDate:(NSDate *)maximumDate currentDate:(NSDate *)currentDate result:(selectedResult)selectedResult;

- (void)dismiss;
@end
