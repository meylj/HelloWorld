#import "IAKernel.h"



/*!
 *	@Author	Izual Azurewrath
 *	@Since	2011-12-26
 *			Creation. 
 */
@interface IAKernel (IAKernel_Limits)



#pragma mark - Result Judgement 
-(BOOL)judgeResult:(Bean_Result*)result;

/*!	
 *	@defgroup	IAKernel_Result_Judgement IAKernel_Result_Judgement
 *				Judge result by set or regex. 
 *	@param		strSet
 *				The math set or regex. 
 */
///	@{
-(BOOL)judgeResult:(id)idResult 
		   withSet:(NSString*)strSet;

-(BOOL)judgeNum:(NSNumber*)numResult 
		withSet:(NSString*)strSet;
-(BOOL)judgeStr:(NSString*)strResult 
		withSet:(NSString*)strSet;
-(BOOL)judgeArray:(NSArray*)aryResult 
		  withSet:(NSString*)strSet;
-(BOOL)judgeDict:(NSDictionary*)dictResult 
		 withSet:(NSString*)strSet;
///	@}



@end


