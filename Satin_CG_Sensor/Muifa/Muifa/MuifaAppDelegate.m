//
//  MuifaAppDelegate.m
//  Muifa
//
//  Created by Gordon Liu on 9/22/11.
//  Copyright 2011 PEGATRON. All rights reserved.
//



#import "MuifaAppDelegate.h"
#import "FunnyZone/IADevice_Other.h"
#import "MuifaScroller.h"
#import "FunnyZone/TestProgress.h"
#import "ScrollingTextView.h"

// auto test system
extern  NSString    * const TEST_FINISHED;
extern  NSString    * const FIXTURE_ERROR;
#define LOGPATH @"/vault/Client/"
static  NSString    *LOCK = @"";
const   NSString    *FixtureState   = @"FixtureState";
const   NSString    *SN             = @"SN";

// globle var to identifier something
extern    BOOL   gbIfNeedRemoteCtl;

// globle var to Audit
extern  BOOL     gbAuditMode;

// accord chose the rel line or not.
BOOL			g_bRELLinePick						= NO;
// color for NFMU
displayColor	structColors[11]	= {	{@"0xffd700",0xff,0xd7,0x00,0} ,
										{@"0x9932cc",0x99,0x32,0xcc,0} ,
										{@"0x00ffff",0x00,0xff,0xff,0} ,
										{@"0xcd5c5c",0xcd,0x5c,0x5c,0} ,
										{@"0x696969",0x69,0x69,0x69,0} ,
										{@"0x0000ff",0x00,0x00,0xff,0} ,
										{@"0x8b4513",0x8b,0x45,0x13,0} ,
										{@"0x2a1a2a",0x2a,0x1a,0x2a,0} ,
										{@"0xff7000",0xff,0x70,0x00,0} ,
										{@"0xff0000",0xff,0x00,0x00,0} ,
										{@"0x006400",0x00,0x64,0x00,0} };



@implementation MuifaAppDelegate

@synthesize window;
@synthesize stationName;
@synthesize stationClass;
@synthesize stationReady;
@synthesize stationStatus;
@synthesize numberOfSlots;

- (id)init
{
    self = [super init];

    if (self) 
    {
        m_arrTemplateObject		= [[NSMutableArray alloc] init];
        m_dicTabViewObject			= [[NSMutableDictionary alloc] init];
        m_iUnitNumber			= 0;
        
        //For Pressure Test, Add by leehua 2013.10.18 begin
        m_objPublicParam = [[publicParams alloc] init];
        m_nFixtureController = [[NSNumber alloc] initWithBool:NO];
        m_dicPublicMemory = [[NSMutableDictionary alloc] init];
        m_iPortCount = [[NSNumber alloc] initWithInteger:0];
        m_iDynamicPortCount = [[NSNumber alloc] initWithInteger:0];
        //g_szSampleLogPath = [[NSString alloc] initWithString:@""];
         objCB_LoadLibrary       = [[CB_LoadLibrary alloc]init];
        
        m_objPublicParam.fixtureController      = m_nFixtureController;
        m_objPublicParam.publicMemoryValues     = m_dicPublicMemory;
        m_objPublicParam.portCount              = m_iPortCount;
        m_objPublicParam.dynamicPortCount       = m_iDynamicPortCount;
        
        //For SMT-QT 2UP
        m_strSMFixtureName  = [[NSMutableString alloc] init];
        m_objSMUart         = [[PEGA_ATS_UART alloc] init];
        m_objSerialPorts    = [[SearchSerialPorts alloc]init];
        
        //For Live & JSON file
        m_strLiveVersion = [[NSMutableString alloc]init];
        m_strDefaultLivePath    = [[NSMutableString alloc]init];
        m_strUIVersion          = [[NSMutableString alloc]init];
        m_iTestItemSYNCCount    = 0;
    }
    
    //For SMT-QT 2UP
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(APPFixtureHaveFinished:) name:@"APPNOTIFORCHECKFIXTUREHAVEFINISHED" object:nil];
    [nc addObserver:self selector:@selector(APPLoopTestCheckFinished:) name:@"APPNOTIFORLOOPTESTCHECKALLTEMPLATEHAVEFINISHED" object:nil];
    [nc addObserver:self selector:@selector(APPTestItemSYNC) name:@"NotificationTestItemSYNC" object:nil];

    
    // auto test system(erase log every time muifa start)
    if (gbIfNeedRemoteCtl) {
        NSFileManager *fm = [NSFileManager defaultManager];
        if ([fm fileExistsAtPath:LOGPATH]) {
            [fm removeItemAtPath:LOGPATH error:nil];
        }
    }
        
    return self;
}

- (void)dealloc
{
    //add for loading IP library Leehua 120507
	if (![[kFZ_UserDefaults objectForKey:@"DisablePudding"] boolValue] && loadingPuddingDylib)
		[loadingPuddingDylib			release];
    [m_dicGHInfo_Muifa					release];
    [m_arrTemplateObject				release];
    [m_dicTabViewObject					release];
    [objCB_LoadLibrary                  release];
    //For Pressure Test, Add by leehua 2013.10.18 begin
    [m_objPublicParam release];
    [m_nFixtureController release];
    [m_dicPublicMemory release];
    [m_iPortCount release];
    [m_iDynamicPortCount release];
    
    //For Live & JSON file
    [m_strLiveVersion release];
    [m_strDefaultLivePath release];
    [m_strUIVersion  release];

    // auto test system (release)
    if (gbIfNeedRemoteCtl)
    {
        [m_Tx_Fixture_Normal            release];
        [m_Tx_Incomplete_Result         release];
        [m_Tx_Initial_Result            release];
        [m_Tx_FailItem_Result           release];
        [m_arrFixtureStatus             release];
        [m_arrTravelers                 release];
        [m_arrResult                    release];
        [m_arrUUTID                     release];
        [m_arrFailItems                 release];
        [m_arrAppleControllers          release];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc removeObserver:self name:TEST_FINISHED object:nil];
        [nc removeObserver:self name:FIXTURE_ERROR object:nil];
    }
    
    //For SMT-QT 2UP
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:@"APPNOTIFORCHECKFIXTUREHAVEFINISHED" object:nil];
    [nc removeObserver:self name:@"APPNOTIFORLOOPTESTCHECKALLTEMPLATEHAVEFINISHED" object:nil];
    [m_strSMFixtureName release];
    [m_objSMUart release];
    [m_objSerialPorts release];

    [super dealloc];
}

#define kMuifa_Window_Point_X                   12
#define kMuifa_Window_Point_Y                   100
#define kMuifa_Window_Size_Width                [[NSScreen mainScreen] visibleFrame].size.width
#define kMuifa_Window_Size_Height               [[NSScreen mainScreen] visibleFrame].size.height
- (void)awakeFromNib
{
    NSLog(@"awakeFromNib begin");
    // auto test system
    NSDictionary    *dicSocket  = [NSDictionary dictionaryWithContentsOfFile:
                                   [NSString stringWithFormat:@"%@/Library/Preferences/ATS_Socket.plist", NSHomeDirectory()]];
    gbIfNeedRemoteCtl           = [[dicSocket objectForKey:@"Need Remote Control"] boolValue];
    NSLog(@"Is Remote Control: %i", gbIfNeedRemoteCtl);
    
    // set mufia window title
    [window setTitle:@"Muifa"];

	// create ATS_Muifa_Counter.plist at path: NSHomeDirectory()/Library/Preferences/
    NSFileManager	*fileManger		= [NSFileManager defaultManager];
    NSError			*error;

	NSDictionary	*dicAttributes	=[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:511]
															 forKey:NSFilePosixPermissions];
    if ([fileManger setAttributes:dicAttributes
					 ofItemAtPath:kUserDefaultPath
							error:&error])
    {
        if (![fileManger fileExistsAtPath:kMuifaCounterPlistPath])
        {
            NSDictionary	*dicBase	= [NSDictionary dictionaryWithObjectsAndKeys:
										   [NSNumber numberWithInt:1],	kUserDefaultCycleTestTime,
										   [NSNumber numberWithInt:0],	kUserDefaultFailCount,
										   [NSNumber numberWithInt:0],	kUserDefaultPassCount,
										   [NSNumber numberWithInt:0],	kUserDefaultHaveRunCount, nil];
            NSDictionary	*dicMFMU	= [NSDictionary dictionaryWithObjectsAndKeys:
										   dicBase,	@"Unit1",
										   dicBase,	@"Unit2",
										   dicBase,	@"Unit3",
										   dicBase,	@"Unit4",
										   dicBase,	@"Unit5",
										   dicBase,	@"Unit6",
										   dicBase,	@"Unit7",
										   dicBase,	@"Unit8",nil];
            [[NSDictionary dictionaryWithObject:dicMFMU forKey:kUserDefaultCounter]
			 writeToFile:kMuifaCounterPlistPath
			 atomically:NO];
        }
    }
    else
    {
        NSAlert *alert = [[NSAlert alloc]init];
        alert.messageText = @"警告(Warning)";
        alert.informativeText = [NSString stringWithFormat:
                                 @"没有路径:%@下的写入权限。(No permission to write ATS_Muifa_Counter.plist at path:%@)",
                                 kUserDefaultPath,kUserDefaultPath];
        [alert addButtonWithTitle:@"确认(OK)"];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
        [alert release];
        [NSApp terminate:self];
    }
    
    // set mufia window frame
    NSRect			rectForWindow		= NSMakeRect([[[kFZ_UserDefaults objectForKey:@"WindowSize"] objectForKey:@"XPoint"] intValue] ?
													 [[[kFZ_UserDefaults objectForKey:@"WindowSize"] objectForKey:@"XPoint"] intValue] :
													 kMuifa_Window_Point_X,
													 [[[kFZ_UserDefaults objectForKey:@"WindowSize"] objectForKey:@"YPoint"] intValue] ?
													 [[[kFZ_UserDefaults objectForKey:@"WindowSize"] objectForKey:@"YPoint"] intValue] :
													 kMuifa_Window_Point_Y,
													 [[[kFZ_UserDefaults objectForKey:@"WindowSize"] objectForKey:@"Width"] intValue] ?
													 [[[kFZ_UserDefaults objectForKey:@"WindowSize"] objectForKey:@"Width"] intValue] :
													 kMuifa_Window_Size_Width,
													 [[[kFZ_UserDefaults objectForKey:@"WindowSize"] objectForKey:@"Height"] intValue] ?
													 [[[kFZ_UserDefaults objectForKey:@"WindowSize"] objectForKey:@"Height"] intValue] :
													 kMuifa_Window_Size_Height);
    [window setFrame:rectForWindow display:YES];
    
    
	// Move alloc Pudding library from init funciton to aweakFromNib.
	// Lorky 2013-11-05.
	if (![[kFZ_UserDefaults objectForKey:@"DisablePudding"] boolValue])
		loadingPuddingDylib				= [[DoLoadingLF alloc] init];

    // Here will start to load views
    [self startLoadviewsAndGetGroudHogInfo];
    [window center];
	
	// Start timer to record test times
	CustomTimer * aTimer = [[CustomTimer alloc] init];
	aTimer.textField = TestTotalTime;
	[aTimer fireTimer];
	[aTimer release];
	
    
    // do check sum
    /*
     * Since we need to check the signature of JSON file, just mark for the local checksum function.
    if ([[m_dicGHInfo_Muifa objectForKey:descriptionOfGHStationInfo(IP_BUILD_STAGE)] contains:@"PVT"] ||
        [[m_dicGHInfo_Muifa objectForKey:descriptionOfGHStationInfo(IP_BUILD_STAGE)] contains:@"MP"])
    {
        TestProgress	*objTestProgress	= [[TestProgress alloc] init];
        
        if (![objTestProgress do_checkSum])
        {
            [NSApp terminate:self];
        }
        
        [objTestProgress release];
    }
    */
    if ([[m_dicGHInfo_Muifa objectForKey:descriptionOfGHStationInfo(IP_BUILD_STAGE)] contains:@"PVT"] ||
        [[m_dicGHInfo_Muifa objectForKey:descriptionOfGHStationInfo(IP_BUILD_STAGE)] contains:@"MP"])
    {
        NSString    *szTime = [kFZ_UserDefaults objectForKey:@"DeleteProcessLogBeforeDays"] ?
        [kFZ_UserDefaults objectForKey:@"DeleteProcessLogBeforeDays"] : @"1";
        NSDictionary *dicInfoPlist  = [NSDictionary dictionaryWithObject:szTime
                                                                  forKey:@"DeleteProcessLogsAfterDays"];
        
        NSTimer *aTimer = [NSTimer timerWithTimeInterval:60*10
                                          target:self
                                        selector:@selector(DeleteProcessLog:)
                                        userInfo:dicInfoPlist
                                         repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:aTimer forMode:NSDefaultRunLoopMode];
        [aTimer fire];
    }

    NSLog(@"awakeFromNib end");
}

- (void)startLoadviewsAndGetGroudHogInfo
{
    NSLog(@"startLoadviewsAndGetGroudHogInfo begin");
    
    //For SMT-QT 2UP
    //For get the default fixture cable
    if ([[kFZ_UserDefaults objectForKey:@"SFMUSetting"] isKindOfClass:[NSDictionary class]])
    {
        NSMutableArray	*arrAllSerialPorts	= [[NSMutableArray alloc] init];
        [m_objSerialPorts SearchSerialPorts:arrAllSerialPorts];
        
        BOOL    bFoundSMFxiture = NO;
        NSDictionary    *dicSFMUSetting = [kFZ_UserDefaults objectForKey:@"SFMUSetting"];
        NSString        *strRangeCable  = [dicSFMUSetting objectForKey:@"FIXTURE"];
        for (NSString *strCableName in arrAllSerialPorts)
        {
            if([strCableName rangeOfString:strRangeCable].location != NSNotFound)
            {
                [m_strSMFixtureName setString:strCableName];
                bFoundSMFxiture = YES;
                break;
            }
        }
        
        if (!bFoundSMFxiture)
        {
            ATSRunAlertPanel(@"警告(Warning)", @"Cable Mapping Error\n找不到正确的治具控制线", @"噢(OK)", nil, nil);
            [arrAllSerialPorts release];
            return;
        }
        [arrAllSerialPorts release];
        [NSThread detachNewThreadSelector:@selector(MonitorFixtureHaveStarted) toTarget:self withObject:nil];
    }
    
    TestProgress *objTestProgress = [[TestProgress alloc] initWithPublicParam:m_objPublicParam];//For Pressure Test, modified by Leehua
    //TestProgress	*objTestProgress	= [[TestProgress alloc] init];
    NSMutableArray	*arrPorts			= [[NSMutableArray alloc] init];
    
    // Has pasering parameter into objTestProgress.
    [objTestProgress.memoryValues setObject:[NSDictionary dictionaryWithContentsOfFile:kMuifaPlistPath]
										  forKey:kPD_Muifa_Plist];
    
    // get groundHog Info if pudding is Enabled.
	if (![[kFZ_UserDefaults objectForKey:@"DisablePudding"] boolValue])
		m_dicGHInfo_Muifa	= [[objTestProgress getStationInfo] retain];
    
	// init window title
	NSString	*szStationID		= [m_dicGHInfo_Muifa objectForKey:descriptionOfGHStationInfo(IP_STATION_ID)] ? [m_dicGHInfo_Muifa objectForKey:descriptionOfGHStationInfo(IP_STATION_ID)] : @"**********";
	NSString	*szStationNumber	= [m_dicGHInfo_Muifa objectForKey:descriptionOfGHStationInfo(IP_STATION_NUMBER)] ? [m_dicGHInfo_Muifa objectForKey:descriptionOfGHStationInfo(IP_STATION_NUMBER)] : @"**********";
    
    //For Live & JSON file
    if (![[kFZ_UserDefaults objectForKey:@"DisableLiveFunction"] boolValue])
    {
        NSString *strLiveFilePath = nil;
        //find local live file.
        if ([[kFZ_UserDefaults objectForKey:@"NoLiveControl"]boolValue])
        {
            strLiveFilePath = [self GetLivePath:@"local"];
            if (!strLiveFilePath || ![self ParseAndCombineJson:strLiveFilePath])
            {
                ATSRunAlertPanel(@"警告(Warning)", @"Not find local live file or create script and limit file fail!", @"噢(OK)", nil, nil);
                [arrPorts			release];
                [objTestProgress	release];
                [NSApp terminate:self];
            }
        }
        else
        {
            //If CR is off, run default
            if (![self CheckCRLiveStatus])
            {
               strLiveFilePath = [self GetLivePath:@"default"];
                if (!strLiveFilePath || ![self ParseAndCombineJson:strLiveFilePath])
                {
                    ATSRunAlertPanel(@"警告(Warning)", @"Default版本找不到或不匹配", @"噢(OK)", nil, nil);
                    [arrPorts			release];
                    [objTestProgress	release];
                    [NSApp terminate:self];
                }

            }
            //if CR is on, run Control Run
            else
            {
                strLiveFilePath = [self GetLivePath:@"control_run"];
                //if CR can not run, then run default live
                if (!strLiveFilePath || ![self ParseAndCombineJson:strLiveFilePath] )
                {
                    NSAlert *alert = ATSGetAlertPanel(@"警告(Warning)", @"默认CR文件找不到或不匹配，需要使用Default版本吗？", @"YES", @"NO", nil);
                    //find and load Default live file
                    if ([alert runModal]==NSAlertFirstButtonReturn)
                    {
                        strLiveFilePath = [self GetLivePath:@"default"];
                        if (!strLiveFilePath || ![self ParseAndCombineJson:strLiveFilePath])
                        {
                            ATSRunAlertPanel(@"警告(Warning)", @"Default版本找不到或不匹配", @"噢(OK)", nil, nil);
                            [alert release];
                            [arrPorts			release];
                            [objTestProgress	release];
                            [NSApp terminate:self];
                        }
                        [btnControlRun setState:0];
                        [alert release];
                    }
                }
                [btnControlRun setState:1];
                
            }
        
            // check hash value
            if (![[kFZ_UserDefaults objectForKey:@"DisableSignature"] boolValue] &&
                ![self CheckSignatureForJSONOnPath:strLiveFilePath])
            {
                ATSRunAlertPanel(@"警告(Warning)", @"Hash and signature are NOT matched, please check!", @"噢(OK)", nil, nil);
                [arrPorts			release];
                [objTestProgress	release];
                [NSApp terminate:self];
            }
            // register file notification.
            [m_strDefaultLivePath setString:[[kFZ_UserDefaults objectForKey:@"ScriptInfo"]objectForKey:@"GroundhogInfo"]];
            [self RegisterNotificationForLive:m_strDefaultLivePath];
        }
    }
    
    //Get UI version
    [self WriteLiveInfoToUIVersion];
    NSString	*szAllInfo			= [NSString stringWithFormat:
                                       @"%@[%@]\t Version:%@",
                                       szStationID,szStationNumber, m_strUIVersion];
    
    [window setTitle:szAllInfo];

    // get assgin port array
    BOOL    bAssignPort     = YES;
    bAssignPort     = [objTestProgress assignPorts:arrPorts];
    
    if (bAssignPort) 
    {
		// Align UI here.
		// If the total count is in the range [2,4], it should be vertical, otherwise, it'll be horizontal
		if ([arrPorts count] == 1 || [arrPorts count] > 4)
		{
			[self LoadVerticalView:arrPorts];
		}
		else
		{
			[self LoadHorizontalView:arrPorts];
		}

        // auto test system (initialize)
        if (gbIfNeedRemoteCtl)
        {
            m_arrFixtureStatus      = [[NSMutableArray alloc] init];
            m_arrAppleControllers   = [[NSMutableArray alloc] init];
            m_arrResult             = [[NSMutableArray alloc] init];
            m_arrTravelers          = [[NSMutableArray alloc] init];
            m_arrUUTID              = [[NSMutableArray alloc] init];
            m_arrFailItems          = [[NSMutableArray alloc] init];
            
            NSDictionary    *dicSocketSet   = [NSDictionary dictionaryWithContentsOfFile:
                                                [NSString stringWithFormat:@"%@/Library/Preferences/ATS_Socket.plist",
                                                 NSHomeDirectory()]];
            
            NSDictionary    *dicProtocol    = [dicSocketSet objectForKey:kUserDefaultSocket_Protocol_ATA];
            m_Tx_Incomplete_Result  = [[dicProtocol objectForKey:@"Incomplete_Result"] retain];
            m_Tx_Initial_Result     = [[dicProtocol objectForKey:@"Initial_Result"] retain];
            m_Tx_Fixture_Normal     = [[dicProtocol objectForKey:@"Fixture_Normal"] retain];
            m_Tx_FailItem_Result    = [[dicProtocol objectForKeyedSubscript:@"FailItem_Result"] retain];
            
            m_iSlot_NO				= (int)[m_arrTemplateObject count];
            
            // auto test system (add Objects)
            for (int i=0; i<m_iSlot_NO; i++)
            {
                //Add unit and fixture status for initial
                [m_arrFixtureStatus addObject:m_Tx_Fixture_Normal];
                [m_arrResult addObject:m_Tx_Initial_Result];
                [m_arrUUTID addObject:[NSString stringWithFormat:@"%@%d", SN, (i + 1)]];
                [m_arrFailItems addObject:@""];
                [m_arrTravelers addObject:[NSNull null]];
                
                //For the new QTx, use the ATA framework to communicate with Agent
                NSString    *szStationName  = [NSString stringWithFormat:@"%@_%d", [m_dicGHInfo_Muifa objectForKey: descriptionOfGHStationInfo(IP_STATION_TYPE)], (i+1)];
                NSString    *szStationClass = [m_dicGHInfo_Muifa objectForKey:descriptionOfGHStationInfo(IP_STATION_TYPE)];
                NSNumber    *numSlot        = [NSNumber numberWithInt:1];
                AppleControlledStation  *AutoMationForQTx   = [AppleControlledStation controlledStationWithName:szStationName
                                                                                                       andClass:szStationClass
                                                                                               andNumberOfSlots:numSlot];
                [self writeLog:[NSString stringWithFormat:@"******** Initail ********\nHas registed to voagent\nStationName: [%@]\nStationClass: [%@]\nNumberOfSlots: [%@]", szStationName, szStationClass, numSlot]
                    WithSlotID:[NSString stringWithFormat:@"%d", (i + 1)]];
                [AppleTestStationAutomation registerStation:AutoMationForQTx];
                AutoMationForQTx.delegate   = self;
                [m_arrAppleControllers addObject:AutoMationForQTx];
            }
            
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc addObserver:self selector:@selector(test_finished:) name:TEST_FINISHED object:nil];
            [nc addObserver:self selector:@selector(ChangeFixtureStatus:) name:FIXTURE_ERROR object:nil];
            
        }
    }
    else
    {
        NSLog(@"startLoadviewsAndGetGroudHogInfo: fail to get assign port");
    }
    //For Pressure Test, Add by leehua 2013.10.18 begin
    @synchronized(m_objPublicParam.portCount)
    {
        m_objPublicParam.portCount = [NSNumber numberWithInteger:[arrPorts count]];
    }

    //For CG-O-TEST
    /*
    if (bAssignPort && [[[kFZ_UserDefaults objectForKey:@"ScriptInfo"] objectForKey:@"ScriptFileName"] ContainString:@"CG-O-TEST"])
    {
        [self initialOTESTFixture:arrPorts];
    }
    */
    
    [arrPorts			release];
    [objTestProgress	release];
    
    NSLog(@"startLoadviewsAndGetGroudHogInfo end");
}


- (void)initialOTESTFixture:(NSArray*)SerialPorts
{
    NSDictionary    *dicODevice   = [[kFZ_UserDefaults objectForKey:@"DeviceSetting"] objectForKey:@"DWCYLINDER"];
    int             iBaudRate           = [[dicODevice objectForKey:@"BAUDE_RATE"] intValue];
    int             iDataBit            = [[dicODevice objectForKey:@"DATA_BIT"] intValue];
    int             iStopBit            = [[dicODevice objectForKey:@"STOP_BIT"] intValue];
    NSString        *strParity          = [dicODevice objectForKey:@"PARITY"];
    NSString        *strEndSymbol       = [dicODevice objectForKey:@"ENDFLAG"];
    
    
    PEGA_ATS_UART   *objDWUart         = [[PEGA_ATS_UART alloc] init];
    PEGA_ATS_UART   *objUPUart         = [[PEGA_ATS_UART alloc] init];
    
    NSString        *strODWBSDPath         = [[[[SerialPorts objectAtIndex:0] objectForKey:@"Unit1"]objectForKey:@"DWCYLINDER"]objectAtIndex:0];
    NSString        *strOUPBSDPath         = [[[[SerialPorts objectAtIndex:0] objectForKey:@"Unit1"]objectForKey:@"UPCYLINDER"]objectAtIndex:0];
    NSInteger       iRet                = kUart_SUCCESS;
    
    iRet	= [objDWUart openPort:strODWBSDPath
                     baudeRate:iBaudRate
                       dataBit:iDataBit
                        parity:strParity
                      stopBits:iStopBit
                     endSymbol:strEndSymbol];
    
    if(iRet != kUart_SUCCESS)//iRet== 0 --> succeed
    {
        [objDWUart release];
        [objUPUart release];
        NSLog(@"Open Port Error");
        return;
    }
    
    iRet	&= [objUPUart openPort:strOUPBSDPath
                      baudeRate:iBaudRate
                        dataBit:iDataBit
                         parity:strParity
                       stopBits:iStopBit
                      endSymbol:strEndSymbol];
    
    if(iRet != kUart_SUCCESS)//iRet== 0 --> succeed
    {
        [objDWUart release];
        [objUPUart release];
        NSLog(@"Open Port Error");
        return;
    }
    
    
    NSArray *arrInitialCommands = [kFZ_UserDefaults objectForKey:@"OTESTCOMMANDS"];
    
    for (int i = 0; i < [arrInitialCommands count]; i++)
    {
        id    strCommand = [arrInitialCommands objectAtIndex:i];
        [objDWUart Clear_UartBuff:0.25 TimeOut:5 readOut:nil];
        [objDWUart  Write_UartCommand:strCommand
                            PackedNum:1
                             Interval:0
                                IsHex:YES];
        
        [objUPUart Clear_UartBuff:0.25 TimeOut:5 readOut:nil];
        [objUPUart  Write_UartCommand:strCommand
                            PackedNum:1
                             Interval:0
                                IsHex:YES];
        if (i == 4)
        {
            sleep(10);
        }
        else
        {
            sleep(5);
        }
        
    }
    
    [objDWUart Close_Uart];
    [objUPUart Close_Uart];
    [objDWUart release];
    [objUPUart release];
    NSLog(@"End test for initialOTestFixture.");
    return;
    
}
- (void)LoadHorizontalView:(NSArray *)ports
{
	NSView *contentView = [window contentView];
	NSSize thisViewSize = NSMakeSize(contentView.frame.size.width - 6, contentView.frame.size.height - 40);
	NSUInteger counts = [ports count];
	
	for (NSUInteger index = 0; index < counts; index++)
	{
		// set initlize parameters
		NSDictionary	*dicUnit	= [ports objectAtIndex:index];
		
		NSString			*szUnitNumber		= [[dicUnit allKeys] objectAtIndex:0];
		NSMutableDictionary	*dicUnitPort		= [dicUnit objectForKey:szUnitNumber];
		NSColor	*colorUnit	= [NSColor colorWithCalibratedRed:(float)structColors[index].red/255
															  green:(float)structColors[index].green/255
															   blue:(float)structColors[index].blue/255
															  alpha:(float)1];
		NSDictionary	*dicPara	= [NSDictionary dictionaryWithObjectsAndKeys:
									   dicUnitPort,													kTransferKey_Ports ,
									   [NSDictionary dictionaryWithObjectsAndKeys:
										colorUnit,					@"NSColor",
										structColors[index].colorDisplay,	@"StringColor", nil],	kTransferKey_UnitColor,
									   [NSDictionary dictionaryWithDictionary:m_dicGHInfo_Muifa],	@"GHInfo", nil];
		
		BOOL	bAutoDetectRun	= [[[kFZ_UserDefaults objectForKey:kUserDefaultModeSetting]
									objectForKey:kUserDefaultAutoDetectAndRun] boolValue];
		
		BOOL    bFixtureManualStart  = [[[kFZ_UserDefaults objectForKey:kUserDefaultModeSetting]
										 objectForKey:kUserDefaultFixtureManualStart] boolValue];
		
		// auto test system(change test mode)
		// never take use of auto-run mode
		if (gbIfNeedRemoteCtl) {
			bAutoDetectRun  = NO;
		}
		
		// aTemplate still not released, because no containers have restored it.
		//Template		*aTemplate	= [[Template allocinitWithParameter:dicPara];
        Template        *aTemplate  = [[Template alloc] initWithParametric:dicPara
                                                               publicParam:m_objPublicParam];//For Pressure Test
		[aTemplate setSNDefaultLables];
		NSView * inputView = aTemplate.inputView;
		NSView * briefView = aTemplate.indicator;
		NSView * listVeiw  = aTemplate.listView;
		aTemplate.templateDelegate				= self;
		
		// Create a new custom view to collect all useful views
		NSView * aCustomView = [[NSView alloc] initWithFrame:NSMakeRect(4 + index * (thisViewSize.width/counts),
																		2,
																		thisViewSize.width/counts - 6,
																		thisViewSize.height - 2)];
		// SN input view
		[inputView setFrame:NSMakeRect(4,
									   aCustomView.frame.size.height - inputView.frame.size.height,
									   aCustomView.frame.size.width - 6,
									   inputView.frame.size.height)];
		// Brief view
		[briefView setFrame:NSMakeRect(4,
									   inputView.frame.origin.y - briefView.frame.size.height - 4,
									   aCustomView.frame.size.width - 6,
									   briefView.frame.size.height)];
		
		// ListView
		[listVeiw setFrame:NSMakeRect(4,
									  0,
									  aCustomView.frame.size.width - 6,
									  briefView.frame.origin.y - 6)];
		// Add to custom view.
		[aCustomView addSubview:inputView];
		[aCustomView addSubview:briefView];
		[aCustomView addSubview:listVeiw];
		[[window contentView] addSubview:aCustomView];
		[aCustomView	release];	aCustomView  = nil;
		
		
		// if it is auto detect and run test, create a thread to detect Unit whether plug in
		if (bAutoDetectRun)
		{
			[aTemplate.btnStart setHidden:YES];
			[NSThread detachNewThreadSelector:@selector(MonitorSerialPortPlugIn)
									 toTarget:aTemplate
								   withObject:nil];
		}
		
		if(bFixtureManualStart)
		{
			[aTemplate.btnStart setEnabled:NO];
			[NSThread detachNewThreadSelector:@selector(MonitorFixtureHaveClickStart) toTarget:aTemplate withObject:nil];
		}
		// set sn&count&script labels
		// Check memory leak issue. 2013-11-15 Lorky
		[aTemplate setDefaultValueAndGetScriptInfo:szUnitNumber];
        //For Live & JSON file
        aTemplate.UIVersion = m_strUIVersion;
		
		// Save template to array;
		[m_arrTemplateObject addObject:aTemplate];
	}
}

- (void)LoadVerticalView:(NSArray *)ports
{
	NSView *contentView = [window contentView];
	NSSize thisViewSize = NSMakeSize(contentView.frame.size.width - 6, contentView.frame.size.height - 40);
	NSUInteger counts = [ports count];

	NSView	 * aCustomLeftView = [[NSView alloc] initWithFrame:NSMakeRect(6,
																		  0,
																		  thisViewSize.width * 0.25,
																		  thisViewSize.height - 2)];
	
	NSTabView * aCustomTabView = [[NSTabView alloc] initWithFrame:NSMakeRect(6 + thisViewSize.width * 0.25,
																			 0,
																			 thisViewSize.width * 0.75 - 2,
																			 thisViewSize.height - 2)];
	
	[aCustomTabView setTabViewType:NSLeftTabsBezelBorder];
	[aCustomTabView setFont:[NSFont fontWithName:@"Arial" size:10]];
	
	for (NSUInteger index = 0; index < counts; index++)
	{
		// set initlize parameters
		NSDictionary	*dicUnit	= [ports objectAtIndex:index];
		
		NSString			*szUnitNumber		= [[dicUnit allKeys] objectAtIndex:0];
		NSMutableDictionary	*dicUnitPort		= [dicUnit objectForKey:szUnitNumber];
		NSColor	*colorUnit	= [NSColor colorWithCalibratedRed:(float)structColors[index].red/255
															  green:(float)structColors[index].green/255
															   blue:(float)structColors[index].blue/255
															  alpha:(float)1];
		NSDictionary	*dicPara	= [NSDictionary dictionaryWithObjectsAndKeys:
									   dicUnitPort,													kTransferKey_Ports ,
									   [NSDictionary dictionaryWithObjectsAndKeys:
										colorUnit,					@"NSColor",
										structColors[index].colorDisplay,	@"StringColor", nil] ,	kTransferKey_UnitColor,
									   [NSDictionary dictionaryWithDictionary:m_dicGHInfo_Muifa],	@"GHInfo", nil];
		
		BOOL	bAutoDetectRun	= [[[kFZ_UserDefaults objectForKey:kUserDefaultModeSetting]
									objectForKey:kUserDefaultAutoDetectAndRun] boolValue];
		
		BOOL    bFixtureManualStart  = [[[kFZ_UserDefaults objectForKey:kUserDefaultModeSetting]
										 objectForKey:kUserDefaultFixtureManualStart] boolValue];
		
		// auto test system(change test mode)
		// never take use of auto-run mode
		if (gbIfNeedRemoteCtl) {
			bAutoDetectRun  = NO;
		}

		// aTemplate still not released, because no containers have restored it.
		// Template		*aTemplate	= [[Template alloc] initWithParameter:dicPara];
        Template		*aTemplate  = [[Template alloc] initWithParametric:dicPara publicParam:m_objPublicParam];
		[aTemplate setSNDefaultLables];
		NSView * inputView = aTemplate.inputView;
		NSView * briefView = aTemplate.indicator;
		NSView * listVeiw  = aTemplate.listView;
		aTemplate.templateDelegate				= self;

		// SN input view
		[inputView setFrame:NSMakeRect(2,
									   aCustomLeftView.frame.size.height - (inputView.frame.size.height + 2) * (index+1) - (briefView.frame.size.height + 2) * index - 2,
									   aCustomLeftView.frame.size.width - 6,
									   inputView.frame.size.height)];
		
		// Brief view
		[briefView setFrame:NSMakeRect(2,
									   inputView.frame.origin.y - briefView.frame.size.height - 2,
									   aCustomLeftView.frame.size.width - 6,
									   briefView.frame.size.height)];
		
		// List View
		[listVeiw setFrame:NSMakeRect(5,
									  0,
									  aCustomTabView.frame.size.width - 55,
									  aCustomTabView.frame.size.height - 18)];
		// Add Test list view
		NSTabViewItem * tabViewItem = [[NSTabViewItem alloc] init];
		NSTextField	 * textField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0,
																				 aCustomTabView.frame.size.width - 42,
																				 aCustomTabView.frame.size.height - 20)];
		[textField setBackgroundColor:colorUnit];
		[textField setEditable:NO];
		[[tabViewItem view] setAutoresizesSubviews:NO];
		[[tabViewItem view] addSubview:textField];
		[[tabViewItem view] addSubview:listVeiw];
		[textField release];	textField	= nil;
		[tabViewItem setLabel:szUnitNumber];
		[aCustomTabView addTabViewItem:tabViewItem];
		[aCustomLeftView addSubview:inputView];
		[aCustomLeftView addSubview:briefView];
		[m_dicTabViewObject setObject:tabViewItem forKey:szUnitNumber];
		[tabViewItem release]; tabViewItem = nil;
		
		// if it is auto detect and run test, create a thread to detect Unit whether plug in
		if (bAutoDetectRun)
		{
			[aTemplate.btnStart setHidden:YES];
			[NSThread detachNewThreadSelector:@selector(MonitorSerialPortPlugIn)
									 toTarget:aTemplate
								   withObject:nil];
		}
		//Add for SMT SA-SensorFlex Loop test
        NSMutableDictionary *dicMuifa_Counter = [[NSMutableDictionary dictionaryWithContentsOfFile:kMuifaCounterPlistPath]objectForKey:@"Counter&Cycle_Setting"];
		int cycleCount = [[[dicMuifa_Counter objectForKey:@"Unit1"] objectForKey:@"Cycle Counter"] intValue];
		if(bFixtureManualStart && cycleCount == 1)
		{
			[aTemplate.btnStart setEnabled:NO];
			[aTemplate.btnStart setHidden:YES];
			[NSThread detachNewThreadSelector:@selector(MonitorFixtureHaveClickStart) toTarget:aTemplate withObject:nil];
		}
		// set sn&count&script labels
		// Check memory leak issue. 2013-11-15 Lorky
		[aTemplate setDefaultValueAndGetScriptInfo:szUnitNumber];
        //For Live & JSON file
        aTemplate.UIVersion = m_strUIVersion;
        
		// Save template to array;
		[m_arrTemplateObject addObject:aTemplate];
	}
	[[window contentView] addSubview:aCustomLeftView];
	[[window contentView] addSubview:aCustomTabView];
	[aCustomLeftView	release];	aCustomLeftView = nil;
	[aCustomTabView		release];	aCustomTabView	= nil;
}

- (void)getTestOnceScriptFileNameWithMenuItemTitle:(NSString*)szTitle
{
    NSLog(@"getTestOnceScriptFileNameWithMenuItemTitle begin");
    // if there is no template object, it must be station set up problem
    if (nil != m_arrTemplateObject
		&& [m_arrTemplateObject count] > 0)
    {
        NSDictionary	*dicTestOnceScript	= [[kFZ_UserDefaults objectForKey:kUserDefaultScriptInfo]
											   objectForKey:kUserDefaultTestOnceScriptName];
        // if the test once script file name is nil or empty, pop up a alert panel
        if ((nil != [dicTestOnceScript objectForKey:szTitle])
			&& [[dicTestOnceScript objectForKey:szTitle] isNotEqualTo:@""])
        {
            // whether to pick REL line or not
            if ([[dicTestOnceScript objectForKey:szTitle] objectForKey:@"EnableLineName"]
				&& [szTitle ContainString:[[dicTestOnceScript objectForKey:szTitle]
										   objectForKey:@"EnableLineName"]])
                g_bRELLinePick	= YES;
            else
                g_bRELLinePick	= NO;
            
            NSString	*plistFileName	= [[dicTestOnceScript objectForKey:szTitle]
										   objectForKey:@"PlistFile"];
            BOOL		bTestForOnce	= [[[dicTestOnceScript objectForKey:szTitle]
											objectForKey:@"IsTestOnce"]boolValue];
            NSString	*szAlertInfo	= [NSString stringWithFormat:
										   @"%@ %@?",
										   [[dicTestOnceScript objectForKey:szTitle] objectForKey:@"Message"],
										   plistFileName];
            
            for (Template *template in m_arrTemplateObject) 
                [template changeScriptFile:plistFileName
						   InformativeText:szAlertInfo
								  TestOnce:bTestForOnce];
        }
        else
        {
            NSAlert *alert = [[NSAlert alloc]init];
            alert.messageText = @"警告(Warning)";
            alert.informativeText = @"请设置正确的一次性剧本档。(You need to set TestOnceScriptFile correctly!)";
            [alert addButtonWithTitle:@"确认(OK)"];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert runModal];
            [alert release];
        }
    }
    else
    {
        NSAlert *alert = [[NSAlert alloc]init];
        alert.messageText = @"警告(Warning)";
        alert.informativeText = @"请先把测试站架好。(You need to set up station correctly!)";
        [alert addButtonWithTitle:@"确认(OK)"];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
        [alert release];
    }
    NSLog(@"getTestOnceScriptFileNameWithMenuItemTitle end");

}

/**	Controls the minimum size of the left subview (or top subview in a horizonal NSSplitView). */
	-(CGFloat)splitView:(NSSplitView *)splitView
 constrainMinCoordinate:(CGFloat)proposedMinimumPosition
			ofSubviewAt:(NSInteger)dividerIndex;
{
    return proposedMinimumPosition + 15;
}

/** Controls the minimum size of the right subview (or lower subview in a horizonal NSSplitView). */
	-(CGFloat)splitView:(NSSplitView*)splitView
 constrainMaxCoordinate:(CGFloat)proposedMaximumPosition
			ofSubviewAt:(NSInteger)dividerIndex;
{
    return proposedMaximumPosition - 15;
}

- (void)checkFocus
{
	NSDictionary	*diclaunchedApplications	= [[NSWorkspace sharedWorkspace] activeApplication];
	NSString		*stringApplication			= [diclaunchedApplications objectForKey:@"NSApplicationName"];
	NSString		*bundle						= [[NSBundle mainBundle] bundleIdentifier];
	if ([stringApplication isNotEqualTo:bundle])
	{
		[self.window center];
		[window setLevel:kCGStatusWindowLevel];
		[NSApp activateIgnoringOtherApps:YES];
		
		//the point mouse will click
		CGPoint pointSend;
		
		NSScreen	*screen		= [NSScreen mainScreen];
		NSRect		rectScreen	= [screen frame];
		CGRect		rect		= *(CGRect*)&rectScreen;
		pointSend	= CGPointMake((rect.size.width - [[[kFZ_UserDefaults objectForKey:@"WindowSize"] objectForKey:@"Width"] intValue] ?
													 [[[kFZ_UserDefaults objectForKey:@"WindowSize"] objectForKey:@"Width"] intValue] :
													 kMuifa_Window_Size_Width)/2 + 10,
								  (rect.size.height - [[[kFZ_UserDefaults objectForKey:@"WindowSize"] objectForKey:@"Height"] intValue] ?
													  [[[kFZ_UserDefaults objectForKey:@"WindowSize"] objectForKey:@"Height"] intValue] :
													 kMuifa_Window_Size_Height)/2 + 30);
		
		//mouse down
		CGEventRef	theEvent = CGEventCreateMouseEvent(NULL,
													   kCGEventLeftMouseDown,
													   pointSend,
													   kCGMouseButtonLeft);
		CGEventPost(kCGHIDEventTap, theEvent);
		CFRelease(theEvent);
		//mouse up
		theEvent	= CGEventCreateMouseEvent(NULL,
											  kCGEventLeftMouseUp,
											  pointSend,
											  kCGMouseButtonLeft);
		CGEventPost(kCGHIDEventTap, theEvent);
		CFRelease(theEvent);
	}
}

// Here is a fucking request, why all mene should be set disable by default???
#if 0
// when you click Tool menu item, this function will call automatically
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    // auto test system
    // hide the help
    if ([menuItem tag] == 100)
    {
        return NO;
    }
    
	NSString		*szLineName			= [m_dicGHInfo_Muifa objectForKey:kPD_GHInfo_LINE_NUMBER];
	NSDictionary	*dicTestOnceScript	= [[kFZ_UserDefaults objectForKey:kUserDefaultScriptInfo]
										   objectForKey:kUserDefaultTestOnceScriptName];
    // if there is no template object, just return no
    if (nil != m_arrTemplateObject && [m_arrTemplateObject count] > 0)
    {
        Template	*objTMP		= [m_arrTemplateObject objectAtIndex:0];
        // if the the UI is testing unit, just return no
            // enable or disable the menu item referred to the setting in Muifa.plist
        NSArray		*arrMenus	= [kFZ_UserDefaults objectForKey:kUserDefaultToolMenuItemSetting];
        if ([arrMenus count] > [menuItem tag])
        {
            [menuItem setTitle:[arrMenus objectAtIndex:[menuItem tag]]];
			if (objTMP.m_bStopTest) 
            {
                NSString	*szEnableLineName	= [[dicTestOnceScript objectForKey:[arrMenus objectAtIndex:[menuItem tag]]]
												   objectForKey:@"EnableLineName"];
                if (szEnableLineName && ![szLineName ContainString:szEnableLineName]) 
                {
                    [menuItem setEnabled:NO];
                    return NO;
                }
                return YES;
            }
        }
        else
            [menuItem setHidden:YES];
    }
    return NO;
}
#endif
// Add by betty on 2012.05.09 for auto running some plist in some station for init
- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
   
    BOOL	bAutoRunInit	= [[[kFZ_UserDefaults objectForKey:kUserDefaultModeSetting]
								objectForKey:kUserDefaultAutoInitFixture] boolValue];
    if (bAutoRunInit)
    {
        id		sender		= [[NSButton alloc]init];
        NSArray	*arrMenus	= [kFZ_UserDefaults objectForKey:kUserDefaultToolMenuItemSetting];
        if (0 == [arrMenus count])
        {
            NSAlert *alert = [[NSAlert alloc]init];
            alert.messageText = @"警告(Warning)";
            alert.informativeText = @"设定档中没有正确的设定一次性剧本档。(There is no TestOnceScriptFile in Muifa.plist, You need to set TestOnceScriptFile correctly!)";
            [alert addButtonWithTitle:@"确认(OK)"];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert runModal];
            [alert release];
        }
        [sender setTitle:[arrMenus objectAtIndex:0]];
        //[self MENU_TOOL1:sender];
        [self getTestOnceScriptFileNameWithMenuItemTitle:[sender title]];
        [sender release];
    }
	
	// Make the first responder
	if ([m_arrTemplateObject count])
	{
		Template * firstTemplate = [m_arrTemplateObject objectAtIndex:0];
		[window makeFirstResponder:firstTemplate.serialNumber1];
	}
	
	/*!
	 * Modified by Lorky on 2014-06-17
	 * If the 'Application is agent (UIElement)' set true, It's not allow to force quit application.
	 */
	NSBundle *bundle = [NSBundle mainBundle];
	NSDictionary * bundleDict = [bundle infoDictionary];
	BOOL bIsAgent = [[bundleDict objectForKey:@"LSUIElement"] boolValue];
	if (bIsAgent)
	{
		[NSApp setPresentationOptions:(NSApplicationPresentationDisableProcessSwitching|NSApplicationPresentationHideDock)];
		[self.window toggleFullScreen:self];
	}
    // Disable APP-NAP technology
    if ([[NSProcessInfo processInfo] respondsToSelector:@selector(beginActivityWithOptions:reason:)])
    {
        NSLog(@"Disable APP-NAP by calling: [NSProcessInfo beginActivityWithOptions:NSActivityUserInitiated reason:@\"keep running!!\"]");
        m_activity = [[NSProcessInfo processInfo] beginActivityWithOptions:NSActivityUserInitiated reason:@"keep running!!"];
        if (!m_activity)
        {
            NSLog(@"failed to disable APP-NAP");
        }
    }
}

#pragma mark - For QTx Auto system
// auto test system

- (BOOL) station:(AppleControlledStation *)station startWithTravelers:(NSArray *)travelers;
{
    [self writeLog:[NSString stringWithFormat:@"**********Start**********\nRead from agent <==== StationName: [%@]; StationClass: [%@]; NumberOfSlots: [%@]",
                    station.stationName, station.stationClass, station.numberOfSlots]
        WithSlotID:@"LogWithoutUnit.log"];
    
    for (int iTraveler = 0; iTraveler < [travelers count] ; iTraveler++)
    {
        NSDictionary    *dicMessage     = [travelers objectAtIndex:iTraveler];
        if (nil == dicMessage &&
            0 == [[dicMessage allKeys] count])
        {
            [self writeLog:[NSString stringWithFormat:@"No message from travelers!"]
                WithSlotID:@"LogWithoutUnit.log"];
            continue;
        }
        NSString        *szSlotID       = [NSString stringWithFormat:@"%@", [station.stationName subByRegex:@"(\\d{1})$"
                                                                                                       name:nil
                                                                                                      error:nil]];
        if ([szSlotID intValue] < 1 || [szSlotID intValue] > m_iSlot_NO)
        {
            [self writeLog:[NSString stringWithFormat:@"Read from agent <==== The slot ID [%@] catch from stationName [%@] is over the count of the slot number [%d], do nothing for this.", szSlotID, station.stationName, m_iSlot_NO]
                WithSlotID:@"LogWithoutUnit.log"];
            continue;
        }
        
        [self writeLog:[NSString stringWithFormat:@"**********Start**********\nRead from agent <==== StationName: [%@]; StationClass: [%@]; NumberOfSlots: [%@]",
                        station.stationName, station.stationClass, station.numberOfSlots]
            WithSlotID:szSlotID];
        [self writeLog:[NSString stringWithFormat:@"Read from agent <==== The data for slot [%@] is [%@]", szSlotID, dicMessage]
            WithSlotID:szSlotID];
        NSString *szPre_Result = [m_arrResult objectAtIndex:([szSlotID intValue] - 1)];
        if ([szPre_Result isEqualToString:m_Tx_Incomplete_Result])
        {
            [self writeLog:[NSString stringWithFormat:@"Already In testing Status, no need to do this again"]
                WithSlotID:szSlotID];
        }
        else
        {
            Template *objTemp = [m_arrTemplateObject objectAtIndex:([szSlotID intValue] - 1)];
            NSLog(@"Andre Will perform button on %@", szSlotID);
            [self writeLog:[NSString stringWithFormat:@"Will Perform button for slot [%@]", szSlotID]
                WithSlotID:szSlotID];
            // Perform Start Button, set the status as testing.
            if ([objTemp.btnStart isEnabled] && !objTemp.isLiveChanging)
            {
                @synchronized(m_arrUUTID)
                {
                    [m_arrUUTID replaceObjectAtIndex:([szSlotID intValue] - 1)
                                          withObject:[NSString stringWithFormat:@"%@%@", SN, szSlotID]];
                }
                @synchronized(m_arrFixtureStatus)
                {
                    [m_arrFixtureStatus replaceObjectAtIndex:([szSlotID intValue] - 1)
                                                  withObject:m_Tx_Fixture_Normal];
                }
                @synchronized(m_arrFailItems)
                {
                    [m_arrFailItems replaceObjectAtIndex:([szSlotID intValue] - 1)
                                              withObject:@""];
                }
                @synchronized(m_arrTravelers)
                {
                    [m_arrTravelers replaceObjectAtIndex:([szSlotID intValue] - 1)
                                              withObject:dicMessage];
                }
                @synchronized(m_arrResult)
                {
                    [m_arrResult replaceObjectAtIndex:([szSlotID intValue] - 1)
                                           withObject:m_Tx_Incomplete_Result];
                }
                [objTemp.btnStart performClick:nil];
            }
            else if (objTemp.isLiveChanging)
            {
                [self writeLog:[NSString stringWithFormat:@"The live files is changing, can not start the test!"]
                    WithSlotID:szSlotID];
            }
            else
            {
                [self writeLog:[NSString stringWithFormat:@"It's already start, but the status is [%@], just need to change the status to [%@] for slot [%@]", szPre_Result, m_Tx_Incomplete_Result, szSlotID]
                    WithSlotID:szSlotID];
            }
        }
    }
    return YES;
}

- (BOOL) station:(AppleControlledStation *)station abortWithOptions:(NSDictionary *)options
{
    [self writeLog:[NSString stringWithFormat:@"**********Abort**********\nRead from agent <==== StationName: [%@]; StationClass: [%@]; NumberOfSlots: [%@]", station.stationName, station.stationClass, station.numberOfSlots]
        WithSlotID:@"LogWithoutUnit.log"];
    [self writeLog:[NSString stringWithFormat:@"The abort function is unabled, no need to do anything with this, just return YES..."]
        WithSlotID:@"LogWithoutUnit.log"];
    return YES;
}

- (BOOL) station:(AppleControlledStation *)station query:(NSDictionary *)query
{
    [self writeLog:[NSString stringWithFormat:@"**********Query**********\nRead from agent <==== StationName: [%@]; StationClass: [%@]; NumberOfSlots: [%@]", station.stationName, station.stationClass, station.numberOfSlots]
        WithSlotID:@"LogWithoutUnit.log"];
    NSMutableDictionary *dicReport = [NSMutableDictionary dictionary];
    //get slot ID (like 1, 2, 3, 4)
    NSString        *szSlotID       = [NSString stringWithFormat:@"%@", [station.stationName subByRegex:@"(\\d{1})$"
                                                                                                   name:nil
                                                                                                  error:nil]];
    if ([szSlotID intValue] < 1 || [szSlotID intValue] > m_iSlot_NO)
    {
        [self writeLog:[NSString stringWithFormat:@"Read from agent <==== The slot ID [%@] catch from stationName [%@] is over the count of the slot number [%d], do nothing for this.", szSlotID, station.stationName, m_iSlot_NO]
            WithSlotID:@"LogWithoutUnit.log"];
        return NO;
    }
    
    NSString *szPre_Result = [m_arrResult objectAtIndex:([szSlotID intValue] - 1)];
    Template *objTemp = [m_arrTemplateObject objectAtIndex:([szSlotID intValue] - 1)];
    if ([objTemp.btnStart isEnabled] && !objTemp.isLiveChanging)
    {
        NSArray *arrFailItems = [[m_arrFailItems objectAtIndex:([szSlotID intValue]-1)]componentsSeparatedByString:@","];
        [self writeLog:[NSString stringWithFormat:@"slot is enabled,the status is [%@] for slot [%@]",szPre_Result, szSlotID] WithSlotID:szSlotID];
         BOOL iResetFixture = [self CheckTheFixtureStatusWithSlot:szSlotID FromPorts:objTemp.m_dicPorts];
        if (iResetFixture)
        {
            //no test
            NSDictionary *dicMessage = nil;
            if ([szPre_Result isEqualToString:m_Tx_Initial_Result])
            {
                [self writeLog:[NSString stringWithFormat:@"No Test,the status is [%@],process is 1,fixture is OK",
                                szPre_Result]
                    WithSlotID:szSlotID];
                
                dicMessage = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:[szSlotID intValue]],eTraveler_SlotIdKey,
                              eTraveler_TestPassedResult, eTraveler_TestResultKey,nil];
            }
            //test fail
            else if ([szPre_Result isEqualToString:eTraveler_TestFailedResult])
            {
                [self writeLog:[NSString stringWithFormat:@"Test fail ,the status is [%@],process is 1,fixture is OK",
                                szPre_Result] WithSlotID:szSlotID];
                dicMessage = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:[szSlotID intValue]],eTraveler_SlotIdKey,
                              [m_arrUUTID objectAtIndex:[szSlotID intValue]-1], eTraveler_SerialNumberKey,
                              szPre_Result,                   eTraveler_TestResultKey,
                              arrFailItems, eTraveler_TestFailuresKey,nil];
            }
            //test pass
            else
            {
                [self writeLog:[NSString stringWithFormat:@"Test pass,the status is [%@],process is 1,fixture is OK",szPre_Result] WithSlotID:szSlotID];
                dicMessage = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:[szSlotID intValue]],eTraveler_SlotIdKey,
                              [m_arrUUTID objectAtIndex:[szSlotID intValue]-1], eTraveler_SerialNumberKey,
                              szPre_Result,                                eTraveler_TestResultKey,nil];
            }
            NSArray *arrTravellers = [NSArray arrayWithObject:dicMessage];
            [dicReport setObject:stationQuery_progressReport forKey:stationReport_TopicKey];
            [dicReport setObject:[NSNumber numberWithInt:1]  forKey:stationQuery_progressReport];
            [dicReport setObject:arrTravellers               forKey:eTraveler_CustomTestResultKey];
            [AppleTestStationAutomation testStation:[m_arrAppleControllers objectAtIndex:([szSlotID intValue]-1)] reports:dicReport];
            return YES;
        }
        //reset fixture fail
        [self writeLog:[NSString stringWithFormat:@"fixture reset fail ,the status is [%@],process is 1",
                        szPre_Result]
            WithSlotID:szSlotID];
        
        NSDictionary *dicMessage = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:[szSlotID intValue]],eTraveler_SlotIdKey,
                                    [m_arrUUTID objectAtIndex:[szSlotID intValue]-1], eTraveler_SerialNumberKey,
                                    eTraveler_TestFixtureIssueResult,                   eTraveler_TestResultKey,
                                    arrFailItems, eTraveler_TestFailuresKey,nil];
        NSArray *arrTravellers = [NSArray arrayWithObject:dicMessage];
        [dicReport setObject:stationQuery_progressReport forKey:stationReport_TopicKey];
        [dicReport setObject:[NSNumber numberWithFloat:1] forKey:stationQuery_progressReport];
        [dicReport setObject:arrTravellers forKey:eTraveler_CustomTestResultKey];
        [AppleTestStationAutomation testStation:[m_arrAppleControllers objectAtIndex:([szSlotID intValue]-1)] reports:dicReport];
        return NO;
    }
    //for fixture is not enable, in testing
    [self writeLog:[NSString stringWithFormat:@"In testing,the status is [%@],process is [%f],fixture is not enable for slot [%@]",
                    szPre_Result,[objTemp.lbPercentageNumber floatValue], szSlotID]
        WithSlotID:szSlotID];
    
    [dicReport setObject:stationQuery_progressReport forKey:stationReport_TopicKey];
    [dicReport setObject:[NSNumber numberWithFloat:[objTemp.lbPercentageNumber floatValue]] forKey:stationQuery_progressReport];
    [AppleTestStationAutomation testStation:[m_arrAppleControllers objectAtIndex:([szSlotID intValue]-1)] reports:dicReport];
    return YES;
}
//for auto test system, send fixture command like "reset fixture".
- (BOOL)CheckTheFixtureStatusWithSlot: (NSString *)szSlotID  FromPorts: (NSDictionary *)dicPorts
{
    // Get port settings
    //for open fixture port
    NSString        *szBsdPath = [[dicPorts objectForKey:@"FIXTURE"]objectAtIndex:0];
    NSDictionary    *dicODevice   = [[kFZ_UserDefaults objectForKey:@"DeviceSetting"] objectForKey:@"FIXTURE"];
    int             iBaudRate           = [[dicODevice objectForKey:@"BAUDE_RATE"] intValue];
    int             iDataBit            = [[dicODevice objectForKey:@"DATA_BIT"] intValue];
    int             iStopBit            = [[dicODevice objectForKey:@"STOP_BIT"] intValue];
    NSString        *strParity          = [dicODevice objectForKey:@"PARITY"];
    NSString        *strEndSymbol       = [dicODevice objectForKey:@"ENDFLAG"];
    NSInteger	iRet			= kUart_SUCCESS;
    
    PEGA_ATS_UART	*uartObj	= [[PEGA_ATS_UART    alloc] init];
    
    // open port
    if (NULL == uartObj)
    {
        iRet	= kUart_CMD_CHECK_DUT_FAIL;
    }
    else
    {
        iRet	= [uartObj openPort:szBsdPath
                       baudeRate:iBaudRate
                         dataBit:iDataBit
                          parity:strParity
                        stopBits:iStopBit
                       endSymbol:strEndSymbol];
    }
    
    // write command to port
    if(kUart_SUCCESS == iRet)//iRet== 0 --> succeed
    {
        iRet    = [uartObj  Write_UartCommand:@"reset fixture"
                                    PackedNum:1
                                     Interval:0
                                        IsHex:NO];
    }
    else
    {
        NSLog(@"Open Fixture Port Error");
    }
    
    // recieve data from port
    if (kUart_SUCCESS == iRet)
    {
        NSMutableString     *mlReadData     = [[NSMutableString  alloc] init];
        [uartObj  Read_UartData:mlReadData
                TerminateSymbol:[NSArray arrayWithObjects:@"@_@", nil]
                      MatchType:0
                   IntervalTime:0
                        TimeOut:1];
        
        [self writeLog:[NSString stringWithFormat:@"Fixture return:%@",mlReadData]
            WithSlotID:szSlotID];
        
        if ([[mlReadData lowercaseString]  ContainString:@"pass"]
            || [mlReadData  ContainString:@"Ok"]
            || [mlReadData  ContainString:@"ok"])
        {
            [mlReadData  release];
            [uartObj Close_Uart]; [uartObj    release];
            return YES;
        }
        [mlReadData release];
    }
    
    [uartObj Close_Uart];   [uartObj     release];
    
    return NO;
}

- (void)ChangeFixtureStatus:(NSNotification*)note
{
    //Just replace the status for the fixture now, need more definition for the fixture error...
    NSString    *szError    = [[note userInfo] objectForKey:@"Error Info"];
    NSString    *szSlotID   = @"LogWithoutUnit.log";
    for (int i = 0; i < [m_arrTemplateObject count]; i++)
    {
        Template    *obj_Temp   = [m_arrTemplateObject objectAtIndex:i];
        if ([obj_Temp.testProgress isEqualTo:[note object]])
        {
            szSlotID    = [NSString stringWithFormat:@"%d", (i+1)];
            @synchronized (m_arrFixtureStatus)
            {
                [m_arrFixtureStatus replaceObjectAtIndex:i
                                              withObject:szError];
            }
            break;
        }
    }
    if ([szSlotID intValue] < 1 || [szSlotID intValue] > m_iSlot_NO)
    {
        [self writeLog:[NSString stringWithFormat:@"Get from Funnyzone <==== The slot ID [%@] is over the count of the slot number [%d], cannot change the status of fixture", szSlotID, m_iSlot_NO]
            WithSlotID:szSlotID];
        return;
    }
    [self writeLog:[NSString stringWithFormat:@"Get from Funnyzone <==== The fixture status is [%@] for the slot [%@].", szError, szSlotID]
        WithSlotID:szSlotID];
}


- (void)writeLog:(NSString*)szInfo WithSlotID:(NSString*)szSlotID
{
    @synchronized(LOCK)
    {
        szInfo = (NSString*)szInfo;
        NSString *szDate = [[NSDate date] descriptionWithCalendarFormat:@"MM/dd HH:mm:ss.Ms" timeZone:nil locale:nil];
        szInfo = [NSString stringWithFormat:@"[%@] %@\n",szDate, szInfo];
        
        // LOG ON DISK
        NSFileManager *fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath:LOGPATH])
        {
            [fm createDirectoryAtPath:LOGPATH withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        NSString *szFileName = @"";
        if ([szSlotID isEqualToString:@"LogWithoutUnit.log"])
        {
            szFileName = @"LogWithoutUnit.log";
        }
        else
        {
            szFileName = [NSString stringWithFormat:@"Slot%@.log",szSlotID];
        }
        
        NSString *szPath = [NSString stringWithFormat:@"%@%@", LOGPATH, szFileName];
        NSFileHandle *h_Log = [NSFileHandle fileHandleForWritingAtPath:szPath];
        if (!h_Log)
        {
            [szInfo writeToFile:szPath atomically:NO encoding:NSUTF8StringEncoding error:nil];
        }
        else
        {
            [h_Log seekToEndOfFile];
            [h_Log writeData:[szInfo dataUsingEncoding:NSUTF8StringEncoding]];
            [h_Log closeFile];
        }
    }
}

- (void)test_finished:(NSNotification*)note
{
    NSString        *szSlotID   = @"LogWithoutUnit.log";
   // NSDictionary  *dicPorts = nil;
    //Get the slotID.
    for (int i=0; i<[m_arrTemplateObject count]; i++)
    {
        Template* obj_Template = [m_arrTemplateObject objectAtIndex:i];
        if ([[note object] isEqualTo:obj_Template.testProgress])
        {
            szSlotID    = [NSString stringWithFormat:@"%d", (i+1)];
           // dicPorts = obj_Template.m_dicPorts;
            break;
        }
    }
    
    if ([szSlotID intValue] < 1 || [szSlotID intValue] > m_iSlot_NO)
    {
        [self writeLog:[NSString stringWithFormat:@"Get from Funnyzone <==== The slot ID [%@] is over the count of the slot number [%d], cannot post the result to ATSagent.", szSlotID, m_iSlot_NO]
            WithSlotID:szSlotID];
        return;
    }
    
    if (0 == [m_arrTravelers count] ||
        [szSlotID intValue] > [m_arrTravelers count])
    {
        [self writeLog:[NSString stringWithFormat:@"Maybe someone click the button manually, no need to post the result to ATSagent!"]
            WithSlotID:szSlotID];
        return;
    }
    
    if (nil == [m_arrTravelers objectAtIndex:([szSlotID intValue] - 1)] ||
        ![[m_arrTravelers objectAtIndex:([szSlotID intValue] - 1)] isKindOfClass:[NSDictionary class]] ||
        0 == [[[m_arrTravelers objectAtIndex:([szSlotID intValue] - 1)] allKeys] count])
    {
        [self writeLog:[NSString stringWithFormat:@"The traveler for the slot is [%@], maybe someone click the start button manually, no need to post the result to ATSagent!", [m_arrTravelers objectAtIndex:([szSlotID intValue] - 1)]]
            WithSlotID:szSlotID];
        return;
    }
    
    //Send the result to ATSagent
    BOOL            bResult     = [[[note userInfo] objectForKey:@"Result"] boolValue];
    NSString        *szFailInfo = [NSString stringWithFormat:@"%@", [[note userInfo] objectForKey:@"Fail Info"]];

    //Replace the parameters base on the test result
    @synchronized(m_arrResult)
    {
        [m_arrResult replaceObjectAtIndex:([szSlotID intValue] - 1)
                               withObject:(bResult ? eTraveler_TestPassedResult : eTraveler_TestFailedResult)];
    }
    @synchronized(m_arrUUTID)
    {
        [m_arrUUTID replaceObjectAtIndex:([szSlotID intValue] - 1)
                              withObject:[[note userInfo] objectForKey:@"ISN"] ?
                                            [[note userInfo] objectForKey:@"ISN"] : [NSString stringWithFormat:@"SN%@", szSlotID]];
    }
    @synchronized(m_arrFailItems)
    {
        [m_arrFailItems replaceObjectAtIndex:([szSlotID intValue] - 1)
                                  withObject:bResult ? @"" : szFailInfo];
    }
    
    /* No need to check the fixture status after finish testing
     *
    BOOL iResetFixture  = [self CheckTheFixtureStatusWithSlot:szSlotID FromPorts:dicPorts];
     */
    //Modify the result and response to ATSagent
    BOOL iResetFixture  = YES;
    NSMutableDictionary *dicTempTraveler    = [NSMutableDictionary dictionaryWithDictionary:
                                               [m_arrTravelers objectAtIndex:([szSlotID intValue] - 1)]];
    if (iResetFixture)
    {
        [dicTempTraveler setObject:[m_arrResult objectAtIndex:([szSlotID intValue] - 1)]
                            forKey:eTraveler_TestResultKey];
    }
    else
        [dicTempTraveler setObject:eTraveler_TestFixtureIssueResult forKey:eTraveler_TestResultKey];
//    [dicTempTraveler setObject:[m_arrFixtureStatus objectAtIndex:([szSlotID intValue] - 1)]
//                        forKey:FixtureState];
//    [dicTempTraveler setObject:szSlotID
//                        forKey:eTraveler_TrayIDKey];
    [dicTempTraveler setObject:[m_arrUUTID objectAtIndex:([szSlotID intValue] - 1)]
                        forKey:eTraveler_SerialNumberKey];
    if (!bResult)
    {
        NSArray *arrFailItems = [[m_arrFailItems objectAtIndex:([szSlotID intValue]-1)]componentsSeparatedByString:@","];
        [dicTempTraveler setObject:arrFailItems
                            forKey:eTraveler_TestFailuresKey];
    }
    
    if ([[m_arrAppleControllers objectAtIndex:([szSlotID intValue] - 1)] isKindOfClass:[AppleControlledStation class]])
    {
        [AppleTestStationAutomation testStation:[m_arrAppleControllers objectAtIndex:([szSlotID intValue] - 1)]
                            finishedWithResults:[NSArray arrayWithObject:dicTempTraveler]];
        [self writeLog:[NSString stringWithFormat:@"Send to agent ====> The reuslt of the testing is [%@]", dicTempTraveler]
            WithSlotID:szSlotID];
    }
    else
    {
        [self writeLog:[NSString stringWithFormat:@"The applecontroller [%@] is NOT OK, cannot send the result to agent!", [m_arrAppleControllers objectAtIndex:([szSlotID intValue] - 1)]]
            WithSlotID:szSlotID];
    }
    
    @synchronized(m_arrTravelers)
    {
        [m_arrTravelers replaceObjectAtIndex:([szSlotID intValue] - 1)
                                  withObject:[NSNull null]];
    }
    @synchronized(m_arrFixtureStatus)
    {
        [m_arrFixtureStatus replaceObjectAtIndex:([szSlotID intValue] - 1)
                                      withObject:m_Tx_Fixture_Normal];
    }
    
    return;
}

- (BOOL) startWithTravelers:(NSArray *)travelers;
{
    return [NSNumber numberWithBool:YES];
}
- (BOOL) abortTesting:(NSDictionary *)options;
{
    return [NSNumber numberWithBool:YES];
}
- (BOOL) stationQuery:(NSDictionary *)query;
{
    return [NSNumber numberWithBool:YES];
}

#pragma mark - Actioins
- (IBAction)HELP_ACTION:(id)sender
{
    NSLog(@"Help menu active.");
    // Insert code here
}

- (IBAction)MENU_Normal:(id)sender
{
    NSLog(@"MENU_Normal begin");
    szSenderTitle	= [sender title];
    [txtPasswordCheck setHidden:YES];
    [self runPasswordCheck];
    NSLog(@"MENU_Normal end");
}

- (IBAction)MENU_Audit:(id)sender
{
    NSLog(@"MENU_Audit begin");
    szSenderTitle	= [sender title];
    [txtPasswordCheck setHidden:NO];
    [txtPasswordCheck setStringValue:@""];
    [self runPasswordCheck];
    NSLog(@"MENU_Audit end");
}

- (IBAction)MENU_TOOL3:(id)sender
{
    NSLog(@"MENU_TOOL3 begin");
    // get test once script file name referred to Tool menu item
    szSenderTitle	= [sender title];
    //[self getTestOnceScriptFileNameWithMenuItemTitle:[sender title]];
    // Password check
    [self runPasswordCheck];
    NSLog(@"MENU_TOOL3 end");
}

- (IBAction)QuerySFIS:(id)sender
{
    [[NSBundle mainBundle]loadNibNamed:@"QueryPage" owner:nil topLevelObjects:nil];
	//[NSBundle loadNibNamed:@"QueryPage" owner:nil];
	MuifaScroller *scroller=[[MuifaScroller alloc] init];
	[[[[[webViewSFIS mainFrame] frameView] documentView] enclosingScrollView] setVerticalScroller:scroller];
	[scroller release];
	scroller=[[MuifaScroller alloc] init];
	[[[[[webViewSFIS mainFrame] frameView] documentView] enclosingScrollView] setHorizontalScroller:scroller];
	[scroller release];

    NSArray *arrPType    = [kFZ_UserDefaults objectForKey:@"QueryPType"];
    NSArray *arrCheckBox    = [m_mtxPType cells];
    if ([arrPType count] > [arrCheckBox count]||[arrPType count] == 0 )
    {
        NSAlert *alert = [[NSAlert alloc]init];
        alert.messageText = @"警告(Warning)";
        alert.informativeText = @"請確認PType數量是否正確";
        [alert addButtonWithTitle:@"确认(OK)"];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
        [alert release];
        return;
    }
	
    for (int i = 0; i < [arrPType count]; i++)
    {
        [[arrCheckBox objectAtIndex:i] setTitle:[arrPType objectAtIndex:i]];
        [[arrCheckBox objectAtIndex:i] setState:1];
    }
}

- (IBAction)QuerySend:(id)sender
{
    //Read URL From ghInformation
    NSString        *strGhURLInfo = [m_dicGHInfo_Muifa objectForKey:descriptionOfGHStationInfo(IP_SFC_URL)];
    //Get PType from setting file
    NSMutableString *strQueryCombine = [[NSMutableString alloc]init];
    NSString    *strURLTxt  = [m_txtQueryURL stringValue];
    NSString    *strQuerySN = [m_txtQuerySN stringValue];
    
    if (!strURLTxt || [strURLTxt isEqualToString:@""])
    {
        [strQueryCombine setString:[NSString stringWithFormat:@"%@?c=QUERY_RECORD",strGhURLInfo]];
    }
    else
    {
        [strQueryCombine setString:[NSString stringWithFormat:@"%@?c=QUERY_RECORD",strURLTxt]];
    }
    
    
    if (!strQuerySN||[strQuerySN isEqualToString:@""])
    {
        NSAlert *alert = [[NSAlert alloc]init];
        alert.messageText = @"警告(Warning)";
        alert.informativeText = @"請確認Query SN是否正確";
        [alert addButtonWithTitle:@"确认(OK)"];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
        [alert release];
		[strQueryCombine release]; strQueryCombine = nil;
        return;
    }
    
    [strQueryCombine appendFormat:@"&sn=%@",strQuerySN];
    
    NSArray *arrCheckBox    = [m_mtxPType cells];
    
    for (int i = 0; i < [arrCheckBox count]; i++)
    {
        if ([[arrCheckBox objectAtIndex:i] state]== NSOnState)
        {
            [strQueryCombine appendFormat:@"&p=%@",[[arrCheckBox objectAtIndex:i]title]];
        }
    }
	
	[[webViewSFIS mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:strQueryCombine]]];
    [strQueryCombine release];
}


- (void)runPasswordCheck
{
    // security window , u should enter the right password.
    [scrWindow setBackgroundColor:nil];
    [NSApp runModalForWindow:scrWindow];
}

- (IBAction)OKButtionPressed:(id)sender
{
    if ([szSenderTitle isEqualToString: @"Audit"])
    {
        if ([[txtPasswordCheck stringValue]isEqualToString:@"opencontrolrun"])
        {
            gbAuditMode = YES;
            [scrWindow orderOut:nil];
            [NSApp endSheet:scrWindow];
            [window setTitle:[NSString stringWithFormat:@"[Audit Mode]%@",window.title]];
        }
        else
        {
            NSAlert *alert = [[NSAlert alloc]init];
            alert.messageText = @"错误（ERROR）";
            alert.informativeText =@"请输入正确的密码（Please input the right passworld!）";
            [alert addButtonWithTitle:@"确定（OK）"];
            [alert runModal];
            [alert release];
        }
    }
    if ([szSenderTitle isEqualToString: @"Normal"])
    {
        gbAuditMode = NO;
        [scrWindow orderOut:nil];
        [NSApp endSheet:scrWindow];
        [window setTitle:[window.title SubFrom:@"Mode]" include:NO]];
    }
}

- (IBAction)checkPassword:(id)btn
{
    // get the formatted date
    NSDateFormatter	*dateformat			= [[NSDateFormatter alloc]init];
    [dateformat setDateStyle:NSDateFormatterMediumStyle];
    [dateformat setTimeStyle:NSDateFormatterShortStyle];
    [dateformat setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSString		*szPasswordCheck	= [NSString stringWithFormat:
										   @"%@",
										   [dateformat stringFromDate:[NSDate date]]];
    [dateformat release];
    // get month and day
    szPasswordCheck	= [szPasswordCheck SubFrom:@"-" include:NO];
    szPasswordCheck	= [szPasswordCheck SubTo:@" " include:NO];
    szPasswordCheck	= [szPasswordCheck stringByReplacingOccurrencesOfString:@"-" withString:@""];
    szPasswordCheck	= [NSString stringWithFormat:@"ATS%@",szPasswordCheck];
    NSString	*szPasswordEnter	= [NSString stringWithFormat:@"%@",[txtPasswordCheck stringValue]];
    if([szPasswordEnter isEqualToString:szPasswordCheck])
    {
        [txtPasswordCheck setStringValue:@""];
        [scrWindow setBackgroundColor:[NSColor greenColor]];
        [scrWindow orderOut:nil];
        [NSApp endSheet:scrWindow];
		
		[self getTestOnceScriptFileNameWithMenuItemTitle:szSenderTitle];
    }
    else
    {
        [txtPasswordCheck setStringValue:@""];
        [scrWindow setBackgroundColor:[NSColor redColor]];
    }
}

- (IBAction)cancelPasswordCheck:(NSButton *)btn
{
    [scrWindow orderOut:nil];
    [NSApp endSheet:scrWindow];
}

#pragma mark - Others
- (void)moveTextString:(NSString *)szString andSpeed:(NSTimeInterval)iSpeed
{
    ScrollingTextView *moveView = [[ScrollingTextView alloc] init];
    moveView.frame = NSRectFromCGRect(CGRectMake(300, self.window.frame.size.height - 55, self.window.frame.size.width - 300 * 2, 30));
    moveView.text  = szString;
    moveView.speed = iSpeed;
    [[self.window contentView] addSubview:moveView];
    [moveView release];
}

#pragma mark - Respondor Delegate
- (void)setNextResponder:(Template *)templateObj
{
	NSInteger index = [m_arrTemplateObject indexOfObject:templateObj];
	
	// From index to (index + [m_arrTemplateObje count]), checking all objects
	for (NSInteger i  = index; i < index + [m_arrTemplateObject count]; i ++)
	{
		NSInteger indexNew = (i+1) % [m_arrTemplateObject count];
		Template * nextTemplate = [m_arrTemplateObject objectAtIndex:indexNew];
		// If the next template is running, set focus on it.
		if (nextTemplate.isRunning)
		{
			continue;
		}
		else
		{
			[self.window makeFirstResponder:nextTemplate.serialNumber1];
			return;
		}
	}
}

- (void)linkToTabViewItem:(NSButton *)sender
{
    NSTabViewItem	*tabViewItemObj	= [m_dicTabViewObject objectForKey:[sender title]];
    NSTabView		*tabView		= [tabViewItemObj tabView];
    [tabView selectTabViewItem:tabViewItemObj];
}

//For SMT-QT 2UP
- (void)setDefaultResponder
{
	NSInteger allIndex = [m_arrTemplateObject count];
    if (allIndex > 0)
    {
        Template *defaultTemplate   = [m_arrTemplateObject objectAtIndex:0];
        [self.window makeFirstResponder:defaultTemplate.serialNumber1];
    }
}
//For SMT-QT 2UP
//For check all template SN repeat function
- (BOOL)CheckSNHaveRepeat:(Template *)templateObj
{
    NSLog(@"Start to check SN have repeat");
    
    //int iAll    = [m_arrTemplateObject count];
    NSInteger iIndex  = [m_arrTemplateObject indexOfObject:templateObj];
    NSString    *strSerialNumber    = [templateObj.serialNumber1 stringValue];
    
    for (int i = 0; i < iIndex; i++)
    {
        Template    *objTemplate    = [m_arrTemplateObject objectAtIndex:i];
        NSString    *strLastSN      = [objTemplate.serialNumber1 stringValue];
        if ([strLastSN isEqualToString:strSerialNumber])
        {
            [templateObj.serialNumber1 setStringValue:@""];
            NSString *szAlert = [NSString stringWithFormat:@"請重新刷入SN, 當前的SN: %@ 已重複刷入了。(You have scanned the same SN with previous slots.Please scan SN again)",strSerialNumber];
            NSAlert *alert = [[NSAlert alloc]init];
            alert.messageText = @"警告(Warning)";
            alert.informativeText = szAlert;
            [alert addButtonWithTitle:@"确认(OK)"];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert runModal];
            [alert release];
            return NO;
        }
        
    }
    NSLog(@"End to check SN have repeat");
    return YES;
}

//For SMT-QT 2UP
//For check all Template have started and send message to Template
- (void)MonitorFixtureHaveStarted
{
    NSAutoreleasePool   *pool   = [[NSAutoreleasePool alloc]init];
    NSMutableString     *strReadData    = [[NSMutableString  alloc] init];
    NSDictionary    *dicFixtureDevice   = [[kFZ_UserDefaults objectForKey:@"DeviceSetting"] objectForKey:@"FIXTURE"];
    int             iBaudRate           = [[dicFixtureDevice objectForKey:@"BAUDE_RATE"] intValue];
    int             iDataBit            = [[dicFixtureDevice objectForKey:@"DATA_BIT"] intValue];
    int             iStopBit            = [[dicFixtureDevice objectForKey:@"STOP_BIT"] intValue];
    NSString        *strParity          = [dicFixtureDevice objectForKey:@"PARITY"];
    NSString        *strEndSymbol       = [dicFixtureDevice objectForKey:@"ENDFLAG"];
    NSString        *strBSDPath         = m_strSMFixtureName;
    NSInteger       iRet                = kUart_SUCCESS;
    BOOL            bRet                = YES;
    
    // open port
    if (nil == m_objSMUart)
	{
        iRet	= kUart_CMD_CHECK_DUT_FAIL;
    }
	else
    {
        iRet	= [m_objSMUart openPort:strBSDPath
                           baudeRate:iBaudRate
                             dataBit:iDataBit
                              parity:strParity
                            stopBits:iStopBit
                           endSymbol:strEndSymbol];
    }
    
    // write command to port
    if(kUart_SUCCESS != iRet)//iRet== 0 --> succeed
    {
        NSLog(@"Open Fixture Port Error");
    }
    
    //For Monitor Fixture
    NSDictionary    *dicSFMUSetting     = [kFZ_UserDefaults objectForKey:@"SFMUSetting"];
    NSArray         *arrMonitorCommands        = [dicSFMUSetting objectForKey:@"MONITORFIXTURE"];
    NSArray         *arrResetCommands        = [dicSFMUSetting objectForKey:@"RESETFIXTURE"];
    
    for (int i = 0; i < [arrResetCommands count]; i++)
    {
        //Modify for the ATA QTx auto test, do not use sleep function. We need to accepet the query request from ATSagent
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
        NSString    *strCommand = [[arrResetCommands objectAtIndex:i]objectForKey:@"COMMAND"];
        
        [m_objSMUart Clear_UartBuff:0.25 TimeOut:5 readOut:nil];
        [m_objSMUart  Write_UartCommand:strCommand
                              PackedNum:1
                               Interval:0
                                  IsHex:NO];
        [m_objSMUart  Read_UartData:strReadData
                    TerminateSymbol:[NSArray arrayWithObjects:@"@_@", nil]
                          MatchType:0
                       IntervalTime:0.01
                            TimeOut:5];
        NSLog(@"COMMAND = %@ UART RESPONSE = %@",strCommand,strReadData);
        if ([strCommand contains:@"Fixture Info"]) {
            for (int j = 0; j < [m_arrTemplateObject count]; j++)
            {
                Template *template = [m_arrTemplateObject objectAtIndex:j];
                template.strSMFixtureInfo = [NSMutableString stringWithString:strReadData];
            }
        }
    }
    
    while (1)
    {
        NSString    *strCommand = [[arrMonitorCommands objectAtIndex:0]objectForKey:@"COMMAND"];
        NSString    *strPassKey = [[arrMonitorCommands objectAtIndex:0]objectForKey:@"PASSKEY"];
        [m_objSMUart  Write_UartCommand:strCommand
                              PackedNum:1
                               Interval:0
                                  IsHex:NO];
        [m_objSMUart  Read_UartData:strReadData
                    TerminateSymbol:[NSArray arrayWithObjects:@"@_@", nil]
                          MatchType:0
                       IntervalTime:0.01
                            TimeOut:5];
        
        if ((kUart_SUCCESS != iRet) || ([strReadData rangeOfString:strPassKey].location == NSNotFound))
        {
            bRet    = NO;
        }
        else
        {
            bRet    = YES;
        }
        
        NSLog(@"COMMAND = %@ UART RESPONSE = %@",strCommand,strReadData);
        
        if (bRet)
        {
            NSInteger iAll = [m_arrTemplateObject count];
            BOOL bAll = NO;
            for (int i = 0; i < iAll; i++)
            {
                Template *objTemplate = [m_arrTemplateObject objectAtIndex:i];
                if (![objTemplate.btnStart isEnabled])
                {
                    bAll = YES;
                }
            }
            if (bAll)
            {
                break;
            }
            
        }
        //Modify for the ATA QTx auto test, do not use sleep function. We need to accepet the query request from ATSagent
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    }
    
    NSNotificationCenter    *nc  = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"TEMNOTIFORCHECKALLTEMPLATEHAVESTARTED" object:self userInfo:nil];
    
    [strReadData release];
    [pool drain];
}

//For SMT-QT 2UP
//For check all Template have Finished and send message to Template
- (void)APPFixtureHaveFinished:(NSNotification *)aNote
{
    NSInteger iAll = [m_arrTemplateObject count];
    BOOL bAll = YES;
    for (int i = 0; i < iAll; i++)
    {
        Template *objTemplate = [m_arrTemplateObject objectAtIndex:i];
        if (!objTemplate.isFinished)
        {
            bAll = NO;
        }
    }
    if (bAll)
    {
        [self MonitorFixtureHaveFinished];
        NSNotificationCenter    *nc  = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:@"TEMNOTIFORCHECKALLTEMPLATEHAVEFINISHED" object:self userInfo:nil];
        [self setDefaultResponder];
        [NSThread detachNewThreadSelector:@selector(MonitorFixtureHaveStarted) toTarget:self withObject:nil];
    }
}
- (BOOL)MonitorFixtureHaveFinished
{
    BOOL            bRet                = YES;
    // open port
    if (nil == m_objSMUart)
	{
        return NO;
    }
    
    NSDictionary    *dicSFMUSetting     = [kFZ_UserDefaults objectForKey:@"SFMUSetting"];
    NSArray         *arrCommands        = [dicSFMUSetting objectForKey:@"ENDFIXTURE"];
    NSMutableString     *strReadData    = [[NSMutableString  alloc] init];
    for (int i = 0; i < [arrCommands count]; i++)
    {
        //Modify for the ATA QTx auto test, do not use sleep function. We need to accepet the query request from ATSagent
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
        NSString    *strCommand = [[arrCommands objectAtIndex:i]objectForKey:@"COMMAND"];
        NSString    *strPassKey = [[arrCommands objectAtIndex:i]objectForKey:@"PASSKEY"];
        
        [m_objSMUart Clear_UartBuff:0.25 TimeOut:5 readOut:nil];
        [m_objSMUart  Write_UartCommand:strCommand
                              PackedNum:1
                               Interval:0
                                  IsHex:NO];
        [m_objSMUart  Read_UartData:strReadData
                    TerminateSymbol:[NSArray arrayWithObjects:@"@_@", nil]
                          MatchType:0
                       IntervalTime:0.01
                            TimeOut:5];
        
        if ([strReadData rangeOfString:strPassKey].location == NSNotFound)
        {
            bRet    = NO;
        }
        NSLog(@"COMMAND = %@ UART RESPONSE = %@",strCommand,strReadData);
    }
    [strReadData release];
    
    [m_objSMUart Close_Uart];
    return bRet;
}

//For SMT-QT 2UP
//For check all Template have finished and restart the fixture for next test
- (void)APPLoopTestCheckFinished:(NSNotification *)aNote
{
    NSInteger iAll = [m_arrTemplateObject count];
    BOOL bAll = YES;
    for (int i = 0; i < iAll; i++)
    {
        Template *objTemplate = [m_arrTemplateObject objectAtIndex:i];
        if (!objTemplate.isFinished)
        {
            bAll = NO;
        }
    }
    if (bAll)
    {
        [self LoopTestWithFixture];
        NSNotificationCenter    *nc  = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:@"TEMNOTIFORLOOPTESTCHECKALLTEMPLATEHAVEFINISHED" object:self userInfo:nil];
    }
}

//For SMT-QT 2UP
- (BOOL)LoopTestWithFixture
{
    BOOL            bRet                = YES;
    // open port
    if (nil == m_objSMUart)
	{
        return NO;
    }
    
    NSDictionary    *dicSFMUSetting     = [kFZ_UserDefaults objectForKey:@"SFMUSetting"];
    NSArray         *arrCommands        = [dicSFMUSetting objectForKey:@"LOOPTESTFIXTURE"];
    NSMutableString     *strReadData    = [[NSMutableString  alloc] init];
    for (int i = 0; i < [arrCommands count]; i++)
    {
        //Modify for the ATA QTx auto test, we need to accepet the query request from ATSagent
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
        NSString    *strCommand = [[arrCommands objectAtIndex:i]objectForKey:@"COMMAND"];
        NSString    *strPassKey = [[arrCommands objectAtIndex:i]objectForKey:@"PASSKEY"];
        
        [m_objSMUart Clear_UartBuff:0.25 TimeOut:5 readOut:nil];
        [m_objSMUart  Write_UartCommand:strCommand
                              PackedNum:1
                               Interval:0
                                  IsHex:NO];
        [m_objSMUart  Read_UartData:strReadData
                    TerminateSymbol:[NSArray arrayWithObjects:@"@_@", nil]
                          MatchType:0
                       IntervalTime:0.01
                            TimeOut:5];
        
        if ([strReadData rangeOfString:strPassKey].location == NSNotFound)
        {
            bRet    = NO;
        }
        NSLog(@"COMMAND = %@ UART RESPONSE = %@",strCommand,strReadData);
    }
    [strReadData release];
    
    return bRet;
}
-(void)APPTestItemSYNC
{
    NSLog(@"[sync]receive notification");
    //1. Founy zong post noti, count + 1.
    m_iTestItemSYNCCount = m_iTestItemSYNCCount + 1;
    
    //2. May be some slot have cancel to end, did not post noti, so check template finished or not. then make sure count + 1 or not.
    for (int i = 0; i < [m_arrTemplateObject count]; i++)
    {
        Template *template = [m_arrTemplateObject objectAtIndex:i];
        if (template.isFinished)
        {
            NSLog(@"slot have finished because some reasons, like cancel to end, so count also +1");
            m_iTestItemSYNCCount = m_iTestItemSYNCCount + 1;
        }
    }
    NSLog(@"[sync]current count:%d",m_iTestItemSYNCCount);
    if (m_iTestItemSYNCCount >= [m_arrTemplateObject count])
    {
        m_iTestItemSYNCCount = 0;
        NSLog(@"[sync] start send fixture command");
        
        //3. run fixture command.
        if ([[kFZ_UserDefaults objectForKey:@"SFMUSetting"] isKindOfClass:[NSDictionary class]])
        {
            NSDictionary    *dicSFMUSetting     = [kFZ_UserDefaults objectForKey:@"SFMUSetting"];
            NSArray         *arrSIMOUT          = [dicSFMUSetting objectForKey:@"SIMOUT"];
            NSMutableString     *strReadData    = [[NSMutableString  alloc] init];
            
            for (int k = 0; k < [arrSIMOUT count]; k++)
            {
                NSString    *strCommand = [[arrSIMOUT objectAtIndex:k]objectForKey:@"COMMAND"];
                [m_objSMUart Clear_UartBuff:0.25 TimeOut:5 readOut:nil];
                [m_objSMUart  Write_UartCommand:strCommand
                                      PackedNum:1
                                       Interval:0
                                          IsHex:NO];
                [m_objSMUart  Read_UartData:strReadData
                            TerminateSymbol:[NSArray arrayWithObjects:@"@_@", nil]
                                  MatchType:0
                               IntervalTime:0.01
                                    TimeOut:5];
                NSLog(@"[sync]COMMAND = %@ UART RESPONSE = %@",strCommand,strReadData);
                //Modify for the ATA QTx auto test, do not use sleep function. We need to accepet the query request from ATSagent
                [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
            }
            [strReadData release];
        }
        NSLog(@"[sync]set bool as yes");
        
        //4. All slots have runed at the same item, so ask all slot continue the rest test items.
        for (int j = 0; j < [m_arrTemplateObject count]; j++)
        {
            Template *template = [m_arrTemplateObject objectAtIndex:j];
            template.testProgress.m_bTestItemSYNCContinue = YES;
        }
    }else
    {
        NSLog(@"Wait other slots.");
    }
}



#pragma mark - Live & JSON file

//For Live & JSON file
- (BOOL)CheckCRLiveStatus
{
    if ([[m_dicGHInfo_Muifa objectForKey:descriptionOfGHStationInfo(IP_CONTROL_RUN)]isEqualToString:@"ON"])
    {
        return YES;
    }
    return NO;
}

- (void)WriteLiveInfoToUIVersion
{
    NSString    *strAppBundleVer    = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
    NSDictionary *dicData = [m_dicLiveInfo objectForKey:@"data"];
    if ([[dicData objectForKey:@"Versions"] isNotEqualTo:@""] && [dicData objectForKey:@"Versions"] != nil
        && [[dicData objectForKey:@"build"] isNotEqualTo:@""] && [dicData objectForKey:@"build"] != nil)
    {
        NSString    *strLiveVer = [dicData objectForKey:@"Versions"];
        [m_strLiveVersion setString:strLiveVer];
        NSString    *strLiveBuild = [dicData objectForKey:@"build"];
        [m_strUIVersion	setString:[NSString stringWithFormat:@"%@_%@_%@",strAppBundleVer,strLiveBuild,strLiveVer]];
    }
    else
    {
        [m_strUIVersion setString:[NSString stringWithFormat:@"%@",strAppBundleVer]];
    }
}

- (NSString *)GetLivePath:(NSString *)strIdentifier
{
    NSFileManager *fileManager  = [NSFileManager defaultManager];
    if ([strIdentifier isEqualToString:@"local"])
    {
        NSString	*szScriptFileName	= [[[kFZ_UserDefaults objectForKey:kUserDefaultScriptInfo]
                                            objectForKey:kUserDefaultScriptFileName]SubTo:@".plist" include:NO];
        NSString	*strDefaultLivePath	= [NSString stringWithFormat:
                                           @"%@/Contents/Frameworks/FunnyZone.framework/Resources/%@_LIVE.json",
                                           [[NSBundle mainBundle] bundlePath], szScriptFileName];
        if ([kFZ_UserDefaults objectForKey:@"DefaultLivePath"])
        {
            strDefaultLivePath      = [kFZ_UserDefaults objectForKey:@"DefaultLivePath"];
            if ([strDefaultLivePath contains:@"~"]) {
                strDefaultLivePath = [NSString stringWithFormat:@"%@%@",NSHomeDirectory(),[strDefaultLivePath SubFrom:@"~" include:NO]];
            }
        }
        if ([fileManager fileExistsAtPath:strDefaultLivePath])
        {
            return strDefaultLivePath;
        }
        else
            return nil;
    }
    else if (![strIdentifier isEqualToString:@"default"] &&
            ![strIdentifier isEqualToString:@"control_run"])
    {
        return nil;
    }
    else
    {
        NSString    *strLivePath    = [m_dicGHInfo_Muifa objectForKey:descriptionOfGHStationInfo(IP_LIVE_VERSION_PATH)];
        NSString    *strLiveVersion	= [m_dicGHInfo_Muifa objectForKey:descriptionOfGHStationInfo(IP_LIVE_VERSION)];
        NSString    *strIdentifierPath  = [NSString stringWithFormat:@"%@_%@",strIdentifier,
                                       [m_dicGHInfo_Muifa objectForKey:descriptionOfGHStationInfo(IP_STATION_TYPE)]];
        NSString    *strLiveAliasPath   = [NSString stringWithFormat:@"%@/%@/%@",
                                           strLivePath,strLiveVersion,strIdentifierPath];
        NSLog(@"GH Live Controller Alias File Path=====%@",strLiveAliasPath);
        
        NSString    *strLiveOriginalName = [fileManager destinationOfSymbolicLinkAtPath:strLiveAliasPath error:nil];
        NSLog(@"GH Live Controller Original File Name=====%@",strLiveOriginalName);
        
        NSString    *strLiveOriginaPath  = [NSString stringWithFormat:@"%@/%@/%@",
                                            strLivePath,strLiveVersion,strLiveOriginalName];
        NSLog(@"GH Live Controller Original File Path=====%@",strLiveOriginaPath);
        if ([fileManager fileExistsAtPath:strLiveOriginaPath])
        {
            return strLiveOriginaPath;
        }
        else
            return nil;
    }
}

- (BOOL)ParseAndCombineJson:(NSString *)strLivePath
{
    BOOL    bCreateScript   = YES;
    NSString	*szTestAllFileName	= [[[kFZ_UserDefaults objectForKey:@"ScriptInfo"]objectForKey:@"ScriptFileName"]SubTo:@".plist" include:NO];
    NSString	*szTestAllFilePath	= [NSString stringWithFormat:
                                       @"%@/Contents/Frameworks/FunnyZone.framework/Resources/%@_TESTALL.plist",
                                       [[NSBundle mainBundle] bundlePath], szTestAllFileName];
    
    NSString        *strJsonData    = [[NSString alloc] initWithContentsOfFile:strLivePath
                                                                      encoding:NSUTF8StringEncoding
                                                                         error:nil];
    NSData          *dtJsonData     = [strJsonData dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary    *dicJsonData    = [NSJSONSerialization JSONObjectWithData:dtJsonData
                                                                      options:NSJSONReadingMutableLeaves
                                                                        error:nil];
    [strJsonData release];  strJsonData = nil;
    
    //Create Test Script
    bCreateScript  &= [self CombineScriptFile:szTestAllFilePath JsonData:dicJsonData];
    
    //Create Limits Script
    bCreateScript  &= [self CreatLimitsFile:szTestAllFilePath JsonData:dicJsonData];
    if (bCreateScript)
    {
        m_dicLiveInfo   = [dicJsonData retain];
    }
    
    return bCreateScript;
}

- (NSString *)GetLiveVersion:(NSString *)strLivePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:strLivePath])
    {
        return nil;
    }
    NSString        *strJsonData    = [[NSString alloc] initWithContentsOfFile:strLivePath encoding:NSUTF8StringEncoding error:nil];
    NSData          *dtJsonData     = [strJsonData dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary    *dicJsonData    = [NSJSONSerialization JSONObjectWithData:dtJsonData options:NSJSONReadingMutableLeaves error:nil];
    NSString        *strNewLiveVersion  = [[dicJsonData objectForKey:@"data"]objectForKey:@"Versions"];
    [strJsonData release];  strJsonData = nil;
    if (!strNewLiveVersion)
    {
        return nil;
    }
    else
        return strNewLiveVersion;
}

- (IBAction)ChooseControlRun:(id)sender
{
    if ([[kFZ_UserDefaults objectForKey:@"DisableLiveFunction"] boolValue] ||
        [[kFZ_UserDefaults objectForKey:@"NoLiveControl"]boolValue])
    {
        [btnControlRun setState:0];
        [btnControlRun setEnabled:NO];
        return;
    }
    //Unit is running, waitting
    for (int i = 0; i < [m_arrTemplateObject count]; i++)
    {
        Template *objTemplate = [m_arrTemplateObject objectAtIndex:i];
        if (objTemplate.isRunning)
        {
            ATSRunAlertPanel(@"警告(Warning)", @"请等待所有机台测试完成后，再点击control run！", @"噢(OK)", nil, nil);
            if ([btnControlRun state]==1)
            {
                [btnControlRun setState:0];
            }
            else
                [btnControlRun setState:1];
            return;
        }
    }
    
    // Update m_dicGHInfo_Muifa
    TestProgress *tempProgerss = [[TestProgress alloc] initWithPublicParam:m_objPublicParam];
    [tempProgerss.memoryValues setObject:[NSDictionary dictionaryWithContentsOfFile:kMuifaPlistPath]
                                  forKey:kPD_Muifa_Plist];
    if (![[kFZ_UserDefaults objectForKey:@"DisablePudding"] boolValue])
    {
        @synchronized(m_dicGHInfo_Muifa)
        {
            [m_dicGHInfo_Muifa release];
            m_dicGHInfo_Muifa	= [[tempProgerss getStationInfo] retain];
        }
    }
    [tempProgerss release];
    
    //get json file path
    NSString *strLivePath = nil;
    if ([btnControlRun state]==0)
    {
        strLivePath = [self GetLivePath:@"default"];
    }
    else if([btnControlRun state]==1)
    {
        strLivePath = [self GetLivePath:@"control_run"];
    }
    if ([btnControlRun state]==1 && ![self CheckCRLiveStatus]) {
        ATSRunAlertPanel(@"警告(Warning)", @"Groundhog 服务器 Control Run没有打开，请检查!", @"噢(OK)", nil, nil);
        [btnControlRun setState:0];
        return;
    }
    
    //Parse and combine json and testall
    if (!strLivePath || ![self ParseAndCombineJson:strLivePath])
    {
        ATSRunAlertPanel(@"警告(Warning)", @"找不到Live文件或产生剧本档失败!", @"噢(OK)", nil, nil);
        if ([btnControlRun state]==1)
        {
            [btnControlRun setState:0];
        }
        else
            [btnControlRun setState:1];
        return;
    }
    
    //Get UI version
    NSString	*szStationID		= [m_dicGHInfo_Muifa objectForKey:descriptionOfGHStationInfo(IP_STATION_ID)] ? [m_dicGHInfo_Muifa objectForKey:descriptionOfGHStationInfo(IP_STATION_ID)] : @"**********";
    NSString	*szStationNumber	= [m_dicGHInfo_Muifa objectForKey:descriptionOfGHStationInfo(IP_STATION_NUMBER)] ? [m_dicGHInfo_Muifa objectForKey:descriptionOfGHStationInfo(IP_STATION_NUMBER)] : @"**********";
    [self WriteLiveInfoToUIVersion];
    NSString	*szAllInfo			= [NSString stringWithFormat:
                                       @"%@[%@]\t Version:%@",
                                       szStationID,szStationNumber, m_strUIVersion];
    [window setTitle:szAllInfo];
    
    //parse and load script file
    NSString	*szPlanFileName	= [[kFZ_UserDefaults objectForKey:kUserDefaultScriptInfo]
                                   objectForKey:kUserDefaultScriptFileName];
    for (int i = 0; i < [m_arrTemplateObject count]; i++)
    {
        Template *objTemplate = [m_arrTemplateObject objectAtIndex:i];
        [objTemplate parseAndLoadScriptFile:szPlanFileName
                               OnlyTestOnce:YES];
    }
}

- (void)RegisterNotificationForLive:(NSString *)LivePath
{
    FSEventStreamContext context;
    context.info    = (__bridge void *)(self);
    context.version = 0;
    context.retain  = NULL;
    context.release = NULL;
    context.copyDescription = NULL;
    
    NSArray *arrPathToWatch = [NSArray arrayWithObject:LivePath];
    
    m_streamFolder = FSEventStreamCreate(NULL, fsEventsCallback, &context, (__bridge CFArrayRef)arrPathToWatch, kFSEventStreamEventIdSinceNow, (CFTimeInterval)2, kFSEventStreamCreateFlagUseCFTypes|kFSEventStreamCreateFlagFileEvents | kFSEventStreamEventFlagMustScanSubDirs);
    
    FSEventStreamScheduleWithRunLoop(m_streamFolder, CFRunLoopGetMain(), kCFRunLoopDefaultMode);
    FSEventStreamStart(m_streamFolder);
    
}

void fsEventsCallback(ConstFSEventStreamRef streamRef, void *clientCallBackInfo, size_t numEvents,
                      void *eventPaths, const FSEventStreamEventFlags eventFlags[],
                      const FSEventStreamEventId eventIds[])
{
    NSArray *paths      = (__bridge NSArray *)(eventPaths);
    MuifaAppDelegate *app  = (__bridge MuifaAppDelegate *)(clientCallBackInfo);
    
    for (int i = 0;i < numEvents;i++)
    {
        FSEventStreamEventFlags flags = eventFlags[i];
        FSEventStreamEventId eventID  = eventIds[i];
        NSString *szPath              = [paths objectAtIndex:i];
        NSLog(@"FSEventStreamEventFlags = %u,%llu,%@,%d,%@",(unsigned int)flags,eventID,szPath,i,clientCallBackInfo);
        
        if (flags & kFSEventStreamEventFlagItemCreated)
        {
            NSLog(@"%@",szPath);
            [app NotificationFromLive];
            break;
        }
        
        if (flags & kFSEventStreamEventFlagItemRenamed)
        {
            NSLog(@"%@",szPath);
            [app NotificationFromLive];
            break;
        }
        
        if (flags & kFSEventStreamEventFlagItemModified)
        {
            NSLog(@"%@",szPath);
            [app NotificationFromLive];
            break;
        }
        
        if (flags & kFSEventStreamEventFlagItemRemoved)
        {
            NSLog(@"%@",szPath);
            [app NotificationFromLive];
            break;
        }
    }
}

- (void)ForCheckTemplateTestFinished
{
    NSInteger iTemplate   = [m_arrTemplateObject count];
    
    while (1)
    {
        usleep(100);
        int iTotal = 0;
        for (int i = 0; i < [m_arrTemplateObject count]; i++)
        {
            Template *objTemplate = [m_arrTemplateObject objectAtIndex:i];
            objTemplate.isLiveChanging  = YES;
            if (!objTemplate.isRunning)
            {
                iTotal = iTotal + 1;
            }
        }
        if (iTemplate == iTotal)
        {
            usleep(500000);
            [NSApp terminate:self];
        }
    }
}

- (void)NotificationFromLive
{
    TestProgress *tempProgerss = [[TestProgress alloc] initWithPublicParam:m_objPublicParam];
    [tempProgerss.memoryValues setObject:[NSDictionary dictionaryWithContentsOfFile:kMuifaPlistPath]
                                     forKey:kPD_Muifa_Plist];
    if (![[kFZ_UserDefaults objectForKey:@"DisablePudding"] boolValue])
    {
        @synchronized(m_dicGHInfo_Muifa)
        {
            [m_dicGHInfo_Muifa release];
            m_dicGHInfo_Muifa	= [[tempProgerss getStationInfo] retain];
        }
    }
    [tempProgerss release];
    NSString *strLivePath = [self GetLivePath:@"default"];
    if ([self CheckCRLiveStatus] && [btnControlRun state]==1)
    {
        strLivePath = [self GetLivePath:@"control_run"];
    }
    if (strLivePath)
    {
        NSString        *strNewLiveVersion  = [self GetLiveVersion:strLivePath];
        if (![strNewLiveVersion isEqualToString:m_strLiveVersion])
        {
            [NSThread detachNewThreadSelector:@selector(ForCheckTemplateTestFinished) toTarget:self withObject:nil];
        }
    }
}

- (void)WriteString: (NSString*)WriteData FilePath:(NSString *)szFilePath;
{
    NSString    *strFilePath    = szFilePath;
    NSString    *strFileData    = [NSString stringWithFormat:@"%@",WriteData];
    
    NSString		*szDirectory	= [strFilePath stringByDeletingLastPathComponent];
    NSFileManager	*fileManager	= [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:szDirectory])
        [fileManager createDirectoryAtPath:szDirectory
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    
    NSFileHandle	*fileHandle		= [NSFileHandle fileHandleForWritingAtPath:strFilePath];
    
    if (!fileHandle)
        [strFileData writeToFile:strFilePath
                      atomically:NO
                        encoding:NSUTF8StringEncoding
                           error:nil];
    else
    {
        NSData	*dataTemp	= [[NSData alloc] initWithBytes:(void *)[strFileData UTF8String]
                                                  length:[strFileData length]];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:dataTemp];
        [dataTemp release];
    }
    [fileHandle closeFile];
}

- (NSString *)FormatStringToSpecial:(NSString *)StringData
{
    NSString    *strOriginal  = [NSString stringWithFormat:@"  %@  ",StringData];
    NSUInteger   iOrigLength   = [strOriginal length];
    NSUInteger iSpecail    = (90 - iOrigLength)/2;
    
    NSMutableString *strNewData = [[NSMutableString alloc]init];
    for (NSUInteger i = 0; i < iSpecail; i++)
    {
        [strNewData appendString:@"-"];
    }
    
    NSString    *strReturn  = [NSString stringWithFormat:@"%@%@%@",strNewData,strOriginal,strNewData];
    
    [strNewData release];
    return strReturn;
    
}

-(BOOL)CombineScriptFile:(NSString *)szScriptFilePath JsonData:(NSDictionary*)dicJsonData
{
    //For write logs
    BOOL    bRet    = YES;
    NSString    *strCmd_ID = @"[*JSON_COMMAND*]";
    NSString    *strFilePath    = @"/vault/Live_Log.txt";
    NSFileManager   *fileManage = [NSFileManager defaultManager];
    void(^FindJsonCmdAndReplace)(NSMutableArray *pAryItem,NSString *pszCommand) = ^(NSMutableArray *pAryItem,NSString *pszCommand)
    {
        for (NSMutableDictionary *dictData in pAryItem) {
            for (NSString *sKey in [dictData allKeys]) {
                if ([sKey isEqualToString:@"SEND_COMMAND:"]) {
                    NSMutableDictionary *dictSubItem = [dictData objectForKey:sKey];
                    if ([[dictSubItem valueForKey:@"TARGET"] containsString:@"MOBILE"] && [[dictSubItem valueForKey:@"STRING"] containsString:strCmd_ID]) {
                        NSString    *szTargetCmd = [[dictSubItem valueForKey:@"STRING"]
                                                    stringByReplacingOccurrencesOfString:strCmd_ID withString:pszCommand];
                        [dictSubItem setValue:szTargetCmd forKey:@"STRING"];
                    }
                }
                else
                    if ([sKey isEqualToString:@"READ_COMMAND:RETURN_VALUE:"]) {
                        NSMutableDictionary *dictSubItem = [dictData objectForKey:sKey];
                        if ([[dictSubItem valueForKey:@"TARGET"] containsString:@"MOBILE"] && [[dictSubItem valueForKey:@"BEGIN"] containsString:strCmd_ID]) {
                            NSString    *szTargetCmd = [[dictSubItem valueForKey:@"BEGIN"]
                                                        stringByReplacingOccurrencesOfString:strCmd_ID withString:pszCommand];
                            [dictSubItem setValue:szTargetCmd forKey:@"BEGIN"];
                        }
                    }
            }
        }
    };
    int(^FindSameJsonCmdIndex)(NSArray *pAryCom,int index) = ^(NSArray *pAryCom,int index)
    {
        NSString *pszCommand = [pAryCom objectAtIndex:index];
        int count = 0;
        for (int i = 0; i<index; i++) {
            if ([[pAryCom objectAtIndex:i]isEqualToString:pszCommand]) {
                count++;
            }
        }
        return count;
    };

    if ([fileManage fileExistsAtPath:strFilePath])
    {
        [fileManage removeItemAtPath:strFilePath error:nil];
    }
    
    [self WriteString:@"===================================  CREATE TEST ITEMS  ===================================\n" FilePath:strFilePath];
    
    //Get testall data
    NSDictionary    *dicTestAllItems    = [NSDictionary dictionaryWithContentsOfFile:szScriptFilePath];
    
    //Get Json item data
    NSArray         *arrJsonItems       = [[dicJsonData objectForKey:@"data"] objectForKey:@"tests"];
    
    //Combine test script
    NSMutableArray  *arrNewItems    = [[NSMutableArray alloc]init];
    for (int i = 0; i < [arrJsonItems count]; i++)
    {
        NSDictionary    *dicJsonItemData        = [arrJsonItems objectAtIndex:i];
        
        // Get item's main and sub name
        NSString        *strJsonItemMainName    = [[dicJsonItemData objectForKey:@"Name"] objectForKey:@"main"];
        NSArray         *aryJsonItemFunction    = [dicJsonItemData objectForKey:@"FunctionNames"];
        NSMutableArray  *aryJsonItemSubItems    = [NSMutableArray array];
        if ([[[dicJsonItemData objectForKey:@"Name"] allKeys] containsObject:@"sub1"])
        {
            NSDictionary *dicNames = [dicJsonItemData objectForKey:@"Name"];
            for (int i = 1; i < [dicNames count]; i++)
            {
                [aryJsonItemSubItems addObject:[dicNames objectForKey:[NSString stringWithFormat:@"sub%d",i]]];
            }
        }
        NSAssert(aryJsonItemFunction,@"Can not find FunctionNames item of %@",strJsonItemMainName);
        NSArray         *arrJsonItemCommands    = [dicJsonItemData objectForKey:@"Commands"];
        NSString        *strJsonItemFunction    = [aryJsonItemFunction objectAtIndex:0];
        NSString        *strDebugLogItem    = [self FormatStringToSpecial:strJsonItemMainName];
        [self WriteString:[NSString stringWithFormat:@"%@\n",strDebugLogItem] FilePath:strFilePath];
        
        //New sub item alloc
        NSMutableArray  *arrNewSubItems         = [[NSMutableArray alloc]init];
        
        
        if([arrJsonItemCommands count] == 0 ||
           ([arrJsonItemCommands count] == 1 && [[arrJsonItemCommands objectAtIndex:0] isEqualToString:@"*"])
           ||([arrJsonItemCommands count] == 1 && [[arrJsonItemCommands objectAtIndex:0] isEqualToString:@""]))
        {
            NSString    *strDBItemKey   = [NSString stringWithFormat:@"%@ = ",strJsonItemFunction];
            NSArray     *arrDBSubitems      = [[dicTestAllItems objectForKey:strJsonItemFunction]objectForKey:@"*"];
            
            if (arrDBSubitems && [arrDBSubitems count] > 0)
            {
                [arrNewSubItems addObjectsFromArray:arrDBSubitems];
                [self WriteString:[NSString stringWithFormat:@"^_^ PASS >>>>> %@\n",strDBItemKey] FilePath:strFilePath];
                
            }
            else
            {
                NSString    *strFailMessage = [NSString stringWithFormat:@"T_T FAIL >>>>> %@\n",strDBItemKey];
                [self WriteString:strFailMessage FilePath:strFilePath];
                bRet = NO;
            }
            //Add for main item
            [arrNewItems addObject:[NSDictionary dictionaryWithObject:arrNewSubItems forKey:strJsonItemMainName]];
        }
        else
        {
            if ([aryJsonItemSubItems count] > 0)
            {
                NSString *strSubItemName;
                if ([aryJsonItemFunction count] < [aryJsonItemSubItems count])
                {
                    ATSRunAlertPanel(@"警告(Warning)", @"不能匹配Sub item，请检查JSON文件", @"噢(OK)", nil, nil);
                    bRet = NO;
                    [arrNewSubItems release];
                    [arrNewItems release];
                    [NSApp terminate:self];

                }
                for (int i1 = 0;i1 < [aryJsonItemSubItems count];i1 ++)
                {
                    NSString *strJsonItemSubFunction = [aryJsonItemFunction objectAtIndex:i1+1];
                    strSubItemName = [aryJsonItemSubItems objectAtIndex:i1];
                    for (int j = 0; j < [arrJsonItemCommands count]; j++)
                    {
                        NSString    *strJsonCommand         = [arrJsonItemCommands objectAtIndex:j];
                        NSString    *strDBItemKey   = [NSString stringWithFormat:@"%@ = %@",strJsonItemSubFunction,strJsonCommand];
                        NSArray     *arrDBSubitems      = [[dicTestAllItems objectForKey:strJsonItemSubFunction]objectForKey:strJsonCommand];
                        int index = FindSameJsonCmdIndex(arrJsonItemCommands,j);
                        if (index!=0 &&
                            [[dicTestAllItems objectForKey:strJsonItemFunction]objectForKey:[NSString stringWithFormat:@"%d_%@",index,strJsonCommand]])
                        {
                            NSString *strIndexCommand = [NSString stringWithFormat:@"%d_%@",index,strJsonCommand];
                            strDBItemKey   = [NSString stringWithFormat:@"%@ = %@",strJsonItemFunction,strIndexCommand];
                            arrDBSubitems      = [[dicTestAllItems objectForKey:strJsonItemFunction]objectForKey:strIndexCommand];
                        }
                        
                        if (arrDBSubitems && [arrDBSubitems count] > 0)
                        {
                            FindJsonCmdAndReplace((NSMutableArray *)arrDBSubitems,strJsonCommand);
                            [arrNewSubItems addObjectsFromArray:arrDBSubitems];
                            [self WriteString:[NSString stringWithFormat:@"^_^ PASS >>>>> %@\n",strDBItemKey] FilePath:strFilePath];
                        }
                        else
                        {
                            NSString    *strFailMessage = [NSString stringWithFormat:@"T_T FAIL >>>>> %@\n",strDBItemKey];
                            [self WriteString:strFailMessage FilePath:strFilePath];
                            bRet = NO;
                        }
                    }
                    
                    // Add for sub items
                    [arrNewItems addObject:[NSDictionary dictionaryWithObject:[NSArray arrayWithArray:arrNewSubItems] forKey:strSubItemName]];
                    
                    [arrNewSubItems removeAllObjects];
                }
            }
            
            // Add for Main item
            for (int j = 0; j < [arrJsonItemCommands count]; j++)
            {
                NSString    *strJsonCommand         = [arrJsonItemCommands objectAtIndex:j];
                NSString    *strDBItemKey   = [NSString stringWithFormat:@"%@ = %@",strJsonItemFunction,strJsonCommand];
                NSArray     *arrDBSubitems      = [[dicTestAllItems objectForKey:strJsonItemFunction]objectForKey:strJsonCommand];
                int index = FindSameJsonCmdIndex(arrJsonItemCommands,j);
                if (index!=0 &&
                    [[dicTestAllItems objectForKey:strJsonItemFunction]objectForKey:[NSString stringWithFormat:@"%d_%@",index,strJsonCommand]])
                {
                    NSString *strIndexCommand = [NSString stringWithFormat:@"%d_%@",index,strJsonCommand];
                    strDBItemKey   = [NSString stringWithFormat:@"%@ = %@",strJsonItemFunction,strIndexCommand];
                    arrDBSubitems      = [[dicTestAllItems objectForKey:strJsonItemFunction]objectForKey:strIndexCommand];
                }
                
                if (arrDBSubitems && [arrDBSubitems count] > 0)
                {
                    FindJsonCmdAndReplace((NSMutableArray *)arrDBSubitems,strJsonCommand);
                    [arrNewSubItems addObjectsFromArray:arrDBSubitems];
                    [self WriteString:[NSString stringWithFormat:@"^_^ PASS >>>>> %@\n",strDBItemKey] FilePath:strFilePath];
                }
                else
                {
                    NSString    *strFailMessage = [NSString stringWithFormat:@"T_T FAIL >>>>> %@\n",strDBItemKey];
                    [self WriteString:strFailMessage FilePath:strFilePath];
                    bRet = NO;
                }
            }
            
            //Add for main item
            [arrNewItems addObject:[NSDictionary dictionaryWithObject:arrNewSubItems forKey:strJsonItemMainName]];
            
        }
        [arrNewSubItems release];
    }
    
    NSString	*szFileName = [[kFZ_UserDefaults objectForKey:kUserDefaultScriptInfo] objectForKey:kUserDefaultScriptFileName];
    NSString    *szFilePath = [NSString stringWithFormat:
                               @"%@/%@",[[NSBundle bundleForClass:[TestProgress class]] resourcePath], szFileName];
    [arrNewItems writeToFile:szFilePath atomically:YES];
    [arrNewItems release];
    return bRet;
}

-(NSDictionary *)FormatLimits:(NSDictionary *)dicJsonItemSpec WithMainName:(NSString *)strMainName
{
    //Init spec
    NSMutableString *strJsonItemSpec = [NSMutableString stringWithString:@"{NA}"];
    NSString        *strJsonItemUnits   = @"";
    
    //No spec
    if (!dicJsonItemSpec || nil == dicJsonItemSpec || [[dicJsonItemSpec allKeys] count] == 0)
    {
        
        NSDictionary    *dicSpecAndUnits    = [NSDictionary dictionaryWithObjectsAndKeys:
                                               strJsonItemSpec,@"spec",
                                               strJsonItemUnits,@"units",
                                               strMainName,@"mainName",nil];
        return dicSpecAndUnits;
    }
    
    //Only match spec
    if ([[dicJsonItemSpec allKeys] containsObject:@"match"])
    {
        NSArray *arrSpecs   = [dicJsonItemSpec objectForKey:@"match"];
        NSMutableString *strSpecs   = [NSMutableString string];
        
        if (!([arrSpecs count] == 1 && [[arrSpecs objectAtIndex:0] isEqualToString:@"*"]))
        {
            for (int j = 0; j < [arrSpecs count]; j++)
            {
                [strSpecs appendFormat:@"%@,",[arrSpecs objectAtIndex:j]];
            }
            NSString    *strSecondSpec  = strSpecs;
            strSecondSpec   = [strSecondSpec stringByReplacingCharactersInRange:NSMakeRange([strSecondSpec length]-1, 1) withString:@""];
            [strJsonItemSpec setString:[NSString stringWithFormat:@"<%@>",strSecondSpec]];
        }
    }
    
    //For max1 min1 max2 min2 ... specs
    else if([[dicJsonItemSpec allKeys] containsObject:@"max1"] ||
            [[dicJsonItemSpec allKeys] containsObject:@"min1"])
    {
        NSInteger iSpecCount = 0, iMaxCount = 0, iMinCount = 0 ;
        NSMutableString *strTempSpec = [NSMutableString string];
        for (NSString *strSpec in [dicJsonItemSpec allKeys])
        {
            if ([strSpec contains:@"max"]) {
                iMaxCount++;
            }
            if ([strSpec contains:@"min"]) {
                iMinCount++;
            }
        }
        iSpecCount = (iMaxCount >= iMinCount)?iMaxCount:iMinCount;
        
        for (int i = 0; i<iSpecCount; i++)
        {
            NSString *strUpLimit = [dicJsonItemSpec objectForKey:[NSString stringWithFormat:@"max%d",i+1]];
            NSString *strDownLimit = [dicJsonItemSpec objectForKey:[NSString stringWithFormat:@"min%d",i+1]];
            if ([strUpLimit isEqualToString:@"N/A"] || nil == strUpLimit)
            {
                strUpLimit = @"";
            }
            if ([strDownLimit isEqualToString:@"N/A"] || nil == strDownLimit)
            {
                strDownLimit = @"";
            }
            NSString *strOneSpec = [NSString stringWithFormat:@"[%@,%@]",strDownLimit,strUpLimit];
            if([strOneSpec isEqualToString:@"[,]"])
                strOneSpec = @"{NA}";
            if (i == iSpecCount - 1)
                [strTempSpec appendFormat:@"%@",strOneSpec];
            else
                [strTempSpec appendFormat:@"%@ || ",strOneSpec];
        }
        [strJsonItemSpec setString:strTempSpec];
        
        //For CoF Spec
        if ([[dicJsonItemSpec allKeys] containsObject:@"cofMin"] || [[dicJsonItemSpec allKeys] containsObject:@"cofMax"])
        {
            NSString    *strCofUpLimit      = [dicJsonItemSpec objectForKey:@"cofMax"];
            NSString    *strCofDownLimit    = [dicJsonItemSpec objectForKey:@"cofMin"];
            if ([strCofUpLimit isEqualToString:@"N/A"] || nil == strCofUpLimit)
            {
                strCofUpLimit = @"";
            }
            if ([strCofDownLimit isEqualToString:@"N/A"] || nil == strCofDownLimit)
            {
                strCofDownLimit = @"";
            }
            NSString *strJsonItemCofSpec  = [NSString stringWithFormat:@"[%@,%@]", strCofDownLimit, strCofUpLimit];
            
            if ([strJsonItemCofSpec isEqualToString:@"[,]"])
            {
                strJsonItemCofSpec = @"{NA}";
            }
            [strJsonItemSpec appendFormat:@";cof%@",strJsonItemCofSpec];
        }
        // For "Units"
        NSString    *strUnits       = [dicJsonItemSpec objectForKey:@"units"];
        if (nil != strUnits || [strUnits isNotEqualTo:@""] || 0 != [strUnits length])
        {
            strJsonItemUnits = [NSString stringWithFormat:@"%@",strUnits];
        }
    }
    
    //Only max and min spec
    else if([[dicJsonItemSpec allKeys] containsObject:@"max"] ||
            [[dicJsonItemSpec allKeys] containsObject:@"min"])
    {
        NSString    *strUpLimit     = [dicJsonItemSpec objectForKey:@"max"];
        NSString    *strDownLimit   = [dicJsonItemSpec objectForKey:@"min"];
        NSString    *strUnits       = [dicJsonItemSpec objectForKey:@"units"];
        
        if ([strUpLimit isEqualToString:@"N/A"] || nil == strUpLimit)
        {
            strUpLimit = @"";
        }
        if ([strDownLimit isEqualToString:@"N/A"] || nil == strDownLimit)
        {
            strDownLimit = @"";
        }
        [strJsonItemSpec setString:[NSString stringWithFormat:@"[%@,%@]",strDownLimit,strUpLimit]];
        if ([strJsonItemSpec isEqualToString:@"[,]"])
        {
            [strJsonItemSpec setString:@"{NA}"];
        }
        //For CoF Spec
        if ([[dicJsonItemSpec allKeys] containsObject:@"cofMin"] || [[dicJsonItemSpec allKeys] containsObject:@"cofMax"])
        {
            NSString    *strCofUpLimit      = [dicJsonItemSpec objectForKey:@"cofMax"];
            NSString    *strCofDownLimit    = [dicJsonItemSpec objectForKey:@"cofMin"];
            if ([strCofUpLimit isEqualToString:@"N/A"] || nil == strCofUpLimit)
            {
                strCofUpLimit = @"";
            }
            if ([strCofDownLimit isEqualToString:@"N/A"] || nil == strCofDownLimit)
            {
                strCofDownLimit = @"";
            }
            NSString *strJsonItemCofSpec  = [NSString stringWithFormat:@"[%@,%@]", strCofDownLimit, strCofUpLimit];
            
            if ([strJsonItemCofSpec isEqualToString:@"[,]"])
            {
                strJsonItemCofSpec = @"{NA}";
            }
            [strJsonItemSpec appendFormat:@";cof%@",strJsonItemCofSpec];
        }
        // For "Units"
        if (nil != strUnits || [strUnits isNotEqualTo:@""] || 0 != [strUnits length])
        {
            strJsonItemUnits    = [NSString stringWithFormat:@"%@",strUnits];
        }
    }
    
    else
    {
        NSLog(@"incorrect format key");
    }
    
    NSDictionary    *dicSpecAndUnits    = [NSDictionary dictionaryWithObjectsAndKeys:
                                           strJsonItemSpec,@"spec",
                                           strJsonItemUnits,@"units",
                                           strMainName,@"mainName",nil];
    return dicSpecAndUnits;
}

-(BOOL)CreatLimitsFile:(NSString *)szScriptFilePath JsonData:(NSDictionary*)dicJsonData
{
    BOOL    bRet = YES;
    
    //For write logs
    NSString    *strFilePath    = @"/vault/Live_Log.txt";
    [self WriteString:@"===================================  CREATE TEST LIMITS  ===================================\n" FilePath:strFilePath];
    
    //Get Json item data
    NSArray         *arrJsonItems       = [[dicJsonData objectForKey:@"data"] objectForKey:@"tests"];
    
    //For save comman and Type spec.
    NSMutableDictionary  *dicComUnitSpecs  = [[NSMutableDictionary alloc]init];
    NSMutableDictionary  *dicTypeUnitSpecs  = [[NSMutableDictionary alloc]init];
    
    for (int i = 0; i < [arrJsonItems count]; i++)
    {
        NSDictionary    *dicJsonItemData        = [arrJsonItems objectAtIndex:i];
        NSString        *strJsonItemMainName    = [[dicJsonItemData objectForKey:@"Name"] objectForKey:@"main"];
        NSArray         *aryJsonItemFunction    = [dicJsonItemData objectForKey:@"FunctionNames"];
        
        NSAssert(aryJsonItemFunction,@"Can not find FunctionNames item of %@",strJsonItemMainName);
        NSString        *strJsonItemFunction    = [aryJsonItemFunction objectAtIndex:0];
        NSString        *strDebugLogItem    = [self FormatStringToSpecial:strJsonItemMainName];
        [self WriteString:[NSString stringWithFormat:@"%@\n",strDebugLogItem] FilePath:strFilePath];
        
        //Get json spec
        NSDictionary    *dicJsonItemSpec    = [dicJsonItemData objectForKey:@"Specification"];
        if ([[dicJsonItemSpec allKeys] containsObject:@"Type1"] ||
            [[dicJsonItemSpec allKeys] containsObject:@"Type2"] ||
            [[dicJsonItemSpec allKeys] containsObject:@"Type3"])
        {
            for (NSString *key in dicJsonItemSpec)
            {
                NSDictionary *dicOneType = [dicJsonItemSpec objectForKey:key];
                NSString *strTypeName = [dicOneType objectForKey:@"Type_name"];
                if (!strTypeName || [strTypeName isEqualToString:@""]) {
                    strTypeName = key;
                }
                if (![dicTypeUnitSpecs objectForKey:strTypeName])
                {
                    [dicTypeUnitSpecs setObject:[NSMutableDictionary dictionaryWithCapacity:200] forKey:strTypeName];
                }
                NSDictionary *dicLimitsAndUnits = [self FormatLimits:dicOneType WithMainName:strJsonItemMainName];
                [[dicTypeUnitSpecs objectForKey:strTypeName] setObject:dicLimitsAndUnits
                                                                forKey:strJsonItemFunction];
                [self WriteString:[NSString stringWithFormat:@"^_^ GET %@ SPEC >>>>> %@ FROM ITEM %@\n",
                                   strTypeName, [dicLimitsAndUnits objectForKey:@"spec"],strJsonItemFunction] FilePath:strFilePath];
                [self WriteString:[NSString stringWithFormat:@"^_^ GET %@ UNITS >>>>> %@ FROM ITEM %@\n",
                                   strTypeName,[dicLimitsAndUnits objectForKey:@"unit"],strJsonItemFunction] FilePath:strFilePath];
                //For sub items which contain "sub1 .... ".
                if ([aryJsonItemFunction count] > 1)
                {
                    for (int i = 1;i < [aryJsonItemFunction count];i++)
                    {
                        strJsonItemFunction = [aryJsonItemFunction objectAtIndex:i];
                        [[dicTypeUnitSpecs objectForKey:strTypeName] setObject:dicLimitsAndUnits
                                                                        forKey:strJsonItemFunction];
                        [self WriteString:[NSString stringWithFormat:@"^_^ GET %@ SPEC >>>>> %@ FROM ITEM %@\n",
                                           strTypeName, [dicLimitsAndUnits objectForKey:@"spec"],strJsonItemFunction] FilePath:strFilePath];
                        [self WriteString:[NSString stringWithFormat:@"^_^ GET %@ UNITS >>>>> %@ FROM ITEM %@\n",
                                           strTypeName,[dicLimitsAndUnits objectForKey:@"unit"],strJsonItemFunction] FilePath:strFilePath];
                    }
                }
            }
        }
        else
        {
            NSDictionary *dicLimitsAndUnits = [self FormatLimits:dicJsonItemSpec WithMainName:strJsonItemMainName];
            [dicComUnitSpecs setObject:dicLimitsAndUnits forKey:strJsonItemFunction];
            
            //For sub items which contain "sub1 .... ".
            if ([aryJsonItemFunction count] > 1)
            {
                for (int i = 1;i < [aryJsonItemFunction count];i++)
                {
                    strJsonItemFunction = [aryJsonItemFunction objectAtIndex:i];
                    [dicComUnitSpecs setObject:dicLimitsAndUnits
                                        forKey:strJsonItemFunction];
                }
            }
            [self WriteString:[NSString stringWithFormat:@"^_^ GET COMMAN SPEC >>>>> %@ FROM ITEM %@\n",
                               [dicLimitsAndUnits objectForKey:@"spec"],strJsonItemFunction] FilePath:strFilePath];
            [self WriteString:[NSString stringWithFormat:@"^_^ GET COMMAN UNITS >>>>> %@ FROM ITEM %@\n",
                               [dicLimitsAndUnits objectForKey:@"unit"],strJsonItemFunction] FilePath:strFilePath];
        }
    }
    
    // Write .plist limits file.
    NSString *szStationName	= [[[kFZ_UserDefaults objectForKey:@"ScriptInfo"]objectForKey:@"ScriptFileName"]SubTo:@".plist" include:NO];
    NSString *szLimitFilePath = [NSString stringWithFormat:
                                 @"%@/Contents/Frameworks/FunnyZone.framework/Resources/%@_Limit.plist",
                                 [[NSBundle mainBundle] bundlePath], szStationName];
    if ([[dicTypeUnitSpecs allKeys]count] > 0)
    {
        NSArray *arrTypeName = [dicTypeUnitSpecs allKeys];
        for (int i = 0; i<[arrTypeName count]; i++)
        {
            NSMutableDictionary *dicAllUnitSpecs = [[NSMutableDictionary alloc]initWithDictionary:dicComUnitSpecs copyItems:YES];
            NSString *strTypeName = [arrTypeName objectAtIndex:i];
            szLimitFilePath = [NSString stringWithFormat:
                               @"%@/Contents/Frameworks/FunnyZone.framework/Resources/%@_%@_Limit.plist",
                               [[NSBundle mainBundle] bundlePath], szStationName,strTypeName];
            for (NSString *key in [dicTypeUnitSpecs objectForKey:strTypeName])
            {
                [dicAllUnitSpecs setObject:[[dicTypeUnitSpecs objectForKey:strTypeName]objectForKey:key] forKey:key];
            }
            [dicAllUnitSpecs writeToFile:szLimitFilePath atomically:YES];
            [dicAllUnitSpecs release];
        }
    }
    else
    {
        [dicComUnitSpecs writeToFile:szLimitFilePath atomically:YES];
    }
    
    [dicTypeUnitSpecs release];
    [dicComUnitSpecs release];
    return bRet;
}

- (BOOL)CheckSumForJSON:(NSDictionary *)dicJSON
{
    if (nil == [dicJSON objectForKey:@"data"] ||
        ![[dicJSON objectForKey:@"data"] isKindOfClass:[NSDictionary class]] ||
        nil == [dicJSON objectForKey:@"hash"] ||
        ![[dicJSON objectForKey:@"hash"] isKindOfClass:[NSString class]])
    {
        NSLog(@"The format of JSON file is NOT correct, pleaes check! [%@]", dicJSON);
        return NO;
    }
    NSDictionary *dicData = [NSDictionary dictionaryWithObject:[dicJSON objectForKey:@"data"] forKey:@"data"];
    NSData *dataOriginal = [NSJSONSerialization dataWithJSONObject:dicData options:NSJSONWritingPrettyPrinted error:nil];
    NSString            *szOriginalHash = [dicJSON objectForKey:@"hash"];
    NSLog(@"The hash in JSON is [%@]", szOriginalHash);
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1([dataOriginal bytes], (CC_LONG)[dataOriginal length], digest);
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH*2];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02X", digest[i]];
    NSString            *szOutputHash   = [NSString stringWithString:output];
    NSLog(@"The output hash is [%@]", szOutputHash);
    
    if ([[szOriginalHash uppercaseString] isEqualToString:[szOutputHash uppercaseString]])
    {
        [dicData release];
        return YES;
    }
    [dicData release];
    return NO;
}

//Check the JSON file's signature by the Python file that provide by Marmoon
- (BOOL)CheckSignatureForJSONOnPath:(NSString *)szJSONPath
{
    NSString	*szBsdPath		= @"/Applications/Python/verifyJsonObj.py";
    NSString	*szPath			= @"/usr/bin/python";
    NSString	*szKeyPath		= @"/Applications/Python/qt_rsa_key.pub";
    
    NSTask	*task		= [[NSTask alloc] init];
    NSPipe	*outPipe	= [[NSPipe alloc]init];
    [task setLaunchPath:szPath];
    NSArray	*args		= [NSArray arrayWithObjects:
                           szBsdPath,
                           @"-i",
                           szJSONPath,
                           @"-k",
                           szKeyPath,
                           nil];
    [task setArguments:args];
    [task setStandardOutput:outPipe];
    [task launch];
    
    NSData	*data		= [[outPipe fileHandleForReading]
                           readDataToEndOfFile];
    [task waitUntilExit];
    [task release];
    [outPipe release];
    NSString	*szString	= [[NSString alloc]	initWithData:data
                                               encoding:NSASCIIStringEncoding];
    NSLog(@"Response command:%@",szString);
    
    if ([szString contains:@"hash matches"] &&
        [szString contains:@"signature matches"])
    {
        [szString release];
        return YES;
    }
    [szString release];
    return NO;
}

#pragma mark - For Delete Process Log

- (void)DeleteProcessLog:(id)_para
{
    [NSThread detachNewThreadSelector:@selector(RemoveProcessLog:) toTarget:self withObject:[_para userInfo]];
}

- (void)RemoveProcessLog:(NSDictionary *)Para
{
    NSAutoreleasePool      *pool = [[NSAutoreleasePool alloc] init];
    NSString          *szLogPath = [[kFZ_UserDefaults objectForKey:@"Log_Path"] objectForKey:@"LogPath"];
    NSInteger               iDay = [[Para objectForKey:@"DeleteProcessLogsAfterDays"] integerValue];
    NSTimeInterval secondsPerDay = 24*60*60;
    NSDate         *standardDate = [[NSDate date] dateByAddingTimeInterval:-(secondsPerDay * iDay)];
    
    NSFileManager   *fileManager = [NSFileManager defaultManager];
    NSArray       *arrSubFolders = [fileManager contentsOfDirectoryAtPath: szLogPath error:nil];
    
    for (int i = 0; i < [arrSubFolders count]; i++)
    {
        NSString        *strSubFolderName   = [arrSubFolders objectAtIndex:i];
        NSString        *strSubFolderPath   = [NSString stringWithFormat:@"%@/%@",szLogPath,strSubFolderName];
        NSDictionary    *dictAttribute      = [fileManager attributesOfItemAtPath:strSubFolderPath error:nil];
        NSDate          *fileDate   = [dictAttribute objectForKey:NSFileModificationDate];
        if ([fileDate compare: standardDate] == NSOrderedAscending)
        {
            [fileManager removeItemAtPath:strSubFolderPath error:nil];
        }
    }
    
    [pool drain];
}
@end




