//
//  NewTestallFormat.m
//  ToolForModifyTestallFile
//
//  Created by Linda8_Yang on 9/23/16.
//  Copyright © 2016 Linda8_Yang. All rights reserved.
//

#import "NewTestallFormat.h"

@implementation NewTestallFormat

-(id)init
{
    if (self = [super init])
    {
        _dicTestallFile = [[NSMutableDictionary alloc]init];
        objPlistScript = [[ToGetPlistScript alloc]init];

    }
    return self;
}

-(void)dealloc
{
    [_dicTestallFile release];
    [objPlistScript release];
    [super dealloc];
}

-(BOOL)creatNewTestallFileWithNewFormat:(NSString *)strOldTestallPath withJsonPath:(NSString *)strJsonPath
{
    [objPlistScript ParseAndCombineJson:strJsonPath withLiveTestAll:strOldTestallPath];
    [_dicTestallFile setObject:objPlistScript.arrNewItems forKey:@"Main_TestItems"];
    
    NSDictionary *dicTestAll =[NSDictionary dictionaryWithContentsOfFile:strOldTestallPath];
    NSString *JsonVersion =[dicTestAll objectForKey:@"JSON Version"];
    NSString *testallVersion = [dicTestAll objectForKey:@"Testall Version"];
    [_dicTestallFile setObject:JsonVersion forKey:@"JSON Version"];
    [_dicTestallFile setObject:testallVersion forKey:@"Testall Version"];
    [_dicTestallFile setObject:[self getItemsControlItems:strOldTestallPath] forKey:@"ITEMSCONTROL"];
    [_dicTestallFile setObject:[self getSubItems] forKey:@"SUBITEMS"];
    
    NSString    *szFilePath = [NSString stringWithFormat:@"%@/Desktop/%@",NSHomeDirectory(),[strOldTestallPath lastPathComponent]];
    
    if([_dicTestallFile writeToFile:szFilePath atomically:YES])
    {
        NSLog(@"Creat new testall file successfully!");
        return YES;
    }
    else
    {
        NSLog(@"Creat new testall file failed!");
        return NO;
    }
}

- (NSMutableArray *)getItemsControlItems:(NSString *)strOldTestallPath
{
    NSDictionary    *dicTestAllItemsControl    = [[NSDictionary dictionaryWithContentsOfFile:strOldTestallPath]objectForKey:@"ITEMSCONTROL"];
    
    NSArray *arrAllKeysInSubControlDictionary = [dicTestAllItemsControl allKeys];
    NSString *controlKey;
    NSMutableArray *controlItems;
    NSMutableArray *subControlItems = [NSMutableArray array];
    
    for (int i= 0; i < [arrAllKeysInSubControlDictionary count]; i++)
    {
        controlKey = [arrAllKeysInSubControlDictionary objectAtIndex:i];
        controlItems = [dicTestAllItemsControl objectForKey:controlKey];
        [controlItems removeObject:controlKey];
        for (int j=0; j<[controlItems count]; j++)
        {
            [subControlItems addObject:[controlItems objectAtIndex:j]];
        }
    }
    return subControlItems;
}

- (NSMutableDictionary *)getSubItems
{
    NSMutableDictionary *dicObjMainItem;
    NSMutableDictionary *dicObjSubItem;
    NSMutableArray *arrSubItems;
    NSArray *arrSubSubItems;
    NSMutableDictionary *dicFinalSubItems = [NSMutableDictionary dictionary];
    
    NSString *strObjSubItem;
    NSString *strMainItem;
    
    for (int i = 0; i < [objPlistScript.arrNewItems count]; i++)
    {
        dicObjMainItem = [objPlistScript.arrNewItems objectAtIndex:i];
        strMainItem = [[dicObjMainItem allKeys] objectAtIndex:0];
        arrSubItems = [dicObjMainItem objectForKey:strMainItem];
        
        for (int j = 0; j<[arrSubItems count]; j++)
        {
            dicObjSubItem = [arrSubItems objectAtIndex:j];
            if ([[dicObjSubItem objectForKey:[[dicObjSubItem allKeys] objectAtIndex:0]] count] != 0)
            {
                dicObjSubItem = [dicObjSubItem objectForKey:[[dicObjSubItem allKeys] objectAtIndex:0]];
                
                NSLog(@"dicObjSubItem = %@",dicObjSubItem);

                if ([[dicObjSubItem objectForKey:[[dicObjSubItem allKeys] objectAtIndex:0]] isKindOfClass:[NSArray class]])
                {
                    strObjSubItem = [[dicObjSubItem allKeys] objectAtIndex:0];
                    if([strObjSubItem isEqualToString:@"SubItems"])
                    {
                        arrSubSubItems = [dicObjSubItem objectForKey:strObjSubItem];
                        [dicFinalSubItems setObject:arrSubSubItems forKey:strMainItem];
                    }
                    NSLog(@"obj mainitem= %@,subitem = %@",strMainItem,dicObjSubItem);
                    NSLog(@"j = %d",j);
                }
            }
            NSLog(@"i = %d",i);
        
        }
    }
    return dicFinalSubItems;

}
    
@end
