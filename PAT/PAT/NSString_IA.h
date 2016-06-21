#import <Foundation/Foundation.h>



/*!
 *	Java API is good. 
 *	@brief	Catagory for Java API. 
 *	@author	Izual Azurewrath
 *	@since	2011-11-29
 *			Creation. 
 */
@interface NSString (NSString_IA)



#pragma mark - Judgement 
-(BOOL)isEmpty;
-(BOOL)beginWith:(NSString*)strSub;
-(BOOL)endWith:(NSString*)strSub;
-(BOOL)contains:(NSString*)strSub;
-(BOOL)matches:(NSString*)strRegex;



#pragma mark - Sub Strings 
-(NSString*)subTo:(NSString*)strStop 
		  include:(BOOL)bInclude;
-(NSString*)subFrom:(NSString*)strFrom 
			include:(BOOL)bInclude;
/*!
 *	@param	aryNames
 *			Contains names for each subed strings. 
 *	@retval	NSString*
 *			When aryNames is nil or empty, and there's only one result. 
 *	@retval	NSArray*
 *			When aryNames is nil or empty, and there's lots of results. 
 *	@retval	NSDictionary*
 *			Otherwise. 
 *	@retval nil
 *			No result because of error. 
 */
-(id)subByRegex:(NSString*)strRegex 
	  withNames:(NSArray*)aryNames 
		  error:(NSError**)error;



#pragma mark - Trim Strings 
/*!	Remove blanks and new line symbols before and after the string. */
-(NSString*)trim;



@end


