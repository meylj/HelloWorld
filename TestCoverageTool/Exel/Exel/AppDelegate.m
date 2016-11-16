//
//  AppDelegate.m
//  FIieRead
//
//  Created by Jane6_Chen on 15/8/12.
//  Copyright (c) 2015年 ykj. All rights reserved.
//

#import "AppDelegate.h"
#include "LibXL/libxl.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

-(id)init
{
    self = [super init];                                    //释放空间
    if (self) {
        strfilestring = [[NSMutableString alloc]init];
        m_datasource = [[tabledatasource alloc]init];
        m_file = [[NSMutableString alloc]init];
        t_textfield = [[NSMutableString alloc]init];
        m_strStationName = [[NSMutableString alloc] init];
        m_orgary = [[NSMutableArray alloc]init];
        m_neededdata = [[NSMutableArray alloc]init];
        name_and_time = [[NSMutableArray alloc]init];
        boolLoadCSV = NO;
    }
    return self;
}

-(void)awakeFromNib
{
    NSRect Copy = NSMakeRect(420, 519, 73, 32);
    NSButton *btnCopy = [[NSButton alloc]initWithFrame:Copy];
    [m_view addSubview:btnCopy];
    [btnCopy setTitle:@"Detail"];
    NSFont *font = [NSFont fontWithName:@"Lucida Grande" size:13.0];
    [btnCopy setFont:font];
    [btnCopy setBezelStyle:NSThickerSquareBezelStyle];
    [nf setState:1];
    [of setState:0];
    [OnlyMobile setState:1];
    [OnlyFixture setState:1];
    [Separate setState:1];
//    [btnCopy setAction:@selector(presscopy:)];
}

-(IBAction)MobileorFixture:(id)sender
{
    BOOL ischoosemobile;
    BOOL ischoosefixture;
    ischoosefixture = [OnlyFixture state];
    ischoosemobile = [OnlyMobile state];
    [m_datasource.m_showdata removeAllObjects];
    if (ischoosemobile&&!ischoosefixture) {
        for (int i = 0; i<[m_neededdata count]; i++) {
            if ([[[m_neededdata objectAtIndex:i]objectForKey:@"Target"]isEqualToString:@"MOBILE"]||[[[m_neededdata objectAtIndex:i]objectForKey:@"Target"]isEqualToString:@"TASK"]) {
                [m_datasource.m_showdata addObject:[m_neededdata objectAtIndex:i]];
            }
                 else
                 {
                     
                 }
        }
        [m_tableview reloadData];
    }
    if (ischoosefixture&&!ischoosemobile) {
        for (int i = 0; i<[m_neededdata count]; i++) {
            if ([[[m_neededdata objectAtIndex:i]objectForKey:@"Target"]isEqualToString:@"FIXTURE"]) {
                [m_datasource.m_showdata addObject:[m_neededdata objectAtIndex:i]];
            }
            else
            {
                
            }
        }
        [m_tableview reloadData];
    }
    if (ischoosemobile&&ischoosefixture) {
        m_datasource.m_showdata = [m_neededdata mutableCopy];
        [m_tableview reloadData];
    }
    else
    {
        [m_tableview reloadData];
    }
    
}


- (IBAction)createExcel:(id)sender
{
    BOOL xlsMode = [[excelFormat selectedCell] tag];
    BOOL ischoosento;
    BOOL ischooseotn;
    BOOL isseparated;
    NSLog(@"createExcel: %@ mode", xlsMode ? @"xls" : @"xlsx");
    
    FontHandle fixturefont;
    FontHandle titleFont;
    FontHandle boldFont;
    FontHandle redfont;
    FontHandle palebluefont;
    FormatHandle titleFormat;
    FormatHandle headerFormat;
    FormatHandle descriptionFormat;
    FormatHandle commandandresponseFormat;
    FormatHandle amountFormat;
    FormatHandle totalLabelFormat;
    FormatHandle totalFormat;
    FormatHandle signatureFormat;
    FormatHandle descriptionchangeFormat;
    FormatHandle deleteFormat;
    FormatHandle fixtureFormat;
    FormatHandle greenformat;
    FormatHandle greenstatusformat;
    FormatHandle yellowformat;
    FormatHandle redformat;
    FormatHandle deepredformat;
    FormatHandle deepredformat1;
    FormatHandle purpleformat;
    FormatHandle paleblueformat;
    FormatHandle titleFormat1;
    
    SheetHandle sheet;
    BookHandle book;
    ischoosento = [nf state];
    ischooseotn = [of state];
    isseparated = [Separate state];
    if (ischooseotn&&ischoosento) {
        NSAlert *alert  = [NSAlert alertWithError:[NSError errorWithDomain:@"大兄弟你不要逗我就算是💩，也要一口一口吃的对不对？所以先新的还是先旧的你选一个吧～"code:22 userInfo:nil]];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert beginSheetModalForWindow:_window completionHandler:nil];
    }
    
    book = xlsMode ? xlCreateBook() : xlCreateXMLBook();
    
    boldFont = xlBookAddFont(book, 0);
    xlFontSetBold(boldFont, 1);
    
    palebluefont = xlBookAddFont(book,0);
    xlFontSetName(palebluefont,"Arial");
    xlFontSetSize(palebluefont,12);
    
    redfont = xlBookAddFont(book,0);
    xlFontSetColor(redfont,COLOR_RED);
    xlFontSetSize(redfont,12);
    xlFontSetName(redfont,"Arial");
    
    fixturefont = xlBookAddFont(book,0);
    xlFontSetColor(fixturefont, COLOR_BLUE);
    xlFontSetName(fixturefont, "Arial");
    xlFontSetSize(fixturefont, 12);
    
    titleFont = xlBookAddFont(book, 0);
    xlFontSetName(titleFont, "Arial");
    xlFontSetSize(titleFont, 12);
    
    greenformat = xlBookAddFormatA(book, 0);
    xlFormatSetFont(greenformat,titleFont);
    xlFormatSetPatternForegroundColor(greenformat, COLOR_GREEN);
    xlFormatSetFillPattern(greenformat, FILLPATTERN_SOLID);
    
    greenstatusformat = xlBookAddFormatA(book, 0);
    xlFormatSetBorderA(greenstatusformat, BORDERSTYLE_THIN);
    xlFormatSetAlignHA(greenstatusformat, ALIGNH_LEFT);
    xlFormatSetAlignV(greenstatusformat,ALIGNV_TOP);
    xlFormatSetFontA(greenstatusformat, palebluefont);
    xlFormatSetPatternForegroundColorA(greenstatusformat, COLOR_GREEN);
    xlFormatSetFillPattern(greenstatusformat, FILLPATTERN_SOLID);

    
    paleblueformat = xlBookAddFormatA(book, 0);
    xlFormatSetBorderA(paleblueformat, BORDERSTYLE_THIN);
    xlFormatSetAlignHA(paleblueformat, ALIGNH_LEFT);
    xlFormatSetAlignV(paleblueformat,ALIGNV_TOP);
    xlFormatSetFontA(paleblueformat, palebluefont);
    xlFormatSetPatternForegroundColorA(paleblueformat, COLOR_PALEBLUE);
    xlFormatSetFillPattern(paleblueformat, FILLPATTERN_SOLID);
    
    yellowformat = xlBookAddFormatA(book, 0);
    xlFormatSetPatternForegroundColor(yellowformat, COLOR_YELLOW_CL);
    xlFormatSetFont(yellowformat,titleFont);
    xlFormatSetFillPattern(yellowformat, FILLPATTERN_SOLID);
    
    redformat = xlBookAddFormatA(book, 0);
    xlFormatSetFont(redformat,titleFont);
    xlFormatSetPatternForegroundColor(redformat, COLOR_RED);
    xlFormatSetFillPattern(redformat, FILLPATTERN_SOLID);
    
    deepredformat = xlBookAddFormatA(book, 0);
    xlFormatSetPatternForegroundColor(deepredformat, COLOR_DARKRED);
    xlFormatSetFont(deepredformat,titleFont);
    xlFormatSetFillPattern(deepredformat, FILLPATTERN_SOLID);
    
    deepredformat1 = xlBookAddFormatA(book, 0);
    xlFormatSetFont(deepredformat1,redfont);
    
    purpleformat = xlBookAddFormatA(book, 0);
    xlFormatSetFont(purpleformat,titleFont);
    xlFormatSetPatternBackgroundColorA(purpleformat, COLOR_DARKPURPLE_CF);
    xlFormatSetFillPattern(purpleformat, FILLPATTERN_SOLID);
    
    titleFormat = xlBookAddFormat(book, 0);
    xlFormatSetBorderA(titleFormat, BORDERSTYLE_THIN);
    xlFormatSetFont(titleFormat, titleFont);
    xlFormatSetAlignH(titleFormat,ALIGNH_LEFT);
    xlFormatSetAlignV(titleFormat,ALIGNV_TOP);
    
    titleFormat1 = xlBookAddFormat(book, 0);
    xlFormatSetFont(titleFormat1, titleFont);
    xlFormatSetAlignH(titleFormat1,ALIGNH_LEFT);
    xlFormatSetAlignV(titleFormat1,ALIGNV_TOP);
    
    headerFormat = xlBookAddFormat(book, 0);
    xlFormatSetAlignH(headerFormat, ALIGNH_CENTER);
    xlFormatSetBorder(headerFormat, BORDERSTYLE_THIN);
    xlFormatSetFont(headerFormat, boldFont);
    xlFormatSetFillPattern(headerFormat, FILLPATTERN_SOLID);
    xlFormatSetPatternForegroundColor(headerFormat, COLOR_TAN);
    
    descriptionFormat = xlBookAddFormat(book, 0);
    xlFormatSetBorder(descriptionFormat, BORDERSTYLE_THIN);
    xlFormatSetAlignV(descriptionFormat,ALIGNV_TOP);
    xlFormatSetAlignH(descriptionFormat,ALIGNH_LEFT);
    xlFormatSetFont(descriptionFormat,titleFont);
    
    commandandresponseFormat = xlBookAddFormat(book, 0);
    xlFormatSetBorder(commandandresponseFormat, BORDERSTYLE_THIN);
    xlFormatSetAlignV(commandandresponseFormat,ALIGNV_TOP);
    xlFormatSetAlignH(commandandresponseFormat,ALIGNH_LEFT);
//    xlSheetRowHeightA(sheet, 20);
    xlFormatSetWrapA(commandandresponseFormat,1);
//    xlFormatSetShrinkToFitA(commandandresponseFormat,5);
    xlFormatSetFont(commandandresponseFormat,titleFont);
    
    descriptionchangeFormat = xlBookAddFormat(book, 0);
    xlFormatSetBorder(descriptionchangeFormat, BORDERSTYLE_THIN);
    xlFormatSetAlignV(descriptionchangeFormat,ALIGNV_TOP);
    xlFormatSetAlignH(descriptionchangeFormat,ALIGNH_LEFT);
    xlFormatSetFont(descriptionchangeFormat,titleFont);
    xlFormatSetFillPattern(descriptionchangeFormat, FILLPATTERN_SOLID);
    xlFormatSetPatternForegroundColor(descriptionchangeFormat, COLOR_BLUE);
    
    deleteFormat = xlBookAddFormat(book, 0);
    xlFormatSetBorder(deleteFormat, BORDERSTYLE_THIN);
    xlFormatSetAlignV(deleteFormat,ALIGNV_TOP);
    xlFormatSetAlignH(deleteFormat,ALIGNH_LEFT);
    xlFormatSetFont(deleteFormat,titleFont);
    xlFormatSetFillPattern(deleteFormat, FILLPATTERN_SOLID);
    xlFormatSetPatternForegroundColor(deleteFormat, COLOR_GRAY40);
    
    fixtureFormat = xlBookAddFormat(book,0);
    xlFormatSetBorder(fixtureFormat,BORDERSTYLE_THIN);
    xlFormatSetAlignV(fixtureFormat,ALIGNV_TOP);
    xlFormatSetAlignH(fixtureFormat,ALIGNH_LEFT);
    xlFormatSetFont(fixtureFormat,fixturefont);
    xlFormatSetFillPattern(fixtureFormat,FILLPATTERN_NONE);
  
    amountFormat = xlBookAddFormat(book, 0);
    xlFormatSetNumFormat(amountFormat, NUMFORMAT_CURRENCY_NEGBRA);
    xlFormatSetBorderLeft(amountFormat, BORDERSTYLE_THIN);
    xlFormatSetBorderRight(amountFormat, BORDERSTYLE_THIN);
    
    totalLabelFormat = xlBookAddFormat(book, 0);
    xlFormatSetBorderTop(totalLabelFormat, BORDERSTYLE_THIN);
    xlFormatSetAlignH(totalLabelFormat, ALIGNH_RIGHT);
    xlFormatSetFont(totalLabelFormat, boldFont);
    
    totalFormat = xlBookAddFormat(book, 0);
    xlFormatSetNumFormat(totalFormat, NUMFORMAT_CURRENCY_NEGBRA);
    xlFormatSetBorder(totalFormat, BORDERSTYLE_THIN);
    xlFormatSetFont(totalFormat, boldFont);
    xlFormatSetFillPattern(totalFormat, FILLPATTERN_SOLID);
    xlFormatSetPatternForegroundColor(totalFormat, COLOR_YELLOW);
    
    signatureFormat = xlBookAddFormat(book, 0);
    xlFormatSetAlignH(signatureFormat, ALIGNH_CENTER);
    xlFormatSetBorderTop(signatureFormat, BORDERSTYLE_THIN);

    const char *cStationName = [m_strStationName UTF8String];
    sheet = xlBookAddSheet(book, cStationName, 0);
    if(sheet)
    {
/*for color define
        NSString *nul = @"";
        const char*m_nul = [nul UTF8String];
        NSString *row1 = @"Color define for Status";
        const char *m_row1 = (char*)malloc(666);
        m_row1 = [row1 UTF8String];
        xlSheetWriteStrA(sheet, 2, 0, m_row1, titleFormat1);
        xlSheetSetMergeA(sheet, 2, 2, 0,2);
        NSString *row2 = @"Command validation OK";
        const char *m_row2 = (char*)malloc(666);
        m_row2 = [row2 UTF8String];
        xlSheetWriteStrA(sheet, 3, 0, m_nul, greenformat);
        xlSheetWriteStrA(sheet, 3, 1, m_row2, titleFormat1);
        xlSheetSetMergeA(sheet, 3, 3, 1, 3);
        NSString *row3 = @"Command validation OK but need Function validation or data check";
        const char*m_row3 = (char*)malloc(666);
        m_row3 = [row3 UTF8String];
        xlSheetWriteStrA(sheet, 4, 0, m_nul, yellowformat);
        xlSheetWriteStrA(sheet, 4, 1, m_row3, titleFormat1);
        xlSheetSetMergeA(sheet, 4, 4, 1, 4);
        NSString *row4 = @"Command validation Fail";
        const char*m_row4 = (char*)malloc(666);
        m_row4 = [row4 UTF8String];
        xlSheetWriteStrA(sheet, 5, 0, m_nul, redformat);
        xlSheetWriteStrA(sheet, 5, 1, m_row4, titleFormat1);
        xlSheetSetMergeA(sheet, 5, 5, 1, 4);
        NSString *row5 = @"Color define for Test Item";
        const char*m_row5 = (char*)malloc(666);
        m_row5 = [row5 UTF8String];
        xlSheetWriteStrA(sheet, 6, 0, m_row5, titleFormat1);
        xlSheetSetMergeA(sheet, 6, 6, 0, 2);
        NSString *row6 = @"Fixture Command and Response";
        const char*m_row6 = (char*)malloc(666);
        m_row6 = [row6 UTF8String];
        xlSheetWriteStrA(sheet, 7, 1, m_row6, titleFormat1);
        xlSheetWriteStrA(sheet, 7, 0, m_nul, descriptionchangeFormat);
        xlSheetSetMergeA(sheet, 7, 7, 1, 4);
        NSString *row7 = @"Item return value is numeric type and with Open Limit";
        const char*m_row7 = (char*)malloc(666);
        m_row7 = [row7 UTF8String];
        xlSheetWriteStrA(sheet, 8, 0, m_nul, purpleformat);
        xlSheetWriteStrA(sheet, 8, 1, m_row7, titleFormat1);
        xlSheetSetMergeA(sheet, 8, 8, 1, 4);
        NSString *row8 = @"Color define for font";
        const char*m_row8 = (char*)malloc(666);
        m_row8 = [row8 UTF8String];
        xlSheetWriteStrA(sheet, 9, 0, m_row8, titleFormat1);
        xlSheetSetMergeA(sheet, 9, 9, 0,2);
        NSString *row9 = @"For fixture";
        const char*m_row9 = (char*)malloc(666);
        m_row9 = [row9 UTF8String];
        xlSheetWriteStrA(sheet, 10, 0, m_nul, descriptionchangeFormat);
        xlSheetWriteStrA(sheet, 10, 1, m_row9, fixtureFormat);
        xlSheetSetMergeA(sheet, 10, 10, 1, 4);
        NSString *row10 = @"Changing compare with previous version";
        const char*m_row10 = (char*)malloc(666);
        m_row10 = [row10 UTF8String];
        xlSheetWriteStrA(sheet, 11, 0, m_nul, deepredformat);
        xlSheetWriteStrA(sheet, 11, 1, m_row10, deepredformat1);
        xlSheetSetMergeA(sheet, 11, 11, 1, 4);
*/
        
//        xlSheetWriteStrA(sheet, 13, 0, [@"Category" UTF8String], paleblueformat);
//        xlSheetWriteStrA(sheet, 13, 1, [@"Related Test Item" UTF8String], paleblueformat);
//        xlSheetWriteStrA(sheet, 13, 2, [@"Spec" UTF8String], paleblueformat);
//        xlSheetWriteStrA(sheet, 13, 3, [@"Target" UTF8String], paleblueformat);
//        xlSheetWriteStrA(sheet, 13, 4, [@"Diags Commands" UTF8String], paleblueformat);
//        xlSheetWriteStrA(sheet, 13, 5, [@"Diags Response" UTF8String], paleblueformat);
//        xlSheetWriteStrA(sheet, 13, 6, [@"Testtime" UTF8String], paleblueformat);
//        xlSheetWriteStrA(sheet, 13, 7, [@"Issue Description" UTF8String], paleblueformat);
//        xlSheetWriteStrA(sheet, 13, 8, [@"Radar No" UTF8String], paleblueformat);
        xlSheetWriteStrA(sheet, 1, 0, [@"Category" UTF8String], paleblueformat);
        xlSheetWriteStrA(sheet, 1, 1, [@"Related Test Item" UTF8String], paleblueformat);
        xlSheetWriteStrA(sheet, 1, 2, [@"Spec" UTF8String], paleblueformat);
        xlSheetWriteStrA(sheet, 1, 3, [@"Testtime" UTF8String], paleblueformat);
        xlSheetWriteStrA(sheet, 1, 4, [@"Diags Commands" UTF8String], paleblueformat);
        xlSheetWriteStrA(sheet, 1, 5, [@"Status" UTF8String], paleblueformat);
        xlSheetWriteStrA(sheet, 1, 6, [@"Radar No" UTF8String], paleblueformat);
        xlSheetWriteStrA(sheet, 1, 7, [@"Remark" UTF8String], paleblueformat);
        xlSheetWriteStrA(sheet, 1, 8, [@"Judgement" UTF8String], paleblueformat);        //xlSheetInsertRowA(sheet, 0, 100000);
        xlSheetWriteStrA(sheet, 1, 9, [@"Diags Response" UTF8String], paleblueformat);        //xlSheetInsertRowA(sheet, 0, 100000);
        //xlSheetInsertColA(sheet, 0, 100000);
        BOOL itemcheck = '\0';
        BOOL speccheck = '\0';
        BOOL commandcheck = '\0';
        for (int i =0; i<[m_datasource.m_showdata count]; i++)
        {
            xlSheetSetColA(sheet, 1, 1, 28, 0, 0);
            xlSheetSetColA(sheet, 4, 4, 36, 0, 0);
            xlSheetSetColA(sheet, 6, 6, 10, 0, 0);
            xlSheetSetColA(sheet, 9, 9, 60, 0, 0);
            xlSheetSetRowA(sheet, i+2, 12, 0, 0);
            NSString *response = [[m_datasource.m_showdata objectAtIndex:i] objectForKey:@"Response"];
            const char *m_response = (char*)malloc(6000);
            m_response = [response UTF8String];
            NSString *target = [[m_datasource.m_showdata objectAtIndex:i] objectForKey:@"Target"];
            const char *m_target = (char*)malloc(6000);
            m_target = [target UTF8String];
            NSString *command = [[m_datasource.m_showdata objectAtIndex:i]objectForKey:@"Command"];
            const char *m_command = (char*)malloc(6000);
            m_command = [command UTF8String];
            NSString *spec = [[m_datasource.m_showdata objectAtIndex:i]objectForKey:@"Spec"];
            const char *m_spec = (char*)malloc(6000);
            m_spec = [spec UTF8String];
            NSString *item = [[m_datasource.m_showdata objectAtIndex:i]objectForKey:@"item"];
            const char *m_item = (char*)malloc(6000);
            m_item = [item UTF8String];
            NSString *testtime;
            const char *m_testtime = (char*)malloc(6000);
            if (name_and_time.count!=0) {
                testtime = [[m_datasource.m_showdata objectAtIndex:i]objectForKey:@"TestTime"];
                m_testtime = [testtime UTF8String];
            }
            if([m_orgary count]!=0)
            {
                for (int k =0; k<[m_orgary count]; k++) {
                    NSString *orgitem = [[m_orgary objectAtIndex:k]objectForKey:@"item"];
                    if ([item isEqualToString:orgitem]) {
                        itemcheck =YES;
                        break;
                    }
                    else
                        itemcheck =NO;
                }
                for (int k =0; k<[m_orgary count]; k++) {
                    NSString *orgspec = [[m_orgary objectAtIndex:k]objectForKey:@"Spec"];
                    if ([spec isEqualToString:orgspec]) {
                        
                        speccheck =YES;
                        break;
                    }
                    else
                        speccheck =NO;
                }
                for (int k =0; k<[m_orgary count]; k++) {
                    NSString *orgcommand = [[m_orgary objectAtIndex:k]objectForKey:@"Command"];
                    if ([command isEqualToString:orgcommand]) {
                        commandcheck =YES;
                        break;
                    }
                    else
                        commandcheck = NO;
                }
                //item
                if (itemcheck==YES) {
                    xlSheetWriteStr(sheet, i+2, 1,m_item,descriptionFormat);
                    //status
                    xlSheetWriteStr(sheet, i+2, 0,"",descriptionFormat);
                    xlSheetWriteStr(sheet, i+2, 5,"",greenformat);
                    xlSheetWriteStr(sheet, i+2, 6,[@"" UTF8String],descriptionFormat);
                    xlSheetWriteStr(sheet, i+2, 7,"",descriptionFormat);
                    xlSheetWriteStr(sheet, i+2, 8,"",descriptionFormat);

                }
                else if (itemcheck==NO)
                {
                    if (ischoosento) {
                        xlSheetWriteStr(sheet, i+2, 1,m_item,descriptionchangeFormat);
                        //status
                        xlSheetWriteStr(sheet, i+2, 0,"",descriptionchangeFormat);
                        xlSheetWriteStr(sheet, i+2, 5,"",descriptionchangeFormat);
                        xlSheetWriteStr(sheet, i+2, 6,[@"" UTF8String],descriptionchangeFormat);
                        xlSheetWriteStr(sheet, i+2, 7,"",descriptionchangeFormat);
                        xlSheetWriteStr(sheet, i+2, 8,"",descriptionchangeFormat);


                    }
                    if (ischooseotn) {
                        xlSheetWriteStr(sheet, i+2, 1,m_item,deleteFormat);
                        //status
                        xlSheetWriteStr(sheet, i+2, 0,"",deleteFormat);
                        xlSheetWriteStr(sheet, i+2, 5,"",deleteFormat);
                        xlSheetWriteStr(sheet, i+2, 6,[@"" UTF8String],deleteFormat);
                        xlSheetWriteStr(sheet, i+2, 7,"",deleteFormat);
                        xlSheetWriteStr(sheet, i+2, 8,"",deleteFormat);

                    }
                }
                if (speccheck ==YES) {
                    xlSheetWriteStr(sheet, i+2, 2, m_spec, descriptionFormat);
                }
                else if(speccheck ==NO)
                {
                    if (ischoosento) {
                        xlSheetWriteStr(sheet, i+2, 2,m_spec,descriptionchangeFormat);
                    }
                    else if (ischooseotn)
                    {
                        xlSheetWriteStr(sheet, i+2, 2,m_spec,deleteFormat);
                    }
                    
                }
                if (commandcheck ==YES) {
                    xlSheetWriteStr(sheet, i+2, 4, m_command, commandandresponseFormat);
//                    xlSheetWriteStr(sheet, i+2, 9, m_response, descriptionFormat);
                    xlSheetWriteStr(sheet, i+2, 9, m_response, commandandresponseFormat);
                }
                else if (commandcheck ==NO)
                {
                    if (ischoosento) {
                        xlSheetWriteStr(sheet, i+2, 4, m_command,commandandresponseFormat);
//                        xlSheetWriteStr(sheet, i+2, 9, m_response,descriptionchangeFormat);
                        xlSheetWriteStr(sheet, i+2, 9, m_response,commandandresponseFormat);
                    }
                    else if (ischooseotn)
                    {
                        xlSheetWriteStr(sheet, i+2, 4, m_command,commandandresponseFormat);
//                        xlSheetWriteStr(sheet, i+2, 9, m_response,deleteFormat);
                        xlSheetWriteStr(sheet, i+2, 9, m_response,commandandresponseFormat);
                    }
                }
//                xlSheetWriteStr(sheet, i+2, 3, m_target, titleFormat);
            }
            if ([m_orgary count]==0) {
                if ([target isEqualToString:@"FIXTURE"]||[target isEqualToString:@"TARGET"]) {
                    xlSheetWriteStr(sheet, i+2, 4, m_command,isseparated?fixtureFormat:commandandresponseFormat);
//                    xlSheetWriteStr(sheet, i+2, 9, m_response,isseparated?fixtureFormat:titleFormat);
                    xlSheetWriteStr(sheet, i+2, 9, m_response,isseparated?fixtureFormat:commandandresponseFormat);
                }
                else
                {
                    xlSheetWriteStr(sheet, i+2, 4, m_command,commandandresponseFormat);
//                    xlSheetWriteStr(sheet, i+2, 9, m_response,titleFormat);
                    xlSheetWriteStr(sheet, i+2, 9, m_response,commandandresponseFormat);
                }
//                xlSheetWriteStr(sheet, i+2, 3, m_testtime, titleFormat);
                xlSheetWriteStr(sheet, i+2, 1,m_item,titleFormat);
                xlSheetWriteStr(sheet, i+2, 2,m_spec,titleFormat);
                //status
                xlSheetWriteStr(sheet, i+2, 0,"",descriptionFormat);
                xlSheetWriteStr(sheet, i+2, 5,nil,greenstatusformat);
                xlSheetWriteStr(sheet, i+2, 6,"",descriptionFormat);
                xlSheetWriteStr(sheet, i+2, 7,"",descriptionFormat);
                xlSheetWriteStr(sheet, i+2, 8,"",descriptionFormat);

                if (testtime!=nil&&![testtime isEqual:@""]) {
                     xlSheetWriteStr(sheet,i+2,3,m_testtime,titleFormat);
                }
            }

            if(i<[m_datasource.m_showdata count]-1){
                for (int j=1; j<=[m_datasource.m_showdata count]-i-1; j++) {
                    if([[[m_datasource.m_showdata objectAtIndex:i] objectForKey:@"item"]isEqualTo:[[m_datasource.m_showdata objectAtIndex:i+j] objectForKey:@"item"]])
                    {
                        continue;
                    }
                    else
                    {
                        if(i+j<[m_datasource.m_showdata count])
                        {
                            xlSheetSetMergeA(sheet,i+2, i+j+1, 0, 0);
                            xlSheetSetMergeA(sheet,i+2, i+j+1, 1, 1);
                            xlSheetSetMergeA(sheet,i+2, i+j+1, 2, 2);
                            if (testtime!=nil&&![testtime isEqual:@""]) {
                                xlSheetSetMergeA(sheet,i+2, i+j+1, 3, 3);
                            }
                        }
                        else
                        {
                            xlSheetSetMergeA(sheet,i+2, i+j+1, 0, 0);
                            xlSheetSetMergeA(sheet,i+2, i+j+1, 2, 2);
                            xlSheetSetMergeA(sheet,i+2, i+j+1, 1, 1);
                            if (testtime!=nil&&![testtime isEqual:@""]) {
                                xlSheetSetMergeA(sheet,i+2, i+j+1, 3, 3);
                            }
                        }
                        break;
                    }
                }
            }
        }
        xlSheetColWidthA(sheet, 50);
        xlSheetRowHeightA(sheet, 22);
        
    }
    NSString *m_path;
    NSSavePanel *s_panel = [NSSavePanel savePanel];                 //利用NSSavepanel类保存文件
    [s_panel setNameFieldStringValue:@"Test"];
    [s_panel setMessage:@"Please choose a path to save the document"];
    [s_panel setAllowsOtherFileTypes:YES];
    [s_panel setAllowedFileTypes:@[@"xlsx"]];
    [s_panel setExtensionHidden:NO];
    [s_panel setCanCreateDirectories:YES];
    if ([s_panel runModal] == NSFileHandlingPanelOKButton)
    {
        m_path = [[s_panel URL] path];
        xlBookSave(book, [m_path UTF8String]);
    }
    xlBookRelease(book);
//    NSString *documentPath =
//    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
//    NSString *filename = [documentPath stringByAppendingPathComponent:name];
   
    
    //[[NSWorkspace sharedWorkspace] openFile:filename];
}

//-(IBAction)presscopy:(NSButton*)sender
//{
//    NSString * m_target= [[m_tableview dataSource] tableView:m_tableview
//                                   objectValueForTableColumn:[m_tableview tableColumnWithIdentifier:@"Target"]
//                                                         row:[m_tableview selectedRow]];
//    NSMutableString * m_command= [[m_tableview dataSource] tableView:m_tableview
//                                           objectValueForTableColumn:[m_tableview tableColumnWithIdentifier:@"Command"]
//                                                                 row:[m_tableview selectedRow]];
//    NSMutableString *m_response = [[m_tableview dataSource] tableView:m_tableview
//                                            objectValueForTableColumn:[m_tableview tableColumnWithIdentifier:@"Response"]
//                                                                  row:[m_tableview selectedRow]];
//    [t_textfield appendFormat:@"%@: %@\n %@\n",m_target,m_command,m_response];
//}

-(IBAction)Load:(id)sender
{
    if (!boolLoadCSV)
    {
        NSAlert *alert = [[NSAlert alloc]init];
        alert.messageText = @"警告(Warning)";
        alert.informativeText = @"先加载CSV文件。(Please laod CSV file firstly!)";
        [alert addButtonWithTitle:@"确认(OK)"];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
    }
    else{
    [m_datasource.m_showdata removeAllObjects];
    [m_tableview reloadData];
    NSMutableDictionary *m_dic;
    NSOpenPanel *panel = [NSOpenPanel openPanel];           //使用NSopenpanel类读取文件路径
    //[panel setDirectoryURL:NSHomeDirectory()];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:YES];
    [panel setAllowedFileTypes:@[@"txt"]];
    [panel setAllowsOtherFileTypes:YES];
    if ([panel runModal] == NSFileHandlingPanelOKButton)
    {
        path = [panel.URLs.firstObject path];               //获得路径
        [m_filetext setStringValue:path];                   //显示路径
        NSString *data =[[NSString alloc]initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];                //读取文件 将内容载入字符串
        if ([data length]>0) {
            NSString *str = [[data stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"]stringByReplacingOccurrencesOfString:@"\n\r" withString:@"\n"];                                           //将换行统一表示为\n
            str = [[str stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"] stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];                                          //将空行统一表示为\n
            NSArray *r_ary = [str componentsSeparatedByString:@"\n"];
            NSMutableArray *m_arry = [[NSMutableArray alloc]initWithArray:r_ary];
            [m_arry removeObject:@""];
            for (int i=0; i<[m_arry count]; i++) {
                m_dic = [[NSMutableDictionary alloc]init];
                NSMutableString *c_str = [m_arry objectAtIndex:i];
                if([c_str containsString:@"======= START TEST"])
                {
                    int l = 0;
                    NSString *strrxtarget = @"";
                    NSString *strrxcommand = @"";
                    NSMutableString *strrxresponse = [[NSMutableString alloc] init];
                    for (int k = i+1; k<[m_arry count]; k++) {
                        c_str = [m_arry objectAtIndex:k];
                        if (![c_str containsString:@"Item Name:"]) {
                            l++;
                        }
                        else if ([c_str containsString:@"Item Name:"])
                        {
                            i=k;
                            m_dic = [[NSMutableDictionary alloc]init];
                            NSString *m_spec = [c_str catchStringBeginWith:@"," endWith:@""];
//                            NSString *m_item = [c_str catchStringBeginWith:@"Item Name:" endWith:@","];
                            NSString *m_item = [c_str subByRegex:@"Item Name:(.*?)," name:nil error:nil];
                            if (l<2) {
                                if ([name_and_time count]!=0) {
                                    for (int m = 0; m<name_and_time.count; m++) {
                                        if ([[[name_and_time objectAtIndex:m]objectForKey:@"ITEM"]isEqualToString:m_item]) {
                                            m_dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:m_item, @"item",strrxcommand,@"Command",strrxresponse,@"Response",m_spec,@"Spec",strrxtarget,@"Target",[[name_and_time objectAtIndex:m]objectForKey:@"TestTime"],@"TestTime",nil];
                                        }
                                    }
                                }
                                else{
                                    m_dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:m_item, @"item",strrxcommand,@"Command",strrxresponse,@"Response",m_spec,@"Spec",strrxtarget,@"Target",nil];
                                }

                                [m_datasource addObject:m_dic];
                                i=k;
                                break;
                            }
                            else
                            {
                                for (int j = k-l; j<k; j++) {
                                    c_str = [m_arry objectAtIndex:j];
                                    if ([c_str containsString:@"TX ==> ["])
                                    {
                                        NSString *response = [[c_str catchStringBeginWith:@"]" endWith:@""]stringByReplacingOccurrencesOfString:@"TX" withString:@"RX"];
                                        for (int n = j+1; n<k; n++) {
                                            c_str = [m_arry objectAtIndex:n];
                                            if ([c_str containsString:response])
                                            {
                                                strrxresponse = [[NSMutableString alloc]init];
                                                //get target and command
                                                strrxtarget = [c_str catchStringBeginWith:@"RX ==> [" endWith:@"])"];
                                                strrxcommand = [response catchStringBeginWith:@"]):" endWith:@""];
                                                if (![strrxtarget isEqualTo:@""])
                                                {
                                                    [strrxresponse appendFormat:@"%@\n",[c_str catchStringBeginWith:@"]):" endWith:@""]];
                                                    for(int m=n+1;m<k;m++)
                                                    {
                                                        m_dic = [[NSMutableDictionary alloc]init];
                                                        c_str = [m_arry objectAtIndex:m];
                                                        if ([c_str containsString:@":-)"]||[c_str containsString:@"@_@"]||[c_str containsString:@"B431-16A>"]||[c_str containsString:@"root#"]) {
                                                            [strrxresponse appendFormat:@"%@\n",c_str];
                                                            j=j+1;
                                                            NSLog(@"%@",strrxcommand);
                                                            break;
                                                        }
                                                        else
                                                        {
                                                            [strrxresponse appendFormat:@"%@\n",c_str];
                                                        }
                                                    }
                                                    if ([m_item containsString:@","]) {
                                                        m_item = [m_item catchStringBeginWith:@"" endWith:@","];
                                                    }
                                                    if ([name_and_time count]!=0) {
                                                        for (int m = 0; m<name_and_time.count; m++) {
                                                            if ([[[name_and_time objectAtIndex:m]objectForKey:@"ITEM"]isEqualToString:m_item]) {
                                                                m_dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:m_item, @"item",strrxcommand,@"Command",strrxresponse,@"Response",m_spec,@"Spec",strrxtarget,@"Target",[[name_and_time objectAtIndex:m]objectForKey:@"TestTime"],@"TestTime",nil];
                                                            }
                                                        }
                                                    }
                                                    else
                                                    {
                                                        m_dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:m_item, @"item",strrxcommand,@"Command",strrxresponse,@"Response",m_spec,@"Spec",strrxtarget,@"Target",nil];
                                                    }
                                                    [m_datasource addObject:m_dic];
                                                    break;
                                                }
                                            }
                                        }
                                    }
                                }
                                i=k;
                                break;
                            }
                            break;
                        }
                    }
                }
            }
        }
    }
    m_neededdata = [m_datasource.m_showdata mutableCopy];
    [m_tableview reloadData];
    }
}

-(IBAction)LoadCSV:(id)sender
{
    boolLoadCSV = NO;
    name_and_time = [[NSMutableArray alloc]init];
    NSMutableArray *m_csvary ;
    NSOpenPanel *panel = [NSOpenPanel openPanel];           //使用NSopenpanel类读取文件路径
    //[panel setDirectoryURL:NSHomeDirectory()];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:YES];
    [panel setAllowedFileTypes:@[@"csv"]];
    [panel setAllowsOtherFileTypes:YES];
    if ([panel runModal] == NSFileHandlingPanelOKButton)
    {
        CSVpath = [panel.URLs.firstObject path];
        [m_csvpath setStringValue:CSVpath];
        NSString *csvdetail = [[NSString alloc]initWithContentsOfFile:CSVpath encoding:NSUTF8StringEncoding error:nil];
        m_strStationName = [csvdetail subByRegex:@"\"START_TEST_(.*?)\"" name:nil error:nil];
        
        csvdetail = [[csvdetail stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"]stringByReplacingOccurrencesOfString:@"\n\r" withString:@"\n"];
        m_csvary = [[NSMutableArray alloc]initWithArray:[csvdetail componentsSeparatedByString:@"\n"]];
        [m_csvary removeObject:@""];
        for (int i=0; i<m_csvary.count; i++)
        {
            if ([[m_csvary objectAtIndex:i]containsString:@"\""]) {
                NSString *step1 = [[m_csvary objectAtIndex:i]catchStringBeginWith:@"\"" endWith:@","];
//                NSString *testtime = [[m_csvary objectAtIndex:i] catchStringBeginWith:step1 endWith:@""];
                NSString *testtime = [[m_csvary objectAtIndex:i]subByRegex:@",([0-9.]+)$" name:nil error:nil];
//                NSString *testitem = [[m_csvary objectAtIndex:i]catchStringBeginWith:@"\"" endWith:@"\","];
                NSString *testitem = [[m_csvary objectAtIndex:i]subByRegex:@"\"(.*?)\"" name:nil error:nil];
//                testitem = [testitem catchStringBeginWith:@"" endWith:@"\","];
                testtime = [testtime stringByReplacingOccurrencesOfString:@"," withString:@""];
                NSDictionary *m_dic = [[NSDictionary alloc]initWithObjectsAndKeys:testitem,@"ITEM",testtime,@"TestTime", nil];
                [name_and_time addObject:m_dic];
            }
        }
        boolLoadCSV =YES;
    }
    NSLog(@"%@",name_and_time);
}

-(IBAction)Openoriginal:(NSButton*)sender
{
    m_orgary = [[NSMutableArray alloc]init];
    NSMutableDictionary *m_dic;
    NSString *filepath;
    NSOpenPanel *panel = [[NSOpenPanel alloc]init];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:YES];
    [panel setAllowedFileTypes:@[@"txt"]];
    [panel setAllowsOtherFileTypes:YES];
    if ([panel runModal] == NSFileHandlingPanelOKButton)
    {
        filepath = [panel.URLs.firstObject path];
        //[[NSWorkspace sharedWorkspace]openFile:filepath];
        
        NSString *data =[[NSString alloc]initWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil];                //读取文件 将内容载入字符串
        if ([data length]>0) {
            NSString *str = [[data stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"]stringByReplacingOccurrencesOfString:@"\n\r" withString:@"\n"];                                           //将换行统一表示为\n
            NSArray *r_ary = [str componentsSeparatedByString:@"\n"];
            NSMutableArray *m_arry = [[NSMutableArray alloc]initWithArray:r_ary];
            [m_arry removeObject:@""];
            for (int i=0; i<[m_arry count]; i++) {
                m_dic = [[NSMutableDictionary alloc]init];
                NSMutableString *c_str = [m_arry objectAtIndex:i];
                if([c_str containsString:@"======= START TEST"])
                {
                    int l = 0;
                    NSString *strrxtarget = @"";
                    NSString *strrxcommand = @"";
                    NSMutableString *strrxresponse = [[NSMutableString alloc] init];
                    for (int k = i+1; k<[m_arry count]; k++) {
                        c_str = [m_arry objectAtIndex:k];
                        if (![c_str containsString:@"Item Name:"]) {
                            l++;
                        }
                        else if ([c_str containsString:@"Item Name:"])
                        {
                            i=k;
                            m_dic = [[NSMutableDictionary alloc]init];
                            NSString *m_spec = [c_str catchStringBeginWith:@"," endWith:@""];
                            NSString *m_item = [c_str catchStringBeginWith:@"Item Name:" endWith:@","];
                            if (l<2) {
                                m_dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:m_item, @"item",strrxcommand,@"Command",strrxresponse,@"Response",m_spec,@"Spec",strrxtarget,@"Target",nil];
                                [m_orgary addObject:m_dic];
                                i=k;
                                break;
                            }
                            else
                            {
                                for (int j = k-l+1; j<k; j++) {
                                    c_str = [m_arry objectAtIndex:j];
                                    if ([c_str containsString:@"RX ==> ["])
                                    {
                                        strrxresponse = [[NSMutableString alloc]init];
                                        //get target and command
                                        strrxtarget = [c_str catchStringBeginWith:@"RX ==> [" endWith:@"])"];
                                        strrxcommand = [c_str catchStringBeginWith:@"]):" endWith:@""];
                                        if (![strrxtarget isEqualTo:@""])
                                        {
                                            [strrxresponse appendFormat:@"%@\n",strrxcommand];
                                            for(int m=j+1;m<k;m++)
                                            {
                                                m_dic = [[NSMutableDictionary alloc]init];
                                                c_str = [m_arry objectAtIndex:m];
                                                if ([c_str containsString:@":-)"]||[c_str containsString:@"@_@"]) {
                                                    [strrxresponse appendFormat:@"%@\n",c_str];
                                                    j=m;
                                                    break;
                                                }
                                                else
                                                {
                                                    [strrxresponse appendFormat:@"%@\n",c_str];
                                                }
                                            }
                                            if ([name_and_time count]!=0) {
                                                for (int m = 0; m<name_and_time.count; m++) {
                                                    if ([[[name_and_time objectAtIndex:m]objectForKey:@"ITEM"]isEqualToString:m_item]) {
                                                        m_dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:m_item, @"item",strrxcommand,@"Command",strrxresponse,@"Response",m_spec,@"Spec",strrxtarget,@"Target",[[name_and_time objectAtIndex:m]objectForKey:@"TestTime"],@"TestTime",nil];
                                                    }
                                                }
                                            }
                                            else
                                            {
                                                 m_dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:m_item, @"item",strrxcommand,@"Command",strrxresponse,@"Response",m_spec,@"Spec",strrxtarget,@"Target",nil];
                                            }
                                            [m_orgary addObject:m_dic];
                                        }
                                    }
                                }
                                i=k;
                                break;
                            }
                            break;
                        }
                    }
                }
            }
        }
    }
}

-(IBAction)Clean:(id)sender
{
    NSString *data=@"";
    [m_textfield setString:data];
    m_datasource.m_showdata = [[NSMutableArray alloc]init];
    [m_tableview reloadData];
    [thread cancel];
}

-(IBAction)Save:(id)sender
{
    NSDate *dateNow = [NSDate date]; //Get current time
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"YYYY-MM-dd HH:mm:ss "];
    NSMutableString *strDateString = [[NSMutableString alloc]init];
    [strDateString appendFormat:@"%@_parselog.txt",[dateFormat stringFromDate:dateNow]];
    NSSavePanel *s_panel = [NSSavePanel savePanel];                 //利用NSSavepanel类保存文件
    [s_panel setNameFieldStringValue:strDateString];
    [s_panel setMessage:@"Please choose a path to save the document"];
    [s_panel setAllowsOtherFileTypes:YES];
    [s_panel setAllowedFileTypes:@[@"txt",@"xlsx"]];
    [s_panel setExtensionHidden:NO];
    [s_panel setCanCreateDirectories:YES];
    if ([s_panel runModal] == NSFileHandlingPanelOKButton)
        {
            NSString *m_path = [[s_panel URL] path];
            [m_file writeToFile:m_path atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
    [thread cancel];
    NSLog(@"%@",strDateString);
}

- (IBAction)Startthread:(id)sender {
    NSDictionary *dicTemp = [NSDictionary dictionaryWithObjectsAndKeys:t_timetext,@"Textfield", nil];
    [t_timetext setStringValue:@""];
    thread=[[NSThread alloc] initWithTarget:self selector:@selector(run:) object:dicTemp];
    [thread setName:@"Thread"];
    [thread start];
}


-(void)run:(NSDictionary*)dict
{
    NSTextField *_time=[dict objectForKey:@"Textfield"];
    int i=1;
    if ([[[NSThread currentThread]name]isEqualToString:@"Thread"]) {
    do
    {
        //sleep(1);
        NSDate *dateNow = [NSDate date]; //Get current time
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"YYYY-MM-dd HH:mm:ss "];
        NSString *strDateString = [dateFormat stringFromDate:dateNow];
        [_time setStringValue:strDateString];
        if ([[NSThread currentThread]isCancelled]) {
            [NSThread exit];
            break;
        }
    }while(i==1);
    }
    else
    {
    }
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    strfilestring = [[NSMutableString alloc]init];
    NSMutableString * m_target= [[tableView dataSource] tableView:tableView
                                        objectValueForTableColumn:[tableView tableColumnWithIdentifier:@"Target"]
                                                              row:row];
    NSMutableString * m_command= [[tableView dataSource] tableView:tableView
                                         objectValueForTableColumn:[tableView tableColumnWithIdentifier:@"Command"]
                                                               row:row];
    NSMutableString *m_response = [[tableView dataSource] tableView:tableView objectValueForTableColumn:[tableView tableColumnWithIdentifier:@"Response"] row:row];
    //打印用户选中那一行的内容
    [strfilestring appendFormat:@"%@\n %@\n %@\n %@\n",t_textfield,m_target,m_command,m_response];
    [m_textfield setString:strfilestring];
    return YES;
} //tableviewDelegate中必须实现的方法
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [m_tableview setDataSource:m_datasource];
    [m_tableview setDelegate:self];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
