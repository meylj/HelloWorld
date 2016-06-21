#import "NSString+APIs.h"



@implementation NSString (APIs)
#pragma mark - Compare
-(BOOL)equalsIgnoreCase:(NSString *)strCompare
{
	return [[self uppercaseString] isEqualToString:
			[strCompare uppercaseString]];
}

#pragma mark - Finding 
-(BOOL)matches:(NSString *)strRegex
{
	NSRegularExpression	*regex	= [NSRegularExpression
								   regularExpressionWithPattern:strRegex
								   options:NSRegularExpressionDotMatchesLineSeparators
								   error:nil];
	if(!regex)
		return NO;
	return [regex numberOfMatchesInString:self
								  options:NSMatchingReportCompletion
									range:NSMakeRange(0, [self length])];
}
-(BOOL)contains:(NSString *)strSub
{
	return (NSNotFound != [self rangeOfString:strSub].location);
}
-(BOOL)beginWith:(NSString *)strSub
{
	NSRange	range	= [self rangeOfString:strSub];
	return (NSNotFound != range.location
			&& range.location == 0);
}
-(BOOL)endWith:(NSString *)strSub
{
	NSRange	range	= [self rangeOfString:strSub];
	return (NSNotFound != range.location
			&& [self length] == range.location + range.length);
}

#pragma mark - Dividing
-(NSString *)trim
{
	return [self stringByTrimmingCharactersInSet:
			[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
-(id)subByRegex:(NSString *)strRegex
		  names:(NSArray *)aryNames
		  error:(NSError **)error
{
	// Generate regular expression.
	NSRegularExpression	*regex	= [NSRegularExpression
								   regularExpressionWithPattern:strRegex
								   options:NSRegularExpressionDotMatchesLineSeparators
								   error:error];
	if(!regex)
		return nil;
	
	// Get sub strings.
	NSArray	*aryResults	= [regex matchesInString:self
										 options:NSMatchingReportCompletion
										   range:NSMakeRange(0, [self length])];
	NSMutableArray	*arySubs	= [NSMutableArray array];
	for(NSTextCheckingResult *result in aryResults)
		for(NSUInteger i=1; i<[result numberOfRanges]; i++)
		{
			NSRange		range	= [result rangeAtIndex:i];
			NSString	*strSub	= [self substringWithRange:range];
			[arySubs addObject:strSub];
		}
	
	// Generate return values;
	if(![arySubs count])
	{
//		IAMakeError(error, @"Sub string not found. ");
		return nil;
	}
	else if(!aryNames)
		return [arySubs objectAtIndex:0];
	else if(![aryNames count])
		return aryNames;
	else
	{
		NSMutableDictionary	*dictSubs	= [NSMutableDictionary dictionary];
		NSUInteger	iCount	= ([aryNames count] > [arySubs count]
							   ? [arySubs count]
							   : [aryNames count]);
		for(int i=0; i<iCount; i++)
			[dictSubs setObject:[arySubs objectAtIndex:i]
						 forKey:[aryNames objectAtIndex:i]];
		return dictSubs;
	}
}
-(NSString *)divideFrom:(NSString *)strSub
				include:(BOOL)bInclude
{
	NSRange	range	= [self rangeOfString:strSub];
	if(NSNotFound == range.location)
		return nil;
	return (bInclude
			? [self substringFromIndex:range.location]
			: [self substringFromIndex:range.location + range.length]);
}
-(NSString *)divideTo:(NSString *)strSub
			  include:(BOOL)bInclude
{
	NSRange	range	= [self rangeOfString:strSub];
	if(NSNotFound == range.location)
		return nil;
	return (bInclude
			? [self substringToIndex:range.location + range.location]
			: [self substringToIndex:range.location]);
}
@end



static	NSDictionary	*g_StringEncodingMapping	= nil;
NSString* strNSStringEncoding(NSStringEncoding encoding)
{
	switch(encoding)
	{
		case NSASCIIStringEncoding:
			return @"ASCII";
		case NSNEXTSTEPStringEncoding:
			return @"NEXTSTEP";
		case NSJapaneseEUCStringEncoding:
			return @"JapaneseEUC";
		case NSUTF8StringEncoding:
			return @"UTF8";
		case NSISOLatin1StringEncoding:
			return @"ISOLatin1";
		case NSSymbolStringEncoding:
			return @"Symbol";
		case NSNonLossyASCIIStringEncoding:
			return @"NonLossyASCII";
		case NSShiftJISStringEncoding:
			return @"ShiftJIS";
		case NSISOLatin2StringEncoding:
			return @"ISOLatin2";
		case NSUnicodeStringEncoding:
			return @"Unicode";
		case NSWindowsCP1251StringEncoding:
			return @"WindowsCP1251";
		case NSWindowsCP1252StringEncoding:
			return @"WindowsCP1252";
		case NSWindowsCP1253StringEncoding:
			return @"WindowsCP1253";
		case NSWindowsCP1254StringEncoding:
			return @"WindowsCP1254";
		case NSWindowsCP1250StringEncoding:
			return @"WindowsCP1250";
		case NSISO2022JPStringEncoding:
			return @"ISO2022JP";
		case NSMacOSRomanStringEncoding:
			return @"MacOSRoman";
		case NSUTF16BigEndianStringEncoding:
			return @"UTF16BigEndian";
		case NSUTF16LittleEndianStringEncoding:
			return @"UTF16LittleEndian";
		case NSUTF32StringEncoding:
			return @"UTF32";
		case NSUTF32BigEndianStringEncoding:
			return @"UTF32BigEndian";
		case NSUTF32LittleEndianStringEncoding:
			return @"UTF32LittleEndian";
		case NSProprietaryStringEncoding:
			return @"Proprietary";
		default:
			return nil;
	}
}
NSStringEncoding encodingFromString(NSString *strEncoding)
{
	if(!g_StringEncodingMapping)
		g_StringEncodingMapping	= [[NSDictionary alloc] initWithObjectsAndKeys:
								   [NSNumber numberWithInt:NSASCIIStringEncoding],
								   @"ASCII",
								   [NSNumber numberWithInt:NSNEXTSTEPStringEncoding],
								   @"NEXTSTEP",
								   [NSNumber numberWithInt:NSJapaneseEUCStringEncoding],
								   @"JapaneseEUC",
								   [NSNumber numberWithInt:NSUTF8StringEncoding],
								   @"UTF8",
								   [NSNumber numberWithInt:NSISOLatin1StringEncoding],
								   @"ISOLatin1",
								   [NSNumber numberWithInt:NSSymbolStringEncoding],
								   @"Symbol",
								   [NSNumber numberWithInt:NSNonLossyASCIIStringEncoding],
								   @"NonLossyASCII",
								   [NSNumber numberWithInt:NSShiftJISStringEncoding],
								   @"ShiftJIS",
								   [NSNumber numberWithInt:NSISOLatin2StringEncoding],
								   @"ISOLatin2",
								   [NSNumber numberWithInt:NSUnicodeStringEncoding],
								   @"Unicode",
								   [NSNumber numberWithInt:NSWindowsCP1251StringEncoding],
								   @"WindowsCP1251",
								   [NSNumber numberWithInt:NSWindowsCP1252StringEncoding],
								   @"WindowsCP1252",
								   [NSNumber numberWithInt:NSWindowsCP1253StringEncoding],
								   @"WindowsCP1253",
								   [NSNumber numberWithInt:NSWindowsCP1254StringEncoding],
								   @"WindowsCP1254",
								   [NSNumber numberWithInt:NSWindowsCP1250StringEncoding],
								   @"WindowsCP1250",
								   [NSNumber numberWithInt:NSISO2022JPStringEncoding],
								   @"ISO2022JP",
								   [NSNumber numberWithInt:NSMacOSRomanStringEncoding],
								   @"MacOSRoman",
								   [NSNumber numberWithInt:NSUTF16BigEndianStringEncoding],
								   @"UTF16BigEndian",
								   [NSNumber numberWithInt:NSUTF16LittleEndianStringEncoding],
								   @"UTF16LittleEndian",
								   [NSNumber numberWithInt:NSUTF32StringEncoding],
								   @"UTF32",
								   [NSNumber numberWithInt:NSUTF32BigEndianStringEncoding],
								   @"UTF32BigEndian",
								   [NSNumber numberWithInt:NSUTF32LittleEndianStringEncoding],
								   @"UTF32LittleEndian",
								   [NSNumber numberWithInt:NSProprietaryStringEncoding],
								   @"Proprietary", nil];
	NSNumber	*numStringEncoding	= nil;
	return ((numStringEncoding = [g_StringEncodingMapping objectForKey:strEncoding])
			? [numStringEncoding intValue]
			: NSUTF8StringEncoding);
}




