#import "IADevice_GPIB.h"



@implementation IADevice_GPIB



#pragma mark - NSObject Override 
- (id)init
{
    self	= [super init];
    if(self) 
	{
		m_iBoardIndex	= 0;
    }
    return self;
}



#pragma mark - Original Functions
-(BOOL)setGPIBBoardIndex:(NSUInteger)iBoardIndex 
		  primaryAddress:(NSUInteger)iPrimaryAddress 
		secondaryAddress:(NSUInteger)iSecondaryAddress 
				 timeOut:(NSUInteger)iTimeOut 
					 EOI:(BOOL)bEOI 
					 EOS:(BOOL)bEOS 
				   error:(NSError**)error
{
	ibonl(m_iDevice, 0);
	m_iDevice	= ibdev(iBoardIndex, iPrimaryAddress, iSecondaryAddress, 
						[self convertTimeout:iTimeOut], bEOI, bEOS);
	if(Ibsta() & ERR)
	{
		if(NULL != error)
			*error	= [NSError errorWithDomain:[self errorGPIB] 
										 code:__LINE__ 
									 userInfo:nil];
		return NO;
	}
	// Memory original data. 
	m_original.BoardIndex		= iBoardIndex;
	m_original.PrimaryAddress	= iPrimaryAddress;
	m_original.SecondaryAddress	= iSecondaryAddress;
	m_original.TimeOut			= iTimeOut;
	m_original.EOI				= bEOI;
	m_original.EOS				= bEOS;
	return YES;
}

-(BOOL)sendCommand:(NSString*)strCommand 
			 error:(NSError**)error
{
	if(self.AutoFlush)
		[self flushBufferAndReportIfError:nil];
	ibwrt(m_iDevice, (void*)[strCommand UTF8String], [strCommand length]);
	if(Ibsta() & ERR)
	{
		if(NULL != error)
			*error	= [NSError errorWithDomain:[self errorGPIB] 
										 code:__LINE__ 
									 userInfo:nil];
		return NO;
	}
	return YES;
}

-(BOOL)flushBufferAndReportIfError:(NSError **)error
{
	ibclr(m_iDevice);
	memset(m_cBuffer, 0, IADEVICE_BUFFER_LENGTH);
	if(Ibsta() & ERR)
	{
		if(NULL != error)
			*error	= [NSError errorWithDomain:[self errorGPIB] 
										 code:__LINE__ 
									 userInfo:nil];
		return NO;
	}
	return YES;
}

-(NSString*)receiveCommandAndReportIfError:(NSError**)error
{
	ibrd(m_iDevice, m_cBuffer, IADEVICE_BUFFER_LENGTH);
	BOOL	bResult	= YES;
	if(Ibsta() & ERR)
	{
		if(NULL != error)
			*error	= [NSError errorWithDomain:[self errorGPIB] 
										 code:__LINE__ 
									 userInfo:nil];
		bResult	= NO;
	}
	if(self.AutoFlush)
		[self flushBufferAndReportIfError:nil];
	return (bResult 
			? [NSString stringWithFormat:@"%s", m_cBuffer] 
			: nil);
}

-(BOOL)disconnectAndReportIfError:(NSError**)error
{
	ibonl(m_iDevice, 0);
	ibonl(m_iBoardIndex, 0);
	if(Ibsta() & ERR)
	{
		if(NULL != error)
			*error	= [NSError errorWithDomain:[self errorGPIB] 
										 code:__LINE__ 
									 userInfo:nil];
		return NO;
	}
	return YES;
}



#pragma mark - IADevice Interface Implementation 
/*!
 *	Override from IADevice.
 *	@param	dictProperties
 *			KEY					-> CLASS	: DEFAULT	: MEANS
 *			BOARD_INDEX			-> Number	: 0			: The first GPIB card. 
 *			PRIMARY_ADDRESS		-> Number	: 20		: Address of device, see your device settings. 
 *			SECONDARY_ADDRESS	-> Number	: 0			: Unknow. 
 *			TIMEOUT				-> Number	: 10000000	: Microsceonds(10^-6 s), 
 *															will convert to most approximate value. 
 *			EOI					-> Number	: YES		: 
 *			EOS					-> Number	: NO		: 
 */
-(id)INIT_WITH_PROPERTIES:(NSDictionary *)dictProperties 
				   RESULT:(id*)idResult
{
	self	= [super INIT_WITH_PROPERTIES:dictProperties 
								RESULT:idResult];
	m_iDevice		= 0;
	m_iBoardIndex	= ([[dictProperties objectForKey:@"BOARD_INDEX"] 
						isKindOfClass:[NSNumber class]] 
					   ? [[dictProperties objectForKey:@"BOARD_INDEX"] 
						  unsignedIntegerValue] 
					   : 0);
	NSUInteger	iPrimaryAddress	= ([[dictProperties objectForKey:@"PRIMARY_ADDRESS"] 
									isKindOfClass:[NSNumber class]]
								   ? [[dictProperties objectForKey:@"PRIMARY_ADDRESS"] 
									  unsignedIntegerValue]
								   : 20);
	NSUInteger	iSecondaryAddress	= ([[dictProperties objectForKey:@"SECONDARY_ADDRESS"] 
										isKindOfClass:[NSNumber class]]
									   ? [[dictProperties objectForKey:@"SECONDARY_ADDRESS"] 
										  unsignedIntegerValue]
									   : 0);
	NSUInteger	iTimeout	= ([[dictProperties objectForKey:@"TIMEOUT"] 
								isKindOfClass:[NSNumber class]]
							   ? [[dictProperties objectForKey:@"TIMEOUT"] 
								  unsignedIntegerValue] 
							   : T10s);
	BOOL	bEOI	= ([[dictProperties objectForKey:@"EOI"] 
						isKindOfClass:[NSNumber class]]
					   ? [[dictProperties objectForKey:@"EOI"] boolValue]
					   : YES);
	BOOL	bEOS	= ([[dictProperties objectForKey:@"EOS"] 
						isKindOfClass:[NSNumber class]]
					   ? [[dictProperties objectForKey:@"EOS"] boolValue]
					   : NO);
	NSError	*error	= nil;
	if(![self setGPIBBoardIndex:m_iBoardIndex 
				 primaryAddress:iPrimaryAddress 
			   secondaryAddress:iSecondaryAddress 
						timeOut:iTimeout 
							EOI:bEOI EOS:bEOS 
						  error:&error])
		if(NULL != idResult)
			*idResult	= [error domain];
	return self;
}

-(BOOL)SET_PROPERTIES:(NSDictionary *)dictProperties 
			   RESULT:(id*)idResult
{
	self.AutoFlush	= ([[dictProperties objectForKey:@"AUTOFLUSH"] 
						isKindOfClass:[NSNumber class]]
					   ? [[dictProperties objectForKey:@"AUTOFLUSH"] boolValue]
					   : self.AutoFlush);
	return YES;
}

-(BOOL)CONNECT:(NSDictionary*)dictCommand 
		RESULT:(id *)idResult
{
	NSError	*error	= nil;
	BOOL	bResult	= [self setGPIBBoardIndex:m_original.BoardIndex 
							primaryAddress:m_original.PrimaryAddress 
						  secondaryAddress:m_original.SecondaryAddress 
								   timeOut:m_original.TimeOut 
									   EOI:m_original.EOI 
									   EOS:m_original.EOS 
									 error:&error];
	if(NULL != idResult)
		*idResult	= (bResult 
					   ? IADEVICE_COMMAND_SUCCESS 
					   : [error domain]);
	return bResult;
}

-(BOOL)SEND_COMMAND:(NSDictionary *)dictCommand 
			 RESULT:(id *)idResult
{
	// Command judgement. 
	id	idCommand	= [dictCommand objectForKey:@"COMMAND"];
	if(!idCommand 
	   || (![idCommand isKindOfClass:[NSString class]] 
		   && ![idCommand isKindOfClass:[NSArray class]]))
	{
		if(NULL != idResult)
			*idResult	= IADEVICE_COMMAND_NOTFOUND;
		return NO;
	}
	// Get wait time. 
	unsigned int	iWait	= 0;
	if([[dictCommand objectForKey:@"WAIT"] isKindOfClass:[NSNumber class]])
		iWait	= [[dictCommand objectForKey:@"WAIT"] unsignedIntValue];
	// Send. 
	BOOL	bResult	= YES;
	NSError	*error	= nil;
	if([idCommand isKindOfClass:[NSString class]])
		bResult	&= [self sendCommand:idCommand error:&error];
	else
		for(NSString *strCommand in idCommand)
		{
			bResult	&= [self sendCommand:strCommand error:&error];
			if(iWait)
				usleep(iWait);
		}
	// End. 
	if(NULL != idResult)
		*idResult	= (bResult 
					   ? IADEVICE_COMMAND_SUCCESS 
					   : [error domain]);
	return bResult;
}

-(BOOL)FLUSH_BUFFER:(NSDictionary *)dictCommand 
			 RESULT:(id *)idResult
{
	NSError	*error	= nil;
	BOOL	bResult	= [self flushBufferAndReportIfError:&error];
	if(NULL != idResult)
		*idResult	= (bResult 
					   ? IADEVICE_COMMAND_SUCCESS 
					   : [error domain]);
	return bResult;
}

-(BOOL)RECEIVE_COMMAND:(NSDictionary *)dictCommand 
				RESULT:(id *)idResult
{
	// Receive command. 
	NSError		*error		= nil;
	NSString	*strCommand	= [self receiveCommandAndReportIfError:&error];
	if(!strCommand)
	{
		if(NULL != idResult)
			*idResult	= (strCommand 
						   ? strCommand 
						   : [error domain]);
		return NO;
	}
	// Get result. 
	return [super subResponse:strCommand 
			   withProperties:dictCommand 
					   result:idResult];
}

-(BOOL)DISCONNECT:(NSDictionary *)dictCommand 
		   RESULT:(id *)idResult
{
	NSError	*error	= nil;
	BOOL	bResult	= [self disconnectAndReportIfError:&error];
	if(NULL != idResult)
		*idResult	= (bResult 
					   ? IADEVICE_COMMAND_SUCCESS 
					   : [error domain]);
	return bResult;
}



#pragma mark - Basic Informations 
-(NSString *)Name
{
	NSError	*error;
	if(![self sendCommand:@"*IDN?" 
					error:&error])
		return [error domain];
	NSString	*strName	= [self receiveCommandAndReportIfError:&error];
	return strName ? strName : [error domain];
}

-(NSUInteger)Timeout
{
	return 0;
}

-(void)setTimeout:(NSUInteger)newTimeout
{
	return;
}

-(BOOL)AutoFlush
{
	return m_bAutoFlush;
}

-(void)setAutoFlush:(BOOL)AutoFlush
{
	m_bAutoFlush	= AutoFlush;
}



#pragma mark - Tools 
-(NSString*)errorGPIB
{
	NSMutableString	*strError	= [NSMutableString string];
	unsigned long	lState		= Ibsta();
	if(lState & ERR)
		[strError appendString:@"ERR: Error detected. \n"];
	if(lState & TIMO)
		[strError appendString:@"TIMO: Timeout. \n"];
	if(lState & END)
		[strError appendString:@"END: EOI or EOS detected. \n"];
	if(lState & SRQI)
		[strError appendString:@"SRQI: SRQ detected by CIC. \n"];
	if(lState & RQS)
		[strError appendString:@"RQS: Device needs service. \n"];
	if(lState & CMPL)
		[strError appendString:@"CMPL: I/O completed. \n"];
	if(lState & LOK)
		[strError appendString:@"LOK: Local lockout state. \n"];
	if(lState & REM)
		[strError appendString:@"REM: Remote state. \n"];
	if(lState & CIC)
		[strError appendString:@"CIC: Controller-in-Charge. \n"];
	if(lState & ATN)
		[strError appendString:@"ATN: Attention asserted. \n"];
	if(lState & TACS)
		[strError appendString:@"TACS: Talker active. \n"];
	if(lState & LACS)
		[strError appendString:@"LACS: Listener active. \n"];
	if(lState & DTAS)
		[strError appendString:@"DTAS: Device trigger state. \n"];
	if(lState & DCAS)
		[strError appendString:@"DCAS: Device clear state. \n"];
	
	switch(Iberr())
	{
		case EDVR:
			[strError appendString:@"EDVR: System error. "];
			break;
		case ECIC:
			[strError appendString:@"ECIC: Function requires GPIB board to be CIC. "];
			break;
		case ENOL:
			[strError appendString:@"ENOL: Write function detected no Listeners. "];
			break;
		case EADR:
			[strError appendString:@"EADR: Interface board not addressed correctly. "];
			break;
		case EARG:
			[strError appendString:@"EARG: Invalid argument to function call. "];
			break;
		case ESAC:
			[strError appendString:@"ESAC: Function requires GPIB board to be SAC. "];
			break;
		case EABO:
			[strError appendString:@"EABO: I/O operation aborted. "];
			break;
		case ENEB:
			[strError appendString:@"ENEB: Non-existent interface boar. "];
			break;
		case EDMA:
			[strError appendString:@"EDMA: Error performing DMA. "];
			break;
		case EOIP:
			[strError appendString:@"EOIP: I/O operation started before previous operation completed. "];
			break;
		case ECAP:
			[strError appendString:@"ECAP: No capability for intended operation. "];
			break;
		case EFSO:
			[strError appendString:@"EFSO: File system operation error. "];
			break;
		case EBUS:
			[strError appendString:@"EBUS: Command error during device call. "];
			break;
		case ESTB:
			[strError appendString:@"ESTB: Serial poll status byte lost. "];
			break;
		case ESRQ:
			[strError appendString:@"ESRQ: SRQ remains asserted. "];
			break;
		case ETAB:
			[strError appendString:@"ETAB: The return buffer is full. "];
			break;
		case ELCK:
			[strError appendString:@"ELCK: Address or board is locked. "];
			break;
		case EARM:
			[strError appendString:@"EARM: The ibnotify Callback failed to rearm. "];
			break;
		case EHDL:
			[strError appendString:@"EHDL: The input handle is invalid. "];
			break;
		case EWIP:
			[strError appendString:@"EWIP: Wait already in progress on input ud. "];
			break;
		case ERST:
			[strError appendString:@"ERST: The event notification was cancelled due to a reset of the interface. "];
			break;
		case EPWR:
			[strError appendString:@"EPWR: The system or board has lost power or gone to standby. "];
			break;
		case WCFG:
			[strError appendString:@"WCFG: Configuration warning. "];
			break;
		default:
			[strError appendString:@"No other error. "];
			break;
	}
	return [strError description];
}

-(int)convertTimeout:(NSUInteger)iTimeout
{
	if(!iTimeout)	// Unlimited. 
		return TNONE;
	else if(iTimeout <= 10)	// 10 us. 
		return T10us;
	else if(iTimeout <= 30)	// 30 us. 
		return T30us;
	else if(iTimeout <= 100)	// 100 us. 
		return T100us;
	else if(iTimeout <= 300)	// 300 us. 
		return T300us;
	else if(iTimeout <= 1000)	// 1 ms. 
		return T1ms;
	else if(iTimeout <= 3000)	// 3 ms. 
		return T3ms;
	else if(iTimeout <= 10000)	// 10 ms. 
		return T10ms;
	else if(iTimeout <= 30000)	// 30 ms. 
		return T30ms;
	else if(iTimeout <= 100000)	// 100 ms. 
		return T100ms;
	else if(iTimeout <= 300000)	// 300 ms. 
		return T300ms;
	else if(iTimeout <= 1000000)	// 1 s. 
		return T1s;
	else if(iTimeout <= 3000000)	// 3 s. 
		return T3s;
	else if(iTimeout <= 10000000)	// 10 s. 
		return T10s;
	else if(iTimeout <= 30000000)	// 30 s. 
		return T30s;
	else if(iTimeout <= 100000000)	// 100 s. 
		return T100s;
	else if(iTimeout <= 300000000)	// 300 s. 
		return T300s;
	else	// Other. 
		return T1000s;
}



@end


