//  IADevice_DetectPort.m
//  FunnyZone
//
//  Created by Eagle on 10/18/11.
//  Copyright 2011 PEGATRON. All rights reserved.



#import "IADevice_DetectPort.h"
#import "IADevice_Operation.h"
#import "IADevice_TestingCommands.h"

// auto test system
extern  BOOL    gbIfNeedRemoteCtl;

@implementation TestProgress (IADevice_DetectPort)

// 2012-04-19 add description by Winter
// for SFSU
// Used to find out the port type(MOBILE/FIXTURE/MIKEY...).
// Param:
//       NSMutableDictionary    *in_out_dicFlags    : port type status
//       NSString   *in_path        :   path to open port
//       NSArray    *in_arrDevices  :   needed devices
//       PEGA_ATS_UART  *uartObj    :   uart object to open port
// Return:
//      Actions result
-(NSString *)tryPort:(NSMutableDictionary *)in_out_dicFlags
		  serialPath:(NSString *)in_path
		  deviceList:(NSArray *)in_arrDevices
				uart:(PEGA_ATS_UART *)uartObj
{
    NSInteger	iDeviceCount	= [in_arrDevices count];
	for (NSInteger iIndex=0; iIndex<iDeviceCount; iIndex++)
    {
        NSString	*szPortType	= [in_arrDevices objectAtIndex:iIndex];
		UInt16	iRet			= [uartObj openPort:in_path
									  baudeRate:[kPD_DeviceSet_BaudeRate intValue]
										dataBit:[kPD_DeviceSet_DataBit intValue]
										 parity:kPD_DeviceSet_Parity
									   stopBits:[kPD_DeviceSet_StopBit intValue]
									  endSymbol:kPD_DeviceSet_EndFlag];
		// add by jingfu ran on 2012 04 26
        BOOL	bISHex	= NO;
        if ((kPD_DeviceSet_Hex != nil)) 
			bISHex	= [kPD_DeviceSet_Hex boolValue];
        //end by jingfu ran n 04 26
		
        if(iRet == kUart_SUCCESS)
        {
            NSInteger	iMatchType	= [kPD_DeviceSet_MatchType intValue];
            if([kPD_DeviceSet_Type intValue] == kPD_DeviceSet_Type_String)
            {
                NSMutableString	*szReturn	= [[NSMutableString alloc] init];
                [uartObj Clear_UartBuff:kUart_ClearInterval
								TimeOut:kUart_CommandTimeOut
								readOut:nil];
                [uartObj Write_UartCommand:kPD_DeviceSet_Try
								 PackedNum:0
								  Interval:1000
									 IsHex:bISHex];
				//modified by jingfu ran on 2012 04 26. No pass the unique NO
                iRet	= [uartObj Read_UartData:szReturn
							  TerminateSymbol:kPD_DeviceSet_Expect
									MatchType:iMatchType
								 IntervalTime:kUart_IntervalTime
									  TimeOut:kUart_CommandTimeOut];
                [szReturn release]; 
                szReturn	= nil;
            }
            else
            {
                NSMutableData	*dataReturn	= [[NSMutableData alloc] init];
                [uartObj Clear_UartBuff:kUart_ClearInterval
								TimeOut:kUart_CommandTimeOut
								readOut:nil];
                [uartObj Write_UartCommand:kPD_DeviceSet_Try
								 PackedNum:1
								  Interval:0
									 IsHex:YES];
                iRet	= [uartObj Read_UartData:dataReturn
							  TerminateSymbol:kPD_DeviceSet_Expect
									MatchType:iMatchType
								 IntervalTime:0.01
									  TimeOut:5.1];
                [dataReturn release];
                dataReturn	= nil;                
            }
            if (iRet == kUart_SUCCESS) 
            {
                [in_out_dicFlags setObject:[NSNumber numberWithBool:YES]
									forKey:szPortType];
                [uartObj Close_Uart];
                return szPortType;
            }
            [uartObj Close_Uart];
        }        
    }
    return kPD_Device_MOBILE;
}

//2012-04-19 add description by Winter
//for all(SFSU,NFMU,MFMU)
// Used to search and list detected ports.
// Param:
//       NSMutableArray    *aryPorts        : list detected ports
// Return:
//      Actions result
-(void)listSerialCablePath:(NSMutableArray *)aryPorts
{
    SearchSerialPorts	*sspObject	= [[SearchSerialPorts alloc] init];
    NSArray     *aryPortList = [self getValueFromXML:kPD_UserDefaults mainKey:kPD_VirtualSerialPrt];
    //Add by sky, 2015.2.9, find the ports from disk
    [sspObject FindSerialPortsFromDisk:aryPorts];
    
    if ((aryPortList) && ([aryPortList count] > 0))
        [aryPorts addObjectsFromArray:aryPortList];
    [sspObject release];
}


//2012-04-19 add description by Winter
// For multi fixture multi UI, assigh ports for each unit.(SerialPort,UartObj,Color,Target)
// Param:
//       NSMutableArray    *in_out_aryPorts        : send out port
//       NSMutableArray    *aryAllProts            : all ports
//       aryPorts       : list detected ports
// Return:
//      Actions result
-(BOOL)detectUnitsPreference:(NSMutableArray *)in_out_aryPorts
		 inAllPorts:(NSMutableArray *)aryAllProts
{
    BOOL	bRet		= YES;
    NSArray				*aryKeys		= [kPD_ModeSet_UnitInfo allKeys];
    NSInteger			iSetListCount	= [aryKeys count];

    for (NSInteger iIndex=0; iIndex<iSetListCount; iIndex++) 
    {
        NSString		*szCurrentKey	= [NSString stringWithFormat:@"Unit%ld", iIndex + 1];
        NSDictionary	*dicEachUnitSet	= [kPD_ModeSet_UnitInfo objectForKey:szCurrentKey];
        if ([dicEachUnitSet isKindOfClass:[NSDictionary class]]) 
        {
            if ([[dicEachUnitSet objectForKey:kPD_UserDefaults_PutInUse] boolValue]) 
            {
                //get dic of Unit1#....
                NSDictionary	*dicDevices	= [dicEachUnitSet objectForKey:
											   kPD_UserDefaults_DeviceRequire];
                NSMutableDictionary	*dicTarget	= [[NSMutableDictionary alloc] init];
                BOOL	bComparedAllName	= YES;
                BOOL	bComparedOneName	= YES;
                NSArray		*aryPorts		= [dicDevices allKeys];
                NSInteger	iCount			= [aryPorts count];
                // kyle 2012.4.11 modify the parameter name "iIndex" to "kIndex".
                for(NSInteger kIndex=0; kIndex<iCount; kIndex++)
                {   
                    NSString	*szPortType	= [aryPorts objectAtIndex:kIndex];
                    
                    // auto test system
                    BOOL    bEnableThisDevice   = [[self getValueFromXML:dicDevices
                                                                 mainKey:szPortType,kPD_UserDefaults_EnableDevice,nil]
                                                   boolValue];
                    if (gbIfNeedRemoteCtl) {
                        bEnableThisDevice   = YES;
                    }
                    
                    if (bEnableThisDevice)
                    {
                        bComparedOneName	= NO;
						NSString		*szPortName			= @"" ;
						//for pressure test
                        BOOL bNeedPortNameMatch = [[self getValueFromXML:dicDevices mainKey:szPortType,@"NameNeedEqual",nil] boolValue];
                        BOOL bIgnoreMissedCables = [[self getValueFromXML:dicDevices mainKey:szPortType,@"CanIgnore",nil] boolValue];
                        
						szPortName = [self getValueFromXML:dicDevices
												   mainKey:szPortType,kPD_UserDefaults_PortName,nil];
						
                        NSInteger	iAllPortCount	= [aryAllProts count];
                        NSInteger	jIndex			= 0;
                        for (; jIndex<iAllPortCount; jIndex++) 
                        {
                            NSString		*szSerialPort	= [aryAllProts objectAtIndex:jIndex];
							PEGA_ATS_UART	*uartObj		= [[[PEGA_ATS_UART alloc]
																init] autorelease];
							NSString		*szColor		= kPD_DeviceSet_UartColor;
							if(!szColor
							   || ![[m_dictPortColor allKeys]
									containsObject:[szColor uppercaseString]])
								szColor	= kFZ_UartTableview_WHITE;
							NSColor	*color	= [self TransformPortColor:szColor];

							if ((szPortName != nil) && (![szPortName isEqualToString:@""]))
							{
								NSRange range = [szSerialPort rangeOfString:szPortName];
								if (range.location != NSNotFound 
									&& range.length >0 
									&& (range.location +range.length) <= [szSerialPort length]) 
								{
                                    //for pressure test
                                    if (bNeedPortNameMatch && ![szSerialPort hasSuffix:szPortName])
                                    {
                                        continue;
                                    }
                                    // Normall process
									bComparedOneName	= YES;
									
									NSArray	*aryTarget	= [NSArray arrayWithObjects:
														   szSerialPort,uartObj,color, nil];
									[dicTarget setObject:aryTarget
												  forKey:szPortType];
									break;
								}
                            }
                        }
                        //bComparedAllName	&= bComparedOneName;
                         bComparedAllName &= (bComparedOneName | bIgnoreMissedCables);
                        if (!bComparedOneName && !bIgnoreMissedCables) 
						{
                            NSAlert *alert = [[NSAlert alloc]init];
                            alert.messageText = @"警告(Warning)";
                            alert.informativeText = [NSString stringWithFormat:@"Cable Mapping Error\n在%@中为%@找不到线名为%@的线。", aryAllProts, szPortType, szPortName];
                            [alert addButtonWithTitle:@"噢(OK)"];
                            [alert setAlertStyle:NSWarningAlertStyle];
                            [alert runModal];
                            [alert release];
                            break;
                        }
                    }
                }
				if (bComparedAllName)
                    [in_out_aryPorts addObject:
					 [NSDictionary dictionaryWithObject:dicTarget
												 forKey:szCurrentKey]];
                [dicTarget release];
            }
        }
    }
    return bRet;
}

//2012-4-16 add note by Sunny
//		Get SerialPorts，dicide use relevant UI through setting file .
// Parameter:
//      NSMutableArray        in_out_aryPorts : send out port
// Return:
//      Actions result
-(BOOL)assignPorts:(NSMutableArray *)in_out_aryPorts
{
    BOOL			bRet			= NO;
    NSMutableArray	*arrSerialPorts	= [[NSMutableArray alloc] init];
    [self listSerialCablePath:arrSerialPorts];
    
    //2012.2.23
    //modify by desikan for set kong cable mode, if assign ports fail, don't set.
    if([self detectUnitsPreference:in_out_aryPorts inAllPorts:arrSerialPorts])
        bRet	= [self Set_KongCable_Auto_diags:in_out_aryPorts];
    [arrSerialPorts release];
    return bRet;
}

-(void)monitorSerialPortPlugInWithUartPath:(NSString *)in_szUARTPath
							  withOutputSN:(NSMutableString *)out_szSN
{
    NSMutableString	*szReadString	= [[NSMutableString alloc] init];
    do
	{
        if ([self checkUnitConnectWellWithSerialPort:in_szUARTPath
										 UARTCommand:@""
										UartResponse:szReadString
										   CheckTime:1.00])
        {
			// OS mode.
			if([szReadString endWith:@"root# "])
				break;
			if([szReadString endWith:@"login: "]
			   && [self checkUnitConnectWellWithSerialPort:in_szUARTPath
											   UARTCommand:@"root"
											  UartResponse:szReadString
												 CheckTime:1.00])
			{
				if([szReadString ContainString:@"Password:"]
				   && [self checkUnitConnectWellWithSerialPort:in_szUARTPath
												   UARTCommand:@"alpine"
												  UartResponse:szReadString
													 CheckTime:1.00])
				{
					if([szReadString ContainString:@"root# "])
						break;
				}
				continue;
			}
			// Recovery mode.
            if ([szReadString endWith:@"] "])
                break;
			// Diags mode.
            if ([self checkUnitConnectWellWithSerialPort:in_szUARTPath
											 UARTCommand:@""
											UartResponse:szReadString
											   CheckTime:10])
            {
                NSRange	rangeSerial	= [szReadString rangeOfString:@":-)"];
                if(NSNotFound != rangeSerial.location)
					break;
            }
        }
        // sleep 1 second
        sleep(1);
        
    } while (YES);
    [szReadString release];
}
- (BOOL)checkUnitConnectWellWithFixturePort:(NSString *)in_szUARTPath
								UARTCommand:(NSString *)in_szCommand
							   UartResponse:(NSMutableString *)in_out_szResponse
								  CheckTime:(NSTimeInterval)inCheckTime
{  
	NSDictionary	*dicForFixture	= [NSDictionary dictionaryWithObject:kPD_Device_FIXTURE
															  forKey:kFZ_Script_DeviceTarget];
    NSString		*szPortType		= [dicForFixture objectForKey:kFZ_Script_DeviceTarget];
    NSString		*szBsdPath		= in_szUARTPath;
    NSMutableString *szReadString	= [[NSMutableString alloc] init];

    int             iSpeed			= [kPD_DeviceSet_BaudeRate intValue];
    int             iDataBit		= [kPD_DeviceSet_DataBit intValue];
    NSString        *szParity		= kPD_DeviceSet_Parity;
    int             iStopBit		= [kPD_DeviceSet_StopBit intValue];
    NSString        *szEndsymbol	= kPD_DeviceSet_EndFlag;
    NSInteger       iRet			= -1;
    PEGA_ATS_UART	*uartObj		= [[PEGA_ATS_UART alloc] init];
    
    iRet	= [uartObj openPort:szBsdPath
				   baudeRate:iSpeed
					 dataBit:iDataBit
					  parity:szParity
					stopBits:iStopBit
				   endSymbol:szEndsymbol];
    
    if(kUart_SUCCESS == iRet)//iRet== 0 --> succeed
    {
        if (0 == iRet)
        {
            for (int i = 0; i < 3; i++)
            {
                iRet	= [uartObj Clear_UartBuff:kUart_ClearInterval
									   TimeOut:kUart_CommandTimeOut
									   readOut:nil];
                if (0 == iRet)
                    iRet	= [uartObj Write_UartCommand:in_szCommand
											PackedNum:1
											 Interval:0
												IsHex:NO];
                if (0 == iRet)
                {	
                    iRet	= [uartObj Read_UartData:szReadString
								  TerminateSymbol:[NSArray arrayWithObjects:@"*_*", nil]
										MatchType:1
									 IntervalTime:0.3
										  TimeOut:inCheckTime];
                    [in_out_szResponse setString:[NSString stringWithString:szReadString]];
                }
                if (0 == iRet)
                    break;
                else if(iRet == kUart_ERROR)
                {
                    [uartObj Close_Uart];
                    [uartObj release];
                    
                    NSLog(@"kUart_ERROR: 241error");
                    uartObj	= [[PEGA_ATS_UART alloc] init];
                    iRet	= [uartObj openPort:szBsdPath
								   baudeRate:iSpeed
									 dataBit:iDataBit
									  parity:szParity
									stopBits:iStopBit
								   endSymbol:szEndsymbol];
                }
                usleep(100000);
            }
            
        }
        [uartObj Close_Uart];
        [uartObj release];
        uartObj	= nil;
        [szReadString release];
        if (0 == iRet) 
            return YES;
        else
            return NO;
    }
    else
    {
        [uartObj Close_Uart];
        [uartObj release];
        uartObj	= nil;
        [szReadString release];
        return NO;
    }
}


//2012-6-30 
//	add for interposer and grape-1 , check the tray which in the fixture is it in?
// Parameter:
//      NSMutableArray   in_szUARTPath : the path about the fixture.
// Return:
//      Actions result
-(void)monitorSensorStatusInWithUartPath:(NSString *)in_szUARTPath
{
    NSMutableString	*szReadString	= [[NSMutableString alloc] init];
    do
	{
        if ([self checkUnitConnectWellWithFixturePort:in_szUARTPath
										  UARTCommand:@""
										 UartResponse:szReadString
											CheckTime:0.65])
        {
            if ([szReadString ContainString:@"*_*"]) 
            {                
                if ([self checkUnitConnectWellWithFixturePort:in_szUARTPath
												  UARTCommand:@"read sensor"
												 UartResponse:szReadString
													CheckTime:10])
                {
                    NSRange	rangeSerial	= [szReadString rangeOfString:@"up/down/back/advance="];
                    if(NSNotFound != rangeSerial.location 
					   && rangeSerial.length > 0 
					   && (rangeSerial.length + rangeSerial.location) <= [szReadString length])
                    {
                        [szReadString setString:
						 [szReadString substringFromIndex:rangeSerial.location + rangeSerial.length]];
                        NSRange	rangeEndSymbol	= [szReadString rangeOfString:@"*_*"];
                    
                        if (NSNotFound != rangeEndSymbol.location 
                            && rangeEndSymbol.length > 0
                            && (rangeEndSymbol.length + rangeEndSymbol.location) <= [szReadString length])
                        {
                            [szReadString setString:
							 [szReadString substringToIndex:rangeEndSymbol.location]];
                            if ([szReadString isEqualToString:@"1010\n"]) 
                                break;
                        }
                    }
                }
            }
        }
        // sleep 1 second
        sleep(1);
    } while (YES);
    [szReadString release];
}

//2012-7-14
//	add by yaya for interposer and grape-1 , In and out the tray to stress test.
// Parameter:
//      NSMutableArray   in_szUARTPath : the path about the fixture.
// Return:
//      Actions result
-(BOOL)MakeTheTrayIn:(NSString *)in_szUARTPath
{
    NSMutableString	*szReadString	= [[NSMutableString alloc] init];
    BOOL			Bret			= NO;
    
    if ([self checkUnitConnectWellWithFixturePort:in_szUARTPath
									  UARTCommand:@"in down on"
									 UartResponse:szReadString
										CheckTime:20])
        if ([szReadString ContainString:@"OK"])
            if ([self checkUnitConnectWellWithFixturePort:in_szUARTPath
											  UARTCommand:@"read sensor"
											 UartResponse:szReadString
												CheckTime:10])
            {
                NSRange	rangeSerial	= [szReadString rangeOfString:@"up/down/back/advance="];
                if(NSNotFound != rangeSerial.location
				   && rangeSerial.length > 0
				   && (rangeSerial.length + rangeSerial.location) <= [szReadString length])
                {
                    [szReadString setString:
					 [szReadString substringFromIndex:rangeSerial.location + rangeSerial.length]];
                    NSRange	rangeEndSymbol	= [szReadString rangeOfString:@"*_*"];
                    
                    if (NSNotFound != rangeEndSymbol.location 
                        && rangeEndSymbol.length > 0
                        && (rangeEndSymbol.length + rangeEndSymbol.location) <= [szReadString length])
                    {
                        [szReadString setString:
						 [szReadString substringToIndex:rangeEndSymbol.location]];
                        if ([szReadString isEqualToString:@"1010\n"]) 
                            Bret = YES;
                    }
                   
                }
               
            }
    
    [szReadString release];
    
    if (Bret)
        return YES;
    else
        return NO;
}

//2012-4-16 add note by Sunny
//		Check unit plug out.
// Parameter:
//      NSString        in_szUARTPath : serial port path
// Return:
//      the action result
- (void)monitorSerialPortPlugOutWithUartPath:(NSString *)in_szUARTPath
{
    NSMutableString	*szReadString	= [[NSMutableString alloc] init];
    do
	{
        if (![self checkUnitConnectWellWithSerialPort:in_szUARTPath
										  UARTCommand:@""
										 UartResponse:szReadString
											CheckTime:0.6])
            break;
        else
            usleep(100000);
    } while (YES);
    [szReadString release];
}

//2012-4-16 add note by Sunny
//		Check unit connect well with serial port
// Parameter:
//      NSString			in_szUARTPath		: UART Path
//		NSString			in_szCommand		: send command
//		NSMutableString		in_out_szResponse	: receive response
//		NSTimeInterval		inCheckTime			: no use
// Return:
//      the action result
- (BOOL)checkUnitConnectWellWithSerialPort:(NSString *)in_szUARTPath
							   UARTCommand:(NSString *)in_szCommand
							  UartResponse:(NSMutableString *)in_out_szResponse
								 CheckTime:(NSTimeInterval)inCheckTime
{
//	bool	bIS_1_to_N	= [[self getValueFromXML:kPD_UserDefaults
//									 mainKey:kPD_UserDefaults_IS_1_to_N]
//						   boolValue];
    NSMutableString	*szReadString	= [[NSMutableString alloc] init];
    PEGA_ATS_UART	*uartObj		= [[PEGA_ATS_UART alloc] init];
    int				iRet			= -1;
    NSString		*szPortType		= kPD_Device_MOBILE;
    
    // modified by betty 12/4/11 for reading baudeRate from muifa
    iRet	= [uartObj openPort:in_szUARTPath
				   baudeRate:[kPD_DeviceSet_BaudeRate intValue]
					 dataBit:[kPD_DeviceSet_DataBit intValue]
					  parity:kPD_DeviceSet_Parity
					stopBits:[kPD_DeviceSet_StopBit intValue]
				   endSymbol:kPD_DeviceSet_EndFlag];
    if (0 == iRet)
    {
        for (int i = 0; i < 3; i++)
        {
            iRet	= [uartObj Clear_UartBuff:kUart_ClearInterval
								   TimeOut:kUart_CommandTimeOut
								   readOut:nil];
            if (0 == iRet)
                iRet	= [uartObj Write_UartCommand:in_szCommand
										PackedNum:1
										 Interval:0
											IsHex:NO];
            if (0 == iRet)
            {
				iRet	= [uartObj Read_UartData:szReadString
							  TerminateSymbol:[NSArray arrayWithObjects:@":-)",@"]", @"login: ", @"Password:", @"root# ", nil]
									MatchType:1
								 IntervalTime:0.3
									  TimeOut:inCheckTime];
                [in_out_szResponse setString:[NSString stringWithString:szReadString]];
            }
            if (0 == iRet)
                break;
            else if(iRet == kUart_ERROR)
            {
                [uartObj Close_Uart];
                [uartObj release];
                
                NSLog(@"kUart_ERROR: 241error");
                uartObj	= [[PEGA_ATS_UART alloc] init];
                iRet	= [uartObj openPort:in_szUARTPath
							   baudeRate:115200
								 dataBit:[kPD_DeviceSet_DataBit intValue]
								  parity:kPD_DeviceSet_Parity
								stopBits:[kPD_DeviceSet_StopBit intValue]
							   endSymbol:kPD_DeviceSet_EndFlag];
            }
            usleep(100000);
        }

    }
    [uartObj Close_Uart];
    [uartObj release];
    uartObj	= nil;
    [szReadString release];
    if (0 == iRet) 
        return YES;
    else
        return NO;
}

- (NSNumber*)DISORCONNECTUSB:(NSDictionary*)dicContents
				RETURN_VALUE:(NSMutableString*)strReturnValue
{ 
    NSString		*szNumber;
    NSString		*szArgus		= [dicContents objectForKey: @"Argus"];
    NSString		*szPortType		= [dicContents objectForKey:kFZ_Script_DeviceTarget];
    NSString		*szBsdPath		= [[m_dicPorts objectForKey:szPortType]
									   objectAtIndex:kFZ_SerialInfo_SerialPort];
    NSString		*szPath			= [dicContents objectForKey:@"Path"];
    NSFileManager	*BuilAppPath	=[NSFileManager defaultManager];
    
    if ([BuilAppPath fileExistsAtPath:szPath] == NO)
    {
        ATSDebug(@"There is no app,please check it!");
        return [NSNumber numberWithBool:NO];
    }
    
    NSMutableDictionary	*dicSerialNumber	=[[NSMutableDictionary alloc] init];
    SearchSerialPorts	*sspObject			= [[SearchSerialPorts alloc] init]; 
    [sspObject SearchPortsNumber:dicSerialNumber] ;
    if (dicSerialNumber ==NULL
		|| dicSerialNumber == nil
		||[szBsdPath isEqualToString: @""])
    {
        ATSDebug(@"The device is error,Please check it!");
        [dicSerialNumber release];
        [sspObject release];
        return [NSNumber numberWithBool:NO];
    }
    
    szNumber	= [dicSerialNumber valueForKey:szBsdPath];
    ATSDebug(@"Serail number%@",szNumber);
    NSTask	*task		= [[NSTask alloc] init];      
    NSPipe	*outPipe	= [[NSPipe alloc]init];
    [task setLaunchPath:szPath];
    NSArray	*args		= [NSArray arrayWithObjects:
						   szNumber,szArgus,nil];
    [task setArguments:args];
    [task setStandardOutput:outPipe];
    [task launch];
    
    NSData	*data		= [[outPipe fileHandleForReading]
						   readDataToEndOfFile];
    [task waitUntilExit];
    [task release];
    [outPipe release];
    NSString	*szString	= [[NSString alloc]	initWithData:data
											   encoding:NSUTF8StringEncoding];
    ATSDebug(@"the error command :%@",szString);
    
    [dicSerialNumber release];
    [sspObject release];
    [szString release];
    return [NSNumber numberWithBool:YES];
    
}

//2012-4-26 added by Lorky
//		Check the disconnect usb status
// Parameter:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
// Return:
//      the action result
- (NSNumber*)CHECK_USB_CONNECT_STATUS:(NSDictionary*)dicContents
						 RETURN_VALUE:(NSMutableString*)strReturnValue
{
	// get dicContents para
	BOOL result = YES;
	int		iTimeOut			= [[dicContents objectForKey:@"TIMEOUT"] intValue];
	NSDictionary	*dicCompareItems	= [dicContents objectForKey:@"COMPARE_ITEMS"];
	// Get Kong Cable Number
	NSString		*szNumber;
	NSString        *szPortType			= [dicContents objectForKey:kFZ_Script_DeviceTarget];
    NSString        *szBsdPath			= [[m_dicPorts objectForKey:szPortType]
										   objectAtIndex:kFZ_SerialInfo_SerialPort];
    NSString		*szPath				= [dicContents objectForKey:@"Path"];
    NSFileManager	*BuilAppPath		= [NSFileManager defaultManager];
    
	if ([BuilAppPath fileExistsAtPath:szPath] == NO)
    {
        ATSDebug(@"There is no app,please check it!");
        return [NSNumber numberWithBool:NO];
    }
    
    NSMutableDictionary	*dicSerialNumber	=[[NSMutableDictionary alloc] init];
    SearchSerialPorts	*sspObject			= [[SearchSerialPorts alloc] init]; 
    [sspObject SearchPortsNumber:dicSerialNumber] ;
    [sspObject release];//Leehua
    if (dicSerialNumber == NULL
		|| dicSerialNumber == nil
		|| [szBsdPath isEqualToString: @""])
    {
        ATSDebug(@"The device is error,Please check it!");
        [dicSerialNumber release];        
        return [NSNumber numberWithBool:NO];
    }
    szNumber	= [dicSerialNumber valueForKey:szBsdPath];
    ATSDebug(@"Serail number%@",szNumber);
    [dicSerialNumber release];//Leehua
	// call task to get the response by /astrisctl tool
	NSArray	*aryPara	= [NSArray  arrayWithObjects:
						   @"--host",
						   [NSString stringWithFormat:@"KongSWD-%@",szNumber],
						   @"relays", nil];
	[self CallTask:szPath
		 Parameter:aryPara
		 EndString:nil
		   TimeOut:[NSNumber numberWithInt:iTimeOut]
	   ReturnValue:strReturnValue];
	if (strReturnValue)
	{
		// Clear up the response and compare with that form dicContents.
		NSMutableDictionary	*dictResponse	= [[NSMutableDictionary alloc] init];
		NSArray				*ary			= [strReturnValue componentsSeparatedByString:@"\n"];
		for (NSString *strTemp in ary)
		{
			NSArray	*aryTemp	= [strTemp componentsSeparatedByCharactersInSet:
								   [NSCharacterSet whitespaceCharacterSet]];
			if ([aryTemp count] >= 3)
				// the first object is key like: vbus
				// the last object is value like: 0
				[dictResponse setObject:[aryTemp objectAtIndex:[aryTemp count]-1]
								 forKey:[aryTemp objectAtIndex:0]];
		}
		
		// compare
		for (NSString *strkey in [dicCompareItems allKeys])
		{
			NSString	*strValue	= [dicCompareItems objectForKey:strkey];
			if (![[dictResponse allKeys] containsObject:strkey])
			{
				[strReturnValue appendFormat:@"did not include key[%@]",strkey];
				result	= NO;
			}
			else
			{
				if (![strValue isEqualToString:[dictResponse objectForKey:strkey]])
				{
					result	= NO;
					[strReturnValue appendFormat:@"[%@] status is not Match",strkey];
				}
			}
		}
		[dictResponse release];
	}
	
	return [NSNumber numberWithBool:result];
}

//2012-4-16 add note by Sunny
//		set kong cable auto enter diags mode/
// Parameter:
//      NSMutableArray        arrPorts : serial ports list
// Return:
//      the action result
-(BOOL)Set_KongCable_Auto_diags:(NSMutableArray *)arrPorts
{   
    NSString		*szToolPath		= @"/usr/local/bin/astrisctl";
    NSMutableString	*szReturn		= [[[NSMutableString alloc]init] autorelease];
    NSString		*szBsdPath;
    bool			bSetPass		= YES;
    bool			bNeedNotReset	= YES;
    NSMutableDictionary	*dicSetting	=   [[[NSMutableDictionary alloc] init] autorelease];
    NSMutableArray		*arrBsdPath	=   [[[NSMutableArray alloc] init] autorelease];
    [dicSetting setObject:@"1"
				   forKey:@"Statu"];
    [dicSetting setObject:szToolPath
				   forKey:@"toolPath"];
    [dicSetting setObject:@"Read"
				   forKey:@"currentAction"];

    if([arrPorts count] <= 0)
        return NO;
    for (int i=0; i<[arrPorts count]; i++)
    {
        NSArray			*arrkey			= [[arrPorts objectAtIndex:i] allKeys];
        NSDictionary	*dicPortInfo	= [[arrPorts objectAtIndex:i]
										   objectForKey:[arrkey objectAtIndex:0]];

            szBsdPath	= [[dicPortInfo objectForKey:kPD_Device_MOBILE]
						   objectAtIndex:kFZ_SerialInfo_SerialPort];
            if(nil == szBsdPath)
                return YES;
            //2012.05.01 Leehua for Mikey Bus test , because it's just normal uart cable , but not kong cable ,can't be programmed
            if ([szBsdPath rangeOfString:@"usbserial"].location != NSNotFound) 
                return YES;
            if ([szBsdPath rangeOfString:@"virtual"].location != NSNotFound)
                return YES;
            [dicSetting setObject:szBsdPath
						   forKey:@"UartPath"];
            BOOL	bSingleNotReset	= [[self Set_KongCable_diagsStatus:dicSetting
													   Return_Value:szReturn] boolValue];
            bNeedNotReset	&= bSingleNotReset;
            if(!bSingleNotReset)
                [arrBsdPath addObject:szBsdPath];
    }
    if(bNeedNotReset)
        return YES;
    for(int i=0;i<[arrBsdPath count];i++)
    {
        [dicSetting setObject:@"Set"
					   forKey:@"currentAction"];
        [dicSetting setObject:[arrBsdPath objectAtIndex:i]
					   forKey:@"UartPath"];
        if(![self Set_KongCable_diagsStatus:dicSetting
							   Return_Value:szReturn])
        {
            NSAlert *alert = [[NSAlert alloc]init];
            alert.messageText = @"警告(Warning)";
            alert.informativeText = @"请确认/usr/local/bin目录下有名为diag_status的文件。(Please make sure /usr/local/bin/diag_status is exist.)";
            [alert addButtonWithTitle:@"确认(OK)"];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert runModal];
            [alert release];
            bSetPass	= NO;
            break;
        }
    }
    if(bSetPass)
    {
        NSAlert *alert = [[NSAlert alloc]init];
        alert.messageText = @"警告(Warning)";
        alert.informativeText = @"所有的Kong Cable已设置成使机台自动进diag模式，请重插拔所有的Kong Cable并重开程式。(Already set Kong Cable be auto enter diag mode. Please replug all the Kong cables,and restart the program)";
        [alert addButtonWithTitle:@"确认(OK)"];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
        [alert release];
    }
    return NO;
}
//2012-4-16 add note by Sunny
//		set kong cable diags status.
// Parameter:
//      NSString        szToolPath	:	tool path
//		NSString		szBsdPath	:	Uart path
//		NSString		szCurrentAction	:	current action
// Return:
//      the action result
- (NSNumber *)Set_KongCable_diagsStatus:(NSDictionary *)dicPara
						   Return_Value:(NSMutableString *)szReturnValue
{
    SearchSerialPorts	*searchSPorts	= [[SearchSerialPorts alloc] init];
    NSMutableDictionary	*muDic			= [[NSMutableDictionary alloc] init];
    [searchSPorts SearchPortsNumber:muDic];
    NSString		*szToolPath			= [dicPara objectForKey:@"toolPath"];
    NSString		*szBsdPath			= [dicPara objectForKey:@"UartPath"];
    NSString		*szNumber           = [muDic valueForKey:szBsdPath];
    NSArray			*args;
    NSString		*szCurrentAction    = [dicPara objectForKey:@"currentAction"];
    if([szCurrentAction isEqualToString:@"Read"])
        args	= [NSArray arrayWithObjects:
				   @"--host",
				   [NSString stringWithFormat:@"kong-%@",szNumber],
				   @"printenv",nil];
    else
    {
        NSString	*szStatus	= [dicPara objectForKey:@"Statu"];
        args	= [NSArray arrayWithObjects:
				   @"--host",
				   [NSString stringWithFormat:@"kong-%@",szNumber],
				   @"setenv",
				   @"diags",
				   szStatus,nil];
    }
    [muDic release];
    [searchSPorts release];
    if(![self CallTask:szToolPath
			 Parameter:args
			 EndString:nil
			   TimeOut:nil
		   ReturnValue:szReturnValue])
    {
        NSLog(@"can't find the app at path %@", szToolPath);
        return [NSNumber numberWithBool:NO];
    }
    else if([szCurrentAction isEqualToString:@"Read"])
    {
        NSRange	range	= [szReturnValue rangeOfString:@"diags="];
        if(NSNotFound !=range.location
		   && range.length >0
		   && (range.location +range.length) <= [szReturnValue length])
        {
            int	iCurrentStatu	= [[szReturnValue substringFromIndex:(range.location
																	  + range.length)]
								   intValue];
            if(1 == iCurrentStatu)
            {
                NSLog(@"get current status is 1,don't need to reset");
                return [NSNumber numberWithBool:YES];
            }
            else
            {
                NSLog(@"current status is not 1");
                return [NSNumber numberWithBool:NO];
            }
        }
        else
        {
            NSLog(@"does not have string :diags");
            return [NSNumber numberWithBool:NO];
        }
    }
    NSLog(@"return value is %@",szReturnValue);
    return [NSNumber numberWithBool:YES];
}

//Add by winter, set the "disableOVCheck" status
//2012-4-16 add note by Sunny
//		set the "disableOVCheck" status
// Parameter:
//      NSString        szPortType : device target
//		BOOL			bOVCheck	:	if not ov check 
//		NSString		szToolPath	:	tool path
// Return:
//      the action result
- (NSNumber *)DisableOVCheck_Set_Del:(NSDictionary*)dictSettings
						RETURN_VALUE:(NSMutableString*)szReturnValue
{
    NSString	*szPortType	= [dictSettings objectForKey:kFZ_Script_DeviceTarget];
    BOOL		bOVCheck	= [[dictSettings objectForKey:@"DEL_DisableOVCheck"]
							   boolValue];
//	bool		bIs_1_to_N	= [[self getValueFromXML:kPD_UserDefaults
//									  mainKey:kPD_UserDefaults_IS_1_to_N]
//							   boolValue];
	NSString	*szBsdPath;
//	if(bIs_1_to_N)
//	{
//        NSString	*szUnit	= [dictSettings objectForKey:@"Unit"];
//		szBsdPath	= [[[m_dicPorts objectForKey:szPortType]
//						objectAtIndex:kFZ_SerialInfo_SerialPort]
//					   objectForKey:szUnit];
//	}
//	else
        szBsdPath	= [[m_dicPorts objectForKey:szPortType]
					   objectAtIndex:kFZ_SerialInfo_SerialPort];
    NSString			*szToolPath		= [dictSettings objectForKey:@"Path"];
    SearchSerialPorts	*searchSPorts	= [[SearchSerialPorts alloc] init];
    NSMutableDictionary	*muDic			= [[NSMutableDictionary alloc] init];
    [searchSPorts SearchPortsNumber:muDic];
    NSString	*szNumber	= [muDic valueForKey:szBsdPath];
    NSArray		*args;
    NSString	*szArgs;
    if (!bOVCheck) 
    {
        szArgs	= [NSString stringWithFormat:
				   @"--host kong-%@ setenv disableOVCheck 1",
				   szNumber];
        args	= [szArgs componentsSeparatedByString:@" "];
        
    }
    else
    {
        szArgs	= [NSString stringWithFormat:
				   @"--host kong-%@ delenv disableOVCheck",
				   szNumber];
        args	= [szArgs componentsSeparatedByString:@" "];
    }
    [self CallTask:szToolPath
		 Parameter:args
		 EndString:nil
		   TimeOut:nil
	   ReturnValue:szReturnValue];
    
    [muDic release];
    [searchSPorts release];
    
    NSString	*szDisableOVCheck	= [NSString stringWithString:szReturnValue];
    if ([[szDisableOVCheck uppercaseString] ContainString:@"ERROR"])
    {
        [szReturnValue setString:@"Set DisableOVCheck fail!"];
        ATSDebug(@"Set DisableOVCheck fail!");
        return [NSNumber numberWithBool:NO];
    }
    return [NSNumber numberWithBool:YES];
}

-(NSNumber *)CHECK_FIXTURE_ALIVE:(NSDictionary *)dicSetting
					RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSDictionary	*dicSend	= [dicSetting objectForKey:@"SEND"];
    NSDictionary	*dicRead	= [dicSetting objectForKey:@"READ"];
    [self SEND_COMMAND:dicSend];
    NSNumber		*numRet		= [self READ_COMMAND:dicRead
							   RETURN_VALUE:szReturnValue];
    if ([numRet boolValue])
        return  [NSNumber numberWithBool:YES];
    else
    {
        NSAlert *alert = [[NSAlert alloc]init];
        alert.messageText = @"警告(Warning)";
        alert.informativeText = @"治具回值錯誤，程式將自動關閉，請檢查治具的狀態然後重啓程式！\n(Fixture response error! MUIFA will be closed later,please check fixture status and reopen MUIFA!)";
        [alert addButtonWithTitle:@"确认(OK)"];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
        [alert release];
        [NSApp terminate:self];
    }
    return [NSNumber numberWithBool:NO];
}

@end




