//
//  TPuddingPDCA.m
//  TestPudding
//
//  Created by 吳 枝霖 on 2009/9/7.
//  Copyright 2009 PEGATRON. All rights reserved.
//



#import "TPuddingPDCA.h"
#import <dlfcn.h>


#define enumItem(item) case item:\
						return [NSString stringWithFormat:@"%s",#item];

NSString * descriptionOfGHStationInfo(enum IP_ENUM_GHSTATIONINFO item)
{
	switch (item) {
			enumItem(IP_SITE)					//SiteCode for the CM from PDCA (predetermined)
			enumItem(IP_PRODUCT)				//Product code name such as N88, N82 (predetermined)
			enumItem(IP_BUILD_STAGE)		    //Build stage
			enumItem(IP_BUILD_SUBSTAGE)			//Build sub stage
			enumItem(IP_REMOTE_ADDR)			//Test Station ip address (DHCP 24 hrs lease)
			enumItem(IP_LOCATION)				//CM building-Floor-Room and floor DA3-2FL-RM123 (predetermined)
			enumItem(IP_LINE_NUMBER)			//Official APPLE line name froom PDCA (predetermined)
			enumItem(IP_STATION_NUMBER)			//Test Station number on the line (setup when ground hogging)
			enumItem(IP_STATION_TYPE)			//PDCA station id code e.g SHIPPING-SETTINGS-OQC (should be same as GH) set up when ground hogging)
			enumItem(IP_SCREEN_COLOR)			//Perferred default background screen color(set up) when ground hogging)
			enumItem(IP_STATION_IP)				//Test Station ip address (DHCP 24 hrs lease)
			enumItem(IP_DCS_IP)					//ip address to submit data to the Data Collection server
			enumItem(IP_PDCA_IP)				//ip address of the PDCA
			enumItem(IP_KOMODO_IP)				//ip address for monitoring server
			enumItem(IP_SPIDERCAB_IP)			//Spidercab IP
			enumItem(IP_FUSING_IP)				//Fusing IP
			enumItem(IP_DROPBOX_IP)				//Dropbox IP
			enumItem(IP_SFC_IP)					//SFC IP
			enumItem(IP_SFC_URL)				//SFC URL
			enumItem(IP_PROV_IP)				//PROV IP
			enumItem(IP_DATE_TIME)				//last time when pudding updated the file
			enumItem(IP_STATION_ID)				//GUID of the station SITE+LOCATION+LINE_NUMBER+STATION_NUMBER+STATION_TYPE
			enumItem(IP_GROUNDHOG_IP)			//ip address of the groundhog server
			enumItem(IP_MAC)					//Station mac address
			enumItem(IP_SAVE_BRICKS)			//Saving bricks
			enumItem(IP_LOCAL_CSV)				//Saving csv locally
			enumItem(IP_REALTIME_PARAMETRIC)	//Real time parametic
			enumItem(IP_SINGLE_CSV_UUT)			//Single CSV UUT
			enumItem(IP_STATION_DISPLAY_NAME)	//station_display_name such as VIDEO-PREBURN
			enumItem(IP_URI_CONFIG_PATH)		//URI Station config path
			enumItem(IP_SFC_QUERY_UNIT_ON_OFF)
			enumItem(IP_SFC_TIMEOUT)
			enumItem(IP_GHSI_LASTUPDATE_TIMEOUT)
			enumItem(IP_FERRET_NOT_RUNNING_TIMEOUT)
			enumItem(IP_NETWORK_NOT_OK_TIMEOUT)
			enumItem(IP_STATION_SET_CONTROL_BIT_ON_OFF)
			enumItem(IP_CONTROL_BITS_TO_CHECK_ON_OFF)
			enumItem(IP_CONTROL_BITS_TO_CLEAR_ON_PASS_ON_OFF)
			enumItem(IP_CONTROL_BITS_TO_CLEAR_ON_FAIL_ON_OFF)
			enumItem(IP_ACTIVATION_IP)			//ip address of activation server
			enumItem(IP_LINE_MANAGER_IP)		//ip address of RAFT
            enumItem(IP_GDADMIN)
            enumItem(IP_RAFT_LINE)
            enumItem(IP_USB_STORAGE)
            enumItem(IP_FIREWALL)
            enumItem(IP_UNIT_PROCESS_REQUIRE_BOBCAT)
            enumItem(IP_GROUNDHOG_STARTED)
            enumItem(IP_LAST_RESTORED)
            enumItem(IP_CONTROL_RUN)
            enumItem(IP_CONTROL_RUN_CB)
            enumItem(IP_FDR_REGISTRATION)
            enumItem(IP_SEND_BLOBS_ON_FAIL_ONLY)
            enumItem(IP_SEND_BLOBS_ON)
            enumItem(IP_LIVE_VERSION)
            enumItem(IP_LIVE_CURRENT)
            enumItem(IP_LIVE_SCHEDULED)
            enumItem(IP_LIVE_VERSION_PATH)
            enumItem(IP_LINE_TYPE)
			enumItem(IP_GHSTATIONINFO_COUNT)
		default:
			return @"ERROR";
	}
}

@implementation TPuddingPDCA

@synthesize haveSetISN;
@synthesize delegate;

// Correct init syntax error by Ken_Wu on 2012.02.25
- (id)init
{
    if (self = [super init])
	{
        NSBundle		*thisBundle	= [NSBundle bundleForClass:[self class]];
        NSDictionary	*mInfo		= [thisBundle infoDictionary];
        m_Version			= [[NSString alloc] initWithString:[mInfo valueForKey:@"CFBundleVersion"]];
        
        haveSetISN			= NO;
        m_bUUTStart			= NO;
            
        m_RequireAttributes	= [[NSMutableDictionary alloc] init];
        m_TestItemList		= [[NSMutableArray alloc] init];    
        m_ToolVer			= [[NSMutableString alloc] initWithString:@""];
        m_ToolName			= [[NSMutableString alloc] initWithString:@""];
        m_Limits			= [[NSMutableString alloc] initWithString:@""];
        m_ISNumber			= [[NSMutableString alloc] initWithString:@""];
        
        //2012.11.1 modify by yaya.Sensor need call twice pudding to upload data.
        m_bIsFirstTime      = YES;
    }
	return self;
}

-(void)dealloc
{
    [self Cancel_Process];

	[m_RequireAttributes release];
	[m_ISNumber release]; m_ISNumber = nil;
	[m_TestItemList release];
	[m_Version release];
	[m_ToolVer release];
	[m_ToolName release];
	[m_Limits release];
	[super dealloc];
}

-(NSString*)getPuddingVersion 
{
	return [NSString stringWithFormat:@"%s",f_IP_getVersion()];
}

-(void)SetInitParamter:(NSString*)pVersion
		  STATOIN_NAME:(NSString*)pName
	   SOFTWARE_LIMITS:(NSString*)pLimits
{
	NSString	*strErrDesc	= [NSString stringWithFormat:
							   @"PuddingPDCA Framework : SetInitParamter(%@,%@,%@)",
							   pVersion,pName,pLimits];
	
	NSAssert(pVersion && pName && pLimits,strErrDesc);
    [m_ToolVer setString:pVersion];
    [m_ToolName setString:pName];
    [m_Limits setString:pLimits];
    [delegate writeDebugLog:[NSString stringWithFormat:
							 @"PuddingPDCA Framework : pVersion = %@, STATOIN_NAME = %@, SOFTWARE_LIMITS = %@",
                             m_ToolVer,m_ToolName,m_Limits]];
}

-(int)handleReply:(IP_API_Reply)reply
		 ErrorMsg:(NSString**)pMsg
		 FailCode:(int)pCode
{
	UInt8	nRetCode	= kSuccessCode;
	if(!f_IP_success( reply ))
	{
		*pMsg	= [[[NSString stringWithFormat:@"%s",f_IP_reply_getError(reply)] retain] autorelease];
		nRetCode = pCode;
	}
	f_IP_reply_destroy(reply);
	reply	= NULL;
	return nRetCode;
}

-(UInt8)SetPDCA_ISN:(NSString*)pISN
{
	UInt	nRetCode	= kSuccessCode;
    if (m_bUUTStart)
	{
        if (pISN)
		{
            NSString	*pErrorMsg	= @"Error from SetPDCA_ISN()";
            
            nRetCode	= [self handleReply:f_IP_addAttribute(UID, IP_ATTRIBUTE_STATIONSOFTWAREVERSION, [m_ToolVer UTF8String])
								ErrorMsg:&pErrorMsg
								FailCode:kIP_addAttribute_Fail];
            if(nRetCode == kSuccessCode)
                nRetCode	= [self handleReply:f_IP_addAttribute(UID, IP_ATTRIBUTE_STATIONSOFTWARENAME, [m_ToolName UTF8String]) 
									ErrorMsg:&pErrorMsg
									FailCode:kIP_addAttribute_Fail];
            else
                [delegate writeDebugLog:[NSString stringWithFormat:
										 @"PuddingPDCA Framework : IP_ATTRIBUTE_STATIONSOFTWARENAME = %@",
										 m_ToolName]];
            if(nRetCode == kSuccessCode)
                nRetCode	= [self handleReply:f_IP_addAttribute(UID, IP_ATTRIBUTE_STATIONLIMITSVERSION, [m_Limits UTF8String]) 
									ErrorMsg:&pErrorMsg
									FailCode:kIP_addAttribute_Fail];
            else
                [delegate writeDebugLog:[NSString stringWithFormat:
										 @"PuddingPDCA Framework : IP_ATTRIBUTE_STATIONLIMITSVERSION = %@",
										 m_Limits]];
            if (nRetCode == kSuccessCode)
            {
                // Added by Lorky on 2011-10-04, check the serial number is validate.
                nRetCode	= [self handleReply:f_IP_validateSerialNumber ( UID, [pISN UTF8String] )
									ErrorMsg:&pErrorMsg
									FailCode:kIP_InvalidSerinalNumber];
                if(nRetCode == kSuccessCode)
                {
                    nRetCode	= [self handleReply:f_IP_addAttribute(UID, IP_ATTRIBUTE_SERIALNUMBER, [pISN UTF8String]) 
										ErrorMsg:&pErrorMsg
										FailCode:kIP_addAttribute_Fail];
                    haveSetISN	= (kSuccessCode == nRetCode);
                }
                else
                    [delegate writeDebugLog:[NSString stringWithFormat:
											 @"PuddingPDCA Framework : IP_VALIDATE_SERIALNUMBER = %@",
											 pISN]];
            }
            else
                [delegate writeDebugLog:[NSString stringWithFormat:
										 @"PuddingPDCA Framework : IP_ATTRIBUTE_SERIALNUMBER = %@",
										 pISN]];
            
            if (nRetCode == kSuccessCode)
				[m_ISNumber setString:pISN];
        }
        else
            return kSendISNumber_ERROR;
    }
    else
        nRetCode	= kIP_UUTStart_Fail;
	return nRetCode;
}

-(void)SetTestItemStatus:(NSString *)pMainItem
				 SubItem:(NSString *)pSubItem
			  SubSubItem:(NSString *)pSubsubItem
			   TestValue:(NSString *)pValue
				LowLimit:(NSString *)pLLimit
			   HighLimit:(NSString *)pHLimit
			   TestUnits:(NSString *)pUnits
				 ErrDesc:(NSString *)pErrCode
				Priority:(NSInteger)pPriority
			  TestResult:(BOOL)pResult
{
	NSString *strErrDesc = [NSString stringWithFormat:@"PuddingPDCA Framework : SetTestItemStatus(%@,%@,%@,%@,%@,%@,%@,%@)",
							pMainItem,pSubItem,pSubsubItem,pValue,pLLimit,pHLimit,pUnits,pErrCode];
	
	NSAssert(pMainItem && pSubItem && pValue && pLLimit && pHLimit && pUnits && pErrCode,strErrDesc);
	
    // set the max length = 512 of error description
    if (512 < [pErrCode length])
    {
        pErrCode = [pErrCode substringToIndex:512];
    }
    
	NSString	*szFilteTestValue	= [pValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSString	*szUpLimit			= [pHLimit stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSString	*szDnLimit			= [pLLimit stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSScanner	*scannerUpLimit		= [NSScanner scannerWithString:szUpLimit];
	NSScanner	*scannerDnLimit		= [NSScanner scannerWithString:szDnLimit];
	float fReturnValue = 0;
	pValue	= ([szFilteTestValue isEqualToString:@""]) ? @"NA" : szFilteTestValue;
	pHLimit	= ([scannerUpLimit scanFloat:&fReturnValue] && [scannerUpLimit isAtEnd]) ? szUpLimit : @"NA";
	pLLimit	= ([scannerDnLimit scanFloat:&fReturnValue] && [scannerDnLimit isAtEnd]) ? szDnLimit : @"NA";
	
	TTestItemList	*m_TestItem		= [[TTestItemList alloc] init];
	m_TestItem.mainItem			= pMainItem;
	m_TestItem.subItem			= pSubItem;
	m_TestItem.subsubItem		= pSubsubItem;
	m_TestItem.testValue		= pValue;
	m_TestItem.lowLimit			= pLLimit;
	m_TestItem.highLimit		= pHLimit;
	m_TestItem.units			= pUnits;
	m_TestItem.testResult		= pResult;
	m_TestItem.errCode			= pErrCode;
	m_TestItem.priority			= pPriority;
	[m_TestItemList addObject:m_TestItem];
	[m_TestItem release];
    [delegate writeDebugLog:[NSString stringWithFormat: @"PuddingPDCA Framework : %@",strErrDesc]];
}

- (UInt8) StartPDCA_Flow
{
	UInt8	nRetCode	= kSuccessCode;
    if(!m_bUUTStart)
    {
        NSString	*ErrorMsg	= @"Error from UUTStart()";
        UID			= 0;
        nRetCode	= [self handleReply:f_IP_UUTStart(&UID)
							ErrorMsg:&ErrorMsg
							FailCode:kIP_UUTStart_Fail];
        m_bUUTStart	= (nRetCode == kSuccessCode ? YES : NO);
    }
	return nRetCode;
}

- (UInt8) Cancel_Process
{
	UInt8	nRetCode	= kSuccessCode;
	if(m_bUUTStart)
	{
		NSString	*ErrorMsg	= @"Error from UUTStart()";
		nRetCode	= [self handleReply:f_IP_UUTCancel(UID)
							ErrorMsg:&ErrorMsg
							FailCode:kIP_UUTCancel_Fail];
		m_bUUTStart	= (nRetCode == kSuccessCode ? NO : YES);
        if (UID) {
            f_IP_UID_destroy( UID );
            UID	= NULL;
        }
	}
    haveSetISN	= NO;
    [m_ISNumber setString:@""];
    //add by jingfu ran on 2011 10 18
	return nRetCode;
}

-(UInt8)CompleteTestProcess:(NSString*)pTestLogCSV 
				   ErrorMsg:(NSString**)pErrorMsg
{
	UInt8	nRetCode	= kSuccessCode;
	UInt16	nFailCount	= 0;
    [delegate writeDebugLog:[NSString stringWithFormat:
							 @"PuddingPDCA Framework : Start CompleteTestProcess(BlobFile = %@)",
							 pTestLogCSV]];
	*pErrorMsg	= @"IP_API_Reply contained an error : ";
	if (!m_bUUTStart)
		nRetCode	= kIP_UUTStart_Fail;
	if (m_ISNumber == nil || [m_ISNumber isEqualToString:@""])
		nRetCode	= kSendISNumber_ERROR;
	if (nRetCode == kSuccessCode) 
	{
		NSString	*strValue;
		for (id key in m_RequireAttributes)  
		{
			strValue	= [m_RequireAttributes objectForKey:key];
			nRetCode	= [self handleReply:f_IP_addAttribute( UID, [key UTF8String], [strValue UTF8String] ) 
								ErrorMsg:pErrorMsg
								FailCode:kIP_addAttribute_Fail];
			if (nRetCode != kSuccessCode) 
			{
                [delegate writeDebugLog:[NSString stringWithFormat:
										 @"PuddingPDCA Framework : %@ = %@",
										 key, strValue]];
				break;
			}
		}
	}
	if (nRetCode == kSuccessCode) 
	{
		NSInteger	priority	= IP_PRIORITY_REALTIME;
		UInt8	nTestCode;
		for (UInt i1 = 0;i1 < [m_TestItemList count];i1 ++) 
		{
			double			dResultValue	= 0;
			TTestItemList	*TestItem		= [m_TestItemList objectAtIndex:i1];
			// Added by Lorky 2011-11-05, Upload Up/Dn limit while they are number.
			// Modified by Izual_Lu on 2011-11-07, a test item is numeric or not, is delimited by its spec, but not its value. 
			BOOL			bIsNumber		= YES;
            NSString		*szTestValue	= [NSString stringWithString:TestItem.testValue];
            NSScanner		*valueScanner;
            BOOL			bNumberResult	= YES;
            // upload the char "NA" and digital.2012.1.13 torres
            if (![@"NA" isEqualToString:szTestValue])
			{
                // if test value is not equal to NA, the value bNumberResult will be judge its type. Ture will Double, Fail will be Char. 
                valueScanner	= [NSScanner scannerWithString:TestItem.testValue];
                bNumberResult	= [valueScanner scanDouble:&dResultValue] && [valueScanner isAtEnd];
            }
			else
                NSLog(@"PuddingPDCA Framework : test value is equal to 'NA'");
			
			NSScanner	*UplimitScanner	= [NSScanner scannerWithString:TestItem.highLimit];
			NSScanner	*DnlimitScaaner	= [NSScanner scannerWithString:TestItem.lowLimit];
			bIsNumber	= (([UplimitScanner scanDouble:&dResultValue] && [UplimitScanner isAtEnd]) 
						   || ([DnlimitScaaner scanDouble:&dResultValue] && [DnlimitScaaner isAtEnd])
						   || bNumberResult);	// Scanner can be use only once. 
			nFailCount	+= (TestItem.testResult ? 0 : 1);
			IP_TestSpecHandle	testSpec	= f_IP_testSpec_create();
			nTestCode	= (TestItem.testResult ? IP_PASS : IP_FAIL);
				
			if( NULL  == testSpec ) 
			{
				[delegate writeDebugLog:@"PuddingPDCA Framework : f_IP_testSpec_create an error"];
				nRetCode	= kIP_testSpec_create_Fail;
				break;
			}
			else 
			{
				priority	= TestItem.priority;
				f_IP_testSpec_setTestName(testSpec,
										  [TestItem.mainItem UTF8String],
										  [TestItem.mainItem length]);
				if ([TestItem.subItem length] > 0)
					f_IP_testSpec_setSubTestName(testSpec,
												 [TestItem.subItem UTF8String],
												 [TestItem.subItem length]);
				if ([TestItem.subsubItem length] > 0)
					f_IP_testSpec_setSubSubTestName(testSpec,
													[TestItem.subsubItem UTF8String],
													[TestItem.subsubItem length]);
				if (bIsNumber) 
					f_IP_testSpec_setLimits(testSpec,
											[TestItem.lowLimit UTF8String],
											[TestItem.lowLimit length],
											[TestItem.highLimit UTF8String],
											[TestItem.highLimit length]);
				if (![(NSString *)TestItem.units isEqualToString:@""])
					f_IP_testSpec_setUnits(testSpec,
										   [TestItem.units UTF8String],
										   [TestItem.units length]);
				f_IP_testSpec_setPriority(testSpec, priority );
			}
			
			IP_TestResultHandle	testResult	= f_IP_testResult_create();
			f_IP_testResult_setResult(testResult, nTestCode);
            [delegate writeDebugLog:[NSString stringWithFormat:
									 @"PuddingPDCA Framework : IsNumber = %s,%@ = %@",
									 (bIsNumber ? "YES" : "NO"),TestItem.mainItem,TestItem.testValue]];
            
            // upload the char "NA" and digital.2012.1.13 torres
            NSLog(@"PuddingPDCA Framework : Limit is number[%d],test vlaue is number[%d]",
				  bIsNumber,bNumberResult);
			if ((bIsNumber && bNumberResult))
				f_IP_testResult_setValue(testResult, 
										 [TestItem.testValue UTF8String],
										 [TestItem.testValue length]);
			else
                NSLog(@"PuddingPDCA Framework : the limits or test value is not an number,don't upload");
        
			if (nTestCode == IP_PASS)
				f_IP_testResult_setMessage(testResult, "",0);
			else
				f_IP_testResult_setMessage(testResult, [TestItem.errCode UTF8String],[TestItem.errCode length]);
			*pErrorMsg	= @"Error from IP_addResult() : ";
			nRetCode	= [self handleReply: f_IP_addResult(UID, testSpec, testResult ) 
								ErrorMsg:pErrorMsg
								FailCode:kIP_addResult_ERROR];
			f_IP_testResult_destroy(testResult);
			f_IP_testSpec_destroy(testSpec);
			testResult	= NULL;
			testSpec	= NULL;
		}
	}
	if ((nRetCode == kSuccessCode) && ([pTestLogCSV length] > 0)) 
	{
		NSFileManager	*fCheck	= [NSFileManager defaultManager];
		if ([fCheck fileExistsAtPath:pTestLogCSV]) 
		{
			NSString	*fName = @"UpPDCAFile";
			*pErrorMsg	= @"IP_addBlob contained an error : ";
			nRetCode	= [self handleReply:f_IP_addBlob(UID, [fName UTF8String], [pTestLogCSV UTF8String] ) 
								ErrorMsg:pErrorMsg
								FailCode:kIP_addBlob_Fail];
            [delegate writeDebugLog:[NSString stringWithFormat:
									 @"PuddingPDCA Framework : f_IP_addBlob(BobName = %@,BobFile = %@) = %d",
									 fName, pTestLogCSV, nRetCode]];
		}
		else
			nRetCode	= kCVS_NOT_EXISTS;
	}
	if(nRetCode == kSuccessCode) 
	{
		NSString	*pCommitMsg	= @"ERROR with the commit:";
		*pErrorMsg	= @"Error returned from UUTDone: ";
		nRetCode	= [self handleReply: f_IP_UUTDone(UID) 
							ErrorMsg:pErrorMsg
							FailCode:kIP_UUTDone_ERROR];
		if(nRetCode != kSuccessCode) 
		{
            [delegate writeDebugLog:[NSString stringWithFormat:
									 @"PuddingPDCA Framework : f_IP_UUTDone(%@) = %d",
									 *pErrorMsg, nRetCode]];
			nFailCount	= -1;
		}
		UInt8	nRetCommit	= [self handleReply: f_IP_UUTCommit(UID, nFailCount == 0 ? IP_PASS : IP_FAIL)
									ErrorMsg:&pCommitMsg
									FailCode:kIP_UUTCommit_ERROR];
        [delegate writeDebugLog:[NSString stringWithFormat:
								 @"PuddingPDCA Framework : f_IP_UUTCommit(%@) = %d, FailCount = %d",
								 pCommitMsg, nRetCommit, nFailCount]];
		if (nRetCommit != kSuccessCode)
			if (nRetCode == kSuccessCode) 
			{
				nRetCode	= nRetCommit;
				*pErrorMsg	= pCommitMsg;
			}
	}
	else
		[self Cancel_Process];
	if (UID) 
	{
		f_IP_UID_destroy( UID );
		UID	= NULL;		
	}
    m_bUUTStart	= NO;
    haveSetISN	= NO;
    //add by jingfu ran on 2011 10 18
    
	if (nRetCode == kSuccessCode)
		*pErrorMsg	= @"";
    [m_ISNumber setString:@""];

	[m_TestItemList removeAllObjects];
	[m_RequireAttributes removeAllObjects];
	
	[delegate writeDebugLog:[NSString stringWithFormat:
							 @"PuddingPDCA Framework : End %d = CompleteTestProcess(ErrorMsg = %@)",
							 nRetCode,*pErrorMsg]];
	return nRetCode;
}
///
//Add for uploading more than one zip file to PDCA.Pleasure  2013.04.15
-(UInt8)FinishTestProcess:(NSArray*)pAryTestLogCSV
                 ErrorMsg:(NSString**)pErrorMsg
{
	UInt8	nRetCode	= kSuccessCode;
	UInt16	nFailCount	= 0;
    [delegate writeDebugLog:[NSString stringWithFormat:
							 @"PuddingPDCA Framework : Start CompleteTestProcess(BlobFile = %@)",
							 [pAryTestLogCSV description]]];
	*pErrorMsg	= @"IP_API_Reply contained an error : ";
	if (!m_bUUTStart)
		nRetCode	= kIP_UUTStart_Fail;
	if (m_ISNumber == nil || [m_ISNumber isEqualToString:@""])
		nRetCode	= kSendISNumber_ERROR;
	if (nRetCode == kSuccessCode)
	{
		NSString	*strValue;
		for (id key in m_RequireAttributes)
		{
			strValue	= [m_RequireAttributes objectForKey:key];
			nRetCode	= [self handleReply:f_IP_addAttribute( UID, [key UTF8String], [strValue UTF8String] )
								ErrorMsg:pErrorMsg
								FailCode:kIP_addAttribute_Fail];
			if (nRetCode != kSuccessCode)
			{
                [delegate writeDebugLog:[NSString stringWithFormat:
										 @"PuddingPDCA Framework : %@ = %@",
										 key, strValue]];
				break;
			}
		}
	}
	if (nRetCode == kSuccessCode)
	{
		UInt8	priority	= IP_PRIORITY_REALTIME;
		UInt8	nTestCode;
		for (UInt i1 = 0;i1 < [m_TestItemList count];i1 ++)
		{
			double			dResultValue	= 0;
			TTestItemList	*TestItem		= [m_TestItemList objectAtIndex:i1];
			// Added by Lorky 2011-11-05, Upload Up/Dn limit while they are number.
			// Modified by Izual_Lu on 2011-11-07, a test item is numeric or not, is delimited by its spec, but not its value.
			BOOL			bIsNumber		= YES;
            NSString		*szTestValue	= [NSString stringWithString:TestItem.testValue];
            NSScanner		*valueScanner;
            BOOL			bNumberResult	= YES;
            // upload the char "NA" and digital.2012.1.13 torres
            if (![@"NA" isEqualToString:szTestValue])
			{
                // if test value is not equal to NA, the value bNumberResult will be judge its type. Ture will Double, Fail will be Char.
                valueScanner	= [NSScanner scannerWithString:TestItem.testValue];
                bNumberResult	= [valueScanner scanDouble:&dResultValue] && [valueScanner isAtEnd];
            }
			else
                NSLog(@"PuddingPDCA Framework : test value is equal to 'NA'");
			
			NSScanner	*UplimitScanner	= [NSScanner scannerWithString:TestItem.highLimit];
			NSScanner	*DnlimitScaaner	= [NSScanner scannerWithString:TestItem.lowLimit];
			bIsNumber	= (([UplimitScanner scanDouble:&dResultValue] && [UplimitScanner isAtEnd])
						   || ([DnlimitScaaner scanDouble:&dResultValue] && [DnlimitScaaner isAtEnd])
						   || bNumberResult);	// Scanner can be use only once.
			nFailCount	+= (TestItem.testResult ? 0 : 1);
			IP_TestSpecHandle	testSpec	= f_IP_testSpec_create();
			nTestCode	= (TestItem.testResult ? IP_PASS : IP_FAIL);
            
			if( NULL  == testSpec )
			{
				[delegate writeDebugLog:@"PuddingPDCA Framework : f_IP_testSpec_create an error"];
				nRetCode	= kIP_testSpec_create_Fail;
				break;
			}
			else
			{
				priority	= TestItem.priority;
				f_IP_testSpec_setTestName(testSpec,
										  [TestItem.mainItem UTF8String],
										  [TestItem.mainItem length]);
				if ([TestItem.subItem length] > 0)
					f_IP_testSpec_setSubTestName(testSpec,
												 [TestItem.subItem UTF8String],
												 [TestItem.subItem length]);
				if ([TestItem.subsubItem length] > 0)
					f_IP_testSpec_setSubSubTestName(testSpec,
													[TestItem.subsubItem UTF8String],
													[TestItem.subsubItem length]);
				if (bIsNumber)
					f_IP_testSpec_setLimits(testSpec,
											[TestItem.lowLimit UTF8String],
											[TestItem.lowLimit length],
											[TestItem.highLimit UTF8String],
											[TestItem.highLimit length]);
				if (![(NSString *)TestItem.units isEqualToString:@""])
					f_IP_testSpec_setUnits(testSpec,
										   [TestItem.units UTF8String],
										   [TestItem.units length]);
				f_IP_testSpec_setPriority(testSpec, priority );
			}
			
			IP_TestResultHandle	testResult	= f_IP_testResult_create();
			f_IP_testResult_setResult(testResult, nTestCode);
            [delegate writeDebugLog:[NSString stringWithFormat:
									 @"PuddingPDCA Framework : IsNumber = %s,%@ = %@",
									 (bIsNumber ? "YES" : "NO"),TestItem.mainItem,TestItem.testValue]];
            
            // upload the char "NA" and digital.2012.1.13 torres
            NSLog(@"PuddingPDCA Framework : Limit is number[%d],test vlaue is number[%d]",
				  bIsNumber,bNumberResult);
			if ((bIsNumber && bNumberResult))
				f_IP_testResult_setValue(testResult,
										 [TestItem.testValue UTF8String],
										 [TestItem.testValue length]);
			else
                NSLog(@"PuddingPDCA Framework : the limits or test value is not an number,don't upload");
            
			if (nTestCode == IP_PASS)
				f_IP_testResult_setMessage(testResult, "",0);
			else
				f_IP_testResult_setMessage(testResult, [TestItem.errCode UTF8String],[TestItem.errCode length]);
			*pErrorMsg	= @"Error from IP_addResult() : ";
			nRetCode	= [self handleReply: f_IP_addResult(UID, testSpec, testResult )
								ErrorMsg:pErrorMsg
								FailCode:kIP_addResult_ERROR];
			f_IP_testResult_destroy(testResult);
			f_IP_testSpec_destroy(testSpec);
			testResult	= NULL;
			testSpec	= NULL;
		}
	}
    for (int k =0; k<[pAryTestLogCSV count]; k++)
    {
        NSString   *pTestLogCSV = [pAryTestLogCSV objectAtIndex:k ];
        if ((nRetCode == kSuccessCode) && ([pTestLogCSV length] > 0))
        {
            NSFileManager	*fCheck	= [NSFileManager defaultManager];
            if ([fCheck fileExistsAtPath:pTestLogCSV])
            {
                *pErrorMsg	= @"IP_addBlob contained an error : ";
               // NSString    *strUploadPDCA  = @"JF4R_JIHJJ89OKKJ_XRAY.jpg";
                NSString     *strUploadPDCA   = [pTestLogCSV      lastPathComponent];
                strUploadPDCA   = [strUploadPDCA    stringByReplacingOccurrencesOfString:@".gz" withString:@""];
                strUploadPDCA    = [strUploadPDCA   stringByReplacingOccurrencesOfString:@"."  withString:@"_"];
                strUploadPDCA   = [strUploadPDCA    stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
                strUploadPDCA  = [strUploadPDCA     stringByReplacingOccurrencesOfString:@"-" withString:@""];
                strUploadPDCA   = [strUploadPDCA    stringByReplacingOccurrencesOfString:@" " withString:@""];
                strUploadPDCA   = [strUploadPDCA    stringByReplacingOccurrencesOfString:@":" withString:@""];
                strUploadPDCA   = [strUploadPDCA    stringByReplacingOccurrencesOfString:@"_jpg" withString:@".jpg"];
                 nRetCode	= [self handleReply:f_IP_addBlob(UID, [strUploadPDCA UTF8String], [pTestLogCSV UTF8String] )
                                    ErrorMsg:pErrorMsg
                                    FailCode:kIP_addBlob_Fail];
                [delegate writeDebugLog:[NSString stringWithFormat:
                                         @"PuddingPDCA Framework : f_IP_addBlob(BobName = %@,BobFile = %@) = %d",
                                         pTestLogCSV, pTestLogCSV, nRetCode]];
                NSLog(@"Hehehehe:%@ : %c",strUploadPDCA, nRetCode);

            }
            else
                nRetCode	= kCVS_NOT_EXISTS;
        }
}
	if(nRetCode == kSuccessCode)
	{
		NSString	*pCommitMsg	= @"ERROR with the commit:";
		*pErrorMsg	= @"Error returned from UUTDone: ";
		nRetCode	= [self handleReply: f_IP_UUTDone(UID)
							ErrorMsg:pErrorMsg
							FailCode:kIP_UUTDone_ERROR];
		if(nRetCode != kSuccessCode)
		{
            [delegate writeDebugLog:[NSString stringWithFormat:
									 @"PuddingPDCA Framework : f_IP_UUTDone(%@) = %d",
									 *pErrorMsg, nRetCode]];
			nFailCount	= -1;
		}
		UInt8	nRetCommit	= [self handleReply: f_IP_UUTCommit(UID, nFailCount == 0 ? IP_PASS : IP_FAIL)
									ErrorMsg:&pCommitMsg
									FailCode:kIP_UUTCommit_ERROR];
        [delegate writeDebugLog:[NSString stringWithFormat:
								 @"PuddingPDCA Framework : f_IP_UUTCommit(%@) = %d, FailCount = %d",
								 pCommitMsg, nRetCommit, nFailCount]];
		if (nRetCommit != kSuccessCode)
			if (nRetCode == kSuccessCode)
			{
				nRetCode	= nRetCommit;
				*pErrorMsg	= pCommitMsg;
			}
	}
	else
		[self Cancel_Process];
	if (UID)
	{
		f_IP_UID_destroy( UID );
		UID	= NULL;
	}
    m_bUUTStart	= NO;
    haveSetISN	= NO;
    //add by jingfu ran on 2011 10 18
    
	if (nRetCode == kSuccessCode)
		*pErrorMsg	= @"";
    [m_ISNumber setString:@""];

	[m_TestItemList removeAllObjects];
	[m_RequireAttributes removeAllObjects];
    //end  2012.11.1 modify by yaya.Sensor need call twice pudding to upload data.
    
    [delegate writeDebugLog:[NSString stringWithFormat:
							 @"PuddingPDCA Framework : End %d = CompleteTestProcess(ErrorMsg = %@)",
							 nRetCode,*pErrorMsg]];
	return nRetCode;
}


-(UInt8)MakeBlobZIP_File:(NSString*)szFileName
				FileList:(NSArray*)pAryFileList
{
	UInt8			nRetCode	= kSuccessCode;
	NSMutableArray	*aryArguemt	= [NSMutableArray arrayWithArray:pAryFileList];
	NSTask			*zipTask	= [[NSTask alloc] init];
    [delegate writeDebugLog:[NSString stringWithFormat:
							 @"PuddingPDCA Framework : Start MakeBlobZIP_File(szFileName = %@, FileList = %@)",
							 szFileName, pAryFileList]];
	[aryArguemt insertObject:szFileName atIndex:0];
	[aryArguemt insertObject:@"-j" atIndex:0];
	[zipTask setArguments:aryArguemt];
	[zipTask setLaunchPath:@"/usr/bin/zip"];
	[zipTask launch];
	[zipTask waitUntilExit];
	nRetCode	= [zipTask terminationStatus];
	if (kSuccessCode != nRetCode)
		nRetCode	= kZIP_File_Fail;
	[zipTask release];
    [delegate writeDebugLog:[NSString stringWithFormat:
							 @"PuddingPDCA Framework : End %d = MakeBlobZIP_File()",
							 nRetCode]];
	return nRetCode;
}

-(UInt8)MakeBlobZIP_File:(NSString*)szFileName FolderPath:(NSString*)pFolderName
{
	UInt8	nRetCode	= kSuccessCode;
	NSTask	*zipTask	= [[NSTask alloc] init];
	NSArray	*aryArguemt	= [NSArray arrayWithObjects:@"-ck",pFolderName,szFileName,nil];
	
    [delegate writeDebugLog:[NSString stringWithFormat:
							 @"PuddingPDCA Framework : Start MakeBlobZIP_File(szFileName = %@, FolderPath = %@)",
							 szFileName, pFolderName]];
	[zipTask setArguments:aryArguemt];
	[zipTask setLaunchPath:@"/usr/bin/ditto"];
	[zipTask launch];
	[zipTask waitUntilExit];
	nRetCode	= [zipTask terminationStatus];
	if (kSuccessCode != nRetCode)
		nRetCode	= kZIP_File_Fail;
	[zipTask release];
    [delegate writeDebugLog:[NSString stringWithFormat:
							 @"PuddingPDCA Framework : End %d = MakeBlobZIP_File()",
							 nRetCode]];
	return nRetCode;
}

- (NSString *) getInterfaceVersion
{
	return m_Version;
}

-(void)SetQT_Attributes:(NSString*)pAttribute Key:(NSString*)szKey
{
    [delegate writeDebugLog:[NSString stringWithFormat:
							 @"PuddingPDCA Framework : SetQT_Attributes(Attribute = %@, Key = %@)",
							 pAttribute,szKey]];
	[m_RequireAttributes setObject:pAttribute forKey:szKey]; 
}

/**
 iFixID         : fixture group id
 iHeadID        : fixture or dut id in one group
 description	: Set DUT in which slot. */
-(UInt8)SetTestSlotID:(enum IP_ENUM_FIXTURE_ID)iFixID
			   HeadId:(enum IP_ENUM_FIXTURE_HEAD_ID)iHeadID
{
    UInt8	nRetCode	= kSuccessCode;
	if (m_bUUTStart)
	{
		NSString	*pErrorMsg	= @"IP_setDUTPosition contained an error : ";
		nRetCode	= [self handleReply:f_IP_setDUTPosition( UID, iFixID, iHeadID)
							ErrorMsg:&pErrorMsg
							FailCode:kIP_setDUTPosition_Fail];
		if (nRetCode != kSuccessCode) 
            [delegate writeDebugLog:[NSString stringWithFormat:
									 @"PuddingPDCA Framework : SetTestSlotID(%@)",
									 pErrorMsg]];
	}
	else 
		nRetCode	= kIP_UUTStart_Fail;
    [delegate writeDebugLog:[NSString stringWithFormat:
							 @"PuddingPDCA Framework : %d = SetTestSlotID(groupId:%d ; fixtureId:%d)",
							 nRetCode, iHeadID, iFixID]];
	return nRetCode;
}

-(UInt8)CheckAmIOKey:(NSString**)pErrorMsg
{
	UInt8	nRetCode	= kSuccessCode;
	if (!m_bUUTStart)
		nRetCode	= kIP_UUTStart_Fail;
	if (m_ISNumber == nil || [m_ISNumber isEqualToString:@""])
		nRetCode	= kSendISNumber_ERROR;
	*pErrorMsg	= [NSString stringWithFormat:
				   @"IP_amIOkay contained an error : retCode = %d",
				   nRetCode];
	if (nRetCode == kSuccessCode) 
	{
		nRetCode	= [self handleReply:f_IP_amIOkay( UID, [m_ISNumber UTF8String] )
							ErrorMsg:pErrorMsg
							FailCode:kIP_AmIOkey_Fail];
		if (nRetCode != kSuccessCode) 
            [delegate writeDebugLog:[NSString stringWithFormat:
									 @"PuddingPDCA Framework : CheckAmIOKey not succeed (%@)",
									 *pErrorMsg]];
	}
    else
        [delegate writeDebugLog:[NSString stringWithFormat:
								 @"PuddingPDCA Framework : CheckAmIOKey not in (%@)",
								 *pErrorMsg]];
	return nRetCode;
}

/**
 description	: extract the info from gh_station_info.json file
 eGHStationInfo : which info you wanna get (such as : IP_STATION_TYPE)
 strValue       : returned value
 Add by Leehua on 2011-11-15. */
-(UInt8)getGHStationInfo:(enum IP_ENUM_GHSTATIONINFO)eGHStationInfo
				strValue:(NSString**)strValue
			errorMessage:(NSString**)pErrorMsg
{
    UInt8	nRetCode	= kSuccessCode;
	if (m_bUUTStart)
	{
		size_t	sLength	= 0;
		*pErrorMsg	= @"IP_getGHStationInfo contained an error when pointer is NULL";
		nRetCode	= [self handleReply:f_IP_getGHStationInfo( UID, eGHStationInfo,NULL,&sLength )
							ErrorMsg:pErrorMsg
							FailCode:kIP_GetGhInfoFail];
		if(kSuccessCode == nRetCode && sLength>0)
		{
			//allocate the memory buffer and pass it again with correct length again
            char	*cpValue	= malloc(sLength+1);
            nRetCode	= [self handleReply:f_IP_getGHStationInfo( UID, eGHStationInfo,&cpValue,&sLength )
								ErrorMsg:pErrorMsg
								FailCode:kIP_GetGhInfoFail];
            if(nRetCode == kSuccessCode)  
                if (cpValue!=NULL)
					*strValue=[NSString stringWithUTF8String:(const char *)cpValue];
            free(cpValue);
            cpValue	= NULL;
            sLength	=0;
		}
	}
	else
		nRetCode	= kIP_UUTStart_Fail;
	return nRetCode;
}

@end



@implementation TTestItemList

@synthesize mainItem	= m_MainItem;
@synthesize subItem		= m_SubItem;
@synthesize subsubItem	= m_SubsubItem;
@synthesize testValue	= m_TestValue;
@synthesize lowLimit	= m_LowLimit;
@synthesize highLimit	= m_HighLimit;
@synthesize units		= m_Units;
@synthesize testResult	= m_TestResult;
@synthesize priority	= m_Priority;
@synthesize errCode		= m_ErrCode;

- (void)dealloc
{
	[m_MainItem		release];	m_MainItem		=	nil;
    [m_SubItem		release];	m_SubItem		=	nil;
	[m_SubsubItem	release];	m_SubsubItem	=	nil;
    [m_TestValue	release];	m_TestValue		=	nil;
    [m_LowLimit		release];	m_LowLimit		=	nil;
    [m_HighLimit	release];	m_HighLimit		=	nil;
    [m_Units		release];	m_Units			=	nil;
    [m_ErrCode		release];	m_ErrCode		=	nil;
	[super dealloc];
}

@end




