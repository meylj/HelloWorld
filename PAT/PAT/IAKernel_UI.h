#import "IAKernel.h"



/*!
 *	@Author	Izual Azurewrath
 *	@Since	2011-12-06
 *			Creation. 
 */
@interface IAKernel (IAKernel_UI)
<NSTableViewDataSource>



/*!	
 *	Show result on UI. We just add it into tableview datasource. 
 *	@param	result
 *			A result. 
 */
-(void)showResultOnUI:(Bean_Result*)result;



@end


