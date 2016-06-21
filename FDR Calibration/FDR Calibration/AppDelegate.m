//
//  AppDelegate.m
//  FDR DELETE
//
//  Created by Torres on 13-11-4.
//  Copyright (c) 2013年 Torres. All rights reserved.
//

#import "AppDelegate.h"

NSString *RUNTASKNOTIFICATIONREADAVABILE = @"RUNTASKNOTIFICATIONREADAVABILE";

@implementation AppDelegate
#define currentTime [[NSDate date] descriptionWithCalendarFormat:@"[%Y-%m-%d %H:%M:%S]:" timeZone:nil locale:nil]
#define showOutput [outputPython insertText:currentLog]
#define DeleteType 0
#define SubmitType 1

- (void)isTerminalRunning
{
    // while 3 sec for nil response, return nil. retry enter terminal
    NSDate *date = [NSDate date];
    while ([[NSDate date] timeIntervalSinceDate:date] <3)
    {
        usleep(100000);
        currentLog = [NSString stringWithContentsOfFile:@"/vault/log.txt" encoding:NSUTF8StringEncoding error:nil];
        if (currentLog != nil ||[currentLog isEqualToString:@""])
        {
            termialRunning = YES;
            return;
        }
    }
    // didn't awaked up, reopen
    termialRunning =NO;
    [NSThread detachNewThreadSelector:@selector(writeStringToTerminal:) toTarget:self withObject:stringWriteToTerminal];    
}

- (void)enterPassword
{
    
}
- (void)monityTerminalOutput
{
    // make sure terminal have been awaked
    [self isTerminalRunning];
    
    // check if need enter pass word
    [self enterPassword];

}

- (void)terminalDidFinishLaunching:(NSNotification *)aNotification
{
    finishLaunchTerminal = YES;
    NSLog(@"finish launch terminal");
}

- (void)terminalHideClose:(NSNotification *)aNotification
{
    finishLaunchTerminal = NO;
    NSLog(@"hide or close terminal!");
}

- (void)findTerminalPSN
{
    CFArrayRef windowList = CGWindowListCopyWindowInfo(kCGWindowListOptionAll, kCGNullWindowID);
    for (id window in (__bridge NSArray *)windowList)
    {
        //find the Terminal opened in the sisson.
        if ([[window objectForKey:(NSString *)kCGWindowOwnerName] isEqualToString:@"Terminal"] )
        {
            //set terminal to the frond of screen
            int pid = [[window objectForKey:(NSString *)kCGWindowOwnerPID] intValue];
            GetProcessForPID(pid, &pSN);
            finishLaunchTerminal =YES;
            break;
        }
    }
}

- (void)awakeTerminal
{
    // try open terminal
    [work launchApplication:@"/Applications/Utilities/Terminal.app"];
    sleep(2);
    NSDate *date = [NSDate date];
    while ([[NSDate date] timeIntervalSinceDate:date]<10 || finishLaunchTerminal)
    {
        [self findTerminalPSN];
        break;
    }
}

#if 1
//send with string -> max lenght shoud less than 20
- (void)writeStringToTerminal:(NSString *)keyWords
{
    int pid;
    if (errSecSuccess != GetProcessPID(&pSN, &pid))
    {
        [self awakeTerminal];
    }
    NSString *temp = @"";
    while (keyWords.length>0)
    {
        NSRange rangetemp = {0,20};
        if (keyWords.length >=20) {
            temp = [keyWords substringWithRange:rangetemp];
            keyWords = [keyWords substringFromIndex:20];
        }
        else{
            rangetemp.length = keyWords.length;
            temp = keyWords;
            keyWords = nil;
        }
        UniChar *unicharstring = malloc(temp.length*sizeof(UniChar));
        [temp getCharacters:unicharstring range:rangetemp];
        CGEventRef event = CGEventCreateKeyboardEvent(kCGHIDEventTap, 0, true);
        CGEventKeyboardSetUnicodeString(event, temp.length, unicharstring);
        CGEventPostToPSN(&pSN, event);
        event = CGEventCreateKeyboardEvent(kCGHIDEventTap, 0, false);
        CGEventKeyboardSetUnicodeString(event, temp.length, unicharstring);
        CGEventPostToPSN(&pSN, event);
        usleep(10000);
    }
    //show info in text view.
}
#else
//send with byte
- (void)writeStringToTerminal:(NSString *)keyWords
{
    int pid;
    if (errSecSuccess != GetProcessPID(&pSN, &pid)) {
        [self awakeTerminal];
    }
    NSString *ssf = @"B";
    _USKeyCode temp = &ssf;
    
    CGEventPostToPSN(&pSN, CGEventCreateKeyboardEvent(kCGHIDEventTap, (CGKeyCode)55, true));
    CGEventPostToPSN(&pSN, CGEventCreateKeyboardEvent(kCGHIDEventTap, (CGKeyCode)55, false));
}
#endif

- (void)checkBox_BBsn
{
    if ([checkBox state])
    {
        [bb_sn setEnabled:YES];
        [bb_sn setHidden:NO];
    }
    else
    {
        [bb_sn setEnabled:NO];
        [bb_sn setHidden:YES];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    work = [NSWorkspace sharedWorkspace];
    [[work notificationCenter] addObserver:self selector:@selector(terminalDidFinishLaunching:) name:NSWorkspaceDidLaunchApplicationNotification object:nil];
    [[work notificationCenter] addObserver:self selector:@selector(terminalHideClose:) name:NSWorkspaceDidTerminateApplicationNotification object:nil];
    
    [self findTerminalPSN];
    runType = DeleteType;
    [textShowScript setStringValue:@"Script File:FDR DELETE"];
    currentLog = @"";
    muOutput = [[NSMutableString alloc] initWithFormat:@"%@READY!\n",currentTime];
    currentLog = [NSString stringWithFormat:@"%@READY!\n",currentTime];
    showOutput;
}

-(void)awakeFromNib
{
    
}

-(void)_judgeResponseSubmit:(NSThread *)thread
{
    int i=0;
    while (i<1) {
        if ([[muOutput uppercaseString] rangeOfString:@"PASSWORD"].location != NSNotFound)
        {
            [writeHandle writeData:[@"bbfw#fdr." dataUsingEncoding:NSASCIIStringEncoding]];
            [writeHandle closeFile];
            currentLog = [NSString stringWithFormat:@"%@enter password ok\n",currentTime];
            [muOutput appendString:currentLog];
            showOutput;
            break;
        }
        sleep(1);
        i++;
    }
    sleep(1);
    [muOutput appendString:[NSString stringWithFormat:@"%@Run FDR DUMMY --End\n",currentTime]];
    //    [self _judgeResponse:szString];
    [muOutput appendString:[NSString stringWithFormat:@"%@Successfully dummy calibration data\n",currentTime]];
    //        [_window setBackgroundColor:[NSColor greenColor]];
    [textResult setStringValue:@"PASS"];
    [textResult setBackgroundColor:[NSColor greenColor]];
    showOutput;
}

-(void)_judgeResponse:(NSString *)szOuput
{
    NSRange range = [szOuput rangeOfString:@"Successfully deleted calibration data from FDR"];
    if (range.location != NSNotFound) {
        //success
        [muOutput appendString:[NSString stringWithFormat:@"%@Successfully deleted calibration data from FDR\n",currentTime]];
        //        [_window setBackgroundColor:[NSColor greenColor]];
        [textResult setStringValue:@"PASS"];
        [textResult setBackgroundColor:[NSColor greenColor]];
    }
    else{
        [muOutput appendString:[NSString stringWithFormat:@"%@Unable to delete calibration data from FDR\n",currentTime]];
        //[_window setBackgroundColor:[NSColor redColor]];
        [textResult setStringValue:@"FAIL"];
        [textResult setBackgroundColor:[NSColor redColor]];
    }
    [muOutput appendString:[NSString stringWithFormat:@"%@Run FDR Delete --End\n",currentTime]];
    showOutput;
}

-(NSString *)_findFDRFolder
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //    NSArray *fileList = [fileManager contentsOfDirectoryAtPath:NSHomeDirectory() error:nil];
    NSArray *fileList = [fileManager subpathsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/Desktop",NSHomeDirectory() ] error:nil];
    for (NSString *string in fileList)
    {
        NSRange range = [string rangeOfString:@"FDR/fdr.pyc"];
        if (range.location != NSNotFound)
        {
            return [[NSString stringWithFormat:@"%@/Desktop/%@",NSHomeDirectory(),string] stringByReplacingOccurrencesOfString:@" " withString:@"'\' "];
        }
    }
    return [NSString stringWithFormat:@"%@/Desktop/FDR/fdr.pyc",NSHomeDirectory()];
}

- (void)_runDFRSubmit
{
    [muOutput appendString:[NSString stringWithFormat:@"%@Run FDR DUMMY --Begin\n",currentTime]];
    showOutput;
    NSString *szPythonPath = @"/usr/bin/python";
    NSString *szToolPath = [self _findFDRFolder];
    NSTask *task = [[NSTask alloc] init];
    
    NSPipe *outPipe = [NSPipe pipe];
    NSFileHandle *readHandle = [outPipe fileHandleForReading];
    
    NSPipe *inPipe = [NSPipe pipe];
    writeHandle = [inPipe fileHandleForWriting];
    
    NSPipe *errorPipe = [NSPipe pipe];
    NSFileHandle *errorhandle = [errorPipe fileHandleForReading];
    
    [task setLaunchPath:szPythonPath];
    
    NSArray *args = [NSArray array];
    if ([checkBox state]) {
        NSString *bbsn = [bb_sn stringValue];
        if (bbsn ==nil || [bbsn isEqualToString:@""]) {
            args = [NSArray arrayWithObjects:szToolPath,@"submit",nil];
        }
        else
            args = [NSArray arrayWithObjects:szToolPath,@"submit",bbsn,nil];
    }
    else
    {
        args = [NSArray arrayWithObjects:szToolPath,@"submit",nil];
    }
    [task setArguments:args];
    [muOutput appendString:[NSString stringWithString:[args description]]];
    showOutput;
    [task setStandardOutput:outPipe];
    [task setStandardError:errorPipe];
    
    [task launch];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(_readbackgroundNotiSubmit:) name:NSFileHandleReadCompletionNotification object:readHandle];
    [nc addObserver:self selector:@selector(_readbackgroundNoti2:) name:NSFileHandleReadCompletionNotification object:errorhandle];
    [readHandle readInBackgroundAndNotify];
    [errorhandle readInBackgroundAndNotify];
    
    sleep(1);
    [NSThread detachNewThreadSelector:@selector(_judgeResponseSubmit:) toTarget:self withObject:nil];
    showOutput;
}

- (void)_runFDRDelete
{
    currentLog = [NSString stringWithFormat:@"%@Run FDR Delete --Begin\n",currentTime];
    [muOutput appendString:currentLog];
    showOutput;
    
    NSString *fdrFile = [self _findFDRFolder];
    stringWriteToTerminal = @"";
    if ([checkBox state]) {
        NSString *bbsn = [bb_sn stringValue];
        if (bbsn ==nil || [bbsn isEqualToString:@""]) {
            NSRunAlertPanel(@"Warning", @"please scan bbSN in the SN lable and run again! or turn off the bbSN.", @"OK", nil, nil);
        }
        else
        {
            stringWriteToTerminal = [NSString stringWithFormat:@"python %@ delete %@ |tee /vault/log.txt\n",fdrFile,bbsn];
        }
    }
    else
    {
        stringWriteToTerminal = [NSString stringWithFormat:@"python %@ delete |tee /vault/log.txt\n",fdrFile];
    }
    currentLog = [NSString stringWithFormat:@"%@type:%@",currentTime,stringWriteToTerminal];
    [muOutput appendString:currentLog];
    showOutput;
    [NSThread detachNewThreadSelector:@selector(writeStringToTerminal:) toTarget:self withObject:stringWriteToTerminal];
}

- (IBAction)buttonStart:(id)sender
{
    if (runType == SubmitType) {
        [self _runDFRSubmit];
    }
    else if (runType == DeleteType)
    {
        NSInteger panelreault = NSRunAlertPanel(@"Warning!", @"This active will run FDR delete script,please make sure!", @"OK", @"Cancel", nil);
        if (panelreault == NSAlertDefaultReturn) {
            [self _runFDRDelete];
        }
    }
    else
    {
        //
    }
    [muOutput setString:@""];
}


//- (IBAction)choosetype:(id)sender
//{
//    [NSApp beginSheet:scrWindow modalForWindow:Window modalDelegate:self didEndSelector:nil contextInfo:nil];
//}
- (IBAction)submitBTN:(id)sender
{
    runType = SubmitType;
    [textShowScript setStringValue:@"Script File:FDR DUMMY"];
    [scrWindow orderOut:nil];
    [Window setTitle:@"FDR DUMMY"];
    [deleteScript setState:NO];
    [submitScript setState:YES];
    [NSApp endSheet:scrWindow];
}
- (IBAction)deleteBTN:(id)sender
{
    runType = DeleteType;
    [textShowScript setStringValue:@"Script File:FDR DELETE"];
    [scrWindow orderOut:nil];
    [Window setTitle:@"FDR DELETE"];
    [deleteScript setState:YES];
    [submitScript setState:NO];
    [NSApp endSheet:scrWindow];
}

- (IBAction)checkBox:(id)sender
{
    [self checkBox_BBsn];
}



- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
    
}

@end
