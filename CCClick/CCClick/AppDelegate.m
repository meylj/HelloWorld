//
//  AppDelegate.m
//  CCClick
//
//  Created by chenchao on 15/1/8.
//  Copyright (c) 2015年 chenchao. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)awakeFromNib
{
    m_strAppName = [[NSMutableString alloc]init];
    m_bLoopTest  = YES;
    [m_iWindow setTitle:@"RFTEST V1"];
    
}

- (IBAction)StopTest:(id)sender
{
    m_bLoopTest = NO;
    [m_txtAppName setEnabled:YES];
    [m_txtAppLocationX setEnabled:YES];
    [m_txtAppLocationY setEnabled:YES];
    [m_txtAppClickFreq setEnabled:YES];
    [m_btnStart setEnabled:YES];
    [m_btnStop setEnabled:NO];
    
}

- (IBAction)StartTest:(id)sender
{
    m_bLoopTest = YES;
    [m_strAppName setString:[m_txtAppName stringValue]];
    m_iLocationX    = [m_txtAppLocationX intValue];
    m_iLocationY    = [m_txtAppLocationY intValue];
    m_iClickFreq    = [[m_txtAppClickFreq stringValue]intValue];
    
    [m_txtAppClickCounts setStringValue:@"0"];
    m_iClickCounts  = [m_txtAppClickCounts intValue];
    
    [m_txtAppName setEnabled:NO];
    [m_txtAppLocationX setEnabled:NO];
    [m_txtAppLocationY setEnabled:NO];
    [m_txtAppClickFreq setEnabled:NO];
    [m_btnStart setEnabled:NO];
    [m_btnStop setEnabled:YES];
    
    [NSThread detachNewThreadSelector:@selector(ThreadStartTest) toTarget:self withObject:nil];
    
}

- (void)ThreadStartTest
{
    while (m_bLoopTest)
    {
        [self ClickAppDefineButton];
        
        sleep(m_iClickFreq);
        
        m_iClickCounts = m_iClickCounts + 1;
        [m_txtAppClickCounts setStringValue:[NSString stringWithFormat:@"%d",m_iClickCounts]];
    }
}
- (void)ClickAppDefineButton
{
    NSLog(@"start ClickAppDefineButton");
    BOOL bResult = NO;
    CGFloat fWindowX=0,fWindowY=0;
    CFArrayRef windowList = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID);
    NSLog(@"%@", (__bridge NSArray*) windowList);
    
    for (NSMutableDictionary* entry in (__bridge NSArray*) windowList)
    {
        NSArray *arrKey = [entry allKeys];
        for (int i = 0; i<[arrKey count]; i++)
        {
            if ([[arrKey objectAtIndex:i]isEqual:@"kCGWindowName"])
            {
                if ([[entry valueForKey:@"kCGWindowName"] rangeOfString:m_strAppName].location != NSNotFound)
                {
                    bResult = YES;
                    // put window front
                    int pid = [[entry objectForKey:(id)kCGWindowOwnerPID] intValue];
                    ProcessSerialNumber   myPSN = {kNoProcess, kNoProcess};
                    GetProcessForPID(pid, &myPSN);
                    SetFrontProcessWithOptions(&myPSN, kSetFrontProcessFrontWindowOnly);
                    CGRect bounds;
                    CGRectMakeWithDictionaryRepresentation((__bridge CFDictionaryRef) [entry objectForKey:@"kCGWindowBounds"], &bounds);
                    
                    fWindowX = bounds.origin.x;
                    fWindowY = bounds.origin.y;
                    
                    usleep(5000);
                    //the point mouse will click
                    CGPoint pointSend = {fWindowX+m_iLocationX, fWindowY+m_iLocationY};
                    //mouse down
                    CGEventRef theEvent = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseDown, pointSend, kCGMouseButtonLeft);
                    CGEventPost(kCGHIDEventTap, theEvent);
                    CFRelease(theEvent);
                    //mouse up
                    theEvent = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseUp, pointSend, kCGMouseButtonLeft);
                    CGEventPost(kCGHIDEventTap, theEvent);
                    CFRelease(theEvent);
                    break;
                }
            }
        }
    }
    CFRelease(windowList);
    NSLog(@"end ClickAppDefineButton");
}


@end
