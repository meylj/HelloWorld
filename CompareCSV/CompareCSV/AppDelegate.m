//
//  AppDelegate.m
//  CompareCSV
//
//  Created by happy on 13-8-28.
//  Copyright (c) 2013年 happy. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate
- (id)init
{
    self = [super init];
    if (self) {
//Ours
        m_strCreateTime			= [[NSString		alloc] init];
		m_strStationNameofOurs	= [[NSString		alloc] init];
        m_strStationNameofOurs1 = [[NSString        alloc] init];
        m_aryItemsName			= [[NSMutableArray	alloc] init];
		m_aryItemsSpec			= [[NSMutableArray	alloc] init];
		m_strUartLogPath		= [[NSMutableString alloc] init];
		m_strCSVLogPath			= [[NSMutableString alloc] init];
		m_dicItemsUartCommand	= [[NSMutableDictionary alloc] init];
        m_arySameItemName		= [[NSMutableArray	alloc] init];
		m_dicSameItemComm		= [[NSMutableDictionary	alloc] init];
//South
        m_strStationNameofSouth =[[NSString alloc]init];
        m_strStationNameofSouth1=[[NSString alloc]init];
        m_szTime                =[[NSString alloc]init];
//Compare
        m_strCSV1Path           =[[NSString alloc]init];
        m_strCSV2Path           =[[NSString alloc]init];
        m_arrTestItems          =[[NSMutableArray alloc]init];
        m_arrTestLimits1        =[[NSMutableArray alloc]init];
        m_arrTestLimits2        =[[NSMutableArray alloc]init];
        m_arrCommand1           =[[NSMutableArray alloc]init];
        m_arrCommand2           =[[NSMutableArray alloc]init];
        m_arrNote               =[[NSMutableArray alloc]init];
        m_arrAddItems           =[[NSMutableArray alloc]init];
        m_arrDelItems           =[[NSMutableArray alloc]init];
        m_strPath1              =[[NSString alloc]init];
        m_strPath2              =[[NSString alloc]init];
        
    }
    return self;
}
-(void)awakeFromNib
{
	[txtShowResult setStringValue:@""];
	[txtShowResult setSelectable:YES];
	[txtShowResult setAutoresizesSubviews:NO];
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [tfFilePath setEnabled:NO];
    [tfFileToPath setEnabled:NO];
    [txtFileToPath setEnabled:NO];
    [txtLogpath setEnabled:NO];
    [tfShowCSV1Path setEnabled:NO];
    [tfShowCSV2Path setEnabled:NO];
    [tfShow_CompareCSVPath setEnabled:NO];
}
- (IBAction)SelectLogsPath:(NSButton *)sender
{
    [txtShowResult setStringValue:@""];
	NSOpenPanel *oPanel = [NSOpenPanel openPanel];
    [oPanel setAllowsMultipleSelection:NO];
	[oPanel setCanChooseFiles:NO];
	[oPanel setCanChooseDirectories:YES];
    [oPanel setDelegate:self];
    [oPanel beginSheetModalForWindow:_window completionHandler:nil];
	[txtShowResult setStringValue:@""];

}
- (IBAction)CreateTestCoverage:(id)sender
{
	// just like clear buffer
	[m_aryItemsName removeAllObjects];
	[m_aryItemsSpec	removeAllObjects];
	[m_dicItemsUartCommand removeAllObjects];
	// get the time when the file create
	NSDateFormatter *dateFormatter= [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"YYYYMMddHHmmss"];
	m_strCreateTime = [dateFormatter stringFromDate:[NSDate date]];
	//read csv and uart logs.
	[self readCSVLogs];
	[self readUartLogs];
	
	// file path to write the result to
	NSString *strFilePath = [NSString stringWithFormat:@"/vault/CompareCSV/Ours/%@_%@.csv",m_strStationNameofOurs,m_strCreateTime];
	
	// write the item information to test coverage
	for (int i =0; i<[m_aryItemsName count]; i++)
	{
		NSString *szItemName = [m_aryItemsName objectAtIndex:i];
		NSString *szItemSpec = [m_aryItemsSpec objectAtIndex:i];
		NSString *szItemComm = [m_dicItemsUartCommand objectForKey:[szItemName uppercaseString]];
        NSString *szItemCommKey = [szItemName uppercaseString];

        if ([szItemName hasPrefix:@"J86 "])
		{
			szItemCommKey = [[szItemName stringByReplacingOccurrencesOfString:@"J86 " withString:@""] uppercaseString];
		}
		
		
		
		//// for same item
		if ([m_arySameItemName containsObject:szItemCommKey])
		{	// have same name items
			NSMutableArray *arySameItemComm = [[NSMutableArray alloc] init];
			arySameItemComm = [m_dicSameItemComm objectForKey:[szItemName uppercaseString]];
			szItemComm = [arySameItemComm objectAtIndex:0];
			[arySameItemComm removeObjectAtIndex:0];
			[m_dicSameItemComm setObject:arySameItemComm  forKey:[szItemName uppercaseString]];
		}else
		{
			szItemComm = [m_dicItemsUartCommand objectForKey:szItemCommKey];
		}

		if (szItemComm == nil)
		{
			szItemComm = @"";
		}
		[self writeTestCoverage:[NSString stringWithFormat:@"%i,%@,%@,\"%@\"\n",i+1,szItemName,szItemSpec,szItemComm] toPath:strFilePath];
		
	}
	
	[txtShowResult setStringValue:[NSString stringWithFormat:@"Create OK!"]];
    [txtFileToPath setStringValue:[NSString stringWithFormat:@"/vault/CompareCSV/Ours/%@_%@.csv",m_strStationNameofOurs,m_strCreateTime]];
	m_strPath1=[txtFileToPath stringValue];
    m_strCSV1Path=[NSString stringWithString:m_strPath1];
    [tfShowCSV1Path setStringValue:m_strPath1];
	
}
// read station name and spec from csv logs
-(void)readCSVLogs
{
	NSString    *szCurrentString	= [NSString stringWithContentsOfFile:m_strCSVLogPath encoding:NSUTF8StringEncoding error:nil];
	NSArray		*aryItemsInfo = [szCurrentString componentsSeparatedByString:@"\n"];
	m_strStationNameofOurs = [[[aryItemsInfo objectAtIndex:1] componentsSeparatedByString:@","] objectAtIndex:2];
    m_strStationNameofOurs1=[[m_strStationNameofOurs componentsSeparatedByString:@"_"]objectAtIndex:1];
	for (int i =4 ; i< [aryItemsInfo count]-4; i++)
	{
		NSString *szItem = [aryItemsInfo objectAtIndex:i];
		NSArray	*aryContent = [szItem componentsSeparatedByString:@","];
		
		// station name.
		NSString *szItemName = [aryContent objectAtIndex:0];
		szItemName = [szItemName stringByReplacingOccurrencesOfString:@"\"" withString:@""];
		[m_aryItemsName addObject:szItemName];
		
		// station spec
		NSString *szDownLimit = [aryContent objectAtIndex:3];
		NSString *szUpLimit = [aryContent objectAtIndex:4];
		if ([szDownLimit isEqualToString:szUpLimit])
		{
			NSString *szItemSpec = [NSString stringWithFormat:@"%@",szDownLimit];
			if (![szDownLimit isEqualToString:@"N/A"])
			{
				szItemSpec = [NSString stringWithFormat:@"{%@}",szDownLimit];
			}
			[m_aryItemsSpec addObject:szItemSpec];
		}else
		{
			NSString *szItemSpec = [NSString stringWithFormat:@"[%@ %@]",szDownLimit,szUpLimit];
			[m_aryItemsSpec addObject:szItemSpec];
		}
	}
}

// get uart commands from uart logs
-(void)readUartLogs
{
	NSString	*strUartLog = [NSString stringWithContentsOfFile:m_strUartLogPath encoding:NSUTF8StringEncoding error:nil];
	NSArray *aryItemUartLog = [strUartLog componentsSeparatedByString:@"==== START TEST "];
	for (NSInteger i=1; i<[aryItemUartLog count]; i++)
	{
		NSString	*szUartLog = [aryItemUartLog objectAtIndex:i];
		// szKey === item names
		NSString	*szKey = [szUartLog SubTo:@" (Item" include:NO];
		NSArray		*aryItemCommands = [szUartLog componentsSeparatedByString:@"\n"];
		// szValue === item commands
		NSMutableString	*szValue = [[NSMutableString alloc] init];
		for (NSString *szCommands in aryItemCommands)
		{
            NSString *strTest = szCommands;
			if ([strTest ContainString:@"TX"])
			{
				strTest = [strTest SubFrom:@"(TX ==> " include:NO];
				strTest = [strTest stringByReplacingOccurrencesOfString:@"):" withString:@" "];
				if ([szValue length] <= 0)
				{
					[szValue setString:strTest];
					continue;
				}
				[szValue appendString:[NSString stringWithFormat:@"\r%@",strTest]];
			}else
			{
				continue;
			}
		}
        NSArray *aryKeys = [m_dicItemsUartCommand allKeys];
		if ([aryKeys containsObject:szKey])
		{
			[m_arySameItemName addObject:szKey];
			NSMutableArray *aryCommand = [[NSMutableArray alloc] initWithArray:[m_dicSameItemComm objectForKey:szKey]];
			if ([aryCommand count] == 0)
			{
				[aryCommand addObject:[m_dicItemsUartCommand objectForKey:szKey]];
			}
			[aryCommand addObject:szValue];
			[m_dicSameItemComm setObject:aryCommand forKey:szKey];
		}

		[m_dicItemsUartCommand setObject:szValue forKey:szKey];
	}	
}
// write the item information in test coverage
-(void)writeTestCoverage:(NSString *)strItemInfo toPath:(NSString *)strPath
{
	NSFileManager	*fileManager = [NSFileManager defaultManager];
	NSFileHandle	*fhTest = [NSFileHandle	 fileHandleForWritingAtPath:strPath];
    if (![fileManager fileExistsAtPath:@"/vault/CompareCSV/Ours"])
	{
		[fileManager createDirectoryAtPath:@"/vault/CompareCSV/Ours" withIntermediateDirectories:YES attributes:nil error:nil];
	}
	if (!fhTest)
	{
		strItemInfo = [NSString stringWithFormat:@"Item NO.,Test Items,Test Limits,Command\n%@",strItemInfo];
		[strItemInfo writeToFile:strPath atomically:NO encoding:NSUTF8StringEncoding error:nil];
	}else
    {
        NSData	*data	= [[NSData alloc] initWithBytes:(void *)[strItemInfo UTF8String]
											  length:[strItemInfo length]];
        [fhTest	seekToEndOfFile];
        [fhTest	writeData:data];
    }
	[fhTest     closeFile];
}
#pragma Mark --Delegate
-(BOOL)panel:(id)sender validateURL:(NSURL *)url error:(NSError **)outError
{
	[m_strCSVLogPath setString:@""];
	[m_strUartLogPath setString:@""];
	NSString *strURL = [NSString stringWithFormat:@"%@",url];
	strURL = [strURL stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	strURL = [strURL SubFrom:@"/localhost" include:NO];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:strURL])
	{
		NSRunAlertPanel(@"Warning", [NSString stringWithFormat:@"The file path [%@] you chose error.",strURL], @"OK", nil, nil);
		NSLog(@"You chose the wrong file path.");
		return NO;
	}
	[txtLogpath setStringValue:strURL];
	NSArray *aryFiles = [fileManager contentsOfDirectoryAtPath:strURL error:nil];
    
	for (NSString *strSubFile in aryFiles)
	{
		if ([strSubFile hasSuffix:@"_Uart.txt"])
		{
			[m_strUartLogPath setString: [NSString stringWithFormat:@"%@%@",strURL,strSubFile]];
			continue;
		}
		if ([strSubFile hasSuffix:@"_CSV.csv"])
		{
			[m_strCSVLogPath setString: [NSString stringWithFormat:@"%@%@",strURL,strSubFile]];
			continue;
		}
	}
	if ([m_strUartLogPath isEqualToString:@""] || [m_strCSVLogPath isEqualToString:@""])
	{
		NSRunAlertPanel(@"Warning", @"Make sure there are both uart log and csv log in the folder you chose.", @"OK", nil, nil);
		NSLog(@"The path of Uart log is [%@],the path of CSV log is [%@].",m_strUartLogPath,m_strCSVLogPath);
		return NO;
	}
	else
	{
		[txtShowResult setStringValue:[NSString stringWithFormat:@"PathOfCSV :%@\nPathOfUart:%@",m_strCSVLogPath,m_strUartLogPath]];
	}
    
	return YES;
}
-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return YES;
}
#pragma mark --action create south csv
- (void)doOneThing
{
    @autoreleasepool
    {
        NSString *szRead;
        NSString *szWrite;
        NSString *szWriteTo;
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"YYYYMMddHHmmss"];
        m_szTime=[dateFormatter stringFromDate:[NSDate date]];
        szRead =[self ReadLog];
        NSArray *arrRead=[self componentsSeparated:szRead];
        
        NSString* szFilePath1=[tfFilePath stringValue];
        NSString* strStationName=[NSString stringWithFormat:@"%@",[szFilePath1 lastPathComponent]];
        NSArray* arrName=[strStationName componentsSeparatedByString:@"_"];
        strStationName=[NSString stringWithFormat:@"%@_%@",[arrName objectAtIndex:2],[arrName objectAtIndex:3]];
        m_strStationNameofSouth1=[NSString stringWithFormat:@"%@",[arrName objectAtIndex:3]];
        m_strStationNameofSouth=[NSString stringWithString:strStationName];
        m_szFilePath =@"/vault/CompareCSV/South";
        m_szFileName=[NSString stringWithFormat:@"%@_%@",m_strStationNameofSouth,m_szTime];
       

        for (int i=0; i<=[arrRead count]; i++)
        {
            if(i==0)
            {
                szWriteTo=[NSString stringWithFormat:@"%@,%@,%@,%@\n",@"Item NO.",@"Test Items",@"Test Limits",@"Command"];
                [self WriteToCsv:szWriteTo];
            }
            else
            {
                szRead=[arrRead objectAtIndex:i-1];
                szWrite=[self valueToWrtteCsv:szRead numItem:i];
                if (m_bFailLog) {
                    szWriteTo=[NSString stringWithFormat:@"%d,%@\n",m_iFailLog,szWrite];
                }
                else
                    szWriteTo=[NSString stringWithFormat:@"%d,%@\n",i,szWrite];
                [self WriteToCsv:szWriteTo];
                
            }
        }
        if (!m_bFailLog) {
            [tfShow setStringValue:@"Create OK!"];
        }
    }
}
-(IBAction)start:(id)sender
{
    [NSThread detachNewThreadSelector:@selector(doOneThing) toTarget:self withObject:nil];
}


-(IBAction)ChooseSouthLog:(id)sender
{
    [tfShow setStringValue:@""];
    NSOpenPanel *openPanel=[NSOpenPanel openPanel];
    [openPanel setTitle:@"Choose a File of South Log"];
    [openPanel setCanChooseDirectories:YES];
    NSInteger i=[openPanel runModal];
    if(i==NSOKButton)
    {
        NSString *szFilePath=[openPanel filename];
        [tfFilePath setStringValue:szFilePath];        
    }
}
// choose the south log file and read it
-(NSString *)ReadLog
{
    NSString * szRead=@"";
    szRead=[tfFilePath stringValue];
    NSString *string= [[NSString alloc] initWithContentsOfFile:szRead];
    szRead=string;
    return szRead;
}


-(NSArray*)componentsSeparated:(NSString*)szRead
{
    NSArray *array = [szRead componentsSeparatedByString:@" s]"];
    return array;
}


-(NSString*)valueToWrtteCsv:(NSString*)szRead numItem:(int)i
{
    NSMutableString *strChangeSign=[[NSMutableString alloc]init];
    NSMutableString *szItemSpec1=[[NSMutableString alloc]init];
    NSMutableString *szItemName1=[[NSMutableString alloc]init];
    BOOL bSign=NO;
    NSString *szChangeSign=@"";
    NSString *szCsvInfo;
    NSString *szItemSpec=@"";
    NSString *szItemName;
    NSString *szCommand=[self sendcommand:szRead numItem:i];
    NSString *szNameNum=[NSString stringWithFormat:@"%d : ",i];
    NSRange range=[szRead rangeOfString:szNameNum];
    if (range.location!=NSNotFound)
    {
        szRead=[ szRead substringFromIndex:range.location+range.length];
    }
    else
    {
        [tfShow setStringValue:@"Log wrong"];
        m_bFailLog=YES;
        while (1) {
            i++;
            szNameNum=[NSString stringWithFormat:@"%d : ",i];
            range=[szRead rangeOfString:szNameNum];
            NSLog(@"1111");
            if (range.location!=NSNotFound)
            {
                m_iFailLog=i;
                szRead=[ szRead substringFromIndex:range.location+range.length];
                break;
            }
        }
    }
    
    NSRange range1=[szRead rangeOfString:@"\n"];
    if (range1.location!=NSNotFound)
    {
        szRead=[szRead substringToIndex:range1.location+range1.length];
        range=[szRead rangeOfString:@"["];
        if(range.location!=NSNotFound)
        {
            szItemSpec=[szRead substringFromIndex:(range.location+range.length)-1];
            NSRange spec=[szItemSpec rangeOfString:@"\n"];
            szItemSpec=[szItemSpec substringToIndex:spec.location+spec.length-1];
            szItemName=[szRead substringToIndex:(range.location+range.length)-1];
            [szItemSpec1 setString:szItemSpec];
            range=[szItemSpec1 rangeOfString:@"\r"];
            if(range.location!=NSNotFound)
            {
                [szItemSpec1 replaceCharactersInRange:range withString:@""];
            }
            
            int i=0;
            while (1)
            {
                NSRange range3=[szItemSpec1 rangeOfString:@","];
                if (range3.location!=NSNotFound)
                {
                    i++;
                    [strChangeSign setString:szItemSpec1];
                    [strChangeSign replaceCharactersInRange:range3 withString:@""];
                    [szItemSpec1 replaceCharactersInRange:range3 withString:@" "];
                }
                else
                {
                    if (i==1)
                    {
                        szChangeSign=[NSString stringWithFormat:@"%@",strChangeSign];
                        for (i=1; i<[szChangeSign length]-1; i++)
                        {
                            char c=[szChangeSign characterAtIndex:i];
                            
                            if((c>='0'&&c<='9')||c=='-'||c=='N'||c=='A'||c=='.'||c=='/')
                                ;
                            else
                            {
                                bSign=YES;
                                break;
                            }
                        }
                        break;
                        
                    }
                    else
                    {
                        bSign=YES;
                        break;
                    }
                }
            }
            if ([szItemSpec1 isEqualTo:@"[]"])
            {
                [szItemSpec1 setString:@""];
            }
            if(bSign)
            {
                range=[szItemSpec1 rangeOfString:@"["];
                if (range.location!=NSNotFound)
                {
                    [szItemSpec1 replaceCharactersInRange:range withString:@"{"];
                }
                range=[szItemSpec1 rangeOfString:@"]"];
                if(range.location!=NSNotFound)
                {
                    [szItemSpec1 replaceCharactersInRange:range withString:@"}"];
                }
            }
            szItemSpec=[NSString stringWithFormat:@"%@",szItemSpec1];
        }
        else
        {
            szItemName =[szRead substringToIndex:(range1.location+range1.length-1)];
        }
    }
    
    if([szItemSpec isEqualTo: @""])
    {
        szItemSpec=@"N/A";
    }
    [szItemName1 setString:szItemName];
    range=[szItemName1 rangeOfString:@"\r"];
    
    if(range.location!=NSNotFound)
    {
        NSLog(@"sf332edsf");
        [szItemName1 replaceCharactersInRange:range withString:@""];
    }
    szItemName=[NSString stringWithFormat:@"%@",szItemName1];
    szCsvInfo=[NSString stringWithFormat:@"%@,%@,%@",szItemName,szItemSpec,szCommand];
    return szCsvInfo;
}



-(NSString*)sendcommand:(NSString*)szRead numItem:(int)i
{
    NSString *szCsvInfo=@"";
    NSString *szCatch;
    NSString *szCommand=@"";
    NSString *szDelay;
    NSString *szDelayToCsv=@"";
    BOOL bMikey=NO;
    NSArray *arrItem=[szRead componentsSeparatedByString:@"send[S"];
    for (int j=1; j<[arrItem count]; j++)
    {
        NSMutableString *strCom=[[NSMutableString alloc]init];
        NSMutableString *strMikey=[[NSMutableString alloc]init];
        [strCom setString:@""];
        NSString *szItem=[arrItem objectAtIndex:j];
        szCatch=szItem;
        szDelay=szItem;
        NSRange range=[szCatch rangeOfString:@"uccess]: "];
        if (range.location!=NSNotFound)
        {
            szCatch=[szCatch substringFromIndex:(range.location+range.length-1)];
            NSRange range3=[szCatch rangeOfString:@"\n"];
            if (range3.location!=NSNotFound)
            {
                szCommand = [szCatch substringToIndex:range3.location+range3.length];
                [strCom setString:szCommand];
                [strCom replaceCharactersInRange:range3 withString:@""];
                
            }
            range3=[strCom rangeOfString:@"\r"];
            if (range3.location!=NSNotFound)
            {
                [strCom replaceCharactersInRange:range3 withString:@""];
                range3=[strCom rangeOfString:@"\r"];
                if (range3.location!=NSNotFound)
                {
                    [strCom replaceCharactersInRange:range3 withString:@""];
                }
                range3=[strCom rangeOfString:@"\n"];
                if (range3.location!=NSNotFound)
                {
                    [strCom replaceCharactersInRange:range3 withString:@""];
                }
            }
            if([strCom length]==2)
            {
                range=[szCatch rangeOfString:@"receive: "];
                if (range.location!=NSNotFound)
                {
                    szCatch=[szCatch substringFromIndex:(range.location+range.length-1)];
                    NSRange range3=[szCatch rangeOfString:@"\n"];
                    if (range3.location!=NSNotFound)
                    {
                        szCommand = [szCatch substringToIndex:range3.location+range3.length];
                        [strMikey setString:szCommand];
                        [strMikey replaceCharactersInRange:range3 withString:@""];
                        range3=[strMikey rangeOfString:@"\r"];
                        if (range3.location!=NSNotFound)
                            [strMikey replaceCharactersInRange:range3 withString:@""];
                        
                    }
                    if (![strCom isEqualTo:strMikey])
                        bMikey=YES;
                }
            }
            NSRange range1=[szItem rangeOfString:@":-)"];
            NSRange range2=[szItem rangeOfString:@"*_*"];
            NSRange range5=[szItem rangeOfString:@"cmd undefined"];
            NSRange range6=[strCom rangeOfString:@" -"];
            
            if((range1.location!=NSNotFound||range6.location!=NSNotFound) && [strCom length]>=3 && !bMikey)
            {
                szCommand=[NSString stringWithFormat:@"[MOBILE]%@",strCom];
            }
            else if ((range2.location!=NSNotFound ||range5.location!=NSNotFound)&& [strCom length]>=3 && !bMikey)
            {
                szCommand=[NSString stringWithFormat:@"[FIXTURE]%@",strCom];
            }
            else if(bMikey && ![strCom isEqualTo:strMikey])
            {
                szCommand=[NSString stringWithFormat:@"[MIKEY]%@",strMikey];
                bMikey=NO;
            }
            else if([strCom length]>3 && !bMikey)
            {
                szCommand=[NSString stringWithFormat:@"[???]%@",strCom];
            }
            else
                szCommand=@"";
            szCatch=@"";
            NSRange range=[szDelay rangeOfString:@"Delay "];
            if (range.location!=NSNotFound)
            {
                szCatch =[ szDelay substringFromIndex:range.location+range.length];
                NSRange spec=[szCatch rangeOfString:@" ms"];
                if (spec.location!=NSNotFound)
                {
                    szCatch=[szCatch substringToIndex:spec.location+spec.length];
                }
                szDelayToCsv=[NSString stringWithFormat:@"[Delay]%@",szCatch];
            }
            
            if(szCommand !=@"")
            {
                if ([szCsvInfo isEqualTo:@""])
                {
                    szCsvInfo=[NSString stringWithFormat:@"%@",szCommand];
                }
                else
                {
                    szCsvInfo=[NSString stringWithFormat:@"%@\r%@",szCsvInfo,szCommand];
                    
                }
            }
            if(szDelayToCsv!=@"")
            {
                if ([szCsvInfo isEqualTo:@""])
                {
                    szCsvInfo=[NSString stringWithFormat:@"%@",szDelayToCsv];
                }
                else
                    szCsvInfo=[NSString stringWithFormat:@"%@\r%@",szCsvInfo,szDelayToCsv];
                szDelayToCsv=@"";
            }
        }
    }
    szCsvInfo=[NSString stringWithFormat:@"\"%@\n\"",szCsvInfo];
    return szCsvInfo;
}

-(void)WriteToCsv:(NSString*)szReadFromTxt
{
//    NSString* szFilePath1=[tfFilePath stringValue];
//    NSString* strStationName=[NSString stringWithFormat:@"%@",[szFilePath1 lastPathComponent]];
//    NSArray* arrName=[strStationName componentsSeparatedByString:@"_"];
//    strStationName=[NSString stringWithFormat:@"%@_%@",[arrName objectAtIndex:2],[arrName objectAtIndex:3]];
//    m_strStationNameofSouth1=[NSString stringWithFormat:@"%@",[arrName objectAtIndex:3]];
//    m_strStationNameofSouth=[NSString stringWithString:strStationName];
//    NSString *szFilePath =@"/vault/CompareCSV/South";
//    NSString *szFileName=[NSString stringWithFormat:@"%@_%@",m_strStationNameofSouth,m_szTime];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:m_szFilePath])
    {
        [fileManager createDirectoryAtPath:m_szFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSMutableString *szContents = [[NSMutableString alloc] initWithString:@""];
    [szContents appendString:szReadFromTxt];
    NSData *data = [[NSData alloc] initWithBytes:[szContents UTF8String] length:[szContents length]];
    NSFileHandle *filehandle = [NSFileHandle fileHandleForWritingAtPath:[NSString stringWithFormat:@"%@/%@.csv",m_szFilePath,m_szFileName]];
    if (!filehandle)
    {
        [szContents writeToFile:[NSString stringWithFormat:@"%@/%@.csv",m_szFilePath,m_szFileName] atomically:NO encoding:NSUTF8StringEncoding error:nil];
    }
    else
    {
        [filehandle seekToEndOfFile];
        [filehandle writeData:data];
    }
    [tfFileToPath setStringValue:[NSString stringWithFormat:@"%@/%@.csv",m_szFilePath,m_szFileName]];
    m_strPath2=[tfFileToPath stringValue];
    [tfShowCSV2Path setStringValue:m_strPath2];
    m_strCSV2Path=[NSString stringWithString:m_strPath2];
    [filehandle closeFile];
    
}


#pragma mark --action compare
-(IBAction)AddCSV1:(id)sender
{
    m_strPath1=[NSString stringWithFormat:@""];
    m_strCSV1Path=[NSString stringWithFormat:@""];
    m_strStationNameofOurs=@"";
    [tfShowCSV1Path setStringValue:@""];
        NSOpenPanel* opCSV=[NSOpenPanel openPanel];
        [opCSV setCanChooseFiles:YES];
        [opCSV setCanChooseDirectories:NO];
        [opCSV setAllowedFileTypes:[NSArray arrayWithObjects:@"csv",nil]];
        if([opCSV runModal] == NSOKButton)
        {
            NSArray  * aryPath = [opCSV URLs];
            m_strCSV1Path = [[[[aryPath objectAtIndex:0] absoluteString] substringFromIndex:16]stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
            NSString* strStationName=[NSString stringWithFormat:@"%@",[m_strCSV1Path lastPathComponent]];
            NSArray* arrName=[strStationName componentsSeparatedByString:@"_"];
            m_strStationNameofOurs=[NSString stringWithFormat:@"%@_%@",[arrName objectAtIndex:0],[arrName objectAtIndex:1]];
            m_strStationNameofOurs1=[NSString stringWithFormat:@"%@",[arrName objectAtIndex:1]];
            [tfShowCSV1Path setStringValue:m_strCSV1Path];
        }
}
-(IBAction)AddCSV2:(id)sender
{
    m_strPath2=[NSString stringWithFormat:@""];
    m_strCSV2Path=[NSString stringWithFormat:@""];
    m_strStationNameofSouth=@"";
    [tfShowCSV2Path setStringValue:@""];
    NSOpenPanel* opCSV=[NSOpenPanel openPanel];
    [opCSV setCanChooseFiles:YES];
    [opCSV setCanChooseDirectories:NO];
    //    [opCSV beginSheetModalForWindow:_window completionHandler:nil];
    [opCSV setAllowedFileTypes:[NSArray arrayWithObjects:@"csv",nil]];
    if([opCSV runModal] == NSOKButton)
    {
        NSArray  * aryPath = [opCSV URLs];
        m_strCSV2Path = [[[[aryPath objectAtIndex:0] absoluteString] substringFromIndex:16]stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
        NSString* strStationName=[NSString stringWithFormat:@"%@",[m_strCSV2Path lastPathComponent]];
        NSArray* arrName=[strStationName componentsSeparatedByString:@"_"];
        m_strStationNameofSouth=[NSString stringWithFormat:@"%@_%@",[arrName objectAtIndex:0],[arrName objectAtIndex:1]];
        m_strStationNameofSouth1=[NSString stringWithFormat:@"%@",[arrName objectAtIndex:1]];
        [tfShowCSV2Path setStringValue:m_strCSV2Path];
    }

   
}
-(IBAction)Compare:(id)sender
{
    if ([m_strCSV1Path isEqualTo:@""]||[m_strCSV2Path isEqualTo:@""]) {
        NSRunAlertPanel(@"WARNING", @"Please add CSV file", @"OK", nil, nil);
        return;
    }
    if ([m_strCSV2Path isEqualTo:m_strCSV1Path]&&![m_strCSV1Path isEqualTo:@""]&&![m_strCSV2Path isEqualTo:@""]) {
        NSInteger result=NSRunAlertPanel(@"WARNING", @"Two CSV files are the same.", @"Continue", @"Cancel", nil);
        if (result==NSAlertAlternateReturn) {
            return;
        }
    }
    if (![m_strStationNameofOurs1 isEqualToString:m_strStationNameofSouth1]) {
        NSInteger result=NSRunAlertPanel(@"WARNING", @"Two CSV files are different station.", @"Continue", @"Cancel", nil);
        if (result==NSAlertAlternateReturn) {
            return;
        }
    }
    NSString* strFile1= [NSString  stringWithContentsOfFile:m_strCSV1Path encoding:NSUTF8StringEncoding error:nil];
    NSString* strFile2= [NSString  stringWithContentsOfFile:m_strCSV2Path encoding:NSUTF8StringEncoding error:nil];
    if ([strFile1 isEqualTo:@""]||[strFile2 isEqualTo:@""]) {
        NSRunAlertPanel(@"WARNING", @"CSV file is empty.Please add again", @"OK", nil, nil);
    }
    NSArray* arrRowInfo1=[strFile1 componentsSeparatedByString:@"\n"];
    NSArray* arrRowInfo2=[strFile2 componentsSeparatedByString:@"\n"];
    
    NSMutableArray* arrTestItems1=[[NSMutableArray alloc]init];
    NSMutableArray* arrTestLimits1=[[NSMutableArray alloc]init];
    NSMutableArray* arrCommand1=[[NSMutableArray alloc]init];
    
    NSMutableArray* arrTestItems2=[[NSMutableArray alloc]init];
    NSMutableArray* arrTestLimits2=[[NSMutableArray alloc]init];
    NSMutableArray* arrCommand2=[[NSMutableArray alloc]init];
    
    NSMutableArray* arrTestItems3=[[NSMutableArray alloc]init];
    NSMutableArray* arrTestLimits3a=[[NSMutableArray alloc]init];
    NSMutableArray* arrTestLimits3b=[[NSMutableArray alloc]init];
    NSMutableArray* arrCommand3a=[[NSMutableArray alloc]init];
    NSMutableArray* arrCommand3b=[[NSMutableArray alloc]init];
    
    NSMutableArray* arrAddItems=[[NSMutableArray alloc]init];
    NSMutableArray* arrAddLimits=[[NSMutableArray alloc]init];
    NSMutableArray* arrAddSpaceLimits1=[[NSMutableArray alloc]init];
    NSMutableArray* arrAddSpaceLimits2=[[NSMutableArray alloc]init];
    NSMutableArray* arrAddCommand=[[NSMutableArray alloc]init];
    NSMutableArray* arrAddSpaceCommand1=[[NSMutableArray alloc]init];
    NSMutableArray* arrAddSpaceCommand2=[[NSMutableArray alloc]init];
    
    
    NSMutableArray* arrDelItems=[[NSMutableArray alloc]init];
    NSMutableArray* arrDelLimits=[[NSMutableArray alloc]init];
    NSMutableArray* arrDelCommand=[[NSMutableArray alloc]init];
    
    NSMutableArray* arrNote=[[NSMutableArray alloc]init];
    NSMutableArray* arrNote_New=[[NSMutableArray alloc]init];
    NSMutableArray* arrNote_Del=[[NSMutableArray alloc]init];
    
    NSMutableArray* arrComparedNum=[[NSMutableArray alloc]init];
//Memory items , limits and command form our csv brfore comparing
    NSString* strItem1a=[arrRowInfo1 objectAtIndex:1];
    NSArray* arrColInfo1a=[strItem1a componentsSeparatedByString:@","];
    NSMutableString* strCommand1a=[[NSMutableString alloc]init];
    strCommand1a=[arrColInfo1a objectAtIndex:3];
    NSRange range1a;
    range1a=[strCommand1a rangeOfString:@"\""];
    BOOL bFlag1a;
    if ([strCommand1a length]>1) {
        range1a.location=range1a.location+[strCommand1a length]-1;
        NSString* strSingna1a=[strCommand1a substringFromIndex:range1a.location ];
        if ([strSingna1a isEqualToString:@"\""]||[strSingna1a isEqualToString:@"\r"]) {
            bFlag1a=YES;
        }else
            bFlag1a=NO;

    }else
        bFlag1a=NO;
        
    for (int i=1; i<[arrRowInfo1 count]-1; i++) {
        NSString* strItem1=[arrRowInfo1 objectAtIndex:i];
        NSArray* arrColInfo1=[strItem1 componentsSeparatedByString:@","];
        for (int j=1; j<[arrColInfo1 count]; j++) {
            if (j==1) {
                NSString* strItems=[arrColInfo1 objectAtIndex:j];
                strItems=[strItems stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                [arrTestItems1 addObject:strItems];
            }else
                if (j==2) {
                    [arrTestLimits1 addObject:[arrColInfo1 objectAtIndex:j]];
                }else
                    if(j==3)
                    {
                        NSString* strCommand=[arrColInfo1 objectAtIndex:j];
                        NSMutableString *strCommandTemp = [strCommand mutableCopy];
                        if ([arrColInfo1 count]>4) {
                            for (int a=4; a<[arrColInfo1 count]; a++) {
                                [strCommandTemp appendString:@","];
                                [strCommandTemp appendString:[arrColInfo1 objectAtIndex:a]];
                            }
                        }
                        NSMutableString *szCommand=[[NSMutableString alloc]init];
                        [szCommand setString:strCommandTemp];
                        NSRange range1;
                        range1=[szCommand rangeOfString:@"\""];
                        if(range1.location!=NSNotFound)
                           {
                                [szCommand replaceCharactersInRange:range1 withString:@""];
                            }
                        if (bFlag1a) {
                            range1.location=range1.location+[szCommand length]-1;
                            if(range1.location!=NSNotFound)
                            {
                                [szCommand replaceCharactersInRange:range1 withString:@""];
                            }
                        }
//                        if ([szCommand length]!=0) {
//                            range1.location=range1.location+[szCommand length]-1;
//                            NSString* strSingna=[szCommand substringFromIndex:range1.location];
//                            if ([strSingna isEqualToString:@"\""]||[strSingna isEqualToString:@"\r"]) {
//                                if(range1.location!=NSNotFound)
//                                {
//                                    [szCommand replaceCharactersInRange:range1 withString:@""];
//                                    NSLog(@"2");
//                                }
//                            }
//                        }
                        [arrCommand1 addObject:szCommand];
                    }
        }
    }
//Memory items , limits and command form south csv brfore comparing
    NSString* strItem1b=[arrRowInfo2 objectAtIndex:1];
    NSArray* arrColInfo1b=[strItem1b componentsSeparatedByString:@","];
    NSMutableString* strCommand1b=[[NSMutableString alloc]init];
    strCommand1b=[arrColInfo1b objectAtIndex:3];
    NSRange range1b;
    range1b=[strCommand1b rangeOfString:@"\""];
    BOOL bFlag1b;
    if ([strCommand1b length]>1) {
        range1b.location=range1b.location+[strCommand1b length]-1;
        NSString* strSingna1b=[strCommand1b substringFromIndex:range1b.location ];
        if ([strSingna1b isEqualToString:@"\""]||[strSingna1b isEqualToString:@"\r"]) {
            bFlag1b=YES;
        }else
            bFlag1b=NO;
        
    }else
        bFlag1b=NO;
    
    for (int i=1; i<[arrRowInfo2 count]-1; i++) {
            NSString* strItem2=[arrRowInfo2 objectAtIndex:i];
            NSArray* arrColInfo2=[strItem2 componentsSeparatedByString:@","];
            for (int j=1; j<[arrColInfo2 count]; j++) {
                if (j==1) {
                    NSString* strItems=[arrColInfo2 objectAtIndex:j];
                    strItems=[strItems stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    if ([strItems ContainString:@"QS"]) {
                        strItems=[strItems stringByReplacingOccurrencesOfString:@"QS" withString:@"J8"];
                    }
                    [arrTestItems2 addObject:strItems];
                }else
                    if (j==2){
                        [arrTestLimits2 addObject:[arrColInfo2 objectAtIndex:j]];
                    }else
                        if (j==3) {
                            NSString* strCommand=[arrColInfo2 objectAtIndex:j];
                            NSMutableString *strCommandTemp = [strCommand mutableCopy];
                            if ([arrColInfo2 count]>4) {
                                for (int a=4; a<[arrColInfo2 count]; a++) {
                                    [strCommandTemp appendString:@","];
                                    [strCommandTemp appendString:[arrColInfo2 objectAtIndex:a]];
                                }
                            }
                            NSMutableString *szCommand=[[NSMutableString alloc]init];
                            [szCommand setString:strCommandTemp];
                            NSRange range1;
                            range1=[szCommand rangeOfString:@"\""];
                            if(range1.location!=NSNotFound)
                            {
                                [szCommand replaceCharactersInRange:range1 withString:@""];

                            }
                            if (bFlag1b) {
                                range1.location=range1.location+[szCommand length]-1;
                                if(range1.location!=NSNotFound)
                                {
                                    [szCommand replaceCharactersInRange:range1 withString:@""];
                                }
                            }
                            strCommand=[strCommand stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
                            [arrCommand2 addObject:szCommand];
                        }
            }
        }
//COMPARE
    for (int i=0; i<[arrTestItems1 count]; i++) {
        NSString* strTestItem1=[arrTestItems1 objectAtIndex:i];
        NSString* strTestLimit1=[arrTestLimits1 objectAtIndex:i];
        NSString* strCommand1=[arrCommand1 objectAtIndex:i];
        NSMutableString* szCommand1=[[NSMutableString alloc]initWithString:strCommand1];
        NSRange range1;
        while (1) {
            range1=[szCommand1 rangeOfString:@"\r"];
            if(range1.location!=NSNotFound)
            {
                [szCommand1 replaceCharactersInRange:range1 withString:@""];
            }
            else
                break;
        }
        
        for (int j=0; j<[arrTestItems2 count]; j++) {
            if ([arrComparedNum containsObject:[NSString stringWithFormat:@"%d",j]]) {
                continue;
            }
            NSString* strTestItem2=[arrTestItems2 objectAtIndex:j];
            if ([strTestItem1 isEqualToString:strTestItem2]) {
                [arrTestItems3 addObject:strTestItem1];
                [arrComparedNum addObject:[NSString stringWithFormat:@"%d",j]];
                NSString* strTestLimit2=[arrTestLimits2 objectAtIndex:j];
                NSMutableString* strCommand2=[arrCommand2 objectAtIndex:j];
                NSMutableString* szCommand2=[[NSMutableString alloc]initWithString:strCommand2];
                NSRange range2;
                while (1) {
                    range2=[szCommand2 rangeOfString:@"\r"];
                    if(range2.location!=NSNotFound)
                    {
                        [szCommand2 replaceCharactersInRange:range2 withString:@""];
                    }
                    else
                        break;
                }
                if ([strTestLimit1 isEqualToString:strTestLimit2]&&[szCommand1 isEqualToString:szCommand2]) {
                    [arrTestLimits3a addObject:strTestLimit1];
                    [arrTestLimits3b addObject:strTestLimit1];
                    [arrCommand3a addObject:strCommand1];
                    [arrCommand3b addObject:strCommand1];
                    [arrNote addObject:@"OK"];
                }else
                    if ([strTestLimit1 isEqualToString:strTestLimit2]&&![szCommand1 isEqualToString:szCommand2]) {
                        [arrTestLimits3a addObject:strTestLimit1];
                        [arrTestLimits3b addObject:strTestLimit1];
                        [arrCommand3a addObject:strCommand1];
                        [arrCommand3b addObject:strCommand2];
                        [arrNote addObject:@"Different Command"];
                    }else
                        if (![strTestLimit1 isEqualToString:strTestLimit2]&&[szCommand1 isEqualToString:szCommand2]) {
                            [arrTestLimits3a addObject:strTestLimit1];
                            [arrTestLimits3b addObject:strTestLimit2];
                            [arrCommand3a addObject:strCommand1];
                            [arrCommand3b addObject:strCommand1];
                            [arrNote addObject:@"Different Limit"];
                        }else
                            if (![strTestLimit1 isEqualToString:strTestLimit2]&&![szCommand1 isEqualToString:szCommand2]) {
                                [arrTestLimits3a addObject:strTestLimit1];
                                [arrTestLimits3b addObject:strTestLimit2];
                                [arrCommand3a addObject:strCommand1];
                                [arrCommand3b addObject:strCommand2];
                                [arrNote addObject:@"Different Command and Different Limit"];
                            }
                break;
            }else{
                if (j==[arrTestItems2 count]-1) {
                    [arrAddItems addObject:strTestItem1];
                    [arrAddLimits addObject:strTestLimit1];
                    [arrAddSpaceLimits2 addObject:@""];
                    [arrAddCommand addObject:strCommand1];
                    [arrAddSpaceCommand2 addObject:@""];
                    [arrNote_New addObject:@"NewItem"];
                }
                continue;
            }
        }
    }
    for (int i=0; i<[arrTestItems2 count]; i++) {
        NSString* strTestItem2=[arrTestItems2 objectAtIndex:i];
        NSString* strTestLimit2=[arrTestLimits2 objectAtIndex:i];
        NSString* strCommand2=[arrCommand2 objectAtIndex:i];
        NSMutableString* szCommand2=[[NSMutableString alloc]initWithString:strCommand2];
        NSRange range2;
        while (1) {
            range2=[szCommand2 rangeOfString:@"\r"];
            if(range2.location!=NSNotFound)
            {
                [szCommand2 replaceCharactersInRange:range2 withString:@""];
            }
            else
                break;
        }
        for (int j=0; j<[arrTestItems1 count]; j++) {
            NSString* strTestItem1=[arrTestItems1 objectAtIndex:j];
            if ([strTestItem2 isEqualToString:strTestItem1]) {
                break;
            }else{
                if (j==[arrTestItems1 count]-1) {
                    [arrDelItems addObject:strTestItem2];
                    [arrAddSpaceLimits1 addObject:@""];
                    [arrDelLimits addObject:strTestLimit2];
                    [arrDelCommand addObject:strCommand2];
                    [arrAddSpaceCommand1 addObject:@""];
                    [arrNote_Del addObject:@"DeleteItem"];
                }
                continue;
            }
        }
    }

//Memory Items,Limits and Command after comparing
    [arrTestItems3 addObjectsFromArray:arrAddItems];
    [arrTestItems3 addObjectsFromArray:arrDelItems];
    
    [arrTestLimits3a addObjectsFromArray:arrAddLimits];
    [arrTestLimits3a addObjectsFromArray:arrAddSpaceLimits1];
    
    [arrTestLimits3b addObjectsFromArray:arrAddSpaceLimits2];
    [arrTestLimits3b addObjectsFromArray:arrDelLimits];
    
    [arrCommand3a addObjectsFromArray:arrAddCommand];
    [arrCommand3a addObjectsFromArray:arrAddSpaceCommand1];
    
    [arrCommand3b addObjectsFromArray:arrAddSpaceCommand2];
    [arrCommand3b addObjectsFromArray:arrDelCommand];
    
    [arrNote addObjectsFromArray:arrNote_New];
    [arrNote addObjectsFromArray:arrNote_Del];
 
    m_arrTestItems=[NSMutableArray arrayWithArray:arrTestItems3];
    m_arrTestLimits1=[NSMutableArray arrayWithArray:arrTestLimits3a];
    m_arrTestLimits2=[NSMutableArray arrayWithArray:arrTestLimits3b];
    m_arrCommand1=[NSMutableArray arrayWithArray:arrCommand3a];
    m_arrCommand2=[NSMutableArray arrayWithArray:arrCommand3b];
    m_arrNote=[NSMutableArray arrayWithArray:arrNote];
// Write to CSV file
    NSDateFormatter *dateFormatter= [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"YYYYMMddHHmmss"];
	NSString* strCreateTime = [dateFormatter stringFromDate:[NSDate date]];
    NSString* strWritePath=[NSString stringWithFormat:@"/vault/CompareCSV/Compare/%@_%@.csv",m_strStationNameofOurs,strCreateTime];
    [tfShow_CompareCSVPath setStringValue:strWritePath];
    for (int i=0; i<[m_arrTestItems count]; i++) {
        NSString	*strItems=[m_arrTestItems objectAtIndex:i];
        NSString *strLimits1=[m_arrTestLimits1 objectAtIndex:i];
        NSString *strLimits2=[m_arrTestLimits2 objectAtIndex:i];
        NSString *strCommand1=[m_arrCommand1 objectAtIndex:i];
        NSString *strCommand2=[m_arrCommand2 objectAtIndex:i];
        NSString *strNote=[m_arrNote objectAtIndex:i];
        [self writeTestCoverage1:[NSString stringWithFormat:@"%@,%@,%@,\"%@\",\"%@\",%@\n",strItems,strLimits1,strLimits2,strCommand1,strCommand2,strNote] toPath:strWritePath];
    }
    
//the result show in the tableview
    [tvCompareResult reloadData];
}
-(void)writeTestCoverage1:(NSString *)strItemInfo toPath:(NSString *)strPath
{
	NSFileManager	*fileManager = [NSFileManager defaultManager];
	NSFileHandle	*fhTest = [NSFileHandle	 fileHandleForWritingAtPath:strPath];
	if (![fileManager fileExistsAtPath:@"/vault/CompareCSV/Compare"])
	{
		[fileManager createDirectoryAtPath:@"/vault/CompareCSV/Compare" withIntermediateDirectories:YES attributes:nil error:nil];
	}
	if (!fhTest)
	{
		strItemInfo = [NSString stringWithFormat:@"Test Item,Our Test Limit,South Test Limit,Our Command,South Command,Note\n%@",strItemInfo];
		[strItemInfo writeToFile:strPath atomically:NO encoding:NSUTF8StringEncoding error:nil];
	}else
    {
        NSData	*data	= [[NSData alloc] initWithBytes:(void *)[strItemInfo UTF8String]
											  length:[strItemInfo length]];
        [fhTest	seekToEndOfFile];
        [fhTest	writeData:data];
    }
	[fhTest     closeFile];
}
#pragma mark --datasource
-(NSInteger)numberOfRowsInTableView:(NSTableView*)tableView
{
    return [m_arrTestItems count];
}
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	NSString			*strKey=[tableColumn  identifier];
    if ([strKey isEqualToString:@"Test Items"]) {
        NSString	*strItems=[m_arrTestItems objectAtIndex:row];
        return	strItems;
    }else
        if ([strKey isEqualToString:@"Note"]) {
            NSString *strNote=[m_arrNote objectAtIndex:row];
            if ([strNote isEqualToString:@"NewItem"]) {
                [[tableColumn dataCellForRow:row] setDrawsBackground:YES];
                [[tableColumn dataCellForRow:row] setBackgroundColor:[NSColor yellowColor]];
            }else
                if ([strNote isEqualToString:@"DeleteItem"]) {
                    [[tableColumn dataCellForRow:row] setDrawsBackground:YES];
                    [[tableColumn dataCellForRow:row] setBackgroundColor:[NSColor grayColor]];
                }else
                    if ([strNote isEqualToString:@"Different Command"]||[strNote isEqualToString:@"Different Limit"]||[strNote isEqualToString:@"Different Command and Different Limit"]) {
                        [[tableColumn dataCellForRow:row] setDrawsBackground:YES];
                        [[tableColumn dataCellForRow:row] setBackgroundColor:[NSColor orangeColor]];
                    }else
                    {
                        [[tableColumn dataCellForRow:row] setDrawsBackground:YES];
                        [[tableColumn dataCellForRow:row] setBackgroundColor:[NSColor whiteColor]];
                    }
            return strNote;
        }else
            if ([strKey isEqualToString:@"Test Limits1"]) {
                NSString *strLimits1=[m_arrTestLimits1 objectAtIndex:row];
                return strLimits1;
            }else
                if ([strKey isEqualToString:@"Test Limits2"]) {
                NSString *strLimits2=[m_arrTestLimits2 objectAtIndex:row];
                return strLimits2;
            }else
                if ([strKey isEqualToString:@"Command1"]) {
                    NSString *strCommand1=[m_arrCommand1 objectAtIndex:row];
                    return strCommand1;
                }else
                    if ([strKey isEqualToString:@"Command2"]) {
                        NSString *strCommand2=[m_arrCommand2 objectAtIndex:row];
                        return strCommand2;
                    }else
                        {
                            return nil;
                        }
}
#pragma mark --delegate
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    NSString* strCommand1=[m_arrCommand1 objectAtIndex:row];
    NSString* strCommand2=[m_arrCommand2 objectAtIndex:row];
    NSArray* arrComand1=[strCommand1 componentsSeparatedByString:@"\r"];
    NSArray* arrComand2=[strCommand2 componentsSeparatedByString:@"\r"];
    if ([arrComand1 count]>[arrComand2 count]) {
        return [arrComand1 count]*17;
    }else
    {
        return [arrComand2 count]*17;
    }

}
@end
