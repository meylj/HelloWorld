//
//  AppDelegate.h
//  TestRegex
//
//  Created by Yaya8_liu on 12-10-11.
//  Copyright (c) 2012年 Yaya8_liu. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    IBOutlet NSButton *btnStart;
    IBOutlet NSButton *btnOpenFile;
    IBOutlet NSButton *checkData;
    IBOutlet NSButton *checkVersion;
    IBOutlet NSButton *checkBuild;
    IBOutlet NSButton *checkHash;
    IBOutlet NSButton *checkAllFile;
    
    IBOutlet NSTextField *textFilePath;
    IBOutlet NSTextField *textHashValue;
    
    NSMutableDictionary *m_dicChoose;

}

@property (assign) IBOutlet NSWindow *window;
- (IBAction)chooseFile:(NSButton *)sender;
- (IBAction)start:(NSButton *)sender;
- (IBAction)checkAllFileSum:(NSButton *)sender;

@end
