#import "PATApp_Progress.h"



@implementation PATApp (PATApp_Progress)



-(IBAction)startTest:(NSButton*)sender
{
	[self setUIState:NO];
	[m_kernel clear];
	[m_kernel startTest];
}

-(IBAction)abortTest:(NSButton*)sender
{
	[m_kernel abortTest];
}

-(void)listenNoteKernelDone:(NSNotification*)note
{
	self.Color	= [[note userInfo] objectForKey:@"RESULT"];
	[self setUIState:YES];
}



@end


