//
//  AppDelegate.h
//  ListenLive
//
//  Created by raniys on 3/31/15.
//  Copyright (c) 2015 raniys. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    IBOutlet NSTextField *textTimeLabel;
    IBOutlet NSPopUpButton *popTimeZone;
    IBOutlet NSTextView *textViewDisplay;
}
@end

