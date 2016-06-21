//
//  IADevice_CAS140.m
//  FunnyZone
//
//  Created by Lorky Luo on 7/23/12.
//  Copyright 2012 PEGATRON. All rights reserved.
//

#import "IADevice_CAS140.h"
#import "MathLibrary.h"

@interface TestProgress ()
//- (int)checkCASError:(int)error causedByAction:(NSString *)action;
//- (void)useFirstConfigCalibFilePair:(NSURL *)dirURL;
@end

@implementation TestProgress (CAS140Controller)

#define kCASSettingFilePath @"/private/CASCalibDir"

#pragma mark - Private function
- (int)checkCASError:(int)error causedByAction:(NSString *)action
{
    if (error < 0) {
        unichar msgBuffer[256] = {0};
//        f_ip_casGetErrorMessageW(error, msgBuffer, 256);
        NSString *errMsg = [NSString stringWithFormat:@"%S", msgBuffer];
//        NSString *errMsg = [NSString stringWithCharacters:msgBuffer length:256];
        if (action) {
			ATSDebug(@"%@",[NSString stringWithFormat:@"Error: %@ returned %@ (%d)", action, errMsg, error]);
        } else{
			ATSDebug(@"%@",[NSString stringWithFormat:@"Error: CAS4 lib returned %@ (%d)", errMsg, error]);
        }
    }
    return error;
}

- (NSString *)casDeviceParameterStringWithDPID:(int)dpid 
{
    unichar buffer[256] = {0};
    int ret = f_ip_casGetDeviceParameterStringW(CASID, dpid, buffer, 255);
    [self checkCASError:ret causedByAction:[NSString stringWithFormat:@"casGetDeviceParameterStringW with AWhat %d", dpid]];
	
    if (ret<0) {
        return nil;
    } else {
        return [NSString stringWithFormat:@"%S", buffer];
//        return [NSString stringWithCharacters:buffer length:256];
    }
}

- (int)setCasDeviceParameterString:(NSString *)aString withDPID:(int)dpid
{
    int ret = 0;
    unichar* stringPointer = (unichar*) [aString cStringUsingEncoding:NSUTF16LittleEndianStringEncoding];
    ret = f_ip_casSetDeviceParameterStringW(CASID, dpid, stringPointer);
    NSLog(@"f_ip_casSetDeviceParameterStringW %d string: %@ dpid:%d",ret,aString, dpid);
    [self checkCASError:ret causedByAction:[NSString stringWithFormat:@"casSetDeviceParameterStringW with AWhat %d", dpid]]; 
    return ret;
}


- (void)fillDeviceTypes
{    
	// [self.deviceTypes removeAllObjects];
    int count = f_ip_casGetDeviceTypes();
    NSString *devTypeName;
    
    for (int i = 0; i<count; i++) {
        unichar buffer[256] = {0};
        f_ip_casGetDeviceTypeNameW(i, buffer, 255);
        devTypeName = [NSString stringWithFormat:@"%S", buffer];
//        devTypeName = [NSString stringWithCharacters:buffer length:256];
    }
}

- (void)useFirstConfigCalibFilePair:(NSURL *)dirURL
{
    //clear any previously used files
    [self setCasDeviceParameterString:@"" withDPID:dpidConfigFileName];
    [self setCasDeviceParameterString:@"" withDPID:dpidCalibFileName];
    
    NSFileManager *fm = [NSFileManager defaultManager];
	ATSDebug(@"%@",[NSString stringWithFormat:@"Looking for config/calib files in %@", dirURL]);
    
    NSArray *dirFiles = [fm contentsOfDirectoryAtURL:dirURL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    for (NSURL *configFileURL in dirFiles) {
        if ([[configFileURL pathExtension] caseInsensitiveCompare:@"ini"] == NSOrderedSame) {
            if ([fm fileExistsAtPath:[configFileURL path]]) {
                NSURL *calibFileURL = [[configFileURL URLByDeletingPathExtension] URLByAppendingPathExtension:@"isc"];
                if ([fm fileExistsAtPath:[calibFileURL path]]) {
                    ATSDebug(@"Found file pair %@", [configFileURL lastPathComponent]);
                    [self setCasDeviceParameterString:[configFileURL path] withDPID:dpidConfigFileName];
                    [self setCasDeviceParameterString:[calibFileURL path] withDPID:dpidCalibFileName];
                    break;
                }
            }
        }
    }
}

- (BOOL)downloadConfigCalib:(NSURL *)dirURL
{
	ATSDebug(@"Trying to download config/calib files into %@", dirURL);
    //make sure the dir is there
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:[dirURL path]]) {
		ATSDebug(@"creating non-existent director @ %@", dirURL);
        [fm createDirectoryAtPath:[dirURL path] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    BOOL isDir;
    if ([fm fileExistsAtPath:[dirURL path] isDirectory:&isDir]) {
        if (!isDir) 
        {
			ATSDebug(@"unexpected file found at %@", dirURL);
            return NO;
        }
    } else {
		ATSDebug(@"failed to create directory!!");
		return NO;
    }
    //now that the dir is there, make sure it's empty, maybe better to backup old files?
    NSArray *existingFiles = [fm contentsOfDirectoryAtURL:dirURL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    if (([existingFiles count] > 0)) 
		ATSDebug(@"Deleting existing calib files before download");
	for (NSURL *url in existingFiles) 
	{
        [fm removeItemAtURL:url error:nil];
    }
    //now download files from the device, this might take a while
    //the download is initiated by setting the path as dpidGetFilesFromDevice
    NSString *identKeySerial = [self casDeviceParameterStringWithDPID:dpidAccessorySerial];
    if (identKeySerial.length == 0) identKeySerial = @"No ident key!!";
	ATSDebug(@"Downloading files from device... Ident key connected: %@", identKeySerial);
    int ret = [self setCasDeviceParameterString:[dirURL path] withDPID:dpidGetFilesFromDevice];
    return ret >= 0;
}

#pragma mark - FunnyZone APIs
#pragma mark Init Instruments
- (NSNumber *)READCAS140_SERIALNUMBER:(NSDictionary *)dictPara RETURNVALUE:(NSMutableString *)retValue
{
	// Get Device Types
	int count = f_ip_casGetDeviceTypes();
    NSString *devTypeName = @"";
	int i = 0;
    for (; i<count; i++) {
        unichar buffer[256] = {0};
        f_ip_casGetDeviceTypeNameW(i, buffer, 255);
        devTypeName = [NSString stringWithFormat:@"%S", buffer];
//        devTypeName = [NSString stringWithCharacters:buffer length:256];
		if ([devTypeName length] > 0 && [devTypeName isNotEqualTo:@"Demo Mode"]) break;
	}
	
    int countOptions = f_ip_casGetDeviceTypeOptions(i);
    [self checkCASError:count causedByAction:@"casGetDeviceTypeOptions"];
    NSString *devOptionName;
    
    int option;
	
    for (int j = 0; j<countOptions; j++) {
        option = f_ip_casGetDeviceTypeOption(i, j);
        [self checkCASError:option causedByAction:@"casGetDeviceTypeOption"];
        unichar buffer[256] = {0};
        f_ip_casGetDeviceTypeOptionNameW(i, j, buffer, 255);
        devOptionName = [NSString stringWithFormat:@"%S", buffer];
//        devOptionName = [NSString stringWithCharacters:buffer length:256];
        if ([devOptionName length]>0)
		{
			[retValue setString:devOptionName];
			[m_dicMemoryValues setObject:devOptionName forKey:@"CAS140SerialNumber"];
			return [NSNumber numberWithBool:YES];
		}
	}
	
	[retValue setString:@"Unknow Error"];
	return [NSNumber numberWithBool:NO];
}

- (NSNumber *)INITCAS140:(NSDictionary *)dictPara RETURNVALUE:(NSMutableString *)retValue
{
	int ret = 0;
    
    //start by finding the first device option
    ret = [self checkCASError:f_ip_casGetDeviceTypeOptions(InterfaceCASUSB) causedByAction:@"casGetDeviceTypeOptions"];
    if (ret < 1)
    {
		ATSDebug(@"AutoInit failed because there are no device options for USB. No device attached or not powered on? ret = %d", ret);
        [retValue setString:[NSString stringWithFormat:@"AutoInit failed because there are no device options for USB. No device attached or not powered on? ret = %d", ret]];
		return [NSNumber numberWithBool:NO];
    }
    
    //now create the device with the first device option
    int opt = f_ip_casGetDeviceTypeOption(InterfaceCASUSB, 0);
    CASID = [self checkCASError:f_ip_casCreateDeviceEx(InterfaceCASUSB, opt) causedByAction:@"casCreateDeviceEx"];
	ATSDebug(@"Created CAS device with id=%d, type=USB and option=%d", CASID, opt);
    if (CASID < 0) {
		ATSDebug(@"Device creation failed!");
		[retValue setString:@"Device creation failed!"];
        return [NSNumber numberWithBool:NO];
    }
    
    
    //enable the coCheckCalibConfigSerials option, since we need the checks during casInitialize
    f_ip_casSetOptionsOnOff(CASID, coCheckCalibConfigSerials, 1);
    ret = [self checkCASError:f_ip_casGetError(CASID) causedByAction:@"enabling coCheckCalibConfigSerials option"];
    if (ret < 0) return [NSNumber numberWithBool:NO];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *dirURL = [[fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    dirURL = [dirURL URLByAppendingPathComponent:@"CASCalibDir"];
    [self useFirstConfigCalibFilePair:dirURL];
    
    ret = f_ip_casInitialize(CASID, InitForced);
    NSString *serial = [self casDeviceParameterStringWithDPID:dpidSerialNo];
	ATSDebug(@"casInitialized returned %d, serial %@", ret, serial);
    if (ret < 0) {
        //in case of any error, try to fix it by redownloading the config/calib files from the device
        if ([self downloadConfigCalib:dirURL]) 
        {
            //if download was successful, get the first file pair again
            [self useFirstConfigCalibFilePair:dirURL];
            //now try to inialize again!
            ret = f_ip_casInitialize(CASID, InitForced);
            serial = [self casDeviceParameterStringWithDPID:dpidSerialNo];
			ATSDebug(@"2nd try for casInitialized returned %d, serial %@", ret, serial);
            if (ret < 0) return [NSNumber numberWithBool:NO];
        } else {
            ATSDebug(@"download calibration files from device failed!");
            return [NSNumber numberWithBool:NO];
        }
    }

	// setting options
	f_ip_casSetOptionsOnOff(CASID, coAutorangeMeasurement, 1);
	f_ip_casSetMeasurementParameter(CASID, mpidAutoRangeLevel, 50);
	f_ip_casSetMeasurementParameter(CASID, mpidAutoRangeMaxIntTime, 5000);
	f_ip_casSetMeasurementParameter(CASID, mpidTOPDistance, 340);
	
	
	
	
	// Restore the handle of the Instrument.
	NSDictionary * dictInstrument = [NSDictionary dictionaryWithObjectsAndKeys:
									 [NSNumber numberWithInt:CASID],@"CASHANDLE", nil];
	[[NSUserDefaults standardUserDefaults] setObject:dictInstrument forKey:@"InstrumentPara"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	return [NSNumber numberWithBool:YES];
}

- (NSNumber *)DO_DARKCURRENT:(NSDictionary *)dictPara RETURNVALUE:(NSMutableString *)strReturn
{
	//we need a dark current measurement!
	ATSDebug(@"Measuriing dark current");
	f_ip_casSetShutter(CASID, casShutterClose);
	if ([self checkCASError:f_ip_casGetError(CASID) causedByAction:@"closing shutter"] < 0) 
		return [NSNumber numberWithBool:NO];
	[self checkCASError:f_ip_casMeasureDarkCurrent(CASID) causedByAction:@"casMeasureDarkCurrent"];
	
	f_ip_casSetShutter(CASID, casShutterOpen);
	if ([self checkCASError:f_ip_casGetError(CASID) causedByAction:@"opening shutter"] < 0) 
		return [NSNumber numberWithBool:NO];
	
	//here ret is still from casMeasureDarkCurrent!
	ATSDebug(@"Prepare successfully finished!");
	
	// I don't konw what's that, Just copy from old MFC code.
	f_ip_casSetMeasurementParameter(CASID, mpidColormetricStart, 368.5);
	return [NSNumber numberWithBool:YES];
}

- (NSNumber *)INITCAMERA:(NSDictionary *)dictPara RETURNVALUE:(NSMutableString *)strReturn
{
	//ideally the return values of casGetDeviceParameter should be checked too
    //(or passed to self checkCASError!). Skipped here for brevity.
    long pixels = roundtol(f_ip_casGetDeviceParameter(CASID, dpidPixels));
    long deadPixels = roundtol(f_ip_casGetDeviceParameter(CASID, dpidDeadPixels));
    long visiblePixels = roundtol(f_ip_casGetDeviceParameter(CASID, dpidVisiblePixels)); 
    
	ATSDebug(@"%ld pixels, %ld visible, %ld dead", pixels, visiblePixels, deadPixels);
    
    //demo code for checking for TOP150 and extracting camera OEM serial #
    long topType = roundtol(f_ip_casGetDeviceParameter(CASID, dpidTOPType));
    if (topType == ttTOP150) {
		f_ip_casSetMeasurementParameter(CASID, mpidTOPDistance, 340);
        NSString *topSerial = [self casDeviceParameterStringWithDPID:dpidTOPSerialEx];
        NSArray *topSerialParts = [topSerial componentsSeparatedByString:@";"];
        if (topSerialParts.count == 2)
		{
			ATSDebug(@"TOP150 with serial %@ configured. Camera serial is %@", [topSerialParts objectAtIndex:0], topSerialParts.lastObject);
			f_ip_casSetDeviceParameter(CASID, dpidTOPSerialEx, [topSerialParts.lastObject doubleValue]);
        } 
		else
		{
			f_ip_casSetDeviceParameter(CASID, dpidTOPSerialEx, [topSerial doubleValue]);
			ATSDebug(@"Unexpected TOP150 serial %@. Camera serial cannot be extracted", topSerial);   
		}
    } 
	else
	{
		ATSDebug(@"No TOP150 configured");
	}

	return [NSNumber numberWithBool:YES];
}

#pragma mark Do meausrement
- (NSNumber *)DO_MEASUREMENT:(NSDictionary *)dictPara RETURNVALUE:(NSMutableString *)retValue
{
	double dx,dy,dz,u,v,vv;
	NSString * strShortPattern = [dictPara objectForKey:@"ShortPattern"];
	if (strShortPattern == nil || ![[strShortPattern class] isSubclassOfClass:[NSString class]])
	{
		[retValue setString:@"No such Short pattern"];
		return [NSNumber numberWithBool:NO];
	}
	int iRet = -1;
	iRet = [self checkCASError:f_ip_casPerformAction(CASID, paPrepareMeasurement) causedByAction:@"casPerformAction"];
	if (iRet < 0) return [NSNumber numberWithBool:NO];
	iRet = [self checkCASError:f_ip_casMeasure(CASID) causedByAction:@"casMeasure"];
	if (iRet < 0) return [NSNumber numberWithBool:NO];
	iRet = [self checkCASError:f_ip_casColorMetric(CASID) causedByAction:@"casColorMetric"];
	if (iRet < 0) return [NSNumber numberWithBool:NO];
	
	double photInt;
	double radInt;
	char unit[256];
	f_ip_casGetPhotInt(CASID, &photInt, unit, 20);
	ATSDebug(@"Photometric integral: %lg %s", photInt, unit);
	f_ip_casGetRadInt(CASID, &radInt, unit, 20);
	ATSDebug(@"Radiometric integral: %lg %s", radInt, unit);
	f_ip_casGetColorCoordinates(CASID, &dx, &dy, &dz, &u, &v, &vv);
	
	// Restore the value into the Memory buffer
	[m_dicMemoryValues setObject:[NSString stringWithFormat:@"%.4f",dx] forKey:[NSString stringWithFormat:@"%@x",strShortPattern]];
	[m_dicMemoryValues setObject:[NSString stringWithFormat:@"%.4f",dy] forKey:[NSString stringWithFormat:@"%@y",strShortPattern]];
	[m_dicMemoryValues setObject:[NSString stringWithFormat:@"%.4f",dz] forKey:[NSString stringWithFormat:@"%@z",strShortPattern]];
	[m_dicMemoryValues setObject:[NSString stringWithFormat:@"%.4f",u] forKey:[NSString stringWithFormat:@"%@u",strShortPattern]];
	[m_dicMemoryValues setObject:[NSString stringWithFormat:@"%.4f",v] forKey:[NSString stringWithFormat:@"%@v",strShortPattern]];
	[m_dicMemoryValues setObject:[NSString stringWithFormat:@"%.4f",vv] forKey:[NSString stringWithFormat:@"%@vv",strShortPattern]];
	[m_dicMemoryValues setObject:[NSString stringWithFormat:@"%.4f",photInt] forKey:[NSString stringWithFormat:@"%@Photo",strShortPattern]]; 
	
	return [NSNumber numberWithBool:YES];
}

- (NSNumber *)READ_INSTRUMENT_SN:(NSDictionary *)dictPara RETURNVALUE:(NSMutableString *)retValue
{
	NSDictionary * dicInstrumentPara = [[NSUserDefaults standardUserDefaults] objectForKey:@"InstrumentPara"];	
	CASID = [[dicInstrumentPara objectForKey:@"CASHANDLE"] intValue];
	char *buffer = (char *)malloc(256);
	//[self checkCASError:casGetSerialNumberExW(CASID, dpidSerialNo, buffer, 255) causedByAction:@"casGetSerialNumber"];
	f_ip_casGetSerialNumber(CASID, buffer, 255);
	NSString * strInstrumentSerialNumber = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
	NSArray * aryTemp = [strInstrumentSerialNumber componentsSeparatedByString:@";"];
	if (![aryTemp count])
	{
        free(buffer);
		ATSDebug(@"Get the serial number fail");
		[retValue setString:@"Get the serial fail"];
		return [NSNumber numberWithBool:NO];
	}
	free(buffer);
	strInstrumentSerialNumber = [aryTemp objectAtIndex:0];
	[retValue setString:strInstrumentSerialNumber];
	return [NSNumber numberWithBool:YES];
}

- (NSNumber *)CALCULATE_GAMMA_VALUE:(NSDictionary *)dictPara RETURN_VALUE:(NSMutableString *)retValue
{
	NSMutableArray * aryIndex = [[NSMutableArray alloc] init];
	NSMutableArray * aryValues = [[NSMutableArray alloc] init];
	int i = 0;
	int iStep = 8;
	NSString  * strShortPattern = [dictPara objectForKey:@"ShortPattern"];
	if (strShortPattern == nil)
	{
		[retValue setString:@"No Short Pattern"];
        [aryIndex release];
        [aryValues release];
		return [NSNumber numberWithBool:NO];
	}
    NSArray *arrChangeStep = [NSArray arrayWithObjects:@"32",@"65",@"106",@"139",@"180",@"213",@"246", nil];
	for (; i < 256; i+=iStep)
	{
		NSString * strKey = [NSString stringWithFormat:@"%@%dPhoto",strShortPattern,i];
		if (![[m_dicMemoryValues allKeys] containsObject:strKey])
		{
			ATSDebug(@"Can NOT find the key [%@] in memory bufer",strKey);
			[aryIndex release];
			[aryValues release];
			return [NSNumber numberWithBool:NO];
		}
		NSString * strValue = [m_dicMemoryValues objectForKey:strKey];
		
		[aryIndex addObject:[NSNumber numberWithInt:i]];
		[aryValues addObject:strValue];
        
		if ([arrChangeStep containsObject:[NSString stringWithFormat:@"%d",i]])
        {
            iStep = 9;
        }
        else
        {
            iStep = 8;
        }
	}
	
	NSMutableArray * aryFlag1Value = [[NSMutableArray alloc] initWithCapacity:([aryIndex count]-2)];
	NSMutableArray * aryFlag2Value = [[NSMutableArray alloc] initWithCapacity:([aryIndex count]-2)];
	double b0 = [[aryValues objectAtIndex:0] doubleValue];
	double Y0 = [[aryValues lastObject] doubleValue] - b0;
	
	for (int j = 0; j < ([aryIndex count]-1); j++)
	{
		double f1 = log10(([[aryValues objectAtIndex:j+1] doubleValue] - b0)/Y0);
		double f2 = log10([[aryIndex objectAtIndex:j+1] doubleValue]/[[aryIndex lastObject] doubleValue]);
		
		[aryFlag1Value addObject:[NSNumber numberWithDouble:f1]];
		[aryFlag2Value addObject:[NSNumber numberWithDouble:f2]];
	}
	NSDictionary * dictReturnValue = [MathLibrary LeastSquareBestFit:aryFlag2Value YValue:aryFlag1Value];
	NSNumber * slope = [dictReturnValue objectForKey:@"slope"];
	
	[retValue setString:[NSString stringWithFormat:@"%.4f",[slope doubleValue]]];
	
	NSScanner *scan = [NSScanner scannerWithString:retValue];
	float fValue = 0;
	
	[aryIndex release];
	[aryValues release];
	[aryFlag1Value release];
	[aryFlag2Value release];
	return [NSNumber numberWithBool:([scan scanFloat:&fValue] && [scan isAtEnd])];
}

- (NSNumber *)SET_NEED_TEST_GAMMA:(NSDictionary *)dictPara RETURNVALUE:(NSMutableString *)retValue
{
	int iSequence = [[dictPara objectForKey:@"Sequence"] intValue];
	if (iSequence<=0)
	{
		ATSDebug(@"Get wrong test sequence");
		return [NSNumber numberWithBool:NO];
	}
	// Get current test count
	NSString * strCounterPath = [NSString stringWithFormat:@"%@/Library/Preferences/Muifa_Counter.plist", NSHomeDirectory()];
	NSDictionary * dic = [NSDictionary dictionaryWithContentsOfFile:strCounterPath];
	int currentCount = [[[[dic objectForKey:@"Counter&Cycle_Setting"] objectForKey:@"SFSU"] objectForKey:@"Total Counter"] intValue];
	
	[retValue setString:[NSString stringWithFormat:@"%d",(currentCount % iSequence)]];
	
	return [NSNumber numberWithBool:YES];
}

@end
