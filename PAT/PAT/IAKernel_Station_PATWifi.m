#import "IAKernel_Station_PATWifi.h"



@implementation IAKernel (IAKernel_Station_PATWifi)



#pragma mark - Original Functions 



#pragma mark - Standard Packaged Functions 
-(BOOL)DRAW_CHART_PAT_WIFI:(NSDictionary*)dictProperties 
					RESULT:(id*)idResult
{
	NSArray	*aryMagnitude	= [self memoryForKey:@"MagnitudeData"];
	NSArray	*aryPhase		= [self memoryForKey:@"PhaseData"];
	if(![aryMagnitude isKindOfClass:[NSArray class]] 
	   || ![aryPhase isKindOfClass:[NSArray class]])
	{
		if(NULL != &idResult)
			*idResult	= @"No data found. ";
		return NO;
	}
	
	NSDictionary	*dictNote	= [NSDictionary dictionaryWithObjectsAndKeys:
								   aryMagnitude,	@"Magnitude",
								   aryPhase,		@"Phase", nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:noteDiagramShouldBegin 
														object:self 
													  userInfo:dictNote];
	if(NULL != &idResult)
		*idResult	= @"Draw diagram. ";
	return YES;
}



@end


