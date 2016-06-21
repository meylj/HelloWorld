//
//  IALogs.m
//  FunnyZone
//
//  Created by Lorky on 4/13/11.
//  Copyright 2011 PEGATRON. All rights reserved.
//



#import "IALogs.h"
#import "NSStringCategory.h"
#import "publicDefine.h"

//static BOOL g_st_bSync = YES;
static NSString *g_st_szSyncUart		= @"";
static NSString *g_st_szSyncCSV		= @"";
static NSString *g_st_szSyncConsole	= @"";
static NSString *g_st_szSyncSummary	= @"";

@implementation IALogs
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
+ (void)CreatAndWriteUARTLog:(NSString *)szInfo
					  atTime:(NSString *)szTime
				  fromDevice:(NSString *)szDevice
					withPath:(NSString *)szPath
					  binary:(BOOL)bBinarySave
{    
    if (kIASaveLogs)
    {
        @synchronized(g_st_szSyncUart)
        {
            //write TxRx (string format)
            NSString		*szDirectory	= [szPath stringByDeletingLastPathComponent];
            NSFileManager	*fileManager	= [NSFileManager defaultManager];
            if (![fileManager fileExistsAtPath:szDirectory])
                [fileManager createDirectoryAtPath:szDirectory
					   withIntermediateDirectories:YES
										attributes:nil
											 error:nil];
            //Modify Log Format 20111021 by Ming
            NSString		*szCombinedInfo	= @"";
            if (!szTime || !szDevice)
                szCombinedInfo	= [NSString stringWithFormat:@"%@\n",szInfo];
            else
                szCombinedInfo	= [NSString stringWithFormat:@"[%@](%@):%@\n",
								   szTime,szDevice,szInfo];
            NSFileHandle	*h_UARTLog		= [NSFileHandle fileHandleForWritingAtPath:szPath];
            if (!h_UARTLog) 
                [szCombinedInfo writeToFile:szPath
								 atomically:NO
								   encoding:NSUTF8StringEncoding
									  error:nil];
            else
            {
                [h_UARTLog seekToEndOfFile];
                [h_UARTLog writeData:[szCombinedInfo dataUsingEncoding:NSUTF8StringEncoding]];
            }
            //write TxRx (binary format)
            if (bBinarySave) 
            {
                if (!h_UARTLog)
                    h_UARTLog	= [NSFileHandle fileHandleForWritingAtPath:szPath];
                //Modify Log Format 20111021 by Ming
                NSMutableString	*szHEXValue	= [[NSMutableString alloc] initWithFormat:
											   @"[%@](%@):",szTime,szDevice];
                const char		*cHexBuffer	= [szInfo cStringUsingEncoding:NSASCIIStringEncoding];
                for (int i = 0; i < strlen(cHexBuffer); i++)
				{
                    int			iHexReceive	= cHexBuffer[i];
                    NSString	*szTemp		= [NSString stringWithFormat:@"[0x%x]:",iHexReceive];
                    [szHEXValue appendFormat:@"%@",szTemp];
                }
                [szHEXValue appendFormat:@"\n"];
                [h_UARTLog writeData:[szHEXValue dataUsingEncoding:NSUTF8StringEncoding]];
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
+ (void)CreatAndWriteSingleCSVLog:(NSString *)szInfo
						 withPath:(NSString *)szPath
{
	if (kIASaveLogs)
	{
		@synchronized(g_st_szSyncCSV)
		{
			NSString		*szDirectory	= [szPath stringByDeletingLastPathComponent];
			NSFileManager	*fileManager	= [NSFileManager defaultManager];
			if (![fileManager fileExistsAtPath:szDirectory])
				[fileManager createDirectoryAtPath:szDirectory
					   withIntermediateDirectories:YES
										attributes:nil
											 error:nil];
			NSFileHandle	*h_CSVLog		= [NSFileHandle fileHandleForWritingAtPath:szPath];
			if (!h_CSVLog)
				[szInfo writeToFile:szPath
						 atomically:NO
						   encoding:NSUTF8StringEncoding
							  error:nil];
			else
			{
				[h_CSVLog seekToEndOfFile];
				[h_CSVLog writeData:[szInfo dataUsingEncoding:NSUTF8StringEncoding]];
				[h_CSVLog closeFile];
			}
		}
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
+ (void)CreatAndWriteConsoleInformation:(NSString *)szInfo
							   withPath:(NSString *)szPath
{
	if (kIASaveLogs)
	{
		@synchronized(g_st_szSyncConsole)
		{
			szInfo	= [NSString stringWithFormat:@"%@\n",szInfo];
			
			NSString		*szDirectory	= [szPath stringByDeletingLastPathComponent];
			NSFileManager	*fileManager	= [NSFileManager defaultManager];
			if (![fileManager fileExistsAtPath:szDirectory])
				[fileManager createDirectoryAtPath:szDirectory
					   withIntermediateDirectories:YES
										attributes:nil
											 error:nil];
			NSFileHandle	*h_ConsoleLog	= [NSFileHandle fileHandleForWritingAtPath:szPath];
			if (!h_ConsoleLog)
				[szInfo writeToFile:szPath
						 atomically:NO
						   encoding:NSUTF8StringEncoding
							  error:nil];
			else
			{
				[h_ConsoleLog seekToEndOfFile];
				[h_ConsoleLog writeData:[szInfo dataUsingEncoding:NSUTF8StringEncoding]];
				[h_ConsoleLog closeFile];
			}
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
+ (void)CreatAndWriteSummaryLog:(NSString *)szInfo
				 paraDictionary:(NSDictionary*)dicParams
					   withPath:(NSString *)szPath
{
	//Modified by Jean 2012.11.09 to make local summary log format as same as PDCA summary log.
    if (kIASaveLogs)
    {
        @synchronized(g_st_szSyncSummary)
        {
            NSString		*szDirectory	= [szPath stringByDeletingLastPathComponent];
            NSFileManager	*fileManager	= [NSFileManager defaultManager];
            if (![fileManager fileExistsAtPath:szDirectory])
                [fileManager createDirectoryAtPath:szDirectory
					   withIntermediateDirectories:YES
										attributes:nil
											 error:nil];
            szInfo	= [NSString stringWithFormat:@"%@\n",szInfo];
            NSFileHandle	*h_SummaryLog	= [NSFileHandle fileHandleForWritingAtPath:szPath];
            
            NSString		*szStationName	= [dicParams objectForKey:@"stationName"];
            NSString		*szVersion		= [dicParams objectForKey:@"softVersion"];
            NSString		*szItemsNames	= [dicParams objectForKey:@"testNames"];
			NSString		*szDisplayName	= [dicParams objectForKey:@"displayName"];
            NSString		*szUpLimits		= [dicParams objectForKey:@"upperLimits"];
            NSString		*szDnLimits		= [dicParams objectForKey:@"downLimits"];
            NSMutableString	*strComma		= [[NSMutableString alloc] initWithString:@""];
			NSMutableString *strUnit		= [[NSMutableString alloc] initWithString:@""];
			NSMutableString *strPDCAPriority = [[NSMutableString alloc] initWithString:@""];

            NSString		*szComma		= @",";
            NSArray			*arrCount		= [szUpLimits componentsSeparatedByString:szComma];
            int				iCount			= [arrCount count];
            for (int i = 0; i<= iCount + 7; i++)
                [strComma appendFormat:@"%@",szComma];
			
			for (int i = 1; i< iCount; i++) {
				[strUnit appendFormat:@"%@NA",szComma];
				[strPDCAPriority appendFormat:@"%@0",szComma];
			}
            
            NSString		*szTitle		= [NSString stringWithFormat:
											   @"%@,ATS_Version:%@%@",
											   szStationName,szVersion,strComma];
            NSMutableString	*szItemName		= [NSMutableString stringWithFormat:
											   @"Product,SerialNumber,Special Build Name,Special Build Description,Unit Number,Station ID,overallResult,StartTime,EndTime,List Of Failling Tests%@",
											   szItemsNames];
           
            if (!h_SummaryLog)
			{
				
                szInfo	= [NSString stringWithFormat:
						   @"%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@",
						   szTitle,
						   szItemName,
						   [NSString stringWithFormat:@"Display Name ----->,,,,,,,,,%@",szDisplayName],
						   [NSString stringWithFormat:@"PDCA Priority ----->,,,,,,,,,%@",strPDCAPriority],
						   [NSString stringWithFormat:@"Upper Limit ----->,,,,,,,,,%@",szUpLimits],
						   [NSString stringWithFormat:@"Lower Limit ----->,,,,,,,,,%@",szDnLimits],
						   [NSString stringWithFormat:@"Measurement Unit ----->,,,,,,,,,%@",strUnit],
						   szInfo];
                [szInfo writeToFile:szPath
						 atomically:NO
						   encoding:NSUTF8StringEncoding
							  error:nil];
            }
            else
            {
                // Add by xiaoyong 2012.2.22 to write the right format of summary log when test item is wrong.
                NSString	*szString		= [NSString stringWithContentsOfFile:szPath
																encoding:NSUTF8StringEncoding
																   error:nil];
                NSArray     *arrString		= [szString componentsSeparatedByString:@"\n"];
				
				// get the version of last test station
				NSString	*strVersion	= [NSString string];
				for (NSString * strTemp in arrString){
					strVersion = [strTemp contains:@"ATS_Version:"] ? strTemp : strVersion;
				}
				if (![strVersion contains:szVersion])
                {
					szInfo	= [NSString stringWithFormat:
							   @"%@\n%@\n%@\n%@\n%@\n%@\n%@\n%@",
							   szTitle,
							   szItemName,
							   [NSString stringWithFormat:@"Display Name ----->,,,,,,,,,%@",szDisplayName],
							   [NSString stringWithFormat:@"PDCA Priority ----->,,,,,,,,,%@",strPDCAPriority],
							   [NSString stringWithFormat:@"Upper Limit ----->,,,,,,,,,%@",szUpLimits],
							   [NSString stringWithFormat:@"Lower Limit ----->,,,,,,,,,%@",szDnLimits],
							   [NSString stringWithFormat:@"Measurement Unit ----->,,,,,,,,,%@",strUnit],
							   szInfo];
                }
				[h_SummaryLog seekToEndOfFile];
				[h_SummaryLog writeData:[szInfo dataUsingEncoding:NSUTF8StringEncoding]];
				[h_SummaryLog closeFile];
            }
            [strComma			release];
			[strUnit			release];
			[strPDCAPriority	release];
        }   
    }
}
@end
