//
//  Template.h
//  Muifa
//
//  Created by Gordon Liu on 9/22/11.
//  Copyright 2011 PEGATRON. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Muifa_Define.h"
#import "FunnyZone/TestProgress.h"
#import "Funnyzone/IADevice_DetectPort.h"
#import "Funnyzone/IADevice_Operation.h"
#import "FunnyZone/LoadingCAS140.h"

// auto test system(V2 .h files)
#import "eTraveler/eTravelerParameterKeys.h"
#import "eTraveler/eTraveler_TestResult.h"
#import "AppleTestStationAutomation/AppleControlledStation.h"
#import "AppleTestStationAutomation/AppleTestStationAutomation.h"
#import "AppleTestStationAutomation/AppleControlledStationDelegate.h"

// 2012.2.20 Desikan for Prox-Cal show ready bug(finished test,before plug out unit,ui show READY,but not PASS/FAIL),
extern NSString * const PostDataToMuifaNote;

// 2012.4.21 Sky separate iPad-1 show voltage of the unit from Prox-Cal show ready bug 
extern NSString * const ShowVoltageOnUI;

extern NSString * const BNRTransferToMuifaNotification;



@interface Template : NSObject<NSApplicationDelegate, NSTableViewDelegate, NSTableViewDataSource, NSTabViewDelegate,NSTextFieldDelegate,AppleControlledStationDelegate>
{    
    NSView                      *viewMain;
    BOOL                        m_bTestPass;
    BOOL                        m_bStopTest;
    BOOL                        m_bTestOnceScript;
    BOOL                        m_bManualClickTest;
    NSInteger                   m_iRunCount;
    TestProgress                *testProgress;
    NSOperationQueue            *m_queue;
    NSDictionary                *m_dictGroundHogInfo;
    NSString                    *m_szStartTime;
    NSArray                     *m_arrayDevices;
    NSArray                     *m_arrScriptFile;
    NSColor                     *m_colorForUnit;
    NSDictionary                *m_dicParaFromMuifa;
    NSString                    *m_szSerialPortPath;
    NSString                    *m_szFixturePortPath;
    NSArray                     *m_arrSNLables;
    NSArray                     *m_arrSNTextFields;
    NSString                    *m_szCurrentMode;
    NSString                    *m_szCurrentUnit;
    NSMutableDictionary         *m_dicSNsFromUI;
    NSString                    *m_szMainSN;
    NSDictionary                *m_dicGHInfo;   
    NSDictionary                *m_dicMuifa_Plist;
    NSUInteger                  m_iSNNumber;
    NSWindow                    *m_windowUI;
    NSWindow                    *m_UI;
    NSArray                     *m_arrObjTemplate;
    NSString                    *m_szUIVersion;
    NSString                    *m_szScriptVersion;
    NSString                    *m_szScriptName;        //add by xiaoyong for summary log
    NSArray                     *m_arrTestOnceScript;
    NSString                    *m_szTestScriptFilePath;//added by lucy for decide two plist file
    NSString                    *m_szCT2LCDFailMsg;     // for CT2
    
    // Indicator view object
    IBOutlet NSView             *viewIndicator;
    IBOutlet NSTextField        *lbPercentageNumber;
    IBOutlet NSLevelIndicator   *levelIndicator;
    IBOutlet NSTextField        *lbResultLabel;
    IBOutlet NSTextField        *lbUnitMark;
    IBOutlet NSButton           *btnLinkToTabViewItem;
    
    // Indicator view object
    IBOutlet NSView             *viewInfo;
    IBOutlet NSTextField        *lbTotalCount;
    IBOutlet NSTextField        *lbScriptFile;
    //display mode
    IBOutlet NSView             *viewDisplayMode;
    IBOutlet NSTextField        *lbDislplayMode;
    
    // SN Labels view object
    IBOutlet NSView             *viewSNLabels;
    IBOutlet NSTextField        *lbSN1;
    IBOutlet NSTextField        *lbSN2;
    IBOutlet NSTextField        *lbSN3;
    IBOutlet NSTextField        *lbSN4;
    IBOutlet NSTextField        *lbSN5;
    IBOutlet NSTextField        *lbSN6;
    IBOutlet NSTextField        *tfSN1;
    IBOutlet NSTextField        *tfSN2;
    IBOutlet NSTextField        *tfSN3;
    IBOutlet NSTextField        *tfSN4;
    IBOutlet NSTextField        *tfSN5;
    IBOutlet NSTextField        *tfSN6;
    
    // Buttons view object
    IBOutlet NSView             *viewButtons;
    IBOutlet NSTextField        *lbTotalTime;
    IBOutlet NSButton           *btnAbort;
    IBOutlet NSButton           *btnStart;
    
    // main view object
    IBOutlet NSTabView          *tabTestInfo;
    IBOutlet NSTableView        *tvCSVInfo;
    IBOutlet NSTableView        *tvUARTInfo;
    IBOutlet NSTableView        *tvFailInfo;
    IBOutlet NSTextView         *textViewFailInfo;
    
    // check box object
    IBOutlet NSView             *viewCheckBox;
    IBOutlet NSButton           *btnCheckBox;
    IBOutlet NSTextField        *tfCheckBox;
    IBOutlet NSButton           *btnAntsFAIL;   // for CT2 
    
    // color label object
    IBOutlet NSView             *viewColorLabel;
    IBOutlet NSTextField        *lbColorLabel;
    
    // label for show voltage and percent
    IBOutlet NSTextField        *lblVoltage;
    IBOutlet NSTextField        *lblPercentage;
    IBOutlet NSView             *viewVol;
    
    
    // draw view
    IBOutlet NSDrawer           *drawerAnts;    // for CT2
    IBOutlet NSTableView        *tvDrawer;
    IBOutlet NSButton           *btnDrawerOK;
    IBOutlet NSTextField        *lbDrawerFlag;
    
    
    // data source for table view
    NSMutableArray              *m_arrCSVInfo;
    NSMutableArray              *m_arrUARTInfo;
    NSMutableArray              *m_arrFailInfo;
    NSMutableArray              *m_arrDrawerFailItemsInfo;
    NSMutableArray              *m_arrDrawerCheckBoxInfo;
    NSMutableDictionary         *m_dicDrawerFailItmes;
    
    
    //for display mode, finish test ,then show items
    NSMutableArray              *m_aryCSV;
    NSMutableArray              *m_aryFail;
    
    
    // Show Text Message
    IBOutlet NSTextField        *m_txtMessage;
    IBOutlet NSView             *viewJudgeButton;
    IBOutlet NSButton           *btnPass;
    IBOutlet NSButton           *btnFail;
    NSInteger                   m_iBtnCount;
    BOOL                        m_bNoButton;
    
    //Leehua 11.10.19
    NSMutableDictionary         *m_dicPorts;
    IBOutlet NSPanel            *panelSN;
    
    BOOL                        bCheckScanSN;
    NSMutableArray              *arrayTxt;
    NSMutableArray              *arrayLable;
    NSMutableArray              *arraySize;
    //add by yaya
    BOOL                        m_bGrapeSensorIN;
    
    BOOL                        m_bNoResponse;//Leehua
    
    // Choose Control cable
    IBOutlet NSView             *viewChooseCable;
    IBOutlet NSButton           *btnChooseCable;
    IBOutlet NSTextField        *tfChooseCable;
    NSMutableString             *m_strSerialPort;
    NSMutableArray              *m_arrSerialPort;
    NSString                    *m_strControlCable;
    
    BOOL                        m_bNoNeedConsole;
    NSMutableDictionary         *m_dicEmptyResponse;
    
    // auto test system (var)
    AppleControlledStation      *m_testStation;
    int                         m_iSlot;
    BOOL                        m_bAlreadyError;
    
    
    //display mode
    BOOL                        m_bDislplayMode;
    NSArray                    *m_aryDisplayItem;
    

}

@property (assign)  BOOL            m_bNoResponse;//Leehua
@property(assign)BOOL               m_bDislplayMode;//add by sam for displaymode
@property (retain) NSMutableDictionary *m_dicEmptyResponse;
- (IBAction)CheckMPNRegion:(id)sender;

- (id)initWithParametric:(NSDictionary *)dicPara WithSlot:(int)iSlot;;
- (IBAction)startTest:(NSButton *)sender;
- (IBAction)abortTest:(NSButton *)sender;
- (IBAction)checkBox:(id)sender;
- (IBAction)antsTestFAIL:(id)sender;
- (IBAction)drawerOK:(id)sender;
- (void)loadLCDFunctionFailDrawer:(NSArray *)arrCheckBox FailItems:(NSArray *)arrFailItems;

- (void)setDefaultValueAndGetScriptInfo:(NSString *)szIdentifier CurrentMode:(NSString *)szCurrentMode;
- (void)setSNDefaultLables;
- (void)showCountOnLable:(NSNotification *)aNote;
- (void)processUartLog:(NSDictionary*)dictResult;
- (void)processNormalTest:(NSNotification*)noti;
- (void)setTimeIndicator:(id)iThread;
- (void)MonitorSerialPortPlugIn;
- (void)MonitorSerialPortPlugOut;
- (void)MonitorUnitInFromFixture;
- (void)MonitorUnitOutFromFixture;
- (void)MonitorUnitOutFromFixtureForInitFixture; //add for auto init fixture
- (void)writeCountIntoSettingFile:(NSDictionary *)dicInfo;
- (BOOL)checkAboveSNRule;
- (void)transferTemplateObject:(NSArray *)arrTemplateObj;
- (void)parseAndLoadScriptFile:(NSString *)szcriptFileName OnlyTestOnce:(BOOL) bTestOnce;
//- (void)parseAndLoadScriptFile:(NSString *)szcriptFileName;
/*
 * Kyle 2011.12.19
 * method   : Get_Script_Version:
 * abstract : get version of scriptFile
 * 
 */
// add brother test thread function
- (void)controlBeforeBrotherTest;
- (NSString *)Get_Script_Version;
- (void)changeSNManage;
//- (void)changeScriptFile:(NSString *)szNewScriptFile InformativeText:(NSString *)szInformativeText;
- (void)changeScriptFile:(NSString *)szNewScriptFile InformativeText:(NSString *)szInformativeText TestOnce:(BOOL)bTestOnce;
- (void)changeDisplayMode;
//added by lucy
/*
 * Kyle 2012.02.15
 * abstract   : get kingds of SN by script , and memory 
 */
- (void)showScanSN:(NSNotification *)notification;
-(void)MonitorsensorhaveIn:(NSNotification*)note;//add by yaya

- (void)transterToMuifa:(NSNotification *)aNote;

//add for 4-up grape-1
- (IBAction)chooseCable:(id)sender;
- (void)setDefaultCable:(NSString *)cableNumber;
- (void)setDefaultStatus:(NSString *)cableNumber;
- (void)unCheckbox:(NSNotification *)note;
- (void)showMessage:(NSNotification *)note;
- (void)closeMessage:(NSNotification *)note;

-(NSAttributedString *)getAttributeString:(NSString *)szName Color:(NSColor *)color;

// Get the boolean value which used for SNRuleCheck from setting file by plist          // add by Gordon 11.21
- (BOOL)GetSNRuleCheckByPlist;

- (NSString *)getPlanPlistNameByProductLineName;     // add by Gordon for different line different UI Mode at 1/15/13

-(void)RegisteStation;                                 // auto test system(registe station)

// box view object
@property (assign) IBOutlet NSView              *viewIndicator;

// main view object
@property (assign) IBOutlet NSView              *viewMain;

// Indicator view object
@property (assign) IBOutlet NSView              *viewInfo;

@property (assign) IBOutlet NSView              *viewDisplayMode;

// SN Labels object
@property (assign) IBOutlet NSView              *viewSNLabels;

// Buttons view object
@property (assign) IBOutlet NSView              *viewButtons;

// check box object
@property (assign) IBOutlet NSView              *viewCheckBox;

// color label object
@property (assign) IBOutlet NSView              *viewColorLabel;
@property (assign) IBOutlet NSTextField         *lbColorLabel;

@property (assign) IBOutlet NSButton            *btnCheckBox;
@property (assign) IBOutlet NSButton            *btnAntsFAIL;

// sn text field object
@property (assign) IBOutlet NSTextField         *tfSN1;
@property (assign) IBOutlet NSTextField         *tfSN2;
@property (assign) IBOutlet NSTextField         *tfSN3;
@property (assign) IBOutlet NSTextField         *tfSN4;
@property (assign) IBOutlet NSTextField         *tfSN5;
@property (assign) IBOutlet NSTextField         *tfSN6;
@property (assign) IBOutlet NSButton            *btnStart;
@property (assign) IBOutlet NSButton            *btnAbort;

// GroundHogInfo dictionary
@property (retain)NSDictionary                  *m_dictGroundHogInfo;

// Bool value indicate test state 
@property (assign)BOOL                          m_bStopTest;

//add for 4-up grape-1
@property (retain)NSMutableArray                *m_arrSerialPort;
@property (retain)NSMutableString               *m_strSerialPort;
@property (assign) IBOutlet NSView              *viewChooseCable;
@property (assign) IBOutlet NSButton            *btnChooseCable;
@property (assign) IBOutlet NSView              *viewVol;


// For prox cal
@property (assign)NSString                      *m_szSerialPortPath;
              
@property (assign) IBOutlet NSView              *viewJudgeButton;

// auto test system (need this port to change sn)
@property (retain) TestProgress                 *testProgress;

@end
