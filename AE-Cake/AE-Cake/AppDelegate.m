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

bool bIsRunning = NO;
NSString *listenFile = nil;

@implementation AppDelegate
@synthesize window;
-(id)init
{
    self = [super init];
    if (self) {
        m_dicSetting = [[NSDictionary alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"Setting.plist" ofType:nil]];
        
        myASIKomodo = [[ASIKomodo alloc]init];
        
        NSDictionary *dicKomodo = [[m_dicSetting objectForKey:@"SERVER"]objectForKey:@"KOMODO"];
        myASIKomodo.KOMODO_URL = [dicKomodo objectForKey:@"URL"];
        myASIKomodo.KOMODO_AV = [dicKomodo objectForKey:@"AV"];
        myASIKomodo.KOMODO_AUID = [dicKomodo objectForKey:@"AUID"];
        myASIKomodo.KOMODO_USERAGENT = [dicKomodo objectForKey:@"USER_AGENT"];
        myASIKomodo.PEGA_SITE = [dicKomodo objectForKey:@"SITE"];
        myASIKomodo.m_iHttpRequestTimeout = [[dicKomodo objectForKey:@"HTTPREQUEST_TIMEOUT"]intValue];
        
        NSString *filePath = [m_dicSetting objectForKey:@"JSON_FILE"];
        NSString *strFileContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        myASIKomodo.KOMODO_IP = [NSString stringWithFormat:@"%@", [strFileContent subByRegex:@"\"STATION_IP\" : \"(.*?)\"" name:nil error:nil]];
        myASIKomodo.KOMODO_GH_STID = [NSString stringWithFormat:@"%@", [strFileContent subByRegex:@"\"STATION_ID\" : \"(.*?)\"" name:nil error:nil]];
        myASIKomodo.KOMODO_MAC = [NSString stringWithFormat:@"%@", [strFileContent subByRegex:@"\"MAC\" : \"(.*?)\"" name:nil error:nil]];

        listenFile = [[m_dicSetting objectForKey:@"LISTEN_FILEPATH"]objectForKey:@"LISTENFILE"];
        m_seconds = [[[m_dicSetting objectForKey:@"TIME"]objectForKey:@"SECOND"]intValue];
        m_strMoveFile = [[m_dicSetting objectForKey:@"MOVE_FILEPATH"]objectForKey:@"MOVEFILE"];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:m_strMoveFile])
        {
            if([fileManager createDirectoryAtPath:m_strMoveFile withIntermediateDirectories:YES attributes:nil error:nil])
                ATSDebug(@"create move file [%@] success",m_strMoveFile);
        }
    }
    return self;
}

- (void)dealloc
{
    [NSThread exit];
    [myASIKomodo release]; myASIKomodo = nil;
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [window setAlphaValue:0];
    
    NSArray *arrFileList = [self listFile:listenFile withFormat:@"_dt_&.csv"];
    if ([arrFileList count]!=0)
    {
        NSDictionary *dicParameter = [NSDictionary dictionaryWithObjectsAndKeys:arrFileList,@"FileArray",nil];
        [self startUploadRealTimeMessage:dicParameter];
    }
    NSArray *arrUploadFile = [self listFile:m_strMoveFile withFormat:@"_dt_&.csv"];
    if ([arrUploadFile count]!=0)
    {
        NSDictionary *dicPara = [NSDictionary dictionaryWithObjectsAndKeys:arrUploadFile,@"FileArray",nil];
        [self startUploadAttachment:dicPara];
    }
    
    NSTimeInterval timer=[[m_dicSetting objectForKey:@"LOOP_UPLOAD_FILE_TIME"]doubleValue];
    [NSTimer scheduledTimerWithTimeInterval:timer target:self selector:@selector(startHandleUploadFile) userInfo:nil repeats:YES];
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
    
    FSEventStreamContext callbackInfo;
    callbackInfo.info    = self;
    callbackInfo.version = 0;
    callbackInfo.retain  = NULL;
    callbackInfo.release = NULL;
    callbackInfo.copyDescription = NULL;
    
    FSEventStreamRef stream;
    CFAbsoluteTime latency = 2.0; /* Latency in seconds   kFSEventStreamCreateFlagNone */
    stream = FSEventStreamCreate(NULL,
                                 &fsEventsCallback,
                                 &callbackInfo,
                                 (CFArrayRef)arrPathToWatch,
                                 kFSEventStreamEventIdSinceNow, /* Or a previous event ID */
                                 latency,
                                 kFSEventStreamCreateFlagFileEvents /* kFSEventStreamCreateFlagFileEvents */
                                 );
    FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
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
    for (int j=0; j<3; j++)
    {
        if (!bIsRunning) {
            break;
        }
        sleep(5);
    }
    if (!bIsRunning)
    {
        bIsRunning = YES;
        int i;
        char **paths = (char**)eventPaths;
        AppDelegate *app  = clientCallBackInfo;
        for (i=0; i<numEvents; i++)
        {
            
            NSString *fileChangedPath = [NSString stringWithFormat:@"%s",paths[i]];
            ATSDebug(@"the file path is:%@",fileChangedPath);
            NSString *strFileLower = [fileChangedPath lowercaseString];
            FSEventStreamEventFlags flags = eventFlags[i];
            ATSDebug(@"the hex flags is:%x",flags);
            
            if (((flags & kFSEventStreamEventFlagItemRenamed) || (flags & kFSEventStreamEventFlagItemCreated))
                && [strFileLower contains:@"dt"]
                && [strFileLower contains:@".csv"])
            {
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
                NSDictionary *dicParameter = [NSDictionary dictionaryWithObjectsAndKeys:arrFileList,@"FileArray",nil];
                [app startUploadRealTimeMessage:dicParameter];
            }
        }
         bIsRunning = NO;
    }
    ATSDebug(@"end fsEventsCallback");
}

- (void)startHandleUploadFile
{
    const int iFailTime=[[m_dicSetting objectForKey:@"FAIL_TIMES"]intValue];           //3
    for (int j=0; j<iFailTime; j++)
    {
        if (!bIsRunning) {
            break;
        }
        sleep(m_seconds);
    }
    
    if(!bIsRunning)
    {
        NSArray *arrFileList = [self listFile:m_strMoveFile withFormat:@"_dt_&.csv"];
        if ([arrFileList count]!=0)
        {
            //bIsRunning = YES;
            NSDictionary *dicParameter = [NSDictionary dictionaryWithObjectsAndKeys:arrFileList,@"FileArray",nil];
            [self performSelectorOnMainThread:@selector(startUploadAttachment:) withObject:dicParameter waitUntilDone:NO];
            //bIsRunning = NO;
        }
    }
    else
    {
        ATSDebug(@"The upload is busy.");
    }
}


- (void)startUploadRealTimeMessage:(NSDictionary *)dicPara
{
    BOOL bCakeSwitch = [[m_dicSetting objectForKey:@"CAKE_SWITCH"]boolValue];
    if (!bCakeSwitch)
    {
        ATSDebug(@"The Swich if off.");
        return;
    }
    NSArray *arrAllFile = [dicPara objectForKey:@"FileArray"];
    int iFileCount = (int)[arrAllFile count];
    NSString *szRealTimeFile = [arrAllFile lastObject];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:szRealTimeFile])
    {
        return;
    }
    
    ATSDebug(@"==========Start To Upload RealTime Message [%@.tar.gz]==========\n",[szRealTimeFile lastPathComponent]);
    const int iTestTimes = [[m_dicSetting objectForKey:@"FAIL_TIMES"]intValue];
    
    ATSDebug(@"==> Step 1: check komodo server ==");
    for (int i=0; i<iTestTimes; i++) {
        if ([myASIKomodo checkKomodoStatus])
            break;
        if (i == iTestTimes-1) {
            ATSDebug(@"ERROR, komodo server is not alive!");
            return;
        }
        sleep(m_seconds);
    }
    ATSDebug(@"Komodo server is OK.\n");
    
    //parse csv content
    NSArray *aryCSVContent = [self parseDTCSVFile:szRealTimeFile];
    NSString *strDate = [self CellContentsAtRow:[aryCSVContent count] - 1 AtColumn:1 FileContents:aryCSVContent];
    NSString *strStation = [self CellContentsAtRow:[aryCSVContent count] - 1 AtColumn:7 FileContents:aryCSVContent];
    NSString *strErrCode = [self CellContentsAtRow:[aryCSVContent count] - 1 AtColumn:11 FileContents:aryCSVContent];
    NSString *strFileR = [self CellContentsAtRow:[aryCSVContent count] - 1 AtColumn:10 FileContents:aryCSVContent];
    NSString *strMSG = [NSString stringWithFormat:@"%@,%@,%@", strStation, strDate, strErrCode];
    
    ATSDebug(@"==> Step2: Upload message to DOWNTIME server ==");
    for (int i=0; i<iTestTimes; i++) {
        if ([myASIKomodo doEventWithFile:strMSG Svc:@"9-PANTHER_DOWNTIME" Result:strFileR])
        {
            break;
        }
        if (i == iTestTimes-1) {
             ATSDebug(@"ERROR, upload message fail!");
            return;
        }
        sleep(m_seconds);
    }
    ATSDebug(@"Upload message OK.\n");
    
    ATSDebug(@"==> Step3: move file ==");
    for (int i=0; i<iFileCount; i++)
    {
        NSString *strFileName = [[arrAllFile objectAtIndex:i]lastPathComponent];
        NSString *strMovePath = [NSString stringWithFormat:@"%@/%@",m_strMoveFile,strFileName];
        if (![self moveFile:[arrAllFile objectAtIndex:i] NewPath:strMovePath]) {
            ATSDebug(@"ERROR, [%@] move fail",[arrAllFile objectAtIndex:i]);
        }
        ATSDebug(@"Move [%@] to [%@] OK.", strFileName, strMovePath);
    }
    ATSDebug(@"Move [%d] files OK.\n",iFileCount);
    
    ATSDebug(@"==========Upload RealTime Message [%@] Success==========\n",[szRealTimeFile lastPathComponent]);
}

- (void)startUploadAttachment:(NSDictionary *)dicPara
{
    bIsRunning = YES;
    BOOL bCakeSwitch = [[m_dicSetting objectForKey:@"CAKE_SWITCH"]boolValue];
    if (!bCakeSwitch)
    {
        ATSDebug(@"The Swich if off.");
        bIsRunning = NO;
        return;
    }
    NSArray *arrAllFile = [dicPara objectForKey:@"FileArray"];

    NSString *szRealTimeFile = [arrAllFile lastObject];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:szRealTimeFile])
    {
        bIsRunning = NO;
        return;
    }
    
    NSString *szTarDirPath = [NSString stringWithFormat:@"%@/%@.tar.gz",m_strMoveFile,[szRealTimeFile lastPathComponent]];
    const int iTestTimes = [[m_dicSetting objectForKey:@"FAIL_TIMES"]intValue];
    ATSDebug(@"==========Start To Upload Attachment [%@.tar.gz]==========\n",[szRealTimeFile lastPathComponent]);
    
    ATSDebug(@"==> Step 1: check komodo server ==");
    for (int i=0; i<iTestTimes; i++) {
        if ([myASIKomodo checkKomodoStatus])
        {
            break;
        }
        if (i == iTestTimes-1) {
            ATSDebug(@"ERROR, komodo server is not alive!");
            return;
        }
        sleep(m_seconds);
    }
    ATSDebug(@"Komodo server is OK.\n");
    
    ATSDebug(@"==> Step 2: check station flag ==");
    for (int i=0; i<iTestTimes; i++) {
        if ([myASIKomodo checkStationFlag])
        {
            break;
        }
        if (i == iTestTimes-1) {
            ATSDebug(@"ERROR, the previous flag is not canceled");
            return;
        }
        sleep(m_seconds);
    }
    ATSDebug(@"Check previous flag is OK.\n");
    
    ATSDebug(@"==> Step3: compress file ==");
    if (![self archiveFile:szTarDirPath destZipFile:m_strMoveFile]) {
        ATSDebug(@"ERROR, [%@] cmpress fail",szTarDirPath);
        bIsRunning = NO;
        return;
    }
    ATSDebug(@"== Compress [%@] to [%@] OK.\n", m_strMoveFile, szTarDirPath);
    
    ATSDebug(@"==> Step4: upload attachment to 9-CREAM ==");
    for (int i=0; i<iTestTimes; i++) {
        if ([myASIKomodo doUploadWithFile:szTarDirPath Svc:@"9-CREAM" Result:@"51"])
        {
            break;
        }
        if (i == iTestTimes-1) {
            ATSDebug(@"ERROR, upload attachment [%@] fail.", szTarDirPath);
            return;
        }
        sleep(m_seconds);
    }
    ATSDebug(@"Upload attachment [%@] OK.\n", szTarDirPath);

    ATSDebug(@"==> Step5: remove file ==");
    if (![self removeAllFiles:m_strMoveFile]) {
        ATSDebug(@"ERROR, [%@] contents remove fail",m_strMoveFile);
        bIsRunning = NO;
        return;
    }
    ATSDebug(@"== Remove [%@] contents OK.\n", m_strMoveFile);
    
    ATSDebug(@"==> Step6: set station flag ==");
    for (int i=0; i<iTestTimes; i++) {
        if ([myASIKomodo setStationFlag])
        {
            break;
        }
        if (i == iTestTimes-1) {
            ATSDebug(@"ERROR, set station flag fail.");
            return;
        }
        sleep(m_seconds);
    }
    ATSDebug(@"Set station flag OK.\n");
        
//        ATSDebug(@"==> Step7: cacel station flag ==");
//        while(![myASIKomodo cancelStationFlag])
//        {
//            ATSDebug(@"ERROR, cancel station flag fail.");
//            iCurrentTimes++;
//            if (iCurrentTimes == iTestTimes) {
//                bIsRunning = NO;
//                return;
//            }
//            sleep(m_seconds);
//        }
//       ATSDebug(@"Cancel station flag success.\n");
    
    ATSDebug(@"==> Step8: download file ==");
    if(![myASIKomodo doDownloadFile:[NSString stringWithFormat:@"/vault/komodo_download/%@",[szTarDirPath lastPathComponent]]])
    {
        ATSDebug(@"ERROR, download file fail.");
        return;
    }
    ATSDebug(@"Download file OK.\n");

    ATSDebug(@"==========Upload Attachment [%@] Success==========\n",[szTarDirPath lastPathComponent]);
    bIsRunning = NO;
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

-(BOOL)removeFilesInArray:(NSArray*)arrFile
{
    for (int i=0; i<[arrFile count]; i++)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        [fileManager removeItemAtPath:[arrFile objectAtIndex:i] error:&error];
        if (error)
        {
            ATSDebug(@"%@",[error description]);
            return NO;
        }
    }
    return YES;
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
        [zipTask release];
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