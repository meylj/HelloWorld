//
//  NSPanel+Category.m
//  test1
//
//  Created by Lorky on 1/22/15.
//  Copyright (c) 2015 Lorky. All rights reserved.
//

#import "NSPanel+Category.h"

@implementation NSPanel (Category)

NSInteger RunAlertPanel(NSString *title, NSString *msgFormat, NSString *defaultButton, NSString *alternateButton, NSString *otherButton)
{
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= __MAC_10_10
	NSAlert * alert = [[NSAlert alloc] init];
	alert.messageText = title;
	alert.informativeText = msgFormat;
	if (defaultButton) [alert addButtonWithTitle:defaultButton];
	if (alternateButton) [alert addButtonWithTitle:alternateButton];
	if (otherButton) [alert addButtonWithTitle:otherButton];
	[alert runModal];
//	[alert release];
	return 1;
#else
	return NSRunAlertPanel(title, msgFormat, defaultButton, alternateButton, otherButton);
#endif
}

id GetAlertPanel(NSString *title, NSString *msgFormat, NSString *defaultButton, NSString *alternateButton, NSString *otherButton)
{
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= __MAC_10_10
	NSAlert * alert = [[NSAlert alloc] init];
	alert.messageText = title;
	alert.informativeText = msgFormat;
	if (defaultButton) [alert addButtonWithTitle:defaultButton];
	if (alternateButton) [alert addButtonWithTitle:alternateButton];
	if (otherButton) [alert addButtonWithTitle:otherButton];
	return alert;
#else
	return NSGetAlertPanel(title, msgFormat, defaultButton, alternateButton, otherButton);
#endif
}

@end
