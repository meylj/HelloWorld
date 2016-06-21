//
//  AppDelegate.h
//  FireTestCoverage
//
//  Created by raniys on 1/7/15.
//  Copyright (c) 2015 raniys. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate,NSTableViewDataSource,
NSOutlineViewDataSource>
{
    IBOutlet NSButton *btnChoose;
    IBOutlet NSButton *btnOK;
    IBOutlet NSButton *btnExport;
    IBOutlet NSButton *checkUnfold;
    IBOutlet NSButton *checkTxtUnit;
    IBOutlet NSButton *checkTxtFixture;
    IBOutlet NSButton *checkXlsFixture;
    IBOutlet NSButton *checkExportTestCoverage;
    IBOutlet NSButton *checkAutoUpdateStatus;
    
    IBOutlet NSTextField *textFilePath;
    IBOutlet NSTextField *textCoveragePath;
    IBOutlet NSTextField *m_textProgress;
    
    
    IBOutlet NSComboBox *comboTestCoverageStatus;
    
    IBOutlet NSOutlineView *outlineViewDisplay;
    
    IBOutlet NSProgressIndicator *rollProgress;
    IBOutlet NSLevelIndicator   *m_lineProgress;
}

- (IBAction)chooseFile:(NSButton *)sender;
- (IBAction)loadDataFromFile:(NSButton *)sender;
- (IBAction)showOrHideCommandOnUI:(NSButton *)sender;
- (IBAction)exportToFile:(NSButton *)sender;
- (IBAction)doTestCoverage:(NSButton *)sender;
- (IBAction)doCommands:(NSButton *)sender;
- (IBAction)editFile:(id)sender;


@end



