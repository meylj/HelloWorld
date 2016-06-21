//
//  Device_34970.m
//  InstrumentTest
//
//  Created by 吳 枝霖 on 2009/4/22.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//



#import "Device_34970.h"



@implementation Device_34970

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
		if (nRetCode == kSuccessCode)
			nRetCode	= [self setCLS_Command];
	}
	return nRetCode;
}

-(int)setRoutSwitch:(BOOL)bOnOff
	   ChannelLists:(NSString*)aChannels
{
	int	nRetCode	= kSuccessCode;
	NSString	*strOnOff, *strCommand;
	NSLog(@"Start setRoutSwitch => %d",__LINE__);
	if (bOnOff)
		strOnOff	= @"CLOSE";
	else 
		strOnOff	= @"OPEN";
	strCommand	= [NSString stringWithFormat:@"ROUT:%@ (@%@)",strOnOff,aChannels];
	nRetCode	= [self sendGPIB_Command:strCommand];
	NSLog(@"%d = setRoutSwitch(%d,%@)",nRetCode,bOnOff,aChannels);
	return nRetCode;
}

-(int)getMeasureVoltage:(BOOL)bIsDC_VOLT
		   ChannelLists:(NSString*)aChannels
				Voltage:(NSMutableArray*)ArrayVoltage
{
	int	nRetCode	= kSuccessCode;
	NSString	*strDC_VOLT, *strCommand;
    NSMutableString	*strResult	= [[[NSMutableString alloc] initWithString:@""] autorelease];
	NSLog(@"Start getMeasureVoltage => %d",__LINE__);
	if (bIsDC_VOLT)
		strDC_VOLT	= @"DC";
	else
		strDC_VOLT	= @"AC";
	strCommand	= [NSString stringWithFormat:@"MEAS:VOLT:%@? AUTO,MAX, (@%@)",strDC_VOLT,aChannels];
	nRetCode	= [self sendGPIB_Command:strCommand];
	if (nRetCode == kSuccessCode)
	{
		[NSThread sleepForTimeInterval:m_fDelayTime];
		nRetCode = [self getCommand_Result:strResult];
	}
	if (nRetCode == kSuccessCode)
	{
        if ([ArrayVoltage count]) 
            [ArrayVoltage removeAllObjects];
        [ArrayVoltage addObjectsFromArray:[strResult componentsSeparatedByString:@","]];
    }
	NSLog(@"%d = getMeasureVoltage(%d,%@,%@)",
		  nRetCode,bIsDC_VOLT,aChannels,strResult);
	return nRetCode;
}


-(int)getCurrent:(BOOL)bIsDC_CURR
		   Quick:(BOOL)bQuick
		  Result:(NSMutableString*)strResult
	ChannelLists:(NSString*)aChannels
		 Current:(NSMutableArray*)ArrayCurrent
{
	int	nRetCode	= kSuccessCode;
	NSString	*strDC_CURR, *strCommand,*strQuick;
	NSLog(@"Start getCurrent => %d",__LINE__);
	if (bIsDC_CURR)
		strDC_CURR	= @"DC";
	else
		strDC_CURR	= @"AC";
	if (bQuick)
		strQuick	= @"MAX";
	else
		strQuick	= @"MIN";
	strCommand	= [NSString stringWithFormat:
				   @"MEAS:CURR:%@? MAX,%@, (@%@)",
				   strDC_CURR,strQuick,aChannels];
	nRetCode	= [self sendGPIB_Command:strCommand];
	if (nRetCode == kSuccessCode)
	{
		[NSThread sleepForTimeInterval:m_fDelayTime];
		nRetCode	= [self getCommand_Result:strResult];
	}
	if (nRetCode == kSuccessCode)
	{
        if ([ArrayCurrent count]) 
            [ArrayCurrent removeAllObjects];
        [ArrayCurrent addObjectsFromArray:[strResult componentsSeparatedByString:@","]];
    }
	return nRetCode;
}

-(int)getMeasureCurrent:(BOOL)bIsDC_CURR
		   ChannelLists:(NSString*)aChannels
				Current:(NSMutableArray*)ArrayCurrent
{
	int				nRetCode	= kSuccessCode;
	NSMutableString	*strResult	= [[[NSMutableString alloc] initWithString:@""] autorelease];
	NSLog(@"Start getMeasureCurrent => %d",__LINE__);
	nRetCode	= [self getCurrent:bIsDC_CURR
						  Quick:NO
						 Result:strResult
				   ChannelLists:aChannels
						Current:ArrayCurrent];
	NSLog(@"%d = getMeasureCurrent(%d,%@,%@)",
		  nRetCode,bIsDC_CURR,aChannels,strResult);
	return nRetCode;	
}

-(int)getQuickMeasureCurrent:(BOOL)bIsDC_CURR
				ChannelLists:(NSString*)aChannels
					 Current:(NSMutableArray*)ArrayCurrent
{
	int				nRetCode	= kSuccessCode;
	NSMutableString	*strResult	= [[[NSMutableString alloc] initWithString:@""] autorelease];
	NSLog(@"Start getQuickMeasureCurrent");
	nRetCode	= [self getCurrent:bIsDC_CURR
						  Quick:YES
						 Result:strResult
				   ChannelLists:aChannels
						Current:ArrayCurrent];
	NSLog(@"%d = getQuickMeasureCurrent(%d,%@,%@)",
		  nRetCode,bIsDC_CURR,aChannels,strResult);
	return nRetCode;	
}

-(int)getMeasureFrequency:(NSString*)aChannels
				Frequency:(NSMutableArray*)ArrayFrequency
{
	int				nRetCode	= kSuccessCode;
	NSString		*strCommand;
    NSMutableString	*strResult	= [[[NSMutableString alloc] initWithString:@""] autorelease];
	NSLog(@"Start getMeasureFrequency => %d",__LINE__);
	strCommand	= [NSString stringWithFormat:@"MEAS:FREQ? AUTO,MAX, (@%@)",aChannels];
	nRetCode	= [self sendGPIB_Command:strCommand];
	if (nRetCode == kSuccessCode)
	{
		[NSThread sleepForTimeInterval:m_fDelayTime];
		nRetCode	= [self getCommand_Result:strResult];
	}
	if (nRetCode == kSuccessCode)
	{
        if ([ArrayFrequency count])
            [ArrayFrequency removeAllObjects];
        [ArrayFrequency  addObjectsFromArray:[strResult componentsSeparatedByString:@","]];
    }
	NSLog(@"%d = getMeasureFrequency(%@,%@)",nRetCode,aChannels,strResult);
	return nRetCode;	
}

-(int)getMeasureResistance:(NSString*)aChannels
					 Range:(int)nRange
				Resistance:(NSMutableArray*)ArrayResistance
{
	int				nRetCode	= kSuccessCode;
	NSString		*strCommand, *strRange;
    NSMutableString	*strResult	= [[[NSMutableString alloc] initWithString:@""] autorelease];
	NSLog(@"Start getMeasureResistance => %d",__LINE__);
	switch (nRange)
	{
		case kAutoRange:
			strRange	= @"AUTO";
			break;
		case k100ohm:
			strRange	= @"100";
			break;
		case k1Kohm:
			strRange	= @"1E3";
			break;
		case k10Kohm:
			strRange	= @"10E3";
			break;
		case k100Kohm:
			strRange	= @"100E3";
			break;
		case k1Mohm:
			strRange	= @"1E6";
			break;
		case k10Mohm:
			strRange	= @"10E6";
			break;
		default:
			strRange	= @"AUTO";
			break;
	}
	strCommand	= [NSString stringWithFormat:@"MEAS:RES? %@,MAX, (@%@)",strRange,aChannels];
	nRetCode	= [self sendGPIB_Command:strCommand];
	if (nRetCode == kSuccessCode)
	{
		[NSThread sleepForTimeInterval:m_fDelayTime];
		nRetCode	= [self getCommand_Result:strResult];
	}
	if (nRetCode == kSuccessCode)
	{
        if ([ArrayResistance count]) 
            [ArrayResistance removeAllObjects];
        [ArrayResistance addObjectsFromArray:[strResult componentsSeparatedByString:@","]];
    }
	NSLog(@"%d = getMeasureResistance(%@,%d,%@)",nRetCode,aChannels,nRange,strResult);
	return nRetCode;
}

-(int)setMeasureCommand:(NSString*)aChannels
		   IntervalTime:(float)fIntervalTime
			 FetchCount:(int)iFetchCount
{
	int				nRetCode	= kSuccessCode;
	NSString		*strCommand;
	NSArray			*aryCount;
    NSMutableString	*strResult	= [[[NSMutableString alloc] initWithString:@""] autorelease];
	
	strCommand	= [NSString stringWithFormat:@"ROUTe:CHANnel:DELay %f,(@%@)", fIntervalTime, aChannels];
	nRetCode	= [self sendGPIB_Command:strCommand];
	if (nRetCode == kSuccessCode)
	{
		strCommand	= [NSString stringWithFormat:@"TRIG:COUNT %d",iFetchCount];
		nRetCode	= [self sendGPIB_Command:strCommand];
	}
	if (nRetCode == kSuccessCode)
		nRetCode	= [self sendGPIB_Command:@"INITiate"];
	if (nRetCode == kSuccessCode)
	{
		strCommand	= [NSString stringWithFormat:@"CALC:AVER:COUNT? (@%@)", aChannels];
		NSDate	*nowDT = [NSDate date];
		while (YES)
		{
			[NSThread sleepForTimeInterval:m_fDelayTime];
			nRetCode	= [self sendGPIB_Command:strCommand];
			if (nRetCode == kSuccessCode)
			{
				[NSThread sleepForTimeInterval:m_fDelayTime];
				nRetCode	= [self getCommand_Result:strResult];
				if (nRetCode == kSuccessCode)
				{
					BOOL	bExit	= YES;
					aryCount	= [strResult componentsSeparatedByString:@","];
					for (int i1 = 0;i1 < [aryCount count];i1 ++)
						if ([[aryCount objectAtIndex:i1] doubleValue] < iFetchCount)
						{
							bExit	= NO;
							break;
						}
					if (bExit)
						break;
				}
				else
					break;
			}
			else
				break;
			if (fabs([nowDT timeIntervalSinceNow]) > kFetchCountTimeOut)
			{
				nRetCode	= k34970_FetchTimeOut;
				break;
			}
		}
	}
	if (nRetCode == kSuccessCode)
	{
		strCommand	= [NSString stringWithFormat:@"CALC:AVER:AVER? (@%@)", aChannels];
		nRetCode	= [self sendGPIB_Command:strCommand];
	}
	return nRetCode;
}

-(int)readMeasureFrequency:(NSString*)aChannels
			  IntervalTime:(float)fIntervalTime
				FetchCount:(int)iFetchCount
				 Frequency:(NSMutableArray*)ArrayFrequency
{
	int				nRetCode	= kSuccessCode;
	NSString		*strCommand;
    NSMutableString	*strResult	= [[[NSMutableString alloc] initWithString:@""] autorelease];
	NSLog(@"Start readMeasureFrequency");
	strCommand	= [NSString stringWithFormat:@"CONF:FREQ AUTO,MAX, (@%@)",aChannels];
	nRetCode	= [self sendGPIB_Command:strCommand];
	if (nRetCode == kSuccessCode) 
		nRetCode = [self setMeasureCommand:aChannels
							  IntervalTime:fIntervalTime
								FetchCount:iFetchCount];
	if (nRetCode == kSuccessCode)
	{
		nRetCode	= [self getCommand_Result:strResult];
		if (nRetCode == kSuccessCode)
		{
            if ([ArrayFrequency count]) 
                [ArrayFrequency removeAllObjects];
            [ArrayFrequency  addObjectsFromArray:[strResult componentsSeparatedByString:@","]];
        }
	}
	NSLog(@"%d = readMeasureFrequency(%@,%f,%d,%@)",
		  nRetCode,aChannels,fIntervalTime,iFetchCount,strResult);
	return nRetCode;
}

-(int)readMeasureResistance:(NSString*)aChannels
					  Range:(int)nRange
			   IntervalTime:(float)fIntervalTime
				 FetchCount:(int)iFetchCount
				 Resistance:(NSMutableArray*)ArrayResistance
{
	int				nRetCode	= kSuccessCode;
	NSString		*strCommand, *strRange;
    NSMutableString	*strResult	= [[[NSMutableString alloc] initWithString:@""] autorelease];
	NSLog(@"Start readMeasureResistance");
	switch (nRange)
	{
		case kAutoRange:
			strRange	= @"AUTO";
			break;
		case k100ohm:
			strRange	= @"100";
			break;
		case k1Kohm:
			strRange	= @"1E3";
			break;
		case k10Kohm:
			strRange	= @"10E3";
			break;
		case k100Kohm:
			strRange	= @"100E3";
			break;
		case k1Mohm:
			strRange	= @"1E6";
			break;
		case k10Mohm:
			strRange	= @"10E6";
			break;
		case k100Mohm:
			strRange	= @"100E6";
			break;
		default:
			strRange	= @"AUTO";
			break;
	}	
	strCommand	= [NSString stringWithFormat:@"CONF:RES %@,MAX, (@%@)",strRange, aChannels];
	nRetCode	= [self sendGPIB_Command:strCommand];
	if (nRetCode == kSuccessCode) 
		nRetCode	= [self setMeasureCommand:aChannels
							  IntervalTime:fIntervalTime
								FetchCount:iFetchCount];
	if (nRetCode == kSuccessCode)
	{
		nRetCode	= [self getCommand_Result:strResult];
		if (nRetCode == kSuccessCode)
		{
            if ([ArrayResistance count]) 
                [ArrayResistance removeAllObjects];
            [ArrayResistance addObjectsFromArray:[strResult componentsSeparatedByString:@","]];
        }
	}
	NSLog(@"%d = readMeasureResistance(%@,%d,%f,%d,%@)",
		  nRetCode,aChannels,nRange,fIntervalTime,iFetchCount,strResult);
	return nRetCode;	
}

-(int)getMeasureAvgCurrent:(BOOL)bIsDC_CURR
					 Quick:(BOOL)bQuick
			  ChannelLists:(NSString*)aChannels
			  IntervalTime:(float)fIntervalTime
				FetchCount:(int)iFetchCount
				   Current:(NSMutableArray*)ArrayCurrent
{
	int				nRetCode	= kSuccessCode;
	NSString		*strCommand;
    NSMutableString	*strResult	= [[[NSMutableString alloc] initWithString:@""] autorelease];
	NSLog(@"Start getMeasureAvgCurrent => %d, Quick = %d",__LINE__,bQuick);
	if (bQuick)
		strCommand	= [NSString stringWithFormat:@"CONF:CURR MAX, (@%@)",aChannels];
	else
		strCommand	= [NSString stringWithFormat:@"CONF:CURR MAX,MIN, (@%@)",aChannels];
	nRetCode	= [self sendGPIB_Command:strCommand];
	if (nRetCode == kSuccessCode) 
		nRetCode	= [self setMeasureCommand:aChannels
							  IntervalTime:fIntervalTime
								FetchCount:iFetchCount];
	if (nRetCode == kSuccessCode)
	{
		nRetCode	= [self getCommand_Result:strResult];
		if (nRetCode == kSuccessCode)
		{
            if ([ArrayCurrent count])
                [ArrayCurrent removeAllObjects];
            [ArrayCurrent addObjectsFromArray:[strResult componentsSeparatedByString:@","]];
        }
	}
	NSLog(@"%d = getMeasureAvgCurrent(%@,%f,%d,%@)",
		  nRetCode,aChannels,fIntervalTime,iFetchCount,strResult);
	return nRetCode;
}

-(id)init
{
    self	= [super init];
    return self;
}

-(void)dealloc
{
	[super dealloc];
}

@end




