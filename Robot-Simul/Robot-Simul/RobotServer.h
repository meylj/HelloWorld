//
//  RobotServer.h
//  Robot_Server
//
//  Created by Jeff_Ma on 13-3-20.
//  Copyright (c) 2013年 Jeff_Ma. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "normaldefine.h"

#import "Optimization.h"
#import "LogManager.h"



NSString *BNRSendToClientNoti;


@interface RobotServer : NSObject
{
    float                   m_fMoveSpeed;//move speed, Leehua
    int                     m_iPickerNum;// robot picker num
    int                     m_iSlotNum; // station slot num
    int                     m_iInputMLBNum;
    
    Station_Position        FailPosition;       //Fail area Position
    Station_Position        NewComerPosition;    //StandBy area Position
    Station_Position        CurrentPosition;     //robot current position
    
    NSMutableArray         *m_aryFirstFailPosition;
    NSMutableArray         *m_arySecondFailPosition;
    NSMutableArray         *m_aryPassPosition;

    
    NSMutableArray          *m_arrFinishStation;   //All finish Stations Locations
    NSMutableDictionary      *m_dicFirstFailStations;  //record the unit first fail informations
    NSMutableDictionary          *m_dicSecondFailStations;  // record the unit second fail informations
    NSMutableDictionary     *m_dicTestResult;   //record station test over results
    NSMutableDictionary     *m_dicBusyStation;  //record the testing stations at current
    NSMutableDictionary     *m_dicReturnValue;
    
    NSMutableDictionary     *m_dicFailMLBInfo;  //record the fail unit Info
    
    NSMutableArray          *m_aryAvailableStation; //record each station available station info
    NSMutableArray          *m_aryPassCount;   //record each station pass MLB count
    NSMutableArray          *m_aryFailCount;   // record each station fail MLB count
    NSMutableArray          *m_aryFirstFailCount; //record each station first fail Units count
    NSMutableArray          *m_arySecondFailCount; //record each station Second Fail Units count
    NSMutableArray          *m_aryFirstFail;   // record each station first fail MLB count
    NSMutableArray          *m_arySecondFail;  //record each station second fail MLB count
    NSMutableArray          *m_arySecondFailMLBInfo; //record each station second fail MLB info
   
    NSMutableArray          *m_aryFirstFailMLBInfo; //record each station first fail MLB info
    NSMutableArray          *m_aryInputMLBCount;  //record each station Input MLB count
    NSMutableArray          *m_aryPreviousPass;  // record each station previous station MLB PASS count
    NSMutableArray          *m_aryHasNewMLB; //record the robot got the new MLB on hand or not
    
    NSMutableArray          *m_aryRetestRule; //record each station retest rule
 
    NSNotificationCenter    *nc;                      //NotificationCenter
    
    int                     iCurrentAtHandCount;
    
    Optimization            *optimization;
    
    int               iFirstPass;
    int               iSecondPass;
    

    BOOL              bFirstFailMLB;
    BOOL              bSecondFailMLB;
    BOOL              bNext;
    BOOL              bPickAll;
    
    NSMutableArray  *m_aryStationName;
}

@property  (retain) NSMutableArray          *aryAvailableStations;
@property  (retain) NSMutableArray          *aryStationNames;
@property  (retain) NSMutableArray          *aryPassCount;
@property  (retain) NSMutableArray          *aryFailCount;
@property  (retain) NSMutableArray          *aryInputMLBCount;
@property  (retain) NSMutableArray          *aryFirstFailCount;
@property  (retain) NSMutableArray          *arySecondFailCount;
@property  (retain) NSMutableArray          *aryPassPositions;
@property  (retain) NSMutableArray          *aryFirstFailPositions;
@property  (retain) NSMutableArray          *arySecondFailPositions;
@property  (retain) NSMutableArray          *aryRetestRule;

@property  (assign) float                   MoveSpeed;//Leehua
@property  (assign) int                     PickerNumber;
@property  (assign) int                     SlotNumber;
@property  (assign) int                     InputUnitNumber;


- (id)initServer;

/*  Method: startRobotServer
 *  Descripton: Start Robot server
 *  Param:
 */
-(void)startRobotServer;

/*  Method: CalculateSpendToStation
 *  Descripton: Calculate Spend between robot and all monitor station locations
 *  Param:  arrStationLocations -> all monitor stations locations
 */
-(float)CalculateSpend:(float)fDistance;

//handle the msg from client side
-(void)HandleMsgFromClient:(NSNotification *)noti;

-(void)Running;

-(void)setRobotLocation:(NSString *)strLocation;

-(void)setFailAreaLocation:(NSString *)strLocation;

-(void)setUntestAreaLocation:(NSString *)strLocation;

- (BOOL)RetestABC:(NSDictionary *)dicStaitonInfo OfIndex:(int)iIndex;

- (BOOL)RetestAAB:(NSDictionary *)dicStaitonInfo ofIndex:(int)iIndex;

//-(void)setBufferAreaLocation:(NSString *)strLocation;
@end
