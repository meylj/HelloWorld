//
//  Optimization.h
//  Optimization
//
//  Created by 漢青 陳 on 13-3-22.
//  Copyright 2013年 PEGATRON. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <stdio.h>
#import "normaldefine.h"
#import "StationCline.h"
#import "math.h"
typedef double MOVEMENT;

#if defined(__cplusplus)
#define OPTIMIZATION_EXTERN extern "C"
#else
#define OPTIMIZATION_EXTERN extern
#endif

#define PI 3.1415926535897932

struct Localtion{
    int X;
    int Y;
    int Z;
    NSString *szStationName;            //standbyarea & passarea & wapix_1.....
    NSString *szStationStatus;          //passed & failed & free & unused
};

@interface Optimization : NSObject
{
    //init para here
    NSMutableArray *M_aryFreeStation;
    NSMutableArray *M_aryPassedStation;
    NSMutableArray *M_aryFailedStation;
    NSMutableArray *M_aryFirstFailStation;
    NSMutableArray *M_aryUnusedStation;
    
    NSMutableDictionary *M_dicStationLocation;// memory station statu with key station_name
    NSDictionary *M_dicStandbyAreaLocation;
    NSDictionary *M_dicPassableAreaLocation;
    NSDictionary *M_dicFailureAreaLocation;
    //NSDictionary *M_dicFirstFailAreaLocation;
    NSDictionary *M_dicRobotaLocation;
    
    NSString *M_szDimensional;
    NSArray *m_aryMovementSteps;
    NSString *m_szRobotPosition;
    
    Station_Position RobotStation;
    
    UInt8 reply;
}


/*
 Description:
        set or update the Robot location,the xyz positin can be nill,this function return a unsigned int.
        must update the robot location before you get the optimization.
 Para:
     NSDictionary    *acpLocationStruct
         OBJECT:NSNumber *X_Position       KEY:OPTIMIZATION_POSITION_X
         OBJECT:NSNumber *Y_Position       KEY:OPTIMIZATION_POSITION_Y
         OBJECT:NSNumber *Z_Position       KEY:OPTIMIZATION_POSITION_Z
         OBJECT:NSString *szStationName    KEY:OPTIMIZATION_STATION_NAME
 */
- (UInt8)_setRobotCurrentLocation:(Station_Position)acpLocationStruct;

- (Station_Position)_getRobotCurrentLocation;

- (double)calculateDistanceByThreeDimensional:(NSDictionary *)acpMinuend with:(NSDictionary *)acpSubtrahend;

- (float)GetTheDistance:(Station_Position )strStartPoint toPoint:(Station_Position )strEndPoint;

- (void)GetShortestPath:(NSDictionary *)dicPosition Return_Value:(NSMutableDictionary *)dicReturn;
- (float)abs:(float)fValue;

@end




