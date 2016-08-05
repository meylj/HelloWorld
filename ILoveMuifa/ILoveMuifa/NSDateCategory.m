//
//  NSDateCategory.m
//  D10_AE-Cake
//
//  Created by Yaya8_liu on 12/9/15.
//  Copyright (c) 2015 Yaya. All rights reserved.
//

#import "NSDateCategory.h"

@implementation NSDate (NSDateCategory)

- (NSString *)descriptionWithCalendarFormat:(NSString *)format timeZone:(NSTimeZone *)aTimeZone locale:(id)locale
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if (aTimeZone)
    {
        [dateFormatter setTimeZone:aTimeZone];
    }
    [dateFormatter setDateFormat:format];
    NSString *szResult = [dateFormatter stringFromDate:self];
    //[dateFormatter release];
    return szResult;
}

@end
