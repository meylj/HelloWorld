//
//  ToSummaryLogToolAppDelegate.h
//  ToSummaryLogTool
//
//  Created by Pleasure on 12-8-27.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CGSPrivate.h"
#define macro_W_Summary 1


@interface ToSummaryLogToolAppDelegate : NSObject <NSApplicationDelegate,NSTableViewDataSource,NSTableViewDelegate,NSWindowDelegate> {
@private
    NSWindow *window;
    NSMutableArray *m_aryTable;
    NSOpenPanel *m_myPanel;
    BOOL bstop;
    IBOutlet NSTableView *m_tableView;
    IBOutlet NSTextField *m_textField;
    IBOutlet NSTextField *txtHelp;
    IBOutlet NSScrollView *vTable;
    IBOutlet    NSView   *vHelp;
    IBOutlet NSLevelIndicator    *pIndicator;
    IBOutlet NSTextField *txtIndicator;
    IBOutlet NSTextField *lTotalCount;
    IBOutlet NSButton *chooseCSVFile;
    IBOutlet NSButton *combine;
    IBOutlet NSButton *deleteCSVFile;
    IBOutlet NSButton *help;
    IBOutlet NSScroller *scroller;
    NSString *m_MuifaStation;
    NSString *m_Version;
    NSMutableArray * m_arrUpLimit;
    NSMutableArray * m_arrDnLimit;
    IBOutlet NSMatrix *mtDelete;
    IBOutlet NSTextField *savepath;
}
@property (assign) IBOutlet NSWindow *window;
-(IBAction)ChooseCSVFiles:(id)sender;
-(IBAction)Combine:(id)sender;
-(IBAction)DeleteCSVFile:(NSButton *)sender;
-(IBAction)help:(id)sender;
-(BOOL)ParserCsv:(NSMutableArray *)arrFiles GetItems:(NSMutableArray *)items;
-(BOOL)compare:(NSMutableArray *)arrCSVlogs;
-(void)change;
@end
