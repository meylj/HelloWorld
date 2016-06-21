//
//  IADevice_TestingCommands.m
//  Izual_Lu
//
//  Created by Lu Izual on 11-4-21.
//  Copyright 2011Âπ?PEGATRON. All rights reserved.
//

#import "IADevice_TestingCommands.h"
#import "IADevice_SFIS.h"

NSString * const TestItemInfoNotification = @"TestItemInfo";

NSString * const ShowMessage    =   @"showMessageOnUI";

NSString * const CloseMessage = @"closeMessageFromUI";

@implementation TestProgress (IADevice_TestingCommands)

#pragma mark ############################## Testting Commands ##############################
// Open target port. {MOBILE, FIXTURE, LIGHTMETER, ...}
// Param:
//		NSDictionary	*dicOpenSettings	: Open target settings
//          TARGET  -> NSString*    : Target you want to open. {MOBILE, FIXTURE, LIGHTMETER, ...}
// Return:
//      Actions result
-(NSNumber*)OPEN_TARGET:(NSDictionary*)dicOpenSettings
{
	// Get port settings
    NSString        *szPortType   = [dicOpenSettings objectForKey:kFZ_Script_DeviceTarget];//#define kIADeviceDeviceTarget @"TARGET"
    NSString        *szSlot    =    [dicOpenSettings objectForKey:@"Unit"];
    NSString        *szBsdPath;
    //for Prox Cal
    if(nil!=szSlot)
    {
        szBsdPath   = [[[m_dicPorts objectForKey:szPortType] objectAtIndex:kFZ_SerialInfo_SerialPort] objectForKey:szSlot];
    }
    else
    {
         szBsdPath  = [[m_dicPorts objectForKey:szPortType] objectAtIndex:kFZ_SerialInfo_SerialPort];
    }
    NSInteger       iSpeed = [kPD_DeviceSet_BaudeRate intValue];
    NSInteger       iDataBit = [kPD_DeviceSet_DataBit intValue];
    NSString        *szParity = kPD_DeviceSet_Parity;
    NSInteger       iStopBit = [kPD_DeviceSet_StopBit intValue]; 
    NSString        *szEndsymbol = kPD_DeviceSet_EndFlag;
    NSInteger iRet = kUart_SUCCESS;
    PEGA_ATS_UART   *uartObj    = [[m_dicPorts objectForKey:szPortType] objectAtIndex:kFZ_SerialInfo_UartObj];
    
    [uartObj Close_Uart];
    
    // if uart object is null,overleap the open or send or read motion with uart.       torres 2012.2.9
    if (NULL == uartObj) {
        iRet = kUart_CMD_CHECK_DUT_FAIL;
        ATSDebug(@"OPEN_TARGET : get uart object fail,overleap open port!");
    }else
        iRet = [uartObj openPort:szBsdPath baudeRate:iSpeed dataBit:iDataBit parity:szParity stopBits:iStopBit endSymbol:szEndsymbol];
    
    if(kUart_SUCCESS == iRet)//iRet== 0 --> succeed
    {
        //Start 2011.11.02 Add By Ming, put MOBILE_ID, FIXTURE_ID, METER_ID in Dictionary
        
        NSInteger nPosition = [self GetUSB_PortNum];
        [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%d",nPosition] forKey:IADevice_TestingCommands_MOBILE_ID];
        [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%d",nPosition] forKey:IADevice_TestingCommands_FIXTURE_ID];
        [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%d",nPosition] forKey:IADevice_TestingCommands_LIGHTMETER_ID];

        //End 2011.11.02 Add By Ming, put MOBILE_ID, FIXTURE_ID, METER_ID in Dictionary
        ATSDebug(@"OPEN_TARGET => Open uart for %@:%@ pass!",szPortType,szBsdPath);
        return [NSNumber numberWithBool:YES];
    }
    else
    {
        ATSDebug(@"OPEN_TARGET => Open uart for %@:%@ fail!",szPortType,szBsdPath);
        return [NSNumber numberWithBool:NO];
    }
}

// Close target port. {MOBILE, FIXTURE, LIGHTMETER, ...}
// Param:
//		NSDictionary	*dicCloseSettings	: Close target settings
//          TARGET  -> NSString*    : Target you want to close. {MOBILE, FIXTURE, LIGHTMETER, ...}
// Return:
//      Actions result
-(NSNumber*)CLOSE_TARGET:(NSDictionary*)dicCloseSettings RETURN_VALUE:(NSMutableString*)strReturnValue
{
	// Get port settings
    NSString        *szTarget   = [dicCloseSettings objectForKey:kFZ_Script_DeviceTarget];
	PEGA_ATS_UART   *uartObj    = [[m_dicPorts objectForKey:szTarget] objectAtIndex:kFZ_SerialInfo_UartObj];
	// Close
	[uartObj Close_Uart];
    
    
	//[strReturnValue setString:@"PASS"];  //marked it by yaya 2012,2,9
	// End
	return [NSNumber numberWithBool:YES];
}

// Clear target buffer. {MOBILE, FIXTURE, LIGHTMETER, ...}
// Param:
//		NSDictionary	*dicClearSettings	: Clear target settings
//          TARGET  -> NSString*    : Target you want to clear. {MOBILE, FIXTURE, LIGHTMETER, ...}
// Return:
//      Actions result
-(NSNumber*)CLEAR_TARGET:(NSDictionary*)dicClearSettings
{
	// Get port settings
    NSString        *szTarget   = [dicClearSettings objectForKey:kFZ_Script_DeviceTarget];
	PEGA_ATS_UART   *uartObj    = [[m_dicPorts objectForKey:szTarget] objectAtIndex:kFZ_SerialInfo_UartObj];
	// Close
	[uartObj Clear_UartBuff:kUart_ClearInterval TimeOut:kUart_CommandTimeOut readOut:nil];
	return [NSNumber numberWithBool:YES];
}

// Send command to TARGET, 4 mode: STRING, STRING(BYTE), STRING(HEXSTRING), DATA
// Param:
//		NSDictionary	*dicSendString	: Save contents that need to be send to device
//			TARGET			-> NSString*	: TARGET you send command to. {FIXTURE, MOBILE, LIGHTMETER, ...}
//			STRING			-> NSString*	: STRING you send out. (Can be nil)
//			DATA			-> NSData*      : DATA you send out. (Can be nil)
//			HEXSTRING		-> Boolean      : STRING is composed of Hex Values or not. (Can be nil)
//			BYTE			-> NSNumber     : STRING convert to characters and write section(one or more) by section or not. (Can be nil)
//          NUART           -> Boolean      : this key decide whether to save uart log
// Return:
//		Actions result
-(NSNumber*)SEND_COMMAND:(NSDictionary*)dicSendContents 
{
    if (!dicSendContents || [dicSendContents count] == 0) {
        NSRunAlertPanel(kFZ_PanelTitle_Warning, @"SEND_COMMAND函数没有参数。(There're no parameters for SEND_COMMAND!)", @"确认(OK)", nil, nil);
        return [NSNumber numberWithBool:NO];
    }
    BOOL bRet = YES;
	NSInteger iRet = kUart_SUCCESS;
	// Get send settings
	NSString	*szPortType		= [dicSendContents objectForKey:kFZ_Script_DeviceTarget];
    
    BOOL        bIsHex = [[dicSendContents objectForKey:kFZ_Script_CommandHexString] boolValue];

    BOOL        bNoUartOutPut = [[dicSendContents objectForKey:kFZ_Script_WithoutUart] boolValue];
    
    //No write uart log.
    BOOL        bNoUartLog = [[dicSendContents objectForKey:KFZ_Script_WithoutUartLog] boolValue];
    
    //modified by jingfu ran on 2012 use same key kFZ_Script_CommandString to tranform data
     //NSData      *data = [dicSendContents objectForKey:kFZ_Script_CommandData];    
    id          SendCommand	= [dicSendContents objectForKey:kFZ_Script_CommandString];
    id          sentCommand = nil;
    
    NSInteger   iPackedNum = 1;
    NSInteger   iIntervalTime = 0;
    if ([dicSendContents objectForKey:kFZ_Script_CommandByte]) {
        iPackedNum = [[dicSendContents objectForKey:kFZ_Script_CommandByte] intValue];
        iIntervalTime = 1000;
    }
    
	PEGA_ATS_UART   *uartObj    = [[m_dicPorts objectForKey:szPortType] objectAtIndex:kFZ_SerialInfo_UartObj];
    
    //for clear buffer
    NSString *szReadOutForClear = @"";
    [uartObj Clear_UartBuff:kUart_ClearInterval TimeOut:kUart_CommandTimeOut readOut:&szReadOutForClear];
    NSString *szDeviceTarget = [NSString stringWithFormat:@"Clear Buffer ==> [%@]",szPortType];
    BOOL bBinarySave = [[self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_SaveBinary,nil] boolValue]; 
    if (!bNoUartLog)
    {
        [IALogs CreatAndWriteUARTLog:[NSString stringWithFormat:@"%@\n",szReadOutForClear] atTime:kIADeviceALSFileNameDate fromDevice:szDeviceTarget withPath:[NSString stringWithFormat:@"%@/%@_%@_Uart.txt",kPD_LogPath_Uart,m_szPortIndex,m_szStartTime] binary:bBinarySave];
    }
    
    // String
	if([SendCommand isKindOfClass:[NSString class]])
	{  
        // Generate complete string command
        bRet = [self TransformKeyToValue:SendCommand returnValue:&SendCommand];
        // Send string command
    
        //comment by jingfu ran accord ken's advice on 2012 05 11 for avoid extra operator
        /*
        if(bHexString)
        {
            //[uartObj Write_UartCmd_WithHex:szSendCommand];
            sentCommand = [self stringHexToData:szSendCommand]; 
            szSendCommand = [NSString stringWithFormat:@"%@\r",szSendCommand];
        }
		else
        {*/
        //end by jingfu ran on 2012 05 11
            //iRet = [uartObj Write_UartCmd_WithSting:szSendCommand];
            sentCommand = SendCommand;
        //}
        if (bNoUartOutPut) 
        {
            SendCommand = @"\r";
        }
        ATSDebug(@"Write to ---> %@ , command[%@(%@)]",szPortType,SendCommand,kFZ_Script_CommandString);
	}
    //data
    else if([SendCommand isKindOfClass:[NSData class]])
    {
        sentCommand = SendCommand;
		SendCommand = [NSString stringWithFormat:@"%@\r",SendCommand];        
        if (bNoUartOutPut) 
        {
            SendCommand = @"\r";
        }        
        ATSDebug(@"Write to ---> %@ , command[%@(%@)]",szPortType,SendCommand,kFZ_Script_CommandData);
    }
	 [m_dicMemoryValues setValue:SendCommand forKey:[NSString stringWithFormat:@"%@ Command",szPortType]];
    
    // if uart object is null,overleap the open or send or read motion with uart.       torres 2012.2.9
    if (NULL == uartObj) {
        iRet = kUart_CMD_CHECK_DUT_FAIL;
        ATSDebug(@"SEND_COMMAND : get uart object fail,overleap!");
    }else
        iRet = [uartObj Write_UartCommand:sentCommand PackedNum:iPackedNum Interval:iIntervalTime IsHex:bIsHex];
    
    // Post to UI
	NSColor	*colorTarget	= [[m_dicPorts objectForKey:szPortType] objectAtIndex:kFZ_SerialInfo_UartTablVColor];
    szDeviceTarget = [NSString stringWithFormat:@"TX ==> [%@]",szPortType]; 

    NSDictionary    *dicPostTXToUI  = [NSDictionary dictionaryWithObjectsAndKeys:
                                       kUartView,kFunnyZoneIdentify,
                                       SendCommand, kIADeviceNotificationTX, 
                                       szDeviceTarget, kFZ_Script_DeviceTarget, 
									   colorTarget, kIADevicePortColor,
                                       kIADeviceALSFileNameDate, kPD_Notification_Time, nil];
    NSLog(@"dicPostTXToUI-------:%@",dicPostTXToUI);
    NSNotificationCenter    *NotificationCenter = [NSNotificationCenter defaultCenter];
    [NotificationCenter postNotificationName:TestItemInfoNotification 
                                      object:self 
                                    userInfo:dicPostTXToUI];
    ATSDebug(@"PostTXToUI ===> \n{\n%@}",[self formatLog_transferObject:dicPostTXToUI]);

    //write uart log Leehua 11.09.27
    //BOOL bBinarySave = [[self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_SaveBinary,nil] boolValue];
    //Start to modify by Ming 20111021  ,Change Time Format
    if (!bNoUartLog) 
    {
        [IALogs CreatAndWriteUARTLog:SendCommand atTime:kIADeviceALSFileNameDate fromDevice:szDeviceTarget withPath:[NSString stringWithFormat:@"%@/%@_%@_Uart.txt",kPD_LogPath_Uart,m_szPortIndex,m_szStartTime] binary:bBinarySave];
    }
    
    //End Ming 20111021 
    if (!bRet) 
    {
        ATSDebug(@"SEND_COMMAND => Send command : Transform key to value fail!");
        return [NSNumber numberWithBool:NO];
    }
    if(kUart_SUCCESS == iRet)//iRet== 0 --> succeed
    {
        ATSDebug(@"SEND_COMMAND => Send command to %@ pass!",szPortType);
        return [NSNumber numberWithBool:YES];
    }
    else
    {
        ATSDebug(@"SEND_COMMAND => Send command to %@ fail!",szPortType);
        return [NSNumber numberWithBool:NO];
    }
}

// Read values from TARGET
// Param:
//		NSDictionary	*dicReadSettings	: Save read settings
//			TARGET          -> NSString*	: TARGET you receive return values from. {FIXTURE, MOBILE, LIGHTMETER, ...}
//			TIMEOUT         -> NSNumber*	: READ TIME OUT. Default = Same with port setting. (Can be nil) (Unit: s)
//			BEGIN           -> NSString*	: Cut begin
//			END             -> NSString*	: Cut end
//          REPEAT          -> NSNumber*    : Cycle read. Default = 1. (Can be nil)
//          DELETE_ENTER    -> Boolean      : Delete \n or not
//          FAIL_RECEIVE    -> NSArray      : READ_COMMAND fail when the string read out contains the items in FAIL_RECEIVE
//          PASS_RECEIVE    -> NSArray      : READ_COMMAND pass when the string read out contains the items in PASS_RECEIVE
//          END_SYMBOL      -> NSArray      : 
//          MATCHTYPE       -> NSNumber*    : For END_SYMBOL, 0: Match all item, 1: Match any one
//          RETURN_DATA     -> Boolean      : For CB read
//          NUART           -> Boolean      : this key decide whether to save uart log
//      NSMutableString *szReturnValue      : Received return values. {STRING, DATA, BYTE}
// Return:
//		Actions result
-(NSNumber*)READ_COMMAND:(NSDictionary*)dicReadSettings 
			RETURN_VALUE:(NSMutableString*)szReturnValue
{
    NSInteger iRet = kUart_SUCCESS;
    //in case save value of last test item 
    [szReturnValue setString:@""];
    // Set default read settings
    BOOL        bNoUartOutPut = [[dicReadSettings objectForKey:kFZ_Script_WithoutUart] boolValue];
    //No write uart log.
    BOOL        bNoUartLog = [[dicReadSettings objectForKey:KFZ_Script_WithoutUartLog] boolValue];
	NSString			*szTarget		= [dicReadSettings objectForKey:kFZ_Script_DeviceTarget];
	PEGA_ATS_UART   *uartObj    = [[m_dicPorts objectForKey:szTarget] objectAtIndex:kFZ_SerialInfo_UartObj];
	NSString *szCommand = [m_dicMemoryValues valueForKey:[NSString stringWithFormat:@"%@ Command",szTarget]];
    double  dReadInterval = kUart_IntervalTime;
    if(nil != [dicReadSettings objectForKey:kFZ_Script_ReceiveInterval])
    {
        dReadInterval = [[dicReadSettings objectForKey:kFZ_Script_ReceiveInterval] doubleValue];
    }    
	double  dReadTimeOut = kUart_CommandTimeOut;
    if(nil != [dicReadSettings objectForKey:kFZ_Script_ReceiveTimeOut])
    {
        dReadTimeOut    = [[dicReadSettings objectForKey:kFZ_Script_ReceiveTimeOut] doubleValue];
    }
	//repeat time for command like print
    unsigned int    uiRepeat    = 1;
    if([[dicReadSettings objectForKey:kFZ_Script_ReceiveRepeat] 
        isKindOfClass:[NSNumber class]])
    {
        uiRepeat    = [[dicReadSettings objectForKey:kFZ_Script_ReceiveRepeat] unsignedIntValue];
    }
    
    NSMutableArray * aryEndSymbols = [NSMutableArray arrayWithArray:[dicReadSettings objectForKey:kFZ_Script_ReceiveEndSymbols]];
	// Added by Lorky 2012-04-30 in Cpto
	// New diags will change the format for end flag.
	// To replace the smail ":-)" with "[ECID] :-)"
	for (NSUInteger i = 0; i < [aryEndSymbols count];i++)
	{
		id objInAry = [aryEndSymbols objectAtIndex:i];
		if ([objInAry isMemberOfClass:[NSString class]] && [[objInAry stringValue] isEqualToString:@":-)"])
		{
			// Used special key to define the ECID name
			if ([m_dicMemoryValues objectForKey:@"LORKY_DEVICE_ECID"])
			{
				[aryEndSymbols replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%@ :-)", [m_dicMemoryValues objectForKey:@"LORKY_DEVICE_ECID"]]];
			}
		}
	}
	
    NSInteger iMatchType = [[dicReadSettings objectForKey:kFZ_Script_ReceiveMatchType] intValue];

    //read data
    if([[dicReadSettings objectForKey:kFZ_Script_ReceiveReturnData] boolValue])
    {
        //for write cb
        NSMutableData *data = [[NSMutableData alloc] init];
        //[uartObj Read_UartDataByBytes:data TerminateSymbol:aryEndSymbols MatchType:iMatchType IntervalTime:kUart_IntervalTime TimeOut:dReadTimeOut];
        
        // if uart object is null,overleap the open or send or read motion with uart.       torres 2012.2.9
        if (NULL == uartObj) {
            iRet = kUart_CMD_CHECK_DUT_FAIL;
            ATSDebug(@"READ_COMMAND : get uart object fail,overleap!");
        }else
            iRet = [uartObj Read_UartData:data TerminateSymbol:aryEndSymbols MatchType:iMatchType IntervalTime:dReadInterval TimeOut:dReadTimeOut];

		//if no end symbol, iRet will always return success, but return date may be nothing
        NSInteger iLen = [data length];
        if (iLen == 0) 
        {
            iRet = kUart_ERROR;
        }
        if (iRet == kUart_SUCCESS) 
        {
            char *pBuffer = malloc(iLen+1);
            [data getBytes:pBuffer];  
            if ([dicReadSettings objectForKey:@"VoltageIndex"])// Read iPad-1 dragonfly voltage
            {
                int iIndex = [[dicReadSettings objectForKey:@"VoltageIndex"] intValue];
                NSString *szTemp = [NSString stringWithFormat:@"%d",(unsigned char)(*(pBuffer + iIndex))];//Get the unsigned value from char*
                float fTemp = [szTemp floatValue] / 10.0f;
                [szReturnValue setString:[NSString stringWithFormat:@"%.2f",fTemp]];
            }
            else
            {
                for(int i=0; i<iLen; i++)
                {
                    [szReturnValue appendFormat:@"%02X ",*(pBuffer+i)];
                }
                [m_dicMemoryValues setObject:data forKey:kFZ_Script_ReceiveReturnData];
            }
            ATSDebug(@"Read from <--- %@ , %@(%s)",szTarget,data,pBuffer);
            free(pBuffer);
        }
        [data release];
    }
    else
    {
        NSMutableString    *strRead=[[NSMutableString alloc] initWithString:@""];
        for (NSInteger iIndex=0; iIndex<uiRepeat; iIndex++) 
        {
            // if uart object is null,overleap the open or send or read motion with uart.       torres 2012.2.9
            if (NULL == uartObj) {
                iRet = kUart_CMD_CHECK_DUT_FAIL;
                ATSDebug(@"READ_COMMAND : get uart object fail,overleap!");
            }else
			{
                iRet = [uartObj Read_UartData:strRead TerminateSymbol:aryEndSymbols MatchType:iMatchType IntervalTime:dReadInterval TimeOut:dReadTimeOut];
			}
            [szReturnValue appendFormat:@"%@",strRead];
        }
        [strRead release];
		
        ATSDebug(@"Read from <--- %@ , %@",szTarget,szReturnValue);
    }
	// Set ECID
	// Maybe need more judgement here.
	// Added by Lorky in Cpto 2012-04-30
	if ([szReturnValue ContainString:@":-)"] && ![[m_dicMemoryValues allKeys] containsObject:@"LORKY_DEVICE_ECID"])
	{
		NSString * strECID = [self getECIDNumber:szReturnValue];
		if (strECID && [strECID isNotEqualTo:@""])
			[m_dicMemoryValues setObject:strECID forKey:@"LORKY_DEVICE_ECID"];
	}
	
    // Post to UI
	NSColor	*colorTarget	= [[m_dicPorts objectForKey:szTarget] objectAtIndex:kFZ_SerialInfo_UartTablVColor];
    NSString *szDeviceTarget = [NSString stringWithFormat:@"RX ==> [%@]",szTarget];
    
    NSString *szReceive = @"";
    if (!bNoUartOutPut) {
        szReceive = [NSString stringWithString:szReturnValue];
    }
    //Start to modify by Ming 20111021    ,Change Time Format 
    NSDictionary    *dicPostRXToUI  = [NSDictionary dictionaryWithObjectsAndKeys:
                                       kUartView,kFunnyZoneIdentify,
                                       szReceive, kIADeviceNotificationRX, 
                                       szDeviceTarget, kFZ_Script_DeviceTarget, 
									   colorTarget, kIADevicePortColor,
                                       kIADeviceALSFileNameDate, kPD_Notification_Time, nil];
    
    //End Ming 20111021
    NSNotificationCenter    *NotificationCenter = [NSNotificationCenter defaultCenter];
    [NotificationCenter postNotificationName:TestItemInfoNotification 
                                      object:self 
                                    userInfo:dicPostRXToUI];
	ATSDebug(@"PostRXToUI ===> \n{\n%@}",[self formatLog_transferObject:dicPostRXToUI]);
    
    //write uart log leehua 11.09.27
    BOOL bBinarySave = [[self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_SaveBinary,nil] boolValue];
    
     //Start to modify by Ming 20111021    ,Change Time Format    
    if (!bNoUartLog)
    {
        [IALogs CreatAndWriteUARTLog:[NSString stringWithFormat:@"%@\n",szReceive] atTime:kIADeviceALSFileNameDate fromDevice:szDeviceTarget withPath:[NSString stringWithFormat:@"%@/%@_%@_Uart.txt",kPD_LogPath_Uart,m_szPortIndex,m_szStartTime] binary:bBinarySave];
    }
    
    
    if(kUart_SUCCESS == iRet)//iRet== 0 --> succeed
    {
        //Set the bUartRevPass flag pass, add by stephen0, 2012.4.20
        bUartRevPass = YES;
        //End
        ATSDebug(@"READ_COMMAND => Read command from %@ pass!",szTarget);
        if (m_newItemFlag && [szTarget isEqualToString:@"MOBILE"]) 
        {
            m_itemHasDUTRX = YES;
        }
        //Leehua 2011/07/25
        if([[dicReadSettings objectForKey:kFZ_Script_ReceiveDeleteEnter] boolValue])
        {
            [szReturnValue replaceOccurrencesOfString:@"\n" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [szReturnValue length])];
            [szReturnValue replaceOccurrencesOfString:@"\r" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [szReturnValue length])];
        }
        
        NSString *szCatchKey = [dicReadSettings objectForKey:kFZ_Script_ReceiveCatch];
        if (![szCatchKey isKindOfClass:[NSString class]] || [szCatchKey isEqualToString:@""]) {
            szCatchKey = kFZ_MemKey_ReadCatch;
        }
        [m_dicMemoryValues setObject:[NSString stringWithString:szReturnValue] forKey:szCatchKey];
        
        //if response doesn't contain all strings that is of pass recieve array , return fail
        NSArray * aryPassReceive = [dicReadSettings objectForKey:kFZ_Script_ReceivePass];
        if(nil != aryPassReceive && [aryPassReceive isKindOfClass:[NSArray class]])
        {
            NSInteger iCount = [aryPassReceive count];
            for(int i=0; i<iCount; i++)
            {
                NSRange range = [szReturnValue rangeOfString:[aryPassReceive objectAtIndex:i]];
                if (range.location == NSNotFound || range.length <= 0 || (range.location+range.length) > [szReturnValue length])
                {
					[szReturnValue setString:[NSString stringWithFormat:@"RX [%@] fail:Can't Catch Pass key:%@!",szCommand,[aryPassReceive objectAtIndex:i]]];
                    return [NSNumber numberWithBool:NO];
                }
            }
        }
        
        //if response contains string that is of fail recieve array , return fail
        NSArray * aryFailReceive = [dicReadSettings objectForKey:kFZ_Script_ReceiveFail];
        if(nil != aryFailReceive && [aryFailReceive isKindOfClass:[NSArray class]])
        {
            NSInteger iCount = [aryFailReceive count];
            for(int i=0; i<iCount; i++)
            {
                NSRange range = [[szReturnValue uppercaseString] rangeOfString:[[aryFailReceive objectAtIndex:i] uppercaseString]];
                if (range.location != NSNotFound && range.length > 0 && (range.location+range.length) <= [szReturnValue length])
                {
					if(m_bNeedJudgeFailReceive) m_iCamispFailCount +=1;
                    ATSDebug(@"READ_COMMAND => Catch fail key:%@!",[aryFailReceive objectAtIndex:i]);
					[szReturnValue setString:[NSString stringWithFormat:@"RX [%@] fail:Catch fail key:%@!",szCommand,[aryFailReceive objectAtIndex:i]]];
                    return [NSNumber numberWithBool:NO];
                }
            }
        }
        
        NSString *szBegin = [dicReadSettings objectForKey:kFZ_Script_ReceiveBegin];
        NSString *szEnd =	[dicReadSettings objectForKey:kFZ_Script_ReceiveEnd];  
		szEnd = ([szEnd isEqualToString:@":-)"] && [[m_dicMemoryValues objectForKey:@"LORKY_DEVICE_ECID"] length] > 0) ? kFZ_EndFlagFormat : szEnd;
        bool bIsNumber  =   NO;
        BOOL bRIGHTSTRING =   NO;
        if(nil !=[dicReadSettings objectForKey:@"IsNumber"])
        {
            bIsNumber   =   [[dicReadSettings objectForKey:@"IsNumber"] boolValue];
        }
        if(nil !=[dicReadSettings objectForKey:@"RIGHTSTRING"])
        {
            bRIGHTSTRING   =   [[dicReadSettings objectForKey:@"RIGHTSTRING"] boolValue];
        }
        if (szBegin != nil && szEnd != nil) {
            NSDictionary    *dicCatch   = [NSDictionary dictionaryWithObjectsAndKeys:szBegin,kFZ_Script_ReceiveBegin,szEnd,kFZ_Script_ReceiveEnd, szCatchKey,kFZ_Script_MemoryKey,[NSNumber numberWithBool:bIsNumber],@"IsNumber",[NSNumber numberWithBool:bRIGHTSTRING],@"RIGHTSTRING",nil];
            if(nil != dicCatch)
            {
                if(![[self CATCH_VALUE:dicCatch RETURN_VALUE:szReturnValue] boolValue])
                {
                    ATSDebug(@"READ_COMMAND => Can't catch string between %@ and %@",szBegin,szEnd);
					if (![szReturnValue isEqualToString:@"NA"]) 
					{
						[szReturnValue setString:[NSString stringWithFormat:@"RX [%@] fail:Catch Value fail",szCommand]];
					}
                    return [NSNumber numberWithBool:NO];
                }
                else
                {
                    ATSDebug(@"READ_COMMAND => Catch string between %@ and %@ == %@",szBegin,szEnd,szReturnValue);
                }
            }
        }             
        return [NSNumber numberWithBool:YES];
    }
    else
    {
        //Set the bUartRevPass flag fail, add by stephen0, 2012.4.20
        bUartRevPass = NO;
        //End
        ATSDebug(@"READ_COMMAND => Read command from %@ fail!",szTarget);
        //if DUT Rx No response continuously happened on 3 test items, stop test.
        if ([szReturnValue ContainString:@":-)"]||[szReturnValue ContainString:@"*_*"]|| [szReturnValue ContainString:@":-D"] ||[szReturnValue ContainString:@"]"])
        {
            if (m_newItemFlag && [szTarget isEqualToString:@"MOBILE"]) 
            {
                m_itemHasDUTRX = YES;
            }
            [szReturnValue setString:[NSString stringWithFormat:@"RX [%@] Error response",szCommand]];
            return [NSNumber numberWithBool:NO];
        }
        else
        {
            if (0 == [szReturnValue length])
            {
                [szReturnValue setString:[NSString stringWithFormat:@"RX [%@] Empty response",szCommand]];
            }
            else
            {
                [szReturnValue setString:[NSString stringWithFormat:@"RX [%@] Incomplete response",szCommand]];
            }
            if (m_newItemFlag && [szTarget isEqualToString:@"MOBILE"]) 
            {
                m_newItemFlag = NO;
            }
            return [NSNumber numberWithBool:NO];
        }
    }
}

// Catch value from m_szLastReturn
// Param:
//		NSDictionary	*dicCatchSettings	: Save catch settings
//			BEGIN           -> NSString*	: Cut begin at the string
//			END             -> NSString*	: Cut end at the string
//          LOCATION        -> NSString*    : Catch from the cut string with the location
//          Length          -> NSString*    : Catch from the cut string with the length
//		NSMutableString	*szReturnValue      : Catched values
// Return:
//		Actions result
-(NSNumber*)CATCH_VALUE:(NSDictionary*)dicCatchSettings 
		   RETURN_VALUE:(NSMutableString*)szReturnValue
{
    [szReturnValue setString:@""];	
	bool bData = NO; 
    if (nil != [dicCatchSettings valueForKey:@"IsNumber"])
    {
        bData = [[dicCatchSettings valueForKey:@"IsNumber"] boolValue];
    }
	// Cut out
    NSString	*szBegin	= [dicCatchSettings objectForKey:kFZ_Script_ReceiveBegin];
    NSString	*szEnd	= [dicCatchSettings objectForKey:kFZ_Script_ReceiveEnd]; 
	szEnd = ([szEnd isEqualToString:@":-)"] && [[m_dicMemoryValues objectForKey:@"LORKY_DEVICE_ECID"] length] > 0) ? kFZ_EndFlagFormat : szEnd;
    NSInteger   iLocation = [[dicCatchSettings objectForKey:kFZ_Script_CatchLocation] intValue];
    NSInteger   iLength = [[dicCatchSettings objectForKey:kFZ_Script_CatchLength] intValue];
    
    NSString    *szKey = [dicCatchSettings objectForKey:kFZ_Script_MemoryKey];
    NSString	*szCatchedValue	= [m_dicMemoryValues objectForKey:szKey];
    if(nil == szCatchedValue)
    {
        szCatchedValue = @"Value not found";
    }
    NSString    *szCatchedResult;
    szCatchedResult = [self catchFromString:szCatchedValue begin:szBegin end:szEnd TheRightString:[[dicCatchSettings objectForKey:@"RIGHTSTRING"] boolValue]];
    if (![szCatchedResult isKindOfClass:[NSString class]] || [szCatchedResult isEqualToString:@""]) 
    {
        ATSDebug(@"CATCH_VALUE => Catch Fail : Can't Find begin string %@ or end string %@.",szBegin,szEnd);
        if(bData)
        {
            [szReturnValue setString:kFZ_99999_Value_Issue];
            ATSDebug(@"-99999issue");;
        }
        else
        {
           [szReturnValue setString:[NSString stringWithFormat:@"%@",szCatchedValue]];
        }
        return [NSNumber numberWithBool:NO];
    }
    
    szCatchedResult = [self catchFromString:szCatchedResult location:iLocation length:iLength];
    if (![szCatchedResult isKindOfClass:[NSString class]] || [szCatchedResult isEqualToString:@""]) 
    {
        ATSDebug(@"CATCH_VALUE => Catch Fail : Can't Find location %d or length %d.",iLocation,iLength);
        if(bData)
        {
            [szReturnValue setString:kFZ_99999_Value_Issue];
            ATSDebug(@"-99999issue");
        }
        else
        {
           [szReturnValue setString:[NSString stringWithFormat:@"%@",szCatchedValue]];
        }
        
        return [NSNumber numberWithBool:NO];
    }
    //Why delete whitespace?Leehua
	szCatchedResult	= [szCatchedResult stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [szReturnValue setString:szCatchedResult];
    ATSDebug(@"CATCH_VALUE => Catch OK : %@",szCatchedResult);
	return [NSNumber numberWithBool:YES];
}

// Judge spec
-(BOOL)JudgeSpec:(NSString *)szSpec return_value:(NSString *)szCatchedValue caseInsensitive:(BOOL)bCaseMode
{
    NSArray     *arraySpec = nil;
    iJudgeMode	= 0;	// 0 = (), 1 = [], 2 = {}, 3 = (], 4 = [), 5 = <>
    
    [self TransformKeyToValue:szSpec returnValue:&szSpec];
    
    if(bCaseMode)
    {
        szCatchedValue	= [szCatchedValue uppercaseString];
        szSpec			= [szSpec uppercaseString];
    }
    
    // Judge spec mode
    
    if((3 > [szSpec length])
       // First character in szSpec must be '(' or '[' or '{'
       || (('(' != [szSpec characterAtIndex: 0])
           && ('[' != [szSpec characterAtIndex: 0])
           && ('{' != [szSpec characterAtIndex: 0])
           && ('<' != [szSpec characterAtIndex: 0]))
       // Last character in szSpec must be ')' or ']' or '}'
       || ((')' != [szSpec characterAtIndex: [szSpec length] - 1])
           && (']' != [szSpec characterAtIndex: [szSpec length] - 1])
           && ('}' != [szSpec characterAtIndex: [szSpec length] - 1])
           && ('>' != [szSpec characterAtIndex: [szSpec length] - 1]))
       // '{' must with '}'
       || (('{' == [szSpec characterAtIndex: 0])
           && ('}' != [szSpec characterAtIndex: [szSpec length] - 1]))
       || (('{' != [szSpec characterAtIndex: 0])
           && ('}' == [szSpec characterAtIndex: [szSpec length] - 1]))
       // '<' must with '>'
       || (('<' == [szSpec characterAtIndex: 0])
           && ('>' != [szSpec characterAtIndex: [szSpec length] - 1]))
       || (('<' != [szSpec characterAtIndex: 0])
           && ('>' == [szSpec characterAtIndex: [szSpec length] - 1])))
    {
        ATSDebug(@"JUDGE_SPEC => Spec format is not correct . ");
        return NO;
    }
    else if('{' == [szSpec characterAtIndex:0])
        iJudgeMode	= 2;
    else if(('(' == [szSpec characterAtIndex:0])
            && (')' == [szSpec characterAtIndex: [szSpec length] - 1]))
        iJudgeMode	= 0;
    else if(('[' == [szSpec characterAtIndex:0])
            && (']' == [szSpec characterAtIndex: [szSpec length] - 1]))
        iJudgeMode	= 1;
    else if(('(' == [szSpec characterAtIndex:0])
            && (']' == [szSpec characterAtIndex: [szSpec length] - 1]))
        iJudgeMode	= 3;
    else if(('[' == [szSpec characterAtIndex:0])
            && (')' == [szSpec characterAtIndex: [szSpec length] - 1]))
        iJudgeMode	= 4;
    else if('<' == [szSpec characterAtIndex:0])
        iJudgeMode  = 5;
    
    // Judge spec
    szSpec	= [szSpec substringFromIndex:1];
    szSpec	= [szSpec substringToIndex: [szSpec length] - 1];
    arraySpec	= [szSpec componentsSeparatedByString:@","];
	//}
    // For debug by Izual_Lu on 2011-05-10
    ATSDebug(@"JUDGE_SPEC =>  value is [%@], spec is [%@], mode is [%d]",szCatchedValue,[self formatLog_transferObject:arraySpec],iJudgeMode);
	if(![self JudgeValue:szCatchedValue 
              WithLimits:arraySpec 
                    Mode:iJudgeMode])
	{
		return NO;
	}
    
	return YES;
}



// Judge spec
// Param:
//		NSDictionary	*dicSpecSettings	: Save judge settings
//			COMMON_SPEC     -> NSDictionary
//              P_LimitBlack  -> NSString   : SPEC for Black Unit. (?,?), [?,?], {?,?,?}
//              P_LimitWhite  -> NSString   : SPEC for White Unit. (?,?), [?,?], {?,?,?}
//
//			MODE			-> NSNumber*	: Default = keep case = 0, ignore case = 1
// Return:
//		Actions result
-(NSNumber*)JUDGE_SPEC:(NSDictionary*)dicSpecSettings RETURN_VALUE:(NSMutableString*)szReturnValue
{
    // Get last return value and mode
	NSString	*szCatchedValue	= [NSString stringWithFormat:@"%@",szReturnValue];
	BOOL		bCaseMode		= [[dicSpecSettings objectForKey:kFZ_Script_JudgeMode] boolValue];
    BOOL        bUnShowFlag       = [[dicSpecSettings objectForKey:@"ISNOSpec"]boolValue]; //added by lucy 2.10
    BOOL        bChangeResult   = [[dicSpecSettings objectForKey:@"NoChangeResult"]boolValue];
    BOOL bCofRet = NO;
    BOOL bMPRet  = NO;
    BOOL bExRet  = NO;
    BOOL bShowCocoPassINUI = NO;
    BOOL bJudgeResult = NO;
    NSString	*szSpec = @"{N/A}";
    
    id dicForCof = [dicSpecSettings objectForKey:kFZ_Script_JudgeCofSpec];
    if (dicForCof != nil) 
    {
        if ([dicForCof valueForKey:kFunnyZoneShowCoFONUI] == nil) 
        {
            bShowCocoPassINUI = NO;
        }else
        {
            bShowCocoPassINUI = [[dicForCof valueForKey:kFunnyZoneShowCoFONUI] boolValue];
        }
        szSpec		= [dicForCof objectForKey:m_strSpecName];
        bCofRet = [self JudgeSpec:szSpec return_value:szCatchedValue caseInsensitive:bCaseMode];
        [m_dicMemoryValues setObject:szSpec forKey:kFZ_Cof_TestLimit];
        [m_dicMemoryValues setObject:[NSNumber numberWithBool:bCofRet] forKey:@"Cof_Result"];
        [m_dicMemoryValues setObject:[NSNumber numberWithBool:bShowCocoPassINUI] forKey:kFunnyZoneShowCoFONUI];
    }
    
	//NSDictionary *dicJudgeCBSpec	= [dicSpecSettings objectForKey:kFZ_Script_JudgeCBSpec];// Added by Lorky 2012/03/06
    
    id dicForCommon = [dicSpecSettings objectForKey:kFZ_Script_JudgeCommonSpec];
    if (dicForCommon != nil)
    {          
        //else common spec judge, defualt spec name is P_LimitBlack.
        szSpec		= [dicForCommon objectForKey:m_strSpecName];
        bMPRet = [self JudgeSpec:szSpec return_value:szCatchedValue caseInsensitive:bCaseMode];
        //[m_dicMemoryValues setObject:szSpec forKey:kFZ_TestLimit];
        if (!bMPRet) 
        {
            [m_dicMemoryValues setObject:[NSNumber numberWithBool:NO] forKey:kFZ_Script_TestResult];
        }
        else
        {
            [m_dicMemoryValues setObject:[NSNumber numberWithBool:YES] forKey:kFZ_Script_TestResult];
        }
        if (!bUnShowFlag)
        {
            [m_dicMemoryValues setObject:szSpec forKey:kFZ_MP_TestLimit];
        }//modify by lucy 2.10
        else
        {
            // Marked by stephen 2012,4,26 , out of logic
            //[m_dicMemoryValues setObject:@"{N/A}" forKey:kFZ_MP_TestLimit];
        }
        if (!bChangeResult) 
        {
             [m_dicMemoryValues setObject:[NSNumber numberWithBool:bMPRet] forKey:@"MP_Result"];
        }
        else
        {
            if (nil == [m_dicMemoryValues objectForKey:@"MP_Result"])
            {
                [m_dicMemoryValues setObject:[NSNumber numberWithBool:YES] forKey:@"MP_Result"];
            }
        }
        
	}
    
    if (!bUnShowFlag) 
    {
        if (!bMPRet && dicForCof != nil) 
        {
            szSpec		= [dicForCof objectForKey:m_strSpecName];
        }
        [m_dicMemoryValues setObject:szSpec forKey:kFZ_TestLimit];
        //[m_dicMemoryValues setObject:[NSNumber numberWithBool:YES] forKey:kFZ_Script_TestResult];
    }
    
    //2012 7 16 torres add for MagnetSpine exception spec
    bJudgeResult = bCofRet||bMPRet;
    id dicForException = [dicSpecSettings objectForKey:kFZ_Script_JudgeExceptionSpec];
    if ((dicForException != nil) && (YES != bJudgeResult)){
        NSLog(@"torres run exception judge spec!");
        szSpec = [dicForException objectForKey:m_strSpecName];
        NSInteger maxCount =  (nil == [dicForException objectForKey:kFZ_Script_JudgeMaxAppearCount])? 2 :[[dicForException objectForKey:kFZ_Script_JudgeMaxAppearCount] intValue];
        
        bExRet = [self JudgeSpec:szSpec return_value:szCatchedValue caseInsensitive:bCaseMode];
        
        [m_dicMemoryValues setObject:[NSNumber numberWithBool:bExRet] forKey:kFZ_Script_TestResult];
        
        if (bExRet) {
            m_exceptCount++;
            if (maxCount < m_exceptCount) {
                [m_dicMemoryValues setObject:[NSNumber numberWithBool:NO] forKey:kFZ_Script_TestResult];
                return [NSNumber numberWithBool:NO];
            }else{
                NSString *szCurrentName = [m_dicMemoryValues objectForKey:kFunnyZoneCurrentItemName];
                NSString *szTansferSpec = [szSpec stringByReplacingOccurrencesOfString:kFunnyZoneComma withString:kIADeviceALSFileNameLink];
                szCurrentName = [NSString stringWithFormat:@"%@_%@",szCurrentName,szTansferSpec];
                [m_dicMemoryValues setObject:szCurrentName forKey:kFZ_UI_SHOWNNAME];
                if (!bUnShowFlag){
                    [m_dicMemoryValues setObject:szSpec forKey:kFZ_TestLimit];
                    [m_dicMemoryValues setObject:szSpec forKey:kFZ_MP_TestLimit];
                }else{
                    // nil
                }
            }
            [m_dicMemoryValues setObject:[NSNumber numberWithBool:YES] forKey:@"MP_Result"];
        }
        return [NSNumber numberWithBool:bExRet];
    }
   
	return [NSNumber numberWithBool:bJudgeResult];
}

// Save catched values to dictionary with given key
// Param:
//		NSDictionary	*dicMemoryContents	: Save memory contents
//			KEY		-> NSString*	: KEY name
// Return:
//      Actions result
-(NSNumber*)MEMORY_VALUE_FOR_KEY:(NSDictionary*)dicMemoryContents RETURN_VALUE:(NSMutableString*)szReturnValue
{
    // Memory
    NSString    *szValue    = [NSString stringWithString:szReturnValue];
    [m_dicMemoryValues setObject:szValue forKey:[dicMemoryContents objectForKey:kFZ_Script_MemoryKey]];
    
    // End
    return [NSNumber numberWithBool:YES];
}

//2011-8-4 add by Gordon
// get values from dictionary with given key
// Param:
//		NSDictionary	*dicMemoryContents	: Save memory contents
//			KEY             -> NSString*	: KEY name
// Return:
//      NSMutableString *szReturnValue      : Return the value in dicMemoryValues with given Key.
// Relate:
//		NSMutableDictionary	*dicMemoryValues: Save memory values with given key
-(NSNumber*)GET_MEMORY_VALUE_FROM_KEY:(NSDictionary*)dicMemoryContents RETURN_VALUE:(NSMutableString*)szReturnValue
{
    NSString *szKey = [dicMemoryContents objectForKey:kFZ_Script_MemoryKey];
    id szValue = [m_dicMemoryValues objectForKey:szKey];
    if (szValue == nil || [szValue isEqual:@""] || [szValue isEqual:@"null"]) 
    {
        ATSDebug(@"Can't get value from dictionary of Key:%@",szKey);
         [szReturnValue setString:[NSString stringWithFormat: @"Can't get the value of the key [%@]!",szKey]];
        if ([[dicMemoryContents objectForKey:@"IgnoreKey"]boolValue]) {
            return [NSNumber numberWithBool:YES];
        }
        else
            return [NSNumber numberWithBool:NO];
    }
    if (![szValue isKindOfClass:[NSString class]])
    {
        szValue = [NSString stringWithFormat:@"%@", szValue];
    }
    [szReturnValue setString:szValue];
    return [NSNumber numberWithBool:YES];
}

// Compare some informations
// Param:
//      NSDictionary    *dicCompareSettings : A dictionary contains compare settings
//          Key         -> NSString*        : Value (The Key and Value should be add prefix: /* and suffix: */)
//          (The Value of Key and Value will be the keys of m_dicMemoryValues.)
//      NSMutableString        *szMatch           : Match information
// Return:
//      Actions result
-(NSNumber*)COMPARE:(NSDictionary*)dicCompareItems RETURN_VALUE:(NSMutableString*)szMatch
{
    // Compare
    BOOL    bResult = YES;
    NSString*    strResult;
    if (nil == dicCompareItems || (0 == [dicCompareItems count])) 
    {
        ATSDebug(@"COMPARE: dicCompareItems is nil or its count is 0");
        return [NSNumber numberWithBool:bResult];
    }
    NSMutableString *szMatchInfo    = [[NSMutableString alloc] init];
    for(NSString *szComparison in [dicCompareItems allKeys])
    {
        NSDictionary *dicComparison = [dicCompareItems objectForKey:szComparison];
        if (nil == dicComparison || (0 == [dicComparison count]))
        {
            continue;
        }
        
        NSString *szComparedValue1 = @"";
        NSString *szComparedKey1 = @"";
        NSString *szComparedValue2 = @"";
        NSString *szComparedKey2 = @"";
        
        NSArray *arrComparedKeys = [[dicComparison allKeys] sortedArrayUsingSelector:@selector(compare:)];

        if (1 == [dicComparison count])
        {
            szComparedKey1 = [arrComparedKeys objectAtIndex:0];
            szComparedValue1 = [dicComparison objectForKey:szComparedKey1];
            szComparedKey2 = @"Unit";
            szComparedValue2 = [NSString stringWithString:szMatch];
        }
        else if (2 == [dicComparison count])
        {
            if ([[dicComparison objectForKey:[arrComparedKeys objectAtIndex:0]] isEqualToString:@""]
                && [[dicComparison objectForKey:[arrComparedKeys objectAtIndex:1]] isEqualToString:@""])
            {
                ATSDebug(@"COMPARE: Comparison %@ two keys' value are empty",szComparison);
                continue;
            }
            else
            {
                if ([[dicComparison objectForKey:[arrComparedKeys objectAtIndex:0]] isEqualToString:@""]) 
                {
                    ATSDebug(@"COMPARE: Comparison key %@ value is empty",[arrComparedKeys objectAtIndex:0]);
                    szComparedKey1 = [arrComparedKeys objectAtIndex:1];
                    szComparedValue1 = [dicComparison objectForKey:szComparedKey1];
                    szComparedKey2 = [arrComparedKeys objectAtIndex:0];
                    szComparedValue2 = [NSString stringWithString:szMatch];
                }
                else if ([[dicComparison objectForKey:[arrComparedKeys objectAtIndex:1]] isEqualToString:@""])
                {
                    ATSDebug(@"COMPARE: Comparison key %@ value is empty",[arrComparedKeys objectAtIndex:1]);
                    szComparedKey1 = [arrComparedKeys objectAtIndex:0];
                    szComparedValue1 = [dicComparison objectForKey:szComparedKey1];
                    szComparedKey2 = [arrComparedKeys objectAtIndex:1];
                    szComparedValue2 = [NSString stringWithString:szMatch];
                }
                else
                {
                    szComparedKey1 = [arrComparedKeys objectAtIndex:0];
                    szComparedValue1 = [dicComparison objectForKey:szComparedKey1];
                    szComparedKey2 = [arrComparedKeys objectAtIndex:1];
                    szComparedValue2 = [dicComparison objectForKey:szComparedKey2];
                }
            }
        }
        else
        {
            ATSDebug(@"COMPARE: dicComparison %@ has more than two keys",dicComparison);
            continue;
        }
        
        BOOL bValue1 = [self TransformKeyToValue:szComparedValue1 returnValue:&szComparedValue1];
        BOOL bValue2 = [self TransformKeyToValue:szComparedValue2 returnValue:&szComparedValue2];
        if (!bValue1 || !bValue2)
        {
            bResult = NO;
        }
        if([szComparedValue1 isEqualToString:@""] && [szComparedValue2 isEqualToString:@""])
        {
            [szMatchInfo appendFormat:@"[%@<%@> != %@<%@>, the two value both are empty.]",szComparedValue1, szComparedKey1, szComparedValue2, szComparedKey2];
            bResult = NO;
        }
        else
        {
            if(![szComparedValue1 isEqualToString:szComparedValue2])
            {
                [szMatchInfo appendFormat:@"[%@<%@> != %@<%@>]",szComparedValue1, szComparedKey1, szComparedValue2, szComparedKey2];
                bResult = NO;
            }
            else
            {
                //[szMatchInfo appendFormat:@"[%@<%@> == %@<%@>]",szComparedValue1, szComparedKey1, szComparedValue2, szComparedKey2];
                // [szMatchInfo appendFormat:@"%@",szComparedValue1];//modify by stephen 2.10
                strResult = [NSString stringWithFormat:@"%@",szComparedValue1];
            }
        }

    }
    if(bResult)
        [szMatchInfo appendFormat:@"%@",strResult];
    ATSDebug(@"COMPARE => Result : %@",szMatchInfo);

    [szMatch setString:szMatchInfo];
    
    [szMatchInfo release];
    return [NSNumber numberWithBool:bResult];
}

// Upload attribute to the pudding
// Param:
//		NSDictionary	*dictUploadContents	: Upload contents
//          ATTRIBUTE   -> NSArray*     : Attribute keys.
//                                      Such as S_BUILD, BUILD_EVENT, BUILD_MATRIX_CONFIG, UNIT#
-(NSNumber*)UPLOADATTRI:(NSDictionary*)dictUploadContents RETURN_VALUE:(NSMutableString *)szReturn
{
    // Get attributes and set
    if (m_bNoUploadPDCA) {
        return [NSNumber numberWithBool:YES];
    }
    
    if (!m_bSubTest_PASS_FAIL) {
        return [NSNumber numberWithBool:NO];
    }
    
    NSArray *aryAttributes  = [dictUploadContents objectForKey:kFZ_Script_UploadAttribute];
    for(NSString *strAttributeKey in aryAttributes)
    {
        NSString    *strAttribute   = [m_dicMemoryValues objectForKey:strAttributeKey];
        if(strAttribute)
        {
            
            if ([strAttribute isEqualToString:@""] )
            {
                ATSDebug(@"UPLOADATTRI => no need set attribute for key [%@]",strAttributeKey);
                return [NSNumber numberWithBool:YES];
                
            }
            else 
            {
                [m_objPudding SetQT_Attributes:strAttribute Key:strAttributeKey];
                ATSDebug(@"UPLOADATTRI => set attribute [%@] for key [%@]",strAttribute,strAttributeKey);
            }
                  
        }
        else
        {
            ATSDebug(@"UPLOADATTRI => Attribute key [%@] missing (no value in dicMemory)",strAttributeKey);
            return [NSNumber numberWithBool:NO];
        }

    } 
    // End
    return [NSNumber numberWithBool:YES];
}

// Upload parametric to the pudding
// Param:
//		NSDictionary	*dictUploadContents	: Upload contents
-(NSNumber*)UPLOAD_PARAMETRIC:(NSDictionary*)dictUploadContents RETURN_VALUE:(NSMutableString *)szReturn
{
    
    if (m_bNoUploadPDCA) {
        return [NSNumber numberWithBool:YES];
    }
     //add by jingfu ran on 2012 04 06
    NSDate   *dateStart = [NSDate date];
    NSTimeInterval dTimeSpend = 0.0;
    BOOL     bNOWriteToCsv = YES;
    if ([dictUploadContents valueForKey:kFunnyZoneNOWriteCsvToLogFile] == nil) 
    {
        bNOWriteToCsv = YES;
    }else
    {
        bNOWriteToCsv = [[dictUploadContents valueForKey:kFunnyZoneNOWriteCsvToLogFile] boolValue];
    }
        
    //end by jingfu ran on 2012 04 06
    
    NSString *szParametricName = [dictUploadContents objectForKey:kFZ_Script_UploadParametric];
    NSString *szLowLimit = [dictUploadContents objectForKey:kFZ_Script_ParamLowLimit];
    NSString *szHighLimit = [dictUploadContents objectForKey:kFZ_SCript_ParamHighLimit];
    NSString *szUnit = [dictUploadContents objectForKey:kFZ_Script_ParamUnit];
    BOOL bTestResult = [[m_dicMemoryValues objectForKey:kFZ_Script_TestResult] boolValue];
    if ([m_dicMemoryValues objectForKey:kFZ_Script_TestResult] ==nil) 
    {
        bTestResult = YES;
    }	
    [m_objPudding SetTestItemStatus:(szParametricName==nil) ? @"" : szParametricName
                            SubItem:kFunnyZoneBlank
                          TestValue:szReturn
                           LowLimit:(szLowLimit == nil)?@"N/A":szLowLimit
                          HighLimit:(szHighLimit == nil)?@"N/A":szHighLimit
                          TestUnits:(szUnit==nil)?@"":szUnit
                            ErrDesc:@"skip"
                           Priority:m_iPriority
                         TestResult:bTestResult];
    [m_dicMemoryValues setObject:[NSNumber numberWithBool:YES] forKey:kFZ_Script_TestResult];
    
    //add by jingfu ran on 2012 04 06
    if (szLowLimit == nil || [szLowLimit isEqualToString:@""]) 
    {
        szLowLimit = @"N/A";
    }
    if (szHighLimit == nil || [szHighLimit isEqualToString:@""]) 
    {
        szHighLimit = @"N/A";
    }
    dTimeSpend = [[NSDate date] timeIntervalSinceDate:dateStart];
    NSString *strTestInfo = [NSString stringWithFormat:@"%@,%d,%@,%@,%@,%0.6fs\n",szParametricName,!bTestResult,szReturn,szLowLimit,szHighLimit,dTimeSpend];
    if (nil != [m_dicMemoryValues objectForKey:kFunnyZoneHasSubItemParameterData]) 
    {
        if (!bNOWriteToCsv) 
        {
            [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%@%@",[m_dicMemoryValues objectForKey:kFunnyZoneHasSubItemParameterData],strTestInfo] forKey:kFunnyZoneHasSubItemParameterData];
        }
        
    }else
    {
        if (!bNOWriteToCsv) 
        {
            [m_dicMemoryValues setObject:strTestInfo forKey:kFunnyZoneHasSubItemParameterData];
        }
        
    }
    //end by jingfu ran on 2012 04 06
    return [NSNumber numberWithBool:YES];
}

// Transform Hex to Int Value
// Param:
//      NSDictionary    *dicInsertItems : A dictionary contains KEY that indicates to the value in dicMemoryValues
// Return:
//      Actions result
-(NSNumber *)HEX_TO_INT:(NSDictionary *)dicInsertItems RETURN_VALUE:(NSMutableString *)szReturn
{
    UInt64 iRet = 0; 
    bool bRet = NO;
    NSScanner *scanTmp;
    NSString *szKey = [dicInsertItems valueForKey:kFZ_Script_MemoryKey];
    if(szKey!=nil)
    {
        scanTmp = [NSScanner scannerWithString:[m_dicMemoryValues valueForKey:szKey]];
        bRet = [scanTmp scanHexLongLong:&iRet];
        
    }else
    {
        scanTmp = [NSScanner scannerWithString:szReturn];
        bRet = [scanTmp scanHexLongLong:&iRet];
    }
    [szReturn setString:[NSString stringWithFormat:@"%d",iRet]];
    
    return [NSNumber numberWithBool:bRet];
}

// Wait for ms
// Param:
//      NSDictionary    *dicInsertItems    : TIME as format "ms"
// Return:
//      Actions result
-(NSNumber *)WAIT_MS:(NSDictionary *)dicInsertItems RETURN_VALUE:(NSMutableString*)szReturn
{
    int iTime = 1000*[[dicInsertItems valueForKey:kFZ_Script_WaitMS] intValue];
    usleep(iTime);
    return [NSNumber numberWithBool:YES];
}

//description : upload slot number to pdca by calling instant pudding API
//Param:
//    NSDictionary *dicInsertItems: 
// Return:
//      Actions result
-(NSNumber *)UPLOAD_SLOT_TO_PDCA:(NSDictionary *)dicInsertItems RETURN_VALUE:(NSMutableString*)szReturn
{
    if (m_bNoUploadPDCA) {
        return [NSNumber numberWithBool:YES];
    }
    NSInteger nPosition = [self GetUSB_PortNum];
    if (nPosition <= 0) 
    {
        nPosition = IP_FIXTURE_HEAD_ID_1;
    }
    if (nPosition > 6) 
    {
        nPosition = nPosition%6;
    }
    //Leehua modified for uploading fixture id , 120802
    NSInteger nFixtureID = [[m_dicMemoryValues objectForKey:@"FIXTURE_ID"] intValue];
    if (nFixtureID <= 0) 
    {
        nFixtureID = IP_FIXTURE_ID_1;
    }
    if (nFixtureID > 10) 
    {
        nFixtureID = nFixtureID%10;
    }
    //end
    //if(nPosition>=0)
    //{
    //first param (1-10), second param (1-6)
    NSInteger iRet = [m_objPudding SetTestSlotID:nFixtureID HeadId:nPosition]; 
    if ([szReturn isEqual:@""]) 
    {
        [szReturn setString:[NSString stringWithFormat:@"%d",nPosition]];
    }
    if(iRet == 0)
        return [NSNumber numberWithBool:YES];
    /*}
     else
     {
     ATSDebug(@"No UUT_Number found! Please check if the serial_number of the uartCable was changed!");
    }
     */
    return [NSNumber numberWithBool:NO];
}

//Show Result ON DUT LCM
//Param
//      NSDictionary *dicInsertItems: Contains a read command parameters and test mode
//          READ_COMMAND:RETURN_VALUE:      ->      NSDictionary*   :
//          SINGLE/MUTIL                    ->      NSString*       : Station Test Mode
// Return:
//      Actions result
-(NSNumber *)SHOW_RESULT_ON_SCREEN:(NSDictionary *)dicInsertItems RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSString *szShowType = [dicInsertItems valueForKey:kUserDefaultSingleOrMulti];
    BOOL showSecPassLogo = [[dicInsertItems valueForKey:kUserNeedShowSecondPassLogo] boolValue]; //torres add for show second pass logo in screen.
    BOOL bIsCurrentType = [[dicInsertItems objectForKey:@"ISCURRENTTYPE"]boolValue];
    if (nil == szShowType)
    {
		[szReturnValue setString:@"PASS"];
        return [NSNumber numberWithBool:YES];
    }
    NSRange range = [szShowType rangeOfString:kUserDefaultSingleMode options:NSCaseInsensitiveSearch];
    NSString *passCommand = showSecPassLogo ? [NSString stringWithString:@"pattern 1"]:[NSString stringWithString:@"pattern e"];//torres add for show second pass logo in screen.
    NSString *failCommand = @"";
    if(range.location == NSNotFound || range.length == 0 || (range.location+range.length) > [szShowType length])
    {
        failCommand = [NSString stringWithFormat:@"mipi fill %@",[m_dicMemoryValues valueForKey:kIADeviceDeviceColor]];
        ATSDebug(@"color:%@",[m_dicMemoryValues valueForKey:kIADeviceDeviceColor]);
    }else
    {
        failCommand = [NSString stringWithString:@"pattern f"];
    }
    NSDictionary *dicSubItems; 
    NSNumber *numRet;
    if(m_bFinalResult)
    {
        dicSubItems = [NSDictionary dictionaryWithObjectsAndKeys:passCommand,kFZ_Script_CommandString,kPD_Device_MOBILE, kFZ_Script_DeviceTarget,nil];
    }
    else
    {
        dicSubItems = [NSDictionary dictionaryWithObjectsAndKeys:failCommand,kFZ_Script_CommandString,kPD_Device_MOBILE, kFZ_Script_DeviceTarget,nil];             
    }
    if (bIsCurrentType) 
    {
        NSString   *szMipiOnTheScreen = [NSString   stringWithString:@"mipi on;mipi enable"];
        NSDictionary    *dicMipiCommand = [NSDictionary dictionaryWithObjectsAndKeys:szMipiOnTheScreen,kFZ_Script_CommandString,kPD_Device_MOBILE, kFZ_Script_DeviceTarget,nil];
        [self SEND_COMMAND:dicMipiCommand];
        dicMipiCommand = [dicInsertItems objectForKey:@"READ_COMMAND:RETURN_VALUE:"];
        [self READ_COMMAND:dicMipiCommand RETURN_VALUE:szReturnValue];
    }
    numRet = [self SEND_COMMAND:dicSubItems];
    dicSubItems = [dicInsertItems objectForKey:@"READ_COMMAND:RETURN_VALUE:"];
    numRet =[self READ_COMMAND:dicSubItems RETURN_VALUE:szReturnValue];
    if (![numRet boolValue])
    {
        ATSDebug(@"SHOW_RESULT_ON_SCREEN => Read UartData failed");
    }
    else
    {
        ATSDebug(@"SHOW_RESULT_ON_SCREEN => Read UartData :%@",szReturnValue);
    }
    return numRet;
}

// set prority,parimatric,cancelToEnd and so on
// Param:
//      NSDictionary        ->      *dicSettingItems : A dictionary contains Priority,
//                                                        whether upload parimatric,when fail whether stop 
//          NSMutableString ->      *szReturn : return value
// Return:
//      Actions result
-(NSNumber*)SET_PROCESS_STATUS:(NSDictionary*)dicSettingItems RETURN_VALUE:(NSMutableString *)szReturn;
{
    // Basic judge
    if(![dicSettingItems isKindOfClass:[NSDictionary class]])
    {
        return [NSNumber numberWithBool:NO];
    }
    
    // Set
    NSNumber *numPriority = [dicSettingItems valueForKey:kIADeviceIP_Priority];
    Boolean  bNoParametric = [[dicSettingItems valueForKey:kIADeviceIP_NoParametric] boolValue];
    Boolean bCancelToEnd = [[dicSettingItems valueForKey:kIADeviceCancelToEnd] boolValue];
    NSString *szUnit = [dicSettingItems valueForKey:kIADeviceIP_Unit];
    if(numPriority != nil)
    {
        m_iPriority = [numPriority intValue];
    }
    if (szUnit != nil) 
    {
        [m_szUnit setString:szUnit];
    }
    m_bNoParametric = bNoParametric;
    m_bCancelToEnd = bCancelToEnd;
    // For Prox-Cal P105 Nopudding
    BOOL    bP105NO_Pudding = [[self getValueFromXML:kPD_UserDefaults mainKey:@"P105NoPudding",nil] boolValue];
    if (bP105NO_Pudding && szReturn && [szReturn isEqualTo:@"0x0A"])
    {
        m_bNoUploadPDCA = bP105NO_Pudding;
    }
    return [NSNumber numberWithBool:YES];
}

//description : AM I OK?
// Param:
//      NSDictionary        ->      *dicSubSetting
// Return:
//      Actions result
-(NSNumber *)AMIOK_CHECK:(NSDictionary *)dicSubSetting RETURN_VALUE:(NSMutableString *)szReturnValue
{
    if (m_bNoUploadPDCA) {
		[szReturnValue setString:@"PASS"];
        return [NSNumber numberWithBool:YES];
    }
    
    //if not set sn, set again
    if(![self set_PDCA_SN])
    {
		[szReturnValue setString:@"FAIL"];
        return [NSNumber numberWithBool:NO];
    }
    
    NSString *strErrorMsg = @"";
    UInt8 iRet = [m_objPudding CheckAmIOKey:&strErrorMsg];
    [szReturnValue setString:strErrorMsg];
	if (kSuccessCode == iRet) {
        [szReturnValue setString:@"PASS"];
        return [NSNumber numberWithBool:YES];
    }
    else
    {
        NSPanel *Panel = NSGetAlertPanel(@"Am I OK Error", strErrorMsg, @"OK", nil, nil);
        NSColor *color = [m_dicMemoryValues objectForKey:kPD_AMIOK_PanelColor];
        if (color) {
            [Panel setBackgroundColor:color];
        }
        [NSApp beginSheet:Panel modalForWindow:nil modalDelegate:self didEndSelector:nil contextInfo:nil];
        [NSApp runModalForWindow:Panel];
        [NSApp endSheet:Panel];
        [Panel orderOut:nil];
        return [NSNumber numberWithBool:NO];
    }
}

// Description  :   save now time to dic
// Param:
//      NSDictionary        ->      *dicSubSetting
// Return:
//      Actions result
-(NSNumber *)SAVE_NOWTIME:(NSDictionary *)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue
{
    [m_dicMemoryValues setObject:[[NSDate date] descriptionWithCalendarFormat:@"%Y%m%d%H%M%S" timeZone:nil locale:nil]  forKey:kFZ_NowTime];
    return [NSNumber numberWithBool:YES];
}

// 2011.07.18 Add By Ming
// Descripiton:
// Copy Function From Magic "CHECK_N92_LIVE"
// Rename to Check_DUT_Alive
// Param:
// NSDictionary    *dicDUTContents  : Contains insert contents
// TARGET  -> NSString*    : Target you want to open. {MOBILE, FIXTURE, LIGHTMETER, ...}
// TIMEOUT     -> NSNumber*    : Insert time out. (Can be nil). Default = 3s

-(NSNumber*)CHECK_DUT_ALIVE:(NSDictionary *)dicDUTContents RETURN_VALUE:(NSMutableString*)strReturnValue;
{
	// Get Check_DUT_Alive settings
    NSString            *szPortType = [dicDUTContents valueForKey:kFZ_Script_DeviceTarget];
    PEGA_ATS_UART       *uartObj	= [[m_dicPorts objectForKey:szPortType] objectAtIndex:kFZ_SerialInfo_UartObj];
    NSString            *szTX       = kPD_DeviceSet_Try;
    double             dReadTimeOut = kUart_CommandTimeOut;
    if(nil != [dicDUTContents objectForKey:kFZ_Script_ReceiveTimeOut])
    {
        dReadTimeOut    = [[dicDUTContents objectForKey:kFZ_Script_ReceiveTimeOut] doubleValue];
    }
    [uartObj Clear_UartBuff:kUart_ClearInterval TimeOut:dReadTimeOut readOut:nil];
    ATSDebug(@"Clear buffer ---> %@",szPortType);
    // Send string command
    //[uartObj Write_UartCmd_WithSting:szTX];
    [uartObj Write_UartCommand:szTX PackedNum:1 Interval:0 IsHex:NO];
    ATSDebug(@"Write to ---> %@ , command[%@(%@)]",szPortType,szTX,kFZ_Script_CommandString);
    NSMutableString    *strRead=[[NSMutableString alloc] initWithString:@""];
    UInt16 iRet = [uartObj Read_UartData:strRead TerminateSymbol:[NSArray arrayWithObjects:kPD_DeviceSet_Expect, nil] MatchType:kUart_MatchAllItems IntervalTime:kUart_IntervalTime TimeOut:dReadTimeOut];
    ATSDebug(@"Read from <--- %@ , %@",szPortType,strRead);   
    
    if(iRet == kUart_SUCCESS)
    {
        [strRead release];
        return [NSNumber numberWithBool:YES];
    } 
    if ([szPortType isEqualToString:kPD_Device_MOBILE]) 
    {
        NSRange range1 = [strRead rangeOfString:@"]"];
        NSRange range2 = [strRead rangeOfString:@")"];
        NSRange range3 = [strRead rangeOfString:@":"];
        NSRange range4 = [strRead rangeOfString:@"="];
        NSRange range5 = [strRead rangeOfString:@"-"];
        if(((NSNotFound !=range1.location) && range1.length > 0 && (range1.location+range1.length) <= [strRead length])|| ((NSNotFound !=range2.location) && range2.length > 0 && (range2.location+range2.length) <= [strRead length])
           || ((NSNotFound !=range3.location) && range3.length > 0 && (range3.location+range3.length) <= [strRead length]) || ((NSNotFound !=range4.location) && range4.length > 0 && (range4.location+range4.length) <= [strRead length])
           || ((NSNotFound !=range5.location) && range5.length > 0 && (range5.location+range5.length) <= [strRead length]))
        {
            szTX   = @"diags";
            //[uartObj Write_UartCmd_WithSting:szTX];
            [uartObj Write_UartCommand:szTX PackedNum:1 Interval:0 IsHex:NO];
            [self CHECK_DUT_ALIVE:dicDUTContents RETURN_VALUE:strReturnValue ];
        }        
    }
    
    [strRead release];
    return [NSNumber numberWithBool:NO];
}

//  set SN to m_szISN when we get sn from UNIT
// Param:
//      NSDictionary        ->      *dicSubSetting
// Return:
//      Actions result
-(NSNumber *)GET_SN:(NSDictionary *)dicSubSetting RETURN_VALUE:(NSMutableString *)szReturnValue
{
	NSRange range = [szReturnValue rangeOfString:@"RX [sn]"];
    NSString *szResult = [NSString stringWithString:szReturnValue];
    if(NSNotFound != range.location && range.length >0 && (range.length +range.location) <= [szReturnValue length])
    {
        szResult = @"null";
    }
    else
    {
        // 2012.2.20 Desikan 
        //      Prox-Cal show ready bug(finished test,before plug out unit,ui show READY,but not PASS/FAIL),
        //      get SN from Fonnyzone
        NSDictionary *dicISNFromUnit    =   [NSDictionary dictionaryWithObjectsAndKeys:szResult,@"ISNFromUnit", nil];
        NSNotificationCenter    *nc     =   [NSNotificationCenter defaultCenter];
       [nc postNotificationName:PostDataToMuifaNote object:self userInfo:dicISNFromUnit];
    }
    [self setMobileSerialNumber:[NSString stringWithString:szResult]]; 
    if([self set_PDCA_SN])
    {
        return [NSNumber numberWithBool:YES];
    }
    else
    {
        return [NSNumber numberWithBool:NO];
    } 
}

// Get DUT syscfg from m_szLastValue
// Param:
//      NSDictionary    *dicInsertItems     : The item you want to get
//          CFGKEY      -> NSString*        : System config Key
// Return:
//      Actions result
-(NSNumber *)GET_SYSCFG:(NSDictionary *)dicInsertItems RETURN_VALUE:(NSMutableString*)szReturn
{
    bool bRet = NO;
    NSString *szValue = [NSString stringWithFormat:@"%@",szReturn];
    NSString *szParKey = [NSString stringWithFormat:@"%@: ",[dicInsertItems valueForKey:kIADeviceSysCfgKey]];
    if(szParKey!=nil)
    {
        NSRange rangeHead = [szValue rangeOfString:szParKey options:NSCaseInsensitiveSearch];
        if (rangeHead.location == NSNotFound || rangeHead.location+rangeHead.length > [szValue length] || rangeHead.length == 0)
        {
            return [NSNumber numberWithBool:NO];
        }
        NSString *szLeft = [szValue substringFromIndex:rangeHead.location+rangeHead.length];
        rangeHead = [szLeft rangeOfString:@"\n"];
        
        if (rangeHead.location == NSNotFound || rangeHead.location+rangeHead.length > [szLeft length] || rangeHead.length == 0)
        {
            return [NSNumber numberWithBool:NO];
        }
        szLeft = [szLeft substringToIndex:rangeHead.location];
        szLeft = [szLeft stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        //NSUInteger totalLen = [szValue length];
        //NSRange rangeSearch = NSMakeRange(rangeHead.location,(totalLen-rangeHead.location));
        //NSRange rangeEnd = [szValue rangeOfString:@"\n" options:NSCaseInsensitiveSearch range:rangeSearch];
        //*szReturn = [szValue substringWithRange:NSMakeRange(rangeHead.location+[szParKey length], (rangeEnd.location-rangeHead.location))];
        if (szLeft != nil) {
            [szReturn setString:szLeft];
            bRet = YES;
        }        
    }
    return [NSNumber numberWithBool:bRet];
}

// calculator result of one expression
//2012-4-16 add note by Sunny
//		calculator result of one expression
// Parameter:
//      NSDictionary        dicExpression : expression which need to calculate
// Return:
//      Actions result
-(NSNumber *)CALCULATOR:(NSDictionary *)dicExpression RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSString *szExpression = [dicExpression objectForKey:@"Expression"];
    NSString *szOutExpression = @"";
    BOOL bRet = [self TransformKeyToValue:szExpression returnValue:&szOutExpression];
    BOOL bIgnoreNA = [[dicExpression objectForKey:@"IgnoreNA"] boolValue];
	NSRange range = [szOutExpression rangeOfString:kFZ_99999_Value_Issue];
    if (((NSNotFound != range.location) && (szOutExpression != nil) && ([szOutExpression length]>=(range.location+range.length))&&(range.length>0))) {
        [szReturnValue setString:kFZ_99999_Value_Issue];
        ATSDebug(@"-99999issue");
        // If it need to ignore NA, it will return YES, otherwise it return NO
		// Modified for Development 1 & development 3.
		// Modified by Lorky in Cpto 2012-05-08
        return [NSNumber numberWithBool:(NO || bIgnoreNA)];        
    }
	
    if (bRet) 
    {
        bRet = [m_mathLibrary Calculater:&szOutExpression];
        if (bRet) 
        {   
			// Modified by Lorky on 2012-05-01 in Cpto
			if ([dicExpression objectForKey:@"DecimalPlaces"])
			{
				NSUInteger iDecimalPlaces = [[dicExpression objectForKey:@"DecimalPlaces"] intValue];
				[szReturnValue setString:[NSString stringWithFormat:@"%.*f",iDecimalPlaces,[szOutExpression floatValue]]];
			}
			else
				[szReturnValue setString:szOutExpression];
        }
        else
        {
            ATSDebug(@"CALCULATOR : ==> unexpected result : %@",szOutExpression);
            [szReturnValue setString:@"NA"];
        }
    }
    else
    {
        ATSDebug(@"CALCULATOR : ==> Can't find parameters of expression @",szExpression);
    }       
    return [NSNumber numberWithBool:bRet];            
}

/*
 //Added  by kyle 2011/11/10
 @method	 TransformHexTocharacter:
 @abstract   Change Hex to character
 @result	 
 @param:      
 NSString *szBuf : save m_szReturnValue
 NSArray *arrHa  : save numbers which be comparted by blank
 */
- (NSNumber *)TransformHexTocharacter:(NSDictionary*)dicPara RETURN_VALUE:(NSMutableString*)szReturnValue
{
    NSString *szBuf = [NSString stringWithString:szReturnValue];
	NSArray *arrHa = [szBuf componentsSeparatedByString:@" "];	
    NSInteger iCount = [arrHa count];
    char *cResult = (char *)malloc(iCount);
    bzero(cResult, iCount);
    
    NSScanner *scaner;
	unsigned int uiValue;
	for(int i=0; i<iCount; i++)
	{
		NSString *szbuf = [arrHa objectAtIndex:i];
		scaner = [NSScanner scannerWithString:szbuf];
		bool bResult = [scaner scanHexInt:&uiValue];
		if(bResult)
			*(cResult+i) = uiValue;
	}
    [szReturnValue setString:[NSString stringWithFormat:@"%s",cResult]];
    free(cResult);
    return [NSNumber numberWithBool:YES];
}

/*
 //Added  by kyle 2011/11/11
 @method	 JUDGE_SPEC_CANCEL:RETURN_VALUE:
 @abstract   Cancel Items
 @result	 
 @param:      
 BOOL flag        : Is szReturnValue content condition form dicPara ? YES : NO
 BOOL cancelFlag  : get value from dicPara : checked is YES / unchecked is NO
 @description:
 When szReturnValue content condition form dicPara and canceFlag is NO 
 then it will cancel items
 */
- (NSNumber *)JUDGE_SPEC_CANCEL:(NSDictionary*)dicPara RETURN_VALUE:(NSMutableString*)szReturnValue
{
    BOOL flag         = [[self JUDGE_SPEC:dicPara RETURN_VALUE:szReturnValue] boolValue];
    BOOL cancelFlag   = [[dicPara valueForKey:kFZ_Script_CancelFlag] boolValue];
    BOOL  bRetFlag = [[dicPara valueForKey:@"RETURNCONTROL"]boolValue];
    [m_dicMemoryValues setObject:@"{N/A}" forKey:kFZ_TestLimit];
    if (flag ^ cancelFlag) 
    {
        m_bCancelFlag = YES;
    }
    if (bRetFlag)
    {
        return [NSNumber numberWithBool:(!m_bCancelFlag)];//if m_bCancelFlag is YES,some subitems bellow will cancel,this result may should return no
    }
    return [NSNumber numberWithBool:YES];
}

/*
 //Added  by kyle 2011/11/11
 @method	 CHANGE_RETURNVALUE_TO_PASS_FAIL:RETURN_VALUE:
 @abstract   change returnValue to PASS or FAIL
 @result	 
 */
- (NSNumber *)CHANGE_RETURNVALUE_TO_PASS_FAIL:(NSDictionary*)dicPara RETURN_VALUE:(NSMutableString*)szReturnValue
{
    NSString *szPASS = [dicPara valueForKey:@"SZ_PASS"];
    NSString *szFAIL = [dicPara valueForKey:@"SZ_FAIL"];
    NSDictionary *dicKeyTemp = [dicPara objectForKey:@"KEY"];
    NSString *szTemp = [dicKeyTemp valueForKey:@"FORMAT"];
    BOOL    b_PassSubTestItem = [[dicKeyTemp valueForKey:@"PASSSUBTESTITEM"]boolValue];
    if (m_bSubTest_PASS_FAIL && szPASS) 
    {
        [szReturnValue setString:szPASS];
    }
    
    if ((!m_bSubTest_PASS_FAIL) && szFAIL)
    {
        [szReturnValue setString:szFAIL];
    }
    
    if ((!m_bLastItemResult) && b_PassSubTestItem && szTemp)                            //For some cases that we didn't catch the right vale, but can ignore. eg.current "LOG" issue.   m_bLastItemResult should be CATCH_VALUE return value.
    {
        NSString *szRetValueTemp = [m_dicMemoryValues valueForKey:@"MOBILE_CATCH"];
        if (NSNotFound != [szRetValueTemp rangeOfString:szTemp].location)
        {
            [szReturnValue setString:@"NA"];
            m_bSubTest_PASS_FAIL = YES;
            [m_dicMemoryValues setObject:[NSNumber numberWithBool:YES] forKey:@"Cof_Result"];//modify for Current 
            [m_dicMemoryValues setObject:[NSNumber numberWithBool:YES] forKey:@"MP_Result"];
        }
    }
    return [NSNumber numberWithBool:YES];
}

/*
 * kyle 2011.11.18
 * method:     GetExtremeValue:RETURN_VALUE:
 * abstract:   get max or min value
 * key:
 *             MAX             : if checked ==> get max value else ==> get min value
 *             Expression      : key of number
 *             ExpressionArray : key of array any number in
 */
- (NSNumber *)GetExtremeValue:(NSDictionary*)dictSettings RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSString *szExpression       = [dictSettings objectForKey:@"Expression"];
    NSString *szExArrayName      = [dictSettings objectForKey:@"ExpressionArray"];
    NSArray *arrayExpression     = szExArrayName?[szExArrayName componentsSeparatedByString:@","]:nil;
    // max value or min value
    BOOL MAX                     = [[dictSettings objectForKey:@"MAX"] boolValue];
    NSString *szOutExpression    = @"";
    NSMutableString *szMutable   = [NSMutableString stringWithString:@""];
    
    if (!szExpression) 
    {
        BOOL bRet                = [self TransformKeyToValue:szExpression returnValue:&szOutExpression];
        if (bRet) 
        {
            [szMutable appendString:szOutExpression];
        }
    }
    
    for (int iCount = 0; iCount<[arrayExpression count]; iCount++) {
        NSString *szArrayName = [[arrayExpression objectAtIndex:iCount] stringValue];
        if (![[m_dicMemoryValues objectForKey:szArrayName] isKindOfClass:[NSArray class]]) {
            ATSDebug(@"Array Error!");
            return [NSNumber numberWithBool:NO];
        }
        NSArray *aryTemp         = [m_dicMemoryValues objectForKey:szArrayName];
        for (int i = 0; i<[aryTemp count]; i++) {
            if ([szMutable length]) 
            {
                [szMutable appendString:@","];
            }
            [szMutable appendString:[[aryTemp objectAtIndex:i] stringValue]];
        }
    }
    
    if ([szMutable length]) 
    {
        NSArray *arry = [[[NSString stringWithString:szMutable] stringByReplacingOccurrencesOfString:@" " withString:@""] componentsSeparatedByString:@","];
        
        // check format of all number in array
        float fResult;
        NSMutableArray *muArry = [NSMutableArray arrayWithArray:nil];
        for(int j = 0; j<[arry count]; j++)
        {
            NSScanner *scanner = [NSScanner scannerWithString:[arry objectAtIndex:j]];
            if(!([scanner scanFloat:&fResult] && [scanner isAtEnd]))
            {
                ATSDebug(@"Expression error!");
                return [NSNumber numberWithBool:NO];
            }
            [muArry insertObject:[NSNumber numberWithFloat:[[arry objectAtIndex:j] floatValue]] atIndex:j];
        }
        // get extreme value
        // array sorting by ascending
        arry = [[NSArray arrayWithArray:muArry] sortedArrayUsingSelector:@selector(compare:)];
        
        if (MAX) {
            [szReturnValue setString:[NSString stringWithFormat:@"%0.4f",[[arry objectAtIndex:[arry count]-1] floatValue]]];
        }else{
            [szReturnValue setString:[NSString stringWithFormat:@"%0.4f",[[arry objectAtIndex:0] floatValue]]];
        }
    }else{
        ATSDebug(@"CALCULATOR :  ==> Can't find parameters of expression");
        return [NSNumber numberWithBool:NO];
    }
    return [NSNumber numberWithBool:YES];
}

/*
 // kyle 2011.11.11  
 // copy function: 
 -(BOOL)CatchValuebyRowAndColumn:(NSDictionary*)dicpara ReturnValue:(NSString **)szReturnValue
 from maggic 
 
 2012-04-17 Add remark by Stephen
 Function:       Catch some value by a certain row and column.
 Description:    This function can make u easy to catch value by a certain row and column from a matrix.
          eg:       row:    3
                    col:    5
                 matrix:    xxxxxxx
                            xxxxxxx
                            xxxxoxx
                            xxxxxxx
 Para:           (NSDictionary*)dicpara --> contain the row, col and so on. 
                 (NSMutableString *)szReturnValue --> The value which would write in csv and show on UI.
 Return:         If exist the certain value in the matrix and can catch return YES, else return NO.
 */
-(NSNumber *)CatchValuebyRowAndColumn:(NSDictionary*)dicpara RETURN_VALUE:(NSMutableString *)szReturnValue
{
    SelectRect  rectselect;
    NSString    * szStart;
    NSString    * szEnd;
    NSString    * szIndex;
    NSArray     * arrReturn;
    NSArray     * arrTemp;
    NSDictionary * dicArray= [dicpara valueForKey:@"CatchArray"];
    NSString    * szReturn;
    NSString    * szCharacter=[dicpara valueForKey:@"character"];
    
    NSString    *szKey = [dicpara objectForKey:kFZ_Script_MemoryKey];
    NSString	*szCatchedValue	= [m_dicMemoryValues objectForKey:szKey];
    if(nil == szCatchedValue)
    {
        szCatchedValue = @"Value not found";
        szReturn    =   @"";
    }
    else if([szCatchedValue ContainString:@"RX ["])
    {
        szReturn    =   @"";
    }
    else
    {
        szReturn    =   [szCatchedValue stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    }
    NSArray     * arrRow=[szReturn componentsSeparatedByString:@"\n"];
    int iRow, iColumn , iIndex;
    bool bData = NO;
    if(nil!= [dicpara valueForKey:@"IsNumber"])
    {
        bData = [[dicpara valueForKey:@"IsNumber"] boolValue];
    }
    if(nil == dicArray)            //return string value by Row and Column
    {
        if([dicpara valueForKey:@"ROW"] && [dicpara valueForKey:@"COLUMN"])
        {
            iRow    =[[dicpara valueForKey:@"ROW"] intValue];
            iColumn =[[dicpara valueForKey:@"COLUMN"] intValue];
            ATSDebug(@"row is %d; column is %d",iRow,iColumn);
            
            if (abs(iRow) < [arrRow count])
            {
                int iRowTemp = (iRow < 0)?([arrRow count] + iRow):iRow;             //judge whether to catch forword or backward.
                NSArray * arrColumn =[[arrRow objectAtIndex:iRowTemp] componentsSeparatedByString:szCharacter];
                if (iColumn < [arrColumn count])
                {
                    [szReturnValue setString:[arrColumn objectAtIndex:iColumn]];
                    ATSDebug(@"return value:%@",szReturnValue);
                    return [NSNumber numberWithBool:YES];
                }
                else
                {
                    ATSDebug(@"the iColumn%i > the count %i",iColumn,[arrColumn count]);
                }
            }

        }
        if (bData)
        {
            [szReturnValue setString:kFZ_99999_Value_Issue];
            ATSDebug(@"-99999issue");
            return [NSNumber numberWithBool:NO];
        }
        else
        {
            [szReturnValue setString:szCatchedValue];
            return [NSNumber numberWithBool:NO];
        }
        
    }
    else                  // return an array
    {
        NSMutableArray *mutableArr = [[NSMutableArray alloc]init];
        szReturn    =[dicArray valueForKey:@"Return"]; 
        szStart     =[dicArray valueForKey:@"Start"];
        szEnd       =[dicArray valueForKey:@"End"];
        szIndex     =[dicArray valueForKey:@"Index"];
        if([szReturn isEqualToString:@"Row"])   // return an array by row
        {
            if(nil == szIndex)
            {
                ATSDebug(@"Index does not have value");
                [mutableArr release];
                return [NSNumber numberWithBool:NO];
            }
            iIndex      =[szIndex intValue];
            if(iIndex>=[arrRow count])                      //if the index is too large， return no
            {
                ATSDebug(@"Index value is too large");
                [mutableArr release];
                return [NSNumber numberWithBool:NO];
            }
            arrTemp     =[[arrRow objectAtIndex:iIndex] componentsSeparatedByString:szCharacter];
            rectselect.startRow =(szStart   != nil && ![szStart isEqualTo:@""])? [szStart intValue]:1; // startFrom
            rectselect.endRow   =(szEnd     != nil && ![szEnd isEqualTo:@""])? [szEnd intValue]:[arrTemp count];// endwith
            ATSDebug(@"index is :%d ; start: %d ; end: %d ",iIndex,rectselect.startRow,rectselect.endRow);
            if(rectselect.startRow > rectselect.endRow || rectselect.endRow > [arrTemp count]|| rectselect.endRow<=0)
            {
                ATSDebug(@"EndRow value is too large or End Row can not be 0");
                [mutableArr release];
                return  [NSNumber numberWithBool:NO];
            }
            for(;rectselect.startRow <= rectselect.endRow;rectselect.startRow++)  //add the value from StartRow to endRow into MutableArray
            {     
                [mutableArr addObject:[arrTemp objectAtIndex:rectselect.startRow-1]];
            }
            arrReturn   = mutableArr;
            [szReturnValue setString:[NSString stringWithFormat:@"%@",arrReturn]];
            [mutableArr release];
            return [NSNumber numberWithBool:YES];
        }
        if([szReturn isEqualToString:@"Column"])  // return an array by column
        {
            if(nil  ==  szIndex )
            {
                [mutableArr release];
                ATSDebug(@"Index does not have value");
                return [NSNumber numberWithBool:NO];
            }
            iIndex      = [szIndex intValue];
            rectselect.startColumn  = (szStart  != nil && ![szStart isEqualTo:@""])?[szStart intValue]:1;
            rectselect.endColumn    = (szEnd    != nil && ![szEnd isEqualTo:@""])? [szEnd intValue]:[arrRow count]-2;
            ATSDebug(@"index is :%d ; start: %d ; end: %d ",iIndex,rectselect.startColumn,rectselect.endColumn);
            if(rectselect.startColumn > rectselect.endColumn || rectselect.endColumn >=[arrRow count])
            {
                ATSDebug(@"EndRow value is too large");
                [mutableArr release];
                return [NSNumber numberWithBool:NO];
            }
            for(;rectselect.startColumn <= rectselect.endColumn;rectselect.startColumn++)  // add the value from StartColumn to EndColumn into MutableArrary
            {
                arrTemp     = [[arrRow objectAtIndex:rectselect.startColumn]componentsSeparatedByString:szCharacter];
                if(iIndex >= [arrTemp count])               //if the index is too large， return no
                {
                    ATSDebug(@"Index value is too large");
                    [mutableArr release];
                    return [NSNumber numberWithBool:NO];
                }
                [mutableArr addObject:[arrTemp objectAtIndex:iIndex-1]];
            }
            arrReturn   = mutableArr;
            [szReturnValue setString:[NSString stringWithFormat:@"%@",arrReturn]];
            [mutableArr release];
            return [NSNumber numberWithBool:YES];
        }
        [mutableArr release];
        return [NSNumber numberWithBool:NO];
    }
}

/*
 2012-04-17 Add remark by Stephen
 Function:       Convert from char type to int type.
 Description:    Convert from char type to int type based on the following rule(PS: the char int value is from ASCII mapping table). 
                 '0'-'9' -> 0-9
                 'A'-'Z' -> 10-35
                 'a'-'z' -> 10-35
 Para:           (char)cChar --> the char need to convert, case ignored.
 Return:         If the para is in the [0,9],[A,Z],[a,z], return the converted int value, else return -1.
 */
-(int)Char2Int:(char)cChar
{
	if((cChar >= '0')	// 48
	   && (cChar <= '9'))	// 57
		return (cChar - 48);
	else if((cChar >= 'A')	// 65
			&& (cChar <= 'Z'))	// 90
		return (cChar - 55);
	else if((cChar >= 'a')	// 97
			&& (cChar <= 'z'))	// 122
		return (cChar - 87);
	else
		return -1;
}

/*
 2012-04-17 Add remark by Stephen
 Function:       Convert from int type to char type.
 Description:    Convert from int type to char type based on the following rule(PS: based on the ASCII mapping table, delete 'I' and 'O')
                 0-9   -> '0'-'9'
                 10-34 -> 'A'-'Z' 
 Para:           (int)iInt --> the int need to convert, only to capital letter.
 Return:         The capital letter converted from int para.
 */
-(NSString*)Int2Char:(int)iInt
{
	if((iInt >= 0) && (iInt <= 9))
		return [NSString stringWithFormat:@"%d",iInt];
	else if ((iInt > 17) && (iInt < 23))
		return [NSString stringWithFormat:@"%c",iInt + 56];// delete letter "I,O"  add by kuro 2011/09/15
    else if ((iInt > 22) && (iInt < 34))
        return [NSString stringWithFormat:@"%c",iInt + 57]; // delete letter "I,O"  add by kuro 2011/09/15
    else 
        return [NSString stringWithFormat:@"%c",iInt + 55];
}

/*
 //Added  by Kyle 2011/11/11
 @method	 NumberSystemConvertion:RETURN_VALUE:
 @abstract   binary system、decimal system and hexadecimal system convert each other.     
 @result	
 @key:
 CHANGE   : before convert with format
 TO       : after convert with format
 FROM     : which bit need to start convert
 LENGTH   : how long will be convert
 */
- (NSNumber *)NumberSystemConvertion:(NSDictionary*)dictSettings RETURN_VALUE:(NSMutableString *)szReturnValue
{
	// Basic judgement
	if((![dictSettings isKindOfClass:[NSDictionary class]]) 
	   || (![szReturnValue isKindOfClass:[NSString class]]))
	{
		ATSDebug(@"Invalid settings or source");
		return [NSNumber numberWithBool:NO];
	}
	NSString	*strSource	= [NSString stringWithString:szReturnValue];
	strSource	            = [strSource stringByReplacingOccurrencesOfString:@" " withString:@""];
	strSource	            = [strSource stringByReplacingOccurrencesOfString:@"\r" withString:@""];
	strSource	            = [strSource stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	
	// Get properties
	int		iSourceSystem	= ([[dictSettings objectForKey:@"CHANGE"] isKindOfClass:[NSNumber class]])?[[dictSettings objectForKey:@"CHANGE"] intValue]:16;	// Default source number system is Hex
	int		iTargetSystem	= ([[dictSettings objectForKey:@"TO"] isKindOfClass:[NSNumber class]])?[[dictSettings objectForKey:@"TO"] intValue]:10;	// Default target number system is Dec
	int		iOffset			= [[dictSettings objectForKey:@"OFFSET"] isKindOfClass:[NSNumber class]]?[[dictSettings objectForKey:@"OFFSET"] intValue]:0;	// Default offset is 0
	unsigned long	ulBegin	= [[dictSettings objectForKey:@"FROM"] isKindOfClass:[NSNumber class]]?[[dictSettings objectForKey:@"FROM"] unsignedLongValue]:0;	// Default begin location is 0
	unsigned long	ulLength= [[dictSettings objectForKey:@"LENGTH"] isKindOfClass:[NSNumber class]]?[[dictSettings objectForKey:@"LENGTH"] unsignedLongValue]:([strSource length]-ulBegin);	// Default length is source length added by winter for show the right message 2.10
	if((iSourceSystem < 2)
	   || (iSourceSystem > 34)
	   || (iTargetSystem < 2)
	   || (iTargetSystem > 34))
	{
		ATSDebug(@"Invalid number system, source [%d], target [%d]", 
				 iSourceSystem, iTargetSystem);
		return [NSNumber numberWithBool:NO];
	}
	if((ulBegin + ulLength) > [strSource length])
	{
		ATSDebug(@"[%lu] + [%lu] Beyond length [%u]",
				 ulBegin, ulLength, [strSource length]);
		return [NSNumber numberWithBool:NO];
	}
	
	// Cut
	NSRange	range;
    NSString	*strCut;
	//range.location	= [strSource length] - ulBegin - ulLength;
    range.location = ulBegin;//modify by lucy 
	range.length	= ulLength;
    if ([strSource length] >= (ulLength+ulBegin))
    {
       strCut = [strSource substringWithRange:range];
    }
    else
    {
        ATSDebug(@"Get unexpected return value or mess code");
        return [NSNumber numberWithBool:NO];
    }
	
	// Convert to dec
	int	Dec	= 0;
    bool bFlag = NO;
	for(int i=[strCut length] - 1; i>=0; i--)
	{
		int Digit	= [self Char2Int:[strCut characterAtIndex:i]];
		if((Digit < 0)
		   || (Digit >= iSourceSystem))
		{   
            //continue;
            bFlag =NO;
            break;
		}
      
		Dec	+= (int)(Digit * pow(iSourceSystem, [strCut length] - i - 1));
        bFlag =YES;
	}
    //added by lucy 11.12.19 for if the return value is invalid value we will show the message.
    if (!bFlag)
    {
        //[szReturnValue setString:@"Invalid Number System"];
         ATSDebug(@"Invalid Number System");//modify by winter
        return [NSNumber numberWithBool:NO];
    }
    
	// Offset
	Dec += iOffset;
	
	// Convert to target system
	NSString	*strResult	        = @"";
	while(Dec >= iTargetSystem)
	{
        int	Remainder	            = Dec%iTargetSystem;
		NSString	*strRemainder	= [self Int2Char:Remainder];
		strResult	                = [NSString stringWithFormat:@"%@%@",strRemainder, strResult];
		Dec	                       /= iTargetSystem;
	}
	strResult	                    = [NSString stringWithFormat:@"%@%@", [self Int2Char:Dec], strResult];
	
	//	Hold enough places
	unsigned int	uiPlace	= [[dictSettings objectForKey:@"PLACE"] isKindOfClass:[NSNumber class]]?[[dictSettings objectForKey:@"PLACE"] unsignedLongValue]:[strResult length];	// Default place is result length
	if(uiPlace > [strResult length])
	{
		int	iLength	= [strResult length];
		for(int i=0; i<uiPlace - iLength; i++)
			strResult	= [NSString stringWithFormat:@"0%@", strResult];
	}
	else if(uiPlace < [strResult length])
		strResult	= [strResult substringFromIndex:([strResult length] - uiPlace)];
	
	// End
    [szReturnValue setString:[NSString stringWithString:strResult]];
	return [NSNumber numberWithBool:YES];
}

/*
 * Kyle 2011.12.15
 * method   : AddFaileCases:RETURN_VALUE:
 * abstract : According to the current results of judgment which case will be failed
 * key      :
 *                  CASES --> name of case will be failed
 */
- (NSNumber *)AddFaileCases:(NSDictionary*)dicSetting RETURN_VALUE:(NSMutableString *)szReturnValue
{    
    if (!m_bSubTest_PASS_FAIL) 
    {
        NSMutableArray * muArry = [dicSetting objectForKey:@"FORCE_FAIL"];
        for(NSString *szItemName in muArry)
        {
            [m_dicForceFaileCase setObject:[m_dicMemoryValues objectForKey:kFunnyZoneCurrentItemName] forKey:szItemName];
        }
    }
    return [NSNumber numberWithBool:YES];
}

/*
 2012-04-17 Add remark by Stephen
 Function:       Show pudding status.
 Description:    Show pudding status which get from the setting script on UI and in csv, NoPudding -> 0, Pudding -> 1.
 Para:           (NSDictionary *)dicInput --> No use here.
                 (NSMutableString *)szReturnValue --> Set as the pudding status value to show on UI and in csv.
 Return:         If the bool m_bIsPuddingCanceled is YES return NO, else return YES.
 */
- (NSNumber *)SHOW_PDCA:(NSDictionary *)dicInput RETURN_VALUE:(NSMutableString *)szReturnValue
{
    if (m_bNoUploadPDCA) {
        [szReturnValue setString:@"0"];
    }
    else
    {
        [szReturnValue setString:@"1"];
    }
    if(m_bIsPuddingCanceled)
    {
        return [NSNumber numberWithBool:NO];
    }
    return [NSNumber numberWithBool:YES];
}

/*
 * Kyle 2012-01-08
 * method   : AddPassCases:RETURN_VALUE:
 * abstract : According to the current results of judgment which case will be passed
 * key      :
 *                  CASES --> name of case will be passed
 */
- (NSNumber *)AddPassCases:(NSDictionary*)dicSetting RETURN_VALUE:(NSMutableString *)szReturnValue
{    
    if (m_bSubTest_PASS_FAIL) 
    {
        NSMutableArray * muArry = [dicSetting objectForKey:@"FORCE_PASS"];
        for(NSString *szItemName in muArry)
        {
            [m_dicForcePassCase setObject:[m_dicMemoryValues objectForKey:kFunnyZoneCurrentItemName] forKey:szItemName];
        }
    }
    return [NSNumber numberWithBool:YES];
}

/*
 * Kyle 2012-01-08
 * method   : AddCancelCases:RETURN_VALUE:
 * abstract : According to the current results of judgment which case will be canceled
 * key      :
 *                  CASES --> name of case will be canceled
 */
- (NSNumber *)AddCancelCases:(NSDictionary*)dicSetting RETURN_VALUE:(NSMutableString *)szReturnValue
{   
   
    BOOL bFlag        = [[self JUDGE_SPEC:dicSetting RETURN_VALUE:[NSMutableString stringWithString:szReturnValue]] boolValue];

    if ([m_dicMemoryValues objectForKey:kFZ_Script_TestResult] != nil) 
    {
        [m_dicMemoryValues setObject:[NSNumber numberWithBool:YES] forKey:kFZ_Script_TestResult];
    }
    BOOL cancelFlag   = [[dicSetting valueForKey:kFZ_Script_CancelFlag] boolValue];
    BOOL bShowFlag    = [[dicSetting objectForKey:@"ISNOSpec"]boolValue];
    if (!bShowFlag)
    {
         [m_dicMemoryValues setObject:@"{N/A}" forKey:kFZ_TestLimit];//modify by lucy
    }
        if (bFlag ^ cancelFlag)
    {
        NSMutableArray * muArry = [dicSetting objectForKey:@"FORCE_CANCEL"];
        for(NSString *szItemName in muArry)
        {
            [m_muArrayCancelCase addObject:szItemName];
        }
    }
    return [NSNumber numberWithBool:YES];
}

/*
 * Kyle 2012-01-09
 * method    :  CheckDisConnect:RETURN_VALUE:
 * abstract  :  check disconnect with DUT
 *
 */
- (NSNumber *)CheckDisConnect:(NSDictionary*)dicSetting RETURN_VALUE:(NSMutableString *)szReturnValue
{
    uint    iTimeInternal = [[dicSetting objectForKey:@"UTIMEDELAY"]intValue];
    uint    iLoopTimesTemp = [[dicSetting objectForKey:@"LOOPTIMES"]intValue];
    BOOL    bFlagTemp = YES;
    
    uint    iDelay = iTimeInternal?iTimeInternal:5000;
    uint    iLoopTimes = iLoopTimesTemp?iLoopTimesTemp:5;
    uint    i = 1;
    
    do {
        if (![[self SEND_COMMAND:dicSetting] boolValue])
        {
            return [NSNumber numberWithBool:YES];
        }
        // If the bUartRevPass flag is YES, means we get the data after shuting down the unit, do loop
        // Stephen0 2012.4.20
        [self READ_COMMAND:dicSetting RETURN_VALUE:szReturnValue];
        if (!bUartRevPass)
        {
            bFlagTemp = YES;
            return [NSNumber numberWithBool:YES];
        }else
        {
            iLoopTimes--;
            bFlagTemp = NO;
            ATSDebug(@"Loop to check unit shut down %i times.",i++);
        }
        usleep(iDelay);
    } while (!bFlagTemp && iLoopTimes != 0);
    
    return [NSNumber numberWithBool:NO];
}

/*
 *descripe : get calbe name and set to szReturnValue;
 */
- (NSNumber *)GetCableName:(NSDictionary*)dicSetting RETURN_VALUE:(NSMutableString *)szReturnValue
{
    // Get port settings
    NSString        *szPortType   = [dicSetting objectForKey:kFZ_Script_DeviceTarget];//
    bool bIS_1_to_N =   [[self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_IS_1_to_N] boolValue];
    NSString        *szBsdPath;
    if(bIS_1_to_N)
    {
        szBsdPath   =   [[[m_dicPorts objectForKey:szPortType] objectAtIndex:kFZ_SerialInfo_SerialPort] objectForKey:@"Slot1"];
    }
    else
    {
        szBsdPath   =   [[m_dicPorts objectForKey:szPortType] objectAtIndex:kFZ_SerialInfo_SerialPort];
    }
    [szReturnValue setString:szBsdPath];
    return [NSNumber numberWithBool:YES];
}

/*
 *descript : for canceling sub items , such as "SEND_COMMAND"
 */
- (NSNumber *)CancelSubItemsForKong:(NSDictionary*)dicSetting RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSString *szCancelStr = [dicSetting objectForKey:@"ENCANCEL"];
    szCancelStr = szCancelStr?szCancelStr:@"usbkong";
    [self GetCableName:dicSetting RETURN_VALUE:szReturnValue];
    if (![[szReturnValue lowercaseString] ContainString:szCancelStr]) 
    {
        m_bCancelFlag = YES;
    }
    return [NSNumber numberWithBool:YES];
}

/*
 *description : return value multiply by some number
 */
- (NSNumber *)MultiplyBy:(NSDictionary *)dicSetting RETURN_VALUE:(NSMutableString *)szReutrnValue
{
    float iTimes = [[dicSetting objectForKey:@"TIMES"] floatValue];
    float fRetValue = [szReutrnValue floatValue];
    fRetValue = fRetValue*iTimes;
    [szReutrnValue setString:[NSString stringWithFormat:@"%f",fRetValue]];
    return [NSNumber numberWithBool:YES];    
}

/*
 *save some value to setting file as some key
 *dicSetting : NSDictionary* type , KEY => to save to in setting file
 */
- (NSNumber *)SAVE_TO_SF:(NSDictionary *)dicSetting RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSString *szKey = [dicSetting objectForKey:@"KEY"];
    [[NSUserDefaults standardUserDefaults] setObject:szReturnValue forKey:szKey];
    [NSUserDefaults resetStandardUserDefaults];
    return [NSNumber numberWithBool:YES];
}
/*
 *combine string
 *dicSetting : strings need to combine
 */
- (NSNumber *)COMBINESTRING:(NSDictionary *)dicSetting RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSString *szFinalString = [dicSetting objectForKey:@"ORIGINAL_STR"];
    BOOL bRet = [self TransformKeyToValue:szFinalString returnValue:&szFinalString];
    if (bRet) 
    {
        [szReturnValue setString:szFinalString];
        return [NSNumber numberWithBool:YES];
    }
    [szReturnValue setString:@""];
    return [NSNumber numberWithBool:NO];
}

/*Origin objective : add for CT 4-up
 *dicSetting => you must set "TITLE", "MESSAGE"; "ABUTTONS" is optional, if no this key , deal as no button condition
 *Create SDPanel object
 *should consider no button and with button conditions => no button ,must call "CLOSE_PANEL" function to release sdPanel items. 
 */
- (NSNumber *)MESSAGE_PANEL:(NSDictionary *)dicSetting RETURN_VALUE:(NSMutableString *)szReturnValue
{
    m_bOpenPanel = NO;
    m_StopFlag = NO;
    NSMutableDictionary *dicIn = [NSMutableDictionary dictionaryWithDictionary:dicSetting];
    NSString *szButtons = [dicSetting objectForKey:@"ABUTTONS"];
    m_bOpenPanel= [[dicIn objectForKey:@"OpenPanel"] boolValue];
    //m_szPortIndex like "Unit1","Unit2","Unit3"..... ; 48 represents '0'
    NSInteger iPort = [m_szPortIndex characterAtIndex:4]-48;
    NSString *szOrigin;
    if (m_bOpenPanel) 
    {
        if (iPort>2) 
        {
            szOrigin = [NSString stringWithFormat:@"%d,%d",SDLeftMargin+SDPanelWidth,SDPanelHeight*(2*(iPort-2)-1)];
        }
        else
        {
            szOrigin = [NSString stringWithFormat:@"%d,%d",SDLeftMargin,SDPanelHeight*(2*iPort-1)];
        }
        [dicIn setObject:szOrigin forKey:@"WIN_ORIGIN"];
        NSColor * color = [m_dicMemoryValues valueForKey:kPD_AMIOK_PanelColor];
        [dicIn setObject:color forKey:@"BACK_COLOR"];
        sdPanel = [[SDPanel alloc] initWithParentWindow:nil panelContents:dicIn];
        enum SD_RESULT enmRet = sdPanel.m_enmRet;
        if (!sdPanel.m_bNoButton && !sdPanel.m_bIsSession) 
        {
            [sdPanel release];
            sdPanel = nil;
        }
        if(enmRet == SD_FAIL)
        {
            return [NSNumber numberWithBool:NO];
        }
        
    }
    else
    {
        NSNotificationCenter    *nc     =   [NSNotificationCenter defaultCenter];
        [nc postNotificationName:ShowMessage object:self userInfo:dicIn];
        if (szButtons && ![szButtons isEqualToString:@""]) 
        {
            do {
                usleep(2000);
            } while (!m_StopFlag);
        }
        else {
            m_ReturnValue = YES;
        }
        
    }
    return [NSNumber numberWithBool:m_ReturnValue];
}

/*Origin objective : add for CT 4-up
 *After call MESSAGE_PANEL no button condition , you must call this function to release sdPanel object.
 */
- (NSNumber *)CLOSE_PANEL:(NSDictionary *)dicSetting RETURN_VALUE:(NSMutableString *)szReturnValue
{
    if (m_bOpenPanel) 
    {
        BOOL bRet = YES;
        if (sdPanel.m_enmRet == SD_FAIL && sdPanel.m_bIsSession && sdPanel.m_iBtnCount==1)
        {
            [szReturnValue setString:@"MENU or VolDn Button NG"];
            bRet = NO;
        }
        [sdPanel TerminateSession];
        [sdPanel release];
        sdPanel = nil;
        return [NSNumber numberWithBool:bRet];
    }
    else
    {
        NSNotificationCenter    *nc     =   [NSNotificationCenter defaultCenter];
        [nc postNotificationName:CloseMessage object:self userInfo:nil];
        return [NSNumber numberWithBool:YES];
    }
}


- (NSNumber *)EXE_COMMAND_PACK:(NSDictionary *)dicSetting RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSInteger iInterval = [[dicSetting objectForKey:@"Interval"] intValue];
    NSInteger iCycleCount = 0;
    if (m_bOpenPanel) 
    {
         m_bForceResult = NO;
    }
    id numCycleCount = [dicSetting objectForKey:@"CycleCount"];
    iCycleCount = numCycleCount?[numCycleCount intValue]:-1;
    
    NSArray *arySubItems = [dicSetting objectForKey:@"SubItems"];    
    NSInteger iSubCount = [arySubItems count];
    for (NSUInteger i = 0; i < iSubCount; i++) 
    {
        id idObj = [arySubItems objectAtIndex:i];//
        if (![idObj isKindOfClass:[NSDictionary class]] || 1 != [idObj count])
        {
            ATSDebug(@"Sub item format not correct , %@",idObj);
            return [NSNumber numberWithBool:NO];
        }
    }
    
    do {  
        if (sdPanel.m_bIsSession && m_bOpenPanel) 
        {
            if (sdPanel.m_enmRet == SD_FAIL)
            {
                m_bForceResult = YES;
                return [NSNumber numberWithBool:NO];
            }
            else if(sdPanel.m_enmRet == SD_PASS)
            {
                m_bForceResult = YES;
                return [NSNumber numberWithBool:YES];
            }
        }
        BOOL bRet = YES;
        for (NSUInteger i = 0; i < iSubCount; i++)
        {
            NSDictionary * dictSubItem = [arySubItems objectAtIndex:i];
            NSArray *arrKeys = [dictSubItem allKeys];
            NSString *szSubItemName = [arrKeys objectAtIndex:0]; //0:just one item
            NSDictionary * dictDetailPara = [dictSubItem objectForKey:szSubItemName];
            bRet &= [self performSELToClass:dictDetailPara SubItemName:szSubItemName ItemName:nil];
        }
        if (bRet) 
        {
            break;
        }
        
        if (iCycleCount == 0) 
        {
            break;
        }
        usleep(iInterval);
    }while ((iCycleCount<0) || --iCycleCount);
    return [NSNumber numberWithBool:YES];
}

- (NSNumber *)JUDGE_KEY:(NSDictionary *)dicSetting RETURN_VALUE:(NSMutableString *)szReturnValue
{
    if (m_bForceResult && m_bOpenPanel)
    {
        m_bForceResult = NO;
        return [NSNumber numberWithBool:YES];
        /*m_bForceResult = NO;
        if (sdPanel.m_enmRet == SD_FAIL)
        {
            return [NSNumber numberWithBool:NO];
        }
        else if(sdPanel.m_enmRet == SD_PASS)
        {
            return [NSNumber numberWithBool:YES];
        }*/
    }
    NSArray *aryKeys = [dicSetting allKeys];
    NSInteger iCount = [aryKeys count];
    for (NSInteger iIndex =0; iIndex < iCount; iIndex++) 
    {
        NSString *szKey = [aryKeys objectAtIndex:iIndex];
        NSDictionary *dicConditions = [dicSetting objectForKey:szKey];
        NSString *szStatisfiedValue = [dicConditions objectForKey:@"SATISFY"];
        BOOL bRet = [[dicConditions objectForKey:@"RETURN"] boolValue];
        
        NSString *szInDic = [m_dicMemoryValues objectForKey:szKey];
        if ([szInDic ContainString:szStatisfiedValue]) 
        {
            return [NSNumber numberWithBool:bRet];
        }    
    }
    return [NSNumber numberWithBool:NO];
}

@end
