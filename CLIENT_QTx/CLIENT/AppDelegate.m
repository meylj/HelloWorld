//
//  AppDelegate.m
//  ParserLog
//
//  Created by Andre Jia on 13-1-8.
//  Copyright (c) 2013年 Mei Zhi. All rights reserved.
//

#import "AppDelegate.h"

#define	ATSDebug(...) [self writeLog:[NSString stringWithFormat:__VA_ARGS__]]

NSString * const WriteLock              = @"WriteLock";
NSString * const SendResultLock         = @"SendResultLock";
NSString * const FinishParserLock       = @"FinishParserLock";
NSString * const ParserLock             = @"ParserLock";

@implementation AppDelegate

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //QT auto test system
    [m_HWTEStationRoster release];
    [m_arrPorts release];
    [m_arrStatus release];
    [m_arrExpectedResponse release];
    [m_szRobotIP release];
    [m_Tx_Initial release];
    [m_Tx_Start release];
    [m_Tx_PASS_Result release];
    [m_Tx_FAIL_Result release];
    [m_Tx_Empty_Status release];
    [m_Tx_Testing_Status release];
    [m_Tx_Complete_Status release];
    [m_Tx_Error_Result release];
    [m_Tx_Error_Status release];
    [m_Rx_Controller_Init release];
    [m_Rx_Start_To_Test release];
    [m_Rx_Device_Removed release];
    [m_Rx_Query release];
    [szStationID release];
    
    [super dealloc];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    m_HWTEStationRoster = [HWTEStationRoster sharedRoster];
    [m_HWTEStationRoster retain];
    [m_HWTEStationRoster setDelegate:self];
    
    NSDictionary    *dicSocketSet   = [[NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/Library/Preferences/ATS_Socket.plist", NSHomeDirectory()]] objectForKey:kUserDefaultSocket];
    m_iRobotPort = [[dicSocketSet objectForKey:kUserDefaultSocket_Robot_Port] intValue];
    m_szRobotIP = [[dicSocketSet objectForKey:kUserDefaultSocket_Robot_IP] retain];
    m_iAck_Timeout = [[dicSocketSet objectForKey:kUserDefaultSocket_Ack_Timeout] intValue];
    m_iRetry_Times = [[dicSocketSet objectForKey:Retry_Times] intValue];
    
    [QTxIP setStringValue:m_szRobotIP];
    [QTxPort setStringValue:[NSString stringWithFormat:@"%d", m_iRobotPort]];
    
    NSDictionary *dicSend = [dicSocketSet objectForKey:kUserDefaultSocket_Send];
    m_Tx_Initial = [[dicSend objectForKey:@"Initial"] retain];
    m_Tx_Start = [[dicSend objectForKey:@"Start"] retain];
    m_Tx_PASS_Result = [[dicSend objectForKey:@"PASS_Result"] retain];
    m_Tx_FAIL_Result = [[dicSend objectForKey:@"FAIL_Result"] retain];
    m_Tx_Empty_Status = [[dicSend objectForKey:@"Empty_Status"] retain];
    m_Tx_Testing_Status = [[dicSend objectForKey:@"Testing_Status"] retain];
    m_Tx_Complete_Status = [[dicSend objectForKey:@"Complete_Status"] retain];
    m_Tx_Error_Status = [[dicSend objectForKey:@"Error_Status"] retain];
    m_Tx_Error_Result = [[dicSend objectForKey:@"ERROR_Result"] retain];
    
    NSDictionary *dicReceive = [dicSocketSet objectForKey:kUserDefaultSocket_Receive];
    m_Rx_Controller_Init = [[dicReceive objectForKey:@"Controller_Initial"] retain];
    m_Rx_Start_To_Test = [[dicReceive objectForKey:@"Start_To_Test"] retain];
    m_Rx_Device_Removed = [[dicReceive objectForKey:@"Device_Removed"] retain];
    m_Rx_Query = [[dicReceive objectForKey:@"Query"] retain];
}

#pragma mark - +++++++++++++++++++  QTx auto test system  +++++++++++++++++++ -
// auto test system

- (void)stationAppeared:(HWTEStation *)station
{
    NSLog(@"[%@] station online", station);
    
    [m_HWTEStation release];
    m_HWTEStation   = [station retain];
    [m_HWTEStation setDelegate:self];
    
    szStationID = [[NSString stringWithFormat:@"%@", [station stationName]] retain];
    NSLog(@"%@--%@", szStationID, [station stationName]);
    m_iSlot_NO      = [[station numberOfSlots] intValue];
    szStationType   = [[station stationClass] retain];
    NSString    *szAppearedInfo    = [NSString stringWithFormat:@"The start info is as below:\nStationName: [%@]\nStationTpye: [%@]\nSlotNO: [%d]", szStationID, szStationType, m_iSlot_NO];
    [self writeLog:szAppearedInfo WithSlotID:@"HWTE.log"];
    [QTxStationID setStringValue:[NSString stringWithFormat:@"%@",szStationID]];
    [QTxSlotN setStringValue:[NSString stringWithFormat:@"%d", m_iSlot_NO]];
    /*****************************************************************************************
     - +++++++++++++++++++++++++++++++ QTx auto test system +++++++++++++++++++++++++++++++ -
     *****************************************************************************************/
    
    m_arrStatus = [[NSMutableArray alloc] init];
    m_arrExpectedResponse = [[NSMutableArray alloc] init];
    
//    m_arrPorts = [[NSMutableArray alloc] initWithArray:arrPorts copyItems:YES];
    NSDictionary    *dicSocketSet   = [[NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/Library/Preferences/ATS_Socket.plist", NSHomeDirectory()]] objectForKey:kUserDefaultSocket];
    int iListenPort = [[dicSocketSet objectForKey:kUserDefaultSocket_Listen_Port] intValue];
    [QTxListenPort setStringValue:[NSString stringWithFormat:@"%d", iListenPort]];

    // auto test system (add Objects)
    for (int i=0; i<m_iSlot_NO; i++)
    {
        NSMutableString *szEmptyStatus = [NSMutableString stringWithString:m_Tx_Empty_Status];
        [szEmptyStatus replaceOccurrencesOfString:@"@ATS" withString:[NSString stringWithFormat:@"%d", i] options:NSCaseInsensitiveSearch range:NSMakeRange(0, [szEmptyStatus length])];
        [m_arrStatus addObject:szEmptyStatus];
    }

    // Listen
    [NSThread detachNewThreadSelector:@selector(ListenOnPort:) toTarget:self withObject:[NSNumber numberWithInt:iListenPort]];
    [NSThread detachNewThreadSelector:@selector(thread_Ack_Timeout) toTarget:self withObject:nil];
    
    //need to modify
    //move this to the function '- (void) stationAppeared : (HWTEStation *)station', after received the initial info from station, then send the Msg to Robot
    NSString *szInitial = [NSString stringWithFormat:@"%@%@", m_Tx_Initial, szStationID];
    
    if (![self sendMsg:szInitial forSlot:@"LogWithoutUnit.log" RetryTimes:m_iRetry_Times])
    {
        NSRunAlertPanel(@"Warning",
                        @"无法连接远程服务器。请确认网线插好以及服务器ip设置正确",
                        @"确认(OK)", nil, nil);
    }
}

- (void)stationDied:(HWTEStation *)station reason:(HWTEForensicReport *)deathReason
{
    NSLog(@"[%@] station offline", station);
}

- (void)station:(HWTEStation *)station finishedWithResults:(NSArray *)travelers
{
    if ([travelers count] > 0)
    {
        NSDictionary    *dicResult      = [travelers objectAtIndex:0];
        NSString        *szResult       = [dicResult objectForKey:eTraveler_TestResultKey];
        NSString        *szSlotID       = [dicResult objectForKey:eTraveler_TrayIDKey];
        if (nil != szResult && nil != szSlotID)
        {
            if ([szResult isEqualToString:@"Empty"])
            {
                if ([self change_Status_To:m_Tx_Empty_Status ForSlotID:szSlotID WithISN:@"" AndResultInfo:@""])
                {
                    [self writeLog:@"Change the stauts to Empty success!" WithSlotID:szSlotID];
                }
                @synchronized(m_arrStatus)
                {
                    NSMutableString *szStatusOfASlot = [[NSMutableString alloc] initWithString:[m_arrStatus objectAtIndex:[szSlotID intValue]]];
                    [szStatusOfASlot setString:[m_arrStatus objectAtIndex:[szSlotID intValue]]];
                    [szStatusOfASlot appendString:szStationID];
                    [self sendMsg:szStatusOfASlot forSlot:szSlotID RetryTimes:m_iRetry_Times];
                    [szStatusOfASlot release];
                }
            }
            else if ([szResult isEqualToString:@"Error"])
            {
                @synchronized(m_arrStatus)
                {
                    NSMutableString *szStatusOfASlot = [[NSMutableString alloc] initWithString:[m_arrStatus objectAtIndex:[szSlotID intValue]]];
                    [szStatusOfASlot setString:[m_arrStatus objectAtIndex:[szSlotID intValue]]];
                    [szStatusOfASlot appendString:szStationID];
                    [self sendMsg:szStatusOfASlot forSlot:szSlotID RetryTimes:m_iRetry_Times];
                    [szStatusOfASlot release];
                }
            }
            else
            {
                NSString        *szFinishInfo   = [NSString stringWithFormat:@"The station result info is as below:\nTestResult:[%@]\nSlotID:[%@]", szResult, szSlotID];
                [self writeLog:szFinishInfo WithSlotID:@"HWTE.log"];
                [self sendMsg:szResult forSlot:szSlotID RetryTimes:m_iRetry_Times];
                NSArray *arrResultInfo = [szResult componentsSeparatedByString:@":"];
                NSString *szISN = [arrResultInfo objectAtIndex:3];
                NSString *szResultP1 = [arrResultInfo objectAtIndex:4];
                NSString *szResultP2 = [arrResultInfo objectAtIndex:5];
                NSString *szResultInfo = @"";
                if (![szResultP2 isEqualToString:@"Station ID"])
                {
                    szResultInfo = [NSString stringWithFormat:@"%@:%@", szResultP1, szResultP2];
                }
                else
                {
                    szResultInfo = szResultP1;
                }
                
                if ([[arrResultInfo objectAtIndex:0] isEqualToString:@"Error"])// Error Status
                {
                    if ([self change_Status_To:m_Tx_Error_Status ForSlotID:szSlotID WithISN:szISN AndResultInfo:szResultInfo])
                    {
                        [self writeLog:@"Change the stauts to Error sucess!" WithSlotID:szSlotID];
                    }
                }
                else// Complete Status
                {
                    if ([self change_Status_To:m_Tx_Complete_Status ForSlotID:szSlotID WithISN:szISN AndResultInfo:szResultInfo])
                    {
                        [self writeLog:@"Change the stauts to Complete sucess!" WithSlotID:szSlotID];
                    }
                }
            }
        }
        else
        {
            NSLog(@"Can not get the result or slotID from station!");
            [self writeLog:@"Can not get the test result from station!" WithSlotID:@"HWTE.log"];
        }
    }
    else
    {
        [self writeLog:[NSString stringWithFormat:@"The traveller is null!"] WithSlotID:@"HWTE.log"];
    }
}

- (void)writeLog:(NSString*)szInfo WithSlotID:(NSString*)szSlotID
{
    @synchronized(LOCK)
    {
        szInfo = (NSString*)szInfo;
        
        NSString *szDate = [[NSDate date] descriptionWithCalendarFormat:@"%m/%d %H:%M:%S.%F" timeZone:nil locale:nil];
        szInfo = [NSString stringWithFormat:@"[%@] %@\n",szDate, szInfo];
        
//        NSLog(@"%@", szInfo);
        
        // LOG ON DISK
        NSFileManager *fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath:QTxLOGPATH])
        {
            [fm createDirectoryAtPath:QTxLOGPATH withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        NSString *szFileName = @"";
        if ([szSlotID isEqualToString:@"LogWithoutUnit.log"])
        {
            szFileName  = @"LogWithoutUnit.log";
        }
        else if ([szSlotID isEqualToString:@"HWTE.log"])
        {
            szFileName  = @"HWTE.log";
        }
        else
        {
            szFileName  = [NSString stringWithFormat:@"Slot%@.log",szSlotID];
        }
        
        NSString *szPath = [NSString stringWithFormat:@"%@%@", QTxLOGPATH, szFileName];
        NSFileHandle *h_Log = [NSFileHandle fileHandleForWritingAtPath:szPath];
        if (!h_Log)
        {
            [szInfo writeToFile:szPath atomically:NO encoding:NSUTF8StringEncoding error:nil];
        }
        else
        {
            NSData *dataTemp = [[NSData alloc] initWithBytes:[szInfo UTF8String] length:[szInfo length]];
            [h_Log seekToEndOfFile];
            [h_Log writeData:dataTemp];
            [dataTemp release];
            [h_Log closeFile];
        }
    }
}

- (BOOL)sendMsg:(NSString*)szMessage forSlot:(NSString*)szSlotID RetryTimes:(int)iRetryTimes
{
    @synchronized(self)
    {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        szMessage = (NSString*)szMessage;
        if (!szMessage && [szMessage isEqualToString:@""])
        {
            NSString *szLogInfo = @"Send Message is NIL";
            [self writeLog:szLogInfo WithSlotID:szSlotID];
            return NO;
        }
        
        int iClientSocket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
        if (iClientSocket == -1)
        {
            [self writeLog:@"Create Socket Error" WithSlotID:@"LogWithoutUnit.log"];
            return NO;
        }
        
        // Connect to IP
        struct sockaddr_in server_addr;
        socklen_t server_size = sizeof(server_addr);
        memset(&server_addr, 0, server_size);
        
        server_addr.sin_family  = AF_INET;
        server_addr.sin_port    = htons(m_iRobotPort);
        server_addr.sin_addr.s_addr = inet_addr([m_szRobotIP UTF8String]);
        
        int iCount = 0;
        while (connect(iClientSocket, (struct sockaddr*)&server_addr, server_size) == -1)
        {
            [self writeLog:@"Can not connect to Robot" WithSlotID:szSlotID];
            iCount++;
            if (iCount > 2)
            {
                [self writeLog:@"Connect 2 times" WithSlotID:szSlotID];
                close(iClientSocket);
                //                iClientSocket = -1;
                return NO;
            }
            sleep(1);
        }
        
        NSString *szInfo = [NSString stringWithFormat:@"Connect OK for Slot %@ With Socket:%d", szSlotID, iClientSocket];
        [self writeLog:szInfo WithSlotID:szSlotID];//3rd
        
        assert(szMessage!=nil);
        //[self writeLog:szMessage WithSlotID:szSlotID];
        
        NSString *szDate = [[NSDate date] descriptionWithCalendarFormat:@"%Y-%m-%d %H-%M-%S.%F" timeZone:nil locale:nil];
        NSString *szMsgWithEnd = nil;
        if ([szMessage rangeOfString:@"_Ack"].location != NSNotFound)
        {
            szMsgWithEnd = [NSString stringWithFormat:@"%@%@", szMessage, Socket_End_Symbol];
        }
        else
        {
            szMsgWithEnd = [NSString stringWithFormat:@"[%@]%@%@", szDate, szMessage, Socket_End_Symbol];
        }
        
        //szInfo = [NSString stringWithFormat:@"Send %@", szMsgWithEnd];
        //[self writeLog:szInfo WithSlotID:szSlotID];
        
        [self sendToRobot:szMsgWithEnd forSlot:szSlotID WithSocket:iClientSocket RetryTimes:iRetryTimes];
        
        [pool drain];
        pool = nil;
    }
    return YES;
}

- (void)sendToRobot:(NSString*)szInfo forSlot:(NSString*)szSlotID WithSocket:(int)iSocket RetryTimes:(int)iRetryTimes
{
    @synchronized(self)
    {
        NSData *data = [NSData dataWithBytes:[szInfo UTF8String] length:[szInfo length]];
        if (data == nil)
        {
            [self writeLog:@"szInfo is not a UTF8String" WithSlotID:szSlotID];
            return;
        }
        
        BOOL bFlag = YES;
        @try {
            if ([szInfo rangeOfString:@"Ack"].location == NSNotFound)
            {
                if ([szSlotID isEqualToString:@"LogWithoutUnit.log"])
                {
                    szSlotID = @"0";
                }
                NSString *szInfoWithoutEnd = [[szInfo componentsSeparatedByString:@"#"] objectAtIndex:0];
                NSString *szExpected = [NSString stringWithFormat:@"%@_Ack", szInfoWithoutEnd];
                NSDate *dateAdd = [NSDate date];
                NSMutableDictionary *dicExpectedInfo = [[NSMutableDictionary alloc] initWithDictionary:
                                                        [NSDictionary dictionaryWithObjectsAndKeys:szExpected, @"Expected", dateAdd, @"Date", [NSNumber numberWithInt:iRetryTimes], @"Retry_Times", nil]];
                @synchronized(m_arrExpectedResponse)
                {
                    [m_arrExpectedResponse addObject:dicExpectedInfo];
                    NSLog(@"Expected ARRAY: %@", m_arrExpectedResponse);
                }
            }
            
            write(iSocket, [szInfo UTF8String], [szInfo length]);
            assert(szInfo!=nil);
            NSString *szSuccess = [NSString stringWithFormat:@"Send Success:%@",szInfo];
            [self writeLog:szSuccess WithSlotID:szSlotID];
            
            close(iSocket);
            NSString *szLogInfo = [NSString stringWithFormat:@"Disconnect Socket: %d", iSocket];
            [self writeLog:szLogInfo WithSlotID:szSlotID];//3rd
        }
        @catch (NSException *exception) {
            [self writeLog:[NSString stringWithFormat:@"%@: %@",exception.name, exception.reason] WithSlotID:szSlotID];
            [m_arrExpectedResponse removeObjectAtIndex:0];
            bFlag = NO;
        }
        @finally {
            
        }
    }
}

- (void)thread_Ack_Timeout
{
    while (1)
    {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        NSDate *dateNow = [NSDate date];
        
        @synchronized(m_arrExpectedResponse)
        {
            for (int i=[m_arrExpectedResponse count]-1; i>=0; i--)
            {
                NSMutableDictionary *dicExpectInfo = nil;
                dicExpectInfo = [m_arrExpectedResponse objectAtIndex:i];
                NSDate *dateBefore = [dicExpectInfo objectForKey:@"Date"];
                NSTimeInterval dTimePassed = [dateNow timeIntervalSinceDate:dateBefore];
                if (dTimePassed > m_iAck_Timeout)
                {
                    NSString *szExpected = [dicExpectInfo objectForKey:@"Expected"];
                    // Decrease Remain times
                    int iRemainTimes = [[dicExpectInfo objectForKey:@"Retry_Times"] intValue];
                    [dicExpectInfo setValue:[NSDate date] forKey:@"Date"];
                    NSString *szLogInfo = [NSString stringWithFormat:@"Timeout at Expecting: %@, Remain Times: %d", szExpected, iRemainTimes];
                    [self writeLog:szLogInfo WithSlotID:@"LogWithoutUnit.log"];
                    if (iRemainTimes == 0)
                    {
                        szLogInfo = [NSString stringWithFormat:@"Fail for Receiving: %@", szExpected];
                        [self writeLog:szLogInfo WithSlotID:@"LogWithoutUnit.log"];
                        //NSRunAlertPanel(@"Error", szLogInfo, @"OK", nil, nil); // If stop here, too many alert panel will cause muifa crash
                        [[m_arrExpectedResponse objectAtIndex:i] release];// release
                        [m_arrExpectedResponse removeObjectAtIndex:i];
                    }
                    else
                    {
                        iRemainTimes--;
                        [dicExpectInfo setValue:[NSNumber numberWithInt:iRemainTimes] forKey:@"Retry_Times"];
                        
                        //resend
                        NSMutableString *szTempMsg = [NSMutableString stringWithString:szExpected];
                        NSString *szOriginMsg = [szTempMsg substringToIndex:[szExpected rangeOfString:@"_Ack"].location];
                        szOriginMsg = [NSString stringWithFormat:@"%@#", szOriginMsg];
                        [self writeLog:[NSString stringWithFormat: @"Resend Message:%@",szOriginMsg] WithSlotID:@"LogWithoutUnit.log"];
                        
                        int iClientSocket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
                        
                        struct sockaddr_in server_addr;
                        socklen_t server_size = sizeof(server_addr);
                        memset(&server_addr, 0, server_size);
                        
                        server_addr.sin_family  = AF_INET;
                        server_addr.sin_port    = htons(m_iRobotPort);
                        server_addr.sin_addr.s_addr = inet_addr([m_szRobotIP UTF8String]);
                        
                        if(connect(iClientSocket, (struct sockaddr*)&server_addr, server_size) != -1)
                        {
                            @try {
                                write(iClientSocket, [szOriginMsg UTF8String], [szOriginMsg length]);
                            }
                            @catch (NSException *exception) {
                            }
                            @finally {
                            }
                        }
                        else
                        {
                            [self writeLog:@"Resend Connect Error" WithSlotID:@"LogWithoutUnit.log"];
                        }
                    }
                    
                    NSLog(@"Expected ARRAY: %@",m_arrExpectedResponse);
                }
            }
        }
        sleep(1);
        [pool drain];
        pool = nil;
    }
}

- (void)ListenOnPort:(NSNumber*)Port//V1.5
{
//    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//    [nc addObserver:self selector:@selector(test_finished:) name:TEST_FINISHED object:nil];
    
    int iPort = [Port intValue];
    int iListenSocket = socket(AF_INET, SOCK_STREAM, 0);
    if (iListenSocket == -1)
    {
        [self writeLog:@"Create Listen Socket Error" WithSlotID:@"LogWithoutUnit.log"];
    }
    
    struct sockaddr_in server_addr;
    socklen_t server_size = sizeof(server_addr);
    memset(&server_addr, 0, server_size);
    
    server_addr.sin_family  = AF_INET;
    server_addr.sin_port    = htons(iPort);
    server_addr.sin_addr.s_addr = htonl(INADDR_ANY);//??
    
    // bind to server port
    if (bind(iListenSocket, (struct sockaddr *)&server_addr, sizeof(server_addr)) == -1)
    {
        [self writeLog:@"Bind To Port Fail" WithSlotID:@"LogWithoutUnit.log"];
        return;
    }
    
    if (listen(iListenSocket, SOMAXCONN) == -1)
    {
        [self writeLog:@"Listen Fail" WithSlotID:@"LogWithoutUnit.log"];
        return;
    }
    
    // Create 2 Array
    int iArrConnectSockets[MAX_LISTEN];
    BOOL bArrConnectStatus[MAX_LISTEN];
    int iConnectedCount = 0;
    for (int i=0; i<MAX_LISTEN; i++)
    {
        bArrConnectStatus[i] = false;
        iArrConnectSockets[i] = -1;
    }
    
    int h = 0;
    fd_set fs;
    struct timeval tv = {0,0};
    char buff[BUFF_SIZE];
    while (1)
    {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        FD_ZERO(&fs);
        int maxfs = 0;
        for (int i=0; i<MAX_LISTEN; i++)
        {
            if(bArrConnectStatus[i])
            {
                FD_SET(iArrConnectSockets[i], &fs);
                if (iArrConnectSockets[i] > maxfs)
                {
                    maxfs = iArrConnectSockets[i];
                }
            }
        }
        FD_SET(iListenSocket, &fs);
        if (maxfs < iListenSocket)
        {
            maxfs = iListenSocket;
        }
        
        int iServerSocket = -1;
        if (select(maxfs+1, &fs, NULL, NULL, &tv)>0)
        {
            if (FD_ISSET(iListenSocket, &fs))
            {
                if ((iServerSocket = accept(iListenSocket, (struct sockaddr *)NULL, NULL)) == -1)
                {
                    [self writeLog:@"Accept Fail" WithSlotID:@"LogWithoutUnit.log"];
                    close(iServerSocket);
                    //                    iServerSocket = -1;
                    continue;
                }
                
                // just for sorting
                for (h=0; h<MAX_LISTEN; h++)
                {
                    if (!bArrConnectStatus[h])
                    {
                        break;
                    }
                }
                
                iArrConnectSockets[h] = iServerSocket;
                bArrConnectStatus[h] = true;
                iConnectedCount++;
                
                if (iConnectedCount >= MAX_LISTEN)
                {
                    [self writeLog:@"Reach Max Listen" WithSlotID:@"LogWithoutUnit.log"];
                    close(iServerSocket);
                    //                    iServerSocket = -1;
                    continue;
                }
                
                assert(iServerSocket!=-1&&h>=0&&h<10);
                NSLog(@"Accept: %d Index: %d", iServerSocket, h);
            }
            
            for (int j=0; j<iConnectedCount; j++)
            {
                if (!bArrConnectStatus[j])
                {
                    continue;
                }
                if (FD_ISSET(iArrConnectSockets[j], &fs))
                {
                    memset(buff, 0, sizeof(buff));
                    int n = recv(iArrConnectSockets[j], buff, BUFF_SIZE, 0);
                    if (n<=0)
                    {
                        NSLog(@"Robot Disconnected Socket: %d Index: %d",iArrConnectSockets[j], j);
                        close(iArrConnectSockets[j]);
                        iArrConnectSockets[j] = -1;
                        bArrConnectStatus[j] = false;
                        iConnectedCount --;
                    }
                    else
                    {
                        NSString *strMsg = [NSString stringWithUTF8String:buff];
                        NSDictionary *dicInfo = [NSDictionary dictionaryWithObjectsAndKeys:strMsg,@"Message",[NSNumber numberWithInt:iArrConnectSockets[j]],@"Socket", nil];
                        [NSThread detachNewThreadSelector:@selector(handleMessage:) toTarget:self withObject:dicInfo];
                    }
                }
            }
            
        }
        [pool drain];
        pool = nil;
    }
}

- (void)handleMessage:(NSDictionary*)dicInfo
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString *strMsg = [dicInfo objectForKey:@"Message"];
    //int iSocket = [[dicInfo objectForKey:@"Socket"] intValue];
    NSString *szStationIDMsg = [NSString stringWithFormat:@":Station ID:%@", szStationID];
    
    if ([strMsg length] > 0)
    {
        NSString *szMsg = strMsg;
        NSString *szMessage = [NSString stringWithFormat:@"Receive from robot: %@",strMsg];;
        [self writeLog:szMessage WithSlotID:@"LogWithoutUnit.log"];
        NSLog(@"%@", szMessage);
        
        NSArray *arrMsg = [szMsg componentsSeparatedByString:Socket_End_Symbol];
        for (int i=0; i<[arrMsg count]-1; i++)
        {
            szMsg = [arrMsg objectAtIndex:i];
            NSString *szInfo = nil;//[NSString stringWithFormat:@"Receive Message:%@", szMsg];
            NSString *szSlotID = @"LogWithoutUnit.log";
            
            // Judge Message Format and Get SlotID
            if (/*[szMsg rangeOfString:@"Ack"].location == NSNotFound &&*/ [szMsg rangeOfString:@"Station Initial OK"].location == NSNotFound)
            {
                szSlotID = [self get_SlotID_From_Message:szMsg];
            }
            if (szSlotID == nil)
            {
                NSString *szErr = [NSString stringWithFormat:@"[ERR] Illegal Message: %@", szMsg];
                [self writeLog:szErr WithSlotID:@"LogWithoutUnit.log"];
                continue;
            }
            //[self writeLog:szInfo WithSlotID:szSlotID];
            
            // Is Ack Msg: Judge expected or not
            // Not Ack Msg: Return an Ack Msg to Server
            if ([szMsg rangeOfString:@"Ack"].location != NSNotFound || [szMsg rangeOfString:@"Station Initial OK"].location != NSNotFound)
            {
                @synchronized(m_arrExpectedResponse)
                {
                    for (int m=[m_arrExpectedResponse count]-1; m>=0; m--)
                    {
                        NSDictionary *dicExpectInfo = [m_arrExpectedResponse objectAtIndex:m];
                        NSString *szExpected = [dicExpectInfo objectForKey:@"Expected"];
                        if ([szExpected isEqualToString:szMsg])
                        {
                            szInfo = [NSString stringWithFormat:@"[Match] Received: %@", szMsg];
                            [self writeLog:szInfo WithSlotID:szSlotID];//2nd
                            [m_arrExpectedResponse removeObjectAtIndex:m];
                            NSLog(@"Expected ARRAY: %@", m_arrExpectedResponse);
                            break;
                        }
                    }
                }
                continue;
            }
            else
            {
                NSString *szAckMsg = nil;
                szAckMsg = [NSString stringWithFormat:@"%@_Ack", szMsg];
                
                [self sendMsg:szAckMsg forSlot:szSlotID RetryTimes:m_iRetry_Times];
            }
            
            // Judge string value and do corresponding action
            if ([szMsg rangeOfString:m_Rx_Start_To_Test].location != NSNotFound)
            {
                // Change Status
                @synchronized(m_arrStatus)
                {
                    NSString *szPre_Status = [m_arrStatus objectAtIndex:[szSlotID intValue]];
                    if ([szPre_Status rangeOfString:@"Testing"].location != NSNotFound)
                    {
                        NSLog(@"Already In testing Status, no need to do this again");
                    }
                    else
                    {
                        if (![self change_Status_To:m_Tx_Testing_Status ForSlotID:szSlotID WithISN:@"" AndResultInfo:@""])
                        {
                            continue;
                        }
                        
                        // Send Already Start
                        NSMutableString *szStart = nil;
                        szStart = [m_Tx_Start mutableCopy];
                        [szStart replaceOccurrencesOfString:@"@ATS" withString:szSlotID options:NSCaseInsensitiveSearch range:NSMakeRange(0, [szStart length])];
                        //QT auto test system
                        NSDictionary    *dicStart   = [NSDictionary dictionaryWithObject:szSlotID forKey:eTraveler_TrayIDKey];
                        NSArray *arrStart   = [NSArray arrayWithObject:dicStart];
                        [m_HWTEStation testWithTravelers:arrStart];
                        [self writeLog:szStart WithSlotID:@"HWTE.log"];
                        [szStart appendString:szStationIDMsg];
                        [self sendMsg:szStart forSlot:szSlotID RetryTimes:m_iRetry_Times];
                        
                        [szStart release];
//                        //need to modify
//                        //move this to the function '[m_station testWithTravelers:@[@"TEST"]];', will call the staion's function '-(BOOL) station:(AppleControlledStation *)station startWithTravelers:(NSArray *)travelers'
//                        Template *objTemp = [m_arrTemplateObject objectAtIndex:[szSlotID intValue]];
//                        NSLog(@"Andre Will perform button on %@", szSlotID);
//                        
//                        // Perform Start Button
//                        if ([objTemp.btnStart isEnabled])
//                        {
//                            [objTemp.btnStart performClick:nil];
//                        }
//                        else
//                        {
//                            NSLog(@"Andre Template Index Error on %@",szSlotID);
//                        }
                    }
                }
            }
            else if ([szMsg rangeOfString:m_Rx_Device_Removed].location != NSNotFound)
            {
                @synchronized(m_arrStatus)
                {
                    NSString *szPre_Status = [m_arrStatus objectAtIndex:[szSlotID intValue]];
                    if ([szPre_Status rangeOfString:@"Empty"].location != NSNotFound)
                    {
                        NSLog(@"Andre Already In Empty Status, no need to do this again");
                    }
                    else
                    {
                        [self writeLog:@"Start Device removed!" WithSlotID:@"HWTE.log"];
                        if ([self change_Status_To:m_Tx_Empty_Status ForSlotID:szSlotID WithISN:@"" AndResultInfo:@""])
                        {
                            [self writeLog:@"Device removed sucess!" WithSlotID:@"HWTE.log"];
                        }
                    }
                }
            }
            else if ([szMsg rangeOfString:m_Rx_Query].location != NSNotFound)
            {
                @synchronized(m_arrStatus)
                {
                    NSMutableString *szStatusOfASlot = [[NSMutableString alloc] initWithString:[m_arrStatus objectAtIndex:[szSlotID intValue]]];
                    NSArray *arrStatusOfASlot = [szStatusOfASlot componentsSeparatedByString:@":"];
                    NSString *sz3rdComponent = [arrStatusOfASlot objectAtIndex:2];
                    if ([sz3rdComponent isEqualToString:@"Error"])
                    {
                        // read fixture state
                        NSLog(@"BEGIN read fixture state");
                        NSDictionary    *dicStart   = [NSDictionary dictionaryWithObjectsAndKeys:szSlotID, eTraveler_TrayIDKey, @"Check Fixture", eTraveler_StationProcessIDKey, nil];
                        NSArray *arrStart   = [NSArray arrayWithObject:dicStart];
                        [m_HWTEStation testWithTravelers:arrStart];
                        NSLog(@"END read fixture state");
                    }
                    else
                    {
                        [szStatusOfASlot setString:[m_arrStatus objectAtIndex:[szSlotID intValue]]];
                        [szStatusOfASlot appendString:szStationIDMsg];
                        [self sendMsg:szStatusOfASlot forSlot:szSlotID RetryTimes:m_iRetry_Times];
                        NSLog(@"Status:%@", szStatusOfASlot);
                    }
                    [szStatusOfASlot release];
                }
            }
        }
    }
    else
    {
        [self writeLog:@"Receive 0 data" WithSlotID:@"LogWithoutUnit.log"];
    }
    [pool drain];
    pool = nil;
}

- (BOOL)change_Status_To:(NSString*)now_Status ForSlotID:(NSString*)szSlotID WithISN:(NSString*)szISN AndResultInfo:(NSString*)szResultInfo
{
    NSMutableString *szStatus = [now_Status mutableCopy];
    [szStatus replaceOccurrencesOfString:@"@ATS" withString:szSlotID options:NSCaseInsensitiveSearch range:NSMakeRange(0, [szStatus length])];
    [szStatus replaceOccurrencesOfString:@"XXX" withString:szISN options:NSCaseInsensitiveSearch range:NSMakeRange(0, [szStatus length])];
    [szStatus replaceOccurrencesOfString:@"ResultInfo" withString:szResultInfo options:NSCaseInsensitiveSearch range:NSMakeRange(0, [szStatus length])];
    NSString *szPre_Status = [m_arrStatus objectAtIndex:[szSlotID intValue]];
    
    // Judge if Legal Operation
    if ([szStatus rangeOfString:@"Testing"].location != NSNotFound)
    {
        if ([szPre_Status rangeOfString:@"Empty"].location == NSNotFound)
        {
            NSString *szErr = [NSString stringWithFormat:@"You can not change status %@ when slot %@ status is %@",szStatus, szSlotID,szPre_Status];
            //NSRunAlertPanel(@"Error", szErr, @"OK", nil, nil);
            [self writeLog:szErr WithSlotID:szSlotID];
            [szStatus release];
            return NO;
        }
    }
    else if ([szStatus rangeOfString:@"Empty"].location != NSNotFound)
    {
        if ([szPre_Status rangeOfString:@"Complete"].location == NSNotFound&&[szPre_Status rangeOfString:@"Error"].location == NSNotFound)
        {
            NSString *szErr = [NSString stringWithFormat:@"You can not change status %@ when slot %@ status is %@",szStatus, szSlotID,szPre_Status];
            //NSRunAlertPanel(@"Error", szErr, @"OK", nil, nil);
            [self writeLog:szErr WithSlotID:szSlotID];
            [szStatus release];
            return NO;
        }
    }
    else if ([szStatus rangeOfString:@"Complete"].location != NSNotFound)
    {
        if ([szPre_Status rangeOfString:@"Testing"].location == NSNotFound)
        {
            NSString *szErr = [NSString stringWithFormat:@"You can not change status %@ when slot %@ status is %@",szStatus, szSlotID,szPre_Status];
            //NSRunAlertPanel(@"Error", szErr, @"OK", nil, nil);
            [self writeLog:szErr WithSlotID:szSlotID];
            [szStatus release];
            return NO;
        }
    }
    @synchronized(m_arrStatus)
    {
        [m_arrStatus replaceObjectAtIndex:[szSlotID intValue] withObject:szStatus];
    }
    [szStatus release];
    return YES;
}

- (NSString*)get_SlotID_From_Message:(NSString*)szMsg
{
    NSArray *arrOfMsg = [szMsg componentsSeparatedByString:@":"];
    if ([arrOfMsg count]<2)
    {
        //NSRunAlertPanel(@"Error", @"Illegal Message Format", @"OK", nil, nil);
        [self writeLog:@"Illegal Message Format" WithSlotID:@"LogWithoutUnit.log"];
        return nil;
    }
    
    NSString *szSlot = [arrOfMsg objectAtIndex:1];
    NSRange range_Slot = [szSlot rangeOfString:@"Slot"];
    if (range_Slot.location == NSNotFound)
    {
        //NSRunAlertPanel(@"Error", @"Illegal Message Format", @"OK", nil, nil);
        [self writeLog:@"Illegal Message Format" WithSlotID:@"LogWithoutUnit.log"];
        return nil;
    }
    
    NSString *szSlotID = [szSlot substringFromIndex:range_Slot.location + range_Slot.length];
    NSRange range_Ack = [szSlotID rangeOfString:@"_Ack"];
    if (range_Ack.location != NSNotFound)
    {
        szSlotID = [szSlotID substringToIndex:range_Ack.location];
    }
    
    if ([szSlotID intValue]>=m_iSlot_NO)
    {
        NSString *szErrInfo = [NSString stringWithFormat:@"Total slot is only %d", m_iSlot_NO];
        //NSRunAlertPanel(@"Error", szErrInfo, @"OK", nil,nil);
        [self writeLog:szErrInfo WithSlotID:@"LogWithoutUnit.log"];
        return nil;
    }
    
    return szSlotID;
}

@end
