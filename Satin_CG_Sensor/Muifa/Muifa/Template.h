//
//  Template.h
//  Muifa
//
//  Created by Gordon Liu on 9/22/11.
//  Copyright 2011 PEGATRON. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "Muifa_Define.h"
#import "CustomTimer.h"
#import "FunnyZone/TestProgress.h"
#import "Funnyzone/IADevice_DetectPort.h"
#import "Funnyzone/IADevice_Operation.h"

//For Pressure Test
#import "FunnyZone/publicParams.h"

@class Template;
@protocol TemplateDelegate <NSObject>
- (void)setNextResponder:(Template *)templateObj;
- (void)linkToTabViewItem:(NSButton *)sender;

//For SMT-QT 2UP
- (BOOL)CheckSNHaveRepeat:(Template *)templateObj;
@end


@interface Template : NSObject
<NSApplicationDelegate,
NSTableViewDelegate,
NSTableViewDataSource,
NSTabViewDelegate,NSTextFieldDelegate,
NSTabViewDelegate>
{    
    NSView                      *listView;
    BOOL                        m_bTestPass;
    BOOL                        m_bRunning;
    BOOL                        m_bTestOnceScript;
    BOOL                        m_bManualClickTest;
    NSInteger                   m_iRunCount;
	CustomTimer					*m_CustomTimer;
    TestProgress                *testProgress;
    NSOperationQueue            *m_queue;
    NSString                    *m_szStartTime;
	NSString					*m_szStartDate;
    NSArray                     *m_arrayDevices;
    NSArray                     *m_arrScriptFile;
    NSColor                     *m_colorForUnit;
    NSDictionary                *m_dicParaFromMuifa;
    NSString                    *m_szSerialPortPath;
    NSArray                     *m_arrSNLables;
    NSArray                     *m_arrSNTextFields;
    NSString                    *m_szCurrentUnit;
    NSMutableDictionary         *m_dicSNsFromUI;
    NSString                    *m_szMainSN;
    NSDictionary                *m_dicGHInfo;   
    NSDictionary                *m_dicMuifa_Plist;
    NSUInteger                  m_iSNNumber;
    NSWindow                    *m_windowUI;
    NSArray                     *m_arrObjTemplate;
    NSMutableString             *m_szUIVersion;
    NSString                    *m_szScriptVersion;
    NSString                    *m_szScriptName;        //add by xiaoyong for summary log
    NSArray                     *m_arrTestOnceScript;
    NSString                    *m_szTestScriptFilePath;//added by lucy for decide two plist file
    // Indicator view object
    IBOutlet NSView             *indicator;
    IBOutlet NSTextField        *lbPercentageNumber;
    IBOutlet NSLevelIndicator   *levelIndicator;
    IBOutlet NSTextField        *lbResultLabel;
    IBOutlet NSTextField        *lbUnitMark;
    
    // Indicator view object
    IBOutlet NSTextField        *lbTotalCount;
    IBOutlet NSTextField        *lbScriptFile;
    
    // SN Labels view object
    IBOutlet NSView             *inputView;
    IBOutlet NSTextField        *lbSN1;
    IBOutlet NSTextField        *lbSN2;
    IBOutlet NSTextField        *lbSN3;
    IBOutlet NSTextField        *lbSN4;
    IBOutlet NSTextField        *lbSN5;
    IBOutlet NSTextField        *lbSN6;
    IBOutlet NSTextField        *serialNum1;
    IBOutlet NSTextField        *serialNum2;
    IBOutlet NSTextField        *serialNum3;
    IBOutlet NSTextField        *serialNum4;
    IBOutlet NSTextField        *serialNum5;
    IBOutlet NSTextField        *serialNum6;
    
    // Buttons view object
    IBOutlet NSTextField        *lbTotalTime;
    IBOutlet NSButton           *btnStart;
    
    // main view object
    IBOutlet NSTabView          *tabTestInfo;
    IBOutlet NSTableView        *tvCSVInfo;
    IBOutlet NSTableView        *tvUARTInfo;
    IBOutlet NSTableView        *tvFailInfo;
    IBOutlet NSTextView         *textViewFailInfo;
  
    // data source for table view
    NSMutableArray              *m_arrCSVInfo;
    NSMutableArray              *m_arrUARTInfo;
    NSMutableArray              *m_arrFailInfo;
	
    //Leehua 11.10.19
    NSMutableDictionary         *m_dicPorts;
    IBOutlet NSPanel            *panelSN;
    
    BOOL                        bCheckScanSN;
    NSMutableArray              *arrayTxt;
    NSMutableArray              *arrayLable;
    NSMutableArray              *arraySize;
    
    BOOL                        m_bEmptyResponse;//Leehua
	BOOL						m_bRunningWithUARTTab;
    
    // Choose Control cable
    IBOutlet NSView             *viewChooseCable;
    
    // For AE stations to choose unit's color
    IBOutlet    NSWindow        *m_windowColorChoiceView;
    IBOutlet    NSMatrix        *m_mtrPanal;
    IBOutlet    NSButton        *m_btnEnterChoice;
	NSMutableString				*m_strAEReadBuffer;
	
	// For CSD BOOT-ARGS station choice.
	IBOutlet	NSWindow		*m_windowStationChoice;
	IBOutlet	NSMatrix		*m_matrixStationChoice;
	
	id <TemplateDelegate>		templateDelegate;
    
    //For Pressure Test
    
    publicParams                *m_objPublicParams;
    
    //For SMT-QT 2UP
    BOOL    m_bAllStarted;
    BOOL    m_bAllEnded;
    BOOL    m_bIsFinished;
    BOOL    m_bAllLoop;
  
    //For Live & JSON file
    BOOL                        m_LiveChanging;
}

//For Pressure Test , Leehua

@property (readwrite,assign)    publicParams        *publicParas;

- (IBAction)ColorChooseEnter:(id)sender;
- (IBAction)checkMPNRegion:(id)sender;

//- (id)initWithParameter:(NSDictionary *)dicPara;
- (id)initWithParametric:(NSDictionary *)dicPara publicParam:(publicParams *)publicParams;//For Pressure Test
- (IBAction)startTest:(id)sender;

- (void)setDefaultValueAndGetScriptInfo:(NSString *)szIdentifier;
- (void)setSNDefaultLables;
- (void)showCountOnLable:(NSNotification *)aNote;
- (void)processUartLog:(NSDictionary*)dictResult;
- (void)processNormalTest:(NSNotification*)noti;
- (void)setTimeIndicator:(id)iThread;
- (void)MonitorSerialPortPlugIn;
- (void)MonitorSerialPortPlugOut;
- (void)writeCountIntoSettingFile:(NSDictionary *)dicInfo;
- (BOOL)checkAboveSNRule;
- (void)transferTemplateObject:(NSArray *)arrTemplateObj;
- (void)parseAndLoadScriptFile:(NSString *)szcriptFileName
				  OnlyTestOnce:(BOOL) bTestOnce;
/* Kyle 2011.12.19
 * method   : Get_Script_Version:
 * abstract : get version of scriptFile. */
- (NSString *)Get_Script_Version;
- (void)changeSNManage;
- (void)changeScriptFile:(NSString *)szNewScriptFile
		 InformativeText:(NSString *)szInformativeText
				TestOnce:(BOOL)bTestOnce;
//added by lucy
/* Kyle 2012.02.15
 * abstract   : get kingds of SN by script , and memory. */
- (void)showScanSN:(NSNotification *)notification;

// add for AE Stations which receive command circularly
- (void)getUnitColorNoti:(NSNotification *)noti;


//For Live & JSON file
@property (assign)BOOL                          isLiveChanging;
@property (retain)NSMutableString               *UIVersion;
@property (retain)NSMutableString               *strSMFixtureInfo;
// box view object
@property (assign) IBOutlet NSView              *indicator;

// main view object
@property (assign) IBOutlet NSView              *listView;

// SN Labels object
@property (assign) IBOutlet NSView              *inputView;


// sn text field object
@property (assign) IBOutlet NSButton            *btnStart;
@property (assign) IBOutlet NSTextField			* serialNumber1;

// Bool value indicate test state 
@property (assign)BOOL                          isRunning;

// auto test system (need this port to change sn)
@property (retain) TestProgress                 *testProgress;
@property (assign)NSMutableDictionary         *m_dicPorts;
@property (assign) IBOutlet NSTextField        *lbPercentageNumber;

@property (retain, readwrite, nonatomic) id <TemplateDelegate> templateDelegate;

//For SMT-QT 2UP
@property (assign)BOOL                          isFinished;

-(void)monitorAEFixtureStartWithUartPath:(NSString*)strPath
								andRegex:(NSString*)strRegex;

-(void)startStationChoice:(NSNotification*)note;
- (IBAction)clickedStationChoiceConfirm:(NSButton*)sender;
- (IBAction)ChangeSelectedBriefView:(id)sender;
@end




