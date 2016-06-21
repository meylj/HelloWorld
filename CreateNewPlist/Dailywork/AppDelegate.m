//
//  AppDelegate.m
//  Dailywork
//
//  Created by Jane6_Chen on 15/8/28.
//  Copyright (c) 2015年 ykj. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

-(IBAction)save:(NSButton*)sender
{
    NSMutableArray *m_ary = [[NSMutableArray alloc]init];
    NSDictionary *level1 = [m_json objectForKey:@"data"];
    NSArray *level2 = [level1 objectForKey:@"tests"];
    //NSLog(@"%@",level2);
    for(NSDictionary *level3 in level2)
    {
        NSEnumerator *m_enum = [[level3 allKeys]objectEnumerator];
        NSString *str = [m_enum nextObject];
        NSDictionary *level4 = [level3 objectForKey:str];
        NSString *item = [[level4 objectForKey:@"Name"]objectForKey:@"main"];
        NSString *command;
        NSLog(@"%@",item);
        if ([[level4 objectForKey:@"Commands"] count]!=0) {
            if([[[level4 objectForKey:@"Commands"]objectAtIndex:0]isKindOfClass:[NSArray class]])
            {
                for (int i=0; i<[[level4 objectForKey:@"Commands"] count]; i++) {
                    command = [[[level4 objectForKey:@"Commands"] objectAtIndex:i]objectAtIndex:0];
                    NSMutableString *m_key;
                    m_key = [[NSMutableString alloc]initWithString:item];
                    [m_key appendFormat:@" = %@",command];
                    //NSLog(@"%@",m_key);
                    if (m_key!=nil)
                    {
                        NSDictionary *m_newplist = [NSDictionary dictionaryWithObjectsAndKeys:[m_plist objectForKey:m_key],item, nil];
                        //NSLog(@"%@",m_newplist);
                        [m_ary addObject:m_newplist];
                    }
                }
            }
            else
            {
                for (int i=0; i<[[level4 objectForKey:@"Commands"] count]; i++) {
                    command = [[level4 objectForKey:@"Commands"] objectAtIndex:i];
                    NSMutableString *m_key;
                    m_key = [[NSMutableString alloc]initWithString:item];
                    [m_key appendFormat:@" = %@",command];
                    //NSLog(@"%@",m_key);
                    if (m_key!=nil)
                    {
                        NSDictionary *m_newplist = [NSDictionary dictionaryWithObjectsAndKeys:[m_plist objectForKey:m_key],item, nil];
                        //NSLog(@"%@",m_newplist);
                        [m_ary addObject:m_newplist];
                    }
                }
            }
        }
//        else
//        {
//            NSMutableString *m_key;
//            m_key = [[NSMutableString alloc]initWithString:item];
//            [m_key appendFormat:@" = "];
//            if (m_key!=nil)
//            {
//                NSDictionary *m_newplist = [NSDictionary dictionaryWithObjectsAndKeys:[m_plist objectForKey:m_key],item, nil];
//                //NSLog(@"%@",m_newplist);
//                [m_ary addObject:m_newplist];
//            }
//        }
    }
    NSSavePanel *s_panel = [NSSavePanel savePanel];
    [s_panel setMessage:@"Please choose a path to save the document"];
    [s_panel setAllowsOtherFileTypes:YES];
    [s_panel setAllowedFileTypes:@[@"plist"]];
    [s_panel setExtensionHidden:NO];
    [s_panel setCanCreateDirectories:YES];
    if ([s_panel runModal] == NSFileHandlingPanelOKButton)
    {
        NSString *path = [[s_panel URL] path];
        [m_ary writeToFile:path atomically:YES];
   }
}

-(IBAction)open:(NSButton*)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:YES];
    [panel setAllowedFileTypes:@[@"plist",@"json"]];
    [panel setAllowsOtherFileTypes:YES];
    if ([panel runModal] == NSFileHandlingPanelOKButton)
    {
        NSString *path = [panel.URLs.firstObject path];
        if ([path containsString:@"json"]) {
            NSData *json = [[NSData alloc]initWithContentsOfFile:path];
            m_json = [NSJSONSerialization JSONObjectWithData:json options:kNilOptions error:nil];
            [m_open setTitle:@"json opened"];
        }
        if ([path containsString:@"plist"]) {
            m_plist = [[NSDictionary alloc]initWithContentsOfFile:path];
            [m_open setTitle:@"plist opened"];
        }
    }
}

-(IBAction)encrypt:(NSButton*)sender
{
    NSMutableArray *m_command = [[NSMutableArray alloc]initWithObjects:@"sha1", nil];
    NSString *filepath = [m_filepath stringValue];
    [m_command addObject:filepath];
    NSTask *task = [[NSTask alloc]init];
    [task setArguments:m_command];
    NSPipe *opipe = [NSPipe pipe];
    [task setLaunchPath:@"/bin/openssl"];
    [task setStandardOutput:opipe];
    [task launch];
    NSData *dataresponse = [[opipe fileHandleForReading]readDataToEndOfFile];
    NSString *str = [[NSString alloc]initWithData:dataresponse encoding:NSUTF8StringEncoding];
    NSLog(@"%@",str);
    [m_filepath setStringValue:str];
    [task waitUntilExit];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
