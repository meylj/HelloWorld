#import <Foundation/Foundation.h>
#import "NSString_IA.h"



/*!	Buffer length. */
#define IADEVICE_BUFFER_LENGTH		20000
/*!	Standard responses. */
///	@{
#define IADEVICE_COMMAND_SUCCESS	@"Command has been sent successfully. "
#define IADEVICE_COMMAND_NOTFOUND	@"Command not found. "
#define IADEVICE_INTERFACE_FUNCTION	@"I'm an interface method, override me please. "
///	@}



/*!
 *	@brief		Abstract class for all devices. 
 *	@author		Izual Azurewrath
 *	@since		2011-11-29
 *				Creation. 
 *	@warning	Don't use me directly. 
 */
@interface IADevice : NSObject
{
	int		m_iDevice;							///<	Device file descriptor. 
	char	m_cBuffer[IADEVICE_BUFFER_LENGTH];	///<	Buffer for receive command. 
	/*!	Need auto flush before send command or after receive command. 
	 *	@see	AutoFlush */
	BOOL	m_bAutoFlush;
}



#pragma mark - Original Functions 
/*!
 *	Sub response by give properties. 
 *	@param		strResponse
 *				The source string. 
 *	@param		dictProperties
 *				Given properties. 
 *	@param[out]	idResult
 *				The intercepted string. 
 */
-(BOOL)subResponse:(NSString*)strResponse 
	withProperties:(NSDictionary*)dictProperties 
			result:(id*)idResult;



/*!	@defgroup	IADevice_Standard_Packaged_Functions IADevice_Standard_Packaged_Functions
 *				Standard packaged functions for script files. 
 *	@param[out]	idResult
 *				Action result, always be a string. 
 */
///	@{
#pragma mark - Standard Packaged Functions 
-(id)INIT_WITH_PROPERTIES:(NSDictionary*)dictProperties 
				   RESULT:(id*)idResult;

-(BOOL)SET_PROPERTIES:(NSDictionary*)dictProperties 
			   RESULT:(id*)idResult;

-(BOOL)CONNECT:(NSDictionary*)dictCommand 
		RESULT:(id *)idResult;

-(BOOL)SEND_COMMAND:(NSDictionary*)dictCommand 
			 RESULT:(id*)idResult;

-(BOOL)FLUSH_BUFFER:(NSDictionary*)dictCommand 
			 RESULT:(id*)idResult;

-(BOOL)RECEIVE_COMMAND:(NSDictionary*)dictCommand 
				RESULT:(id*)idResult;

-(BOOL)DISCONNECT:(NSDictionary*)dictCommand 
		   RESULT:(id*)idResult;
///	@}



#pragma mark - Basic Informations 
@property (assign, readonly)	NSString	*Name;
@property (assign, readwrite)	NSUInteger	Timeout;
/*!	Auto flush buffer after receive command or before send command. */
@property (assign, readwrite)	BOOL		AutoFlush;



@end



#import "IADeviceMonitor.h"
#import "IADevice_GPIB.h"


