//
//  AppDelegate.m
//  LimitsSplot
//
//  Created by User on 12-11-3.
//  Copyright (c) 2012年 User. All rights reserved.
//

#import "AppDelegate.h"
#import "Base64.c"

#define Row(index)          [NSString stringWithFormat:@"Line%li", index]
#define Col(index)          [NSString stringWithFormat:@"Coln%li", index]

#define Alert(Message)      NSRunAlertPanel(@"Warning", Message, @"(#‵′)凸", nil, nil);\
                            return
#define AlertNoR(Message)      NSRunAlertPanel(@"Warning", Message, @"(#‵′)凸", nil, nil)

#define NOLOWLMT            [strLowLimit  rangeOfString:@"NA"].location != NSNotFound || [strLowLimit   rangeOfString:@"N/A"].location  != NSNotFound || [strLowLimit   rangeOfString:@" "].location != NSNotFound || [strLowLimit isEqualToString:@""]

#define NOHIGHLMT           [strUpLimit  rangeOfString:@"NA"].location != NSNotFound || [strUpLimit   rangeOfString:@"N/A"].location  != NSNotFound || [strUpLimit  rangeOfString:@" "].location != NSNotFound || [strUpLimit isEqualToString:@""]

#define SAMPLENUM              39
#define OFFSET                 6
#define LABELINTERNAL          8
#define TAUTLETICKS         (SAMPLENUM+2*OFFSET+3)
#define MULTHREAD              1

NSInteger       g_iCount     = 0;

@implementation AppDelegate

@synthesize window;

- (void)awakeFromNib
{
    /* ++++++++++++++++++++++ 
        license permit
        based on base64
     ++++++++++++++++++++++++*/
    
    // get current date
    NSDate      *currentDate    = [NSDate  date];
    NSLog(@"%@",[currentDate description]);
    
    // get the permitted license
    NSString    *strPermitDate  = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/Documents/SDD_License.rtf",NSHomeDirectory()] encoding:NSUTF8StringEncoding error:nil];
    if ( !strPermitDate || ![strPermitDate length] ) {
        AlertNoR(@"缺少授权文件。");
        exit(-1);
    }
    
    // decode the Ciphertext
    char        OrgString[100];
    char        Base64String[1024];
    strcpy(Base64String, [strPermitDate UTF8String]);
    Base64Int   Base64StringLen = (Base64Int)strlen( Base64String );
    Base64Int   OrgStringLen =  Base64Decode(OrgString, Base64String, Base64StringLen, 1);
    if (OrgStringLen>0)
    {
        // the plain text
        strPermitDate   = [NSString stringWithUTF8String:OrgString];
        if ( strPermitDate && [strPermitDate rangeOfString:@"Stephen's date: "].location != NSNotFound &&[strPermitDate rangeOfString:@" Willow's Love"].location != NSNotFound )
        {
            strPermitDate   = [strPermitDate    stringByReplacingOccurrencesOfString:@"Stephen's date: " withString:@""];
            strPermitDate   = [strPermitDate    stringByReplacingOccurrencesOfString:@" Willow's Love" withString:@""];
        }else
        {
            AlertNoR(@"授权文件失效,文件不可读或被篡改。");
            exit(0);
        }

    }
    
    // get the permitted date
    NSDate      *permitedDate   = [NSDate   dateWithString:strPermitDate];
    NSLog(@"%@",[permitedDate description]);
    
    if ( permitedDate && [currentDate compare:permitedDate] == NSOrderedDescending )
    {
        AlertNoR(@"授权文件已过期。");
        exit(1);
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [window      setBackgroundColor:[NSColor grayColor]];
    
    // initial
    strLowLimit         = @"NA";
    strUpLimit          = @"NA";
    strItemName         = @"NA";
    arr_fileLogsPath    = [[NSMutableArray          alloc]init];
    arr_SrcList         = [[NSMutableArray          alloc]init];
    arr_ImagePath       = [[NSMutableArray          alloc]init];
    arr_TestResult      = [[NSMutableArray          alloc]init];
    arr_CasePick        = [[NSMutableArray          alloc]init];
    
    // init my lock
    myLock      = [[NSLock   alloc]init];
    
    myClock.hour    = 0;
    myClock.minute  = 0;
    myClock.second  = 0;
    
    // set tag and delegate and datasource
    [tvSrcList      setTag:0];
    [tvSrcList      setDelegate:self];
    [tvSrcList      setDataSource:self];
    [tvRawData      setTag:1];
    [tvRawData      setDelegate:self];
    [tvRawData      setDataSource:self];
    [tvCfgList      setTag:2];
    [tvCfgList      setDelegate:self];
    [tvCfgList      setDataSource:self];
    [tvPckList      setTag:3];
    [tvPckList      setDelegate:self];
    [tvPckList      setDataSource:self];
    
    // option window add subview
    [[optWindow     contentView] addSubview:firstView];
    [[optWindow     contentView] addSubview:secondView];
    // set two views' status
    [firstView      setHidden:NO];
    [secondView     setHidden:YES];

}

- (void)dealloc{
    // Should close the ARC function
    // “Build Setting”->"CLANG_ENABLE_OBJC_ARC", set as "NO"
    [arr_fileLogsPath       release];
    [arr_SrcList            release];
    [arr_TestItems          release];
    [arr_UpperLimits        release];
    [arr_LowerLimits        release];
    [arr_ImagePath          release];
    [arr_TestResult         release];
    [arr_CasePick           release];
    [myLock                 release];

    [super dealloc];
}

#pragma mark    - Choose data source -

- (void) openPanelDidEnd: (NSOpenPanel *) sheet
               returnCode: (int) returnCode
              contextInfo: (void *) context
{
    if (returnCode == NSOKButton) {
        for (NSURL  *theUrl in [sheet URLs])
        {
            NSString    *filePath   = [theUrl path];
            NSLog(@"the log path: %@", filePath);
            [arr_fileLogsPath   addObject:filePath];
            [arr_SrcList        addObject:[filePath lastPathComponent]];
        }
    }
    [tvSrcList              reloadData];
}

- (void)selectSrcData
{
    // realloc array
    arr_TestItems   ? [arr_TestItems    release]: NSLog(@"arr_TestItems NA");
    arr_UpperLimits ? [arr_UpperLimits  release]: NSLog(@"arr_UpperLimits NA");
    arr_LowerLimits ? [arr_LowerLimits  release]: NSLog(@"arr_LowerLimits NA");
    
    // get the test items, values and spec, should in row 1, 4, 5 (PDCA formart)
    arr_TestItems       = [[NSMutableArray          alloc]initWithArray:[self getValuesFromDic:(NSInteger)(1)     Type:kRowType]];
    arr_UpperLimits     = [[NSMutableArray          alloc]initWithArray:[self getValuesFromDic:(NSInteger)(4)     Type:kRowType]];
    arr_LowerLimits     = [[NSMutableArray          alloc]initWithArray:[self getValuesFromDic:(NSInteger)(5)     Type:kRowType]];
    
    // reload tableview
    [tvRawData              reloadData];
}

- (IBAction)choseCsvData:(id)sender
{
    openPanel               = [NSOpenPanel openPanel];
    [openPanel              setCanChooseDirectories:NO];
    [openPanel              setAllowsMultipleSelection:NO];
    [openPanel              setCanChooseFiles:YES];
        
    [openPanel  beginSheetForDirectory:nil file:nil types:[NSArray arrayWithObjects:@"csv", nil] modalForWindow:window modalDelegate:self didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:) contextInfo:nil];

}

- (NSMutableIndexSet    *)getFailIndexSet
{
    // get the test result
    arr_TestResult          = [self getValuesFromDic:(NSInteger)(6)     Type:kColType];
    
    NSMutableIndexSet   *indexes_fail    = [NSMutableIndexSet    indexSet];
    for (int i =0; i<[arr_TestResult count]; i++)
    {
        if ([[arr_TestResult objectAtIndex:i]rangeOfString:@"FAIL"].location != NSNotFound)
        {
            [indexes_fail     addIndex:i];
        }
    }
    
    return indexes_fail;
}

// filter the raw data by first, last or all, or only pass
- (NSMutableIndexSet    *)datafilter
{
    NSMutableIndexSet   *indexes = [NSMutableIndexSet   indexSet];
    
    // only pass?
    if ([btnPassPick state] == NSOnState) {
        NSMutableIndexSet   *indexes_fail    = [self getFailIndexSet];
        [indexes addIndexes:indexes_fail];
    }
    
    // only first or last or all?
    // get the test Serialnumbers
    NSMutableArray      *mlArrSerialNumber      = [self   getValuesFromDic:(NSInteger)(1)   Type:kColType];

    switch ([segBtn selectedSegment]) {
        case 0:
            // only keep the first data
            // 32bit system int , 4294967296
            for (int i=0; i<[mlArrSerialNumber count]-1; i++)
            {
                if ([indexes containsIndex:i]) {
                    continue;
                }
                for (int j=i+1; j<[mlArrSerialNumber count]; j++)
                {
                    if ([[mlArrSerialNumber objectAtIndex:j] isEqualTo: [mlArrSerialNumber objectAtIndex:i]])
                    {
                        [indexes addIndex:j];
                    }
                }
            }
            break;
        case 1:
            // only keep the last data
            for (int i=[mlArrSerialNumber count]-1; i>0; i--)
            {
                if ([indexes containsIndex:i]) {
                    continue;
                }
                for (int j=i-1; j>=0; j--)
                {
                    if ([[mlArrSerialNumber objectAtIndex:j] isEqualTo: [mlArrSerialNumber objectAtIndex:i]])
                    {
                        [indexes addIndex:j];
                    }
                }
            }
            break;
        case 2:
            // all data
            // maybe nothing
            break;
        default:
            break;
    }

    return indexes;
}

// sort the data
- (void)dataSort : (NSMutableArray  *)mlArray  inDic: (NSMutableDictionary **)mlDic
{
    NSMutableIndexSet   *indexSet   = [NSMutableIndexSet    indexSet];
    id  temp    = [mlArray  objectAtIndex:0];
    for (NSInteger i=0; i<[mlArray count]; i++)
    {
        if ([[mlArray    objectAtIndex:i] isEqualTo:temp])
        {
            [indexSet   addIndex:i];
        }
    }
    [*mlDic      setObject:indexSet forKey: temp];
    [mlArray    removeObjectsAtIndexes:indexSet];
    if ([mlArray count] == 0)
    {
        return;
    }else
    {
        [self    dataSort:mlArray  inDic:&(*mlDic)];
    }
}

- (IBAction)dataFilter:(id)sender
{
    if (idx_IndexSetFnl) {
        [idx_IndexSetFnl     removeAllIndexes];
        [idx_IndexSetFnl     release];
        idx_IndexSetFnl      = nil;
    }
    idx_IndexSetFnl     = [[NSMutableIndexSet    alloc]initWithIndexSet:[self    datafilter]];
}

// click to open a new window with some options to filter the data by line, station or config
- (IBAction)dataFilter2:(id)sender
{
    // get sender's tag
    iSenderTag      = [sender   tag];
        
    // switch case in protected scope , we need add "{", "}"
    switch (iSenderTag)
    {
        case kNoneRule:
            // no rule means export exactly
        {
            [txtTimeCost     setStringValue: @"00:00:00"];
            myClock.hour    = 0;
            myClock.minute  = 0;
            myClock.second  = 0;
            if (myTimer) {
                [myTimer     release];
                myTimer     = nil;
            }
            myTimer     = [[NSTimer  alloc]initWithFireDate:nil interval:1.0f target:self selector:@selector(timeTicks) userInfo:nil repeats:YES];
            g_iCount        = 0;
            if (MULTHREAD)
            {
                [[NSRunLoop   currentRunLoop]addTimer:myTimer forMode:NSDefaultRunLoopMode];
                [self       runThreadForThePro];
            }else
            {
                [NSThread   detachNewThreadSelector:@selector(runLoopRun) toTarget:self withObject:nil];
                [self        saveAllandExport];
            }
            return;
        }
            break;
        case kConfigRule:
            // s_build
        {
            iSenderTagNoEnter   = kConfigRule;
            arr_Config          = [self getValuesFromDic:(NSInteger)(3)     Type:kColType];
            
            // 递归实现数据筛选
            if (dic_Config) {
                [dic_Config  removeAllObjects];
                [dic_Config  release];
                dic_Config  = nil;
            }
            dic_Config      =   [[NSMutableDictionary   alloc]init];

            [self           dataSort:arr_Config          inDic:&dic_Config];
        }
            break;
        case kStationIdRule:
            // stationID
        {
            iSenderTagNoEnter   = kStationIdRule;
            arr_StationID       = [self getValuesFromDic:(NSInteger)(5)     Type:kColType];
            
            // 递归实现数据筛选
            if (dic_StationID) {
                [dic_StationID   removeAllObjects];
                [dic_StationID   release];
                dic_StationID   = nil;
            }
            dic_StationID   =   [[NSMutableDictionary    alloc]init];
            
            [self           dataSort:arr_StationID       inDic:&dic_StationID];
        }
            break;
        case kCancelRule:
        {
            [optWindow      orderOut:nil];
            [NSApp          endSheet:optWindow];
            return;
        }
            break;
        default:
            break;
    }
    
    // switch to another view to chose the config
    // declare CGSTransitionSpec
	int handle = -1;
	CGSTransitionSpec spec;
	
	spec.unknown1 = 0;
	spec.type = (CGSTransitionType)CGSWarpFade;
	spec.option = (CGSTransitionOption)CGSInOut;
	spec.backColour = 0;
	spec.wid = [window  windowNumber];
	
	CGSConnection cgs = _CGSDefaultConnection();
	
	// Create a transition
	CGSNewTransition(cgs, &spec, &handle);
    [firstView      setHidden:YES];
    [secondView     setHidden:NO];
    
    /* Pass the connection, handle, and duration to apply the animation */
	CGSInvokeTransition(cgs, handle, 1);
	
	/* We need to wait for the transition to finish before we get rid of it */
	usleep((useconds_t)(1000000 * 1));
	
	//	Release our variables
	CGSReleaseTransition(cgs, handle);
	handle = 0;
    
    //reload tableview
    [tvCfgList      reloadData];
    [tvPckList      reloadData];
}

- (IBAction)dataAdd:(id)sender
{
    switch (iSenderTagNoEnter)
    {
        case kConfigRule:
            if (-1 != [tvCfgList selectedRow]) {
                [arr_CasePick    addObject:[[dic_Config allKeys] objectAtIndex:[tvCfgList   selectedRow]]];
            }else
            {
                Alert(@"请选择数据。");
            }
            break;
        case kStationIdRule:
            if (-1 != [tvCfgList selectedRow]) {
                [arr_CasePick    addObject:[[dic_StationID allKeys] objectAtIndex:[tvCfgList   selectedRow]]];
            }else
            {
                Alert(@"请选择数据。");
            }
            break;
        default:
            break;
    }
    
    [tvPckList      reloadData];
}

- (IBAction)dataDel:(id)sender
{
    if (-1 != [tvPckList selectedRow])
    {
        [arr_CasePick   removeObjectAtIndex:[tvPckList  selectedRow]];
    }else
    {
        Alert(@"请选择要删除的内容。");
    }
    
    [tvPckList      reloadData];
}

- (IBAction)enterToBack:(id)sender
{
    [firstView      setHidden:NO];
    [secondView     setHidden:YES];

}


#pragma mark    - Deal the Data -

- (NSMutableArray  *)dealTheSrc  : (NSInteger)_index  Type: (SAGetType)_type
{
    // source data from .csv    
    NSMutableArray      *arrReturn  = [NSMutableArray   array];
    switch (_type)
    {
        case kRowType:
            // get the data source by row, keep some basic info like: itemname or limits
            arrReturn       = (NSMutableArray *)[[arrSepareted objectAtIndex:_index]componentsSeparatedByString:@","];
            break;
        case kColType:
        {
            // get the data source by col
            for ( NSInteger  i = 1; i<[arrSepareted count]-1; i++ )
            {
                NSAutoreleasePool   *poolTmp = [[NSAutoreleasePool alloc] init];
                NSArray     *arrLineSpr = nil;
                NSString    *suchLine   = [arrSepareted objectAtIndex:i];
                arrLineSpr      = [suchLine componentsSeparatedByString:@","];
                if ([arrLineSpr count] > _index)
                    [arrReturn   addObject:[arrLineSpr objectAtIndex:_index]];
                else
                    NSLog(@"Index (%ld) over array size (%ld)",_index,[arrLineSpr count]);
                [poolTmp drain];
            }
        }
            break;
        default:
            break;
    }

    return          arrReturn;
}

- (NSMutableArray   *)getValuesFromDic :(NSInteger)index   Type: (SAGetType)type
{
    NSAutoreleasePool   *pool = [[NSAutoreleasePool alloc] init];
    NSMutableArray      *mlArr_Ret      = [NSMutableArray   array];
    NSMutableIndexSet   *indexes        = nil;
    switch (type)
    {
        case kRowType:
        {
            mlArr_Ret       = [self           dealTheSrc:index  Type:type];
            indexoffsetX    = 11;     // start test is at index 11 of col default as PDCA format
            // remove garbage data
            indexes         = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, indexoffsetX)];
            [mlArr_Ret      removeObjectsAtIndexes:indexes];
        }
            break;
        case kColType:
        {
            mlArr_Ret       = [self           dealTheSrc:index  Type:type];
            indexoffsetY    = 7;     // as PDCA format
            indexes         = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(0, indexoffsetY)];
            [mlArr_Ret      removeObjectsAtIndexes: indexes];
        }
            break;
        default:
            break;
    }
    [mlArr_Ret  retain];
    [pool       drain];
    return  [mlArr_Ret autorelease];
}

#pragma mark    - Table View DataSource -
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    switch ([tableView tag]) {
        case 0:
            return [arr_SrcList count];
            break;
        case 1:
            return [arr_TestItems count];
            break;
        case 2:
        {
            switch (iSenderTagNoEnter)
            {
                case kConfigRule:
                    return [[dic_Config allKeys]count];
                    break;
                case kStationIdRule:
                    return [[dic_StationID allKeys]count];
                    break;
                default:
                    break;
            }
        }
            break;
        case 3:
            return [arr_CasePick    count];
            break;
            
        default:
            break;
    }
    return  0;
}

- (id)tableView:(NSTableView*)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex
{
    NSAutoreleasePool   *pool = [[NSAutoreleasePool alloc]init];
    id      theRecode = nil;

    switch ([tableView tag]) {
        case 0:
            theRecode = [arr_SrcList objectAtIndex:rowIndex];
            break;
        case 1:
            if([[tableColumn identifier] isEqualToString:@"Items"])
            {
                theRecode = [arr_TestItems objectAtIndex:rowIndex];
                
            }else if([[tableColumn identifier] isEqualToString:@"DownLimit"])
            {
                theRecode = [arr_LowerLimits objectAtIndex:rowIndex];
            }
            else
            {
                theRecode = [arr_UpperLimits objectAtIndex:rowIndex];
            }
            break;
        case 2:
        {
            switch (iSenderTagNoEnter)
            {
                case kConfigRule:
                    theRecode   = [[dic_Config    allKeys]objectAtIndex:rowIndex];
                    break;
                case kStationIdRule:
                    theRecode   = [[dic_StationID    allKeys]objectAtIndex:rowIndex];
                    break;
                default:
                    break;
            }
        }
            break;
        case 3:
            theRecode   = [arr_CasePick     objectAtIndex:rowIndex];
            break;
            
        default:
            break;
    }

    [pool drain];
    return theRecode;
}

#pragma mark    - Table View Delegate -
- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSTableView     *tvSender   = [notification object];
    NSInteger       selectIndex = [tvSender selectedRow];
    
    switch ([tvSender tag]) {
        case 0:
        {
            if (arrSepareted) {
                [arrSepareted        release];
                arrSepareted    = nil;
            }
            
            // source data from .csv
            NSString        *strSourceTmp   = [NSString     stringWithContentsOfFile:[arr_fileLogsPath objectAtIndex:selectIndex] encoding:NSASCIIStringEncoding error:nil];
            arrSepareted  = [[strSourceTmp  componentsSeparatedByString:@"\n"]retain];
            
            // sometimes the source is seperated by "\r"
            if ([arrSepareted count] == 1) {
                arrSepareted = [[strSourceTmp   componentsSeparatedByString:@"\r"]retain];
            }
            [self           selectSrcData];
        }
            break;
        case 1:
        {
            // get test values of the item which be clicked
            arr_TestValues          = [[NSMutableArray   alloc]initWithArray:[self getValuesFromDic:(indexoffsetX+selectIndex)     Type:kColType]];

            // the plot's range
            yRange      = [arr_TestValues count];
            
            // get the spec
            strLowLimit = [arr_LowerLimits  objectAtIndex:selectIndex];
            strUpLimit  = [arr_UpperLimits  objectAtIndex:selectIndex];
            strItemName = [arr_TestItems    objectAtIndex:selectIndex];
            
            // insert code here......
            if (idx_IndexSetFnl && [idx_IndexSetFnl count]!=0) {
                [arr_TestValues      removeObjectsAtIndexes:idx_IndexSetFnl];

            }
            
            // draw graphics
            // value is too huge, like FCMB/BCMB
            for (long  i =0;   i<[arr_TestValues count];   i++)
            {
                if ([[arr_TestValues objectAtIndex:i]length]>19) {
                    [arr_TestValues  replaceObjectAtIndex:i  withObject:[NSString stringWithFormat:@"\"%@\"",[arr_TestValues objectAtIndex:i]]];
                }
                else
                    break;
            }
            [self           generateData];
            [self           renderInLayer:hostView];
            [hostView       setNeedsDisplay:YES];
            [hostView       display];
            
            // show feedback infomation
            [self           feedBackInformation];
            
            [arr_TestValues  release];
        }
            break;

        default:
            break;
    }
}

#define ThreadsATime    4
- (void)runLoopRun
{
    NSAutoreleasePool   *pool   = [[NSAutoreleasePool    alloc]init];
    NSRunLoop   *runLoop    = [NSRunLoop    currentRunLoop];
    [runLoop    addTimer:myTimer forMode:NSDefaultRunLoopMode];
    NSLog(@"%@",[NSNumber   numberWithBool:[myTimer isValid]]);
    [runLoop    run];
    [pool       drain];
}

- (void)timeTicks
{
    NSAutoreleasePool       *pool   = [[NSAutoreleasePool    alloc]init];
    myClock.second++;
    if (myClock.second == 60) {
        myClock.second  = 0;
        myClock.minute++;
        if (myClock.minute == 60) {
            myClock.minute  = 0;
            myClock.hour++;
        }
    }
    NSString    *strTime    = [NSString     stringWithFormat:@"%@:%@:%@", myClock.hour<10?[NSString stringWithFormat:@"0%d",myClock.hour]:[NSString stringWithFormat:@"%d",myClock.hour], myClock.minute<10?[NSString stringWithFormat:@"0%d",myClock.minute]:[NSString stringWithFormat:@"%d",myClock.minute],  myClock.second<10?[NSString stringWithFormat:@"0%d",myClock.second]:[NSString stringWithFormat:@"%d",myClock.second]];
    [txtTimeCost     setStringValue:[NSString    stringWithFormat:@"%@",strTime]];
    [pool    drain];
}

// each time , run 3~4 threads about the item
- (void)runThreadForThePro
{
    int     iAllCounts  = [arr_TestItems    count];
    int     iInterNal   = iAllCounts/ThreadsATime;
    for (int i=0; i<ThreadsATime; i++)
    {
        [NSThread    detachNewThreadSelector:@selector(fillTheProAndSave:) toTarget:self withObject:[NSDictionary  dictionaryWithObjectsAndKeys:[NSNumber  numberWithInt:i*iInterNal], @"START_INDEX", [NSNumber   numberWithInt:(i+1)==ThreadsATime? iAllCounts: (i+1)*iInterNal], @"END_INDEX", nil]];
    }
}

- (void)runTheMop_Up
{
    // stop the timer
    [myTimer        invalidate];
    
    // export to excel
    [self           exportToExcel:nil];
    [optWindow      orderOut:nil];
    [NSApp          endSheet:optWindow];
}

- (void)updateProcess
{
    int     iAllCounts  = [arr_TestItems    count];
    dProcessPerformed   = g_iCount*1.0/iAllCounts;
    [txtProcess         setStringValue:[NSString    stringWithFormat:@"saving images...%d%s",(int)(dProcessPerformed*100),"%"]];
    [indicator          setDoubleValue:(dProcessPerformed*100)];
    [firstView          display];       // redraw the view
    
    if (g_iCount == iAllCounts)
        [self       runTheMop_Up];

}

- (void)fillTheProAndSave   : (NSDictionary     *)dicPara
{
    NSAutoreleasePool   *pool   = [[NSAutoreleasePool alloc]init];
    
    [myLock         lock];

    NSInteger       iStart      = [[dicPara  objectForKey:@"START_INDEX"]intValue];
    NSInteger       iEnd        = [[dicPara  objectForKey:@"END_INDEX"]intValue];
    for ( NSInteger    i =iStart; i<iEnd ; i++ )
    {
        NSAutoreleasePool   *subPool    = [[NSAutoreleasePool alloc]init];
        // get test values of the item which be clicked
        arr_TestValues      = [[NSMutableArray   alloc]initWithArray:[self getValuesFromDic:(i+indexoffsetX)   Type:kColType]];
        
        // the plot's range
        yRange      = [arr_TestValues count];
        
        // get the spec
        strLowLimit = [arr_LowerLimits  objectAtIndex:i];
        strUpLimit  = [arr_UpperLimits  objectAtIndex:i];
        strItemName = [arr_TestItems    objectAtIndex:i];
        
        // insert code here......
        if (idx_IndexSetFnl && [idx_IndexSetFnl count]!=0) {
            [arr_TestValues      removeObjectsAtIndexes:idx_IndexSetFnl];
        }
        
        // draw graphics
        // value is too huge, like FCMB/BCMB
        for (NSInteger  i =0;   i<[arr_TestValues count];   i++)
        {
            if ([[arr_TestValues objectAtIndex:i]length]>19) {
                [arr_TestValues  replaceObjectAtIndex:i  withObject:[NSString stringWithFormat:@"\"%@\"",[arr_TestValues objectAtIndex:i]]];
            }
            else
                break;
        }
        
        // this loop is to visit all the configs need to save
        if( 0 != [arr_CasePick count] )
        {
            for ( NSString   *key    in  arr_CasePick )
            {
                // mulcopy the testvalues
                NSMutableArray  *mlArr_TestValuesCpy     = [[NSMutableArray  alloc]initWithArray:arr_TestValues];
                // get the data of the config or stationid u pick
                switch (iSenderTagNoEnter)
                {
                    case kConfigRule:
                        [arr_TestValues removeAllObjects];
                        [arr_TestValues addObjectsFromArray:[mlArr_TestValuesCpy  objectsAtIndexes:
                                                             [dic_Config objectForKey:key]]];
                        break;
                    case kStationIdRule:
                        [arr_TestValues removeAllObjects];
                        [arr_TestValues addObjectsFromArray:[mlArr_TestValuesCpy  objectsAtIndexes:
                                                             [dic_StationID objectForKey:key]]];
                        break;
                    default:
                        break;
                }
                // generate the data for plot charts
                [self           generateData];
                // render the plot in view
                [self           renderInLayer:hostView];
                // redraw the view  ,   u can mark it when u donot wanna see any process in view
                [hostView       setNeedsDisplay:YES];
                [hostView       display];
                // feed back info
                [self           performSelectorOnMainThread:@selector(feedBackInformation) withObject:nil waitUntilDone:YES];
                // save the graphs
                [self           saveImage:nil FolderName:key];
                // copy back
                [arr_TestValues removeAllObjects];
                [arr_TestValues addObjectsFromArray:mlArr_TestValuesCpy];
                [mlArr_TestValuesCpy     release];
            }
        }
        else
        {
            // generate the data for plot charts
            [self           generateData];
            // render the plot in view
            [self           renderInLayer:hostView];
            // redraw the view  ,   u can mark it when u donot wanna see any process in view
            [hostView       setNeedsDisplay:YES];
            [hostView       display];
            // feed back info
            [self           performSelectorOnMainThread:@selector(feedBackInformation) withObject:nil waitUntilDone:YES];
            // save the graphs
            [self           saveImage:nil FolderName:nil];
        }
        [arr_TestValues      release];
        [subPool             drain];
        
        g_iCount++;
        [self       performSelectorOnMainThread:@selector(updateProcess) withObject:nil waitUntilDone:NO];
    }
    
    [myLock     unlock];

    [pool    drain];
}

// single thread
- (void)saveAllandExport
{
    // this loop is to save all data as image and export into excel
    NSInteger    iAllCounts  = [arr_TestItems count];
    for (NSInteger    i =0; i<iAllCounts ; i++ )
    {
        // process infomation
        NSAutoreleasePool   *pool   = [[NSAutoreleasePool alloc]init];
        dProcessPerformed   = i*1.0/iAllCounts;
        [txtProcess         setStringValue:[NSString    stringWithFormat:@"saving images...%d%s",(int)(dProcessPerformed*100),"%"]];
        [indicator          setDoubleValue:(dProcessPerformed*100)];
        [firstView          display];       // redraw the view
        
        // get test values of the item which be clicked
        arr_TestValues      = [[NSMutableArray   alloc]initWithArray:[self getValuesFromDic:(i+indexoffsetX)   Type:kColType]];

        // the plot's range
        yRange      = [arr_TestValues count];
        
        // get the spec
        strLowLimit = [arr_LowerLimits  objectAtIndex:i];
        strUpLimit  = [arr_UpperLimits  objectAtIndex:i];
        strItemName = [arr_TestItems    objectAtIndex:i];
        
        // insert code here......
        if (idx_IndexSetFnl && [idx_IndexSetFnl count]!=0) {
            [arr_TestValues      removeObjectsAtIndexes:idx_IndexSetFnl];
        }
        
        // draw graphics
        // value is too huge, like FCMB/BCMB
        for (NSInteger  i =0;   i<[arr_TestValues count];   i++)
        {
            if ([[arr_TestValues objectAtIndex:i]length]>19) {
                [arr_TestValues  replaceObjectAtIndex:i  withObject:[NSString stringWithFormat:@"\"%@\"",[arr_TestValues objectAtIndex:i]]];
            }
            else
                break;
        }
        
        // this loop is to visit all the configs need to save
        if( 0 != [arr_CasePick count] )
        {
            for ( NSString   *key    in  arr_CasePick )
            {
                // mulcopy the testvalues
                NSMutableArray  *mlArr_TestValuesCpy     = [[NSMutableArray  alloc]initWithArray:arr_TestValues];
                // get the data of the config or stationid u pick
                switch (iSenderTagNoEnter)
                {
                    case kConfigRule:
                        [arr_TestValues removeAllObjects];
                        [arr_TestValues addObjectsFromArray:[mlArr_TestValuesCpy  objectsAtIndexes:
                                                             [dic_Config objectForKey:key]]];
                        break;
                    case kStationIdRule:
                        [arr_TestValues removeAllObjects];
                        [arr_TestValues addObjectsFromArray:[mlArr_TestValuesCpy  objectsAtIndexes:
                                                             [dic_StationID objectForKey:key]]];
                        break;
                    default:
                        break;
                }
                // generate the data for plot charts
                [self           generateData];
                // render the plot in view
                [self           renderInLayer:hostView];
                // redraw the view  ,   u can mark it when u donot wanna see any process in view
                [hostView       setNeedsDisplay:YES];
                [hostView       display];
                // feed back info
                [self           feedBackInformation];
                // save the graphs
                [self           saveImage:nil FolderName:key];
                // copy back
                [arr_TestValues removeAllObjects];
                [arr_TestValues addObjectsFromArray:mlArr_TestValuesCpy];
                [mlArr_TestValuesCpy     release];
                
            }
        }
        else
        {
            // generate the data for plot charts
            [self           generateData];
            // render the plot in view
            [self           renderInLayer:hostView];
            // redraw the view  ,   u can mark it when u donot wanna see any process in view
            [hostView       setNeedsDisplay:YES];
            [hostView       display];
            // feed back info
            [self           feedBackInformation];
            // save the graphs
            [self           saveImage:nil FolderName:nil];
        }
        [arr_TestValues      release];
        [pool                drain];
    }
    
    // stop the timer
    [myTimer        invalidate];
    
    // export to excel
    [self           exportToExcel:nil];
    [optWindow      orderOut:nil];
    [NSApp          endSheet:optWindow];
    
}


#pragma mark    - auto save and export -
- (IBAction)autoSaveAndExport:(id)sender
{
    // initial
    [txtProcess         setStringValue:@"saving images..."];
    [indicator          setDoubleValue:0];
    
    [NSApp      beginSheet:optWindow modalForWindow:window modalDelegate:self didEndSelector:nil contextInfo:nil];
    
}


#pragma mark    - generate the data -
- (NSArray   *)ascendData : (NSMutableArray  *)_marray
{
    if ([_marray count] == 1) {
        return _marray;
    }
    NSArray     *sortedArray = [_marray sortedArrayUsingComparator:^(id obj1,  id obj2)
                                {
                                    if (([obj1 doubleValue] < [obj2 doubleValue])) {
                                        return (NSComparisonResult)NSOrderedAscending;
                                    }
                                    if (([obj1 doubleValue] > [obj2 doubleValue])) {
                                        return (NSComparisonResult)NSOrderedDescending;
                                    }
                                    return (NSComparisonResult)NSOrderedSame;
                                }];
    //NSLog(@"%@",sortedArray);
    return sortedArray;
}

#pragma mark    - generate data and render the layer -
// 这里我本应把2个柱状图的datasrc分开的，为了省事，结果╮(╯▽╰)╭
- (void)generateData
{
    // get the ascending sorted array
    NSArray     *sortedArr = [self ascendData:arr_TestValues];
    NSInteger   i = 0, j = [sortedArr count]-1;
    minValue_x    = [[sortedArr objectAtIndex:i]doubleValue];
    maxValue_x    = [[sortedArr objectAtIndex:j]doubleValue];
    minScale_x    = NOLOWLMT ? minValue_x : MIN(minValue_x, [strLowLimit doubleValue]);
    maxScale_x    = NOHIGHLMT ? maxValue_x : MAX(maxValue_x, [strUpLimit doubleValue]);
    majorticks_x  = (maxScale_x-minScale_x)/(SAMPLENUM);
    maxScale_y    = 0;
    NSMutableArray  *contentArray = [NSMutableArray array];
    unsigned int    count  = 0;
    for(int n=0, m=0; n<j || m<=SAMPLENUM; n++)
    {
        if (majorticks_x == 0 /*sometimes all values and specs are the same*/) {
            [contentArray addObject:[NSDecimalNumber numberWithInt:(int)[sortedArr count]]];
            maxScale_y  = 1.2*(int)[sortedArr count];
            break;
        }
        if (j==0) {
            [contentArray addObject:[NSDecimalNumber numberWithInt:1]]; // only 1 data left
            maxScale_y  = 1.2;
            break;
        }
        if ((minScale_x+1.0*majorticks_x*m<=[[sortedArr objectAtIndex:n] doubleValue]) && ([[sortedArr objectAtIndex:n]doubleValue]<minScale_x+1.0*majorticks_x*(m+1))) {
            count++;
        }
        if (n==j) {
            [contentArray addObject:[NSDecimalNumber numberWithInt:count]];
            m++;
            n=0;
            maxScale_y = (count>maxScale_y)?count:maxScale_y;
            count=0;
        }
    }
    
    // offset as space
    for (int l=0; l<OFFSET; l++) {
        [contentArray insertObject:[NSDecimalNumber numberWithInt:0] atIndex:0];
    }

    // offset as space
    for (int l=0; l<OFFSET; l++) {
        [contentArray addObject:[NSDecimalNumber numberWithInt:0]];
    }
    
    // low spec
    BOOL    bFlagLow    = NO,   bFlagHigh   = NO;
    if (NOLOWLMT)
    {
        bFlagLow    = YES;
        dlocationoffset_low = 0.0;
        [contentArray addObject:[NSDecimalNumber numberWithInt:0]];
    }else
        [contentArray addObject:[NSDecimalNumber numberWithInt:maxScale_y*1.2]];
    if (!bFlagLow)
    {
        if (minScale_x == [strLowLimit doubleValue])
            dlocationoffset_low     = 0.0;
        else
            dlocationoffset_low     = (([strLowLimit doubleValue]-minScale_x)/majorticks_x);
    }

    // high spec
    if (NOHIGHLMT)
    {
        bFlagHigh   = YES;
        dlocationoffset_high    = 0.0;
        [contentArray addObject:[NSDecimalNumber numberWithInt:0]];
    }else
        [contentArray addObject:[NSDecimalNumber numberWithInt:maxScale_y*1.2]];
    if (!bFlagHigh)
    {
        if (maxScale_x == [strUpLimit doubleValue])
            dlocationoffset_high    = 0.0;
        else
            dlocationoffset_high    = (([strUpLimit doubleValue]-maxScale_x)/majorticks_x);
    }
    plotData    ? [plotData release] : NSLog(@"plotData NA");
    plotData    = [contentArray copy];
}

- (void)labelRenderInLayer  : (CPTGraphHostingView *)layHostingView
{
    // add static label
    [layHostingView     addSubview:stctxtAverageValue];
    [layHostingView     addSubview:stctxtDownlimit];
    [layHostingView     addSubview:stctxtFailCount];
    [layHostingView     addSubview:stctxtFailHigh];
    [layHostingView     addSubview:stctxtFailLow];
    [layHostingView     addSubview:stctxtMaxValue];
    [layHostingView     addSubview:stctxtMinValue];
    [layHostingView     addSubview:stctxtStdeviation];
    [layHostingView     addSubview:stctxtTotalCount];
    [layHostingView     addSubview:stctxtUplimit];
    
    // add info label
    [layHostingView     addSubview:txtAverageValue];
    [layHostingView     addSubview:txtDownlimit];
    [layHostingView     addSubview:txtFailCount];
    [layHostingView     addSubview:txtFailHigh];
    [layHostingView     addSubview:txtFailLow];
    [layHostingView     addSubview:txtMaxValue];
    [layHostingView     addSubview:txtMinValue];
    [layHostingView     addSubview:txtStdeviation];
    [layHostingView     addSubview:txtTotalCount];
    [layHostingView     addSubview:txtUplimit];
}

- (void)labelRemoveInLayer  : (CPTGraphHostingView  *)layHostingView
{
    // rmv  static label
    [stctxtAverageValue     removeFromSuperview];
    [stctxtDownlimit        removeFromSuperview];
    [stctxtFailCount        removeFromSuperview];
    [stctxtFailHigh         removeFromSuperview];
    [stctxtFailLow          removeFromSuperview];
    [stctxtMaxValue         removeFromSuperview];
    [stctxtMinValue         removeFromSuperview];
    [stctxtStdeviation      removeFromSuperview];
    [stctxtTotalCount       removeFromSuperview];
    [stctxtUplimit          removeFromSuperview];
    
    // rmv  info label
    [txtAverageValue        removeFromSuperview];
    [txtDownlimit           removeFromSuperview];
    [txtFailCount           removeFromSuperview];
    [txtFailHigh            removeFromSuperview];
    [txtFailLow             removeFromSuperview];
    [txtMaxValue            removeFromSuperview];
    [txtMinValue            removeFromSuperview];
    [txtStdeviation         removeFromSuperview];
    [txtTotalCount          removeFromSuperview];
    [txtUplimit             removeFromSuperview];
}

- (void)renderInLayer: (CPTGraphHostingView *)layHostingView
{    
    // Create graph from theme
    NSAutoreleasePool       *pool   = [[NSAutoreleasePool    alloc]init];
    CPTXYGraph    *graph   = [[(CPTXYGraph   *)[CPTXYGraph alloc]initWithFrame:CGRectZero]autorelease];
    CPTTheme      *theme = [CPTTheme themeNamed:kCPTSlateTheme];
	[graph         applyTheme:theme];
	layHostingView.hostedGraph = graph;
    
    // Add subviews
    [self    labelRenderInLayer:layHostingView];
            
    graph.paddingLeft   = 250.0f;
    graph.paddingRight  = 7.0f;
    graph.paddingTop    = 7.0f;
    graph.paddingBottom = 7.0f;
    graph.plotAreaFrame.paddingLeft	  += 80.0;
	graph.plotAreaFrame.paddingTop	  += 25.0;
	graph.plotAreaFrame.paddingRight  += 20.0;
	graph.plotAreaFrame.paddingBottom += 40.0;
    
    // Add plot space for bar charts
	CPTXYPlotSpace *barPlotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
	barPlotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.5f) length:CPTDecimalFromFloat(SAMPLENUM+3+OFFSET*2)];
	barPlotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromInt(maxScale_y*1.3)];
	[graph addPlotSpace:barPlotSpace];
    
	// Create grid line styles
	CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
	majorGridLineStyle.lineWidth = 1.0;
	majorGridLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:0.75];
    
	// Create axes
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
	CPTXYAxis *x		  = axisSet.xAxis;
	{
		x.majorIntervalLength		  = CPTDecimalFromDouble(RAND_MAX);
		x.minorTicksPerInterval		  = 0;
		x.orthogonalCoordinateDecimal = CPTDecimalFromInteger(0);
		x.majorGridLineStyle		  = majorGridLineStyle;
		x.axisLineStyle				  = nil;
		x.majorTickLineStyle		  = nil;
		x.minorTickLineStyle		  = nil;
		x.labelFormatter			  = nil;
        x.labelingPolicy              = CPTAxisLabelingPolicyNone;
	}
    
    //  Set the x labels
    NSMutableArray *customLabels      = [NSMutableArray arrayWithCapacity :[plotData count]];
    static CPTTextStyle * labelTextStyle= nil ;
    labelTextStyle  =[[[CPTTextStyle alloc] init]autorelease];;
    
    unsigned int    count   = 0;
    for (double dvalue =minScale_x; dvalue <=maxScale_x; dvalue +=majorticks_x)
    {
        NSAutoreleasePool       *subPool    = [[NSAutoreleasePool    alloc]init];
        if (majorticks_x == 0 || (dvalue == 0 && maxScale_x == 0))
        {
            NSString    *strTick    = @"Stephen's tick";
            strTick                 = [NSString stringWithFormat:@"%.2f",dvalue];
            CPTAxisLabel *newLabel  = [[[CPTAxisLabel   alloc]initWithText:strTick textStyle:labelTextStyle]autorelease];
            newLabel.tickLocation   = CPTDecimalFromInt(OFFSET+count);
            [customLabels   addObject:newLabel];
            [subPool        drain];
            break;
        }
        if (dvalue  == [strLowLimit doubleValue])
        {
            // for the maxscale is so near the minscale
            NSString    *strTick    = @"Stephen's tick";
            if ((maxScale_x-minScale_x)<10)
            {
                strTick     = [NSString stringWithFormat:@"%.1f",dvalue];
            }
            else
            {
                strTick     = (dvalue>=5000)?[NSString stringWithFormat:@"%.1e",dvalue]:[NSString stringWithFormat:@"%d",(int)(dvalue>0?(dvalue+0.5):(dvalue-0.5))];
            }
            CPTAxisLabel *newLabel  = [[[CPTAxisLabel   alloc]initWithText:strTick textStyle:labelTextStyle]autorelease];
            newLabel.tickLocation   = CPTDecimalFromInt(OFFSET+count);
            [customLabels   addObject:newLabel];
        }
        else
        if (fabs(maxScale_x - dvalue) < majorticks_x)
        {
            NSString    *strTick    = @"Stephen's tick";
            if ((maxScale_x-minScale_x)<10)
            {
                strTick     = [NSString stringWithFormat:@"%.1f",maxScale_x];
            }
            else
            {
                strTick     = (dvalue>=5000)?[NSString stringWithFormat:@"%.1e",maxScale_x]:[NSString stringWithFormat:@"%d",(int)(maxScale_x>0?(maxScale_x+0.5):(maxScale_x-0.5))];
            }
            CPTAxisLabel *newLabel  = [[[CPTAxisLabel   alloc]initWithText:strTick textStyle:labelTextStyle]autorelease];

            newLabel.tickLocation   = CPTDecimalFromInt([plotData count]-3-OFFSET);
            [customLabels   addObject:newLabel];
        }
        else
        {
            if (count%LABELINTERNAL == 0)
            {
                NSString    *strTick    = @"Stephen's tick";
                if ((maxScale_x-minScale_x)<10)
                {
                    strTick     = [NSString stringWithFormat:@"%.1f",dvalue];
                }
                else
                {
                    strTick     = (dvalue>=5000)?[NSString stringWithFormat:@"%.1e",dvalue]:[NSString stringWithFormat:@"%d",(int)(dvalue>0?(dvalue+0.5):(dvalue-0.5))];
                }
                CPTAxisLabel *newLabel  = [[[CPTAxisLabel   alloc]initWithText:strTick textStyle:labelTextStyle]autorelease];

                newLabel.tickLocation   = CPTDecimalFromInt(OFFSET+count);
                [customLabels   addObject:newLabel];
            }
        }
        [subPool     drain];
        count++;
    }
    
    x.axisLabels    = [NSSet setWithArray:customLabels];
    
	CPTXYAxis *y = axisSet.yAxis;
	{
		y.majorIntervalLength		  = CPTDecimalFromInteger([arr_TestValues count]/5);
		y.minorTicksPerInterval		  = 0;
		y.orthogonalCoordinateDecimal = CPTDecimalFromDouble(0);
		y.preferredNumberOfMajorTicks = 8;
		y.majorGridLineStyle		  = majorGridLineStyle;
		y.axisLineStyle				  = nil;
		y.majorTickLineStyle		  = nil;
		y.minorTickLineStyle		  = nil;
		y.labelOffset				  = 10.0;
		y.labelRotation				  = 0.0;
		y.labelingPolicy			  = CPTAxisLabelingPolicyAutomatic;
	}
    
	// Create a bar line style
	CPTMutableLineStyle *barLineStyle = [[[CPTMutableLineStyle alloc] init] autorelease];
	barLineStyle.lineWidth = 1.0;
	barLineStyle.lineColor = [CPTColor whiteColor];
    
	// Create bar plot
	CPTBarPlot *barPlot = [[[CPTBarPlot alloc] init] autorelease];
	barPlot.lineStyle		  = barLineStyle;
	barPlot.barWidth		  = CPTDecimalFromFloat(0.85f); // bar is 85% of the available space
	barPlot.barCornerRadius	  = 0.0;
	barPlot.barsAreHorizontal = NO;
	barPlot.dataSource		  = self;
	barPlot.identifier		  = @"Bar Plot 1";
    // Fill color set
    barPlot.fill              = [CPTFill fillWithColor:[CPTColor colorWithComponentRed:0 green:0 blue:1 alpha:1]];
    
	[graph addPlot:barPlot];
    
    // Create second bar plot as spec
    CPTBarPlot  *barPlot2     = [[[CPTBarPlot alloc] init] autorelease];
    barPlot2.lineStyle        = barLineStyle;
    barPlot2.barWidth         = CPTDecimalFromCGFloat(0.4f);
    barPlot2.barCornerRadius  = 2.0;
	barPlot2.barsAreHorizontal= NO;
    barPlot2.dataSource       = self;
    barPlot2.identifier       = @"Bar Plot 2";
    barPlot2.fill             = [CPTFill fillWithColor:[CPTColor colorWithComponentRed:1.0 green:0.0 blue:0.0 alpha:1]];
    
    [graph addPlot:barPlot2];
    
    [pool        drain];
}

#pragma mark    - Plot Data Source Methods -

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    if ([plot.identifier isEqual:@"Bar Plot 1"]) {
        return plotData.count-2;
    }else{
        return 2;
    }
}

-(NSArray *)numbersForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndexRange:(NSRange)indexRange
{
	NSArray     *nums   =   nil;

	switch ( fieldEnum ) {
		case CPTBarPlotFieldBarLocation:
            // location
            if ([plot.identifier isEqual:@"Bar Plot 1"])
            {
                nums = [NSMutableArray arrayWithCapacity:indexRange.length];
                for ( NSUInteger i = indexRange.location; i < NSMaxRange(indexRange); i++ )
                {
                    [(NSMutableArray *) nums addObject:[NSDecimalNumber numberWithUnsignedInteger:i]];
                }
            }else
            {
                nums = [NSMutableArray arrayWithCapacity:2];
                double lowLmtPos   = OFFSET+dlocationoffset_low;
                double highLmtPos  = [plotData count]-OFFSET-3+dlocationoffset_high;
                // if lowlimit is so near to highlimit
                if ((highLmtPos-lowLmtPos)<1.0)
                {
                    [(NSMutableArray *) nums addObject:[NSDecimalNumber numberWithFloat:lowLmtPos-0.5]];
                    [(NSMutableArray *) nums addObject:[NSDecimalNumber numberWithFloat:highLmtPos+0.5]];
                }
                else
                {
                    [(NSMutableArray *) nums addObject:[NSDecimalNumber numberWithFloat:lowLmtPos]];
                    [(NSMutableArray *) nums addObject:[NSDecimalNumber numberWithFloat:highLmtPos]];
                }

            }
			break;
            
		case CPTBarPlotFieldBarTip:
            // length
            if ([plot.identifier isEqual:@"Bar Plot 1"])
            {
                nums    = [NSArray  arrayWithArray:plotData];
            }else
            {
                nums = [NSMutableArray arrayWithCapacity:2];
                [(NSMutableArray *) nums addObject:[plotData    objectAtIndex:[plotData count]-2]];
                [(NSMutableArray *) nums addObject:[plotData    objectAtIndex:[plotData count]-1]];
            }
			break;
            
		default:
			break;
	}
    
	return  nums;
}

#pragma mark    - feed back some info to usr -

- (BOOL)judgeSpec : (NSString   *)_value withUpLmt :(NSString  *)_uplimit andLowLmt :(NSString  *)_lowlimit
{
    BOOL    bLowThanUpLmt   = NO,   bHighThanLowLmt    = NO;
    if ([[_uplimit uppercaseString] rangeOfString:@"NA"].location != NSNotFound || [[_uplimit uppercaseString] rangeOfString:@"N/A"].location != NSNotFound) {
        bLowThanUpLmt   = YES;
    }else{
        bLowThanUpLmt   = ([_value doubleValue]<=[_uplimit doubleValue])?YES:NO;
    }
    if ([[_lowlimit uppercaseString] rangeOfString:@"NA"].location != NSNotFound || [[_lowlimit uppercaseString] rangeOfString:@"N/A"].location != NSNotFound) {
        bHighThanLowLmt = YES;
    }else{
        bHighThanLowLmt = ([_value doubleValue]>=[_lowlimit doubleValue])?YES:NO;
    }
    
    return bLowThanUpLmt && bHighThanLowLmt;
}

- (int)judgeSpecRet : (NSString   *)_value withUpLmt :(NSString  *)_uplimit andLowLmt :(NSString  *)_lowlimit
{
    if ([_value doubleValue]>[_uplimit doubleValue] && [[_uplimit uppercaseString] rangeOfString:@"NA"].location == NSNotFound && [[_uplimit uppercaseString] rangeOfString:@"N/A"].location == NSNotFound && [_uplimit isNotEqualTo:@""]) {
        return 1;
    }
    if ([_value doubleValue]<[_lowlimit doubleValue] && [[_lowlimit uppercaseString] rangeOfString:@"NA"].location == NSNotFound && [[_lowlimit uppercaseString] rangeOfString:@"N/A"].location == NSNotFound && [_lowlimit isNotEqualTo:@""]) {
        return -1;
    }
    return 0;
}

- (void)feedBackInformation
{
    // count
    unsigned    int iTotalCount = (unsigned    int)[arr_TestValues count];
    
    // avg
    double          dSum        = 0.0f;
    for (int    i=0; i<iTotalCount; i++)
    {
        dSum    += [[arr_TestValues objectAtIndex:i]doubleValue];
    }
    double          dAverage    = dSum/iTotalCount;
    
    // std
    double          dStdevition = 0.0f;
    for (int    i=0; i<iTotalCount; i++)
    {
        // at here , fuck!!!
        // (#‵′)凸
        dStdevition += pow(([[arr_TestValues objectAtIndex:i]doubleValue]-dAverage), 2);
    }
    dStdevition = sqrt(dStdevition/iTotalCount);
    
    // fail count
    unsigned    int iFailCount    = 0,  iFailHigh   = 0,    iFailLow    = 0;
    for (int    i=0; i<iTotalCount; i++)
    {
        int    iRet   = [self judgeSpecRet:[arr_TestValues objectAtIndex:i] withUpLmt:strUpLimit andLowLmt:strLowLimit];
        if (iRet>0) {
            iFailHigh++;
            iFailCount++;
        }
        else
            if (iRet<0)
            {
                iFailLow++;
                iFailCount++;
            }
            else
            {
                // pass
            }
    }
    
    // fail rate
    float       fFailRata       = iFailCount*1.0/iTotalCount;
    float       fFailRataHigh   = iFailHigh*1.0/iTotalCount;
    float       fFailRataLow    = iFailLow*1.0/iTotalCount;
    
    [txtTotalCount          setStringValue:[NSString    stringWithFormat:@"%d",iTotalCount]];
    [txtAverageValue        setStringValue:dAverage>RAND_MAX?[NSString    stringWithFormat:@"%.2e",dAverage]:[NSString    stringWithFormat:@"%.3f",dAverage]];
    [txtStdeviation         setStringValue:dStdevition>RAND_MAX?[NSString    stringWithFormat:@"%.2e",dStdevition]:[NSString    stringWithFormat:@"%.3f",dStdevition]];
    [txtMaxValue            setStringValue:maxValue_x>RAND_MAX?[NSString    stringWithFormat:@"%.2e",maxValue_x]:[NSString    stringWithFormat:@"%.3f",maxValue_x]];
    [txtMinValue            setStringValue:minValue_x>RAND_MAX?[NSString    stringWithFormat:@"%.2e",minValue_x]:[NSString    stringWithFormat:@"%.3f",minValue_x]];
    [txtDownlimit           setStringValue:[NSString    stringWithFormat:@"%@",[strLowLimit stringByReplacingOccurrencesOfString:@"\r" withString:@""]]];
    [txtUplimit             setStringValue:[NSString    stringWithFormat:@"%@",[strUpLimit stringByReplacingOccurrencesOfString:@"\r" withString:@""]]];
    [txtFailCount           setStringValue:[NSString    stringWithFormat:@"%d : %.3f%s",iFailCount,fFailRata*100,"%"]];
    [txtFailHigh            setStringValue:[NSString    stringWithFormat:@"%d : %.3f%s",iFailHigh,fFailRataHigh*100,"%"]];
    [txtFailLow             setStringValue:[NSString    stringWithFormat:@"%d : %.3f%s",iFailLow,fFailRataLow*100,"%"]];
    
    
    if (iFailCount) {
        [txtFailCount       setTextColor:[NSColor   redColor]];
    }else
        [txtFailCount       setTextColor:nil];
    if (iFailHigh) {
        [txtFailHigh        setTextColor:[NSColor   redColor]];
        [txtMaxValue        setTextColor:[NSColor   redColor]];
    }else
    {
        [txtFailHigh        setTextColor:nil];
        [txtMaxValue        setTextColor:nil];
    }
    if (iFailLow) {
        [txtFailLow         setTextColor:[NSColor   redColor]];
        [txtMinValue        setTextColor:[NSColor   redColor]];
    }else
    {
        [txtFailLow         setTextColor:nil];
        [txtMinValue        setTextColor:nil];
    }
}

#pragma mark    - save image and export into excel -
// i was to die when coding this module, i creat a new nsview instance rather than using the hostView, which is so stupid
- (BOOL)image_SaveToPath: (NSString     *)_strPath
{
    NSAutoreleasePool       *pool   = [[NSAutoreleasePool    alloc]init];
    // create paths to output images
    NSString        *jpgPath  = [_strPath     stringByAppendingPathComponent:[NSString  stringWithFormat:@"/%@.jpg",[strItemName stringByReplacingOccurrencesOfString:@"/" withString:@"_"]]];
    
    CGRect imageFrame = hostView.frame;
    
    CGSize boundsSize = imageFrame.size;
    
    NSBitmapImageRep    *layerImage = [[NSBitmapImageRep alloc]
                                    initWithBitmapDataPlanes:NULL
                                    pixelsWide:boundsSize.width
                                    pixelsHigh:boundsSize.height
                                    bitsPerSample:8
                                    samplesPerPixel:4
                                    hasAlpha:YES
                                    isPlanar:NO
                                    colorSpaceName:NSCalibratedRGBColorSpace
                                    bytesPerRow:(NSInteger)boundsSize.width * 4
                                    bitsPerPixel:32];
    
    // get context
    NSGraphicsContext   *bitmapContext  = [NSGraphicsContext    graphicsContextWithBitmapImageRep:layerImage];
    CGContextRef        context        = (CGContextRef) [bitmapContext graphicsPort];
    CGContextClearRect(context, CGRectMake(imageFrame.origin.x, imageFrame.origin.y, boundsSize.width, boundsSize.height));
    CGContextSetAllowsAntialiasing(context, true);
    CGContextSetShouldSmoothFonts(context, false);
    [hostView.layer    renderInContext:context];
    CGContextFlush(context);
    
    NSImage             *image  = [[NSImage  alloc]  initWithSize:NSSizeFromCGSize(boundsSize)];
    [image          addRepresentation:layerImage];
    [layerImage     release];
    
    [image          lockFocus];
    NSBitmapImageRep    *layerImage2    = [[NSBitmapImageRep alloc]initWithFocusedViewRect: CGRectMake(0, 0, boundsSize.width, boundsSize.height)];
    [image          unlockFocus];
    [image          release];
    
    // set the properties
    NSDictionary        *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:0] forKey:NSImageInterlaced];

    NSData              *screendata   = [layerImage2 representationUsingType:NSJPEGFileType properties:imageProps];
    [layerImage2    release];
    
    // create file manager
    NSFileManager       *fileMgr = [NSFileManager defaultManager];
    
    // create the super folder
    if (![fileMgr fileExistsAtPath:[_strPath stringByDeletingLastPathComponent]]) {
        [fileMgr     createDirectoryAtPath:[_strPath stringByDeletingLastPathComponent] withIntermediateDirectories:NO attributes:nil error:nil];
    }
    // create the sub folder
    if (![fileMgr fileExistsAtPath:_strPath]) {
        [fileMgr     createDirectoryAtPath:_strPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    BOOL    bRet = NO;
    bRet    = [screendata  writeToFile:jpgPath atomically:YES];
    [arr_ImagePath   addObject:jpgPath];
    
    [pool       drain];
    
    return  bRet;
}

- (IBAction)saveImage:(id)sender  FolderName: (NSString *)strFolderName
{
    BOOL    bRet = NO;
    bRet    = [self    image_SaveToPath:[NSString   stringWithFormat:@"%@/Desktop/Charts/%@",NSHomeDirectory(),strFolderName?strFolderName:@"Graphics"]];
    if (!bRet) {
        Alert(@"保存图片失败。");
    }
}

- (BOOL)image_ExportToExcel: (NSMutableArray    *)_imagePaths
{
    //  creat a new workbook
    BookHandle      book    = xlCreateXMLBookCA();
    if (book)
    {
        // creat a new sheet
        SheetHandle     sheet   = xlBookAddSheetA(book, "sheet1", 0);
        
        // set text format
        FontHandle      font    = xlBookAddFontA(book, 0);
        xlFontSetNameA(font, "Impact");
        xlFontSetSizeA(font, 16);
        FormatHandle    format  = xlBookAddFormatA(book, NULL);
        xlFormatSetFontA(format, font);
        
        // add pictures
        if (sheet)
        {
            NSString  *strImgPath = @"";
            unsigned    iAllCount   = [_imagePaths count];
            for (unsigned   i =0; i<iAllCount; i++)
            {
                // get the image
                strImgPath      = [_imagePaths objectAtIndex:i];
                int iRet        = xlBookAddPictureA(book, [strImgPath UTF8String]);
                strImgPath      = [strImgPath lastPathComponent];
                if (strImgPath && [strImgPath length]>4) {
                    //strImgPath  = [strImgPath substringToIndex:[strImgPath length]-4];
                    strImgPath  = [strImgPath   stringByDeletingPathExtension];
                }
                else
                {
                    Alert(@"图片路径有误") NO;
                }
                
                unsigned    iSubCount   = [arr_CasePick count];
                if( 0 != iSubCount )
                {                    
                    strImgPath      = [NSString     stringWithFormat:@"%@ (%@)",strImgPath,[arr_CasePick objectAtIndex:(i%iSubCount)]];
                    if (iRet == -1)
                    {
                        return NO;
                    }else
                    {
                        xlSheetWriteStrA(sheet, 6+35*(i%iSubCount), 7+19*(i/iSubCount), [strImgPath UTF8String], format);
                        xlSheetSetPictureA(sheet, 7+35*(i%iSubCount), 7+19*(i/iSubCount), iRet, 1.1);
                    }
                }
                else
                {
                    if (iRet == -1)
                    {
                        return NO;
                    }
                    else
                    {
                        xlSheetWriteStrA(sheet, 35*i+6, 7, [strImgPath UTF8String], format);
                        xlSheetSetPictureA(sheet, 35*i+7, 7, iRet, 1.3);
                    }
                }
            }
        }
    }
    
    // 设置路径前先注意所在路径权限问题
    xlBookSave(book, [[NSString   stringWithFormat:@"%@/Desktop/Charts/Charts.xlsx",NSHomeDirectory()] UTF8String]);
    xlBookRelease(book);
    
    //  next round will repick
    [arr_CasePick    removeAllObjects];
    
    return YES;
}

- (IBAction)exportToExcel:(id)sender
{
    BOOL    bRet    = NO;
    bRet    = [self    image_ExportToExcel: arr_ImagePath];
    if (!bRet) {
        Alert(@"图片导入Excel失败。");
    }

    //  remove all images
    if ([arr_ImagePath   count]) {
        [arr_ImagePath  removeAllObjects];
    }
}

@end
