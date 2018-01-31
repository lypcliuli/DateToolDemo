//
//  DatePicker.m
//  DatePickerDeomo
//
//  Created by LYPC on 03/12/17.
//  Copyright © 2017 LYPC. All rights reserved.
//

#import "DatePicker.h"

// Constants :
static NSString  * const kSureButtonItemTitle = @"完成";
static NSString  * const kCancelButtonItemTitle = @"取消";

// Constants sizes :

static CGFloat const kDatePickerHeaderHeight = 44.0f;

static CGFloat const kDatePickerButtonHeaderWidth = 90.0f;

static CGFloat const kDatePickerHeaderBottomMargin = 0.0f;

static CGFloat const kDatePickerScrollViewDaysWidth = 90.0f;

static CGFloat const kDatePickerScrollViewMonthWidth = 140.0f;

static CGFloat const kDatePickerScrollViewDateWidth = 165.0f;

static CGFloat const kDatePickerScrollViewLeftMargin = 1.0f;

static CGFloat const kDatePickerScrollViewItemHeight = 45.0f;

static CGFloat const kDatePickerLineWidth = 1.0f;

static CGFloat const kDatePickerLineMargin = 15.0f;

static CGFloat const kDatePickerPadding = 30.0f;

// Constants times :
static CGFloat const kDatePickerAnimationDuration = 0.15f;

static CGFloat const kDatePickerHeight = 3*kDatePickerScrollViewItemHeight+2*kDatePickerHeaderHeight+15;

// Constants fonts
#define kDatePickerTitleFont [UIFont systemFontOfSize:18.0]
#define kDatePickerLabelFont [UIFont systemFontOfSize:18.0]
#define kDatePickerLabelSelectedFont [UIFont systemFontOfSize:20.0];

//十六进制颜色
#define UIColorFromRGB(rgbValue)    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


typedef NS_ENUM(NSInteger,ScrollViewTagValue) {
    ScrollViewTagValue_DAYS = 1,
    ScrollViewTagValue_MONTHS = 2,
    ScrollViewTagValue_YEARS = 3,
    ScrollViewTagValue_HOURS = 4,
    ScrollViewTagValue_MINUTES = 5,
    ScrollViewTagValue_SECONDS = 6,
    ScrollViewTagValue_DATES = 7,
    
};

@interface DatePicker ()<UIScrollViewDelegate> {
    // Lines :
    UIView *_lineDaysTop, *_lineDaysBottom, *_lineMonthsTop, *_lineMonthsBottom, *_lineYearsTop,*_lineYearsBottom, *_lineDatesTop, *_lineDatesBottom, *_lineHoursTop, *_lineHoursBottom, *_lineMinutesTop, *_lineMinutesBottom, *_lineSecondsTop, *_lineSecondsBottom;
    
    // Labels :
    NSMutableArray *_labelsDays, *_labelsMonths, *_labelsYears, *_labelsDates, *_labelsHours, *_labelsMinutes, *_labelsSeconds;
    
    // Date and time selected :
    NSInteger _selectedDay,  _selectedMonth, _selectedYear,  _selectedDate, _selectedHour, _selectedMinute,  _selectedSecond;
    
    NSInteger _minYear;
    
}

@property (nonatomic,copy) selectedResult selectedResult;
@property (nonatomic, weak) id<DatePickerDelegate> delegate;

// Data of years, months, days, dates, hours, minutes, seconds
@property (nonatomic, strong) NSMutableArray *years, *months, *days, *dates, *hours, *minutes, *seconds;

// ScrollView for Years, Months, days ,Dates ,Hours ,Minute ,Seconds
@property (nonatomic, strong) UIScrollView *scrollViewYears, *scrollViewMonths, *scrollViewDays, *scrollViewDates, *scrollViewHours, *scrollViewMinutes,*scrollViewSeconds;

@property (nonatomic, copy) UIView *dimBackgroundView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic,strong) UILabel *dateStyleLabel;

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *footerView;

@property (nonatomic, strong) UILabel *headerLine;
@property (nonatomic,strong) UILabel *footerLine;

@property (nonatomic, strong) UIColor *tintColor;

@property (nonatomic, strong) UIColor *highlightColor;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic,strong) UIPickerView *yearPickerView;
@property (nonatomic,strong) UIPickerView *monthPickerView;

@property (nonatomic,strong) UIButton *sureButton;
@end

@implementation DatePicker


#pragma mark - Initializers

+ (instancetype)shareInstans {
    static DatePicker *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 默认 留在底部展示 show时底部弹出
        instance = [[DatePicker alloc] initWithFrame:CGRectMake(0, SCREEN_H, SCREEN_W, kDatePickerHeight)];
    });
    return instance;
}

- (void)showDatePickerMode:(DatePickerMode)datePickerMode minDate:(NSDate *)minimumDate maxMamDate:(NSDate *)maximumDate currentDate:(NSDate *)currentDate result:(selectedResult)selectedResult {
    self.backgroundColor = [UIColor whiteColor];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    _datePickerMode = datePickerMode;
    self.dimBackgroundView.alpha = 0.45;
    [window addSubview:self.dimBackgroundView];
    [window addSubview:self];
    _minYear = 1900;
    if (maximumDate) {
        _maximumDate = maximumDate;
    }
    if (minimumDate) {
        _minimumDate = minimumDate;
        
        NSDateComponents* componentsMin = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:_minimumDate];
        NSInteger yearMin = [componentsMin year];
        _minYear = yearMin;
    }
    if (currentDate) {
        _currentDate = currentDate;
    }
    [self addSubview:self.headerView];
    [self addSubview:self.footerView];
    [self setupControl];
    // 展示
    [self show];
    self.selectedResult = selectedResult;
}

- (void)showDatePickerMode:(DatePickerMode)datePickerMode minDate:(NSDate *)minimumDate maxMamDate:(NSDate *)maximumDate currentDate:(NSDate *)currentDate handle:(id)handle {
    self.backgroundColor = [UIColor whiteColor];
    self.delegate = handle;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    _datePickerMode = datePickerMode;
    self.dimBackgroundView.alpha = 0.45;
    [window addSubview:self.dimBackgroundView];
    [window addSubview:self];
    _minYear = 1900;
    if (maximumDate) {
        _maximumDate = maximumDate;
    }
    if (minimumDate) {
        _minimumDate = minimumDate;
        
        NSDateComponents* componentsMin = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:_minimumDate];
        NSInteger yearMin = [componentsMin year];
        _minYear = yearMin;
    }
    if (currentDate) {
        _currentDate = currentDate;
    }
    [self addSubview:self.headerView];
    [self addSubview:self.footerView];
    [self setupControl];
    // 展示
    [self show];
}

- (void)setupControl {
    
    // Set parent View :
    self.hidden = YES;
    
    // Clear old selectors
    [self removeSelectorYears];
    [self removeSelectorMonths];
    [self removeSelectorDays];
    [self removeSelectorHours];
    [self removeSelectorMinutes];
    [self removeSelectorSeconds];
    
    // Generate collections days, months, years, hours, minutes and seconds :
    _years = [self getYears];
    _days = [self getDaysInMonth:[NSDate date]];
    if (self.datePickerMode == DatePickerModeDateAndTime) {
        _dates = [self getDates];
    }
    
    // Date Selectors :
    if (self.datePickerMode == DatePickerModeDate) {
        [self buildSelectorYearsOffsetX:0.0 andWidth:kDatePickerScrollViewMonthWidth];
        [self buildSelectorMonthsOffsetX:(_scrollViewYears.frame.size.width + kDatePickerScrollViewLeftMargin) andWidth:kDatePickerScrollViewDaysWidth];
        [self buildSelectorDaysOffsetX:(_scrollViewMonths.frame.origin.x + _scrollViewMonths.frame.size.width + kDatePickerScrollViewLeftMargin) andWidth:(self.frame.size.width - (_scrollViewMonths.frame.origin.x + _scrollViewMonths.frame.size.width + kDatePickerScrollViewLeftMargin))];
    }
    
    // Time Selectors :
    if (self.datePickerMode == DatePickerModeTime) {
        [self buildSelectorHoursOffsetX:0.0 andWidth:((self.frame.size.width / 3.0) - kDatePickerScrollViewLeftMargin)];
        [self buildSelectorMinutesOffsetX:(self.frame.size.width / 3.0) andWidth:((self.frame.size.width / 3.0) - kDatePickerScrollViewLeftMargin)];
        [self buildSelectorSecondsOffsetX:((self.frame.size.width / 3.0) * 2.0) andWidth:(self.frame.size.width / 3.0)];
    }
    
    // Date & Time Selectors :
    if (self.datePickerMode == DatePickerModeDateAndTime) {
        [self buildSelectorDatesOffsetX:0.0 andWidth:kDatePickerScrollViewDateWidth];
        [self buildSelectorHoursOffsetX:(kDatePickerScrollViewDateWidth + kDatePickerScrollViewLeftMargin) andWidth:(((self.frame.size.width - kDatePickerScrollViewDateWidth) / 2.0) - kDatePickerScrollViewLeftMargin)];
        [self buildSelectorMinutesOffsetX:(kDatePickerScrollViewDateWidth + kDatePickerScrollViewLeftMargin + ((self.frame.size.width - kDatePickerScrollViewDateWidth) / 2.0)) andWidth:(((self.frame.size.width - kDatePickerScrollViewDateWidth) / 2.0) - kDatePickerScrollViewLeftMargin)];
    }
    
    if (self.datePickerMode == DatePickerModeYearAndMonth) {
        [self buildSelectorYearsOffsetX:0.0 andWidth:self.frame.size.width * 0.5];
        [self buildSelectorMonthsOffsetX:(_scrollViewYears.frame.size.width + kDatePickerScrollViewLeftMargin) andWidth:self.frame.size.width * 0.5];
    }
    
    // Defaut Date selected :
    [self setDate:[NSDate date] animated:NO];
}


#pragma mark - Build Selector Days

- (void)buildSelectorDaysOffsetX:(CGFloat)x andWidth:(CGFloat)width {
    
    // ScrollView Days :
    _scrollViewDays = [[UIScrollView alloc] initWithFrame:CGRectMake(x, kDatePickerHeaderHeight + kDatePickerHeaderBottomMargin, width, self.frame.size.height - kDatePickerHeaderHeight - kDatePickerHeaderBottomMargin)];
    _scrollViewDays.tag = ScrollViewTagValue_DAYS;
    _scrollViewDays.delegate = self;
    _scrollViewDays.showsHorizontalScrollIndicator = NO;
    _scrollViewDays.showsVerticalScrollIndicator = NO;
    [self addSubview:_scrollViewDays];
    
    _lineDaysTop = [[UIView alloc] initWithFrame:CGRectMake(_scrollViewDays.frame.origin.x + kDatePickerLineMargin, _scrollViewDays.frame.origin.y + (_scrollViewDays.frame.size.height / 2) - (kDatePickerScrollViewItemHeight / 2), width - (2 * kDatePickerLineMargin), kDatePickerLineWidth)];
    _lineDaysTop.backgroundColor = self.highlightColor;
    [self addSubview:_lineDaysTop];
    
    _lineDaysBottom = [[UIView alloc] initWithFrame:CGRectMake(_scrollViewDays.frame.origin.x + kDatePickerLineMargin, _scrollViewDays.frame.origin.y + (_scrollViewDays.frame.size.height / 2) + (kDatePickerScrollViewItemHeight / 2), width - (2 * kDatePickerLineMargin), kDatePickerLineWidth)];
    _lineDaysBottom.backgroundColor = self.highlightColor;
    [self addSubview:_lineDaysBottom];
    
    // Update ScrollView Data
    [self buildSelectorLabelsDays];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureDaysCaptured:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [_scrollViewDays addGestureRecognizer:singleTap];
}

- (void)buildSelectorLabelsDays {
    
    CGFloat offsetContentScrollView = (_scrollViewYears.frame.size.height - kDatePickerScrollViewItemHeight) / 2.0;
    
    if (_labelsDays && _labelsDays.count > 0) {
        for (UILabel *label in _labelsDays) {
            [label removeFromSuperview];
        }
    }
    
    _labelsDays = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < _days.count; i++) {
        
        NSString *day = (NSString*)[_days objectAtIndex:i];
        
        UILabel *labelDay = [[UILabel alloc] initWithFrame:CGRectMake(0, (i * kDatePickerScrollViewItemHeight) + offsetContentScrollView, _scrollViewDays.frame.size.width, kDatePickerScrollViewItemHeight)];
        labelDay.text = day;
        labelDay.font = kDatePickerLabelFont;
        labelDay.textAlignment = NSTextAlignmentCenter;
        labelDay.textColor = UIColorFromRGB(0x2d2d2d);
        [_labelsDays addObject:labelDay];
        [_scrollViewDays addSubview:labelDay];
    }
    
    _scrollViewDays.contentSize = CGSizeMake(_scrollViewDays.frame.size.width, (kDatePickerScrollViewItemHeight * _days.count) + (offsetContentScrollView * 2));
}

- (void)removeSelectorDays {
    
    if (_scrollViewDays) {
        [_scrollViewDays removeFromSuperview];
        _scrollViewDays = nil;
    }
    if (_lineDaysTop) {
        [_lineDaysTop removeFromSuperview];
        _lineDaysTop = nil;
    }
    if (_lineDaysBottom) {
        [_lineDaysBottom removeFromSuperview];
        _lineDaysBottom = nil;
    }
}

#pragma mark - Build Selector Months

- (void)buildSelectorMonthsOffsetX:(CGFloat)x andWidth:(CGFloat)width {
    
    // ScrollView Months
    
    _scrollViewMonths = [[UIScrollView alloc] initWithFrame:CGRectMake(x, kDatePickerHeaderHeight + kDatePickerHeaderBottomMargin, width, 3*kDatePickerScrollViewItemHeight)];
    _scrollViewMonths.tag = ScrollViewTagValue_MONTHS;
    _scrollViewMonths.delegate = self;
    _scrollViewMonths.showsHorizontalScrollIndicator = NO;
    _scrollViewMonths.showsVerticalScrollIndicator = NO;
    [self addSubview:_scrollViewMonths];
    
    _lineMonthsTop = [[UIView alloc] initWithFrame:CGRectMake(_scrollViewMonths.frame.origin.x +25, _scrollViewMonths.frame.origin.y + (_scrollViewMonths.frame.size.height / 2) - (kDatePickerScrollViewItemHeight / 2), 35, kDatePickerLineWidth)];
    _lineMonthsTop.backgroundColor = UIColorFromRGB(0x4b87e5);
    [self addSubview:_lineMonthsTop];
    
    _lineMonthsBottom = [[UIView alloc] initWithFrame:CGRectMake(_scrollViewMonths.frame.origin.x +25, _scrollViewMonths.frame.origin.y + (_scrollViewMonths.frame.size.height / 2) + (kDatePickerScrollViewItemHeight / 2), 35, kDatePickerLineWidth)];
    _lineMonthsBottom.backgroundColor = UIColorFromRGB(0x4b87e5);
    [self addSubview:_lineMonthsBottom];
    
    
    // Update ScrollView Data
    [self buildSelectorLabelsMonths];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureMonthsCaptured:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [_scrollViewMonths addGestureRecognizer:singleTap];
}

- (void)buildSelectorLabelsMonths {
    
    CGFloat offsetContentScrollView = (_scrollViewYears.frame.size.height - kDatePickerScrollViewItemHeight) / 2.0;
    
    if (_labelsMonths && _labelsMonths.count > 0) {
        for (UILabel *label in _labelsMonths) {
            [label removeFromSuperview];
        }
    }
    
    _labelsMonths = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.months.count; i++) {
        
        NSString *day = (NSString*)[self.months objectAtIndex:i];
        
        UILabel *labelDay = [[UILabel alloc] initWithFrame:CGRectMake(30, (i * kDatePickerScrollViewItemHeight) + offsetContentScrollView, _scrollViewMonths.frame.size.width-30, kDatePickerScrollViewItemHeight)];
        labelDay.text = day;
        labelDay.font = kDatePickerLabelFont;
        labelDay.textAlignment = NSTextAlignmentLeft;
        labelDay.textColor = self.tintColor;
        labelDay.backgroundColor = [UIColor clearColor];
        [_labelsMonths addObject:labelDay];
        [_scrollViewMonths addSubview:labelDay];
    }
    
    _scrollViewMonths.contentSize = CGSizeMake(_scrollViewMonths.frame.size.width, (kDatePickerScrollViewItemHeight * self.months.count) + (offsetContentScrollView * 2));
}

- (void)removeSelectorMonths {
    
    if (_scrollViewMonths) {
        [_scrollViewMonths removeFromSuperview];
        _scrollViewMonths = nil;
    }
    if (_lineMonthsTop) {
        [_lineMonthsTop removeFromSuperview];
        _lineMonthsTop = nil;
    }
    if (_lineMonthsBottom) {
        [_lineMonthsBottom removeFromSuperview];
        _lineMonthsBottom = nil;
    }
}

#pragma mark - Build Selector Years

- (void)buildSelectorYearsOffsetX:(CGFloat)x andWidth:(CGFloat)width {
    
    // ScrollView Years
    
    _scrollViewYears = [[UIScrollView alloc] initWithFrame:CGRectMake(x,  kDatePickerHeaderHeight+kDatePickerHeaderBottomMargin, width, 3*kDatePickerScrollViewItemHeight)];
    _scrollViewYears.tag = ScrollViewTagValue_YEARS;
    _scrollViewYears.delegate = self;
    _scrollViewYears.showsHorizontalScrollIndicator = NO;
    _scrollViewYears.showsVerticalScrollIndicator = NO;
    [self addSubview:_scrollViewYears];
    _lineYearsTop = [[UIView alloc] initWithFrame:CGRectMake(width-55-25, _scrollViewYears.frame.origin.y + (_scrollViewYears.frame.size.height / 2) - (kDatePickerScrollViewItemHeight / 2),  55, kDatePickerLineWidth)];
    _lineYearsTop.backgroundColor = UIColorFromRGB(0x4b87e5);
    [self addSubview:_lineYearsTop];
    
    _lineYearsBottom = [[UIView alloc] initWithFrame:CGRectMake(width-55-25, _scrollViewYears.frame.origin.y + (_scrollViewYears.frame.size.height / 2) + (kDatePickerScrollViewItemHeight / 2), 55, kDatePickerLineWidth)];
    _lineYearsBottom.backgroundColor = UIColorFromRGB(0x4b87e5);
    [self addSubview:_lineYearsBottom];
    
    // Update ScrollView Data
    [self buildSelectorLabelsYears];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureYearsCaptured:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [_scrollViewYears addGestureRecognizer:singleTap];
}

- (void)buildSelectorLabelsYears {
    
    CGFloat offsetContentScrollView = (_scrollViewYears.frame.size.height - kDatePickerScrollViewItemHeight) / 2.0;
    
    if (_labelsYears && _labelsYears.count > 0) {
        for (UILabel *label in _labelsYears) {
            [label removeFromSuperview];
        }
    }
    
    _labelsYears = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < _years.count; i++) {
        
        NSString *day = (NSString*)[_years objectAtIndex:i];
        
        UILabel *labelDay = [[UILabel alloc] initWithFrame:CGRectMake(0.0, (i * kDatePickerScrollViewItemHeight) + offsetContentScrollView, _scrollViewYears.frame.size.width-30, kDatePickerScrollViewItemHeight)];
        labelDay.text = day;
        labelDay.font = kDatePickerLabelFont;
        labelDay.textAlignment = NSTextAlignmentRight;
        labelDay.textColor = self.tintColor;
        labelDay.backgroundColor = [UIColor clearColor];
        
        [_labelsYears addObject:labelDay];
        [_scrollViewYears addSubview:labelDay];
    }
    
    _scrollViewYears.contentSize = CGSizeMake(_scrollViewYears.frame.size.width, (kDatePickerScrollViewItemHeight * _years.count) + (offsetContentScrollView * 2));
}

- (void)removeSelectorYears {
    
    if (_scrollViewYears) {
        [_scrollViewYears removeFromSuperview];
        _scrollViewYears = nil;
    }
    if (_lineYearsTop) {
        [_lineYearsTop removeFromSuperview];
        _lineYearsTop = nil;
    }
    if (_lineYearsBottom) {
        [_lineYearsBottom removeFromSuperview];
        _lineYearsBottom = nil;
    }
}

#pragma mark - Build Selector Dates

- (void)buildSelectorDatesOffsetX:(CGFloat)x andWidth:(CGFloat)width {
    
    // ScrollView Dates
    _scrollViewDates = [[UIScrollView alloc] initWithFrame:CGRectMake(x, kDatePickerHeaderHeight + kDatePickerHeaderBottomMargin, width, self.frame.size.height - kDatePickerHeaderHeight - kDatePickerHeaderBottomMargin)];
    _scrollViewDates.tag = ScrollViewTagValue_DATES;
    _scrollViewDates.delegate = self;
    _scrollViewDates.showsHorizontalScrollIndicator = NO;
    _scrollViewDates.showsVerticalScrollIndicator = NO;
    [self addSubview:_scrollViewDates];
    
    _lineDatesTop = [[UIView alloc] initWithFrame:CGRectMake(_scrollViewDates.frame.origin.x + kDatePickerLineMargin, _scrollViewDates.frame.origin.y + (_scrollViewDates.frame.size.height / 2) - (kDatePickerScrollViewItemHeight / 2), width - (2 * kDatePickerLineMargin), kDatePickerLineWidth)];
    _lineDatesTop.backgroundColor = self.highlightColor;
    [self addSubview:_lineDatesTop];
    
    _lineDatesBottom = [[UIView alloc] initWithFrame:CGRectMake(_scrollViewDates.frame.origin.x + kDatePickerLineMargin, _scrollViewDates.frame.origin.y + (_scrollViewDates.frame.size.height / 2) + (kDatePickerScrollViewItemHeight / 2), width - (2 * kDatePickerLineMargin), kDatePickerLineWidth)];
    _lineDatesBottom.backgroundColor = self.highlightColor;
    [self addSubview:_lineDatesBottom];
    
    // Update ScrollView Data
    [self buildSelectorLabelsDates];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureDatesCaptured:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [_scrollViewDates addGestureRecognizer:singleTap];
}

- (void)buildSelectorLabelsDates {
    
    CGFloat offsetContentScrollView = (_scrollViewDates.frame.size.height - kDatePickerScrollViewItemHeight) / 2.0;
    
    if (_labelsDates && _labelsDates.count > 0) {
        for (UILabel *label in _labelsDates) {
            [label removeFromSuperview];
        }
    }
    
    _labelsDates = [[NSMutableArray alloc] init];
    
    NSDateFormatter *dateFormatter = self.dateFormatter;
    [dateFormatter setCalendar:self.calendar];
    [dateFormatter setTimeZone:self.timeZone];
    [dateFormatter setDateFormat:[NSString stringWithFormat:@"MMMdd%@ EEE", @"日"]];
    
    for (int i = 0; i < _dates.count; i++) {
        
        NSDate *date = [_dates objectAtIndex:i];
        
        NSString *hour = [dateFormatter stringFromDate:date];
        
        UILabel *labelDate = [[UILabel alloc] initWithFrame:CGRectMake(0, (i * kDatePickerScrollViewItemHeight) + offsetContentScrollView, _scrollViewDates.frame.size.width, kDatePickerScrollViewItemHeight)];
        labelDate.text = hour;
        labelDate.font = kDatePickerLabelFont;
        labelDate.textAlignment = NSTextAlignmentCenter;
        labelDate.textColor = self.tintColor;
        labelDate.backgroundColor = [UIColor clearColor];
        
        [_labelsDates addObject:labelDate];
        [_scrollViewDates addSubview:labelDate];
    }
    
    _scrollViewDates.contentSize = CGSizeMake(_scrollViewDates.frame.size.width, (kDatePickerScrollViewItemHeight * _dates.count) + (offsetContentScrollView * 2));
}

- (void)removeSelectorDates {
    
    if (_scrollViewDates) {
        [_scrollViewDates removeFromSuperview];
        _scrollViewDates = nil;
    }
    if (_lineDatesTop) {
        [_lineDatesTop removeFromSuperview];
        _lineDatesTop = nil;
    }
    if (_lineDatesBottom) {
        [_lineDatesBottom removeFromSuperview];
        _lineDatesBottom = nil;
    }
}

#pragma mark - Build Selector Hours

- (void)buildSelectorHoursOffsetX:(CGFloat)x andWidth:(CGFloat)width {
    
    // ScrollView Hours :
    _scrollViewHours = [[UIScrollView alloc] initWithFrame:CGRectMake(x, kDatePickerHeaderHeight + kDatePickerHeaderBottomMargin, width, self.frame.size.height - kDatePickerHeaderHeight - kDatePickerHeaderBottomMargin)];
    _scrollViewHours.tag = ScrollViewTagValue_HOURS;
    _scrollViewHours.delegate = self;
    _scrollViewHours.showsHorizontalScrollIndicator = NO;
    _scrollViewHours.showsVerticalScrollIndicator = NO;
    [self addSubview:_scrollViewHours];
    
    _lineHoursTop = [[UIView alloc] initWithFrame:CGRectMake(_scrollViewHours.frame.origin.x + kDatePickerLineMargin, _scrollViewHours.frame.origin.y + (_scrollViewHours.frame.size.height / 2) - (kDatePickerScrollViewItemHeight / 2), width - (2 * kDatePickerLineMargin), kDatePickerLineWidth)];
    _lineHoursTop.backgroundColor = self.highlightColor;
    [self addSubview:_lineHoursTop];
    
    _lineHoursBottom = [[UIView alloc] initWithFrame:CGRectMake(_scrollViewHours.frame.origin.x + kDatePickerLineMargin, _scrollViewHours.frame.origin.y + (_scrollViewHours.frame.size.height / 2) + (kDatePickerScrollViewItemHeight / 2), width - (2 * kDatePickerLineMargin), kDatePickerLineWidth)];
    _lineHoursBottom.backgroundColor = self.highlightColor;
    [self addSubview:_lineHoursBottom];
    
    // Update ScrollView Data
    [self buildSelectorLabelsHours];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureHoursCaptured:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [_scrollViewHours addGestureRecognizer:singleTap];
}

- (void)buildSelectorLabelsHours {
    
    CGFloat offsetContentScrollView = (_scrollViewHours.frame.size.height - kDatePickerScrollViewItemHeight) / 2.0;
    
    if (_labelsHours && _labelsHours.count > 0) {
        for (UILabel *label in _labelsHours) {
            [label removeFromSuperview];
        }
    }
    
    _labelsHours = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.hours.count; i++) {
        
        NSString *hour = (NSString*)[self.hours objectAtIndex:i];
        
        UILabel *labelHour = [[UILabel alloc] initWithFrame:CGRectMake(0, (i * kDatePickerScrollViewItemHeight) + offsetContentScrollView, _scrollViewHours.frame.size.width, kDatePickerScrollViewItemHeight)];
        labelHour.text = hour;
        labelHour.font = kDatePickerLabelFont;
        labelHour.textAlignment = NSTextAlignmentCenter;
        labelHour.textColor = self.tintColor;
        labelHour.backgroundColor = [UIColor clearColor];
        
        [_labelsHours addObject:labelHour];
        [_scrollViewHours addSubview:labelHour];
    }
    
    _scrollViewHours.contentSize = CGSizeMake(_scrollViewHours.frame.size.width, (kDatePickerScrollViewItemHeight * self.hours.count) + (offsetContentScrollView * 2));
}

- (void)removeSelectorHours {
    
    if (_scrollViewHours) {
        [_scrollViewHours removeFromSuperview];
        _scrollViewHours = nil;
    }
    if (_lineHoursTop) {
        [_lineHoursTop removeFromSuperview];
        _lineHoursTop = nil;
    }
    if (_lineHoursBottom) {
        [_lineHoursBottom removeFromSuperview];
        _lineHoursBottom = nil;
    }
}

#pragma mark - Build Selector Minutes

- (void)buildSelectorMinutesOffsetX:(CGFloat)x andWidth:(CGFloat)width {
    
    // ScrollView Minutes :
    _scrollViewMinutes = [[UIScrollView alloc] initWithFrame:CGRectMake(x, kDatePickerHeaderHeight + kDatePickerHeaderBottomMargin, width, self.frame.size.height - kDatePickerHeaderHeight - kDatePickerHeaderBottomMargin)];
    _scrollViewMinutes.tag = ScrollViewTagValue_MINUTES;
    _scrollViewMinutes.delegate = self;
    _scrollViewMinutes.showsHorizontalScrollIndicator = NO;
    _scrollViewMinutes.showsVerticalScrollIndicator = NO;
    [self addSubview:_scrollViewMinutes];
    
    _lineMinutesTop = [[UIView alloc] initWithFrame:CGRectMake(_scrollViewMinutes.frame.origin.x + kDatePickerLineMargin, _scrollViewMinutes.frame.origin.y + (_scrollViewMinutes.frame.size.height / 2) - (kDatePickerScrollViewItemHeight / 2), width - (2 * kDatePickerLineMargin), kDatePickerLineWidth)];
    _lineMinutesTop.backgroundColor = self.highlightColor;
    [self addSubview:_lineMinutesTop];
    
    _lineMinutesBottom = [[UIView alloc] initWithFrame:CGRectMake(_scrollViewMinutes.frame.origin.x + kDatePickerLineMargin, _scrollViewMinutes.frame.origin.y + (_scrollViewMinutes.frame.size.height / 2) + (kDatePickerScrollViewItemHeight / 2), width - (2 * kDatePickerLineMargin), kDatePickerLineWidth)];
    _lineMinutesBottom.backgroundColor = self.highlightColor;
    [self addSubview:_lineMinutesBottom];
    
    // Update ScrollView Data
    [self buildSelectorLabelsMinutes];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureMinutesCaptured:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [_scrollViewMinutes addGestureRecognizer:singleTap];
}

- (void)buildSelectorLabelsMinutes {
    
    CGFloat offsetContentScrollView = (_scrollViewMinutes.frame.size.height - kDatePickerScrollViewItemHeight) / 2.0;
    
    if (_labelsMinutes && _labelsMinutes.count > 0) {
        for (UILabel *label in _labelsMinutes) {
            [label removeFromSuperview];
        }
    }
    
    _labelsMinutes = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.minutes.count; i++) {
        
        NSString *minute = (NSString*)[self.minutes objectAtIndex:i];
        
        UILabel *labelMinute = [[UILabel alloc] initWithFrame:CGRectMake(0, (i * kDatePickerScrollViewItemHeight) + offsetContentScrollView, _scrollViewMinutes.frame.size.width, kDatePickerScrollViewItemHeight)];
        labelMinute.text = minute;
        labelMinute.font = kDatePickerLabelFont;
        labelMinute.textAlignment = NSTextAlignmentCenter;
        labelMinute.textColor = self.tintColor;
        labelMinute.backgroundColor = [UIColor clearColor];
        
        [_labelsMinutes addObject:labelMinute];
        [_scrollViewMinutes addSubview:labelMinute];
    }
    
    _scrollViewMinutes.contentSize = CGSizeMake(_scrollViewMinutes.frame.size.width, (kDatePickerScrollViewItemHeight * self.minutes.count) + (offsetContentScrollView * 2));
}

- (void)removeSelectorMinutes {
    
    if (_scrollViewMinutes) {
        [_scrollViewMinutes removeFromSuperview];
        _scrollViewMinutes = nil;
    }
    if (_lineMinutesTop) {
        [_lineMinutesTop removeFromSuperview];
        _lineMinutesTop = nil;
    }
    if (_lineMinutesBottom) {
        [_lineMinutesBottom removeFromSuperview];
        _lineMinutesBottom = nil;
    }
}

#pragma mark - Build Selector Seconds

- (void)buildSelectorSecondsOffsetX:(CGFloat)x andWidth:(CGFloat)width {
    
    // ScrollView Seconds :
    _scrollViewSeconds = [[UIScrollView alloc] initWithFrame:CGRectMake(x, kDatePickerHeaderHeight + kDatePickerHeaderBottomMargin, width, self.frame.size.height - kDatePickerHeaderHeight - kDatePickerHeaderBottomMargin)];
    _scrollViewSeconds.tag = ScrollViewTagValue_SECONDS;
    _scrollViewSeconds.delegate = self;
    _scrollViewSeconds.showsHorizontalScrollIndicator = NO;
    _scrollViewSeconds.showsVerticalScrollIndicator = NO;
    [self addSubview:_scrollViewSeconds];
    
    _lineSecondsTop = [[UIView alloc] initWithFrame:CGRectMake(_scrollViewSeconds.frame.origin.x + kDatePickerLineMargin, _scrollViewSeconds.frame.origin.y + (_scrollViewSeconds.frame.size.height / 2) - (kDatePickerScrollViewItemHeight / 2), width - (2 * kDatePickerLineMargin), kDatePickerLineWidth)];
    _lineSecondsTop.backgroundColor = self.highlightColor;
    [self addSubview:_lineSecondsTop];
    
    _lineSecondsBottom = [[UIView alloc] initWithFrame:CGRectMake(_scrollViewSeconds.frame.origin.x + kDatePickerLineMargin, _scrollViewSeconds.frame.origin.y + (_scrollViewSeconds.frame.size.height / 2) + (kDatePickerScrollViewItemHeight / 2), width - (2 * kDatePickerLineMargin), kDatePickerLineWidth)];
    _lineSecondsBottom.backgroundColor = self.highlightColor;
    [self addSubview:_lineSecondsBottom];
    
    // Update ScrollView Data
    [self buildSelectorLabelsSeconds];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureSecondsCaptured:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [_scrollViewSeconds addGestureRecognizer:singleTap];
}

- (void)buildSelectorLabelsSeconds {
    
    CGFloat offsetContentScrollView = (_scrollViewSeconds.frame.size.height - kDatePickerScrollViewItemHeight) / 2.0;
    
    if (_labelsSeconds && _labelsSeconds.count > 0) {
        for (UILabel *label in _labelsSeconds) {
            [label removeFromSuperview];
        }
    }
    
    _labelsSeconds = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.seconds.count; i++) {
        
        NSString *second = (NSString*)[self.seconds objectAtIndex:i];
        
        UILabel *labelSecond = [[UILabel alloc] initWithFrame:CGRectMake(0, (i * kDatePickerScrollViewItemHeight) + offsetContentScrollView, _scrollViewSeconds.frame.size.width, kDatePickerScrollViewItemHeight)];
        labelSecond.text = second;
        labelSecond.font = kDatePickerLabelFont;
        labelSecond.textAlignment = NSTextAlignmentCenter;
        labelSecond.textColor = self.tintColor;
        labelSecond.backgroundColor = [UIColor clearColor];
        
        [_labelsSeconds addObject:labelSecond];
        [_scrollViewSeconds addSubview:labelSecond];
    }
    
    _scrollViewSeconds.contentSize = CGSizeMake(_scrollViewSeconds.frame.size.width, (kDatePickerScrollViewItemHeight * self.seconds.count) + (offsetContentScrollView * 2));
}

- (void)removeSelectorSeconds {
    
    if (_scrollViewSeconds) {
        [_scrollViewSeconds removeFromSuperview];
        _scrollViewSeconds = nil;
    }
    if (_lineSecondsTop) {
        [_lineSecondsTop removeFromSuperview];
        _lineSecondsTop = nil;
    }
    if (_lineSecondsBottom) {
        [_lineSecondsBottom removeFromSuperview];
        _lineSecondsBottom = nil;
    }
}

#pragma mark - Actions

- (void)actionButtonCancel:(UIButton *)sender {
    
    [self dismiss];
    
    if ([self.delegate respondsToSelector:@selector(datePicker:didCancel:)]) {
        [self.delegate datePicker:self didCancel:sender];
    }
}

- (void)actionButtonValid:(UIButton *)sender {
    NSDate *currentDate = [self getDate];
    if (currentDate == nil) {
        return;
    }
    // 当前时间必须在开始和结束时间之间
    if ([currentDate compare:self.minimumDate] == NSOrderedAscending) {
        return;
    }else if ([currentDate compare:self.maximumDate] == NSOrderedDescending) {
        return;
    }else {
        [self dismiss];
        if ([self.delegate respondsToSelector:@selector(datePicker:didSelectedDate:dateStyle:)]) {
            [self.delegate datePicker:self didSelectedDate:[self getDate] dateStyle:self.dateStyle];
        }
        if (self.selectedResult) {
            self.selectedResult([self getDate], self.dateStyle);
        }
    }
}

#pragma mark - Show and Dismiss

-(void)show {
    if (self.hidden == YES) {
        self.hidden = NO;
    }
    if (self.datePickerMode == DatePickerModeDate || self.datePickerMode == DatePickerModeDateAndTime) {
        
        int indexDays = [self getIndexForScrollViewPosition:_scrollViewDays];
        [self highlightLabelInArray:_labelsDays atIndex:indexDays];
        
        int indexMonths = [self getIndexForScrollViewPosition:_scrollViewMonths];
        [self highlightLabelInArray:_labelsMonths atIndex:indexMonths];
        
        int indexYears = [self getIndexForScrollViewPosition:_scrollViewYears];
        [self highlightLabelInArray:_labelsYears atIndex:indexYears];
    }
    
    if (self.datePickerMode == DatePickerModeTime || self.datePickerMode == DatePickerModeDateAndTime) {
        
        int indexHours = [self getIndexForScrollViewPosition:_scrollViewHours];
        [self highlightLabelInArray:_labelsHours atIndex:indexHours];
        
        int indexMinutes = [self getIndexForScrollViewPosition:_scrollViewMinutes];
        [self highlightLabelInArray:_labelsMinutes atIndex:indexMinutes];
        
        int indexSeconds = [self getIndexForScrollViewPosition:_scrollViewSeconds];
        [self highlightLabelInArray:_labelsSeconds atIndex:indexSeconds];
    }
    
    if (self.datePickerMode == DatePickerModeYearAndMonth) {
        int indexYears = [self getIndexForScrollViewPosition:_scrollViewYears];
        [self highlightLabelInArray:_labelsYears atIndex:indexYears];
        
        int indexMonths = [self getIndexForScrollViewPosition:_scrollViewMonths];
        [self highlightLabelInArray:_labelsMonths atIndex:indexMonths];
        
        // 优先展示当前设置的时间 _currentDate
        if (_currentDate) {
            // 设置的当前时间必须在开始和结束时间之间
            if ([_currentDate compare:self.minimumDate] == NSOrderedAscending) {
                [self setDate:self.minimumDate animated:YES];
            }else if ([_currentDate compare:self.maximumDate] == NSOrderedDescending) {
                [self setDate:self.maximumDate animated:YES];
            }else {
                [self setDate:self.currentDate animated:YES];
            }
        }else {
            NSDateComponents *componentsMine = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self.maximumDate];
            NSInteger endM = [componentsMine month];
            if (_selectedYear == [componentsMine year]) {
                NSString *endMStr = [NSString stringWithFormat:@"%ld", (long)endM];
                if (endM < 10) {
                    endMStr = [NSString stringWithFormat:@"%d%ld", 0, (long)endM];
                }
                [self setScrollView:_scrollViewMonths atIndex:[self.months indexOfObject:endMStr] animated:YES];
            }
        }
    }
    
    [UIView animateWithDuration:kDatePickerAnimationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.frame = CGRectMake(0, SCREEN_H-kDatePickerHeight, SCREEN_W, kDatePickerHeight);
        _isOpen = YES;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)dismiss {
    
    [UIView animateWithDuration:kDatePickerAnimationDuration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.frame = CGRectMake(0, SCREEN_H, SCREEN_W, kDatePickerHeight);
        self.dimBackgroundView.alpha = 0.0;
        _isOpen = NO;
        [self.dimBackgroundView removeFromSuperview];
        self.dimBackgroundView = nil;
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - DatePicker Mode

- (void)setDatePickerMode:(DatePickerMode)mode {
    _datePickerMode = mode;
    [self setupControl];
}

#pragma mark - Collections

- (NSMutableArray*)getYears {
    
    NSMutableArray *years = [[NSMutableArray alloc] init];
    
    NSInteger yearMin = 0;
    
    if (self.minimumDate) {
        NSDateComponents* componentsMin = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self.minimumDate];
        yearMin = [componentsMin year];
    } else {
        yearMin = _minYear;
    }
    
    NSInteger yearMax = 0;
    NSDateComponents* componentsMax = nil;
    
    if (self.maximumDate) {
        componentsMax = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self.maximumDate];
        yearMax = [componentsMax year];
    } else {
        componentsMax = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
        yearMax = [componentsMax year];
    }
    
    for (NSInteger i = yearMin; i <= yearMax; i++) {
        
        [years addObject:[NSString stringWithFormat:@"%ld", (long)i]];
    }
    return years;
}

- (NSMutableArray*)getDates {
    NSMutableArray *dates = [[NSMutableArray alloc] init];
    
    if (self.minimumDate && self.maximumDate) {
        NSInteger days = [self.minimumDate daysBetween:self.maximumDate];
        for (NSInteger i = 0; i < days; i++) {
            NSDate *date = [self.minimumDate dateByAddingDays:i];
            if ([date daysBetween: self.maximumDate] >= 0) {
                [dates addObject:date];
            }
        }
    } else {
        
        NSDateComponents* currentComponents = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
        NSInteger currentYear = [currentComponents year];
        
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setCalendar:self.calendar];
        [dateComponents setTimeZone:self.timeZone];
        [dateComponents setDay:1];
        [dateComponents setMonth:1];
        [dateComponents setHour:0];
        [dateComponents setMinute:0];
        [dateComponents setSecond:0];
        [dateComponents setYear:currentYear];
        
        NSDateComponents *maxComponents = [[NSDateComponents alloc] init];
        [maxComponents setCalendar:self.calendar];
        [maxComponents setTimeZone:self.timeZone];
        [maxComponents setDay:1];
        [maxComponents setMonth:1];
        [maxComponents setHour:0];
        [maxComponents setMinute:0];
        [maxComponents setSecond:0];
        [maxComponents setYear:currentYear + 1];
        
        NSDate *yearMin = [dateComponents date];
        NSDate *yearMax = [maxComponents date];
        
        NSInteger timestampMin = [yearMin timeIntervalSince1970];
        NSInteger timestampMax = [yearMax timeIntervalSince1970];
        
        while (timestampMin < timestampMax) {
            
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestampMin];
            
            [dates addObject:date];
            
            timestampMin += 1 * 24 * 60 * 60;
        }
    }
    
    return dates;
}

- (NSMutableArray*)getDaysInMonth:(NSDate*)date {
    
    if (date == nil) date = [NSDate date];
    
    NSRange daysRange = [self.calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    
    NSMutableArray *days = [[NSMutableArray alloc] init];
    
    for (int i = 1; i <= daysRange.length; i++) {
        
        [days addObject:[NSString stringWithFormat:@"%d%@", i, @"日"]];
    }
    
    return days;
}

#pragma mark - UIScrollView Delegate

- (void)singleTapGestureDaysCaptured:(UITapGestureRecognizer *)gesture {
    
    CGPoint touchPoint = [gesture locationInView:self];
    CGFloat touchY = touchPoint.y;
    
    if (touchY < (_lineDaysTop.frame.origin.y)) {
        
        if (_selectedDay > 1) {
            _selectedDay -= 1;
            [self setScrollView:_scrollViewDays atIndex:(_selectedDay - 1) animated:YES];
        }
        
    } else if (touchY > (_lineDaysBottom.frame.origin.y)) {
        
        if (_selectedDay < _days.count) {
            _selectedDay += 1;
            [self setScrollView:_scrollViewDays atIndex:(_selectedDay - 1) animated:YES];
        }
    }
}

- (void)singleTapGestureMonthsCaptured:(UITapGestureRecognizer *)gesture {
    
    CGPoint touchPoint = [gesture locationInView:self];
    CGFloat touchY = touchPoint.y;
    
    if (touchY < (_lineMonthsTop.frame.origin.y)) {
        
        if (_selectedMonth > 1) {
            _selectedMonth -= 1;
            [self setScrollView:_scrollViewMonths atIndex:(_selectedMonth - 1) animated:YES];
        }
        
    } else if (touchY > (_lineMonthsBottom.frame.origin.y)) {
        
        if (_selectedMonth < self.months.count) {
            _selectedMonth += 1;
            [self setScrollView:_scrollViewMonths atIndex:(_selectedMonth - 1) animated:YES];
        }
    }
    NSDate *selectedDate = [self getDate];
    if (self.datePickerMode != DatePickerModeDateAndTime && self.datePickerMode != DatePickerModeTime) {
        if ([selectedDate compare:self.minimumDate] == NSOrderedAscending) {
            [self setDate:self.minimumDate animated:YES];
        }
        
        if ([selectedDate compare:self.maximumDate] == NSOrderedDescending) {
            [self setDate:self.maximumDate animated:YES];
        }
    }
}

- (void)singleTapGestureYearsCaptured:(UITapGestureRecognizer *)gesture {
    
    CGPoint touchPoint = [gesture locationInView:self];
    CGFloat touchY = touchPoint.y;
    
    NSInteger minYear = _minYear;
    
    if (touchY < (_lineYearsTop.frame.origin.y)) {
        
        if (_selectedYear > minYear) {
            _selectedYear -= 1;
            [self setScrollView:_scrollViewYears atIndex:(_selectedYear - minYear) animated:YES];
        }
        
    } else if (touchY > (_lineYearsBottom.frame.origin.y)) {
        
        if (_selectedYear < (_years.count + (minYear - 1))) {
            _selectedYear += 1;
            [self setScrollView:_scrollViewYears atIndex:(_selectedYear - minYear) animated:YES];
        }
    }
    [self setupHideLabels];
    NSDateComponents *componentsMine = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self.maximumDate];
    NSInteger endM = [componentsMine month];
    if (_selectedYear == [componentsMine year]) {
        if (_selectedMonth > endM) {
            NSString *endMStr = [NSString stringWithFormat:@"%ld", (long)endM];
            if (endM < 10) {
                endMStr = [NSString stringWithFormat:@"%d%ld", 0, (long)endM];
            }
            [self setScrollView:_scrollViewMonths atIndex:[self.months indexOfObject:endMStr] animated:YES];
        }
    }
    NSDateComponents *componentsMin = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self.minimumDate];
    NSInteger startM = [componentsMin month];
    NSInteger startY = [componentsMin year];
    if (_selectedYear == startY) {
        if (_selectedMonth < startM) {
            NSString *startMStr = [NSString stringWithFormat:@"%ld", (long)startM];
            if (startM < 10) {
                startMStr = [NSString stringWithFormat:@"%d%ld", 0, (long)startM];
            }
            [self setScrollView:_scrollViewMonths atIndex:[self.months indexOfObject:startMStr] animated:YES];
        }
    }
}

- (void)singleTapGestureDatesCaptured:(UITapGestureRecognizer *)gesture {
    
    CGPoint touchPoint = [gesture locationInView:self];
    CGFloat touchY = touchPoint.y;
    
    if (touchY < (_lineDatesTop.frame.origin.y)) {
        
        if (_selectedDate > 0) {
            _selectedDate -= 1;
            [self setScrollView:_scrollViewDates atIndex:_selectedDate animated:YES];
        }
        
    } else if (touchY > (_lineDatesBottom.frame.origin.y)) {
        
        if (_selectedDate < _dates.count - 1) {
            _selectedDate += 1;
            [self setScrollView:_scrollViewDates atIndex:_selectedDate animated:YES];
        }
    }
}

- (void)singleTapGestureHoursCaptured:(UITapGestureRecognizer *)gesture {
    
    CGPoint touchPoint = [gesture locationInView:self];
    CGFloat touchY = touchPoint.y;
    
    if (touchY < (_lineHoursTop.frame.origin.y)) {
        
        if (_selectedHour > 0) {
            _selectedHour -= 1;
            [self setScrollView:_scrollViewHours atIndex:_selectedHour animated:YES];
        }
        
    } else if (touchY > (_lineHoursBottom.frame.origin.y)) {
        
        if (_selectedHour < self.hours.count - 1) {
            _selectedHour += 1;
            [self setScrollView:_scrollViewHours atIndex:_selectedHour animated:YES];
        }
    }
}

- (void)singleTapGestureMinutesCaptured:(UITapGestureRecognizer *)gesture {
    
    CGPoint touchPoint = [gesture locationInView:self];
    CGFloat touchY = touchPoint.y;
    
    if (touchY < (_lineMinutesTop.frame.origin.y)) {
        
        if (_selectedMinute > 0) {
            _selectedMinute -= 1;
            [self setScrollView:_scrollViewMinutes atIndex:_selectedMinute animated:YES];
        }
        
    } else if (touchY > (_lineMinutesBottom.frame.origin.y)) {
        
        if (_selectedMinute < self.minutes.count - 1) {
            _selectedMinute += 1;
            [self setScrollView:_scrollViewMinutes atIndex:_selectedMinute animated:YES];
        }
    }
}

- (void)singleTapGestureSecondsCaptured:(UITapGestureRecognizer *)gesture {
    
    CGPoint touchPoint = [gesture locationInView:self];
    CGFloat touchY = touchPoint.y;
    
    if (touchY < (_lineSecondsTop.frame.origin.y)) {
        
        if (_selectedSecond > 0) {
            _selectedSecond -= 1;
            [self setScrollView:_scrollViewSeconds atIndex:_selectedSecond animated:YES];
        }
        
    } else if (touchY > (_lineSecondsBottom.frame.origin.y)) {
        
        if (_selectedSecond < self.seconds.count - 1) {
            _selectedSecond += 1;
            [self setScrollView:_scrollViewSeconds atIndex:_selectedSecond animated:YES];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int index = [self getIndexForScrollViewPosition:scrollView];
    [self updateSelectedDateAtIndex:index forScrollView:scrollView];
    [self setupHideLabels];
    if (scrollView.tag == ScrollViewTagValue_DAYS) {
        [self highlightLabelInArray:_labelsDays atIndex:index];
    } else if (scrollView.tag == ScrollViewTagValue_MONTHS) {
        [self highlightLabelInArray:_labelsMonths atIndex:index];
    } else if (scrollView.tag == ScrollViewTagValue_YEARS) {
        [self highlightLabelInArray:_labelsYears atIndex:index];
    } else if (scrollView.tag == ScrollViewTagValue_HOURS) {
        [self highlightLabelInArray:_labelsHours atIndex:index];
    } else if (scrollView.tag == ScrollViewTagValue_MINUTES) {
        [self highlightLabelInArray:_labelsMinutes atIndex:index];
    } else if (scrollView.tag == ScrollViewTagValue_SECONDS) {
        [self highlightLabelInArray:_labelsSeconds atIndex:index];
    } else if (scrollView.tag == ScrollViewTagValue_DATES) {
        [self highlightLabelInArray:_labelsDates atIndex:index];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    int index = [self getIndexForScrollViewPosition:scrollView];
    
    [self updateSelectedDateAtIndex:index forScrollView:scrollView];
    
    [self setScrollView:scrollView atIndex:index animated:YES];
    
    NSDate *selectedDate = [self getDate];
    if (self.datePickerMode != DatePickerModeDateAndTime && self.datePickerMode != DatePickerModeTime) {
        if ([selectedDate compare:self.minimumDate] == NSOrderedAscending) {
            [self setDate:self.minimumDate animated:YES];
        }
        
        if ([selectedDate compare:self.maximumDate] == NSOrderedDescending) {
            [self setDate:self.maximumDate animated:YES];
        }
    }
    if ([self.delegate respondsToSelector:@selector(datePicker:dateDidChange:)]) {
        [self.delegate datePicker:self dateDidChange:selectedDate];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int index = [self getIndexForScrollViewPosition:scrollView];
    
    [self updateSelectedDateAtIndex:index forScrollView:scrollView];
    
    [self setScrollView:scrollView atIndex:index animated:YES];
    
    NSDate *selectedDate = [self getDate];
    if (self.datePickerMode != DatePickerModeDateAndTime && self.datePickerMode != DatePickerModeTime) {
        if ([selectedDate compare:self.minimumDate] == NSOrderedAscending) {
            [self setDate:self.minimumDate animated:YES];
            return;
        }
        
        if ([selectedDate compare:self.maximumDate] == NSOrderedDescending) {
            [self setDate:self.maximumDate animated:YES];
            return;
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(datePicker:dateDidChange:)]) {
        [self.delegate datePicker:self dateDidChange:selectedDate];
    }
}

- (void)updateSelectedDateAtIndex:(int)index forScrollView:(UIScrollView*)scrollView {
    
    if (scrollView.tag == ScrollViewTagValue_DAYS) {
        _selectedDay = index + 1; // 1 to 31
    } else if (scrollView.tag == ScrollViewTagValue_MONTHS) {
        
        _selectedMonth = index + 1; // 1 to 12
        
        // Updates days :
        [self updateNumberOfDays];
        
    } else if (scrollView.tag == ScrollViewTagValue_YEARS) {
        
        _selectedYear = _minYear + index;
        
        // Updates days :
        [self updateNumberOfDays];
        
    } else if (scrollView.tag == ScrollViewTagValue_HOURS) {
        _selectedHour = index; // 0 to 23
    } else if (scrollView.tag == ScrollViewTagValue_MINUTES) {
        _selectedMinute = index; // 0 to 59
    } else if (scrollView.tag == ScrollViewTagValue_SECONDS) {
        _selectedSecond = index; // 0 to 59
    } else if (scrollView.tag == ScrollViewTagValue_DATES) {
        _selectedDate = index;
    }
}

- (void)updateNumberOfDays {
    
    // Updates days :
    NSDate *date = [self convertToDateDay:1 month:_selectedMonth year:_selectedYear hours:_selectedHour minutes:_selectedMinute seconds:_selectedSecond];
    
    if (!date) return;
    
    NSMutableArray *newDays = [self getDaysInMonth:date];
    
    if (newDays.count != _days.count) {
        
        _days = newDays;
        
        [self buildSelectorLabelsDays];
        
        if (_selectedDay > _days.count) {
            _selectedDay = _days.count;
        }
        
        [self highlightLabelInArray:_labelsDays atIndex:_selectedDay - 1];
    }
}

- (int)getIndexForScrollViewPosition:(UIScrollView *)scrollView {
    
    CGFloat offsetContentScrollView = (scrollView.frame.size.height - kDatePickerScrollViewItemHeight) / 2.0;
    CGFloat offetY = scrollView.contentOffset.y;
    CGFloat index = floorf((offetY + offsetContentScrollView) / kDatePickerScrollViewItemHeight);
    index = (index - 1);
    return index;
}

- (void)setScrollView:(UIScrollView*)scrollView atIndex:(NSInteger)index animated:(BOOL)animated {
    
    if (!scrollView) return;
    
    if (animated) {
        [UIView beginAnimations:@"ScrollViewAnimation" context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:kDatePickerAnimationDuration];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    }
    
    scrollView.contentOffset = CGPointMake(0.0, (index * kDatePickerScrollViewItemHeight));
    if (animated) {
        [UIView commitAnimations];
    }
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    dateFormat.dateFormat = @"yyyy年MM月";
    self.title = [dateFormat stringFromDate:[self getDate]];
    self.titleLabel.text = self.title;
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(datePicker:dateDidChange:)]) {
        [self.delegate datePicker:self dateDidChange:[self getDate]];
    }
}

- (void)highlightLabelInArray:(NSMutableArray*)labels atIndex:(NSInteger)index {
    if (!labels) return;
    if (index > labels.count) return;
    if (index < 0) return;
    
    for (int i = 0; i < labels.count; i++) {
        UILabel *label = (UILabel *)[labels objectAtIndex:i];
        if (i != index) {
            label.textColor = UIColorFromRGB(0xa4a4a4);
            label.font = kDatePickerLabelFont;
        } else {
            label.textColor = UIColorFromRGB(0x2d2d2d);
            label.font = kDatePickerLabelSelectedFont;
        }
    }
}

/**
 根据极限边界值控制开始之前和结束之后的时间label的展示或隐藏
 */
- (void)setupHideLabels {
    NSDateComponents *componentsMine = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self.maximumDate];
    NSInteger endM = [componentsMine month];
    NSInteger endY = [componentsMine year];
    
    NSDateComponents *componentsMin = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self.minimumDate];
    NSInteger startM = [componentsMin month];
    NSInteger startY = [componentsMin year];
    
    // 开始时间=结束时间（只有一个年份）
    if (endY == startY) {
        NSString *startMStr = [NSString stringWithFormat:@"%ld", (long)startM];
        if (startM < 10) {
            startMStr = [NSString stringWithFormat:@"%d%ld", 0, (long)startM];
        }
        for (int i=0; i<[self.months indexOfObject:startMStr]; i++) {
            UILabel *mLabelItem = _labelsMonths[i];
            mLabelItem.hidden = YES;
        }
        NSString *endMStr = [NSString stringWithFormat:@"%ld", (long)endM];
        if (endM < 10) {
            endMStr = [NSString stringWithFormat:@"%d%ld", 0, (long)endM];
        }
        for (NSInteger i=[self.months indexOfObject:endMStr]+1; i<self.months.count; i++) {
            UILabel *mLabelItem = _labelsMonths[i];
            mLabelItem.hidden = YES;
        }
    }else {
        // 把起始月份之前的隐藏
        if (_selectedYear == startY) {
            NSString *startMStr = [NSString stringWithFormat:@"%ld", (long)startM];
            if (startM < 10) {
                startMStr = [NSString stringWithFormat:@"%d%ld", 0, (long)startM];
            }
            if (_selectedMonth <= startM) {
                for (int i=0; i<[self.months indexOfObject:startMStr]+1; i++) {
                    UILabel *mLabelItem = _labelsMonths[i];
                    mLabelItem.hidden = YES;
                }
                for (NSInteger i=[self.months indexOfObject:startMStr]; i<self.months.count; i++) {
                    UILabel *mLabelItem = _labelsMonths[i];
                    mLabelItem.hidden = NO;
                }
            }else {
                // 当前选择的月份 > 开始月份， 把当前选择的月份之后截止到12月的展示出来
                for (NSInteger i=[self.months indexOfObject:startMStr]; i<self.months.count; i++) {
                    UILabel *mLabelItem = _labelsMonths[i];
                    mLabelItem.hidden = NO;
                }
            }
        }else if (_selectedYear == endY) {
            // 把结束月份之后的隐藏
            NSString *endMStr = [NSString stringWithFormat:@"%ld", (long)endM];
            if (endM < 10) {
                endMStr = [NSString stringWithFormat:@"%d%ld", 0, (long)endM];
            }
            for (NSInteger i=[self.months indexOfObject:endMStr]+1; i<self.months.count; i++) {
                UILabel *mLabelItem = _labelsMonths[i];
                mLabelItem.hidden = YES;
            }
            for (int i=0; i<=[self.months indexOfObject:endMStr]; i++) {
                UILabel *mLabelItem = _labelsMonths[i];
                mLabelItem.hidden = NO;
            }
        }else {
            for (int i=0; i<_labelsMonths.count; i++) {
                UILabel *mLabelItem = _labelsMonths[i];
                if (mLabelItem.hidden) {
                    mLabelItem.hidden = NO;
                }
            }
        }
    }
}

#pragma mark - Date

- (void)setDate:(NSDate *)date animated:(BOOL)animated {
    
    if (!date) return;
    NSDateComponents* components = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:date];
    
    _selectedDay = [components day];
    _selectedMonth = [components month];
    _selectedYear = [components year];
    _selectedHour = [components hour];
    [self setupHideLabels];
    /**
     *  only show mininute 00 10 20 ~ 50 in hotel tour edit order for flight pick up
     */
    if (self.datePickerMode != DatePickerModeDateAndTime) {
        _selectedMinute = [components minute];
    }
    _selectedSecond = [components second];
    
    if (self.datePickerMode == DatePickerModeDateAndTime) {
        if (self.minimumDate) {
            [self  setScrollView:_scrollViewDates atIndex:[date daysBetween:self.minimumDate] - 1 animated:animated];
        } else {
            [self setScrollView:_scrollViewDates atIndex:(_selectedDay - 1) animated:animated];
        }
        
    }
    
    if (self.datePickerMode == DatePickerModeDate) {
        [self setScrollView:_scrollViewYears atIndex:(_selectedYear - _minYear) animated:animated];
        [self setScrollView:_scrollViewMonths atIndex:(_selectedMonth - 1) animated:animated];
        [self setScrollView:_scrollViewDays atIndex:(_selectedDay - 1) animated:animated];
        
        
    }
    
    if (self.datePickerMode == DatePickerModeTime || self.datePickerMode == DatePickerModeDateAndTime) {
        [self setScrollView:_scrollViewHours atIndex:_selectedHour animated:animated];
        [self setScrollView:_scrollViewMinutes atIndex:_selectedMinute animated:animated];
        [self setScrollView:_scrollViewSeconds atIndex:_selectedSecond animated:animated];
    }
    
    if (self.datePickerMode == DatePickerModeYearAndMonth) {
        [self setScrollView:_scrollViewMonths atIndex:(_selectedMonth - 1) animated:animated];
        [self setScrollView:_scrollViewYears atIndex:(_selectedYear - _minYear) animated:animated];
    }
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(datePicker:dateDidChange:)]) {
        [self.delegate datePicker:self dateDidChange:[self getDate]];
    }
}

- (NSDate*)convertToDateDay:(NSInteger)day month:(NSInteger)month year:(NSInteger)year hours:(NSInteger)hours minutes:(NSInteger)minutes seconds:(NSInteger)seconds {
    
    NSMutableString *dateString = [[NSMutableString alloc] init];
    
    NSDateFormatter *dateFormatter = self.dateFormatter;
    if (self.timeZone) [dateFormatter setTimeZone:self.timeZone];
    [dateFormatter setLocale:self.locale];
    
    // Date Mode :
    if (self.datePickerMode == DatePickerModeDate) {
        
        if (day < 10) {
            [dateString appendFormat:@"0%ld-", (long)day];
        } else {
            [dateString appendFormat:@"%ld-", (long)day];
        }
        
        if (month < 10) {
            [dateString appendFormat:@"0%ld-", (long)month];
        } else {
            [dateString appendFormat:@"%ld-", (long)month];
        }
        
        [dateString appendFormat:@"%ld", (long)year];
        
        [dateFormatter setDateFormat:@"dd-MM-yyyy"];
    }
    
    // Time Mode :
    if (self.datePickerMode == DatePickerModeTime) {
        
        NSDateComponents* components = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
        
        NSInteger nowDay = [components day];
        NSInteger nowMonth = [components month];
        NSInteger nowYear = [components year];
        
        if (nowDay < 10) {
            [dateString appendFormat:@"0%ld-", (long)nowDay];
        } else {
            [dateString appendFormat:@"%ld-", (long)nowDay];
        }
        
        if (nowMonth < 10) {
            [dateString appendFormat:@"0%ld-", (long)nowMonth];
        } else {
            [dateString appendFormat:@"%ld-", (long)nowMonth];
        }
        
        [dateString appendFormat:@"%ld", (long)nowYear];
        
        if (hours < 10) {
            [dateString appendFormat:@" 0%ld:", (long)hours];
        } else {
            [dateString appendFormat:@" %ld:", (long)hours];
        }
        
        if (minutes < 10) {
            [dateString appendFormat:@"0%ld:", (long)minutes];
        } else {
            [dateString appendFormat:@"%ld:", (long)minutes];
        }
        
        if (seconds < 10) {
            [dateString appendFormat:@"0%ld", (long)seconds];
        } else {
            [dateString appendFormat:@"%ld", (long)seconds];
        }
        
        [dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    }
    
    // Date and Time Mode :
    if (self.datePickerMode == DatePickerModeDateAndTime) {
        
        if (day < 10) {
            [dateString appendFormat:@"0%ld-", (long)day];
        } else {
            [dateString appendFormat:@"%ld-", (long)day];
        }
        
        if (month < 10) {
            [dateString appendFormat:@"0%ld-", (long)month];
        } else {
            [dateString appendFormat:@"%ld-", (long)month];
        }
        
        [dateString appendFormat:@"%ld", (long)year];
        
        if (hours < 10) {
            [dateString appendFormat:@" 0%ld:", (long)hours];
        } else {
            [dateString appendFormat:@" %ld:", (long)hours];
        }
        
        if (minutes < 10) {
            [dateString appendFormat:@"0%ld:", (long)minutes];
        } else {
            [dateString appendFormat:@"%ld:", (long)minutes];
        }
        
        [dateString appendString:@"00"];
        
        [dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    }
    
    if (self.datePickerMode == DatePickerModeYearAndMonth) {
        
        if (month < 10) {
            [dateString appendFormat:@"0%ld-", (long)month];
        } else {
            [dateString appendFormat:@"%ld-", (long)month];
        }
        
        [dateString appendFormat:@"%ld", (long)year];
        
        [dateFormatter setDateFormat:@"MM-yyyy"];
    }
    
    return [dateFormatter dateFromString:dateString];
}

- (NSDate*)convertToDate:(NSInteger)days hours:(NSInteger)hours minutes:(NSInteger)minutes seconds:(NSInteger)seconds {
    
    NSDate *date = [self.minimumDate dateByAddingDays:days];
    
    NSMutableString *dateString = [[NSMutableString alloc] initWithString:[date stringForFormat:@"dd-MM-yyyy"]];
    
    NSDateFormatter *dateFormatter = self.dateFormatter;
    if (self.timeZone) [dateFormatter setTimeZone:self.timeZone];
    [dateFormatter setLocale:self.locale];
    
    
    if (hours < 10) {
        [dateString appendFormat:@" 0%ld:", (long)hours];
    } else {
        [dateString appendFormat:@" %ld:", (long)hours];
    }
    /**
     *  only show mininute 00 10 20 ~ 50 in hotel tour edit order for flight pick up
     */
    
    if (!minutes) {
        [dateString appendFormat:@"0%ld:", (long)minutes];
    } else {
        [dateString appendFormat:@"%ld:", (long)minutes * 10];
    }
    
    [dateString appendString:@"00"];
    
    [dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    return [dateFormatter dateFromString:dateString];
}

- (NSDate*)getDate {
    if (self.datePickerMode == DatePickerModeDateAndTime) {
        return [self convertToDate:_selectedDate hours:_selectedHour minutes:_selectedMinute seconds:_selectedSecond];
    }
    return [self convertToDateDay:_selectedDay month:_selectedMonth year:_selectedYear hours:_selectedHour minutes:_selectedMinute seconds:_selectedSecond];
}

#pragma mark - Getters and Setters

- (UIView *)dimBackgroundView {
    if(!_dimBackgroundView) {
        _dimBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_W, SCREEN_H)];
        [_dimBackgroundView setTranslatesAutoresizingMaskIntoConstraints:YES];
        _dimBackgroundView.backgroundColor = [UIColor blackColor];
        _dimBackgroundView.alpha = 0.45;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
        [_dimBackgroundView addGestureRecognizer:tap];
    }
    return _dimBackgroundView;
}

- (void)setDateStyle:(NSString *)dateStyle {
    if (_dateStyle != dateStyle) {
        _dateStyle = dateStyle;
        if (_dateStyleLabel != nil) {
            _dateStyleLabel.text = _dateStyle;
        }
    }
}

- (UIView *)headerView {
    if (!_headerView) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, kDatePickerHeaderHeight)];
        // Label Title
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0.0, (SCREEN_W-80)*0.5, kDatePickerHeaderHeight)];
        _titleLabel.text = self.title;
        _titleLabel.font = kDatePickerTitleFont;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.textColor = UIColorFromRGB(0x2d2d2d);
        [_headerView addSubview:_titleLabel];
        
        // dateStyle Title
        _dateStyleLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_W*0.5, 0.0, (SCREEN_W-80)*0.5, kDatePickerHeaderHeight)];
        _dateStyleLabel.text = self.dateStyle;
        _dateStyleLabel.font = kDatePickerTitleFont;
        _dateStyleLabel.textAlignment = NSTextAlignmentRight;
        _dateStyleLabel.textColor = UIColorFromRGB(0x4b87e5);
        [_headerView addSubview:_dateStyleLabel];
        _headerLine = [[UILabel alloc] initWithFrame:CGRectMake(0, kDatePickerHeaderHeight-1, SCREEN_W, 1)];
        _headerLine.backgroundColor = UIColorFromRGB(0x4b87e5);
        [_headerView addSubview:_headerLine];
    }
    return _headerView;
}

- (UIView *)footerView {
    if (!_footerView) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, kDatePickerHeight-kDatePickerHeaderHeight, self.frame.size.width, kDatePickerHeaderHeight)];
        // Button Cancel
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(kDatePickerPadding, 0.0, kDatePickerButtonHeaderWidth, kDatePickerHeaderHeight)];
        [cancelButton setTitle:kCancelButtonItemTitle forState:UIControlStateNormal];
        [cancelButton setTitleColor:UIColorFromRGB(0xa4a4a4) forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(actionButtonCancel:) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:cancelButton];
        
        // Button confirm
        self.sureButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - kDatePickerButtonHeaderWidth - kDatePickerPadding, 0.0, kDatePickerButtonHeaderWidth, kDatePickerHeaderHeight)];
        [self.sureButton setTitle:kSureButtonItemTitle forState:UIControlStateNormal];
        [self.sureButton setTitleColor:UIColorFromRGB(0x4b87e5) forState:UIControlStateNormal];
        [self.sureButton addTarget:self action:@selector(actionButtonValid:) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:self.sureButton];
        
        _footerLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 1, SCREEN_W, 1)];
        _footerLine.backgroundColor = UIColorFromRGB(0xa4a4a4);
        [_footerView addSubview:_footerLine];
    }
    return _footerView;
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        NSDateFormatter *dateFormatter = [NSDate shareDateFormatter];
        _dateFormatter = dateFormatter;
    }
    _dateFormatter.dateFormat = kDateFormatYYYYMMDD;
    return _dateFormatter;
}

- (NSCalendar *)calendar {
    if (!_calendar) {
        _calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        _calendar.timeZone = self.timeZone;
        _calendar.locale = self.locale;
    }
    return _calendar;
}

- (NSMutableArray *)months {
    NSMutableArray *months = [[NSMutableArray alloc] init];
    for (int monthNumber = 1; monthNumber <= 12; monthNumber++) {
        NSString *dateString = [NSString stringWithFormat: @"%d", monthNumber];
        NSDateFormatter* dateFormatter = self.dateFormatter;
        if (self.timeZone) [dateFormatter setTimeZone:self.timeZone];
        [dateFormatter setLocale:self.locale];
        [dateFormatter setDateFormat:@"MM"];
        NSDate* myDate = [dateFormatter dateFromString:dateString];
        
        NSDateFormatter *formatter = self.dateFormatter;
        if (self.timeZone) [dateFormatter setTimeZone:self.timeZone];
        [dateFormatter setLocale:self.locale];
        [formatter setDateFormat:@"MM"];
        NSString *stringFromDate = [formatter stringFromDate:myDate];
        
        [months addObject:stringFromDate];
    }
    _months = months;
    return _months;
}

- (NSMutableArray*)hours {
    if (!_hours) {
        NSMutableArray *hours = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < 24; i++) {
            if (i < 10) {
                [hours addObject:[NSString stringWithFormat:@"0%d%@", i, @"时"]];
            } else {
                [hours addObject:[NSString stringWithFormat:@"%d%@", i, @"时"]];
            }
        }
        _hours = hours;
    }
    return _hours;
}

- (NSMutableArray*)minutes {
    if (!_minutes) {
        NSMutableArray *minutes = [[NSMutableArray alloc] init];
        /**
         *  only show mininute 00 10 20 ~ 50 in hotel tour edit order for flight pick up
         */
        for (int i = 0; i < 6; i++) {
            if (!i) {
                [minutes addObject:[NSString stringWithFormat:@"%d0%@", i, @"分"]];
            } else {
                [minutes addObject:[NSString stringWithFormat:@"%d%@", i * 10, @"分"]];
            }
            
        }
        _minutes = minutes;
    }
    return _minutes;
}

- (NSMutableArray*)seconds {
    if (!_seconds) {
        
        NSMutableArray *seconds = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < 60; i++) {
            if (i < 10) {
                [seconds addObject:[NSString stringWithFormat:@"0%d", i]];
            } else {
                [seconds addObject:[NSString stringWithFormat:@"%d", i]];
            }
        }
        _seconds = seconds;
    }
    return _seconds;
}
- (NSTimeZone *)timeZone {
    if (!_timeZone) {
        _timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    }
    return _timeZone;
}

- (NSLocale *)locale {
    if (!_locale) {
        _locale = [NSLocale currentLocale];
    }
    return _locale;
}

- (void)setTintColor:(UIColor *)tintColor {
    _tintColor = tintColor;
    [self setupControl];
}

- (void)setHighlightColor:(UIColor *)highlightColor {
    _highlightColor = highlightColor;
    [self setupControl];
}

- (void)setMinimumDate:(NSDate*)date {
    _minimumDate = date;
    NSDateComponents* componentsMin = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:_minimumDate];
    NSInteger yearMin = [componentsMin year];
    _minYear = yearMin;
    [self setupControl];
}

- (void)setMaximumDate:(NSDate*)date {
    _maximumDate = date;
    [self setupControl];
}


@end

