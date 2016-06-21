//
//  RobotServer.m
//  Robot_Server
//
//  Created by Jeff_Ma on 13-3-20.
//  Copyright (c) 2013年 Jeff_Ma. All rights reserved.
//

#import "RobotServer.h"

NSString *const BNRPostNoteName = @"PostNoteName";
NSString *const BNRPostSelfNote = @"SelfNote";
NSString *const BNRPostStartNotification = @"PostStartNotification";
NSString *const BNRPostGoToStationNotification = @"PostGoToStationNotification" ;
extern NSString *BNRResultOfClientNotification;
static NSString *g_szSyncHandleMsg = @"";
@implementation RobotServer

@synthesize MoveSpeed = m_fMoveSpeed;//Leehua
@synthesize InputUnitNumber = m_iInputMLBNum;
@synthesize aryAvailableStations = m_aryAvailableStation;
@synthesize aryStationNames = m_aryStationName;
@synthesize aryPassCount = m_aryPassCount;
@synthesize aryInputMLBCount = m_aryInputMLBCount;
@synthesize aryFailCount = m_aryFailCount;
@synthesize aryFirstFailCount = m_aryFirstFail;
@synthesize arySecondFailCount = m_arySecondFail;
@synthesize aryPassPositions = m_aryPassPosition;
@synthesize aryFirstFailPositions = m_aryFirstFailPosition;
@synthesize arySecondFailPositions = m_arySecondFailPosition;
@synthesize PickerNumber = m_iPickerNum;
@synthesize SlotNumber = m_iSlotNum;
@synthesize aryRetestRule = m_aryRetestRule;

extern int G_SPEED;

-(id)initServer
{
    self = [super init];
    if (self)
    {
        m_arrFinishStation = [[NSMutableArray alloc] init];
        m_dicFirstFailStations = [[NSMutableDictionary alloc]init];
        m_dicSecondFailStations = [[NSMutableDictionary alloc]init];
        m_aryFailCount  = [[NSMutableArray alloc]init];
        m_aryFirstFailCount = [[NSMutableArray alloc]init];
        m_arySecondFailCount = [[NSMutableArray alloc]init];
        m_dicBusyStation = [[NSMutableDictionary alloc]init];
        m_dicReturnValue = [[NSMutableDictionary alloc]init];
        m_dicTestResult = [[NSMutableDictionary alloc]init];
        m_dicFailMLBInfo = [[NSMutableDictionary alloc]init];
        m_aryAvailableStation = [[NSMutableArray alloc]init];
        m_aryStationName  = [[NSMutableArray alloc]init];
        m_aryPassCount = [[NSMutableArray alloc]init];
        m_aryFirstFail = [[NSMutableArray alloc]init];
        m_arySecondFail = [[NSMutableArray alloc]init];
        m_aryFirstFailMLBInfo = [[NSMutableArray alloc]init];
        m_arySecondFailMLBInfo = [[NSMutableArray alloc]init];
        m_aryInputMLBCount = [[NSMutableArray alloc]init];
        m_aryPreviousPass = [[NSMutableArray alloc]init];
        m_aryHasNewMLB = [[NSMutableArray alloc]init];
        m_aryFirstFailPosition = [[NSMutableArray alloc]init];
        m_arySecondFailPosition = [[NSMutableArray alloc]init];
        m_aryPassPosition     = [[NSMutableArray alloc]init];
        m_aryRetestRule  = [[NSMutableArray alloc]init];
        m_iPickerNum = 0;
        m_iSlotNum = 1;

        iCurrentAtHandCount = 0;   // robot current has under test MLB count
        bFirstFailMLB = NO;  //current on robot wait for test MLB is first fail mlb or not
        bSecondFailMLB = NO; // current on robot wait for test MLB is second fail MLB or not
//        bNext = NO;
        bPickAll = NO;  //need to wait for 4 to test or not.
        nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(HandleMsgFromClient:) name:BNRResultOfClientNotification object:nil];
        [nc addObserver:self selector:@selector(UpdateRetestRule:) name:@"UpdateRetestRule" object:nil];
        optimization = [[Optimization alloc] init];
        [optimization _setRobotCurrentLocation:CurrentPosition];
    }
    return self;
}

-(void)dealloc
{
    [nc removeObserver:self name:BNRResultOfClientNotification object:nil];
    [m_dicBusyStation release];
    [m_arrFinishStation release];
    [m_dicFirstFailStations release];
    [m_dicSecondFailStations release];
    [m_dicTestResult release];
    [m_dicReturnValue release];
    [m_aryAvailableStation release];
    [m_aryStationName release];
    [m_aryPassCount release];
    [m_aryFirstFail release];
    [m_arySecondFail release];
    [m_aryFailCount release];
    [m_aryRetestRule release];
    [m_aryFirstFailCount release];
    [m_arySecondFailCount release];
    [m_arySecondFailMLBInfo release];
    [m_aryFirstFailMLBInfo release];
    [m_aryInputMLBCount release];
    [m_aryPreviousPass release];
    [m_aryHasNewMLB release];
    [m_aryFirstFailPosition release];
    [m_arySecondFailPosition release];
    [m_aryPassPosition release];
    [m_dicFailMLBInfo release];
    [optimization release];
    [super dealloc];
}

// update the retest rule of stations
-(void)UpdateRetestRule:(NSNotification *)note
{
    @synchronized(m_aryRetestRule)
    {
        NSDictionary *dicInfo = [note userInfo];
        NSString *strName = [dicInfo objectForKey:@"StationName"];
        NSUInteger index = [m_aryStationName indexOfObject:strName];
        [m_aryRetestRule replaceObjectAtIndex:index withObject:[dicInfo objectForKey:@"RetestRule"]];
    }
}


//Start simulate tool
-(void)Running
{
    @synchronized(self)
    {
        int iPickNumber = 0;
        if (bPickAll)
        {
            iPickNumber = m_iSlotNum -1;
        }
        
        while (1)
        {
            BOOL bRet = NO;
            for (int i = 0; i < [m_aryStationName count]; i++)
            {
                NSInteger j = 0;
                if(i == [m_aryStationName count]-1)
                    j = 0;
                else
                    j = i+1;
                if ([m_aryStationName count] == 1)
                {
                    if ([[m_aryAvailableStation objectAtIndex:i]count] > 0 && ([[m_aryPreviousPass objectAtIndex:i]intValue]> 0|| [[m_aryFirstFailCount objectAtIndex:i]intValue] > m_iSlotNum-1 || [[m_arySecondFailCount objectAtIndex:i]intValue]> m_iSlotNum -1))
                    {
                        [self DoTest:i];
                        bRet = YES;
                    }
                }
                else
                {
                    if (![[m_aryHasNewMLB objectAtIndex:i]boolValue] && ![[m_aryHasNewMLB objectAtIndex:j]boolValue] && [m_aryHasNewMLB containsObject:[NSNumber numberWithBool:YES]])
                    {
                        continue;
                    }
                    if (([[m_aryFirstFailCount objectAtIndex:j]intValue]> m_iSlotNum-1|| [[m_arySecondFailCount objectAtIndex:j]intValue]>m_iSlotNum-1) && ![[m_aryHasNewMLB objectAtIndex:i ]boolValue] && [[m_aryAvailableStation objectAtIndex:j]count]>0 /*&& !bNext*/)
                    {
                        [self DoTest:(int)j];
                        bRet = YES;
                    }
                   if ([[m_aryAvailableStation objectAtIndex:i]count] > 0 && [[m_aryPreviousPass objectAtIndex:i]intValue]> iPickNumber && ![[m_aryHasNewMLB objectAtIndex:j]boolValue])
                   {
                       [self DoTest:i];
                       bRet = YES;
                   }
                   
                }
            }
            if (!bRet && [m_arrFinishStation count] > 0)
            {
                [self DoTest:-1];
            }
            if (!bRet && [m_dicBusyStation count] == 0)
            {
                NSLog(@"End test");
                [NSApp terminate:self];
            }
        }
    }
}


// handle the fail unit on the station: put it on the first fail area? second fail area? fail area? Judge where the fail unit should place.
-(Station_Position)HandleFailUnitsOfStation:(NSString *)strName ReturnValue:(NSMutableDictionary *)dicReturn ofIndex:(int)iIndex
{
    NSArray *aryResult = [m_dicTestResult objectForKey:strName];
     //if the first fail MLB retest Fail again, then put the fail MLB on second fail area
    if ([[m_dicFirstFailStations allKeys]containsObject:strName] && [[m_dicFirstFailStations objectForKey:strName]boolValue])
    {
        
        [m_dicFirstFailStations removeObjectForKey:strName];
        int iSecondFail = [[m_arySecondFailCount objectAtIndex:iIndex]intValue];
        NSArray *aryInfo = [m_dicFailMLBInfo objectForKey:strName];
        for (int k = 0; k < m_iSlotNum; k++)
        {
            if ([[aryResult objectAtIndex:k] isEqualTo:@"FAIL"])
            {
                iSecondFail++;
                if ([m_arySecondFailMLBInfo count] < iIndex+1)
                {
                    NSMutableArray *aryFail = [[NSMutableArray alloc]init];
                    [aryFail addObject:[NSString stringWithFormat:@"%@,%@",[aryInfo objectAtIndex:k],strName]];
                    for (NSInteger j = [m_arySecondFailMLBInfo count]; j< iIndex; j ++)
                    {
                        NSMutableArray *aryTemp = [[NSMutableArray alloc]init];
                        [m_arySecondFailMLBInfo addObject:aryTemp];
                    }
                    
                    [m_arySecondFailMLBInfo addObject:aryFail];
                    
                }
                else
                {
                    NSMutableArray *aryFail = [m_arySecondFailMLBInfo objectAtIndex:iIndex];
                    [aryFail addObject:[NSString stringWithFormat:@"%@,%@",[aryInfo objectAtIndex:k],strName]];
                    [m_arySecondFailMLBInfo replaceObjectAtIndex:iIndex withObject:aryFail];
                }
            }
        }
        NSLog(@"1.second fail MLB info: %@",m_arySecondFailMLBInfo);
        NSString *strLog = [NSString stringWithFormat:@"station %@ second fail number : %d",[m_aryStationName objectAtIndex:iIndex],iSecondFail];
        [LogManager creatAndWriteRobotLog:strLog];
        [m_arySecondFailCount replaceObjectAtIndex:iIndex withObject:[NSNumber numberWithInt:iSecondFail]];
        [dicReturn setObject:[NSString stringWithFormat:@"%@_Second_Fail_Area",[m_aryStationName objectAtIndex:iIndex]] forKey:@"GoToStation"];
        NSString *strSecondFail = [m_arySecondFailPosition objectAtIndex:iIndex];
        NSArray *aryTemp = [strSecondFail componentsSeparatedByString:@","];
        float x = [[aryTemp objectAtIndex:0]floatValue];
        float y = [[aryTemp objectAtIndex:1]floatValue];
        float z = [[aryTemp objectAtIndex:2]floatValue];
        Station_Position SecondFailPosition = {x,y,z};
        [m_dicFailMLBInfo removeObjectForKey:strName];
        return SecondFailPosition;
    }
    
    //if the seoncd fail MLB retest still fail, then put the fail MLB on fail area
    if ([[m_dicSecondFailStations allKeys] containsObject:strName])
    {       
        [dicReturn setObject:OPTIMIZATION_AREA_FAIL forKey:@"GoToStation"];
        [m_dicSecondFailStations removeObjectForKey:strName];
        [m_dicFailMLBInfo removeObjectForKey:strName];
        return FailPosition;
    }
    
    //if the mlb is first fail, then put the mlb on first fail area
    if (!([[m_dicFirstFailStations allKeys] containsObject:strName] ||[[m_dicFirstFailStations objectForKey:strName]boolValue])&& !([[m_dicSecondFailStations allKeys] containsObject:strName]|| [[m_dicSecondFailStations objectForKey:strName]boolValue]))
    {
       
        int iFirstFail = [[m_aryFirstFailCount objectAtIndex:iIndex]intValue];
    
        for (int k = 0; k < m_iSlotNum; k++)
        {
            if ([[aryResult objectAtIndex:k] isEqualTo:@"FAIL"])
            {
                iFirstFail++;
                if ([m_aryFirstFailMLBInfo count] < iIndex+1)
                {
                    NSMutableArray *aryFailInfo = [[NSMutableArray alloc]init];
                    [aryFailInfo addObject:strName];
                    for (NSInteger j = [m_aryFirstFailMLBInfo count]; j< iIndex; j ++)
                    {
                        NSMutableArray *aryTemp = [[NSMutableArray alloc]init];
                        [m_aryFirstFailMLBInfo addObject:aryTemp];
                    }
                    [m_aryFirstFailMLBInfo addObject:aryFailInfo];
                }
                else
                {
                    NSMutableArray *aryFirstFail = [m_aryFirstFailMLBInfo objectAtIndex:iIndex];
                    [aryFirstFail addObject:strName];
                    
                    [m_aryFirstFailMLBInfo replaceObjectAtIndex:iIndex withObject:aryFirstFail];
                }
            }
        }
        NSString *strLog = [NSString stringWithFormat:@"station %@ first fail number : %d",[m_aryStationName objectAtIndex:iIndex],iFirstFail];
        [LogManager creatAndWriteRobotLog:strLog];
        [m_aryFirstFailCount replaceObjectAtIndex:iIndex withObject:[NSNumber numberWithInt:iFirstFail]];
        
        [dicReturn setObject:[NSString stringWithFormat:@"%@_First_Fail_Area",[m_aryStationName objectAtIndex:iIndex]] forKey:@"GoToStation"];
        NSString *strFirstFail = [m_arySecondFailPosition objectAtIndex:iIndex];
        NSArray *aryTemp = [strFirstFail componentsSeparatedByString:@","];
        float x = [[aryTemp objectAtIndex:0]floatValue];
        float y = [[aryTemp objectAtIndex:1]floatValue];
        float z = [[aryTemp objectAtIndex:2]floatValue];
        Station_Position FirstFailPosition = {x,y,z};
        [m_dicFailMLBInfo removeObjectForKey:strName];
        return FirstFailPosition;
    }
    
    return FailPosition;
}

// the main test
- (void)DoTest:(int)i
{
//    bNext= NO;
    int iTemp = 0;
    if (bPickAll)
    {
        iTemp = m_iSlotNum -1;
    }
    NSMutableDictionary *dicTestStation;
    if (i == -1)
    {
        //all the units tested complete, just need handle the station which is under testing
        NSMutableDictionary *dicStation = [[NSMutableDictionary alloc]init];
        NSPredicate *thePredicate = [NSPredicate predicateWithFormat:@"SELF IN %@",m_arrFinishStation];
        
        for (int j = 0; j < [m_aryStationName count]; j++)
        {
           
            NSMutableDictionary *dicTemp = [m_aryAvailableStation objectAtIndex:j];
            NSArray *aryAll = [dicTemp allKeys];
            NSArray *aryFinish = [aryAll filteredArrayUsingPredicate:thePredicate];
            for (NSString *strKey in aryFinish)
            {
                [dicStation setObject:[dicTemp objectForKey:strKey] forKey:strKey];
            }
        }
        [optimization GetShortestPath:dicStation Return_Value:m_dicReturnValue];
        [dicStation release];
        NSString *strStationName = [m_dicReturnValue objectForKey:@"StationName"];
        for(int j = 0; j < [m_aryStationName count]; j++)
        {
            NSMutableDictionary *dicTemp = [m_aryAvailableStation objectAtIndex:j];
            NSArray *aryAll = [dicTemp allKeys];
            if ([aryAll containsObject:strStationName])
            {
                dicTestStation = [m_aryAvailableStation objectAtIndex:j];
                i = j;
                break;
            }
        }
    }
    else
    {
        dicTestStation = [m_aryAvailableStation objectAtIndex:i];
        
        if ([[m_aryFirstFailCount objectAtIndex:i]intValue]> m_iSlotNum -1 || [[m_arySecondFailCount objectAtIndex:i]intValue] > m_iSlotNum -1 || [[m_aryPreviousPass objectAtIndex:i]intValue] > iTemp)
        {
            if (m_iPickerNum/m_iSlotNum > 1)
            {
                [optimization GetShortestPath:dicTestStation Return_Value:m_dicReturnValue];
            }
            else if([[m_aryHasNewMLB objectAtIndex:i]boolValue])
            {
                //if robot has unit in hand, just find the lastest station which is empty
                NSMutableDictionary *dicStation = [[NSMutableDictionary alloc]init];
                NSPredicate *thePredicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",m_arrFinishStation];
                NSArray *aryAll = [dicTestStation allKeys];
                NSArray *aryFinish = [aryAll filteredArrayUsingPredicate:thePredicate];
                for (NSString *strKey in aryFinish)
                {
                    [dicStation setObject:[dicTestStation objectForKey:strKey] forKey:strKey];
                }
                [optimization GetShortestPath:dicStation Return_Value:m_dicReturnValue];
                [dicStation release];
            }
            else if([m_arrFinishStation count] >0)
            {
                //if robot don't have anything in hand, go to the lastest which is just finished test to get the MLB out
                NSMutableDictionary *dicStation = [[NSMutableDictionary alloc]init];
                NSPredicate *thePredicate = [NSPredicate predicateWithFormat:@"SELF IN %@",m_arrFinishStation];
                NSArray *aryAll = [dicTestStation allKeys];
                NSArray *aryFinish = [aryAll filteredArrayUsingPredicate:thePredicate];
                for (NSString *strKey in aryFinish)
                {
                    [dicStation setObject:[dicTestStation objectForKey:strKey] forKey:strKey];
                }
                [optimization GetShortestPath:dicStation Return_Value:m_dicReturnValue];
                [dicStation release];
            }
            else
            {
                [optimization GetShortestPath:dicTestStation Return_Value:m_dicReturnValue];
            }
        
        }
        else 
        {
            NSMutableDictionary *dicStation = [[NSMutableDictionary alloc]init];
            NSPredicate *thePredicate = [NSPredicate predicateWithFormat:@"SELF IN %@",m_arrFinishStation];
            NSArray *aryAll = [dicTestStation allKeys];
            NSArray *aryFinish = [aryAll filteredArrayUsingPredicate:thePredicate];
            for (NSString *strKey in aryFinish)
            {
                [dicStation setObject:[dicTestStation objectForKey:strKey] forKey:strKey];
            }
            [optimization GetShortestPath:dicStation Return_Value:m_dicReturnValue];
            [dicStation release];
        }
    }
//    NSLog(@"1: new MLB %@",m_aryHasNewMLB);
    NSString *strStationName = [m_dicReturnValue objectForKey:@"StationName"];
    float fDistance = 0;
    float fSleepTime = 0;
    if ([strStationName isEqualToString:@"NA"])
    {
        [LogManager creatAndWriteRobotLog:@"Error, can't get the lastest station"];
        return;
    }
    StationCline *currentStation = [dicTestStation objectForKey:strStationName];
    NSArray *aryTemp = [NSArray arrayWithArray:m_arrFinishStation];
    // if the station is just finished test
    if ([aryTemp containsObject:strStationName])
    {
        
        NSArray *aryResult = [m_dicTestResult objectForKey:strStationName];
         [LogManager creatAndWriteRobotLog:[NSString stringWithFormat:@"Go To Station : %@ ",strStationName]];
        // if all the unit result is first fail, and the station retest Rule is AAB/AAA, no need to get unit out, just let the station start test again for retest.
        if ([[m_aryRetestRule objectAtIndex:i]isNotEqualTo:@"ABC"]&&[aryResult containsObject:@"FAIL"]&&!([[m_dicSecondFailStations allKeys] containsObject:strStationName] ||[[m_dicSecondFailStations objectForKey:strStationName]boolValue]))
        {
            int k = 0;
            for (NSString *strTemp in aryResult)
            {
                if ([strTemp isEqualToString:@"FAIL"])
                {
                    k++;
                }
            }
           if(k == m_iSlotNum)
           {
                if (([[m_dicFirstFailStations allKeys]containsObject:strStationName] && [[m_dicFirstFailStations objectForKey:strStationName]boolValue])&&!([[m_dicSecondFailStations allKeys] containsObject:strStationName]||[[m_dicSecondFailStations objectForKey:strStationName]boolValue] )&& [[m_aryRetestRule objectAtIndex:i]isEqualToString:@"AAA"])
                {
                    NSMutableDictionary *dicReturn = [[NSMutableDictionary alloc]init];
                    [self HandleFailUnitsOfStation:strStationName ReturnValue:dicReturn ofIndex:i];
                    [dicReturn release];
//                    NSLog(@"No need to get the mlb out of fixture, just test again for third test");
                    [LogManager creatAndWriteRobotLog:@"No need to get the mlb out of fixture, just test again for third test"];
                    NSDictionary *dicTemp = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],OPTIMIZATION_ROBOT_PUTNEWMLB,[NSString stringWithFormat:@"%@",strStationName],@"StationName",[NSNumber numberWithInt:m_iSlotNum],@"InputCount", nil];
                    [nc postNotificationName:BNRPostStartNotification object:self userInfo:dicTemp];
                    [m_arrFinishStation removeObject:strStationName];
                    [m_dicBusyStation setObject:currentStation forKey:strStationName];
                    NSMutableDictionary *dicAvailable = [m_aryAvailableStation objectAtIndex:i];
                    [dicAvailable removeObjectForKey:strStationName];
                    [m_aryAvailableStation replaceObjectAtIndex:i withObject:dicAvailable];
                    NSMutableArray *aryFail = [m_arySecondFailMLBInfo objectAtIndex:i];
                    int iFailCount = [[m_arySecondFailCount objectAtIndex:i]intValue];
                    int iSecondFail = [[m_arySecondFail objectAtIndex:i]intValue];
                    for (int j =0 ;j< m_iSlotNum ; j++)
                    {
                        [aryFail removeLastObject];
                        iFailCount--;
                        iSecondFail--;
                    }
                    [m_arySecondFailMLBInfo replaceObjectAtIndex:i withObject:aryFail];
                    [m_arySecondFailCount replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:iFailCount]];
                    [m_arySecondFail replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:iSecondFail]];
                    
                    return;

                }
                else 
                {
                    NSMutableDictionary *dicReturn = [[NSMutableDictionary alloc]init];
                    [self HandleFailUnitsOfStation:strStationName ReturnValue:dicReturn ofIndex:i];
                    [dicReturn release];
//                    NSLog(@"No need to get the mlb out of fixture, just test again for second test");
                    [LogManager creatAndWriteRobotLog:@"No need to get the mlb out of fixture, just test again for second test"];
                    
                    NSDictionary *dicTemp = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],OPTIMIZATION_ROBOT_PUTNEWMLB,[NSString stringWithFormat:@"%@",strStationName],@"StationName",[NSNumber numberWithInt:m_iSlotNum],@"InputCount", nil];
                    [nc postNotificationName:BNRPostStartNotification object:self userInfo:dicTemp];
                    [m_arrFinishStation removeObject:strStationName];
                    [m_dicBusyStation setObject:currentStation forKey:strStationName];
                    NSMutableDictionary *dicAvailable = [m_aryAvailableStation objectAtIndex:i];
                    [dicAvailable removeObjectForKey:strStationName];
                    [m_aryAvailableStation replaceObjectAtIndex:i withObject:dicAvailable];
                    NSMutableArray *aryFail = [m_aryFirstFailMLBInfo objectAtIndex:i];
                    int iFailCount = [[m_aryFirstFailCount objectAtIndex:i]intValue];
                    int iFirstFail = [[m_aryFirstFail objectAtIndex:i]intValue];
                    for (int j =0 ;j< m_iSlotNum ; j++)
                    {
                        [aryFail removeLastObject];
                        iFailCount--;
                        iFirstFail--;
                    }
                    [m_aryFirstFailMLBInfo replaceObjectAtIndex:i withObject:aryFail];
                    [m_aryFirstFailCount replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:iFailCount]];
                    [m_aryFirstFail replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:iFirstFail]];
                    return;
                }
           }
        }
        
        fDistance = [[m_dicReturnValue objectForKey:@"Distance"]floatValue];
        fSleepTime = [self CalculateSpend:fDistance];
        usleep(fSleepTime);
        //get the unit out of the fixture
        [self HandleTestOverStation:strStationName ofClient:currentStation];
        //if robot has new unit on hand, put the unit on fixture to test.
        if ([[m_aryHasNewMLB objectAtIndex:i]boolValue])
        {
            [m_aryHasNewMLB replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:NO]];
          //  NSLog(@"7 not have new MLB:%@",m_aryHasNewMLB);
            NSDictionary *dicTemp = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],OPTIMIZATION_ROBOT_PUTNEWMLB,[NSString stringWithFormat:@"%@",strStationName],@"StationName",[NSNumber numberWithInt:iCurrentAtHandCount],@"InputCount", nil];
            [self PutMLBOnStation:strStationName Client:currentStation forSleep:0 ofIndex:i];
            [nc postNotificationName:BNRPostStartNotification object:self userInfo:dicTemp];
            [m_dicBusyStation setObject:currentStation forKey:strStationName];
            [dicTestStation removeObjectForKey:strStationName];
            [m_aryAvailableStation replaceObjectAtIndex:i withObject:dicTestStation];
            [optimization _setRobotCurrentLocation:currentStation.StationPosition];
        }
        //hand the unit whiched just finised test
        [self HandleMLBTestOverofStation:strStationName ofClient:currentStation ofIndex:i];
        return;
    }
    else
    {
        //if the robot has new units on hand, just put the new unit on fixture to test
        if ([[m_aryHasNewMLB objectAtIndex:i]boolValue])
        {
            [m_aryHasNewMLB replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:NO]];
            fDistance = [[m_dicReturnValue objectForKey:@"Distance"]floatValue];
            fSleepTime = [self CalculateSpend:fDistance];
            [LogManager creatAndWriteRobotLog:[NSString stringWithFormat:@"Go To Station : %@",strStationName]];
            usleep(fSleepTime);
            NSDictionary *dicTemp = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],OPTIMIZATION_ROBOT_PUTNEWMLB,[NSString stringWithFormat:@"%@",strStationName],@"StationName",[NSNumber numberWithInt:iCurrentAtHandCount],@"InputCount", nil];
            [self PutMLBOnStation:strStationName Client:currentStation forSleep:0 ofIndex:i];
            [nc postNotificationName:BNRPostStartNotification object:self userInfo:dicTemp];
            [m_dicBusyStation setObject:currentStation forKey:strStationName];
            [dicTestStation removeObjectForKey:strStationName];
            [m_aryAvailableStation replaceObjectAtIndex:i withObject:dicTestStation];
            iCurrentAtHandCount = 0;
            return;
        }
        //go to the buffer area to get unit for test
        else if (i > 0 && [[m_aryPreviousPass objectAtIndex:i]intValue] > iTemp)
        {
            if ([m_aryHasNewMLB containsObject:[NSNumber numberWithBool:YES]])
            {
                return;
            }
            if ([[m_aryPreviousPass objectAtIndex:i]intValue] >0)
            {
                NSString *strPass = [m_aryPassPosition objectAtIndex:i-1];
                NSArray *aryPass = [strPass componentsSeparatedByString:@","];
                float x = [[aryPass objectAtIndex:0]floatValue];
                float y = [[aryPass objectAtIndex:1]floatValue];
                float z = [[aryPass objectAtIndex:2]floatValue];
                Station_Position PassPosition = {x,y,z};
                
                
                if ([[m_aryPreviousPass objectAtIndex:i]intValue] > m_iSlotNum-1)
                {
                    iCurrentAtHandCount = m_iSlotNum;
                }
                else if([[m_aryPreviousPass objectAtIndex:i]intValue] > iTemp)
                    iCurrentAtHandCount = [[m_aryPreviousPass objectAtIndex:i]intValue];
                
                [LogManager creatAndWriteRobotLog:[NSString stringWithFormat:@"Go to buffer area %d to get unit for test next station : %@",[[m_aryPreviousPass objectAtIndex:i]intValue],[m_aryStationName objectAtIndex:i]]];
                
                //get the mlb from buffer area
                fDistance = [optimization GetTheDistance: [optimization _getRobotCurrentLocation] toPoint:PassPosition];
                fSleepTime = [self CalculateSpend:fDistance];
                usleep(fSleepTime);
                [optimization _setRobotCurrentLocation:PassPosition];
                [m_aryHasNewMLB replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:YES]];
                return;
            }
        }

        BOOL bRet = NO;
        //for retest
        if ([[m_aryRetestRule objectAtIndex:i]isEqualToString:@"AAB"])
        {
            bRet = [self RetestAAB:dicTestStation ofIndex:i];
        }
        else if ([[m_aryRetestRule objectAtIndex:i]isEqualToString:@"ABC"])
        {
            bRet = [self RetestABC:dicTestStation OfIndex:i];
        }
        
       if (bRet)
        {
//                bNext = YES;
            return;
        }
        //go to the new input area get the unit for test
        else if(i == 0)
        {
            if ([m_aryHasNewMLB containsObject:[NSNumber numberWithBool:YES]])
            {
                return;
            }
            [LogManager creatAndWriteRobotLog:[NSString stringWithFormat:@"Go To New Input area to get MLB: %@",OPTIMIZATION_AREA_NEWCOMER]];
            fDistance = [optimization GetTheDistance:[optimization _getRobotCurrentLocation] toPoint:NewComerPosition];
            [optimization _setRobotCurrentLocation:NewComerPosition];
            fSleepTime = [self CalculateSpend:fDistance];
            usleep(fSleepTime);
            [m_aryHasNewMLB replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:YES]];
            iCurrentAtHandCount = m_iSlotNum;
        }
    }
    
}

// handle the Units test over the station. To put it in the buffer or go to next station for test
- (void)HandleMLBTestOverofStation:(NSString *)strStationName ofClient:(StationCline *)Client ofIndex:(int)iIndex
{
   
    NSMutableDictionary *dicReturn = [[NSMutableDictionary alloc]init];
    NSArray *aryResult = [m_dicTestResult objectForKey:strStationName];
    float fSleepTime = 0;
    float fDistance = 0;
    NSString *strPassPosition = [m_aryPassPosition objectAtIndex:iIndex];
    NSArray *aryPassPosition = [strPassPosition componentsSeparatedByString:@","];
    float x = [[aryPassPosition objectAtIndex:0]floatValue];
    float y = [[aryPassPosition objectAtIndex:1]floatValue];
    float z = [[aryPassPosition objectAtIndex:2]floatValue];
    Station_Position PassPosition = {x,y,z};
    
    BOOL bRet = NO;
    BOOL bTemp = NO;
    if (aryResult == nil)
    {
        aryResult = [m_dicTestResult objectForKey:strStationName];
    }
    NSLog(@"Handle test over MLB result:%@",aryResult);
    if([aryResult containsObject:@"FAIL"] && [aryResult containsObject:@"PASS"])
    {
        NSLog(@"result contains PASS and FAIL");
        Station_Position GoToStation = [self HandleFailUnitsOfStation:strStationName ReturnValue:dicReturn ofIndex:iIndex];
         NSString *strGoToStationName = [dicReturn objectForKey:@"GoToStation"];
        float fFailDistance = [optimization GetTheDistance:Client.StationPosition toPoint:GoToStation];
        float fPassDistance = [optimization GetTheDistance:Client.StationPosition toPoint:PassPosition];
        
        if (iIndex+1 < [m_aryStationName count])
        {
            int k = 0;
            @synchronized(m_aryPreviousPass)
            {
                int iPass = [[m_aryPreviousPass objectAtIndex:iIndex+1]intValue];
                for (NSString *strName in aryResult)
                {
                    if ([strName isEqualToString:@"PASS"])
                    {
                        iPass++;
                        k++;
                        
                    }
                }
                [m_aryPreviousPass replaceObjectAtIndex:iIndex+1 withObject:[NSNumber numberWithInt:iPass]];
            }
            
            if ([m_aryHasNewMLB containsObject:[NSNumber numberWithBool:YES]])
            {
                bRet = NO;
            }
            //no need wait for 4 MLBs to test next station
            else if (!bPickAll &&[[m_aryAvailableStation objectAtIndex:iIndex+1]count] > 0)
            {
                iCurrentAtHandCount = k;
                [m_aryHasNewMLB replaceObjectAtIndex:iIndex+1 withObject:[NSNumber numberWithBool:YES]];
                [LogManager creatAndWriteRobotLog:[NSString stringWithFormat:@"Put the fail MLB on Fail Area: %@",strGoToStationName]];
                fSleepTime = [self CalculateSpend:fFailDistance];
                usleep(fSleepTime);
                [optimization _setRobotCurrentLocation:GoToStation];
                bRet = YES;
            }
        }
        if(!bRet)
        {
            if (fFailDistance <= fPassDistance)
            {
                fSleepTime = [self CalculateSpend:fFailDistance];
                [LogManager creatAndWriteRobotLog:[NSString stringWithFormat:@"Put the fail MLB on Fail area: %@ ",strGoToStationName]];
                
                usleep(fSleepTime);
                //then go to pass area
                fDistance = [optimization GetTheDistance:GoToStation toPoint:PassPosition];
                fSleepTime = [self CalculateSpend:fDistance];
                [LogManager creatAndWriteRobotLog:[NSString stringWithFormat: @"Put the pass MLB on Pass area! "]];
                usleep(fSleepTime);
                [optimization _setRobotCurrentLocation:PassPosition];
                
            }
            else
            {
                //go to pass area first
                fSleepTime = [self CalculateSpend:fPassDistance];
                [LogManager creatAndWriteRobotLog:[NSString stringWithFormat: @"Put the pass MLB on Pass area! "]];
                usleep(fSleepTime);
                //then go to fail area
                fDistance = [optimization GetTheDistance:PassPosition toPoint:GoToStation];
                fSleepTime = [self CalculateSpend:fDistance];
                [LogManager creatAndWriteRobotLog:[NSString stringWithFormat:@"Put the fail MLB on Fail area: %@ ",strGoToStationName]];
                usleep(fSleepTime);
                [optimization _setRobotCurrentLocation:GoToStation];
            }
            iCurrentAtHandCount = 0;
        }
        [m_dicTestResult removeObjectForKey:strStationName];
        [dicReturn release];
        return;
    }
    //if all the mlb is pass, then put the mlb on pass area
    if (![aryResult containsObject:@"FAIL"])
    {
        bRet = YES;
        if (iIndex+1 < [m_aryStationName count])
        {
            @synchronized(m_aryPreviousPass)
            {
                
                int iPass = [[m_aryPreviousPass objectAtIndex:iIndex+1]intValue];
                [LogManager creatAndWriteRobotLog:[NSString stringWithFormat:@"%@ previous pass MLB number: %d",[m_aryStationName objectAtIndex:iIndex+1],iPass]];
                for (NSString *strResult in aryResult)
                {
                    if ([strResult isEqualToString:@"PASS"])
                    {
                        iPass++;
                    }
                }
                [m_aryPreviousPass replaceObjectAtIndex:iIndex+1 withObject:[NSNumber numberWithInt:iPass]];
                NSLog(@"%@ previous pass MLB number: %d",[m_aryStationName objectAtIndex:iIndex+1],iPass);
            }
            //no need wait for 4 MLBs to test next station
            if ([[m_aryAvailableStation objectAtIndex:iIndex+1]count] > 0 && ![m_aryHasNewMLB containsObject:[NSNumber numberWithBool:YES]] )
            {
                //put the pass MLB on hand
                if (bPickAll && [aryResult containsObject:@"NA"])
                {
                    bRet = NO;
                }
                else
                {
                    iCurrentAtHandCount = 0;
                    for (NSString *strName in aryResult)
                    {
                        if ([strName isEqualToString:@"PASS"])
                        {
                            iCurrentAtHandCount++;
                            
                        }
                    }
                    [m_aryHasNewMLB replaceObjectAtIndex:iIndex+1 withObject:[NSNumber numberWithBool:YES]];
                }
            }
            else if(!bRet)
            {
                float fPassDistance = [optimization GetTheDistance:Client.StationPosition toPoint:PassPosition];
                // put the pass area on pass area
                fSleepTime = [self CalculateSpend:fPassDistance];
                [LogManager creatAndWriteRobotLog:[NSString stringWithFormat: @"Put the pass MLB on Pass area! "]];
                usleep(fSleepTime);
                [dicReturn release];
                [m_dicTestResult removeObjectForKey:strStationName];
                return;
            }
        }
        else
        {
            fDistance = [optimization GetTheDistance:Client.StationPosition toPoint:PassPosition];
            [LogManager creatAndWriteRobotLog:@"Put the pass MLB on Pass Area"];
            fSleepTime = [self CalculateSpend:fDistance];
            [optimization _setRobotCurrentLocation:PassPosition];
            usleep(fSleepTime);
            [dicReturn release];
            [m_dicTestResult removeObjectForKey:strStationName];
            return;

        }
        
    }
    else if(![aryResult containsObject:@"PASS"])
    {
        
        if (![aryResult containsObject:@"NA"]&& [[m_aryRetestRule objectAtIndex:iIndex]isNotEqualTo:@"AAA"] && [[m_aryAvailableStation objectAtIndex:iIndex]count] >1)
        {
            if (!([[m_dicFirstFailStations allKeys] containsObject:strStationName] || [[m_dicFirstFailStations objectForKey:strStationName]boolValue])&&([[m_dicSecondFailStations allKeys] containsObject:strStationName] && [[m_dicSecondFailStations objectForKey:strStationName]boolValue])&& [[m_aryRetestRule objectAtIndex:iIndex]isEqualToString:@"AAB"])
            {
                [self HandleFailUnitsOfStation:strStationName ReturnValue:dicReturn ofIndex:iIndex];
                NSMutableDictionary *dicAvailable = [m_aryAvailableStation objectAtIndex:iIndex];
                [dicAvailable removeObjectForKey:strStationName];
                if (m_iPickerNum/m_iSlotNum > 1)
                {
                    [optimization GetShortestPath:dicAvailable Return_Value:m_dicReturnValue];
                    bTemp = YES;
                }
                else
                {
                    NSMutableDictionary *dicStation = [[NSMutableDictionary alloc]init];
                    NSPredicate *thePredicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",m_arrFinishStation];
                    NSArray *aryAll = [dicAvailable allKeys];
                    NSArray *aryFinish = [aryAll filteredArrayUsingPredicate:thePredicate];
                    for (NSString *strKey in aryFinish)
                    {
                        [dicStation setObject:[dicAvailable objectForKey:strKey] forKey:strKey];
                    }
                    if ([dicStation count]>0)
                    {
                        [optimization GetShortestPath:dicStation Return_Value:m_dicReturnValue];
                        bTemp = YES;
                    }
                    else
                        bTemp = NO;
                    
                    [dicStation release];
                }
                if (bTemp)
                {
                    dicAvailable = [m_aryAvailableStation objectAtIndex:iIndex];
                    NSString *strStation = [m_dicReturnValue objectForKey:@"StationName"];
                    StationCline *currentStation = [dicAvailable objectForKey:strStation];
                    NSArray *aryTemp = [NSArray arrayWithArray:m_arrFinishStation];
                    bSecondFailMLB = YES;
                    
                    if ([aryTemp containsObject:strStation])
                    {
                        //Get the unit out of the fixture and put the new unit on fixture for test
                        fDistance = [[m_dicReturnValue objectForKey:@"Distance"]floatValue];
                        float fSleepTime = [self CalculateSpend:fDistance];
                        [LogManager creatAndWriteRobotLog:[NSString stringWithFormat:@"Go To Station : %@ ",strStationName]];
                        usleep(fSleepTime);
                        bTemp = YES;
                        [self HandleTestOverStation:strStationName ofClient:currentStation];
                        NSDictionary *dicInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],OPTIMIZATION_ROBOT_PUTNEWMLB,[NSString stringWithFormat:@"%@",strStation],@"StationName",[NSNumber numberWithInt:m_iSlotNum],@"InputCount", nil];
                        iCurrentAtHandCount = m_iSlotNum;
                        [self PutMLBOnStation:strStationName Client:currentStation forSleep:0 ofIndex:iIndex];
                        [nc postNotificationName:BNRPostStartNotification object:self userInfo:dicInfo];
                        [m_dicBusyStation setObject:currentStation forKey:strStation];
                        dicAvailable = [m_aryAvailableStation objectAtIndex:iIndex];
                        [dicAvailable removeObjectForKey:strStationName];
                        [m_aryAvailableStation replaceObjectAtIndex:iIndex withObject:dicAvailable];
                        [optimization _setRobotCurrentLocation:currentStation.StationPosition];
                        
                        [self HandleMLBTestOverofStation:strStationName ofClient:currentStation ofIndex:iIndex];
                        [dicReturn release];
                        return;
                    }
                    else
                    {
                        //put the new unit on fixture for test
                        fDistance = [[m_dicReturnValue objectForKey:@"Distance"]floatValue];
                        float fSleepTime = [self CalculateSpend:fDistance];
                        [LogManager creatAndWriteRobotLog:[NSString stringWithFormat:@"Go To Station : %@ ",strStationName]];
                        usleep(fSleepTime);
                        bTemp = YES;
                        NSDictionary *dicTemp = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],OPTIMIZATION_ROBOT_PUTNEWMLB,[NSString stringWithFormat:@"%@",strStation],@"StationName",[NSNumber numberWithInt:m_iSlotNum],@"InputCount", nil];
                        iCurrentAtHandCount = m_iSlotNum;
                        [self PutMLBOnStation:strStationName Client:currentStation forSleep:0 ofIndex:iIndex];
                        [nc postNotificationName:BNRPostStartNotification object:self userInfo:dicTemp];
                        [m_dicBusyStation setObject:currentStation forKey:strStationName];
                        dicAvailable = [m_aryAvailableStation objectAtIndex:iIndex];
                        [dicAvailable removeObjectForKey:strStationName];
                        [m_aryAvailableStation replaceObjectAtIndex:iIndex withObject:dicAvailable];
                        iCurrentAtHandCount = 0;
                        [optimization _setRobotCurrentLocation:currentStation.StationPosition];
                        [dicReturn release];
                        return;
                    }
                }

            }
            else if([[m_aryRetestRule objectAtIndex:iIndex]isEqualToString:@"ABC"])
            {
                
                NSMutableDictionary *dicAvailable = [m_aryAvailableStation objectAtIndex:iIndex];
                [self HandleFailUnitsOfStation:strStationName ReturnValue:dicReturn ofIndex:iIndex];
                NSString *strGoToStation = [dicReturn objectForKey:@"GoToStation"];
                if ([strGoToStation rangeOfString:@"_First_Fail_Area"].location != NSNotFound)
                {
                    bFirstFailMLB = YES;
                    [dicAvailable removeObjectForKey:strStationName];
                }
                if ([strGoToStation rangeOfString:@"_Second_Fail_Area"].location != NSNotFound)
                {
                    bSecondFailMLB = YES;
                    NSMutableArray *aryTemp = [[NSMutableArray alloc]init];
                    for (NSInteger j = [m_arySecondFailMLBInfo count] -m_iSlotNum ; j <[m_arySecondFailMLBInfo count]; j++)
                    {
                        NSArray *aryInfo = [[m_arySecondFailMLBInfo objectAtIndex:j]componentsSeparatedByString:@","];
                        [aryTemp addObject:aryInfo];
                    }
                    for (NSString *strName in aryTemp)
                    {
                        [dicAvailable removeObjectForKey:strName];
                    }
                }
                if ([dicAvailable count]>0)
                {
                    
                    if (m_iPickerNum/m_iSlotNum > 1)
                    {
                        [optimization GetShortestPath:dicAvailable Return_Value:m_dicReturnValue];
                        bTemp = YES;
                    }
                    else
                    {
                        NSMutableDictionary *dicStation = [[NSMutableDictionary alloc]init];
                        NSPredicate *thePredicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",m_arrFinishStation];
                        NSArray *aryAll = [dicAvailable allKeys];
                        NSArray *aryFinish = [aryAll filteredArrayUsingPredicate:thePredicate];
                        for (NSString *strKey in aryFinish)
                        {
                            [dicStation setObject:[dicAvailable objectForKey:strKey] forKey:strKey];
                        }
                        if ([dicStation count]>0)
                        {
                            [optimization GetShortestPath:dicStation Return_Value:m_dicReturnValue];
                            bTemp = YES;
                        }
                        else
                            bTemp = NO;
                        
                        [dicStation release];
                    }
                    if (bTemp)
                    {
                        NSString *strStation = [m_dicReturnValue objectForKey:@"StationName"];
                        StationCline *currentStation = [dicAvailable objectForKey:strStation];
                        NSArray *aryTemp = [NSArray arrayWithArray:m_arrFinishStation];
                        
                        if ([aryTemp containsObject:strStation])
                        {
                            fDistance = [[m_dicReturnValue objectForKey:@"Distance"]floatValue];
                            float fSleepTime = [self CalculateSpend:fDistance];
                            [LogManager creatAndWriteRobotLog:[NSString stringWithFormat:@"Go To Station : %@ ",strStationName]];
                            usleep(fSleepTime);
                            
                            [self HandleTestOverStation:strStationName ofClient:currentStation];
                            NSDictionary *dicInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],OPTIMIZATION_ROBOT_PUTNEWMLB,[NSString stringWithFormat:@"%@",strStation],@"StationName",[NSNumber numberWithInt:m_iSlotNum],@"InputCount", nil];
                            iCurrentAtHandCount = m_iSlotNum;
                            [self PutMLBOnStation:strStationName Client:currentStation forSleep:0 ofIndex:iIndex];
                            [nc postNotificationName:BNRPostStartNotification object:self userInfo:dicInfo];
                            [m_dicBusyStation setObject:currentStation forKey:strStation];
                            dicAvailable = [m_aryAvailableStation objectAtIndex:iIndex];
                            [dicAvailable removeObjectForKey:strStationName];
                            [m_aryAvailableStation replaceObjectAtIndex:iIndex withObject:dicAvailable];
                            [optimization _setRobotCurrentLocation:currentStation.StationPosition];
                            
                            [self HandleMLBTestOverofStation:strStationName ofClient:currentStation ofIndex:iIndex];
                            [dicReturn release];
                            return;
                        }
                        else
                        {
                            fDistance = [[m_dicReturnValue objectForKey:@"Distance"]floatValue];
                            float fSleepTime = [self CalculateSpend:fDistance];
                            [LogManager creatAndWriteRobotLog:[NSString stringWithFormat:@"Go To Station : %@ ",strStationName]];
                            usleep(fSleepTime);
                            NSDictionary *dicTemp = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],OPTIMIZATION_ROBOT_PUTNEWMLB,[NSString stringWithFormat:@"%@",strStation],@"StationName",[NSNumber numberWithInt:m_iSlotNum],@"InputCount", nil];
                            iCurrentAtHandCount = m_iSlotNum;
                            [self PutMLBOnStation:strStationName Client:currentStation forSleep:0 ofIndex:iIndex];
                            [nc postNotificationName:BNRPostStartNotification object:self userInfo:dicTemp];
                            [m_dicBusyStation setObject:currentStation forKey:strStationName];
                            dicAvailable = [m_aryAvailableStation objectAtIndex:iIndex];
                            [dicAvailable removeObjectForKey:strStationName];
                            [m_aryAvailableStation replaceObjectAtIndex:iIndex withObject:dicAvailable];
                            iCurrentAtHandCount = 0;
                            [optimization _setRobotCurrentLocation:currentStation.StationPosition];
                            [dicReturn release];
                            return;
                        }
                    }
                }
            }
        }
        else if(!bTemp)
        {
            Station_Position GoToPostion = [self HandleFailUnitsOfStation:strStationName ReturnValue:dicReturn ofIndex:iIndex];
            NSString *strGoToStation = [dicReturn objectForKey:@"GoToStation"];
            
            [LogManager creatAndWriteRobotLog:[NSString stringWithFormat:@"Put the fail MLB on fail area: %@",strGoToStation]];
            fDistance = [optimization GetTheDistance:Client.StationPosition toPoint:GoToPostion];
            [nc postNotificationName:BNRPostGoToStationNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:strGoToStation,@"GoToStation", nil]];
            fSleepTime = [self CalculateSpend:fDistance];
            [optimization _setRobotCurrentLocation:GoToPostion];
            usleep(fSleepTime);
            iCurrentAtHandCount = 0;
            [dicReturn release];
            [m_dicTestResult removeObjectForKey:strStationName];
            return;
        }
    }

}

// get the units out of the fixture
- (void)HandleTestOverStation:(NSString *)strStationName ofClient:(StationCline *)currentStation
{
    //the mlb test result of the station
    NSArray *aryResult = [m_dicTestResult objectForKey:strStationName];
    [LogManager creatAndWriteRobotLog:[NSString stringWithFormat:@"Get the MLB out of Station: %@ and test result :%@",strStationName,[aryResult componentsJoinedByString:@":"]]];
    NSDictionary *dicTemp = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],OPTIMIZATION_ROBOT_GETMLBOUT,[NSString stringWithFormat:@"%@",strStationName],@"StationName", nil];
    [nc postNotificationName:BNRPostStartNotification object:self userInfo:dicTemp];
   
    [m_arrFinishStation removeObject:strStationName];
    [optimization _setRobotCurrentLocation:currentStation.StationPosition];
}

// put the unit on station for test
-(void)PutMLBOnStation:(NSString *)strStationName Client:(StationCline *)objClient forSleep:(float)fSleepTime ofIndex:(int)iIndex
{
    //if the robot has new MLB on hand, then put the mlb on the fixture and start test
    //put the new mlb on fixture
    if (!bFirstFailMLB && !bSecondFailMLB)
    {
        [LogManager creatAndWriteRobotLog:[NSString stringWithFormat:@"Put the new MLB on fixture : %@ and MLB count is:%d",strStationName,iCurrentAtHandCount]];
        
        int iInput = [[m_aryInputMLBCount objectAtIndex:iIndex]intValue];
        iInput += iCurrentAtHandCount;
        [m_aryInputMLBCount replaceObjectAtIndex:iIndex withObject:[NSNumber numberWithInt:iInput]];
        //betty
        if(iIndex != 0 )
        {
            @synchronized(m_aryPreviousPass)
            {
                int iPreviousPass = [[m_aryPreviousPass objectAtIndex:iIndex]intValue];
                iPreviousPass -= iCurrentAtHandCount;
                [m_aryPreviousPass replaceObjectAtIndex:iIndex withObject:[NSNumber numberWithInt:iPreviousPass]];
                NSLog(@"Station: %@ Input MLB Count: %d, Test pass untest :%d",strStationName, iInput,iPreviousPass);
            }
        }
        else if([[m_aryPreviousPass objectAtIndex:0]intValue] != 99999)
        {
            @synchronized(m_aryPreviousPass)
            {
                int iPreviousPass = [[m_aryPreviousPass objectAtIndex:iIndex]intValue];
                iPreviousPass -= iCurrentAtHandCount;
                [m_aryPreviousPass replaceObjectAtIndex:iIndex withObject:[NSNumber numberWithInt:iPreviousPass]];
                NSLog(@"Station: %@ Input MLB Count: %d, Test pass untest :%d",strStationName, iInput,iPreviousPass);
            }
        }
        return;
    }
    //put the first fail unit on Fixture for retest
    if (bFirstFailMLB)
    {
//        [m_dicFirstFailStations addObject:strStationName];
        [m_dicFirstFailStations setObject:[NSNumber numberWithBool:NO] forKey:strStationName];
        bFirstFailMLB = NO;
        @synchronized(g_szSyncHandleMsg)
        {
             NSLog(@"before First Fail MLB number: %@",m_aryFirstFail);
            int iFirstFail = [[m_aryFirstFail objectAtIndex:iIndex]intValue];
            iFirstFail -= iCurrentAtHandCount;
//            [m_aryFirstFail replaceObjectAtIndex:iIndex withObject:[NSNumber numberWithInt:iFirstFail]];
            [m_aryFirstFail removeObjectAtIndex:iIndex];
            [m_aryFirstFail insertObject:[NSNumber numberWithInt:iFirstFail] atIndex:iIndex];
            int iFirstFailCount = [[m_aryFirstFailCount objectAtIndex:iIndex]intValue];
            iFirstFailCount -= iCurrentAtHandCount;
            [m_aryFirstFailCount replaceObjectAtIndex:iIndex withObject:[NSNumber numberWithInt:iFirstFailCount]];
            
            [LogManager creatAndWriteRobotLog:[NSString stringWithFormat:@"Put the first Fail MLB on fixture to retest : %@ count:%d and Untest Fail MLB:%d",strStationName,iCurrentAtHandCount,iFirstFail]];
            NSLog(@"after First Fail MLB number: %@",m_aryFirstFail);
            NSLog(@"after first fail MLB count: %@",m_aryFirstFailCount);
        }
        return;
    }
    //put the second fail units on fixture for third retest
    if (bSecondFailMLB)
    {
        [m_dicSecondFailStations setObject:[NSNumber numberWithBool:NO] forKey:strStationName];
        bSecondFailMLB = NO;
       @synchronized(g_szSyncHandleMsg)
        {
            int iSecondFail = [[m_arySecondFail objectAtIndex:iIndex]intValue];
            iSecondFail -= iCurrentAtHandCount;
            [m_arySecondFail replaceObjectAtIndex:iIndex withObject:[NSNumber numberWithInt:iSecondFail]];
            
            int iSecondFailCount = [[m_arySecondFailCount objectAtIndex:iIndex]intValue];
            iSecondFailCount -= iCurrentAtHandCount;
            [m_arySecondFailCount replaceObjectAtIndex:iIndex withObject:[NSNumber numberWithInt:iSecondFailCount]];
    //        [m_arySecondFail replaceObjectAtIndex:iIndex withObject:[NSNumber numberWithInt:iSecondFailCount]];
            
            [LogManager creatAndWriteRobotLog:[NSString stringWithFormat:@"Put the second fail MLB on fixture to retest: %@ Count:%d and Untest fail MLB:%d",strStationName,iCurrentAtHandCount,iSecondFail]];
        }
        return;
    }
}

//retest ABC rule
- (BOOL)RetestABC:(NSDictionary *)dicStaitonInfo OfIndex:(int)iIndex
{
    NSLog(@"RetestABC");
    int iCount = 0;
    NSMutableDictionary *dicTemp = [[NSMutableDictionary alloc]init];
    Station_Position TempPosition = {0,0,0};
    NSString *strStation = @"";
    NSMutableArray *aryTemp = [[NSMutableArray alloc]init];
    
    if ([[m_arySecondFailCount objectAtIndex:iIndex]intValue] >= m_iSlotNum)
    {
        NSMutableArray *aryFail = [m_arySecondFailMLBInfo objectAtIndex:iIndex];
        int j = [[m_arySecondFailCount objectAtIndex:iIndex]intValue] / m_iSlotNum;
        for (int i = 0; i < j; i++)
        {
            [aryTemp removeAllObjects];
            for (int k = 0; k < m_iSlotNum; k++)
            { 
                NSArray *aryInfo = [[aryFail objectAtIndex:iCount]componentsSeparatedByString:@","];
                [aryTemp addObject:aryInfo];
                iCount++;
            }
            for (NSString *strKey in dicStaitonInfo)
            {
                if (![aryTemp containsObject:strKey])
                {
                    [dicTemp setObject:[dicStaitonInfo objectForKey:strKey] forKey:strKey];
                    bSecondFailMLB = YES;
                }
            }
            if (bSecondFailMLB)
            {
                NSString *strFail = [m_arySecondFailPosition objectAtIndex:iIndex];
                NSArray *aryFail = [strFail componentsSeparatedByString:@","];
                float x = [[aryFail objectAtIndex:0]floatValue];
                float y = [[aryFail objectAtIndex:1]floatValue];
                float z = [[aryFail objectAtIndex:2]floatValue];
                
                TempPosition.X = x;
                TempPosition.Y = y;
                TempPosition.Z = z;
                
                strStation = [NSString stringWithFormat:@"%@_Second_Fail_Area",[m_aryStationName objectAtIndex:iIndex]];
                break;
            }
        }
    }
    
    else if ([[m_aryFirstFailCount objectAtIndex:iIndex]intValue] >= m_iSlotNum)
    {
        NSMutableArray *aryFail = [m_aryFirstFailMLBInfo objectAtIndex:iIndex];
        int j = [[m_aryFirstFailCount objectAtIndex:iIndex]intValue]/m_iSlotNum;
        for (int i = 0;i < j ; i++)
        {
            [aryTemp removeAllObjects];
            for (int k = 0; k < m_iSlotNum; k++)
            {
                [aryTemp addObject:[aryFail objectAtIndex:iCount]];
                iCount++;
            }
            for (NSString *strKey in dicStaitonInfo)
            {
                if (![aryTemp containsObject:strKey])
                {
                    [dicTemp setObject:[dicStaitonInfo objectForKey:strKey] forKey:strKey];
                    bFirstFailMLB = YES;
                }
            }
            if (bFirstFailMLB)
            {
                NSString *strFail = [m_aryFirstFailPosition objectAtIndex:iIndex];
                NSArray *aryFail = [strFail componentsSeparatedByString:@","];
                float x = [[aryFail objectAtIndex:0]floatValue];
                float y = [[aryFail objectAtIndex:1]floatValue];
                float z = [[aryFail objectAtIndex:2]floatValue];
                
                TempPosition.X = x;
                TempPosition.Y = y;
                TempPosition.Z = z;
                
                strStation = [NSString stringWithFormat:@"%@_First_Fail_Area",[m_aryStationName objectAtIndex:iIndex]];
                break;
            }
        }
    }
    if (!bSecondFailMLB && !bFirstFailMLB)
    {
        [aryTemp release];
        [dicTemp release];
        return (bFirstFailMLB||bSecondFailMLB);
    }
    else
    {
        if (m_iPickerNum/m_iSlotNum > 1)
        {
            [optimization GetShortestPath:dicTemp Return_Value:m_dicReturnValue];
        }
        else 
        {
            NSMutableDictionary *dicStation = [[NSMutableDictionary alloc]init];
            NSPredicate *thePredicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",m_arrFinishStation];
            NSArray *aryAll = [dicTemp allKeys];
            NSArray *aryFinish = [aryAll filteredArrayUsingPredicate:thePredicate];
            for (NSString *strKey in aryFinish)
            {
                [dicStation setObject:[dicTemp objectForKey:strKey] forKey:strKey];
            }
            [optimization GetShortestPath:dicStation Return_Value:m_dicReturnValue];
            [dicStation release];
        }

        NSString *strStationName = [m_dicReturnValue objectForKey:@"StationName"];
        if ([strStationName isEqualToString:@"NA"])
        {
            [aryTemp release];
            [dicTemp release];
            bFirstFailMLB = NO;
            bSecondFailMLB = NO;
            return NO;
        }
        StationCline *currentStation = [[m_aryAvailableStation objectAtIndex:0] objectForKey:strStationName];
        
        //go to fail area to get fail mlb to retest
        [LogManager creatAndWriteRobotLog:[NSString stringWithFormat:@"Go to %@ to get %d fail MLB for retest",strStation,m_iSlotNum]];
        float fDistance = [optimization GetTheDistance:optimization._getRobotCurrentLocation toPoint:TempPosition];
        float fCostTime = [self CalculateSpend:fDistance];
        iCurrentAtHandCount = m_iSlotNum;
        usleep(fCostTime);
       
        if (bFirstFailMLB)
        {
             NSMutableArray *aryFail = [m_aryFirstFailMLBInfo objectAtIndex:iIndex];
            for (int j =0 ;j< m_iSlotNum ; j++)
            {
                iCount--;
                [aryFail removeObjectAtIndex:iCount];
            }
            [m_aryFirstFailMLBInfo replaceObjectAtIndex:iIndex withObject:aryFail];
        }
        else
        {
            NSMutableArray *aryFail = [m_arySecondFailMLBInfo objectAtIndex:iIndex];
//            [aryFail removeObjectAtIndex:iCount];
            for (int j =0 ;j< m_iSlotNum ; j++)
            {
                iCount--;
                [aryFail removeObjectAtIndex:iCount];
            }
            [m_arySecondFailMLBInfo replaceObjectAtIndex:iIndex withObject:aryFail];
        }
      
        if ([m_arrFinishStation containsObject:strStationName])
        {
            fDistance = [[m_dicReturnValue objectForKey:@"Distance"]floatValue];
            float fSleepTime = [self CalculateSpend:fDistance];
            [LogManager creatAndWriteRobotLog:[NSString stringWithFormat:@"Go To Station : %@ ",strStationName]];
            usleep(fSleepTime);
            
            [self HandleTestOverStation:strStationName ofClient:currentStation];
            NSDictionary *dicTemp = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],OPTIMIZATION_ROBOT_PUTNEWMLB,[NSString stringWithFormat:@"%@",strStationName],@"StationName",[NSNumber numberWithInt:iCurrentAtHandCount],@"InputCount", nil];
            [self PutMLBOnStation:strStationName Client:currentStation forSleep:0 ofIndex:iIndex];
            [nc postNotificationName:BNRPostStartNotification object:self userInfo:dicTemp];
            [m_dicFailMLBInfo setObject:aryTemp forKey:strStationName];
            NSLog(@"Fail MLB info:%@",m_dicFailMLBInfo);
            [m_dicBusyStation setObject:currentStation forKey:strStationName];
            NSMutableDictionary *dicAvailable = [m_aryAvailableStation objectAtIndex:iIndex];
            [dicAvailable removeObjectForKey:strStationName];
            [m_aryAvailableStation replaceObjectAtIndex:iIndex withObject:dicAvailable];
            [optimization _setRobotCurrentLocation:currentStation.StationPosition];
            iCurrentAtHandCount = m_iSlotNum; //for station test over MLB
            
            [self HandleMLBTestOverofStation:strStationName ofClient:currentStation ofIndex:iIndex];

        }
        else
        {
            fDistance = [[m_dicReturnValue objectForKey:@"Distance"]floatValue];
            float fSleepTime = [self CalculateSpend:fDistance];
            [LogManager creatAndWriteRobotLog:[NSString stringWithFormat:@"Go To Station : %@ ",strStationName]];
            usleep(fSleepTime);
            NSDictionary *dicTemp = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],OPTIMIZATION_ROBOT_PUTNEWMLB,[NSString stringWithFormat:@"%@",strStationName],@"StationName",[NSNumber numberWithInt:iCurrentAtHandCount],@"InputCount", nil];
            [self PutMLBOnStation:strStationName Client:currentStation forSleep:0 ofIndex:iIndex];
            [nc postNotificationName:BNRPostStartNotification object:self userInfo:dicTemp];
            [m_dicBusyStation setObject:currentStation forKey:strStationName];
            NSMutableDictionary *dicAvailable = [m_aryAvailableStation objectAtIndex:iIndex];
            [dicAvailable removeObjectForKey:strStationName];
            [m_aryAvailableStation replaceObjectAtIndex:iIndex withObject:dicAvailable];
            iCurrentAtHandCount = 0;
            [optimization _setRobotCurrentLocation:currentStation.StationPosition];
        }
    }
    [aryTemp release];
    [dicTemp release];
    return YES;
}

//retest AAB rule
- (BOOL)RetestAAB:(NSDictionary *)dicStaitonInfo ofIndex:(int)iIndex
{
    NSLog(@"RetestAAB");
    int iCount = 0;
    NSMutableDictionary *dicTemp = [[NSMutableDictionary alloc]init];
    Station_Position TempPosition = {0,0,0};
    NSString *strStation = @"";
    NSMutableArray *aryTemp = [[NSMutableArray alloc]init];
    
    if ([[m_arySecondFailCount objectAtIndex:iIndex]intValue] >= m_iSlotNum)
    {
        NSString *strFail = [m_arySecondFailPosition objectAtIndex:iIndex];
        NSArray *aryFail = [strFail componentsSeparatedByString:@","];
        float x = [[aryFail objectAtIndex:0]floatValue];
        float y = [[aryFail objectAtIndex:1]floatValue];
        float z = [[aryFail objectAtIndex:2]floatValue];

        TempPosition.X = x;
        TempPosition.Y = y;
        TempPosition.Z = z;

        strStation = [NSString stringWithFormat:@"%@_Second_Fail_Area",[m_aryStationName objectAtIndex:iIndex]];
        dicTemp = [NSDictionary dictionaryWithDictionary:dicStaitonInfo];
        bSecondFailMLB = YES;
        iCount = m_iSlotNum;
    }
    
    else if ([[m_aryFirstFailCount objectAtIndex:iIndex]intValue] >= m_iSlotNum)
    {
        int j = [[m_aryFirstFailCount objectAtIndex:iIndex]intValue]/m_iSlotNum;
        for (int i = 0;i < j ; i++)
        {
            [aryTemp removeAllObjects];
            for (int k = 0; k < m_iSlotNum; k++)
            {
                [aryTemp addObject:[[m_aryFirstFailMLBInfo objectAtIndex:iIndex]objectAtIndex:iCount]];
                iCount++;
            }
            NSArray *aryKeyName = [dicStaitonInfo allKeys];
            for (NSString *strKey in aryKeyName)
            {
                if (![aryTemp containsObject:strKey])
                {
                    [dicTemp setObject:[dicStaitonInfo objectForKey:strKey] forKey:strKey];
                    bFirstFailMLB = YES;
                }
            }
            if (bFirstFailMLB)
            {
                NSString *strFail = [m_aryFirstFailPosition objectAtIndex:iIndex];
                NSArray *aryFail = [strFail componentsSeparatedByString:@","];
                float x = [[aryFail objectAtIndex:0]floatValue];
                float y = [[aryFail objectAtIndex:1]floatValue];
                float z = [[aryFail objectAtIndex:2]floatValue];
                
                TempPosition.X = x;
                TempPosition.Y = y;
                TempPosition.Z = z;
                strStation = [NSString stringWithFormat:@"%@_First_Fail_Area",[m_aryStationName objectAtIndex:iIndex]];
               
                break;
            }
        }
    }
    if (!bFirstFailMLB && !bSecondFailMLB)
    {
        [dicTemp release];
        [aryTemp release];
        return (NO);
    }
    else
    {
        
        if (m_iPickerNum/m_iSlotNum > 1)
        {
            [optimization GetShortestPath:dicTemp Return_Value:m_dicReturnValue];
        }
        else
        {
            NSMutableDictionary *dicStation = [[NSMutableDictionary alloc]init];
            NSPredicate *thePredicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",m_arrFinishStation];
            NSArray *aryAll = [dicTemp allKeys];
            NSArray *aryFinish = [aryAll filteredArrayUsingPredicate:thePredicate];
            for (NSString *strKey in aryFinish)
            {
                [dicStation setObject:[dicTemp objectForKey:strKey] forKey:strKey];
            }
            [optimization GetShortestPath:dicStation Return_Value:m_dicReturnValue];
            [dicStation release];
        }
        
        NSString *strStationName = [m_dicReturnValue objectForKey:@"StationName"];
        if ([strStationName isEqualToString:@"NA"])
        {
            [aryTemp release];
            [dicTemp release];
            bFirstFailMLB = NO;
            bSecondFailMLB = NO;
            return NO;
        }
        //go to fail area to get fail mlb to retest
        [LogManager creatAndWriteRobotLog:[NSString stringWithFormat:@"Go to %@ to get %d fail MLB for retest",strStation,m_iSlotNum]];
        float fDistance = [optimization GetTheDistance:optimization._getRobotCurrentLocation toPoint:TempPosition];
        float fCostTime = [self CalculateSpend:fDistance];
        [optimization _setRobotCurrentLocation:TempPosition];
        usleep(fCostTime);
        
        StationCline *currentStation;
        
        currentStation = [[m_aryAvailableStation objectAtIndex:iIndex] objectForKey:strStationName];
        iCurrentAtHandCount = m_iSlotNum;
        
        if (bFirstFailMLB)
        {
            NSMutableArray *aryFail = [m_aryFirstFailMLBInfo objectAtIndex:iIndex];
            for (int j =0 ;j< m_iSlotNum ; j++)
            {
                iCount--;
                [aryFail removeObjectAtIndex:iCount];
            }
            [m_aryFirstFailMLBInfo replaceObjectAtIndex:iIndex withObject:aryFail];
            [m_dicFailMLBInfo setObject:aryTemp forKey:strStationName];
            NSLog(@"Fail MLB Info:%@",m_dicFailMLBInfo);
        }
        else
        {
            NSMutableArray *aryFail = [m_arySecondFailMLBInfo objectAtIndex:iIndex];
            for (int j =0 ;j< m_iSlotNum ; j++)
            {
                iCount--;
                [aryFail removeObjectAtIndex:iCount];
            }
            [m_arySecondFailMLBInfo replaceObjectAtIndex:iIndex withObject:aryFail];
        }
    
        if ([m_arrFinishStation containsObject:strStationName])
        {
            //get the units out of mlb and put the new MLB on fixture to test. then handle the units tested
            fDistance = [[m_dicReturnValue objectForKey:@"Distance"]floatValue];
            float fSleepTime = [self CalculateSpend:fDistance];
            [LogManager creatAndWriteRobotLog:[NSString stringWithFormat:@"Go To Station : %@ ",strStationName]];
            usleep(fSleepTime);
            
            [self HandleTestOverStation:strStationName ofClient:currentStation];
            NSDictionary *dicInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],OPTIMIZATION_ROBOT_PUTNEWMLB,[NSString stringWithFormat:@"%@",strStationName],@"StationName",[NSNumber numberWithInt:iCurrentAtHandCount],@"InputCount", nil];
            [self PutMLBOnStation:strStationName Client:currentStation forSleep:0 ofIndex:iIndex];  
            [nc postNotificationName:BNRPostStartNotification object:self userInfo:dicInfo];
            [m_dicBusyStation setObject:currentStation forKey:strStationName];
            NSMutableDictionary *dicAvailable = [m_aryAvailableStation objectAtIndex:iIndex];
            [dicAvailable removeObjectForKey:strStationName];
            [m_aryAvailableStation replaceObjectAtIndex:iIndex withObject:dicAvailable];
            [optimization _setRobotCurrentLocation:currentStation.StationPosition];
        
            [self HandleMLBTestOverofStation:strStationName ofClient:currentStation ofIndex:iIndex];
        }
        else
        {
            //put the units on fixture and start test
            fDistance = [[m_dicReturnValue objectForKey:@"Distance"]floatValue];
            float fSleepTime = [self CalculateSpend:fDistance];
            [LogManager creatAndWriteRobotLog:[NSString stringWithFormat:@"Go To Station : %@ ",strStationName]];
            usleep(fSleepTime);

            NSDictionary *dicTemp = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],OPTIMIZATION_ROBOT_PUTNEWMLB,[NSString stringWithFormat:@"%@",strStationName],@"StationName",[NSNumber numberWithInt:iCurrentAtHandCount],@"InputCount", nil];

            [self PutMLBOnStation:strStationName Client:currentStation forSleep:0 ofIndex:iIndex];
            [nc postNotificationName:BNRPostStartNotification object:self userInfo:dicTemp];
            [m_dicBusyStation setObject:currentStation forKey:strStationName];
            NSMutableDictionary *dicAvailable = [m_aryAvailableStation objectAtIndex:iIndex];
            [dicAvailable removeObjectForKey:strStationName];
            [m_aryAvailableStation replaceObjectAtIndex:iIndex withObject:dicAvailable];
            iCurrentAtHandCount = 0;
            [optimization _setRobotCurrentLocation:currentStation.StationPosition];
        }
    }
    [aryTemp release];
    [dicTemp release];
    return YES;

}

//start robot sever and initial some variable, open a thread to running robot
-(void)startRobotServer
{
    [m_aryPassCount removeAllObjects];
    [m_aryFirstFail removeAllObjects];
    [m_arySecondFail removeAllObjects];
    [m_aryFailCount removeAllObjects];
    [m_aryInputMLBCount removeAllObjects];
    [m_aryHasNewMLB removeAllObjects];
    [m_aryFirstFailCount removeAllObjects];
    [m_arySecondFailCount removeAllObjects];
    [m_aryPreviousPass removeAllObjects];
    
    
    for (int i = 0; i < [m_aryStationName count]; i++)
    {
        [m_aryPassCount addObject:[NSNumber numberWithInt:0]];
        [m_aryFirstFail addObject:[NSNumber numberWithInt:0]];
        [m_arySecondFail addObject:[NSNumber numberWithInt:0]];
        [m_aryFailCount addObject:[NSNumber numberWithInt:0]];
        [m_aryInputMLBCount addObject:[NSNumber numberWithInt:0]];
        [m_aryHasNewMLB addObject:[NSNumber numberWithBool:NO]];
        [m_aryFirstFailCount addObject:[NSNumber numberWithInt:0]];
        [m_arySecondFailCount addObject:[NSNumber numberWithInt:0]];
        if (i == 0)
        {
            if (m_iInputMLBNum <= 0)
            {
                [m_aryPreviousPass addObject:[NSNumber numberWithInt:99999]];
            }
            else
                [m_aryPreviousPass addObject:[NSNumber numberWithInt:m_iInputMLBNum]];
        }
        else
            [m_aryPreviousPass addObject:[NSNumber numberWithInt:0]];
    }
    [optimization _setRobotCurrentLocation:NewComerPosition];
    [NSThread detachNewThreadSelector:@selector(Running) toTarget:self withObject:nil];
}

//calculate the cost time
-(float)CalculateSpend:(float)fDistance
{
    float fTime = fDistance/m_fMoveSpeed;
    return fTime*1000*G_SPEED;
}

//handle the message from the client
-(void)HandleMsgFromClient:(NSNotification *)noti
{
   @synchronized(g_szSyncHandleMsg)
    {
        NSString *strName = [[noti userInfo]valueForKey:@"StationName"];
        for (int i = 0; i < [m_aryStationName count]; i++)
        {
            NSString *strStationName = [m_aryStationName objectAtIndex:i];
            NSString *strStation = [NSString stringWithFormat:@"%@", [strStationName substringToIndex:1]];
            if ([strName rangeOfString:strStationName].location != NSNotFound || [strName rangeOfString:strStation].location != NSNotFound)
            {
                NSString *strTestResult = [[noti userInfo]objectForKey:@"Result"];
                NSArray *aryResult = [strTestResult componentsSeparatedByString:@":"];
                [m_dicTestResult setObject:aryResult forKey:strName];
                [LogManager creatAndWriteRobotLog:[NSString stringWithFormat:@"the result of station %@ is %@",strName,strTestResult]];
           
                int iPassCount = [[m_aryPassCount objectAtIndex:i]intValue];
                int iSecondFail = [[m_arySecondFail objectAtIndex:i]intValue];
                int iFail = [[m_aryFailCount objectAtIndex:i]intValue];
                int iFirstFail = [[m_aryFirstFail objectAtIndex:i]intValue];
                for (NSString *strResult in aryResult)
                {
                    if ([strResult isEqualToString:@"FAIL"])
                    {
                        if ([[m_dicFirstFailStations allKeys] containsObject:strName])
                        {
                            [m_dicFirstFailStations setObject:[NSNumber numberWithBool:YES] forKey:strName];
                            iSecondFail++;
                            [LogManager creatAndWriteRobotLog:[NSString stringWithFormat:@"station %@ second fail number : %d",strStationName,iSecondFail]];
                        }
                        else if([[m_dicSecondFailStations allKeys] containsObject:strName])
                        {
                            [m_dicSecondFailStations setObject:[NSNumber numberWithBool:YES] forKey:strName];
                            iFail++;
                            [LogManager creatAndWriteRobotLog:[NSString stringWithFormat:@"station %@ fail number : %d",strStationName,iFail]];

                        }
                        else
                        {
                            
                            iFirstFail++;
                            [LogManager creatAndWriteRobotLog:[NSString stringWithFormat:@"station %@ first fail number : %d",strStationName,iFirstFail]];

                        }
                    }
                    else if([strResult isEqualToString:@"PASS"])
                    {
                        iPassCount++;
                        [LogManager creatAndWriteRobotLog:[NSString stringWithFormat:@"station %@ pass number %d",strStationName,iPassCount]];
//                        NSLog(@"station %@ pass number %d",strStationName,iPassCount);
                    }
                }
                    [m_aryPassCount replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:iPassCount]];
                     [m_aryFirstFail replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:iFirstFail]];
                    [m_arySecondFail replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:iSecondFail]];
                    [m_aryFailCount replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:iFail]];
                    NSMutableDictionary *dicAvaiable = [m_aryAvailableStation objectAtIndex:i];
                    [dicAvaiable setValue:[m_dicBusyStation objectForKey:strName] forKey:strName];
                    [m_aryAvailableStation replaceObjectAtIndex:i withObject:dicAvaiable];
                    [m_arrFinishStation addObject:strName];
                    [m_dicBusyStation removeObjectForKey:strName];               
            }
        }
    }
}

-(void)setRobotLocation:(NSString *)strLocation
{
    NSArray *aryTemp = [strLocation componentsSeparatedByString:@","];
    CurrentPosition.X = [[aryTemp objectAtIndex:0]floatValue];
    CurrentPosition.Y = [[aryTemp objectAtIndex:1]floatValue];
    CurrentPosition.Z = [[aryTemp objectAtIndex:2]floatValue];
}

-(void)setFailAreaLocation:(NSString *)strLocation
{
    NSArray *aryTemp = [strLocation componentsSeparatedByString:@","];
    FailPosition.X = [[aryTemp objectAtIndex:0]floatValue];
    FailPosition.Y = [[aryTemp objectAtIndex:1]floatValue];
    FailPosition.Z = [[aryTemp objectAtIndex:2]floatValue];
}

-(void)setUntestAreaLocation:(NSString *)strLocation
{
    NSArray *aryTemp = [strLocation componentsSeparatedByString:@","];
    NewComerPosition.X = [[aryTemp objectAtIndex:0]floatValue];
    NewComerPosition.Y = [[aryTemp objectAtIndex:1]floatValue];
    NewComerPosition.Z = [[aryTemp objectAtIndex:2]floatValue];
}

@end
