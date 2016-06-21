//
//  AppDelegate.h
//  SearchErrorResponseLog
//
//  Created by 张斌 on 14-8-21.
//  Copyright (c) 2014年 张斌. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate,NSTableViewDataSource,NSTableViewDelegate>
{
//    NSString * m_szDiretory;
//    NSString * m_szMoveDir;
    
    IBOutlet NSTextField * m_textDiretory;
    IBOutlet NSTextField * m_textMoveDir;
    IBOutlet NSProgressIndicator * m_process;
    IBOutlet NSButton * m_btnParse;
    IBOutlet NSTableView * m_tableView;
    
    
}

@property (assign) IBOutlet NSWindow *window;
@property(copy)NSString * m_szDiretory;
@property(copy)NSString * m_szMoveDir;
@property(retain)NSMutableDictionary * m_dicDescription;

-(IBAction)ParseLogFile:(id)sender;
-(IBAction)AddDiretory:(id)sender;
-(IBAction)MoveDiretory:(id)sender;
-(void)ParseFileThread;
-(void)ParseOK:(NSNotification *)note;

@end
