//
//  AppleTestStationAutomation
//
//  Created by Manuel Petit on 2013/05/30.
//  Copyright (c) 2013 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HWTEControlledStation.h"

@protocol AppleControlledStationDelegate;

@interface AppleControlledStation : NSObject<HWTEControlledStation>
{
	NSString *_stationName;
	NSString *_stationClass;
	NSNumber *_numberOfSlots;

	id<AppleControlledStationDelegate> _delegate;

	id _userInfo;
}

+ controlledStationWithName:(NSString *)stationName andClass:(NSString *)stationClass andNumberOfSlots:(NSNumber *)numberOfSlots;

@property (retain) id<AppleControlledStationDelegate> delegate;
@property (retain) id userInfo;

@end
