//  IADevice_Other.m
//  Izual_Lu
//
//  Created by Lu Izual on 11-5-5.
//  Copyright 2011年 PEGATRON. All rights reserved.



#import "IADevice_Other.h"
#import "IADevice_TestingCommands.h"
#import "IADevice_SFIS.h"
#import "IADevice_Compass.h"
#import "publicDefine.h"
#import "NSStringCategory.h"


#define kOther_OSModeTool_Location          @"LOCATION"
#define kOther_OSModeTool_TimeOut           @"TIMEOUT"
#define kOther_OSModeTool_DefaultTimeOut    5
#define kOther_OSModeTool_StringEncoding    NSUTF8StringEncoding
#define kHallEffect_CaluteDistance_Value    (10000/(4.959702-(-0.358978)))

NSString* const	TiltFixtureNotificationToUI	= @"TiltFixtureNotificationToUI";
NSString* const	TiltFixtureNotificationToFZ	= @"TiltFixtureNotificationToFZ";



const NSString* const	kNoteStartCSDStationChoice	= @"kNoteStartCSDStationChoice";



@implementation TestProgress (IADevice_Other)

// Get data from mobile in OS mode
// Param:
//      NSDictionary    *dictSettings       : Settings
//          LOCATION    -> NSString*    : Coco tool bundle path
//          TIMEOUT     -> NSNumber*    : Read time out
//      NSMutableString    *strReturnValue    : Return value
-(NSNumber*)GetDataFromOSMode:(NSDictionary*)dictSettings 
                  ReturnValue:(NSMutableString*)strReturnValue
{
    // Basic judge
    if((![dictSettings isKindOfClass:[NSDictionary class]])
       || (![[dictSettings objectForKey:kOther_OSModeTool_Location] 
			 isKindOfClass:[NSString class]])
       || ((nil != [dictSettings objectForKey:kOther_OSModeTool_TimeOut])
		   && (![[dictSettings objectForKey:kOther_OSModeTool_TimeOut] 
				 isKindOfClass:[NSNumber class]]))
       || (![strReturnValue isKindOfClass:[NSString class]]))
        return [NSNumber numberWithBool:NO];
    
    // Get coco tool
    NSString		*strToolPath	= [dictSettings objectForKey:
									   kOther_OSModeTool_Location];
    [self TransformKeyToValue:strToolPath
				  returnValue:&strToolPath];
    NSFileManager	*filemanager	= [NSFileManager defaultManager];
    if(![filemanager fileExistsAtPath:strToolPath])
        return [NSNumber numberWithBool:NO];
    
    // Pipe it
    NSTask	*taskTool	= [[NSTask alloc] init];
    NSPipe	*pipeTool	= [NSPipe pipe];
    NSFileHandle	*hToolOut;
    [taskTool setStandardOutput:pipeTool];
    [taskTool setLaunchPath:strToolPath];
    hToolOut	= [pipeTool fileHandleForReading];
    
    // Get data
    [taskTool launch];
    if(nil == [dictSettings objectForKey:kOther_OSModeTool_TimeOut])
        sleep(kOther_OSModeTool_DefaultTimeOut);
    else
        sleep([[dictSettings objectForKey:kOther_OSModeTool_TimeOut]
			   unsignedIntValue]);
    [taskTool suspend];
    [taskTool terminate];
    [taskTool release];
    NSData		*dataToolOut	= [hToolOut availableData];
    NSString	*strToolOut		= [[NSString alloc] initWithData:dataToolOut 
												  encoding:kOther_OSModeTool_StringEncoding];
    // End
    [strToolOut release];
    return [NSNumber numberWithBool:YES];
}

//2011-8-4 add by Gordon
// Calculate temperature of thermistor component
// Param:
//      NSDictionary    *dictSettings   : Settings
//          VALUE       -> NSString*    : {NTC,TEMP}
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
- (NSNumber *)CALCULATE_TEMPERATURE_FOR_THERMISTOR:(NSDictionary *)dictSettings
									  RETURN_VALUE:(NSMutableString*)strReturnValue
{
	BOOL	bRet	= YES;
	for(int i = 0; i < [strReturnValue length]; i ++ )
	{
		if(isdigit([strReturnValue characterAtIndex:i])
		   || '.'==[strReturnValue characterAtIndex:i])
			;
		else
		{
			bRet	= NO;;
			break;
		}
	}
	if(bRet)
	{
		double	dValue	= [strReturnValue doubleValue];
		double B = 3435;
//		if([[dictSettings valueForKey:@"VALUE"] isEqualToString:@"NTC"])
//			B = 3435.0;
//		else if([[dictSettings valueForKey:@"VALUE"] isEqualToString:@"TEMP"])
//			B = 3380.0;
//		else
//			return NO;
		double R0 = 4096;
		double T0 = 298.15;
//		double V =(dValue/4095)*2.5;
//		double R = 10;
		double RRatio = log(dValue*5/R0);
		double	t	= (RRatio/B)+(1.0/T0);
		double	T	= (1 / t) - 273.15;
        [strReturnValue setString:[NSString stringWithFormat:@"%0.3f", T]];
	}
	return [NSNumber numberWithBool:bRet];
}

//2011-8-4 add by Gordon
// Transform value from hex to dec
// Param:
//      NSDictionary    *dictSettings   : Settings
//          Mode        -> NSString*    : {RECEIVE,FIXTURE,D_FIXTURE,BATQMAX}
//          CHANNEL     -> NSString*    : save data to key named by channel
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
- (NSNumber *)TRANSFORM_FOR_HEX_TO_DEC:(NSDictionary*)dictSettings
						  RETURN_VALUE:(NSMutableString*)strReturnValue
{
	NSString	*szMode		= [dictSettings valueForKey:@"Mode"];
	NSString	*szChannel	= [dictSettings valueForKey:@"CHANNEL"];
	NSScanner	*scaner;
	if([szMode isEqualToString:@"RECEIVE"])
		scaner	= [NSScanner scannerWithString:strReturnValue];
	else if([szMode isEqualToString:@"FIXTURE"])
	{
		if([strReturnValue length] >= 2)
		{
			if([strReturnValue characterAtIndex:0] == '0')
                [strReturnValue setString:[NSString stringWithFormat:
										   @"%d", [strReturnValue characterAtIndex:1]]];
			else
                [strReturnValue setString:[NSString stringWithFormat:
										   @"%d",
										   ([strReturnValue characterAtIndex:0]
											* 256
											+ [strReturnValue characterAtIndex:1])]];
			if(szChannel)
			{
				[m_dicMemoryValues setValue:[NSString stringWithString:strReturnValue]
									 forKey:szChannel];
                ATSDebug(@"Add value:%@ named:%@", strReturnValue, szChannel);
			}
			return [NSNumber numberWithBool:YES];
		}
		else
			return [NSNumber numberWithBool:NO];
	}
	else if([szMode isEqualToString:@"D_FIXTURE"])
	{
		if([strReturnValue length])
		{
			if(szChannel)
			{
				[m_dicMemoryValues setValue:[NSString stringWithString:strReturnValue]
									 forKey:szChannel];
                ATSDebug(@"Add value:%@ named:%@", strReturnValue, szChannel);
			}
			return [NSNumber numberWithBool:YES];
		}
		else
		{
			if(szChannel)
			{
                [strReturnValue setString:@"0"];
                ATSDebug(@"szReturnValue length < 2");
				[m_dicMemoryValues setValue:[NSString stringWithString:strReturnValue]
									 forKey:szChannel];
                ATSDebug(@"Add value:%@ named:%@", strReturnValue, szChannel);
			}
			return [NSNumber numberWithBool:NO];
		}
	}
	else if([szMode isEqualToString:@"BATQMAX"])
	{
		NSString *szTmp = strReturnValue;
		szTmp = [szTmp stringByReplacingOccurrencesOfString:@" 0x"
												 withString:@""];
		NSScanner *scan = [NSScanner scannerWithString:szTmp];
		unsigned int uiValue;
		if([scan scanHexInt:&uiValue])
		{
            [strReturnValue setString:[NSString stringWithFormat:@"%d", uiValue]];
			return [NSNumber numberWithBool:YES];
		}
		else
			return [NSNumber numberWithBool:NO];		
	}
	else
		return [NSNumber numberWithBool:NO];
	unsigned int	iValue;
	bool			bStatus	= [scaner scanHexInt:&iValue];
	if(bStatus)
        [strReturnValue setString:[NSString stringWithFormat:@"%d", iValue]];
	return [NSNumber numberWithBool:bStatus];
}

//2011-8-4 add by Gordon
// Through get ClrC from Unit to judge whether the unit is white or black
// Param:
//      NSDictionary    *dictSettings   : Settings
//          NO settings in  this function
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
-(NSNumber *)GET_DUT_COLOR:(NSDictionary*)dictSettings
			  RETURN_VALUE:(NSMutableString *)strReturnValue
{
	NSRange	range	= [strReturnValue rangeOfString:@"0x"];
	if(range.location != NSNotFound 
       && range.length >0 
       && (range.length + range.location) <= [strReturnValue length])
	{
        [strReturnValue setString:[strReturnValue substringFromIndex:(range.location
																	  + range.length)]];
		range	= [strReturnValue rangeOfString:@" "];
		if(range.location != NSNotFound 
           && range.length>0 
           && (range.location +range.length) <= [strReturnValue length])
		{
            [strReturnValue setString:[strReturnValue substringToIndex:range.location]];
			NSInteger	iValue	= [strReturnValue intValue];
			if(iValue == 0)
			{
                // if the ClrC get from unit is 0x00000000 0x00000000 0x00000000 0x00000000, we set black spec
                [m_strSpecName setString:kFZ_Script_JudgeCommonBlack];
                [m_dicMemoryValues setObject:[NSString stringWithFormat:KIADeviceDUT_BLACKCOLOR]
									  forKey:KIADeviceDUT_COLOR];
			}
			else if(iValue == 1)
			{
                // if the ClrC get from unit is 0x00000001 0x00000000 0x00000000 0x00000000, we set white spec
                [m_strSpecName setString:kFZ_Script_JudgeCommonWhite];
                [m_dicMemoryValues setObject:[NSString stringWithFormat:KIADeviceDUT_WHITECOLOR]
									  forKey:KIADeviceDUT_COLOR];
			}
			else
				return [NSNumber numberWithBool:NO];
			return [NSNumber numberWithBool:YES];
		}
	}
	return [NSNumber numberWithBool:NO];
}

// add note by betty 2012.4.17
// check the file of current root 
// Param:
//      NSDictionary    nil
//      NSMutableString *strReturnValue : Return value
// Return:
//      if the file path read from unit is equal to the file from setting file.return YES
//      Otherwise return NO!
- (NSNumber *)CURRENT_ROOT_CHECK:(NSDictionary *)dicSubSetting
					RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSDictionary	*dicTemp	= [kFZ_UserDefaults valueForKey:@"CurrentRoot"];
	NSArray		*arrReturnValue	= [szReturnValue componentsSeparatedByString:
								   @"nandfs:\\AppleInternal\\Diags\\Scripts\\N94\\FATP\\Current\\"];
	if ([arrReturnValue count] != 30) 
	{
		[szReturnValue setString:[NSString stringWithFormat:@"Root count error"]];
		return [NSNumber numberWithBool:NO];
	}
	for (int i=1; i < [arrReturnValue count]; i++)
	{
		NSArray	*arrRoot	= [[arrReturnValue objectAtIndex:i]
							   componentsSeparatedByString:@": "];
		if ([arrRoot count] >= 2)
		{			
			NSString	*szRoot	= [dicTemp valueForKey:[arrRoot objectAtIndex:0]];
			NSLog(@"Root:%@", [arrRoot objectAtIndex:0]);
			NSLog(@"SettingFile:%@", szRoot);
			NSLog(@"Unit:%@", [arrRoot objectAtIndex:1]);
			if ([[arrRoot objectAtIndex:1] isEqualToString:szRoot])
				[szReturnValue setString:[NSString stringWithFormat:
										  @"%@Match", [arrRoot objectAtIndex:0]]];
			else
			{
				[szReturnValue setString:[NSString stringWithFormat:
										  @"%@UnMatch,Setting:%@,Unit:%@",
										  [arrRoot objectAtIndex:0],
										  szRoot,
										  [arrRoot objectAtIndex:1]]];
				return [NSNumber numberWithBool:NO];
			}
		}
	}
	[szReturnValue setString:[NSString stringWithFormat:@"PASS"]];
	return [NSNumber numberWithBool:YES];
}

#pragma mark ############################ Tilt Fixture Monitor begin ##############################
- (NSNumber *)OPEN_FIXTURE
{
    NSNumber	*numRet	= [NSNumber numberWithBool:YES];
    if ([m_dicPorts objectForKey:kPD_Device_FIXTURE] != nil)
	{
        NSDictionary	*dicForFixture	= [NSDictionary dictionaryWithObject:kPD_Device_FIXTURE
																  forKey:kFZ_Script_DeviceTarget];
        numRet	= [self OPEN_TARGET:dicForFixture];
    }
    return numRet;
}

- (NSNumber *)CLOSE_FIXTURE
{
    NSNumber	*numRet	= [NSNumber numberWithBool:YES];
    if ([m_dicPorts objectForKey:kPD_Device_FIXTURE] != nil)
	{
        NSDictionary	*dicForFixture	= [NSDictionary dictionaryWithObject:kPD_Device_FIXTURE
																  forKey:kFZ_Script_DeviceTarget];
        NSMutableString	*szReturn		= [NSMutableString stringWithString:@""];
        numRet	= [self CLOSE_TARGET:dicForFixture
					   RETURN_VALUE:szReturn];
    }
    return numRet;
}

- (NSNumber *)CLEAR_FIXTURE
{
    NSNumber	*numRet	= [NSNumber numberWithBool:YES];
    if ([m_dicPorts objectForKey:kPD_Device_FIXTURE] != nil)
	{
        NSDictionary	*dicForFixture	= [NSDictionary dictionaryWithObject:kPD_Device_FIXTURE
																  forKey:kFZ_Script_DeviceTarget];
        numRet	= [self CLEAR_TARGET:dicForFixture];
    }
    return numRet;
}

//dicSubItems : monitor parameters
//      TIMEOUT : timeout
- (NSNumber *)MONITOR_FIXTURE:(NSDictionary *)dicSubItems
{
    NSNumber			*numRet	= [NSNumber numberWithBool:YES];
    NSNotificationCenter	*nc	= [NSNotificationCenter defaultCenter];
    [nc postNotificationName:TiltFixtureNotificationToUI
					  object:self
					userInfo:nil];
    if ([m_dicPorts objectForKey:kPD_Device_FIXTURE] != nil)
	{
        PEGA_ATS_UART	*uartObj	= [[m_dicPorts objectForKey:kPD_Device_FIXTURE]
									   objectAtIndex:kFZ_SerialInfo_UartObj];
        NSTimeInterval	timeOut		= [[dicSubItems objectForKey:
										kFZ_Script_ReceiveTimeOut] doubleValue];
        NSMutableString	*data		= [[NSMutableString alloc] init];
        NSInteger		iRet		= [uartObj Read_UartData:data
								  TerminateSymbol:[NSArray arrayWithObject:@"Vol Down"]
										MatchType:0
									 IntervalTime:kUart_IntervalTime
										  TimeOut:timeOut];
        [nc postNotificationName:TiltFixtureNotificationToFZ
						  object:self
						userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:
																	 @"%d", iRet]
															 forKey:@"PatnFixRet"]];
        if (kUart_SUCCESS != iRet)
            numRet	= [NSNumber numberWithBool:NO];
        [data release];      
    }
    else
        do
		{
            sleep(1);
            if (m_iPatnRFromFZ != kFZ_Pattern_NoMsg)
                break;
        }while (1);
    return numRet;
}

- (NSNumber *)MEASURE_RESULT
{
    if(m_bPatnRFromUI
	   && (m_iPatnRFromFZ == kFZ_Pattern_ReceiveVolDnMsg))
    {
        m_iPatnRFromFZ	= kFZ_Pattern_NoMsg;
        return [NSNumber numberWithBool:YES];
    }
    else
    {
        m_bPatnRFromUI	= YES;
        m_iPatnRFromFZ	= kFZ_Pattern_NoMsg;
        return [NSNumber numberWithBool:NO];
    }
}
#pragma mark ############################## Tilt Fixture Monitor end ##############################

- (NSNumber *)GET_CONFIG:(NSDictionary *)dicSubItems
			RETURN_VALUE:(NSMutableString *)szReturnValue
{
    return [NSNumber numberWithBool:YES];
}

//Start 2011.11.04 Add by Ming 
// Descripton:Get the Start Time
// Param:
//      NSDictionary    *dicContents	: Settings in script
//      NSMutableString *strReturnValue	: Return value
-(NSNumber*)GET_START_TIME:(NSDictionary*)dicContents
			  RETURN_VALUE:(NSMutableString*)strReturnValue;
{
    NSDate	*intervalTime	= [NSDate date];
    [m_dicMemoryValues setObject:intervalTime
						  forKey:[dicContents objectForKey:kFZ_Script_MemoryKey]];
    ATSDebug(@"Start Test Time: %@", intervalTime);
    return [NSNumber numberWithBool:YES];
}

//Start 2011.11.06 Add by Ming 
// Descripton:Change Test Case Name with Black/White
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)CHANGE_TESTCASENAME_WITH_COLOR:(NSDictionary*)dicContents
							  RETURN_VALUE:(NSMutableString*)strReturnValue
{
    NSString	*szCurrentTestItem;
    if([[m_dicMemoryValues valueForKey:KIADeviceDUT_COLOR]
		isEqualToString:KIADeviceDUT_BLACKCOLOR ])
		szCurrentTestItem	= [NSString stringWithFormat:
							   @"%@_Black",
							   [m_dicMemoryValues valueForKey:kFunnyZoneCurrentItemName]];
    else if([[m_dicMemoryValues valueForKey:KIADeviceDUT_COLOR]
			 isEqualToString:KIADeviceDUT_WHITECOLOR ])
    {
        szCurrentTestItem	= [NSString stringWithFormat:
							   @"%@_White",
							   [m_dicMemoryValues valueForKey:kFunnyZoneCurrentItemName]];
		[m_strSpecName setString:kFZ_Script_JudgeCommonWhite];
    }
    else 
        szCurrentTestItem	= [NSString stringWithFormat:
							   @"%@_Unknown",
							   [m_dicMemoryValues valueForKey:kFunnyZoneCurrentItemName]];
	[m_dicMemoryValues setObject:szCurrentTestItem
						  forKey:kFZ_UI_SHOWNNAME];
	[strReturnValue setString:@"PASS"];
    return [NSNumber numberWithBool:YES];
}

//add note by betty, 2012/4/17
// Change the Scientific notation to Normal notation 
// Param:
//      NSDictionary    *dicSubSetting   : Settings
//                 LENGTH --> NSString*  : the length after the decimal point you want to keep
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
// modified by desikan  combine with "ScientificToDouble:RETURN_VALUE:"
- (NSNumber *)ChangeScientificToNormal:(NSDictionary*)dicContents
						  RETURN_VALUE:(NSMutableString*)szNumber
{
    //start 2012,02,09 modified by yaya
    if ([szNumber isEqualToString:kFZ_99999_Value_Issue])
    {
        ATSDebug(@"-99999issue");
        return [NSNumber numberWithBool:NO];
    }
    double		dNumber;
    NSScanner	*scanerBuf	= [NSScanner scannerWithString:szNumber];
    if (![scanerBuf scanDouble:&dNumber])
    {
        [szNumber setString:kFZ_99999_Value_Issue];
        ATSDebug(@"Invalid String");
        return [NSNumber numberWithBool:NO];
    }
    if(nil == [dicContents valueForKey:@"LENGTH"]
	   || [[dicContents valueForKey:@"LENGTH"] isEqualTo:@""])
        [szNumber setString:[NSString stringWithFormat:@"%lf", dNumber]];
    else
    {
        int	iLength	= [[dicContents objectForKey:@"LENGTH"] intValue];
        [szNumber setString:[NSString stringWithFormat:@"%.*f", iLength, dNumber]];
    }
    //end 2012.2.9 modified by yaya.
    return [NSNumber numberWithBool:YES];
}

//add note by betty, 2012/4/17
// Change the value of m_bCancelFlag, 
// Param:
//      NSDictionary    *dicSubSetting   : Settings
//             FailCancel -> Boolean     : Set bool value of FailCancel, YES --> if fail, cancel some item
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
- (NSNumber *)CHANGE_CANCLE_FLAG:(NSDictionary *)dicPara
					RETURN_VALUE:(NSMutableString *)szReturnValue
{
    //cancel the items according as the szReturnValue
    NSString    *szCancel   = [dicPara objectForKey:@"CancelString"];
    NSString    *szNoCancel = [dicPara objectForKey:@"NoCancelString"];
    if (nil != szCancel && nil == szNoCancel)
    {
        if ([szReturnValue ContainString:szCancel])
        {
            m_bCancelFlag   = YES;
        }
        else
            m_bCancelFlag   = NO;
    }
    else if (nil == szCancel && nil != szNoCancel)
    {
        if ([szReturnValue ContainString:szNoCancel])
        {
            m_bCancelFlag   = NO;
        }
        else
            m_bCancelFlag   = YES;
    }
    else if (nil != szCancel && nil != szNoCancel)
    {
        if ([szReturnValue ContainString:szCancel] && ![szReturnValue ContainString:szNoCancel])
            m_bCancelFlag   = YES;
        else if (![szReturnValue ContainString:szCancel] && [szReturnValue ContainString:szNoCancel])
            m_bCancelFlag   = NO;
    }
    else
    {
        if (nil != [dicPara objectForKey:@"FailCancle"])
        {
            bool	bChangeFlag;
            if(nil ==[dicPara valueForKey:@"FailCancle"])
                bChangeFlag		= YES;
            else
                bChangeFlag		= [[dicPara valueForKey:@"FailCancle"] boolValue];
            if(bChangeFlag ^ m_bLastItemResult)
                m_bCancelFlag	= YES;
            else
                m_bCancelFlag	= NO;
        }        
    }
    
    return [NSNumber numberWithBool:YES];
}

- (NSNumber *)CHANGE_PRE_SUBITEM_RESULT:(NSDictionary *)dicPara
						   RETURN_VALUE:(NSMutableString *)szReturnValue
{
	m_bSubTest_PASS_FAIL = [[dicPara objectForKey:@"RESULT"] boolValue];
	ATSDebug(@"PRE SUB ITEM HAS CHANGED to [%@]",[dicPara objectForKey:@"RESULT"]);
	return [NSNumber numberWithBool:YES];
}

- (NSNumber *)RECORD_CURRENT_SBURESULT_WITHKEY:(NSDictionary   *)dicPara
                                  RETURN_VALUE:(NSMutableString *)szReturnValue
{
    [m_dicMemoryValues   setObject:m_bSubTest_PASS_FAIL ? @"PASS" : @"FAIL"
                            forKey:[dicPara objectForKey:kFZ_Script_MemoryKey]];
    return [NSNumber    numberWithBool:YES];
}

//add note by betty, 2012/4/17
// do round, keep the length you want to keep after the decimal point, default is 6
// Param:
//      NSDictionary    *dicSubSetting   : Settings
//              Digit  --> NSString *    : set the length after the decimal point you want to keep
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
- (NSNumber *)DO_ROUND:(NSDictionary *)dicPara
		  RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSString	*szNumber	= [NSString stringWithFormat:@"%@", szReturnValue];
    if ([kFZ_99999_Value_Issue isEqualToString:szNumber])
    {
        [szReturnValue setString:kFZ_99999_Value_Issue];
        ATSDebug(@"-99999issue");
        return [NSNumber numberWithBool:NO];
    }
    if(nil == szNumber
	   || [szNumber isEqualToString:@""])
    {
        ATSDebug(@"the return number is nil please check");
        return [NSNumber numberWithBool:NO];
    }
    NSString	*szIntegral;
    NSString	*szDecimal;
    bool		bNegative	= NO;
    int			iDigit;
    int			iDeLength;
    // default Digit is 6; 
    iDigit	= ([dicPara valueForKey:@"Digit"]
			   ? [[dicPara valueForKey:@"Digit"] intValue]
			   : 6);
    // judge the iDigit set the largetest value to 18
    if(iDigit >18)
    {
        ATSDebug(@"The Digit value is too large ,change it to 18");
        iDigit	= 18;
    }
    NSRange	range1	= [szNumber rangeOfString:@"-"];
    // judge the number  whether it is a negative
    if(NSNotFound != range1.location 
       && range1.length > 0 
       && (range1.location +range1.length) <=[szNumber length])
    {
        szNumber	= [szNumber substringFromIndex:range1.location+range1.length];
        bNegative	= YES;
    }
    else
        ATSDebug(@"The number is a positive number");
    NSRange	range2	= [szNumber rangeOfString:@"."];
    if(NSNotFound != range2.location 
       && range2.length > 0 
       && (range2.location +range2.length) <= [szNumber length])
    {	// get the Integral and Decimal of the number
		szIntegral	= [szNumber substringToIndex:range2.location];
        szDecimal	= [szNumber substringFromIndex:range2.location + range2.length];
        ATSDebug(@" the Integral is %@    ; and the Decimal is %@   ",
				 szIntegral, szDecimal);
        iDeLength	= [szDecimal length];
        if(iDeLength <= iDigit)
        {   // if the length of decimal is little than the Digit we want , complementarity 0
            for (int i=0; i<iDigit-iDeLength; i++) 
                szNumber	= [NSString stringWithFormat:@"%@0", szNumber];
            ATSDebug(@"the length of decimal is little than the Digit we want ,so just do complementarity 0");
        }
        else
        {	// do round(四舍五入)
            // get the Digit we wanted in Decimal
            NSString	*szDigit		= [szDecimal substringToIndex:iDigit];
            long long	lDigit			= [szDigit longLongValue];
            ATSDebug(@"Digit we want is %@", szDigit);
            NSString	*szRemainder	= [szDecimal substringFromIndex:iDigit];
            double		dRemainder		= [[NSString stringWithFormat:
											@"0.%@", szRemainder] doubleValue];
            ATSDebug(@"The Remainder is %@", szRemainder);
			// if the remainder is more than 0.5 abnegate it and carry 1
            if(dRemainder >= 0.5)
                lDigit	= lDigit + 1;
			// else abnegate without carry 1
            szDecimal	= [NSString stringWithFormat:@"%qi", lDigit];
			// if the number is like 3.0032, the Decimal will be 32 so we need to complementarity 0 
            if([szDecimal length] < [szDigit length])
                for (; [szDecimal length] < iDigit; ) 
                    szDecimal	= [NSString stringWithFormat:@"0%@", szDecimal];
			// if the number is like 32.999999 than maybe it will carry 1 to integral
            else if([szDecimal length] >[szDigit length])
            {
                szDecimal	= [NSString stringWithFormat:@"%@", szDigit];
                ATSDebug(@"now the decimal is %@", szDecimal);
            }
            szNumber	= [NSString stringWithFormat:@"%@.%@", szIntegral, szDecimal];
        }
    }
    if(bNegative)
        [szReturnValue setString:[NSString stringWithFormat:@"-%@", szNumber]];
    else
        [szReturnValue setString:[NSString stringWithFormat:@"%@", szNumber]];
    ATSDebug(@"the last result is %@", szReturnValue);
    return [NSNumber numberWithBool:YES];
}

//add note by betty, 2012/4/17
// get region_code and MPN by 3 ways, 1.get SN from script 2.get SN from SFIS  3.get SN from UI
// Param:
//      NSDictionary    *dictSettings   : Settings
//               TypeFlag -> NSNumber   : the ways you want to get SN. 0 -> through script,  1 -> through SFIS, 2-> through Scan SN
//        SettingSN -> NSDictionary *   : according to CCCode, to get the region_code and MPN through which was written in plist
//        ScanSN    -> NSArray *        : get the SN from Scan, you can set the SN's length in plist
//        QuerySN   -> NSDictionary *   : the Item you want query from SFIS
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
- (NSNumber *)Provisioning:(NSDictionary *)dictSettings
			  RETURN_VALUE:(NSMutableString*)szReturnValue
{
    int				iType			= [[dictSettings objectForKey:@"TypeFlag"] intValue];
    NSDictionary	*dicSetSN		= [NSDictionary dictionaryWithDictionary:
									   [dictSettings objectForKey:@"SettingSN"]];
    NSArray			*arrayScanSN	= [NSArray arrayWithArray:
									   [dictSettings objectForKey:@"ScanSN"]];
    switch (iType)
	{	// get SN from script
        case 0:
            if (dicSetSN) 
            {
                for (NSString *szBoardID in [dicSetSN allKeys])
                {
                    if ([szBoardID isEqualToString:[NSString stringWithString:szReturnValue]]) 
                    {
                        [m_dicMemoryValues setValuesForKeysWithDictionary:
						 [dicSetSN objectForKey:szBoardID]];
                        return [NSNumber numberWithBool:YES];
                    }
                }
                ATSDebug(@"Can't find boardid !");
                return [NSNumber numberWithBool:NO];
            }
            else
            {
                ATSDebug(@"NO SN Setting !");
                return [NSNumber numberWithBool:NO];
            }
        case 1:	// get SN from SFIS
            return [self QUERY_SFIS:dictSettings
					   RETURN_VALUE:szReturnValue];
        case 2:	// get SN from scan SN
            if (arrayScanSN) 
            {
                [m_dicMemoryValues setObject:@"0"
									  forKey:@"ScanSNFlag"];
                NSDictionary	*dicScanSN	= [NSDictionary dictionaryWithObject:arrayScanSN
																	  forKey:@"dicScanSN"];
                NSNotificationCenter	*nc	= [NSNotificationCenter defaultCenter];
                [nc postNotificationName:@"NotificationScanSN"
								  object:self
								userInfo:dicScanSN];
                NSRunLoop	*RunLoop	= [NSRunLoop currentRunLoop];
				// set wait 1 second every time
                NSDate		*dateTime	= [NSDate dateWithTimeIntervalSinceNow:1];
                while ([[m_dicMemoryValues objectForKey:@"ScanSNFlag"]
						isEqualToString:@"0"])
                    [RunLoop runUntilDate:dateTime];
            }
            else
            {
                ATSDebug(@"NO SN Scan !");
                return [NSNumber numberWithBool:NO];
            }
            break;
        default:
            ATSDebug(@"Unknown Model !");
            return [NSNumber numberWithBool:NO];
            break;
    }
    return [NSNumber numberWithBool:YES];
}

//add note by betty, 2012/4/17
// Split the item name to Two parts, get the mainItemName and memory in m_dicMemoryValues
// Param:
//      NSDictionary    *dicSubSetting   : Settings
//                      MainItemName  -> the key of value which you want to memory 
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
- (NSNumber *)SPLIT_TEST_NAME:(NSDictionary *)dictSettings
				 RETURN_VALUE:(NSMutableString*)szReturnValue
{
	NSString	*strMainItemName	= [dictSettings objectForKey:@"MainItemName"];
	[m_dicMemoryValues setObject:strMainItemName
						  forKey:@"MainItemName"];
	return [NSNumber numberWithBool:YES];
}

// 2012.4.11
/* For QT0 Prox Open/Short.
 Get the value from an array to judge spec one by one, and upload parametric data.
 Para: dicSpec--> contain the array which need to judge spec, the spec and the parametric name. */
- (NSNumber *)JUDGESPEC_AND_UPLOADPARAMETRIC:(NSDictionary  *)dicPara
								RETURN_VALUE:(NSMutableString*)szReturnValue
{
    // get the data and spec
    NSArray		*arrData	= [dicPara objectForKey:@"DATA"];
    NSString	*szSpec		= [dicPara objectForKey:@"SPEC"];
    // return value
    NSNumber	*retNum		= [NSNumber numberWithBool:YES];
    // for parametic data
    NSString	*szParaName	= [dicPara objectForKey:@"PARANAME"];
    NSString	*szLowLimits, *szHighLimits, *szParamatricData;;
    
    // loop to judge spec and upload parametric data
    for (int i = 0; i < [arrData count]; i++) 
    {
        NSString			*szDataTemp	= [arrData objectAtIndex:i];
        NSMutableString		*szSomeData	= [[NSMutableString alloc] initWithString:szDataTemp];
        NSDictionary        *dicTheSpec	= [NSDictionary dictionaryWithObject:szSpec
																	  forKey:kFZ_Script_JudgeCommonBlack];
        dicTheSpec	= [NSDictionary dictionaryWithObject:dicTheSpec
												 forKey:kFZ_Script_JudgeCommonSpec];
        // judge spec
        if (![[self JUDGE_SPEC:dicTheSpec
				  RETURN_VALUE:szSomeData] boolValue])
        {
            [szReturnValue setString:[NSString stringWithFormat:
									  @"The value %@ is not in the spec %@",
									  szSomeData, szSpec]];
            ATSDebug(@"szReturn value %@", szReturnValue);
            retNum	= [NSNumber numberWithBool:NO];
        }
        [m_dicMemoryValues setObject:@"{NA}"
							  forKey:kFZ_TestLimit];
        // upload paramatric data
        szLowLimits		= [szSpec SubFrom:@"["
							   include:NO];
        szLowLimits		= [szLowLimits SubTo:@","
								  include:NO];
        szHighLimits	= [szSpec SubFrom:@","
							   include:NO];
        szHighLimits	= [szHighLimits SubTo:@"]"
								   include:NO];
        // creat the parametric name
        int	j	= i / 2;
        int	k	= i % 2;
        szParamatricData	= [NSString stringWithFormat:
							   @"%@_%d_%d", szParaName, (k + 1), j];
        NSDictionary	*dicUpload	= [NSDictionary dictionaryWithObjectsAndKeys:
									   szLowLimits,			kFZ_Script_ParamLowLimit,
									   szHighLimits,		kFZ_SCript_ParamHighLimit,
									   szParamatricData,	kFZ_Script_UploadParametric,
									   [NSNumber numberWithBool:NO],
									   kFunnyZoneNOWriteCsvToLogFile, nil];
        [self UPLOAD_PARAMETRIC:dicUpload
				   RETURN_VALUE:szSomeData];
        [szSomeData release];
    }
    return retNum;
}

// 2012.2.21 
// get prox data, and judge.   
- (NSNumber *)CAlCULATOR_PROX_DATA:(NSDictionary *)dicpara
					  RETURN_VALUE:(NSMutableString*)strReturnValue
{
    NSString	*szProxStatus	= [dicpara valueForKey:kFZ_Script_MemoryKey];
    NSString	*szAVG_SPEC		= [dicpara valueForKey:@"AVG_SPEC"];
    NSString	*szSD_SPEC		= [dicpara valueForKey:@"SD_SPEC"] ;
    NSString	*szAverageValue;
    NSString	*szDeviationValue;
    NSNumber	*retNum;
    NSMutableArray	*aryAverageDataStage	= [[NSMutableArray alloc] init];
    NSMutableArray	*aryDeviationDataStage	= [[NSMutableArray alloc] init];
    NSArray		*aryData		= [strReturnValue componentsSeparatedByString:@"\n"];
    if ([aryData count] < 6) 
    {
        ATSDebug(@"Prox Data Error!");
        [aryAverageDataStage release];
        [aryDeviationDataStage release];
        return [NSNumber numberWithBool:NO];
    }
    for (NSString *szValue in aryData) 
    {
        if ([szValue ContainString:@"Average:"]
			&& [szValue ContainString:@"Deviation:"])
        {
            szAverageValue	= [szValue SubFrom:@"Average:"
									  include:NO];
            szAverageValue	= [szAverageValue SubTo:@"Deviation:"
										   include:NO];
            [szAverageValue stringByReplacingOccurrencesOfString:@"\t"
													  withString:@""];
            NSArray	*aryAverage	= [szAverageValue componentsSeparatedByString:@", "];
            //besic judgement , the collumn of data should be more than 3.
            if ([aryAverage count] < 3)
            {
                ATSDebug(@"Prox Data Error!");
                [aryAverageDataStage release];
                [aryDeviationDataStage release];
                return [NSNumber numberWithBool:NO];
            }
            //memory stage 1&2 in aryAverageDataStage
            [aryAverageDataStage addObject:[aryAverage objectAtIndex:1]];
            [aryAverageDataStage addObject:[aryAverage objectAtIndex:2]];
            szDeviationValue	= [szValue SubFrom:@"Deviation:"
										include:NO];
            [szDeviationValue stringByReplacingOccurrencesOfString:@"\t"
														withString:@""];
            NSArray	*aryDeviation	= [szDeviationValue componentsSeparatedByString:@", "];
            //besic judgement , the collumn of data should be more than 3.
            if ([aryDeviation count] < 3)
            {
                ATSDebug(@"Prox Data Error!");
                [aryAverageDataStage release];
                [aryDeviationDataStage release];
                return [NSNumber numberWithBool:NO];
            }
            // memory stage 1 & 2 in aryDeviationDataStage
            [aryDeviationDataStage addObject:[aryDeviation objectAtIndex:1]];
            [aryDeviationDataStage addObject:[aryDeviation objectAtIndex:2]];
        }
    }
    if ([szProxStatus isEqualToString:@"Short"]) 
    {  
        if ([dicpara valueForKey:@"AVG_SPEC"] != nil)
        {
            NSDictionary	*dicParaTemp	= [NSDictionary dictionaryWithObjectsAndKeys:
											   aryAverageDataStage,	@"DATA",
											   szAVG_SPEC,			@"SPEC",
											   @"Prox Short Aver",	@"PARANAME", nil];
            retNum	= [self JUDGESPEC_AND_UPLOADPARAMETRIC:dicParaTemp
											 RETURN_VALUE:strReturnValue];
            if (![retNum boolValue])
            {
                ATSDebug(@"Prox Average Data Error!");
                [aryAverageDataStage release];
                [aryDeviationDataStage release];
                return retNum;
            }
        }
        else
        {
            [aryAverageDataStage release];
            [aryDeviationDataStage release];
            ATSDebug(@"Haven't average spec,please check it!") ;
            return [NSNumber numberWithBool:NO];
        }
    }
    else if([szProxStatus isEqualToString:@"Open"])
    {
        if ([dicpara valueForKey:@"SD_SPEC"] != nil)
        {
            NSDictionary	*dicParaTemp	= [NSDictionary dictionaryWithObjectsAndKeys:
											   aryDeviationDataStage,	@"DATA",
											   szSD_SPEC,				@"SPEC",
											   @"Prox Open SD",			@"PARANAME", nil];
            retNum	= [self JUDGESPEC_AND_UPLOADPARAMETRIC:dicParaTemp
											 RETURN_VALUE:strReturnValue];
            if (![retNum boolValue])
            {
                ATSDebug(@"Prox Deviation Data Error!");
                [aryAverageDataStage release];
                [aryDeviationDataStage release];
                return retNum;
            }
        }
        else
        {
            [aryAverageDataStage release];
            [aryDeviationDataStage release];
            ATSDebug(@"Haven't deviation spec,please check it!");
            return [NSNumber numberWithBool:NO];
        }
    }
    else
    {
        [aryAverageDataStage release];
        [aryDeviationDataStage release];
        ATSDebug(@"Get the wrong status!");
        return [NSNumber numberWithBool:NO];
    }
    [aryAverageDataStage release];
    [aryDeviationDataStage release];
    return [NSNumber numberWithBool:YES];
}

- (NSNumber *)MatchReginCode:(NSDictionary *)dicpara
				RETURN_VALUE:(NSMutableString*)strReturnValue
{
    NSString	*strSN		= [m_dicMemoryValues objectForKey:@"ISN"];
    NSString	*strMLBSN	= [NSString stringWithString:m_szReturnValue];
    if (([strSN length]==12 ) && ([strMLBSN length]==17)) 
    {
        NSString *strEEEEcode = [self catchFromString:strReturnValue
											 location:11
											   length:4];
        NSString *strCCCCCode = [self catchFromString:strSN
											 location:8
											   length:4];
        NSDictionary	*dicCode	= [dicpara objectForKey:@"MatchingTable"];
        if ([[dicCode allKeys] containsObject:strCCCCCode])
		{
            if ([[dicCode objectForKey:strCCCCCode]
				 isEqualToString:strEEEEcode])
            {
                [m_dicMemoryValues setValue:strCCCCCode
									 forKey:@"CCODE"];
                [m_dicMemoryValues setValue:strEEEEcode
									 forKey:@"ECODE"];
                return [NSNumber numberWithBool:YES];
            }
            else
                [strReturnValue setString:[NSString stringWithFormat:
										   @"EEEE code didn't match with CCCC code! MLBSN:%@;SN:%@",
										   strMLBSN, [m_dicMemoryValues objectForKey:@"ISN"]]];
        }
        else
            [strReturnValue setString:[NSString stringWithFormat:
									   @"Didn't maintain this CCCC code! MLBSN:%@;SN:%@",
									   strMLBSN, [m_dicMemoryValues objectForKey:@"ISN"]]];
    }
    else
        [strReturnValue setString:@"MLBSN or SN length error!"];
    m_bCancelFlag	= YES;
    return [NSNumber numberWithBool:NO];
}

// 2012.2.28 Andre
// Descripton:Judge if "XX" exists.
// Param:
//      NSDictionary    *dicContents        : Settings in script
//          XX          -> NSString*    : string which you want to judge
//          WANT        -> NSString*    : controls that if all value is XX, return YES or NO
//          Charactor   -> NSString*    : return value from last function seperated by WHAT
//          Judge       -> NSArray*     : values to be judged
//      NSMutableString *strReturnValue     : Return value 
// Return:
//      Actions result
- (NSNumber *)Judge_If_ALL_Value_Is_XX:(NSDictionary *)dicContents
						  RETURN_VALUE:(NSMutableString *)strReturnValue
{
    NSString	*szXX			= [dicContents objectForKey:@"XX"];
    int			iLengthofXX		= [szXX length];
    BOOL		bWant			= [[dicContents objectForKey:@"WANT"] boolValue];
    NSString	*szCharactor	= [dicContents objectForKey:@"Charactor"];
    NSArray		*aryJudge		= [dicContents objectForKey:@"Judge"];
    BOOL		bTestRet		= NO;
    
    if (nil == aryJudge) 
    {
        ATSDebug(@"No judge range rule, please check!");
        [strReturnValue setString:@"FAIL"];
        return [NSNumber numberWithBool:NO];
    }

    for (int i = 0; i < [aryJudge count]; i+=1)
    {
        NSArray			*aryLines	= [strReturnValue componentsSeparatedByString:@"\n"];
        NSDictionary	*dicAJudge	= [aryJudge objectAtIndex:i];
        NSInteger		iLine		= [[dicAJudge objectForKey:@"Line"] intValue];
        NSString		*szLine		= [aryLines objectAtIndex:iLine];
        NSArray			*aryValues	= [szLine componentsSeparatedByString:szCharactor];
        NSString	*szPositions	= [dicAJudge objectForKey:@"Position"]; //Format: 3-8,11-11
        ATSDebug(@"You want to judge [Line: %d , Position: %@]",
				 iLine, szPositions);
        NSArray	*aryPositions	= [szPositions componentsSeparatedByString:@","]; 
        for (int j = 0; j < [aryPositions count]; j++)
        {
            NSString	*szAPosition	= [aryPositions objectAtIndex:j];
            NSArray		*aryFromXXToXX	= [szAPosition componentsSeparatedByString:@"-"];
            if ([aryFromXXToXX count] == 2)
            {
                int	iBegin	= [[aryFromXXToXX objectAtIndex:0] intValue];
                int	iEnd	= [[aryFromXXToXX objectAtIndex:1] intValue];
                int	iMax	= [aryValues count];
                if (iEnd < iBegin || iMax < iEnd) 
                {
                    ATSDebug(@"Choose the wrong range, please check!");
                    [strReturnValue setString:@"FAIL"];
                    return [NSNumber numberWithBool:NO];
                }
                for (int iIndex = iBegin; iIndex <= iEnd ; iIndex++)
                {
                    if ([[aryValues objectAtIndex:iIndex] length] != iLengthofXX)
                        continue;
                    if (!bWant)
                    {
                        if (![[aryValues objectAtIndex:iIndex] isEqualToString:szXX])
                        {
                            ATSDebug(@"Value in [Line: %d , Position: %d] doesn't MATCH %@",
									 iLine, iIndex, szXX);
                            [strReturnValue setString:@"PASS"];
                            return [NSNumber numberWithBool:YES];
                        }
                        else
                        {
                            ATSDebug(@"Value in [Line: %d , Position: %d] MATCH %@",
									 iLine, iIndex, szXX);
                            bTestRet	= NO;
                        }
                    }
                    else
                    {
                        if ([[aryValues objectAtIndex:iIndex] isEqualToString:szXX])
                        {
                            ATSDebug(@"Value in [Line: %d , Position: %d] MATCH %@",
									 iLine, iIndex, szXX);
                            bTestRet = YES;
                        }
                        else
                        {
                            ATSDebug(@"Value in [Line: %d , Position: %d] doesn't MATCH %@",
									 iLine, iIndex, szXX);
                            [strReturnValue setString:@"FAIL"];
                            return [NSNumber numberWithBool:NO];
                        }
                    }
                }
            }
            else
            {
                ATSDebug(@"No Judge in [Line: %d , Position: %@] Or your Format is Wrong",
						 iLine, szAPosition);
                bTestRet = NO;
                break;
            }
        }
    }
    if (bTestRet) 
    {
        ATSDebug(@"Judge Format pass!");
        [strReturnValue setString:@"PASS"];
        return [NSNumber numberWithBool:YES];
    }
    else
    {
        ATSDebug(@"Judge Format fail!");
        [strReturnValue setString:@"FAIL"];
        return [NSNumber numberWithBool:NO];
    }
} 
#if 0
-(NSNumber *)CHECK_UNIT_LIVE:(NSDictionary *)dicSub
				RETURN_VALUE:(NSMutableString *)szReturnValue
{
    BOOL			bRet						= NO;
    NSDictionary	*dicSendCommandEnter		= [dicSub objectForKey:@"SendCommandEnter"];
    NSDictionary	*dicReciveCommandForEnter	= [dicSub objectForKey:@"ReciveCommandForEnter"];
    NSDictionary	*dicSendCommandDiags		= [dicSub objectForKey:@"SendCommandDiags"];
    NSDictionary	*dicReciveCommandForDiags	= [dicSub objectForKey:@"ReciveCommandForDiags"];
    NSDictionary	*dicReciveCommandAuto		= [dicSub objectForKey:@"ReciveCommandAuto"];
    NSDictionary    *dicReciveCommandForReboot  = [dicSub   objectForKey:@"ReciveCommandForReboot"];
    NSDictionary    *dicReciveCommandForBoot    = [dicSub   objectForKey:@"ReciveCommandForBoot"];
    NSDictionary    *dicReciveCommandForLogIn   = [dicSub   objectForKey:@"ReciveCommandForLogIn"];
    if (!dicSendCommandEnter
		|| !dicSendCommandDiags
		|| !dicReciveCommandForEnter
		|| !dicReciveCommandForDiags
		|| !dicReciveCommandAuto
        || !dicReciveCommandForReboot
        || !dicReciveCommandForBoot
        || !dicReciveCommandForLogIn)
    {
        ATSDebug(@"(FAIL)ENTER_DIAGS: NO Parameters about write and read command");
        [szReturnValue setString:@"ENTER_DIAGS Parameters ERROR"];
        return [NSNumber numberWithBool:NO];
    }
    // 12/4/11 betty modify for getting loop times for receiveCommandAuto from plist, default times is 4
    int	iLoopAutoReceive	= 4;
    if ([dicSub objectForKey:@"LoopForAutoReceive"]
		&& [[dicSub objectForKey:@"LoopForAutoReceive"] isNotEqualTo:@""])
        iLoopAutoReceive	= [[dicSub objectForKey:@"LoopForAutoReceive"] intValue];
    //Rx first, if return value contain ":-)",return directly
    for (int iCurrentTime = 0; iCurrentTime < iLoopAutoReceive; iCurrentTime ++) 
    {
        bRet	= [[self READ_COMMAND:dicReciveCommandAuto
					  RETURN_VALUE:szReturnValue] boolValue];
        if (bRet) 
        {
            ATSDebug(@"(PASS)ENTER_DIAGS: auto enter diags successfully!");
            [szReturnValue setString:@"Unit in Diags Mode"];
//            return [NSNumber numberWithBool: YES];
//          We need double confirm that it's in Diags mode
            break;         
        }
        if ([szReturnValue isEqualToString:@"RX [(null)] Empty response"]) 
            break;
    }
    // get loop times, default times is 5
    int	iLoopTimes	= 5;
    if ([dicSub objectForKey:@"LoopTimes"]
		&& [[dicSub objectForKey:@"LoopTimes"] isNotEqualTo:@""])
        iLoopTimes	= [[dicSub objectForKey:@"LoopTimes"] intValue];
    // get pass flag of enter recovery mode, default is "]"
    NSString	*szPassFlagOfRecovery	= @"]";
    if ([dicSub objectForKey:@"PassFlagOfRecovery"]
		&& [[dicSub objectForKey:@"PassFlagOfRecovery"] isNotEqualTo:@""])
        szPassFlagOfRecovery	= [dicSub objectForKey:@"PassFlagOfRecovery"];
    // get pass flag of enter diags mode, default is ":-)"
    NSString	*szPassFlagOfDiags	= (([[m_dicMemoryValues objectForKey:
										  @"LORKY_DEVICE_ECID"] length] > 0)
									   ? kFZ_EndFlagFormat
									   : @":-)");
    if ([dicSub objectForKey:@"PassFlagOfDiags"]
		&& [[dicSub objectForKey:@"PassFlagOfDiags"] isNotEqualTo:@""])
        szPassFlagOfDiags	= [dicSub objectForKey:@"PassFlagOfDiags"];
    BOOL	bRecoveryMode	= NO;
    BOOL	bDiagsMode		= NO;
    
#pragma mark    -Check OS Mode- 
    // Now i know y Izual ask me to do this, 'cause this is a bullshit
    BOOL    bOSMode         = NO;
    BOOL    bOSModeLogin    = NO;
    NSString    *szPassFlagOfOS     = [dicSub objectForKey:@"PassFlagOfOS"]?[dicSub objectForKey:@"PassFlagOfOS"]:@"login:";
    NSString    *szPassFlagOfOS_LogIn   = [dicSub   objectForKey:@"PassFlagOfOS_Login"]?[dicSub   objectForKey:@"PassFlagOfOS_Login"]:@"iPhone:~ root#";
    
    int		iCurrentLoop	= 0;
    do 
    {
        ATSDebug(@"(BENGIN)ENTER_DIAGS: start enter diags (%i) times",
				 iCurrentLoop);
        iCurrentLoop++;
        // judge whether unit in diags mode or not, if diags mode,return pass and don't write "diags" command
        bDiagsMode	= [self repeatWriteCommand:dicSendCommandEnter
							   ReceiveCommand:dicReciveCommandForEnter
								   PassString:szPassFlagOfDiags
								  ReturnValue:szReturnValue];
        if (bDiagsMode)
        {
            ATSDebug(@"(PASS)ENTER_DIAGS: Unit in Diags Mode (%i times)",
					 iCurrentLoop);
            [szReturnValue setString:@"Unit in Diags Mode"];
            return [NSNumber numberWithBool:YES];
        }
        // if not diags mode, judge if unit in recovery mode, if recovery mode, write "diags command"
        bRecoveryMode	= [self repeatWriteCommand:dicSendCommandEnter
								  ReceiveCommand:dicReciveCommandForEnter
									  PassString:szPassFlagOfRecovery
									 ReturnValue:szReturnValue];
        
        // see if unit's status is OS, if so, login in and reboot
        if (!bRecoveryMode)
        {
            bOSModeLogin    = [self repeatWriteCommand:dicSendCommandEnter
                                        ReceiveCommand:dicReciveCommandForEnter
                                            PassString:szPassFlagOfOS_LogIn
                                           ReturnValue:szReturnValue];
            if (!bOSModeLogin)
            {
                bOSMode     = [self repeatWriteCommand:dicSendCommandEnter
                                        ReceiveCommand:dicReciveCommandForEnter
                                            PassString:szPassFlagOfOS
                                           ReturnValue:szReturnValue];
            }
        }
        
        if (bOSModeLogin)
        {
            if ([self repeatWriteCommand:[NSDictionary  dictionaryWithObjectsAndKeys:@"reboot",@"STRING",@"MOBILE",@"TARGET", nil]
						  ReceiveCommand:dicReciveCommandForReboot
							  PassString:nil
							 ReturnValue:szReturnValue]
                &&
                [self repeatWriteCommand:dicSendCommandEnter
                          ReceiveCommand:dicReciveCommandForEnter
                              PassString:szPassFlagOfDiags
                             ReturnValue:szReturnValue])
            {
                ATSDebug(@"(PASS)ENTER_DIAGS: Unit in OS Mode, then in Diags Mode (%i times)",
                         iCurrentLoop);
                [szReturnValue setString:@"Unit in Diags Mode"];
                return [NSNumber numberWithBool:YES];
            }
        }
        
        if (bOSMode)
        {
            if ([self repeatWriteCommand:[NSDictionary  dictionaryWithObjectsAndKeys:@"root",@"STRING",@"MOBILE",@"TARGET", nil]
						  ReceiveCommand:dicReciveCommandForBoot
							  PassString:nil
							 ReturnValue:szReturnValue]
                &&
                [self repeatWriteCommand:[NSDictionary  dictionaryWithObjectsAndKeys:@"alpine",@"STRING",@"MOBILE",@"TARGET", nil]
						  ReceiveCommand:dicReciveCommandForLogIn
							  PassString:nil
							 ReturnValue:szReturnValue]
                &&
                [self repeatWriteCommand:dicSendCommandEnter
                          ReceiveCommand:dicReciveCommandForEnter
                              PassString:szPassFlagOfDiags
                             ReturnValue:szReturnValue])
            {
                ATSDebug(@"(PASS)ENTER_DIAGS: Unit in OS Mode, then in Diags Mode (%i times)",
                         iCurrentLoop);
                [szReturnValue setString:@"Unit in Diags Mode"];
                return [NSNumber numberWithBool:YES];
            }
        }
        
        if (bRecoveryMode)
        {
            // sent diagscommand to enter diags.
			//	if can't ennter diags mode after write "diags" command, fail it and loop test
            if ([self repeatWriteCommand:dicSendCommandDiags
						  ReceiveCommand:dicReciveCommandForDiags
							  PassString:nil
							 ReturnValue:szReturnValue])
            {
                // double check unit is in diags mode
                bDiagsMode	= [self repeatWriteCommand:dicSendCommandEnter
									   ReceiveCommand:dicReciveCommandForEnter
										   PassString:szPassFlagOfDiags
										  ReturnValue:szReturnValue];
                if (bDiagsMode)
                {
                    ATSDebug(@"(PASS)ENTER_DIAGS: Unit in Recovery Mode, then in Diags Mode (%i times)",
							 iCurrentLoop);
                    [szReturnValue setString:@"Unit in Diags Mode"];
                    return [NSNumber numberWithBool:YES];
                }
                else
                {
                    ATSDebug(@"(PASS)ENTER_DIAGS: Unit in Recovery Mode, then in Diags Mode, but no double check (%i times)",
							 iCurrentLoop);
                    [szReturnValue setString:@"Unit in Diags Mode, but no double check"];
                }

            }
            else
            {
                ATSDebug(@"(FAIL)ENTER_DIAGS: Unit in Recovery Mode, then in Diags Mode (%i times)",
						 iCurrentLoop);
                [szReturnValue setString:@"Unit in Recovery Mode, but can't enter Diags Mode"];
            }
        }
		// if not recovery mode or diags mode, just wait for 5 seconds ands loop test
        if (!bRecoveryMode && !bDiagsMode)
        {
            ATSDebug(@"(FAIL)ENTER_DIAGS: Unit not in Recovery or Diags Mode (%i times)",
					 iCurrentLoop);
            [szReturnValue setString:@"Unit not in Recovery or Diags Mode"];
            //sleep(5);
        }
    } while (iCurrentLoop < iLoopTimes);  // loop untill out of times
    return [NSNumber numberWithBool: NO];
}

- (BOOL)repeatWriteCommand:(NSDictionary *)dicSendCommand
			ReceiveCommand:(NSDictionary *)dicReveiveCommand
				PassString:(NSString *)szPass
			   ReturnValue:(NSMutableString *)szReturnValue
{
    BOOL	bRet	= NO;
    if (!dicSendCommand || !dicReveiveCommand)
        return bRet;
    [szReturnValue setString:@""];
    
    // get the repeat times, default is 1
    int	iRepeatTimes	= 1;
    if ([dicReveiveCommand objectForKey:@"RepeatTimes"]
		&& [[dicReveiveCommand objectForKey:@"RepeatTimes"] isNotEqualTo:@""])
        iRepeatTimes	= [[dicReveiveCommand objectForKey:@"RepeatTimes"] intValue];
	
	int	iPassCount		= 0;
    int	iCurrentRepeat	= 0;
    do 
    {
        iCurrentRepeat++;
        ATSDebug(@"[BEGIN]repeatWriteCommand: %i times try to write command \"%@\"",
				 iCurrentRepeat, [dicSendCommand objectForKey:kFZ_Script_CommandString]);
        bRet	= [[self SEND_COMMAND:dicSendCommand] boolValue];
        if (bRet)
        {
            bRet	= [[self READ_COMMAND:dicReveiveCommand
						  RETURN_VALUE:szReturnValue] boolValue];
			// Added by Lorky 2012-05-01 in Cpto 
			// If we get the ECID Key and we need to trandfor the szPassFlagOfDiags to the correct format.
			if ([szPass isEqualToString:@":-)"]
				&& [[m_dicMemoryValues objectForKey:@"LORKY_DEVICE_ECID"] length] > 0)
				szPass	= kFZ_EndFlagFormat;
        }
        if (bRet)
        {
            if (nil != szPass)// if szPass is nil, just take is as no need to judge pass string
            {
                NSLog(@"%s:%s", [szReturnValue UTF8String], [szPass UTF8String]);
                if (/*[szReturnValue isEqualToString:szPass]*/
                    [szReturnValue    ContainString:szPass])
                {
					iPassCount++;
                    ATSDebug(@"[PASS]repeatWriteCommand: Pass to compare the pass string: %@ (%i times)",
							 szPass, iCurrentRepeat);
                    //if in recovery mode, break to send "diag"
                    if ([szPass isEqualToString:@"]"]||[szPass ContainString:@"login:"]||[szPass    ContainString:@"iPhone:~ root#"])
                    {
						if (iPassCount == iRepeatTimes)
						{
							bRet = YES;
							break;
						}
						else
						{
							bRet = NO;
						}

                    }
                    //[2012-08-14 11:00:30.237](TX ==> [MOBILE]):
                    //[2012-08-14 11:00:30.250](RX ==> [MOBILE]):
                    //[4420208F:8E7F3233] 
                    //[2012-08-14 11:00:30.254](Clear Buffer ==> [MOBILE]):
                    //[2012-08-14 11:00:30.257](TX ==> [MOBILE]):
                    //[2012-08-14 11:00:30.260](RX ==> [MOBILE])::-) 
                    //add this judgement to fix above bug
                    if ([[m_dicMemoryValues objectForKey:@"LORKY_DEVICE_ECID"] length] == 0)
                    {
                        ATSDebug(@"Response didn't contain ECID, need try again!");
                        bRet	= NO;
                    }
                    else
                    {
						if (iPassCount == iRepeatTimes)
						{
							bRet = YES;
							break;
						}
						else
						{
							bRet = NO;
						}
                    }
                }
                else
                {
                    ATSDebug(@"[FAIL]repeatWriteCommand: Fail to compare the pass string: %@ (%i times)",
							 szPass, iCurrentRepeat);
                    bRet	= NO;
                }
            }
            else
            {
                ATSDebug(@"[PASS]repeatWriteCommand: Don't need to get the pass string (%i times)",
						 iCurrentRepeat);
                bRet	= YES;
                // if nil, break
                break;
            }
        }
        else
        {
            ATSDebug(@"[FAIL]repeatWriteCommand: Read command \"%@\" fail, ReturnValue: %@ (%i times)",
					 [dicSendCommand objectForKey:kFZ_Script_CommandString],
					 szReturnValue, iCurrentRepeat);
            bRet	= NO;
        }
    }while (iCurrentRepeat < iRepeatTimes); // loop untill out of times 
    return bRet;
}

#else
typedef enum
{
	kDiagsMode = 0,
	kRecoverMode,
	kNonLoginOSMode,
	kLogonOSMode,
	kUnknownMode,
}TestingDeviceMode;

- (TestingDeviceMode)CheckingDeviceModeWithCommand:(NSString *)strResponse
{
	TestingDeviceMode testMode = kUnknownMode;
    if ([strResponse  contains:@"RX ["]
        || [strResponse contains:@"Empty response"]
        || [strResponse contains:@"Incomplete response"])
    {
        return kUnknownMode;
    }
    if ([strResponse contains:@"iPhone:~ root#"])
        testMode    = kLogonOSMode;
    else if ([strResponse contains:@"login:"])
        testMode    = kNonLoginOSMode;
	else if ([strResponse contains:@":-)"])
		testMode    = kDiagsMode;
	else if ([strResponse contains:@"]"]&&[strResponse  length]<100)
		testMode    = kRecoverMode;
	return testMode;
}


-(NSNumber *)CHECK_UNIT_LIVE:(NSDictionary *)dicSub
				RETURN_VALUE:(NSMutableString *)szReturnValue
{
    BOOL			bRet						= NO;
    NSDictionary	*dicSendCommandEnter		= [dicSub objectForKey:@"SendCommandEnter"];
    NSDictionary	*dicReciveCommandForEnter	= [dicSub objectForKey:@"ReciveCommandForEnter"];
    NSDictionary	*dicSendCommandDiags		= [dicSub objectForKey:@"SendCommandDiags"];
    NSDictionary	*dicReciveCommandForDiags	= [dicSub objectForKey:@"ReciveCommandForDiags"];
    NSDictionary    *dicReciveCommandForReboot  = [dicSub   objectForKey:@"ReciveCommandForReboot"];
    NSDictionary    *dicReciveCommandForBoot    = [dicSub   objectForKey:@"ReciveCommandForBoot"];
    NSDictionary    *dicReciveCommandForLogIn   = [dicSub   objectForKey:@"ReciveCommandForLogIn"];
    if (!dicSendCommandEnter
		|| !dicSendCommandDiags
		|| !dicReciveCommandForEnter
		|| !dicReciveCommandForDiags
        || !dicReciveCommandForReboot
        || !dicReciveCommandForBoot
        || !dicReciveCommandForLogIn)
	{
		ATSDebug(@"(FAIL)ENTER_DIAGS: NO Parameters about write and read command");
        [szReturnValue setString:@"ENTER_DIAGS Parameters ERROR"];
        return [NSNumber numberWithBool:NO];
	}
	
	NSUInteger	iLoopTimes	= 5;
    if ([dicSub objectForKey:@"LoopTimes"]
		&& [[dicSub objectForKey:@"LoopTimes"] isNotEqualTo:@""])
        iLoopTimes	= [[dicSub objectForKey:@"LoopTimes"] intValue];
	
	for (NSUInteger iCurrentLoop = 0; iCurrentLoop < iLoopTimes; iCurrentLoop++)
	{
		// send command for this checking.
		[self WriteCommand:dicSendCommandEnter
			ReceiveCommand:dicReciveCommandForEnter
			   ReturnValue:szReturnValue];
		TestingDeviceMode DUTMode = [self CheckingDeviceModeWithCommand:szReturnValue];
		NSUInteger iRepeatTimes = 1;
		BOOL bMode				=	NO;
		BOOL iTried				=	0;
		switch (DUTMode) {
			case kRecoverMode: // Should send command "diags" to enter diags mode
			{
				[szReturnValue setString:@"Recover Mode"];
				[self WriteCommand:dicSendCommandDiags
					ReceiveCommand:dicReciveCommandForDiags
					   ReturnValue:szReturnValue];
			}
			case kDiagsMode: // Check the response has contains ":-)" more than twice
			{
				iRepeatTimes = [[dicReciveCommandForDiags objectForKey:@"RepeatTimes"] integerValue];
				for (int i = 0; i < iRepeatTimes; i++)
				{
					bMode = [self WriteCommand:dicSendCommandEnter
								ReceiveCommand:dicReciveCommandForDiags
								   ReturnValue:szReturnValue];
					if (bMode) iTried ++;
				}
				if (iRepeatTimes == iTried)
					[szReturnValue setString:@"Diags Mode"];
				break;
			}
			case kNonLoginOSMode: // Should send command "root"/"alpine" to login OS mode
			{
				[szReturnValue setString:@"NonLogin OS Mode"];
				NSDictionary * dictRoot = [NSDictionary  dictionaryWithObjectsAndKeys:@"root",@"STRING",@"MOBILE",@"TARGET", nil];
				NSDictionary * dictPWD= [NSDictionary  dictionaryWithObjectsAndKeys:@"alpine",@"STRING",@"MOBILE",@"TARGET", nil];

				bRet = [self WriteCommand:dictRoot
						   ReceiveCommand:dicReciveCommandForBoot
							  ReturnValue:szReturnValue];
				if (bRet)
					bRet = [self WriteCommand:dictPWD
							   ReceiveCommand:dicReciveCommandForLogIn
								  ReturnValue:szReturnValue];
				if (bRet)
					[szReturnValue setString:@"Logon OS Mode"];
			}
			case kLogonOSMode: // should send command "reboot" to reboot in Diags mode
			{
				NSDictionary * dictReboot = [NSDictionary  dictionaryWithObjectsAndKeys:@"reboot",@"STRING",@"MOBILE",@"TARGET", nil];
				bRet = [self WriteCommand:dictReboot
						   ReceiveCommand:dicReciveCommandForReboot
							  ReturnValue:szReturnValue];
				if (bRet)
					[szReturnValue setString:@"Logon OS Mode"];
				break;
			}
			case kUnknownMode: // Unknown mode, only sleep 3 seconds to bringup the DUT
				sleep(3);
				[szReturnValue setString:@"Unknown Mode"];
				break;
		}
		ATSDebug(@"DEVICE in %@",szReturnValue);
        // 100 percent definitely diags mode, no need to loop again.
        if (bMode) {
            return [NSNumber numberWithBool:YES];
        }
	}
	return [NSNumber numberWithBool:bRet];
}

- (BOOL)WriteCommand:(NSDictionary *)dicSendCommand
	  ReceiveCommand:(NSDictionary *)dicReveiveCommand
		 ReturnValue:(NSMutableString *)szReturnValue
{
	BOOL bRet = NO;
	
	bRet	= [[self SEND_COMMAND:dicSendCommand] boolValue];
	if (bRet)
	{
		bRet	= [[self READ_COMMAND:dicReveiveCommand
					  RETURN_VALUE:szReturnValue] boolValue];
		return bRet;
	}
	return NO;	
}

#endif


//Add for enter OS mode
-(NSNumber *)CHECK_OS_LIVE:(NSDictionary *)dicSub RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSInteger iCycleEnter = [[dicSub objectForKey:@"EnterCycleTime"] intValue];
    NSDictionary *dicSendEnter = [dicSub objectForKey:@"0.SEND_ENTER"];
    NSDictionary *dicReadEnter = [dicSub objectForKey:@"1.READ_ENTER"];
    
    NSNumber *numRet = [NSNumber numberWithBool:YES];
    for(NSInteger iIndex=0; iIndex<iCycleEnter; iIndex++)
    {
        [self SEND_COMMAND:dicSendEnter];
        numRet = [self READ_COMMAND:dicReadEnter RETURN_VALUE:szReturnValue];
        if([numRet boolValue])
        {
            break;
        }
    }
    if([numRet boolValue])
    {
        if([szReturnValue rangeOfString:@"login:"].location != NSNotFound)
		{
			NSDictionary *dicSendUser = [dicSub objectForKey:@"2.SEND_USER"];
            NSDictionary *dicReadUser = [dicSub objectForKey:@"3.READ_USER"];
            NSDictionary *dicSendPasd = [dicSub objectForKey:@"4.SEND_PASSWORD"];
            NSDictionary *dicReadPasd = [dicSub objectForKey:@"5.READ_PASSWORD"];
            
            numRet = [self SEND_COMMAND:dicSendUser];
            if([numRet boolValue])
            {
                numRet = [self READ_COMMAND:dicReadUser RETURN_VALUE:szReturnValue];
                if([numRet boolValue])
                {
                    return [NSNumber numberWithBool:([[self SEND_COMMAND:dicSendPasd] boolValue] &&
                                                     [[self READ_COMMAND:dicReadPasd RETURN_VALUE:szReturnValue] boolValue])];
				}
				else
				{
					NSLog(@"Receive user name response fail ! Return NO !");
					return [NSNumber numberWithBool:NO];
				}
			}
			else
			{
				NSLog(@"Send user name fail ! Return NO !");
				return [NSNumber numberWithBool:NO];
			}
		}
		else if([szReturnValue rangeOfString:@"root#"].location != NSNotFound)
		{
			NSLog(@"You have logged in ! Return YES !");
			return [NSNumber numberWithBool:YES];
		}
		else
		{
			NSLog(@"Incorrect mode ! Return NO !");
			return [NSNumber numberWithBool:NO];
		}
	}
    else
    {
        NSLog(@"Read Data fail ! Return NO !");
        return [NSNumber numberWithBool:NO];
    }
}


//add by soshon, 2012/4/19
// Convert Voltage. if dFlapVolage > 2048   dReturnValue = 1500 - 1500*(((double)(4096-dFlapVolage))/2048);
//                  else dReturnValue = 1500 + 1500*(((double)(dFlapVolage))/2048)
// Param:
//      NSDictionary    *dicSubSetting   : Settings
//          NO settings in  this function
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
-(NSNumber *)ConvertVoltage:(NSDictionary *)dicParam
			   RETURN_VALUE:(NSMutableString *)strReturnValue
{
    if (strReturnValue == nil || [strReturnValue isEqualToString:@""]) 
    {
        [strReturnValue setString:@"FAIL"];
        return [NSNumber numberWithBool:NO];
    }
    double	dFlapVolage		= [strReturnValue doubleValue];
    double	dReturnValue	= 0.0;
    if (dFlapVolage > 2048) 
    {
        dFlapVolage		= 4096 - dFlapVolage;
        dReturnValue	= 1500 - 1500 * (((double)(dFlapVolage)) / 2048);
    }
	else
        dReturnValue	= 1500 + 1500 * (((double)(dFlapVolage)) / 2048);
    [strReturnValue setString:[NSString stringWithFormat:
							   @"%0.6f", dReturnValue]];
    return [NSNumber numberWithBool:YES];
}

// Soshon, 2012/4/19
// calculate offset. combine two Hex value. ex:  KEY1->0xDE KEY2->0x05   combine DE05
// Param:
//      NSDictionary    *dicSubSetting   : Settings
//                KEY1 -> NSString  *    : get the key of first value
//                KEY2 -> NSString  *    : get the key of second value
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
-(NSNumber *)Calculate_Offset:(NSDictionary *)dicParam
				 RETURN_VALUE:(NSMutableString *)strReturnValue
{
    if (strReturnValue == nil) 
    {
        [strReturnValue setString:@""];
        return [NSNumber numberWithBool:NO];
    }
    if ((nil == [dicParam valueForKey:@"KEY1"])
		|| (nil == [dicParam valueForKey:@"KEY2"]))
    {
        [strReturnValue setString:@"Get Value FAIL"];
        return [NSNumber numberWithBool:NO];
    }
    NSString	*strValue1	= [m_dicMemoryValues valueForKey:
							   [dicParam valueForKey:@"KEY1"]];
    strValue1	= [strValue1 stringByReplacingOccurrencesOfString:@"0x"
													 withString:@""];
    strValue1	= [strValue1 stringByReplacingOccurrencesOfString:@"0X"
													 withString:@""];
    NSString	*strValue2	= [m_dicMemoryValues valueForKey:
							   [dicParam valueForKey:@"KEY2"]];
    strValue2	= [strValue2 stringByReplacingOccurrencesOfString:@"0x"
													 withString:@""];
    strValue2	= [strValue2 stringByReplacingOccurrencesOfString:@"0X"
													 withString:@""];
    NSString	*strJoinString	= [NSString stringWithFormat:
								   @"0x%@%@", strValue1, strValue2];
    [strReturnValue setString:strJoinString];
    return [NSNumber numberWithBool:YES];
}

// Soshon, 2012/4/19
// calculate tesla. dTestFlap = (strOffset-strVoltage )/(1.25*10);
// Param:
//      NSDictionary    *dicSubSetting   : Settings
//              OFFSET -> NSString  *    : get the key name for offset
//             VOLTAGE -> NSString  *    : get the key name for Voltage
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
-(NSNumber *)Calculate_Tesla:(NSDictionary *)dicParam
				RETURN_VALUE:(NSMutableString *)strReturnValue
{
    if (strReturnValue == nil) 
    {
        [strReturnValue setString:@""];
        return [NSNumber numberWithBool:NO];
    }
    if ((nil == [dicParam valueForKey:@"OFFSET"])
		|| (nil == [dicParam valueForKey:@"VOLTAGE"]))
    {
        [strReturnValue setString:@"Get Value FAIL"];
        return [NSNumber numberWithBool:NO];
    }
    NSString	*strOffset	= [dicParam valueForKey:@"OFFSET"];
    NSString	*strVoltage	= [dicParam valueForKey:@"VOLTAGE"];
    strOffset	= [m_dicMemoryValues valueForKey:strOffset];
    strVoltage	= [m_dicMemoryValues valueForKey:strVoltage];
    double		dTestFlap	= (([strOffset doubleValue]
								- [strVoltage doubleValue])
							   / (1.25 * 10));
    [strReturnValue setString:[NSString stringWithFormat:
							   @"%0.6f", dTestFlap]];
    return [NSNumber numberWithBool:YES];
}

//betty 2012/4/20
//read 50 command,and calculate average of the 50 return value
//Param:
//       NSDictionary    *dicSubSetting   : Settings
//                  LoopTimes  NSString*  : The loop time you want to read the command
//            MemForCalculate  NSString*  : the key you want to memory in m_dicMemoryValues
//            SendCommand   NSDictionary* : the command you want to send
//            ReceiveCommand NSDictionary*: receive command
//            TransferResult NSDictionary*: for each return value you want to transfer
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
-(NSNumber *)Calculate_AverageVoltage:(NSDictionary *)dicParam
						 RETURN_VALUE:(NSMutableString *)strReturnValue
{
    BOOL			bRet				= NO;
    NSDictionary	*dicSendCommand		= [dicParam objectForKey:@"SendCommand"];
    NSDictionary	*dicReciveCommand	= [dicParam objectForKey:@"ReceiveCommand"];
    NSDictionary	*dicTransfer		= [dicParam objectForKey:@"TransferResult"];
    NSString		*strKey				= ([dicParam objectForKey:@"MemForCalculate"]
										   ? [dicParam objectForKey:@"MemForCalculate"]
										   : @"Voltage");
    NSMutableArray	*arrValue			= [[NSMutableArray alloc]init];
    double			result				= 0.0;
    if (!dicSendCommand || !dicReciveCommand )
    {
        ATSDebug(@"(FAIL)Calculate_AverageVoltage: NO Parameters about send and read command");
        [strReturnValue setString:@"Calculate_AverageVoltage Parameters ERROR"];
		[arrValue release];//add by jingfu ran for avoiding memory leak on 2012 05 02
        return [NSNumber numberWithBool:NO];
    }
    int	iLoopTime	= 50;  // default loop time is 50
    if ([dicParam objectForKey:@"LoopTimes"]
		&& [[dicParam objectForKey:@"LoopTimes"] isNotEqualTo:@""])
        iLoopTime	= [[dicParam objectForKey:@"LoopTimes"] intValue];
    for (int i = 0; i < iLoopTime; i++)
    {
        bRet	= [[self SEND_COMMAND:dicSendCommand] boolValue];
        if (bRet) 
            bRet	= [[self READ_COMMAND:dicReciveCommand
						  RETURN_VALUE:strReturnValue] boolValue];
        else
        {
            ATSDebug(@"[Fail]Calculate_AverageVoltage Fail: Send_Command \"%@\" fail (%i times)",
					 [dicSendCommand objectForKey:kFZ_Script_CommandString], i);
			[arrValue release];//add by jingfu ran for avoiding memory leak on 2012 05 02
            return [NSNumber numberWithBool:NO];
        }
        if (bRet) 
        {
            // add by betty for judging dicTransfer is need or not, if nil, don't need transfer on 2012.05.04
            if (dicTransfer) 
                bRet	= [[self NumberSystemConvertion:dicTransfer
										RETURN_VALUE:strReturnValue]boolValue];
        }
        else
        {
            ATSDebug(@"[Fail]Calculate_AverageVoltage Fail: Read_Command \"%@\" fail,returnValue:%@ (%i times)",
					 [dicSendCommand objectForKey:kFZ_Script_CommandString],
					 strReturnValue,
					 i);
            [arrValue release];//add by jingfu ran for avoiding memory leak on 2012 05 02
			return [NSNumber numberWithBool:NO];
        }
        // marked by betty for no use for convert voltage on 2012.05.04
        if (bRet) 
        {
            result	+= [strReturnValue floatValue];
            //modified by jingfu ran for avoiding memory leak on 2012 05 03
            [arrValue addObject:[NSString stringWithFormat:@"%@", strReturnValue]];
        }
        else
        {
            ATSDebug(@"[Fail]Calculate_AverageVoltage Fail: convert the %@ from 16 to 10 fail (%i times)",
					 strReturnValue, i);
            [arrValue release];//add by jingfu ran for avoiding memory leak on 2012 05 02
			return [NSNumber numberWithBool:NO];
        }
    }
    result	= result / iLoopTime;
    [strReturnValue setString:[NSString stringWithFormat:
							   @"%i", (int)result]];
    [m_dicMemoryValues setValue:arrValue
						 forKey:strKey];
    [arrValue release];
    return [NSNumber numberWithBool:YES];
}

//betty 2012/4/20
//Split the value Voltage to Two part. for example DE05   after split DE and 05
//Param:
//       NSDictionary    *dicSubSetting   : Settings
//                  KEY1  NSString*  : The key you want to memory in m_dicMemoryValues
//                  KEY2  NSString*  : the key you want to memory in m_dicMemoryValues
//        SplitLocation   NSString*  : the location you want to split the string
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
-(NSNumber *)SplitVoltage:(NSDictionary *)dicParam
			 RETURN_VALUE:(NSMutableString *)strReturnValue
{
    if (strReturnValue == nil
		|| [strReturnValue isEqualToString:@""])
    {
        [strReturnValue setString:@"FAIL"];
        return [NSNumber numberWithBool:NO];
    }
    NSString	*strKey1	= ([dicParam objectForKey:@"KEY1"]
							   ? [dicParam objectForKey:@"KEY1"]
							   : @"EEProm1");
    NSString	*strkey2	= ([dicParam objectForKey:@"KEY2"]
							   ? [dicParam objectForKey:@"KEY2"]
							   : @"EEProm1");
    NSString	*strKey		= [dicParam objectForKey:kFZ_Script_MemoryKey];
    NSString	*strValue	= [NSString stringWithString:
							   [m_dicMemoryValues objectForKey:strKey]];
    int		SplitLocation	= ([dicParam objectForKey:@"SplitLocation"]
							   ? [[dicParam objectForKey:@"SplitLocation"]intValue]
							   : 2);
    if (4 < [strValue length])
        ATSDebug(@"the value you get from voltage is not correct");
    else
        if ([strValue length]< 4) 
        {
            int	i	= 4 - [strValue length];
            for (; i>0; i--)
                strValue	= [NSString stringWithFormat:@"0%@", strValue];
        }
    NSString	*strValue1	= [strValue substringToIndex:SplitLocation];
    [m_dicMemoryValues setValue:strValue1
						 forKey:strKey1];
    strValue1	= [strValue substringFromIndex:SplitLocation];
    [m_dicMemoryValues setValue:strValue1
						 forKey:strkey2];
    return [NSNumber numberWithBool:YES];
}

//betty 2012/4/20
//Write the date in to the path file
//Param:
//       NSDictionary    *dicSubSetting   : Settings
//                  KEY  NSString*   : The name you want to memory in the file
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
-(NSNumber *)WriteToPlist:(NSDictionary *)dicParam
			 RETURN_VALUE:(NSMutableString *)strReturnValue
{
    NSString	*strFileName	= ([dicParam objectForKey:@"FileName"]
								   ? [dicParam objectForKey:@"FileName"]
								   : @"MagnetClibration");
    NSString	*strPath		= [NSString stringWithFormat:@"%@/Library/Preferences/%@.plist",
								   NSHomeDirectory(), strFileName];
    NSFileManager	*BuildPlistPath	= [NSFileManager defaultManager];
    if ([BuildPlistPath fileExistsAtPath:strPath] != YES) 
    {
        [BuildPlistPath createFileAtPath:strPath
								contents:nil
							  attributes:nil];
        NSMutableDictionary	*dicSetting	= [[NSMutableDictionary alloc] init];
        [dicSetting writeToFile:strPath
					 atomically:NO];
        [dicSetting release];
        ATSDebug(@"Create MagnetCalibration file in path %@ PASS",
				 strPath);
    }
    NSMutableDictionary	*dicSetting	= [[NSMutableDictionary alloc]
									   initWithContentsOfFile:strPath];
    NSString	*strKey		= ([dicParam objectForKey:@"KEY"]
							   ? [dicParam objectForKey:@"KEY"]
							   : @"other");
    NSString	*strValue	= [NSString stringWithString:strReturnValue];
    [dicSetting setObject:strValue
				   forKey:strKey];
    [dicSetting writeToFile:strPath
				 atomically:NO];
    [dicSetting release];
    return [NSNumber numberWithBool:YES];
}

//betty 2012/4/20
//caculate a array standard deviation 
//Param:
//       NSDictionary    *dicSubSetting   : Settings
//                  KEY  NSString*   : The key you memory in the m_dicMemoryValue
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
-(NSNumber *)CalculateSTD:(NSDictionary *)dicParam
			 RETURN_VALUE:(NSMutableString *)strReturnValue
{
    NSString	*strKey	= ([dicParam objectForKey:kFZ_Script_MemoryKey]
						   ? [dicParam objectForKey:kFZ_Script_MemoryKey]
						   : @"Voltage");
    id	arrValue	= [m_dicMemoryValues objectForKey:strKey];
    if (![arrValue isKindOfClass:[NSArray class]]) 
    {
        ATSDebug(@"The value you get is not NSArray class");
        return [NSNumber numberWithBool:NO];
    }
    double	doubleTemp	= 0.0,
			doubleSum1	= 0.0,
			doubleSum2	= 0.0;
	for(int i=0; i<[arrValue count]; i++)
	{
		doubleTemp	= [[arrValue objectAtIndex:i] doubleValue];
		doubleSum1	+= doubleTemp*doubleTemp;
		doubleSum2	+= doubleTemp;
	}
	int		iCount	= [arrValue count];
	double	fResult	= sqrt(((iCount * doubleSum1
							 - doubleSum2 * doubleSum2)
							/ (iCount * (iCount - 1) * 1.0)));
    [strReturnValue setString:[NSString stringWithFormat:@"%f", fResult]];
    return [NSNumber numberWithBool:YES];
}

//betty 2012/4/20
//Read the AveVoltage from plist file, and show it On UI
//Param:
//       NSDictionary    *dicSubSetting   : Settings
//                  KEY  NSString*   : The key you want get from plist file
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
- (NSNumber *)ADD_AveVoltage_TO_CSV:(NSDictionary *)dictData
					   RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSString	*strPath	= [NSString stringWithFormat:
							   @"%@/Library/Preferences/MagnetClibration.plist",
							   NSHomeDirectory()];
    NSDictionary	*dicSetting		= [NSDictionary dictionaryWithContentsOfFile:strPath];
    NSFileManager	*fileManager	= [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:strPath] != YES) 
    {
        if (!m_bCancelToEnd)
        {
            NSRunAlertPanel(@"警告(Warning)",
							@"请先对治具进行校验！(Please do fixture calibration first!)",
							@"确认(OK)", nil, nil);
            m_bCancelToEnd	= YES;
			//If do not fixture calibration, cancel to end and don't upload pdca(No sn at this time)
            m_bValidationDisablePudding	= YES;
        }
        ATSDebug(@"the file is not exits,please do MagnetCalibration first!");
        [szReturnValue setString:@"No calibaration data"];
        return [NSNumber numberWithBool:NO];
    }
    NSString	*strKey	= [dictData objectForKey:kFZ_Script_MemoryKey];
    [szReturnValue setString:[dicSetting objectForKey:strKey]];
    return [NSNumber numberWithBool:YES];
}

//betty 2012/4/24
//change the flag m_bNoUploadPDCA you set
//Param:
//       NSDictionary    *dicSubSetting   : Settings
//                  KEY  NSString*        : set the bool value you want not upload to PDCA or not, default is NO
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
- (NSNumber *)NONEED_UPLOAD_PDCA:(NSDictionary *)dicPara
					RETURN_VALUE:(NSMutableString *)szReturnValue
{
    BOOL	bNoNeedUpload	= NO;
    if(nil ==[dicPara valueForKey:@"NoNeedUpload"])
        bNoNeedUpload	= NO; 
    else
        bNoNeedUpload	= [[dicPara valueForKey:@"NoNeedUpload"] boolValue];
    NSString	*strSN	= [dicPara valueForKey:@"setSN"];
    if (strSN)
        [self setMobileSerialNumber:[NSString stringWithString:strSN]];  
    m_bValidationDisablePudding	= bNoNeedUpload;
    return [NSNumber numberWithBool:YES];
}

-(float) CalculateDistanceFromBytes:(unsigned int) high
								low:(unsigned int) low
{
    float			sensor_full_scale	= 220;
    float			sensor_scale_factor	= (sensor_full_scale / 4095);
    unsigned int	acc					= 0;
    // drop bits 7 and 6 from high
    acc	= (0x3F & high);
    // move high niblet up 6 bits
    acc	<<= 6;
    // drop bits 7 and 6 from low
    acc	|= (0x3F & low);
    // scale and return mm's
    return (fabsf(sensor_full_scale - (float)(acc * sensor_scale_factor)));
}

-(NSNumber *)GetDistance:(NSDictionary *)dicSetting
			 ReturnValue:(NSMutableString *)strReturn
{
    //Add by Shania to check prox sensor response
    if (![self JudgeProxSensorData:dicSetting
					  return_Value:strReturn])
    {
        ATSDebug(@"JudgeProxSensorData result is not good!");
        return [NSNumber numberWithBool:NO];
    }
    //modified by jingfu ran 2012 04 30
    unsigned int	high	= 0;
    unsigned int	low		= 0;
    //Modified by Shania 2012/05/30
    NSArray	*arrayHexValue	= [strReturn componentsSeparatedByString:@" "];
    if ([arrayHexValue count]>5)
    {  
        NSScanner	*scan	= [NSScanner scannerWithString:[arrayHexValue objectAtIndex:3]];
        [scan scanHexInt:&high];
        scan	= [NSScanner scannerWithString:[arrayHexValue objectAtIndex:4]];
        [scan scanHexInt:&low];
        ATSDebug(@"High = %d, Low = %d", high, low);
    }
	else
    {
        ATSDebug(@"The prox seneor is less than 5\n data = %@\nlength = %d\n",
				 strReturn, [arrayHexValue count]);
        return [NSNumber numberWithBool:NO];
    }
	float	sensor_cal_distance	= 82;
	float	distance_actual		= [self CalculateDistanceFromBytes:high
														  low:low];
	float	distance			= -distance_actual + sensor_cal_distance;
    if (![[dicSetting objectForKey:@"Init"] boolValue]) 
    {
        ATSDebug(@"The prox sensor read data = %.6f", distance);
        float	fInitLocation	= [[kPD_UserDefaults objectForKey:@"InitLocation"] floatValue];
        NSString	*strPath	= [NSString stringWithFormat:
								   @"%@/Library/Preferences/HESCalibration.plist",
								   NSHomeDirectory()];
        NSDictionary	*dicSetting	= [NSDictionary dictionaryWithContentsOfFile:strPath];
        float		fInitDistance	= [[dicSetting objectForKey:@"InitDistance"] floatValue];
        ATSDebug(@"The InitLocation is %.6f and InitDistance is %.6f",
				 fInitLocation, fInitDistance);
        distance	= distance + fInitLocation - fInitDistance;
    }
	[strReturn setString:[NSString stringWithFormat:@"%0.6f", distance]];
    ATSDebug(@"The convert prox sensor data = %.6f", distance);
	return [NSNumber numberWithBool:YES];
}

-(NSNumber *)CalculateMoveDistance:(NSDictionary *)dicSetting
						ReturnVale:(NSMutableString *)strReturn
{
    BOOL	bCancelToEND	= ([dicSetting valueForKey:@"CANCELTOEND"] == nil
							   ? NO
							   : [[dicSetting valueForKey:@"CANCELTOEND"] boolValue]);
    NSString	*strCanceToEndDistance	= [dicSetting valueForKey:@"CANCELDISTANCE"];
    float			fNeedMove			= [[dicSetting valueForKey:@"INITDISTANCE"] floatValue];
    //Save the INITDISTNACE for the later judge  by Shania 2012/5/28
    [m_dicMemoryValues setObject:[dicSetting valueForKey:@"INITDISTANCE"]
						  forKey:@"INITDISTANCE"];
    ATSDebug(@"INITDISTANCE saved: %@", [dicSetting valueForKey:@"INITDISTANCE"]);
    NSString	*strKeyValue	= [dicSetting valueForKey:@"KEY"];
    NSString	*strValue		= [m_dicMemoryValues valueForKey:strKeyValue];
    float		iawayfromZero	= [strValue floatValue] - fNeedMove;
    long		lNeedMoveDistance	= 0;
    lNeedMoveDistance	= (long)kHallEffect_CaluteDistance_Value * iawayfromZero;
    [strReturn setString:[NSString stringWithFormat:@"%ld", lNeedMoveDistance]];
    //add by jingfu ran for end test if init default location fail on 2012 05 04
    if (bCancelToEND) 
        if (abs([strValue floatValue]) >= [strCanceToEndDistance floatValue]) 
        {
            [strReturn setString:@"INIT FAIL"];
            m_bCancelToEnd	= YES;
            ATSDebug(@"Init fixture to default location fail! ");
            return [NSNumber numberWithBool:NO];
        }
    //end by jingfu ran on 2012 05 04
    return [NSNumber numberWithBool:YES];
}

-(NSNumber *)FindTheMissOrDetectLocation:(NSDictionary *)dicSetting
							 ReturnValue:(NSMutableString *)strReturn
{
    NSString	*strFirstCommand			= [dicSetting valueForKey:@"FIRSTCOMMAND"];
    NSString	*strSecondCommand			= [dicSetting valueForKey:@"SECONDCOMMAND"];
	NSString	*strThirdCommand			= [dicSetting valueForKey:@"THIRDCOMMAND"];
    NSString	*strFirstNeedHasString		= [dicSetting valueForKey:@"FIRSTNEEDSTRING"];
    NSString	*strSecondNeedHasString		= [dicSetting valueForKey:@"SECONDNEEDSTRING"];
	NSString	*strThirdNeedHasString		= [dicSetting valueForKey:@"THIRDNEEDSTRING"];
    //modified by jingfu ran for avoid ertra operator and direct tranform NSData as command  data as  ken's advice
    id			ProxCommand					= [dicSetting valueForKey:@"PROXCOMMAND"];
    NSString	*strFirstStoreInMemoryKey	= [dicSetting valueForKey:@"FIRSTSTOREKEY"];
    NSString	*strSecondStorememoryKey	= [dicSetting valueForKey:@"SECONDSTOREKEY"];
	NSString	*strThirdStoreMemoryKey		= [dicSetting valueForKey:@"THIRDSTOREKEY"];
    NSString	*strFLCommand				= [dicSetting valueForKey:@"FLCOMMAND"];
    NSString	*strPortMobileType			= [dicSetting valueForKey:@"TARGETMOBILE"];
    NSString	*strPortFixtureType			= [dicSetting valueForKey:@"TARGETFIXTURE"];
    NSString	*strPortProxSensorType		= [dicSetting valueForKey:@"TARGETPROXSENSOR"];
    NSString	*strInitValue				= [dicSetting valueForKey:@"INITDISTANCE"];
    NSString	*strRemainTimes				= [dicSetting valueForKey:@"REMAINTIMES"]; 
    NSString	*strProxHasString			= [dicSetting valueForKey:@"PROXHASSTRING"];
    int			iTryReadProxDataTimes		= ([dicSetting valueForKey:@"READPROXDATATIME"] == nil
											   ? 3
											   : [[dicSetting valueForKey:@"READPROXDATATIME"] intValue]);
    int			tryTimes					= [[dicSetting valueForKey:@"TRYCOUNT"] intValue];
    BOOL		bFirstNoNeedloop			= NO;
    BOOL		bSecondNoNeedLoop			= NO;
	BOOL		bThirdNoNeedLoop			= YES;
    NSDictionary	*dicCheckMotorStatus	= [dicSetting objectForKey:@"CheckMotorStatus"];
    // change NSMutableDictionary to NSDictionary by Soshon on 2012.05.09
    NSDictionary	*dicFirstCommandInfo	= [NSDictionary dictionaryWithObjectsAndKeys:
											   strPortMobileType,	@"TARGET",
											   strFirstCommand,		@"STRING", nil];
    NSDictionary	*dicSecondCommandInfo	= [NSDictionary dictionaryWithObjectsAndKeys:
											   strPortMobileType,	@"TARGET",
											   strSecondCommand,	@"STRING", nil];
	NSDictionary	*dicThirdCommandInfor	= [NSDictionary dictionaryWithObjectsAndKeys:
											   strPortMobileType,	@"TARGET",
											   strThirdCommand,		@"STRING", nil];
    NSDictionary	*dicProxCommandInfo		= [NSDictionary dictionaryWithObjectsAndKeys:
											   strPortProxSensorType,		@"TARGET",
											   ProxCommand,					@"STRING",
											   [NSNumber numberWithInt:1],	@"HEXSTRING", nil];
    NSDictionary	*dicFixtureCommandInfo	= [NSDictionary dictionaryWithObjectsAndKeys:
											   strPortFixtureType,	@"TARGET",
											   strFLCommand,		@"STRING", nil];
    // end by Soshon
    NSDictionary	*dicReadMobileinfo		= [NSDictionary dictionaryWithObjectsAndKeys:
											   [NSNumber numberWithBool:YES],	@"DELETE_ENTER",
											   @":-)",							@"END",
											   [NSNumber numberWithDouble:0.1],	kFZ_Script_ReceiveInterval,
											   [NSArray arrayWithObject:@":-)"],@"END_SYMBOL",
											   [NSNumber numberWithInt:0],		@"MATCHTYPE",
											   strPortMobileType,				@"TARGET",
											   [NSNumber numberWithInt:5],		@"TIMEOUT", nil];
    NSDictionary	*dicReadProxSensorinfo	= [NSDictionary dictionaryWithObjectsAndKeys:
											   [NSNumber numberWithBool:YES],	@"DELETE_ENTER",
											   [NSNumber numberWithInt:0],		@"MATCHTYPE",
											   [NSNumber numberWithDouble:0.1],	kFZ_Script_ReceiveInterval,
											   strPortProxSensorType,			@"TARGET",
											   [NSArray arrayWithObject:@"Y"],	@"END_SYMBOL",
											   [NSNumber numberWithInt:1],		@"TIMEOUT", nil];
    NSDictionary	*dicProxReadInfo		= [NSDictionary dictionaryWithObject:strProxHasString
																 forKey:@"PROXHASSTRING"];
    long	lMaxValue		= (long)kHallEffect_CaluteDistance_Value * ([strInitValue intValue]);
    long	lRemainTimes	= (strRemainTimes == nil
							   ? 0
							   : [strRemainTimes floatValue]);
    long	lOnceDisTance	= [[[strFLCommand componentsSeparatedByString:@" "]
								lastObject] integerValue];
    lOnceDisTance	= ABS(lOnceDisTance);
    bool	bFirst	= YES,
			bSecond	= YES,
			bThird	= YES;
    if ([dicSetting objectForKey:@"SkipItem"]
		&& [m_muArrayCancelCase count]>0)
    {
        NSArray	*arrSkipItem	= [[dicSetting objectForKey:@"SkipItem"]
								   componentsSeparatedByString:@","];
        if ([arrSkipItem containsObject:@"irq0"])
			bFirstNoNeedloop	= YES;
		if ([arrSkipItem containsObject:@"irq1"])
			bSecondNoNeedLoop	= YES;
        if ([arrSkipItem containsObject:@"irq2"])
			bThirdNoNeedLoop	= YES;
	}
	//add +lOnceDisTance to  make motor move more one time on 2012 05 23 by jingfu ran
    while (tryTimes >= 0
		   && (lMaxValue +lOnceDisTance > lOnceDisTance *lRemainTimes))
    {
		int	iReadProxDataTimes	= iTryReadProxDataTimes;
        if (bFirstNoNeedloop && bSecondNoNeedLoop && bThirdNoNeedLoop) 
            break;
        if (!bFirstNoNeedloop) 
        {
            [self SEND_COMMAND:dicFirstCommandInfo];
            [self READ_COMMAND:dicReadMobileinfo
				  RETURN_VALUE:strReturn];
            if (NSNotFound != [strReturn rangeOfString:strFirstNeedHasString].location) 
            {
				do 
				{
					[self SEND_COMMAND:dicProxCommandInfo];
					usleep(1000);
					[self READ_COMMAND:dicReadProxSensorinfo
						  RETURN_VALUE:strReturn];
					ATSDebug(@"ReadProxData count = %d", iReadProxDataTimes);
					iReadProxDataTimes--;
					bFirst	= [[self GetDistance:dicProxReadInfo
									ReturnValue:strReturn] boolValue];
					
				}while (!bFirst && iReadProxDataTimes >= 0);
				
				//Move GetDistance into the reading loop to avoid incorrect data reading. eg. return digit less than 5
				//[self GetDistance:dicProxReadInfo ReturnValue:strReturn];
				[m_dicMemoryValues setObject:[NSString stringWithString:strReturn]
									  forKey:strFirstStoreInMemoryKey];
				bFirstNoNeedloop	= YES;
            }
        }
        if (!bSecondNoNeedLoop)
        {
            [self SEND_COMMAND:dicSecondCommandInfo];
            [self READ_COMMAND:dicReadMobileinfo
				  RETURN_VALUE:strReturn];
            if (NSNotFound != [strReturn rangeOfString:strSecondNeedHasString].location)
            {
                //modified by jingfu ran on 2012 05 08 to add retest function if read prox length equal or less than 3
                do 
                {
                    [self SEND_COMMAND:dicProxCommandInfo];
                    usleep(1000);
                    [self READ_COMMAND:dicReadProxSensorinfo
						  RETURN_VALUE:strReturn];
                    ATSDebug(@"ReadProxData count = %d", iReadProxDataTimes);
					bSecond	= [[self GetDistance:dicProxReadInfo
									 ReturnValue:strReturn] boolValue];
					iReadProxDataTimes--;
                }while (!bSecond && iReadProxDataTimes >= 0); 
                //Move GetDistance into the reading loop to avoid incorrect data reading. eg. return digit less than 5
                [m_dicMemoryValues setObject:[NSString stringWithString:strReturn]
									  forKey:strSecondStorememoryKey];
                bSecondNoNeedLoop	= YES;
            }
        }
		if (!bThirdNoNeedLoop) 
        {
            [self SEND_COMMAND:dicThirdCommandInfor];
            [self READ_COMMAND:dicReadMobileinfo
				  RETURN_VALUE:strReturn];
			//modified by jingfu ran on 2012 05 08 to add retest function if read prox length equal or less than 3
            if (NSNotFound !=  [strReturn rangeOfString:strThirdNeedHasString].location) 
            {
                do 
                {
                    [self SEND_COMMAND:dicProxCommandInfo];
                    usleep(1000);
                    [self READ_COMMAND:dicReadProxSensorinfo
						  RETURN_VALUE:strReturn];
                    bThird	= [[self GetDistance:dicProxReadInfo
									ReturnValue:strReturn] boolValue];
                    ATSDebug(@"ReadProxData count = %d", iReadProxDataTimes);
					iReadProxDataTimes--;
                }while (!bThird && iReadProxDataTimes >= 0); 
                //Move GetDistance into the reading loop to avoid incorrect data reading. eg. return digit less than 5
				[m_dicMemoryValues setObject:[NSString stringWithString:strReturn]
									  forKey:strThirdStoreMemoryKey];
				bThirdNoNeedLoop	= YES;
            }
        }
        if (!bFirstNoNeedloop || !bSecondNoNeedLoop || !bThirdNoNeedLoop) 
        {
            [self SEND_COMMAND:dicFixtureCommandInfo];
            //CheckMotorStatus after moving 
            if(![[self CheckMotorStatus:dicCheckMotorStatus
							ReturnValue:strReturn] boolValue])
            {
                ATSDebug(@"Motor Status NOT GOOD.");
                [strReturn setString:@"FAIL"];
                return [NSNumber numberWithBool:NO];
            }
            lMaxValue	-= lOnceDisTance;
        }
        tryTimes--;
    }
    if ((tryTimes < 0
		 || (lMaxValue <= lOnceDisTance *lRemainTimes))
		&& !(bFirstNoNeedloop && bSecondNoNeedLoop))
    {
        [strReturn setString:@"FAIL"];
        return [NSNumber numberWithInt:NO];
    }
    // Ignore irq2
    if (bFirst && bSecond)
	{
        [strReturn setString:@"PASS"];
        return [NSNumber numberWithBool:YES];
    }
	else
    {
        [strReturn setString:@"FAIL"];
        return [NSNumber numberWithBool:NO];
    }
}

- (NSNumber *)JudgeMoveDistance:(NSDictionary *)dicSetting
					ReturnValue:(NSMutableString *)strReturn
{
    NSString	*strInitValue	= ([dicSetting valueForKey:@"Target"]
								   ? [dicSetting valueForKey:@"Target"]
								   : @"8");
    float		lValue			= [strReturn floatValue] - [strInitValue floatValue];
    [strReturn setString:[NSString stringWithFormat:@"%0.6f", lValue]];
    return  [NSNumber numberWithBool:YES];
}

- (NSNumber *)CheckDistance:(NSDictionary *)dicSetting
				ReturnValue:(NSMutableString *)strReturn
{
    NSString	*strStep	= ([dicSetting objectForKey:@"Step"]
							   ? [dicSetting objectForKey:@"Step"]
							   : @"1000");
    NSString	*strLength	= ([dicSetting objectForKey:@"Distance"]
							   ? [dicSetting objectForKey:@"Distance"]
							   : @"0.5");
    NSString	*strStepS	= ([dicSetting objectForKey:@"StepS"]
							   ? [dicSetting objectForKey:@"StepS"]
							   : @"500");
    NSString	*strLengthS	= ([dicSetting objectForKey:@"DistanceS"]
							   ? [dicSetting objectForKey:@"DistanceS"]
							   : @"0.25");
    NSDictionary	*dicSendCommand			= [dicSetting objectForKey:@"SEND_COMMAND"];
    NSDictionary	*dicReceiveCommand		= [dicSetting objectForKey:@"READ_COMMAND"];
    NSDictionary	*dicProxSendCommand		= [dicSetting objectForKey:@"PROXSENDCOMMAND"];
    NSDictionary	*dicProxReadCommand		= [dicSetting objectForKey:@"PROXREADCOMMAND"];
    NSDictionary	*dicCheckMotorStatus	= [dicSetting objectForKey:@"CheckMotorStatus"];
    NSString		*strRetryTimes			= ([dicSetting valueForKey:@"TRYTIMES"]
											   ? [dicSetting valueForKey:@"TRYTIMES"]
											   : @"3");
    //Get Initial Distance from Memory key: INITDISTANCE by Shania 2012/05/28
    NSString	*strInitValue	= ([m_dicMemoryValues objectForKey:@"INITDISTANCE"]
								   ? [m_dicMemoryValues objectForKey:@"INITDISTANCE"]
								   : @"8");
    NSString	*strSpec		= ([dicSetting valueForKey:@"Limit"]
								   ? [dicSetting valueForKey:@"Limit"]
								   : @"8,8.25");
    NSString	*strLowLimit,	*strHighLimit;
    //Add limits for initial position  by Shania 2012/5/25
    strLowLimit		= [strSpec SubFrom:@"["
							include:NO];
    strLowLimit		= [strLowLimit SubTo:@","
							  include:NO];
    strHighLimit	= [strSpec SubFrom:@","
							include:NO];
    strHighLimit	= [strHighLimit SubTo:@"]"
							   include:NO];
    float	lValue				= 0;
    int		iReadProxDataTimes	= 3;
    if (dicSendCommand == nil || dicReceiveCommand == nil)
    {
        ATSDebug(@"check your plist, there is no SEND_COMMAND or READ_COMMAND");
        return [NSNumber numberWithBool:NO];
    }
    NSMutableString	*strReturnValue	= [[NSMutableString alloc]
									   initWithString:strReturn];
    int	tryTime	= [strRetryTimes intValue];
    while (tryTime > 0) 
    {
        ATSDebug(@"Start Fine Tune #%d", tryTime);
        iReadProxDataTimes	= 3;
        lValue				= [strReturnValue floatValue] - [strInitValue floatValue];
        //Modify stop loop condition by Shania 2012/5/25
        //Stop Loop when distance is within strLowLimit and strUpLimit
        if([strReturnValue floatValue] >= [strLowLimit floatValue]
		   && [strReturnValue floatValue] <= [strHighLimit floatValue])
        {
            ATSDebug(@"[%@] Already in Spec. Stop moving.", strReturnValue);
            break;
        }
        //Calculate times need to loop to fine tune init position
        //NOTE: strLength setting can not be smaller than delta of strLowLimit and strUpLimit
        //If delta < 1mm, use strLengthS and strStepS
        NSNumber	*numStep;
        int			iMoveTimes	= 0;
        if(ABS(lValue)>1)
		{
            numStep		= [NSNumber numberWithInt:[strStep intValue]];
            iMoveTimes	= ABS(lValue) / ([strLength floatValue]);
        }
        else
        {
            numStep		= [NSNumber numberWithInt:[strStepS intValue]];
            iMoveTimes	= ABS(lValue) / ([strLengthS floatValue]);
        }
        //Judge move Up (positive) or Down (negative)
        if(lValue < 0)
            numStep	= [NSNumber numberWithInt:-[numStep intValue]];
        
        [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%@", numStep]
							  forKey:@"STEP"];
        ATSDebug(@"Going to move %@, %d times", numStep, iMoveTimes);
        //Force it to move at least once in case of the distance is less than 0.25
        if(iMoveTimes == 0)
            iMoveTimes	= 1;
        for (int i = 0; i < iMoveTimes; i++)
        {
            ATSDebug(@"Move #%d, Command: %@", i, dicSendCommand);
            [self SEND_COMMAND:dicSendCommand];
        }
        if ([[self CheckMotorStatus:dicCheckMotorStatus
						ReturnValue:strReturn]boolValue])
        {
            do 
            {
                usleep(100000);
                [self SEND_COMMAND:dicProxSendCommand];
                [self READ_COMMAND:dicProxReadCommand
					  RETURN_VALUE:strReturnValue];
                iReadProxDataTimes--;
            
            }while((![[self GetDistance:dicSetting
							ReturnValue:strReturnValue] boolValue])
				   && iReadProxDataTimes >= 0);
        }
        tryTime--;
    }
    [strReturn setString:strReturnValue];
    //Show limits at csv and UI
    NSDictionary	*dicTheSpec	= [NSDictionary dictionaryWithObject:strSpec
														   forKey:kFZ_Script_JudgeCommonBlack];
    dicTheSpec	= [NSDictionary dictionaryWithObject:dicTheSpec
											 forKey:kFZ_Script_JudgeCommonSpec];
    NSNumber		*numRet		= [self JUDGE_SPEC:dicTheSpec
							 RETURN_VALUE:strReturnValue];
    [strReturnValue release];
    return numRet;
}

- (NSNumber *)CheckMotorStatus:(NSDictionary *)dicSetting
				   ReturnValue:(NSMutableString *)strReturn
{
    NSDictionary	*dicSendCommand		= [dicSetting objectForKey:@"SEND_COMMAND"];
    NSDictionary	*dicReceiveCommand	= [dicSetting objectForKey:@"READ_COMMAND"];
    int				tryCount			= ([dicSetting objectForKey:@"RepeatTime"]
										   ? [[dicSetting objectForKey:@"RepeatTime"]intValue]
										   : 5);
    NSString		*strPassReceive		= ([dicSetting objectForKey:@"ExpectReceive"]
										   ? [dicSetting objectForKey:@"ExpectReceive"]
										   : @"SR=R");
    do
    {
        usleep(100000);
        [self SEND_COMMAND:dicSendCommand];
        [self READ_COMMAND:dicReceiveCommand
			  RETURN_VALUE:strReturn];
        ATSDebug(@"the %d receive command of SR is %@", tryCount, strReturn);
        if(NSNotFound != [strReturn rangeOfString:strPassReceive].location)
            break;
        tryCount--;
    }while (tryCount > 0);   
    if (tryCount < 0)
        return [NSNumber numberWithBool:NO];
    return [NSNumber numberWithBool:YES];
}

-(NSNumber *)READ_FIXTURESN:(NSDictionary *)dicSetting
				ReturnValue:(NSMutableString *)strReturn
{
    NSString	*szPortType			= [dicSetting valueForKey:kFZ_Script_DeviceTarget];
    id			idWantToNumberIndex	= [dicSetting valueForKey:@"ISNUMBERINDEX"];
    NSString	*strChar			= [dicSetting valueForKey:@"SeperateChar"];
    NSString	*strPath			= [[m_dicPorts valueForKey:szPortType]
									   objectAtIndex:kFZ_SerialInfo_SerialPort];
    NSString	*strFixtureSN		= @"";
    if (strPath == nil) 
        return [NSNumber numberWithBool:NO];
    if ([idWantToNumberIndex boolValue]) 
    {
        if (strChar != nil) 
        {
            if (NSNotFound != [strPath rangeOfString:strChar].location) 
            {
                NSArray	*arrayType	= [strPath componentsSeparatedByString:strChar];
                strFixtureSN	= [arrayType lastObject];
            }
			else
                strFixtureSN	= [strPath substringFromIndex:[strPath length] - 2];
        }
		else
            strFixtureSN	= [strPath substringFromIndex:[strPath length] - 2];
    }
	else
		//modified by jingfu ran for avoiding memory leak on 2012 05 02
		strFixtureSN	= [NSString  stringWithString:strFixtureSN];
    [strReturn setString:strFixtureSN];
    return [NSNumber numberWithBool:YES];
}

/*calculate average value of some values that saved in dictionary
 *if value is "NA" or "" ,won't be calculated */
-(NSNumber *)AVERAGE_FORKEYS:(NSDictionary *)dicSetting
				RETURN_VALUE:(NSMutableString *)strReturn
{
    BOOL	bRet	= YES;
    float	fAve	= 0;
    [strReturn setString:@"NA"];
    NSString	*szKeys	= [dicSetting objectForKey:@"KEY"];
    if (szKeys != nil
		&& [szKeys isKindOfClass:[NSString class]])
    {
        NSInteger	iCount		= 0;
        float		fSum		= 0;
        NSArray		*aryKeys	= [szKeys componentsSeparatedByString:@","];
        for (NSString *szKey in aryKeys) 
        {
            if(![szKey isEqualToString:@""]
			   && ![szKey isEqualToString:@" "]
			   && ![szKey isEqualToString:@"NA"]
			   && ![szKey isEqualToString:@"N/A"])
            {
                NSString	*szValue	= [m_dicMemoryValues objectForKey:szKey];
                if (szValue != nil ) 
                {
                    if (![szValue isEqualToString:@""]
						&& ![szValue isEqualToString:@" "]
						&& ![szValue isEqualToString:@"NA"]
						&& ![szValue isEqualToString:@"N/A"]
						&& [szValue intValue] != 0)
                    {
                        iCount++;
                        fSum	+= [szValue floatValue];                            
                    }
                }  
                else
                    bRet	= NO;
            }
        }
        fAve	= fSum / iCount;
        [strReturn setString:[NSString stringWithFormat:@"%.6f", fAve]];
    }
    else
        bRet	= NO;
    return [NSNumber numberWithBool:bRet];
}

- (NSNumber *)CHECKMATRIX:(NSDictionary *)dicSetting
			 RETURN_VALUE:(NSMutableString *)strReturn
{
	BOOL	bRowResult	= YES,
			bColResult	= YES;
	NSUInteger	iCheckRowCount	= [[dicSetting objectForKey:@"RowCount"] intValue];
	NSUInteger	iCheckColCount	= [[dicSetting objectForKey:@"ColCount"] intValue];
	NSArray		*aryRow			= [strReturn componentsSeparatedByString:@"\n"];
	bRowResult	&= ([aryRow count] == iCheckRowCount);
	NSString	*strRowCompare	= (bRowResult
								   ? [NSString stringWithFormat:
									  @"Compare Row OK, row count is [%d]",
									  iCheckRowCount]
								   : [NSString stringWithFormat:
									  @"Compare Row NOT OK, checking count is [%d], actually count is [%d]",
									  iCheckColCount, [aryRow count]]);
    ATSDebug(@"%@", strRowCompare);
	for (NSUInteger i = 0; i < [aryRow count]; i++)
	{
		id		obj		= [aryRow objectAtIndex:i];
		NSArray	*aryCol	= [obj componentsSeparatedByString:@"\t"];
		bColResult		&= ([aryCol count] == iCheckColCount);
		strRowCompare	= (bColResult
						   ? [NSString stringWithFormat:
							  @"Compare Row[%d] OK, Column count is [%d]",
							  i, iCheckColCount]
						   : [NSString stringWithFormat:
							  @"Compare Row[%d] NOT OK, checking count is [%d], actually count is [%d]",
							  i, iCheckColCount, [aryRow count]]);
        ATSDebug(@"%@", strRowCompare);
	}
	return [NSNumber numberWithBool:bRowResult & bColResult];
}

// Get the max value from the given array.
// Note: The given array should be NSNumber type.
// Return: 
//		minimal value
- (float)getMaxValueFromArray:(NSArray *)_SourceArray
{
	NSArray	*sortedArray	= [m_mathLibrary BringOrderToArray:_SourceArray];
	return [[sortedArray lastObject] floatValue];
}

// Get the min value from the given array.
// Note: The given array should be NSNumber type.
// Return: 
//		minimal value
- (float)getMinValueFromArray:(NSArray *)_SourceArray
{
	NSArray	*sortedArray	= [m_mathLibrary BringOrderToArray:_SourceArray];
	return [[sortedArray objectAtIndex:0] floatValue];
}

-(NSNumber *)GETDRAGONFLYDATA:(NSDictionary *)dicParam
				 RETURN_VALUE:(NSMutableString *)strReturnValue
{
    NSMutableArray	*aryOneZone		= [[NSMutableArray alloc] init];
	NSMutableArray	*aryZeroZone	= [[NSMutableArray alloc] init];
    NSString		*strValue		= [m_dicMemoryValues valueForKey:
									   [dicParam objectForKey:@"DISPOSAL"]];
	NSArray			*row			= [strValue componentsSeparatedByString:@"\n"];
    NSMutableArray	*muArray		= [[NSMutableArray alloc]init];
    if ([row count] > 0) 
    {
        //Add object for muArray
        for (NSUInteger i = 0; i < [row count]; i++)
            [muArray addObject:[NSString stringWithFormat:@"%d", i]];
        //Arrange muArray by row number
        for (NSUInteger i = 0; i < [row count]; i++)
        {
            NSString	*strRow		= [row objectAtIndex:i];
            NSArray		*arrTitle	= [strRow componentsSeparatedByString:@"]"];
            if ([arrTitle count] >= 2) 
            {
                NSArray	*number	= [[arrTitle objectAtIndex:0]
								   componentsSeparatedByString:@"row"];
                if ([number count] >= 2) 
                {
                    NSUInteger	inumber	= [[number objectAtIndex:1]intValue];
                    if ([row count] > inumber) 
                    {
                        [muArray removeObjectAtIndex:inumber];
                        [muArray insertObject:[arrTitle objectAtIndex:1]
									  atIndex:inumber];
                    }
                }
            }
            else
            {
                //modified by Chao for avoiding memory leak on 2012 05 02
                [aryOneZone release];
                [aryZeroZone release];
                [muArray release];
                return [NSNumber numberWithBool:NO];
            }
        }
        for (NSUInteger i = 0; i < [muArray count]; i++)
        {
            NSString	*strRow	= [muArray objectAtIndex:i];
            NSArray		*column	= [strRow componentsSeparatedByString:@"\t"];
            // The first column is title like [rowXX], it not useful data.
            for (NSUInteger j = 1; j < [column count]; j++)
            {
                // the data rectangle width is larger than height
                if ([column count] - 1 < [muArray count])
                {
                    // useful data count is "[column count]-1"
                    if ((abs(i-(j-1)))%([column count]-1)==0)
                        [aryOneZone addObject:[NSNumber numberWithFloat:
											   [[column objectAtIndex:j] floatValue]]];
                    else
                        [aryZeroZone addObject:[NSNumber numberWithFloat:
												[[column objectAtIndex:j] floatValue]]];
                }
                // the data rectangle widt is smaller than height
                else 
                {
                    if ((abs(j-1-i))%([row count])==0)
                        [aryOneZone addObject:[NSNumber numberWithFloat:
											   [[column objectAtIndex:j] floatValue]]];
                    else
                        [aryZeroZone addObject:[NSNumber numberWithFloat:
												[[column objectAtIndex:j] floatValue]]];
                }
            }
        }
        if ([aryZeroZone count] && [aryOneZone count]) 
        {
            float	maxZero	= [self getMaxValueFromArray:aryZeroZone];
            float	minZero	= [self getMinValueFromArray:aryZeroZone];
            float	aveZero	= (float)[m_mathLibrary GetAverageWithArray:aryZeroZone
															  NeedABS:NO];
            float	maxOne	= [self getMaxValueFromArray:aryOneZone];
            float	minOne	= [self getMinValueFromArray:aryOneZone];
            float	aveOne	= (float)[m_mathLibrary GetAverageWithArray:aryOneZone
															 NeedABS:NO];
            [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%.2f", maxZero]
								  forKey:[dicParam objectForKey:@"ZeroPtMax"]];
            [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%.2f", minZero]
								  forKey:[dicParam objectForKey:@"ZeroPtMin"]];
            [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%.2f", aveZero]
								  forKey:[dicParam objectForKey:@"ZeroPtAve"]];
            [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%.2f", maxOne]
								  forKey:[dicParam objectForKey:@"OnePtMax"]];
            [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%.2f", minOne]
								  forKey:[dicParam objectForKey:@"OnePtMin"]];
            [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%.2f", aveOne]
								  forKey:[dicParam objectForKey:@"OnePtAve"]];
        }
        else
        {
            //modified by Chao for avoiding memory leak on 2012 05 02
            [aryOneZone release];
            [aryZeroZone release];
            [muArray release];
            return [NSNumber numberWithBool:NO];
        }
    }
    else
    {
        //modified by Chao for avoiding memory leak on 2012 05 02
        [aryOneZone release];
        [aryZeroZone release];
        [muArray release];
        return [NSNumber numberWithBool:NO];
    }
    [aryOneZone release];
	[aryZeroZone release];
    [muArray release];
    return [NSNumber numberWithBool:YES];
}

-(NSNumber *)JudgeProxSensorData:(NSDictionary*)dicSetting
					return_Value:(NSMutableString *)strReturn
{
    if ([strReturn length] <= 3) 
        return [NSNumber numberWithBool:NO];  
    NSString	*strHasString	= (![dicSetting valueForKey:@"PROXHASSTRING"]
								   ? @"0x81 0x6 0x59"
								   : [dicSetting valueForKey:@"PROXHASSTRING"]);
    NSMutableString	*strValue	= [[NSMutableString alloc] initWithString:@""];
    for (int i = 0; i < [strReturn length]; i++) 
        [strValue appendFormat:
		 @" 0x%X", (unsigned char)[strReturn characterAtIndex:i]];
    [strValue setString:[strValue substringFromIndex:1]];
    ATSDebug(@"Prox data = %@\n length = %d\n",
			 strValue, [strReturn length]);
    NSRange	range	= [strValue rangeOfString:strHasString];
    if (NSNotFound != range.location) 
        [strReturn setString:[strValue substringFromIndex:range.location]];
    else
    {
        [strValue release];
        return [NSNumber numberWithBool:NO];
    }
    [strValue release];
    return [NSNumber numberWithBool:YES];
}

-(float)absFloat:(float)value
{
    if (value <= 0) 
        value	= -value;
    return value;
}

-(NSNumber *)RemoveToPosition:(NSDictionary *)dicSetting
				 Return_Value:(NSMutableString *)strReturn
{
    NSString	*strFixtureTarget		= [dicSetting valueForKey:@"FIXTURETARGET"];
    NSString	*strProxSensorTarget	= [dicSetting valueForKey:@"PROXSENSORTARGET"];
    NSString	*strFixCommand			= [dicSetting valueForKey:@"COMMAND"];
    NSString	*strProxHasString		= [dicSetting valueForKey:@"PROXHASSTRING"];
    NSString	*strTryMaxTimes			= (![dicSetting valueForKey:@"MAXTIMES"]
										   ? @"500"
										   : [dicSetting valueForKey:@"MAXTIMES"]);
    //modified by jingfu ran for avoid extra operator and tranform NSData to as command as ken's advice
    id			ProxCommand				= [dicSetting valueForKey:@"PROXCOMMAND"];
    NSString	*strCalValue			= (![dicSetting valueForKey:@"CALVALUE"]
										   ? @"82"
										   : [dicSetting valueForKey:@"CALVALUE"]);
    NSDictionary	*dicProxReadInfo	= [NSDictionary dictionaryWithObject:strProxHasString
																forKey:@"PROXHASSTRING"];
    NSDictionary	*dicFixtureCommandInfo	= [NSDictionary dictionaryWithObjectsAndKeys:
											   strFixtureTarget,	@"TARGET",
											   strFixCommand,		@"STRING", nil];
    NSDictionary	*dicFixtureSubCommndInfo	= [NSDictionary dictionaryWithObjectsAndKeys:
												   strFixtureTarget,	@"TARGET",
												   @"FL -100",			@"STRING", nil];
    NSDictionary	*dicReadProxSensorinfo	= [NSDictionary dictionaryWithObjectsAndKeys:
											   [NSNumber numberWithBool:YES],	@"DELETE_ENTER",
											   [NSNumber numberWithInt:0],		@"MATCHTYPE",
											   strProxSensorTarget,				@"TARGET",
											   [NSArray arrayWithObject:@"Y"],	@"END_SYMBOL",
											   [NSNumber numberWithInt:1],		@"TIMEOUT", nil];
    NSDictionary	*dicProxCommandInfo	= [NSDictionary dictionaryWithObjectsAndKeys:
										   strProxSensorTarget,			@"TARGET",
										   ProxCommand,					@"STRING",
										   [NSNumber numberWithInt:1],	@"HEXSTRING", nil];
    float	a[3]		= {0};
    int		i			= 0;
    int		iMaxTimes	= [strTryMaxTimes intValue];
    NSMutableString	*strResponse	= [[NSMutableString alloc] init];
    while (1) 
    {
        //add by jingfu ran to avoid  endless loop
        if (iMaxTimes <= 0) 
        { 
            [strResponse release];
            [strReturn setString:[NSString  stringWithFormat:
								  @"a[0]:%.6f a[1]: %.6f a[2]:%f",
								  a[0], a[1], a[2]]];
            return [NSNumber numberWithBool:NO];
        }
        iMaxTimes--;
        [self SEND_COMMAND:dicFixtureCommandInfo];
        [self SEND_COMMAND:dicProxCommandInfo];
        [self READ_COMMAND:dicReadProxSensorinfo
			  RETURN_VALUE:strResponse];
        if (![self JudgeProxSensorData:dicProxReadInfo
						  return_Value:strResponse])
        {
            [self SEND_COMMAND:dicFixtureSubCommndInfo];
            continue;
        }
		else
            [self GetDistance:nil
				  ReturnValue:strResponse];
        a[i]	= [strResponse floatValue] + [strCalValue floatValue];
        i++;
        i		= i% 3;
        if (a[0] == 0 || a[1] == 0 || a[2] == 0) 
            continue;
        if ((a[1] > a[0]+0.03) && (a[2] > a[1]+0.03))
			;
		else
        {
            if (([self absFloat:a[1] - a[0]] < 0.03)
				&& ([self absFloat:(a[2]-a[1])] < 0.03))
                 break;
            else
                continue;
        }
    }
    [strResponse release];
    [strReturn setString:[NSString  stringWithFormat:
						  @"a[0]:%.6f a[1]: %.6f a[2]:%f",
						  a[0], a[1], a[2]]];
    return [NSNumber numberWithBool:YES];
}

/* Fixture move to top */
-(NSNumber *)MOVE_TOP:(NSDictionary *)dicSetting
		 RETURN_VALUE:(NSMutableString *)strReturn
{
    NSDictionary	*dicSendFL		= [dicSetting objectForKey:@"1.SEND_COMMAND:"];
    NSDictionary	*dicReadFL		= [dicSetting objectForKey:@"2.READ_COMMAND:RETURN_VALUE:"];
    NSDictionary	*dicCheckStatus	= [dicSetting objectForKey:@"3.CheckMotorStatus:ReturnValue:"];
    NSDictionary	*dicSendProx	= [dicSetting objectForKey:@"4.SEND_COMMAND:"];
    NSDictionary	*dicReadProx	= [dicSetting objectForKey:@"5.READ_COMMAND:RETURN_VALUE:"];
    NSDictionary	*dicGetDistance	= [dicSetting objectForKey:@"6.GetDistance:ReturnValue:"];
    double			dTimeout		= [[dicSetting objectForKey:@"TIME_OUT"] doubleValue];
    float			fSpec			= [[dicSetting objectForKey:@"ABS_SPEC"] floatValue];
    BOOL			bRet			= YES; 
    float			fPreLastDistance	= 0;
    float			fLastDistance		= 0;
    float			fCurrentDistance	= 0;
    NSString		*szFirstValue	= @"";
    NSString		*szPreLastValue	= @"";
    NSString		*szLastValue	= @"";
    NSString		*szCurrentValue	= @"";
    NSDate			*dtStartTime	= [NSDate date];
    NSTimeInterval	dEndTime		= 0.0;
    do
	{
        bRet	= [[self SEND_COMMAND:dicSendFL] boolValue];
        bRet	&= [[self READ_COMMAND:dicReadFL
					   RETURN_VALUE:strReturn] boolValue];
        bRet	&= [[self CheckMotorStatus:dicCheckStatus
							ReturnValue:strReturn] boolValue];
        bRet	&= [[self SEND_COMMAND:dicSendProx] boolValue];
        bRet	&= [[self READ_COMMAND:dicReadProx
					   RETURN_VALUE:strReturn] boolValue];
        bRet	&= [[self GetDistance:dicGetDistance
					   ReturnValue:strReturn] boolValue];
        if (bRet) 
        {
            szFirstValue	= [NSString stringWithString:szPreLastValue];
            szPreLastValue	= [NSString stringWithString:szLastValue];
            szLastValue		= [NSString stringWithString:szCurrentValue];
            szCurrentValue	= [NSString stringWithString:strReturn];
            fPreLastDistance	= [szPreLastValue floatValue] - [szFirstValue floatValue];
            fLastDistance		= [szLastValue floatValue] - [szPreLastValue floatValue];
            fCurrentDistance	= [szCurrentValue floatValue] - [szLastValue floatValue];
            if (fabs(fPreLastDistance)<fSpec
				&& fabs(fLastDistance)<fSpec
				&& fabs(fCurrentDistance)<fSpec)
                break;
        }
        usleep(10);
        dEndTime	= [[NSDate date] timeIntervalSinceDate:dtStartTime];
    } while (dTimeout >= dEndTime);
    if (dEndTime > dTimeout) 
        return [NSNumber numberWithBool:NO];
    return [NSNumber numberWithBool:YES];
}

- (NSNumber *)JUDGESPEC_CSV_UPLOADPARAMETRIC:(NSDictionary  *)dicPara
								RETURN_VALUE:(NSMutableString*)szReturnValue
{
    // get the data and spec
    NSString        *szSpec		= [dicPara objectForKey:@"SPEC"];
    // return value
    NSNumber        *retNum		= [NSNumber numberWithBool:YES];
    // for parametic data
    NSString        *szParaName	= [dicPara objectForKey:@"PARANAME"];
    NSString        *szLowLimits,
					*szHighLimits,
					*szParamatricData;
    NSMutableString	*strMuData	= [NSMutableString stringWithString:
								   [m_dicMemoryValues objectForKey:
									[dicPara objectForKey:@"STRDATA"]]];
    if (strMuData != nil)
    {
        NSDictionary	*dicTheSpec	= [NSDictionary dictionaryWithObject:szSpec
															   forKey:kFZ_Script_JudgeCommonBlack];
        dicTheSpec	= [NSDictionary dictionaryWithObject:dicTheSpec
												 forKey:kFZ_Script_JudgeCommonSpec];
        if (![[self JUDGE_SPEC:dicTheSpec
				  RETURN_VALUE:strMuData] boolValue])
        {
            [szReturnValue setString:[NSString stringWithFormat:
									  @"The value %@ is not in the spec %@",
									  strMuData, szSpec]];
            ATSDebug(@"szReturn value %@", szReturnValue);
            retNum	= [NSNumber numberWithBool:NO];
        }
        [m_dicMemoryValues setObject:@"{NA}"
							  forKey:kFZ_TestLimit];
        // upload paramatric data
        szLowLimits		= [szSpec SubFrom:@"["
							   include:NO];
        szLowLimits		= [szLowLimits SubTo:@","
								  include:NO];
        szHighLimits	= [szSpec SubFrom:@","
							   include:NO];
        szHighLimits	= [szHighLimits SubTo:@"]"
								   include:NO];
        // creat the parametric name
        szParamatricData	= [NSString stringWithFormat:@"%@", szParaName, nil];
        NSDictionary	*dicUpload	= [NSDictionary dictionaryWithObjectsAndKeys:
									   szLowLimits,			kFZ_Script_ParamLowLimit,
									   szHighLimits,		kFZ_SCript_ParamHighLimit,
									   szParamatricData,	kFZ_Script_UploadParametric,
									   [NSNumber numberWithBool:NO],	kFunnyZoneNOWriteCsvToLogFile, nil];
        [self UPLOAD_PARAMETRIC:dicUpload
				   RETURN_VALUE:strMuData];
    }
    // loop to judge spec and upload parametric data
    return retNum;
}

- (NSNumber *)CatchWIFISN:(NSDictionary  *)dicPara
			 RETURN_VALUE:(NSMutableString*)szReturnValue
{
    NSString		*szReturn;
    NSMutableString	*strValue		= [[NSMutableString alloc]init];
    NSMutableArray	*arrValue		= [[NSMutableArray alloc]init];
    
    NSString		*szKey			= [dicPara objectForKey:kFZ_Script_MemoryKey];
    NSString		*szCatchedValue	= [m_dicMemoryValues objectForKey:szKey];
    int				iStart			= ([[dicPara objectForKey:@"START"] intValue]
									   ? [[dicPara objectForKey:@"START"] intValue]
									   : 2);
    int				iStep			= ([[dicPara objectForKey:@"STEP"]intValue]
									   ? [[dicPara objectForKey:@"STEP"]intValue]
									   : 16);
    if(nil == szCatchedValue)
    {
        szReturn	= @"Value not found";
        [szReturnValue setString:szReturn];
        [arrValue release];
        [strValue release];
        return [NSNumber numberWithBool:NO];
    }
    else if([szCatchedValue ContainString:@"RX ["])
    {
        szReturn	= @"no response";
        [szReturnValue setString:szReturn];
        [arrValue release];
        [strValue release];
        return [NSNumber numberWithBool:NO];
    }
    else if([szCatchedValue ContainString:@"ERROR"])
    {
        [szReturnValue setString:szCatchedValue];
        [arrValue release];
        [strValue release];
        return [NSNumber numberWithBool:NO];
    }
    else
        szReturn	= [szCatchedValue stringByReplacingOccurrencesOfString:@"\r"
															 withString:@""];
    NSArray	*arrRow	= [szReturn componentsSeparatedByString:@"\n"];
    for (int i = 0; i < [arrRow count]; i++) 
    {
        NSArray	*arrTemp	= [[arrRow objectAtIndex:i]
							   componentsSeparatedByString:@" "];
        for (int j = 1; j < iStep +1; j++) 
            [arrValue addObject:[arrTemp objectAtIndex:j]];
    }
    NSString		*szLocation	= [arrValue objectAtIndex:iStart-1];
    unsigned int	iLocation	= 0;
    NSScanner		*scan		= [NSScanner scannerWithString:szLocation];
    [scan scanHexInt:&iLocation];
    iLocation	= iLocation + iStart;
    if ([[arrValue objectAtIndex:iLocation-1] isNotEqualTo:@"FF"]) 
    {
        [szReturnValue setString:@"Compare FF FAIL"];
        [arrValue release];
        [strValue release];
        return [NSNumber numberWithBool:NO];
    }
    NSString		*szLength	= [arrValue objectAtIndex:iLocation + 1];
    unsigned int	iLength		= 0;
    scan	= [NSScanner scannerWithString:szLength];
    [scan scanHexInt:&iLength];
    [strValue setString:@""];
    iLocation	+= 4;
    NSString		*szWIFISNLength	= [arrValue objectAtIndex:iLocation];
    unsigned int	iWIFISNLength	= 0;
    scan	= [NSScanner scannerWithString:szWIFISNLength];
    [scan scanHexInt:&iWIFISNLength];
    if (iLength != iWIFISNLength + 3)
	{
        [szReturnValue setString:@"WIFI SN length is error!"];
        [arrValue release];
        [strValue release];
        return [NSNumber numberWithBool:NO];
    }
    iLocation	= iLocation + 1;
    for (int i = iLocation; i < iLocation + iWIFISNLength; i++)
    {
        [strValue appendString:[arrValue objectAtIndex:i]];
        if (i != iLocation + iWIFISNLength-1)
            [strValue appendString:@" "];
    }
    [szReturnValue setString:strValue];
    [arrValue release];
    [strValue release];
    return [NSNumber numberWithBool:YES];
}
/* Chao 2012.9.25
 * method   : AVERAGE_PROX_MEAN:RETURN_VALUE:
 * abstract : get ave value from PROX data */
- (NSNumber *)AVERAGE_PROX_MEAN:(NSDictionary *)dicSetting
				   RETURN_VALUE:(NSMutableString*)szReturnValue
{
    int		iProxCount	= 0;
    float	fProxSum	= 0.00;
	NSString	*strProxData	= szReturnValue;
	strProxData	= [strProxData stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	strProxData	= [strProxData stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    NSArray	*arrayProx	= [strProxData componentsSeparatedByString:@"PROX:"];
    if ([arrayProx count] < 3)
    {
        ATSDebug(@"PROX Data error!");
		[szReturnValue setString:@"PROX Data error"];
        return [NSNumber numberWithBool:NO];
    }
    for(NSString *szTemp in arrayProx)
    {
        if (![szTemp isKindOfClass:[NSString class]])
            continue;
		
        if ([szTemp ContainString:@"RAW: "])
        {
            szTemp	= [szTemp SubFrom:@"RAW: "
							 include:NO];
            NSScanner		*scan	= [NSScanner scannerWithString:szTemp];
            unsigned int	iValue	= 0;
            [scan scanHexInt:&iValue];
            iProxCount++;
            fProxSum	+= iValue;
        }
		
    }
	
    if (iProxCount)
	{
		[szReturnValue	setString:[NSString stringWithFormat:@"%.2f",fProxSum / iProxCount]];
	}
    else
    {
        ATSDebug(@"data count is 0 !");
		[szReturnValue setString:@"data count is 0 !"];
		return [NSNumber numberWithBool:NO];
    }
    return [NSNumber numberWithBool:YES];
}

/****************************************************************************************************
 Start 2012.10.17 Add by Yaya
 Descripton: replace the "x" and "0x" to "", and add it to array.
 Param:
 NSMutableString *strReturnValue : the data need to deal with.
 sample: 
 szReturnValue: 0xA1 0xC2 0xFE 0x9 0x6 0x54 0x5 0x0 0x0 0x0 0x0 0x0 0x0 0x0 0x0
step1: replace the "0x" or "x" to "". then we will get a array which include those data.
step2: combine the data which you want, for example begin is 2, end is 3, you will get the data "FE09".
 ****************************************************************************************************/
- (NSNumber *)CombineHEXData:(NSDictionary*)dicSetting
                 RETURN_VALUE:(NSMutableString*)szReturnValue
{
    int     Ibegin          = [[dicSetting objectForKey:@"BeginIndex"] intValue];
    int     iEnd            = [[dicSetting objectForKey:@"EndIndex"] intValue];
	BOOL    bNoDeleteString = [[dicSetting objectForKey:@"NoDeleteString"] boolValue];
    BOOL    bNeedTransferToDec  = [[dicSetting objectForKey:@"NeedTransferToDec"] boolValue];
    BOOL    bFlip           = [[dicSetting objectForKey:@"NeedFlip"] boolValue];
    // Get the value.
	NSString	*szKey          = [dicSetting objectForKey:kFZ_Script_MemoryKey];
    NSString    *szCatchedValue = [m_dicMemoryValues objectForKey:szKey];
    NSString    *szSeparate     = [dicSetting objectForKey:@"SeparateString"] ?
    [dicSetting objectForKey:@"SeparateString"] : [NSString stringWithFormat:@" "];
    if(!szCatchedValue)
    {
        szCatchedValue	= szReturnValue;
        
        if (!szReturnValue || [szReturnValue isEqualToString:nil])
        {
            [szReturnValue setString:@"Value not found in szReturnValue."];
            return [NSNumber numberWithBool:NO];
        }
    }
    
    szCatchedValue	= [szCatchedValue stringByReplacingOccurrencesOfString:@"\r"
														 withString:@""];
    szCatchedValue  = [szCatchedValue stringByReplacingOccurrencesOfString:@"\n"
                                                                withString:@""];
    NSArray			*arrCell	= [szCatchedValue componentsSeparatedByString:szSeparate];
    
    NSMutableArray	*aryTemp	= [[NSMutableArray alloc] init];
    NSMutableArray	*arrBits	= [[NSMutableArray alloc] initWithArray:arrCell];
    for (int iIndex = 0; iIndex < [arrBits count]; iIndex ++)
    {
        if (!bNoDeleteString)
        {
            NSString	*szValue	= (([[arrBits objectAtIndex:iIndex] length] == 4)
                                       ? [[arrBits objectAtIndex:iIndex]
                                          stringByReplacingOccurrencesOfString:@"0x"
                                          withString:@""]
                                       : [[arrBits objectAtIndex:iIndex]
                                          stringByReplacingOccurrencesOfString:@"x"
                                          withString:@""]);
            if ([szValue length] <2)
                szValue = [NSString stringWithFormat:@"0%@",szValue];
            if([szValue length] > 4)
            {
                [arrBits removeObjectAtIndex:iIndex];
                continue;
            }
            [aryTemp addObject:szValue];
        }
        else
        {
            [aryTemp addObject:[arrBits objectAtIndex:iIndex]];
        }
        
    }
    [arrBits release];
    
    //combine the vaule which you want.
    [szReturnValue setString:@""];
    if ([dicSetting objectForKey:@"BeginIndex"] == nil
		&& [dicSetting objectForKey:@"EndIndex"] == nil)
    {
        for (int i =0; i <= [aryTemp count] -1; i++)
            [szReturnValue appendString:[NSString stringWithFormat:@"%@",
										  [aryTemp objectAtIndex:i]]];
        
    }
    else if (([dicSetting objectForKey:@"BeginIndex"] == nil) && iEnd < [aryTemp count])
    {
        for (int i =0; i <=iEnd; i++)
            [szReturnValue appendString:[NSString stringWithFormat:@"%@",
										  [aryTemp objectAtIndex:i]]];
    }
    else if (([dicSetting objectForKey:@"EndIndex"] == nil) && Ibegin < [aryTemp count])
    {
        for (int i =Ibegin; i <=[aryTemp count] -1; i++)
            [szReturnValue appendString:[NSString stringWithFormat:@"%@",
										  [aryTemp objectAtIndex:i]]];
    }
    else if ((iEnd==Ibegin) && (Ibegin < [aryTemp count]))
    {
        [szReturnValue appendString:[aryTemp objectAtIndex:Ibegin]];
        ATSDebug(@"The value is %@", szReturnValue);
    }
    else if ((Ibegin < iEnd) && (iEnd < [aryTemp count]))
    {
        //Modify by yaya, add flip. 20150527.
        if (bFlip && (iEnd - Ibegin+1 == 2))
        {
            if (!bNoDeleteString)
                [szReturnValue appendString:[NSString stringWithFormat:@"%@%@",
                                             [aryTemp objectAtIndex:iEnd],[aryTemp objectAtIndex:Ibegin]]];
            else
                [szReturnValue appendString:[NSString stringWithFormat:@"%@ %@",
                                             [aryTemp objectAtIndex:iEnd],[aryTemp objectAtIndex:Ibegin]]];

        }else
        {
            for (int i =Ibegin; i <=iEnd; i++)
            {
                if (!bNoDeleteString)
                    [szReturnValue appendString:[NSString stringWithFormat:@"%@",
                                                 [aryTemp objectAtIndex:i]]];
                else
                    [szReturnValue appendString:[NSString stringWithFormat:@"%@ ",
                                                 [aryTemp objectAtIndex:i]]];
                
            }
        }
    }
    else
    {
        ATSDebug(@"Invaild index,please check it!");
		[aryTemp release];	aryTemp	= nil;
        return [NSNumber numberWithBool:NO];
    }
    
    //transfet to dec.
    if (bNeedTransferToDec)
    {
        // Transfer from HEX to DEC
        NSScanner *scanner = [[NSScanner alloc]initWithString:[NSString stringWithFormat:@"0x%@", szReturnValue]];
        unsigned long long iDec = 0;
        BOOL iRet   = [scanner scanHexLongLong:&iDec];
        if (iRet)
        {
            [szReturnValue setString:[NSString stringWithFormat:@"%llu",iDec]];
        }
        [scanner release];
    }
    
    [aryTemp release];	aryTemp	= nil;
    return [NSNumber numberWithBool:YES];
}


/* Add by Jean
		NSDictionary			*dictSettings   : Settings
				SeparateString	->	NSString		: " ", "/n", "," ...
				AddString		->	NSString		: 0x
				AddBefore		->	Boolean			: YES/NO
				BeginIndex		->	NSNumber		: begin index	//0,1,2,...
				EndIndex		->	NSNumber		: end index
 eg: "AA BB CC DD"  --> "0xAABBCCDD"
*/
- (NSNumber *)CUSTOM_COMBINE_DATA:(NSDictionary *)dicSetting
					 RETURN_VALUE:(NSMutableString *)szReturnValue
{
	//If the setting dictionary has no parameters, post a alert panel.
	if (!dicSetting || [dicSetting count] == 0) {
		NSRunAlertPanel([NSString stringWithFormat:@"警告(Warning)"],
						@"CUSTOM_COMBINE_DATA:RETURN_VALUE:没有参数。(There are no parameters for CUSTOM_COMBINE_DATA!)",
						@"确认(OK)", nil, nil);
		return [NSNumber numberWithBool:NO];
	}
	
	//Input string and output string
	NSString *strInput = [m_dicMemoryValues objectForKey:[dicSetting objectForKey:@"KEY"]];
	NSMutableString *strOutput = [NSMutableString stringWithString:@""];
	
	//Related params
	NSString	*strSeparateString = [dicSetting objectForKey:@"SeparateString"];
	NSArray		*arySeparate		= [strInput componentsSeparatedByString:strSeparateString];
	NSString	*strAddString		= [dicSetting objectForKey:@"AddString"];
	strAddString	= (strAddString ? strAddString : @"");
	
	BOOL		bAddBefore		= ([dicSetting objectForKey:@"AddBefore"]
								   ? [[dicSetting objectForKey:@"AddBefore"] boolValue] : YES);
	int			iBeginIndex		= ([dicSetting objectForKey:@"BeginIndex"]
								   ? [[dicSetting objectForKey:@"BeginIndex"] intValue] : 0);
	int			iEndIndex		= ([dicSetting objectForKey:@"EndIndex"]
								   ? [[dicSetting objectForKey:@"EndIndex"] intValue] : [arySeparate count]-1);
	//Combine
	if ([arySeparate count] > 0)
	{
		if (iBeginIndex >= 0 && iEndIndex < [arySeparate count] && iBeginIndex <= iEndIndex)
		{
			for (int i = iBeginIndex; i <= iEndIndex; i++)
			{
				[strOutput appendFormat:@"%@", [arySeparate objectAtIndex:i]];
			}
		}
	}
	//Add string
	if (bAddBefore)
	{
		[szReturnValue setString:[NSString stringWithFormat:@"%@%@", strAddString, strOutput]];
	}
	else
	{
		[szReturnValue setString:strOutput];
	}
		
	return [NSNumber numberWithBool:YES];
}



/* Add by Jean
 NSDictionary			*dictSettings   : Settings
 SeparateString	->	NSString		: " ", "/n", "," ...
 BeginIndex		->	NSNumber		: begin index	//0,1,2,...
 EndIndex		->	NSNumber		: end index
 */
- (NSNumber *)CALCULATE_LCM_SN:(NSDictionary *)dicSetting
				  RETURN_VALUE:(NSMutableString *)strReturnValue
{
	//If the setting dictionary has no parameters, post a alert panel.
	if (!dicSetting || [dicSetting count] == 0) {
		NSRunAlertPanel([NSString stringWithFormat:@"警告(Warning)"],
						@"CALCULATE_LCM_SN:RETURN_VALUE:没有参数。(There are no parameters for CALCULATE_LCM_SN!)",
						@"确认(OK)", nil, nil);
		return [NSNumber numberWithBool:NO];
	}
	
	//Input string and output string
	NSString *strInput = [m_dicMemoryValues objectForKey:[dicSetting objectForKey:@"KEY"]];
	NSMutableString *strOutput = [NSMutableString stringWithString:@""];
	
	if ([dicSetting objectForKey:@"SeperateString"] == nil
		|| [[dicSetting objectForKey:@"SeperateString"] isEqualToString:@""])
	{
		ATSDebug(@"The SeperateString string is nil or null.");
		return [NSNumber numberWithBool:NO];
	}
	
	// Get the setting value
	NSString	*strSeparateString	= [dicSetting objectForKey:@"SeperateString"];
	NSArray		*aryContent			= [strInput componentsSeparatedByString:strSeparateString];
	
	int			iBeginIndex		= ([dicSetting objectForKey:@"BeginIndex"]
								   ? [[dicSetting objectForKey:@"BeginIndex"] intValue] : 0);
	int			iEndIndex		= ([dicSetting objectForKey:@"EndIndex"]
								   ? [[dicSetting objectForKey:@"EndIndex"] intValue] : [aryContent count]-1);
	
	NSDictionary	*dicTransform = [dicSetting objectForKey:@"Transform"];
	
	//Combine
	if ([aryContent count] > 0)
	{
		if (iBeginIndex >= 0 && iEndIndex < [aryContent count] && iBeginIndex <= iEndIndex)
		{
			for (int i = iBeginIndex; i <= iEndIndex; i++)
			{
				if (dicTransform!=nil)
				{
					[strReturnValue setString:[aryContent objectAtIndex:i]];
					[self NumberSystemConvertion:dicTransform
									RETURN_VALUE:strReturnValue];
				}
				else
				{
					ATSDebug(@"No transform parameters.");
				}
				[strOutput appendFormat:@"%@", [NSString stringWithFormat:@"%c", [strReturnValue intValue]]];
			}
			ATSDebug(@"The LCM SN value from diags: %@", strOutput);
		}
	}
	
	[strReturnValue setString:strOutput];
	
	return [NSNumber numberWithBool:YES];
}



- (NSNumber*)CATCH_VALUE_BY_INDEX:(NSDictionary *)dicSetting
					 RETURN_VALUE:(NSMutableString *)strReturnValue
{
	//If the setting dictionary has no parameters, post a alert panel.
	if (!dicSetting || [dicSetting count] == 0) {
		NSRunAlertPanel([NSString stringWithFormat:@"警告(Warning)"],
						@"CATCH_VALUE_BY_INDEX:RETURN_VALUE:没有参数。(There are no parameters for CATCH_VALUE_BY_INDEX!)",
						@"确认(OK)", nil, nil);
		return [NSNumber numberWithBool:NO];
	}
	
	//Input string
	NSString		*strInput		= [m_dicMemoryValues objectForKey:[dicSetting objectForKey:@"KEY"]];
    if ((strInput == nil || [strInput isEqualTo:@""])
        && [[dicSetting objectForKey:@"KEY"] isEqualTo:@"config"])
    {
        return [NSNumber numberWithBool:YES];
    }
    
	if ([[strInput lowercaseString] ContainString:@"not found"] ||
		[[strInput lowercaseString] ContainString:@"error"] ||
		[[strInput lowercaseString] ContainString:@"fail"])
	{
		return [NSNumber numberWithBool:NO];
	}
	
	
	NSString		*strSeparate	= [dicSetting objectForKey:@"SeperateString"];
	NSArray			*arySeparate	= [strInput componentsSeparatedByString:strSeparate];
	
	int				iIndex			= [[dicSetting objectForKey:@"Index"] intValue];	
	if (iIndex < 0 || iIndex > [arySeparate count]-1)
	{
		ATSDebug(@"CATCH_VALUE_BY_INDEX:RETURN_VALUE: The param Index ERROR.");
		return [NSNumber numberWithBool:NO];
	}
	
    [strReturnValue setString:[arySeparate objectAtIndex:iIndex]];
	
	return [NSNumber numberWithBool:YES];
}


/* Chao 2012.10.17
 * method   : CALCULATERESULT:RETURN_VALUE:
 * abstract : get total result value from sub items */
- (NSNumber *)CALCULATERESULT:(NSDictionary *)dicSetting
                 RETURN_VALUE:(NSMutableString*)szReturnValue
{
	NSString	*strResultKey	= [dicSetting objectForKey:@"TESTITEM"];
	BOOL		bCalculate		= [[dicSetting objectForKey:@"CALCULATE"]boolValue];
	BOOL		bCompare		= [[dicSetting objectForKey:@"COMPARE"]boolValue];
	BOOL		bChangeResult	= [[dicSetting objectForKey:@"CHANGERESULT"] boolValue];
	int			iResultValue	= [[dicSetting objectForKey:@"RESULTVALUE"]intValue];
	int			iCurrentValue	= [[m_dicMemoryValues objectForKey:strResultKey] intValue];
	if (![m_dicMemoryValues objectForKey:strResultKey])
	{
		iCurrentValue	= 0;
		[m_dicMemoryValues setValue:[NSNumber numberWithInt:iCurrentValue] forKey:strResultKey];
	}
	if (bCalculate && m_bSubTest_PASS_FAIL)
	{
		iCurrentValue++;
		[m_dicMemoryValues setValue:[NSNumber numberWithInt:iCurrentValue] forKey:strResultKey];
	}
	if (bCompare && iCurrentValue != iResultValue)
	{
        
		if (bChangeResult)
		{
			[szReturnValue setString:@"FAIL"];
		}
        
		return [NSNumber numberWithBool:NO];
		
	}
	
	if (bChangeResult)
	{
		[szReturnValue setString:@"PASS"];
	}
	return [NSNumber numberWithBool:YES];
    
}

- (NSNumber *)SAVE_PLIST:(NSDictionary *)dicPara
			RETURN_VALUE:(NSMutableString *)szReturnValue
{
	NSString * szPath = [NSString stringWithFormat:
						 @"%@/%@_%@/PDCA.plist",
						 kPD_LogPath,m_szPortIndex,m_szStartTime];
	
	NSString		*szDirectory	= [szPath stringByDeletingLastPathComponent];
	NSFileManager	*fileManager	= [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:szDirectory])
		[fileManager createDirectoryAtPath:szDirectory
			   withIntermediateDirectories:YES
								attributes:nil
									 error:nil];
	NSFileHandle	*h_UARTLog		= [NSFileHandle fileHandleForWritingAtPath:szPath];
	if (!h_UARTLog)
		[szReturnValue writeToFile:szPath
						 atomically:NO
						   encoding:NSUTF8StringEncoding
							  error:nil];
	else
	{
		[h_UARTLog writeData:[szReturnValue dataUsingEncoding:NSUTF8StringEncoding]];
	}
	return [NSNumber numberWithBool:YES];
}
- (NSNumber *)PASER_PDCA_FILE:(NSDictionary *)dicPara
				 RETURN_VALUE:(NSMutableString *)szReturnValue
{
	NSString * szPath = [NSString stringWithFormat:
						 @"%@/%@_%@/PDCA.plist",
						 kPD_LogPath,m_szPortIndex,m_szStartTime];
	NSDictionary * dictData = [NSDictionary  dictionaryWithContentsOfFile:szPath];
	if (!dictData)
	{
		ATSDebug(@"Can't paser PDCA file");
		[szReturnValue setString:@"Can't paser PDCA file"];
		return [NSNumber numberWithBool:NO];
	}
	
	NSString * strTestsKey	= [dicPara objectForKey:@"TestsKEY"];
	NSArray * aryTests		= [[dictData objectForKey:@"0"] objectForKey:strTestsKey];
	if (!aryTests)
	{
		ATSDebug(@"Paser PDCA file ERROR");
		[szReturnValue setString:@"Paser PDCA file ERROR"];
		return [NSNumber numberWithBool:NO];
	}
	
	// get the keys from script file.
	NSString * strTestNameKEY		= [dicPara objectForKey:@"testnameKEY"];
	NSString * strSubTestNameKEY	= [dicPara objectForKey:@"subtestnameKEY"];
	NSString * strSubSubTestNameKEY	= [dicPara objectForKey:@"subsubtestnameKEY"];
	NSString * strResultKEY			= [dicPara objectForKey:@"resultKEY"];
	NSString * strValueKEY			= [dicPara objectForKey:@"valueKEY"];
	NSString * strLowerLimitKEY		= [dicPara objectForKey:@"lowerlimitKEY"];
	NSString * strUpperLimitKEY		= [dicPara objectForKey:@"upperlimitKEY"];
	NSString * strUnitsKEY			= [dicPara objectForKey:@"unitsKEY"];
	NSString * strPriorityKEY		= [dicPara objectForKey:@"priorityKEY"];
	for (NSDictionary * dictItems in aryTests)
	{
		NSString * strTestNameValue			= [dictItems objectForKey:strTestNameKEY];
		NSString * strSubTestNameValue		= [dictItems objectForKey:strSubTestNameKEY];
		NSString * strSubSubTestNameValue	= [dictItems objectForKey:strSubSubTestNameKEY];
		NSString * strResultValue			= [dictItems objectForKey:strResultKEY];
		NSString * strValueValue			= [dictItems objectForKey:strValueKEY];
		NSString * strLowerLimitValue		= [dictItems objectForKey:strLowerLimitKEY];
		NSString * strUpperLimitValue		= [dictItems objectForKey:strUpperLimitKEY];
		NSString * strUnitsValue			= [dictItems objectForKey:strUnitsKEY];
		NSString * strPriorityValue			= [dictItems objectForKey:strPriorityKEY];
		
		
		
		[m_objPudding SetTestItemStatus:(strTestNameValue		? strTestNameValue		: @"")
								SubItem:(strSubTestNameValue	? strSubTestNameValue	: @"")
							 SubSubItem:(strSubSubTestNameValue ? strSubSubTestNameValue: @"")
							  TestValue:(strValueValue			? strValueValue			: @"")
							   LowLimit:(strLowerLimitValue		? strLowerLimitValue	: @"NA")
							  HighLimit:(strUpperLimitValue		? strUpperLimitValue	: @"NA")
							  TestUnits:(strUnitsValue			? strUnitsValue			: @"")
								ErrDesc:[NSString stringWithFormat:
										 @"Test [%@] Fail",strTestNameValue]
							   Priority:(strPriorityValue		? [strPriorityValue integerValue]	: 0)
							 TestResult:([@"PASS" isEqualToString:strResultValue]	? YES	: NO)];
		
	}
	
	return [NSNumber numberWithBool:YES];
}

/* Chao 2012.11.03
 * method   : DO_CALCULATE_PROX:RETURN_VALUE:
 * abstract : get ave value from PROX data */
- (NSNumber *)DO_CALCULATE_PROX:(NSDictionary *)dicSetting
				   RETURN_VALUE:(NSMutableString *)szReturnValue
{
	int		iProxCount	= 0;
    float	fProxSum	= 0.00;
	NSString	*strProxData	= [dicSetting objectForKey:@"KEY"];
	int			iStart			= [[dicSetting objectForKey:@"STARTCOUNT"] intValue];
	NSString * strTemp = [szReturnValue stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	strTemp = [strTemp stringByReplacingOccurrencesOfString:@"\r" withString:@""];
	[szReturnValue setString:strTemp];
	NSArray	*arrayProx	= [szReturnValue componentsSeparatedByString:@"PROX:"];
    if ([arrayProx count] < 3)
    {
        ATSDebug(@"PROX Data error!");
		[szReturnValue setString:@"PROX Data error"];
        return [NSNumber numberWithBool:NO];
    }
	NSMutableArray * arrProxData = [[NSMutableArray alloc] init];
    for(int i = iStart; i < [arrayProx count]; i++)
    {
        NSString * szTemp = [arrayProx objectAtIndex:i];
        if (![szTemp isKindOfClass:[NSString class]])
            continue;
        
        //modified by Chao,2013.3.15, change the catch value.
        if ([szTemp contains:@"RAW: "])
        {
			if ([[szTemp SubFrom:@"RAW: "include:NO] length]>=6)
			{
				szTemp = [szTemp subByRegex:@"RAW: (.{6}?)" name:nil error:nil];
				NSScanner *scan = [NSScanner scannerWithString:szTemp];
				unsigned int iValue = 0;
				signed	int temp = 0;
				[scan scanHexInt:&iValue];
				NSLog(@"iValue=====%d",iValue);
				if (iValue < 32768)
				{
					temp	=  iValue;
				}
				else if (32768 <= iValue <= 65535)
                {
                    temp = (65535 - iValue + 1);
                }
                else
                {
                    ATSDebug(@"The data format is error!");
                    [szReturnValue setString:@"The data format is error!"];
                    return [NSNumber numberWithBool:NO];
                }
				NSLog(@"temp=====%d",temp);
				iProxCount++;
				[arrProxData addObject:[NSNumber numberWithInt:temp]];
				fProxSum	+= temp;
			}
        }
	}
	BOOL bCalcSTD = NO;
    if (iProxCount)
	{
		// initliaze keys
		NSString * strKeyAve	= [NSString stringWithFormat:@"PROX_%@_AVE",strProxData];
		NSString * strKeyCount	= [NSString stringWithFormat:@"PROX_%@_N_SAMPLES",strProxData];
		NSString * strKeySTD	= [NSString stringWithFormat:@"PROX_%@_STD",strProxData];
		
		// Values
		NSString * strAverage	= [NSString stringWithFormat:@"%.2f",fProxSum / iProxCount];
		NSLog(@"strAverage=====%@",strAverage);
		NSString * strCount		= [NSString stringWithFormat:@"%d",iProxCount];
		NSString * strSTD		= @"";
		bCalcSTD = [self Cal_STD:(NSArray *)arrProxData ReturnValue:&strSTD];
		
		// store results into memory buffer.
		[m_dicMemoryValues setObject:strAverage	forKey:strKeyAve];
		[m_dicMemoryValues setObject:strCount	forKey:strKeyCount];
		[m_dicMemoryValues setObject:strSTD		forKey:strKeySTD];
	}
    else
    {
        ATSDebug(@"data count is 0 !");
		[szReturnValue setString:@"data count is 0 !"];
		[arrProxData release];
		return [NSNumber numberWithBool:NO];
    }
	[arrProxData release];
    return [NSNumber numberWithBool:YES && bCalcSTD];
}

//Add by yaya, 1210
- (NSNumber *)DO_CALCULATE_PROX_TWO:(NSDictionary *)dicSetting
                   RETURN_VALUE:(NSMutableString *)szReturnValue
{
    int		iProxCount	= 0;
    float	fProxSum	= 0.00;
    NSString	*strProxData	= [dicSetting objectForKey:@"KEY"];
    int			iStart			= [[dicSetting objectForKey:@"STARTCOUNT"] intValue];
    NSString * strTemp = [szReturnValue stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    strTemp = [strTemp stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    [szReturnValue setString:strTemp];
    NSArray	*arrayProx	= [szReturnValue componentsSeparatedByString:@"PROX:"];
    
    if ([arrayProx count] < 3)
    {
        ATSDebug(@"PROX Data error!");
        [szReturnValue setString:@"PROX Data error"];
        return [NSNumber numberWithBool:NO];
    }
    NSMutableArray * arrProxData = [[NSMutableArray alloc] init];
    for(int i = iStart; i < [arrayProx count]; i++)
    {
        NSString * szTemp = [arrayProx objectAtIndex:i];
        if (![szTemp isKindOfClass:[NSString class]])
            continue;
        
        //modified by Chao,2013.3.15, change the catch value.
        if ([szTemp contains:@"("])
        {
            NSString *szRegex = @"^(.*?)\\(";
            NSError		*error	= nil;
            NSString	*strSub	= [szTemp subByRegex:szRegex
                                                name:nil
                                                error:&error];
            NSLog(@"CATCH_VALUE: Catch [%@] by [%@] = [%@]. ",
                  szTemp, szRegex, strSub);
            if(strSub)
            {
                [szReturnValue setString:[strSub trim]];
                iProxCount++;
                [arrProxData addObject:[NSNumber numberWithInt:[[strSub trim] intValue]]];
                fProxSum	+= [[strSub trim] intValue];

            }
            else
            {
                if ([[error localizedDescription] contains:@"Sub string not found"])
                {
                    [szReturnValue setString:[NSString stringWithFormat:@"Invalide RegularExpress (%@) in MemoryKey[%@]",szRegex,szTemp]];
                }
                else
                {
                    [szReturnValue setString:[error localizedDescription]];
                }
                [arrProxData release];
                return [NSNumber numberWithBool:NO];
            }
        }
    }
    
    ATSDebug(@"The raw data of prox: %@", [arrProxData description]);
    
    BOOL bCalcSTD = NO;
    if (iProxCount)
    {
        // initliaze keys
        NSString * strKeyAve	= [NSString stringWithFormat:@"PROX_%@_AVE",strProxData];
        NSString * strKeyCount	= [NSString stringWithFormat:@"PROX_%@_N_SAMPLES",strProxData];
        NSString * strKeySTD	= [NSString stringWithFormat:@"PROX_%@_STD",strProxData];
        
        // Values
        NSString * strAverage	= [NSString stringWithFormat:@"%.2f",fProxSum / iProxCount];
        NSLog(@"strAverage=====%@,Prox count:%d",strAverage,iProxCount);
        NSString * strCount		= [NSString stringWithFormat:@"%d",iProxCount];
        NSString * strSTD		= @"";
        bCalcSTD = [self Cal_STD:(NSArray *)arrProxData ReturnValue:&strSTD];
        
        // store results into memory buffer.
        [m_dicMemoryValues setObject:strAverage	forKey:strKeyAve];
        [m_dicMemoryValues setObject:strCount	forKey:strKeyCount];
        [m_dicMemoryValues setObject:strSTD		forKey:strKeySTD];
    }
    else
    {
        ATSDebug(@"data count is 0 !");
        [szReturnValue setString:@"data count is 0 !"];
        [arrProxData release];
        return [NSNumber numberWithBool:NO];
    }
    [arrProxData release];
    return [NSNumber numberWithBool:YES && bCalcSTD];
    
}


- (NSNumber *)CHECKLENGTH:(NSDictionary *)dicSetting
			 RETURN_VALUE:(NSMutableString *)szReturnValue
{
	NSString * strKEY = [dicSetting objectForKey:@"KEY"];
	NSString * strValue = [m_dicMemoryValues objectForKey:strKEY];
	int length = [[dicSetting objectForKey:@"LENGTH"] integerValue];
	
	return [NSNumber numberWithBool:([strValue length] == length)];
}

// add by sky 2012.11.4
// Cancel or item for REL line or other line. 
- (NSNumber *)CANCEL_ITEM_FOR_REL_OR_OTHERLINE:(NSDictionary *)dicSetting
                                  RETURN_VALUE:(NSMutableString *)szReturnValue
{
    if ([[m_dicMemoryValues objectForKey:descriptionOfGHStationInfo(IP_LINE_NUMBER)] ContainString:@"REL"])
    {
        if ([dicSetting objectForKey:@"CancelItemForREL"])
        {
            NSMutableArray  *arrCancelForREL    = [dicSetting objectForKey:@"CancelItemForREL"];
            for (NSString   *szCancelForREL in arrCancelForREL)
            {
                [m_muArrayCancelCase addObject:szCancelForREL];
            }
        }
        
    }
    else if([[m_dicMemoryValues objectForKey:descriptionOfGHStationInfo(IP_LINE_NUMBER)] ContainString:@"REP"]
            && [[m_dicMemoryValues objectForKey:descriptionOfGHStationInfo(IP_LOCATION)] ContainString:@"FT"])
    {
        //Add by raniys on 07/29/2014
        //Cancel some items if test in the line which is in FA area
        if ([dicSetting objectForKey:@"CancelItemForFA"])
        {
            NSMutableArray  *arrCancelForREL    = [dicSetting objectForKey:@"CancelItemForFA"];
            for (NSString   *szCancelForREL in arrCancelForREL)
            {
                [m_muArrayCancelCase addObject:szCancelForREL];
            }
        }
        if ([dicSetting objectForKey:@"CancelItemForOtherline"])
        {
            NSMutableArray  *arrCancelForOtherline = [dicSetting objectForKey:@"CancelItemForOtherline"];
            for (NSString   *szCancelForOtherline in arrCancelForOtherline)
            {
                [m_muArrayCancelCase addObject:szCancelForOtherline];
            }
        }
    }
    else
    {
        if ([dicSetting objectForKey:@"CancelItemForOtherline"])
        {
            NSMutableArray  *arrCancelForOtherline = [dicSetting objectForKey:@"CancelItemForOtherline"];
            for (NSString   *szCancelForOtherline in arrCancelForOtherline)
            {
                [m_muArrayCancelCase addObject:szCancelForOtherline];
            }
        }
    }
    return [NSNumber numberWithBool:YES];
}

#pragma mark ############################## TILT1 Fixture Button judge start ##############################

// Start 2012.12.13 Add by Sky
// Description: Judge the pattern status form the fixture button.
// Param:
//      NSDictionany    *dicContents    : Setting in script file
//      NSMutableString *strReturnValue : Return value

-(NSNumber*)START_JUDGE_PATTERN_TEST:(NSDictionary *)dicContents
                        RETURN_VALUE:(NSMutableString *)strReturnValue
{
    [m_dicMemoryValues setObject:[NSNumber numberWithBool:YES]
						  forKey:@"Pattern_Thread_On"];
    [m_dicMemoryValues setObject:@"None"
                          forKey:@"Pattern_Thread_Status"];
    [NSThread detachNewThreadSelector:@selector(JudgePatternStatus:)
							 toTarget:self
						   withObject:dicContents];
    [strReturnValue setString:@"PASS"];
    return [NSNumber numberWithBool:YES];
}

-(NSNumber*)CHECK_PATTERN_STATUS:(NSDictionary *)dicContents
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
            if ([[m_dicMemoryValues objectForKey:@"Pattern_Thread_Status"] isNotEqualTo:@"None"] &&
                [[m_dicMemoryValues objectForKey:@"Pattern_Thread_Status"] boolValue])
            {
                ATSDebug(@"Congratulations! The operator think the picture is normal!");
                [strReturnValue setString:@"PASS"];
                return [NSNumber numberWithBool:YES];
            }
            if ([[m_dicMemoryValues objectForKey:@"Pattern_Thread_Status"] isNotEqualTo:@"None"] &&
                ![[m_dicMemoryValues objectForKey:@"Pattern_Thread_Status"] boolValue])
            {
                ATSDebug(@"Sorry, the operator think the picture is unnormal!");
                [strReturnValue setString:@"FAIL"];
                return [NSNumber numberWithBool:NO];
            }
        }
        usleep(10000);
    }while(dSpendtime < dCheckTime);
    ATSDebug(@"Sorry, the operator did not press the button!");
    return [NSNumber numberWithBool:NO];
}

-(NSNumber*)END_JUDGE_PATTERN_TEST:(NSDictionary *)dicContents
                      RETURN_VALUE:(NSMutableString *)strReturnValue
{
    @synchronized(m_dicMemoryValues)
    {
        [m_dicMemoryValues setObject:[NSNumber numberWithBool:NO]
							  forKey:@"Pattern_Thread_On"];
    }
    return [NSNumber numberWithBool:YES];
}

- (void)JudgePatternStatus:(id)idThread
{
    NSAutoreleasePool	*pool		= [[NSAutoreleasePool alloc] init];
    ATSDebug(@"Start Pattern_Test Monitor.");
    NSMutableString	*strReadData	= [[NSMutableString alloc] initWithString:@""];
    NSDictionary	*dicReadCommand	= [idThread valueForKey:@"READ_COMMAND"];
    NSNumber        *nRet;//           = [NSNumber numberWithBool:NO];
    PEGA_ATS_UART	*uartObj        = [[m_dicPorts objectForKey:kPD_Device_FIXTURE]
                                       objectAtIndex:kFZ_SerialInfo_UartObj];

    while ([[m_dicMemoryValues objectForKey:@"Pattern_Thread_On"] boolValue])
    {
        [strReadData setString:@""];
        [uartObj Clear_UartBuff:kUart_ClearInterval
                        TimeOut:kUart_CommandTimeOut
                        readOut:nil];
        nRet    = [self READ_COMMAND:dicReadCommand
                        RETURN_VALUE:strReadData];
        ATSDebug(@"The return value of this pattern is [%@]", strReadData);
        @synchronized(m_dicMemoryValues)
        {
            [m_dicMemoryValues setObject:@"None"
                                  forKey:@"Pattern_Thread_Status"];
#ifndef N61_Project
#define N61_Project 1
#endif
#if N61_Project
            if ([nRet boolValue] &&
                ([strReadData ContainString:@"Pass"] || [strReadData ContainString:@"Menu -st"]))
            {
                [m_dicMemoryValues setObject:[NSNumber numberWithBool:YES]
                                      forKey:@"Pattern_Thread_Status"];
                ATSDebug(@"The operator press the PASS button, the return value is [%@]", strReadData);
                break;
            }
            else if ([nRet boolValue] &&
                     ([strReadData ContainString:@"Fail"] || [strReadData ContainString:@"Menu -p"]))
            {
                [m_dicMemoryValues setObject:[NSNumber numberWithBool:NO]
                                      forKey:@"Pattern_Thread_Status"];
                ATSDebug(@"The operator press the FAIL button, the return value is [%@]", strReadData);
                break;
            }
#else
            if ([nRet boolValue] &&
                [strReadData ContainString:@"Pass"])
            {
                [m_dicMemoryValues setObject:[NSNumber numberWithBool:YES]
                                      forKey:@"Pattern_Thread_Status"];
                ATSDebug(@"The operator press the PASS button, the return value is [%@]", strReadData);
                break;
            }
            else if ([nRet boolValue] &&
                     [strReadData ContainString:@"Fail"])
            {
                [m_dicMemoryValues setObject:[NSNumber numberWithBool:NO]
                                      forKey:@"Pattern_Thread_Status"];
                ATSDebug(@"The operator press the FAIL button, the return value is [%@]", strReadData);
                break;
            }
#endif
        }
    }
    [strReadData release];
    ATSDebug(@"End Pattern_Test Monitor.");
    [pool drain];
}
//End 2012.10.26 Add by Sky

#pragma mark ############################## TILT1 Fixture Button judge start ##############################


-(NSNumber*)READ_FILE:(NSDictionary*)dictContents
		 RETURN_VALUE:(NSMutableString*)strReturnValue
{
	// Get path variable. 
	NSString	*strPath	= [dictContents objectForKey:@"PATH"];
	BOOL		bDelete		= [[dictContents objectForKey:@"DELETE"] boolValue];
	if(!strPath)
	{
		[strReturnValue setString:@"Path not found. "];
		return [NSNumber numberWithBool:NO];
	}
	// Read contents of file. 
	NSError		*error		= nil;
	NSString	*strContent	= [NSString stringWithContentsOfFile:strPath
													 encoding:NSUTF8StringEncoding
														error:&error];
	if(!strContent)
	{
		[strReturnValue setString:[error localizedDescription]];
		return [NSNumber numberWithBool:NO];
	}
	if(bDelete)
	{
		NSFileManager	*fm	= [NSFileManager defaultManager];
		[fm removeItemAtPath:strPath error:nil];
	}
	// Response.
	[strReturnValue setString:strContent];
	return [NSNumber numberWithBool:YES];
}
-(NSNumber*)TCPRELAY_START:(NSDictionary*)dictContents
			  RETURN_VALUE:(NSMutableString*)strReturnValue
{
	// Get path and check.
	NSString	*strPath	= [dictContents objectForKey:@"PATH"];
    
    int iPort = 0;
    int iTelnet  = 0;
    NSInteger	nPosition	= [self GetUSB_PortNum];
    switch (nPosition)
    {
        case 1:
            iPort = 10000;
            iTelnet = 10023;
            break;
            
        case 2:
            iPort = 20000;
            iTelnet = 20023;
            break;
            
        case 3:
            iPort = 30000;
            iTelnet = 30023;
            break;
        default:
            break;
    }
    
    
    [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%d",iPort+873] forKey:@"PORTKEY"];
    [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%d",iTelnet] forKey:@"TELNETID"];
    
    NSArray     *aryArgs    = [NSArray arrayWithObjects:@"--portoffset",
                               [NSString stringWithFormat:@"%d",iPort],
                                                        @"873",
                                                        @"23",
                                                        @"--locationid",
                                                        [m_dicMemoryValues objectForKey:@"PLOCATIONID"], nil];
    
	//NSArray		*aryArgs	= [dictContents objectForKey:@"ARGUMENTS"];
	NSFileManager	*fm		= [NSFileManager defaultManager];
	BOOL		bDirectory	= YES;
	if(!strPath
	   || ![fm fileExistsAtPath:strPath isDirectory:&bDirectory]
	   || bDirectory)
	{
		[strReturnValue setString:@"Invalid file. "];
		return [NSNumber numberWithBool:NO];
	}
	// Terminate old task.
	[m_taskTcprelay terminate];
	[m_taskTcprelay release];	m_taskTcprelay	= nil;
	// Create new task.
	m_taskTcprelay	= [[NSTask alloc] init];
	[m_taskTcprelay setStandardInput:[NSPipe pipe]];
	[m_taskTcprelay setStandardOutput:[NSPipe pipe]];
	[m_taskTcprelay setStandardError:[m_taskTcprelay standardOutput]];
	[m_taskTcprelay setLaunchPath:strPath];
	if(aryArgs && [aryArgs isKindOfClass:[NSArray class]])
		[m_taskTcprelay setArguments:aryArgs];
	@try
	{
		[m_taskTcprelay launch];
	}
	@catch (NSException *exception)
	{
		[m_taskTcprelay release];	m_taskTcprelay	= nil;
		[strReturnValue setString:[exception reason]];
		return [NSNumber numberWithBool:NO];
	}
	[strReturnValue setString:@"PASS"];
	return [NSNumber numberWithBool:YES];
}
-(NSNumber*)TCPRELAY_END:(NSDictionary*)dictContents
			RETURN_VALUE:(NSMutableString*)strReturnValue
{
	@try
	{
		[m_taskTcprelay terminate];
	}
	@catch (NSException *exception)
	{
		[strReturnValue setString:[exception reason]];
	}
	@finally
	{
		[m_taskTcprelay release];	m_taskTcprelay	= nil;
	}
	[strReturnValue setString:@"PASS"];
	return [NSNumber numberWithBool:YES];
}

// add by sky 2013.1.19
// Cancel or item for N49 or other Products.
-(NSNumber*)CANCEL_ITEM_FOR_N49_OR_OTHERPRODUCTS:(NSDictionary *)dicSetting
                                    RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSString    *szConfig   = (nil != [dicSetting objectForKey:kFZ_Script_MemoryKey])
                            ?   [m_dicMemoryValues objectForKey:
                                 [dicSetting objectForKey:kFZ_Script_MemoryKey]]
                            :   szReturnValue;
    if ([szConfig ContainString:@"N49"])
    {
        if ([dicSetting objectForKey:@"CancelItemForN49"])
        {
            NSMutableArray  *arrCancelForREL    = [dicSetting objectForKey:@"CancelItemForN49"];
            for (NSString   *szCancelForREL in arrCancelForREL)
            {
                [m_muArrayCancelCase addObject:szCancelForREL];
            }
        }
    }
    else if ([szConfig ContainString:@"N48"])
    {
        if ([dicSetting objectForKey:@"CancelItemForOtherProducts"])
        {
            NSMutableArray  *arrCancelForOtherline = [dicSetting objectForKey:@"CancelItemForOtherProducts"];
            for (NSString   *szCancelForOtherline in arrCancelForOtherline)
            {
                [m_muArrayCancelCase addObject:szCancelForOtherline];
            }
        }
    }
    else
    {
        ATSDebug(@"Can't catch the key value \"N48\" or \"N49\" from the config of this unit, please check it!");
        return [NSNumber numberWithBool:NO];
    }
    return [NSNumber numberWithBool:YES];
}

//2013.02.04 Add by Pleasure for switch data which contains "," to no "," contained

-(NSNumber *)DeleteCommaForData:(NSDictionary*)dictContents
                   RETURN_VALUE:(NSMutableString*)strReturnValue
{
    if (NSNotFound != [strReturnValue rangeOfString:@","].location )
    {
        NSNumberFormatter * number = [[NSNumberFormatter alloc]init ];
        [number  setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber * data = [number numberFromString:strReturnValue];
        [strReturnValue setString:[data stringValue]];
        [number release];
    }
    else
        ATSDebug(@"The data format is OK,It doesn't contain comma");
    return [NSNumber numberWithBool:YES];
}
-(NSNumber*)DATASTRING_TO_STRING:(NSDictionary*)dictContents
					RETURN_VALUE:(NSMutableString*)strReturnValue
{
	// Remove extra flags. 
	NSString	*strData	= [NSString stringWithString:strReturnValue];
	strData	= [strData stringByReplacingOccurrencesOfString:@" " withString:@""];
	strData	= [strData stringByReplacingOccurrencesOfString:@"0x" withString:@""];
	strData	= [strData stringByReplacingOccurrencesOfString:@"0X" withString:@""];
	// Check length. 
	if([strData length] % 2)
	{
		[strReturnValue setString:[NSString stringWithFormat:@"%s", strerror(EINVAL)]];
		return [NSNumber numberWithBool:NO];
	}
	
	NSMutableString	*strTruth	= [NSMutableString string];
	for(int i=0; i<[strData length]; i+=2)
	{	// Convert 2 digits of hex. 
		NSString	*strSection	= [strData substringWithRange:NSMakeRange(i, 2)];
		NSUInteger	iSection	= 0;
		NSScanner	*scanner	= [NSScanner scannerWithString:strSection];
		if([scanner scanHexInt:&iSection]&&[scanner isAtEnd])
			[strTruth appendFormat:@"%c", iSection];
	}
	[strReturnValue setString:strTruth];
	return [NSNumber numberWithBool:YES];
}
-(NSNumber*)CL200A_LUX:(NSDictionary*)dictContents
		  RETURN_VALUE:(NSMutableString*)strReturnValue
{
	// CL200A lux value length should be 6. 
	if([strReturnValue length] != 6)
	{
		[strReturnValue setString:[NSString stringWithFormat:@"%s", strerror(EINVAL)]];
		return [NSNumber numberWithBool:NO];
	}
	
	const char	*cValue	= [strReturnValue UTF8String];
	double		dValue	= 0;
	int	iPointOffset	= cValue[5] - 48;
	// Get valid number. 
	for(char *p = (char*)cValue + 1; p - cValue <= 4; p++)
		if(*p == 32)
			;
		else
		{
			dValue	*= 10;
			dValue	+= *p - 48;
		}
	// Sign.
	switch(cValue[0])
	{
		case '+':
			break;
		case '-':
			dValue	= 0 - dValue;
			break;
		default:
			break;
	}
	// Move number point.
	dValue	*= pow(10, iPointOffset - 4);
	[strReturnValue setString:[NSString stringWithFormat:@"%g", dValue]];
	return [NSNumber numberWithBool:YES];
}


- (NSNumber *)SET_RETURNVALUE_FORMAT:(NSDictionary *)dicSetting
						RETURN_VALUE:(NSMutableString *)strReturnValue
{
	//If the setting dictionary has no parameters, post a alert panel.
	if (!dicSetting || [dicSetting count] == 0) {
		NSRunAlertPanel([NSString stringWithFormat:@"警告(Warning)"],
						@"SET_RETURNVALUE_FORMAT:RETURN_VALUE:没有参数。(There are no parameters for SET_RETURNVALUE_FORMAT!)",
						@"确认(OK)", nil, nil);
		return [NSNumber numberWithBool:NO];
	}
	NSString *strFormat = [dicSetting objectForKey:@"FORMAT_SETTING"];
	NSString *strOutput = @"";
	
	//If the FORMAT_SETTING is null
	if (strFormat == nil || [strFormat isEqualToString:@""]) {
		NSRunAlertPanel([NSString stringWithFormat:@"警告(warning)"],
						@"SET_RETURNVALUE_FORMAT:RETURN_VALUE里的参数为空。(The parameters for SET_RETURNVALUE_FORMAT is null.)",
						@"确认(OK)", nil, nil);
		return [NSNumber numberWithBool:NO];
	}
	
	//Set the returnValue's format
	BOOL bReturn = [self TransformKeyToValue:strFormat returnValue:&strOutput];
	[strReturnValue setString:strOutput];
	return [NSNumber numberWithBool:bReturn];
}

//Add by Jean
- (NSNumber *)MAPPING_TABLE:(NSDictionary *)dicSetting
			   RETURN_VALUE:(NSMutableString *)strReturnValue
{
	//If the setting dictionary has no parameters, post a alert panel.
	if (!dicSetting || [dicSetting count] == 0) {
		NSRunAlertPanel([NSString stringWithFormat:@"警告(Warning)"],
						@"MAPPING_TABLE:RETURN_VALUE:没有参数。(There are no parameters for MAPPING_TABLE!)",
						@"确认(OK)", nil, nil);
		return [NSNumber numberWithBool:NO];
	}
	
	NSString		*strPreKey			= [dicSetting objectForKey:@"PRE_KEY"];
	NSString		*strPreValue		= [m_dicMemoryValues objectForKey:strPreKey];
	NSString		*strPostKey			= [dicSetting objectForKey:@"POST_KEY"];
	NSDictionary	*dicMappingTable	= [dicSetting objectForKey:@"MAPPING_TABLE"];
	BOOL			bLowercaseMapping	= [[dicSetting objectForKey:@"LowercaseMapping"] boolValue];
	
	//Some parameters of MAPPING_TABLE are missing.
	if (strPreKey == nil || [strPreKey isEqualToString:@""]
		|| strPostKey ==nil || [strPostKey isEqualToString:@""]
		|| !dicMappingTable || [dicMappingTable count] ==0)
	{
		NSRunAlertPanel([NSString stringWithFormat:@"警告(Warning)"],
						@"MAPPING_TABLE:RETURN_VALUE:缺少参数。(Some parameters of MAPPING_TABLE are missing!)",
						@"确认(OK)", nil, nil);
		return [NSNumber numberWithBool:NO];
	}
	
	//Get the matched value according the value of PRE_KEY.
	if (bLowercaseMapping ?
		[[dicMappingTable allKeys] containsObject:[strPreValue lowercaseString]] :
		[[dicMappingTable allKeys] containsObject:strPreValue])
	{
		NSString	*strMatchValue	= bLowercaseMapping ?
										[dicMappingTable objectForKey:[strPreValue lowercaseString]] :
										[dicMappingTable objectForKey:strPreValue];
		[m_dicMemoryValues setObject:strMatchValue forKey:strPostKey];
	}
	else
	{
		[strReturnValue setString:[NSString stringWithFormat:@"Didn't match the value %@",strPreValue]];
		[m_dicMemoryValues setObject:@"" forKey:strPostKey];
		return [NSNumber numberWithBool:NO];
	}
	return [NSNumber numberWithBool:YES];	
}


//Add by Jean
- (NSNumber *)ASC2Char:(NSDictionary *)dicSetting
		  RETURN_VALUE:(NSMutableString *)strReturnValue
{
	int iReturnValue = [strReturnValue intValue];
	[strReturnValue setString:[NSString stringWithFormat:@"%c", iReturnValue]];
	return [NSNumber numberWithBool:YES];
}

- (NSNumber *)Char2ASC:(NSDictionary *)dicSetting
		  RETURN_VALUE:(NSMutableString *)strReturnValue
{
	if([strReturnValue length])
	{
		char	*cValue	= [strReturnValue characterAtIndex:0];
		[strReturnValue setString:[NSString stringWithFormat:@"%d", (int)cValue]];
		return [NSNumber numberWithBool:YES];
	}
	else
		return [NSNumber numberWithBool:NO];
}



/* Chao 2012.11.05
 method   : COMPARE_CONFIG:RETURN_VALUE:
 abstract : Compare config:
 If scan config in UI is match config in unit, return yes.
 If the CFG in unit is empty or abnormal  format, we will add CFG in MLB with scan config in UI.
 */
- (NSNumber *)COMPARE_CONFIG: (NSDictionary *)dicSetting
                RETURN_VALUE:(NSMutableString *)szReturnValue
{
	NSString	*strScanConfig	= [m_dicMemoryValues objectForKey:[dicSetting objectForKey:@"SCAN"]];
	NSString	*strUnitConfig	= [m_dicMemoryValues objectForKey:[dicSetting objectForKey:@"UNIT"]];
	if (strScanConfig && strUnitConfig && [strScanConfig isNotEqualTo:@""])
    {
        if ([strUnitConfig ContainString:strScanConfig])
        {
            ATSDBgLog(@"compare OK: config[%@]",strScanConfig);
			[szReturnValue setString:strUnitConfig];
            return [NSNumber numberWithBool:YES];
        }
        else
        {
			ATSDBgLog(@"UNIT = %@ NOT CONTAIN SCAN = %@",strUnitConfig,strScanConfig);
            [szReturnValue setString:[NSString stringWithFormat:@"UNIT = %@ NOT CONTAIN SCAN = %@",strUnitConfig,strScanConfig]];
            return [NSNumber numberWithBool:NO];
        }
    }
    else
    {
		ATSDBgLog(@"Can't found scan config or unit config.");
        return [NSNumber numberWithBool:NO];
    }
}


/* Chao 2013.3.28
 method   : CONTAIN_STRING:RETURN_VALUE:
 abstract : Judge  if one string  contain  the string in given array , if YES , cancel some items
 */
- (NSNumber *)Contain_String:(NSDictionary *)dicSetting
                RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSString    *strMessage     = [dicSetting objectForKey:@"ORI_STRING"];
	NSArray     *aryContain     = [dicSetting objectForKey:@"CON_STRING"];
    
    [self TransformKeyToValue:strMessage returnValue:&strMessage];;
	if (strMessage && [strMessage isNotEqualTo:@""] && [aryContain count] != 0)
    {
        for(NSString *strContain  in aryContain)
        {
            if ([strMessage ContainString:strContain])
            {
                ATSDebug(@"The [ORI_STRING = %@] contains the [CON_STRING = %@]",strMessage, strContain);
                [szReturnValue setString:@"YES"];
                return [NSNumber numberWithBool:YES];
            }
            else
            {
                [szReturnValue setString:@"NO"];
            }
        }
        return [NSNumber numberWithBool:YES];
    }
    else
    {
		ATSDBgLog(@"Please check the script file !");
        return [NSNumber numberWithBool:NO];
    }
}

- (NSNumber *)JUDGESPECFORI2CADDRESS:(NSDictionary *)dicSetting
                        RETURN_VALUE:(NSMutableString *)strReturnValue
{
    NSString        *szSpecKey          = [dicSetting objectForKey:kFZ_Script_MemoryKey];
    NSDictionary    *dicMappingTable    = [dicSetting objectForKey:@"MappingTable"];
    NSDictionary    *dicAction          = [dicSetting objectForKey:@"SpecAndParametric"];
    NSArray         *arrTemp            = [dicMappingTable allKeys];
    for (NSString *szTempMap in arrTemp)
    {
        if ([strReturnValue isEqualToString:szTempMap])
        {
            @synchronized(m_dicMemoryValues)
            {
                [m_dicMemoryValues setObject:[dicMappingTable objectForKey:szTempMap] forKey:szSpecKey];
            }
            NSDictionary    *dicTempJudge   = [dicAction objectForKey:szTempMap];
            NSNumber        *numRet;
            numRet = [self JUDGE_SPEC:[dicTempJudge objectForKey:@"JudgeSpec"]
                         RETURN_VALUE:strReturnValue];
            [self UPLOAD_PARAMETRIC:[dicTempJudge objectForKey:@"UploadParametric"]
                       RETURN_VALUE:strReturnValue];
            return numRet;
        }
        
    }
    if (0 < [arrTemp count])
    {
        NSDictionary    *dicTempJudge   = [dicAction objectForKey:[arrTemp objectAtIndex:0]];
        NSNumber        *numRet;
        numRet = [self JUDGE_SPEC:[dicTempJudge objectForKey:@"JudgeSpec"]
                     RETURN_VALUE:strReturnValue];
        [self UPLOAD_PARAMETRIC:[dicTempJudge objectForKey:@"UploadParametric"]
                   RETURN_VALUE:strReturnValue];
        return numRet;
    }
    return [NSNumber numberWithBool:NO];
}

- (NSNumber *)JUDGESPECFORI2CSPEC:(NSDictionary *)dicSetting
                     RETURN_VALUE:(NSMutableString *)strReturnValue
{
    NSString        *szSpecKey      = [dicSetting objectForKey:kFZ_Script_MemoryKey];
    NSDictionary    *dicAction      = [dicSetting objectForKey:@"SpecAndParametric"];
    NSArray         *arrTemp        = [dicAction allKeys];
    NSNumber        *numRet;
    if (nil == [m_dicMemoryValues objectForKey:szSpecKey])
    {
        if (0 < [arrTemp count])
        {
            NSDictionary    *dicTempJudge   = [dicAction objectForKey:[arrTemp objectAtIndex:0]];
            NSNumber        *numRet;
            numRet = [self JUDGE_SPEC:[dicTempJudge objectForKey:@"JudgeSpec"]
                         RETURN_VALUE:strReturnValue];
            [self UPLOAD_PARAMETRIC:[dicTempJudge objectForKey:@"UploadParametric"]
                       RETURN_VALUE:strReturnValue];
            return numRet;
        }
        return [NSNumber numberWithBool:NO];
    }
    NSDictionary    *dicTempJudge       = [dicAction objectForKey:[m_dicMemoryValues objectForKey:szSpecKey]];
    numRet  = [self JUDGE_SPEC:[dicTempJudge objectForKey:@"JudgeSpec"]
                  RETURN_VALUE:strReturnValue];
    [self UPLOAD_PARAMETRIC:[dicTempJudge objectForKey:@"UploadParametric"]
               RETURN_VALUE:strReturnValue];
    return numRet;
}

- (NSNumber *)Judge_Loss:(NSDictionary *)dicSetting
            RETURN_VALUE:(NSMutableString *)strReturnValue
{
    if ([strReturnValue isEqual:@""] || strReturnValue == nil)
    {
        ATSDebug(@"Return value is nil");
        return [NSNumber numberWithBool:NO];
    }
    
    if ([strReturnValue contains:@"??????"])
    {
        ATSDebug(@"No loss data, the return value is ??????");
        m_bCancelToEnd = YES;
        NSRunAlertPanel(@"Alert 1", @"There have no loss data in fixture,please do correlation with this fixture.", @"OK", nil, nil);
        
        return  [NSNumber numberWithBool:NO];
    }
    else if ([strReturnValue contains:@"+99999"])
    {
        ATSDebug(@"No loss data, the return value is +99999");
        m_bCancelToEnd = YES;
        NSRunAlertPanel(@"Alert 2", @"calibration did not complete, please re-do calibration.", @"OK", nil, nil);
        
        return  [NSNumber numberWithBool:NO];
    }
    else
    {
        if ([strReturnValue ContainString:@"+"])
        {
            [strReturnValue setString:[strReturnValue stringByReplacingOccurrencesOfString:@"+" withString:@"-"]];

        }else if ([strReturnValue ContainString:@"-"])
        {
            [strReturnValue setString:[strReturnValue stringByReplacingOccurrencesOfString:@"-" withString:@"+"]];
        }
    }
   return [NSNumber numberWithBool:YES];
}

- (NSNumber *)DELETE_STRING_FROM_VALUE:(NSDictionary *)dicSetting
                          RETURN_VALUE:(NSMutableString *)strReturnValue
{
    //If the setting dictionary has no parameters, post a alert panel.
    NSDictionary    *dicCatchValue  = [dicSetting objectForKey:@"CATCH_VALUE"];
	if (!dicCatchValue || [dicCatchValue count] == 0) {
		NSRunAlertPanel([NSString stringWithFormat:@"警告(Warning)"],
						@"DELETE_STRING_FROM_VALUE:RETURN_VALUE::没有参数。(There are no parameters for SET_RETURNVALUE_FORMAT!)",
						@"确认(OK)", nil, nil);
		return [NSNumber numberWithBool:NO];
	}
	NSString    *szKey      = [dicCatchValue objectForKey:kFZ_Script_MemoryKey];
    NSString    *szRegex    = [dicCatchValue objectForKey:@"REGEX"];
	//If the CATCH_VALUE is null, post a alert panel.
	if (szKey   == nil || [szKey isEqualToString:@""] ||
        szRegex == nil || [szRegex isEqualToString:@""])
    {
		NSRunAlertPanel([NSString stringWithFormat:@"警告(warning)"],
						@"DELETE_STRING_FROM_VALUE:RETURN_VALUE:里的参数为空。(The parameters for SET_RETURNVALUE_FORMAT is null.)",
						@"确认(OK)", nil, nil);
		return [NSNumber numberWithBool:NO];
	}
    [strReturnValue setString:[m_dicMemoryValues objectForKey:szKey]];
    NSNumber    *nRet       = [self CATCH_VALUE:dicCatchValue RETURN_VALUE:strReturnValue];
    if ([nRet boolValue])
    {
        NSString    *szCatch    = strReturnValue;
        NSString    *szReturn   = [[m_dicMemoryValues objectForKey:szKey] stringByReplacingOccurrencesOfString:szCatch withString:@""];
        [m_dicMemoryValues setObject:szReturn forKey:szKey];
        [strReturnValue setString:szReturn];
        return [NSNumber numberWithBool:YES];
    }
    [strReturnValue setString:[m_dicMemoryValues objectForKey:szKey]];
    return [NSNumber numberWithBool:YES];
}
-(NSNumber*)ADD_UART_LOG:(NSDictionary*)dictSetting
			RETURN_VALUE:(NSMutableString *)strReturnValue
{
	NSString	*strDeviceTarget	= [dictSetting objectForKey:@"TARGET"];
	BOOL		bSaveBinary			= [[dictSetting objectForKey:@"SaveBinary"] boolValue];
	
	// Post to UI. 
	NSDictionary	*dicPostRXToUI	= [NSDictionary dictionaryWithObjectsAndKeys:
                                       kUartView,					kFunnyZoneIdentify,
                                       strReturnValue,				kIADeviceNotificationRX,
                                       strDeviceTarget,				kFZ_Script_DeviceTarget,
									   [NSColor blueColor],			kIADevicePortColor,
                                       kIADeviceALSFileNameDate,	kPD_Notification_Time, nil];
    NSNotificationCenter	*NotificationCenter	= [NSNotificationCenter defaultCenter];
    [NotificationCenter postNotificationName:TestItemInfoNotification
                                      object:self
                                    userInfo:dicPostRXToUI];
	
	// Write to UART log. 
	[IALogs CreatAndWriteUARTLog:[NSString stringWithFormat:@"%@\n", strReturnValue]
						  atTime:kIADeviceALSFileNameDate
					  fromDevice:strDeviceTarget
						withPath:[NSString stringWithFormat:
								  @"%@/%@_%@/%@_%@_Uart.txt",
								  kPD_LogPath,		m_szPortIndex,
								  m_szStartTime,	m_szPortIndex,
								  m_szStartTime]
						  binary:bSaveBinary];
	// Append attribute uart log for debug window in UI
	NSString	*strInformation = [NSString stringWithFormat:@"[%@] (%@) : %@\n",kIADeviceALSFileNameDate,strDeviceTarget,strReturnValue];
	NSColor		*color			= ([strDeviceTarget contains:@"MOBILE"]) ? [NSColor blueColor] : [NSColor orangeColor];
	NSDictionary	*dict		= [NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
	NSAttributedString	*attriUART	= [[NSAttributedString alloc] initWithString:strInformation
																	attributes:dict];
	[m_strSingleUARTLogs appendAttributedString:attriUART];
	[attriUART release];
	return [NSNumber numberWithBool:YES];
}

// add by sky 2013.7.10
// Cancel or item by BOOL value.
-(NSNumber *)CANCEL_ITEM_BY_BOOL_VALUE:(NSDictionary *)dicSetting
                          RETURN_VALUE:(NSMutableString *)szReturnValue
{
    if (nil == [dicSetting objectForKey:kFZ_Script_MemoryKey])
    {
        [szReturnValue setString:@"Cannot get the bool value of the function [CANCEL_ITEM_BY_BOOL_VALUE] from the script file!"];
        return [NSNumber numberWithBool:NO];
    }
    BOOL    bJudge  = [[m_dicMemoryValues objectForKey:[dicSetting objectForKey:kFZ_Script_MemoryKey]] boolValue];
    if (bJudge)
    {
        if ([dicSetting objectForKey:@"CancelItemForYES"])
        {
            NSArray *arrCancelForYES        = [dicSetting objectForKey:@"CancelItemForYES"];
            for (NSString   *szCancelForYES in arrCancelForYES)
            {
                [m_muArrayCancelCase addObject:szCancelForYES];
            }
        }
        
    }
    else
    {
        if ([dicSetting objectForKey:@"CancelItemForNO"])
        {
            NSArray *arrCancelForNO  = [dicSetting objectForKey:@"CancelItemForNO"];
            for (NSString   *szCancelForNO in arrCancelForNO)
            {
                [m_muArrayCancelCase addObject:szCancelForNO];
            }
        }
    }
    return [NSNumber numberWithBool:YES];
}

// add by Sky_Ge 2013.7.11
/*Param:
 *  NSArray         *LineName       : The name (in json file) of the line what you need to cancel items.
 *  NSDictionary    *CancelItems    : The items that need to cancel for each line, name the Array with the name in LineName.
 *      NSArry  *Others         : The items that need to cancel except the line in the LineName.
 *Description:
 *  Since some lines need special requirement for some items, we may rename/remove/modify the items for the special lines, this function can remove the items for different line name.
 */
-(NSNumber *)CANCEL_ITEM_BY_LINE_NAME:(NSDictionary *)dicSetting
                         RETURN_VALUE:(NSMutableString *)szReturnValue
{
    if (nil == [dicSetting objectForKey:@"LineName"] ||
        nil == [dicSetting objectForKey:@"CancelItems"] ||
        0 == [[dicSetting objectForKey:@"LineName"] count] ||
        0 == [[[dicSetting objectForKey:@"CancelItems"] allKeys] count])
    {
        return [NSNumber numberWithBool:YES];
    }
    NSArray         *arrLineName    = [dicSetting objectForKey:@"LineName"];
    NSDictionary    *dicCancelItems = [dicSetting objectForKey:@"CancelItems"];
    for (NSString   *szLineName in arrLineName)
    {
        for (szLineName in [dicCancelItems allKeys])
        {
            NSArray *arrCancelLine  = [dicCancelItems objectForKey:szLineName];
            if ([[m_dicMemoryValues objectForKey:descriptionOfGHStationInfo(IP_LINE_NUMBER)] ContainString:szLineName])
            {
                for (NSString   *szCancelItems in arrCancelLine)
                {
                    [m_muArrayCancelCase addObject:szCancelItems];
                }
                return [NSNumber numberWithBool:YES];
            }
        }
    }
    if (nil != [dicCancelItems objectForKey:@"Others"] &&
        0 != [[dicCancelItems objectForKey:@"Others"] count])
    {
        for (NSString   *szCancelOthers in [dicCancelItems objectForKey:@"Others"])
        {
            [m_muArrayCancelCase addObject:szCancelOthers];
        }
    }
    return [NSNumber numberWithBool:YES];
}

- (NSNumber *)SHOW_PROCESS_ISSUE_MSG_ON_SCREEN:(NSDictionary *)dicSetting
                                  RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSNumber        *nRet;
    NSString        *szFontSizeKEY  = [dicSetting objectForKey:@"FontSizeKEY"];
    NSString        *szBackColorKEY = [dicSetting objectForKey:@"BackColorKEY"];
    NSString        *szProcessKEY   = [dicSetting objectForKey:@"ProcessKEY"];
    NSString        *szShowType     = [dicSetting objectForKey:kUserDefaultSingleOrMulti];
    NSString        *szPRCErrorMSG  = [m_dicMemoryValues objectForKey:@"ProcessMessage"];
    NSDictionary    *dicSendCMD     = [dicSetting objectForKey:@"SEND_COMMAND"];
    NSDictionary    *dicReadCMD     = [dicSetting objectForKey:@"READ_COMMAND"];
    if (nil == szShowType)
    {
		[szReturnValue setString:@"PASS"];
        return [NSNumber numberWithBool:YES];
    }
    if (nil == szPRCErrorMSG ||
        [szPRCErrorMSG isEqualToString:@""] ||
        m_bFinalResult)
    {
        return [NSNumber numberWithBool:YES];
    }
    NSRange		range			= [szShowType rangeOfString:kUserDefaultSingleMode
										 options:NSCaseInsensitiveSearch];
    if(range.location == NSNotFound
	   || range.length == 0
	   || (range.location+range.length) > [szShowType length])
    {
        [m_dicMemoryValues setObject:@"l" forKey:szFontSizeKEY];
        [m_dicMemoryValues setObject:[m_dicMemoryValues objectForKey:kIADeviceDeviceColor] forKey:szBackColorKEY];
        [m_dicMemoryValues setObject:szPRCErrorMSG forKey:szProcessKEY];
    }
	else
    {
        [m_dicMemoryValues setObject:@"l" forKey:szFontSizeKEY];
        [m_dicMemoryValues setObject:@"0x000000" forKey:szBackColorKEY];
        [m_dicMemoryValues setObject:szPRCErrorMSG forKey:szProcessKEY];
    }
    nRet = [self SEND_COMMAND:dicSendCMD];
    if (nRet)
    {
        nRet = [self READ_COMMAND:dicReadCMD RETURN_VALUE:szReturnValue];
        return nRet;
    }
    [szReturnValue setString:@"Can't set the process issue on screen!"];
    return nRet;
}
-(NSNumber *)SELECT_BOOTARGS_STATION:(NSDictionary *)dictSetting
						RETURN_VALUE:(NSMutableString *)szReturnValue
{
	NSNotificationCenter	*nc	= [NSNotificationCenter defaultCenter];
	[nc postNotificationName:(NSString*)kNoteStartCSDStationChoice
					  object:self];
	while(1)
	{
		if([[NSThread currentThread] isCancelled])
			return [NSNumber numberWithBool:NO];
		@synchronized(m_dicMemoryValues)
		{
			if([m_dicMemoryValues objectForKey:@"SELECTED_STATION"])
				return [NSNumber numberWithBool:YES];
		}
	}
}

- (NSNumber *)ALSO_ALLOWED_SPEC:(NSDictionary *)dictPara
				   RETURN_VALUE:(NSMutableString *)szReturnValue
{
	BOOL bResult = YES;
	bResult = [[self JUDGE_SPEC:dictPara
				   RETURN_VALUE:szReturnValue] boolValue];
	if (bResult)
		m_iAlsoAllowedCount ++;
	bResult &= [[self CHANGE_PRE_SUBITEM_RESULT:dictPara
								   RETURN_VALUE:szReturnValue] boolValue];
	
	return [NSNumber numberWithBool:bResult];
}

- (NSNumber *)ALSO_ALLOWED_COUNT:(NSDictionary *)dictPara
				   RETURN_VALUE:(NSMutableString *)szReturnValue
{
	BOOL bResult = YES;
	int iAllowedCount = [[dictPara objectForKey:@"COUNT"] intValue];
	
	bResult = (m_iAlsoAllowedCount <= iAllowedCount);
	return [NSNumber numberWithBool:bResult];
}

// Add for MBT-OQC station
-(NSNumber *)COUNT_CERTAIN_VALUE:(NSDictionary *)dicSetting
                    RETURN_VALUE:(NSMutableString *)szReturnValue
{
    BOOL bResult = YES;
    bResult   = [[self JUDGE_SPEC:dicSetting RETURN_VALUE:szReturnValue] boolValue];
    if (bResult) {
        m_iAllCount ++;
        [m_dicMemoryValues setValue:[NSNumber numberWithInt:m_iAllCount] forKey:@"ALLCOUNT"];
    }
    return  [NSNumber numberWithBool:YES];
    
}

//Add for change the spec name
-(NSNumber *)CHANGE_SPECNAME:(NSDictionary *)dicPara
                RETURN_VALUE:(NSMutableString *)szReturenValue
{
    NSString    *szPostfix  = ([dicPara objectForKey:kFZ_Script_MemoryKey]) ?
                                [dicPara objectForKey:kFZ_Script_MemoryKey] : [NSString stringWithFormat:@"%@", szReturenValue];
    if (nil == szPostfix &&
        [szPostfix isEqualToString:@""])
    {
        ATSDebug(@"There is no postfix for spec name, no need to change the spec name!");
        return [NSNumber numberWithBool:YES];
    }
    NSString    *szPreSpce  = [NSString stringWithFormat:@"%@", m_strSpecName];
    [m_strSpecName setString:[NSString stringWithFormat:@"%@%@", KFZ_Script_JudgeSpecPrefix, szPostfix]];
    ATSDebug(@"Change spec success! Have changed the spec from [%@] to [%@].", szPreSpce, m_strSpecName);
    return [NSNumber numberWithBool:YES];
}

-(NSNumber *)JUDGE_TOTALNUM_AND_SPEC:(NSDictionary *)dicPara
                        RETURN_VALUE:(NSMutableString *)szReturenValue
{
    NSString *strComponent = [dicPara objectForKey:@"COMPONENT"];
    NSString *strTotalNum = [dicPara objectForKey:@"TOTAL_NUM"];
    NSMutableString *strHeigh = [dicPara objectForKey:@"HEIGHLIMIT"];
    NSMutableString *strLow = [dicPara objectForKey:@"LOWLIMIT"];
    
    if ([szReturenValue isEqualToString:@""]) {
        return [NSNumber numberWithBool:NO];
    }
    unsigned int iHeigh = 0;
    unsigned int iLow = 0;
    
    if ([strHeigh isNotEqualTo:@""]&&[strHeigh ContainString:@"0x"])
    {
        NSScanner		*scan	= [NSScanner scannerWithString:strHeigh];
        [scan scanHexInt:&iHeigh];
    }
    if ([strLow isNotEqualTo:@""]&&[strLow ContainString:@"0x"])
    {
        NSScanner		*scan	= [NSScanner scannerWithString:strLow];
        [scan scanHexInt:&iLow];
    }
    
    if ([strComponent isNotEqualTo:@""]&&[strTotalNum isNotEqualTo:@""]) {
        NSArray *arySaveString = [NSArray arrayWithArray:[szReturenValue componentsSeparatedByString:strComponent]];
        
        for (NSMutableString *strInArr in arySaveString)
        {
            if ([strInArr isNotEqualTo:@""])
            {
                unsigned int iResult = 0;
                if ([strInArr ContainString:@"0x"])
                {
                    NSScanner		*scan	= [NSScanner scannerWithString:strInArr];
                    [scan scanHexInt:&iResult];
                }
                else
                {
                    ATSDebug(@"The format is error, the string [%@] does not contains [0x]", strInArr);
                    return [NSNumber numberWithBool:NO];
                }
                //judge heigh spec
                if ([strHeigh isNotEqualTo:@""]) {
                    if (iResult>iHeigh)
                    {
                        return [NSNumber numberWithBool:NO];
                    }
                }
                //judge low spec
                if ([strLow isNotEqualTo:@""]) {
                    if (iResult<iLow)
                    {
                        return [NSNumber numberWithBool:NO];
                    }
                }
            }
        }
        
        //judge number
        if ([arySaveString count] == [strTotalNum intValue]) {
            return [NSNumber numberWithBool:YES];
        }
    }
    return [NSNumber numberWithBool:NO];
}

- (NSNumber *)RESTORE_DATE_COMPONENTS:(NSDictionary *)dictPara
						 RETURN_VALUE:(NSMutableString *)szReturnValue
{
	NSDate * date = [NSDate date];
	
	if (!date)
	{
		[szReturnValue setString:@"NO date found"];
		return [NSNumber numberWithBool:NO];
	}
	
	NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents * dateComponents = [gregorian components:(NSEraCalendarUnit |
															   NSYearCalendarUnit |
															   NSMonthCalendarUnit |
															   NSDayCalendarUnit |
															   NSHourCalendarUnit |
															   NSMinuteCalendarUnit |
															   NSSecondCalendarUnit |
															   NSWeekCalendarUnit |
															   NSWeekdayCalendarUnit |
															   NSWeekdayOrdinalCalendarUnit |
															   NSQuarterCalendarUnit |
															   NSWeekOfMonthCalendarUnit |
															   NSWeekOfYearCalendarUnit |
															   NSYearForWeekOfYearCalendarUnit)
													 fromDate:date];
	
	NSInteger iEra					= [dateComponents era];
	NSInteger iYear					= [dateComponents year];
	NSInteger iMonth				= [dateComponents month];
	NSInteger iDay					= [dateComponents day];
	NSInteger iHour					= [dateComponents hour];
	NSInteger iMinute				= [dateComponents minute];
	NSInteger iSecond				= [dateComponents second];
	NSInteger iWeek					= [dateComponents week];
	NSInteger iWeekday				= [dateComponents weekday];
	NSInteger iWeekdayOrdinal		= [dateComponents weekdayOrdinal];
	NSInteger iQuarter				= [dateComponents quarter];
	NSInteger iWeekOfMonth			= [dateComponents weekOfMonth];
	NSInteger iWeekOfYear			= [dateComponents weekOfYear];
	NSInteger iYearForWeekOfYear	= [dateComponents yearForWeekOfYear];
	[gregorian release];	gregorian	= nil;
	
	[m_dicMemoryValues setObject:[NSString stringWithFormat:@"%d",iEra]					forKey:@"era"];
	[m_dicMemoryValues setObject:[NSString stringWithFormat:@"%d",iYear]					forKey:@"year"];
	[m_dicMemoryValues setObject:[NSString stringWithFormat:@"%d",iMonth]				forKey:@"month"];
	[m_dicMemoryValues setObject:[NSString stringWithFormat:@"%d",iDay]					forKey:@"day"];
	[m_dicMemoryValues setObject:[NSString stringWithFormat:@"%d",iHour]					forKey:@"hour"];
	[m_dicMemoryValues setObject:[NSString stringWithFormat:@"%d",iMinute]				forKey:@"minute"];
	[m_dicMemoryValues setObject:[NSString stringWithFormat:@"%d",iSecond]				forKey:@"second"];
	[m_dicMemoryValues setObject:[NSString stringWithFormat:@"%d",iWeek]					forKey:@"week"];
	[m_dicMemoryValues setObject:[NSString stringWithFormat:@"%d",iWeekday]				forKey:@"weekday"];
	[m_dicMemoryValues setObject:[NSString stringWithFormat:@"%d",iWeekdayOrdinal]		forKey:@"weekdayOrdinal"];
	[m_dicMemoryValues setObject:[NSString stringWithFormat:@"%d",iQuarter]				forKey:@"quarter"];
	[m_dicMemoryValues setObject:[NSString stringWithFormat:@"%d",iWeekOfMonth]			forKey:@"weekOfMonth"];
	[m_dicMemoryValues setObject:[NSString stringWithFormat:@"%d",iWeekOfYear]			forKey:@"weekOfYear"];
	[m_dicMemoryValues setObject:[NSString stringWithFormat:@"%d",iYearForWeekOfYear]	forKey:@"yearForWeekOfYear"];
	
	return [NSNumber numberWithBool:YES];
}

//Add by Lorky 2014.7.2
- (NSNumber *)EZ_LINK_TEST:(NSDictionary *)dictPara
			  RETURN_VALUE:(NSMutableString *)strReturn
{
	NSString	*szPortType		= [dictPara objectForKey:kFZ_Script_DeviceTarget];
	NSString	*szBsdPath		= [[m_dicPorts objectForKey:szPortType] objectAtIndex:kFZ_SerialInfo_SerialPort];
	NSString	*szPath			= [dictPara objectForKey:@"PATH"];
	NSString	*szCommand		= [dictPara objectForKey:@"COMMAND"];
	
	NSTask	*task		= [[NSTask alloc] init];
    NSPipe	*outPipe	= [[NSPipe alloc]init];
    [task setLaunchPath:szPath];
    NSArray	*args		= [NSArray arrayWithObjects:
						   szBsdPath,szCommand,nil];
    [task setArguments:args];
    [task setStandardOutput:outPipe];
    [task launch];
    
    NSData	*data		= [[outPipe fileHandleForReading]
						   readDataToEndOfFile];
    [task waitUntilExit];
    [task release];
    [outPipe release];
    NSString	*szString	= [[NSString alloc]	initWithData:data
											   encoding:NSASCIIStringEncoding];//Modified by raniys on 3/2/2015
    ATSDebug(@"Response command command :%@",szString);
	[m_dicMemoryValues setObject:szString forKey:@"Tristar_Provision"];
    
	[IALogs CreatAndWriteUARTLog:szString
						  atTime:kIADeviceALSFileNameDate
					  fromDevice:@"MOBILE"
						withPath:[NSString stringWithFormat:
								  @"%@/%@_%@/%@_%@_Uart.txt",
								  kPD_LogPath,		m_szPortIndex,
								  m_szStartTime,	m_szPortIndex,
								  m_szStartTime]
						  binary:NO];
	
    [szString release];
	return [NSNumber numberWithBool:YES];
}

//Add by Chao 2014.9.2
- (NSNumber *)GET_TEMPLATE_MAC_ADDRESS:(NSDictionary *)dictPara
			  RETURN_VALUE:(NSMutableString *)strReturn
{
    
    NSString    *szMemoryKey    = [dictPara objectForKey:@"KEY"];
    NSString    *szSNKey        = [dictPara objectForKey:@"SNKEY"];
    NSString    *szFilePath     = [dictPara objectForKey:@"FILEPATH"];
    NSArray     *arrWriteKeys   = [dictPara objectForKey:@"WRITEKEY"];
    
	BOOL        bWrite          = NO;
    
    for (int i = 0; i < [arrWriteKeys count]; i++)
    {
        NSString    *strWriteKey    = [arrWriteKeys objectAtIndex:i];
        if ([strReturn ContainString:strWriteKey])
        {
            bWrite = YES;
        }
    }
    
    if (!bWrite)
    {
        [strReturn setString:@"NONEEDTOWRITE"];
        return [NSNumber numberWithBool:YES];
    }
    
    
    NSMutableString *strMacAddress = [[NSMutableString alloc]init];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:szFilePath] )
    {
        // Create the file to record used mac address.
        NSRunAlertPanel(@"警告",
                        @"請確認MAC Address維護文件是否存在",
                        @"确认(OK)", nil, nil);
        [strMacAddress release];
        return [NSNumber numberWithBool:NO];
    }
    else
    {
        NSString * strFileContent = [NSString stringWithContentsOfFile:szFilePath encoding:NSUTF8StringEncoding error:nil];
        ATSDebug(@"MACADDR: %@",strFileContent);
        NSArray	* arrayContents = [strFileContent componentsSeparatedByString:@"\n"];
        NSString * strLastObj = [arrayContents objectAtIndex:([arrayContents count]-2)];
        NSArray * array = [strLastObj componentsSeparatedByString:@","];
		[strMacAddress setString:[array objectAtIndex:0]];

		//get first obj
		NSString * strFirstObj	= [arrayContents objectAtIndex:0];
		NSMutableString * FirstMacAddr	= [[NSMutableString alloc]init];
		[FirstMacAddr setString:[ [strFirstObj componentsSeparatedByString:@","] objectAtIndex: 0]];
		
		//Get the header of address.
		NSString * strHeader	=[strMacAddress subByRegex:@"^(.{6})" name:nil error:nil];
		NSMutableString * strMacAddrHeader	=[[NSMutableString alloc]initWithString:strHeader];
		
		NSDictionary * dictPara = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:16],@"CHANGE",
								   [NSNumber numberWithInt:0],@"FROM",
								   [NSNumber numberWithInt:10],@"TO", nil];
		[self NumberSystemConvertion:dictPara RETURN_VALUE:strMacAddrHeader];
		
		
        if ([strMacAddress length] != 12)
        {
            NSRunAlertPanel(@"警告",
                            @"請確認MAC Address維護文件格式是否正確",
                            @"确认(OK)", nil, nil);
			[FirstMacAddr release];
			[strMacAddress release];
			[strMacAddrHeader release];
            return [NSNumber numberWithBool:NO];
        }
		// 8920993 convert to HEX : 881FA1
        else if([strMacAddrHeader intValue] == 8920993)
        {
            NSString * strPart = [strMacAddress subByRegex:@"^.{6}(.{6})" name:nil error:nil];
            NSMutableString * strMacAddrPart = [[NSMutableString alloc] initWithString:((strPart == nil) ? @"" : strPart)];
            
            [self NumberSystemConvertion:dictPara
                            RETURN_VALUE:strMacAddrPart];
            int iNewMac = [strMacAddrPart intValue] + 2;
            
			// transform the first object from 16 system to 10 system
			NSString * FirstPart = [FirstMacAddr subByRegex:@"^.{6}(.{6})" name:nil error:nil];
			NSMutableString * FirstAddrPart = [[NSMutableString alloc] initWithString:((FirstPart == nil) ? @"" : FirstPart)];
			
			
			[self NumberSystemConvertion:dictPara
							RETURN_VALUE:FirstAddrPart];

			// TODO: if iNewMac >= 15998999, iNewMac get different value base on different first object.
            if (iNewMac >= 15998999)
            {
				if ([FirstAddrPart intValue] == 15993078)
					iNewMac = 15992700;
				if ([FirstAddrPart intValue] == 15993079)
					iNewMac = 15992701;
			}
			// if the mac address which need to write equal with the initial mac address, then report error.
			if (iNewMac == [FirstAddrPart intValue])
			{
				if([FirstAddrPart intValue] == 15993078)
					iNewMac = 15983000;
				else
					iNewMac =15983001;
			}
			
			
			
            NSString * strNewMac = [NSString stringWithFormat:@"%d",iNewMac];
            [strMacAddrPart setString:strNewMac];
            dictPara = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:10],	@"CHANGE",
                        [NSNumber numberWithInt:0],		@"FROM",
                        [NSNumber numberWithInt:16],	@"TO", nil];
            [self NumberSystemConvertion:dictPara
                            RETURN_VALUE:strMacAddrPart];
			
            if (iNewMac != 15983000 && iNewMac != 15983001)
			{
				[strMacAddress setString: [NSString stringWithFormat:@"881FA1%@",strMacAddrPart]];
            }
			else
				[strMacAddress setString: [NSString stringWithFormat:@"1C1AC0%@",strMacAddrPart]];
			[strMacAddrPart release];
			[FirstMacAddr release];
			[FirstAddrPart release];
			[strMacAddrHeader release];
        }
		else
		{
			NSString * strPart = [strMacAddress subByRegex:@"^.{6}(.{6})" name:nil error:nil];
            NSMutableString * strMacAddrPart = [[NSMutableString alloc] initWithString:((strPart == nil) ? @"" : strPart)];
            
            [self NumberSystemConvertion:dictPara
                            RETURN_VALUE:strMacAddrPart];
            int iNewMac = [strMacAddrPart intValue] + 2;
            
			// TODO: if iNewMac >= 15998999, iNewMac get different value base on different first object.
            if (iNewMac >= 15990499)
            {
				NSRunAlertPanel(@"警告",
								@"沒有可用的MAC地址",
								@"确认(OK)", nil, nil);
				
				[strMacAddress release];
				[FirstMacAddr release];
				[strMacAddrPart release];
				[strMacAddrHeader release];
				
				return [NSNumber numberWithBool:NO];

			}
			NSString * strNewMac = [NSString stringWithFormat:@"%d",iNewMac];
            [strMacAddrPart setString:strNewMac];
            dictPara = [NSDictionary dictionaryWithObjectsAndKeys:
                        [NSNumber numberWithInt:10],	@"CHANGE",
                        [NSNumber numberWithInt:0],		@"FROM",
                        [NSNumber numberWithInt:16],	@"TO", nil];
            [self NumberSystemConvertion:dictPara
                            RETURN_VALUE:strMacAddrPart];

			[strMacAddress setString: [NSString stringWithFormat:@"1C1AC0%@",strMacAddrPart]];
			[strMacAddrPart release];
			[FirstMacAddr release];
			[strMacAddrHeader release];
			
		}
    }
	
	
	
    
    // 3. Memory the key to memory buffer to write.
    NSString * strWritingMac     = [self TransToWritingMacAddress:strMacAddress];
    [m_dicMemoryValues setObject:strWritingMac forKey:szMemoryKey];
    
    // 4. Write the Mac address into the resotre file.
    NSString * strMacAddr = [NSString stringWithFormat:@"%@,%@,%@,%@\n",strMacAddress,strWritingMac,[m_dicMemoryValues objectForKey:szSNKey],szMemoryKey];
    NSFileHandle	*fileHandle		= [NSFileHandle fileHandleForWritingAtPath:szFilePath];
	
    if (!fileHandle)
        [strMacAddr writeToFile:szFilePath
                     atomically:NO
                       encoding:NSUTF8StringEncoding
                          error:nil];
    else
    {
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[strMacAddr dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [strMacAddress release];
    return [NSNumber numberWithBool:YES];
}

- (NSString *)TransToWritingMacAddress:(NSString *)strOrginal
{
	if ([strOrginal length] != 12)
	{
		NSLog(@"Orginal mac address [%@] format is NOT OK",strOrginal);
		return nil;
	}
    
	NSString * strPart1 = [strOrginal subByRegex:@"^(.{2})" name:nil error:nil];
	NSString * strPart2 = [strOrginal subByRegex:@".{2}(.{2})" name:nil error:nil];
	NSString * strPart3 = [strOrginal subByRegex:@".{4}(.{2})" name:nil error:nil];
	NSString * strPart4 = [strOrginal subByRegex:@".{6}(.{2})" name:nil error:nil];
	NSString * strPart5 = [strOrginal subByRegex:@".{8}(.{2})" name:nil error:nil];
	NSString * strPart6 = [strOrginal subByRegex:@".{10}(.{2})$" name:nil error:nil];
	return [NSString stringWithFormat:@"0x%@%@%@%@ 0x0000%@%@",strPart4,strPart3,strPart2,strPart1,strPart6,strPart5];
}

- (NSNumber *)COMBINEATTRIBUTESTRING:(NSDictionary *)dictPara
                          RETURN_VALUE:(NSMutableString *)strReturn
{

	NSString * strPart1 = [strReturn subByRegex:@".{2}(.{2})" name:nil error:nil];
	NSString * strPart2 = [strReturn subByRegex:@".{4}(.{2})" name:nil error:nil];
	NSString * strPart3 = [strReturn subByRegex:@".{6}(.{2})" name:nil error:nil];
	NSString * strPart4 = [strReturn subByRegex:@".{8}(.{2})" name:nil error:nil];
	NSString * strPart5 = [strReturn subByRegex:@".{17}(.{2})" name:nil error:nil];
    NSString * strPart6 = [strReturn subByRegex:@".{19}(.{2})" name:nil error:nil];
    
    NSString    *strAttribute   = [[NSString stringWithFormat:@"%@:%@:%@:%@:%@:%@",strPart4,strPart3,strPart2,strPart1,strPart6,strPart5] lowercaseString];
    [strReturn setString: strAttribute];
	return [NSNumber numberWithBool:YES];
}


- (NSNumber *)COMBINEANDFORMATSTRING:(NSDictionary *)dictPara
                          RETURN_VALUE:(NSMutableString *)strReturn
{
    
    NSString    *szPreKey   = [dictPara objectForKey:@"PREKEY"];
    NSString    *szPostKey    = [dictPara objectForKey:@"POSTKEY"];
	BOOL		bFlip = [[dictPara objectForKey:@"Flip"] boolValue];
    NSString    *szPreValue      = [m_dicMemoryValues objectForKey:szPreKey];
    NSDictionary    *dicChange  = [dictPara objectForKey:@"Change_Return_Rule"];
    NSDictionary    *dicMapping = [dicChange objectForKey:@"Mapping"];
    int         iBegin     = [[dicChange objectForKey:@"BeginIndex"] intValue];
    int         iLength         = [[dicChange objectForKey:@"Length"] intValue];
    NSString        *szKEY      = [dicChange objectForKey:@"KEY"];
    
    if (!szPreValue || [szPreValue isEqualToString:@""])
    {
        [strReturn setString:@"NO SYSCFG VALUE"];
        return [NSNumber numberWithBool:NO];
    }
	NSString * strAll = [szPreValue stringByReplacingOccurrencesOfString:@" " withString:@""];
    strAll = [strAll stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    
    
    if ([strAll length] < 8)
    {
        [strReturn setString:@"SYSCFG VALUE FORMAT ERROR"];
        return [NSNumber numberWithBool:NO];
    }
    
    NSMutableString * mutaStrOriginal = [[NSMutableString alloc]init];
    [mutaStrOriginal setString:strAll];
    
    //for the request from Saurav_Bhatia's, need to modify the OrbG for some specail config.
    if (dicChange &&
        dicMapping &&
        szKEY)
    {
        if ([mutaStrOriginal length] >= (iBegin + iLength))
        {
            for (NSString *szKey in [dicMapping allKeys])
            {
                NSString    *szJudgeValue   = [m_dicMemoryValues objectForKey:szKEY];
                if ([szKey isEqualToString:szJudgeValue])
                {
                    NSString * strRegex     = [NSString stringWithFormat:@"^.{%d}(.{%d})",iBegin,iLength];
                    
                    NSString * strSkyVaule  = [mutaStrOriginal subByRegex:strRegex name:nil error:nil];
                    
                    if ([strSkyVaule isEqualToString:[dicMapping objectForKey:szKey]])
                    {
                        break;
                    }
                    [mutaStrOriginal replaceCharactersInRange:NSMakeRange(iBegin, iLength)
                                                   withString:[dicMapping objectForKey:szKey]];
                    NSDictionary    *dicCatch           = [dicChange objectForKey:@"CATCH_VALUE"];
                    if ([[dicChange objectForKey:@"NeedChangeCheckSumValue"] boolValue] &&
                        [dicCatch objectForKey:@"KEY"])
                    {
                        NSMutableString *szReturnForOrbG    = [[NSMutableString alloc] init];
                        [m_dicMemoryValues setObject:mutaStrOriginal forKey:[dicCatch objectForKey:@"KEY"]];
                        NSNumber    *nRet   = [self CATCH_VALUE:dicCatch RETURN_VALUE:szReturnForOrbG];
                        NSDictionary    *dic16to10  = [dicChange objectForKey:@"16to10"];
                        NSDictionary    *dic10to16  = [dicChange objectForKey:@"10to16"];
                        if ([nRet boolValue])
                        {
                            [self NumberSystemConvertion:dic16to10 RETURN_VALUE:szReturnForOrbG];
                            [szReturnForOrbG setString:[NSString stringWithFormat:@"%d", ([szReturnForOrbG intValue] - 1)]];
                            [self NumberSystemConvertion:dic10to16 RETURN_VALUE:szReturnForOrbG];
                            [mutaStrOriginal replaceCharactersInRange:NSMakeRange(mutaStrOriginal.length-2, 2)
                                                           withString:szReturnForOrbG];
                        }
                        [szReturnForOrbG release];
                    }
                    break;
                }
            }
        }
    }
    
                                         
    int iOriginal = [mutaStrOriginal length];
    if (iOriginal%8 != 0)
    {
        // NOTE: Here is append  '0' if it's less than 8 bits. I am not sure it's '0' or 'F'.
        for (int i = 0; i < 8 - iOriginal%8; i++)
        {
            [mutaStrOriginal appendString:@"0"];
        }
    }
    
    NSMutableString *mutaStrFormat  = [[NSMutableString alloc]initWithString:@""];
    
	for (NSUInteger i = 0; i < [mutaStrOriginal length]; i += 8 )
	{
		NSString * strOne = [mutaStrOriginal substringWithRange:NSMakeRange(i, 8)];
        NSString * strPart1 = [strOne subByRegex:@".{0}(.{2})" name:nil error:nil];
        NSString * strPart2 = [strOne subByRegex:@".{2}(.{2})" name:nil error:nil];
        NSString * strPart3 = [strOne subByRegex:@".{4}(.{2})" name:nil error:nil];
        NSString * strPart4 = [strOne subByRegex:@".{6}(.{2})" name:nil error:nil];
        
		if (bFlip)
			[mutaStrFormat appendString:[NSString stringWithFormat:@"0x%@%@%@%@ ",strPart4,strPart3,strPart2,strPart1]];
        else
			[mutaStrFormat appendString:[NSString stringWithFormat:@"0x%@%@%@%@ ",strPart1,strPart2,strPart3,strPart4]];
	}
    //Remove the last blank
    [mutaStrFormat deleteCharactersInRange:NSMakeRange(mutaStrFormat.length-1, 1)];
    [m_dicMemoryValues setObject: mutaStrFormat forKey:szPostKey];
    NSLog(@"%@",[m_dicMemoryValues objectForKey:mutaStrFormat]);
    [mutaStrOriginal release];
    [mutaStrFormat release];
    
    return [NSNumber numberWithBool:YES];
}

/* Calculate the average of the FLT station values, example as below:
 *
 * LOG 10, -299 mA
 * LOG 9, -300 mA
 * LOG 8, -299 mA
 * LOG 7, -299 mA
 * LOG 6, -300 mA
 * LOG 5, -299 mA
 * LOG 4, -300 mA
 * LOG 3, -299 mA
 * LOG 2, -300 mA
 * LOG 1, -300 mA
 *
 * We need to set the min & max index, to calculate the values that between them.
 * Notice:
 * 1. The max value must OVER the min value.
*/
- (NSNumber *)FLTAVERAGE:(NSDictionary *)dicPara
            RETURN_VALUE:(NSMutableString *)strReturn
{
    NSString    *szMIN      = [dicPara objectForKey:@"MIN"];
    NSString    *szMAX      = [dicPara objectForKey:@"MAX"];
    NSString    *szPreKey   = [dicPara objectForKey:@"PREKEY"] ? [dicPara objectForKey:@"PREKEY"] : @"PREKEY";
    NSString    *szPostKey  = [dicPara objectForKey:@"POSTKEY"] ? [dicPara objectForKey:@"POSTKEY"] : @"POSTKEY";
    NSUInteger  iLength     = [dicPara objectForKey:@"RESULTLENGTH"] ? [[dicPara objectForKey:@"RESULTLENGTH"] intValue] : 0;
    BOOL        bNeedABS    = [[dicPara objectForKey:@"NEEDABS"] boolValue];
    if ([szMIN intValue] >= [szMAX intValue] ||
        [szMIN intValue] <= 0 ||
        [szMAX intValue] <= 0)
    {
        ATSDebug(@"The max index [%@] is NOT over min index [%@], can not calculate for this, please to check the plist!", szMAX, szMIN);
        [strReturn setString:@"The index set error!"];
        return [NSNumber numberWithBool:NO];
    }
    NSMutableArray  *arrAllValues   = [[NSMutableArray alloc] init];
    NSString        *szRawData      = [NSString stringWithFormat:@"%@",
                                       ([m_dicMemoryValues objectForKey:szPreKey] ?
                                        [m_dicMemoryValues objectForKey:szPreKey] : strReturn)];
    @synchronized(m_dicMemoryValues)
    {
        [m_dicMemoryValues setObject:szRawData
                              forKey:szPreKey];
    }
    for (int i = [szMIN intValue]; i <= [szMAX intValue] ; i++)
    {
        NSString    *szRex  = [NSString stringWithFormat:@"LOG %d,(\\s*-?\\d*\\s*)mA", i];
        NSNumber    *numRet = [self CATCH_VALUE:[NSDictionary dictionaryWithObjectsAndKeys:
                                                 szPreKey, @"KEY",
                                                 szRex, @"REGEX",
                                                 nil]
                                   RETURN_VALUE:strReturn];
        if ([numRet boolValue])
        {
            [arrAllValues addObject:[NSString stringWithFormat:@"%@", strReturn]];
            ATSDebug(@"For the index [%d], catch the value [%@] sucessfully!", i, strReturn);
        }
        else
        {
            ATSDebug(@"For the index [%d], can not catch the value from [%@], just ignore it.", i, szRawData);
        }
    }
    if (0 >= [arrAllValues count])
    {
        ATSDebug(@"Can not get any value from the raw data [%@] from index [%@] to [%@]!", szRawData, szMIN, szMAX);
        [strReturn setString:szRawData];
        [arrAllValues release];
        return [NSNumber numberWithBool:NO];
    }
    double  douAverage  = [m_mathLibrary GetAverageWithArray:[NSArray arrayWithArray:arrAllValues]
                                                     NeedABS:bNeedABS];
    ATSDebug(@"Congratulations! We got the average value [%.*f] from the array [%@]", iLength, douAverage, arrAllValues);
    @synchronized(m_dicMemoryValues)
    {
        [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%.*f", iLength, douAverage]
                              forKey:szPostKey];
    }
    [arrAllValues release];
    [strReturn setString:[NSString stringWithFormat:@"%.*f", iLength ,douAverage]];
    return [NSNumber numberWithBool:YES];
}

/* Need to choose limit files base on the SOC type
 * Mapping table: 
 *      8000 ==> QT0_Limit_Maui.plist
 *      8003 ==> QT0_Limit_Malta.plist
 */
-(NSNumber *)LOADLIMITBASEONSOCTYPE:(NSDictionary *)dicPara
                       RETURN_VALUE:(NSMutableString *)strReturn
{
    //Get the script path
    NSString    *szScriptName  = [m_dicMemoryValues objectForKey:[dicPara objectForKey:kFZ_Script_MemoryKey]];
    NSString    *szVersion     = [m_dicMemoryValues objectForKey:[dicPara objectForKey:@"VersionKEY"]];
    if (nil == szScriptName ||
        [szScriptName isEqualTo:@""] ||
        nil == szVersion ||
        [szVersion isEqualTo:@""])
    {
        ATSDebug(@"The key [%@ & %@] is empty in m_dicMemoryValues, please help check!", [dicPara objectForKey:kFZ_Script_MemoryKey],[dicPara objectForKey:@"VersionKEY"]);
        [strReturn setString:@"No Script Name or Version.please tell me."];
        return [NSNumber numberWithBool:NO];
    }
    ATSDebug(@"Script Name:%@,Version:%@",szScriptName,szVersion);
    
    //Change overlay version.
    self.uiVersion  = [NSString stringWithFormat:@"%@_%@", uiVersion, szVersion];
    [self startPuddingUploadFlow];
    ATSDebug(@"Has changed the version to [%@]", uiVersion);

    szScriptName    = [szScriptName ContainString:@".plist"]? szScriptName:[NSString stringWithFormat:@"%@.plist", szScriptName];
    NSString    *szScriptPath   = [NSString stringWithFormat:@"%@/Contents/Frameworks/FunnyZone.framework/Resources/%@",
                                   [[NSBundle mainBundle] bundlePath],szScriptName];
    
    //If the SOC_limit file is not exist, just quite the app.
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:szScriptPath])
    {
        [strReturn setString:@"Can not find script file."];
        NSRunAlertPanel(@"错误(Error)",
                        @"解析%@剧本档失败。(Parser Script Fail)",
                        @"确认(OK)", nil, nil, szScriptName);
        ATSDebug(@"Terminate at [%@], Parser Script fail, Get Nil array from the path [%@]",
                 [[NSDate date] description], szScriptPath);
        [NSApp terminate:nil];
    }
    
    //Insert the limits to the m_dicMemoryValues
    NSDictionary    *dicSOCLimit    = [NSDictionary dictionaryWithContentsOfFile:szScriptPath];
    for (NSString *szKey in [dicSOCLimit allKeys])
    {
        [m_dicMemoryValues setObject:[dicSOCLimit objectForKey:szKey]
                              forKey:szKey];
        ATSDebug(@"Sucessful to add the limit [%@] for key [%@]", [dicSOCLimit objectForKey:szKey], szKey);
    }
    return [NSNumber numberWithBool:YES];
}

//Add by Shirley on 2015-03-07
- (void)writeOrbDataToLogPath:(NSString*)iPath
                      andData:(NSString*)iData
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath: iPath])
    {
        [fileManager createFileAtPath: iPath
                             contents: nil
                           attributes: nil];
        NSFileHandle *sHandle    = [NSFileHandle fileHandleForWritingAtPath: iPath];
        [sHandle seekToEndOfFile];
        [sHandle writeData: [iData dataUsingEncoding: NSUTF8StringEncoding]];
    }
    else
    {
        NSFileHandle *sNewHandle = [NSFileHandle fileHandleForWritingAtPath: iPath];
        [sNewHandle seekToEndOfFile];
        [sNewHandle writeData: [iData dataUsingEncoding: NSUTF8StringEncoding]];
    }
}

//Add by Shirley on 2015-03-06
- (NSNumber*)GET_ORB_VALUE:(NSDictionary*)dicMemoryData
              RETURN_VALUE:(NSMutableString*)szReturnValue
{
    //get the original value
    NSString    *szKey      = [dicMemoryData objectForKey:@"KEY"];
    NSString    *szTypeO    = [dicMemoryData objectForKey:@"TYPE"];
    
    int iFrames = [[dicMemoryData objectForKey:@"FRAME_COUNT"] intValue];
    BOOL        bResult     = YES;
    
    
    //set single file path
    NSString        *szFilePath    =  [NSString stringWithFormat: @"%@/%@_%@/ORB%@.txt",kPD_LogPath,
                                       m_szPortIndex,m_szStartTime,szTypeO];
    //set summary file path
    NSString *szSummaryPath             = [NSString stringWithFormat: @"%@/%@_%@/Summary.txt",kPD_LogPath,
                                       m_szPortIndex,m_szStartTime];

    NSMutableString *strAllNewData      = [[NSMutableString alloc] init];
    NSString        *szNewColumn        = [[NSString alloc] init];
    NSString        *szOriginalValue	= [m_dicMemoryValues objectForKey:szKey];
    NSArray         *arrOriginalData    = [szOriginalValue componentsSeparatedByString: @"Iteration"];
    //add the title for sing summary log
    NSString     *szType      = [NSString stringWithFormat: @"----------------------------  %@  ----------------------------\n",szTypeO];
    [self writeOrbDataToLogPath: szSummaryPath
                        andData: szType];
    for (int i = 1; i < [arrOriginalData count]; i++)
    {
        NSString *strSingleGap = [arrOriginalData objectAtIndex:i];
        strSingleGap = [strSingleGap SubFrom:[NSString stringWithFormat:@"%d/%d:\n\n\t\"touch\"",i,iFrames] include:NO];
        NSArray *arrSingleGap = [strSingleGap componentsSeparatedByString:@"\n"];
        //The data isn't integrated
        if ([arrSingleGap count] < 14)
        {
            //If no data, single log
            NSString     *szNoData        = [NSString stringWithFormat: @"data format error\n"];
            //Write single log
            [self writeOrbDataToLogPath:szFilePath
                                andData:szNoData];
            
            //Write single summary log
            [self writeOrbDataToLogPath: szSummaryPath
                                andData: szNoData];
            
            ATSDebug(@"GET_OBD_VALUE => Get Fail : The data isn't integrated! ");
            return [NSNumber numberWithBool:NO];
        }
        else
        {
            //have data
            for ( int k =13; k >= 2; k--)
            {
                NSString       *szSingleColumn  = [arrSingleGap objectAtIndex: k];
                NSArray        *arrSingleColumn = [szSingleColumn componentsSeparatedByString: @"\t"];
                NSMutableArray *arrNewColumn    = [[NSMutableArray alloc] init];
                
                if([arrSingleColumn count] >=9)
                {
                    for ( int j = 1; j<= 8; j++)
                    {
                        NSString *szOneData = [arrSingleColumn objectAtIndex: j];
                        [arrNewColumn addObject: szOneData];
                    }
                }
                else
                {
                    ATSDebug(@"GET_OBD_VALUE => Get Fail : The data format is abnormal ");
                    return [NSNumber numberWithBool:NO];
                }
               
                
                szNewColumn             = [arrNewColumn componentsJoinedByString: @"\t"];
                NSString *szWriteColumn = [NSString stringWithFormat: @"%@\n", szNewColumn];
                [strAllNewData appendString: szWriteColumn];
                
            }
            //Write single log
            [strAllNewData appendFormat:@"\n"];
            ATSDebug(@"GET_OBD_VALUE => Get OK : %@", strAllNewData);
            
        }
    }
    [self writeOrbDataToLogPath:szFilePath
                        andData:strAllNewData];
    
    //Write single summary log
    [self writeOrbDataToLogPath:szSummaryPath
                        andData:strAllNewData];
    [szReturnValue setString: strAllNewData];
    [strAllNewData release]; strAllNewData = nil;
    return [NSNumber numberWithBool:bResult];
}

/*
 Add by raniys on 3/11/2015
 Description:    Add for bitwise operators
 Param:
 KEY1             -> string1
 KEY1             -> string2
 OPERATOR         -> the value should be "AND"/"OR"/"XOR"
 MEMORYKEY        -> Memory key
 szReturnValue    -> Caculate result
 */
- (NSNumber *)BITWISE_OPERATOR_WITH_DATA:(NSDictionary *)dicOriginalData
                          RETURN_VALUE:(NSMutableString *)szReturnValue
{
    
    NSString *strOriginalValue1     = [m_dicMemoryValues objectForKey:[dicOriginalData objectForKey:@"KEY1"]];
    NSString *strOriginalValue2     = [m_dicMemoryValues objectForKey:[dicOriginalData objectForKey:@"KEY2"]];
    NSString *strOperator           = [dicOriginalData objectForKey:@"OPERATOR"];
    NSString *strMemoryKEY          = [dicOriginalData objectForKey:@"MEMORYKEY"];
    
    NSArray *aryData1   = [strOriginalValue1 componentsSeparatedByString:@" "];
    NSArray *aryData2   = [strOriginalValue2 componentsSeparatedByString:@" "];
    NSMutableString *strResult  = [[NSMutableString alloc]init];
    if ([aryData1 count] == [aryData2 count])
    {
        for (int i = 0; i < [aryData1 count]; i++)
        {
            NSString *strValue1 = [aryData1 objectAtIndex:i];
            NSString *strValue2 = [aryData2 objectAtIndex:i];
            if (([strValue1 isEqualToString:@""] || [strValue1 isEqualToString:@" "] || strValue1 == nil)
                || ([strValue2 isEqualToString:@""] || [strValue2 isEqualToString:@" "] || strValue2 == nil))
                continue;
            
            NSMutableString *strFirst   = [[NSMutableString alloc]init];
            NSMutableString *strSecond  = [[NSMutableString alloc]init];
            
            [self HexWithInt:strValue1 ReturnValue:strFirst];
            [self HexWithInt:strValue2 ReturnValue:strSecond];
            
            if ([strOperator isEqualToString:@"AND"])
            {
                NSMutableString *strBuffer = [[NSMutableString alloc] init];
                unsigned long iResult = [strFirst integerValue] & [strSecond integerValue];
                NSString *strInput = [NSString stringWithFormat:@"%ld",iResult];
                [self HexWithInt:strInput ReturnValue:strBuffer];
                [strResult appendString:[NSString stringWithFormat:@"%@", strBuffer]];
                [strBuffer release]; strBuffer = 0;
            }
            else if ([strOperator isEqualToString:@"OR"])
            {
                NSMutableString *strBuffer = [[NSMutableString alloc] init];
                unsigned long iResult = [strFirst integerValue] | [strSecond integerValue];
                NSString *strInput = [NSString stringWithFormat:@"%ld",iResult];
                [self HexWithInt:strInput ReturnValue:strBuffer];
                [strResult appendString:[NSString stringWithFormat:@"%@", strBuffer]];
                [strBuffer release]; strBuffer = 0;
            }
            else if ([strOperator isEqualToString:@"XOR"])
            {
                NSMutableString *strBuffer = [[NSMutableString alloc] init];
                unsigned long iResult = [strFirst integerValue] ^ [strSecond integerValue];
                NSString *strInput = [NSString stringWithFormat:@"%ld",iResult];
                [self HexWithInt:strInput ReturnValue:strBuffer];
                [strResult appendString:[NSString stringWithFormat:@"%@", strBuffer]];
                [strBuffer release]; strBuffer = 0;
            }
            else
            {
                [szReturnValue setString:@"Invalid operator for bitwise"];
                return [NSNumber numberWithBool:NO];
            }
            
            if (i != [aryData1 count]-1)
            {
                [strResult appendString:@" "];
            }
            [strFirst release]; strFirst = nil;
            [strSecond release]; strSecond = nil;
        }
    }
    else
    {
        [szReturnValue setString:@"Invalid data for bitwise"];
        return [NSNumber numberWithBool:NO];
    }
    NSLog(@"%@", strResult);
    [m_dicMemoryValues setObject:strResult forKey:strMemoryKEY];
    [szReturnValue setString:strResult];
    [strResult release]; strResult = nil;
    return [NSNumber numberWithBool:YES];
}

-(void)HexWithInt:(NSString *)str
      ReturnValue:(NSMutableString *)returnValue
{
    if ([str isEqualToString:@""] || str == nil)
    {
        return;
    }
    NSString    *buffer = [NSString string];
    NSScanner   *scanner= [NSScanner new];
    NSString *strData = [str uppercaseString];
    strData = [strData stringByReplacingOccurrencesOfString:@" " withString:@","];
    strData = [strData stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    strData = [strData stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    if ([strData contains:@","])
    {
        NSArray     *array  = [NSArray arrayWithArray:[strData componentsSeparatedByString:@","]];
        for (NSString *strIndex in array)
        {
            buffer = @"";
            scanner = [NSScanner scannerWithString:strIndex];
            if([strIndex contains:@"0X"])
            {
                NSString *string = [strIndex SubFrom:@"0X" include:NO];
                for (int i = 0; i < [string length]; i++)
                {
                    if ([string characterAtIndex:i] > 'F')
                    {
                        buffer = [NSString stringWithFormat:@"%@:Invalid data\n", strIndex];
                        break;
                    }
                }
                if ([buffer isNotEqualTo:@""])
                {
                    [returnValue appendString:buffer];
                    continue;
                }
                unsigned long long	iValue;
                if([scanner scanHexLongLong:&iValue])
                {
                    buffer = [NSString stringWithFormat:@"%@:%llu\n", strIndex,iValue];
                }
                else
                {
                    buffer = [NSString stringWithFormat:@"%@:Invalid data\n", strIndex];
                }
            }
            else
            {
                long long int iIntNumber = [strIndex longLongValue];
                if ([strIndex isEqualToString:[NSString stringWithFormat:@"%llu", iIntNumber]])
                {
                    NSMutableString *strHexValue = [[NSMutableString alloc] init];
                    [self Int2Hex:iIntNumber Return_Value:strHexValue];
                    buffer = [NSString stringWithFormat:@"%@:0x%@\n",strIndex,strHexValue];
                    [strHexValue release]; strHexValue = nil;
                }
                else
                    buffer = [NSString stringWithFormat:@"%@:Invalid data\n", strIndex];
            }
            [returnValue appendString:buffer];
        }
    }
    else
    {
        buffer = @"";
        scanner = [NSScanner scannerWithString:strData];
        if([strData contains:@"0X"])
        {
            NSString *string = [strData SubFrom:@"0X" include:NO];
            for (int i = 0; i < [string length]; i++)
            {
                if ([string characterAtIndex:i] > 'F')
                {
                    buffer = @"Invalid data\n";
                    break;
                }
            }
            if ([buffer isNotEqualTo:@""])
            {
                [returnValue setString:buffer];
            }
            else
            {
                unsigned long long	iValue;
                if([scanner scanHexLongLong:&iValue])
                {
                    [returnValue setString:[NSString stringWithFormat:@"%llu", iValue]];
                }
                else
                {
                    [returnValue setString:@"Invalid data"];
                }
            }
        }
        else if ([strData contains:@"0"])
        {
            [returnValue setString:@"0x0"];
        }
        else
        {
            long long int iIntNumber = [strData longLongValue];
            if ([strData isEqualToString:[NSString stringWithFormat:@"%llu", iIntNumber]])
            {
                NSMutableString *strHexValue = [[NSMutableString alloc] init];
                [self Int2Hex:iIntNumber Return_Value:strHexValue];
                [returnValue setString:[NSString stringWithFormat:@"0x%@",strHexValue]];
                [strHexValue release]; strHexValue = nil;
            }
            else
                [returnValue setString:@"Invalid data"];
        }
        
    }
}

- (void)Int2Hex:(long long int)iInput Return_Value:(NSMutableString*)strHex
{
    NSString *strLetterValue;
    NSString *strOutput = @"";
    int iRemainder;
    while (iInput != 0)
    {
        iRemainder  = iInput%16;
        iInput      = iInput/16;
        
        iRemainder  = iRemainder<=9?'0'+iRemainder:'A'-10+iRemainder;
        strLetterValue = [NSString stringWithFormat:@"%c", iRemainder];
        strOutput   = [strLetterValue stringByAppendingString:strOutput];
    }
    [strHex setString:strOutput];
}

//Add by Shirley on 2015-03-14
- (NSNumber*)CACULATE_MUON_VALUE:(NSDictionary*)dicMemoryData
                    RETURN_VALUE:(NSMutableString*)szReturnValue
{
    //get the original value
    NSString        *szData        = [dicMemoryData objectForKey:@"KEY"];
    NSString        *szType        = [dicMemoryData objectForKey:@"TYPE"];
    int             iLength        = [[dicMemoryData objectForKey:@"LENGTH"] intValue];
    
    
    NSArray *arrSeparate = [[m_dicMemoryValues objectForKey:szData] componentsSeparatedByString: @"\n"];
    
    //get the every CH0_DATA column
    NSMutableArray *arrBufferColumn = [[NSMutableArray alloc] init];
    for (int i = 0; i < [arrSeparate count]; i++)
    {
        NSString *singleColumn = [arrSeparate objectAtIndex: i];
        if ([singleColumn rangeOfString: @"CH0_DATA"].location != NSNotFound)
        {
            [arrBufferColumn addObject: singleColumn];
        }
    }
    
    //The data isn't integrated
    if ([arrBufferColumn count] < iLength)
    {
        ATSDebug(@"GET_OBD_VALUE => Get Fail : The data isn't integrated! ");
        return [NSNumber numberWithBool:NO];
    }
    else
    {
        //get the data
        NSMutableArray *arrBufferData = [[NSMutableArray alloc] init];
        for (int j = 0; j < [arrBufferColumn count]; j++)
        {
            NSString *szSingle   = [arrBufferColumn objectAtIndex: j];
            NSString *szNeedData = [szSingle subByRegex: @"CH0_DATA:(\\d*?)$" name:nil error: nil];
            if ((szNeedData != nil) && (![szNeedData isEqualToString: @""]))
            {
                [arrBufferData addObject: szNeedData];
            }
        }
        
        NSLog(@"%@", arrBufferData);
        
        //Average
        if ([szType isEqualToString: @"AVERAGE"])
        {
            double dSum = 0.0f;
            double dAverage = 0;
            for (int k=0; k < [arrBufferData count]; k++)
            {
                dSum += [[arrBufferData objectAtIndex: k] doubleValue] ;
            }
            dAverage = dSum/[arrBufferData count];
            NSString *szAverage = [NSString stringWithFormat: @"%.2f", dAverage];
            
            NSLog(@"%@", szAverage);
            [szReturnValue setString: szAverage];
        }
        
        
        //MAX
        if ([szType isEqualToString: @"MAX"])
        {
            double dMax = [[arrBufferData objectAtIndex: 0] doubleValue];
            for (int l = 1; l < [arrBufferData count]; l++)
            {
                double dMaxAmong = [[arrBufferData objectAtIndex: l] doubleValue];
                if (dMaxAmong > dMax)
                {
                    dMax = dMaxAmong;
                }
            }
            
            NSString *szMax = [NSString stringWithFormat: @"%.2f", dMax];
            NSLog(@"%@", szMax);
            [szReturnValue setString: szMax];
        }
        
        
        //MIN
        if ([szType isEqualToString: @"MIN"])
        {
            double dMin = [[arrBufferData objectAtIndex: 0] doubleValue];
            for (int m = 1; m < [arrBufferData count]; m++)
            {
                double dMinAmong = [[arrBufferData objectAtIndex: m] doubleValue];
                if (dMinAmong < dMin)
                {
                    dMin = dMinAmong;
                }
            }
            NSString *szMin = [NSString stringWithFormat: @"%.2f", dMin];
            NSLog(@"%@", szMin);
            [szReturnValue setString: szMin];
        }
        
        ATSDebug(@"GET_OBD_VALUE => Get OK : %@", szReturnValue);
        return [NSNumber numberWithBool:YES];
    }
}

- (NSNumber*)ORB_IMAGE_CATCH:(NSDictionary*)dicMemoryData
                RETURN_VALUE:(NSMutableString*)szReturnValue
{
    BOOL    bResult = YES;
    NSString    *szInputKey     = [dicMemoryData objectForKey:@"IN"];
    NSString    *szInputValue   = [m_dicMemoryValues objectForKey:szInputKey];
    NSString    *szOutPutKey    = [dicMemoryData objectForKey:@"OUT"];
    
    int iCount  = [[dicMemoryData objectForKey:@"DATA_COUNT"]intValue];
    NSArray     *arrData = [szInputValue componentsSeparatedByString:@" "];
    NSMutableArray  *aryOldCommands = [[NSMutableArray alloc] init];
    for (int i = 0; i < [arrData count]; i++)
    {
        if ([arrData objectAtIndex:i] != nil && [[arrData objectAtIndex:i] isNotEqualTo:@""])
        {
            [aryOldCommands addObject:[arrData objectAtIndex:i]];
        }
    }
    
    NSMutableString *strSensorData  = [[NSMutableString alloc]init];
    NSMutableArray *aryOrbData      = [[NSMutableArray alloc] init];
    if ([aryOldCommands count] < 4 * iCount
        || ![szInputValue contains:@"0x2"]
        || [[aryOldCommands objectAtIndex:0] isNotEqualTo:@"0x4"])
    {
        [szReturnValue setString:@"RESPONSE ERROR"];
        bResult = NO;
    }
    else
    {
        int iRow = 0;
        for (int i = 1; i < [aryOldCommands count]; i++)
        {
            if (i % 7 == 1)
                iRow++;
            if (iRow == 3)
            {
                [aryOrbData addObject:[aryOldCommands objectAtIndex:i]];
            }
        }
        
        if (aryOrbData == nil || [[aryOrbData objectAtIndex:0] isNotEqualTo:@"0x2"])
        {
            [szReturnValue setString:@"Orb value ERROR"];
            bResult = NO;
        }
        else
        {
            for (int i = 1; i < [aryOrbData count] - 1; i++)
            {
                [strSensorData appendString:[aryOrbData objectAtIndex:i]];
                [strSensorData appendString:@" "];
            }
        }
        
        [szReturnValue setString:strSensorData];
        [m_dicMemoryValues setObject:strSensorData forKey:szOutPutKey];
    }
    
    [strSensorData release]; strSensorData = nil;
    [aryOrbData release]; aryOrbData = nil;
    [aryOldCommands release]; aryOldCommands = nil;
    return [NSNumber numberWithBool:bResult];
}


- (NSNumber*)FORMAT_GAP_COMMAND:(NSDictionary*)dicMemoryData
                     RETURN_VALUE:(NSMutableString*)szReturnValue
{
    BOOL    bResult = YES;
    NSString    *szInputKey     = [dicMemoryData objectForKey:@"IN"];
    NSString    *szInputValue   = [m_dicMemoryValues objectForKey:szInputKey];
    NSString    *szOutPutKey    = [dicMemoryData objectForKey:@"OUT"];
    
    int iCount  = [[dicMemoryData objectForKey:@"DATA_COUNT"]intValue];
    NSArray     *arrData = [szInputValue componentsSeparatedByString:@" "];
    NSMutableArray  *aryOldCommands = [[NSMutableArray alloc] init];
    for (int i = 0; i < [arrData count]; i++)
    {
        if ([arrData objectAtIndex:i] != nil && [[arrData objectAtIndex:i] isNotEqualTo:@""])
        {
            [aryOldCommands addObject:[arrData objectAtIndex:i]];
        }
    }
    
    NSMutableString *strCommand = [[NSMutableString alloc]init];
    if ([aryOldCommands count] < iCount)
    {
        [szReturnValue setString:@"RESPONSE ERROR"];
        bResult = NO;
    }
    else
    {
        for (int i = 0; i < [aryOldCommands count]; i++)
        {
            if (i == [aryOldCommands count] - 1)
            {
                [strCommand appendFormat:@"%@",[aryOldCommands objectAtIndex:i]];
            }
            else
            {
                [strCommand appendFormat:@"%@ ",[aryOldCommands objectAtIndex:i]];
            }
        }
        [szReturnValue setString:strCommand];
        [m_dicMemoryValues setObject:strCommand forKey:szOutPutKey];
    }
    
    [strCommand release]; strCommand = nil;
    [aryOldCommands release]; aryOldCommands = nil;
    return [NSNumber numberWithBool:bResult];
}

- (NSNumber*)FORMAT_TOUCH_COMMAND:(NSDictionary*)dicMemoryData
                    RETURN_VALUE:(NSMutableString*)szReturnValue
{
    NSString    *szInputKey     = [dicMemoryData objectForKey:@"IN"];
    NSString    *szInputValue   = [m_dicMemoryValues objectForKey:szInputKey];
    NSString    *szOutPutKey    = [dicMemoryData objectForKey:@"OUT"];
    
    
    NSArray     *arrOldCommands = [szInputValue componentsSeparatedByString:@" "];
    
    NSMutableString *strCommand = [[NSMutableString alloc]init];
    
    
    if ([arrOldCommands count] < 31)
    {
        [szReturnValue setString:@"RESPONSE ERROR"];
        return [NSNumber numberWithBool:NO];
    }
    
    
    for (int i = 0; i < [arrOldCommands count]; i++)
    {
        if (i == 30)
        {
            [strCommand appendString:@"0x00 "];
        }
        else if (i == [arrOldCommands count] - 1)
        {
            [strCommand appendFormat:@"%@",[arrOldCommands objectAtIndex:i]];
        }
        else
        {
            [strCommand appendFormat:@"%@ ",[arrOldCommands objectAtIndex:i]];
        }
    }
    
    [szReturnValue setString:strCommand];
    [m_dicMemoryValues setObject:strCommand forKey:szOutPutKey];
    
    [strCommand release];
    return [NSNumber numberWithBool:YES];
    
}

- (NSNumber*)LOOPTESTDOE:(NSDictionary*)dicMemoryData
                     RETURN_VALUE:(NSMutableString*)szReturnValue
{
    int     iCounts     = [[dicMemoryData objectForKey:@"TIMES"] intValue];
    NSArray *arrItems   = [dicMemoryData objectForKey:@"ITEMS"];
    
    BOOL    bYet    = YES;
    
    
    for (int i = 0; i < iCounts; i++)
    {
        
        for (int j = 0; j < [arrItems count]; j++)
        {
            NSDictionary    *dicItemData    = [arrItems objectAtIndex:j];
            
            NSString        *strSubItemName = [[dicItemData allKeys] objectAtIndex:0];
            NSDictionary    *dicSubItemPara = [dicItemData objectForKey:strSubItemName];
            
            SEL selectorFunction    = NSSelectorFromString(strSubItemName);
            if ([self respondsToSelector:selectorFunction])
            {
                bYet &= [[self performSelector:selectorFunction withObject:dicSubItemPara withObject:szReturnValue] boolValue];
            }
            else
            {
                [szReturnValue setString:@"Can't found the selector function"];
                return [NSNumber numberWithBool:NO];
            }

        }
    }
    return [NSNumber numberWithBool:YES];
    
}

- (NSNumber*)LOOP_CHECK:(NSDictionary*)dicMemoryData
		   RETURN_VALUE:(NSMutableString*)szReturnValue
{
	NSArray *arrItems   = [dicMemoryData objectForKey:@"LOOP_ITEMS"];
	//NSString *strExpec = [dicMemoryData objectForKey:@"EXPECT_VALUE"];
	float iDownLimit = [[dicMemoryData objectForKey:@"DOWN_LIMIT"] floatValue];
	float iUpLimit = [[dicMemoryData objectForKey:@"UP_LIMIT"] floatValue];
	float fFixtureValue = 0;
	BOOL    bYet		= YES;
	BOOL    	bFirstSuccess  = NO;
	BOOL    	bSecondSucess  = NO;
	NSDate			*dtStartTime	= [NSDate date];
	NSTimeInterval	dEndTime		= 0.0;
	double inTimeOut = [[dicMemoryData objectForKey:@"TIMEOUT"]doubleValue];
	NSTimeInterval inIntervalTime =0.01;
	do{
		for (int i = 0; i < [arrItems count]; i++)
		{
			NSDictionary    *dicItemData    = [arrItems objectAtIndex:i];
			NSString        *strSubItemName = [[dicItemData allKeys] objectAtIndex:0];
			NSDictionary    *dicSubItemPara = [dicItemData objectForKey:strSubItemName];
			
			SEL selectorFunction    = NSSelectorFromString(strSubItemName);
			if ([self respondsToSelector:selectorFunction])
			{
				bYet &= [[self performSelector:selectorFunction withObject:dicSubItemPara withObject:szReturnValue] boolValue];
			}
			else
			{
				[szReturnValue setString:@"Can't found the selector function"];
				bFirstSuccess = NO;
			}
		}
		NSString *strRealValue = [m_dicMemoryValues objectForKey:@"CYLINDER_POSITION"];
		NSString *strCatchValue = [strRealValue substringWithRange:NSMakeRange(9, 11)];
		NSString *strTemp =[NSString stringWithFormat:@"0x%@",[strCatchValue stringByReplacingOccurrencesOfString:@" " withString:@""]];
		
		[[NSScanner scannerWithString:strTemp]scanHexFloat:&fFixtureValue];
		
		if (bFirstSuccess)
		{
			if ((fFixtureValue/100 >=iDownLimit) && (fFixtureValue/100<=iUpLimit))
				bSecondSucess = YES;
			else
				bSecondSucess = NO;
			break;
		}
		
		if ((fFixtureValue/100 >=iDownLimit) && (fFixtureValue/100<=iUpLimit))
			bFirstSuccess = YES;
		
		[NSThread sleepForTimeInterval:inIntervalTime];
		dEndTime	= [[NSDate date] timeIntervalSinceDate:dtStartTime];
	}while (inTimeOut >= dEndTime);
	
	ATSDebug(@"The CYLINDER position is: [%f]",fFixtureValue/100);
	if (bSecondSucess)
		return [NSNumber numberWithBool:YES];
	return [NSNumber numberWithBool:NO];
}

- (NSNumber*)CHECK_MESA_STATUS:(NSDictionary*)dicMemoryData
                  RETURN_VALUE:(NSMutableString*)szReturnValue
{
    BOOL    bReturn = NO;
    NSString    *szProvisionStatus  = [m_dicMemoryValues objectForKey:[dicMemoryData objectForKey:@"STATUS"]];
    NSString    *szProvisionDatas  = [m_dicMemoryValues objectForKey:[dicMemoryData objectForKey:@"DATAS"]];
    
    //if “yes” , it means the unit is not under  “ATE” mode ( not Fresh unit )
    if ([szProvisionStatus isEqualToString:@"yes"])
    {
        //if the mesa module is  in “Unpaired” status , then skip  “load firmware” & skip  X404 Module SN
        if ([szProvisionDatas isEqualToString:@"0x1D"])
        {
            [szReturnValue setString:@"UNPAIRED"];
            bReturn = NO;
        }
        else
        {
            [szReturnValue setString:@"PAIRED"];
            bReturn = YES;
        }
    }
    else
    {
        [szReturnValue setString:@"ATE"];
        bReturn = YES;
    }
    
    return [NSNumber numberWithBool:bReturn];
    
}

//Add by raniys for upload 96 pixel parametric data
- (NSNumber *)UPLOAD_ORB_PARAMETRIC:(NSDictionary *)dicPara
                       RETURN_VALUE:(NSMutableString *)szReturnValue
{
    BOOL bResult        = YES;
    BOOL bNo_Write_CSV  = [[dicPara objectForKey:@"NO_WRITE_CSV"]boolValue];
    NSString *strOriginaleData  = [m_dicMemoryValues objectForKey:[dicPara objectForKey:kFZ_Script_MemoryKey]];
    NSString *strParametricName = [dicPara objectForKey:@"PARAMETRIC_NAME"];
    NSString *strHighLimit      = [dicPara objectForKey:@"HIGH_LIMIT"];
    NSString *strLowLimit       = [dicPara objectForKey:@"LOW_LIMIT"];
    
    NSMutableArray *arrAllValues = [[NSMutableArray alloc]init];
    NSArray *aryRowDatas    = [strOriginaleData componentsSeparatedByString:@"\n"];
    for (int i = 0; i < [aryRowDatas count]; i++)
    {
        NSArray *aryColDatas = [[aryRowDatas objectAtIndex:i] componentsSeparatedByString:@"\t"];
        for (int j = 0; j < [aryColDatas count]; j++)
        {
            if ([[aryColDatas objectAtIndex:j] isNotEqualTo:@""] && [aryColDatas objectAtIndex:j] != nil)
                [arrAllValues addObject:[aryColDatas objectAtIndex:j]];
        }
    }

    if ([arrAllValues count] != 0)
    {
        for (int i = 0; i < [arrAllValues count]; i++)
        {
            NSDictionary *dicContents = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSString stringWithFormat:@"%hhd",bNo_Write_CSV],kFunnyZoneNOWriteCsvToLogFile,
                                         strLowLimit,kFZ_Script_ParamLowLimit,
                                         strHighLimit,kFZ_SCript_ParamHighLimit,
                                         @"NO",@"IsCSVHexParaDec",
                                         [NSString stringWithFormat:@"%@_%d",strParametricName,i+1],kFZ_Script_UploadParametric,nil];
            [self UPLOAD_PARAMETRIC: dicContents
                       RETURN_VALUE:[arrAllValues objectAtIndex:i]];
        }
    }
    else
        bResult = NO;
    [arrAllValues release]; arrAllValues = nil;
    return [NSNumber numberWithBool:bResult];
}


//add by Allen_liu
//Function:  when test fail, alert a dialog panel to tell OP scan FCSN to upload the test record.
//CHECKKEY is testing if the FCSN is exist or not, if exist, return YES. If not, need send an alert to warn op scan FCSN to upload.

-(NSNumber *)SCAN_SN_FOR_UPLOAD_FAIL_RECORD:(NSDictionary *)dicPara RETURN_VALUE:(NSMutableString *)strReturn
{
    
    ATSDebug(@"start RunAlterPanel");
    NSString	*szInputMSG		= [dicPara objectForKey:@"MESSAGE"];
    NSString	*szButtons	= [dicPara objectForKey:@"ABUTTONS"];
    NSString    *szMemoryFCSNKey   =[dicPara objectForKey:@"KEY"];
    NSString    *szCheckKey        =[dicPara objectForKey:@"CHECKKEY"];
    
    
    m_bPanelThread	= YES;
    NSString *szMSG   =  @"";
    m_iPanelReturnValue = [self TransformKeyToValue:szInputMSG returnValue:&szMSG];
    
    if ([m_dicMemoryValues objectForKey:szCheckKey])
    {
        [m_dicMemoryValues setObject:[m_dicMemoryValues objectForKey:szCheckKey] forKey:szMemoryFCSNKey];
        ATSDebug(@"SN SHOULD BE UPLOADED IS %@", [m_dicMemoryValues objectForKey:szMemoryFCSNKey]);
        return [NSNumber numberWithBool:YES];
        
        
    }
    else
    {
        
        if (szMSG == nil || szButtons == nil)
        {
            ATSDebug(@"No Message or no button number!");
            NSRunAlertPanel(@"警告(Warning)!",
                            @"设定挡没有预设消息对话框的内容和按键的种类。(There are no Msg and Button No.)",
                            @"确认（OK）", nil, nil);
        }
        else
        {
            
            [self performSelectorOnMainThread:@selector(ShowAlertToStoreFCSN:)
                                   withObject:[NSArray arrayWithObjects:szMSG,szButtons,szMemoryFCSNKey,nil]
                                waitUntilDone:YES];
            
        }
        
        do
        {
            [NSThread sleepForTimeInterval:1];
            ATSDebug(@"Wait Panel......End %d",m_iPanelReturnValue);
        }
        while (m_bPanelThread == YES);
        
        if(m_iPanelReturnValue == 1)
            [strReturn setString:@"Yes"];
        
        else
            [strReturn setString:@"No"];
        ATSDebug(@"panel return value: %d",m_iPanelReturnValue);
        return [NSNumber numberWithBool:m_iPanelReturnValue];
    }
    
}
//add by allen
//show an alter and store the SN.
-(void)ShowAlertToStoreFCSN:(id)dicContect
{
    
    NSAlert         *Alert  = [NSAlert alertWithMessageText:[dicContect objectAtIndex:0]
                                              defaultButton:[dicContect objectAtIndex:1]
                                            alternateButton:nil
                                                otherButton:nil
                                  informativeTextWithFormat:@""];
    NSTextField * InputView  = [[NSTextField alloc]initWithFrame:NSMakeRect(0, 0, 245.0f, 50.0f)];
    InputView.editable       = YES;
    [Alert setAccessoryView: InputView];
    int button    =[Alert runModal];
    [InputView validateEditing];
    NSString * StoreFCSN    =[InputView stringValue];
    [m_dicMemoryValues setObject:StoreFCSN forKey:[dicContect objectAtIndex:2]];
    ATSDebug(@"Store FCSN is %@", [m_dicMemoryValues objectForKey:[dicContect objectAtIndex:2]]);
    
    
    if (button == NSAlertDefaultReturn)
    {
        
        m_iPanelReturnValue     = button;
        ATSDebug(@"Panel Click %d",m_iPanelReturnValue);
    }
    
    m_bPanelThread = NO;
    [NSApp endSheet:[Alert window]];
    [[Alert window] orderOut:self];
    [InputView release];
    NSReleaseAlertPanel(Alert);
    
    
}
@end







