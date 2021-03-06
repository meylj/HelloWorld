//
//  AppDelegate.m
//  TestRegex
//
//  Created by Yaya8_liu on 12-10-11.
//  Copyright (c) 2012年 Yaya8_liu. All rights reserved.
//

#import "AppDelegate.h"
#include <CommonCrypto/CommonDigest.h>


@implementation AppDelegate
@synthesize window;

-(id)init
{
    self = [super init];
    if (self)
    {
        m_dicChoose = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)dealloc
{
    [m_dicChoose release];m_dicChoose = nil;
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [window setTitle:@"CalculateJsonHash"];
}

-(void)chooseFile:(NSButton *)sender
{
    NSOpenPanel *openPanel  = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:YES];		//Can choose file
    [openPanel setCanChooseDirectories:NO];	//Can't choose directories
    [openPanel setAllowsMultipleSelection:NO];	//Only can choose one file at one time
    // [openPanel setAllowedFileTypes:[NSArray arrayWithObjects:@"json",nil]];//set the file types that can be choosed
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"NSNavLastRootDirectory"] isEqualToString:@"~/Desktop"])
        [openPanel setDirectoryURL:[NSURL URLWithString:@"~/"]];
    [openPanel beginSheetModalForWindow:window completionHandler:^(NSInteger result)
     {
         // if press OK button, do something
         if(result == NSFileHandlingPanelOKButton)
         {
             for(NSURL *url in  [openPanel URLs])
             {
                 NSString *urlString = [url path];
                 [textFilePath setStringValue:urlString];
                 [textHashValue setStringValue:@""];
             }
         }
     }];
}

- (IBAction)start:(NSButton *)sender
{
    if([[textFilePath stringValue]isEqualToString:@""])
    {
        return;
    }
    [m_dicChoose removeAllObjects];
    NSString        *strJsonData    = [[NSString alloc] initWithContentsOfFile:[textFilePath stringValue]
                                                                      encoding:NSUTF8StringEncoding
                                                                         error:nil];
    NSData          *dtJsonData     = [strJsonData dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary    *dicJsonData    = [NSJSONSerialization JSONObjectWithData:dtJsonData
                                                                             options:NSJSONReadingMutableLeaves
                                                                               error:nil];
    if ([checkData state] == 1 && [dicJsonData objectForKey:@"data"]!=nil) {
        [m_dicChoose setObject:[dicJsonData objectForKey:@"data"] forKey:@"data"];
    }
    if ([checkBuild state] == 1 && [dicJsonData objectForKey:@"build"]!=nil) {
        [m_dicChoose setObject:[dicJsonData objectForKey:@"build"] forKey:@"build"];
    }
    if ([checkVersion state] == 1 && [dicJsonData objectForKey:@"Versions"]!=nil) {
        [m_dicChoose setObject:[dicJsonData objectForKey:@"Versions"] forKey:@"Versions"];
    }
    if ([checkHash state] == 1 && [dicJsonData objectForKey:@"hash"]!=nil) {
        [m_dicChoose setObject:[dicJsonData objectForKey:@"hash"] forKey:@"hash"];
    }
    NSString *strSHA1 = @"";
    if([checkAllFile state])
    {
        NSData *dataOfFile = [[NSData alloc]initWithContentsOfFile:[textFilePath stringValue]];
        strSHA1 = [self sha1WithData:dataOfFile];
        [dataOfFile release];
    }
    else
    {
        if([[m_dicChoose allKeys]count]!=0)
        {
            NSData *dataResult = [NSJSONSerialization dataWithJSONObject:m_dicChoose options:NSJSONWritingPrettyPrinted error:nil];
            strSHA1 = [self sha1WithData:dataResult];
        }
    }
    
    [textHashValue setStringValue:strSHA1];
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    [pb declareTypes:@[NSStringPboardType] owner:self];
    [pb setString:strSHA1 forType:NSStringPboardType];
    [strJsonData release];
}

- (IBAction)checkAllFileSum:(NSButton *)sender
{
    if([checkAllFile state])
    {
        [checkBuild setState:0];
        [checkData setState:0];
        [checkHash setState:0];
        [checkVersion setState:0];
    }
    else
    {
        [checkBuild setState:1];
        [checkData setState:1];
        [checkHash setState:0];
        [checkVersion setState:1];
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    [NSApp terminate:self];
}

- (NSString *)sha1WithString:(NSString*) strHashString
{
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    NSData *hashData = [strHashString dataUsingEncoding:NSUTF8StringEncoding];
    CC_SHA1([hashData bytes], (CC_LONG)[hashData length], digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02X", digest[i]];
    NSString *strOutPut = [NSString stringWithString:output];
    return strOutPut;
}

- (NSString *)sha1WithData:(NSData*) hashData
{
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1([hashData bytes], (CC_LONG)[hashData length], digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH*2];
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02X", digest[i]];
    NSString *strOutPut = [NSString stringWithString:output];
    return strOutPut;
}

@end
