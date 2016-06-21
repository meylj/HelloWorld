#import <Foundation/Foundation.h>



/*!
 *	@brief	Results bean. 
 *	@author	Izual Azurewrath
 *	@since	2011-12-06
 *			Creation. 
 */
@interface Bean_Result : NSObject
{
	NSUInteger	Index;
	NSString	*ItemName;
	NSString	*Limits;
	id			Value;
	BOOL		Result;
}



@property (assign, readwrite)	NSUInteger	Index;		///<	Index of this result in all results. 
@property (retain, readwrite)	NSString	*ItemName;	///<	Test item name. 
@property (retain, readwrite)	NSString	*Limits;	///<	Test limits. 
@property (copy, readwrite)		id			Value;		///<	Test result value. 
@property (assign, readwrite)	BOOL		Result;		///<	Test result. 



@end


