//
//  HWTEStationRoster.h
//  AppleTestStationControl
//
//  Created by Manuel Petit on 12/26/12.
//  Copyright (c) 2013 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol HWTEStationRosterDelegate;


@interface HWTEStationRoster : NSObject

/*
 * Properties
 *
 *   stations : Array of stations to control
 *   delegate : set delegate to caller that wants to be notified of station status
 */
@property (readonly) NSArray *stations;
@property (retain)   id<HWTEStationRosterDelegate>  delegate;

/*
 * returns a defaultRoster, nil if not initalized first
 */
+ (HWTEStationRoster *)sharedRoster;


@end
