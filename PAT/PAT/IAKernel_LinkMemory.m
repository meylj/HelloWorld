#import "IAKernel_LinkMemory.h"



@implementation IAKernel (IAKernel_LinkMemory)



-(void)memory:(id)idObject 
	  withKey:(NSString*)strKey
{
	@synchronized(m_dictMemory)
	{
		[m_dictMemory setObject:idObject forKey:strKey];
	}
}

-(id)memoryForKey:(NSString*)strKey
{
	return [m_dictMemory objectForKey:strKey];
}

-(NSString*)translateMemory:(NSString*)strSource
{
	NSMutableString	*strResult	= [NSMutableString stringWithString:strSource];
	NSRange			rangeSubBegin	= [strResult rangeOfString:@"/*"];
	NSRange			rangeSubEnd		= [strResult rangeOfString:@"*/"];
	while(NSNotFound != rangeSubBegin.location
		  && NSNotFound != rangeSubEnd.location
		  && (rangeSubEnd.location - rangeSubBegin.location) >= 2)
	{
		NSRange	rangeKey	= NSMakeRange(rangeSubBegin.location + rangeSubBegin.length, 
										  rangeSubEnd.location - rangeSubBegin.location - rangeSubBegin.length);
		NSString	*strKey		= [strResult substringWithRange:rangeKey];
		NSString	*strValue	= [[self memoryForKey:strKey] description];
		rangeKey	= NSMakeRange(rangeSubBegin.location, 
								  rangeSubEnd.location - rangeSubBegin.location + rangeSubEnd.length);
		[strResult replaceCharactersInRange:rangeKey withString:strValue];
		rangeSubBegin	= [strResult rangeOfString:@"/*"];
		rangeSubEnd		= [strResult rangeOfString:@"*/"];
	}
	return [strResult description];
}

-(BOOL)SHOW_MEMORY:(NSDictionary*)dictProperties 
			RESULT:(id*)idResult
{
	if([[dictProperties objectForKey:@"SOURCE"] isKindOfClass:[NSString class]])
	{
		id	idMemory	= [self memoryForKey:[self translateMemory:[dictProperties objectForKey:@"SOURCE"]]];
		if(idMemory)
		{
			if(NULL != idResult)
				*idResult	= idMemory;
			return YES;
		}
		else
		{
			if(NULL != idResult)
				*idResult	= @"Memory not found. ";
			return NO;
		}
	}
	return NO;
}



@end


