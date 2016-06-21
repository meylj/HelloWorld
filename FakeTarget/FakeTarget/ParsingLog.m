//
//  FTAppDelegate+ParsingLog.m
//  FakeTarget
//
//  Created by raniys on 4/4/14.
//  Copyright (c) 2014 raniys. All rights reserved.
//

#import "ParsingLog.h"

@implementation FTAppDelegate (ParsingLog)

-(NSNumber*)getDataFromLogPath: (NSString *)logPath
                   returnValue: (NSMutableString *)szReturnValue
{
    [szReturnValue setString:@""];
    NSString *strReadData = [[NSString alloc] initWithContentsOfFile:logPath encoding:NSUTF8StringEncoding error:nil];
    if ([strReadData isEqualToString:@""])
    {
        NSRunAlertPanel(@"警告(Warning)!",
						@"No data found!",
						@"确认（OK）", nil, nil);
        [szReturnValue setString:@"\nNo data found!"];
        return [NSNumber numberWithBool:NO];
    }
    [szReturnValue setString: strReadData];
    
    if ((![strReadData contains:@"PEGATRON"])
        || (![strReadData contains:@"PROJECT:"])
        || (![strReadData contains:@"STATION:"]))
    {
        NSRunAlertPanel(@"警告(Warning)!",
						@"文件格式不正确,请使用正确格式的UART log文件。(Invalid file, please make sure the file which you were choosed is a correct UART log file.)",
						@"确认（OK）", nil, nil);
        [szReturnValue setString:@"\n文件格式不正确,请使用正确格式的UART log文件。(Invalid file, please make sure the file which you were choosed is a correct UART log file.)"];
        return [NSNumber numberWithBool: NO];
    }
    //memory all data
    [m_dictMemoryValues setObject: strReadData forKey: kFT_File_Data];
    
    NSString    *strValue       = @"";
    //get the file tile
    strValue    = [strReadData SubTo:@"PROJECT:" include:NO];
    [m_dictMemoryValues setObject:strValue forKey:kFT_Department_Name];
    strValue    = [[strReadData SubFrom:@"PROJECT: " include:NO] SubTo:@"STATION:" include:NO];
    [m_dictMemoryValues setObject:strValue forKey:kFT_Project_Name];
    strValue    = [[strReadData SubFrom:@"STATION: " include:NO] SubTo:@"Overlay_Version" include:NO];
    [m_dictMemoryValues setObject: strValue forKey:kFT_Station_Name];
    
    return [NSNumber numberWithBool:YES];
}

//get command and result by target(Mobile/fixture/mikey)
-(NSNumber*)getDataByTargetFromLog:(NSString *)logData
                       returnValue:(NSMutableString *)szReturnValue
{
    if ([logData isEqualToString:@""])
    {
        NSRunAlertPanel(@"警告(Warning)!",
						@"No data found!",
						@"确认（OK）", nil, nil);
        [szReturnValue setString:@"\nNo data found!"];
        return [NSNumber numberWithBool:NO];
    }
    if ((![logData contains:@"(Item"]) || (![logData contains:@"===== START TEST"]))
    {
        NSRunAlertPanel(@"警告(Warning)!",
						@"文件格式不正确,请使用正确格式的UART log文件。(Invalid file, please make sure the file which you were choosed is a correct UART log file.)",
						@"确认（OK）", nil, nil);
        [szReturnValue setString:@"\n文件格式不正确,请使用正确格式的UART log文件。(Invalid file, please make sure the file which you were choosed is a correct UART log file.)"];
        return [NSNumber numberWithBool:NO];
    }
    //get command and result
    BOOL    bSuccessful         = NO;
    NSString *strEnd            = nil;
    BOOL    bIncludeEndSymbol   = NO;
    //get fixture command and result
    if ([[[m_dictMemoryValues objectForKey:kFT_Data_Parameters]objectForKey:@"FIXTURE"]count] != 0)
    {
        strEnd  = [[[m_dictMemoryValues objectForKey:kFT_Data_Parameters] objectForKey:@"FIXTURE"] objectForKey:@"EndSymbol"];
        bIncludeEndSymbol   = [[[[m_dictMemoryValues objectForKey:kFT_Data_Parameters] objectForKey:@"FIXTURE"] objectForKey:@"IsInclude"]boolValue];
    }
    bSuccessful |= [[self dealWithString:logData byTarget:@"FIXTURE" readCommandTo:strEnd ifInclude:bIncludeEndSymbol]boolValue];
    
    //get mobile command and result
    if ([[[m_dictMemoryValues objectForKey:kFT_Data_Parameters]objectForKey:@"MOBILE"]count] != 0)
    {
        strEnd  = [[[m_dictMemoryValues objectForKey:kFT_Data_Parameters] objectForKey:@"MOBILE"] objectForKey:@"EndSymbol"];
        bIncludeEndSymbol   = [[[[m_dictMemoryValues objectForKey:kFT_Data_Parameters] objectForKey:@"MOBILE"] objectForKey:@"IsInclude"]boolValue];
    }
    bSuccessful |= [[self dealWithString:logData byTarget:@"MOBILE" readCommandTo:strEnd ifInclude:bIncludeEndSymbol]boolValue];
    //get mikey command and result
    if ([[[m_dictMemoryValues objectForKey:kFT_Data_Parameters]objectForKey:@"MIKEY"]count] != 0)
    {
        strEnd  = [[[m_dictMemoryValues objectForKey:kFT_Data_Parameters] objectForKey:@"MIKEY"] objectForKey:@"EndSymbol"];
        bIncludeEndSymbol   = [[[[m_dictMemoryValues objectForKey:kFT_Data_Parameters] objectForKey:@"MIKEY"] objectForKey:@"IsInclude"]boolValue];
    }
    bSuccessful |= [[self dealWithString:logData byTarget:@"MIKEY" readCommandTo:strEnd ifInclude:bIncludeEndSymbol]boolValue];

    if (!bSuccessful)
        return [NSNumber numberWithBool:NO];
    return [NSNumber numberWithBool:YES];
}
//deal with log to get command and result
-(NSNumber *)dealWithString:(NSString *)strString
                   byTarget:(NSString *)strTarget
              readCommandTo:(NSString *)strEnd
                  ifInclude:(BOOL)bInclude
{
    if (![strString contains:[NSString stringWithFormat:@"(Clear Buffer ==> [%@]):",strTarget]])
        return [NSNumber numberWithBool:NO];
    [m_arrLogTargets addObject:strTarget];
    NSMutableArray  *arrCommand     = [[NSMutableArray alloc] init];
    NSArray         *aryData        = [strString componentsSeparatedByString:[NSString stringWithFormat:@"(Clear Buffer ==> [%@]):",strTarget]];
    for (NSString *strTemp in aryData)
    {
        NSString *strSendCommand    = @"";
        NSString *strReadCommand    = @"";
        NSMutableDictionary *dictCommandAndResult = [[NSMutableDictionary alloc] init];
        if ([strTemp contains:[NSString stringWithFormat:@"(TX ==> [%@]):",strTarget]])
        {
            strSendCommand = [[strTemp SubFrom:[NSString stringWithFormat:@"(TX ==> [%@]):",strTarget] include:NO] SubTo:@"[" include:NO];
            [dictCommandAndResult setObject:strSendCommand forKey:@"SendCommand"];
            if ([strTemp contains:[NSString stringWithFormat:@"(RX ==> [%@]):",strTarget]])
            {
                strReadCommand = [[strTemp SubFrom:[NSString stringWithFormat:@"(RX ==> [%@]):",strTarget] include:NO] SubTo:strEnd include:bInclude];
                [dictCommandAndResult setObject:strReadCommand forKey:@"ReadCommand"];
            }
            [arrCommand addObject:dictCommandAndResult];
            [dictCommandAndResult release];
        }
    }
    [m_dictMemoryValues setObject:arrCommand forKey:[NSString stringWithFormat:@"%@Command", strTarget]];
    [arrCommand release];
    return [NSNumber numberWithBool:YES];
}

@end
