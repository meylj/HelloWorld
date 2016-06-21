//
//  TestProgress.m
//  FunnyZone
//
//  Created by Lorky on 3/30/11.
//  Copyright 2011 PEGATRON. All rights reserved.
//

#import "TestProgress.h"
#import "CB_TestBase.h"
#import "IADevice_CB.h"
#import "IADevice_DetectPort.h"

// auto test system(global var)
BOOL    gbIfNeedRemoteCtl   = NO;
BOOL    isRaft = NO;
NSString * const TEST_FINISHED = @"Test_Finished";

// 2012.2.20 Desikan 
//      Prox-Cal show ready bug(finished test,before plug out unit,ui show READY,but not PASS/FAIL),
NSString * const PostDataToMuifaNote    =   @"postDataToMuifa";

// 2012.4.21 Sky
//      Separate iPad-1 show voltage of the unit from Prox-Cal show ready bug. 
NSString * const ShowVoltageOnUI        =   @"showVoltageOnUI";

NSString * const BNRElderBrotherNotification = @"ElderBrother";
NSString * const BNRYoungBrotherNotification = @"YoungBrother";
NSString * const BNRKeyBoardPressedNotification = @"KeyBoardPressed";
NSString * const BNRAllPatternReadyOrNotNotification = @"AllPatternReadyOrNot";
NSString * const BNRTransferToMuifaNotification = @"TransferToMuifa";
NSString * const BNRDrawerOKClickedNotification = @"DrawerOKClicked";
NSString * const BNRMonitorProxCalUUT1Notification = @"MonitorProxCalUUT1";

//extern NSString *BNRTestProgressPopWindow;
//extern NSString *BNRTestProgressQuitWindow;


@implementation TestItemStruct

@synthesize ItemName;
@synthesize TestSort;

- (void)dealloc
{
	[ItemName release];
	[TestSort release];
	[super dealloc];
}

@end


@implementation TestProgress
@synthesize m_szMuifaUIMode;
@synthesize m_szUIVersion,m_szScriptVersion,m_szStartTime;//startTime
@synthesize m_bAbort;//m_bPause,
@synthesize m_bPatnRFromUI;
@synthesize MobileSerialNumber = m_szISN;//ISN
@synthesize arrayScript = m_arrayScript;//script
@synthesize ScriptName = m_szScriptName;

@synthesize m_dicPorts;//port
@synthesize m_dicMemoryValues;//save variables
@synthesize m_szPortIndex;//for multi , in single it's set as 0

@synthesize m_iStatus;//for multiUI to control status(running, finish...)
@synthesize isCheckedPDCA = m_bIsCheckedPDCA;//For has checked PDCA or not.

@synthesize m_bNoResponse;//Leehua

@synthesize m_StopFlag;
@synthesize m_ReturnValue;

@synthesize m_szStatusColor;

@synthesize m_dicNoResponse;
@synthesize m_aryDisplayName;
@synthesize m_bDisplayMode;
@synthesize m_bMonitorIn;
@synthesize m_iFlagIn;
@synthesize m_bMonitorOut;
@synthesize m_iFlagOut;
@synthesize m_szFilePath;
@synthesize m_bUploadFile;
@synthesize m_aryFile;
@synthesize m_bRemoveFile;
@synthesize m_szRemoveFilePath;



#pragma mark +++++++++++++++    Notifications      ++++++++++++++++
// Description	:
//
//		Post some information to UI. The notification name is TestItemInfoNotification.
//
// Parameter	:
//
//		dictTestInfo	--->		NSDictionary	:	a dictionary that include some information with keys.
//													You may find the keys at the publicDefine.h file.
- (void)postTestInfoToUI:(NSDictionary *)dictTestInfo
{	
	NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
	[nc postNotificationName:TestItemInfoNotification object:self userInfo:dictTestInfo];
}
#pragma ++++++++++++++++++       Body Implement            ++++++++++++++++++

- (id)init
{
	if (self = [super init])
	{
        //variables initialization
        // CT2 3-up related
        m_bEnableKeyDown    = NO;
        m_bNextPattern      = NO;
        m_bLastPattern      = NO;
        m_bAllPatternReady  = NO;
        m_bCT2PatternFail   = NO;        
        m_bIsFinished       = NO;    
        m_bIsCheckedPDCA    = NO;
        m_iElderBrother     = BROTHER_ERROR;
        m_bYoungBrother     = NO;
        m_bIsElderBrotherPort = NO;
        
        m_bDisplayMode   = YES;
        
        
		m_szReturnValue     = [[NSMutableString alloc] initWithString:@""];
        m_szErrorDescription= [[NSMutableString alloc] initWithString:@""];//err of each case
        m_szFailLists       = [[NSMutableString alloc] initWithString:@""];
        m_strSpecName		= [[NSMutableString alloc] initWithString:@""];
		m_strConsoleMessage = [[NSMutableAttributedString alloc] initWithString:@""];
        //port number for multi , in single it's set as 0
        m_szPortIndex       = [[NSMutableString alloc] initWithString:@"0"];//Leehua 11-9-7
        m_dicLogPaths       = [[NSMutableDictionary alloc] init];
        
        m_dicMemoryValues   = [[NSMutableDictionary alloc] init];
        m_aryDisplayName    = [[NSArray alloc] init];
        
        //background color of each device for Uart log in uart tableview , we can set color for each device in setting file (such as mobile=>WHITE,fixture=>RED....,you must set color included in below dictionary
        m_dictPortColor = [[NSDictionary alloc ] initWithObjectsAndKeys:
                           [NSColor whiteColor],	kFZ_UartTableview_WHITE, 
                           [NSColor redColor],		kFZ_UartTableview_RED,
                           [NSColor greenColor],	kFZ_UartTableview_GREEN,
                           [NSColor blueColor],		kFZ_UartTableview_BLUE,
                           [NSColor yellowColor],	kFZ_UartTableview_YELLOW,
                           [NSColor orangeColor],	kFZ_UartTableview_ORANGE, nil];

        //for multiUI to control status(running, finish...)
        m_iStatus           = kFZ_MultiStatus_None;

		
		
        //object initialization
        m_objPudding = [[TPuddingPDCA alloc] init];  
        [m_objPudding setDelegate:self];
        
        m_CB_TestBase = [[CB_TestBase alloc] init];//Leehua 11.09.09 add for new cb function
        
        m_mathLibrary = [[MathLibrary alloc] init];
        
        //for DisplayPort
        m_arrDisplayPortData = [[NSMutableArray alloc] init];
        
        m_bFinalResult = YES;
        //for record testResult of on sub item (such as OPEN_UART...)
        m_bSubTest_PASS_FAIL = YES;
        
        //flag for Pattern CG
        m_bPatnRFromUI = YES;
        m_iPatnRFromFZ = kFZ_Pattern_NoMsg;
        
        //add notification
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(PatternResultFromFixture:) name:TiltFixtureNotificationToFZ object:nil];
        
        //for CPAS camispfailcount
        m_bNeedJudgeFailReceive = NO;
        
        //for will be failed case
        m_dicForceFaileCase =[[NSMutableDictionary alloc] init];
        
        //for will be passed case
        m_dicForcePassCase  = [[NSMutableDictionary alloc] init];
        
        //for will be cancel case
        m_muArrayCancelCase = [[NSMutableArray alloc] init];
        
        //pudding canceled
        m_bIsPuddingCanceled = NO;
        
        //for update unit to PDCA
        m_szUnit = [[NSMutableString alloc] initWithString:@""];
        
        //for NetWork CB Station Result
        m_dicNetWorkCBStation = [[NSMutableDictionary alloc] init];
        
        //2012 7 16 torres add for MagnetSpine exception spec
        m_exceptCount = 0;
        
        //for CT 4UP
        m_bForceResult = NO;
        
        m_bNoResponse = NO;//Leehua
        
        // for prox cal
        m_bHasTestedSlot1 = NO;
        
        m_objPrint = [[Printer alloc]init];
        
        //memory the times that command no respose
        m_dicNoResponse     = [[NSMutableDictionary alloc]init];
        m_dicEmptyResponse  = [[NSMutableDictionary alloc] init];
        // Do not write log
        NSDictionary *dicSettings = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/Library/Preferences/Muifa.plist", NSHomeDirectory()]];
        bNoNeedWriteCSV = [[self getValueFromXML:dicSettings mainKey:kPD_UserDefaults_NoNeedCSV,nil] boolValue];
        bNoNeedWriteUart = [[self getValueFromXML:dicSettings mainKey:kPD_UserDefaults_NoNeedUart,nil] boolValue];
        bNoNeedWriteDebug = [[self getValueFromXML:dicSettings mainKey:kPD_UserDefaults_NoNeedDebug,nil] boolValue];
        m_bNoNeedWriteConsole = [[self getValueFromXML:dicSettings mainKey:kPD_UserDefaults_NoNeedConsole,nil] boolValue];
    
        m_iBigTestCaseFrom = 0;
        m_iBigTestCaseTo = 0;
        
        m_bMonitorIn = NO;
        m_iFlagIn = 1;
        m_iFlagOut = 1;
        m_bMonitorOut = NO;
        
        //upload file select by self or upload log
        m_bUploadFile = NO;
        m_szFilePath = [[NSMutableString alloc] initWithString:@""];
        m_szRemoveFilePath = [[NSMutableString alloc] initWithString:@""];
        m_aryFile = [[NSMutableArray alloc] init];
        m_bRemoveFile = NO;
	}
	return self;
}

- (void)dealloc
{
    //release for property
	[m_szUIVersion			release];
    [m_szScriptVersion      release];
	[m_szISN				release];
	[m_szStartTime			release];
	[m_arrayScript          release];
    [m_dicPorts             release];
    [m_szScriptName			release];
	
    //release which alloc int init
    [m_szReturnValue        release];
    [m_szErrorDescription   release];
    [m_szFailLists          release];
    [m_strSpecName          release];
    [m_strConsoleMessage	release];
    [m_dicMemoryValues      release];
    [m_szPortIndex			release];//Leehua 11-9-7
    [m_dicLogPaths          release];
    [m_dictPortColor        release];
    
    [m_objPudding           release];
    [m_CB_TestBase          release];
    [m_mathLibrary          release];
    [m_objPrint             release];
    
    [m_arrDisplayPortData   release];
    [m_dicForceFaileCase    release];
    [m_dicForcePassCase     release];
    [m_muArrayCancelCase    release];
    [m_dicNetWorkCBStation  release];
    [m_dicEmptyResponse     release];
    [m_dicNoResponse        release];
    [m_szUnit               release];
    
    [m_szFilePath release];
    [m_aryFile release];
	[super dealloc];
}

//get stationINfo
- (NSDictionary *)getStationInfo
{
    NSMutableDictionary *dicGhInfo = [[NSMutableDictionary alloc] init];
    TPuddingPDCA *pdObj = [[TPuddingPDCA alloc] init];
    [pdObj StartPDCA_Flow];
    uint8 iRet = kSuccessCode;
    //enum IP_ENUM_GHSTATIONINFO ghInfo = 0;
    NSString *szValue = @"";
    NSString *szError = @"";
    for (NSInteger iIndex=1; iIndex<IP_GHSTATIONINFO_COUNT; iIndex++)
    {
        NSString *szKey = [NSString stringWithFormat:@"GHIF_%d",iIndex];
        iRet = [pdObj getGHStationInfo:iIndex strValue:&szValue errorMessage:&szError];
        if (iRet == kSuccessCode && ![szValue isEqualToString:@""])
        {
            [dicGhInfo setObject:szValue forKey:szKey];
            szValue = @"";
        }
        else
        {
            [dicGhInfo setObject:@"" forKey:szKey];
        }
        //ATSDebug(@"getGHStationInfo : %@ = %@",szKey , [dicGhInfo objectForKey:szKey]);
    }
    [pdObj Cancel_Process];
    NSDictionary *dicGhStInfo = [NSDictionary dictionaryWithDictionary:dicGhInfo];
    [pdObj release];
    [dicGhInfo release];
    return dicGhStInfo;
}

//parser script file such as QT0b.plist , we'd better call it in awakeFromNib in UI(once)
//script file format : first level=>array, second level=>dictionary(just contains one key:such as START_TEST_QT0b), third level=>array, fourth level=>dictionary(just contains one key:such as OPEN_UART)
- (NSArray *)parserScriptFile:(id)ScriptFile
{
	NSArray * arrTestItems = [ScriptFile isKindOfClass:[NSArray class]]? ScriptFile: [NSArray arrayWithContentsOfFile:ScriptFile];//first level
	if (!arrTestItems)
	{
		NSRunAlertPanel(@"错误(Error)", @"解析剧本档失败。(Parser Script Fail)", @"确认(OK)", nil, nil);
        //modify from ATSDebug to NSLog , because this function may move to awakefromnib in UI , and console log isn't created
		NSLog(@"Terminate at [%@], Parser Script fail, Get Nil array from the path [%@]", [[NSDate date] description], ScriptFile);
		[NSApp terminate:nil];
		return nil;
	}
	NSMutableArray * arrTestItemTemp = [[NSMutableArray alloc] init];
	for (NSDictionary *dict in arrTestItems)//second level
	{
        if(![dict isKindOfClass:[NSDictionary class]] || 1 != [dict count])
        {
            NSRunAlertPanel(@"错误(Error)", [NSString stringWithFormat:@"剧本档格式错误: %@ (Script file format error : [%@].)",dict,dict], @"确认(OK)", nil, nil);
            NSLog(@"Terminate at [%@], Script file format error : [%@] , Please connect with ATS", [[NSDate date] description], dict);
            [NSApp terminate:nil];
        }
		TestItemStruct * obj_Struct = [[TestItemStruct alloc] init];
		NSString *szTestItemName = @"";
		NSEnumerator *enumerator = [dict keyEnumerator];
		id key;//such as START_TEST_QT0b
		while ((key = [enumerator nextObject])) //I think this execute once at most ,Leehua
		{
			if ([[dict objectForKey:key] isKindOfClass:[NSArray class]])
			{
				szTestItemName = key;
				NSArray * arrSubItem =  [dict objectForKey:key];//third level
				for (NSUInteger i = 0; i < [arrSubItem count]; i++)
				{
					id idObj = [arrSubItem objectAtIndex:i];//fourth level
					if (![idObj isKindOfClass:[NSDictionary class]] || 1 != [idObj count])
					{
                        NSRunAlertPanel(@"错误(Error)", [NSString stringWithFormat:@"剧本档格式错误: %@ (Script file format error : [%@].)",szTestItemName,szTestItemName], @"确认(OK)", nil, nil);
						NSLog(@"Terminate at [%@], Script file format error : [%@] SubItem Error, Please connect with ATS", [[NSDate date] description], szTestItemName);
						[NSApp terminate:nil];
					}
				}
				obj_Struct.ItemName = szTestItemName;
				obj_Struct.TestSort	= arrSubItem;
				[arrTestItemTemp addObject:obj_Struct];
			}
			else
				continue;//sub items wasn't saved as array, this item won't be executed
		}
		[obj_Struct release];
	}
    NSArray * arrayReturn = [NSArray arrayWithArray:arrTestItemTemp];
	[arrTestItemTemp release];
    return arrayReturn;
}

// Description	:
//
//		Test one sub item. For example: SENDCOMMAND:; READ_COMMAND:RETURN_VALUE:; .ect, It will post sub item test result to debug table view on UI.
//
// Parameter	:
//
//		dictItem		--->		NSDictionary	:	The dictionary that include all sub test item dictionary.
//													The key is full name of sub test item.
//		szSubName		--->		NSString		:	Sub test item full name.
//		szLimit			--->		NSString		:	Parent test item limit. Here may response JUDGE_SPEC function.
//
// Return Value	:
//
//		YES				--->		BOOL			:	single sub item test pass(all sub test items test pass).
//		NO				--->		BOOL			:	single sub item test fail(some sub test items test fail).
//
- (BOOL)performSELToClass:(NSDictionary *)dictItem SubItemName:(NSString *)szSubName ItemName:(NSString *)szItemName
{
    ATSDebug(@"^=^ Begin subItem : %@ ===> parameters:\n{\n%@}",szSubName,[self formatLog_transferObject:dictItem]);
    
    NSDate *date = [NSDate date];//begin time
    NSTimeInterval timeDuration = 0.0;
    
	NSNumber * numSubItemResult = [NSNumber numberWithBool:YES];
         
	SEL selectorForFunction = NSSelectorFromString(szSubName);
    //Judge whether our programe can response the function 
	if ([self respondsToSelector:selectorForFunction])
	{        
        numSubItemResult = [self performSelector:selectorForFunction withObject:dictItem withObject:m_szReturnValue];
    }
	else
	{
        NSRunAlertPanel(kFZ_PanelTitle_Error, [NSString stringWithFormat:@"无法响应函数: %@。(Can't response function [%@])",szSubName,szSubName], @"确认(OK)", nil, nil);
        return NO;
	}
	
    timeDuration = [[NSDate date] timeIntervalSinceDate:date];//end time
	NSString *szResult = [numSubItemResult boolValue]?@"PASS":@"FAIL";
    NSString *szTitle = [NSString stringWithFormat:@"%@ (TestResult : %@ ; Duration : %.6fs)",szSubName,szResult,timeDuration];
	
	ATSDebug(@"RETURN_VALUE ===> %@\n%@",m_szReturnValue,[self formatLog:@"+" title:szTitle]);
    
    //Winter 2012.4.18
	//Write cycle time log,add for each sub test item
    if(![[self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_NoCycleTimeLog,nil]boolValue])
    {
        NSString *szTarget = @"";
        NSString *szCommand = @"";
        NSString *szCycleTimeName = [NSString stringWithFormat:@"%@/%@_%@_CycleTime.csv",kPD_LogPath_CycleTime,m_szPortIndex,m_szStartTime];
        NSString *szParameter = [self formatLog_transferObject:dictItem];
        NSArray *aryParameter = [szParameter componentsSeparatedByString:@"\n"];
        //judge which target you used to send/read or open/close and write to the cycle time log, and write the command you send into the log
        if ([szSubName isEqualToString:@"SEND_COMMAND:"]) 
        {
            for(NSString *szValue in aryParameter)
            {
                if ([szValue ContainString:@"TARGET ==>"]) {
                    szTarget = [szValue SubFrom:@"TARGET ==> " include:NO];
                }
                if ([szValue ContainString:@"STRING ==>"]) {
                    szCommand = [szValue SubFrom:@"STRING ==> " include:NO];
                    szCommand = [szCommand stringByReplacingOccurrencesOfString:@"," withString:@" "];
                }
            }
        }
        
        if([szSubName isEqualToString:@"READ_COMMAND:RETURN_VALUE:"])
        {
            for(NSString *szValue in aryParameter)
            {
                if ([szValue ContainString:@"TARGET ==>"]) {
                    szTarget = [szValue SubFrom:@"TARGET ==> " include:NO];
                }
            }
        }
        
        if([szSubName isEqualToString:@"OPEN_TARGET:"])
        {
            for(NSString *szValue in aryParameter)
            {
                if ([szValue ContainString:@"TARGET ==>"]) {
                    szTarget = [szValue SubFrom:@"TARGET ==> " include:NO];
                }
            }
        }
        
        if([szSubName isEqualToString:@"CLOSE_TARGET:RETURN_VALUE:"])
        {
            for(NSString *szValue in aryParameter)
            {
                if ([szValue ContainString:@"TARGET ==>"]) {
                    szTarget = [szValue SubFrom:@"TARGET ==> " include:NO];
                }
            }
        }
        
        NSString *szBeginLog = [NSString stringWithFormat:@",%@,%@,%.6fs,%@,%@\n",szResult,szSubName,timeDuration,szCommand,szTarget];
        [IALogs CreatAndWriteSingleCSVLog:szBeginLog withPath:szCycleTimeName];
    }
    
	return [numSubItemResult boolValue];
}

// Description	:
//	
//		Test one test item. For example : Start_Test_QT1, End_Test_QT1 .ect
//
// Parameter	:
//				
//		arrDetailTest	--->		NSArray	:	Include some information about test name and detail test parameter
//
// Return Value	:
//
//		YES				--->		BOOL			:	single item test pass(all sub test items test pass).
//		NO				--->		BOOL			:	single item test fail(some sub test items test fail).
- (BOOL)singleItemTest:(NSArray *)arrDetailTest ItemName:(NSString *)szItemName currentIndex:(NSInteger)iIndex
{
	// Some vars init here	
    //BOOL bSingleTestResult = YES;
    m_bCT2PatternFail = NO;             // init no fail for CT2 pattern at begin of testing single item
    NSMutableArray *arrFailItemsName = [[NSMutableArray alloc] init];
    NSMutableArray *arrFailItemsMSG = [[NSMutableArray alloc] init];
    
    //set no need upload parametricdata
    if(kPD_UserDefaults_NoParametricData)
    {
        m_bNoParametric = kPD_UserDefaults_NoParametricData;
    }
    // set init subitem test result PASS
    m_bSubTest_PASS_FAIL = YES;
	BOOL bSubItemResult = YES;
    [m_dicMemoryValues setValue:[NSNumber numberWithBool:YES] forKey:kFZ_Script_TestResult];
    
    // Write UART Log
    NSString *szStartItemLog = [self formatLog:@"=" title:[NSString stringWithFormat:@"START TEST %@ (Item%d)",[szItemName uppercaseString],iIndex]];
	ATSDebug(@"%@",szStartItemLog);    
    [IALogs CreatAndWriteUARTLog:szStartItemLog atTime:nil fromDevice:nil withPath:[NSString stringWithFormat:@"%@/%@_%@_Uart.txt",kPD_LogPath_Uart,m_szPortIndex,m_szStartTime] binary:NO];
    
    //Winter 2012.4.18
	//Write cycle time log, add for each item name
    if(![[self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_NoCycleTimeLog,nil]boolValue])
    {
        NSString *szCycleTimeName = [NSString stringWithFormat:@"%@/%@_%@_CycleTime.csv",kPD_LogPath_CycleTime,m_szPortIndex,m_szStartTime];
        NSString *szItemNameLog = [szItemName stringByReplacingOccurrencesOfString:@"," withString:@" "];
        NSString *szBeginLog = [NSString stringWithFormat:@"%d. %@,,,,,\n",iIndex,szItemNameLog];
        [IALogs CreatAndWriteSingleCSVLog:szBeginLog withPath:szCycleTimeName];
    }
    
    NSDate *dateSingleItemStart = [NSDate date];
    NSTimeInterval dSingleItemSpend = 0.0;
    m_bCancelFlag = NO;//before item start testing, set cancel flag "not allow to cancel items"
    m_bCancelNoMatterWhat = NO;
    
    NSMutableArray *aryFailSubItems = [[NSMutableArray alloc] init];
    //run sub item detail function
    for (int i = 0 ; i < [arrDetailTest count] ; i++)
    {
        //get sub item
        NSDictionary * dictSubItem = [arrDetailTest objectAtIndex:i];
		NSArray *arrKeys = [dictSubItem allKeys];
		NSString *szSubItemName = [arrKeys objectAtIndex:0]; //0:just one item
		
        //get params of sub item
		NSDictionary * dictDetailPara = [dictSubItem objectForKey:szSubItemName];
        
        // for CT2 Ants Test
        if (0 == i)
        {
            m_bLastLastItemResult = YES;
        }
        
        BOOL bAntsTest = NO;
        NSString *szTestMode = [dictDetailPara objectForKey:@"TESTMODE"];
        if (szTestMode && [szTestMode isEqualToString:@"AntsTest"])
        {
            bAntsTest = YES;
        }
        // For CT2
        if (bAntsTest)
        {
            // check all the slot has posted the same notification
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            
            do 
            {
                // wait for all slot.
                usleep(100000);
                
                [nc postNotificationName:BNRTransferToMuifaNotification object:self userInfo:dictDetailPara];

            } while (!m_bAllPatternReady);
            m_bAllPatternReady = NO;
        }
        
		// Loop sub test item function.
        NSRange rangeCancelItems = [szSubItemName rangeOfString:kFZ_Script_CancelItems];
		NSRange rangeLoopName = [szSubItemName rangeOfString:kFZ_Script_LoopItem];
        if(NSNotFound != rangeCancelItems.location && rangeCancelItems.length>0 && (rangeCancelItems.location+rangeCancelItems.length) <= [szSubItemName length])
        {
            //cancel some sub items
            if (m_bCancelFlag) 
            {
                NSInteger iCancelCount = [[dictDetailPara objectForKey:kFZ_Script_CancelCount] intValue];
                i += iCancelCount;
                m_bCancelFlag = NO;
            }
        }
		else if (NSNotFound != rangeLoopName.location && rangeLoopName.length>0 && (rangeLoopName.location+rangeLoopName.length) <= [szSubItemName length])
		{
            //if sub name equal "LoopItem" and test fail loop test some items
            NSInteger iStart=0,iEnd=0,iMaxRepeatTime=0; 
            id loopStart = [dictDetailPara objectForKey:kFZ_Script_LoopStart];
            id loopEnd = [dictDetailPara objectForKey:kFZ_Script_LoopEnd];
            id loopRepeatTime = [dictDetailPara objectForKey:kFZ_Script_LoopRepeatTime];
            NSNumber *bPassContinue = [dictDetailPara objectForKey:@"PassContinue"];
            if ((bPassContinue == nil) && /*bSingleTestResult*/m_bSubTest_PASS_FAIL) {
                continue;
            }
            if (loopStart != nil && loopEnd != nil && loopRepeatTime != nil) 
            {
                BOOL bStatus = NO;
                BOOL bResetResult = YES;
                iStart = [loopStart intValue];
                iEnd = [loopEnd intValue];
                iMaxRepeatTime = [loopRepeatTime intValue];
                
                NSMutableArray *aryLoopItems = [[NSMutableArray alloc] init];
                
                //put loop items to an array
                for(int iIndex=iStart; iIndex<=iEnd; iIndex++)
                {
                    NSDictionary * dictSubItem = [arrDetailTest objectAtIndex:iIndex];
                    [aryLoopItems addObject:dictSubItem];
                }
                
                for(int j=0; j<[aryFailSubItems count]; j++)
                {
                    if([aryLoopItems containsObject:[aryFailSubItems objectAtIndex:j]])
                    {
                        //some item need to loop, fail
                        if (bPassContinue && [bPassContinue boolValue])
                            iMaxRepeatTime = 0;
                        else
                            bStatus = YES;
                    }
                    else
                    {
                        //some item fail, but not contained marked to redo(in loop)
                        bResetResult = NO;
                    }
                }
                
                //do loop
                if((bStatus && bResetResult) || ((bPassContinue) && ([bPassContinue boolValue])))
                {
                    //if (bResetResult) {
                    //fail items all need to loop , then mark test result of this item "PASS"
                    /*bSingleTestResult*/
                    m_bSubTest_PASS_FAIL = YES;
                    //}
                    //loop
                    for (int iLoop = 0; iLoop < iMaxRepeatTime; iLoop++) 
                    {
                        //set default result of loop items "PASS"
                        bStatus = YES;                    
                        for(int j=iStart; j<=iEnd; j++)
                        {
                            NSDictionary * dictSubItem = [arrDetailTest objectAtIndex:j];
                            NSArray *arrKeys = [dictSubItem allKeys];
                            NSString *szSubItemName = [arrKeys objectAtIndex:0]; 
                            NSRange rangeCancelItems = [szSubItemName rangeOfString:kFZ_Script_CancelItems];
                            if(NSNotFound != rangeCancelItems.location && rangeCancelItems.length>0 && (rangeCancelItems.location+rangeCancelItems.length) <= [szSubItemName length])
                            {
                                if (m_bCancelFlag) {
                                    NSInteger iCancelCount = [[dictDetailPara objectForKey:kFZ_Script_CancelCount] intValue];
                                    j += iCancelCount;
                                    m_bCancelFlag = NO;
                                }
                            }
                            else
                            {
                                NSDictionary * dictDetailPara = [dictSubItem objectForKey:szSubItemName];
                                bSubItemResult = [self performSELToClass:dictDetailPara SubItemName:szSubItemName ItemName:szItemName];
                                bStatus &= bSubItemResult;
                                if([aryFailSubItems containsObject:dictSubItem])
                                {
                                    [aryFailSubItems removeObject:dictSubItem];
                                }
                            }
                        }
                        //if these items all pass ,break
                        
                        if ((bPassContinue) && ([bPassContinue boolValue])) {
                            if (!bStatus)
                                break;
                        }
                        else
                            if(bStatus)
                                break;
                    }
                    //bSingleTestResult &= bStatus;
                    m_bSubTest_PASS_FAIL &= bStatus;   
                }	
                [aryLoopItems release];                
            }
        }
		else 
		{
			bSubItemResult = [self performSELToClass:dictDetailPara SubItemName:szSubItemName ItemName:szItemName];
            if(!bSubItemResult)
                [aryFailSubItems addObject:dictSubItem];
			//bSingleTestResult &= bSubItemResult;
            m_bSubTest_PASS_FAIL &= bSubItemResult;
		}
        //m_bSubTest_PASS_FAIL = bSingleTestResult;  
        //bSingleTestResult = m_bSubTest_PASS_FAIL;
        
        //for CT2
        if (bAntsTest)
        {
            // clear the previous status for keys
            m_bNextPattern = NO;
            m_bLastPattern = NO;

            //[[NSApp mainWindow] makeFirstResponder:[[NSApp mainWindow] contentView]];

            do 
            {
                // wait for key pressed
                usleep(100000);
            } while (!(m_bEnableKeyDown && (m_bNextPattern || m_bLastPattern)));
            m_bEnableKeyDown = NO;
            
            // Pass result for next pattern
            NSString *szTestPatternName = [dictDetailPara objectForKey:@"TESTNAME"];
            NSString *szLCDFailMessage = [m_dicMemoryValues objectForKey:@"LCDFAILMSG"];
            if (m_bNextPattern)
            {
                m_bNextPattern = NO;
                bSubItemResult = YES;
                m_bSubTest_PASS_FAIL &= YES;
            }

            // Last Item result for last pattern
            if (m_bLastPattern)
            {
                m_bLastPattern = NO;
                m_bCT2PatternFail = NO; // clear the last pattern's fail items due to we'll retest it. 
                bSubItemResult = m_bLastLastItemResult;
                m_bSubTest_PASS_FAIL = m_bLastLastItemResult;
                //retest the last pattern
                if ([dictDetailPara objectForKey:@"LASTPATTERN"] && ([[dictDetailPara objectForKey:@"LASTPATTERN"] intValue] <= i)) 
                {
                    int iRollBack = [[dictDetailPara objectForKey:@"LASTPATTERN"] intValue];
                    i = i - iRollBack - 1;
                    continue;
                }            
            }
                        
            if (m_bCT2PatternFail)
            {
                bSubItemResult = NO;
                m_bSubTest_PASS_FAIL &= NO;                
            }
            
            // add fail items into dictionary
            if (!m_bSubTest_PASS_FAIL && m_bCT2PatternFail)
            {
                [arrFailItemsName addObject:szTestPatternName];
                [arrFailItemsMSG addObject:[NSString stringWithFormat:@"Fail items: %@", szLCDFailMessage]];
            }
            else
            {
                // if retest pass, remove this fail items
                if ([arrFailItemsName containsObject:szTestPatternName])
                {
                    NSUInteger iIndex = [arrFailItemsName indexOfObject:szTestPatternName];
                    [arrFailItemsName removeObjectAtIndex:iIndex];
                    [arrFailItemsMSG removeObjectAtIndex:iIndex];
                }
            }
            
            m_bCT2PatternFail = NO;
            
        }
        
        // Get the last last result, but you only can re-design the last pattern's result.
        if (0 == i)
        {
            m_bLastLastItemResult = YES;
        }
        else
        {
            m_bLastLastItemResult = m_bLastItemResult;
        }
        
        m_bLastItemResult = bSubItemResult;
        if (m_bCancelNoMatterWhat)
        {
            i = [arrDetailTest count];
            m_bCancelNoMatterWhat = NO;
            m_bCancelToEnd = YES;
        }
       
	}
    [aryFailSubItems release];   
    
    
    // for CT2 sub items' parametric data and csv log
    if ((nil != arrFailItemsName) && (0 != [arrFailItemsName count])) 
    {
        NSMutableString *szTotalFailMSG = [[NSMutableString alloc] initWithString:@"NO PASS FOR: "];
        for (int iCT2 = 0; iCT2 < [arrFailItemsName count]; iCT2++)
        {
            NSDate *dateStart = [NSDate date];
            NSString *szItemsName = [arrFailItemsName objectAtIndex:iCT2];
            NSString *szFailMSG = [arrFailItemsMSG objectAtIndex:iCT2];
            if(!m_bNoUploadPDCA && !m_bNoParametric)
            {
                [m_objPudding SetTestItemStatus:szItemsName
                                        SubItem:kFunnyZoneBlank
                                      TestValue:szFailMSG
                                       LowLimit:@"N/A"
                                      HighLimit:@"N/A"
                                      TestUnits:@""
                                        ErrDesc:@"Sub Items Fail"
                                       Priority:m_iPriority
                                     TestResult:NO];
            }
            [szTotalFailMSG appendFormat:@"%@&", szItemsName];
            NSTimeInterval dTimeSpend = [[NSDate date] timeIntervalSinceDate:dateStart];
            NSString *strTestInfo = [NSString stringWithFormat:@"%@,1,%@,N/A,N/A,%0.6fs\n",szItemsName, szFailMSG, dTimeSpend];
            if (nil != [m_dicMemoryValues objectForKey:kFunnyZoneHasSubItemParameterData]) 
            {
                [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%@%@",[m_dicMemoryValues objectForKey:kFunnyZoneHasSubItemParameterData],strTestInfo] forKey:kFunnyZoneHasSubItemParameterData];
            }
            else
            {
                
                [m_dicMemoryValues setObject:strTestInfo forKey:kFunnyZoneHasSubItemParameterData];
                
            }
        }
        
        [m_szReturnValue setString:szTotalFailMSG];
        [szTotalFailMSG release];
        [arrFailItemsMSG removeAllObjects];
        [arrFailItemsName removeAllObjects];
    }
    
    [arrFailItemsMSG release];
    [arrFailItemsName release];
    
    dSingleItemSpend = [[NSDate date] timeIntervalSinceDate:dateSingleItemStart];
    [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%.6f",dSingleItemSpend] forKey:kFZ_SingleTime];

    NSString *szResult = /*bSingleTestResult*/m_bSubTest_PASS_FAIL ? @"PASS" : @"FAIL";
    NSString *szTitle = [NSString stringWithFormat:@"END TEST %@ (TestResult : %@ ; Duration : %.6fs)",szItemName,szResult,dSingleItemSpend];
    NSString *szEndItemLog = [self formatLog:@"=" title:szTitle];
	ATSDebug(@"%@",szEndItemLog);
    
    //Winter 2012.4.18
	//Write cycle time log, add for each single item
    if(![[self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_NoCycleTimeLog,nil]boolValue])
    {
        NSString *szCycleTimeName = [NSString stringWithFormat:@"%@/%@_%@_CycleTime.csv",kPD_LogPath_CycleTime,m_szPortIndex,m_szStartTime];
        NSString *szItemNameLog = [szItemName stringByReplacingOccurrencesOfString:@"," withString:@" "];
        NSString *szBeginLog = [NSString stringWithFormat:@"Total_Test_%@,%@,,%.6fs,,\n",szItemNameLog,szResult,dSingleItemSpend];
        [IALogs CreatAndWriteSingleCSVLog:szBeginLog withPath:szCycleTimeName];
    }
    
    // Deal with return values
    [m_szReturnValue replaceOccurrencesOfString:kFunnyZoneComma withString:kFunnyZoneBlank1 options:NSCaseInsensitiveSearch range:NSMakeRange(0, [m_szReturnValue length])];//
    [m_szReturnValue replaceOccurrencesOfString:kFunnyZoneEnter withString:kFunnyZoneBlank1 options:NSCaseInsensitiveSearch range:NSMakeRange(0, [m_szReturnValue length])];
    [m_szReturnValue replaceOccurrencesOfString:kFunnyZoneNewLine withString:kFunnyZoneBlank1 options:NSCaseInsensitiveSearch range:NSMakeRange(0, [m_szReturnValue length])];
    
	return /*bSingleTestResult*/m_bSubTest_PASS_FAIL;
}

-(BOOL)isFinished
{
    return m_bIsFinished;//each test will init one testProgress , so m_bIsFinished need not be set to NO when in start function
}
// 

-(void)setDelegate
{
    //set deletegate for uart objects
    NSArray *aryDevices = [m_dicPorts allKeys];
    NSInteger iDeviceCount = [aryDevices count];
    for(NSInteger iIndex=0; iIndex<iDeviceCount; iIndex++)
    {
        PEGA_ATS_UART *uartObj = [[m_dicPorts objectForKey:[aryDevices objectAtIndex:iIndex]] objectAtIndex:kFZ_SerialInfo_UartObj];
        [uartObj setDelegate:self];
    }
}

//start the test
- (void)start
{
    // memory the times that command no response
    [m_dicEmptyResponse removeAllObjects];
    
    // auto test system (set global key for further use)
    if (gbIfNeedRemoteCtl)
    {
        [m_dicMemoryValues   setObject:@"YES" forKey:@"IS_REMOTE_MODE"];
    }else
    {
        [m_dicMemoryValues   setObject:@"NO" forKey:@"IS_REMOTE_MODE"];
    }
    
    m_bNoResponse = NO;//Leehua set default NoResponse value NO
    
    // auto test system (initial fail info)
    NSMutableString *szFailInfo = [[NSMutableString alloc] initWithString:@""];
    
    NSLog(@"testprocess:%@",self);
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(youngBrotherIsReady:) name:BNRYoungBrotherNotification object:nil];
    [nc addObserver:self selector:@selector(judgeWhichKeyPressed:) name:BNRKeyBoardPressedNotification object:nil];
    [nc addObserver:self selector:@selector(judgeAllPatternReadyOrNot:) name:BNRAllPatternReadyOrNotNotification object:nil];
    [nc addObserver:self selector:@selector(getInfomationFromDrawer:) name:BNRDrawerOKClickedNotification object:self];
    //Start, Add By Ming 20111021
    NSString *szCompanyPart = [NSString stringWithFormat:@"PEGATRON ATS\n"];
    NSString *szProject = [NSString stringWithFormat:@"PROJECT: %@\n",[m_dicMemoryValues objectForKey:kPD_GHInfo_PRODUCT]];
    NSString *szStation = [NSString stringWithFormat:@"STATION: %@\n",[m_dicMemoryValues objectForKey:kPD_GHInfo_STATION_ID]];
    NSString *szVer     = [NSString stringWithFormat:@"Overlay_Version : %@\n",m_szUIVersion];
    NSString *szBeginUart = [NSString stringWithFormat:@"%@%@%@%@",szCompanyPart,szProject,szStation,szVer];
    int iCount = 0; // to memory "RX no reponse" count
    //for measure is continous or not, if new item has DUT command, and RX normal, anew calculate iCount
    m_itemHasDUTRX = NO;

    //create and write UART Log
    [IALogs CreatAndWriteUARTLog:szBeginUart atTime:nil fromDevice:nil withPath:[NSString stringWithFormat:@"%@/%@_%@_Uart.txt",kPD_LogPath_Uart,m_szPortIndex,m_szStartTime] binary:NO];
    // create and write console log
    if (macro_W_Console) 
    {
        [IALogs CreatAndWriteConsoleInformation:szBeginUart withPath:[NSString stringWithFormat:@"%@/%@_%@_DEBUG.txt",kPD_LogPath_Console,m_szPortIndex,m_szStartTime]];
    }
    //End Ming 20111021
    
    //Winter 2012.4.18
	//Write cycle time log, add title information
    if(![[self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_NoCycleTimeLog,nil]boolValue])
    {
        NSString *szCycleTimeName = [NSString stringWithFormat:@"%@/%@_%@_CycleTime.csv",kPD_LogPath_CycleTime,m_szPortIndex,m_szStartTime];
        NSString *szBeginCycle = [NSString stringWithFormat:@"STATION: %@,Overlay_Version : %@,,,,\n",[m_dicMemoryValues objectForKey:kPD_GHInfo_STATION_ID],m_szUIVersion];
        NSString *szCycltTimeTitle = [NSString stringWithFormat:@"TestItems,Status,SubTestItems,CostTime,Commands,Target\n"];
        NSString *szBeginLog = [NSString stringWithFormat:@"%@%@",szBeginCycle,szCycltTimeTitle];
        [IALogs CreatAndWriteSingleCSVLog:szBeginLog withPath:szCycleTimeName];
    }
    
	ATSDebug(@"%@",[self formatLog:@"#" title:@"START DUT PROGRESS"]);
    
    // CSV file name;
	NSString *szCSVFileName = [NSString stringWithFormat:@"%@/%@_%@_CSV.csv",kPD_LogPath_CSV,m_szPortIndex,m_szStartTime];
	NSString *szCSVBegin	= [NSString stringWithFormat:@"TestName,Status,Value,DownLimit,UpLimit,SingleTime(s)\n"];
	NSString *szTSP			= [NSString stringWithFormat:@"TSP,0,%@_%@,,,\n",[m_dicMemoryValues objectForKey:kPD_GHInfo_PRODUCT],[m_dicMemoryValues objectForKey:kPD_GHInfo_STATION_TYPE]];
	NSString *szScript		= [NSString stringWithFormat:@"Script_Version,0,%@,,,\n",m_szScriptVersion];
	NSString *szVersion		= [NSString stringWithFormat:@"Overlay_Version,0,%@,,,\n",m_szUIVersion];
    NSString *szBeginCSV = [NSString stringWithFormat:@"%@%@%@%@",szCSVBegin,szTSP,szScript,szVersion];
	[IALogs CreatAndWriteSingleCSVLog:szBeginCSV withPath:szCSVFileName];  // write csv file
    
	// Do some init here    
    NSDate *dateStartProgress = [NSDate date];
	
	//add by betty 2012.4.24 for init m_bNoUploadPDCA value with muifa setting
	m_bNoUploadPDCA     = kPD_UserDefaults_NoPudding;

    //for Prox Cal
    dateStartTime   =   dateStartProgress;
    [m_dicMemoryValues setObject:dateStartProgress forKey:@"Single_Start_Time"];//for add SFIS
	NSString *sz_TestStatus = kFunnyZoneStatusTest;
    //add for summary log 2011.12.12
    m_szTestNames = [[NSMutableString alloc] initWithString:@""];
    m_szUpperLimits = [[NSMutableString alloc] initWithString:@""];
    m_szDownLimits = [[NSMutableString alloc] initWithString:@""];
    m_szValueList = [[NSMutableString alloc] initWithString:@""];
    //NSMutableString *szFailLists = [[NSMutableString alloc] initWithString:@""];
    m_szErrorInfo = [[NSMutableString alloc] initWithString:@""];
    NSString *szSummaryLogName = [NSString stringWithFormat:@"/vault/summary/%@_VAULT_LOG/%@_%@.csv",[m_dicMemoryValues objectForKey:kPD_GHInfo_PRODUCT],m_szScriptName,[dateStartProgress descriptionWithCalendarFormat:@"%Y%m%d" timeZone:nil locale:nil]];
    //end for summary log
    
    //set delegate for uart object for writing debug log
    [self setDelegate];
    
    //start PDCA
    //[self start_PDCA];
	if (!m_bNoUploadPDCA && [m_objPudding StartPDCA_Flow] != kFZ_InstantPudding_Success && !gbIfNeedRemoteCtl)
    {
		NSRunAlertPanel(kFZ_PanelTitle_Error, @"开始使用Pudding时发生错误。(Pudding StartPDCA Flow Error)", @"确认(OK)", nil, nil);
    }
         
    m_bHasTestedSlot1 = NO;  // For Prox Cal to memory has tested slot1 or not, default value is NO.
    
    m_szStatusColor = @"NONE";      // add for show special status color on UI  --Gordon
    BOOL b_OtherFAIL = NO;          // add for show special status color on UI  --Gordon
    
    // Do the Loop all the test items.
	for (NSUInteger i = 0; i < [m_arrayScript count]; i++)
	{
        //Set black spec as default spec
        [m_strSpecName setString:kFZ_Script_JudgeCommonBlack];
        [m_dicMemoryValues setObject:@"{N/A}" forKey:kFZ_TestLimit];
        //set default
        //Set don't cancel to end when this item test fail 
        m_bCancelToEnd = NO;
        //set not upload parimatric data of this test item
        m_bNoParametric = NO;
        //set priority
        m_iPriority = 0;
        //set unit
        [m_szUnit setString:@""];
        //set singleTest as pass
        m_bSubTest_PASS_FAIL = YES;
        //when run new item, set flag to YES.
        m_newItemFlag = YES;

        // If press the "Abort" Button, cancel to the end
		if (m_bAbort)
		{
            [m_objPudding Cancel_Process];
             m_bIsPuddingCanceled = YES;
            m_bAbort = NO; 

            int iCancelNumber = 4; //default cancel to end number = 4
           /*
            if (nil != [[m_dicMemoryValues objectForKey:kPD_Muifa_Plist] objectForKey:@"ReduceNumberOfCancelToEnd"])
            {
                iCancelNumber += [[kPD_UserDefaults objectForKey:@"ReduceNumberOfCancelToEnd"] intValue];
            }
            */
            //Modified for the multi script.
            NSDictionary    *dicCancelSetting = [kPD_UserDefaults objectForKey:@"CancelToEndSetting"];
            if (nil != dicCancelSetting) 
            {
                NSArray         *arrCancelSettingScript = [dicCancelSetting allKeys];
                for (NSString  *szStationNameTemp in arrCancelSettingScript)
                {
                    if ([szStationNameTemp isEqualToString:m_szScriptName]) 
                    {
                        iCancelNumber += [[[dicCancelSetting objectForKey:szStationNameTemp]objectForKey:@"ReduceNumberOfCancelToEnd"]intValue]; // re-setting the end number with setting on Muifa.plist.
                        break;
                    }
                }
            }
            
            if (i <= ([m_arrayScript count] - iCancelNumber))
            {
                i = [m_arrayScript count] - iCancelNumber;  // jump to the item i
                continue;
            }

		}
		
        // get current item TestItemStruct
		TestItemStruct *obj_TIS = [m_arrayScript objectAtIndex:i];
		NSString *szCurrentItemName = [obj_TIS ItemName];  // get current item name
        if (szCurrentItemName == nil) {
            szCurrentItemName = @"";
        }
        [m_dicMemoryValues setObject:szCurrentItemName forKey:kFunnyZoneCurrentItemName];
		NSArray *arrDetailTest = [obj_TIS TestSort];  // get current test item's sub items
		
        [m_szErrorDescription setString:@""];//each item initiaze err description as @""
		//===== for case fail or pass     add by Kyle 2011.12.15 =====
        if ([m_muArrayCancelCase containsObject:szCurrentItemName]) 
        {
            [m_muArrayCancelCase removeObject:szCurrentItemName];
            continue;
        }
        else if([[m_dicForceFaileCase allKeys] containsObject:szCurrentItemName])  // forceFailedCases contains currentTestItem, force the current test item result "Fail"
        {
            [m_szReturnValue setString:[NSString stringWithFormat:@"%@ fail !",[m_dicForceFaileCase objectForKey:szCurrentItemName]]];
            m_bSubTest_PASS_FAIL = NO;
            [m_szErrorDescription appendFormat:@"%@",m_szReturnValue];
            [m_dicForceFaileCase removeObjectForKey:szCurrentItemName];
        }
        else if ([[m_dicForcePassCase allKeys] containsObject:szCurrentItemName])// forcePassCase contains currentTestItem, force the current item test result "PASS"
        {
            [m_szReturnValue setString:[NSString stringWithFormat:@"%@ pass !",[m_dicForcePassCase objectForKey:szCurrentItemName]]];
            m_bSubTest_PASS_FAIL = YES;
            [m_dicForcePassCase removeObjectForKey:szCurrentItemName];
        }
        else
        {
            if ([self isCaseHidden:arrDetailTest atIndex:i])
            {
                i = i-1;
                continue;
            }
            //do the singleItemTest
            m_bSubTest_PASS_FAIL = [self singleItemTest:arrDetailTest ItemName:szCurrentItemName currentIndex:i];
        }
        //===========
        //if Rx No response continuously happened on 3 test items, stop test.
        if (!m_newItemFlag) 
        {
            iCount++;
            if (m_itemHasDUTRX) 
            {
                iCount = 1;
                m_itemHasDUTRX = NO;
            }
        }
        if (iCount == 3) 
        {
            m_bCancelToEnd = YES;
            iCount = 0;
        }
      
//        if ([m_dicMemoryValues objectForKey:@"ImageType"] != nil)
//		{
//			imageResult = [m_dicMemoryValues objectForKey:@"ImageType"];
//			[m_dicMemoryValues removeObjectForKey:@"ImageType"];
//		}
//		
        //set the current item test result
        m_bFinalResult &= m_bSubTest_PASS_FAIL;
		
		if (i == [m_arrayScript count] - 1)
		{
			if (m_bFinalResult)
				sz_TestStatus = kFunnyZoneStatusPass;
			else
				sz_TestStatus = kFunnyZoneStatusFail;			
		}
        
        //show value on UI
        if ([m_dicMemoryValues objectForKey:kFZ_UI_SHOWNVALUE] && ![[m_dicMemoryValues objectForKey:kFZ_UI_SHOWNVALUE] isEqualToString:@""]) 
        {
            [m_szReturnValue setString:[m_dicMemoryValues objectForKey:kFZ_UI_SHOWNVALUE]];
            [m_dicMemoryValues setValue:@"" forKey:kFZ_UI_SHOWNVALUE];
        }
        
        //show itemName on UI
        if ([m_dicMemoryValues objectForKey:kFZ_UI_SHOWNNAME] && ![[m_dicMemoryValues objectForKey:kFZ_UI_SHOWNNAME] isEqualToString:@""])
        {
            szCurrentItemName = [m_dicMemoryValues objectForKey:kFZ_UI_SHOWNNAME];
            [m_dicMemoryValues removeObjectForKey:kFZ_UI_SHOWNNAME];
        }
        
        //set image for "pass" and "fail"
        NSImage *imageResult =  m_bSubTest_PASS_FAIL ? [NSImage imageNamed:NSImageNameStatusAvailable] : [NSImage imageNamed:NSImageNameStatusUnavailable];
        BOOL bCofResult = [[m_dicMemoryValues objectForKey:@"Cof_Result"] boolValue];
        BOOL bMPResult = [[m_dicMemoryValues objectForKey:@"MP_Result"] boolValue];
        if (m_bSubTest_PASS_FAIL) 
        {
            if (bCofResult) 
            {
                imageResult = [NSImage imageNamed:NSImageNameStatusPartiallyAvailable];// set coco pass item image
            }
            //set for cocopass spec
            [self writeForCocoSpecName:szCurrentItemName status:bCofResult csvPath:szCSVFileName sumNames:m_szTestNames sumUpLimits:m_szUpperLimits sumDnLimits:m_szDownLimits sumValueList:m_szValueList errorDescription:m_szErrorDescription sumError:m_szErrorInfo endItem:YES saveSummary:YES saveCSV:YES uploadParametric:YES CurrentIndex:i];
            if (bMPResult) 
            {
                imageResult = [NSImage imageNamed:NSImageNameStatusAvailable];  // set normal item pass image
            }
            // set for normal spec
            [self writeForNormalSpecName:szCurrentItemName status:bMPResult csvPath:szCSVFileName sumNames:m_szTestNames sumUpLimits:m_szUpperLimits sumDnLimits:m_szDownLimits sumValueList:m_szValueList errorDescription:m_szErrorDescription sumError:m_szErrorInfo endItem:YES saveSummary:YES saveCSV:YES uploadParametric:YES CurrentIndex:i];           
        }
        else
        {
            imageResult = [NSImage imageNamed:NSImageNameStatusUnavailable]; //set fail image
            //set for cocopass spec
            [self writeForCocoSpecName:szCurrentItemName status:m_bSubTest_PASS_FAIL csvPath:szCSVFileName sumNames:m_szTestNames sumUpLimits:m_szUpperLimits sumDnLimits:m_szDownLimits sumValueList:m_szValueList errorDescription:m_szErrorDescription sumError:m_szErrorInfo endItem:YES saveSummary:YES saveCSV:YES uploadParametric:YES CurrentIndex:i];
            // set for normal spec
            [self writeForNormalSpecName:szCurrentItemName status:m_bSubTest_PASS_FAIL csvPath:szCSVFileName sumNames:m_szTestNames sumUpLimits:m_szUpperLimits sumDnLimits:m_szDownLimits sumValueList:m_szValueList errorDescription:m_szErrorDescription sumError:m_szErrorInfo endItem:YES saveSummary:YES saveCSV:YES uploadParametric:YES CurrentIndex:i];
        }
        
        //if the current item is coco pass item, change the current item name to "Cof_CurrentItemName"
        if (!bMPResult && [m_dicMemoryValues objectForKey:@"Cof_Result"] != nil) {
            szCurrentItemName = [NSString stringWithFormat:@"CoF_%@",szCurrentItemName];
        } 
        // Get the limit of test item and show them to UI
        NSString * szCurrentTestItemLimit = [m_dicMemoryValues objectForKey:kFZ_TestLimit];
        
        
        
        // set special image for IQC-MAGNET-SPINE
        NSString *strStatusColor = [m_dicMemoryValues objectForKey:kFZ_Script_StatusOnUI];
        if (strStatusColor && [strStatusColor isNotEqualTo:@""]) 
        {
            if ([strStatusColor isEqualToString:@"RED"])     //show red image on UI
            {
                imageResult = [NSImage imageNamed:NSImageNameStatusUnavailable];
                m_szStatusColor = @"RED";
            }
            else if ([strStatusColor isEqualToString:@"YELLOW"])  // show yellow image on UI
            {
                imageResult = [NSImage imageNamed:NSImageNameStatusPartiallyAvailable];
                if ([m_szStatusColor isNotEqualTo:@"RED"])
                {
                    m_szStatusColor = @"YELLOW";
                }
            }
            else if ([strStatusColor isEqualToString:@"WHITE"])  // show white image on UI
            {
                imageResult = [NSImage imageNamed:NSImageNameStatusNone];
                if ([m_szStatusColor isNotEqualTo:@"RED"] && [m_szStatusColor isNotEqualTo:@"YELLOW"])
                {
                    m_szStatusColor = @"WHITE";
                }  
            }
            else
            {
                
            }
            [m_dicMemoryValues removeObjectForKey:kFZ_Script_StatusOnUI];
        }
        else
        {
            if (!m_bSubTest_PASS_FAIL)
            {
                b_OtherFAIL = YES;
            }
        }
        
        if (b_OtherFAIL)
        {
            m_szStatusColor = @"NONE";
        }
        
        //UI relative, show the value on the UI
        NSString *szReturnValue = [NSString stringWithString:m_szReturnValue];
		NSAttributedString * szConsoleMessage = [[NSAttributedString alloc] initWithAttributedString:m_strConsoleMessage];
        
        if ([m_dicMemoryValues valueForKey:kFunnyZoneShowCoFONUI] == nil)
        {
            BOOL bDisplayMode = YES;
            if(m_bDisplayMode)
            {
                BOOL obel = NO;
                
                for (NSString * szItemName in m_aryDisplayName)
                {
                    if ([szCurrentItemName isEqualToString:szItemName])
                    {
                        obel = YES;
                        break;
                    }
                }
                if(!obel)
                {
                    bDisplayMode = NO;
                }
            }
            
            NSDictionary *dictALLView = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithBool:bDisplayMode],kAllTableViewDisplayMode,
                                         kAllTableView, kFunnyZoneIdentify,
                                         [NSString stringWithFormat:@"[%d]",i+1], kAllTableViewIndex,
                                         imageResult, kAllTableViewResultImage,
                                         szCurrentTestItemLimit, kAllTableViewSpec,
                                         szCurrentItemName, kAllTableViewItemName,
                                         szReturnValue, kAllTableViewRetureValue,
                                         [m_dicMemoryValues objectForKey:kFZ_SingleTime], kAllTableViewCostTime,
                                         [NSNumber numberWithInt:i], kFunnyZoneCurrentIndex,
                                         [NSNumber numberWithInt:[m_arrayScript count]], kFunnyZoneSumIndex,
                                         [NSNumber numberWithBool:m_bSubTest_PASS_FAIL], kFunnyZoneSingleItemResult,
                                         sz_TestStatus,kFunnyZoneStatus,
                                         m_szISN,kFunnyZoneISN,
                                         szConsoleMessage, kFunnyZoneConsoleMessage,
                                         m_szPortIndex,kFunnyZonePortIndex,nil];
            [self postTestInfoToUI:dictALLView];
        }
        else
        {
            BOOL bDisplayMode = YES;
            if(m_bDisplayMode)
            {
                BOOL obel = NO;
                
                for (NSString * szItemName in m_aryDisplayName)
                {
                    if ([szCurrentItemName isEqualToString:szItemName])
                    {
                        obel = YES;
                        break;
                    }
                }
                
                if(!obel)
                {
                    bDisplayMode = NO;
                }
            }

            if (![[m_dicMemoryValues valueForKey:kFunnyZoneShowCoFONUI] boolValue])
            {
                NSDictionary *dictALLView = [NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSNumber numberWithBool:bDisplayMode],kAllTableViewDisplayMode,
                                             kAllTableView, kFunnyZoneIdentify,
                                             [NSString stringWithFormat:@"[%d]",i+1], kAllTableViewIndex,
                                             imageResult, kAllTableViewResultImage,
                                             szCurrentTestItemLimit, kAllTableViewSpec,
                                             szCurrentItemName, kAllTableViewItemName,
                                             szReturnValue, kAllTableViewRetureValue,
                                             [m_dicMemoryValues objectForKey:kFZ_SingleTime], kAllTableViewCostTime,
                                             [NSNumber numberWithInt:i], kFunnyZoneCurrentIndex,
                                             [NSNumber numberWithInt:[m_arrayScript count]], kFunnyZoneSumIndex,
                                             [NSNumber numberWithBool:m_bSubTest_PASS_FAIL], kFunnyZoneSingleItemResult,
                                             sz_TestStatus,kFunnyZoneStatus,
                                             m_szISN,kFunnyZoneISN,
                                             szConsoleMessage, kFunnyZoneConsoleMessage,
                                             m_szPortIndex,kFunnyZonePortIndex,nil];
                [self postTestInfoToUI:dictALLView];
            }
            
            [m_dicMemoryValues removeObjectForKey:kFunnyZoneShowCoFONUI];
        }
        
        // auto test system (combine fail info)
        if (!m_bSubTest_PASS_FAIL)
        {
            [szFailInfo appendFormat:@"%@;", szCurrentItemName];
        }
        
		//add for write network cb stations into csv log
        if ([[m_dicNetWorkCBStation allKeys] count] > 0) 
        {
            NSString *szCBStationResult;
            NSArray *arrKey = [m_dicNetWorkCBStation allKeys];
            for (int iKey = 0; iKey < [arrKey count]; iKey++)
            {
                szCBStationResult = [m_dicNetWorkCBStation objectForKey:[arrKey objectAtIndex:iKey]];
                int iStatus = 1;
                if ([szCBStationResult isEqualToString:@"PASS"]) 
                {
                    iStatus = 0;
                }
                else
                {
                    iStatus = 1;
                }
                
                NSString *szCheckStationname = [NSString stringWithFormat:@"NetWork CB:%@,%d,%@,\"%@\",\"%@\",\n",[arrKey objectAtIndex:iKey],iStatus,[m_dicMemoryValues objectForKey:[arrKey objectAtIndex:iKey]], [m_dicMemoryValues objectForKey:kFZ_TestLimit_KBB], [m_dicMemoryValues objectForKey:kFZ_TestLimit_KBB]];
                [IALogs CreatAndWriteSingleCSVLog:szCheckStationname withPath:szCSVFileName];
            }
            [m_dicNetWorkCBStation removeAllObjects];
        }
		[szConsoleMessage release];
        [m_szReturnValue setString:@""];		
		[m_strConsoleMessage setAttributedString:[[[NSAttributedString alloc] initWithString:@""] autorelease]];
        
        //remove for judge spec
        [m_dicMemoryValues removeObjectForKey:kFZ_Cof_TestLimit];
        [m_dicMemoryValues removeObjectForKey:@"Cof_Result"];
        [m_dicMemoryValues removeObjectForKey:kFZ_MP_TestLimit];
        [m_dicMemoryValues removeObjectForKey:@"MP_Result"];
        if ((0 != m_iBigTestCaseFrom) && (0 != m_iBigTestCaseTo)) {
            NSMutableArray *script_temp = [[NSMutableArray alloc] initWithArray:m_arrayScript];
            [script_temp removeObjectsInRange:NSMakeRange(m_iBigTestCaseFrom, m_iBigTestCaseTo-m_iBigTestCaseFrom + 1)];
            m_arrayScript = nil;
            m_arrayScript = [[NSArray alloc] initWithArray:script_temp];
            m_iBigTestCaseTo = 0;
            m_iBigTestCaseFrom = 0;
            [script_temp release];
        }

        //if this item fail and cancel to end
        if (m_bCancelToEnd && !m_bSubTest_PASS_FAIL)
		{
            int iCancelNumber = 4; //default cancel to end number = 4
            /*
            if (nil != [[m_dicMemoryValues objectForKey:kPD_Muifa_Plist] objectForKey:@"ReduceNumberOfCancelToEnd"])
            {
                iCancelNumber += [[kPD_UserDefaults objectForKey:@"ReduceNumberOfCancelToEnd"] intValue];
            }
             */
            //Modified for the multi script.
            NSDictionary    *dicCancelSetting = [kPD_UserDefaults objectForKey:@"CancelToEndSetting"];
            if (nil != dicCancelSetting) 
            {
                NSArray         *arrCancelSettingScript = [dicCancelSetting allKeys];
                for (NSString  *szStationNameTemp in arrCancelSettingScript)
                {
                    if ([szStationNameTemp isEqualToString:m_szScriptName]) 
                    {
                        iCancelNumber += [[[dicCancelSetting objectForKey:szStationNameTemp]objectForKey:@"ReduceNumberOfCancelToEnd"]intValue];
                        break;
                    }
                }
            }
            
            if (i <= ([m_arrayScript count] - iCancelNumber))
            {
                i = [m_arrayScript count] - iCancelNumber;
            }
		}        
	}
    
    NSString *szSNLog		= [NSString stringWithFormat:@"ISN,0,%@,,,\n",m_szISN];
    NSDate *dateEnd = [NSDate date];

    double dProgressCostTime = [[m_dicMemoryValues objectForKey:@"Cost_Time"] doubleValue];
    if (!dProgressCostTime) {
        dProgressCostTime = [dateEnd timeIntervalSinceDate:dateStartProgress];
    }
	NSString *szEndInfoToCSV = [NSString stringWithFormat:@"%@Test Start Time,0,%@,,,,\nTest End Time,0,%@,,,,\nTest Cost Time,0,%fs,,,,",szSNLog,[dateStartProgress descriptionWithCalendarFormat:@"%H:%M:%S" timeZone:nil locale:nil],[dateEnd descriptionWithCalendarFormat:@"%H:%M:%S" timeZone:nil locale:nil],dProgressCostTime];
	[IALogs CreatAndWriteSingleCSVLog:szEndInfoToCSV withPath:szCSVFileName];
    
    //add for summary log 2011.12.12
    NSString *szInfo = [NSString stringWithFormat:@"%@,%@,\"%@\",\"%@\",%@,%@,BringUp%@",m_szISN,sz_TestStatus,m_szFailLists,m_szErrorInfo,[dateStartProgress descriptionWithCalendarFormat:@"%H:%M:%S" timeZone:nil locale:nil],[dateEnd descriptionWithCalendarFormat:@"%H:%M:%S" timeZone:nil locale:nil],m_szValueList];
    NSDictionary *dicInParams = [NSDictionary dictionaryWithObjectsAndKeys:[m_dicMemoryValues objectForKey:kPD_GHInfo_STATION_ID],@"stationName",m_szUIVersion,@"softVersion",m_szTestNames,@"testNames",m_szUpperLimits,@"upperLimits",m_szDownLimits,@"downLimits", nil];
    [IALogs CreatAndWriteSummaryLog:szInfo paraDictionary:dicInParams withPath:szSummaryLogName];
    [m_szErrorDescription setString:@""];
    [m_szFailLists setString:@""];
    [m_szTestNames release];
    [m_szUpperLimits release];
    [m_szDownLimits release];
    [m_szValueList release];
    [m_szErrorInfo    release];
    //end for summary log
    
    ATSDebug(@"%@",[self formatLog:@"#" title:[NSString stringWithFormat:@"END DUT PROGRESS (Duration : %.6fs)",dProgressCostTime]]);
    
	//Winter 2012.4.18
    //Write cycle time log, add for final result
    if(![[self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_NoCycleTimeLog,nil]boolValue])
    {
        NSString *szCycleTimeName = [NSString stringWithFormat:@"%@/%@_%@_CycleTime.csv",kPD_LogPath_CycleTime,m_szPortIndex,m_szStartTime];
        NSString *szFinalResult;
        if (m_bFinalResult) 
        {
            szFinalResult = @"PASS";
        }
        else
        {
            szFinalResult = @"FAIL";
        }
        NSString *szBeginLog = [NSString stringWithFormat:@"Total_TestAll,%@,,%.6fs,,\n",szFinalResult,dProgressCostTime];
        [IALogs CreatAndWriteSingleCSVLog:szBeginLog withPath:szCycleTimeName];
    }
    
    NSLog(@"TTTTTTSend Result To UI");
    // auto test system (send fail info to Robot)
    if (gbIfNeedRemoteCtl) {
        NSString *szFailInfo_Temp = @"";
        if (![szFailInfo isEqualToString:@""])
        {
            szFailInfo_Temp = [szFailInfo   SubTo:@";" include:YES];
            szFailInfo_Temp = [szFailInfo_Temp substringToIndex:[szFailInfo_Temp length]-1];
        }
        
        NSDictionary *dicResultInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:m_bFinalResult], @"Result", szFailInfo_Temp, @"Fail Info",  m_szISN, @"ISN",nil];
        [nc postNotificationName:TEST_FINISHED object:self userInfo:dicResultInfo];
        NSLog(@"Andre Post Result");
    }
    else // notify muifa to start a new detect Start Thread for manual line
    {
        [nc postNotificationName:TEST_FINISHED object:self];
    }
    
	[self endDUTPrg:dProgressCostTime TestResult:m_bFinalResult];  
    [nc removeObserver:self name:BNRElderBrotherNotification object:nil];
    [nc removeObserver:self name:BNRYoungBrotherNotification object:nil];
    [nc removeObserver:self name:BNRKeyBoardPressedNotification object:nil];
    [nc removeObserver:self name:BNRDrawerOKClickedNotification object:self];
    
    [nc removeObserver:self name:BNRAllPatternReadyOrNotNotification object:nil];
}

// end the test
- (void)endDUTPrg:(double)dStartTime TestResult:(BOOL)bResult
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //BOOL bSave = [[self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_SaveLog,nil] boolValue];//whether save log (just one flag to control all the logs)
	    
    //rename logs (replace portnumber with SN)
    [self renameLogs];
    //send data to PDCA and show result on UI    
    /*BOOL bWritePDCA = */[self write_PDCA];
    /*NSImage *imageResult =  bWritePDCA ? [NSImage imageNamed:NSImageNameStatusAvailable] : [NSImage imageNamed:NSImageNameStatusUnavailable];
    NSString *sz_TestStatus = bWritePDCA ? kFunnyZoneStatusPass : kFunnyZoneStatusFail;
    NSDictionary *dictALlView = [NSDictionary dictionaryWithObjectsAndKeys:
                   kAllTableView, kFunnyZoneIdentify,
                   [NSString stringWithFormat:@"[%d]",[m_arrayScript count]+1], kAllTableViewIndex,
                   imageResult, kAllTableViewResultImage,
                   @"{N/A}", kAllTableViewSpec,
                   @"writePDCA", kAllTableViewItemName,
                   sz_TestStatus, kAllTableViewRetureValue,
                   @"0,0002", kAllTableViewCostTime,
                   [NSNumber numberWithInt:[m_arrayScript count]], kFunnyZoneCurrentIndex,
                   [NSNumber numberWithInt:[m_arrayScript count]+1], kFunnyZoneSumIndex,
                   [NSNumber numberWithBool:bWritePDCA], kFunnyZoneSingleItemResult,
                   sz_TestStatus,kFunnyZoneStatus,
                   m_szISN,kFunnyZoneISN,
                   @"", kFunnyZoneConsoleMessage,
                   m_szPortIndex,kFunnyZonePortIndex,nil];
    [self postTestInfoToUI:dictALlView];*/
    
    //delete logs
    //Modified by Leehua on 130311
    //if (!bSave)
    if ([[m_dicMemoryValues objectForKey:kPD_GHInfo_BUILD_STAGE] isEqual:@"MP"] && [[m_dicMemoryValues objectForKey:kPD_GHInfo_LOCAL_CSV] isEqual:@"OFF"]) 
	{
        NSArray *aryAllLogs = [m_dicLogPaths allValues];
        NSInteger iLogCount = [aryAllLogs count];
        for (NSInteger iIndex=0; iIndex<iLogCount; iIndex++) {
            NSString *szLogPath = [aryAllLogs objectAtIndex:iIndex];
            if ([fileManager fileExistsAtPath:szLogPath]) 
            {
                [fileManager removeItemAtPath:szLogPath error:nil];
                //ATSDebug(@"Remove file : [%@]",szLogPath);
                NSLog(@"Remove file	:	[%@]",szLogPath);
            }
        }
	}	

    m_bNoResponse = YES;//Leehua
    
	m_iStatus = kFZ_MultiStatus_Finish;
    m_bIsFinished = YES;

    // For porx-cal
    NSDictionary *dicECID = [NSDictionary dictionaryWithObjectsAndKeys:
                             [m_dicMemoryValues objectForKey:@"LORKY_DEVICE_ECID"],@"ECIDFinishTest", nil];
    bool bIS_1_to_N =   [[self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_IS_1_to_N] boolValue];
    if (bIS_1_to_N)
    {
        if (!m_bHasTestedSlot1)
        {
            NSString *szPortPathTemp = [[[m_dicPorts objectForKey:@"MOIBLE"] objectAtIndex:0] objectForKey:@"Slot1"];
            NSDictionary *dicInfo = [NSDictionary dictionaryWithObjectsAndKeys:szPortPathTemp, @"PortPath", nil];
            [NSThread detachNewThreadSelector:@selector(wakeUpPortsForUnexpectedFail:) toTarget:self withObject:dicInfo];
        }
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:BNRMonitorProxCalUUT1Notification object:self userInfo:dicECID];
    }
	// Added by Lorky in Cpto on 2012-05-01
	// Remove all the ECID key.
	[m_dicMemoryValues removeObjectForKey:@"LORKY_DEVICE_ECID"];

}

#pragma ++++++++++++++++++       special functions            ++++++++++++++++++

// Judge value with limits and mode
// Param:
//		NSString	*szValue		: Value you want to judge
//		NSArray		*arrayLimits	: Given limits
//		int			iMode			: Spec mode. 0 = (), 1 = [], 2 = {}, 3 = (], 4 = [), 5 = <>
-(BOOL)JudgeValue:(NSString*)szValue 
	   WithLimits:(NSArray*)arrayLimits 
             Mode:(int)iMode
{
	// Basic judge
	if((![szValue isKindOfClass:[NSString class]])
	   || (![arrayLimits isKindOfClass:[NSArray class]])
	   || (iMode < 0)
	   || (iMode > 5))
	{
		return NO;
	}
	
	// Judge
	// String
	if(2 == iMode)
	{
		for(NSString *strMatch in arrayLimits)
        {
            if([strMatch isEqualToString:@"N/A"])
            {
                return YES;
            }
            NSRange range = [szValue rangeOfString:strMatch];
            if(NSNotFound != range.location && range.length>0 && (range.location+range.length) <= [szValue length])
            {
                return YES;
            }
        }
        return NO;
	}
    else if(5 == iMode)
    {
        for(NSString *strMatch in arrayLimits)
        {
            if([strMatch isEqualToString:@"N/A"])
            {
                return YES;
            }
            if([szValue isEqualToString:strMatch])
            {
                return YES;
            }
        }
        return NO;
    }
    // Number
	else
	{
        NSString *strDownLimit = [arrayLimits objectAtIndex:0];
        NSString *strUpLimit = [arrayLimits objectAtIndex:1];
        
        // to convert specs from Hex to int
        unsigned int iDownLimit;
        unsigned int iUpLimit;
        if ([strDownLimit ContainString:@"0x"])
        {
            NSScanner *scanner = [NSScanner scannerWithString:strDownLimit];
            [scanner scanHexInt:&iDownLimit];
            strDownLimit = [NSString stringWithFormat:@"%i", iDownLimit];
        }
        if ([strUpLimit ContainString:@"0x"])
        {
            NSScanner *scanner = [NSScanner scannerWithString:strUpLimit];
            [scanner scanHexInt:&iUpLimit];
            strUpLimit = [NSString stringWithFormat:@"%i", iUpLimit];
        }
        
        // to convert value from Hex to int
        double dValue = 0;
        if ([szValue ContainString:@"0x"])
        {
            NSScanner *scanner = [NSScanner scannerWithString:szValue];
            [scanner scanHexDouble:&dValue];
            szValue = [NSString stringWithFormat:@"%f", dValue];
        }
        
        
        for (int i =0;i< [szValue length]; i++)
        {
            char Digit	= [szValue characterAtIndex:i];
            if (!((Digit >='0'&&Digit <='9')||Digit =='.'||Digit =='-'))
            {
                return NO;
            }
        }
		if(2 != [arrayLimits count])
		{
			return NO;
		}
		if ([szValue isEqualToString:@"NA"]) 
		{
			return NO;
		}
       
		dValue = [szValue doubleValue];
		double	dLowerLimit	= 0;
		double	dUpperLimit	= 0;
		// Get lower limit
		if([strDownLimit isEqualToString:@""])
			dLowerLimit	= -HUGE_VAL;
		else
			dLowerLimit	= [strDownLimit doubleValue];
		// Get upper limit
		if([strUpLimit isEqualToString:@""])
			dUpperLimit	= HUGE_VAL;
		else
			dUpperLimit	= [strUpLimit doubleValue];
		// Judge
		switch(iMode)
		{
			case 0:	// ()
				if((dLowerLimit < dValue)
				   && (dValue < dUpperLimit))
                {
					return YES;
                }
				break;
			case 1:	// []
				if((dLowerLimit <= dValue)
				   && (dValue <= dUpperLimit))
                {
					return YES;
                }
				break;
			case 3:	// (]
				if((dLowerLimit < dValue)
				   && (dValue <= dUpperLimit))
                {
					return YES;
                }
				break;
			case 4:	// [)
				if((dLowerLimit <= dValue)
				   && (dValue < dUpperLimit))
                {
					return YES;
                }
				break;
			default:
				break;
		}
	}
	
	// End
	return NO;
}

-(BOOL)ParseSpec:(NSString *)szSpec
{
    // Basic judge
	if(![szSpec isKindOfClass:[NSString class]])
	{
		return NO;
	}
    if((3 > [szSpec length])
       // First character in szSpec must be '(' or '[' or '{'
       || (('(' != [szSpec characterAtIndex: 0])
           && ('[' != [szSpec characterAtIndex: 0])
           && ('{' != [szSpec characterAtIndex: 0])
           && ('<' != [szSpec characterAtIndex: 0]))
       // Last character in szSpec must be ')' or ']' or '}'
       || ((')' != [szSpec characterAtIndex: [szSpec length] - 1])
           && (']' != [szSpec characterAtIndex: [szSpec length] - 1])
           && ('}' != [szSpec characterAtIndex: [szSpec length] - 1])
           && ('>' != [szSpec characterAtIndex: [szSpec length] - 1]))
       // '{' must with '}'
       || (('{' == [szSpec characterAtIndex: 0])
           && ('}' != [szSpec characterAtIndex: [szSpec length] - 1]))
       || (('{' != [szSpec characterAtIndex: 0])
           && ('}' == [szSpec characterAtIndex: [szSpec length] - 1]))
       // '<' must with '>'
       || (('<' == [szSpec characterAtIndex: 0])
           && ('>' != [szSpec characterAtIndex: [szSpec length] - 1]))
       || (('<' != [szSpec characterAtIndex: 0])
           && ('>' == [szSpec characterAtIndex: [szSpec length] - 1])))
    {
        ATSDebug(@"JUDGE_SPEC => Spec format is not correct . ");
        return NO;
    }
    else if('{' == [szSpec characterAtIndex:0])
        iJudgeMode	= 2;
    else if(('(' == [szSpec characterAtIndex:0])
            && (')' == [szSpec characterAtIndex: [szSpec length] - 1]))
        iJudgeMode	= 0;
    else if(('[' == [szSpec characterAtIndex:0])
            && (']' == [szSpec characterAtIndex: [szSpec length] - 1]))
        iJudgeMode	= 1;
    else if(('(' == [szSpec characterAtIndex:0])
            && (']' == [szSpec characterAtIndex: [szSpec length] - 1]))
        iJudgeMode	= 3;
    else if(('[' == [szSpec characterAtIndex:0])
            && (')' == [szSpec characterAtIndex: [szSpec length] - 1]))
        iJudgeMode	= 4;
    else if('<' == [szSpec characterAtIndex:0])
        iJudgeMode  = 5;
    
    return YES;
}

// Transform keys in expressions to values in dicMemoryValues
// Key format /*???*/, ??? is the key
// Param:
//      NSString    *szKey  : An expression contains keys
//      NSString   **szValue: value form dict for the szKey
// Return:
//      BOOL   : if value is nil ,return nil
-(BOOL)TransformKeyToValue:(NSString*)szKeyString returnValue:(NSString **)szValue
{
    BOOL bRet = YES;
    // Basic judge
    if(![szKeyString isKindOfClass:[NSString class]])
    {
        *szValue = @"";
        ATSDebug(@"The key you want to transfor to value  format is not a string class!");
        return NO;
    }
    
    // Transform
    while(((NSNotFound != [szKeyString rangeOfString:kIADeviceKeyBegin].location) && ([szKeyString rangeOfString:kIADeviceKeyBegin].length>0) && ([szKeyString rangeOfString:kIADeviceKeyBegin].location+[szKeyString rangeOfString:kIADeviceKeyBegin].length) <= [szKeyString length])
          || ((NSNotFound != [szKeyString rangeOfString:kIADeviceKeyEnd].location) && ([szKeyString rangeOfString:kIADeviceKeyEnd].length>0) && ([szKeyString rangeOfString:kIADeviceKeyEnd].location+[szKeyString rangeOfString:kIADeviceKeyEnd].length) <= [szKeyString length]))
    {
        NSRange rangeKeyBegin   = [szKeyString rangeOfString:kIADeviceKeyBegin];
        NSRange rangeKeyEnd     = [szKeyString rangeOfString:kIADeviceKeyEnd];
        // Format errors, just remove it
        // catch the key between the symbol 'begin'  and 'end'
        if((NSNotFound != rangeKeyBegin.location) && (rangeKeyBegin.length>0) && (rangeKeyBegin.location+rangeKeyBegin.length) <= [szKeyString length]
           && (NSNotFound == rangeKeyEnd.location))
        {
            szKeyString   = [szKeyString stringByReplacingOccurrencesOfString:kIADeviceKeyBegin
                                                                   withString:@""];
            continue;
        }
        else if((NSNotFound == rangeKeyBegin.location)
                && (NSNotFound != rangeKeyEnd.location) && (rangeKeyEnd.length>0) && (rangeKeyEnd.location+rangeKeyEnd.length) <= [szKeyString length])
        {
            szKeyString   = [szKeyString stringByReplacingOccurrencesOfString:kIADeviceKeyEnd
                                                                   withString:@""];
            continue;
        }
        else if((rangeKeyBegin.location + rangeKeyBegin.length) > rangeKeyEnd.location)
        {
            szKeyString   = [szKeyString stringByReplacingOccurrencesOfString:kIADeviceKeyBegin
                                                                   withString:@""];
            szKeyString   = [szKeyString stringByReplacingOccurrencesOfString:kIADeviceKeyEnd
                                                                   withString:@""];
            continue;
        }
        // Transform
        NSRange rangeKey;
        rangeKey.location   = rangeKeyBegin.location + rangeKeyBegin.length;
        rangeKey.length     = rangeKeyEnd.location - rangeKeyBegin.location - rangeKeyBegin.length;
        NSString    *szKey  = [szKeyString substringWithRange:rangeKey];
        if(nil != [m_dicMemoryValues objectForKey:szKey] && ![[m_dicMemoryValues objectForKey:szKey] isEqualToString:@""])
            szKey   = [m_dicMemoryValues objectForKey:szKey];
        else
        {
            ATSDebug(@"The key's value in the dictionary is nil  or is equal to string ""  ");
            bRet = NO;
            szKey   = @"";
        }
        rangeKey.location   = rangeKeyBegin.location;
        rangeKey.length     = rangeKeyEnd.location + rangeKeyEnd.length - rangeKeyBegin.location;
        szKeyString = [szKeyString stringByReplacingCharactersInRange:rangeKey withString:szKey];
    }
    
    // End
    *szValue = [NSString stringWithFormat:@"%@",szKeyString];
    return bRet;
}

// Transform Color string to NSColor
// Param:
//		NSString			*strPortColor	: String color before transform. {WHITE, RED, GREEN, BLUE, YELLOW, ORANGE}
// Return:
//		NSColor				: NSColor after transform
-(NSColor*)TransformPortColor:(NSString*)strPortColor
{
	return [m_dictPortColor objectForKey:[strPortColor uppercaseString]];
}

//get sub objects from one dictionary
//param:
//  id                  inXml  :   dictionary you want get sub objects from
//  NSString            *inMainKey,... :    sub keys
//Return:
//  id      :           return the value you want
-(id)getValueFromXML:(id)inXml mainKey:(NSString *)inMainKey, ...
{
    id returnValue = nil;
    if([[inXml class] instancesRespondToSelector:@selector(objectForKey:)])
    {
        // the inMainKey may be included not only one key , but the back key must included in the front key
        returnValue = [inXml objectForKey:inMainKey];
        va_list ap;
        va_start(ap , inMainKey);
        if (returnValue)
        {
            NSString *nextKey = va_arg(ap, NSString *);
            while (nextKey)
            {
                // get the next's value
                returnValue = [returnValue objectForKey:nextKey];
                nextKey = va_arg(ap, NSString *);
            }
        }
        va_end(ap);
    }
    return returnValue;
}

// Get UUT Number from BSD path
// Param:
//      NSString    *szResponse : SFIS response
// Return:
//      Port Number
- (NSInteger) GetUSB_PortNum 
{
    //for Prox Cal
    bool bIS_1_to_N =   [[self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_IS_1_to_N] boolValue];
    ATSDebug(@"bIS_1_to_N => %c",bIS_1_to_N);
    NSString        *szUSB_Port;
    //for Prox Cal
    if(bIS_1_to_N)
    {
        szUSB_Port = [[[m_dicPorts valueForKey:kPD_Device_MOBILE] objectAtIndex:kFZ_SerialInfo_SerialPort] objectForKey:@"Slot1"];
    }
    else
    {
        szUSB_Port = [[m_dicPorts valueForKey:kPD_Device_MOBILE] objectAtIndex:kFZ_SerialInfo_SerialPort];
    }
	NSRange			range;
    NSString *szPortName = kPD_ModeSet_CableName;
	range = [szUSB_Port rangeOfString:szPortName];
	if (range.location == NSNotFound || range.length<=0 || (range.location+range.length) > [szUSB_Port length])
    {
		ATSDebug(@"GetUSB_PortNum => Error : %@", szUSB_Port);
		return -1;
	}
	else {
		NSUInteger	nPosition = [szPortName length] + range.location;
		NSString	*szPort_ID = [szUSB_Port substringFromIndex:nPosition];
        if ([szPort_ID isEqualToString:@"A"]) {
            szPort_ID = @"1";
        }
        if ([szPort_ID isEqualToString:@"B"]) {
            szPort_ID = @"2";
        }
		return [szPort_ID intValue];
	}
}

//cFix  :   you can input = , * ....
//szTitle : START TEST QT0b
//return(example) :  ========= START TEST QT0b ========= ; ************ START TEST QT0b *************
- (NSString *)formatLog:(NSString *)cFix title:(NSString *)szTitle
{
    NSString *szRet = @"";
    NSInteger iLineLength = 120;
    NSInteger iLength = [szTitle length];
    if (iLength>=iLineLength) {
        szRet = [NSString stringWithFormat:@"%@",szTitle];
    }
    else
    {
        NSInteger iPre = (iLineLength-iLength)/2+1;
        NSMutableString *szPre = [[NSMutableString alloc] initWithString:@""];
        for(NSInteger iIndex=0; iIndex<iPre; iIndex++)
        {
            [szPre appendString:cFix];
        }
        szRet = [NSString stringWithFormat:@"%@ %@  %@",szPre,szTitle,szPre];
        [szPre release];
    }
    return szRet;
}

//tranfer dictionary to string for writing console log
- (NSString *)formatLog_transferObject:(id)objItem
{
    NSString *szRet = @"";
    if ([[[objItem class] description] isEqualToString:@"NSCFBoolean"]) 
    {
        szRet = [NSString stringWithFormat:@"%@",objItem];
    }
    else if ([objItem isKindOfClass:[NSString class]] || [objItem isKindOfClass:[NSNumber class]] || [objItem isKindOfClass:[NSDate class]] || [objItem isKindOfClass:[NSData class]]) {
        szRet = [NSString stringWithFormat:@"%@",objItem];
    }
    else if ([objItem isKindOfClass:[NSArray class]]) 
    {
        NSMutableString *szMutRet = [[NSMutableString alloc] initWithString:@""];
        NSInteger iCount = [objItem count];
        for(NSInteger iIndex=0; iIndex<iCount; iIndex++)
        {
            NSString *szMid = [self formatLog_transferObject:[objItem objectAtIndex:iIndex]]; 
            [szMutRet appendFormat:@"Item%d=%@ ; ",iIndex,szMid];
        }
        szRet = [NSString stringWithFormat:@"%@",szMutRet];
        [szMutRet release];
    }
    else if([objItem isKindOfClass:[NSDictionary class]])
    {
        NSMutableString *szMutRet = [[NSMutableString alloc] initWithString:@""];
        NSArray *aryKeys = [objItem allKeys];
        NSInteger iCount = [aryKeys count];
        for (NSInteger iIndex=0; iIndex<iCount; iIndex++) 
        {
            NSString *szMid = [self formatLog_transferObject:[objItem objectForKey:[aryKeys objectAtIndex:iIndex]]];
            [szMutRet appendString:[NSString stringWithFormat:@"%@ ==> %@ \n",[aryKeys objectAtIndex:iIndex],szMid]];
        } 
        szRet = [NSString stringWithString:szMutRet];
        [szMutRet release];
    }
    return szRet;
}

#pragma mark ############################ CheckSum Items Begin ##############################
-(bool)IsFileExist:(NSString*)szFilePath
{
	NSFileHandle *fileHandel = [NSFileHandle fileHandleForReadingAtPath:szFilePath];
	
	if (nil == fileHandel) 
	{
		NSLog(@"IsFileExist:File[%@] does not exist!",szFilePath);
		[fileHandel closeFile];
		return NO;
	}else 
	{
		NSLog(@"IsFileExist:File[%@] does exist!",szFilePath);
		[fileHandel closeFile];
		return YES;
	}
}
//
- (NSString *)cal_checkSum:(NSString *)szFilePath
{
    NSString *szCalSum = @"";
    NSTask *task=[[NSTask alloc] init];
    NSPipe *Pipe=[NSPipe pipe];
    NSArray	*args = [NSArray arrayWithObjects:@"sha1",szFilePath,nil];
    [task setLaunchPath:@"/usr/bin/openssl"];
    [task setArguments:args];
    [task setStandardOutput:Pipe];
    [task launch];
    NSData *outData = [[Pipe fileHandleForReading]readDataToEndOfFile];
    NSLog(@"%@ => CheckSum Value:%@!",szFilePath,outData);
    [task waitUntilExit];
    int iRetCode = [task terminationStatus];
    [task release];
    if(iRetCode == 0)
    {
        NSString *strCheckSumValue = [[NSString alloc] initWithData:outData encoding:NSUTF8StringEncoding];
        NSRange range = [strCheckSumValue rangeOfString:@"="];
        NSString *szSub = @"";
        NSString *szSubSub = @"";
        if(range.location != NSNotFound && range.length>0 && [strCheckSumValue length]>=(range.location+2))
        {
            szSub = [strCheckSumValue substringFromIndex:range.location+2];
            
        }
        else{
            NSLog(@"There is no '=' in szCheckSumValue ");
        }
        range = [szSub rangeOfString:@"\n"];
        if(range.location != NSNotFound && range.length>0 && (range.location+range.length) <= [szSub length])
        {
            szSubSub = [szSub substringToIndex:range.location];
            NSLog(@"%@ => szCheckSumValue szSubSub:%@",szFilePath,szSubSub);
            szCalSum = [NSString stringWithString:szSubSub];
            NSLog(@"CheckSumValue :%@",szCalSum);
        }
        else{
            NSLog(@"There is no '\n' in szSub ");
        }
        [strCheckSumValue release];
    }
    else
    {
        NSLog(@"Calculate plist file:[%@] failCheckSum iRetCode vaule:[%d]",szFilePath,iRetCode);
    }
    return szCalSum;
}

- (BOOL)checkSum:(NSString *)szCheckSumPath withSum:(NSString *)szSum
{
    BOOL bRet = NO;
    
    if(![self IsFileExist:szCheckSumPath])
    {
        NSString * szMSG = [NSString stringWithFormat:@"[%@]不存在，请重做Groundhog. ([%@] does not exist\n Please do groundhog!)",szCheckSumPath,szCheckSumPath];
        NSRunAlertPanel(kFZ_PanelTitle_Warning, szMSG, @"确认(OK)", @"", @"");
    }
    else if(!szSum || [szSum isEqualToString:@""]){
        NSString * szMSG = [NSString stringWithFormat:@"%@检验和初始值为空，请重做Groundhog. (%@ check sum default value is empty. Please do groundhog!)",szCheckSumPath,szCheckSumPath];
        NSRunAlertPanel(kFZ_PanelTitle_Warning, szMSG, @"确认(OK)", @"", @"");
    }
    else
    {
        NSString *szCalSum = [self cal_checkSum:szCheckSumPath];
        if ([szSum isEqualToString:szCalSum]) {
            NSLog(@"%@ check sum pass!",szCheckSumPath);
            bRet = YES;
        }
        else
        {
            NSString *szMessage = [NSString stringWithFormat:@"[%@] 路径下的文件被修改，请重做Groundhog. (Somebody modified %@.\n Please do groundhog!)",szCheckSumPath,szCheckSumPath];
            NSRunAlertPanel(kFZ_PanelTitle_Warning,szMessage , @"确认(OK)", @"", @"");
        }
        
    }
    return bRet;
}
//You can call this function from UI to do checkSum , if you want to do checkSum for one file , you need to add the absolute path of this file to dicCheckSumFiles
- (BOOL)do_checkSum
{
    BOOL bRet = YES;
    NSString *szCheckSumFile = [NSString stringWithFormat:@"%@/Library/Preferences/com.PEGATRON.checksum.plist",NSHomeDirectory()];
    NSDictionary* dicCheckSumDefaultValue = [NSDictionary dictionaryWithContentsOfFile:szCheckSumFile];
    NSLog(@"CheckSumDefaultValue : %@",dicCheckSumDefaultValue);
    NSMutableDictionary *dicCheckSumFiles = [[NSMutableDictionary alloc] init];
    
    NSDictionary *dicCheckSum = [[NSUserDefaults standardUserDefaults] objectForKey:@"PlistCheckFunction"];
    NSLog(@"The CheckSum is %@",dicCheckSum);
    if (dicCheckSum)
    {
        NSArray *aryCheckSumScripts = [dicCheckSum allKeys];
        NSInteger iScriptsCountPerStation = [aryCheckSumScripts count];
        for (NSInteger iIndex=0; iIndex<iScriptsCountPerStation; iIndex++)
        {
            NSString *szScriptName = [aryCheckSumScripts objectAtIndex:iIndex];
            if ([[self getValueFromXML:dicCheckSum mainKey:szScriptName,@"NeedCheckSum",nil] boolValue])
            {
                NSString *szScriptPath = [NSString stringWithFormat:@"%@/Contents/Frameworks/FunnyZone.framework/Resources/%@"
                                          ,[[NSBundle mainBundle] bundlePath],szScriptName];
                NSString *szCheckSumKey = [self getValueFromXML:dicCheckSum mainKey:szScriptName,@"RC_Checksum_Key",nil];
                [dicCheckSumFiles setObject:szScriptPath forKey:szCheckSumKey];
            }
            else{
                NSLog(@"Do Not Need CheckSum!");
            }
        }
    }
    else{
        NSLog(@"The dicCheckSum is nil or not exiting");
    }
    //add setting file
    NSString *szSettingPath = [NSString stringWithFormat:@"%@/Library/Preferences/Muifa.plist",NSHomeDirectory()];
    [dicCheckSumFiles setObject:szSettingPath forKey:@"SettingFile"];
    
    //here to add your file which need to do checksum
    
    //check sum
    NSArray *aryCheckKeys = [dicCheckSumFiles allKeys];
    NSInteger iKeyCount = [aryCheckKeys count];
    for(NSInteger iIndex=0; iIndex<iKeyCount; iIndex++)
    {
        NSString *szKey = [aryCheckKeys objectAtIndex:iIndex];
        NSString *szFilePath = [dicCheckSumFiles objectForKey:szKey];
        NSString *szGhValue = [dicCheckSumDefaultValue objectForKey:szKey];
        
        bRet &= [self checkSum:szFilePath withSum:szGhValue];
    }
    
    [dicCheckSumFiles release];
    
    return bRet;
}

#pragma mark ############################ CheckSum Items End ##############################

- (BOOL)start_PDCA
{
    if (m_bNoUploadPDCA)
    {
        return YES;
    }
    // auto test system(NO Alert)
	if ([m_objPudding StartPDCA_Flow] != kFZ_InstantPudding_Success && !gbIfNeedRemoteCtl)
    {
		NSRunAlertPanel(kFZ_PanelTitle_Error, @"开始使用Pudding时发生错误。(Pudding StartPDCA Flow Error)", @"确认(OK)", nil, nil);
        ATSDebug(@"Pudding StartPDCA Flow Error");
        return NO;
    }
    // init the Paramter
	[m_objPudding SetInitParamter:m_szUIVersion
					 STATOIN_NAME:@"PEGA_QTx.APP"
				  SOFTWARE_LIMITS: m_szScriptVersion];
    return YES;
}


- (BOOL)set_PDCA_SN
{
    if (m_bNoUploadPDCA)
    {
        return YES;
    }
    BOOL bRet = YES;
    uint iRet = kSuccessCode;
    // judge  if SetISN already
    if (!m_objPudding.haveSetISN)
    {
        //   set the PDCA_ISN
        iRet = [m_objPudding SetPDCA_ISN:m_szISN];
        if (iRet != kSuccessCode)
        {
            NSString * strErrorCode = [NSString stringWithFormat:@"往Pudding传SN失败，测试将会强制结束，错误代码为[%d]。(Set Serial number fail, will stop test, error Code [%d])",iRet,iRet];
            
            // auto test system(NO Alert)
            // no need alert message box
            if (!gbIfNeedRemoteCtl)
            {
              
         //       [[NSNotificationCenter defaultCenter] postNotificationName:BNRTestProgressPopWindow object:nil];
                NSRunAlertPanel(kFZ_PanelTitle_IPError, strErrorCode, @"确认(OK)", nil, nil);
                
         //       [[NSNotificationCenter defaultCenter] postNotificationName:BNRTestProgressQuitWindow object:nil];
            }
            
            ATSDebug(@"Set Serial number fail, will stop test, error Code [%d])",iRet);
            [m_objPudding Cancel_Process]; // cancel_Process
            m_bIsPuddingCanceled = YES;
			m_bCancelToEnd = YES;
            bRet = NO;
        }
    }
    return bRet;
}

- (BOOL)write_PDCA
{
    if (m_bNoUploadPDCA)
    {
        return YES;
    }
    BOOL bRet = NO;
    // Pudding upload blob zip file.
    if ([self set_PDCA_SN])   // check if set PDCA SN already ,if not , set again ,return the result
    {
        NSString *szPuddingErr = @"";
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *szVersion = [NSString stringWithString:m_szUIVersion];
        NSString *szDiagVer = [m_dicMemoryValues objectForKey:@"DIAG_VER"];
        if (kPD_UserDefaults_ChangeVersion && szDiagVer)
        {
            szVersion = [NSString stringWithFormat:@"%@.%@",m_szUIVersion,szDiagVer];
        }
        [m_objPudding SetInitParamter:szVersion
                         STATOIN_NAME:@"PEGA_QTx.APP"
                      SOFTWARE_LIMITS: m_szScriptVersion];
        // torres
        // read the setting that if need upload process log for PASS test.
        NSString *szFileNameUploadToPDCA = @"";
        
        //Modified by Leehua on 130311 
        if (m_bFinalResult /*&& kPD_UserDefaults_NoProcessLog*/ && [[m_dicMemoryValues objectForKey:kPD_GHInfo_BUILD_STAGE] isEqual:@"MP"] && [[m_dicMemoryValues objectForKey:kPD_GHInfo_LOCAL_CSV] isEqual:@"OFF"])
        {
            ATSDebug(@"write_PDCA : => Do not need upload process log for PASS test.");
        }
        else
        {
            // make blob zip file of the logs
            if(m_bUploadFile)
            {
                szFileNameUploadToPDCA = m_szFilePath;
                [m_objPudding MakeBlobZIP_File:szFileNameUploadToPDCA FileList:m_aryFile];
            }
            else
            {
                szFileNameUploadToPDCA = [NSString stringWithFormat:@"/vault/%@_UpPDCAFile.zip",m_szISN];
                [m_objPudding MakeBlobZIP_File:szFileNameUploadToPDCA FileList:[m_dicLogPaths allValues]];

            }
        }
        
        if ([m_objPudding CompleteTestProcess:szFileNameUploadToPDCA ErrorMsg:&szPuddingErr] != TEST_SUCCESS)
        {
            // Show fail on UI
            m_bIsCheckedPDCA = YES;
            NSDictionary    *dicUIResult = [NSDictionary dictionaryWithObjectsAndKeys:kAllTableView, kFunnyZoneIdentify,[NSNumber numberWithBool:NO], kFunnyZoneSingleItemResult, nil];
            [self postTestInfoToUI:dicUIResult];
            
            // auto test system(NO Alert)
            // no need alert message box
            if (!gbIfNeedRemoteCtl)
            {
          //      [[NSNotificationCenter defaultCenter] postNotificationName:BNRTestProgressPopWindow object:nil];
                
                 NSRunAlertPanel(kFZ_PanelTitle_IPError, szPuddingErr, @"OK", nil, nil);
                
          //      [[NSNotificationCenter defaultCenter] postNotificationName:BNRTestProgressQuitWindow object:nil];
            }
            
            ATSDebug(@"Pudding Warning : %@",szPuddingErr);
        }
        else
        {
            bRet = YES;
        }
        if (nil != szFileNameUploadToPDCA && ![szFileNameUploadToPDCA isEqualToString:@""])
        {
            // move the file of blob zip logs
            [fileManager removeItemAtPath:szFileNameUploadToPDCA error:nil];
            if(m_bRemoveFile)
            {
                [fileManager removeItemAtPath:m_szRemoveFilePath error:nil];
            }
            ATSDebug(@"Remove file	:	[%@]",szFileNameUploadToPDCA);
        }
    }
    return bRet;
}


- (void)renameLogs
{
    // Call the Log info class to do log manager.
	NSFileManager *fileManager = [NSFileManager  defaultManager];
	NSString *szFinalCSVFileName = kFunnyZoneBlank;
    NSString *szFinalUartFileName = kFunnyZoneBlank;
    NSString *szFinalConsoleLog = kFunnyZoneBlank;//Leehua 110907
	NSString *szCSVFileName = [NSString stringWithFormat:@"%@/%@_%@_CSV.csv",kPD_LogPath_CSV,m_szPortIndex,m_szStartTime];
	NSString *szUARTFileName = [NSString stringWithFormat:@"%@/%@_%@_Uart.txt",kPD_LogPath_Uart,m_szPortIndex,m_szStartTime];
	NSString *szConsoleLog = [NSString stringWithFormat:@"%@/%@_%@_DEBUG.txt",kPD_LogPath_Console,m_szPortIndex,m_szStartTime];//Leehua 110907
    
    //############################# 2011.07.21 Modify By Ming Begin ###############################
    //for other logs
    //2011.07.11 Add by Ming for gyro log ,Can we change another way (delete kIADevice_Gyro_bIsHaveGyroPath)?Leehua
    NSString *TempbIsHaveGyroPath = [m_dicMemoryValues objectForKey:kIADevice_Gyro_bIsHaveGyroPath];
    BOOL bIsHaveGyroPath = [TempbIsHaveGyroPath boolValue];
    if(bIsHaveGyroPath)
    {
        NSString *szGyroFilePath = [m_dicMemoryValues objectForKey:kIADevice_Gyro_GyroFilePath];
        ATSDebug(@"szGyroFilePath= %@",szGyroFilePath);
        [m_dicLogPaths setValue:szGyroFilePath forKey:kFZ_GyroLogPath];
    }
    //############################# 2011.07.21 Modify By Ming End ###############################
    
	if ([fileManager fileExistsAtPath:szCSVFileName])
	{
		if (m_bFinalResult)
		{
			szFinalCSVFileName = [NSString stringWithFormat:@"%@/PASS_%@_%@_CSV.csv",kPD_LogPath_CSV,m_szISN,m_szStartTime];
		}
		else
		{
			szFinalCSVFileName = [NSString stringWithFormat:@"%@/FAIL_%@_%@_CSV.csv",kPD_LogPath_CSV,m_szISN,m_szStartTime];
		}
        ATSDebug(@"FinalCSVFileName = %@",szFinalCSVFileName);
        
        [fileManager moveItemAtPath:szCSVFileName toPath:szFinalCSVFileName error:nil];
        NSLog(@"Move file from [%@] to [%@]",szCSVFileName,szFinalCSVFileName);
		[m_dicLogPaths setValue:szFinalCSVFileName forKey:kFZ_CSVLogPath];
	}
	if ([fileManager fileExistsAtPath:szUARTFileName])
	{
		if (m_bFinalResult)
		{
			szFinalUartFileName = [NSString stringWithFormat:@"%@/PASS_%@_%@_Uart.txt",kPD_LogPath_Uart,m_szISN,m_szStartTime];
		}
		else
		{
			szFinalUartFileName = [NSString stringWithFormat:@"%@/FAIL_%@_%@_Uart.txt",kPD_LogPath_Uart,m_szISN,m_szStartTime];
		}
        ATSDebug(@"FinalUartFileName = %@",szFinalUartFileName);
        
        [fileManager moveItemAtPath:szUARTFileName toPath:szFinalUartFileName error:nil];
        NSLog(@"Move file from [%@] to [%@]",szUARTFileName,szFinalUartFileName);
		[m_dicLogPaths setValue:szFinalUartFileName forKey:kFZ_UARTLogPath];
	}
    
    //Winter 2012.4.18
	//Write cycle time log, rename log name
    if(![[self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_NoCycleTimeLog,nil]boolValue])
    {
        NSString *szFinalCycleTimeName = kFunnyZoneBlank;
        NSString *szCycleTimeLog = [NSString stringWithFormat:@"%@/%@_%@_CycleTime.csv",kPD_LogPath_CycleTime,m_szPortIndex,m_szStartTime];
        if ([fileManager fileExistsAtPath:szCycleTimeLog])
        {
            if (m_bFinalResult)
            {
                szFinalCycleTimeName = [NSString stringWithFormat:@"%@/PASS_%@_%@_CycleTime.csv",kPD_LogPath_CycleTime,m_szISN,m_szStartTime];
            }
            else
            {
                szFinalCycleTimeName = [NSString stringWithFormat:@"%@/FAIL_%@_%@_CycleTime.csv",kPD_LogPath_CycleTime,m_szISN,m_szStartTime];
            }
            ATSDebug(@"FinalCycleTimeName = %@",szFinalCycleTimeName);
            
            [fileManager moveItemAtPath:szCycleTimeLog toPath:szFinalCycleTimeName error:nil];
            NSLog(@"Move file from [%@] to [%@]",szCycleTimeLog,szFinalCycleTimeName);
            [m_dicLogPaths setValue:szFinalCycleTimeName forKey:kFZ_CycleTimeLogPath];
        }
    }
    
	if ([fileManager fileExistsAtPath:szConsoleLog])
	{
		if (m_bFinalResult)
		{
			szFinalConsoleLog = [NSString stringWithFormat:@"%@/PASS_%@_%@_DEBUG.txt",kPD_LogPath_Console,m_szISN,m_szStartTime];
		}
		else
		{
			szFinalConsoleLog = [NSString stringWithFormat:@"%@/FAIL_%@_%@_DEBUG.txt",kPD_LogPath_Console,m_szISN,m_szStartTime];
		}
        ATSDebug(@"FinalConsoleLog = %@",szFinalConsoleLog);
        
        [fileManager moveItemAtPath:szConsoleLog toPath:szFinalConsoleLog error:nil];
        NSLog(@"Move file from [%@] to [%@]",szConsoleLog,szFinalConsoleLog);
		[m_dicLogPaths setValue:szFinalConsoleLog forKey:kFZ_ConsoleLogPath];
	}
    
    //after rename
    if (m_bFinalResult) {
        [m_szPortIndex setString:[NSString stringWithFormat:@"PASS_%@",m_szISN]];
    }
    else
    {
        [m_szPortIndex setString:[NSString stringWithFormat:@"FAIL_%@",m_szISN]];
    }
    //ATSDebug(@"m_szPortIndex = %@",m_szPortIndex);
    
}

// If the strSource did not exsist any object at arrayObjs, return NO, otherwise return YES
- (BOOL)ExsistObjects:(NSArray *)arrayObjs AtString:(NSString *)strSource IgnoreCase:(BOOL)bCase
{
	BOOL bReply = NO;
	NSMutableArray * arrExsist = [[NSMutableArray alloc] init];
	for (NSUInteger i = 0; i < [arrayObjs count]; i++)
	{
		NSString * strOneObj = [arrayObjs objectAtIndex:i];
		strOneObj = bCase ? [strOneObj uppercaseString] : strOneObj;
		strSource = bCase ? [strSource uppercaseString] : strSource;
        NSRange range = [strSource rangeOfString:strOneObj];
		if (range.location != NSNotFound && range.length > 0 && (range.location+range.length) <= [strSource length])
		{
			bReply |= YES;
			[arrExsist addObject:strOneObj];
		}
	}
	NSLog(@"Source string [%@] Exsist objects [%@]",strSource, arrExsist);
	[arrExsist release];
	return bReply;
}

//delegate function implement
-(void)writeDebugLog:(NSString *)szFirstParam
{
    @synchronized(self)
    {
        if (macro_W_Console)
        {
            ATSDBgLog(@"%@",szFirstParam);
        }
    }
}

//handle tiltFixtureResult notification
- (void)PatternResultFromFixture:(NSNotification *)notiInfo
{
    NSString *szRet = [[notiInfo userInfo] objectForKey:@"PatnFixRet"];
    if(szRet)
    {
        NSInteger iRet = [szRet intValue];
        if(iRet == kUart_SUCCESS)
        {
            m_iPatnRFromFZ = kFZ_Pattern_ReceiveVolDnMsg;
            return;
        }
    }
    m_iPatnRFromFZ = kFZ_Pattern_ReceiveMsg;
}

//**********************************************************for uart*************************************************
//string hex to data
-(NSData *)stringHexToData:(NSString *)szInput
{
    NSArray *arrCMD = [szInput componentsSeparatedByString:@" "];
    NSInteger iCount = [arrCMD count];
    unsigned char   *pBuffer = malloc(iCount+1);
    for(NSInteger iIndex=0; iIndex<iCount; iIndex++)
    {
        unsigned int ucBuf = 0;
        NSString *szValue = [arrCMD objectAtIndex:iIndex];
        NSScanner *scan = [NSScanner scannerWithString:szValue];        
        [scan scanHexInt:&ucBuf];
        *(pBuffer+iIndex)=ucBuf;
    }
    NSData *dataRet = [NSData dataWithBytes:pBuffer length:iCount];
    free(pBuffer);
    pBuffer = NULL;
    return dataRet;
}

-(NSString *)catchFromString:(NSString *)szOriString begin:(NSString*)szBegin end:(NSString *)szEnd TheRightString:(BOOL)bTheRight
{
    if (szBegin && szEnd && [szBegin isNotEqualTo:@""] && [szEnd isNotEqualTo:@""] && [szBegin isEqualToString:szEnd] && bTheRight) 
    {
        if ([szOriString ContainString:szBegin]) 
        {
            return szBegin;
        }
        else
        {
            return @"";
        }
    }
    NSRange range;
    if (![szOriString isKindOfClass:[NSString class]]) {
        return @"";
    }
    if(nil != szBegin && ![szBegin isEqualToString:@""])
	{
        [self TransformKeyToValue:szBegin returnValue:&szBegin];
        range	= [szOriString rangeOfString:szBegin];
        if(NSNotFound != range.location && [szOriString length]>=range.location+range.length && range.length > 0)
        {
            szOriString	= [szOriString substringFromIndex:range.location + range.length];
        }
        else
        {
            return @"";
        }        
	}
	if(nil != szEnd && ![szEnd isEqualToString:@""] && szOriString != nil && ![szOriString isEqualToString:@""])
	{
        [self TransformKeyToValue:szEnd returnValue:&szEnd];
        range	= [szOriString rangeOfString:szEnd];
        if(NSNotFound != range.location && [szOriString length]>=range.location+range.length && range.length > 0)
        {
            szOriString	= [szOriString substringToIndex:range.location];
        }
        else
        {
            return @"";
        }
	}
    return szOriString;
}

-(NSString *)catchFromString:(NSString *)szOriString location:(NSInteger)iLocation length:(NSInteger)iLength
{
    if([szOriString isKindOfClass:[NSString class]] && ((iLocation + iLength) <= [szOriString length]))
    {
        if (iLength != 0) 
        {
            szOriString = [szOriString substringWithRange:NSMakeRange(iLocation, iLength)];
        }
        else
        {
            szOriString = [szOriString substringFromIndex:iLocation];
        }
        return szOriString;
    }
    else
    {
        return @"";
    }
}

// upload parametedata to PDCA

-(NSNumber *)UPLOADPARAMETEDATAFORSUBITEM:(NSDictionary *)dicUploadInfo RETURNVALUE:(NSMutableString *)szReturn
{
    
    ATSDebug(@"dicUploadInfo:%@\nszReturn:%@\n",dicUploadInfo,szReturn);
    if (nil == dicUploadInfo)
    {
        ATSDebug(@"The dicUploadInfo you want to upload is nil , please check!");
        return [NSNumber numberWithBool:NO];
    }
    NSDate   *dateStart = [NSDate date];
    NSTimeInterval dTimeSpend = 0.0;
    NSNumber *bResult = [NSNumber numberWithBool:YES];
    //NSString *szCSVFileName = [NSString stringWithFormat:@"%@/%@_%@_CSV.csv",kPD_LogPath_CSV,m_szPortIndex,m_szStartTime];
    NSString *szParametricName = [dicUploadInfo objectForKey:kFZ_Script_UploadParametric];
    NSString *szLowLimit = [dicUploadInfo objectForKey:kFZ_Script_ParamLowLimit];
    NSString *szHighLimit = [dicUploadInfo objectForKey:kFZ_SCript_ParamHighLimit];
    BOOL bTestResult = [[m_dicMemoryValues objectForKey:kFZ_Script_TestResult] boolValue];
    // if the parameters is nil then set the value fro them
    if ([m_dicMemoryValues objectForKey:kFZ_Script_TestResult] == nil)
    {
        bTestResult = YES;
    }
    if (nil == szLowLimit)
    {
        szLowLimit = @"N/A";
    }
    if (nil == szHighLimit)
    {
        szHighLimit = @"N/A";
    }
    if (nil == szReturn)
    {
        [szReturn setString:@"NA"];
    }
    if (nil == szParametricName)
    {
        szParametricName = @"";
    }
    // upload to PDCA
    if(!m_bNoUploadPDCA && !m_bNoParametric)
    {
        
        [m_objPudding SetTestItemStatus:szParametricName
                                SubItem:kFunnyZoneBlank
                              TestValue:szReturn
                               LowLimit:szLowLimit
                              HighLimit:szHighLimit
                              TestUnits:m_szUnit
                                ErrDesc:m_szErrorDescription
                               Priority:m_iPriority
                             TestResult:bTestResult];
        
        [m_dicMemoryValues setObject:[NSNumber numberWithBool:YES] forKey:kFZ_Script_TestResult];
        
    }
    // calculate the spend time
    dTimeSpend = [[NSDate date] timeIntervalSinceDate:dateStart];
    NSString *strTestInfo = [NSString stringWithFormat:@"%@,%d,%@,%@,%@,%0.6f\n",szParametricName,!bTestResult,szReturn,szLowLimit,szHighLimit,dTimeSpend];
    // save the test info to m_dicMemoryValues
    if (nil != [m_dicMemoryValues objectForKey:kFunnyZoneHasSubItemParameterData])
    {
        [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%@%@",[m_dicMemoryValues objectForKey:kFunnyZoneHasSubItemParameterData],strTestInfo] forKey:kFunnyZoneHasSubItemParameterData];
    }
    else
    {
        [m_dicMemoryValues setObject:strTestInfo forKey:kFunnyZoneHasSubItemParameterData];
    }
    return bResult;
}


-(void) writeForCocoSpecName:(NSString *)szCurrentItemName status:(BOOL)bStatus csvPath:(NSString *)szCSVFileName sumNames:(NSMutableString *)szTestNames sumUpLimits:(NSMutableString *)szUpperLimits sumDnLimits:(NSMutableString *)szDownLimits sumValueList:(NSMutableString *)szValueList errorDescription:(NSMutableString *)szErrorDescription sumError:(NSMutableString *)szErrorInfo endItem:(BOOL)bEndItem saveSummary:(BOOL)bSaveSum saveCSV:(BOOL)bSaveCSV uploadParametric:(BOOL)bUploadParam CurrentIndex:(int)index
{
    NSString *szUpLimit,*szDnLimit;
    NSString *szCofSpec = [m_dicMemoryValues objectForKey:kFZ_Cof_TestLimit];
    if (szCofSpec != nil)
    {
        NSString *szReturnValue = [NSString stringWithString:m_szReturnValue];
        [self getSpecFrom:szCofSpec lowLimt:&szDnLimit highLimit:&szUpLimit];
        ATSDebug(@"DnLimit is %@, UpLimit is %@",szDnLimit,szUpLimit);
        NSString *szCofItemName = [NSString stringWithFormat:@"CoF_%@",szCurrentItemName];
        if (!bStatus)
        {
            
            if ([szErrorDescription isEqualToString:@""])
            {
                [szErrorDescription setString:[NSString stringWithFormat:@"%@_FAIL",szCofItemName]];
            }
            else
            {
                [szErrorDescription setString:[NSString stringWithFormat:@"CoF_%@",szErrorDescription]];
            }
            ATSDebug(@"ErrorDescription is %@",szErrorDescription);
            
            if (bEndItem)
            {
                [m_szFailLists appendFormat:@"%@;",szCofItemName];
                [szErrorInfo appendFormat:@"%@=>%@;",szCofItemName,szErrorDescription];
                ATSDebug(@"ErrorInfo is %@",szErrorInfo);
            }
            
        }
        //add for summary log
        if (bSaveSum)
        {
            
            [szTestNames appendFormat:@",\"%@\"",szCofItemName];
            
            double  dUp;
            NSScanner   *scanUp = [NSScanner scannerWithString:szUpLimit];
            if (!([scanUp scanDouble:&dUp] && [scanUp isAtEnd]))
            {
                [szUpperLimits appendFormat:@",\"%@\"",szUpLimit];
            }
            else
                [szUpperLimits appendFormat:@",%@",szUpLimit];
            
            double  dDn;
            NSScanner   *scanDn = [NSScanner scannerWithString:szDnLimit];
            if (!([scanDn scanDouble:&dDn] && [scanDn isAtEnd]))
            {
                [szDownLimits appendFormat:@",\"%@\"",szDnLimit];
            }
            else
                [szDownLimits appendFormat:@",%@",szDnLimit];
            
            double   fDigit;
            NSScanner *scaner = [NSScanner scannerWithString:szReturnValue];
            if (!([scaner scanDouble:&fDigit] && [scaner isAtEnd]))
            {
                [szValueList appendFormat:@",\"%@\"",szReturnValue];
            }
            else
                [szValueList appendFormat:@",%@",szReturnValue];
            ATSDebug(@"szUpperLimits is %@, szDownLimits is %@, szValueList is %@",szUpperLimits,szDownLimits,szValueList);
        }
        //end for summary log
        
        //add by jingfu ran on 2012 04 23
        NSImage  *imageResult = [NSImage imageNamed:NSImageNameStatusAvailable];
        BOOL bCofResult = [[m_dicMemoryValues objectForKey:@"Cof_Result"] boolValue];
        BOOL bMPResult = [[m_dicMemoryValues objectForKey:@"MP_Result"] boolValue];
        
        if (bCofResult && bMPResult)
        {
            imageResult =  [NSImage imageNamed:NSImageNameStatusAvailable];
        }
        if (bCofResult && !bMPResult)
        {
            imageResult = [NSImage imageNamed:NSImageNameStatusPartiallyAvailable];
        }
        if (!bMPResult && !bCofResult)
        {
            imageResult = [NSImage imageNamed:NSImageNameStatusUnavailable];
        }
        NSAttributedString * szConsoleMessage = [[NSAttributedString alloc] initWithAttributedString:m_strConsoleMessage];
        
        if ([m_dicMemoryValues valueForKey:kFunnyZoneShowCoFONUI] != nil)
        {
            if ([[m_dicMemoryValues valueForKey:kFunnyZoneShowCoFONUI] boolValue])
            {
                NSDictionary *dictALLView = [NSDictionary dictionaryWithObjectsAndKeys:
                                             kAllTableView, kFunnyZoneIdentify,
                                             [NSString stringWithFormat:@"[%d]",index+1], kAllTableViewIndex,
                                             imageResult, kAllTableViewResultImage,
                                             szCofSpec, kAllTableViewSpec,
                                             szCofItemName, kAllTableViewItemName,
                                             szReturnValue, kAllTableViewRetureValue,
                                             [m_dicMemoryValues objectForKey:kFZ_SingleTime], kAllTableViewCostTime,
                                             [NSNumber numberWithInt:index], kFunnyZoneCurrentIndex,
                                             [NSNumber numberWithInt:[m_arrayScript count]], kFunnyZoneSumIndex,
                                             [NSNumber numberWithBool:m_bSubTest_PASS_FAIL], kFunnyZoneSingleItemResult,
                                             [NSNumber numberWithBool:bStatus],kFunnyZoneStatus,
                                             m_szISN,kFunnyZoneISN,
                                             szConsoleMessage, kFunnyZoneConsoleMessage,
                                             m_szPortIndex,kFunnyZonePortIndex,nil];
                [self postTestInfoToUI:dictALLView];
                ATSDebug(@"Post TestInfo to UI Success!");
                
                
            }
            
        }
        //end by jingfu ran on 2012 04 23
        [szConsoleMessage release];            // add by jingfu ran for avoiding memory leak on 2012 05 02
        // Write CSV Log
        if (bSaveCSV)
        {
            NSString *szCSVInfo = [NSString stringWithFormat:@"\"%@\",%@,\"%@\",%@,%@,%@\n",szCofItemName,[NSNumber numberWithBool:!bStatus],m_szReturnValue,szDnLimit,szUpLimit,[m_dicMemoryValues objectForKey:kFZ_SingleTime]];
            [IALogs CreatAndWriteSingleCSVLog:szCSVInfo withPath:szCSVFileName];
            ATSDebug(@"Creat And Write Single CSVLog Success");
        }
        //parametric data
        if (bUploadParam)
        {
            [self uploadParametric:szCofItemName lowLimit:szDnLimit highLimit:szUpLimit status:bStatus errorMessage:szErrorDescription];
            ATSDebug(@"upload Parametric done");
        }
    }
}

-(void) writeForNormalSpecName:(NSString *)szCurrentItemName status:(BOOL)bStatus csvPath:(NSString *)szCSVFileName sumNames:(NSMutableString *)szTestNames sumUpLimits:(NSMutableString *)szUpperLimits sumDnLimits:(NSMutableString *)szDownLimits sumValueList:(NSMutableString *)szValueList errorDescription:(NSMutableString *)szErrorDescription sumError:(NSMutableString *)szErrorInfo endItem:(BOOL)bEndItem saveSummary:(BOOL)bSaveSum saveCSV:(BOOL)bSaveCSV uploadParametric:(BOOL)bUploadParam CurrentIndex:(int)index
{
    NSString *szUpLimit,*szDnLimit;
    NSString *szMPSpec = [m_dicMemoryValues objectForKey:kFZ_MP_TestLimit];
    NSString *szReturnValue = [NSString stringWithString:m_szReturnValue];
    if (szMPSpec != nil)
    {
        [self getSpecFrom:szMPSpec lowLimt:&szDnLimit highLimit:&szUpLimit];
    }
    else
    {
        szMPSpec = [m_dicMemoryValues objectForKey:kFZ_TestLimit];
        [self getSpecFrom:szMPSpec lowLimt:&szDnLimit highLimit:&szUpLimit];
        
        if (bEndItem)
        {
            bStatus = m_bSubTest_PASS_FAIL;
        }
        else
        {
            //temporarily no need
        }
    }
    ATSDebug(@"DnLimit is %@, UpLimit is %@",szDnLimit,szUpLimit);
    
    if (!bStatus)
    {
        if ([szErrorDescription isEqualToString:@""])
        {
            [szErrorDescription setString:[NSString stringWithFormat:@"%@_FAIL",szCurrentItemName]];
        }
        else
        {
            if ([szErrorDescription ContainString:@"CoF_"])
            {
                [szErrorDescription setString:[szErrorDescription SubFrom:@"CoF_" include:NO]];
            }
        }
        ATSDebug(@"ErrorDescription is %@",szErrorDescription);
        
        if (bEndItem)
        {
            [m_szFailLists appendFormat:@"%@;",szCurrentItemName];
            [szErrorInfo appendFormat:@"%@=>%@;",szCurrentItemName,szErrorDescription];
            ATSDebug(@"ErrorInfo is %@",szErrorInfo);
        }
    }
    
    //add by jingfu ran on 2012 04 23
    NSImage  *imageResult = [NSImage imageNamed:NSImageNameStatusAvailable];
    BOOL bCofResult = [[m_dicMemoryValues objectForKey:@"Cof_Result"] boolValue];
    BOOL bMPResult = [[m_dicMemoryValues objectForKey:@"MP_Result"] boolValue];
    
    if (bCofResult && bMPResult)
    {
        imageResult =  [NSImage imageNamed:NSImageNameStatusAvailable];
    }
    if (bCofResult && !bMPResult)
    {
        imageResult = [NSImage imageNamed:NSImageNameStatusPartiallyAvailable];
    }
    if (!bMPResult && !bCofResult)
    {
        imageResult = [NSImage imageNamed:NSImageNameStatusUnavailable];
    }
    NSAttributedString * szConsoleMessage = [[NSAttributedString alloc] initWithAttributedString:m_strConsoleMessage];
    
    
    if ([m_dicMemoryValues valueForKey:kFunnyZoneShowCoFONUI] != nil)
    {
        if ([[m_dicMemoryValues valueForKey:kFunnyZoneShowCoFONUI] boolValue])
        {
            NSDictionary *dictALLView = nil;
            dictALLView  = [NSDictionary dictionaryWithObjectsAndKeys:
                            kAllTableView, kFunnyZoneIdentify,
                            [NSString stringWithFormat:@"[%d]",index+1], kAllTableViewIndex,
                            imageResult, kAllTableViewResultImage,
                            szMPSpec, kAllTableViewSpec,
                            szCurrentItemName, kAllTableViewItemName,
                            szReturnValue, kAllTableViewRetureValue,
                            [m_dicMemoryValues objectForKey:kFZ_SingleTime], kAllTableViewCostTime,
                            [NSNumber numberWithInt:index], kFunnyZoneCurrentIndex,
                            [NSNumber numberWithInt:[m_arrayScript count]], kFunnyZoneSumIndex,
                            [NSNumber numberWithBool:m_bSubTest_PASS_FAIL], kFunnyZoneSingleItemResult,
                            [NSNumber numberWithBool:bStatus],kFunnyZoneStatus,
                            m_szISN,kFunnyZoneISN,
                            szConsoleMessage, kFunnyZoneConsoleMessage,
                            m_szPortIndex,kFunnyZonePortIndex,nil];
            [self postTestInfoToUI:dictALLView];
            ATSDebug(@"Post TestInfo to UI Success!");
            
        }
        
    }
    //end by jingfu ran on 2012 04 23
    
    //add for summary log
    if (bSaveSum)
    {
        //Add by xiaoyong 2012/07/25 for summary log...
        [szTestNames appendFormat:@",%@",szCurrentItemName];
        double  dUp;
        NSScanner   *scanUp = [NSScanner scannerWithString:szUpLimit];
        if (!([scanUp scanDouble:&dUp] && [scanUp isAtEnd]))
        {
            [szUpperLimits appendFormat:@",\"%@\"",szUpLimit];
        }
        else
            [szUpperLimits appendFormat:@",%@",szUpLimit];
        
        double  dDn;
        NSScanner   *scanDn = [NSScanner scannerWithString:szDnLimit];
        if (!([scanDn scanDouble:&dDn] && [scanDn isAtEnd]))
        {
            [szDownLimits appendFormat:@",\"%@\"",szDnLimit];
        }
        else
            [szDownLimits appendFormat:@",%@",szDnLimit];
        
        double   fDigit;
        NSScanner *scaner = [NSScanner scannerWithString:szReturnValue];
        if (!([scaner scanDouble:&fDigit] && [scaner isAtEnd]))
        {
            [szValueList appendFormat:@",\"%@\"",szReturnValue];
        }
        else
            [szValueList appendFormat:@",%@",szReturnValue];
        ATSDebug(@"szUpperLimits is %@, szDownLimits is %@, szValueList is %@",szUpperLimits,szDownLimits,szValueList);
    }
    //end for summary log
	[szConsoleMessage release];            // add by jingfu ran for avoiding memory leak on 2012 05 02
    // Write CSV Log
    if (bSaveCSV)
    {
        //add for write subItem parameter  add by jingfu ran on 2012 04 04
        if (nil != [m_dicMemoryValues valueForKey:kFunnyZoneHasSubItemParameterData])
        {
            [IALogs CreatAndWriteSingleCSVLog:[m_dicMemoryValues valueForKey:kFunnyZoneHasSubItemParameterData] withPath:szCSVFileName];
            [m_dicMemoryValues removeObjectForKey:kFunnyZoneHasSubItemParameterData];
        }
        //end
        NSString *szCSVInfo = [NSString stringWithFormat:@"\"%@\",%@,\"%@\",%@,%@,%@\n",szCurrentItemName,[NSNumber numberWithBool:!bStatus],m_szReturnValue,szDnLimit,szUpLimit,[m_dicMemoryValues objectForKey:kFZ_SingleTime]];
        [IALogs CreatAndWriteSingleCSVLog:szCSVInfo withPath:szCSVFileName];
        ATSDebug(@"Creat And Write Single CSVLog Success");
        
    }
    //parametric data
    if (bUploadParam)
    {
        [self uploadParametric:szCurrentItemName lowLimit:szDnLimit highLimit:szUpLimit status:bStatus errorMessage:szErrorDescription];
        ATSDebug(@"upload Parametric done");
    }
}

- (void)getSpecFrom:(NSString *)szSpecString lowLimt:(NSString **)szDnLimit highLimit:(NSString **)szUpLimit
{
    if ([szSpecString length] < 3) {
        *szUpLimit = *szDnLimit = @"";
    }
    else
    {
        // START modified by Andre on 2012-03-07
        char character = [szSpecString characterAtIndex:0];
        if ('{' == character) 
        {
            NSString *szSpecTemp = [szSpecString substringFromIndex:1];
            NSString *szSpec = [szSpecTemp substringToIndex:([szSpecTemp length] - 1)];	
            //replace "," with " " for in csv file ,data separated with ","
            *szUpLimit = *szDnLimit = [szSpec stringByReplacingOccurrencesOfString:kFunnyZoneComma withString:kFunnyZoneBlank1];
        }
        else
        {
            NSString *szSpecTemp = [szSpecString substringFromIndex:1];
            NSString *szSpec = [szSpecTemp substringToIndex:([szSpecTemp length] - 1)];		
            NSArray *arySpec = [szSpec componentsSeparatedByString:kFunnyZoneComma];
            NSInteger iSpecCount = [arySpec count];
            if(iSpecCount == 2)	
            {
                *szUpLimit = [arySpec objectAtIndex:1];
                *szDnLimit = [arySpec objectAtIndex:0];
                if ([*szUpLimit isEqualToString:@""]) {
                    *szUpLimit = @"NA";
                }
                if ([*szDnLimit isEqualToString:@""]) {
                    *szDnLimit = @"NA";
                }
                szSpecString = [szSpecString stringByReplacingCharactersInRange:NSMakeRange(1, [szSpec length]) withString:[NSString stringWithFormat:@"%@,%@",*szDnLimit,*szUpLimit]];
            }
            else
            {
                //replace "," with " " for in csv file ,data separated with ","
                *szUpLimit = *szDnLimit = [szSpec stringByReplacingOccurrencesOfString:kFunnyZoneComma withString:kFunnyZoneBlank1];
            }
        }
    }
}

// upload Parametric to the PDCA
- (void)uploadParametric:(NSString *)szItemName lowLimit:(NSString *)szDnLimit highLimit:(NSString *)szUpLimit status:(BOOL)bStatus errorMessage:(NSMutableString *)szErrorMessage
{
    // Upload pramatric data
    if(!m_bNoUploadPDCA && !m_bNoParametric)
    {
        NSString *szValue = [NSString stringWithString:m_szReturnValue];
        if ([szValue isEqualToString:kFZ_99999_Value_Issue])
        {
            szValue = @"NA";
        }
        
        NSString * strMainItemName = [m_dicMemoryValues objectForKey:@"MainItemName"];
        NSString * strSubItemName = kFunnyZoneBlank;
        // if the current Item name contains the MainItemName  then catch the string from begin to MainItemName(include)
        if (strMainItemName != nil && [szItemName ContainString:strMainItemName])
        {
            strSubItemName = [szItemName SubFrom:strMainItemName include:NO];
            NSString *strBeginName = [self catchFromString:szItemName begin:nil end:strMainItemName TheRightString:NO];
            strMainItemName = [NSString stringWithFormat:@"%@%@",strBeginName,strMainItemName];
        }
        // upload
        [m_objPudding SetTestItemStatus:(nil == strMainItemName) ? szItemName : strMainItemName
								SubItem:strSubItemName
							  TestValue:szValue
							   LowLimit:szDnLimit
							  HighLimit:szUpLimit
							  TestUnits:m_szUnit
                                ErrDesc:[NSString stringWithFormat:@"%@",szErrorMessage]
							   Priority:m_iPriority
							 TestResult:bStatus];
        [m_dicMemoryValues removeObjectForKey:@"MainItemName"];
    }
}


- (NSString *)getECIDNumber:(NSString *)strInput
{
	NSString *strECID = @"";
	// Can find the smail in the strInput string.
	NSString * strLastObj = [[strInput componentsSeparatedByString:@"\n"] lastObject];
    //modify by Leehua 12.08.16
    strLastObj = [strLastObj stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    strLastObj = [strLastObj stringByReplacingOccurrencesOfString:@" " withString:@""];
	if ([strLastObj hasPrefix:@"["] && [strLastObj hasSuffix:@"]:-)"] && [strLastObj ContainString:@":-)"] /*&& [strLastObj ContainString:@"["] && [strLastObj ContainString:@"]"]*/)
	{
		strECID = [strLastObj SubFrom:@"[" include:YES];
		strECID = [strECID SubTo:@"]" include:YES];
	}
	
	return strECID;
}

-(NSNumber *)GETTESTSLOT:(NSDictionary *)dicParam RETURN_VALUE:(NSMutableString *)strReturnValue
{
    NSString *szPortType = [[[m_dicMemoryValues objectForKey:@"Muifa_Plist"] objectForKey:@"ModeSetting"] objectForKey:@"SlotType"];
    NSString *szBsdPath = [[m_dicPorts objectForKey:szPortType] objectAtIndex:kFZ_SerialInfo_SerialPort];
    
    NSRange range = [szBsdPath rangeOfString:@"UUT"];
    if (range.location != NSNotFound && range.length > 0 ) 
    {
        [strReturnValue setString:[szBsdPath substringWithRange:NSMakeRange(range.location+3, 1)]];
        return [NSNumber numberWithBool:YES];
    }
    else
    {
        [strReturnValue setString:@"Can't find the test slot!"];
        return [NSNumber numberWithBool:NO];
    }   
}


// Judge the uart port whether is the port to control fixture(Unit1)
- (NSNumber *)Is_Elder_Brother_port:(NSDictionary*)dicPort RETURNVALUE:(NSMutableString *)szReturnValue
{
    NSString *szPortType = [[[[m_dicMemoryValues objectForKey:@"Muifa_Plist"] objectForKey:@"ModeSetting"] objectForKey:@"BROTHER"] objectForKey:@"BrotherType"];
    //NSString *szBrotherUnit = [[[[m_dicMemoryValues objectForKey:@"Muifa_Plist"] objectForKey:@"ModeSetting"] objectForKey:@"BROTHER"] objectForKey:@"ElderBrotherUnit"];
    NSString *szBsdPath = [[dicPort objectForKey:szPortType] objectAtIndex:kFZ_SerialInfo_SerialPort];
   // NSDictionary *dicEachUnitSet = [kPD_ModeSet_UnitInfo objectForKey:szReturnValue];
    NSDictionary *dicUnitSet = [[[m_dicMemoryValues objectForKey:@"Muifa_Plist"] objectForKey:@"ModeSetting"] objectForKey:m_szMuifaUIMode];
    NSDictionary *dicEachUnitSet = [dicUnitSet objectForKey:szReturnValue];
    NSString *szPortName = [[[dicEachUnitSet objectForKey:kPD_UserDefaults_DeviceRequire] objectForKey:szPortType] objectForKey:kPD_UserDefaults_PortName];
    if ((nil != szBsdPath) && (NSNotFound != [szBsdPath rangeOfString:szPortName].location))
    {
        m_bIsElderBrotherPort = YES;
        return [NSNumber numberWithBool:YES];
    }
    else
    {
        m_bIsElderBrotherPort = NO;
        return [NSNumber numberWithBool:NO];
    }
    
    
}

// Host port post notification to the other port to start test
- (NSNumber *)ELDER_BROTHER_NOTIFY_YOUNG_BROTHER:(NSDictionary*)dicPara RETURNVALUE:(NSMutableString *)szReturnValue
{
    BOOL bRet = YES;
     NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(elderBrotherIsReady:) name:BNRElderBrotherNotification object:nil];
    
    // if it is the host port, run the fixture command.
    [self Is_Elder_Brother_port:m_dicPorts RETURNVALUE:szReturnValue];
    
    if (m_bIsElderBrotherPort)
    {
        NSString *szFixturePort = [[m_dicPorts objectForKey:@"FIXTURE"]objectAtIndex:0];
        bRet = [self MakeTheTrayIn:szFixturePort];
       
        if (bRet)
        {
            NSDictionary *dicInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"PASS", @"ELDERBROTHER", nil];
            [nc postNotificationName:BNRElderBrotherNotification object:self userInfo:dicInfo];
            [szReturnValue setString:@"Close the fixture tray pass."];
        }
        else
        {
            NSDictionary *dicInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"FAIL", @"ELDERBROTHER", nil];
            [nc postNotificationName:BNRElderBrotherNotification object:self userInfo:dicInfo];
            [szReturnValue setString:@"Close the fixture tray fail."];
        }
        
    }
    else
    {
        BOOL bReady = NO;
        do {
            usleep(100000);
            if (m_iElderBrother == BROTHER_PASS || m_iElderBrother == BROTHER_FAIL)
            {
                bReady = YES;
            }
        } while (!bReady);
        
        if (m_iElderBrother == BROTHER_PASS) 
        {
            bRet = YES;
            [szReturnValue setString:@"Close the fixture tray pass."];
            
        }
        else
        {
            bRet = NO;
            [szReturnValue setString:@"Close the fixture tray fail."];
            
        }
        m_iElderBrother = BROTHER_ERROR;
    }
    return [NSNumber numberWithBool:bRet];
}

// The servo ports post nofitication to the host port to end test
- (NSNumber *)YOUNG_BROTHER_NOTIFY_ELDER_BROTHER:(NSDictionary*)dicPara RETURNVALUE:(NSMutableString *)szReturnValue
{
    BOOL bRet = YES;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"YoungBrotherStartButtonUnpressed" object:self userInfo:nil];
    
    // if it is the host port, run the fixture command.
    if (m_bIsElderBrotherPort)
    {
        BOOL bReady = NO;
        do {
            usleep(100000);
            if (m_bYoungBrother)
            {
                bReady = YES;
            }
        } while (!bReady);
        
        NSDictionary *dicSendcommand1 = [dicPara objectForKey:@"1.SEND_COMMAND:"];
        NSDictionary *dicReadcommand1 = [dicPara objectForKey:@"1.READ_COMMAND:RETURN_VALUE:"];
//        NSDictionary *dicSendcommand2 = [dicPara objectForKey:@"2.SEND_COMMAND:"];
//        NSDictionary *dicReadcommand2 = [dicPara objectForKey:@"2.READ_COMMAND:RETURN_VALUE:"];
        NSDictionary *dicJudgeSpec = [dicPara objectForKey:@"3.JUDGE_SPEC_CANCEL:RETURN_VALUE:"];
        
        bRet &= [[self SEND_COMMAND:dicSendcommand1] boolValue];
        bRet &= [[self READ_COMMAND:dicReadcommand1 RETURN_VALUE:szReturnValue] boolValue];
//        bRet &= [[self SEND_COMMAND:dicSendcommand2] boolValue];
//        bRet &= [[self READ_COMMAND:dicReadcommand2 RETURN_VALUE:szReturnValue] boolValue];
        bRet &= [[self JUDGE_SPEC:dicJudgeSpec RETURN_VALUE:szReturnValue] boolValue];
        m_bYoungBrother = NO;
    }
    return [NSNumber numberWithBool:bRet];
}

-(void)elderBrotherIsReady:(NSNotification *)aNote
{
    if ([[[aNote userInfo] objectForKey:@"ELDERBROTHER"] isEqualToString:@"PASS"])
    {
        m_iElderBrother = BROTHER_PASS;
    }
    else
    {
        m_iElderBrother = BROTHER_FAIL;
    }
}

-(void)youngBrotherIsReady:(NSNotification *)aNote
{
    m_bYoungBrother = YES;
}

- (NSNumber *)ANTS_TEST:(NSDictionary*)dicPara RETURNVALUE:(NSMutableString *)szReturnValue
{
    // set window as first responder
    [[NSApp mainWindow] makeFirstResponder:[[NSApp mainWindow] contentView]];
    
    // enbale key down function
    m_bEnableKeyDown = YES;
    
    return [NSNumber numberWithBool:YES];
}

-(void)judgeWhichKeyPressed:(NSNotification *)aNote
{
    NSString *szKeyCode = [[aNote userInfo] objectForKey:@"KeyCode"];
    if ([szKeyCode isEqualToString:@"29"] || [szKeyCode isEqualToString:@"82"]) // "0" keycode is 29
    {
        m_bNextPattern = YES; 
        m_bLastPattern = NO; // invoid two flag both return true
    }
    else if([szKeyCode isEqualToString:@"18"] || [szKeyCode isEqualToString:@"83"]) // "1" keycode is 18
    {
        m_bLastPattern = YES; 
        m_bNextPattern = NO; // invoid two flag both return true
    }
    else
    {
        
    }
}

-(void)judgeAllPatternReadyOrNot:(NSNotification *)aNote
{
    if ([[aNote userInfo] objectForKey:@"ALLREADY"])
    {
        m_bAllPatternReady = [[[aNote userInfo] objectForKey:@"ALLREADY"] boolValue];
    }
    else
    {
        m_bAllPatternReady = NO;
    }
}

- (void)getInfomationFromDrawer:(NSNotification *)aNote
{    
    m_bCT2PatternFail = YES;
    [m_dicMemoryValues setObject:[[aNote userInfo]objectForKey:@"CURRENTUNIT"] forKey:@"CURRENTUNIT"]; 
    [m_dicMemoryValues setObject:[[aNote userInfo]objectForKey:@"LCDFAILMSG"] forKey:@"LCDFAILMSG"]; 
}

- (void)wakeUpPortsForUnexpectedFail:(NSDictionary *)dicInfo
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString *szBsdPath = [dicInfo objectForKey:@"PortPath"];
    [self monitorSerialPortPlugOutWithUartPath:szBsdPath]; 
    
    NSDictionary *diTemp = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"WakeUpUUT1", nil];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:BNRMonitorProxCalUUT1Notification object:self userInfo:diTemp];
    
    [pool drain];
}

- (NSNumber *)SHOW_OTHER_STATUS_ON_UI:(NSDictionary*)dicPara RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSString *szValue = [dicPara objectForKey:kFZ_Script_MemoryKey];
    if (szValue && [szValue isNotEqualTo:@""])
    {
        if ([m_dicMemoryValues objectForKey:szValue] && [[m_dicMemoryValues objectForKey:szValue] isKindOfClass:[NSString class]]) 
        {
            [szReturnValue setString:[m_dicMemoryValues objectForKey:szValue]];
        }
    }
    
    NSArray *arrCondition = [dicPara objectForKey:@"JUDGE_CONDITION"];
    int iTotal = [arrCondition count];
    for (int iCount = 0; iCount < iTotal; iCount++)
    {
        NSDictionary *dicCondition = [arrCondition objectAtIndex:iCount];
        BOOL bConditionResult = [[self JUDGE_SPEC:dicCondition RETURN_VALUE:szReturnValue] boolValue];
        if (bConditionResult)
        {
            if ([dicCondition objectForKey:@"STATUS_COLOR"])
            {
                [m_dicMemoryValues setObject:[dicCondition objectForKey:@"STATUS_COLOR"] forKey:kFZ_Script_StatusOnUI];
                break;
            }
        }
    }
    
    return [NSNumber numberWithBool:YES];
}

- (NSNumber *)CANCEL_BIG_TEST_CASE:(NSDictionary *)dicContents RETURN_VALUE:(NSMutableString *)szReturnValue
{
    m_iBigTestCaseFrom = [[dicContents objectForKey:@"NumberFrom"] intValue];
    m_iBigTestCaseTo = [[dicContents objectForKey:@"NumberTo"] intValue];
    if (m_iBigTestCaseFrom > m_iBigTestCaseTo) {
        m_iBigTestCaseFrom = m_iBigTestCaseTo = 0;
    }
    return [NSNumber numberWithBool:YES];
}

// auto test system (send fixture error)
- (NSNumber *)SocketError:(NSDictionary *)dicSetting RETURN_VALUE:(NSMutableString *)strReturnValue
{
    NSString *strErrorInfo = [dicSetting objectForKey:@"Error"];
    NSDictionary *dicResultInfo = [NSDictionary dictionaryWithObjectsAndKeys:strErrorInfo, @"Error Info",  m_szISN, @"ISN",nil];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:TEST_FINISHED object:self userInfo:dicResultInfo];
    return [NSNumber numberWithBool:YES];
}

- (BOOL)isCaseHidden:(NSArray *)aryInput atIndex:(NSInteger)iIndex
{
    NSDictionary *dicInput = [aryInput objectAtIndex:0];
    NSArray *arrKeys = [dicInput allKeys];
    NSString *szProjectName = [arrKeys objectAtIndex:0]; //0:just one item
    
    id idDetailPara = [dicInput objectForKey:szProjectName];
    if ([idDetailPara isKindOfClass:[NSArray class]])
        {
        NSMutableArray *maryBridge = [NSMutableArray arrayWithArray:m_arrayScript];
        [maryBridge insertObjects:[self parserScriptFile:aryInput] atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(iIndex+1, [aryInput count])]];
        [maryBridge removeObjectAtIndex:iIndex];
        [self setArrayScript:maryBridge];
        return YES;
        }
    return NO;
}

@end
