//
//  Device_53131.m
//  InstrumentTest
//
//  Created by 吳 枝霖 on 2009/4/23.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//



#import "Device_53131.h"



@implementation Device_53131

-(int)setInitialDevice:(int)nBoardID
		   PrimaryAddr:(int)nPrimaryAddr
{
	int	nRetCode	= kSuccessCode;
	nRetCode	= [super setInitialDevice:nBoardID PrimaryAddr:nPrimaryAddr];
	if (nRetCode == kSuccessCode)
	{
		NSMutableString	*aDeviceName	= [[[NSMutableString alloc] initWithString:@""] autorelease];
		nRetCode	= [self getInstrumentName:aDeviceName];
		NSLog(@"Initial Device : %@ => %d", aDeviceName, nRetCode);
		nRetCode	= [self setCLS_Command];
	}
	return nRetCode;
}

- (int) setMeasureFrequency
{
	int	nRetCode	= kSuccessCode;
	
	if (nRetCode == kSuccessCode)
		nRetCode = [self setRST_Command];								/* Reset the counter */ 
	if (nRetCode == kSuccessCode)
		nRetCode = [self setCLS_Command];								/* Clear event registers and error queue */ 
	if (nRetCode == kSuccessCode)
		nRetCode = [self sendGPIB_Command:@"*SRE 0"];					/* Clear service request enable register */
	if (nRetCode == kSuccessCode)
		nRetCode = [self sendGPIB_Command:@"*ESE 0"];					/* Clear event status enable register */ 
	if (nRetCode == kSuccessCode)
		nRetCode = [self sendGPIB_Command:@":STAT:PRES"];				/* Preset enable registers and transition 
																			filters for operation and questionable 
																			status structures */ 
	if (nRetCode == kSuccessCode)
		nRetCode = [self sendGPIB_Command:@":FUNC 'FREQ 1'"];			/* Measure frequency on channel 1 
																			Note that the function must 
																			be a quoted string. The actual 
																			string sent to the counter is 
																			'FREQ 1'. */ 
	if (nRetCode == kSuccessCode)
		nRetCode = [self sendGPIB_Command:@":FREQ:ARM:STAR:SOUR IMM"];	/* These 3 lines enable the */
	if (nRetCode == kSuccessCode)
		nRetCode = [self sendGPIB_Command:@":FREQ:ARM:STOP:SOUR TIM"];	/* time arming mode with a */
	if (nRetCode == kSuccessCode)
		nRetCode = [self sendGPIB_Command:@":FREQ:ARM:STOP:TIM .1"];	/* 0.1 second gate time */
	NSLog(@"%d = setMeasureFrequency", nRetCode);
	return nRetCode;
}

- (int) getMeasureValue:(float *) fFrequency
{
	int	nRetCode	= kSuccessCode;
	NSMutableString	*strResult	= [[[NSMutableString alloc] initWithString:@""] autorelease];
	nRetCode = [self sendGPIB_Command:@"INIT"];							/* Start a measurement */
	if (nRetCode == kSuccessCode)
		nRetCode = [self sendGPIB_Command:@"FETCH:FREQUENCY?"];			
	if (nRetCode == kSuccessCode)
	{
		[NSThread sleepForTimeInterval:m_fDelayTime];
		nRetCode = [self getCommand_Result:strResult];
	}
	if (nRetCode == kSuccessCode)
		*fFrequency = [strResult floatValue];
	NSLog(@"%d = getMeasureValue(%3.3f)", nRetCode,*fFrequency);
	return nRetCode;
}

@end




