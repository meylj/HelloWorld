//
//  AppDelegate.h
//  MuifaA
//
//  Created by Andre on 13-10-22.
//  Copyright (c) 2013年 Andre. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppleTestStationAutomation/AppleControlledStation.h"
//#import "AppleTestStationControl/AppleTestStationControl.h"
#import "AppleTestStationAutomation/AppleControlledStationDelegate.h"
#import "AppleTestStationAutomation/AppleTestStationAutomation.h"
#import "eTraveler/eTravelerParameterKeys.h"
#import "eTraveler/eTraveler_TestResult.h"

@interface AppDelegate : NSObject <NSApplicationDelegate,AppleControlledStationDelegate>
{
    NSArray                     *m_eTraveler;
    AppleControlledStation      *m_testStation;
}

@property (assign) IBOutlet NSWindow *window;
- (IBAction)OnActInitTester:(id)sender;
- (IBAction)OnActRegisterStation:(id)sender;
- (IBAction)OnActTestResult:(id)sender;
- (IBAction)OnActReleaseTester:(id)sender;
@end
