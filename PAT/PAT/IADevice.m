#import "IADevice.h"



@implementation IADevice



#pragma mark - NSObject Override 
- (id)init
{
    self = [super init];
    if (self) 
	{
		m_iDevice		= 0;
		m_bAutoFlush	= NO;
    }
    return self;
}



#pragma mark - Original Functions 
-(BOOL)subResponse:(NSString*)strResponse 
	withProperties:(NSDictionary*)dictProperties 
			result:(id*)idResult
{
	// Get regex and names. 
	id	strRegex	= [dictProperties objectForKey:@"SUB_REGEX"];
	id	aryNames	= [dictProperties objectForKey:@"SUB_NAMES"];
	if(![strRegex isKindOfClass:[NSString class]])
	{
		if(NULL != &idResult)
			*idResult	= strResponse;
		return YES;
	}
	// Sub. 
	id		idSubed	= nil;
	NSError	*error	= nil;
	if([aryNames isKindOfClass:[NSArray class]])
		idSubed	= [strResponse subByRegex:strRegex 
								withNames:aryNames 
									error:&error];
	else
		idSubed	= [strResponse subByRegex:strRegex 
								withNames:nil 
									error:&error];
	// Return. 
	if(NULL != &idResult)
		*idResult	= (idSubed ? idSubed : [error domain]);
	return (idSubed ? YES : NO);
}



#pragma mark - Standard Packaged Functions 
-(id)INIT_WITH_PROPERTIES:(NSDictionary*)dictProperties 
				   RESULT:(id *)idResult
{
	[self init];
	return self;
}

-(BOOL)SET_PROPERTIES:(NSDictionary*)dictProperties 
			   RESULT:(id*)idResult
{
	if(NULL != idResult)
		*idResult	= IADEVICE_INTERFACE_FUNCTION;
	return NO;
}

-(BOOL)CONNECT:(NSDictionary*)dictCommand 
		RESULT:(id *)idResul
{
	if(NULL != idResul)
		*idResul	= IADEVICE_INTERFACE_FUNCTION;
	return NO;
}

-(BOOL)SEND_COMMAND:(NSDictionary*)dictCommand 
			 RESULT:(id*)idResult
{
	if(NULL != idResult)
		*idResult	= IADEVICE_INTERFACE_FUNCTION;
	return NO;
}

-(BOOL)FLUSH_BUFFER:(NSDictionary*)dictCommand 
			 RESULT:(id*)idResult
{
	if(NULL != idResult)
		*idResult	= IADEVICE_INTERFACE_FUNCTION;
	return NO;
}

-(BOOL)RECEIVE_COMMAND:(NSDictionary*)dictCommand 
				RESULT:(id*)idResult
{
	if(NULL != idResult)
		*idResult	= IADEVICE_INTERFACE_FUNCTION;
	return NO;
}

-(BOOL)DISCONNECT:(NSDictionary*)dictCommand 
		   RESULT:(id*)idResult
{
	if(NULL != idResult)
		*idResult	= IADEVICE_INTERFACE_FUNCTION;
	return NO;
}



#pragma mark - Basic Informations 
-(NSString *)Name
{
	return IADEVICE_INTERFACE_FUNCTION;
}
-(NSUInteger)Timeout
{
	return 0;
}
-(void)setTimeout:(NSUInteger)newTimeout
{
	return;
}
-(BOOL)AutoFlush
{
	return NO;
}
-(void)setAutoFlush:(BOOL)AutoFlush
{
	return;
}



@end


