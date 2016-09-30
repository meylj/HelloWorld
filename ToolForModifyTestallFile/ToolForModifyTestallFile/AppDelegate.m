//
//  AppDelegate.m
//  ToolForModifyTestallFile
//
//  Created by Linda8_Yang on 9/22/16.
//  Copyright © 2016 Linda8_Yang. All rights reserved.
//


#import "AppDelegate.h"

@interface AppDelegate ()

@property (assign) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

-(id)init
{
    if (self = [super init])
    {
        objNewTestall = [[NewTestallFormat alloc]init];
    }
    return self;
}

-(void)dealloc
{
    [objNewTestall release];
    [_JsonFilePath release];
    [_testallFilePath release];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)loadTestallFile:(id)sender
{
    [_testallFilePath setStringValue:[self openPanelFilePath]];
}

- (IBAction)loadJsonFile:(id)sender
{
    [_JsonFilePath setStringValue:[self openPanelFilePath]];
}

-(NSString *)openPanelFilePath
{
    NSString *strTemp = @"";
    
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setAllowsMultipleSelection:NO];
    if ([openPanel runModal] == NSFileHandlingPanelOKButton)
    {
        [openPanel orderOut:self];
        NSURL *url = [[openPanel URLs] objectAtIndex:0];
        if (url)
        {
            strTemp = [url path];
        }
    }
    
    return strTemp;

}

- (IBAction)toGenerateNewTestallFileWithNewFormat:(id)sender
{
    if ([[_testallFilePath stringValue] length] == 0|| [[_JsonFilePath stringValue] length] ==0)
    {
        NSAlert *alert = [[NSAlert alloc]init];
        alert.messageText = @"Data parameter can't be nil!";
        [alert runModal];
        [alert release];
    }
    BOOL iRet = [objNewTestall creatNewTestallFileWithNewFormat:[_testallFilePath stringValue] withJsonPath:[_JsonFilePath stringValue]];
    if (iRet)
    {
        NSAlert *alert = [[NSAlert alloc]init];
        alert.informativeText = @"Creat new testall file successfully!";
        alert.messageText = @"Warning!";
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
        [alert release];
    }
    else
    {
        NSAlert *alert = [[NSAlert alloc]init];
        alert.informativeText = @"Creat new testall file failed,you can creat again!";
        alert.messageText = @"Warning!";
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
        [alert release];
    }
}

- (IBAction)toCheckTheNewTestallFile:(id)sender
{
    m_strStationName = [[_testallFilePath stringValue]lastPathComponent];
    NSString *strNewPlistFilePath = [NSString stringWithFormat:@"%@/Desktop/%@",NSHomeDirectory(),m_strStationName];
    
    [[NSWorkspace sharedWorkspace] openFile:strNewPlistFilePath withApplication:@"Xcode"];
    
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
