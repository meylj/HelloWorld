//
//  AppDelegate.h
//  Dailywork
//
//  Created by Jane6_Chen on 15/8/28.
//  Copyright (c) 2015年 ykj. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    NSDictionary *m_json;
    NSDictionary *m_plist;
    IBOutlet NSTextField *m_filepath;
    IBOutlet NSButton *m_open;
}

-(IBAction)save:(NSButton*)sender;
-(IBAction)open:(NSButton*)sender;
-(IBAction)encrypt:(NSButton*)sender;

@end

