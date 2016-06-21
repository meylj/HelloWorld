//
//  IADevice_Other.m
//  Izual_Lu
//
//  Created by Lu Izual on 11-5-5.
//  Copyright 2011年 PEGATRON. All rights reserved.
//

#import "IADevice_Other.h"
#import "IADevice_TestingCommands.h"
#import "IADevice_SFIS.h"

#define kOther_OSModeTool_Location          @"LOCATION"
#define kOther_OSModeTool_TimeOut           @"TIMEOUT"
#define kOther_OSModeTool_DefaultTimeOut    5
#define kOther_OSModeTool_StringEncoding    NSUTF8StringEncoding
#define kHallEffect_CaluteDistance_Value    (10000/(4.959702-(-0.358978)))

NSString * const TiltFixtureNotificationToUI = @"TiltFixtureNotificationToUI";
NSString * const TiltFixtureNotificationToFZ = @"TiltFixtureNotificationToFZ";

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
    {
        return [NSNumber numberWithBool:NO];
    }
    
    // Get coco tool
    NSString        *strToolPath    = [dictSettings objectForKey:kOther_OSModeTool_Location];
    [self TransformKeyToValue:strToolPath returnValue:&strToolPath];
    NSFileManager   *filemanager    = [NSFileManager defaultManager];
    if(![filemanager fileExistsAtPath:strToolPath])
    {
        return [NSNumber numberWithBool:NO];
    }
    
    // Pipe it
    NSTask  *taskTool   = [[NSTask alloc] init];
    NSPipe  *pipeTool   = [NSPipe pipe];
    NSFileHandle    *hToolOut;
    [taskTool setStandardOutput:pipeTool];
    [taskTool setLaunchPath:strToolPath];
    hToolOut    = [pipeTool fileHandleForReading];
    
    // Get data
    [taskTool launch];
    if(nil == [dictSettings objectForKey:kOther_OSModeTool_TimeOut])
        sleep(kOther_OSModeTool_DefaultTimeOut);
    else
        sleep([[dictSettings objectForKey:kOther_OSModeTool_TimeOut] unsignedIntValue]);
    [taskTool suspend];
    [taskTool terminate];
    [taskTool release];
    NSData      *dataToolOut    = [hToolOut availableData];
    NSString    *strToolOut     = [[NSString alloc] initWithData:dataToolOut 
                                                        encoding:kOther_OSModeTool_StringEncoding];
    
    // Cut datas out
    
    
    // Save into dicMemoryValues
    
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
- (NSNumber *)CALCULATE_TEMPERATURE_FOR_THERMISTOR:(NSDictionary *)dictSettings RETURN_VALUE:(NSMutableString*)strReturnValue
{
	BOOL bRet = YES;
	for(int i = 0; i < [strReturnValue length]; i ++ )
	{
		if(isdigit([strReturnValue characterAtIndex:i]) || '.'==[strReturnValue characterAtIndex:i])
		{
		}
		else
		{
			bRet = NO;;
			break;
		}
	}
	if(bRet)
	{
		double dValue = [strReturnValue doubleValue];
		double B = 0.0;
		if([[dictSettings valueForKey:@"VALUE"] isEqualToString:@"NTC"])
			B = 3435.0;
		else if([[dictSettings valueForKey:@"VALUE"] isEqualToString:@"TEMP"])
			B = 3380.0;
		else
			return NO;
		double R0 = 10000.0;
		double T0 = 298.15;
		//double V =(dValue/4095)*2.5;
		double R = dValue;
		double RRatio = log(R/R0);
		double t = (RRatio/B)+(1.0/T0);
		double T = (1/t)-273.15;
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
- (NSNumber *)TRANSFORM_FOR_HEX_TO_DEC:(NSDictionary*)dictSettings RETURN_VALUE:(NSMutableString*)strReturnValue
{
	NSString            *szMode = [dictSettings valueForKey:@"Mode"];
	NSString            *szChannel = [dictSettings valueForKey:@"CHANNEL"];
	NSScanner *scaner;
	
	if([szMode isEqualToString:@"RECEIVE"])
	{
		scaner = [NSScanner scannerWithString:strReturnValue];
	}
	else if([szMode isEqualToString:@"FIXTURE"])
	{
		if([strReturnValue length] >= 2)
		{
			if([strReturnValue characterAtIndex:0] == '0')
			{
                [strReturnValue setString:[NSString stringWithFormat:@"%d",[strReturnValue characterAtIndex:1]]];
			}
			else
                [strReturnValue setString:[NSString stringWithFormat:@"%d",[strReturnValue characterAtIndex:0]*256+[strReturnValue characterAtIndex:1]]];
			if(szChannel)
			{
				[m_dicMemoryValues setValue:[NSString stringWithString:strReturnValue] forKey:szChannel];
                ATSDebug(@"Add value:%@ named:%@", strReturnValue, szChannel);
			}
			return [NSNumber numberWithBool:YES];
		}
		else
		{
			return [NSNumber numberWithBool:NO];
		}
		
	}
	else if([szMode isEqualToString:@"D_FIXTURE"])
	{
		if([strReturnValue length])
		{
			if(szChannel)
			{
				[m_dicMemoryValues setValue:[NSString stringWithString:strReturnValue] forKey:szChannel];
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
				[m_dicMemoryValues setValue:[NSString stringWithString:strReturnValue] forKey:szChannel];
                ATSDebug(@"Add value:%@ named:%@", strReturnValue, szChannel);
			}
			return [NSNumber numberWithBool:NO];
		}
	}
	else if([szMode isEqualToString:@"BATQMAX"])
	{
		NSString *szTmp = strReturnValue;
		szTmp = [szTmp stringByReplacingOccurrencesOfString:@" 0x" withString:@""];
		NSScanner *scan = [NSScanner scannerWithString:szTmp];
		unsigned int uiValue;
		if([scan scanHexInt:&uiValue])
		{
            [strReturnValue setString:[NSString stringWithFormat:@"%d",uiValue]];
			return [NSNumber numberWithBool:YES];
		}
		else
			return [NSNumber numberWithBool:NO];		
	}
	else
	{
		return [NSNumber numberWithBool:NO];
	}
	unsigned int iValue;
	bool bStatus = [scaner scanHexInt:&iValue];
	if(bStatus)
	{
        [strReturnValue setString:[NSString stringWithFormat:@"%d",iValue]];
	}
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
-(NSNumber *)GET_DUT_COLOR:(NSDictionary*)dictSettings RETURN_VALUE:(NSMutableString *)strReturnValue
{
	NSRange range = [strReturnValue rangeOfString:@"0x"];
	if(range.location != NSNotFound 
       && range.length >0 
       && (range.length + range.location) <= [strReturnValue length])
	{
        [strReturnValue setString:[strReturnValue substringFromIndex:range.location+range.length]];
		range = [strReturnValue rangeOfString:@" "];
		if(range.location != NSNotFound 
           && range.length>0 
           && (range.location +range.length) <= [strReturnValue length])
		{
            [strReturnValue setString:[strReturnValue substringToIndex:range.location]];
			NSInteger iValue = [strReturnValue intValue];
			
			if(iValue ==0)
			{
                // if the ClrC get from unit is 0x00000000 0x00000000 0x00000000 0x00000000, we set black spec
                [m_strSpecName setString:kFZ_Script_JudgeCommonBlack];
                [m_dicMemoryValues setObject:[NSString stringWithFormat:KIADeviceDUT_BLACKCOLOR] forKey:KIADeviceDUT_COLOR];
			}
			else if(iValue == 1)
			{
                // if the ClrC get from unit is 0x00000001 0x00000000 0x00000000 0x00000000, we set white spec
                [m_strSpecName setString:kFZ_Script_JudgeCommonWhite];
                [m_dicMemoryValues setObject:[NSString stringWithFormat:KIADeviceDUT_WHITECOLOR] forKey:KIADeviceDUT_COLOR];
			}
			else
            {
				return [NSNumber numberWithBool:NO];
			}
			return [NSNumber numberWithBool:YES];
		}
        else
        {
            // don't care
        }
	}
    else
    {
        // don't care
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
//

- (NSNumber *)CURRENT_ROOT_CHECK:(NSDictionary *)dicSubSetting RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSDictionary *dicTemp = [[NSUserDefaults standardUserDefaults] valueForKey:@"CurrentRoot"];
	NSArray *arrReturnValue = [szReturnValue componentsSeparatedByString:@"nandfs:\\AppleInternal\\Diags\\Scripts\\N94\\FATP\\Current\\"];
	if ([arrReturnValue count] != 30) 
	{
		[szReturnValue setString:[NSString stringWithFormat:@"Root count error"]];
		return [NSNumber numberWithBool:NO];
	}
	for (int i=1; i < [arrReturnValue count]; i++)
	{
		NSArray *arrRoot = [[arrReturnValue objectAtIndex:i] componentsSeparatedByString:@": "];
		if ([arrRoot count]>=2)
		{			
			NSString *szRoot = [dicTemp valueForKey:[arrRoot objectAtIndex:0]];
			NSLog(@"Root:%@",[arrRoot objectAtIndex:0]);
			NSLog(@"SettingFile:%@",szRoot); 
			NSLog(@"Unit:%@",[arrRoot objectAtIndex:1]);
			if ([[arrRoot objectAtIndex:1] isEqualToString:szRoot])
			{
				[szReturnValue setString:[NSString stringWithFormat:@"%@Match",[arrRoot objectAtIndex:0]]];
			}
			else
			{
				[szReturnValue setString:[NSString stringWithFormat:@"%@UnMatch,Setting:%@,Unit:%@",[arrRoot objectAtIndex:0],szRoot,[arrRoot objectAtIndex:1]]];
				return [NSNumber numberWithBool:NO];
			}
		}
	}
	[szReturnValue setString:[NSString stringWithFormat:@"PASS"]];
	return [NSNumber numberWithBool:YES];

}


#pragma mark ############################## DisplayPort function begin ##############################
//description : load bundle for displayport
- (NSNumber *)LOAD_BUNDLE
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init]; //what ever code calls IFTestSuite onload is reponsible for maintaining the auto release pool
    //NSError* e;
    
    //build the path to the bundle
    NSString* folderPath = [[NSBundle mainBundle] builtInPlugInsPath];
    NSArray* array = [NSArray arrayWithObjects:folderPath, @"DisplayPort.bundle", nil];
    NSString* bundlePath = [NSString pathWithComponents:array];
    
    //check if this is our bundle
    NSBundle* bundle = [NSBundle bundleWithPath:bundlePath];
    NSDictionary* info = [bundle infoDictionary];
    NSLog(@"bundle information:\n%@", [info description]);
    
    NSString* bundleIDStr = [bundle objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    NSLog(@"bundle id is %@", bundleIDStr);
    
    //runmode is 0 for hardware, 1 for simulation
    NSDictionary* stationInfo = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:1], @"runMode", nil];

    /*Class suiteClass = [bundle principalClass];
    BOOL ret = [suiteClass onLoad:stationInfo error:&e];
    if( !ret )
    {
        NSAlert *theAlert = [NSAlert alertWithError:e];
        [theAlert runModal];
    }*/
    [stationInfo release];
	[pool release];
    return [NSNumber numberWithBool:YES];
}

//description : save bundle and iF version ... to dic
- (NSNumber *)SAVE_BUNDLE_INFO
{
    NSString* folderPath = [[NSBundle mainBundle] builtInPlugInsPath];
    NSArray* array = [NSArray arrayWithObjects:folderPath, @"DisplayPort.bundle", nil];
    NSString* bundlePath = [NSString pathWithComponents:array];
    
    //check if this is our bundle
    NSBundle* bundle = [NSBundle bundleWithPath:bundlePath];
    NSBundle* bundleFramework = [NSBundle bundleWithIdentifier:@"com.apple.iFactoryTest"];
    
    //save version
    [m_dicMemoryValues setObject:[bundle objectForInfoDictionaryKey:@"CFBundleVersion"] forKey: @"APPLEIFTBUNDLEVERSION"];
    [m_dicMemoryValues setObject:[bundleFramework objectForInfoDictionaryKey:@"CFBundleVersion"] forKey:@"APPLEIFTFRAMEWORKVERSION"];
    return [NSNumber numberWithBool:YES];
}

//run coco displayprot function
- (NSNumber *)DisplayPort_TEST
{
    /*
    NSString *filePath=@"/vault/iFactoryTest/TesterConfig_oc.csv"; 
	NSString *szBsdPath = [[m_dicPorts objectForKey:kPD_Device_MOBILE] objectAtIndex:kFZ_SerialInfo_SerialPort];
	NSString *szResult;
	NSError * error1 ;
	
	NSString * source = [NSString stringWithContentsOfFile:filePath 
												  encoding:NSUTF8StringEncoding
													 error:&error1];
	ATSDebug(@"DisplayPort_TEST => %@\n%@",filePath,source);
	NSArray *splitResult=[source componentsSeparatedByString:@"\r"];
	for(int i=0;i<[splitResult count];i++)
	{
		NSString *szt1=[splitResult objectAtIndex:i];
		if([szt1 rangeOfString:@"bsdPath"].location!=NSNotFound&&[szt1 rangeOfString:szBsdPath].location!=NSNotFound)	
		{			
			NSArray *lineArray=[[splitResult objectAtIndex:i] componentsSeparatedByString:@","];
			NSArray *resultArray=[[lineArray objectAtIndex:0] componentsSeparatedByString:@"_"];
            if ([resultArray count]>1) {
                szResult=[resultArray objectAtIndex:1];
            }
			else
            {
                ATSDebug(@"%@",@"DisplayPort_TEST => Test displayPort error , Can't get site");
                return [NSNumber numberWithBool:NO];
            }
			ATSDebug(@"DisplayPort_TEST => mobile: %@",szResult);
			break;
		}	
	}

	BOOL bRet = YES;
	IFTestSiteManager* siteManager = [IFTestSiteManager sharedInstance];
	IFTestSuite* suite = [siteManager suiteForSite:szResult];
	NSArray* testFlow = [suite flowForName:@"default"];
	NSDictionary* puddingAttributes= [suite onDUTStart:nil returnedError:&error1];
	if( !puddingAttributes )
	{
		NSAlert *theAlert = [NSAlert alertWithError:error1];
		[theAlert runModal];
	}
	else {
        [m_dicMemoryValues setObject:[puddingAttributes valueForKey:@"FPGA_Firmware"] forKey:@"FPGA_FIRMWARE"];
        [m_dicMemoryValues setObject:[puddingAttributes valueForKey:@"DPRx_Firmware"] forKey:@"DPRX_FIRMWARE"];
        ATSDebug(@"DisplayPort_TEST => pudding attribute is:\n%@", puddingAttributes);
	}
	int count = [testFlow count];
	ATSDebug(@"DisplayPort_TEST => testflow for site %@ has %d tests", szResult, count);
	for(int i=0; i<count; i++)
    {
		BOOL continueFlow = YES;
		IFTestMethod* test = [testFlow objectAtIndex:i];
		NSLog(@"running sub test %@", [test displayName]);
		if( ![test willRun:i+1 error:&error1] )
		{
			NSAlert *theAlert = [NSAlert alertWithError:error1];
			[theAlert runModal];
			break;
		}
		continueFlow = [test run:i+1 error:&error1];
		NSArray* results = [test didRun:i+1 error:&error1];   
		[m_arrDisplayPortData insertObject:results atIndex:0];
		if( !results )
		{
			NSLog(@"error running test %@", [test displayName]);
			NSAlert *theAlert = [NSAlert alertWithError:error1];
			[theAlert runModal];
			[suite onDUTFail:&error1];
			break;
		}
		for(IFTestResult* r in results)
		{
			NSLog(@"%@", [r description]);
			if( [r result]==IFTResultFail ){
				bRet = NO;
			}
		}
		if(!continueFlow)
			break;
	}
	[suite onDUTFinished:&error1];
 	return [NSNumber numberWithBool:bRet];
     */
    return [NSNumber numberWithBool:YES];
}

//get data form dic or ary
- (NSNumber *)GET_DP_DATA:(NSDictionary *)dicSubSetting RETURN_VALUE:(NSMutableString *)szReturnValue
{
    /*
    BOOL bRet = NO;
    NSString	*szItem1= [dicSubSetting valueForKey:@"ITEM"];
	NSString	*szItem2= [dicSubSetting valueForKey:@"ITEM2"];
	NSRange	range = [szItem1 rangeOfString:@"*"];
	if(NSNotFound!=range.location)
	{
		szItem1 = [szItem1 stringByReplacingOccurrencesOfString:@"*" withString:@""];
        NSString *szValue = [m_dicMemoryValues valueForKey:szItem1];
        if (szValue) {
            [szReturnValue setString:szValue];
            bRet = YES;
        }
	}
	else
	{	
		for(int i=0; i<[m_arrDisplayPortData count]; i++)
		{
			NSArray *arrBuf = [m_arrDisplayPortData objectAtIndex:i];
			for(int q=0; q<[arrBuf count]; q++)
			{
				IFTestResult *IFTRESULT_DATA = [arrBuf objectAtIndex:q];
				if([szItem1 isEqualToString:[IFTRESULT_DATA testName]]&&[szItem2 isEqualToString:[IFTRESULT_DATA subTestName]])
				{
                    [m_dicMemoryValues setObject:[NSString stringWithFormat:@"{%@}",[IFTRESULT_DATA expected]] forKey:kFZ_TestLimit];
					if(IFTResultPass==[IFTRESULT_DATA result])
					{
                        [szReturnValue setString:[IFTRESULT_DATA expected]];
						bRet = YES;
					}
					else
					{
                        [szReturnValue setString:[IFTRESULT_DATA failMessage]];
					}
					
				}
			}
		}
	}
	return [NSNumber numberWithBool:bRet];
     */
    return [NSNumber numberWithBool:YES];
}
#pragma mark ############################## DisplayPort function end ##############################

#pragma mark ############################ Tilt Fixture Monitor begin ##############################
- (NSNumber *)OPEN_FIXTURE
{
    NSNumber *numRet = [NSNumber numberWithBool:YES];
    if ([m_dicPorts objectForKey:kPD_Device_FIXTURE] != nil) {
        NSDictionary *dicForFixture = [NSDictionary dictionaryWithObject:kPD_Device_FIXTURE forKey:kFZ_Script_DeviceTarget];
        numRet = [self OPEN_TARGET:dicForFixture];
    }
    return numRet;
}

- (NSNumber *)CLOSE_FIXTURE
{
    NSNumber *numRet = [NSNumber numberWithBool:YES];
    if ([m_dicPorts objectForKey:kPD_Device_FIXTURE] != nil) {
        NSDictionary *dicForFixture = [NSDictionary dictionaryWithObject:kPD_Device_FIXTURE forKey:kFZ_Script_DeviceTarget];
        NSMutableString *szReturn = [NSMutableString stringWithString:@""];
        numRet = [self CLOSE_TARGET:dicForFixture RETURN_VALUE:szReturn];
    }
    return numRet;
}

- (NSNumber *)CLEAR_FIXTURE
{
    NSNumber *numRet = [NSNumber numberWithBool:YES];
    if ([m_dicPorts objectForKey:kPD_Device_FIXTURE] != nil) {
        NSDictionary *dicForFixture = [NSDictionary dictionaryWithObject:kPD_Device_FIXTURE forKey:kFZ_Script_DeviceTarget];
        numRet = [self CLEAR_TARGET:dicForFixture];
    }
    return numRet;
}

//dicSubItems : monitor parameters
//      TIMEOUT : timeout
- (NSNumber *)MONITOR_FIXTURE:(NSDictionary *)dicSubItems
{
    NSNumber *numRet = [NSNumber numberWithBool:YES];
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:TiltFixtureNotificationToUI object:self userInfo:nil];
    if ([m_dicPorts objectForKey:kPD_Device_FIXTURE] != nil) {
        PEGA_ATS_UART   *uartObj    = [[m_dicPorts objectForKey:kPD_Device_FIXTURE] objectAtIndex:kFZ_SerialInfo_UartObj];
        NSTimeInterval timeOut = [[dicSubItems objectForKey:kFZ_Script_ReceiveTimeOut] doubleValue];
        NSMutableString *data = [[NSMutableString alloc] init];
        NSInteger iRet = [uartObj Read_UartData:data TerminateSymbol:[NSArray arrayWithObjects:@"Vol Down",nil] MatchType:0 IntervalTime:kUart_IntervalTime TimeOut:timeOut];
        [nc postNotificationName:TiltFixtureNotificationToFZ object:self userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d",iRet] forKey:@"PatnFixRet"]];
        if (kUart_SUCCESS != iRet)
        {
            numRet = [NSNumber numberWithBool:NO];
        }
        [data release];      
    }
    else
    {
        do{
            sleep(1);
            if (m_iPatnRFromFZ != kFZ_Pattern_NoMsg) {
                break;
            }
        }while (1);
    }
    return numRet;
}

//
- (NSNumber *)MEASURE_RESULT
{
    if(m_bPatnRFromUI && (m_iPatnRFromFZ == kFZ_Pattern_ReceiveVolDnMsg))
    {
        m_iPatnRFromFZ = kFZ_Pattern_NoMsg;
        return [NSNumber numberWithBool:YES];
    }
    else
    {
        m_bPatnRFromUI = YES;
        m_iPatnRFromFZ = kFZ_Pattern_NoMsg;
        return [NSNumber numberWithBool:NO];
    }
}
#pragma mark ############################## Tilt Fixture Monitor end ##############################

- (NSNumber *)GET_CONFIG:(NSDictionary *)dicSubItems RETURN_VALUE:(NSMutableString *)szReturnValue
{/*
    NSString *szSBUILD = @"";
	NSString *szBuild_Event = @"";
	NSString *szBuild_Matrix_Config = @"";
	NSString *szUNIT = @"";
	
    //add by jingfu ran on 2011 10 26
    //If the *szReturnValue  IS NULL,WE will set the config as follow!
    if ([[*szReturnValue uppercaseString] isEqualToString:@"NULL"]) 
    {
        [m_dicInsertTestValue setValue:szUNIT forKey:@"UNIT#"];
		[m_dicInsertTestValue setValue:szSBUILD forKey:@"S_BUILD"];
		[m_dicInsertTestValue setValue:szBuild_Event forKey:@"BUILD_EVENT"];
		[m_dicInsertTestValue setValue:szBuild_Matrix_Config forKey:@"BUILD_MATRIX_CONFIG"];
        return YES;
    }
    //end by jingfu ran on 2011 10 26
    
	NSArray * array = [*szReturnValue componentsSeparatedByString:@"/"];
	if ([array count] < 5)
	{
		NSLog(@"Separated string fail, get [%d] items",[array count]);
		*szReturnValue = [NSString stringWithFormat:@"config [%@] error",*szReturnValue];
		[m_dicInsertTestValue setValue:szUNIT forKey:@"UNIT#"];
		[m_dicInsertTestValue setValue:szSBUILD forKey:@"S_BUILD"];
		[m_dicInsertTestValue setValue:szBuild_Event forKey:@"BUILD_EVENT"];
		[m_dicInsertTestValue setValue:szBuild_Matrix_Config forKey:@"BUILD_MATRIX_CONFIG"];
		return NO;
	}
	
	szBuild_Matrix_Config = [array objectAtIndex:4];
	szUNIT = [array objectAtIndex:3];
	szBuild_Event = [NSString stringWithFormat:@"%@%@",[array objectAtIndex:0],[array objectAtIndex:1]];
	szSBUILD = [NSString stringWithFormat:@"%@_%@",szBuild_Event, szBuild_Matrix_Config];
	[m_dicInsertTestValue setValue:szUNIT forKey:@"UNIT#"];
	[m_dicInsertTestValue setValue:szSBUILD forKey:@"S_BUILD"];
	[m_dicInsertTestValue setValue:szBuild_Event forKey:@"BUILD_EVENT"];
	[m_dicInsertTestValue setValue:szBuild_Matrix_Config forKey:@"BUILD_MATRIX_CONFIG"];
	return YES;	
  */
    return [NSNumber numberWithBool:YES];
}

//Start 2011.11.04 Add by Ming 
// Descripton:Get the Start Time
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)GET_START_TIME:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue;
{

    NSDate *intervalTime = [NSDate date];
    
    [m_dicMemoryValues setObject:intervalTime forKey:[dicContents objectForKey:kFZ_Script_MemoryKey]];
    
    ATSDebug(@"Start Test Time: %@",intervalTime);
    
    return [NSNumber numberWithBool:YES];
}
//End 2011.11.04 Add by Ming


//Start 2011.11.06 Add by Ming 
// Descripton:Change Test Case Name with Black/White
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)CHANGE_TESTCASENAME_WITH_COLOR:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue
{

    NSString *szCurrentTestItem;
    /*
    if (m_szColor && ![m_szColor isEqualToString:@""]&&(NSNotFound!=[m_szColor rangeOfString:@"BLACK" options:NSCaseInsensitiveSearch].location||NSNotFound!=[m_szColor rangeOfString:@"WHITE" options:NSCaseInsensitiveSearch].location)) //modify the information showed on UI ,by leo ,20110422,begin
    {
        if(NSNotFound!=[m_szColor rangeOfString:@"BLACK" options:NSCaseInsensitiveSearch].location)
        {
            //[m_dicMemoryValues setObject:szCurrentItemName forKey:kFunnyZoneCurrentItemName];
            szCurrentTestItem = [NSString stringWithFormat:@"%@_Black",[m_dicMemoryValues valueForKey:kFunnyZoneCurrentItemName]];
        }
        else if(NSNotFound!=[m_szColor rangeOfString:@"WHITE" options:NSCaseInsensitiveSearch].location)
        {
            szCurrentTestItem = [NSString stringWithFormat:@"%@_White",[m_dicMemoryValues valueForKey:kFunnyZoneCurrentItemName]];
        }
        
    } //modify the information showed on UI ,by leo ,20110422,end
    else 
    {
        szCurrentTestItem = [NSString stringWithFormat:@"%@_Command fail",[m_dicMemoryValues valueForKey:kFunnyZoneCurrentItemName]];
    }
     */
    //[m_dicMemoryValues setObject:[NSString stringWithFormat:KIADeviceDUT_BLACKCOLOR] forKey:KIADeviceDUT_COLOR];
    if([[m_dicMemoryValues valueForKey:KIADeviceDUT_COLOR] isEqualToString:KIADeviceDUT_BLACKCOLOR ])
    {
    
        szCurrentTestItem = [NSString stringWithFormat:@"%@_Black",[m_dicMemoryValues valueForKey:kFunnyZoneCurrentItemName]];
    
    }else if([[m_dicMemoryValues valueForKey:KIADeviceDUT_COLOR] isEqualToString:KIADeviceDUT_WHITECOLOR ])
    {
    
        szCurrentTestItem = [NSString stringWithFormat:@"%@_White",[m_dicMemoryValues valueForKey:kFunnyZoneCurrentItemName]];
		[m_strSpecName setString:kFZ_Script_JudgeCommonWhite];
    }
    else 
    {
        szCurrentTestItem = [NSString stringWithFormat:@"%@_Unknown",[m_dicMemoryValues valueForKey:kFunnyZoneCurrentItemName]];
    }
    
    
     [m_dicMemoryValues setObject:szCurrentTestItem forKey:kFZ_UI_SHOWNNAME];
    
    [strReturnValue setString:@"PASS"];
    
    return [NSNumber numberWithBool:YES];

}
//End 2011.11.06 Add by Ming

//add note by betty, 2012/4/17
// Change the Scientific notation to Normal notation 
// Param:
//      NSDictionary    *dicSubSetting   : Settings
//                 LENGTH --> NSString*  : the length after the decimal point you want to keep
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
// modified by desikan  combine with "ScientificToDouble:RETURN_VALUE:"
- (NSNumber *)ChangeScientificToNormal:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)szNumber
{
    //start 2012,02,09 modified by yaya
    if ([szNumber isEqualTo:kFZ_99999_Value_Issue]) 
    {
        ATSDebug(@"-99999issue");
        return [NSNumber numberWithBool:NO];
    }
    double dNumber;
    NSScanner *scanerBuf = [NSScanner scannerWithString:szNumber];
    if (![scanerBuf scanDouble:&dNumber])
    {
        [szNumber setString:kFZ_99999_Value_Issue];
        ATSDebug(@"Invalid String");
        return [NSNumber numberWithBool:NO];
    }
    if(nil == [dicContents valueForKey:@"LENGTH"]|| [[dicContents valueForKey:@"LENGTH"] isEqualTo:@""])
    {
        [szNumber setString:[NSString stringWithFormat:@"%lf",dNumber]];
    }
    else
    {
        int iLength = [[dicContents objectForKey:@"LENGTH"] intValue];
        [szNumber setString:[NSString stringWithFormat:@"%.*f",iLength,dNumber]];
    }
    //end 2012.2.9 modified by yaya. 
    
    return [NSNumber numberWithBool:YES];

}

//add note by betty, 2012/4/17
// Change the value of m_bCancelFlag, 
// Param:
//      NSDictionary    *dicSubSetting   : Settings
//             FailCancle -> Boolean     : Set bool value of FailCancle, YES --> if fail, cancle some item 
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
- (NSNumber *)CHANGE_CANCLE_FLAG:(NSDictionary *)dicPara RETURN_VALUE:(NSMutableString *)szReturnValue
{
    bool bChangeFlag;
    if(nil ==[dicPara valueForKey:@"FailCancle"])
    {
        bChangeFlag = YES; 
    }
    else
    {
        bChangeFlag = [[dicPara valueForKey:@"FailCancle"] boolValue];
    }
    if(bChangeFlag ^ m_bLastItemResult)
    {
        m_bCancelFlag = YES;
    }
    else
    {
        m_bCancelFlag = NO;
    }
    return [NSNumber numberWithBool:YES];
}

//add note by betty, 2012/4/17
// do round, keep the length you want to keep after the decimal point, default is 6
// Param:
//      NSDictionary    *dicSubSetting   : Settings
//              Digit  --> NSString *    : set the length after the decimal point you want to keep
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
- (NSNumber *)DO_ROUND:(NSDictionary *)dicPara RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSString * szNumber =   [NSString stringWithFormat:@"%@",szReturnValue];
    if (kFZ_99999_Value_Issue == szNumber)
    {
        [szReturnValue setString:kFZ_99999_Value_Issue];
        ATSDebug(@"-99999issue");
        return [NSNumber numberWithBool:NO];
    }
    if(nil == szNumber || [szNumber isEqualToString:@""])
    {
        ATSDebug(@"the return number is nil please check");
        return [NSNumber numberWithBool:NO];
    }
    NSString * szIntegral;
    NSString * szDecimal;
    bool bNegative  =   NO;
    int iDigit;
    int iDeLength;
    // default Digit is 6; 
    iDigit  =   [dicPara valueForKey:@"Digit"]?[[dicPara valueForKey:@"Digit"] intValue]:6;
    // judge the iDigit set the largetest value to 18
    if(iDigit >18)
    {
        ATSDebug(@"The Digit value is too large ,change it to 18");
        iDigit  =   18;
    }
    NSRange range1  =   [szNumber rangeOfString:@"-"];
    // judge the number  whether it is a negative
    if(NSNotFound != range1.location 
       && range1.length > 0 
       && (range1.location +range1.length) <=[szNumber length])
    {
        szNumber    =   [szNumber substringFromIndex:range1.location+range1.length];
        bNegative   =   YES;
    }
    else
    {
        ATSDebug(@"The number is a positive number");
    }
    NSRange range2  =   [szNumber rangeOfString:@"."];
    if(NSNotFound != range2.location 
       && range2.length > 0 
       && (range2.location +range2.length) <=[szNumber length])
    {      // get the Integral and Decimal of the number
        szIntegral  =   [szNumber substringToIndex:range2.location];
        szDecimal   =   [szNumber substringFromIndex:range2.location+range2.length];
        ATSDebug(@" the Integral is %@    ; and the Decimal is %@   ",szIntegral,szDecimal);
        iDeLength   =   [szDecimal length];
        if(iDeLength <= iDigit)
        {   // if the length of decimal is little than the Digit we want , complementarity 0
            for (int i=0;i<iDigit-iDeLength; i++) 
            {
                szNumber = [NSString stringWithFormat:@"%@0",szNumber];
            }
            ATSDebug(@"the length of decimal is little than the Digit we want ,so just do complementarity 0");
        }
        else
        {       //  do round(四舍五入)
            //  get the Digit we wanted in Decimal
            NSString *szDigit   =   [szDecimal substringToIndex:iDigit];
            long long lDigit    =   [szDigit longLongValue];
            ATSDebug(@"Digit we want is %@",szDigit);
            NSString *szRemainder   =   [szDecimal substringFromIndex:iDigit];
            double dRemainder   =   [[NSString stringWithFormat:@"0.%@",szRemainder] doubleValue];
            ATSDebug(@"The Remainder is %@",szRemainder);
            if(dRemainder >= 0.5)  // if the remainder is more than 0.5 abnegate it and carry 1
            {
                lDigit  =   lDigit + 1;
            }                      // else abnegate without carry 1
            szDecimal   =   [NSString stringWithFormat:@"%qi",lDigit];
            if([szDecimal length]<[szDigit length])
            {                      // if the number is like 3.0032, the Decimal will be 32 so we need to complementarity 0 
                for (;[szDecimal length] < iDigit; ) 
                {
                    szDecimal   =   [NSString stringWithFormat:@"0%@",szDecimal];
                }
            }
            else if([szDecimal length] >[szDigit length])
            {                    // if the number is like 32.999999 than maybe it will carry 1 to integral
                szDecimal = [NSString stringWithFormat:@"%@",szDigit];
                ATSDebug(@"now the decimal is %@",szDecimal);
            }
            szNumber =   [NSString stringWithFormat:@"%@.%@",szIntegral,szDecimal];
        }
    }
    else
    {
        // don't care
    }
    if(bNegative)
    {
        [szReturnValue setString:[NSString stringWithFormat:@"-%@",szNumber]];
    }
    else
    {
        [szReturnValue setString:[NSString stringWithFormat:@"%@",szNumber]];
    }
    ATSDebug(@"the last result is %@",szReturnValue);
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
- (NSNumber *)Provisioning:(NSDictionary *)dictSettings RETURN_VALUE:(NSMutableString*)szReturnValue
{
    int iType               = [[dictSettings objectForKey:@"TypeFlag"] intValue];
    NSDictionary *dicSetSN  = [NSDictionary dictionaryWithDictionary:[dictSettings objectForKey:@"SettingSN"]];
    NSArray *arrayScanSN    = [NSArray arrayWithArray:[dictSettings objectForKey:@"ScanSN"]];
    switch (iType) {
			// get SN from script
        case 0:
            if (dicSetSN) 
            {
                for (NSString *szBoardID in [dicSetSN allKeys])
                {
                    if ([szBoardID isEqualToString:[NSString stringWithString:szReturnValue]]) 
                    {
                        [m_dicMemoryValues setValuesForKeysWithDictionary:[dicSetSN objectForKey:szBoardID]];
                        return [NSNumber numberWithBool:YES];
                        break;
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
            break;
			// get SN from SFIS
        case 1:
            return [self QUERY_SFIS:dictSettings RETURN_VALUE:szReturnValue];
            break;
			// get SN from scan SN
        case 2:
            if (arrayScanSN) 
            {
                [m_dicMemoryValues setObject:@"0" forKey:@"ScanSNFlag"];
                NSDictionary *dicScanSN  = [NSDictionary dictionaryWithObject:arrayScanSN forKey:@"dicScanSN"];
                NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
                [nc postNotificationName:@"NotificationScanSN" object:self userInfo:dicScanSN];
                NSRunLoop *RunLoop       = [NSRunLoop currentRunLoop];
                NSDate *dateTime         = [NSDate dateWithTimeIntervalSinceNow:1];             // set wait 1 second every time
                while ([[m_dicMemoryValues objectForKey:@"ScanSNFlag"] isEqualToString:@"0"]) 
                {                             
                    [RunLoop runUntilDate:dateTime];
                }
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
- (NSNumber *)SPLIT_TEST_NAME:(NSDictionary *)dictSettings RETURN_VALUE:(NSMutableString*)szReturnValue
{
	
	NSString * strMainItemName = [dictSettings objectForKey:@"MainItemName"];
	[m_dicMemoryValues setObject:strMainItemName forKey:@"MainItemName"];
	return [NSNumber numberWithBool:YES];
}

// 2012.4.11
/*
 For QT0 Prox Open/Short.
 Get the value from an array to judge spec one by one, and upload parametric data.
 Para: dicSpec--> contain the array which need to judge spec, the spec and the parametric name.
 */
- (NSNumber *)JUDGESPEC_AND_UPLOADPARAMETRIC:(NSDictionary  *)dicPara  RETURN_VALUE:(NSMutableString*)szReturnValue
{
    // get the data and spec
    NSArray         *arrData = [dicPara objectForKey:@"DATA"];
    NSString        *szSpec = [dicPara objectForKey:@"SPEC"];
    
    // return value
    NSNumber        *retNum = [NSNumber numberWithBool:YES];
    
    // for parametic data
    NSString        *szParaName = [dicPara objectForKey:@"PARANAME"];
    NSString        *szLowLimits, *szHighLimits, *szParamatricData;;
    
    // loop to judge spec and upload parametric data
    for (int i = 0; i < [arrData count]; i++) 
    {
        NSString            *szDataTemp = [arrData objectAtIndex:i];
        NSMutableString     *szSomeData = [[NSMutableString alloc] initWithString:szDataTemp];
        NSDictionary        *dicTheSpec = [NSDictionary dictionaryWithObjectsAndKeys:szSpec, kFZ_Script_JudgeCommonBlack , nil];
        dicTheSpec = [NSDictionary dictionaryWithObjectsAndKeys:dicTheSpec , kFZ_Script_JudgeCommonSpec , nil];
        
        // judge spec
        if (![[self JUDGE_SPEC:dicTheSpec RETURN_VALUE:szSomeData] boolValue])
        {
            [szReturnValue setString:[NSString stringWithFormat:@"The value %@ is not in the spec %@",szSomeData,szSpec]];
            ATSDebug(@"szReturn value %@",szReturnValue);
            retNum = [NSNumber numberWithBool:NO];
        }
        [m_dicMemoryValues setObject:@"{N/A}" forKey:kFZ_TestLimit];
        
        // upload paramatric data
        szLowLimits = [szSpec SubFrom:@"[" include:NO];
        szLowLimits = [szLowLimits SubTo:@"," include:NO];
        szHighLimits = [szSpec SubFrom:@"," include:NO];
        szHighLimits = [szHighLimits SubTo:@"]" include:NO];
        // creat the parametric name
        int j = i/2;
        int k = i%2;
        szParamatricData = [NSString stringWithFormat:@"%@_%d_%d",szParaName,(k+1),j];
        NSDictionary *dicUpload =[NSDictionary dictionaryWithObjectsAndKeys:szLowLimits,kFZ_Script_ParamLowLimit,szHighLimits,kFZ_SCript_ParamHighLimit,szParamatricData,kFZ_Script_UploadParametric,[NSNumber numberWithBool:NO],kFunnyZoneNOWriteCsvToLogFile,nil];
        
        [self UPLOAD_PARAMETRIC:dicUpload RETURN_VALUE:szSomeData];
        [szSomeData release];
        

    }
    return retNum;
}

// 2012.2.21 
// get prox data, and judge.   
- (NSNumber *)CAlCULATOR_PROX_DATA:(NSDictionary *)dicpara RETURN_VALUE:(NSMutableString*)strReturnValue
{
    NSString *szProxStatus = [dicpara valueForKey:kFZ_Script_MemoryKey];
    NSString * szAVG_SPEC = [dicpara valueForKey:@"AVG_SPEC"];
    NSString * szSD_SPEC = [dicpara valueForKey:@"SD_SPEC"] ;
    NSString *szAverageValue;
    NSString *szDeviationValue;
    //NSString *szLowLimits;
    //NSString *szHighLimits,*szParamatricData;
    NSNumber *retNum = [NSNumber numberWithBool:YES];
    
    NSMutableArray *aryAverageDataStage = [[NSMutableArray alloc]init];
    NSMutableArray *aryDeviationDataStage = [[NSMutableArray alloc]init];
    
    
    NSArray *aryData = [strReturnValue componentsSeparatedByString:@"\n"];
    if ([aryData count] < 6) 
    {
        ATSDebug(@"Prox Data Error!");
        [aryAverageDataStage release];
        [aryDeviationDataStage release];
        return [NSNumber numberWithBool:NO];
    }
    
    for (NSString *szValue in aryData) 
    {
        if ([szValue ContainString:@"Average:"] && [szValue ContainString:@"Deviation:"]) 
        {
            szAverageValue = [szValue SubFrom:@"Average:" include:NO];
            szAverageValue = [szAverageValue SubTo:@"Deviation:" include:NO];
            [szAverageValue stringByReplacingOccurrencesOfString:@"\t" withString:@""];
            NSArray *aryAverage = [szAverageValue componentsSeparatedByString:@", "];
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
            
            szDeviationValue = [szValue SubFrom:@"Deviation:" include:NO];
            [szDeviationValue stringByReplacingOccurrencesOfString:@"\t" withString:@""];
            NSArray *aryDeviation = [szDeviationValue componentsSeparatedByString:@", "];
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
        if ([dicpara valueForKey:@"AVG_SPEC"]!=nil)
        {
            /*
            for (int i =0; i< [aryAverageDataStage count]; i++) 
            {
                
                NSString     *szAverage = [aryAverageDataStage objectAtIndex:i];
                NSMutableString *szFinalAverage = [[NSMutableString alloc] initWithString:szAverage];
                //judge spec
                NSDictionary *dicSpec = [NSDictionary dictionaryWithObjectsAndKeys:szAVG_SPEC, kFZ_Script_JudgeCommonBlack , nil];
                dicSpec = [NSDictionary dictionaryWithObjectsAndKeys:dicSpec , kFZ_Script_JudgeCommonSpec , nil];
            if (![[self JUDGE_SPEC:dicSpec RETURN_VALUE:szFinalAverage] boolValue])
                {
                    
                    [strReturnValue setString:[NSString stringWithFormat:@"The average value %@ is not include the spec %@",szAverage,szAVG_SPEC]];
                    ATSDebug(@"szReturn value %@",strReturnValue);
                    retNum = [NSNumber numberWithBool:NO];
                }
                [m_dicMemoryValues setObject:@"{N/A}" forKey:kFZ_TestLimit];
                //upload paramatric data
                szLowLimits = [szAVG_SPEC SubFrom:@"[" include:NO];
                szLowLimits = [szLowLimits SubTo:@"," include:NO];
                szHighLimits = [szAVG_SPEC SubFrom:@"," include:NO];
                szHighLimits = [szHighLimits SubTo:@"]" include:NO];
                int j =i/2;
                int k = i%2;
                szParamatricData = [NSString stringWithFormat:@"Prox Short Aver_%d_%d",(k+1),j];
                NSDictionary *dicUpload =[NSDictionary dictionaryWithObjectsAndKeys:szLowLimits,kFZ_Script_ParamLowLimit,szHighLimits,kFZ_SCript_ParamHighLimit,szParamatricData,kFZ_Script_UploadParametric,[NSNumber numberWithBool:NO],kFunnyZoneNOWriteCsvToLogFile,nil];
                
                [self UPLOAD_PARAMETRIC:dicUpload RETURN_VALUE:szFinalAverage];
                [szFinalAverage release];
                
            }
             */
            
            NSDictionary    *dicParaTemp = [NSDictionary dictionaryWithObjectsAndKeys:aryAverageDataStage,@"DATA",szAVG_SPEC,@"SPEC",@"Prox Short Aver",@"PARANAME", nil];
            
            retNum = [self JUDGESPEC_AND_UPLOADPARAMETRIC:dicParaTemp RETURN_VALUE:strReturnValue];
            
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
        if ([dicpara valueForKey:@"SD_SPEC"]!=nil)
        {
            /*
            for (int i =0; i< [aryDeviationDataStage count]; i++) 
            {
                
                NSString     *szDeviation = [aryDeviationDataStage objectAtIndex:i];
                NSMutableString *szFinalDeviation = [[NSMutableString alloc]initWithString:szDeviation];
                //judge spec
                NSDictionary *dicSpec = [NSDictionary dictionaryWithObjectsAndKeys:szSD_SPEC, kFZ_Script_JudgeCommonBlack , nil];
                dicSpec = [NSDictionary dictionaryWithObjectsAndKeys:dicSpec , kFZ_Script_JudgeCommonSpec , nil];
                if (![[self JUDGE_SPEC:dicSpec RETURN_VALUE:szFinalDeviation] boolValue])
                {
                    
                    [strReturnValue setString:[NSString stringWithFormat:@"The deviation value %@ is not include the spec %@",szDeviation,szSD_SPEC]];
                    ATSDebug(@"szReturn value %@",strReturnValue);
                    retNum = [NSNumber numberWithBool:NO];
                    
                }
                 [m_dicMemoryValues setObject:@"{N/A}" forKey:kFZ_TestLimit];
                //upload paramatric data
                szLowLimits = [szSD_SPEC SubFrom:@"[" include:NO];
                szLowLimits = [szLowLimits SubTo:@"," include:NO];
                szHighLimits = [szSD_SPEC SubFrom:@"," include:NO];
                szHighLimits = [szHighLimits SubTo:@"]" include:NO];
                int j =i/2;
                int k = i%2;
                szParamatricData = [NSString stringWithFormat:@"Prox Open SD_%d_%d",(k+1),j];
                NSDictionary *dicUpload =[NSDictionary dictionaryWithObjectsAndKeys:szLowLimits,kFZ_Script_ParamLowLimit,szHighLimits,kFZ_SCript_ParamHighLimit,szParamatricData,kFZ_Script_UploadParametric,[NSNumber numberWithBool:NO],kFunnyZoneNOWriteCsvToLogFile,nil];
                [self UPLOAD_PARAMETRIC:dicUpload RETURN_VALUE:szFinalDeviation];
                [szFinalDeviation release];
                
            }
             */
            
            NSDictionary    *dicParaTemp = [NSDictionary dictionaryWithObjectsAndKeys:aryDeviationDataStage,@"DATA",szSD_SPEC,@"SPEC",@"Prox Open SD",@"PARANAME", nil];
            
            retNum = [self JUDGESPEC_AND_UPLOADPARAMETRIC:dicParaTemp RETURN_VALUE:strReturnValue];
            
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

- (NSNumber *)MatchReginCode:(NSDictionary *)dicpara RETURN_VALUE:(NSMutableString*)strReturnValue
{
    NSString *strSN = [m_dicMemoryValues objectForKey:@"ISN"];
    NSString *strMLBSN = [NSString stringWithString:m_szReturnValue];
    if (([strSN length]==12 )&& ([strMLBSN length]==17)) 
    {
        NSString *strEEEEcode = [self catchFromString:strReturnValue location:11 length:4];
        NSString *strCCCCCode = [self catchFromString:strSN location:8 length:4];
        BOOL NoMacthCode      = [[dicpara objectForKey:@"NoMacthCode"] boolValue];
        
        //if no macth , save ccc code and eee code return yes
        if (NoMacthCode) 
        {
            [m_dicMemoryValues setValue:strCCCCCode forKey:@"CCODE"];
            [m_dicMemoryValues setValue:strEEEEcode forKey:@"ECODE"];
            return [NSNumber numberWithBool:YES];
        }
        
        NSDictionary *dicCode = [dicpara objectForKey:@"MatchingTable"];
        if ([[dicCode allKeys] containsObject:strCCCCCode]) {
            if ([[dicCode objectForKey:strCCCCCode]isEqualToString:strEEEEcode]) 
            {
                [m_dicMemoryValues setValue:strCCCCCode forKey:@"CCODE"];
                [m_dicMemoryValues setValue:strEEEEcode forKey:@"ECODE"];
                return [NSNumber numberWithBool:YES];
            }
            else
            {
                [strReturnValue setString:[NSString stringWithFormat:@"EEEE code didn't match with CCCC code! MLBSN:%@;SN:%@",strMLBSN,[m_dicMemoryValues objectForKey:@"ISN"]]];
            }
        }
        else
        {
            [strReturnValue setString:[NSString stringWithFormat:@"Didn't maintain this CCCC code! MLBSN:%@;SN:%@",strMLBSN,[m_dicMemoryValues objectForKey:@"ISN"]]];
        }
    }
    else
    {
        [strReturnValue setString:@"MLBSN or SN length error!"];
    }
    m_bCancelFlag = YES;
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
- (NSNumber *)Judge_If_ALL_Value_Is_XX:(NSDictionary *)dicContents RETURN_VALUE:(NSMutableString *)strReturnValue
{
    NSString *szXX = [dicContents objectForKey:@"XX"];
    int      iLengthofXX = [szXX length];
    BOOL     bWant = [[dicContents objectForKey:@"WANT"] boolValue];
    NSString *szCharactor = [dicContents objectForKey:@"Charactor"];
    NSArray  *aryJudge = [dicContents objectForKey:@"Judge"];
    BOOL bTestRet = NO;
    
    if (nil == aryJudge) 
    {
        ATSDebug(@"No judge range rule, please check!");
        [strReturnValue setString:@"FAIL"];
        return [NSNumber numberWithBool:NO];
    }

    for (int i = 0; i < [aryJudge count]; i+=1)
    {
        NSArray  *aryLines = [strReturnValue componentsSeparatedByString:@"\n"];
        NSDictionary *dicAJudge = [aryJudge objectAtIndex:i];
        NSInteger iLine = [[dicAJudge objectForKey:@"Line"] intValue];
        if (iLine >= [aryLines count]) 
        {
            ATSDebug(@"Line: %d , Total Line: %d", iLine, [aryLines count]);
            [strReturnValue setString:@"FAIL"];
            return [NSNumber numberWithBool:NO];
        }
        NSString  *szLine = [aryLines objectAtIndex:iLine];
        NSArray *aryValues = [szLine componentsSeparatedByString:szCharactor];
        NSString  *szPositions = [dicAJudge objectForKey:@"Position"]; //Format: 3-8,11-11
        
        ATSDebug(@"You want to judge [Line: %d , Position: %@]", iLine, szPositions);
        
        NSArray   *aryPositions = [szPositions componentsSeparatedByString:@","]; 
        for (int j = 0; j < [aryPositions count]; j++)
        {
            NSString *szAPosition = [aryPositions objectAtIndex:j];
            NSArray  *aryFromXXToXX = [szAPosition componentsSeparatedByString:@"-"];
            
            if ([aryFromXXToXX count] == 2)
            {
                int iBegin = [[aryFromXXToXX objectAtIndex:0] intValue];
                int iEnd = [[aryFromXXToXX objectAtIndex:1] intValue];
                int iMax = [aryValues count];
                if (iEnd < iBegin || iMax < iEnd) 
                {
                    ATSDebug(@"Choose the wrong range, please check!");
                    [strReturnValue setString:@"FAIL"];
                    return [NSNumber numberWithBool:NO];
                }
               
                for (int iIndex = iBegin; iIndex <= iEnd ; iIndex++)
                {
                    if ([[aryValues objectAtIndex:iIndex] length] != iLengthofXX) {
                        continue;
                    }
                    
                    if (!bWant)
                    {
                        if (![[aryValues objectAtIndex:iIndex] isEqualToString:szXX])
                        {
                            ATSDebug(@"Value in [Line: %d , Position: %d] doesn't MATCH %@", iLine, iIndex, szXX);
                            [strReturnValue setString:@"PASS"];
                            return [NSNumber numberWithBool:YES];
                        }
                        else
                        {
                            ATSDebug(@"Value in [Line: %d , Position: %d] MATCH %@", iLine, iIndex, szXX);
                            bTestRet = NO;
                        }
                    }
                    else
                    {
                        if ([[aryValues objectAtIndex:iIndex] isEqualToString:szXX])
                        {
                            ATSDebug(@"Value in [Line: %d , Position: %d] MATCH %@", iLine, iIndex, szXX);
                            bTestRet = YES;
                        }
                        else
                        {
                            ATSDebug(@"Value in [Line: %d , Position: %d] doesn't MATCH %@", iLine, iIndex, szXX);
                            [strReturnValue setString:@"FAIL"];
                            return [NSNumber numberWithBool:NO];
                        }
                    }
                }
            }
            else
            {
                ATSDebug(@"No Judge in [Line: %d , Position: %@] Or your Format is Wrong", iLine, szAPosition);
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

// 2012.3.2 Leehua
// Descripton:show voltage and percentage on UI
-(NSNumber *)SEND_VOL_TO_UI:(NSDictionary *)dicSub RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSMutableDictionary *dicVolp = [NSMutableDictionary dictionary];
    id ifReset = [dicSub objectForKey:@"reset"];
    if (ifReset) 
    {
        [dicVolp setObject:[dicSub objectForKey:@"reset"] forKey:@"reset"];
        NSNotificationCenter    *nc     =   [NSNotificationCenter defaultCenter];
        [nc postNotificationName:ShowVoltageOnUI object:self userInfo:dicVolp];
    }  
    else
    {
        NSString *szVoltage = [m_dicMemoryValues objectForKey:@"Voltage"];
        NSString *szPercent = [m_dicMemoryValues objectForKey:@"Percent"];
        [m_dicMemoryValues removeObjectForKey:@"Voltage"];
        [m_dicMemoryValues removeObjectForKey:@"Percent"];
        if (szVoltage || szPercent) 
        {
            if (szVoltage) 
            {
                [dicVolp setObject:szVoltage forKey:@"Voltage"];
            }
            if (szPercent) 
            {
                [dicVolp setObject:szPercent forKey:@"Percent"];
            }
            
            NSNotificationCenter    *nc     =   [NSNotificationCenter defaultCenter];
            [nc postNotificationName:ShowVoltageOnUI object:self userInfo:dicVolp];        
        }
    }
    return [NSNumber numberWithBool:YES];
}

-(NSNumber *)ENTER_DIAGS:(NSDictionary *)dicSub RETURN_VALUE:(NSMutableString *)szReturnValue
{
    BOOL bRet = NO;
    NSDictionary *dicSendCommandEnter = [dicSub objectForKey:@"SendCommandEnter"];
    NSDictionary *dicReciveCommandForEnter = [dicSub objectForKey:@"ReciveCommandForEnter"];
    NSDictionary *dicSendCommandDiags = [dicSub objectForKey:@"SendCommandDiags"];
    NSDictionary *dicReciveCommandForDiags = [dicSub objectForKey:@"ReciveCommandForDiags"];
    NSDictionary *dicReciveCommandAuto  = [dicSub objectForKey:@"ReciveCommandAuto"];
    if (!dicSendCommandEnter || !dicSendCommandDiags || !dicReciveCommandForEnter || !dicReciveCommandForDiags || !dicReciveCommandAuto)
    {
        ATSDebug(@"(FAIL)ENTER_DIAGS: NO Parameters about write and read command");
        [szReturnValue setString:@"ENTER_DIAGS Parameters ERROR"];
        return [NSNumber numberWithBool:NO];
    }
    
    // 12/4/11 betty modify for getting loop times for receiveCommandAuto from plist, default times is 4
    int iLoopAutoReceive = 4;
    if ([dicSub objectForKey:@"LoopForAutoReceive"] && [[dicSub objectForKey:@"LoopForAutoReceive"] isNotEqualTo:@""])
    {
        iLoopAutoReceive = [[dicSub objectForKey:@"LoopForAutoReceive"] intValue];
    }
    
    //Rx first, if return value contain ":-)",return directly
    for (int iCurrentTime = 0; iCurrentTime < iLoopAutoReceive; iCurrentTime ++) 
    {
        bRet = [[self READ_COMMAND:dicReciveCommandAuto RETURN_VALUE:szReturnValue] boolValue];
        if (bRet) 
        {
            ATSDebug(@"(PASS)ENTER_DIAGS: auto enter diags successfully!");
            [szReturnValue setString:@"Unit in Diags Mode"];
            return [NSNumber numberWithBool: YES];
        }

        if ([szReturnValue isEqualToString:@"RX [(null)] Empty response"]) 
        {
            break;
        }
    }
    
    // get loop times, default times is 5
    int iLoopTimes = 5;
    if ([dicSub objectForKey:@"LoopTimes"] && [[dicSub objectForKey:@"LoopTimes"] isNotEqualTo:@""])
    {
        iLoopTimes = [[dicSub objectForKey:@"LoopTimes"] intValue];
    }
    
    // get pass flag of enter recovery mode, default is "]"
    NSString *szPassFlagOfRecovery = @"]";
    if ([dicSub objectForKey:@"PassFlagOfRecovery"] && [[dicSub objectForKey:@"PassFlagOfRecovery"] isNotEqualTo:@""])
    {
        szPassFlagOfRecovery = [dicSub objectForKey:@"PassFlagOfRecovery"];
    }
    
    // get pass flag of enter diags mode, default is ":-)"
    NSString *szPassFlagOfDiags = ([[m_dicMemoryValues objectForKey:@"LORKY_DEVICE_ECID"] length] > 0) ? kFZ_EndFlagFormat : @":-)";
    if ([dicSub objectForKey:@"PassFlagOfDiags"] && [[dicSub objectForKey:@"PassFlagOfDiags"] isNotEqualTo:@""])
    {
        szPassFlagOfDiags = [dicSub objectForKey:@"PassFlagOfDiags"];
    }
    
    BOOL bRecoveryMode = NO;
    BOOL bDiagsMode    = NO;
    int iCurrentLoop = 0;
    do 
    {
        ATSDebug(@"(BENGIN)ENTER_DIAGS: start enter diags (%i) times", iCurrentLoop);
        iCurrentLoop ++;
        bRecoveryMode = NO;
        bDiagsMode = NO;
        
        // judge whether unit in diags mode or not, if diags mode,return pass and don't write "diags" command
        bDiagsMode = [self repeatWriteCommand:dicSendCommandEnter ReceiveCommand:dicReciveCommandForEnter PassString:szPassFlagOfDiags ReturnValue:szReturnValue];
        if (bDiagsMode)
        {
            ATSDebug(@"(PASS)ENTER_DIAGS: Unit in Diags Mode (%i times)", iCurrentLoop);
            [szReturnValue setString:@"Unit in Diags Mode"];
            return [NSNumber numberWithBool:YES];
        }

        if (![[[szReturnValue componentsSeparatedByString:@"\r"] lastObject] isEqual:szPassFlagOfRecovery]) 
        {
            // if not diags mode, judge if unit in recovery mode, if recovery mode, write "diags command"
            bRecoveryMode = [self repeatWriteCommand:dicSendCommandEnter ReceiveCommand:dicReciveCommandForEnter PassString:szPassFlagOfRecovery ReturnValue:szReturnValue];
        }
        else
        {
            bRecoveryMode = YES;
        }
                
        if (bRecoveryMode)
        {
            // sent diagscommand to enter diags. if can't ennter diags mode after write "diags" command, fail it and loop test
            if ([self repeatWriteCommand:dicSendCommandDiags ReceiveCommand:dicReciveCommandForDiags PassString:nil ReturnValue:szReturnValue])
            {
                // double check unit is in diags mode
                bDiagsMode = [self repeatWriteCommand:dicSendCommandEnter ReceiveCommand:dicReciveCommandForEnter PassString:szPassFlagOfDiags ReturnValue:szReturnValue];
                if (bDiagsMode)
                {
                    ATSDebug(@"(PASS)ENTER_DIAGS: Unit in Recovery Mode, then in Diags Mode (%i times)", iCurrentLoop);
                    [szReturnValue setString:@"Unit in Diags Mode"];
                    return [NSNumber numberWithBool:YES];
                }
                else
                {
                    ATSDebug(@"(PASS)ENTER_DIAGS: Unit in Recovery Mode, then in Diags Mode, but no double check (%i times)", iCurrentLoop);
                    [szReturnValue setString:@"Unit in Diags Mode, but no double check"];
                }

            }
            else
            {
                ATSDebug(@"(FAIL)ENTER_DIAGS: Unit in Recovery Mode, then in Diags Mode (%i times)", iCurrentLoop);
                [szReturnValue setString:@"Unit in Recovery Mode, but can't enter Diags Mode"];
            }
        }
        
          // if not recovery mode or diags mode, just wait for 5 seconds ands loop test
        if (!bRecoveryMode && !bDiagsMode)
        {
            ATSDebug(@"(FAIL)ENTER_DIAGS: Unit not in Recovery or Diags Mode (%i times)", iCurrentLoop);
            [szReturnValue setString:@"Unit not in Recovery or Diags Mode"];
            usleep(5000);
        }

        
    } while (iCurrentLoop < iLoopTimes);  // loop untill out of times
    return [NSNumber numberWithBool: NO];
}

- (BOOL)repeatWriteCommand:(NSDictionary *)dicSendCommand ReceiveCommand:(NSDictionary *)dicReveiveCommand PassString:(NSString *)szPass ReturnValue:(NSMutableString *)szReturnValue
{
    BOOL bRet = NO;
    if (!dicSendCommand || !dicReveiveCommand)
    {
        return bRet;
    }
    
    [szReturnValue setString:@""];
    
    // get the repeat times, default is 1
    int iRepeatTimes = 1;
    if ([dicReveiveCommand objectForKey:@"RepeatTimes"] && [[dicReveiveCommand objectForKey:@"RepeatTimes"] isNotEqualTo:@""])
    {
        iRepeatTimes = [[dicReveiveCommand objectForKey:@"RepeatTimes"] intValue];
    }
    
    int iCurrentRepeat = 0;
    do 
    {
        iCurrentRepeat++;
        ATSDebug(@"[BEGIN]repeatWriteCommand: %i times try to write command \"%@\"", iCurrentRepeat, [dicSendCommand objectForKey:kFZ_Script_CommandString]);
        bRet = NO;
        bRet = [[self SEND_COMMAND:dicSendCommand] boolValue];
        if (bRet)
        {
            bRet = [[self READ_COMMAND:dicReveiveCommand RETURN_VALUE:szReturnValue] boolValue];
			
			// Added by Lorky 2012-05-01 in Cpto 
			// If we get the ECID Key and we need to trandfor the szPassFlagOfDiags to the correct format.
            
			if ([szPass isEqualToString:@":-)"] && [[m_dicMemoryValues objectForKey:@"LORKY_DEVICE_ECID"] length] > 0)
			{
				szPass = kFZ_EndFlagFormat;
			}
        }
        if (bRet)
        {
            if (nil != szPass)// if szPass is nil, just take is as no need to judge pass string
            {
                NSLog(@"%s:%s", [szReturnValue UTF8String], [szPass UTF8String]);
                //if saPass = :-) ,szReturnVlaue = :-), break , but ECID may not caught
                if ([szReturnValue isEqualToString:szPass])
                {
                    ATSDebug(@"[PASS]repeatWriteCommand: Pass to compare the pass string: %@ (%i times)", szPass, iCurrentRepeat);
                    //if in recovery mode, break to send "diag"
                    if ([szPass isEqualToString:@"]"]) 
                    {
                        bRet = YES;
                        break;
                    }
                    //[2012-08-14 11:00:30.237](TX ==> [MOBILE]):
                    //[2012-08-14 11:00:30.250](RX ==> [MOBILE]):
                    
                    //[4420208F:8E7F3233] 
                    
                    //[2012-08-14 11:00:30.254](Clear Buffer ==> [MOBILE]):
                    
                    //[2012-08-14 11:00:30.257](TX ==> [MOBILE]):
                    //[2012-08-14 11:00:30.260](RX ==> [MOBILE])::-) 
                    //add this judgement to fix above bug
                    if ([[m_dicMemoryValues objectForKey:@"LORKY_DEVICE_ECID"] length]==0)
                    {
                        ATSDebug(@"Response didn't contain ECID, need try again!");
                        bRet = NO;
                    }
                    else
                    {
                        bRet = YES;
                        break;
                    }
                }
                else
                {
                    ATSDebug(@"[FAIL]repeatWriteCommand: Fail to compare the pass string: %@ (%i times)", szPass, iCurrentRepeat);
                    bRet = NO;
                }
            }
            else
            {
                ATSDebug(@"[PASS]repeatWriteCommand: Don't need to get the pass string (%i times)", iCurrentRepeat);
                bRet = YES;
            }
        }
        else
        {
            ATSDebug(@"[FAIL]repeatWriteCommand: Read command \"%@\" fail, ReturnValue: %@ (%i times)", [dicSendCommand objectForKey:kFZ_Script_CommandString], szReturnValue, iCurrentRepeat);
            bRet = NO;
        }
    }while (iCurrentRepeat < iRepeatTimes); // loop untill out of times 
    return bRet;
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
-(NSNumber *)ConvertVoltage:(NSDictionary *)dicParam RETURN_VALUE:(NSMutableString *)strReturnValue
{
    
    if (strReturnValue == nil || [strReturnValue isEqualToString:@""]) 
    {
        [strReturnValue setString:@"FAIL"];
        return [NSNumber numberWithBool:NO];
    }
    double dFlapVolage = [strReturnValue doubleValue];
    double dReturnValue = 0.0;
    
    if (dFlapVolage > 2048) 
    {
        dFlapVolage = 4096-dFlapVolage;
        dReturnValue = 1500 - 1500*(((double)(dFlapVolage))/2048);
    }else
    {
        dReturnValue = 1500 + 1500*(((double)(dFlapVolage))/2048);
    }
    
    [strReturnValue setString:[NSString stringWithFormat:@"%0.6f",dReturnValue]];
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
-(NSNumber *)Calculate_Offset:(NSDictionary *)dicParam RETURN_VALUE:(NSMutableString *)strReturnValue
{
    if (strReturnValue == nil) 
    {
        [strReturnValue setString:@""];
        return [NSNumber numberWithBool:NO];
    }
    if ((nil == [dicParam valueForKey:@"KEY1"])|| (nil == [dicParam valueForKey:@"KEY2"])) 
    {
        [strReturnValue setString:@"Get Value FAIL"];
        return [NSNumber numberWithBool:NO];
    }
    //NSString  *keyFirst = [dicParam valueForKey:@"KEY1"];
    NSString  *strValue1 = [m_dicMemoryValues valueForKey:[dicParam valueForKey:@"KEY1"]];
    strValue1 = [strValue1 stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    strValue1 = [strValue1 stringByReplacingOccurrencesOfString:@"0X" withString:@""];
    
    NSString  *strValue2 = [m_dicMemoryValues valueForKey:[dicParam valueForKey:@"KEY2"]];
    strValue2 = [strValue2 stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    strValue2 = [strValue2 stringByReplacingOccurrencesOfString:@"0X" withString:@""];
    NSString  *strJoinString = [NSString stringWithFormat:@"0x%@%@",strValue1,strValue2];
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
-(NSNumber *)Calculate_Tesla:(NSDictionary *)dicParam RETURN_VALUE:(NSMutableString *)strReturnValue
{
    if (strReturnValue == nil) 
    {
        [strReturnValue setString:@""];
        return [NSNumber numberWithBool:NO];
    }
    if ((nil == [dicParam valueForKey:@"OFFSET"])|| (nil == [dicParam valueForKey:@"VOLTAGE"])) 
    {
        [strReturnValue setString:@"Get Value FAIL"];
        return [NSNumber numberWithBool:NO];
    }
    NSString  *strOffset = [dicParam valueForKey:@"OFFSET"];
    NSString  *strVoltage = [dicParam valueForKey:@"VOLTAGE"];
    strOffset = [m_dicMemoryValues valueForKey:strOffset];
    strVoltage = [m_dicMemoryValues valueForKey:strVoltage];
    
    float fResult;
    NSScanner *scanner = [NSScanner scannerWithString:strVoltage];
    if(!([scanner scanFloat:&fResult] && [scanner isAtEnd]))
    {
        ATSDebug(@"Calculate_Tesla:Can't read correct voltage from fixture!");
        [strReturnValue setString:@"NA"];
        return [NSNumber numberWithBool:NO];
    }
    double    dTestFlap = ([strOffset doubleValue]-[strVoltage doubleValue])/(1.25*10);
    [strReturnValue setString:[NSString stringWithFormat:@"%0.6f",dTestFlap]];
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
-(NSNumber *)Calculate_AverageVoltage:(NSDictionary *)dicParam RETURN_VALUE:(NSMutableString *)strReturnValue
{
    BOOL bRet =    NO;
    NSDictionary *dicSendCommand = [dicParam objectForKey:@"SendCommand"];
    NSDictionary *dicReciveCommand = [dicParam objectForKey:@"ReceiveCommand"];
    NSDictionary *dicTransfer   =   [dicParam objectForKey:@"TransferResult"];
    NSString     *strKey        =   [dicParam objectForKey:@"MemForCalculate"]?[dicParam objectForKey:@"MemForCalculate"]:@"Voltage";
    NSMutableArray *arrValue = [[NSMutableArray alloc]init];
    double result=0.0;
    if (!dicSendCommand || !dicReciveCommand )
    {
        ATSDebug(@"(FAIL)Calculate_AverageVoltage: NO Parameters about send and read command");
        [strReturnValue setString:@"Calculate_AverageVoltage Parameters ERROR"];
		[arrValue release];//add by jingfu ran for avoiding memory leak on 2012 05 02
        return [NSNumber numberWithBool:NO];
    }
    int iLoopTime = 50;  // default loop time is 50
    if ([dicParam objectForKey:@"LoopTimes"] && [[dicParam objectForKey:@"LoopTimes"] isNotEqualTo:@""])
    {
        iLoopTime = [[dicParam objectForKey:@"LoopTimes"] intValue];
    }
    
    for (int i = 0; i < iLoopTime; i++)
    {
        bRet = [[self SEND_COMMAND:dicSendCommand] boolValue];
        if (bRet) 
        {
            bRet = [[self READ_COMMAND:dicReciveCommand RETURN_VALUE:strReturnValue] boolValue];
        }
        else
        {
            ATSDebug(@"[Fail]Calculate_AverageVoltage Fail: Send_Command \"%@\" fail (%i times)",[dicSendCommand objectForKey:kFZ_Script_CommandString],i);
			[arrValue release];//add by jingfu ran for avoiding memory leak on 2012 05 02
            return [NSNumber numberWithBool:NO];
        }
        if (bRet) 
        {
            // add by betty for judging dicTransfer is need or not, if nil, don't need transfer on 2012.05.04
            if (dicTransfer) 
            {
                bRet = [[self NumberSystemConvertion:dicTransfer RETURN_VALUE:strReturnValue]boolValue];
            }
        }
        else
        {
            ATSDebug(@"[Fail]Calculate_AverageVoltage Fail: Read_Command \"%@\" fail,returnValue:%@ (%i times)",[dicSendCommand objectForKey:kFZ_Script_CommandString],strReturnValue ,i);
            [arrValue release];//add by jingfu ran for avoiding memory leak on 2012 05 02
			return [NSNumber numberWithBool:NO];
        }
        // marked by betty for no use for convert voltage on 2012.05.04
        /*if (bRet) 
        {
            bRet = [[self ConvertVoltage:dicParam RETURN_VALUE:strReturnValue]boolValue];
        }
        else
        {
            ATSDebug(@"[Fail]Calculate_AverageVoltage Fail: convert voltage fail (%i times)",i);
            [arrValue release];//add by jingfu ran for avoiding memory leak on 2012 05 02
			return [NSNumber numberWithBool:NO];
        }*/
        if (bRet) 
        {
            result += [strReturnValue floatValue];
            //modified by jingfu ran for avoiding memory leak on 2012 05 03
            [arrValue addObject:[NSString stringWithFormat:@"%@",strReturnValue]];
        }
        else
        {
            ATSDebug(@"[Fail]Calculate_AverageVoltage Fail: convert the %@ from 16 to 10 fail (%i times)",strReturnValue,i);
            [arrValue release];//add by jingfu ran for avoiding memory leak on 2012 05 02
			return [NSNumber numberWithBool:NO];
        }
    }
    result = result / iLoopTime;
    [strReturnValue setString:[NSString stringWithFormat:@"%i",(int)result]];
    [m_dicMemoryValues setValue:arrValue forKey:strKey];
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
-(NSNumber *)SplitVoltage:(NSDictionary *)dicParam RETURN_VALUE:(NSMutableString *)strReturnValue
{
    if (strReturnValue == nil || [strReturnValue isEqualToString:@""]) 
    {
        [strReturnValue setString:@"FAIL"];
        return [NSNumber numberWithBool:NO];
    }
    NSString *strKey1 = [dicParam objectForKey:@"KEY1"]?[dicParam objectForKey:@"KEY1"]:@"EEProm1";
    NSString *strkey2 = [dicParam objectForKey:@"KEY2"]?[dicParam objectForKey:@"KEY2"]:@"EEProm1";
    NSString *strKey  = [dicParam objectForKey:kFZ_Script_MemoryKey];
    NSString *strValue = [NSString stringWithString:[m_dicMemoryValues objectForKey:strKey]];
    int SplitLocation = [dicParam objectForKey:@"SplitLocation"]?[[dicParam objectForKey:@"SplitLocation"]intValue]:2;
    if (4 < [strValue length])
    {
        ATSDebug(@"the value you get from voltage is not correct");
    }
    else
        if ([strValue length]< 4) 
        {
            int i = 4 - [strValue length];
            for (; i>0; i--)
            {
                strValue = [NSString stringWithFormat:@"0%@",strValue];
            }
        }
    NSString *strValue1 = [strValue substringToIndex:SplitLocation];
    [m_dicMemoryValues setValue:strValue1 forKey:strKey1];
    strValue1 = [strValue substringFromIndex:SplitLocation];
    [m_dicMemoryValues setValue:strValue1 forKey:strkey2];
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
-(NSNumber *)WriteToPlist:(NSDictionary *)dicParam RETURN_VALUE:(NSMutableString *)strReturnValue
{
    NSString *strFileName = [dicParam objectForKey:@"FileName"]?[dicParam objectForKey:@"FileName"]:@"MagnetClibration";
    NSString *strPath = [NSString stringWithFormat:@"%@/Library/Preferences/%@.plist", NSHomeDirectory(),strFileName];
    NSFileManager *BuildPlistPath = [NSFileManager defaultManager];
    if ([BuildPlistPath fileExistsAtPath:strPath] != YES) 
    {
        [BuildPlistPath createFileAtPath:strPath contents:nil attributes:nil];
        NSMutableDictionary *dicSetting = [[NSMutableDictionary alloc]init];
        [dicSetting writeToFile:strPath atomically:NO];
        [dicSetting release];
        ATSDebug(@"Create MagnetCalibration file in path %@ PASS",strPath);
    }
    NSMutableDictionary *dicSetting = [[NSMutableDictionary alloc]initWithContentsOfFile:strPath];
    NSString *strKey = [dicParam objectForKey:@"KEY"]?[dicParam objectForKey:@"KEY"]:@"other";
    NSString *strValue = [NSString stringWithString:strReturnValue];
    [dicSetting setObject:strValue forKey:strKey];
    [dicSetting writeToFile:strPath atomically:NO];
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
-(NSNumber *)CalculateSTD:(NSDictionary *)dicParam RETURN_VALUE:(NSMutableString *)strReturnValue
{
    NSString *strKey = [dicParam objectForKey:kFZ_Script_MemoryKey]?[dicParam objectForKey:kFZ_Script_MemoryKey]:@"Voltage";
    
    id  arrValue = [m_dicMemoryValues objectForKey:strKey];
    
    if (![arrValue isKindOfClass:[NSArray class]]) 
    {
        ATSDebug(@"The value you get is not NSArray class");
        return [NSNumber numberWithBool:NO];
    }
    
    double doubleTemp = 0.0, doubleSum1 = 0.0,doubleSum2 = 0.0;
	for(int i=0; i<[arrValue count]; i++)
	{
		doubleTemp = [[arrValue objectAtIndex:i] doubleValue];
		doubleSum1 += doubleTemp*doubleTemp;
		doubleSum2 += doubleTemp;
		
	}
	int iCount = [arrValue count];
	double fResult = sqrt(((iCount*doubleSum1-doubleSum2*doubleSum2)/(iCount*(iCount-1)*1.0)));
    [strReturnValue setString:[NSString stringWithFormat:@"%f",fResult]];
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
- (NSNumber *)ADD_AveVoltage_TO_CSV:(NSDictionary *)dictData RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSString    *strPath = [NSString stringWithFormat:@"%@/Library/Preferences/MagnetClibration.plist", NSHomeDirectory()];
    NSDictionary *dicSetting = [NSDictionary dictionaryWithContentsOfFile:strPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:strPath]!=YES) 
    {
        if (!m_bCancelToEnd)
        {
            NSRunAlertPanel(@"警告(Warning)", @"请先对治具进行校验！(Please do fixture calibration first!)", @"确认(OK)", nil, nil);
            m_bCancelToEnd = YES;
            m_bNoUploadPDCA = YES; //If do not fixture calibration, cancel to end and don't upload pdca(No sn at this time)
        }
        ATSDebug(@"the file is not exits,please do MagnetCalibration first!");
        [szReturnValue setString:@"No calibaration data"];
        return [NSNumber numberWithBool:NO];
    }
    NSString *strKey = [dictData objectForKey:kFZ_Script_MemoryKey];
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

- (NSNumber *)NONEED_UPLOAD_PDCA:(NSDictionary *)dicPara RETURN_VALUE:(NSMutableString *)szReturnValue
{
    BOOL bNoNeedUpload = NO;
    if(nil ==[dicPara valueForKey:@"NoNeedUpload"])
    {
        bNoNeedUpload = NO; 
    }
    else
    {
        bNoNeedUpload = [[dicPara valueForKey:@"NoNeedUpload"] boolValue];
    }
    
    NSString *strSN = [dicPara valueForKey:@"setSN"];
    if (strSN) {
        [self setMobileSerialNumber:[NSString stringWithString:strSN]];  
    }
    
    m_bNoUploadPDCA = bNoNeedUpload;
    return [NSNumber numberWithBool:YES];
}

-(float) CalculateDistanceFromBytes:(unsigned int) high low:(unsigned int) low
{
    float sensor_full_scale = 220;
    float sensor_scale_factor = (sensor_full_scale / 4095);
    unsigned int acc = 0;
    // drop bits 7 and 6 from high
    acc = (0x3F & high);
    // move high niblet up 6 bits
    acc <<= 6;
    // drop bits 7 and 6 from low
    acc |= (0x3F & low);
    // scale and return mm's
    return (fabsf(sensor_full_scale-(float)(acc*sensor_scale_factor)));
}

-(NSNumber *)GetDistance:(NSDictionary *)dicSetting ReturnValue:(NSMutableString *)strReturn
{
    //Add by Shania to check prox sensor response
    if (![self JudgeProxSensorData:dicSetting return_Value:strReturn])
    {
        ATSDebug(@"JudgeProxSensorData result is not good!");
        return [NSNumber numberWithBool:NO];
    }
    
    //modified by jingfu ran 2012 04 30
    unsigned int high = 0;
    unsigned int low = 0;
    //Modified by Shania 2012/05/30
    NSArray  *arrayHexValue = [strReturn componentsSeparatedByString:@" "];
//    for (int i = 0; i < [strReturn length]; i++) 
//    {
//        unsigned char charValue = [strReturn characterAtIndex:i];
//        [arrayHexValue addObject:[NSString  stringWithFormat:@"%X",charValue]];
//       
//    }
//    ATSDebug(@"The prox seneor data = %@\n length = %d\n StringValue:%@\n",[arrayHexValue componentsJoinedByString:@" "],[strReturn length],strReturn);
//    [arrayHexValue release];
    //end by jingfu ran on 2012 05 03
//	if ([strReturn length] == 4) 
//    {
//        high = [strReturn characterAtIndex:3];
//        ATSDebug(@"The prox seneor is less than 5\n. data = %@\nlength = %d\n",strReturn,[strReturn length]);
//        return [NSNumber numberWithBool:NO];
//    }else if ([strReturn length] > 4)
    if ([arrayHexValue count]>5)
    {  
        NSScanner  *scan = [NSScanner scannerWithString:[arrayHexValue objectAtIndex:3]];
        [scan scanHexInt:&high];
        scan = [NSScanner scannerWithString:[arrayHexValue objectAtIndex:4]];
        [scan scanHexInt:&low];
        ATSDebug(@"High = %d, Low = %d",high, low);
    }else
    {
        ATSDebug(@"The prox seneor is less than 5\n data = %@\nlength = %d\n",strReturn,[arrayHexValue count]);
        return [NSNumber numberWithBool:NO];
    }
	float sensor_cal_distance = 82;
	float distance_actual = [self CalculateDistanceFromBytes:high low:low];
	float distance = distance_actual *(-1)+sensor_cal_distance;
    
    if (![[dicSetting objectForKey:@"Init"] boolValue]) 
    {
        ATSDebug(@"The prox sensor read data = %.6f",distance);
        float fInitLocation = [[kPD_UserDefaults objectForKey:@"InitLocation"] floatValue];
        NSString    *strPath = [NSString stringWithFormat:@"%@/Library/Preferences/HESCalibration.plist", NSHomeDirectory()];
        NSDictionary *dicSetting = [NSDictionary dictionaryWithContentsOfFile:strPath];
        float fInitDistance = [[dicSetting objectForKey:@"InitDistance"] floatValue];
        ATSDebug(@"The InitLocation is %.6f and InitDistance is %.6f",fInitLocation,fInitDistance);
        distance = distance + fInitLocation - fInitDistance;
    }
	[strReturn setString:[NSString stringWithFormat:@"%0.6f",distance]];
    ATSDebug(@"The convert prox sensor data = %.6f",distance);
    
	return [NSNumber numberWithBool:YES];
}

-(NSNumber *)CalculateMoveDistance:(NSDictionary *)dicSetting ReturnVale:(NSMutableString *)strReturn
{
    BOOL  bCancelToEND = [dicSetting valueForKey:@"CANCELTOEND"] == nil ? NO:[[dicSetting valueForKey:@"CANCELTOEND"] boolValue];
    NSString   *strCanceToEndDistance = [dicSetting valueForKey:@"CANCELDISTANCE"];
    float   fNeedMove = [[dicSetting valueForKey:@"INITDISTANCE"] floatValue];
    //Save the INITDISTNACE for the later judge  by Shania 2012/5/28
    [m_dicMemoryValues setObject:[dicSetting valueForKey:@"INITDISTANCE"] forKey:@"INITDISTANCE"];
    ATSDebug(@"INITDISTANCE saved: %@",[dicSetting valueForKey:@"INITDISTANCE"]);
    
    NSString  *strKeyValue = [dicSetting valueForKey:@"KEY"];
    NSString  *strValue = [m_dicMemoryValues valueForKey:strKeyValue];
    float  iawayfromZero = [strValue floatValue]-fNeedMove;
    long  lNeedMoveDistance = 0;
    lNeedMoveDistance = (long)kHallEffect_CaluteDistance_Value * iawayfromZero;
    [strReturn setString:[NSString stringWithFormat:@"%ld",lNeedMoveDistance]];
    
    //add by jingfu ran for end test if init default location fail on 2012 05 04
    if (bCancelToEND) 
    {
        if (abs([strValue floatValue]) >= [strCanceToEndDistance floatValue]) 
        {
            [strReturn setString:@"INIT FAIL"];
            m_bCancelToEnd = YES;
            ATSDebug(@"Init fixture to default location fail! ");
            return [NSNumber numberWithBool:NO];
        }
    }
    //end by jingfu ran on 2012 05 04
    return [NSNumber numberWithBool:YES];
}




-(NSNumber *)FindTheMissOrDetectLocation:(NSDictionary *)dicSetting ReturnValue:(NSMutableString *)strReturn
{
    NSString   *strFirstCommand = [dicSetting valueForKey:@"FIRSTCOMMAND"];
    NSString   *strSecondCommand = [dicSetting valueForKey:@"SECONDCOMMAND"];
	NSString   *strThirdCommand = [dicSetting valueForKey:@"THIRDCOMMAND"];
    NSString   *strFirstNeedHasString = [dicSetting valueForKey:@"FIRSTNEEDSTRING"];
    NSString   *strSecondNeedHasString = [dicSetting valueForKey:@"SECONDNEEDSTRING"];
	NSString   *strThirdNeedHasString  = [dicSetting valueForKey:@"THIRDNEEDSTRING"];
    //modified by jingfu ran for avoid ertra operator and direct tranform NSData as command  data as  ken's advice
    id ProxCommand = [dicSetting valueForKey:@"PROXCOMMAND"];
    NSString   *strFirstStoreInMemoryKey = [dicSetting valueForKey:@"FIRSTSTOREKEY"];
    NSString   *strSecondStorememoryKey = [dicSetting valueForKey:@"SECONDSTOREKEY"];
	NSString   *strThirdStoreMemoryKey	= [dicSetting valueForKey:@"THIRDSTOREKEY"];
    NSString   *strFLCommand = [dicSetting valueForKey:@"FLCOMMAND"];
    NSString   *strPortMobileType = [dicSetting valueForKey:@"TARGETMOBILE"];
    NSString   *strPortFixtureType = [dicSetting valueForKey:@"TARGETFIXTURE"];
    NSString   *strPortProxSensorType = [dicSetting valueForKey:@"TARGETPROXSENSOR"];
    NSString   *strInitValue = [dicSetting valueForKey:@"INITDISTANCE"];
    NSString   *strRemainTimes = [dicSetting valueForKey:@"REMAINTIMES"]; 
    NSString   *strProxHasString = [dicSetting valueForKey:@"PROXHASSTRING"];
    int       iTryReadProxDataTimes = [dicSetting valueForKey:@"READPROXDATATIME"] == nil ? 3:[[dicSetting valueForKey:@"READPROXDATATIME"] intValue];
    int       tryTimes = [[dicSetting valueForKey:@"TRYCOUNT"] intValue];
    BOOL      bFirstNoNeedloop = NO;
    BOOL      bSecondNoNeedLoop = NO;
	BOOL      bThirdNoNeedLoop = YES;
    
    NSDictionary *dicCheckMotorStatus = [dicSetting objectForKey:@"CheckMotorStatus"];
	
    // change NSMutableDictionary to NSDictionary by Soshon on 2012.05.09
    NSDictionary  *dicFirstCommandInfo = [NSDictionary dictionaryWithObjectsAndKeys:strPortMobileType,@"TARGET",
										  strFirstCommand,@"STRING",nil];
    NSDictionary  *dicSecondCommandInfo = [NSDictionary dictionaryWithObjectsAndKeys:strPortMobileType,@"TARGET",
										   strSecondCommand,@"STRING",nil];
	NSDictionary  *dicThirdCommandInfor = [NSDictionary dictionaryWithObjectsAndKeys:strPortMobileType,@"TARGET",
										   strThirdCommand,@"STRING",nil];
    NSDictionary  *dicProxCommandInfo = [NSDictionary dictionaryWithObjectsAndKeys:strPortProxSensorType,@"TARGET",
										 ProxCommand,@"STRING",[NSNumber numberWithInt:1],@"HEXSTRING",nil];
    NSDictionary  *dicFixtureCommandInfo = [NSDictionary dictionaryWithObjectsAndKeys:strPortFixtureType,@"TARGET",
											strFLCommand,@"STRING",nil];
    // end by Soshon
    NSDictionary  *dicReadMobileinfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"DELETE_ENTER",@":-)",@"END",[NSNumber numberWithDouble:0.1],kFZ_Script_ReceiveInterval,[NSArray arrayWithObjects:@":-)",nil],@"END_SYMBOL",[NSNumber numberWithInt:0],@"MATCHTYPE",strPortMobileType,@"TARGET",[NSNumber numberWithInt:5],@"TIMEOUT",nil];
    NSDictionary  *dicReadProxSensorinfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"DELETE_ENTER",[NSNumber numberWithInt:0],@"MATCHTYPE",[NSNumber numberWithDouble:0.1],kFZ_Script_ReceiveInterval,strPortProxSensorType,@"TARGET",[NSArray arrayWithObjects:@"Y", nil],@"END_SYMBOL",[NSNumber numberWithInt:1],@"TIMEOUT",nil];
    NSDictionary  *dicProxReadInfo = [NSDictionary dictionaryWithObjectsAndKeys:strProxHasString,@"PROXHASSTRING",nil];
	/* NSDictionary  *dicReadFixtureInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],@"DELETE_ENTER",[NSArray arrayWithObjects:@"%",@"?",@"\r",@"\n",nil],@"END_SYMBOL",[NSNumber numberWithInt:0],@"MATCHTYPE",strPortFixtureType,@"TARGET",[NSNumber numberWithInt:1],@"TIMEOUT",nil];*/
    
    
    long  lMaxValue = (long)kHallEffect_CaluteDistance_Value *([strInitValue intValue]);
    long  lRemainTimes = strRemainTimes == nil ? 0:[strRemainTimes floatValue];
    long  lOnceDisTance =[[[strFLCommand componentsSeparatedByString:@" "] lastObject] integerValue];
    lOnceDisTance = ABS(lOnceDisTance);
    bool bFirst=YES, bSecond=YES, bThird=YES;
    if ([dicSetting objectForKey:@"SkipItem"]&& [m_muArrayCancelCase count]>0) 
    {
        NSArray *arrSkipItem = [[dicSetting objectForKey:@"SkipItem"]componentsSeparatedByString:@","];
        if ([arrSkipItem containsObject:@"irq0"]) {
            bFirstNoNeedloop = YES;
        }
       if ([arrSkipItem containsObject:@"irq1"]) {
                bSecondNoNeedLoop = YES;
            }
        if ([arrSkipItem containsObject:@"irq2"])
        {  bThirdNoNeedLoop = YES;}
    }
    while (tryTimes >= 0 && (lMaxValue +lOnceDisTance> lOnceDisTance *lRemainTimes))  //add +lOnceDisTance to  make motor move more one time on 2012 05 23 by jingfu ran
    {
        int iReadProxDataTimes = iTryReadProxDataTimes;
        if (bFirstNoNeedloop && bSecondNoNeedLoop && bThirdNoNeedLoop) 
        {
            break;
        }
        if (!bFirstNoNeedloop) 
        {
            
            [self SEND_COMMAND:dicFirstCommandInfo];
            [self READ_COMMAND:dicReadMobileinfo RETURN_VALUE:strReturn];
            
            if (NSNotFound !=  [strReturn rangeOfString:strFirstNeedHasString].location) 
            {
                //Remove CheckMotor here and put it after motor moved instead by Shania 2012/05/30
                //if ([[self CheckMotorStatus:dicCheckMotorStatus ReturnValue:strReturn]boolValue]) 
                //{
                    //modified by jingfu ran on 2012 05 08 to add retest function if read prox length equal or less than 3
                    do 
                    {
                        [self SEND_COMMAND:dicProxCommandInfo];
                        usleep(1000);
                        [self READ_COMMAND:dicReadProxSensorinfo RETURN_VALUE:strReturn];
                        ATSDebug(@"ReadProxData count = %d",iReadProxDataTimes);
						iReadProxDataTimes--;
                        bFirst = [[self GetDistance:dicProxReadInfo ReturnValue:strReturn] boolValue];
                        
                    }while (!bFirst && iReadProxDataTimes >= 0); 
                    //} while ((![[self JudgeProxSensorData:nil return_Value:strReturn] boolValue]) && iReadProxDataTimes >= 0);
                    
                    //Move GetDistance into the reading loop to avoid incorrect data reading. eg. return digit less than 5
                    //[self GetDistance:dicProxReadInfo ReturnValue:strReturn];
                    [m_dicMemoryValues setObject:[NSString stringWithString:strReturn] forKey:strFirstStoreInMemoryKey];
                    bFirstNoNeedloop = YES;
                    //end by jingfu ran on 2012 05 08
                    //need 

                //}
            }
            
        }
        
        if (!bSecondNoNeedLoop) 
        {
            [self SEND_COMMAND:dicSecondCommandInfo];
            [self READ_COMMAND:dicReadMobileinfo RETURN_VALUE:strReturn];
			
            if (NSNotFound !=  [strReturn rangeOfString:strSecondNeedHasString].location) 
            {
                //modified by jingfu ran on 2012 05 08 to add retest function if read prox length equal or less than 3
                do 
                {
                    [self SEND_COMMAND:dicProxCommandInfo];
                    usleep(1000);
                    [self READ_COMMAND:dicReadProxSensorinfo RETURN_VALUE:strReturn];
                    ATSDebug(@"ReadProxData count = %d",iReadProxDataTimes);
					bSecond = [[self GetDistance:dicProxReadInfo ReturnValue:strReturn] boolValue];
					iReadProxDataTimes--;
                   
                }while (!bSecond && iReadProxDataTimes >= 0); 

                //} while ((![[self JudgeProxSensorData:nil return_Value:strReturn] boolValue]) && iReadProxDataTimes >= 0);
                
                //Move GetDistance into the reading loop to avoid incorrect data reading. eg. return digit less than 5
                //[self GetDistance:dicProxReadInfo ReturnValue:strReturn];

                [m_dicMemoryValues setObject:[NSString stringWithString:strReturn] forKey:strSecondStorememoryKey];
                bSecondNoNeedLoop = YES;
            }
            
        }
		
		if (!bThirdNoNeedLoop) 
        {
            [self SEND_COMMAND:dicThirdCommandInfor];
            [self READ_COMMAND:dicReadMobileinfo RETURN_VALUE:strReturn];
			
            if (NSNotFound !=  [strReturn rangeOfString:strThirdNeedHasString].location) 
            {
                    //modified by jingfu ran on 2012 05 08 to add retest function if read prox length equal or less than 3
                do 
                {
                    [self SEND_COMMAND:dicProxCommandInfo];
                    usleep(1000);
                    [self READ_COMMAND:dicReadProxSensorinfo RETURN_VALUE:strReturn];
                    bThird = [[self GetDistance:dicProxReadInfo ReturnValue:strReturn] boolValue];
                    ATSDebug(@"ReadProxData count = %d",iReadProxDataTimes);
					iReadProxDataTimes--;
                }while (!bThird && iReadProxDataTimes >= 0); 

                //} while ((![[self JudgeProxSensorData:nil return_Value:strReturn] boolValue]) && iReadProxDataTimes >= 0);
                
                //Move GetDistance into the reading loop to avoid incorrect data reading. eg. return digit less than 5
                //[self GetDistance:dicProxReadInfo ReturnValue:strReturn];

                    [m_dicMemoryValues setObject:[NSString stringWithString:strReturn] forKey:strThirdStoreMemoryKey];
                    bThirdNoNeedLoop = YES;
            }
            
        }
		
        if (!bFirstNoNeedloop || !bSecondNoNeedLoop || !bThirdNoNeedLoop) 
        {
            [self SEND_COMMAND:dicFixtureCommandInfo];
            //[self READ_COMMAND:dicReadFixtureInfo RETURN_VALUE:strReturn];
            //CheckMotorStatus after moving 
            if(![[self CheckMotorStatus:dicCheckMotorStatus ReturnValue:strReturn] boolValue])
            {
                ATSDebug(@"Motor Status NOT GOOD.");
                [strReturn setString:@"FAIL"];
                return  [NSNumber numberWithBool:NO];
            }
            lMaxValue -= lOnceDisTance;
        }
        tryTimes--;
    }
    
    if ((tryTimes < 0 || (lMaxValue <= lOnceDisTance *lRemainTimes))
        && !(bFirstNoNeedloop && bSecondNoNeedLoop))
        //&& !(bFirstNoNeedloop && bSecondNoNeedLoop && bThirdNoNeedLoop)) //add && bThirdNoNeedLoop for avoid judge wrong test result! by jingfu ran on 2012 05 23
    {
        [strReturn setString:@"FAIL"];
        return [NSNumber numberWithInt:NO];
    }
    // Ignore irq2
    //if(bFirst && bSecond && bThird){
    if (bFirst && bSecond) {
        [strReturn setString:@"PASS"];
        return [NSNumber numberWithBool:YES];
    }else
    {
        [strReturn setString:@"FAIL"];
        return [NSNumber numberWithBool:NO];
    }
        
}

- (NSNumber *)JudgeMoveDistance:(NSDictionary *)dicSetting ReturnValue:(NSMutableString *)strReturn
{
    NSString   *strInitValue = [dicSetting valueForKey:@"Target"]?[dicSetting valueForKey:@"Target"]:@"8";
    float lValue = [strReturn floatValue] - [strInitValue floatValue];
    [strReturn setString:[NSString stringWithFormat:@"%0.6f",lValue]];
    return  [NSNumber numberWithBool:YES];
}
- (NSNumber *)CheckDistance:(NSDictionary *)dicSetting ReturnValue:(NSMutableString *)strReturn
{
    NSString *strStep = [dicSetting objectForKey:@"Step"]?[dicSetting objectForKey:@"Step"]:@"1000";
    NSString *strLength = [dicSetting objectForKey:@"Distance"]?[dicSetting objectForKey:@"Distance"]:@"0.5";
    NSString *strStepS = [dicSetting objectForKey:@"StepS"]?[dicSetting objectForKey:@"StepS"]:@"500";
    NSString *strLengthS = [dicSetting objectForKey:@"DistanceS"]?[dicSetting objectForKey:@"DistanceS"]:@"0.25";
    
    NSDictionary *dicSendCommand = [dicSetting objectForKey:@"SEND_COMMAND"];
    NSDictionary *dicReceiveCommand = [dicSetting objectForKey:@"READ_COMMAND"];
    NSDictionary *dicProxSendCommand = [dicSetting objectForKey:@"PROXSENDCOMMAND"];
    NSDictionary *dicProxReadCommand = [dicSetting objectForKey:@"PROXREADCOMMAND"];
    NSDictionary *dicCheckMotorStatus = [dicSetting objectForKey:@"CheckMotorStatus"];
    NSString     *strRetryTimes = [dicSetting valueForKey:@"TRYTIMES"]?[dicSetting valueForKey:@"TRYTIMES"]:@"3";
    //NSString     *strInitValue = [dicSetting valueForKey:@"Target"]?[dicSetting valueForKey:@"Target"]:@"8";
    //Get Initial Distance from Memory key: INITDISTANCE by Shania 2012/05/28
    NSString    *strInitValue = [m_dicMemoryValues objectForKey:@"INITDISTANCE"]?[m_dicMemoryValues objectForKey:@"INITDISTANCE"]:@"8";
                                
    NSString     *strSpec    = [dicSetting valueForKey:@"Limit"]?[dicSetting valueForKey:@"Limit"]:@"8,8.25";
    NSString     *strLowLimit, *strHighLimit;
    
    //Add limits for initial position  by Shania 2012/5/25
    strLowLimit     = [strSpec SubFrom:@"[" include:NO];
    strLowLimit     = [strLowLimit SubTo:@"," include:NO];
    strHighLimit    = [strSpec SubFrom:@"," include:NO];
    strHighLimit     = [strHighLimit SubTo:@"]" include:NO];
   // NSString   *strProxHasString = [dicSetting valueForKey:@"PROXHASSTRING"];
    //NSDictionary  *dicProxReadInfo = [NSDictionary dictionaryWithObjectsAndKeys:strProxHasString,@"PROXHASSTRING",nil];
    float lValue = 0;
    int iReadProxDataTimes = 3;
    
    if (dicSendCommand == nil || dicReceiveCommand == nil)
    {
        ATSDebug(@"check your plist, there is no SEND_COMMAND or READ_COMMAND");
        return [NSNumber numberWithBool:NO];
    }
    NSMutableString   *strReturnValue = [[NSMutableString alloc] initWithString:strReturn];
    int tryTime = [strRetryTimes intValue];
    //
    while (tryTime > 0) 
    {
        ATSDebug(@"Start Fine Tune #%d",tryTime);
        iReadProxDataTimes = 3;
        lValue = [strReturnValue floatValue] - [strInitValue floatValue];
            
        //Modify stop loop condition by Shania 2012/5/25
        //Stop Loop when distance is within strLowLimit and strUpLimit
        if([strReturnValue floatValue] >= [strLowLimit floatValue]  && [strReturnValue floatValue] <= [strHighLimit floatValue])
        {
            ATSDebug(@"[%@] Already in Spec. Stop moving.",strReturnValue);
            break;
        }
        
        //Calculate times need to loop to fine tune init position
        //NOTE: strLength setting can not be smaller than delta of strLowLimit and strUpLimit
        
        //If delta < 1mm, use strLengthS and strStepS
        NSNumber *numStep = [NSNumber numberWithInt:1000];
        int iMoveTimes = 0;
        if(ABS(lValue)>1){
            numStep = [NSNumber numberWithInt:[strStep intValue]];
            iMoveTimes = ABS(lValue)/([strLength floatValue]);
        }
        else
        {
            numStep = [NSNumber numberWithInt:[strStepS intValue]];
            iMoveTimes = ABS(lValue)/([strLengthS floatValue]);
        }
        
        //Judge move Up (positive) or Down (negative)    
        if(lValue<0)
            numStep = [NSNumber numberWithInt:(-1)*[numStep intValue]];
        
        [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%@", numStep] forKey:@"STEP"];
        ATSDebug(@"Going to move %@, %d times",numStep,iMoveTimes);
        //Force it to move at least once in case of the distance is less than 0.25
        if(iMoveTimes==0)
            iMoveTimes=1;
        
        for (int i = 0; i < iMoveTimes; i++)
        {
            ATSDebug(@"Move #%d, Command: %@", i, dicSendCommand);
            [self SEND_COMMAND:dicSendCommand];
            //usleep(300000);
        }
        if ([[self CheckMotorStatus:dicCheckMotorStatus ReturnValue:strReturn]boolValue]) 
        {   
           // usleep(300000);
            do 
            {
                [self SEND_COMMAND:dicProxSendCommand];
                usleep(1000);
                [self READ_COMMAND:dicProxReadCommand RETURN_VALUE:strReturnValue];
                iReadProxDataTimes--;
            
            }while((![[self GetDistance:dicSetting ReturnValue:strReturnValue] boolValue]) && iReadProxDataTimes >= 0);
        }
        
        tryTime--;
    }
        
    [strReturn setString:strReturnValue];
    
    //Show limits at csv and UI
    NSDictionary    *dicTheSpec = [NSDictionary dictionaryWithObjectsAndKeys:strSpec, kFZ_Script_JudgeCommonBlack , nil];
    dicTheSpec = [NSDictionary dictionaryWithObjectsAndKeys:dicTheSpec , kFZ_Script_JudgeCommonSpec , nil];
    NSNumber *numRet = [self JUDGE_SPEC:dicTheSpec RETURN_VALUE:strReturnValue];
    
    [strReturnValue release];
    return numRet;
}

- (NSNumber *)CheckMotorStatus:(NSDictionary *)dicSetting ReturnValue:(NSMutableString *)strReturn
{
    NSDictionary *dicSendCommand = [dicSetting objectForKey:@"SEND_COMMAND"];
    NSDictionary *dicReceiveCommand = [dicSetting objectForKey:@"READ_COMMAND"];
    int tryCount = [dicSetting objectForKey:@"RepeatTime"]?[[dicSetting objectForKey:@"RepeatTime"]intValue]:5;
    NSString *strPassReceive = [dicSetting objectForKey:@"ExpectReceive"]?[dicSetting objectForKey:@"ExpectReceive"]:@"SR=R";
    do 
    {
        [self SEND_COMMAND:dicSendCommand];
        usleep(1000);
        [self READ_COMMAND:dicReceiveCommand RETURN_VALUE:strReturn];
        ATSDebug(@"the %d receive command of SR is %@",tryCount,strReturn);
        if(NSNotFound != [strReturn rangeOfString:strPassReceive].location)
        {
            break;
        }
        tryCount --;
    }while (tryCount > 0);   
    if (tryCount < 0)
    {
        return [NSNumber numberWithBool:NO];
    }
    return [NSNumber numberWithBool:YES];
}

-(NSNumber *)READ_FIXTURESN:(NSDictionary *)dicSetting ReturnValue:(NSMutableString *)strReturn
{
    
    NSString   *szPortType = [dicSetting valueForKey:kFZ_Script_DeviceTarget];
    id         idWantToNumberIndex = [dicSetting valueForKey:@"ISNUMBERINDEX"];
    NSString   *strChar = [dicSetting valueForKey:@"SeperateChar"];
    NSString   *strPath = [[m_dicPorts valueForKey:szPortType] objectAtIndex:kFZ_SerialInfo_SerialPort];
    NSString   *strFixtureSN = @"";
    if (strPath == nil) 
    {
        return [NSNumber numberWithBool:NO];
    }
    if ([idWantToNumberIndex boolValue]) 
    {
        if (strChar != nil) 
        {
            if (NSNotFound != [strPath rangeOfString:strChar].location) 
            {
                NSArray  *arrayType = [strPath componentsSeparatedByString:strChar];
                strFixtureSN = [arrayType lastObject];
            }else
            {
                strFixtureSN = [strPath substringFromIndex:[strPath length]-2];
            }
            
        }else
        {
            strFixtureSN = [strPath substringFromIndex:[strPath length]-2];
        }
    }else
    {
		//modified by jingfu ran for avoiding memory leak on 2012 05 02
		strFixtureSN = [NSString  stringWithString:strFixtureSN];
    }
    [strReturn setString:strFixtureSN];
    return [NSNumber numberWithBool:YES];
}

/*calculate average value of some values that saved in dictionary
 *if value is "NA" or "" ,won't be calculated
 */
-(NSNumber *)AVERAGE_FORKEYS:(NSDictionary *)dicSetting RETURN_VALUE:(NSMutableString *)strReturn
{
    BOOL bRet = YES;
    float fAve = 0;
    
    [strReturn setString:@"NA"];
    NSString *szKeys = [dicSetting objectForKey:@"KEY"];
    if (szKeys != nil && [szKeys isKindOfClass:[NSString class]]) 
    {
        NSInteger iCount = 0;
        float fSum = 0;
        NSArray *aryKeys = [szKeys componentsSeparatedByString:@","];
        for (NSString *szKey in aryKeys) 
        {
            if(![szKey isEqualToString:@""] && ![szKey isEqualToString:@" "] && ![szKey isEqualToString:@"NA"] && ![szKey isEqualToString:@"N/A"])
            {
                NSString *szValue = [m_dicMemoryValues objectForKey:szKey];
                if (szValue != nil ) 
                {
                    if (![szValue isEqualToString:@""] && ![szValue isEqualToString:@" "] && ![szValue isEqualToString:@"NA"] && ![szValue isEqualToString:@"N/A"] && [szValue intValue] != 0) 
                    {
                        iCount++;
                        fSum += [szValue floatValue];                            
                    }
                }  
                else
                {
                    bRet = NO;
                }
            }
        }
        fAve = fSum/iCount;
        [strReturn setString:[NSString stringWithFormat:@"%.6f",fAve]]; 
    }
    else
    {
        bRet = NO;
    }
    
    return [NSNumber numberWithBool:bRet];
}

- (NSNumber *)CHECKMATRIX:(NSDictionary *)dicSetting RETURN_VALUE:(NSMutableString *)strReturn
{
	BOOL bRowResult = YES, bColResult = YES;
	NSUInteger iCheckRowCount = [[dicSetting objectForKey:@"RowCount"] intValue];
	NSUInteger iCheckColCount = [[dicSetting objectForKey:@"ColCount"] intValue];
	
	NSArray * aryRow = [strReturn componentsSeparatedByString:@"\n"];
	bRowResult &= ([aryRow count] == iCheckRowCount);
	NSString * strRowCompare = bRowResult ? [NSString stringWithFormat:@"Compare Row OK, row count is [%d]",iCheckRowCount] : [NSString stringWithFormat:@"Compare Row NOT OK, checking count is [%d], actually count is [%d]",iCheckColCount,[aryRow count]];
    ATSDebug(@"%@", strRowCompare);
	
	for (NSUInteger i = 0; i < [aryRow count]; i++)
	{
		id obj = [aryRow objectAtIndex:i];
		NSArray * aryCol = [obj componentsSeparatedByString:@"\t"];
		bColResult &= ([aryCol count] == iCheckColCount);
		strRowCompare = bColResult ? [NSString stringWithFormat:@"Compare Row[%d] OK, Column count is [%d]", i, iCheckColCount] : [NSString stringWithFormat:@"Compare Row[%d] NOT OK, checking count is [%d], actually count is [%d]",i,iCheckColCount,[aryRow count]];
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
    
	NSArray * sortedArray  = [m_mathLibrary BringOrderToArray:_SourceArray];
	return [[sortedArray lastObject] floatValue];
}

// Get the min value from the given array.
// Note: The given array should be NSNumber type.
// Return: 
//		minimal value
- (float)getMinValueFromArray:(NSArray *)_SourceArray
{
	NSArray * sortedArray  = [m_mathLibrary BringOrderToArray:_SourceArray];
	return [[sortedArray objectAtIndex:0] floatValue];
}
-(NSNumber *)GETDRAGONFLYDATA:(NSDictionary *)dicParam RETURN_VALUE:(NSMutableString *)strReturnValue
{
    NSMutableArray * aryOneZone = [[NSMutableArray alloc] init];
	NSMutableArray * aryZeroZone = [[NSMutableArray alloc] init];
    NSString  *strValue = [m_dicMemoryValues valueForKey:[dicParam objectForKey:@"DISPOSAL"]];
	NSArray * row = [strValue componentsSeparatedByString:@"\n"];
    NSMutableArray *muArray = [[NSMutableArray alloc]init];
    if ([row count] > 0) 
    {
        //Add object for muArray
        for (NSUInteger i = 0; i < [row count]; i++)
        {
            [muArray addObject:[NSString stringWithFormat:@"%d",i]];
        }
        //Arrange muArray by row number
        for (NSUInteger i = 0; i < [row count]; i++)
        {
            NSString * strRow = [row objectAtIndex:i];
            NSArray *arrTitle = [strRow componentsSeparatedByString:@"]"];
            if ([arrTitle count] >= 2) 
            {
                NSArray *number = [[arrTitle objectAtIndex:0] componentsSeparatedByString:@"row"];
                if ([number count] >= 2) 
                {
                    NSUInteger inumber = [[number objectAtIndex:1]intValue];
                    if ([row count] > inumber) 
                    {
                        [muArray removeObjectAtIndex:inumber];
                        [muArray insertObject:[arrTitle objectAtIndex:1] atIndex:inumber];
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
            NSString * strRow = [muArray objectAtIndex:i];
            NSArray * column = [strRow componentsSeparatedByString:@"\t"];
            // The first column is title like [rowXX], it not useful data.
            for (NSUInteger j = 1; j < [column count]; j++)
            {
                // the data rectangle width is larger than height
                if ([column count] - 1 < [muArray count])
                {
                    // useful data count is "[column count]-1"
                    if ((abs(i-(j-1)))%([column count]-1)==0)
                        [aryOneZone addObject:[NSNumber numberWithFloat:[[column objectAtIndex:j] floatValue]]];
                    else
                        [aryZeroZone addObject:[NSNumber numberWithFloat:[[column objectAtIndex:j] floatValue]]];
                }
                // the data rectangle widt is smaller than height
                else 
                {
                    if ((abs(j-1-i))%([row count])==0)
                        [aryOneZone addObject:[NSNumber numberWithFloat:[[column objectAtIndex:j] floatValue]]];
                    else
                        [aryZeroZone addObject:[NSNumber numberWithFloat:[[column objectAtIndex:j] floatValue]]];
                }
            }
        }
        if ([aryZeroZone count]&&[aryOneZone count]) 
        {
            float maxZero = [self getMaxValueFromArray:aryZeroZone];
            float minZero = [self getMinValueFromArray:aryZeroZone];
            float aveZero = (float)[m_mathLibrary GetAverageWithArray:aryZeroZone NeedABS:NO];
            
            float maxOne = [self getMaxValueFromArray:aryOneZone];
            float minOne = [self getMinValueFromArray:aryOneZone];
            float aveOne = (float)[m_mathLibrary GetAverageWithArray:aryOneZone NeedABS:NO];
            
            [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%.2f",maxZero] forKey:[dicParam objectForKey:@"ZeroPtMax"]];
            [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%.2f",minZero] forKey:[dicParam objectForKey:@"ZeroPtMin"]];
            [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%.2f",aveZero] forKey:[dicParam objectForKey:@"ZeroPtAve"]];
            
            [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%.2f",maxOne] forKey:[dicParam objectForKey:@"OnePtMax"]];
            [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%.2f",minOne] forKey:[dicParam objectForKey:@"OnePtMin"]];
            [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%.2f",aveOne] forKey:[dicParam objectForKey:@"OnePtAve"]];
            
            
            
            //NSLog(@"maxZero : %f\nminZero : %f\naveZero : %f\nmaxOne : %f\nminOne : %f\naveOne : %f\n",maxZero,minZero,aveZero,maxOne,minOne,aveOne);
            
            // printf("PTRN_DCSIG_ONE_PT_MIN : %.2f\nPTRN_DCSIG_ONE_PT_AVG : %.2f\nPTRN_DCSIG_ONE_PT_MAX : %.2f\nPTRN_DCSIG_ZRO_PT_MIN : %.2f\nPTRN_DCSIG_ZRO_PT_AVG : %.2f\nPTRN_DCSIG_ZRO_PT_MAX : %.2f\n",minOne,aveOne,maxOne,minZero,aveZero,maxZero);
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
-(NSNumber *)JudgeProxSensorData:(NSDictionary*)dicSetting return_Value:(NSMutableString *)strReturn
{
    if ([strReturn length] <= 3) 
    {  
        return [NSNumber numberWithBool:NO];  
    }
    NSString   *strHasString = [dicSetting valueForKey:@"PROXHASSTRING"] == nil?@"0x81 0x6 0x59":[dicSetting valueForKey:@"PROXHASSTRING"];
    NSMutableString  *strValue = [[NSMutableString alloc] initWithString:@""];
    
    for (int i = 0; i < [strReturn length]; i++) 
    {
        [strValue appendFormat:@" 0x%X",(unsigned char)[strReturn characterAtIndex:i]];
    }
    [strValue setString:[strValue substringFromIndex:1]];
    ATSDebug(@"Prox data = %@\n length = %d\n",strValue,[strReturn length]);
    NSRange range = [strValue rangeOfString:strHasString];
    if (NSNotFound != range.location) 
    {
        [strReturn setString:[strValue substringFromIndex:range.location]];
//        NSArray    *array = [strValue componentsSeparatedByString:@" "];
//        char   value[100] = {'\0'};
//        for (int i = 0; i < [array count]; i++) 
//        {
//            unsigned int   iValue = 0;
//            NSScanner  *scan = [NSScanner scannerWithString:[array objectAtIndex:i]];
//            [scan scanHexInt:&iValue];
//            value[i] = iValue;
//        }
        //[strReturn setString:[NSString stringWithCString:value encoding:NSASCIIStringEncoding]];
        //[strReturn setString:strValue];
    }else
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
    {
        value = -value;
    }
    return value;
}

-(NSNumber *)RemoveToPosition:(NSDictionary *)dicSetting Return_Value:(NSMutableString *)strReturn
{

    NSString   *strFixtureTarget = [dicSetting valueForKey:@"FIXTURETARGET"];
    NSString   *strProxSensorTarget = [dicSetting valueForKey:@"PROXSENSORTARGET"];
    NSString   *strFixCommand = [dicSetting valueForKey:@"COMMAND"];
    NSString   *strProxHasString = [dicSetting valueForKey:@"PROXHASSTRING"];
    NSString   *strTryMaxTimes = [dicSetting valueForKey:@"MAXTIMES"] == nil ? @"500":[dicSetting valueForKey:@"MAXTIMES"];
    //modified by jingfu ran for avoid extra operator and tranform NSData to as command as ken's advice
    id         ProxCommand = [dicSetting valueForKey:@"PROXCOMMAND"];
    NSString   *strCalValue = [dicSetting valueForKey:@"CALVALUE"] == nil ? @"82":[dicSetting valueForKey:@"CALVALUE"];
    NSDictionary  *dicProxReadInfo = [NSDictionary dictionaryWithObjectsAndKeys:strProxHasString,@"PROXHASSTRING",nil];
    NSDictionary  *dicFixtureCommandInfo = [NSDictionary dictionaryWithObjectsAndKeys:strFixtureTarget,@"TARGET",
											strFixCommand,@"STRING",nil];
    NSDictionary  *dicFixtureSubCommndInfo = [NSDictionary dictionaryWithObjectsAndKeys:strFixtureTarget,@"TARGET",
											@"FL -100",@"STRING",nil];
      
    NSDictionary  *dicReadProxSensorinfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"DELETE_ENTER",[NSNumber numberWithInt:0],@"MATCHTYPE",strProxSensorTarget,@"TARGET",[NSArray arrayWithObjects:@"Y", nil],@"END_SYMBOL",[NSNumber numberWithInt:1],@"TIMEOUT",nil];
    NSDictionary  *dicProxCommandInfo = [NSDictionary dictionaryWithObjectsAndKeys:strProxSensorTarget,@"TARGET",
										 ProxCommand,@"STRING",[NSNumber numberWithInt:1],@"HEXSTRING",nil];
   
    float a[3] = {0};
    int i = 0;
    int iMaxTimes = [strTryMaxTimes intValue];
    NSMutableString   *strResponse = [[NSMutableString alloc] init];
    while (1) 
    {
        //add by jingfu ran to avoid  endless loop
        if (iMaxTimes <= 0) 
        { 
            [strResponse release];
            [strReturn setString:[NSString  stringWithFormat:@"a[0]:%.6f a[1]: %.6f a[2]:%f",a[0],a[1],a[2]]];
            return [NSNumber numberWithBool:NO];
        }
        iMaxTimes--;
        [self SEND_COMMAND:dicFixtureCommandInfo];
        [self SEND_COMMAND:dicProxCommandInfo];
        [self READ_COMMAND:dicReadProxSensorinfo RETURN_VALUE:strResponse];
        if (![self JudgeProxSensorData:dicProxReadInfo return_Value:strResponse]) 
        {
            [self SEND_COMMAND:dicFixtureSubCommndInfo];
            continue;
        }else
        {
            [self GetDistance:nil ReturnValue:strResponse];
        }
        a[i] = [strResponse floatValue] + [strCalValue floatValue];
        i++;
        i = i%3;
        if (a[0] == 0 || a[1] == 0 || a[2] == 0) 
        {
            continue;
        }
        if ((a[1] > a[0]+0.03) && (a[2] > a[1]+0.03))
        {
            
        }else
        {
            if (([self absFloat:a[1] - a[0]] < 0.03) && ([self absFloat:(a[2]-a[1])] < 0.03)) 
            {
                 break;
            } else
            {
                continue;
            }
        }
    }
    [strResponse release];
    [strReturn setString:[NSString  stringWithFormat:@"a[0]:%.6f a[1]: %.6f a[2]:%f",a[0],a[1],a[2]]];
    return [NSNumber numberWithBool:YES];
}

/*
 *Fixture move to top
 */
-(NSNumber *)MOVE_TOP:(NSDictionary *)dicSetting RETURN_VALUE:(NSMutableString *)strReturn
{
    NSDictionary *dicSendFL = [dicSetting objectForKey:@"1.SEND_COMMAND:"];
    NSDictionary *dicReadFL = [dicSetting objectForKey:@"2.READ_COMMAND:RETURN_VALUE:"];
    NSDictionary *dicCheckStatus = [dicSetting objectForKey:@"3.CheckMotorStatus:ReturnValue:"];
    NSDictionary *dicSendProx = [dicSetting objectForKey:@"4.SEND_COMMAND:"];
    NSDictionary *dicReadProx = [dicSetting objectForKey:@"5.READ_COMMAND:RETURN_VALUE:"];
    NSDictionary *dicGetDistance = [dicSetting objectForKey:@"6.GetDistance:ReturnValue:"];
    double dTimeout = [[dicSetting objectForKey:@"TIME_OUT"] doubleValue];
    
    float fSpec = [[dicSetting objectForKey:@"ABS_SPEC"] floatValue];
    
    BOOL bRet = YES; 

    float fPreLastDistance = 0;
    float fLastDistance = 0;
    float fCurrentDistance = 0;
    
    NSString *szFirstValue = @"";
    NSString *szPreLastValue = @"";
    NSString *szLastValue = @"";
    NSString *szCurrentValue = @"";
    NSDate			*dtStartTime = [NSDate date];
    NSTimeInterval	dEndTime = 0.0;
    do {
        bRet = [[self SEND_COMMAND:dicSendFL] boolValue];
        bRet &= [[self READ_COMMAND:dicReadFL RETURN_VALUE:strReturn] boolValue];
        bRet &= [[self CheckMotorStatus:dicCheckStatus ReturnValue:strReturn] boolValue];
        bRet &= [[self SEND_COMMAND:dicSendProx] boolValue];
        bRet &= [[self READ_COMMAND:dicReadProx RETURN_VALUE:strReturn] boolValue];
        bRet &= [[self GetDistance:dicGetDistance ReturnValue:strReturn] boolValue];
        if (bRet) 
        {
            szFirstValue = [NSString stringWithString:szPreLastValue];
            szPreLastValue = [NSString stringWithString:szLastValue];
            szLastValue = [NSString stringWithString:szCurrentValue];
            szCurrentValue = [NSString stringWithString:strReturn];
            
            fPreLastDistance = [szPreLastValue floatValue] - [szFirstValue floatValue];
            fLastDistance = [szLastValue floatValue] - [szPreLastValue floatValue];
            fCurrentDistance = [szCurrentValue floatValue] - [szLastValue floatValue];
            
            if (fabs(fPreLastDistance)<fSpec && fabs(fLastDistance)<fSpec && fabs(fCurrentDistance)<fSpec) 
            {
                break;
            }
        }
        usleep(10);
        dEndTime = [[NSDate date] timeIntervalSinceDate:dtStartTime];
    } while (dTimeout >= dEndTime);
    if (dEndTime > dTimeout) 
    {
        return [NSNumber numberWithBool:NO];
    }
    return [NSNumber numberWithBool:YES];
}

- (NSNumber *)JUDGESPEC_CSV_UPLOADPARAMETRIC:(NSDictionary  *)dicPara  RETURN_VALUE:(NSMutableString*)szReturnValue
{
    // get the data and spec
    NSString        *szSpec = [dicPara objectForKey:@"SPEC"];
    // return value
    NSNumber        *retNum = [NSNumber numberWithBool:YES];
    // for parametic data
    NSString        *szParaName = [dicPara objectForKey:@"PARANAME"];
    NSString        *szLowLimits, *szHighLimits, *szParamatricData;;
    NSMutableString *strMuData = [NSMutableString stringWithString:
                                  [m_dicMemoryValues objectForKey:[dicPara objectForKey:@"STRDATA"]]];
    //strMuData                    = [dicPara objectForKey:@"STRDATA"];
    //strMuData                    = [m_dicMemoryValues objectForKey:strMuData];
    if (strMuData != nil)
    {
        NSDictionary        *dicTheSpec = [NSDictionary dictionaryWithObjectsAndKeys:szSpec, kFZ_Script_JudgeCommonBlack , nil];
        dicTheSpec = [NSDictionary dictionaryWithObjectsAndKeys:dicTheSpec , kFZ_Script_JudgeCommonSpec , nil];
        if (![[self JUDGE_SPEC:dicTheSpec RETURN_VALUE:strMuData] boolValue])
        {
            [szReturnValue setString:[NSString stringWithFormat:@"The value %@ is not in the spec %@",strMuData,szSpec]];
            ATSDebug(@"szReturn value %@",szReturnValue);
            retNum = [NSNumber numberWithBool:NO];
        }
        [m_dicMemoryValues setObject:@"{N/A}" forKey:kFZ_TestLimit];
        
        // upload paramatric data
        szLowLimits = [szSpec SubFrom:@"[" include:NO];
        szLowLimits = [szLowLimits SubTo:@"," include:NO];
        szHighLimits = [szSpec SubFrom:@"," include:NO];
        szHighLimits = [szHighLimits SubTo:@"]" include:NO];
        // creat the parametric name
        
        szParamatricData = [NSString stringWithFormat:@"%@",szParaName,nil];
        NSDictionary *dicUpload =[NSDictionary dictionaryWithObjectsAndKeys:szLowLimits,kFZ_Script_ParamLowLimit,szHighLimits,kFZ_SCript_ParamHighLimit,szParamatricData,kFZ_Script_UploadParametric,[NSNumber numberWithBool:NO],kFunnyZoneNOWriteCsvToLogFile,nil];
        
        [self UPLOAD_PARAMETRIC:dicUpload RETURN_VALUE:strMuData];
        
        
    }
    // loop to judge spec and upload parametric data
   // [strMuData release];
    return retNum;
}

- (NSNumber *)CatchWIFISN:(NSDictionary  *)dicPara  RETURN_VALUE:(NSMutableString*)szReturnValue
{
    NSString    * szReturn;
    NSMutableString *strValue = [[NSMutableString alloc]init];
    NSMutableArray *arrValue = [[NSMutableArray alloc]init];
    
    NSString    *szKey = [dicPara objectForKey:kFZ_Script_MemoryKey];
    NSString	*szCatchedValue	= [m_dicMemoryValues objectForKey:szKey];
    int iStart = [[dicPara objectForKey:@"START"]intValue]?[[dicPara objectForKey:@"START"]intValue]:2;
    int iStep  = [[dicPara objectForKey:@"STEP"]intValue]?[[dicPara objectForKey:@"STEP"]intValue]:16;
    
    if(nil == szCatchedValue)
    {
        szReturn    =   @"Value not found";
        [szReturnValue setString:szReturn];
        [arrValue release];
        [strValue release];
        return [NSNumber numberWithBool:NO];
    }
    else if([szCatchedValue ContainString:@"RX ["])
    {
        szReturn    =   @"no response";
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
    {
        szReturn    =   [szCatchedValue stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    }
    NSArray     * arrRow=[szReturn componentsSeparatedByString:@"\n"];
    
    for (int i = 0; i < [arrRow count]; i++) 
    {
        NSArray *arrTemp = [[arrRow objectAtIndex:i]componentsSeparatedByString:@" "];
        for (int j = 1; j < iStep +1; j++) 
        {
            [arrValue addObject:[arrTemp objectAtIndex:j]];
        }
    }
    
    NSString *szLocation = [arrValue objectAtIndex:iStart-1];
    unsigned int  iLocation = 0;
    NSScanner *scan     = [NSScanner scannerWithString:szLocation];
    [scan scanHexInt:&iLocation];
    
    iLocation = iLocation + iStart;
    
    if ([[arrValue objectAtIndex:iLocation-1]isNotEqualTo:@"FF"]) 
    {
        [szReturnValue setString:@"Compare FF FAIL"];
        [arrValue release];
        [strValue release];
        return [NSNumber numberWithBool:NO];
    }
    
    NSString *szLength = [arrValue objectAtIndex:iLocation + 1];
    unsigned int iLength = 0;
    scan = [NSScanner scannerWithString:szLength];
    [scan scanHexInt:&iLength];
    [strValue setString:@""];
    
    iLocation = iLocation + 4;
    
    NSString *szWIFISNLength = [arrValue objectAtIndex:iLocation];
    unsigned int iWIFISNLength = 0;
    scan = [NSScanner scannerWithString:szWIFISNLength];
    [scan scanHexInt:&iWIFISNLength];
    
    if (iLength != iWIFISNLength + 3) {
        [szReturnValue setString:@"WIFI SN length is error!"];
        [arrValue release];
        [strValue release];
        return [NSNumber numberWithBool:NO];
    }
    
    iLocation = iLocation + 1;
    
    for (int i = iLocation; i < iLocation + iWIFISNLength; i++)
    {
        [strValue appendString:[arrValue objectAtIndex:i]];
        if (i != iLocation + iWIFISNLength-1) {
            [strValue appendString:@" "];
        }
        
    }
    [szReturnValue setString:strValue];
    
    [arrValue release];
    [strValue release];
    return [NSNumber numberWithBool:YES];
}

- (NSNumber *)READ_EEPROM_CHECK_SELETED_ITEMS:(NSDictionary *)dicPara RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSNumber    *numRet = [NSNumber numberWithBool:YES];
    NSNumber    *numCmdRet = [NSNumber numberWithBool:YES];
    int         iCount = 0;
    BOOL        failBreak = NO;
    
    NSString *szCSVFileName = [NSString stringWithFormat:@"%@/%@_%@_CSV.csv",kPD_LogPath_CSV,m_szPortIndex,m_szStartTime];
    
    NSDictionary    *dicSendWrite = [dicPara objectForKey:@"1.SEND_COMMAND:"];//send command "mipi longwrite 0x29 0xb8 0x1 /*ITEM0*/ /*ITEM1*/"
    NSDictionary    *dicReadWrite = [dicPara objectForKey:@"1.READ_COMMAND:RETURN_VALUE:"];
    NSDictionary    *dicSendPattern = [dicPara objectForKey:@"2.SEND_COMMAND:"];
    NSDictionary    *dicReadPattern = [dicPara objectForKey:@"2.READ_COMMAND:RETURN_VALUE:"];    
    NSDictionary    *dicSendRead = [dicPara objectForKey:@"3.SEND_COMMAND:"]; //send command "mipi read 0x14 0xc4"
    NSDictionary    *dicReadRead = [dicPara objectForKey:@"3.READ_COMMAND:RETURN_VALUE:"];
    NSDictionary    *dicSpecs = [dicPara objectForKey:@"JUDGE_EEPROM:"];//judge spec , just spec not 0x0
    NSArray         *aryNoSpecItems = [dicPara objectForKey:@"NOSPEC_ITEMS"];
    NSArray         *arrSeletedItems = [dicPara objectForKey:@"SELTECTED_ITEMS"];
    NSMutableString     *szReturn = [[NSMutableString alloc] initWithString:@""];
    
    int iSeletedItems = [arrSeletedItems count];
    
    for (NSInteger iInnerIndex = 0; iInnerIndex < iSeletedItems; iInnerIndex++) 
    {
        if (failBreak) {
            failBreak = NO;
            break;
        }
        NSString    *szRegistorAddress = [NSString stringWithFormat:@"%@", [arrSeletedItems objectAtIndex:iInnerIndex]];
        [m_dicMemoryValues setObject:szRegistorAddress forKey:@"ITEM"];
        numCmdRet = [self SEND_COMMAND:dicSendWrite];
        numCmdRet = [self READ_COMMAND:dicReadWrite RETURN_VALUE:szReturn];
        
        if (iInnerIndex==0) 
        {
            numCmdRet = [self SEND_COMMAND:dicSendPattern];
            numCmdRet = [self READ_COMMAND:dicReadPattern RETURN_VALUE:szReturn];
        }
        
        numCmdRet = [self SEND_COMMAND:dicSendRead];
        numCmdRet = [self READ_COMMAND:dicReadRead RETURN_VALUE:szReturn];
        
        if (![numCmdRet boolValue]) 
            iCount++;
        else
            iCount = 0;
        
        // if read 3 address value fail, break
        if (iCount == 3)
        {
            iCount = 0;
            failBreak = YES;
            break;
        }
        
        BOOL bSingleResult = YES;
        [szReturnValue setString:szReturn];
        if ([aryNoSpecItems containsObject:szRegistorAddress]) 
        {
            [self writeForNormalSpecName:szRegistorAddress status:bSingleResult csvPath:szCSVFileName sumNames:m_szTestNames sumUpLimits:m_szUpperLimits sumDnLimits:m_szDownLimits sumValueList:m_szValueList errorDescription:m_szErrorDescription sumError:m_szErrorInfo endItem:YES saveSummary:YES saveCSV:YES uploadParametric:NO CurrentIndex:0];
            continue;
        }
        
        NSString *szSpec = [dicSpecs objectForKey:szRegistorAddress];
        
        if (szSpec) 
        {
            //if spec in script file , means not 0x0
            if (![szSpec ContainString:szReturn])
            {
                //if spec not contain return value, return no (eg. spec is{0x19}, value should be 0x19 too)
                //[4D20238E:4BC1BEE3] :-) mipi read 0x14 0xc4
                //0x15 0x19
                //[szReturnValue appendFormat:@"%@: %@ !Contain %@ ",szRegistorAddress,szSpec,szReturn];
                numRet = [NSNumber numberWithBool:NO]; 
                bSingleResult = NO;
            }
        }
        else
        {
            szSpec = @"{0x0}";
            //if spec not in script file, means vlaue is 0x0
            if (![szReturn isEqualToString:@"0x0"]) 
            {
                //[szReturnValue appendFormat:@"%@: %@ !Equal 0x0 ",szRegistorAddress,szReturn];
                numRet = [NSNumber numberWithBool:NO];
                bSingleResult = NO;
            }
        }
        
        [m_dicMemoryValues setObject:szSpec forKey:kFZ_MP_TestLimit];
        [self writeForNormalSpecName:szRegistorAddress status:bSingleResult csvPath:szCSVFileName sumNames:m_szTestNames sumUpLimits:m_szUpperLimits sumDnLimits:m_szDownLimits sumValueList:m_szValueList errorDescription:m_szErrorDescription sumError:m_szErrorInfo endItem:YES saveSummary:YES saveCSV:YES uploadParametric:NO CurrentIndex:0];
        [m_dicMemoryValues setObject:@"{N/A}" forKey:kFZ_MP_TestLimit];
    }
    
    [szReturn release];
    return [numCmdRet boolValue]?numRet:numCmdRet;
}


- (NSNumber *)READ_EEPROM:(NSDictionary *)dicPara RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSNumber    *numRet = [NSNumber numberWithBool:YES];
    NSNumber    *numCmdRet = [NSNumber numberWithBool:YES];
    int         count = 0;
    BOOL        failBreak = NO;
    NSString    *fPath = @"/vault/EEPROM/";
    NSString    *lPath;
    
    NSString *szCSVFileName = [NSString stringWithFormat:@"%@/%@_%@_CSV.csv",kPD_LogPath_CSV,m_szPortIndex,m_szStartTime];
    
    NSDictionary    *dicSendWrite = [dicPara objectForKey:@"1.SEND_COMMAND:"];//send command "mipi longwrite 0x29 0xb8 0x1 /*ITEM0*/ /*ITEM1*/"
    NSDictionary    *dicReadWrite = [dicPara objectForKey:@"1.READ_COMMAND:RETURN_VALUE:"];
    NSDictionary    *dicSendPattern = [dicPara objectForKey:@"2.SEND_COMMAND:"];
    NSDictionary    *dicReadPattern = [dicPara objectForKey:@"2.READ_COMMAND:RETURN_VALUE:"];    
    NSDictionary    *dicSendRead = [dicPara objectForKey:@"3.SEND_COMMAND:"]; //send command "mipi read 0x14 0xc4"
    NSDictionary    *dicReadRead = [dicPara objectForKey:@"3.READ_COMMAND:RETURN_VALUE:"];
    NSDictionary    *dicSpecs = [dicPara objectForKey:@"JUDGE_EEPROM:"];//judge spec , just spec not 0x0
    NSArray *aryNoSpecItems = [dicPara objectForKey:@"NOSPEC_ITEMS"];
    
    BOOL    bIsLogWrite = [[dicPara objectForKey:@"WRITE_CSV"]boolValue]; //write as csv log?
    NSMutableString    *szRawData = [[NSMutableString alloc]initWithString:@""];
    
    NSMutableString     *szReturn = [[NSMutableString alloc] initWithString:@""];
    
    if (bIsLogWrite) 
    {
        NSFileManager   *fileManager = [NSFileManager defaultManager];
        
        if (![fileManager fileExistsAtPath:fPath]) 
        {
            [fileManager createDirectoryAtPath:fPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        NSString    *szLCM_SN = [m_dicMemoryValues objectForKey:@"LCM SN"];
        szLCM_SN = szLCM_SN?szLCM_SN:@"Null";
        NSString    *szStartTime = [NSString stringWithFormat: @"%@",m_szStartTime];
        lPath = [NSString stringWithFormat:@"%@EEPROM_VAL_%@_%@.csv",fPath,szLCM_SN,szStartTime];
        
        // set title
        [szRawData appendString:@"MSB,LSB,Value(Hex)\n"];
    }
    
    for (NSInteger iExtIndex = 0; iExtIndex <= 1; iExtIndex++) 
    {
        if (failBreak) {
            failBreak = NO;
            break;
        }
        for (NSInteger iInnerIndex = 0; iInnerIndex <= 255; iInnerIndex++) 
        {
            NSString    *szItem0 = [NSString stringWithFormat:@"0x%x",iExtIndex];
            NSString    *szItem1 = [NSString stringWithFormat:@"0x%x",iInnerIndex];
            NSString    *szRegistorAddress = [NSString stringWithFormat:@"%@%@",szItem0,szItem1];
            [m_dicMemoryValues setObject:szItem0 forKey:@"ITEM0"];
            [m_dicMemoryValues setObject:szItem1 forKey:@"ITEM1"];
            numCmdRet = [self SEND_COMMAND:dicSendWrite];
            numCmdRet = [self READ_COMMAND:dicReadWrite RETURN_VALUE:szReturn];
            
            if (iExtIndex==0 && iInnerIndex==0) 
            {
                numCmdRet = [self SEND_COMMAND:dicSendPattern];
                numCmdRet = [self READ_COMMAND:dicReadPattern RETURN_VALUE:szReturn];
            }
            
            numCmdRet = [self SEND_COMMAND:dicSendRead];
            numCmdRet = [self READ_COMMAND:dicReadRead RETURN_VALUE:szReturn];
            
            if (![numCmdRet boolValue]) 
                count++;
            else
                count = 0;
            
            // if read 3 address value fail, break
            if (count == 3)
            {
                count = 0;
                failBreak = YES;
                break;
            }
            
            BOOL bSingleResult = YES;
            [szReturnValue setString:szReturn];
            if ([aryNoSpecItems containsObject:szRegistorAddress]) 
            {
                [self writeForNormalSpecName:szRegistorAddress status:bSingleResult csvPath:szCSVFileName sumNames:m_szTestNames sumUpLimits:m_szUpperLimits sumDnLimits:m_szDownLimits sumValueList:m_szValueList errorDescription:m_szErrorDescription sumError:m_szErrorInfo endItem:YES saveSummary:YES saveCSV:YES uploadParametric:NO CurrentIndex:0];
                continue;
            }
            
            NSString *szSpec = [dicSpecs objectForKey:szRegistorAddress];
            
            if (szSpec) 
            {
                //if spec in script file , means not 0x0
                if (![szSpec ContainString:szReturn])
                {
                    //if spec not contain return value, return no (eg. spec is{0x19}, value should be 0x19 too)
                    //[4D20238E:4BC1BEE3] :-) mipi read 0x14 0xc4
                    //0x15 0x19
                    //[szReturnValue appendFormat:@"%@: %@ !Contain %@ ",szRegistorAddress,szSpec,szReturn];
                    numRet = [NSNumber numberWithBool:NO]; 
                    bSingleResult = NO;
                }
            }
            else
            {
                szSpec = @"{0x0}";
                //if spec not in script file, means vlaue is 0x0
                if (![szReturn isEqualToString:@"0x0"]) 
                {
                    //[szReturnValue appendFormat:@"%@: %@ !Equal 0x0 ",szRegistorAddress,szReturn];
                    numRet = [NSNumber numberWithBool:NO];
                    bSingleResult = NO;
                }
            }
            
            [m_dicMemoryValues setObject:szSpec forKey:kFZ_MP_TestLimit];
            [self writeForNormalSpecName:szRegistorAddress status:bSingleResult csvPath:szCSVFileName sumNames:m_szTestNames sumUpLimits:m_szUpperLimits sumDnLimits:m_szDownLimits sumValueList:m_szValueList errorDescription:m_szErrorDescription sumError:m_szErrorInfo endItem:YES saveSummary:YES saveCSV:YES uploadParametric:NO CurrentIndex:0];
            [m_dicMemoryValues setObject:@"{N/A}" forKey:kFZ_MP_TestLimit];
            
            // Write csv, name : EEPROM_VAL_startTime.csv
            [szRawData appendFormat:@"%@,%@,%@\n",szItem0,szItem1,szReturn];
        }
    }
    if (bIsLogWrite) {
        
        [szRawData writeToFile:lPath atomically:YES encoding:NSASCIIStringEncoding error:nil];
    }
    [szRawData release];
    [szReturn release];
    return [numCmdRet boolValue]?numRet:numCmdRet;
}

-(NSNumber *)JudgeSetChargeOrNot:(NSDictionary *)dicSub RETURN_VALUE:(NSMutableString *)szReturnValue
{
    int iUpLimit = [[dicSub objectForKey:@"UpLimit"]intValue];
    int iLowLimit = [[dicSub objectForKey:@"LowLimit"]intValue];
    NSNumber    *numCmdRet = [NSNumber numberWithBool:YES];
    NSNumber    *numRet = [NSNumber numberWithBool:YES];
    
    NSString *szPercent = [m_dicMemoryValues objectForKey:@"Percent"];
    if (!szPercent || [szPercent isEqualToString:@""]) {
        [szReturnValue setString:@"Can't get percent!"];
        return [NSNumber numberWithBool:NO];
    }
    szPercent = [szPercent SubTo:@"%" include:NO];
    int iPercent = [szPercent intValue];
    NSMutableString     *szReturn = [[NSMutableString alloc] initWithString:@""];
    
    //If the percentage is low than iLowLimit, send "charge --set 2000"
    if (iPercent < iLowLimit) 
    {
        NSDictionary *dicLowSendCommand = [dicSub objectForKey:@"LowSEND_COMMAND"];
        NSDictionary *dicLowReadCommand = [dicSub objectForKey:@"LowREAD_COMMAND"];
        numCmdRet = [self SEND_COMMAND:dicLowSendCommand];
        numCmdRet = [self READ_COMMAND:dicLowReadCommand RETURN_VALUE:szReturn];
    }
    //If the percentage is high than iHighLimit, send "charge --set 0"
    if (iPercent > iUpLimit)
    {
        NSDictionary *dicHighSendCommand = [dicSub objectForKey:@"HighSEND_COMMAND"];
        NSDictionary *dicHighReadCommand = [dicSub objectForKey:@"HighREAD_COMMAND"];
        numCmdRet = [self SEND_COMMAND:dicHighSendCommand];
        numCmdRet = [self READ_COMMAND:dicHighReadCommand RETURN_VALUE:szReturn];
    }
    if (!numCmdRet) 
    {
        [szReturnValue setString:szReturn];
    }
    
    [szReturn release];
    return [numCmdRet boolValue]?numRet:numCmdRet;
}

// add by Gordon for SMT-PROV auto get dummy sn with board id
- (NSNumber *)GET_SN_COMPARED_WITH_BOARDID:(NSDictionary *)dicPara RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSString *szBoardID = [m_dicMemoryValues objectForKey:[dicPara objectForKey:kFZ_Script_MemoryKey]];
    if (szBoardID && [szBoardID isNotEqualTo:@""])
    {
        // set Dummy SN
        [szReturnValue setString:[dicPara objectForKey:szBoardID]];
        //  set SN to m_szISN when we get sn from UNIT
        [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%@",szReturnValue] forKey:@"ISN"];
        BOOL bGetSN = [[self GET_SN:dicPara RETURN_VALUE:szReturnValue] boolValue];
        return [NSNumber numberWithBool:bGetSN];
    }
    else
    {
        [szReturnValue setString:@"Get Board ID FAIL"];
        return [NSNumber numberWithBool:NO];
    }
}

- (NSNumber *)JUDGE_SN_LIST_CANCEL:(NSDictionary *)dicSub RETURN_VALUE:(NSMutableString *)szReturnValue
{
    BOOL bCheckSum = [[dicSub objectForKey:@"NEED_CHECKSUM"] boolValue];
    NSString *szListName = [dicSub objectForKey:@"SN_LIST"];
    NSString *szListPath = [NSString stringWithFormat:@"%@/Contents/Frameworks/FunnyZone.framework/Resources/%@"
                              ,[[NSBundle mainBundle] bundlePath],szListName];
    NSString *szSNs = [NSString stringWithContentsOfFile:szListPath encoding:NSUTF8StringEncoding error:nil];
    
    if (bCheckSum) 
    {
        NSString *szKey = [dicSub objectForKey:@"CHECKSUM_KEY"];
        NSString *szCheckSumFile = [NSString stringWithFormat:@"%@/Library/Preferences/com.PEGATRON.checksum.plist",NSHomeDirectory()];
        NSDictionary* dicCheckSumDefaultValue = [NSDictionary dictionaryWithContentsOfFile:szCheckSumFile];
        NSString *szGhValue = [dicCheckSumDefaultValue objectForKey:szKey];
        BOOL bCheckSumResult = [self checkSum:szListPath withSum:szGhValue];
        if (!bCheckSumResult) 
        {
            NSRunAlertPanel(@"Warning", [NSString stringWithFormat:@"%@ has been modified, please change it back or redo groundhog!",szListPath], @"OK", nil, nil);
            [NSApp terminate:self];
        }
    }
    
    szSNs = [szSNs stringByReplacingOccurrencesOfString:@"\r" withString:@","];
    szSNs = [szSNs stringByReplacingOccurrencesOfString:@"\n" withString:@","];
    NSArray *arySn = [szSNs componentsSeparatedByString:@","];
    NSString *szCurrentSN = [NSString stringWithString:szReturnValue];
    if ([arySn containsObject:szCurrentSN]) 
    {
        return [NSNumber numberWithBool:YES];
    }
    else
    {
        m_bCancelFlag = YES;
        ATSDebug(@"JUDGE_SN_LIST FAIL:This unit %@ isn't in sn_list",szCurrentSN);
        return [NSNumber numberWithBool:NO];
    }
}

- (NSNumber *)CHECK_SECURITY_LIVE:(NSDictionary *)dicSub RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSInteger iCycleEnter = [[dicSub objectForKey:@"EnterCycleTime"] intValue];
    NSDictionary *dicSendEnter = [dicSub objectForKey:@"0.SEND_ENTER"];
    NSDictionary *dicReadEnter = [dicSub objectForKey:@"1.READ_ENTER"];
    
    NSNumber *numRet = [NSNumber numberWithBool:YES];
    for(NSInteger iIndex=0; iIndex<iCycleEnter; iIndex++)
    {
        numRet = [self SEND_COMMAND:dicSendEnter];
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
                    numRet = [self SEND_COMMAND:dicSendPasd];
                    if([numRet boolValue])
                    {
                        numRet = [self READ_COMMAND:dicReadPasd RETURN_VALUE:szReturnValue];
                        
                        if([numRet boolValue])
						{
							NSLog(@"Succeed to log in ! Return YES !");
							return [NSNumber numberWithBool:YES];
						}
						else
						{
							NSLog(@"Receive password response fail ! Return NO !");
							return [NSNumber numberWithBool:NO];
						}
					}
					else
					{
						NSLog(@"Send password fail ! Return NO !");
						return [NSNumber numberWithBool:NO];
					}
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
		else if([szReturnValue rangeOfString:@"iPad:~ root#"].location != NSNotFound)
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

-(NSNumber*)CHECKSCRIPT:(NSDictionary *)dicItemInfo RETURN_VALUE:(NSMutableString *)szReturnValue
{
	// get groundHog Info
	NSDictionary *dicStationInfo = [self getStationInfo];
	// get Station_ID of groundHog Info
	NSString *strStationID = [dicStationInfo objectForKey:kPD_GHInfo_STATION_ID];
	
	NSArray *aryAllKeys = [dicItemInfo allKeys];
	NSInteger iCount = [aryAllKeys count];
	
	for (NSInteger iIndex=0;iIndex<iCount;iIndex++)
	{
		NSString *strKey = [aryAllKeys objectAtIndex:iIndex];
		
		if ([strStationID ContainString:strKey])
		{
			if (![m_szScriptName ContainString:[dicItemInfo objectForKey:strKey]])
			{
				
				NSRunAlertPanel(@"警告(Warning)", @"请选择正确的剧本档!（Please choose the correct script!）", @"确认(OK)", nil, nil);
				[NSApp terminate:nil];
				m_bCancelToEnd = YES;
				return [NSNumber numberWithBool:NO];
			}
		}
	}
	return [NSNumber numberWithBool:YES];
}




@end
