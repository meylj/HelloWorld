//
//  AppDelegate.m
//  AE-Cake

#import "AppDelegate.h"
#import  "ASIKomodo.h"
#import "NSStringCategory.h"
#import <CoreServices/CoreServices.h>
@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;
@end

@implementation AppDelegate
@synthesize window;

-(id)init
{
    self = [super init];
    if (self) {
        m_dicSetting = [[NSDictionary alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"Setting.plist" ofType:nil]];
        m_bFinish = YES;
        
        myASIKomodo = [[ASIKomodo alloc]init];
        NSDictionary *dicKomodo = [[m_dicSetting objectForKey:@"SERVER"]objectForKey:@"KOMODO"];

        myASIKomodo.KOMODO_URL = [dicKomodo objectForKey:@"URL"];
        myASIKomodo.KOMODO_AV = [dicKomodo objectForKey:@"AV"];
        myASIKomodo.KOMODO_AUID = [dicKomodo objectForKey:@"AUID"];
        myASIKomodo.KOMODO_USERAGENT = [dicKomodo objectForKey:@"USER_AGENT"];
        myASIKomodo.PEGA_SITE = [dicKomodo objectForKey:@"SITE"];
        
        NSString *filePath = @"/vault/data_collection/test_station_config/gh_station_info.json";
        NSString *strFileContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        myASIKomodo.KOMODO_IP = [NSString stringWithFormat:@"%@", [strFileContent subByRegex:@"\"STATION_IP\" : \"(.*?)\"" name:nil error:nil]];
        myASIKomodo.KOMODO_GH_STID = [NSString stringWithFormat:@"%@", [strFileContent subByRegex:@"\"STATION_ID\" : \"(.*?)\"" name:nil error:nil]];
        myASIKomodo.KOMODO_MAC = [NSString stringWithFormat:@"%@", [strFileContent subByRegex:@"\"MAC\" : \"(.*?)\"" name:nil error:nil]];
        m_seconds = [[[m_dicSetting objectForKey:@"TIME"]objectForKey:@"SECOND"]intValue];
        m_strMoveFile = [[m_dicSetting objectForKey:@"MOVE_FILEPATH"]objectForKey:@"MOVEFILE"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:m_strMoveFile]) {
            if([fileManager createDirectoryAtPath:m_strMoveFile withIntermediateDirectories:YES attributes:nil error:nil])
                ATSDebug(@"create move file [%@] success",m_strMoveFile);
        }
    }
    return self;
}

- (void)dealloc
{
    [myASIKomodo release]; myASIKomodo = nil;
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    //[self archiveFile:@"/vault/komodo_upload.tar.gz" destZipFile:@"/vault/komodo_upload"];
    //[self listFile:@"/Users/gdlocal/Public/Workspace/AlarmFiles" withFormat:@".csv&dt"];
    //[self removeAllFiles:@"/vault/komodo_upload"];
    [window setAlphaValue:0];
    
    NSString *listenFile = [[m_dicSetting objectForKey:@"LISTEN_FILEPATH"]objectForKey:@"LISTENFILE"];
    
    NSArray *arrFileList = [self listFile:listenFile withFormat:@"_dt_&.csv"];
    if ([arrFileList count]!=0)
    {
        NSDictionary *dicParameter = [NSDictionary dictionaryWithObjectsAndKeys:@"DTFile",@"Type",arrFileList,@"FileArray",nil];
        [self startUpload:dicParameter];
    }
    
    [self startMonitorFile:listenFile];
}

-(void)startMonitorFile:(NSString*)filePath
{
    ATSDebug(@"Start startMonitor file [%@]",filePath);
    
    if (!filePath || [filePath isEqualToString:@""])
    {
        ATSDebug(@"ERROR, can't find monitor file path");
        return;
    }
    NSArray *arrPathToWatch = [NSArray arrayWithObject:filePath];
    
//    NSArray *arr = @[self];
//    [arr retain];
    FSEventStreamContext callbackInfo;
    callbackInfo.info    = self;
    callbackInfo.version = 0;
    callbackInfo.retain  = NULL;
    callbackInfo.release = NULL;
    callbackInfo.copyDescription = NULL;
    
    FSEventStreamRef stream;
    CFAbsoluteTime latency = 1.0; /* Latency in seconds   kFSEventStreamCreateFlagNone */
    stream = FSEventStreamCreate(NULL,
                                 &fsEventsCallback,
                                 &callbackInfo,
                                 (CFArrayRef)arrPathToWatch,
                                 kFSEventStreamEventIdSinceNow, /* Or a previous event ID */
                                 latency,
                                 kFSEventStreamCreateFlagFileEvents /* kFSEventStreamCreateFlagFileEvents */
                                 );
    FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(),         kCFRunLoopDefaultMode);
    FSEventStreamStart(stream);
    
    ATSDebug(@"Monitor file success.");
}


void fsEventsCallback(
                ConstFSEventStreamRef streamRef,
                void *clientCallBackInfo,
                size_t numEvents,
                void *eventPaths,
                const FSEventStreamEventFlags eventFlags[],
                const FSEventStreamEventId eventIds[])
{
    ATSDebug(@"start fsEventsCallback");
    int i;
    char **paths = (char**)eventPaths;
//    NSArray *ary = (NSArray*)clientCallBackInfo;
    AppDelegate *app  = clientCallBackInfo;
    for (i=0; i<numEvents; i++)
    {
        
         NSString *fileChangedPath = [NSString stringWithFormat:@"%s",paths[i]];
        NSString *strFileLower = [fileChangedPath lowercaseString];
         FSEventStreamEventFlags flags = eventFlags[i];
        if ((flags & kFSEventStreamEventFlagItemRenamed) && [strFileLower contains:@"dt"]
                                                         && [strFileLower contains:@".csv"])
        {
            //file not exitst, return
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if (![fileManager fileExistsAtPath:fileChangedPath])
            {
                ATSDebug(@"action is move file [%@]",fileChangedPath);
                break;
            }
            //list all files which contains "DT" and ".csv",Then upload
            NSArray *arrFileList = [app listFile:[fileChangedPath stringByDeletingLastPathComponent] withFormat:@"_dt_&.csv"];
            if ([arrFileList count]==0) {
                ATSDebug(@"The files in array is empty.");
                break;
            }
            NSDictionary *dicParameter = [NSDictionary dictionaryWithObjectsAndKeys:@"DTFile",@"Type",arrFileList,@"FileArray",nil];
            [app startUpload:dicParameter];
        }
    }
    ATSDebug(@"end fsEventsCallback");
}

- (void)startUpload:(NSDictionary *)dicPara
{
    NSString *szType = [dicPara objectForKey:@"Type"];
    NSArray *arrAllFile = [dicPara objectForKey:@"FileArray"];
    int iFileCount = [arrAllFile count];
 
	//NSString *szListenDir = [[m_dicSetting objectForKey:@"LISTEN_FILEPATH"]objectForKey:@"LISTENFILE"];
    NSString *szRealTimeFile = [arrAllFile lastObject];
    NSString *szTarDirPath = [NSString stringWithFormat:@"%@/%@.tar.gz",m_strMoveFile,[szRealTimeFile lastPathComponent]];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:szRealTimeFile])
    {
        return;
    }
    ATSDebug(@"==========Start To Upload [%@.tar.gz]==========\n",[szRealTimeFile lastPathComponent]);

    do{
        BOOL bCakeSwich = [[m_dicSetting objectForKey:@"CAKE_SWICH"]boolValue];
        if (bCakeSwich)
        {
            ATSDebug(@"==> Step 1: check komodo server ==");
            while(![myASIKomodo checkKomodoStatus])
            {
                ATSDebug(@"ERROR, komodo server is not alive!");
                sleep(m_seconds);
            }
            ATSDebug(@"Komodo server is OK.");
            
            ATSDebug(@"==> Step 2: check station flag ==");
            while (![myASIKomodo checkStationFlag])
            {
                ATSDebug(@"ERROR, the previous flag is not canceled");
                sleep(m_seconds);
            }
            ATSDebug(@"Check previous flag is OK");
            
            if ([szType isEqualToString:@"DTFile"])
            {
                //parse csv content
                NSArray *aryCSVContent = [self parseDTCSVFile:szRealTimeFile];
                NSString *strDate = [self CellContentsAtRow:[aryCSVContent count] - 1 AtColumn:1 FileContents:aryCSVContent];
                NSString *strStation = [self CellContentsAtRow:[aryCSVContent count] - 1 AtColumn:7 FileContents:aryCSVContent];
                NSString *strErrCode = [self CellContentsAtRow:[aryCSVContent count] - 1 AtColumn:11 FileContents:aryCSVContent];
                NSString *strFileR = [self CellContentsAtRow:[aryCSVContent count] - 1 AtColumn:10 FileContents:aryCSVContent];
                NSString *strMSG = [NSString stringWithFormat:@"%@,%@,%@", strStation, strDate, strErrCode];
                
                ATSDebug(@"== Step3: Upload message to DOWNTIME server ==");
                while (![myASIKomodo doEventWithFile:strMSG Svc:@"9-PANTHER_DOWNTIME" Result:strFileR]) {
                    ATSDebug(@"ERROR, upload message fail!");
                    sleep(m_seconds);
                }
                ATSDebug(@"Upload message OK.");
        
                ATSDebug(@"==> Step4: move file ==");
                for (int i=0; i<iFileCount; i++)
                {
                    NSString *strFileName = [[arrAllFile objectAtIndex:i]lastPathComponent];
                    NSString *strMovePath = [NSString stringWithFormat:@"%@/%@",m_strMoveFile,strFileName];
                    if (![self moveFile:[arrAllFile objectAtIndex:i] NewPath:strMovePath]) {
                        ATSDebug(@"ERROR, [%@] move fail",[arrAllFile objectAtIndex:i]);
                    }
                    ATSDebug(@"Move [%@] to [%@] OK.", strFileName, strMovePath);
                }
                ATSDebug(@"Move [%d] files OK.",iFileCount);
                
                ATSDebug(@"==> Step5: compress file ==");
                if (![self archiveFile:szTarDirPath destZipFile:m_strMoveFile]) {
                    ATSDebug(@"ERROR, [%@] cmpress fail",szTarDirPath);
                }
                ATSDebug(@"== Compress [%@] to [%@] OK.", m_strMoveFile, szTarDirPath);
                
                ATSDebug(@"==> Step6: upload attachment to 9-CREAM ==");
                while (![myASIKomodo doUploadWithFile:szTarDirPath Svc:@"9-CREAM" Result:@"51"])
                {
                    ATSDebug(@"ERROR, upload attachment [%@] fail.", szTarDirPath);
                    sleep(m_seconds);
                }
                ATSDebug(@"Upload attachment [%@] OK.", szTarDirPath);
            
                ATSDebug(@"==> Step7: remove file ==");
                if (![self removeAllFiles:m_strMoveFile]) {
                    ATSDebug(@"ERROR, [%@] contents remove fail",m_strMoveFile);
                }
                ATSDebug(@"== Remove [%@] contents OK.", m_strMoveFile);
                
                ATSDebug(@"==> Step8: set station flag ==");
                while(![myASIKomodo setStationFlag]){
                    ATSDebug(@"ERROR, set station flag fail.");
                    sleep(m_seconds);
                }
                ATSDebug(@"Set station flag OK.");
                    
    //            ATSDebug(@"==> Step9: cacel station flag ==");
    //            while(![myASIKomodo cancelStationFlag])
    //            {
    //                ATSDebug(@"ERROR, cancel station flag fail.");
    //                sleep(m_seconds);
    //            }
    //            ATSDebug(@"Cancel station flag success.\n");
                
                ATSDebug(@"==> Step10: download file ==");
                while(![myASIKomodo doDownloadFile:[NSString stringWithFormat:@"/vault/download/%@",[szTarDirPath lastPathComponent]]])
                {
                    ATSDebug(@"ERROR, download file fail.");
                    sleep(m_seconds);
                }
                ATSDebug(@"Download file OK.\n");
        
                ATSDebug(@"==========Upload [%@] OK==========\n",[szTarDirPath lastPathComponent]);
                break;
                }
        }
        else
        {
            ATSDebug(@"The Swich if off.");
            sleep(60);
        }
    }while(true);
}


//parse a csv log
- (NSArray *)parseDTCSVFile:(NSString *)filePath
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath])
    {
        NSMutableString * strFile = [NSMutableString stringWithContentsOfFile:filePath
                                                                            encoding:NSUTF8StringEncoding
                                                                               error:nil];
        [strFile replaceOccurrencesOfString:@"\n"
                                        withString:@"\r"
                                           options:NSCaseInsensitiveSearch
                                             range:NSMakeRange(0, [strFile length])];
        [strFile replaceOccurrencesOfString:@"\r\r"
                                        withString:@"\r"
                                           options:NSCaseInsensitiveSearch
                                             range:NSMakeRange(0, [strFile length])];
        
        NSMutableArray * aryContents =[NSMutableArray arrayWithArray:[strFile componentsSeparatedByString:@"\r"]];
        [aryContents removeObject:@""];
        return aryContents;
    }
    return nil;
}

-(NSString*)CellContentsAtRow:(NSUInteger)row
                     AtColumn:(NSUInteger)column
                 FileContents:(NSArray *)aryContents
{
    if (!aryContents)
    {
        ATSDebug(@"no contents");
        return @"";
    }
    if (row < [aryContents count])
    {
        NSArray * aryRowContents = [[aryContents objectAtIndex:row] componentsSeparatedByString:@","];
        if (column <= [aryRowContents count])
            return [aryRowContents objectAtIndex:column-1];
    }else
    {
        ATSDebug(@"row >= aryContents");
    }
    return @"";
}

//list all files of a directory and sorted by modifydate
-(NSArray*)listFile:(NSString*)strDicPath withFormat:(NSString*)fileFormat
{
    NSFileManager *fileManger = [NSFileManager defaultManager];
    if (![fileManger fileExistsAtPath:strDicPath])
    {
        NSLog(@"Can not find file at path %@",strDicPath);
        return nil;
    }
    NSArray *arrFileName = [fileManger contentsOfDirectoryAtPath:strDicPath error:nil];
    NSMutableArray *arrFileList = [[NSMutableArray alloc] init];
    if ([fileFormat contains:@"&"])
    {
        bool ret = true;
        NSArray *arrFileFormat = [fileFormat componentsSeparatedByString:@"&"];
        
        for (int i = 0; i<[arrFileName count]; i++)
        {
             NSString *strFileName = [[arrFileName objectAtIndex:i]lowercaseString];
            for (int j=0; j<[arrFileFormat count]; j++)
            {
                ret &=[strFileName contains:[arrFileFormat objectAtIndex:j]];
                if (!ret)
                    break;
            }
            if (ret)
            {
                NSString *szFilePath = [NSString stringWithFormat:@"%@/%@",strDicPath,[arrFileName objectAtIndex:i]];
                [arrFileList addObject:szFilePath];
            }
            ret = true;
        }
    }
    else if([fileFormat contains:@"|"])
    {
        bool ret = false;
        NSArray *arrFileFormat = [fileFormat componentsSeparatedByString:@"|"];
        
        for (int i = 0; i<[arrFileName count]; i++)
        {
            NSString *strFileName = [[arrFileName objectAtIndex:i]lowercaseString];
            for (int j=0; j<[arrFileFormat count]; j++)
            {
                ret |=[strFileName contains:[arrFileFormat objectAtIndex:j]];
                if (ret)
                    break;
            }
            if (ret)
            {
                NSString *szFilePath = [NSString stringWithFormat:@"%@/%@",strDicPath,[arrFileName objectAtIndex:i]];
                [arrFileList addObject:szFilePath];
            }
            ret = false;
        }
    }
    else
    {
        for (int i = 0; i<[arrFileName count]; i++)
        {
            NSString *strFileName = [[arrFileName objectAtIndex:i]lowercaseString];
            if (fileFormat==nil || [fileFormat isEqualTo:@""] || [strFileName contains:fileFormat])
            {
                NSString *szFilePath = [NSString stringWithFormat:@"%@/%@",strDicPath,[arrFileName objectAtIndex:i]];
                [arrFileList addObject:szFilePath];
            }
        }
    }
    
    //sort
    NSMutableDictionary		*dicAll			= [[NSMutableDictionary alloc] init];
    NSString *strFile;
    for (int iIndex = 0; iIndex < [arrFileList count]; iIndex++)
    {
        strFile = [arrFileList objectAtIndex:iIndex];
        [dicAll setValue:[[fileManger attributesOfItemAtPath:strFile error:nil]
                          objectForKey:NSFileModificationDate]
                  forKey:strFile];
    }
    NSArray *arySorted = [dicAll keysSortedByValueUsingSelector:@selector(compare:)];
    [dicAll release];
    [arrFileList release];
    return arySorted;
}


//move file
-(BOOL)moveFile:(NSString*)szOldPath NewPath:(NSString*)szNewPath
{
    if (szOldPath && szNewPath)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        if ([fileManager fileExistsAtPath:szNewPath]) {
            [fileManager removeItemAtPath:szNewPath error:&error];
        }
        [fileManager moveItemAtPath:szOldPath toPath:szNewPath error:&error];
        if (error)
        {
            ATSDebug(@"%@",[error description]);
            return NO;
        }
        return YES;
    }
    return NO;
}

//remove file
-(BOOL)removeFile:(NSString*)szPath
{
    if (szPath)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        [fileManager removeItemAtPath:szPath error:&error];
        if (error)
        {
            ATSDebug(@"%@",[error description]);
            return NO;
        }
        return YES;
    }
    return NO;
}

//remove all files at a directory
-(BOOL)removeAllFiles:(NSString*)szDirPath
{
    if (szDirPath)
    {
        NSFileManager *fileManger = [NSFileManager defaultManager];
        if (![fileManger fileExistsAtPath:szDirPath])
        {
            ATSDebug(@"Can not find remove file path %@",szDirPath);
            return NO;
        }
        if (![fileManger removeItemAtPath:szDirPath error:nil]) {
            ATSDebug(@"ERROR, remove directory [%@] fail",szDirPath);
            return NO;
        }
        if (![fileManger createDirectoryAtPath:szDirPath withIntermediateDirectories:YES attributes:nil error:nil]) {
            ATSDebug(@"Can not find remove file path %@",szDirPath);
            return NO;
        }
        return YES;
    }
    return NO;
}
//compress file
- (BOOL) archiveFile:(NSString*)zipfile destZipFile:(NSString*)srcfile
{
    NSTask * zipTask = [[NSTask alloc] init];
    [zipTask setLaunchPath:@"/usr/bin/tar"];
    [zipTask setArguments:[NSArray arrayWithObjects:@"--format=ustar",@"-zcvf", zipfile, srcfile, nil]];
    [zipTask launch];
    [zipTask waitUntilExit];
    
    if ([zipTask terminationStatus] != 0){
        ATSDebug(@"can't zip file:%@", srcfile);
        return NO;
    }
    [zipTask release];
    return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return YES;
}

@end