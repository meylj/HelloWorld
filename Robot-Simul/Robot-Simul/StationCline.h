//
//  StationCline.h
//  StationCline
//
//  Created by Lucky_Jin on 13-3-22.
//  Copyright (c) 2013年 Lucky_Jin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogManager.h"

//NSString * const SCUpdateTestStatus; //Leehua

typedef struct Station_Position
{
	CGFloat	X;
	CGFloat	Y;
	CGFloat	Z;
}Station_Position;
// the enum of station mode
typedef enum
{
    StationTestMode_Audit = 0,
    StationTestMode_Normal//Leehua
}TestMode;
// the enum of station status

typedef enum
{
    StationTestRule_AAA = 0,
	StationTestRule_AAB = 1,
	StationTestRule_ABC = 2
}RetestRule;//Leehua

typedef enum
{
	Station_Empty		= 0,
	Station_Running		,//Leehua , I think they are the same
	Station_Pass		,
	Station_Fail			
}Station_Status;

@interface StationCline : NSObject
{
	NSString			*m_strStationName;		///>the name of this station
	Station_Position	m_StationPosition;		///>the position of this station(X,Y,Z)
	Station_Status		m_stationStatus;		///>the status of this station(empty,undertest,pass)
	NSString            *m_strCycleTime_Fail;		///>the cycle time when test failed
	NSString			*m_strCycleTime_Pass;		///>the cycle time when test passed
	float				m_fStationFailRate;		///>the fail rate of the station
    float               m_fStationRetestRate;   ///>the retest rate of the station, Leehua 
	TestMode			m_stationTestMode;		///>Audit or Normal Leehua
	int					m_iSingleTestCount;		///>the count of the DUT have been tested
	int                 m_iTotalPassCount;
	int                 m_iTatalFailCount;
    int                 m_iSlotNum;
    int                 m_iInputCount;
//    BOOL    m_bHasMLB;
   
    NSNotificationCenter    *nc;
   
}

@property (readwrite,retain)	NSString *StationName;
@property (readwrite,assign)	Station_Position StationPosition;
@property (readwrite,assign)	Station_Status	StationStatus;
@property (readwrite,retain)	NSString	*CycleTime_Fail;
@property (readwrite,retain)	NSString	*CycleTime_Pass;
@property (readwrite,assign)	float	StationFailRate;
@property (readwrite,assign)	float	StationRetestRate; //Leehua
@property (readwrite,assign)	TestMode	StationTestMode;


@property(readonly)		int TotalPassCount;
@property(readonly)		int TotalFailCount;
@property (assign)      int SlotNumber;


-(void)Start:(NSNotification *)note;
-(void)StationTesting;
-(NSString *)GenerateFailResult:(int)iFailUnits;

@end
