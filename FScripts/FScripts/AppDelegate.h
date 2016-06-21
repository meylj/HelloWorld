//
//  AppDelegate.h
//  FScripts
//
//  Created by chenchao on 14/11/6.
//  Copyright (c) 2014年 chenchao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    IBOutlet    NSWindow    *m_window;
    
    //For get original test script ,then create first version GH file.
    IBOutlet    NSPathControl   *m_pcGetFirstScript;
    IBOutlet    NSButton        *m_btnCreateFirstGHScript;

    //According to the new GH file, format original script

    IBOutlet    NSPathControl   *m_pcGetSecondGHScript;
    IBOutlet    NSButton        *m_btnCreateSecondScript;
    
    IBOutlet    NSTextField     *m_txtLiveVerFirst;
//    IBOutlet    NSTextField     *m_txtERSVerSecond;
    
    int         m_iChangeCount;
}
    //For get original test script ,then create first version GH file.
- (IBAction)GetFirstScript:(id)sender;
- (IBAction)CreateFirstGHScript:(id)sender;
- (void)CreateGHScript:(NSArray *)FirstScriptData;

    //According to the new GH file, format original script
- (IBAction)GetSecondGHScript:(id)sender;
- (IBAction)CreateSecondScript:(id)sender;
- (void)CreateScript:(NSArray *)FirstScriptData GetGHScript:(NSDictionary *)GHScriptData;

//- (void)ReturnHandler:(NSModalResponse)ReturnCode;

@end

