#import "PATApp.h"



@implementation PATApp



@synthesize window;



#pragma mark - Life and Death 
-(id)init
{
	self	= [super init];
	if(self)
	{
		m_kernel	= [[IAKernel alloc] init];
	}
	return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	NSError	*error	= nil;
	if(![self checkConfigFilesAndReportIfError:&error]
	   || ![self setUpKernelAndReportIfError:&error]
	   || ![self setUpUIAndReportIfError:&error]
	   || ![self setUpDiagramAndReportIfError:&error])
	{
		NSAlert	*alert	= [NSAlert alertWithError:error];
		[alert runModal];
		exit(1);
	}
}

-(void)windowWillClose:(NSNotification *)notification
{
	exit(0);
}

-(void)dealloc
{
	[m_kernel release];		m_kernel	= nil;
	[super dealloc];
}



#pragma mark - Control UI 
-(void)setUIState:(BOOL)bState
{
	[m_txtSN setEnabled:bState];
	[m_btnStart setEnabled:bState];
}



#pragma mark - Basic Informations 
-(NSString *)SN
{
	return [m_txtSN stringValue];
}
-(NSColor *)Color
{
	return [window backgroundColor];
}
-(void)setColor:(NSColor *)Color
{
	[window performSelectorOnMainThread:@selector(setBackgroundColor:) 
							 withObject:Color 
						  waitUntilDone:NO];
}



@end


