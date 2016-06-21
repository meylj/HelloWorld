//
//  Device_34401A.m
//  InstrumentTest
//
//  Created by wu howard on 09-9-7.
//  Copyright 2009 pegatron. All rights reserved.
//

#import "Device_34401A.h"


@implementation Device_34401A
- (id) init {

	return [super init];
}

-(int)setInitialDevice:(int)nBoardID PrimaryAddr:(int)nPrimaryAddr{
	int nRetCode = kSuccessCode;
	nRetCode=[super setInitialDevice:nBoardID PrimaryAddr:nPrimaryAddr];
	if (nRetCode==kSuccessCode) 
	{
		NSMutableString *aDeviceName = [[[NSMutableString alloc] initWithString:@""] autorelease];
		nRetCode=[self getInstrumentName:aDeviceName];
		NSLog(@"Initial Device :%@=> %d",aDeviceName,nRetCode);
	}
	
	return nRetCode;
}

-(int)_getMeasureVoltage:(bool)bIsDC range:(int)iRange resolution:(float)fResolution MeasureValue:(float*)fMeasureValue{
	
	int nRetCode = kSuccessCode;
	NSString	*strCommand, *strDCorAC;
    NSMutableString *strResult = [[[NSMutableString alloc] initWithString:@""] autorelease];
	if(bIsDC)
		strDCorAC=@"DC";
	else
		strDCorAC=@"AC";
	
	strCommand = [NSString stringWithFormat:@"MEASure:VOLTage:%@? %d,%f", strDCorAC,iRange, fResolution];
	
	nRetCode = [self sendGPIB_Command:strCommand];
	if (nRetCode == kSuccessCode) {
		[NSThread sleepForTimeInterval:m_fDelayTime];
		nRetCode = [self getCommand_Result:strResult];
	}
	if (nRetCode == kSuccessCode) {
		*fMeasureValue=[strResult floatValue];
	}
	NSLog(@"%d = getMeasureVoltage(%d,%@)",nRetCode,bIsDC,strResult);
	return nRetCode;
	
}

-(int)_getMeasureCurrent:(bool)bIsDC range:(int)iRange resolution:(float)fResolution MeasureValue:(float*)fMeasureValue{
	
	int nRetCode = kSuccessCode;
	NSString	*strCommand, *strDCorAC;
    NSMutableString *strResult = [[[NSMutableString alloc] initWithString:@""] autorelease];
	if(bIsDC)
		strDCorAC=@"DC";
	else
		strDCorAC=@"AC";
	
	strCommand = [NSString stringWithFormat:@"MEASure:CURRent:%@? %d,%f", strDCorAC, iRange,fResolution];
	
	nRetCode = [self sendGPIB_Command:strCommand];
	if (nRetCode == kSuccessCode) {
		[NSThread sleepForTimeInterval:m_fDelayTime];
		nRetCode = [self getCommand_Result:strResult];
	}
	if (nRetCode == kSuccessCode) {
		*fMeasureValue=[strResult floatValue];
	}
	NSLog(@"%d = getMeasureCurrent(%d,%@)",nRetCode,bIsDC,strResult);
	return nRetCode;
	
}
-(int)_getMeasureResistence: (int)iRange  MeasureValue:(float*)fMeasureValue{
	int nRetCode = kSuccessCode;
	NSString	*strCommand, *strRange;
    NSMutableString *strResult  = [[[NSMutableString alloc] initWithString:@""] autorelease];
	NSLog(@"Start getMeasureResistance => %d",__LINE__);
	switch (iRange) {
		case kAutoRange:
			strRange = @"AUTO";
			break;
		case k100ohm:
			strRange = @"100";
			break;
		case k1Kohm:
			strRange = @"1E3";
			break;
		case k10Kohm:
			strRange = @"10E3";
			break;
		case k100Kohm:
			strRange = @"100E3";
			break;
		case k1Mohm:
			strRange = @"1E6";
			break;
		case k10Mohm:
			strRange = @"10E6";
			break;
		default:
			strRange = @"AUTO";
			break;
	}
	strCommand = [NSString stringWithFormat:@"MEASure:RESistance? %@",strRange];
	nRetCode = [self sendGPIB_Command:strCommand];
	if (nRetCode == kSuccessCode) {
		[NSThread sleepForTimeInterval:m_fDelayTime];
		nRetCode = [self getCommand_Result:strResult];
	}
	if (nRetCode == kSuccessCode) {
		*fMeasureValue=[strResult floatValue];
	}
	NSLog(@"%d = getMeasureResistance(%d,%@)",nRetCode,iRange,strResult);
	return nRetCode;
	


}

@end
