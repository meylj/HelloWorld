//
//  IADevice_ButtonTest.m
//  FunnyZone
//
//  Created by Cheng Ming on 2011/10/28.
//  Copyright 2011年 PEGATRON. All rights reserved.
//

#import "IADevice_ButtonTest.h"

@implementation TestProgress (IADevice_ButtonTest)

//Start 2011.10.28 Add by Ming 
// Descripton:create a thread to read the DUT's key status, until m_bTestButton = NO
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)TEST_BUTTON_THREAD:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue
{
    //steat the button test, BoolTestFlag = yes.
    [m_dicMemoryValues setObject:[NSNumber numberWithBool:YES] forKey:kIADevice_ButtonTest_BoolTestFlag];
    [NSThread detachNewThreadSelector:@selector(TestButtonFlex:) toTarget:self withObject:dicContents];        
    [strReturnValue setString:@"PASS"];
    
    return [NSNumber numberWithBool:YES];
}
//End 2011.10.28 Add by Ming


//Start 2011.10.28 Add by Ming 
// Descripton:Set the Fixture Ringer's Position, accordance with DUT ringer's Position
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value

-(NSNumber*)RINGER_POSITION_SETTING:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue
{
    NSString *szRinger0 = [m_dicMemoryValues valueForKey:@"RingerOrigin"];
	NSString *szValue1 = [dicContents valueForKey:@"COMMANDFIRST"];
	NSString *szValue2 = [dicContents valueForKey:@"COMMANDSECOND"];
    NSString *szValue3 = [dicContents valueForKey:@"COMMANDTHIRD"];
    NSString *szTarget = [dicContents objectForKey:kFZ_Script_DeviceTarget];
    int iDelayTime = [[dicContents valueForKey:@"DELAYTIME"]intValue];
    NSString *szDeviceTargetTX = [NSString stringWithFormat:@"TX ==> [%@]",szTarget]; 
    NSString *szDeviceTargetRX = [NSString stringWithFormat:@"RX ==> [%@]",szTarget];
    PEGA_ATS_UART   *uartObj    = [[m_dicPorts objectForKey:szTarget] objectAtIndex:kFZ_SerialInfo_UartObj];
    
	NSMutableString *strReadData = [[NSMutableString alloc] initWithString:@""];
	int iRet;
    
    if([szRinger0 intValue] == 1)
    {
        
        [uartObj Clear_UartBuff:kUart_ClearInterval TimeOut:kUart_CommandTimeOut readOut:nil];
        //iRet = [uartObj Write_UartCmd_WithSting:szValue1];
        iRet = [uartObj Write_UartCommand:szValue1 PackedNum:1 Interval:0 IsHex:NO];
        ATSDebug(@"TX ==> [%@]:%@",szTarget,szValue1);
        [IALogs CreatAndWriteUARTLog:szValue1 atTime:kIADeviceALSFileNameDate fromDevice:szDeviceTargetTX withPath:[NSString stringWithFormat:@"%@/%@_%@_Uart.txt",kPD_LogPath_Uart,m_szPortIndex,m_szStartTime] binary:NO];
        iRet = [uartObj Read_UartData:strReadData 
						   TerminateSymbol:[NSArray arrayWithObject:@"@_@"] 
								 MatchType:0 
							  IntervalTime:0.01 
								   TimeOut:5];
        ATSDebug(@"RX ==> [%@]:%@",szTarget,strReadData);
        
        [IALogs CreatAndWriteUARTLog:[NSString stringWithFormat:@"%@\n",strReadData] atTime:kIADeviceALSFileNameDate fromDevice:szDeviceTargetRX withPath:[NSString stringWithFormat:@"%@/%@_%@_Uart.txt",kPD_LogPath_Uart,m_szPortIndex,m_szStartTime] binary:NO];
        
        usleep(iDelayTime);
        
        [uartObj Clear_UartBuff:kUart_ClearInterval TimeOut:kUart_CommandTimeOut readOut:nil];
        //iRet = [uartObj Write_UartCmd_WithSting:szValue3];
        iRet = [uartObj Write_UartCommand:szValue3 PackedNum:1 Interval:0 IsHex:NO];
        ATSDebug(@"TX ==> [%@]:%@",szTarget,szValue3);
        [IALogs CreatAndWriteUARTLog:szValue3 atTime:kIADeviceALSFileNameDate fromDevice:szDeviceTargetTX withPath:[NSString stringWithFormat:@"%@/%@_%@_Uart.txt",kPD_LogPath_Uart,m_szPortIndex,m_szStartTime] binary:NO];
        iRet = [uartObj Read_UartData:strReadData 
                      TerminateSymbol:[NSArray arrayWithObject:@"@_@"] 
                            MatchType:0 
                         IntervalTime:0.01 
                              TimeOut:5];
        ATSDebug(@"RX ==> [%@]:%@",szTarget,strReadData);
        
        [IALogs CreatAndWriteUARTLog:[NSString stringWithFormat:@"%@\n",strReadData] atTime:kIADeviceALSFileNameDate fromDevice:szDeviceTargetRX withPath:[NSString stringWithFormat:@"%@/%@_%@_Uart.txt",kPD_LogPath_Uart,m_szPortIndex,m_szStartTime] binary:NO];
        
        usleep(iDelayTime);
        
        [uartObj Clear_UartBuff:kUart_ClearInterval TimeOut:kUart_CommandTimeOut readOut:nil];
        //iRet = [uartObj Write_UartCmd_WithSting:szValue2];
        iRet = [uartObj Write_UartCommand:szValue2 PackedNum:1 Interval:0 IsHex:NO];
        ATSDebug(@"TX ==> [%@]:%@",szTarget,szValue2);
        [IALogs CreatAndWriteUARTLog:szValue2 atTime:kIADeviceALSFileNameDate fromDevice:szDeviceTargetTX withPath:[NSString stringWithFormat:@"%@/%@_%@_Uart.txt",kPD_LogPath_Uart,m_szPortIndex,m_szStartTime] binary:NO];
        iRet = [uartObj Read_UartData:strReadData 
                      TerminateSymbol:[NSArray arrayWithObject:@"@_@"] 
                            MatchType:0 
                         IntervalTime:0.01 
                              TimeOut:5];
        ATSDebug(@"RX ==> [%@]:%@",szTarget,strReadData);
        
        [IALogs CreatAndWriteUARTLog:[NSString stringWithFormat:@"%@\n",strReadData] atTime:kIADeviceALSFileNameDate fromDevice:szDeviceTargetRX withPath:[NSString stringWithFormat:@"%@/%@_%@_Uart.txt",kPD_LogPath_Uart,m_szPortIndex,m_szStartTime] binary:NO];

        [uartObj Clear_UartBuff:kUart_ClearInterval TimeOut:kUart_CommandTimeOut readOut:nil];
 
    }else
    {
        if([szValue2 isEqualToString:@"Ringer Up"])
        {
            [uartObj Clear_UartBuff:kUart_ClearInterval TimeOut:kUart_CommandTimeOut readOut:nil];
            //iRet = [uartObj Write_UartCmd_WithSting:szValue2];
            iRet = [uartObj Write_UartCommand:szValue2 PackedNum:1 Interval:0 IsHex:NO];
            ATSDebug(@"TX ==> [%@]:%@",szTarget,szValue2);
            [IALogs CreatAndWriteUARTLog:szValue2 atTime:kIADeviceALSFileNameDate fromDevice:szDeviceTargetTX withPath:[NSString stringWithFormat:@"%@/%@_%@_Uart.txt",kPD_LogPath_Uart,m_szPortIndex,m_szStartTime] binary:NO];
            iRet = [uartObj Read_UartData:strReadData 
                          TerminateSymbol:[NSArray arrayWithObject:@"@_@"] 
                                MatchType:0 
                             IntervalTime:0.01 
                                  TimeOut:5];
            ATSDebug(@"RX ==> [%@]:%@",szTarget,strReadData);
            
            [IALogs CreatAndWriteUARTLog:[NSString stringWithFormat:@"%@\n",strReadData] atTime:kIADeviceALSFileNameDate fromDevice:szDeviceTargetRX withPath:[NSString stringWithFormat:@"%@/%@_%@_Uart.txt",kPD_LogPath_Uart,m_szPortIndex,m_szStartTime] binary:NO];
            
        }
        usleep(iDelayTime);
        
        [uartObj Clear_UartBuff:kUart_ClearInterval TimeOut:kUart_CommandTimeOut readOut:nil];
        //iRet = [uartObj Write_UartCmd_WithSting:szValue3];
        iRet = [uartObj Write_UartCommand:szValue3 PackedNum:1 Interval:0 IsHex:NO];
        ATSDebug(@"TX ==> [%@]:%@",szTarget,szValue3);
        [IALogs CreatAndWriteUARTLog:szValue3 atTime:kIADeviceALSFileNameDate fromDevice:szDeviceTargetTX withPath:[NSString stringWithFormat:@"%@/%@_%@_Uart.txt",kPD_LogPath_Uart,m_szPortIndex,m_szStartTime] binary:NO];               
        iRet = [uartObj Read_UartData:strReadData 
                      TerminateSymbol:[NSArray arrayWithObject:@"@_@"] 
                            MatchType:0 
                         IntervalTime:0.01 
                              TimeOut:5];
        ATSDebug(@"RX ==> [%@]:%@",szTarget,strReadData);
        
        [IALogs CreatAndWriteUARTLog:[NSString stringWithFormat:@"%@\n",strReadData] atTime:kIADeviceALSFileNameDate fromDevice:szDeviceTargetRX withPath:[NSString stringWithFormat:@"%@/%@_%@_Uart.txt",kPD_LogPath_Uart,m_szPortIndex,m_szStartTime] binary:NO];

        usleep(iDelayTime);  

        [uartObj Clear_UartBuff:kUart_ClearInterval TimeOut:kUart_CommandTimeOut readOut:nil];
        //iRet = [uartObj Write_UartCmd_WithSting:szValue1];
        iRet = [uartObj Write_UartCommand:szValue1 PackedNum:1 Interval:0 IsHex:NO];
        ATSDebug(@"TX ==> [%@]:%@",szTarget,szValue1);
        [IALogs CreatAndWriteUARTLog:szValue1 atTime:kIADeviceALSFileNameDate fromDevice:szDeviceTargetTX withPath:[NSString stringWithFormat:@"%@/%@_%@_Uart.txt",kPD_LogPath_Uart,m_szPortIndex,m_szStartTime] binary:NO];
        
        iRet = [uartObj Read_UartData:strReadData 
                      TerminateSymbol:[NSArray arrayWithObject:@"@_@"] 
                            MatchType:0 
                         IntervalTime:0.01 
                              TimeOut:5];
        ATSDebug(@"RX ==> [%@]:%@",szTarget,strReadData);
        
        [IALogs CreatAndWriteUARTLog:[NSString stringWithFormat:@"%@\n",strReadData] atTime:kIADeviceALSFileNameDate fromDevice:szDeviceTargetRX withPath:[NSString stringWithFormat:@"%@/%@_%@_Uart.txt",kPD_LogPath_Uart,m_szPortIndex,m_szStartTime] binary:NO];
        
        [uartObj Clear_UartBuff:kUart_ClearInterval TimeOut:kUart_CommandTimeOut readOut:nil];
    }
        
    [strReturnValue setString:@"PASS"];
    [strReadData release];
    
    return [NSNumber numberWithBool:YES];    
}

//End 2011.10.28 Add by Ming

- (void)TestButtonFlex:(id)idThread
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    ATSDebug(@"Start TestButtonFlex Monitor");
    NSMutableString    *strReadData = [[NSMutableString alloc] initWithString:@""];
    NSMutableString    *strResult=[[NSMutableString alloc] initWithString:@""];
    NSDictionary *dicSendCommand=[idThread valueForKey:@"SEND_COMMAND"];
    NSDictionary *dicReadCommand=[idThread valueForKey:@"READ_COMMAND_DATA"];
    NSArray      *arrButton=[idThread valueForKey:@"BUTTON_COUNT"];
    [m_dicMemoryValues setValue:arrButton forKey:@"BUTTON"];
    NSMutableArray *arrResult=[[NSMutableArray alloc] init];
    BOOL bFirstRun = YES;
    
    while ([[m_dicMemoryValues objectForKey:kIADevice_ButtonTest_BoolTestFlag] isEqualToNumber:[NSNumber numberWithBool:YES]]) 
    {
        @synchronized(m_dicMemoryValues)
        {
             //send and read command                       
            [self SEND_COMMAND:dicSendCommand];
            [strReadData setString:@""];
            [self READ_COMMAND:dicReadCommand RETURN_VALUE:strReadData];
            
            if (strReadData) 
            {
                for (int i=0; i<[arrButton count]; i++) 
                {
                    NSString *szButtonCount = [arrButton objectAtIndex:i];
                    if ([szButtonCount isKindOfClass:[NSString class]]) {
                        NSRange aRange=[strReadData rangeOfString:[arrButton objectAtIndex:i]];
                        if (NSNotFound == aRange.location || aRange.length<=0 || [strReadData length] < aRange.length+aRange.location+1)
                        {
                            if (!bFirstRun) 
                            {
                                [[arrResult objectAtIndex:i] appendString:[NSMutableString stringWithString:@"$"]];
                            }
                            else
                            {
                                [strResult setString:@"$"];
                                [arrResult insertObject:[NSMutableString stringWithString:strResult] atIndex:i]; 
                                
                            }
                            ATSDebug(@"Can't find %@",[arrButton objectAtIndex:i]);
                        }
                        else
                        {
                            NSString *szValue=[strReadData substringFromIndex:aRange.length+1+aRange.location];
                            if([szValue length]<2)
                            {
                                ATSDebug(@"can't find button status!");
                            }
                            else
                            {
                                szValue=[szValue substringToIndex:1];
                                
                                //Judge if it first run ? append the button status to a string.
                                if (!bFirstRun) 
                                {
                                    [[arrResult objectAtIndex:i] appendString:[NSMutableString stringWithString:szValue]];
                                }
                                else
                                {
                                    [strResult setString:@""];
                                    [strResult appendString:szValue];
                                    [arrResult insertObject:[NSMutableString stringWithString:strResult] atIndex:i]; 
                                    
                                }
                                [m_dicMemoryValues setValue:[arrResult objectAtIndex:i] forKey:[arrButton objectAtIndex:i]];
                                NSLog(@"Every Cycle Key and Value: %@ = %@",[arrButton objectAtIndex:i], [m_dicMemoryValues valueForKey:[arrButton objectAtIndex:i]]);
                            }
                            
                        }
                    }
                    else
                    {
                        ATSDebug(@"BUTTON_COUNT is not string type!");
                    }
                }
                bFirstRun = NO;
            }
            else
            {
                ATSDebug(@"READ COMMAND FAIL");
            }
            
        }
        usleep(10000);
    }   
    [strReadData release];
    [arrResult release];
    [strResult release];
    ATSDebug(@"End TestButtonFlex Monitor");
    [pool drain];
}


//Start 2011.10.28 Add by Ming 
// Descripton:Stop the thread to read the DUT's key status, until Set kIADevice_ButtonTest_BoolTestFlag  = NO
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)END_TEST_BUTTON_THREAD:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue
{
    //steat the button test, BoolTestFlag = yes.
    @synchronized(m_dicMemoryValues)
    {
        [m_dicMemoryValues setObject:[NSNumber numberWithBool:NO] forKey:kIADevice_ButtonTest_BoolTestFlag];
    }
    return [NSNumber numberWithBool:YES];
}
//End 2011.10.28 Add by Ming


//Add by Jeff
-(NSNumber*)CHECK_BUTTON_STATUS:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue
{
    double dTimeOut =[ [dicContents objectForKey:@"TIMEOUT"] doubleValue];
    NSArray  *arrButton=[m_dicMemoryValues valueForKey:@"BUTTON"];
    NSArray *arrStatus=[dicContents objectForKey:@"STATUS_KEYS"];
    NSString *szMatchType = [dicContents objectForKey:@"MATCHTYPE"];
    BOOL bCheckAll = [[dicContents objectForKey:@"CHECKALL"] boolValue];
    BOOL bForcePass = [[dicContents objectForKey:@"FORCEPASS"] boolValue];
    NSDate *dateStart = [NSDate date];
    double dSpendtime=0;
    BOOL bReturn= NO;
    BOOL bOnePass = NO;
    
    int index = 0;
    
    if (bForcePass) 
    {
        index = [[dicContents objectForKey:@"BUTTON_INDEX"] intValue];
    }
    
    //dowhile to check the button status if changed
    do{
        @synchronized(m_dicMemoryValues)
        {
            NSArray *arrTemp =[m_dicMemoryValues allKeys];
            dSpendtime = [[NSDate date] timeIntervalSinceDate:dateStart];
            BOOL bAllPass = NO;
            for (int i=0; i<[arrButton count]; i++) 
            {
                if (!bCheckAll) 
                {
                    i = [[dicContents objectForKey:@"BUTTON_INDEX"] intValue];
                }
                
                if ([arrTemp containsObject:[arrButton objectAtIndex:i]])
                {
                    BOOL bMatch = NO;
                
                    //judge if can find the button status which gived in plist.
                    //szMatchType:  if it is 0,must match all status;if it is 1,just need match any status .
                    for (int j = 0; j < [arrStatus count]; j++) 
                    {
                        NSRange range1=[[m_dicMemoryValues valueForKey:[arrButton objectAtIndex:i]] rangeOfString:[arrStatus objectAtIndex:j]];
                        if((NSNotFound == range1.location || [[m_dicMemoryValues valueForKey:[arrButton objectAtIndex:i]] length] < range1.length+range1.location || range1.length == 0))
                        {
                            bMatch = NO;
                            NSLog(@"The Button %@ Status is not Ok!",[arrButton objectAtIndex:i]);
                            if ([szMatchType isEqualToString:@"0"])
                            {
                                break;
                            }
                        }
                        else
                        {
                            bMatch = YES;
                            NSLog(@"The Button %@ Status Value %@ suit to the conditon: %@",[arrButton objectAtIndex:i], [m_dicMemoryValues valueForKey:[arrButton objectAtIndex:i]], [arrStatus objectAtIndex:j]);
                            if ([szMatchType isEqualToString:@"1"])
                            {
                                break;
                            }
                        }
                    }
                    if (!bMatch)
                    {
                        bAllPass = NO;
                        break;
                    }
                    else
                    {
                        bAllPass = YES;
                        if (!bCheckAll) 
                        {
                            break;
                        }
                        else if(bForcePass && i==index)
                        {
                            bOnePass = YES;
                        }
                    }
                }
                else
                {
                    bAllPass = NO;
                    ATSDebug(@"Can't Find Key");
                }                                
            }
            if (bAllPass) 
            {
                bReturn = YES;
                break;
            }
            
        }
        usleep(10000);
    }while(dSpendtime<dTimeOut);
    
    if (bOnePass) 
    {
        bReturn = YES;
    }
    
    if (bReturn)
    {
        [strReturnValue setString:@"PASS"];
    }
    else
    {
        [strReturnValue setString:@"FAIL"];
    }
    return [NSNumber numberWithBool:bReturn];
}

// Homebutton check tool
- (NSNumber *)CHECK_HOMEBTN_STATUS :(NSDictionary *)dicpara RETURN_VALUE:(NSMutableString*)strReturnValue
{
    BOOL    bRet = NO;
    if(!dicpara)   return [NSNumber numberWithBool:bRet];
    NSString    *btnTobeChecked = [dicpara objectForKey:@"CHECKBUTTON"];
    NSString    *btnToJudge = [dicpara objectForKey:@"JUDGEBUTTON"];
    NSString    *btnNextButton = [dicpara objectForKey:@"NEXTBUTTON"];
    NSDictionary *dicSendCommand=[dicpara valueForKey:@"SEND_COMMAND"];
    NSDictionary *dicReadCommand=[dicpara valueForKey:@"READ_COMMAND_DATA"];
    NSMutableString    *strReadData = [[NSMutableString alloc] initWithString:@""];
    NSString    *szCheckedBtnKey = @"NULL", *szJudgeBtnKey = @"NULL";
    do {
        // get return value bu sending command gpio
        [self SEND_COMMAND:dicSendCommand];
        [strReadData setString:@""];
        [self READ_COMMAND:dicReadCommand RETURN_VALUE:strReadData];
        
        // get the status of btnTobeChecked
        NSRange range = [strReadData rangeOfString:btnTobeChecked];
        if(range.location!=NSNotFound)
            szCheckedBtnKey = [strReadData substringFromIndex:range.location];
        range = [szCheckedBtnKey rangeOfString:btnToJudge];
        if(range.location!=NSNotFound)
            szCheckedBtnKey = [szCheckedBtnKey substringToIndex:range.location];
        
        // get the status of btnToJudge
        range = [strReadData rangeOfString:btnToJudge];
        if(range.location!=NSNotFound)
            szJudgeBtnKey = [strReadData substringFromIndex:range.location];
        range = [szJudgeBtnKey rangeOfString:btnNextButton];
        if(range.location!=NSNotFound)
            szJudgeBtnKey = [szJudgeBtnKey substringToIndex:range.location];
        
        // judge
        if ([szCheckedBtnKey rangeOfString:@"0"].location != NSNotFound) 
        {
            break;
        }
        if([szJudgeBtnKey rangeOfString:@"0"].location != NSNotFound)
        {
            bRet = YES;
            break;
        }
        usleep(10000);
    } while (1);
    [strReadData release];
    return [NSNumber numberWithBool:bRet];
}

@end
