//  IADevice_SFIS.m
//  FunnyZone
//
//  Created by Eagle on 10/27/11.
//  Copyright 2011 PEGATRON. All rights reserved.



#import "IADevice_SFIS.h"
#import "PuddingPDCA/IPSFCPost.h"
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>


@implementation TestProgress (IADevice_SFIS)

// Query SFIS with given contents, and save return values to dicMemoryValues
// Param:
//      NSDictionary    *dicQueryContents   : Contains query contents
//          band_sn         -> NSString*    : 
//          nandcs          -> NSString*    : 
//          nand_id         -> NSString*    : 
//          .....
// Return:
//      Actions result
-(NSNumber*)QUERY_SFIS:(NSDictionary*)dicQueryContents
		  RETURN_VALUE:(NSMutableString *)szReturnValue
{
	// If the dictionary of "QueryItems" is nil or null
    if (nil == dicQueryContents
		|| 0 == [[dicQueryContents allKeys] count])
	{
        ATSDebug(@"QUERY_SFIS: => input dictionary error! please check script.");
        return [NSNumber numberWithBool:NO];
    }
	
	// Default use serial number to query SFIS.
	// If there are no "QuerySNKey" key, use 80ISN to query, if not, use the value of "QuerySNKey" to query.
    NSString	*strQueryNum	= m_szISN;
    NSString	*strQuerySN		= [dicQueryContents objectForKey:
								   KIADeviceSFISQuerySNKey];
    if (strQuerySN != nil
		&& ![strQuerySN isEqualToString:@""])
	{
        strQueryNum	= [m_dicMemoryValues objectForKey:strQuerySN];
        strQueryNum	= (nil == strQueryNum) ? m_szISN : strQueryNum;
    }
    CFStringRef	strEncode	= CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                      (CFStringRef)strQueryNum,
                                                                      NULL,
                                                                      CFSTR(":/?#[]@!$&'()*+,;= "),
                                                                      kCFStringEncodingUTF8);
    NSString	*strEncodeNum	= (NSString*)strEncode;
	NSDictionary	*dictQueryItems	= [dicQueryContents objectForKey:
									   KIADeviceSFISQueryItems];
    
	IPSFCPost	*postObj	= [[IPSFCPost alloc] init];
    [postObj setDelegate:self];
    NSInteger	acpResult;
	NSMutableDictionary	*acp_muDictionary	= [[NSMutableDictionary alloc]
											   initWithDictionary:dictQueryItems];
    for (int iQueryTime = 0 ; iQueryTime < 1; iQueryTime++)
	{
        // query sfc record.
        acpResult	= [postObj TrySFCQueryRecord:strEncodeNum
									DataStruct:acp_muDictionary
										  Size:[[acp_muDictionary allKeys] count]];
        NSMutableString *szPtype    = [[NSMutableString alloc] init];
        for (NSString *szPKey in [dictQueryItems allKeys])
        {
            [szPtype appendFormat:@"&p=%@", szPKey];
        }
        ATSDebug(@"Query URL : %@?c=query_record&sn=%@%@",
                 [m_dicMemoryValues objectForKey:descriptionOfGHStationInfo(IP_SFC_URL)], strEncodeNum, szPtype);
        [szPtype release];
        if (TEST_SUCCESS == acpResult)
			break;
		// sleep(5);
    }
    NSString	*strKeys	= [acp_muDictionary description];
    ATSDebug(@"QUERY_SFIS TrySFCQueryRecord : result[%ld] all value with keys [%@]",
			 (long)acpResult, strKeys);
	
//	// Store the info of not queried keys
//	NSMutableArray *aryNotQueryKey = [[NSMutableArray alloc] init];
	
    for (NSString *strKey in [acp_muDictionary allKeys])
	{
        NSString	*strValue	= [acp_muDictionary valueForKey:strKey];
		
		// Check value of QueryItems format
//		// Check hwconfig format
//		if ([[strKey lowercaseString]isEqualToString:@"hwconfig"])
//		{
//			if (strValue != nil && ![strValue isEqualToString:@""])
//			{
//				NSArray *aryHwconfigInfo = [strValue componentsSeparatedByString:@","];				
//				for (NSString *strHWKeysInfo in aryHwconfigInfo)
//				{
//					if ([strHWKeysInfo ContainString:@"="])
//					{
//						NSString *strHWKeyvalue = [strHWKeysInfo SubFrom:@"=" include:NO];
//						if ([strHWKeyvalue isEqualToString:@""])
//						{
//							[aryNotQueryKey addObject:[NSString stringWithFormat:@"%@ in hwconfig",
//													   [strHWKeysInfo SubTo:@"=" include:NO]]];
//							
//							acpResult = -1;
//							ATSDebug(@"%@ in hwconfig is null", [strHWKeysInfo SubTo:@"=" include:NO]);
//						}
//					}
//				}
//			}
//			else if ([strValue isEqualToString:@""])
//			{
//				[aryNotQueryKey addObject:strKey];
//				acpResult = -1;
//				ATSDebug(@"%@ is null", strKey);
//			}
//		}
//		// check other values' format
//		// In MP stage, the values of "config", "sbuild" and "sbuild_unit" are null.
//		else if (![[strKey lowercaseString] isEqualToString:@"config"]
//			&& ![[strKey lowercaseString] isEqualToString:@"sbuild"]
//			&& ![[strKey lowercaseString] isEqualToString:@"sbuild_unit"])
//		{
//			if ([strValue isEqualToString:@""] || nil == strValue)
//			{
//				[aryNotQueryKey addObject:strKey];
//				acpResult = -1;
//				ATSDebug(@"%@ is null", strKey);
//			}
//		}
//		
		
        if (nil == strValue || [strValue isEqualToString:@""])
            strValue	= @"null";
		else
		{
            //default when querysn is sn,set the key  added by lucy
            if (nil == strQuerySN || [strQuerySN isEqualToString:@""])
                [m_dicMemoryValues setObject:strValue
									  forKey:strKey];
            // when the querysn is mlb_sn,ban_sn added by lucy
            else
                [m_dicMemoryValues setObject:strValue
									  forKey:[NSString stringWithFormat:
											  @"%@_%@", strKey, strQuerySN]];
        }
		[szReturnValue appendFormat:@"%@=%@;", strKey, strValue];
        ATSDebug(@"QUERY_SFIS: => print query value[%@] with key[%@]",
				 strValue, strKey);
    }
    
    /* 2015.4.21 Add for disable query funciton, because there is no SFC of dry run in USA...
     * Just for dry run in USA...
     *
     * ++++++++++ Start ++++++++++
     */
    BOOL    bDisableQueryFunction   = [[[[kFZ_UserDefaults objectForKey:@"ModeSetting"] objectForKey:@"NoSFISFunction"] objectForKey:@"DisableFunction"] boolValue];
    NSString    *szDisableDicName   = [[[kFZ_UserDefaults objectForKey:@"ModeSetting"] objectForKey:@"NoSFISFunction"] objectForKey:@"DictionaryName"];
    if (bDisableQueryFunction &&
        szDisableDicName &&
        ![szDisableDicName isEqualTo:@""])
    {
        for (NSString *strKey in [acp_muDictionary allKeys])
        {
            NSString	*strValue	= [acp_muDictionary valueForKey:strKey];
            
            if (nil == strValue || [strValue isEqualToString:@""])
            {
                [m_dicMemoryValues setObject:[dictQueryItems objectForKey:strKey]
                                      forKey:(nil == strQuerySN) ? strKey : [NSString stringWithFormat:@"%@_%@", strKey, strQuerySN]];
                ATSDebug(@"QUERY_SFIS(Fake): => print query value[%@] with key[%@]",
                         [dictQueryItems objectForKey:strKey], strKey);
            }
            
            [m_dicDisableQueryItems setObject:szDisableDicName
                                       forKey:(nil == strQuerySN) ? strKey : [NSString stringWithFormat:@"%@_%@", strKey, strQuerySN]];
        }
        
        [acp_muDictionary release];
        [postObj release];
        return [NSNumber numberWithBool:YES];
    }
    /*
     * ++++++++++ End ++++++++++
     */

    
//	// If there are some keys are null in SFIS DB, show related info in UI.
//	if (!([aryNotQueryKey count] == 0))
//	{
//		[szReturnValue setString:@""];
//		if ([aryNotQueryKey count] == 1)
//		{
//			[szReturnValue appendFormat:@"%@ is not maintained in the SFIS DB.",
//			 [aryNotQueryKey objectAtIndex:0]];
//		}
//		else
//		{
//			NSMutableString *strUIInfo = [[NSMutableString alloc] initWithString:@""];
//			for (int i = 0; i < [aryNotQueryKey count]-1; i++)
//			{
//				[strUIInfo appendFormat:@"%@; ",
//					[aryNotQueryKey objectAtIndex:i]];
//			}
//			[strUIInfo appendFormat:@"%@",
//				[aryNotQueryKey objectAtIndex:[aryNotQueryKey count]-1]];
//			[szReturnValue appendFormat:@"%@ are not maintained in the SFIS DB.", strUIInfo];
//			[strUIInfo release]; strUIInfo = nil;
//		}
//	}
//	[aryNotQueryKey release]; aryNotQueryKey = nil;
	
    [acp_muDictionary release];
	[postObj release];
	return [NSNumber numberWithBool:(acpResult == 0)];
}
// Catch data with given keys from m_dicMemoryValues
// Param:
//      NSDictionary    *dicQueryContents   : Contains Catch contents
//          area         -> NSString*    : 
//          asku         -> NSString*    : 
//          .....
// Return:
//      Actions result
-(NSNumber*)CATCH_DATA:(NSDictionary*)dicQueryContents
		  RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSNumber	*numRet		= [NSNumber numberWithBool:YES];
    NSArray		*aryFrom	= [dicQueryContents allKeys];
    NSInteger	iCount		= [aryFrom count];
    for (NSInteger i=0; i<iCount; i++) 
    {
        NSString	*szFromKey	= [aryFrom objectAtIndex:i];
        NSString	*szFromStr	= [m_dicMemoryValues objectForKey:szFromKey];
        if (szFromStr == nil
			|| [szFromStr isEqualToString:@""])
        {
            ATSDebug(@"CATCH_SFCDATA: didn't get %@ from SFC!",szFromKey);
            numRet	= [NSNumber numberWithBool:NO];
        }
        else
        {
            NSDictionary	*dicCatch	= [dicQueryContents objectForKey:szFromKey];
            NSArray			*aryCatch	= [dicCatch allKeys];
            for(NSString *szKey in aryCatch) 
            {
                NSString		*szValue		= szFromStr;
                NSDictionary	*dicCondition	= [dicCatch objectForKey:szKey];
                NSString		*szFrom			= [dicCondition objectForKey:@"FROM"];
                NSString		*szTo			= [dicCondition objectForKey:@"TO"];
                szValue	= [self catchFromString:szValue
										  begin:szFrom
											end:szTo
								 TheRightString:[[dicQueryContents objectForKey:@"RIGHTSTRING"]
												 boolValue]];
                
                if ([szValue isKindOfClass:[NSString class]]
					&& ![szValue isEqualToString:@""])
                    [m_dicMemoryValues setObject:szValue
										  forKey:szKey];
                else
                    numRet	= [NSNumber numberWithBool:NO];
            }
        }
    }
    return numRet;
}

// Insert SFIS with given contents, and save return values to dicMemoryValues
// Param:
//      NSDictionary    *dicInsertContents  : Contains insert contents
//          URL         -> NSString*    : Insert URL.
//          SN          -> NSString*    : Insert SN or BandSN.
//          STATIONID   -> NSString*    : Insert station id
//          STATIONNAME -> NSString*    : Insert station name
//          STARTTIME   -> NSString*    : Insert start time
//          STOPTIME    -> NSString*    : Insert stop time. (Can be nil). Default = Current time
//          PRODUCT     -> NSString*    : Insert product.
//          OS          -> NSString*    : Insert OS bundle version
//          MACADDRESS  -> NSString*    : Insert MAC address
//          ECID        -> NSString*    : Insert ECID. (Can be nil)
//          UDID        -> NSString*    : Insert UDID. (Can be nil)
//          FAILLIST    -> NSString*    : Insert list of failing tests. (Can be nil)
//          FAILURE     -> NSString*    : Insert failure messages. (Can be nil)
//          TIMEOUT     -> NSNumber*    : Insert time out. (Can be nil). Default = 3s
//      NSMutableString        *strReturn         : Return values
// Return:
//      Actions result
-(NSNumber*)INSERT_SFIS:(NSDictionary*)dicInsertContents
           RETURN_VALUE:(NSMutableString*)strReturn
{
    NSInteger	iTimeOut        = 5;
	
    NSString	*szURL          = [dicInsertContents objectForKey:@"URL"] ?
    [dicInsertContents objectForKey:@"URL"]:
    [m_dicMemoryValues objectForKey:descriptionOfGHStationInfo(IP_SFC_URL)];
    
    NSString	*szSFCTimeOut   = [m_dicMemoryValues objectForKey:descriptionOfGHStationInfo(IP_SFC_TIMEOUT)];
    
    NSString	*szStartTime    = [[NSDate date] descriptionWithCalendarFormat:@"YYYY-MM-dd HH:mm:ss"
                                                                   timeZone:nil
                                                                     locale:nil];
    
    NSString	*szStopTime		= [[NSDate date] descriptionWithCalendarFormat:@"YYYY-MM-dd HH:mm:ss"
																timeZone:nil
																  locale:nil];
    NSString	*szFinalResult = m_bFinalResult ? @"PASS" : @"FAIL";
    [m_dicMemoryValues setObject:szFinalResult forKey:@"FinalResult"];
    
	// Some exceptions
	if (!szURL)
	{
        [strReturn setString:@"Can't get URL!"];
        ATSDebug(@"INSERT_SFIS: => %@",strReturn);
        return [NSNumber numberWithBool:NO];
    }
    if (!szStartTime
		|| !szStopTime)
	{
        [strReturn setString:@"Can't get start or stop time !"];
        ATSDebug(@"INSERT_SFIS: => %@",strReturn);
        return [NSNumber numberWithBool:NO];
    }
	
	// Format URLs.
    if ([szSFCTimeOut intValue]>0)
        iTimeOut	= [szSFCTimeOut intValue];
    NSMutableString	*szURLPath	= [NSMutableString stringWithFormat:@"%@?c=ADD_RECORD",szURL];
	
	NSDictionary * dictPairs = [dicInsertContents objectForKey:@"InsertKey"];
	for(NSString *strKey in [dictPairs allKeys])
	{
		NSString	*strValue	= [dictPairs objectForKey:strKey];
		NSString	*strOutPutValue = @"";
		[self TransformKeyToValue:strValue returnValue:&strOutPutValue]; // Decode keys
		if ([strOutPutValue contains:@"@Empty@"]) {
            continue;
        }
		CFStringRef	strEncode	= CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
																		  (CFStringRef)strOutPutValue,
																		  NULL,
																		  CFSTR(":/?#[]@!$&'()*+,;= "),
																		  kCFStringEncodingUTF8);
		NSString	*strEncoded	= (NSString*)strEncode;
		[szURLPath appendFormat:@"&%@=%@", strKey, strEncoded];
		CFRelease(strEncode);
	}
	// Append start time and stop time
	CFStringRef	strStartTimeEncode	= CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                              (CFStringRef)szStartTime,
                                                                              NULL,
                                                                              CFSTR(":/?#[]@!$&'()*+,;= "),
                                                                              kCFStringEncodingUTF8);
	NSString	*strStartEncoded	= (NSString*)strStartTimeEncode;
	CFStringRef	strStopTimeEncode	= CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
																			  (CFStringRef)szStopTime,
																			  NULL,
																			  CFSTR(":/?#[]@!$&'()*+,;= "),
																			  kCFStringEncodingUTF8);
	NSString	*strStopEncoded	= (NSString*)strStopTimeEncode;
	[szURLPath appendFormat:@"&start_time=%@&stop_time=%@", strStartEncoded, strStopEncoded];
	CFRelease(strStartTimeEncode);
	CFRelease(strStopTimeEncode);
    
	// Post response to SFIS
    NSHTTPURLResponse	*theResponse;
    NSError				*errors;
    BOOL				bRet	= YES;
    ATSDebug(@"The URL is [%@]", szURLPath);
    
    NSMutableURLRequest	*theRequest	= [[NSMutableURLRequest alloc]
									   initWithURL:[NSURL URLWithString:szURLPath]];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setValue:@"text/html;charset=UTF8"
	  forHTTPHeaderField:@"Content-Type"];
    [theRequest setTimeoutInterval:iTimeOut];
    NSData	*dataRet	= [NSURLConnection sendSynchronousRequest:theRequest
											returningResponse:&theResponse
														error:&errors];
    if ([(NSHTTPURLResponse *)theResponse statusCode] == 200)
    {
        NSString	*szResposeData	= [[NSString alloc] initWithData:dataRet
														encoding:NSUTF8StringEncoding];
        
        NSRange range   = [szResposeData rangeOfString:@"SFC_OK"];
        bRet  = (NSNotFound != range.location);
        ATSDebug(@"InsertDataToSFC : Response = %@", szResposeData);
        [strReturn setString:szResposeData];
        [szResposeData release];
    }
    else
	{
        ATSDebug(@"InsertDataToSFC : statusCode = %ld, Response Headers = %@",
				 (long)[(NSHTTPURLResponse *)theResponse statusCode],
				 [(NSHTTPURLResponse *)theResponse allHeaderFields]);
        [strReturn setString:@"statusCode != 200"];
        bRet	= NO;
    }
    [theRequest release];
    return [NSNumber numberWithBool:bRet];
}

// Link KP SN with ISN into the SFIS

-(NSNumber*)SFIS_LINK:(NSDictionary*)dicInsertContents
         RETURN_VALUE:(NSMutableString*)strReturn
{
    NSInteger	iTimeOut        = 5;
    //url
    NSString	*szURL          = [dicInsertContents objectForKey:@"SFCURL"] ?
    [dicInsertContents objectForKey:@"SFCURL"]:
    [m_dicMemoryValues objectForKey:descriptionOfGHStationInfo(IP_SFC_URL)];
    //sn
	NSString	*szISN          = [dicInsertContents objectForKey:@"ISN"] ?
    [m_dicMemoryValues objectForKey: [dicInsertContents objectForKey:@"ISN"]]:
    m_szISN;
    //product
    NSString	*szProduct      = [dicInsertContents objectForKey:@"PRODUCT"] ?
    [dicInsertContents objectForKey:@"PRODUCT"]:
    [m_dicMemoryValues objectForKey:descriptionOfGHStationInfo(IP_PRODUCT)];
    //station name
    NSString	*szStationName  = [dicInsertContents objectForKey:@"STATIONNAME"] ?
    [dicInsertContents objectForKey:@"STATIONNAME"]:
    [m_dicMemoryValues objectForKey:descriptionOfGHStationInfo(IP_STATION_TYPE)];
    //station id
    NSString	*szStationID    = [dicInsertContents objectForKey:@"STATIONID"] ?
    [dicInsertContents objectForKey:@"STATIONID"]:
    [[m_dicMemoryValues objectForKey:descriptionOfGHStationInfo(IP_STATION_ID)] stringByReplacingOccurrencesOfString:[m_dicMemoryValues objectForKey:descriptionOfGHStationInfo(IP_STATION_TYPE)]
                                                                                                          withString:szStationName];
    //mac address
    NSString	*szMacAddr      = [[dicInsertContents objectForKey:@"OFFLINE"] boolValue] ?
    [self Mac_Address] : [m_dicMemoryValues objectForKey:descriptionOfGHStationInfo(IP_MAC)];
    
    //sfc time out
    NSString	*szSFCTimeOut   = [m_dicMemoryValues objectForKey:descriptionOfGHStationInfo(IP_SFC_TIMEOUT)];
    
    //insert time
	//Raniys on 07/15/2014: Update for keypart auto link, Change the AUTO-LINK test time be 15s early, it must have the test record on SFIS before test station
	NSDate		*dateStationStartTime   = [m_dicMemoryValues objectForKey:@"Single_Start_Time"];
    NSString	*szStartTime            = [[dateStationStartTime dateByAddingTimeInterval:-10] descriptionWithCalendarFormat:@"YYYY-MM-dd HH:mm:ss"
                                                                                        timeZone:nil
                                                                                          locale:nil];
	
	NSString	*szStopTime             = [[dateStationStartTime dateByAddingTimeInterval:-5] descriptionWithCalendarFormat:@"YYYY-MM-dd HH:mm:ss"
                                                                                        timeZone:nil
                                                                                          locale:nil];
    if (!szISN
        || !szURL
		|| !szProduct
		|| !szStationName
		|| !szStationID
		|| !szMacAddr)
	{
        [strReturn setString:@"May missed json file !"];
        ATSDebug(@"SFIS_LINK: => %@", strReturn);
        return [NSNumber numberWithBool:NO];
    }
    if (!szStartTime
		|| !szStopTime)
	{
        [strReturn setString:@"Can't get start or stop time !"];
        ATSDebug(@"SFIS_LINK: => %@",strReturn);
        return [NSNumber numberWithBool:NO];
    }
    if ([szSFCTimeOut intValue]>0)
    {
        iTimeOut	= [szSFCTimeOut intValue];
    }
    
	
    NSMutableDictionary *dicPairs   = [[NSMutableDictionary alloc]initWithObjectsAndKeys:szISN,@"sn",
                                       szProduct,@"product",
                                       szStationName,@"test_station_name",
                                       szStationID,@"station_id",
                                       szMacAddr,@"mac_address",
                                       szStartTime,@"start_time",
                                       szStopTime,@"stop_time", nil];
    NSDictionary	*dicInsert	= [dicInsertContents objectForKey:@"INSERTKEY"];
	for(NSString *strKey in [dicInsert allKeys])
	{
		NSString	*strValue	= [m_dicMemoryValues objectForKey:[dicInsert objectForKey:strKey]];
        if (strValue)
        {
            [dicPairs setObject:strValue forKey:strKey];
        }
        else
        {
            ATSDebug(@"The %@ value is null",strKey);
            [strReturn setString:[NSString stringWithFormat:@"The %@ value is null",strKey]];
            [dicPairs release];
            return [NSNumber numberWithBool:NO];
        }
	}
    
    NSMutableString	*szURLPath	= [NSMutableString stringWithFormat:@"%@?result=PASS&c=ADD_RECORD",szURL];
	for(NSString *strKey in [dicPairs allKeys])
	{
		NSString	*strValue	= [dicPairs objectForKey:strKey];
		CFStringRef	strEncode	= CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
																		  (CFStringRef)strValue,
																		  NULL,
																		  CFSTR(":/?#[]@!$&'()*+,;= "),
																		  kCFStringEncodingUTF8);
		NSString	*strEncoded	= (NSString*)strEncode;
		[szURLPath appendFormat:@"&%@=%@", strKey, strEncoded];
		CFRelease(strEncode);
	}
    [dicPairs release];
    
    NSHTTPURLResponse	*theResponse;
    NSError				*errors;
    ATSDebug(@"%@", szURLPath);
    
    NSMutableURLRequest	*theRequest	= [[NSMutableURLRequest alloc]
									   initWithURL:[NSURL URLWithString:szURLPath]];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setValue:@"text/html;charset=UTF8"
	  forHTTPHeaderField:@"Content-Type"];
    [theRequest setTimeoutInterval:iTimeOut];
    NSData	*dataRet	= [NSURLConnection sendSynchronousRequest:theRequest
											returningResponse:&theResponse
														error:&errors];
    if ([(NSHTTPURLResponse *)theResponse statusCode] == 200)
    {
        NSString	*szResposeData	= [[NSString alloc] initWithData:dataRet
														encoding:NSUTF8StringEncoding];
        
        if ([szResposeData contains:@"0 SFC_OK"]) // Insert first time and insert OK.
        {
            ATSDebug(@"InsertDataToSFC : Response = %@", szResposeData);
            [strReturn setString:szResposeData];
            [szResposeData release];
            [theRequest release];
            return [NSNumber numberWithBool:YES];
        }
        if ([szResposeData contains:@"2 SFC_FATAL_ERROR"])   // Response is FATAL ERROR
        {
            // Already linked to current sn on SFIS
            if ([szResposeData contains:@"Already Linked !"])
            {
                ATSDebug(@"InsertDataToSFC : Response = %@", szResposeData);
                [strReturn setString:[NSString stringWithFormat:@"Already link to %@",szISN]];
                [szResposeData release];
                [theRequest release];
                return [NSNumber numberWithBool:YES];
            }
            // Already linked to other sn on SFIS
            else if ([szResposeData contains:@"Already Linked to ISN"])
            {
                NSString    *strOriISN  = [szResposeData subByRegex:@"Already Linked to ISN \\[(.*?)\\]" name:nil error:nil];
                ATSDebug(@"InsertDataToSFC : FAIL Response = %@", szResposeData);
                [strReturn setString:[NSString stringWithFormat:@"Already link to [%@], != [%@]",strOriISN,szISN]];
                [szResposeData release];
                [theRequest release];
                return [NSNumber numberWithBool:NO];
            }
            else // Other Error Message
            {
                ATSDebug(@"InsertDataToSFC : FAIL Response = %@", szResposeData);
                [strReturn setString:szResposeData];
                [szResposeData release];
                [theRequest release];
                return [NSNumber numberWithBool:NO];
            }
        }
        else
        {
            ATSDebug(@"InsertDataToSFC: FAIL Resposne = %@",szResposeData);
            [strReturn setString:[NSString stringWithFormat:@"Response format error [%@]",szResposeData]];
            [szResposeData release];
            [theRequest release];
            return [NSNumber numberWithBool:NO];
        }
    }
    else
	{
        ATSDebug(@"InsertDataToSFC : statusCode = %ld, Response Headers = %@",
				 (long)[(NSHTTPURLResponse *)theResponse statusCode],
				 [(NSHTTPURLResponse *)theResponse allHeaderFields]);
        [strReturn setString:@"statusCode != 200"];
    }
    [theRequest release];
    return [NSNumber numberWithBool:NO];
}

#pragma mark ############################## Commands Tool Functions ##############################
// 2011-12-2 added by lucy
// Descripton: judge the nand size spec by the different value from SFC
// Param:
//      NSDictionary    *dicContents        : Settings
//      NSMutableString *strReturnValue     : Return value 
- (NSNumber*)JUDGE_NANDSIZE_SPEC:(NSDictionary*)dicContents
					RETURN_VALUE:(NSMutableString*)strReturnValue
{  
    NSNumber	*numRet;
    NSString	*szNandSizeValue	= [m_dicMemoryValues objectForKey:@"Nand_Size"];
    ATSDebug(@"Nand szie from SFC is %@ ", szNandSizeValue);
    id	dicForNandSize	= [dicContents objectForKey:KFZ_Script_JudgeNandSizeSpec]; 
    
    if (dicForNandSize != nil) 
    {
        NSString	*szSpec	= [dicForNandSize objectForKey:szNandSizeValue];
        if(szSpec != NULL)
        {
            NSDictionary	*dicSpec	= [NSDictionary dictionaryWithObject:szSpec
																forKey:kFZ_Script_JudgeCommonBlack];
            dicSpec	= [NSDictionary dictionaryWithObject:dicSpec
												  forKey:kFZ_Script_JudgeCommonSpec];
            numRet	=[self JUDGE_SPEC:dicSpec
						RETURN_VALUE:strReturnValue];
        }
        else
        {
            [strReturnValue setString:[NSString stringWithFormat:
									   @"The value %@ haven't no spec,Please check it!",
									   szNandSizeValue]];
            numRet	= [NSNumber numberWithBool:NO];
        }
    }  
    else
    {
        ATSDebug(@"Haven't no specs") ;
        numRet	= [NSNumber numberWithBool:NO];
    }
    return numRet;
}

// 2011-12-2 added by lucy
// Descripton: First step:  query area by sn
//            Second step: query area by ban_sn
//             Third step:  read area from DFU
//             Fouth step:  compare the third value, if the same ,return yes;else, return no;
// Param:
//      NSDictionary    *dicContents        : Settings
//      NSMutableString *strReturnValue     : Return value 
- (NSNumber*)COMPAREAREA:(NSDictionary*)dicContents
			RETURN_VALUE:(NSMutableString*)strReturnValue
{
	//added by lucy 11.10.26 for querying area by ban_sn
    NSDictionary	*dictAreaMaintainTable	=[NSDictionary dictionaryWithObjectsAndKeys:
											  @"US",	@"0x00000000",
											  @"EU",	@"0x00000001", nil];
	// get Area from SFIS by sn
    NSString	*strArea_SN		= [m_dicMemoryValues objectForKey:@"AREA"];
    // get Area from MLB
	NSString	*strRSKU_MLB	= [m_dicMemoryValues objectForKey:@"RSKU"];
    NSArray		*array			= [strRSKU_MLB componentsSeparatedByString:@" "];
	NSString	*strArea_MLB	= (([array count] > 3)
								   ? [array	 objectAtIndex:2]
								   : @"Area_MLB");
    ATSDebug(@"The area from UI is %@", strArea_MLB);
    strArea_MLB	= [dictAreaMaintainTable objectForKey:strArea_MLB];
    //get Area from SFIS by ban_sn
    NSString	*strArea_Ban	= [m_dicMemoryValues objectForKey:@"AREA_ban_sn"];
    // compare 
	if ([strArea_SN isEqualToString:strArea_Ban]
		&& [strArea_Ban isEqualToString:strArea_MLB])
	{   
        [strReturnValue setString:[NSString stringWithFormat:
								   @"Matched(SFIS:%@,UNIT:%@,SFIS(70):%@)",
								   strArea_SN, strArea_MLB, strArea_Ban]];
        return [NSNumber numberWithBool:YES];
    }
    
    else
    {
        if(![strArea_Ban isEqualToString:strArea_MLB])
        {
            [strReturnValue setString:[NSString stringWithFormat:
									   @"UnMatched(SFIS(70):%@,UNIT:%@)",
									   strArea_Ban, strArea_MLB]];
            return [NSNumber numberWithBool:NO];
        }
        if(![strArea_MLB isEqualToString:strArea_SN])
        {
            [strReturnValue setString:[NSString stringWithFormat:
									   @"UnMatched(SFIS:%@,UNIT:%@)",
									   strArea_SN, strArea_MLB]];
            return [NSNumber numberWithBool:NO];
        }
        return [NSNumber numberWithBool:NO];
    }
    
}
// 2011-12-2 added by lucy
// Descripton: compare grape_sn and Lcm_sn from UI with SFC
//            
// Param:
//      NSDictionary    *dicContents        : Settings
//      NSMutableString *strReturnValue     : Return value 
- (NSNumber*)COMPAREDATAFORUI:(NSDictionary *)dicContents
				 RETURN_VALUE:(NSMutableString *)strReturnValue
{   
    BOOL		bStatus		= NO;
    NSString	*strUIKey	= [dicContents objectForKey:KIADeviceSFISUIItem];
    NSString	*strLastKey	= [dicContents objectForKey:KIADeviceUILastItem];
    NSString	*szUIValue	= [m_dicMemoryValues objectForKey:strUIKey];
	ATSDebug(@"Compare original data : %@",szUIValue);
	ATSDebug(@"Compare SFC data : %@", strReturnValue);
	if (strReturnValue != NULL)
    {
        if([[szUIValue uppercaseString]
			isEqualToString:[strReturnValue uppercaseString]])
			bStatus	= YES;
		else 
		{
			[strReturnValue setString:[NSString stringWithFormat:
									   @"UnMatched(SFIS:%@,UI:%@)",
									   strReturnValue, szUIValue]];
			bStatus	= NO ;
		}
	}
    if (!bStatus)	// added by lucy for if fail it will cancel next item. 
        m_bCancelFlag	= YES;
    else
    {
        NSInteger	iLocation	= [[dicContents objectForKey:KIADeviceUILocation]
								   intValue];
        NSInteger	iLength		= [[dicContents objectForKey:KIADeviceUILength]
								   intValue];
        szUIValue	= [self catchFromString:szUIValue
								 location:iLocation
								   length:iLength];
        [m_dicMemoryValues setObject:szUIValue
							  forKey:strLastKey];
    }
    return [NSNumber numberWithBool:bStatus];
}

//2011-12-10 add by Winter
// Calculate DUT config, and memory for key "CFG#"
// Param:
//       NSDictionary    *dicContents        : Settings in script
//       NSMutableString *strReturnValue     : Return value
// Return:
//      Actions result
- (NSNumber *)JUDGE_CONFIG:(NSDictionary *)dicContents
			  RETURN_VALUE:(NSMutableString*)strReturnValue
{
	NSString		*szUNIT			= @"",	*szSBUILD				= @"",
					*szBuild_Event	= @"",	*szBuild_Matrix_Config	= @"";
	NSString		*szSFCConfig		= [m_dicMemoryValues objectForKey:@"Config"];
	NSArray			*arrCfgSFC			= [szSFCConfig componentsSeparatedByString:@"/"];
	NSString		*szFinalCfg;
    NSDictionary	*dicSendCommand		= [dicContents objectForKey:@"SEND_COMMAND:"];
    NSDictionary	*dicReceiveCommand	= [dicContents objectForKey:@"READ_COMMAND:RETURN_VALUE:"];
	//check SFIS Config is NULL or not
	if (szSFCConfig==nil
		|| [[szSFCConfig uppercaseString]
			isEqualToString:@"NULL" ])
	{
		[m_dicMemoryValues setValue:szUNIT
							 forKey:@"UNIT#"];
		[m_dicMemoryValues setValue:szSBUILD
							 forKey:@"S_BUILD"];
		[m_dicMemoryValues setValue:szBuild_Event
							 forKey:@"BUILD_EVENT"];
		[m_dicMemoryValues setValue:szBuild_Matrix_Config
							 forKey:@"BUILD_MATRIX_CONFIG"];
		return [NSNumber numberWithBool:YES];
	}
	else 
    {
		//check the config from MLB
        [self SEND_COMMAND:dicSendCommand];
        [self READ_COMMAND:dicReceiveCommand
			  RETURN_VALUE:strReturnValue];
		//check if SFIS less than 5 datas
		if ([arrCfgSFC count] < 5)
		{
			NSLog(@"Config from SFC format error, Config is %@",
				  szSFCConfig);
			[m_dicMemoryValues setValue:szUNIT
								 forKey:@"UNIT#"];
			[m_dicMemoryValues setValue:szSBUILD
								 forKey:@"S_BUILD"];
			[m_dicMemoryValues setValue:szBuild_Event
								 forKey:@"BUILD_EVENT"];
			[m_dicMemoryValues setValue:szBuild_Matrix_Config
								 forKey:@"BUILD_MATRIX_CONFIG"];
			return [NSNumber numberWithBool:NO];
		}
		//if the MLB never write Config , Diag command will return "Not Found"
		NSRange	rang1	= [strReturnValue rangeOfString:@"Not Found"];
		if ((NSNotFound != rang1.location)
			&& (rang1.length >0)
			&&((rang1.location+ rang1.length) <= [strReturnValue length]))
		{
			szFinalCfg	= [NSString stringWithFormat:@"%@/%@///%@/%@",
						   [arrCfgSFC objectAtIndex:0],	[arrCfgSFC objectAtIndex:1],
						   [arrCfgSFC objectAtIndex:3],	[arrCfgSFC objectAtIndex:4]];
            [m_dicMemoryValues setValue:szFinalCfg
								 forKey:@"CFG#"];
			ATSDebug(@"Did not find Config in MLB");
			szBuild_Event	= [NSString stringWithFormat:@"%@%@",
							   [arrCfgSFC objectAtIndex:0], [arrCfgSFC objectAtIndex:1]];
			szSBUILD		= [NSString stringWithFormat:@"%@_%@",
							   szBuild_Event, [arrCfgSFC objectAtIndex:4]];
			szBuild_Matrix_Config	= [arrCfgSFC objectAtIndex:4];
			szUNIT=[arrCfgSFC objectAtIndex:3];
		}
		else 
        {
            //if the MLB had config
			NSArray	*arrCfgDUT	= [strReturnValue componentsSeparatedByString:@"/"];
			//to check if Config are wrong from SFIS and DUT
			if ([arrCfgDUT count] < 4
				|| [arrCfgSFC count] < 5)
			{
				ATSDebug(@"Config from DUT format error, Config is %@",
						 strReturnValue);
				ATSDebug(@"Config from SFC format error, Config is %@",
						 szSFCConfig);
				[m_dicMemoryValues setValue:szUNIT
									 forKey:@"UNIT#"];
				[m_dicMemoryValues setValue:szSBUILD
									 forKey:@"S_BUILD"];
				[m_dicMemoryValues setValue:szBuild_Event
									 forKey:@"BUILD_EVENT"];
				[m_dicMemoryValues setValue:szBuild_Matrix_Config
									 forKey:@"BUILD_MATRIX_CONFIG"];
				return [NSNumber numberWithBool:NO];
			}
            
            szFinalCfg	= [NSString stringWithFormat:@"%@/%@/%@/%@/%@/%@",
						   [arrCfgSFC objectAtIndex:0],	[arrCfgSFC objectAtIndex:1],
						   [arrCfgDUT objectAtIndex:2],	[arrCfgDUT objectAtIndex:3],
						   [arrCfgSFC objectAtIndex:3],	[arrCfgSFC objectAtIndex:4]];
            [m_dicMemoryValues setValue:szFinalCfg
								 forKey:@"CFG#"];
			szUNIT					= [arrCfgSFC objectAtIndex:3];
            szBuild_Event			= [NSString stringWithFormat:@"%@%@",
									   [arrCfgSFC objectAtIndex:0], [arrCfgSFC objectAtIndex:1]];
            szSBUILD				= [NSString stringWithFormat:@"%@_%@",
									   szBuild_Event, [arrCfgSFC objectAtIndex:4]];
            szBuild_Matrix_Config	= [arrCfgSFC objectAtIndex:4];
		}
		[m_dicMemoryValues setValue:szUNIT
							 forKey:@"UNIT#"];
		[m_dicMemoryValues setValue:szSBUILD
							 forKey:@"S_BUILD"];
		[m_dicMemoryValues setValue:szBuild_Event
							 forKey:@"BUILD_EVENT"];
		[m_dicMemoryValues setValue:szBuild_Matrix_Config
							 forKey:@"BUILD_MATRIX_CONFIG"];
		[strReturnValue setString:szFinalCfg];
		return [NSNumber numberWithBool:YES];
	}
}

//2012.1.6 add by lucy
//sbuild=BUILD_EVENT +_+BUILD_MATRIX_CONFIG = N94P-EVT_PG01
//sbuild_unit = 0064
//CFG# = N94P/DVT/MB03/0186/0064/P-PDFC-01    (old)
//CFG# = N94P/DVT/MB03/0186/PG01/0064         (now)
// P106/PROTO0-MINI/P-SOP-02-6/0008/ (scan config)
// P106/PROTO0-MINI/0021/MINI/*/**/*     (mlb config)
// P106/PROTO0-MINI/0021/MINI/0008/P-SOP-02-6 (final config)
-(NSNumber *) COMBINE_CONFIG_By_UI:(NSDictionary *)dicContents
					  RETURN_VALUE:(NSMutableString *)strReturnValue
{  
    //  sample : P105/PROTO0/P-PDFC-03/0002/
    NSString		*szScanConfig		= [m_dicMemoryValues valueForKey:@"CONFIG"];
    NSString		*szUNIT				= @"";
    NSString		*szSBUILD			= @"";
    NSString	*szBUILD_MATRIX_CONFIG	= @"";
    NSString		*szBUILD_EVENT		= @"";
    NSDictionary	*dicSendCommand		= [dicContents objectForKey:@"SEND_COMMAND:"];
    NSDictionary	*dicReceiveCommand	= [dicContents objectForKey:@"READ_COMMAND:RETURN_VALUE:"];
    NSString		*szFinalCfg, *szMidCfg;
    
    NSArray	*arrScanCfg	= [szScanConfig componentsSeparatedByString:@"/"];
    if ([arrScanCfg count]<5)
    {
        [strReturnValue setString:@"The format of config from scanner is error,please check it!"];
        return [NSNumber numberWithBool:NO];
    }
    
     //send the command to the DFU   
    [self SEND_COMMAND:dicSendCommand];
    [self READ_COMMAND:dicReceiveCommand
		  RETURN_VALUE:strReturnValue];
    
    //if the MLB never write Config , Diag command will return "Not Found"
    NSRange	rang1			= [strReturnValue rangeOfString:@"Not Found"];
    NSArray	*arrMlbConfig	=[strReturnValue componentsSeparatedByString:@"/"];
    
    if ((NSNotFound != rang1.location)
		&& (rang1.length >0)
		&& ((rang1.location+ rang1.length) <= [strReturnValue length]))
    {
        //  0002   P-PDFC-03
        szFinalCfg	= [NSString stringWithFormat:@"*/*/*/*/%@/%@",
					   [arrScanCfg objectAtIndex:3], [arrScanCfg objectAtIndex:2]];
        [m_dicMemoryValues setValue:szFinalCfg
							 forKey:@"CFG#"];
    }
    else
    {  
        if ([arrMlbConfig count] < 4)
        {
            ATSDebug(@"The format of config from DFU is error,please check it!");
            return [NSNumber numberWithBool:NO];
        }
        else
        { 
			szMidCfg	= [NSString stringWithFormat:@"%@/%@/%@/%@",
						   [arrMlbConfig objectAtIndex:0],	[arrMlbConfig objectAtIndex:1],
						   [arrMlbConfig objectAtIndex:2],	[arrMlbConfig objectAtIndex:3]];
        }
        szFinalCfg	= [NSString stringWithFormat:@"%@/%@/%@",
					   szMidCfg, [arrScanCfg objectAtIndex:3], [arrScanCfg objectAtIndex:2]];
        [m_dicMemoryValues setValue:szFinalCfg
							 forKey:@"CFG#"];
    }
    szUNIT					= [arrScanCfg objectAtIndex:3];
    szBUILD_MATRIX_CONFIG	=[arrScanCfg objectAtIndex:2];
    // P105-PROTO0
    szBUILD_EVENT			= [NSString stringWithFormat:@"%@-%@",
							   [arrScanCfg objectAtIndex:0], [arrScanCfg objectAtIndex:1]];
    //P105-PROTO0_P-PDFC-03
    szSBUILD				= [NSString stringWithFormat:@"%@_%@",
							   szBUILD_EVENT, szBUILD_MATRIX_CONFIG];
    [m_dicMemoryValues setValue:szUNIT
						 forKey:@"UNIT#"];
    [m_dicMemoryValues setValue:szSBUILD
						 forKey:@"S_BUILD"];
    [m_dicMemoryValues setValue:szBUILD_EVENT
						 forKey:@"BUILD_EVENT"];
    [m_dicMemoryValues setValue:szBUILD_MATRIX_CONFIG
						 forKey:@"BUILD_MATRIX_CONFIG"];
    [strReturnValue setString:szFinalCfg];
    return [NSNumber numberWithBool:YES];
}

// Start 2012.4.16 Add note by Sky_Ge 
// Descripton: It is for QT0 station to combine config.
//             if the sbuild_unit&sbuild in SFC is NULL,return yes(for PVT)
//             if the CFG in DUT is not found , conbine the config like "*/*/*/*/0019/DSP-DOE1R"
//             other conbine the config like "P105/P2/0733/f3/0019/DSP-DOE1R"
// Param:
// NSMutableString *strReturnValue : It is used to receive the reture value about commmand "syscfg print CFG#".
// NSDictionary *dicpara : setting in script.some para which need in this function.include command "syscfg print CFG#"
-(NSNumber*)COMBINE_CONFIG:(NSDictionary*)dicContents
			  RETURN_VALUE:(NSMutableString*)strReturnValue
{
    /* Modify the method for catch the config, modify by sky at 2015.12.10
     * No need to catch the config & unit number from sbuild & sbuild_unit
     * Just catch the information from config, the 3 & 4 index.
     */
    
    NSString        *szConfig           = [m_dicMemoryValues objectForKey:@"config"];
//    NSString		*szUNIT				= [m_dicMemoryValues valueForKey:@"sbuild_unit"];
//    NSString		*szSBUILD			= [m_dicMemoryValues valueForKey:@"sbuild"];
    NSString	*szBUILD_MATRIX_CONFIG	= @"*";
    NSString		*szBUILD_EVENT		= @"*";
    NSDictionary	*dicSendCommand		= [dicContents objectForKey:@"SEND_COMMAND:"];
    NSDictionary	*dicReceiveCommand	= [dicContents objectForKey:@"READ_COMMAND:RETURN_VALUE:"];
    NSArray         *aryKeys            = [dicContents allKeys]; //Add by Raniys
    NSString		*szFinalCfg, *szMidCfg;
    
    //P106/PROTO0-MINI/P-SOP-02-6/0008/
    // Not found in SFIS? Show FAIL.
    if (nil == szConfig || [@"NULL" isEqualToString:szConfig])
    {
        ATSDebug(@"The config is [%@]", szConfig);
        [strReturnValue setString:@"No FATP config, skip burn CFG#."];
        return [NSNumber numberWithBool:YES];
    }
    
    NSArray         *arrFATPConfig      = [szConfig componentsSeparatedByString:@"/"];
    
    if (5 > [arrFATPConfig count])
    {
        ATSDebug(@"The config is [%@]", szConfig);
        [strReturnValue setString:@"FATP config incorrect!"];
        return [NSNumber numberWithBool:NO];
    }
    
    NSString		*szUNIT         = [arrFATPConfig objectAtIndex:4];
    NSString        *szSBUILD       = [NSString stringWithFormat:@"%@-%@_%@", [arrFATPConfig objectAtIndex:0], [arrFATPConfig objectAtIndex:1], [arrFATPConfig objectAtIndex:3]];
    szBUILD_MATRIX_CONFIG           = [arrFATPConfig objectAtIndex:3];

    if(szUNIT == NULL || szBUILD_MATRIX_CONFIG == NULL)
    {
        ATSDebug(@"The sbuild_unit is [%@], the sbuild is [%@]", szUNIT, szSBUILD);
        szUNIT                  = @"";
        szBUILD_MATRIX_CONFIG	= @"";
        [m_dicMemoryValues setValue:szUNIT
                             forKey:@"UNIT#"];
        [m_dicMemoryValues setValue:szSBUILD
                             forKey:@"S_BUILD"];
        [m_dicMemoryValues setValue:szBUILD_EVENT
                             forKey:@"BUILD_EVENT"];
        [m_dicMemoryValues setValue:szBUILD_MATRIX_CONFIG
                             forKey:@"BUILD_MATRIX_CONFIG"];
        [strReturnValue setString:@"No FATP config, skip burn CFG#. "];
        return [NSNumber numberWithBool:YES];
    }
    // SFIS config incorrect? Show FAIL.
    
    /* Just catch the value from config. 
     * Moidfy by sky, 2015.12.10
    NSArray	*aryBuild		= [szSBUILD componentsSeparatedByString:@"_"];
    if ([aryBuild count] < 2)
    {
        [strReturnValue setString:@"FATP config incorrect, skip burn CFG#. "];
        return [NSNumber numberWithBool:YES];
    }
    else
    {
        if ([aryBuild count]==3) {
            szBUILD_MATRIX_CONFIG = [NSString stringWithFormat:@"%@_%@",[aryBuild objectAtIndex:1],[aryBuild objectAtIndex:2]];
        }
        else
            szBUILD_MATRIX_CONFIG	= [aryBuild objectAtIndex:1];
        szBUILD_EVENT			= [aryBuild objectAtIndex:0];
    }
     */
    szBUILD_EVENT   = [NSString stringWithFormat:@"%@-%@", [arrFATPConfig objectAtIndex:0], [arrFATPConfig objectAtIndex:1]];
    // MLB config incorrect? Instead by *.
    if (dicSendCommand != NULL)
    {
        [self SEND_COMMAND:dicSendCommand];
        [self READ_COMMAND:dicReceiveCommand
              RETURN_VALUE:strReturnValue];
    }
    

    NSArray	*arrMlbConfig	=[strReturnValue componentsSeparatedByString:@"/"];
    if(!arrMlbConfig || [arrMlbConfig count] < 4)
        arrMlbConfig	= [NSArray arrayWithObjects:@"*", @"*", @"*", @"*", @"*", nil];
    //    //if the MLB never write Config , Diag command will return "Not Found"
    //    NSRange	rang1	= [strReturnValue rangeOfString:@"Not Found"];
    //    if ((NSNotFound != rang1.location)
    //		&& (rang1.length >0)
    //		&& ((rang1.location+ rang1.length) <= [strReturnValue length]))
    //    {
    //        // N94P/EVT///PG01/0064
    ////        ATSDebug(@"Not find config in MLB!");
    ////        szFinalCfg	= [NSString stringWithFormat:@"*/*/*/*/%@/%@",
    ////					   szUNIT, szBUILD_MATRIX_CONFIG];
    ////        [m_dicMemoryValues setValue:szFinalCfg
    ////							 forKey:@"CFG#"];
    //		return [NSNumber numberWithBool:NO];
    //    }
    //    else
    //    {
    //        //if the MLB has config
    //        if ([arrMlbConfig count] < 4)
    //        {
    //            ATSDebug(@"The format of config from DFU is error,please check it!");
    //            return [NSNumber numberWithBool:NO];
    //        }
    //        else
    
    //Add by raniys on 3/20/2015 for project code changing
    for (int i = 0; i < [aryKeys count]; i++)
    {
        if ([szSBUILD ContainString:[aryKeys objectAtIndex:i]])
        {
            ATSDebug(@"Need to tansfer the config, the original sbuild is [%@]", szSBUILD);
            szSBUILD = [szSBUILD stringByReplacingOccurrencesOfString:[aryKeys objectAtIndex:i] withString:[dicContents objectForKey:[aryKeys objectAtIndex:i]]];
            ATSDebug(@"The new sbuild is [%@]", szSBUILD);
        }
    }
    //end add by raniys
    
    szMidCfg	= [NSString stringWithFormat:@"%@/%@/%@/%@",
                   [arrMlbConfig objectAtIndex:0], [arrMlbConfig objectAtIndex:1],
                   [arrMlbConfig objectAtIndex:2], [arrMlbConfig objectAtIndex:3]];
    if([[arrMlbConfig objectAtIndex:2]isEqualToString:@"SUB"]){
        szMidCfg	= [NSString stringWithFormat:@"%@/%@",[arrMlbConfig objectAtIndex:1],
                       [arrMlbConfig objectAtIndex:2]];
    }
    szFinalCfg	= [NSString stringWithFormat:@"%@/%@/%@",
                   szMidCfg, szBUILD_MATRIX_CONFIG, szUNIT];
    ATSDebug(@"The CFG# is [%@]\nThe UNIT# is [%@]\nThe S_BUILD is [%@]\nThe BUILD_EVENT is [%@]\nThe Build_MATRIX_CONFIG is [%@]", szFinalCfg, szUNIT, szSBUILD, szBUILD_EVENT, szBUILD_MATRIX_CONFIG);
    [m_dicMemoryValues setValue:szFinalCfg
                         forKey:@"CFG#"];
    //    }
    [m_dicMemoryValues setValue:szUNIT
                         forKey:@"UNIT#"];
    [m_dicMemoryValues setValue:szSBUILD
                         forKey:@"S_BUILD"];
    [m_dicMemoryValues setValue:szBUILD_EVENT
                         forKey:@"BUILD_EVENT"];
    [m_dicMemoryValues setValue:szBUILD_MATRIX_CONFIG
                         forKey:@"BUILD_MATRIX_CONFIG"];
    [strReturnValue setString:szFinalCfg];
    return [NSNumber numberWithBool:YES];
}

//2015-8-20 add by York
//If config are "" NULL nil and "NULL" in SFIS? return NO.
-(NSNumber*)JUDGE_CONFIG_FOR_SUB:(NSDictionary*)dicContents
                    RETURN_VALUE:(NSMutableString*)strReturnValue
{
    NSString        *szConfig           = [m_dicMemoryValues objectForKey:@"config"];
    //P106/PROTO0-MINI/P-SOP-02-6/0008/
    // Return "" NULL nil and "NULL" in SFIS? Show FAIL.
    if (nil == szConfig || NULL == szConfig || [@"NULL" isEqualToString:szConfig] || [@"null" isEqualToString:szConfig] || [@"" isEqualToString:szConfig])
    {
        [strReturnValue setString:@"No FATP config, skip upload config."];
        return [NSNumber numberWithBool:NO];
    }
    else
    {
        [strReturnValue setString:szConfig];
        return [NSNumber numberWithBool:YES];
    }
}

//2011-12-10 add by Winter
// Calculate camera sn from strReturnValue, and compare it with SFIS.
// Param:
//       NSDictionary    *dicContents        : Settings in script
//       NSMutableString *strReturnValue     : Return value
// Return:
//      Actions result
-(NSNumber*)CHECK_CAMERA_SN:(NSDictionary*)dicContents
			   RETURN_VALUE:(NSMutableString*)strReturnValue
{
    NSString		*szKeyValue			= [dicContents valueForKey:kFZ_Script_MemoryKey];
    //Add Plant Code & Config Code Mapping Table, 5.15.12
    NSDictionary	*dicPlantCodeMT		= [dicContents objectForKey:@"PLANTCODE"];
    NSDictionary	*dicConfigCodeMT	= [dicContents objectForKey:@"CONFIGCODE"];
    //Add End, 5.15.12
    NSRange			rangeStartCMS;
    NSRange         rangeEndCMS;
    NSString        *rangeCatchValue;
    NSString        *szFCMSSN;
    NSString        *szBCMSSN;
    BOOL            bCombineResult;
    NSString        *szFCMSfromSFIC		= [m_dicMemoryValues valueForKey:@"front_nvm_barcode"];
    NSString        *szBCMSfromSFIC		= [m_dicMemoryValues valueForKey:@"back_nvm_barcode"];
    //Add ret value , default NO
    BOOL			bRet				= NO;
    
    if ([szKeyValue isEqualToString:@"FCMS"]) 
    {
        if ([strReturnValue ContainString:@"Sensor channel 1 detected :"]) 
        {
            rangeCatchValue	= [strReturnValue SubFrom:@"Sensor channel 1 detected :"
											  include:NO];
            if ([rangeCatchValue ContainString:@"NVM Data 512 bytes :"]) 
            {
				rangeCatchValue	= [rangeCatchValue SubFrom:@"NVM Data 512 bytes :"
												   include:NO];
                rangeStartCMS	= [rangeCatchValue rangeOfString:@"0x0 : "];
                rangeEndCMS		= [rangeCatchValue rangeOfString:@"0x8 : "];
                
                if (NSNotFound == rangeStartCMS.location
					|| NSNotFound == rangeEndCMS.location
					|| rangeStartCMS.length ==0
					|| rangeEndCMS.length ==0
					|| (rangeStartCMS.location+ rangeStartCMS.length) > [rangeCatchValue length]
					|| (rangeEndCMS.location +rangeEndCMS.length) > [rangeCatchValue length])
                {
                    ATSDebug(@"NVM format error");
                    [strReturnValue setString: @"NVM format Error"];
                    return [NSNumber numberWithBool:NO];
                }
                szFCMSSN	= [rangeCatchValue substringToIndex:rangeEndCMS.location];
                szFCMSSN	= [szFCMSSN substringFromIndex:(rangeStartCMS.location
															+ rangeStartCMS.length)];
                NSArray	*aryFCMSSN	= [szFCMSSN componentsSeparatedByString:@" "];
                //Compare Sequence Number
                if ([aryFCMSSN count] >= 6) 
                {
                    bCombineResult	= [self COMBINE_CAMERA_SN:aryFCMSSN
												RETURN_VALUE:&szFCMSSN];
                    //----compare with SFIS
                    if ([szFCMSfromSFIC length] >= 17) 
                    {
                        if (bCombineResult
							&& [[szFCMSfromSFIC substringWithRange:NSMakeRange(3, 8)]
								isEqualToString:szFCMSSN])
                            [strReturnValue setString:[NSString stringWithFormat:
													   @"FCMSSN from DUT:%@,FCMS from SFIS:%@",
													   szFCMSSN, szFCMSfromSFIC]];
                        else
                        {
                            [strReturnValue setString:[NSString stringWithFormat:
													   @"Compare fail![FCMSSN from DUT:%@,FCMS from SFIS:%@]",
													   szFCMSSN, szFCMSfromSFIC]];
                            ATSDebug(@"Check Front Camera SN fail!");
                            return [NSNumber numberWithBool:NO];
                        }
                    }
                    else
                    {
                        [strReturnValue setString:[NSString stringWithFormat:
												   @"FCMS from SFIS Format Error:%@",
												   szFCMSfromSFIC]];
                        ATSDebug(@"FCMS from SFIS Format Error : FCMS length less than 17");
                        return [NSNumber numberWithBool:NO];
                    }
                }
                else
                {
                    ATSDebug(@"NVM format error");
                    [strReturnValue setString:@"NVM format Error"];
                    return [NSNumber numberWithBool:NO];
                }
                /* Get plant code and config from DUT Start*/
                // Deal with the plant code from NVM
                NSString		*strPlantCode		= [aryFCMSSN objectAtIndex:2];
                NSScanner		*scanner			= [NSScanner scannerWithString:strPlantCode];
                unsigned int	iValue				= 0;
                [scanner scanHexInt:&iValue];
                iValue	&= 0xf0;
                iValue	>>= 4;
                NSString		*strPlantCodeKey	= [NSString stringWithFormat:@"0x%X", iValue];
                
                // Deal with the config code's key from NVM
                rangeStartCMS	= [rangeCatchValue rangeOfString:@"0x10 : "];
                rangeEndCMS		= [rangeCatchValue rangeOfString:@"0x18 : "];
                if (NSNotFound == rangeStartCMS.location
					|| NSNotFound == rangeEndCMS.location
					|| rangeStartCMS.length ==0
					|| rangeEndCMS.length ==0
					|| (rangeStartCMS.location+ rangeStartCMS.length) > [rangeCatchValue length]
					|| (rangeEndCMS.location +rangeEndCMS.length) > [rangeCatchValue length])
                {
                    ATSDebug(@"NVM format error");
                    [strReturnValue setString: @"NVM format Error"];
                    return [NSNumber numberWithBool:NO];
                }
                
                NSString	*szNVMPart	= [rangeCatchValue substringToIndex:rangeEndCMS.location];
                szNVMPart	= [szNVMPart substringFromIndex:(rangeStartCMS.location
															 + rangeStartCMS.length)];
                NSArray		*arrNVMPart	= [szNVMPart componentsSeparatedByString:@" "];
                NSString	*strConfigCodeKey	= [arrNVMPart objectAtIndex:6];
                /* Get plant code and config's key from DUT End*/
                
                /* Get plant code and config from SFIS Start*/
                // Get the plant code
                NSString	*strPlantCodeFromSFIS	= [szFCMSfromSFIC substringWithRange:NSMakeRange(0, 3)];
                // Get the config code
                NSString	*strConfigCodeFromSFIS	= [szFCMSfromSFIC substringWithRange:NSMakeRange(11, 5)];
                
                /* Get plant code and config from DUT Start*/ 
                NSString	*strPlantCodeFromDut	= @"NULL";
				NSString	*strConfigCodeFromDut	= @"NULL";
                if (!dicPlantCodeMT) 
                {
                    [strReturnValue setString:@"Plant Code Table in script is empty."];
                    return [NSNumber numberWithBool:NO];
                }
                for(NSString *keyTemp in [dicPlantCodeMT allKeys])
                    if ([keyTemp isEqualToString:strPlantCodeKey])
                    {
                        strPlantCodeFromDut	= [NSString stringWithFormat:@"%@",
											   [dicPlantCodeMT objectForKey:strPlantCodeKey]];
                        break;
                    }
                if (!dicConfigCodeMT)
                {
                    [strReturnValue setString:@"Config Code Table in script is empty."]; 
                    return [NSNumber numberWithBool:NO];
                }
                for(NSString *keyTemp in [dicConfigCodeMT allKeys])
                    if([keyTemp isEqualToString:strConfigCodeKey])
                    {
                        strConfigCodeFromDut	= [NSString stringWithFormat:@"%@",
												   [dicConfigCodeMT objectForKey:strConfigCodeKey]];
                        break;
                    }
                /* Get plant code and config from DUT End*/ 
                /* Compare Start */ 
                if([strPlantCodeFromDut ContainString:strPlantCodeFromSFIS]
				   && [strConfigCodeFromDut ContainString:strConfigCodeFromSFIS])
                    bRet	= YES;
                else
                {
                    bRet	= NO;
                    [strReturnValue setString:[NSString stringWithFormat:
											   @"FCMS from SFIS is %@,Front Camera SN from UNIT is %@, Plant Code from unit is %@, Config Code from unit is %@",
											   szFCMSfromSFIC,		szFCMSSN,
											   strPlantCodeFromDut,	strConfigCodeFromDut]];
                }
                /* Compare End */
            }
            else
            {
                ATSDebug(@"NVM format error");
                [strReturnValue setString: @"NVM format Error"];
                return [NSNumber numberWithBool:NO];
            }
        }
        else
        {
            ATSDebug(@"NVM format error");
            [strReturnValue setString: @"NVM format Error"];
            return [NSNumber numberWithBool:NO];
        }
    }
    else if([szKeyValue isEqualToString:@"BCMS"])
    {
        if ([strReturnValue ContainString:@"Sensor channel 0 detected :"]) 
        {
            rangeCatchValue	= [strReturnValue SubFrom:@"Sensor channel 0 detected :"
											  include:NO];
            if ([rangeCatchValue ContainString:@"NVM Data 512 bytes :"])
            {
                rangeCatchValue	= [rangeCatchValue SubFrom:@"NVM Data 512 bytes :"
												   include:NO];
                rangeStartCMS	= [rangeCatchValue rangeOfString:@"0x10 : "];
                rangeEndCMS		= [rangeCatchValue rangeOfString:@"0x18 : "];
                if (NSNotFound == rangeStartCMS.location
					|| NSNotFound == rangeEndCMS.location
					||rangeStartCMS.length ==0
					|| rangeEndCMS.length ==0
					|| (rangeStartCMS.location+ rangeStartCMS.length) > [rangeCatchValue length]
					|| (rangeEndCMS.location +rangeEndCMS.length) > [rangeCatchValue length])
                {
                    ATSDebug(@"NVM format error");
                    [strReturnValue setString: @"NVM format Error"];
                    return [NSNumber numberWithBool:NO];
                }
                szBCMSSN	= [rangeCatchValue substringToIndex:rangeEndCMS.location];
                szBCMSSN	= [szBCMSSN substringFromIndex:rangeStartCMS.location+rangeStartCMS.length];
                NSArray	*aryBCMSSN	= [szBCMSSN componentsSeparatedByString:@" "];
                
                if ([aryBCMSSN count] >= 6)
                {
                    NSMutableArray	*aryMutableBCMS	= [[NSMutableArray alloc] init];
                    [aryMutableBCMS addObject:[aryBCMSSN objectAtIndex:0]];
                    [aryMutableBCMS addObject:[aryBCMSSN objectAtIndex:2]];
                    [aryMutableBCMS addObject:[aryBCMSSN objectAtIndex:1]];
                    [aryMutableBCMS addObject:[aryBCMSSN objectAtIndex:3]];
                    [aryMutableBCMS addObject:[aryBCMSSN objectAtIndex:4]];
                    [aryMutableBCMS addObject:[aryBCMSSN objectAtIndex:5]];
                    
                    bCombineResult	= [self COMBINE_CAMERA_SN:aryMutableBCMS
												RETURN_VALUE:&szBCMSSN];
                    [aryMutableBCMS release];
                    
                    //----compare with SFIS
                    if ([szBCMSfromSFIC length] >= 17) 
                    {
                        
                        if (bCombineResult
							&& [[szBCMSfromSFIC substringWithRange:NSMakeRange(3, 8)]
								isEqualToString:szBCMSSN])
                            [strReturnValue setString:[NSString stringWithFormat:
													   @"BCMSSN from DUT:%@,BCMS from SFIS:%@",
													   szBCMSSN, szBCMSfromSFIC]];
                        else
                        {
                            [strReturnValue setString:[NSString stringWithFormat:
													   @"Compare fail![BCMSSN from DUT:%@,BCMS from SFIS:%@]",
													   szBCMSSN, szBCMSfromSFIC]];
                            ATSDebug(@"Check Back Camera SN fail!");
                            return [NSNumber numberWithBool:NO];
                        }
                    }
                    else
                    {
                        [strReturnValue setString:[NSString stringWithFormat:
												   @"BCMS from SFIS Format Error:%@",
												   szBCMSfromSFIC]];
                        ATSDebug(@"BCMS from SFIS Format Error: BCMS length less than 17");
                        return [NSNumber numberWithBool:NO];
                    }
                }
                else
                {
                    ATSDebug(@"NVM format error");
                    [strReturnValue setString: @"NVM format Error"];
                    return [NSNumber numberWithBool:NO];
                }

                /* Get plant code and config from DUT Start */
                // Deal with the plant code from NVM
                NSString	*strPlantCode		= [aryBCMSSN objectAtIndex:1];
                NSScanner	*scanner			= [NSScanner scannerWithString:strPlantCode];
                unsigned int	iValue			= 0;
                [scanner scanHexInt:&iValue];
                iValue	&= 0xf0;
                iValue	>>= 4;
                NSString	*strPlantCodeKey	= [NSString stringWithFormat:@"0x%X", iValue];
                
                // Deal with the config code's key from NVM
                rangeStartCMS	= [rangeCatchValue rangeOfString:@"0x28 : "];
                rangeEndCMS		= [rangeCatchValue rangeOfString:@"0x30 : "];
                if (NSNotFound == rangeStartCMS.location
					|| NSNotFound == rangeEndCMS.location
					|| rangeStartCMS.length ==0
					|| rangeEndCMS.length ==0
					|| (rangeStartCMS.location+ rangeStartCMS.length) > [rangeCatchValue length]
					|| (rangeEndCMS.location +rangeEndCMS.length) > [rangeCatchValue length])
                {
                    ATSDebug(@"NVM format error");
                    [strReturnValue setString: @"NVM format Error"];
                    return [NSNumber numberWithBool:NO];
                }
                
                NSString	*szNVMPart		= [rangeCatchValue substringToIndex:rangeEndCMS.location];
                szNVMPart	= [szNVMPart substringFromIndex:(rangeStartCMS.location
															 + rangeStartCMS.length)];
                NSArray		*arrNVMPart		= [szNVMPart componentsSeparatedByString:@" "];
                // Here which is different from Front
                NSString	*strConfigCode	= [arrNVMPart objectAtIndex:0]; 
                scanner	= [NSScanner scannerWithString:strConfigCode];
                iValue	= 0;
                [scanner scanHexInt:&iValue];
                iValue	&= 0xf0;
                iValue	>>= 4;
                NSString	*strConfigCodeKey	= [NSString stringWithFormat:@"0x0%X",iValue];
                /* Get plant code and config's key from DUT End*/
                
                /* Get plant code and config from SFIS Start*/
                // Get the plant code
                NSString	*strPlantCodeFromSFIS	= [szBCMSfromSFIC substringWithRange:
													   NSMakeRange(0, 3)];
                // Get the config code
                NSString	*strConfigCodeFromSFIS	= [szBCMSfromSFIC substringWithRange:
													   NSMakeRange(11, 5)];
                
                /* Get plant code and config from DUT Start*/ 
                NSString	*strPlantCodeFromDut	= @"NULL";
				NSString	*strConfigCodeFromDut	= @"NULL";
                if (!dicPlantCodeMT) 
                {
                    [strReturnValue setString:@"Plant Code Table in script is empty."];
                    return [NSNumber numberWithBool:NO];
                }
                for(NSString *keyTemp in [dicPlantCodeMT allKeys])
                {
                    if ([keyTemp isEqualToString:strPlantCodeKey])
                    {
                        strPlantCodeFromDut	= [NSString stringWithFormat:@"%@",
											   [dicPlantCodeMT objectForKey:strPlantCodeKey]];
                        break;
                    }
                }
                if (!dicConfigCodeMT)
                {
                    [strReturnValue setString:@"Config Code Table in script is empty."]; 
                    return [NSNumber numberWithBool:NO];
                }
                for(NSString *keyTemp in [dicConfigCodeMT allKeys])
                {
                    if([keyTemp isEqualToString:strConfigCodeKey])
                    {
                        strConfigCodeFromDut	= [NSString stringWithFormat:@"%@",
												   [dicConfigCodeMT objectForKey:strConfigCodeKey]];
                        break;
                    }
                }
                /* Get plant code and config from DUT End*/ 
                /* Compare Start */ 
                if([strPlantCodeFromDut ContainString:strPlantCodeFromSFIS]
				   && [strConfigCodeFromDut ContainString:strConfigCodeFromSFIS])
                    bRet	= YES;
                else
                {
                    bRet	= NO;
                    [strReturnValue setString:[NSString stringWithFormat:
											   @"BCMS from SFIS is %@,Back Camera SN from UNIT is %@, Plant Code from unit is %@, Config Code from unit is %@",
											   szBCMSfromSFIC,		szBCMSSN,
											   strPlantCodeFromDut,	strConfigCodeFromDut]];
                }   
            }
            else
            {
                ATSDebug(@"NVM format error");
                [strReturnValue setString: @"NVM format Error"];
                return [NSNumber numberWithBool:NO];
            }
        }
        else
        {
            ATSDebug(@"NVM format error");
            [strReturnValue setString: @"NVM format Error"];
            return [NSNumber numberWithBool:NO];
        }
    }
    else
    {
        ATSDebug(@"NVM format error");
        [strReturnValue setString: @"NVM format Error"];
        return [NSNumber numberWithBool:NO];
    }
    //return [NSNumber numberWithBool:YES];
    return [NSNumber numberWithBool:bRet];
}


- (BOOL)COMPARE_PLANTANDCONFIG_WITHSFIS:(NSDictionary *)dicContents
						   RETURN_VALUE:(NSMutableString *)strReturnValue
{
    // torres remove plant code check, and review in PVT. 2012 7 23
    // Get info from args
    NSDictionary	*dicConfigCodeMT		= [dicContents objectForKey:@"CONFIGCODEMT"];
    NSString        *strConfigCode			= [dicContents objectForKey:@"CONFIGCODEFROMNVM"];
    NSString        *strCameraSNFromSFIS	= [dicContents objectForKey:@"SFISINFO"];
    if (!strConfigCode)
        return NO;
    BOOL			bConfigCodeCMPRet		= NO;
    NSString		*strConfigCodeFromMT	= [dicConfigCodeMT objectForKey:strConfigCode];
    NSString		*strConfigCodeFromSFIS	= [strCameraSNFromSFIS substringWithRange:
											   NSMakeRange(11, 5)];
    // ***Compare Config Code Start***
    if (nil != strConfigCodeFromMT) 
    {
        NSArray	*arrConfigCodeInfo	= [strConfigCodeFromMT componentsSeparatedByString:@"/"];
        if(strConfigCodeFromMT != nil
		   && strConfigCodeFromSFIS != nil)
		{
            for (int i = 0; i < [arrConfigCodeInfo count]; i++)
                if ([strConfigCodeFromSFIS isEqualToString:[arrConfigCodeInfo objectAtIndex:i]])
                {
                    bConfigCodeCMPRet	= YES; 
                    [strReturnValue setString:[NSString stringWithFormat:
											   @"%@, ConfigCode From DUT is %@",
											   strReturnValue, [arrConfigCodeInfo objectAtIndex:i]]];
                    break;
                }
		}
		else
        {
            [strReturnValue setString:[NSString stringWithFormat:
									   @"Compare fail![ConfigCode from DUT:%@,BCMS from SFIS:%@]",
									   strConfigCodeFromMT, strCameraSNFromSFIS]];
            ATSDebug(@"strConfigCodeFromMT = %@, strConfigCodeFromSFIS = %@",
					 strConfigCodeFromMT, strConfigCodeFromSFIS);
            ATSDebug(@"Compare ConfigCode with SFIS fail");
            bConfigCodeCMPRet	= NO;
        }
    }
    // torres remove plant code check, and review in PVT. 2012 7 23
    // ***Compare Config Code End***
    return bConfigCodeCMPRet;
}

/****************************************************************************************************
 Start 2012.4.23 Add note by Sky_Ge 
 Descripton: Conbine camera SN for QT0 station.
 Param:
 NSMutableString *strReturnValue : Return value
 NSArray *aryContents : the data which need to conbine.
 ****************************************************************************************************/
- (BOOL)COMBINE_CAMERA_SN:(NSArray *)aryContents
			 RETURN_VALUE:(NSString **)strReturnValue
{
    NSScanner		*scan;
    unsigned int	iValue;
    NSString		*szYear;
    NSString		*szWeek;
    NSString		*szDay;
    NSString		*szYearWeekDay;
    NSString		*szFirstSN;
    NSString		*szSecondSN;
	NSString		*szThirdSN;
    NSString		*szCameraSN;
    
    scan	= [NSScanner scannerWithString:[aryContents objectAtIndex:0]];
    [scan scanHexInt:&iValue];
    iValue	&= 0x0f;
    szYear	= [NSString stringWithFormat:@"%d",iValue];
    //Week
    scan	= [NSScanner scannerWithString:[aryContents objectAtIndex:1]];
    [scan scanHexInt:&iValue];
    iValue	&= 0x3f;
    if (iValue <=9)
        szWeek	= [NSString stringWithFormat:@"0%d",iValue];
    else 
        szWeek	= [NSString stringWithFormat:@"%d",iValue];
    //Day
    scan	= [NSScanner scannerWithString:[aryContents objectAtIndex:2]];
    [scan scanHexInt:&iValue];
    iValue	&= 0x0f;
    szDay	= [NSString stringWithFormat:@"%d",iValue];
    
    szYearWeekDay	= [NSString stringWithFormat:@"%@%@%@",
					   szYear, szWeek, szDay];
    ATSDebug(@"szYearWeekDay : %@",szYearWeekDay);
    
    //-----------------------------------
    szFirstSN	= [aryContents objectAtIndex:3];
    szSecondSN	= [aryContents objectAtIndex:4];
    szThirdSN	= [aryContents objectAtIndex:5];
    
    if ([szFirstSN length] == 3)
        szFirstSN	= [NSString stringWithFormat:@"0%@",
					   [szFirstSN substringWithRange:NSMakeRange(2, 1)]];
    else
        szFirstSN	= [szFirstSN substringWithRange:NSMakeRange(2, 2)];
    if ([szSecondSN length] == 3)
        szSecondSN	= [NSString stringWithFormat:@"0%@",
					   [szSecondSN substringWithRange:NSMakeRange(2, 1)]];
    else
        szSecondSN	= [szSecondSN substringWithRange:NSMakeRange(2, 2)]; 
    if ([szThirdSN length] == 3)
        szThirdSN	= [NSString stringWithFormat:@"0%@",
					   [szThirdSN substringWithRange:NSMakeRange(2, 1)]];
    else
        szThirdSN	= [szThirdSN substringWithRange:NSMakeRange(2, 2)]; 
    
    szCameraSN	= [NSString stringWithFormat:@"%@%@%@",
				   szThirdSN, szSecondSN, szFirstSN];
    
    // use function "NumberSystemConvertion" instead of "OriginalString"
    NSMutableDictionary	*dictConvertion		= [[NSMutableDictionary alloc] init];
    NSMutableString		*szMutableCameraSN	= [[NSMutableString alloc]
											   initWithString:szCameraSN];
    [dictConvertion setObject:[NSNumber numberWithInt:16]
					   forKey:@"CHANGE"];
    [dictConvertion setObject:[NSNumber numberWithInt:34]
					   forKey:@"TO"];
    [dictConvertion setObject:[NSNumber numberWithInt:4]
					   forKey:@"PLACE"];
    if (![self NumberSystemConvertion:dictConvertion
						 RETURN_VALUE:szMutableCameraSN])
    {
        ATSDebug(@"Catch wrong value,please check!");
        *strReturnValue	= @"Catch wrong value,please check";
        [szMutableCameraSN release];
        [dictConvertion release];
        return NO;
    }
    
    //----summary
    szCameraSN		= [NSString stringWithFormat:@"%@%@",
					   szYearWeekDay, szMutableCameraSN];
    ATSDebug(@"CameraSN :==> %@",szCameraSN);
    *strReturnValue	= [NSString stringWithString:szCameraSN];
    [dictConvertion release];
    [szMutableCameraSN release];
    return YES;
}

/****************************************************************************************************
 Start 2012.4.23 Add note by Sky_Ge 
 Descripton: check the board id , change the DUT response "0x0A" or "0x0C/E" to "P105" or "P106/P107".
 Param:
 NSMutableString *strReturnValue : Board id about DUT and return value.
 NSDictionary *dicContents : setting in script , it is a mapping table about board id.
 ****************************************************************************************************/
-(NSNumber*)JUDGE_BBVERSION:(NSDictionary*)dicContents
			   RETURN_VALUE:(NSMutableString*)strReturnValue
{
    NSString	*szBBVERSION	= [dicContents objectForKey:strReturnValue];
    
    if (szBBVERSION == nil)
	{
        ATSDebug(@"Get the wrong board id!");
        return [NSNumber numberWithBool:NO];
    }
    
    [m_dicMemoryValues setObject:szBBVERSION
						  forKey:@"BBVERSION"];
    [strReturnValue setString:szBBVERSION];
    return [NSNumber numberWithBool:YES];
}

/****************************************************************************************************
 Start 2012.4.23 Add note by Sky_Ge 
 Descripton: calulate the color checksum
 Param:
 NSMutableString *strReturnValue : the data need to calulate and return value.
 NSDictionary *dicContents : nothing
 ****************************************************************************************************/
//added by lucy 11.2.18
-(NSNumber*)CaculateColorCheckSum:(NSDictionary*)dicContents
					 RETURN_VALUE:(NSMutableString*)strReturnValue
{
    int				sum			= 0;
    NSScanner		*scanerData;
    unsigned int	iValue;
    int				checksum	=0;
    if (NSNotFound == [strReturnValue rangeOfString:@" "].location)
    {
        ATSDebug(@"Invaild value!");
        return [NSNumber numberWithBool:NO];
    }
    NSArray	*arrData	=[strReturnValue componentsSeparatedByString:@" "];
    for (int i = 0; i< [arrData count];i++)
    {
        scanerData	= [NSScanner scannerWithString:[arrData objectAtIndex:i]];
       // [scanerData scanHexInt:&iValue];
        if ([scanerData scanHexInt:&iValue] && [scanerData isAtEnd])
            sum	+= iValue;
    }

    checksum	= 256 - sum & 0x0ff;
    ATSDebug(@"check sum is %i", checksum);
    [strReturnValue setString:[NSString stringWithFormat:@"%i", checksum]];
    return [NSNumber numberWithBool:YES];
}

/****************************************************************************************************
 Start 2012.4.23 Add note by Sky_Ge 
 Descripton: replace the "\n" and "0x" to "", and add it to array.
 Param:
 NSMutableString *strReturnValue : the data need to deal with.
 ****************************************************************************************************/
- (NSArray *)DealWithNVMData:(NSString*)returnValue
{
    returnValue	= [returnValue stringByReplacingOccurrencesOfString:@"\n"
														 withString:@"\r"];
    returnValue	= [returnValue stringByReplacingOccurrencesOfString:@"\r\r"
                                                         withString:@"\r"];
	NSArray			*arrCell	= [returnValue componentsSeparatedByString:@"\r"];

	NSMutableArray	*aryTemp	= [[NSMutableArray alloc] init];
	for (NSString * strCell in arrCell)
	{
		NSRange	range	= [strCell rangeOfString:@" : "];
		if (NSNotFound != range.location
			&& range.length > 0
			&& (range.location + range.length) <= [strCell length])
		{
			NSString		*strTemp	=[strCell substringFromIndex:(range.location
																	  + range.length)];
			NSArray			*arrayUnit	= [strTemp componentsSeparatedByString:@" "];
            NSMutableArray	*arrBits	= [[NSMutableArray alloc] initWithArray:arrayUnit];
            [arrBits removeLastObject];
            for (int iIndex = 0; iIndex < [arrBits count]; iIndex ++)
			{    
                NSString	*szValue	= (([[arrBits objectAtIndex:iIndex] length] == 4)
										   ? [[arrBits objectAtIndex:iIndex]
											  stringByReplacingOccurrencesOfString:@"0x"
											  withString:@""]
										   : [[arrBits objectAtIndex:iIndex]
											  stringByReplacingOccurrencesOfString:@"x"
											  withString:@""]);
                if ([szValue length] <2)
                    szValue	=[NSString stringWithFormat:@"0%@",szValue];
				[aryTemp addObject:szValue];
			}
            [arrBits release];
		}
	}
    NSArray	*aryFinal	= [NSArray arrayWithArray:aryTemp];
    [aryTemp release];
    return aryFinal;
}

/****************************************************************************************************
 Start 2012.4.23 Add note by Sky_Ge 
 Descripton: Get camera NVM data about QT0 station.and cut the value which you need.
 Param:
 NSMutableString *strReturnValue : the data need to calulate and return value.
 NSDictionary *dicContents : setting in script file, para which need in this function.
 ****************************************************************************************************/
-(NSNumber*)DO_CAMERA_DATA:(NSDictionary*)dicContents
			  RETURN_VALUE:(NSMutableString*)strReturnValue
{
    NSString	*szValue;
    NSArray		*arrData;
    NSRange		rangeFrontStart;
    NSRange		rangeFrontEnd;
    NSRange		rangeBackStart;
    NSRange		rangeBackEnd;
    int	Ibegin	= [[dicContents objectForKey:@"BeginIndex"]
				   intValue];
    int	iEnd	= [[dicContents objectForKey:@"EndIndex"]
				   intValue];
    NSString	*szKey			= [dicContents objectForKey:@"KEY"];
    NSString	*szSourceValue	= [m_dicMemoryValues objectForKey:@"CAMERA_CONFIG"];
    if ([szKey isEqualToString:@"Front"]) 
    {   
        rangeFrontStart	= [szSourceValue rangeOfString:@"Sensor channel 2 detected :"];
		if (rangeFrontStart.location == NSNotFound
			|| rangeFrontStart.length <=0)
		{
			ATSDebug(@"Front NVM Data Missing!");
			return [NSNumber numberWithBool:NO];
		}
		szValue	= [szSourceValue substringFromIndex:(rangeFrontStart.location
													 + rangeFrontStart.length)];
        NSInteger iNVMData = [[[szValue lowercaseString]subByRegex:@"nvm data(.*?)bytes" name:nil error:nil]integerValue]; //like 1536
        NSString *strHexNVM = [NSString stringWithFormat:@"0x%1lX :",iNVMData];  //like @"0x600 :"
    
		rangeFrontEnd	= [szValue rangeOfString:strHexNVM];
		if (rangeFrontEnd .location == NSNotFound
			|| rangeFrontEnd.length <= 0)
		{
            ATSDebug(@"Front NVM Format Error!");
            return [NSNumber numberWithBool:NO];
		}
		szValue			= [szValue substringToIndex:rangeFrontEnd.location];
		rangeFrontStart	= [szValue rangeOfString:[NSString stringWithFormat:@"NVM Data %ld bytes :",iNVMData]];
		if(rangeFrontStart.location == NSNotFound
		   || rangeFrontStart.length <= 0 )
		{
			ATSDebug(@"Front NVM Format Error!");
			return [NSNumber numberWithBool:NO];
		}
		szValue	= [szValue substringFromIndex:(rangeFrontStart.location
											   + rangeFrontStart.length)];
    }
    else if ([szKey isEqualToString:@"Back"])
    {
        rangeBackStart	= [szSourceValue rangeOfString:@"Sensor channel 0 detected :"];
        if (rangeBackStart.location == NSNotFound
			|| rangeBackStart.length<=0)
        {
            ATSDebug(@"Back NVM Data Missing!");
            return [NSNumber numberWithBool:NO];
        }
        szValue	= [szSourceValue substringFromIndex:(rangeBackStart.location
													 + rangeBackStart.length)];
        NSInteger iNVMData = [[[szValue lowercaseString]subByRegex:@"nvm data(.*?)bytes" name:nil error:nil]integerValue];//like 4096
        NSString *strHexNVM = [NSString stringWithFormat:@"0x%1lX :",iNVMData];  //like @"0x1000 :"
        
        rangeBackEnd	= [szValue rangeOfString:strHexNVM];
        if (rangeBackEnd.location == NSNotFound
			|| rangeBackEnd.length<=0)
        {
            ATSDebug(@"Back NVM Format Error!");
            return [NSNumber numberWithBool:NO];
        }
        [szValue substringToIndex:rangeBackEnd.location];
        rangeBackStart	= [szValue rangeOfString:[NSString stringWithFormat:@"NVM Data %ld bytes :",iNVMData]];
        if(rangeBackStart.location == NSNotFound
		   || rangeBackStart.length <=0 )
        {
            ATSDebug(@"Back NVM Format Error!");
            return [NSNumber numberWithBool:NO];
        }
        szValue	= [szValue substringFromIndex:(rangeBackStart.location
											   + rangeBackStart.length)];
    }
    else
    {
        ATSDebug(@"You must decide to  one sensor!");
        return [NSNumber numberWithBool:NO];
        
    }
	// ATSDebug(@"The szvalue is %@",szValue);
    arrData	= [self DealWithNVMData:szValue];
	if ([arrData count] < iEnd)
	{
		[strReturnValue setString:@"Fatle error"];
		ATSDebug(@"Can't get enough array count");
		return [NSNumber numberWithBool:NO];
	}
    [strReturnValue setString:@""];
    if ([dicContents objectForKey:@"BeginIndex"] == nil
		&& [dicContents objectForKey:@"EndIndex"] == nil)
    {
        for (int i =0; i < [arrData count] -1; i++)
            [strReturnValue appendString:[NSString stringWithFormat:@"%@ ",
										  [arrData objectAtIndex:i]]];
        [strReturnValue appendString:[arrData objectAtIndex:([arrData count] - 1)]];
        return [NSNumber numberWithBool:YES];
    }
    if ([dicContents objectForKey:@"BeginIndex"] == nil)
    {
        for (int i =0; i <iEnd; i++)
            [strReturnValue appendString:[NSString stringWithFormat:@"%@ ",
										  [arrData objectAtIndex:i]]];
        [strReturnValue appendString:[arrData objectAtIndex:iEnd]];
        return [NSNumber numberWithBool:YES];
    }
    if ([dicContents objectForKey:@"EndIndex"] == nil)
    {
        for (int i =Ibegin; i <[arrData count] -1; i++)
            [strReturnValue appendString:[NSString stringWithFormat:@"%@ ",
										  [arrData objectAtIndex:i]]];
        [strReturnValue appendString:[arrData objectAtIndex:([arrData count] - 1)]];
        return [NSNumber numberWithBool:YES];
    }
    if (iEnd==Ibegin)
    {
        [strReturnValue appendString:[arrData objectAtIndex:Ibegin]];
        ATSDebug(@"The value is %@", strReturnValue);
		return [NSNumber numberWithBool:YES];
    }
    if (Ibegin < iEnd)
    {
        for (int i =Ibegin; i <iEnd; i++)
            [strReturnValue appendString:[NSString stringWithFormat:@"%@ ",
										  [arrData objectAtIndex:i]]];
        [strReturnValue appendString:[arrData objectAtIndex:(iEnd )]];
        return [NSNumber numberWithBool:YES];
    }
    else
    {
        ATSDebug(@"Invaild index,please check it!");
        return [NSNumber numberWithBool:NO];
    }
}

//2012-04-19 add description by Winter
// Used to catch number, and convert the number to the bit you want, then memory the return value.
// Param:
//       NSDictionary    *dicQueryContents        : Settings in script
//       NSMutableString *strReturnValue     : Return value
// Return:
//      Actions result
-(NSNumber*)CATCH_BIT:(NSDictionary *)dicQueryContents
		 RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSDictionary	*dicBit	= [dicQueryContents objectForKey:@"Bit"]; 
    NSString	*szTestName	= [dicBit objectForKey:@"TestName"];
    if (dicBit!=nil)
        [self NumberSystemConvertion:dicBit
						RETURN_VALUE:szReturnValue];
    ATSDebug(@"return value is %@",szReturnValue);
    if (szTestName && [szTestName isNotEqualTo:@""])
    {
        [m_dicMemoryValues setValue:[NSString stringWithString:szReturnValue]
                             forKey:szTestName];
    }
    return [NSNumber numberWithBool:YES];
}

//2012-04-19 add description by Winter
// Used to combine some string values to a string value, for example(A;B;C =====> ABC)
// Param:
//       NSDictionary    *dicQueryContents        : Settings in script
//       NSMutableString *strReturnValue     : Return value
// Return:
//      Actions result
-(NSNumber*)CONBINE_DATA:(NSDictionary *)dicQueryContents
			RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSString	*szValue		= [dicQueryContents objectForKey:@"KEY"];
    NSString	*szFinalValue	= [dicQueryContents objectForKey:@"TestName"];
    NSString	*szSeperateKey	=[dicQueryContents objectForKey:@"SeperateKey"];
    NSArray		*arrData		= [szValue componentsSeparatedByString:@";"];
    [szReturnValue setString:@""];
    if ([arrData count] == 1)
    {
		if (nil != [m_dicMemoryValues objectForKey:[arrData objectAtIndex:0]])
		{
			NSString	*szFirstValue	= [m_dicMemoryValues objectForKey:
										   [arrData objectAtIndex:0]];
			if (szSeperateKey != nil && ![szSeperateKey isEqualTo:@""])
				[szReturnValue appendString:[NSString stringWithFormat:
											 @"%@%@",
											 szSeperateKey, szFirstValue]];
			else
				[szReturnValue appendString:szFirstValue];
		}
		else
		{
			ATSDebug(@"AVERAGE_WITH_KEYS : no value in dicMemoryValues with key");
			return [NSNumber numberWithBool:NO];
		}
    }
    else
        for (int i =0; i< [arrData count]; i++)
        {
            if (nil !=[m_dicMemoryValues objectForKey:[arrData objectAtIndex:i]])
            {    
                NSString	*szValueKey	= [m_dicMemoryValues objectForKey:
										   [arrData objectAtIndex:i]];
                if ([szValueKey ContainString:@"not found!"])
				{
                    [szReturnValue setString: szValueKey];
                    break;
                }
                if (szSeperateKey != nil && ![szSeperateKey isEqualTo:@""])
                {
                    if(i ==[arrData count]-1)
                        [szReturnValue appendString:szValueKey];
                    else
                        [szReturnValue appendString:[NSString stringWithFormat:
													 @"%@%@",
													 szValueKey, szSeperateKey]];
                }
                else
                    [szReturnValue appendString:szValueKey];
            }
            else
            {
                ATSDebug(@"AVERAGE_WITH_KEYS : no value in dicMemoryValues with key[%@]",
						 [arrData objectAtIndex:i]);
                return [NSNumber numberWithBool:NO];
            }
        }
    ATSDebug(@"return value is %@",szReturnValue);
    if (szFinalValue != nil)
    [m_dicMemoryValues setValue:szReturnValue
						 forKey:szFinalValue];
    return [NSNumber numberWithBool:YES];
}

//2012-04-19 add description by Winter
// Used to change test item name by different nand_size. You'll see the changed the name at parametric data and UI.
// Param:
//       NSDictionary    *dicContents        : Settings in script
//       NSMutableString *strReturnValue     : Return value
// Return:
//      Actions result
- (NSNumber *)CHANGE_TESTCASENAME_BY_NANDSIZE:(NSDictionary *)dicContents
								 RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSString	*szCurrentTestItem;
    NSString	*szNandSize	= [m_dicMemoryValues valueForKey:@"nand_size"];
    if (nil == szNandSize) 
    {
        ATSDebug(@"Nand Size error!");
        [szReturnValue setString:@"Nand Size error!"];
        return [NSNumber numberWithBool:NO];
    }
    if ([szNandSize isEqualToString:@"8G"]
		|| [szNandSize isEqualToString:@"16G"]
		|| [szNandSize isEqualToString:@"32G"]
		|| [szNandSize isEqualToString:@"64G"])
        szCurrentTestItem	= [NSString stringWithFormat:
							   @"NAND Size [%@] Check between sysconfig and unit",
							   szNandSize];
    else
    {
        ATSDebug(@"Get the wrong nand size : %@", szNandSize);
        [szReturnValue setString:[NSString stringWithFormat:
								  @"Get the wrong nand size : %@", szNandSize]];
        return [NSNumber numberWithBool:NO];
    }
    [m_dicMemoryValues setObject:szCurrentTestItem
						  forKey:kFZ_UI_SHOWNNAME];
    return [NSNumber numberWithBool:YES];
}

-(NSString*)Mac_Address
{
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    size_t              length;
    unsigned char       macAddress[6];
    struct if_msghdr    *interfaceMsgStruct;
    struct sockaddr_dl  *socketStruct;
    NSString            *errorFlag = NULL;
    
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
    else
    {
        // Get the size of the data available (store in len)
        if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
            errorFlag = @"sysctl mgmtInfoBase failure";
        else
        {
            // Alloc memory based on above call
            if ((msgBuffer = malloc(length)) == NULL)
                errorFlag = @"buffer allocation failure";
            else
            {
                // Get system information, store in buffer
                if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                    errorFlag = @"sysctl msgBuffer failure";
            }
        }
    }
    
    // Befor going any further...
    if (errorFlag != NULL)
    {
        free(msgBuffer);
        NSLog(@"Error: %@", errorFlag);
        return errorFlag;
    }
    
    // Map msgbuffer to interface message structure
    interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
    
    // Map to link-level socket structure
    socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
    
    // Copy link layer address data in socket structure to an array
    memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
    
    // Read from char array into a string object, into traditional Mac address format
    NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                  macAddress[0], macAddress[1], macAddress[2],
                                  macAddress[3], macAddress[4], macAddress[5]];
    NSLog(@"Mac Address: %@", macAddressString);
    
    // Release the buffer memory
    free(msgBuffer);
    
    return macAddressString;
    
    
}

@end




