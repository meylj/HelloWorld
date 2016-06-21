#import "IAKernel.h"



/*!
 *	@Author	Izual Azurewrath
 *	@Since	2011-12-05
 *			Creation. 
 */
@interface IAKernel (IAKernel_FlowControl)



#pragma mark - Original Functions 
-(BOOL)ForLoop:(NSDictionary*)dictProperties 
		 begin:(NSString*)strBegin 
		   end:(NSString*)strEnd 
		  step:(NSString*)strStep 
	 failbreak:(BOOL)bFailBreak 
		result:(id*)idResult 
		 error:(NSError**)error;

/*!	@param	iTime
 *			Unit: 10^-6s, microseconds. */
-(BOOL)wait:(NSUInteger)iTime;



#pragma mark - Standard Packaged Functions 
-(BOOL)FOR_LOOP:(NSDictionary*)dictProperties 
		 RESULT:(id*)idResult;

-(BOOL)WAIT:(NSDictionary*)dictProperties 
	 RESULT:(id*)idResult;



@end


