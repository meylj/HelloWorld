#import "PATApp.h"



/*!
 *	Set up app configurations when app is launching. 
 *	@author	Izual Azurewrath
 *	@since	2011-12-07
 *			Creation. 
 */
@interface PATApp (PATApp_Configuration)



#pragma mark - First Use 
-(BOOL)checkConfigFilesAndReportIfError:(NSError**)error;



#pragma mark - Get Configurations 



#pragma mark - Set Up Kernel 
-(BOOL)setUpKernelAndReportIfError:(NSError**)error;



#pragma mark - Set Up UI 
-(BOOL)setUpUIAndReportIfError:(NSError**)error;
-(BOOL)setUpDiagramAndReportIfError:(NSError**)error;



@end


