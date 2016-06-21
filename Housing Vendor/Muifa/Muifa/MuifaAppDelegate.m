//
//  MuifaAppDelegate.m
//  Muifa
//
//  Created by Gordon Liu on 9/22/11.
//  Copyright 2011 PEGATRON. All rights reserved.
//

#import "MuifaAppDelegate.h"
#import "FunnyZone/IADevice_Other.h"

NSString * const BNRYoungBrotherNotification = @"YoungBrother";
NSString * const BNRAllPatternReadyOrNotNotification = @"AllPatternReadyOrNot";


// accord chose the rel line or not.
BOOL                g_bRELLinePick = NO;

// color for NFMU
struct_Color  structColors[12] = { {@"0xffebcd",0xff,0xeb,0xcd,0} , {@"0x00ffff",0x00,0xff,0xff,0} , {@"0xcd5c5c",0xcd,0x5c,0x5c,0} ,{@"0x696969",0x69,0x69,0x69,0} , {@"0xffd700",0xff,0xd7,0x00,0} , {@"0x9932cc",0x99,0x32,0xcc,0} , {@"0x0000ff",0x00,0x00,0xff,0} , {@"0x8b4513",0x8b,0x45,0x13,0} , {@"0x2a1a2a",0x2a,0x1a,0x2a,0} , {@"0xff7000",0xff,0x70,0x00,0} , {@"0xff0000",0xff,0x00,0x00,0} ,{@"0x006400",0x00,0x64,0x00,0} };

@implementation MuifaAppDelegate

extern NSString *BNRAllStartButtonPressedNotification;
extern NSString *BNRYoungBrotherStartButtonUnpressedNotification;
extern NSString *BNRStartTestOnePatternNotification;
extern NSString *BNRMonitorProxCalUUT1Notification;


@synthesize window;

- (id)init
{
    self = [super init];

    if (self) 
    {
        m_arrTemplateObject = [[NSMutableArray alloc] init];
        m_dicUnitObject = [[NSMutableDictionary alloc] init];
        m_iUnitNumber = 0;
        //add for loading IP library Leehua 120507
        doLoadingLF = [[DoLoadingLF alloc] init];
        m_dicAntsFlags = [[NSMutableDictionary alloc] init];
        m_arrSerialPortApp = [[NSMutableArray alloc]init];
        m_arrUnitECIDForProxCal = [[NSMutableArray alloc]init];
        m_bFixtureControl = NO;
        m_bDetectUUT1 = NO;
        m_lockProxCal = [[NSLock alloc] init];
        //m_szUnitECIDForProxCal = @"";
    }
    return self;
}

- (void)dealloc
{
    //add for loading IP library Leehua 120507
    [doLoadingLF release];
    [m_dicGHInfo_Muifa release];
    [m_arrTemplateObject release];
    [m_dicUnitObject release];
    [m_dicAntsFlags release];
    [m_arrSerialPortApp release];
    [m_arrUnitECIDForProxCal release];
    [m_lockProxCal release];
    [super dealloc];
}

- (void)awakeFromNib
{
    NSLog(@"awakeFromNib begin");
    
    // set mufia window title
    [window setTitle:@"Muifa"];
    
    // create Muifa_Counter.plist at path: NSHomeDirectory()/Library/Preferences
    NSFileManager *fileManger = [NSFileManager defaultManager];
    NSError *error;

	NSDictionary *dicAttributes=[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:511] forKey:NSFilePosixPermissions];
    if ([fileManger setAttributes:dicAttributes ofItemAtPath:kUserDefaultPath error:&error])
    {
        if (![fileManger fileExistsAtPath:kMuifaCounterPlistPath])
        {
            NSDictionary *dicBase = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1],kUserDefaultCycleTestTime,[NSNumber numberWithInt:0],kUserDefaultFailCount,[NSNumber numberWithInt:0],kUserDefaultPassCount,[NSNumber numberWithInt:0],kUserDefaultHaveRunCount, nil];
            NSDictionary *dicMFMU = [NSDictionary dictionaryWithObjectsAndKeys:dicBase,@"Unit1",dicBase,@"Unit2",dicBase,@"Unit3",dicBase,@"Unit4",dicBase,@"Unit5",dicBase,@"Unit6",dicBase,@"Unit7", nil];
            NSDictionary *dicCounter = [NSDictionary dictionaryWithObjectsAndKeys:dicMFMU,kMuifa_Window_Mode_MFMU,dicBase,kMuifa_Window_Mode_NFMU,dicBase, kMuifa_Window_Mode_SFSU, nil];
            [[NSDictionary dictionaryWithObject:dicCounter forKey:kUserDefaultCounter] writeToFile:kMuifaCounterPlistPath atomically:NO];
        }
    }
    else
    {
        //NSRunAlertPanel(@"警告(Warning)", @"没有路径:%@下的写入权限。(No permission to write Muifa_Counter.plist at path:%@)", @"确认(OK)", nil, nil, kUserDefaultPath,kUserDefaultPath);
        //[NSApp terminate:self];
    }
    BOOL bBrotherTest = [[[[kFZ_UserDefaults objectForKey:kUserDefaultModeSetting] objectForKey:@"BROTHER"] objectForKey:@"BrotherTest"] boolValue];
    if (bBrotherTest)
    {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(runPasswordCheckBrother:) name:@"BNRUsePasswordWindowNotification" object:nil];
        
        m_bFxitureFile = NO;
        
    }
    // set default mode
    NSString *szDefaultMode = [[kFZ_UserDefaults objectForKey:kUserDefaultModeSetting] objectForKey:kUserDefaultCurrentMode];
    if (szDefaultMode == nil || [szDefaultMode isEqualToString:@""])
    {
        m_szMode = kMuifa_Window_Mode_SFSU;
    }
    else
    {
        m_szMode = szDefaultMode;
    }
    if ([m_szMode isEqualToString:kMuifa_Window_Mode_SFSU])
    {
        [segController setSelectedSegment:0];
    }
    else if([m_szMode isEqualToString:kMuifa_Window_Mode_NFMU])
    {
        [segController setSelectedSegment:1];
    }
    else if([m_szMode isEqualToString:kMuifa_Window_Mode_MFMU])
    {
        [segController setSelectedSegment:2];
    }
    
    // Disable change mode
    [segController setEnabled:NO];
    
    // set mufia window frame
    NSRect rectForWindow = NSMakeRect(kMuifa_Window_Point_X, kMuifa_Window_Point_Y, kMuifa_Window_Size_Width, kMuifa_Window_Size_Height);
    [window setFrame:rectForWindow display:YES];
    
    NSNumber *numLoadBundle = [kFZ_UserDefaults valueForKey:@"LOAD_BUNDLE"];	
    TestProgress *objTestProgress = [[TestProgress alloc] init];
    if (![fileManger fileExistsAtPath:@"/Library/Preferences/Muifa.plist"]) {
        NSRunAlertPanel(@"警告(Warning)", @"找不到设定档案(/Library/Preferences/Muifa.plist),请放回设定档或重新安装.", @"确认(OK)", nil, nil, kUserDefaultPath,kUserDefaultPath);
        [NSApp terminate:self];
    }
    [objTestProgress.m_dicMemoryValues setObject:[NSDictionary dictionaryWithContentsOfFile:kMuifaPlistPath] forKey:kPD_Muifa_Plist];
	if([numLoadBundle boolValue])
	{
        [objTestProgress LOAD_BUNDLE];
	}
    
    // do check sum
    // remark for Proto 0
    //if (![objTestProgress do_checkSum]) 
    //{
    //    [NSApp terminate:self];
    //}
       
    [objTestProgress release];
    
    // load views
    [self startLoadviewsAndGetGroudHogInfo];
    
    NSDictionary *dicAntsTest = [[kFZ_UserDefaults objectForKey:kUserDefaultModeSetting] objectForKey:@"ANTS"];
    BOOL bAntsTest = NO;
    if (dicAntsTest)
    {
        bAntsTest = [[dicAntsTest objectForKey:@"AntsTest"] boolValue];
    }
    if (bAntsTest)
    {
        // add one main observer to control all the template
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(monitorAllTemplate:) name:BNRStartTestOnePatternNotification object:nil];
        
        // all slot start test together
        [nc addObserver:self selector:@selector(allStartButtonPressed:) name:BNRAllStartButtonPressedNotification object:nil];
    }
    
    for (int i= 0; i < [m_arrTemplateObject count]; i++)
    {
        // transfer template object to Template class
        [[m_arrTemplateObject objectAtIndex:i] transferTemplateObject:[NSArray arrayWithArray: m_arrTemplateObject]];
        if (i==0) 
        {
            Template *template = [m_arrTemplateObject objectAtIndex:0];
            [window makeFirstResponder:template.tfSN1];
        }
    }
    
    // open thread to monitor whether unit has pluged in slot1
    BOOL bIS_1_to_N  =   [[[kFZ_UserDefaults objectForKey:kUserDefaultModeSetting] objectForKey:@"IS_1_to_N"] boolValue];
    if (bIS_1_to_N && ([m_arrTemplateObject count] >= 1))
    {
        // add one main observer to receive all templates' notification.
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(monitorProxCalUUT1:) name:BNRMonitorProxCalUUT1Notification object:nil];
        
        [NSThread detachNewThreadSelector:@selector(detectProxCalUUT1) toTarget:self withObject:nil];
    }
    
    
    [window center];
	
    NSLog(@"awakeFromNib end");
    
}

- (void)startLoadviewsAndGetGroudHogInfo
{
    NSLog(@"startLoadviewsAndGetGroudHogInfo begin");
    TestProgress *objTestProgress = [[TestProgress alloc] init];
    NSMutableArray *arrPorts = [[NSMutableArray alloc] init];
    [objTestProgress.m_dicMemoryValues setObject:[NSDictionary dictionaryWithContentsOfFile:kMuifaPlistPath] forKey:kPD_Muifa_Plist];
    
    // get groundHog Info
    m_dicGHInfo_Muifa = [[objTestProgress getStationInfo]retain];
    
    // get assgin port array
    if ([objTestProgress assignPorts:arrPorts]) 
    {
        for (int iUnitCount = 0; iUnitCount < [arrPorts count]; iUnitCount ++)
        {
            // if unit number is over the max Unit number 12, break and not load view any more
            if (iUnitCount >= kMuifa_MaxUnitNumber)
            {
                break;
            }
            NSDictionary *dicUnit = [arrPorts objectAtIndex:iUnitCount];
            
            // load one template view for one unit
            [self addViewsForMainMenuXib:dicUnit WithUnitColor:structColors[iUnitCount]];
        }
    }
    else
    {
        NSLog(@"startLoadviewsAndGetGroudHogInfo: fail to get arrgin port");
    }
    
    [arrPorts release];
    [objTestProgress release];
    
    NSLog(@"startLoadviewsAndGetGroudHogInfo end");
}


- (void)addViewsForMainMenuXib:(NSDictionary *)dicUnit WithUnitColor:(struct_Color)struct_ColorForUnit
{
    NSLog(@"addViewsForMainMenuXib begin");
    NSString *szUnitNumber = [[dicUnit allKeys] objectAtIndex:0];
    NSMutableDictionary *dicUnitPort = [dicUnit objectForKey:szUnitNumber];
    unsigned char iColor[3];
    NSString *szColor = nil;
    iColor[0] = struct_ColorForUnit.ucRed;
    iColor[1] = struct_ColorForUnit.ucGreen;
    iColor[2] = struct_ColorForUnit.ucBlue;
    szColor = struct_ColorForUnit.strColor;
    NSColor *colorForNFMUUnit= [NSColor colorWithCalibratedRed:(float)iColor[0]/255 green:(float)iColor[1]/255 blue:(float)iColor[2]/255 alpha:(float)1];
    NSDictionary *dicPara = [NSDictionary dictionaryWithObjectsAndKeys:dicUnitPort, kTransferKey_Ports ,
                            [NSDictionary dictionaryWithObjectsAndKeys:colorForNFMUUnit, @"NSColor", szColor, @"StringColor", nil] ,kTransferKey_UnitColor,
                            [NSDictionary dictionaryWithDictionary:m_dicGHInfo_Muifa], @"GHInfo",
                             nil];
    
    BOOL bAutoDetectRun = [[[kFZ_UserDefaults objectForKey:kUserDefaultModeSetting] objectForKey:kUserDefaultAutoDetectAndRun] boolValue];
    BOOL bEnableAbort = [[[kFZ_UserDefaults objectForKey:kUserDefaultModeSetting] objectForKey:kUserDefualtEnableAbort] boolValue];
    
    // alloc a template object
    Template *templateOne = [[Template alloc] initWithParametric:dicPara];
    [m_arrTemplateObject addObject:templateOne];
    NSTabViewItem *tabViewItem = [[NSTabViewItem alloc] init];
    NSArray *arrSNNumber = [[kFZ_UserDefaults objectForKey:kUserDefaultSN_Manager] objectForKey:kUserDefaultSN_Arrangement];
    int iSNNumber = [arrSNNumber count];
    NSRect rectForSNLabels = [templateOne.viewSNLabels frame];
    rectForSNLabels = NSMakeRect(rectForSNLabels.origin.x, rectForSNLabels.origin.y, rectForSNLabels.size.width, kMuifa_SN_View_Size_BaseHeight*iSNNumber);
    NSView *viewForMFMU = [[NSView alloc] initWithFrame:NSMakeRect(15, 0, kMuifa_Left_View_Size_Width, kMuifa_Left_View_Size_Height)];
    
    m_szIdentifier = szUnitNumber;
    m_iUnitNumber++;
    m_iBoxHeight= m_iUnitNumber*kMuifa_IndicatorView_Size_Height;

    
    
    // add view for mode SFSU
    if ([m_szMode isEqualToString:kMuifa_Window_Mode_SFSU]) 
    {
        if (1 == m_iUnitNumber)
        {
            viewLeft = [[NSView alloc] initWithFrame:NSMakeRect(15, 10, kMuifa_Left_View_Size_Width, kMuifa_Left_View_Size_Height - 10)];
            viewRight = [[NSView alloc] initWithFrame:NSMakeRect(kMuifa_Left_View_Size_Width + 18, 10, kMuifa_Right_View_Size_Width, kMuifa_Right_View_Size_Height - 10)];
            [[window contentView] addSubview:viewLeft];
            [[window contentView] addSubview: viewRight];
            
            rectViewLeft = [viewLeft frame];
            rectViewRight = [viewRight frame];
        }
        
        //[templateOne.viewMain setFrame:NSMakeRect(-5, 0, rectViewRight.size.width - 20, rectViewRight.size.height - 15)];
        //[viewRight addSubview:templateOne.viewMain];
        
        [templateOne.tfShowResult setFrame:NSMakeRect(-5, 0, rectViewRight.size.width - 30, rectViewRight.size.height - 25)];
        [viewRight addSubview:templateOne.tfShowResult];
        
        [templateOne.viewSNLabels setFrame:NSMakeRect(0, rectViewLeft.size.height - rectForSNLabels.size.height - kMuifa_BaseBlankHeight, rectViewLeft.size.width - 5, rectForSNLabels.size.height)];
        [templateOne.viewIndicator setFrame:NSMakeRect(0, rectViewLeft.size.height - m_iBoxHeight - rectForSNLabels.size.height -kMuifa_BaseBlankHeight - 20, rectViewLeft.size.width - 8, kMuifa_IndicatorView_Size_Height)];
        [templateOne.viewInfo setFrame:NSMakeRect(0, rectViewLeft.size.height - m_iBoxHeight - rectForSNLabels.size.height - kMuifa_BaseBlankHeight - 100, rectViewLeft.size.width - 5, 40)];
        
        if ([[[NSDictionary dictionaryWithContentsOfFile:kMuifaPlistPath] objectForKey:@"Show_Voltage_UI"] boolValue])
        {
            [templateOne.viewVol setFrame:NSMakeRect(0, [viewLeft frame].size.height - kMuifa_IndicatorView_Size_Height - [templateOne.viewSNLabels frame].size.height - kMuifa_BaseBlankHeight - 300, [viewLeft frame].size.width - 5, 100)];
            [viewLeft addSubview:templateOne.viewVol];
        }
        [viewLeft addSubview:templateOne.viewSNLabels];
        [viewLeft addSubview:templateOne.viewIndicator];
        [viewLeft addSubview:templateOne.viewInfo];
        if (!bAutoDetectRun)
        {
            [templateOne.viewButtons setFrame:NSMakeRect(0, rectViewLeft.size.height - m_iBoxHeight - rectForSNLabels.size.height - kMuifa_BaseBlankHeight - 160, rectViewLeft.size.width - 5, 40)];
            [viewLeft addSubview:templateOne.viewButtons];
        }
    }
    else if([m_szMode isEqualToString:kMuifa_Window_Mode_NFMU])
    {
        if (1 == m_iUnitNumber)
        {
            viewLeft = [[NSView alloc] initWithFrame:NSMakeRect(15, 0, kMuifa_Left_View_Size_Width, kMuifa_Left_View_Size_Height)];
            viewRight = [[NSView alloc] initWithFrame:NSMakeRect(kMuifa_Left_View_Size_Width + 18, 0, kMuifa_Right_View_Size_Width, kMuifa_Right_View_Size_Height + 15)];
            
            [[window contentView] addSubview:viewLeft];
            [[window contentView] addSubview: viewRight];
            
            rectViewLeft = [viewLeft frame];
            rectViewRight = [viewRight frame];
            
            if (tbForUnit)
            {
                [tbForUnit release];
            }
            tbForUnit = [[NSTabView alloc] initWithFrame:NSMakeRect(0, 0, rectViewRight.size.width - 20, rectViewRight.size.height - 35)];
            [tbForUnit setTabViewType:NSLeftTabsBezelBorder];
            [tbForUnit setFont:[NSFont fontWithName:@"Arial" size:10]];
            [viewRight addSubview:tbForUnit];
            
            [templateOne.viewInfo setFrame:NSMakeRect(0, rectViewLeft.size.height - 35, rectViewLeft.size.width - 5, 35)];
            [viewLeft addSubview:templateOne.viewInfo];

        }
        [tbForUnit addTabViewItem:tabViewItem];
        [tabViewItem setLabel:m_szIdentifier];
        [[tabViewItem view] setAutoresizesSubviews:NO];
        [templateOne.lbColorLabel setBackgroundColor:colorForNFMUUnit];
        [templateOne.viewColorLabel setFrame:NSMakeRect(-5, 8, rectViewRight.size.width - 55, rectViewRight.size.height - 58)];
        [[tabViewItem view] addSubview:templateOne.viewColorLabel];
        [templateOne.viewMain setFrame:NSMakeRect(-4, 0, rectViewRight.size.width - 56, rectViewRight.size.height - 48)];
        [[tabViewItem view] addSubview:templateOne.viewMain];
        [templateOne.viewIndicator setFrame:NSMakeRect(0, rectViewLeft.size.height - m_iBoxHeight - 35, rectViewLeft.size.width - 5, kMuifa_IndicatorView_Size_Height)];
        [viewLeft addSubview:templateOne.viewIndicator];

    }
    else if([m_szMode isEqualToString:kMuifa_Window_Mode_MFMU])
    {
        // add a flag for brother test
        BOOL bBrotherTest = [[[[kFZ_UserDefaults objectForKey:kUserDefaultModeSetting] objectForKey:@"BROTHER"] objectForKey:@"BrotherTest"] boolValue];
        int iAdjstHeight =  12 -3*iSNNumber;
        if (1 == m_iUnitNumber)
        {
            if (bBrotherTest)
            {
                //[NSThread detachNewThreadSelector:@selector(controlSettingForBrotherTest) toTarget:templateOne withObject:nil];
                NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
                [nc addObserver:self selector:@selector(allStartButtonPressed:) name:BNRAllStartButtonPressedNotification object:nil];
                [nc addObserver:self selector:@selector(youngBrotherStartButtonUnpressed:) name:BNRYoungBrotherStartButtonUnpressedNotification object:nil];
                
            }
            splitView = [[NSSplitView alloc] initWithFrame:NSMakeRect(7, 10, kMuifa_Window_Size_Width - 12, kMuifa_Window_Size_Height - 72)];
            [splitView setDividerStyle:NSSplitViewDividerStylePaneSplitter];
            [splitView setDelegate:self];
            [splitView setVertical:YES];
            [[window contentView] addSubview:splitView];
        }
        NSRect rectForMFMU = [viewForMFMU frame];
        [templateOne.viewCheckBox setFrame:NSMakeRect(2, rectForMFMU.size.height - 25, rectForMFMU.size.width - 19, 25)];
        [templateOne.viewSNLabels setFrame:NSMakeRect(2, rectForMFMU.size.height - rectForSNLabels.size.height - kMuifa_BaseBlankHeight -15 - iAdjstHeight, rectForMFMU.size.width - 4, rectForSNLabels.size.height)];
        [templateOne.viewIndicator setFrame:NSMakeRect(2, rectForMFMU.size.height - rectForSNLabels.size.height - kMuifa_BaseBlankHeight - kMuifa_IndicatorView_Size_Height - 25 - 2*iAdjstHeight, rectForMFMU.size.width - 4, kMuifa_IndicatorView_Size_Height + 5)];
        [templateOne.viewInfo setFrame:NSMakeRect(2, rectForMFMU.size.height - rectForSNLabels.size.height - kMuifa_BaseBlankHeight - kMuifa_IndicatorView_Size_Height - 70 - 3*iAdjstHeight, rectForMFMU.size.width - 4, 40)];
        [viewForMFMU addSubview:templateOne.viewCheckBox];
        [viewForMFMU addSubview:templateOne.viewSNLabels];
        [viewForMFMU addSubview:templateOne.viewIndicator];
        [viewForMFMU addSubview:templateOne.viewInfo];
        if (bBrotherTest) 
        {
            [templateOne.viewChooseCable setFrame:NSMakeRect(110, rectForMFMU.size.height - 25, rectForMFMU.size.width - 19, 25)];
            [viewForMFMU addSubview:templateOne.viewChooseCable];
        }
        //add for grape-1 4-up
        if (bBrotherTest)
        {
            [m_arrSerialPortApp addObject:szUnitNumber];
            [templateOne.m_strSerialPort setString:szUnitNumber];
            [templateOne.m_arrSerialPort setArray:m_arrSerialPortApp];
            
            
            NSMutableString *szFixtureResponse = [[NSMutableString alloc]init];
            NSString  *szFixturePort = [[dicUnitPort objectForKey:@"FIXTURE"] objectAtIndex:0];
            TestProgress *objTestProgress = [[TestProgress alloc] init];
            
            if ([m_arrSerialPortApp count] == 1) 
            {
                NSFileManager *fileManger = [NSFileManager defaultManager];
                if ([fileManger fileExistsAtPath:kFxitureControlPlistPath])
                {
                    NSMutableDictionary *dicFixtureControl = [[NSMutableDictionary alloc] initWithContentsOfFile:kFxitureControlPlistPath];
                    m_strDefaultCable = [NSString stringWithString:[dicFixtureControl objectForKey:@"FIXTURENUMBER"]];
                    if (![m_strDefaultCable ContainString:@"Unit"]) 
                    {
                        NSDictionary *dicFixture = [NSDictionary dictionaryWithObjectsAndKeys:szUnitNumber,@"FIXTURENUMBER",nil];
                        [dicFixture writeToFile:kFxitureControlPlistPath atomically:NO];
                        m_strDefaultCable = [NSString stringWithString:szUnitNumber];
                    }
                    [dicFixtureControl release];
                    
                }
                else
                {
                    NSDictionary *dicFixture = [NSDictionary dictionaryWithObjectsAndKeys:szUnitNumber,@"FIXTURENUMBER",nil];
                    [dicFixture writeToFile:kFxitureControlPlistPath atomically:NO];
                    m_strDefaultCable = [NSString stringWithString:szUnitNumber];
                }
            }
            
            if (![m_strDefaultCable isEqualToString:@"NONE"]) 
            {
                if ([m_strDefaultCable isEqualToString:szUnitNumber]) 
                {
                    if ([objTestProgress checkUnitConnectWellWithFixturePort:szFixturePort UARTCommand:@"clr channels" UartResponse:szFixtureResponse CheckTime:1.0]) 
                    {
                        if ([szFixtureResponse ContainString:@"OK"])
                        {
                            if ([objTestProgress checkUnitConnectWellWithFixturePort:szFixturePort UARTCommand:@"set channels" UartResponse:szFixtureResponse CheckTime:1.0]) 
                            {
                                if ([szFixtureResponse ContainString:@"OK"]) 
                                {
                                    [templateOne setDefaultCable:m_strDefaultCable];
                                }
                                else
                                {
                                    m_bFixtureControl = YES ;
                                }
                            }
                            else
                            {
                                m_bFixtureControl = YES ;
                            }
                        }
                        else
                        {
                            m_bFixtureControl = YES ;
                        }
                    }
                    else
                    {
                        m_bFixtureControl = YES ;
                    }
                }
                else
                {
                    if ([objTestProgress checkUnitConnectWellWithFixturePort:szFixturePort UARTCommand:@"clr channels" UartResponse:szFixtureResponse CheckTime:1.0]) 
                    {
                        if (![szFixtureResponse ContainString:@"OK"]) 
                        {
                            m_bFixtureControl = YES ;
                        }
                    }
                    else
                    {
                        m_bFixtureControl = YES ;
                    }
                }
            }
            
            if (m_bFixtureControl) 
            {
                NSRunAlertPanel(@"警告(Warning)", @"請在UI開啓來之後選擇治具控制线!(Please set Fixture control cable on UI!)", @"YES", nil, nil);
                m_strDefaultCable = [NSString stringWithString:@"NONE"];
                NSDictionary *dicFixture = [NSDictionary dictionaryWithObjectsAndKeys:m_strDefaultCable,@"FIXTURENUMBER",nil];
                [dicFixture writeToFile:kFxitureControlPlistPath atomically:NO];
                m_bFixtureControl = NO;
            }
            
            [objTestProgress release];
            [szFixtureResponse release];
        }
        
        if (!bAutoDetectRun)
        {
            // For prox cal sepcial auto detect and run, so didn't add button view on UI.
            BOOL bIS_1_to_N  =   [[[kFZ_UserDefaults objectForKey:kUserDefaultModeSetting] objectForKey:@"IS_1_to_N"] boolValue];
            if (bIS_1_to_N)
            {
                [templateOne .viewMain setFrame:NSMakeRect(2, 0, rectForMFMU.size.width - 4, rectForMFMU.size.height - rectForSNLabels.size.height - kMuifa_BaseBlankHeight - kMuifa_IndicatorView_Size_Height - 80 - 4*iAdjstHeight)];
                [viewForMFMU addSubview:templateOne.viewMain];
            }
            else
            {
                [templateOne.viewButtons setFrame:NSMakeRect(2, rectForMFMU.size.height - rectForSNLabels.size.height - kMuifa_BaseBlankHeight - kMuifa_IndicatorView_Size_Height - 120 - 4*iAdjstHeight, rectForMFMU.size.width - 4, 40)];
                [templateOne .viewMain setFrame:NSMakeRect(2, 0, rectForMFMU.size.width - 4, rectForMFMU.size.height - rectForSNLabels.size.height - kMuifa_BaseBlankHeight - kMuifa_IndicatorView_Size_Height - 120 - 5*iAdjstHeight)];
                [viewForMFMU addSubview:templateOne.viewButtons];
                [viewForMFMU addSubview:templateOne.viewMain]; 

            }

        }
        else
        {
            [templateOne .viewMain setFrame:NSMakeRect(2, 0, rectForMFMU.size.width - 4, rectForMFMU.size.height - rectForSNLabels.size.height - kMuifa_BaseBlankHeight - kMuifa_IndicatorView_Size_Height - 80 - 4*iAdjstHeight)];
            [viewForMFMU addSubview:templateOne.viewMain];

        }
        
        //add for grape-1 and interposer , hidden the start button.
        if (bBrotherTest)
        {
            [templateOne.btnStart setBoundsSize:NSMakeSize(0, 0)];
        }
        
        // enale FAIL button for Ants Test
        BOOL bAntsTest = [[[[kFZ_UserDefaults objectForKey:kUserDefaultModeSetting] objectForKey:@"ANTS"] objectForKey:@"AntsTest"] boolValue];
        if (bAntsTest)
        {
            [templateOne.btnAntsFAIL setEnabled:NO];
            [templateOne.btnAntsFAIL setHidden:YES];
        }
         
        [splitView addSubview:viewForMFMU];
    }
    
    // if it is auto detect and run test, create a thread to detect Unit whether plug in
    if (bAutoDetectRun)
    {
        [NSThread detachNewThreadSelector:@selector(MonitorSerialPortPlugIn) toTarget:templateOne withObject:nil];
    }
    
    // set sn&count&script labels
    [templateOne setDefaultValueAndGetScriptInfo:m_szIdentifier CurrentMode:m_szMode];
    
    // set window title
    m_strUIVersion = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
	NSString	*szStationID = [m_dicGHInfo_Muifa objectForKey:kPD_GHInfo_STATION_ID];
	NSString	*szStationNumber = [m_dicGHInfo_Muifa objectForKey:kPD_GHInfo_STATION_NUMBER];
	NSString	*szAllInfo = [NSString stringWithFormat:@"%@[%@]\t Version:%@",szStationID,szStationNumber, m_strUIVersion];
	[window setTitle:szAllInfo];
    
    [m_dicUnitObject setObject:[NSDictionary dictionaryWithObjectsAndKeys:tabViewItem, @"TabView", templateOne, @"Template",viewForMFMU, @"ViewForMFMU", nil] forKey:szUnitNumber];
    [viewForMFMU release];
    [tabViewItem release];
    [templateOne release];
    
    if (bEnableAbort) 
    {
        [templateOne.btnAbort setEnabled:NO];
    }
    
    NSLog(@"addViewsForMainMenuXib end");
}

- (void)linkToTabViewItem:(NSButton *)sender
{   
    NSTabViewItem *tabViewItemObj = [[m_dicUnitObject objectForKey:[sender title]] objectForKey:@"TabView"];
    NSTabView *tabView = [tabViewItemObj tabView];
    [tabView selectTabViewItem:tabViewItemObj];
}

- (IBAction)MENU_TOOL1:(id)sender
{   
    NSLog(@"MENU_TOOL1 begin");
    // get test once script file name referred to Tool menu item
    szSenderTitle   = [sender title];
//    [self getTestOnceScriptFileNameWithMenuItemTitle:[sender title]];
    // Password check
//    [self runPasswordCheck];
    [self checkPassword:nil];
    
    BOOL bBrotherTest = [[[[kFZ_UserDefaults objectForKey:kUserDefaultModeSetting] objectForKey:@"BROTHER"] objectForKey:@"BrotherTest"] boolValue];
    if (!bBrotherTest)
    {
        // change script name reffered to menu item
        [self getTestOnceScriptFileNameWithMenuItemTitle:szSenderTitle];
    }
    else
    {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        NSString *szChoosePort = [m_dicUnitObject objectForKey:@"CHOOSE_UNIT"];
        NSDictionary *dicTemp = [NSDictionary dictionaryWithObjectsAndKeys: szChoosePort,@"UUT", nil];
        [nc postNotificationName:@"BNRControlCableNotification" object:self userInfo:dicTemp];
        
    }

    
    NSLog(@"MENU_TOOL1 end");
}

- (IBAction)MENU_TOOL2:(id)sender
{
    NSLog(@"MENU_TOOL2 begin");
    // get test once script file name referred to Tool menu item
    szSenderTitle   = [sender title];
    //[self getTestOnceScriptFileNameWithMenuItemTitle:[sender title]];
    // Password check
    [self runPasswordCheck];
    NSLog(@"MENU_TOOL2 end");
}

- (IBAction)MENU_TOOL3:(id)sender
{
    NSLog(@"MENU_TOOL3 begin");
    // get test once script file name referred to Tool menu item
    szSenderTitle   = [sender title];
    //[self getTestOnceScriptFileNameWithMenuItemTitle:[sender title]];
    // Password check
    [self runPasswordCheck];
    NSLog(@"MENU_TOOL3 end");
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
    NSDateFormatter     *dateformat = [[NSDateFormatter alloc]init];
    [dateformat setDateStyle:NSDateFormatterMediumStyle];
    [dateformat setTimeStyle:NSDateFormatterShortStyle];
    [dateformat setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    NSString    *szPasswordCheck = [NSString stringWithFormat:@"%@",[dateformat stringFromDate:[NSDate date]]];
    [dateformat release];
    // get month and day 
    szPasswordCheck = [szPasswordCheck SubFrom:@"-" include:NO];
    szPasswordCheck = [szPasswordCheck SubTo:@" " include:NO];
    szPasswordCheck = [szPasswordCheck stringByReplacingOccurrencesOfString:@"-" withString:@""];
    szPasswordCheck = [NSString stringWithFormat:@"ATS%@",szPasswordCheck];
    NSString    *szPasswordEnter = [NSString stringWithFormat:@"%@",[txtPasswordCheck stringValue]];
    if([szPasswordEnter isEqualToString:szPasswordCheck])
    {
        [txtPasswordCheck setStringValue:@""];
        [scrWindow setBackgroundColor:[NSColor greenColor]];
        [scrWindow orderOut:nil];
        [NSApp endSheet:scrWindow];
        //add for 4-up grape-1
        BOOL bBrotherTest = [[[[kFZ_UserDefaults objectForKey:kUserDefaultModeSetting] objectForKey:@"BROTHER"] objectForKey:@"BrotherTest"] boolValue];
        if (!bBrotherTest)
        {
            // change script name reffered to menu item
            [self getTestOnceScriptFileNameWithMenuItemTitle:szSenderTitle];
        }
        else
        {
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            NSString *szChoosePort = [m_dicUnitObject objectForKey:@"CHOOSE_UNIT"];
            NSDictionary *dicTemp = [NSDictionary dictionaryWithObjectsAndKeys: szChoosePort,@"UUT", nil];
            [nc postNotificationName:@"BNRControlCableNotification" object:self userInfo:dicTemp];
            
        }

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

- (void)getTestOnceScriptFileNameWithMenuItemTitle:(NSString*)szTitle
{
    NSLog(@"getTestOnceScriptFileNameWithMenuItemTitle begin");
    // if there is no template object, it must be station set up problem
    if (nil != m_arrTemplateObject && [m_arrTemplateObject count] > 0)
    {
        NSDictionary *dicTestOnceScript = [[kFZ_UserDefaults objectForKey:kUserDefaultScriptInfo] objectForKey:kUserDefaultTestOnceScriptName];
        // if the test once script file name is nil or empty, pop up a alert panel
        if ((nil != [dicTestOnceScript objectForKey:szTitle]) && [[dicTestOnceScript objectForKey:szTitle] isNotEqualTo:@""]) 
        {
            
            NSString *plistFileName = [[dicTestOnceScript objectForKey:szTitle] objectForKey:@"PlistFile"];
            BOOL bTestForOnce = [[[dicTestOnceScript objectForKey:szTitle] objectForKey:@"IsTestOnce"]boolValue];
            NSString *szAlertInfo = [[dicTestOnceScript objectForKey:szTitle] objectForKey:@"Message"];
            
            for (Template *template in m_arrTemplateObject) 
            {
                [template changeScriptFile:plistFileName InformativeText:szAlertInfo TestOnce:bTestForOnce];
            }    
            
            //[[m_arrTemplateObject objectAtIndex:0] changeScriptFile:plistFileName InformativeText:szAlertInfo TestOnce:bTestForOnce];
            //=============modify for Clear CB===============
            //change show sn for UI
          /*  NSDictionary *dicOnceScript = [dicTestOnceScript objectForKey:@"FATP_CB_PLIST"];
            NSString *onceScriptName = [dicOnceScript objectForKey:KUserDefaultTestPlistFile];
            
            if ([[onceScriptName uppercaseString] isEqualToString:@"FATP_CB ERASE.PLIST"]) 
            {
                [[m_arrTemplateObject objectAtIndex:0] changeSNManage];
            }*/
            //=============modify for Clear CB===============
        }
        else
        {
            NSRunAlertPanel(@"警告(Warning)", @"请设置正确的一次性剧本档。(You need to set TestOnceScriptFile correctly!)", @"确认(OK)", nil, nil);
        }
    }
    else
    {
        NSRunAlertPanel(@"警告(Warning)", @"请先把测试站架好。(You need to set up station correctly!)", @"确认(OK)", nil, nil);
    }
    NSLog(@"getTestOnceScriptFileNameWithMenuItemTitle end");

}

/*
 * Controls the minimum size of the left subview (or top subview in a horizonal NSSplitView)
 */
- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex;
{
    return proposedMinimumPosition + 15;
}

/*
 * Controls the minimum size of the right subview (or lower subview in a horizonal NSSplitView)
 */
- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex;
{
    return proposedMaximumPosition - 15;
}

- (void)checkFocus
{
	NSDictionary * diclaunchedApplications = [[NSWorkspace sharedWorkspace] activeApplication];
	NSString * stringApplication = [diclaunchedApplications objectForKey:@"NSApplicationName"];
	NSString * bundle = [[NSBundle mainBundle] bundleIdentifier];
	if ([stringApplication isNotEqualTo:bundle])
	{
		[self.window center];
		[window setLevel:kCGStatusWindowLevel];
		[NSApp activateIgnoringOtherApps:YES];
		
		//the point mouse will click
		CGPoint pointSend;
		
		NSScreen * screen = [NSScreen mainScreen];
		NSRect rectScreen = [screen frame];
		CGRect rect = *(CGRect*)&rectScreen;
		pointSend = CGPointMake((rect.size.width - kMuifa_Window_Size_Width)/2 + 10, (rect.size.height - kMuifa_Window_Size_Height)/2 + 30);
		
		//mouse down
		CGEventRef theEvent = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseDown, pointSend, kCGMouseButtonLeft);
		CGEventPost(kCGHIDEventTap, theEvent);
		CFRelease(theEvent);
		//mouse up
		theEvent = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseUp, pointSend, kCGMouseButtonLeft);
		CGEventPost(kCGHIDEventTap, theEvent);
		CFRelease(theEvent);
	}
}


// when you click Tool menu item, this function will call automatically
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	NSString	*szLineName = [m_dicGHInfo_Muifa objectForKey:kPD_GHInfo_STATION_ID];
	NSDictionary *dicTestOnceScript = [[kFZ_UserDefaults objectForKey:kUserDefaultScriptInfo] objectForKey:kUserDefaultTestOnceScriptName];
    // if there is no template object, just return no
    if (nil != m_arrTemplateObject && [m_arrTemplateObject count] > 0)
    {
        Template *objTMP = [m_arrTemplateObject objectAtIndex:0];
        // if the the UI is testing unit, just return no
            // enable or disable the menu item referred to the setting in Muifa.plist
        NSArray *arrMenus = [kFZ_UserDefaults objectForKey:kUserDefaultToolMenuItemSetting];
        if ([arrMenus count] > [menuItem tag])
        {
            [menuItem setTitle:[arrMenus objectAtIndex:[menuItem tag]]];
			if (objTMP.m_bStopTest) 
            {
//                NSArray *arrEnableLineName = [[dicTestOnceScript objectForKey:[arrMenus objectAtIndex:[menuItem tag]]] objectForKey:@"EnableLineName"];
//                BOOL bContain = NO;
//                if (arrEnableLineName)
//                {
//                    NSInteger iTotal = [arrEnableLineName count];
//                    for (NSInteger iCount = 0; iCount < iTotal; iCount++)
//                    {
//                        if ([szLineName ContainString:[arrEnableLineName objectAtIndex:iCount]])
//                        {
//                            bContain = YES;
//                            break;
//                        }
//                    }
//                }
//                if (!bContain) 
//                {
//                    [menuItem setEnabled:NO];
//                    return NO;
//                }
                return YES;
            }
        }
        else
        {
            [menuItem setHidden:YES];
        }
    }
    return NO;
}

// Add by betty on 2012.05.09 for auto running some plist in some station for init
- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    BOOL bAutoRunInit = [[[kFZ_UserDefaults objectForKey:kUserDefaultModeSetting] objectForKey:kUserDefaultAutoInitFixture] boolValue];
    if (bAutoRunInit)
    {
        id sender = [[NSButton alloc]init];
        NSArray *arrMenus = [kFZ_UserDefaults objectForKey:kUserDefaultToolMenuItemSetting];
        if (0 == [arrMenus count]) 
        {
            NSRunAlertPanel(@"警告(Warning)", @"设定档中没有正确的设定一次性剧本档。(There is no TestOnceScriptFile in Muifa.plist, You need to set TestOnceScriptFile correctly!)", @"确定(OK)", nil, nil);
        }
        [sender setTitle:[arrMenus objectAtIndex:0]];
        //[self MENU_TOOL1:sender];
        [self getTestOnceScriptFileNameWithMenuItemTitle:[sender title]];
        [sender release];
    }
   
}

- (void)allStartButtonPressed:(NSNotification *)aNote
{
    //
    int iAll = [m_arrTemplateObject count];
    BOOL bAll = YES;
    for (int i = 0; i < iAll; i++)
    {
        BOOL bOne = NO;
        Template *objTemplate = [m_arrTemplateObject objectAtIndex:i];
        if ((![objTemplate.btnStart isEnabled]) || ([objTemplate.btnCheckBox state] == NSOffState))
        {
            bOne = YES;
        }
        else
        {
            bOne = NO;
        }
        bAll &= bOne;
    }
    if (bAll)
    {
        [NSThread detachNewThreadSelector:@selector(controlBeforeBrotherTest) toTarget:[m_arrTemplateObject objectAtIndex:0] withObject:nil];
		timerCheckFocus = [NSTimer timerWithTimeInterval:0.01 target:self selector:@selector(checkFocus) userInfo:nil repeats:YES];
		timerDetectAllFinished = [NSTimer timerWithTimeInterval:0.01 target:self selector:@selector(DetectAllTemplateFinishTest) userInfo:nil repeats:YES];
		[[NSRunLoop mainRunLoop] addTimer:timerCheckFocus forMode:NSDefaultRunLoopMode];
		[[NSRunLoop mainRunLoop] addTimer:timerDetectAllFinished forMode:NSDefaultRunLoopMode];
		[timerCheckFocus fire];
		[timerDetectAllFinished fire];
    }
}

- (void)DetectAllTemplateFinishTest
{
	int iAll = [m_arrTemplateObject count];
	BOOL bAllTestFinished = YES;
    for (int i = 0; i < iAll; i++)
    {
        BOOL bOne = NO;
        Template *objTemplate = [m_arrTemplateObject objectAtIndex:i];
        if (([objTemplate.btnStart isEnabled]) || ([objTemplate.btnCheckBox state] == NSOffState))
        {
            bOne = YES;
        }
        else
        {
            bOne = NO;
        }
        bAllTestFinished &= bOne;
    }
	if (bAllTestFinished)
	{
        for (Template *template0 in m_arrTemplateObject) 
        {
            if ([template0.btnCheckBox state]==NSOnState) 
            {
                [template0.tfSN1 setEditable:YES];
                [window makeFirstResponder:template0.tfSN1];
                break;
            }
        }
		[timerCheckFocus invalidate];
		[timerDetectAllFinished invalidate];
		[window setLevel:kCGBaseWindowLevelKey];
		[NSApp activateIgnoringOtherApps:NO];
	}
}

- (void)youngBrotherStartButtonUnpressed:(NSNotification *)aNote
{
    int iAll = [m_arrTemplateObject count];
    BOOL bBrotherTest = [[[[kFZ_UserDefaults objectForKey:kUserDefaultModeSetting] objectForKey:@"BROTHER"] objectForKey:@"BrotherTest"] boolValue];
    if (bBrotherTest)
    {
        int iCount = 0;
        //BOOL bAll = YES;
        for (int i = 0; i < iAll; i++)
        {
            BOOL bOne = NO;
            Template *objTemplate = [m_arrTemplateObject objectAtIndex:i];
            if (([objTemplate.btnStart isEnabled]) || ([objTemplate.btnCheckBox state] == NSOffState))
            {
                bOne = YES;
                iCount = iCount + 1;
            }
            else
            {
                bOne = NO;
            }
            //bAll &= bOne;
        }
        if (iCount == iAll - 1)
        {
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc postNotificationName:BNRYoungBrotherNotification object:self userInfo:nil];
        }
    }
    else
    {
        BOOL bAll = YES;
        for (int i = 1; i < iAll; i++)
        {
            BOOL bOne = NO;
            Template *objTemplate = [m_arrTemplateObject objectAtIndex:i];
            if (([objTemplate.btnStart isEnabled]) || ([objTemplate.btnCheckBox state] == NSOffState))
            {
                bOne = YES;
            }
            else
            {
                bOne = NO;
            }
            bAll &= bOne;
        }
        if (bAll)
        {
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc postNotificationName:BNRYoungBrotherNotification object:self userInfo:nil];
        }
    }

}


- (void)monitorAllTemplate:(NSNotification *)aNote
{
    NSMutableArray *arrTemplateObject = [[NSMutableArray alloc] init];
    [arrTemplateObject setArray:m_arrTemplateObject];
    // remove the untest and unuse tempate
    for (int i = [arrTemplateObject count] - 1; i >= 0; i--)
    {
        Template *objTemplate = [arrTemplateObject objectAtIndex:i];
        if ([objTemplate.btnCheckBox state] == NSOffState || objTemplate.m_bNoResponse)
        {
            [arrTemplateObject removeObjectAtIndex:i];
        }
    }
    
    NSString *szKey = [NSString stringWithFormat:@"%p", [aNote object]];
    NSString *szValue = [[aNote userInfo] objectForKey:@"TESTNAME"];
    if (szKey && szValue) 
    {
        [m_dicAntsFlags setObject:szValue forKey:szKey];
    }
    
    BOOL bExist = YES;
    int iLeft = [arrTemplateObject count];
    for (int i = 0; i < iLeft; i++)
    {
        Template *objTemplate = [arrTemplateObject objectAtIndex:i];
        NSString *szTestName = [m_dicAntsFlags objectForKey:[NSString stringWithFormat:@"%p", objTemplate]];
        if (nil == szTestName || [szTestName isEqualToString:@""])
        {
            bExist = NO;
            break;
        }
    }
    
    // if all tempate has posted notification, judge all the tempate notification name.
    BOOL bTest = NO;
    BOOL bAll = YES;
    if (bExist)
    {
        NSString *szTestName = [m_dicAntsFlags objectForKey:[NSString stringWithFormat:@"%p", [arrTemplateObject objectAtIndex:0]]];
        for (int i = 0; i < iLeft; i++)
        {
            BOOL bOne = NO;
            Template *objTemplate = [arrTemplateObject objectAtIndex:i];
            NSString *szOtherTestName = [m_dicAntsFlags objectForKey:[NSString stringWithFormat:@"%p", objTemplate]];
            if ([szOtherTestName isEqualToString:szTestName])
            {
                bOne = YES;
            }
            else
            {
                bOne = NO;
            }
            bAll &= bOne;
            bTest = YES;
        }
    }

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    if (bAll && bTest)
    {
        [nc postNotificationName:BNRAllPatternReadyOrNotNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"ALLREADY", nil]];
    }
    else
    {
        [nc postNotificationName:BNRAllPatternReadyOrNotNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], @"ALLREADY", nil]];
    }
    
    //[m_dicAntsFlags removeAllObjects];
    [arrTemplateObject release];
}
//add for 4-up grape-1
- (void)runPasswordCheckBrother:(NSNotification *)note
{
    // security window , u should enter the right password.
   // m_strSerialPortApp = [[note userInfo] objectForKey:@"UUT"];
    [m_dicUnitObject setObject:[[note userInfo] objectForKey:@"UUT"] forKey:@"CHOOSE_UNIT"];
    [scrWindow setBackgroundColor:nil];
    [NSApp beginSheet:scrWindow
       modalForWindow:window
        modalDelegate:self
       didEndSelector:nil
          contextInfo:nil];
}

- (void)detectProxCalUUT1
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    Template *objTemplate = [m_arrTemplateObject objectAtIndex:0];
    NSString *szBsdPath =[NSString stringWithFormat:@"%@", objTemplate.m_szSerialPortPath];
    TestProgress *objTestProgress = [[TestProgress alloc] init];
    NSMutableString *szUartResponse = [[NSMutableString alloc] init];
    do 
    {
        BOOL bConnected = [objTestProgress checkUnitConnectWellWithSerialPort:szBsdPath UARTCommand:@"" UartResponse:szUartResponse CheckTime:1.0];
        
        //get ECID
        NSString *strECID = @"";
        NSString * strLastObj = [[szUartResponse componentsSeparatedByString:@"\n"] lastObject];
        strLastObj = [strLastObj stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        strLastObj = [strLastObj stringByReplacingOccurrencesOfString:@" " withString:@""];
        if ([strLastObj hasPrefix:@"["] && [strLastObj hasSuffix:@"]:-)"] && [strLastObj ContainString:@":-)"])
        {
            strECID = [strLastObj SubFrom:@"[" include:YES];
            strECID = [strECID SubTo:@"]" include:YES];
        }
        
        //unit not finish test,then plug in slot1,show message
        int j=0;
        @synchronized(m_arrUnitECIDForProxCal)
        {
            for (int i= 0; i < [m_arrUnitECIDForProxCal count]; i++)
            {
                NSArray *arrProxCalMessage =[m_arrUnitECIDForProxCal objectAtIndex:i];
                if ([arrProxCalMessage count] >= 4)
                {
                    //Get UI slot
                    NSString *strUnit = [arrProxCalMessage objectAtIndex:1];
                    NSRange range = [strUnit rangeOfString:@"Unit"];
                    if ((NSNotFound != range.location) && (range.length>0) && ((range.location+range.length)<=[strUnit length])) 
                    {
                        j = [[strUnit substringFromIndex:range.location + range.length]intValue];
                        
                        //judge ECID
                        if ((j < ([m_arrTemplateObject count]+1)) && [strECID isEqualToString:[arrProxCalMessage objectAtIndex:0]])
                        {
                            NSString *strMessage = [NSString stringWithFormat:@"已测过Slot1，应测试%@(Tested slot1,change %@)",
                                                    [arrProxCalMessage objectAtIndex:3],[arrProxCalMessage objectAtIndex:3]];
                            
                            NSDictionary *dicMessage = [NSDictionary dictionaryWithObjectsAndKeys:strMessage,@"MESSAGE", nil];
                            NSNotification *aNote = [NSNotification notificationWithName:@"showMessageOnUI" object:self userInfo:dicMessage];
                            
                            //show message
                            [[m_arrTemplateObject objectAtIndex:j-1] closeMessage:aNote];
                            [[m_arrTemplateObject objectAtIndex:j-1] showMessage:aNote];
                            bConnected = NO;
                        }
                    }
                }
            }
        }
        if (bConnected) 
        {
            m_bDetectUUT1 = YES;
            
            // self call startTest function
            // get the idle template to start test
            int iIdleSlot = [self proxCalIdleSlot];
            if (-1 != iIdleSlot)
            {
                Template *objTemplateTemp = [m_arrTemplateObject objectAtIndex:iIdleSlot];
                [NSThread detachNewThreadSelector:@selector(startTest:) toTarget:objTemplateTemp withObject:nil];
            }
            
            // Don't detect UUT1 any more when UUT1 is on testing
            do
            {
                usleep(100000);
            } while (m_bDetectUUT1);
        }
        else
        {
            m_bDetectUUT1 = NO;
        }
        usleep(100000);

    } while (YES);
    
    [szUartResponse release];
    [objTestProgress release];
    [pool drain];
}

- (int)proxCalIdleSlot
{
    int iRet = -1;
    int iAll = [m_arrTemplateObject count];
    for (int i = 0; i < iAll; i++)
    {
        Template *objTemplate = [m_arrTemplateObject objectAtIndex:i];
        if ([objTemplate.btnCheckBox isEnabled] && ([objTemplate.btnCheckBox state] == NSOnState))
        {
            iRet = i;
            break;
        }

    }
    return iRet;
}

- (void)monitorProxCalUUT1: (NSNotification*)aNote
{
    [m_lockProxCal lock];
    NSArray *arrNewMessage = [[aNote userInfo] objectForKey:@"ProxCalMessage"];
    NSString *szECIDFinishTest = [[aNote userInfo] objectForKey:@"ECIDFinishTest"];
    
    // for slot1 unexpected fail: continuous three uart command fail and cancel to end on slot1 at fixture.
    BOOL bWakeUpUUT1 = [[[aNote userInfo] objectForKey:@"WakeUpUUT1"] boolValue];
    if (bWakeUpUUT1) 
    {
        m_bDetectUUT1 = NO;
        [m_lockProxCal unlock];
        return;
    }
    
    //Finish slot1 testing,others UI can detect UUT1.When testing,UI unit the same,remove primary record.
    if ([arrNewMessage count] >= 4) 
    {
        if ([[arrNewMessage objectAtIndex:2]isEqualToString:@"Slot1"]) 
        {
            m_bDetectUUT1 = NO;
        }
        
        @synchronized(m_arrUnitECIDForProxCal)
        {
            for (int i= 0; i< [m_arrUnitECIDForProxCal count]; i++)
            {
                NSArray *arrOldMessage= [m_arrUnitECIDForProxCal objectAtIndex:i];
                if ([[arrNewMessage objectAtIndex:1] isEqualToString:[arrOldMessage objectAtIndex:1]]) 
                {
                    [m_arrUnitECIDForProxCal removeObject:arrOldMessage];
                }
            }
            [m_arrUnitECIDForProxCal addObject:arrNewMessage];
        }

    }
    //Finish testing, ECID the same,remove primary record
    if (szECIDFinishTest && [szECIDFinishTest isNotEqualTo:@""]) 
    {
        @synchronized(m_arrUnitECIDForProxCal)
        {
            for (int i = 0; i < [m_arrUnitECIDForProxCal count]; i++)
            {
                if ([szECIDFinishTest isEqualToString:[[m_arrUnitECIDForProxCal objectAtIndex:i] objectAtIndex:0]])
                {
                    [m_arrUnitECIDForProxCal removeObject:[m_arrUnitECIDForProxCal objectAtIndex:i]];
                }
            }
        }
    }
    
    [m_lockProxCal unlock];
}

@end
