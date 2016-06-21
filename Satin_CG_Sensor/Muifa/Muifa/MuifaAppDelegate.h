//
//  MuifaAppDelegate.h
//  Muifa
//
//  Created by Gordon Liu on 9/22/11.
//  Copyright 2011 PEGATRON. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Muifa_Define.h"
#import "Template.h"
#import <WebKit/WebKit.h>
#import "CustomTimer.h"
#import <AppleTestStationAutomation/AppleTestStationAutomation.h>
#import <AppleTestStationAutomation/AppleControlledStation.h>
#import <AppleTestStationAutomation/AppleControlledStationDelegate.h>
#import <AppleTestStationAutomation/TestStationKeys.h>
#import "eTravelerQT/eTravelerQT.h"
#include <CommonCrypto/CommonDigest.h>



@interface MuifaAppDelegate : NSObject
<NSApplicationDelegate, NSSplitViewDelegate,
NSWindowDelegate, TemplateDelegate,
AppleControlledStationDelegate,
HWTEControlledStation>
{
    NSWindow                    *window;
    NSSplitView                 *splitView;
    NSView                      *viewLeft;
    NSView                      *viewRight;
    NSTabView                   *tbForUnit;
	IBOutlet		NSTextField *TestTotalTime;

    NSMutableDictionary         *m_dicTabViewObject;
    int                         m_iUnitNumber;
    NSString                    *m_szIdentifier;
    int                         m_iBoxHeight;
    
    TestProgress				*testProgress;
    NSArray						*m_arrayDevices;
	NSArray						*m_arrScriptFile;
	NSMutableArray				*m_UartInfoArray;
	NSMutableArray				*m_ItemArray;
	NSString					*m_szStartTime;
	NSString					*m_szStartDate;
	NSMutableString				*m_strUIVersion;
	NSColor						*m_backGroundColor;
	BOOL						m_bTestPass;
	NSOperationQueue			*m_queue;
	
	NSString					*m_szFirstFail;
    NSDictionary				*m_dicGHInfo_Muifa;
    NSMutableArray				*m_arrTemplateObject;
    
    //add for loading IP library Leehua 120507
    DoLoadingLF					*loadingPuddingDylib;
    CB_LoadLibrary				*objCB_LoadLibrary;
    //security window
    IBOutlet NSWindow           *scrWindow;
    IBOutlet NSTextField        *txtPasswordCheck;
    IBOutlet NSButton           *btnEnter;
    IBOutlet NSButton           *btnCancel;
    // accord the sender title in menu item
	
	// SFIS Query Page
	IBOutlet WebView			*webViewSFIS;
    NSString                    *szSenderTitle;
	IBOutlet NSTextField        *m_txtQueryURL;
    IBOutlet NSTextField        *m_txtQuerySN;
    IBOutlet NSMatrix           *m_mtxPType;
    IBOutlet NSButton           *m_btnQuery;
	
    //for choos control run
    IBOutlet NSButton           *btnControlRun;
    // auto test system, for ATA protocol
    NSMutableArray              *m_arrAppleControllers;
    NSMutableArray              *m_arrResult;
    NSMutableArray              *m_arrFixtureStatus;
    NSMutableArray              *m_arrTravelers;
    NSMutableArray              *m_arrUUTID;
    NSMutableArray              *m_arrFailItems;
    int                         m_iSlot_NO;
    
    NSString    *m_Tx_Incomplete_Result;
    NSString    *m_Tx_Initial_Result;
    NSString    *m_Tx_FailItem_Result;
    NSString    *m_Tx_Fixture_Normal;
  
    //For Pressure Test, Add by leehua 2013.10.18 begin
    publicParams        *m_objPublicParam;
    NSNumber            *m_nFixtureController; //need clear every time
    NSMutableDictionary *m_dicPublicMemory; //need remove all objects every time
    NSNumber            *m_iPortCount; //no need to clear every time
    NSNumber            *m_iDynamicPortCount;//need to set as 0 every sampling
    
    //For SMT-QT 2UP
    NSMutableString *m_strSMFixtureName;
    PEGA_ATS_UART   *m_objSMUart;
    SearchSerialPorts   *m_objSerialPorts;
    int             m_iTestItemSYNCCount;

    //For Live & JSON file
    NSDictionary				*m_dicLiveInfo;
    FSEventStreamRef            m_streamFolder;
    NSMutableString             *m_strLiveVersion;
    NSMutableString             *m_strDefaultLivePath;
    
    //For APP-NAP
    id m_activity;

}


typedef struct DisplayColor
{
	NSString		*colorDisplay;
	unsigned char	red;
	unsigned char	green;
	unsigned char	blue;
	bool			flag;
}displayColor;

// Add for new QTx communication protocol, use ATA framework.

extern  NSString    const   *FixtureState;
extern  NSString    const   *SN;


@property (assign) IBOutlet NSWindow	*window;

- (void)linkToTabViewItem:(NSButton *)sender;

- (void)startLoadviewsAndGetGroudHogInfo;

- (void)getTestOnceScriptFileNameWithMenuItemTitle:(NSString*)szTitle;

- (void)runPasswordCheck;

#pragma mark - Actions
- (IBAction)checkPassword:(id)btn;

- (IBAction)cancelPasswordCheck:(NSButton *)btn;

- (IBAction)MENU_Normal:(id)sender;

- (IBAction)MENU_Audit:(id)sender;

- (IBAction)MENU_TOOL3:(id)sender;

- (IBAction)QuerySFIS:(id)sender;
#pragma mark - Others

- (BOOL) station:(AppleControlledStation *)station startWithTravelers:(NSArray *)travelers;
- (BOOL) station:(AppleControlledStation *)station abortWithOptions:(NSDictionary *)options;
- (BOOL) station:(AppleControlledStation *)station query:(NSDictionary *)query;

#pragma mark - JSON file -
- (BOOL) CheckSumForJSON:(NSDictionary *)dicJSON;
- (BOOL) CheckSignatureForJSONOnPath:(NSString *)szJSONPath;
void fsEventsCallback(ConstFSEventStreamRef streamRef, void *clientCallBackInfo, size_t numEvents,
                      void *eventPaths, const FSEventStreamEventFlags eventFlags[],
                      const FSEventStreamEventId eventIds[]);
@end




