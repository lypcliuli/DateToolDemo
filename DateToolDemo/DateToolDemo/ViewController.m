//
//  ViewController.m
//  DateToolDemo
//
//  Created by LYPC on 2017/12/3.
//  Copyright © 2017年 LYPC. All rights reserved.
//

#import "ViewController.h"
#import "DatePicker.h"
#import "NSDateFormatter+UTCTimeZone.h"

@interface ViewController ()

@end

@implementation ViewController

- (IBAction)clickBtn:(id)sender {
    
    NSDateFormatter *dateFormatter = [NSDateFormatter creatDateFormatter];

    [dateFormatter setDateFormat:@"yyyy年MM"];
    NSDate *minDate = [dateFormatter dateFromString:@"2015年02"];
    NSDate *maxDate = [dateFormatter dateFromString:@"2018年09"];
    NSDate *currentDate = [dateFormatter dateFromString:@"2016年01"];
    
    [[DatePicker shareInstans] showDatePickerMode:DatePickerModeYearAndMonth minDate:minDate maxMamDate:maxDate currentDate:currentDate result:^(NSDate *selectDate, NSString *dateStyle) {
        NSLog(@"11111---%@,%@", selectDate, dateStyle);
    }];
    [DatePicker shareInstans].dateStyle = @"开始时间";
}

- (IBAction)click1:(id)sender {
    NSDateFormatter *dateFormatter = [NSDateFormatter creatDateFormatter];
    
    [dateFormatter setDateFormat:@"yyyy年MM"];
    NSDate *minDate = [dateFormatter dateFromString:@"2014年09"];
    NSDate *maxDate = [dateFormatter dateFromString:@"2017年11"];
    NSDate *currentDate = [dateFormatter dateFromString:@"2026年01"];
    
    //    [[DatePicker shareInstans] showDatePickerMode:DatePickerModeYearAndMonth minDate:minDate maxMamDate:maxDate currentDate:currentDate handle:self];
    
    [[DatePicker shareInstans] showDatePickerMode:DatePickerModeYearAndMonth minDate:minDate maxMamDate:maxDate currentDate:currentDate result:^(NSDate *selectDate, NSString *dateStyle) {
        NSLog(@"22222----%@,%@", selectDate, dateStyle);
    }];
    [DatePicker shareInstans].dateStyle = @"结束时间";
}

#pragma mark - FlatDatePicker Delegate
- (void)datePicker:(DatePicker *)dataPicker didSelectedDate:(NSDate *)date dateStyle:(NSString *)dateStyle {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMM"];
    NSLog(@"1--------:%@---%@", dateStyle, [dateFormatter stringFromDate:date]);
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    // 标题
//    ChartTitleView *titleHead = [[ChartTitleView alloc] initWithFrame:CGRectMake(50, 110, 100, 40) titleText:@"我国进出口分布情况"];
//    titleHead.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:titleHead];
//    titleHead.leftLine.backgroundColor = [UIColor greenColor];
//    titleHead.titleLabel.textColor = [UIColor yellowColor];

    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
