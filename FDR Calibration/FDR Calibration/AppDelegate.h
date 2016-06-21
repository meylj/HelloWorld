//
//  AppDelegate.h
//  FDR Calibration
//
//  Created by Torres on 13-11-5.
//  Copyright (c) 2013年 Torres. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "USKeyCode.h"
@interface AppDelegate : NSObject <NSApplicationDelegate,NSTextFieldDelegate,NSWindowDelegate>
{
    NSWindow *Window;
//    IBOutlet NSTextField *outputPython;
    IBOutlet NSTextView *outputPython;
    IBOutlet NSTextField *textResult;
    IBOutlet NSView *viewResult;
    NSMutableString *muOutput;
    NSString *currentLog;
    IBOutlet NSWindow *scrWindow;
    IBOutlet NSTextField *textShowScript;
    
    IBOutlet NSButton *checkBox;
    IBOutlet NSTextField *bb_sn;
    
    int runType;
    NSMutableString *muReadNote;
    NSNotificationCenter *nc;
    NSFileHandle *writeHandle;
    
    IBOutlet NSMenuItem *deleteScript;
    IBOutlet NSMenuItem *submitScript;
    
    
    //run terminal active
    ProcessSerialNumber pSN;
    BOOL finishLaunchTerminal;
    BOOL termialRunning;
    
    NSString *stringWriteToTerminal;
    NSWorkspace *work;


}
@property (assign) IBOutlet NSWindow *Window;

- (IBAction)buttonStart:(id)sender;

//- (IBAction)choosetype:(id)sender;
- (IBAction)submitBTN:(id)sender;
- (IBAction)deleteBTN:(id)sender;

- (IBAction)checkBox:(id)sender;


- (void)_readbackgroundNoti:(NSNotification*)note;

@end
