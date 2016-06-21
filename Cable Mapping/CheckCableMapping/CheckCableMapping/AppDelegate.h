//
//  AppDelegate.h
//  CheckCableMapping
//
//  Created by Lorky on 7/13/13.
//  Copyright (c) 2013 Lorky. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PEGA_ATS_UART/PEGA_ATS_UART.h"


@interface AppDelegate : NSObject <NSApplicationDelegate,NSTableViewDataSource>
{
	// Vars
	NSDictionary	* dictCableMapping;
	NSMutableArray	* aryRequiredTargets;
	NSMutableString * strDebugInfo;
	
	NSMutableArray	* aryTableViewDataSource;
	
	// Outlets
	IBOutlet NSTextField	*labResult;
	IBOutlet NSTextView		*textDebugInfo;
	IBOutlet NSTableView	*tbCables;
	IBOutlet NSPopUpButton	*fixtureSelected;
	IBOutlet NSWindow		*myWindow;
}

//@property (nonatomic) IBOutlet NSWindow *myWindow;

- (IBAction)DoMapping:(id)sender;


@end
