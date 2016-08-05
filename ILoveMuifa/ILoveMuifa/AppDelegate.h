//
//  AppDelegate.h
//  ILoveMuifa
//
//  Created by Yaya8_liu on 6/2/16.
//  Copyright © 2016 Yaya8_liu. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSStringCategory.h"
#import "NSDateCategory.h"
#import "NSPanelCategory.h"
#import "DebugWindowController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate,NSTableViewDelegate,NSTableViewDataSource,NSTabViewDelegate,NSTextFieldDelegate>
{
    //NSWindow *window;
    // main view object
    IBOutlet NSTabView          *tabTestInfo;
    IBOutlet NSTableView        *tvCSVInfo;
    IBOutlet NSTableView        *tvUARTInfo;
    IBOutlet NSTableView        *tvFailInfo;
    IBOutlet NSTextView         *textViewFailInfo;
    
    // briefView view object
    IBOutlet NSView             *briefView;
    IBOutlet NSTextField        *lbPercentageNumber;
    IBOutlet NSLevelIndicator   *levelIndicator;
    IBOutlet NSTextField        *lbResultLabel;
    IBOutlet NSTextField        *lbUnitMark;
    IBOutlet NSTextField        *lbTotalCount;
    IBOutlet NSTextField        *lbScriptFile;
    IBOutlet NSButton           *btnStart;
    IBOutlet NSTextField        *lbTotalTime;
    
    // SN Labels view object
    IBOutlet NSView             *inputView;
    IBOutlet NSTextField        *lbPath;
    IBOutlet NSView             *listView;
    IBOutlet NSButton           *btnOpenLog;

    // data source for table view
    NSMutableArray              *m_arrCSVInfo;
    NSMutableArray              *m_arrFailInfo;
    
}

- (IBAction)startTest:(id)sender;

@end

