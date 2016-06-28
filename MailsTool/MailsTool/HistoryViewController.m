//
//  HistoryViewController.m
//  MailsTool
//
//  Created by allen on 10/4/2016.
//  Copyright © 2016 allen. All rights reserved.
//

#import "HistoryViewController.h"


@interface HistoryViewController ()<NSTableViewDelegate, NSTableViewDataSource, NSPopoverDelegate>
{
    NSDictionary * dicForShowInTableview;
    
    NSMutableArray * m_arrDailyWork;
    NSMutableArray * m_arrValidationMail;
    NSMutableArray * m_arrRollInMail;
    
    
}

@end

@implementation HistoryViewController

@synthesize tvHistory = _tvHistory;
@synthesize segCategory = _segCategory;


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do view setup here.
    
      m_arrDailyWork =[[NSMutableArray alloc]init];
      m_arrValidationMail =[[NSMutableArray alloc]init];
    
    
    
    NSDictionary * dicSettings	= [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SettingFile" ofType:@"plist"]];
    NSString * filePath =[dicSettings objectForKey:@"HistoryRecordPath"];
    
    NSFileManager * fm =[NSFileManager defaultManager];
    if (![fm fileExistsAtPath:filePath])
    {
        NSAlert *alert = [[NSAlert alloc]init];
        alert.messageText = @"亲：";
        alert.informativeText = [NSString stringWithFormat:@"你是第一次使用或历史记录丢失导致无法打开,\n请发Mail再来看历史。\n（毕竟啥都没有看个毛线啊！-_-|||）"];
        [alert addButtonWithTitle:@"确认(OK)"];
        [alert setAlertStyle:NSWarningAlertStyle];
        if ([alert runModal] == NSAlertFirstButtonReturn)
        {
//            return;
            [self dismissViewController:self];
            
            
        }
    }
    else
    {
        
        dicForShowInTableview =[NSDictionary dictionaryWithContentsOfFile:filePath];
        
        _segCategory.selectedSegment = 0;
        [_segCategory setTarget:self];
        [_segCategory setAction:@selector(loadTableView:)];
        
        _tvHistory.delegate = self;
        _tvHistory.dataSource = self;
        
        [_tvHistory setAllowsTypeSelect:YES];
        
        [self UpdateHeaderCellForCategory:[_segCategory selectedSegment]];
        
        [self UpdateDataforCategoryAndReloadView:@"DailyWork"];
        
    }
    
    
    
}


-(void)loadTableView :(id)sender
{
    NSInteger clickSegTag =[sender selectedSegment];
    switch (clickSegTag)
    {
        case 0:
            [m_arrDailyWork removeAllObjects];
            [self UpdateHeaderCellForCategory:0];
            [self UpdateDataforCategoryAndReloadView:@"DailyWork"];
            
            break;
            
        case 1:
            [m_arrValidationMail removeAllObjects];
            [self UpdateHeaderCellForCategory:1];
            [self UpdateDataforCategoryAndReloadView:@"Validation_Mail"];

            break;
            
        default:
            break;
    }
}
-(void)UpdateDataforCategoryAndReloadView :(NSString *)category
{
    if ([category isEqualToString:@"DailyWork"])
    {
        
        NSArray * arrDailyWork = [dicForShowInTableview objectForKey:@"Assign_Work_Mail"];

            for (int i = 0; i < arrDailyWork.count; i++)
            {
                NSArray * arrTmp =[[arrDailyWork objectAtIndex:i]allKeys];
                
                NSDictionary * dictemp =[[arrDailyWork objectAtIndex:i ]objectForKey :[arrTmp objectAtIndex:0]];
                
                NSString * time = [dictemp objectForKey:@"Time"];
                
                NSString * AssignPerson = [dictemp objectForKey:@"AssignPerson"];
                NSString * TaskContent =[dictemp objectForKey:@"TaskContent"];
                NSString * DailyMailTitle =[dictemp objectForKey:@"DailyMailTitle"];
                                           
                NSDictionary * dicTemp =@{@"Time":time,
                                          @"AssignPerson":AssignPerson,
                                          @"TaskContent":TaskContent,
                                          @"DailyMailTitle":DailyMailTitle};
                [m_arrDailyWork addObject:dicTemp];
                [self performSelectorOnMainThread:@selector(updateTableView) withObject:nil waitUntilDone:NO];
                
            }
    }

    if ([category isEqualToString:@"Validation_Mail"])
    {
        
        NSArray * arrValidationTemp = [dicForShowInTableview objectForKey:@"Validation_Mail"];
            for (int i = 0; i < arrValidationTemp.count; i++)
            {
                NSArray * arrTmp =[[arrValidationTemp objectAtIndex:i]allKeys];
                
                NSDictionary * dictemp =[[arrValidationTemp objectAtIndex:i ]objectForKey :[arrTmp objectAtIndex:0]];
                
                NSString * time = [dictemp objectForKey:@"Time"];
                NSString * strNewOverlay = [dictemp objectForKey:@"Latest Overlay Version"];
                NSString * strNewJSON =[dictemp objectForKey:@"Latest Live Version"];
                NSString * strchangelist =[dictemp objectForKey:@"changelist"];
                NSString * strNewTestAll = [dictemp objectForKey:@"Latest Testall Version"];
                NSString * strStation   =   [dictemp objectForKey:@"Station"];
                
                
                NSDictionary * dicTemp =@{@"V_Overlay":strNewOverlay,
                                          @"V_JSON":strNewJSON,
                                          @"V_Testall":strNewTestAll,
                                          @"V_ChangeList":strchangelist,
                                          @"V_Station": strStation,
                                          @"Time":time};
                [m_arrValidationMail addObject:dicTemp];
            }
                [self performSelectorOnMainThread:@selector(updateTableView) withObject:nil waitUntilDone:NO];
    }

}

#pragma mark database for tableview
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    if (_segCategory.selectedSegment == 0)
    {
        return [m_arrDailyWork count];
        
    }
    if (_segCategory.selectedSegment == 1)
    {
        return [m_arrValidationMail count];
        
    }
    else
        return [m_arrValidationMail count];
    
}

- (nullable id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSLog(@"%@",tableColumn.identifier);
    
    // for Daily work
    if (_segCategory.selectedSegment == 0)
    {
        if ([tableColumn.identifier isEqualToString:@"Column1"])
        {
            return [[m_arrDailyWork objectAtIndex:row] objectForKey:@"AssignPerson"] ;
            
        }
        if ([tableColumn.identifier isEqualToString:@"Column2"])
        {
            if ([[m_arrDailyWork objectAtIndex:row] objectForKey:@"Urgent"])
            {
                return @"YES";
            }
            else
            {
                return @"NO";
            }
            
            
        }

        if ([tableColumn.identifier isEqualToString:@"Column3"])
        {
            
            return [[m_arrDailyWork objectAtIndex:row] objectForKey:@"TaskContent"] ;
            
        }
        if ([tableColumn.identifier isEqualToString:@"Column4"])
        {
            NSLog(@"Column3 the %ld row: %@", (long)row,[[m_arrDailyWork objectAtIndex:row] objectForKey:@"DailyMailTitle"]);
            
            return [[m_arrDailyWork objectAtIndex:row] objectForKey:@"DailyMailTitle"] ;

        }
        else
        {
            NSLog(@"Column4 the %ld row: %@", (long)row,[[m_arrDailyWork objectAtIndex:row] objectForKey:@"Time"]);
            
            return [[m_arrDailyWork objectAtIndex:row] objectForKey:@"Time"];
        }

    }
    // for Validation
    else
    {
        if ([tableColumn.identifier isEqualToString:@"Column1"])
        {
            NSLog(@"Column1  the %ld row: %@", (long)row,[[m_arrValidationMail objectAtIndex:row] objectForKey:@"V_Station"]);
            
            return [[m_arrValidationMail objectAtIndex:row] objectForKey:@"V_Station"] ;
            
        }
        if ([tableColumn.identifier isEqualToString:@"Column2"])
        {
            NSLog(@"Column2 the %ld row: %@", (long)row,[[m_arrValidationMail objectAtIndex:row] objectForKey:@"V_JSON"]);
            
            return [[m_arrValidationMail objectAtIndex:row] objectForKey:@"V_JSON"] ;
            
        }
        if ([tableColumn.identifier isEqualToString:@"Column3"])
        {
            NSLog(@"Column3 the %ld row: %@", (long)row,[[m_arrValidationMail objectAtIndex:row] objectForKey:@"V_Testall"]);
            
            return [[m_arrValidationMail objectAtIndex:row] objectForKey:@"V_Testall"] ;
            
        }
        if ([tableColumn.identifier isEqualToString:@"Column4"])
        {
            NSLog(@"Column3 the %ld row: %@", (long)row,[[m_arrValidationMail objectAtIndex:row] objectForKey:@"V_Overlay"]);
            
            return [[m_arrValidationMail objectAtIndex:row] objectForKey:@"V_Overlay"] ;

        }
        else
        {
            NSLog(@"Column4 the %ld row: %@", (long)row,[[m_arrValidationMail objectAtIndex:row] objectForKey:@"Time"]);
            
            return [[m_arrValidationMail objectAtIndex:row] objectForKey:@"Time"];
            
        }
        
    }
 
    
}
-(void)UpdateHeaderCellForCategory:(NSInteger )number
{
    NSArray * numberOfColumns =[_tvHistory tableColumns];

    if ( number == 0)
    {
        for (int i = 0; i < [numberOfColumns count]; i ++)
        {
            NSTableColumn * tableColumn =[numberOfColumns objectAtIndex:i];
            if ([tableColumn.identifier isEqualToString:@"Column1"])
            {
                [[tableColumn headerCell]setTitle:@"AssignTo"];

            }
            if ([tableColumn.identifier isEqualToString:@"Column2"])
            {
                [[tableColumn headerCell]setTitle:@"Urgent?"];
            }
            if ([tableColumn.identifier isEqualToString:@"Column3"])
            {
                [[tableColumn headerCell]setTitle:@"Content"];

            }
            if ([tableColumn.identifier isEqualToString:@"Column4"])
            {
                [[tableColumn headerCell]setTitle:@"MailTitle"];
            }
            if ([tableColumn.identifier isEqualToString:@"Column5"])
            {
                [[tableColumn headerCell]setTitle:@"Time"];
            }
        }
    }
    if ( number == 1)
    {
        for (int i = 0; i < [numberOfColumns count]; i ++)
        {
            NSTableColumn * tableColumn =[numberOfColumns objectAtIndex:i];
            if ([tableColumn.identifier isEqualToString:@"Column1"])
            {
                [[tableColumn headerCell]setTitle:@"STATION"];
                
            }
            if ([tableColumn.identifier isEqualToString:@"Column2"])
            {
                [[tableColumn headerCell]setTitle:@"JSON"];
                
            }
            if ([tableColumn.identifier isEqualToString:@"Column3"])
            {
                [[tableColumn headerCell] setTitle:@"TESTALL"];
            }
            if ([tableColumn.identifier isEqualToString:@"Column4"])
            {
                [[tableColumn headerCell]setTitle:@"OVERLAY"];
                
            }
            if ([tableColumn.identifier isEqualToString:@"Column5"])
            {
                [[tableColumn headerCell]setTitle:@"Time"];
                
            }
        }
    }
}

-(BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    NSLog(@"selected row is%ld",(long)row);
    if (row == 0)
    {
        return NO;
        
    }
    else
    {
        return YES;
        
    }
}
-(NSIndexSet *)tableView:(NSTableView *)tableView selectionIndexesForProposedSelection:(NSIndexSet *)proposedSelectionIndexes
{
    return proposedSelectionIndexes;
    
}
-(void)tableViewSelectionIsChanging:(NSNotification *)notification
{
    NSLog(@"select changing");
    
}
-(void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSLog(@"select did change");
    NSViewController * vc   =   [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"PopOver"];
    NSTextView * tv_Lable  =   [[NSTextView alloc]initWithFrame:NSMakeRect(0, 0, vc.view.bounds.size.width, vc.view.bounds.size.height)];

    [tv_Lable setEditable:NO];
    
    NSInteger selcetedRow =   [_tvHistory selectedRow];
    NSInteger selectedSeg =   [_segCategory selectedSegment];
    NSMutableDictionary * dicAttributeTitle =[[NSMutableDictionary alloc]init];
    
    [dicAttributeTitle setObject:[NSFont fontWithName:@"Consolas" size:15.0f] forKey:NSFontAttributeName];
    [dicAttributeTitle setObject:[NSColor blueColor] forKey:NSForegroundColorAttributeName];

    if (selectedSeg == 0)
    {
        NSDictionary * dicInfo  =   [m_arrDailyWork objectAtIndex:selcetedRow];
        NSArray *   arrCount    =   [dicInfo allKeys];
        NSMutableAttributedString * strTem    =   [[NSMutableAttributedString alloc]init];
        NSMutableString * strTmp              =   [NSMutableString string];
        
        for (int i =0 ; i<arrCount.count; i++)
        {
            [strTmp appendFormat:@"%@ : %@ \n\n",arrCount[i],[dicInfo objectForKey:arrCount[i]]];

        }
        [strTem setAttributedString:[[NSAttributedString alloc]initWithString:strTmp attributes:dicAttributeTitle]];

        [[tv_Lable textStorage]appendAttributedString:strTem];
    

    }
    else
    {
        NSDictionary * dicInfo  =   [m_arrValidationMail objectAtIndex:selcetedRow];
        NSArray *   arrCount    =   [dicInfo allKeys];
        NSMutableString * strTemp    =   [NSMutableString string];
        NSMutableAttributedString * strTem    =   [[NSMutableAttributedString alloc]init];
        

        for (int i =0 ; i<arrCount.count; i++)
        {
            if ([arrCount[i] isEqualToString:@"V_ChangeList"])
            {
                [strTemp appendFormat:@"Change List :\n %@ \n\n",[dicInfo objectForKey:arrCount[i]]];
            }
            
        }
        [strTem setAttributedString:[[NSAttributedString alloc]initWithString:strTemp attributes:dicAttributeTitle]];
        
        
        [[tv_Lable textStorage]appendAttributedString:strTem];
        
   
    }
    [vc.view addSubview:tv_Lable];

    NSPopover   * popOver   =   [[NSPopover alloc] init];
    popOver.behavior        =  NSPopoverBehaviorTransient;
    popOver.contentViewController   =   vc;
    [popOver showRelativeToRect:[_tvHistory bounds] ofView:_tvHistory preferredEdge:NSRectEdgeMaxX];
    
}

-(void)updateTableView
{
    [_tvHistory reloadData];
    
}

-(void)popoverDidShow:(NSNotification *)notification
{
    NSLog(@"popover did show");
    
}

-(void)popoverDidClose:(NSNotification *)notification
{
    NSLog(@"popover did close");
    
}

@end
