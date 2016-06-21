//
//  LFAppDelegate.h
//  LogFormatter
//
//  Created by Lorky on 5/22/14.
//  Copyright (c) 2014 Lorky. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LFAppDelegate : NSObject <NSApplicationDelegate>
{
	IBOutlet NSTextField *_logPath;
	IBOutlet NSMatrix *mobileOnly;
	
	IBOutlet NSButton *btnKeepNameLimit;
	IBOutlet NSProgressIndicator *progIndicator;
	NSDate	* date;
}

@property (assign) IBOutlet NSWindow *window;
@property (copy, nonatomic) NSString * logInfo;

- (IBAction)FormatLog:(id)sender;
- (IBAction)CoupleFormatterLogs:(id)sender;
- (IBAction)helpSend:(id)sender;
@end
