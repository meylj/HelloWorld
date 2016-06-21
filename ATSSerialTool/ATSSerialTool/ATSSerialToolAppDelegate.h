//
//  ATSSerialToolAppDelegate.h
//  ATSSerialTool
//
//  Created by Lorky Luo on 5/31/12.
//  Copyright 2012 Pegatron. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ATSSerialToolAppDelegate : NSObject <NSApplicationDelegate> {
	NSMutableArray *nsMutaryOfWindows;
	NSPoint nsPointWindowOrigin;
}

- (IBAction)createWindow:(id)pId;
- (IBAction)SaveAsRTF:(id)sender;


@end
