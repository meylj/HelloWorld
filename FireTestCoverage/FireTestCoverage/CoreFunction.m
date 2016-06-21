//
//  CoreFunction.m
//  FireTestCoverage
//
//  Created by raniys on 11/13/14.
//  Copyright (c) 2014 raniys. All rights reserved.
//


#import <Cocoa/Cocoa.h>

#import "FTCPublicDefine.h"
#import "CoreFunction.h"
#import "NSStringCategory.h"
#import "LibXL/libxl.h"


//HTML 中有用的字符实体
//显示结果	描述      实体名称            实体编号
//        空格      &nbsp;                &#160;
//<       小于号     &lt;                  &#60;
//>       大于号     &gt;                  &#62;
//&       和号      &amp;                 &#38;
//"       引号      &quot;                &#34;
//'       撇号      &apos; (IE不支持)      &#39;
//￠       分       &cent;                &#162;
//£       镑       &pound;               &#163;
//¥       日圆      &yen;                 &#165;
//€       欧元      &euro;                &#8364;
//§       小节      &sect;                &#167;
//©       版权      &copy;                &#169;
//®       注册商标   &reg;                  &#174;
//™       商标      &trade;               &#8482;
//×       乘号      &times;               &#215;
//÷       除号      &divide;              &#247;


//HTML 颜色
//十六进制颜色值       颜色名
//#000000           black
//#FF4500           red
//#808080           gray
//#FFFF00           yellow
//#9ACD32           yellowgreen
//#98FB98           PaleGreen
//#0000FF           blue
//#FF00FF           Fuchsia
//#008000           Green

#define KFT_TestCoverageStatus_TBC          @"#FF4500"
#define KFT_TestCoverageStatus_REMOVED      @"#808080"
#define KFT_TestCoverageStatus_OPEN         @"#FF00FF"
#define KFT_TestCoverageStatus_ONGOING      @"#9ACD32"
#define KFT_TestCoverageStatus_VALIDATION   @"#98FB98"
#define KFT_TestCoverageStatus_CLOSE        @"#008000"

@implementation CoreFunction
@synthesize lineProgress = m_lineProgress;
@synthesize textProgress = m_textProgress;

-(id)init
{
    self = [super init];
    if (self)
    {
        m_aryAllData = [NSMutableArray array];
        m_dicStationStatus  = [NSDictionary dictionaryWithObjectsAndKeys:
                               KFT_TestCoverageStatus_VALIDATION,@"Validation",
                               KFT_TestCoverageStatus_TBC,@"TBC",
                               KFT_TestCoverageStatus_REMOVED,@"Removed",
                               KFT_TestCoverageStatus_OPEN,@"Open",
                               KFT_TestCoverageStatus_ONGOING,@"Ongoing",
                               KFT_TestCoverageStatus_CLOSE,@"Close", nil];
    }
    return self;
}

-(NSArray *)loadDataFromPlistFile:(NSString *)path
{
    NSMutableArray *aryPlist = [NSMutableArray arrayWithContentsOfFile:path];
    NSMutableArray *aryAllCommands = [NSMutableArray array];
    for (id aDic in aryPlist)
    {
        NSMutableDictionary *aDicForSingleItem = [NSMutableDictionary dictionary];
        NSArray *ary    = [NSArray arrayWithArray:[aDic allKeys]];
        NSArray *bAry   = [aDic objectForKey:[ary objectAtIndex:0]];
        [aDicForSingleItem setObject:[ary objectAtIndex:0] forKey:@"Item"];
        NSMutableArray  *aAryForAllCmdInSingleItem  = [NSMutableArray array];
        
        for(id bDic in bAry )
        {
            NSArray* cAry = [NSArray arrayWithArray:[bDic allKeys]];
            if([cAry containsObject:@"SEND_COMMAND:"])
            {
                id cDic = [bDic objectForKey:@"SEND_COMMAND:"];
                NSMutableDictionary *aDic = [NSMutableDictionary dictionaryWithObjects:
                                             [NSArray arrayWithObjects:[cDic objectForKey:@"STRING"],[cDic objectForKey:@"TARGET"], nil]
                                                                               forKeys:[NSArray arrayWithObjects:@"Command",@"Target", nil]];
                [aAryForAllCmdInSingleItem addObject:aDic];
            }
            if([cAry containsObject:@"JUDGE_SPEC:RETURN_VALUE:"])
            {
                id cDic = [bDic objectForKey:@"JUDGE_SPEC:RETURN_VALUE:"];
                NSString *heheDic = [NSString stringWithString:[[cDic objectForKey:@"COMMON_SPEC"] objectForKey:@"P_LimitBlack"]];
                [aDicForSingleItem setObject:heheDic forKey:@"SPEC"];
            }
        }
        [aDicForSingleItem setObject:aAryForAllCmdInSingleItem forKey:@"Item/Command"];
        [aryAllCommands addObject:aDicForSingleItem];
    }
    
    return aryAllCommands;
}

-(id)loadDataFromTxtFile:(NSString *)path
{
//    NSMutableArray *aryAllCommands = [NSMutableArray array];
    NSString *strReadData = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if ([strReadData isEqualToString:@""])
    {
        return [NSError errorWithDomain:@"No data found!" code:001 userInfo:nil];
    }
    
    if ((![strReadData contains:@"PEGATRON"])
        || (![strReadData contains:@"PROJECT:"])
        || (![strReadData contains:@"STATION:"]))
    {
        return [NSError errorWithDomain:@"文件格式不正确,请使用正确格式的UART log文件。(Invalid file, please make sure the file you choosed is a correct UART log file.)" code:002 userInfo:nil];
    }
    
    if ((![strReadData contains:@"(Item"]) || (![strReadData contains:@"===== START TEST"]))
    {
        return [NSError errorWithDomain:@"文件格式不正确,请使用正确格式的UART log文件。(Invalid file, please make sure the file which you were choosed is a correct UART log file.)" code:002 userInfo:nil];
    }
    //get command and result
    return [self getItemAndCommandFromData:strReadData];
}

-(void)writeData:(NSMutableArray *)data ToTxtFile:(NSURL *)url unitStatus:(id)checkUnitButton fixtureStatus:(id)checkFixtureButton
{
//    NSString * strFilePath = [NSString stringWithFormat:@"%@/TextCommand.txt",url];
//    strFilePath = [strFilePath stringByExpandingTildeInPath];
//    strFilePath = [strFilePath stringByExpandingTildeInPath];
//    NSURL *excelFileURL = url;
    NSMutableString *szAllCmd   = [NSMutableString string];
    NSMutableString *szBuffer   = [NSMutableString string];
    if(0 != [data count])
    {
        iAllCount = [data count];
        for(int i = 0; i < [data count]; i++)
        {
            iCurrentItem   = i;
            [self runProgress];
            NSMutableString    *szItemName  = [[NSMutableString alloc] init];
            NSMutableString    *szCommands  = [[NSMutableString alloc] init];
//            NSMutableString    *szReadCommand  = [[NSMutableString alloc] init];
            NSMutableString    *szSpec      = [[NSMutableString alloc] init];
            if(nil  != [[data objectAtIndex:i] objectForKey:@"Item"])
                [szItemName setString:[NSString stringWithFormat:@"Item%d:%@\n",i+1,[[data objectAtIndex:i] objectForKey:@"Item"]]];
            if (0==[[[data objectAtIndex:i] objectForKey:@"Item/Command"] count])
            {
                [szCommands setString:@"N/A\n"];
            }
            else
                for (int j = 0; j<[[[data objectAtIndex:i] objectForKey:@"Item/Command"] count]; j++)
                {
                    if ([szCommands isEqualToString:@"N/A\n"])
                        [szCommands setString:@""];
                    if(nil != [[[[data objectAtIndex:i] objectForKey:@"Item/Command"] objectAtIndex:j] objectForKey:@"ReadCommand"])
                    {
                        if([checkUnitButton state] == 1 && [checkFixtureButton state] == 0)
                        {
                            if([[[[[data objectAtIndex:i] objectForKey:@"Item/Command"] objectAtIndex:j] objectForKey:@"Target"] isEqualToString:@"MOBILE"])
                            {
                                [szCommands appendString:[[[[data objectAtIndex:i] objectForKey:@"Item/Command"] objectAtIndex:j] objectForKey:@"ReadCommand"]];
                                [szCommands appendString:@"\n\n"];
                            }
//                            else if(szCommands == nil || [szCommands isEqualToString:@""])
//                                [szCommands setString:@"N/A\n"];
                        }
                        else if([checkUnitButton state] == 1 && [checkFixtureButton state] == 1)
                        {
                            [szCommands appendString:[NSString stringWithFormat:@"%@",[[[[data objectAtIndex:i] objectForKey:@"Item/Command"] objectAtIndex:j] objectForKey:@"ReadCommand"]]];
                            [szCommands appendString:@"\n\n"];
                        }
                        else
                        {
                            if([[[[[data objectAtIndex:i] objectForKey:@"Item/Command"] objectAtIndex:j] objectForKey:@"Target"] isEqualToString:@"FIXTURE"])
                            {
                                [szCommands appendString:[[[[data objectAtIndex:i] objectForKey:@"Item/Command"] objectAtIndex:j] objectForKey:@"ReadCommand"]];
                                [szCommands appendString:@"\n\n"];
                            }
//                            else if(szCommands == nil || [szCommands isEqualToString:@""])
//                                [szCommands setString:@"N/A\n"];
                        }
                    }
                    else if(nil != [[[[data objectAtIndex:i] objectForKey:@"Item/Command"] objectAtIndex:j] objectForKey:@"Command"])
                    {
                        if([checkUnitButton state] == 1 && [checkFixtureButton state] == 0)
                        {
                            if([[[[[data objectAtIndex:i] objectForKey:@"Item/Command"] objectAtIndex:j] objectForKey:@"Target"] isEqualToString:@"MOBILE"])
                            {
                                [szCommands appendString:[[[[data objectAtIndex:i] objectForKey:@"Item/Command"] objectAtIndex:j] objectForKey:@"Command"]];
                                [szCommands appendString:@"\n"];
                            }
//                            else if(szCommands == nil || [szCommands isEqualToString:@""])
//                                [szCommands setString:@"N/A\n"];
                        }
                        else if([checkUnitButton state] == 1 && [checkFixtureButton state] == 1)
                        {
                            [szCommands appendString:[NSString stringWithFormat:@"%@",[[[[data objectAtIndex:i] objectForKey:@"Item/Command"] objectAtIndex:j] objectForKey:@"Command"]]];
                            [szCommands appendString:@"\n"];
                        }
                        else
                        {
                            if([[[[[data objectAtIndex:i] objectForKey:@"Item/Command"] objectAtIndex:j] objectForKey:@"Target"] isEqualToString:@"FIXTURE"])
                            {
                                [szCommands appendString:[[[[data objectAtIndex:i] objectForKey:@"Item/Command"] objectAtIndex:j] objectForKey:@"Command"]];
                                [szCommands appendString:@"\n"];
                            }
//                            else if(szCommands == nil || [szCommands isEqualToString:@""])
//                                [szCommands setString:@"N/A\n"];
                        }
                    }
                    
                }
            if (nil != [[data objectAtIndex:i] objectForKey:@"SPEC"])
            {
                [szSpec  setString:[NSString stringWithFormat:@"SPEC:%@\nCommand:\n",[[data objectAtIndex:i] objectForKey:@"SPEC"]]];
            }
            else
                [szSpec setString:@"SPEC: N/A\nCommand:\n"];
            
            [szBuffer appendString:[NSString stringWithFormat:@"\n%@%@%@\n",szItemName,szSpec,szCommands]];
        }
        [szAllCmd setString:szBuffer];
        [szAllCmd writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

-(id)getItemAndCommandFromData:(NSString *)data
{
    NSMutableArray  *aryAllCommands     = [NSMutableArray array];
    
    m_Version   = @"";
    if ([data containsString:@"Overlay_Version : "])
    {
        m_Version = [[data SubFrom:@"Overlay_Version : " include:NO]SubTo:@"\n" include:NO];
    }
    data = [data SubFrom:@"===== START TEST" include:YES];
    NSArray *aryData = [data componentsSeparatedByString:@"===== START TEST "];
    for (NSString *strTemp in aryData)
    {
        m_aryAllData = [NSMutableArray array];
        if ([strTemp isNotEqualTo:@""])
        {
            NSMutableDictionary *dicItems   = [NSMutableDictionary dictionary];
            NSString *itemName = [[strTemp SubFrom:@"Item Name:" include:NO]SubTo:@", " include:NO];
            NSString *itemSpec = [[[[strTemp SubFrom:@"Item Name:" include:NO] SubFrom:@", " include:NO]SubTo:@"\n===" include:NO] deleteLineFeeds];
            [dicItems setObject: itemName forKey:@"Item"];
            [dicItems setObject:itemSpec forKey:@"SPEC"];
            NSString *buffer = [[strTemp SubFrom:@"===== START TEST " include:YES] SubTo:@"Item Name:" include:NO];
            //get command and result
            if ([self dealWithString:buffer])
            {
                [dicItems setObject:m_aryAllData forKey:@"Item/Command"];
            }
            [aryAllCommands addObject:dicItems];
        }
    }
    if ([aryAllCommands count] == 0)
    {
        return [NSError errorWithDomain:@"No data found!" code:001 userInfo:nil];
    }
    return aryAllCommands;
}

//deal with log to get command and result
-(BOOL)dealWithString:(NSString *)strString
{
    if (![strString contains:@"(Clear Buffer ==> ["])
        return NO;
    NSArray *aryData = [strString componentsSeparatedByString:@"Clear Buffer ==>"];
    for (int i = 1; i< [aryData count]; i++)
    {
        NSString *strTemp = @"";
        NSString *strSendCommand    = @"";
        NSString *strReadCommand    = @"";
        NSString *strTXTarget       = @"";
        NSString *strRXTarget       = @"";
        NSMutableDictionary *dictCommandAndResult = [NSMutableDictionary dictionary];
        
        strTemp = [aryData objectAtIndex:i];
        strTXTarget = [[strTemp SubFrom:@"TX ==> [" include:NO] SubTo:@"]" include:NO];
        strRXTarget = [[strTemp SubFrom:@"RX ==> [" include:NO] SubTo:@"]" include:NO];
        
        NSString *strEnd    = @"";
        BOOL    bInclude    = YES;
        if (strTXTarget != nil && [strTXTarget isNotEqualTo:@""])
        {
            [dictCommandAndResult setObject:strTXTarget forKey:@"Target"];
            if ([strTXTarget isEqualToString:@"MOBILE"])
            {
                strEnd      = @":-)";
                bInclude    = YES;
            }
            else if([strTXTarget isEqualToString:@"FIXTURE"])
            {
                strEnd      = @"@_@";
                bInclude    = YES;
            }
            else if([strTXTarget isEqualToString:@"MIKEY"])
            {
                strEnd      = @"]";
                bInclude    = YES;
            }
            else if([strTXTarget isEqualToString:@"CL200A"])
            {
                strEnd      = @"[";
                bInclude    = NO;
            }
            else
            {
                strEnd      = @"[";
                bInclude    = NO;
            }
            strSendCommand = [[strTemp SubFrom:[NSString stringWithFormat:@"TX ==> [%@]):",strTXTarget] include:NO] SubTo:@"\n[" include:NO];
            if ([strSendCommand isNotEqualTo:@""] && strSendCommand != nil)
            {
                [dictCommandAndResult setObject:strSendCommand forKey:@"Command"];
                if (![strTXTarget isEqualToString:@"CL200A"])
                {
                    for (int j = 1; j<[aryData count]; j++)
                    {
                        NSString *strRXTemp = [aryData objectAtIndex:j];
                        if ([strRXTemp contains:strSendCommand] && [strRXTemp contains:[NSString stringWithFormat:@"RX ==> [%@]):",strTXTarget]])
                        {
                            strReadCommand = [[strRXTemp SubFrom:[NSString stringWithFormat:@"RX ==> [%@]):",strTXTarget] include:NO] SubTo:strEnd include:bInclude];
                            strReadCommand = [strReadCommand stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
                            [dictCommandAndResult setObject:strReadCommand forKey:@"ReadCommand"];
                            break;
                        }
                    }
                }
                else
                {
                    if ([strTemp contains:[NSString stringWithFormat:@"RX ==> [%@]):",strTXTarget]])
                        strReadCommand = [[strTemp SubFrom:[NSString stringWithFormat:@"RX ==> [%@]):",strTXTarget] include:NO] SubTo:strEnd include:bInclude];
                    strReadCommand = [strReadCommand stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
                    [dictCommandAndResult setObject:strReadCommand forKey:@"ReadCommand"];
                }
                [m_aryAllData addObject:dictCommandAndResult];
            }
        }
        else if(strRXTarget != nil && [strRXTarget isNotEqualTo:@""])
        {
            [dictCommandAndResult setObject:strRXTarget forKey:@"Target"];
            if ([strTXTarget isEqualToString:@"MOBILE"])
            {
                strEnd      = @":-)";
                bInclude    = YES;
            }
            else if([strTXTarget isEqualToString:@"FIXTURE"])
            {
                strEnd      = @"@_@";
                bInclude    = YES;
            }
            else if([strTXTarget isEqualToString:@"MIKEY"])
            {
                strEnd      = @"]";
                bInclude    = YES;
            }
            else if([strTXTarget isEqualToString:@"CL200A"])
            {
                strEnd      = @"[";
                bInclude    = NO;
            }
            else
            {
                strEnd      = @"[";
                bInclude    = NO;
            }
            
            NSString *strRXTemp = [aryData objectAtIndex:i];
            strSendCommand = @"";
            strReadCommand = [[strRXTemp SubFrom:[NSString stringWithFormat:@"RX ==> [%@]):",strTXTarget] include:NO] SubTo:strEnd include:bInclude];
            strReadCommand = [strReadCommand stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
            [dictCommandAndResult setObject:strSendCommand forKey:@"Command"];
            [dictCommandAndResult setObject:strReadCommand forKey:@"ReadCommand"];
            [m_aryAllData addObject:dictCommandAndResult];
        }
        else
            continue;
    }
    return YES;
}

-(NSNumber *)updateUartData:(NSArray *)arrData
             toTestCoverage:(NSString *)excelPath
         withSpecialSetting:(NSDictionary *)dicSetting
{
    NSLog(@"Start to update test coverage");

    NSMutableArray  *arrTestItems   = [[NSMutableArray alloc] init];//save the test items
    excelPath   = [excelPath contains:@"file://"]?[excelPath SubFrom:@"file://" include:NO]:excelPath;
    if([arrData count] == 0 )
    {
        NSLog(@"UartLog format error. Please check!");
        return [NSNumber numberWithBool:NO];
    }
    //  get the station name
    NSString  * strStationName = [[[arrData objectAtIndex:0]objectForKey:@"Item"]SubFrom:@"START_TEST_" include:NO];
    strStationName = [strStationName stringByReplacingOccurrencesOfString:@" " withString:@""];
    //save the  uartlog to an array by test item
    for (int i = 0; i< [arrData count]; i++)
    {
        NSString *strItemName = [[arrData objectAtIndex:i]objectForKey:@"Item"];
        [arrTestItems addObject:strItemName];
    }
    
    if(![[self checkTestCoverage:excelPath
                 forStation:strStationName
                withSetting:[NSDictionary dictionaryWithObjectsAndKeys:arrTestItems,@"logItems", nil]]boolValue])
        return [NSNumber numberWithBool:NO];
    
    NSString *strStatus = @"";
    int     iStatusRow  = 0;
    int     iStatusCol  = 0;
    if (dicSetting)
    {
        strStatus   = [dicSetting objectForKey:@"status"];
        iStatusCol  = [[dicSetting objectForKey:@"Column"]intValue] - 1;
        iStatusRow  = [[dicSetting objectForKey:@"Row"]intValue] - 1;
    }
    //  get the sheet handle and book handle to edit the TC
    SheetHandle     sheet = nil;
    SheetHandle     sheetStation   = nil;
    FormatHandle    sheetFormat;
    FontHandle      sheetFont;
    
    // each time you read the book ,you should create and load it
    BookHandle book = xlCreateXMLBook();
    xlBookLoad(book, [excelPath UTF8String]);
    
    int iCommandCol     = 0;
    int iResponseCol    = 0;
    int iItemSpecCol    = 0;
    int iStatesCol      = 2 ;
    int iCount = xlBookSheetCount(book); //sheet count
    int iRow = 13;//Start row

    for(int i = 0; i < iCount; i++)
    {
        sheet  = xlBookGetSheet(book,i);
        const char  * cSheetName   = xlSheetName(sheet);
        NSString    * strSheetName = [NSString stringWithUTF8String:cSheetName];
        strSheetName = [strSheetName stringByReplacingOccurrencesOfString:@" " withString:@""];
        if([[strSheetName uppercaseString] isEqualToString:[strStationName uppercaseString]])
        {
            sheetStation  = xlBookGetSheet(book,i);
            break;
        }
        else
            continue;
    }
    if (!sheetStation)
        return [NSNumber numberWithBool:NO];
    
    const char  * cState = "One";
    // find the Cols
    while (cState != nil)
    {
        NSString  * strStates = [NSString stringWithUTF8String:cState];
        strStates = [strStates stringByReplacingOccurrencesOfString:@" " withString:@""];
        if( [[strStates uppercaseString] isEqualToString:[[@"Command" stringByReplacingOccurrencesOfString:@" " withString:@""]uppercaseString]] )
            iCommandCol     = iStatesCol - 1;
        if( [[strStates uppercaseString] isEqualToString:[[@"Response(N71)" stringByReplacingOccurrencesOfString:@" " withString:@""]uppercaseString]] )
            iResponseCol    = iStatesCol - 1;
        if( [[strStates uppercaseString] isEqualToString:[[@"N71 Spec" stringByReplacingOccurrencesOfString:@" " withString:@""]uppercaseString]] )
            iItemSpecCol    = iStatesCol - 1;

        cState = xlSheetReadStr(sheetStation, iRow -3, iStatesCol, NULL);
        iStatesCol ++;
    }
    
    if(iCommandCol == 0 || iResponseCol == 0)
    {
        NSLog(@"Current Station is  %@ , TC file format error ,can't find the Col of command , please check !", strStationName);
        return [NSNumber numberWithBool:NO];
    }
    // save the book
    xlBookSave(book,  [excelPath UTF8String]);
    xlBookRelease(book);
    
    NSLog(@"Start to write data to test command and response");
    //get the command and response (include mobile and fixture) about every test item in the UartLog
    iAllCount = [arrData count];
    for(int i = 0 ; i < [arrData count]; i++)
    {
        iCurrentItem   = i;
        [self runProgress];
        BookHandle newBook = xlCreateXMLBook();
        // reload the book
        xlBookLoad(newBook, [excelPath UTF8String]);
        SheetHandle     newSheet;
        SheetHandle     newSheetStation   = nil;
        
        for(int j = 0; j < iCount; j++)
        {
            newSheet  = xlBookGetSheet(newBook,j);
            const char  * cSheetName   = xlSheetName(newSheet);
            NSString    * strSheetName = [NSString stringWithUTF8String:cSheetName];
            strSheetName = [strSheetName stringByReplacingOccurrencesOfString:@" " withString:@""];
            if([[strSheetName uppercaseString] isEqualToString:[strStationName uppercaseString]])
            {
                newSheetStation  = xlBookGetSheet(newBook,j);
                break;
            }
            else
                continue;
        }
        NSArray *arrTestItemData    = [[arrData objectAtIndex:i]objectForKey:@"Item/Command"];
        NSString  *strTestItemName  = @"";
        NSString  *strItemSpec      = @"";
        strTestItemName = [[arrData objectAtIndex:i]objectForKey:@"Item"];
        //spec
        strItemSpec = [[arrData objectAtIndex:i]objectForKey:@"SPEC"];
        if(strItemSpec == nil)
        {
            strItemSpec = @"NA";
        }
#if DEBUG
        NSLog(@"Item:%@, spec:%@",strTestItemName,strItemSpec);
#endif
        NSDictionary *dicWritingData    = [self dealData:arrTestItemData];//get the data to excel writing

        //1. set font
        sheetFont = xlBookAddFont(newBook, 0);
        xlFontSetName(sheetFont, [@"Arial" cStringUsingEncoding:NSUTF8StringEncoding]);
        //2. cell format
        sheetFormat = xlBookAddFormat(newBook, 0);
        xlFormatSetFont(sheetFormat, sheetFont);
        xlFormatSetWrap(sheetFormat,1);
        xlFormatSetBorder(sheetFormat, BORDERSTYLE_THIN);
        xlFormatSetAlignH(sheetFormat, ALIGNH_LEFT);//set horizontal(-)
        xlFormatSetAlignV(sheetFormat, ALIGNV_TOP);//set vertical(|)
        
        
        FormatHandle    statusFormat = xlSheetCellFormatA(newSheetStation, iStatusRow, iStatusCol);
        // if the test item in the UatrLog is equal to the TC's test item  , write to the TC file
        for(NSString * strTCtestName in  arrTestItems)
        {
            int m = (int)[arrTestItems indexOfObject:strTCtestName];
            if([[strTCtestName uppercaseString] isEqualToString:[strTestItemName uppercaseString]])
            {
                xlSheetWriteStr(newSheetStation, m+iRow, iCommandCol, [[dicWritingData objectForKey:@"Command"]  UTF8String], sheetFormat);
                xlSheetWriteStr(newSheetStation, m+iRow, iResponseCol, [[dicWritingData objectForKey:@"Response"]  UTF8String], sheetFormat);
                if (0 != iItemSpecCol)
                    xlSheetWriteStr(newSheetStation, m+iRow, iItemSpecCol, [strItemSpec UTF8String], sheetFormat);
                    xlSheetWriteStr(newSheetStation, m+iRow, iItemSpecCol-1, [strStatus UTF8String], statusFormat);
                break;
            }
        }
        
        // save the book
        xlBookSave(newBook,  [excelPath UTF8String]);
        xlBookRelease(newBook);
    }
    NSLog(@"End write command and response");
    return [NSNumber numberWithBool:YES];
}


-(NSNumber *)checkTestCoverage:(NSString *)excelPath
                    forStation:(NSString *)stationName
                   withSetting:(NSDictionary *)dicSetting
{
#if DEBUG
    NSLog(@"Starting check TestCoverage file...");
#endif
    //get the sheet handle and book handle to edit the TC
    SheetHandle     sheet;
    SheetHandle     sheetStation   = nil;
    BookHandle      book;
    
    // save the test item  in the test coverage file
    NSMutableArray  *arrTCtestItemAll   = [[NSMutableArray alloc] init];
    NSArray         *aryLogItems        = [dicSetting objectForKey:@"logItems"];
    NSString        *strStationName     = [stationName stringByReplacingOccurrencesOfString:@" " withString:@""];//get the station name
    excelPath   = [excelPath contains:@"file://"]?[excelPath SubFrom:@"file://" include:NO]:excelPath;
    
    //each time you read the book ,you should create it
    book = xlCreateXMLBook();
    //if the excel file does not exist, create it
    NSFileManager	*fileManager	= [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:excelPath])
    {
#if DEBUG
        NSLog(@"Starting create TestCoverage file...--(TBC)");
#endif
//        [fileManager createFileAtPath:excelPath contents:nil attributes:nil];
//        // each time you read the book ,you should load it
//        xlBookLoad(book, [excelPath UTF8String]);
//        sheet  = xlBookGetSheetA(book,0);
//        xlSheetSetNameA(sheet, [strStationName cStringUsingEncoding:NSUTF8StringEncoding]);
#if DEBUG
        NSLog(@"End create TestCoverage file--(TBC)");
#endif
    }
    else
    {
        // each time you read the book ,you should load it
        xlBookLoad(book, [excelPath UTF8String]);
    }

#if DEBUG
    NSLog(@"Starting check the sheet of the station...");
#endif
    int iCount = xlBookSheetCount(book); //sheet count
    //get the sheet  by catched the Station name from UartLog
    for(int i = 0; i < iCount; i++)
    {
       sheet  = xlBookGetSheet(book,i);
        const char  * cSheetName   = xlSheetName(sheet);
        NSString    * strSheetName = [NSString stringWithUTF8String:cSheetName];
        strSheetName = [strSheetName stringByReplacingOccurrencesOfString:@" " withString:@""];
        if([[strSheetName uppercaseString] isEqualToString:[strStationName uppercaseString]])
        {
            sheetStation  = xlBookGetSheet(book,i);
            break;
        }
        else if(i != iCount-1)
            continue;
        else
        {
            const char  * cSheetName = [strStationName cStringUsingEncoding:NSUTF8StringEncoding];
            xlBookAddSheet(book, cSheetName, nil);
            sheetStation  = xlBookGetSheet(book,i+1);
            break;
        }
    }
#if DEBUG
    NSLog(@"End check the sheet of the station");
#endif
    //replace the sheet with TestCoverage model
    [self createTestCoverageModelforSheet:sheetStation ofBook:book];
    // save the book
    xlBookSave(book,  [excelPath UTF8String]);

    int iStartRow   = 13;//Item start row
    int iEndRow     = xlSheetLastRow(sheetStation);
    int iStartCol   = 2;//Item start col
    int iEndCol     = xlSheetLastCol(sheetStation);
    
    xlSheetSetCol(sheetStation, iStartCol-1, iStartCol-1, 15.0, nil, 0);
    xlSheetSetCol(sheetStation, iStartCol, iStartCol, 30.0, nil, 0);
    xlSheetSetCol(sheetStation, iStartCol+1, iStartCol+1, 18.0, nil, 0);
    xlSheetSetCol(sheetStation, iStartCol+2, iStartCol+2, 10.0, nil, 0);
    xlSheetSetCol(sheetStation, iStartCol+3, iStartCol+3, 15.0, nil, 0);
    xlSheetSetCol(sheetStation, iStartCol+4, iStartCol+5, 30.0, nil, 0);
    xlSheetSetCol(sheetStation, iStartCol+6, iStartCol+6, 15.0, nil, 0);


    //1. set font
    FontHandle itemFont = xlBookAddFont(book, 0);
    xlFontSetBold(itemFont, 0);
    xlFontSetName(itemFont, [@"Arial" cStringUsingEncoding:NSUTF8StringEncoding]);
    //cell format
    FormatHandle itemFormat = [self newFormatForBook:book
                                            withFont:itemFont
                                         borderStyle:BORDERSTYLE_THIN
                                    horizontalAlignh:ALIGNH_LEFT
                                      verticalAlignv:ALIGNV_CENTER
                                     backgroundColor:COLOR_WHITE];

    xlSheetRemoveRow(sheetStation, iStartRow, iEndRow); //clear the sheet first
    NSString * strTest = nil;
    for (int i = 0 ; i<[aryLogItems count]; i++)
    {
        strTest = [aryLogItems objectAtIndex:i];
        //write item name to sheet
        xlSheetWriteStr(sheetStation, iStartRow+i, iStartCol, [strTest cStringUsingEncoding:NSUTF8StringEncoding], itemFormat);
        [arrTCtestItemAll addObject:strTest];
    }

    iEndRow     = xlSheetLastRow(sheetStation);
    iEndCol     = xlSheetLastCol(sheetStation);
    xlSheetSetMerge(sheetStation, iStartRow, iEndRow-1, iStartCol-1, iStartCol-1);
    //1. set font
    FontHandle sheetFont = xlBookAddFont(book, 0);
    xlFontSetBold(sheetFont, FALSE);
    xlFontSetName(sheetFont, [@"Arial" cStringUsingEncoding:NSUTF8StringEncoding]);
    //2. cell format
    FormatHandle sheetFormat = [self newFormatForBook:book
                                             withFont:sheetFont
                                          borderStyle:BORDERSTYLE_THIN
                                     horizontalAlignh:ALIGNH_LEFT
                                       verticalAlignv:ALIGNV_CENTER
                                      backgroundColor:COLOR_WHITE];
    xlSheetSetCol(sheetStation, 0, 0, 2.0, nil, 0);
    xlSheetSetRow(sheetStation, 0, 0.5, nil, 0);//first row
    for (int i = iStartRow-1; i<iEndRow; i++)
    {
        xlSheetSetRow(sheetStation, i, 15.0, nil, 0);
        for (int j = iStartCol-1; j<iEndCol; j++)
        {
            xlSheetSetCellFormat(sheetStation, i, j, sheetFormat);
        }
    }
    
    //write station name
    //1. cell font
    FontHandle nameFont = xlBookAddFont(book, 0);
    xlFontSetBold(nameFont, TRUE);
    xlFontSetName(nameFont, [@"Arial" cStringUsingEncoding:NSUTF8StringEncoding]);
    //2. cell format
    FormatHandle nameFormat = [self newFormatForBook:book
                                            withFont:nameFont
                                         borderStyle:BORDERSTYLE_THIN
                                    horizontalAlignh:ALIGNH_CENTER
                                      verticalAlignv:ALIGNV_CENTER
                                     backgroundColor:COLOR_WHITE];
    NSString *strOverlayVersion = [NSString stringWithFormat:@"Version:%@",m_Version];
    xlSheetWriteStr(sheetStation, iStartRow-1, iStartCol-1, [strStationName UTF8String], nameFormat);
    xlSheetWriteStr(sheetStation, iStartRow-1, iStartCol, [strOverlayVersion UTF8String], sheetFormat);
    //cycle time
//    NSString *strCycleTime = [NSString stringWithFormat:@"=SUM(D%d:D%d)",iStartRow+2,iEndRow+1];
    xlSheetWriteStr(sheetStation, iStartRow-2, iStartCol+1, [@"TestTime" UTF8String], xlSheetCellFormat(sheetStation, iStartRow-3, iStartCol+1));
    xlSheetWriteStr(sheetStation, 1, 1, [[NSString stringWithFormat:@"N71 %@ Test Coverage List",strStationName] UTF8String], sheetFormat);
    //Group
    //xlSheetGroupCols(sheetStation, iStartCol, iEndCol, 0);
//    xlSheetGroupRows(sheetStation, iStartRow, iEndRow, 0);
    
#if DEBUG
    //  test item count and item name
    NSLog(@"The current station  name is : %@ . The total test item of the TC  file is : %li",strStationName, [arrTCtestItemAll count]);
    NSLog(@"Test the function:%s",xlSheetReadStr(sheetStation, iStartRow, iStartCol, NULL));
#endif
    
    // save the book
    xlBookSave(book,  [excelPath UTF8String]);
    if (!xlSheetReadStr(sheetStation, iStartRow, iStartCol, NULL))
    {
        xlBookRelease(book);
        return [NSNumber numberWithBool:NO];
    }
    xlBookRelease(book);
#if DEBUG
    NSLog(@"Ending check TestCoverage file...");
#endif
    return [NSNumber numberWithBool:YES];
}

-(NSNumber *)createTestCoverageModelforSheet:(SheetHandle)sheet ofBook:(BookHandle)book
{
#if DEBUG
    NSLog(@"Starting create TestCoverageModel...");
#endif
    //get the sheet handle and book handle to edit the TC
    SheetHandle     sheetStation   = sheet;
    int  iCol = 2 - 1;//Start column
    int  iRow = 2 - 1;//Start row

    const char  * cSheetName   = xlSheetName(sheet);
    NSString    * strSheetName = [NSString stringWithUTF8String:cSheetName];
    NSString    *strStationName= strSheetName;//get the station name
    
    //init the sheet
    xlSheetRemoveRow(sheetStation, iRow, xlSheetLastRow(sheetStation)); //clear the sheet first
    xlSheetRemoveCol(sheetStation, iCol, xlSheetLastCol(sheetStation)); //clear the col
    //1. set font
    FontHandle titleFont = xlBookAddFont(book, 0);
    FontHandle descriptionFont = xlBookAddFont(book, 0);
    xlFontSetBold(titleFont, TRUE);
    xlFontSetBold(descriptionFont, NO);
    xlFontSetName(titleFont, [@"Arial" cStringUsingEncoding:NSUTF8StringEncoding]);
    xlFontSetName(descriptionFont, [@"Arial" cStringUsingEncoding:NSUTF8StringEncoding]);
    
    //2. cell format
    FormatHandle titleFormat = [self newFormatForBook:book
                                             withFont:titleFont
                                          borderStyle:BORDERSTYLE_THIN
                                     horizontalAlignh:ALIGNH_CENTER             //set horizontal(-)
                                       verticalAlignv:ALIGNV_CENTER             //set vertical(|)
                                      backgroundColor:COLOR_LIGHTGREEN];
    
    FormatHandle descriptionFormat = [self newFormatForBook:book
                                                   withFont:descriptionFont
                                                borderStyle:BORDERSTYLE_THIN
                                           horizontalAlignh:ALIGNH_LEFT         //set horizontal(-)
                                             verticalAlignv:ALIGNV_CENTER       //set vertical(|)
                                            backgroundColor:COLOR_WHITE];
    
    //remove
    FormatHandle removeFormat = [self newFormatForBook:book
                                              withFont:titleFont
                                           borderStyle:BORDERSTYLE_THIN
                                      horizontalAlignh:ALIGNH_CENTER              //set horizontal(-)
                                        verticalAlignv:ALIGNV_CENTER            //set vertical(|)
                                       backgroundColor:COLOR_GRAY40];
    //open
    FormatHandle openFormat = [self newFormatForBook:book
                                            withFont:titleFont
                                         borderStyle:BORDERSTYLE_THIN
                                    horizontalAlignh:ALIGNH_CENTER              //set horizontal(-)
                                      verticalAlignv:ALIGNV_CENTER            //set vertical(|)
                                     backgroundColor:COLOR_RED];
    
    //TBC
    FormatHandle TBCFormat = [self newFormatForBook:book
                                           withFont:titleFont
                                        borderStyle:BORDERSTYLE_THIN
                                   horizontalAlignh:ALIGNH_CENTER              //set horizontal(-)
                                     verticalAlignv:ALIGNV_CENTER            //set vertical(|)
                                    backgroundColor:COLOR_PINK];
    
    //Ongoing
    FormatHandle OngoingFormat = [self newFormatForBook:book
                                               withFont:titleFont
                                            borderStyle:BORDERSTYLE_THIN
                                       horizontalAlignh:ALIGNH_CENTER              //set horizontal(-)
                                         verticalAlignv:ALIGNV_CENTER            //set vertical(|)
                                        backgroundColor:COLOR_YELLOW];
    
    //Validation
    FormatHandle validationFormat = [self newFormatForBook:book
                                                  withFont:titleFont
                                               borderStyle:BORDERSTYLE_THIN
                                          horizontalAlignh:ALIGNH_CENTER              //set horizontal(-)
                                            verticalAlignv:ALIGNV_CENTER            //set vertical(|)
                                           backgroundColor:COLOR_LIGHTGREEN];
    
    //Colse
    FormatHandle closeFormat = [self newFormatForBook:book
                                             withFont:titleFont
                                          borderStyle:BORDERSTYLE_THIN
                                     horizontalAlignh:ALIGNH_CENTER              //set horizontal(-)
                                       verticalAlignv:ALIGNV_CENTER            //set vertical(|)
                                      backgroundColor:COLOR_BRIGHTGREEN];
    
    //Cyccle time
    FormatHandle cycleFormat = [self newFormatForBook:book
                                             withFont:titleFont
                                          borderStyle:BORDERSTYLE_THIN
                                     horizontalAlignh:ALIGNH_CENTER              //set horizontal(-)
                                       verticalAlignv:ALIGNV_CENTER            //set vertical(|)
                                      backgroundColor:COLOR_WHITE];
    
    //3. write string to cell
    xlSheetWriteStr(sheetStation, iRow+9, iCol, [@"Test Station" cStringUsingEncoding:NSUTF8StringEncoding], titleFormat);
    xlSheetWriteStr(sheetStation, iRow+9, iCol+1, [@"Test Items" cStringUsingEncoding:NSUTF8StringEncoding], titleFormat);
    xlSheetWriteStr(sheetStation, iRow+9, iCol+2, [@"N71TT(s)" cStringUsingEncoding:NSUTF8StringEncoding], titleFormat);
    xlSheetWriteStr(sheetStation, iRow+10,iCol+2, [@"TestCycleTime" cStringUsingEncoding:NSUTF8StringEncoding], titleFormat);
    xlSheetWriteStr(sheetStation, iRow+9, iCol+3, [@"Status" cStringUsingEncoding:NSUTF8StringEncoding], titleFormat);
    xlSheetWriteStr(sheetStation, iRow+9, iCol+4, [@"N71 Spec" cStringUsingEncoding:NSUTF8StringEncoding], titleFormat);
    xlSheetWriteStr(sheetStation, iRow+9, iCol+5, [@"Command" cStringUsingEncoding:NSUTF8StringEncoding], titleFormat);
    xlSheetWriteStr(sheetStation, iRow+9, iCol+6, [@"Response(N71)" cStringUsingEncoding:NSUTF8StringEncoding], titleFormat);
    xlSheetWriteStr(sheetStation, iRow+9, iCol+7, [@"Remark" cStringUsingEncoding:NSUTF8StringEncoding], titleFormat);
    
    xlSheetWriteStr(sheetStation, iRow, iCol, [[NSString stringWithFormat:@"N71 %@ Test Coverage List",strStationName] cStringUsingEncoding:NSUTF8StringEncoding], descriptionFormat);
    xlSheetWriteStr(sheetStation, iRow+1, iCol, [@"Removed" cStringUsingEncoding:NSUTF8StringEncoding], removeFormat);
    xlSheetWriteStr(sheetStation, iRow+2, iCol, [@"Open" cStringUsingEncoding:NSUTF8StringEncoding], openFormat);
    xlSheetWriteStr(sheetStation, iRow+3, iCol, [@"TBC" cStringUsingEncoding:NSUTF8StringEncoding], TBCFormat);
    xlSheetWriteStr(sheetStation, iRow+4, iCol, [@"Ongoing" cStringUsingEncoding:NSUTF8StringEncoding], OngoingFormat);
    xlSheetWriteStr(sheetStation, iRow+5, iCol, [@"Validation" cStringUsingEncoding:NSUTF8StringEncoding], validationFormat);
    xlSheetWriteStr(sheetStation, iRow+6, iCol, [@"Close" cStringUsingEncoding:NSUTF8StringEncoding], closeFormat);
    xlSheetWriteStr(sheetStation, iRow+7, iCol, [@"Cycle Time" cStringUsingEncoding:NSUTF8StringEncoding], cycleFormat);
    
    xlSheetWriteStr(sheetStation, iRow+1, iCol+1, [@"Disabled items based on latest SW / Non POR Station" cStringUsingEncoding:NSUTF8StringEncoding], descriptionFormat);
    xlSheetWriteStr(sheetStation, iRow+2, iCol+1, [@"No Start" cStringUsingEncoding:NSUTF8StringEncoding], descriptionFormat);
    xlSheetWriteStr(sheetStation, iRow+3, iCol+1, [@"TBC" cStringUsingEncoding:NSUTF8StringEncoding], descriptionFormat);
    xlSheetWriteStr(sheetStation, iRow+4, iCol+1, [@"Ongoing" cStringUsingEncoding:NSUTF8StringEncoding], descriptionFormat);
    xlSheetWriteStr(sheetStation, iRow+5, iCol+1, [@"Waiting for Validation" cStringUsingEncoding:NSUTF8StringEncoding], descriptionFormat);
    xlSheetWriteStr(sheetStation, iRow+6, iCol+1, [@"OK for Build" cStringUsingEncoding:NSUTF8StringEncoding], descriptionFormat);
    xlSheetWriteStr(sheetStation, iRow+7, iCol+1, [@"" cStringUsingEncoding:NSUTF8StringEncoding], descriptionFormat);
    
    xlSheetWriteStr(sheetStation, iRow+1, iCol+4, [@"DRI1" cStringUsingEncoding:NSUTF8StringEncoding], titleFormat);
    xlSheetSetCellFormat(sheetStation, iRow+2, iCol+4, titleFormat);
    xlSheetWriteStr(sheetStation, iRow+3, iCol+4, [@"DRI2" cStringUsingEncoding:NSUTF8StringEncoding], titleFormat);
    xlSheetSetCellFormat(sheetStation, iRow+4, iCol+4, titleFormat);
    
    
    //4. Merge the cell
    xlSheetSetMerge(sheetStation, iRow+9, iRow+10, iCol, iCol);
    xlSheetSetMerge(sheetStation, iRow+9, iRow+10, iCol+1, iCol+1);
    xlSheetSetMerge(sheetStation, iRow+9, iRow+10, iCol+3, iCol+3);
    xlSheetSetMerge(sheetStation, iRow+9, iRow+10, iCol+4, iCol+4);
    xlSheetSetMerge(sheetStation, iRow+9, iRow+10, iCol+5, iCol+5);
    xlSheetSetMerge(sheetStation, iRow+9, iRow+10, iCol+6, iCol+6);
    xlSheetSetMerge(sheetStation, iRow+9, iRow+10, iCol+7, iCol+7);
    
    xlSheetSetMerge(sheetStation, iRow+1, iRow+2, iCol+4, iCol+4);//DRI
    xlSheetSetMerge(sheetStation, iRow+3, iRow+4, iCol+4, iCol+4);//DRI
    xlSheetSetMerge(sheetStation, iRow+1, iRow+2, iCol+5, iCol+6);//DRI
    xlSheetSetMerge(sheetStation, iRow+3, iRow+4, iCol+5, iCol+6);//DRI
    //5. Hiding the col @"N71TT(s)"
    //        xlSheetSetColHidden(sheetStation, iCol+1, TRUE);
    
    for (int i = iRow+9; i<=iRow+10; i++)
    {
        for (int j = iCol; j<= iCol+7; j++)
        {
            xlSheetSetCellFormat(sheetStation, i, j, titleFormat);
        }
    }
    
    for (int i = iRow+1; i<=iRow+4; i++)
    {
        for (int j = iCol+5; j<= iCol+6; j++)
        {
            xlSheetSetCellFormat(sheetStation, i, j, descriptionFormat);
        }
    }
    NSLog(@"End create TestCoverageModel.");
    return [NSNumber numberWithBool:YES];
}

-(FormatHandle)newFormatForBook:(BookHandle)book
                       withFont:(FontHandle)font
                    borderStyle:(enum BorderStyle)borderStyle
               horizontalAlignh:(enum AlignH)horizontal
                 verticalAlignv:(enum AlignV)vertical
                backgroundColor:(enum Color)backgroundColor
{
    FormatHandle newFormat = xlBookAddFormat(book, 0);
    xlFormatSetFont(newFormat, font);//set font
    xlFormatSetAlignH(newFormat, horizontal);//set horizontal(-)
    xlFormatSetAlignV(newFormat, vertical);//set vertical(|)
    xlFormatSetBorder(newFormat, borderStyle);//set border
    xlFormatSetFillPattern(newFormat, FILLPATTERN_SOLID);//set pattern
    xlFormatSetPatternForegroundColor(newFormat, backgroundColor);//set color
    return newFormat;
}

-(NSDictionary *)dealData:(NSArray *)data
{
    NSString *strSendComamnd    = @"";
    NSString *strReadCommand    = @"";
    for(int j = 0 ; j < [data count]; j++)
    {
        NSString *strSendCMD    = @"";
        NSString *strReadCMD    = @"";
        NSString *strTarget = [[data objectAtIndex:j]objectForKey:@"Target"];
        strSendCMD = [NSString stringWithFormat:@"%@",[[data objectAtIndex:j]objectForKey:@"Command"]];
        if([strSendCMD isNotEqualTo:@""] && [strSendCMD isNotEqualTo:@"\n"])
        {
            strSendComamnd = [strSendComamnd stringByAppendingString:@"\n"];
            if ([strTarget isNotEqualTo:@"MOBILE"])
                strSendComamnd = [strSendComamnd stringByAppendingString:[NSString stringWithFormat:@"\n[%@]:",strTarget]];
            strSendComamnd = [strSendComamnd stringByAppendingString:strSendCMD];
            if ([strTarget isNotEqualTo:@"MOBILE"])
                strSendComamnd = [strSendComamnd stringByAppendingString:@"\n"];
            
            strReadCMD = [NSString stringWithFormat:@"%@",[[data objectAtIndex:j]objectForKey:@"ReadCommand"]];
            if (strReadCMD == nil || [strReadCMD isEqualToString:@""])
            {
                strReadCMD = @"{NA}";
            }
            strReadCommand = [strReadCommand stringByAppendingString:@"\n"];
            if ([strTarget isNotEqualTo:@"MOBILE"])
                strReadCommand = [strReadCommand stringByAppendingString:[NSString stringWithFormat:@"\n[%@]:",strTarget]];
            if([strTarget isNotEqualTo:@"MIKEY"] && ![strReadCMD containsCharacter:27])//check the
                strReadCommand = [strReadCommand stringByAppendingString:strReadCMD];
            else
            {
                for (int i = 0; i<[strReadCMD length]; i++)
                {
                    strReadCMD = [strReadCMD stringByReplacingOccurrencesOfString:@"[0;31m" withString:@""];
                    strReadCMD = [strReadCMD stringByReplacingOccurrencesOfString:@"[0m" withString:@""];
                    NSString *string = [NSString stringWithFormat:@"%d",[strReadCMD characterAtIndex:i]];
                    NSString *old    = [NSString stringWithFormat:@"%c",[strReadCMD characterAtIndex:i]];
                    if ([string intValue]==13 || [string intValue] == 27)
                    {
                        old = [old stringByReplacingOccurrencesOfString:old withString:@"\n"];
                    }
                    strReadCommand = [strReadCommand stringByAppendingString:old];
                }
                NSLog(@"%@",strReadCommand);
            }
            if ([strTarget isNotEqualTo:@"MOBILE"])
                strReadCommand = [strReadCommand stringByAppendingString:@"\n"];
            strReadCommand = [strReadCommand stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"];
            strReadCommand = [strReadCommand stringByReplacingOccurrencesOfString:@"\n\r" withString:@"\n"];
            strReadCommand = [strReadCommand stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
        }
    }
    return [NSDictionary dictionaryWithObjectsAndKeys:
            strSendComamnd,  @"Command",
            strReadCommand,  @"Response",nil];
}

-(void)runProgress
{
    [m_lineProgress setMinValue:0];
    [m_lineProgress setMaxValue:iAllCount];
    [m_lineProgress setIntegerValue:iCurrentItem+1];
    [m_textProgress setStringValue:[NSString stringWithFormat:@"%.0f%%",(float)(iCurrentItem + 1) * 100 / iAllCount]];
}

#pragma mark -
#pragma mark Unused methods below
-(NSNumber *)writeString:(NSString *)str
                 toExcel:(NSString *)strPath
              withFormat:(FormatHandle)format
              andSetting:(NSDictionary *)dicSetting
{
    //get the sheet handle and row, col
    SheetHandle sheetStation = (__bridge SheetHandle)([dicSetting objectForKey:@"sheet"]);
    int iRow    = (int)[dicSetting objectForKey:@"row"];
    int iCol    = (int)[dicSetting objectForKey:@"col"];
    
    //each time you read the book ,you should create and load it
    BookHandle book = xlCreateXMLBook();
    xlBookLoad(book, [strPath UTF8String]);
    
    if (sheetStation != nil && str != nil && [str isNotEqualTo:@""])
    {
        //write string to excel cell
        xlSheetWriteStr(sheetStation, iRow, iCol, [str cStringUsingEncoding:NSUTF8StringEncoding], format);
    }
    // save the book
    xlBookSave(book,  [strPath UTF8String]);
    xlBookRelease(book);
    return [NSNumber numberWithDouble:YES];
}

-(NSDictionary *)findString:(NSString *)strData
                    inSheet:(SheetHandle)sheet
{
    int iRow;
    int iCol;
    int iStatesRow = 0;
    int iStatesCol = 0;
    const char  *cState = nil;
    do
    {
        cState = xlSheetReadStr(sheet, iStatesRow, iStatesCol, NULL);
        if (cState)
        {
            NSString  * strStates = [NSString stringWithUTF8String:cState];
            NSLog(@"%@",strStates);
            strStates = [strStates stringByReplacingOccurrencesOfString:@" " withString:@""];
            if([[strStates uppercaseString] isEqualToString:[[strData stringByReplacingOccurrencesOfString:@" " withString:@""]uppercaseString]])
            {
                iRow    = iStatesRow;
                iCol    = iStatesCol;
                return [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSString stringWithFormat:@"%d",iRow],@"row",
                        [NSString stringWithFormat:@"%d",iCol],@"col",nil];
            }
        }
        
        do
        {
            cState = xlSheetReadStr(sheet, iStatesRow, iStatesCol, NULL);
            if (cState)
            {
                NSString  * strStates = [NSString stringWithUTF8String:cState];
                NSLog(@"%@",strStates);
                strStates = [strStates stringByReplacingOccurrencesOfString:@" " withString:@""];
                if([[strStates uppercaseString] isEqualToString:[[strData stringByReplacingOccurrencesOfString:@" " withString:@""]uppercaseString]])
                {
                    iRow    = iStatesRow;
                    iCol    = iStatesCol;
                    return [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%d",iRow],@"row",
                            [NSString stringWithFormat:@"%d",iCol],@"col",nil];
                }
            }
            iStatesRow ++;
        }while (iStatesRow <= xlSheetLastRow(sheet));
        
        iStatesCol ++;
    }while (iStatesCol<=xlSheetLastCol(sheet));
    return nil;
}


-(void)writeData:(NSMutableArray *)data ToExcelFile:(NSURL *)url unitStatus:(id)checkUnitButton fixtureStatus:(id)checkFixtureButton testCoverageStatus:(id)checkTestCoverageButton stationStatus:(NSString *)status
{
    NSMutableString *szAllCmd   = [NSMutableString string];
    //save mobile command and spec
    if (([checkUnitButton state] == 1) && (0 != [data count]))
    {
        [szAllCmd setString:@""];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        //        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        NSMutableString *currentTime = [[NSMutableString alloc] init];
        //        [currentTime appendString:[dateFormatter stringFromDate:[NSDate date]]];
        //        dateFormatter = [NSDateFormatter new];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        //        [currentTime appendString:@"_"];
        [currentTime appendString:[dateFormatter stringFromDate:[NSDate date]]];
        NSMutableString *szBuffer   = [NSMutableString string];
        //        NSString    *strExcelPath   = [NSString stringWithFormat:@"%@/TestCoverage_%@.xls",url,currentTime];
        //        strExcelPath = [strExcelPath stringByExpandingTildeInPath];
        //        NSURL *excelFileURL = [NSURL fileURLWithPath:strExcelPath];
        NSString        *strTitle   = [NSString stringWithFormat:@"<tr><td style=\"font-size:12px; font-family:Arial; vertical-align: middle; font-weight:bold; background:#98FB98;\" width=\"205\" height=\"35\">Test Items</td><td style=\"font-size:12px; font-family:Arial; vertical-align: middle; font-weight:bold; background:#98FB98;\" width=\"65\">Status</td><td style=\"font-size:12px; font-family:Arial; vertical-align: middle; font-weight:bold; background:#98FB98;\" width=\"75\">N71 Spec</td><td style=\"font-size:12px; font-family:Arial; vertical-align: middle; font-weight:bold; background:#98FB98;\" width=\"405\">Command</td><td style=\"font-size:12px; font-family:Arial; vertical-align: middle; font-weight:bold; background:#98FB98;\" width=\"405\">Response(N71)</td></tr>"];
        for(int i = 0; i < [data count]; i++)
        {
            NSMutableString    *szItemName      = [[NSMutableString alloc] init];
            NSMutableString    *szCommands      = [[NSMutableString alloc] init];
            NSMutableString    *szSpec          = [[NSMutableString alloc] init];
            NSMutableString    *szReadCommand   = [[NSMutableString alloc] init];
            if(nil  != [[data objectAtIndex:i] objectForKey:@"Item"])
                [szItemName setString:[[data objectAtIndex:i] objectForKey:@"Item"]];
            for (int j = 0; j<[[[data objectAtIndex:i] objectForKey:@"Item/Command"] count]; j++)
            {
                if ([checkTestCoverageButton state] != 1)
                {
                    if (0 != [[[data objectAtIndex:i] objectForKey:@"Item/Command"] count]
                        && [[[[[data objectAtIndex:i] objectForKey:@"Item/Command"] objectAtIndex:j] objectForKey:@"Target"] isEqualToString:@"MOBILE"])
                    {
                        //command
                        NSString    *strCommand = [[[[data objectAtIndex:i] objectForKey:@"Item/Command"] objectAtIndex:j] objectForKey:@"Command"];
                        [szCommands appendString:[NSString stringWithFormat:@"%@<br/>", strCommand]];
                        //read command
                        NSString    *strReadCommand = [[[[data objectAtIndex:i] objectForKey:@"Item/Command"] objectAtIndex:j] objectForKey:@"ReadCommand"];
                        //                        strReadCommand = [strReadCommand stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
                        [szReadCommand appendString:[NSString stringWithFormat:@"%@<br/>",strReadCommand]];
                    }
                }
                else
                {
                    if (0 != [[[data objectAtIndex:i] objectForKey:@"Item/Command"] count])
                    {
                        //command
                        NSString    *strCommand = [[[[data objectAtIndex:i] objectForKey:@"Item/Command"] objectAtIndex:j] objectForKey:@"Command"];
                        //                        strCommand  = [NSString stringWithFormat:@"[%@]:%@",[[[[data objectAtIndex:i] objectForKey:@"Item/Command"] objectAtIndex:j] objectForKey:@"Target"],strCommand];
                        if ([[[[[data objectAtIndex:i] objectForKey:@"Item/Command"] objectAtIndex:j] objectForKey:@"Target"] isEqualToString:@"FIXTURE"] || [[[[[data objectAtIndex:i] objectForKey:@"Item/Command"] objectAtIndex:j] objectForKey:@"Target"] isEqualToString:@"MIKEY"])
                        {
                            strCommand = [NSString stringWithFormat:@"<span style=\"color:blue\" datafld=\"type\">%@</span>", strCommand];
                        }
                        [szCommands appendString:[NSString stringWithFormat:@"%@<br/>", strCommand]];
                        //read command
                        NSString    *strReadCommand = [[[[data objectAtIndex:i] objectForKey:@"Item/Command"] objectAtIndex:j] objectForKey:@"ReadCommand"];
                        //                        strReadCommand = [strReadCommand stringByReplacingOccurrencesOfString:@"\n" withString:@"doEnter"];
                        [szReadCommand appendString:[NSString stringWithFormat:@"%@<br/>",strReadCommand]];
                    }
                }
            }
            if (nil != [[data objectAtIndex:i] objectForKey:@"SPEC"])
            {
                [szSpec  setString:[[data objectAtIndex:i] objectForKey:@"SPEC"]];
                if ([szSpec contains:@"<"])
                {
                    [szSpec replaceOccurrencesOfString:@"<"
                                            withString:@"&#60;"
                                               options:NSCaseInsensitiveSearch
                                                 range:NSMakeRange(0, [szSpec length])];
                    
                }
                if ([szSpec contains:@">"])
                {
                    [szSpec replaceOccurrencesOfString:@">"
                                            withString:@"&#62;"
                                               options:NSCaseInsensitiveSearch
                                                 range:NSMakeRange(0, [szSpec length])];
                }
            }
            else
                [szSpec setString:@"N/A"];
            //style=\"word-wrap: break-word; white-space:nowrap=false;\"
            //            [szBuffer appendString:[NSString stringWithFormat:@"<tr class=xl65 height=45 style='height:45.0pt'><td style=\"font-size:12px; font-family:Arial; vertical-align: middle;\">%@</td><td style=\"font-size:10px; font-family:Arial; vertical-align: middle; background:%@; font-weight:bold;\">%@</td><td style=\"font-size:12px; font-family:Arial; vertical-align: middle;\">%@</td><td style=\"font-size:12px; font-family:Arial; vertical-align: middle;\"><div>%@</div></td><td class=xl69 style=\"font-size:12px; font-family:Arial; vertical-align: middle;\">%@</td></tr>",szItemName,[m_dicStationStatus objectForKey:status],status,szSpec,szCommands,szReadCommand]];
            [szBuffer appendString:[NSString stringWithFormat:@"<tr class=xl65 height=45 style='height:45.0pt'><td style=\"font-size:12px; font-family:Arial; vertical-align: middle;\">%@</td><td style=\"font-size:10px; font-family:Arial; vertical-align: middle; background:%@; font-weight:bold;\">%@</td><td style=\"font-size:12px; font-family:Arial; vertical-align: middle;\">%@</td><td style=\"font-size:12px; font-family:Arial; vertical-align: middle;\"><div>%@</div></td><td class=xl69 style=\"font-size:12px; font-family:Arial; vertical-align: middle;\">nil</td></tr>",szItemName,[m_dicStationStatus objectForKey:status],status,szSpec,szCommands]];
        }
        
        [szAllCmd appendString:[NSString stringWithFormat:@"<table align=\"center\" colspan=\"0\" border=\"1\" style=\"font-size: 13px\">%@%@</table></body>",strTitle,szBuffer]];
        [szAllCmd writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:nil];
        usleep(1000);
    }
    
    //save fixture command
    if (([checkFixtureButton state] == 1) && (0 != [data count]))
    {
        [szAllCmd setString:@""];
        NSMutableString *szBuffer   = [[NSMutableString alloc] init];
        NSString    *strTitle       = [NSString stringWithFormat:@"<tr><td style=\"font-size:12px; font-family:Arial; vertical-align: middle; font-weight:bold;\" width=\"205\">Test Items</td><td style=\"font-size:12px; font-family:Arial; vertical-align: middle; font-weight:bold;\" width=\"205\">Fixture Command</td></tr>"];
        //        NSString    *strExcelPath   = @"~/Desktop/FixtureCommand.xls";
        //        strExcelPath = [strExcelPath stringByExpandingTildeInPath];
        //        NSURL *excelFileURL = [NSURL fileURLWithPath:strExcelPath];
        for(int i = 0; i < [data count]; i++)
        {
            NSMutableString    *szItemName  = [[NSMutableString alloc] init];
            NSMutableString    *szCommands  = [[NSMutableString alloc] init];
            if(nil  != [[data objectAtIndex:i] objectForKey:@"Item"])
                [szItemName setString:[[data objectAtIndex:i] objectForKey:@"Item"]];
            for (int j = 0; j<[[[data objectAtIndex:i] objectForKey:@"Item/Command"] count]; j++)
            {
                if (0 != [[[data objectAtIndex:i] objectForKey:@"Item/Command"] count]
                    && ([[[[[data objectAtIndex:i] objectForKey:@"Item/Command"] objectAtIndex:j] objectForKey:@"Target"] isEqualToString:@"FIXTURE"]|| [[[[[data objectAtIndex:i] objectForKey:@"Item/Command"] objectAtIndex:j] objectForKey:@"Target"] isEqualToString:@"MIKEY"]))
                {
                    NSString    *strCommand = [[[[data objectAtIndex:i] objectForKey:@"Item/Command"] objectAtIndex:j] objectForKey:@"Command"];
                    [szCommands appendString:[NSString stringWithFormat:@"%@<br/>", strCommand]];
                }
            }
            
            [szBuffer appendString:[NSString stringWithFormat:@"<tr><td style=\"font-size:12px; font-family:Arial; vertical-align: middle;\">%@</td><td style=\"font-size:12px; font-family:Arial; vertical-align: middle;\"><div>%@</div></td></tr>",szItemName,szCommands]];
        }
        
        [szAllCmd appendString:[NSString stringWithFormat:@"<table align=\"center\" colspan=\"0\" border=\"1\" style=\"font-size: 13px\">%@%@</table>",strTitle,szBuffer]];
        [szAllCmd writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:nil];
        usleep(1000);
    }
}

@end





