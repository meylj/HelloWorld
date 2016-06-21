//
//  AppDelegate.m
//  FireTestCoverage
//
//  Created by raniys on 1/7/15.
//  Copyright (c) 2015 raniys. All rights reserved.
//

#import <LibXL/LibXL.h>

#import "AppDelegate.h"
#import "CoreFunction.h"
#import "NSStringCategory.h"

@interface AppDelegate ()
{
    NSMutableString *m_strFilePath;
    NSMutableString *m_strTestCoveragePath;
    
    NSMutableArray  *m_aryOfAllCmdForOutlineView;
    
    BOOL            m_bItemOpened;
    NSNumber        *m_dNumber;
    
    dispatch_queue_t m_queue;
    
    CoreFunction    *objCore;
}
@property (assign) IBOutlet NSWindow *window;
@end

static const char *queueLabel = "com.pegatron.ATS.control_queue";
@implementation AppDelegate

-(id)init
{
    self = [super init];
    if (self)
    {
        m_bItemOpened       = NO;
        m_strFilePath                   = [[NSMutableString alloc] init];
        m_strTestCoveragePath           = [[NSMutableString alloc] init];
        m_aryOfAllCmdForOutlineView     = [[NSMutableArray alloc] init];
        m_queue = dispatch_queue_create(queueLabel, NULL);
        objCore =[[CoreFunction alloc]init];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [outlineViewDisplay setDataSource:self];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

-(void)awakeFromNib
{
    [comboTestCoverageStatus removeAllItems];
    [comboTestCoverageStatus addItemsWithObjectValues:[NSArray arrayWithObjects:@"Validation",@"Ongoing",@"TBC",@"Open",@"Removed",@"Close", nil]];
    [comboTestCoverageStatus selectItemAtIndex:0];
    [textCoveragePath setStringValue:@""];
    [rollProgress setHidden:YES];
}


-(void)chooseFile:(NSButton *)sender
{
    NSOpenPanel *openPanel  = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:YES];		//Can choose file
    [openPanel setCanChooseDirectories:NO];	//Can't choose directories
    [openPanel setAllowsMultipleSelection:NO];	//Only can choose one file at one time
    [openPanel setAllowedFileTypes:[NSArray arrayWithObjects:@"txt",@"plist",nil]];//set the file types that can be choosed
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"NSNavLastRootDirectory"] isEqualToString:@"~/Desktop"])
        [openPanel setDirectoryURL:[NSURL URLWithString:@"~/"]];
    [openPanel beginSheetModalForWindow:_window completionHandler:^(NSInteger result)
     {
         // if press OK button, do something
         if(result == NSFileHandlingPanelOKButton)
         {
             for(NSURL *url in  [openPanel URLs])
             {
                 NSString *urlString = [url path];
                 [textFilePath setStringValue:urlString];
             }
         }
     }];
}

-(void)loadDataFromFile:(NSButton *)sender
{
    [m_strFilePath setString:[textFilePath stringValue]];
    NSLog(@"[Data Source]: %@",m_strFilePath);
    [m_aryOfAllCmdForOutlineView removeAllObjects];
    [outlineViewDisplay reloadData];
    if ([self loadCmdFromFile])
        [outlineViewDisplay reloadData];
}

-(void)showOrHideCommandOnUI:(NSButton *)sender
{
    if ([m_aryOfAllCmdForOutlineView count] < 1)
    {
        sender.state = 0;
    }
    else
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
}

-(void)exportToFile:(NSButton *)sender
{
    objCore.textProgress = m_textProgress;
    objCore.lineProgress = m_lineProgress;
    
    [self workingFlow];
}

- (IBAction)doTestCoverage:(NSButton *)sender
{
    if ([checkTxtUnit state] == 1 || [checkTxtFixture state] == 1 || [checkXlsFixture state] == 1)
    {
        [self popUpError:[NSError errorWithDomain:@"大兄弟／大妹子，你到底想叫俺干啥？要么俺只给你机台/治具command的txt文件和治具command的xls excel文件，要么俺只给你TestCoverage xlsx的excel文件，你自己选一个。(You may choose 'UnitCmd2txt'/'FixtureCmd2txt'/'FixtureCmd2xls' button at the same time, but you may not choose these buttons on the same time with them.)" code:003 userInfo:nil]];
        checkExportTestCoverage.state = 0;
    }
    
    if ([checkExportTestCoverage state])
    {
        NSOpenPanel *openPanel  = [NSOpenPanel openPanel];
        [openPanel setCanChooseFiles:YES];		//Can choose file
        [openPanel setCanChooseDirectories:NO];	//Can't choose directories
        [openPanel setAllowsMultipleSelection:NO];	//Only can choose one file at one time
        [openPanel setAllowedFileTypes:[NSArray arrayWithObjects:@"xlsx", nil]];
        // get the file's url
        NSString * strFilePath = @"~/Desktop/";
        NSURL *fileURL = [NSURL URLWithString:strFilePath];
        [openPanel setDirectoryURL:fileURL];
        [openPanel beginSheetModalForWindow:_window completionHandler:^(NSInteger result)
         {
             // if press OK button, do something
             if(result == NSFileHandlingPanelOKButton)
             {
                 for(NSURL *url in  [openPanel URLs])
                 {
                     NSString *urlString = [url path];
                     [textCoveragePath setStringValue:[NSString stringWithFormat:@"path:%@",urlString]];
                     [m_strTestCoveragePath setString:urlString];
                 }
             }
             else
                 checkExportTestCoverage.state = 0;
         }];
    }
}

-(void)doCommands:(NSButton *)sender
{
    if ([checkExportTestCoverage state] == 1)
    {
        [self popUpError:[NSError errorWithDomain:@"大兄弟／大妹子，你到底想叫俺干啥？要么俺只给你机台/治具command的txt文件和治具command的xls excel文件，要么俺只给你TestCoverage xlsx的excel文件，你自己选一个。(You may choose 'UnitCmd2txt'/'FixtureCmd2txt'/'FixtureCmd2xls' button at the same time, but you may not choose these buttons on the same time with them.)" code:003 userInfo:nil]];
        sender.state = 0;
    }
}

- (IBAction)editFile:(id)sender
{
    
}

-(void)openAllItem
{
    for (int i=0; i<[m_aryOfAllCmdForOutlineView count]; i++)
    {
        [outlineViewDisplay expandItem:[m_aryOfAllCmdForOutlineView objectAtIndex:i]];
    }
}

-(void)closeAllItem
{
    for (int i=0; i<[m_aryOfAllCmdForOutlineView count]; i++)
    {
        [outlineViewDisplay collapseItem:[m_aryOfAllCmdForOutlineView objectAtIndex:i]];
    }
}

#define kItemStatus     @"status"
#define kStatusCol      @"Column"
#define kStatusRow      @"Row"
-(void)workingFlow
{
    dispatch_async(m_queue, ^{
        [btnChoose setEnabled:NO];
        [btnOK setEnabled:NO];
        [btnExport setEnabled:NO];
        [comboTestCoverageStatus setEditable:NO];
        [checkExportTestCoverage setEnabled:NO];
        [checkTxtFixture setEnabled:NO];
        [checkTxtUnit setEnabled:NO];
        [checkXlsFixture setEnabled:NO];
        [checkAutoUpdateStatus setEnabled:NO];
        [textFilePath setEditable:NO];
    });
    if ([checkTxtUnit state] == 1 || [checkTxtFixture state] ==1)
    {
        NSURL   *fileURL = [self createFilePath];
        if (!fileURL)
            return;
        [objCore writeData:m_aryOfAllCmdForOutlineView ToTxtFile:fileURL unitStatus:checkTxtUnit fixtureStatus:checkTxtFixture];
        
    }
    else if([checkExportTestCoverage state] == 1)
    {
        //        [objCore writeData:m_aryOfAllCmdForOutlineView ToExcelFile:[self createFilePath] unitStatus:checkXlsUnit fixtureStatus:checkXlsFixture testCoverageStatus:checkIncludeFixCmd stationStatus:[comboTestCoverageStatus stringValue]];
        NSInteger iRow = 0;
        NSInteger iCol = 0;
        switch ([comboTestCoverageStatus indexOfSelectedItem])
        {
            case 0:
                iRow = 7, iCol = 2;
                break;
            case 1:
                iRow = 6, iCol = 2;
                break;
            case 2:
                iRow = 5, iCol = 2;
                break;
            case 3:
                iRow = 4, iCol = 2;
                break;
            case 4:
                iRow = 3, iCol = 2;
                break;
            case 5:
                iRow = 8, iCol = 2;
                break;
            default:
                break;
        }
        NSDictionary *dicSetting = [NSDictionary dictionaryWithObjectsAndKeys:[comboTestCoverageStatus stringValue],kItemStatus,[NSString stringWithFormat:@"%ld",iRow],kStatusRow,[NSString stringWithFormat:@"%ld",iCol],kStatusCol, nil];
        if ([checkAutoUpdateStatus state])
        {
            dispatch_async(m_queue, ^{
                [rollProgress startAnimation:nil];
                [rollProgress setHidden:NO];
              //  [m_lineProgress setHidden:NO];
               // [m_textProgress setHidden:NO];
                [objCore updateUartData:m_aryOfAllCmdForOutlineView toTestCoverage:m_strTestCoveragePath withSpecialSetting:dicSetting];
                [rollProgress stopAnimation:nil];
                [rollProgress setHidden:YES];
               // [m_lineProgress setHidden:YES];
                //[m_textProgress setHidden:YES];
            });
        }
        else
        {
            dispatch_async(m_queue, ^{
                [rollProgress startAnimation:nil];
                [rollProgress setHidden:NO];
               // [m_lineProgress setHidden:NO];
                //[m_textProgress setHidden:NO];
                [objCore updateUartData:m_aryOfAllCmdForOutlineView toTestCoverage:m_strTestCoveragePath withSpecialSetting:nil];
                [rollProgress stopAnimation:nil];
                [rollProgress setHidden:YES];
                //[m_lineProgress setHidden:YES];
               // [m_textProgress setHidden:YES];
            });
        }
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            [self runProgress];
//        });
    }
    
    dispatch_async(m_queue, ^{
        [btnChoose setEnabled:YES];
        [btnOK setEnabled:YES];
        [btnExport setEnabled:YES];
        [comboTestCoverageStatus setEditable:YES];
        [checkExportTestCoverage setEnabled:YES];
        [checkTxtFixture setEnabled:YES];
        [checkTxtUnit setEnabled:YES];
        [checkXlsFixture setEnabled:YES];
        [checkAutoUpdateStatus setEnabled:YES];
        [textFilePath setEditable:YES];
    });
}

-(BOOL)loadCmdFromFile
{
    if(0 != [m_aryOfAllCmdForOutlineView count])
        [m_aryOfAllCmdForOutlineView removeAllObjects];
    CFStringRef fileExtension = (__bridge CFStringRef) [m_strFilePath pathExtension];
    CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
    if (UTTypeConformsTo(fileUTI, kUTTypePropertyList))
        m_aryOfAllCmdForOutlineView = [NSMutableArray arrayWithArray:[objCore loadDataFromPlistFile:m_strFilePath]];
    else if(UTTypeConformsTo(fileUTI, kUTTypeText))
    {
        id result = [objCore loadDataFromTxtFile:m_strFilePath];
        if ([result isKindOfClass:[NSArray class]])
            m_aryOfAllCmdForOutlineView = result;
        else
        {
            [self popUpError:result];
            return NO;
        }
    }
    else
    {
        [self popUpError:[NSError errorWithDomain:@"文件格式不对，请确认！(Wrong type of the file you choosed, please double confirm)"
                                             code:22
                                         userInfo:nil]];
        return NO;
    }
    return YES;
}

-(void)popUpError:(NSError *)error
{
    NSAlert *alert  = [NSAlert alertWithError:error];
    //    [alert addButtonWithTitle:@"确定(YES)"];
    //    [alert setMessageText:[NSString stringWithFormat:
    //                           @"警告(Warning)"]];
    //    [alert setInformativeText:@"This is an error message"];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:_window completionHandler:nil];
}

-(NSURL *)createFilePath
{
    NSString    *strFileName;
    NSString    *strTextFileSuffix    = @".txt";
    NSString    *strXlsFileSuffix     = @".xlsx";
    NSString    *defaultDirectoryPath = @"~/Desktop";
    if ((nil != m_strFilePath || [m_strFilePath isNotEqualTo:@""])&& [m_aryOfAllCmdForOutlineView count] != 0)
    {
        strFileName = [[[m_aryOfAllCmdForOutlineView objectAtIndex:0] objectForKey:@"Item"]SubFrom:@"START_TEST_" include:NO];
        NSLog(@"%@",strFileName);
    }
    
    NSSavePanel *tvarNSSavePanelObj	= [NSSavePanel savePanel];
    if ([checkTxtFixture state] == 1 || [checkTxtUnit state] == 1)
    {
        strFileName = [NSString stringWithFormat:@"%@Command%@",strFileName,strTextFileSuffix];
        [tvarNSSavePanelObj setAllowedFileTypes:[NSArray arrayWithObjects:@"txt", nil]];
    }
    else
    {
        strFileName = [NSString stringWithFormat:@"%@TestCoverage%@",strFileName,strXlsFileSuffix];
        [tvarNSSavePanelObj setAllowedFileTypes:[NSArray arrayWithObjects:@"xlsx", nil]];
    }
    [tvarNSSavePanelObj setNameFieldStringValue:strFileName];
    [tvarNSSavePanelObj setDirectoryURL:[NSURL URLWithString:defaultDirectoryPath]];
    NSInteger tvarInt	= [tvarNSSavePanelObj runModal];
    if(tvarInt == NSModalResponseOK)
    {
        NSLog(@"doSaveAs we have an OK button");
    }
    else if(tvarInt == NSModalResponseCancel)
    {
        NSLog(@"doSaveAs we have a Cancel button, url:%@",[tvarNSSavePanelObj URL]);
        return nil;
    }
    else
    {
        NSLog(@"doSaveAs tvarInt not equal 1 or zero = %lu",tvarInt);
        return nil;
    } // end if
    NSLog(@"doSaveAs directory = %@",[tvarNSSavePanelObj directoryURL]);
    NSLog(@"doSaveAs filename = %@",[tvarNSSavePanelObj URL]);
    
    return [tvarNSSavePanelObj URL];
}

-(void)openFileType:(NSArray *)arrType forPath:(NSMutableString **)path
{
    NSOpenPanel *openPanel  = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:YES];		//Can choose file
    [openPanel setCanChooseDirectories:NO];	//Can't choose directories
    [openPanel setAllowsMultipleSelection:NO];	//Only can choose one file at one time
    [openPanel setAllowedFileTypes:arrType];//set the file types that can be choosed
//    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"NSNavLastRootDirectory"] isEqualToString:@"~/Desktop"])
//        [openPanel setDirectoryURL:[NSURL URLWithString:@"~/"]];
    [openPanel beginSheetModalForWindow:_window completionHandler:^(NSInteger result)
     {
         // if press OK button, do something
         if(result == NSFileHandlingPanelOKButton)
         {
             for(NSURL *url in  [openPanel URLs])
             {
                 NSString *urlString = [url path];
                 [*path setString:urlString];
             }
         }
     }];
}

#pragma **NSOutlineDataSourse**
- (id)outlineView:(NSOutlineView *)outlineView
            child:(NSInteger)index
           ofItem:(id)item
{
    if(item == nil)
        return [m_aryOfAllCmdForOutlineView objectAtIndex:index];
    if([item isKindOfClass:[NSDictionary class]])
        return [[item objectForKey:@"Item/Command"] objectAtIndex:index];
    else
        return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
   isItemExpandable:(id)item
{
    if([[item allKeys] containsObject:@"Item/Command"] )
    {
        if([[item objectForKey:@"Item/Command"] count] != 0)
            return YES;
        else
            return NO;
    }
    else
        return NO;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView
  numberOfChildrenOfItem:(id)item
{
    if(item == nil)
        return [m_aryOfAllCmdForOutlineView count];
    if([item isKindOfClass:[NSDictionary class]])
        return [[item objectForKey:@"Item/Command"] count];
    return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView
objectValueForTableColumn:(NSTableColumn *)tableColumn
           byItem:(id)item
{
    if([[item allKeys] containsObject:@"Item"])
    {
        if([[tableColumn identifier] isEqualToString:@"Item/Command"])
            return [item objectForKey:@"Item"];
        if([[tableColumn identifier] isEqualToString:@"Target/Spec"])
            return [item objectForKey:@"SPEC"];
        else
            return nil;
    }
    else
    {
        if([[tableColumn identifier] isEqualToString:@"Target/Spec"])
            return [item objectForKey:@"Target"];
        else
            return [item objectForKey:@"Command"];
    }
}


@end
