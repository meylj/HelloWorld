//
//  AppDelegate.m
//  FScripts
//
//  Created by chenchao on 14/11/6.
//  Copyright (c) 2014年 chenchao. All rights reserved.
//

#import "AppDelegate.h"

//@interface AppDelegate ()
//
//@property (weak) IBOutlet NSWindow *window;
//@end

@implementation AppDelegate


- (void)awakeFromNib
{
    [m_window setTitle:@"FScripts V1.1"];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [m_btnCreateFirstGHScript setEnabled:NO];
    [m_btnCreateSecondScript setEnabled:NO];
    m_iChangeCount  = 0;
    
    

}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    // Insert code here to tear down your application
}

//- (void)ReturnHandler:(NSModalResponse)ReturnCode
//{
//    NSLog(@"Start Return Handler");
//    if (ReturnCode == NSAlertFirstButtonReturn)
//    {
//        NSLog(@"CONTINUE");
//    }
//    if (ReturnCode == NSAlertSecondButtonReturn)
//    {
//        NSLog(@"RETURN");
//    }
//    NSLog(@"End Return Handler");
//}

//For get original test script URL
- (IBAction)GetFirstScript:(id)sender
{
    NSOpenPanel *openPanel=[NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setPrompt:@"Choose"];
    [openPanel setTitle:@"Please choose the orgional script"];
    if ([openPanel runModal] == NSModalResponseOK)
    {
        [m_pcGetFirstScript setURL:[[openPanel URLs] objectAtIndex:0]];
    }
    [m_btnCreateFirstGHScript setEnabled:YES];
    m_iChangeCount = 0;
}
//According to original test script url, get file data.
- (IBAction)CreateFirstGHScript:(id)sender
{
    NSString    *szFilePath = [[m_pcGetFirstScript URL] absoluteString];
    NSLog(@"szFilePath=%@",szFilePath);
    szFilePath = [szFilePath stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    NSLog(@"szFilePath=%@",szFilePath);
    NSArray     *arrFirstScriptData = [NSArray arrayWithContentsOfFile:szFilePath];
    NSLog(@"arrFirstScriptData=%@",arrFirstScriptData);
    
    [self CreateGHScript:arrFirstScriptData];
    [m_btnCreateFirstGHScript setEnabled:NO];
    m_iChangeCount = 0;
}
//According to original test script file data, create the GH file
- (void)CreateGHScript:(NSArray *)FirstScriptData
{
    NSMutableDictionary *dicGHData  = [[NSMutableDictionary alloc]init];
    for (int i = 0; i < [FirstScriptData count]; i++)
    {
        BOOL    bHaveJudge  = NO;
        NSDictionary    *dicItem        = [FirstScriptData objectAtIndex:i];
        NSString        *strItemName    = [[dicItem allKeys] objectAtIndex:0];
        NSArray         *arrSubItems    = [dicItem objectForKey:strItemName];
        
        int iJudgeItemCount = 0;
        for (int j = 0; j < [arrSubItems count]; j++)
        {
            NSDictionary    *dicSubItem       = [arrSubItems objectAtIndex:j];
            NSString        *strSubItemName   = [[dicSubItem allKeys] objectAtIndex:0];
            NSRange         JudgeRange        = [strSubItemName rangeOfString:@"JUDGE_SPEC"];
            if (JudgeRange.location !=NSNotFound)
            {
                bHaveJudge = YES;
                NSString    *strNewSpec = [[[dicSubItem objectForKey:strSubItemName] objectForKey:@"COMMON_SPEC"]objectForKey:@"P_LimitBlack"];
                if (iJudgeItemCount > 0)
                {
                    [dicGHData setObject:strNewSpec forKey:[NSString stringWithFormat:@"%@%d",strItemName,iJudgeItemCount]];
                }
                else
                {
                    [dicGHData setObject:strNewSpec forKey:strItemName];
                }
                iJudgeItemCount = iJudgeItemCount + 1;
            }
        }
        
        if (!bHaveJudge)
        {
            [dicGHData setObject:@"{NA}" forKey:strItemName];
        }
        
    }
    [dicGHData setObject:[m_txtLiveVerFirst stringValue] forKey:@"LIVE_VER"];
    
    NSString    *strFirstGHScriptPath   = [NSString stringWithFormat:@"%@/Desktop/GH.plist",NSHomeDirectory()];
    [dicGHData writeToFile: strFirstGHScriptPath atomically: NO];
    [dicGHData removeAllObjects];
    m_iChangeCount = 0;
}


//For get GH script URL with modified by manually
- (IBAction)GetSecondGHScript:(id)sender
{
    NSOpenPanel *openPanel=[NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setPrompt:@"Choose"];
    [openPanel setTitle:@"Please choose the orgional script"];
    if ([openPanel runModal] == NSModalResponseOK)
    {
        [m_pcGetSecondGHScript setURL:[[openPanel URLs] objectAtIndex:0]];
    }
    [m_btnCreateSecondScript setEnabled:YES];
    m_iChangeCount = 0;
}
//According to original test script url, get file data.
//According to GH script url, get file data.
- (IBAction)CreateSecondScript:(id)sender
{
    NSString    *szFilePath1 = [[m_pcGetFirstScript URL] absoluteString];
    szFilePath1 = [szFilePath1 stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    NSLog(@"szFilePath=%@",szFilePath1);
    NSArray     *arrFirstScriptData = [NSArray arrayWithContentsOfFile:szFilePath1];
    NSLog(@"arrFirstScriptData=%@",arrFirstScriptData);
    
    NSString    *szFilePath2 = [[m_pcGetSecondGHScript URL] absoluteString];
    szFilePath2 = [szFilePath2 stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    NSLog(@"szFilePath=%@",szFilePath2);
    NSDictionary    *dicSecondGHData= [NSDictionary dictionaryWithContentsOfFile:szFilePath2];
    NSLog(@"dicSecondGHData=%@",dicSecondGHData);
    
    [self CreateScript:arrFirstScriptData GetGHScript:dicSecondGHData];
    [m_btnCreateSecondScript setEnabled:NO];
    m_iChangeCount = 0;
}

//According to original and GH script file data, create the final script file
- (void)CreateScript:(NSArray *)FirstScriptData GetGHScript:(NSDictionary *)GHScriptData
{
    NSArray         *arrSecondGHItems = [GHScriptData allKeys];
    NSMutableArray  *arrAllItems    = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < [FirstScriptData count]; i++)
    {
        NSDictionary    *dicItem        = [FirstScriptData objectAtIndex:i];
        NSString        *strItemName    = [[dicItem allKeys] objectAtIndex:0];
        NSArray         *arrSubItems    = [dicItem objectForKey:strItemName];
        
        //Check whether control by GH
        //Check whether have judge spec function
        BOOL    bGHControl  = NO;
        BOOL    bNoTest     = NO;
        for (NSString *strGHItemName in arrSecondGHItems)
        {
            NSRange rangeJudge  = [strGHItemName rangeOfString:strItemName];
            if (rangeJudge.location != NSNotFound)
            {
                //This Item Control by GH
                bGHControl = YES;
                for (int k = 0; k < [arrSubItems count]; k++)
                {
                    NSDictionary    *dicSubItem    = [arrSubItems objectAtIndex:k];
                    NSString        *strSubItemName    = [[dicSubItem allKeys] objectAtIndex:0];
                    NSRange         JudgeRangeError         = [strSubItemName rangeOfString:@"JUDGE_SPEC"];
                    
                    if (JudgeRangeError.location != NSNotFound)
                    {
                        //This Item No Judge Spec Function
                        bNoTest = YES;
                    }
                }
            }
        }
        
        
        
        //Control by GH
        if (bGHControl)
        {
            //No Judge Spec Function, Need Pop up Warning Window.
            //Choose CONTINUE -> continue modify and create script, but this item no any change.
            //Choose RETURN   -> Stop modify and create script.
            if (!bNoTest)
            {
                
                NSString    *strWarningMessage  = [NSString stringWithFormat:@"No Judge Spec function at item %@",strItemName];
                NSAlert *objAlert   = [[NSAlert alloc]init];
                [objAlert addButtonWithTitle:@"RETURN"];
                [objAlert addButtonWithTitle:@"CONTINUE"];
                [objAlert setMessageText:@"Warning"];
                [objAlert setInformativeText:strWarningMessage];
                [objAlert setAlertStyle:NSCriticalAlertStyle];
                
//                [objAlert beginSheetModalForWindow:m_window completionHandler:^(NSModalResponse returnCode)
//                 {
//                     NSLog(@"Start completionHandler");
//                     if (returnCode == NSAlertFirstButtonReturn)
//                     {
//                         NSLog(@"CONTINUE");
//                     }
//                     if (returnCode == NSAlertSecondButtonReturn)
//                     {
//                         NSLog(@"RETURN");
//                         return;
//                     }
//                     //[self ReturnHandler:returnCode];
//                     NSLog(@"End completionHandler");
//                 }];
                
                NSModalResponse modalResponse = [objAlert runModal];
                
                switch (modalResponse)
                {
                    case NSAlertFirstButtonReturn:
                        NSLog(@"modalResponse RETURN");
                        return;
                        
                    default:
                        NSLog(@"modalResponse CONTINUE");
                        break;
                }
                NSLog(@"FUCK UP");
            }
            
            
            //Modified the Judge function spec to test Item Name if this item have Judge spec function
            NSMutableArray  *arrNewSubItems = [[NSMutableArray alloc]init];
            int iJudgeItemCount = 0;
            for (int j = 0; j < [arrSubItems count]; j++)
            {
                NSDictionary    *dicSubItem    = [arrSubItems objectAtIndex:j];
                NSString        *strSubItemName    = [[dicSubItem allKeys] objectAtIndex:0];
                NSRange         JudgeRange         = [strSubItemName rangeOfString:@"JUDGE_SPEC"];
                if (JudgeRange.location !=NSNotFound)
                {
                    
                    if (iJudgeItemCount > 0)
                    {
                        NSString        *strCurrentSpec    = [[[dicSubItem objectForKey:strSubItemName] objectForKey:@"COMMON_SPEC"]objectForKey:@"P_LimitBlack"];
                        NSDictionary    *dicNewSpecValue   = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"[*%@%d*]",strItemName,iJudgeItemCount] forKey:@"P_LimitBlack"];
                        NSDictionary    *dicNewSpecCommon  = [NSDictionary dictionaryWithObject:dicNewSpecValue forKey:@"COMMON_SPEC"];
                        NSDictionary    *dicNewSpecJudge   = [NSDictionary dictionaryWithObject:dicNewSpecCommon forKey:@"JUDGE_SPEC:RETURN_VALUE:"];
                        [arrNewSubItems addObject:dicNewSpecJudge];
                        
                        NSString    *strModifyLog   = [NSString stringWithFormat:@"%@\n%@->%@%d\n",strItemName,strCurrentSpec,strItemName,iJudgeItemCount];
                        
                        [self WriteToFile:strModifyLog];
                    }
                    else
                    {
                        NSString        *strCurrentSpec    = [[[dicSubItem objectForKey:strSubItemName] objectForKey:@"COMMON_SPEC"]objectForKey:@"P_LimitBlack"];
                        NSDictionary    *dicNewSpecValue   = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"[*%@*]",strItemName] forKey:@"P_LimitBlack"];
                        NSDictionary    *dicNewSpecCommon  = [NSDictionary dictionaryWithObject:dicNewSpecValue forKey:@"COMMON_SPEC"];
                        NSDictionary    *dicNewSpecJudge   = [NSDictionary dictionaryWithObject:dicNewSpecCommon forKey:@"JUDGE_SPEC:RETURN_VALUE:"];
                        [arrNewSubItems addObject:dicNewSpecJudge];
                        
                        NSString    *strModifyLog   = [NSString stringWithFormat:@"%@\n%@->%@\n",strItemName,strCurrentSpec,strItemName];
                        
                        [self WriteToFile:strModifyLog];
                    }
                    iJudgeItemCount = iJudgeItemCount + 1;
                    

                }
                else
                {
                    [arrNewSubItems addObject:dicSubItem];
                }
            }
            
            [arrAllItems addObject:[NSDictionary dictionaryWithObject:arrNewSubItems forKey:strItemName]];
        }
        //Control by Local
        else
        {
            [arrAllItems addObject:dicItem];
        }
        
    }
    
    NSString    *strSecondScriptPath   = [NSString stringWithFormat:@"%@/Desktop/TEST.plist",NSHomeDirectory()];
    [arrAllItems writeToFile: strSecondScriptPath atomically: NO];
    [arrAllItems removeAllObjects];
    m_iChangeCount = 0;
}

- (void)WriteToFile: (NSString*)FileData
{
    m_iChangeCount  = m_iChangeCount + 1;
    NSString    *strFileData    = [NSString stringWithFormat:@"%d:%@",m_iChangeCount,FileData];
    NSString    *strFilePath    = [NSString stringWithFormat:@"%@/Desktop/ModifyLog.csv",NSHomeDirectory()];
    NSFileHandle	*fileHandle		= [NSFileHandle fileHandleForWritingAtPath:strFilePath];
    
    if (!fileHandle)
        [strFileData writeToFile:strFilePath
                      atomically:NO
                        encoding:NSUTF8StringEncoding
                           error:nil];
    else
    {
        NSData	*dataTemp	= [[NSData alloc] initWithBytes:(void *)[strFileData UTF8String]
                                                  length:[strFileData length]];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:dataTemp];
        [fileHandle closeFile];
    }
    
}
@end
