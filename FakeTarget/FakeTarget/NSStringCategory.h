//  NSStringCategory.h
//  FunnyZone
//
//  Created by Kyle Yu on 11-12-28.
//  Copyright 2011年 PEGATRON. All rights reserved.



#import <Foundation/Foundation.h>



/*!	@update	Izual Azurewrath on 2012-09-25. 
 *			Add some convenent APIs and regular expression. 
 *			Deprecated the 3 old methods. */
@interface NSString (NSStringCategory)

/*!	Remove blanks and new lines before&after this string. */
-(NSString*)trim;

-(BOOL)contains:(NSString*)strContain;
-(BOOL)beginWith:(NSString*)strBegin;
-(BOOL)endWith:(NSString*)strEnd;
-(BOOL)matches:(NSString*)strRegex;

-(NSString*)subFrom:(NSString*)strSub
			include:(BOOL)bInclude;
-(NSString*)subTo:(NSString*)strSub
		  include:(BOOL)bInclude;

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

#pragma mark - Deprecated 
/*	Kyle 2012.12.28
 * method     : ContainString:
 * abstract   : judge whether self include in a string. */
- (BOOL)ContainString:(NSString *)szStr;

/*	Kyle 2012.12.28
 * method     : SubFrom:include:
 * abstract   : self substring from a string
 * key        : 
 *              include --> result of substring whether include szStr. */
- (NSString *)SubFrom:(NSString *)szStr include:(BOOL) include;

/*	Kyle 2012.12.28
 * method     : SubTo:include:
 * abstract   : self substring to a string
 * key        : 
 * include --> result of substring whether include szStr*/
- (NSString *)SubTo:(NSString *)szStr include:(BOOL) include;

@end




