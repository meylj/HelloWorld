//
//  AppDelegate.m
//  MuifaA
//
//  Created by Andre on 13-10-22.
//  Copyright (c) 2013年 Andre. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL) station:(AppleControlledStation *)station startWithTravelers:(NSArray *)travelers {
    NSLog(@"AppleControlledStation = %@,startWithTravelers = %@",station,travelers);
    [m_eTraveler release];
    m_eTraveler = [travelers retain];
    return YES;
}

- (IBAction)OnActInitTester:(id)sender {
    m_testStation = [AppleControlledStation controlledStationWithName:@"Pega.ATS.com.tw"
                                                             andClass:@"QT0"
                                                     andNumberOfSlots:[NSNumber numberWithInt:1]];
    [m_testStation setDelegate:self];
    [m_testStation retain];
}

- (IBAction)OnActRegisterStation:(id)sender {
    [AppleTestStationAutomation registerStation:m_testStation];
}

- (IBAction)OnActTestResult:(id)sender {
    NSDictionary *dictInfo = [m_eTraveler objectAtIndex:0];
    NSString    *szSerialNo = [dictInfo valueForKey:eTraveler_SerialNumberKey];
    NSArray     *result;
    NSMutableDictionary *resultInfo = [[NSMutableDictionary alloc] init];
    
    [resultInfo setValue:szSerialNo forKey:eTraveler_SerialNumberKey];
    [resultInfo setValue:eTraveler_TestPassedResult forKey:eTraveler_TestResultKey];
    result = [NSArray arrayWithObject:resultInfo];
    [AppleTestStationAutomation testStation:m_testStation finishedWithResults:result];
    [resultInfo release];
}

- (IBAction)OnActReleaseTester:(id)sender {
    [m_testStation release];
    m_testStation = nil;
}

@end
