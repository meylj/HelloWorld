//
//  AppDelegate.h
//  SetSettingFile
//
//  Created by Linda8_Yang on 9/9/16.
//  Copyright © 2016 Linda8_Yang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate,NSWindowDelegate>
{
    NSMutableDictionary    *dicNewSetting;
   // NSMutableDictionary    *dicOriginalSetting;
    
    IBOutlet NSButton *btn_disableLiveFunction;
    IBOutlet NSButton *btn_NoLiveControl;
    IBOutlet NSButton *btn_disableSignature;
    
    IBOutlet NSButton *btn_offlineDisablePudding;
    IBOutlet NSButton *btn_validationDisablePudding;
    IBOutlet NSButton *btn_disablePudding;
    
    IBOutlet NSButton *btn_forceEnableDebugLog;
    
    IBOutlet NSButton *btn_disableDebugLog;
    IBOutlet NSButton *btn_runningWithUartTab;
    IBOutlet NSButton *btn_deleteLogsBeforeDays;
    
    //IBOutlet NSTextField *m_txtScirptFileName;
    IBOutlet NSComboBox *m_boxScriptFileName;
    IBOutlet NSPopUpButton *m_btnQuickSetting;
    IBOutlet NSTextField    *m_txtNewControlKey;
    
    //security window
    IBOutlet NSWindow   *scrWindow;
    IBOutlet NSTextField    *txtUserID;
    IBOutlet NSTextField    *txtPassword;
    IBOutlet NSButton   *btnGoToApp;
    IBOutlet NSButton   *btnCancel;

    
}
- (void)CheckSettingFileExistOrNot;
- (void)PasswordCheckWindow;
- (IBAction)GoToApp:(id)sender;
- (IBAction)CancelAction:(id)sender;

- (IBAction)OpenSettingFile:(id)sender;
- (IBAction)ExitApp:(id)sender;
- (IBAction)QuickSetting:(id)sender;

@end

