//
//  ATSSerialToolAppDelegate.m
//  ATSSerialTool
//
//  Created by Lorky Luo on 5/31/12.
//  Copyright 2012 Pegatron. All rights reserved.
//

#import "ATSSerialToolAppDelegate.h"
#import "SingleWindow.h"

static int iIndexSave = 0;
@implementation ATSSerialToolAppDelegate
- (void)awakeFromNib
{
	nsMutaryOfWindows   = [[NSMutableArray alloc]init];
	
	NSScreen * screen = [NSScreen mainScreen];
	NSRect rect = [screen frame];
	
	nsPointWindowOrigin.x   = rect.origin.x;
	nsPointWindowOrigin.y   = rect.size.height;
	
	SingleWindow *zWindowController = [[SingleWindow alloc] initWithWindowNibName:@"SingleWindow"];
	[zWindowController showWindow:self];
	[zWindowController.window setFrameOrigin:nsPointWindowOrigin];
	[nsMutaryOfWindows addObject:zWindowController];
	[zWindowController release];
}

- (void)dealloc
{
	[super dealloc];
	[nsMutaryOfWindows release];
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return YES;
}

- (IBAction)createWindow:(id)pId
{
	SingleWindow *zWindowController = [[SingleWindow alloc] initWithWindowNibName:@"SingleWindow"];
	nsPointWindowOrigin.x   += 20.0;
	nsPointWindowOrigin.y   -= 15.0;
	[zWindowController.window setFrameOrigin:nsPointWindowOrigin];
	[zWindowController showWindow:self];
	[nsMutaryOfWindows addObject:zWindowController];
	
	[zWindowController release];
}

- (IBAction)SaveAsRTF:(id)sender 
{
	for (SingleWindow * mywindowController in nsMutaryOfWindows)
	{
		if ([mywindowController.window isKeyWindow])
		{
			NSSavePanel * panel = [NSSavePanel savePanel];
			[panel setNameFieldStringValue:[NSString stringWithFormat:@"%@-%d.rtf",[mywindowController bsdPath],iIndexSave++]];
			[panel beginSheetModalForWindow:mywindowController.window completionHandler:^(NSInteger result){
				if (result == NSOKButton) 
				{
					NSAttributedString * attriStr = [mywindowController information];
					NSData * data = [attriStr RTFFromRange:NSMakeRange(0, [attriStr length]) documentAttributes:nil];
					NSURL * filePath = [panel URL];
					
					[data writeToURL:filePath atomically:YES];
				}
			}];
		}
	}
}

@end
