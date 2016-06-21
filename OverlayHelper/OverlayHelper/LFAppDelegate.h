//
//  LFAppDelegate.h
//  OverlayHelper
//
//  Created by Lorky on 9/19/14.
//  Copyright (c) 2014 Lorky. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface LFAppDelegate : NSObject <NSApplicationDelegate,NSPathControlDelegate>
{
	IBOutlet NSTextField * txtVersion;
	IBOutlet NSTextField * txtCheckSum;
	IBOutlet NSProgressIndicator *progress;
	IBOutlet NSPopUpButton *popProjects;
	IBOutlet NSPopUpButton *popStations;
	IBOutlet NSButton		*isRebuild;
	IBOutlet NSTextView *changeList;
    
    IBOutlet NSButton *isOffline;
    IBOutlet NSButton *isDisablePudding;
    IBOutlet NSButton *isDisableSignature;
    IBOutlet NSButton *isDisableLiveFunction;
    IBOutlet NSButton *isNoLiveControl;
    IBOutlet NSButton *isDefaultLivePath;
}

@property (assign) IBOutlet NSWindow *window;
- (IBAction)GoWork:(id)sender;
- (IBAction)ProjectDidChange:(id)sender;

@end
