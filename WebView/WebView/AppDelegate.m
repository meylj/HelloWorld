//
//  AppDelegate.m
//  WebView
//
//  Created by He xiaoyong on 4/17/13.
//  Copyright (c) 2013 Pegatron. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize window = _window;

#pragma mark -life cycle
- (id)init
{
    self = [super init];
    if (self)
	{
		
        bLoadingFlag			= NO;
        bDownloading			= YES;
        iCount					= 0;
        
		szUserName				= [[NSString			alloc] init];
		szPassword				= [[NSString			alloc] init];
        dicSettingFile			= [[NSMutableDictionary alloc] init];
		
        szSettringPath			= [[NSString			alloc] initWithString:[NSString stringWithFormat:@"%@/Contents/Resources%@",[[NSBundle mainBundle] bundlePath],SETTINGFILEPATH]];
        
        szDefaultURL			= [[NSString			alloc] initWithString:@"http://17.239.228.36/cgi-bin/WebObjects/QCR"];
        [self GetSettingFile];
        szPrifixURL				= [[NSString			alloc] initWithString:[szQCRUrl SubTo:@"/cgi-bin/" include:NO]];
		
		szCurrentQuerySN		= [[NSString			alloc] init];
		downLogSetting			= downAllLogs; // default to down all the logs of the station
		szCurrentQueryStation	= [[NSString			alloc] init];
		muArySN					= [[NSMutableArray		alloc] init];
        muAryStation			= [[NSMutableArray		alloc] init];
		muAryLogSetting			= [[NSMutableArray		alloc] init];
        dicMemoryURL			= [[NSMutableDictionary alloc] init];
        // added observer 
        nc	= [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(StartToTest)				name:@"BeginToRun" object:nil];
        [nc addObserver:self selector:@selector(MoveMouseToRun)				name:@"PressToRun" object:nil];
		[nc addObserver:self selector:@selector(downLoadAllLogsOfStation)	name:@"DownAllLogs" object:nil];
		
		aryLogsNeedDown			= [[NSMutableArray		alloc] init];
		dicFailSNList			= [[NSMutableDictionary alloc] init];
		
		NSLog(@"init");
    }
    return self;
}



-(void)awakeFromNib
{
    [txtUserName	setStringValue:szUserName];
    [txtPassword	setStringValue:szPassword];
    
    [labMessage		setStringValue:@"Select csv files to start......"];
    [labMessage		setTextColor:[NSColor redColor]];
	
    [self.window	setTitle:@"Query_From_QCR"];
    NSLog(@"awake");
}

- (void)dealloc
{
    [szQCRUrl				release]; szQCRUrl			= nil;
    [szPrifixURL			release]; szPrifixURL		= nil;
    [szUserName				release]; szUserName		= nil;
    [szPassword				release]; szPassword		= nil;
	[szCurrentQuerySN		release]; szCurrentQuerySN	= nil;
	[szCurrentQueryStation	release]; szCurrentQueryStation = nil;
    [szSettringPath			release]; szSettringPath	= nil;
    [dicSettingFile			release]; dicSettingFile	= nil;
    [dicMemoryURL			release]; dicMemoryURL		= nil;
    [aryLogsNeedDown		release]; aryLogsNeedDown	= nil;
    [muArySN				release]; muArySN			= nil;
    [muAryStation			release]; muAryStation		= nil;
	[muAryLogSetting		release]; muAryLogSetting	= nil;
	[dicFailSNList			release]; dicFailSNList		= nil;
    [super					dealloc];
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [NSApp beginSheet:panelLogin modalForWindow:nil modalDelegate:self didEndSelector:nil contextInfo:nil];
}


#pragma mark  -Login QCR

- (IBAction)Login:(id)sender
{
    [self CheckRemember];
	// check the text field of UserName and Password is empty or not.
	[labelNoticeLogin			setStringValue:@""];
	[labelNoticeUsername		setStringValue:@""];
	
    szUserName = [txtUserName	stringValue];
    szPassword = [txtPassword	stringValue];
    
    if ((!szUserName) || [szUserName isEqualToString:@""]) 
    {
		[labelNoticeUsername setStringValue:@"No username."];
		[btnCheckRemember setEnabled:YES];
        return;
    }
    
    if ((!szPassword) || [szPassword isEqualToString:@""]) 
    {
		[labelNoticeUsername setStringValue:@"No password."];
		[btnCheckRemember setEnabled:YES];
        return;
    }
    // login QCR 
    if ([self LoginQCR]) 
    {
        [NSApp endSheet:panelLogin];
        [panelLogin orderOut:nil];
        // new thread to auto detect the SN files
        [NSThread detachNewThreadSelector:@selector(AutoDetect) toTarget:self withObject:nil];
        [NSApp beginSheet:_window modalForWindow:nil modalDelegate:self didEndSelector:nil contextInfo:nil];
    }
    else
    {
		[btnCheckRemember setEnabled:YES];
        return;
    }
}


- (BOOL)LoginQCR
{    
    // load login page of QCR    
    [self LoadWebURL:szQCRUrl];
    // enter the use name and password to login QCR.
    DOMDocument *domMainWeb		= [[mainWebView mainFrame] DOMDocument];
    DOMNodeList *domInputList	= [domMainWeb getElementsByTagName:@"input"];
    DOMElement	*domUserName;
    DOMElement	*domPassword;
    DOMElement	*domEnterButton;
    
    if (0 >= [domInputList length]) 
    {
		[labelNoticeLogin setStringValue:@"Network unavailable or QCR URL error."];
        return NO;
    }
    
    for (int i = 0; i < [domInputList length]; i++) 
    {
        if ([[(DOMElement *)[domInputList item:i] getAttribute:@"name"] isEqualToString:@"UserName"]) 
        {
            domUserName		= (DOMElement *)[domInputList item:i];
        }
        if ([[(DOMElement *)[domInputList item:i] getAttribute:@"name"] isEqualToString:@"Password"]) 
        {
            domPassword		= (DOMElement *)[domInputList item:i];
        }
        if ([[(DOMElement *)[domInputList item:i] getAttribute:@"name"] isEqualToString:@"3.7.5.13"]) 
        {
            domEnterButton	= (DOMElement *)[domInputList item:i];
            NSLog(@"%@",[(DOMElement *)[domInputList item:i] getAttribute:@"value"]);
        }
    }
    
    if (domUserName && domPassword && domEnterButton) 
    {
        // set user name and password
        [domUserName setAttribute:@"value" value:szUserName];
        [domPassword setAttribute:@"value" value:szPassword];
		if (![self ClickReloadWeb:domEnterButton])
		{
			[labelNoticeLogin setStringValue:@"Can't login QCR with this Account."];
			NSLog(@"Can not login QCR.");
		}        
    }else
    {
        [labelNoticeLogin setStringValue:@"Coding error: can't find input tags."];
        return NO;
    }
    
    domMainWeb				= [[mainWebView mainFrame] DOMDocument];
    DOMNodeList *domTdList	= [domMainWeb	getElementsByTagName:@"td"];
    for (int i = 0; i < [domTdList length]; i++) 
    {
        if ([[(DOMElement *)[domTdList item:i] innerText] isEqualToString:@"Unknown user name!"])
        {
			[labelNoticeUsername setStringValue:@"Unknow username."];
            return NO;
        }
        if ([[(DOMElement *)[domTdList item:i] innerText] isEqualToString:@"Invalid password"])
        {
			[labelNoticeUsername setStringValue:@"Invalid password."];
            return NO;
        }
    }
    
    return YES;
}


- (BOOL)CheckRemember
{
    [btnCheckRemember setEnabled:NO];
    
    int i =(int)btnCheckRemember.state;
    if (1 == i) 
    {
        NSMutableDictionary *dicChangedAccout = [[NSMutableDictionary alloc] init];
        [dicChangedAccout	setDictionary:[dicSettingFile objectForKey:@"QCR_Accout"]];
        [dicChangedAccout	setObject:[txtUserName stringValue] forKey:@"UserName"];
        [dicChangedAccout	setObject:[txtPassword stringValue] forKey:@"PassWord"];
        [dicSettingFile		setObject:dicChangedAccout			forKey:@"QCR_Accout"];
        
        [dicSettingFile		writeToFile:szSettringPath atomically:NO];
        [dicChangedAccout	release];
		if (szQCRUrl)
        {
			NSMutableDictionary *dicUrl = [[NSMutableDictionary alloc] init];
			[dicUrl			setDictionary:[dicSettingFile objectForKey:@"QCR_URL"]];
			[dicUrl			setObject:szQCRUrl	forKey:@"URL"];
			[dicSettingFile	setObject:dicUrl	forKey:@"QCR_URL"];
			szPrifixURL		= [szQCRUrl SubTo:@"/cgi-bin/" include:NO];
			[dicSettingFile	writeToFile:szSettringPath atomically:NO];
			[dicUrl			release];
        }
    }
    else
    {
        return NO;
    }
    return YES;    
}

- (BOOL)GetSettingFile
{
    NSFileManager *fileManager  = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:szSettringPath]) 
	{
        NSRunAlertPanel(@"Warning", @"Can't find setting file!", @"OK", nil, nil);
        return NO;
	}
	[dicSettingFile setDictionary:[NSDictionary dictionaryWithContentsOfFile:szSettringPath]];
    
    NSDictionary *dicID		= [dicSettingFile	objectForKey:@"QCR_Accout"];
    szUserName				= [dicID			objectForKey:@"UserName"]?[dicID objectForKey:@"UserName"]:@"rachel_xu";
    szPassword				= [dicID			objectForKey:@"PassWord"]?[dicID objectForKey:@"PassWord"]:@"lei1234";
    NSDictionary *dicURL	= [dicSettingFile	objectForKey:@"QCR_URL"];
    szQCRUrl				= [dicURL			objectForKey:@"URL"]?[dicURL objectForKey:@"URL"]:szDefaultURL;
    return YES;
}


#pragma mark    -Testing

- (void)Test
{   
    [_window center];
    
    //add for single test...
	szCurrentQuerySN		= [muArySN			objectAtIndex:0];
	szCurrentQueryStation	= [muAryStation		objectAtIndex:0];
	
	downLogSetting			= [[muAryLogSetting	objectAtIndex:0] intValue];
	
	[txtLog_StationName	setStringValue:szCurrentQueryStation];
    //remove the testing sn from total sn count...
    [muArySN			removeObjectAtIndex:0];
    [muAryStation		removeObjectAtIndex:0];
	[muAryLogSetting	removeObjectAtIndex:0];
	[dicMemoryURL		removeObjectForKey:@"ViewProcessLogs"];

    NSLog(@"query SN [%@],download station name [%@],download setting [%i]",szCurrentQuerySN,szCurrentQueryStation,downLogSetting);
	
    [self Batch_DownLoad_Logs_By_StaitonName:szCurrentQueryStation];
}

- (BOOL)Batch_DownLoad_Logs_By_StaitonName:(NSString *)szStaitonName
{
	if (![self AccessProductHistoryWeb])
	{
		NSString *szError	= @"Can not access product history web";
		NSLog(@"%@",szError);
		[self whenDownloadFail:szError];
		return NO;
	}
	
	if (![self QueryBySN])
	{
		NSString *szError	= @"No Factory Data found for this Serial Number......";
		NSLog(@"%@",szError);
		[self whenDownloadFail:szError];
		return NO;
	}
	if (![self AccessProcessLogsWeb])
	{
		NSString	*szError = @"Load \"View Process Logs\" web failed.";
		NSLog(@"%@",szError);
		[self whenDownloadFail:szError];
		return NO;
	}
	if (![self DownloadLogsByStationName:szStaitonName])
	{
		return NO;
	}
		
    return YES;
}

- (BOOL)DownloadLogsByStationName:(NSString *)szStationName
{    
    DOMDocument *domMainWeb	= [[mainWebView mainFrame] DOMDocument];
    BOOL bDownloadLogs	= NO;

    DOMNodeList *domDownTbList  = [domMainWeb getElementsByTagName:@"table"];
	DOMNodeList *domTdList		= [domMainWeb getElementsByTagName:@"td"];
    DOMNodeList *domDownTrList  = [(DOMElement *)[domDownTbList item:0] getElementsByTagName:@"tr"];
    
    for (int iTR = 0; iTR < [domDownTrList length]; iTR++)
    {
        domTdList    = [(DOMElement *)[domDownTrList item:iTR] getElementsByTagName:@"td"];
        NSString    *szStationSelect	= [NSString stringWithFormat:@"%@_",szStationName];
        if ([[(DOMElement *)[domTdList item:0] innerText] ContainString:szStationSelect]) 
        {
            bDownloadLogs			= YES;
			[aryLogsNeedDown addObject:[NSString stringWithFormat:@"%i",iTR-1]];
        }
    }
	int iMoveTimes = 0;
	if ([aryLogsNeedDown count] >0 && bDownloadLogs)
	{
		switch (downLogSetting)
		{
			case downFirstLog:
				iMoveTimes = [[aryLogsNeedDown objectAtIndex:0] intValue];
				[aryLogsNeedDown removeAllObjects];
				[self PressClick:iMoveTimes];
				break;
			case downLastLog:
				iMoveTimes = [[aryLogsNeedDown lastObject] intValue];
				[aryLogsNeedDown removeAllObjects];
				[self PressClick:iMoveTimes];
				break;
			case downAllLogs:
				NSLog(@"all logs %@",aryLogsNeedDown);
				iMoveTimes = [[aryLogsNeedDown objectAtIndex:0] intValue];
				[aryLogsNeedDown removeObjectAtIndex:0];
				[self PressClick:iMoveTimes];
				break;
			default:
//				bDownloadLogs = NO;
				[self whenDownloadFail:@"Wrong setting.The download log setting must be 0~2."];
				NSLog(@"Wrong setting.The download log setting must be 0~2.");
				break;
		}
	} else
	{
		NSString	*szError = [NSString stringWithFormat:@"There are no logs about the %@ station",szStationName];
        [self whenDownloadFail:szError];
		NSLog(@"%@",szError);
	}
    return bDownloadLogs;
}


-(BOOL)downLoadAllLogsOfStation
{
	
	if (![self AccessProcessLogsWeb])
	{
		[self whenDownloadFail:@"Access process logs web failed when down all logs."];
		return NO;
	}
	int iMoveTimes = [[aryLogsNeedDown objectAtIndex:0] intValue];
	
	NSLog(@"Move total times %i",iMoveTimes);
		
	[aryLogsNeedDown removeObjectAtIndex:0];
	
	[self PressClick:iMoveTimes];
	return YES;
}

- (BOOL)AccessProductHistoryWeb
{
    if ([dicMemoryURL objectForKey:@"ProductHistory"])
    {
        [self LoadWebURL:[dicMemoryURL objectForKey:@"ProductHistory"]];
        return YES;
    }
    
    DOMDocument *domMainWeb			= [[mainWebView	mainFrame] DOMDocument];
    DOMNodeList *domAList			= [domMainWeb	getElementsByTagName:@"a"];
    BOOL bAccessProducthistory		= NO;
    for (int i = 0; i < [domAList length]; i++)
    {
        if([[((DOMElement *)[domAList item:i]) getAttribute:@"href"] ContainString:@"2.1.5.5.13"])
        {
            NSString *szURL			= [NSString stringWithFormat:@"%@%@",szPrifixURL,
									   [(DOMElement *)[domAList item:i] getAttribute:@"href"]];
            [dicMemoryURL setObject:szURL forKey:@"ProductHistory"];
            [self	LoadWebURL:szURL];
            bAccessProducthistory	= YES;
            NSLog(@"Access Product History Web success!");
            break;
        }
    }
	
    return bAccessProducthistory;
}

- (BOOL)QueryBySN
{
    if ((!szCurrentQuerySN) || [@""isEqualToString:szCurrentQuerySN])
    {
		NSLog(@"Queried sn [%@] error!",szCurrentQuerySN);
        return	NO;
    }
    
    DOMDocument *domMainWeb		= [[mainWebView mainFrame] DOMDocument];
    DOMNodeList *domInputList	= [domMainWeb getElementsByTagName:@"input"];
    DOMElement	*domSNInput;
    DOMElement	*domSearchButton;
    
    for (int i = 0; i < [domInputList length]; i++)
    {
        if ([[(DOMElement *)[domInputList item:i] getAttribute:@"name"] isEqualToString:@"7.1.3"]) 
        {
            domSearchButton		= (DOMElement *)[domInputList item:i];
        }
        if ([[(DOMElement *)[domInputList item:i] getAttribute:@"name"] isEqualToString:@"7.1.1"]) 
        {
            domSNInput			= (DOMElement *)[domInputList item:i];
        }
    }
    
    [domSNInput	setAttribute:@"value" value:szCurrentQuerySN];
    
    if (![self ClickReloadWeb:domSearchButton])
    {
		NSLog(@"search nothing with the SN [%@].",szCurrentQuerySN);
        return NO;
    }    
    return YES;
}

- (BOOL)AccessProcessLogsWeb
{
	BOOL bDownloadLogsWeb	= NO;

	if ([dicMemoryURL objectForKey:@"ViewProcessLogs"] && downLogSetting==downAllLogs)
    {
        [self LoadWebURL:[dicMemoryURL objectForKey:@"ViewProcessLogs"]];
		bDownloadLogsWeb = YES;
    }else
	{
		DOMDocument *domMainWeb	= [[mainWebView mainFrame] DOMDocument];
		DOMNodeList *domTdList	= [domMainWeb getElementsByTagName:@"td"];
		DOMNodeList *domAList;
		NSString *szURL = @"";
		for (int i = 0; i < [domTdList length]; i++)
		{
			if([[((DOMElement *)[domTdList item:i]) getAttribute:@"colspan"] isEqualToString:@"4"] &&
			   [[(DOMElement *)[domTdList item:i] innerText] ContainString:@"View Parametric Data"])
			{
				domAList		= [(DOMElement *)[domTdList item:i] getElementsByTagName:@"a"];
				szURL	= [NSString stringWithFormat:@"%@%@",szPrifixURL,
						   [(DOMElement *)[domAList item:1] getAttribute:@"href"]];
				[dicMemoryURL setObject:szURL forKey:@"ViewProcessLogs"];
				[self LoadWebURL:szURL];
				NSLog(@"Access Download logs Web success!");
				bDownloadLogsWeb = YES;
				break;
			}
		}
	}
	
	DOMDocument *domMainWeb	= [[mainWebView mainFrame] DOMDocument];
	DOMNodeList *domTable = [domMainWeb getElementsByTagName:@"Table"];
	
	[(DOMElement *)[domTable item:0] setAttribute:@"style"	value:@"table-layout:fixed;"];
	[(DOMElement *)[domTable item:0] setAttribute:@"width"	value:@"900"];
	DOMNodeList *domTDNodeL = [domMainWeb getElementsByTagName:@"td"];
	
    for (int i = 0; i < [domTDNodeL length]; i++)
    {
        if ([[(DOMElement *)[domTDNodeL item:i] getAttribute:@"align"] isEqualToString:@"LEFT"])
        {
			[(DOMElement *)[domTDNodeL item:i] setAttribute:@"style"	value:@"word-break:keep-all;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;"];
			[(DOMElement *)[domTDNodeL item:i] setAttribute:@"Height"	value:@"30"];

        }
		// all the td set height = 30; width = 300 px
		[(DOMElement *)[domTDNodeL item:i] setAttribute:@"width"	value:@"300"];
    }
	
	return bDownloadLogsWeb;
}

- (NSString *)GetNowTimeStr
{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"YYYYMMddHHmmss"];
    NSString	*szNowTime		= [dateFormat stringFromDate:[NSDate date]];
    [dateFormat release];
    return		szNowTime;
}

#pragma mark    -Thread to detect or remove 


- (void)AutoDetect
{
    NSAutoreleasePool   *pool		= [[NSAutoreleasePool	alloc] init];
    NSFileManager		*fileManager= [NSFileManager		defaultManager];
    
    szSNFileList                    = [NSString stringWithFormat:@"%@/SN_IN",QUERY_INFO_FILEPATH];
    szPass                          = [NSString stringWithFormat:@"%@/PASS",QUERY_INFO_FILEPATH];
    szFail                          = [NSString stringWithFormat:@"%@/FAIL",QUERY_INFO_FILEPATH];
	

    if (![fileManager     fileExistsAtPath:szSNFileList])
    {
        [fileManager createDirectoryAtPath:szSNFileList withIntermediateDirectories:YES attributes:nil error:nil];
    }
	if (![fileManager     fileExistsAtPath:szPass])
    {
        [fileManager createDirectoryAtPath:szPass withIntermediateDirectories:YES attributes:nil error:nil];
    }  
    if (![fileManager     fileExistsAtPath:szFail])
    {
        [fileManager createDirectoryAtPath:szFail withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    while (YES)
    {
		
        NSArray     *arrSNLists             = [fileManager contentsOfDirectoryAtPath:szSNFileList error:nil];		
        NSString    *szFileName;
        for (int i = 0; i < [arrSNLists count]; i++) 
        {
            szFileName						= [arrSNLists objectAtIndex:i];
        
            NSString    *szStringSNPath		= [NSString stringWithFormat:@"%@/%@", szSNFileList,szFileName];
            NSString    *szCurrentString	= [NSString stringWithContentsOfFile:szStringSNPath encoding:NSUTF8StringEncoding error:nil];
            if (!szCurrentString)
            {
                [fileManager removeItemAtPath:szStringSNPath error:nil];
                continue;
            }
			
            NSString  *szCompare = @"\n";
            szCurrentString = [szCurrentString stringByReplacingOccurrencesOfString:@"\r" withString:szCompare];
			szCurrentString = [szCurrentString stringByReplacingOccurrencesOfString:@"\\r" withString:szCompare];
			szCurrentString = [szCurrentString stringByReplacingOccurrencesOfString:@"\r\n" withString:szCompare];
			szCurrentString = [szCurrentString stringByReplacingOccurrencesOfString:@"\n\r" withString:szCompare];
			szCurrentString = [szCurrentString stringByReplacingOccurrencesOfString:@"\n\n" withString:szCompare];
			szCurrentString = [szCurrentString stringByReplacingOccurrencesOfString:@"\r\r" withString:szCompare];
			szCurrentString = [szCurrentString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
            NSArray     *arrCurrent	= [szCurrentString componentsSeparatedByString:szCompare];
			for (int j=0; j<[arrCurrent count]; j++)
			{
				NSArray *aryRecode = [[arrCurrent objectAtIndex:j] componentsSeparatedByString:@","];
				if ([aryRecode count]<3)
				{
					NSLog(@"No usefull data,%@",[arrCurrent objectAtIndex:j]);
					continue;
				}else
				{
					[muArySN			addObject:[aryRecode objectAtIndex:0]];
					[muAryStation		addObject:[aryRecode objectAtIndex:1]];
					[muAryLogSetting	addObject:[aryRecode objectAtIndex:2]];
				}
				
			}
			// remove the SN LIST file that we have read
			[fileManager removeItemAtPath:szStringSNPath error:nil];
		
			// auto detect, if the app is not running post
//            if (!bDownloading)
//            {
//                [nc  postNotificationName:@"BeginToRun" object:self];
//            }
        }
        
        //move item to file when download failed    
        
        NSArray     *arrFailed  = [fileManager contentsOfDirectoryAtPath:szFail error:nil];
		for (int i = 0; i< [arrFailed count]; i++)
		{
			NSString    *szName		= [arrFailed	objectAtIndex:i];
			if ([szName isEqualToString:@"RealFail.CSV"])
			{
				continue;
			}
			if (![fileManager     fileExistsAtPath:szSNFileList])
			{
				[fileManager createDirectoryAtPath:szSNFileList withIntermediateDirectories:YES attributes:nil error:nil];
			}
			NSString    *szFile		= [NSString	stringWithFormat:@"%@/%@",szFail,szName];
			NSString	*szToPath	= [NSString	stringWithFormat:@"%@/%@",szSNFileList,szName];
			[fileManager moveItemAtPath:szFile toPath:szToPath error:nil];
		}
		if ([muArySN count]<1 && [dicFailSNList count]<1 && !bDownloading)
		{
			[btnSelect			setEnabled:YES];
			[btnRun				setEnabled:YES];
			[labMessage			setStringValue:@"Add new SN list to query...."];
			[txtLog_StationName	setStringValue:@"No SN To Query..."];
		}else if([muArySN count]>0)
		{
			[nc postNotificationName:@"PressToRun" object:self];
		}
		// Every 5 seconds to auto detect.
        sleep(5);
    }
	[pool drain];
       
}

- (IBAction)selectQueryFiles:(id)sender
{
	NSOpenPanel *oPanel = [NSOpenPanel openPanel];
    [oPanel setAllowsMultipleSelection:NO];
    [oPanel setDelegate:self];
    [oPanel beginSheetModalForWindow:_window completionHandler:nil];
	
}


- (IBAction)Start:(id)sender
{   
    [self.window	center];
    [btnRun			setEnabled:NO];
	[btnSelect		setEnabled:NO];
	[txtSNFilePath	setEnabled:NO];
	[labMessage		setStringValue:@"Running"];
	
    
    if ([muArySN count] > 0)
    {
        bDownloading    = YES;
        [nc  postNotificationName:@"BeginToRun" object:self];
    }
    else 
    {
        bDownloading    = NO;
		[btnRun			setEnabled:YES];
		[btnSelect		setEnabled:YES];
		[txtSNFilePath	setEnabled:YES];
		return;
    }
}

- (void)StartToTest
{
	if([muArySN count] > 0)
	{
		[self performSelectorOnMainThread:@selector(Test) withObject:nil waitUntilDone:NO];
	}
	
}

- (void)whenDownloadFail:(NSString *)szInfo
{
	NSString	*szFailFileName	= [NSString stringWithFormat:@"%@/FAIL.CSV",szFail];
	
	NSString	*szNowTime		= [self GetNowTimeStr];

	szCurrentQuerySN			= [szCurrentQuerySN			stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	szCurrentQueryStation		= [szCurrentQueryStation	stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	

	NSString	*szFailInfo		= [NSString stringWithFormat:@"%@,%@,%u,%@\n",szCurrentQuerySN,szCurrentQueryStation,downLogSetting,szNowTime];
	NSArray		*aryKeys		= [dicFailSNList allKeys];
	int iFailedCount			= 1;
	if (![aryKeys containsObject:szCurrentQuerySN])
	{
		[dicFailSNList setObject:[NSString stringWithFormat:@"%i",1] forKey:szCurrentQuerySN];
	}else
	{
		iFailedCount = [[dicFailSNList objectForKey:szCurrentQuerySN] intValue];
		if (iFailedCount< RealFailCount-1)
		{
			[dicFailSNList setObject:[NSString stringWithFormat:@"%i",iFailedCount+1] forKey:szCurrentQuerySN];
		}else
		{
			szFailFileName	= [NSString stringWithFormat:@"%@/RealFail.CSV",szFail];
			szInfo			= [szInfo	stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			szFailInfo		= [NSString stringWithFormat:@"%@,%@,%u,%@,%@\n",szCurrentQuerySN,szCurrentQueryStation,downLogSetting,szInfo,szNowTime];
			[dicFailSNList	removeObjectForKey:szCurrentQuerySN];
		}
	}
	
	NSFileManager   *fileManager    = [NSFileManager defaultManager];
    NSFileHandle    *fhFail         = [NSFileHandle fileHandleForWritingAtPath:szFailFileName];

    if (![fileManager fileExistsAtPath:szFail])
    {
        [fileManager createDirectoryAtPath:szFail withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if (!fhFail)
    {
        [szFailInfo writeToFile:szFailFileName atomically:NO encoding:NSUTF8StringEncoding error:nil];
    }
    else
    {
        NSData	*data	= [[NSData alloc] initWithBytes:(void *)[szFailInfo UTF8String]
														 length:[szFailInfo length]];
        [fhFail	seekToEndOfFile];
        [fhFail	writeData:data];
        [data	release];
    }
	[fhFail     closeFile];
	// Do some preparation for query next SN.
	[btnRun		setEnabled:YES];
	// begin to query next SN
	[nc			postNotificationName:@"PressToRun" object:self];
}

- (void)whenDownloadPass:(NSString *)szInfo
{
    NSString        *szPASSFileName = [NSString		 stringWithFormat:@"%@/PASS.CSV",szPass];
    NSFileManager   *fileManager    = [NSFileManager defaultManager];
    NSFileHandle    *fhPass         = [NSFileHandle	 fileHandleForWritingAtPath:szPASSFileName];
    
	NSArray *aryFailSNList = [dicFailSNList allKeys];
	if ([aryFailSNList containsObject:szCurrentQuerySN])
	{
		[dicFailSNList removeObjectForKey:szCurrentQuerySN];
	}
	
    if (![fileManager     fileExistsAtPath:szPass])
    {
        [fileManager createDirectoryAtPath:szPass withIntermediateDirectories:YES attributes:nil error:nil];
    }  
    
    if (!fhPass)
    {
        [szInfo writeToFile:szPASSFileName atomically:NO encoding:NSUTF8StringEncoding error:nil];
    }
    else
    {
        NSData		*data	= [[NSData alloc] initWithBytes:(void *)[szInfo UTF8String]
											   length:[szInfo length]];
        [fhPass     seekToEndOfFile];
        [fhPass     writeData:data];
        [data       release];
    }
	[fhPass     closeFile];
	// Do some preparation for query next SN.
	[btnRun		setEnabled:YES];
//	szCurrentQuerySN = @"";
	[nc			postNotificationName:@"PressToRun" object:self];
}



#pragma mark  -some movement on UI

- (void)MoveMouseToRun
{
	[self SetMainWindow];
    NSScreen        *screen     =   [NSScreen mainScreen];
    
    CGPoint         point       = {[_window frame].origin.x + 880, [screen frame].size.height - ([_window frame].origin.y + 660)};
    
    CGEventRef      mouseEvent  = CGEventCreateMouseEvent(NULL, kCGEventLeftMouseDown, point, kCGMouseButtonLeft);
    CGEventPost(kCGHIDEventTap, mouseEvent);
    
    CGEventRef      mouseEvent1	= CGEventCreateMouseEvent(NULL, kCGEventLeftMouseUp, point, kCGMouseButtonLeft);
    CGEventPost(kCGHIDEventTap, mouseEvent1);
    
    
    CFRelease(mouseEvent);
    CFRelease(mouseEvent1);
}

- (void)PressClick:(int)iMoveTimes
{
	[self	SetMainWindow];
    NSScreen	*screen		= [NSScreen mainScreen];
    float		fY			= [screen frame].size.height;
	CGPoint		point		= {[_window frame].origin.x +777, fY - ([_window frame].origin.y +546)};
    
    NSLog(@"x= %.1f , y= %.1f ",point.x,point.y);
    [self	scrollDown:iMoveTimes];
	//sleep(1);
    CGEventRef mouseEvent	= CGEventCreateMouseEvent(NULL, kCGEventLeftMouseDown, point, kCGMouseButtonLeft);
    CGEventPost(kCGHIDEventTap, mouseEvent);
    
    CGEventRef mouseEvent1	= CGEventCreateMouseEvent(NULL, kCGEventLeftMouseUp, point, kCGMouseButtonLeft);
    CGEventPost(kCGHIDEventTap, mouseEvent1);
    
    CFRelease(mouseEvent);
    CFRelease(mouseEvent1);
	sleep(1);
	NSLog(@"click");
}


- (void)scrollDown:(int)iMoveTimes
{
    float   fDistance   = 36;
    NSScrollView *myScrollView = [[[[mainWebView mainFrame] frameView] documentView] enclosingScrollView];
    // get the current scroll position of the document view
    NSRect	rectScroll	= [[myScrollView contentView] bounds];
    NSPoint	pointScroll	= rectScroll.origin;
    [[myScrollView documentView] scrollPoint:NSMakePoint(pointScroll.x, pointScroll.y + iMoveTimes * fDistance)];
	NSLog(@"Move times %i",iMoveTimes);
}

-(void)SetMainWindow
{
	[_window	setLevel:kCGStatusWindowLevel];
	[NSApp		activateIgnoringOtherApps:YES];
	[self.window	center];
}

#pragma mark -some methods to load web

- (BOOL)ClickReloadWeb:(DOMElement *)domButton
{
    [domButton performSelector:@selector(click)];
    bLoadingFlag	= YES;
    iCount			= 0;
    while (bLoadingFlag && iCount < 40)
    {
        iCount++;
        [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode
								 beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    if (40 < iCount)
    {
        return NO;
    }
    return YES;
}

- (void)ReloadWebOnFrameWithURL:(NSString *)szURL
{
    bLoadingFlag	= YES;
    while (bLoadingFlag && iCount < 40)
    {
        iCount++;
        [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    if (40 == iCount)
    {
        NSLog(@"URL + 5 second.");
//        [self LoadWebURL:szURL];
    }
}

- (void)LoadWebURL:(NSString *)szURL
{
    iCount	= 0;
    [[mainWebView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:szURL]]];
    [self ReloadWebOnFrameWithURL:szURL];
}

#pragma mark  -Download delegate

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return YES;
}

// NSOpenSavePanelDelegate
-(BOOL)panel:(id)sender validateURL:(NSURL *)url error:(NSError **)outError
{
	NSString *strURL	= [NSString	stringWithFormat:@"%@",url];
	strURL				= [strURL	SubFrom:@"/localhost" include:NO];
	[txtSNFilePath setStringValue:strURL];
	NSFileManager	*fileManager = [NSFileManager	defaultManager];
	if ([fileManager	fileExistsAtPath:strURL])
	{
		if (![fileManager	fileExistsAtPath:szSNFileList])
		{
			[fileManager createDirectoryAtPath:szSNFileList withIntermediateDirectories:YES attributes:nil error:nil];
		}
		NSString    *szStringSNPath		= [NSString stringWithFormat:@"%@/Default.csv", szSNFileList];
		[fileManager copyItemAtPath:strURL toPath:szStringSNPath error:nil];
	}
	[btnRun setEnabled:YES];
	[nc postNotificationName:@"PressToRun" object:self];
	return YES;
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    bLoadingFlag    = NO;
}

- (WebView *)webView:(WebView *)sender createWebViewWithRequest:(NSURLRequest *)request
{
    m_hiddenWebView	=  [[WebView alloc] init];
    [m_hiddenWebView setPolicyDelegate:self];
    return m_hiddenWebView;
}

- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener
{
    if ([sender isEqualTo:m_hiddenWebView])
    {
        NSLog(@"%@",sender);
        NSLog(@"%@",[[actionInformation objectForKey:WebActionOriginalURLKey] absoluteString]);
        NSLog(@"%@",[actionInformation objectForKey:WebActionNavigationTypeKey]);
        //[[NSWorkspace sharedWorkspace] openURL:[actionInformation objectForKey:WebActionOriginalURLKey]];
        [listener use];
        
        [self LoadWebURL:[[actionInformation objectForKey:WebActionOriginalURLKey] absoluteString]];
        //[sender release];
    }
    else
    {
        [listener use];
    }
}

- (void)webView:(WebView *)webView decidePolicyForMIMEType:(NSString *)type request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id < WebPolicyDecisionListener >)listener
{
    if([type isEqualToString:@"application/zip"])
    {
        [listener download];
    }
    else
    {
        [listener use];
    }
    //just ignore all other types; the default behaviour will be used
}

//- (NSWindow *)downloadWindowForAuthenticationSheet:(WebDownload *)download
//{
//
//}

- (void)downloadDidBegin:(NSURLDownload *)download
{
    NSLog(@"downloadDidBegin");
}

- (void)download:(NSURLDownload *)download decideDestinationWithSuggestedFilename:(NSString *)filename
{	
	// Need to check the diectory is exist or not
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:DOWNLOAD_TO_FILEPATH])
    {
        [fileManager createDirectoryAtPath:DOWNLOAD_TO_FILEPATH withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *destinationFileName = [DOWNLOAD_TO_FILEPATH stringByAppendingPathComponent:filename];
    [download setDestination:destinationFileName allowOverwrite:YES];

}

- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error
{
	[self		whenDownloadFail:@"Download logs failed"];
	
    NSLog(@"Download failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)downloadDidFinish:(NSURLDownload *)download
{
	NSLog(@"downloadDidFinish");

	if ([aryLogsNeedDown count]< 1)
	{
		NSString *szInfo = [NSString stringWithFormat:@"%@,%@,%u,%@\n",szCurrentQuerySN,szCurrentQueryStation,downLogSetting,[self GetNowTimeStr]];
		[self		whenDownloadPass:szInfo];
	}else
	{
		[nc	postNotificationName:@"DownAllLogs" object:self];	
	}
}



@end
