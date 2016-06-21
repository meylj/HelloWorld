//
//  LogManager.m
//  AE-Cake
//
//  Created by Joker on 2/4/15.
//  Copyright (c) 2015 Yaya. All rights reserved.
//

#import "LogManager.h"

NSString	* const logLock              = @"logLock";

#define LOG_PATH @"/vault/CakeLog.log"

@implementation LogManager

+ (void)writeLog:(NSString*)message
{
    @synchronized(logLock)
    {
        NSLog(@"%@",message);
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *strDate = [[NSDate date] descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M:%S.%F" timeZone:nil locale:nil];
        if (![fileManager fileExistsAtPath:LOG_PATH])
        {
            if (![fileManager createFileAtPath:LOG_PATH contents:nil attributes:nil])
            {
                NSLog(@"Can not create log file");
                return;
            }
        }
        NSFileHandle *filehandle = [NSFileHandle fileHandleForWritingAtPath:LOG_PATH];
        NSString *strInfo = [NSString stringWithFormat:@"[%@]:%@\r\n",strDate,message];
        
        if (nil == filehandle)
        {
            NSLog(@"can't get filehandle of file %@",LOG_PATH);
            return;
        }
        @try {
            NSData *data = [NSData dataWithBytes:[strInfo UTF8String] length:[strInfo length]];
            if (!data)
            {
                NSLog(@"szInfo is not a UTF8String");
                return;
            }
            [filehandle synchronizeFile];
            [filehandle seekToEndOfFile];
            [filehandle writeData:data];
            [filehandle closeFile];
        }
        @catch (NSException *exception) {
            NSLog(@"write log exception name :%@, description:%@",exception.name,exception.description);
            return;
        }
        @finally
        {
        }
    }
}

@end
