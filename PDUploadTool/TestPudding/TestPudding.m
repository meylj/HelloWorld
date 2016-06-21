#import "TestPudding.h"

@implementation TestPudding

- (void)awakeFromNib {
	
}

- (void)dealloc {
	[m_InstantPudding release];
	[super dealloc];
}

- (IBAction)TestAct1:(id)sender {
    [m_DisplayVer setStringValue:[m_InstantPudding getInterfaceVersion]];
}

- (IBAction)SetISN_Number:(id)sender {
	NSLog(@"SetPDCA_ISN = %d",[m_InstantPudding SetPDCA_ISN:[m_ISNumber stringValue]]);
}

- (IBAction)StartPuddingAct:(id)sender {
	[m_InstantPudding StartPDCA_Flow];
}

- (IBAction)InitPuddingAct:(id)sender {
	m_InstantPudding = [[TPuddingPDCA alloc] init];
	[m_InstantPudding SetInitParamter:[m_StationVer stringValue] 
						 STATOIN_NAME:[m_StationName stringValue] 
					  SOFTWARE_LIMITS: [m_Limits stringValue] 
					SOFTWARE_IDENTIF : [m_Identifier stringValue]];
	NSLog(@"getPuddingVersion = %@", [m_InstantPudding getPuddingVersion]);
}

- (IBAction)AddTestItemAct:(id)sender {
	[m_InstantPudding SetTestItemStatus:[m_MainItem stringValue] SubItem:[m_SubItem stringValue] 
							  TestValue:[m_TestValue stringValue] LowLimit:[m_LowLimit stringValue] 
							  HighLimit:[m_HighLimit stringValue] TestUnits:[m_Units stringValue]
								ErrDesc:[m_edtErrCode stringValue]
							   Priority:0
							 TestResult:[[m_edtErrCode stringValue] length] == 0 ? YES : NO];
}

- (IBAction)SubmmitReslutAct:(id)sender {
	int nRetCode = 0;
	NSOpenPanel		*openFolder = [NSOpenPanel openPanel];
	NSString		*ErrMsg;
	NSString		*FileName;
	if ([openFolder runModalForTypes:nil] == NSOKButton)
		FileName = [[openFolder filenames] objectAtIndex:0];
	else 
		FileName = @"";

	nRetCode = [m_InstantPudding CompleteTestProcess:FileName ErrorMsg:&ErrMsg];
	[m_ErrCode setStringValue:[NSString stringWithFormat:@"%d and ErrorMsg = %@", nRetCode,ErrMsg]];
}

- (IBAction)PackageZipAct:(id)sender {
	NSOpenPanel		*openFolder = [NSOpenPanel openPanel];
	NSSavePanel		*saveFile = [NSSavePanel savePanel];
	
	[openFolder setCanChooseFiles:NO];
	[openFolder setCanChooseDirectories:YES];
	if ([openFolder runModalForTypes:nil] == NSOKButton)
		if ([saveFile runModal] == NSOKButton) {
			NSString *aFileName = [[openFolder filenames] objectAtIndex:0];
			NSString *aFolderPath = [saveFile filename];
			
			[m_InstantPudding MakeBlobZIP_File:aFileName FolderPath:aFolderPath];
		}
}

- (IBAction)GetPuddingVerAct:(id)sender {
	[m_edtPuddingVer setStringValue:[m_InstantPudding getPuddingVersion]];
}
@end
