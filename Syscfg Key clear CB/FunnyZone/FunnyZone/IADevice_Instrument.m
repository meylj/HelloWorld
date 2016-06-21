//  IADevice_Instrument.m
//  FunnyZone
//
//  Created by Eagle on 12/13/11.
//  Copyright 2011 PEGATRON. All rights reserved.



#import "IADevice_Instrument.h"
#import "InstrumentLibrary/Device_34401A.h"
#import "InstrumentLibrary/Device_53131.h"
#import "InstrumentLibrary/Device_34970.h"
#import "InstrumentLibrary/PPS_Device.h"



@implementation TestProgress (IADevice_Instrument)

/* Kyle 2012.02.21
 * abstract : Init a GPIB with boardid,primaryAddress
 * key      :
 *              InstantType ==> 0  34401A
 *                              1  53131
 *                              2  34970
 *                              3  PPS */
- (BOOL)Init_Instrument:(int)InstantType
		   BoardIDCount:(int)iBoardIDCount
		 PrimaryAddress:(int)iPrimaryAddress
			 Instrument:(InstrumentBase **)instrumentBase
{
    int				iGPIBRet	= -1;
    Device_34401A	*device_34401A;
    Device_53131	*device_53131;
    Device_34970	*device_34970;
    PPS_Device		*device_PPS;
    
    
    switch (InstantType)
	{
        case kIADevice_InstantType_34401A:
            device_34401A	= [[[Device_34401A alloc] init] autorelease];
            for (int i = 0; i < iBoardIDCount; i++) 
            {
                iGPIBRet	= [device_34401A setInitialDevice:i PrimaryAddr:iPrimaryAddress];
                if (TEST_SUCCESS == iGPIBRet) 
                    break;
            }
            if (TEST_SUCCESS == iGPIBRet)
                *instrumentBase	= device_34401A;
            break;
        case kIADevice_InstantType_53131:
            device_53131	= [[[Device_53131 alloc] init] autorelease];
            for (int i = 0; i < iBoardIDCount; i++) 
            {
                iGPIBRet	= [device_53131 setInitialDevice:i
											  PrimaryAddr:iPrimaryAddress];
                if (TEST_SUCCESS == iGPIBRet) 
                    break;
            }
            if (TEST_SUCCESS == iGPIBRet)
                *instrumentBase	= device_53131;
            break;
        case kIADevice_InstantType_34970:
            device_34970	= [[[Device_34970 alloc] init] autorelease];
            for (int i = 0; i < iBoardIDCount; i++) 
            {
                iGPIBRet	= [device_34970 setInitialDevice:i
											  PrimaryAddr:iPrimaryAddress];
                if (TEST_SUCCESS == iGPIBRet) 
                    break;
            }
            if (TEST_SUCCESS == iGPIBRet)
                *instrumentBase	= device_34970;
            break;
        case kIADevice_InstantType_PPS:
            device_PPS	= [[[PPS_Device alloc] init] autorelease];
            for (int i = 0; i < iBoardIDCount; i++) 
            {
                iGPIBRet	= [device_PPS setInitialDevice:i
											PrimaryAddr:iPrimaryAddress];
                if (TEST_SUCCESS == iGPIBRet) 
                    break;
            }
            if (TEST_SUCCESS == iGPIBRet)
                *instrumentBase	= device_PPS;
            break;
            
        default:
            break;
    }
    
    return (TEST_SUCCESS == iGPIBRet);
}

- (BOOL)Instrument_Send_Command:(InstrumentBase *)instrumentBase
					SendCommand:(NSString *)szCommand
{
    int	iGPIBRet	= TEST_FAIL;
    iGPIBRet	= [instrumentBase sendGPIB_Command:szCommand];
    return (TEST_SUCCESS == iGPIBRet);
}

- (BOOL)Instrument_Receive_Command:(InstrumentBase *)instrumentBase
					  ReceiveValue:(NSMutableString *)szReceiveValue
{
    int	iGPIBRet	= TEST_FAIL;
    iGPIBRet	= [instrumentBase getCommand_Result:szReceiveValue];
    return (TEST_SUCCESS == iGPIBRet);
}

/* Kyle 2012.02.21
 * method   : Init_Instrument:RETURN_VALUE:
 * abstract : Init a GPIB and memory
 * key      :
 *              INSTRUMENTTYPE ==> init GPIB type
 *              BOARDIDCOUNT   ==> how many cards will be used
 *              PRIMARYADDRESS ==> init GPIB address
 *              INSTRUMENTNAME ==> GPIB memory key */
- (NSNumber *)Init_Instrument:(NSDictionary *)dictSetting
				 RETURN_VALUE:(NSMutableString *)szReturnValue
{
    int			iBoardCount			= [[dictSetting valueForKey:@"BOARDIDCOUNT"]
									   intValue];
    int			iPrimaryAddress		= [[dictSetting valueForKey:@"PRIMARYADDRESS"]
									   intValue];
    int			iInstrumentType		= [[dictSetting valueForKey:@"INSTRUMENTTYPE"]
									   intValue];
    NSString	*szInstrumentName	= [dictSetting valueForKey:@"INSTRUMENTNAME"];
    InstrumentBase	*instrumentBase;
    
    if ([self Init_Instrument:iInstrumentType
				 BoardIDCount:iBoardCount
			   PrimaryAddress:iPrimaryAddress
				   Instrument:&instrumentBase])
    {
        [m_dicMemoryValues setObject:instrumentBase
							  forKey:szInstrumentName];
        return [NSNumber numberWithBool:YES];
    }
    
    return [NSNumber numberWithBool:NO];
}

/*
 2013.01.15
 Release the device
 */
- (NSNumber*)RELEASEDEVICE:(NSDictionary *)dictSetting
              RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSString
    *szInstrumentName  = [dictSetting valueForKey:@"INSTRUMENTNAME"];
    if (![[m_dicMemoryValues objectForKey:szInstrumentName]
          isKindOfClass:[InstrumentBase class]])
    {
        ATSDebug(@"Type error !");
        return [NSNumber numberWithBool:NO];
    }
    InstrumentBase
    *instrumentBase  = [m_dicMemoryValues objectForKey:szInstrumentName];
    [instrumentBase
     releaseDevice];
    return [NSNumber numberWithBool:YES];
}

/*
 * Kyle 2012.02.21
 * method   : Instrument_Send_Command:RETURN_VALUE:
 * abstract : get a GPIB and send command
 * key      :
 *              GPIBCOMMAND    ==> will be send command
 *              INSTRUMENTNAME ==> the key of GPIB
 *
 */
- (NSNumber *)Instrument_Send_Command:(NSDictionary *)dictSetting
						 RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSString	*szInstrumentName	= [dictSetting valueForKey:@"INSTRUMENTNAME"];
    NSString	*szCommand			= [dictSetting valueForKey:@"GPIBCOMMAND"];
    if (![[m_dicMemoryValues objectForKey:szInstrumentName]
		  isKindOfClass:[InstrumentBase class]])
    {
        ATSDebug(@"Type error !");
        return [NSNumber numberWithBool:NO];
    }
    
    InstrumentBase	*instrumentBase	= [m_dicMemoryValues objectForKey:szInstrumentName];
    BOOL			bGPIBRet		= [self Instrument_Send_Command:instrumentBase
										 SendCommand:szCommand];
    if (!bGPIBRet) 
        ATSDebug(@"Send Command error !");
    return [NSNumber numberWithBool:bGPIBRet];
}

/* Kyle 2012.02.21
 * method   : Instrument_Receive_Command:RETURN_VALUE:
 * abstract : get a GPIB and receive command
 * key      :
 *              INSTRUMENTNAME ==> the key of GPIB */
- (NSNumber *)Instrument_Receive_Command:(NSDictionary *)dictSetting
							RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSMutableString	*szValue		= [[[NSMutableString alloc]
										initWithString:@""] autorelease];
    NSString	*szInstrumentName	= [dictSetting valueForKey:@"INSTRUMENTNAME"];
    if (![[m_dicMemoryValues objectForKey:szInstrumentName]
		  isKindOfClass:[InstrumentBase class]])
    {
        ATSDebug(@"Type error !");
        return [NSNumber numberWithBool:NO];
    }
   
    InstrumentBase	*instrumentBase	= [m_dicMemoryValues objectForKey:szInstrumentName];
    if ([self Instrument_Receive_Command:instrumentBase
							ReceiveValue:szValue])
    {
        [szReturnValue setString:szValue];
        return [NSNumber numberWithBool:YES];
    }
    else
    {
        ATSDebug(@"Receive Command error !");
        return [NSNumber numberWithBool:NO];
    }
}

/*
 * Kyle 2012.02.22
 * method   : SendCommandTimesForAVG:RETURN_VALUE:
 * abstract : send command ? times ,get the values and get AVG
 *
 */
- (NSNumber *)SendCommandTimesForAVG:(NSDictionary *)dictSetting
						RETURN_VALUE:(NSMutableString *)szReturnValue
{
    int			iTimes				= [[dictSetting valueForKey:@"TIMES"]
									   intValue];
    NSString	*szInstrumentName	= [dictSetting valueForKey:@"INSTRUMENTNAME"];
    NSString	*szCommand			= [dictSetting valueForKey:@"GPIBCOMMAND"];
    NSMutableString	*szValue		= [[[NSMutableString alloc]
										initWithString:@""] autorelease];
    NSMutableArray	*array			= [NSMutableArray arrayWithArray:nil];
    
    for (int i = 0; i < iTimes; i++) 
    {
        if (![[m_dicMemoryValues objectForKey:szInstrumentName]
			  isKindOfClass:[InstrumentBase class]])
        {
            ATSDebug(@"Type error !");
            return [NSNumber numberWithBool:NO];
        }
        
        InstrumentBase	*instrumentBase	= [m_dicMemoryValues objectForKey:szInstrumentName];
        BOOL			bGPIBRet		= [self Instrument_Send_Command:instrumentBase
											 SendCommand:szCommand];
        if (!bGPIBRet) 
        {
            ATSDebug(@"Send Command error !");
            return [NSNumber numberWithBool:NO];
        }
        [self Instrument_Receive_Command:instrumentBase
							ReceiveValue:szValue];
        [array addObject:szValue];
    }
    
    [szReturnValue setString:[NSString stringWithFormat:
							  @"%f",
							  [m_mathLibrary GetAverageWithArray:array
														 NeedABS:NO]]];
    return [NSNumber numberWithBool:YES];
}

- (NSNumber *)RECEIVE_DATA:(NSDictionary *)dicData
			  RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSDictionary	*dicSetting	= [NSDictionary dictionaryWithContentsOfFile:
								   [NSString stringWithFormat:
									@"%@/Library/Preferences/Muifa.plist",
									NSHomeDirectory()]];
    NSString	*szMuifaName	= [[dicSetting objectForKey:@"ScriptInfo"]
								   objectForKey:@"CableLossFile"];
    NSString	*szPath			= [NSString stringWithFormat:
								   @"%@/Library/Preferences/%@",
								   NSHomeDirectory(), szMuifaName];
    NSDictionary	*dicOffset	= [[NSDictionary dictionaryWithContentsOfFile:szPath]
								   objectForKey:@"LOSS"];
    NSString		*szKey		= [dicData objectForKey:kFZ_Script_MemoryKey];
    
    //count the result
    float	fOffset	= [[dicOffset objectForKey:szKey] floatValue];
    float	fTestValue ;
    NSScanner	*scaner	= [NSScanner scannerWithString:szReturnValue];
    if(!([scaner scanFloat:&fTestValue]
		 && [scaner isAtEnd]))
    {
        ATSDebug(@"The result is not all the Number");
        return [NSNumber numberWithBool:NO];
    }
    [szReturnValue setString:
	 [NSString stringWithFormat:
	  @"%.*f",
	  [[dicData objectForKey:@"LENGTH"] intValue], (fTestValue - fOffset)]];
    ATSDebug(@"%@",szReturnValue);
    
    return [NSNumber numberWithBool:YES];
}

- (NSNumber *)COUNT_DATA_LOSS:(NSDictionary*)dictData
				 RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSDictionary	*dicSetting	= [NSDictionary dictionaryWithContentsOfFile:
								   [NSString stringWithFormat:
									@"%@/Library/Preferences/Muifa.plist",
									NSHomeDirectory()]];
    
    NSString	*szMuifaName	= [[dicSetting objectForKey:@"ScriptInfo"]
								   objectForKey:@"CableLossFile"];
    NSString	*szPath			= [NSString stringWithFormat:
								   @"%@/Library/Preferences/%@",
								   NSHomeDirectory(), szMuifaName];
    
    NSMutableDictionary	*dicMuifaGrounding	= [[NSMutableDictionary alloc]
											   initWithContentsOfFile:szPath];
    NSDictionary		*dicGolden			= [dicMuifaGrounding objectForKey:@"GOLDEN"];
    
    NSString			*szKey				= [dictData objectForKey:kFZ_Script_MemoryKey];
    
    //count the cable loss
    float	fTestValue ;
    float	fGoldenValue	= [[dicGolden objectForKey:szKey] floatValue];
    NSScanner	*scaner		= [NSScanner scannerWithString:szReturnValue];
    if(!([scaner scanFloat:&fTestValue] && [scaner isAtEnd]))
    {
        [dicMuifaGrounding release];
        return [NSNumber numberWithBool:NO];
    }
    NSString	*szLossValue	= [NSString stringWithFormat:
								   @"%.*f",
								   [[dictData objectForKey:@"LENGTH"] intValue],
								   (fTestValue - fGoldenValue)];
    
    [szReturnValue setString:szLossValue];
    ATSDebug(@"%@",szLossValue);
    
    NSMutableDictionary	*dicLoss	= [[NSMutableDictionary alloc] init];
    [dicLoss setDictionary:[dicMuifaGrounding objectForKey:@"LOSS"]];
    [dicLoss setObject:szLossValue
				forKey:szKey];
    [dicMuifaGrounding setObject:dicLoss
						  forKey:@"LOSS"];
    
    NSFileManager	*fileManager	= [NSFileManager defaultManager];
    NSDictionary	*dicAttributes	= [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:511]
															  forKey:NSFilePosixPermissions];
    [fileManager setAttributes:dicAttributes
				  ofItemAtPath:szPath
						 error:nil];
    [dicMuifaGrounding writeToFile:szPath
						atomically:NO];
    [dicLoss release];
    [dicMuifaGrounding release];
    
    return [NSNumber numberWithBool:YES];
}

- (NSNumber *)ADD_CABLE_LOSS_TO_CSV:(NSDictionary *)dictData
					   RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSDictionary	*dicSetting	= [NSDictionary dictionaryWithContentsOfFile:
								   [NSString stringWithFormat:
									@"%@/Library/Preferences/Muifa.plist",
									NSHomeDirectory()]];
    NSString	*szMuifaName	= [[dicSetting objectForKey:@"ScriptInfo"]
								   objectForKey:@"CableLossFile"];
    NSString	*szPath			= [NSString stringWithFormat:
								   @"%@/Library/Preferences/%@",
								   NSHomeDirectory(), szMuifaName];
    
    NSDictionary	*dicMuifaGrounding	= [NSDictionary dictionaryWithContentsOfFile:szPath];
    NSDictionary	*dicLoss			= [dicMuifaGrounding objectForKey:@"LOSS"];
    NSString		*szKey				= [dictData objectForKey:kFZ_Script_MemoryKey];
    [szReturnValue setString:[dicLoss objectForKey:szKey]];    
    return [NSNumber numberWithBool:YES];
}

@end




