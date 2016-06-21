#import "PATApp_Configuration.h"



@implementation PATApp (PATApp_Configuration)



#pragma mark - First Use 
-(BOOL)checkConfigFilesAndReportIfError:(NSError**)error
{
	NSFileManager	*fm	= [NSFileManager defaultManager];
	// Create file path list. 
	NSArray	*aryFileList	= [NSArray arrayWithObjects:
							   [NSString stringWithFormat:
								@"/Users/%@/Library/Preferences/PAT.Wifi.plist", NSUserName()],
							   [NSString stringWithFormat:
								@"%@/CalProcess.plist", [fm currentDirectoryPath]],
							   [NSString stringWithFormat:
								@"%@/IOProcess.plist", [fm currentDirectoryPath]], nil];
	// Check files. 
	for(NSString *strFilePath in aryFileList)
		if(![fm fileExistsAtPath:strFilePath])
		{
			if(NULL != error)
				*error	= [NSError errorWithDomain:[NSString stringWithFormat:
													@"File [%@] not found. ", strFilePath] 
											 code:__LINE__ 
										 userInfo:nil];
			return NO;
		}
	return YES;
}



#pragma mark - Get Configurations 



#pragma mark - Set Up Kernel 
-(BOOL)setUpKernelAndReportIfError:(NSError**)error
{
	// Set up script. 
	[m_kernel setUpCalProcess:[NSDictionary dictionaryWithContentsOfFile:
							   @"/Users/izualazurewrath/Desktop/PAT/PAT/PAT/CalProcess.plist"]];
	[m_kernel setUpIOProcess:[NSDictionary dictionaryWithContentsOfFile:
							  @"/Users/izualazurewrath/Desktop/PAT/PAT/PAT/IOProcess.plist"]];
	[m_kernel setLogPath:@"/Users/izualazurewrath/Desktop/Izual_Test"];
	// Set up devices. 
	IADevice_GPIB	*gpib	= [[IADevice_GPIB alloc] init];
	[gpib setGPIBBoardIndex:0 
			 primaryAddress:20 
		   secondaryAddress:0 
					timeOut:3000000 
						EOI:YES 
						EOS:NO 
					  error:nil];
	[m_kernel setUpDevice:gpib targetName:@"ZVB8"];
	[gpib release];	gpib	= nil;
	[m_kernel clear];
	
	// Set up notification. 
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(listenNoteKernelDone:) 
												 name:noteKernelDone 
											   object:m_kernel];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(listenNoteDiagramShouldBegin:) 
												 name:noteDiagramShouldBegin 
											   object:m_kernel];
	return YES;
}



#pragma mark - Set Up UI 
-(void)refreshUI
{
	[m_progress setIntegerValue:[m_tableResults numberOfRows]];
	[m_progress display];
	[m_tableResults reloadData];
}
-(BOOL)setUpUIAndReportIfError:(NSError**)error
{
	[window setDelegate:self];
	[m_tableResults setDataSource:m_kernel];
	[m_progress setMinValue:0];
	[m_progress setMaxValue:m_kernel.Count];
	[NSTimer scheduledTimerWithTimeInterval:0.1 
									 target:self 
								   selector:@selector(refreshUI) 
								   userInfo:nil 
									repeats:YES];
	return YES;
}

-(BOOL)setUpDiagramAndReportIfError:(NSError**)error
{
	[m_viewMagnitud DrawTheCoordinate:450 
						XcoordniteEnd:3000 
				 YcoordnitestartValue:0 
				   YcoordniteEndValue:1 
						CommentNumber:10];
	m_viewMagnitud.m_strXCoordinateFormat	= @"Magnitude";
	m_viewMagnitud.m_strYCoordinateFormat	= @"f(MHz)";
	[m_viewPhase DrawTheCoordinate:450 
					 XcoordniteEnd:3000 
			  YcoordnitestartValue:0 
				YcoordniteEndValue:360 
					 CommentNumber:10];
	m_viewPhase.m_strXCoordinateFormat	= @"Phase(Degrees)";
	m_viewPhase.m_strYCoordinateFormat	= @"f(MHz)";
	[m_viewSmith DrawTheCoordinate:-1 
					 XcoordniteEnd:1 
			  YcoordnitestartValue:-1 
				YcoordniteEndValue:1 
					 CommentNumber:10];
	m_viewSmith.m_strXCoordinateFormat	= @"Smith Chart";
	m_viewSmith.m_strYCoordinateFormat	= @"";
	return YES;
}



@end


