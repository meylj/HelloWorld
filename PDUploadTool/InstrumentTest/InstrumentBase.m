//
//  InstrumentBase.m
//  InstrumentTest
//
//  Created by 吳 枝霖 on 2009/4/20.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "InstrumentBase.h"
#include <NI488/ni488.h>
#define		kReadBufferSize		1024

@implementation InstrumentBase


- (id) init {
    if ((self = [super init])) {
        NSBundle		*thisBundle = [NSBundle bundleForClass:[self class]];
        NSDictionary	*mInfo = [thisBundle infoDictionary];
        m_Version = [[NSString alloc] initWithString:[mInfo valueForKey:@"CFBundleVersion"]];
        
        m_device = 0;
        m_fDelayTime = 0;
        NSLog(@"mInfo = %@, m_Version = %@",mInfo,m_Version);
    }
	return self;
}

- (void) dealloc {
	[m_Version release];
	if (m_device)
		[self releaseDevice];
	[super dealloc];
}

- (NSString *) getInterfaceVersion {
	return m_Version;
}

- (void) GpibError:(char *) msg {
	printf ("%s\n", msg);
	
    printf ("ibsta = 0x%x  <", ibsta);
    if (ibsta & ERR )  printf (" ERR");
    if (ibsta & TIMO)  printf (" TIMO");
    if (ibsta & END )  printf (" END");
    if (ibsta & SRQI)  printf (" SRQI");
    if (ibsta & RQS )  printf (" RQS");
    if (ibsta & CMPL)  printf (" CMPL");
    if (ibsta & LOK )  printf (" LOK");
    if (ibsta & REM )  printf (" REM");
    if (ibsta & CIC )  printf (" CIC");
    if (ibsta & ATN )  printf (" ATN");
    if (ibsta & TACS)  printf (" TACS");
    if (ibsta & LACS)  printf (" LACS");
    if (ibsta & DTAS)  printf (" DTAS");
    if (ibsta & DCAS)  printf (" DCAS");
    printf (" >\n");
	
    printf ("iberr = %d", iberr);
    if (iberr == EDVR) printf (" EDVR <System Error>\n");
    if (iberr == ECIC) printf (" ECIC <Not Controller-In-Charge>\n");
    if (iberr == ENOL) printf (" ENOL <No Listener>\n");
    if (iberr == EADR) printf (" EADR <Address error>\n");
    if (iberr == EARG) printf (" EARG <Invalid argument>\n");
    if (iberr == ESAC) printf (" ESAC <Not System Controller>\n");
    if (iberr == EABO) printf (" EABO <Operation aborted>\n");
    if (iberr == ENEB) printf (" ENEB <No GPIB board>\n");
    if (iberr == EOIP) printf (" EOIP <Async I/O in progress>\n");
    if (iberr == ECAP) printf (" ECAP <No capability>\n");
    if (iberr == EFSO) printf (" EFSO <File system error>\n");
    if (iberr == EBUS) printf (" EBUS <GPIB bus error>\n");
    if (iberr == ESTB) printf (" ESTB <Status byte lost>\n");
    if (iberr == ESRQ) printf (" ESRQ <SRQ stuck on>\n");
    if (iberr == ETAB) printf (" ETAB <Table Overflow>\n");
	
    printf ("\n");
    printf ("ibcntl = %ld\n", ibcntl);
    printf ("\n");
	
    /* Call ibonl to take the device and interface offline */
    ibonl (m_device,0);
    ibonl (m_BoardIndex,0);
}

- (int) setInitialDevice: (int) nBoardID PrimaryAddr:(int) nPrimaryAddr {
	int nRetCode = kSuccessCode;
	int SecondaryAddress = 0;				/* Secondary address of the device         */
	m_device = ibdev(						/* Create a unit descriptor handle         */
				   nBoardID,				/* Board Index (GPIB0 = 0, GPIB1 = 1, ...) */
				   nPrimaryAddr,			/* Device primary address                  */
				   SecondaryAddress,        /* Device secondary address                */
				   T10s,                    /* Timeout setting (T10s = 10 seconds)     */
				   1,                       /* Assert EOI line at end of write         */
				   0);                      /* EOS termination mode                    */
	m_BoardIndex = nBoardID;
	if (ibsta & ERR) {
		[self GpibError:"ibrd Error"];
		nRetCode = kGPIB_Error;
	}
	ibclr(m_device);							/* Clear the device                        */
	if (ibsta & ERR) {
		[self GpibError:"ibclr Error"];
		nRetCode = kGPIB_Error;
	}
	return nRetCode;
}

- (void) releaseDevice {
	if (m_device) {
		ibonl(m_device, 0);              /* Take the device offline                 */
		if (ibsta & ERR) {
			[self GpibError:"ibonl Error"];	
		}
		
		ibonl(m_BoardIndex, 0);          /* Take the interface offline              */
		if (ibsta & ERR) {
			[self GpibError:"ibonl Error"];	
		}
		m_device = 0;
	}
	NSLog(@"releaseDevice");
}

- (int) setRST_Command {
	int nRetCode = kSuccessCode;
	nRetCode = [self sendGPIB_Command:@"*RST"];
	NSLog(@"%d = setRST_Command", nRetCode); 
	return nRetCode;
}

- (int) setOPC_Command {
	int nRetCode = kSuccessCode;
	nRetCode = [self sendGPIB_Command:@"*OPC"];
	NSLog(@"%d = setOPC_Command", nRetCode); 
	return nRetCode;
}

- (int) setCLS_Command {
	int nRetCode = kSuccessCode;
	nRetCode = [self sendGPIB_Command:@"*CLS"];
	NSLog(@"%d = setCLS_Command", nRetCode); 
	return nRetCode;
}

- (int) getInstrumentName:(NSMutableString *) aDeviceName {
	int nRetCode = kSuccessCode;
	nRetCode = [self sendGPIB_Command:@"*IDN?"];
	if (nRetCode == kSuccessCode)
		nRetCode = [self getCommand_Result:aDeviceName];
	else 
    {
        [aDeviceName setString:@""];
	}
	NSLog(@"%d = getInstrumentName(%@)",nRetCode,aDeviceName); 
	return nRetCode;
}

- (int) sendGPIB_Command:(NSString *) aCommand {
	int nRetCode = kSuccessCode;
	if (m_device) {
		ibwrt(m_device, (char *)[aCommand UTF8String], [aCommand length]);
		if (ibsta & ERR) {
			[self GpibError:"ibwrt Error"];
			nRetCode = kGPIB_Error;
		}
	}
	else
		nRetCode = kNoInitDevice;
	return nRetCode;
}

- (int) getCommand_Result:(NSMutableString *) aResult {
	int nRetCode = kSuccessCode;
	if (m_device) {
		char  Buffer[kReadBufferSize+1] = {0};			/* Read buffer                             */
		ibrd(m_device, Buffer, kReadBufferSize);		/* Read up to 100 bytes from the device    */
		if (ibsta & ERR) {
			[self GpibError:"ibrd Error"];
			nRetCode = kGPIB_Error;
			[aResult setString:@""];
		}
		else
			[aResult setString:[NSString stringWithFormat:@"%s",Buffer]];
	}
	else
		nRetCode = kNoInitDevice;
	return nRetCode;
}

- (void) setQueryDelay:(float) fDelayTime {
	m_fDelayTime = fDelayTime;
}
@end
