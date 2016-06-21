//
//  InstrumentBase.m
//  InstrumentTest
//
//  Created by 吳 枝霖 on 2009/4/20.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//



#import "InstrumentBase.h"
//#include <NI488/ni488.h>
#include <NI4882/ni4882.h>

#define		kReadBufferSize		1024

@implementation InstrumentBase

-(id)init
{
    if ((self = [super init]))
	{
        NSBundle		*thisBundle	= [NSBundle bundleForClass:[self class]];
        NSDictionary	*mInfo		= [thisBundle infoDictionary];
        m_Version		= [[NSString alloc] initWithString:[mInfo valueForKey:@"CFBundleVersion"]];
        
        m_device		= 0;
        m_fDelayTime	= 0;
        NSLog(@"mInfo = %@, m_Version = %@",mInfo,m_Version);
    }
	return self;
}

-(void)dealloc
{
	[m_Version release];
	if (m_device)
		[self releaseDevice];
	[super dealloc];
}

-(NSString*)getInterfaceVersion
{
	return m_Version;
}

-(void)GpibError:(char*)msg
{
	printf ("%s\n", msg);
	
    printf ("Ibsta() = 0x%x  <", Ibsta());
    if (Ibsta() & ERR )
		printf (" ERR");
    if (Ibsta() & TIMO)
		printf (" TIMO");
    if (Ibsta() & END )
		printf (" END");
    if (Ibsta() & SRQI)
		printf (" SRQI");
    if (Ibsta() & RQS )
		printf (" RQS");
    if (Ibsta() & CMPL)
		printf (" CMPL");
    if (Ibsta() & LOK )
		printf (" LOK");
    if (Ibsta() & REM )
		printf (" REM");
    if (Ibsta() & CIC )
		printf (" CIC");
    if (Ibsta() & ATN )
		printf (" ATN");
    if (Ibsta() & TACS)
		printf (" TACS");
    if (Ibsta() & LACS)
		printf (" LACS");
    if (Ibsta() & DTAS)
		printf (" DTAS");
    if (Ibsta() & DCAS)
		printf (" DCAS");
    printf (" >\n");
	
    printf ("Iberr() = %d", Iberr());
    if (Iberr() == EDVR)
		printf (" EDVR <System Error>\n");
    if (Iberr() == ECIC)
		printf (" ECIC <Not Controller-In-Charge>\n");
    if (Iberr() == ENOL)
		printf (" ENOL <No Listener>\n");
    if (Iberr() == EADR)
		printf (" EADR <Address error>\n");
    if (Iberr() == EARG)
		printf (" EARG <Invalid argument>\n");
    if (Iberr() == ESAC)
		printf (" ESAC <Not System Controller>\n");
    if (Iberr() == EABO)
		printf (" EABO <Operation aborted>\n");
    if (Iberr() == ENEB)
		printf (" ENEB <No GPIB board>\n");
    if (Iberr() == EOIP)
		printf (" EOIP <Async I/O in progress>\n");
    if (Iberr() == ECAP)
		printf (" ECAP <No capability>\n");
    if (Iberr() == EFSO)
		printf (" EFSO <File system error>\n");
    if (Iberr() == EBUS)
		printf (" EBUS <GPIB bus error>\n");
    if (Iberr() == ESTB)
		printf (" ESTB <Status byte lost>\n");
    if (Iberr() == ESRQ)
		printf (" ESRQ <SRQ stuck on>\n");
    if (Iberr() == ETAB)
		printf (" ETAB <Table Overflow>\n");
	
    printf ("\n");
    printf ("Ibcnt() = %u\n", Ibcnt());
    printf ("\n");
	
    /* Call ibonl to take the device and interface offline */
    ibonl (m_device,0);
    ibonl (m_BoardIndex,0);
}

-(int)setInitialDevice:(int)nBoardID
		   PrimaryAddr:(int)nPrimaryAddr
{
	int	nRetCode			= kSuccessCode;
	int	SecondaryAddress	= 0;			/* Secondary address of the device         */
	m_device	= ibdev(					/* Create a unit descriptor handle         */
						nBoardID,			/* Board Index (GPIB0 = 0, GPIB1 = 1, ...) */
						nPrimaryAddr,		/* Device primary address                  */
						SecondaryAddress,	/* Device secondary address                */
						T10s,				/* Timeout setting (T10s = 10 seconds)     */
						1,					/* Assert EOI line at end of write         */
						0);					/* EOS termination mode                    */
	m_BoardIndex	= nBoardID;
	if (Ibsta() & ERR)
	{
		[self GpibError:"ibrd Error"];
		nRetCode	= kGPIB_Error;
	}
	ibclr(m_device);						/* Clear the device                        */
	if (Ibsta() & ERR)
	{
		[self GpibError:"ibclr Error"];
		nRetCode	= kGPIB_Error;
	}
	return nRetCode;
}

-(void)releaseDevice
{
	if (m_device)
	{
		ibonl(m_device, 0);					/* Take the device offline                 */
		if(Ibsta() & ERR)
			[self GpibError:"ibonl Error"];	
		
		ibonl(m_BoardIndex, 0);				/* Take the interface offline              */
		if(Ibsta() & ERR)
			[self GpibError:"ibonl Error"];	
		m_device = 0;
	}
	NSLog(@"releaseDevice");
}

-(int)setRST_Command
{
	int	nRetCode	= kSuccessCode;
	nRetCode		= [self sendGPIB_Command:@"*RST"];
	NSLog(@"%d = setRST_Command", nRetCode); 
	return nRetCode;
}

-(int)setOPC_Command
{
	int	nRetCode	= kSuccessCode;
	nRetCode		= [self sendGPIB_Command:@"*OPC"];
	NSLog(@"%d = setOPC_Command", nRetCode); 
	return nRetCode;
}

-(int)setCLS_Command
{
	int	nRetCode	= kSuccessCode;
	nRetCode		= [self sendGPIB_Command:@"*CLS"];
	NSLog(@"%d = setCLS_Command", nRetCode); 
	return nRetCode;
}

-(int)getInstrumentName:(NSMutableString*)aDeviceName
{
	int	nRetCode	= kSuccessCode;
	nRetCode		= [self sendGPIB_Command:@"*IDN?"];
	if (nRetCode == kSuccessCode)
		nRetCode	= [self getCommand_Result:aDeviceName];
	else 
        [aDeviceName setString:@""];
	NSLog(@"%d = getInstrumentName(%@)",nRetCode,aDeviceName); 
	return nRetCode;
}

-(int)sendGPIB_Command:(NSString*)aCommand
{
	int	nRetCode	= kSuccessCode;
	if (m_device)
	{
		ibwrt(m_device, (char *)[aCommand UTF8String], [aCommand length]);
		if(Ibsta() & ERR)
		{
			[self GpibError:"ibwrt Error"];
			nRetCode = kGPIB_Error;
		}
	}
	else
		nRetCode = kNoInitDevice;
	return nRetCode;
}

-(int)getCommand_Result:(NSMutableString*)aResult
{
	int	nRetCode	= kSuccessCode;
	if(m_device)
	{
		char	Buffer[kReadBufferSize+1]	= {0};	/* Read buffer                             */
		ibrd(m_device, Buffer, kReadBufferSize);	/* Read up to 100 bytes from the device    */
		if (Ibsta() & ERR)
		{
			[self GpibError:"ibrd Error"];
			nRetCode	= kGPIB_Error;
			[aResult setString:@""];
		}
		else
			[aResult setString:[NSString stringWithFormat:@"%s",Buffer]];
	}
	else
		nRetCode	= kNoInitDevice;
	return nRetCode;
}

-(void)setQueryDelay:(float)fDelayTime
{
	m_fDelayTime	= fDelayTime;
}

@end




