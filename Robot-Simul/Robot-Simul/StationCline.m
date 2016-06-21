//
//  StationCline.m
//  StationCline
//
//  Created by Lucky_Jin on 13-3-22.
//  Copyright (c) 2013年 Lucky_Jin. All rights reserved.
//

#import "StationCline.h"
#import "normaldefine.h"

NSString * const BNRResultOfClientNotification = @"ResultOfClient";
extern NSString *BNRPostStartNotification;
NSString *const BNRPostUpdateStatusNotification = @"PostUpdateStatusNotification";

extern int G_SPEED;
@implementation StationCline

@synthesize StationName		= m_strStationName;
@synthesize StationPosition	= m_StationPosition;
@synthesize StationStatus	= m_stationStatus;
@synthesize CycleTime_Pass	= m_strCycleTime_Pass;
@synthesize CycleTime_Fail	= m_strCycleTime_Fail;
@synthesize StationFailRate	= m_fStationFailRate;
@synthesize StationRetestRate	= m_fStationRetestRate;//Leehua
@synthesize StationTestMode = m_stationTestMode;
//@synthesize StationRetestRule = m_stationRetestRule;//Leehua
//@synthesize StationTestCount = m_iSingleTestCount;
//@synthesize bHasMLB = m_bHasMLB;
@synthesize SlotNumber = m_iSlotNum;

@synthesize TotalPassCount = m_iTotalPassCount;
@synthesize TotalFailCount = m_iTatalFailCount;


- (id)init
{
    self = [super init];
    if (self)
	{
		m_StationPosition.X	= 1.23;
		m_StationPosition.Y	= 3.22;
		m_StationPosition.Z	= 4.55;
        m_stationStatus		= Station_Empty;
		m_strStationName	= [[NSString alloc] init];
		m_fStationFailRate	= 0.234;
		m_stationTestMode	= StationTestMode_Normal;//Leehua
        m_iSlotNum = 4;
        nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(Start:) name:BNRPostStartNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [m_strStationName release]; m_strStationName = nil;
    [nc removeObserver:self name:BNRPostStartNotification object:nil];
    [super dealloc];
}


-(void)Start:(NSNotification *)note
{
    NSDictionary *dicTemp = [note userInfo];
   // NSLog(@"Go To station %@, and current staiton is %@", [dicTemp objectForKey:@"StationName"], m_strStationName);
    if (dicTemp != nil && [[dicTemp objectForKey:@"StationName"] isEqualToString:m_strStationName])
    {
        if ([[dicTemp objectForKey:OPTIMIZATION_ROBOT_GETMLBOUT]boolValue])
        {
            //get the mlb out of fixture and set the station station to waiting
            [nc postNotificationName:BNRPostUpdateStatusNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0],OPTIMIZATION_STATION_STATUS,m_strStationName,@"StationName", nil]];
            [nc postNotificationName:@"UpdateRunningCount" object:self userInfo:nil];
            NSDictionary *dic = [NSDictionary dictionaryWithObject:m_strStationName forKey:@"stationName"];
            [nc postNotificationName:@"WriteCsv" object:self userInfo:dic];
            m_stationStatus = Station_Empty;
            return;
        }
        if ([[dicTemp objectForKey:OPTIMIZATION_ROBOT_PUTNEWMLB]boolValue])
        {
            [nc postNotificationName:BNRPostUpdateStatusNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:1],OPTIMIZATION_STATION_STATUS,m_strStationName,@"StationName",[dicTemp objectForKey:@"InputCount"],@"RunningNo", nil]];
            m_iInputCount = [[dicTemp objectForKey:@"InputCount"]intValue];
            [NSThread detachNewThreadSelector:@selector(StationTesting) toTarget:self withObject:nil];
        }
    }
}

- (void)StationTesting
{
    [nc postNotificationName:@"UpdateRunningCount" object:self userInfo:nil];
 	m_stationStatus = Station_Running;
	NSString *strDate = [[NSDate date] descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M:%S.%F" timeZone:nil locale:nil];
	[LogManager creatAndWriteUnitTestedCount:[NSString stringWithFormat:@"%@,%@,%d,%@\n",m_strStationName,@"Coordinate",1,strDate] withPath:UnitRunningCountLog];
	NSString *strResult = @"PASS:PASS:PASS:PASS";
	int iCostTime;
    if ([m_strCycleTime_Pass rangeOfString:@"~"].location != NSNotFound)
    {
        NSArray *aryTime = [m_strCycleTime_Pass componentsSeparatedByString:@"~"];
        int iRange =abs([[aryTime objectAtIndex:1]intValue] - [[aryTime objectAtIndex:0]intValue]);
        int iRandom = [self random:iRange];
        iCostTime = (iRandom + [[aryTime objectAtIndex:0]intValue]) * G_SPEED *1000;
    }
    else
        iCostTime = [m_strCycleTime_Pass intValue] * G_SPEED *1000;
    
    int iFailCostTime = 0;
    int iFailCount = 0;
    for (int i = 0; i < m_iInputCount; i++)
    {
        if ([self random:(1/m_fStationFailRate)] == 1)
        {
            iFailCount++;
        }
    }
    
    if ([m_strCycleTime_Fail rangeOfString:@"~"].location != NSNotFound)
    {
        NSArray *aryTemp = [m_strCycleTime_Fail componentsSeparatedByString:@"~"];
        int iRange =abs([[aryTemp objectAtIndex:1]intValue] - [[aryTemp objectAtIndex:0]intValue]);
        int iRandom = [self random:iRange];
        iFailCostTime = (iRandom + [[aryTemp objectAtIndex:0]intValue]) / G_SPEED *1000;
    }
    else
        iFailCostTime = [m_strCycleTime_Fail intValue]/G_SPEED *1000;
    
    if (iFailCount == m_iInputCount)
    {
        iCostTime = iFailCostTime;
        m_iTatalFailCount++;
        self.StationStatus = Station_Fail;
    }
    else if(iFailCount > 0)
    {
        iCostTime = iCostTime>iFailCostTime?iCostTime:iFailCostTime;
        m_iTatalFailCount++;
        self.StationStatus = Station_Fail;
    }
    

//    if ([self random:1/m_fStationFailRate]== 1)
//    {
//        iFailCount = [self random:m_iInputCount];
//        if (iFailCount == 0)
//        {
//            iFailCount = 1;
//        }
//        if ([m_strCycleTime_Fail rangeOfString:@"~"].location != NSNotFound)
//        {
//            NSArray *aryTemp = [m_strCycleTime_Fail componentsSeparatedByString:@"~"];
//            int iRange =abs([[aryTemp objectAtIndex:1]intValue] - [[aryTemp objectAtIndex:0]intValue]);
//            iFailCostTime = ([self random:iRange] + [[aryTemp objectAtIndex:0]intValue]) / G_SPEED;
//        }
//        else
//            iFailCostTime = [m_strCycleTime_Fail intValue]/G_SPEED;
//        if (iFailCount == m_iInputCount)
//        {
//            iCostTime = iFailCostTime;
//            
//        }
//        else
//        {
//            iCostTime = iCostTime>iFailCostTime?iCostTime:iFailCostTime;
//        }
//        self.StationStatus = Station_Fail;
//        m_iTatalFailCount = +1;
//        NSLog(@"Test Failed");
//    }
    
    strResult = [self GenerateFailResult:iFailCount];
    NSDictionary *dic = [NSDictionary dictionaryWithObject:m_strStationName forKey:@"stationName"];
    [nc postNotificationName:@"WriteCsv" object:self userInfo:dic];

    NSString *strInfo = [NSString stringWithFormat:@"%@ start test and MLB: %d ",m_strStationName,m_iInputCount];
    [LogManager creatAndWriteRobotLog:strInfo];
    if (m_iInputCount == 0)
    {
        strResult = @"NA";
        for (int i = 0; i < m_iSlotNum; i++)
        {
            strResult = [NSString stringWithFormat:@"%@:NA",strResult];
        }
        iCostTime = 0;
    }
    usleep(iCostTime);
    
	 NSLog(@"station: %@ test result is: %@",m_strStationName,strResult);
	[nc postNotificationName:BNRResultOfClientNotification
					  object:self
					userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@",strResult],@"Result",[NSString stringWithFormat:@"%@", m_strStationName],@"StationName",nil]];
    if (iFailCount == 0)
    {
        [nc postNotificationName:BNRPostUpdateStatusNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:2],OPTIMIZATION_STATION_STATUS,m_strStationName,@"StationName",[NSString stringWithFormat:@"%@",strResult],@"Result", nil]];
    }
    else
    {
        [nc postNotificationName:BNRPostUpdateStatusNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:3],OPTIMIZATION_STATION_STATUS,[NSString stringWithFormat:@"%@",m_strStationName],@"StationName",[NSString stringWithFormat:@"%@",strResult],@"Result",  nil]];
    }
    
    m_stationStatus = Station_Pass;
}
// get random
- (int)random:(int)dLength
{
    if (dLength == 0)
    {
        return (int)random();
    }
    else
        return (int)(random()%dLength);
}

//  the fail result.
-(NSString *)GenerateFailResult:(int)iFailUnits
{
	NSString *strResult = @"";
   
    switch (iFailUnits)
    {
        case 0:
            strResult = @"PASS";
            for (int i = 1; i < m_iInputCount; i++)
            {
                strResult = [NSString stringWithFormat:@"%@:%@",strResult,@"PASS"];
            }
            for (int i = 0; i < m_iSlotNum - m_iInputCount; i++)
            {
                strResult = [NSString stringWithFormat:@"%@:%@",strResult,@"NA"];
            }
            break;
        case 1:
            strResult = @"FAIL";
            for (int i = 1; i < iFailUnits; i++)
            {
                strResult = [NSString stringWithFormat:@"%@:%@",strResult,@"FAIL"];
            }
            for (int i = 0; i < (m_iInputCount-iFailUnits); i++)
            {
                strResult = [NSString stringWithFormat:@"%@:%@",strResult,@"PASS"];
            }
            for (int i = 0; i < m_iSlotNum -m_iInputCount; i++)
            {
                strResult = [NSString stringWithFormat:@"%@:%@",strResult,@"NA"];
            }
            break;
        case 2:
            strResult = @"FAIL";
            for (int i = 1; i < iFailUnits; i++)
            {
                strResult = [NSString stringWithFormat:@"%@:%@",strResult,@"FAIL"];
            }
            for (int i = 0; i < (m_iInputCount-iFailUnits); i++)
            {
                strResult = [NSString stringWithFormat:@"%@:%@",strResult,@"PASS"];
            }
            for (int i = 0; i < m_iSlotNum - m_iInputCount; i++)
            {
                strResult = [NSString stringWithFormat:@"%@:%@",strResult,@"NA"];
            }
            break;
        case 3:
            strResult = @"FAIL";
            for (int i = 1; i < iFailUnits; i++)
            {
                strResult = [NSString stringWithFormat:@"%@:%@",strResult,@"FAIL"];
            }
            for (int i = 0; i < (m_iInputCount-iFailUnits); i++)
            {
                strResult = [NSString stringWithFormat:@"%@:%@",strResult,@"PASS"];
            }
            for (int i = 0; i < m_iSlotNum - m_iInputCount; i++)
            {
                strResult = [NSString stringWithFormat:@"%@:%@",strResult,@"NA"];
            }
            break;
        case 4:
            strResult = [NSString stringWithFormat:@"%@",@"FAIL:FAIL:FAIL:FAIL"];
            break;
            
        default:
            break;
    }
    return strResult;
}


@end
