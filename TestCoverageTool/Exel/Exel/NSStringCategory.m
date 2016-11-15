//
//  NSStringCategory.m
//  TestStation
//
//  Created by Jean on 8/11/15.
//  Copyright (c) 2015 Jean. All rights reserved.
//

#import "NSStringCategory.h"

@implementation NSString (NSStringCategory)

-(NSString *)catchStringBeginWith:(NSString *)strBegin
                          endWith:(NSString *)strEnd
{
    //begin string == null, end string != null
    if ((!strBegin || [strBegin isEqualToString:@""])
        && (strEnd != nil && ![strEnd isEqualToString:@""]))
    {
        NSRange endRange = [self rangeOfString:strEnd];
        if (NSNotFound != endRange.location) {
            return [self substringToIndex:endRange.location];
        }
        else
            return @"Not found end string";
    }
    //begin string != null, end string == null
    else if((strBegin != nil && ![strBegin isEqualToString:@""])
            && (!strEnd || [strEnd isEqualToString:@""]))
    {
        NSRange beginRange = [self rangeOfString:strBegin];
        if (NSNotFound != beginRange.location) {
            return [self substringFromIndex:beginRange.location+beginRange.length];
        }
        else
            return @"Not found begin string";
    }
    //begin string != null, end string != null
    else if (strBegin != nil && ![strBegin isEqualToString:@""]
             && strEnd != nil && ![strEnd isEqualToString:@""])
    {
        // added by Jockey
        NSRange beginRange	= [self rangeOfString:strBegin];
        NSRange endRange	= [self rangeOfString:strEnd options:4];
        if (NSNotFound != beginRange.location && NSNotFound != endRange.location) {
            NSRange subRange;
            if (endRange.location == beginRange.location) {
                return @"Not found begin string or end string";
            }
            else{
                subRange.location	= beginRange.location + beginRange.length;
                
                subRange.length		= endRange.location - beginRange.location - beginRange.length;
                return [self substringWithRange:subRange];
            }
        }
        else
            return @"Not found begin string or end string";
    }
    else
        return self;
}


@end
