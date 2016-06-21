//
//  FTAppDelegate.m
//  FakeTarget
//
//  Created by raniys on 4/1/14.
//  Copyright (c) 2014 raniys. All rights reserved.
//

#import "FTAppDelegate.h"
#import "FakeData.h"
#import "ParsingLog.h"

#import "YYControlPort.h"

@implementation FTAppDelegate
@synthesize window;


#pragma mark -
#pragma mark init
-(id)init
{
    if (self = [super init])
    {
        m_bTimerFired       = NO;
        m_bCheckBox         = YES;
        m_bItemOpened       = NO;
        m_iTrack            = 0;
        
        aTimer              = [[CustomTimer alloc] init];
        m_objDataSource     = [[FTDataSource alloc] init];
        
        m_szLogPath         = [[NSMutableString alloc] init];
        m_szReturnValue     = [[NSMutableString alloc] initWithString:@""];
        m_dictMemoryValues  = [[NSMutableDictionary alloc] init];
        m_arrCommandForView = [[NSMutableArray alloc] init];
        m_arrLogTargets     = [[NSMutableArray alloc] init];
        
    }
    return self;
}

- (void)dealloc
{
    [aTimer                 release]; aTimer = nil;
    [m_objDataSource        release]; m_objDataSource = nil;
    [_rootTreeNode          release]; _rootTreeNode = nil;
    
    [m_szLogPath            release]; m_szLogPath = nil;
    [m_szReturnValue        release]; m_szReturnValue = nil;
    [m_dictMemoryValues     release]; m_dictMemoryValues = nil;
    [m_arrCommandForView    release]; m_arrCommandForView = nil;
    [m_arrLogTargets        release]; m_arrLogTargets = nil;
    
    [super dealloc];
}

#define kMuifa_Window_Point_X                   12
#define kMuifa_Window_Point_Y                   100
#define kMuifa_Window_Size_Width                [[NSScreen mainScreen] visibleFrame].size.width
#define kMuifa_Window_Size_Height               [[NSScreen mainScreen] visibleFrame].size.height
-(void)awakeFromNib
{
    // set window frame
    NSRect			rectForWindow		= NSMakeRect(kMuifa_Window_Point_X, kMuifa_Window_Point_Y,kMuifa_Window_Size_Width, kMuifa_Window_Size_Height);
    [window setFrame:rectForWindow display:YES];
    
    //set TextView editable to NO
    [m_textDisplay setEditable:NO];
    
    //set data source for outlineview
    [m_outLineViewCommand setDataSource:self];
    [m_outLineViewCommand setDraggingSourceOperationMask:NSDragOperationEvery forLocal:YES];
    [m_outLineViewCommand setDraggingSourceOperationMask:NSDragOperationEvery forLocal:NO];
    [m_outLineViewCommand setAutoresizesOutlineColumn:NO];
    
    [m_outLineViewCommand setNeedsDisplay:YES];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

#pragma mark -
#pragma mark Interface control
- (IBAction)findLogPath:(id)sender
{
    if (!m_bTimerFired)
    {
        NSOpenPanel	*openPanel = [NSOpenPanel openPanel];
        [openPanel setCanChooseFiles:YES];		//Can choose file
        [openPanel setCanChooseDirectories:NO];	//Can't choose directories
        [openPanel setAllowsMultipleSelection:YES];	//Only can choose one file at one time
        [openPanel setAllowedFileTypes:[NSArray arrayWithObject:@"txt"]];//set the file types that can be choosed
        
        //Get the file's URL
        NSString *strFilePath = @"~/Desktop";
        strFilePath = [strFilePath stringByExpandingTildeInPath];
        NSURL *fileURL = [NSURL fileURLWithPath:strFilePath];
        
        [openPanel setDirectoryURL:fileURL];
        [openPanel beginSheetModalForWindow:window completionHandler:^(NSInteger result)
         {
             // if press button is equal to OK button , then do something
             if(result == NSFileHandlingPanelOKButton)
             {
                 for(NSURL *url in  [openPanel URLs])
                 {
                     NSString *urlString = [url path];
                     [m_textLogPath setStringValue:urlString];
                 }
             }
         }];
    }
    else
    {
        NSRunAlertPanel(@"警告(Warning)!",
						@"Program is in reading message, please turn it off first!",
						@"确认（OK）", nil, nil);
        NSLog(@"Error: Program is in reading message!");
    }
    
}

- (IBAction)showCommandAndTheResult:(id)sender
{
    if (m_bTimerFired)
    {
        NSRunAlertPanel(@"警告(Warning)!",
						@"Program is in reading message, please turn it off first!",
						@"确认（OK）", nil, nil);
        NSLog(@"Error: Program is in reading message!");
    }
    else
    {
        [m_btnShowResult setEnabled:NO];
        [m_textDisplay setEditable:YES];
        
        //clear memory
        if (m_dictMemoryValues != nil)
            [m_dictMemoryValues removeAllObjects];
        [m_textDisplay setString:@""];
        [self loadingScriptFile];
        if ([self getLogResultAndShowItToUI])
        {
            NSLog(@"Get data from log file OK.");
            [self showStringToUI:@"\n\nGet data from log file OK."
                       withColor:[NSColor greenColor]
                          toView:m_textDisplay];
            [m_textDisplay scrollRangeToVisible:NSMakeRange([[m_textDisplay string] length], 0)];
        }
        [m_btnShowResult setEnabled:YES];
        [m_textDisplay setEditable:NO];
    }
}

- (IBAction)startingToReceiveNotification:(id)sender
{
    NSInteger iRet = kUart_SUCCESS;
    if ([m_dictMemoryValues objectForKey:kFT_Cable_Paths] == nil)
    {
        iRet = [[self getSerialPorts]integerValue];
        if ([m_btnCheckBox state])
            m_bCheckBox = YES;
    }
    if (iRet == kUart_SUCCESS && [m_btnCheckBox state]
        && m_bTimerFired == NO)
    {
        if ([[self StartingMonitor]boolValue])
        {
            // Start timer to record test times
            aTimer.textField = m_textTimer;
            [aTimer fireTimer];
            m_bTimerFired = YES;
        }
    }
}

- (IBAction)checkBox:(id)sender
{
    if (![m_btnCheckBox state])
    {
        NSLog(@"%hhd",[aTimer isValid]);
        if ([aTimer isValid])
            [aTimer invalidateTimer];
        m_bTimerFired   = NO;
        m_bCheckBox     = NO;
        [self closeTarget:[m_dictMemoryValues objectForKey:kFT_Targets]];
    }
    else
        m_bCheckBox = YES;
}

- (IBAction)changeTarget:(id)sender
{
    if ([m_dictMemoryValues objectForKey:[m_dictMemoryValues objectForKey: kFT_Targets]] != nil)
    {
        [aTimer invalidateTimer];
        m_bTimerFired   = NO;
        m_bCheckBox     = NO;
        [self closeTarget:[m_dictMemoryValues objectForKey:kFT_Targets]];
        [m_dictMemoryValues removeObjectForKey:kFT_Cable_Paths];
    }
}

- (IBAction)showAllCommand:(id)sender
{
    if (!m_bItemOpened)
    {
        [self openAllItem];
        m_bItemOpened = YES;
    }
    else
    {
        [self closeAllItem];
        m_bItemOpened = NO;
    }
}

- (IBAction)manualSendComamnd:(NSButton *)sender
{
    NSString    *strComamnd = [m_textManualCommand stringValue];
    if (!strComamnd)
    {
        return;
    }
    else
    {
        YYControlPort * newControlPort = [m_dictMemoryValues objectForKey:@"FIXTURE"];
        if (!newControlPort)
            return;
        else
            [newControlPort Write_UartCommand:strComamnd
                                    PackedNum:1
                                     Interval:0
                                        IsHex:NO];
    }
    
}

- (IBAction)saveDataToCsvFile:(NSButton *)sender
{
    NSString    *strFilePath    = @"~/Desktop/CommandResponse.csv";
    strFilePath = [strFilePath stringByExpandingTildeInPath];
    
    
    
}



#pragma mark - Methods for control
-(BOOL)getLogResultAndShowItToUI
{
    if ([[m_textLogPath stringValue] isEqualToString:@"LogPathHere"])
    {
        NSLog(@"Log not found.");
        [self showStringToUI:@"\n\nLog not found, please check."
                   withColor:[NSColor redColor]
                      toView:m_textDisplay];
        return NO;
    }
    m_szLogPath = [NSMutableString stringWithFormat:@"%@", [m_textLogPath stringValue]];
    if (![[self getDataFromLogPath:m_szLogPath
                      returnValue:m_szReturnValue]boolValue])
    {
        NSLog(@"%@", m_szReturnValue);
        NSLog(@"Get data from log file failed.");
        [self showStringToUI:m_szReturnValue
                   withColor:[NSColor redColor]
                      toView:m_textDisplay];
        [self showStringToUI:@"\n\nGet data from log file failed."
                   withColor:[NSColor redColor]
                      toView:m_textDisplay];
        return NO;
    }
    [self showStringToUI:[NSString stringWithFormat:@"\nDepartment: %@", [m_dictMemoryValues objectForKey:kFT_Department_Name]]
               withColor:[NSColor purpleColor]
                  toView:m_textDisplay];
    [self showStringToUI:[NSString stringWithFormat:@"\nProject: %@", [m_dictMemoryValues objectForKey:kFT_Project_Name]]
               withColor:[NSColor purpleColor]
                  toView:m_textDisplay];
    [self showStringToUI:[NSString stringWithFormat:@"\nStation: %@", [m_dictMemoryValues objectForKey:kFT_Station_Name]]
               withColor:[NSColor purpleColor]
                  toView:m_textDisplay];
    NSString    *strLogData = [m_dictMemoryValues objectForKey: kFT_File_Data];
    if (![[self getDataByTargetFromLog:strLogData
                          returnValue:m_szReturnValue]boolValue])
    {
        NSLog(@"%@", m_szReturnValue);
        NSLog(@"Get data from log file failed.");
        [self showStringToUI:m_szReturnValue
                   withColor:[NSColor redColor]
                      toView:m_textDisplay];
        [self showStringToUI:@"\n\nGet data from log file failed."
                   withColor:[NSColor redColor]
                      toView:m_textDisplay];
        return NO;
    }
    
    //show the command and result to UI
    if (m_arrCommandForView != nil)
        [m_arrCommandForView removeAllObjects];
    //show mobile command and result
    if ([[m_dictMemoryValues objectForKey:kFT_Mobile_Command] count] != 0)
        [self getDataToUIByTarget:@"MOBILE"];
    //show fixture command and result
    if ([[m_dictMemoryValues objectForKey:kFT_Fixture_Command] count] != 0)
        [self getDataToUIByTarget:@"FIXTURE"];
    //show Mikey command and result
    if ([[m_dictMemoryValues objectForKey:kFT_Mikey_Command] count] != 0)
        [self getDataToUIByTarget:@"MIKEY"];
    if ([[m_dictMemoryValues objectForKey:kFT_Lightmeter_Command] count] != 0)
        [self getDataToUIByTarget:@"LIGHTMETER"];
    [m_outLineViewCommand reloadData];
    return YES;
}

-(void)getDataToUIByTarget:(NSString *)target
{
    NSString *strSendCommand = @"";
    NSString *strReadCommand = @"";
    FTDataSource * dataParent = [[FTDataSource alloc] init];
    [dataParent setContentName:target];
    NSArray *aryCommand    = [m_dictMemoryValues objectForKey:[NSString stringWithFormat:@"%@Command", target]];
    NSString    *message    = [NSString stringWithFormat:@"\n\n\n\nBelow comes %@ command and result:", target];
    [self showStringToUI:message
               withColor:[NSColor greenColor]
                  toView:m_textDisplay];
    for (NSDictionary *dicCommand in aryCommand)
    {
        FTDataSource * child = [[FTDataSource alloc] init];
        strSendCommand = [dicCommand objectForKey:@"SendCommand"];
        strReadCommand = [dicCommand objectForKey:@"ReadCommand"];
        [self showStringToUI:[NSString stringWithFormat:@"\n\n(%@)Command==>：%@",target,strSendCommand]
                   withColor:[NSColor blueColor]
                      toView:m_textDisplay];
        [self showStringToUI:[NSString stringWithFormat:@"\n%@",strReadCommand]
                   withColor:[NSColor grayColor]
                      toView:m_textDisplay];
        
        if ([strSendCommand isEqualToString:@"\n"])
            strSendCommand = @"\\r";
        [child setContentName:strSendCommand];
        [dataParent addAChild:child];
        [child release];
    }
    [m_arrCommandForView addObject:dataParent];
}

-(void)showStringToUI:(NSString *)strString
            withColor:(NSColor *)color
               toView:(NSTextView *)textView
{
    if ([strString isEqualToString:@""])
    {
        NSRunAlertPanel(@"警告(Warning)!",
						@"No data found!",
						@"确认（OK）", nil, nil);
        NSLog(@"Error: no data found!");
        [textView insertText:@"Error: no data found!"];
    }
    if (color != nil)
    {
        NSDictionary	*dict	= [NSDictionary dictionaryWithObject:color
                                                         forKey:NSForegroundColorAttributeName];
        NSAttributedString* attr = [[[NSAttributedString alloc] initWithString:strString
                                                                    attributes:dict] autorelease];
        [[textView textStorage] appendAttributedString:attr];
    }
    else
        [textView insertText:strString];
}

- (NSNumber *)loadingScriptFile
{
    NSDictionary    *dicScriptSetting   = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:
                                                                                      @"%@/Contents/Resources/ATS_FakeTarget.plist",
                                                                                      [[NSBundle mainBundle] bundlePath]]];
    if (dicScriptSetting == nil)
    {
        NSLog(@"Error: Program could not find script file.");
        NSRunAlertPanel(@"警告(Warning)!",
						@"Program could not find script file.",
						@"确认（OK）", nil, nil);
        return [NSNumber numberWithBool:NO];
    }
    [m_dictMemoryValues setObject:dicScriptSetting forKey:@"ScriptSetting"];
    NSDictionary    *dicDevicePort      = [dicScriptSetting objectForKey:@"DeviceSetting"];
    NSDictionary    *dicPortName        = [dicScriptSetting objectForKey:@"UnitsPreference"];
    NSDictionary    *dicUnitsParameters = [dicScriptSetting objectForKey:@"LogParameter"];
    if (dicPortName == nil || dicDevicePort == nil || dicUnitsParameters == nil)
    {
        NSLog(@"Script Issue:  Script file setting error.");
        NSRunAlertPanel(@"警告(Warning)!",
						@"Script Issue:  Script file setting error.",
						@"确认（OK）", nil, nil);
        return [NSNumber numberWithBool:NO];
    }
    [m_dictMemoryValues setObject:dicDevicePort forKey:KFT_Device_Setting];
    [m_dictMemoryValues setObject:dicUnitsParameters forKey:kFT_Data_Parameters];
    
    //get device from script file
    NSArray         *aryDeviceName = [dicPortName allKeys];
    NSString        *strCablePartNeedToOpen = @"";
    NSMutableArray  *arrTargetDevice = [[NSMutableArray alloc] init];
    for (int i=0; i<[dicPortName count]; i++)
    {
        NSDictionary *dicDevice = [dicPortName objectForKey:[aryDeviceName objectAtIndex:i]];
        if ([[dicDevice objectForKey:@"EnableDevice"]boolValue] &&
            [[dicDevice objectForKey:@"PortName"] isNotEqualTo:@""])
        {
            strCablePartNeedToOpen = [dicDevice objectForKey:@"PortName"];
            [m_dictMemoryValues setObject:strCablePartNeedToOpen
                                   forKey:[NSString stringWithFormat:@"%@ CableName", [aryDeviceName objectAtIndex:i]]];
            [arrTargetDevice addObject:[aryDeviceName objectAtIndex:i]];
        }
    }
    if ([arrTargetDevice count] == 0)
    {
        NSLog(@"Script Issue:  Script file format error.");
        NSRunAlertPanel(@"警告(Warning)!",
                        @"Script Issue:  Script file format error.",
                        @"确认（OK）", nil, nil);
        return [NSNumber numberWithBool:NO];
    }
//    [m_dictMemoryValues setObject:arrOpenCable forKey:@"CableToOpen"];
    [m_dictMemoryValues setObject:arrTargetDevice forKey:@"TARGETS"];
    [arrTargetDevice release];
    return [NSNumber numberWithBool:YES];
}

- (NSNumber *)StartingMonitor
{
    BOOL bProcess = YES;
    NSString    *strTarget  = [[[m_popTarget titleOfSelectedItem]uppercaseString] isNotEqualTo:@"MOBILE"]?[[m_popTarget titleOfSelectedItem]uppercaseString ]:@"MOBILE";
    bProcess &= [[self loadingScriptFile] boolValue];
    if (bProcess)
    {
        NSArray *aryTargets = [m_dictMemoryValues objectForKey:kFT_Targets];
        for (int i = 0; i<[aryTargets count]; i++)
        {
            strTarget = [aryTargets objectAtIndex:i];
            [NSThread detachNewThreadSelector:@selector(runSingleTarget:)
                                     toTarget:self
                                   withObject:strTarget];
        }
        
//        [m_dictMemoryValues setObject:strTarget forKey:kFT_Target];
        return [NSNumber numberWithBool:YES];
    }
    else
        return [NSNumber numberWithBool:NO];
}

-(NSNumber *)runSingleTarget:(NSString *)strTarget
{
    if ([strTarget isEqualTo:@""])
        return [NSNumber numberWithBool:NO];
    @synchronized(strTarget)
    {
        //Open target
        if (![[self openTarget:strTarget]boolValue])
            return [NSNumber numberWithBool:NO];
        
//        NSOperationQueue
        //Starting monitor
        [NSThread detachNewThreadSelector:@selector(readAndSendMessage:)
                                 toTarget:self
                               withObject:strTarget];
        return [NSNumber numberWithBool:YES];
    }
   
    return [NSNumber numberWithBool:YES];
}

-(void)openAllItem
{
    for (int i=0; i<[m_arrCommandForView count]; i++)
    {
		[m_outLineViewCommand expandItem:[m_arrCommandForView objectAtIndex:i]];
	}
}

-(void)closeAllItem
{
	for (int i=0; i<[m_arrCommandForView count]; i++)
    {
		[m_outLineViewCommand collapseItem:[m_arrCommandForView objectAtIndex:i]];
	}
}

- (BOOL)treeNode:(NSTreeNode *)treeNode isDescendantOfNode:(NSTreeNode *)parentNode
{
    while (treeNode != nil)
    {
        if (treeNode == parentNode)
        {
            return YES;
        }
        treeNode = [treeNode parentNode];
    }
    return NO;
}

- (NSTreeNode *)treeNodeFromArray:(NSArray *)array
{
    // We will use the built-in NSTreeNode with a representedObject that is our model object - the SimpleNodeData object.
    // First, create our model object.
    NSString *nodeName = @"root";
    FTDataSource *nodeData = [FTDataSource nodeDataWithName:nodeName];
    // The image for the nodeData is lazily filled in, for performance.
    
    // Create a NSTreeNode to wrap our model object. It will hold a cache of things such as the children.
    NSTreeNode *result = [NSTreeNode treeNodeWithRepresentedObject:nodeData];
    
//    // Walk the dictionary and create NSTreeNodes for each child.
//    NSArray *children = [dictionary objectForKey:CHILDREN_KEY];
    
    for (id item in array)
    {
        // A particular item can be another dictionary (ie: a container for more children), or a simple string
        NSTreeNode *childTreeNode;
        if ([item isKindOfClass:[NSArray class]])
        {
            // Recursively create the child tree node and add it as a child of this tree node
            childTreeNode = [self treeNodeFromArray:item];
        }
        else {
            // It is a regular leaf item with just the name
            FTDataSource *childNodeData = [[FTDataSource alloc] initWithName:item];
            childTreeNode = [NSTreeNode treeNodeWithRepresentedObject:childNodeData];
            [childNodeData release];
        }
        // Now add the child to this parent tree node
        [[result mutableChildNodes] addObject:childTreeNode];
    }
    return result;
    
}


#pragma mark - outlineView Required Methods (unless bindings is used)

- (NSInteger)outlineView:(NSOutlineView *)outlineView
  numberOfChildrenOfItem:(id)item
{
    if (item == nil)
        return [m_arrCommandForView count];
    if ([item isKindOfClass:[FTDataSource class]])
    {
        return [item countOfChildren];
    }
    return 0;
}
- (id)outlineView:(NSOutlineView *)outlineView
            child:(NSInteger)index
           ofItem:(id)item
{
    if (item == nil)
        return [m_arrCommandForView objectAtIndex:index];
    if ([item isKindOfClass:[FTDataSource class]])
        return [item ChildAtIndex:index];
    return nil;
}
- (BOOL)outlineView:(NSOutlineView *)outlineView
   isItemExpandable:(id)item
{
    if (item == nil)
        return [m_arrCommandForView count] > 0;
    if ([item isKindOfClass:[FTDataSource class]])
        return [item isExpandable];
    return NO;
}

/* NOTE: this method is optional for the View Based OutlineView.
 */
- (id)outlineView:(NSOutlineView *)outlineView
objectValueForTableColumn:(NSTableColumn *)tableColumn
           byItem:(id)item
{
    if ([item isKindOfClass:[FTDataSource class]])
        return [item contentName];
    return nil;
}


#pragma mark - Control the outLineView
// To get the "group row" look, we implement this method.
- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
    FTDataSource *nodeData = item;
    return nodeData.isExpandable;
}

// reload data when you access to the tabviewitem
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
    if (m_arrCommandForView != nil)
        return YES;
    return NO;
}

- (BOOL)outlineView:(NSOutlineView *)ov shouldTrackCell:(NSCell *)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    // Only allow tracking on selected rows. This is what NSTableView does by default.
    return [m_outLineViewCommand isRowSelected:[m_outLineViewCommand rowForItem:item]];
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    // This message is sent whenever the selection changes
    if ([[m_outLineViewCommand selectedRowIndexes] count] > 1)
    {
        [self showStringToUI:@"\n\nMultiple Rows Selected" withColor:[NSColor redColor] toView:m_textDisplay];
        [m_textDisplay scrollRangeToVisible:NSMakeRange([[m_textDisplay string] length], 0)];
    }
    else if ([[m_outLineViewCommand selectedRowIndexes] count] == 1)
    {
        // Grab the single selected row value
        id          selectedItem    = [m_outLineViewCommand itemAtRow:[m_outLineViewCommand selectedRow]];
        NSString    *strCommand     = [selectedItem contentName];
        NSString    *strScroll      = [NSString stringWithFormat:@"Command==>：%@",strCommand];
		NSString    *strAll         = [[m_textDisplay string] stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
		// fouse
		if (NSNotFound != [strAll rangeOfString:strScroll].location)
        {
            //to highlight the text on textView which you have clicked
            [[m_textDisplay textStorage] addAttribute:NSForegroundColorAttributeName
                                                value:[NSColor grayColor]
                                                range:NSMakeRange(0,strAll.length)];
            NSRange     area;
            NSString    *strBuffer  = strAll;
            NSUInteger  iCount      = 0;
            NSUInteger  iLocation   = 0;
            NSUInteger  iArray[100] = {};
            //get the number of the command line from the outlineView
            NSLog(@"Rows count=>%ld",(long)[m_outLineViewCommand numberOfRows]);
            for (int i=0; i<[m_outLineViewCommand numberOfRows]; i++)
            {
                if ([[[m_outLineViewCommand itemAtRow:i] contentName] isEqualToString:strCommand])
                {
                    NSLog(@"contentName=>%@", [[m_outLineViewCommand itemAtRow:i] contentName]);
                    iArray[iCount] = i;
                    iCount++;
                }
            }
            //get the command line place on the textView
            if (1 != iCount && [strCommand isNotEqualTo:@"\\r"])
            {
                for (int j=0; j<iCount; j++)
                {
                    if ([m_outLineViewCommand selectedRow] == iArray[j] )
                    {
                        m_iTrack    = j;
                    }
                }
                for (int i = 0; i<m_iTrack; i++)
                {
                    iLocation   += [strBuffer rangeOfString:strScroll].location+strScroll.length;
                    strBuffer   = [strBuffer SubFrom:strScroll include:NO];
                }
//                strScroll  = [NSString stringWithFormat:@"Command==>：%@", strCommand];
                area    = NSMakeRange(iLocation+[strBuffer rangeOfString:strScroll].location, strScroll.length);
            }
            else
                area    = NSMakeRange([strAll rangeOfString:strScroll].location, strScroll.length);
            NSLog(@"%@", [m_textDisplay textStorage]);
            [[m_textDisplay textStorage] addAttribute:NSForegroundColorAttributeName
                                value:[NSColor blueColor]
                                range:area];
            
            //scroll to the text which you have choosed
			[m_textDisplay scrollRangeToVisible:area];
        }
    }
    else
    {
        [self showStringToUI:@"\n\nNothing Selected" withColor:[NSColor redColor] toView:m_textDisplay];
        [m_textDisplay scrollRangeToVisible:NSMakeRange([[m_textDisplay string] length], 0)];
    }
    
}

@end











