//
//  FTAppDelegate+ParsingLog.h
//  FakeTarget
//
//  Created by raniys on 4/4/14.
//  Copyright (c) 2014 raniys. All rights reserved.
//

#import "FTAppDelegate.h"

@interface FTAppDelegate (ParsingLog)

//get all data from log
-(NSNumber*)getDataFromLogPath: (NSString *)logPath
                   returnValue: (NSMutableString *)szReturnValue;
//get command and result by target(Mobile/fixture/mikey)
-(NSNumber*)getDataByTargetFromLog:(NSString *)logData
                       returnValue:(NSMutableString *)szReturnValue;
//deal with log to get command and result
-(NSNumber *)dealWithString:(NSString *)strString
                   byTarget:(NSString *)strTarget
              readCommandTo:(NSString *)strEnd
                  ifInclude:(BOOL)bInclude;

@end
