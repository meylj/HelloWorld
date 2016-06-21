//  IADevice_LightMeter.m
//  FunnyZone
//
//  Created by Cheng Ming on 2011/11/7.
//  Copyright 2011年 PEGATRON. All rights reserved.



#import "IADevice_LightMeter.h"



@implementation TestProgress (IADevice_LightMeter)

// 2011-12-9 desikan modify the function name 
// 2011-11-29 add by desikan
// read data from lightmeter
// Param:
//      NSMutableDictionary  *dictSettings   : Settings
//          MULTIPLE    -> int          : multiple for lightmeter
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
- (NSNumber *)Read_Data_From_LightMeter:(NSMutableDictionary *)dictSettings
						   Return_Value:(NSMutableString *)strReturnValue
{
    int	iValue		= -1;
    int	iMultiple	=[[dictSettings valueForKey:@"MULTIPLE"] intValue];
   
    NSMutableArray	*arrReadData	= [[NSMutableArray alloc] init];
    NSMutableString	*strSubString	= [[NSMutableString alloc] init];
    if(![[dictSettings valueForKey:KIADeviceKey_LEDRESULT]
		 isEqualTo:@""])
        [dictSettings setValue:@""
						forKey:KIADeviceKey_LEDRESULT];
    
    // 2011-12-9 desikan replace calling function from UART with READ_COMMAND 
    [self READ_COMMAND:dictSettings
		  RETURN_VALUE:strReturnValue];
    if ((nil==strReturnValue)
		|| ([strReturnValue isEqualToString:@""]))
    {
        ATSDebug(@"can't get the value from lightmeter");
        [strSubString release];
        [arrReadData release];
        return [NSNumber numberWithBool:NO];
    }
    else 
    {
        BOOL		bCycle	= YES;
        NSString	*szValue;
        [strSubString setString:[NSString stringWithFormat:
								 @"%@", strReturnValue]];
        ATSDebug(@"the value from lightmeter:%@", strReturnValue);
        //  LightMeter RX Value : 0015008??0\r0015008??0\r0015008??00342
        //  N48 new format : 0015008???0284\r0015008???0283\r0015008???0283
        NSString	*str1	= [NSString stringWithFormat:@"\r"];
        NSString	*str2	= [NSString stringWithFormat:@"???"];
        while (bCycle)
        {   
            NSRange	range1	=[strSubString rangeOfString:str1];
            if(NSNotFound != range1.location
			   && range1.length >0
			   && (range1.length+range1.location) <= [strSubString length])
            {
                szValue	= [strSubString substringToIndex:range1.location]; 
                [strSubString setString:[strSubString substringFromIndex:
										 range1.location + range1.length]];
                NSRange	range2	= [szValue rangeOfString:str2];
                if(NSNotFound != range2.location
				   && range2.length >0
				   && (range2.length+range2.location) <= [szValue length])
                {
                    szValue	= [szValue substringFromIndex:
							   range2.location + range2.length];
                    if(4 == [szValue length])
                        iValue	= [szValue intValue] * iMultiple;    
                    else
                        iValue	= 0;
                    [arrReadData addObject:[NSNumber numberWithInt:iValue]];
                }
                else
                    ATSDebug(@"NO the string ??? continue ");
            }
            else
                bCycle	= NO;
        }
        [dictSettings setValue:arrReadData
						forKey:KIADeviceKey_LEDRESULT];
        [strSubString release];
        [arrReadData release];
        return [NSNumber numberWithInt:YES];
    }
}

//2011-8-4 add by Gordon
// check lightmeter whether is connected OK
// Param:
//      NSDictionary    *dictSettings   : Settings
//          MULTIPLE    -> int          : multiple for lightmeter
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
- (NSNumber *)CHECK_LIGHTMETER_STATUS:(NSDictionary*)dictSettings
						 RETURN_VALUE:(NSMutableString*)strReturnValue
{
    NSNumber			*nRed			= 0;
    NSMutableString		*strReadData	= [[NSMutableString alloc] init];
    NSString			*szTarget		= @"LIGHTMETER";
    NSMutableDictionary	*dicOwnSettings	= [NSMutableDictionary dictionaryWithObjectsAndKeys:
										   szTarget,
										   @"TARGET",
										   [NSNumber numberWithDouble:1.1],
										   @"TIMEOUT",
										   [dictSettings valueForKey:@"MULTIPLE"],
										   @"MULTIPLE",
										   kFZ_MemKey_ForLTMeterCatch,
										   kFZ_Script_ReceiveCatch, nil];
    [self CLEAR_TARGET:dicOwnSettings];
    // write command to light meter ,check whether it's work normally.
    nRed	= [self Read_Data_From_LightMeter:dicOwnSettings
							  Return_Value:strReadData];
    if([nRed boolValue])
    {
        ATSDebug(@"LightMeter is OK Return value is :%@", strReadData);
        [strReadData release];
        return [NSNumber numberWithBool:YES];
    }
    else
    {
        ATSDebug(@"LightMeter is not OK");
        [strReadData release];
        return [NSNumber numberWithBool:NO];
    }
}


-(void)LightMeter_CollectDataThread:(NSDictionary *)dicThread
{
    BOOL				bReadOut		= NO;
    int					iReadCount		= 12; 
    double				dResult			= -1;
    NSAutoreleasePool	*pool			= [[NSAutoreleasePool alloc] init];
    NSMutableString		*szReadData		= [[NSMutableString alloc] initWithString:@""];
    NSMutableArray		*aryLedData		= [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray		*aryNewLedData	= [[[NSMutableArray alloc] init] autorelease];
    NSString			*szTarget		= @"LIGHTMETER";
    NSMutableDictionary	*dicLedValue	= [NSMutableDictionary dictionaryWithObjectsAndKeys:
										   szTarget,
										   @"TARGET",
										   [dicThread valueForKey:kFZ_Script_ReceiveTimeOut],
										   kFZ_Script_ReceiveTimeOut,
										   [dicThread valueForKey:@"MULTIPLE"],
										   @"MULTIPLE",
										   kFZ_MemKey_ForLTMeterCatch,
										   kFZ_Script_ReceiveCatch, nil] ;
    
    // read raw data count
    int iSampleCount = [[dicThread objectForKey:@"READCOUNT"]intValue]?[[dicThread objectForKey:@"READCOUNT"]intValue]:5;
    
    [self CLEAR_TARGET:dicLedValue];
    do
	{
        iReadCount--;
        [self Read_Data_From_LightMeter:dicLedValue
						   Return_Value:szReadData];
        if(nil != szReadData
		   && ![szReadData isEqualToString:@""])
        {
            if(![[dicLedValue valueForKey:KIADeviceKey_LEDRESULT]
				 isEqualTo:@""])
            { 
                [aryLedData setArray:[dicLedValue valueForKey:KIADeviceKey_LEDRESULT]];
                ATSDebug(@"LED Strobe Source Data : %@", aryLedData);
                if(0 != [aryLedData count])
                {
                    for (int i1=0 ; i1< [aryLedData count];i1++)
                        if (0 != [[aryLedData objectAtIndex:i1] intValue])
                            [aryNewLedData addObject:[aryLedData objectAtIndex:i1]];
                    if ([aryNewLedData count]>=iSampleCount)
                    {
                        // if value count >= iSampleCount (default is 5) the end the cycle
                        bReadOut	= YES;   
                        ATSDebug(@"LED Strobe Complete Data : %@", aryNewLedData);
                        // do taxis
                        NSArray	*ary	= [m_mathLibrary BringOrderToArray:aryNewLedData];
                        [aryNewLedData removeAllObjects];
                        // Remove the largest and smallest value
                        for(int i = 1;i < [ary count]-1;i++)
                            [aryNewLedData addObject:[ary objectAtIndex:i]];
                        ATSDebug(@"LED Strobe Complete Data(remove zero value and the largest and smallest value) : %@",
								 aryNewLedData);
                        // do average
                        dResult	= [m_mathLibrary GetAverageWithArray:aryNewLedData
															 NeedABS:NO];
                    } 
                    else
                        dResult	= 0;
                }
                else 
                    dResult	= 0; 
            }
        }
    } while (!bReadOut && (iReadCount > 0));
    if(dResult >0)
        ATSDebug(@"LED average value : %.2f", dResult);
    else if(dResult != 0 )
        ATSDebug(@"Can't get the lightmeter value");
    else
        ATSDebug(@"lightmeter value is 0 ,make sure the strobe is on");
    [m_dicMemoryValues setValue:[NSString stringWithFormat:@"%.2f", dResult]
						 forKey:KIADeviceKey_LEDRESULT];
    ATSDebug(@"LED average value : %.2f", dResult);
    [szReadData release];
    [m_TEST_LIGHTMETER_THREAD cancel];
    [pool drain];
}

//Start 2011.11.14 Add by Ming 
// Descripton:Start the Thread for Light Meter 
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)LIGHT_METER_BEGINREAD:(NSDictionary*)dicContents
					 RETURN_VALUE:(NSMutableString*)strReturnValue
{  
    m_TEST_LIGHTMETER_THREAD	= [[NSThread alloc] initWithTarget:self
													   selector:@selector(LightMeter_CollectDataThread:)
														 object:dicContents];
    [m_TEST_LIGHTMETER_THREAD setName:@"TEST_LIGHTMETER_THREAD"];
    [m_TEST_LIGHTMETER_THREAD start];
    [strReturnValue setString:@"PASS"];    
    return [NSNumber numberWithBool:YES];
}
//End 2011.11.14 Add by Ming

//Start 2011.11.14 Add by Ming 
// Descripton:Get the light meter's value
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)GET_LIGHT_METER_AVERAGE:(NSDictionary*)dicContents
					   RETURN_VALUE:(NSMutableString*)strReturnValue
{
    while(![m_TEST_LIGHTMETER_THREAD isCancelled])
        usleep(1000);        
    ATSDebug(@"TEST_LIGHTMETER Monitor is Finished "); 
    [m_TEST_LIGHTMETER_THREAD release];
    NSNumber	*fResult	= [m_dicMemoryValues valueForKey:KIADeviceKey_LEDRESULT];
    ATSDebug(@"LED average value is: %@", fResult);
    [strReturnValue setString:[NSString stringWithFormat:@"%@", fResult]];
    return [NSNumber numberWithBool:YES];
}
//End 2011.11.14 Add by Ming

// Start 2012.10.26 Add by Sky
// Description:Send the fixture command to catch the ray from the unit.
// Param:
//      NSDictionany    *dicContents    : Setting in script file
//      NSMutableString *strReturnValue : Return value

-(NSNumber*)START_LED_TEST:(NSDictionary *)dicContents
              RETURN_VALUE:(NSMutableString *)strReturnValue
{
    [m_dicMemoryValues setObject:[NSNumber numberWithBool:YES]
						  forKey:@"LED_Thread_On"];
    [m_dicMemoryValues setObject:@"NO"
                          forKey:@"LED_Thread_Status"];
    [NSThread detachNewThreadSelector:@selector(SendFixtureCommand:)
							 toTarget:self
						   withObject:dicContents];
    [strReturnValue setString:@"PASS"];
    return [NSNumber numberWithBool:YES];
}

-(NSNumber*)CHECK_LED_ON:(NSDictionary *)dicContents
            RETURN_VALUE:(NSMutableString *)strReturnValue
{
    double		dCheckTime      = [[dicContents objectForKey:@"CHECKTIME"] doubleValue];
    NSDate		*dateStart		= [NSDate date];
    double		dSpendtime		= 0;
    do
	{
        @synchronized(m_dicMemoryValues)
        {
            dSpendtime	= [[NSDate date] timeIntervalSinceDate:dateStart];
            if ([[m_dicMemoryValues objectForKey:@"LED_Thread_Status"] isEqualToString:@"YES"])
            {
                NSLog(@"Congratulations! The fixture can catch the ray from unit!");
                return [NSNumber numberWithBool:YES];
            }
            usleep(10000);
        }
    }while(dSpendtime < dCheckTime);
    NSLog(@"Sorry, the fixture cannot catch the ray from unit!");
    return [NSNumber numberWithBool:NO];
}

-(NSNumber*)END_LED_TEST:(NSDictionary *)dicContents
            RETURN_VALUE:(NSMutableString *)strReturnValue
{
    @synchronized(m_dicMemoryValues)
    {
        [m_dicMemoryValues setObject:[NSNumber numberWithBool:NO]
							  forKey:@"LED_Thread_On"];
    }
    return [NSNumber numberWithBool:YES];
}

- (void)SendFixtureCommand:(id)idThread
{
    NSAutoreleasePool	*pool		= [[NSAutoreleasePool alloc] init];
    NSLog(@"Start LED_Test Monitor.");
    NSMutableString	*strReadData	= [[NSMutableString alloc] initWithString:@""];
    NSDictionary	*dicSendCommand	= [idThread valueForKey:@"SEND_COMMAND"];
    NSDictionary	*dicReadCommand	= [idThread valueForKey:@"READ_COMMAND"];
    NSNumber        *nRet;//           = [NSNumber numberWithBool:NO];
    while ([[m_dicMemoryValues objectForKey:@"LED_Thread_On"]
            isEqualToNumber:[NSNumber numberWithBool:YES]])
    {
        @synchronized(m_dicMemoryValues)
        {
            [self SEND_COMMAND:dicSendCommand];
            [strReadData setString:@""];
            nRet    = [self READ_COMMAND:dicReadCommand
                            RETURN_VALUE:strReadData];
            if ([nRet boolValue])
            {
                [m_dicMemoryValues setObject:@"YES"
                                      forKey:@"LED_Thread_Status"];
                NSLog(@"Fixture has catched the ray from unit, the return value is [%@]", strReadData);
                break;
            }
        }
    }
    [strReadData release];
    NSLog(@"End LED_Test Monitor.");
    [pool drain];
}

//End 2012.10.26 Add by Sky
@end




