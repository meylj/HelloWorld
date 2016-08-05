//
//  NSDateCategory.h
//  D10_AE-Cake
//
//  Created by Yaya8_liu on 12/9/15.
//  Copyright (c) 2015 Yaya. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (NSDateCategory)

- (NSString *)descriptionWithCalendarFormat:(NSString *)format timeZone:(NSTimeZone *)aTimeZone locale:(id)locale;

@end
