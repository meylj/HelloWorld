//
//  eTraveler_QueriesAndReports.h
//  eTraveler
//
//  Created by Kai Huang on 7/16/14.
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


/*
 * Example Usage
 *
 *    Query
 *    {
 *       eTraveler_QueryTopicKey       : eTraveler_Custom_Topic
 *       eTraveler_CustomDataDictKey   : {...}
 *    }
 */

extern NSString * const eTraveler_QueryTopicKey;
extern NSString * const eTraveler_ReportTopicKey;




/*
 *  See AppleTestStationAutomation/TestStationKeys.h for station definition of
 *  stationQuery_TopicKey
 *  stationReport_TopicKey
 */



/*
 * Query/Report
 * KEYS
 */
extern NSString * const eTraveler_CustomDataDictKey;                        /*custom data section*/

extern NSString * const eTraveler_CalibrationValidTimeRemainingKey;         /*time remaining in seconds*/
extern NSString * const eTraveler_AuditValidTimeRemainingKey;               /*time remaining in seconds*/
extern NSString * const eTraveler_QueryConnectedDUTs;                       /*LEGACY* connected duts*/
extern NSString * const eTraveler_ReportConnectedDUTs;                      /*LEGACY* connected duts*/
extern NSString * const eTraveler_ConnectedDUTsArrayKey;                    /*connected duts*/
extern NSString * const eTraveler_ConnectedDUTsArray;                       /*LEGACY* data array*/
extern NSString * const eTraveler_NSErrorObjectKey;                         /*nserror*/



/*
 * Query/Report
 * TOPICS
 */
extern NSString * const eTraveler_custom_Topic;                             /*custom topic*/

extern NSString * const eTraveler_CalibrationExpiring_Topic;                /*station calibration expiring*/
extern NSString * const eTraveler_AuditExpiring_Topic;                      /*station audit expiring*/
extern NSString * const eTraveler_ConnectedDUTs_Topic;                      /*get connected duts*/
extern NSString * const eTraveler_ReportError_Topic;                        /*report errors*/
extern NSString * const eTraveler_SwVersion_Topic;                          /*station app sw version*/
extern NSString * const eTraveler_SwCapabilities_Topic;                     /*statoin app sw cabavilities*/


