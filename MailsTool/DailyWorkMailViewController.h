//
//  DailyWorkMailViewController.h
//  MailsTool
//
//  Created by allen on 20/3/2016.
//  Copyright © 2016 allen. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DailyWorkMailViewController : NSViewController

@property (weak) IBOutlet NSTextField *tfDailyWorkContent;
@property (weak) IBOutlet NSTextField *tfDetailMailTitle;
@property (weak) IBOutlet NSTextField *tfRadarNumber;
@property (weak) IBOutlet NSButton *bUrgent;
@property (weak) IBOutlet NSTextField *tfAssignPerson;
@property (weak) IBOutlet NSTextField *tfCCMail;
@property (weak) IBOutlet NSPopUpButton *PopMailList;
@property (readwrite,assign) IBOutlet NSTextView *tfComment;
@property (weak) IBOutlet NSButton *bsend;



- (IBAction)SendMail:(id)sender;
- (IBAction)MailListChange:(id)sender;

@end
