//
//  TestProgress.m
//  FunnyZone
//
//  Created by Lorky on 3/30/11.
//  Copyright 2011 PEGATRON. All rights reserved.
//



#import "TestProgress.h"
#import "IADevice_TestingCommands.h"
//#import "CBTestBase.h"

// auto test system
BOOL    gbIfNeedRemoteCtl   = NO;

// auto test system
NSString    * const TEST_FINISHED   = @"Test_Finished";
NSString    * const FIXTURE_ERROR   = @"Fixture_Error";

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

//For Pressure Test , Leehua

@synthesize publicParas         = m_objPublicParams;
@synthesize uiVersion;
@synthesize scriptName			= m_szScriptName;
@synthesize scriptVersion		= m_szScriptVersion;
@synthesize startDate			= m_szStartDate;
@synthesize startTime			= m_szStartTime;
@synthesize m_bPatnRFromUI;
@synthesize MobileSerialNumber	= m_szISN;//ISN
@synthesize arrayScript			= m_arrayScript;//script

@synthesize ports				= m_dicPorts;//port
@synthesize memoryValues		= m_dicMemoryValues;//save variables
@synthesize portIndex			= m_szPortIndex;//for multi , in single it's set as 0

@synthesize status				= m_iStatus;//for multiUI to control status(running, finish...)
@synthesize isCheckedPDCA		= m_bIsCheckedPDCA;//For has checked PDCA or not.

@synthesize isEmptyResponse		= m_bEmptyResponse;//Leehua

@synthesize processIssue		= m_bProcessIssue;

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
	NSNotificationCenter	*nc	= [NSNotificationCenter defaultCenter];
	[nc postNotificationName:TestItemInfoNotification
					  object:self
					userInfo:dictTestInfo];
}
#pragma ++++++++++++++++++       Body Implement            ++++++++++++++++++

- (id)initWithPublicParam:(publicParams *)publicParams
{
	if(self = [super init])
        
	{
        // For Pressure Test 
        m_objPublicParams       = publicParams;
    
        //variables initialization
        m_bIsFinished			= NO;
        m_bIsCheckedPDCA		= NO;

		m_szReturnValue			= [[NSMutableString alloc] initWithString:@""];
        m_szErrorDescription	= [[NSMutableString alloc] initWithString:@""];//err of each case
        m_szFailLists			= [[NSMutableString alloc] initWithString:@""];
        m_strSpecName			= [[NSMutableString alloc] initWithString:@""];
		m_strConsoleMessage		= [[NSMutableAttributedString alloc] initWithString:@""];
		m_strSingleUARTLogs		= [[NSMutableAttributedString alloc] initWithString:@""];
		m_arrSingleItemInfo		= [[NSMutableArray alloc] init];
        //port number for multi , in single it's set as 0
        m_szPortIndex			= [[NSMutableString alloc] initWithString:@"0"];//Leehua 11-9-7
        m_dicLogPaths			= [[NSMutableDictionary alloc] init];
        m_strLogFolderPath      = [[NSMutableString alloc]init];
        
        m_dicMemoryValues		= [[NSMutableDictionary alloc] init];
		m_dicButtonBuffer		= [[NSMutableDictionary alloc] init];
        m_dicMemoryButtonKeyValue = [[NSMutableDictionary alloc] init];
		
        //background color of each device for Uart log in uart tableview , we can set color for each device in setting file (such as mobile=>WHITE,fixture=>RED....,you must set color included in below dictionary
        m_dictPortColor			= [[NSDictionary alloc ] initWithObjectsAndKeys:
								   [NSColor whiteColor],	kFZ_UartTableview_WHITE, 
								   [NSColor redColor],		kFZ_UartTableview_RED,
								   [NSColor greenColor],	kFZ_UartTableview_GREEN,
								   [NSColor blueColor],		kFZ_UartTableview_BLUE,
								   [NSColor yellowColor],	kFZ_UartTableview_YELLOW,
								   [NSColor orangeColor],	kFZ_UartTableview_ORANGE, nil];

        //for multiUI to control status(running, finish...)
        m_iStatus				= kFZ_MultiStatus_None;
        //object initialization
        m_objPudding			= [[TPuddingPDCA alloc] init];
		NSLog(@"Pudding version: %@. ", [m_objPudding getInterfaceVersion]);
        [m_objPudding setDelegate:self];
        m_CBTestBase			= [[CBTestBase alloc] init];//Leehua 11.09.09 add for new cb function
        m_mathLibrary			= [[MathLibrary alloc] init];
        //for DisplayPort
        m_arrDisplayPortData	= [[NSMutableArray alloc] init];
        m_bFinalResult			= YES;
        //for record testResult of on sub item (such as OPEN_UART...)
        m_bSubTest_PASS_FAIL	= YES;
        //flag for Pattern CG
        m_bPatnRFromUI			= YES;
        m_iPatnRFromFZ			= kFZ_Pattern_NoMsg;
        //add notification
        NSNotificationCenter	*nc	= [NSNotificationCenter defaultCenter];
        [nc addObserver:self
			   selector:@selector(PatternResultFromFixture:)
				   name:TiltFixtureNotificationToFZ
				 object:nil];
        //for CPAS camispfailcount
        m_bNeedJudgeFailReceive	= NO;
        //for will be cancel case
        m_muArrayCancelCase		= [[NSMutableArray alloc] init];
        //pudding canceled
        m_bIsPuddingCanceled	= NO;
        //for update unit to PDCA
        m_szUnit				= [[NSMutableString alloc] initWithString:@""];
        //for NetWork CB Station Result
        m_dicNetWorkCBStation	= [[NSMutableDictionary alloc] init];
        //2012 7 16 torres add for MagnetSpine exception spec
        m_exceptCount			= 0;

        m_bEmptyResponse			= NO;//Leehua
        
        // record process items
        m_arrProItems           = [[NSArray  alloc]  init];
		m_bProcessIssue			= NO;
        
        //For Pressure Test, Add by leehua 2013.10.18 begin
        m_bFixtureControlOnhand = NO;
        
        m_dicDisableQueryItems  = [[NSMutableDictionary alloc] init];
        
	}
	return self;
}

- (void)dealloc
{
    //release for property
	@try
	{
		[m_taskTcprelay terminate];
	}
	@catch (NSException *exception)
	{
	}
	@finally
	{
		[m_taskTcprelay release];	m_taskTcprelay	= nil;
	}
	[uiVersion			release];
    [m_szScriptVersion      release];
	[m_szISN				release];
	[m_szStartTime			release];
    [m_szStartDate          release];
	[m_arrayScript          release];
    [m_dicPorts             release];
    [m_szScriptName			release];
	
    //release which alloc int init
    [m_szReturnValue        release];
    [m_szErrorDescription   release];
    [m_szFailLists          release];
    [m_strSpecName          release];
    [m_strConsoleMessage	release];
	[m_strSingleUARTLogs	release];
	[m_arrSingleItemInfo	release];
    [m_dicMemoryValues      release];
	[m_dicButtonBuffer		release]; m_dicButtonBuffer = nil;
    [m_dicMemoryButtonKeyValue release]; m_dicMemoryButtonKeyValue = nil;
    [m_szPortIndex			release];//Leehua 11-9-7
    [m_dicLogPaths          release];
    [m_strLogFolderPath     release];
    [m_dictPortColor        release];
    
    [m_objPudding           release];
    [m_CBTestBase          release];
    [m_mathLibrary          release];
    
    [m_arrDisplayPortData   release];
    [m_muArrayCancelCase    release];
    [m_dicNetWorkCBStation  release];
    
    [m_szUnit               release];
    
    [m_arrProItems          release];
    
    [m_dicDisableQueryItems release];
	[super dealloc];
}

//get stationINfo
- (NSDictionary *)getStationInfo
{
    NSMutableDictionary	*dicGhInfo	= [[NSMutableDictionary alloc] init];
    TPuddingPDCA		*pdObj		= [[TPuddingPDCA alloc] init];
    [pdObj StartPDCA_Flow];
    
    uint8				iRet		= kSuccessCode;
    //enum IP_ENUM_GHSTATIONINFO ghInfo = 0;
    NSString			*szValue	= @"";
    NSString			*szError	= @"";
	// Modified by lorky.
    for (NSInteger iIndex=1; iIndex<IP_GHSTATIONINFO_COUNT; iIndex++)
    {
        NSString	*szKey		= descriptionOfGHStationInfo(iIndex);
        iRet	= [pdObj getGHStationInfo:iIndex
							  strValue:&szValue
						  errorMessage:&szError];
        if (iRet == kSuccessCode && ![szValue isEqualToString:@""])
		{
            [dicGhInfo setObject:szValue forKey:szKey];
            szValue		= @"";
        }
        else
            [dicGhInfo setObject:@"" forKey:szKey];
    }
    [pdObj Cancel_Process];
    NSDictionary	*dicGhStInfo	= [NSDictionary dictionaryWithDictionary:dicGhInfo];
    [pdObj release];
    [dicGhInfo release];
    return dicGhStInfo;
}


//parser script file such as QT0b.plist , we'd better call it in awakeFromNib in UI(once)
//script file format : first level=>array, second level=>dictionary(just contains one key:such as START_TEST_QT0b), third level=>array, fourth level=>dictionary(just contains one key:such as OPEN_UART)
- (NSArray *)parserScriptFile:(NSString *)szScriptFilePath
{
	NSArray		*arrTestItems	= [NSArray arrayWithContentsOfFile:szScriptFilePath];//first level
    NSString    *szLineName     = [m_dicMemoryValues objectForKey:descriptionOfGHStationInfo(IP_LINE_NUMBER)];
	if (!arrTestItems)
	{
		NSRunAlertPanel(@"错误(Error)",
						@"解析剧本档失败。(Parser Script Fail)",
						@"确认(OK)", nil, nil);
        //modify from ATSDebug to NSLog , because this function may move to awakefromnib in UI , and console log isn't created
		NSLog(@"Terminate at [%@], Parser Script fail, Get Nil array from the path [%@]",
			  [[NSDate date] description], szScriptFilePath);
		[NSApp terminate:nil];
		return nil;
	}
	NSMutableArray	*arrTestItemTemp	= [[NSMutableArray alloc] init];
	for (NSDictionary *dictTemp in arrTestItems)//second level
	{
        NSMutableDictionary *dict   = [NSMutableDictionary dictionaryWithDictionary:dictTemp];
        //For REL line: cancel the item witch no need for REL line
        if ([szLineName ContainString:@"REL"] &&
            2 == [dict count] &&
            [[dict objectForKey:kScriptFileNoNeedForREL] boolValue])
        {
            [dict removeObjectForKey:kScriptFileNoNeedForREL];
            NSArray *arrTemp11  = [dict allKeys];
            NSLog(@"This test item \"==== %@ ====\" is no need for REL line!", [arrTemp11 objectAtIndex:0]);
            continue;
        }
        //For other line: cancel the item witch just for REL line
        else if (![szLineName ContainString:@"REL"] &&
            2 == [dict count] &&
            [[dict objectForKey:kScriptFileJustForREL] boolValue])
        {
            [dict removeObjectForKey:kScriptFileJustForREL];
            NSArray *arrTemp12  = [dict allKeys];
            NSLog(@"This test item \"==== %@ ====\" is just for REL line", [arrTemp12 objectAtIndex:0]);
            continue;
        }
        //For all line: cancel the flag if they are useless.
        else if(![dict isKindOfClass:[NSDictionary class]] ||
           1 != [dict count])
        {
            if (2 == [dict count] &&
                [dict objectForKey:kScriptFileNoNeedForREL])
            {
                //remove the flag "NoNeedForREL" if the line is not REL line
                [dict removeObjectForKey:kScriptFileNoNeedForREL];
            }
            else if (2 == [dict count] &&
                     [dict objectForKey:kScriptFileJustForREL])
            {
                //remove the flag "JustForREL" if the line is REL line
                [dict removeObjectForKey:kScriptFileJustForREL];
            }
            else
            {
                NSRunAlertPanel(@"错误(Error)",
                                [NSString stringWithFormat:@"剧本档格式错误: %@ (Script file format error : [%@].)",dict,dict],
                                @"确认(OK)", nil, nil);
                NSLog(@"Terminate at [%@], Script file format error : [%@] , Please connect with ATS",
                      [[NSDate date] description], dict);
                [NSApp terminate:nil];
            }            
        }
		TestItemStruct	*obj_Struct			= [[TestItemStruct alloc] init];
		NSString		*szTestItemName		= @"";
		NSEnumerator	*enumerator			= [dict keyEnumerator];
		id				key;//such as START_TEST_QT0b
		while((key = [enumerator nextObject])) //I think this execute once at most ,Leehua
		{
			if ([[dict objectForKey:key] isKindOfClass:[NSArray class]])
			{
				szTestItemName	= key;
				NSArray         *arrSubItemTemp =   [dict objectForKey:key];//third level
                NSMutableArray  *arrSubItem     =   [NSMutableArray arrayWithArray:arrSubItemTemp];
				for (NSUInteger i = 0; i < [arrSubItemTemp count]; i++)
				{
					id	idObjTemp	= [arrSubItemTemp objectAtIndex:i];//fourth level
                    int j           = [arrSubItemTemp count] - [arrSubItem count];
					if ([idObjTemp isKindOfClass:[NSDictionary class]])
					{
                        //For REL line: delete the subitem witch no need for REL line
                        NSMutableDictionary *idObj  = [NSMutableDictionary dictionaryWithDictionary:idObjTemp];
                        if ([szLineName ContainString:@"REL"] &&
                            2 == [idObj count] &&
                            [[idObj objectForKey:kScriptFileNoNeedForREL] boolValue])
                        {
                            [idObj removeObjectForKey:kScriptFileNoNeedForREL];
                            NSArray *arrTemp21  = [idObj allKeys];
                            NSLog(@"This subitem \"++++ %@ ++++\" is no need for REL line!", [arrTemp21 objectAtIndex:0]);
                            [arrSubItem removeObjectAtIndex:(i - j)];
                            continue;
                        }
                        //For other line: delete the subitem witch just need for REL line
                        else if (![szLineName ContainString:@"REL"] &&
                            2 == [idObj count] &&
                            [[idObj objectForKey:kScriptFileJustForREL] boolValue])
                        {
                            [idObj removeObjectForKey:kScriptFileJustForREL];
                            NSArray *arrTemp22  = [idObj allKeys];
                            NSLog(@"This subitem \"++++ %@ ++++\"is just for REL line!", [arrTemp22 objectAtIndex:0]);
                            [arrSubItem removeObjectAtIndex:(i - j)];
                            continue;
                        }
                        //For all line: cancel the flag if they are useless.
                        else if (1 != [idObj count])
                        {
                            if (2 == [idObj count] &&
                                [idObj objectForKey:kScriptFileNoNeedForREL])
                            {
                                //remove the flag "NoNeedForREL" if the line is not REL line
                                [idObj removeObjectForKey:kScriptFileNoNeedForREL];
                                [arrSubItem replaceObjectAtIndex:(i - j) withObject:idObj];
                            }
                            else if (2 == [idObj count] &&
                                     [idObj objectForKey:kScriptFileJustForREL])
                            {
                                //remove the flag "JustForREL" if the line is REL line
                                [idObj removeObjectForKey:kScriptFileJustForREL];
                                [arrSubItem replaceObjectAtIndex:(i - j) withObject:idObj];
                            }
                            else
                            {
                                NSRunAlertPanel(@"错误(Error)",
                                                [NSString stringWithFormat:
                                                 @"剧本档格式错误: %@ (Script file format error : [%@].)",
                                                 szTestItemName,szTestItemName],
                                                @"确认(OK)", nil, nil);
                                NSLog(@"Terminate at [%@], Script file format error : [%@] SubItem Error, Please connect with ATS",
                                      [[NSDate date] description], szTestItemName);
                                [NSApp terminate:nil];
                            }
                        }
                    }
                    else
                    {
                        NSRunAlertPanel(@"错误(Error)",
										[NSString stringWithFormat:
										 @"剧本档格式错误: %@ (Script file format error : [%@].)",
										 szTestItemName,szTestItemName],
										@"确认(OK)", nil, nil);
						NSLog(@"Terminate at [%@], Script file format error : [%@] SubItem Error, Please connect with ATS",
							  [[NSDate date] description], szTestItemName);
						[NSApp terminate:nil];
                    }
				}
				obj_Struct.ItemName	= szTestItemName;
				obj_Struct.TestSort	= arrSubItem;
				[arrTestItemTemp addObject:obj_Struct];
			}
			else
				continue;//sub items wasn't saved as array, this item won't be executed
		}
		[obj_Struct release];
	}
	NSArray	*arrayReturn	= [NSArray arrayWithArray:arrTestItemTemp];
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
-(BOOL)performSELToClass:(NSDictionary *)dictItem
			 SubItemName:(NSString *)szSubName
				ItemName:(NSString *)szItemName
{
    ATSDebug(@"^=^ Begin subItem : %@ ===> parameters:\n{\n%@}",
			 szSubName, [self formatLog_transferObject:dictItem]);
    NSDate			*date				= [NSDate date];//begin time
    NSTimeInterval	timeDuration		= 0.0;
	NSNumber		*numSubItemResult;
	SEL				selectorForFunction	= NSSelectorFromString(szSubName);
	if ([self respondsToSelector:selectorForFunction])
        numSubItemResult	= [self performSelector:selectorForFunction
									  withObject:dictItem
									  withObject:m_szReturnValue];
	else
	{
        NSRunAlertPanel([NSString stringWithFormat:@"错误(Error) (Slot:%@)",
						 m_szPortIndex],
						[NSString stringWithFormat:@"无法响应函数: %@。(Can't response function [%@])",
						 szSubName,szSubName],
						@"确认(OK)", nil, nil);
        return NO;
	}
    timeDuration	= [[NSDate date] timeIntervalSinceDate:date];//end time
	NSString	*szResult	= ([numSubItemResult boolValue] ? @"PASS" : @"FAIL");
    NSString	*szTitle	= [NSString stringWithFormat:
							   @"%@ (TestResult : %@ ; Duration : %.6fs)",
							   szSubName,szResult,timeDuration];
	NSImage	*imageResult	= [numSubItemResult boolValue] ? [NSImage imageNamed:NSImageNameStatusAvailable] : [NSImage imageNamed:NSImageNameStatusUnavailable];
	// Add for Debug winodw Subitem result
	[m_arrSingleItemInfo addObject:[NSDictionary dictionaryWithObjectsAndKeys:
									imageResult,			@"SubResult",
									szSubName,				@"SubName",
									[NSString stringWithFormat:@"%.6fs",timeDuration], @"DurationTime",
									[NSNumber numberWithInteger:[m_arrSingleItemInfo count]], @"Index",nil]];
	
	ATSDebug(@"RETURN_VALUE ===> %@\n%@",
			 m_szReturnValue,[self formatLog:@"+" title:[NSString stringWithFormat:@"[%d] %@",[m_arrSingleItemInfo count],szTitle]]);
    
    //Winter 2012.4.18
	//Write cycle time log,add for each sub test item
    if([[self getValueFromXML:kPD_UserDefaults
					  mainKey:kPD_UserDefaults_SaveCycleTimeLog,nil] boolValue])
    {
        NSString	*szTarget			= @"";
        NSString	*szCommand			= @"";
        NSString	*szCycleTimeName	= [NSString stringWithFormat:
										   @"%@/%@_%@/%@_%@_CycleTime.csv",
										   kPD_LogPath,m_szPortIndex,m_szStartTime,m_szPortIndex,m_szStartTime];
        NSString	*szParameter		= [self formatLog_transferObject:dictItem];
        NSArray		*aryParameter		= [szParameter componentsSeparatedByString:@"\n"];
        if ([szSubName isEqualToString:@"SEND_COMMAND:"])
        {
            for(NSString *szValue in aryParameter)
            {
                if ([szValue ContainString:@"TARGET ==>"])
                    szTarget	= [szValue SubFrom:@"TARGET ==> " include:NO];
                if ([szValue ContainString:@"STRING ==>"])
				{
                    szCommand	= [szValue SubFrom:@"STRING ==> " include:NO];
                    szCommand	= [szCommand stringByReplacingOccurrencesOfString:@","
																	 withString:@" "];
                }
            }
        }
        if([szSubName isEqualToString:@"READ_COMMAND:RETURN_VALUE:"])
            for(NSString *szValue in aryParameter)
                if ([szValue ContainString:@"TARGET ==>"])
                    szTarget = [szValue SubFrom:@"TARGET ==> " include:NO];
        if([szSubName isEqualToString:@"OPEN_TARGET:"])
            for(NSString *szValue in aryParameter)
                if ([szValue ContainString:@"TARGET ==>"])
                    szTarget = [szValue SubFrom:@"TARGET ==> " include:NO];
        if([szSubName isEqualToString:@"CLOSE_TARGET:RETURN_VALUE:"])
            for(NSString *szValue in aryParameter)
                if ([szValue ContainString:@"TARGET ==>"])
                    szTarget = [szValue SubFrom:@"TARGET ==> " include:NO];
        NSString	*szBeginLog		= [NSString stringWithFormat:
									   @",%@,%@,%.6f,%@,%@\n",
									   szResult,szSubName,timeDuration,szCommand,szTarget];
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
-(BOOL)singleItemTest:(NSArray *)arrDetailTest
			 ItemName:(NSString *)szItemName
		 currentIndex:(NSInteger)iIndex
{
	// Some vars init here.
	[m_arrSingleItemInfo removeAllObjects];
    m_bSubTest_PASS_FAIL	= YES;
	BOOL			bSubItemResult		= YES;
    [m_dicMemoryValues setValue:[NSNumber numberWithBool:YES]
						 forKey:kFZ_Script_TestResult];
    NSString		*szStartItemLog		= [self formatLog:@"="
										   title:[NSString stringWithFormat:
												  @"START TEST %@ (Item%d)",
												  [szItemName uppercaseString],iIndex]];
	ATSDebug(@"%@",szStartItemLog);
    [IALogs CreatAndWriteUARTLog:szStartItemLog
						  atTime:nil
					  fromDevice:nil
						withPath:[NSString stringWithFormat:
								  @"%@/%@_%@/%@_%@_Uart.txt",
								  kPD_LogPath,m_szPortIndex,m_szStartTime,m_szPortIndex,m_szStartTime]
						  binary:NO];
    
    //Winter 2012.4.18
	//Write cycle time log, add for each item name
    if([[self getValueFromXML:kPD_UserDefaults
					  mainKey:kPD_UserDefaults_SaveCycleTimeLog,nil]boolValue])
    {
        NSString	*szCycleTimeName	= [NSString stringWithFormat:
										   @"%@/%@_%@/%@_%@_CycleTime.csv",
										   kPD_LogPath,m_szPortIndex,m_szStartTime,m_szPortIndex,m_szStartTime];
        NSString	*szItemNameLog		= [szItemName stringByReplacingOccurrencesOfString:@","
																		 withString:@" "];
        NSString	*szBeginLog			= [NSString stringWithFormat:
										   @"%ld. %@,,,,,\n",
										   (long)iIndex,szItemNameLog];
        [IALogs CreatAndWriteSingleCSVLog:szBeginLog
								 withPath:szCycleTimeName];
    }
    
    NSDate			*dateSingleItemStart	= [NSDate date];
    NSTimeInterval	dSingleItemSpend		= 0.0;
    m_bCancelFlag	= NO;	//before item start testing, set cancel flag "not allow to cancel items"
    
    //For Pressure Test, Add by leehua 2013.10.18 begin
    NSArray *aryCancelItems = nil;
    
    NSMutableArray	*aryFailSubItems		= [[NSMutableArray alloc] init];
    for (int i = 0 ; i < [arrDetailTest count] ; i++)
    {
        //For Pressure Test, Add by leehua 2013.10.18 begin
        if (aryCancelItems && [aryCancelItems containsObject:[NSString stringWithFormat:@"%i",i]]) continue;
        //get sub item
        NSDictionary	*dictSubItem	= [arrDetailTest objectAtIndex:i];
		NSArray			*arrKeys		= [dictSubItem allKeys];
		NSString		*szSubItemName	= [arrKeys objectAtIndex:0]; //0:just one item
		
        //get params of sub item
		NSDictionary	*dictDetailPara	= [dictSubItem objectForKey:szSubItemName];
                
        //For Pressure Test, Add by leehua 2013.10.18 begin
        if ([[dictDetailPara objectForKey:@"NeedCancel"] boolValue] && [szSubItemName isEqualToString:@"NOAUTH_CANCEL"])
        {
            if (!m_bFixtureControlOnhand)
            {
                NSString *szCancelItems = [dictDetailPara objectForKey:@"CancelItems"];
                aryCancelItems = [szCancelItems componentsSeparatedByString:@","];
            }
            else
            {
                NSMutableString *szItems = [NSMutableString stringWithString:@""];
                NSString *szCPT6000Case = [dictDetailPara objectForKey:@"NoCPT6000Cancel"];
                NSString *szCPT6100Case = [dictDetailPara objectForKey:@"NoCPT6100Cancel"];
                if (![[m_dicPorts allKeys] containsObject:@"CPT6000"] && szCPT6000Case)
                {
                    [szItems isEqualToString:@""]?[szItems appendString:szCPT6000Case]:[szItems appendString:[NSString stringWithFormat:@",%@",szCPT6000Case]];
                }
                if (![[m_dicPorts allKeys] containsObject:@"CPT6100"] && szCPT6100Case)
                {
                    [szItems isEqualToString:@""]?[szItems appendString:szCPT6100Case]:[szItems appendString:[NSString stringWithFormat:@",%@",szCPT6100Case]];
                }
                aryCancelItems = [szItems componentsSeparatedByString:@","];
            }
            continue;
        }
        if ([szSubItemName isEqualToString:@"NOAUTH_CANCEL"]) continue;
    // Here end for the Press Test
        
 		// Loop sub test item function.
        NSRange	rangeCancelItems	= [szSubItemName rangeOfString:kFZ_Script_CancelItems];
		NSRange	rangeLoopName		= [szSubItemName rangeOfString:kFZ_Script_LoopItem];
        if(NSNotFound != rangeCancelItems.location
		   && rangeCancelItems.length>0
		   && (rangeCancelItems.location+rangeCancelItems.length) <= [szSubItemName length])
		{
            //cancel some sub items
            if (m_bCancelFlag)
            {
                NSInteger	iCancelCount	= [[dictDetailPara objectForKey:kFZ_Script_CancelCount] intValue];
                i				+= iCancelCount;
                m_bCancelFlag	= NO;
            }
        }
		else if (NSNotFound != rangeLoopName.location
				 && rangeLoopName.length > 0
				 && (rangeLoopName.location+rangeLoopName.length) <= [szSubItemName length])
		{
            //if sub name equal "LoopItem" and test fail
            NSInteger	iStart=0,iEnd=0,iMaxRepeatTime=0;
            id			loopStart		= [dictDetailPara objectForKey:kFZ_Script_LoopStart];
            id			loopEnd			= [dictDetailPara objectForKey:kFZ_Script_LoopEnd];
            id			loopRepeatTime	= [dictDetailPara objectForKey:kFZ_Script_LoopRepeatTime];
            NSNumber	*bPassContinue	= [dictDetailPara objectForKey:@"PassContinue"];
            if ((bPassContinue == nil) && /*bSingleTestResult*/m_bSubTest_PASS_FAIL)
                continue;
            if (loopStart != nil
				&& loopEnd != nil
				&& loopRepeatTime != nil)
            {
                BOOL	bStatus			= NO;
                BOOL	bResetResult	= YES;
                iStart			= [loopStart intValue];
                iEnd			= [loopEnd intValue];
                iMaxRepeatTime	= [loopRepeatTime intValue];
                
                NSMutableArray	*aryLoopItems	= [[NSMutableArray alloc] init];
                
                //put loop items to an array
                for(int iIndex=iStart; iIndex<=iEnd; iIndex++)
                {
                    NSDictionary	*dictSubItem	= [arrDetailTest objectAtIndex:iIndex];
                    [aryLoopItems addObject:dictSubItem];
                }
                
                for(int j=0; j<[aryFailSubItems count]; j++)
                    if([aryLoopItems containsObject:[aryFailSubItems objectAtIndex:j]])
                    {
                        //some item need to loop, fail
                        if (bPassContinue && [bPassContinue boolValue])
                            iMaxRepeatTime	= 0;
                        else
                            bStatus			= YES;
                    }
                    else
                        //some item fail, but not contained marked to redo(in loop)
                        bResetResult = NO;
                
                //do loop
                if((bStatus && bResetResult)
				   || ((bPassContinue) && ([bPassContinue boolValue])))
                {
                    m_bSubTest_PASS_FAIL	= YES;
                    for (int iLoop = 0; iLoop < iMaxRepeatTime; iLoop++)
                    {
                        //set default result of loop items "PASS"
                        bStatus		= YES;
                        for(int j=iStart; j<=iEnd; j++)
                        {
                            NSDictionary	*dictSubItem		= [arrDetailTest objectAtIndex:j];
                            NSArray			*arrKeys			= [dictSubItem allKeys];
                            NSString		*szSubItemName		= [arrKeys objectAtIndex:0];
                            NSRange			rangeCancelItems	= [szSubItemName rangeOfString:kFZ_Script_CancelItems];
                            if(NSNotFound != rangeCancelItems.location
							   && rangeCancelItems.length>0
							   && (rangeCancelItems.location+rangeCancelItems.length) <= [szSubItemName length])
                            {
                                if (m_bCancelFlag)
								{
                                    NSInteger	iCancelCount	= [[dictDetailPara objectForKey:kFZ_Script_CancelCount] intValue];
                                    j				+= iCancelCount;
                                    m_bCancelFlag	= NO;
                                }
                            }
                            else
                            {
                                NSDictionary	*dictDetailPara	= [dictSubItem objectForKey:szSubItemName];
                                bSubItemResult	= [self performSELToClass:dictDetailPara
															 SubItemName:szSubItemName
																ItemName:szItemName];
                                bStatus			&= bSubItemResult;
                                if([aryFailSubItems containsObject:dictSubItem])
                                    [aryFailSubItems removeObject:dictSubItem];
                            }
                        }
                        //if these items all pass ,break
                        if ((bPassContinue) && ([bPassContinue boolValue]))
						{
                            if (!bStatus)
                                break;
                        }
                        else
                            if(bStatus)
                                break;
                    }
                    m_bSubTest_PASS_FAIL	&= bStatus;
                }
                [aryLoopItems release];
            }
        }
		else
		{
			bSubItemResult	= [self performSELToClass:dictDetailPara
										 SubItemName:szSubItemName
											ItemName:szItemName];
            if(!bSubItemResult)
				[aryFailSubItems addObject:dictSubItem];
            m_bSubTest_PASS_FAIL	&= bSubItemResult;
		}
        
        m_bLastItemResult	= bSubItemResult;
	}
    [aryFailSubItems release];
  
    dSingleItemSpend	= [[NSDate date] timeIntervalSinceDate:dateSingleItemStart];
    [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%.6f",dSingleItemSpend]
						  forKey:kFZ_SingleTime];
    NSString	*szResult		= (m_bSubTest_PASS_FAIL ? @"PASS" : @"FAIL");
    NSString	*szTitle		= [NSString stringWithFormat:
								   @"END TEST %@ (TestResult : %@ ; Duration : %.6fs)",
								   szItemName,szResult,dSingleItemSpend];
    NSString	*szEndItemLog	= [self formatLog:@"=" title:szTitle];
	ATSDebug(@"%@",szEndItemLog);
    
    //Winter 2012.4.18
	//Write cycle time log, add for each single item
    if([[self getValueFromXML:kPD_UserDefaults
					  mainKey:kPD_UserDefaults_SaveCycleTimeLog,nil]boolValue])
    {
        NSString	*szCycleTimeName	= [NSString stringWithFormat:
										   @"%@/%@_%@/%@_%@_CycleTime.csv",
										   kPD_LogPath,m_szPortIndex,m_szStartTime,m_szPortIndex,m_szStartTime];
        NSString	*szItemNameLog		= [szItemName stringByReplacingOccurrencesOfString:@","
																		 withString:@" "];
        NSString	*szBeginLog			= [NSString stringWithFormat:
										   @"Total_Test_%@,%@,,%.6f,,\n",
										   szItemNameLog,szResult,dSingleItemSpend];
        [IALogs CreatAndWriteSingleCSVLog:szBeginLog
								 withPath:szCycleTimeName];
    }
    // Deal with return values
    [m_szReturnValue replaceOccurrencesOfString:kFunnyZoneComma
									 withString:kFunnyZoneBlank1
										options:NSCaseInsensitiveSearch
										  range:NSMakeRange(0, [m_szReturnValue length])];//
    [m_szReturnValue replaceOccurrencesOfString:kFunnyZoneEnter
									 withString:kFunnyZoneBlank1
										options:NSCaseInsensitiveSearch
										  range:NSMakeRange(0, [m_szReturnValue length])];
    [m_szReturnValue replaceOccurrencesOfString:kFunnyZoneNewLine
									 withString:kFunnyZoneBlank1
										options:NSCaseInsensitiveSearch
										  range:NSMakeRange(0, [m_szReturnValue length])];
	return m_bSubTest_PASS_FAIL;
}

-(BOOL)isFinished
{
	//each test will init one testProgress , so m_bIsFinished need not be set to NO when in start function
    return m_bIsFinished;
}

-(void)setDelegate
{
    //set deletegate for uart objects
    NSArray		*aryDevices		= [m_dicPorts allKeys];
    NSInteger	iDeviceCount	= [aryDevices count];
    for(NSInteger iIndex=0; iIndex<iDeviceCount; iIndex++)
    {
        PEGA_ATS_UART	*uartObj	= [[m_dicPorts objectForKey:[aryDevices objectAtIndex:iIndex]]
									   objectAtIndex:kFZ_SerialInfo_UartObj];
        [uartObj setDelegate:self];
    }
}

- (void)start
{
	
    // auto test system
    if (gbIfNeedRemoteCtl)
    {
        [m_dicMemoryValues   setObject:@"YES" forKey:@"IS_REMOTE_MODE"];
    }
	else
    {
        [m_dicMemoryValues   setObject:@"NO" forKey:@"IS_REMOTE_MODE"];
    }
    
	[m_dicButtonBuffer removeAllObjects];
    m_bEmptyResponse	= NO;//Leehua
    m_bProcessIssue = NO;
	m_iAlsoAllowedCount	= 0;
    m_iAllCount         = 0;
	
    // auto test system (initial fail info)
    NSMutableString *szFailInfo = [[NSMutableString alloc] initWithString:@""];

    NSMutableString *szUnitShowMessage = [[NSMutableString alloc] initWithString:@""];
    NSLog(@"testprocess:%@",self);
    NSNotificationCenter	*nc	= [NSNotificationCenter defaultCenter];

    //Start, Add By Ming 20111021
    NSString	*szCompanyPart	= [NSString stringWithFormat:@"PEGATRON ATS\n"];
    NSString	*szProject		= [NSString stringWithFormat:@"PROJECT: %@\n",
								   [m_dicMemoryValues objectForKey:descriptionOfGHStationInfo(IP_PRODUCT)]];
    NSString	*szStation		= [NSString stringWithFormat:@"STATION: %@\n",
								   [m_dicMemoryValues objectForKey:descriptionOfGHStationInfo(IP_STATION_ID)]];
    NSString	*szVer			= [NSString stringWithFormat:@"Overlay_Version : %@\n",
								   uiVersion];
    NSString	*szBeginUart	= [NSString stringWithFormat:@"%@%@%@%@",
								   szCompanyPart,szProject,szStation,szVer];
    int			iCount			= 0; // to memory "RX no reponse" count
    //for measure is continous or not, if new item has DUT command, and RX normal, anew calculate iCount
    m_itemHasDUTRX	= NO;
    [IALogs CreatAndWriteUARTLog:szBeginUart
						  atTime:nil
					  fromDevice:nil
						withPath:[NSString stringWithFormat:
								  @"%@/%@_%@/%@_%@_Uart.txt",
								  kPD_LogPath,m_szPortIndex,m_szStartTime,m_szPortIndex,m_szStartTime]
						  binary:NO];
	[IALogs CreatAndWriteConsoleInformation:szBeginUart
								   withPath:[NSString stringWithFormat:
											 @"%@/%@_%@/%@_%@_DEBUG.txt",
											 kPD_LogPath,m_szPortIndex,m_szStartTime,m_szPortIndex,m_szStartTime]];
    //End Ming 20111021
    
    //Winter 2012.4.18
	//Write cycle time log, add title information
	if([[self getValueFromXML:kPD_UserDefaults
					  mainKey:kPD_UserDefaults_SaveCycleTimeLog, nil] boolValue])
    {
        NSString	*szCycleTimeName	= [NSString stringWithFormat:
										   @"%@/%@_%@/%@_%@_CycleTime.csv",
										   kPD_LogPath,m_szPortIndex,m_szStartTime,m_szPortIndex,m_szStartTime];
        NSString	*szBeginCycle		= [NSString stringWithFormat:
										   @"STATION: %@,Overlay_Version : %@,,,,\n",
										   [m_dicMemoryValues objectForKey:descriptionOfGHStationInfo(IP_STATION_ID)],
										   uiVersion];
        NSString	*szCycltTimeTitle	= [NSString stringWithFormat:
										   @"TestItems,Status,SubTestItems,CostTime,Commands,Target\n"];
        NSString	*szBeginLog			= [NSString stringWithFormat:
										   @"%@%@",
										   szBeginCycle,szCycltTimeTitle];
        [IALogs CreatAndWriteSingleCSVLog:szBeginLog
								 withPath:szCycleTimeName];
    }
	ATSDebug(@"%@",[self formatLog:@"#"
							 title:@"START DUT PROGRESS"]);
    // CSV file name;
	NSString	*szCSVFileName	= [NSString stringWithFormat:
								   @"%@/%@_%@/%@_%@_CSV.csv",
								   kPD_LogPath,m_szPortIndex,m_szStartTime,m_szPortIndex,m_szStartTime];
	NSString	*szCSVBegin		= [NSString stringWithFormat:
								   @"TestName,Status,Value,DownLimit,UpLimit,TestTime\n"];
	NSString	*szTSP			= [NSString stringWithFormat:
								   @"TSP,0,%@_%@,,,\n",
								   [m_dicMemoryValues objectForKey:descriptionOfGHStationInfo(IP_PRODUCT)],
								   [m_dicMemoryValues objectForKey:descriptionOfGHStationInfo(IP_STATION_TYPE)]];
	NSString	*szScript		= [NSString stringWithFormat:
								   @"Script_Version,0,%@,,,\n",
								   m_szScriptVersion];
	NSString	*szVersion		= [NSString stringWithFormat:
								   @"Overlay_Version,0,%@,,,\n",
								   uiVersion];
    NSString	*szBeginCSV		= [NSString stringWithFormat:
								   @"%@%@%@%@",
								   szCSVBegin,szTSP,szScript,szVersion];
	[IALogs CreatAndWriteSingleCSVLog:szBeginCSV
							 withPath:szCSVFileName];
	// Do some init here
    NSDate	*dateStartProgress	= [NSDate date];
	//add by betty 2012.4.24 for init m_bNoUploadPDCA value with muifa setting
	m_bOfflineDisablePudding	= [[self getValueFromXML:kPD_UserDefaults
									 mainKey:@"OfflineDisablePudding",nil] boolValue];
	m_bValidationDisablePudding = [[self getValueFromXML:kPD_UserDefaults
												 mainKey:@"ValidationDisablePudding",nil] boolValue];
    [m_dicMemoryValues setObject:dateStartProgress
						  forKey:@"Single_Start_Time"];//for add SFIS
	NSString	*sz_TestStatus	= kFunnyZoneStatusTest;
    //add for summary log 2011.12.12
    NSMutableString	*szTestNames		= [[NSMutableString alloc] initWithString:@""];
    NSMutableString	*szUpperLimits		= [[NSMutableString alloc] initWithString:@""];
    NSMutableString	*szDownLimits		= [[NSMutableString alloc] initWithString:@""];
    NSMutableString	*szValueList		= [[NSMutableString alloc] initWithString:@""];
    NSMutableString	*szErrorInfo		= [[NSMutableString alloc] initWithString:@""];
    NSString		*szSummaryLogName	= [NSString stringWithFormat:
										   @"/vault/summary/%@_VAULT_LOG/%@_%@.csv",
										   [m_dicMemoryValues objectForKey:descriptionOfGHStationInfo(IP_PRODUCT)],
										   m_szScriptName,uiVersion];

    //end for summary log
    //set delegate for uart object for writing debug log
    [self setDelegate];
	
    //start PDCA
    [self startPuddingUploadFlow];
    
    // Do the Loop test for all the test items.
	// Lorky Tips' This loop test is the kernal test, you should focus on this loop test first.
	for (NSUInteger i = 0; i < [m_arrayScript count]; i++)
	{
		// Just do some initlize here.
		[m_strSpecName		setString:kFZ_Script_JudgeCommonBlack];
        [m_dicMemoryValues	setObject:@"{NA}" forKey:kFZ_TestLimit];
		[m_szUnit			setString:@""];
        m_bCancelToEnd			= NO;
        m_bNoParametric			= NO;
        m_iPriority				= 0;
        m_bSubTest_PASS_FAIL	= YES;
        m_newItemFlag			= YES;
		
		TestItemStruct	*obj_TIS			= [m_arrayScript objectAtIndex:i];
		NSString		*szCurrentItemName	= [obj_TIS ItemName];
        if (szCurrentItemName == nil)
            szCurrentItemName	= @"";
        [m_dicMemoryValues setObject:szCurrentItemName
							  forKey:kFunnyZoneCurrentItemName];
		NSArray			*arrDetailTest		= [obj_TIS TestSort];
        [m_szErrorDescription setString:@""];//each item initiaze err description as @""
		//===== for case fail or pass     add by Kyle 2011.12.15 =====
        if ([m_muArrayCancelCase containsObject:szCurrentItemName])
        {
            [m_muArrayCancelCase removeObject:szCurrentItemName];
			// Added by Izual_Lu on 2013-03-19 for summary log columns corresponding.
			[szTestNames appendFormat:@",\"%@\"", szCurrentItemName];
			[szUpperLimits appendString:@","];
			[szDownLimits appendString:@","];
			[szValueList appendString:@","];
            continue;
        }
        else
			// Lorky Tips' Here will be enter the single item test. It will deal the events for each item.
            m_bSubTest_PASS_FAIL	= [self singleItemTest:arrDetailTest
											   ItemName:szCurrentItemName
										   currentIndex:i];
        //===========
        //if Rx No response continuously happened on 3 test items, stop test.
        if (!m_newItemFlag)
        {
            iCount++;
            if (m_itemHasDUTRX)
            {
                iCount = 1;
                m_itemHasDUTRX	= NO;
            }
        }
        if (iCount == 3)
        {
            m_bCancelToEnd	= YES;
            iCount = 0;
        }
        m_bFinalResult	&= m_bSubTest_PASS_FAIL;
		
		if (i == [m_arrayScript count] - 1)
		{
			if (m_bFinalResult)
				sz_TestStatus = kFunnyZoneStatusPass;
			else
				sz_TestStatus = kFunnyZoneStatusFail;
		}
        
        //show value
        if ([m_dicMemoryValues objectForKey:kFZ_UI_SHOWNVALUE]
			&& ![[m_dicMemoryValues objectForKey:kFZ_UI_SHOWNVALUE] isEqualToString:@""])
        {
            [m_szReturnValue setString:[m_dicMemoryValues objectForKey:kFZ_UI_SHOWNVALUE]];
            [m_dicMemoryValues setValue:@""
								 forKey:kFZ_UI_SHOWNVALUE];
        }
        
        //show itemName
        if ([m_dicMemoryValues objectForKey:kFZ_UI_SHOWNNAME]
			&& ![[m_dicMemoryValues objectForKey:kFZ_UI_SHOWNNAME] isEqualToString:@""])
        {
            szCurrentItemName	= [m_dicMemoryValues objectForKey:kFZ_UI_SHOWNNAME];
            [m_dicMemoryValues removeObjectForKey:kFZ_UI_SHOWNNAME];
        }
        
        //set image for "pass" and "fail"
        NSImage	*imageResult	=  (m_bSubTest_PASS_FAIL
									? [NSImage imageNamed:NSImageNameStatusAvailable]
									: [NSImage imageNamed:NSImageNameStatusUnavailable]);
		// Lorky Tips' I think this function upload test data to PDCA and format csv test file.
		[self writeForNormalSpecName:szCurrentItemName
							  status:m_bSubTest_PASS_FAIL
							 csvPath:szCSVFileName
							sumNames:szTestNames
						 sumUpLimits:szUpperLimits
						 sumDnLimits:szDownLimits
						sumValueList:szValueList
					errorDescription:m_szErrorDescription
							sumError:szErrorInfo
						CurrentIndex:i];
        // Get the limit of test item and show them to UI
        NSString			*szCurrentTestItemLimit	= [m_dicMemoryValues objectForKey:kFZ_TestLimit];
		
		// Add item name and limit
		NSString * strNameAndSpec = [NSString stringWithFormat:@"Item Name:%@, %@",szCurrentItemName, szCurrentTestItemLimit];
		ATSDebug(@"%@",strNameAndSpec);
		[IALogs CreatAndWriteUARTLog:strNameAndSpec
							  atTime:nil
						  fromDevice:nil
							withPath:[NSString stringWithFormat:
									  @"%@/%@_%@/%@_%@_Uart.txt",
									  kPD_LogPath,m_szPortIndex,m_szStartTime,m_szPortIndex,m_szStartTime]
							  binary:NO];
		
		
        //UI relative, Post test information to UI.
        NSString			*szReturnValue			= [NSString stringWithString:m_szReturnValue];
		NSAttributedString	*szUartLog				= [[NSAttributedString alloc] initWithAttributedString:m_strSingleUARTLogs];
		NSAttributedString	*szConsoleMessage		= [[NSAttributedString alloc] initWithAttributedString:m_strConsoleMessage];
		NSArray				*arrSingleItemInfo		= [NSArray arrayWithArray:m_arrSingleItemInfo];
		
        if ([m_dicMemoryValues valueForKey:kFunnyZoneShowCoFONUI] == nil)
        {
            NSDictionary	*dictALLView	= [NSDictionary dictionaryWithObjectsAndKeys:
											   kAllTableView,									kFunnyZoneIdentify,
											   [NSString stringWithFormat:@"[%d]",i+1],			kAllTableViewIndex,
											   imageResult,										kAllTableViewResultImage,
											   szCurrentTestItemLimit,							kAllTableViewSpec,
											   szCurrentItemName,								kAllTableViewItemName,
											   szReturnValue,									kAllTableViewRetureValue,
											   [m_dicMemoryValues objectForKey:kFZ_SingleTime],	kAllTableViewCostTime,
											   [NSNumber numberWithInt:i],						kFunnyZoneCurrentIndex,
											   [NSNumber numberWithInt:[m_arrayScript count]],	kFunnyZoneSumIndex,
											   [NSNumber numberWithBool:m_bSubTest_PASS_FAIL],	kFunnyZoneSingleItemResult,
											   sz_TestStatus,									kFunnyZoneStatus,
											   szConsoleMessage,								kFunnyZoneConsoleMessage,
											   szUartLog,										kFunnyZoneUartLog,
											   arrSingleItemInfo,								kFunnyZoneSubitemInfo,
											   m_szPortIndex,									kFunnyZonePortIndex,
											   m_szISN,											kFunnyZoneISN,nil];
            [self postTestInfoToUI:dictALLView];
        }
		else
        {
            if (![[m_dicMemoryValues valueForKey:kFunnyZoneShowCoFONUI] boolValue])
            {
                NSDictionary	*dictALLView	= [NSDictionary dictionaryWithObjectsAndKeys:
												   kAllTableView,									kFunnyZoneIdentify,
												   [NSString stringWithFormat:@"[%d]",i+1],			kAllTableViewIndex,
												   imageResult,										kAllTableViewResultImage,
												   szCurrentTestItemLimit,							kAllTableViewSpec,
												   szCurrentItemName,								kAllTableViewItemName,
												   szReturnValue,									kAllTableViewRetureValue,
												   [m_dicMemoryValues objectForKey:kFZ_SingleTime],	kAllTableViewCostTime,
												   [NSNumber numberWithInt:i],						kFunnyZoneCurrentIndex,
												   [NSNumber numberWithInt:[m_arrayScript count]],	kFunnyZoneSumIndex,
												   [NSNumber numberWithBool:m_bSubTest_PASS_FAIL],	kFunnyZoneSingleItemResult,
												   sz_TestStatus,									kFunnyZoneStatus,
												   szConsoleMessage,								kFunnyZoneConsoleMessage,
												   arrSingleItemInfo,								kFunnyZoneSubitemInfo,
												   m_szPortIndex,									kFunnyZonePortIndex,
												   szUartLog,										kFunnyZoneUartLog,
												   m_szISN,											kFunnyZoneISN,nil];
                [self postTestInfoToUI:dictALLView];
            }
            [m_dicMemoryValues removeObjectForKey:kFunnyZoneShowCoFONUI];
        }
		[szUartLog release];
		[szConsoleMessage release];
		
        // auto test system (combine fail info)
        if (!m_bSubTest_PASS_FAIL)
        {
            if ([szFailInfo isEqualTo:@""] ||
                nil == szFailInfo)
            {
                [szFailInfo appendFormat:@"%@", szCurrentItemName];
            }
            else
            {
                [szFailInfo appendFormat:@",%@", szCurrentItemName];
            }
            NSString    *strProcessName    = @"";
            for (strProcessName in m_arrProItems)
            {
                if ([szCurrentItemName ContainString:strProcessName])
                {
                    [szUnitShowMessage appendFormat:@"%@:%@;", szCurrentItemName,szReturnValue];
                    [m_dicMemoryValues setObject:szUnitShowMessage forKey:@"ProcessMessage"];
                    ATSDebug(@"Unit will show message%@",szUnitShowMessage);
                    break;
                }
            }
        }
        
		//add for write network cb stations csv log
        if ([[m_dicNetWorkCBStation allKeys] count] > 0)
        {
            NSString	*szCBStationResult;
            NSArray		*arrKey	= [m_dicNetWorkCBStation allKeys];
            for (int iKey = 0; iKey < [arrKey count]; iKey++)
            {
                szCBStationResult	= [m_dicNetWorkCBStation objectForKey:[arrKey objectAtIndex:iKey]];
                int	iStatus	= 1;
                if ([szCBStationResult isEqualToString:@"PASS"])
                    iStatus	= 0;
                else
                    iStatus	= 1;
                
                NSString	*szCheckStationname	= [NSString stringWithFormat:
												   @"NetWork CB:%@,%d,%@,PASS,PASS,\n",
												   [arrKey objectAtIndex:iKey],
												   iStatus,
												   szCBStationResult];
                [IALogs CreatAndWriteSingleCSVLog:szCheckStationname
										 withPath:szCSVFileName];
            }
            [m_dicNetWorkCBStation removeAllObjects];
        }
        [m_szReturnValue setString:@""];
		[m_strConsoleMessage setAttributedString:[[[NSAttributedString alloc] initWithString:@""] autorelease]];
        [m_strSingleUARTLogs setAttributedString:[[[NSAttributedString alloc] initWithString:@""] autorelease]];
		
        //remove for judge spec
        [m_dicMemoryValues removeObjectForKey:kFZ_Cof_TestLimit];
        [m_dicMemoryValues removeObjectForKey:kFZ_MP_TestLimit];
        //if this item fail and cancel to end
        if (m_bCancelToEnd && !m_bSubTest_PASS_FAIL)
		{
            //modify by yaya,2014.8.8. just run end test item.
            int				iCancelNumber		= 2; //default cancel to end number = 2
            //Modified for the multi script.
            NSDictionary	*dicCancelSetting	= [kPD_UserDefaults objectForKey:@"CancelToEndSetting"];
            if (nil != dicCancelSetting)
            {
                NSArray	*arrCancelSettingScript	= [dicCancelSetting allKeys];
                for (NSString *szStationNameTemp in arrCancelSettingScript)
                    if ([szStationNameTemp isEqualToString:m_szScriptName])
                    {
                        iCancelNumber	+= [[[dicCancelSetting objectForKey:szStationNameTemp]
											 objectForKey:@"ReduceNumberOfCancelToEnd"]intValue];
                        break;
                    }
            }
            if (i <= ([m_arrayScript count] - iCancelNumber))
			{
				// Added by Izual_Lu on 2013-03-19 for summary log columns corresponding.
				for(int i0=i+1; i0<=[m_arrayScript count]-iCancelNumber; i0++)
				{
					[szTestNames appendFormat:@",\"%@\"", [(TestItemStruct*)[m_arrayScript objectAtIndex:i0] ItemName]];
					[szUpperLimits appendString:@","];
					[szDownLimits appendString:@","];
					[szValueList appendString:@","];
				}
                i	= [m_arrayScript count] - iCancelNumber;
			}
		}
	}
    
    NSString	*szSNLog			= [NSString stringWithFormat:@"ISN,0,%@,,,\n",m_szISN];
    NSDate		*dateEnd			= [NSDate date];
	double		dProgressCostTime	= [dateEnd timeIntervalSinceDate:dateStartProgress];
	NSString	*szEndInfoToCSV		= [NSString stringWithFormat:
									   @"%@Test Start Time,0,%@,,,\nTest End Time,0,%@,,,\nTest Cost Time,0,%f,,,",
									   szSNLog,
									   [dateStartProgress descriptionWithCalendarFormat:@"%H:%M:%S"
																			   timeZone:nil
																				 locale:nil],
									   [dateEnd descriptionWithCalendarFormat:@"%H:%M:%S"
																	 timeZone:nil
																	   locale:nil],
									   dProgressCostTime];
	[IALogs CreatAndWriteSingleCSVLog:szEndInfoToCSV
							 withPath:szCSVFileName];
    
    //add for summary log 2011.12.12
    NSString	*szInfo	= [NSString stringWithFormat:
						   @"%@,%@,BringUp,,,%@,%@,%@,%@,\"%@\"%@",
						   [m_dicMemoryValues objectForKey:descriptionOfGHStationInfo(IP_PRODUCT)],
						   m_szISN,
						   [m_dicMemoryValues objectForKey:descriptionOfGHStationInfo(IP_STATION_ID)],
						   sz_TestStatus,
						   [dateStartProgress descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M:%S"
																   timeZone:nil
																	 locale:nil],
						   [dateEnd descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M:%S"
														 timeZone:nil
														   locale:nil],
						   m_szFailLists,
						   szValueList];
    NSDictionary	*dicInParams	= [NSDictionary dictionaryWithObjectsAndKeys:
									   [m_dicMemoryValues objectForKey:descriptionOfGHStationInfo(IP_STATION_TYPE)],	@"stationName",
									   uiVersion,	@"softVersion",
									   szTestNames,		@"testNames",
									   @"",				@"displayName",
									   szUpperLimits,	@"upperLimits",
									   szDownLimits,	@"downLimits",
									   nil];
    [IALogs CreatAndWriteSummaryLog:szInfo
					 paraDictionary:dicInParams
						   withPath:szSummaryLogName];
    [m_szErrorDescription setString:@""];
    [m_szFailLists	setString:@""];
    [szTestNames	release];
    [szUpperLimits	release];
    [szDownLimits	release];
    [szValueList	release];
    [szErrorInfo	release];
    //end for summary log
	
    ATSDebug(@"%@",[self formatLog:@"#"
							 title:[NSString stringWithFormat:
									@"END DUT PROGRESS (Duration : %.6f)",
									dProgressCostTime]]);
    
	//Winter 2012.4.18
    //Write cycle time log, add for final result
	if([[self getValueFromXML:kPD_UserDefaults
					  mainKey:kPD_UserDefaults_SaveCycleTimeLog, nil] boolValue])
    {
        NSString	*szCycleTimeName	= [NSString stringWithFormat:
										   @"%@/%@_%@/%@_%@_CycleTime.csv",
										   szCSVFileName, m_szPortIndex,m_szStartTime,m_szPortIndex,m_szStartTime];
        NSString	*szFinalResult = m_bFinalResult ? @"PASS" : @"FAIL";
        NSString	*szBeginLog	= [NSString stringWithFormat:
								   @"Total_TestAll,%@,,%.6f,,\n",
								   szFinalResult,dProgressCostTime];
        [IALogs CreatAndWriteSingleCSVLog:szBeginLog
								 withPath:szCycleTimeName];
    }
    
    // auto test system (send fail info to Robot)
    if (gbIfNeedRemoteCtl)
    {
        NSDictionary *dicResultInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithBool:m_bFinalResult], @"Result",
                                       szFailInfo,      @"Fail Info",
                                       m_szISN,         @"ISN",
                                       nil];
        [nc postNotificationName:TEST_FINISHED
                          object:self
                        userInfo:dicResultInfo];
        NSLog(@"Andre Post Result");
    }
    
    // jugde if it is process issue
    if (szFailInfo!=nil && [szFailInfo  isNotEqualTo:@""])
    {
        NSString    *strItemName    = @"Not_An_Item_Dame";
        for (strItemName in m_arrProItems)
        {
            if ([szFailInfo ContainString:strItemName])
            {
				m_bProcessIssue = YES;
				ATSDebug(@"It's process issue at [%@]",strItemName);
                break;
            }
        }
    }
    [szFailInfo     release];
    [szUnitShowMessage release];
    
	[self endDUTPrg:dProgressCostTime TestResult:m_bFinalResult];
	
	// Remove notification observer here.
	
}

- (void)endDUTPrg:(double)dStartTime TestResult:(BOOL)bResult
{
    NSFileManager	*fileManager	= [NSFileManager defaultManager];
    //rename logs (replace portnumber with SN)
    [self renameLogs];
    [self write_PDCA];
	
	// Should insert COSMETRIC OUTPUT to SFIS while it's STOM station and it test PASS.
	if ([m_szScriptName contains:@"STOM"] && m_bFinalResult)
	{
		if ([self respondsToSelector:@selector(INSERT_SFIS:RETURN_VALUE:)])
		{
			ATSDebug(@"Self execute INSERT_SFIS:RETURN_VALUE: selector");
			// Replace the statio id first.
			NSString * strStationID = [m_dicMemoryValues objectForKey:descriptionOfGHStationInfo(IP_STATION_ID)];
			NSString * strTempStationID = [strStationID subByRegex:@"(.*_.*_.*_).*?" name:nil error:nil];
			[m_dicMemoryValues setObject:[NSString stringWithFormat:@"%@COSMETIC-OUTPUT",strTempStationID] forKey:descriptionOfGHStationInfo(IP_STATION_ID)];
			ATSDebug(@"Station ID is %@", [m_dicMemoryValues objectForKey:descriptionOfGHStationInfo(IP_STATION_ID)]);
            NSDictionary *dictPara = [NSDictionary dictionaryWithObjectsAndKeys:
                                      m_szISN,@"sn",
                                      [m_dicMemoryValues objectForKey:descriptionOfGHStationInfo(IP_STATION_ID)],@"station_id",
                                      @"COSMETIC-OUTPUT",@"test_station_name",
                                      [NSNumber numberWithBool:m_bFinalResult],@"result",
                                      [m_dicMemoryValues objectForKey:descriptionOfGHStationInfo(IP_PRODUCT)],@"product",
                                      [m_dicMemoryValues objectForKey:descriptionOfGHStationInfo(IP_MAC)],@"mac_address",
                                      nil];
            NSDictionary *dicContents = [NSDictionary dictionaryWithObject:dictPara forKey:@"InsertKey"];
			[self performSelector:@selector(INSERT_SFIS:RETURN_VALUE:)
					   withObject:dicContents
					   withObject:nil];
		}
		ATSDebug(@"script name contains STOM and Test PASS.");
	}
	
    //delete pass logs
	// Added by Lorky 2014-08-26, control the deleting PASS log by gh_station.json file. Only deleted it when it's PVT/MP
	BOOL bIsPVTorMP = ([[m_dicMemoryValues objectForKey:descriptionOfGHStationInfo(IP_BUILD_STAGE)] contains:@"PVT"] ||
					   [[m_dicMemoryValues objectForKey:descriptionOfGHStationInfo(IP_BUILD_STAGE)] contains:@"MP"]);
	
    if (m_bFinalResult && bIsPVTorMP)
    {
        NSString    *strNeedDeletePassLogFolder = [NSString stringWithFormat:@"%@/PASS_%@_%@",kPD_LogPath,m_szISN,m_szStartTime];
        if ([fileManager fileExistsAtPath:strNeedDeletePassLogFolder])
            [fileManager removeItemAtPath:strNeedDeletePassLogFolder error:nil];
    }
    
    m_bEmptyResponse	= YES;//Leehua
	m_iStatus		= kFZ_MultiStatus_Finish;
    m_bIsFinished	= YES;
	// Added by Lorky in Cpto on 2012-05-01
	// Remove all the ECID key.
	[m_dicMemoryValues removeObjectForKey:@"LORKY_DEVICE_ECID"];
}

#pragma ++++++++++++++++++       special functions            ++++++++++++++++++
-(BOOL)JudgeValue:(NSString*)szValue
	   WithLimits:(NSArray*)arrayLimits 
             Mode:(int)iMode
{
	// Basic judge
	if((![szValue isKindOfClass:[NSString class]])
	   || (![arrayLimits isKindOfClass:[NSArray class]])
	   || (iMode < 0)
	   || (iMode > 5))
		return NO;
	
	// Judge
	// String
	if(2 == iMode)
	{
		for(NSString *strMatch in arrayLimits)
        {
            if([strMatch isEqualToString:@"NA"])
                return YES;
            NSRange	range	= [szValue rangeOfString:strMatch];
            if(NSNotFound != range.location
			   && range.length>0
			   && (range.location+range.length) <= [szValue length])
                return YES;
        }
        return NO;
	}
    else if(5 == iMode)
    {
        for(NSString *strMatch in arrayLimits)
        {
            if([strMatch isEqualToString:@"NA"])
                return YES;
            if([szValue isEqualToString:strMatch])
                return YES;
        }
        return NO;
    }
    // Number
	else
	{
//        for (int i =0;i< [szValue length]; i++)
//        {
//            char	Digit	= [szValue characterAtIndex:i];
//            if (!((Digit >='0'&&Digit <='9')||Digit =='.'||Digit =='-'||Digit == 'e'||Digit == '+'))
//                return NO;
//        }
		double	dValue		= 0;
		NSScanner * scanValue = [NSScanner scannerWithString:szValue];
//		[scanValue scanDouble:&dValue];
//		
//		if(2 != [arrayLimits count])
//			return NO;
//		if ([szValue isEqualToString:@"NA"]) 
//			return NO;
       
		if (![scanValue scanDouble:&dValue] ||
			(2 != [arrayLimits count]) ||
			[szValue isEqualToString:@"NA"])
			return NO;

		double	dLowerLimit	= 0;
		double	dUpperLimit	= 0;
		// Get lower limit
		if([[arrayLimits objectAtIndex:0] isEqualToString:@""])
			dLowerLimit	= -HUGE_VAL;
		else
			dLowerLimit	= [[arrayLimits objectAtIndex:0] doubleValue];
		// Get upper limit
		if([[arrayLimits objectAtIndex:1] isEqualToString:@""])
			dUpperLimit	= HUGE_VAL;
		else
			dUpperLimit	= [[arrayLimits objectAtIndex:1] doubleValue];
		// Judge
		switch(iMode)
		{
			case 0:	// ()
				if((dLowerLimit < dValue)
				   && (dValue < dUpperLimit))
					return YES;
				break;
			case 1:	// []
				if((dLowerLimit <= dValue)
				   && (dValue <= dUpperLimit))
					return YES;
				break;
			case 3:	// (]
				if((dLowerLimit < dValue)
				   && (dValue <= dUpperLimit))
					return YES;
				break;
			case 4:	// [)
				if((dLowerLimit <= dValue)
				   && (dValue < dUpperLimit))
					return YES;
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
		return NO;
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
// Key format [*???*], ??? is the key
// Param:
//      NSString    *szKey  : An expression contains keys
//      NSString   **szValue: value form dict for the szKey
// Return:
//      BOOL   : if value is nil ,return nil
-(BOOL)TransformKeyToValue:(NSString*)szKeyString
			   returnValue:(NSString **)szValue
{
    BOOL	bRet	= YES;
    // Basic judge
    if(![szKeyString isKindOfClass:[NSString class]])
    {
        *szValue	= @"";
        return NO;
    }
    
    // Transform
    while(((NSNotFound != [szKeyString rangeOfString:kIADeviceKeyBegin].location)
		   && ([szKeyString rangeOfString:kIADeviceKeyBegin].length>0)
		   && ([szKeyString rangeOfString:kIADeviceKeyBegin].location
			   + [szKeyString rangeOfString:kIADeviceKeyBegin].length)
		   <= [szKeyString length])
		  || ((NSNotFound != [szKeyString rangeOfString:kIADeviceKeyEnd].location)
			  && ([szKeyString rangeOfString:kIADeviceKeyEnd].length>0)
			  && ([szKeyString rangeOfString:kIADeviceKeyEnd].location
				  + [szKeyString rangeOfString:kIADeviceKeyEnd].length)
			  <= [szKeyString length]))
    {
        NSRange	rangeKeyBegin	= [szKeyString rangeOfString:kIADeviceKeyBegin];
        NSRange	rangeKeyEnd		= [szKeyString rangeOfString:kIADeviceKeyEnd];
        // Format errors, just remove it
        if((NSNotFound != rangeKeyBegin.location)
		   && (rangeKeyBegin.length>0)
		   && (rangeKeyBegin.location+rangeKeyBegin.length)
		   <= [szKeyString length]
           && (NSNotFound == rangeKeyEnd.location))
        {
            szKeyString	= [szKeyString stringByReplacingOccurrencesOfString:kIADeviceKeyBegin 
																 withString:@""];
            continue;
        }
        else if((NSNotFound == rangeKeyBegin.location)
                && (NSNotFound != rangeKeyEnd.location)
				&& (rangeKeyEnd.length>0)
				&& (rangeKeyEnd.location+rangeKeyEnd.length) <= [szKeyString length])
        {
            szKeyString	= [szKeyString stringByReplacingOccurrencesOfString:kIADeviceKeyEnd 
																 withString:@""];
            continue;
        }
        else if((rangeKeyBegin.location + rangeKeyBegin.length) > rangeKeyEnd.location)
        {
            szKeyString	= [szKeyString stringByReplacingOccurrencesOfString:kIADeviceKeyBegin 
																 withString:@""];
            szKeyString	= [szKeyString stringByReplacingOccurrencesOfString:kIADeviceKeyEnd 
																 withString:@""];
            continue;
        }
        // Transform
        NSRange	rangeKey;
        rangeKey.location	= rangeKeyBegin.location + rangeKeyBegin.length;
        rangeKey.length		= rangeKeyEnd.location - rangeKeyBegin.location - rangeKeyBegin.length;
        NSString	*szKey	= [szKeyString substringWithRange:rangeKey];
        if(nil != [m_dicMemoryValues objectForKey:szKey]
		   && ![[m_dicMemoryValues objectForKey:szKey] isEqualToString:@""])
            szKey	= [m_dicMemoryValues objectForKey:szKey];
        else
        {
            bRet	= NO;
            szKey	= @"";
        }
        rangeKey.location	= rangeKeyBegin.location;
        rangeKey.length		= rangeKeyEnd.location + rangeKeyEnd.length - rangeKeyBegin.location;
        szKeyString	= [szKeyString stringByReplacingCharactersInRange:rangeKey withString:szKey];
    }
    
    // End
    *szValue	= [NSString stringWithFormat:@"%@",szKeyString];
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
-(id)getValueFromXML:(id)inXml
			 mainKey:(NSString *)inMainKey, ...
{
    id	returnValue	= nil;
    if([[inXml class] instancesRespondToSelector:@selector(objectForKey:)]) 
    {
        returnValue	= [inXml objectForKey:inMainKey];
        va_list	ap;
        va_start(ap , inMainKey);
        if (returnValue)
		{
            NSString	*nextKey	= va_arg(ap, NSString *);
            while (nextKey && [returnValue isKindOfClass:[NSDictionary class]])
			{
                returnValue	= [returnValue objectForKey:nextKey];
                nextKey		= va_arg(ap, NSString *);
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
-(NSInteger)GetUSB_PortNum 
{
    NSString	*szUSB_Port	= [[m_dicPorts valueForKey:kPD_Device_MOBILE] objectAtIndex:kFZ_SerialInfo_SerialPort];
	NSRange		range;
    NSString	*szPortName	= kPD_ModeSet_CableName;
	range	= [szUSB_Port rangeOfString:szPortName];
	if (range.location == NSNotFound
		|| range.length<=0
		|| (range.location+range.length) > [szUSB_Port length])
    {
		ATSDebug(@"GetUSB_PortNum => Error : %@", szUSB_Port);
		return -1;
	}
	else
	{
		NSUInteger	nPosition	= [szPortName length] + range.location;
		NSString	*szPort_ID	= [szUSB_Port substringFromIndex:nPosition];
		return [szPort_ID intValue];
	}
}

//cFix  :   you can input = , * ....
//szTitle : START TEST QT0b
//return(example) :  ========= START TEST QT0b ========= ; ************ START TEST QT0b *************
-(NSString*)formatLog:(NSString*)cFix title:(NSString*)szTitle
{
    NSString	*szRet		= @"";
    NSInteger	iLineLength	= 100;
    NSInteger	iLength		= [szTitle length];
    if (iLength>=iLineLength)
        szRet	= [NSString stringWithFormat:@"%@",szTitle];
    else
    {
        NSInteger		iPre	= (iLineLength-iLength)/2+1;
        NSMutableString	*szPre	= [[NSMutableString alloc] initWithString:@""];
        for(NSInteger iIndex=0; iIndex<iPre; iIndex++)
            [szPre appendString:cFix];
        szRet	= [NSString stringWithFormat:@"%@ %@ %@",szPre,szTitle,szPre];
        [szPre release];
    }
    return szRet;
}

//tranfer dictionary to string for writing console log
- (NSString *)formatLog_transferObject:(id)objItem
{
    NSString	*szRet	= @"";
    if ([[[objItem class] description] isEqualToString:@"NSCFBoolean"]) 
        szRet	= [NSString stringWithFormat:@"%@",[objItem description]];
    else if ([objItem isKindOfClass:[NSString class]]
			 || [objItem isKindOfClass:[NSNumber class]]
			 || [objItem isKindOfClass:[NSDate class]]
			 || [objItem isKindOfClass:[NSData class]])
        szRet	= [NSString stringWithFormat:@"%@",objItem];
    else if ([objItem isKindOfClass:[NSArray class]]) 
    {
        NSMutableString	*szMutRet	= [[NSMutableString alloc] initWithString:@""];
        NSInteger		iCount		= [objItem count];
        for(NSInteger iIndex=0; iIndex<iCount; iIndex++)
        {
            NSString	*szMid	= [self formatLog_transferObject:
								   [objItem objectAtIndex:iIndex]];
            [szMutRet appendFormat:@"Item%d=%@ ; ",iIndex,szMid];
        }
        szRet	= [NSString stringWithFormat:@"%@",szMutRet];
        [szMutRet release];
    }
    else if([objItem isKindOfClass:[NSDictionary class]])
    {
        NSMutableString	*szMutRet	= [[NSMutableString alloc] initWithString:@""];
        NSArray			*aryKeys	= [objItem allKeys];
        NSInteger		iCount		= [aryKeys count];
        for (NSInteger iIndex=0; iIndex<iCount; iIndex++) 
        {
            NSString	*szMid	= [self formatLog_transferObject:
								   [objItem objectForKey:[aryKeys objectAtIndex:iIndex]]];
            [szMutRet appendString:[NSString stringWithFormat:
									@"%@ ==> %@ \n",
									[aryKeys objectAtIndex:iIndex],szMid]];
        } 
        szRet	= [NSString stringWithString:szMutRet];
        [szMutRet release];
    }
    return szRet;
}

#pragma mark ############################ CheckSum Items Begin ##############################
-(bool)IsFileExist:(NSString*)szFilePath
{
	NSFileHandle	*fileHandel	= [NSFileHandle fileHandleForReadingAtPath:szFilePath];
	if(nil == fileHandel)
	{
		NSLog(@"IsFileExist:File[%@] does not exist!",szFilePath);
		[fileHandel closeFile];
		return NO;
	}
	else
	{
		NSLog(@"IsFileExist:File[%@] does exist!",szFilePath);
		[fileHandel closeFile];
		return YES;
	}
}
//
- (NSString *)cal_checkSum:(NSString *)szFilePath
{
    NSString	*szCalSum	= @"";
    NSTask		*task		=[[NSTask alloc] init];
    NSPipe		*Pipe		=[NSPipe pipe];
    NSArray		*args		= [NSArray arrayWithObjects:@"sha1",szFilePath,nil];
    [task setLaunchPath:@"/usr/bin/openssl"];
    [task setArguments:args];
    [task setStandardOutput:Pipe];
    [task launch];
    NSData		*outData	= [[Pipe fileHandleForReading]readDataToEndOfFile];
    NSLog(@"%@ => CheckSum Value:%@!",szFilePath,outData);
    [task waitUntilExit];
    int			iRetCode	= [task terminationStatus];
    [task release];
    if(iRetCode == 0)
    {
        NSString	*strCheckSumValue	= [[NSString alloc] initWithData:outData
														   encoding:NSUTF8StringEncoding];
        NSRange		range				= [strCheckSumValue rangeOfString:@"="];
        NSString	*szSub				= @"";
        NSString	*szSubSub			= @"";
        if(range.location != NSNotFound
		   && range.length>0
		   && [strCheckSumValue length]>=(range.location+2))
            szSub	= [strCheckSumValue substringFromIndex:range.location+2];
        range = [szSub rangeOfString:@"\n"];
        if(range.location != NSNotFound
		   && range.length>0
		   && (range.location+range.length) <= [szSub length])
        {
            szSubSub	= [szSub substringToIndex:range.location];
            NSLog(@"%@ => szCheckSumValue szSubSub:%@",szFilePath,szSubSub);
            szCalSum	= [NSString stringWithString:szSubSub];
        }				
        [strCheckSumValue release];
    }
    else
        NSLog(@"Calculate plist file:[%@] failCheckSum iRetCode vaule:[%d]",szFilePath,iRetCode);
    return szCalSum;
}

- (BOOL)checkSum:(NSString *)szCheckSumPath
		 withSum:(NSString *)szSum
{
    BOOL bRet = NO;
    
    if(![self IsFileExist:szCheckSumPath])
    {
        NSString	*szMSG	= [NSString stringWithFormat:
							   @"[%@]不存在，请重做Groundhog. ([%@] does not exist\n Please do groundhog!)",
							   szCheckSumPath,szCheckSumPath];
        NSRunAlertPanel([NSString stringWithFormat:@"警告(Warning) (Slot:%@)",m_szPortIndex],
						szMSG,
						@"确认(OK)", @"", @"");
    }
    else if(!szSum || [szSum isEqualToString:@""])
	{
        NSString	*szMSG	= [NSString stringWithFormat:
							   @"%@检验和初始值为空，请重做Groundhog. (%@ check sum default value is empty. Please do groundhog!)",
							   szCheckSumPath,szCheckSumPath];
        NSRunAlertPanel([NSString stringWithFormat:@"警告(Warning) (Slot:%@)",m_szPortIndex],
						szMSG,
						@"确认(OK)", @"", @"");
    }
    else
    {
        NSString	*szCalSum	= [self cal_checkSum:szCheckSumPath];
        if ([szSum isEqualToString:szCalSum])
		{
            NSLog(@"%@ check sum pass!",szCheckSumPath);
            bRet	= YES;
        }
        else
        {
            NSString	*szMessage	= [NSString stringWithFormat:
									   @"[%@] 路径下的文件被修改，请重做Groundhog. (Somebody modified %@.\n Please do groundhog!)",
									   szCheckSumPath,szCheckSumPath];
            NSRunAlertPanel([NSString stringWithFormat:@"警告(Warning) (Slot:%@)",m_szPortIndex],
							szMessage ,
							@"确认(OK)", @"", @"");
        }
    }
    return bRet;
}
//You can call this function from UI to do checkSum , if you want to do checkSum for one file , you need to add the absolute path of this file to dicCheckSumFiles
- (BOOL)do_checkSum
{
    BOOL			bRet						= YES;
    NSString		*szCheckSumFile				= [NSString stringWithFormat:
												   @"%@/Library/Preferences/com.PEGATRON.checksum.plist",
												   NSHomeDirectory()];
    NSDictionary	*dicCheckSumDefaultValue	= [NSDictionary dictionaryWithContentsOfFile:szCheckSumFile];
    
    NSMutableDictionary	*dicCheckSumFiles		= [[NSMutableDictionary alloc] init]; 
    NSString			*szScriptFileName		= [self getValueFromXML:kPD_UserDefaults
												  mainKey:kPD_UserDefaults_ScriptFileName,nil];
    //add rel script file
    if ([[self getValueFromXML:kPD_UserDefaults
					   mainKey:@"CheckRel",nil] boolValue])
    {
        NSString	*szRelScriptName	= [szScriptFileName stringByReplacingOccurrencesOfString:@".plist"
																				withString:@"_REL.plist"];
        NSString	*szScriptPath_Rel	= [NSString stringWithFormat:
										   @"%@/Contents/Frameworks/FunnyZone.framework/Resources/%@",
										   [[NSBundle mainBundle] bundlePath],szRelScriptName];
        [dicCheckSumFiles setObject:szScriptPath_Rel
							 forKey:@"Rel_TestScript"];//this key must be the same as that in rc
    }
    
    //add script file
    NSString	*szScriptPath	= [NSString stringWithFormat:
								   @"%@/Contents/Frameworks/FunnyZone.framework/Resources/%@",
								   [[NSBundle mainBundle] bundlePath],
								   [self getValueFromXML:kPD_UserDefaults
												 mainKey:kPD_UserDefaults_ScriptFileName,nil]];
    [dicCheckSumFiles setObject:szScriptPath forKey:@"TestScript"];//this key must be the same as that in rc
    //add setting file
    NSString	*szSettingPath	= [NSString stringWithFormat:
								   @"%@/Library/Preferences/ATS_Muifa.plist",
								   NSHomeDirectory()];
    [dicCheckSumFiles setObject:szSettingPath forKey:@"SettingFile"];
    
    //here to add your file which need to do checksum
    
    //check sum
    NSArray		*aryCheckKeys	= [dicCheckSumFiles allKeys];
    NSInteger	iKeyCount		= [aryCheckKeys count];
    for(NSInteger iIndex=0; iIndex<iKeyCount; iIndex++)
    {
        NSString	*szKey		= [aryCheckKeys objectAtIndex:iIndex];
        NSString	*szFilePath	= [dicCheckSumFiles objectForKey:szKey];
        NSString	*szGhValue	= [dicCheckSumDefaultValue objectForKey:szKey];
        
        bRet	&= [self checkSum:szFilePath withSum:szGhValue];
    }
    
    [dicCheckSumFiles release];
    
    return bRet;
}
#pragma mark ############################ CheckSum Items End ##############################

-(BOOL)startPuddingUploadFlow
{
    if (m_bOfflineDisablePudding || m_bValidationDisablePudding)
        return YES;
	if ([m_objPudding StartPDCA_Flow] != kFZ_InstantPudding_Success)
    {
        if (!gbIfNeedRemoteCtl)
		NSRunAlertPanel([NSString stringWithFormat:@"错误(Error) (Slot:%@)",m_szPortIndex],
						@"开始使用Pudding时发生错误。(Pudding StartPDCA Flow Error)",
						@"确认(OK)", nil, nil);
        return NO;
    }
	NSString	*strProduct			=	[m_dicMemoryValues objectForKey:descriptionOfGHStationInfo(IP_PRODUCT)];
	NSString	*strStationType		=	[m_dicMemoryValues objectForKey:descriptionOfGHStationInfo(IP_STATION_TYPE)];
	[m_objPudding SetInitParamter:uiVersion 
					 STATOIN_NAME:[NSString stringWithFormat:@"%@_%@.app",strProduct,strStationType]
				  SOFTWARE_LIMITS:m_szScriptVersion];
    return YES;
}

- (BOOL)setInstantPuddingSerialNumber
{
    if (m_bOfflineDisablePudding || m_bValidationDisablePudding)
        return YES;
    BOOL	bRet	= YES;
    uint	iRet	= kSuccessCode;
    if (!m_objPudding.haveSetISN)
	{
        iRet	= [m_objPudding SetPDCA_ISN:m_szISN];
        if (iRet != kSuccessCode)
		{
            NSString	*strErrorCode	= [NSString stringWithFormat:
										   @"往Pudding传SN失败，测试将会强制结束，错误代码为[%d]。(Set Serial number fail, will stop test, error Code [%d])",
										   iRet,iRet];
            // auto test system
            // no need alert message box
            if (!gbIfNeedRemoteCtl)
            {
                NSRunAlertPanel([NSString stringWithFormat:@"Pudding Error (Slot:%@)",m_szPortIndex],
                                strErrorCode,
                                @"确认(OK)", nil, nil);
            }
            
            [m_objPudding Cancel_Process]; // cancel_Process
			m_bIsPuddingCanceled	= YES;
			m_bCancelToEnd			= YES;
            bRet					= NO;
        }
    }
    return bRet;
}

- (BOOL)write_PDCA
{
    if (m_bOfflineDisablePudding || m_bValidationDisablePudding)
        return YES;
    BOOL	bRet	= NO;
	
	// Pudding upload blob zip file.
    if ([self setInstantPuddingSerialNumber])
	{
        NSString		*szPuddingErr			= @"";
        NSFileManager	*fileManager			= [NSFileManager defaultManager];
        // read the setting that if need upload process log for PASS test.
        NSString		*szFileNameUploadToPDCA	= @"";
		// Added by Lorky 2014-08-26, control the deleting PASS log by gh_station.json file. Only deleted it when it's PVT/MP
        BOOL bIsPVTorMP = ([[m_dicMemoryValues objectForKey:descriptionOfGHStationInfo(IP_BUILD_STAGE)] contains:@"PVT"] ||
						   [[m_dicMemoryValues objectForKey:descriptionOfGHStationInfo(IP_BUILD_STAGE)] contains:@"MP"]);
		
        if (m_bFinalResult && bIsPVTorMP)
		{
            ATSDebug(@"write_PDCA : => Do not need upload process log for PASS test.Coz it's %@",[m_dicMemoryValues objectForKey:descriptionOfGHStationInfo(IP_BUILD_STAGE)]);
		}
		else
		{
			ATSDebug(@"It's %@, upload process log!",[m_dicMemoryValues objectForKey:descriptionOfGHStationInfo(IP_BUILD_STAGE)]);
            szFileNameUploadToPDCA	= [NSString stringWithFormat:@"/vault/%@_UpPDCAFile.zip",m_szISN];
//            [m_objPudding MakeBlobZIP_File:szFileNameUploadToPDCA
//								  FileList:[m_dicLogPaths allValues]];
            [m_objPudding MakeBlobZIP_File:szFileNameUploadToPDCA
                                  FolderPath:m_strLogFolderPath];
        }
        
         BOOL  bComplete = [m_objPudding CompleteTestProcess:szFileNameUploadToPDCA
									 ErrorMsg:&szPuddingErr];
        
        if (bComplete != TEST_SUCCESS)
        {
            // Show fail on UI
            m_bIsCheckedPDCA	= YES;
            NSDictionary	*dicUIResult	= [NSDictionary dictionaryWithObjectsAndKeys:
											   kAllTableView,					kFunnyZoneIdentify,
											   [NSNumber numberWithBool:NO],	kFunnyZoneSingleItemResult, nil];
            [self postTestInfoToUI:dicUIResult];
            // auto test system
            // no need alert message box
            if (!gbIfNeedRemoteCtl)
            NSRunAlertPanel([NSString stringWithFormat:@"Pudding Error (Slot:%@)",m_szPortIndex],
							szPuddingErr,
							@"OK", nil, nil);
            ATSDebug(@"Pudding Warning :	%@",szPuddingErr);
        }
        else
            bRet = YES;
        if (nil != szFileNameUploadToPDCA
			&& ![szFileNameUploadToPDCA isEqualToString:@""])
		{
            [fileManager removeItemAtPath:szFileNameUploadToPDCA error:nil];
            ATSDebug(@"Remove file	:	[%@]",szFileNameUploadToPDCA);
        }
    }
    return bRet;
}

- (void)renameLogs
{
    // Call the Log info class to do log manager.
	NSFileManager	*fileManager			= [NSFileManager  defaultManager];
	NSString		*szFinalCSVFileName		= kFunnyZoneBlank;
    NSString		*szFinalUartFileName	= kFunnyZoneBlank;
    NSString		*szFinalConsoleLog		= kFunnyZoneBlank;//Leehua 110907
	NSString		*szFinalLogFolderName	= kFunnyZoneBlank;
	
	NSString		*szLogFolderName		= [NSString stringWithFormat:@"%@/%@_%@",kPD_LogPath,m_szPortIndex,m_szStartTime];
	
	if ([fileManager fileExistsAtPath:szLogFolderName])
	{
		if (m_bFinalResult)
			szFinalLogFolderName	= [NSString stringWithFormat:@"%@/PASS_%@_%@",kPD_LogPath,m_szISN,m_szStartTime];
		else
			szFinalLogFolderName	= [NSString stringWithFormat:@"%@/FAIL_%@_%@",kPD_LogPath,m_szISN,m_szStartTime];
		
		[fileManager moveItemAtPath:szLogFolderName toPath:szFinalLogFolderName error:nil];
		
        NSLog(@"Move file from [%@] to [%@]",szLogFolderName,szFinalLogFolderName);
	}
	
    //Save folder path
    [m_strLogFolderPath setString:szFinalLogFolderName];
    
    
	NSString		*szCSVFileName			= [NSString stringWithFormat:@"%@/%@_%@_CSV.csv",
											   szFinalLogFolderName,m_szPortIndex,m_szStartTime];
	NSString		*szUARTFileName			= [NSString stringWithFormat:@"%@/%@_%@_Uart.txt",
											   szFinalLogFolderName,m_szPortIndex,m_szStartTime];
	NSString		*szConsoleLog			= [NSString stringWithFormat:@"%@/%@_%@_DEBUG.txt",
											   szFinalLogFolderName,m_szPortIndex,m_szStartTime];//Leehua 110907
	NSString		*szBBStressPDCA			= [NSString stringWithFormat:@"%@/PDCA.plist",
											   szFinalLogFolderName]; // Lorky 2012/10/19 for BBStress PDCA file upload to PDCA
    
    //############################# 2011.07.21 Modify By Ming Begin ###############################
    //for other logs
    //2011.07.11 Add by Ming for gyro log ,Can we change another way (delete kIADevice_Gyro_bIsHaveGyroPath)?Leehua
    NSString		*TempbIsHaveGyroPath	= [m_dicMemoryValues objectForKey:kIADevice_Gyro_bIsHaveGyroPath];
    BOOL			bIsHaveGyroPath			= [TempbIsHaveGyroPath boolValue];
    if(bIsHaveGyroPath)
    {
        NSString	*szGyroFilePath	= [m_dicMemoryValues objectForKey:kIADevice_Gyro_GyroFilePath];
        ATSDebug(@"szGyroFilePath= %@",szGyroFilePath);
        [m_dicLogPaths setValue:szGyroFilePath forKey:kFZ_GyroLogPath];
    }
    //############################# 2011.07.21 Modify By Ming End ###############################
    
    //Add for GYRO-SANITY station
    if ([[kPD_UserDefaults objectForKey:@"gyroSanity"]boolValue])
    {
        NSString    *Earthbound_pdca_gyrosanity     = @"Earthbound_pdca_gyrosanity.plist";
        NSString    *gyroSanityRawGyroReadings_0    = @"gyroSanityRawGyroReadings_0.csv";
        NSString    *gyroSanityLiveGyroReadings_0   = @"gyroSanityLiveGyroReadings_0.csv";
        NSString    *gyroSanityGyroReadings_0       = @"gyroSanityGyroReadings_0.csv";
        
        [fileManager moveItemAtPath:[NSString stringWithFormat:@"/vault/%@/%@",[m_dicMemoryValues objectForKey:@"PLOCATIONID"],Earthbound_pdca_gyrosanity] toPath:[NSString stringWithFormat:@"%@/%@",szFinalLogFolderName,Earthbound_pdca_gyrosanity] error:nil];
        [fileManager moveItemAtPath:[NSString stringWithFormat:@"/vault/%@/%@",[m_dicMemoryValues objectForKey:@"PLOCATIONID"],gyroSanityRawGyroReadings_0] toPath:[NSString stringWithFormat:@"%@/%@",szFinalLogFolderName,gyroSanityRawGyroReadings_0] error:nil];
        [fileManager moveItemAtPath:[NSString stringWithFormat:@"/vault/%@/%@",[m_dicMemoryValues objectForKey:@"PLOCATIONID"],gyroSanityLiveGyroReadings_0] toPath:[NSString stringWithFormat:@"%@/%@",szFinalLogFolderName,gyroSanityLiveGyroReadings_0] error:nil];
        [fileManager moveItemAtPath:[NSString stringWithFormat:@"/vault/%@/%@",[m_dicMemoryValues objectForKey:@"PLOCATIONID"],gyroSanityGyroReadings_0] toPath:[NSString stringWithFormat:@"%@/%@",szFinalLogFolderName,gyroSanityGyroReadings_0] error:nil];
        
        [fileManager removeItemAtPath:[NSString stringWithFormat:@"/vault/%@",[m_dicMemoryValues objectForKey:@"PLOCATIONID"]] error:nil];
    }
    
	if ([fileManager fileExistsAtPath:szCSVFileName])
	{
		if (m_bFinalResult)
			szFinalCSVFileName	= [NSString stringWithFormat:@"%@/PASS_%@_%@_CSV.csv",
								   szFinalLogFolderName,m_szISN,m_szStartTime];
		else
			szFinalCSVFileName	= [NSString stringWithFormat:@"%@/FAIL_%@_%@_CSV.csv",
								   szFinalLogFolderName,m_szISN,m_szStartTime];
        [fileManager moveItemAtPath:szCSVFileName toPath:szFinalCSVFileName error:nil];
        NSLog(@"Move file from [%@] to [%@]",szCSVFileName,szFinalCSVFileName);
		[m_dicLogPaths setValue:szFinalCSVFileName forKey:kFZ_CSVLogPath];
	}
	if ([fileManager fileExistsAtPath:szUARTFileName])
	{
		if (m_bFinalResult)
			szFinalUartFileName	= [NSString stringWithFormat:@"%@/PASS_%@_%@_Uart.txt",
								   szFinalLogFolderName,m_szISN,m_szStartTime];
		else
			szFinalUartFileName	= [NSString stringWithFormat:@"%@/FAIL_%@_%@_Uart.txt",
								   szFinalLogFolderName,m_szISN,m_szStartTime];
        [fileManager moveItemAtPath:szUARTFileName toPath:szFinalUartFileName error:nil];
        NSLog(@"Move file from [%@] to [%@]",szUARTFileName,szFinalUartFileName);
		[m_dicLogPaths setValue:szFinalUartFileName forKey:kFZ_UARTLogPath];
	}
	if ([fileManager fileExistsAtPath:szConsoleLog])
	{
		if (m_bFinalResult)
			szFinalConsoleLog	= [NSString stringWithFormat:@"%@/PASS_%@_%@_DEBUG.txt",
								   szFinalLogFolderName,m_szISN,m_szStartTime];
		else
			szFinalConsoleLog	= [NSString stringWithFormat:@"%@/FAIL_%@_%@_DEBUG.txt",
								   szFinalLogFolderName,m_szISN,m_szStartTime];
        [fileManager moveItemAtPath:szConsoleLog toPath:szFinalConsoleLog error:nil];
        NSLog(@"Move file from [%@] to [%@]",szConsoleLog,szFinalConsoleLog);
		[m_dicLogPaths setValue:szFinalConsoleLog forKey:kFZ_ConsoleLogPath];
	}
	
	if ([fileManager fileExistsAtPath:szBBStressPDCA])
	{		
		[m_dicLogPaths setValue:szBBStressPDCA forKey:kFZ_ConsoleLogPath];
	}
	
    //Winter 2012.4.18
	//Write cycle time log, rename log name
    if([[self getValueFromXML:kPD_UserDefaults
					  mainKey:kPD_UserDefaults_SaveCycleTimeLog, nil] boolValue])
    {
        NSString	*szFinalCycleTimeName	= kFunnyZoneBlank;
        NSString	*szCycleTimeLog			= [NSString stringWithFormat:@"%@/%@_%@_CycleTime.csv",
											   szFinalLogFolderName,m_szPortIndex,m_szStartTime];
        if ([fileManager fileExistsAtPath:szCycleTimeLog])
        {
            if (m_bFinalResult)
                szFinalCycleTimeName	= [NSString stringWithFormat:@"%@/PASS_%@_%@_CycleTime.csv",
										   szFinalLogFolderName,m_szISN,m_szStartTime];
            else
                szFinalCycleTimeName	= [NSString stringWithFormat:@"%@/FAIL_%@_%@_CycleTime.csv",
										   szFinalLogFolderName,m_szISN,m_szStartTime];
            [fileManager moveItemAtPath:szCycleTimeLog toPath:szFinalCycleTimeName error:nil];
            NSLog(@"Move file from [%@] to [%@]",szCycleTimeLog,szFinalCycleTimeName);
            [m_dicLogPaths setValue:szFinalCycleTimeName forKey:kFZ_CycleTimeLogPath];
        }
    }
    
    //after rename
    if (m_bFinalResult)
        [m_szPortIndex setString:[NSString stringWithFormat:@"PASS_%@",m_szISN]];
    else
        [m_szPortIndex setString:[NSString stringWithFormat:@"FAIL_%@",m_szISN]];
}

// If the strSource did not exsist any object at arrayObjs, return NO, otherwise return YES
- (BOOL)ExsistObjects:(NSArray *)arrayObjs
			 AtString:(NSString *)strSource
		   IgnoreCase:(BOOL)bCase
{
	BOOL			bReply		= NO;
	NSMutableArray	*arrExsist	= [[NSMutableArray alloc] init];
	for (NSUInteger i = 0; i < [arrayObjs count]; i++)
	{
		NSString	*strOneObj	= [arrayObjs objectAtIndex:i];
		strOneObj	= (bCase ? [strOneObj uppercaseString] : strOneObj);
		strSource	= (bCase ? [strSource uppercaseString] : strSource);
        NSRange		range		= [strSource rangeOfString:strOneObj];
		if (range.location != NSNotFound
			&& range.length > 0
			&& (range.location+range.length) <= [strSource length])
		{
			bReply	|= YES;
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
         ATSDBgLog(@"%@",szFirstParam);
    }
}

//handle tiltFixtureResult notification
- (void)PatternResultFromFixture:(NSNotification *)notiInfo
{
    NSString	*szRet	= [[notiInfo userInfo] objectForKey:@"PatnFixRet"];
    if(szRet)
    {
        NSInteger	iRet	= [szRet intValue];
        if(iRet == kUart_SUCCESS)
        {
            m_iPatnRFromFZ	= kFZ_Pattern_ReceiveVolDnMsg;
            return;
        }
    }
    m_iPatnRFromFZ	= kFZ_Pattern_ReceiveMsg;
}

//**********************************************************for uart*************************************************
//string hex to data
-(NSData *)stringHexToData:(NSString *)szInput
{
    NSArray			*arrCMD		= [szInput componentsSeparatedByString:@" "];
    NSInteger		iCount		= [arrCMD count];
    unsigned char	*pBuffer	= malloc(iCount+1);
    for(NSInteger iIndex=0; iIndex<iCount; iIndex++)
    {
        unsigned int	ucBuf		= 0;
        NSString		*szValue	= [arrCMD objectAtIndex:iIndex];
        NSScanner		*scan		= [NSScanner scannerWithString:szValue];        
        [scan scanHexInt:&ucBuf];
        *(pBuffer+iIndex)	= ucBuf;
    }
    NSData	*dataRet	= [NSData dataWithBytes:pBuffer length:iCount];
    free(pBuffer);
    pBuffer	= NULL;
    return dataRet;
}

-(NSString*)catchFromString:(NSString *)szOriString
					  begin:(NSString*)szBegin
						end:(NSString *)szEnd
			 TheRightString:(BOOL)bTheRight
{
    if (szBegin
		&& szEnd
		&& [szBegin isNotEqualTo:@""]
		&& [szEnd isNotEqualTo:@""]
		&& [szBegin isEqualToString:szEnd]
		&& bTheRight)
    {
        if ([szOriString ContainString:szBegin]) 
            return szBegin;
        else
            return @"";
    }
    NSRange	range;
    if (![szOriString isKindOfClass:[NSString class]])
        return @"";
    if(nil != szBegin
	   && ![szBegin isEqualToString:@""])
	{
        [self TransformKeyToValue:szBegin returnValue:&szBegin];
        range	= [szOriString rangeOfString:szBegin];
        if(NSNotFound != range.location
		   && [szOriString length] >= range.location+range.length
		   && range.length > 0)
            szOriString	= [szOriString substringFromIndex:range.location + range.length];
        else
            return @"";
	}
	if(nil != szEnd
	   && ![szEnd isEqualToString:@""]
	   && szOriString != nil
	   && ![szOriString isEqualToString:@""])
	{
        [self TransformKeyToValue:szEnd returnValue:&szEnd];
        range	= [szOriString rangeOfString:szEnd];
        if(NSNotFound != range.location
		   && [szOriString length] >= range.location+range.length
		   && range.length > 0)
            szOriString	= [szOriString substringToIndex:range.location];
        else
            return @"";
	}
    return szOriString;
}

-(NSString *)catchFromString:(NSString *)szOriString
					location:(NSInteger)iLocation
					  length:(NSInteger)iLength
{
    if([szOriString isKindOfClass:[NSString class]]
	   && ((iLocation + iLength) <= [szOriString length]))
    {
        if (iLength != 0) 
            szOriString	= [szOriString substringWithRange:NSMakeRange(iLocation, iLength)];
        else
            szOriString	= [szOriString substringFromIndex:iLocation];
        return szOriString;
    }
    else
        return @"";
}

-(NSNumber *)UPLOADPARAMETEDATAFORSUBITEM:(NSDictionary *)dicUploadInfo
							  RETURNVALUE:(NSMutableString *)szReturn
{

    NSLog(@"dicUploadInfo:%@\nszReturn:%@\n",dicUploadInfo,szReturn);
    if (nil == dicUploadInfo) 
        return [NSNumber numberWithBool:NO];
    
    NSDate			*dateStart			= [NSDate date];
    NSTimeInterval	dTimeSpend			= 0.0;
    NSNumber		*bResult			= [NSNumber numberWithBool:YES];
    NSString		*szParametricName	= [dicUploadInfo objectForKey:kFZ_Script_UploadParametric];
    NSString		*szLowLimit			= [dicUploadInfo objectForKey:kFZ_Script_ParamLowLimit];
    NSString		*szHighLimit		= [dicUploadInfo objectForKey:kFZ_SCript_ParamHighLimit];
    BOOL			bTestResult			= [[m_dicMemoryValues objectForKey:kFZ_Script_TestResult] boolValue];
    if ([m_dicMemoryValues objectForKey:kFZ_Script_TestResult] == nil) 
        bTestResult	= YES;
    if (nil == szLowLimit) 
        szLowLimit	= @"NA";
    if (nil == szHighLimit) 
        szHighLimit	= @"NA";
    if (nil == szReturn)
        [szReturn setString:@"NA"];
    if (nil == szParametricName) 
        szParametricName = @"";
    if(!m_bOfflineDisablePudding && !m_bValidationDisablePudding && !m_bNoParametric)
    {

        [m_objPudding SetTestItemStatus:szParametricName
                                SubItem:kFunnyZoneBlank
							 SubSubItem:@""
                              TestValue:szReturn
                               LowLimit:szLowLimit
                              HighLimit:szHighLimit
                              TestUnits:m_szUnit
                                ErrDesc:m_szErrorDescription
                               Priority:m_iPriority
                             TestResult:bTestResult];
        
        [m_dicMemoryValues setObject:[NSNumber numberWithBool:YES]
							  forKey:kFZ_Script_TestResult];
        
    }
    dTimeSpend	= [[NSDate date] timeIntervalSinceDate:dateStart];
    NSString	*strTestInfo	= [NSString stringWithFormat:@"%@,%d,%@,%@,%@,%0.6f\n",
								   szParametricName,!bTestResult,szReturn,szLowLimit,szHighLimit,dTimeSpend];
    if (nil != [m_dicMemoryValues objectForKey:kFunnyZoneHasSubItemParameterData]) 
        [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%@%@",
									  [m_dicMemoryValues objectForKey:kFunnyZoneHasSubItemParameterData],
									  strTestInfo]
							  forKey:kFunnyZoneHasSubItemParameterData];
    else
        [m_dicMemoryValues setObject:strTestInfo
							  forKey:kFunnyZoneHasSubItemParameterData];
    return bResult;
}

-(void)writeForCocoSpecName:(NSString *)szCurrentItemName
					 status:(BOOL)bStatus
					csvPath:(NSString *)szCSVFileName
				   sumNames:(NSMutableString *)szTestNames
				sumUpLimits:(NSMutableString *)szUpperLimits
				sumDnLimits:(NSMutableString *)szDownLimits
			   sumValueList:(NSMutableString *)szValueList
		   errorDescription:(NSMutableString *)szErrorDescription
				   sumError:(NSMutableString *)szErrorInfo
			   CurrentIndex:(int)index
{
    NSString	*szUpLimit,*szDnLimit;
    NSString	*szCofSpec	= [m_dicMemoryValues objectForKey:kFZ_Cof_TestLimit];
    if (szCofSpec != nil) 
    {
        NSString	*szReturnValue	= [NSString stringWithString:m_szReturnValue];
        [self getSpecFrom:szCofSpec lowLimt:&szDnLimit highLimit:&szUpLimit];
        NSString	*szCofItemName	= [NSString stringWithFormat:@"CoF_%@",szCurrentItemName];
        if (!bStatus) 
        {
            if ([szErrorDescription isEqualToString:@""]) 
                [szErrorDescription setString:[NSString stringWithFormat:
											   @"%@_FAIL",szCofItemName]];
            else
                [szErrorDescription setString:[NSString stringWithFormat:@"CoF_%@",szErrorDescription]];
			[m_szFailLists appendFormat:@"%@:",szCofItemName];
			[szErrorInfo appendFormat:@"%@=>%@;",szCofItemName,szErrorDescription];
        }
        //add for summary log

		[szTestNames appendFormat:@",\"%@\"",szCofItemName];
		NSString	*strFormat;
		double		dUp;
		NSScanner	*scanUp	= [NSScanner scannerWithString:szUpLimit];
		strFormat			= ([scanUp scanDouble:&dUp] && [scanUp isAtEnd]) ?
								[NSString stringWithFormat:@",%@",szUpLimit] :
								[NSString stringWithFormat:@",\"%@\"",szUpLimit];
		[szUpperLimits appendString:strFormat];
		
		double		dDn;
		NSScanner	*scanDn		= [NSScanner scannerWithString:szDnLimit];
		strFormat				= ([scanDn scanDouble:&dDn] && [scanDn isAtEnd]) ?
									[NSString stringWithFormat:@",%@",szDnLimit] :
									[NSString stringWithFormat:@",\"%@\"",szDnLimit];
		[szDownLimits appendString:strFormat];
		
		double		fDigit;
		NSScanner	*scaner	= [NSScanner scannerWithString:szReturnValue];
		strFormat				= ([scaner scanDouble:&fDigit] && [scaner isAtEnd]) ?
									[NSString stringWithFormat:@",%@",szReturnValue] :
									[NSString stringWithFormat:@",\"%@\"",szReturnValue];
		[szValueList appendString:strFormat];
        //end for summary log
        // Write CSV Log
		NSString	*szCSVInfo	= [NSString stringWithFormat:@"\"%@\",%@,\"%@\",%@,%@,%@\n",
								   szCofItemName,	[NSNumber numberWithBool:!bStatus],
								   m_szReturnValue,	szDnLimit,
								   szUpLimit,		[m_dicMemoryValues objectForKey:kFZ_SingleTime]];
		[IALogs CreatAndWriteSingleCSVLog:szCSVInfo withPath:szCSVFileName];
        //parametric data
		[self uploadParametric:szCofItemName
					  lowLimit:szDnLimit
					 highLimit:szUpLimit
						status:bStatus
				  errorMessage:szErrorDescription];
    }
}

-(void)writeForNormalSpecName:(NSString *)szCurrentItemName
					   status:(BOOL)bStatus
					  csvPath:(NSString *)szCSVFileName
					 sumNames:(NSMutableString *)szTestNames
				  sumUpLimits:(NSMutableString *)szUpperLimits
				  sumDnLimits:(NSMutableString *)szDownLimits
				 sumValueList:(NSMutableString *)szValueList
			 errorDescription:(NSMutableString *)szErrorDescription
					 sumError:(NSMutableString *)szErrorInfo
				 CurrentIndex:(int)index
{
    NSString	*szUpLimit, *szDnLimit;
    NSString	*szMPSpec		= [m_dicMemoryValues objectForKey:kFZ_MP_TestLimit];
    NSString	*szReturnValue	= [NSString stringWithString:m_szReturnValue];
    if (szMPSpec != nil) 
        [self getSpecFrom:szMPSpec lowLimt:&szDnLimit highLimit:&szUpLimit];
    else
    {
        szMPSpec	= [m_dicMemoryValues objectForKey:kFZ_TestLimit];
        [self getSpecFrom:szMPSpec lowLimt:&szDnLimit highLimit:&szUpLimit];
		bStatus	= m_bSubTest_PASS_FAIL;
    }
    if (!bStatus) 
    {
        if ([szErrorDescription isEqualToString:@""]) 
            [szErrorDescription setString:[NSString stringWithFormat:
										   @"%@_FAIL",szCurrentItemName]];
        else if ([szErrorDescription ContainString:@"CoF_"])
			[szErrorDescription setString:[szErrorDescription SubFrom:@"CoF_" include:NO]];

		[m_szFailLists appendFormat:@"%@:",szCurrentItemName];
		[szErrorInfo appendFormat:@"%@=>%@;",szCurrentItemName,szErrorDescription];
    }
    
	//Add by xiaoyong 2012/07/25 for summary log...
	[szTestNames appendFormat:@",%@",szCurrentItemName];
	double		dUp;
	NSScanner	*scanUp	= [NSScanner scannerWithString:szUpLimit];
	NSString * strFormat = ([scanUp scanDouble:&dUp] && [scanUp isAtEnd]) ?
							 [NSString stringWithFormat:@",%@",szUpLimit] :
							 [NSString stringWithFormat:@",\"%@\"",szUpLimit];
	[szUpperLimits appendString:strFormat];
	
	double		dDn;
	NSScanner	*scanDn	= [NSScanner scannerWithString:szDnLimit];
	strFormat = ([scanDn scanDouble:&dDn] && [scanDn isAtEnd]) ?
				  [NSString stringWithFormat:@",%@",szDnLimit] :
				  [NSString stringWithFormat:@",\"%@\"",szDnLimit];
	[szDownLimits appendString:strFormat];

	double		fDigit;
	NSScanner	*scaner	= [NSScanner scannerWithString:szReturnValue];
	strFormat = ([scaner scanDouble:&fDigit] && [scanDn isAtEnd]) ?
				 [NSString stringWithFormat:@",%@",szReturnValue] :
				 [NSString stringWithFormat:@",\"%@\"",szReturnValue];
	[szValueList appendString:strFormat];
	
	// Write CSV Log

	//add for write subItem parameter  add by jingfu ran on 2012 04 04
	if (nil != [m_dicMemoryValues valueForKey:kFunnyZoneHasSubItemParameterData]) 
	{
		[IALogs CreatAndWriteSingleCSVLog:[m_dicMemoryValues valueForKey:kFunnyZoneHasSubItemParameterData]
								 withPath:szCSVFileName];
		[m_dicMemoryValues removeObjectForKey:kFunnyZoneHasSubItemParameterData];
	}
	//end
	NSString	*szCSVInfo	= [NSString stringWithFormat:@"\"%@\",%@,\"%@\",%@,%@,%@\n",
							   szCurrentItemName,	[NSNumber numberWithBool:!bStatus],
							   m_szReturnValue,		szDnLimit,
							   szUpLimit,			[m_dicMemoryValues objectForKey:kFZ_SingleTime]];
	[IALogs CreatAndWriteSingleCSVLog:szCSVInfo withPath:szCSVFileName];
	
    //parametric data
	[self uploadParametric:szCurrentItemName
				  lowLimit:szDnLimit
				 highLimit:szUpLimit
					status:bStatus
			  errorMessage:szErrorDescription];
}

- (void)getSpecFrom:(NSString *)szSpecString
			lowLimt:(NSString **)szDnLimit
		  highLimit:(NSString **)szUpLimit
{
    if ([szSpecString length] < 3)
        *szUpLimit	=	*szDnLimit	= @"";
    else
    {
        // START modified by Andre on 2012-03-07
        char	character	= [szSpecString characterAtIndex:0];
        if ('{' == character)
        {
            NSString	*szSpecTemp	= [szSpecString substringFromIndex:1];
            NSString	*szSpec		= [szSpecTemp substringToIndex:([szSpecTemp length] - 1)];	
            //replace "," with " " for in csv file ,data separated with ","
            *szUpLimit = *szDnLimit	= [szSpec stringByReplacingOccurrencesOfString:kFunnyZoneComma
																		withString:kFunnyZoneBlank1];
        }
        else
        {
            NSString	*szSpecTemp	= [szSpecString substringFromIndex:1];
            NSString	*szSpec		= [szSpecTemp substringToIndex:([szSpecTemp length] - 1)];		
            NSArray		*arySpec	= [szSpec componentsSeparatedByString:kFunnyZoneComma];
            NSInteger	iSpecCount	= [arySpec count];
            if(iSpecCount == 2)	
            {
                *szUpLimit	= [arySpec objectAtIndex:1];
                *szDnLimit	= [arySpec objectAtIndex:0];
                if ([*szUpLimit isEqualToString:@""])
                    *szUpLimit	= @"NA";
                if ([*szDnLimit isEqualToString:@""])
                    *szDnLimit	= @"NA";
            }
            else
                *szUpLimit = *szDnLimit	= [szSpec stringByReplacingOccurrencesOfString:kFunnyZoneComma
																			withString:kFunnyZoneBlank1];
        }
    }
}

- (void)uploadParametric:(NSString *)szItemName
				lowLimit:(NSString *)szDnLimit
			   highLimit:(NSString *)szUpLimit
				  status:(BOOL)bStatus
			errorMessage:(NSMutableString *)szErrorMessage
{
    // Upload pramatric data
    if(!m_bOfflineDisablePudding && !m_bValidationDisablePudding && !m_bNoParametric)
    {
        NSString	*szValue	= [NSString stringWithString:m_szReturnValue];
        if ([szValue isEqualToString:kFZ_99999_Value_Issue])
            szValue	= @"NA";
        
        NSString	*strMainItemName	= [m_dicMemoryValues objectForKey:@"MainItemName"];
        NSString	*strSubItemName		= kFunnyZoneBlank;
        if (strMainItemName != nil
			&& [szItemName ContainString:strMainItemName])
        {
            strSubItemName	= [szItemName SubFrom:strMainItemName include:NO];
            NSString	*strBeginName	= [self catchFromString:szItemName
													begin:nil
													   end:strMainItemName
											TheRightString:NO];
            strMainItemName	= [NSString stringWithFormat:@"%@%@",strBeginName,strMainItemName];
        }
        
        [m_objPudding SetTestItemStatus:(nil == strMainItemName) ? szItemName : strMainItemName
								SubItem:strSubItemName
							 SubSubItem:@""
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
	NSString	*strECID	= @"";
	// Can find the smail in the strInput string.
	NSString	*strLastObj	= [[strInput componentsSeparatedByString:@"\n"] lastObject];
    //modify by Leehua 12.08.16
    strLastObj	= [strLastObj stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    strLastObj	= [strLastObj stringByReplacingOccurrencesOfString:@" " withString:@""];
	if ([strLastObj hasPrefix:@"["]
		&& [strLastObj hasSuffix:@"]:-)"]
		&& [strLastObj ContainString:@":-)"])
	{
		strECID	= [strLastObj SubFrom:@"[" include:YES];
		strECID	= [strECID SubTo:@"]" include:YES];
	}
	return strECID;
}

-(NSNumber *)GETTESTSLOT:(NSDictionary *)dicParam
			RETURN_VALUE:(NSMutableString *)strReturnValue
{
    NSString	*szPortType	= [[[m_dicMemoryValues objectForKey:@"Muifa_Plist"]
								objectForKey:@"ModeSetting"]
							   objectForKey:@"SlotType"];
    NSString	*szBsdPath	= [[m_dicPorts objectForKey:szPortType]
							   objectAtIndex:kFZ_SerialInfo_SerialPort];
    
    NSRange		range		= [szBsdPath rangeOfString:@"UUT"];
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


#pragma mark - For Remove Space of Unit Tool
-(NSNumber *)COMMUNICATE_WITH_TASK:(NSDictionary *)dictParam
					  RETURN_VALUE:(NSMutableString *)strReturnValue
{
	// Get parameters.
	NSString	*strPath		= [dictParam objectForKey:@"PATH"];
	NSString	*strDirectory	= [dictParam objectForKey:@"DIRECTORY"];
	NSArray		*aryArgs		= [dictParam objectForKey:@"ARGS"];
	NSArray		*aryCommands	= [dictParam objectForKey:@"COMMANDS"];
    
    NSMutableArray  *arrMutable = [[NSMutableArray alloc]init];
    for (int i = 0; i < [aryArgs count]; i++)
    {
        NSString    *strArgs    = [aryArgs objectAtIndex:i];
        [self TransformKeyToValue:strArgs returnValue:&strArgs];
        [arrMutable addObject:strArgs];

    }
    
	// Check task file exist.
	NSFileManager	*fm			= [NSFileManager defaultManager];
	BOOL			bDirectory	= YES;
	if(!strPath
	   || ![fm fileExistsAtPath:strPath isDirectory:&bDirectory]
	   || bDirectory
	   || (strDirectory
		   && (![fm fileExistsAtPath:strDirectory isDirectory:&bDirectory]
			   || !bDirectory)))
	{
		[strReturnValue setString:@"Task file not found. "];
		return [NSNumber numberWithBool:NO];
	}
	
	// Launch task.
	NSTask	*task	= [[NSTask alloc] init];
	[task setLaunchPath:strPath];
	if(aryArgs && [aryArgs count])
		[task setArguments:arrMutable];
	[task setStandardInput:[NSPipe pipe]];
	[task setStandardOutput:[NSPipe pipe]];
	[task setStandardError:[task standardOutput]];
	[task setStandardInput:[NSPipe pipe]];
	if (strDirectory)
		[task setCurrentDirectoryPath:strDirectory];
	@try
	{
		[task launch];
	}
	@catch (NSException *exception)
	{
		[task release];	task	= nil;
		[strReturnValue setString:[exception reason]];
		return [NSNumber numberWithBool:NO];
	}
	
	// Commands.
	for(NSDictionary *dictCommand in aryCommands)
	{
		// Get command.
		NSString	*strCommand	= [dictCommand objectForKey:@"COMMAND"];
		strCommand	= (strCommand ? [strCommand stringByAppendingString:@"\n"] : nil);
		NSString	*strSleep	= [dictCommand objectForKey:@"USLEEP"];
		unsigned int	iSleep	= (strSleep ? [strSleep intValue] : 0);
		NSString	*strRegex	= [dictCommand objectForKey:@"REGEX"];
		strRegex	= (strRegex ? strRegex : nil);
		NSString	*strError	= [dictCommand objectForKey:@"ERROR"];
		NSString	*strRestoreKey	= [dictCommand objectForKey:@"RESPONSE_KEY"];
		
		// Send.
		if(strCommand)
			[[[task standardInput] fileHandleForWriting] writeData:[strCommand dataUsingEncoding:NSUTF8StringEncoding]];
		if(iSleep)
			usleep(iSleep);
		
		// Receive.
		NSData      *dataResponse	= [[[task standardOutput] fileHandleForReading] availableData];
        NSString    *strResponse	= [[NSString alloc] initWithData:dataResponse
                                                      encoding:NSUTF8StringEncoding];
		// Check.
		if(strRegex)
		{
			if(!dataResponse)
			{
				[task terminate];	[task release];	task	= nil;
				[strReturnValue setString:@"DUT no response. "];
				return [NSNumber numberWithBool:NO];
			}
			ATSDebug(@"%@ RESPONSE:%@",strPath, strResponse);
			if(!strResponse)
			{
				[task terminate];	[task release];	task	= nil;
				[strReturnValue setString:@"DUT response invalid. "];
				return [NSNumber numberWithBool:NO];
			}
			if(![strResponse matches:strRegex])
			{
				[strResponse release];	strResponse	= nil;
				[task terminate];	[task release];	task	= nil;
				[strReturnValue setString:(strError ? strError : @"DUT response incorrect. ")];
				return [NSNumber numberWithBool:NO];
			}
			
		}
        if (strRestoreKey)
            [m_dicMemoryValues setObject:strResponse forKey:strRestoreKey];
        [strResponse release];	strResponse	= nil;
	}
	// If no commands, waiting until exit.
	if(!aryCommands)
	{
		NSData	*dataResponse	= [[[task standardOutput] fileHandleForReading]
								   readDataToEndOfFile];
        [task waitUntilExit];
        [task release];	task	= nil;
        
		if(dataResponse)
		{
			NSString	*strResponse	= [[NSString alloc] initWithData:dataResponse
														  encoding:NSUTF8StringEncoding];
			[strReturnValue setString:strResponse];
			[strResponse release];	strResponse	= nil;
			return [NSNumber numberWithBool:YES];
		}
	}
    [task terminate];
    [task release];	task	= nil;
	[strReturnValue setString:@"PASS"];
	return [NSNumber numberWithBool:YES];
}
// auto test system, modify for ATA QTx
- (NSNumber *)SocketError:(NSDictionary *)dicSetting RETURN_VALUE:(NSMutableString *)strReturnValue
{
    NSString        *strErrorInfo   = [dicSetting objectForKey:@"Error"];
    NSDictionary    *dicResultInfo  = [NSDictionary dictionaryWithObjectsAndKeys:
                                       strErrorInfo,    @"Error Info",
                                       m_szISN,         @"ISN",
                                       nil];
    NSNotificationCenter    *nc     = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:FIXTURE_ERROR
                      object:self
                    userInfo:dicResultInfo];
    return [NSNumber numberWithBool:YES];
}

// define indicated items as process items
- (NSNumber *)DEFINE_PRC_ITEMS:(NSDictionary *)dictParam RETURN_VALUE:(NSMutableString *)strReturnValue
{
    m_arrProItems   = [[dictParam    objectForKey:@"List"]   mutableCopy];
    NSLog(@"Define process items as: %@", m_arrProItems);
    
    return [NSNumber    numberWithBool:YES];
}

//Add for GYRO-SANITY station
- (NSNumber *)PARSE_GYROSANITY_FILE:(NSDictionary *)dicParam RETURN_VALUE:(NSMutableString *)strReturnValue
{
    BOOL    bReturn = YES;
    
    NSString *strFilePath = [dicParam objectForKey:@"FILE_PATH"];
    [self TransformKeyToValue:strFilePath returnValue:&strFilePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:strFilePath])
    {
        [strReturnValue setString:[NSString stringWithFormat:@"ERROR, file path [%@] not found",strFilePath]];
        return [NSNumber numberWithBool:NO];
    }
    NSString *strSerialNumberkey = [dicParam objectForKey:@"SAVE_SN"];
    NSString *strLowLimitKey = [dicParam objectForKey:@"SAVE_LOWLIMIT"];
    NSString *strUpLimitKey = [dicParam objectForKey:@"SAVE_UPLIMIT"];
    NSString *strUnitsKey = [dicParam objectForKey:@"SAVE_UNITS"];
    NSString *strValueKey = [dicParam objectForKey:@"SAVE_VALUE"];
    NSString * strResultKey = [dicParam objectForKey:@"SAVE_RESULT"];
    NSString * strParametricDataKey = [dicParam objectForKey:@"SAVE_PARAMETRIC_DATA"];
    
    NSArray *arrItems   = [dicParam objectForKey:@"TEST_ITEMS"];
    BOOL    bYet		= YES;
    NSDictionary *dicFileContent = [NSDictionary dictionaryWithContentsOfFile:strFilePath];
    NSString *strLastKey = [NSString stringWithFormat:@"%lu",[[dicFileContent allKeys]count]-1];
    NSLog(@"Upload Key: %@",strLastKey);
    NSDictionary *dicLastTest = [dicFileContent objectForKey:strLastKey];
    //Get SN
    NSMutableString *strSN = [[dicLastTest objectForKey:@"Attributes"]objectForKey:strSerialNumberkey];
    [m_dicMemoryValues setObject:strSN forKey:strSerialNumberkey];
    
    NSArray *arrTestItem = [dicLastTest objectForKey:@"Tests"];
    for (int j=0; j<[arrTestItem count]; j++)
    {
        NSDictionary *dicTestRecord = [arrTestItem objectAtIndex:j];
        //Get info
        NSString *strResult = [dicTestRecord objectForKey:strResultKey];
        NSString *strLowLimit = [dicTestRecord objectForKey:strLowLimitKey];
        NSString *strUpLimit = [dicTestRecord objectForKey:strUpLimitKey];
        NSMutableString *strValue = [dicTestRecord objectForKey:strValueKey];
        NSString *strUnits = [dicTestRecord objectForKey:strUnitsKey];
        NSString *strParametric = [NSString stringWithFormat:@"%@_%@",[dicTestRecord objectForKey:@"testname"],[dicTestRecord objectForKey:@"subtestname"]];
        
        NSLog(@"parameters:%@ %@ %@ %@ %@ %@ %@",strSN,strParametric,strResult,strLowLimit,strUpLimit,strValue,strUnits);
        
        if ([strResult isEqualToString:@"FAIL"])
        {
            bReturn = NO;
            ATSDebug(@"The content of file contain FAIL");
        }
        
        [m_dicMemoryValues setObject:strLowLimit forKey:strLowLimitKey];
        [m_dicMemoryValues setObject:strUpLimit forKey:strUpLimitKey];
        [m_dicMemoryValues setObject:strValue forKey:strValueKey];
        [m_dicMemoryValues setObject:strUnits forKey:strUnitsKey];
        [m_dicMemoryValues setObject:strResult forKey:strResultKey];
        [m_dicMemoryValues setObject:strParametric forKey:strParametricDataKey];
        
        for (int i = 0; i < [arrItems count]; i++)
        {
            NSDictionary    *dicItemData    = [arrItems objectAtIndex:i];
            NSString        *strSubItemName = [[dicItemData allKeys] objectAtIndex:0];
            NSDictionary    *dicSubItemPara = [dicItemData objectForKey:strSubItemName];
            
            SEL selectorFunction    = NSSelectorFromString(strSubItemName);
            if ([self respondsToSelector:selectorFunction])
            {
                bYet &= [[self performSelector:selectorFunction withObject:dicSubItemPara withObject:strReturnValue] boolValue];
            }
            else
            {
                [strReturnValue setString:@"Can't found the selector function"];
                return [NSNumber numberWithBool:NO];
            }
        }
        
        //do upload
        //            NSDictionary *dicUpload = [NSDictionary dictionaryWithObjectsAndKeys:strLowLimit,@"LOWLMT",
        //                                                  strUpLimit,@"HIGHLMT",
        //                                                  strUnits,@"UNIT",
        //                                                  bResult,@"Result",nil];
        //           [self UPLOAD_PARAMETRIC:dicUpload RETURN_VALUE:strValue];
    }
    return [NSNumber numberWithBool:bReturn];
}

- (NSNumber *)UPLOAD_GYROSANITY:(NSDictionary *)dicParam RETURN_VALUE:(NSMutableString *)strReturnValue
{
    NSString *strLowLimit = [m_dicMemoryValues objectForKey:[dicParam objectForKey:@"LOWLIMIT"]];
    NSString *strUpLimit = [m_dicMemoryValues objectForKey:[dicParam objectForKey:@"UPLIMIT"]];
    NSString *strUnits = [m_dicMemoryValues objectForKey:[dicParam objectForKey:@"UNITS"]];
    NSString *strResult = [m_dicMemoryValues objectForKey:[dicParam objectForKey:@"RESULT"]];
    NSMutableString *strValue = [m_dicMemoryValues objectForKey:[dicParam objectForKey:@"VALUE"]];
    NSString *strParametricData = [m_dicMemoryValues objectForKey:[dicParam objectForKey:@"PARAMETRIC_DATA"]];
    
    NSNumber *bResult = [NSNumber numberWithBool:YES];
    if ([strResult isEqualTo:@"PASS"]) {
        bResult = [NSNumber numberWithBool:YES];
    }
    else
    {
        bResult = [NSNumber numberWithBool:NO];
    }
    NSDictionary *dicUpload = [NSDictionary dictionaryWithObjectsAndKeys:strParametricData,@"PARAMETRIC",
                               strLowLimit,@"LOWLMT",
                               strUpLimit,@"HIGHLMT",
                               strUnits,@"UNIT",
                               bResult,@"Result",
                               @"NO",@"NOWRITETOCSV",nil];
    BOOL res = [self UPLOAD_PARAMETRIC:dicUpload RETURN_VALUE:strValue];
    if (!res) {
        return [NSNumber numberWithBool:NO];
    }
    
    return [NSNumber numberWithBool:YES];
}

//Add for GYRO-SANITY station
- (NSNumber *)CREATE_GYROSANITY_DIRECTORY:(NSDictionary *)dicParam RETURN_VALUE:(NSMutableString *)strReturnValue
{
    NSString *strFilePath = [dicParam objectForKey:@"DIRECTORY"];
    [self TransformKeyToValue:strFilePath returnValue:&strFilePath];
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:strFilePath])
    {
        [fileManager createDirectoryAtPath:strFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
  
    return [NSNumber numberWithBool:YES];
}

-(NSNumber *)WRITECB_WITH_TASK:(NSDictionary *)dictParam
                      RETURN_VALUE:(NSMutableString *)strReturnValue
{
    // Get parameters.
    NSString	*strPath		= [dictParam objectForKey:@"PATH"];
    NSString	*strDirectory	= [dictParam objectForKey:@"DIRECTORY"];
    NSArray		*aryArgs		= [dictParam objectForKey:@"ARGS"];
    NSArray		*aryCommands	= [dictParam objectForKey:@"COMMANDS"];
    
    NSMutableArray  *arrMutable = [[NSMutableArray alloc]init];
    for (int i = 0; i < [aryArgs count]; i++)
    {
        NSString    *strArgs    = [aryArgs objectAtIndex:i];
        [self TransformKeyToValue:strArgs returnValue:&strArgs];
        [arrMutable addObject:strArgs];
        
    }
    
    // Check task file exist.
    NSFileManager	*fm			= [NSFileManager defaultManager];
    BOOL			bDirectory	= YES;
    if(!strPath
       || ![fm fileExistsAtPath:strPath isDirectory:&bDirectory]
       || bDirectory
       || (strDirectory
           && (![fm fileExistsAtPath:strDirectory isDirectory:&bDirectory]
               || !bDirectory)))
    {
        [strReturnValue setString:@"Task file not found. "];
        return [NSNumber numberWithBool:NO];
    }
    
    // Launch task.
    NSTask	*task	= [[NSTask alloc] init];
    [task setLaunchPath:strPath];
    if(aryArgs && [aryArgs count])
        [task setArguments:arrMutable];
    [task setStandardInput:[NSPipe pipe]];
    [task setStandardOutput:[NSPipe pipe]];
    [task setStandardError:[task standardOutput]];
    [task setStandardInput:[NSPipe pipe]];
    if (strDirectory)
        [task setCurrentDirectoryPath:strDirectory];
    @try
    {
        [task launch];
    }
    @catch (NSException *exception)
    {
        [task release];	task	= nil;
        [strReturnValue setString:[exception reason]];
        return [NSNumber numberWithBool:NO];
    }
    
    // Commands.
    for(NSDictionary *dictCommand in aryCommands)
    {
        // Get command.
        NSString	*strCommand	= [dictCommand objectForKey:@"COMMAND"];
        strCommand	= (strCommand ? [strCommand stringByAppendingString:@"\n"] : nil);
        NSString	*strSleep	= [dictCommand objectForKey:@"USLEEP"];
        unsigned int	iSleep	= (strSleep ? [strSleep intValue] : 0);
        NSString	*strRegex	= [dictCommand objectForKey:@"REGEX"];
        strRegex	= (strRegex ? strRegex : nil);
        NSString	*strError	= [dictCommand objectForKey:@"ERROR"];
        NSString	*strRestoreKey	= [dictCommand objectForKey:@"RESPONSE_KEY"];
        
        BOOL	bWriteCB	= [[dictCommand objectForKey:@"WRITECB"]boolValue];
        
        
        if (!bWriteCB)
        {
            // Send.
            if(strCommand)
                [[[task standardInput] fileHandleForWriting] writeData:[strCommand dataUsingEncoding:NSUTF8StringEncoding]];
            if(iSleep)
                usleep(iSleep);
            
            // Receive.
            NSData      *dataResponse	= [[[task standardOutput] fileHandleForReading] availableData];
            NSString    *strResponse	= [[NSString alloc] initWithData:dataResponse
                                                             encoding:NSUTF8StringEncoding];
            // Check.
            if(strRegex)
            {
                if(!dataResponse)
                {
                    [task terminate];	[task release];	task	= nil;
                    [strReturnValue setString:@"DUT no response. "];
                    return [NSNumber numberWithBool:NO];
                }
                ATSDebug(@"%@ RESPONSE:%@",strPath, strResponse);
                if(!strResponse)
                {
                    [task terminate];	[task release];	task	= nil;
                    [strReturnValue setString:@"DUT response invalid. "];
                    return [NSNumber numberWithBool:NO];
                }
                if(![strResponse matches:strRegex])
                {
                    [strResponse release];	strResponse	= nil;
                    [task terminate];	[task release];	task	= nil;
                    [strReturnValue setString:(strError ? strError : @"DUT response incorrect. ")];
                    return [NSNumber numberWithBool:NO];
                }
                
            }
            if (strRestoreKey)
                [m_dicMemoryValues setObject:strResponse forKey:strRestoreKey];
            [strResponse release];	strResponse	= nil;
        }
        else
        {
        
            if(!m_bFinalResult)
            {
                
                [m_dicMemoryValues setObject:kFZ_TestFail
                                      forKey:kFZ_TestResult];
                
                [self TransformKeyToValue:strCommand returnValue:&strCommand];
                // Send.
                if(strCommand)
                    [[[task standardInput] fileHandleForWriting] writeData:[strCommand dataUsingEncoding:NSUTF8StringEncoding]];
                if(iSleep)
                    usleep(iSleep);
                
                // Receive.
                NSData      *dataResponse	= [[[task standardOutput] fileHandleForReading] availableData];
                NSString    *strResponse	= [[NSString alloc] initWithData:dataResponse
                                                                 encoding:NSUTF8StringEncoding];
                // Check.
                if(strRegex)
                {
                    if(!dataResponse)
                    {
                        [task terminate];	[task release];	task	= nil;
                        [strReturnValue setString:@"DUT no response. "];
                        return [NSNumber numberWithBool:NO];
                    }
                    ATSDebug(@"%@ RESPONSE:%@",strPath, strResponse);
                    if(!strResponse)
                    {
                        [task terminate];	[task release];	task	= nil;
                        [strReturnValue setString:@"DUT response invalid. "];
                        return [NSNumber numberWithBool:NO];
                    }
                    if(![strResponse matches:strRegex])
                    {
                        [strResponse release];	strResponse	= nil;
                        [task terminate];	[task release];	task	= nil;
                        [strReturnValue setString:(strError ? strError : @"DUT response incorrect. ")];
                        return [NSNumber numberWithBool:NO];
                    }
                    
                }
                if (strRestoreKey)
                    [m_dicMemoryValues setObject:strResponse forKey:strRestoreKey];
                [strResponse release];	strResponse	= nil;
                
            }
            else
            {
                [m_dicMemoryValues setObject:kFZ_TestPass
                                      forKey:kFZ_TestResult];
                
                [self TransformKeyToValue:strCommand returnValue:&strCommand];
                // Send.
                if(strCommand)
                    [[[task standardInput] fileHandleForWriting] writeData:[strCommand dataUsingEncoding:NSUTF8StringEncoding]];
                if(iSleep)
                    usleep(iSleep);
                
                // Receive.
                NSData      *dataResponse	= [[[task standardOutput] fileHandleForReading] availableData];
                NSString    *strResponse	= [[NSString alloc] initWithData:dataResponse
                                                                 encoding:NSUTF8StringEncoding];
                
                NSString * strNONCE = [strResponse subByRegex:@"Nonce:\\s*(.*?)\\s*?Enter password:" name:nil error:nil];
                
                ATSDebug(@"The Nonce value is [%@]", strNONCE);
                
                if ([strNONCE length] != 40)
                {
                    [task terminate];
                    [task release];	task	= nil;
                    [strReturnValue setString:@"FAIL"];
                    return [NSNumber numberWithBool:NO];
                }
                
                NSString    *finalPassWord  = [self calculateOSSecuerControlBitPasswordTCP:strNONCE];
                
                ATSDebug(@"The finalPassWord is [%@]", finalPassWord);
                
                NSString    *strPassWord    = [NSString stringWithFormat:@"%@\n",finalPassWord];
                
                [[[task standardInput] fileHandleForWriting] writeData:[strPassWord dataUsingEncoding:NSUTF8StringEncoding]];
                
                sleep(3);
                
                NSData      *dataResponse2	= [[[task standardOutput] fileHandleForReading] availableData];
                NSString    *strResponse2	= [[NSString alloc] initWithData:dataResponse2
                                                                  encoding:NSUTF8StringEncoding];
                
                if (![strResponse2 contains:@"successfully"])
                {
                    ATSDebug(@"The incorrect response is [%@]", strResponse2);
                    [task terminate];
                    [task release];	task	= nil;
                    [strReturnValue setString:@"FAIL"];
                    return [NSNumber numberWithBool:NO];
                }
                ATSDebug(@"The successful response is [%@]", strResponse2);
            }
        }
    }
    
    //For write CB
    
    [task terminate];
    [task release];	task	= nil;
    [strReturnValue setString:@"PASS"];
    return [NSNumber numberWithBool:YES];
}


@end




