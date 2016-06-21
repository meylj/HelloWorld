//
//  AppDelegate.m
//  ListenLive
//
//  Created by raniys on 3/31/15.
//  Copyright (c) 2015 raniys. All rights reserved.
//

#import "AppDelegate.h"
#import "NSStringCategory.h"
#import "NSDateCategory.h"
#import "NSPanel+Category.h"
#import "pudding.h"

@interface AppDelegate ()
{
    NSTimer         *m_timer;
    dispatch_queue_t m_queue;
    
    NSDictionary *m_dicPuddingDatas;
    
    pudding     *objPudding;
    
    NSWindowController *newWindowController;
}
@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate
static const char *queueLabel = "com.pegatron.ATS.control_queue";
NSString *m_dicPuddingDatas       = @"";
NSString *m_strLiveVer            = @"";
NSString *m_strLiveCurrent        = @"";
NSString *m_strLiveScheduled      = @"";
NSString *m_strLiveVersionPath    = @"";
NSString *m_strStationId          = @"";
NSString *m_strController         = @"";
BOOL    m_jsonUpdated = NO;
BOOL    m_liveUpdated = NO;


-(instancetype)init
{
    self = [super init];
    if (self)
    {
        objPudding      = [[pudding alloc] init];
        m_queue = dispatch_queue_create(queueLabel, NULL);
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [self StartToListenLive];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    // Insert code here to tear down your application
    
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

-(void)awakeFromNib
{
    [popTimeZone removeAllItems];
    [popTimeZone addItemsWithTitles:[NSTimeZone knownTimeZoneNames]];
    [popTimeZone selectItemWithTitle:@"Asia/Shanghai"];
    [self showTime];
    
    [textViewDisplay setEditable: NO];
}

- (void)StartToListenLive
{
    if ([self getGHJsonInfo:@"/vault/data_collection/test_station_config/gh_station_info.json"])
    {
        NSString *strCurrentTime = [textTimeLabel stringValue];
        if ([m_strLiveVer isEqualToString:@"0"])
            [self showStringToUI:[NSString stringWithFormat:@"\n%@: Live is setting 'OFF' in gh_station_info.json\n\n",strCurrentTime] withColor:[NSColor redColor] toView:textViewDisplay];
        else
            [self showStringToUI:[NSString stringWithFormat:@"\n%@: Live is setting 'ON' in gh_station_info.json\n\n",strCurrentTime] withColor:[NSColor greenColor] toView:textViewDisplay];
        
        NSString *strProductionMode = [m_strController isEqualToString:@"ON"] ? @"control_run" : @"default";
        NSString *strLiveLocaltion = [NSString stringWithFormat:@"%@/%@/%@",m_strLiveVersionPath,m_strLiveCurrent,strProductionMode];
        if ([self liveFileIsExistAt:strLiveLocaltion])
        {
            NSFileManager * fileManager = [NSFileManager defaultManager];
            NSString    *szOriginalName = [fileManager destinationOfSymbolicLinkAtPath:strLiveLocaltion error:nil];
            [self showStringToUI:[NSString stringWithFormat:@"%@: The live file has already existed!",strCurrentTime] withColor:[NSColor greenColor] toView:textViewDisplay];
            NSString    *szOriginalPath  = [NSString stringWithFormat:@"%@/%@/%@",m_strLiveVersionPath,m_strLiveCurrent,szOriginalName];
            [self showStringToUI:[NSString stringWithFormat:@"\nLive Original File Name==>%@\nLive Original File Path==>%@\n\n",szOriginalName,szOriginalPath] withColor:[NSColor grayColor] toView:textViewDisplay];
            dispatch_async(m_queue, ^{
                [self CheckIfTheLiveClosed];
            });
            
        } else {
            [self showStringToUI:[NSString stringWithFormat:@"%@: The live file not found!\n\n",strCurrentTime] withColor:[NSColor redColor] toView:textViewDisplay];
            dispatch_async(m_queue, ^{
                [self startListenForLive];
            });
        }
    }
    //check for json file
    [self monitorForJsonFile:[@"/vault/data_collection/test_station_config/" stringByExpandingTildeInPath]];
    
    //check for live file
    [self monitorForLiveFile:[[NSString stringWithFormat:@"%@/%@",m_strLiveVersionPath,m_strLiveCurrent] stringByExpandingTildeInPath]];
}


-(BOOL)getGHJsonInfo:(NSString *)strJsonPath
{
    BOOL    bReturn = YES;
    m_dicPuddingDatas       = [objPudding loadDataFromJsonFile:strJsonPath];
    m_strLiveVer            = [m_dicPuddingDatas objectForKey:@"LIVE_VERSION"];
    m_strLiveCurrent        = [m_dicPuddingDatas objectForKey:@"LIVE_CURRENT"];
    m_strLiveScheduled      = [m_dicPuddingDatas objectForKey:@"LIVE_SCHEDULED"];
    m_strLiveVersionPath    = [m_dicPuddingDatas objectForKey:@"LIVE_VERSION_PATH"];
    m_strStationId          = [m_dicPuddingDatas objectForKey:@"STATION_ID"];
    m_strController         = [m_dicPuddingDatas objectForKey:@"CONTROL_RUN"];
    if ([m_strLiveVer isEqualToString:@""]
        || m_strLiveVer == nil
        || [m_strLiveCurrent isEqualToString:@""]
        || m_strLiveCurrent == nil
        || [m_strLiveScheduled isEqualToString:@""]
        || m_strLiveScheduled == nil
        || [m_strLiveVersionPath isEqualToString:@""]
        || m_strLiveVersionPath == nil
        || [m_strStationId isEqualToString:@""]
        || m_strStationId == nil
        || [m_strController isEqualToString:@""]
        || m_strController == nil)
    {
        [self popUpError:[NSError errorWithDomain:@"Format error: Cannot get data from gh_station_info.json file."
                                             code:22
                                         userInfo:nil]];
        bReturn = NO;
    }else
       [self showStringToUI:[NSString stringWithFormat:@"Station: %@\nLive version: %@\nLive current: %@\nLive Scheduled: %@\nLive path: %@\n",m_strStationId,m_strLiveVer,m_strLiveCurrent,m_strLiveScheduled,m_strLiveVersionPath] withColor:[NSColor darkGrayColor] toView:textViewDisplay];
    return bReturn;
}


- (BOOL)liveStatusOnGHServer
{
    BOOL    bResult = NO;
    NSString *strLiveStatus = [m_strLiveVer isEqualToString:@"0"] ? @"OFF" : @"ON";
    if ([strLiveStatus isEqualToString:@"ON"])
        bResult = YES;
    return bResult;
}

- (BOOL)liveFileIsExistAt:(NSString *)path
{
    BOOL bResult = NO;
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path])
        bResult = YES;
    return bResult;
}

-(void)startListenForLive
{
    NSString *strGHCurrentTime = [textTimeLabel stringValue];
    [self showStringToUI:[NSString stringWithFormat:@"\n%@: ******Start to check if the live is set 'OPEN' from GH******\n",strGHCurrentTime] withColor:[NSColor darkGrayColor] toView:textViewDisplay];
    while (YES)
    {
        if ([self liveStatusOnGHServer])
        {
            
            strGHCurrentTime = [textTimeLabel stringValue];
            [self showStringToUI:[NSString stringWithFormat:@"\n\nStation: %@\nLive version: %@\nLive current: %@\nLive Scheduled: %@\nLive path: %@\n",m_strStationId,m_strLiveVer,m_strLiveCurrent,m_strLiveScheduled,m_strLiveVersionPath] withColor:[NSColor darkGrayColor] toView:textViewDisplay];
            [self showStringToUI:[NSString stringWithFormat:@"\n%@: Live is setting 'ON' in gh_station_info.json\n",strGHCurrentTime] withColor:[NSColor greenColor] toView:textViewDisplay];
            
            [self showStringToUI:[NSString stringWithFormat:@"\n%@: ******Start to check if the live file is pushed to local disk******\n",strGHCurrentTime] withColor:[NSColor darkGrayColor] toView:textViewDisplay];
            
            
            while (YES)
            {
                NSString *strProductionMode = [m_strController isEqualToString:@"ON"] ? @"control_run" : @"default";
                NSString *strLiveLocaltion = [NSString stringWithFormat:@"%@/%@/%@",m_strLiveVersionPath,m_strLiveCurrent,strProductionMode];
                sleep(1);
                if ([self liveFileIsExistAt:strLiveLocaltion])
                {
                    if (!m_liveUpdated)
                    {
                        NSString *strLiveCurrentTime = [textTimeLabel stringValue];
                        NSFileManager * fileManager = [NSFileManager defaultManager];
                        NSString    *szOriginalName = [fileManager destinationOfSymbolicLinkAtPath:strLiveLocaltion error:nil];
                        [self showStringToUI:[NSString stringWithFormat:@"%@: The live file has already exist, but it is not updated by GH",strLiveCurrentTime] withColor:[NSColor greenColor] toView:textViewDisplay];
                        NSString    *szOriginalPath  = [NSString stringWithFormat:@"%@/%@/%@",m_strLiveVersionPath,m_strLiveCurrent,szOriginalName];
                        [self showStringToUI:[NSString stringWithFormat:@"\nLive Original File Name==>%@\nLive Original File Path==>%@\n",szOriginalName,szOriginalPath] withColor:[NSColor grayColor] toView:textViewDisplay];
                    } else {
                        NSString *strLiveCurrentTime = [textTimeLabel stringValue];
                        NSFileManager * fileManager = [NSFileManager defaultManager];
                        NSString    *szOriginalName = [fileManager destinationOfSymbolicLinkAtPath:strLiveLocaltion error:nil];
                        [self showStringToUI:[NSString stringWithFormat:@"%@: The live file has updated from GH by now!",strLiveCurrentTime] withColor:[NSColor greenColor] toView:textViewDisplay];
                        NSString    *szOriginalPath  = [NSString stringWithFormat:@"%@/%@/%@",m_strLiveVersionPath,m_strLiveCurrent,szOriginalName];
                        [self showStringToUI:[NSString stringWithFormat:@"\nLive Original File Name==>%@\nLive Original File Path==>%@\n",szOriginalName,szOriginalPath] withColor:[NSColor grayColor] toView:textViewDisplay];
                        
                        m_liveUpdated = NO;
                    }
                    dispatch_async(m_queue, ^{
                        [self CheckIfTheLiveClosed];
                    });
                    break;
                } else if (m_liveUpdated) {
                    NSString *strLiveCurrentTime = [textTimeLabel stringValue];
                    [self showStringToUI:[NSString stringWithFormat:@"%@: Live file not found!\n\n",strLiveCurrentTime] withColor:[NSColor redColor] toView:textViewDisplay];
                }
            }
            break;
        }
    }
}


-(void)CheckIfTheLiveClosed
{
    NSString *strGHCurrentTime = [textTimeLabel stringValue];
    [self showStringToUI:[NSString stringWithFormat:@"\n%@: ******Start to check if the live is set 'CLOSE' from GH******\n",strGHCurrentTime] withColor:[NSColor darkGrayColor] toView:textViewDisplay];
    while (YES)
    {
        sleep(1);
        if (m_jsonUpdated)
        {
            m_jsonUpdated = NO;
            strGHCurrentTime = [textTimeLabel stringValue];
            if (![self liveStatusOnGHServer])
            {
                [self showStringToUI:[NSString stringWithFormat:@"\n%@: Live is setting 'OFF' on Groundhog server\n",strGHCurrentTime] withColor:[NSColor redColor] toView:textViewDisplay];
                dispatch_async(m_queue, ^{
                    [self startListenForLive];
                });
                break;
            } else
                [self showStringToUI:[NSString stringWithFormat:@"\n%@: The json file has update, but live is still 'ON' in gh_station_info.json\n",strGHCurrentTime] withColor:[NSColor redColor] toView:textViewDisplay];
            
            NSString *strProductionMode = [m_strController isEqualToString:@"ON"] ? @"control_run" : @"default";
            NSString *strLiveLocaltion = [NSString stringWithFormat:@"%@/%@/%@",m_strLiveVersionPath,m_strLiveCurrent,strProductionMode];
            if ([self liveFileIsExistAt:strLiveLocaltion])
            {
                NSFileManager * fileManager = [NSFileManager defaultManager];
                NSString    *szOriginalName = [fileManager destinationOfSymbolicLinkAtPath:strLiveLocaltion error:nil];
                [self showStringToUI:[NSString stringWithFormat:@"%@: The live file has already existed!",strGHCurrentTime] withColor:[NSColor greenColor] toView:textViewDisplay];
                NSString    *szOriginalPath  = [NSString stringWithFormat:@"%@/%@/%@",m_strLiveVersionPath,m_strLiveCurrent,szOriginalName];
                [self showStringToUI:[NSString stringWithFormat:@"\nLive Original File Name==>%@\nLive Original File Path==>%@\n\n",szOriginalName,szOriginalPath] withColor:[NSColor grayColor] toView:textViewDisplay];
                
            } else
                [self showStringToUI:[NSString stringWithFormat:@"%@: The live file not found!\n\n",strGHCurrentTime] withColor:[NSColor redColor] toView:textViewDisplay];
        }
    }
}


-(void)showStringToUI:(NSString *)strString
            withColor:(NSColor *)color
               toView:(NSTextView *)textView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([strString isEqualToString:@""])
        {
            [self popUpError:[NSError errorWithDomain:@"No data found!"
                                                 code:22
                                             userInfo:nil]];
            NSLog(@"Error: no data found!");
            [textView insertText:@"Error: no data found!"];
        }
        if (color != nil)
        {
            NSDictionary	*dict	= [NSDictionary dictionaryWithObject:color
                                                             forKey:NSForegroundColorAttributeName];
            NSAttributedString* attr = [[NSAttributedString alloc] initWithString:strString
                                                                       attributes:dict];
            [[textView textStorage] appendAttributedString:attr];
        }
        else
            [textView insertText:strString];
        
        [self writeLog:strString];
    });
}

-(void)popUpError:(NSError *)error
{
    NSAlert *alert  = [NSAlert alertWithError:error];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:_window completionHandler:nil];
}

- (void)showTime
{
    m_timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timeStream) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:m_timer forMode:NSDefaultRunLoopMode];
    [m_timer fire];
}

-(void)timeStream
{
    NSTimeZone      *timeZone      = [NSTimeZone timeZoneWithName:[popTimeZone titleOfSelectedItem]];
    [textTimeLabel setStringValue:[[NSDate date]descriptionWithCalendarFormat:@"MM/dd/yyyy HH:mm:ss" timeZone:timeZone locale:nil]];
}

- (void)writeLog:(NSString *)data
{
    NSString * strFilePath = @"~/Desktop/ListenLiveLog.txt";
    strFilePath = [strFilePath stringByExpandingTildeInPath];
    NSFileHandle *h_Log = [NSFileHandle fileHandleForWritingAtPath:strFilePath];
    if (!h_Log)
        [data writeToFile:strFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    else
    {
        NSData *dataTemp = [[NSData alloc] initWithBytes:(void *)[data UTF8String]
                                                  length:[data length]];
        [h_Log seekToEndOfFile];
        [h_Log writeData:dataTemp];
        dataTemp = nil;
    }
}


// for json file
void myJsonCallBack(
                ConstFSEventStreamRef streamRef,
                void *clientCallBackInfo,
                size_t numEvents,
                void *eventPaths,
                const FSEventStreamEventFlags eventFlags[],
                const FSEventStreamEventId eventIds[])
{
    NSUInteger i;
//    char **paths = (char**)eventPaths;
    CFArrayRef paths = (CFArrayRef)eventPaths;
    AppDelegate *app  = (__bridge AppDelegate*)clientCallBackInfo;
    NSLog(@"Called this mehod!!! %@", app);
    
    for (i=0; i<numEvents; i++)
    {
        FSEventStreamEventFlags eventFlag = eventFlags[i];
        FSEventStreamEventId    eventId = eventIds[i];
        NSString *strChangedFilePath = (__bridge NSString *)CFArrayGetValueAtIndex(paths, (CFIndex)i);
        NSLog(@"file path: %@, event flag: %u, event id: %llu",strChangedFilePath,(unsigned int)eventFlag,eventId);
        if ([strChangedFilePath contains:@"gh_station_info.json"])
        {
            m_jsonUpdated = YES;
            strChangedFilePath = [strChangedFilePath SubTo:@"gh_station_info.json" include:YES];
            [app getGHJsonInfo:strChangedFilePath];
        }
        
    }
}

- (void)monitorForJsonFile:(NSString *)filePath
{
    if (!filePath || [filePath isEqualToString:@""])
    {
        NSLog(@"ERROR, can't find csv log path");
        return;
    }
    NSArray *arrPathToWatch = [NSArray arrayWithObject:filePath];
    
    FSEventStreamContext callbackInfo;
    callbackInfo.info    = (__bridge void *)(self);
    callbackInfo.version = 0;
    callbackInfo.retain  = NULL;
    callbackInfo.release = NULL;
    callbackInfo.copyDescription = NULL;
    
    FSEventStreamRef fsStream;
    CFAbsoluteTime latency = 3.0; /* Latency in seconds   kFSEventStreamCreateFlagNone */
    fsStream = FSEventStreamCreate(NULL,
                                 &myJsonCallBack,
                                 &callbackInfo,
                                 (__bridge CFArrayRef)arrPathToWatch,
                                 kFSEventStreamEventIdSinceNow, /* Or a previous event ID */
                                 latency,
                                 kFSEventStreamCreateFlagFileEvents | kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagWatchRoot | kFSEventStreamCreateFlagNone | kFSEventStreamCreateFlagMarkSelf /* kFSEventStreamCreateFlagFileEvents */
                                 );
    FSEventStreamScheduleWithRunLoop(fsStream, CFRunLoopGetCurrent(),         kCFRunLoopDefaultMode);
    FSEventStreamStart(fsStream);
}


//for live file
void myLiveCallBack(
                    ConstFSEventStreamRef streamRef,
                    void *clientCallBackInfo,
                    size_t numEvents,
                    void *eventPaths,
                    const FSEventStreamEventFlags eventFlags[],
                    const FSEventStreamEventId eventIds[])
{
    NSUInteger i;
    CFArrayRef paths = (CFArrayRef)eventPaths;
    AppDelegate *app  = (__bridge AppDelegate*)clientCallBackInfo;
    NSLog(@"Called this mehod!!! %@", app);
    
    for (i=0; i<numEvents; i++)
    {
        FSEventStreamEventFlags eventFlag = eventFlags[i];
        FSEventStreamEventId    eventId = eventIds[i];
        NSString *strChangedFilePath = (__bridge NSString *)CFArrayGetValueAtIndex(paths, (CFIndex)i);
        NSLog(@"file path: %@, event flag: %u, event id: %llu",strChangedFilePath,(unsigned int)eventFlag,eventId);
        if ([strChangedFilePath contains:[NSString stringWithFormat:@"%@/%@",m_strLiveVersionPath,m_strLiveCurrent]])
        {
            m_liveUpdated = YES;
        }
        
    }
}

- (void)monitorForLiveFile:(NSString *)filePath
{
    if (!filePath || [filePath isEqualToString:@""])
    {
        NSLog(@"ERROR, can't find csv log path");
        return;
    }
    NSArray *arrPathToWatch = [NSArray arrayWithObject:filePath];
    
    FSEventStreamContext callbackInfo;
    callbackInfo.info    = (__bridge void *)(self);
    callbackInfo.version = 0;
    callbackInfo.retain  = NULL;
    callbackInfo.release = NULL;
    callbackInfo.copyDescription = NULL;
    
    FSEventStreamRef fsStream;
    CFAbsoluteTime latency = 3.0; /* Latency in seconds   kFSEventStreamCreateFlagNone */
    fsStream = FSEventStreamCreate(NULL,
                                   &myLiveCallBack,
                                   &callbackInfo,
                                   (__bridge CFArrayRef)arrPathToWatch,
                                   kFSEventStreamEventIdSinceNow, /* Or a previous event ID */
                                   latency,
                                   kFSEventStreamCreateFlagNone /* kFSEventStreamCreateFlagFileEvents */
                                   );
    FSEventStreamScheduleWithRunLoop(fsStream, CFRunLoopGetCurrent(),         kCFRunLoopDefaultMode);
    FSEventStreamStart(fsStream);
}
@end





