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

extern BOOL bNoNeedWriteCSV;
extern BOOL bNoNeedWriteUart;
extern BOOL bNoNeedWriteDebug;

@interface IALogs : NSObject
{
@private
    
}
/* Descripton	:
 *		This fucntion was used to create a file to record the UART log. It will record
 *		hex & string styles into the same file.
 *
 *	Param		:
 *		szInfo		:		the information that will write into the file
 *		szTime		:       the time of send and receive commands
 *		szDevice	:       which device the command is sented to or received from (such as mobile , fixture...)
 *		szPath		:		absolute path of uart log (include directory and file name)
 *      binary		:       whether transfer command and response to hex and save it
 */
+ (void)CreatAndWriteUARTLog:(NSString *)szInfo atTime:(NSString *)szTime fromDevice:(NSString *)szDevice withPath:(NSString *)szPath binary:(BOOL)bBinarySave;
/* Descripton	:
 *		This fucntion was used to create a file to record all of the CSV logs(CSV and CycleTime log). 
 *	Param		:
 *		szInfo		:		the information that will write into the file
 *		szPath		:		absolute path of csv log (include directory and file name)
 */
+ (void)CreatAndWriteSingleCSVLog:(NSString *)szInfo withPath:(NSString *)szPath;
/* Descripton	:
 *		This fucntion was used to create a file to record the Console log.  
 *	Param		:
 *		szInfo		:		the information that will write into the file
 *		szPath		:		absolute path of Console log (include directory and file name)
*/
+ (void)CreatAndWriteConsoleInformation:(NSString *)szInfo withPath:(NSString *)szPath;
/* Descripton	:
 *		This fucntion was used to create a file to record the summary log. 
 *	Param		:
 *		szInfo		:		the information that will write into the file
 *		dicParams	:		params when writing
 *								stationName: such as PGPD_F05-4FT-FlightDeck_1_QT0b
 *								softVersion: UI version
 *								testNames  : names of all test items
 *								upperLimits: uppder limits of all test items
 *								downLimits : down limits of all test items
 *		szPath		:		absolute path of summary log (include directory and file name)
 */
+ (void)CreatAndWriteSummaryLog:(NSString *)szInfo paraDictionary:(NSDictionary*)dicParams withPath:(NSString *)szPath;
@end
