//
//  ToGetPlistScript.m
//  ToolForModifyTestallFile
//
//  Created by Linda8_Yang on 9/23/16.
//  Copyright © 2016 Linda8_Yang. All rights reserved.
//

#import "ToGetPlistScript.h"

@implementation ToGetPlistScript

-(id)init
{
    if (self = [super init])
    {
        _arrNewItems = [[NSMutableArray alloc]init];
    }
    return self;
}

-(void)dealloc
{
    [_arrNewItems release];
    [super dealloc];
}


// combine the JSON and testall
- (BOOL)ParseAndCombineJson:(NSString *)strLivePath withLiveTestAll:(NSString *)strLiveTestAllPath
{
    BOOL    bCreateScript   = YES;
    
    
    NSString        *strJsonData    = [[NSString alloc] initWithContentsOfFile:strLivePath
                                                                      encoding:NSUTF8StringEncoding
                                                                         error:nil];
    NSData          *dtJsonData     = [strJsonData dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary    *dicJsonData    = [NSJSONSerialization JSONObjectWithData:dtJsonData
                                                                      options:NSJSONReadingMutableLeaves
                                                                        error:nil];
    [strJsonData release];  strJsonData = nil;
    
    //add function to match the version of JSON file by testall
    if (![self MatchPistVersion:strLiveTestAllPath withJSON:strLivePath])
    {
        bCreateScript = NO;
        return bCreateScript;
        
    }
    //Create Test Script
    else
    {
        bCreateScript  &= [self CombineScriptFile:strLiveTestAllPath JsonData:dicJsonData];
    }
    return bCreateScript;
}

//match the testall and JSON file version

-(BOOL)MatchPistVersion:(NSString *)strTestallPath withJSON:(NSString *)strJSONPath
{
    NSFileManager *fm =[NSFileManager defaultManager];
    
    NSDictionary *dicTestAll =[NSDictionary dictionaryWithContentsOfFile:strTestallPath];
    NSString * LiveMatchVersion =[dicTestAll objectForKey:@"JSON Version"];
    NSString * LiveInJSON =[self GetLiveVersion:strJSONPath];
    
    if ([fm fileExistsAtPath:strTestallPath] && [fm fileExistsAtPath:strJSONPath])
    {
        if ([LiveInJSON isEqualToString:LiveMatchVersion])
        {
            
            NSLog(@"the Live version in testall is matching with the Live version in JSON file");
            return  YES;
            
        }
        else
        {
            NSLog(@"the Live version in testall is %@ NO MATCHING with the Live version in JSON file %@\n",LiveMatchVersion,LiveInJSON);
            
            NSAlert *alert = [[NSAlert alloc]init];
            alert.messageText = @"警告(Warning)";
            alert.informativeText = [NSString stringWithFormat:@"The JSON file version in Testall is %@, but the current JSON file is %@, NOT MATCHING",LiveMatchVersion,LiveInJSON];
            [alert addButtonWithTitle:@"确认(OK)"];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert runModal];
            [alert release];
            
            [NSApp terminate:self];
            return NO;
        }
        
    }
    else
    {
        NSLog(@"TestAll or JSON do not exist at the default path %@ and %@",strTestallPath,strJSONPath);
        return NO;
        
    }
}

- (NSString *)GetLiveVersion:(NSString *)strLivePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:strLivePath])
    {
        return nil;
    }
    NSString        *strJsonData    = [[NSString alloc] initWithContentsOfFile:strLivePath encoding:NSUTF8StringEncoding error:nil];
    NSData          *dtJsonData     = [strJsonData dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary    *dicJsonData    = [NSJSONSerialization JSONObjectWithData:dtJsonData options:NSJSONReadingMutableLeaves error:nil];
    NSString        *strNewLiveVersion  = [[dicJsonData objectForKey:@"data"]objectForKey:@"Versions"];
    [strJsonData release];  strJsonData = nil;
    if (!strNewLiveVersion)
    {
        return nil;
    }
    else
        return strNewLiveVersion;
}

-(BOOL)CombineScriptFile:(NSString *)szScriptFilePath JsonData:(NSDictionary*)dicJsonData
{
    if ([_arrNewItems count] != 0)
    {
        [_arrNewItems removeAllObjects];
    }
    
    //For write logs
    BOOL    bRet    = YES;
    NSString    *strFilePath    = @"/vault/Live_Log.txt";
    NSFileManager   *fileManage = [NSFileManager defaultManager];
    if ([fileManage fileExistsAtPath:strFilePath])
    {
        [fileManage removeItemAtPath:strFilePath error:nil];
    }
    
    [self WriteString:@"===================================  CREATE TEST ITEMS  ===================================\n" FilePath:strFilePath];
    
    //Get testall data
    NSDictionary    *dicTestAllItems    = [[NSDictionary dictionaryWithContentsOfFile:szScriptFilePath]objectForKey:@"SUBITEMS"];
    NSDictionary    *dicTestAllItemsControl    = [[NSDictionary dictionaryWithContentsOfFile:szScriptFilePath]objectForKey:@"ITEMSCONTROL"];
    
    //Get Json item data
    NSArray         *arrJsonItems       = [[dicJsonData objectForKey:@"data"] objectForKey:@"tests"];
    
    for (int i = 0; i < [arrJsonItems count]; i++)
    {
        NSDictionary    *dicJsonItemData        = [arrJsonItems objectAtIndex:i];
        //New sub item
        NSArray  *arrNewSubItems = nil;
        
        // Get item's sub and main name from json
        NSString        *strJsonItemMainName    = [[dicJsonItemData objectForKey:@"Name"] objectForKey:@"main"];
        NSMutableArray  *aryJsonSubItems    = [NSMutableArray array];
        if ([[[dicJsonItemData objectForKey:@"Name"] allKeys] containsObject:@"sub1"])
        {
            NSDictionary *dicNames = [dicJsonItemData objectForKey:@"Name"];
            for (int i = 1; i < [dicNames count]; i++)
            {
                [aryJsonSubItems addObject:[dicNames objectForKey:[NSString stringWithFormat:@"sub%d",i]]];
            }
        }
        [aryJsonSubItems addObject:strJsonItemMainName];
        NSAssert(strJsonItemMainName,@"Can not find the item of %@",strJsonItemMainName);
        
        NSArray         *arrJsonItemCommands    = [dicJsonItemData objectForKey:@"Commands"];
        NSString        *strDebugLogItem    = [self FormatStringToSpecial:strJsonItemMainName];
        [self WriteString:[NSString stringWithFormat:@"%@\n",strDebugLogItem] FilePath:strFilePath];
        
        // Get the Spec and Units from singal item
        
        for (NSString *strSubName in aryJsonSubItems)
        {
            //serach ITEMSCONTROL in TESTALL
            if ([dicTestAllItemsControl objectForKey:strSubName])
            {
                NSArray *arrItemsControl = [dicTestAllItemsControl objectForKey:strSubName];
                for (NSString *strDBItem in arrItemsControl)
                {
                    if ([strDBItem isEqualToString:strSubName])
                    {
                        arrNewSubItems = [self MatchTestAll:dicTestAllItems
                                                   WithName:strDBItem
                                                    WithCom:arrJsonItemCommands];
                    }
                    else
                    {
                        arrNewSubItems = [self MatchTestAll:dicTestAllItems
                                                   WithName:strDBItem
                                                    WithCom:[NSArray arrayWithObject:@"*"]];
                    }
                    if (!arrNewSubItems || [arrNewSubItems count]==0)
                    {
                        bRet = NO;
                    }
                    else
                        [_arrNewItems addObject:[NSDictionary dictionaryWithObject:arrNewSubItems forKey:strDBItem]];
                }
            }
            //serach SUBITEMS in TESTALL
            else
            {
                arrNewSubItems = [self MatchTestAll:dicTestAllItems
                                           WithName:strSubName
                                            WithCom:arrJsonItemCommands];
                if (!arrNewSubItems || [arrNewSubItems count]==0)
                {
                    bRet = NO;
                }
                else
                    [_arrNewItems addObject:[NSDictionary dictionaryWithObject:arrNewSubItems forKey:strSubName]];
            }
        }
    }
    
    
    NSString    *szFilePath = [NSString stringWithFormat:@"%@/Desktop/old_%@",NSHomeDirectory(),[szScriptFilePath lastPathComponent]];
    
    if([_arrNewItems writeToFile:szFilePath atomically:YES])
        NSLog(@"Creat new testall file successfully!");
    else
        NSLog(@"Creat new testall file failed!");

    
    return bRet;
}

- (NSString *)FormatStringToSpecial:(NSString *)StringData
{
    NSString    *strOriginal  = [NSString stringWithFormat:@"  %@  ",StringData];
    NSUInteger   iOrigLength   = [strOriginal length];
    NSUInteger iSpecail    = (90 - iOrigLength)/2;
    
    NSMutableString *strNewData = [[NSMutableString alloc]init];
    for (NSUInteger i = 0; i < iSpecail; i++)
    {
        [strNewData appendString:@"-"];
    }
    
    NSString    *strReturn  = [NSString stringWithFormat:@"%@%@%@",strNewData,strOriginal,strNewData];
    
    [strNewData release];
    return strReturn;
    
}

- (NSArray*)MatchTestAll:(NSDictionary *)dicTestAllItems
                WithName:(NSString *)strName
                 WithCom:(NSArray *)arrCom

{
    NSMutableArray  *arrNewSubItems  = [NSMutableArray array];
    NSString    *strFilePath    = @"/vault/Live_Log.txt";
    NSString    *strCmd_ID = @"[*JSON_COMMAND*]";
    void(^FindJsonCmdAndReplace)(NSMutableArray *pAryItem,NSString *pszCommand) = ^(NSMutableArray *pAryItem,NSString *pszCommand)
    {
        for (NSMutableDictionary *dictData in pAryItem)
        {
            for (NSString *sKey in [dictData allKeys])
            {
                
                if ([sKey isEqualToString:@"SEND_COMMAND:"])
                {
                    NSMutableDictionary *dictSubItem = [dictData objectForKey:sKey];
                    if ([[dictSubItem valueForKey:@"TARGET"] containsString:@"MOBILE"] && [[dictSubItem valueForKey:@"STRING"] containsString:strCmd_ID]) {
                        NSString    *szTargetCmd = [[dictSubItem valueForKey:@"STRING"]
                                                    stringByReplacingOccurrencesOfString:strCmd_ID withString:pszCommand];
                        [dictSubItem setValue:szTargetCmd forKey:@"STRING"];
                    }
                }
                else if ([sKey isEqualToString:@"READ_COMMAND:RETURN_VALUE:"])
                {
                        NSMutableDictionary *dictSubItem = [dictData objectForKey:sKey];
                        if ([[dictSubItem valueForKey:@"TARGET"] containsString:@"MOBILE"] && [[dictSubItem valueForKey:@"BEGIN"] containsString:strCmd_ID])
                        {
                            NSString    *szTargetCmd = [[dictSubItem valueForKey:@"BEGIN"]
                                                        stringByReplacingOccurrencesOfString:strCmd_ID withString:pszCommand];
                            [dictSubItem setValue:szTargetCmd forKey:@"BEGIN"];
                        }
                }
                else if ([sKey isEqualToString:@"JUDGE_SPEC:RETURN_VALUE:"])
                {
                    NSMutableDictionary *dictSubItem = [dictData objectForKey:sKey];
                    NSMutableDictionary *dictSubSubItem = [dictSubItem objectForKey:@"COMMON_SPEC"];
                    NSString *strSpecValue = [dictSubSubItem objectForKey:@"P_LimitBlack"];
                    if (![strSpecValue isEqualToString:[NSString stringWithFormat:@"[*%@_spec*]",strName]])
                    {
                        [dictSubSubItem setValue:[NSString stringWithFormat:@"[*%@_spec*]",strName] forKey:@"P_LimitBlack"];
                        
                        //[dictSubItem setValue:dictSubSubItem forKey:sKey];
                    }
                }
                else if ([sKey isEqualToString:@"SET_PROCESS_STATUS:RETURN_VALUE:"])
                {
                    NSMutableDictionary *dictSubItem = [dictData objectForKey:sKey];
                    
                    if ([[dictSubItem allKeys] containsObject:@"IP_unit"])
                    {
                        NSString *strErrorUnit = [dictSubItem objectForKey:@"IP_unit"];
                        [dictSubItem setObject:strErrorUnit forKey:@"IP_Unit"];
                        [dictSubItem removeObjectForKey:@"IP_unit"];
                    }
                    
                    NSString *strUnit = [dictSubItem objectForKey:@"IP_Unit"];
                    if (![strUnit isEqualToString:[NSString stringWithFormat:@"[*%@_units*]",strName]])
                    {
                        [dictSubItem setValue:[NSString stringWithFormat:@"[*%@_units*]",strName] forKey:@"IP_Unit"];
                    }
                }
            }
        }
    };
        
    int(^FindSameJsonCmdIndex)(NSArray *pAryCom,int index) = ^(NSArray *pAryCom,int index)
    {
        NSString *pszCommand = [pAryCom objectAtIndex:index];
        int count = 0;
        for (int i = 0; i<index; i++) {
            if ([[pAryCom objectAtIndex:i]isEqualToString:pszCommand]) {
                count++;
            }
        }
        return count;
    };
    
    if([arrCom count] == 0
       ||([arrCom count] == 1 && [[arrCom objectAtIndex:0] isEqualToString:@"*"])
       ||([arrCom count] == 1 && [[arrCom objectAtIndex:0] isEqualToString:@""])
       ||!arrCom)
    {
        NSString    *strLogItemKey   = [NSString stringWithFormat:@"%@ = ",strName];
        NSArray     *arrDBSubitems      = [[dicTestAllItems objectForKey:strName]objectForKey:@"*"];
        
        if (arrDBSubitems && [arrDBSubitems count] > 0)
        {
            for (NSMutableDictionary *dictData in arrDBSubitems)
            {
                for (NSString *sKey in [dictData allKeys])
                {
                    if ([sKey isEqualToString:@"JUDGE_SPEC:RETURN_VALUE:"])
                    {
                        NSMutableDictionary *dictSubItem = [dictData objectForKey:sKey];
                        NSMutableDictionary *dictSubSubItem = [dictSubItem objectForKey:@"COMMON_SPEC"];
                        NSString *strSpecValue = [dictSubSubItem objectForKey:@"P_LimitBlack"];
                        if (![strSpecValue isEqualToString:[NSString stringWithFormat:@"[*%@_spec*]",strName]])
                        {
                            [dictSubSubItem setValue:[NSString stringWithFormat:@"[*%@_spec*]",strName] forKey:@"P_LimitBlack"];
                            
                        }
                    }
                    else if ([sKey isEqualToString:@"SET_PROCESS_STATUS:RETURN_VALUE:"])
                    {
                        NSMutableDictionary *dictSubItem = [dictData objectForKey:sKey];
                        
                        if ([[dictSubItem allKeys] containsObject:@"IP_unit"])
                        {
                            NSString *strErrorUnit = [dictSubItem objectForKey:@"IP_unit"];
                            [dictSubItem setObject:strErrorUnit forKey:@"IP_Unit"];
                            [dictSubItem removeObjectForKey:@"IP_unit"];
                        }
                        
                        NSString *strUnit = [dictSubItem objectForKey:@"IP_Unit"];
                        if (![strUnit isEqualToString:[NSString stringWithFormat:@"[*%@_units*]",strName]])
                        {
                            [dictSubItem setValue:[NSString stringWithFormat:@"[*%@_units*]",strName] forKey:@"IP_Unit"];
                        }
                    }
                }
            }
            [arrNewSubItems addObjectsFromArray:arrDBSubitems];
            [self WriteString:[NSString stringWithFormat:@"^_^ PASS >>>>>_%@\n",strLogItemKey] FilePath:strFilePath];
        }
        else
        {
            [self WriteString:[NSString stringWithFormat:@"T_T FAIL >>>>>_%@\n",strLogItemKey] FilePath:strFilePath];
            return nil;
        }
    }
    //Item commands not nill
    else
    {
        for (int i = 0; i < [arrCom count]; i++)
        {
            NSString    *strJsonCommand         = [arrCom objectAtIndex:i];
            NSString    *strLogItemKey   = [NSString stringWithFormat:@"%@ = %@",strName,strJsonCommand];
            NSArray     *arrDBSubitems      = [[dicTestAllItems objectForKey:strName]objectForKey:strJsonCommand];
            
            int index = FindSameJsonCmdIndex(arrCom,i);
            if (index!=0 &&
                [[dicTestAllItems objectForKey:strName]objectForKey:[NSString stringWithFormat:@"%d_%@",index,strJsonCommand]])
            {
                NSString *strIndexCommand = [NSString stringWithFormat:@"%d_%@",index,strJsonCommand];
                strLogItemKey   = [NSMutableString stringWithFormat:@"%@ = %@",strName,strIndexCommand];
                arrDBSubitems      = [[dicTestAllItems objectForKey:strName]objectForKey:strIndexCommand];
            }
            
            if (arrDBSubitems && [arrDBSubitems count] > 0)
            {
                FindJsonCmdAndReplace((NSMutableArray *)arrDBSubitems,strJsonCommand);
                [arrNewSubItems addObjectsFromArray:arrDBSubitems];
                
                [self WriteString:[NSString stringWithFormat:@"^_^ PASS >>>>>_%@\n",strLogItemKey] FilePath:strFilePath];
            }
            else
            {
                NSString    *strFailMessage = [NSString stringWithFormat:@"^_^ FAIL >>>>>_%@\n",strLogItemKey];
                [self WriteString:strFailMessage FilePath:strFilePath];
                return nil;
            }
        }
    }
    return arrNewSubItems;
}

- (void)WriteString: (NSString*)WriteData FilePath:(NSString *)szFilePath
{
    NSString    *strFilePath    = szFilePath;
    NSString    *strFileData    = [NSString stringWithFormat:@"%@",WriteData];
    
    NSString		*szDirectory	= [strFilePath stringByDeletingLastPathComponent];
    NSFileManager	*fileManager	= [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:szDirectory])
        [fileManager createDirectoryAtPath:szDirectory
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:nil];
    
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
        [dataTemp release];
    }
    [fileHandle closeFile];
}

@end
