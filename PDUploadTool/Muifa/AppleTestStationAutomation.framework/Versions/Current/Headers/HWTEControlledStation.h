//
//  AppleTestStationAutomation
//
//  Created by Manuel Petit on 2013/05/30.
//  Copyright (c) 2013 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol HWTEControlledStation <NSObject>


@required - (BOOL) startWithTravelers:(NSArray *)travelers;


@required @property (readonly) NSString  *stationName;
@required @property (readonly) NSString  *stationClass;
@required @property (readonly) NSNumber  *numberOfSlots;


@end
