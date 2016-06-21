//
//  AppleTestStationAutomation
//
//  Created by Manuel Petit on 2013/05/30.
//  Copyright (c) 2013 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HWTEControlledStation.h"

@interface AppleTestStationAutomation : NSObject

/*
 * results is an array of results of type NSDictionary
 */
+ (void) registerStation:(id<HWTEControlledStation>)station;
+ (void) unregisterStation:(id<HWTEControlledStation>)station userInfo:(NSDictionary *)info;

+ (void) testStation:(id<HWTEControlledStation>)station finishedWithResults:(NSArray *)results;
+ (void) testStation:(id<HWTEControlledStation>)station abortedWithResults:(NSArray *)results;
+ (void) testStation:(id<HWTEControlledStation>)station reports:(NSDictionary *)report;
+ (void) testStation:(id<HWTEControlledStation>)station setOfflineWithStatus:(NSString *)status;

/*
 * checks to see if this is a raftStation
 * 1. checks for file override in /tmp/force-raft then /tmp/no-raft
 * 2. checks for [RAFT_LINE] in gh_station_info
 */
+ (bool) automationEnabled;

@end
