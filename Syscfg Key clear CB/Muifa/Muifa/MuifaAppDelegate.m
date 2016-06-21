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

- (id)init
{
    self = [super init];

    if (self) 
    {
        
        m_arrLocationID         = [[NSMutableArray alloc]init];
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
        m_objSMUart         = [[PEGA_ATS_UART alloc] init_Uart];
        m_objSerialPorts    = [[SearchSerialPorts alloc]init];
    }
    
    //For SMT-QT 2UP
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(APPFixtureHaveFinished:) name:@"APPNOTIFORCHECKFIXTUREHAVEFINISHED" object:nil];
    [nc addObserver:self selector:@selector(APPLoopTestCheckFinished:) name:@"APPNOTIFORLOOPTESTCHECKALLTEMPLATEHAVEFINISHED" object:nil];

    
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
    [m_arrLocationID release];

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
        NSRunAlertPanel(@"警告(Warning)",
						@"没有路径:%@下的写入权限。(No permission to write ATS_Muifa_Counter.plist at path:%@)",
						@"确认(OK)", nil, nil, kUserDefaultPath,kUserDefaultPath);
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
            NSRunAlertPanel(@"警告(Warning)",
                            [NSString stringWithFormat:@"Cable Mapping Error\n找不到正确的治具控制线"],@"噢(OK)", nil, nil);
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
    
	//Modified by raniys on 2/26/2015: delete LiveController and add default Live file
    /*************************Start modify*********************/
    //Get GH Live Controller Alias File Path
    NSString * strLivePath		= [m_dicGHInfo_Muifa objectForKey:descriptionOfGHStationInfo(IP_LIVE_VERSION_PATH)];
    NSString * strLiveCurrent	= [m_dicGHInfo_Muifa objectForKey:descriptionOfGHStationInfo(IP_LIVE_CURRENT)];
    NSString * strController	= [m_dicGHInfo_Muifa objectForKey:descriptionOfGHStationInfo(IP_CONTROL_RUN)];
    NSString * strCRFile        = [strController isEqualToString:@"ON"] ? @"control_run" : @"default";
    NSString * strLimitFilePath = [NSString stringWithFormat:@"%@/%@/%@",strLivePath,strLiveCurrent,strCRFile];
    NSString * szStationName	= [[[kFZ_UserDefaults objectForKey:@"ScriptInfo"]objectForKey:@"ScriptFileName"]SubTo:@".plist" include:NO];
    NSString * strDefaultLivePath = [NSString stringWithFormat:
                                     @"%@/Contents/Frameworks/FunnyZone.framework/Resources/LIVE_%@_DEFAULT.plist",
                                     [[NSBundle mainBundle] bundlePath],szStationName];
    NSLog(@"GH Live Controller Alias File Path=====%@",strLimitFilePath);
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([[m_dicGHInfo_Muifa objectForKey:descriptionOfGHStationInfo(IP_LIVE_CURRENT)]boolValue]&&[fileManager fileExistsAtPath:strLimitFilePath])
    {
        //Get GH Live Controller Original File Path
        NSString    *szOriginalName = [fileManager destinationOfSymbolicLinkAtPath:strLimitFilePath error:nil];
        NSLog(@"GH Live Controller Original File Name=====%@",szOriginalName);
        NSString    *szOriginalPath  = [NSString stringWithFormat:@"%@/%@/%@",strLivePath,strLiveCurrent,szOriginalName];
        NSLog(@"GH Live Controller Original File Path=====%@",szOriginalPath);
        
        //Get GH Live Controller All Data
        NSDictionary *dicGHInfo_Live = [[NSDictionary dictionaryWithContentsOfFile:szOriginalPath] retain];
        NSLog(@"GH Live Controller All Data%@",dicGHInfo_Live);
        
        NSString    *strAppBundleVer    = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
        if ([[dicGHInfo_Live objectForKey:@"LIVE_VER"] isNotEqualTo:@""]
            && [dicGHInfo_Live objectForKey:@"LIVE_VER"] != nil)
        {
            NSString    *strLiveVer = [dicGHInfo_Live objectForKey:@"LIVE_VER"];
            m_strUIVersion	= [NSString stringWithFormat:@"%@_%@",strAppBundleVer,strLiveVer];;
            
            if ([strCRFile isEqualToString:@"control_run"])
            {
                [self moveTextString: @"      It's Control Run mode" andSpeed: 0.036];
            }
        }
        else
        {
            m_strUIVersion = [NSString stringWithFormat:@"%@_Null",strAppBundleVer];
        }
        [dicGHInfo_Live release];
        
    }
    else if([fileManager fileExistsAtPath:strDefaultLivePath])
    {
        NSDictionary *dicGHInfo_Live = [[NSDictionary dictionaryWithContentsOfFile:strDefaultLivePath] retain];
        NSLog(@"GH Live Controller All Data%@",dicGHInfo_Live);
        NSString    *strAppBundleVer    = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
        if ([[dicGHInfo_Live objectForKey:@"LIVE_VER"] isNotEqualTo:@""]
            && [dicGHInfo_Live objectForKey:@"LIVE_VER"] != nil)
        {
            NSString    *strLiveVer = [dicGHInfo_Live objectForKey:@"LIVE_VER"];
            m_strUIVersion	= [NSString stringWithFormat:@"%@_%@",strAppBundleVer,strLiveVer];;
            
            if ([strCRFile isEqualToString:@"control_run"])
            {
                [self moveTextString: @"      It's Control Run mode" andSpeed: 0.036];
            }
            
        }
        else
        {
            m_strUIVersion = [NSString stringWithFormat:@"%@_Null",strAppBundleVer];
        }
        [dicGHInfo_Live release];
    }
    else
       m_strUIVersion	= [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
    /*************************End modify*********************/
    
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
            
            m_iSlot_NO				= [m_arrTemplateObject count];
            
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
                NSString    *szStationName  = [NSString stringWithFormat:@"%@_%d", [m_dicGHInfo_Muifa objectForKey: descriptionOfGHStationInfo(IP_STATION_ID)], (i+1)];
                NSString    *szStationClass = [m_dicGHInfo_Muifa objectForKey:descriptionOfGHStationInfo(IP_STATION_ID)];
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
    if (bAssignPort && [[[kFZ_UserDefaults objectForKey:@"ScriptInfo"] objectForKey:@"ScriptFileName"] ContainString:@"CG-O-TEST"])
    {
        [self initialOTESTFixture:arrPorts];
    }
    
    
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
    
    
    PEGA_ATS_UART   *objDWUart         = [[PEGA_ATS_UART alloc] init_Uart];
    PEGA_ATS_UART   *objUPUart         = [[PEGA_ATS_UART alloc] init_Uart];
    
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
		
		//Chao
        [aTemplate.btnStart setHidden:YES];
        
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
		
        
        //Chao
        [aTemplate.btnStart setHidden:YES];
        
        
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
            NSRunAlertPanel(@"警告(Warning)",
							@"请设置正确的一次性剧本档。(You need to set TestOnceScriptFile correctly!)",
							@"确认(OK)", nil, nil);
    }
    else
        NSRunAlertPanel(@"警告(Warning)",
						@"请先把测试站架好。(You need to set up station correctly!)",
						@"确认(OK)", nil, nil);
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
            NSRunAlertPanel(@"警告(Warning)",
							@"设定档中没有正确的设定一次性剧本档。(There is no TestOnceScriptFile in Muifa.plist, You need to set TestOnceScriptFile correctly!)",
							@"确定(OK)", nil, nil);
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
    
//FUCK GYRO
    [NSThread detachNewThreadSelector:@selector(StartThreadToDetect) toTarget:self withObject:nil];
    
    
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
            if ([objTemp.btnStart isEnabled])
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
    [self writeLog:[NSString stringWithFormat:@"The query function is unabled, no need to do anything with this, just return YES..."]
        WithSlotID:@"LogWithoutUnit.log"];
    return YES;

    /*
     *For now, there is no query function.
    //Got the data from agent
    if (![[query objectForKey:@"TravelersInfo"] isKindOfClass:[NSArray class]])
    {
        [self writeLog:[NSString stringWithFormat:@"The data format of the key [TravelersInfo] is not NSArray, no need to do anything!"]
            WithSlotID:@"LogWithoutUnit.log"];
        return NO;
    }
    NSMutableArray  *arrTravelers   = [[NSMutableArray alloc] initWithArray:[query objectForKey:@"TravelersInfo"]];
    for (int iTraveler = 0; iTraveler < [arrTravelers count]; iTraveler++)
    {
        NSString        *szSlotID       = [[[arrTravelers objectAtIndex:iTraveler] objectForKey:eTraveler_TrayIDKey] stringValue];
        if ([szSlotID intValue] < 1 ||
            [szSlotID intValue] > m_iSlot_NO ||
            nil == szSlotID)
        {
            [self writeLog:[NSString stringWithFormat:@"Read from agent <==== The slot ID [%@] is over the count of the slot number [%d], cannot response the status for this.", szSlotID, m_iSlot_NO]
                WithSlotID:@"LogWithoutUnit.log"];
            continue;
        }
        
        [self writeLog:[NSString stringWithFormat:@"**********Query**********\nRead from agent <==== StationName: [%@]; StationClass: [%@]; NumberOfSlots: [%@]", station.stationName, station.stationClass, station.numberOfSlots]
            WithSlotID:szSlotID];
        //for the online slot, just need to replace the result & UUTID for ATSagent
        NSMutableDictionary *dicTraveler    = [NSMutableDictionary dictionaryWithDictionary:[arrTravelers objectAtIndex:iTraveler]];
        [dicTraveler setObject:[m_arrResult objectAtIndex:([szSlotID intValue] - 1)]
                        forKey:eTraveler_TestResultKey];
        [dicTraveler setObject:[m_arrUUTID objectAtIndex:([szSlotID intValue] - 1)]
                        forKey:eTraveler_SerialNumberKey];
        [dicTraveler setObject:[m_arrFailItems objectAtIndex:([szSlotID intValue] - 1)]
                        forKey:eTraveler_CustomTestResultKey];
        [dicTraveler setObject:[m_arrFixtureStatus objectAtIndex:([szSlotID intValue] - 1)]
                        forKey:FixtureState];
        [arrTravelers replaceObjectAtIndex:iTraveler
                                withObject:[NSDictionary dictionaryWithDictionary:dicTraveler]];
        [self writeLog:[NSString stringWithFormat:@"Send to agent ====> The result of the slot [%@] is [%@]. The data sent from ATSagent is [%@].",
                        [m_arrResult objectAtIndex:([szSlotID intValue] - 1)], szSlotID, [arrTravelers objectAtIndex:iTraveler]]
            WithSlotID:szSlotID];
    }
    
    [AppleTestStationAutomation testStation:AutoMationForQTx
                        finishedWithResults:arrTravelers];
    [self writeLog:[NSString stringWithFormat:@"Send to agent ====> Data [%@]", arrTravelers]
        WithSlotID:@"LogWithoutUnit.log"];

    return YES;
     */
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
        
        NSString *szDate = [[NSDate date] descriptionWithCalendarFormat:@"%m/%d %H:%M:%S.%F" timeZone:nil locale:nil];
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
    
    //Get the slotID.
    for (int i=0; i<[m_arrTemplateObject count]; i++)
    {
        Template* obj_Template = [m_arrTemplateObject objectAtIndex:i];
        if ([[note object] isEqualTo:obj_Template.testProgress])
        {
            szSlotID    = [NSString stringWithFormat:@"%d", (i+1)];
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
                                  withObject:bResult ? @"" : [NSString stringWithFormat:@"%@%@", m_Tx_FailItem_Result, szFailInfo]];
    }
    
    //Modify the result and response to ATSagent
    NSMutableDictionary *dicTempTraveler    = [NSMutableDictionary dictionaryWithDictionary:
                                               [m_arrTravelers objectAtIndex:([szSlotID intValue] - 1)]];
    
    [dicTempTraveler setObject:[m_arrResult objectAtIndex:([szSlotID intValue] - 1)]
                        forKey:eTraveler_TestResultKey];
    [dicTempTraveler setObject:[m_arrFixtureStatus objectAtIndex:([szSlotID intValue] - 1)]
                        forKey:FixtureState];
    [dicTempTraveler setObject:szSlotID
                        forKey:eTraveler_TrayIDKey];
    [dicTempTraveler setObject:[m_arrUUTID objectAtIndex:([szSlotID intValue] - 1)]
                        forKey:eTraveler_SerialNumberKey];
    [dicTempTraveler setObject:[m_arrFailItems objectAtIndex:([szSlotID intValue] - 1)]
                        forKey:eTraveler_CustomTestResultKey];
    
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

#pragma mark - Actioins
- (IBAction)HELP_ACTION:(id)sender
{
    NSLog(@"Help menu active.");
    // Insert code here
}

- (IBAction)MENU_TOOL1:(id)sender
{
    NSLog(@"MENU_TOOL1 begin");
    // get test once script file name referred to Tool menu item
    szSenderTitle	= [sender title];
    //[self getTestOnceScriptFileNameWithMenuItemTitle:[sender title]];
    // Password check
    [self runPasswordCheck];
    NSLog(@"MENU_TOOL1 end");
}

- (IBAction)MENU_TOOL2:(id)sender
{
    NSLog(@"MENU_TOOL2 begin");
    // get test once script file name referred to Tool menu item
    szSenderTitle	= [sender title];
    //[self getTestOnceScriptFileNameWithMenuItemTitle:[sender title]];
    // Password check
    [self runPasswordCheck];
    NSLog(@"MENU_TOOL2 end");
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
	[NSBundle loadNibNamed:@"QueryPage" owner:nil];
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
        NSRunAlertPanel(@"警告",@"請確認PType數量是否正確", @"确定", nil, nil);
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
        NSRunAlertPanel(@"警告",@"請確認Query SN是否正確",@"确定", nil, nil);
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
    [NSApp beginSheet:scrWindow
       modalForWindow:window
        modalDelegate:self
       didEndSelector:nil
          contextInfo:nil];
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
	int index = [m_arrTemplateObject indexOfObject:templateObj];
	
	// From index to (index + [m_arrTemplateObje count]), checking all objects
	for (int i  = index; i < index + [m_arrTemplateObject count]; i ++)
	{
		int indexNew = (i+1) % [m_arrTemplateObject count];
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
	int allIndex = [m_arrTemplateObject count];
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
    int iIndex  = [m_arrTemplateObject indexOfObject:templateObj];
    NSString    *strSerialNumber    = [templateObj.serialNumber1 stringValue];
    
    for (int i = 0; i < iIndex; i++)
    {
        Template    *objTemplate    = [m_arrTemplateObject objectAtIndex:i];
        NSString    *strLastSN      = [objTemplate.serialNumber1 stringValue];
        if ([strLastSN isEqualToString:strSerialNumber])
        {
            [templateObj.serialNumber1 setStringValue:@""];
            NSString *szAlert = [NSString stringWithFormat:@"請重新刷入SN, 當前的SN: %@ 已重複刷入了。(You have scanned the same SN with previous slots.Please scan SN again)",strSerialNumber];
            NSRunAlertPanel(@"警告(Warning)", szAlert, @"确认(OK)", nil, nil);
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
            int iAll = [m_arrTemplateObject count];
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
    int iAll = [m_arrTemplateObject count];
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
    int iAll = [m_arrTemplateObject count];
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
@end




