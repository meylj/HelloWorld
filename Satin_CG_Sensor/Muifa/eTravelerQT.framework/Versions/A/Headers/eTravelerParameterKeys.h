//
//  eTravelerParameterKeys.h
//  eTravelerRF
//
//
//  Developer        Date          Description
//  ============     ==========    ===========
//  Manuel Petit     07/15/2013    Created
//  Benjamin Lin     02/13/2015    Added SlotIdKey

#import <Foundation/Foundation.h>

/*
 * Parameter key declarations.
 */

/*
 * eTraveler_SerialNumberKey : serial number of the unit being tested. The value will be a NSString.
 *
 * eTraveler_TrayIDKey  : ID of the tray holding the unit being tested. The value will be a NSString.
 * eTraveler_SlotIdKey  : ID of a slot in a tester.  The value will be a NSInteger.
 * eTraveler_TestResultKey : result of the test. The value will be one of the constants declared in RAFTTestResult.h.
 *
 * eTraveler_ProcessKey : factory process. The value will be one of the constants declared in eTraveler_StationProcess.h.
 * eTraveler_ProcessArgsKey : Extra information for the factory process. The value will be one of the constants declared in eTraveler_StationProcess.h.
 *
 * eTraveler_PerStationInformationKey : Per station information.  The system will enforce that a station can only modify the entry under its own groundhog name.
 * eTraveler_PerStationClassInformationKey : Per station class information.  The system will enforce that a station can only modify the entry under its own groundhog class name.
 *
 * eTraveler_TestDelayedInSecondsKey : Key corresponding to the approximate number of seconds for which a test is delayed. The value will be an integer.
 */
extern NSString * const eTraveler_SerialNumberKey;
extern NSString * const eTraveler_TrayIDKey;
extern NSString * const eTraveler_SlotIdKey;
extern NSString * const eTraveler_TestResultKey;

extern NSString * const eTraveler_ProcessKey;
extern NSString * const eTraveler_ProcessArgsKey;

extern NSString * const eTraveler_StationIdKey;
extern NSString * const eTraveler_StationClassKey;
extern NSString * const eTraveler_StationGangKey;
extern NSString * const eTraveler_PerStationInformationKey;
extern NSString * const eTraveler_PerStationClassInformationKey;
extern NSString * const eTraveler_PerStationGangInformationKey;
extern NSString * const eTraveler_StatusMessageKey;
extern NSString * const eTraveler_SwVersionKey;
extern NSString * const eTraveler_SwCapabilitiesKey;
extern NSString * const eTraveler_CustomTestResultKey;
extern NSString * const eTraveler_CustomDataKey;

extern NSString * const eTraveler_TestFailuresKey;

/*
 * Old Compat keys
 */
extern NSString * const eTraveler_TestDelayedInSecondsKey;
extern NSString * const eTraveler_XYCellSessionKey;
extern NSString * const eTraveler_StationProcessIDKey;
extern NSString * const eTraveler_OSModeKey;

