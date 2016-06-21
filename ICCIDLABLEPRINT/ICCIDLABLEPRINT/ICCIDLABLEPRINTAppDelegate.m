//
//  ICCIDLABLEPRINTAppDelegate.m
//  ICCIDLABLEPRINT

//  Created by User on 12-8-30.

//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ICCIDLABLEPRINTAppDelegate.h"
#define ISN     @"SerialNumber"
#define ICCID   @"IntegratedCircuitCardIdentity"
#define iccid   @"iccid"
#define kPrintNotification  @"PRINTTERREADYTOGO"


@implementation ICCIDLABLEPRINTAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [txtRspInfo setFont:[NSFont fontWithName:@"Helvetica-BoldOblique" size:40]];
    [txtRspInfo setStringValue:@"Ready..."];
    [txtInputStr setAction:@selector(CmpISN)];
    [window setBackgroundColor:NULL];
    NSNotificationCenter    *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self 
           selector:@selector(PrintInfo:) 
               name:kPrintNotification 
             object:nil];
//    controlPrint *objControl = [[controlPrint alloc] init];
//    [objControl print:@"C8TJC001C0C0"];
}

- (BOOL)CmpISN
{
    BOOL    bRet;
    NSString    *szSnfromUnit = [self getInfoWithKey:ISN];
    NSString    *szSnInput  = [txtInputStr stringValue];
    [window setBackgroundColor:NULL];
    if([szSnInput isEqualToString:szSnfromUnit])
    {
        bRet = YES;
        [txtRspInfo setFont:[NSFont fontWithName:@"Helvetica-BoldOblique" size:20]];
        [txtRspInfo setTextColor:[NSColor greenColor]];
        [txtRspInfo setStringValue:@"SN Match(SN 相符)"];
    }
    else
    {
        bRet = NO;
        [txtRspInfo setFont:[NSFont fontWithName:@"Helvetica-BoldOblique" size:20]];
        [txtRspInfo setTextColor:[NSColor redColor]];
        [txtRspInfo setStringValue:[NSString stringWithFormat:@"SN Not Match(SN 不符)\n机台SN:%@\n刷人SN:%@",szSnfromUnit,szSnInput]];
    }
    return (bRet==NO?bRet:(bRet=[self CmpICCID]));
}

- (BOOL)CmpICCID
{
    BOOL    bRet;
    NSString    *szICCIDfromUnit = [self getInfoWithKey:ICCID];
    NSString    *szICCIDfromSIFS = [SFIS_Query getKeyValue:iccid withSN:[txtInputStr stringValue]];
    if ([szICCIDfromSIFS isEqualToString:szICCIDfromUnit])
    {
        bRet = YES;
        [window setBackgroundColor:[NSColor greenColor]];
        [txtRspInfo setStringValue:@"ICCID Match(ICCID 相符)"];
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        NSString    *strTobePrint = [NSString   stringWithFormat:@"ICCID: %@",szICCIDfromUnit];
        NSDictionary    *dicTemp = [NSDictionary dictionaryWithObjectsAndKeys:strTobePrint,@"Message", nil];
        [nc postNotificationName:kPrintNotification 
                          object:self 
                        userInfo:dicTemp];
    }
    else
    {
        bRet = NO;
        [window setBackgroundColor:[NSColor redColor]];
        [txtRspInfo setFont:[NSFont fontWithName:@"Helvetica-BoldOblique" size:15]];
        [txtRspInfo setTextColor:[NSColor blackColor]];
        [txtRspInfo setStringValue:[NSString stringWithFormat:@"ICCID Not Match(ICCID 不符)\n机台ICCID:   %@\nSIFS_ICCID:%@",szICCIDfromUnit,szICCIDfromSIFS]];
    }
    return bRet;
}

- (NSString *)getInfoWithKey :(NSString     *)key
{
    NSTask *task = [[NSTask alloc]  init];
	NSPipe *pipeError = [[NSPipe alloc] init];
    NSArray * aryArgument = [NSArray arrayWithObjects:@"get",@"NULL",key, nil];
	NSFileHandle *h_handle = [pipeError fileHandleForReading];
	[task setStandardError:pipeError];
	[task setLaunchPath:@"/usr/bin/mobdev"];
	[task setArguments:aryArgument];
	[task launch];
	NSData *data = [h_handle readDataToEndOfFile];
	[task waitUntilExit];
	[task release];
	NSString * strData = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
    NSString    *szRet = [NSString stringWithFormat:@"%@",strData];
    [strData release];
	return [szRet stringByReplacingOccurrencesOfString:@"\n" withString:@""];
}


- (void)PrintInfo: (NSNotification  *)noti
{
    NSDictionary    *dictemp = [noti userInfo];
    controlPrint *objControl = [[controlPrint alloc] init];
    NSString *szMsgToPrint = [dictemp objectForKey:@"Message"];
    [objControl print:szMsgToPrint];
    [objControl release];
}

@end
