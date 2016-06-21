//
//  IALogs.m
//  FunnyZone
//
//  Created by Lorky on 4/13/11.
//  Copyright 2011 PEGATRON. All rights reserved.
//

#import "IALogs.h"

//static BOOL g_st_bSync = YES;
static NSString * g_st_szSyncUart = @"";
static NSString * g_st_szSyncConsole = @"";
static NSString * g_st_szSyncSummary = @"";

@implementation IALogs

- (id)init
{
    self = [super init];
    if (self)
	{
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

#pragma mark ##########################       UART Log create and write        ###########################
// Descripton		:	
//
//		This fucntion was used to create a file to record the UART log. It will record
//		binary & string styles into same file.
//
// Param			;
//
//		szInfo		:		the message that will write into the file
//      szTime      :       send and receive command time
//      szDevice    :       which device command is sent to or receive from (such as DUT , fixture...)
//		szPath		:		absolute path (include directory and name)
//      binary      :       whether transfer command or response to hex and save 
+ (void)CreatAndWriteUARTLog:(NSString *)szInfo atTime:(NSString *)szTime fromDevice:(NSString *)szDevice withPath:(NSString *)szPath binary:(BOOL)bBinarySave
{    
    if (bNoNeedWriteUart)
    {
        return;
    }
    if (macro_W_Uart)
    {
        @synchronized(g_st_szSyncUart)
        {
            //write TxRx (string format)
            NSString *szDirectory = [szPath stringByDeletingLastPathComponent];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if (![fileManager fileExistsAtPath:szDirectory])
			{
                [fileManager createDirectoryAtPath:szDirectory withIntermediateDirectories:YES attributes:nil error:nil];
            }
            //Modify Log Format 20111021 by Ming
            NSString *szCombinedInfo = @"";
            if (!szTime || !szDevice)
			{
                szCombinedInfo = [NSString stringWithFormat:@"%@\n",szInfo];
            }
            else
            {
                szCombinedInfo = [NSString stringWithFormat:@"[%@](%@):%@\n",szTime,szDevice,szInfo];
            }
            NSFileHandle *h_UARTLog = [NSFileHandle fileHandleForWritingAtPath:szPath];
            if (!h_UARTLog) 
            {
                [szCombinedInfo writeToFile:szPath atomically:NO encoding:NSUTF8StringEncoding error:nil];
            }
            else
            {
                NSData *dataTemp = [[NSData alloc] initWithBytes:(void *)[szCombinedInfo UTF8String] length:[szCombinedInfo length]];
                [h_UARTLog seekToEndOfFile];
                [h_UARTLog writeData:dataTemp];
                [dataTemp release];
            }
            //write TxRx (hex format)
            if (bBinarySave) 
            {
				
                if (!h_UARTLog) 
                {
                    h_UARTLog = [NSFileHandle fileHandleForWritingAtPath:szPath];
                }
                //Modify Log Format 20111021 by Ming
                NSMutableString *szHEXValue = [[NSMutableString alloc] initWithFormat:@"[%@](%@):",szTime,szDevice];
				//transfer the info to hex and save to file
                const char * cHexBuffer = [szInfo cStringUsingEncoding:NSASCIIStringEncoding];
                for (int i = 0; i < strlen(cHexBuffer); i++)
			  {
				  int iHexReceive = cHexBuffer[i];
				  NSString *szTemp = [NSString stringWithFormat:@"[0x%x]:",iHexReceive];
				  [szHEXValue appendFormat:@"%@",szTemp];
			  }
                [szHEXValue appendFormat:@"\n"];
                NSData *dataHexTemp = [[NSData alloc] initWithBytes:(void *)[szHEXValue UTF8String] length:[szHEXValue length]];
                [h_UARTLog writeData:dataHexTemp];
                [dataHexTemp release];
                [szHEXValue release];
            }
            [h_UARTLog closeFile];
        }
    }
}

#pragma mark #####################      Single CSV log create and write           ########################
// Descripton		:	
//
//		This fucntion was used to create a file to record the CSV log.
// Param			;
//
//		szInfo		:		the message that will write into the file
//		szPath		:		absolute path (include directory and name) 
+ (void)CreatAndWriteSingleCSVLog:(NSString *)szInfo withPath:(NSString *)szPath
{
    if (bNoNeedWriteCSV)
    {
        return;
    }
    NSString *szDirectory = [szPath stringByDeletingLastPathComponent];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:szDirectory])
	{
		[fileManager createDirectoryAtPath:szDirectory withIntermediateDirectories:YES attributes:nil error:nil];
	}
	NSFileHandle *h_CSVLog = [NSFileHandle fileHandleForWritingAtPath:szPath];
	if (!h_CSVLog)
	{
		//create a file at the szPath and write the szInfo to the file
		[szInfo writeToFile:szPath atomically:NO encoding:NSUTF8StringEncoding error:nil];
	}
    else
    {
		//the file is exit,append the info to the end of the file 
        NSData *dataTemp = [[NSData alloc] initWithBytes:(void *)[szInfo UTF8String] length:[szInfo length]];
        [h_CSVLog seekToEndOfFile];
        [h_CSVLog writeData:dataTemp];
        [dataTemp release];
        [h_CSVLog closeFile];
    }
}


#pragma mark ######################			Debug log create and write          ##########################
// Descripton		:		
//
//		This fucntion was used to create a file to record the console log.
//
// Param			;
//
//		szInfo		:		the message that will write into the file
//		szPath		:		absolute path (include directory and name) 
+ (void)CreatAndWriteConsoleInformation:(NSString *)szInfo withPath:(NSString *)szPath
{
    if (bNoNeedWriteDebug)
    {
        return;
    }
    @synchronized(g_st_szSyncConsole)
    {
        szInfo = [NSString stringWithFormat:@"%@\n",szInfo];
        NSString *szDirectory = [szPath stringByDeletingLastPathComponent];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:szDirectory])
		{
            [fileManager createDirectoryAtPath:szDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSFileHandle *h_ConsoleLog = [NSFileHandle fileHandleForWritingAtPath:szPath];
        if (!h_ConsoleLog)
		{
			//create a file at the szPath and write the szInfo to the file
            [szInfo writeToFile:szPath atomically:NO encoding:NSUTF8StringEncoding error:nil];
        }
        else
        {
			//append the info to the end of the file
            NSData *dataTemp = [[NSData alloc] initWithBytes:(void *)[szInfo UTF8String] length:[szInfo length]];
            [h_ConsoleLog seekToEndOfFile];
            [h_ConsoleLog writeData:dataTemp];
            [dataTemp release];
            [h_ConsoleLog closeFile];
        }
    }
}

#pragma mark ######################			Summary log create and write          ##########################
// Descripton		:		
//
//		This fucntion was used to create a file to summary all csv log.
//
// Param			;
//
//		szInfo		:		the message that will write into the file (the normal line)
//      dicParmas   :       params when writing
//                          stationName: such as PGPD_F05-4FT-FlightDeck_1_QT0b
//                          softVersion: UI version
//                          testNames  : names of all test items
//                          upperLimits: uppder limits of all test items
//                          downLimits : down limits of all test items
//		szPath		:		absolute path (include directory and name) 
+ (void)CreatAndWriteSummaryLog:(NSString *)szInfo paraDictionary:(NSDictionary*)dicParams withPath:(NSString *)szPath
{
    if (macro_W_Summary) 
    {
        @synchronized(g_st_szSyncSummary)
        {
            NSString *szDirectory = [szPath stringByDeletingLastPathComponent];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if (![fileManager fileExistsAtPath:szDirectory])
			{
                [fileManager createDirectoryAtPath:szDirectory withIntermediateDirectories:YES attributes:nil error:nil];
            }
            szInfo = [NSString stringWithFormat:@"%@\n",szInfo];
            NSFileHandle *h_SummaryLog	= [NSFileHandle fileHandleForWritingAtPath:szPath];
            
            NSString	*szStationName	= [dicParams objectForKey:@"stationName"];
            NSString	*szVersion		= [dicParams objectForKey:@"softVersion"];
            NSString	*szItemsNames		= [dicParams objectForKey:@"testNames"];
            NSString	*szUpLimits		= [dicParams objectForKey:@"upperLimits"];
            NSString	*szDnLimits		= [dicParams objectForKey:@"downLimits"];
            NSMutableString *strComma	= [[NSMutableString alloc] initWithString:@""];

            NSString	*szComma		= @",";
            NSArray	*arrCount		= [szUpLimits componentsSeparatedByString:szComma];
            int		iCount		= [arrCount count];
            for (int i = 0; i<= iCount + 4; i++)
			{
                [strComma appendFormat:@"%@",szComma];
            }
            
            NSString *szTitle = [NSString stringWithFormat:@"Muifa Station:%@  Version:%@%@",szStationName,szVersion,strComma];
            NSMutableString *szItemName = [NSMutableString stringWithFormat:@"SerialNumber,Test Pass/Fail Status,List of Failing Tests,Error Description,Test Start Time,Test Stop Time,Config%@",szItemsNames];
//            NSMutableString *szUpperLimits = [NSMutableString stringWithFormat:@"Upper Limits----->,,,,,,%@",szUpLimits];
//            NSMutableString *szDownLimits = [NSMutableString stringWithFormat:@"Lower Limits----->,,,,,,%@",szDnLimits];
           
            if (!h_SummaryLog)
			{
                   //create a file at the szPath,and add titles in the szInfo
                szInfo = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n%@",szTitle,szItemName,[NSString stringWithFormat:@"Upper Limit ----->,,,,,,%@",szUpLimits],[NSString stringWithFormat:@"Lower Limit ----->,,,,,,%@",szDnLimits],[NSString stringWithFormat:@"Measurement Unit -----> %@",strComma],szInfo];
                [szInfo writeToFile:szPath atomically:NO encoding:NSUTF8StringEncoding error:nil];
            }
            else
            {
                // Add by xiaoyong 2012.2.22 to write the right format of summary log when test item is wrong.
                NSString    *szString = [NSString stringWithContentsOfFile:szPath encoding:NSUTF8StringEncoding error:nil];
                NSArray     *arrString = [szString componentsSeparatedByString:@"\n"];
                NSString    *szLastLine = [arrString objectAtIndex:[arrString count]-2];
                NSString    *strValue;
                int         iUpLimitCount = [[szUpLimits componentsSeparatedByString:@","] count];
                int         iLastLineCount = -1;
                
                // get the length of recent test items
                NSRange     range = [szLastLine rangeOfString:@"BringUp"];
                if ((range.location != NSNotFound) && (range.length > 0) && (range.location+range.length<=[szLastLine length]))
				{
                    strValue  = [szLastLine substringFromIndex:range.location + range.length];
                    iLastLineCount = [[strValue componentsSeparatedByString:@","] count];
                }
                // compare recent test item's length with last test's
                if ((iLastLineCount != iUpLimitCount) && (-1 != iLastLineCount)) 
                {
                    szInfo = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@",szItemName,[NSString stringWithFormat:@"Upper Limit ----->,,,,,,%@",szUpLimits],[NSString stringWithFormat:@"Lower Limit ----->,,,,,,%@",szDnLimits],[NSString stringWithFormat:@"Measurement Unit -----> %@",strComma],szInfo];
                    NSData  *data = [[NSData alloc] initWithBytes:(void *)[szInfo UTF8String] length:[szInfo length]];
                    [h_SummaryLog	seekToEndOfFile];
                    [h_SummaryLog	writeData:data];
                    [data			release];
					[h_SummaryLog	closeFile];
                }
                else
                {
                    NSData *dataTemp = [[NSData alloc] initWithBytes:(void *)[szInfo UTF8String] length:[szInfo length]];
                    [h_SummaryLog	seekToEndOfFile];
                    [h_SummaryLog	writeData:dataTemp];
                    [dataTemp		release];
					[h_SummaryLog	closeFile];
                }
            }
            [strComma release];
        }   
    }
}
@end
