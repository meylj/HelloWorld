//
//  NSDateCategory.m
//  FunnyZone
//
//  Created by raniys on 1/22/15.
//  Copyright (c) 2015 PEGATRON. All rights reserved.
//

#import "NSDateCategory.h"

@implementation NSDate (NSDateCategory)
- (NSString *)descriptionWithCalendarFormat:(NSString *)format timeZone:(NSTimeZone *)aTimeZone locale:(id)locale
{
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:format];
    [outputFormatter setTimeZone:aTimeZone];
    NSString *newDateString = [outputFormatter stringFromDate:self];
//    [outputFormatter release]; outputFormatter = nil;
    return newDateString;
}
@end
