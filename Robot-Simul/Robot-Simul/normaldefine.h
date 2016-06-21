//
//  normaldefine.h
//  ThreeDSpaceOptimization
//
//  Created by 漢青 陳 on 13-3-26.
//  Copyright 2013年 PEGATRON. All rights reserved.
//

#ifndef ThreeDSpaceOptimization_normaldefine_h
#define ThreeDSpaceOptimization_normaldefine_h

#define FUNCTION_SUCCESS                                    0
#define FUNCTION_FAILURE_1                                  1
#define FUNCTION_FAILURE_2                                  2
#define FUNCTION_FAILURE_3                                  3
#define FUNCTION_FAILURE_4                                  4

//position
#define OPTIMIZATION_POSITION_X                             @"POSITION_X"
#define OPTIMIZATION_POSITION_Y                             @"POSITION_Y"
#define OPTIMIZATION_POSITION_Z                             @"POSITION_Z"

//station type
#define OPTIMIZATION_STATION_NAME                           @"STATION_NAME" //stationname_number : WIPAX_1
//#define OPTIMIZATION_STATION_ID                             @"STATION_ID" //station_id : WIPAX
//#define OPTIMIZATION_STATION_NUMBER                         @"STATION_NUMBER" //station_number : 1

//station status
#define OPTIMIZATION_STATION_STATUS                         @"STATUS"
#define OPTIMIZATION_STATION_STATUS_PASSED                  @"2"
#define OPTIMIZATION_STATION_STATUS_FAILED                  @"3"
#define OPTIMIZATION_STATION_STATUS_FRESTFAILED             @"4"
#define OPTIMIZATION_STATION_STATUS_FREE                    @"0"
#define OPTIMIZATION_STATION_STATUS_TESTING                 @"1"

//robot
#define OPTIMIZATION_ROBOT_STATUS                           @"STATUS"
#define OPTIMIZATION_ROBOT_STATUS_PASSED                    @"PASSED"
#define OPTIMIZATION_ROBOT_STATUS_FAILED                    @"FAILED"
#define OPTIMIZATION_ROBOT_STATUS_FREE                      @"FREE"

#define OPTIMIZATION_ACTION                                 @"ACTION"
#define OPTIMIZATION_ACTION_TAKEUP                          @"ACTION_TAKEUP"
#define OPTIMIZATION_ACTION_PUTDOWN                         @"ACTION_PUTDOWN"

#define OPTIMIZATION_ROBOT_GETMLBOUT                        @"GetMLBOut"
#define OPTIMIZATION_ROBOT_PUTNEWMLB                        @"PutNewMLB"


#define OPTIMIZATION_MOVETO_TARGET_DISTANCE                 @"DISTANCE"

//area for placing units
#define OPTIMIZATION_AREA_NEWCOMER                          @"NewComer_Area"
#define OPTIMIZATION_AREA_PASS                              @"Pass_Area"
#define OPTIMIZATION_AREA_FAIL                              @"Fail_Area"
#define OPTIMIZATION_AREA_TFIRST_FAIL                       @"Test_First_Fail_Area"
#define OPTIMIZATION_AREA_TSECOND_FAIL                      @"Test_Second_Fail_Area"
#define OPTIMIZATION_AREA_WFIRST_FAIL                       @"WiFi_First_Fail_Area"
#define OPTIMIZATION_AREA_WSECOND_FAIL                      @"WiFi_Second_Fail_Area"
#define OPTIMIZATION_AREA_BUFFER                            @"Buffer_Area"
#define OPTIMIZATION_AREA_UNTEST                            @"Untest_Area"
#define OPTIMIZATION_ROBOT_LOCATION                         @"Robot_Location"

//dimensional
//#define OPTIMIZATION_ONE_DIMENSIONAL                        @"oneD"
//#define OPTIMIZATION_TWO_DIMENSIONAL                        @"twoD"
//#define OPTIMIZATION_THREE_DIMENSIONAL                      @"threeD"
//robot setting
#define kRobotCoordinate                                    @"RobotCoordinate"
#define kBufferAreaCoordinate                               @"BufferAreaCoordinate"
#define kFailAreaCoordinate                                 @"FailAreaCoordinate"
#define kIBTxtFSpeed                                        @"IBTxtFSpeed"
#define kPassAreaCoordinate                                 @"PassAreaCoordinate"
#define kUntestAreaCoordinate                               @"UntestAreaCoordinate"
#define kRobotMoveSpeed                                     @"RobotMoveSpeed"
#define kEndTestTime                                        @"EndTime"
#define kStationCoordinate                                  @"StationCoordinate"
#define kStationSetting                                     @"StationSetting"
#define kFailCoordinate                                     @"FailCoordinate"
#define kFirstFailCoordinate                                @"FirstFailArea"
#define kSecondFailCoordinate                               @"SecondFailArea"
#define kPassCoordinate                                     @"PassArea"
#define kRobotPickerNumber                                  @"RobotPickerNumber"
#define kStationUnitNumber                                  @"SlotNumber"
#define kStationPassTime                                    @"TestPassTime"
#define kStationFailTime                                    @"TestFailTime"
#define kStationFailRate                                    @"FailRate"
#define kStationRetestRate                                  @"RetestRate"
#define kStationRetestRule                                  @"RetestRule"
#define kInputUnitNumber                                    @"InputUnitNumber"

//log path
#define RobotRunningLog                                     @"/vault/Robot-Simul/SimulateLog.txt"
#define UnitRunningCountLog                                 @"/vault/Robot-Simul/StationCycleCount.csv"
#define StationRunningDetailLog                             @"/vault/Robot-Simul/StationUseageLog.csv"
#define InputStatusLog                                      @"/vault/Robot-Simul/InputStatus.csv"
#define kTestConfigurationLog                               @"/vault/Robot-Simul/TestConfiguration.csv"

#endif
