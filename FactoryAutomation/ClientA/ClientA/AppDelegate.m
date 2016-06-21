//
//  AppDelegate.m
//  ClientA
//
//  Created by Andre on 13-10-22.
//  Copyright (c) 2013年 Andre. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void) stationAppeared : (HWTEStation *)station
{
    NSLog(@"station online");
    [station setDelegate:self];
    NSLog(@"Station Name: %@",[station stationName]);
    [m_station release];
    m_station = [station retain];
    NSLog(@"Station Info = %@,Station Gruop = %@",[station stationClass],[station numberOfSlots]);
}

- (void) station:(HWTEStation *)station finishedWithResults:(NSArray *)travelers {
    NSLog(@"station finishedWithResults => %@",travelers);
}

- (IBAction)OnActInitController:(id)sender {
    stationRoster = [HWTEStationRoster sharedRoster];
    [stationRoster retain];
    [stationRoster setDelegate:self];
}

- (IBAction)OnActSendStart:(id)sender {
    NSDictionary *dic = [NSDictionary dictionaryWithObject:@"1" forKey:eTraveler_TrayIDKey];
    NSArray *array = [NSArray arrayWithObject:dic];
    [m_station testWithTravelers:array];
}

- (IBAction)OnReleaseController:(id)sender {
    [stationRoster release];
}

@end
