//
//  eTraveler_StationStatus.h
//  eTraveler
//
//  Created by Erich on 3/17/14.
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 * Station status codes
 * These codes are used to indicate more detail around test pass/fail to a automation system
 * status codes are updated on every unit pass/fail.
 */

enum {
	TEST_STATUS_CODE__PASS              = 0,
    TEST_STATUS_CODE__INCOMPLETE        = 1,
    TEST_STATUS_CODE__DISQUALIFY        = 2,
    TEST_STATUS_CODE__ABORT             = 3,
    TEST_STATUS_CODE__DUTLOWBATTERY     = 4,
    TEST_STATUS_CODE__DUTOUTOFPROCESS   = 5,
    TEST_STATUS_CODE__SNREADFAIL        = 6,
    TEST_STATUS_CODE__SF_ERR_RESULT     = 7,
    TEST_STATUS_CODE__FIXTURE_ISSUE     = 8,
    TEST_STATUS_CODE__NEEDSAUDIT        = 16,
    TEST_STATUS_CODE__NEEDSCALIBRATION  = 17,
    TEST_STATUS_CODE__NEEDSMAINTENANCE  = 18,
    TEST_STATUS_CODE__UNKNOWN_FAILURE   = 65534,
	TEST_STATUS_CODE__FAIL              = 65535,
};

/*
 * Options for stationStatus
 * These station status codes are set when a station is set to offline.
 */
extern NSString * const stationStatus_TesterAbortHWFailure;
extern NSString * const stationStatus_TesterNeedsAudit;
extern NSString * const stationStatus_TesterNeedsCalibration;
extern NSString * const stationStatus_TesterNeedsMaintenance;


@interface eTraveler_StationStatus : NSObject

+(uint16_t) stationStatusString_toStatusCode:(NSString *)status;

@end
