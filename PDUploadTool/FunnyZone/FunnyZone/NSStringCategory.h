//
//  NSStringCategory.h
//  FunnyZone
//
//  Created by Kyle Yu on 11-12-28.
//  Copyright 2011年 PEGATRON. All rights reserved.
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

/*
 * 
 * method     : endWith:
 * abstract   : judge whether self string is endwith a string
 *
 */
-(BOOL)endWith:(NSString*)strEnd;

/*
 *
 * method     : endWith:
 * abstract   : judge whether self string is beginwith a string
 *
 */
-(BOOL)beginWith:(NSString*)strBegin;



//add regular expression function, 2014/03/27
#pragma regular expression
/*!	Remove blanks and new lines before&after this string. */
-(NSString*)trim;

-(BOOL)matches:(NSString*)strRegex;


/*! Sub strings by given regex.
 *	@param	strRegex
 *			The regular expression string.
 *	@param	idName
 *			NSString:
 *			NSArray:
 *			NSDictionary:
 *	@param	error
 *			An error object contains error messages when return nil.
 *	@retval	NSString
 *			If idName is nil;
 *	@retval	NSArray
 *			If idName is an empty array.
 *	@retval	NSDictionary
 *			If idName is an array not empty.
 *	@retval	nil
 *			Error occures. */
-(id)subByRegex:(NSString*)strRegex
		   name:(id)idName
		  error:(NSError**)error;


@end
