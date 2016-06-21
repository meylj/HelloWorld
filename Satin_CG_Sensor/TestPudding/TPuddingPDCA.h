//
//  TPuddingPDCA.h
//  TestPudding
//
//  Created by 吳 枝霖 on 2009/9/7.
//  Copyright 2009 PEGATRON. All rights reserved.
//



#import <Cocoa/Cocoa.h>
#import "DoLoadingLF.h"
#import "ErrorCode.h"
#include <stdio.h>

NSString * descriptionOfGHStationInfo(enum IP_ENUM_GHSTATIONINFO item);

//Leehua
// =============================================================================
#ifndef writeDebug
#define writeDebug
@protocol writeDebugLog
-(void)writeDebugLog:(NSString *)szFirstParam;
@end
#endif



@interface TPuddingPDCA : NSObject
{
    //delegate for writing debug log
    id<writeDebugLog>	delegate;
    
	BOOL				m_bUUTStart;
	NSString			*m_Version;

    NSMutableString		*m_ToolVer;
	NSMutableString		*m_ToolName;
	NSMutableString		*m_ISNumber;
	NSMutableString		*m_Limits;
	NSMutableArray		*m_TestItemList;
	NSMutableDictionary	*m_RequireAttributes;
    
    //2012.11.1 modify by yaya.Sensor need call twice pudding to upload data.
    BOOL                m_bIsFirstTime;

	// PDCA variant
	IP_UUTHandle		UID;
    BOOL				haveSetISN;// Add by Lorky on 2011-10-09, To check whether have set ISN
}

// Add by Lorky on 2011-10-09
@property (readonly, assign)	BOOL				haveSetISN;
@property (assign)				id<writeDebugLog>	delegate;//define a property , can use get and set

/**	return Pudding Library version. */
-(NSString*)getPuddingVersion;
/**	return PuddingPDCA Framework version. */
-(NSString*)getInterfaceVersion;
/**
 pVersion		: Testing Tool Version
 pName			: Test Tool Name
 pIdentifier    : Station Name
 description	: Must use it at begin for every time. */
-(UInt8)StartPDCA_Flow;
/**
 pVersion		: Testing Tool Version
 pName			: Test Tool Name
 pLimits		: Test Script Version
 description	: Set initialize paramter. */
-(void)SetInitParamter:(NSString*)pVersion
		  STATOIN_NAME:(NSString*)pName
	   SOFTWARE_LIMITS:(NSString*)pLimits;
/**
 pISN			: DUT's serial number
 description	: Assign test DUT's serail number and Check Serial is correct or not. */
-(UInt8)SetPDCA_ISN:(NSString*)pISN;
/**
 pCLCD_ID		: Display Key Value, if value is @"", it will ignore.
 description	: set require attributes for QT station. */
-(void)SetQT_Attributes:(NSString*)pAttribute
					Key:(NSString*)szKey;
/**
 pMainItem		: Test item name
 pSubItem		: if it has sub test can setting else send null value
 pSubsubItem	: if it has sub sub test can setting else send null value
 pValue			: Test result
 pLLimit		: Low Limit of Spec.
 pHLimit		: High Limit of Spec.
 pUnits			: Measure value units
 pPriority		: IP_PDCA_PRIORITY
 pErrCode		: Error Code or Error Message
 pResult		: Result of Test item, YES : PASS, NO : FAIL
 description	: Test item status. */
-(void)SetTestItemStatus:(NSString*)pMainItem
				 SubItem:(NSString*)pSubItem
			  SubSubItem:(NSString*)pSubsubItem
			   TestValue:(NSString*)pValue
				LowLimit:(NSString*)pLLimit
			   HighLimit:(NSString*)pHLimit
			   TestUnits:(NSString*)pUnits
				 ErrDesc:(NSString*)pErrCode
				Priority:(NSInteger)pPriority
			  TestResult:(BOOL)pResult;
/**
 strZipName		: Full ZIP Path Name, Please put file under \tmp folder
 aryFiles		: Need to package file name
 description	: Make ZIP file. */
-(UInt8)MakeBlobZIP_File:(NSString*)szFileName
				FileList:(NSArray*)pAryFileList;
/**
 strZipName		: Full ZIP Path Name
 FolderPath		: Need to package file of folder path
 description	: Make ZIP file in the folder. */
-(UInt8)MakeBlobZIP_File:(NSString*)szFileName
			  FolderPath:(NSString*)pFolderName;
/**
 pResult		: result of Test process
 pTestLogCSV	: Test result CSV file
 pErrorMsg		: Pudding Error Message
 description	: Send Test result to PDCA System. */
-(UInt8)CompleteTestProcess:(NSString*)pTestLogCSV 
				   ErrorMsg:(NSString**)pErrorMsg;
//Add for uploading more than one zip file to PDCA
-(UInt8)FinishTestProcess:(NSArray*)pAryTestLogCSV
				 ErrorMsg:(NSString**)pErrorMsg;
/**
 iFixID         : fixture group id
 iHeadID        : fixture or dut id in one group
 description	: Set DUT in which slot. */
-(UInt8)SetTestSlotID:(enum IP_ENUM_FIXTURE_ID)iFixID
			   HeadId:(enum IP_ENUM_FIXTURE_HEAD_ID)iHeadID;
/**
 when we after call IUUTStart and before the IUUTCommit, if we want to pause the testing,
 we need to call this function, to notice pudding to cancel this cycle. by Howard. */
-(UInt8)Cancel_Process;
/**
 description	: Assign test DUT's progress is OK or not
 pErrorMsg		: Pudding Error Message
 Add by Lorky on 2011-10-04. */
-(UInt8)CheckAmIOKey:(NSString**)pErrorMsg;
/**
 description	: extract the info from gh_station_info.json file
 eGHStationInfo : which info you wanna get (such as : IP_STATION_TYPE)
 strValue       : returned value
 Add by Leehua on 2011-11-15. */
-(UInt8)getGHStationInfo:(enum IP_ENUM_GHSTATIONINFO)eGHStationInfo
				strValue:(NSString**)strValue
			errorMessage:(NSString **)pErrorMsg;
@end



@interface TTestItemList : NSObject
{
	NSString	*m_MainItem;
	NSString	*m_SubItem;
	NSString	*m_SubsubItem;
	NSString	*m_TestValue;
	NSString	*m_LowLimit;
	NSString	*m_HighLimit;
	NSString	*m_Units;
	BOOL		m_TestResult;
	NSInteger	m_Priority;
	NSString	*m_ErrCode;
}

@property (copy, readwrite) NSString	*mainItem;
@property (copy, readwrite) NSString	*subItem;
@property (copy, readwrite) NSString	*subsubItem;
@property (copy, readwrite) NSString	*testValue;
@property (copy, readwrite) NSString	*lowLimit;
@property (copy, readwrite) NSString	*highLimit;
@property (copy, readwrite) NSString	*units;
@property (copy, readwrite) NSString	*errCode;
@property (readwrite) BOOL	testResult;
@property (readwrite) NSInteger priority;

@end




