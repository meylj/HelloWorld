//
//  NSPanel+Category.m
//  FunnyZone
//
//  Created by Scott on 15/8/21.
//  Copyright (c) 2015年 PEGATRON. All rights reserved.
//

#import "NSPanelCategory.h"

@implementation NSPanel (NSPanelCategory)

NSInteger ATSRunAlertPanel(NSString *title, NSString *msgFormat, NSString *firtButton, NSString *secondButton, NSString *thirdButton)
{
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= __MAC_10_10
    NSAlert * alert = [[NSAlert alloc] init];
    alert.messageText = title;
    alert.informativeText = msgFormat;
    if (firtButton) [alert addButtonWithTitle:firtButton];
    if (secondButton) [alert addButtonWithTitle:secondButton];
    if (thirdButton) [alert addButtonWithTitle:thirdButton];
    [alert layout];
    NSInteger returnCode = [alert runModal];
    //[alert release];
    return returnCode;
#else
    return NSRunAlertPanel(title, msgFormat, defaultButton, alternateButton, otherButton);
#endif
}

//When calling this function, need to release the alert.
id ATSGetAlertPanel(NSString *title, NSString *msgFormat, NSString *firtButton, NSString *secondButton, NSString *thirdButton)
{
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= __MAC_10_10
    NSAlert * alert = [[NSAlert alloc] init];
    alert.messageText = title;
    alert.informativeText = msgFormat;
    if (firtButton) [alert addButtonWithTitle:firtButton];
    if (secondButton) [alert addButtonWithTitle:secondButton];
    if (thirdButton) [alert addButtonWithTitle:thirdButton];
    [alert layout];
    return alert;
#else
    return NSGetAlertPanel(title, msgFormat, defaultButton, alternateButton, otherButton);
#endif
}
@end
