//
//  AppDelegate.h
//  CompareCSV
//
//  Created by happy on 13-8-28.
//  Copyright (c) 2013年 happy. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSStringCategory.h"


@interface AppDelegate : NSObject <NSApplicationDelegate,NSOpenSavePanelDelegate>
{
//Ours
    IBOutlet NSButton		*btnSelectLogPath;
	IBOutlet NSTextField	*txtLogpath;
    IBOutlet NSTextField    *txtFileToPath;
    IBOutlet NSTextField    *txtShowResult;
	NSString				*m_strCreateTime;
	NSString				*m_strStationNameofOurs;
    NSString                *m_strStationNameofOurs1;
	NSMutableArray			*m_aryItemsName;
	NSMutableArray			*m_aryItemsSpec;
	NSMutableString			*m_strUartLogPath;
	NSMutableString			*m_strCSVLogPath;
	NSMutableDictionary     *m_dicItemsUartCommand;
    NSMutableArray			*m_arySameItemName;
	NSMutableDictionary		*m_dicSameItemComm;
//South
    IBOutlet NSTextField    *tfFilePath;
    IBOutlet NSTextField    *tfFileToPath;
    IBOutlet NSTextField    *tfShow;
    NSString                *m_strStationNameofSouth;
    NSString                *m_strStationNameofSouth1;
    NSString                *m_szTime;
    BOOL                    m_bFailLog;
    int                     m_iFailLog;
    NSString                *m_szFilePath;
    NSString                *m_szFileName;
//Compare
    IBOutlet NSTableView*   tvCompareResult;
    IBOutlet NSTextField*   tfShowCSV1Path;
    IBOutlet NSTextField*   tfShowCSV2Path;
    IBOutlet NSTextField*   tfShow_CompareCSVPath;
    NSString*               m_strCSV1Path;
    NSString*               m_strCSV2Path;
    NSMutableArray*         m_arrTestItems;
    NSMutableArray*         m_arrTestLimits1;
    NSMutableArray*         m_arrTestLimits2;
    NSMutableArray*         m_arrCommand1;
    NSMutableArray*         m_arrCommand2;
    NSMutableArray*         m_arrNote;
    NSMutableArray*         m_arrAddItems;
    NSMutableArray*         m_arrDelItems;
    NSString*               m_strPath1;
    NSString*               m_strPath2;
    
}
@property (assign) IBOutlet NSWindow *window;
//Ours
- (IBAction)SelectLogsPath:(NSButton *)sender;// select the folder that csv and uart logs in
- (IBAction)CreateTestCoverage:(id)sender;// create a csv file
- (void)readCSVLogs;// read the item name and spec from the csv log
- (void)readUartLogs;// read the uart command from the uart log
-(void)writeTestCoverage1:(NSString *)strItemInfo toPath:(NSString *)strPath;

//South
-(IBAction)start:(id)sender;
/*
 enter the button
 */
-(IBAction)ChooseSouthLog:(id)sender;

/*
 Choose the south log file and read it.
 return a string which is read log file.
 */
-(NSString *)ReadLog;

/*
 Separated the string which read log file.
 return an array for Separated.
 */
-(NSArray*)componentsSeparated:(NSString*)szRead;


/*
 Catch the value to write csv.
 szread:    string of array.
 numItem:   array index.
 
 return : string to write csv.
 */
-(NSString*)valueToWrtteCsv:(NSString*)szRead numItem:(int)i;

/*
 Catch the value which is command.
 szread:    string of array.
 numItem:   array index.
 return : string to write csv.
 */
-(NSString*)sendcommand:(NSString*)szRead numItem:(int)i;
-(void)WriteToCsv:(NSString*)szReadFromTxt;

//Compare
-(IBAction)AddCSV1:(id)sender;//Add our CSV
-(IBAction)AddCSV2:(id)sender;//Add south CSV
-(IBAction)Compare:(id)sender;//Compare ours and south
-(void)writeTestCoverage:(NSString *)strItemInfo toPath:(NSString *)strPath;//Write the CSV after comparing
@end
