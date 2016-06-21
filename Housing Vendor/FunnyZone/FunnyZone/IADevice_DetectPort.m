//
//  IADevice_DetectPort.m
//  FunnyZone
//
//  Created by Eagle on 10/18/11.
//  Copyright 2011 PEGATRON. All rights reserved.
//

#import "IADevice_DetectPort.h"
#import "IADevice_Operation.h"
#import "IADevice_TestingCommands.h"
extern NSString *BNRMonitorProxCalUUT1Notification;

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
-(NSString *)tryPort:(NSMutableDictionary *)in_out_dicFlags serialPath:(NSString *)in_path deviceList:(NSArray *)in_arrDevices uart:(PEGA_ATS_UART *)uartObj
{
    NSInteger iDeviceCount = [in_arrDevices count];
  // for Prox Cal
    bool bIS_1_to_N =   [[self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_IS_1_to_N] boolValue];
    for (NSInteger iIndex=0; iIndex<iDeviceCount; iIndex++) 
    {
        NSString *szPortType = [in_arrDevices objectAtIndex:iIndex];
        if ([in_out_dicFlags objectForKey:szPortType] && !bIS_1_to_N) {
            continue;
        }
        UInt16 iRet = [uartObj openPort:in_path baudeRate:[kPD_DeviceSet_BaudeRate intValue] dataBit:[kPD_DeviceSet_DataBit intValue] parity:kPD_DeviceSet_Parity stopBits:[kPD_DeviceSet_StopBit intValue] endSymbol:kPD_DeviceSet_EndFlag];
		// add by jingfu ran on 2012 04 26
        BOOL   bISHex = NO;
        if ((kPD_DeviceSet_Hex != nil)) 
        {
			bISHex = [kPD_DeviceSet_Hex boolValue];
        }
        //end by jingfu ran n 04 26
		
        if(iRet == kUart_SUCCESS)
        {
            NSInteger iMatchType = [kPD_DeviceSet_MatchType intValue];
            if([kPD_DeviceSet_Type intValue] == kPD_DeviceSet_Type_String)
            {
                NSMutableString *szReturn = [[NSMutableString alloc] init];
                [uartObj Clear_UartBuff:kUart_ClearInterval TimeOut:kUart_CommandTimeOut readOut:nil];
                //[uartObj Write_UartCmd_WithSting:kPD_DeviceSet_Try];
                [uartObj Write_UartCommand:kPD_DeviceSet_Try PackedNum:0 Interval:1000 IsHex:bISHex];
				//modified by jingfu ran on 2012 04 26. No pass the unique NO
                iRet = [uartObj Read_UartData:szReturn TerminateSymbol:kPD_DeviceSet_Expect MatchType:iMatchType IntervalTime:kUart_IntervalTime TimeOut:kUart_CommandTimeOut];                
                [szReturn release]; 
                szReturn = nil;
            }
            else
            {
                NSMutableData *dataReturn = [[NSMutableData alloc] init];
                [uartObj Clear_UartBuff:kUart_ClearInterval TimeOut:kUart_CommandTimeOut readOut:nil];
                //[uartObj Write_UartCmd_WithHex:kPD_DeviceSet_Try];
                [uartObj Write_UartCommand:kPD_DeviceSet_Try PackedNum:1 Interval:0 IsHex:YES];
                //iRet = [uartObj deal_Read_UartDataByBytes:dataReturn TerminateSymbol:[kPD_DeviceSet_Expect componentsSeparatedByString:@" "] MatchType:kUart_MatchAllItems IntervalTime:0.01 TimeOut:5.1];
                iRet = [uartObj Read_UartData:dataReturn TerminateSymbol:kPD_DeviceSet_Expect/*[kPD_DeviceSet_Expect componentsSeparatedByString:@" "]*/ MatchType:iMatchType IntervalTime:0.01 TimeOut:5.1];
                [dataReturn release];
                dataReturn = nil;                
            }
            if (iRet == kUart_SUCCESS) 
            {
                [in_out_dicFlags setObject:[NSNumber numberWithBool:YES] forKey:szPortType];
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
-(void)listSrialPath:(NSMutableArray *)aryPorts
{
    SearchSerialPorts *sspObject = [[SearchSerialPorts alloc] init]; 
    [sspObject SearchSerialPorts:aryPorts];
    [sspObject release];
}


//2012-04-19 add description by Winter
// For no fixture multi UI, assign ports for each unit. (SerialPort,UartObj,Color,Target)
// Param:
//       NSMutableArray    *in_out_aryPorts    : send out port
//       NSMutableArray    *aryAllProts        : all ports
// Return:
//      Actions result
-(BOOL)forNFMU:(NSMutableArray *)in_out_aryPorts ports:(NSMutableArray *)aryAllProts
{
    NSString *szPortName = [kPD_ModeSet_UnitInfo objectForKey:kPD_UserDefaults_PortName];
    NSInteger iAllCount = [aryAllProts count];
    NSInteger iUUTCount = 0;
    BOOL  retFlag =NO;
    for(NSInteger iIndex=0; iIndex<iAllCount; iIndex++)
    {
        NSString *szSerialPort = [aryAllProts objectAtIndex:iIndex];
        NSRange range = [szSerialPort rangeOfString:szPortName];
        if (range.location != NSNotFound 
            && range.length >0 
            && (range.location + range.length) <= [szSerialPort length]) 
        {
            retFlag =YES;
            iUUTCount++;
            PEGA_ATS_UART *uartObj = [[[PEGA_ATS_UART alloc] init_Uart] autorelease];            
            NSColor *color = [self TransformPortColor:kFZ_UartTableview_WHITE];
            NSArray *aryTarget = [NSArray arrayWithObjects:szSerialPort,uartObj,color, nil];
            NSDictionary *dicTarget = [NSDictionary dictionaryWithObject:aryTarget forKey:kPD_Device_MOBILE]; 
            NSDictionary *dicForUnit = [NSDictionary dictionaryWithObject:dicTarget forKey:[NSString stringWithFormat:@"Unit%d",iUUTCount]];
            [in_out_aryPorts addObject:dicForUnit];
        }
        else
        {
            //retFlag =NO;
        }
    }
    if (!retFlag)
    {
        NSString *errMessage = [NSString stringWithFormat:@"请确认电脑是否有连接测试用线，且线名为%@. (The station need at least one device,but now you plug into 0 or the cable name %@ is not right.Please check it !)", szPortName, szPortName,szPortName, szPortName];
          NSRunAlertPanel(@"警告(Warning)", errMessage , @"确认(OK)", nil, nil);
         return retFlag;
     }
    return YES;
}

//2012-04-19 add description by Winter
// For single fixture single UI, assigh ports for single unit.(SerialPort,UartObj,Color,Target)
// Param:
//       NSMutableArray    *in_out_aryPorts        : send out port
//       NSMutableArray    *aryAllProts            : all ports
//       aryPorts       : list detected ports
//       in_dicDevice   : needed devices : such as MOBILE,FIXTURE...
// Return:
//      Actions result
-(BOOL)forSFSU:(NSMutableArray *)in_out_aryPorts ports:(NSMutableArray *)aryAllProts
{
    BOOL bRet = YES;
    if (![[kPD_ModeSet_UnitInfo objectForKey:kPD_UserDefaults_PutInUse] boolValue]) {
        return YES;
    }
    else
    {
        //get dic of Unit1#....
        NSDictionary *dicDevices = [kPD_ModeSet_UnitInfo objectForKey:kPD_UserDefaults_DeviceRequire];
        //if QT2 use single UI      2012.4.11,  marked, for not used now
        //NSString	*strStationNameIni = [self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_ScriptFileName,nil];
        //for Prox cal
        bool bIS_1_to_N =   [[self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_IS_1_to_N] boolValue];
        // 2012.4.11,  marked, for not used now
        /*
        if ([strStationNameIni isEqualToString:@"QT2-PREBURN.plist"] )
        {
            NSString *szPortName = [[dicDevices objectForKey:kPD_Device_MOBILE] objectForKey:kPD_UserDefaults_PortName];
            if (szPortName) {
                for (NSInteger index=0; index<[aryAllProts count]; index++) {
                    NSRange range = [[aryAllProts objectAtIndex:index] rangeOfString:szPortName];
                    if (range.location != NSNotFound 
                        && range.length>0 
                        &&(range.length+range.location)<= [[aryAllProts objectAtIndex:index] length]) 
                    {
                        NSMutableArray *aryPorts = [NSMutableArray arrayWithObject:[aryAllProts objectAtIndex:index]];
                        [self forNFMU:in_out_aryPorts ports:aryPorts];
                        break;
                    }
                    else
                    {
                        // don’t care
                    }
                }
            }
            else
            {
                NSRunAlertPanel(@"Warning", @"Please set PortName for Mobile in SFSU!" , @"OK", nil, nil);
                return NO;
            }
            return YES;
        }
        */
        //
                        
        //for save needed devices
        NSMutableArray *aryNeedPorts = [[NSMutableArray alloc] init];
        NSArray *aryPorts = [dicDevices allKeys];
        NSInteger iCount = [aryPorts count];
        for(NSInteger iIndex=0; iIndex<iCount; iIndex++)
        {
            NSString *szMainKey = [aryPorts objectAtIndex:iIndex];
            if (![[self getValueFromXML:dicDevices mainKey:szMainKey,kPD_UserDefaults_NoNeed,nil] boolValue]) {
                [aryNeedPorts addObject:szMainKey];                
            }
        }
        
        NSInteger iNeedDeviceNum = [aryNeedPorts count];
        NSDictionary    *dicSerialPortName;
        //for Prox cal
        if(bIS_1_to_N)
        {
            dicSerialPortName  =   [self getValueFromXML:dicDevices mainKey:@"MOBILE",kPD_UserDefaults_PortName,nil];
            iNeedDeviceNum +=[dicSerialPortName count]-1;
        }
                
        if([aryAllProts count] != iNeedDeviceNum)
        {
            NSString *szMessage = [NSString stringWithFormat:@"测试站需要%d根线，但是只有侦测到%d根，请确认。(This station need %d devices, but you plug in %d, please check!)",iNeedDeviceNum,[aryAllProts count],iNeedDeviceNum,[aryAllProts count]];
            NSRunAlertPanel(@"警告(Warning)", szMessage , @"确认(OK)", nil, nil);
            [aryNeedPorts release];
            return NO;
        }
        
        NSMutableDictionary *dicStatus = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *dicTarget = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *dicPorts    =   [NSMutableDictionary dictionary];
        for(NSInteger jIndex=0; jIndex<iNeedDeviceNum; jIndex++)
        {
            NSString *szSerialPort = [aryAllProts objectAtIndex:jIndex];
            PEGA_ATS_UART *uartObj = [[[PEGA_ATS_UART alloc] init_Uart] autorelease];
            NSString *szPortType = [self tryPort:dicStatus serialPath:szSerialPort deviceList:aryNeedPorts uart:uartObj];
            //for Prox cal
            if(bIS_1_to_N && [szPortType isEqualTo:@"MOBILE"])
            {
                if(nil!=dicSerialPortName)
                {
                    NSArray *arrKeys    =   [dicSerialPortName allKeys];
                    NSArray *arrValues  =   [dicSerialPortName allValues];
                    for (int i=0; i<[arrValues count]; i++)
                    {
                        NSRange range   =   [szSerialPort rangeOfString:[arrValues objectAtIndex:i]];
                        if(range.location !=NSNotFound && range.length>0 && (range.location +range.length) <=[szSerialPort length])
                        {
                            [dicPorts setValue:szSerialPort forKey:[arrKeys objectAtIndex:i]];
                        }
                    }
                }
            }
            else
            {
                NSString *szSerialPortName = [self getValueFromXML:dicDevices mainKey:szPortType,kPD_UserDefaults_PortName,nil];
                if ((szSerialPortName != nil) && (szSerialPortName != @"")) 
                {
                    NSRange range = [szSerialPort rangeOfString:szSerialPortName];
                    if (range.location == NSNotFound 
                        || (range.length+range.location)> [szSerialPort length] 
                        || range.length <= 0) 
                    {
                        break;
                    }
                    else
                    {
                        // don‘t care
                    }
                }
            }
            NSString *szColor = kPD_DeviceSet_UartColor;
            if(!szColor || ![[m_dictPortColor allKeys] containsObject:szColor])
            {
                szColor = kFZ_UartTableview_WHITE;
            }
            NSColor *color = [self TransformPortColor:szColor];
            //for Prox cal
            NSArray *aryTarget;
            if(bIS_1_to_N && [szPortType isEqualTo:@"MOBILE"])
            {
                aryTarget  = [NSArray arrayWithObjects:dicPorts,uartObj,color, nil];
            }else
            {
                aryTarget  = [NSArray arrayWithObjects:szSerialPort,uartObj,color, nil];
            }
            ///////////////
            [dicTarget setObject:aryTarget forKey:szPortType];       
        }
        
        //2012.2.23
        //modify by desikan for SFSU detected port   ------begin
        /*if(bIS_1_to_N)
        {
            iNeedDeviceNum -=[dicSerialPortName count]-1;
        }
        if(iNeedDeviceNum != [dicTarget count])
        {
            NSString *szMessage = [NSString stringWithFormat:@"This station need %lu devices .Just %lu devices detected, please check whether fixture power is on!",iNeedDeviceNum,[dicTarget count]];
            NSRunAlertPanel(@"Warning", szMessage , @"OK", nil, nil);
            bRet = NO;
        }*/
        NSMutableString *szErrMessage   =   [[NSMutableString alloc] initWithString:@""];
        for (NSString * szTarget in aryPorts) 
        {
            int iNeedNum    =   0;
            int iDetectNum  =   0;
            if (![[self getValueFromXML:dicDevices mainKey:szTarget,kPD_UserDefaults_NoNeed,nil] boolValue]) 
            {
                if(bIS_1_to_N && [szTarget isEqualToString:kFZ_MOBILE_PortType])
                {
                    iNeedNum    =   [dicSerialPortName count];
                    NSLog(@"%@",dicSerialPortName);
                }
                else
                {
                    iNeedNum    =   1;
                }
            }
            if(nil !=[dicTarget objectForKey:szTarget])
            {
                if(bIS_1_to_N &&[szTarget isEqualToString:kFZ_MOBILE_PortType])
                {
                    iDetectNum  =   [[[dicTarget objectForKey:szTarget] objectAtIndex:kFZ_SerialInfo_SerialPort] count];
                    NSLog(@"%@",[[dicTarget objectForKey:szTarget] objectAtIndex:kFZ_SerialInfo_SerialPort]);
                }
                else
                {
                    iDetectNum  =   1;
                }
            }
            if(iNeedNum != iDetectNum)
            {
                if([szTarget isNotEqualTo:kFZ_MOBILE_PortType])
                {
                    [szErrMessage appendString:[NSString stringWithFormat:@"%@有%d个，只侦测到%d个，请确认%@是否有通电。(%@ need %d devices,but %d devices detected, please check whether %@ power is on\n)",szTarget,iNeedNum,iDetectNum,szTarget,szTarget,iNeedNum,iDetectNum,szTarget]];
                }
                else
                {
                    [szErrMessage appendString:[NSString stringWithFormat:@"%@有%d个，只侦测到%d个。(%@ need %d devices,but %d devices detected\n)",szTarget,iNeedNum,iDetectNum,szTarget,iNeedNum,iDetectNum]];
                }
                bRet = NO;
            }
        }
        if(!bRet)
        {
            NSRunAlertPanel(@"警告(Warning)",szErrMessage,@"确认(OK)" ,nil ,nil);
        }
        //
        [in_out_aryPorts addObject:[NSDictionary dictionaryWithObject:dicTarget forKey:@"Unit1"]];
        [szErrMessage release];
        //2012.2.23
        //modify by desikan for SFSU detected port   ------end
        
        [dicTarget release];
        [dicStatus release];
        [aryNeedPorts release];
        
        return bRet;
    }
}

//2012-04-19 add description by Winter
// For multi fixture multi UI, assigh ports for each unit.(SerialPort,UartObj,Color,Target)
// Param:
//       NSMutableArray    *in_out_aryPorts        : send out port
//       NSMutableArray    *aryAllProts            : all ports
//       aryPorts       : list detected ports
// Return:
//      Actions result
-(BOOL)forMFMU:(NSMutableArray *)in_out_aryPorts ports:(NSMutableArray *)aryAllProts
{
    BOOL bRet = YES;
	//For Prox cal
    bool bIS_1_to_N =   [[self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_IS_1_to_N] boolValue];
	
    NSArray *aryKeys = [kPD_ModeSet_UnitInfo allKeys];
    NSInteger iSetListCount = [aryKeys count];
	NSMutableDictionary *dicPorts    =   [NSMutableDictionary dictionary];
    
    for (NSInteger iIndex=0; iIndex<iSetListCount; iIndex++) 
    {
        NSString *szCurrentKey = [NSString stringWithFormat:@"Unit%d", iIndex + 1];
        NSDictionary *dicEachUnitSet = [kPD_ModeSet_UnitInfo objectForKey:szCurrentKey];
        if ([dicEachUnitSet isKindOfClass:[NSDictionary class]]) 
        {
            if ([[dicEachUnitSet objectForKey:kPD_UserDefaults_PutInUse] boolValue]) 
            {
                //get dic of Unit1#....
                NSDictionary *dicDevices = [dicEachUnitSet objectForKey:kPD_UserDefaults_DeviceRequire];
                NSMutableDictionary *dicTarget = [[NSMutableDictionary alloc] init];
                BOOL    bComparedAllName = YES;
                BOOL    bComparedOneName = YES;
                NSArray *aryPorts = [dicDevices allKeys];
                NSInteger iCount = [aryPorts count];
                // kyle 2012.4.11 modify the parameter name "iIndex" to "kIndex".
                for(NSInteger kIndex=0; kIndex<iCount; kIndex++)
                {   
                    NSString *szPortType = [aryPorts objectAtIndex:kIndex];
                    if (![[self getValueFromXML:dicDevices mainKey:szPortType,kPD_UserDefaults_NoNeed,nil] boolValue])
                    {
                        bComparedOneName = NO;
						NSDictionary    *dicSerialPortName = nil;
						NSString *szPortName = @"" ;
						
						//for Prox cal
						if(bIS_1_to_N&& [szPortType isEqualTo:@"MOBILE"])
						{
							dicSerialPortName  =   [self getValueFromXML:dicDevices mainKey:@"MOBILE",kPD_UserDefaults_PortName,nil];
						}
						else
						{
							szPortName = [self getValueFromXML:dicDevices mainKey:szPortType,kPD_UserDefaults_PortName,nil];
						}
						
                        NSInteger iAllPortCount = [aryAllProts count];
                        NSInteger jIndex=0;
                        for (; jIndex<iAllPortCount; jIndex++) 
                        {
                            NSString *szSerialPort = [aryAllProts objectAtIndex:jIndex];
							PEGA_ATS_UART *uartObj = [[[PEGA_ATS_UART alloc] init_Uart] autorelease];
							NSString *szColor = kPD_DeviceSet_UartColor;
							if(!szColor || ![[m_dictPortColor allKeys] containsObject:[szColor uppercaseString]])
							{
								szColor = kFZ_UartTableview_WHITE;
							}
							NSColor *color = [self TransformPortColor:szColor];
							
							//for Prox cal
							if(bIS_1_to_N && [szPortType isEqualTo:@"MOBILE"])
							{
								if(nil!=dicSerialPortName)
								{
									NSArray *arrKeys    =   [dicSerialPortName allKeys];
									NSArray *arrValues  =   [dicSerialPortName allValues];
									for (int i=0; i<[arrValues count]; i++)
									{
										NSRange range   =   [szSerialPort rangeOfString:[arrValues objectAtIndex:i]];
										if(range.location !=NSNotFound && range.length>0 && (range.location +range.length) <=[szSerialPort length])
										{
											bComparedOneName = YES;
											[dicPorts setValue:szSerialPort forKey:[arrKeys objectAtIndex:i]];
											NSArray *aryTarget = [NSArray arrayWithObjects:dicPorts,uartObj,color, nil];
											[dicTarget setObject:aryTarget forKey:szPortType];
											break;
										}
									}
								}
							}
							else if ((szPortName != nil) && (szPortName != @"")) 
							{
								NSRange range = [szSerialPort rangeOfString:szPortName];
								if (range.location != NSNotFound 
									&& range.length >0 
									&& (range.location +range.length) <= [szSerialPort length]) 
								{
									bComparedOneName = YES;
									
									NSArray *aryTarget = [NSArray arrayWithObjects:szSerialPort,uartObj,color, nil];
									[dicTarget setObject:aryTarget forKey:szPortType];
									break;
								}
                            }
                            else
                            {
                                // don’t care
                            }
                        }
                        bComparedAllName &= bComparedOneName;
                        if (!bComparedOneName) 
						{
                            NSString *szTemp = [self formatLog_transferObject:aryAllProts];
							NSString *szMessage;
							if (bIS_1_to_N && [szPortType isEqualTo:@"MOBILE"])
							{
								szMessage = [NSString stringWithFormat:@"MFMU: 需要的线名为%@，为%@找不到线名为%@的线。(MFMU : Can't find serial path named %@ for %@ in all paths :\n%@)",dicSerialPortName,szPortType,szTemp,dicSerialPortName,szPortType,szTemp];
							}
							else
							{
								szMessage = [NSString stringWithFormat:@"MFMU: 需要的线名为%@，为%@找不到线名为%@的线。(MFMU : Can't find serial path named %@ for %@ in all paths :\n%@)",dicSerialPortName,szPortType,szTemp,dicSerialPortName,szPortType,szTemp];							}
                            NSRunAlertPanel(@"警告(Warning)",szMessage, @"确认(OK)", nil, nil);
                            break;
                        }
                    }
					if (bIS_1_to_N && bComparedAllName)
					{
						if (![in_out_aryPorts containsObject:[NSDictionary dictionaryWithObject:dicTarget forKey:szCurrentKey]]) 
						{
							[in_out_aryPorts addObject:[NSDictionary dictionaryWithObject:dicTarget forKey:szCurrentKey]];
						}
					}
                }
                if (!bIS_1_to_N&& bComparedAllName) 
                {
                    [in_out_aryPorts addObject:[NSDictionary dictionaryWithObject:dicTarget forKey:szCurrentKey]];
                }
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
    BOOL bRet = YES;
    NSMutableArray *arrSerialPorts = [[NSMutableArray alloc] init];
    [self listSrialPath:arrSerialPorts];
    
    if ([kPD_ModeSet_Mode isEqualToString:kPD_Mode_SFSU]) 
    {
        //for single fixture single ui
        bRet = [self forSFSU:in_out_aryPorts ports:arrSerialPorts];
    }
    else if([kPD_ModeSet_Mode isEqualToString:kPD_Mode_NFMU])
    {
        //for no fixture multi ui
        bRet = [self forNFMU:in_out_aryPorts ports:arrSerialPorts];
    }
    else if([kPD_ModeSet_Mode isEqualToString:kPD_Mode_MFMU])
    {
        //for multi fixture multi ui
        bRet = [self forMFMU:in_out_aryPorts ports:arrSerialPorts];
    }
    else
    {
        //unnormal
        NSRunAlertPanel(@"警告(Warning)", @"请设置正确的测试软件的模式。(Please set right Mode(SFSU,NFMU,MFMU) in setting file!)", @"确认(OK)", nil, nil);
        bRet = NO;        
    }
    
    //2012.2.23
    //modify by desikan for set kong cable mode, if assign ports fail, don't set.
    if(bRet)
    {
        bRet    =   [self Set_KongCable_Auto_diags:in_out_aryPorts];
    }
    [arrSerialPorts release];
    return bRet;
}

-(void)monitorSerialPortPlugInWithUartPath:(NSString *)in_szUARTPath withOutputSN:(NSMutableString *) out_szSN
{
    NSMutableString *szReadString = [[NSMutableString alloc] init];
    do {
        if ([self checkUnitConnectWellWithSerialPort:in_szUARTPath UARTCommand:@"" UartResponse:szReadString CheckTime:1.00]) 
        {
            if ([szReadString ContainString:@"]"]) {
                break;
            }
            if ([szReadString ContainString:@"login:"] || [szReadString ContainString:@"iPad:~ root#"]) 
            {
                break;
            }
            if ([self checkUnitConnectWellWithSerialPort:in_szUARTPath UARTCommand:@"sn" UartResponse:szReadString CheckTime:10])
            {
                NSRange rangeSerial = [szReadString rangeOfString:@"Serial:"];
                if(NSNotFound != rangeSerial.location 
                   && rangeSerial.length > 0 
                   && (rangeSerial.length + rangeSerial.location) <= [szReadString length])
                {
                    [szReadString setString:[szReadString substringFromIndex:rangeSerial.location + rangeSerial.length]];
                    NSRange rangeEndSymbol = [szReadString rangeOfString:@":-)"];

                    if (NSNotFound != rangeEndSymbol.location 
                        && rangeEndSymbol.length > 0
                        && (rangeEndSymbol.length + rangeEndSymbol.location) <= [szReadString length])
                    {
                        [szReadString setString:[szReadString substringToIndex:rangeEndSymbol.location]];
                        [out_szSN setString:[NSString stringWithString:szReadString]];
                        break;
                    }
                    else
                    {
                         // don‘t care
                    }
                }
                else
                {
                    // don’t care
                }
            }
        }
        // sleep 1 second
        sleep(1);
        
    } while (YES);
    [szReadString release];
}
- (BOOL)checkUnitConnectWellWithFixturePort:(NSString *)in_szUARTPath UARTCommand:(NSString *)in_szCommand UartResponse:(NSMutableString *)in_out_szResponse CheckTime:(NSTimeInterval)inCheckTime
{  
     NSDictionary *dicForFixture = [NSDictionary dictionaryWithObject:kPD_Device_FIXTURE forKey:kFZ_Script_DeviceTarget]; 
    NSString        *szPortType   = [dicForFixture objectForKey:kFZ_Script_DeviceTarget];//#define kIADeviceDeviceTarget @"TARGET"
    NSString        *szBsdPath = in_szUARTPath;
    NSMutableString *szReadString = [[NSMutableString alloc] init];

    NSInteger       iSpeed = [kPD_DeviceSet_BaudeRate intValue];
    NSInteger       iDataBit = [kPD_DeviceSet_DataBit intValue];
    NSString        *szParity = kPD_DeviceSet_Parity;
    NSInteger       iStopBit = [kPD_DeviceSet_StopBit intValue]; 
    NSString        *szEndsymbol = kPD_DeviceSet_EndFlag;
    NSInteger       iRet = -1;
    PEGA_ATS_UART   *uartObj    = [[PEGA_ATS_UART alloc] init];
    
    iRet = [uartObj openPort:szBsdPath baudeRate:iSpeed dataBit:iDataBit parity:szParity stopBits:iStopBit endSymbol:szEndsymbol];
    
    if(kUart_SUCCESS == iRet)//iRet== 0 --> succeed
    {
        if (0 == iRet)
        {
            for (int i = 0; i < 3; i++)
            {
                iRet = [uartObj Clear_UartBuff:kUart_ClearInterval TimeOut:kUart_CommandTimeOut readOut:nil];
                if (0 == iRet)
                {
                    iRet = [uartObj Write_UartCommand:in_szCommand PackedNum:1 Interval:0 IsHex:NO];
                }
                if (0 == iRet)
                {	
                    iRet = [uartObj Read_UartData:szReadString TerminateSymbol:[NSArray arrayWithObjects:@"*_*", nil] MatchType:1 IntervalTime:0.3 TimeOut:inCheckTime];
                    [in_out_szResponse setString:[NSString stringWithString:szReadString]];
                }
                if (0 == iRet)
                {
                    break;
                }
                else if(iRet == kUart_ERROR)
                {
                    [uartObj Close_Uart];
                    [uartObj release];
                    
                    NSLog(@"kUart_ERROR: 241error");
                    uartObj = [[PEGA_ATS_UART alloc] init];
                    iRet = -1;
                    iRet = [uartObj openPort:szBsdPath baudeRate:iSpeed dataBit:iDataBit parity:szParity stopBits:iStopBit endSymbol:szEndsymbol];
                }
                usleep(100000);
            }
            
        }
        [uartObj Close_Uart];
        [uartObj release];
        uartObj = nil;
        [szReadString release];
        if (0 == iRet) 
        {
            return YES;
        }
        else
        {
            return NO;
        }

    }
    else
    {
        [uartObj Close_Uart];
        [uartObj release];
        uartObj = nil;
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
    NSMutableString *szReadString = [[NSMutableString alloc] init];
    do {
        if ([self checkUnitConnectWellWithFixturePort:in_szUARTPath UARTCommand:@"" UartResponse:szReadString CheckTime:0.65]) 
        {
            if ([szReadString ContainString:@"*_*"]) 
            {                
                if ([self checkUnitConnectWellWithFixturePort:in_szUARTPath UARTCommand:@"read sensor" UartResponse:szReadString CheckTime:10])
                {
                    NSRange rangeSerial = [szReadString rangeOfString:@"up/down/back/advance="];
                    if(NSNotFound != rangeSerial.location 
                    && rangeSerial.length > 0 
                    && (rangeSerial.length + rangeSerial.location) <= [szReadString length])
                    {
                        [szReadString setString:[szReadString substringFromIndex:rangeSerial.location + rangeSerial.length]];
                        NSRange rangeEndSymbol = [szReadString rangeOfString:@"*_*"];
                    
                        if (NSNotFound != rangeEndSymbol.location 
                            && rangeEndSymbol.length > 0
                            && (rangeEndSymbol.length + rangeEndSymbol.location) <= [szReadString length])
                        {
                            [szReadString setString:[szReadString substringToIndex:rangeEndSymbol.location]];
                            if ([szReadString isEqualToString:@"1010\n"]) 
                            {
                                break;
                            }
                            else
                            {
                            // don‘t care
                            }
            
                        }
                        else
                        {
                        // don‘t care
                        }
                    }
                    else
                    {
                    // don’t care
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
    NSMutableString *szReadString = [[NSMutableString alloc] init];
    BOOL Bret = NO;
    
    if ([self checkUnitConnectWellWithFixturePort:in_szUARTPath UARTCommand:@"in down on" UartResponse:szReadString CheckTime:20])
    {
        if ([szReadString ContainString:@"OK"])
        {
            if ([self checkUnitConnectWellWithFixturePort:in_szUARTPath UARTCommand:@"read sensor" UartResponse:szReadString CheckTime:10])
            {
                NSRange rangeSerial = [szReadString rangeOfString:@"up/down/back/advance="];
                if(NSNotFound != rangeSerial.location && rangeSerial.length > 0 && (rangeSerial.length + rangeSerial.location) <= [szReadString length])
                {
                    [szReadString setString:[szReadString substringFromIndex:rangeSerial.location + rangeSerial.length]];
                    NSRange rangeEndSymbol = [szReadString rangeOfString:@"*_*"];
                    
                    if (NSNotFound != rangeEndSymbol.location 
                        && rangeEndSymbol.length > 0
                        && (rangeEndSymbol.length + rangeEndSymbol.location) <= [szReadString length])
                    {
                        [szReadString setString:[szReadString substringToIndex:rangeEndSymbol.location]];
                        if ([szReadString isEqualToString:@"1010\n"]) 
                        {
                            Bret = YES;
                        }
                        
                    }
                   
                }
               
            }
           
        }
    }
    
    [szReadString release];
    
    if (Bret)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

//2012-4-16 add note by Sunny
//		Check unit plug out.
// Parameter:
//      NSString        in_szUARTPath : serial port path
// Return:
//      the action result
- (void)monitorSerialPortPlugOutWithUartPath:(NSString *)in_szUARTPath
{
    NSMutableString *szReadString = [[NSMutableString alloc] init];
    do {
        if (![self checkUnitConnectWellWithSerialPort:in_szUARTPath UARTCommand:@"" UartResponse:szReadString CheckTime:0.6])
        {
            break;
        }
        else
        {
            usleep(100000);
        }
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
- (BOOL)checkUnitConnectWellWithSerialPort:(NSString *)in_szUARTPath UARTCommand:(NSString *)in_szCommand UartResponse:(NSMutableString *)in_out_szResponse CheckTime:(NSTimeInterval)inCheckTime
{
	bool bIS_1_to_N =   [[self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_IS_1_to_N] boolValue];
    NSMutableString *szReadString = [[NSMutableString alloc] init];
    PEGA_ATS_UART *uartObj = [[PEGA_ATS_UART alloc] init];
    int     iRet = -1;
    
    NSString *szPortType = kPD_Device_MOBILE;
    
    // modified by betty 12/4/11 for reading baudeRate from muifa
    iRet = [uartObj openPort:in_szUARTPath baudeRate:[kPD_DeviceSet_BaudeRate intValue] dataBit:[kPD_DeviceSet_DataBit intValue] parity:kPD_DeviceSet_Parity stopBits:[kPD_DeviceSet_StopBit intValue] endSymbol:kPD_DeviceSet_EndFlag];
    if (0 == iRet)
    {
        for (int i = 0; i < 3; i++)
        {
            iRet = [uartObj Clear_UartBuff:kUart_ClearInterval TimeOut:kUart_CommandTimeOut readOut:nil];
            if (0 == iRet)
            {
                iRet = [uartObj Write_UartCommand:in_szCommand PackedNum:1 Interval:0 IsHex:NO];
            }
            if (0 == iRet)
            {
                //For prox cal
				if (bIS_1_to_N)
				{
                    // check unit whether pluged out or not before wake up UUT1
                    if (!m_bHasTestedSlot1)
                    {
                        iRet = [uartObj Read_UartData:szReadString TerminateSymbol:[NSArray arrayWithObjects:@":-)",@"]", nil] MatchType:1 IntervalTime:0.3 TimeOut:inCheckTime];  
                    }
                    NSString *strMemoryECID = [m_dicMemoryValues objectForKey:@"LORKY_DEVICE_ECID"];
                    if (strMemoryECID) 
                    {
                        iRet = [uartObj Read_UartData:szReadString TerminateSymbol:[NSArray arrayWithObjects:kFZ_EndFlagFormat, nil] MatchType:1 IntervalTime:0.3 TimeOut:inCheckTime];
                    }
                    //unit plug out or different unit
                    if (0 != iRet) 
                    {
                        iRet = [uartObj Clear_UartBuff:kUart_ClearInterval TimeOut:kUart_CommandTimeOut readOut:nil];
                        if (0 == iRet)
                        {
                            iRet = [uartObj Write_UartCommand:in_szCommand PackedNum:1 Interval:0 IsHex:NO];
                        }
                        if (0 == iRet)
                        {
                            iRet = [uartObj Read_UartData:szReadString TerminateSymbol:[NSArray arrayWithObjects:@":-)",@"]", nil] MatchType:1 IntervalTime:0.3 TimeOut:inCheckTime]; 
                        }
                        //different unit,compare ECID
                        NSString *strProxCalSlot = [m_dicMemoryValues objectForKey:@"ProxCalSlot"];
                        NSString * strUnitECID = [self getECIDNumber:szReadString];
                        NSString *szMessage = [NSString stringWithFormat:@"警告:%@插入机台错误(Warning %@ Plug in wrong unit)",
                                               strProxCalSlot,strProxCalSlot];
                        NSDictionary *dicMessage = [NSDictionary dictionaryWithObjectsAndKeys:szMessage,@"MESSAGE", nil];
                        if (strProxCalSlot && strUnitECID && 
                            [strUnitECID isNotEqualTo:@""] && 
                            ![strMemoryECID isEqualToString:strUnitECID])
                        {
                            NSMutableString *szResult = [[NSMutableString alloc] init];
                            [self CLOSE_PANEL:dicMessage RETURN_VALUE:szResult];
                            [self MESSAGE_PANEL:dicMessage RETURN_VALUE:szResult];
                            [szResult release];
                            iRet = -1;
                        }
                    }
                }
                else 
                {
                    iRet = [uartObj Read_UartData:szReadString TerminateSymbol:[NSArray arrayWithObjects:@":-)",@"]",@"login:",@"root#", nil] MatchType:1 IntervalTime:0.3 TimeOut:inCheckTime];  
                }
                [in_out_szResponse setString:[NSString stringWithString:szReadString]];
            }
            if (0 == iRet)
            {
                break;
            }
            else if(iRet == kUart_ERROR)
            {
                [uartObj Close_Uart];
                [uartObj release];
                
                NSLog(@"kUart_ERROR: 241error");
                uartObj = [[PEGA_ATS_UART alloc] init];
                iRet = -1;
                iRet = [uartObj openPort:in_szUARTPath baudeRate:115200 dataBit:[kPD_DeviceSet_DataBit intValue] parity:kPD_DeviceSet_Parity stopBits:[kPD_DeviceSet_StopBit intValue] endSymbol:kPD_DeviceSet_EndFlag];
            }
            usleep(100000);
        }

    }
    [uartObj Close_Uart];
    [uartObj release];
    uartObj = nil;
    [szReadString release];
    if (0 == iRet) 
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (NSNumber*)DISORCONNECTUSB:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue
{ 
    NSString *szNumber;
    NSString *szArgus = [dicContents objectForKey: @"Argus"];
    NSString        *szPortType   = [dicContents objectForKey:kFZ_Script_DeviceTarget];//#define kIADeviceDeviceTarget @"TARGET"
    NSString        *szBsdPath = [[m_dicPorts objectForKey:szPortType] objectAtIndex:kFZ_SerialInfo_SerialPort];
    NSString *szPath = [dicContents objectForKey:@"Path"];
    NSFileManager *BuilAppPath =[NSFileManager defaultManager];
    
    if ([BuilAppPath fileExistsAtPath:szPath] ==NO)
    {
        ATSDebug(@"There is no app,please check it!");
        return [NSNumber numberWithBool:NO];
    }
    
    NSMutableDictionary *dicSerialNumber =[[NSMutableDictionary alloc] init];
    SearchSerialPorts *sspObject = [[SearchSerialPorts alloc] init]; 
    [sspObject SearchPortsNumber:dicSerialNumber] ;
    if (dicSerialNumber ==NULL ||dicSerialNumber == nil ||[szBsdPath isEqualToString: @""])
    {
        ATSDebug(@"The device is error,Please check it!");
        [dicSerialNumber release];
        [sspObject release];
        return [NSNumber numberWithBool:NO];
    }
    
    szNumber = [dicSerialNumber valueForKey:szBsdPath];
    ATSDebug(@"Serail number%@",szNumber);
    NSTask *task = [[NSTask alloc] init];      
    NSPipe *outPipe = [[NSPipe alloc]init];
    [task setLaunchPath:szPath];
    NSArray *args = [NSArray arrayWithObjects:szNumber,szArgus,nil];
    [task setArguments:args];
    [task setStandardOutput:outPipe];
    [task launch];
    
    NSData *data = [[outPipe fileHandleForReading] readDataToEndOfFile];
    [task waitUntilExit];
    [task release];
    [outPipe release];
    NSString *szString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
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
- (NSNumber*)CHECK_USB_CONNECT_STATUS:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue
{
	// get dicContents para
	BOOL result = YES;
	NSUInteger		iTimeOut = [[dicContents objectForKey:@"TIMEOUT"] intValue];
	NSDictionary	*dicCompareItems = [dicContents objectForKey:@"COMPARE_ITEMS"];
	// Get Kong Cable Number
	NSString		*szNumber;
	NSString        *szPortType   = [dicContents objectForKey:kFZ_Script_DeviceTarget];//#define kIADeviceDeviceTarget @"TARGET"
    NSString        *szBsdPath = [[m_dicPorts objectForKey:szPortType] objectAtIndex:kFZ_SerialInfo_SerialPort];
    NSString		*szPath = [dicContents objectForKey:@"Path"];
    NSFileManager	*BuilAppPath =[NSFileManager defaultManager];
    
	if ([BuilAppPath fileExistsAtPath:szPath] ==NO)
    {
        ATSDebug(@"There is no app,please check it!");
        return [NSNumber numberWithBool:NO];
    }
    
    NSMutableDictionary *dicSerialNumber =[[NSMutableDictionary alloc] init];
    SearchSerialPorts *sspObject = [[SearchSerialPorts alloc] init]; 
    [sspObject SearchPortsNumber:dicSerialNumber] ;
    [sspObject release];//Leehua
    if (dicSerialNumber ==NULL ||dicSerialNumber == nil ||[szBsdPath isEqualToString: @""])
    {
        ATSDebug(@"The device is error,Please check it!");
        [dicSerialNumber release];        
        return [NSNumber numberWithBool:NO];
    }
    szNumber = [dicSerialNumber valueForKey:szBsdPath];
    ATSDebug(@"Serail number%@",szNumber);
    [dicSerialNumber release];//Leehua
	// call task to get the response by /astrisctl tool
	NSArray * aryPara = [NSArray  arrayWithObjects:@"--host",[NSString stringWithFormat:@"KongSWD-%@",szNumber],@"relays", nil];
	[self CallTask:szPath Parameter:aryPara EndString:nil TimeOut:[NSNumber numberWithInt:iTimeOut] ReturnValue:strReturnValue];
	if (strReturnValue)
	{
		// Clear up the response and compare with that form dicContents.
		NSMutableDictionary * dictResponse = [[NSMutableDictionary alloc] init];
		NSArray * ary = [strReturnValue componentsSeparatedByString:@"\n"];
		for (NSString * strTemp in ary)
		{
			NSArray *aryTemp = [strTemp componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
			if ([aryTemp count] >= 3)
			{
				// the first object is key like: vbus
				// the last object is value like: 0
				
				[dictResponse setObject:[aryTemp objectAtIndex:[aryTemp count]-1] forKey:[aryTemp objectAtIndex:0]];
			}
		}
		
		// compare
		for (NSString * strkey in [dicCompareItems allKeys])
		{
			NSString *strValue = [dicCompareItems objectForKey:strkey];
			if (![[dictResponse allKeys] containsObject:strkey])
			{
				[strReturnValue appendFormat:@"did not include key[%@]",strkey];
				result = NO;
			}
			else
			{
				if (![strValue isEqualToString:[dictResponse objectForKey:strkey]])
				{
					result = NO;
					[strReturnValue appendFormat:@"[%@] status is not Match",strkey];
				}
			}
		}
		
		[dictResponse release];
	}
	
	return [NSNumber numberWithBool:result];
}


//for Prox Cal 
//Add 2012/2/7 by desikan
//2012-4-16 add note by Sunny
//		change current slot and tell op to change slot.
// Parameter:
//      bool        bFailCancle : if not cancle to end
//		double		dTimeLimit	: test time limit
//		NSString	szCurrentSlot	:current slot
//		NSString	szNextSlot	:	next slot
//		NSString	szButtion	:	message box button
//		NSString	szMessage	:	unit plug out message
//		NSString	szMessage2	:	unit plug in message
// Return:
//      the action result
- (NSNumber *)Change_Slot:(NSDictionary *)dicSetting Return_Value:(NSMutableString *)szReturnValue
{
    bool    bFailCancle    =   [[dicSetting objectForKey:@"FailCancle"] boolValue];
    NSDate  *dateEnd     =   [NSDate date];
    double  dCostTime   =   [dateEnd timeIntervalSinceDate:dateStartTime];
    double dTimeLimit   =   [[dicSetting objectForKey:@"TimeLimit"] doubleValue];
    if(dCostTime>dTimeLimit && bFailCancle)
    {
        NSRunAlertPanel(@"警告(Warning)", @"距离更换上一个测试槽超过了3分钟，测试程序将会跳到设定的最后的测试项。(Last slot cost time more than 180s, Cancle to END)", @"确认(OK)", nil, nil);
        return [NSNumber numberWithBool:NO];
    }
    if(!m_bFinalResult && bFailCancle)
    {
       return [NSNumber numberWithBool:NO];
    }
    
    NSString *szCurrentSlot    =   [dicSetting objectForKey:@"Unit"];
    NSString *szNextSlot    =   [dicSetting objectForKey:@"Unit2"];
    [m_dicMemoryValues setValue:szNextSlot forKey:@"ProxCalSlot"];
   // NSString    *szButtion  =   [dicSetting objectForKey:@"ABUTTONS"];
    NSString    *szMessage  =   [dicSetting objectForKey:@"Message"];
    NSString    *szMessage2 =   [dicSetting objectForKey:@"Message2"];
    NSMutableString *szResult   =   [[NSMutableString alloc] init];
    NSDictionary    *dicPlugOut =   [NSDictionary dictionaryWithObjectsAndKeys:szMessage,@"MESSAGE",nil];
    NSString *szPortPath    =   [[[m_dicPorts objectForKey:@"MOBILE"] objectAtIndex:0] objectForKey:szCurrentSlot];
    
    if ([szCurrentSlot isEqualToString:@"Slot1"])
    {
        m_bHasTestedSlot1 = YES;
    }
    
	[self MESSAGE_PANEL:dicPlugOut RETURN_VALUE:szResult];
    //[self MSGBOX_COMMAND:dicPlugOut RETURN_VALUE:szResult];

    [self monitorSerialPortPlugOutWithUartPath:szPortPath]; 
	[self CLOSE_PANEL:dicPlugOut RETURN_VALUE:szResult];
   // [self CLOSE_MESSAGE_BOX:dicPlugOut RETURN_VALUE:szResult];
    
    [self CLOSE_TARGET:[NSDictionary dictionaryWithObjectsAndKeys:@"MOBILE", @"TARGET", nil] RETURN_VALUE:szReturnValue];
    
    //post notification to muifa,send ECID,Port,currentalot,nextslot.
    NSString *strECID = [m_dicMemoryValues objectForKey:@"LORKY_DEVICE_ECID"];
    NSArray *arrMessage = [NSArray arrayWithObjects:strECID,m_szPortIndex,szCurrentSlot,szNextSlot, nil];
    if (strECID && [strECID isNotEqualTo:@""]) 
    {
        NSDictionary *dicMessage = [NSDictionary dictionaryWithObject:arrMessage forKey:@"ProxCalMessage"];
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:BNRMonitorProxCalUUT1Notification object:self userInfo:dicMessage];
    }
    NSDictionary    *dicPlugin  =   [NSDictionary dictionaryWithObjectsAndKeys:szMessage2,@"MESSAGE", nil];
   // [self MSGBOX_COMMAND:dicPlugin RETURN_VALUE:szResult];
	[self MESSAGE_PANEL:dicPlugin RETURN_VALUE:szResult];
    szPortPath  =   [[[m_dicPorts objectForKey:@"MOBILE"] objectAtIndex:0] objectForKey:szNextSlot];
    [self monitorSerialPortPlugInWithUartPath:szPortPath withOutputSN:szResult];
    //[self CLOSE_MESSAGE_BOX:dicPlugOut RETURN_VALUE:szResult];
	[self CLOSE_PANEL:dicPlugin RETURN_VALUE:szResult];
	
    // 2012.2.20 Desikan 
    //      Prox-Cal show ready bug(finished test,before plug out unit,ui show READY,but not PASS/FAIL),
    //      get SN from Fonnyzone    
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
    NSDictionary    *dicInfo    =   [NSDictionary dictionaryWithObjectsAndKeys:szPortPath,@"CurrentPath", nil];
    [nc postNotificationName:PostDataToMuifaNote object:self userInfo:dicInfo];
    // post to Muifa
    dateStartTime = [NSDate date];
    [szResult release];
    return [NSNumber numberWithBool:YES];
}
//2012-4-16 add note by Sunny
//		set kong cable auto enter diags mode/
// Parameter:
//      NSMutableArray        arrPorts : serial ports list
// Return:
//      the action result
-(BOOL)Set_KongCable_Auto_diags:(NSMutableArray *)arrPorts
{   
    NSString    *szToolPath    =   @"/usr/local/bin/astrisctl";
    NSMutableString     *szReturn   = [[[NSMutableString alloc]init] autorelease];
    NSString    *szBsdPath;
    bool    bSetPass    =   YES;
    bool    bNeedNotReset   =   YES;
    NSMutableDictionary *dicSetting =   [[[NSMutableDictionary alloc] init] autorelease];
    NSMutableArray  *arrBsdPath     =   [[[NSMutableArray alloc] init] autorelease];
    [dicSetting setObject:@"1" forKey:@"Statu"];
    [dicSetting setObject:szToolPath forKey:@"toolPath"];
    [dicSetting setObject:@"Read" forKey:@"currentAction"];
    bool bIS_1_to_N =   [[self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_IS_1_to_N] boolValue];
    if([arrPorts count]<=0)
    {
        return NO;
    }
    for (int i=0; i<[arrPorts count]; i++)
    {
        NSArray *  arrkey    =   [[arrPorts objectAtIndex:i] allKeys];
        NSDictionary    *dicPortInfo   =   [[arrPorts objectAtIndex:i] objectForKey:[arrkey objectAtIndex:0]];
        if(bIS_1_to_N)
        {
            NSDictionary    *dicPorts   =   [[dicPortInfo objectForKey:kFZ_MOBILE_PortType] objectAtIndex:kFZ_SerialInfo_SerialPort];
            NSArray *arrKey =   [dicPorts allKeys];
            for(int i=0;i<[arrKey count];i++)
            {
                szBsdPath      = [dicPorts objectForKey:[arrKey objectAtIndex:i]];
                if(nil == szBsdPath || [szBsdPath rangeOfString:@"usbserial"].location != NSNotFound)
                {
                    return YES;
                }
                [dicSetting setObject:szBsdPath forKey:@"UartPath"];
                BOOL bSingleNotReset = [[self Set_KongCable_diagsStatus:dicSetting Return_Value:szReturn] boolValue];
                bNeedNotReset &= bSingleNotReset;
                if(!bSingleNotReset)
                {
                    [arrBsdPath addObject:szBsdPath];
                }
            }
        }
        else
        {
            szBsdPath   =   [[dicPortInfo objectForKey:kPD_Device_MOBILE] objectAtIndex:kFZ_SerialInfo_SerialPort];
            if(nil == szBsdPath)
            {
                return YES;
            }
            //2012.05.01 Leehua for Mikey Bus test , because it's just normal uart cable , but not kong cable ,can't be programmed
            if ([szBsdPath rangeOfString:@"usbserial"].location != NSNotFound) 
            {
                return YES;
            }
            [dicSetting setObject:szBsdPath forKey:@"UartPath"];
            BOOL bSingleNotReset = [[self Set_KongCable_diagsStatus:dicSetting Return_Value:szReturn] boolValue];
            bNeedNotReset &= bSingleNotReset;
            if(!bSingleNotReset)
            {
                [arrBsdPath addObject:szBsdPath];
            }
        }
    }
    if(bNeedNotReset)
    {
        return YES;
    }
    for(int i=0;i<[arrBsdPath count];i++)
    {
        [dicSetting setObject:@"Set"forKey:@"currentAction"];
        [dicSetting setObject:[arrBsdPath objectAtIndex:i] forKey:@"UartPath"];
        if(![self Set_KongCable_diagsStatus:dicSetting Return_Value:szReturn])
        {
            NSRunAlertPanel(@"警告(Warning)", @"请确认/usr/local/bin目录下有名为diag_status的文件。(Please make sure /usr/local/bin/diag_status is exist.)", @"确认(OK)", nil, nil);
            bSetPass    =   NO;
            break;
        }
    }
    if(bSetPass)
    {
        NSRunAlertPanel(@"警告(Warning)", @"所有的Kong Cable已设置成使机台自动进diag模式，请重插拔所有的Kong Cable并重开程式。(Already set Kong Cable be auto enter diag mode. Please replug all the Kong cables,and restart the program)", @"确认(OK)", nil, nil);
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
- (NSNumber *)Set_KongCable_diagsStatus:(NSDictionary *)dicPara Return_Value:(NSMutableString *)szReturnValue
{
    SearchSerialPorts *searchSPorts = [[SearchSerialPorts alloc] init];
    NSMutableDictionary *muDic      = [[NSMutableDictionary alloc] init];
    [searchSPorts SearchPortsNumber:muDic];
    NSString    *szToolPath         = [dicPara objectForKey:@"toolPath"];
    NSString    *szBsdPath          = [dicPara objectForKey:@"UartPath"];
    NSString    *szNumber           = [muDic valueForKey:szBsdPath];
    NSArray     *args;
    NSString    *szCurrentAction    =   [dicPara objectForKey:@"currentAction"];
    if([szCurrentAction isEqualToString:@"Read"])
    {
        args       = [NSArray arrayWithObjects:@"--host",[NSString stringWithFormat:@"kong-%@",szNumber],@"printenv",nil];    }
    else
    {
        NSString    *szStatus       = [dicPara objectForKey:@"Statu"];
        args       = [NSArray arrayWithObjects:@"--host",[NSString stringWithFormat:@"kong-%@",szNumber],@"setenv",@"diags",szStatus,nil];
    }
    [muDic release];
    [searchSPorts release];
    if(![self CallTask:szToolPath Parameter:args EndString:nil TimeOut:nil ReturnValue:szReturnValue])
    {
        NSLog(@"can't find the app at path %@",szToolPath);
        return [NSNumber numberWithBool:NO];
    }
    else if([szCurrentAction isEqualToString:@"Read"])
    {
        NSRange range   =   [szReturnValue rangeOfString:@"diags="];
        if(NSNotFound !=range.location &&range.length >0 && (range.location +range.length) <=[szReturnValue length])
        {
            int iCurrentStatu    =   [[szReturnValue substringFromIndex:(range.location +range.length)] intValue];
            if(1==iCurrentStatu)
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
- (NSNumber *)DisableOVCheck_Set_Del:(NSDictionary*)dictSettings RETURN_VALUE:(NSMutableString*)szReturnValue
{
    NSString    *szPortType     = [dictSettings objectForKey:kFZ_Script_DeviceTarget];
    BOOL    bOVCheck   = [[dictSettings objectForKey:@"DEL_DisableOVCheck"] boolValue];
	bool bIs_1_to_N	=	[[self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_IS_1_to_N] boolValue];
	NSString    *szBsdPath;
	if(bIs_1_to_N)
	{
        NSString *szUnit = [dictSettings objectForKey:@"Unit"];
		szBsdPath      = [[[m_dicPorts objectForKey:szPortType] objectAtIndex:kFZ_SerialInfo_SerialPort] objectForKey:szUnit];
	}
	else
	{
        szBsdPath       = [[m_dicPorts objectForKey:szPortType] objectAtIndex:kFZ_SerialInfo_SerialPort];
	}
    NSString    *szToolPath         = [dictSettings objectForKey:@"Path"];
    SearchSerialPorts *searchSPorts = [[SearchSerialPorts alloc] init];
    NSMutableDictionary *muDic      = [[NSMutableDictionary alloc] init];
    [searchSPorts SearchPortsNumber:muDic];
    NSString    *szNumber           = [muDic valueForKey:szBsdPath];
    NSArray  *args;
    NSString    *szArgs;
    if (!bOVCheck) 
    {
        szArgs = [NSString stringWithFormat:@"--host kong-%@ setenv disableOVCheck 1",szNumber];
        args = [szArgs componentsSeparatedByString:@" "];
        
    }
    else
    {
        szArgs = [NSString stringWithFormat:@"--host kong-%@ delenv disableOVCheck",szNumber];
        args = [szArgs componentsSeparatedByString:@" "];
        
    }
    
    [self CallTask:szToolPath Parameter:args EndString:nil TimeOut:nil ReturnValue:szReturnValue];
    
    [muDic release];
    [searchSPorts release];
    
    NSString *szDisableOVCheck = [NSString stringWithString:szReturnValue];
    if ([[szDisableOVCheck uppercaseString] ContainString:@"ERROR"])
    {
        [szReturnValue setString:@"Set DisableOVCheck fail!"];
        ATSDebug(@"Set DisableOVCheck fail!");
        return [NSNumber numberWithBool:NO];
    }
    
    return [NSNumber numberWithBool:YES];
}

-(NSNumber *)CHECK_FIXTURE_ALIVE:(NSDictionary *)dicSetting RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSDictionary *dicSend = [dicSetting objectForKey:@"SEND"];
    NSDictionary *dicRead = [dicSetting objectForKey:@"READ"];
    NSNumber *numRet = [self SEND_COMMAND:dicSend];
    numRet = [self READ_COMMAND:dicRead RETURN_VALUE:szReturnValue];
    if ([numRet boolValue])
    {
        return  [NSNumber numberWithBool:YES];
    }
    else
    {
        NSRunAlertPanel(@"警告(Warning)", @"治具回值錯誤，程式將自動關閉，請檢查治具的狀態然後重啓程式！\n(Fixture response error! MUIFA will be closed later,please check fixture status and reopen MUIFA!)", @"OK", nil, nil);
        [NSApp terminate:self]; 
    }
    return [NSNumber numberWithBool:NO];
}

@end
