//
//  NSStringCategory.h
//  Batch_Query_From_QCR
//
//  Created by Kyle Yu on 12-11-20.
//  Copyright 2012年 PEGATRON. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NSStringCategory)
/*
 * Kyle 2012.12.28
 * method     : ContainString:
 * abstract   : judge whether self include in a string
 * 
 */
- (BOOL)ContainString:(NSString *)szStr;

/*
 * Kyle 2012.12.28
 * method     : SubFrom:include:
 * abstract   : self substring from a string
 * key        : 
 *              include --> result of substring whether include szStr
 */
- (NSString *)SubFrom:(NSString *)szStr include:(BOOL) include;

/*
 * Kyle 2012.12.28
 * method     : SubTo:include:
 * abstract   : self substring to a string
 * key        : 
 *              include --> result of substring whether include szStr
 */
- (NSString *)SubTo:(NSString *)szStr include:(BOOL) include;
@end
