//
//  Optimization.m
//  Optimization
//
//  Created by 漢青 陳 on 13-3-22.
//  Copyright 2013年 PEGATRON. All rights reserved.
//

#import "Optimization.h"

@implementation Optimization

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        M_aryFreeStation = [[NSMutableArray alloc] init];
        M_aryPassedStation = [[NSMutableArray alloc] init];
        M_aryFailedStation = [[NSMutableArray alloc] init];
        M_aryFirstFailStation = [[NSMutableArray alloc] init];
        M_aryUnusedStation = [[NSMutableArray alloc] init];
        M_dicStationLocation = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc
{
    if (M_aryFreeStation) [M_aryFreeStation release];
    if (M_aryPassedStation) [M_aryPassedStation release];
    if (M_aryFailedStation) [M_aryFailedStation release];
    if (M_aryFirstFailStation) [M_aryFirstFailStation release];
    if (M_aryUnusedStation) [M_aryUnusedStation release];
    if (M_dicStationLocation) [M_dicStationLocation release];
    [super dealloc];
}


- (double)calculateDistanceByThreeDimensional:(NSDictionary *)acpMinuend with:(NSDictionary *)acpSubtrahend 
{
    if (![acpMinuend isKindOfClass:[NSDictionary class]] || ![acpSubtrahend isKindOfClass:[NSDictionary class]]) return 99999.99999;    
    double x_minuend = [[acpMinuend objectForKey:OPTIMIZATION_POSITION_X] doubleValue];
    double y_minuend = [[acpMinuend objectForKey:OPTIMIZATION_POSITION_Y] doubleValue];
    double z_minuend = [[acpMinuend objectForKey:OPTIMIZATION_POSITION_Z] doubleValue];
    double x_subtrahend = [[acpSubtrahend objectForKey:OPTIMIZATION_POSITION_X] doubleValue];
    double y_subtrahend = [[acpSubtrahend objectForKey:OPTIMIZATION_POSITION_Y] doubleValue];
    double z_subtrahend = [[acpSubtrahend objectForKey:OPTIMIZATION_POSITION_Z] doubleValue];
    
    return sqrt(pow((x_minuend-x_subtrahend),2) + pow((y_minuend-y_subtrahend),2) + pow((z_minuend-z_subtrahend),2));                                                             
}



- (float)CalculateARCLengeth:(Station_Position )strStartPoint EndPoint:(Station_Position )strEndPoint
{
    float fStartX = strStartPoint.X;
    float fStartY = strStartPoint.Y;
    
    float fEndX = strEndPoint.X;
    float fEndY = strEndPoint.Y;
    
    float fStartAngle;
    float fEndAngel;
    
    if (fStartX == 0)
    {
        fStartAngle = 0;
    }
    else
    {
        float fValue = [self abs:(fStartY/fStartX)];
        fStartAngle = atan(fValue);
    }
    if (fEndX == 0)
    {
        fEndAngel = 0;
    }
    else
        fEndAngel = atan( [self abs:(fEndY/fEndX)]);
    
    if (fStartX< 0)
    {
        fStartAngle = fStartAngle + PI/2;
    }
    if (fStartY< 0)
    {
        fStartAngle = fStartAngle + PI;
    }
    
    if (fEndX < 0)
    {
        fEndAngel = fEndAngel + PI/2;
    }
    if (fEndY < 0)
    {
        fEndAngel = fEndAngel + PI;
    }

    float fRadius = 0.0;
    if((pow(fStartX,2) + pow(fStartY,2)) > (pow(fEndX,2) + pow(fEndY,2)))
    {
        fRadius = sqrt(pow(fStartX,2) + pow(fStartY,2));
    }
    else
        fRadius = sqrtf(pow(fEndX,2) + pow(fEndY,2));

    return (fRadius * [self abs:(fEndAngel - fStartAngle)]);

}

- (float)GetTheDistance:(Station_Position )strStartPoint toPoint:(Station_Position )strEndPoint
{
    float fARCLen = [self CalculateARCLengeth:strStartPoint EndPoint:strEndPoint];
    float fDistance = [self abs:(strStartPoint.Z - strEndPoint.Z)];
    return (fARCLen + fDistance);
}

- (void)GetShortestPath:(NSDictionary *)dicPosition Return_Value:(NSMutableDictionary *)dicReturn
{
    float fDistance = 999999;
    NSString *strStationName = @"NA";
    for (NSString *strName in [dicPosition allKeys])
    {
        StationCline *objClient = [dicPosition objectForKey:strName];
       float fTemp = [self GetTheDistance:RobotStation toPoint:objClient.StationPosition];
        if (fTemp < fDistance)
        {
            fDistance = fTemp;
            strStationName = [NSString stringWithFormat:@"%@",strName];
        }
    }
    
    if ([strStationName isEqualToString:@"NA"])
    {
        NSLog(@"NA");
    }
    
    [dicReturn setValue:[NSNumber numberWithFloat:fDistance] forKey:@"Distance"];
    [dicReturn setValue:strStationName forKey:@"StationName"];
}

- (Station_Position)_getRobotCurrentLocation
{
    return RobotStation;
}

- (UInt8)_setRobotCurrentLocation:(Station_Position )stationPosition
{
//    NSLog(@"start set robot location! ");
    RobotStation.X = stationPosition.X;
    RobotStation.Y = stationPosition.Y;
    RobotStation.Z = stationPosition.Z;
    return FUNCTION_SUCCESS;
}

- (float)abs:(float)fValue
{
    if (fValue > 0)
    {
        return fValue;
    }
    else
        return (0-fValue);
}

@end



