#import "IAKernel_Network.h"



@implementation IAKernel (IAKernel_Network)



#pragma mark - Data Access 
-(NSDictionary*)queryData:(NSDictionary*)dictKeywords 
				  fromURL:(NSString*)strURL 
				 withInfo:(NSDictionary*)dictInfo 
					error:(NSError**)error
{
	// Create HTTP request. 
	NSString	*strParamKey	= [strURL subFrom:@"?" include:NO];
	NSMutableString	*strRequest	= [NSMutableString stringWithString:[strURL subTo:@"?" include:YES]];
	for(NSString *strKey in [dictKeywords allKeys])
		[strRequest appendFormat:@"%@=%@&", strParamKey, strKey];
	for(NSString *strKey in [dictInfo allKeys])
		[strRequest appendFormat:@"%@=%@&", strKey, [dictInfo objectForKey:strKey]];
	NSString	*strHttpRequest	= [strRequest stringByReplacingOccurrencesOfString:@" " 
																	 withString:@"%20"];
	NSURL	*url	= [NSURL URLWithString:strHttpRequest];
	if(!url)
	{
		if(NULL != error)
			*error	= [NSError errorWithDomain:[NSString stringWithFormat:
												@"Can not create request URL with string: [%@]. ", 
												strHttpRequest] 
										 code:__LINE__ 
									 userInfo:nil];
		return nil;
	}
	NSMutableURLRequest	*request	= [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:@"POST"];
	[request setValue:@"text/html;charset=UTF8" forHTTPHeaderField:@"Content-Type"];
	[request setTimeoutInterval:IAKERNEL_NETWORK_TIMEOUT];
	// Post request and receive response. 
	NSHTTPURLResponse	*response;
	NSData	*dataResponse	= [NSURLConnection sendSynchronousRequest:request 
												 returningResponse:&response 
															 error:error];
	if([response statusCode] != 200)
		return nil;
	NSString	*strResponse	= [[NSString alloc] initWithData:dataResponse 
												  encoding:NSUTF8StringEncoding];
	if(![strResponse contains:IAKERNEL_NETWORK_PASS])
	{
		if(NULL != error)
			*error	= [NSError errorWithDomain:strResponse code:__LINE__ userInfo:nil];
		return nil;
	}
	// Intercept values out. 
	NSMutableDictionary	*dictResponse	= [NSMutableDictionary dictionary];
	for(NSString *strKey in [dictKeywords allKeys])
	{
		if(![strResponse contains:strKey])
		{
			if(NULL != error)
				*error	= [NSError errorWithDomain:[NSString stringWithFormat:
													@"Missing value for key [%@]. ", strKey] 
											 code:__LINE__ 
										 userInfo:nil];
			return nil;
		}
		NSString	*strValue	= [strResponse subFrom:[NSString stringWithFormat:@"%@=", strKey] 
										  include:NO];
		strValue	= [strValue subTo:[dictKeywords objectForKey:strKey] include:NO];
		[dictResponse setObject:strValue forKey:strKey];
	}
	[strResponse release];	strResponse	= nil;
	// End. 
	return [NSDictionary dictionaryWithDictionary:dictResponse];
}
-(BOOL)QUERY_DATA:(NSDictionary*)dictProperties 
		   RESULT:(id*)idResult
{
	return NO;
}



@end


