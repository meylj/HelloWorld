//  IADevice_ALS.m
//  Izual_Lu
//
//  Created by Lu Izual on 11-5-5.
//  Copyright 2011å¹?PEGATRON. All rights reserved.



#import "IADevice_ALS.h"



@implementation TestProgress (IADevice_ALS)

#pragma mark ############################## ALS ##############################
// Get Prox and ALS data, and calculate them
// Param:
//      NSDictionary    *dictSettings   : Settings
//          SOURCE      -> NSString*    : Data source
//          SN          -> NSString*    : SN.
//          LOCATION    -> NSString*    : Save data to location. (Can be nil)
//      NSMutableString        *strReturnValue : Return value
// Return:
//      Actions result
-(NSNumber*)GENERATE_PROX_ALS_DATA:(NSDictionary*)dictSettings
					  RETURN_VALUE:(NSMutableString*)strReturnValue
{
    // Basic judge
    if((![dictSettings isKindOfClass:[NSDictionary class]])
       || (![[dictSettings objectForKey:kIADeviceALSDataSource]
             isKindOfClass:[NSString class]])
       || (![[dictSettings objectForKey:kIADeviceALSFileSNKey]
             isKindOfClass:[NSString class]])
       || ((nil != [dictSettings objectForKey:kIADeviceALSFileLocation])
           && (![[dictSettings objectForKey:kIADeviceALSFileLocation]
                 isKindOfClass:[NSString class]])))
        return [NSNumber numberWithBool:NO];
    
    // Get user settings
    NSString	*strFileLocation	= [dictSettings objectForKey:
									   kIADeviceALSFileLocation];
    if(nil == strFileLocation)
        strFileLocation	= [self getValueFromXML:kPD_UserDefaults
										mainKey:kPD_UserDefaults_ALSPath, nil];
    if(nil == strFileLocation)
    {
        [strReturnValue setString:@"No file location"];
        return [NSNumber numberWithBool:NO];
    }
    
    // Get source
    NSString	*strDataSource	= [dictSettings objectForKey:kIADeviceALSDataSource];
    [self TransformKeyToValue:strDataSource
				  returnValue:&strDataSource];
    
    // Save to file
    NSString	*strFileName	= [dictSettings objectForKey:kIADeviceALSFileSNKey];
    [self TransformKeyToValue:strFileName
				  returnValue:&strFileName];
    strFileName	= [NSString stringWithFormat:@"%@/%@%@%@.txt",
				   strFileLocation,				strFileName,
				   kIADeviceALSFileNameLink,	kIADeviceALSFileNameDate];
    NSFileManager	*fileManager	= [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:strFileName])
		[fileManager removeItemAtPath:strFileName
								error:nil];
    NSError *errorSave;
    [strDataSource writeToFile:strFileName
                    atomically:YES
                      encoding:NSUTF8StringEncoding
                         error:&errorSave];
    
    // Check file save result
    usleep(100000);
    if(![fileManager fileExistsAtPath:strFileName])
    {
        [strReturnValue setString:[NSString stringWithFormat:
								   @"File saving failed: [%@]",
                                   [errorSave localizedDescription]]];
        return [NSNumber numberWithBool:NO];
    }
    
    // End
    [strReturnValue setString:[NSString stringWithFormat:
							   @"File saved to [%@]",strFileName]];
    return [NSNumber numberWithBool:YES];
}

//2011-8-4 add by Gordon
// Get Als&Prox data
// Param:
//      NSMutableString        *strReturnValue : Return value
// Return:
//      Actions result
- (NSNumber *)GET_ARRAY_ALS_PROX:(NSDictionary *)dicSub
					RETURN_VALUE:(NSMutableString *)strReturnValue
{
    int				iTotalNumber;
	memset(dData,0,6000*sizeof(double));
	NSString		*szDataPath		= @"/vault/Data/";
    NSFileManager	*BuildLogPath	= [NSFileManager defaultManager];
	if ([BuildLogPath fileExistsAtPath:szDataPath]!=YES)
		[BuildLogPath createDirectoryAtPath:szDataPath
				withIntermediateDirectories:YES
								 attributes:nil
									  error:nil];
    NSString	*szStartTime	= m_szStartTime;
	NSString	*dataPath		= [NSString stringWithFormat:
								   @"%@%@.txt", szDataPath, szStartTime];
	[strReturnValue writeToFile:dataPath
					 atomically:YES
					   encoding:1
						  error:nil];
	NSString	*szAlsData		= strReturnValue;
    szAlsData	= [szAlsData stringByReplacingOccurrencesOfString:@"  "
													 withString:@","];
    szAlsData	= [szAlsData stringByReplacingOccurrencesOfString:@" "
													 withString:@"\n"];
    [m_dicMemoryValues setObject:szAlsData
						  forKey:KIADeviceALS_DATA];
	NSRange		range_return	= [szAlsData rangeOfString:@"\n"];
	if((NSNotFound != range_return.location)
	   && (range_return.length >0)
	   && ((range_return.location +range_return.length) <= [szAlsData length]))
		do
		{
            // separate als data by "\n"
			szAlsData		= [szAlsData  stringByReplacingCharactersInRange:range_return
															 withString:@","];
			range_return	= [szAlsData rangeOfString:@"\n"];
		}while((NSNotFound != range_return.location)
			   && (range_return.length > 0)
			   && ((range_return.location + range_return.length) <= [szAlsData length]));
	else
		return [NSNumber numberWithBool:NO];
	NSArray	*array	= [szAlsData componentsSeparatedByString:@","];
	iTotalNumber	= ([array count] - 3) / 6;
    [m_dicMemoryValues setObject:[NSNumber numberWithInt: iTotalNumber]
						  forKey:KIADeviceALS_TOTALNUMBER];
	for(int iRow = 0; iRow<iTotalNumber; iRow++)
		for(int iColumn = 0; iColumn<5; iColumn++)
		{
			NSString		*szbuf		= [array objectAtIndex:(iRow * 6 + iColumn + 1)];
			unsigned int	iBuf;
			NSScanner		*scanerBuf	= [NSScanner scannerWithString:szbuf];
			if([scanerBuf scanHexInt:&iBuf])
                // save "prox data", "als red data", "als green data", "als blue data", "als clear data",
                // to two-dimensional array dDate[iRow][iColmn]
				dData[iRow][iColumn]	= iBuf;
		}
    return [NSNumber numberWithBool:YES];
}

//2011-8-4 add by Gordon
// Calculate the Ratio of ALS
// Param:
//      NSDictionary    *dictSettings   : Settings
//          JudgeValue  -> int          : Als judge value
//      NSMutableString        *strReturnValue : Return value
// Return:
//      Actions result
- (NSNumber *)CALCULATE_RATIO:(NSDictionary*)dictSettings
				 RETURN_VALUE:(NSMutableString*)strReturnValue
{
    double		dBlue_Ratio, dRed_Ratio, dGreen_Ratio;
    int		iTotalNumber	= [[m_dicMemoryValues objectForKey:
								KIADeviceALS_TOTALNUMBER]
							   intValue];
    NSString	*szColor	= [m_dicMemoryValues objectForKey:
							   KIADeviceDUT_COLOR];
	if (iTotalNumber==0)
    {
        // if cann't read out als data, return "NO ALS Data" to UI
        [strReturnValue setString:@"NO ALS Data"];
        ATSDebug(@"CALCULATE_RATIO : [NO ALS Data]");
        [m_dicMemoryValues setObject:@"NO ALS Data"
							  forKey:KIADeviceALS_REDRATIO];
        [m_dicMemoryValues setObject:@"NO ALS Data"
							  forKey:KIADeviceALS_GREENRATIO];
        [m_dicMemoryValues setObject:@"NO ALS Data"
							  forKey:KIADeviceALS_BLUERATIO];
		return [NSNumber numberWithBool:NO];
	}
	else
    {
		int	iJudgeValue	= [[dictSettings valueForKey:
							KIADeviceALS_JUDGEVALUE] intValue];
        [m_dicMemoryValues setObject:[NSNumber numberWithInt:iJudgeValue]
							  forKey:KIADeviceALS_JUDGEVALUE];
		int	i = 1, j = 0;
        // catch the first above 1200 point and save to dicMemoryValues
		int	iFirstAbove1200	= [self CATCH_THE_POINT_LOCATION:j
													  COLUMN:i
													   LABLE:@"above"];
        [m_dicMemoryValues setObject:[NSNumber numberWithInt:iFirstAbove1200]
							  forKey:KIADeviceALS_FIRSTABOVE1200];
		if (iFirstAbove1200>=iTotalNumber)
        {
            [strReturnValue setString:[NSString stringWithFormat:
									   @"No data first more than %i", iJudgeValue]];
			return [NSNumber numberWithBool:NO];
		}
        // Begin from the first above 1200 point, catch the first below 1200 point and save to dicMemoryVaules
        int	iFirstBelow1200	= [self CATCH_THE_POINT_LOCATION:iFirstAbove1200
													  COLUMN:i
													   LABLE:@"below"];
        [m_dicMemoryValues setObject:[NSNumber numberWithInt:iFirstBelow1200]
							  forKey:KIADeviceALS_FIRSTBELOW1200];
        // get the middle point between point iFirstAbove1200 and point iFirstBelow1200
		int	iMid3	= (iFirstAbove1200 + iFirstBelow1200) / 2 - 1;
		//if white unit, the three ratio is fixed value.
		if ([szColor isEqualToString:KIADeviceDUT_WHITECOLOR])
		{
			dBlue_Ratio		= 0.90910201;
            dRed_Ratio		= 1.818205;
            dGreen_Ratio	= 10.000153;
		}
		else
		{
            if (iMid3 < 0)
            {
                // if the middle point is below 0,
				//	the als data we get is the wrong data and we notice UI "Wrong ALS Data"
                [strReturnValue setString:@"Wrong ALS Data"];
                ATSDebug(@"CALCULATE_RATIO : [Wrong ALS Data]");
                [m_dicMemoryValues setObject:@"Wrong ALS Data"
									  forKey:KIADeviceALS_REDRATIO];
                [m_dicMemoryValues setObject:@"Wrong ALS Data"
									  forKey:KIADeviceALS_GREENRATIO];
                [m_dicMemoryValues setObject:@"Wrong ALS Data"
									  forKey:KIADeviceALS_BLUERATIO];
                return [NSNumber numberWithBool:NO];
            }
			else
            {
				// red_ratio = als_clear/als_red
                dRed_Ratio		= (dData[iMid3][KIADeviceALS_CLEAR]
								   / dData[iMid3][KIADeviceALS_RED]);
				// red_ratio = als_clear/als_green
                dGreen_Ratio	= (dData[iMid3][KIADeviceALS_CLEAR]
								   / dData[iMid3][KIADeviceALS_GREEN]);
				// red_ratio = als_clear/als_blue
                dBlue_Ratio		= (dData[iMid3][KIADeviceALS_CLEAR]
								   / dData[iMid3][KIADeviceALS_BLUE]);
            }
		}
        [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%lf", dRed_Ratio]
							  forKey:KIADeviceALS_REDRATIO];
        [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%lf", dGreen_Ratio]
							  forKey:KIADeviceALS_GREENRATIO];
        [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%lf", dBlue_Ratio]
							  forKey:KIADeviceALS_BLUERATIO];
        [strReturnValue setString:[NSString stringWithFormat:@"%lf", dBlue_Ratio]];
		return [NSNumber numberWithBool:YES];
	}
}

//2011-8-4 add by Gordon
// Calculate the Gain of ALS
// Param:
//      NSDictionary    *dictSettings   : Settings
//          LUX         -> int          : lux
//      NSMutableString        *strReturnValue : Return value
// Return:
//      Actions result
- (NSNumber *)CALCULATE_GAIN:(NSDictionary*)dictSettings
				RETURN_VALUE:(NSMutableString*)strReturnValue
{
    if ([[m_dicMemoryValues objectForKey:KIADeviceALS_BLUERATIO]
		 isEqualToString:@"NO ALS Data"])
    {
        [strReturnValue setString:@"NO ALS Data"];
        ATSDebug(@"CALCULATE_GAIN : [NO ALS Data]");
        return [NSNumber numberWithBool:NO];
    }
	int		lux				= [[dictSettings valueForKey:@"LUX"] intValue];
    int		iFirstAbove1200	= [[m_dicMemoryValues objectForKey:
								KIADeviceALS_FIRSTABOVE1200] intValue];
    int		iFirstBelow1200	= [[m_dicMemoryValues objectForKey:
								KIADeviceALS_FIRSTBELOW1200] intValue];
    int		iJudgeValue		= [[m_dicMemoryValues objectForKey:
								KIADeviceALS_JUDGEVALUE] intValue];
    int		iTotalNumber	= [[m_dicMemoryValues objectForKey:
								KIADeviceALS_TOTALNUMBER] intValue];
    NSString	*szColor	= [m_dicMemoryValues objectForKey:
							   KIADeviceDUT_COLOR];
    NSString	*szAlsData	= [m_dicMemoryValues objectForKey:
							   KIADeviceALS_DATA];
    
	int	i = 1, j = iFirstBelow1200 + 1;
	double	gain2, cyan, magenta, yellow, red2, green2, blue2;
    // catch the second above 1200 point and save to dicMemoryValues
	int	iSecondAbove1200	= [self CATCH_THE_POINT_LOCATION:j
												   COLUMN:i
													LABLE:@"above"];
    [m_dicMemoryValues setObject:[NSNumber numberWithInt:iSecondAbove1200]
						  forKey:KIADeviceALS_SECONDABOVE1200];
	if (iSecondAbove1200 >= iTotalNumber)
	{
        [strReturnValue setString:[NSString stringWithFormat:
								   @"No data second more than %i", iJudgeValue]];
		return [NSNumber numberWithBool:NO];
	}
    // Begin from the second above 1200 point, catch the second below 1200 point and save to dicMemoryVaules
	int	iSecondBelow1200	= [self CATCH_THE_POINT_LOCATION:iSecondAbove1200
												   COLUMN:i
													LABLE:@"below"];
    [m_dicMemoryValues setObject:[NSNumber numberWithInt:iSecondBelow1200]
						  forKey:KIADeviceALS_SECONDBELOW1200];
    // get the middle point between point iSecondAbove1200 and point iSecondBelow1200
	int	iMid4	= (iSecondAbove1200 + iSecondBelow1200) / 2 - 1;
    if (iMid4 < 0)
    {
        [strReturnValue setString:@"Wrong ALS Data"];
        return [NSNumber numberWithBool:NO];
    }
    NSString		*szPointPath	= @"/vault/Point/";
    NSFileManager	*BuildLogPath	= [NSFileManager defaultManager];
	if ([BuildLogPath fileExistsAtPath:szPointPath] != YES)
		[BuildLogPath createDirectoryAtPath:szPointPath
				withIntermediateDirectories:YES
								 attributes:nil
									  error:nil];
    NSString	*szISN			= m_szISN;
    NSString	*szStartTime	= m_szStartTime;
	NSString	*alsinfo		= [NSString stringWithFormat:
								   @"%@\nx1,%d\nx2,%d\nIR_MIDDLE,%d\nx3,%d\nx4,%d\nMIDDLE,%d\nx3-x2,%d\nx1-x4 represent 4 points which first more or less than 1200",
								   szAlsData,			iFirstAbove1200,
								   iFirstBelow1200,		iMid4,
								   iSecondAbove1200,	iSecondBelow1200,
								   iMid4,				iSecondAbove1200 - iFirstBelow1200];
    NSString	*szAlsInfoPath	= @"/vault/AlsInfoPath/";
	if ([BuildLogPath fileExistsAtPath:szAlsInfoPath]!=YES)
		[BuildLogPath createDirectoryAtPath:szAlsInfoPath
				withIntermediateDirectories:YES
								 attributes:nil
									  error:nil];
	NSString	*alsinfopath	= [NSString stringWithFormat:
								   @"%@%@_%@_ALS.csv",
								   szAlsInfoPath, szISN, szStartTime];
	[alsinfo writeToFile:alsinfopath
			  atomically:YES
				encoding:NSASCIIStringEncoding
				   error:nil];
    // calculate gain formula is different about white unit and black unit
	if ([szColor isEqualToString:KIADeviceDUT_WHITECOLOR])
	{
		gain2	= 4.0 * lux / (2 * dData[iMid4][KIADeviceALS_CLEAR]
							   - 2 * dData[iMid4][KIADeviceALS_RED]
							   + 2 * dData[iMid4][KIADeviceALS_GREEN]
							   - 1 * dData[iMid4][KIADeviceALS_BLUE]);
        ATSDebug(@"calc_gain : %lf,color is white", gain2);
	}
	else
	{
        double	dRed_Ratio		= [[m_dicMemoryValues objectForKey:
									KIADeviceALS_REDRATIO] doubleValue];
        double	dGreen_Ratio	= [[m_dicMemoryValues objectForKey:
									KIADeviceALS_GREENRATIO] doubleValue];
        double	dBlue_Ratio		= [[m_dicMemoryValues objectForKey:
									KIADeviceALS_BLUERATIO] doubleValue];
		cyan	= (dData[iMid4][KIADeviceALS_CLEAR]
				   - (dData[iMid4][KIADeviceALS_RED] * dRed_Ratio));
		magenta	= (dData[iMid4][KIADeviceALS_CLEAR]
				   - (dData[iMid4][KIADeviceALS_GREEN] * dGreen_Ratio));
		yellow	= (dData[iMid4][KIADeviceALS_CLEAR]
				   - (dData[iMid4][KIADeviceALS_BLUE] * dBlue_Ratio));
		red2	= magenta+yellow;
		green2	= yellow+cyan;
		blue2	= cyan+magenta;
		gain2	= lux / (- 0.1 * red2 + 1.2 * green2 - 0.1 * blue2);
        ATSDebug(@"calc_gain : %lf,color is black", gain2);
	}
    [strReturnValue setString:[NSString stringWithFormat:@"%.2f", gain2]];
	return [NSNumber numberWithBool:YES];
}

//2011-8-4 add by Gordon
// Get the point
// Param:
//      int        row :            the specific row
//      int        column :         the specific column
//      NSString   aboveOrbelow :   above mode or below mode
// Return:
//      return the first point above or below the value "JudgeValue" setting at - (BOOL)CALCULATE_GAIN: RETURN_VALUE:
- (int)CATCH_THE_POINT_LOCATION:(int)row
						 COLUMN:(int)column
						  LABLE:(NSString *)aboveOrbelow
{
	double	ave				= 0.0;
    int		iJudgeValue		= [[m_dicMemoryValues objectForKey:
								KIADeviceALS_JUDGEVALUE] intValue];
    int		iTotalNumber	= [[m_dicMemoryValues objectForKey:
								KIADeviceALS_TOTALNUMBER] intValue];
	for(; row<iTotalNumber ; row++)
	{
		ave	= [self AVERAGE_FOR_ALS:row];
		if ([aboveOrbelow isEqualToString:@"above"])
            // make sure the successive three points are all above iJudgeValue
			if (ave >= iJudgeValue
				&& [self AVERAGE_FOR_ALS:row+1] >= iJudgeValue
				&& [self AVERAGE_FOR_ALS:row+2] >= iJudgeValue)
				return row + 1;
        // make sure the successive three points are all below iJudgeValue
		if ([aboveOrbelow isEqualToString:@"below"])
			if (ave < iJudgeValue
				&& [self AVERAGE_FOR_ALS:row+1] < iJudgeValue
				&& [self AVERAGE_FOR_ALS:row+2] < iJudgeValue)
				return row;
	}
    return 0;
}

//2011-8-4 add by Gordon
// Get the average of the row
// Param:
//      int        row : the specific row
// Return:
//      the average value
- (double)AVERAGE_FOR_ALS:(int)row
{
	double	sum	= 0.0;
	double	ave	= 0.0;
	for(int column=1; column<5; column++)
		sum	+= dData[row][column];
	ave	= sum / 4.0;
	return ave;
	
}

//+++++marked by yaya.2014/2/4++++++

/* Kyle 2011.12.15
 * method   : AVERAGE_ALS_Clear:RETURN_VALUE:
 * abstract : get ave clear value from ALS data */
/*
 - (NSNumber *)AVERAGE_ALS_ClearAndIR:(NSDictionary *)dicSetting
 RETURN_VALUE:(NSMutableString*)szReturnValue
 {
 int		iCleanCount	= 0;
 int		iIrCount	= 0;
 float	fCleanSum	= 0;
 float	fIrSum		= 0;
 NSArray	*arrayALS	= [szReturnValue componentsSeparatedByString:@"ALS"];
 if ([arrayALS count] < 3)
 {
 ATSDebug(@"ALS Data error!");
 return [NSNumber numberWithBool:NO];
 }
 for(NSString *szTemp in arrayALS)
 {
 if (![szTemp isKindOfClass:[NSString class]])
 continue;
 
 // whether @"Clear Channel: " is exist
 if ([szTemp ContainString:@"Clear Channel: "])
 {
 szTemp	= [szTemp SubFrom:@"Clear Channel: "
 include:NO];
 NSScanner		*scan	= [NSScanner scannerWithString:szTemp];
 unsigned int	iValue	= 0;
 [scan scanHexInt:&iValue];
 iCleanCount++;
 fCleanSum	+= iValue;
 }
 
 // whether @"IR Channel: " is exist
 if ([szTemp ContainString:@"IR Channel: "])
 {
 szTemp	= [szTemp SubFrom:@"IR Channel: "
 include:NO];
 NSScanner		*scan	= [NSScanner scannerWithString:szTemp];
 unsigned int	iValue	= 0;
 [scan scanHexInt:&iValue];
 iIrCount++;
 fIrSum	+= iValue;
 }
 }
 // calculate avg of Clean
 if (iCleanCount)
 [m_dicMemoryValues setObject:[NSNumber numberWithFloat:
 fCleanSum / iCleanCount]
 forKey:KIADeviceALS_CLEAR_CHANNEL];
 else
 {
 ATSDebug(@"data count is 0 !");
 [m_dicMemoryValues setObject:@"NA"
 forKey:KIADeviceALS_CLEAR_CHANNEL];
 }
 // calculate avg of IR
 if (iIrCount)
 [m_dicMemoryValues setObject:[NSNumber numberWithFloat:
 fIrSum / iIrCount]
 forKey:KIADeviceALS_IR_CHANNEL];
 else
 {
 ATSDebug(@"data count is 0 !");
 [m_dicMemoryValues setObject:@"NA"
 forKey:KIADeviceALS_IR_CHANNEL];
 }
 return [NSNumber numberWithBool:YES];
 }
 */
//add by yaya , with new response format.
//Modify by wangyu for canculate ALS new method 2014-02-15.
- (NSNumber *)AVERAGE_ALS_ClearAndIR:(NSDictionary *)dicSetting
						RETURN_VALUE:(NSMutableString*)szReturnValue
{
    int iLimitCount = 0;
    int		iCleanCount	= 0;
    int		iIrCount	= 0;
    float	fCleanSum	= 0;
    float	fIrSum		= 0;
    if ([[dicSetting objectForKey:@"ALS_begin"] isNotEqualTo:@""]) {
        iLimitCount = [[dicSetting objectForKey:@"ALS_begin"] intValue];
    }else
    {
        iLimitCount = 3;
    }
    
    NSArray	*arrayALS	= [szReturnValue componentsSeparatedByString:@"als:"];
    if ([arrayALS count] < iLimitCount)
    {
        ATSDebug(@"ALS Data error!");
        return [NSNumber numberWithBool:NO];
    }
    
    NSArray *arrDoWithALS = [NSArray arrayWithArray:arrayALS];
    NSMutableArray *arrSaveALS_begin = [[NSMutableArray alloc] init];
    if ([[dicSetting objectForKey:@"ALS_begin"] isNotEqualTo:@""]) {
        
        for (int i = iLimitCount; i<[arrayALS count]; i++) {
            [arrSaveALS_begin addObject:[arrayALS objectAtIndex:i]];
        }
        arrDoWithALS  = arrSaveALS_begin;
    }
    
    for(NSString *szTempOrl in arrDoWithALS)
    {
        if (![szTempOrl isKindOfClass:[NSString class]])
            continue;
        
        // whether @"ir =" is exist
        if ([szTempOrl ContainString:@"ir = "])
        {
            NSString *szTemp	= [szTempOrl SubFrom:@"ir = "
                                          include:NO];
            szTemp  = [szTemp SubTo:@","
                            include:NO];
            NSScanner		*scan	= [NSScanner scannerWithString:szTemp];
            unsigned int	iValue	= 0;
            [scan scanHexInt:&iValue];
            iIrCount++;
            fIrSum	+= iValue;
        }
        
        // whether @"clear = " is exist
        if ([szTempOrl ContainString:@"clear = "])
        {
            NSString *szTemp	= [szTempOrl SubFrom:@"clear = "
                                          include:NO];
            NSScanner		*scan	= [NSScanner scannerWithString:szTemp];
            unsigned int	iValue	= 0;
            [scan scanHexInt:&iValue];
            iCleanCount++;
            fCleanSum	+= iValue;
        }  
    }
    [arrSaveALS_begin release];
    // calculate avg of Clean
    if (iCleanCount)
        [m_dicMemoryValues setObject:[NSNumber numberWithFloat:
                                      fCleanSum / iCleanCount]
                              forKey:KIADeviceALS_CLEAR_CHANNEL];
    else
    {
        ATSDebug(@"data count is 0 !");
        [m_dicMemoryValues setObject:@"NA"
                              forKey:KIADeviceALS_CLEAR_CHANNEL];
    }
    // calculate avg of IR
    if (iIrCount)
        [m_dicMemoryValues setObject:[NSNumber numberWithFloat:
                                      fIrSum / iIrCount]
                              forKey:KIADeviceALS_IR_CHANNEL];
    else
    {
        ATSDebug(@"data count is 0 !");
        [m_dicMemoryValues setObject:@"NA"
                              forKey:KIADeviceALS_IR_CHANNEL];
    }
    return [NSNumber numberWithBool:YES];
}

#pragma mark ############################## Tool Functions ##############################

@end




