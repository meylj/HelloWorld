//
//  AppDelegate.m
//  CheckCableMapping
//
//  Created by Lorky on 7/13/13.
//  Copyright (c) 2013 Lorky. All rights reserved.
//

#import "AppDelegate.h"
#import "PEGA_ATS_UART/SearchSerialPorts.h"
#import "NSString+APIs.h"

@implementation AppDelegate

- (id)init
{
	if (self = [super init])
	{
		aryRequiredTargets	= [NSMutableArray new];
		strDebugInfo		= [NSMutableString new];
		aryTableViewDataSource = [NSMutableArray new];
		
		
		NSString * strBundlePath = [[NSBundle mainBundle] bundlePath];
		dictCableMapping = [[NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Resources/CableMapping.plist",strBundlePath]] retain];
		
		for (NSString * strTarget in [[dictCableMapping objectForKey:@"DeviceSetting"] allKeys])
		{
			if ([[[[dictCableMapping objectForKey:@"DeviceSetting"] objectForKey:strTarget] objectForKey:@"ENABLE"] boolValue])
			{
				[aryRequiredTargets addObject:strTarget];
			}
		}
		[aryRequiredTargets retain];
	}
	return self;
}

- (void)dealloc
{
	[aryRequiredTargets		release];
	[strDebugInfo			release];
	[aryTableViewDataSource release];
    [super dealloc];
}

- (void)awakeFromNib
{
	// search all serial ports and list on UI.
	[self listSerialPorts:aryTableViewDataSource];
	
	if ([aryTableViewDataSource count])
	{
		aryTableViewDataSource = [[aryTableViewDataSource sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] copy];
		[tbCables reloadData];
	}
	
	NSString * strFixturePrefix = [[[dictCableMapping objectForKey:@"DeviceSetting"] objectForKey:@"FIXTURE"] objectForKey:@"CABLE_PREFIX"];
	
	// Initialize popup button
	NSMutableArray * aryFixtureCount = [NSMutableArray new];
	for (NSString * strCable in aryTableViewDataSource)
	{
		if ([strCable contains:strFixturePrefix])
			[aryFixtureCount addObject:strCable];
	}
	if ([aryFixtureCount count])
	{
		[fixtureSelected removeAllItems];
		for (NSString * strCable in aryFixtureCount)
		{
			NSString * index = [strCable divideFrom:strFixturePrefix include:NO];
			[fixtureSelected insertItemWithTitle:index atIndex:0];
		}
	}
	else
	{
		NSRunAlertPanel(@"FATAL ERROR", @"Can't find any fixture cables", @"OK", nil, nil);
		[NSApp terminate:self];
	}
	
	[aryFixtureCount release];
	[labResult setStringValue:@"Ready"];
	[myWindow setBackgroundColor:[NSColor blueColor]];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	
}

- (IBAction)DoMapping:(id)sender
{
	BOOL bResult = YES;
	//BOOL bTried	= NO;
	int iTriedCount	= 0;
	NSString * strDate	= [[NSDate date] descriptionWithCalendarFormat:@"%Y-%m-%d-%H-%M-%S" timeZone:nil locale:nil];

	for (NSString * strTarget in aryRequiredTargets)
	{
		NSDictionary * dictTarget	= [[dictCableMapping objectForKey:@"DeviceSetting"] objectForKey:strTarget];
		// Popup a alert window to reminder user
		NSString * strMessage		= [dictTarget objectForKey:@"MESSAGE"];
		NSString * strFormatMessage = [NSString stringWithFormat:@"%@ [%d]",strMessage, [[[fixtureSelected selectedItem] title] integerValue]];
		NSString * strTargetDetail	= [NSString stringWithFormat:@"%@%d",strTarget,[[[fixtureSelected selectedItem] title] integerValue]];
		
		if (strMessage != nil)
		{
			NSRunAlertPanel(@"Reminder", strFormatMessage, @"OK", nil, nil);
			[self PrintoutDebugMessage:strFormatMessage Target:strTargetDetail Date:strDate];
		}
		// Open target
		PEGA_ATS_UART * aUartObj	= [[PEGA_ATS_UART alloc] init_Uart];
		NSString * strPortPath		= @"";
		for (NSString * strCable in aryTableViewDataSource)
		{
			NSString * strIndex		= [[fixtureSelected selectedItem] title];
			NSString * strPrefix	= [dictTarget objectForKey:@"CABLE_PREFIX"];
			
			if ([strCable contains:strPrefix] && [strCable contains:strIndex])
				strPortPath = strCable;
		}
		if ([strPortPath isNotEqualTo:@""])
		{
			NSString * strEndSymbol = [dictTarget objectForKey:@"ENDFLAG"];
			NSString * strParity	= [dictTarget objectForKey:@"PARITY"];
			int iBaudeRate	= [[dictTarget objectForKey:@"BAUDE_RATE"] integerValue];
			int iDataBit	= [[dictTarget objectForKey:@"DATA_BIT"] integerValue];
			int iStopBit	= [[dictTarget objectForKey:@"STOP_BIT"] integerValue];

			UInt16 iReturn = [aUartObj openPort:strPortPath
									  baudeRate:iBaudeRate
										dataBit:iDataBit
										 parity:strParity
									   stopBits:iStopBit
									  endSymbol:strEndSymbol];
			
			if (iReturn == kUart_SUCCESS)
			{
				int iMath	= [[dictTarget objectForKey:@"MATCH_TYPE"] integerValue];
				NSString	* strTry	= [dictTarget objectForKey:@"TRY"];
				NSArray		* aryExpect = [dictTarget objectForKey:@"EXPECT"];
				// Try
				NSMutableString * strDataRet	= [[NSMutableString alloc] init];
				[aUartObj Clear_UartBuff:kUart_ClearInterval
								 TimeOut:kUart_CommandTimeOut
								 readOut:nil];
				[aUartObj Write_UartCommand:strTry
								  PackedNum:0
								   Interval:1000
									  IsHex:NO];
				UInt16 iReturn = [aUartObj Read_UartData:strDataRet
										 TerminateSymbol:aryExpect
											   MatchType:iMath
											IntervalTime:kUart_IntervalTime
												 TimeOut:kUart_CommandTimeOut];
				[self PrintoutDebugMessage:strDataRet Target:strTargetDetail Date:strDate];
				[strDataRet release];
				strDataRet = nil;
				iTriedCount++;
				bResult &= ~iReturn;
				if (!(~iReturn))
					[self PrintoutDebugMessage:[NSString stringWithFormat:@"Can't communicate with %@", strTargetDetail]
										Target:strTargetDetail Date:strDate];
				else
					[self PrintoutDebugMessage:[NSString stringWithFormat:@"Tried %@ OK", strTargetDetail]
										Target:strTargetDetail Date:strDate];
				// Close Target
				[aUartObj Close_Uart];
			}
			else
			{
				strMessage = [NSString stringWithFormat:@"Open %@ fail, please check the connection of %@",strTarget,strTarget];
				NSRunAlertPanel(@"Error", strMessage, @"OK", nil, nil);
				[self PrintoutDebugMessage:strMessage Target:strTargetDetail Date:strDate];
			}
		}
		[aUartObj release]; aUartObj = nil;
	}
	
	if (iTriedCount != [aryRequiredTargets count])
	{
		NSString * strMessage = [NSString stringWithFormat:@"Need test %d device(s), but tried %d OK",[aryRequiredTargets count],iTriedCount];
		
		[self PrintoutDebugMessage:strMessage Target:@"ALL" Date:strDate];
	}
	
	[labResult setStringValue:((bResult && (iTriedCount == [aryRequiredTargets count])) ? @"Mapped" : @"UnMapping")];
	NSColor * color = (bResult && (iTriedCount == [aryRequiredTargets count])) ? [NSColor greenColor] : [NSColor redColor];
	[myWindow setBackgroundColor:color];
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return YES;
}

-(void)listSerialPorts:(NSMutableArray *)aryPorts
{
    SearchSerialPorts	*aObject	= [[SearchSerialPorts alloc] init];
	[aObject SearchSerialPorts:aryPorts];
	[aObject release];
}

- (void)PrintoutDebugMessage:(NSString *)strInformation Target:(NSString *)strTarget Date:(NSString *)strDate
{
	NSString * strInfo = [NSString stringWithFormat:@"[%@] (%@): %@\n",strDate,strTarget,strInformation];
	[textDebugInfo insertText:strInfo];
	// write debug logs
	[self CreatAndWriteUARTLog:strInformation
						atTime:strDate
					fromDevice:strTarget
					  withPath:[NSString  stringWithFormat:@"/vault/CableMapping/%@.txt",strDate]
						binary:NO];
}

- (void)CreatAndWriteUARTLog:(NSString *)szInfo
					  atTime:(NSString *)szTime
				  fromDevice:(NSString *)szDevice
					withPath:(NSString *)szPath
					  binary:(BOOL)bBinarySave
{
    NSString		*szDirectory	= [szPath stringByDeletingLastPathComponent];
    NSFileManager	*fileManager	= [NSFileManager defaultManager];
	NSError			*myError		= nil;
    if (![fileManager fileExistsAtPath:szDirectory])
        [fileManager createDirectoryAtPath:szDirectory
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&myError];
    NSString		*szCombinedInfo	= @"";
    if (!szTime || !szDevice)
        szCombinedInfo	= [NSString stringWithFormat:@"%@\n",szInfo];
    else
        szCombinedInfo	= [NSString stringWithFormat:@"[%@](%@):%@\n",
                           szTime,szDevice,szInfo];
    NSFileHandle	*h_UARTLog		= [NSFileHandle fileHandleForWritingAtPath:szPath];
    if (!h_UARTLog)
        [szCombinedInfo writeToFile:szPath
                         atomically:NO
                           encoding:NSUTF8StringEncoding
                              error:nil];
    else
    {
        NSData	*dataTemp	= [[NSData alloc] initWithBytes:(void *)[szCombinedInfo UTF8String]
                                                  length:[szCombinedInfo length]];
        [h_UARTLog seekToEndOfFile];
        [h_UARTLog writeData:dataTemp];
        [dataTemp release];
    }
    if (bBinarySave)
    {
        if (!h_UARTLog)
            h_UARTLog	= [NSFileHandle fileHandleForWritingAtPath:szPath];
        NSMutableString	*szHEXValue	= [[NSMutableString alloc] initWithFormat:
                                       @"[%@](%@):",szTime,szDevice];
        const char		*cHexBuffer	= [szInfo cStringUsingEncoding:NSASCIIStringEncoding];
        for (int i = 0; i < strlen(cHexBuffer); i++)
        {
            int			iHexReceive	= cHexBuffer[i];
            NSString	*szTemp		= [NSString stringWithFormat:@"[0x%x]:",iHexReceive];
            [szHEXValue appendFormat:@"%@",szTemp];
        }
        [szHEXValue appendFormat:@"\n"];
        NSData	*dataHexTemp	= [[NSData alloc] initWithBytes:(void *)[szHEXValue UTF8String]
                                                     length:[szHEXValue length]];
        [h_UARTLog writeData:dataHexTemp];
        [dataHexTemp release];
        [szHEXValue release];
    }
    [h_UARTLog closeFile];
    
}

#pragma mark -
#pragma mark ***** Required Methods (unless bindings are used) *****

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [aryTableViewDataSource count];
}

/* This method is required for the "Cell Based" TableView, and is optional for the "View Based" TableView. If implemented in the latter case, the value will be set to the view at a given row/column if the view responds to -setObjectValue: (such as NSControl and NSTableCellView).
 */
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	return [[aryTableViewDataSource objectAtIndex:row] divideFrom:@"/dev/cu.usbserial-" include:NO];
}

@end
