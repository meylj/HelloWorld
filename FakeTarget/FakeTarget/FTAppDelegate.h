//
//  FTAppDelegate.h
//  FakeTarget
//
//  Created by raniys on 4/1/14.
//  Copyright (c) 2014 raniys. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

#import "FakeTagetDefine.h"
#import "YYControlPort.h"
#import "CustomTimer.h"
#import "FTDataSource.h"

@class FTDataSource;
@class CustomTimer;

@interface FTAppDelegate : NSObject <NSApplicationDelegate,NSSplitViewDelegate, NSWindowDelegate, NSOutlineViewDataSource, NSOutlineViewDelegate>
{
    NSWindow                    *window;
    IBOutlet NSTextField        *m_textLogPath;
    IBOutlet NSTextView         *m_textDisplay;
    IBOutlet NSButton           *m_btnShowResult;
    IBOutlet NSTextField        *m_textTimer;
    IBOutlet NSPopUpButton      *m_popTarget;
    IBOutlet NSButton           *m_btnCheckBox;
    IBOutlet NSOutlineView      *m_outLineViewCommand;
    IBOutlet NSTextField        *m_textManualCommand;
    
    NSMutableString             *m_szLogPath;
    NSMutableString             *m_szReturnValue;
    NSMutableDictionary         *m_dictMemoryValues;
    NSMutableArray              *m_arrCommandForView;
    NSMutableArray              *m_arrLogTargets;
    NSTreeNode                  *_rootTreeNode;
    
    CustomTimer                 *aTimer;
    FTDataSource                *m_objDataSource;
    
    BOOL                        m_bTimerFired;
    BOOL                        m_bCheckBox;
    BOOL                        m_bItemOpened;
    
    NSUInteger                  m_iTrack;
}
@property (assign) IBOutlet NSWindow *window;

- (IBAction)findLogPath:(id)sender;
- (IBAction)showCommandAndTheResult:(id)sender;
- (IBAction)startingToReceiveNotification:(id)sender;
- (IBAction)checkBox:(id)sender;
- (IBAction)changeTarget:(id)sender;
- (IBAction)showAllCommand:(id)sender;
- (IBAction)manualSendComamnd:(NSButton *)sender;
- (IBAction)saveDataToCsvFile:(NSButton *)sender;



- (NSNumber *)loadingScriptFile;
- (NSNumber *)StartingMonitor;
- (NSNumber *)runSingleTarget:(NSString *)strTarget;
- (NSTreeNode *)treeNodeFromArray:(NSArray *)array;

@end
