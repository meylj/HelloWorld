#import "IAKernel.h"



@implementation IAKernel



#pragma mark - NSObject Override 
- (id)init
{
    self = [super init];
    if (self) 
	{
		m_dictIndelibleMemory	= [[NSDictionary alloc] init];
		m_dictMemory	= [[NSMutableDictionary alloc] init];
		m_dictDevices	= [[NSMutableDictionary alloc] init];
		m_strLogPath	= [[NSString alloc] init];
		m_aryIOProcess	= [[NSMutableArray alloc] init];
		m_aryCalProcess	= [[NSMutableArray alloc] init];
		m_dictIOResult	= [[NSMutableDictionary alloc] init];
		m_aryProcessed	= [[NSMutableArray alloc] init];
		m_status		= IAKERNEL_IDLE;
    }
    return self;
}

-(void)dealloc
{
	[m_aryProcessed release];		m_aryProcessed	= nil;
	[m_dictIOResult release];		m_dictIOResult	= nil;
	[m_aryCalProcess release];		m_aryCalProcess	= nil;
	[m_aryIOProcess release];		m_aryIOProcess	= nil;
	[m_strLogPath release];			m_strLogPath	= nil;
	[m_dictDevices release];		m_dictDevices	= nil;
	[m_dictMemory release];			m_dictMemory	= nil;
	[m_dictIndelibleMemory release];	m_dictIndelibleMemory	= nil;
	[super dealloc];
}



#pragma mark - Set Up 
-(BOOL)setUpCalProcess:(NSDictionary*)dictCalProcess
{
	@synchronized(m_aryCalProcess)
	{
		[m_aryCalProcess removeAllObjects];
		NSArray	*aryItemNames	= [dictCalProcess allKeys];
		aryItemNames	= [aryItemNames sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
		for(NSString *strItemName in aryItemNames)
		{
			NSDictionary	*dictItemContents	= [dictCalProcess objectForKey:strItemName];
			NSArray		*arySubItemNames	= [dictItemContents allKeys];
			arySubItemNames	= [arySubItemNames sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
			NSMutableArray	*arySubItems	= [NSMutableArray array];
			for(NSString *strSubItemName in arySubItemNames)
			{
				NSDictionary	*dictSublItem	= [NSDictionary dictionaryWithObject:
												   [dictItemContents objectForKey:[strSubItemName trim]] 
																		 forKey:[strSubItemName trim]];
				[arySubItems addObject:dictSublItem];
			}
			NSDictionary	*dictItem	= [NSDictionary dictionaryWithObject:arySubItems 
																 forKey:[strItemName trim]];
			[m_aryCalProcess addObject:dictItem];
		}
	}
	return YES;
}

-(BOOL)setUpIOProcess:(NSDictionary*)dictIOProcess
{
	@synchronized(m_aryIOProcess)
	{
		[m_aryIOProcess removeAllObjects];
		NSArray	*aryItemNames	= [dictIOProcess allKeys];
		aryItemNames	= [aryItemNames sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
		for(NSString *strItemName in aryItemNames)
		{
			NSDictionary	*dictItemContents	= [dictIOProcess objectForKey:strItemName];
			NSArray	*arySubItemNames	= [dictItemContents allKeys];
			arySubItemNames	= [arySubItemNames sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
			NSMutableArray	*arySubItems	= [NSMutableArray array];
			for(NSString *strSubItemName in arySubItemNames)
			{
				NSDictionary	*dictSublItem	= [NSDictionary dictionaryWithObject:
												   [dictItemContents objectForKey:[strSubItemName trim]] 
																		 forKey:[strSubItemName trim]];
				[arySubItems addObject:dictSublItem];
			}
			NSDictionary	*dictItem	= [NSDictionary dictionaryWithObject:arySubItems 
																 forKey:[strItemName trim]];
			[m_aryIOProcess addObject:dictItem];
		}
	}
	return YES;
}

@synthesize IndelibleMemory	= m_dictIndelibleMemory;

-(BOOL)setUpDevice:(IADevice*)device 
		targetName:(NSString*)strName
{
	@synchronized(m_dictDevices)
	{
		[m_dictDevices setObject:device forKey:strName];
	}
	return YES;
}

@synthesize LogPath	= m_strLogPath;
-(void)setLogPath:(NSString *)LogPath
{
	[m_strLogPath release];	m_strLogPath	= nil;
	m_strLogPath	= [LogPath retain];
	[self createLogFilesAndReportIfError:nil];
}



#pragma mark - Clean For Next 
// Hided method, for -(void)clear. 
-(BOOL)needWait:(NSString*)strItemName
{
	for(NSDictionary *dictIOItem in m_aryIOProcess)
	{
		NSString	*strIOItemName	= [[dictIOItem allKeys] objectAtIndex:0];
		if([strIOItemName isEqualToString:strItemName])
			return YES;
	}
	return NO;
}
-(void)clear
{
	@synchronized(m_dictMemory)
	{
		[m_dictMemory removeAllObjects];
		[m_dictMemory addEntriesFromDictionary:m_dictIndelibleMemory];
	}
	@synchronized(m_dictIOResult)
	{
		[m_dictIOResult removeAllObjects];
		for(NSDictionary *dictCalItem in m_aryCalProcess)
		{
			NSString	*strItemName	= [[dictCalItem allKeys] objectAtIndex:0];
			if(![self needWait:strItemName])
				[m_dictIOResult setObject:[NSNumber numberWithBool:YES] forKey:strItemName];
		}
	}
	@synchronized(m_aryProcessed)
	{
		[m_aryProcessed removeAllObjects];
	}
	
	[m_threadCal release];	m_threadCal	= nil;
	m_threadCal	= [[NSThread alloc] initWithTarget:self 
										  selector:@selector(threadCalProcess) 
											object:nil];
	[m_threadIO release];	m_threadIO	= nil;
	m_threadIO	= [[NSThread alloc] initWithTarget:self 
										 selector:@selector(threadIOProcess) 
										   object:nil];
}



#pragma mark - Main Process 
-(BOOL)waitIOResult:(NSString*)strItemName
{
	while(1)
	{
		if([[NSThread currentThread] isCancelled])
			return NO;
		NSNumber	*numResult	= [m_dictIOResult objectForKey:strItemName];
		if(numResult)
			return [numResult boolValue];
		usleep(100000);
	}
}

-(void)setIO:(NSString*)strItemName 
	  result:(BOOL)bResult\
{
	@synchronized(m_dictIOResult)
	{
		[m_dictIOResult setObject:[NSNumber numberWithBool:bResult] 
						   forKey:strItemName];
	}
}

-(void)threadCalProcess
{
	NSAutoreleasePool	*pool	= [[NSAutoreleasePool alloc] init];
	id			idLastResult	= nil;
	BOOL		bFinalResult	= YES;
	
	for(NSUInteger i=0; i<[m_aryCalProcess count]; i++)
	{
		// Get the test item. 
		NSDictionary	*dictItem	= [m_aryCalProcess objectAtIndex:i];
		Bean_Result		*result		= [[Bean_Result alloc] init];
		result.Index	= i;
		result.ItemName	= [[dictItem allKeys] objectAtIndex:0];
		// Abort? 
		if([[NSThread currentThread] isCancelled])
		{
			result.Value	= @"Canceled. ";
			result.Result	&= NO;
			bFinalResult	&= NO;
			[self showResultOnUI:result];
			[self saveLog:[self makeLogFromResult:result] 
					 type:IAKERNEL_RESULT 
					error:nil];
			[result release];	result	= nil;
			continue;
		}
		// Wait IO. 
		if(!(result.Result = [self waitIOResult:result.ItemName]))
		{
			result.Value	= @"IO error. ";
			result.Result	&= NO;
			bFinalResult	&= NO;
			[self showResultOnUI:result];
			[self saveLog:[self makeLogFromResult:result] 
					 type:IAKERNEL_RESULT 
					error:nil];
			[result release];	result	= nil;
			continue;
		}
		// Test sub items. 
		BOOL	bShowUI	= YES;	// Each item should be showed once and only once. 
		BOOL	bSave	= YES;	// Each item should be saved once and only once. 
		for(NSDictionary *dictSubItem in [dictItem objectForKey:result.ItemName])
		{
			// Abort? 
			if([[NSThread currentThread] isCancelled])
			{
				result.Value	= @"Canceled. ";
				result.Result	&= NO;
				break;
			}
			// Sub item process. 
			NSString		*strSubItem		= [[dictSubItem allKeys] objectAtIndex:0];
			NSDictionary	*dictContents	= [dictSubItem objectForKey:strSubItem];
			NSString	*strFunction	= [NSString stringWithFormat:@"%@:RESULT:", 
										   [strSubItem subFrom:@"." include:NO]];
			SEL	sel	= NSSelectorFromString(strFunction);
			if(![self respondsToSelector:sel])
			{
				result.Result	&= NO;
				continue;
			}
			result.Result	&= (BOOL)[self performSelector:sel 
											  withObject:dictContents 
											  withObject:&idLastResult];
			result.Value	= idLastResult;
			// Show result? 
			if([[dictContents objectForKey:@"SHOW"] isKindOfClass:[NSNumber class]]
			   && [[dictContents objectForKey:@"SAVE"] boolValue])
			{
				[self showResultOnUI:result];
				bShowUI	&= NO;
			}
			// Save result? 
			if([[dictContents objectForKey:@"SAVE"] isKindOfClass:[NSNumber class]]
			   && [[dictContents objectForKey:@"SAVE"] boolValue])
			{
				[self saveLog:[self makeLogFromResult:result] 
						 type:IAKERNEL_RESULT 
						error:nil];
				bSave	&= NO;
			}
			// Memory? 
			if([[dictContents objectForKey:@"MEMORY"] isKindOfClass:[NSString class]])
				[self memory:result.Value withKey:[dictContents objectForKey:@"MEMORY"]];
			// Jump? 
			// Fail break? 
			if(!result.Result && self.FailBreak)
			{
				i	= [m_aryCalProcess count] - 1;
				break;
			}
		}
		// Over. Show if not showed before, save if not saved before. 
		bFinalResult	&= result.Result;
		if(bShowUI)
			[self showResultOnUI:result];
		if(bSave)
			[self saveLog:[self makeLogFromResult:result] 
					 type:IAKERNEL_RESULT 
					error:nil];
		[result release];	result	= nil;
	}
	
	[self sendNoteKernelDone:bFinalResult];
	[pool drain];
}

-(void)threadIOProcess
{
	NSAutoreleasePool	*pool	= [[NSAutoreleasePool alloc] init];
	id		idLastResult		= nil;
	
	for(NSUInteger i=0; i<[m_aryIOProcess count]; i++)
	{
		// Get the test item. 
		NSDictionary	*dictItem	= [m_aryIOProcess objectAtIndex:i];
		NSString		*strItem	= [[dictItem allKeys] objectAtIndex:0];
		BOOL			bResult		= YES;
		// Run sub test items. 
		for(NSUInteger j=0; j<[[dictItem objectForKey:strItem] count]; j++)
		{
			// Abort? 
			if([[NSThread currentThread] isCancelled])
			{
				i	= [m_aryIOProcess count] - 1;
				break;
			}
			// Get the sub test item. 
			NSDictionary	*dictSubItem	= [[dictItem objectForKey:strItem] objectAtIndex:j];
			NSString		*strSubItem		= [[dictSubItem allKeys] objectAtIndex:0];
			NSDictionary	*dictContents	= [dictSubItem objectForKey:strSubItem];
			// Get the selector. 
			NSString	*strFunction	= [NSString stringWithFormat:@"%@:RESULT:", 
										   [strSubItem subFrom:@"." include:NO]];
			SEL	sel	= NSSelectorFromString(strFunction);
			id	idTarget	= ([[dictContents objectForKey:@"TARGET"] isKindOfClass:[NSString class]] 
							   ? ([[m_dictDevices objectForKey:[dictContents objectForKey:@"TARGET"]] 
								   isKindOfClass:[IADevice class]] 
								  ? [m_dictDevices objectForKey:[dictContents objectForKey:@"TARGET"]] 
								  : nil) 
							   : self);
			if(!idTarget)
			{
				bResult	&= NO;
				continue;
			}
			// Run the function. 
			bResult	&= ([idTarget respondsToSelector:sel] 
						? (BOOL)[idTarget performSelector:sel 
											   withObject:dictContents 
											   withObject:&idLastResult] 
						: NO);
			// Memory? 
			if([[dictContents objectForKey:@"MEMORY"] isKindOfClass:[NSString class]])
				[self memory:idLastResult withKey:[dictContents objectForKey:@"MEMORY"]];
			// Jump? 
			// Fail break? 
			if(!bResult && self.FailBreak)
			{
				i	= [m_aryCalProcess count] - 1;
				break;
			}
		}
		// Tell Cal I have finished. 
		[self setIO:strItem result:bResult];
	}
	
	[pool drain];
}

-(BOOL)startTest
{
	m_status	= IAKERNEL_BUSY;
	[m_threadCal start];
	[m_threadIO start];
	return YES;
}

-(BOOL)autoStart
{
	if((m_threadCal && [m_threadCal isExecuting]) 
	   || (m_threadIO && [m_threadIO isExecuting]) 
	   || IAKERNEL_BUSY == self.Status)
		return NO;
	[self clear];
	[self startTest];
	return YES;
}

-(void)abortTest
{
	[m_threadCal cancel];
	[m_threadIO cancel];
}

-(void)sendNoteKernelDone:(BOOL)bFinalResult
{
	[[NSNotificationCenter defaultCenter] 
	 postNotificationName:noteKernelDone 
	 object:self 
	 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
			   [NSNumber numberWithUnsignedInteger:self.tag],	@"TAG",
			   (bFinalResult ? [NSColor greenColor] : [NSColor redColor]),	@"RESULT", nil]];
}



#pragma mark - Basic Informations 
-(NSUInteger)Count
{
	return [m_aryCalProcess count];
}
@synthesize Status		= m_status;
@synthesize tag;
-(BOOL)AutoStart
{
	return (m_timerAutoStart 
			&& [m_timerAutoStart isValid]);
}
-(void)setAutoStart:(BOOL)AutoStart
{
	if(AutoStart)
	{
		if(m_timerAutoStart && [m_timerAutoStart isValid])
			return;	// Still alive. 
		else
		{
			m_timerAutoStart	= [NSTimer scheduledTimerWithTimeInterval:3 
																target:self 
															  selector:@selector(autoStart) 
															  userInfo:nil 
															   repeats:YES];
			[m_timerAutoStart fire];
		}
	}
	else
		if(m_timerAutoStart && [m_timerAutoStart isValid])
			[m_timerAutoStart invalidate];
}
@synthesize FailBreak		= m_bFailBreak;
@synthesize AutoDeleteLogs	= m_bAutoDeleteLogs;



@end


