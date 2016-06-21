//
//  TestStationKeys.h
//  AppleTestStationAutomation
//
//  Created by Manuel Petit on 2/19/14.
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


/*
 * options for abortTesting
 *
 *  + stationAbort_UnitDispositionKey -- what to do with the units
 *
 *     @ stationAbort_HoldUnits  -- withhold units
 *     @ stationAbort_EjectUnits -- eject units
 *
 */
extern NSString *stationAbort_UnitDispositionKey;
extern NSString *stationAbort_HoldUnits;
extern NSString *stationAbort_EjectUnits;



/*
 * Station Queries and Reports
 *
 *  + stationQuery_TopicKey  -- what the query is about
 *  + stationReport_TopicKey -- what the query is about (aliased to stationQuery_TopicKey)
 *
 *     @ stationQuery_progressReport -- progress reported as NSNumber from 0 to 1
 *     @ stationQuery_ETCReport      -- estimated time to completion (NSNumber in seconds)
 *
 * Examples:
 *
 *    NSDictionary *query_1 = @{ stationQuery_TopicKey : stationQuery_progressReport };
 *    NSDictionary *reply_1 = @{ stationReport_TopicKey      : stationQuery_progressReport,
 *                               stationQuery_progressReport : @0.71 };
 *
 *    NSDictionary *query_2 = @{ stationQuery_TopicKey : stationQuery_ETCReport };
 *    NSDictionary *reply_2 = @{ stationQuery_ReportKey : stationQuery_ETCReport,
 *                               stationQuery_ETCReport : @47 };
 *
 */
extern NSString *stationQuery_TopicKey;
extern NSString *stationReport_TopicKey;
extern NSString *stationQuery_progressReport;
extern NSString *stationQuery_ETCReport;
