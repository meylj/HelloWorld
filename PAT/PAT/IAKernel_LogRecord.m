#import "IAKernel_LogRecord.h"



@implementation IAKernel (IAKernel_LogRecord)



#pragma mark - Create 
-(BOOL)createLogFilesAndReportIfError:(NSError**)error
{
	NSFileManager	*fm	= [NSFileManager defaultManager];
	[fm createDirectoryAtPath:m_strLogPath 
  withIntermediateDirectories:YES 
				   attributes:nil 
						error:nil];
	for(IAKERNEL_LOGTYPE iType=0; iType<3; iType++)
		[fm createFileAtPath:[self createLogPath:iType] 
					contents:[NSData data] 
				  attributes:nil];
	for(IAKERNEL_LOGTYPE iType=0; iType<3; iType++)
		if(![fm fileExistsAtPath:[self createLogPath:iType] isDirectory:NO])
		{
			if(NULL != error)
				*error	= [NSError errorWithDomain:[NSString stringWithFormat:@"Create file [%@] failed. ", 
													[self createLogPath:iType]] 
											 code:__LINE__ 
										 userInfo:nil];
			return NO;
		}
	return YES;
}

-(NSString*)createLogPath:(IAKERNEL_LOGTYPE)iType
{
	switch(iType)
	{
		case IAKERNEL_DEVICE:
			return [NSString stringWithFormat:@"%@/Device.txt", m_strLogPath];
		case IAKERNEL_PROGRESS:
			return [NSString stringWithFormat:@"%@/Progress.txt", m_strLogPath];
		case IAKERNEL_RESULT:
			return [NSString stringWithFormat:@"%@/Result.csv", m_strLogPath];
		default:
			return [NSString stringWithFormat:@"%@/Default.txt", m_strLogPath];
	}
}

-(NSString*)makeLogFromResult:(Bean_Result*)result
{
	NSMutableString	*strLog	= [NSMutableString string];
	[strLog appendString:[result.ItemName stringByReplacingOccurrencesOfString:@"," 
																	withString:@"\",\""]];
	[strLog appendString:@","];
	[strLog appendString:[(result.Result 
						   ? @"PASS" 
						   : @"FAIL") stringByReplacingOccurrencesOfString:@"," 
						  withString:@"\",\""]];
	[strLog appendString:@","];
	[strLog appendString:[result.Limits stringByReplacingOccurrencesOfString:@"," 
																  withString:@"\",\""]];
	[strLog appendString:@","];
	// Append values. 
	NSString	*strValue	= [result.Value description];
	if([strValue contains:@"\r\n"])
		strValue	= [strValue stringByReplacingOccurrencesOfString:@"\r\n" 
													   withString:@" "];
	else if([strValue contains:@"\r"])
		strValue	= [strValue stringByReplacingOccurrencesOfString:@"\r" 
													   withString:@" "];
	else if([strValue contains:@"\n"])
		strValue	= [strValue stringByReplacingOccurrencesOfString:@"\n" 
													   withString:@" "];
	[strLog appendString:[strValue stringByReplacingOccurrencesOfString:@"," 
															 withString:@"\",\""]];
	[strLog appendString:@"\n"];
	return [strLog description];
}

-(BOOL)saveLog:(NSString*)strLog 
		  type:(IAKERNEL_LOGTYPE)iType 
		 error:(NSError**)error
{
	NSFileHandle	*f	= [NSFileHandle fileHandleForWritingAtPath:[self createLogPath:iType]];
	if(!f)
	{
		if(NULL != error)
			*error	= [NSError errorWithDomain:[NSString stringWithFormat:@"Can not write file [%@]. ", 
												[self createLogPath:iType]] 
										 code:__LINE__ 
									 userInfo:nil];
		return NO;
	}
	[f seekToEndOfFile];
	[f writeData:[NSData dataWithBytes:[strLog UTF8String] 
								length:[strLog length]]];
	[f synchronizeFile];
	[f closeFile];
	return YES;
}



@end


