#import "PATApp.h"



/*!
 *	User control. 
 *	@author	Izual Azurewrath
 *	@since	2011-12-07
 *			Creation. 
 */
@interface PATApp (PATApp_Progress)



-(IBAction)startTest:(NSButton*)sender;
-(IBAction)abortTest:(NSButton*)sender;
-(void)listenNoteKernelDone:(NSNotification*)note;



@end


