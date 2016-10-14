//
//  AppDelegate.m
//  SetSettingFile
//
//  Created by Linda8_Yang on 9/9/16.
//  Copyright © 2016 Linda8_Yang. All rights reserved.
//

#import "AppDelegate.h"

#define kUserDefaultPath [NSString stringWithFormat:@"%@/Library/Preferences", NSHomeDirectory()]
#define kMuifaPlistPath  [NSString stringWithFormat:@"%@/Library/Preferences/ATS_Muifa.plist", NSHomeDirectory()]

@interface AppDelegate ()

@property (assign) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

-(id)init
{
    self = [super init];
    if (self)
    {
        dicNewSetting = [[NSMutableDictionary alloc]init];
    }
    return self;
}

-(void)dealloc
{
    [dicNewSetting release];
    [scrWindow release];
    [super dealloc];
}

-(void)awakeFromNib
{
    NSLog(@"awakeFromNib begin");
    
//    NSAlert *alert = [[NSAlert alloc]init];
//    alert.messageText = @"Warning!";
//    alert.informativeText = @"You need to input the UserID and Password firstly to open this app!";
//    [alert addButtonWithTitle:@"OK"];
//    [alert addButtonWithTitle:@"Cancel"];
//    [alert setAlertStyle:NSWarningAlertStyle];
//    NSInteger   returnCode = [alert runModal];
//    if (returnCode == NSAlertFirstButtonReturn)
//    {
//        [self PasswordCheckWindow];
//    }
//    else if (returnCode == NSAlertSecondButtonReturn)
//    {
//        exit(0);
//    }
//
//    [alert release];
    
    [self PasswordCheckWindow];
    //[self CheckSettingFileExistOrNot];
}

- (void)PasswordCheckWindow
{
    [scrWindow setBackgroundColor:nil];
    [NSApp runModalForWindow:scrWindow];
}

- (IBAction)GoToApp:(id)sender
{
    NSString    *strUserID = @"ATS";
    NSString    *strPassword = @"ATS@123";
    NSString    *strUserIDEnter = [NSString stringWithFormat:@"%@",[txtUserID stringValue]];
    NSString	*strPasswordEnter = [NSString stringWithFormat:@"%@",[txtPassword stringValue]];
    
    if([strUserIDEnter isEqualToString:strUserID] && [strPasswordEnter isEqualToString:strPassword])
    {
        [txtUserID setStringValue:@""];
        [txtPassword setStringValue:@""];
        [scrWindow orderOut:nil];
        [NSApp endSheet:scrWindow];
        [self CheckSettingFileExistOrNot];
        [NSApp runModalForWindow:_window];
        [scrWindow release];
    }
    else
    {
        [txtUserID setStringValue:@""];
        [txtPassword setStringValue:@""];
        [scrWindow setBackgroundColor:[NSColor redColor]];
        NSAlert *alert = [[NSAlert alloc]init];
        alert.messageText = @"ERROR";
        alert.informativeText =@"Please input the right UserID or Password!";
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
        [alert release];
    }
    
}

- (IBAction)CancelAction:(id)sender
{
    [scrWindow orderOut:nil];
    [NSApp endSheet:scrWindow];
    exit(0);
}

- (void)CheckSettingFileExistOrNot
{
    NSFileManager	*fileManger		= [NSFileManager defaultManager];
    NSError			*error;
    
    NSDictionary	*dicAttributes	=[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:511]
                                                             forKey:NSFilePosixPermissions];
    if ([fileManger setAttributes:dicAttributes
                     ofItemAtPath:kUserDefaultPath
                            error:&error])
    {
        // create ATS_Muifa.plist at path: ~/Library/Preferences/ if not exists.
        if (![fileManger fileExistsAtPath:kMuifaPlistPath])
        {
            //load the ATS_Muifa.plist file at path:mainbundle/Content/Resources/
            NSDictionary    *dicSetting = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/Contents/Resources/ATS_Muifa.plist",[[NSBundle mainBundle] bundlePath]]];
            
            //get the contents of ATS_Muifa.plist file at path:mainbundle/Content
            NSDictionary    *dicCancelToEndSetting = [dicSetting objectForKey:@"CancelToEndSetting"];
            NSDictionary    *dicDeviceSetting = [dicSetting objectForKey:@"DeviceSetting"];
            NSDictionary    *dicLog_Path = [dicSetting objectForKey:@"Log_Path"];
            NSDictionary    *dicModeSetting = [dicSetting objectForKey:@"ModeSetting"];
            NSDictionary    *dicScriptInfo = [dicSetting objectForKey:@"ScriptInfo"];
            NSDictionary    *dicSN_Manager = [dicSetting objectForKey:@"SN_Manager"];
            NSArray *arrQueryPType = [dicSetting objectForKey:@"QueryPType"];
            
            //add this content to a new dictionary
            [dicNewSetting setObject:dicCancelToEndSetting forKey:@"CancelToEndSetting"];
            [dicNewSetting setObject:dicDeviceSetting forKey:@"DeviceSetting"];
            [dicNewSetting setObject:dicLog_Path forKey:@"Log_Path"];
            [dicNewSetting setObject:dicModeSetting forKey:@"ModeSetting"];
            [dicNewSetting setObject:dicScriptInfo forKey:@"ScriptInfo"];
            [dicNewSetting setObject:dicSN_Manager forKey:@"SN_Manager"];
            [dicNewSetting setObject:arrQueryPType forKey:@"QueryPType"];
            
            //creat ATS_Muifa.plist file at path ~/Library/Preferences/ATS_Muifa.plist with content of this new dictionary
            [dicNewSetting writeToFile:kMuifaPlistPath atomically:YES];
            
        }
    }
    else
    {
        NSAlert *alert = [[NSAlert alloc]init];
        alert.messageText = @"警告(Warning)";
        alert.informativeText = [NSString stringWithFormat:
                                 @"没有路径:%@下的写入权限。(No permission to write ATS_Muifa_Counter.plist at path:%@)",
                                 kUserDefaultPath,kUserDefaultPath];
        [alert addButtonWithTitle:@"确认(OK)"];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
        [alert release];
        [NSApp terminate:self];
    }

}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (IBAction)QuickSetting:(id)sender
{
    NSFileManager   *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:kMuifaPlistPath])
    {
        
        NSMutableDictionary *dicOriginalSetting = [NSMutableDictionary dictionaryWithContentsOfFile:kMuifaPlistPath];
        
        //For Validation
        //For MP Stage
        
        if ([[m_btnQuickSetting stringValue] length] != 0 && ![[m_btnQuickSetting titleOfSelectedItem] isEqualToString:@""])
        {
            if ([[m_btnQuickSetting titleOfSelectedItem] isEqualToString:@"For local plist"])
            {
                
                [btn_deleteLogsBeforeDays setState:0];
                [btn_disableDebugLog setState:0];
                [btn_runningWithUartTab setState:0];
                [btn_offlineDisablePudding setState:0];
                [btn_forceEnableDebugLog setState:0];
                [btn_validationDisablePudding setState:0];
                [btn_disableLiveFunction setState:1];
                [btn_NoLiveControl setState:0];
                [btn_disableSignature setState:0];
                [btn_disablePudding setState:0];
                
                if ([[dicOriginalSetting allKeys] containsObject:@"DisableLiveFunction"] && [[dicOriginalSetting objectForKey:@"DisableLiveFunction"] boolValue] == NO)
                {
                    [dicOriginalSetting setValue:[NSNumber numberWithBool:YES] forKey:@"DisableLiveFunction"];
                }
                else if(![[dicOriginalSetting allKeys] containsObject:@"DisableLiveFunction"])
                {
                    [dicOriginalSetting setObject:[NSNumber numberWithBool:YES] forKey:@"DisableLiveFunction"];
                }
            }

            if ([[m_btnQuickSetting titleOfSelectedItem] isEqualToString:@"For local Live"])
            {
            
                [btn_deleteLogsBeforeDays setState:0];
                [btn_disableDebugLog setState:0];
                [btn_runningWithUartTab setState:0];
                [btn_offlineDisablePudding setState:0];
                [btn_forceEnableDebugLog setState:0];
                [btn_validationDisablePudding setState:0];
                [btn_disableLiveFunction setState:0];
                [btn_NoLiveControl setState:1];
                [btn_disableSignature setState:1];
                [btn_disablePudding setState:0];
                
                if ([[dicOriginalSetting allKeys] containsObject:@"DisableSignature"] && [[dicOriginalSetting objectForKey:@"DisableSignature"] boolValue] == NO)
                {
                    [dicOriginalSetting setValue:[NSNumber numberWithBool:YES] forKey:@"DisableSignature"];
                }
                else if(![[dicOriginalSetting allKeys] containsObject:@"DisableSignature"])
                {
                    [dicOriginalSetting setObject:[NSNumber numberWithBool:YES] forKey:@"DisableSignature"];
                }
    
                if ([[dicOriginalSetting allKeys] containsObject:@"NoLiveControl"] && [[dicOriginalSetting objectForKey:@"NoLiveControl"] boolValue] == NO)
                {
                    [dicOriginalSetting setValue:[NSNumber numberWithBool:YES] forKey:@"NoLiveControl"];
                }
                else if(![[dicOriginalSetting allKeys] containsObject:@"NoLiveControl"])
                {
                    [dicOriginalSetting setObject:[NSNumber numberWithBool:YES] forKey:@"NoLiveControl"];
                }
            }
            
            if ([[m_btnQuickSetting titleOfSelectedItem] isEqualToString:@"For offline validation"])
            {
                
                [btn_deleteLogsBeforeDays setState:0];
                [btn_disableDebugLog setState:0];
                [btn_runningWithUartTab setState:0];
                [btn_offlineDisablePudding setState:0];
                [btn_forceEnableDebugLog setState:1];
                [btn_validationDisablePudding setState:1];
                [btn_disableLiveFunction setState:0];
                [btn_NoLiveControl setState:1];
                [btn_disableSignature setState:1];
                [btn_disablePudding setState:0];
                
                if ([[dicOriginalSetting allKeys] containsObject:@"DisableSignature"] && [[dicOriginalSetting objectForKey:@"DisableSignature"] boolValue] == NO)
                {
                    [dicOriginalSetting setValue:[NSNumber numberWithBool:YES] forKey:@"DisableSignature"];
                }
                else if(![[dicOriginalSetting allKeys] containsObject:@"DisableSignature"])
                {
                    [dicOriginalSetting setObject:[NSNumber numberWithBool:YES] forKey:@"DisableSignature"];
                }
                
                if ([[dicOriginalSetting allKeys] containsObject:@"NoLiveControl"] && [[dicOriginalSetting objectForKey:@"NoLiveControl"] boolValue] == NO)
                {
                    [dicOriginalSetting setValue:[NSNumber numberWithBool:YES] forKey:@"NoLiveControl"];
                }
                else if(![[dicOriginalSetting allKeys] containsObject:@"NoLiveControl"])
                {
                    [dicOriginalSetting setObject:[NSNumber numberWithBool:YES] forKey:@"NoLiveControl"];
                }
                if ([[dicOriginalSetting allKeys] containsObject:@"ValidationDisablePudding"] && [[dicOriginalSetting objectForKey:@"ValidationDisablePudding"] boolValue] == NO)
                {
                    [dicOriginalSetting setValue:[NSNumber numberWithBool:YES] forKey:@"ValidationDisablePudding"];
                }
                else if(![[dicOriginalSetting allKeys] containsObject:@"ValidationDisablePudding"])
                {
                    [dicOriginalSetting setObject:[NSNumber numberWithBool:YES] forKey:@"ValidationDisablePudding"];
                }
                if ([[dicOriginalSetting allKeys] containsObject:@"ForceEnableDebugLog"] && [[dicOriginalSetting objectForKey:@"ForceEnableDebugLog"] boolValue] == NO)
                {
                    [dicOriginalSetting setValue:[NSNumber numberWithBool:YES] forKey:@"ForceEnableDebugLog"];
                }
                else if(![[dicOriginalSetting allKeys] containsObject:@"ForceEnableDebugLog"])
                {
                    [dicOriginalSetting setObject:[NSNumber numberWithBool:YES] forKey:@"ForceEnableDebugLog"];
                }
            }
            
            if ([[m_btnQuickSetting titleOfSelectedItem] isEqualToString:@"For offline station"])
            {
                [btn_deleteLogsBeforeDays setState:0];
                [btn_disableDebugLog setState:0];
                [btn_runningWithUartTab setState:0];
                [btn_offlineDisablePudding setState:1];
                [btn_forceEnableDebugLog setState:0];
                [btn_validationDisablePudding setState:0];
                [btn_disableLiveFunction setState:0];
                [btn_NoLiveControl setState:1];
                [btn_disableSignature setState:1];
                [btn_disablePudding setState:0];
                
                if ([[dicOriginalSetting allKeys] containsObject:@"DisableSignature"] && [[dicOriginalSetting objectForKey:@"DisableSignature"] boolValue] == NO)
                {
                    [dicOriginalSetting setValue:[NSNumber numberWithBool:YES] forKey:@"DisableSignature"];
                }
                else if(![[dicOriginalSetting allKeys] containsObject:@"DisableSignature"])
                {
                    [dicOriginalSetting setObject:[NSNumber numberWithBool:YES] forKey:@"DisableSignature"];
                }
                
                if ([[dicOriginalSetting allKeys] containsObject:@"NoLiveControl"] && [[dicOriginalSetting objectForKey:@"NoLiveControl"] boolValue] == NO)
                {
                    [dicOriginalSetting setValue:[NSNumber numberWithBool:YES] forKey:@"NoLiveControl"];
                }
                else if(![[dicOriginalSetting allKeys] containsObject:@"NoLiveControl"])
                {
                    [dicOriginalSetting setObject:[NSNumber numberWithBool:YES] forKey:@"NoLiveControl"];
                }
                if ([[dicOriginalSetting allKeys] containsObject:@"OfflineDisablePudding"] && [[dicOriginalSetting objectForKey:@"OfflineDisablePudding"] boolValue] == NO)
                {
                    [dicOriginalSetting setValue:[NSNumber numberWithBool:YES] forKey:@"OfflineDisablePudding"];
                }
                else if(![[dicOriginalSetting allKeys] containsObject:@"OfflineDisablePudding"])
                {
                    [dicOriginalSetting setObject:[NSNumber numberWithBool:YES] forKey:@"OfflineDisablePudding"];
                }
            }
            
            if ([[m_btnQuickSetting titleOfSelectedItem] isEqualToString:@"For MP Stage"])
            {
                
                [btn_deleteLogsBeforeDays setState:1];
                [btn_disableDebugLog setState:1];
                [btn_runningWithUartTab setState:1];
                [btn_offlineDisablePudding setState:0];
                [btn_forceEnableDebugLog setState:0];
                [btn_validationDisablePudding setState:0];
                [btn_disableLiveFunction setState:0];
                [btn_NoLiveControl setState:0];
                [btn_disableSignature setState:0];
                [btn_disablePudding setState:0];
                
                if ([[dicOriginalSetting allKeys] containsObject:@"RunningWithUARTTab"] && [[dicOriginalSetting objectForKey:@"RunningWithUARTTab"] boolValue] == NO)
                {
                    [dicOriginalSetting setValue:[NSNumber numberWithBool:YES] forKey:@"RunningWithUARTTab"];
                }
                else if(![[dicOriginalSetting allKeys] containsObject:@"RunningWithUARTTab"])
                {
                    [dicOriginalSetting setObject:[NSNumber numberWithBool:YES] forKey:@"RunningWithUARTTab"];
                }
                if ([[dicOriginalSetting allKeys] containsObject:@"DisableDebugLog"] && [[dicOriginalSetting objectForKey:@"DisableDebugLog"] boolValue] == NO)
                {
                    [dicOriginalSetting setValue:[NSNumber numberWithBool:YES] forKey:@"DisableDebugLog"];
                }
                else if(![[dicOriginalSetting allKeys] containsObject:@"DisableDebugLog"])
                {
                    [dicOriginalSetting setObject:[NSNumber numberWithBool:YES] forKey:@"DisableDebugLog"];
                }
                if ([[dicOriginalSetting allKeys] containsObject:@"DeleteProcessLogBeforeDays"] && [[dicOriginalSetting objectForKey:@"DeleteProcessLogBeforeDays"] boolValue] == NO)
                {
                    [dicOriginalSetting setValue:[NSString stringWithFormat:@"%@",[NSNumber numberWithInt:2]] forKey:@"DeleteProcessLogBeforeDays"];
                }
                else if(![[dicOriginalSetting allKeys] containsObject:@"DeleteProcessLogBeforeDays"])
                {
                    [dicOriginalSetting setObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithInt:2]] forKey:@"DeleteProcessLogBeforeDays"];
                }
            }
            if ([[m_btnQuickSetting titleOfSelectedItem] isEqualToString:@"Add QueryPType"])
            {
                if(![[dicOriginalSetting allKeys] containsObject:@"QueryPType"])
                {
                    NSMutableArray *arrQueryPType = [[NSMutableArray alloc]init];
                    [arrQueryPType insertObject:@"config" atIndex:0];
                    [arrQueryPType insertObject:@"hwconfig" atIndex:0];
                    [arrQueryPType insertObject:@"nand_size" atIndex:0];
                    [arrQueryPType insertObject:@"mlbsn" atIndex:0];
                    [arrQueryPType insertObject:@"MPN" atIndex:0];
                    [arrQueryPType insertObject:@"REGION_CODE" atIndex:0];
                    [arrQueryPType insertObject:@"front_nvm_barcode" atIndex:0];
                    [arrQueryPType insertObject:@"back_nvm_barcode" atIndex:0];
                    [arrQueryPType insertObject:@"lcm_sn" atIndex:0];
                    [arrQueryPType insertObject:@"lcg_sn" atIndex:0];
                    
                    [dicOriginalSetting setObject:arrQueryPType forKey:@"QueryPType"];
                    [arrQueryPType release];
                }
            }
            if ([[m_btnQuickSetting titleOfSelectedItem] isEqualToString:@"Remove QueryPType"])
            {
                if([[dicOriginalSetting allKeys] containsObject:@"QueryPType"])
                {
                    [dicOriginalSetting removeObjectForKey:@"QueryPType"];
                }
            }
            
            [dicOriginalSetting writeToFile:kMuifaPlistPath atomically:YES];
        }
        else
        {
            [btn_deleteLogsBeforeDays setState:0];
            [btn_disableDebugLog setState:0];
            [btn_runningWithUartTab setState:0];
            [btn_offlineDisablePudding setState:0];
            [btn_forceEnableDebugLog setState:0];
            [btn_validationDisablePudding setState:0];
            [btn_disableLiveFunction setState:0];
            [btn_NoLiveControl setState:0];
            [btn_disableSignature setState:0];
            [btn_disablePudding setState:0];
        }
    }
    
}

-(IBAction)SetBoolFunction:(id)sender
{
    NSFileManager	*fileManger		= [NSFileManager defaultManager];
    if ([fileManger fileExistsAtPath:kMuifaPlistPath])
    {
        NSMutableDictionary *dicOriginalSetting = [NSMutableDictionary dictionaryWithContentsOfFile:kMuifaPlistPath];
        
        if ([btn_disableLiveFunction state]==1)
        {
            [dicOriginalSetting setObject:[NSNumber numberWithBool:YES] forKey:@"DisableLiveFunction"];
        }
        else
        {
            if ([dicOriginalSetting objectForKey:@"DisableLiveFunction"])
            {
                [dicOriginalSetting removeObjectForKey:@"DisableLiveFunction"];
            }
        }
        
        if ([btn_NoLiveControl state]==1)
        {
            [dicOriginalSetting setObject:[NSNumber numberWithBool:YES]
                                   forKey:@"NoLiveControl"];
        }
        else
        {
            if ([dicOriginalSetting objectForKey:@"NoLiveControl"])
            {
                [dicOriginalSetting removeObjectForKey:@"NoLiveControl"];
            }
        }

        if ([btn_disableSignature state]==1)
        {
            [dicOriginalSetting setObject:[NSNumber numberWithBool:YES]
                                   forKey:@"DisableSignature"];
        }
        else
        {
            if ([dicOriginalSetting objectForKey:@"DisableSignature"])
            {
                [dicOriginalSetting removeObjectForKey:@"DisableSignature"];
            }
        }

        if ([btn_offlineDisablePudding state]==1)
        {
            [dicOriginalSetting setObject:[NSNumber numberWithBool:YES] forKey:@"OfflineDisablePudding"];
        }
        else
        {
            if ([dicOriginalSetting objectForKey:@"OfflineDisablePudding"])
            {
                [dicOriginalSetting removeObjectForKey:@"OfflineDisablePudding"];
            }
        }

        if ([btn_validationDisablePudding state]==1)
        {
            [dicOriginalSetting setObject:[NSNumber numberWithBool:YES] forKey:@"ValidationDisablePudding"];
        }
        else
        {
            if ([dicOriginalSetting objectForKey:@"ValidationDisablePudding"])
            {
                [dicOriginalSetting removeObjectForKey:@"ValidationDisablePudding"];
            }
        }

        if ([btn_disablePudding state]==1)
        {
            [dicOriginalSetting setObject:[NSNumber numberWithBool:YES]
                                   forKey:@"DisablePudding"];
        }
        else
        {
            if ([dicOriginalSetting objectForKey:@"DisablePudding"])
            {
                [dicOriginalSetting removeObjectForKey:@"DisablePudding"];
            }
        }

        if ([btn_forceEnableDebugLog state]==1)
        {
            [dicOriginalSetting setObject:[NSNumber numberWithBool:YES] forKey:@"ForceEnableDebugLog"];
        }
        else
        {
            if ([dicOriginalSetting objectForKey:@"ForceEnableDebugLog"])
            {
                [dicOriginalSetting removeObjectForKey:@"ForceEnableDebugLog"];
            }
        }

        if ([btn_disableDebugLog state]==1)
        {
            [dicOriginalSetting setObject:[NSNumber numberWithBool:YES]
                                   forKey:@"DisableDebugLog"];
        }
        else
        {
            if ([dicOriginalSetting objectForKey:@"DisableDebugLog"])
            {
                [dicOriginalSetting removeObjectForKey:@"DisableDebugLog"];
            }
        }

        if ([btn_runningWithUartTab state]==1)
        {
            [dicOriginalSetting setObject:[NSNumber numberWithBool:YES]
                                   forKey:@"RunningWithUARTTab"];
        }
        else
        {
            if ([dicOriginalSetting objectForKey:@"RunningWithUARTTab"])
            {
                [dicOriginalSetting removeObjectForKey:@"RunningWithUARTTab"];
            }
        }

        if ([btn_deleteLogsBeforeDays state]==1)
        {
            [dicOriginalSetting setObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithInt:2]] forKey:@"DeleteProcessLogBeforeDays"];
        }
        else
        {
            if ([dicOriginalSetting objectForKey:@"DeleteProcessLogBeforeDays"])
            {
                [dicOriginalSetting removeObjectForKey:@"DeleteProcessLogBeforeDays"];
            }
        }

        
        [dicOriginalSetting writeToFile:kMuifaPlistPath atomically:YES];
    }
}

- (IBAction)OpenSettingFile:(id)sender
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:kMuifaPlistPath])
    {
        NSMutableDictionary *dicOriginalSetting = [NSMutableDictionary dictionaryWithContentsOfFile:kMuifaPlistPath];
        
        if ([[m_txtNewControlKey stringValue] length] != 0)
        {
            [dicOriginalSetting setObject:[NSNumber numberWithBool:YES] forKey:[m_txtNewControlKey stringValue]];
            [dicOriginalSetting writeToFile:kMuifaPlistPath atomically:YES];
        }

        if ([btn_NoLiveControl state] != 1)
        {
            [dicOriginalSetting removeObjectForKey:@"NoLiveControl"];
        }
        if ([btn_disablePudding state] != 1)
        {
            [dicOriginalSetting removeObjectForKey:@"DisablePudding"];
        }
        if ([btn_disableDebugLog state] != 1)
        {
            [dicOriginalSetting removeObjectForKey:@"DisableDebugLog"];
        }
        if ([btn_disableSignature state] != 1)
        {
            [dicOriginalSetting removeObjectForKey:@"DisableSignature"];
        }
        if ([btn_runningWithUartTab state] != 1)
        {
            [dicOriginalSetting removeObjectForKey:@"RunningWithUARTTab"];
        }
        if ([btn_disableLiveFunction state] != 1)
        {
            [dicOriginalSetting removeObjectForKey:@"DisableLiveFunction"];
        }
        if ([btn_forceEnableDebugLog state] != 1)
        {
            [dicOriginalSetting removeObjectForKey:@"ForceEnableDebugLog"];
        }
        if ([btn_deleteLogsBeforeDays state] != 1)
        {
            [dicOriginalSetting removeObjectForKey:@"DeleteProcessLogBeforeDays"];
        }
        if ([btn_offlineDisablePudding state] != 1)
        {
            [dicOriginalSetting removeObjectForKey:@"OfflineDisablePudding"];
        }
        if ([btn_validationDisablePudding state] != 1)
        {
            [dicOriginalSetting removeObjectForKey:@"ValidationDisablePudding"];
        }

        if ([[m_boxScriptFileName stringValue] length] != 0 )
        {
            //for CancelToEndSetting
            NSString *
            dicOldStationID = [[[dicOriginalSetting objectForKey:@"CancelToEndSetting"] allKeys]objectAtIndex:0];
            NSString *obj = [[dicOriginalSetting objectForKey:@"CancelToEndSetting"] objectForKey:dicOldStationID];
            NSMutableDictionary *dicStation = [NSMutableDictionary dictionary];
            [dicStation setObject:obj forKey:[NSString stringWithFormat:@"%@",[m_boxScriptFileName stringValue]]];
            [dicOriginalSetting setObject:dicStation forKey:@"CancelToEndSetting"];
            
            //for ScriptInfo ScriptFileName
            [[dicOriginalSetting objectForKey:@"ScriptInfo"] setValue:[NSString stringWithFormat:@"%@.plist",[m_boxScriptFileName stringValue]] forKey:@"ScriptFileName"];
        }
        [dicOriginalSetting writeToFile:kMuifaPlistPath atomically:YES];
        [[NSWorkspace sharedWorkspace] openFile:kMuifaPlistPath withApplication:@"PegaPropertyEdit"];
    }
}

- (IBAction)ExitApp:(id)sender
{
    exit(0);
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

@end
