//
//  ICCIDLABLEPRINTAppDelegate.h
//  ICCIDLABLEPRINT
//

//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "controlPrint.h"
#import "SFIS_Query.h"


@interface ICCIDLABLEPRINTAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    IBOutlet    NSTextField*    txtRspInfo;
    IBOutlet    NSTextField*    txtInputStr;  
}

@property (assign) IBOutlet NSWindow *window;
- (NSString *)getInfoWithKey :(NSString *)key;
- (void)PrintInfo: (NSNotification  *)noti;
- (BOOL)CmpISN;
- (BOOL)CmpICCID;

@end
