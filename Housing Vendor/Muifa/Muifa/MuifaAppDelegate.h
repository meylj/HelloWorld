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

@interface MuifaAppDelegate : NSObject <NSApplicationDelegate, NSSplitViewDelegate, NSWindowDelegate> {
    NSWindow                    *window;
    NSSplitView                 *splitView;
    NSView                      *viewLeft;
    NSView                      *viewRight;
    NSTabView                   *tbForUnit;
    NSRect                      rectViewLeft;
    NSRect                      rectViewRight;

    IBOutlet NSSegmentedControl *segController;
    NSMutableDictionary         *m_dicUnitObject;
    int                         m_iUnitNumber;
    NSString                    *m_szMode;
    NSString                    *m_szIdentifier;
    int                         m_iBoxHeight;
    
    TestProgress			*	testProgress;
    NSArray					*	m_arrayDevices;
	NSArray					*	m_arrScriptFile;
	NSMutableArray			*	m_UartInfoArray;
	NSMutableArray			*	m_ItemArray;
	NSString				*	m_szStartTime;
	NSString				*	m_strUIVersion;
	NSColor					*	m_backGroundColor;
	BOOL						m_bTestPass;
	NSOperationQueue		*	m_queue;
	
	NSString				*	m_szFirstFail;
    NSDictionary            *   m_dicGHInfo_Muifa;
    NSMutableArray          *   m_arrTemplateObject;
    
    // for CT2 Ants Test
    NSMutableDictionary     *   m_dicAntsFlags;
    
    //add for loading IP library Leehua 120507
    DoLoadingLF *doLoadingLF;
    
    
    //security window
    IBOutlet NSWindow           *scrWindow;
    IBOutlet NSTextField        *txtPasswordCheck;
    IBOutlet NSButton           *btnEnter;
    IBOutlet NSButton           *btnCancel;
    // accord the sender title in menu item
    NSString                    *szSenderTitle;
	NSTimer				 *		timerCheckFocus;
	NSTimer				 *		timerDetectAllFinished;
    
    //add for 4-up grape-1 
    NSMutableArray              *m_arrSerialPortApp;
    NSString                    *m_strDefaultCable;
    BOOL                        m_bFixtureControl;
    //NSString                    *m_strSerialPortApp;
    BOOL                        m_bFxitureFile;
    NSString                    *m_strPlistCable;
    
    // for prox cal
    BOOL                        m_bDetectUUT1;
   // NSString                    *m_szUnitECIDForProxCal;
    NSMutableArray              *m_arrUnitECIDForProxCal;
    NSLock                      *m_lockProxCal;
}


typedef struct color_pattern{
	NSString     *strColor;
	unsigned char ucRed;
	unsigned char ucGreen;
	unsigned char ucBlue;
	bool          bFlag;
}struct_Color;

@property (assign) IBOutlet NSWindow *window;

- (void)addViewsForMainMenuXib:(NSDictionary *)dicUnit WithUnitColor:(struct_Color )struct_ColorForUnit;

- (void)linkToTabViewItem:(NSButton *)sender;

- (void)startLoadviewsAndGetGroudHogInfo;

- (void)getTestOnceScriptFileNameWithMenuItemTitle:(NSString*)szTitle;

- (IBAction)MENU_TOOL1:(id)sender;
- (IBAction)MENU_TOOL2:(id)sender;
- (IBAction)MENU_TOOL3:(id)sender;

- (void)allStartButtonPressed:(NSNotification *)aNote;
- (void)youngBrotherStartButtonUnpressed:(NSNotification *)aNote;

- (void)runPasswordCheck;

- (IBAction)checkPassword:(id)btn;

- (IBAction)cancelPasswordCheck:(NSButton *)btn;

// for CT2 Ants Test
- (void)monitorAllTemplate:(NSNotification *)aNote;
//for grape-1 4-up
- (void)runPasswordCheckBrother:(NSNotification *)note;

// for prox cal
- (void)detectProxCalUUT1;
- (void)monitorProxCalUUT1: (NSNotification*)aNote;
- (int)proxCalIdleSlot;

@end
