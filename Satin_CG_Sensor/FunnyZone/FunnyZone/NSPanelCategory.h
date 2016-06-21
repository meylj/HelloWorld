//
//  NSPanel+Category.h
//  FunnyZone
//
//  Created by Scott on 15/8/21.
//  Copyright (c) 2015年 PEGATRON. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSPanel (NSPanelCategory)
NSInteger ATSRunAlertPanel(NSString *title, NSString *msgFormat, NSString *firtButton, NSString *secondButton, NSString *thirdButton);
id ATSGetAlertPanel(NSString *title, NSString *msgFormat, NSString *firtButton, NSString *secondButton, NSString *thirdButton);
@end
