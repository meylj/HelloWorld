//
//  eTraveler_StationProcess.h
//  eTraveler
//
//
//  Developer        Date          Description
//  ============     ==========    ===========
//  Manuel Petit     07/15/2013    Created
//  Benjamin Lin     11/17/2014    Added Execution, ExecutionStart
//                                 Added Priming, Testing and PostProcessing
//  Benjamin Lin     03/04/2015    Per Xuefeng Zhao's request:
//                                 Removed Priming... process flavors
//                                 Added ProcessStageKey and priming...process stages


#import <Foundation/Foundation.h>

/*
 * Test Process constant.
 */
extern NSString * const eTraveler_StationProcessTest;
extern NSString * const eTraveler_StationProcessAudit;
extern NSString * const eTraveler_StationProcessGRR;
extern NSString * const eTraveler_StationProcessCalibrate;



/*
 * Process flavor, part of eTraveler_ProcessArgsKey map.
 * Value of favors are like: LAT, UAT, ZAT...
 */
extern NSString * const eTraveler_ProcessFlavorKey;

/*
 * Process stage, part of eTraveler_ProcessArgsKey map.
 */
extern NSString* const eTraveler_ProcessStageKey;

/*
 * Values of process stages
 * This defines stage names in a multi-stage test.
 */
extern NSString* const eTraveler_ProcessStagePriming;
extern NSString* const eTraveler_ProcessStageTesting;
extern NSString* const eTraveler_ProcessStagePostProcessing;


/*
 * Station process execution key, part of eTraveler_ProcessArgsKey map.
 * This separates queries from execution during a multi-stage test.
 */
extern NSString * const eTraveler_ProcessExecutionKey;


/*
 * Possible values associated with station process execution.
 * Start: starts a test in a particular stage (other than first.)
 */
extern NSString * const eTraveler_ProcessExecutionStart;