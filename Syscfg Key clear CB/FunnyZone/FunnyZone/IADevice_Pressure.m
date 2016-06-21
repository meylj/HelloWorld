//
//  TestProgress+IADevice_Pressure.m
//  FunnyZone
//
//  Created by Eagle on 13-10-18.
//  Copyright (c) 2013年 PEGATRON. All rights reserved.
//

#import "IADevice_Pressure.h"

@implementation TestProgress (IADevice_Pressure)

- (NSNumber *) GET_FIXTURE_HANDLES:(NSDictionary *)dicSubItems RETURN_VALUE:(NSMutableString *)szReturnValue
{
    @synchronized(m_objPublicParams)
    {
        BOOL bFixtureControlled = [m_objPublicParams.fixtureController boolValue];
        if (!bFixtureControlled)
        {
            m_objPublicParams.fixtureController = [NSNumber numberWithBool:YES];
            m_bFixtureControlOnhand = YES;
            
            NSArray *aryInitKeys = [dicSubItems objectForKey:@"KEY_SET"];
            for (NSString *szKey in aryInitKeys)
            {
                [m_objPublicParams.publicMemoryValues setObject:[NSNumber numberWithInt:0] forKey:szKey];
            }
        }
    }
    return [NSNumber numberWithBool:YES];
}

- (NSNumber *) MEMORY_GLOBAL_VALUE:(NSDictionary *)dicSubItems RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSString *szKey = [dicSubItems objectForKey:@"KEY"];
    @synchronized(m_objPublicParams.publicMemoryValues)
    {
        [m_objPublicParams.publicMemoryValues setObject:[NSString stringWithString:szReturnValue] forKey:szKey];
    }
    return [NSNumber numberWithBool:YES];
}

- (NSNumber *) GET_GLOBAL_VALUE:(NSDictionary *)dicSubItems RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSTimeInterval dTimeout = [[dicSubItems objectForKey:@"TIMEOUT"] doubleValue];
    NSInteger iInterval = [[dicSubItems objectForKey:@"INTERVAL"] integerValue];
    NSString *szKey = [dicSubItems objectForKey:@"KEY"];
    NSDate			*dtStartTime = [NSDate date];
    NSTimeInterval dSlashTime = 0.0;
    NSString *szValue = [NSString stringWithFormat:@"%@",[m_objPublicParams.publicMemoryValues objectForKey:szKey]];
    while ((!szValue || [szValue isEqualToString:@"(null)"] || [szValue isEqualToString:@"null"]) && dSlashTime<dTimeout)
    {
        usleep(iInterval);
        szValue = [NSString stringWithFormat:@"%@",[m_objPublicParams.publicMemoryValues objectForKey:szKey]];
        dSlashTime = [[NSDate date] timeIntervalSinceDate:dtStartTime];
    }
    if (!szValue && dSlashTime > dTimeout)
    {
        [szReturnValue setString:@"NULL"];
        return [NSNumber numberWithBool:NO];
    }
    [szReturnValue setString:szValue];
    return [NSNumber numberWithBool:YES];
}

- (NSNumber *) IS_NUMBER:(NSDictionary *)dicSubItems RETURN_VALUE:(NSMutableString *)szReturnValue
{
    float fResult;
    NSScanner *scanner = [NSScanner scannerWithString:szReturnValue];
    if(!([scanner scanFloat:&fResult] && [scanner isAtEnd]))
    {
        [szReturnValue setString:@"Not A Number!"];
        return [NSNumber numberWithBool:NO];
    }
    return [NSNumber numberWithBool:YES];
}

- (NSNumber *) SYNC_WITH_OTHER_DEVICE:(NSDictionary *)dicSubItems RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSString *szIncludeThread = [dicSubItems objectForKey:@"INCLUDED_THREAD"];
    if ([szIncludeThread ContainString:@"/*"] && [szIncludeThread ContainString:@"*/"])
    {
        //szIncludeThread = [[kPD_UserDefaults objectForKey:@"ModeSetting"] objectForKey:@"PUBLIC_FC"];
        szIncludeThread = [NSString stringWithFormat:@"%d",[[m_dicPorts allKeys] count]-1]; //get fixture count
    }
    
    NSInteger iFixtureThread = [szIncludeThread integerValue];
    //NSInteger iFixtureCount = [[[m_dicMemoryValues objectForKey:@"Muifa_Plist"] objectForKey:@"FIXTURE_COUNT"] integerValue];//from setting file
    NSTimeInterval dTimeout = [[dicSubItems objectForKey:@"TIMEOUT"] doubleValue];
    NSInteger iInterval = [[dicSubItems objectForKey:@"SYNC_INTERVAL"] integerValue];
    NSString *szSyncKey = [dicSubItems objectForKey:@"SYNC_KEY"];
    
    BOOL bSelfExcluded = [[dicSubItems objectForKey:@"SELF_EXCLUDED"] boolValue];
    
    if (!bSelfExcluded)
    {
        @synchronized(m_objPublicParams.publicMemoryValues)
        {
            NSInteger iCurrentPortCount = [[m_objPublicParams.publicMemoryValues objectForKey:szSyncKey] integerValue];
            [m_objPublicParams.publicMemoryValues setObject:[NSNumber numberWithInteger:iCurrentPortCount+1] forKey:szSyncKey];
        }
    }    
    
    /*
    @synchronized([m_objPublicParams g_iDynamicPortCount_obj])
    {
        NSInteger iCurrentPortCount = [[m_objPublicParams g_iDynamicPortCount_obj] integerValue];
        [m_objPublicParams setG_iDynamicPortCount_obj:[NSNumber numberWithInteger:iCurrentPortCount+1]];
    }
    */
    
    NSDate			*dtStartTime = [NSDate date];
    NSTimeInterval dSlashTime = 0.0;
    NSInteger iPortCount = [m_objPublicParams.portCount integerValue];
    ATSDebug(@"SYNC_WITH_OTHER_DEVICE: Parallel thread count %d , fixture count %d",iPortCount,iFixtureThread);
    while ([[m_objPublicParams.publicMemoryValues objectForKey:szSyncKey] integerValue] < (iPortCount+iFixtureThread) && dSlashTime < dTimeout)
    {
        usleep(iInterval);
        dSlashTime = [[NSDate date] timeIntervalSinceDate:dtStartTime];
    }
    ATSDebug(@"SYNC_WITH_OTHER_DEVICE: syncKey %@ count %d",szSyncKey,[[m_objPublicParams.publicMemoryValues objectForKey:szSyncKey] integerValue]);
    if ([[m_objPublicParams.publicMemoryValues objectForKey:szSyncKey] integerValue] < (iPortCount+iFixtureThread) || dSlashTime > dTimeout)
    {
        return [NSNumber numberWithBool:NO];
    }
    /*
    @synchronized([m_objPublicParams.publicMemoryValues objectForKey:szSyncKey])
    {
        [m_objPublicParams.publicMemoryValues setObject:[NSNumber numberWithInteger:0] forKey:szSyncKey];
    }
     */
    return [NSNumber numberWithBool:YES];
}

- (void)sampleSingleDevice:(NSArray *)aryObjects
{
    if ([aryObjects count] != 2)
    {
        return;
    }
    NSString *szDevice = [aryObjects objectAtIndex:0];
    NSDictionary *dicSubItems = [aryObjects objectAtIndex:1];
    
    NSDictionary *dicDevice = [dicSubItems objectForKey:szDevice];
    NSDictionary *dicSend = [dicDevice objectForKey:@"Send"];
    NSDictionary *dicReceive = [dicDevice objectForKey:@"Receive"];
    BOOL bIsGlobal = [[dicDevice objectForKey:@"ISGLOBAL"] boolValue];
    BOOL bIsMember = [[dicDevice objectForKey:@"ISMEMBER"] boolValue];
    NSString *szSaveKey = [dicDevice objectForKey:@"SAVE_KEY"];
    NSInteger iSampleCount = [[dicDevice objectForKey:@"SampleCount"] integerValue];
    NSString *szStartTimeKey = [dicDevice objectForKey:@"StartTimeKey"];
    NSString *szEndTimeKey = [dicDevice objectForKey:@"EndTimeKey"];
    NSString *szSampleCount = [dicDevice objectForKey:@"SampleCountKey"];
    NSString *szSlashTimeKey = [dicDevice objectForKey:@"SlashTimeKey"];
    
    //Send
    BOOL    bIsHex = [[dicSend objectForKey:kFZ_Script_CommandHexString] boolValue];
    id      SendCommand	= [dicSend objectForKey:kFZ_Script_CommandString];
    NSInteger   iPackedNum = 1;
    NSInteger   iIntervalTime = 0;
    if ([dicSend objectForKey:kFZ_Script_CommandByte]) {
        iPackedNum = [[dicSend objectForKey:kFZ_Script_CommandByte] intValue];
        iIntervalTime = 1000;
    }
    id          sentCommand = nil;
    if([SendCommand isKindOfClass:[NSString class]])
    {
        sentCommand = [SendCommand stringByReplacingOccurrencesOfString:@"\xc2\xa0" withString:@" "];
    }
    //data
    else if([SendCommand isKindOfClass:[NSData class]])
    {
        sentCommand = SendCommand;
    }
    
    //Receive
    double  dReadInterval = kUart_IntervalTime;
    if(nil != [dicReceive objectForKey:kFZ_Script_ReceiveInterval])
    {
        dReadInterval = [[dicReceive objectForKey:kFZ_Script_ReceiveInterval] doubleValue];
    }
	double  dReadTimeOut = kUart_CommandTimeOut;
    if(nil != [dicReceive objectForKey:kFZ_Script_ReceiveTimeOut])
    {
        dReadTimeOut    = [[dicReceive objectForKey:kFZ_Script_ReceiveTimeOut] doubleValue];
    }
    NSMutableArray * aryEndSymbols = [NSMutableArray arrayWithArray:[dicReceive objectForKey:kFZ_Script_ReceiveEndSymbols]];
    NSInteger iMatchType = [[dicReceive objectForKey:kFZ_Script_ReceiveMatchType] intValue];

    NSString *szReadOutForClear = @"";
	PEGA_ATS_UART   *uartObj    = [[m_dicPorts objectForKey:szDevice] objectAtIndex:kFZ_SerialInfo_UartObj];
    if (NULL == uartObj) return;
    
    id uartResponse = nil;
    id allUartResponse = nil;
    if([[dicReceive objectForKey:kFZ_Script_ReceiveReturnData] boolValue])
    {
        uartResponse = [[NSMutableData alloc] init];
        allUartResponse = [[NSMutableData alloc] init];
    }
    else
    {
        uartResponse = [[NSMutableString alloc] initWithString:@""];
        allUartResponse = [[NSMutableString alloc] initWithString:@""];
    }
    
    const char seperateKey[2] = {0x0a,0x0d};
    
    //[self SYNC_WITH_OTHER_DEVICE:dicSubItems RETURN_VALUE:nil];
    
    NSTimeInterval dSlashTime = 0.0;
    NSDate *dateStart = [NSDate date];
    NSString *szStartTime = [dateStart descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M:%S.%F" timeZone:nil locale:nil];
    NSInteger iIndex=0;
    for (iIndex=0; iIndex<iSampleCount; iIndex++)
    {
        //clear
        [uartObj Clear_UartBuff:kUart_ClearInterval TimeOut:kUart_CommandTimeOut readOut:&szReadOutForClear];
        //send
        [uartObj Write_UartCommand:sentCommand PackedNum:iPackedNum Interval:iIntervalTime IsHex:bIsHex];
        //read uart data
//        [uartObj Read_UartData:uartResponse TerminateSymbol:aryEndSymbols MatchType:iMatchType IntervalTime:dReadInterval TimeOut:dReadTimeOut Ignore:nil];
        
        [uartObj Read_UartData:uartResponse
			   TerminateSymbol:aryEndSymbols
					 MatchType:iMatchType
				  IntervalTime:dReadInterval
					   TimeOut:dReadTimeOut];
        
        if ([uartResponse isKindOfClass:[NSData class]])
        {
            [allUartResponse appendData:uartResponse];
            [allUartResponse appendData:[NSData dataWithBytes:seperateKey length:2]];
        }
        else
        {
            [allUartResponse appendString:uartResponse];
        }
    }
    
    NSDate *dateEnd = [NSDate date];
    dSlashTime = [dateEnd timeIntervalSinceDate:dateStart];    
    NSString *szEndTime = [dateEnd descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M:%S.%F" timeZone:nil locale:nil];
    NSString *szSlashTime = [NSString stringWithFormat:@"%lf",dSlashTime];
    
    if (uartResponse)
    {
        [uartResponse release];
    }
    
    if (bIsGlobal)
    {
        @synchronized(m_objPublicParams.publicMemoryValues)
        {
            [m_objPublicParams.publicMemoryValues setObject:allUartResponse forKey:szSaveKey];
            if (szStartTimeKey && ![szStartTimeKey isEqual:@""])
            {
                [m_objPublicParams.publicMemoryValues setObject:[NSString stringWithString:szStartTime] forKey:szStartTimeKey];
            }
            if (szEndTimeKey && ![szEndTimeKey isEqual:@""])
            {
                [m_objPublicParams.publicMemoryValues setObject:[NSString stringWithString: szEndTime] forKey:szEndTimeKey];
            }
            if (szSampleCount && ![szSampleCount isEqual:@""])
            {
                [m_objPublicParams.publicMemoryValues setObject:[NSString stringWithFormat:@"%d",iIndex] forKey:szSampleCount];
            }
            if (szSlashTimeKey && ![szSlashTimeKey isEqual:@""])
            {
                [m_objPublicParams.publicMemoryValues setObject:[NSString stringWithString:szSlashTime] forKey:szSlashTimeKey];
            }
        }
    }
    if (bIsMember)
    {
        [m_dicMemoryValues setObject:allUartResponse forKey:szSaveKey];
		if (szStartTimeKey && ![szStartTimeKey isEqual:@""])
			[m_dicMemoryValues setObject:[NSString stringWithString:szStartTime] forKey:szStartTimeKey];
		if (szEndTimeKey && ![szEndTimeKey isEqual:@""])
			[m_dicMemoryValues setObject:[NSString stringWithString:szEndTime] forKey:szEndTimeKey];
    }
    
    if (allUartResponse)
    {
        [allUartResponse release];
    }
    
    //[self SYNC_WITH_OTHER_DEVICE:dicSubItems RETURN_VALUE:nil];
    
    NSString *szThreadEndSymbol = [dicSubItems objectForKey:@"THREAD_END_SYMBOL"];
    if (szThreadEndSymbol && ![szThreadEndSymbol isEqual:@""])
    {
        @synchronized(m_objPublicParams.publicMemoryValues)
        {
            NSNumber *numer = [NSNumber numberWithInteger:[[m_objPublicParams.publicMemoryValues objectForKey:szThreadEndSymbol] integerValue]+1];
            [m_objPublicParams.publicMemoryValues setObject:numer forKey:szThreadEndSymbol];
        }
    }
}

- (NSNumber *) SAMPLE_THREAD:(NSDictionary *)dicSubItems RETURN_VALUE:(NSMutableString *)szReturnValue
{  
    NSArray *aryDevices = [dicSubItems allKeys];
    for(NSString *szDevice in aryDevices)
    {
        if ([[dicSubItems objectForKey:szDevice] isKindOfClass:[NSDictionary class]])
        {
            BOOL bNeedCancel = [[[dicSubItems objectForKey:szDevice] objectForKey:@"NeedCancel"] boolValue];
            if (!m_bFixtureControlOnhand && bNeedCancel)
            {
                continue;
            }
            else
            {
                if ([[m_dicPorts allKeys] containsObject:szDevice])
                {
                    NSArray *aryObjects = [NSArray arrayWithObjects:szDevice,dicSubItems, nil];
                    [NSThread detachNewThreadSelector:@selector(sampleSingleDevice:) toTarget:self withObject:aryObjects];
                }
            }
        }
    }
    return [NSNumber numberWithBool:YES];
}

- (NSNumber *) CALCULATE_TEMP_HUM:(NSDictionary *)dicSubItems RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSInteger iTempInteger = [[dicSubItems objectForKey:@"TEMP_INT"] integerValue];
    NSInteger iTempDecimal = [[dicSubItems objectForKey:@"TEMP_DEC"] integerValue];
    NSInteger iHumInteger = [[dicSubItems objectForKey:@"HUM_INT"] integerValue];
    NSInteger iHumDecimal = [[dicSubItems objectForKey:@"HUM_DEC"] integerValue];
    
    NSArray *aryBytes = [szReturnValue componentsSeparatedByString:@" "];
    
    if ([aryBytes count] < iHumDecimal+1)
    {
        return [NSNumber numberWithBool:NO];
    }
    
    NSString *szTempInteger = [aryBytes objectAtIndex:iTempInteger];
    NSString *szTempDecimal = [aryBytes objectAtIndex:iTempDecimal];
    NSString *szHumInteger = [aryBytes objectAtIndex:iHumInteger];
    NSString *szHumDecimal = [aryBytes objectAtIndex:iHumDecimal];
    
    unsigned int iBuf = 0;
    NSMutableString *szTemperature = [NSMutableString stringWithString:@""];
    NSMutableString *szHumidity = [NSMutableString stringWithString:@""];
    
    NSScanner *scanerBuf = [NSScanner scannerWithString:szTempInteger];
    [scanerBuf scanHexInt:&iBuf];    
    [szTemperature appendFormat:@"%d.",iBuf];
    
    scanerBuf = [NSScanner scannerWithString:szTempDecimal];
    [scanerBuf scanHexInt:&iBuf];
    [szTemperature appendFormat:@"%d",iBuf];
    
    scanerBuf = [NSScanner scannerWithString:szHumInteger];
    [scanerBuf scanHexInt:&iBuf];
    [szHumidity appendFormat:@"%d.",iBuf];
    
    scanerBuf = [NSScanner scannerWithString:szHumDecimal];
    [scanerBuf scanHexInt:&iBuf];
    [szHumidity appendFormat:@"%d",iBuf];
    
    [szReturnValue setString:[NSString stringWithFormat:@"%@C %@",szTemperature,szHumidity]];
    [szReturnValue appendString:@"%"];
    
    return [NSNumber numberWithBool:YES];
}

- (NSNumber *) MEMORY_COUNT:(NSDictionary *)dicSubItems RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSString *szSeperatedKey = [dicSubItems objectForKey:@"SEPERATE_KEY"];
    NSString *szCountSaveKey = [dicSubItems objectForKey:@"COUNT_SAVED_KEY"];
    NSArray *aryResponse = [szReturnValue componentsSeparatedByString:szSeperatedKey];
    NSString *szCount = [NSString stringWithFormat:@"%d",[aryResponse count]];
    [m_dicMemoryValues setObject:szCount forKey:szCountSaveKey];
    return [NSNumber numberWithBool:YES];
}

- (NSNumber *) CALCULATE_PRESSURE:(NSDictionary *)dicSubItems RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSArray *aryTokens = [dicSubItems objectForKey:@"CATCH_TOKEN"];
    NSString *szRowSeperator = [dicSubItems objectForKey:@"ROW_SEPERATOR"];
    NSArray *aryResponse = [szReturnValue componentsSeparatedByString:szRowSeperator];
    NSInteger iRowCount = [aryResponse count];
    
    NSMutableArray *aryValues = [NSMutableArray arrayWithCapacity:0];
    for (NSInteger iIndex=0; iIndex<iRowCount; iIndex++)
    {
        NSArray *aryTemp = nil;
        NSString *szRow = [aryResponse objectAtIndex:iIndex];
        NSInteger iToken = [aryTokens count];
        for (NSInteger iTokenIndex=0; iTokenIndex<iToken; iTokenIndex++)
        {
            if (iTokenIndex%2==0)
            {
                aryTemp = [szRow componentsSeparatedByString:[aryTokens objectAtIndex:iTokenIndex]];
            }
            else
            {
                NSInteger iColumn = [[aryTokens objectAtIndex:iTokenIndex] intValue];
                if ([aryTemp count] >= iColumn+1)
                {
                    szRow = [aryTemp objectAtIndex:iColumn];
                }
            }
        }
        if (![szRow isEqual:@""]) [aryValues addObject:szRow];
    }

    BOOL bExtractAve = [[dicSubItems objectForKey:@"EXTRACT_AVERAGE"] boolValue];
    BOOL bExtractStdev = [[dicSubItems objectForKey:@"EXTRACT_STDEV"] boolValue];

    double dSumamry = 0.0;
    double dAverage = 0.0;
    double dStdev = 0.0;
    iRowCount = [aryValues count];
    if (bExtractAve)
    {
        for (NSInteger iIndex=0; iIndex<iRowCount; iIndex++)
        {
            dSumamry += [[aryValues objectAtIndex:iIndex] doubleValue];
        }
        dAverage = dSumamry/iRowCount;
        
        NSString *szAverageKey = [dicSubItems objectForKey:@"AVERAGE_KEY"];
        if (szAverageKey && ![szAverageKey isEqual:@""])
        {
            [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%lf",dAverage] forKey:szAverageKey];
        }
    }
    if (bExtractStdev)
    {
        double dPow2Summary = 0.0;
        for (NSInteger iIndex=0; iIndex<iRowCount; iIndex++)
        {
            double dValue = [[aryValues objectAtIndex:iIndex] doubleValue];
            dPow2Summary += (dValue-dAverage)*(dValue-dAverage);
        }
        dStdev =  sqrt(dPow2Summary/iRowCount);
        
        NSString *szStdevKey = [dicSubItems objectForKey:@"STDEV_KEY"];
        if (szStdevKey && ![szStdevKey isEqual:@""])
        {
            //NSNumber *numSTD = [NSNumber numberWithDouble:dStdev];
            [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%lf",dStdev] forKey:szStdevKey];
            //[m_dicMemoryValues setObject:[NSString stringWithFormat:@"%@",numSTD] forKey:szStdevKey];
        }
    }
    return [NSNumber numberWithBool:YES];
}

- (NSNumber *) CALCULATE_PATCH_DATA:(NSDictionary *)dicSubItems RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSString *szSeperator = [dicSubItems objectForKey:@"SEPERATOR"];
    NSString *szFromKey = [dicSubItems objectForKey:@"FROM_KEY"];
    BOOL bIsGlobal = [[dicSubItems objectForKey:@"ISGLOBAL"] boolValue];
    NSString *szSampleCntKey = [dicSubItems objectForKey:@"ROW_COUNT"];
    NSInteger iTempInteger = [[dicSubItems objectForKey:@"TEMP_INT"] integerValue];
    NSInteger iTempDecimal = [[dicSubItems objectForKey:@"TEMP_DEC"] integerValue];
    NSInteger iHumInteger = [[dicSubItems objectForKey:@"HUM_INT"] integerValue];
    NSInteger iHumDecimal = [[dicSubItems objectForKey:@"HUM_DEC"] integerValue];
    
    NSInteger iSampleCount = 0;
    NSData *dataValue = nil;
    if (bIsGlobal)
    {
        dataValue = [m_objPublicParams.publicMemoryValues objectForKey:szFromKey];
        iSampleCount = [[m_objPublicParams.publicMemoryValues objectForKey:szSampleCntKey] integerValue];
    }
    else
        return [NSNumber numberWithBool:NO];
    
    [szReturnValue setString:@""];
    NSInteger iLen = [dataValue length];    
    char *pBuffer = malloc(iLen+1);
    [dataValue getBytes:pBuffer];
    for(int i=0; i<iLen; i++)
    {
        [szReturnValue appendFormat:@"%02X ",*(pBuffer+i)];
    }
    free(pBuffer);
    
    NSArray *aryRows = [szReturnValue componentsSeparatedByString:szSeperator];
    [szReturnValue setString:@""];
    for (NSInteger iIndex=0; iIndex<iSampleCount; iIndex++)
    {
        NSString *szRow = [aryRows objectAtIndex:iIndex];
        NSArray *aryBytes = [szRow componentsSeparatedByString:@" "];
        if ([aryBytes count] < iHumDecimal+1)
        {
            return [NSNumber numberWithBool:NO];
        }
        
        NSString *szTempInteger = [aryBytes objectAtIndex:iTempInteger];
        NSString *szTempDecimal = [aryBytes objectAtIndex:iTempDecimal];
        NSString *szHumInteger = [aryBytes objectAtIndex:iHumInteger];
        NSString *szHumDecimal = [aryBytes objectAtIndex:iHumDecimal];
        
        unsigned int iBuf = 0;
        NSMutableString *szTemperature = [NSMutableString stringWithString:@""];
        NSMutableString *szHumidity = [NSMutableString stringWithString:@""];
        
        NSScanner *scanerBuf = [NSScanner scannerWithString:szTempInteger];
        [scanerBuf scanHexInt:&iBuf];
        [szTemperature appendFormat:@"%d.",iBuf];
        
        scanerBuf = [NSScanner scannerWithString:szTempDecimal];
        [scanerBuf scanHexInt:&iBuf];
        [szTemperature appendFormat:@"%d",iBuf];
        
        scanerBuf = [NSScanner scannerWithString:szHumInteger];
        [scanerBuf scanHexInt:&iBuf];
        [szHumidity appendFormat:@"%d.",iBuf];
        
        scanerBuf = [NSScanner scannerWithString:szHumDecimal];
        [scanerBuf scanHexInt:&iBuf];
        [szHumidity appendFormat:@"%d",iBuf];
        
        if (iIndex < iSampleCount-1)
        {
            [szReturnValue appendFormat:@"%@,%@\n",szTemperature,szHumidity];
        }
        else
        {
            [szReturnValue appendFormat:@"%@,%@",szTemperature,szHumidity];
        }
    }
    return [NSNumber numberWithBool:YES];
}

- (NSNumber *) PUBLIC_ROLL:(NSDictionary *)dicSubItems RETURN_VALUE:(NSMutableString *)szReturnValue
{
    if (m_bFixtureControlOnhand)
    {
        @synchronized(m_objPublicParams)
        {
            [m_objPublicParams.publicMemoryValues removeAllObjects];
            m_objPublicParams.fixtureController = [NSNumber numberWithBool:NO];
        }
    }
    return [NSNumber numberWithBool:YES];
}

- (NSNumber *) WRITE_SAMPLE_LOG:(NSDictionary *)dicSubItems RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSMutableString *szStringToWrite = [NSMutableString stringWithString:@""];
    NSArray *aryToWrite = [dicSubItems objectForKey:@"WRITE_INFO"];
    for (NSDictionary *dicToWrite in aryToWrite)
    {
        NSString *szKey = [[dicToWrite allKeys] objectAtIndex:0];
        NSString *szUnit = [dicToWrite objectForKey:szKey];
        NSString *szInfo = [m_dicMemoryValues objectForKey:szKey];
        if (!szInfo)
        {
            szInfo = @"NULL";
        }
        [szStringToWrite appendFormat:@"%@ = %@%@\n",szKey,szInfo,szUnit];
    }
    [szStringToWrite appendString:@"\n"];
    /*
    NSString *szDevice = [dicSubItems objectForKey:@"DEVICE"];
    NSString *szStartTimeKey = [dicSubItems objectForKey:@"START_TIME_KEY"];
    NSString *szEndTimeKey = [dicSubItems objectForKey:@"END_TIME_KEY"];
    
    NSString *szStartTime = [m_dicMemoryValues objectForKey:szStartTimeKey];
    NSString *szEndTime = [m_dicMemoryValues objectForKey:szEndTimeKey];
    */
    /*
    NSString *szInfo = [NSString stringWithFormat:@"%@ ==> %@(%@)\r%@\r%@\r",szStartTime,szDevice,m_szISN, szReturnValue,szEndTime];
    
    @synchronized([m_objPublicParams g_szSampleLogPath])
    {
        NSString *szPath = [m_objPublicParams g_szSampleLogPath];
        NSFileHandle *hLog = [NSFileHandle fileHandleForWritingAtPath:szPath];
        if (!hLog)
        {
            [szInfo writeToFile:szPath atomically:NO encoding:NSUTF8StringEncoding error:nil];
        }
        else
        {
            NSData *dataTemp = [[NSData alloc] initWithBytes:(void *)[szInfo UTF8String] length:[szInfo length]];
            [hLog seekToEndOfFile];
            [hLog writeData:dataTemp];
            [dataTemp release];
        }
    }
    */
    /*
    [IALogs CreatAndWriteUARTLog:[NSString stringWithFormat:@"\n%@",szReturnValue] atTime:[NSString stringWithFormat:@"%@ - %@",szStartTime,szEndTime] fromDevice:[NSString stringWithFormat:@"RX ==> [%@]",szDevice] withPath:[NSString stringWithFormat:@"%@/%@_%@_Uart.txt",kPD_LogPath_Uart,m_szPortIndex,m_szStartTime] binary:NO];
     */
//    
//    [IALogs CreatAndWriteUARTLog:szStringToWrite atTime:nil fromDevice:nil withPath:[NSString stringWithFormat:@"%@/%@_%@_Uart.txt",kPD_LogPath_Uart,m_szPortIndex,m_szStartTime] binary:NO];

    [IALogs CreatAndWriteUARTLog:szStringToWrite
                          atTime:kIADeviceALSFileNameDate
                      fromDevice:nil
                        withPath:[NSString stringWithFormat:@"%@/%@_%@/%@_%@_Uart.txt",kPD_LogPath,m_szPortIndex,m_szStartTime,m_szPortIndex,m_szStartTime]
                          binary:NO];
    return [NSNumber numberWithBool:YES];
}

- (IBAction)btnOKClick:(id)sender
{
    [NSApp stopModal];
    NSWindow *window = [[sender superview] window];
    [window orderOut:nil];
//    [window release];
}

- (NSNumber *) MESSAGE_BOX:(NSDictionary *)dicSubItems RETURN_VALUE:(NSMutableString *)szReturnValue
{
    CGFloat fBottomHeight = 15.0;
    CGFloat fTopHeight = 30.0;
    CGFloat fLeftWidth =10.0, fRightWidth = 10.0;
    CGFloat fButtonHeight = 30.0;
    CGFloat fButtonWidth = 60.0;
    
    NSString *szTitle = [dicSubItems objectForKey:@"TITLE"];
    CGFloat fTitleHeight = [[dicSubItems objectForKey:@"TITLE_HEIGHT"] floatValue];
    CGFloat fTitleWidth = [[dicSubItems objectForKey:@"TITLE_WIDTH"] floatValue];
    
    NSPanel *panel = [[NSPanel alloc] init];
    
    NSArray *aryMessageList = [dicSubItems objectForKey:@"MESSAGE_LIST"];
    NSInteger iCount = [aryMessageList count];
    
    CGFloat fPanelHeight = fBottomHeight+fButtonHeight+fTitleHeight+fTopHeight;
    CGFloat fPanelWidth = fTitleWidth;
    
    for (NSDictionary *dicMessage in aryMessageList)
    {
        iCount--;
        NSString *szMessage = [dicMessage objectForKey:@"MESSAGE"];
        BOOL bBold = [[dicMessage objectForKey:@"BOLD"] boolValue];
        BOOL bRedColor = [[dicMessage objectForKey:@"REDCOLOR"] boolValue];
        CGFloat fWidth = [[dicMessage objectForKey:@"TF_WIDTH"] floatValue];
        CGFloat fHeight = [[dicMessage objectForKey:@"TF_HEIGHT"] floatValue];
        
        fPanelHeight += fHeight;
        if (fWidth > fPanelWidth)
        {
            fPanelWidth = fWidth;
        }
        
        NSTextField *txtMessage = [[NSTextField alloc] initWithFrame:NSMakeRect(fLeftWidth, fBottomHeight+fButtonHeight+fHeight*iCount, fWidth, fHeight)];
        [txtMessage setEditable:NO];
        [txtMessage setBordered:NO];
        [txtMessage setBackgroundColor:[NSColor windowBackgroundColor]];
    
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:szMessage];
        [attrString addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Helvetica" size:12] range:NSMakeRange(0, [szMessage length])];
        if (bBold)
        {
            [attrString addAttribute:NSFontAttributeName value:[NSFont boldSystemFontOfSize:12] range:NSMakeRange(0, [szMessage length])];
        }
        if (bRedColor)
        {
            [attrString addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:NSMakeRange(0, [szMessage length])];
        }
        [txtMessage setAttributedStringValue:attrString];
        [attrString release];

        [[panel contentView] addSubview:txtMessage];
        [txtMessage release];
    }
    fPanelWidth = fPanelWidth+fLeftWidth+fRightWidth;
    
    NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:szTitle];
    [attrTitle addAttribute:NSFontAttributeName value:[NSFont fontWithName:@"Charcoal CY" size:18] range:NSMakeRange(0, [szTitle length])];
    NSTextField *txtTitle = [[NSTextField alloc] initWithFrame:NSMakeRect(fLeftWidth, fPanelHeight-fTopHeight-fTitleHeight+5, fTitleWidth, fTitleHeight)];
    [txtTitle setEditable:NO];
    [txtTitle setBordered:NO];
    [txtTitle setBackgroundColor:[NSColor windowBackgroundColor]];
    [txtTitle setAttributedStringValue:attrTitle];
    [attrTitle release];
    [[panel contentView] addSubview:txtTitle];
    [txtTitle release];
    
    NSButton *btnOK = [[NSButton alloc] initWithFrame:NSMakeRect((fPanelWidth-fButtonWidth)/2, fBottomHeight, fButtonWidth, fButtonHeight)];
    [btnOK setTitle:@"OK"];
    [btnOK setTarget:self];
    [btnOK setKeyEquivalent:@"\r"];
    [btnOK setBezelStyle:NSRoundedBezelStyle];
    [btnOK setAction:@selector(btnOKClick:)];
    [[panel contentView] addSubview:btnOK];
    
    [btnOK release];
    
    NSScreen *screen = [NSScreen mainScreen];
    CGFloat fScreenWidth = [screen frame].size.width;
    CGFloat fScreenHeight = [screen frame].size.height;
    [panel setFrame:NSMakeRect((fScreenWidth-fPanelWidth)/2, (fScreenHeight-fPanelHeight)/2, fPanelWidth, fPanelHeight) display:YES];

    [NSApp runModalForWindow:panel];

    return [NSNumber numberWithBool:YES];
}

- (NSNumber *) CANCEL_CASE_BY_TARGET:(NSDictionary *)dicSubItems RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSArray *aryTargets = [dicSubItems allKeys];
    for(NSString *szTarget in aryTargets)
    {
        if (![[m_dicPorts allKeys] containsObject:szTarget])
        {
            NSArray *aryCancelCases = [dicSubItems objectForKey:szTarget];
            [m_muArrayCancelCase addObjectsFromArray:aryCancelCases];
        }
    }
    return [NSNumber numberWithBool:YES];
}

- (NSNumber *) GET_ID_BY_TARGET:(NSDictionary *)dicSubItems RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSString *szDevice = [dicSubItems objectForKey:@"TARGET"];
    NSString *szPort = [[m_dicPorts objectForKey:szDevice] objectAtIndex:kFZ_SerialInfo_SerialPort];
    [szReturnValue setString:szPort];
    return [NSNumber numberWithBool:YES];
}

// 2013-10-30 add by xiaoyong for pressure function
// Set dictionary
// Param:
//      NSMutableDictionary  *dictSettings   : NA
//      NSMutableString *szReturnValue      : Return value
// Return:
//      YES
//
- (NSNumber *)GET_ROW_FROM_RAWDATA:(NSDictionary *)dicSetting RETURN_VALUE:(NSMutableString *)szReturnValue
{    
    NSArray     *arrCounts  = [[m_dicMemoryValues objectForKey:@"GetRows"] componentsSeparatedByString:@"\n"];
    NSString    *szLine     = [arrCounts objectAtIndex:0];
    NSString    *szLastLine = [arrCounts objectAtIndex:[arrCounts count]-1];
    NSString    *szCount    = [NSString stringWithFormat:@"%d",[arrCounts count]];
    
    [m_dicMemoryValues setObject:szLine forKey:@"LineValue"];
    [m_dicMemoryValues setObject:szLastLine forKey:@"LastLineValue"];
    [m_dicMemoryValues setObject:szCount forKey:@"SamplesCollected"];
    return [NSNumber numberWithBool:YES];
}
@end
