//
//  AppDelegate.h
//  ParserLog
//
//  Created by Andre Jia on 13-1-8.
//  Copyright (c) 2013年 Mei Zhi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#import "define.h"

//QTx auto test system
#import "AppleTestStationControl/AppleTestStationControl.h"
#import "eTraveler/eTravelerParameterKeys.h"
#import "eTraveler/eTraveler_TestResult.h"
#import "NSStringCategory.h"

#define QTxLOGPATH @"/vault/Client/"
#define MAX_LISTEN  10
#define BUFF_SIZE   300
static NSString * LOCK = @"";

#define LOGPATH @"/vault/ParserLog.log"

extern NSString * const SENDRESULTTOROBOT;
extern NSString * const SENDMESSGAETOROBOT;
extern NSString * const FINISHPARSER;
extern NSString * const CHANGETOTESTING;


@interface AppDelegate : NSObject <NSApplicationDelegate, HWTEStationRosterDelegate, HWTEStationDelegate>
{
    IBOutlet NSWindow *window;
    
    //QTx auto test system
    HWTEStationRoster           *m_HWTEStationRoster;
    HWTEStation                 *m_HWTEStation;
    NSMutableArray              *m_arrPorts;
    NSMutableArray              *m_arrStatus;
    NSMutableArray              *m_arrExpectedResponse;
    BOOL                        m_bRemoteControl;
    int                         m_iRobotPort;
    int                         m_iAck_Timeout;
    int                         m_iSlot_NO;
    int                         m_iRetry_Times;
    NSString                    *m_szRobotIP;
    // Tx
    NSString *m_Tx_Initial;
    NSString *m_Tx_Start;
    NSString *m_Tx_PASS_Result;
    NSString *m_Tx_FAIL_Result;
    NSString *m_Tx_Empty_Status;
    NSString *m_Tx_Testing_Status;
    NSString *m_Tx_Complete_Status;
    NSString *m_Tx_Error_Result;
    NSString *m_Tx_Error_Status;
    // Rx
    NSString *m_Rx_Controller_Init;
    NSString *m_Rx_Start_To_Test;
    NSString *m_Rx_Device_Removed;
    NSString *m_Rx_Query;
    NSString *szStationID;
    NSString *szStationType;
    IBOutlet    NSTextField *QTxIP;
    IBOutlet    NSTextField *QTxPort;
    IBOutlet    NSTextField *QTxSlotN;
    IBOutlet    NSTextField *QTxStationID;
    IBOutlet    NSTextField *QTxListenPort;
}

#pragma mark - +++++++++++++++++++  QTx auto test system  +++++++++++++++++++ -
- (void)writeLog:(NSString*)szInfo WithSlotID:(NSString*)szSlotID;
- (BOOL)sendMsg:(NSString*)szMessage forSlot:(NSString*)szSlotID RetryTimes:(int)iRetryTimes;
- (void)sendToRobot:(NSString*)szInfo forSlot:(NSString*)szSlotID WithSocket:(int)iSocket RetryTimes:(int)iRetryTimes;
- (void)thread_Ack_Timeout;
- (void)ListenOnPort:(NSNumber*)Port;
- (void)handleMessage:(NSDictionary*)dicInfo;
- (BOOL)change_Status_To:(NSString*)now_Status ForSlotID:(NSString*)szSlotID WithISN:(NSString*)szISN AndResultInfo:(NSString*)szResultInfo;
- (NSString*)get_SlotID_From_Message:(NSString*)szMsg;

@end
