//
//  DebugWindowController.h
//  Muifa
//
//  Created by Lorky on 11/19/13.
//  Copyright (c) 2013 PEGATRON. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DebugWindowController : NSWindowController
<NSTableViewDataSource, NSTableViewDelegate>
{
	NSDictionary * m_Informations;
	IBOutlet NSTextField	*resultShown;
	IBOutlet NSTextView		*singleItemConsoleMessage;
	IBOutlet NSTextView		*singleItemUARTMessage;
	IBOutlet NSTableView	*subItemTableView;
	
	NSArray					*dataSource;
}

@property (nonatomic,retain) NSDictionary * informations;

@end
