//
//  PPS_Device.h
//  InstrumentTest
//
//  Created by 吳 枝霖 on 2009/4/21.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "InstrumentBase.h"

@interface PPS_Device : InstrumentBase {
	int		m_PPS_Identification;
}
/****************************************************************************************************
 nChannel		: 0 (all channel), 1 (channel 1), 2 (channel 2)
 description	: Sets the voltage
 ****************************************************************************************************/
- (int) SetVoltage:(int) nChannel Voltage:(float) fVoltage;
/****************************************************************************************************
 nChannel		: 0 (all channel), 1 (channel 1), 2 (channel 2)
 description	: Sets the current
 ****************************************************************************************************/
- (int) SetCurrLimit:(int) nChannel Current:(float) fCurrent;
/****************************************************************************************************
 nChannel		: 0 (all channel), 1 (channel 1), 2 (channel 2)
 PowerOn		: YES (Power On), NO (Power Off)
 description	: Switch Power on or Off
 ****************************************************************************************************/
- (int) SetPowrSwitch:(int) nChannel PowerON:(BOOL) bOnOff;
/****************************************************************************************************
 nChannel		: 0 (all channel), 1 (channel 1), 2 (channel 2)
 description	: Queries the current output.
 ****************************************************************************************************/
- (int) GetCurrent:(int) nChannel Current:(float *) fCurrent;
@end
