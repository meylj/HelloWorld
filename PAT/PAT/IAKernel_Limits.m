#import "IAKernel_Limits.h"



@implementation IAKernel (IAKernel_Limits)



#pragma mark - Result Judgement 
-(BOOL)judgeResult:(Bean_Result*)result
{
	return [self judgeResult:result.Value withSet:result.Limits];
}
-(BOOL)judgeResult:(id)idResult 
		   withSet:(NSString*)strSet
{
	// Basic judgement. 
	if(!strSet || [strSet isEmpty])
		return YES;
	if(!idResult)
		return NO;
	// Judgement with set. 
	if([idResult isKindOfClass:[NSNumber class]])
		return [self judgeNum:idResult withSet:strSet];
	else if([idResult isKindOfClass:[NSString class]])
		return [self judgeStr:idResult withSet:strSet];
	else if([idResult isKindOfClass:[NSArray class]])
		return [self judgeArray:idResult withSet:strSet];
	else if([idResult isKindOfClass:[NSDictionary class]])
		return [self judgeDict:idResult withSet:strSet];
	else
		return NO;
}

-(BOOL)judgeNum:(NSNumber*)numResult 
		withSet:(NSString*)strSet
{
	return [self judgeStr:[numResult description] 
				  withSet:strSet];
}
-(BOOL)judgeStr:(NSString*)strResult 
		withSet:(NSString*)strSet
{	
	// Set? 
	if([strSet matches:@"^\\{.*\\}$"])
	{
		strSet	= [strSet substringWithRange:NSMakeRange(1, [strSet length] - 2)];
		NSArray	*arySet	= [strSet componentsSeparatedByString:@","];
		return [arySet containsObject:strResult];
	}
	
	// String? 
	if(![strSet matches:@"^[(\\[].*,.*[)\\]]$"])
		return [strResult matches:strSet];
	
	// Numbers. 
	// Get number value. 
	double		dValue	= 0;
	NSScanner	*scan	= [NSScanner scannerWithString:strResult];
	[scan scanDouble:&dValue];
	// Get limits value. 
	NSString	*strLimits	= [strSet substringWithRange:NSMakeRange(1, [strSet length] - 2)];
	NSArray		*aryLimits	= [strLimits componentsSeparatedByString:@","];
	double		dLowerLimit	= 0;
	scan	= [NSScanner scannerWithString:[aryLimits objectAtIndex:0]];
	[scan scanDouble:&dLowerLimit];
	double		dUpperLimit	= 0;
	scan	= [NSScanner scannerWithString:[aryLimits objectAtIndex:1]];
	[scan scanDouble:&dUpperLimit];
	// Judge value with limits. 
	if([strSet beginWith:@"("] && !(dValue > dLowerLimit))
		return NO;
	if([strSet beginWith:@"["] && !(dValue >= dLowerLimit))
		return NO;
	if([strSet endWith:@")"] && !(dValue < dUpperLimit))
		return NO;
	if([strSet endWith:@"]"] && !(dValue <= dUpperLimit))
		return NO;
	return YES;
}
-(BOOL)judgeArray:(NSArray*)aryResult 
		  withSet:(NSString*)strSet
{
	for(NSObject *obj in aryResult)
		if(![self judgeStr:[obj description] 
				   withSet:strSet])
			return NO;
	return YES;
}
-(BOOL)judgeDict:(NSDictionary*)dictResult 
		 withSet:(NSString*)strSet
{
	for(NSObject *obj in [dictResult allValues])
		if(![self judgeStr:[obj description] 
				   withSet:strSet])
			return NO;
	return YES;
}



@end


