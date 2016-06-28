//
//  VaildateAndSignViewController.h
//  MailsTool
//
//  Created by allen on 20/3/2016.
//  Copyright © 2016 allen. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface VaildateAndSignViewController : NSViewController <NSPathControlDelegate>

@property (weak) IBOutlet NSPopUpButton *PopStation;
@property (weak) IBOutlet NSTextField *tfNewOverlay;
@property (weak) IBOutlet NSTextField *tfBaseOverlay;
@property (weak) IBOutlet NSTextField *tfNewLive;
@property (weak) IBOutlet NSTextField *tfBaseLive;
@property (strong) IBOutlet NSTextView *tvChangelist;
@property (weak) IBOutlet NSTextField *tfRadarNumber;
@property (weak) IBOutlet NSTextField *tfGitCommit;
@property (weak) IBOutlet NSTextField *tfP4Number;
@property (weak) IBOutlet NSTextField *labelGit;
@property (weak) IBOutlet NSTextField *tfNewTestall;
@property (weak) IBOutlet NSTextField *tfbaseTestall;
@property (weak) IBOutlet NSPopUpButton *PopReceiver;
@property (weak) IBOutlet NSPopUpButton *PopCCmail;
@property (weak) IBOutlet NSButton *btnSend;
@property (weak) IBOutlet NSPathControl *PCTestcoveragePath;





- (IBAction)SelectSation:(id)sender;
- (IBAction)SelectReceiver:(id)sender;
- (IBAction)SelectCCGroup:(id)sender;

- (IBAction)btnSend:(id)sender;

@end
