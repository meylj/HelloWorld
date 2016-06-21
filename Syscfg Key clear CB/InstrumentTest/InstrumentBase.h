//
//  InstrumentBase.h
//  InstrumentTest
//
//  Created by 吳 枝霖 on 2009/4/20.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//



#import <Cocoa/Cocoa.h>
#import "ErrorCodeDef.h"



@interface InstrumentBase : NSObject
{
	int			m_device;
	int			m_BoardIndex;
	float		m_fDelayTime;
	NSString	*m_Version;
}

- (NSString *) getInterfaceVersion;
/**
 nDelayTime		: second
 description	: Set Query delay time. */
-(void)setQueryDelay:(float)nDelayTime;
-(int)setInitialDevice:(int)nBoardID
		   PrimaryAddr:(int)nPrimaryAddr;
-(void)releaseDevice;
// Resets the Instrument to a known state
-(int)setRST_Command;
// Clears Status data structures (Event Registers and Error Queue). 
-(int)setCLS_Command;
// Causes Counter to set the operation complete bit in the Standard Event Status 
// Register when all pending operations (see Note) are finished. 
-(int)setOPC_Command;
-(int)getInstrumentName:(NSMutableString*)szDeviceName;
-(int)sendGPIB_Command:(NSString*)aCommand;
-(int)getCommand_Result:(NSMutableString*)szResult;
-(void)GpibError:(char*)msg;

@end




