//
//  NSDateCategory.h
//  FunnyZone
//
//  Created by raniys on 1/22/15.
//  Copyright (c) 2015 PEGATRON. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (NSDateCategory)
//Format date
- (NSString *)descriptionWithCalendarFormat:(NSString *)format timeZone:(NSTimeZone *)aTimeZone locale:(id)locale;
@end
