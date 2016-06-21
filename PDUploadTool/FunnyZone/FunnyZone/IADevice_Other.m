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
#import "IADevice_Operation.h"

#define kOther_OSModeTool_Location          @"LOCATION"
#define kOther_OSModeTool_TimeOut           @"TIMEOUT"
#define kOther_OSModeTool_DefaultTimeOut    5
#define kOther_OSModeTool_StringEncoding    NSUTF8StringEncoding
#define kHallEffect_CaluteDistance_Value    (10000/(4.959702-(-0.358978)))

NSString * const TiltFixtureNotificationToUI = @"TiltFixtureNotificationToUI";
NSString * const TiltFixtureNotificationToFZ = @"TiltFixtureNotificationToFZ";
NSString * const BNRMonitorWindowTitleChangeNotification = @"MonitorWindowTitleChange";


//extern NSString *BNRTestProgressPopWindow;
//extern NSString *BNRTestProgressQuitWindow;

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
    NSArray * aryValue = [dictSettings allValues];
    
    for (id value in aryValue)
    {
        if([value isKindOfClass:[NSDictionary class]])
        {
            //spec name
            NSString * szSpecName = [value objectForKey:@"SpecName"];
            //color value like  0x00000200 0x00D7D9D8 0x00E1E4E3 0x00000000
            NSString * szColorValue = [value objectForKey:@"ColorValue"];
            //color
            NSString * szColor    = [value objectForKey:@"Color"];
            if([szSpecName isEqualToString:@""] || szSpecName == nil || [szColorValue isEqualToString:@""] || szColorValue == nil || [szColor isEqualToString:@""] || szColor == nil)
            {
                [strReturnValue setString:@"parameter fromat error"];
                return [NSNumber numberWithBool:NO];
            }
            
            if([strReturnValue isEqualToString:szColorValue])
            {
                [m_strSpecName setString:szSpecName];
                [m_dicMemoryValues setObject:szColor forKey:KIADeviceDUT_COLOR];
                return [NSNumber numberWithBool:YES];
            }
        }
        else
        {
            [strReturnValue setString:@"value is not a dictionary"];
            return [NSNumber numberWithBool:NO];
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
        NSInteger iRet = [uartObj Read_UartData:data TerminateSymbol:[NSArray arrayWithObjects:@"Vol Down",nil] MatchType:0 IntervalTime:kUart_IntervalTime TimeOut:timeOut Ignore:nil];
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

    NSString *szCurrentTestItem = @"";
	NSString *szDutColor = [m_dicMemoryValues valueForKey:KIADeviceDUT_COLOR];
	if ([szDutColor isEqualToString:@""] || szDutColor == nil)
	{
		szCurrentTestItem = [NSString stringWithFormat:@"%@_Unknown",[m_dicMemoryValues valueForKey:kFunnyZoneCurrentItemName]];
	}else
	{
		szCurrentTestItem = [NSString stringWithFormat:@"%@_%@",[m_dicMemoryValues valueForKey:kFunnyZoneCurrentItemName],szDutColor];
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
    if ([kFZ_99999_Value_Issue isEqualToString: szNumber])
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
        
        NSDictionary *dicCode = [dicpara objectForKey:@"MatchingTable"];
        if ([[dicCode allKeys] containsObject:strCCCCCode])
        {
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
    BOOL    bMatchAll = [[dicContents objectForKey:@"MATCHALL"] boolValue];//Leehua add 130225
    BOOL     bWant = [[dicContents objectForKey:@"WANT"] boolValue];
    NSString *szCharactor = [dicContents objectForKey:@"Charactor"];
    NSArray  *aryJudge = [dicContents objectForKey:@"Judge"];
    BOOL bTestRet = YES;
    
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
                    
                    //add by Leehua 130225
                    BOOL bRet = [[aryValues objectAtIndex:iIndex] isEqualToString:szXX];
                    
                    if (bWant == bRet) 
                    {
                        if (bMatchAll) 
                        {
                            bTestRet = YES;
                        }
                        else
                        {
                            ATSDebug(@"Judge_If_ALL_Value_Is_XX: Pass for one bit is %@ -> match type:%d!",szXX,bWant);
                            [strReturnValue setString:@"PASS"];
                            return [NSNumber numberWithBool:YES];
                        }
                    }
                    else
                    {
                        if (bMatchAll) 
                        {
                            ATSDebug(@"Judge_If_ALL_Value_Is_XX: Fail for one bit is %@ -> match type:%d!",szXX,bWant);
                            [strReturnValue setString:@"FAIL"];
                            return [NSNumber numberWithBool:NO];
                        }
                        else
                        {
                            bTestRet = NO;
                        }
                    }
                    
                    /* Marked by Leehua 130225
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
                     */
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
        [m_dicEmptyResponse setObject:[NSNumber numberWithInt:0] forKey:@"MOBILE"];
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

        if (![[[szReturnValue componentsSeparatedByString:@"\r"] lastObject] isEqualToString:szPassFlagOfRecovery])
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
            [m_dicEmptyResponse setObject:[NSNumber numberWithInt:0] forKey:@"MOBILE"];
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

// get the data from prox sensor
//Param:
//       NSDictionary       *dicSetting   : Settings
//       PROXHASSTRING        NSSting     : the string you need to check the prox sensor return value
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
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
    //ex: strReturn 0x81 0x6 0x59 0x6A 0x75 0x41
    NSArray  *arrayHexValue = [strReturn componentsSeparatedByString:@" "];
    if ([arrayHexValue count]>5)
    {  
        // get high and low value, and change hex to decimal
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
    //caluclate the distance with high and low
	float distance_actual = [self CalculateDistanceFromBytes:high low:low];
    ATSDebug(@"The distance_actual calculate fron high:%d and low:%d is %f",high,low,distance_actual);
	float distance = distance_actual *(-1)+sensor_cal_distance;
   
    //For not Init, the distance = distance + fInitLocation - FInitDistace
    //For Init, we just get the distance
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
    ATSDebug(@"The convert final prox sensor data = %.6f",distance);
    
	return [NSNumber numberWithBool:YES];
}

// calculate the distance you need to move
//Param:
//       NSDictionary       *dicSetting   : Settings
//       CANCELTOEND         NSNumber     : need cancel to end or not
//      CANCELDISTANCE       NSString     : the cancel distance, if the distance larger than canceldistance, cancel to the end
//      INITDISTANCE         NSString     : the Init Distance you want to locate the magnet
//      AWAYFROMZERO         NSString     : the key you memory the current locate
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
-(NSNumber *)CalculateMoveDistance:(NSDictionary *)dicSetting ReturnVale:(NSMutableString *)strReturn
{
    BOOL  bCancelToEND = [dicSetting valueForKey:@"CANCELTOEND"] == nil ? NO:[[dicSetting valueForKey:@"CANCELTOEND"] boolValue];
    NSString   *strCanceToEndDistance = [dicSetting valueForKey:@"CANCELDISTANCE"];
    float   fNeedMove = [[dicSetting valueForKey:@"INITDISTANCE"] floatValue];
    //Save the INITDISTNACE for the later judge  by Shania 2012/5/28
    [m_dicMemoryValues setObject:[dicSetting valueForKey:@"INITDISTANCE"] forKey:@"INITDISTANCE"];
    ATSDebug(@"INITDISTANCE we need to move the magnet before testing is : %@",[dicSetting valueForKey:@"INITDISTANCE"]);
    
    NSString  *strKeyValue = [dicSetting valueForKey:@"KEY"];
    NSString  *strValue = [m_dicMemoryValues valueForKey:strKeyValue];
    ATSDebug(@"Current magnet postion is %@",strValue);
    float  iawayfromZero = [strValue floatValue]-fNeedMove;
    ATSDebug(@"the distance we need to move : %f",iawayfromZero);
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



//get the distance when hallsensor shows detect or missed
//Param:
//       NSDictionary       *dicSetting   : Settings
//        FIRSTCOMMAND         NSString   : command sensor 0(irq0)
//      FIRSTNEEDSTRING        NSString   : the string you want the FIRSTCOMMAND to return
//        FIRSTSTOREKEY        NSString   : the key you want to memory the first distance
//        SECONDCOMMAND        NSString   : command sensor 1(irq1)
//      SECONDNEEDSTRING       NSString   : the string you want the SECONDCOMMAND to return
//       SECONDSTOREKEY        NSString   : the key you want to memory the second distance
//        THIRDCOMMAND         NSString   : command sensor 2(irq2)
//      THIRDNEEDSTRING        NSString   : the string you want the THIRDCOMMAND to return
//       THIRDSTOREKEY         NSString   : the key you want to memory the third distance
//        TARGETFIXTURE        NSString   : target of fixture
//        TARGETMOBILE         NSString   : target of mobile 
//     TARGETPROXSENSOR        NSString   : target of prox sensor 
//         PROXCOMMAND         NSString   : command send to the prox sensor
//        PROXHASSTRING        NSString   : the string to check the prox sensor return value
//       READPROXDATATIME      NSString   : the time you can repeat read the data when you read prox data fail
//          REMAINTIMES        NSString   : the remain times when you resend the command
//          TRYCOUNT           NSString   : the count you can try to re-send the command
//    CheckMotorStatus     NSDictionary   : the parametric you need when you call function CheckMotorStatus
//           FLCOMMAND         NSString   : the command of fixture
//          INITDISTANCE       NSString   : the fixture init distance
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
-(NSNumber *)FindTheMissOrDetectLocation:(NSDictionary *)dicSetting ReturnValue:(NSMutableString *)strReturn
{
    // get information from plist
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
    NSDictionary  *dicReadMobileinfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"DELETE_ENTER",@":-)",@"END",[NSNumber numberWithDouble:0.1],kFZ_Script_ReceiveInterval,[NSArray arrayWithObjects:@":-)",nil],@"END_SYMBOL",[NSNumber numberWithInt:0],@"MATCHTYPE",strPortMobileType,@"TARGET",[NSNumber numberWithInt:5],@"TIMEOUT",[NSArray arrayWithObjects:@"FAIL",@"not found",@"ERROR", nil],kFZ_Script_ReceiveFail,nil];
    NSDictionary  *dicReadProxSensorinfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"DELETE_ENTER",[NSNumber numberWithInt:0],@"MATCHTYPE",[NSNumber numberWithDouble:0.1],kFZ_Script_ReceiveInterval,strPortProxSensorType,@"TARGET",[NSArray arrayWithObjects:@"Y", nil],@"END_SYMBOL",[NSNumber numberWithInt:1],@"TIMEOUT",nil];
    NSDictionary  *dicProxReadInfo = [NSDictionary dictionaryWithObjectsAndKeys:strProxHasString,@"PROXHASSTRING",nil];
    
    //get the max value that motor can move
    long  lMaxValue = (long)kHallEffect_CaluteDistance_Value *([strInitValue intValue]);
    long  lRemainTimes = strRemainTimes == nil ? 0:[strRemainTimes floatValue];
    long  lOnceDisTance =[[[strFLCommand componentsSeparatedByString:@" "] lastObject] integerValue];
    lOnceDisTance = ABS(lOnceDisTance);
    bool bFirst=YES, bSecond=YES, bThird=YES;
    
    //set the flag which sensor you want to cancel test
    if ([dicSetting objectForKey:@"SkipItem"]&& [dicSetting objectForKey:@"SkipItem"]!= nil)
    {
        NSArray *arrSkipItem = [[dicSetting objectForKey:@"SkipItem"]componentsSeparatedByString:@","];
        if ([arrSkipItem containsObject:@"irq0"]) {
            bFirstNoNeedloop = YES;
            ATSDebug(@"Skip irq0 test!");
        }
       if ([arrSkipItem containsObject:@"irq1"]) 
       {
            bSecondNoNeedLoop = YES;
           ATSDebug(@"Skip irq1 test!");
        }
        if ([arrSkipItem containsObject:@"irq2"])
        {  
            bThirdNoNeedLoop = YES;
            ATSDebug(@"Skip irq2 test!");
        }
    }
    while (tryTimes >= 0 && (lMaxValue +lOnceDisTance> lOnceDisTance *lRemainTimes))  //add +lOnceDisTance to  make motor move more one time on 2012 05 23 by jingfu ran
    {
        int iReadProxDataTimes = iTryReadProxDataTimes;
        if (bFirstNoNeedloop && bSecondNoNeedLoop && bThirdNoNeedLoop) 
        {
            break;
        }
        //For irq0, to find detect or miss position
        if (!bFirstNoNeedloop) 
        {
            
            [self SEND_COMMAND:dicFirstCommandInfo];
            [self READ_COMMAND:dicReadMobileinfo RETURN_VALUE:strReturn];
            if (m_bCancelNoMatterWhat)
            {
                [strReturn setString:@"CancelToEnd"];
                return [NSNumber numberWithBool:NO];
            }
            //if find we need status, read the prox value and 
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
                        if (m_bCancelNoMatterWhat)
                        {
                            [strReturn setString:@"CancelToEnd"];
                            return [NSNumber numberWithBool:NO];
                        }
                        ATSDebug(@"ReadProxData count = %d",iReadProxDataTimes);
						iReadProxDataTimes--;
                        bFirst = [[self GetDistance:dicProxReadInfo ReturnValue:strReturn] boolValue];
                        
                    }while (!bFirst && iReadProxDataTimes >= 0); 
                    ATSDebug(@"irq0 %@ position is %@",strFirstNeedHasString,strReturn);
                    [m_dicMemoryValues setObject:[NSString stringWithString:strReturn] forKey:strFirstStoreInMemoryKey];
                    bFirstNoNeedloop = YES;
                    //end by jingfu ran on 2012 05 08
                    //need 

                //}
            }
            
        }
        //For Irq1, to find irq1 miss or detect position
        if (!bSecondNoNeedLoop) 
        {
            [self SEND_COMMAND:dicSecondCommandInfo];
            [self READ_COMMAND:dicReadMobileinfo RETURN_VALUE:strReturn];
			if (m_bCancelToEnd)
            {
                [strReturn setString:@"CancelToEnd"];
                return [NSNumber numberWithBool:NO];
            }
            if (NSNotFound !=  [strReturn rangeOfString:strSecondNeedHasString].location) 
            {
                //modified by jingfu ran on 2012 05 08 to add retest function if read prox length equal or less than 3
                do 
                {
                    [self SEND_COMMAND:dicProxCommandInfo];
                    usleep(1000);
                    [self READ_COMMAND:dicReadProxSensorinfo RETURN_VALUE:strReturn];
                    if (m_bCancelNoMatterWhat)
                    {
                        [strReturn setString:@"CancelToEnd"];
                        return [NSNumber numberWithBool:NO];
                    }
                    ATSDebug(@"ReadProxData count = %d",iReadProxDataTimes);
					bSecond = [[self GetDistance:dicProxReadInfo ReturnValue:strReturn] boolValue];
					iReadProxDataTimes--;
                   
                }while (!bSecond && iReadProxDataTimes >= 0); 
                ATSDebug(@"irq1 %@ position is %@",strSecondNeedHasString,strReturn);

                [m_dicMemoryValues setObject:[NSString stringWithString:strReturn] forKey:strSecondStorememoryKey];
                bSecondNoNeedLoop = YES;
            }
            
        }
		//For Irq2, to find irq1 miss or detect position
		if (!bThirdNoNeedLoop) 
        {
            [self SEND_COMMAND:dicThirdCommandInfor];
            [self READ_COMMAND:dicReadMobileinfo RETURN_VALUE:strReturn];
			if (m_bCancelNoMatterWhat)
            {
                [strReturn setString:@"CancelToEnd"];
                return [NSNumber numberWithBool:NO];
            }
            if (NSNotFound !=  [strReturn rangeOfString:strThirdNeedHasString].location) 
            {
                    //modified by jingfu ran on 2012 05 08 to add retest function if read prox length equal or less than 3
                do 
                {
                    [self SEND_COMMAND:dicProxCommandInfo];
                    usleep(1000);
                    [self READ_COMMAND:dicReadProxSensorinfo RETURN_VALUE:strReturn];
                    if (m_bCancelNoMatterWhat)
                    {
                        [strReturn setString:@"CancelToEnd"];
                        return [NSNumber numberWithBool:NO];
                    }
                    bThird = [[self GetDistance:dicProxReadInfo ReturnValue:strReturn] boolValue];
                    ATSDebug(@"ReadProxData count = %d",iReadProxDataTimes);
					iReadProxDataTimes--;
                }while (!bThird && iReadProxDataTimes >= 0); 
                ATSDebug(@"irq2 %@ position is %@",strThirdNeedHasString,strReturn);
                [m_dicMemoryValues setObject:[NSString stringWithString:strReturn] forKey:strThirdStoreMemoryKey];
                bThirdNoNeedLoop = YES;
            }
            
        }
		//if any one don't get the status we want, move the motor
        if (!bFirstNoNeedloop || !bSecondNoNeedLoop || !bThirdNoNeedLoop) 
        {
            [self SEND_COMMAND:dicFixtureCommandInfo];
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

//judge the distance you need to move
//Param:
//       NSDictionary       *dicSetting   : Settings
//      Target               NSString     : the location you want to move the magnet
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
- (NSNumber *)JudgeMoveDistance:(NSDictionary *)dicSetting ReturnValue:(NSMutableString *)strReturn
{
    NSString   *strInitValue = [dicSetting valueForKey:@"Target"]?[dicSetting valueForKey:@"Target"]:@"8";
    float lValue = [strReturn floatValue] - [strInitValue floatValue];
    [strReturn setString:[NSString stringWithFormat:@"%0.6f",lValue]];
    ATSDebug(@"The distance you need to move : %f",lValue);
    return  [NSNumber numberWithBool:YES];
}

// check the current distance with target distance, if difference large than spec, Calculate times need to loop to fine tune init position
//Param:
//       NSDictionary       *dicSetting   : Settings
//         SEND_COMMAN     NSDictionary   : command send to the motor
//        READ_COMMAND     NSDictionary   : command read from motor
//     PROXSENDCOMMAND     NSDictionary   : command send to the prox sensor
//      PROXREADCOMMAND    NSDictionary   : command read from prox sensor
//        PROXHASSTRING        NSString   : the string to check the prox sensor return value
//    CheckMotorStatus     NSDictionary   : the parametric you need when you call function CheckMotorStatus
//            TRYTIMES         NSString   : the times you want to adjust the position
//               Step          NSString   : the step you want to move the magnet
//           Distance          NSString   : the step of fixture corresponds to the actual distance
//               StepS         NSString   : the Small step you want to move the magnet
//           DistanceS         NSString   : the StepS of fixture corresponds to the actual distance
//              Limit          NSString   : the limit you want the magnet to loacate
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result

- (NSNumber *)CheckDistance:(NSDictionary *)dicSetting ReturnValue:(NSMutableString *)strReturn
{
    //Get the info from plist
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
    
    //Get Initial Distance from Memory key: INITDISTANCE by Shania 2012/05/28
    NSString    *strInitValue = [m_dicMemoryValues objectForKey:@"INITDISTANCE"]?[m_dicMemoryValues objectForKey:@"INITDISTANCE"]:@"8";
                                
    NSString     *strSpec    = [dicSetting valueForKey:@"Limit"]?[dicSetting valueForKey:@"Limit"]:@"8,8.25";
    NSString     *strLowLimit, *strHighLimit;
    
    //Add limits for initial position  by Shania 2012/5/25
    strLowLimit     = [strSpec SubFrom:@"[" include:NO];
    strLowLimit     = [strLowLimit SubTo:@"," include:NO];
    strHighLimit    = [strSpec SubFrom:@"," include:NO];
    strHighLimit     = [strHighLimit SubTo:@"]" include:NO];
  
    float lValue = 0;
    int iReadProxDataTimes = 3;  //default readProxDataTimes is 3
    
    if (dicSendCommand == nil || dicReceiveCommand == nil)
    {
        ATSDebug(@"check your plist, there is no SEND_COMMAND or READ_COMMAND");
        return [NSNumber numberWithBool:NO];
    }
    NSMutableString   *strReturnValue = [[NSMutableString alloc] initWithString:strReturn];
    int tryTime = [strRetryTimes intValue];

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
        if(ABS(lValue)>1)
        {
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
        
        //Loop iMoveTimes to move fixture
        for (int i = 0; i < iMoveTimes; i++)
        {
            ATSDebug(@"Move #%d, step: %@ Command: %@", i,numStep, dicSendCommand);
            [self SEND_COMMAND:dicSendCommand];
            //usleep(300000);
        }
        //check the motor status and read the magnet position from fixture
        if ([[self CheckMotorStatus:dicCheckMotorStatus ReturnValue:strReturn]boolValue]) 
        {   
           // usleep(300000);
            do 
            {
                [self SEND_COMMAND:dicProxSendCommand];
                usleep(1000);
                [self READ_COMMAND:dicProxReadCommand RETURN_VALUE:strReturnValue];
                if (m_bCancelNoMatterWhat)
                {
                    [strReturn setString:@"CancelToEnd"];
                    [strReturn release];
                    return [NSNumber numberWithBool:NO];
                }
                iReadProxDataTimes--;
            
            }while((![[self GetDistance:dicSetting ReturnValue:strReturnValue] boolValue]) && iReadProxDataTimes >= 0);
        }
        else
        {
            if (m_bCancelNoMatterWhat) {
                break;
            }
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

// check current motor status. if current motor status is SR=R, it means the magnet moves finished and can read the distance now
//Param:
//       NSDictionary       *dicSetting   : Settings
//       SEND_COMMAN     NSDictionary     : command send to fixture
//      READ_COMMAND     NSDictionary     : command read from fixture
//      RepeatTime           NSString     : the repeat time you can send the command
//      ExpectReceive        NSString     : the value you want to get from fixture
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
- (NSNumber *)CheckMotorStatus:(NSDictionary *)dicSetting ReturnValue:(NSMutableString *)strReturn
{
    NSDictionary *dicSendCommand = [dicSetting objectForKey:@"SEND_COMMAND"];
    NSDictionary *dicReceiveCommand = [dicSetting objectForKey:@"READ_COMMAND"];
    int tryCount = [dicSetting objectForKey:@"RepeatTime"]?[[dicSetting objectForKey:@"RepeatTime"]intValue]:5;
    NSString *strPassReceive = [dicSetting objectForKey:@"ExpectReceive"]?[dicSetting objectForKey:@"ExpectReceive"]:@"SR=R";
    ATSDebug(@"The count we need to try is %d, and the return value we expected is:%@",tryCount,strPassReceive);
    do 
    {
        [self SEND_COMMAND:dicSendCommand];
        usleep(1000);
        [self READ_COMMAND:dicReceiveCommand RETURN_VALUE:strReturn];
        if (m_bCancelNoMatterWhat)
        {
            [strReturn setString:@"CancelToEnd"];
            return [NSNumber numberWithBool:NO];
        }
        ATSDebug(@"the %d receive command of SR is %@",tryCount,strReturn);
        if(NSNotFound != [strReturn rangeOfString:strPassReceive].location)
        {
            break;
        }
        tryCount --;
    }while (tryCount > 0);   
    if (tryCount < 0)
    {
        ATSDebug(@"the motor status is not ready");
        return [NSNumber numberWithBool:NO];
    }
    return [NSNumber numberWithBool:YES];
}

// get the fixture sn from seial-number ex:/dev/cu.usbserial-mh1-2038  so the fixture sn is 2038
//Param:
//       NSDictionary       *dicSetting   : Settings
//           TARGET         NSString     : the fixture target
//      ISNUMBERINDEX       NSNumber     : you want the fixtureSN is number or not
//      SeperateChar        NSString     : the seperateChar you want to seperate the fixture serial-number,ex"-"
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result

-(NSNumber *)READ_FIXTURESN:(NSDictionary *)dicSetting ReturnValue:(NSMutableString *)strReturn
{
    
    NSString   *szPortType = [dicSetting valueForKey:kFZ_Script_DeviceTarget];
    id         idWantToNumberIndex = [dicSetting valueForKey:@"ISNUMBERINDEX"];
    NSString   *strChar = [dicSetting valueForKey:@"SeperateChar"];
    NSString   *strPath = [[m_dicPorts valueForKey:szPortType] objectAtIndex:kFZ_SerialInfo_SerialPort];
    NSString   *strFixtureSN = @"";
    ATSDebug(@"the %@ path is %@",szPortType,strPath);
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
    }
    else
    {
		//modified by jingfu ran for avoiding memory leak on 2012 05 02
		strFixtureSN = [NSString  stringWithString:strFixtureSN];
    }
    ATSDebug(@"The fixture SN is %@",strFixtureSN);
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

//Judge the prox sensor data whether contain some string
//Param:
//       NSDictionary       *dicSetting   : Settings
//      PROXHASSTRING     NSString     : the string you want to judge the prox sensor return value 
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
-(NSNumber *)JudgeProxSensorData:(NSDictionary*)dicSetting return_Value:(NSMutableString *)strReturn
{
    if ([strReturn length] <= 3) 
    {  
        return [NSNumber numberWithBool:NO];  
    }
    NSString   *strHasString = [dicSetting valueForKey:@"PROXHASSTRING"] == nil?@"0x81 0x6 0x59":[dicSetting valueForKey:@"PROXHASSTRING"];
    NSMutableString  *strValue = [[NSMutableString alloc] initWithString:@""];
    
    // re format the prox return value
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

    }else
    {
        ATSDebug(@"the prox data :%@ don't contain :%@",strValue,strHasString);
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

//move the motor to the top position
//Param:
//       NSDictionary       *dicSetting   : Settings
//      FIXTURETARGET     NSString     : the fixture target
//      PROXSENSORTARGET  NSString     : the proxsensor target
//      COMMAND           NSString     : fixture command
//      PROXHASSTRING     NSString     : the string you want to judge the prox sensor return value 
//      MAXTIMES          NSString     : the max time you want to try 
//      PROXCOMMAND             id     : prox command
//      CALVALUE          NSString     : the value you want to calculate prox distance
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
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
   
    float a[3] = {0};  // to memory the last three times position
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
            ATSDebug(@"a[0]:%.6f a[1]: %.6f a[2]:%f",a[0],a[1],a[2]);
            return [NSNumber numberWithBool:NO];
        }
        iMaxTimes--;
        [self SEND_COMMAND:dicFixtureCommandInfo];
        [self SEND_COMMAND:dicProxCommandInfo];
        [self READ_COMMAND:dicReadProxSensorinfo RETURN_VALUE:strResponse];
        //judge the proxSensorData
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
            //if the three times difference less than 0.03, break the loop
            if (([self absFloat:a[1] - a[0]] < 0.03) && ([self absFloat:(a[2]-a[1])] < 0.03)) 
            {
                 break;
            } else
            {
                continue;
            }
        }
        ATSDebug(@"a[0]:%.6f a[1]: %.6f a[2]:%f",a[0],a[1],a[2]);
    }
    [strResponse release];
    [strReturn setString:[NSString  stringWithFormat:@"a[0]:%.6f a[1]: %.6f a[2]:%f",a[0],a[1],a[2]]];
    return [NSNumber numberWithBool:YES];
}

//Move the fixture magnet to the top
//Param:
//       NSDictionary       *dicSetting   : Settings
//      1.SEND_COMMAND:     NSDictionary     : the command you want to send to fixture to move motor
//      2.READ_COMMAND:RETURN_VALUE:  NSDictionary     : the command you want to read to fixture to move motor
//      3.CheckMotorStatus:ReturnValue:  NSDictionary     : check the motor status
//      4.SEND_COMMAND:     NSDictionary     : the command you want to send to prox to 
//      5.READ_COMMAND:RETURN_VALUE:  NSDictionary     : read the prox data
//      6.GetDistance:ReturnValue:  NSDictionary     : get the distance through prox data
//      TIME_OUT   NSString  : the time out of this item
//      ABS_SPEC    NSString : the value you want the continues two value difference less than the spec
//      PROXHASSTRING  NSString : the data you want check with prox return value
//      Init      Boolean   :  is the Fixture Init or Not
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
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
            ATSDebug(@"the first value : %@, PreLast value : %@, Last value: %@, current value: %@",szFirstValue,szPreLastValue,szLastValue,szCurrentValue);
            fPreLastDistance = [szPreLastValue floatValue] - [szFirstValue floatValue];
            fLastDistance = [szLastValue floatValue] - [szPreLastValue floatValue];
            fCurrentDistance = [szCurrentValue floatValue] - [szLastValue floatValue];
            // judge if the difference between last three times is less than spec, break the loop
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
        ATSDebug(@"Move_Top fail. Time out");
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
        NSInteger iCount = [arrTemp count];
        
        if ([[arrTemp objectAtIndex:0] hasSuffix:@":"] && [[arrTemp objectAtIndex:0] hasPrefix:@"0"]) 
        {
            if (iCount < iStep+1)
            {
                ATSDebug(@"CatchWIFISN =>Number %i row count is not right!",i);
                [arrValue release];
                [strValue release];
                return [NSNumber numberWithBool:NO];
            }
            for (int j = 1; j < iStep +1; j++) 
            {
                [arrValue addObject:[arrTemp objectAtIndex:j]];
            }
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
	/* Approve by coco Kevin Yang.
	 * Modify by Lucky at 2013/09/17.
	 * Judge the value at "FF+2 byte" is >=09, to check that there isn’t more data in contained tuples than the offset states.
	 */
	if (!(iLength >= 9))
	{
        [szReturnValue setString:@"Length of the Tuple is error!"];
        [arrValue release];
        [strValue release];
        return [NSNumber numberWithBool:NO];
    }
    
    iLocation = iLocation + 4;
    
    NSString *szWIFISNLength = [arrValue objectAtIndex:iLocation];
    unsigned int iWIFISNLength = 0;
    scan = [NSScanner scannerWithString:szWIFISNLength];
    [scan scanHexInt:&iWIFISNLength];
    
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
//check current script;  added by Lucky.2012/11/20
-(NSNumber*)CHECKSCRIPT:(NSDictionary *)dicItemInfo RETURN_VALUE:(NSMutableString *)strReturnValue
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
                
           //     [[NSNotificationCenter defaultCenter] postNotificationName:BNRTestProgressPopWindow object:nil];
                
                NSRunAlertPanel(@"警告(Warning)", @"请选择正确的剧本档!（Please choose the correct script!）", @"确认(OK)", nil, nil);
                
          //      [[NSNotificationCenter defaultCenter] postNotificationName:BNRTestProgressQuitWindow object:nil];
				
				
				[NSApp terminate:nil];
				return [NSNumber numberWithBool:NO];
			}
		}
	}
	return [NSNumber numberWithBool:YES];
}
//catch string
-(NSNumber*)CatchString:(NSDictionary *)dicPara RETURN_VALUE:(NSMutableString *)strReturnValue
{
    NSString * strkey     = [dicPara objectForKey:@"key"];
    NSString * strSaveKey = [dicPara objectForKey:@"SAVEKEY"];
    NSUInteger iFrom      = [[dicPara objectForKey:@"FROM"] intValue];
    NSUInteger iLength    = [[dicPara objectForKey:@"LENGTH"] intValue];
    BOOL     bDeleteSpace = [[dicPara objectForKey:@"DELETE"] boolValue];
    
    NSString * szKeyValue;
    [self TransformKeyToValue:strkey returnValue:&szKeyValue];
    
    //delete space
    if(bDeleteSpace)
    {
        szKeyValue = [szKeyValue stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    
    [strReturnValue setString:@""];
    if(szKeyValue)
    {
        if((iLength + iFrom) <=[szKeyValue length])
        {
            NSString * strCatchValue = [self catchFromString:szKeyValue location:iFrom length:iLength];
            [m_dicMemoryValues setObject:strCatchValue forKey:strSaveKey];
            [strReturnValue setString:strCatchValue];
            return [NSNumber numberWithBool:YES];
        }
        else
        {
            [strReturnValue setString:@"Catch string fail"];
            return [NSNumber numberWithBool:NO];
        }
    }
    else
    {
        return [NSNumber numberWithBool:NO];
    }
}
//check RSKU fromat
-(NSNumber*)CheckRSKUFromat:(NSDictionary*)dicPara RETURN_VALUE:(NSMutableString *)strReturnValue
{
    NSString    *   szRSKU = [m_dicMemoryValues objectForKey:@"RSKU"];
    //remove space and newline
    szRSKU = [szRSKU stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray * aryRSKU = [szRSKU componentsSeparatedByString:@" "];
    [strReturnValue setString:[NSString stringWithFormat:@"%@",szRSKU]];
    if(3 == [aryRSKU count] && [szRSKU isNotEqualTo:@""] && [szRSKU isNotEqualTo:@"null"])
    {
        for (NSString * szBlock in aryRSKU)
        {
            if([szBlock ContainString:@"0x"])
            {
                if(10 != [szBlock length])
                {
                    [strReturnValue setString:@"RSKU fomat error : length less than 10"];
                    ATSDBgLog(@"RSKU fomat error : length less than 10");
                    return [NSNumber numberWithBool:NO];
                }
            }
            else
            {
                [strReturnValue setString:@"RSKU fomat error : prefix is not 0x"];
                ATSDBgLog(@"RSKU format error : prefix is not 0x");
                return [NSNumber numberWithBool:NO];
            }
        }
        
        return [NSNumber numberWithBool:YES];
    }
    else
    {
        [strReturnValue setString:@"RSKU fomat error : RSKU value is null"];
        ATSDBgLog(@"RSKU format error : RSKU value is null");
        return [NSNumber numberWithBool:NO];
    }
}
//super string whether contain sub string
-(NSNumber*)ContainString:(NSDictionary *)dicPara RETURN_VALUE:(NSMutableString *)strReturnValu
{
    NSString    *   szSuperkey = [dicPara objectForKey:@"super"];
    NSString    *   szSubkey   = [dicPara objectForKey:@"sub"];
    NSString    *   szSuper;
    NSString    *   szSub;
    
    [self TransformKeyToValue:szSuperkey returnValue:&szSuper];
    [self TransformKeyToValue:szSubkey returnValue:&szSub];
    
    [strReturnValu setString:@""];
    
    if([szSuper ContainString:szSub])
    {
        [strReturnValu setString:[NSString stringWithFormat:@"%@",szSuper]];
        ATSDebug(@"ContainString:%@",strReturnValu);
        return [NSNumber numberWithBool:YES];
    }
    else
    {
        [strReturnValu setString:[NSString stringWithFormat:@"%@ don't contain %@",szSuper,szSub]];
        ATSDebug(@"ContainString:%@",strReturnValu);
        return [NSNumber numberWithBool:NO];
    }
}
//compare value after transfrom in table
-(NSNumber*)CompareTransFeromInTable:(NSDictionary*)dicPara RETURN_VALUE:(NSMutableString *)strReturnValu
{    
    NSDictionary  *   dicTable        = [dicPara objectForKey:@"table"];
    NSString      *   szKey           = [dicPara objectForKey:@"key"];
    NSString      *   szTransformKey  = [dicPara objectForKey:@"transforkey"];
    NSString      *   szKeyValue;
    NSString      *   szTransKeyValue;
    [self TransformKeyToValue:szKey returnValue:&szKeyValue];
    [self TransformKeyToValue:szTransformKey returnValue:&szTransKeyValue];
    
    id idTransformValue = [dicTable objectForKey:szTransKeyValue];
    
    [strReturnValu setString:[NSString stringWithFormat:@"tranksKeyValue=%@,keyValue=%@",szTransKeyValue,szKeyValue]];

    if([idTransformValue isKindOfClass:[NSString class]])
    {
        if([szKeyValue isEqualToString:idTransformValue])
        {
            return [NSNumber numberWithBool:YES];
        }
        else
        {
            return [NSNumber numberWithBool:NO];
        }
    }
    
    if([idTransformValue isKindOfClass:[NSNumber class]])
    {
        if([szKeyValue isEqualToString:[NSString stringWithFormat:@"%@",idTransformValue]])
        {
            return [NSNumber numberWithBool:YES];
        }
        else
        {
            return [NSNumber numberWithBool:NO];
        }
    }
    
    return [NSNumber numberWithBool:NO];
}
-(NSNumber*)CombineStringBySpecialString:(NSDictionary*)dicPara RETURN_VALUE:(NSMutableString *)strReturnValue
{
    NSDictionary * dicCombineString = [dicPara objectForKey:@"Combine"];
    NSString     * szSpecial        = [dicPara objectForKey:@"Special"];
    [strReturnValue setString:@""];

    NSArray * aryCombine = [dicCombineString allValues];
    for (id  idCombine in aryCombine)
    {
        if([idCombine isKindOfClass:[NSString class]])
        {
            //trans
            [self TransformKeyToValue:idCombine returnValue:&idCombine];
            
            if([strReturnValue isEqualToString:@""])
            {
                //first string
                [strReturnValue setString:idCombine];
            }
            else
            {
                [strReturnValue setString:[NSString stringWithFormat:@"%@%@%@",strReturnValue,szSpecial,idCombine]];
            }
            
        }
        else
        {
            [strReturnValue setString:@"combine string error"];
            return [NSNumber numberWithBool:NO];
        }
    }
    
    return [NSNumber numberWithBool:YES];
}


//catch string from strReturnValue in CHANGE_MODE_TO_GRAPECAL item.
-(NSNumber *)RemoveLastContent:(NSDictionary *)dicPara RETURN_VALUE:(NSMutableString*)strReturnValue
{
    NSString *strKey=[dicPara objectForKey:@"KEY"];
    NSString *strContent=[m_dicMemoryValues valueForKey:strKey];
    NSArray *aryTemp=[strContent componentsSeparatedByString:@" "];
    NSMutableArray *aryMulTemp=[[NSMutableArray alloc] init ];
    for (NSString *szTemp in aryTemp) {
        if ([szTemp ContainString:@"="]) {
            [aryMulTemp addObject:szTemp];
        };
    }
    NSString *strTemp=[NSString pathWithComponents:aryMulTemp];
    [strReturnValue setString:[strTemp stringByReplacingOccurrencesOfString:@"/" withString:@" "]];
    [aryMulTemp release];
    return [NSNumber numberWithBool:YES];
    
}

//setting printer command
//Param:
//       NSDictionary    *dicContents   : Settings
//         SettingFileName  NSString*   : the print setting file name
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result

- (BOOL)Setting_Printer:(NSDictionary *)dicContents withPrintLabel:(NSDictionary *)dicPrinter
{
    BOOL bRet = YES;
    NSString *strTextContent = @"";
    NSString *strPrefix = [dicPrinter objectForKey:kPRINT_PREFIX];
    NSString *strSuffix = [dicPrinter objectForKey:kPRINT_SUFFIX];
    int iType = [[dicPrinter objectForKey:kPRINT_TYPE]intValue];
    BOOL bPrintBarSuf = [[dicPrinter objectForKey:kIF_PRINTBar_PRE_SUF]boolValue];
    NSString *strPrintLabel = [dicPrinter objectForKey:kPRINT_KEY];
   
    bRet  = [self TransformKeyToValue:strPrintLabel returnValue:&strPrintLabel];
     strTextContent = [NSString stringWithFormat:@"%@",strPrintLabel];
    if (!bRet)
        return bRet;
    
    if ([dicPrinter objectForKey:kPrintCmd_2DBarcode])
    {
        //Set barcode location
        NSDictionary *dic2DBcInfo = [dicContents objectForKey:kPrintCmd_2DBarcode];
        NSDictionary *dicLocation = [dic2DBcInfo objectForKey:kPrintCmd_Location];
        NSString *sz2DBcLocationX = [dicLocation objectForKey:kPrintCmd_LocationX];
        NSString *sz2DBcLocationY = [dicLocation objectForKey:kPrintCmd_LocationY];
        bRet &= [m_objPrint SetFieldLocationX:sz2DBcLocationX FiledLocationY:sz2DBcLocationY BarcodeOrText:1];
        //set 2DBarcode command
        NSDictionary *dic2DCommand = [dic2DBcInfo objectForKey:kPrintCmd_Command];
        NSString *strEncoding = [dic2DCommand objectForKey:kPrintCmd_Encoding];
        NSString *strDirection = [dic2DCommand objectForKey:kPrintCmd_Direction];
        NSString *strLayer = [dic2DCommand objectForKey:kPrintCmd_Layer];
        NSString *strHeight = [dic2DCommand objectForKey:kPrintCmd_Height];
        
        bRet &= [m_objPrint Set2DBarcodeCommand:strEncoding Direction:strDirection Layer:strLayer Hight:strHeight];
    }
    else
    {
        if ([[dicContents allKeys]containsObject:kPrintCmd_Barcode]) 
        {
            //Barcode location setting
            NSDictionary *dicBarcode        = [dicContents objectForKey:kPrintCmd_Barcode];
            if ([[dicBarcode allKeys]containsObject:kPrintCmd_Location]) 
            {
                NSDictionary *dicBcLocation     = [dicBarcode objectForKey:kPrintCmd_Location];
                NSString *szBcLoctionX          = [dicBcLocation objectForKey:kPrintCmd_LocationX];
                NSString *szBcLoctionY          = [dicBcLocation objectForKey:kPrintCmd_LocationY];
                
                bRet &= [m_objPrint SetFieldLocationX:szBcLoctionX FiledLocationY:szBcLoctionY BarcodeOrText:1];
            }
            
            if ([[dicBarcode allKeys]containsObject:kPrintCmd_Field]) 
            {
                //Barcode field setting
                NSDictionary *dicBcField        = [dicBarcode objectForKey:kPrintCmd_Field];
                NSString *szBcLinePoints        = [dicBcField objectForKey:kPrintCmd_LinePoints];
                NSString *szBcWidthRadio        = [dicBcField objectForKey:kPrintCmd_WidthRadio];
                NSString *szBcHeight            = [dicBcField objectForKey:kPrintCmd_Height];
                
                bRet &= [m_objPrint SetBarcodeNarrowLineLength:szBcLinePoints WidthHeightRadio:szBcWidthRadio BarcodeHeight:szBcHeight];
            }
           
        }
        
        if ([[dicContents allKeys]containsObject:kPrintCmd_Text]) 
        {
            NSDictionary *dicText           = [dicContents objectForKey:kPrintCmd_Text];
            //set text filed location
            if ([[dicText allKeys]containsObject:kPrintCmd_Location])
            {
                NSDictionary *dicTxtLocation    = [dicText objectForKey:kPrintCmd_Location];
                NSString *szTxtLoctionX         = [dicTxtLocation objectForKey:kPrintCmd_LocationX];
                NSString *szTxtLoctionY         = [dicTxtLocation objectForKey:kPrintCmd_LocationY];
                bRet &= [m_objPrint SetFieldLocationX:szTxtLoctionX FiledLocationY:szTxtLoctionY BarcodeOrText:2];
            }
            // set text field font and size
            if ([[dicText allKeys]containsObject:kPrintCmd_Printer])
            {
                NSDictionary *dicTxtPrinter     = [dicText objectForKey:kPrintCmd_Printer];
                NSString *szTxtFont             = [dicTxtPrinter objectForKey:kPrintCmd_Font];
                NSString *szTxtHeight           = [dicTxtPrinter objectForKey:kPrintCmd_Height];
                NSString *szTxtWidth            = [dicTxtPrinter objectForKey:kPrintCmd_Width];
                
                bRet &= [m_objPrint SetTextFont:szTxtFont TextAngle:@"" TextHeight:szTxtHeight TextWidth:szTxtWidth];
            }
 
        }
    }
    
    if (strPrefix)
    {
        strTextContent = [NSString stringWithFormat:@"%@%@",strPrefix,strTextContent];
    }
    if (strSuffix) {
        strTextContent = [NSString stringWithFormat:@"%@%@",strTextContent,strSuffix];
    }
    // combine all the command list
    if (bPrintBarSuf)
    {
        bRet &= [m_objPrint CombineCmdBarContent:strTextContent TextContent:strTextContent PrintType:iType];
    }
    else
    {
        bRet &= [m_objPrint CombineCmdBarContent:strPrintLabel TextContent:strTextContent PrintType:iType];
    }
    return bRet;
    
}

//print the label
//Param:
//       NSDictionary    *dicContents   : Settings
//                  Label   NSArray *   : the array of label you want to print
//                      NSDictionary*   :
//                          PREFIX  NSString*   : the prefix you want add before content
//                          SUFFIX  NSString*   : the suffix you want add after content
//                          PRINTER_KEY  NSString*   : the key you want to print
//                          PRINTER_TYPE  NSString*   : print type  0 -> print barcode and text; 1-> only print barcode;  2-> only print text
//                           PRINTER_PRE_SUF  boolean     : YES -> barcode with prefix and suffix, NO -> barcode only print content
//      NSString *      SettingFileName: printer setting file name
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
- (NSNumber *)Print_Label:(NSDictionary *)dicContents RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSArray *aryLabels = [dicContents objectForKey:@"Label"];
    
    NSString *strFileName = [dicContents objectForKey:@"SettingFileName"];
    NSString *strSettingPath = [NSString stringWithFormat:@"%@/Library/Preferences/%@.plist", NSHomeDirectory(),strFileName];
    NSFileManager *FileManage = [NSFileManager defaultManager];
    if ([FileManage fileExistsAtPath:strSettingPath] != YES)
    {
        NSString *strMsg = [NSString stringWithFormat:@"The file of Setting print is not exit, please do print setting first!"];
        NSRunAlertPanel(@"Warning", strMsg, @"OK",nil, nil);
        return [NSNumber numberWithBool:NO];
    }
    NSDictionary *dicSettingFile = [NSDictionary dictionaryWithContentsOfFile:strSettingPath];
    
    NSArray *aryGroups = [dicSettingFile objectForKey:kPRINT_Groups];
    
    NSString *strDarkness = [dicSettingFile objectForKey:kPrintCmd_Darkness];
    NSString *strPrintCount = [dicSettingFile objectForKey:kPrintCmd_Count];
    
    [m_objPrint SetPreContents];
    [m_objPrint SetDarkness:strDarkness];
    
    if ([aryLabels count] > [aryGroups count])
    {
        NSRunAlertPanel(@"Warning", @"Please check the PrintSetting.plist", @"OK", nil, nil);
        return NO;
    }
    BOOL bRet = YES;
    for(int i = 0; i < [aryLabels count]; i++)
    {
        NSDictionary *dicInfo = [aryLabels objectAtIndex:i];
        NSDictionary *dicSettingInfo = [aryGroups objectAtIndex:i];
        bRet &= [self Setting_Printer:dicSettingInfo withPrintLabel:dicInfo];
    }
    if (!bRet)
    {
        return [NSNumber numberWithBool:bRet];
    }
    [m_objPrint SetPrinterCount:strPrintCount PauseTimes:nil NumRepeatTimes:nil ContinusPrint:NO];
    [m_objPrint SetEndContents];
    int iRet = [m_objPrint Print];
    
    if (iRet < 0)
    {
        return [NSNumber numberWithBool:NO];
    }
    return [NSNumber numberWithBool:YES];
    
}


//Change the title show on the muifa window
//Param:
//       NSDictionary    *dicContents   : Settings
//                  KEY  NSString*   : the title you want to show on UI
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
- (NSNumber *)ChangeUITile:(NSDictionary *)dicContents RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSString *strTitle = [dicContents objectForKey:@"Title"];
    if (strTitle && [strTitle isNotEqualTo:@""]) 
    {
        NSDictionary *dicMsg = [NSDictionary dictionaryWithObject:strTitle forKey:@"Title"];
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:BNRMonitorWindowTitleChangeNotification object:self userInfo:dicMsg];
        ATSDebug(@"change the window title to %@", strTitle);
        return [NSNumber numberWithBool:YES];
    }
    return [NSNumber numberWithBool:YES];
}

//Read the data from OS mode
//Param:
//       NSDictionary    *dicContents   : Settings
//                  KEY  NSString*   : the key you want to memory your value
//              Command  NSString*   : command on OS mode for reading information
//                 Path  NSString*   : the mobdev path    
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
- (NSNumber *)OS_MODE_READ:(NSDictionary *)dicOsSetting RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSLog(@"--------START OS MODE -------");
    BOOL iRet = YES;
    NSMutableString *strValue = [[NSMutableString alloc]init];
    // get the command and path
    NSString *strPath = [dicOsSetting objectForKey:@"Path"];
    NSString *strOsCommand = [dicOsSetting valueForKey:@"Command"];
    int itimeout = [[dicOsSetting objectForKey:kFZ_Script_ReceiveTimeOut]intValue]?[[dicOsSetting objectForKey:kFZ_Script_ReceiveTimeOut]intValue]:5;
    NSArray * aryArgument = [NSArray arrayWithObjects:@"get",@"NULL",strOsCommand, nil];
    
    iRet = [self CallTask:strPath Parameter:aryArgument EndString:nil TimeOut:[NSNumber numberWithInt:itimeout] ReturnValue:strValue];
    
    if(!iRet)
    {
        [szReturnValue setString:strValue];
        [strValue release];
        return [NSNumber numberWithBool:iRet];
    }
    
    if ([strValue isEqualToString:@""])
    {
        iRet = NO;
    }
    else if([strValue ContainString:@"Could not lookup value"])
    {
        iRet = NO;
        ATSDebug(@"could not get the value");
        [szReturnValue setString:@"could not get the value"];
    }
    else
    {
        [szReturnValue setString:strValue];
        ATSDebug(@"the value read from os is %@",strValue);
        [m_dicMemoryValues setObject:strValue forKey:kFZ_MemKey_ForMobileCatch];
    }
    [strValue release];
    return [NSNumber numberWithBool:iRet];
}

-(NSNumber *)JUDGE_PROX_VALUE:(NSDictionary *)dicSetting RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSString * szSpec = [dicSetting objectForKey:@"SPEC"];
    NSString * szKey  = [dicSetting objectForKey:@"KEY"];
    BOOL       bolUp  = [[dicSetting objectForKey:@"UP"] boolValue];
    int iCount = [[dicSetting objectForKey:@"COUNT"] intValue];
    
    int iNumber = 0;
    [szReturnValue setString:@""];
    NSArray * aryKey = [szKey componentsSeparatedByString:@","];
    for (NSString * szKey in aryKey)
    {
        NSString * szKeyValue = [m_dicMemoryValues objectForKey:szKey];
        if([self JudgeSpec:szSpec return_value:szKeyValue caseInsensitive:NO])
        {
            iNumber++;
        }
    }
    
    [szReturnValue setString:[NSString stringWithFormat:@"%d value in spec%@",iNumber,szSpec]];
    
    if(iNumber >iCount)
    {
        if(bolUp)
        {
            return [NSNumber numberWithBool:YES];
        }
        else
        {
            return [NSNumber numberWithBool:NO];
        }
        
    }
    else
    {
        if(bolUp)
        {
            return [NSNumber numberWithBool:NO];
        }
        else
        {
            return [NSNumber numberWithBool:YES];
        }

    }
    
    
    
}

- (NSNumber *)READ_VENDOR:(NSDictionary *)dicPara RETURNVALUE:(NSMutableString *)retValue
{
	NSString * strVendor = nil;
	if ([retValue length] > 3)
	{
		NSString * headOfSerialNumber = [retValue substringToIndex:3];
		strVendor = [dicPara objectForKey:headOfSerialNumber];
	}
	strVendor = (strVendor == nil) ? @"Unknow Vendor" : strVendor;
	[retValue setString:strVendor];
	return [NSNumber numberWithBool:![strVendor isEqualToString:@"Unknow Vendor"]];
}

- (NSNumber *)READ_LED_VENDOR:(NSDictionary *)dicPara RETURNVALUE:(NSMutableString *)retValue
{
    NSString *szLedVendorSymbol = nil;
    NSString *szLedVendor = nil;
    if ([retValue length] == 4) {
        szLedVendorSymbol = [retValue substringToIndex:1];
    }
    for (NSString *szKey in [dicPara allKeys]) {
        NSArray *arrVendorInfo = [dicPara objectForKey:szKey];
        if ([arrVendorInfo containsObject:szLedVendorSymbol]) {
            szLedVendor = [NSString stringWithFormat:@"%@",szKey];
            break;
        }
    }
    szLedVendor = (szLedVendor == nil) ? @"UnKnow Vendor" : szLedVendor;
    [retValue setString:szLedVendor];
    return [NSNumber numberWithBool:![szLedVendor isEqualToString:@"UnKnow Vendor"]];
}

- (NSNumber *)GET_LED_BRT:(NSDictionary *)dicPara RETURNVALUE:(NSMutableString *)retValue
{
    NSString *szBrightNessSymbol = nil;
    NSString *szBrightNess = nil;
    if ([retValue length] == 4) {
        szBrightNessSymbol = [retValue substringFromIndex:1];
        szBrightNessSymbol = [szBrightNessSymbol substringToIndex:1];
    }
    NSString * szLedVendor = [m_dicMemoryValues objectForKey:@"LED VENDOR"];
    NSDictionary *dicLedBrightNess = [dicPara objectForKey:szLedVendor];
    if (dicLedBrightNess) {
        szBrightNess = [dicLedBrightNess objectForKey:szBrightNessSymbol];
    }
    szBrightNess = (szBrightNess == nil) ? @"Error Brightness" : szBrightNess;
    [retValue setString:szBrightNess];
    return [NSNumber numberWithBool:![szBrightNess isEqualToString:@"Error Brightness"]];
}

- (NSNumber *)GET_LED_COLOR:(NSDictionary *)dicPara RETURNVALUE:(NSMutableString *)retValue
{
    NSString *szColor = nil;
    NSString *szColorSymbol1 = nil;
    NSString *szColorSymbol2 = nil;
    if ([retValue length] == 4) {
        szColorSymbol1 = [retValue substringFromIndex:2];
        szColorSymbol1 = [szColorSymbol1 substringToIndex:1];
        szColorSymbol2 = [retValue substringFromIndex:3];
    }
    NSString *szLedVendor = [m_dicMemoryValues objectForKey:@"LED VENDOR"];
    NSDictionary *dicLedColor = [dicPara objectForKey:szLedVendor];
    if (dicLedColor) {
        if ([szColorSymbol1 isEqualToString:szColorSymbol2]) {
            szColor = [dicLedColor objectForKey:szColorSymbol1];
        }
        else
        {
            NSString *szColor1 = [dicLedColor objectForKey:szColorSymbol1];
            NSString *szColor2 = [dicLedColor objectForKey:szColorSymbol2];
            szColor1 = (szColor1 == nil) ? @"Error" : szColor1;
            szColor2 = (szColor2 == nil) ? @"Error" : szColor2;
            szColor = [NSString stringWithFormat:@"%@+%@",szColor1,szColor2];
        }
    }
    
    if (szColor == nil) {
        szColor = [NSString stringWithFormat:@"Error Color"];
    }
    [retValue setString:szColor];
    if ([szColor rangeOfString:@"Error"].location != NSNotFound) {
        return [NSNumber numberWithBool:NO];
    }
    else{
        return [NSNumber numberWithBool:YES];
    }
}



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
    if ([strResponse  ContainString:@"RX ["]
        || [strResponse ContainString:@"Empty response"]
        || [strResponse ContainString:@"Incomplete response"])
    {
        return kUnknownMode;
    }
    if ([strResponse ContainString:@"iPad:~ root#"])
        testMode    = kLogonOSMode;
    else if ([strResponse ContainString:@"login:"])
        testMode    = kNonLoginOSMode;
    else if ([strResponse ContainString:@"]"]&&[strResponse length]<100)
		testMode    = kRecoverMode;
    else if ([strResponse ContainString:@":-)"])
		testMode    = kDiagsMode;
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
			case kUnknownMode: // Unknown mode, only sleep 5 minutes to bringup the DUT
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
        [m_dicEmptyResponse setObject:[NSNumber numberWithInt:0] forKey:@"MOBILE"];
        bRet	= [[self READ_COMMAND:dicReveiveCommand
					  RETURN_VALUE:szReturnValue] boolValue];
		return bRet;
	}
	return NO;	
}

//add by betty, 2013/09/24 For Gatekeeper, if the result is fail, no need to disconnect battery and check unit shutdown
//Check the above items test result
//Param:
//       NSDictionary    *dicContents   : Settings
//              FailCancel  boolean     : YES  ==> If test result Fail, change the cancelFlag to YES
//                                        NO  ==> If test result Pass, change the cancelFlag to YES
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
-(NSNumber *)CheckTestResultCancel:(NSDictionary *)dicSub
				RETURN_VALUE:(NSMutableString *)szReturnValue
{
    //FailCancel  ==> YES, If test result Fail, change the cancelFlag to YES
    BOOL bFailCancel = [[dicSub objectForKey:@"FailCancel"]boolValue];
    if (m_bFinalResult ^ bFailCancel) 
    {
        //(m_bFinalResult= YES && bFailCancel = NO) or (m_bFinalResult= NO && bFailCancel = YES) will enter here
        m_bCancelFlag = YES;
    }
    else
    {
        m_bCancelFlag = NO;
    }
    return [NSNumber numberWithBool:YES];
}
// auto test system (Change sub item result)
- (NSNumber *)CHANGE_PRE_SUBITEM_RESULT:(NSDictionary *)dicPara
						   RETURN_VALUE:(NSMutableString *)szReturnValue
{
	m_bSubTest_PASS_FAIL = [[dicPara objectForKey:@"RESULT"] boolValue];
	ATSDebug(@"PRE SUB ITEM HAS CHANGED to [%@]",[dicPara objectForKey:@"RESULT"]);
	return [NSNumber numberWithBool:YES];
}

- (NSNumber *)Fail_Station_Matching:(NSDictionary *)dictPara
                       RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSString	*strServerFailStationName   = [m_dicMemoryValues objectForKey:@"FAIL_STATION"];
    NSArray     *aryStationName             = [dictPara allKeys];
    BOOL        bHaveFailStation            = NO;
    BOOL        bYet                        = YES;
    NSString    *strLocalFailStationName    = nil;
    NSDictionary *dicFailStationKeys        = nil;
    
    for (NSString *stationName in aryStationName)
    {
        if ([strServerFailStationName ContainString:stationName])
        {
            dicFailStationKeys = [dictPara objectForKey:stationName];
            strLocalFailStationName = stationName;
            bHaveFailStation = YES;
        }
    }
    
    if (!bHaveFailStation)
    {
        [szReturnValue setString:[NSString stringWithFormat:@"The fail station %@ no need to check CB",strServerFailStationName]];
        return [NSNumber numberWithBool:YES];
    }
    
    bYet    = [[self SEND_COMMAND:[dicFailStationKeys objectForKey:@"SEND_COMMAND"]]boolValue];
    bYet   &= [[self READ_COMMAND:[dicFailStationKeys objectForKey:@"READ_COMMAND"] RETURN_VALUE:szReturnValue]boolValue];
    bYet   &= [[self MEMORY_VALUE_FOR_KEY:[dicFailStationKeys objectForKey:@"MEMORY_VALUE_FOR_KEY"] RETURN_VALUE:szReturnValue]boolValue];
    bYet   &= [[self CATCH_VALUE:[dicFailStationKeys objectForKey:@"CATCH_VALUE"] RETURN_VALUE:szReturnValue]boolValue];
    bYet   &= [[self JUDGE_SPEC:[dicFailStationKeys objectForKey:@"JUDGE_SPEC"] RETURN_VALUE:szReturnValue]boolValue];
    return [NSNumber numberWithBool:bYet];
}

- (NSNumber *)Query_Fail_Station_WSDL:(NSDictionary *)dictPara
                         RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSString	*strISN         = [m_dicMemoryValues objectForKey:@"MLBSN"];
    NSString    *strURL         = [dictPara objectForKey:@"WSDL_URL"];
    NSString    *strMethod      = [dictPara objectForKey:@"WSDL_Method"];
    
    BOOL bYet   = NO;
    WSMethodInvocationRef rpcCall;
    NSURL *rpcURL = [NSURL URLWithString:strURL];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:strISN,nil] forKeys:[NSArray arrayWithObjects:@"MLBSN",nil]];
    NSDictionary *result;
    rpcCall = WSMethodInvocationCreate((CFURLRef) rpcURL, (CFStringRef) strMethod, kWSSOAP2001Protocol);
    
    if (params)
    {
        WSMethodInvocationSetParameters (rpcCall, (CFDictionaryRef) params, NULL);
    }
    result = (NSDictionary *) (WSMethodInvocationInvoke(rpcCall));
    ATSDebug(@"result = %@", result);
    
    if (WSMethodResultIsFault ((CFDictionaryRef) result))
    {
        bYet = NO;
        NSDictionary    *dicResult  = [result objectForKey: (NSString *) kWSFaultString];
        ATSDebug(@"result = %@",dicResult);
        [szReturnValue setString:@"FAIL"];
    }
    else
    {
        bYet = YES;
        NSDictionary    *dicResult  = [result objectForKey: (NSString *) kWSMethodInvocationResult];
        NSString    *strResult  = [dicResult objectForKey:@"return"];
        ATSDebug(@"result = %@",strResult);
        if (strResult&&dicResult)
        {
            [szReturnValue setString:strResult];
            [m_dicMemoryValues setObject:strResult forKey:@"FAIL_STATION"];
        }
        else
        {
            bYet = NO;
            ATSDebug(@"result = %@",dicResult);
            [szReturnValue setString:@"FAIL"];
        }
    }
	return [NSNumber numberWithBool:bYet];
}
- (NSNumber *)Query_Fail_Station_CRB_Result:(NSDictionary *)dictPara
                               RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSString	*strISN         = [m_dicMemoryValues objectForKey:@"MLBSN"];
    NSString    *strURL         = [dictPara objectForKey:@"WSDL_URL"];
    NSString    *strMethod      = [dictPara objectForKey:@"WSDL_Method"];
    NSString    *strStationName = [dictPara objectForKey:@"Station_Name"];
    BOOL bYet   = NO;
    WSMethodInvocationRef rpcCall;
    NSURL *rpcURL = [NSURL URLWithString:strURL];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:strISN,strStationName,nil] forKeys:[NSArray arrayWithObjects:@"sn",@"Station",nil]];
    
    NSDictionary *result;
    rpcCall = WSMethodInvocationCreate((CFURLRef) rpcURL, (CFStringRef) strMethod, kWSSOAP2001Protocol);
    
    if (params)
    {
        WSMethodInvocationSetParameters (rpcCall, (CFDictionaryRef) params, NULL);
    }
    NSLog(@"START====================");
    result = (NSDictionary *) (WSMethodInvocationInvoke(rpcCall));
    ATSDebug(@"result = %@", result);
    NSLog(@"END====================");
    
    if (WSMethodResultIsFault ((CFDictionaryRef) result))
    {
        NSDictionary    *dicResult  = [result objectForKey: (NSString *) kWSFaultString];
        ATSDebug(@"result = %@",dicResult);
        [szReturnValue setString:@"FAIL"];
        return [NSNumber numberWithBool:bYet];
    }
    
    NSDictionary    *dicResult  = [result objectForKey: (NSString *) kWSMethodInvocationResult];
    NSString    *strResult  = [dicResult objectForKey:@"return"];
    ATSDebug(@"result = %@",strResult);
    if (!strResult || !dicResult)
    {
        [szReturnValue setString:@"FAIL"];
        return [NSNumber numberWithBool:bYet];
    }
    
    if ([strResult isEqualToString:@"PASS"])
    {
        bYet = YES;
        ATSDebug(@"result = %@",dicResult);
        [szReturnValue setString:strResult];
    }
    else
    {
        bYet = NO;
        ATSDebug(@"result = %@",dicResult);
        [szReturnValue setString:strResult];
    }
    
	return [NSNumber numberWithBool:bYet];
}
- (NSNumber *)WRITE_WSDL:(NSDictionary *)dictPara
            RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSString	*strISN         = [m_dicMemoryValues objectForKey:@"MLBSN"];
    NSString    *strURL         = [dictPara objectForKey:@"WSDL_URL"];
    NSString    *strMethod      = [dictPara objectForKey:@"WSDL_Method"];
    NSString    *strProduct     = [dictPara objectForKey:@"Product"];
    NSString    *strStationID   = [dictPara objectForKey:@"Station_Id"];
    NSString    *strStationName = [dictPara objectForKey:@"Test_Station_Name"];
    NSString	*strStartTime   = [[m_dicMemoryValues objectForKey:@"Single_Start_Time"]
                                   descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M:%S"
                                   timeZone:nil
                                   locale:nil];
    NSString	*strStopTime	= [[NSDate date] descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M:%S"
                                                                timeZone:nil
                                                                  locale:nil];
    NSString    *strFailList    = m_szFailLists;
    NSString    *strFinalResult       = nil;
    if (m_bFinalResult)
    {
        strFinalResult = [NSString stringWithFormat:@"PASS"];
    }
    else
    {
        strFinalResult = [NSString stringWithFormat:@"FAIL"];
    }
    
    BOOL bYet   = NO;
    WSMethodInvocationRef rpcCall;
    NSURL *rpcURL = [NSURL URLWithString:strURL];
    NSMutableString *strResult  = [[NSMutableString alloc]init];
    [strResult appendFormat:@"TEST%cSTATUS%cVALUE%cU_LIMIT%cL_LIMIT\r\n",0x7F,0x7F,0x7F,0x7F];
    [strResult appendFormat:@"\"start_time\"%c0%c\"%@\"%c\"N/A\"%c\"N/A\"\r\n",0x7F,0x7F,strStartTime,0x7F,0x7F];
    [strResult appendFormat:@"\"stop_time\"%c0%c\"%@\"%c\"N/A\"%c\"N/A\"\r\n",0x7F,0x7F,strStopTime,0x7F,0x7F];
    [strResult appendFormat:@"\"sn\"%c0%c\"%@\"%c\"N/A\"%c\"N/A\"\r\n",0x7F,0x7F,strISN,0x7F,0x7F];
    [strResult appendFormat:@"\"product\"%c0%c\"%@\"%c\"N/A\"%c\"N/A\"\r\n",0x7F,0x7F,strProduct,0x7F,0x7F];
    [strResult appendFormat:@"\"station_id\"%c0%c\"%@\"%c\"N/A\"%c\"N/A\"\r\n",0x7F,0x7F,strStationID,0x7F,0x7F];
    [strResult appendFormat:@"\"test_station_name\"%c0%c\"%@\"%c\"N/A\"%c\"N/A\"\r\n",0x7F,0x7F,strStationName,0x7F,0x7F];
    [strResult appendFormat:@"\"result\"%c0%c\"%@\"%c\"N/A\"%c\"N/A\"\r\n",0x7F,0x7F,strFinalResult,0x7F,0x7F];
    [strResult appendFormat:@"\"list_of_failing_tests\"%c0%c\"%@\"%c\"N/A\"%c\"N/A\"",0x7F,0x7F,strFailList,0x7F,0x7F];
    ATSDebug(@"strResult=%@",strResult);
    NSDictionary    *params = [NSDictionary dictionaryWithObject:strResult forKey:@"RESULT"];
    
    NSDictionary *result;
    rpcCall = WSMethodInvocationCreate((CFURLRef) rpcURL, (CFStringRef) strMethod, kWSSOAP2001Protocol);
    
    if (params)
    {
        WSMethodInvocationSetParameters (rpcCall, (CFDictionaryRef) params, NULL);
    }
    result = (NSDictionary *) (WSMethodInvocationInvoke(rpcCall));
    ATSDebug(@"result = %@", result);
    
    if (WSMethodResultIsFault ((CFDictionaryRef) result))
    {
        bYet = NO;
        ATSDebug(@"result = %@", [result objectForKey: (NSString *) kWSFaultString]);
        [szReturnValue setString:@"FAIL"];
    }
    else
    {
        bYet = YES;
        ATSDebug(@"result = %@", [result objectForKey: (NSString *) kWSMethodInvocationResult]);
        [szReturnValue setString:@"PASS"];
        
    }
    [strResult release];
	return [NSNumber numberWithBool:bYet];
}

//add by xiaoyong, 2014/03/22 For Mesa EEPROM Test, if the result count is not 10,fail. if result contain "0x00" or "0xff" fail.
//Check the above items test result
//Param:
//          NSDictionary    *dicContents   : 
//              
//          NSMutableString *strReturnValue : Return value
// Return:
//      YES.

- (NSNumber *)TEST_MESA_EEPROM:(NSDictionary *)dicContent RETURN_VALUE:(NSMutableString *)szReturnValue
{
    if (![szReturnValue ContainString:@"  "])
    {
        return [NSNumber numberWithBool:NO];
    }
    
    NSArray     *aArray      = [szReturnValue componentsSeparatedByString:@"  "];
    int         iCount      = [[szReturnValue componentsSeparatedByString:@"  "] count];
    if (10 != iCount)
    {
        [szReturnValue setString:@"Return number is not 10!"];
        return [NSNumber numberWithBool:NO];
    }
     //judge rule:if reture value is All 0xFF,it will return NO. If once there is one != 0xFF ,it will return YES.
    for (int i = 0 ; i < iCount; i++)
    {
        unsigned int iValue;
        NSScanner   *scaner = [NSScanner scannerWithString:[aArray objectAtIndex:i]];
        if ([scaner scanHexInt:&iValue] && [scaner isAtEnd])
        {
            if (0xFF != iValue)
            {
                return  [NSNumber numberWithBool:YES];
            }
        }        
    }
    [szReturnValue setString:@"Return value is all 0xFF"];
    return [NSNumber numberWithBool:NO];

}

- (NSNumber *)MESA_CHIPID:(NSDictionary *)dicContent RETURN_VALUE:(NSMutableString *)szReturnValue
{
    if (szReturnValue.length != 32)
    {
        [szReturnValue setString:@"The length of serial number is not 32 bit"];
        return [NSNumber numberWithBool:NO];
    }
    
    NSString    *szSrNm = [NSString stringWithFormat:@"0x%@ 0x%@ 0x%@ 0x%@",
                           [szReturnValue substringToIndex:8],
                           [[szReturnValue substringFromIndex:8] substringToIndex:8],
                           [[szReturnValue substringFromIndex:16] substringToIndex:8],
                           [[szReturnValue substringFromIndex:24] substringToIndex:8]];

    [szReturnValue setString:szSrNm];
    
    return [NSNumber numberWithBool:YES];
}
-(NSNumber *)PARSEBARCODE:(NSDictionary * )dicContent RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSString * szBarcode = [m_dicMemoryValues objectForKey:[dicContent objectForKey:@"KEY"]];
    if(szBarcode == nil || [szBarcode isEqualToString:@""])
    {
        [szReturnValue setString:@"Barcode is nil"];
        return [NSNumber numberWithBool:NO];

    }
    NSString * szSeparator = [dicContent objectForKey:@"separator"];
    int iCount = [[dicContent objectForKey:@"BarcodeCount"] intValue];
    // add for offset setting
	
    NSDictionary * dicCharacterSetting = [dicContent objectForKey:@"characterSetting"];
    NSArray * aryCharactorSetting = [dicCharacterSetting allKeys];
    NSArray * aryBarcode = [szBarcode componentsSeparatedByString:szSeparator];
    
    [szReturnValue setString:@""];
    [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%i",iCount] forKey:@"BarcodeCount"];
    //judge barcode format
    if(iCount >0)
    {
        if([aryBarcode count] < iCount)
        {
            [szReturnValue setString:@"Barcode format error"];
            return [NSNumber numberWithBool:NO];
        }
    }

    //parse string
    for(NSString * szKey in aryCharactorSetting)
    {
        NSDictionary * dicKey = [dicCharacterSetting objectForKey:szKey];
        NSString * szIndex = [dicKey objectForKey:@"index"];
        NSString * szLink  = [dicKey objectForKey:@"linkcharacter"];
        NSArray * aryIndex = [szIndex componentsSeparatedByString:szLink];
        NSMutableString * szStrKey = [[NSMutableString alloc] initWithString:@""];
        for (NSString * szStr in aryIndex)
        {
            int index = [szStr intValue];
            NSString * szParseBarcode = [aryBarcode objectAtIndex:index];
            if([szStrKey isEqualToString:@""])
            {
                [szStrKey setString:szParseBarcode];
            }
            else
            {
                [szStrKey setString:[NSString stringWithFormat:@"%@%@%@",szStrKey,szLink,szParseBarcode]];
            }
            
        }
        
        [m_dicMemoryValues setObject:[NSString stringWithFormat:@"\"%@\"",szStrKey] forKey:[NSString stringWithFormat:@"%@_csv",szKey]];
        [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%@",szStrKey] forKey:szKey];
        [szStrKey release];
    }
    
    return [NSNumber numberWithBool:YES];
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

- (NSNumber *)READ_TERMINAL:(NSDictionary*)dictSettings RETURN_VALUE:(NSMutableString*)szReturnValue
{
    NSString *szToolPath       = [dictSettings objectForKey:@"ToolPath"];
    NSArray *arrInput       = [dictSettings objectForKey:@"Argument"];
    BOOL bSequoia = [dictSettings objectForKey:@"Sequoia"];
    if (arrInput == Nil) {
        [szReturnValue setString:@"No input argument in srcipt"];
        return [NSNumber numberWithBool:NO];
    }
    
    NSMutableArray *arrTemp = [[NSMutableArray alloc] initWithArray:arrInput];
    NSMutableArray *arrFinal = [[NSMutableArray alloc] init];
    
    for (NSString *szArg in arrTemp) {
        if ([szArg ContainString:@"/*"] && [szArg ContainString:@"*/"]) {
            if ([self TransformKeyToValue:szArg returnValue:&szArg]) {
                [arrFinal addObject:szArg];
            }
            else {
                [szReturnValue setString:[NSString stringWithFormat:@"Can't get value from key:%@", szArg]];
                [arrTemp release];
                [arrFinal release];
                return [NSNumber numberWithBool:NO];
            }
            
        }else {
            [arrFinal addObject:szArg];
        }
    }
    NSArray *args = [NSArray arrayWithArray:arrFinal];
    [arrTemp release];
    [arrFinal release];
    
    if (bSequoia) {
        NSTask *task = [[NSTask alloc] init];
        NSPipe *outPipe = [[NSPipe alloc]init];
        [task setLaunchPath:szToolPath];
        [task setArguments:args];
        [task setStandardOutput:outPipe];
        [task launch];
        [task waitUntilExit];
        [task release];
        [outPipe release];
        return [NSNumber numberWithBool:YES];
    }
    
    if (![self CallTask:szToolPath Parameter:args EndString:nil TimeOut:nil ReturnValue:szReturnValue]){
        return [NSNumber numberWithBool:NO];
        }
    
    return [NSNumber numberWithBool:YES];
}

-(NSNumber *)CHECK_NANDSIZE_WITH_SPEC:(NSDictionary *)dicContents
                         RETURN_VALUE:(NSMutableString *)szReturnValue
{
    id dicForNandSize = [dicContents objectForKey:KFZ_Script_JudgeNandSizeSpec];
	//  NSMutableString * szName = [dicContents objectForKey:@"TestItemName"];
    NSMutableString * szName = [[NSMutableString alloc] init];
    [szName setString:@""];
	NSNumber *numRet = [NSNumber numberWithBool:YES];
    
    if (dicForNandSize!=nil)
    {
        NSArray * arySpec = [dicForNandSize allKeys];
		
        BOOL obel = NO;
        for (NSString * szSpec in arySpec)
        {
            if(szSpec !=NULL)
            {
                NSDictionary *dicSpec = [NSDictionary dictionaryWithObjectsAndKeys:szSpec , kFZ_Script_JudgeCommonBlack , nil];
                dicSpec = [NSDictionary dictionaryWithObjectsAndKeys:dicSpec , kFZ_Script_JudgeCommonSpec , nil];
				
                if([[self JUDGE_SPEC:dicSpec RETURN_VALUE:szReturnValue] boolValue])
                {
                    [szName setString:[NSString stringWithFormat:@"%@[%@]",[dicContents objectForKey:@"TestItemName"],[dicForNandSize objectForKey:szSpec]]];
                    obel = YES;
                    break;
                }
            }
        }
        if(!obel)
        {
            [szReturnValue setString:@"value not in spec"];
			numRet = [NSNumber numberWithBool:NO];
        }
        else
        {
			[m_dicMemoryValues setObject:[szName copy] forKey:kFZ_UI_SHOWNNAME];
        }
    }
    else
    {
        ATSDebug(@"Haven't no specs") ;
        numRet = [NSNumber numberWithBool:NO];
    }
    [szName release];
    return  numRet;
	
}

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

// 2013-10-30 add by xiaoyong for pressure function
// Set dictionary
// Param:
//      NSMutableDictionary  *dictSettings   : NA
//      NSMutableString *szReturnValue      : Return value
// Return:
//      YES
//
- (NSNumber *)GET_ROW_FROM_RAWDATA:(NSDictionary *)dicSetting RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSArray     *arrCounts  = [[m_dicMemoryValues objectForKey:@"GetRows"] componentsSeparatedByString:@"\n"];
    NSString    *szLine     = [arrCounts objectAtIndex:0];
    NSString    *szLastLine = [arrCounts objectAtIndex:[arrCounts count]-1];
    NSString    *szCount    = [NSString stringWithFormat:@"%d",[arrCounts count]];
    
    [m_dicMemoryValues setObject:szLine forKey:@"LineValue"];
    [m_dicMemoryValues setObject:szLastLine forKey:@"LastLineValue"];
    [m_dicMemoryValues setObject:szCount forKey:@"SamplesCollected"];
    return [NSNumber numberWithBool:YES];
}
-(NSNumber *)CAL_SQRT:(NSDictionary* )dicParam RETURN_VALUE:(NSMutableString*)strReturnValue
{
    NSString * szValue = [dicParam objectForKey:@"VALUE"];
    [strReturnValue setString:@""];
    NSString	*szOutValue	= @"";
    BOOL	bRet		= [self TransformKeyToValue:szValue
							   returnValue:&szOutValue];
    if(bRet)
    {
        double dSum = [szOutValue doubleValue];
        double dSportValue = sqrt(dSum);
        [strReturnValue setString:[NSString stringWithFormat:@"%.5f", dSportValue]];
        return [NSNumber numberWithBool:YES];
    }
    else
    {
        ATSDebug(@"CAL_SPORT : ==> Can't find parameters of value %@",
				 szOutValue);
        return [NSNumber numberWithBool:NO];
    }
}
-(NSNumber*)COST_TIME:(NSDictionary* )dicParam RETURN_VALUE:(NSMutableString *)strReturnValue
{
    NSDate  *endDate        = [NSDate date];
	double costTime         = [endDate timeIntervalSinceDate:dateStartTime];
    [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%fs",costTime] forKey:@"Cost_Time"];
    NSMutableString *strCostTime   = [NSMutableString stringWithFormat:@"%fs",costTime];
    NSRange range = [strCostTime rangeOfString:@"s"];
    [strCostTime deleteCharactersInRange:NSMakeRange(range.location, 1)];
    [strReturnValue appendString:[NSString stringWithFormat:@"%@",strCostTime]];
    return [NSNumber numberWithBool:YES];
}


//Add by Lily 2014.11.19
- (NSNumber *)EZ_LINK_TEST:(NSDictionary *)dictPara
              RETURN_VALUE:(NSMutableString *)strReturnValue
{
    
    NSString	*szPortType		= [dictPara objectForKey:kFZ_Script_DeviceTarget];
    NSString	*szBsdPath		= [[m_dicPorts objectForKey:szPortType] objectAtIndex:kFZ_SerialInfo_SerialPort];
    NSString	*szPath			= [dictPara objectForKey:@"PATH"];
    NSString	*szCommand		= [dictPara objectForKey:@"COMMAND"];
    
    
    NSTask	*task		= [[NSTask alloc] init];
    NSPipe	*outPipe	= [[NSPipe alloc]init];
    [task setLaunchPath:szPath];
    //    ATSDebug(@"Response command command path :%@",szPath);
    
    NSArray	*args		= [NSArray arrayWithObjects:
                           szBsdPath,szCommand,nil];
    
    
    [task setArguments:args];
    [task setStandardOutput:outPipe];
    [task launch];
    //    ATSDebug(@"Response command command args:%@",args);
    
    NSData	*data		= [[outPipe fileHandleForReading]
                           readDataToEndOfFile];
    [task waitUntilExit];
    [task release];
    [outPipe release];
    NSString	*szString	= [[NSString alloc]	initWithData:data
                                               encoding:NSUTF8StringEncoding];
    
    ATSDebug(@"Response command ok1");
    
    [IALogs CreatAndWriteUARTLog:szString
                          atTime:kIADeviceALSFileNameDate
                      fromDevice:@"MOBILE"
                        withPath:[NSString stringWithFormat:
                                  @"%@/%@_%@_Uart.txt",
                                  kPD_LogPath_Uart,
                                  m_szPortIndex,
                                  m_szStartTime]
                          binary:NO];
    [strReturnValue appendString:[NSString stringWithFormat:@"%@",szString]];
    
    ATSDebug(@"Response command ok2");
    
    [szString release];
    return [NSNumber numberWithBool:YES];
}
-(NSNumber*)CREATE_FOLDER:(NSDictionary* )dicParam RETURN_VALUE:(NSMutableString *)strReturnValue
{
    NSString * szFolder = [dicParam objectForKey:@"Folder"];
    NSFileManager * fileManger = [NSFileManager defaultManager];
    
    if([fileManger fileExistsAtPath:szFolder])
    {
        [fileManger removeItemAtPath:szFolder error:nil];
    }
    
    if([fileManger createDirectoryAtPath:szFolder withIntermediateDirectories:YES attributes:nil error:nil])
    {
        return [NSNumber numberWithBool:YES];
    }
    else
    {
        [strReturnValue setString:[NSString stringWithFormat:@"create folder:%@ fail",szFolder]];
        return [NSNumber numberWithBool:NO];
    }
    
}
-(NSNumber*)MOVE_FILE:(NSDictionary* )dicParam RETURN_VALUE:(NSMutableString *)strReturnValue
{
    NSArray * aryFORM = [dicParam objectForKey:@"FROM"];
    NSString * szMOVE = [dicParam objectForKey:@"MOVE"];
    
    if(![aryFORM count])
    {
        [strReturnValue setString:@"not from Forder"];
        return [NSNumber numberWithBool:NO];
    }
    
    [self TransformKeyToValue:szMOVE returnValue:&szMOVE];
    
    NSFileManager * fileManger = [NSFileManager defaultManager];
    
    if(![fileManger fileExistsAtPath:szMOVE])
    {
        [strReturnValue setString:[NSString stringWithFormat:@"%@ not found",szMOVE]];
        return [NSNumber numberWithBool:NO];
    }

    for (NSString * szFrom in aryFORM)
    {
        [self TransformKeyToValue:szFrom returnValue:&szFrom];
        
        if(![fileManger fileExistsAtPath:szFrom])
        {
            [strReturnValue setString:[NSString stringWithFormat:@"%@ not found",szFrom]];
            return [NSNumber numberWithBool:NO];
        }
    }

    for (NSString * szFrom in aryFORM)
    {
        [self TransformKeyToValue:szFrom returnValue:&szFrom];
        NSString * szMoveTo = [NSString stringWithFormat:@"%@/%@",szMOVE,[szFrom lastPathComponent]];
        if(![fileManger fileExistsAtPath:szMoveTo])
        {
            if(![fileManger moveItemAtPath:szFrom toPath:szMoveTo error:nil])
            {
                [strReturnValue setString:[NSString stringWithFormat:@"move %@ to %@ fail",szFrom,szMOVE]];
                return [NSNumber numberWithBool:NO];
            }
            
        }
    }
    
    return [NSNumber numberWithBool:YES];
}
-(NSNumber*)UPLOAD_FILE:(NSDictionary* )dicParam RETURN_VALUE:(NSMutableString *)strReturnValue
{
    NSString * szFolder = [dicParam objectForKey:@"Folder"];
    NSString * szFileName = [dicParam objectForKey:@"FileName"];
    
    
    m_bUploadFile = YES;
    [m_szFilePath setString:[NSString stringWithFormat:@"%@/%@",szFolder,szFileName]];
    NSFileManager * fileManger = [NSFileManager defaultManager];
    if(![fileManger fileExistsAtPath:szFolder])
    {
        return [NSNumber numberWithBool:NO];
    }
    NSArray * aryFile = [fileManger contentsOfDirectoryAtPath:szFolder error:nil];
    
    for (NSString * szFile in aryFile)
    {
        if([szFile hasSuffix:@"csv"] || [szFile hasSuffix:@"JPG"] || [szFile hasSuffix:@"mat"])
        {
            [m_aryFile addObject:[NSString stringWithFormat:@"%@/%@",szFolder,szFile]];
        }
    }
    
    return [NSNumber numberWithBool:YES];
}
-(NSNumber*)REMOVE_FILE:(NSDictionary* )dicParam RETURN_VALUE:(NSMutableString *)strReturnValue
{
    NSString * szFilePath = [dicParam objectForKey:@"FilePath"];
    
    NSFileManager * fileManger = [NSFileManager defaultManager];
    
    if([fileManger fileExistsAtPath:szFilePath])
    {
        m_bRemoveFile = YES;
        [m_szRemoveFilePath setString:szFilePath];
    }
    
    return [NSNumber numberWithBool:YES];
}
-(NSNumber *)CHECKCSV_AndWRITECSV:(NSDictionary* )dicParam RETURN_VALUE:(NSMutableString *)strReturnValue
{
    NSString * szCSVPath = [dicParam objectForKey:@"Path"];
    NSString * szWriteCSVFolder = [dicParam objectForKey:@"Folder"];
    NSString * szSN = [m_dicMemoryValues objectForKey:@"ISN"];
    NSString * szFileName = [szCSVPath lastPathComponent];
    NSFileManager * fileManger = [NSFileManager defaultManager];
    if([fileManger fileExistsAtPath:szCSVPath] && [fileManger fileExistsAtPath:szWriteCSVFolder])
    {
        NSString * szFileContent = [NSString stringWithContentsOfFile:szCSVPath encoding:NSUTF8StringEncoding error:nil];
        
        if(![szFileContent ContainString:szSN])
        {
            [strReturnValue setString:@"CSV not contain this sn record"];
            return [NSNumber numberWithBool:NO];
        }
        //szFileContent = [szFileContent stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
        szFileContent = [szFileContent stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
        szFileContent = [szFileContent stringByReplacingOccurrencesOfString:@"\\r" withString:@"\n"];
        szFileContent = [szFileContent stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"];
        szFileContent = [szFileContent stringByReplacingOccurrencesOfString:@"\n\r" withString:@"\n"];
        szFileContent = [szFileContent stringByReplacingOccurrencesOfString:@"\n\n" withString:@"\n"];
        [szFileContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSMutableArray * aryFileContent = [NSMutableArray arrayWithArray:[szFileContent componentsSeparatedByString:@"\n"]];
        
        
        if(![aryFileContent count])
        {
            [strReturnValue setString:@"CSV not record"];
            return [NSNumber numberWithBool:NO];
        }
        
        //another CSV content
        NSMutableString * szCSVFile = [NSMutableString stringWithString:[aryFileContent objectAtIndex:0]];
        //rewrite CSV content
        NSMutableString * szCSV = [NSMutableString stringWithString:[aryFileContent objectAtIndex:0]];
        
        BOOL bCSVSingleSN = YES;
        
        for (NSString * szFileCoulm in aryFileContent)
        {
            if(![szFileCoulm isEqualToString:@""])
            {
                if([szFileCoulm ContainString:szSN])
                {
                    [szCSVFile appendString:[NSString stringWithFormat:@"\n%@",szFileCoulm]];
                }
                else
                {
                    if([aryFileContent indexOfObject:szFileCoulm])
                    {
                        [szCSV appendString:[NSString stringWithFormat:@"\n%@",szFileCoulm]];
                        bCSVSingleSN = NO;
                    }
                }
            }
            
        }
        
        if(!bCSVSingleSN)
        {
            //Rewrite CSV and write another CSV
            [szCSVFile writeToFile:[NSString stringWithFormat:@"%@/%@",szWriteCSVFolder,szFileName] atomically:YES encoding:NSUTF8StringEncoding error:nil];
            
            
            [szCSV writeToFile:szCSVPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
            
        }
        
        return [NSNumber numberWithBool:YES];
        
    }
    else
    {
        [strReturnValue setString:[NSString stringWithFormat:@"%@ or %@ not found",szCSVPath,szWriteCSVFolder]];
        return [NSNumber numberWithBool:NO];
    }
    
    return [NSNumber numberWithBool:NO];
}

-(NSNumber *)CHECKFOLDER_FILECOUNT:(NSDictionary* )dicParam RETURN_VALUE:(NSMutableString *)strReturnValue
{
    int iCount = [[dicParam objectForKey:@"COUNT"] intValue];
    NSString * szFolder =[dicParam objectForKey:@"Folder"];
    NSString * szFileType = [dicParam objectForKey:@"TYPE"];
    NSString * szFileKey  = [dicParam objectForKey:@"FileSaveKey"];
    
    
    NSFileManager * fileManger = [NSFileManager defaultManager];
    
    if([fileManger fileExistsAtPath:szFolder])
    {
        NSArray * aryFile = [fileManger contentsOfDirectoryAtPath:szFolder error:nil];
        
        if(![aryFile count])
        {
            [strReturnValue setString:@"Folder not file"];
            return [NSNumber numberWithBool:NO];
        }
        else
        {
            int iSum = 0;
            for (NSString * szFile in aryFile)
            {
                if([szFile hasSuffix:szFileType])
                {
                    [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%@/%@",szFolder,szFile] forKey:[NSString stringWithFormat:@"%@%d",szFileKey,iSum]];
                    iSum++;
                }
                
                
            }
            
            if(iSum == iCount)
            {
                return [NSNumber numberWithBool:YES];
            }
            else
            {
                for (int i = 0; i<iSum; i++)
                {
                    [m_dicMemoryValues removeObjectForKey:[NSString stringWithFormat:@"image%d",iSum]];
                }
                [strReturnValue setString:[NSString stringWithFormat:@"%@ file count=%d",szFileType,iSum]];
                return [NSNumber numberWithBool:NO];
            }
        }
    }
    else
    {
        [strReturnValue setString:@"CHECKFOLDER_FILECOUNT: folder not found"];
        return [NSNumber numberWithBool:NO];
    }
    
    return [NSNumber numberWithBool:NO];
}
-(NSNumber *)RENAME_FILE:(NSDictionary* )dicParam RETURN_VALUE:(NSMutableString *)strReturnValue
{
    NSString * szFileKey = [dicParam objectForKey:@"FileKey"];
    NSString * szRename = [dicParam objectForKey:@"Rename"];
    NSString * szFileType = [dicParam objectForKey:@"TYPE"];
    
    [self TransformKeyToValue:szRename returnValue:&szRename];
    int iCount = [[dicParam objectForKey:@"COUNT"] intValue];
    
    NSMutableArray * aryFile = [[NSMutableArray alloc] init];
    for (int i = 0; i< iCount; i++)
    {
        NSString * szFile = [m_dicMemoryValues objectForKey:[NSString stringWithFormat:@"%@%d",szFileKey,i]];
        if(!szFile)
        {
            [strReturnValue setString:[NSString stringWithFormat:@"%@%d not found",szFileKey,i]];
            return [NSNumber numberWithBool:NO];
        }
        else
        {
            [aryFile addObject:szFile];
        }
    }
    
    for (NSString * szFilePath in aryFile)
    {
        int index = [aryFile indexOfObject:szFilePath];
        
        if(index == 0)
        {
            NSFileManager * fileManger = [NSFileManager defaultManager];
            NSString * fileName = [szFilePath lastPathComponent];
            NSString * szRenameFile = [szFilePath stringByReplacingOccurrencesOfString:fileName withString:[NSString stringWithFormat:@"%@.%@",szRename,szFileType]];
            
            if(![szRenameFile isEqualToString:szFilePath])
            {
                if(![fileManger moveItemAtPath:szFilePath toPath:szRenameFile error:nil])
                {
                    [strReturnValue setString:@"rename file fail"];
                    return [NSNumber numberWithBool:NO];
                }

            }
            
            
            
        }
        else
        {
            NSFileManager * fileManger = [NSFileManager defaultManager];
            NSString * fileName = [szFilePath lastPathComponent];
            NSString * szRenameFile = [szFilePath stringByReplacingOccurrencesOfString:fileName withString:[NSString stringWithFormat:@"%@_%d.%@",szRename,index,szFileType]];
             if(![szRenameFile isEqualToString:szFilePath])
             {
                 [fileManger moveItemAtPath:szFilePath toPath:szRenameFile error:nil];
             }
        }
    }
    [aryFile release];
    return [NSNumber numberWithBool:YES];
}
-(NSNumber *)COPY_FILE:(NSDictionary* )dicParam RETURN_VALUE:(NSMutableString *)strReturnValue
{
    NSString * szFilePath = [dicParam objectForKey:@"FilePath"];
    NSString * szFolder = [dicParam objectForKey:@"Folder"];
    NSString * szMovedName = [dicParam objectForKey:@"MovedName"];
    
    [self TransformKeyToValue:szFilePath returnValue:&szFilePath];
    [self TransformKeyToValue:szFolder returnValue:&szFolder];
    [self TransformKeyToValue:szMovedName returnValue:&szMovedName];
    
    NSFileManager * fileManger = [NSFileManager defaultManager];
    if(![fileManger fileExistsAtPath:szFilePath])
    {
        [strReturnValue setString:[NSString stringWithFormat:@"%@ not found",szFilePath]];
        return [NSNumber numberWithBool:NO];
    }
    
    if(![fileManger fileExistsAtPath:szFolder])
    {
        if(![fileManger createDirectoryAtPath:szFolder withIntermediateDirectories:YES attributes:nil error:nil])
        {
            [strReturnValue setString:[NSString stringWithFormat:@"create %@ fail",szFolder]];
            return [NSNumber numberWithBool:NO];
        }
    }
    
    if(![fileManger copyItemAtPath:szFilePath toPath:[NSString stringWithFormat:@"%@/%@",szFolder,szMovedName] error:nil])
    {
        [strReturnValue setString:[NSString stringWithFormat:@"copy file form %@ to %@ fail",szFilePath,szFolder]];
        return [NSNumber numberWithBool:NO];
    }
    
    return [NSNumber numberWithBool:YES];
}


@end
