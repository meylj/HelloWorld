//
//  IALogs.h
//  FunnyZone
//
//  Created by Lorky on 4/13/11.
//  Copyright 2011 PEGATRON. All rights reserved.
//



#import <Foundation/Foundation.h>
@interface IALogs : NSObject

+ (void)CreatAndWriteUARTLog:(NSString *)szInfo
					  atTime:(NSString *)szTime
				  fromDevice:(NSString *)szDevice
					withPath:(NSString *)szPath
					  binary:(BOOL)bBinarySave;
+ (void)CreatAndWriteSingleCSVLog:(NSString *)szInfo
						 withPath:(NSString *)szPath;
+ (void)CreatAndWriteConsoleInformation:(NSString *)szInfo
							   withPath:(NSString *)szPath;
+ (void)CreatAndWriteSummaryLog:(NSString *)szInfo
				 paraDictionary:(NSDictionary*)dicParams
					   withPath:(NSString *)szPath;

@end




