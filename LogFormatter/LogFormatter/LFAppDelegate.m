//
//  LFAppDelegate.m
//  LogFormatter
//
//  Created by Lorky on 5/22/14.
//  Copyright (c) 2014 Lorky. All rights reserved.
//

#import "LFAppDelegate.h"
#import "NSStringCategory.h"

@implementation LFAppDelegate
@synthesize logInfo;
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	self.logInfo = @"Initlize OK";
	[progIndicator setHidden:YES];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return YES;
}

- (IBAction)FormatLog:(id)sender
{
	NSString * strFilePath = [_logPath stringValue];
	// Choose a wrong format file.
	if ([[strFilePath pathExtension] isNotEqualTo:@"txt"])
	{
		NSRunAlertPanel(@"Error", @"Please choose .txt file", @"OK", nil, nil);
		[_logPath setStringValue:@""];
		return;
	}
	
	if (date)
	{
		[date release]; date = nil;
	}
	date = [[NSDate date] retain];
	[progIndicator setHidden:NO];
	[progIndicator startAnimation:nil];
	
	NSString * strContent = [NSString stringWithContentsOfFile:strFilePath encoding:NSASCIIStringEncoding error:nil];
	if ([strContent contains:@"PEGATRON ATS"] && [strFilePath contains:@"Uart"])
	{
		self.logInfo = [NSString stringWithFormat:@"Pasering %@",strFilePath];
		[self writeLog:strContent forVendor:@"PEGA"];
	}
	else
	{
		self.logInfo = [NSString stringWithFormat:@"Pasering %@",strFilePath];
		[self writeLog:strContent forVendor:@"Foxconn"];
	}
	if (NSOKButton == NSRunAlertPanel(@"Reminder", @"Would you like to open the folder?", @"Yes", @"No, thanks", nil))
	{
		[[NSWorkspace sharedWorkspace] openFile:[NSString stringWithFormat:@"%@/Desktop/LogFormatter",NSHomeDirectory()]];
	}
	self.logInfo = @"Completed log parsing!";
	[progIndicator stopAnimation:nil];
	[progIndicator setHidden:YES];
}

- (IBAction)CoupleFormatterLogs:(id)sender
{
	[progIndicator setHidden:NO];
	[progIndicator startAnimation:nil];

	@autoreleasepool
	{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setTitle:@"Choose a folder which contains pasering logs"];
	[openPanel setCanCreateDirectories:YES];
	[openPanel setCanChooseDirectories:YES];
	if (NSOKButton == [openPanel runModal])
	{
		if (date)
		{
			[date release]; date = nil;
		}
		date = [[NSDate date] retain];
		NSArray * arrayAllUrls = [openPanel URLs];
		[NSThread detachNewThreadSelector:@selector(createTemplateLogs:) toTarget:self withObject:arrayAllUrls];
	}
	}
}

- (IBAction)helpSend:(id)sender
{
	[[NSWorkspace sharedWorkspace] openFile:[[NSBundle mainBundle] pathForResource:@"ReadMe"
																			ofType:@"rtf"]];
}

- (void)createTemplateLogs:(NSArray *)arrayUrls
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	for (NSURL *url  in arrayUrls)
	{
		NSString * strFilePath = [url absoluteString];
		
		// Check the selected file path extension is 'txt'
		if ([[strFilePath pathExtension] isEqualTo:@"txt"])
		{
			NSString * strContent = [NSString stringWithContentsOfFile:strFilePath
															  encoding:NSASCIIStringEncoding
																 error:nil];
			if ([strContent contains:@"PEGATRON ATS"] && [strFilePath contains:@"Uart"])
			{
				self.logInfo = [NSString stringWithFormat:@"Pasering %@",strFilePath];
				[self writeLog:strContent forVendor:@"PEGA"];
			}
			else
			{
				self.logInfo = [NSString stringWithFormat:@"Pasering %@",strFilePath];
				[self writeLog:strContent forVendor:@"Foxconn"];
			}
			continue;
		}
		
		// Enumerate all files in the selected folder.
		NSFileManager *fileMan = [NSFileManager defaultManager];
		NSDirectoryEnumerator *dirEnum = [fileMan enumeratorAtURL:url
									   includingPropertiesForKeys:[NSArray array]
														  options:0
													 errorHandler:nil];
		
		while (strFilePath = [dirEnum nextObject])
		{
			if ([[strFilePath pathExtension] isEqualTo:@"txt"])
			{
				NSString * strContent = [NSString stringWithContentsOfFile:strFilePath
																  encoding:NSASCIIStringEncoding
																	 error:nil];
				if ([strContent contains:@"PEGATRON ATS"] && [[(NSURL*)strFilePath absoluteString] contains:@"Uart"])
				{
					self.logInfo = [NSString stringWithFormat:@"Pasering %@",strFilePath];
					[self writeLog:strContent forVendor:@"PEGA"];
				}
				else
				{
					self.logInfo = [NSString stringWithFormat:@"Pasering %@",strFilePath];
					[self writeLog:strContent forVendor:@"Foxconn"];
				}
			}
		}
		self.logInfo = @"Completed log parsing!";
		
		if (NSOKButton == NSRunAlertPanel(@"Reminder", @"Would you like to open the folder?", @"Yes", @"No, thanks", nil))
		{
			[[NSWorkspace sharedWorkspace] openFile:[NSString stringWithFormat:@"%@/Desktop/LogFormatter",NSHomeDirectory()]];
		}
		
	}
	
	[progIndicator stopAnimation:nil];
	[progIndicator setHidden:YES];
	[pool drain];
}

- (BOOL)writeLog:(NSString *)strContent forVendor:(NSString *)strVendor
{
	NSArray * arrContent		= [strContent componentsSeparatedByString:@"\n"];
	NSString * strVersion		= nil;
	NSString * strStation		= nil;
	NSString * strVerRegex		= [strVendor isEqualTo:@"PEGA"] ? @"Overlay_Version : (.*)" : @"Version: (.*)";
	NSString * strStationRegex	= [strVendor isEqualTo:@"PEGA"] ? @"STATION:.*_.*-.*-.*_.*_(.*)" : @"Station: (.*)";
	
	//for (NSString * str in arrContent)
	for (NSUInteger i = 0; i < [arrContent count]; i++)
	{
		NSString * str = [arrContent objectAtIndex:i];
		if (!strVersion)
			strVersion = [str subByRegex:strVerRegex name:nil error:nil];
		if (!strStation)
			strStation = [str subByRegex:strStationRegex name:nil error:nil];
		if (strVersion && strStation)
		{
			NSString * strFilePath = [NSString stringWithFormat:@"%@/Desktop/LogFormatter/%@/%@_%@_%@_%@.txt",
									  NSHomeDirectory(),[strVendor trim],
									  [strVendor trim],[strStation trim],
									  [strVersion trim],[date descriptionWithCalendarFormat:@"%H%M%S-%F"
																				   timeZone:nil
																					 locale:nil]];
			if ([str contains:@" Start Test: "] && i < [arrContent count] - 1) // For Foxconn log, next string will be the test item name and spec.
			{
				if ([btnKeepNameLimit state] == NSOnState)
					[self formatlogWithInformation:[NSString stringWithFormat:@"[ItemName , Limit]: %@",[arrContent objectAtIndex:i+1]] toLogPath:strFilePath];
			}
			if ([self strWriteString:str])
				[self formatlogWithInformation:[self strWriteString:str] toLogPath:strFilePath];
		}
	}
	return YES;
}

- (NSString *)strWriteString:(NSString *)strContent
{
	NSString * strReturn = nil;
	// For PEGA item Name
	if ((strReturn = [strContent subByRegex:@"Item Name:(.*)" name:nil error:nil]))
	{
		if ([btnKeepNameLimit state] == NSOnState)
		{
			// Format the limit, keep the same with Foxconn.
			NSMutableString *strTemp = [NSMutableString stringWithString:strReturn];
			NSMutableString *strTemp1 = [NSMutableString stringWithString:[strTemp stringByReplacingOccurrencesOfString:@", {NA}" withString:@""]];
			NSMutableString *strTemp2 = [NSMutableString stringWithString:[strTemp1 stringByReplacingOccurrencesOfString:@"[," withString:@"[N/A,"]];
			NSMutableString *strTemp3 = [NSMutableString stringWithString:[strTemp2 stringByReplacingOccurrencesOfString:@",]" withString:@",N/A]"]];
			NSMutableString *strTemp4 = [NSMutableString stringWithString:[strTemp3 stringByReplacingOccurrencesOfString:@"<" withString:@"*"]];
			NSMutableString *strTemp5 = [NSMutableString stringWithString:[strTemp4 stringByReplacingOccurrencesOfString:@">" withString:@"*"]];
			NSMutableString *strTemp6 = [NSMutableString stringWithString:[strTemp5 stringByReplacingOccurrencesOfString:@"{" withString:@"*"]];
			NSMutableString *strTemp7 = [NSMutableString stringWithString:[strTemp6 stringByReplacingOccurrencesOfString:@"}" withString:@"*"]];
			
			return [NSString stringWithFormat:@"[ItemName , Limit]: %@",strTemp7];
		}
		else
			return nil;
	}
	// For Device and Command
	else if ([strContent contains:@"(TX ==> "] || [strContent contains:@"Write --> "])
	{
		NSString * strDeviceType = nil;
		NSString * strCommand = nil;
		if ([strContent contains:@"(TX ==> "])
		{
			strDeviceType = [strContent subByRegex:@"\\(TX ==> \\[(.*)\\]\\):.*" name:nil error:nil];
			strCommand = [strContent subByRegex:@"\\(TX ==> \\[.*\\]\\):(.*)" name:nil error:nil];
		}
		else if ([strContent contains:@"Write --> "])
		{
			strDeviceType = [strContent subByRegex:@"Write --> (.*) , .*" name:nil error:nil];
			strCommand = [strContent subByRegex:@"Write --> .* , (.*)" name:nil error:nil];
			if ([strDeviceType isEqualTo:@"DUT"])
			{
				strDeviceType = @"MOBILE";
			}
		}
		
		if (0 == [mobileOnly selectedColumn])
		{
			if ([strDeviceType isNotEqualTo:@"MOBILE"]) {
				return nil;
			}
		}
		
		return [NSString stringWithFormat:@"[%@] %@",[strDeviceType uppercaseString],strCommand];
	}

	return nil;
}

- (void)formatlogWithInformation:(NSString *)szInfo toLogPath:(NSString *)szPath
{
	szInfo	= [NSString stringWithFormat:@"%@\n",szInfo];
	NSString		*szDirectory	= [szPath stringByDeletingLastPathComponent];
	NSFileManager	*fileManager	= [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:szDirectory])
		[fileManager createDirectoryAtPath:szDirectory
			   withIntermediateDirectories:YES
								attributes:nil
									 error:nil];
	NSFileHandle	*h_ConsoleLog	= [NSFileHandle fileHandleForWritingAtPath:szPath];
	if (!h_ConsoleLog)
		[szInfo writeToFile:szPath
				 atomically:NO
				   encoding:NSUTF8StringEncoding
					  error:nil];
	else
	{
		NSData	*dataTemp	= [[NSData alloc] initWithBytes:(void *)[szInfo UTF8String]
												  length:[szInfo length]];
		[h_ConsoleLog seekToEndOfFile];
		[h_ConsoleLog writeData:dataTemp];
		[dataTemp release];
		[h_ConsoleLog closeFile];
	}
}

@end
