//
//  DebugWindowController.m
//  Muifa
//
//  Created by Lorky on 11/19/13.
//  Copyright (c) 2013 PEGATRON. All rights reserved.
//

#import "DebugWindowController.h"

@interface DebugWindowController ()

@end

@implementation DebugWindowController

@synthesize informations = m_Informations;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
		
    }
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:NSTableViewSelectionDidChangeNotification
												  object:nil];
	[super dealloc];
}

- (void)showWindow:(id)sender
{
	[super showWindow:sender];
	// Registe a observer to monitor tableview selection change.
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(tableViewSelectionDidChange:)
												 name:NSTableViewSelectionDidChangeNotification
											   object:nil];
	
	[self.window setFrame:[[NSScreen mainScreen] visibleFrame] display:YES];
	[self.window setTitle:[NSString stringWithFormat:@"%@	%@",[m_Informations objectForKey:@"CurrentIndex"], [m_Informations objectForKey:@"ItemName"]]];
	NSLog(@"%@",m_Informations);
	// Set item test result
	NSImage *imageResult = [m_Informations objectForKey:@"Image"];
	if ([[imageResult name] isEqualToString:NSImageNameStatusAvailable])
	{
		[resultShown setStringValue:@"PASS"];
		[resultShown setTextColor:[NSColor greenColor]];
	}
	else if ([[imageResult name] isEqualToString:NSImageNameStatusUnavailable])
	{
		[resultShown setStringValue:@"FAIL"];
		[resultShown setTextColor:[NSColor redColor]];
	}
	else
	{
		[resultShown setStringValue:@"Unknown"];
		[resultShown setTextColor:[NSColor grayColor]];
	}
	
	// update sub item table view
	dataSource = [m_Informations objectForKey:@"FunnyZoneSubItemInfo"];
	[subItemTableView setDataSource:self];
	[subItemTableView reloadData];

	// update UART logs.
	NSAttributedString * attributeString = [m_Informations objectForKey:@"FunnyZoneUartLog"];
	[singleItemUARTMessage setSelectedRange:NSMakeRange( 0, [[attributeString string] length])];
	[[singleItemUARTMessage textStorage] insertAttributedString:attributeString
														   atIndex:0];
	[singleItemUARTMessage scrollRangeToVisible: NSMakeRange(0, 0)];
	
	// Update Console logs
	NSAttributedString * console = [m_Informations objectForKey:@"FunnyZoneConsoleMessage"];
	[singleItemConsoleMessage setSelectedRange:NSMakeRange(0, [[console string] length])];
	[[singleItemConsoleMessage textStorage] insertAttributedString:console
														   atIndex:0];
	[singleItemConsoleMessage scrollRangeToVisible: NSMakeRange(0, 0)];
}
#pragma mark - TableView datasource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [dataSource count];
}

/* This method is required for the "Cell Based" TableView, and is optional for the "View Based" TableView. If implemented in the latter case, the value will be set to the view at a given row/column if the view responds to -setObjectValue: (such as NSControl and NSTableCellView).
 */
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	return [[dataSource objectAtIndex:row] objectForKey:[tableColumn identifier]];
}

#pragma mark - TableView notification
- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	// Scroll Range to visible
	if ([[notification object] selectedRow] <= [dataSource count])
	{
		NSDictionary * userInfo = [dataSource objectAtIndex:[[notification object] selectedRow]];
		NSString * strSelectedItem = [userInfo objectForKey:@"SubName"];
		NSNumber * numIndex = [userInfo objectForKey:@"Index"];
		NSString * finderString = [NSString stringWithFormat:@"[%d] %@",[numIndex intValue] + 1, strSelectedItem];
		NSAttributedString * console = [m_Informations objectForKey:@"FunnyZoneConsoleMessage"];
		// fouse
		if (NSNotFound != [[console string] rangeOfString:finderString].location)
			[singleItemConsoleMessage scrollRangeToVisible:[[console string] rangeOfString:finderString]];
	}
}
@end
