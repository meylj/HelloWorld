//
//  TPuddingPDCA.m
//  TestPudding
//
//  Created by 吳 枝霖 on 2009/9/7.
//  Copyright 2009 PEGATRON. All rights reserved.
//

#import "TPuddingPDCA.h"
#import <dlfcn.h>

@implementation TPuddingPDCA
@synthesize haveSetISN;

@synthesize delegate;
// Correct init syntax error by Ken_Wu on 2012.02.25
- (id)init {
    if (self = [super init]) {
        NSBundle		*thisBundle = [NSBundle bundleForClass:[self class]];
        NSDictionary	*mInfo = [thisBundle infoDictionary];
        m_Version = [[NSString alloc] initWithString:[mInfo valueForKey:@"CFBundleVersion"]];
        
        haveSetISN = NO;
        m_bUUTStart = NO;
            
        m_RequireAttributes = [[NSMutableDictionary alloc] init];
        m_TestItemList = [[NSMutableArray alloc] init];    
        m_ToolVer = [[NSMutableString alloc] initWithString:@""];
        m_ToolName = [[NSMutableString alloc] initWithString:@""];
        m_Limits = [[NSMutableString alloc] initWithString:@""];
        m_ISNumber = [[NSMutableString alloc] initWithString:@""];
        
        NSLog(@"Start Pudding Framework version : %@", m_Version);
    }
	return self;
}

- (void)dealloc {
    [self Cancel_Process];

	[m_RequireAttributes release];
	[m_ISNumber release];
	[m_TestItemList release];
	[m_Version release];
	[m_ToolVer release];
	[m_ToolName release];
	[m_Limits release];
	[super dealloc];
}

- (NSString *) getPuddingVersion 
{
	return [NSString stringWithFormat:@"%s",f_IP_getVersion()];
}

- (int) handleReply :(IP_API_Reply) reply ErrorMsg : (NSString **) pMsg FailCode : (int) pCode {
	UInt8	nRetCode = kSuccessCode;
	if ( !f_IP_success( reply ) )
	{
		*pMsg = [[[NSString stringWithFormat:@"%s",f_IP_reply_getError(reply)] retain] autorelease];
        //[delegate writeDebugLog:[NSString stringWithFormat:@"PuddingPDCA Framework : handleReply : %@",*pMsg]];
		nRetCode = pCode;
	}
	f_IP_reply_destroy(reply);
	reply = NULL;
	return nRetCode;
}

- (void) SetInitParamter : (NSString *) pVersion STATOIN_NAME:(NSString *) pName 
		SOFTWARE_LIMITS: (NSString *) pLimits{
	NSString *strErrDesc = [NSString stringWithFormat:@"PuddingPDCA Framework : SetInitParamter(%@,%@,%@)",
							pVersion,pName,pLimits];	
	NSAssert(pVersion && pName && pLimits,@"%@",strErrDesc);
    UInt	nRetCode = kSuccessCode;
    NSString	*pErrorMsg = @"Error from SetInitParamter:STATION_NAME:SOFTWARE_LIMITS:";
    nRetCode = [self handleReply:f_IP_addAttribute( UID, IP_ATTRIBUTE_STATIONSOFTWAREVERSION, [pVersion UTF8String] ) 
                        ErrorMsg:&pErrorMsg FailCode:kIP_addAttribute_Fail];
    if (nRetCode != kSuccessCode) 
    {
        [delegate writeDebugLog:[NSString stringWithFormat:@"PuddingPDCA Framework : IP_ATTRIBUTE_STATIONSOFTWAREVERSION = %@", pVersion]];
    }
    nRetCode = [self handleReply:f_IP_addAttribute( UID, IP_ATTRIBUTE_STATIONSOFTWARENAME, [pName UTF8String] ) 
                            ErrorMsg:&pErrorMsg FailCode:kIP_addAttribute_Fail];
    if (nRetCode != kSuccessCode)
    {
        [delegate writeDebugLog:[NSString stringWithFormat:@"PuddingPDCA Framework : IP_ATTRIBUTE_STATIONSOFTWARENAME = %@", pName]];
    }
    nRetCode = [self handleReply:f_IP_addAttribute( UID, IP_ATTRIBUTE_STATIONLIMITSVERSION, [pLimits UTF8String] ) 
                            ErrorMsg:&pErrorMsg FailCode:kIP_addAttribute_Fail];
    if (nRetCode != kSuccessCode)
    {
        [delegate writeDebugLog:[NSString stringWithFormat:@"PuddingPDCA Framework : IP_ATTRIBUTE_STATIONLIMITSVERSION = %@", pLimits]];
    }
}

- (UInt8) SetPDCA_ISN : (NSString *) pISN {
	UInt	nRetCode = kSuccessCode;
    if (m_bUUTStart)
    {
        if (pISN) {
            NSString	*pErrorMsg = @"Error from SetPDCA_ISN()";
            // Added by Lorky on 2011-10-04, check the serial number is validate.
            nRetCode = [self handleReply:f_IP_validateSerialNumber ( UID, [pISN UTF8String] ) ErrorMsg:&pErrorMsg FailCode:kIP_InvalidSerinalNumber];
            if (nRetCode == kSuccessCode)
            {
                nRetCode = [self handleReply:f_IP_addAttribute( UID, IP_ATTRIBUTE_SERIALNUMBER, [pISN UTF8String] ) 
                                    ErrorMsg:&pErrorMsg FailCode:kIP_addAttribute_Fail];
                haveSetISN = (kSuccessCode == nRetCode);
            }
            else
                [delegate writeDebugLog:[NSString stringWithFormat:@"PuddingPDCA Framework : IP_VALIDATE_SERIALNUMBER = %@", pISN]];
            if (nRetCode == kSuccessCode)
                [m_ISNumber setString:pISN];
        }
        else
            return kSendISNumber_ERROR;
    }
    else
    {
        nRetCode = kIP_UUTStart_Fail;
    }
	return nRetCode;
}

- (void) SetTestItemStatus : (NSString *) pMainItem SubItem : (NSString *) pSubItem TestValue : (NSString *) pValue 
				  LowLimit : (NSString *) pLLimit HighLimit : (NSString *) pHLimit  TestUnits : (NSString *) pUnits 
				  ErrDesc  : (NSString *) pErrCode Priority : (NSInteger) pPriority TestResult : (BOOL) pResult {
	NSString *strErrDesc = [NSString stringWithFormat:@"PuddingPDCA Framework : SetTestItemStatus(%@,%@,%@,%@,%@,%@,%@)",
							pMainItem,pSubItem,pValue,pLLimit,pHLimit,pUnits,pErrCode];
	
	NSAssert(pMainItem && pSubItem && pValue && pLLimit && pHLimit && pUnits && pErrCode,@"%@",strErrDesc);
	
    // set the max length = 512 of error description
    if (512 < [pErrCode length])
    {
        pErrCode = [pErrCode substringToIndex:512];
    }
    
	NSString * szFilteTestValue = [pValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSString * szUpLimit = [pHLimit stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSString * szDnLimit = [pLLimit stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSScanner *scannerUpLimit = [NSScanner scannerWithString:szUpLimit];
	NSScanner *scannerDnLimit = [NSScanner scannerWithString:szDnLimit];
	float fReturnValue = 0;
	pValue = ([szFilteTestValue isEqualToString:@""]) ? @"NA" : szFilteTestValue;
	pHLimit = ([scannerUpLimit scanFloat:&fReturnValue] && [scannerUpLimit isAtEnd]) ? szUpLimit : @"NA";
	pLLimit = ([scannerDnLimit scanFloat:&fReturnValue] && [scannerDnLimit isAtEnd]) ? szDnLimit : @"NA";
	
	TTestItemList	*m_TestItem = [[TTestItemList alloc] init];
	[m_TestItem setM_MainItem:pMainItem];
	[m_TestItem setM_SubItem:pSubItem];
	[m_TestItem setM_TestValue:pValue];
	[m_TestItem setM_LowLimit:pLLimit];
	[m_TestItem setM_HighLimit:pHLimit];
	[m_TestItem setM_Units:pUnits];
	[m_TestItem setM_ErrCode:pErrCode];
	[m_TestItem setM_TestResult:pResult];
	[m_TestItem setM_Priority:pPriority];
	[m_TestItemList addObject:m_TestItem];
	[m_TestItem release];
    [delegate writeDebugLog:[NSString stringWithFormat:@"PuddingPDCA Framework : %@",strErrDesc]];
}

- (UInt8) StartPDCA_Flow {
	UInt8	nRetCode = kSuccessCode;
    if(!m_bUUTStart)
    {
        NSString	*ErrorMsg = @"Error from UUTStart()";
        //[delegate writeDebugLog:[NSString stringWithString:@"PuddingPDCA Framework : Start StartPDCA_Flow"]];
        UID = 0;
        nRetCode = [self handleReply: f_IP_UUTStart(&UID) ErrorMsg:&ErrorMsg 
                            FailCode:kIP_UUTStart_Fail];
        m_bUUTStart = nRetCode == kSuccessCode ? YES : NO;
        //[delegate writeDebugLog:[NSString stringWithFormat:@"PuddingPDCA Framework : End StartPDCA_Flow(nRetCode = %d) = %d", nRetCode, m_bUUTStart]];
    }
	return nRetCode;
}
- (UInt8) Cancel_Process {
	UInt8	nRetCode = kSuccessCode;
	if(m_bUUTStart)
	{
		NSString	*ErrorMsg = @"Error from UUTStart()";
        //[delegate writeDebugLog:[NSString stringWithString:@"PuddingPDCA Framework : start Cancel_Process"]];
		nRetCode = [self handleReply: f_IP_UUTCancel(UID) ErrorMsg:&ErrorMsg 
							FailCode:kIP_UUTCancel_Fail];
		m_bUUTStart = nRetCode == kSuccessCode ? NO : YES;
        //[delegate writeDebugLog:[NSString stringWithFormat:@"PuddingPDCA Framework : End Cancel_Process(nRetCode = %d) = %d", nRetCode, m_bUUTStart]];        
	}
    haveSetISN = NO;
    [m_ISNumber setString:@""];
    //add by jingfu ran on 2011 10 18
	return nRetCode;
}


- (UInt8) CompleteTestProcess : (NSString *) pTestLogCSV 
					 ErrorMsg : (NSString**) pErrorMsg
{
	UInt8	nRetCode = kSuccessCode;
	UInt16	nFailCount = 0;
    [delegate writeDebugLog:[NSString stringWithFormat:@"PuddingPDCA Framework : Start CompleteTestProcess(BlobFile = %@)", pTestLogCSV]];
	*pErrorMsg = @"IP_API_Reply contained an error : ";
	if (!m_bUUTStart)
		nRetCode = kIP_UUTStart_Fail;
	if (m_ISNumber == NULL || [m_ISNumber isEqualToString:@""])
		nRetCode = kSendISNumber_ERROR;
	if (nRetCode == kSuccessCode) 
	{
		NSString	*strValue;
		for (id key in m_RequireAttributes)  
		{
			strValue = [m_RequireAttributes objectForKey:key];
			nRetCode = [self handleReply:f_IP_addAttribute( UID, [key UTF8String], [strValue UTF8String] ) 
							ErrorMsg:pErrorMsg FailCode:kIP_addAttribute_Fail];
			if (nRetCode != kSuccessCode) 
			{
                [delegate writeDebugLog:[NSString stringWithFormat:@"PuddingPDCA Framework : %@ = %@", key, strValue]];
				break;
			}
		}
	}
	if (nRetCode == kSuccessCode) 
	{
		NSInteger priority = IP_PRIORITY_REALTIME;
		UInt8 nTestCode;
		for (UInt i1 = 0;i1 < [m_TestItemList count];i1 ++)
		{
			double			dResultValue	= 0;
			TTestItemList	*TestItem = [m_TestItemList objectAtIndex:i1];
			// Added by Lorky 2011-11-05, Upload Up/Dn limit while they are number.
			// Modified by Izual_Lu on 2011-11-07, a test item is numeric or not, is delimited by its spec, but not its value. 
			BOOL			bIsNumber	= YES;
            NSString *szTestValue = [NSString stringWithString:[TestItem m_TestValue]];
            NSScanner		*valueScanner;
            BOOL			bNumberResult = YES;
            // upload the char "NA" and digital.2012.1.13 torres
            if (![@"NA" isEqualToString:szTestValue]) {
                // if test value is not equal to NA, the value bNumberResult will be judge its type. Ture will Double, Fail will be Char. 
                valueScanner = [NSScanner scannerWithString:[TestItem m_TestValue]];
                bNumberResult	= [valueScanner scanDouble:&dResultValue] && [valueScanner isAtEnd];
            }else{
                
                NSLog(@"PuddingPDCA Framework : test value is equal to 'NA'");
            }
        
			//NSScanner		*valueScanner = [NSScanner scannerWithString:[TestItem m_TestValue]];
			//BOOL			bNumberResult	= [valueScanner scanDouble:&dResultValue] && [valueScanner isAtEnd];
			NSScanner		*UplimitScanner = [NSScanner scannerWithString:[TestItem m_HighLimit]];
			NSScanner		*DnlimitScaaner = [NSScanner scannerWithString:[TestItem m_LowLimit]];
			bIsNumber	= (([UplimitScanner scanDouble:&dResultValue] && [UplimitScanner isAtEnd]) 
						   || ([DnlimitScaaner scanDouble:&dResultValue] && [DnlimitScaaner isAtEnd])
						   || bNumberResult);	// Scanner can be use only once. 
			nFailCount += ([TestItem m_TestResult] ? 0 : 1);
			IP_TestSpecHandle testSpec = f_IP_testSpec_create();
			nTestCode = [TestItem m_TestResult] ? IP_PASS : IP_FAIL;
				
			if ( NULL  == testSpec ) 
			{
                [delegate writeDebugLog:@"PuddingPDCA Framework : f_IP_testSpec_create an error"];
				nRetCode = kIP_testSpec_create_Fail;
				break;
			}
			else 
			{
				priority = [TestItem m_Priority];
				f_IP_testSpec_setTestName( testSpec, [[TestItem m_MainItem] UTF8String], [[TestItem m_MainItem] length]);
				if ([[TestItem m_SubItem] length] > 0)
					f_IP_testSpec_setSubTestName( testSpec, [[TestItem m_SubItem] UTF8String], [[TestItem m_SubItem] length]);
				//else
				//	f_IP_testSpec_setSubTestName( testSpec, "-", 1);
				//f_IP_testSpec_setSubSubTestName( testSpec, "-", 1);
				if (bIsNumber) 
				{
					f_IP_testSpec_setLimits( testSpec, [[TestItem m_LowLimit] UTF8String], 
											[[TestItem m_LowLimit] length], 
											[[TestItem m_HighLimit] UTF8String], 
											[[TestItem m_HighLimit] length]);
				}
				if (![(NSString *)[TestItem m_Units] isEqualToString:@""])
					f_IP_testSpec_setUnits( testSpec, [[TestItem m_Units] UTF8String], [[TestItem m_Units] length]);
				f_IP_testSpec_setPriority( testSpec, priority );
     
			}
			
			IP_TestResultHandle testResult = f_IP_testResult_create();
			f_IP_testResult_setResult( testResult, nTestCode);
            [delegate writeDebugLog:[NSString stringWithFormat:@"PuddingPDCA Framework : IsNumber = %s,%@ = %@", bIsNumber ? "YES" : "NO",[TestItem m_MainItem],[TestItem m_TestValue]]];
            
            // upload the char "NA" and digital.2012.1.13 torres
            NSLog(@"PuddingPDCA Framework : Limit is number[%d],test vlaue is number[%d]",bIsNumber,bNumberResult);
			if ((bIsNumber && bNumberResult))
			{	// Add by Izual_Lu on 2011-11-07, Default numeric value is -999999999. 
				//if(!bNumberResult)
					//f_IP_testResult_setValue( testResult, [@"-999999999" UTF8String], 10 );
				//else
					f_IP_testResult_setValue( testResult, 
											 [[TestItem m_TestValue] UTF8String], 
											 [[TestItem m_TestValue] length]);
                //NSLog(@"PuddingPDCA Framework : upload");
			}else{
                NSLog(@"PuddingPDCA Framework : the limits or test value is not an number,don't upload");
            }
        
			if (nTestCode == IP_PASS)
				f_IP_testResult_setMessage( testResult, "",0);
			else
				f_IP_testResult_setMessage( testResult, [[TestItem m_ErrCode] UTF8String],[[TestItem m_ErrCode] length]);
			*pErrorMsg = @"Error from IP_addResult() : ";
			nRetCode = [self handleReply: f_IP_addResult(UID, testSpec, testResult ) 
								ErrorMsg:pErrorMsg FailCode:kIP_addResult_ERROR];
			f_IP_testResult_destroy(testResult);
			f_IP_testSpec_destroy(testSpec);
			testResult = NULL;
			testSpec = NULL;
		}
	}
    
	if ((nRetCode == kSuccessCode) && ([pTestLogCSV length] > 0)) 
	{
		NSFileManager	*fCheck = [NSFileManager defaultManager];
		if ([fCheck fileExistsAtPath:pTestLogCSV]) 
		{
			NSString	*fName = @"UpPDCAFile";
			*pErrorMsg = @"IP_addBlob contained an error : ";
			nRetCode = [self handleReply:f_IP_addBlob( UID, [fName UTF8String], [pTestLogCSV UTF8String] ) 
								ErrorMsg:pErrorMsg FailCode:kIP_addBlob_Fail];
            [delegate writeDebugLog:[NSString stringWithFormat:@"PuddingPDCA Framework : f_IP_addBlob(BobName = %@,BobFile = %@) = %d", fName, pTestLogCSV, nRetCode]];
		}
		else
			nRetCode = kCVS_NOT_EXISTS;
	}
	if (nRetCode == kSuccessCode) 
	{
		NSString	*pCommitMsg = @"ERROR with the commit:";
		*pErrorMsg = @"Error returned from UUTDone: ";
		nRetCode = [self handleReply: f_IP_UUTDone(UID) 
							ErrorMsg:pErrorMsg FailCode:kIP_UUTDone_ERROR];
		if (nRetCode != kSuccessCode) 
		{
            [delegate writeDebugLog:[NSString stringWithFormat:@"PuddingPDCA Framework : f_IP_UUTDone(%@) = %d", *pErrorMsg, nRetCode]];
			nFailCount = -1;
		}
		UInt8 nRetCommit = [self handleReply: f_IP_UUTCommit(UID, nFailCount == 0 ? IP_PASS : IP_FAIL)
								ErrorMsg:&pCommitMsg FailCode:kIP_UUTCommit_ERROR];
        [delegate writeDebugLog:[NSString stringWithFormat:@"PuddingPDCA Framework : f_IP_UUTCommit(%@) = %d, FailCount = %d", pCommitMsg, nRetCommit, nFailCount]];
		if (nRetCommit != kSuccessCode)
			if (nRetCode == kSuccessCode) 
			{
				nRetCode = nRetCommit;
				*pErrorMsg = pCommitMsg;
			}
	}
	else
		[self Cancel_Process];
	if (UID) 
	{
		f_IP_UID_destroy( UID );
		UID = NULL;		
	}
    m_bUUTStart = NO;
    haveSetISN = NO;
    //add by jingfu ran on 2011 10 18
    
	if (nRetCode == kSuccessCode)
		*pErrorMsg = @"";
    [m_ISNumber setString:@""];
	[m_TestItemList removeAllObjects];
	[m_RequireAttributes removeAllObjects];
    [delegate writeDebugLog:[NSString stringWithFormat:@"PuddingPDCA Framework : End %d = CompleteTestProcess(ErrorMsg = %@)",nRetCode,*pErrorMsg]];
	return nRetCode;
}

- (UInt8) MakeBlobZIP_File : (NSString *) szFileName FileList : (NSArray *) pAryFileList
{
	UInt8			nRetCode = kSuccessCode;
	NSMutableArray	*aryArguemt = [NSMutableArray arrayWithArray:pAryFileList];
	NSTask			*zipTask = [[NSTask alloc] init];
    [delegate writeDebugLog:[NSString stringWithFormat:@"PuddingPDCA Framework : Start MakeBlobZIP_File(szFileName = %@, FileList = %@)", szFileName, pAryFileList]];
	[aryArguemt insertObject:szFileName atIndex:0];
	[aryArguemt insertObject:@"-j" atIndex:0];
	[zipTask setArguments:aryArguemt];
	[zipTask setLaunchPath:@"/usr/bin/zip"];
	[zipTask launch];
	[zipTask waitUntilExit];
	nRetCode = [zipTask terminationStatus];
	if (kSuccessCode != nRetCode)
		nRetCode = kZIP_File_Fail;
	[zipTask release];
    [delegate writeDebugLog:[NSString stringWithFormat:@"PuddingPDCA Framework : End %d = MakeBlobZIP_File()",nRetCode]];
	return nRetCode;
}

- (UInt8) MakeBlobZIP_File : (NSString *) szFileName FolderPath : (NSString *) pFolderName {
	UInt8			nRetCode = kSuccessCode;
	NSTask			*zipTask = [[NSTask alloc] init];
	NSArray			*aryArguemt = [NSArray arrayWithObjects:@"-ck",pFolderName,szFileName,nil];
	
    [delegate writeDebugLog:[NSString stringWithFormat:@"PuddingPDCA Framework : Start MakeBlobZIP_File(szFileName = %@, FolderPath = %@)", szFileName, pFolderName]];
	[zipTask setArguments:aryArguemt];
	[zipTask setLaunchPath:@"/usr/bin/ditto"];
	[zipTask launch];
	[zipTask waitUntilExit];
	nRetCode = [zipTask terminationStatus];
	if (kSuccessCode != nRetCode)
		nRetCode = kZIP_File_Fail;
	[zipTask release];
    [delegate writeDebugLog:[NSString stringWithFormat:@"PuddingPDCA Framework : End %d = MakeBlobZIP_File()",nRetCode]];
	return nRetCode;
}

- (NSString *) getInterfaceVersion {
	return m_Version;
}

- (void) SetQT_Attributes : (NSString *)pAttribute Key:(NSString *)szKey{
    [delegate writeDebugLog:[NSString stringWithFormat:@"PuddingPDCA Framework : SetQT_Attributes(Attribute = %@, Key = %@)",pAttribute,szKey]];
	[m_RequireAttributes setObject:pAttribute forKey:szKey]; 
}

/*- (UInt8) SetTestSlotID : (NSInteger) pnSlotID {
	UInt8			nRetCode = kSuccessCode;
	if (m_bUUTStart) {
		NSString	*pErrorMsg = @"IP_setDUTPosition contained an error : ";
		nRetCode = [self handleReply:f_IP_setDUTPosition( UID, IP_FIXTURE_ID_1, IP_FIXTURE_HEAD_ID_1) ErrorMsg:&pErrorMsg FailCode:kIP_setDUTPosition_Fail];
		if (nRetCode != kSuccessCode) 
            [delegate writeDebugLog:[NSString stringWithFormat:@"PuddingPDCA Framework : SetTestSlotID(%@)", pErrorMsg]];
	}
	else 
		nRetCode = kIP_UUTStart_Fail;
    [delegate writeDebugLog:[NSString stringWithFormat:@"PuddingPDCA Framework : %d = SetTestSlotID(%d)", nRetCode, pnSlotID]];
	return nRetCode;
}*/

/****************************************************************************************************
 iFixID         : fixture group id
 iHeadID        : fixture or dut id in one group
 description	: Set DUT in which slot
 ****************************************************************************************************/
- (UInt8) SetTestSlotID : (enum IP_ENUM_FIXTURE_ID) iFixID HeadId:(enum IP_ENUM_FIXTURE_HEAD_ID)iHeadID
{
    UInt8			nRetCode = kSuccessCode;
	if (m_bUUTStart) {
		NSString	*pErrorMsg = @"IP_setDUTPosition contained an error : ";
		nRetCode = [self handleReply:f_IP_setDUTPosition( UID, iFixID, iHeadID) ErrorMsg:&pErrorMsg FailCode:kIP_setDUTPosition_Fail];
		if (nRetCode != kSuccessCode) 
            [delegate writeDebugLog:[NSString stringWithFormat:@"PuddingPDCA Framework : SetTestSlotID(%@)", pErrorMsg]];
	}
	else 
		nRetCode = kIP_UUTStart_Fail;
    [delegate writeDebugLog:[NSString stringWithFormat:@"PuddingPDCA Framework : %d = SetTestSlotID(groupId:%d ; fixtureId:%d)", nRetCode, iFixID,iHeadID]];
	return nRetCode;
}

- (UInt8) CheckAmIOKey: (NSString **) pErrorMsg
{
	UInt8			nRetCode = kSuccessCode;
	if (!m_bUUTStart)
		nRetCode = kIP_UUTStart_Fail;
	if (m_ISNumber == NULL || [m_ISNumber isEqualToString:@""])
		nRetCode = kSendISNumber_ERROR;
	*pErrorMsg = [NSString stringWithFormat:@"IP_amIOkay contained an error : retCode = %d",nRetCode];
	if (nRetCode == kSuccessCode) 
	{
		nRetCode = [self handleReply:f_IP_amIOkay( UID, [m_ISNumber UTF8String] ) ErrorMsg:pErrorMsg FailCode:kIP_AmIOkey_Fail];
		if (nRetCode != kSuccessCode) 
            [delegate writeDebugLog:[NSString stringWithFormat:@"PuddingPDCA Framework : CheckAmIOKey not succeed (%@)", *pErrorMsg]];
	}
    else
    {
        [delegate writeDebugLog:[NSString stringWithFormat:@"PuddingPDCA Framework : CheckAmIOKey not in (%@)", *pErrorMsg]];
    }
	return nRetCode;
}

/****************************************************************************************************
 description	: extract the info from gh_station_info.json file
 eGHStationInfo : which info you wanna get (such as : IP_STATION_TYPE)
 strValue       : returned value
 Add by Leehua on 2011-11-15
 ****************************************************************************************************/
- (UInt8) getGHStationInfo: (enum IP_ENUM_GHSTATIONINFO) eGHStationInfo strValue:(NSString**) strValue errorMessage:(NSString **) pErrorMsg
{
    UInt8			nRetCode = kSuccessCode;
	if (m_bUUTStart)
	{
		size_t sLength = 0;
		*pErrorMsg = @"IP_getGHStationInfo contained an error when pointer is NULL";
		nRetCode = [self handleReply:f_IP_getGHStationInfo( UID, eGHStationInfo,NULL,&sLength ) ErrorMsg:pErrorMsg FailCode:kIP_GetGhInfoFail];
        //[delegate writeDebugLog:[NSString stringWithFormat:@"PuddingPDCA Framework : getGHStationInfo size =%ld",sLength]];
		if(kSuccessCode == nRetCode && sLength>0)
		{
			//allocate the memory buffer and pass it again with correct length again
            char *cpValue = malloc(sLength+1);
            nRetCode = [self handleReply:f_IP_getGHStationInfo( UID, eGHStationInfo,&cpValue,&sLength ) ErrorMsg:pErrorMsg FailCode:kIP_GetGhInfoFail];
            if(nRetCode == kSuccessCode)  
            {  
                if (cpValue!=NULL)
                    *strValue=[NSString stringWithUTF8String:(const char *)cpValue];
            }
            else
            {
                //ideally we should never get here, if we do then value in the gh_station_info.json does not look right
                //[delegate writeDebugLog:[NSString stringWithFormat:@"PuddingPDCA Framework : IP_getGHStationInfo Second call failed(%@)",*pErrorMsg]];
            }
            free(cpValue);
            cpValue = NULL;
            sLength =0;
		}
		else
        {
            //[delegate writeDebugLog:[NSString stringWithFormat:@"PuddingPDCA Framework : IP_getGHStationInfo First call failed(%@)",*pErrorMsg]];
        }
	}
	else 
    {
		nRetCode = kIP_UUTStart_Fail;
	}
	return nRetCode;
}

@end
@implementation TTestItemList

@synthesize m_MainItem;
@synthesize m_SubItem;
@synthesize m_TestValue;
@synthesize m_LowLimit;
@synthesize m_HighLimit;
@synthesize m_Units;
@synthesize m_TestResult;
@synthesize m_Priority;
@synthesize	m_ErrCode;

- (void)dealloc {
	[m_MainItem release];
    [m_SubItem release];
    [m_TestValue release];
    [m_LowLimit release];
    [m_HighLimit release];
    [m_Units release];
    [m_ErrCode release];
	[super dealloc];
}
@end
