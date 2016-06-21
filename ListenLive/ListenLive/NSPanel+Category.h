//
//  NSPanel+Category.h
//  test1
//
//  Created by Lorky on 1/22/15.
//  Copyright (c) 2015 Lorky. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSPanel (Category)

NSInteger RunAlertPanel(NSString *title, NSString *msgFormat, NSString *defaultButton, NSString *alternateButton, NSString *otherButton);
id GetAlertPanel(NSString *title, NSString *msgFormat, NSString *defaultButton, NSString *alternateButton, NSString *otherButton);
@end
