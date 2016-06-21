#import <Cocoa/Cocoa.h>
#import "IAKernel.h"
#import "SingleView_Wifi.h"



/*!
 *	@brief	Main UI process. 
 *	@author	Izual Azurewrath
 *	@since	2011-11-29
 *			Creation. 
 */
@interface PATApp : NSObject 
<NSApplicationDelegate, NSWindowDelegate> 
{
	NSWindow *window;
	
	// Common interface. 
	IBOutlet NSTextField		*m_txtSN;
	IBOutlet NSButton			*m_btnStart;
	IBOutlet NSTableView		*m_tableResults;
	IBOutlet NSLevelIndicator	*m_progress;
	
	// Kernel for single test. 
	IAKernel					*m_kernel;
	
	// Diagram for PAT_Wifi station. Magnitude, Phase and Smith chart. 
	IBOutlet SingleView_Wifi	*m_viewSmith;
	IBOutlet SingleView_Wifi	*m_viewMagnitud;
	IBOutlet SingleView_Wifi	*m_viewPhase;
}



@property (assign) IBOutlet		NSWindow	*window;



#pragma mark - Control UI 
-(void)setUIState:(BOOL)bState;



#pragma mark - Basic Informations 
/*!	SN in the text field on UI. */
@property (assign, readonly)	NSString	*SN;
/*!	Backgroud color of UI. */
@property (assign, readwrite)	NSColor		*Color;



@end



#import "PATApp_Configuration.h"
#import "PATApp_Progress.h"
#import "PATApp_Station_PATWifi.h"


