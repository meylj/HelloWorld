//  IADevice_ButtonTest.m
//  FunnyZone
//
//  Created by Cheng Ming on 2011/10/28.
//  Copyright 2011年 PEGATRON. All rights reserved.



#import "IADevice_ButtonTest.h"



@implementation TestProgress (IADevice_ButtonTest)

//Start 2011.10.28 Add by Ming 
// Descripton:create a thread to read the DUT's key status, until m_bTestButton = NO
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)TEST_BUTTON_THREAD:(NSDictionary*)dicContents
				  RETURN_VALUE:(NSMutableString*)strReturnValue
{
    //steat the button test, BoolTestFlag = yes.
    [m_dicButtonBuffer setObject:[NSNumber numberWithBool:YES]
						  forKey:kIADevice_ButtonTest_BoolTestFlag];
    [NSThread detachNewThreadSelector:@selector(TestButtonFlex:)
							 toTarget:self
						   withObject:dicContents];
    [strReturnValue setString:@"PASS"];
    return [NSNumber numberWithBool:YES];
}
//End 2011.10.28 Add by Ming


//Start 2011.10.28 Add by Ming 
// Descripton:Set the Fixture Ringer's Position, accordance with DUT ringer's Position
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)RINGER_POSITION_SETTING:(NSDictionary*)dicContents
					   RETURN_VALUE:(NSMutableString*)strReturnValue
{
    NSString	*szRinger0	= [m_dicButtonBuffer valueForKey:@"RingerOrigin"];
	NSString	*szValue1	= [dicContents valueForKey:@"COMMANDFIRST"];
	NSString	*szValue2	= [dicContents valueForKey:@"COMMANDSECOND"];
    NSString	*szValue3	= [dicContents valueForKey:@"COMMANDTHIRD"];
    NSString	*szTarget	= [dicContents objectForKey:kFZ_Script_DeviceTarget];
    int			iDelayTime	= [[dicContents valueForKey:@"DELAYTIME"] intValue];
    NSString	*szDeviceTargetTX	= [NSString stringWithFormat:
									   @"TX ==> [%@]", szTarget];
    NSString	*szDeviceTargetRX	= [NSString stringWithFormat:
									   @"RX ==> [%@]", szTarget];
    PEGA_ATS_UART	*uartObj	= [[m_dicPorts objectForKey:szTarget]
								   objectAtIndex:kFZ_SerialInfo_UartObj];
    
	NSMutableString	*strReadData	= [[NSMutableString alloc] init];
    if([szRinger0 intValue] == 1)
    {
        [uartObj Clear_UartBuff:kUart_ClearInterval
						TimeOut:kUart_CommandTimeOut
						readOut:nil];
        [uartObj Write_UartCommand:szValue1
						 PackedNum:1
						  Interval:0
							 IsHex:NO];
        //ATSDebug(@"TX ==> [%@]:%@", szTarget, szValue1);
		[IALogs CreatAndWriteUARTLog:szValue1
							  atTime:kIADeviceALSFileNameDate
						  fromDevice:szDeviceTargetTX
							withPath:[NSString stringWithFormat:@"%@/%@_%@/%@_%@_Uart.txt",kPD_LogPath,m_szPortIndex,m_szStartTime,m_szPortIndex,m_szStartTime]
							  binary:NO];
		
		// Append attribute uart log for debug window in UI
		NSString	*strInformation = [NSString stringWithFormat:@"[%@] (%@) : %@\n",kIADeviceALSFileNameDate,szDeviceTargetTX,szValue1];
		NSColor		*color			= ([szDeviceTargetTX contains:@"MOBILE"]) ? [NSColor blueColor] : [NSColor orangeColor];
		NSDictionary	*dict		= [NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
		NSAttributedString	*attriUART	= [[NSAttributedString alloc] initWithString:strInformation
																		attributes:dict];
		[m_strSingleUARTLogs appendAttributedString:attriUART];
		[attriUART release];
        [uartObj Read_UartData:strReadData
			   TerminateSymbol:[NSArray arrayWithObject:@"@_@"]
					 MatchType:0
				  IntervalTime:0.01
					   TimeOut:5];
        //ATSDebug(@"RX ==> [%@]:%@", szTarget, strReadData);
		[IALogs CreatAndWriteUARTLog:[NSString stringWithFormat:@"%@\n",strReadData]
							  atTime:kIADeviceALSFileNameDate
						  fromDevice:szDeviceTargetRX
							withPath:[NSString stringWithFormat:@"%@/%@_%@/%@_%@_Uart.txt",kPD_LogPath,m_szPortIndex,m_szStartTime,m_szPortIndex,m_szStartTime]
							  binary:NO];
		strInformation	= [NSString stringWithFormat:@"[%@] (%@) : %@\n",kIADeviceALSFileNameDate,szDeviceTargetRX,strReadData];
		attriUART		= [[NSAttributedString alloc] initWithString:strInformation
													 attributes:dict];
		[m_strSingleUARTLogs appendAttributedString:attriUART];
		[attriUART release];
        usleep(iDelayTime);
        [uartObj Clear_UartBuff:kUart_ClearInterval
						TimeOut:kUart_CommandTimeOut
						readOut:nil];
        [uartObj Write_UartCommand:szValue3
						 PackedNum:1
						  Interval:0
							 IsHex:NO];
        //ATSDebug(@"TX ==> [%@]:%@", szTarget, szValue3);
		[IALogs CreatAndWriteUARTLog:szValue3
							  atTime:kIADeviceALSFileNameDate
						  fromDevice:szDeviceTargetTX
							withPath:[NSString stringWithFormat:@"%@/%@_%@/%@_%@_Uart.txt",kPD_LogPath,m_szPortIndex,m_szStartTime,m_szPortIndex,m_szStartTime]
							  binary:NO];
		strInformation	= [NSString stringWithFormat:@"[%@] (%@) : %@\n",kIADeviceALSFileNameDate,szDeviceTargetTX,szValue3];
		attriUART		= [[NSAttributedString alloc] initWithString:strInformation
													 attributes:dict];
		[m_strSingleUARTLogs appendAttributedString:attriUART];
		[attriUART release];

        [uartObj Read_UartData:strReadData
			   TerminateSymbol:[NSArray arrayWithObject:@"@_@"]
					 MatchType:0
				  IntervalTime:0.01
					   TimeOut:5];
        //ATSDebug(@"RX ==> [%@]:%@", szTarget, strReadData);
		[IALogs CreatAndWriteUARTLog:[NSString stringWithFormat:@"%@\n",strReadData]
							  atTime:kIADeviceALSFileNameDate
						  fromDevice:szDeviceTargetRX
							withPath:[NSString stringWithFormat:@"%@/%@_%@/%@_%@_Uart.txt",kPD_LogPath,m_szPortIndex,m_szStartTime,m_szPortIndex,m_szStartTime]
							  binary:NO];
		
		strInformation	= [NSString stringWithFormat:@"[%@] (%@) : %@\n",kIADeviceALSFileNameDate,szDeviceTargetRX,strReadData];
		attriUART		= [[NSAttributedString alloc] initWithString:strInformation
													 attributes:dict];
		[m_strSingleUARTLogs appendAttributedString:attriUART];
		[attriUART release];

        usleep(iDelayTime);
        [uartObj Clear_UartBuff:kUart_ClearInterval
						TimeOut:kUart_CommandTimeOut
						readOut:nil];
        [uartObj Write_UartCommand:szValue2
						 PackedNum:1
						  Interval:0
							 IsHex:NO];
        //ATSDebug(@"TX ==> [%@]:%@", szTarget, szValue2);
		[IALogs CreatAndWriteUARTLog:szValue2
							  atTime:kIADeviceALSFileNameDate
						  fromDevice:szDeviceTargetTX
							withPath:[NSString stringWithFormat:@"%@/%@_%@/%@_%@_Uart.txt",kPD_LogPath,m_szPortIndex,m_szStartTime,m_szPortIndex,m_szStartTime]
							  binary:NO];
		strInformation	= [NSString stringWithFormat:@"[%@] (%@) : %@\n",kIADeviceALSFileNameDate,szDeviceTargetTX,szValue2];
		attriUART		= [[NSAttributedString alloc] initWithString:strInformation
													 attributes:dict];
		[m_strSingleUARTLogs appendAttributedString:attriUART];
		[attriUART release];

        [uartObj Read_UartData:strReadData
			   TerminateSymbol:[NSArray arrayWithObject:@"@_@"]
					 MatchType:0
				  IntervalTime:0.01
					   TimeOut:5];
        //ATSDebug(@"RX ==> [%@]:%@", szTarget, strReadData);
		[IALogs CreatAndWriteUARTLog:[NSString stringWithFormat:@"%@\n",strReadData]
							  atTime:kIADeviceALSFileNameDate
						  fromDevice:szDeviceTargetRX
							withPath:[NSString stringWithFormat:@"%@/%@_%@/%@_%@_Uart.txt",kPD_LogPath,m_szPortIndex,m_szStartTime,m_szPortIndex,m_szStartTime]
							  binary:NO];
		strInformation	= [NSString stringWithFormat:@"[%@] (%@) : %@\n",kIADeviceALSFileNameDate,szDeviceTargetRX,strReadData];
		attriUART		= [[NSAttributedString alloc] initWithString:strInformation
													 attributes:dict];
		[m_strSingleUARTLogs appendAttributedString:attriUART];
		[attriUART release];

        [uartObj Clear_UartBuff:kUart_ClearInterval
						TimeOut:kUart_CommandTimeOut
						readOut:nil];
    }
	else
    {
        if([szValue2 isEqualToString:@"Ringer Up"])
        {
            [uartObj Clear_UartBuff:kUart_ClearInterval
							TimeOut:kUart_CommandTimeOut
							readOut:nil];
            [uartObj Write_UartCommand:szValue2
							 PackedNum:1
							  Interval:0
								 IsHex:NO];
            //ATSDebug(@"TX ==> [%@]:%@", szTarget, szValue2);
			[IALogs CreatAndWriteUARTLog:szValue2
								  atTime:kIADeviceALSFileNameDate
							  fromDevice:szDeviceTargetTX
								withPath:[NSString stringWithFormat:@"%@/%@_%@/%@_%@_Uart.txt",kPD_LogPath,m_szPortIndex,m_szStartTime,m_szPortIndex,m_szStartTime]
								  binary:NO];
			NSString	*strInformation = [NSString stringWithFormat:@"[%@] (%@) : %@\n",kIADeviceALSFileNameDate,szDeviceTargetTX,szValue2];
			NSColor		*color			= ([szDeviceTargetTX contains:@"MOBILE"]) ? [NSColor blueColor] : [NSColor orangeColor];
			NSDictionary	*dict		= [NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
			NSAttributedString *attriUART		= [[NSAttributedString alloc] initWithString:strInformation
														 attributes:dict];
			[m_strSingleUARTLogs appendAttributedString:attriUART];
			[attriUART release];

            [uartObj Read_UartData:strReadData
				   TerminateSymbol:[NSArray arrayWithObject:@"@_@"]
						 MatchType:0
					  IntervalTime:0.01
						   TimeOut:5];
            //ATSDebug(@"RX ==> [%@]:%@", szTarget, strReadData);
			[IALogs CreatAndWriteUARTLog:[NSString stringWithFormat:@"%@\n",strReadData]
								  atTime:kIADeviceALSFileNameDate
							  fromDevice:szDeviceTargetRX
								withPath:[NSString stringWithFormat:@"%@/%@_%@/%@_%@_Uart.txt",kPD_LogPath,m_szPortIndex,m_szStartTime,m_szPortIndex,m_szStartTime]
								  binary:NO];
			strInformation	= [NSString stringWithFormat:@"[%@] (%@) : %@\n",kIADeviceALSFileNameDate,szDeviceTargetRX,strReadData];
			attriUART		= [[NSAttributedString alloc] initWithString:strInformation
														 attributes:dict];
			[m_strSingleUARTLogs appendAttributedString:attriUART];
			[attriUART release];
        }
        usleep(iDelayTime);
        [uartObj Clear_UartBuff:kUart_ClearInterval
						TimeOut:kUart_CommandTimeOut
						readOut:nil];
        [uartObj Write_UartCommand:szValue3
						 PackedNum:1
						  Interval:0
							 IsHex:NO];
        //ATSDebug(@"TX ==> [%@]:%@", szTarget, szValue3);
		[IALogs CreatAndWriteUARTLog:szValue3
							  atTime:kIADeviceALSFileNameDate
						  fromDevice:szDeviceTargetTX
							withPath:[NSString stringWithFormat:@"%@/%@_%@/%@_%@_Uart.txt",kPD_LogPath,m_szPortIndex,m_szStartTime,m_szPortIndex,m_szStartTime]
							  binary:NO];
		NSString	*strInformation = [NSString stringWithFormat:@"[%@] (%@) : %@\n",kIADeviceALSFileNameDate,szDeviceTargetTX,szValue3];
		NSColor		*color			= ([szDeviceTargetTX contains:@"MOBILE"]) ? [NSColor blueColor] : [NSColor orangeColor];
		NSDictionary	*dict		= [NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
		NSAttributedString *attriUART		= [[NSAttributedString alloc] initWithString:strInformation
																		 attributes:dict];
		[m_strSingleUARTLogs appendAttributedString:attriUART];
		[attriUART release];

        [uartObj Read_UartData:strReadData
			   TerminateSymbol:[NSArray arrayWithObject:@"@_@"]
					 MatchType:0
				  IntervalTime:0.01
					   TimeOut:5];
        //ATSDebug(@"RX ==> [%@]:%@", szTarget, strReadData);

		[IALogs CreatAndWriteUARTLog:[NSString stringWithFormat:@"%@\n",strReadData]
							  atTime:kIADeviceALSFileNameDate
						  fromDevice:szDeviceTargetRX
							withPath:[NSString stringWithFormat:@"%@/%@_%@/%@_%@_Uart.txt",kPD_LogPath,m_szPortIndex,m_szStartTime,m_szPortIndex,m_szStartTime]
							  binary:NO];
		strInformation	= [NSString stringWithFormat:@"[%@] (%@) : %@\n",kIADeviceALSFileNameDate,szDeviceTargetRX,strReadData];
		attriUART		= [[NSAttributedString alloc] initWithString:strInformation
													 attributes:dict];
		[m_strSingleUARTLogs appendAttributedString:attriUART];
		[attriUART release];

        usleep(iDelayTime);
        [uartObj Clear_UartBuff:kUart_ClearInterval
						TimeOut:kUart_CommandTimeOut
						readOut:nil];
        [uartObj Write_UartCommand:szValue1
						 PackedNum:1
						  Interval:0
							 IsHex:NO];
        //ATSDebug(@"TX ==> [%@]:%@", szTarget, szValue1);
		[IALogs CreatAndWriteUARTLog:szValue1
							  atTime:kIADeviceALSFileNameDate
						  fromDevice:szDeviceTargetTX
							withPath:[NSString stringWithFormat:@"%@/%@_%@/%@_%@_Uart.txt",kPD_LogPath,m_szPortIndex,m_szStartTime,m_szPortIndex,m_szStartTime]
							  binary:NO];
		strInformation	= [NSString stringWithFormat:@"[%@] (%@) : %@\n",kIADeviceALSFileNameDate,szDeviceTargetTX,szValue1];
		attriUART		= [[NSAttributedString alloc] initWithString:strInformation
													 attributes:dict];
		[m_strSingleUARTLogs appendAttributedString:attriUART];
		[attriUART release];

        [uartObj Read_UartData:strReadData
			   TerminateSymbol:[NSArray arrayWithObject:@"@_@"]
					 MatchType:0
				  IntervalTime:0.01
					   TimeOut:5];
        //ATSDebug(@"RX ==> [%@]:%@", szTarget, strReadData);
		[IALogs CreatAndWriteUARTLog:[NSString stringWithFormat:@"%@\n",strReadData]
							  atTime:kIADeviceALSFileNameDate
						  fromDevice:szDeviceTargetRX
							withPath:[NSString stringWithFormat:@"%@/%@_%@/%@_%@_Uart.txt",kPD_LogPath,m_szPortIndex,m_szStartTime,m_szPortIndex,m_szStartTime]
							  binary:NO];
		strInformation	= [NSString stringWithFormat:@"[%@] (%@) : %@\n",kIADeviceALSFileNameDate,szDeviceTargetRX,strReadData];
		attriUART		= [[NSAttributedString alloc] initWithString:strInformation
													 attributes:dict];
		[m_strSingleUARTLogs appendAttributedString:attriUART];
		[attriUART release];

        [uartObj Clear_UartBuff:kUart_ClearInterval
						TimeOut:kUart_CommandTimeOut
						readOut:nil];
    }
    [strReturnValue setString:@"PASS"];
    [strReadData release];
    return [NSNumber numberWithBool:YES];
}

// 2011.10.18 Add by Sky
// Descripton:Judge the ringer button status, make the fixture to do the corresponding activity.
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)RINGER_TEST:(NSDictionary*)dicContents
           RETURN_VALUE:(NSMutableString*)strReturnValue
{
    //Get the current key of the ringer button status from the unit.
    NSString        *szRinger0      = [m_dicMemoryValues valueForKey:@"RINGERSTATUS"];
    //Get the appointed fixture command that the fixture can move the ringer button up.
	NSDictionary    *dicSendUp      = [dicContents valueForKey:@"SENDCOMMAND_UP"];
    NSDictionary    *dicReadUp      = [dicContents valueForKey:@"READCOMMAND_UP"];
    //Get the appointed fixture command that the fixture can move the ringer button down.
	NSDictionary    *dicSendDown    = [dicContents valueForKey:@"SENDCOMMAND_DOWN"];
    NSDictionary    *dicReadDown    = [dicContents valueForKey:@"READCOMMAND_DOWN"];
    //Get the appointed fixture command that the fixture can move the ringer button in.
	NSDictionary    *dicSendIn      = [dicContents valueForKey:@"SENDCOMMAND_IN"];
    NSDictionary    *dicReadIn      = [dicContents valueForKey:@"READCOMMAND_IN"];
    //Get the appointed fixture command that the fixture can move the ringer button out.
	NSDictionary    *dicSendOut     = [dicContents valueForKey:@"SENDCOMMAND_OUT"];
    NSDictionary    *dicReadOut     = [dicContents valueForKey:@"READCOMMAND_OUT"];
    //Get the appointed key of the 'RingerA' in diags response that the ringer button is on the upside.
    NSString        *szRingerUp     = [dicContents valueForKey:@"RingerUpKey"];
    //Get the appointed key of the 'RingerA' in diags response that the ringer button is on the downside.
    NSString        *szRingerDown   = [dicContents valueForKey:@"RingerDownKey"];
    
	//Ringer status need to change after test, Changed by Johuwu_Wu 2013/07/18
	NSString		*szRingerStatusAfterTest = ![dicContents valueForKey:@"RingerStatusAfterTest"] ? nil : [dicContents valueForKey:[dicContents valueForKey:@"RingerStatusAfterTest"]];
	
	//Change the time from microsecond to millisecond.
    int             iDelayTime      = 1000 * [[dicContents valueForKey:@"DELAYTIME"] intValue];
    NSNumber        *numRet;
	NSMutableString	*strReadData    = [[NSMutableString alloc] init];
    if([szRinger0 isEqualToString:szRingerUp])
    {
        [self SEND_COMMAND:dicSendUp];
        numRet = [self READ_COMMAND:dicReadUp RETURN_VALUE:strReadData];
        if (![numRet boolValue])
        {
            NSLog(@"Cannot send the fixture command [%@] successfully!",
                  [dicSendUp objectForKey:kFZ_Script_CommandString]);
            [strReturnValue setString:@"Cannot send the fixture command successfully!"];
            [strReadData release];
            return [NSNumber numberWithBool:NO];
        }
        usleep(iDelayTime);
        [self SEND_COMMAND:dicSendIn];
        numRet = [self READ_COMMAND:dicReadIn RETURN_VALUE:strReadData];
        if (![numRet boolValue])
        {
            NSLog(@"Cannot send the fixture command [%@] successfully!",
                  [dicSendIn objectForKey:kFZ_Script_CommandString]);
            [strReturnValue setString:@"Cannot send the fixture command successfully!"];
            [strReadData release];
            return [NSNumber numberWithBool:NO];
        }
        usleep(iDelayTime);
        [self SEND_COMMAND:dicSendDown];
        numRet = [self READ_COMMAND:dicReadDown RETURN_VALUE:strReadData];
        if (![numRet boolValue])
        {
            NSLog(@"Cannot send the fixture command [%@] successfully!",
                  [dicSendDown objectForKey:kFZ_Script_CommandString]);
            [strReturnValue setString:@"Cannot send the fixture command successfully!"];
            [strReadData release];
            return [NSNumber numberWithBool:NO];
        }
        usleep(iDelayTime);
        [self SEND_COMMAND:dicSendUp];
        numRet = [self READ_COMMAND:dicReadUp RETURN_VALUE:strReadData];
        if (![numRet boolValue])
        {
            NSLog(@"Cannot send the fixture command [%@] successfully!",
                  [dicSendUp objectForKey:kFZ_Script_CommandString]);
            [strReturnValue setString:@"Cannot send the fixture command successfully!"];
            [strReadData release];
            return [NSNumber numberWithBool:NO];
        }
        usleep(iDelayTime);
		
		//Ringer status need to change after test, Changed by Johuwu_Wu 2013/07/18
		if( szRingerStatusAfterTest && ![szRinger0 isEqualToString:szRingerStatusAfterTest] )
		{
			[self SEND_COMMAND:dicSendDown];
			numRet = [self READ_COMMAND:dicReadDown RETURN_VALUE:strReadData];
			if (![numRet boolValue])
			{
				NSLog(@"Cannot send the fixture command [%@] successfully!",
					  [dicSendDown objectForKey:kFZ_Script_CommandString]);
				[strReturnValue setString:@"Cannot send the fixture command successfully!"];
				[strReadData release];
				return [NSNumber numberWithBool:NO];
			}
			usleep(iDelayTime);

		}
		
        [self SEND_COMMAND:dicSendOut];
        numRet = [self READ_COMMAND:dicReadOut RETURN_VALUE:strReadData];
        if (![numRet boolValue])
        {
            NSLog(@"Cannot send the fixture command [%@] successfully!",
                  [dicSendOut objectForKey:kFZ_Script_CommandString]);
            [strReturnValue setString:@"Cannot send the fixture command successfully!"];
            [strReadData release];
            return [NSNumber numberWithBool:NO];
        }
		usleep(iDelayTime);
			
		//Ringer status need to change after test, Changed by Johuwu_Wu 2013/07/18
		if( szRingerStatusAfterTest && ![szRinger0 isEqualToString:szRingerStatusAfterTest] )
		{
			[self SEND_COMMAND:dicSendUp];
			numRet = [self READ_COMMAND:dicReadUp RETURN_VALUE:strReadData];
			if (![numRet boolValue])
			{
				NSLog(@"Cannot send the fixture command [%@] successfully!",
					  [dicSendUp objectForKey:kFZ_Script_CommandString]);
				[strReturnValue setString:@"Cannot send the fixture command successfully!"];
				[strReadData release];
				return [NSNumber numberWithBool:NO];
			}
			usleep(iDelayTime);
		}

    }
	else if([szRinger0 isEqualToString:szRingerDown])
    {
        [self SEND_COMMAND:dicSendDown];
        numRet = [self READ_COMMAND:dicReadDown RETURN_VALUE:strReadData];
        if (![numRet boolValue])
        {
            NSLog(@"Cannot send the fixture command [%@] successfully!",
                  [dicSendDown objectForKey:kFZ_Script_CommandString]);
            [strReturnValue setString:@"Cannot send the fixture command successfully!"];
            [strReadData release];
            return [NSNumber numberWithBool:NO];
        }
        usleep(iDelayTime);
        [self SEND_COMMAND:dicSendIn];
        numRet = [self READ_COMMAND:dicReadIn RETURN_VALUE:strReadData];
        if (![numRet boolValue])
        {
            NSLog(@"Cannot send the fixture command [%@] successfully!",
                  [dicSendIn objectForKey:kFZ_Script_CommandString]);
            [strReturnValue setString:@"Cannot send the fixture command successfully!"];
            [strReadData release];
            return [NSNumber numberWithBool:NO];
        }
        usleep(iDelayTime);
        [self SEND_COMMAND:dicSendUp];
        numRet = [self READ_COMMAND:dicReadUp RETURN_VALUE:strReadData];
        if (![numRet boolValue])
        {
            NSLog(@"Cannot send the fixture command [%@] successfully!",
                  [dicSendUp objectForKey:kFZ_Script_CommandString]);
            [strReturnValue setString:@"Cannot send the fixture command successfully!"];
            [strReadData release];
            return [NSNumber numberWithBool:NO];
        }
        usleep(iDelayTime);
        [self SEND_COMMAND:dicSendDown];
        numRet = [self READ_COMMAND:dicReadDown RETURN_VALUE:strReadData];
        if (![numRet boolValue])
        {
            NSLog(@"Cannot send the fixture command [%@] successfully!",
                  [dicSendDown objectForKey:kFZ_Script_CommandString]);
            [strReturnValue setString:@"Cannot send the fixture command successfully!"];
            [strReadData release];
            return [NSNumber numberWithBool:NO];
        }
        usleep(iDelayTime);
		
		//Ringer status need to change after test, Changed by Johuwu_Wu 2013/07/18
		if( szRingerStatusAfterTest && ![szRinger0 isEqualToString:szRingerStatusAfterTest] )
		{
			[self SEND_COMMAND:dicSendUp];
			numRet = [self READ_COMMAND:dicReadUp RETURN_VALUE:strReadData];
			if (![numRet boolValue])
			{
				NSLog(@"Cannot send the fixture command [%@] successfully!",
					  [dicSendUp objectForKey:kFZ_Script_CommandString]);
				[strReturnValue setString:@"Cannot send the fixture command successfully!"];
				[strReadData release];
				return [NSNumber numberWithBool:NO];
			}
			usleep(iDelayTime);
		}
				
        [self SEND_COMMAND:dicSendOut];
        numRet = [self READ_COMMAND:dicReadOut RETURN_VALUE:strReadData];
        if (![numRet boolValue])
        {
            NSLog(@"Cannot send the fixture command [%@] successfully!",
                  [dicSendOut objectForKey:kFZ_Script_CommandString]);
            [strReturnValue setString:@"Cannot send the fixture command successfully!"];
            [strReadData release];
            return [NSNumber numberWithBool:NO];
        }
        usleep(iDelayTime);
        [self SEND_COMMAND:dicSendUp];
        numRet = [self READ_COMMAND:dicReadUp RETURN_VALUE:strReadData];
        if (![numRet boolValue])
        {
            NSLog(@"Cannot send the fixture command [%@] successfully!",
                  [dicSendUp objectForKey:kFZ_Script_CommandString]);
            [strReturnValue setString:@"Cannot send the fixture command successfully!"];
            [strReadData release];
            return [NSNumber numberWithBool:NO];
        }
    }
    else
    {
        NSLog(@"Get the wrong key [%@] from the unit for the Ringer button status!", szRinger0);
        [strReturnValue setString:@"Can not get the ringer button status from the unit!"];
        [strReadData release];
        return [NSNumber numberWithBool:NO];
    }
    [strReturnValue setString:@"PASS"];
    [strReadData release];
    return [NSNumber numberWithBool:YES];
}

//End 2011.10.28 Add by Ming
- (void)TestButtonFlex:(id)idThread
{
    NSAutoreleasePool	*pool		= [[NSAutoreleasePool alloc] init];
    //ATSDebug(@"Start TestButtonFlex Monitor");
    NSMutableString	*strReadData	= [[NSMutableString alloc] initWithString:@""];
    NSMutableString	*strResult		= [[NSMutableString alloc] initWithString:@""];
    NSDictionary	*dicSendCommand	= [idThread valueForKey:@"SEND_COMMAND"];
    NSDictionary	*dicReadCommand	= [idThread valueForKey:@"READ_COMMAND_DATA"];
    NSArray			*arrButton		= [idThread valueForKey:@"BUTTON_COUNT"];
    [m_dicButtonBuffer setValue:arrButton
						 forKey:@"BUTTON"];
    NSMutableArray	*arrResult		= [[NSMutableArray alloc] init];
    for(int i=0; i<[arrButton count]; i++)
        [arrResult addObject:[NSMutableString string]];
    while ([[m_dicButtonBuffer objectForKey:kIADevice_ButtonTest_BoolTestFlag]
			isEqualToNumber:[NSNumber numberWithBool:YES]])
    {
        @synchronized(m_dicButtonBuffer)
        {
			//send and read command                       
            [self SEND_COMMAND:dicSendCommand];
            [strReadData setString:@""];
            [self BUTTONREAD_COMMAND:dicReadCommand RETURN_VALUE:strReadData];
             /*[self READ_COMMAND:dicReadCommand
				  RETURN_VALUE:strReadData];*/
            for (int i=0; i<[arrButton count]; i++)
            {
                NSString    *strRegex   = [arrButton objectAtIndex:i];
                NSString    *strResult  = [strReadData subByRegex:strRegex name:nil error:nil];
                if(!strResult)
                    continue;
                [[arrResult objectAtIndex:i] appendString:strResult];
                [m_dicButtonBuffer setObject:[arrResult objectAtIndex:i]
                                      forKey:[arrButton objectAtIndex:i]];
            }
        }
        usleep(10000);
    }   
    [strReadData release];
    [arrResult release];
    [strResult release];
    //ATSDebug(@"End TestButtonFlex Monitor");
    [pool drain];
}

//Start 2011.10.28 Add by Ming 
// Descripton:Stop the thread to read the DUT's key status, until Set kIADevice_ButtonTest_BoolTestFlag  = NO
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)END_TEST_BUTTON_THREAD:(NSDictionary*)dicContents
					  RETURN_VALUE:(NSMutableString*)strReturnValue
{
    //steat the button test, BoolTestFlag = yes.
    @synchronized(m_dicButtonBuffer)
    {
        [m_dicButtonBuffer setObject:[NSNumber numberWithBool:NO]
							  forKey:kIADevice_ButtonTest_BoolTestFlag];
    }
    return [NSNumber numberWithBool:YES];
}
//End 2011.10.28 Add by Ming

//Add by Jeff
-(NSNumber*)CHECK_BUTTON_STATUS:(NSDictionary*)dicContents
				   RETURN_VALUE:(NSMutableString*)strReturnValue
{
    double		dTimeOut		= [[dicContents objectForKey:@"TIMEOUT"]
								   doubleValue];
    NSArray		*arrButton		= [m_dicButtonBuffer valueForKey:@"BUTTON"];
    NSArray		*arrStatus		= [dicContents objectForKey:@"STATUS_KEYS"];
	NSArray		*arrButtonKey	= [dicContents valueForKey:@"BUTTON_COUNT"];
    NSString	*szMatchType	= [dicContents objectForKey:@"MATCHTYPE"];
    NSDate		*dateStart		= [NSDate date];
    double		dSpendtime		= 0;
	BOOL		bMatch			= NO;
	BOOL		bAllPass		= NO;
	int			iValue			= 0;
    	
	if ([arrButton count] != [arrButtonKey count])
		return [NSNumber numberWithBool:NO];
    for (int i = 0; i < [arrButton count]; i++)
		[m_dicButtonBuffer setValue:@"FAIL"
							 forKey:[NSString stringWithFormat:
									 @"%@Key", [arrButton objectAtIndex:i]]];
    //dowhile to check the button status if changed
    do
	{
        @synchronized(m_dicButtonBuffer)
        {
			iValue	= 0;
            NSArray	*arrTemp	=[m_dicButtonBuffer allKeys];
            dSpendtime	= [[NSDate date] timeIntervalSinceDate:dateStart];
            for (int i=0; i<[arrButton count]; i++)
                
            {
                int         iCount          = 0;
				if (![[m_dicButtonBuffer valueForKey:[NSString stringWithFormat:
													  @"%@Key", [arrButton objectAtIndex:i]]]
					  isEqualToString:@"PASS"])
				{
					if ([arrTemp containsObject:[arrButton objectAtIndex:i]])
					{
						//judge if can find the button status which gived in plist.
						//szMatchType:  if it is 0,must match all status;if it is 1,just need match any status .
						for (int j = 0; j < [arrStatus count]; j++)
						{
							NSRange	range1	= [[m_dicButtonBuffer valueForKey:
												[arrButton objectAtIndex:i]]
											   rangeOfString:[arrStatus objectAtIndex:j]];
							if((NSNotFound == range1.location
								|| ([[m_dicButtonBuffer valueForKey:[arrButton objectAtIndex:i]] length]
									< range1.length+range1.location)
								|| range1.length == 0))
							{
								bMatch	= NO;
								NSLog(@"The Button %@ Status is not Ok!", [arrButton objectAtIndex:i]);
								if ([szMatchType isEqualToString:@"0"])
									break;
							}
							else
							{
								bMatch	= YES;
								NSLog(@"The Button %@ Status Value %@ suit to the conditon: %@",
									  [arrButton objectAtIndex:i],
									  [m_dicButtonBuffer valueForKey:[arrButton objectAtIndex:i]],
									  [arrStatus objectAtIndex:j]);
                                
                                //add by pleasure for AE stations to count the button status change.
                                //modified for Ringer button 
                                if([[arrButton objectAtIndex:i]contains:@"Ringer"])
                                {
                                    NSString *Ringerstr = [m_dicButtonBuffer valueForKey:[arrButton objectAtIndex:i]];
                                    Ringerstr = [NSString stringWithFormat:@"%@00001111",Ringerstr];
                                    [m_dicButtonBuffer setObject:Ringerstr forKey:[arrButton objectAtIndex:i]];
                                }
                                NSArray *arrayCount =[[[m_dicButtonBuffer valueForKey:
                                                        [arrButton objectAtIndex:i]]
                                                       stringByReplacingOccurrencesOfString:[arrStatus objectAtIndex:j] withString:@"*@"]
                                                      componentsSeparatedByString:@"@"];
                                for (int i = 0; i < [arrayCount count]; i++)
                                {
                                    NSRange rangeString = [[arrayCount objectAtIndex:i]rangeOfString:@"*"];
                                    if (NSNotFound ==rangeString.location)
                                    {
                                        continue;
                                    }
                                    else
                                        
                                        iCount +=1;
                                }
								if ([szMatchType isEqualToString:@"1"])
									break;
							}
						}
						if (bMatch)
                        {
                            [m_dicButtonBuffer setValue:@"PASS"
												 forKey:[NSString stringWithFormat:@"%@Key",
                                                         [arrButton objectAtIndex:i]]];
                            [m_dicButtonBuffer setObject:[NSNumber numberWithInt:iCount]
                                                  forKey:[NSString stringWithFormat:@"%@KeyCount",
                                                             [arrButton objectAtIndex:i]]];
                        }
					}
					else
					{
						bAllPass	= NO;
						//ATSDebug(@"Can't Find Key");
					}
				}
            }
			for (int k = 0; k < [arrButton count]; k++)
			{
				if ([[m_dicButtonBuffer valueForKey:[NSString stringWithFormat:
													 @"%@Key",
													 [arrButton objectAtIndex:k]]]
					 isEqualToString:@"PASS"])
					iValue	+= 1;
			}
			if (iValue == [arrButton count])
				bAllPass	= YES;
            if (bAllPass)
                break;
        }
        usleep(10000);
    }while(dSpendtime < dTimeOut);
    
    
    if (bAllPass)
        [strReturnValue setString:@"PASS"];
    else
        [strReturnValue setString:@"FAIL"];
    return [NSNumber numberWithBool:bAllPass];
}

///Add for AE stations to count the signal received times
-(NSNumber*)CHECK_BUTTON_PRESS_TIMES:(NSDictionary*)dicContents
                        RETURN_VALUE:(NSMutableString*)strReturnValue
{
    NSArray		*arrButtons		= [m_dicButtonBuffer valueForKey:@"BUTTON"];
    NSString    *strStatus      = @"";
    NSString    *strAEButton    = [dicContents valueForKey:@"MAINBUTTON_TYPE"];
    NSArray     *arrOtherBtn    = [dicContents valueForKey:@"OTHERBUTTON_TYPE"];
    NSString    *strAEkey       = [dicContents valueForKey:@"KEY"];
    NSMutableString *strCount   = [[NSMutableString alloc]init];
    BOOL              flag      = NO ;
    BOOL             bAEStatus  = [[dicContents valueForKey:@"AEKEY"] boolValue];
    NSString    *strRinger      = @"";
    // [strReturnValue setString:@""];
    @synchronized(m_dicButtonBuffer)
    {
        for(int i=0;i<[arrButtons count];i++)
        {
            int iCount    = 0;
            if ([m_dicButtonBuffer valueForKey:[arrButtons objectAtIndex:i]] == nil)
            {
                [strCount release];
                return [NSNumber numberWithBool:NO];
            }
            if ([[arrButtons objectAtIndex:i]contains:@"Ringer"])
            {
                if (bAEStatus)
                {
                    strRinger = [m_dicButtonBuffer valueForKey:[arrButtons objectAtIndex:i]];
                    if (NSNotFound != [strRinger rangeOfString:@"10"].location || NSNotFound != [strRinger rangeOfString:@"01"].location)
                    {
                        //for counting the signal change number
                        NSString *strRingerCount = [NSString stringWithFormat:@"%@00001111",strRinger];
                        [m_dicButtonBuffer setObject:strRingerCount forKey:[arrButtons objectAtIndex:i]];
                    }

                }
                strStatus = [NSString stringWithFormat:@"%@",@"10"];
            }
            if ([[arrButtons objectAtIndex:i]contains:@"Vol"])
            {
                strStatus = [NSString stringWithFormat:@"%@",@"10"];
            }
            if ([[arrButtons objectAtIndex:i]contains:@"Menu"]||[[arrButtons objectAtIndex:i]contains:@"Hold"])
            {
                strStatus = [NSString stringWithFormat:@"%@",@"01"];
            }
            NSArray *arrayCount =[[[m_dicButtonBuffer valueForKey:
                                    [arrButtons objectAtIndex:i]]
                                   stringByReplacingOccurrencesOfString:strStatus  withString:@"*@"]
                                  componentsSeparatedByString:@"@"];
            // count the status to change and restore in m_dicMemoryValue
            for (int i = 0; i < [arrayCount count]; i++)
            {
                NSRange rangeString = [[arrayCount objectAtIndex:i]rangeOfString:@"*"];
                if (NSNotFound ==rangeString.location)
                {
                    continue;
                }
                else
                    
                    iCount +=1;
            }
            
            [m_dicButtonBuffer setObject:[NSNumber numberWithInt:iCount]
                                  forKey:[NSString stringWithFormat:@"%@KeyCounter",
                                      [arrButtons objectAtIndex:i]]];
            
        }
        //restore status count for other buttons
        if (arrOtherBtn && strAEButton)
        {
            for (int j =0; j<[arrOtherBtn count]; j++)
            {
                [strCount appendFormat:@"%@",[m_dicButtonBuffer objectForKey:[arrOtherBtn objectAtIndex:j]]];
                
            }
            int i = [arrOtherBtn count];
            NSString * strBtnCount = @"";
            if (i== 3) {
                strBtnCount = @"000";
            }
            if (i== 4) 
                strBtnCount = @"0000";
            if (i == 5)
                strBtnCount = @"00000";
            if (i == 6)
                strBtnCount = @"000000";
            if (i == 7)
                strBtnCount = @"0000000";
           if ([strCount isEqualTo:strBtnCount])
                 flag = NO ;
            else
                 flag = YES;
            
        }
        // no button signal received,set the value "0"
        if ([[m_dicButtonBuffer objectForKey:strAEButton]isEqualTo:[NSNumber numberWithInt:0]] && !flag )
        {
            [m_dicButtonBuffer setObject:[NSNumber numberWithInt:0] forKey:strAEkey];
            if (!bAEStatus)
            {
                [m_dicButtonBuffer setObject:@"0,No button signal received" forKey:[NSString stringWithFormat:@"%@_KEY",strAEkey]];
            }
            
        }
        // only incorrect button signal received,set value "-1"
        if ([[m_dicButtonBuffer objectForKey:strAEButton]isEqualTo:[NSNumber numberWithInt:0]] && flag )
        {
            [m_dicButtonBuffer setObject:[NSNumber numberWithInt:-1] forKey:strAEkey];
            if (!bAEStatus)
            {
                [m_dicButtonBuffer setObject:@"-1,Only the other button be pressed" forKey:[NSString stringWithFormat:@"%@_KEY",strAEkey]];
            }
        }
        // only correct button signal received,set value "1"
        if ([[m_dicButtonBuffer objectForKey:strAEButton]isEqualTo:[NSNumber numberWithInt:1]] && !flag)
        {
            [m_dicButtonBuffer setObject:[NSNumber numberWithInt:1] forKey:strAEkey];
            if (!bAEStatus)
            {
                [m_dicButtonBuffer setObject:@"1,The correct button be pressed once" forKey:[NSString stringWithFormat:@"%@_KEY",strAEkey]];
            }
        }
        // Both correct and incorrect button singal receive,set value "2"
        if ([[m_dicButtonBuffer objectForKey:strAEButton]isNotEqualTo:[NSNumber numberWithInt:0]] && flag )
        {
            [m_dicButtonBuffer setObject:[NSNumber numberWithInt:2] forKey:strAEkey];
            if (!bAEStatus)
            {
                [m_dicButtonBuffer setObject:@"2,Both correct and incorrect button be pressed" forKey:[NSString stringWithFormat:@"%@_KEY",strAEkey]];
            }
        }
        // The correct button signal receive more than 1,may be 2/3/....
        if ([[m_dicButtonBuffer objectForKey:strAEButton]intValue ]>1 && !flag)
        {
            [m_dicButtonBuffer setObject:[NSNumber numberWithInt:3] forKey:strAEkey];
            if (!bAEStatus)
            {
                [m_dicButtonBuffer setObject:@"3,The correct button be pressed more than once" forKey:[NSString stringWithFormat:@"%@_KEY",strAEkey]];
            }
        }
                
    }
    [strCount release];
    return [NSNumber numberWithBool:YES];
    
}

//Add by Jean
// Param:
//		NSString: RINGER_DOWN: 1 / 0
//		NSString: RINGRT_ORIGINAL
//		NSString: FixtureUP			fixture ringer up command
//		NSString: FixtureDOWN		fixture ringer down command
// Based on RINGER_UP
-(NSNumber*)CHECK_RINGER_STATUS:(NSDictionary*)dicContents
				   RETURN_VALUE:(NSMutableString*)strReturnValue
{
	//If the setting dictionary has no parameters, post a alert panel.
	if (!dicContents || [dicContents count] == 0) {
		NSRunAlertPanel([NSString stringWithFormat:@"警告(Warning)"],
						@"CHECK_RINGER_STATUS:RETURN_VALUE:没有参数。(There are no parameters for CHECK_RINGER_STATUS!)",
						@"确认(OK)", nil, nil);
		return [NSNumber numberWithBool:NO];
	}
	
	NSString		*strRingerDownValue		= [dicContents objectForKey:@"RINGER_DOWN"];
	NSString		*strRingerOriginal		= [dicContents objectForKey:@"RINGRT_ORIGINAL"];
	NSString		*strRingerOriValue		= @"";
	if (strRingerDownValue == nil
		|| [strRingerDownValue isEqualToString:@""]
		|| strRingerOriginal == nil
		|| [strRingerOriginal isEqualToString:@""])
	{
		NSRunAlertPanel([NSString stringWithFormat:@"警告(warning)"],
						@"CHECK_RINGER_STATUS:RETURN_VALUE:里的参数为空。(The parameters for CHECK_RINGER_STATUS is null.)",
						@"确认(OK)", nil, nil);
		return [NSNumber numberWithBool:NO];
	}
	
	BOOL bReturn = [self TransformKeyToValue:strRingerOriginal returnValue:&strRingerOriValue];
	
	
	NSString	*strFixtureUp	= [dicContents objectForKey:@"FixtureUP"];
	NSString	*strFixtureDown	= [dicContents objectForKey:@"FixtureDOWN"];
	if (strFixtureUp == nil
		|| [strFixtureUp isEqualToString:@""]
		|| strFixtureDown == nil
		|| [strFixtureDown isEqualToString:@""])
	{
		NSRunAlertPanel([NSString stringWithFormat:@"警告(warning)"],
						@"CHECK_RINGER_STATUS:RETURN_VALUE:里的参数为空。(The parameters for CHECK_RINGER_STATUS is null.)",
						@"确认(OK)", nil, nil);
		return [NSNumber numberWithBool:NO];
	}
	
	//The original status of ringer button is down
	if ([strRingerDownValue isEqualToString:strRingerOriValue])
	{
		@synchronized(m_dicMemoryValues)
		{
			[m_dicMemoryValues setObject:strFixtureDown
								  forKey:@"AdjustFixtureLocation"];
			[m_dicMemoryValues setObject:strFixtureUp
								  forKey:@"FirstFixtureCommand"];
			[m_dicMemoryValues setObject:strFixtureDown
								  forKey:@"SecondFixtureCommand"];
		}
	}
	else
	{
		@synchronized(m_dicMemoryValues)
		{
			[m_dicMemoryValues setObject:strFixtureUp
								  forKey:@"AdjustFixtureLocation"];
			[m_dicMemoryValues setObject:strFixtureDown
								  forKey:@"FirstFixtureCommand"];
			[m_dicMemoryValues setObject:strFixtureUp
								  forKey:@"SecondFixtureCommand"];
		}
	}
	
	return [NSNumber numberWithBool:bReturn];
}

@end




