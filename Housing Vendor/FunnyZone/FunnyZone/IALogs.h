//
//  IALogs.h
//  FunnyZone
//
//  Created by Lorky on 4/13/11.
//  Copyright 2011 PEGATRON. All rights reserved.
//

#import <Foundation/Foundation.h>

#define macro_W_Uart 1
#define macro_W_Console 1
#define macro_W_Summary 1

@interface IALogs : NSObject {
@private
    
}

+ (void)CreatAndWriteUARTLog:(NSString *)szInfo atTime:(NSString *)szTime fromDevice:(NSString *)szDevice withPath:(NSString *)szPath binary:(BOOL)bBinarySave;
+ (void)CreatAndWriteSingleCSVLog:(NSString *)szInfo withPath:(NSString *)szPath;
+ (void)CreatAndWriteConsoleInformation:(NSString *)szInfo withPath:(NSString *)szPath;
+ (void)CreatAndWriteSummaryLog:(NSString *)szInfo paraDictionary:(NSDictionary*)dicParams withPath:(NSString *)szPath;
@end
