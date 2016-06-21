#import "NSString_IA.h"



@implementation NSString (NSString_IA)



#pragma mark - Judgement 
-(BOOL)isEmpty
{
	return (0 == [self length]);
}

-(BOOL)beginWith:(NSString*)strBegin
{
	if([self length] < [strBegin length])
		return NO;
	for(NSUInteger i=0; i<[strBegin length]; i++)
		if([strBegin characterAtIndex:i]
		   != [self characterAtIndex:i])
			return NO;
	return YES;
}

-(BOOL)endWith:(NSString*)strEnd
{
	if([self length] < [strEnd length])
		return NO;
	NSUInteger	iIndex	= [self length] - [strEnd length];
	for(NSUInteger i=0; i<[strEnd length]; i++)
		if([strEnd characterAtIndex:i]
		   != [self characterAtIndex:(iIndex + i)])
			return NO;
	return YES;
}

-(BOOL)contains:(NSString*)strSubString
{
	return (NSNotFound != [self rangeOfString:strSubString].location);
}

-(BOOL)matches:(NSString*)strRegex
{
	// Create regex. 
	NSRegularExpression	*regex	= [NSRegularExpression 
								   regularExpressionWithPattern:strRegex 
								   options:NSRegularExpressionDotMatchesLineSeparators 
								   error:nil];
	if(!regex)
		return NO;
	return [regex numberOfMatchesInString:self 
								  options:NSMatchingCompleted 
									range:NSMakeRange(0, [self length])];
}



#pragma mark - Sub Strings 
-(NSString*)subTo:(NSString*)strStop 
		  include:(BOOL)bInclude
{
	NSRange	range	= [self rangeOfString:strStop];
	if(NSNotFound == range.location)
		return self;
	return (bInclude 
			? [self substringToIndex:range.location + range.length] 
			: [self substringToIndex:range.location]);
}

-(NSString*)subFrom:(NSString*)strFrom 
			include:(BOOL)bInclude
{
	NSRange	range	= [self rangeOfString:strFrom];
	if(NSNotFound == range.location)
		return self;
	return (bInclude 
			? [self substringFromIndex:range.location] 
			: [self substringFromIndex:range.location + range.length]);
}

-(id)subByRegex:(NSString*)strRegex 
	  withNames:(NSArray*)aryNames 
		  error:(NSError**)error
{
	// Create regex and check if string matches it. 
	NSRegularExpression	*regex	= [NSRegularExpression 
								   regularExpressionWithPattern:strRegex 
								   options:NSRegularExpressionDotMatchesLineSeparators 
								   error:error];
	if(!regex)
	{
		if(NULL != error)
			*error	= [NSError errorWithDomain:[NSString stringWithFormat:
												@"Invalid regex source: [%@]. ", 
												strRegex] 
										 code:__LINE__ 
									 userInfo:nil];
		return nil;
	}
	if(![regex numberOfMatchesInString:self 
							   options:NSMatchingCompleted 
								 range:NSMakeRange(0, [self length])])
	{
		if(NULL != error)
			*error	= [NSError errorWithDomain:[NSString stringWithFormat:
												@"String [%@] doesn't matches regex [%@]. ", 
												self, strRegex] 
										 code:__LINE__ 
									 userInfo:nil];
		return nil;
	}
	// Sub. 
	NSArray	*aryTexts	= [regex matchesInString:self 
									   options:NSMatchingCompleted 
										 range:NSMakeRange(0, [self length])];
	NSMutableArray	*aryResults	= [NSMutableArray array];
	for(NSTextCheckingResult *result in aryTexts)
	{
		for(NSUInteger i=1; i<[result numberOfRanges]; i++)
		{
			NSString	*strSub	= [self substringWithRange:[result rangeAtIndex:i]];
			[aryResults addObject:strSub];
		}
	}
	// Return. 
	if(!aryNames)
		return [aryResults objectAtIndex:0];
	else if(![aryNames count])
		return aryResults;
	else if([aryNames count] != [aryResults count])
	{
		if(NULL != error)
			*error	= [NSError errorWithDomain:@"Names count != results count. " 
										 code:__LINE__ 
									 userInfo:nil];
		return nil;
	}
	else
	{
		NSMutableDictionary	*dictResult	= [NSMutableDictionary dictionary];
		for(NSUInteger i=0; i<[aryNames count]; i++)
			[dictResult setObject:[aryResults objectAtIndex:i] 
						   forKey:[aryNames objectAtIndex:i]];
		return [NSDictionary dictionaryWithDictionary:dictResult];
	}
}



#pragma mark - Trim Strings 
-(NSString*)trim
{
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}



@end


