//
//  LFAppDelegate.m
//  OverlayHelper
//
//  Created by Lorky on 9/19/14.
//  Copyright (c) 2014 Lorky. All rights reserved.
//

#import "LFAppDelegate.h"
#import "NSStringCategory.h"

@implementation LFAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
	[progress setHidden:YES];
	
	// Initilse UI
	NSDictionary * dicSettings	= [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SettingFile" ofType:@"plist"]];
	NSDictionary * dicProjects	= dicSettings[@"ProjectMapping"];
	[popProjects removeAllItems];
	[popStations removeAllItems];
	[popProjects addItemsWithTitles:[dicProjects allKeys]];
	[popProjects selectItemAtIndex:0];
	[changeList setString:@"BaseOn:\nChangeNotes:\n - "];
	[self ProjectDidChange:nil];
	
	NSDictionary * dictBundleInfo = [[NSBundle mainBundle] infoDictionary];
	[self.window setTitle:[NSString stringWithFormat:@"%@ v %@", dictBundleInfo[@"CFBundleName"],dictBundleInfo[@"CFBundleShortVersionString"]]];
}

- (IBAction)ProjectDidChange:(id)sender {
	[popStations	removeAllItems];
	[popStations	setStringValue:@""];
	[txtCheckSum	setStringValue:@""];
	[changeList setString:@"BaseOn:\nChangeNotes:\n - "];
	
	NSDictionary * dicSettings	= [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]
																			  pathForResource:@"SettingFile"
																			  ofType:@"plist"]];
	NSString * strGitPath		= dicSettings[@"UserConfiguration"][NSUserName()];
//	NSString * strProjectSelect = [[popProjects selectedItem] title];
	NSFileManager *fileManager	= [NSFileManager defaultManager];
	NSString * strOverlayPath	= @"";
//	if ([strProjectSelect contains:@"_AE"])
//		strOverlayPath = [NSString stringWithFormat:@"%@/%@/Station/AE Stations/",strGitPath,[strProjectSelect subByRegex:@"^(.*)-AE" name:nil error:nil]];
//    else if ([strProjectSelect contains:@"-CSD"])
//        strOverlayPath = [NSString stringWithFormat:@"%@/%@/Station/CSD Stations/",strGitPath,[strProjectSelect subByRegex:@"^(.*)-CSD" name:nil error:nil]];
//	else
    
    strOverlayPath = [NSString stringWithFormat:@"%@/%@/Station/ATS Stations/",strGitPath,[[popProjects selectedItem] title]];
	if ([fileManager fileExistsAtPath:strOverlayPath])
	{
		NSArray * arrayStations = [fileManager contentsOfDirectoryAtPath:strOverlayPath error:nil];
		for (NSString * station in arrayStations)
		{
			if ([station isNotEqualTo:@".DS_Store"])
				[popStations addItemWithTitle:station];
		}
		[popStations selectItemAtIndex:0];
	}
	else
	{
		[txtCheckSum setStringValue:@"P4 workspace格式不对，请检查下"];
	}
}

- (IBAction)GoWork:(id)sender
{
	if ([txtVersion stringValue].length<=0 || [popStations title].length <= 0)
	{
		[txtCheckSum setStringValue:@"还有比你更懒的人么？版本号都不想写？？"];
		return;
	}
	
	NSString * baseVersion = [changeList.string SubFrom:@"BaseOn:" include:NO];
	baseVersion = [baseVersion SubTo:@"ChangeNotes" include:NO];
	if (baseVersion.length <= 0 || [baseVersion isEqualToString:@"\n"])
	{
		[txtCheckSum setStringValue:@"讲过多少遍了，写清楚基于哪个版本修改的，要不用大鞋拔子抽你丫的！"];
		return;
	}
	if ([changeList.string SubFrom:@"ChangeNotes:\n - " include:NO].length <=0)
	{
		[txtCheckSum setStringValue:@"讲过多少遍了，写清楚改了些神马东西，要不用大鞋拔子抽你丫的！"];
		return;
	}
	
	[NSThread detachNewThreadSelector:@selector(workingFlow)
							 toTarget:self
						   withObject:nil];
}

- (void)workingFlow
{
	[progress startAnimation:nil];
	[progress setHidden:NO];
	[popProjects setEnabled:NO];
	[popStations setEnabled:NO];
	[txtVersion setEditable:NO];
	[isRebuild setEnabled:NO];
	
	// 1. Rename the folder name and overlay version.
	NSString * strFinalFolder = [self CreateOverlayStructor];
	if ([strFinalFolder length] > 0) {
		// 2. zip the file
		[txtCheckSum setStringValue:@"大爷，overlay正在压缩捏～～"];
		[self ZipFolder:strFinalFolder];
		// 3. show the check sum.
		[txtCheckSum setStringValue:@"大爷，开始计算checksum，耐心等待哟"];
		[txtCheckSum setStringValue:[self CalculateCheckSum:[NSString stringWithFormat:@"%@.zip",strFinalFolder]]];
		[[NSFileManager defaultManager] removeItemAtPath:strFinalFolder error:nil];
	}
	else
	{
		//[txtCheckSum setStringValue:@"Overlay木有创建成功吖～～"];
	}
	
	[progress stopAnimation:nil];
	[progress setHidden:YES];
	[popProjects setEnabled:YES];
	[popStations setEnabled:YES];
	[txtVersion setEditable:YES];
	[isRebuild setEnabled:YES];
}

- (NSString *)CreateOverlayStructor
{
	NSDictionary * dicSettings	= [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SettingFile" ofType:@"plist"]];
	NSDictionary * dicProjects	= dicSettings[@"ProjectMapping"];
	NSString * strP4Path		= dicSettings[@"UserConfiguration"][NSUserName()];
	NSString * strProject		= [[popProjects selectedItem] title];
	NSString * strStation		= [[popStations selectedCell] title];
	NSString * strVersion		= [NSString stringWithFormat:@"1.0d%@",[txtVersion stringValue]];
	
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= __MAC_10_10
	NSString * format = @"YYYYMMdd_HHmmss";
	
	NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
	[outputFormatter setDateFormat:format];
	NSString *newDateString = [outputFormatter stringFromDate:[NSDate date]];
	[outputFormatter release];
	NSString * strFolder = [NSString stringWithFormat:@"%@_%@ %@_%@",newDateString,
							dicProjects[strProject],strStation,strVersion];
#else
	NSString * strFolder = [NSString stringWithFormat:@"%@_%@ %@_%@",[[NSDate date] descriptionWithCalendarFormat:@"%Y%m%d_%H%M%S"
																										  timeZone:nil
																											locale:nil],
							dicProjects[strProject],strStation,strVersion];
#endif
	NSString * strDistantFolder = [NSString stringWithFormat:@"%@/Downloads/%@",NSHomeDirectory(),strFolder];

	NSFileManager * fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:strDistantFolder])
	{
		[fileManager createDirectoryAtPath:strDistantFolder withIntermediateDirectories:YES attributes:nil error:nil];
        NSString    *stTempProject  = strProject;
        if ([strProject contains:@"-AE"])
        {
            stTempProject   = [strProject subByRegex:@"^(.*)-AE" name:nil error:nil];
        }
        else if ([strProject contains:@"-CSD"])
        {
            stTempProject   = [strProject subByRegex:@"^(.*)-CSD" name:nil error:nil];
        }
		// Copy overlay structor into distant folder
		// Special Copy
		[txtCheckSum setStringValue:@"拷贝每个站特定的文件，耐心等待哟"];
		
        NSString    *strOrginalPath =   [NSString stringWithFormat:@"%@/%@/Station/ATS Stations/%@/OverlayDir/*",strP4Path,stTempProject,strStation];
        if ([[[popProjects selectedItem] title] contains:@"-AE"])
        {
            strOrginalPath  = [NSString stringWithFormat:@"%@/%@/Station/AE Stations/%@/OverlayDir/*",strP4Path,stTempProject,strStation];
        }
        else if ([[[popProjects selectedItem] title] contains:@"-CSD"])
        {
            strOrginalPath  = [NSString stringWithFormat:@"%@/%@/Station/CSD Stations/%@/OverlayDir/*",strP4Path,stTempProject,strStation];
        }
		
		NSMutableString * strOrginal1 = [NSMutableString stringWithString:strOrginalPath];
		NSMutableString * strDistant1 = [NSMutableString stringWithString:strDistantFolder];
		[strOrginal1 replaceOccurrencesOfString:@" " withString:@"\\ " options:NSCaseInsensitiveSearch range:NSMakeRange(0, strOrginal1.length)];
		[strDistant1 replaceOccurrencesOfString:@" " withString:@"\\ " options:NSCaseInsensitiveSearch range:NSMakeRange(0, strDistant1.length)];
		NSString * strSpecialCopy = [NSString stringWithFormat:@"cp -r %@ %@",strOrginal1,strDistant1];
		system([strSpecialCopy UTF8String]);
		
        //Mofify ATS_Mufia.plist
        NSString *strMufiaSettingPath = [NSString stringWithFormat:@"%@/Users/gdlocal/Library/Preferences/ATS_Muifa.plist",strDistantFolder];
        NSString *strLocalJson = [NSString stringWithFormat:@"%@/%@/Code/FunnyZone/FunnyZone/StationJSON_Files/%@_LIVE.json",strP4Path,stTempProject,strStation];
        if(![self Modify_ATS_Muifa:strMufiaSettingPath LiveJson:strLocalJson])
        {
            [txtCheckSum setStringValue:@"修改ATS_Mufia.plist没有成功。"];
            return @"";
        }
        
		// Base applications Copy
		[txtCheckSum setStringValue:@"拷贝基本应用程序，耐心等待哟"];
		NSString * strBasePath	= [NSString stringWithFormat:@"%@/%@/Station/Overlay/*",strP4Path,stTempProject];
        if ([[[popProjects selectedItem] title] contains:@"-AE"])
        {
           strBasePath	= [NSString stringWithFormat:@"%@/%@/Station/AE_Overlay/*",strP4Path,stTempProject];
        }
        
		NSString * strBase1		= [NSMutableString stringWithString:strBasePath];
		NSString * strBaseCopy	= [NSString stringWithFormat:@"cp -r %@ %@",strBase1,strDistant1];
		system([strBaseCopy UTF8String]);
		
		if ([isRebuild state] == NSOnState)
		{
		
			// Build the application
			[txtCheckSum setStringValue:@"开始build代码了，耐心等待哟"];
			NSMutableString * strError = [NSMutableString new];
			NSString * strWorkspaceFolder = [NSString stringWithFormat:@"%@/Other_Code/ProjectsWorkspace",strP4Path];
			if (![self BuildApplicaiton:strWorkspaceFolder	ErrorDescription:strError])
			{
				[txtCheckSum setStringValue:@"他妈的,workspace没有build成功，快去检查下！"];
				[strError release]; strError = nil;
				return @"";
			}
			[strError release]; strError = nil;
		}
		
		// Muifa Copy
		// Replace the latest Muifa.app here, it should be built at ~/Public/
		NSString * strMuifaPath = [NSString stringWithFormat:@"%@/Public/Muifa.app",NSHomeDirectory()];
		if ([fileManager fileExistsAtPath:strMuifaPath isDirectory:NO])
		{
			NSDate * dateModificaiton = [fileManager attributesOfItemAtPath:strMuifaPath error:nil][NSFileModificationDate];
			NSTimeInterval timeInterval = [dateModificaiton timeIntervalSinceNow];
			
			// If the Muifa.app is older than 5 minitues, will reminder user to double check.
			if (abs(timeInterval) >= 5 * 60)
			{
				if (NSRunAlertPanel(@"提示", @"这个Muifa不是最近5分钟之内创建出来的，大爷确定要包到新overlay里面么？？", @"包呗", @"还是算了吧，我再多考虑一下", nil)==NSOKButton)
				{
					NSString * strMuifa = [NSString stringWithFormat:@"%@/Users/gdlocal/Desktop/%@-%@/",strDistantFolder,strStation,strVersion];
					if (![fileManager fileExistsAtPath:strMuifa isDirectory:NO])
						[fileManager createDirectoryAtPath:strMuifa withIntermediateDirectories:YES attributes:nil error:nil];

					[fileManager copyItemAtPath:strMuifaPath
										 toPath:[NSString stringWithFormat:@"%@Muifa.app",strMuifa]
										  error:nil];
					
					// Change the Info.plist version
					NSString * strInfoPath = [NSString stringWithFormat:@"%@/Muifa.app/Contents/Info.plist",strMuifa];
					NSMutableDictionary * dictContent = [NSMutableDictionary dictionaryWithContentsOfFile:strInfoPath];
					[fileManager removeItemAtPath:strInfoPath error:nil];
					dictContent[@"CFBundleShortVersionString"] = strVersion;
					[dictContent writeToFile:strInfoPath atomically:YES];
				}
				else
				{
					[txtCheckSum setStringValue:@"大爷，这不是最新的Muifa，您不想创建Overlay"];
					return @"";
				}
			}
			else // Copy Muifa.app into overlay structor directory.
			{
				NSString * strMuifa = [NSString stringWithFormat:@"%@/Users/gdlocal/Desktop/%@-%@/",strDistantFolder,strStation,strVersion];
				if (![fileManager fileExistsAtPath:strMuifa isDirectory:NO])
					[fileManager createDirectoryAtPath:strMuifa withIntermediateDirectories:YES attributes:nil error:nil];
				
				[fileManager copyItemAtPath:strMuifaPath
									 toPath:[NSString stringWithFormat:@"%@Muifa.app",strMuifa]
									  error:nil];
				
				// Change the Info.plist version
				NSString * strInfoPath = [NSString stringWithFormat:@"%@/Muifa.app/Contents/Info.plist",strMuifa];
				NSMutableDictionary * dictContent = [NSMutableDictionary dictionaryWithContentsOfFile:strInfoPath];
				[fileManager removeItemAtPath:strInfoPath error:nil];
				dictContent[@"CFBundleShortVersionString"] = strVersion;
				[dictContent writeToFile:strInfoPath atomically:YES];
			}
		}
		else
		{
			[txtCheckSum setStringValue:@"大爷，在~/Public/下面找不到Muifa，求大爷先build下Muifa的代码吧！"];
			return @"";
		}
		
		// Write Change list
		NSError * error = nil;
		NSString * strChangelistPath = [NSString stringWithFormat:@"%@/Users/gdlocal/Desktop/%@-%@/ChangeList.txt",strDistantFolder,strStation,strVersion];
		NSString * strChangelist = [NSString stringWithFormat:@"New Version:%@\nDate:%@\n%@",strVersion,[[NSDate date] description],changeList.string];
		
		[strChangelist writeToFile:strChangelistPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
		if (error)
		{
			[txtCheckSum setStringValue:error.description];
			return @"";
		}
	}
	else
	{
		[txtCheckSum setStringValue:@"怎么可能，时间至少不应该一样啊～～"];
		return @"";
	}
	return strDistantFolder;
}

-(UInt8)ZipFolder:(NSString *)folderPath
{
	UInt8 iReturn = 0;
	NSTask	*zipTask	= [[NSTask alloc] init];
	NSArray	*aryArgument	= @[@"-ck",folderPath,[NSString stringWithFormat:@"%@.zip",folderPath]];
	[zipTask setArguments:aryArgument];
	[zipTask setLaunchPath:@"/usr/bin/ditto"];
	[zipTask launch];
	[zipTask waitUntilExit];
	iReturn = [zipTask terminationStatus];
	[zipTask release];
	return iReturn;
}

- (BOOL)BuildApplicaiton:(NSString *)applicaitonPath ErrorDescription:(NSMutableString *)errorDes
{
	// Find the applciaiton path.
	NSFileManager * fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:applicaitonPath])
	{
		[errorDes setString:[NSString stringWithFormat:@"大爷，找不到%@这个文件夹",applicaitonPath]];
		return NO;
	}
	
	NSString * strWorkSpace = [NSString stringWithFormat:@"%@/%@.xcworkspace",applicaitonPath,[[popProjects selectedItem] title]];
	NSString * string = [NSString stringWithFormat:@"cd %@",applicaitonPath];
	system([string UTF8String]);
	// Clear the workspace
	NSDictionary * dictCleanParam = @{@"PATH" : @"/usr/bin/xcodebuild",
									  @"ARGS" : @[@"clean",@"-workspace",strWorkSpace,@"-scheme",@"Muifa"]};
	[self CommunicateWithTask:dictCleanParam ReturnValue:errorDes];
	if ([errorDes contains:@"** CLEAN SUCCEEDED **"])
	{
		// Build the project
		NSDictionary * dictBuildParam = @{@"PATH" : @"/usr/bin/xcodebuild",
										  @"ARGS" : @[@"-workspace",strWorkSpace,@"-scheme",@"Muifa"]};
		[self CommunicateWithTask:dictBuildParam ReturnValue:errorDes];
		return [errorDes contains:@"** BUILD SUCCEEDED **"];
	}
	else
	{
		return NO;
	}
}

- (BOOL)CommunicateWithTask:(NSDictionary *)dictParam
				ReturnValue:(NSMutableString *)strReturnValue
{
	// Get parameters.
	NSString	*strPath		= dictParam[@"PATH"];
	NSString	*strDirectory	= dictParam[@"DIRECTORY"];
	NSArray		*aryArgs		= dictParam[@"ARGS"];
	NSArray		*aryCommands	= dictParam[@"COMMANDS"];
	
	// Check task file exist.
	NSFileManager	*fm			= [NSFileManager defaultManager];
	BOOL			bDirectory	= YES;
	if(!strPath
	   || ![fm fileExistsAtPath:strPath isDirectory:&bDirectory]
	   || bDirectory
	   || (strDirectory
		   && (![fm fileExistsAtPath:strDirectory isDirectory:&bDirectory]
			   || !bDirectory)))
	{
		[strReturnValue setString:@"Task file not found. "];
		return NO;
	}
	
	// Launch task.
	NSTask	*task	= [[NSTask alloc] init];
	[task setLaunchPath:strPath];
	if(aryArgs && [aryArgs count])
		[task setArguments:aryArgs];
	[task setStandardInput:[NSPipe pipe]];
	[task setStandardOutput:[NSPipe pipe]];
	[task setStandardError:[task standardOutput]];
	[task setStandardInput:[NSPipe pipe]];
	if (strDirectory)
		[task setCurrentDirectoryPath:strDirectory];
	@try
	{
		[task launch];
	}
	@catch (NSException *exception)
	{
		[task release];	task	= nil;
		[strReturnValue setString:[exception reason]];
		return NO;
	}
	
	// Commands.
	for(NSDictionary *dictCommand in aryCommands)
	{
		// Get command.
		NSString	*strCommand	= dictCommand[@"COMMAND"];
		strCommand	= (strCommand ? [strCommand stringByAppendingString:@"\n"] : nil);
		NSString	*strSleep	= dictCommand[@"USLEEP"];
		unsigned int	iSleep	= (strSleep ? [strSleep intValue] : 0);
		NSString	*strRegex	= dictCommand[@"REGEX"];
		strRegex	= (strRegex ? strRegex : nil);
		NSString	*strError	= dictCommand[@"ERROR"];
		
		// Send.
		if(strCommand)
			[[[task standardInput] fileHandleForWriting]
			 writeData:[strCommand dataUsingEncoding:NSUTF8StringEncoding]];
		if(iSleep)
			usleep(iSleep);
		
		// Receive.
		NSData	*dataResponse	= [[[task standardOutput] fileHandleForReading] availableData];
		
		// Check.
		if(strRegex)
		{
			if(!dataResponse)
			{
				[task terminate];	[task release];	task	= nil;
				[strReturnValue setString:@"DUT no response. "];
				return NO;
			}
			NSString	*strResponse	= [[NSString alloc] initWithData:dataResponse
														  encoding:NSUTF8StringEncoding];
			if(!strResponse)
			{
				[task terminate];	[task release];	task	= nil;
				[strReturnValue setString:@"DUT response invalid. "];
				return NO;
			}
			if(![strResponse matches:strRegex])
			{
				[strResponse release];	strResponse	= nil;
				[task terminate];	[task release];	task	= nil;
				[strReturnValue setString:(strError ? strError : @"DUT response incorrect. ")];
				return NO;
			}
			[strResponse release];	strResponse	= nil;
		}
	}
	// If no commands, waiting until exit.
	if(!aryCommands)
	{
		NSData	*dataResponse	= [[[task standardOutput] fileHandleForReading]
								   readDataToEndOfFile];
		[task waitUntilExit];
		[task release];	task	= nil;
		if(dataResponse)
		{
			NSString	*strResponse	= [[NSString alloc] initWithData:dataResponse
														  encoding:NSUTF8StringEncoding];
			[strReturnValue setString:strResponse];
			[strResponse release];	strResponse	= nil;
			return YES;
		}
	}
    [task terminate];
	[task release];	task	= nil;
	[strReturnValue setString:@"PASS"];
	return YES;
}

- (NSString *)CalculateCheckSum:(NSString *)szFilePath
{
    NSString	*szCalSum	= @"";
    NSTask		*task		=[[NSTask alloc] init];
    NSPipe		*Pipe		=[NSPipe pipe];
    NSArray		*args		= @[@"sha1",szFilePath];
    [task setLaunchPath:@"/usr/bin/openssl"];
    [task setArguments:args];
    [task setStandardOutput:Pipe];
    [task launch];
    NSData		*outData	= [[Pipe fileHandleForReading] readDataToEndOfFile];
    [task waitUntilExit];
    int			iRetCode	= [task terminationStatus];
    [task release];
    if(iRetCode == 0)
    {
        NSString	*strCheckSumValue	= [[NSString alloc] initWithData:outData
														   encoding:NSUTF8StringEncoding];
		szCalSum = [strCheckSumValue subByRegex:@".*= (.{40})$" name:nil error:nil];
		[strCheckSumValue release];
    }
    else
        NSLog(@"Calculate plist file:[%@] failCheckSum iRetCode vaule:[%d]",szFilePath,iRetCode);
    return szCalSum;
}

- (BOOL)Modify_ATS_Muifa:(NSString *)strFilePath
                LiveJson:(NSString *)strJsonPath
{
    NSMutableDictionary *dicMufiaSetting = [NSMutableDictionary dictionaryWithContentsOfFile:strFilePath];
    if ([isOffline state]==1) {
        [dicMufiaSetting setObject:[NSNumber numberWithBool:YES] forKey:@"ValidationDisablePudding"];
        
    }
    if ([isDisablePudding state]==1) {
        [dicMufiaSetting setObject:[NSNumber numberWithBool:YES] forKey:@"DisablePudding"];
        
    }
    if ([isDisableLiveFunction state]==1) {
        [dicMufiaSetting setObject:[NSNumber numberWithBool:YES] forKey:@"DisableLiveFunction"];
    }
    if ([isNoLiveControl state]==1) {
        [dicMufiaSetting setObject:[NSNumber numberWithBool:YES] forKey:@"NoLiveControl"];
    }
    if ([isDisableSignature state]==1) {
        [dicMufiaSetting setObject:[NSNumber numberWithBool:YES] forKey:@"DisableSignature"];
    }
    BOOL bRet = [dicMufiaSetting writeToFile:strFilePath atomically:YES];
    return bRet;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return YES;
}
@end
