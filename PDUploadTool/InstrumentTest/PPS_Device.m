//
//  PPS_Device.m
//  InstrumentTest
//
//  Created by 吳 枝霖 on 2009/4/21.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PPS_Device.h"


@implementation PPS_Device

- (int) setInitialDevice:(int) nBoardID PrimaryAddr:(int) nPrimaryAddr {
	int nRetCode = kSuccessCode;
	nRetCode = [super setInitialDevice:nBoardID PrimaryAddr:nPrimaryAddr];
	if (nRetCode == kSuccessCode) {
		NSMutableString *aDeviceName  = [[[NSMutableString alloc] initWithString:@""] autorelease];
		nRetCode = [self getInstrumentName:aDeviceName];
		NSLog(@"Initial Device : %@ => %d", aDeviceName, nRetCode);
		NSRange	aRange;
		m_PPS_Identification = kUnknownDevice;
		aRange = [aDeviceName rangeOfString:@"PPS-1201"];
		if ((aRange.location != NSNotFound) && (aRange.length > 0) && ((aRange.length + aRange.location) <=  [aDeviceName length]))
			m_PPS_Identification = kMotechPPS_1201;
		aRange = [aDeviceName rangeOfString:@"Agilent Technologies,66321"];
		if ((aRange.location != NSNotFound) && (aRange.length > 0) && ((aRange.length + aRange.location) <=  [aDeviceName length]))
			m_PPS_Identification = kAgilentPPS_66321;
	}
	NSLog(@"%d = setInitialDevice(nBoardID=%d,nPrimaryAddr=%d)",nRetCode,nBoardID,nPrimaryAddr);
	return nRetCode;
}

- (int) SetVoltage:(int) nChannel Voltage:(float) fVoltage {
	int nRetCode = kSuccessCode;
	NSString	*aStr, *aCmd;
	
	if (m_PPS_Identification == kAgilentPPS_66321)
		aCmd = @"VOLT";
	else
		aCmd = @"VSET";
	switch (nChannel) {
		case 0 :
			aStr = [NSString stringWithFormat:@"%@ %3.3f",aCmd,fVoltage];
			break;
		case 1 :
		case 2 :
			aStr = [NSString stringWithFormat:@"%@%d %3.3f",aCmd,nChannel,fVoltage];
			break;
		default:
			nRetCode = kFuncParamterError;
			break;
	}
	if (nRetCode == kSuccessCode) 
		nRetCode = [self sendGPIB_Command:aStr];
	NSLog(@"%d = SetVoltage(nChannel=%d,Voltage=%3.3f)",nRetCode,nChannel,fVoltage);
	return nRetCode;
}

- (int) SetCurrLimit:(int) nChannel Current:(float) fCurrent {
	int nRetCode = kSuccessCode;
	NSString	*aStr,*aCmd;
	
	if (m_PPS_Identification == kAgilentPPS_66321)
		aCmd = @"CURR";
	else
		aCmd = @"ISET";
	switch (nChannel) {
		case 0 :
			aStr = [NSString stringWithFormat:@"%@ %3.3f",aCmd,fCurrent];
			break;
		case 1 :
		case 2 :
			aStr = [NSString stringWithFormat:@"%@%d %3.3f",aCmd,nChannel,fCurrent];
			break;
		default:
			nRetCode = kFuncParamterError;
			break;
	}
	if (nRetCode == kSuccessCode) 
		nRetCode = [self sendGPIB_Command:aStr];
	NSLog(@"%d = SetCurrLimit(nChannel=%d,Current=%3.3f)",nRetCode,nChannel,fCurrent);
	return nRetCode;	
}

- (int) SetPowrSwitch:(int) nChannel PowerON:(BOOL) bOnOff {
	int nRetCode = kSuccessCode;
	NSString	*aStr,*aCmd;
	
	if (m_PPS_Identification == kAgilentPPS_66321)
		aCmd = @"OUTP";
	else
		aCmd = @"OUT";	
	switch (nChannel) {
		case 0 :
			aStr = [NSString stringWithFormat:@"%@ %d",aCmd,bOnOff];
			break;
		case 1 :
		case 2 :
			aStr = [NSString stringWithFormat:@"%@%d %d",aCmd,nChannel,bOnOff];
			break;
		default:
			nRetCode = kFuncParamterError;
			break;
	}
	if (nRetCode == kSuccessCode) 
		nRetCode = [self sendGPIB_Command:aStr];
	NSLog(@"%d = SetPowrSwitch(nChannel=%d,PowerON=%d)",nRetCode,nChannel,bOnOff);
	return nRetCode;	
}

- (int) GetCurrent:(int) nChannel Current:(float *) fCurrent {
	int nRetCode = kSuccessCode;
	NSString	*aCmd;
    NSMutableString *aStr = [[[NSMutableString alloc]initWithString:@""]autorelease];
	
	if (m_PPS_Identification == kAgilentPPS_66321)
		aCmd = @"MEAS:CURR";
	else
	{
		//aCmd = @"IOUT";
		aCmd = @"SENS:FUNC 'CURR'";
		nRetCode = [self sendGPIB_Command:aCmd];
		aCmd = @"READ";
	}
	switch (nChannel) {
		case 0 :
            [aStr setString:[NSString stringWithFormat:@"%@?",aCmd]];
			break;
		case 1 :
		case 2 :
            [aStr setString:[NSString stringWithFormat:@"%@%d",aCmd,nChannel]];
			break;
		default:
			nRetCode = kFuncParamterError;
			break;
	}
	*fCurrent = -1;
	if (nRetCode == kSuccessCode) {
		nRetCode = [self sendGPIB_Command:aStr];
		if (nRetCode == kSuccessCode) {
			[NSThread sleepForTimeInterval:m_fDelayTime];
			nRetCode = [self getCommand_Result:aStr];
			if (nRetCode == kSuccessCode)
				*fCurrent = [aStr floatValue];
		}
	}
	NSLog(@"%d = GetCurrent(nChannel=%d,Current=%3.3f)",nRetCode,nChannel,*fCurrent);
	return nRetCode;		
}
@end
