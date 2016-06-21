//
//  ToSummaryLogToolAppDelegate.m
//  ToSummaryLogTool
//
//  Created by Pleasure on 12-8-27.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "ToSummaryLogToolAppDelegate.h"

@implementation ToSummaryLogToolAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [m_tableView setDataSource:self];
    [lTotalCount setIntValue:0];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:window];
}

-(void)windowWillClose:(NSNotification *)notification
{
    [NSApp terminate:self];
}

-(id)init
{
    self=[super init];
    if (self) {
        bstop=NO;
        m_aryTable=[[NSMutableArray alloc]init];
    }
    return self;
}
-(void)awakeFromNib
{
    [window setTitle:@"Combine Single CSV Log to Summary Log"];
    [pIndicator setMinValue:0];
    [pIndicator setMaxValue:[m_aryTable count]];
    [txtIndicator setDoubleValue:0];
}

-(void)dealloc
{
    [m_aryTable release];
    [super dealloc];
}

/*-(void)savelog:(NSString **)szResult
{
    NSSavePanel *saveFile = [NSSavePanel savePanel];
    if ([saveFile runModal] == NSOKButton)
    {
        *szResult = [saveFile filename];
    }
}*/

-(IBAction)ChooseCSVFiles:(id)sender

{
    [pIndicator setDoubleValue:0];
    [txtIndicator setDoubleValue:0];

    m_myPanel=[NSOpenPanel openPanel];
    [m_myPanel setCanChooseFiles:YES];
    [m_myPanel setAllowsMultipleSelection:YES];
    if([m_myPanel runModalForTypes:[NSArray arrayWithObject:@"csv"]]==NSOKButton)
        {
            NSArray *arrCSVFiles=[m_myPanel filenames];
            for(NSString *szCSVFile in arrCSVFiles)
            {
                [m_aryTable addObject:szCSVFile]; 
            }
        }
    [lTotalCount setIntValue:[m_aryTable count]];
    [m_tableView reloadData];
}
-(void)CreatAndWriteSummaryLog:(NSString *)szInfo paraDictionary:(NSDictionary*)dicParams withPath:(NSString *)szPath
{
    if (macro_W_Summary) 
    {
        NSString *szDirectory = [szPath stringByDeletingLastPathComponent];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:szDirectory]) {
            [fileManager createDirectoryAtPath:szDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        }
        szInfo = [NSString stringWithFormat:@"%@\n",szInfo];
        NSFileHandle *h_SummaryLog = [NSFileHandle fileHandleForWritingAtPath:szPath];
        
        NSString *szStationName = [dicParams objectForKey:@"stationName"];
        NSString *szVersion = [dicParams objectForKey:@"softVersion"];
        NSString *szItemsNames = [dicParams objectForKey:@"testNames"];
        NSString *szUpLimits = [dicParams objectForKey:@"upperLimits"];
        NSString *szDnLimits = [dicParams objectForKey:@"downLimits"];
        NSMutableString *strComma = [[NSMutableString alloc] initWithString:@""];
        
        NSString *szComma    = @",";
        NSArray  *arrCount    = [szUpLimits componentsSeparatedByString:szComma];
        int      iCount       = [arrCount count];
        for (int i = 0; i<= iCount + 4; i++) {
            [strComma appendFormat:@"%@",szComma];
        }
        
        NSString *szTitle = [NSString stringWithFormat:@"Muifa Station:%@  Version:%@%@",szStationName,szVersion,strComma];
        NSMutableString *szItemName = [NSMutableString stringWithFormat:@"SerialNumber,Test Pass/Fail Status,List of Failing Tests,Error Description,Test Start Time,Test Stop Time,Config%@",szItemsNames];
        
        if (!h_SummaryLog) {
            
            szInfo = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n%@",szTitle,szItemName,[NSString stringWithFormat:@"Upper Limit ----->,,,,,,%@",szUpLimits],[NSString stringWithFormat:@"Lower Limit ----->,,,,,,%@",szDnLimits],[NSString stringWithFormat:@"Measurement Unit -----> %@",strComma],szInfo];
            [szInfo writeToFile:szPath atomically:NO encoding:NSUTF8StringEncoding error:nil];
        }
        else
        {
            NSData *dataTemp = [[NSData alloc] initWithBytes:(void *)[szInfo UTF8String] length:[szInfo length]];
            [h_SummaryLog seekToEndOfFile];
            [h_SummaryLog writeData:dataTemp];
            [dataTemp release];
            [h_SummaryLog closeFile];
        }
        [strComma release];
           
    }
}

//Paser single csv logs which we choose to get the length of testitems is max .
-(BOOL)ParserCsv:(NSMutableArray *)arrFiles GetItems:(NSMutableArray *)items
{
    NSError *error;
    m_arrDnLimit = [[NSMutableArray alloc] init];
    m_arrUpLimit = [[NSMutableArray alloc] init];
    BOOL bSameStation=[self compare:arrFiles];
    if (bSameStation) 
    {
        for (NSString * szCsvPath in arrFiles) 
        {
            NSString *strCSVLogs = [NSString stringWithContentsOfFile:szCsvPath encoding:NSASCIIStringEncoding error:&error];
            NSArray *arrLogs = [strCSVLogs componentsSeparatedByString:@"\n"];
            if ([arrLogs count]>8) 
            {
                NSArray *arrFile2=[[arrLogs objectAtIndex:3] componentsSeparatedByString:@","];
                m_Version=[arrFile2 objectAtIndex:2];
                for (int i=4; i<[arrLogs count]-4; i++) 
                {
                    NSArray *arrSingleLine = [[arrLogs objectAtIndex:i] componentsSeparatedByString:@","];
                    if ([items containsObject:[arrSingleLine objectAtIndex:0]]) 
                    {
                        continue;   
                    }
                    else
                    {
                        [items addObject:[arrSingleLine objectAtIndex:0]];
                        [m_arrDnLimit addObject:[arrSingleLine objectAtIndex:3]];
                        [m_arrUpLimit addObject:[arrSingleLine objectAtIndex:4]];
                    }
                     
                 
                }
            }
            else
            {
                NSRunAlertPanel(@"Warning", @"The CSV log formate is not right!", @"OK",nil,nil);
                [m_textField setStringValue:@"wrong Formate"];
                [m_textField setTextColor: [NSColor  redColor]];
                bstop = YES;
               // [pIndicator stopAnimation:nil];
                return NO;
            }
        }
        return YES; 
    }
   else
   {
       return NO;
   }
}
//compare whether the station name of the logs we choose is the same 
-(BOOL)compare:(NSMutableArray *)arrCSVlogs
{
    NSError *error;
    NSInteger i;
    NSMutableArray *arrStationNames=[[NSMutableArray alloc]init];
    if ([arrCSVlogs count]>0) 
    {
        for (NSString * szCsvPath in arrCSVlogs) 
        {
            NSString *strCSVLogFiles = [NSString stringWithContentsOfFile:szCsvPath encoding:NSASCIIStringEncoding error:&error];
            NSArray *arrLogFiles = [strCSVLogFiles componentsSeparatedByString:@"\n"];
            if ([arrLogFiles count]>8) 
            {
                NSArray *arrFile1=[[arrLogFiles objectAtIndex:1] componentsSeparatedByString:@","];
                NSString *szAllStationName=[arrFile1 objectAtIndex:2];
                NSArray *arrFile2=[szAllStationName componentsSeparatedByString:@"_"];
                NSString *szStationName=[arrFile2 lastObject];
                [arrStationNames addObject:szStationName];      
            }
            
        }
        for (i=0; i<[arrStationNames count]; i++) 
        {
            NSString *szName=[arrStationNames objectAtIndex:i];
            if ([szName isEqualToString:[arrStationNames objectAtIndex:0]]) 
            {
                m_MuifaStation=[arrStationNames objectAtIndex:0];
            }  
            else
            { 
                NSRunAlertPanel(@"Warning", @"The CSV log don't choose the same station log,Please choose again !", @"OK",nil,nil);
                [m_textField setStringValue:@"Not the same station"];
                [m_textField setTextColor: [NSColor  redColor]];
                [arrStationNames release];
                bstop = YES;
                //[pIndicator stopAnimation:nil];
                return NO;
            }
        }
        [arrStationNames release];
        return YES;
    }
    else
    {
         NSRunAlertPanel(@"Warning", @"Please make sure you have add the single csvs!", @"OK",nil,nil);
        [m_textField setStringValue:@"No Csv files"];
        [m_textField setTextColor: [NSColor  redColor]];
        [arrStationNames release];
        bstop = YES;
        //[pIndicator stopAnimation:nil];
        return NO;
    }
    
}

//combine single csv to summary log
-(void)CombineFunction:(id)iThread
{
    while (!bstop) 
    {
        NSAutoreleasePool *pool = [[NSAutoreleasePool  alloc] init];
        NSError *error;
        NSMutableArray  *arrItems=[[NSMutableArray alloc] init];
        NSMutableArray  *arrValue=[[NSMutableArray alloc] init];
        NSMutableString *szUPLimit=[[NSMutableString alloc] init];
        NSMutableString *szDownLimit=[[NSMutableString alloc] init];
        NSMutableString *szTestName=[[NSMutableString alloc] init];
        NSMutableString *szTestValue=[[NSMutableString alloc] init];
        NSMutableString *m_strStatus=[[NSMutableString alloc] init];
        NSMutableArray *arrIndex = [[NSMutableArray alloc] init];
        NSString *m_State;
        int index=0 ;
        BOOL bPaser = [self ParserCsv:m_aryTable GetItems:arrItems];
        
        if (bPaser) 
        {
            NSString *szDate = [[NSDate date] descriptionWithCalendarFormat:@"%Y-%m-%d %H-%M-%S" timeZone:nil locale:nil];
            // NSString *strPath = [NSMutableString stringWithFormat:@"%@/Desktop/%@_Summary_%@.csv",NSHomeDirectory(),m_MuifaStation,szDate];
           /* NSFileHandle *h_SummaryLog = [NSFileHandle fileHandleForWritingAtPath:strPath]; 
            if (h_SummaryLog) 
            {
                NSRunAlertPanel(@"Warning", @"The summary log has exist,Please change the name!", @"OK",nil,nil);
                [self savelog:&strPath];
            }*/
             for(int k =0; k<[m_aryTable count]; k++)
                {
                    [szUPLimit setString:@""];
                    [szDownLimit setString:@""];
                    [szTestName setString:@""];
                    [szTestValue setString:@""];
                    [m_strStatus setString:@""];
                    [arrIndex removeAllObjects];
                    [arrValue removeAllObjects];
                    NSString *strCSVLog=[NSString stringWithContentsOfFile:[m_aryTable objectAtIndex:k] encoding:NSASCIIStringEncoding error:&error];
                    NSArray *arrCSVLog=[strCSVLog componentsSeparatedByString:@"\n"];
                    
                    for (int i=4; i<[arrCSVLog count]-4; i++) 
                    {
                        NSArray *arrSingleLine=[[arrCSVLog objectAtIndex:i] componentsSeparatedByString:@","];
                        NSString *szTestItem=[arrSingleLine objectAtIndex:0];
                        NSString *szValue = [arrSingleLine objectAtIndex:2];
                        NSRange  range = [szValue rangeOfString:@"\""];
                        if (range.location != NSNotFound &&range.length >0&& (range.length+range.location)<= [szValue length] )
                        {
                            szValue = [szValue substringFromIndex:range.location+range.length];
                            range = [szValue rangeOfString:@"\""];
                            if (range.location != NSNotFound &&range.length >0&& (range.length+range.location)<= [szValue length]) 
                            {
                                szValue = [szValue substringToIndex:range.location];
                            }
                        }
                        
                        index = [arrItems indexOfObject:szTestItem];
                        //[arrValue insertObject:szValue atIndex:i];
                        [arrValue addObject:szValue];
                        [arrIndex addObject:[NSNumber numberWithInt:index]];
                       
                    }
                    
                    for (int i= 0; i<[arrItems count];i++) 
                    {
                        if ([arrIndex containsObject:[NSNumber numberWithInt:i]]) 
                        {
                            [szTestValue appendFormat:@",%@",[arrValue objectAtIndex:[arrIndex indexOfObject:[NSNumber numberWithInt:i]]]];
                        }
                        else
                        {
                            [szTestValue appendFormat:@",NA"];
                        }
                        [szTestName appendFormat:@",%@",[arrItems objectAtIndex:i]];
                        [szUPLimit appendFormat:@",%@",[m_arrUpLimit objectAtIndex:i]];
                        [szDownLimit appendFormat:@",%@",[m_arrDnLimit objectAtIndex:i]];
                        
                    }
                    NSString *startTime=[[[arrCSVLog objectAtIndex:[arrCSVLog count]-3] componentsSeparatedByString:@","] objectAtIndex:2];
                    NSString *endTime=[[[arrCSVLog objectAtIndex:[arrCSVLog count]-2] componentsSeparatedByString:@","] objectAtIndex:2];
                    NSString *ISNnumber=[[[arrCSVLog objectAtIndex:[arrCSVLog count]-4] componentsSeparatedByString:@","] objectAtIndex:2];
                    
                    for (int j=1;j< [arrCSVLog count]; j++)
                    {
                        NSString *szState=[[[arrCSVLog objectAtIndex:j] componentsSeparatedByString:@","] objectAtIndex:1];
                        [m_strStatus appendFormat:@",\"%@\"",szState];
                        
                    }
                    if ([m_strStatus rangeOfString:@"1"].location==NSNotFound)
                    {
                        m_State=@"PASS";
                    }
                    else
                    {
                        m_State=@"FAIL"; 
                    }
                    
                    //write summary log
                   NSString *strPath = [NSString stringWithFormat:@"/vault/Combine_SingleCSV/%@/%@_%@.csv",m_MuifaStation,m_MuifaStation,szDate];
                    NSDictionary *dicInParams=[NSDictionary dictionaryWithObjectsAndKeys:m_MuifaStation,@"stationName",m_Version,@"softVersion",szTestName,@"testNames",szUPLimit,@"upperLimits",szDownLimit,@"downLimits", nil];
                    NSString *szInfo=[NSString stringWithFormat:@"%@,%@,NA,NA,%@,%@,BringUp%@",ISNnumber,m_State,startTime,endTime,szTestValue];
                    [self CreatAndWriteSummaryLog:szInfo paraDictionary:dicInParams withPath:strPath];
                    NSString *number=[[NSNumber numberWithInt:k+1] stringValue];
                    [pIndicator setStringValue:number];
                    //NSString *szString=[NSString stringWithFormat:@"%d/%d",k+1,[m_aryTable count]];
                    NSString *myString=[NSString stringWithFormat:@"%.2f%%",(float)(k+1)*100/[m_aryTable count] ];
                    [txtIndicator setStringValue:myString];
                    //[savepath setStringValue:strPath];
                } 
                [m_textField setStringValue:@"Combine OK"];
                [m_textField setTextColor: [NSColor  greenColor]]; 
                
            //[pIndicator stopAnimation:nil];
            bstop = YES;
            
        }
        [combine setEnabled:YES];
        [arrItems release];
        [szUPLimit release];
        [szDownLimit release];
        [szTestName release];
        [szTestValue release];
        [m_strStatus release];
        [m_arrUpLimit release];
        [m_arrDnLimit release];
        [arrIndex release];
        [arrValue release];
        [pool drain];
    }
    
    
}
-(IBAction)DeleteCSVFile:(NSButton *)sender
{
    [pIndicator setDoubleValue:0];
    [txtIndicator setDoubleValue:0];

    int i = [mtDelete selectedRow];
    if (i==0) 
    {
        int iRow = [m_tableView selectedRow];
        if (iRow>=0) 
        {
            NSString *szDelFile=[m_aryTable objectAtIndex:iRow];
            [m_aryTable removeObject:szDelFile];
        }
        else
        {
            NSRunAlertPanel(@"Warning", @"Please make sure you have choose csv to delete!", @"OK",nil,nil);
        }
    }
    else
    {
        [m_aryTable removeAllObjects];
    }
    [lTotalCount setIntValue:[m_aryTable count]];
    [m_tableView reloadData];
}
-(IBAction)Combine:(id)sender
{
    bstop=NO;
    [combine setEnabled:NO];
    [pIndicator setMinValue:0];
    [pIndicator setMaxValue:[m_aryTable count]];
   // [pIndicator startAnimation:nil];
    [NSThread detachNewThreadSelector:@selector(CombineFunction:) toTarget:self withObject:nil];
}
-(IBAction)help:(id)sender
{
    [self change];
    if ([help state]==YES) 
    {
        [combine setEnabled:NO];
        [chooseCSVFile setEnabled:NO];
        [deleteCSVFile setEnabled:NO];
        [mtDelete setEnabled:NO];
    }
    else
    {
        [combine setEnabled:YES];
        [chooseCSVFile setEnabled:YES];
        [deleteCSVFile setEnabled:YES];
         [mtDelete setEnabled:YES];
    }
    
}

-(void)change
{
    int handle=-1;
    CGSTransitionSpec spec;
    
    spec.unknown1 = 0;
    spec.type = CGSFlip;
    spec.option = (CGSLeft| 128);
    spec.backColour = 0;
    spec.wid = [window windowNumber];
    
    CGSConnection cgs = _CGSDefaultConnection();
    
    // Create a transition
    CGSNewTransition(cgs, &spec, &handle);
    
    [vTable setHidden:![vTable isHidden]];
    [vHelp setHidden:![vHelp isHidden]];
    
    // Redraw the window
    [window display];
    
    /* Pass the connection, handle, and duration to apply the animation */
    CGSInvokeTransition(cgs, handle, 1);
    
    /* We need to wait for the transition to finish before we get rid of it */
    usleep((useconds_t)(1000000 * 1));
    
    //	Release our variables
    CGSReleaseTransition(cgs, handle);
    handle=0; 
}

#pragma mark ++++++++++++Delegate+++++++++++++
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [m_aryTable count];
    
}
-(id)tableView:(NSTableView *)tableView 
objectValueForTableColumn:(NSTableColumn *)tableColumn 
           row:(NSInteger)row
{
    return [m_aryTable objectAtIndex:row];    
  
}
@end
