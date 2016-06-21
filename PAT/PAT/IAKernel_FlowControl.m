#import "IAKernel_FlowControl.h"



@implementation IAKernel (IAKernel_FlowControl)



#pragma mark - Original Functions 
-(BOOL)ForLoop:(NSDictionary *)dictProperties 
		 begin:(NSString *)strBegin 
		   end:(NSString *)strEnd 
		  step:(NSString *)strStep 
	 failbreak:(BOOL)bFailBreak 
		result:(id *)idResult 
		 error:(NSError **)error
{
	return NO;
}

-(BOOL)wait:(NSUInteger)iTime
{
	usleep(iTime);
	return YES;
}



#pragma mark - Standard Packaged Functions 
-(BOOL)FOR_LOOP:(NSDictionary*)dictProperties 
		 RESULT:(id*)idResult
{
	return NO;
}

-(BOOL)WAIT:(NSDictionary*)dictProperties 
	 RESULT:(id*)idResult
{
	NSUInteger	iTime	= ([[dictProperties objectForKey:@"TIME"] isKindOfClass:[NSNumber class]] 
						   ? [[dictProperties objectForKey:@"TIME"] unsignedIntegerValue] 
						   : 100);
	return [self wait:iTime];
}



@end


