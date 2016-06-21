//
//  Template.m
//  Muifa
//
//  Created by Gordon Liu on 9/22/11.
//  Copyright 2011 PEGATRON. All rights reserved.
//

#import "Template.h"


NSString *BNRCounterForNFMUNotification = @"CounterForNFMU";
NSString *BNRAllStartButtonPressedNotification = @"AllStartButtonPressed";
NSString *BNRYoungBrotherStartButtonUnpressedNotification = @"YoungBrotherStartButtonUnpressed";
NSString *BNRMoniterGrapeFixtureSenserInNotification = @"MoniterGrapeFixtureSenserIn";
NSString * const BNRStartTestOnePatternNotification = @"StartTestOnePattern";
NSString * const BNRDrawerOKClickedNotification = @"DrawerOKClicked";


NSString *g_szMutex_Lock = @"MutexLock";
int g_iPassForNFMU = 0;
int g_iFailForNFMU = 0;
int g_iCycleCountForNFMU = 0;
BOOL g_bBrotherTestReady = NO;

@implementation Template
extern NSString *BNRPostTestInfoNotification;

// box view object
@synthesize viewIndicator;

// main view object
@synthesize viewMain;

// Indicator view object
@synthesize viewInfo;

// SN Labels view object
@synthesize viewSNLabels;

// Buttons view object
@synthesize viewButtons;

// check box object
@synthesize viewCheckBox;

@synthesize btnCheckBox;

// color label object
@synthesize viewColorLabel;
@synthesize lbColorLabel;

@synthesize viewJudgeButton;

// sn text field object
@synthesize tfSN1;
@synthesize tfSN2;
@synthesize tfSN3;
@synthesize tfSN4;
@synthesize tfSN5;
@synthesize tfSN6;
@synthesize btnStart;
@synthesize btnAntsFAIL;
@synthesize btnAbort;

// GroundHogInfo dictionary
@synthesize m_dictGroundHogInfo;

// Bool value indicate test state 
@synthesize m_bStopTest;

@synthesize m_bNoResponse;//Leehua

//chao
@synthesize m_strSerialPort;
@synthesize m_arrSerialPort;
@synthesize viewChooseCable;
@synthesize btnChooseCable;
@synthesize viewVol;
@synthesize tfShowResult;
// for prox cal
@synthesize m_szSerialPortPath;
- (id)initWithParametric:(NSDictionary *)dicPara
{
    self = [super init];
    if (self) 
    {
        //add by yaya
        m_bGrapeSensorIN = NO;
        
        m_bTestPass = YES;
        m_bTestOnceScript = NO;
        m_bStopTest = YES;
        //m_bManualClickTest = NO;
        testProgress = [[TestProgress alloc] init];
        m_queue = [[NSOperationQueue alloc] init];
        m_dicSNsFromUI = [[NSMutableDictionary alloc] init];
        
        // get parameter from MuifaAppDelegate.h
        m_dicParaFromMuifa = [dicPara retain];
        m_dicMuifa_Plist = [[NSDictionary dictionaryWithContentsOfFile:kMuifaPlistPath] retain];
        m_dicGHInfo = [dicPara objectForKey:@"GHInfo"];
        [testProgress.m_dicMemoryValues setDictionary:m_dicGHInfo];
        m_dicPorts = [[NSMutableDictionary alloc] initWithDictionary:[m_dicParaFromMuifa objectForKey:kTransferKey_Ports]];
        //for Prox cal
        bool    bIS_1_to_N  =   [[[m_dicMuifa_Plist objectForKey:@"ModeSetting"] objectForKey:@"IS_1_to_N"] boolValue];
        if(bIS_1_to_N)
        {
            m_szSerialPortPath  =   [[[[m_dicPorts objectForKey:@"MOBILE"]objectAtIndex:0] objectForKey:@"Slot1"] retain];
        }
        else
        {
            m_szSerialPortPath = [[[m_dicPorts objectForKey:@"MOBILE"] objectAtIndex:0] retain];
        }
        //
        m_colorForUnit = [[[m_dicParaFromMuifa objectForKey:kTransferKey_UnitColor] objectForKey:@"NSColor"] retain];
        [testProgress.m_dicMemoryValues setObject:[[m_dicParaFromMuifa objectForKey:kTransferKey_UnitColor] objectForKey:@"StringColor"] forKey:kTransferKey_UnitColor];
        [testProgress.m_dicMemoryValues setObject:m_colorForUnit forKey:kPD_AMIOK_PanelColor];
        
        [testProgress.m_dicMemoryValues setObject:m_dicMuifa_Plist forKey:kPD_Muifa_Plist];

        // load nib file
        [NSBundle loadNibNamed:@"Template" owner:self];
        m_arrCSVInfo = [[NSMutableArray alloc] init];
        m_arrUARTInfo = [[NSMutableArray alloc] init];
        m_arrFailInfo = [[NSMutableArray alloc] init];
        m_arrDrawerFailItemsInfo = [[NSMutableArray alloc] init];
        m_arrDrawerCheckBoxInfo = [[NSMutableArray alloc] init];
        m_dicDrawerFailItmes = [[NSMutableDictionary alloc] init];
        m_arrSerialPort = [[NSMutableArray alloc] init];
        m_strSerialPort = [[NSMutableString alloc] init];
        
        // set sn lables and text fields
        m_arrSNLables = [NSArray arrayWithObjects:lbSN1,lbSN2,lbSN3,lbSN4,lbSN5,lbSN6, nil];
        m_arrSNTextFields = [NSArray arrayWithObjects:tfSN1,tfSN2,tfSN3,tfSN4,tfSN5,tfSN6, nil];
        [m_arrSNLables retain];
        [m_arrSNTextFields retain];
        
        // set data source and delegete
        [tvCSVInfo setDelegate:self];
        [tvCSVInfo setDataSource:self]; 
        [tvUARTInfo setDelegate:self];
        [tvUARTInfo setDataSource:self];
        [tvFailInfo setDelegate:self];
        [tvFailInfo setDataSource:self];
        [tabTestInfo setDelegate:self];
        // add for table view in drawerAnts
        [tvDrawer setDelegate:self];
        [tvDrawer setDataSource:self];
        
        //torres 2011.29
        //[tfShowResult setDelegate:self];
        //[tvDrawer setDataSource:self];
        [tfShowResult setEnabled:NO];
        m_szMagnetResult = [[NSMutableString alloc] initWithString:@""];
        
        
        m_iSNNumber = 0;
        m_szTestScriptFilePath =[[[m_dicMuifa_Plist objectForKey:kUserDefaultScriptInfo] objectForKey:kUserDefaultScriptFileName] retain];
        
        //2012.03.02 Leehua
        if ([[[m_dicMuifa_Plist objectForKey:kUserDefaultModeSetting] objectForKey:kUserDefaultManualStartTest] boolValue])
        {
            [btnStart setKeyEquivalent:@""];
        }
        
        m_bNoResponse = NO;//Leehua
    }
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self selector:@selector(unCheckbox:) name:@"BNRControlCableNotification" object:nil];
    
    return self;
}

- (void)dealloc
{
    if (testProgress) 
    {
        [testProgress release];
    }
    //Leehua
    if (m_dicSNsFromUI) 
    {
        [m_dicSNsFromUI release];
    }
    [m_dicParaFromMuifa release];
    [m_dicMuifa_Plist release];
    if (m_szSerialPortPath) 
    {
        [m_szSerialPortPath release];
    }
    [m_colorForUnit release];
    [m_arrSNLables release];
    [m_arrSNTextFields release];
    [m_arrObjTemplate release];
    [m_szCurrentMode release];
    [m_szCurrentUnit release];
    [m_szTestScriptFilePath release];
    
    if (m_arrScriptFile)
    {
        [m_arrScriptFile release];
    }
    [m_arrTestOnceScript release];
    if (m_szMainSN) [m_szMainSN release];
    
    [m_szScriptName release];
    [m_queue release];
    [m_arrCSVInfo release];
    [m_arrUARTInfo release];
    [m_arrFailInfo release];
    [m_arrDrawerFailItemsInfo release];
    [m_arrDrawerCheckBoxInfo release];
    [m_dicDrawerFailItmes release];
    [m_dicPorts release];
    [m_szUIVersion release];
    [m_szScriptVersion release];
    [m_strSerialPort release];
    [m_arrSerialPort release];
    
    [m_szMagnetResult release];//torres 2012.11.29
    [super dealloc];

}

- (void)transferTemplateObject:(NSArray *)arrTemplateObj
{
    m_arrObjTemplate = [NSArray arrayWithArray:arrTemplateObj];
    [m_arrObjTemplate retain];

}

// funciton for auto detect serial port for Auto detect and run test           -- Begin --
- (void)MonitorSerialPortPlugIn
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSMutableString * szSNInUnit= [[NSMutableString alloc] init];
    bool    bIS_1_to_N  =   [[[m_dicMuifa_Plist objectForKey:@"ModeSetting"] objectForKey:@"IS_1_to_N"] boolValue];
    if(bIS_1_to_N)
    {
        if(m_szSerialPortPath) [m_szSerialPortPath release];
        m_szSerialPortPath  =   [[[[m_dicPorts objectForKey:@"MOBILE"]objectAtIndex:0] objectForKey:@"Slot1"] retain];
    }
    NSLog(@" monitorSerialPortPlugInWithUartPath begin");
    [testProgress monitorSerialPortPlugInWithUartPath:m_szSerialPortPath withOutputSN:szSNInUnit];
    NSLog(@" monitorSerialPortPlugInWithUartPath end");
    
    [lbUnitMark setStringValue:[NSString stringWithFormat:@"[%@]%@", m_szCurrentUnit, szSNInUnit]];
    [NSThread detachNewThreadSelector:@selector(startTest:) toTarget:self withObject:nil];
    //[self startTest:nil];
    [szSNInUnit release];
    [pool release];
}

- (void)MonitorSerialPortPlugOut
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    if (nil==testProgress)
    {
        testProgress=[[TestProgress alloc] init];
       if (m_bTestOnceScript)
        {
            // once test, do once test script
            testProgress.arrayScript = m_arrTestOnceScript;
        }
        else
        {
            // not once test, do the default test script
            testProgress.arrayScript = m_arrScriptFile;
        }
        testProgress.ScriptName = m_szScriptName;
        [testProgress.m_dicMemoryValues setDictionary:m_dicGHInfo];
        [testProgress.m_dicMemoryValues setObject:[[m_dicParaFromMuifa objectForKey:kTransferKey_UnitColor] objectForKey:@"StringColor"] forKey:kTransferKey_UnitColor];
        [testProgress.m_dicMemoryValues setObject:m_colorForUnit forKey:kPD_AMIOK_PanelColor];
        [testProgress.m_dicMemoryValues setObject:m_dicMuifa_Plist forKey:kPD_Muifa_Plist];
    }
    
    NSLog(@" monitorSerialPortPlugOutWithUartPath begin");
    [testProgress monitorSerialPortPlugOutWithUartPath:m_szSerialPortPath];
    NSLog(@" monitorSerialPortPlugOutWithUartPath end");

    // reset lable when plug out
    [lbPercentageNumber setStringValue:@"0%"];
    [levelIndicator setFloatValue:0.0f];
    [lbResultLabel setStringValue:@"READY"];
    [lbResultLabel setBackgroundColor:[NSColor orangeColor]];
    [lbUnitMark setStringValue:m_szCurrentUnit];
    // NSLog(@" MonitorSerialPortPlugOut end");
    [NSThread detachNewThreadSelector:@selector(MonitorSerialPortPlugIn) toTarget:self withObject:nil];
    [pool release];
}
// funciton for auto detect serial port for auto detect and run test           -- End --

- (IBAction)startTest:(NSButton *)sender
{      
    BOOL bBrotherTest = [[[[m_dicMuifa_Plist objectForKey:kUserDefaultModeSetting] objectForKey:@"BROTHER"] objectForKey:@"BrotherTest"] boolValue];
    if (bBrotherTest) 
    {
        NSFileManager *fileManger = [NSFileManager defaultManager];
        if (([fileManger fileExistsAtPath:kFxitureControlPlistPath])&&(!m_strControlCable))
        {
            NSDictionary *dicFixtureControl = [[NSDictionary alloc] initWithContentsOfFile:kFxitureControlPlistPath];
            m_strControlCable = [[NSString stringWithString:[dicFixtureControl objectForKey:@"FIXTURENUMBER"]] copy];
            [dicFixtureControl release];
        }
        if ([m_strControlCable isEqualToString:@"NONE"]||![fileManger fileExistsAtPath:kFxitureControlPlistPath]) 
        {
            NSRunAlertPanel(@"警告(Warning)", @"請重新選擇治具控制線之後再進行測試!(Please reset Fixture control cable on UI!)", @"YES", nil, nil);
            return;
        }
    }
    m_bNoResponse = NO;//Leehua
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(MonitorsensorhaveIn:) name:BNRMoniterGrapeFixtureSenserInNotification object:nil];
    
    NSArray *arrSNArrangement = [[m_dicMuifa_Plist objectForKey:kUserDefaultSN_Manager] objectForKey:kUserDefaultSN_Arrangement];

    // if the test is auto detect and run, we don't need to check the sn rule
    if (![[[m_dicMuifa_Plist objectForKey:kUserDefaultModeSetting] objectForKey:kUserDefaultAutoDetectAndRun] boolValue] && (nil != arrSNArrangement) && (0 != [arrSNArrangement count])/* && !m_bManualClickTest*/)
    { 
        BOOL bCheckAboveSNRule = NO;
        
        // get UI window object
        m_windowUI = [[[viewSNLabels superview] superview] window];
        
        NSLog(@"startTest: check sn rule begin");
        bCheckAboveSNRule = [self checkAboveSNRule];        // check the sn rule above the focus
        NSLog(@"startTest; check sn rule end");
        
        if (!bCheckAboveSNRule) 
        {
            // if check rule fail, return out of startTest funtion
            return;
        }
        else
        {
            //=======start: add for grape-1 , if scan sn repeat , we will pop up a windows remind OP re-scan SN.=======
            BOOL bBrotherTest = [[[[m_dicMuifa_Plist objectForKey:kUserDefaultModeSetting] objectForKey:@"BROTHER"] objectForKey:@"BrotherTest"] boolValue];
            if (bBrotherTest)
            {
                NSLog(@"start check the SN repeat");
                Template *objTem;
                NSMutableArray *m_arrGrapeAllSNValue = [[NSMutableArray alloc] init];
                NSMutableArray *arrObjTemplate = [[NSMutableArray alloc] initWithArray:m_arrObjTemplate];
                if ([arrObjTemplate containsObject:self])
                {
                    NSString *szCurrentSN = [[[m_arrSNTextFields objectAtIndex:0] stringValue] uppercaseString];
                    NSLog(@"the current SN : %@",szCurrentSN);
                    [arrObjTemplate removeObject:self];
                    
                    for (NSInteger k = 0; k < [arrObjTemplate count]; k++) 
                    {
                        objTem = [arrObjTemplate objectAtIndex:k];
                        [m_arrGrapeAllSNValue addObject:[objTem.tfSN1 stringValue]];
                        NSLog(@"All SN Value : %@",m_arrGrapeAllSNValue);
                    }
                    
                    if ([m_arrGrapeAllSNValue containsObject:szCurrentSN])
                    {
                        NSString *szAlert = [NSString stringWithFormat:@"請重新刷入SN, 當前的SN: %@ 已重複刷入了。(You have scanned the same SN with previous slots.Please scan SN again)",szCurrentSN,szCurrentSN];
                        NSRunAlertPanel(@"警告(Warning)", szAlert, @"确认(OK)", nil, nil);
                        [[m_arrSNTextFields objectAtIndex:0] setStringValue:@""];
                        [m_arrGrapeAllSNValue release];
                        [arrObjTemplate release];
                        return;
                    }
                }
                [m_arrGrapeAllSNValue release];
                [arrObjTemplate release];
            }
            //=======end: add for grape-1 , if scan sn repeat , we will pop up a windows remind OP re-scan SN.=======
            
            if (nil == arrSNArrangement || 0 == [arrSNArrangement count] || ![self GetSNRuleCheckByPlist])
            {
                if (m_dicSNsFromUI)
                {
                    [m_dicSNsFromUI release];
                    m_dicSNsFromUI = nil;
                }
            }
            else
            {
                if (m_iSNNumber+1 != [arrSNArrangement count]) 
                {
                    [m_windowUI makeFirstResponder:[m_arrSNTextFields objectAtIndex:++m_iSNNumber]];
                    NSLog(@"startTest: set next focus to sn id(%d)", m_iSNNumber);
                    return;     // if check rule pass and the sn isn't the last sn, return and set focus to the next sn text field

                }
                else
                {
                    // if it all sn check pass, get sn KEY_VALUE from UI
                    m_szMainSN = @"";
                    for (int i = 0; i < [arrSNArrangement count]; i++)
                    {
                        // get sn from UI
                        NSString *szSNKey = [[[m_arrSNLables objectAtIndex:i] stringValue] uppercaseString];
                        NSString *szSNValue = [[[m_arrSNTextFields objectAtIndex:i] stringValue] uppercaseString];
                        
                        // if it is garbage sn, don't add sn into m_dicSNsFromUI
                        if ([szSNKey isEqualToString:kUserDefualtGarbageSN])
                        {
                            NSLog(@"startTest: %@ = \"%@\"", szSNKey, szSNValue);
                            continue;
                        }
                        NSRange range = [szSNKey rangeOfString:@"*"];
                        if ((NSNotFound != range.location) && (range.length > 0) && ((range.length + range.location) <= [szSNKey length]))
                        {
                            if(m_szMainSN)[m_szMainSN release];
                            m_szMainSN = [NSString stringWithString:szSNValue];
                            [m_szMainSN retain];
                            szSNKey = [szSNKey stringByReplacingOccurrencesOfString:@"*" withString:@""];
                        }
                        [m_dicSNsFromUI setObject:szSNValue forKey:szSNKey];
                    }
                    //[m_dicSNsFromUI retain];
                }
            }
        }
        
        // for MFMU to jump focus form one sn group to another group
        BOOL bret = NO;
        Template *objTemplate;
        if ([m_arrObjTemplate containsObject:self])
        {
            // set default template
            objTemplate = [m_arrObjTemplate objectAtIndex:0];
            int iObjNum;
            if (self == [m_arrObjTemplate lastObject])
            {
                // if this class is the last template on UI, set the focus to the first template sn group as default
                iObjNum = 0;
            }
            else
            {
                // if the template is not the last template
                iObjNum = [m_arrObjTemplate indexOfObject:self] + 1;
            }
            
            
            // for loop the rest templates and find one template which can be used
            for (; iObjNum < [m_arrObjTemplate count]; iObjNum++)
            {
                objTemplate = [m_arrObjTemplate objectAtIndex:iObjNum];
                if ([objTemplate.btnStart isEnabled])
                {
                    // if the template can be used, break the for loop.
                    break;
                }
                else
                {
                    // set default template
                    objTemplate = self;
                }
            }
            
            // if all the template have scan the sn, then make first responder to the first templete. 
            if (objTemplate == self) 
            {
                int index;
                for (Template *template0 in m_arrObjTemplate) 
                {
                    if ([template0.btnCheckBox state]==NSOnState) 
                    {
                        index = [m_arrObjTemplate indexOfObject:template0];
                        break;
                    }
                }
                objTemplate = [m_arrObjTemplate objectAtIndex:index];
                [objTemplate.tfSN1 setEditable:YES];
                bret = YES;
            }

            // jump the focus to the other sn group
            [m_windowUI makeFirstResponder:objTemplate.tfSN1];
            
            if (bret) 
            {
                if (![objTemplate.btnStart isEnabled])
                {
                    [objTemplate.tfSN1 setEditable:NO];
                }
            }
            
        }
        /*if ([[[m_dicMuifa_Plist objectForKey:kUserDefaultModeSetting] objectForKey:kUserDefaultManualStartTest] boolValue])
        {
            m_bManualClickTest = YES;
            return;
        }*/
    }
    
    // open a thread to start to test unit
    [NSThread detachNewThreadSelector:@selector(startSingleTest:) toTarget:self withObject:nil];
}

- (BOOL)checkAboveSNRule
{
    BOOL bRet = YES;

    if (![self GetSNRuleCheckByPlist]) 
    {
        return bRet;
    }
    NSDictionary *dicSNManage = [m_dicMuifa_Plist objectForKey:kUserDefaultSN_Manager];
    //=============modify for Clear CB===============
    NSArray *arrSNArrangement;
    NSDictionary *dicTestOnceScript = [[kFZ_UserDefaults objectForKey:kUserDefaultScriptInfo] objectForKey:kUserDefaultTestOnceScriptName];
    NSString *onceScriptName = [[dicTestOnceScript objectForKey:@"FATP_CB_PLIST"]objectForKey:@"PlistFile"];
    
    if ([[onceScriptName uppercaseString] isEqualToString:@"FATP_CB ERASE.PLIST"]&&[[onceScriptName uppercaseString] isEqualToString:[[NSString stringWithFormat:@"%@.PLIST",m_szScriptName] uppercaseString]]) 
    {
        arrSNArrangement = [NSArray arrayWithObject:@"SN1"];
    }
    else
    {
        
        arrSNArrangement = [dicSNManage objectForKey:kUserDefaultSN_Arrangement];
    }
    //=============modify for Clear CB===============
    if (nil != arrSNArrangement) 
    {
        int iCheckNumber = m_iSNNumber;
        NSLog(@"checkAboveSNRule: check sn numbers = %d", iCheckNumber+1);
        for (int i = 0; i <= iCheckNumber; i++)
        {
            NSLog(@"checkAboveSNRule: check sn label id(%d)", i);
            NSString *szSNKey = [[[m_arrSNLables objectAtIndex:i] stringValue] uppercaseString];
            NSString *szSNValue = [[[m_arrSNTextFields objectAtIndex:i] stringValue] uppercaseString];
            // basic judge
            if ([szSNValue isEqualToString:@""])
            {
                if (bRet)
                {
                    // set the focus to the first empty sn lable
                    m_iSNNumber = i;
                    [m_windowUI makeFirstResponder:[m_arrSNTextFields objectAtIndex:i]];
                    NSLog(@"checkAboveSNRule: the first empty SN id(%d)", i);
                }
                bRet = NO;
                NSString *szRunAlertTitle = [NSString stringWithFormat:@"错误(Error)(slot:%@)", m_szCurrentUnit];
                NSRunAlertPanel(szRunAlertTitle, @"%@长度不匹配，不能为空。(%@ can't be empty)", @"确定(OK)", nil, nil, szSNKey,szSNKey);
                continue;            
            }
            
            // check sn rule
            NSDictionary *dicSNInfomation = [dicSNManage objectForKey:[arrSNArrangement objectAtIndex:i]];
            BOOL bSNNeedCheckRule = [[dicSNInfomation objectForKey:kUserDefaultNeedJudgeSn] boolValue];
            if (bSNNeedCheckRule)
            {
                // check sn rule
                // length
                int iSNLength = [[dicSNInfomation objectForKey:kUserDefaultSNRule_Length] intValue];
                
                if (0 != iSNLength && [szSNValue length] != iSNLength) 
                {
                    NSLog(@"checkAboveSNRule: check sn length rule: FAIL");
                    [[m_arrSNTextFields objectAtIndex:i] setStringValue:@""];
                    if (bRet)
                    {
                        // set the focus to the first FAIL sn lable
                        m_iSNNumber = i;
                        [m_windowUI makeFirstResponder:[m_arrSNTextFields objectAtIndex:i]];
                        
                        NSLog(@"checkAboveSNRule: the first fail SN id(%d)", i);
                    }
                    bRet = NO;
                    NSString *szRunAlertTitle = [NSString stringWithFormat:@"错误(Error)(slot:%@)", m_szCurrentUnit];
                    NSRunAlertPanel(szRunAlertTitle, @"%@长度不匹配，长度应该为%d。(%@ length should be %d)", @"确定(OK)", nil, nil, szSNKey, iSNLength,szSNKey, iSNLength);
                    continue;
                }
                else
                {
                    NSLog(@"checkAboveSNRule: check sn length rule: PASS");
                }
                
                // contain string
                NSString *szContainString = [dicSNInfomation objectForKey:kUserDefaultSNRule_ContainString];
                if (nil == szContainString || [szContainString isEqualToString:@""])
                {
                    continue;
                }
                NSArray *arrKeyString = [szContainString componentsSeparatedByString:@","];
                
                BOOL bContain = YES;
                for (int i = 0; i < [arrKeyString count]; i++)
                {
                    NSRange rangeContain = [szSNValue rangeOfString:[arrKeyString objectAtIndex:i]];
                    if (NSNotFound != rangeContain.location
                        && rangeContain.length > 0
                        && rangeContain.length + rangeContain.location <= [szSNValue length])
                    {
                        szSNValue = [szSNValue substringFromIndex:(rangeContain.location + rangeContain.length)];
                    }
                    else
                    {
                        bContain = NO;
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
                        m_iSNNumber = i;
                        [m_windowUI makeFirstResponder:[m_arrSNTextFields objectAtIndex:i]];
                        
                        NSLog(@"checkAboveSNRule: the first fail SN id(%d)", i);
                    }
                    bRet = NO;
                    NSString *szRunAlertTitle = [NSString stringWithFormat:@"错误(ERROR)(slot:%@)", m_szCurrentUnit];
                    NSString *szTempString = [szContainString stringByReplacingOccurrencesOfString:@"," withString:@"\" \""];
                    NSRunAlertPanel(szRunAlertTitle, @"%@中没有特定的字符\"%@\"。(%@ does not contain key string \"%@\")", @"确认(OK)", nil, nil, szSNKey,szTempString, szSNKey, szTempString);
                    continue;
                }
                else
                {
                    NSLog(@"checkAboveSNRule: check sn contain rule: PASS");
                }
            }
        }
    }
    
    return bRet;
}

- (IBAction)abortTest:(NSButton *)sender
{
    NSLog(@"abortTest begin");
    testProgress.m_bAbort = YES;
//    if (1 == m_iRunCount) 
//    {
//        [btnCheckBox setEnabled:YES];
//        [tfCheckBox setTextColor:[NSColor blackColor]];
//    }
    NSLog(@"abortTest end");
}

- (IBAction)checkBox:(id)sender
{
    NSLog(@"checkBox begin");
    // enable all components on UI
    if ([btnCheckBox state] == NSOffState)
    {
        BOOL bBrotherTest = [[[[m_dicMuifa_Plist objectForKey:kUserDefaultModeSetting] objectForKey:@"BROTHER"] objectForKey:@"BrotherTest"] boolValue];
        if(bBrotherTest)
        {
            if ([[tfChooseCable stringValue] isEqualToString:@"Cable In Use"]) 
            {
                NSRunAlertPanel(@"Warning", @"請先選擇其他的治具控制線,然後再取消這個測試對象！(Please Choose Other Fixture Control Cable,Then Cancel This Test Object!)", @"YES", nil, nil);
                [btnCheckBox setState:NSOnState];
                return;
            }
            else
            {
                [btnChooseCable setEnabled:NO];
                [tfChooseCable setTextColor:[NSColor redColor]];
                
            }
            
            
        }

        [tfCheckBox setTextColor:[NSColor redColor]];
        [tfCheckBox setStringValue:@"Unit Unuse"];
        [btnCheckBox setState:NSOffState];
        [tfSN1 setEditable:NO];
        [tfSN2 setEditable:NO];
        [tfSN3 setEditable:NO];
        [tfSN4 setEditable:NO];
        [tfSN5 setEditable:NO];
        [tfSN6 setEditable:NO];
        [btnAbort setEnabled:NO];
        [btnStart setEnabled:NO];
        [tvCSVInfo setEnabled:NO];
        [tvUARTInfo setEnabled:NO];
        [tvFailInfo setEnabled:NO];
        [lbResultLabel setStringValue:@"UNUSE"];
        [lbResultLabel setTextColor:[NSColor redColor]];
        [lbResultLabel setBackgroundColor:[NSColor orangeColor]];
    }
    else
    {
        BOOL bBrotherTest = [[[[m_dicMuifa_Plist objectForKey:kUserDefaultModeSetting] objectForKey:@"BROTHER"] objectForKey:@"BrotherTest"] boolValue];
        if(bBrotherTest)
        {
            [btnChooseCable setEnabled:YES];
            [tfChooseCable setTextColor:[NSColor blackColor]];
        }

        [tfCheckBox setTextColor:[NSColor blackColor]];
        [tfCheckBox setStringValue:@"Unit In Use"];
        [btnCheckBox setState:NSOnState];
		[tfSN1 setEditable:YES];
        [tfSN2 setEditable:YES];
        [tfSN3 setEditable:YES];
        [tfSN4 setEditable:YES];
        [tfSN5 setEditable:YES];
        [tfSN6 setEditable:YES];
        [btnStart setEnabled:YES];
        
        BOOL bEnableAbort = [[[m_dicMuifa_Plist objectForKey:kUserDefaultModeSetting] objectForKey:kUserDefualtEnableAbort] boolValue];
        if (bEnableAbort)
        {
            [btnAbort setEnabled:NO];
        }
        else
        {
            [btnAbort setEnabled:YES];
        }
        
        [tvCSVInfo setEnabled:YES];
        [tvUARTInfo setEnabled:YES];
        [tvFailInfo setEnabled:YES];
        [lbResultLabel setStringValue:@"READY"];
        [lbResultLabel setTextColor:[NSColor blackColor]];
        [lbResultLabel setBackgroundColor:[NSColor orangeColor]];
        
        // reset SN default lable
        [self setSNDefaultLables];
    }
    NSLog(@"checkBox end");
}

- (void)startSingleTest:(NSDictionary *)dicInfo
{
    NSLog(@"startSingleTest begin");
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
    BOOL bBrotherTest = [[[[m_dicMuifa_Plist objectForKey:kUserDefaultModeSetting] objectForKey:@"BROTHER"] objectForKey:@"BrotherTest"] boolValue];
    // set manual click test 
    //m_bManualClickTest = NO;
    
    // set UI uneditable
    [tfSN1 setEditable:NO];
    [tfSN2 setEditable:NO];
    [tfSN3 setEditable:NO];
    [tfSN4 setEditable:NO];
    [tfSN5 setEditable:NO];
    [tfSN6 setEditable:NO];
    [btnStart   setEnabled:NO];
    [btnCheckBox setEnabled:NO];
    [tfCheckBox setTextColor:[NSColor grayColor]];
    
//======================  add for interposer and grape-1, when the start button have pressed , start test auto.========
    
    if (bBrotherTest) 
    {
        [btnChooseCable setEnabled:NO];
        [tfChooseCable setTextColor:[NSColor grayColor]];
    }
    BOOL bAntsTest = [[[[kFZ_UserDefaults objectForKey:kUserDefaultModeSetting] objectForKey:@"ANTS"] objectForKey:@"AntsTest"] boolValue];
    
    if (bBrotherTest || bAntsTest)
    {
        // notification for pressed start button
        [nc postNotificationName:BNRAllStartButtonPressedNotification object:self userInfo:nil];
        
        while (!g_bBrotherTestReady)
        {
            usleep(100000);
        }
        
        // Ants Test didn't need to pressed fixutre button to start.
        if (bBrotherTest)
        {
            NSString    *szMessage =@"請長按治具上的兩個綠色按鈕，讓tray盤進去下壓，直到到位才能鬆手。";
            NSString    *szbutton =@" ";
            NSMutableString *szResult=[[NSMutableString alloc] init];
            NSDictionary    *dicPlugIN=[NSDictionary dictionaryWithObjectsAndKeys:szMessage,@"MESSAGE",szbutton,@"ABUTTONS",nil];
            if (testProgress == nil)
            {
                testProgress = [[TestProgress alloc] init];
                if (m_bTestOnceScript)
                {
                    // once test, do once test script
                    testProgress.arrayScript = m_arrTestOnceScript;
                }
                else
                {
                    // not once test, do the default test script
                    testProgress.arrayScript = m_arrScriptFile;
                }
                testProgress.ScriptName = m_szScriptName;
                [testProgress.m_dicMemoryValues setDictionary:m_dicGHInfo];
                [testProgress.m_dicMemoryValues setObject:[[m_dicParaFromMuifa objectForKey:kTransferKey_UnitColor] objectForKey:@"StringColor"] forKey:kTransferKey_UnitColor];
                [testProgress.m_dicMemoryValues setObject:m_colorForUnit forKey:kPD_AMIOK_PanelColor];
                [testProgress.m_dicMemoryValues setObject:m_dicMuifa_Plist forKey:kPD_Muifa_Plist];
            }
            
            [szResult setString: m_strControlCable];
            NSNumber   *iPort = [testProgress Is_Elder_Brother_port:m_dicPorts RETURNVALUE:szResult];
            
            if([iPort boolValue])
            {
                [NSThread detachNewThreadSelector:@selector(MonitorGrapeSensorIN:) toTarget:self withObject:dicPlugIN];
                usleep(5000);
                NSString *szFixturePort = [[m_dicPorts objectForKey:@"FIXTURE"]objectAtIndex:0];
                [testProgress monitorSensorStatusInWithUartPath:szFixturePort];
                
                [testProgress CLOSE_MESSAGE_BOX:dicPlugIN RETURN_VALUE:szResult];
                [nc postNotificationName:BNRMoniterGrapeFixtureSenserInNotification object:self userInfo:nil];
            }
            else
            {
                while (!m_bGrapeSensorIN) 
                {
                    usleep(100000);
                }
            }
            [szResult release];
        }
    }
//========================== add for interposer and grape-1, when the start button have pressed , start test auto.===========
    
    // show time indicator
    m_bStopTest = NO;
    [lbTotalTime setStringValue:@"Time: 00:00:00"];
    [NSThread detachNewThreadSelector:@selector(setTimeIndicator:) toTarget:self withObject:nil];
    
    // iPass&iFail for counting cycle count results
	int iPass = 0;
	int iFail = 0;
    
    //torres add for magnet vendor 2012.11.29
    @synchronized(tfShowResult){
        [tfShowResult setStringValue:@""];
    }
    
    // if m_iRunCount = 1, test once; m_iRunCount > 1, cycle test
    for(int iCount = 0;iCount < m_iRunCount;iCount++)
    {
        NSAutoreleasePool *poolFunnyZone = [[NSAutoreleasePool alloc] init]; // poolFunnyZone for release object in testProgress
        
        // manage the test count for NFMU cycle test
        if ([m_szCurrentMode isEqualToString:kMuifa_Window_Mode_NFMU] && (0 != m_iRunCount) && (1 != m_iRunCount))
        {
            @synchronized(g_szMutex_Lock)
            {
                if (g_iCycleCountForNFMU >= m_iRunCount) 
                {
                    break;
                }
                g_iCycleCountForNFMU++;
            }
        }
        
        // we need to alloc one testProgress object every test
        if (nil==testProgress)
		{
			testProgress=[[TestProgress alloc] init];
            if (m_bTestOnceScript)
            {
                // once test, do once test script
                testProgress.arrayScript = m_arrTestOnceScript;
            }
            else
            {
                // not once test, do the default test script
                testProgress.arrayScript = m_arrScriptFile;
            }
            testProgress.ScriptName = m_szScriptName;
            [testProgress.m_dicMemoryValues setDictionary:m_dicGHInfo];
            [testProgress.m_dicMemoryValues setObject:[[m_dicParaFromMuifa objectForKey:kTransferKey_UnitColor] objectForKey:@"StringColor"] forKey:kTransferKey_UnitColor];
            [testProgress.m_dicMemoryValues setObject:m_colorForUnit forKey:kPD_AMIOK_PanelColor];
            [testProgress.m_dicMemoryValues setObject:m_dicMuifa_Plist forKey:kPD_Muifa_Plist];
		}
        
        // set Pass for default result
        m_bTestPass = YES;

        // add observers
        [nc removeObserver:self];
        [nc addObserver:self selector:@selector(controlTextDidBeginEditing:) name:NSControlTextDidBeginEditingNotification object:nil];
        [nc addObserver:self
               selector:@selector(handleTestResult:) 
                   name:TestItemInfoNotification 
                 object:testProgress];
        [nc addObserver:self selector:@selector(tableViewSelectionDidChange:) name:NSTableViewSelectionDidChangeNotification object:nil];
        if ([m_szCurrentMode isEqualToString:kMuifa_Window_Mode_NFMU])
        {
            // add an observer for NFMU to show count
            [nc addObserver:self selector:@selector(showCountOnLable:) name:BNRCounterForNFMUNotification object:nil];
        }
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(showScanSN:) name:@"NotificationScanSN" object:nil];
        
        // 2012.2.20 Desikan 
        //      Prox-Cal show ready bug(finished test,before plug out unit,ui show READY,but not PASS/FAIL),
        //      get SN from Fonnyzone
        [nc addObserver:self selector:@selector(getDataFromFonnyZone:) name:PostDataToMuifaNote object:testProgress];
        
        // 2012.4.21 Sky
        //      iPad-1 show voltage on UI
        [nc addObserver:self selector:@selector(showVoltageOnUI:) name:ShowVoltageOnUI object:testProgress];
        
     //jeff   
        [nc addObserver:self selector:@selector(showMessage:) name:ShowMessage object:testProgress];

        [nc addObserver:self selector:@selector(closeMessage:) name:CloseMessage object:testProgress];     

        // for CT Ants Test
        [nc addObserver:self selector:@selector(transterToMuifa:) name:BNRTransferToMuifaNotification object:testProgress];
        
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
        @synchronized(m_arrDrawerCheckBoxInfo)
        {
            [m_arrDrawerCheckBoxInfo removeAllObjects];
        }
        @synchronized(m_arrDrawerFailItemsInfo)
        {
            [m_arrDrawerFailItemsInfo removeAllObjects];
        }
        
        //torres removed for Magnet vendor 2012.11.29
        //[tvCSVInfo reloadData];
        //[tvFailInfo reloadData];
        //[tvUARTInfo reloadData];
        //[textViewFailInfo setString:@""];
        
        //torres add for Magnet vendor 2012.11.29

        [m_szMagnetResult setString:@""];
        
        // set default indicator view
        [lbPercentageNumber setStringValue:@"0%"];
        [levelIndicator setFloatValue:0.0f];
        [lbResultLabel setStringValue:@"TESTING"];
        [lbResultLabel setBackgroundColor:[NSColor orangeColor]];
        
        //transfer SN Key-Value to FunnyZone
        if (m_dicSNsFromUI != nil && [m_dicSNsFromUI count]>0)
        {
            testProgress.MobileSerialNumber = m_szMainSN;
            NSArray *arrKeys = [m_dicSNsFromUI allKeys];
            for (int i = 0; i < [arrKeys count]; i++)
            {
                NSString *szKey = [arrKeys objectAtIndex:i];
                [testProgress.m_dicMemoryValues setObject:[m_dicSNsFromUI objectForKey:szKey] forKey:szKey];
            }
        }
        
        // print m_dicMemoryValues in testprogress
        NSLog(@"startSingleTest: m_dicMemoryValues = %@", testProgress.m_dicMemoryValues);
        
        // get start time and transfer to FunnyZone
		testProgress.m_szStartTime = [[NSDate date] descriptionWithCalendarFormat:@"%Y-%m-%d %H-%M-%S" timeZone:nil locale:nil];
        
         // set unit name as Port index for FunnyZone to write logs
        testProgress.m_szPortIndex = [NSMutableString stringWithString:m_szCurrentUnit];
        
        // transfer serial port information to FunnyZone by Unit
        [testProgress setM_dicPorts:m_dicPorts];
        
        // transfer UI version and script version to FunnyZone
		testProgress.m_szUIVersion = m_szUIVersion;
        testProgress.m_szScriptVersion = m_szScriptVersion;
        
        
        //===========add for interposer & grape-1 to stress test. yaya 2012.7.14============
        if ( bBrotherTest && m_iRunCount != 0 && m_iRunCount != 1)
        {
            NSMutableString *szResult=[[NSMutableString alloc] init];
            NSMutableDictionary *dicPara = [[NSMutableDictionary alloc] init];
            [szResult setString:m_strControlCable];
            [testProgress ELDER_BROTHER_NOTIFY_YOUNG_BROTHER:dicPara RETURNVALUE:szResult];
            [btnStart setEnabled:NO];
            [dicPara release];
            [szResult release];
        }
        
		// start test at FunnyZone after next code
        [m_queue addOperation:testProgress];
        
        while(YES)
        {
            m_bNoResponse = testProgress.m_bNoResponse;//Leehua
            
            // when finish test, this code will execute
            if([testProgress isFinished])
            {
                NSString *szStatusColor = testProgress.m_szStatusColor;     // add for show special status color on UI  --Gordon

                //reset brother test as NO
                g_bBrotherTestReady = NO;
                m_bGrapeSensorIN = NO;
                
                // make test once script only test once
               if (m_bTestOnceScript)
                {
                    // test once
                    // back to normal test script and refresh UI
                    //added by lucy for test once
                   NSString * szPlanFileName = [[m_dicMuifa_Plist objectForKey:kUserDefaultScriptInfo] objectForKey:kUserDefaultScriptFileName];
                    [self parseAndLoadScriptFile:szPlanFileName OnlyTestOnce:m_bTestOnceScript];
                    m_bTestOnceScript =NO;
                }
                    [self parseAndLoadScriptFile:m_szTestScriptFilePath OnlyTestOnce:m_bTestOnceScript];
                   // [self parseAndLoadScriptFile:m_szTestOnceScriptFile];
                //}
                //modify by lucy for Hall-Effect
                
                
                [nc removeObserver:self name:TestItemInfoNotification object:testProgress];
                [nc removeObserver:self name:BNRTransferToMuifaNotification object:testProgress];
                [nc removeObserver:self  name:@"NotificationScanSN" object:nil];
                [nc removeObserver:self name:PostDataToMuifaNote object:testProgress];
                [nc removeObserver:self name:ShowVoltageOnUI object:testProgress];
                [nc removeObserver:self name:ShowMessage object:testProgress];
                [nc removeObserver:self name:CloseMessage object:testProgress];
				[testProgress release];
                testProgress = nil;
                
                // set UI according to the test result
                if (m_bTestPass) 
                {
					iPass ++;
                    g_iPassForNFMU ++;
                    [lbResultLabel setDrawsBackground:YES];
                    [lbResultLabel setBackgroundColor:[NSColor greenColor]];
                    [lbResultLabel setStringValue:@"PASS"];
                }
                else
                {
					iFail ++;
                    g_iFailForNFMU ++;
                    [lbResultLabel setDrawsBackground:YES];
                    [lbResultLabel setBackgroundColor:[NSColor redColor]];
                    [lbResultLabel setStringValue:@"FAIL"];
                }
                
                // add for show special status color on UI  --Gordon
                if ([szStatusColor isEqualToString:@"YELLOW"])
                {
                    [lbResultLabel setDrawsBackground:YES];
                    [lbResultLabel setBackgroundColor:[NSColor yellowColor]];
                    [lbResultLabel setStringValue:@"FAIL"];
                }
                else if ([szStatusColor isEqualToString:@"WHITE"])
                {
                    [lbResultLabel setDrawsBackground:YES];
                    [lbResultLabel setBackgroundColor:[NSColor whiteColor]];
                    [lbResultLabel setStringValue:@"FAIL"];
                }
                else
                {
                    
                }
                
                
				// add count after test and show on UI
				if (0 != m_iRunCount && 1 != m_iRunCount) 
				{
                    if ([m_szCurrentMode isEqualToString:kMuifa_Window_Mode_NFMU])
                    {
                        NSDictionary *dicInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:g_iPassForNFMU], @"TotalPassCount", [NSNumber numberWithInt:g_iFailForNFMU], @"TotalFailCount", [NSNumber numberWithInt:g_iPassForNFMU+g_iFailForNFMU], @"HaveRunCycleCount", nil];
                        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
                        [nc postNotificationName:BNRCounterForNFMUNotification object:self userInfo:dicInfo];
                    }
                    else
                    {
                        [lbTotalCount setStringValue:[NSString stringWithFormat:@"Cycle Count: %d/%d (Pass:%d Fail:%d)",iCount+1, m_iRunCount, iPass, iFail]];
                    }
				}
				else
				{
                    NSDictionary *dicInfo = [NSDictionary dictionaryWithObjectsAndKeys:m_szCurrentMode, @"CurrentMode", m_szCurrentUnit, @"CurrentUnit", [NSNumber numberWithBool:m_bTestPass], @"TestResult", nil];
                    
                    // open a thread to write count into setting file
                    [NSThread detachNewThreadSelector:@selector(writeCountIntoSettingFile:) toTarget:self withObject:dicInfo];
                    
                    if ([[[m_dicMuifa_Plist objectForKey:kUserDefaultModeSetting] objectForKey:kUserDefaultAutoDetectAndRun] boolValue])
                    {
                        // open a thread to monitor serial port whether pulg out for auto detect and run test
                        [NSThread detachNewThreadSelector:@selector(MonitorSerialPortPlugOut) toTarget:self withObject:nil];
                    }
				}
                
                //===========add for interposer & grape-1 to stress test. yaya 2012.7.14============
                if ( bBrotherTest && m_iRunCount != 0 && m_iRunCount != 1)
                {
                    [btnStart setEnabled:YES];
                    [nc postNotificationName:BNRYoungBrotherStartButtonUnpressedNotification object:self userInfo:nil];
                }
               
                [poolFunnyZone release];
                
                break; // one test finish, break while(YES) loop
            }
            usleep(100000);
        }
        // if m_iRunCount = 1, for loop will end and continue to execute next code
        // if m_iRunCount > 1, loop test
        
        // torres add for magnet vendor 2012.11.29
        [tfShowResult setStringValue:m_szMagnetResult];
        
    }
    
  
    // test stop
    m_bStopTest = YES;
    //Don't erase the test result in UI before unit is unplugged from slot4. 
    BOOL bIS_1_to_N  =   [[[kFZ_UserDefaults objectForKey:kUserDefaultModeSetting] objectForKey:@"IS_1_to_N"] boolValue];
    if (bIS_1_to_N ) 
    {
        NSString *szBsdPath =[[[m_dicPorts objectForKey:@"MOBILE"] objectAtIndex:0] objectForKey:@"Slot4"];
        TestProgress *objTestProgressTemp = [[TestProgress alloc] init];
        NSMutableString *szUartResponseTemp = [[NSMutableString alloc]init];
        
        do {
            BOOL bConnnect = [objTestProgressTemp checkUnitConnectWellWithSerialPort:szBsdPath UARTCommand:@"" UartResponse:szUartResponseTemp CheckTime:1.0];
            if (!bConnnect) {
                break;
            }
            sleep(1);
            
        } while (YES);
        [objTestProgressTemp release];
        [szUartResponseTemp release];         
    }

    // editable UI
    [tfSN1 setEditable:YES];
    [tfSN2 setEditable:YES];
    [tfSN3 setEditable:YES];
    [tfSN4 setEditable:YES];
    [tfSN5 setEditable:YES];
    [tfSN6 setEditable:YES];
    [btnStart setEnabled:YES];
    [btnCheckBox setEnabled:YES];
    [tfCheckBox setTextColor:[NSColor blackColor]];
    
    if (bBrotherTest) 
    {
        [btnChooseCable setEnabled:YES];
        [tfChooseCable setTextColor:[NSColor blackColor]];
    }
    m_iSNNumber = 0;
    
    // set SN default lables
    [self setSNDefaultLables];
    
    if (bBrotherTest)
    {
        // notification for unpressed start button
        NSLog(@"before postNotificationName:BNRYoungBrotherStartButtonUnpressedNotification");
        [nc postNotificationName:BNRYoungBrotherStartButtonUnpressedNotification object:self userInfo:nil];
        [nc addObserver:self selector:@selector(unCheckbox:) name:@"BNRControlCableNotification" object:nil];
        NSLog(@"after postNotificationName:BNRYoungBrotherStartButtonUnpressedNotification");
    }

    [pool drain];
    NSLog(@"startSingleTest end");
}

-(void)handleTestResult:(NSNotification*)note
{
    if ([[[note userInfo] objectForKey:kFunnyZoneIdentify] isEqualToString:kUartView]) {
        [self processUartLog:[note userInfo]];
    }
    else if(([[note object] isMemberOfClass:[TestProgress class]])
			&&([[[note userInfo] objectForKey:kFunnyZoneIdentify] isEqualToString:kAllTableView]))
    {
        [self processNormalTest:note];
    }
    
}

-(void)processUartLog:(NSDictionary*)dicResult
{
    NSString *szTxRx=[dicResult objectForKey:kIADeviceNotificationTX];
    szTxRx=[szTxRx stringByReplacingOccurrencesOfString:kFunnyZoneEnter	withString:kFunnyZoneBlank1];
    szTxRx=[szTxRx stringByReplacingOccurrencesOfString:kFunnyZoneNewLine withString:kFunnyZoneBlank1];
	
	NSMutableDictionary *dictTemp = [NSMutableDictionary dictionaryWithDictionary:dicResult];
	[dictTemp setObject:szTxRx forKey:kIADeviceNotificationTX];
    @synchronized(m_arrUARTInfo)
    {
        [m_arrUARTInfo addObject:dictTemp];
    }
    NSLog(@"processUartLog: ADD UART LOG: %@", dictTemp);
    
    // Don't show Uart information immediately
	//[tvUARTInfo reloadData];
}

-(void)processNormalTest:(NSNotification*)noti
{
	//NSDictionary *dictResult = [noti userInfo];
    NSDictionary *dicResult = [[NSDictionary alloc] initWithDictionary:[noti userInfo]];
    BOOL bResult = [[dicResult objectForKey:kFunnyZoneSingleItemResult] boolValue];
    if	(!bResult)
    {
        @synchronized(m_arrFailInfo)
        {
            [m_arrFailInfo addObject:dicResult];
            /*NSDictionary *dictALLView = [NSDictionary dictionaryWithObjectsAndKeys:
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
            [self postTestInfoToUI:dictALLView];*/
            NSString *szShowFailMessage = [NSString stringWithFormat:@" %@ ==> Value:[%@]  Limits:[%@]",[dicResult objectForKey:kAllTableViewItemName],[dicResult objectForKey:kAllTableViewRetureValue],[dicResult objectForKey:kAllTableViewSpec]];
            [m_szMagnetResult appendFormat:@"%@\n",szShowFailMessage];
            
        }
        NSLog(@"processNormalTest: ADD FAIL LOG: %@", dicResult);
        m_bTestPass = NO;
        if (testProgress.isCheckedPDCA)
        {
            // set back the flag and return.
            [dicResult release];
            testProgress.isCheckedPDCA = NO;
            return;
        }
    }
    
    // synchronize the levelindicator with test process.
    NSInteger curIndex=[[dicResult objectForKey:kFunnyZoneCurrentIndex] intValue];
    NSInteger sum=[[dicResult objectForKey:kFunnyZoneSumIndex] intValue];
    [levelIndicator setMinValue:0];
    [levelIndicator setMaxValue:sum-1];
    [levelIndicator setIntValue:curIndex+1];
    [lbPercentageNumber setStringValue:[NSString stringWithFormat:@"%.2f%%", (float)(curIndex + 1) *100 /sum]];
    
    @synchronized(m_arrCSVInfo)
    {
        [m_arrCSVInfo insertObject:dicResult atIndex:0];
    }
    NSLog(@"processNormalTest: ADD CSV LOG: %@", dicResult);
    [dicResult release];
    
    if ([[[tabTestInfo tabViewItems] objectAtIndex:0] isEqualTo: [tabTestInfo selectedTabViewItem]])
    {
        //torres removed for Magnet vendor 2012.11.29
        //[tvCSVInfo reloadData];
    }
    
    // Don't show Fail message immediately
    //[tvFailInfo reloadData];
}

- (void)setDefaultValueAndGetScriptInfo:(NSString *)szIdentifier CurrentMode:(NSString *)szCurrentMode
{
    NSLog(@"setDefaultValueAndGetScriptInfo begin");
    // Current Mode
    m_szCurrentMode = szCurrentMode;
    [m_szCurrentMode retain];
    
    //Current Unit
    m_szCurrentUnit = szIdentifier;
    [m_szCurrentUnit retain];
    
    [lbUnitMark setStringValue:szIdentifier];    
    // set color of the unit lable
    [lbUnitMark setBackgroundColor:m_colorForUnit];
    
    //link lables in left with tabviewitems in right
    [btnLinkToTabViewItem setTitle:szIdentifier];
    [btnLinkToTabViewItem setAction:@selector(linkToTabViewItem:)];
    
    // set labels
    [lbPercentageNumber setStringValue:@"0%"];
    [levelIndicator setFloatValue:0.0f];
    [lbResultLabel setStringValue:@"READY"];
    [lbResultLabel setBackgroundColor:[NSColor orangeColor]];
    [lbTotalTime setStringValue:@"Time: 00:00:00"];
    [lbTotalCount setStringValue:@"Count: 0 (Pass:0 Fail:0)"];
    
    [self setSNDefaultLables];
    
    // read test count from setting file and show it on UI
    if ([m_szCurrentMode isEqualToString:kMuifa_Window_Mode_NFMU])
    {
        NSDictionary *dicInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0], @"TotalPassCount", [NSNumber numberWithInt:0], @"TotalFailCount", [NSNumber numberWithInt:0],@"HaveRunCycleCount", nil];
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(showCountOnLable:) name:BNRCounterForNFMUNotification object:nil];
        [nc postNotificationName:BNRCounterForNFMUNotification object:self userInfo:dicInfo];
    }
    else
    {
        [self showCountOnLable:nil];
    }
    
    // parse the script file.
	NSString * szPlanFileName = [[m_dicMuifa_Plist objectForKey:kUserDefaultScriptInfo] objectForKey:kUserDefaultScriptFileName];
    [self parseAndLoadScriptFile:szPlanFileName OnlyTestOnce:NO];
   // NSDictionary *dicTestOnceScript = [[kFZ_UserDefaults objectForKey:kUserDefaultScriptInfo] objectForKey:kUserDefaultTestOnceScriptName];
   // m_bTestOnceScript = [dicTestOnceScript objectForKey:@""];
    //[self parseAndLoadScriptFile:szPlanFileName];
    
    // get UI version and script file verion
    m_szUIVersion =[[[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"] retain];
    m_szScriptVersion = [[self Get_Script_Version] retain];
    
    NSLog(@"setDefaultValueAndGetScriptInfo end");
}

- (void)parseAndLoadScriptFile:(NSString *)szcriptFileName OnlyTestOnce:(BOOL)bTestOnce
//- (void)parseAndLoadScriptFile:(NSString *)szcriptFileName
{
    NSLog(@"parseAndLoadScriptFile begin");
    NSString * szPlanFilePath = [NSString stringWithFormat:@"%@/Contents/Frameworks/FunnyZone.framework/Resources/%@",
								 [[NSBundle mainBundle] bundlePath],szcriptFileName];
	NSLog(@"setDefaultValueAndGetScriptInfo: Plan file path: %@",szPlanFilePath);
    
    //Add by xiaoyong for summary log
    NSRange     range = [szcriptFileName rangeOfString:@".plist"];
    NSString    *szScript = @"";
    if ((NSNotFound != range.location) && (range.length >0) && range.location+range.length <= [szcriptFileName length]) 
    {
        szScript = [szcriptFileName stringByReplacingCharactersInRange:range withString:@""];
    }

    // get script information and save it for FunnyZone
    m_bTestOnceScript = bTestOnce;
    
    [m_szTestScriptFilePath release];
    m_szTestScriptFilePath =[szcriptFileName retain];
   
    
    if (nil != testProgress)
    {
        testProgress.arrayScript = [testProgress parserScriptFile:szPlanFilePath];
        if (m_arrScriptFile) [m_arrScriptFile release];
        m_arrScriptFile = [[NSArray alloc] initWithArray:testProgress.arrayScript];
    }
    else
    {
        TestProgress *temp = [[TestProgress alloc] init];
        if (m_arrScriptFile) [m_arrScriptFile release];
        m_arrScriptFile = [[NSArray alloc] initWithArray:[temp parserScriptFile:szPlanFilePath]];
        [temp release];
    }
    
    if (bTestOnce)
    {
        // if it is test once script file, save to the special array
        if (nil != testProgress)
        {
            testProgress.arrayScript = [testProgress parserScriptFile:szPlanFilePath];
            if (m_arrTestOnceScript) [m_arrTestOnceScript release];
            m_arrTestOnceScript = [[NSArray alloc] initWithArray:testProgress.arrayScript];
        }
        else
        {
            TestProgress *temp = [[TestProgress alloc] init];
            if (m_arrTestOnceScript) [m_arrTestOnceScript release];
            m_arrTestOnceScript = [[NSArray alloc] initWithArray:[temp parserScriptFile:szPlanFilePath]];
            [temp release];
        }
    }
    else
    {
        //=============modify for Clear CB===============
        //Alloc testProcess object
        if (nil !=testProgress)
		{
			
            testProgress.arrayScript = [testProgress parserScriptFile:szPlanFilePath];
            if (m_arrScriptFile) [m_arrScriptFile release];
            m_arrScriptFile = [[NSArray alloc] initWithArray:testProgress.arrayScript];
        }
        else
        {
            TestProgress *temp=[[TestProgress alloc] init];
            temp.arrayScript = [temp parserScriptFile:szPlanFilePath];
            if (m_arrScriptFile) [m_arrScriptFile release];
            m_arrScriptFile = [[NSArray alloc] initWithArray:temp.arrayScript];
            [temp release];
        }
        //=============modify for Clear CB===============
    }
	
    if (m_szScriptName) [m_szScriptName release];
    testProgress.ScriptName = m_szScriptName = [szScript retain];

    // check the script name between groundhog and setting file
    NSString	*szStationType = [m_dicGHInfo objectForKey:kPD_GHInfo_STATION_TYPE];
    if ([szcriptFileName	isEqualToString:[NSString stringWithFormat:@"%@.plist",szStationType]])
    {
        [lbScriptFile setTextColor:[NSColor blackColor]];
    }
    else
    {
        [lbScriptFile setTextColor:[NSColor redColor]];
    }
	[lbScriptFile setStringValue:[NSString stringWithFormat:@"Script:  %@",szcriptFileName]];
    NSLog(@"parseAndLoadScriptFile end");
    //[szcriptFileName release];
    //[szScript release];
}

- (void)setSNDefaultLables
{
    NSLog(@"setSNDefaultLables begin");
    //=============modify for Clear CB===============
    NSDictionary *dicTestOnceScript = [[kFZ_UserDefaults objectForKey:kUserDefaultScriptInfo] objectForKey:kUserDefaultTestOnceScriptName];
    NSString *onceScriptName = [[dicTestOnceScript objectForKey:@"FATP_CB_PLIST"]objectForKey:@"PlistFile"];
    if ([[onceScriptName uppercaseString] isEqualToString:@"FATP_CB ERASE.PLIST"]&&[[onceScriptName uppercaseString] isEqualToString:[[NSString stringWithFormat:@"%@.PLIST",m_szScriptName] uppercaseString]]) 
    {
        [self changeSNManage];
    }
    //=============modify for Clear CB===============
    else
    {
        NSDictionary *dicSN_Manage = [m_dicMuifa_Plist objectForKey:kUserDefaultSN_Manager];
        NSArray *arrSNArrangement = [[m_dicMuifa_Plist objectForKey:kUserDefaultSN_Manager] objectForKey:kUserDefaultSN_Arrangement];
        if (nil == arrSNArrangement) 
        {
            [lbSN1 setStringValue:@"*ISN*"];
            [lbSN2 setStringValue:@"MLBSN"];
            [lbSN3 setStringValue:@"LCMSN"];
            [lbSN4 setStringValue:@"GRPSN"];
            [lbSN5 setStringValue:@"SN5"];
            [lbSN6 setStringValue:@"SN6"];
            [tfSN1 setStringValue:@""];
            [tfSN2 setStringValue:@""];
            [tfSN3 setStringValue:@""];
            [tfSN4 setStringValue:@""];
            [tfSN5 setStringValue:@""];
            [tfSN6 setStringValue:@""];
        }
        else
        {
            for (int i = 0; i < [arrSNArrangement count]; i++)
            {
                NSDictionary *dicParameters = [dicSN_Manage objectForKey:[arrSNArrangement objectAtIndex:i]];
                [[m_arrSNLables objectAtIndex:i] setEnabled:YES];
                [[m_arrSNTextFields objectAtIndex:i] setEnabled:YES];
                [[m_arrSNLables objectAtIndex:i] setStringValue:[[dicParameters objectForKey:kUserDefaultShowTitle] uppercaseString]];
                [[m_arrSNTextFields objectAtIndex:i] setStringValue:[[dicParameters objectForKey:kUserDefaultShowDebugSN]uppercaseString]];
                
                // if it is garbage sn, make it invisible
                // The garbage sn is for the condition that if we scan three sn, but we only used two sn.
                // We use garbage sn to receive the unused sn
                if ([[dicParameters objectForKey:kUserDefualtGarbageSN] boolValue])
                {
                    [[m_arrSNLables objectAtIndex:i] setStringValue:[kUserDefualtGarbageSN uppercaseString]];
                    [[m_arrSNLables objectAtIndex:i] setBoundsSize:NSMakeSize(0, 0)];
                    [[m_arrSNTextFields objectAtIndex:i] setBoundsSize:NSMakeSize(0, 0)];
                    [[m_arrSNTextFields objectAtIndex:i] setBordered:NO];
                    [[m_arrSNTextFields objectAtIndex:i] setDrawsBackground:NO];
                }
            }
            
        }
    }

    NSLog(@"setSNDefaultLables end");
}
//=============modify for Clear CB===============
- (void)changeSNManage
{
    NSLog(@"changeSNManage begin");
    NSDictionary *dicParameters = [[m_dicMuifa_Plist objectForKey:kUserDefaultSN_Manager] objectForKey:@"SN1"];
    [[m_arrSNLables objectAtIndex:0] setEnabled:YES];
    [[m_arrSNTextFields objectAtIndex:0] setEnabled:YES];
    [[m_arrSNLables objectAtIndex:0] setStringValue:[[dicParameters objectForKey:kUserDefaultShowTitle] uppercaseString]];
    [[m_arrSNTextFields objectAtIndex:0] setStringValue:[[dicParameters objectForKey:kUserDefaultShowDebugSN] uppercaseString]];
    NSLog(@"changeSNManage end");
}
//=============modify for Clear CB===============

- (void)writeCountIntoSettingFile:(NSDictionary *)dicInfo
{
    NSLog(@"writeCountIntoSettingFile begin");
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    @synchronized(g_szMutex_Lock)
    {
        NSMutableDictionary *dicMuifa_Counter_Plist = [[NSMutableDictionary alloc] initWithContentsOfFile:kMuifaCounterPlistPath];
        
        NSString *szCurrentMode = [dicInfo objectForKey:@"CurrentMode"];
        NSString *szCurrentUnit =[dicInfo objectForKey:@"CurrentUnit"];
        BOOL bTestResult = [[dicInfo objectForKey:@"TestResult"] boolValue];
        int iPassRunCounter = 0;
        int iFailRunCounter = 0;
        int iHaveRunCounter = 0;
        
        // get the source dictionary about counter
        NSMutableDictionary *dicWrite = [[NSMutableDictionary alloc] init];
        if ([szCurrentMode isEqualToString:kMuifa_Window_Mode_MFMU])
        {
            [dicWrite setDictionary:[[[dicMuifa_Counter_Plist objectForKey:kUserDefaultCounter] objectForKey:szCurrentMode] objectForKey:szCurrentUnit]];
        }
        else
        {
            [dicWrite setDictionary:[[dicMuifa_Counter_Plist objectForKey:kUserDefaultCounter] objectForKey:szCurrentMode]];
        }
        
        // if test result is pass, iPassRunCounter+1; test result is fail, iFailRunCounter+1.
        if (bTestResult)
        {
            iHaveRunCounter = [[dicWrite objectForKey:kUserDefaultHaveRunCount] intValue] + 1;
            iPassRunCounter = [[dicWrite objectForKey:kUserDefaultPassCount] intValue] + 1;
            iFailRunCounter = [[dicWrite objectForKey:kUserDefaultFailCount] intValue];
        }
        else
        {
            iHaveRunCounter = [[dicWrite objectForKey:kUserDefaultHaveRunCount] intValue] + 1;
            iPassRunCounter = [[dicWrite objectForKey:kUserDefaultPassCount] intValue];
            iFailRunCounter = [[dicWrite objectForKey:kUserDefaultFailCount] intValue] + 1;
        }
        
        // update counter dictionary
        [dicWrite setObject:[NSNumber numberWithInt:iHaveRunCounter] forKey:kUserDefaultHaveRunCount];
        [dicWrite setObject:[NSNumber numberWithInt:iPassRunCounter] forKey:kUserDefaultPassCount];
        [dicWrite setObject:[NSNumber numberWithInt:iFailRunCounter] forKey:kUserDefaultFailCount];
        
        // write to setting file
        NSMutableDictionary *dicCounter = [[NSMutableDictionary alloc] initWithDictionary:[dicMuifa_Counter_Plist objectForKey:kUserDefaultCounter]];
        NSMutableDictionary *dicCounter_Mode = [[NSMutableDictionary alloc] initWithDictionary:[dicCounter objectForKey:szCurrentMode]];
        if ([szCurrentMode isEqualToString:kMuifa_Window_Mode_MFMU])
        {       
            [dicCounter_Mode setObject:dicWrite forKey:szCurrentUnit];
            [dicCounter setObject:dicCounter_Mode forKey:szCurrentMode];
        }
        else
        {
            [dicCounter setObject:dicWrite forKey:szCurrentMode];
        }
        [dicMuifa_Counter_Plist setObject:dicCounter forKey:kUserDefaultCounter];
        [dicMuifa_Counter_Plist writeToFile:kMuifaCounterPlistPath atomically:NO];
        
        // if NFMU mode, post notification to show counter
        if ([szCurrentMode isEqualToString:kMuifa_Window_Mode_NFMU])
        {
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc postNotificationName:BNRCounterForNFMUNotification object:self userInfo:nil];
        }
        else
        {
            [self showCountOnLable:nil];
        }
        [dicCounter_Mode release];
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

        NSMutableDictionary *dicMuifa_Counter_Plist = [[NSMutableDictionary alloc] initWithContentsOfFile:kMuifaCounterPlistPath];

        NSDictionary *dicWrite;
        if ([m_szCurrentMode isEqualToString:@"MFMU"])
        {
            dicWrite = [[[dicMuifa_Counter_Plist objectForKey:kUserDefaultCounter] objectForKey: m_szCurrentMode] objectForKey:m_szCurrentUnit];
        }
        else
        {
            dicWrite = [[dicMuifa_Counter_Plist objectForKey:kUserDefaultCounter] objectForKey: m_szCurrentMode];
        }
                        
        m_iRunCount=[[dicWrite objectForKey:kUserDefaultCycleTestTime] intValue];
        if(0 != m_iRunCount && 1 != m_iRunCount)
        {
            // if cycle test
            int iPass = [[[aNote userInfo] objectForKey:@"TotalPassCount"] intValue];
            int iFail = [[[aNote userInfo] objectForKey:@"TotalFailCount"] intValue];
            int iHaveRunCycleCount = [[[aNote userInfo] objectForKey:@"HaveRunCycleCount"] intValue];
            [lbTotalCount setStringValue:[NSString stringWithFormat:@"Cycle Count: %d/%d (Pass:%d Fail:%d)", iHaveRunCycleCount, m_iRunCount, iPass, iFail]];
        }
        else
        {
            // if normal test
            NSNumber  *numHaveRunCount = [dicWrite objectForKey:kUserDefaultHaveRunCount];
            NSNumber  *numPassRunCount = [dicWrite objectForKey:kUserDefaultPassCount];
            NSNumber  *numFailRunCount = [dicWrite objectForKey:kUserDefaultFailCount];
            [lbTotalCount setStringValue:[NSString stringWithFormat:@"Count: %@ (Pass:%@ Fail:%@)", numHaveRunCount, numPassRunCount, numFailRunCount]];
        }
        
        [dicMuifa_Counter_Plist release];
    }
    NSLog(@"showCountOnLable end");
}

-(void)setTimeIndicator:(id)iThread
{
    NSLog(@"setTimeIndicator begin");
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    unsigned unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit |NSSecondCalendarUnit;
    NSDate *dateStart = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    while (YES)
    {
        if(m_bStopTest)
        {
            break;
        }
        NSDate *dateEnd = [NSDate date];
        NSDateComponents *comps = [gregorian components:unitFlags fromDate:dateStart toDate:dateEnd options:1]; 
        NSInteger iHour = [comps hour];
        NSInteger iMinute = [comps minute];
        NSInteger iSecond = [comps second];
        NSString *szHour = [NSString stringWithFormat:@"%d",iHour];
        if (1==[szHour length])
        {
            szHour = [NSString stringWithFormat:@"0%d", iHour];
        }
        NSString *szMinute = [NSString stringWithFormat:@"%d",iMinute];
        if (1==[szMinute length])
        {
            szMinute = [NSString stringWithFormat:@"0%d", iMinute];
        }        
        NSString *szSecond = [NSString stringWithFormat:@"%d",iSecond];
        if (1==[szSecond length])
        {
            szSecond = [NSString stringWithFormat:@"0%d", iSecond];
        }
        
        [lbTotalTime setStringValue:[NSString stringWithFormat:@"Time: %@:%@:%@", szHour, szMinute, szSecond]];
        sleep(1);
    }
    [gregorian release];
    [pool drain];
    NSLog(@"setTimeIndicator end");
}

// when check box is off state in MFMU mode, the tabview can't switch tabviewitems
- (BOOL)tabView:(NSTabView *)tabView shouldSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    if ([btnCheckBox state] == NSOffState)
    {
        return NO;
    }
    else
    {
        return YES;
    }
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
    NSString *scriptFileName = [[m_dicMuifa_Plist objectForKey:kUserDefaultScriptInfo] objectForKey:kUserDefaultScriptFileName];
    // get scriptFilePath
    NSString *scriptPath     = [NSString stringWithFormat:@"%@/Contents/Frameworks/FunnyZone.framework/Resources/%@",[[NSBundle mainBundle] bundlePath],scriptFileName];
    // get contents with scriptFilePath
    NSString *szContents     = [NSString stringWithContentsOfFile:scriptPath encoding:NSUTF8StringEncoding error:nil];
    NSRange versionRange     = [szContents rangeOfString:@"<plist version=\""];
    if ((NSNotFound != versionRange.location) && (versionRange.length > 0) && ((versionRange.length + versionRange.location) <= [szContents length])) 
    {
        szContents           = [szContents substringFromIndex:versionRange.location + versionRange.length];
        NSRange endRange     = [szContents rangeOfString:@"\">"];
        if ((NSNotFound != endRange.location) && (endRange.length > 0) && ((endRange.length + endRange.location) <= [szContents length])) 
        {
            NSString *szValue = [szContents substringToIndex:endRange.location];
            if (szValue)
            {
                NSLog(@"Get_Script_Version end");
                return [NSString stringWithFormat:@"%@", szValue];
            }
        }
    }
    NSLog(@"Get_Script_Version end");
    return @"Unknow version";
}

//torres removed for Magnet vendor 2012.11.29
/*
// reload data when you access to the tabviewitem
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    if(kTag_TableView_FailItems == [tabView indexOfTabViewItem:tabViewItem])
    {
        [tvFailInfo reloadData];
    }
    if (kTag_TableView_UartLog == [tabView indexOfTabViewItem:tabViewItem])
    {
        [tvUARTInfo reloadData];
    }
    if (kTag_TableView_CSVLog == [tabView indexOfTabViewItem:tabViewItem])
    {
        [tvCSVInfo reloadData];
    }
}
*/
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    @synchronized(m_arrFailInfo)
    {
        if (([m_arrFailInfo count] > [tvFailInfo selectedRow]))
        {
			NSAttributedString * attriStrConsole = [[m_arrFailInfo objectAtIndex:[tvFailInfo selectedRow]] objectForKey:kFunnyZoneConsoleMessage];
			[textViewFailInfo setSelectedRange:NSMakeRange( 0, [[textViewFailInfo string] length])];
            [textViewFailInfo delete:nil];
			[[textViewFailInfo textStorage] insertAttributedString:attriStrConsole atIndex:0];
            [textViewFailInfo scrollRangeToVisible: NSMakeRange( 0, 0)];
        }
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    if (aTableView.tag == kTag_TableView_CSVLog)
    {
        @synchronized(m_arrCSVInfo)
        {
            return [m_arrCSVInfo count];
        }
    }
    else if (aTableView.tag == kTag_TableView_UartLog)
    {
        @synchronized(m_arrUARTInfo)
        {
            return [m_arrUARTInfo count];
        }
    }
    else if (aTableView.tag == kTag_TableView_FailItems)
    {
        @synchronized(m_arrFailInfo)
        {
            return [m_arrFailInfo count];
        }
    }
    else if (aTableView.tag == kTag_TableView_Drawer)
    {
        @synchronized(m_arrDrawerFailItemsInfo)
        {
            return [m_arrDrawerFailItemsInfo count];
        }
    }
    else
    {
        return 0;
    }
    return 0;
}

- (id) tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    NSMutableArray *arrCommon = nil;
	if (aTableView.tag == kTag_TableView_CSVLog)
	{ 
        arrCommon = m_arrCSVInfo;
	}
    else if (aTableView.tag == kTag_TableView_UartLog)
	{
        arrCommon = m_arrUARTInfo;
	}
    else if (aTableView.tag == kTag_TableView_FailItems)
	{
        arrCommon = m_arrFailInfo;
	}
    else if (aTableView.tag == kTag_TableView_Drawer)
	{
        arrCommon = m_arrDrawerFailItemsInfo;
	}
    else
    {
        NSLog(@"TABLEVIEW ERROR: Can't get the tableview identifier");
        [pool drain];
        return @"";
    }
    
    id theValue = @"";
    
    @synchronized(arrCommon)
    {
        //when call setobject for tableview , rowIndex will be the row you selected , but when test begin,we need clear last test's record. Now rowIndex will bigger than [arrCommon count](0), so here will crash, add this judgement to return
        if ([arrCommon count] == 0) 
        {
            return nil;
        }
        //end
        NSParameterAssert(rowIndex >= 0 && rowIndex < [arrCommon count]);
        
        NSString *identifier = [aTableColumn identifier];        
        if (nil == identifier)
        {
            NSLog(@"TABLEVIEW ERROR: Nil indentifier at row index: %d", rowIndex);
            [pool drain];
            return @"";
        }
        
        id theRecord = [arrCommon objectAtIndex:rowIndex];
        if(theRecord)
        {
            if([identifier isEqualToString:kAllTableViewIndex])
            {
                theValue = [theRecord objectForKey:kAllTableViewIndex];
            }
            else if([identifier isEqualToString:kAllTableViewResultImage])
            {
                theValue = [theRecord objectForKey:kAllTableViewResultImage];
            }
            else if([identifier isEqualToString:kAllTableViewSpec])
            {
                theValue = [theRecord objectForKey:kAllTableViewSpec];
                
            }
            else if([identifier isEqualToString:kAllTableViewItemName])
            {
                theValue = [theRecord objectForKey:kAllTableViewItemName];
            }
            else if([identifier isEqualToString:kAllTableViewRetureValue])
            {
                theValue = [theRecord objectForKey:kAllTableViewRetureValue];
            }
            else if([identifier isEqualToString:kAllTableViewCostTime])
            {
                theValue = [theRecord objectForKey:kAllTableViewCostTime];
            }
            else if([identifier isEqualToString:kPD_Notification_Time])
            {
                theValue = [theRecord objectForKey:kPD_Notification_Time];
            }
            else if([identifier isEqualToString:kFZ_Script_DeviceTarget])
            {
                theValue = [theRecord objectForKey:kFZ_Script_DeviceTarget];
            }
            else if([identifier isEqualToString:kIADeviceNotificationTX])
            {
                theValue = [theRecord objectForKey:kIADeviceNotificationTX];
            }
            else if([identifier isEqualToString:kDrawerViewFailName])
            {
                NSTextFieldCell *tfTitle = [aTableColumn dataCellForRow:rowIndex];
                [tfTitle setStringValue:[m_arrDrawerFailItemsInfo objectAtIndex:rowIndex]];
                theValue = [m_arrDrawerFailItemsInfo objectAtIndex:rowIndex];
            }
            else if([identifier isEqualToString:kDrawerViewOV])
            {
                NSButtonCell* cellCheckBox = [aTableColumn dataCellForRow:rowIndex];
                [cellCheckBox setTag:rowIndex];
                [cellCheckBox setAction:@selector(drawerCheckBoxCellClick:)];
                [cellCheckBox setTarget:self];
                NSInteger iTemp = [[m_arrDrawerCheckBoxInfo objectAtIndex:rowIndex] intValue];
                [cellCheckBox setState:iTemp];
                
                theValue = cellCheckBox;
            }
            else
            {
                theValue = @"";
                NSLog(@"TABLEVIEW EERO: Can't get current identifier");
            }
        }
        else
        {
            theValue = @"";
            NSLog(@"TABVIEW EERO: Tableview can't get information at index \"%d\"", rowIndex);
        }
        
        NSLog(@"TABLEVIW INFO: Current Tableview is \"%d\", Identifier is \"%@\", Value is \"%@\".", aTableView.tag, identifier, theValue);
    }
	[pool drain];
	//return theValue;
    return nil;
}


- (void)controlTextDidBeginEditing:(NSNotification *)aNotification
{
    if ([m_arrSNTextFields containsObject:[aNotification object]]) 
    {
        m_iSNNumber = [m_arrSNTextFields indexOfObject:[aNotification object]];
        NSLog(@"controlTextDidBeginEditing: (sn label: \"%@\") (object address: %@) ", [[m_arrSNLables objectAtIndex:m_iSNNumber] stringValue], [aNotification object]);
        
        // only enable the key equivalent of "Start" button for the active unit/slot 
        if ([[[m_dicMuifa_Plist objectForKey:kUserDefaultModeSetting] objectForKey:kUserDefaultManualStartTest] boolValue]
            && [[[m_dicMuifa_Plist objectForKey:kUserDefaultModeSetting] objectForKey:kUserDefaultCurrentMode] isEqualToString:kMuifa_Window_Mode_MFMU])        
        {
            if ([m_arrObjTemplate containsObject:self])
            {
                int iCount = [m_arrObjTemplate count];
                int iNumber = [m_arrObjTemplate indexOfObject:self];
                for (int i = 0; i < iCount; i++) 
                {
                    Template *objTemplate = [m_arrObjTemplate objectAtIndex:i];
                    if (i == iNumber)
                    {
                        [objTemplate.btnStart setKeyEquivalent:@"\r"];
                    }
                    else
                    {
                        [objTemplate.btnStart setKeyEquivalent:@""];                        
                    }
                }
            }
        }
    }
}

// set and open a alert panel to notice operator
- (void)changeScriptFile:(NSString *)szNewScriptFile InformativeText:(NSString *)szInformativeText TestOnce:(BOOL)bTestOnce
{
    NSLog(@"changeScriptFile begin");
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    //Add by Betty on 2012.05.08 If bAutoRunInit is YES, don't show "NO" button in the alert panel. else show "NO" button.
   // NSDictionary *dicTestOnceScript = [[kFZ_UserDefaults objectForKey:kUserDefaultScriptInfo] objectForKey:kUserDefaultTestOnceScriptName];
    BOOL bAutoRunInit = [[[kFZ_UserDefaults objectForKey:kUserDefaultModeSetting] objectForKey:kUserDefaultAutoInitFixture] boolValue];
    // end by betty
    [alert addButtonWithTitle:@"确定(YES)"];
    m_bTestOnceScript =bTestOnce;
    if (!bAutoRunInit) 
    {
        [alert addButtonWithTitle:@"取消(NO)"];
    }
    
    [alert setMessageText:[NSString stringWithFormat:@"警告(Warning)(slot:%@)",m_szCurrentUnit]];
    [alert setInformativeText:szInformativeText];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:m_UI modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:szNewScriptFile];
    NSLog(@"changeScriptFile end");
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    
    if (returnCode == NSAlertFirstButtonReturn) 
    {
        // if click YES button, parse and load test once script file
        //=============modify for Clear CB===============
        
        //modify by lucy for Clear CB
        if ([(NSString *)contextInfo isEqualTo:@"FATP_CB Erase.plist"] )
        {
            [self changeSNManage];
        }
        //=============modify for Clear CB=============== 
        //modified by lucy for test once or not once
        [self parseAndLoadScriptFile:contextInfo OnlyTestOnce:m_bTestOnceScript];
        if (![self GetSNRuleCheckByPlist])
        {
            [viewSNLabels    setHidden:YES];
        }
        else
        {
            [viewSNLabels    setHidden:NO];
            [[m_arrSNTextFields objectAtIndex:0] becomeFirstResponder];
        }
    }
    else if(returnCode == NSAlertSecondButtonReturn)
    {
        // if click NO button, do nothing
    }
    else
    {
        // else, do nothing
    }
}

/*
 * Kyle 2012.02.15
 * abstract   : get kingds of SN by script , and memory 
 */
- (void)showScanSN:(NSNotification *)notification
{
    bCheckScanSN                    = NO;
    arrayTxt                        = [NSMutableArray arrayWithArray:nil];
    arrayLable                      = [NSMutableArray arrayWithArray:nil];
    arraySize                       = [NSMutableArray arrayWithArray:nil];
    NSDictionary *dicUserInfo       = [notification userInfo];
    NSArray *arrayKeys              = [dicUserInfo objectForKey:@"dicScanSN"];
    NSArray *arrayObjects           = [[panelSN contentView] subviews];
    
    // Clear conttrol info 
    for (int i = 0; i < [arrayObjects count]; i++) 
    {
        if (1 == [[arrayObjects objectAtIndex:i] tag]) 
        {
            [[arrayObjects objectAtIndex:i] removeFromSuperview];
        }
    }
    
    // creat textField by notification userinfo
    for (int i = 0, x = 30 + 40*[arrayKeys count]; i < [arrayKeys count]; i++) 
    {
        // set panel height
        NSRect rectFrame = [panelSN frame];
        rectFrame.size.height = 40*[arrayKeys count] + 120;
        [panelSN setFrame:rectFrame display:YES];
        
        NSString *szKey = [[[arrayKeys objectAtIndex:i] allKeys] objectAtIndex:0];
        NSTextField *txtName = [[NSTextField alloc] initWithFrame:NSMakeRect(30, (float)x, 80, 30)];
        [txtName setStringValue:szKey];
        [txtName setBordered:NO];
        [txtName setEditable:NO];
        [txtName setBackgroundColor:[panelSN backgroundColor]];
        [txtName setTag:1];
        NSTextField *txtSN   = [[NSTextField alloc] initWithFrame:NSMakeRect(130, (float)(x+5), 230, 30)];
        [txtSN setTag:1];
        [arrayTxt addObject:txtSN];
        [arrayLable addObject:[txtName stringValue]];
        [arraySize addObject:[[arrayKeys objectAtIndex:i] objectForKey:szKey]];
        [txtSN setDelegate:self];
        [txtSN setFocusRingType:NSFocusRingTypeDefault];
        
        x -= 40;
        [[panelSN contentView] addSubview:txtName];
        [[panelSN contentView] addSubview:txtSN];
        
        [txtName release];
        [txtSN release];
    }
    [NSApp runModalForWindow:panelSN];
}

- (IBAction)CheckMPNRegion:(id)sender 
{
    NSMutableDictionary *muDic = [[NSMutableDictionary alloc] init];
    for (int i =0;i < [arrayTxt count]; i++) 
    {
        NSTextField *txtSN  = [arrayTxt objectAtIndex:i];
        NSString *szTxt       = [txtSN stringValue];
        int iLength         = [szTxt length];
        if ([szTxt isEqualToString:@""]) 
        {
            [muDic release];
            [NSApp stopModal];
            [panelSN orderOut:nil];
            return;
        }
        else if ((0 != [arraySize objectAtIndex:i]) && (iLength != [[arraySize objectAtIndex:i] intValue]))
        {
            NSString *szName = [arrayLable objectAtIndex:i];
            int iTemp = [[arraySize objectAtIndex:i] intValue];
            NSRunAlertPanel(@"错误(Error)", [NSString stringWithFormat:@"%@长度不匹配，长度应该为%d。(%@ lengh error ! must be %d)",szName,iTemp,szName,iTemp], @"确认(OK)", nil, nil);
            
            [muDic release];
            [NSApp stopModal];
            [panelSN orderOut:nil];
            return;
        }
        
        [muDic setObject:[[arrayTxt objectAtIndex:i] stringValue] forKey:[arrayLable objectAtIndex:i]];
        if (i < [arrayTxt count]-1)
            [panelSN makeFirstResponder:[arrayTxt objectAtIndex:i+1]];
    }
    [testProgress.m_dicMemoryValues setValuesForKeysWithDictionary:[NSDictionary dictionaryWithDictionary:muDic]];
    [testProgress.m_dicMemoryValues setObject:@"1" forKey:@"ScanSNFlag"];
    [muDic release];
    [NSApp stopModal];
    [panelSN orderOut:nil];
}

// 2012.2.20 Desikan 
//      Prox-Cal show ready bug(finished test,before plug out unit,ui show READY,but not PASS/FAIL),
//      get SN from Fonnyzone
-(void)getDataFromFonnyZone:(NSNotification *)note
{
    NSString *szPortPath    =   [[note userInfo] objectForKey:@"CurrentPath"];
    NSString *szISNFromUnit =   [[note userInfo] objectForKey:@"ISNFromUnit"];
    if(szPortPath && [szPortPath isNotEqualTo:@""])
    {
        if (m_szSerialPortPath) [m_szSerialPortPath release];
        m_szSerialPortPath =  [[NSString stringWithFormat:@"%@",szPortPath] retain];
    }
    if(szISNFromUnit &&[szISNFromUnit isNotEqualTo:@""] &&[szISNFromUnit isKindOfClass:[NSString class]])
    {
        [lbUnitMark setStringValue:[NSString stringWithFormat:@"[%@]%@", m_szCurrentUnit, szISNFromUnit]];
    }
}

// 2012.4.21 Sky
//      Separate iPad-1 show voltage of the unit from Prox-Cal show ready bug. 
-(void)showVoltageOnUI:(NSNotification *)note
{
    //for iPad show voltage on UI
    BOOL bReset = [[[note userInfo] objectForKey:@"reset"] boolValue];
    if (bReset) {
        [lblVoltage setStringValue:@""];
        [lblPercentage setStringValue:@""];
    }
    else
    {
        NSString *szVoltage = [[note userInfo] objectForKey:@"Voltage"];
        NSString *szPercent = [[note userInfo] objectForKey:@"Percent"];
        NSFont *font = [NSFont fontWithName:@"Times-Roman" size:18];
        if (szVoltage || szPercent) 
        {
            if (szVoltage) 
            {
                if ([szVoltage intValue]<3800) 
                {
                    [lblVoltage setTextColor:[NSColor redColor]];  
                    [lblPercentage setTextColor:[NSColor redColor]];
                }
                [lblVoltage setFont:font];
                [lblVoltage setStringValue:szVoltage];
            }
            if (szPercent) 
            {
                [lblPercentage setFont:font];
                [lblPercentage setStringValue:szPercent];
            }
        }
    }
}
- (void)controlBeforeBrotherTest
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    // get response of command "START"
    g_bBrotherTestReady = YES;
    [pool release];
}

//add for interposer and grape-1
-(void)MonitorsensorhaveIn:(NSNotification*)note
{
    m_bGrapeSensorIN = YES;
    
}

//add for interposer and grape-1
- (void)MonitorGrapeSensorIN:(id)idThread
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSMutableString *szResult = [[NSMutableString alloc] init];
    if (testProgress == nil)
    {
        testProgress = [[TestProgress alloc] init];
    }
    [testProgress MSGBOX_COMMAND:idThread RETURN_VALUE:szResult];
    [szResult release];
	[pool drain];
}

- (void)transterToMuifa:(NSNotification *)aNote
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:BNRStartTestOnePatternNotification object:self userInfo:[aNote userInfo]];
}

- (IBAction)antsTestFAIL:(id)sender
{
    NSDictionary *dicAntsTest = [[m_dicMuifa_Plist objectForKey:kUserDefaultModeSetting] objectForKey:@"ANTS"];
    NSDictionary *dicDrawerContent = [dicAntsTest objectForKey:@"Drawer Content"];
    NSArray *arrLCDFunctionFail = [dicDrawerContent  objectForKey:@"LCD Function Fail"];
    NSArray *arrCheckBoxFlag = [dicDrawerContent  objectForKey:@"Check Box Status"];
    [self loadLCDFunctionFailDrawer:arrCheckBoxFlag FailItems:arrLCDFunctionFail];
    NSSize sizeDefault = [drawerAnts contentSize];
    [drawerAnts setMinContentSize:NSMakeSize(sizeDefault.width + 100, sizeDefault.height)];
    [drawerAnts setParentWindow:[NSApp mainWindow]];
    
    [lbDrawerFlag setDrawsBackground:YES];
    [lbDrawerFlag setBackgroundColor:m_colorForUnit];
    [lbDrawerFlag setStringValue:m_szCurrentUnit];
    
    [drawerAnts open];
}


- (IBAction)drawerOK:(id)sender
{
    if (m_dicDrawerFailItmes)
    {
        NSMutableString *szFailMessage = [[NSMutableString alloc] initWithString:@""];
        NSMutableString *szEnglishMsg = [[NSMutableString alloc] initWithString:@""];
        int iTotal = [m_arrDrawerCheckBoxInfo count];
        for (int i = 0; i < iTotal; i++)
        {
            NSInteger iStatus = [[m_arrDrawerCheckBoxInfo objectAtIndex:i] intValue];
            if (1 == iStatus)
            {
                NSString *szFail = [NSString stringWithFormat:@"%@", [m_arrDrawerFailItemsInfo objectAtIndex:i]];
                [szFailMessage appendFormat:@"%@&", szFail];
                
                // delete chinese message
                NSString *szRightPart = @"";
                NSRange range = [szFail rangeOfString:@"("];
                if (NSNotFound != range.location
                    && range.length > 0
                    && range.length + range.location <= [szFail length])
                {
                    szRightPart = [szFail substringFromIndex:range.length + range.location];
                }
                szRightPart = [szRightPart substringToIndex:[szRightPart length] - 1];
                [szEnglishMsg appendFormat:@"%@&", szRightPart];
            }
        }
        m_szCT2LCDFailMsg = [[NSString stringWithString: szEnglishMsg] retain];
        NSLog(@"drawerOK: Get Fail message = %@", szFailMessage);
        NSAlert *alert = [[[NSAlert alloc] init] autorelease];
        [alert addButtonWithTitle:@"确认(YES)"];
        [alert addButtonWithTitle:@"取消(NO)"];
        [alert setMessageText:@"警告(Warning)"];
        NSString *szInformativeText = [NSString stringWithFormat:@"请确定：是否要为%@选择下列FAIL项目 ＝ %@。(please make sure you want to let %@ fail at following items: %@)", m_szCurrentUnit, szFailMessage, m_szCurrentUnit, szFailMessage];
        [alert setInformativeText:szInformativeText];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert beginSheetModalForWindow:[NSApp mainWindow] modalDelegate:self didEndSelector:@selector(drawerOKDidEnd:returnCode:contextInfo:) contextInfo:nil];
        
        [szEnglishMsg release];
        [szFailMessage release];
    }
    
    [drawerAnts close];
}

- (void)loadLCDFunctionFailDrawer:(NSArray *)arrCheckBox FailItems:(NSArray *)arrFailItems
{
    [m_arrDrawerFailItemsInfo removeAllObjects];
    [m_arrDrawerCheckBoxInfo removeAllObjects];
    if (nil == m_arrDrawerFailItemsInfo)
    {
        m_arrDrawerFailItemsInfo = [[NSMutableArray alloc] init];
    }
    if (nil == m_arrDrawerCheckBoxInfo)
    {
        m_arrDrawerCheckBoxInfo = [[NSMutableArray alloc] init];
    }
    [m_arrDrawerFailItemsInfo addObjectsFromArray:arrFailItems];
    [m_arrDrawerCheckBoxInfo addObjectsFromArray:arrCheckBox];
    
    @synchronized(m_arrDrawerFailItemsInfo)
    {
        [tvDrawer reloadData];
    }
}

- (void)drawerCheckBoxCellClick:(id)sender
{
    NSButtonCell* cell = (NSButtonCell *)[tvDrawer selectedCell];
    if([cell state] == 1)
    {
        [cell setState:0];
    }
    else
    {
        [cell setState:1];
    }
    NSLog(@"drawerCheckBoxCellClick = %d",[[tvDrawer selectedCell] tag]);
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	
	NSString *strIdentifier=[aTableColumn identifier];
	if([strIdentifier isEqualToString:kDrawerViewOV])
    {
		NSInteger iTemp = [[m_arrDrawerCheckBoxInfo objectAtIndex:rowIndex] intValue];
		if(1 == iTemp)
        {
            iTemp = 0;
        }
        else
        {
            iTemp = 1;
        }
		[m_arrDrawerCheckBoxInfo replaceObjectAtIndex:rowIndex withObject:[NSString stringWithFormat:@"%d", iTemp]];
	}
	else
    {

	}
}


- (void)drawerOKDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode == NSAlertFirstButtonReturn) 
    {
        if (testProgress)
        {
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc postNotificationName:BNRDrawerOKClickedNotification object:testProgress userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithString:m_szCT2LCDFailMsg], @"LCDFAILMSG", [NSString stringWithString:m_szCurrentUnit], @"CURRENTUNIT", nil]];
        }
        
    }
    else if(returnCode == NSAlertSecondButtonReturn)
    {
        // if click NO button, do nothing
    }
    else
    {
        // else, do nothing
    }
}

-(NSAttributedString *)getAttributeString:(NSString *)szName Color:(NSColor *)color
{
     NSFont *font = [NSFont fontWithName:@"Charcoal CY" size:15];
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    [paraStyle setAlignment:NSCenterTextAlignment];
    NSDictionary *dicAttribut = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,color, NSForegroundColorAttributeName,paraStyle, NSParagraphStyleAttributeName, nil];
    NSAttributedString * szAttributeString = [[NSAttributedString alloc] initWithString:szName attributes:dicAttribut];
    [paraStyle release];
    return szAttributeString;
}

-(void)showMessage:(NSNotification *)note
{
    // enale FAIL button for Ants Test
    BOOL bAntsTest = [[[[kFZ_UserDefaults objectForKey:kUserDefaultModeSetting] objectForKey:@"ANTS"] objectForKey:@"AntsTest"] boolValue];
    
    NSString  *szButtons = [[note userInfo] objectForKey:@"ABUTTONS"];
    BOOL bHaveButton = YES;
    if ([szButtons isEqualToString:@""])
    {
        bHaveButton = NO;
    }
    NSArray  *arrButtons = [szButtons componentsSeparatedByString:@","];
    m_iBtnCount = [arrButtons count];
    //  m_bNoButton = (m_iBtnCount == 0)?YES:NO;
    
    if (bAntsTest)
    {
        [self.btnAntsFAIL setEnabled:YES];
        [self.btnAntsFAIL setHidden:NO];
	}
    NSView *view = [viewInfo superview];
    NSRect rect1 = [viewInfo frame];
    NSRect rect2 = [viewIndicator frame];
    NSRect rect3 = [viewButtons frame];
    [m_txtMessage initWithFrame:rect1];
    NSRect rect = NSMakeRect(rect1.origin.x, rect1.origin.y, rect2.size.width, rect1.size.height);
    [m_txtMessage setFrame:rect];
    [m_txtMessage setFocusRingType:NSFocusRingTypeNone];
    [m_txtMessage setBordered:YES];
    NSString *szMsg = [[note userInfo] objectForKey:@"MESSAGE"];
    [m_txtMessage setStringValue:szMsg];
    [m_txtMessage setTextColor:[NSColor blackColor]];
	[m_txtMessage setEditable:NO];
    NSFont *font = [NSFont fontWithName:@"Charcoal CY" size:14];
    [m_txtMessage setFont:font];
    NSColor *color = [testProgress.m_dicMemoryValues objectForKey:kPD_AMIOK_PanelColor];
    [m_txtMessage setBackgroundColor:color];
    [m_txtMessage setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin | NSViewWidthSizable | NSViewMinYMargin];
    NSArray *arrSubview = [view subviews];
    if ([arrSubview containsObject:m_txtMessage]) 
    {
        [m_txtMessage removeFromSuperview];
    }
    [view addSubview:m_txtMessage];
    
    [viewJudgeButton setFrame:rect3];
    if (bHaveButton)
    {
        [[viewButtons superview] addSubview:viewJudgeButton];
        switch (m_iBtnCount) {
            case 1:
            {
                [btnFail setHidden:YES];
                SEL selectorForFunction = NSSelectorFromString([NSString stringWithFormat:@"%@:",[btnPass title]]);
                [btnPass setTarget:self];
                [btnPass setAction:selectorForFunction];
                NSAttributedString *szAttString = [self getAttributeString:[arrButtons objectAtIndex:0] Color:[NSColor blueColor]];
                [btnPass setTitle:szAttString];
                [szAttString release];
                break;
            }
            case 2: 
            {
                NSAttributedString *szAttPassString = [self getAttributeString:[arrButtons objectAtIndex:0] Color:[NSColor greenColor]];
                NSAttributedString *szAttFailString = [self getAttributeString:[arrButtons objectAtIndex:1] Color:[NSColor redColor]];
                [btnPass setTitle:szAttPassString];
                [btnFail setTitle:szAttFailString];
                [btnFail setHidden:NO];
                SEL selectorForFunction1 = NSSelectorFromString([NSString stringWithFormat:@"%@:",[btnPass title]]);
                SEL selectorForFunction2 = NSSelectorFromString([NSString stringWithFormat:@"%@:",[btnFail title]]);
                [btnPass setTarget:self];
                [btnPass setAction:selectorForFunction1];
                [btnFail setTarget:self];
                [btnFail setAction:selectorForFunction2];
                [szAttPassString release];
                [szAttFailString release];
                break;
            }

            default:
                break;
        }
        [viewButtons setHidden:YES];

    }
}

-(void)closeMessage:(NSNotification *)note
{
    // enale FAIL button for Ants Test
    BOOL bAntsTest = [[[[kFZ_UserDefaults objectForKey:kUserDefaultModeSetting] objectForKey:@"ANTS"] objectForKey:@"AntsTest"] boolValue];
    if (bAntsTest)
    {
        [self.btnAntsFAIL setEnabled:NO];
        [self.btnAntsFAIL setHidden:YES];
	}
    [m_txtMessage removeFromSuperview];
    [viewJudgeButton removeFromSuperview];
}

- (void)unCheckbox:(NSNotification *)note
{           
    NSMutableString *szFixtureResponse = [[NSMutableString alloc]init];
    NSString  *szFixturePort = [[m_dicPorts objectForKey:@"FIXTURE"] objectAtIndex:0];
    TestProgress *objTestProgress = [[TestProgress alloc] init];
    NSString *szUUT = [[note userInfo] objectForKey:@"UUT"];
    m_strControlCable = [NSString stringWithString:szUUT];
    
    NSFileManager *fileManger = [NSFileManager defaultManager];
    if (![fileManger fileExistsAtPath:kFxitureControlPlistPath])
    {
        NSDictionary *dicFixture = [NSDictionary dictionaryWithObjectsAndKeys:m_strControlCable,@"FIXTURENUMBER",nil];
        [dicFixture writeToFile:kFxitureControlPlistPath atomically:NO];
    }
    else
    {
        NSDictionary *dicFixtureControl = [[NSDictionary alloc] initWithContentsOfFile:kFxitureControlPlistPath];
        NSString *strGetFxitureCable = [NSString stringWithString:[dicFixtureControl objectForKey:@"FIXTURENUMBER"]];
        if (![strGetFxitureCable isEqualToString:m_strControlCable]) 
        {
            NSDictionary *dicFixture = [NSDictionary dictionaryWithObjectsAndKeys:m_strControlCable,@"FIXTURENUMBER",nil];
            [dicFixture writeToFile:kFxitureControlPlistPath atomically:NO];
        }
        [dicFixtureControl release];
    }
    
    if (![szUUT isEqualToString:[NSString stringWithString:m_strSerialPort]]) 
    {
        
        if ([objTestProgress checkUnitConnectWellWithFixturePort:szFixturePort UARTCommand:@"clr channels" UartResponse:szFixtureResponse CheckTime:1.0]) 
        {
            if ([szFixtureResponse ContainString:@"OK"]) 
            {
                [btnChooseCable setState:NSOffState];
                [tfChooseCable setStringValue:@"Cable UnUse"];
            }
            else
            {
                NSString *strWarning = [NSString stringWithFormat:@"%@ 治具控制線不能關閉串口，請檢查!(%@ Fixture Control Cable Can't Close Port ,Please Check!)",m_strSerialPort,m_strSerialPort];
                m_strControlCable = [NSString stringWithString:@"NONE"];
                NSDictionary *dicFixture = [NSDictionary dictionaryWithObjectsAndKeys:m_strControlCable,@"FIXTURENUMBER",nil];
                [dicFixture writeToFile:kFxitureControlPlistPath atomically:NO];
                [btnChooseCable setState:NSOffState];
                NSRunAlertPanel(@"Warning", strWarning, @"YES", nil, nil);
            }
        }
        else
        {
            NSString *strWarning = [NSString stringWithFormat:@"%@ 治具控制線不能關閉串口，請檢查!(%@ Fixture Control Cable Can't Close Port ,Please Check!)",m_strSerialPort,m_strSerialPort];
            m_strControlCable = [NSString stringWithString:@"NONE"];
            NSDictionary *dicFixture = [NSDictionary dictionaryWithObjectsAndKeys:m_strControlCable,@"FIXTURENUMBER",nil];
            [dicFixture writeToFile:kFxitureControlPlistPath atomically:NO];
            [btnChooseCable setState:NSOffState];
            NSRunAlertPanel(@"Warning", strWarning, @"YES", nil, nil);
        }
    }
    else
    {
        if ([[tfCheckBox stringValue] isEqualToString:@"Unit Unuse"]) 
        {
            NSRunAlertPanel(@"警告(Warning)", @"當前對象不可用，請選擇其他的治具控制線！(This Object Can't Work,Please Choose Other Fixture Control Cable!)", @"YES", nil, nil);
            [btnChooseCable setState:NSOffState];
        }
        else
        {
            if ([objTestProgress checkUnitConnectWellWithFixturePort:szFixturePort UARTCommand:@"set channels" UartResponse:szFixtureResponse CheckTime:1.0]) 
            {
                if ([szFixtureResponse ContainString:@"OK"]) 
                {
                    [btnChooseCable setState:NSOnState];
                    [tfChooseCable setStringValue:@"Cable In Use"];
                }
                else
                {
                    NSString *strWarning = [NSString stringWithFormat:@"%@ 治具控制線不能打開串口，請檢查!(%@ Fixture Control Cable Can't Open Port ,Please Check!)",m_strSerialPort,m_strSerialPort];
                    m_strControlCable = [NSString stringWithString:@"NONE"];
                    NSDictionary *dicFixture = [NSDictionary dictionaryWithObjectsAndKeys:m_strControlCable,@"FIXTURENUMBER",nil];
                    [dicFixture writeToFile:kFxitureControlPlistPath atomically:NO];
                    [btnChooseCable setState:NSOffState];
                    NSRunAlertPanel(@"Warning", strWarning, @"YES", nil, nil);
                }
            }
            else
            {
                NSString *strWarning = [NSString stringWithFormat:@"%@ 治具控制線不能打開串口，請檢查!(%@ Fixture Control Cable Can't Open Port ,Please Check!)",m_strSerialPort,m_strSerialPort];
                m_strControlCable = [NSString stringWithString:@"NONE"];
                NSDictionary *dicFixture = [NSDictionary dictionaryWithObjectsAndKeys:m_strControlCable,@"FIXTURENUMBER",nil];
                [dicFixture writeToFile:kFxitureControlPlistPath atomically:NO];
                [btnChooseCable setState:NSOffState];
                NSRunAlertPanel(@"Warning", strWarning, @"YES", nil, nil);
            }
        }
    }
    
    [szFixtureResponse release];
    [objTestProgress release];
}

- (void)setDefaultCable:(NSString *)cableNumber
{
    [btnChooseCable setState:NSOnState];
    [tfChooseCable setStringValue:@"Cable In Use"];
    //m_strControlCable = [NSString stringWithString:cableNumber];
    
}
- (void)setDefaultStatus:(NSString *)cableNumber
{
    //m_strControlCable = [NSString stringWithString:cableNumber];
    
}

- (IBAction)chooseCable:(id)sender
{
    NSLog(@"chooseCable begin");
    if (![[tfChooseCable stringValue] isEqualToString:@"Cable In Use"]) 
    {
        [btnChooseCable setState:NSOffState];
    }
    else
    {
        
        [btnChooseCable setState:NSOnState];
    }
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    NSDictionary *dicTemp = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithString: m_strSerialPort],@"UUT", nil];
    [nc postNotificationName:@"BNRUsePasswordWindowNotification" object:self userInfo:dicTemp];
    
    
    
    NSLog(@"chooseCable end");
}

-(IBAction)PASS:(id)sender
{
    testProgress.m_ReturnValue = YES;
    testProgress.m_StopFlag = YES;
    [m_txtMessage removeFromSuperview];
    [viewJudgeButton removeFromSuperview];
    [viewButtons setHidden:NO];
}
-(IBAction)FAIL:(id)sender
{
    testProgress.m_ReturnValue = NO;
    testProgress.m_StopFlag = YES;
    [m_txtMessage removeFromSuperview];
    [viewJudgeButton removeFromSuperview];
    [viewButtons setHidden:NO];
}
-(IBAction)OK:(id)sender
{
    testProgress.m_ReturnValue = YES;
    testProgress.m_StopFlag = YES;
    [m_txtMessage removeFromSuperview];
    [viewJudgeButton removeFromSuperview];
    [viewButtons setHidden:NO];
}

// Get the boolean value which used for SNRuleCheck from setting file by plist          // add by Gordon 11.21
- (BOOL)GetSNRuleCheckByPlist
{
    BOOL bRet = YES;
    NSDictionary *dicCheckSum = [[m_dicMuifa_Plist objectForKey:@"PlistCheckFunction"] objectForKey:m_szTestScriptFilePath];
    if (dicCheckSum) 
    {
        bRet = [[dicCheckSum objectForKey:@"NeedSNRuleCheck"] boolValue];
    }
    
    return bRet;
}


@end
