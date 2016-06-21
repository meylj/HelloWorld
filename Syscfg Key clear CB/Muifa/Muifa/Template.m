//
//  Template.m
//  Muifa
//
//  Created by Gordon Liu on 9/22/11.
//  Copyright 2011 PEGATRON. All rights reserved.
//

#import "Template.h"
#import "DebugWindowController.h"
#import "FuckDCSD.h"

NSString* const kNoteStartCSDStationChoice						= @"kNoteStartCSDStationChoice";


// for AE stations
NSString    * const  BNRRunColorChoicePanelNotification         = @"RunColorChoose";
extern    NSString    * const  BNRColorChoiceFinish;

NSString		*g_szMutex_Lock									= @"MutexLock";
//int				g_iPassForNFMU									= 0;
//int				g_iFailForNFMU									= 0;
//int				g_iCycleCountForNFMU							= 0;

// auto test system
extern  BOOL    gbIfNeedRemoteCtl;

@implementation Template

extern	NSString	*BNRPostTestInfoNotification;
extern	BOOL		g_bRELLinePick;


@synthesize LocationID = m_szLocationID;

@synthesize indicator;	// box view object
@synthesize listView;		// main view object
@synthesize inputView;	// SN Labels view object

// sn text field object
@synthesize btnStart;
@synthesize serialNumber1 = serialNum1;
@synthesize isRunning = m_bRunning;			// Bool value indicate test state
@synthesize isDCSDRunning = m_bDCSDRunning;			// Bool value indicate test state
@synthesize testProgress;					// auto test system

@synthesize templateDelegate;

//For SMT-QT 2UP
@synthesize isFinished  = m_bIsFinished;

//For Pressure Test , Leehua
@synthesize publicParas         = m_objPublicParams;

- (id)initWithParametric:(NSDictionary *)dicPara publicParam:(publicParams *)publicParams //For Prssure Test, Leehua Modified
{
    self	= [super init];
    if (self) 
    {
        m_bDCSDRunning  = NO;
        //For Pressure Test
        m_objPublicParams       = publicParams;
        m_bTestPass			= YES;
        m_bTestOnceScript	= NO;
        //testProgress		= [[TestProgress alloc] init];
        testProgress = [[TestProgress alloc] initWithPublicParam:m_objPublicParams];//For Pressure Test, modified by Leehua
        m_queue				= [[NSOperationQueue alloc] init];
        m_dicSNsFromUI		= [[NSMutableDictionary alloc] init];
        
        // get parameter from MuifaAppDelegate.h
        m_dicParaFromMuifa	= [dicPara retain];
        m_dicMuifa_Plist	= [[NSDictionary dictionaryWithContentsOfFile:kMuifaPlistPath] retain];
        m_dicGHInfo			= [dicPara objectForKey:@"GHInfo"];
        [testProgress.memoryValues setDictionary:m_dicGHInfo];
		/*!
		 * Modified by Raniys on 2014-07-29
		 * For PVT/MP stage, the detail tab should be selected to UART log tab while start testing.
		 */
//		NSBundle *bundle = [NSBundle mainBundle];
//		NSDictionary * bundleDict = [bundle infoDictionary];
//		m_bRunningWithUARTTab = [[bundleDict objectForKey:@"LSUIElement"] boolValue];
        m_bRunningWithUARTTab   = ([[m_dicGHInfo objectForKey:descriptionOfGHStationInfo(IP_BUILD_STAGE)] ContainString:@"PVT"]
                                   || [[m_dicGHInfo objectForKey:descriptionOfGHStationInfo(IP_BUILD_STAGE)] ContainString:@"MP"]);
        
        m_dicPorts			= [[NSMutableDictionary alloc]
							   initWithDictionary:[m_dicParaFromMuifa objectForKey:kTransferKey_Ports]];
		m_szSerialPortPath	= [[[m_dicPorts objectForKey:@"MOBILE"]
								objectAtIndex:0] retain];
        
        m_colorForUnit	= [[[m_dicParaFromMuifa objectForKey:kTransferKey_UnitColor]
							objectForKey:@"NSColor"] retain];
        [testProgress.memoryValues setObject:[[m_dicParaFromMuifa objectForKey:kTransferKey_UnitColor]
												   objectForKey:@"StringColor"]
										   forKey:kTransferKey_UnitColor];
        [testProgress.memoryValues setObject:m_colorForUnit
										   forKey:kPD_AMIOK_PanelColor];
        
        [testProgress.memoryValues setObject:m_dicMuifa_Plist
										   forKey:kPD_Muifa_Plist];
        if (m_szSerialPortPath) 
        {
            [testProgress.memoryValues setObject:m_szSerialPortPath
                                               forKey:kPD_Device_BSDPATH];
        }

        // load nib file
        [NSBundle loadNibNamed:@"Template" owner:self];
        m_arrCSVInfo				= [[NSMutableArray alloc] init];
        m_arrUARTInfo				= [[NSMutableArray alloc] init];
        m_arrFailInfo				= [[NSMutableArray alloc] init];
        
        // set sn lables and text fields
        m_arrSNLables		= [[NSArray alloc] initWithObjects:lbSN1,lbSN2,lbSN3,lbSN4,lbSN5,lbSN6, nil];
        m_arrSNTextFields	= [[NSArray alloc] initWithObjects:serialNum1,serialNum2,serialNum3,serialNum4,serialNum5,serialNum6, nil];
        
        // set data source and delegete
        [tvCSVInfo		setDelegate:self];
        [tvCSVInfo		setDataSource:self];
        [tvUARTInfo		setDelegate:self];
        [tvUARTInfo		setDataSource:self];
        [tvFailInfo		setDelegate:self];
        [tvFailInfo		setDataSource:self];
        [tabTestInfo	setDelegate:self];

        m_iSNNumber				= 0;
        m_szTestScriptFilePath	= [[[m_dicMuifa_Plist objectForKey:kUserDefaultScriptInfo]
									objectForKey:kUserDefaultScriptFileName] retain];
        
        //2012.03.02 Leehua
        if ([[[m_dicMuifa_Plist objectForKey:kUserDefaultModeSetting]
			  objectForKey:kUserDefaultManualStartTest] boolValue])
            [btnStart setKeyEquivalent:@""];
        
        m_bEmptyResponse	= NO;//Leehua
		m_strAEReadBuffer	= [NSMutableString new];
        
        //For SMT-QT 2UP
        m_bAllStarted   = NO;
        m_bAllEnded     = NO;
        m_bAllLoop      = NO;
        m_bIsFinished   = YES;
        
    }
    return self;
}

- (void)dealloc
{
    if (testProgress) 
        [testProgress release];
    //Leehua
	[m_strAEReadBuffer release];	m_strAEReadBuffer	= nil;
    if (m_dicSNsFromUI) 
        [m_dicSNsFromUI release];
    [m_dicParaFromMuifa release];
    [m_dicMuifa_Plist release];
    if (m_szSerialPortPath) 
        [m_szSerialPortPath release];
    [m_colorForUnit release];
    [m_arrSNLables release];
    [m_arrSNTextFields release];
    [m_arrObjTemplate release];
    [m_szCurrentUnit release];
    [m_szTestScriptFilePath release];
    [m_arrTestOnceScript release];
    if (m_szMainSN)
		[m_szMainSN release];
    
    [m_arrScriptFile release];
    [m_szScriptName release];
    [m_queue release];
    [m_arrCSVInfo release];
    [m_arrUARTInfo release];
    [m_arrFailInfo release];
    [m_dicPorts release];
    [m_szScriptVersion release];
	
    [super dealloc];
}

- (void)transferTemplateObject:(NSArray *)arrTemplateObj
{
    m_arrObjTemplate	= [arrTemplateObj copy];
}

// funciton for auto detect serial port for Auto detect and run test           -- Begin --
- (void)MonitorSerialPortPlugIn
{
    NSAutoreleasePool	*pool		= [[NSAutoreleasePool alloc] init];
    NSMutableString		*szSNInUnit	= [[NSMutableString alloc] init];
    NSLog(@" monitorSerialPortPlugInWithUartPath begin");
    NSString	*strAEFixtureStart	= [[m_dicMuifa_Plist objectForKey:kUserDefaultModeSetting]
									   objectForKey:kUserDefaultAEFixtureStart];
	if(strAEFixtureStart)
		[self monitorAEFixtureStartWithUartPath:[[m_dicPorts objectForKey:@"FIXTURE"] objectAtIndex:0]
									   andRegex:strAEFixtureStart];
	else
		[testProgress monitorSerialPortPlugInWithUartPath:m_szSerialPortPath
											 withOutputSN:szSNInUnit];
    NSLog(@" monitorSerialPortPlugInWithUartPath end");
    
    [lbUnitMark setStringValue:[NSString stringWithFormat:
								@"[%@]%@",
								m_szCurrentUnit, szSNInUnit]];
    [NSThread detachNewThreadSelector:@selector(startTest:)
							 toTarget:self
						   withObject:nil];
    [szSNInUnit release];
    [pool drain];
}

// funciton for auto detect If Op have click Fixture start button
- (void)MonitorFixtureHaveClickStart
{
	NSString *fixtureStartResponse = @"Start";
	NSString *strUartPath = [[m_dicPorts objectForKey:@"FIXTURE"] objectAtIndex:0];
	PEGA_ATS_UART	*uartFixture	= [[PEGA_ATS_UART alloc] init_Uart];
	[uartFixture openPort:strUartPath
				baudeRate:115200
				  dataBit:8
				   parity:@"NONE"
				 stopBits:1
				endSymbol:@"@"];
	NSMutableString	*strSingleRead	= [[NSMutableString alloc] init];
	while(uartFixture)
	{
		[uartFixture Read_UartData:strSingleRead
				   TerminateSymbol:[NSArray arrayWithObject:@"@"]
						 MatchType:1
					  IntervalTime:0.1
						   TimeOut:5];
		if(strSingleRead && ![strSingleRead isEqualToString:@""])
		{
			if([strSingleRead contains:fixtureStartResponse])
			{
				[NSThread detachNewThreadSelector:@selector(startTest:) toTarget:self withObject:nil];
				sleep(50);
			}
		}
	}
	[uartFixture release];
	[strSingleRead release];

}

- (void)MonitorSerialPortPlugOut
{
    NSAutoreleasePool	*pool	= [[NSAutoreleasePool alloc] init];
    if (nil==testProgress)
    {
       // testProgress	= [[TestProgress alloc] init];
       testProgress=[[TestProgress alloc] initWithPublicParam:m_objPublicParams];//For Pressure Test, modified by Leehua
       if (m_bTestOnceScript)
            // once test, do once test script
            testProgress.arrayScript	= m_arrTestOnceScript;
        else
            // not once test, do the default test script
            testProgress.arrayScript	= m_arrScriptFile;
        testProgress.ScriptName	= m_szScriptName;
        [testProgress.memoryValues setDictionary:m_dicGHInfo];
        [testProgress.memoryValues setObject:[[m_dicParaFromMuifa objectForKey:kTransferKey_UnitColor]
												   objectForKey:@"StringColor"]
										   forKey:kTransferKey_UnitColor];
        [testProgress.memoryValues setObject:m_colorForUnit
										   forKey:kPD_AMIOK_PanelColor];
        [testProgress.memoryValues setObject:m_dicMuifa_Plist
										   forKey:kPD_Muifa_Plist];
    }
    
    NSLog(@" monitorSerialPortPlugOutWithUartPath begin");
	if([[m_dicMuifa_Plist objectForKey:kUserDefaultModeSetting]
		objectForKey:kUserDefaultAEFixtureStart])
		;
	else
		[testProgress monitorSerialPortPlugOutWithUartPath:m_szSerialPortPath];
    NSLog(@" monitorSerialPortPlugOutWithUartPath end");

	// Start a new thread to monitor serial port plug in event
    [NSThread detachNewThreadSelector:@selector(MonitorSerialPortPlugIn)
							 toTarget:self
						   withObject:nil];
    [pool drain];
}
// funciton for auto detect serial port for auto detect and run test           -- End --

- (IBAction)startTest:(id)sender
{
    
    //For SMT-QT 2UP
    m_bAllStarted   = NO;
    m_bAllEnded     = NO;
    m_bAllLoop      = NO;
    m_bIsFinished   = NO;
    
	/*!
	 * Modified by Lorky on 2014-06-17
	 * For PVT/MP stage, the detail tab should be selected to UART log tab while start testing.
	 */
	if (m_bRunningWithUARTTab)
		[tabTestInfo selectTabViewItemAtIndex:1];
	if(m_bRunning)
	{
		return;
	}
	m_bRunning	= YES;
    m_bDCSDRunning  = YES;
    m_bEmptyResponse	= NO;//Leehua
    
    //Add for REL line, delete the data of the "SN_Arrangement" if the line is REL.
    NSMutableArray	*arrSNArrangement	= [NSMutableArray arrayWithArray:
										   [[m_dicMuifa_Plist objectForKey:kUserDefaultSN_Manager]
											objectForKey:kUserDefaultSN_Arrangement]];
    if ([[m_dicGHInfo objectForKey:descriptionOfGHStationInfo(IP_LINE_NUMBER)] ContainString:@"REL"])
        [arrSNArrangement removeAllObjects];
    // if the test is auto detect and run, we don't need to check the sn rule
    // auto test system
    BOOL    bAutoDetectRun  = [[[m_dicMuifa_Plist objectForKey:kUserDefaultModeSetting]
                                objectForKey:kUserDefaultAutoDetectAndRun] boolValue];

    if (gbIfNeedRemoteCtl) {
        bAutoDetectRun  = NO;
    }
    
    if (!bAutoDetectRun
		&& (nil != arrSNArrangement)
		&& (0 != [arrSNArrangement count]))
    { 
        BOOL	bCheckAboveSNRule	= NO;
        
        // get UI window object
        m_windowUI	= [[[inputView superview] superview] window];
        
        NSLog(@"startTest: check sn rule begin");
        bCheckAboveSNRule	= [self checkAboveSNRule];	// check the sn rule above the focus
        NSLog(@"startTest; check sn rule end");
        
        if (!bCheckAboveSNRule)
		{	// if check rule fail, return out of startTest funtion
			m_bRunning	= NO;
            m_bDCSDRunning = NO;
            return;
		}
        else
        {
            //For SMT-QT 2UP
            //For Check All Template SN Repeat Function, Fail Return.
            if ([[kFZ_UserDefaults objectForKey:@"SFMUSetting"] isKindOfClass:[NSDictionary class]])
            {
                if (![templateDelegate CheckSNHaveRepeat:self])
                {
                    m_bRunning      = NO;
                    m_bDCSDRunning  = NO;
                    m_bIsFinished   = YES;
                    return;
                }
            }
            
            if (nil == arrSNArrangement
				|| 0 == [arrSNArrangement count]
				|| g_bRELLinePick)
            {
                [m_dicSNsFromUI release];
                m_dicSNsFromUI	= nil;
            }
            else
            {
				// if check rule pass and the sn isn't the last sn, return and set focus to the next sn text field
                if (m_iSNNumber+1 != [arrSNArrangement count]) 
                {
                    [m_windowUI makeFirstResponder:[m_arrSNTextFields objectAtIndex:++m_iSNNumber]];
                    NSLog(@"startTest: set next focus to sn id(%d)", m_iSNNumber);
					m_bRunning	= NO;
                    m_bDCSDRunning = NO;
                    return;
                }
                else
                {
                    // if it all sn check pass, get sn KEY_VALUE from UI
                    m_szMainSN	= @"";
                    for (int i = 0; i < [arrSNArrangement count]; i++)
                    {
                        // get sn from UI
                        NSString	*szSNKey	= [[[m_arrSNLables objectAtIndex:i]
													stringValue] uppercaseString];
                        NSString	*szSNValue	= [[[m_arrSNTextFields objectAtIndex:i]
													stringValue] uppercaseString];
                        
                        // if it is garbage sn, don't add sn into m_dicSNsFromUI
                        if ([szSNKey isEqualToString:kUserDefualtGarbageSN])
                        {
                            NSLog(@"startTest: %@ = \"%@\"", szSNKey, szSNValue);
                            continue;
                        }
                        NSRange	range	= [szSNKey rangeOfString:@"*"];
                        if ((NSNotFound != range.location)
							&& (range.length > 0)
							&& ((range.length + range.location) <= [szSNKey length]))
                        {
                            if(m_szMainSN)
								[m_szMainSN release];
                            m_szMainSN	= [szSNValue copy];
                            szSNKey		= [szSNKey stringByReplacingOccurrencesOfString:@"*"
																		  withString:@""];
                        }
                        [m_dicSNsFromUI setObject:szSNValue
										   forKey:szSNKey];
                    }
                }
            }
        }
		
		[templateDelegate setNextResponder:self];
    }
    
    // open a thread to start to test unit
	[NSThread detachNewThreadSelector:@selector(startSingleTest:)
							 toTarget:self
						   withObject:nil];
}

- (BOOL)isDigitalForString:(NSString *)string
{
	BOOL bIsDigital = YES;
	char * cString = malloc([string length] + 1);
	memcpy(cString, [string UTF8String], [string length]);
	
	for (int i = 0; i < strlen(cString); i++)
		bIsDigital &= isdigit(cString[i]);
	free(cString);
	return bIsDigital;
}

- (BOOL)checkAboveSNRule
{
    BOOL	bRet			= YES;
    // sn check?
    BOOL	bNoSnRuleCheck	= [[[[kFZ_UserDefaults objectForKey:kUserDefaultScriptInfo]
								 objectForKey:kUserDefaultTestOnceScriptName]
								objectForKey:@"NOSNRuleCheck"] boolValue];
	if (bNoSnRuleCheck && g_bRELLinePick)
        return bRet;
    NSDictionary	*dicSNManage		= [m_dicMuifa_Plist objectForKey:kUserDefaultSN_Manager];
    //=============modify for Clear CB===============
    NSMutableArray	*arrSNArrangement;
    NSDictionary	*dicTestOnceScript	= [[kFZ_UserDefaults objectForKey:kUserDefaultScriptInfo]
										   objectForKey:kUserDefaultTestOnceScriptName];
    NSString		*onceScriptName		= [[dicTestOnceScript objectForKey:@"FATP_CB_PLIST"]
										   objectForKey:@"PlistFile"];
    
    if ([[onceScriptName uppercaseString]
		 isEqualToString:@"FATP_CB ERASE.PLIST"]
		&& [[onceScriptName uppercaseString]
			isEqualToString:[[NSString stringWithFormat:@"%@.PLIST",m_szScriptName]
							 uppercaseString]])
        arrSNArrangement	= [NSMutableArray arrayWithObject:@"SN1"];
    else
    {
        //Add for REL line, delete the data of the "SN_Arrangement" if the line is REL.
       arrSNArrangement     = [NSMutableArray arrayWithArray:
							   [dicSNManage objectForKey:kUserDefaultSN_Arrangement]];
        if ([[m_dicGHInfo objectForKey:descriptionOfGHStationInfo(IP_LINE_NUMBER)] ContainString:@"REL"])
            [arrSNArrangement removeAllObjects];
    }
    //=============modify for Clear CB===============
    if (nil != arrSNArrangement) 
    {
        int	iCheckNumber	= m_iSNNumber;
        NSLog(@"checkAboveSNRule: check sn numbers = %d", iCheckNumber+1);
        for (int i = 0; i <= iCheckNumber; i++)
        {
            NSLog(@"checkAboveSNRule: check sn label id(%d)", i);
            NSString	*szSNKey	= [[[m_arrSNLables objectAtIndex:i] stringValue]
									   uppercaseString];
            NSString	*szSNValue	= [[[m_arrSNTextFields objectAtIndex:i] stringValue]
									   uppercaseString];
			
            // basic judge
            if ([szSNValue isEqualToString:@""])
            {
                if (bRet)
                {
                    // set the focus to the first empty sn lable
                    m_iSNNumber	= i;
                    [m_windowUI makeFirstResponder:[m_arrSNTextFields objectAtIndex:i]];
                    NSLog(@"checkAboveSNRule: the first empty SN id(%d)", i);
                }
                bRet	= NO;
                continue;
            }
            
            // check sn rule
            NSDictionary    *dicSNInfomation	= [dicSNManage objectForKey:[arrSNArrangement objectAtIndex:i]];
            BOOL	bSNNeedCheckRule	= [[dicSNInfomation objectForKey:kUserDefaultNeedJudgeSn] boolValue];
            if (bSNNeedCheckRule)
            {
                // check sn rule
                // length
                
                NSArray     *arrSNLength    = [[dicSNInfomation objectForKeyedSubscript:kUserDefaultSNRule_Length] componentsSeparatedByString:@","];
                BOOL    bLength = NO;
                for (int iLength = 0; iLength < [arrSNLength count]; iLength++)
                {
                    int     iSNLength       = [[arrSNLength objectAtIndex:iLength] intValue];
                    // New requestion: need to judge each length.. and separated by ','.
                    if (0 != iSNLength && [szSNValue length] == iSNLength)
                    {
                        bLength    = YES;
                        NSLog(@"checkAboveSNRule: check sn length rule: PASS");
                        break;
                    }
                }
                
                if (!bLength)
                {
                    [[m_arrSNTextFields objectAtIndex:i] setStringValue:@""];
                    if (bRet)
                    {
                        // set the focus to the first FAIL sn lable
                        m_iSNNumber	= i;
                        [m_windowUI makeFirstResponder:[m_arrSNTextFields objectAtIndex:i]];
                        
                        NSLog(@"checkAboveSNRule: the first fail SN id(%d)", i);
                        bRet    = NO;
                    }
                    NSString	*szRunAlertTitle	= [NSString stringWithFormat:
                                                       @"错误(Error)(slot:%@)",
                                                       m_szCurrentUnit];
                    NSRunAlertPanel(szRunAlertTitle,
                                    @"%@长度不匹配，长度应该为[%@]。(%@ length should be [%@])",
                                    @"确定(OK)", nil, nil, szSNKey, [dicSNInfomation objectForKeyedSubscript:kUserDefaultSNRule_Length],szSNKey, [dicSNInfomation objectForKeyedSubscript:kUserDefaultSNRule_Length]);
                    continue;
                }
                else
				{
                    NSLog(@"checkAboveSNRule: check sn length rule: PASS");				
				}
                
				// Check is digital.
				BOOL bIsCheckDigital		=	[[dicSNInfomation objectForKey:@"isDigitalCheck"] boolValue];
				if (bIsCheckDigital)
				{
					BOOL isDigital  = [self isDigitalForString:szSNValue];
					if (!isDigital)
					{
						NSLog(@"checkAboveSNRule: check sn contain rule: FAIL");
						[[m_arrSNTextFields objectAtIndex:i] setStringValue:@""];
						if (bRet)
						{
							// set the focus to the first FAIL sn lable
							m_iSNNumber	= i;
							[m_windowUI makeFirstResponder:[m_arrSNTextFields objectAtIndex:i]];
							
							NSLog(@"checkAboveSNRule: the first fail SN id(%d)", i);
						}
						bRet	= NO;
						NSString	*szRunAlertTitle	= [NSString stringWithFormat:
														   @"错误(ERROR)(slot:%@)",m_szCurrentUnit];
						NSRunAlertPanel(szRunAlertTitle,@"%@[%@]不是数值类型的！(%@ is not digital!)",
										@"确认(OK)", nil, nil, szSNKey, szSNValue, szSNKey);
						continue;
					}
					else
						NSLog(@"checkAboveSNRule: check sn contain rule: PASS");
				}
				// no contain string
                NSString *szNoContainString = [dicSNInfomation objectForKey:kUserDefaultSNRuleNoContainString];
                if (nil != szNoContainString && ![szNoContainString isEqualToString:@""])
				{
                    NSRange rangeNoContain = [szSNValue rangeOfString:szNoContainString];
                    if (NSNotFound != rangeNoContain.location)
					{
                        [[m_arrSNTextFields objectAtIndex:i] setStringValue:@""];
                        if (bRet)
                        {
                            // set the focus to the first FAIL sn lable
                            m_iSNNumber	= i;
                            [m_windowUI makeFirstResponder:[m_arrSNTextFields objectAtIndex:i]];
                        }
                        bRet	= NO;
                        NSString	*szRunAlertTitle	= [NSString stringWithFormat:
                                                           @"错误(Error)(slot:%@)",
                                                           m_szCurrentUnit];
                        NSRunAlertPanel(szRunAlertTitle,@"%@中含有不期待的字符\"%@\",請重刷正確序號。(%@ contain invalid key string \"%@\",Please re-scan with the correct SN)",
                                        @"确认(OK)", nil, nil, szSNKey,szNoContainString, szSNKey, szNoContainString);
                        continue;
                    }
                }

                // contain string
                NSString	*szContainString	= [dicSNInfomation objectForKey:kUserDefaultSNRule_ContainString];
                if (nil != szContainString && ![szContainString isEqualToString:@""])
                {
                    NSArray	*arrKeyString	= [szContainString componentsSeparatedByString:@","];
                    
                    BOOL	bContain	= YES;
                    for (int i = 0; i < [arrKeyString count]; i++)
                    {
                        
                        NSRange	rangeContain	= [szSNValue rangeOfString:[arrKeyString objectAtIndex:i]];
                        if (NSNotFound != rangeContain.location
                            && rangeContain.length > 0
                            && rangeContain.length + rangeContain.location <= [szSNValue length])
                            szSNValue	= [szSNValue substringFromIndex:(rangeContain.location + rangeContain.length)];
                        else
                        {
                            bContain	= NO;
                            break;
                        }
                    }
                    if (!bContain)
                    {
                        NSLog(@"checkAboveSNRule: check sn contain rule: FAIL");
                        [[m_arrSNTextFields objectAtIndex:i] setStringValue:@""];
                        if (bRet)
                        {
                            // set the focus to the first FAIL sn lable
                            m_iSNNumber	= i;
                            [m_windowUI makeFirstResponder:[m_arrSNTextFields objectAtIndex:i]];
                            
                            NSLog(@"checkAboveSNRule: the first fail SN id(%d)", i);
                        }
                        bRet	= NO;
                        NSString	*szRunAlertTitle	= [NSString stringWithFormat:
                                                           @"错误(ERROR)(slot:%@)",
                                                           m_szCurrentUnit];
                        NSString	*szTempString		= [szContainString
                                                           stringByReplacingOccurrencesOfString:@","
                                                           withString:@"\" \""];
                        NSRunAlertPanel(szRunAlertTitle,
                                        @"%@中没有特定的字符\"%@\"。(%@ does not contain key string \"%@\")",
                                        @"确认(OK)", nil, nil, szSNKey,szTempString, szSNKey, szTempString);
                        continue;
                    }
                    else
                        NSLog(@"checkAboveSNRule: check sn contain rule: PASS");
                    
                }
               
                
                // contain one of string, Add by yaya. 2014.8.5
                NSString	*szContainOneOfString	= [dicSNInfomation objectForKey:KUserDefaultSNRule_ContainOneOfString];
                if (nil != szContainOneOfString && ![szContainOneOfString isEqualToString:@""])
                {
                    NSArray	*arrKeyAllString	= [szContainOneOfString componentsSeparatedByString:@","];
                    NSString *szSNPrefix = [szSNValue subByRegex:@"^(.{3})" name:nil error:nil];

                    BOOL	bContainOneOf	= NO;
                    for (int i = 0; i < [arrKeyAllString count]; i++)
                    {
                        NSRange	rangeContain	= [szSNPrefix rangeOfString:[arrKeyAllString objectAtIndex:i]];
                        if (NSNotFound != rangeContain.location
                            && rangeContain.length > 0
                            && rangeContain.length + rangeContain.location <= [szSNPrefix length])
                        {
                            bContainOneOf = YES;
                            break;
                        }
                    }
                    if (!bContainOneOf)
                    {
                        NSLog(@"checkAboveSNRule: check sn contain one of rule: FAIL");
                        [[m_arrSNTextFields objectAtIndex:i] setStringValue:@""];
                        if (bRet)
                        {
                            // set the focus to the first FAIL sn lable
                            m_iSNNumber	= i;
                            [m_windowUI makeFirstResponder:[m_arrSNTextFields objectAtIndex:i]];
                            
                            NSLog(@"checkAboveSNRule: the first fail SN id(%d)", i);
                        }
                        bRet	= NO;
                        NSString	*szRunAlertTitle	= [NSString stringWithFormat:
                                                           @"错误(ERROR)(slot:%@)",
                                                           m_szCurrentUnit];
                        NSString	*szTempString		= [szContainOneOfString
                                                           stringByReplacingOccurrencesOfString:@","
                                                           withString:@"\" \""];
                        NSRunAlertPanel(szRunAlertTitle,
                                        @"%@中没有特定的字符\"%@\"。(%@ does not contain key string \"%@\")",
                                        @"确认(OK)", nil, nil, szSNValue,szTempString, szSNValue, szTempString);
                        continue;
                    }
                    else
                        NSLog(@"checkAboveSNRule: check sn contain rule: PASS");
                }
            }
        }
    }
    
    return bRet;
}


- (void)UpdateUI_Object:(id)aObject {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if ([aObject isKindOfClass:[NSTableView class]])
        [aObject reloadData];
    [pool drain];
}

- (void)startSingleTest:(NSDictionary *)dicInfo
{
    NSLog(@"startSingleTest begin");
    NSAutoreleasePool		*pool	= [[NSAutoreleasePool alloc] init];
    NSNotificationCenter	* nc	= [NSNotificationCenter defaultCenter];
    // set UI uneditable
    [serialNum1 setEditable:NO];
    [serialNum2 setEditable:NO];
    [serialNum3 setEditable:NO];
    [serialNum4 setEditable:NO];
    [serialNum5 setEditable:NO];
    [serialNum6 setEditable:NO];
	
    [btnStart	setEnabled:NO];

    //For SMT-QT 2UP
    //Send message to AppDelegate for check all Template have started
    [nc addObserver:self
           selector:@selector(TEPAllTemplateHaveStarted:)
               name:@"TEMNOTIFORCHECKALLTEMPLATEHAVESTARTED"
             object:nil];
    if ([[kFZ_UserDefaults objectForKey:@"SFMUSetting"] isKindOfClass:[NSDictionary class]])
    {
        while (!m_bAllStarted)
        {
            sleep(1);
        }
    }
    [nc removeObserver:self name:@"TEMNOTIFORCHECKALLTEMPLATEHAVESTARTED" object:nil];


    // show time indicator
    [lbTotalTime setStringValue:@"Time: 00:00:00"];
    [NSThread detachNewThreadSelector:@selector(setTimeIndicator:)
							 toTarget:self
						   withObject:nil];
    
    // iPass&iFail for counting cycle count results
	int	iPass	= 0;
	int	iFail	= 0;
    
    // if m_iRunCount = 1, test once; m_iRunCount > 1, cycle test
    for(int iCount = 0;iCount < m_iRunCount;iCount++)
    {
        NSAutoreleasePool	*poolFunnyZone	= [[NSAutoreleasePool alloc] init];
        //For SMT-QT 2UP
        m_bAllLoop      = NO;
        m_bIsFinished   = NO;

        // we need to alloc one testProgress object every test
        if (nil == testProgress)
		{
			//testProgress	= [[TestProgress alloc] init];
            testProgress = [[TestProgress alloc] initWithPublicParam:m_objPublicParams];//For Pressure Test, modified by Leehua
            if (m_bTestOnceScript)
                // once test, do once test script
                testProgress.arrayScript	= m_arrTestOnceScript;
            else
                // not once test, do the default test script
                testProgress.arrayScript	= m_arrScriptFile;
            testProgress.ScriptName	= m_szScriptName;
            [testProgress.memoryValues setDictionary:m_dicGHInfo];
            [testProgress.memoryValues setObject:
			 [[m_dicParaFromMuifa objectForKey:kTransferKey_UnitColor]
			  objectForKey:@"StringColor"]
											   forKey:kTransferKey_UnitColor];
            [testProgress.memoryValues setObject:m_colorForUnit
											   forKey:kPD_AMIOK_PanelColor];
            [testProgress.memoryValues setObject:m_dicMuifa_Plist
											   forKey:kPD_Muifa_Plist];

		}
        
        
        [testProgress.memoryValues setObject:m_szLocationID forKey:@"PLOCATIONID"];
        
        // set Pass for default result
        m_bTestPass	= YES;

        // add observers
        [nc removeObserver:self];
        [nc addObserver:self
               selector:@selector(handleTestResult:) 
                   name:TestItemInfoNotification 
                 object:testProgress];
        [nc addObserver:self
			   selector:@selector(tableViewSelectionDidChange:)
				   name:NSTableViewSelectionDidChangeNotification
				 object:nil];
        
        [nc addObserver:self
			   selector:@selector(showScanSN:)
				   name:@"NotificationScanSN"
				 object:nil];
        
        // For AE stations
        [nc addObserver:self
               selector:@selector(getUnitColorNoti:)
                   name:BNRRunColorChoicePanelNotification
                 object:nil];
		[nc addObserver:self
			   selector:@selector(startStationChoice:)
				   name:(NSString*)kNoteStartCSDStationChoice
				 object:testProgress];
        
        //clear content of tableViews and testView
        @synchronized(m_arrCSVInfo)
        {
            [m_arrCSVInfo removeAllObjects];
        }
        @synchronized(m_arrUARTInfo)
        {
            [m_arrUARTInfo removeAllObjects];
        }
        @synchronized(m_arrFailInfo)
        {
            [m_arrFailInfo removeAllObjects];
        }
        [self performSelectorOnMainThread:@selector(UpdateUI_Object:)
                               withObject:tvCSVInfo waitUntilDone:YES];
        [self performSelectorOnMainThread:@selector(UpdateUI_Object:)
                               withObject:tvFailInfo waitUntilDone:YES];
        [self performSelectorOnMainThread:@selector(UpdateUI_Object:)
                               withObject:tvUARTInfo waitUntilDone:YES];
        [textViewFailInfo setString:@""];
        
        // set default indicator view
        [lbPercentageNumber setStringValue:@"0%"];
        [levelIndicator setFloatValue:0.0f];
        [lbResultLabel setStringValue:@"TESTING"];
        [lbResultLabel setTextColor:[NSColor   blackColor]];
        [lbResultLabel setBackgroundColor:[NSColor orangeColor]];
        
        //transfer SN Key-Value to FunnyZone
        if (m_dicSNsFromUI != nil
			&& [m_dicSNsFromUI count]>0)
        {
            testProgress.MobileSerialNumber	= m_szMainSN;
            NSArray	*arrKeys	= [m_dicSNsFromUI allKeys];
            for (int i = 0; i < [arrKeys count]; i++)
            {
                NSString	*szKey	= [arrKeys objectAtIndex:i];
                [testProgress.memoryValues setObject:[m_dicSNsFromUI objectForKey:szKey]
												   forKey:szKey];
            }
        }
        // get start time and transfer to FunnyZone
		testProgress.startTime	= [[NSDate date] descriptionWithCalendarFormat:@"%Y-%m-%d %H-%M-%S"
																		 timeZone:nil
																		   locale:nil];
        testProgress.startDate = [[NSDate date] descriptionWithCalendarFormat:@"%Y%m%d"
																		 timeZone:nil
																		   locale:nil];
        
        //Modified by raniys on 2/26/2015: delete LiveController and add default Live file
        /*************************Start modify*********************/
        //Get GH Live Controller Alias File Path
        NSString * strLivePath		= [m_dicGHInfo objectForKey:descriptionOfGHStationInfo(IP_LIVE_VERSION_PATH)];
        NSString * strLiveCurrent	= [m_dicGHInfo objectForKey:descriptionOfGHStationInfo(IP_LIVE_CURRENT)];
        NSString * strController			= [m_dicGHInfo objectForKey:descriptionOfGHStationInfo(IP_CONTROL_RUN)];
        NSString * strCRFile = [strController isEqualToString:@"ON"] ? @"control_run" : @"default";
        NSString * strLimitFilePath = [NSString stringWithFormat:@"%@/%@/%@",strLivePath,strLiveCurrent,strCRFile];
        NSString * szStationName	= [[[m_dicMuifa_Plist objectForKey:kUserDefaultScriptInfo]
                                       objectForKey:kUserDefaultScriptFileName]SubTo:@".plist" include:NO];
        NSString * strDefaultLivePath = [NSString stringWithFormat:
                                         @"%@/Contents/Frameworks/FunnyZone.framework/Resources/LIVE_%@_DEFAULT.plist",
                                         [[NSBundle mainBundle] bundlePath],szStationName];
        NSLog(@"GH Live Controller Alias File Path=====%@",strLimitFilePath);
        NSFileManager * fileManager = [NSFileManager defaultManager];
        if ([[m_dicGHInfo objectForKey:descriptionOfGHStationInfo(IP_LIVE_CURRENT)]boolValue]&&[fileManager fileExistsAtPath:strLimitFilePath])
        {
            //Get GH Live Controller Original File Path
            NSString    *szOriginalName = [fileManager destinationOfSymbolicLinkAtPath:strLimitFilePath error:nil];
            NSLog(@"GH Live Controller Original File Name=====%@",szOriginalName);
            NSString    *szOriginalPath  = [NSString stringWithFormat:@"%@/%@/%@",strLivePath,strLiveCurrent,szOriginalName];
            NSLog(@"GH Live Controller Original File Path=====%@",szOriginalPath);
            
            //Get GH Live Controller All Data
            NSDictionary * dictLimit = [NSDictionary dictionaryWithContentsOfFile:szOriginalPath];
            NSLog(@"GH Live Controller All Data%@",dictLimit);
            for (NSString *strKey in [dictLimit allKeys])
            {
                [testProgress.memoryValues setObject:[dictLimit objectForKey:strKey] forKey:strKey];
                NSLog(@"GH Live Controller Key: [%@]; Value[%@];", strKey, [testProgress.memoryValues objectForKey:strKey]);
            }
        }
        else if ([fileManager fileExistsAtPath:strDefaultLivePath])
        {
            
            NSLog(@"The default live file path=====%@",strDefaultLivePath);
            NSDictionary * dictLimit = [NSDictionary dictionaryWithContentsOfFile:strDefaultLivePath];
            for (NSString *strKey in [dictLimit allKeys])
            {
                [testProgress.memoryValues setObject:[dictLimit objectForKey:strKey] forKey:strKey];
                NSLog(@"Default Live Controller Key: [%@]; Value[%@];", strKey, [testProgress.memoryValues objectForKey:strKey]);
            }
        }
        /*************************End modify*********************/
        
        // set unit name as Port index for FunnyZone to write logs
        testProgress.portIndex	= [NSMutableString stringWithString:m_szCurrentUnit];
        
        // transfer serial port information to FunnyZone by Unit
        [testProgress setPorts:m_dicPorts];
        
        // transfer UI version and script version to FunnyZone
        
        //Add for GH Live Controller
        if ([[testProgress.memoryValues objectForKey:@"LIVE_VER"] isNotEqualTo:@""]
            && [testProgress.memoryValues objectForKey:@"LIVE_VER"] != nil)
        {
            testProgress.uiVersion		= [NSString stringWithFormat:@"%@_%@",m_szUIVersion,[testProgress.memoryValues objectForKey:@"LIVE_VER"]];
            
            NSLog(@"Need Combine UI Version by GH Live Controller=====%@",testProgress.uiVersion);
        }
        else
        {
            testProgress.uiVersion		= m_szUIVersion;
            NSLog(@"No Need to Combine UI Version===%@",testProgress.uiVersion);
        }
        
        //Add for GH Live Controller
		//testProgress.uiVersion		= m_szUIVersion;
        testProgress.scriptVersion	= m_szScriptVersion;
        
		// get the py file path
		if (m_szSerialPortPath)
		{
			[testProgress.memoryValues setObject:m_szSerialPortPath
											   forKey:kPD_Device_BSDPATH];
		}
		// start test at FunnyZone after next code
        [m_queue addOperation:testProgress];
        
        while(YES)
        {
            m_bEmptyResponse	= testProgress.isEmptyResponse;//Leehua
            
            // when finish test, this code will execute
            if([testProgress isFinished])
            {
                //For SMT-QT 2UP
                m_bIsFinished   = YES;
                // make test once script only test once
               if (m_bTestOnceScript)
                {
                    // test once
                    // back to normal test script and refresh UI
                    // added by lucy for test once
                   NSString	*szPlanFileName	= [[m_dicMuifa_Plist objectForKey:kUserDefaultScriptInfo]
											   objectForKey:kUserDefaultScriptFileName];
                    [self parseAndLoadScriptFile:szPlanFileName
									OnlyTestOnce:m_bTestOnceScript];
                    m_bTestOnceScript	=NO;
                }
				[self parseAndLoadScriptFile:m_szTestScriptFilePath
								OnlyTestOnce:m_bTestOnceScript];
                
                [nc removeObserver:self name:TestItemInfoNotification object:testProgress];
                [nc removeObserver:self name:@"NotificationScanSN" object:nil];
                [nc removeObserver:self name:BNRRunColorChoicePanelNotification object:nil];
				
                // set UI according to the test result
                if (m_bTestPass) 
                {
					iPass ++;
//                    g_iPassForNFMU ++;
                    [lbResultLabel setDrawsBackground:YES];
                    [lbResultLabel setBackgroundColor:[NSColor greenColor]];
                    [lbResultLabel setStringValue:@"PASS"];
                }
                else
                {
					iFail ++;
                    [lbResultLabel		setDrawsBackground:YES];
                    
                    // if this fail is process fail, yellow background and red type. otherwise, red background and black type.
					[lbResultLabel		setBackgroundColor:testProgress.processIssue ? [NSColor yellowColor] : [NSColor redColor]];
					[lbResultLabel		setTextColor:testProgress.processIssue ? [NSColor   redColor] : [NSColor   blackColor]];
					[lbResultLabel		setStringValue:@"FAIL"];
				}
				[testProgress release];
                testProgress	= nil;

				// add count after test and show on UI
				if (0 != m_iRunCount && 1 != m_iRunCount) 
				{
					[lbTotalCount setStringValue:[NSString stringWithFormat:@"LoopTest: %d/%d (P:%d F:%d)",iCount+1, m_iRunCount, iPass, iFail]];
				}
				else
				{
                    NSDictionary	*dicInfo	= [NSDictionary dictionaryWithObjectsAndKeys:
												   m_szCurrentUnit,							@"CurrentUnit",
												   [NSNumber numberWithBool:m_bTestPass],	@"TestResult", nil];
                    
                    // open a thread to write count into setting file
                    [NSThread detachNewThreadSelector:@selector(writeCountIntoSettingFile:)
											 toTarget:self
										   withObject:dicInfo];
                    
                    BOOL    bAutoDetectRun  = [[[m_dicMuifa_Plist objectForKey:kUserDefaultModeSetting]
                                                objectForKey:kUserDefaultAutoDetectAndRun] boolValue];
                    // auto test system
                    if (gbIfNeedRemoteCtl){
                        bAutoDetectRun  = NO;
                    }
                    if (bAutoDetectRun)
                        // open a thread to monitor serial port whether pulg out for auto detect and run test
                        [NSThread detachNewThreadSelector:@selector(MonitorSerialPortPlugOut)
												 toTarget:self
											   withObject:nil];

				}
               
                [poolFunnyZone release];

                //For SMT-QT 2UP
                //For loop test, Send message to AppDelegate for check all Template have finished and restart the fixture for next test
                if (m_iRunCount > 1)
                {
                    [nc addObserver:self
                           selector:@selector(TEPAllTemplateLoopFinished:)
                               name:@"TEMNOTIFORLOOPTESTCHECKALLTEMPLATEHAVEFINISHED"
                             object:nil];
                    if ([[kFZ_UserDefaults objectForKey:@"SFMUSetting"] isKindOfClass:[NSDictionary class]])
                    {
                        [nc postNotificationName:@"APPNOTIFORLOOPTESTCHECKALLTEMPLATEHAVEFINISHED" object:self userInfo:nil];
                        while (!m_bAllLoop)
                        {
                            sleep(1);
                        }
                    }
                    [nc removeObserver:self name:@"TEMNOTIFORLOOPTESTCHECKALLTEMPLATEHAVEFINISHED" object:nil];
                }
                
                break; // one test finish, break while(YES) loop
            }
            usleep(100000);
        }
        // if m_iRunCount = 1, for loop will end and continue to execute next code
        // if m_iRunCount > 1, loop test
    }
    
    // editable UI
    [serialNum1 setEditable:YES];
    [serialNum2 setEditable:YES];
    [serialNum3 setEditable:YES];
    [serialNum4 setEditable:YES];
    [serialNum5 setEditable:YES];
    [serialNum6 setEditable:YES];
    [btnStart	setEnabled:YES];

	
	m_iSNNumber	= 0;
    
    // set SN default lables
    [self setSNDefaultLables];
 	m_bRunning	= NO;
    
    //For SMT-QT 2UP
    //Send message to AppDelegate for check all Template have finished
    [nc addObserver:self
           selector:@selector(TEPAllTemplateHaveFinished:)
               name:@"TEMNOTIFORCHECKALLTEMPLATEHAVEFINISHED"
             object:nil];
    if ([[kFZ_UserDefaults objectForKey:@"SFMUSetting"] isKindOfClass:[NSDictionary class]])
    {
        [nc postNotificationName:@"APPNOTIFORCHECKFIXTUREHAVEFINISHED" object:self userInfo:nil];
        while (!m_bAllEnded)
        {
            sleep(1);
        }
    }
    [nc removeObserver:self name:@"TEMNOTIFORCHECKALLTEMPLATEHAVEFINISHED" object:nil];
    
	
	if (m_bRunningWithUARTTab)
		[tabTestInfo selectTabViewItemAtIndex:0];
	
    [pool drain];
    NSLog(@"startSingleTest end");
}

-(void)handleTestResult:(NSNotification*)note
{
    if ([[[note userInfo] objectForKey:kFunnyZoneIdentify]
		 isEqualToString:kUartView])
        [self processUartLog:[note userInfo]];
    else if(([[note object] isMemberOfClass:[TestProgress class]])
			&& ([[[note userInfo] objectForKey:kFunnyZoneIdentify]
				 isEqualToString:kAllTableView]))
        [self processNormalTest:note];
}

-(void)processUartLog:(NSDictionary*)dicResult
{
    NSString	*szTxRx	= [dicResult objectForKey:kIADeviceNotificationTX];
    szTxRx	= [szTxRx stringByReplacingOccurrencesOfString:kFunnyZoneEnter
											   withString:kFunnyZoneBlank1];
    szTxRx	= [szTxRx stringByReplacingOccurrencesOfString:kFunnyZoneNewLine
											   withString:kFunnyZoneBlank1];
	
	NSMutableDictionary	*dictTemp	= [NSMutableDictionary dictionaryWithDictionary:dicResult];
	[dictTemp setObject:szTxRx forKey:kIADeviceNotificationTX];
    @synchronized(m_arrUARTInfo)
    {
        [m_arrUARTInfo addObject:dictTemp];
    }
    NSLog(@"processUartLog: ADD UART LOG: %@", dictTemp);
}

-(void)processNormalTest:(NSNotification*)noti
{
    NSDictionary	*dicResult	= [[NSDictionary alloc] initWithDictionary:[noti userInfo]];
    BOOL			bResult		= [[dicResult objectForKey:kFunnyZoneSingleItemResult] boolValue];
    if	(!bResult)
    {
        @synchronized(m_arrFailInfo)
        {
            [m_arrFailInfo addObject:dicResult];
        }
        m_bTestPass	= NO;
        if (testProgress.isCheckedPDCA)
        {
            // set back the flag and return.
            [dicResult release];
            testProgress.isCheckedPDCA	= NO;
            return;
        }
    }
    
    // synchronize the levelindicator with test process.
    NSInteger	curIndex	= [[dicResult objectForKey:kFunnyZoneCurrentIndex] intValue];
    NSInteger	sum			= [[dicResult objectForKey:kFunnyZoneSumIndex] intValue];
    [levelIndicator setMinValue:0];
    [levelIndicator setMaxValue:sum-1];
//    [levelIndicator setIntValue:curIndex+1];
    [levelIndicator setIntegerValue:curIndex+1];//Modified by raniys on 3/2/2015
    [lbPercentageNumber setStringValue:[NSString stringWithFormat:
										@"%.2f%%",
										(float)(curIndex + 1) *100 /sum]];
    
    @synchronized(m_arrCSVInfo)
    {
        [m_arrCSVInfo insertObject:dicResult atIndex:0];
    }
    [dicResult release];
    
    if ([[[tabTestInfo tabViewItems] objectAtIndex:0] isEqualTo:[tabTestInfo selectedTabViewItem]])
	{
        [self performSelectorOnMainThread:@selector(UpdateUI_Object:)
                               withObject:tvCSVInfo waitUntilDone:YES];
    }
}

- (void)setDefaultValueAndGetScriptInfo:(NSString *)szIdentifier
{
    NSLog(@"setDefaultValueAndGetScriptInfo begin");
    
    //Current Unit
    m_szCurrentUnit	= [szIdentifier retain];
    
    [lbUnitMark setStringValue:szIdentifier];
    // set color of the unit lable
    [lbUnitMark setBackgroundColor:m_colorForUnit];
    
    // set labels
    [lbPercentageNumber setStringValue:@"0%"];
    [levelIndicator setFloatValue:0.0f];
    [lbResultLabel setStringValue:@"READY"];
    [lbResultLabel setBackgroundColor:[NSColor orangeColor]];
    [lbTotalTime setStringValue:@"Time: 00:00:00"];
    [lbTotalCount setStringValue:@"Count: 0 (P:0 F:0)"];
    
	[self showCountOnLable:nil];
    
    // parse the script file.
	NSString	*szPlanFileName	= [[m_dicMuifa_Plist objectForKey:kUserDefaultScriptInfo]
								   objectForKey:kUserDefaultScriptFileName];
    [self parseAndLoadScriptFile:szPlanFileName OnlyTestOnce:NO];
    
    // get UI version and script file verion
    m_szUIVersion		= [[[NSBundle mainBundle] infoDictionary]
							valueForKey:@"CFBundleShortVersionString"];
	
    m_szScriptVersion	= [[self Get_Script_Version] retain];
    
    NSLog(@"setDefaultValueAndGetScriptInfo end");
}

- (void)parseAndLoadScriptFile:(NSString *)szcriptFileName
				  OnlyTestOnce:(BOOL)bTestOnce
{
    NSLog(@"parseAndLoadScriptFile begin");
    NSString	*szPlanFilePath	= [NSString stringWithFormat:
								   @"%@/Contents/Frameworks/FunnyZone.framework/Resources/%@",
								   [[NSBundle mainBundle] bundlePath], szcriptFileName];
	NSLog(@"parseAndLoadScriptFile: Plan file path: %@", szPlanFilePath);
    
    //Add by xiaoyong for summary log
    NSRange		range		= [szcriptFileName rangeOfString:@".plist"];
    NSString	*szScript	= @"";
    if ((NSNotFound != range.location)
		&& (range.length >0)
		&& range.location+range.length <= [szcriptFileName length])
        szScript	= [szcriptFileName stringByReplacingCharactersInRange:range
															withString:@""];

    // get script information and save it for FunnyZone
    m_bTestOnceScript		= bTestOnce;
    
    [m_szTestScriptFilePath release];
    m_szTestScriptFilePath	= [szcriptFileName retain];
   
    
    if (nil != testProgress)
    {
        testProgress.arrayScript	= [testProgress parserScriptFile:szPlanFilePath];
        if (m_arrScriptFile)
			[m_arrScriptFile release];
        m_arrScriptFile	= [testProgress.arrayScript copy];
    }
    else
    {
        //TestProgress	*temp	= [[TestProgress alloc] init];
        TestProgress *temp  = [[TestProgress alloc] initWithPublicParam:m_objPublicParams];//For Pressure Test, modified by Leehua
        if (m_arrScriptFile)
			[m_arrScriptFile release];
        m_arrScriptFile	= [[temp parserScriptFile:szPlanFilePath] copy];
        [temp release];
    }
    
    if (bTestOnce)
    {
        // if it is test once script file, save to the special array
        if (nil != testProgress)
        {
            testProgress.arrayScript	= [testProgress parserScriptFile:szPlanFilePath];
            if (m_arrTestOnceScript)
				[m_arrTestOnceScript release];
            m_arrTestOnceScript	= [testProgress.arrayScript copy];
        }
        else
        {
            //TestProgress	*temp	= [[TestProgress alloc] init];
            TestProgress *temp  = [[TestProgress alloc] initWithPublicParam:m_objPublicParams];//For Pressure Test, modified by Leehua
            if (m_arrTestOnceScript)
				[m_arrTestOnceScript release];
            m_arrTestOnceScript	= [[temp parserScriptFile:szPlanFilePath] copy];
            [temp release];
        }
    }
    else
    {
        //=============modify for Clear CB===============
        //Alloc testProcess object
        if (nil !=testProgress)
		{
            testProgress.arrayScript	= [testProgress parserScriptFile:szPlanFilePath];
            if (m_arrScriptFile)
				[m_arrScriptFile release];
            m_arrScriptFile	= [testProgress.arrayScript copy];
        }
        else
        {
            //TestProgress	*temp	=[[TestProgress alloc] init];
            TestProgress	*temp = [[TestProgress alloc] initWithPublicParam:m_objPublicParams];//For Pressure Test, modified by Leehua
            temp.arrayScript	= [temp parserScriptFile:szPlanFilePath];
            if (m_arrScriptFile)
				[m_arrScriptFile release];
            m_arrScriptFile		= [temp.arrayScript copy];
            [temp release];
        }
        //=============modify for Clear CB===============
    }
	
    if (m_szScriptName)
		[m_szScriptName release];
    testProgress.ScriptName = m_szScriptName	= [szScript retain];

    // check the script name between groundhog and setting file
    NSString	*szStationType	= [m_dicGHInfo objectForKey:descriptionOfGHStationInfo(IP_STATION_TYPE)];
    if ([szcriptFileName isEqualToString:[NSString stringWithFormat:
										  @"%@.plist",szStationType]])
        [lbScriptFile setTextColor:[NSColor blackColor]];
    else
        [lbScriptFile setTextColor:[NSColor redColor]];
	[lbScriptFile setStringValue:[NSString stringWithFormat:
								  @"Script:  %@",szcriptFileName]];
    NSLog(@"parseAndLoadScriptFile end");
}

- (void)setSNDefaultLables
{
	NSDictionary	*dicSerialNumManager       = [m_dicMuifa_Plist objectForKey:kUserDefaultSN_Manager];
	//Add for REL line, delete the data of the "SN_Arrangement" if the line is REL.
	NSMutableArray  *arrSNArrangement    = [NSMutableArray arrayWithArray:
											[[m_dicMuifa_Plist objectForKey:kUserDefaultSN_Manager]
											 objectForKey:kUserDefaultSN_Arrangement]];
	if ([arrSNArrangement count] == 0 ||
        [[m_dicGHInfo objectForKey:descriptionOfGHStationInfo(IP_LINE_NUMBER)] ContainString:@"REL"])
	{
		[self.inputView setFrame:NSMakeRect(0, 0, 0, 0)];
		return;
	}
	
	NSMutableArray * arySNAll		= [[NSMutableArray alloc] initWithObjects:lbSN1,lbSN2,lbSN3,lbSN4,lbSN5,lbSN6, nil];
	NSMutableArray * aryInputAll	= [[NSMutableArray alloc] initWithObjects:serialNum1,serialNum2,serialNum3,serialNum4,serialNum5,serialNum6, nil];

	for (int i = 0; i < [arrSNArrangement count]; i++)
	{
		NSDictionary	*dicParameters	= [dicSerialNumManager objectForKey:[arrSNArrangement objectAtIndex:i]];
		[[arySNAll objectAtIndex:0]		setEnabled:YES];
		[[aryInputAll objectAtIndex:0]	setEnabled:YES];
		[[arySNAll objectAtIndex:0]		setStringValue:[[dicParameters objectForKey:kUserDefaultShowTitle] uppercaseString]];
		[[aryInputAll objectAtIndex:0]	setStringValue:[[dicParameters objectForKey:kUserDefaultShowDebugSN] uppercaseString]];
		
		// if it is garbage sn, make it invisible
		// The garbage sn is for the condition that if we scan three sn, but we only used two sn.
		// We use garbage sn to receive the unused sn
		if ([[dicParameters objectForKey:kUserDefualtGarbageSN] boolValue])
		{
			[[arySNAll objectAtIndex:0] setStringValue:[kUserDefualtGarbageSN uppercaseString]];
			[[arySNAll objectAtIndex:0] setBoundsSize:NSMakeSize(0, 0)];
			[[aryInputAll objectAtIndex:0] setBoundsSize:NSMakeSize(0, 0)];
			[[aryInputAll objectAtIndex:0] setBordered:NO];
			[[aryInputAll objectAtIndex:0] setDrawsBackground:NO];
		}
		[arySNAll removeObjectAtIndex:0];
		[aryInputAll removeObjectAtIndex:0];
	}
	
	for (NSUInteger i = 0; i < [arySNAll count]; i++)
	{
		[[arySNAll objectAtIndex:i] removeFromSuperview];
		[[aryInputAll objectAtIndex:i] removeFromSuperview];
	}
	[self.inputView setFrameSize:NSMakeSize(self.inputView.frame.size.width, 16 + 6 * (5 - [arySNAll count]) + 22 * (6 - [arySNAll count]))];
	[aryInputAll release];
	[arySNAll	release];
}

//=============modify for Clear CB===============
- (void)changeSNManage
{
    NSLog(@"changeSNManage begin");
    NSDictionary	*dicParameters	= [[m_dicMuifa_Plist objectForKey:kUserDefaultSN_Manager]
									   objectForKey:@"SN1"];
    [[m_arrSNLables		objectAtIndex:0] setEnabled:YES];
    [[m_arrSNLables		objectAtIndex:0] setStringValue:[[dicParameters objectForKey:kUserDefaultShowTitle] uppercaseString]];
	
	[[m_arrSNTextFields objectAtIndex:0] setEnabled:YES];
    [[m_arrSNTextFields objectAtIndex:0] setStringValue:[[dicParameters objectForKey:kUserDefaultShowDebugSN] uppercaseString]];
    NSLog(@"changeSNManage end");
}
//=============modify for Clear CB===============

- (void)writeCountIntoSettingFile:(NSDictionary *)dicInfo
{
    NSLog(@"writeCountIntoSettingFile begin");
    NSAutoreleasePool	*pool	= [[NSAutoreleasePool alloc] init];
    @synchronized(g_szMutex_Lock)
    {
        NSMutableDictionary	*dicMuifa_Counter_Plist	= [[NSMutableDictionary alloc]
													   initWithContentsOfFile:kMuifaCounterPlistPath];
        
        NSString	*szCurrentUnit	=[dicInfo objectForKey:@"CurrentUnit"];
        BOOL		bTestResult		= [[dicInfo objectForKey:@"TestResult"] boolValue];
        int			iPassRunCounter	= 0;
        int			iFailRunCounter	= 0;
        int			iHaveRunCounter	= 0;
        
        // get the source dictionary about counter
        NSMutableDictionary	*dicWrite	= [[NSMutableDictionary alloc] init];
		[dicWrite setDictionary:[[dicMuifa_Counter_Plist
								   objectForKey:kUserDefaultCounter]
								 objectForKey:szCurrentUnit]];

        
        // if test result is pass, iPassRunCounter+1; test result is fail, iFailRunCounter+1.
        if (bTestResult)
        {
            iHaveRunCounter	= [[dicWrite objectForKey:kUserDefaultHaveRunCount] intValue] + 1;
            iPassRunCounter	= [[dicWrite objectForKey:kUserDefaultPassCount] intValue] + 1;
            iFailRunCounter	= [[dicWrite objectForKey:kUserDefaultFailCount] intValue];
        }
        else
        {
            iHaveRunCounter = [[dicWrite objectForKey:kUserDefaultHaveRunCount] intValue] + 1;
            iPassRunCounter = [[dicWrite objectForKey:kUserDefaultPassCount] intValue];
            iFailRunCounter = [[dicWrite objectForKey:kUserDefaultFailCount] intValue] + 1;
        }
        
        // update counter dictionary
        [dicWrite setObject:[NSNumber numberWithInt:iHaveRunCounter]
					 forKey:kUserDefaultHaveRunCount];
        [dicWrite setObject:[NSNumber numberWithInt:iPassRunCounter]
					 forKey:kUserDefaultPassCount];
        [dicWrite setObject:[NSNumber numberWithInt:iFailRunCounter]
					 forKey:kUserDefaultFailCount];
		[dicWrite setObject:[NSNumber numberWithInt:1]
					 forKey:kUserDefaultCycleTestTime];
        
        // write to setting file
        NSMutableDictionary	*dicCounter	= [[NSMutableDictionary alloc]
										   initWithDictionary:[dicMuifa_Counter_Plist
															   objectForKey:kUserDefaultCounter]];
    
		[dicCounter setObject:dicWrite forKey:szCurrentUnit];

        [dicMuifa_Counter_Plist setObject:dicCounter
								   forKey:kUserDefaultCounter];
        [dicMuifa_Counter_Plist writeToFile:kMuifaCounterPlistPath
								 atomically:NO];

		[self showCountOnLable:nil];
        [dicCounter release];
        [dicWrite release];
        [dicMuifa_Counter_Plist release];
    }
    [pool drain];
    NSLog(@"writeCountIntoSettingFile end");
}

- (void)showCountOnLable:(NSNotification *)aNote
{
    NSLog(@"showCountOnLable begin");
    @synchronized(g_szMutex_Lock)
    {
        NSMutableDictionary	*dicMuifa_Counter_Plist	= [[NSMutableDictionary alloc]
													   initWithContentsOfFile:kMuifaCounterPlistPath];

        NSDictionary		*dicWrite = [[dicMuifa_Counter_Plist objectForKey:kUserDefaultCounter]
										 objectForKey:m_szCurrentUnit];
        
        m_iRunCount		= [[dicWrite objectForKey:kUserDefaultCycleTestTime] intValue];
        if(0 != m_iRunCount && 1 != m_iRunCount)
        {
            // if cycle test
            int	iPass				= [[[aNote userInfo] objectForKey:@"TotalPassCount"] intValue];
            int	iFail				= [[[aNote userInfo] objectForKey:@"TotalFailCount"] intValue];
            int	iHaveRunCycleCount	= [[[aNote userInfo] objectForKey:@"HaveRunCycleCount"] intValue];
            [lbTotalCount setStringValue:[NSString stringWithFormat:
										  @"LoopTest: %d/%d (P:%d F:%d)",
										  iHaveRunCycleCount, m_iRunCount, iPass, iFail]];
        }
        else
        {
            // if normal test
            NSNumber	*numHaveRunCount	= [dicWrite objectForKey:kUserDefaultHaveRunCount];
            NSNumber	*numPassRunCount	= [dicWrite objectForKey:kUserDefaultPassCount];
            NSNumber	*numFailRunCount	= [dicWrite objectForKey:kUserDefaultFailCount];
            [lbTotalCount setStringValue:[NSString stringWithFormat:
										  @"Count: %@ (P:%@ F:%@)",
										  numHaveRunCount, numPassRunCount, numFailRunCount]];
        }
        [dicMuifa_Counter_Plist release];
    }
    NSLog(@"showCountOnLable end");
}

-(void)setTimeIndicator:(id)iThread
{
    NSLog(@"setTimeIndicator begin");
    NSAutoreleasePool	*pool	= [[NSAutoreleasePool alloc] init];
    unsigned		unitFlags	= (NSHourCalendarUnit
								   | NSMinuteCalendarUnit
								   | NSSecondCalendarUnit);
    NSDate			*dateStart	= [NSDate date];
    NSCalendar		*gregorian	= [[NSCalendar alloc]
								   initWithCalendarIdentifier:NSGregorianCalendar];
    while (m_bRunning)
    {
        NSDate				*dateEnd	= [NSDate date];
        NSDateComponents	*comps		= [gregorian components:unitFlags
												fromDate:dateStart
												  toDate:dateEnd
												 options:1];
        NSInteger	iHour		= [comps hour];
        NSInteger	iMinute		= [comps minute];
        NSInteger	iSecond		= [comps second];
        NSString	*szHour		= [NSString stringWithFormat:@"%d",iHour];
        if (1==[szHour length])
            szHour	= [NSString stringWithFormat:@"0%d", iHour];
        NSString	*szMinute	= [NSString stringWithFormat:@"%d",iMinute];
        if (1==[szMinute length])
            szMinute	= [NSString stringWithFormat:@"0%d", iMinute];
        NSString	*szSecond	= [NSString stringWithFormat:@"%d",iSecond];
        if (1==[szSecond length])
            szSecond	= [NSString stringWithFormat:@"0%d", iSecond];
        
        [lbTotalTime setStringValue:[NSString stringWithFormat:
									 @"Time: %@:%@:%@",
									 szHour, szMinute, szSecond]];
        sleep(1);
    }
    [gregorian release];
    [pool drain];
    NSLog(@"setTimeIndicator end");
}

/*
 * Kyle 2011.12.19
 * method   : Get_Script_Version:
 * abstract : get version of scriptFile
 * 
 */
- (NSString *)Get_Script_Version;
{
    NSLog(@"Get_Script_Version begin");
    // get scriptFileName
    NSString	*scriptFileName	= [[m_dicMuifa_Plist objectForKey:kUserDefaultScriptInfo]
								   objectForKey:kUserDefaultScriptFileName];
    // get scriptFilePath
    NSString	*scriptPath		= [NSString stringWithFormat:
								   @"%@/Contents/Frameworks/FunnyZone.framework/Resources/%@",
								   [[NSBundle mainBundle] bundlePath],scriptFileName];
    // get contents with scriptFilePath
    NSString	*szContents		= [NSString stringWithContentsOfFile:scriptPath
													  encoding:NSUTF8StringEncoding
														 error:nil];
    NSRange		versionRange	= [szContents rangeOfString:@"<plist version=\""];
    if ((NSNotFound != versionRange.location)
		&& (versionRange.length > 0)
		&& ((versionRange.length + versionRange.location) <= [szContents length]))
    {
        szContents	= [szContents substringFromIndex:versionRange.location + versionRange.length];
        NSRange	endRange	= [szContents rangeOfString:@"\">"];
        if ((NSNotFound != endRange.location)
			&& (endRange.length > 0)
			&& ((endRange.length + endRange.location) <= [szContents length]))
        {
            NSString	*szValue	= [szContents substringToIndex:endRange.location];
            if (szValue)
            {
                NSLog(@"Get_Script_Version end");
                return szValue;
            }
        }
    }
    NSLog(@"Get_Script_Version end");
    return @"Unknow version";
}

// reload data when you access to the tabviewitem
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    if(kTag_TableView_FailItems == [tabView indexOfTabViewItem:tabViewItem])
        [self performSelectorOnMainThread:@selector(UpdateUI_Object:)
                               withObject:tvFailInfo waitUntilDone:YES];
    if (kTag_TableView_UartLog == [tabView indexOfTabViewItem:tabViewItem])
        [self performSelectorOnMainThread:@selector(UpdateUI_Object:)
                               withObject:tvUARTInfo waitUntilDone:YES];
    if (kTag_TableView_CSVLog == [tabView indexOfTabViewItem:tabViewItem])
        [self performSelectorOnMainThread:@selector(UpdateUI_Object:)
                               withObject:tvCSVInfo waitUntilDone:YES];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    @synchronized(m_arrFailInfo)
    {
        if (([m_arrFailInfo count] > [tvFailInfo selectedRow]))
        {
			NSAttributedString	*attriStrConsole	= [[m_arrFailInfo objectAtIndex:[tvFailInfo selectedRow]]
													   objectForKey:kFunnyZoneConsoleMessage];
			[textViewFailInfo setSelectedRange:NSMakeRange( 0, [[textViewFailInfo string] length])];
            [textViewFailInfo delete:nil];
			[[textViewFailInfo textStorage] insertAttributedString:attriStrConsole
														   atIndex:0];
            [textViewFailInfo scrollRangeToVisible: NSMakeRange( 0, 0)];
        }
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	switch(aTableView.tag)
	{
		case kTag_TableView_CSVLog:
			@synchronized(m_arrCSVInfo)
			{
				return [m_arrCSVInfo count];
			}
		case kTag_TableView_UartLog:
			@synchronized(m_arrUARTInfo)
			{
				return [m_arrUARTInfo count];
			}
		case kTag_TableView_FailItems:
			@synchronized(m_arrFailInfo)
			{
				return [m_arrFailInfo count];
			}
		default:
			return 0;
	}
}

			- (id)tableView:(NSTableView *)aTableView
  objectValueForTableColumn:(NSTableColumn *)aTableColumn
						row:(int)rowIndex
{
    NSAutoreleasePool	*pool		= [[NSAutoreleasePool alloc] init];
    
    NSMutableArray		*arrCommon	= nil;
	switch(aTableView.tag)
	{
		case kTag_TableView_CSVLog:
			arrCommon = m_arrCSVInfo;
			break;
		case kTag_TableView_UartLog:
			arrCommon = m_arrUARTInfo;
			break;
		case kTag_TableView_FailItems:
			arrCommon = m_arrFailInfo;
			break;
		default:
			NSLog(@"TABLEVIEW ERROR: Can't get the tableview identifier");
			[pool drain];
			return @"";
	}
    
    id	theValue	= @"";
    
    @synchronized(arrCommon)
    {
        if ([arrCommon count] == 0)
            return nil;
        NSParameterAssert(rowIndex >= 0 && rowIndex < [arrCommon count]);
        
        NSString	*identifier	= [aTableColumn identifier];        
        if (nil == identifier)
        {
            NSLog(@"TABLEVIEW ERROR: Nil indentifier at row index: %d", rowIndex);
            [pool drain];
            return @"";
        }
        
        id	theRecord	= [arrCommon objectAtIndex:rowIndex];
        if(theRecord)
        {
			theValue = [theRecord objectForKey:identifier];
		}
        else
        {
            theValue	= @"";
            NSLog(@"TABVIEW EERO: Tableview can't get information at index \"%d\"", rowIndex);
        }
    }
	[pool drain];
	return theValue; 
}


- (void)controlTextDidBeginEditing:(NSNotification *)aNotification
{
    if ([m_arrSNTextFields containsObject:[aNotification object]]) 
    {
        m_iSNNumber	= [m_arrSNTextFields indexOfObject:[aNotification object]];
        NSLog(@"controlTextDidBeginEditing: (sn label: \"%@\") (object address: %@) ",
			  [[m_arrSNLables objectAtIndex:m_iSNNumber] stringValue], [aNotification object]);
    }
}

// set and open a alert panel to notice operator
- (void)changeScriptFile:(NSString *)szNewScriptFile
		 InformativeText:(NSString *)szInformativeText
				TestOnce:(BOOL)bTestOnce
{
    NSLog(@"changeScriptFile begin");
    NSAlert	*alert	= [[[NSAlert alloc] init] autorelease];
    //Add by Betty on 2012.05.08 If bAutoRunInit is YES, don't show "NO" button in the alert panel. else show "NO" button.
    BOOL	bAutoRunInit	= [[[kFZ_UserDefaults objectForKey:kUserDefaultModeSetting]
								objectForKey:kUserDefaultAutoInitFixture] boolValue];
    // end by betty
    [alert addButtonWithTitle:@"确定(YES)"];
    m_bTestOnceScript	= bTestOnce;
    if (!bAutoRunInit) 
        [alert addButtonWithTitle:@"取消(NO)"];
    
    [alert setMessageText:[NSString stringWithFormat:
						   @"警告(Warning)(slot:%@)",
						   m_szCurrentUnit]];
    [alert setInformativeText:szInformativeText];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:m_windowUI
					  modalDelegate:self
					 didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
						contextInfo:[szNewScriptFile copy]];
    NSLog(@"changeScriptFile end");
}

- (void)alertDidEnd:(NSAlert *)alert
		 returnCode:(NSInteger)returnCode
		contextInfo:(void *)contextInfo
{
    
    if (returnCode == NSAlertFirstButtonReturn) 
    {
        // if click YES button, parse and load test once script file
        //=============modify for Clear CB===============
        
        //modify by lucy for Clear CB
        if ([(NSString *)contextInfo isEqualTo:@"FATP_CB Erase.plist"] )
            [self changeSNManage];
        //=============modify for Clear CB=============== 
        //modified by lucy for test once or not once
        [self parseAndLoadScriptFile:contextInfo
						OnlyTestOnce:m_bTestOnceScript];
        BOOL	bNoSnRuleCheck	= [[[[kFZ_UserDefaults objectForKey:kUserDefaultScriptInfo]
									 objectForKey:kUserDefaultTestOnceScriptName]
									objectForKey:@"NOSNRuleCheck"] boolValue];
        if (bNoSnRuleCheck && g_bRELLinePick)
            [inputView setHidden:YES];
        else
        {
            [inputView setHidden:NO];
            [[m_arrSNTextFields objectAtIndex:0] becomeFirstResponder];
        }
    }
}

/*
 * Kyle 2012.02.15
 * abstract   : get kingds of SN by script , and memory 
 */
- (void)showScanSN:(NSNotification *)notification
{
    bCheckScanSN					= NO;
    arrayTxt						= [NSMutableArray arrayWithArray:nil];
    arrayLable						= [NSMutableArray arrayWithArray:nil];
    arraySize						= [NSMutableArray arrayWithArray:nil];
    NSDictionary	*dicUserInfo	= [notification userInfo];
    NSArray	*arrayKeys				= [dicUserInfo objectForKey:@"dicScanSN"];
    NSArray	*arrayObjects			= [[panelSN contentView] subviews];
    
    // Clear conttrol info 
    for (int i = 0; i < [arrayObjects count]; i++) 
        if (1 == [[arrayObjects objectAtIndex:i] tag]) 
            [[arrayObjects objectAtIndex:i] removeFromSuperview];
    
    // creat textField by notification userinfo
    for (int i = 0, x = 30 + 40*[arrayKeys count]; i < [arrayKeys count]; i++) 
    {
        // set panel height
        NSRect	rectFrame		= [panelSN frame];
        rectFrame.size.height	= 40*[arrayKeys count] + 120;
        [panelSN setFrame:rectFrame display:YES];
        
        NSString	*szKey		= [[[arrayKeys objectAtIndex:i] allKeys] objectAtIndex:0];
        NSTextField	*txtName	= [[NSTextField alloc]
								   initWithFrame:NSMakeRect(30, (float)x, 80, 30)];
        [txtName setStringValue:szKey];
        [txtName setBordered:NO];
        [txtName setEditable:NO];
        [txtName setBackgroundColor:[panelSN backgroundColor]];
        [txtName setTag:1];
        NSTextField	*txtSN	= [[NSTextField alloc]
							   initWithFrame:NSMakeRect(130, (float)(x+5), 230, 30)];
        [txtSN setTag:1];
        [arrayTxt addObject:txtSN];
        [arrayLable addObject:[txtName stringValue]];
        [arraySize addObject:[[arrayKeys objectAtIndex:i] objectForKey:szKey]];
        [txtSN setDelegate:self];
        [txtSN setFocusRingType:NSFocusRingTypeDefault];
        
        x	-= 40;
        [[panelSN contentView] addSubview:txtName];
        [[panelSN contentView] addSubview:txtSN];
        
        [txtName release];
        [txtSN release];
    }
    [NSApp runModalForWindow:panelSN];
}


- (IBAction)checkMPNRegion:(id)sender 
{
    NSMutableDictionary	*muDic	= [[NSMutableDictionary alloc] init];
    for (int i =0;i < [arrayTxt count]; i++) 
    {
        NSTextField	*txtSN	= [arrayTxt objectAtIndex:i];
        NSString	*szTxt	= [txtSN stringValue];
        int			iLength	= [szTxt length];
        if ([szTxt isEqualToString:@""]) 
        {
            [muDic release];
            [NSApp stopModal];
            [panelSN orderOut:nil];
            return;
        }
        else if ((0 != [arraySize objectAtIndex:i])
				 && (iLength != [[arraySize objectAtIndex:i] intValue]))
        {
            NSString	*szName	= [arrayLable objectAtIndex:i];
            int			iTemp	= [[arraySize objectAtIndex:i] intValue];
            NSRunAlertPanel(@"错误(Error)",
							[NSString stringWithFormat:
							 @"%@长度不匹配，长度应该为%d。(%@ lengh error ! must be %d)",
							 szName,iTemp,szName,iTemp],
							@"确认(OK)", nil, nil);
            
            [muDic release];
            [NSApp stopModal];
            [panelSN orderOut:nil];
            return;
        }
        
        [muDic setObject:[[arrayTxt objectAtIndex:i] stringValue]
				  forKey:[arrayLable objectAtIndex:i]];
        if (i < [arrayTxt count]-1)
            [panelSN makeFirstResponder:[arrayTxt objectAtIndex:i+1]];
    }
    [testProgress.memoryValues setValuesForKeysWithDictionary:
	 [NSDictionary dictionaryWithDictionary:muDic]];
    [testProgress.memoryValues setObject:@"1"
									   forKey:@"ScanSNFlag"];
    [muDic release];
    [NSApp stopModal];
    [panelSN orderOut:nil];
}

-(NSAttributedString *)getAttributeString:(NSString *)szName
									Color:(NSColor *)color
{
	NSFont					*font		= [NSFont fontWithName:@"Charcoal CY" size:15];
    NSMutableParagraphStyle	*paraStyle	= [[NSMutableParagraphStyle alloc] init];
    [paraStyle setAlignment:NSCenterTextAlignment];
    NSDictionary		*dicAttribut	= [NSDictionary dictionaryWithObjectsAndKeys:
										   font,		NSFontAttributeName,
										   color,		NSForegroundColorAttributeName,
										   paraStyle,	NSParagraphStyleAttributeName, nil];
	[paraStyle release];
    return [[[NSAttributedString alloc] initWithString:szName
											attributes:dicAttribut] autorelease];
}


// For AE station to choose unit's color
- (void)getUnitColorNoti :(NSNotification   *)noti
{
    [NSApp      runModalForWindow:m_windowColorChoiceView];
}

- (IBAction)ColorChooseEnter:(id)sender
{
    NSString    *strUnitColor   = [[m_mtrPanal   selectedCell]   title];
    [testProgress.memoryValues setObject:strUnitColor forKey:@"UNITCOLOR"];
    [NSApp endSheet:m_windowColorChoiceView];
    [m_windowColorChoiceView      orderOut:nil];
    NSNotificationCenter        *nc = [NSNotificationCenter  defaultCenter];
    [nc postNotificationName:BNRColorChoiceFinish
                      object:self
                    userInfo:nil];
}


-(void)monitorAEFixtureStartWithUartPath:(NSString*)strPath
								andRegex:(NSString*)strRegex
{
    NSLog(@"Start function monitorAEFixtureStartWithUartPath!");
    PEGA_ATS_UART	*uartFixture	= [[PEGA_ATS_UART alloc] init_Uart];
    [uartFixture openPort:strPath
                baudeRate:115200
                  dataBit:8
                   parity:@"NONE"
                 stopBits:1
                endSymbol:@"@"];
    // Read until get correct response.
    while(![m_strAEReadBuffer matches:strRegex])
    {
        // Buffered read.
        NSMutableString	*strSingleRead	= [NSMutableString new];
        [uartFixture Read_UartData:strSingleRead
                   TerminateSymbol:[NSArray arrayWithObject:@"@"]
                         MatchType:1
                      IntervalTime:0.1
                           TimeOut:5];
        [m_strAEReadBuffer appendString:strSingleRead];
        NSLog(@"Read data [%@] from port and append to the string m_strAEReadBuffer [%@].", strSingleRead, m_strAEReadBuffer);
        [strSingleRead release];	strSingleRead	= nil;
        sleep(1);
     }
    // Get the correct response from buffer.
    
	NSString	*strSingleResponse	= [m_strAEReadBuffer subByRegex:strRegex
													    name:nil
                                                        error:nil];
    if ([strSingleResponse length])
    {
        NSLog(@"Get the data [%@] by the regex [%@] successfully!", strSingleResponse, strRegex);
        [uartFixture Clear_UartBuff:kUart_ClearInterval
                            TimeOut:kUart_CommandTimeOut
                            readOut:nil];
        [uartFixture Write_UartCommand:@"StartTransfers;"
                             PackedNum:1
                              Interval:0
                                 IsHex:NO];
        NSLog(@"Write the command [StartTransfers;]!");
        NSMutableString *strValue = [NSMutableString new];
        [uartFixture Read_UartData:strValue
                   TerminateSymbol:[NSArray arrayWithObject:@"@"]
                         MatchType:1
                      IntervalTime:0.01
                           TimeOut:5];
        if ([strValue contains:@"Accept"])
        {
            NSLog(@"Get the data [%@] that contains string [Accept]!", strValue);
            [uartFixture Read_UartData:strValue
                       TerminateSymbol:[NSArray arrayWithObject:@"@"]
                             MatchType:1
                          IntervalTime:0.01
                               TimeOut:5];
            [testProgress.memoryValues setObject:strValue forKey:@"AE response"];
            NSLog(@"Save the data [%@] as the key [AE response]", strValue);
            [uartFixture Write_UartCommand:@"OK;"
                                 PackedNum:1
                                  Interval:0
                                     IsHex:NO];
            NSLog(@"Write the command [OK;]!");
        }
		[strValue release];	strValue	= nil;
    }
    [uartFixture Close_Uart];
    [uartFixture release];	uartFixture	= nil;
    
	[m_strAEReadBuffer setString:[m_strAEReadBuffer subFrom:strSingleResponse include:NO]];
    NSLog(@"Clear the string m_strAEReadBuffer to [%@]", m_strAEReadBuffer);
	// Save this single response to memory values.
	//[testProgress.memoryValues setObject:strSingleResponse forKey:@"Response"];
}
-(void)startStationChoice:(NSNotification *)note
{
	[m_windowStationChoice setBackgroundColor:m_colorForUnit];
	[NSApp runModalForWindow:m_windowStationChoice];
}
-(void)clickedStationChoiceConfirm:(NSButton *)sender
{
	@synchronized(testProgress.memoryValues)
	{
		[testProgress.memoryValues setObject:[m_matrixStationChoice.selectedCell title]
										   forKey:@"SELECTED_STATION"];
	}
	[NSApp stopModalWithCode:NSOKButton];
	[m_windowStationChoice orderOut:nil];
}

- (IBAction)ChangeSelectedBriefView:(id)sender
{
	[sender setTitle:m_szCurrentUnit];
	[self.templateDelegate linkToTabViewItem:sender];
}

// This method is used to response CSV double click event, it will popup a full screen window to fouse on one item debug.
// Added by Lorky 2013-11-21
- (void)LoadDebugInformation
{	
	if ([m_arrCSVInfo count] <= [tvCSVInfo selectedRow])
		return;
	
	NSDictionary * dictContentsSelected = [m_arrCSVInfo objectAtIndex:[tvCSVInfo selectedRow]];
	// dwc can't be released because once it released, the debug window will disappear
	DebugWindowController *dwc = [[DebugWindowController alloc] initWithWindowNibName:@"DebugWindowController"];
	dwc.informations = dictContentsSelected;
	[dwc showWindow:self];
}

- (void)LoadFailureDebugInformation
{
	if ([m_arrFailInfo count] <= [tvFailInfo selectedRow])
		return;
	
	NSDictionary * dictContentsSelected = [m_arrFailInfo objectAtIndex:[tvFailInfo selectedRow]];
	// dwc can't be released because once it released, the debug window will disappear
	DebugWindowController *dwc = [[DebugWindowController alloc] initWithWindowNibName:@"DebugWindowController"];
	dwc.informations = dictContentsSelected;
	[dwc showWindow:self];
}

- (BOOL)tabView:(NSTabView *)tabView shouldSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	/*!
	 * Modified by Lorky on 2014-06-17
	 * For PVT/MP stage, that's not allowed to choose other tabs during PVT/MP stage. Only DetailTab should have this modification
	 */
	if (m_bRunningWithUARTTab)
	{
		// if the application is running and the tab view identifier is DetailTab
		// It can't be change the tab view and start to reflash the uart log tab.
		if (m_bRunning && [[tabView identifier] isEqualToString:@"DetailTab"])
		{
			return NO;
		}
		else
			return YES;
	}
	else
		return YES;
}

//For SMT-QT 2UP
//All Template Have Started
- (void)TEPAllTemplateHaveStarted:(NSNotification *)aNote
{
    m_bAllStarted   = YES;
}
//All Template Have Finished
- (void)TEPAllTemplateHaveFinished:(NSNotification *)aNote
{
    m_bAllEnded     = YES;
}
//Loop Test For All Template Have Finished
- (void)TEPAllTemplateLoopFinished:(NSNotification *)aNote
{
    m_bAllLoop     = YES;
}
@end
