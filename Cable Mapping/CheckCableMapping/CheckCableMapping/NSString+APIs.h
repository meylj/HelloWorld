#import <Foundation/Foundation.h>

/*!	@author	Izual Azurewrath
 *	@since	2012-10-16 
 *	Added some convenient API like Java. */
@interface NSString (APIs)
#pragma mark - Compare
-(BOOL)equalsIgnoreCase:(NSString*)strCompare;

#pragma mark - Finding
-(BOOL)matches:(NSString*)strRegex;
-(BOOL)contains:(NSString*)strSub;
-(BOOL)beginWith:(NSString*)strSub;
-(BOOL)endWith:(NSString*)strSub;

#pragma mark - Dividing
-(NSString*)trim;
-(id)subByRegex:(NSString*)strRegex
		  names:(NSArray*)aryNames
		  error:(NSError**)error;
-(NSString*)divideFrom:(NSString*)strSub
			   include:(BOOL)bInclude;
-(NSString*)divideTo:(NSString*)strSub
			 include:(BOOL)bInclude;
@end



NSString* strNSStringEncoding(NSStringEncoding encoding);
NSStringEncoding encodingFromString(NSString *strEncoding);




