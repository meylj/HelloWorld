//
//  IADevice_SFIS.m
//  FunnyZone
//
//  Created by Eagle on 10/27/11.
//  Copyright 2011 PEGATRON. All rights reserved.
//

#import "IADevice_SFIS.h"
#import "PuddingPDCA/IPSFCPost.h"

// auto test system(global var)
extern  BOOL    gbIfNeedRemoteCtl;

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
-(NSNumber*)QUERY_SFIS:(NSDictionary*)dicQueryContents RETURN_VALUE:(NSMutableString *)szReturnValue
{   
#if 1
    //judge the parameter if null
    if (nil == dicQueryContents || 0 == [[dicQueryContents allKeys] count]) {
        ATSDebug(@"QUERY_SFIS: => input dictionary error! please check script.");
        return [NSNumber numberWithBool:NO];
    }
	// Default use serial number to query SFIS.
    NSString * strQueryNum = m_szISN;
    NSString *strQuerySN = [dicQueryContents objectForKey:KIADeviceSFISQuerySNKey];
    if (strQuerySN != nil && ![strQuerySN isEqualToString:@""]) {
        strQueryNum = [m_dicMemoryValues objectForKey:strQuerySN];
        strQueryNum = (nil == strQueryNum) ? m_szISN : strQueryNum;
    }
	NSDictionary *dictQueryItems = [dicQueryContents objectForKey:KIADeviceSFISQueryItems];
    
	IPSFCPost * postObj = [[IPSFCPost alloc] init];
    [postObj setDelegate:self];
    NSInteger acpResult;
	NSMutableDictionary * acp_muDictionary = [[NSMutableDictionary alloc] initWithDictionary:dictQueryItems];
    for (int iQueryTime=0 ; iQueryTime<1; iQueryTime++) {
        // query sfc record.
        acpResult = [postObj TrySFCQueryRecord:strQueryNum DataStruct:acp_muDictionary Size:[[acp_muDictionary allKeys] count]];
        if (TEST_SUCCESS == acpResult) break;
        sleep(5);
    }
    NSString *strKeys = [acp_muDictionary description];
    ATSDebug(@"QUERY_SFIS TrySFCQueryRecord : result[%d] all value with keys [%@]",acpResult,strKeys);
    for (NSString *strKey in [acp_muDictionary allKeys]) {
        NSString *strValue = [acp_muDictionary valueForKey:strKey];
        if (nil == strValue || [strValue isEqualToString:@""]) {
            strValue = @"null";
        }else{
            //default when querysn is sn,set the key  added by lucy
            if (nil == strQuerySN || [strQuerySN isEqualToString:@""]){
                [m_dicMemoryValues setObject:strValue forKey:strKey];                    
            }
            // when the querysn is mlb_sn,ban_sn added by lucy
            else{
                [m_dicMemoryValues setObject:strValue forKey:[NSString stringWithFormat:@"%@_%@",strKey,strQuerySN]]; 
            }
        }
		[szReturnValue appendFormat:@"%@=%@;",strKey,strValue];
        ATSDebug(@"QUERY_SFIS: => print query value[%@] with key[%@]",strValue,strKey);
    }
    
    [acp_muDictionary release];
	[postObj release];
	return [NSNumber numberWithBool:(acpResult == 0)];
# else	
    NSNumber *numRet = [NSNumber numberWithBool:YES];
    NSInteger iTimeOut = 5;
    NSString *szURL = [m_dicMemoryValues objectForKey:kPD_GHInfo_SFC_URL];
    NSString *szStationID = [m_dicMemoryValues objectForKey:kPD_GHInfo_STATION_ID];
    NSString *szStationName = [m_dicMemoryValues objectForKey:kPD_GHInfo_STATION_TYPE];
    NSString *szSFCTimeOut = [m_dicMemoryValues objectForKey:kPD_GHInfo_SFC_TIMEOUT];
	NSString *szOtherURLFormat = [dicQueryContents objectForKey:@"URLSuffix"]; // Added by Lorky 2012/03/05 for test result Query
    if (!szURL || !szStationID || !szStationName) {
        [szReturnValue setString:@"May missed json file !"];
        ATSDebug(@"QUERY_SFIS: => %@",szReturnValue);
        return [NSNumber numberWithBool:NO];
    }
    if (szSFCTimeOut && ![szSFCTimeOut isEqualToString:@""]) {
        iTimeOut = [szSFCTimeOut intValue];
    }
    
    // Default use serial number to query SFIS.
    NSString * strQueryNum = m_szISN;
    NSString *strQuerySN = [dicQueryContents objectForKey:KIADeviceSFISQuerySNKey];
    if (strQuerySN != nil && ![strQuerySN isEqualToString:@""]) {
        strQueryNum = [m_dicMemoryValues objectForKey:strQuerySN];
        strQueryNum = (nil == strQueryNum) ? m_szISN : strQueryNum;
    }
    
    //don't sent station id and station name, do as coco's station.
    NSMutableString *strURL_Addr =	[[NSMutableString alloc] initWithFormat:@"%@?command=QUERY_RECORD&sn=%@",szURL,strQueryNum];
	NSDictionary *dictQueryItems = [dicQueryContents objectForKey:KIADeviceSFISQueryItems];
    NSArray *aryQueryKeys = [dictQueryItems allKeys];
    NSInteger iCount = [aryQueryKeys count];
    
	if (szOtherURLFormat != nil)
	{
		[strURL_Addr appendString:szOtherURLFormat];
	}
	else
	{
		for(NSInteger iIndex=0; iIndex<iCount;iIndex++)
		{
			[strURL_Addr appendFormat:@"&p=%@",[aryQueryKeys objectAtIndex:iIndex]];
		}
	}
	
    ATSDebug(@"QUERY_SFIS: => query url : %@",strURL_Addr);
    
    NSHTTPURLResponse   *theResponse;
    NSError		 *errors;
	NSURL * urls = [NSURL URLWithString:strURL_Addr];
	NSMutableURLRequest	*theRequest = [[NSMutableURLRequest alloc] initWithURL:urls];
	[theRequest setHTTPMethod:@"POST"];
	[theRequest setValue:@"text/html;charset=UTF8" forHTTPHeaderField:@"Content-Type"];
	[theRequest setTimeoutInterval:iTimeOut];
	NSData *getData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&theResponse error:&errors];
	[theRequest release];
    [strURL_Addr release];    
    
	// Judge response status
    ATSDebug(@"QUERY_SFIS: => responseStatus : %d",[(NSHTTPURLResponse *)theResponse statusCode]);
	
	if ([(NSHTTPURLResponse *)theResponse statusCode] != 200) 
	{ 
        [szReturnValue setString:@"Response status != 200"];
        ATSDebug(@"QUERY_SFIS: => %@",szReturnValue);
		return [NSNumber numberWithBool:NO];
	}
    NSString	*szResposeDataTemp = [[NSString alloc] initWithData:getData encoding:NSUTF8StringEncoding];
    NSString    *szResposeData = [NSString stringWithFormat:@"%@", szResposeDataTemp];
    [szResposeDataTemp release];
    
    ATSDebug(@"QUERY_SFIS: => %@",szResposeData);
    if(NSNotFound == [szResposeData rangeOfString:@"0 SFC OK"].location || [szResposeData rangeOfString:@"0 SFC OK"].length <=0)
	{
        [szReturnValue setString:[NSString stringWithFormat:@"[%@]",szResposeData]];		 
		NSRunAlertPanel(kFZ_PanelTitle_SFISError, szResposeData, @"OK", nil, nil);
		numRet = [NSNumber numberWithBool:NO];
		//return numRet;
	}
    if (szOtherURLFormat != nil)
	{
		NSString * myStringTemp = [szResposeData SubFrom:@"ts::" include:NO];
		NSString * strStationName = [myStringTemp SubTo:@"::result" include:NO];
		NSString * strResult = [myStringTemp SubFrom:@"::result=" include:NO];
		[m_dicMemoryValues setObject:strResult forKey:strStationName];
		ATSDebug(@"QYERY_SFIS: => memory set value [%@] as key [%@]",strResult,strStationName)
		return [NSNumber numberWithBool:YES];
	}
	
    //Change SFIS Data format 
    if (NSNotFound != [szResposeData rangeOfString:@"PROTO1-DOE"].location || NSNotFound != [szResposeData rangeOfString:@"PROTO1-MINI"].location) 
    {
        szResposeData=[szResposeData stringByReplacingOccurrencesOfString:@"PROTO1-DOE" withString:@"P1-DOE"];
        szResposeData=[szResposeData stringByReplacingOccurrencesOfString:@"PROTO1-MINI" withString:@"P1-MINI"];
    }
    
    //[szReturnValue setString:@""];
    for(NSString *strKey in aryQueryKeys)
    {
        NSString	*strBegin	= [NSString stringWithFormat:@"%@=",strKey];
		NSString	*strEndSymbol = [dictQueryItems objectForKey:strKey];
		NSString    *strEnd		= (strEndSymbol ==nil || [strEndSymbol isEqualToString:@""]) ? @"\n" : strEndSymbol;
        NSRange		range	= [szResposeData rangeOfString:strBegin];
        NSString    *szValue = @"null";
		if((NSNotFound != range.location) && ([szResposeData length]>=(range.location+range.length))&&(range.length>0))
		{
            szValue	= [szResposeData substringFromIndex:range.location + range.length];
            range	= [szValue rangeOfString:strEnd];
            if((NSNotFound != range.location) && (szValue!= nil)&&(range.length>0)&& ((range.length+range.location)<=[szValue length]))
            {
                szValue	= [szValue substringToIndex:range.location];
            }
            else
            {
                if (strEndSymbol != nil && ![strEndSymbol isEqualToString:@""]) 
                {
                    numRet = [NSNumber numberWithBool:NO];
                }
            }
            if (szValue!= nil && ![szValue isEqualToString:@""]) 
            {
                //default when querysn is sn,set the key  added by lucy
                if (nil == strQuerySN || [strQuerySN isEqualToString:@""])
                {
                    [m_dicMemoryValues setObject:szValue forKey:strKey];                    
                }
                // when the querysn is mlb_sn,ban_sn added by lucy
                else
                {
                    [m_dicMemoryValues setObject:szValue forKey:[NSString stringWithFormat:@"%@_%@",strKey,strQuerySN]]; 
                }
            }
            else
            {
                szValue = @"null";
                //numRet = [NSNumber numberWithBool:NO];marked by lucy
            }
		}
        else
        {
            numRet = [NSNumber numberWithBool:NO];
        }
        [szReturnValue appendFormat:@"%@=%@;",strKey,szValue];
    }
    return numRet;
#endif
}
// Catch data with given keys from m_dicMemoryValues
// Param:
//      NSDictionary    *dicQueryContents   : Contains Catch contents
//          area         -> NSString*    : 
//          asku         -> NSString*    : 
//          .....
// Return:
//      Actions result
-(NSNumber*)CATCH_DATA:(NSDictionary*)dicQueryContents RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSNumber *numRet = [NSNumber numberWithBool:YES];
    NSArray *aryFrom = [dicQueryContents allKeys];
    NSInteger iCount = [aryFrom count];
    for (NSInteger i=0; i<iCount; i++) 
    {
        NSString *szFromKey = [aryFrom objectAtIndex:i];
        NSString *szFromStr = [m_dicMemoryValues objectForKey:szFromKey];
        if (szFromStr == nil || [szFromStr isEqualToString:@""]) 
        {
            ATSDebug(@"CATCH_SFCDATA: didn't get %@ from SFC!",szFromKey);
            numRet = [NSNumber numberWithBool:NO];
        }
        else
        {
            NSDictionary *dicCatch = [dicQueryContents objectForKey:szFromKey];
            NSArray *aryCatch = [dicCatch allKeys];
            for(NSString *szKey in aryCatch) 
            {
                NSString    *szValue = szFromStr;
                NSDictionary *dicCondition = [dicCatch objectForKey:szKey];
                NSString *szFrom = [dicCondition objectForKey:@"FROM"];
                NSString *szTo = [dicCondition objectForKey:@"TO"];
                szValue = [self catchFromString:szValue begin:szFrom end:szTo TheRightString:[[dicQueryContents objectForKey:@"RIGHTSTRING"] boolValue]];
                
                if ([szValue isKindOfClass:[NSString class]] && ![szValue isEqualToString:@""]) 
                {
                    [m_dicMemoryValues setObject:szValue forKey:szKey];
                }
                else
                {
                    numRet = [NSNumber numberWithBool:NO];
                }                
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
	
#if 1
	// add by lucky for CSD WIPE-CSD insert sfis.
	NSInteger	iTimeOut        = 5;
	
    NSString	*szURL          = [dicInsertContents objectForKey:@"URL"] ?
	[dicInsertContents objectForKey:@"URL"]:
	[m_dicMemoryValues objectForKey:kPD_GHInfo_SFC_URL];
	
    NSString	*szSFCTimeOut   = [m_dicMemoryValues objectForKey:kPD_GHInfo_SFC_TIMEOUT];
	
    NSString	*szStartTime    = [[NSDate date] descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M:%S"
																   timeZone:nil
																	 locale:nil];
    
    NSString	*szStopTime		= [[NSDate date] descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M:%S"
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
	
	NSDictionary * dictPairs = [dicInsertContents objectForKey:@"InsertItems"];
	ATSDebug(@"insert items -->%@",dictPairs);
	for(NSString *strKey in [dictPairs allKeys])
	{
		NSString	*strValue	= [m_dicMemoryValues objectForKey:[dictPairs objectForKey:strKey]];
		
		if ([strValue isEqualToString:@""])
		{
            continue;
        }
		CFStringRef	strEncode	= CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
																		  (CFStringRef)strValue,
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
        ATSDebug(@"InsertDataToSFC : statusCode = %d, Response Headers = %@",
				 [(NSHTTPURLResponse *)theResponse statusCode],
				 [(NSHTTPURLResponse *)theResponse allHeaderFields]);
        [strReturn setString:@"statusCode != 200"];
        bRet	= NO;
    }
    [theRequest release];
    return [NSNumber numberWithBool:bRet];
	
#else
    NSInteger iTimeOut = 5;
    NSString *szURL = [m_dicMemoryValues objectForKey:kPD_GHInfo_SFC_URL];
    NSString *szStationID = [m_dicMemoryValues objectForKey:kPD_GHInfo_STATION_ID];
    NSString *szStationName = [m_dicMemoryValues objectForKey:kPD_GHInfo_STATION_TYPE];
    NSString *szSFCTimeOut = [m_dicMemoryValues objectForKey:kPD_GHInfo_SFC_TIMEOUT];
    NSString *szProduct = [m_dicMemoryValues objectForKey:kPD_GHInfo_PRODUCT];
    NSString *szMacAddr = [m_dicMemoryValues objectForKey:kPD_GHInfo_MAC];
    NSString *szStartTime = [[m_dicMemoryValues objectForKey:@"Single_Start_Time"] descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M:%S" 
                                      timeZone:nil 
                                        locale:nil];
    NSString *szStopTime = [[NSDate date] descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M:%S" 
                                                               timeZone:nil 
                                                                 locale:nil];
    if (!szURL || !szStationID || !szStationName || !szProduct ||!szMacAddr) {
        [strReturn setString:@"May missed json file !"];
        ATSDebug(@"INSERT_SFIS: => %@",strReturn);
        return [NSNumber numberWithBool:NO];
    }
    if (!szStartTime || !szStopTime) {
        [strReturn setString:@"Can't get start or stop time !"];
        ATSDebug(@"INSERT_SFIS: => %@",strReturn);
        return [NSNumber numberWithBool:NO];
    }
    if ([szSFCTimeOut intValue]>0) {
        iTimeOut = [szSFCTimeOut intValue];
    }

    NSMutableString *szURLPath = [NSMutableString stringWithFormat:@"%@?command=ADD_RECORD&sn=%@&station_id=%@&test_station_name=%@&product=%@&mac_address=%@&start_time=%@&stop_time=%@",szURL,m_szISN,szStationID,szStationName,szProduct,szMacAddr,szStartTime,szStopTime];
    
    NSArray *aryInsert = [dicInsertContents allValues];
    NSInteger iCount = [aryInsert count];
    for (NSInteger i=0; i<iCount; i++) 
    {
        NSString *szInsert = [aryInsert objectAtIndex:i];
        if ([szInsert isEqualToString:@"result"]) 
        {
            if(m_bFinalResult)//pass
            {
                [szURLPath appendString:@"&result=PASS"];
            }
            else
            {	//fail
                [szURLPath appendFormat:@"&result=FAIL&list_of_failing_tests=%@&failure_message=%@",m_szFailLists,m_szErrorDescription];
            }
        }
        else
        {   //must insert into m_dicMemoryValues first
            [szURLPath appendFormat:@"&%@=%@",szInsert,[m_dicMemoryValues objectForKey:szInsert]];
        }
    }
    
    NSHTTPURLResponse	*theResponse;
    NSError				*errors;
    BOOL        bRet = YES;
    ATSDebug(@"%@",szURLPath);
    //replace blank with %20, or add statusCode=0
    [szURLPath replaceOccurrencesOfString:@" " withString:@"%20" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [szURLPath length])];
    NSMutableURLRequest	*theRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:szURLPath]];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setValue:@"text/html;charset=UTF8" forHTTPHeaderField:@"Content-Type"];
    [theRequest setTimeoutInterval:iTimeOut];
    NSData *dataRet = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&theResponse error:&errors];
    if ([(NSHTTPURLResponse *)theResponse statusCode] == 200) 
    {
        NSString	*szResposeData = [[NSString alloc] initWithData:dataRet encoding:NSUTF8StringEncoding];
        ATSDebug(@"InsertDataToSFC : Response = %@",szResposeData); 
        /*NSRange range = [szResposeData rangeOfString:kIADeviceSFISInsertOK];
        if(NSNotFound   == range.location || range.length<=0)
        {
            bRet = NO;
        }*/
        [strReturn setString:szResposeData];
        [szResposeData release];
    }
    else {
        ATSDebug(@"InsertDataToSFC : statusCode = %d, Response Headers = %@",
              [(NSHTTPURLResponse *)theResponse statusCode],
              [(NSHTTPURLResponse *)theResponse allHeaderFields]);
        [strReturn setString:@"statusCode != 200"];
        bRet = NO;
    }
    [theRequest release];
    return [NSNumber numberWithBool:bRet];
#endif
}


#pragma mark ############################## Commands Tool Functions ##############################
// 2011-12-2 added by lucy
// Descripton: judge the nand size spec by the different value from SFC
// Param:
//      NSDictionary    *dicContents        : Settings
//      NSMutableString *strReturnValue     : Return value 

- (NSNumber*)JUDGE_NANDSIZE_SPEC:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue
{  
    NSNumber *numRet = [NSNumber numberWithBool:YES];
    NSString *szNandSizeValue = [m_dicMemoryValues objectForKey:@"Nand_Size"];
    ATSDebug(@"Nand szie from SFC is %@ ",szNandSizeValue);
    id dicForNandSize = [dicContents objectForKey:KFZ_Script_JudgeNandSizeSpec]; 
    
    if (dicForNandSize!=nil) 
    {
        NSString *szSpec = [dicForNandSize objectForKey:szNandSizeValue];
        if(szSpec !=NULL)
        {
            NSDictionary *dicSpec = [NSDictionary dictionaryWithObjectsAndKeys:szSpec , kFZ_Script_JudgeCommonBlack , nil];
            dicSpec = [NSDictionary dictionaryWithObjectsAndKeys:dicSpec , kFZ_Script_JudgeCommonSpec , nil];
            numRet =[self JUDGE_SPEC:dicSpec RETURN_VALUE:strReturnValue];
        }
        else
        {
            [strReturnValue setString:[NSString stringWithFormat:@"The value %@ haven't no spec,Please check it!",szNandSizeValue]];
            numRet = [NSNumber numberWithBool:NO];
        }
    }  
    else
    {
        ATSDebug(@"Haven't no specs") ;
        numRet = [NSNumber numberWithBool:NO];
    }
    return  numRet;
}

// 2011-12-2 added by lucy
// Descripton: First step:  query area by sn
//            Second step: query area by ban_sn
//             Third step:  read area from DFU
//             Fouth step:  compare the third value, if the same ,return yes;else, return no;
// Param:
//      NSDictionary    *dicContents        : Settings
//      NSMutableString *strReturnValue     : Return value 

- (NSNumber*)COMPAREAREA:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue
{
    
	// Maintained table must as fomart @"GSM/UMTS only+US", it should has '+'
	/*NSDictionary * dictMaintainTable = [NSDictionary dictionaryWithObjectsAndKeys:
     @"GSM/UMTS only+US",@"0x00000001 0x00000000 0x00000000",
     @"GSM/UMTS only+EU",@"0x00000001 0x00000000 0x00000001",
     @"GSM/UMTS/C2K+US",@"0x00000001 0x00000001 0x00000000",
     @"GSM/UMTS/C2K+EU",@"0x00000001 0x00000001 0x00000001",nil];	//maintained a table of rsku from SFC in the function*/ //marked by lucy 
    NSDictionary *dictAreaMaintainTable =[NSDictionary dictionaryWithObjectsAndKeys:
                                          @"US",@"0x00000000",
                                          @"EU",@"0x00000001", nil];//added by lucy 11.10.26 for querying area by ban_sn
    
	// get Area from SFIS by sn
    NSString *strArea_SN = [m_dicMemoryValues objectForKey:@"AREA"];
    
    // get Area from MLB
	NSString * strRSKU_MLB = [m_dicMemoryValues objectForKey:@"RSKU"];
    NSArray *array = [strRSKU_MLB componentsSeparatedByString:@" "];
	NSString * strArea_MLB = ([array count] > 3) ? [array	 objectAtIndex:2] : @"Area_MLB";
    ATSDebug(@"The area from UI is %@",strArea_MLB);
    strArea_MLB = [dictAreaMaintainTable objectForKey:strArea_MLB];
    //get Area from SFIS by ban_sn
    NSString *strArea_Ban = [m_dicMemoryValues objectForKey:@"AREA_ban_sn"];
    // compare 
	if ([strArea_SN isEqualToString:strArea_Ban]&&[strArea_Ban isEqualToString:strArea_MLB])
	{   
        [strReturnValue setString:[NSString stringWithFormat:@"Matched(SFIS:%@,UNIT:%@,SFIS(70):%@)",strArea_SN,strArea_MLB,strArea_Ban]];
        
        return [NSNumber numberWithBool:YES];
    }
    
    else
    {
        if(![strArea_Ban isEqualToString:strArea_MLB])
        {
            [strReturnValue setString:[NSString stringWithFormat:@"UnMatched(SFIS(70):%@,UNIT:%@)",strArea_Ban,strArea_MLB]]; 
            return [NSNumber numberWithBool:NO];
        }
        if(![strArea_MLB isEqualToString:strArea_SN])
        {
            [strReturnValue setString:[NSString stringWithFormat:@"UnMatched(SFIS:%@,UNIT:%@)",strArea_SN,strArea_MLB]];
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

- (NSNumber*)COMPAREDATAFORUI:(NSDictionary *)dicContents RETURN_VALUE:(NSMutableString *)strReturnValue
{   
    BOOL bStatus = NO;
    NSString *strUIKey = [dicContents objectForKey:KIADeviceSFISUIItem];
    NSString *strLastKey = [dicContents objectForKey:KIADeviceUILastItem];
    //int length = [[dicContents objectForKey:KIADeviceUILength] intValue];
    //int location = [[dicContents objectForKey:KIADeviceUILocation] intValue];
    
    NSString *szUIValue = [m_dicMemoryValues objectForKey:strUIKey];
	ATSDebug(@"Compare original data : %@",szUIValue);
	ATSDebug(@"Compare SFC data : %@", strReturnValue);
	if (strReturnValue != NULL)
    {
		
        if([[szUIValue uppercaseString] isEqualToString:[strReturnValue uppercaseString]])
        {
            bStatus=YES;
        }
        
		else 
		{
			[strReturnValue setString: [NSString stringWithFormat:@"UnMatched(SFIS:%@,UI:%@)",strReturnValue,szUIValue]];
			bStatus= NO ;
		}
	}
    
    if (!bStatus) 
    { 
        m_bCancelFlag=YES;//added by lucy for if fail it will cancel next item
        szUIValue = @"";     
    }  
    else
    {
        NSInteger iLocation = [[dicContents objectForKey:KIADeviceUILocation] intValue];
        NSInteger iLength = [[dicContents objectForKey:KIADeviceUILength] intValue];
        szUIValue = [self catchFromString:szUIValue location:iLocation length:iLength];
        [m_dicMemoryValues setObject:szUIValue forKey:strLastKey];
    }
    
    return [NSNumber numberWithBool:bStatus];
}//added by lucy end

//2011-12-10 add by Winter
// Calculate DUT config, and memory for key "CFG#"
// Param:
//       NSDictionary    *dicContents        : Settings in script
//       NSMutableString *strReturnValue     : Return value
// Return:
//      Actions result
- (NSNumber *)JUDGE_CONFIG:(NSDictionary *)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue
{
	NSString *szUNIT = @"",*szSBUILD = @"", *szBuild_Event = @"",*szBuild_Matrix_Config = @"";
	NSString * szSFCConfig = [m_dicMemoryValues objectForKey:@"Config"];
	NSArray *arrCfgSFC = [szSFCConfig componentsSeparatedByString:@"/"];
	NSString *szFinalCfg;
    NSDictionary *dicSendCommand = [dicContents objectForKey:@"SEND_COMMAND:"];
    NSDictionary *dicReceiveCommand = [dicContents objectForKey:@"READ_COMMAND:RETURN_VALUE:"];
	//check SFIS Config is NULL or not
	if (szSFCConfig==nil||[[szSFCConfig uppercaseString]isEqualToString:@"NULL" ]) {
		[m_dicMemoryValues setValue:szUNIT forKey:@"UNIT#"];
		[m_dicMemoryValues setValue:szSBUILD forKey:@"S_BUILD"];
		[m_dicMemoryValues setValue:szBuild_Event forKey:@"BUILD_EVENT"];
		[m_dicMemoryValues setValue:szBuild_Matrix_Config forKey:@"BUILD_MATRIX_CONFIG"];
		return [NSNumber numberWithBool:YES];
	}
	else 
    {
		//check the config from MLB
        [self SEND_COMMAND:dicSendCommand];
        [self READ_COMMAND:dicReceiveCommand RETURN_VALUE:strReturnValue];
        
		//check if SFIS less than 5 datas
		if ([arrCfgSFC count] < 5) {
			NSLog(@"Config from SFC format error, Config is %@",szSFCConfig);
			[m_dicMemoryValues setValue:szUNIT forKey:@"UNIT#"];
			[m_dicMemoryValues setValue:szSBUILD forKey:@"S_BUILD"];
			[m_dicMemoryValues setValue:szBuild_Event forKey:@"BUILD_EVENT"];
			[m_dicMemoryValues setValue:szBuild_Matrix_Config forKey:@"BUILD_MATRIX_CONFIG"];
			return [NSNumber numberWithBool:NO];
		}
		//if the MLB never write Config , Diag command will return "Not Found"
		NSRange	rang1 = [strReturnValue rangeOfString:@"Not Found"];
		if ((NSNotFound != rang1.location)&&(rang1.length >0) &&((rang1.location+ rang1.length)<= [strReturnValue length])) {
			szFinalCfg = [NSString stringWithFormat:@"%@/%@///%@/%@",
						  [arrCfgSFC objectAtIndex:0],[arrCfgSFC objectAtIndex:1],
						  [arrCfgSFC objectAtIndex:3],[arrCfgSFC objectAtIndex:4]];
            [m_dicMemoryValues setValue:szFinalCfg forKey:@"CFG#"];
			ATSDebug(@"Did not find Config in MLB");
			szBuild_Event = [NSString stringWithFormat:@"%@%@",[arrCfgSFC objectAtIndex:0],[arrCfgSFC objectAtIndex:1]];
			szSBUILD = [NSString stringWithFormat:@"%@_%@",szBuild_Event,[arrCfgSFC objectAtIndex:4]];
			szBuild_Matrix_Config = [arrCfgSFC objectAtIndex:4];
			szUNIT=[arrCfgSFC objectAtIndex:3];
		}
		else 
        {
            //if the MLB had config
			NSArray *arrCfgDUT = [strReturnValue componentsSeparatedByString:@"/"];
			//to check if Config are wrong from SFIS and DUT
			if ([arrCfgDUT count] < 4 || [arrCfgSFC count] < 5) {
				ATSDebug(@"Config from DUT format error, Config is %@",strReturnValue);
				ATSDebug(@"Config from SFC format error, Config is %@",szSFCConfig);
				[m_dicMemoryValues setValue:szUNIT forKey:@"UNIT#"];
				[m_dicMemoryValues setValue:szSBUILD forKey:@"S_BUILD"];
				[m_dicMemoryValues setValue:szBuild_Event forKey:@"BUILD_EVENT"];
				[m_dicMemoryValues setValue:szBuild_Matrix_Config forKey:@"BUILD_MATRIX_CONFIG"];
				return [NSNumber numberWithBool:NO];
			}
            
            szFinalCfg = [NSString stringWithFormat:@"%@/%@/%@/%@/%@/%@",
                          [arrCfgSFC objectAtIndex:0],[arrCfgSFC objectAtIndex:1],
                          [arrCfgDUT objectAtIndex:2],[arrCfgDUT objectAtIndex:3],
                          [arrCfgSFC objectAtIndex:3],[arrCfgSFC objectAtIndex:4]];
            [m_dicMemoryValues setValue:szFinalCfg forKey:@"CFG#"];
			szUNIT = [arrCfgSFC objectAtIndex:3];
            szBuild_Event = [NSString stringWithFormat:@"%@%@",[arrCfgSFC objectAtIndex:0],[arrCfgSFC objectAtIndex:1]];
            szSBUILD = [NSString stringWithFormat:@"%@_%@",szBuild_Event,[arrCfgSFC objectAtIndex:4]];
            szBuild_Matrix_Config = [arrCfgSFC objectAtIndex:4];
			
		}
        
		[m_dicMemoryValues setValue:szUNIT forKey:@"UNIT#"];
		[m_dicMemoryValues setValue:szSBUILD forKey:@"S_BUILD"];
		[m_dicMemoryValues setValue:szBuild_Event forKey:@"BUILD_EVENT"];
		[m_dicMemoryValues setValue:szBuild_Matrix_Config forKey:@"BUILD_MATRIX_CONFIG"];
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

-(NSNumber *) COMBINE_CONFIG_By_UI:(NSDictionary *)dicContents RETURN_VALUE:(NSMutableString *)strReturnValue
{  
    //  sample : P105/PROTO0/P-PDFC-03/0002/
    NSString *szScanConfig = [m_dicMemoryValues valueForKey:@"CONFIG"];
    NSString *szUNIT = @"";
    NSString *szSBUILD = @"";
    NSString *szBUILD_MATRIX_CONFIG = @"";
    NSString *szBUILD_EVENT = @"";
    NSDictionary *dicSendCommand = [dicContents objectForKey:@"SEND_COMMAND:"];
    NSDictionary *dicReceiveCommand = [dicContents objectForKey:@"READ_COMMAND:RETURN_VALUE:"];
    NSString *szFinalCfg ,*szMidCfg;
    
    NSArray *arrScanCfg = [szScanConfig componentsSeparatedByString:@"/"];
    if ([arrScanCfg count]<5)
    {
        [strReturnValue setString:@"The format of config from scanner is error,please check it!"];
        return [NSNumber numberWithBool:NO];
    }
    
     //send the command to the DFU   
    [self SEND_COMMAND:dicSendCommand];
    [self READ_COMMAND:dicReceiveCommand RETURN_VALUE:strReturnValue];
    
    //if the MLB never write Config , Diag command will return "Not Found"
    NSRange	rang1 = [strReturnValue rangeOfString:@"Not Found"];
    NSArray *arrMlbConfig =[strReturnValue componentsSeparatedByString:@"/"];
    
    if ((NSNotFound != rang1.location)&&(rang1.length >0) &&((rang1.location+ rang1.length)<= [strReturnValue length]))
    {
        //  0002   P-PDFC-03
        szFinalCfg  = [NSString stringWithFormat:@"*/*/*/*/%@/%@",[arrScanCfg objectAtIndex:3],[arrScanCfg objectAtIndex:2]];
        [m_dicMemoryValues setValue:szFinalCfg forKey:@"CFG#"];
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
        szMidCfg = [NSString stringWithFormat:@"%@/%@/%@/%@",[arrMlbConfig objectAtIndex:0],[arrMlbConfig objectAtIndex:1]
                           ,[arrMlbConfig objectAtIndex:2],[arrMlbConfig objectAtIndex:3]];
        }
            
        szFinalCfg = [NSString stringWithFormat:@"%@/%@/%@",szMidCfg,[arrScanCfg objectAtIndex:3],[arrScanCfg objectAtIndex:2]];
        [m_dicMemoryValues setValue:szFinalCfg forKey:@"CFG#"];
    }
    szUNIT = [arrScanCfg objectAtIndex:3];
    szBUILD_MATRIX_CONFIG =[arrScanCfg objectAtIndex:2];
    // P105-PROTO0
    szBUILD_EVENT = [NSString stringWithFormat:@"%@-%@",[arrScanCfg objectAtIndex:0],[arrScanCfg objectAtIndex:1]];
    //P105-PROTO0_P-PDFC-03
    szSBUILD = [NSString stringWithFormat:@"%@_%@",szBUILD_EVENT,szBUILD_MATRIX_CONFIG];
    [m_dicMemoryValues setValue:szUNIT forKey:@"UNIT#"];
    [m_dicMemoryValues setValue:szSBUILD forKey:@"S_BUILD"];
    [m_dicMemoryValues setValue:szBUILD_EVENT forKey:@"BUILD_EVENT"];
    [m_dicMemoryValues setValue:szBUILD_MATRIX_CONFIG forKey:@"BUILD_MATRIX_CONFIG"];
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

-(NSNumber*)COMBINE_CONFIG:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue
{
    // auto test system (query key changed)
    NSString *szUNITKey = [dicContents objectForKey:@"sbuild_unit"];
    NSString *szUNIT = szUNITKey==nil?[m_dicMemoryValues objectForKey:@"sbuild_unit"]:[m_dicMemoryValues objectForKey:szUNITKey];
    NSString *szSBUILDKey = [dicContents objectForKey:@"sbuild"];
    NSString *szSBUILD = szSBUILDKey==nil?[m_dicMemoryValues objectForKey:@"sbuild"]:[m_dicMemoryValues objectForKey:szSBUILDKey];
    NSArray  *arrSBUILD = [dicContents objectForKey:@"SBUILD"];
    NSString *szBUILD_MATRIX_CONFIG = @"";
    NSString *szBUILD_EVENT = @"";
    NSDictionary *dicSendCommand = [dicContents objectForKey:@"SEND_COMMAND:"];
    NSDictionary *dicReceiveCommand = [dicContents objectForKey:@"READ_COMMAND:RETURN_VALUE:"];
    NSString *szFinalCfg,*szMidCfg;
    //P106/PROTO0-MINI/P-SOP-02-6/0008/
    //
    
    /*if(szUNIT == NULL && szSBUILD == NULL)
    {
        ATSDebug(@"No config in SFIS, just return yes!");
        szUNIT = @"";
        szSBUILD = @"";
        [m_dicMemoryValues setValue:szUNIT forKey:@"UNIT#"];
        [m_dicMemoryValues setValue:szSBUILD forKey:@"S_BUILD"];
        [m_dicMemoryValues setValue:szBUILD_EVENT forKey:@"BUILD_EVENT"];
        [m_dicMemoryValues setValue:szBUILD_MATRIX_CONFIG forKey:@"BUILD_MATRIX_CONFIG"];
        return [NSNumber numberWithBool:YES];
    }*/
    
    // when sbuild == null 
    if(szSBUILD == NULL || [szSBUILD isEqualToString:@"null"] || [szSBUILD isEqualToString:@""])
    {
        ATSDebug(@"COMBINE_CONFIG : No config in SFIS, just return NO!");
        m_bCancelFlag = YES;
        [strReturnValue setString:@"null"];
        return [NSNumber numberWithBool:NO];
    }
    //add for no config --20140324
    for (NSString *temp in arrSBUILD) {
        if ([[szSBUILD uppercaseString] isEqualToString:temp])
        {
            ATSDebug(@"COMBINE_CONFIG : Sbuild from SFC");
            m_bCancelFlag = YES;
            [strReturnValue setString:szSBUILD];
            return [NSNumber numberWithBool:YES];
        }
    }
    
    [self SEND_COMMAND:dicSendCommand];
    [self READ_COMMAND:dicReceiveCommand RETURN_VALUE:strReturnValue];
    NSArray *arrMlbConfig =[strReturnValue componentsSeparatedByString:@"/"];
    NSArray *aryBuild = [szSBUILD componentsSeparatedByString:@"_"];

    if ([aryBuild count] < 2)
    {
        ATSDebug(@"sbuild from SFIS = %@", szSBUILD);
        ATSDebug(@"sbuild from SFIS format error!");
        return [NSNumber numberWithBool:NO];
    }
    else
    {
        szBUILD_MATRIX_CONFIG = [aryBuild objectAtIndex:1];
        szBUILD_EVENT = [aryBuild objectAtIndex:0];
    }
    
    //if the MLB never write Config , Diag command will return "Not Found"
    NSRange	rang1 = [strReturnValue rangeOfString:@"Not Found"];
    if ((NSNotFound != rang1.location)&&(rang1.length >0) &&((rang1.location+ rang1.length)<= [strReturnValue length]))
    {
        // N94P/EVT///PG01/0064
        ATSDebug(@"Not find config in MLB!");
        
        szFinalCfg  = [NSString stringWithFormat:@"////%@/%@",szUNIT,szBUILD_MATRIX_CONFIG];
        [m_dicMemoryValues setValue:szFinalCfg forKey:@"CFG#"];      
    }
    else
    {
        //if the MLB has config
        if ([arrMlbConfig count] < 4)
        {
            ATSDebug(@"The format of config from DFU is error,please check it!");
            return [NSNumber numberWithBool:NO];
        }
        else
        { 
            szMidCfg = [NSString stringWithFormat:@"%@/%@/%@/%@",[arrMlbConfig objectAtIndex:0],[arrMlbConfig objectAtIndex:1]
                        ,[arrMlbConfig objectAtIndex:2],[arrMlbConfig objectAtIndex:3]];
        }

      szFinalCfg = [NSString stringWithFormat:@"%@/%@/%@",szMidCfg,szUNIT,szBUILD_MATRIX_CONFIG];
               [m_dicMemoryValues setValue:szFinalCfg forKey:@"CFG#"];
    }
    
    [m_dicMemoryValues setValue:szUNIT forKey:@"UNIT#"];
    [m_dicMemoryValues setValue:szSBUILD forKey:@"S_BUILD"];
    [m_dicMemoryValues setValue:szBUILD_EVENT forKey:@"BUILD_EVENT"];
    [m_dicMemoryValues setValue:szBUILD_MATRIX_CONFIG forKey:@"BUILD_MATRIX_CONFIG"];
    [strReturnValue setString:szFinalCfg];
    return [NSNumber numberWithBool:YES];
}
//2011-12-10 add by Winter
// Calculate camera sn from strReturnValue, and compare it with SFIS.
// Param:
//       NSDictionary    *dicContents        : Settings in script
//       NSMutableString *strReturnValue     : Return value
// Return:
//      Actions result
-(NSNumber*)CHECK_CAMERA_SN:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue
{
    NSString        *szKeyValue = [dicContents valueForKey:kFZ_Script_MemoryKey];
    
    //Add Plant Code & Config Code Mapping Table, 5.15.12
    NSDictionary    *dicPlantCodeMT = [dicContents objectForKey:@"PLANTCODE"];
    NSDictionary    *dicConfigCodeMT = [dicContents objectForKey:@"CONFIGCODE"];
    //Add End, 5.15.12
    
    //Add for Plant code and config code 1/17/13
    NSString        *szPlantCode;
    NSRange         rangeStartPlant;
    NSRange         rangeEndPlant;
    //Add End 1/17/13
    NSRange         rangeStartCMS;
    NSRange         rangeEndCMS;
    NSString        *rangeCatchValue;
    NSString        *szFCMSSN;
    NSString        *szBCMSSN;
    BOOL            bCombineResult;
    NSString        *szFCMSfromSFIC = [m_dicMemoryValues valueForKey:@"front_nvm_barcode"];
    NSString        *szBCMSfromSFIC = [m_dicMemoryValues valueForKey:@"back_nvm_barcode"];
    
    //Add ret value , default NO
    BOOL            bRet = NO;
    
    if ([szKeyValue isEqualToString:@"FCMS"]) 
    {
        if ([strReturnValue ContainString:@"Sensor channel 1 detected :"]) 
        {
            //catch the value for calculate front camera year,work week,day,sequence number.
            rangeCatchValue = [strReturnValue SubFrom:@"Sensor channel 1 detected :" include:NO];
            if ([rangeCatchValue ContainString:@"NVM Data 1024 bytes :"]) 
            {
                rangeCatchValue = [rangeCatchValue SubFrom:@"NVM Data 1024 bytes :" include:NO];
                rangeStartCMS = [rangeCatchValue rangeOfString:@"0x10 : "];
                rangeEndCMS = [rangeCatchValue rangeOfString:@"0x18 : "];
                
                if (NSNotFound == rangeStartCMS.location || NSNotFound == rangeEndCMS.location|| rangeStartCMS.length ==0 || rangeEndCMS.length ==0 || (rangeStartCMS.location+ rangeStartCMS.length) >[rangeCatchValue length]|| (rangeEndCMS.location +rangeEndCMS.length) > [rangeCatchValue length])
                {
                    ATSDebug(@"NVM format error");
                    [strReturnValue setString: @"NVM format Error"];
                    return [NSNumber numberWithBool:NO];
                }
                
                //get the string among 0x10:......0x18
                szFCMSSN = [rangeCatchValue substringToIndex:rangeEndCMS.location];
                szFCMSSN = [szFCMSSN substringFromIndex:rangeStartCMS.location+rangeStartCMS.length];
                
                NSArray *aryFCMSSN = [szFCMSSN componentsSeparatedByString:@" "];
                NSMutableArray *aryFcmSn = [[NSMutableArray alloc] initWithArray:aryFCMSSN];
                [aryFcmSn addObject:szKeyValue];
                
                //Compare Date Code of Manufacture at Supplier and Sequence Number
                if ([aryFCMSSN count] >= 6)
                {
                    bCombineResult = [self COMBINE_CAMERA_SN:aryFcmSn RETURN_VALUE:&szFCMSSN];
                    [aryFcmSn release];
                    //----compare with SFIS
                    if ([szFCMSfromSFIC length] >= 17) 
                    {
                        //compare camera sn with DUT and SFC
                        if (bCombineResult && [[szFCMSfromSFIC substringWithRange:NSMakeRange(3, 8)] isEqualToString:szFCMSSN])
                        {
                            [strReturnValue setString:[NSString stringWithFormat:@"FCMSSN from DUT:%@,FCMS from SFIS:%@",szFCMSSN,szFCMSfromSFIC]];
                            //return [NSNumber numberWithBool:YES];
                        }
                        else
                        {
                            [strReturnValue setString: [NSString stringWithFormat:@"Compare fail![FCMSSN from DUT:%@,FCMS from SFIS:%@]",szFCMSSN,szFCMSfromSFIC]];
                            ATSDebug(@"Check Front Camera SN fail!");
                            return [NSNumber numberWithBool:NO];
                        }
                    }
                    else
                    {
                        [strReturnValue setString: [NSString stringWithFormat:@"FCMS from SFIS Format Error:%@",szFCMSfromSFIC]];
                        ATSDebug(@"FCMS from SFIS Format Error : FCMS length less than 17");
                        return [NSNumber numberWithBool:NO];
                    }
                }
                else
                {
                    ATSDebug(@"NVM format error");
                    [strReturnValue setString: @"NVM format Error"];
                    [aryFcmSn release];
                    return [NSNumber numberWithBool:NO];
                }
                //Add for Plant code 1/17/13
                //catch the value for calculate plant code and config code.
                rangeStartPlant = [rangeCatchValue rangeOfString:@"0x0 : "];
                rangeEndPlant   = [rangeCatchValue rangeOfString:@"0x8 : "];
                if(NSNotFound == rangeStartPlant.location || NSNotFound == rangeEndPlant.location || rangeStartPlant.length == 0 || rangeEndPlant.length == 0 || (rangeStartPlant.location + rangeStartPlant.length) > [rangeCatchValue length] || (rangeEndPlant.location + rangeEndPlant.length) > [rangeCatchValue length])
                {
                    ATSDebug(@"NVM format error");
                    [strReturnValue setString: @"NVM format Error"];
                    return [NSNumber numberWithBool:NO];
                }
                szPlantCode = [rangeCatchValue substringToIndex:rangeEndPlant.location];
                szPlantCode = [rangeCatchValue substringFromIndex:(rangeStartPlant.location + rangeStartPlant.length)];
                NSArray *aryPlant = [szPlantCode componentsSeparatedByString:@" "];
                
                /* Get plant code and config from DUT Start*/
                // Deal with the plant code from NVM
                
//                NSString    *strPlantCode = [aryPlant objectAtIndex:2];
//                NSScanner   *scanner = [NSScanner scannerWithString:strPlantCode];
//                unsigned    int     iValue = 0;
//                [scanner scanHexInt:&iValue];
//                iValue &= 0xff;
//                iValue >>= 4;
//                NSString    *strPlantCodeKey = [NSString stringWithFormat:@"0x%X",iValue];
                // Deal with the config code's key from NVM
//                rangeStartCMS = [rangeCatchValue rangeOfString:@"0x10 : "];
//                rangeEndCMS = [rangeCatchValue rangeOfString:@"0x18 : "];
//                if (NSNotFound == rangeStartCMS.location || NSNotFound == rangeEndCMS.location|| rangeStartCMS.length ==0 || rangeEndCMS.length ==0 || (rangeStartCMS.location+ rangeStartCMS.length) >[rangeCatchValue length]|| (rangeEndCMS.location +rangeEndCMS.length) > [rangeCatchValue length])
//                {
//                    ATSDebug(@"NVM format error");
//                    [strReturnValue setString: @"NVM format Error"];
//                    return [NSNumber numberWithBool:NO];
//                }
//                NSString    *szNVMPart = [rangeCatchValue substringToIndex:rangeEndCMS.location];
//                szNVMPart = [szNVMPart substringFromIndex:rangeStartCMS.location+rangeStartCMS.length];
//                NSArray *arrNVMPart = [szNVMPart componentsSeparatedByString:@" "];
                NSString    *strPlantCodeKey = [aryPlant objectAtIndex:2];
				ATSDebug(@"Calculated Plant Code key from DUT:==>%@",strPlantCodeKey);
                NSScanner   *scanner = [NSScanner scannerWithString:strPlantCodeKey];
                unsigned    int iValue = 0;
                [scanner scanHexInt:&iValue];
                iValue &= 0xf0;
                iValue >>= 4;
                NSString    *strConfigCodeKey = [NSString stringWithFormat:@"0x%X",iValue];
                NSString    *strRConfigCode = [aryFCMSSN objectAtIndex:1];
				ATSDebug(@"Calculated Config Code key from DUT:==>EEEE %@",strConfigCodeKey);
                strRConfigCode = [strRConfigCode stringByReplacingOccurrencesOfString:@"0x" withString:@""];
                NSMutableDictionary *dicConvertion = [[NSMutableDictionary alloc] init];
                [dicConvertion setObject:[NSNumber numberWithInt:16] forKey:@"CHANGE"];
                [dicConvertion setObject:[NSNumber numberWithInt:10] forKey:@"TO"];
                [dicConvertion setObject:[NSNumber numberWithInt:1] forKey:@"PLACE"];
                NSMutableString *strRConfig = [[NSMutableString alloc] initWithString:strRConfigCode];
                if(![self NumberSystemConvertion:dicConvertion RETURN_VALUE:strRConfig])
                {
                    ATSDebug(@"Catch wrong value,please check!");
                    [strRConfig release];
                    [dicConvertion release];
                    return NO;
                }
				ATSDebug(@"Calculated Config Code from DUT:==>R %@",strRConfig);
                //[strRConfig release];
                [dicConvertion release];
                /* Get plant code and config's keys from DUT End*/
                
                /* Get plant code and config from SFIS Start*/
                // Get the plant code
                NSString    *strPlantCodeFromSFIS = [szFCMSfromSFIC substringWithRange:NSMakeRange(0, 3)];
				ATSDebug(@"get Plant Code From SFIS :==> %@",strPlantCodeFromSFIS);
                // Get the config code
                NSString    *strConfigCodeFromSFIS = [szFCMSfromSFIC substringWithRange:NSMakeRange(11, 5)];
                ATSDebug(@"get Config Code From SFIS :==> %@",strConfigCodeFromSFIS);
				
                /* Get plant code and config from DUT Start*/ 
                NSString    *strPlantCodeFromDut = @"NULL",   *strConfigCodeFromDut = @"NULL";
                if (!dicPlantCodeMT)
                {
                    [strReturnValue setString:@"Plant Code Table in script is empty."];
                    return [NSNumber numberWithBool:NO];
                }
                for(NSString    *keyTemp in [dicPlantCodeMT allKeys])
                {
                    if ([keyTemp isEqualToString:strPlantCodeKey])
                    {
                        strPlantCodeFromDut = [NSString stringWithFormat:@"%@",[dicPlantCodeMT objectForKey:strPlantCodeKey]];
                        break;
                    }
                }
                if (!dicConfigCodeMT)
                {
                    [strReturnValue setString:@"Config Code Table in script is empty."]; 
                    return [NSNumber numberWithBool:NO];
                }
                for(NSString    *keyTemp in [dicConfigCodeMT allKeys])
                {
                    if([keyTemp isEqualToString:strConfigCodeKey])
                    {
//                        strConfigCodeFromDut = [NSString stringWithFormat:@"%@%@",[dicConfigCodeMT objectForKey:strConfigCodeKey],strRConfig];
                        // Modified For Multi Config
                        NSString *szTemp = [dicConfigCodeMT objectForKey:strConfigCodeKey];
                        NSArray *arrTemp = [szTemp componentsSeparatedByString:@"/"];
                        NSMutableArray *arrToBeCombined = [[NSMutableArray alloc] init];
                        for (int i=0; i<[arrTemp count]; i++)
                        {
                            NSString *szAConfig = [arrTemp objectAtIndex:i];
                            if ([szAConfig isEqualToString:@""] || szAConfig == nil)
                            {
                                continue;
                            }
                            NSString *szAFullConfig = [NSString stringWithFormat:@"%@%@", szAConfig, strRConfig];
                            [arrToBeCombined addObject:szAFullConfig];
                        }
                        strConfigCodeFromDut = [arrToBeCombined componentsJoinedByString:@"/"];
                        [arrToBeCombined release];
                        break;
                    }
                }
                [strRConfig release];
                /* Get plant code and config from DUT End*/ 
                /* Compare Start */ 
                if([strPlantCodeFromDut ContainString:strPlantCodeFromSFIS] && [strConfigCodeFromDut ContainString:strConfigCodeFromSFIS])
                {
                    bRet = YES;
                }
                else
                {
                    bRet = NO;
                    [strReturnValue setString:[NSString stringWithFormat:@"FCMS from SFIS is %@,Front Camera SN from UNIT is %@, %@, %@",szFCMSfromSFIC,szFCMSSN,[strPlantCodeFromDut isEqualToString:@"NULL"]?[NSString stringWithFormat:@"Plant Code %@ from unit is not in the Mapping table", strPlantCodeKey]:[NSString stringWithFormat:@"Plant Code from unit is %@",strPlantCodeFromDut],[strConfigCodeFromDut isEqualToString:@"NULL"]?[NSString stringWithFormat:@"Config Code %@ from unit is not in the Mapping table",strConfigCodeKey]:[NSString stringWithFormat:@"Config Code from unit is %@",strConfigCodeFromDut]]];
					ATSDebug(@"After Compared,the result is %@",strReturnValue);
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
        //judge the camera config format if OK 
        if ([strReturnValue ContainString:@"Sensor channel 0 detected :"]) 
        {
            rangeCatchValue = [strReturnValue SubFrom:@"Sensor channel 0 detected :" include:NO];
            if ([rangeCatchValue ContainString:@"NVM Data 768 bytes :"])
            {
                //catch the value for calculate back camera year,work week,day,sequence number.
                rangeCatchValue = [rangeCatchValue SubFrom:@"NVM Data 768 bytes :" include:NO];
                rangeStartCMS = [rangeCatchValue rangeOfString:@"0x10 : "];
                rangeEndCMS = [rangeCatchValue rangeOfString:@"0x18 : "];
                if (NSNotFound == rangeStartCMS.location || NSNotFound == rangeEndCMS.location||rangeStartCMS.length ==0 || rangeEndCMS.length ==0 || (rangeStartCMS.location+ rangeStartCMS.length) >[rangeCatchValue length]|| (rangeEndCMS.location +rangeEndCMS.length) > [rangeCatchValue length])
                {
                    ATSDebug(@"NVM format error");
                    [strReturnValue setString: @"NVM format Error"];
                    return [NSNumber numberWithBool:NO];
                }
                
                szBCMSSN = [rangeCatchValue substringToIndex:rangeEndCMS.location];
                szBCMSSN = [szBCMSSN substringFromIndex:rangeStartCMS.location+rangeStartCMS.length];
                
                NSArray *aryBCMSSN = [szBCMSSN componentsSeparatedByString:@" "];
                
                if ([aryBCMSSN count] >= 6)
                {
                    NSMutableArray *aryMutableBCMS = [[NSMutableArray alloc] init];
                    [aryMutableBCMS addObject:[aryBCMSSN objectAtIndex:2]];
                    [aryMutableBCMS addObject:[aryBCMSSN objectAtIndex:3]];
                    [aryMutableBCMS addObject:[aryBCMSSN objectAtIndex:4]];
                    [aryMutableBCMS addObject:[aryBCMSSN objectAtIndex:5]];
                    [aryMutableBCMS addObject:[aryBCMSSN objectAtIndex:6]];
                    [aryMutableBCMS addObject:[aryBCMSSN objectAtIndex:7]];
                    [aryMutableBCMS addObject:szKeyValue];
                    
                    bCombineResult = [self COMBINE_CAMERA_SN:aryMutableBCMS RETURN_VALUE:&szBCMSSN];
                    [aryMutableBCMS release];
                    
                    //----compare with SFIS,judge the camera sn length if OK
                    if ([szBCMSfromSFIC length] >= 17) 
                    {
                        //compare camera sn with DUT and SFC
                        if (bCombineResult && [[szBCMSfromSFIC substringWithRange:NSMakeRange(3, 8)] isEqualToString:szBCMSSN])
                        {
                            [strReturnValue setString:[NSString stringWithFormat:@"BCMSSN from DUT:%@,BCMS from SFIS:%@",szBCMSSN,szBCMSfromSFIC]];
                            //return [NSNumber numberWithBool:YES];
                        }
                        else
                        {
                            [strReturnValue setString: [NSString stringWithFormat:@"Compare fail![BCMSSN from DUT:%@,BCMS from SFIS:%@]",szBCMSSN,szBCMSfromSFIC]];
                            ATSDebug(@"Check Back Camera SN fail!");
                            return [NSNumber numberWithBool:NO];
                        }
                    }
                    else
                    {
                        [strReturnValue setString: [NSString stringWithFormat:@"BCMS from SFIS Format Error:%@",szBCMSfromSFIC]];
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
                // Deal with the plant code from NVM, modify by Lucky base on new ERS, 2014/07/15
				NSString    *strConfigCode = [aryBCMSSN objectAtIndex:1];
				NSScanner   *scanner = [NSScanner scannerWithString:strConfigCode];
                unsigned    int     iValue = 0;
                [scanner	scanHexInt:&iValue];
                NSString    *strConfigCodeKey = [NSString stringWithFormat:@"0x0%X",iValue];
				ATSDebug(@"Calculated Config Code key from DUT :==> %@",strConfigCodeKey);
				
				rangeStartCMS = [rangeCatchValue rangeOfString:@"0x0 : "];
                rangeEndCMS = [rangeCatchValue rangeOfString:@"0x8 : "];
                if (NSNotFound == rangeStartCMS.location || NSNotFound == rangeEndCMS.location|| rangeStartCMS.length ==0 || rangeEndCMS.length ==0 || (rangeStartCMS.location+ rangeStartCMS.length) >[rangeCatchValue length]|| (rangeEndCMS.location +rangeEndCMS.length) > [rangeCatchValue length])
                {
                    ATSDebug(@"NVM format error");
                    [strReturnValue setString: @"NVM format Error"];
                    return [NSNumber numberWithBool:NO];
                }
                NSString    *szNVMPart = [rangeCatchValue substringToIndex:rangeEndCMS.location];
                szNVMPart = [szNVMPart substringFromIndex:rangeStartCMS.location+rangeStartCMS.length];
                NSArray *arrNVMPart = [szNVMPart componentsSeparatedByString:@" "];
				NSString    *strPlantCode = [arrNVMPart objectAtIndex:2];
                scanner = [NSScanner scannerWithString:strPlantCode];
                iValue = 0;
                [scanner scanHexInt:&iValue];
                NSString    *strPlantCodeKey = [NSString stringWithFormat:@"0x%X",iValue];
				ATSDebug(@"Calculated Plant Code key from DUT :==> %@",strPlantCodeKey);
                /* Get plant code and config's key from DUT End*/
                
                /* Get plant code and config from SFIS Start*/
                // Get the plant code
                NSString    *strPlantCodeFromSFIS = [szBCMSfromSFIC substringWithRange:NSMakeRange(0, 3)];
				ATSDebug(@"Get Plant Code from SFIS:==> %@",strPlantCodeFromSFIS);
                // Get the config code
                NSString    *strConfigCodeFromSFIS = [szBCMSfromSFIC substringWithRange:NSMakeRange(11, 5)];
				ATSDebug(@"Get Config Code from SFIS:==> %@",strConfigCodeFromSFIS);
                /* Get plant code and config from DUT Start*/ 
                NSString    *strPlantCodeFromDut = @"NULL",   *strConfigCodeFromDut = @"NULL";
                if (!dicPlantCodeMT) 
                {
                    [strReturnValue setString:@"Plant Code Table in script is empty."];
                    return [NSNumber numberWithBool:NO];
                }
                for(NSString    *keyTemp in [dicPlantCodeMT allKeys])
                {
                    if ([keyTemp isEqualToString:strPlantCodeKey])
                    {
                        strPlantCodeFromDut = [NSString stringWithFormat:@"%@",[dicPlantCodeMT objectForKey:strPlantCodeKey]];
                        break;
                    }
                }
                if (!dicConfigCodeMT)
                {
                    [strReturnValue setString:@"Config Code Table in script is empty."]; 
                    return [NSNumber numberWithBool:NO];
                }
                for(NSString    *keyTemp in [dicConfigCodeMT allKeys])
                {
                    if([keyTemp isEqualToString:strConfigCodeKey])
                    {
                        strConfigCodeFromDut = [NSString stringWithFormat:@"%@",[dicConfigCodeMT objectForKey:strConfigCodeKey]];
                        break;
                    }
                }
                /* Get plant code and config from DUT End*/ 
                /* Compare Start */ 
                if([strPlantCodeFromDut ContainString:strPlantCodeFromSFIS] && [strConfigCodeFromDut ContainString:strConfigCodeFromSFIS])
                {
                    bRet = YES;
                }
                else
                {
                    bRet = NO;
                    [strReturnValue setString:[NSString stringWithFormat:@"BCMS from SFIS is %@,Back Camera SN from UNIT is %@, %@, %@",szBCMSfromSFIC,szBCMSSN,[strPlantCodeFromDut isEqualToString:@"NULL"]?[NSString stringWithFormat:@"Plant Code %@ from unit is not in the Mapping table", strPlantCodeKey]:[NSString stringWithFormat:@"Plant Code from unit is %@",strPlantCodeFromDut],[strConfigCodeFromDut isEqualToString:@"NULL"]?[NSString stringWithFormat:@"Config Code %@ from unit is not in the Mapping table",strConfigCodeKey]:[NSString stringWithFormat:@"Config Code from unit is %@",strConfigCodeFromDut]]];
					ATSDebug(@"After Compared,the result is %@",strReturnValue);
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


- (BOOL)COMPARE_PLANTANDCONFIG_WITHSFIS:(NSDictionary *)dicContents RETURN_VALUE:(NSMutableString *)strReturnValue
{
    // torres remove plant code check, and review in PVT. 2012 7 23
    // Get info from args
    //NSDictionary    *dicPlantCodeMT = [dicContents objectForKey:@"PLANTCODEMT"];
    NSDictionary    *dicConfigCodeMT = [dicContents objectForKey:@"CONFIGCODEMT"];
    //NSString        *strPlantCode = [dicContents objectForKey:@"PLANTCODEFROMNVM"];
    NSString        *strConfigCode = [dicContents objectForKey:@"CONFIGCODEFROMNVM"];
    NSString        *strCameraSNFromSFIS = [dicContents objectForKey:@"SFISINFO"];
    
    if (!strConfigCode)
    {
        return NO;
    }
    
    // Read from Plant Mapping Table in Script
    //NSString    *strPlantCodeFromMT = [dicPlantCodeMT objectForKey:strPlantCode];
    //NSString    *strPlantCodeFromSFIS = [strCameraSNFromSFIS substringWithRange:NSMakeRange(0, 3)];
    //BOOL        bPlantCodeCMPRet = NO, bConfigCodeCMPRet = NO, bRet = NO;
    BOOL bConfigCodeCMPRet = NO;
    // torres remove plant code check, and review in PVT. 2012 7 23 --BAING
    // ***Compare Plant Code Start***
    /*if (nil != strPlantCodeFromMT) 
    {
        NSArray *arrPlantCodeInfo = [strPlantCodeFromMT componentsSeparatedByString:@"/"];
        for (int i = 0; i < [arrPlantCodeInfo count]; i++) 
        {
            if ([strPlantCodeFromSFIS isEqualToString:[arrPlantCodeInfo objectAtIndex:i]])
            {
                bPlantCodeCMPRet = YES;
                [strReturnValue setString:[NSString stringWithFormat:@"%@, PlantCode From DUT is %@",strReturnValue,[arrPlantCodeInfo objectAtIndex:i]]];
                break;
            }
        }
        if (! bPlantCodeCMPRet) 
        {
            [strReturnValue setString: [NSString stringWithFormat:@"Compare fail![PLANTCODE from DUT:%@,FCMS from SFIS:%@]",strPlantCodeFromMT,strCameraSNFromSFIS]];
            ATSDebug(@"Compare PlantCode with SFIS fail");
            return NO;
        }
    }
    else
    {
        ATSDebug(@"NVM format error: PlantCode format error");
        return NO;
    }*/
    // ***Compare Plant Code End***
    // torres remove plant code check, and review in PVT. 2012 7 23 --END

    // Read from Config Mapping Table by strPlantCodeFromSFIS as a key.
    //dicConfigCodeMT = [dicConfigCodeMT objectForKey:strPlantCodeFromSFIS];
    NSString    *strConfigCodeFromMT = [dicConfigCodeMT objectForKey:strConfigCode];
    /////
    
    
    NSString    *strConfigCodeFromSFIS = [strCameraSNFromSFIS substringWithRange:NSMakeRange(11, 5)];
    
    // ***Compare Config Code Start***
    if (nil != strConfigCodeFromMT) 
    {
        NSArray *arrConfigCodeInfo = [strConfigCodeFromMT componentsSeparatedByString:@"/"];
        /*for (int i = 0; i < [arrConfigCodeInfo count]; i++) 
        {
            if ([strConfigCodeFromSFIS isEqualToString:[arrConfigCodeInfo objectAtIndex:i]])
            {
                bConfigCodeCMPRet = YES; 
                [strReturnValue setString:[NSString stringWithFormat:@"%@, ConfigCode From DUT is %@",strReturnValue,[arrConfigCodeInfo objectAtIndex:i]]];
                break;
            }
        }
        
        if (! bConfigCodeCMPRet) 
        {
            [strReturnValue setString: [NSString stringWithFormat:@"Compare fail![PLANTCODE from DUT:%@,BCMS from SFIS:%@]",strConfigCodeFromMT,strCameraSNFromSFIS]];
            ATSDebug(@"Compare ConfigCode with SFIS fail");
            return NO;
      
        }*/
        
        if(strConfigCodeFromMT != nil && strConfigCodeFromSFIS != nil)
        {
            for (int i = 0; i < [arrConfigCodeInfo count]; i++) 
            {
                if ([strConfigCodeFromSFIS isEqualToString:[arrConfigCodeInfo objectAtIndex:i]])
                {
                    bConfigCodeCMPRet = YES; 
                    [strReturnValue setString:[NSString stringWithFormat:@"%@, ConfigCode From DUT is %@",strReturnValue,[arrConfigCodeInfo objectAtIndex:i]]];
                    break;
                }
            }            
        }else
        {
            [strReturnValue setString: [NSString stringWithFormat:@"Compare fail![ConfigCode from DUT:%@,BCMS from SFIS:%@]",strConfigCodeFromMT,strCameraSNFromSFIS]];
            ATSDebug(@"strConfigCodeFromMT = %@, strConfigCodeFromSFIS = %@", strConfigCodeFromMT, strConfigCodeFromSFIS);
            ATSDebug(@"Compare ConfigCode with SFIS fail");
            bConfigCodeCMPRet = NO;
        }
    }

    // torres remove plant code check, and review in PVT. 2012 7 23
    // ***Compare Config Code End***
    //bRet = bPlantCodeCMPRet && bConfigCodeCMPRet;
    return bConfigCodeCMPRet;
}

/****************************************************************************************************
 Start 2012.4.23 Add note by Sky_Ge 
 Descripton: Combine camera SN for QT0 station.
 Param:
 NSMutableString *strReturnValue : Return value
 NSArray *aryContents : the data which need to conbine.
 ****************************************************************************************************/

- (BOOL)COMBINE_CAMERA_SN:(NSArray *)aryContents RETURN_VALUE:(NSString **)strReturnValue
{
    NSScanner *scan;
    unsigned int iValue;
    NSString *szYear;
    NSString *szWeek;
    NSString *szDay;
    NSString *szYearWeekDay;
    NSString  *szFirstSN;
    NSString  *szSecondSN;
	NSString  *szThirdSN;
    NSString *szCameraSN;
    
    //Add for front camera Year,work week,day 1/17/13
    if([[aryContents lastObject] isEqual:@"FCMS"])
    {
        //Year
        scan = [NSScanner scannerWithString:[aryContents objectAtIndex:2]];
        [scan scanHexInt:&iValue];
        iValue &= 0x0f;
        szYear = [NSString stringWithFormat:@"%d",iValue];
        //Week
        scan = [NSScanner scannerWithString:[aryContents objectAtIndex:3]];
        [scan scanHexInt:&iValue];
        iValue &= 0x3f;
        if (iValue <=9)
        {
            szWeek = [NSString stringWithFormat:@"0%d",iValue];
        }
        else
        {
            szWeek = [NSString stringWithFormat:@"%d",iValue];
        }
        //Day
        scan = [NSScanner scannerWithString:[aryContents objectAtIndex:4]];
        [scan scanHexInt:&iValue];
        iValue &= 0x07;
        szDay = [NSString stringWithFormat:@"%d",iValue];
    }
    //Add for back camera Year,work week,day 1/17/13
    if([[aryContents lastObject] isEqual:@"BCMS"])
    {
        //Year
        scan = [NSScanner scannerWithString:[aryContents objectAtIndex:0]];
        [scan scanHexInt:&iValue];
        iValue &= 0x0f;
        szYear = [NSString stringWithFormat:@"%d",iValue];
        //Week
        scan = [NSScanner scannerWithString:[aryContents objectAtIndex:1]];
        [scan scanHexInt:&iValue];
        iValue &= 0x3f;
        if (iValue <=9)
        {
            szWeek = [NSString stringWithFormat:@"0%d",iValue];
        }
        else
        {
            szWeek = [NSString stringWithFormat:@"%d",iValue];
        }
        //Day
        scan = [NSScanner scannerWithString:[aryContents objectAtIndex:2]];
        [scan scanHexInt:&iValue];
        iValue &= 0x0f;
        szDay = [NSString stringWithFormat:@"%d",iValue];
    }
    
    szYearWeekDay = [NSString stringWithFormat:@"%@%@%@",szYear,szWeek,szDay];
    ATSDebug(@"szYearWeekDay : %@",szYearWeekDay);
    
    //-----------------------------------
    //Sequence Number
    if([[aryContents lastObject] isEqual:@"FCMS"])
    {
        szFirstSN = [aryContents objectAtIndex:5];
        szSecondSN = [aryContents objectAtIndex:6];
        szThirdSN = [aryContents objectAtIndex:7];
    }
    if([[aryContents lastObject] isEqual:@"BCMS"])
    {
        szFirstSN = [aryContents objectAtIndex:3];
        szSecondSN = [aryContents objectAtIndex:4];
        szThirdSN = [aryContents objectAtIndex:5];
    }
    
    if ([szFirstSN length] == 3)
    {
        szFirstSN = [NSString stringWithFormat:@"0%@",[szFirstSN substringWithRange:NSMakeRange(2, 1)]];
    }
    else
    {
        szFirstSN = [szFirstSN substringWithRange:NSMakeRange(2, 2)];
    }
    if ([szSecondSN length] == 3)
    {
        szSecondSN = [NSString stringWithFormat:@"0%@",[szSecondSN substringWithRange:NSMakeRange(2, 1)]];
    }
    else
    {
        szSecondSN = [szSecondSN substringWithRange:NSMakeRange(2, 2)]; 
    }
    if ([szThirdSN length] == 3)
    {
        szThirdSN = [NSString stringWithFormat:@"0%@",[szThirdSN substringWithRange:NSMakeRange(2, 1)]];
    }
    else
    {
        szThirdSN = [szThirdSN substringWithRange:NSMakeRange(2, 2)]; 
    }
    
    szCameraSN = [NSString stringWithFormat:@"%@%@%@",szThirdSN,szSecondSN,szFirstSN];
    
    // use function "NumberSystemConvertion" instead of "OriginalString"
    NSMutableDictionary	*dictConvertion	= [[NSMutableDictionary alloc] init];
    NSMutableString *szMutableCameraSN = [[NSMutableString alloc] initWithString:szCameraSN];
    [dictConvertion setObject:[NSNumber numberWithInt:16] forKey:@"CHANGE"];
    [dictConvertion setObject:[NSNumber numberWithInt:34] forKey:@"TO"];
    [dictConvertion setObject:[NSNumber numberWithInt:4] forKey:@"PLACE"];
    if (![self NumberSystemConvertion:dictConvertion RETURN_VALUE:szMutableCameraSN]) 
    {
        ATSDebug(@"Catch wrong value,please check!");
        *strReturnValue = @"Catch wrong value,please check";
        [szMutableCameraSN release];
        [dictConvertion release];
        return NO;
    }
    
    //----summary
    szCameraSN = [NSString stringWithFormat:@"%@%@",szYearWeekDay,szMutableCameraSN];
    ATSDebug(@"Combine CameraSN from DUT:==> %@",szCameraSN);
    *strReturnValue = [NSString stringWithString:szCameraSN];
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

-(NSNumber*)JUDGE_BBVERSION:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue
{
    NSString *szBBVERSION = [dicContents objectForKey:strReturnValue];
    
    if (szBBVERSION == nil) {
        ATSDebug(@"Get the wrong board id!");
        return [NSNumber numberWithBool:NO];
    }
    
    [m_dicMemoryValues setObject:szBBVERSION forKey:@"BBVERSION"];
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
-(NSNumber*)CaculateColorCheckSum:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue
{
    int sum= 0;
    NSScanner *scanerData;
    unsigned int iValue;
    int checksum =0;
    if (NSNotFound == [strReturnValue rangeOfString:@" "].location)
    {
        ATSDebug(@"Invaild value!");
        return [NSNumber numberWithBool:NO];
    }
    NSArray *arrData =[strReturnValue componentsSeparatedByString:@" "];
 
    for (int i = 0; i< [arrData count];i++)
    {
        scanerData = [NSScanner scannerWithString:[arrData objectAtIndex:i]];
       // [scanerData scanHexInt:&iValue];
        if ([scanerData scanHexInt:&iValue] &&[scanerData isAtEnd])
            sum = sum +iValue;
        
    }

    checksum = 256 - (sum&0x0ff);
    ATSDebug(@"check sum is %i",checksum);
    [strReturnValue setString:[NSString stringWithFormat:@"%i",checksum]];
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
   // *strSourceData = [*strSourceData stringByReplacingOccurrencesOfString:@"\r" withString:@""];
	//NSArray * arrCell = [*strSourceData componentsSeparatedByString:@"\n"];
	//NSMutableString * strCamera = [[NSMutableString alloc] initWithString:@""];
    returnValue = [returnValue stringByReplacingOccurrencesOfString:@"\r" withString:@""];
	NSArray * arrCell = [returnValue componentsSeparatedByString:@"\n"];

	NSMutableArray *aryTemp = [[NSMutableArray alloc] init];
	for (NSString * strCell in arrCell)//int i = 0; i< [arrCell count]; i++)
	{
		//NSString * strCell = [arrCell objectAtIndex:i];
		NSRange range = [strCell rangeOfString:@" : "];
		if (NSNotFound != range.location && range.length > 0 && (range.location + range.length) <= [strCell length])
		{
			NSString * strTemp =[strCell substringFromIndex:range.location + range.length];
            //[strTemp stringByReplacingOccurrencesOfString:@"  " withString:@" "];
            
			NSArray * arrayUnit = [strTemp componentsSeparatedByString:@" "];
            NSMutableArray *arrBits = [[NSMutableArray alloc] initWithArray:arrayUnit];
            [arrBits removeLastObject];
            for (int iIndex = 0; iIndex < [arrBits count]; iIndex ++)
			{    
                NSString *szValue = ([[arrBits objectAtIndex:iIndex] length] == 4) ? [[arrBits objectAtIndex:iIndex] stringByReplacingOccurrencesOfString:@"0x" withString:@""]: [[arrBits objectAtIndex:iIndex]  stringByReplacingOccurrencesOfString:@"x" withString:@""];
                if ([szValue length] <2)
                {
                    szValue =[NSString stringWithFormat:@"0%@",szValue];
                }
            
				[aryTemp addObject:szValue];
			}
            [arrBits release];
           // [aryTemp addObjectsFromArray:arrayUnit];
		}
	}
    
    NSArray * aryFinal = [NSArray arrayWithArray:aryTemp];
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

-(NSNumber*)DO_CAMERA_DATA:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue
{
    NSString *szValue;
    NSArray *arrData;
    NSRange rangeFrontStart;
    NSRange rangeFrontEnd;
    NSRange rangeBackStart;
    NSRange rangeBackEnd;
    int Ibegin = [[dicContents objectForKey:@"BeginIndex"] intValue];
    int iEnd = [[dicContents objectForKey:@"EndIndex"] intValue];
    NSString *szKey = [dicContents objectForKey:@"KEY"];
    NSString *szSourceValue = [m_dicMemoryValues objectForKey:@"CAMERA_CONFIG"];
    if ([szKey isEqualToString:@"Front"]) 
    {   
        rangeFrontStart = [szSourceValue rangeOfString:@"Sensor channel 1 detected : "];
    if (rangeFrontStart.location == NSNotFound ||rangeFrontStart.length <=0)
    {
        ATSDebug(@"Front NVM Data Missing!")
        //[strReturnValue setString:@"Front NVM Data Missing!"];
        return [NSNumber numberWithBool:NO];
    }
    
    szValue = [szSourceValue substringFromIndex:(rangeFrontStart.location+rangeFrontStart.length)];
    rangeFrontEnd = [szValue rangeOfString:@"0x400 :"]; 
    if (rangeFrontEnd .location == NSNotFound || rangeFrontEnd.length <=0) 
    {
            ATSDebug(@"Front NVM Format Error!")
            return [NSNumber numberWithBool:NO];

    }
   szValue = [szValue substringToIndex:rangeFrontEnd.location];
    rangeFrontStart = [szValue rangeOfString:@"NVM Data 1024 bytes : "];
    if(rangeFrontStart.location == NSNotFound || rangeFrontStart.length <=0 )
    {
        ATSDebug(@"Front NVM Format Error!")
        return [NSNumber numberWithBool:NO];
        
    }
    szValue = [szValue substringFromIndex:(rangeFrontStart.location + rangeFrontStart.length)];
    }
    else if ([szKey isEqualToString:@"Back"])
    {
        rangeBackStart = [szSourceValue rangeOfString:@"Sensor channel 0 detected : "];
        if (rangeBackStart.location == NSNotFound ||rangeBackStart.length<=0)
        {
            ATSDebug(@"Back NVM Data Missing!")
            return [NSNumber numberWithBool:NO];
        }
        szValue = [szSourceValue substringFromIndex:(rangeBackStart.location+rangeBackStart.length)];
        rangeBackEnd = [szValue rangeOfString:@"0x200 :"];
        if (rangeBackEnd.location == NSNotFound ||rangeBackEnd.length<=0)
        {
            ATSDebug(@"Back NVM Format Error!")
            return [NSNumber numberWithBool:NO];
        }
        [szValue substringToIndex:rangeBackEnd.location];
        
        rangeBackStart = [szValue rangeOfString:@"NVM Data 768 bytes : "];
        if(rangeBackStart.location == NSNotFound || rangeBackStart.length <=0 )
        {
            ATSDebug(@"Back NVM Format Error!")
            return [NSNumber numberWithBool:NO];
            
        }
        szValue = [szValue substringFromIndex:(rangeBackStart.location + rangeBackStart.length)];


    }
    else 
    {
        ATSDebug(@"You must decide to  one sensor!");
        return [NSNumber numberWithBool:NO];
        
    }
   // ATSDebug(@"The szvalue is %@",szValue);
    arrData =[self DealWithNVMData:szValue];
	if ([arrData count] < iEnd)
	{
		[strReturnValue setString:@"Fatle error"];
		ATSDebug(@"Can't get enough array count");
		return [NSNumber numberWithBool:NO];
	}
    [strReturnValue setString:@""];
    if ([dicContents objectForKey:@"BeginIndex"]==nil && [dicContents objectForKey:@"EndIndex"]==nil)
    {
        for (int i =0; i < [arrData count] -1; i++) {
            [strReturnValue appendString:[NSString stringWithFormat:@"%@ ",[arrData objectAtIndex:i]]];
        }
        [strReturnValue appendString:[arrData objectAtIndex:([arrData count] -1)]];
        return [NSNumber numberWithBool:YES];
    }
    if ([dicContents objectForKey:@"BeginIndex"]==nil)
    {
        for (int i =0; i <iEnd; i++) {
            [strReturnValue appendString:[NSString stringWithFormat:@"%@ ",[arrData objectAtIndex:i]]];
        }
        [strReturnValue appendString:[arrData objectAtIndex:iEnd]];
        return [NSNumber numberWithBool:YES];
    }
    
    if ([dicContents objectForKey:@"EndIndex"]==nil)
    {
        for (int i =Ibegin; i <[arrData count] -1; i++) {
            [strReturnValue appendString:[NSString stringWithFormat:@"%@ ",[arrData objectAtIndex:i]]];
        }
        [strReturnValue appendString:[arrData objectAtIndex:([arrData count] -1)]];
        return [NSNumber numberWithBool:YES];
    }
    if (iEnd==Ibegin)
    {
        [strReturnValue appendString:[arrData objectAtIndex:Ibegin]];
        ATSDebug(@"The value is %@",strReturnValue);
          return [NSNumber numberWithBool:YES];
    }
    if (Ibegin < iEnd) 
    {
        for (int i =Ibegin; i <iEnd; i++) {
            [strReturnValue appendString:[NSString stringWithFormat:@"%@ ",[arrData objectAtIndex:i]]];
        }
        [strReturnValue appendString:[arrData objectAtIndex:(iEnd )]];
        return [NSNumber numberWithBool:YES];

    }
    else
    {
        ATSDebug(@"Invaild index,please check it!");
        //[strReturnValue setString:@"Invaild Index"];
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
-(NSNumber*)CATCH_BIT:(NSDictionary *)dicQueryContents RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSDictionary *dicBit = [dicQueryContents objectForKey:@"Bit"]; 
    NSString *szTestName = [dicBit objectForKey:@"TestName"];
    if (dicBit!=nil)
    {    
        [self NumberSystemConvertion:dicBit RETURN_VALUE:szReturnValue];        
    }
    ATSDebug(@"return value is %@",szReturnValue);
    [m_dicMemoryValues setValue:[NSString stringWithString:szReturnValue] forKey:szTestName];
    return [NSNumber numberWithBool:YES];
}

//2012-04-19 add description by Winter
// Used to combine some string values to a string value, for example(A;B;C =====> ABC)
// Param:
//       NSDictionary    *dicQueryContents        : Settings in script
//       NSMutableString *strReturnValue     : Return value
// Return:
//      Actions result
-(NSNumber*)CONBINE_DATA:(NSDictionary *)dicQueryContents RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSString *szValue = [dicQueryContents objectForKey:@"KEY"];
    NSString *szFinalValue = [dicQueryContents objectForKey:@"TestName"];
    NSString *szSeperateKey =[dicQueryContents objectForKey:@"SeperateKey"];
    
    NSArray *arrData = [szValue componentsSeparatedByString:@";"];
    [szReturnValue setString:@""];
    if ([arrData count] == 1)
    {
       if (nil != [m_dicMemoryValues objectForKey:[arrData objectAtIndex:0]])
       {
           NSString *szFirstValue = [m_dicMemoryValues objectForKey:[arrData objectAtIndex:0]];
           if (szSeperateKey != nil&&![szSeperateKey isEqualTo:@""]) 
           {
               [szReturnValue appendString:[NSString stringWithFormat:@"%@%@",szSeperateKey,szFirstValue]];
           }
           else
           {
               [szReturnValue appendString:szFirstValue];
           }
           
       }
        else
        {
            ATSDebug(@"AVERAGE_WITH_KEYS : no value in dicMemoryValues with key");
            return [NSNumber numberWithBool:NO];

        }
    }
    else
    {
        for (int i =0; i< [arrData count]; i++)
        {
            if (nil !=[m_dicMemoryValues objectForKey:[arrData objectAtIndex:i]])
            {    
                NSString *szValueKey = [m_dicMemoryValues objectForKey:[arrData objectAtIndex:i]];
                if ([szValueKey ContainString:@"Can't get the value of the key"]) {
                    [szReturnValue setString: szValueKey];
                    break;
                }
                if (szSeperateKey != nil&&![szSeperateKey isEqualTo:@""])
                {
                    if(i ==[arrData count]-1)
                    {
                        [szReturnValue appendString:szValueKey];
                    }
                    else
                    {
                        [szReturnValue appendString:[NSString stringWithFormat:@"%@%@",szValueKey,szSeperateKey]];
                    }
                }
                else
                {
                    [szReturnValue appendString:szValueKey];
                }
            }
            else
            {    
                ATSDebug(@"AVERAGE_WITH_KEYS : no value in dicMemoryValues with key[%@]",[arrData objectAtIndex:i]);
                return [NSNumber numberWithBool:NO];
                
            }
        }
    }
    ATSDebug(@"return value is %@",szReturnValue);
    if (szFinalValue !=nil)
    {
    [m_dicMemoryValues setValue:szReturnValue forKey:szFinalValue];
    }
    return [NSNumber numberWithBool:YES];
    
}

//2012-04-19 add description by Winter
// Used to change test item name by different nand_size. You'll see the changed the name at parametric data and UI.
// Param:
//       NSDictionary    *dicContents        : Settings in script
//       NSMutableString *strReturnValue     : Return value
// Return:
//      Actions result
- (NSNumber *)CHANGE_TESTCASENAME_BY_NANDSIZE:(NSDictionary *)dicContents RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSString        *szCurrentTestItem;
    // auto test system (query key changed)
    NSString *szNandSizeKey = [dicContents objectForKey:@"nand_size"];
    NSString      *szNandSize = szNandSizeKey==nil?[m_dicMemoryValues objectForKey:@"nand_size"]:[m_dicMemoryValues objectForKey:szNandSizeKey];
    
    if (nil == szNandSize) 
    {
        ATSDebug(@"Nand Size error!");
        [szReturnValue setString:@"Nand Size error!"];
        return [NSNumber numberWithBool:NO];
    }
	
    //Modified by Leehua 130227
    NSArray *aryAllowedNand = [dicContents objectForKey:@"ALLOW_NAND"];
    ATSDebug(@"Allowed Nand : %@",aryAllowedNand);
    if ([aryAllowedNand containsObject:szNandSize]) 
    {
        szCurrentTestItem = [NSString stringWithFormat:@"NAND Size [%@] Check between sysconfig and unit",szNandSize];
    }
    /*if ([szNandSize isEqualToString:@"8G"] || [szNandSize isEqualToString:@"16G"] || [szNandSize isEqualToString:@"32G"]|| [szNandSize isEqualToString:@"64G"] || [szNandSize isEqualToString:@"96G"] || [szNandSize isEqualToString:@"128G"]) 
    {
        szCurrentTestItem = [NSString stringWithFormat:@"NAND Size [%@] Check between sysconfig and unit",szNandSize];
    }*/
    else
    {
        ATSDebug(@"Get the wrong nand size : %@",szNandSize);
        [szReturnValue setString:[NSString stringWithFormat:@"Get the wrong nand size : %@",szNandSize]];
        return [NSNumber numberWithBool:NO];
    }
    [m_dicMemoryValues setObject:szCurrentTestItem forKey:kFZ_UI_SHOWNNAME];
    
    return [NSNumber numberWithBool:YES];
}

@end
