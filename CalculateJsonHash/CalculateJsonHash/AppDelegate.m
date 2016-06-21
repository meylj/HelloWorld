//
//  AppDelegate.m
//  CalculateJsonHash
//
//  Created by York_Xu on 6/29/15.
//  Copyright (c) 2015 York_Xu. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (id)init
{
    if(self = [super init])
    {
        m_strJsonFullPath       = [[NSMutableString alloc] init];
        m_strNewCheckSum        = [[NSMutableString alloc] init];
    }
    return self;
}


- (NSDictionary*)JsonParse:(NSURL*)FilePath
{
    NSString        *strJsonData    = [[NSString alloc] initWithContentsOfURL:FilePath
                                                                     encoding:NSUTF8StringEncoding
                                                                        error:nil];
    NSData          *dtJsonData     = [strJsonData dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary    *dicJsonData    = [NSJSONSerialization JSONObjectWithData:dtJsonData
                                                                      options:NSJSONReadingMutableLeaves
                                                                        error:nil];
    return dicJsonData;
}


-(IBAction)ChooseJsonFilePlace:(id)sender

{
    //Set the "OK" button is able
    [m_btnChooseJsonFilePlace setEnabled:YES];
    
    NSOpenPanel	*openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:YES];		//Can choose file
    [openPanel setCanChooseDirectories:NO];	//Can't choose directories
    [openPanel setAllowsMultipleSelection:YES];	//Only can choose one file at one time
    [openPanel setAllowedFileTypes:[NSArray arrayWithObject:@"Json"]];//set the file types choosed
    //Get the file's URL
    [openPanel beginSheetModalForWindow:_window completionHandler:^(NSInteger result)
     {
         // if press button is equal to OK button , then do something
         if(result == NSFileHandlingPanelOKButton)
         {
             [m_txtCheckSum setStringValue:@""];
//多选
//             NSURL *urlAllJsonPath = [openPanel URLs];
             for(NSURL *url in  [openPanel URLs])
             {
                 NSURL *urlJsonPath = url;
                 urlString  = [url path];
//                 [m_strJsonFullPath setString:urlString];
                 m_strJsonFullPath = [NSMutableString stringWithFormat:@"%@",urlString];
                 [m_txtJsonFilePath setStringValue:urlString];
                 m_dicJsonData = [[NSMutableDictionary alloc]initWithDictionary:[self JsonParse:urlJsonPath]];
             }
         }
     }];
    
}

-(void)CreatNewJsonPath
{
    [m_dicJsonData removeObjectForKey:@"hash"];
    if ([NSJSONSerialization isValidJSONObject:m_dicJsonData])
    {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:m_dicJsonData options:NSJSONWritingPrettyPrinted error:&error];
        //        NSString *json =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        //        NSLog(@"%@",json);
//CreatNewJsonFile
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:m_strJsonFullPath])
        {
            [fileManager createFileAtPath:m_strJsonFullPath contents:jsonData attributes:nil];
        }
        else
        {
            [fileManager removeItemAtPath:m_strJsonFullPath error:nil];
            [fileManager createFileAtPath:m_strJsonFullPath contents:jsonData attributes:nil];
        }
    }

}
- (NSString *)CalculateCheckSum:(NSString *)szFilePath
{
    NSString	*szCalSum	= @"";
    NSTask		*task		=[[NSTask alloc] init];
    NSPipe		*Pipe		=[NSPipe pipe];
    NSArray		*args		= @[@"sha1",szFilePath];
    [task setLaunchPath:@"/usr/bin/openssl"];
    [task setArguments:args];
    [task setStandardOutput:Pipe];
    [task launch];
    NSData		*outData	= [[Pipe fileHandleForReading] readDataToEndOfFile];
    [task waitUntilExit];
    int			iRetCode	= [task terminationStatus];
//    [task release];
    if(iRetCode == 0)
    {
        NSString	*strCheckSumValue	= [[NSString alloc] initWithData:outData
                                                           encoding:NSUTF8StringEncoding];
        szCalSum = [strCheckSumValue subByRegex:@".*= (.{40})$" name:nil error:nil];
//        [strCheckSumValue release];
    }
    else
        NSLog(@"Calculate plist file:[%@] failCheckSum iRetCode vaule:[%d]",szFilePath,iRetCode);
    return szCalSum;
}

-(BOOL)AddBackHashKey
{
//    NSDictionary *dicNewHash = [NSDictionary dictionaryWithObjects:[self CalculateCheckSum:urlString] forKeys:@"hash"];
    [m_dicJsonData setObject:m_strNewCheckSum forKey:@"hash"];
    if ([NSJSONSerialization isValidJSONObject:m_dicJsonData])
    {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:m_dicJsonData options:NSJSONWritingPrettyPrinted error:&error];
        //        NSString *json =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        //        NSLog(@"%@",json);
        //CreatNewJsonFile
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:m_strJsonFullPath])
        {
            [fileManager createFileAtPath:m_strJsonFullPath contents:jsonData attributes:nil];
        }
        else
        {
            [fileManager removeItemAtPath:m_strJsonFullPath error:nil];
            [fileManager createFileAtPath:m_strJsonFullPath contents:jsonData attributes:nil];
        }
        [m_txtCheckSum setStringValue:m_strNewCheckSum];
        return YES;
    }
    return NO;
    
}


-(void)CalculateCheckSum
{
    if ([m_strJsonFullPath length] > 0) {
//        [m_txtCheckSum setStringValue:[self CalculateCheckSum:m_strJsonFullPath]];
//        [m_strNewCheckSum setString:[m_txtCheckSum stringValue]];
        
        [m_strNewCheckSum setString:[self CalculateCheckSum:m_strJsonFullPath]];
//        [[NSFileManager defaultManager] removeItemAtPath:strFinalFolder error:nil];
    }
    else
    {
        NSLog(@"Calculate CheckSum fail");
    }
}

-(IBAction)Start:(id)sender
{
    [self CreatNewJsonPath];
    [self CalculateCheckSum];
    [self AddBackHashKey];
}
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}



@end
