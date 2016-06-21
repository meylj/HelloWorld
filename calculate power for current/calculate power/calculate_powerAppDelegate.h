//
//  calculate_powerAppDelegate.h
//  calculate power
//
//  Created by  on 12-4-16.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface calculate_powerAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    IBOutlet NSButton *btnForPostBurn;
    //IBOutlet NSLevelIndicator *levelIndictor;
    NSMutableString *m_szPathPreBurn;
    NSMutableString *m_szPathPostBurn;
    IBOutlet NSButton *btnForPreBurn;
    IBOutlet NSButton *btnStart;
    IBOutlet NSTextField *txtShowPathPre;
    IBOutlet NSTextField *txtShowPathPost;
    NSArray *arryItemFirst;
    NSArray *arryItemSecond;
    IBOutlet NSComboBox *comBox;
    IBOutlet NSProgressIndicator *processIndicator;
    IBOutlet NSTextField *txtfield;
    IBOutlet NSButton *btnExit;
    // NSFileHandle *fileHandle;
    //IBOutlet NSComboBoxCell *comboxCell;
    
}
-(IBAction)choosePathForPre:(id)sender;
-(IBAction)choosePathForPost:(id)sender;
-(void)choosePath:(NSMutableString *)m_path;
-(IBAction)btnStart:(id)sender;
-(IBAction)btnExit:(id)sender;
@property (assign) IBOutlet NSWindow *window;

@end
