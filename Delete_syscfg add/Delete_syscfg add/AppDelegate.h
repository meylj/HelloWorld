//
//  AppDelegate.h
//  Delete_syscfg add
//
//  Created by wangyu on 13-9-12.
//  Copyright (c) 2013年 wangyu. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <stdio.h>
#import <stdlib.h>
#import <unistd.h>
#import <sys/types.h>
#import <sys/stat.h>
#import <fcntl.h>
#import <termios.h>
#import <errno.h>
@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    IBOutlet NSButton *btConnect;
    //IBOutlet NSButton *btQT0;
    IBOutlet NSComboBox  *cbSerialPort;
    IBOutlet NSTextView *tvSnName;
    IBOutlet NSTextView *tvResult;
    NSMutableString *m_szResultOk;
    NSMutableArray * m_aryTable;
    NSMutableArray *arrSnName2;
    int m_ifd;
    BOOL m_fconnect;
}

@property (assign) IBOutlet NSWindow *window;

-(IBAction)C_QT0:(id)sender;
-(IBAction)C_QT0b:(id)sender;
-(IBAction)C_QT1:(id)sender;
-(IBAction)C_CT:(id)sender;
-(IBAction)C_Prox_Cal:(id)sender;
-(IBAction)J_QT0:(id)sender;
-(IBAction)J_QT0b:(id)sender;
-(IBAction)J_QT1:(id)sender;
-(IBAction)J_CT:(id)sender;
-(IBAction)J_Prox_Cal:(id)sender;
-(IBAction)Delete_Item:(id)sender;
-(IBAction)Choose_port:(id)sender;
-(IBAction)Connect:(id)sender;
-(void)parseScript:(NSString*)szPath;
-(void)Sender1:(NSString *)szBuf DeleteName:(NSString*)Delete;
-(void)Sender:(NSString *)szBuf DeleteName:(NSString*)Delete;
-(int)openPort:(NSString *)szDev;

-(void)prompt:(NSString *) sta_Name;
@end
