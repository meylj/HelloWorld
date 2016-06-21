//
//  HWTEStationRosterDelegate.h
//  AppleTestStationControl
//
//  Created by Manuel Petit on 12/26/12.
//  Copyright (c) 2013 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HWTEStation;
@class HWTEForensicReport;


@protocol HWTEStationRosterDelegate <NSObject>

@required - (void) stationAppeared : (HWTEStation *)station;
@optional - (void) stationDied     : (HWTEStation *)station   reason:(HWTEForensicReport *)deathReason;

@end
