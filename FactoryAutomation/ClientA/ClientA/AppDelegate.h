//
//  AppDelegate.h
//  ClientA
//
//  Created by Andre on 13-10-22.
//  Copyright (c) 2013年 Andre. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "AppleTestStationControl/AppleTestStationControl.h"
//#import "AppleTestStationAutomation/AppleTestStationAutomation.h"
#import "eTraveler/eTravelerParameterKeys.h"
#import "eTraveler/eTraveler_TestResult.h"

@interface AppDelegate : NSObject <NSApplicationDelegate,HWTEStationRosterDelegate,HWTEStationDelegate>
{
    HWTEStation                 *m_station;
    HWTEStationRoster           *stationRoster;
}
@property (assign) IBOutlet NSWindow *window;
- (IBAction)OnActInitController:(id)sender;
- (IBAction)OnActSendStart:(id)sender;
- (IBAction)OnReleaseController:(id)sender;
@end
