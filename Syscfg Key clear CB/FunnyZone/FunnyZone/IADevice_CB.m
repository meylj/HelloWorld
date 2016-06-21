//  IADevice_CB.m
//  Izual_Lu
//
//  Created by Lu Izual on 11-5-5.
//  Copyright 2011年 PEGATRON. All rights reserved.



#import "IADevice_CB.h"


@implementation TestProgress (IADevice_CB)

//description : get write pass control bit password
//param:
//  NSDictionary *dicSubTestItem : sub item for some setting params
//  char         *secureInput    : address for save password
//  NSMutableString    *szReturnValue  : return value
//Return result:
//  bool type : not use
- (bool)calculateSecuerControlBitPassword:(NSDictionary *)dicSubTestItem
							  SecureInput:(char*)secureInput
							  ReturnValue:(NSMutableString*)szReturnValue
{ 
    char	*cPasswordOutput	= malloc(32);
    memset(cPasswordOutput, 0, 32);
    char	*pBufferForNonce	= malloc(20);
    
    /*/------------------------------------------------------------------
     Send command "getnonce"
     recevie nonce number by byte
     ------------------------------------------------------------------*/
    NSDictionary	*dicSendGetnonce	= [dicSubTestItem objectForKey:@"SEND_GETNONCE"];
    [self SEND_COMMAND:dicSendGetnonce];
    
    NSDictionary	*dicReceiveGetnonce	= [dicSubTestItem objectForKey:@"RECEIVE_GETNONCE"];
    [self READ_COMMAND:dicReceiveGetnonce
		  RETURN_VALUE:szReturnValue];
    
    //
    NSData	*data			= [m_dicMemoryValues objectForKey:kFZ_Script_ReceiveReturnData];
    char	*pBuffer_Nonce	= malloc(100);
    [data getBytes:pBuffer_Nonce
			length:[data length]];
    for(int i=0; i< [data length]; i++)//length?Leehua
        if((*(pBuffer_Nonce+i)==0x0a)
		   && (*(pBuffer_Nonce+i+1)==0x0d))
        {
            memcpy(pBufferForNonce,(pBuffer_Nonce+i+2),20);
            break;
        }
    free(pBuffer_Nonce);
    
    memcpy((secureInput+20),pBufferForNonce,20);
    ATSDebug(@"calculateSecureControlBitPassword : %s",secureInput);
    
    /*/------------------------------------------------------------------
     Caculate password form UUID and nonce
     ------------------------------------------------------------------*/
    CC_SHA1_CTX		context;
    unsigned char	digest[CC_SHA1_DIGEST_LENGTH];
    
    ///* Digest the concatenated string. 
    CC_SHA1_Init(&context);
    CC_SHA1_Update(&context, secureInput,40);
    CC_SHA1_Final(digest, &context);
    //strncpy(m_cPasswordOutput,(const char*)digest,20);
    memcpy(cPasswordOutput,(const char*)digest,20);
    
    /*/------------------------------------------------------------------
     Send password to UART and write control bit
     ------------------------------------------------------------------*/
    [self SEND_COMMAND:dicSubTestItem];
    
    NSDictionary		*dicReceiveForPass	= [dicSubTestItem objectForKey:
											   @"RECEIVE_FOR_PASS"];
    [self READ_COMMAND:dicReceiveForPass
		  RETURN_VALUE:szReturnValue];
    NSMutableDictionary	*dicSendPassword	= [dicSubTestItem objectForKey:
											   @"SEND_PASSWORD"];
    
    //modified the kFZ_Script_CommandData as kFZ_Script_CommandString on 2012 05 12
    [dicSendPassword setObject:[NSData dataWithBytes:cPasswordOutput
											  length:20]
						forKey:kFZ_Script_CommandString];
    [self SEND_COMMAND:dicSendPassword];

    NSDictionary	*dicReceivePassword	= [dicSubTestItem objectForKey:
										   @"RECEIVE_PASSWORD"];
    [self READ_COMMAND:dicReceivePassword
		  RETURN_VALUE:szReturnValue];
    
    /*/------------------------------------------------------------------
     free buffer
     ------------------------------------------------------------------*/
    free(cPasswordOutput);
    free(pBufferForNonce);
    
    NSString	*szSource		= [NSString stringWithString:szReturnValue];
    NSArray		*aryExsist		= [NSArray arrayWithObjects:
								   @"Pass",
								   @"Fail",
								   @"Incomplete",
								   @"Untested", nil];
    NSArray		*aryNotExist	= [NSArray arrayWithObject:@"ERROR"];
	if(![self ExsistObjects:aryExsist
				   AtString:szSource
				 IgnoreCase:YES]
	   || [self ExsistObjects:aryNotExist
					 AtString:szSource
				   IgnoreCase:YES])
		return NO;
	else
		return YES;
}


// set pass or fail control bit
// Param:
//		NSDictionary	*dicSubTestItem	
//			KEY		-> NSString*	: KEY name
//      NSMutableString*   szReturnValue   : return value
// Relate:
//		NSMutableDictionary	*dicMemoryValues	: Save memory values with given key
- (NSNumber*)WRITE_CONTROL_BIT:(NSDictionary *)dicSubTestItem
				  RETURN_VALUE:(NSMutableString*)szReturnValue
{
    //for PVT stage
    NSNumber	*numSetFlag	= [m_dicMemoryValues objectForKey:kFZ_SetCBFlag];
    if (![numSetFlag boolValue])
	{
        [szReturnValue setString:@"UnNeed to set CB!"];
        return [NSNumber numberWithBool:YES];
    }
    
    NSNumber	*retValue	= [NSNumber numberWithBool:NO];;
    NSString	*szCommand	= [dicSubTestItem valueForKey:kFZ_Script_CommandString];
    if(!m_bFinalResult)
    {
        //test fail
        [m_dicMemoryValues setObject:kFZ_TestFail
							  forKey:kFZ_TestResult];
        [self SEND_COMMAND:dicSubTestItem];
        NSDictionary	*dicReceiveForFail	= [dicSubTestItem objectForKey:@"RECEIVE_FOR_FAIL"];
        retValue	= [self READ_COMMAND:dicReceiveForFail
						 RETURN_VALUE:szReturnValue];
    }
    else
    {
        //test pass
        [m_dicMemoryValues setObject:kFZ_TestPass
							  forKey:kFZ_TestResult];
		
		// TODO: Change secure keys here!! --> Lorky on 2014-09-03
		NSDictionary * dictPassword = [NSDictionary dictionaryWithObjectsAndKeys:
									   @"AFC7FBb41A7C698aDCC33E1dA5761Ad935E0DC49", @"0x0b",  // SMT-QT
									   @"28DBBF82FF3EF2c6FA545795880159c1A7F2CA34", @"0x7a",  // UNIT-SHUTDOWN
									   @"050497df8115B0a9D6FD975b99EB852993C7AA23", @"0x7b",  // CG-INSTALL
									   @"EF36D1af24A4B450CEB2AA6465D09E671D457D3b", @"0x80",  // QT0
									   @"5E43721aC7E7896d1386A313981627704B64CF67", @"0x81",  // QT1
									   @"A56A1F62D9791A2b1241250b010EDCb729ABCE02", @"0x82",  // QT2
									   @"BFD0076e5C152B3f857C5Ba5570E3Aea546F1B2d", @"0xd2",  // STOM
                                       @"2277A3359E65ED5958BB6F6298071402D4259De7", @"0x77",  // CT1
                                       @"5923EFf491B178576958D5ee3CBE51faC2A8B76f", @"0x93",  // MBT
                                       nil];
		NSString * strStationID = [szCommand subByRegex:@"cbwrite (0x.{2})" name:nil error:nil];
		NSString *szUUID = [dictPassword objectForKey:[strStationID lowercaseString]];
		if ([szUUID length] != 40)
		{
			[szReturnValue setString:@"Can't find the secure keys"];
			return [NSNumber numberWithBool:NO];
		}
        //copy fixed password to first 20 bytes of password area
        char	*cSecureUUID	= malloc(40);
		memset(cSecureUUID ,0x00,40);
		for(int i=0,j=0;i<20;i++)
		{
			unsigned int	nHex	= 0;
			NSRange			range;
			range.location	= j;
			range.length	= 2;            
			NSString		*temp	= @"";
            if ([szUUID length] >= range.location + range.length)
                temp	= [szUUID substringWithRange:range];
			[[NSScanner scannerWithString:temp ] scanHexInt:&nHex];
			*(cSecureUUID+i)	= nHex;
			j					+= 2;
		}
		ATSDebug(@"WRITE_CONTROL_BIT => szSecureUUID = %s",
				 cSecureUUID);
        
        BOOL	bRetFromCal	= YES;
        //calculate late 20 bytes of password
        for(int iCount = 0; iCount < 3; iCount++)
		{
            //call function to calculate
			bRetFromCal	= [self calculateSecuerControlBitPassword:dicSubTestItem
													  SecureInput:cSecureUUID
													  ReturnValue:szReturnValue];
			ATSDebug(@"WRITE_CONTROL_BIT => calculateSecuerControlBit return value:[%@],iCount=[%d]",
					 szReturnValue, iCount);
			if(bRetFromCal)
			{
                //if pass , jump out , not to repeat
				retValue	= [NSNumber numberWithBool:YES];
                break;
			}
		}
        //7.24
        //mark by desikan  fix the bug: upload to PDCA fail but our log show PASS
        //move uploadPDCA out of the loop
        if(!m_bOfflineDisablePudding && !m_bValidationDisablePudding && ![retValue boolValue])
            [m_objPudding SetTestItemStatus:@"CB Check"
                                    SubItem:@"Write"
								 SubSubItem:@""
                                  TestValue:szReturnValue
                                   LowLimit:@"" 
                                  HighLimit:@""
                                  TestUnits:@"" 
                                    ErrDesc:@"CB Write Fail"
                                   Priority:0
                                 TestResult:NO];
        free(cSecureUUID);  
    }
    return retValue;
}

/* 2012-04-17 Add remark by Stephen
 Function:       Check control bits of some stations.
 Description:    Get the result of cb value from unit by sending cbread "StationID", upload the result to PDCA.
 Para:           (NSDictionary *)dicSubTestItem --> A dictionary contains the array commands to send, maybe cbread "StationID1", cbread "StationID2" and so on.
 (NSMutableString*)szReturnValue --> Value to show on UI and write in csv
 Return:         If all the cb value from unit are PASS return YES, else return NO. */
- (NSNumber*)CHECK_CONTROL_BITS:(NSDictionary *)dicSubTestItem
				   RETURN_VALUE:(NSMutableString*)szReturnValue
{  
    NSNumber		*numRet;
    NSMutableArray	*aryStationIDs		= [[NSMutableArray alloc] init];
    NSMutableArray	*aryStationNames	= [[NSMutableArray alloc] init];
    NSString		*szErrorMSG			= @"CBAuth Error: To Be Design Error";
        
    [szReturnValue setString:@"PASS"];
    BOOL			bNumRet			= YES;
    NSMutableString	*szFailStation	= [[NSMutableString alloc] init];
	//The local station no cb, no need write incomplete
//    BOOL		bNoWriteIncomplete	= [[dicSubTestItem objectForKey:
//										@"NO_WRITE_INCOMPLETE"]
//									   boolValue];
	// No need check GH fail count
    BOOL		bNoCheckFailCount	= [[dicSubTestItem objectForKey:
										@"NO_CHECK_FAIL_COUNT"]
									   boolValue];
    BOOL		bNewAPI				= NO;
    if ([dicSubTestItem objectForKey:@"NEW_CBAuth_API"]) //New API flag
        bNewAPI	= [[dicSubTestItem objectForKey:@"NEW_CBAuth_API"] boolValue];

    // Step 1
    // Use the new API with the unit SN
    int	iRet	= -528; // default error code
    if (bNewAPI)
    {
		if (!m_szISN || [m_szISN isEqualToString:@""])
		{
			[szReturnValue setString:@"Serial Number is empty"];
			[aryStationIDs release];
            [aryStationNames release];
            [szFailStation release];
            return [NSNumber numberWithBool:NO];
		}
		
		iRet	= [m_CBTestBase ControlBitsToCheckSN:m_szISN
									stationIDsHex:aryStationIDs
									  stationName:aryStationNames];
        if (iRet < 0)
        {
            szErrorMSG	= [m_CBTestBase cbGetErrMsg:iRet];
            [szReturnValue setString:szErrorMSG];
            [aryStationIDs release];
            [aryStationNames release];
            [szFailStation release];
            return [NSNumber numberWithBool:NO];
        }
    }
    else
    {
		// old API, don't have error code function
        BOOL	bRet	= [m_CBTestBase ControlBitsToCheck:aryStationIDs
										 stationName:aryStationNames];
        if (bRet)// if return yes, return the count of stations need to check similar to the new API
            iRet	= [aryStationIDs count];
        else// if return no, return 0, indicate the Network CB don't need to check.
            iRet	= 0;
    }

    NSInteger	iSize	= [aryStationNames count];   
    // check_control_bit return no need 
    if (iRet > 0) 
    {
        // need check_control_bit
        NSDictionary	*dicReadCB			= [dicSubTestItem objectForKey:
											   @"SEND_COMMAND:"];
        NSDictionary	*dicReceiveFromCB	= [dicSubTestItem objectForKey:
											   @"READ_COMMAND:RETURN_VALUE:"];
        for(NSInteger i=0; i<iSize; i++)
        {
            NSString	*szStationName	= [aryStationNames objectAtIndex:i];
            [m_dicMemoryValues setObject:[aryStationIDs objectAtIndex:i]
								  forKey:kFZ_StationId];
            [self SEND_COMMAND:dicReadCB];
            numRet	= [self READ_COMMAND:dicReceiveFromCB
						   RETURN_VALUE:szReturnValue];
            bNumRet	&= [numRet boolValue];
            if(![numRet boolValue])
            {
                if ([szReturnValue isEqualToString:@""])
                    [szReturnValue setString:@"CB read formart error"];
                if(!m_bOfflineDisablePudding && !m_bValidationDisablePudding)
                    [m_objPudding SetTestItemStatus:@"CB Check Read" 
                                            SubItem:szStationName
										 SubSubItem:@""
                                          TestValue:[NSString stringWithString:szReturnValue] 
                                           LowLimit:@"" 
                                          HighLimit:@"" 
                                          TestUnits:@"" 
                                            ErrDesc:@"CB Read Fail"
                                           Priority:0 
                                         TestResult:NO];
                [szReturnValue setString:[NSString stringWithFormat:
										  @"Rx Data format [%@] error  at station [%@]",
										  szReturnValue, szStationName]];
            }
            else
            {
                NSArray		*aryValues	= [szReturnValue componentsSeparatedByString:@" "];
                NSInteger	iValueCount	= [aryValues count];
                if(iValueCount < 6)
                {
                    if ([szReturnValue isEqualToString:@""])
                        [szReturnValue setString:@"NoRx"];
                    if(!m_bOfflineDisablePudding && !m_bValidationDisablePudding)
                    {
                        [m_objPudding SetTestItemStatus:@"CB Check Routing"
                                                SubItem:szStationName
											 SubSubItem:@""
                                              TestValue:[NSString stringWithString:szReturnValue]
                                               LowLimit:@"Passed" 
                                              HighLimit:@"Passed"
                                              TestUnits:@"" 
                                                ErrDesc:[NSString stringWithFormat:
														 @"No pass for %@, go to %@",
														 szStationName, szStationName]
                                               Priority:0
                                             TestResult:NO];
                    }
                    [szReturnValue setString:[NSString stringWithFormat:
											  @"Rx Data format [%@] error  at station [%@]",
											  szReturnValue, szStationName]];
                }
                else
                {
                    NSString	*szResult	= [aryValues objectAtIndex:1];
                    if([[szResult uppercaseString] isEqualToString:@"PASSED"])
                    {
						//add for remember network CB
                        [m_dicNetWorkCBStation setObject:@"PASS"
												  forKey:szStationName];
                        continue;
                    }
                    else
                    {
						//add for remember network CB
                        [m_dicNetWorkCBStation setObject:@"FAIL"
												  forKey:szStationName];
                        if(!m_bOfflineDisablePudding && !m_bValidationDisablePudding)
                            [m_objPudding SetTestItemStatus:@"CB Check Routing"
                                                    SubItem:szStationName
												 SubSubItem:@""
                                                  TestValue:szResult
                                                   LowLimit:@"Passed" 
                                                  HighLimit:@"Passed"
                                                  TestUnits:@"" 
                                                    ErrDesc:[NSString stringWithFormat:
															 @"No pass for %@, go to %@",
															 szStationName, szStationName]
                                                   Priority:0
                                                 TestResult:NO];
                        [szFailStation appendFormat:@"%@ ", szStationName];
                    }
                }
            }
            bNumRet	= NO;
        }
    }
    // judge check_control_bit result
    if (!bNumRet)
    {
        [szReturnValue setString:[NSString stringWithFormat:
								  @"No pass for %@", szFailStation]];
        [szFailStation release];
        [aryStationIDs release];
        [aryStationNames release];
        return [NSNumber numberWithBool:NO];
    }
    
    // Step 2
    // check self fail count
    int			iAllowedFailCount	= [m_CBTestBase getStationFailCountAllowed];
    NSDictionary	*dicForAllowed	= [NSDictionary dictionaryWithObjectsAndKeys:
									   [NSNumber numberWithInt:iAllowedFailCount],
									   @"ALLOWED_FAIL_COUNT",
									   [dicSubTestItem objectForKey:@"SEND_COMMAND:"],
									   @"SEND_COMMAND:",
									   [dicSubTestItem objectForKey:@"READ_COMMAND:RETURN_VALUE:"],
									   @"READ_COMMAND:RETURN_VALUE:",
                                       [dicSubTestItem  objectForKey:@"LOCAL_STATIONID"],
                                       @"LOCAL_STATIONID",
                                       nil];
    if (!bNoCheckFailCount && iAllowedFailCount>0) 
        //add for check allowed GH fail count
        if (![[self WHETHER_STATION_ALLOWED_TEST:dicForAllowed
									RETURN_VALUE:szReturnValue] boolValue])
        {
            [szFailStation release];
            [aryStationIDs release];
            [aryStationNames release];
            return [NSNumber numberWithBool:NO];
        }
    
    // Step 3
    // write in complete cb value
//    if (!bNoWriteIncomplete) 
//    {
//        if (![[self WRITE_INCOMPLETE_CONTROLBIT:dicSubTestItem
//								   RETURN_VALUE:szReturnValue] boolValue])
//        {
//            [szReturnValue setString:@"NetWork CB On and Write CB Incomplete fail"];
//            [aryStationIDs release];
//            [aryStationNames release];
//            [szFailStation release];
//            return [NSNumber numberWithBool:NO];
//        }
//    }
    if (iRet == 0)
		[szReturnValue setString:@"Network CB Check Return No Need!"];
    [szFailStation release];
    [aryStationIDs release];
    [aryStationNames release];
    return [NSNumber numberWithBool:bNumRet];
}

/* 2012-04-17 Add remark by Stephen
 Function:       Clear some stations' cb based on the test result.
 Description:    Get the stations' IDs based on the final result, than clear them.
 Para:           (NSDictionary *)dicSubTestItem --> A dictionary contains the arguments of "SEND_COMMAND:" and "READ_COMMAND:RETURN_VALUE:" function.
                 (NSMutableString*)szReturnValue --> Value returned from the last function, contains the unit's return value, show on UI and save in csv.
 Return:         If the stations' cb has cleard ok, return YES, else return NO. */
- (NSNumber*)CLEAR_RELATIVE_CONTROL_BITS:(NSDictionary *)dicSubTestItem
							RETURN_VALUE:(NSMutableString *)szReturnValue
{
    bool			bReply			= YES;
    NSMutableString	*szMuErrorCode	= [[NSMutableString alloc] init];
    NSMutableArray	*aryToClear		= [[NSMutableArray alloc] init];
    if(m_bFinalResult)
        bReply	= [m_CBTestBase ControlBitsToClearOnPass:aryToClear];
    else
        bReply	= [m_CBTestBase ControlBitsToClearOnFail:aryToClear];
    NSNumber	*numRet;
    if (bReply) 
    {
        NSDictionary	*dicSend	= [dicSubTestItem objectForKey:
									   @"SEND_COMMAND:"];
        NSDictionary	*dicReceive	= [dicSubTestItem objectForKey:
									   @"READ_COMMAND:RETURN_VALUE:"];

        for(NSInteger i=0; i<[aryToClear count]; i++)
        {
            [m_dicMemoryValues setObject:[aryToClear objectAtIndex:i]
								  forKey:kFZ_StationId];
            [self SEND_COMMAND:dicSend];
            numRet	= [self READ_COMMAND:dicReceive
						   RETURN_VALUE:szReturnValue];
            if(![numRet boolValue])
                if([szReturnValue isEqualToString:@""])
                    [szReturnValue setString:@"CB clear formart error"];
            bReply	&= [numRet boolValue];
            [szMuErrorCode appendFormat:@"%@  ",szReturnValue];
            ATSDebug(@"CLEAR_RELATIVE_CONTROL_BITS => Clear station %@",
					 [aryToClear objectAtIndex:i]);
        }
        numRet	= [NSNumber numberWithBool:bReply];
    }
    else
    {
        [szReturnValue setString:@"No list for CBCF"];
        ATSDebug(@"CLEAR_RELATIVE_CONTROL_BITS => No stations need to clear !");
        numRet	= [NSNumber numberWithBool:YES];
    }
    [szReturnValue setString:szMuErrorCode];
    [aryToClear release];
    [szMuErrorCode release];
    return numRet;
}

/****************************************************************************************************
 Start 2012.4.16 Add note by Yaya 
 Descripton: check the setting file scriptFileName is contain the GH station type. 
 Param:
 NSMutableString *strErr : Return value , if the script file name contain the GH station type , the return value
                           is the GH station type. or the return value is like  "GroundhogInfo [GH station name] vs SettingFile [script file name]"
 ****************************************************************************************************/
- (BOOL)GetAndCompareLocalStationName:(NSMutableString *)strErr
{
	BOOL		bResult;	
	NSString	*strStationNameGH	= [m_dicMemoryValues objectForKey:descriptionOfGHStationInfo(IP_STATION_TYPE)];
	NSString	*strStationNameIni	= [self getValueFromXML:kPD_UserDefaults
												mainKey:kPD_UserDefaults_ScriptFileName, nil];
	NSRange		range	= [[strStationNameIni uppercaseString]
						   rangeOfString:[strStationNameGH uppercaseString]];
	if (NSNotFound != range.location
		&& range.length >0
		&& (range.location+range.length) <= [strStationNameIni length])
	{
        [strErr setString:strStationNameGH];
		bResult	= YES;
	}
	else
	{
        [strErr setString:[NSString stringWithFormat:
						   @"GroundhogInfo [%@] vs SettingFile [%@]",
						   strStationNameGH, strStationNameIni]];
		bResult	= NO;
	}
	return bResult;
}
/****************************************************************************************************
 Start 2012.4.16 Add note by Yaya 
 Descripton: check one station is it over the fail count! 
 Param:
 NSDictionary  *dicSubTestItem : setting in script,the contents about which station you want to check.
 NSMutableString  *szReturnValue : Return value
 ****************************************************************************************************/

- (NSNumber*)WHETHER_STATION_ALLOWED_TEST:(NSDictionary *)dicSubTestItem
							 RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSNumber		*numRet	= [NSNumber numberWithBool:NO];
    //update Mapping Table...
    if([self GetAndCompareLocalStationName:szReturnValue])
    {
        NSString    *szStationID    = [dicSubTestItem   objectForKey:@"LOCAL_STATIONID"];
        if (nil == szStationID)
		{
            [szReturnValue setString:[NSString stringWithFormat:
									  @"NO StationID:%@", szReturnValue]];
            return numRet;
        }
        
        NSDictionary	*dicReadCB			= [dicSubTestItem objectForKey:
											   @"SEND_COMMAND:"];
        NSDictionary	*dicReceiveFromCB	= [dicSubTestItem objectForKey:
											   @"READ_COMMAND:RETURN_VALUE:"];
        [m_dicMemoryValues setObject:szStationID
							  forKey:kFZ_StationId];
        [self SEND_COMMAND:dicReadCB];
        numRet	= [self READ_COMMAND:dicReceiveFromCB
					   RETURN_VALUE:szReturnValue];
        if(![numRet boolValue])
        {
            if ([szReturnValue isEqualToString:@""])
                [szReturnValue setString:@"CB read formart error"];
            if(!m_bOfflineDisablePudding && !m_bValidationDisablePudding)
                [m_objPudding SetTestItemStatus:@"CB Check"
										SubItem:@"Read"
									 SubSubItem:@""
									  TestValue:[NSString stringWithString:szReturnValue]
									   LowLimit:@"Passed"
									  HighLimit:@"Passed"
									  TestUnits:@""
										ErrDesc:[NSString stringWithFormat:
												 @"CB Read Fail [%@]",szReturnValue]
									   Priority:0
									 TestResult:NO];
            [szReturnValue setString:[NSString stringWithFormat:
									  @"Rx Data format [%@] error  at station ID [%@]",
									  szReturnValue, szStationID]];
        }
        else
        {
            NSArray		*aryValues	= [szReturnValue componentsSeparatedByString:@" "];
            NSInteger	iValueCount	= [aryValues count];
            if(iValueCount < 4)
            {
                numRet	= [NSNumber numberWithBool:NO];
                ATSDebug(@"WHETHER_STATION_ALLOWED_TEST : nil == arrValues || [arrValues count] < 4");
                [szReturnValue setString:[NSString stringWithFormat:
										  @"Read [%@] Control Bit format error",
										  szReturnValue]];
            }
            else
            {
                int	iFailCount			= [[aryValues objectAtIndex:2] intValue];
                int	iAllowedFailCount	= [[dicSubTestItem objectForKey:@"ALLOWED_FAIL_COUNT"]
										   intValue];
                if(iAllowedFailCount > 0
				   && iFailCount >= iAllowedFailCount)
                {
                    numRet	= [NSNumber numberWithBool:NO];
                    [szReturnValue setString:[NSString stringWithFormat:
											  @"Already fail %d times;STATION_FAIL_COUNT_ALLOWED is %d",
											  iFailCount, iAllowedFailCount]];
                    if(!m_bOfflineDisablePudding && !m_bValidationDisablePudding)
                        [m_objPudding SetTestItemStatus:@"CB Check"
                                                SubItem:@"Retest"
											 SubSubItem:@""
                                              TestValue:[NSString stringWithFormat:
														 @"%d", iFailCount]
                                               LowLimit:@"0"
                                              HighLimit:[NSString stringWithFormat:
														 @"%d", iAllowedFailCount]
                                              TestUnits:@"" 
                                                ErrDesc:@"Over fail count, go to repair"
                                               Priority:0
                                             TestResult:NO];
                }
            }
        }
    }
    else
        ATSDebug(@"WHETHER_STATION_ALLOWED_TEST call function GetAndCompareLocalStationName : %@",
				 szReturnValue);
    return numRet;
}
/****************************************************************************************************
 Start 2012.4.16 Add note by Yaya 
 Descripton: write incomplete control bit. 
 Param:
 NSDictionary  *dicSubTestItem : setting in script.it is mainly about two commmands"rtc" and "cb write"
 NSMutableString  *szReturnValue : Return value
 ****************************************************************************************************/
- (NSNumber*)WRITE_INCOMPLETE_CONTROLBIT:(NSDictionary *)dicSubTestItem
							RETURN_VALUE:(NSMutableString *)szReturnValue
{
    if(![m_dicMemoryValues objectForKey:descriptionOfGHStationInfo(IP_STATION_IP)])
    {
        ATSDebug(@"WRITE_INCOMPLETE_CONTROLBIT => Can't find StationId from m_dicMemoryValues! Check whether WHETHER_STATION_ALLOWED_TEST: has been done.");
        return [NSNumber numberWithBool:NO];
    }
    
    NSDictionary	*dicSend_setIncomplete		= [dicSubTestItem objectForKey:
												   @"2.SEND_COMMAND:"];
    NSDictionary	*dicReceive_setIncomplete	= [dicSubTestItem objectForKey:
												   @"2.READ_COMMAND:RETURN_VALUE:"];
    [m_dicMemoryValues setObject:uiVersion
						  forKey:kFZ_SoftVersion];
    [self SEND_COMMAND:dicSend_setIncomplete];
    NSNumber	*numRet	= [self READ_COMMAND:dicReceive_setIncomplete
							 RETURN_VALUE:szReturnValue];
    if (![numRet boolValue])
	{
        if([szReturnValue isEqualToString:@""])
            [szReturnValue setString:@"CB write formart error"];
        if(!m_bOfflineDisablePudding && !m_bValidationDisablePudding)
            [m_objPudding SetTestItemStatus:@"CB Check"
                                    SubItem:@"Write"
								 SubSubItem:@""
                                  TestValue:[NSString stringWithString:szReturnValue]
                                   LowLimit:@"Passed" 
                                  HighLimit:@"Passed"
                                  TestUnits:@"" 
                                    ErrDesc:[NSString stringWithFormat:@"CB Write Fail [%@]",szReturnValue]
                                   Priority:0
                                 TestResult:NO];
        [szReturnValue setString:[NSString stringWithFormat:
								  @"Write CB error [%@]", szReturnValue]];
    }
    return  numRet;
}
/****************************************************************************************************
 Start 2012.4.16 Add note by Yaya
 Descripton: Base on the Json to decide if setting control bit or not.
 Param:
 NSDictionary  *dicSubTestItem : nothing
 NSMutableString  *szReturnValue : Return value
 ****************************************************************************************************/
- (NSNumber*)CB_SETORNOT:(NSDictionary *)dicSubTestItem
			RETURN_VALUE:(NSMutableString *)szReturnValue
{
    BOOL	bSetFlag	= [m_CBTestBase StationSetControlBit];
    
    if (bSetFlag)
	{
        [m_dicMemoryValues setObject:[NSNumber numberWithBool:YES]
							  forKey:kFZ_SetCBFlag];
        [szReturnValue setString:@"ON"];
    }
    else
    {
        [m_dicMemoryValues setObject:[NSNumber numberWithBool:NO]
							  forKey:kFZ_SetCBFlag];
        [szReturnValue setString:@"OFF"];
    }
    return [NSNumber numberWithBool:YES];     
}

/****************************************************************************************************
 Start 2012.4.16 Add note by Yaya
 Descripton: Self CB check and upload the result to PDCA.
 Param:
 NSDictionary  *dicSubTestItem : setting in script.include whether there have spec? what the spec?
 NSMutableString  *szReturnValue : Return value
 ****************************************************************************************************/
- (NSNumber*)SELF_CB_CHECK:(NSDictionary *)dicSubTestItem
			  RETURN_VALUE:(NSMutableString *)szReturnValue
{   
    NSArray	*arrValues	= [szReturnValue componentsSeparatedByString:@" "];
	if (nil == arrValues || [arrValues count] < 6)
	{	
		ATSDebug(@"SELF_CB_CHECK => nil == arrValues || [arrValues count] < 5");
        if(!m_bOfflineDisablePudding && !m_bValidationDisablePudding)
            [m_objPudding SetTestItemStatus:@"CB Check"
								SubItem:@"Read"
							 SubSubItem:@""
							  TestValue:[NSString stringWithString:szReturnValue]
							   LowLimit:@"" 
							  HighLimit:@""
							  TestUnits:@"" 
								ErrDesc:@"CB Read Fail" 
							   Priority:0
							 TestResult:NO];
		return [NSNumber numberWithBool:NO];
	}
    [szReturnValue setString:[arrValues objectAtIndex:1]];
    
    NSNumber	*numRet	= [NSNumber numberWithBool:YES];
    BOOL		bNoSpec	= [[dicSubTestItem objectForKey:@"NoSpec"] boolValue];    
    if (!bNoSpec) 
    {
        NSString		*szSpec		= [dicSubTestItem objectForKey:@"SPEC"];
        NSDictionary	*dicSpec	= [NSDictionary dictionaryWithObject:szSpec
															forKey:kFZ_Script_JudgeCommonBlack];
        
        dicSpec	= [NSDictionary dictionaryWithObject:dicSpec
											  forKey:kFZ_Script_JudgeCommonSpec];
        numRet	= [self JUDGE_SPEC:dicSpec
					 RETURN_VALUE:szReturnValue];
    }    
    NSString	*szTestItemName	= [m_dicMemoryValues objectForKey:
								   kFunnyZoneCurrentItemName];
    NSArray		*arrayKeys		= [NSArray arrayWithObjects:
								   @"Station id",	@"CB result",
								   @"RFC",			@"AFC",
								   @"EC",			@"Time",
								   @"SW_V", nil];
    NSString	*strErrDes		= ([numRet boolValue]
								   ? @""
								   : [NSString stringWithFormat:
									  @"[%@] FAIL",szTestItemName]);
    if(!m_bOfflineDisablePudding && !m_bValidationDisablePudding)
    {
        for (NSUInteger i = 2; i < 5; i++)
        {
            [m_objPudding SetTestItemStatus:[NSString stringWithFormat:
											 @"%@_%@",
											 szTestItemName, [arrayKeys objectAtIndex:i]]
                                    SubItem:@""
								 SubSubItem:@""
                                  TestValue:[arrValues objectAtIndex:i] 
                                   LowLimit:@"" 
                                  HighLimit:@""
                                  TestUnits:@"" 
                                    ErrDesc:strErrDes 
                                   Priority:0
                                 TestResult:[numRet boolValue]];
        }
    }
    //show write cb time as one case and upload to parametric data 11.12.15
    [m_dicMemoryValues setObject:[arrValues objectAtIndex:5]
						  forKey:kFZ_Script_CBWtnTime];
    
    NSDictionary	*dictMappingTable = [NSDictionary dictionaryWithObjectsAndKeys:
										 @"0",	@"Passed",
										 @"1",	@"Untested",
										 @"2",	@"Failed",
										 @"3",	@"Incomplete", nil];
	NSString		*strValueToPDCA		= [dictMappingTable objectForKey:szReturnValue];
	if (strValueToPDCA == nil
		|| [strValueToPDCA isEqualToString:@""])
	{
        [szReturnValue setString:@"Upload CB To PDCA fail!"];
		numRet = [NSNumber numberWithBool:NO];
	}
    else if(!m_bOfflineDisablePudding && !m_bValidationDisablePudding)
		[m_objPudding SetTestItemStatus:[NSString stringWithFormat:
										 @"%@_CB", szTestItemName]
								SubItem:@""
							 SubSubItem:@""
							  TestValue:strValueToPDCA
							   LowLimit:@"" 
							  HighLimit:@""
							  TestUnits:@"" 
								ErrDesc:strErrDes 
							   Priority:0
							 TestResult:[numRet boolValue]];
	return numRet;
}

// set pass or fail control bit under NonUI mode
- (NSNumber*)WRITE_OS_CONTROL_BIT:(NSDictionary *)dicSubTestItem
                     RETURN_VALUE:(NSMutableString*)szReturnValue
{
    //for PVT stage
    //    NSNumber	*numSetFlag	= [m_dicMemoryValues objectForKey:kFZ_SetCBFlag];
    //    if (![numSetFlag boolValue])
    //    {
    //        [szReturnValue setString:@"UnNeed to set CB!"];
    //        return [NSNumber numberWithBool:YES];
    //    }
    
    NSNumber	*retValue	= [NSNumber numberWithBool:NO];;
    NSString	*szCommand	= [dicSubTestItem valueForKey:kFZ_Script_CommandString];
    if(!m_bFinalResult)
    {
        //test fail
        [m_dicMemoryValues setObject:kFZ_TestFail
                              forKey:kFZ_TestResult];
        [self SEND_COMMAND:dicSubTestItem];
        NSDictionary	*dicReceiveForFail	= [dicSubTestItem objectForKey:@"RECEIVE_FOR_FAIL"];
        retValue	= [self READ_COMMAND:dicReceiveForFail
                         RETURN_VALUE:szReturnValue];
    }
    else
    {
        //test pass
        [m_dicMemoryValues setObject:kFZ_TestPass
                              forKey:kFZ_TestResult];
        
        // TODO: Change secure keys here!! --> Lorky on 2014-09-03
        NSDictionary * dictPassword = [NSDictionary dictionaryWithObjectsAndKeys:
                                       @"0F121D1173606FD64562AD5A44FCAA9A0C8DD27B", @"206",  // Gyro-sanity
                                       nil];
        NSString * strStationID = [szCommand subByRegex:@"controlbits -o (\\d*?) -v" name:nil error:nil];
        NSString *szUUID = [dictPassword objectForKey:[strStationID lowercaseString]];
        if ([szUUID length] != 40)
        {
            [szReturnValue setString:@"Can't find the secure keys"];
            return [NSNumber numberWithBool:NO];
        }
        [m_dicMemoryValues setObject:kFZ_TestPass
                              forKey:kFZ_TestResult];
        
        //copy fixed password to first 20 bytes of password area
        char	*cSecureUUID	= malloc(40);
        memset(cSecureUUID ,0x00,40);
        for(int i=0,j=0;i<20;i++)
        {
            unsigned int	nHex	= 0;
            NSRange			range;
            range.location	= j;
            range.length	= 2;
            NSString		*temp	= @"";
            if ([szUUID length] >= range.location + range.length)
                temp	= [szUUID substringWithRange:range];
            [[NSScanner scannerWithString:temp ] scanHexInt:&nHex];
            *(cSecureUUID+i)	= nHex;
            j					+= 2;
        }
        ATSDebug(@"WRITE_CONTROL_BIT => szSecureUUID = %s",cSecureUUID);
        
        NSLog(@"cSecureUUID == ");
        for (int i=0;i<strlen(cSecureUUID);i++)
        {
            printf("%02x",cSecureUUID[i]&0xff);
        }
        
        BOOL	bRetFromCal	= YES;
        //calculate late 20 bytes of password
        for(int iCount = 0; iCount < 3; iCount++)
        {
            //call function to calculate
            bRetFromCal	= [self calculateOSSecuerControlBitPassword:dicSubTestItem
                                                        SecureInput:cSecureUUID
                                                        ReturnValue:szReturnValue];
            ATSDebug(@"WRITE_CONTROL_BIT => calculateSecuerControlBit return value:[%@],iCount=[%d]",
                     szReturnValue, iCount);
            if(bRetFromCal)
            {
                //if pass , jump out , not to repeat
                retValue	= [NSNumber numberWithBool:YES];
                break;
            }
        }
        free(cSecureUUID);
    }
    return retValue;
}
//description : get write pass control bit password for NoUI test
- (bool)calculateOSSecuerControlBitPassword:(NSDictionary *)dicSubTestItem
                                SecureInput:(char*)secureInput
                                ReturnValue:(NSMutableString*)szReturnValue
{
    char	*cPasswordOutput	= malloc(32);
    memset(cPasswordOutput, 0, 32);
    char	*pBufferForNonce	= malloc(20);
    
    [self SEND_COMMAND:dicSubTestItem];
    
    NSDictionary	*dicReceiveGetnonce	= [dicSubTestItem objectForKey:@"RECEIVE_GETNONCE"];
    [self READ_COMMAND:dicReceiveGetnonce
          RETURN_VALUE:szReturnValue];
    
    NSString * strNONCE = [szReturnValue subByRegex:@"Nonce:\\s*(.*?)\\s*?Enter password:" name:nil error:nil];
    
    if ([strNONCE length] != 40)
    {
        [szReturnValue setString:@"Can't find the secure keys"];
        return [NSNumber numberWithBool:NO];
    }
    //copy fixed password to first 20 bytes of password area
    char	*pBuffer_Nonce	= malloc(40);
    memset(pBuffer_Nonce ,0x00,40);
    for(int i=0,j=0;i<20;i++)
    {
        unsigned int	nHex	= 0;
        NSRange			range;
        range.location	= j;
        range.length	= 2;
        NSString		*temp	= @"";
        if ([strNONCE length] >= range.location + range.length)
            temp	= [strNONCE substringWithRange:range];
        [[NSScanner scannerWithString:temp ] scanHexInt:&nHex];
        *(pBuffer_Nonce+i)	= nHex;
        j					+= 2;
    }
    
    //Output bytes
    NSLog(@"UnitNonce == ");
    for (int i=0;i<strlen(pBuffer_Nonce);i++)
    {
        printf("%02x",pBuffer_Nonce[i]&0xff);
    }
    
    //combine password and nonce
    memcpy((secureInput+20),pBuffer_Nonce,20);
    ATSDebug(@"calculateSecureControlBitPassword : %s",secureInput);
    
    //Output bytes all bytes
    NSLog(@"Combine U+N == ");
    for (int i=0;i<strlen(secureInput);i++)
    {
        printf("%02X",secureInput[i]&0xff);
    }
    
    /*/------------------------------------------------------------------
     Caculate password form UUID and nonce
     ------------------------------------------------------------------*/
    CC_SHA1_CTX		context;
    unsigned char	digest[CC_SHA1_DIGEST_LENGTH];
    
    ///* Digest the concatenated string.
    CC_SHA1_Init(&context);
    CC_SHA1_Update(&context, secureInput,40);
    CC_SHA1_Final(digest, &context);
    //strncpy(m_cPasswordOutput,(const char*)digest,20);
    memcpy(cPasswordOutput,(const char*)digest,20);
    
    /*/------------------------------------------------------------------
     Send password to UART and write control bit
     ------------------------------------------------------------------*/
    
    NSLog(@"SHA1 == ");
    for (int i=0;i<strlen(cPasswordOutput);i++)
    {
        printf("%02X",cPasswordOutput[i]&0xff);
    }
    
    NSMutableString *strCPassword   = [[NSMutableString alloc]init];
    for (int i=0;i<strlen(cPasswordOutput);i++)
    {
        [strCPassword appendFormat:@"%02X",cPasswordOutput[i]&0xff];
    }
    
    NSMutableString *strFinalPassword = [[NSMutableString alloc]init];
    
    if ([strCPassword length] == 40)
    {
        for (NSUInteger i = 0; i < 40; i += 8 )
        {
            NSString * strOne = [strCPassword substringWithRange:NSMakeRange(i, 8)];
            NSString * strPart1 = [strOne subByRegex:@".{0}(.{2})" name:nil error:nil];
            NSString * strPart2 = [strOne subByRegex:@".{2}(.{2})" name:nil error:nil];
            NSString * strPart3 = [strOne subByRegex:@".{4}(.{2})" name:nil error:nil];
            NSString * strPart4 = [strOne subByRegex:@".{6}(.{2})" name:nil error:nil];
            [strFinalPassword appendString:[NSString stringWithFormat:@"%@%@%@%@",strPart4,strPart3,strPart2,strPart1]];
        }
    }
    
    /*/------------------------------------------------------------------
     Send password to UART and write control bit
     ------------------------------------------------------------------*/
    
    NSMutableDictionary	*dicSendPassword	= [dicSubTestItem objectForKey:@"SEND_PASSWORD"];
    [dicSendPassword setObject: strFinalPassword forKey:kFZ_Script_CommandString];
    NSDictionary	*dicReceivePassword	= [dicSubTestItem objectForKey:@"RECEIVE_PASSWORD"];
    
    [self SEND_COMMAND:dicSendPassword];
    
    [self READ_COMMAND:dicReceivePassword
          RETURN_VALUE:szReturnValue];
    
    [strCPassword release];
    [strFinalPassword release];
    
    /*/------------------------------------------------------------------
     free buffer
     ------------------------------------------------------------------*/
    free(cPasswordOutput);
    free(pBufferForNonce);
    
    NSString	*szSource		= [NSString stringWithString:szReturnValue];
    NSArray		*aryExsist		= [NSArray arrayWithObjects:@"successfully", nil];
    NSArray		*aryNotExist	= [NSArray arrayWithObject:@"ERROR"];
    if(![self ExsistObjects:aryExsist
                   AtString:szSource
                 IgnoreCase:YES]
       || [self ExsistObjects:aryNotExist
                     AtString:szSource
                   IgnoreCase:YES])
        return NO;
    else
        return YES;
}

//description : get write pass control bit password for NoUI test
- (NSString*)calculateOSSecuerControlBitPasswordTCP:(NSString *)Nonce

{
    //For password
//  NSString *dictPassword = @"D8A9B6FB624A740F6B5C319AA4BB9846A66062C4";  // N71 Gyro-sanity password
    NSString *dictPassword = @"5817F0B7C0552B0E713A3692F55657E2A4C5173F"; //D10 Gyro-sanity password
    //copy fixed password to first 20 bytes of password area
    char	*cSecureUUID	= malloc(40);
    memset(cSecureUUID ,0x00,40);
    for(int i=0,j=0;i<20;i++)
    {
        unsigned int	nHex	= 0;
        NSRange			range;
        range.location	= j;
        range.length	= 2;
        NSString		*temp	= @"";
        if ([dictPassword length] >= range.location + range.length)
            temp	= [dictPassword substringWithRange:range];
        [[NSScanner scannerWithString:temp ] scanHexInt:&nHex];
        *(cSecureUUID+i)	= nHex;
        j					+= 2;
    }
    ATSDebug(@"WRITE_CONTROL_BIT => szSecureUUID = %s",cSecureUUID);
    
    NSLog(@"cSecureUUID == ");
    for (int i=0;i<strlen(cSecureUUID);i++)
    {
        printf("%02x",cSecureUUID[i]&0xff);
    }
    
    
    //For password
    char	*cPasswordOutput	= malloc(32);
    memset(cPasswordOutput, 0, 32);
    char	*pBufferForNonce	= malloc(20);
    
    //copy fixed password to first 20 bytes of password area
    char	*pBuffer_Nonce	= malloc(40);
    memset(pBuffer_Nonce ,0x00,40);
    for(int i=0,j=0;i<20;i++)
    {
        unsigned int	nHex	= 0;
        NSRange			range;
        range.location	= j;
        range.length	= 2;
        NSString		*temp	= @"";
        if ([Nonce length] >= range.location + range.length)
            temp	= [Nonce substringWithRange:range];
        [[NSScanner scannerWithString:temp ] scanHexInt:&nHex];
        *(pBuffer_Nonce+i)	= nHex;
        j					+= 2;
    }
    
    //Output bytes
    NSLog(@"UnitNonce == ");
    for (int i=0;i<strlen(pBuffer_Nonce);i++)
    {
        printf("%02x",pBuffer_Nonce[i]&0xff);
    }
    
    //combine password and nonce
    memcpy((cSecureUUID+20),pBuffer_Nonce,20);
    ATSDebug(@"calculateSecureControlBitPassword : %s",cSecureUUID);
    
    //Output bytes all bytes
    NSLog(@"Combine U+N == ");
    for (int i=0;i<strlen(cSecureUUID);i++)
    {
        printf("%02X",cSecureUUID[i]&0xff);
    }
    
    /*/------------------------------------------------------------------
     Caculate password form UUID and nonce
     ------------------------------------------------------------------*/
    CC_SHA1_CTX		context;
    unsigned char	digest[CC_SHA1_DIGEST_LENGTH];
    
    ///* Digest the concatenated string.
    CC_SHA1_Init(&context);
    CC_SHA1_Update(&context, cSecureUUID,40);
    CC_SHA1_Final(digest, &context);
    //strncpy(m_cPasswordOutput,(const char*)digest,20);
    memcpy(cPasswordOutput,(const char*)digest,20);
    
    /*/------------------------------------------------------------------
     Send password to UART and write control bit
     ------------------------------------------------------------------*/
    
    NSLog(@"SHA1 == ");
    for (int i=0;i<strlen(cPasswordOutput);i++)
    {
        printf("%02X",cPasswordOutput[i]&0xff);
    }
    
    NSMutableString *strCPassword   = [[NSMutableString alloc]init];
    for (int i=0;i<strlen(cPasswordOutput);i++)
    {
        [strCPassword appendFormat:@"%02X",cPasswordOutput[i]&0xff];
    }
    
    NSMutableString *strFinalPassword = [[NSMutableString alloc]init];
    
    if ([strCPassword length] == 40)
    {
        for (NSUInteger i = 0; i < 40; i += 8 )
        {
            NSString * strOne = [strCPassword substringWithRange:NSMakeRange(i, 8)];
            NSString * strPart1 = [strOne subByRegex:@".{0}(.{2})" name:nil error:nil];
            NSString * strPart2 = [strOne subByRegex:@".{2}(.{2})" name:nil error:nil];
            NSString * strPart3 = [strOne subByRegex:@".{4}(.{2})" name:nil error:nil];
            NSString * strPart4 = [strOne subByRegex:@".{6}(.{2})" name:nil error:nil];
            [strFinalPassword appendString:[NSString stringWithFormat:@"%@%@%@%@",strPart4,strPart3,strPart2,strPart1]];
        }
    }
    
    
    [strCPassword release];
    NSString	*szSource		= [NSString stringWithString:strFinalPassword];
    
    [strFinalPassword release];
    
    /*/------------------------------------------------------------------
     free buffer
     ------------------------------------------------------------------*/
    free(cPasswordOutput);
    free(pBufferForNonce);
    return szSource;
    
    
}

@end




