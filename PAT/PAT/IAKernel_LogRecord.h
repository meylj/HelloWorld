#import "IAKernel.h"



/// Log types. 
typedef enum
{
	IAKERNEL_DEVICE	= 0,
	IAKERNEL_PROGRESS,
	IAKERNEL_RESULT
} IAKERNEL_LOGTYPE;



/*!
 *	@author	Izual Azurewrath
 *	@since	2011-12-12
 *			Creation. 
 */
@interface IAKernel (IAKernel_LogRecord)



#pragma mark - Create 
-(BOOL)createLogFilesAndReportIfError:(NSError**)error;
-(NSString*)createLogPath:(IAKERNEL_LOGTYPE)iType;



#pragma mark - Create and Save Log 
/*!
 *	Create log contents from a Bean_Result. 
 *	@param	result
 *			A test result. 
 *	@return	An string with CSV content format. 
 *			All dot and new line symbol will be surrounded by pair of quotation marks. 
 */
-(NSString*)makeLogFromResult:(Bean_Result*)result;

/*!
 *	Save log contents. 
 *	@param		strLog
 *				A log string. We just append it to end of file without any modification. 
 *	@param		iType
 *				Log types, it determines which log file to write. 
 *	@param[out]	error
 *				Error descriptioin if action failed. 
 *	@see		IAKERNEL_LOGTYPE. 
 */
-(BOOL)saveLog:(NSString*)strLog 
		  type:(IAKERNEL_LOGTYPE)iType 
		 error:(NSError**)error;



@end


