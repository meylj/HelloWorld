#import "IADevice.h"
#import <NI4882/NI4882.h>



/*!	
 *	@brief	GPIB properties. 
 *	@author	Izual Azurewrath
 *	@since	2011-11-29
 *			Creation. 
 */
struct IADevice_GPIB_Structure
{
	NSUInteger	BoardIndex;
	NSUInteger	PrimaryAddress;
	NSUInteger	SecondaryAddress;
	NSUInteger	TimeOut;
	BOOL		EOI;
	BOOL		EOS;
};



/*!
 *	@brief	GPIB Instruments. 
 *	@author	Izual Azurewrath
 *	@since	2011-11-29
 *			Creation. 
 */
@interface IADevice_GPIB : IADevice 
{
	int		m_iBoardIndex;
	struct IADevice_GPIB_Structure	m_original;
}



#pragma mark - Original Functions 
/*!	
 *	Set up a GPIB instrument. 
 *	@param		iBoardIndex
 *				Index number of your GPIB card. 
 *	@param		iPrimaryAddress
 *				Primary address of your instrument. 
 *	@param		iSecondaryAddress
 *				Secondary address of your instrument, generally 0. 
 *	@param		iTimeOut
 *				Time out, unit is 10^-6s, microseconds. 
 *	@param		bEOI
 *				Generally 1. 
 *	@param		bEOS
 *				Generally 0. 
 *	@param[out]	error
 *				Error messages if result is NO. 
 */
-(BOOL)setGPIBBoardIndex:(NSUInteger)iBoardIndex 
		  primaryAddress:(NSUInteger)iPrimaryAddress 
		secondaryAddress:(NSUInteger)iSecondaryAddress 
				 timeOut:(NSUInteger)iTimeOut 
					 EOI:(BOOL)bEOI 
					 EOS:(BOOL)bEOS 
				   error:(NSError**)error;

-(BOOL)sendCommand:(NSString*)strCommand 
			 error:(NSError**)error;

-(BOOL)flushBufferAndReportIfError:(NSError**)error;

-(NSString*)receiveCommandAndReportIfError:(NSError**)error;

-(BOOL)disconnectAndReportIfError:(NSError**)error;



#pragma mark - Tools 
-(NSString*)errorGPIB;
/*!
 *	Convert user time out to GPIB standard time out. 
 *	@param	iTimeout
 *			The user time out.
 *	@return	The GPIB standard time out.
 *			The nearest greater int value of user time out. 
 */
-(int)convertTimeout:(NSUInteger)iTimeout;



@end


