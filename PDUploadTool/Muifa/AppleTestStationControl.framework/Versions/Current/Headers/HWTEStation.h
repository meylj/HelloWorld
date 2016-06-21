//
//  HWTEStation.h
//  AppleTestStationControl
//
//  Created by Manuel Petit on 12/26/12.
//  Copyright (c) 2013 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol HWTEStationDelegate;


@interface HWTEStation : NSObject

- (BOOL) testWithTravelers:(NSArray *)travelers;

/*
 * Properties
 *
 *   stationName   : name of the station
 *   stationClass  : station class
 *   numberOfSlots : number of test positions in the station
 *   delegate      : set delegate to caller that wants to be notified of station status
 */
@property (readonly) NSString *stationName;
@property (readonly) NSString *stationClass;
@property (readonly) NSNumber *numberOfSlots;

@property (retain)  id                      userInfo;
@property (retain)  id<HWTEStationDelegate> delegate;

@end

