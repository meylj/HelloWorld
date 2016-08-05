//
//  AppDelegate.m
//  ILoveMuifa
//
//  Created by Yaya8_liu on 6/2/16.
//  Copyright © 2016 Yaya8_liu. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (assign) IBOutlet NSWindow *window;
@end

#define kMuifa_Window_Point_X                   12
#define kMuifa_Window_Point_Y                   100
#define kMuifa_Window_Size_Width                [[NSScreen mainScreen] visibleFrame].size.width
#define kMuifa_Window_Size_Height               [[NSScreen mainScreen] visibleFrame].size.height

#pragma mark ############################## Table view tag ##############################
#define kTag_TableView_CSVLog                   0
//#define kTag_TableView_UartLog                  1
#define kTag_TableView_FailItems                1

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [_window setTitle:@"ILoveMuifa"];
    NSRect rectForwindow = NSMakeRect(kMuifa_Window_Point_X, kMuifa_Window_Point_Y, kMuifa_Window_Size_Width, kMuifa_Window_Size_Height);
    [_window setFrame:rectForwindow display:YES];
    [_window center];
    
    [lbResultLabel setBackgroundColor:[NSColor orangeColor]];
    [lbResultLabel setStringValue:@"READY"];
    [lbPercentageNumber setStringValue:@"0%"];
    [levelIndicator setFloatValue:0.00];
    [lbUnitMark setStringValue:@"Unit1"];
    [lbUnitMark setBackgroundColor:[NSColor yellowColor]];
    
    [self LoadVerticalView];
    
    // set data source and delegete
    [tvCSVInfo		setDelegate:self];
    [tvCSVInfo		setDataSource:self];
    [tvUARTInfo		setDelegate:self];
    [tvUARTInfo		setDataSource:self];
    [tvFailInfo		setDelegate:self];
    [tvFailInfo		setDataSource:self];
    [tabTestInfo	setDelegate:self];
    
    m_arrCSVInfo = [[NSMutableArray alloc] init];
    m_arrFailInfo = [[NSMutableArray alloc] init];
    [textViewFailInfo setString:@""];
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return YES;
}

-(void)dealloc
{
    [m_arrCSVInfo release];
    [m_arrFailInfo release];
    [super dealloc];
}

- (void)LoadVerticalView
{
    NSView *contentView = [_window contentView];
    NSSize thisViewSize = NSMakeSize(contentView.frame.size.width - 6, contentView.frame.size.height - 40);
    
    NSView	 * aCustomLeftView = [[NSView alloc] initWithFrame:NSMakeRect(6,
                                                                          0,
                                                                          thisViewSize.width * 0.25,
                                                                          thisViewSize.height - 2)];
    
    NSTabView * aCustomTabView = [[NSTabView alloc] initWithFrame:NSMakeRect(6 + thisViewSize.width * 0.25,
                                                                             0,
                                                                             thisViewSize.width * 0.75 - 2,
                                                                             thisViewSize.height - 2)];
    
    [aCustomTabView setTabViewType:NSLeftTabsBezelBorder];
    [aCustomTabView setFont:[NSFont fontWithName:@"Arial" size:10]];
    
    // SN input view
    [inputView setFrame:NSMakeRect(2,
                                   aCustomLeftView.frame.size.height - inputView.frame.size.height,
                                   aCustomLeftView.frame.size.width - 2,
                                   inputView.frame.size.height)];
    
    // Brief view
    [briefView setFrame:NSMakeRect(2,
                                   inputView.frame.origin.y - briefView.frame.size.height - 6,
                                   aCustomLeftView.frame.size.width - 6,
                                   briefView.frame.size.height)];
    
    // List View
    [listView setFrame:NSMakeRect(5,
                                  0,
                                  aCustomTabView.frame.size.width - 55,
                                  aCustomTabView.frame.size.height - 18)];
    // Add Test list view
    NSTabViewItem * tabViewItem = [[NSTabViewItem alloc] init];
    NSTextField	 * textField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0,
                                                                             aCustomTabView.frame.size.width - 42,
                                                                             aCustomTabView.frame.size.height - 20)];
    NSColor	*colorUnit	= [NSColor colorWithCalibratedRed:0xF4/255
                                                   green:0xd7/255
                                                    blue:0x00/255
                                                   alpha:(float)1];
    [textField setBackgroundColor:colorUnit];
    [textField setEditable:NO];
    [[tabViewItem view] setAutoresizesSubviews:NO];
    [[tabViewItem view] addSubview:textField];
    [[tabViewItem view] addSubview:listView];
    [tabViewItem setLabel:@"Unit1"];
    [aCustomTabView addTabViewItem:tabViewItem];
    [aCustomLeftView addSubview:inputView];
    [aCustomLeftView addSubview:briefView];

    [[_window contentView] addSubview:aCustomLeftView];
    [[_window contentView] addSubview:aCustomTabView];
    [lbPath setEditable:YES];
    [lbPath setEnabled:YES];
    [_window makeFirstResponder:lbPath];
    [textField release];
    [aCustomLeftView release];
    [aCustomTabView release];
    [tabViewItem release];
}

- (IBAction)openLog:(id)sender
{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:NO];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel beginSheetModalForWindow:_window completionHandler:^(NSInteger result)
     {
         if(NSFileHandlingPanelOKButton == result)
         {
             NSString *strURL = [[[openPanel URLs] objectAtIndex:0] path];
             if (strURL)
             {
                 [lbPath setStringValue:strURL];
             }
         }
     }];
}

- (IBAction)startTest:(id)sender
{
    NSString *szLogPath = [lbPath stringValue];
    if (!szLogPath || [szLogPath isEqualToString:@""])
    {
        ATSRunAlertPanel(@"Alert", @"Please input log lbPath", @"OK", nil, nil);
        return;
    }
    
    [btnStart setEnabled:NO];
    [lbResultLabel setStringValue:@"Testing"];
    [lbResultLabel setBackgroundColor:[NSColor orangeColor]];
    
    [m_arrCSVInfo removeAllObjects];
    [m_arrFailInfo removeAllObjects];
    
    //Start parser log.
    [self ParserLog:szLogPath];
    [btnStart setEnabled:YES];
}

-(NSNumber*)ParserLog:(NSString*)szLogPath
{
    NSLog(@"Start ParserLog");
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:szLogPath])
    {
        ATSRunAlertPanel(@"Alert", @"I can not find log, please check your log lbPath", @"OK", nil, nil);
        return @NO;
    }
    NSArray *arrLogList = [fileManager contentsOfDirectoryAtPath:szLogPath error:nil];
    
    if ([arrLogList count] > 5)
    {
        ATSRunAlertPanel(@"Sorry", @"I found the file counts in folder > 5, are you sure you choose right log folder? Please remove some unuse file,and retry. ", @"OK", nil, nil);
        [lbPath setStringValue:@""];
        return @YES;
    }
    
    NSMutableString *strCSV = [[NSMutableString alloc] init];
    NSMutableString *strUART = [[NSMutableString alloc] init];
    NSMutableString *strDEBUG = [[NSMutableString alloc] init];
    NSError *error = nil;
    for(int i = 0; i < [arrLogList count]; i++)
    {
        NSString *strOneLog = [arrLogList objectAtIndex:i];
        NSString *strOneLogPath = [NSString stringWithFormat:@"%@/%@",szLogPath,strOneLog];
        if ([strOneLog containsString:@"Uart.txt"])
        {
            //Uart log
            [strUART setString: [NSString stringWithContentsOfFile:strOneLogPath encoding:NSUTF8StringEncoding error:nil]];
            NSString *strStationID = [strUART subByRegex:@"STATION: (.*?)\n" name:nil error:&error];
            NSString *strOverlayVer = [strUART subByRegex:@"Overlay_Version : (.*?)\n" name:nil error:&error];
            if (!error)
            {
                //Show Station id On Muifa UI.
                [_window setTitle:[NSString stringWithFormat:@"%@_%@",strStationID,strOverlayVer]];
            }
        }
        else if([strOneLog containsString:@"DEBUG.txt"])
        {
            //DEBUG log
            [strDEBUG setString: [NSString stringWithContentsOfFile:strOneLogPath encoding:NSUTF8StringEncoding error:nil]];

            
        }
        else if([strOneLog containsString:@"CSV.csv"])
        {
            //CSV log
            [strCSV setString: [NSString stringWithContentsOfFile:strOneLogPath encoding:NSUTF8StringEncoding error:nil]];
            error = nil;
            NSString *strScriptFile = [strCSV subByRegex:@"TSP,0,(.*?)," name:nil error:&error];
            if (!error)
            {
                [lbScriptFile setStringValue:[NSString stringWithFormat:@"Script:%@",strScriptFile]];
            }
            error = nil;
            NSString *strTotalTestTime = [strCSV subByRegex:@"Test Cost Time,0,(.*?)," name:nil error:&error];
            if (!error)
            {
                [lbTotalTime setStringValue:strTotalTestTime];
            }
            error = nil;
            NSString *strISN = [strCSV subByRegex:@"ISN,0,(.*?)," name:nil error:&error];
            if (!error)
            {
                [lbUnitMark setStringValue:strISN];
            }
        }else
        {
            NSLog(@"I don't know what log.");
        }
    }
    
    NSArray *arrAllRows = [strCSV componentsSeparatedByString:@"\n"];
    BOOL bFinalResult = YES;
    for (int y = 4; y < [arrAllRows count]; y++)
    {
        NSString *strOneRow = [arrAllRows objectAtIndex:y];
        strOneRow = [strOneRow stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        NSArray *arrRowElement = [strOneRow componentsSeparatedByString:@","];
        if ([arrRowElement count] >= 6)
        {
            //Catch CSV file.
            NSString *strItemName = [arrRowElement objectAtIndex:0];
            NSNumber *numFunnyZoneSingleItemResult = (([[arrRowElement objectAtIndex:1] intValue] == 0 )? [NSNumber numberWithInt:1] : [NSNumber numberWithInt:0]);
            NSImage *Image = [numFunnyZoneSingleItemResult intValue] == 1? [NSImage imageNamed:NSImageNameStatusAvailable]:[NSImage imageNamed:NSImageNameStatusUnavailable];
            NSString *strReturnValue = [arrRowElement objectAtIndex:2];
            NSString *strTime = [arrRowElement objectAtIndex:5];
            if ([numFunnyZoneSingleItemResult intValue] == 0)
            {
                bFinalResult &= NO;
            }
            
            //Catch FunnyZoneConsoleMessage from Debug log.
            NSString *strSubRegex = [NSString stringWithFormat:@"^.*?(=+ START TEST %@.*?)=+ START TEST",[strItemName uppercaseString]];
            if ([strItemName containsString:@"END_TEST"])
            {
                strSubRegex = [NSString stringWithFormat:@"^.*?(=+ START TEST %@.*?)#+ END DUT",[strItemName uppercaseString]];
            }else if ([strItemName containsString:@")"] || [strItemName containsString:@"("])
            {
                NSString *strTemItemName = [strItemName stringByReplacingOccurrencesOfString:@"(" withString:@"\\("];
                strTemItemName = [strTemItemName stringByReplacingOccurrencesOfString:@")" withString:@"\\)"];
                strSubRegex = [NSString stringWithFormat:@"^.*?(=+ START TEST %@.*?)=+ START TEST",[strTemItemName uppercaseString]];
            }
            error = nil;
            NSString *strFunnyZoneConsoleMessage = [strDEBUG subByRegex:strSubRegex name:nil error:&error];
            if (error)
            {
                strFunnyZoneConsoleMessage = @"-_-!";
                error = nil;
            }
            NSMutableAttributedString *attriFunnyZoneConsoleMessage = [[NSMutableAttributedString alloc] initWithString:strFunnyZoneConsoleMessage];
            NSRegularExpression *regexConsole = [NSRegularExpression regularExpressionWithPattern:@"(\\++.*?TestResult : FAIL.*?\\++)" options:NSRegularExpressionCaseInsensitive error:NULL];
            NSArray *myArrayConsole = [regexConsole matchesInString:strFunnyZoneConsoleMessage options:0 range:NSMakeRange(0, strFunnyZoneConsoleMessage.length)] ;
            for (NSTextCheckingResult *match in myArrayConsole)
            {
                NSRange matchRange = [match rangeAtIndex:1];
                [attriFunnyZoneConsoleMessage addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:matchRange];
                NSFont *boldFont = [NSFont boldSystemFontOfSize:16];
                [attriFunnyZoneConsoleMessage addAttribute:NSFontAttributeName value:boldFont range:matchRange];
                
            }
            
            
            
            //Catch SubItem Info from Debug log.
            NSMutableArray *mutarrFunnyZoneSubItemInfo = [[NSMutableArray alloc] init];
            NSMutableString *mutstrSingleConsoleMessage = [[NSMutableString alloc] initWithString:strFunnyZoneConsoleMessage];
            NSString *strSubItemIndexRegex = [NSString stringWithFormat:@"\\+ \\[(.*?)\\]"];
            NSString *strSubItemNameRegex = [NSString stringWithFormat:@"\\++ \\[[0-9]\{1,2\}\\] (.*?) \\(TestResult"];
            NSString *strSubItemResultRegex =[NSString stringWithFormat:@"\\(TestResult : (.*?) ; "];
            NSString *strSubItemTimeRegex = [NSString stringWithFormat:@"TestResult.*?Duration : (.*?)s\\)"];
            
            for (int x = 0; x < 50; x++)
            {
                NSString *strSubItemIndex = [mutstrSingleConsoleMessage subByRegex:strSubItemIndexRegex name:nil error:&error];
                if (error)
                {
                    error = nil;
                    break;
                }
                NSString *strSubItemName = [mutstrSingleConsoleMessage subByRegex:strSubItemNameRegex name:nil error:&error];
                if (error)
                {
                    strSubItemName = @"-_-!";
                    error = nil;
                    ATSRunAlertPanel(@"Oh", @"Did not catch subitem name", @"OK", nil, nil);
                    break;
                }
                NSString *strSubItemResult = [mutstrSingleConsoleMessage subByRegex:strSubItemResultRegex name:nil error:&error];
                if (error)
                {
                    strSubItemResult = @"-_-!";
                    error = nil;
                    ATSRunAlertPanel(@"Oh", @"Did not catch subitem result", @"OK", nil, nil);
                    break;
                }
                NSString *strSubItemTime = [mutstrSingleConsoleMessage subByRegex:strSubItemTimeRegex name:nil error:&error];
                if (error)
                {
                    strSubItemTime = @"-_-!";
                    error = nil;
                    ATSRunAlertPanel(@"Oh", @"Did not catch subitem time", @"OK", nil, nil);
                    break;
                }
                NSImage *ImageSubItemResult = [strSubItemResult isEqualToString:@"PASS"]? [NSImage imageNamed:NSImageNameStatusAvailable]:[NSImage imageNamed:NSImageNameStatusUnavailable];
                [mutarrFunnyZoneSubItemInfo addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                      strSubItemIndex,@"Index",
                                                      strSubItemName,@"SubName",
                                                      ImageSubItemResult,@"SubResult",
                                                       strSubItemTime,@"DurationTime", nil]];
                [mutstrSingleConsoleMessage setString: [mutstrSingleConsoleMessage SubFrom:[NSString stringWithFormat:@"[%@] %@ (TestResult : %@ ; Duration : %@s)",strSubItemIndex,strSubItemName,strSubItemResult,strSubItemTime] include:NO]];
            }
            
            //Catch FunnyZoneUartLog from UART log.
            NSString *strUARTSubRegex = [NSString stringWithFormat:@"START TEST %@.*?=+(.*?)Item Name:",[strItemName uppercaseString]];
            NSString *strFunnyZoneUartLog = [strUART subByRegex:strUARTSubRegex name:nil error:&error];
            if (error)
            {
                error = nil;
                //Sometimes, no item Name.
                strUARTSubRegex = [NSString stringWithFormat:@"START TEST %@.*?=+(.*?)START TEST",[strItemName uppercaseString]];
                strFunnyZoneUartLog = [strUART subByRegex:strUARTSubRegex name:nil error:&error];
                if (error)
                {
                    error = nil;
                    strFunnyZoneUartLog = @"-_-!";
                }
            }
            NSMutableAttributedString *attriFunnyZoneUartLog = [[NSMutableAttributedString alloc] initWithString:strFunnyZoneUartLog];
            NSRegularExpression *regexFixture = [NSRegularExpression regularExpressionWithPattern:@"\n(.*?\\[FIXTURE\\].*?)\n" options:NSRegularExpressionCaseInsensitive error:NULL];
            NSArray *myArrayFixture = [regexFixture matchesInString:strFunnyZoneUartLog options:0 range:NSMakeRange(0, strFunnyZoneUartLog.length)] ;
            for (NSTextCheckingResult *match in myArrayFixture)
            {
                NSRange matchRange = [match rangeAtIndex:1];
                [attriFunnyZoneUartLog addAttribute:NSForegroundColorAttributeName value:[NSColor orangeColor] range:matchRange];
            }
            NSRegularExpression *regexCL200A = [NSRegularExpression regularExpressionWithPattern:@"\n(.*?\\[CL200A\\].*?)\n" options:NSRegularExpressionCaseInsensitive error:NULL];
            NSArray *myArrayCL200A = [regexCL200A matchesInString:strFunnyZoneUartLog options:0 range:NSMakeRange(0, strFunnyZoneUartLog.length)] ;
            for (NSTextCheckingResult *match in myArrayCL200A)
            {
                NSRange matchRange = [match rangeAtIndex:1];
                [attriFunnyZoneUartLog addAttribute:NSForegroundColorAttributeName value:[NSColor purpleColor] range:matchRange];
            }
            
            //Catch spec from UART log.
            NSString *strUARTSpecRegex =[NSString stringWithFormat:@"Item Name:%@, (.*?)\n",strItemName];
            if ([strItemName containsString:@")"]
                || [strItemName containsString:@"("]
                ||[strItemName containsString:@"["]
                || [strItemName containsString:@"]"])
            {
                NSString *strTemItemName1 = [strItemName stringByReplacingOccurrencesOfString:@"(" withString:@"\\("];
                strTemItemName1 = [strTemItemName1 stringByReplacingOccurrencesOfString:@")" withString:@"\\)"];
                strTemItemName1 = [strTemItemName1 stringByReplacingOccurrencesOfString:@"[" withString:@"\\["];
                strTemItemName1 = [strTemItemName1 stringByReplacingOccurrencesOfString:@"]" withString:@"\\]"];
                strUARTSpecRegex = [NSString stringWithFormat:@"Item Name:%@, (.*?)\n",strTemItemName1];
            }
            NSString *strSpec = [strUART subByRegex:strUARTSpecRegex name:nil error:&error];
            if (error)
            {
                error = nil;
                if ([arrRowElement objectAtIndex:3] == [arrRowElement objectAtIndex:4])
                {
                    strSpec = [NSString stringWithFormat:@"<%@>",[arrRowElement objectAtIndex:3]];
                }else
                {
                    strSpec = [NSString stringWithFormat:@"[%@,%@]",[arrRowElement objectAtIndex:3],[arrRowElement objectAtIndex:4]];
                }
            }
            
            NSDictionary *dicResult = [NSDictionary dictionaryWithObjectsAndKeys:
                                       strItemName,@"ItemName",
                                       numFunnyZoneSingleItemResult,@"FunnyZoneSingleItemResult",
                                       strReturnValue,@"ReturnValue",
                                       strSpec,@"Spec",
                                       strTime,@"Time",
                                       Image,@"Image",
                                       @"Unit1",@"PortIndex",
                                       [NSNumber numberWithInt:y-4],@"FunnyZoneCurrentIndex",
                                       [NSString stringWithFormat:@"[%d]",y-3],@"CurrentIndex",
                                       [NSNumber numberWithInt:(int)[arrAllRows count] - 8],@"FunnyZoneSumIndex",
                                       attriFunnyZoneConsoleMessage,@"FunnyZoneConsoleMessage",
                                       [NSArray arrayWithArray:mutarrFunnyZoneSubItemInfo],@"FunnyZoneSubItemInfo",
                                       attriFunnyZoneUartLog,@"FunnyZoneUartLog",
                                       nil];
            
            [self processNormalTest:dicResult];
            [attriFunnyZoneUartLog release];
            [attriFunnyZoneConsoleMessage release];
            [mutarrFunnyZoneSubItemInfo release];
            [mutstrSingleConsoleMessage release];
            
            if ([[strItemName uppercaseString] containsString:@"END_TEST"])
            {
                if (bFinalResult)
                {
                    [lbResultLabel setStringValue:@"PASS"];
                    [lbResultLabel setBackgroundColor:[NSColor greenColor]];
                }else
                {
                    [lbResultLabel setStringValue:@"FAIL"];
                    [lbResultLabel setBackgroundColor:[NSColor redColor]];
                }
                break;
            }
           
        }
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
    }
    
    [strCSV release];
    [strUART release];
    [strDEBUG release];
    return @YES;
}

-(void)processNormalTest:(NSDictionary*)dicResult
{
    BOOL			bResult		= [[dicResult objectForKey:@"FunnyZoneSingleItemResult"] boolValue];
    if	(!bResult)
    {
        @synchronized(m_arrFailInfo)
        {
            [m_arrFailInfo addObject:dicResult];
        }
    }
    
    // synchronize the levelindicator with test process.
    NSInteger	curIndex	= [[dicResult objectForKey:@"FunnyZoneCurrentIndex"] intValue];
    NSInteger	sum			= [[dicResult objectForKey:@"FunnyZoneSumIndex"] intValue];
    [levelIndicator setMinValue:0];
    [levelIndicator setMaxValue:sum-1];
    [levelIndicator setIntValue:(int)curIndex+1];
    [lbPercentageNumber setStringValue:[NSString stringWithFormat:
                                        @"%.2f%%",
                                        (float)(curIndex + 1) *100 /sum]];
    
    @synchronized(m_arrCSVInfo)
    {
        [m_arrCSVInfo insertObject:dicResult atIndex:0];
    }
    
    if ([[[tabTestInfo tabViewItems] objectAtIndex:0] isEqualTo:[tabTestInfo selectedTabViewItem]])
    {
        [self UpdateUI_Object:tvCSVInfo];
    }
}

- (void)UpdateUI_Object:(id)aObject {
    if ([aObject isKindOfClass:[NSTableView class]])
        [aObject reloadData];
    if ([aObject isKindOfClass:[NSDictionary class]])
    {
        id obj = [aObject objectForKey:@"CLASS"];
        if ([obj isKindOfClass:[NSTextField class]])
        {
            NSString *szText = [aObject valueForKey:@"TEXT"];
            NSColor *TxtColor = [aObject objectForKey:@"TextColor"];
            NSColor *BGColor = [aObject objectForKey:@"BG_Color"];
            [obj setStringValue:szText];
            if (TxtColor)
                [obj setTextColor:TxtColor];
            if (BGColor)
                [obj setBackgroundColor:BGColor];
        }
    }
}

// reload data when you access to the tabviewitem
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    if(kTag_TableView_FailItems == [tabView indexOfTabViewItem:tabViewItem])
        [self performSelectorOnMainThread:@selector(UpdateUI_Object:)
                               withObject:tvFailInfo waitUntilDone:YES];
    if (kTag_TableView_CSVLog == [tabView indexOfTabViewItem:tabViewItem])
        [self performSelectorOnMainThread:@selector(UpdateUI_Object:)
                               withObject:tvCSVInfo waitUntilDone:YES];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    @synchronized(m_arrFailInfo)
    {
        if (([m_arrFailInfo count] > [tvFailInfo selectedRow]))
        {
            NSAttributedString	*attriStrConsole	= [[m_arrFailInfo objectAtIndex:[tvFailInfo selectedRow]]
                                                       objectForKey:@"FunnyZoneConsoleMessage"];
            [textViewFailInfo setSelectedRange:NSMakeRange( 0, [[textViewFailInfo string] length])];
            [textViewFailInfo delete:nil];
            [[textViewFailInfo textStorage] insertAttributedString:attriStrConsole
                                                           atIndex:0];
            [textViewFailInfo scrollRangeToVisible: NSMakeRange( 0, 0)];
        }
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    switch(aTableView.tag)
    {
        case kTag_TableView_CSVLog:
            @synchronized(m_arrCSVInfo)
        {
            return [m_arrCSVInfo count];
        }
        case kTag_TableView_FailItems:
            @synchronized(m_arrFailInfo)
        {
            return [m_arrFailInfo count];
        }
        default:
            return 0;
    }
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    NSMutableArray		*arrCommon	= nil;
    switch(aTableView.tag)
    {
        case kTag_TableView_CSVLog:
            arrCommon = m_arrCSVInfo;
            break;
        case kTag_TableView_FailItems:
            arrCommon = m_arrFailInfo;
            break;
        default:
            NSLog(@"TABLEVIEW ERROR: Can't get the tableview identifier");
            return @"";
    }
    
    id	theValue	= @"";
    
    @synchronized(arrCommon)
    {
        if ([arrCommon count] == 0)
            return nil;
        NSParameterAssert(rowIndex >= 0 && rowIndex < (int)[arrCommon count]);
        
        NSString	*identifier	= [aTableColumn identifier];
        if (nil == identifier)
        {
            NSLog(@"TABLEVIEW ERROR: Nil indentifier at row index: %ld", (long)rowIndex);
            return @"";
        }
        
        id	theRecord	= [arrCommon objectAtIndex:rowIndex];
        if(theRecord)
        {
            theValue = [theRecord objectForKey:identifier];
        }
        else
        {
            theValue	= @"";
            NSLog(@"TABVIEW EERO: Tableview can't get information at index \"%ld\"", (long)rowIndex);
        }
    }
    return theValue;
}

- (void)LoadDebugInformation
{
    if ([m_arrCSVInfo count] <= [tvCSVInfo selectedRow])
        return;
    
    NSDictionary * dictContentsSelected = [m_arrCSVInfo objectAtIndex:[tvCSVInfo selectedRow]];
    // dwc can't be released because once it released, the debug window will disappear
    DebugWindowController *dwc = [[DebugWindowController alloc] initWithWindowNibName:@"DebugWindowController"];
    dwc.informations = dictContentsSelected;
    [dwc showWindow:self];
}


@end
