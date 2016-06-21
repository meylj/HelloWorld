//
//  eTraveler_TestResult.h
//  eTraveler
//
//
//  Developer        Date          Description
//  ============     ==========    ===========
//  Manuel Petit     07/15/2013    Created
//  Benjamin Lin     02/19/2015    Added Tether and ShieldBox failures
//  Benjamin Lin     03/19/2015    Added Instrument failure



#import <Foundation/Foundation.h>


extern NSString * const eTraveler_TestPassedResult;
extern NSString * const eTraveler_TestFailedResult;
extern NSString * const eTraveler_TestIncompleteResult;
extern NSString * const eTraveler_TestDisqualifyFailResult;
extern NSString * const eTraveler_TestDUTLowBatteryResult;
extern NSString * const eTraveler_TestDUTOutOfProcessResult;
extern NSString * const eTraveler_TestSNReadFailResult;
extern NSString * const eTraveler_TestSFErrorResult;
extern NSString * const eTraveler_TestAbortResult;
extern NSString * const eTraveler_TestFixtureIssueResult;
extern NSString * const eTraveler_TetherFailResult;
extern NSString * const eTraveler_DetetherFailResult;
extern NSString * const eTraveler_ShieldBoxOpenFailResult;
extern NSString * const eTraveler_ShieldBoxCloseFailResult;
// e.g. Lost connection with RF Signal Analyzer
extern NSString * const eTraveler_InstrumentFailResult;
extern NSString * const eTraveler_CustomTestResult;
