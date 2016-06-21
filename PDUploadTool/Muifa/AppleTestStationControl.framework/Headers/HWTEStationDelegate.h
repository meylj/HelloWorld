//
//  HWTEStationDelegate.h
//  AppleTestStationControl
//
//  Created by Manuel Petit on 1/7/13.
//  Copyright (c) 2013 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HWTEStation;

@protocol HWTEStationDelegate <NSObject>

/*
 * Called when a station group is finished testing
 * This function will be called for each group that is finished testing
 * @param station that finished
 * @param TesterGroup is the group that finished testing
 * @param results for each slot 
 */
- (void) station:(HWTEStation *)station finishedWithResults:(NSArray *)travelers;

@optional - (void) station:(HWTEStation *)tester isReadyToLoadDUTs:(BOOL)yes_or_no;
@optional - (void) station:(HWTEStation *)tester isReadyToUnloadDUTs:(BOOL)yes_or_no;
@optional - (void) station:(HWTEStation *)tester isInHomePosition:(BOOL)yes_or_no;

@end
