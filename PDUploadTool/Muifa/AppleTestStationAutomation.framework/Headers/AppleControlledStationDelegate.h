//
//  AppleTestStationAutomation
//
//  Created by Manuel Petit on 2013/05/30.
//  Copyright (c) 2013 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@class AppleControlledStation;


@protocol AppleControlledStationDelegate <NSObject>

@required - (BOOL) station:(AppleControlledStation *)station startWithTravelers:(NSArray *)travelers;

@end
