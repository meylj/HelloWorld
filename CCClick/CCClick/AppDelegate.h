//
//  AppDelegate.h
//  CCClick
//
//  Created by chenchao on 15/1/8.
//  Copyright (c) 2015年 chenchao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

{
    IBOutlet NSWindow       *m_iWindow;
    
    IBOutlet NSTextField    *m_txtAppName;
    IBOutlet NSTextField    *m_txtAppLocationX;
    IBOutlet NSTextField    *m_txtAppLocationY;
    IBOutlet NSTextField    *m_txtAppClickFreq;
    IBOutlet NSTextField    *m_txtAppClickCounts;
    
    IBOutlet NSButton       *m_btnStart;
    IBOutlet NSButton       *m_btnStop;

    NSMutableString         *m_strAppName;
    int                     m_iLocationX;
    int                     m_iLocationY;
    int                     m_iClickFreq;
    int                     m_iClickCounts;
    
    
    BOOL                    m_bLoopTest;
    
    
    
}

- (IBAction)StartTest:(id)sender;
- (IBAction)StopTest:(id)sender;

@end

