//
//  AppDelegate.h
//  CheckJsonSum
//
//  Created by Scott on 15/6/30.
//  Copyright (c) 2015年 PEGA. All rights reserved.
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

- (IBAction)chooseFile:(NSButton *)sender;
- (IBAction)start:(NSButton *)sender;
- (IBAction)checkAllFileSum:(NSButton *)sender;

@end

