//  IADevice_Gyro.m
//  Izual_Lu
//
//  Created by Lu Izual on 11-5-5.
//  Copyright 2011年 PEGATRON. All rights reserved.



#import "IADevice_Gyro.h"
#import "IADevice_TestingCommands.h"



@implementation TestProgress (IADevice_Gyro)

// 2012.04.16 Modified by Andre 
// Descripton:Calculate Gyro_QT_Test_X/Y/Z
//        return input * (2000.0/32768.0)
// Param:
//      input  uint16_t  :  input value
static double u16_to_angular_speed(double_t input)
{
	//soshon change from 0.07 to 2000.0/32768.0，Sunny chang to 2294/32768
#if 1
	double_t const	input_as_double	= input;
	return input_as_double * (2294.0 / 32768.0);
#else
	double_t const	v	= ((input & 0x8000)
						   ? - ((input ^ 0xffff) + 1)
						   : input);
	
	return (2294.0/32768.0) * v;
#endif
}

// Get gyro data from input stream
// Param:
//      NSDictionary    *dicSettings        : Settings
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)GetGyroData:(NSDictionary*)dicContents
			ReturnValue:(NSMutableString*)strReturnValue
{
    double	GyroX;
    double	GyroY;
    double	GyroZ;
    double	GyroTemp;
    ATSDebug(@"GetGyroData");
	ATSDebug(@"%@",dicContents);
    // Basic judge
    if((![dicContents isKindOfClass:[NSDictionary class]])
       || (![strReturnValue isKindOfClass:[NSString class]]))
        return [NSNumber numberWithBool:NO];
    
    //m_szLastValue
	NSRange	range	= [strReturnValue rangeOfString:@"Average"];
	if((range.length+range.location) <= [strReturnValue length]
	   && range.location != NSNotFound
	   && range.length > 0)
	{
		NSString	*gryoXYZTemp	= [strReturnValue substringFromIndex:(range.location
																		  + range.length)];
		range	= [gryoXYZTemp rangeOfString:@"Standard"];
        if (range.location != NSNotFound
			&&range.length >0
			&& (range.length+range.location) <= [gryoXYZTemp length] )
			gryoXYZTemp	= [gryoXYZTemp substringToIndex:range.location];
        else
        {
            ATSDebug(@"The gryoxyztemmp is not ok,please check it!");
            [strReturnValue setString:kFZ_99999_Value_Issue];
            ATSDebug(@"-99999issue");
            return [NSNumber numberWithBool:NO];
        }
		NSArray	*xyztArray	= [gryoXYZTemp componentsSeparatedByString:@","];
		
		/* this would be the obvious way, but coreLocation has a 
		 * transformation matrix, so we must rotate... hence the sign change and
		 * the swap of X and Y from the input stream. */
		////9.19   sky change from x = y to x = -y
		GyroX	= -u16_to_angular_speed([[xyztArray objectAtIndex:1] doubleValue]);
		//9.19   sky change from y = -x to y = x
		GyroY	=  u16_to_angular_speed([[xyztArray objectAtIndex:0] doubleValue]);
		GyroZ	=  u16_to_angular_speed([[xyztArray objectAtIndex:2] doubleValue]);
		ATSDebug(@"gyro temperature : %lf", [[xyztArray objectAtIndex:3] doubleValue]);
		double_t const	double_temperature	= [[xyztArray objectAtIndex:3] doubleValue];
		ATSDebug(@"gyro temperature complement : %lf", double_temperature);
		GyroTemp	= -double_temperature + 36;
        [strReturnValue setString:[NSString stringWithFormat:@"%f", GyroX]];
        ATSDebug(@"GyroX = %f", GyroX);
        [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%f", GyroX]
							  forKey:kIADevice_Gyro_GyroX];
        [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%f", GyroY]
							  forKey:kIADevice_Gyro_GyroY ];
        [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%f", GyroZ]
							  forKey:kIADevice_Gyro_GyroZ];
        [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%f", GyroTemp]
							  forKey:kIADevice_Gyro_GyroTemp];
        return [NSNumber numberWithBool:YES];
	}
	else
    {
        [strReturnValue setString:kFZ_99999_Value_Issue ];
        ATSDebug(@"-99999issue");
        ATSDebug(@"We can not find the 'A,' in the String m_szReturnValue");
        return [NSNumber numberWithBool:NO];
    }
}

// Get gyro data Y from dicMemoryValues
// Param:
//      NSDictionary    *dicSettings        : Settings
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)GetGyroData_Y_Z_Temperature:(NSInteger) iType
					  DictionaryContent:(NSDictionary*) dicContents
							ReturnValue:(NSMutableString*) strReturnValue
{
    double	GyroTemp;
    ATSDebug(@"GetGyroData_Y_Z_Temperature, Type 1 = GetGyroData_Y,Type 2 = GetGyroData_Z,Type 3 = GetGyroData_Temperature");
    ATSDebug(@"Type:%d", iType);
	ATSDebug(@"DictionaryContent:%@", dicContents);
    // Basic judge
    if((![dicContents isKindOfClass:[NSDictionary class]])
       || (![strReturnValue isKindOfClass:[NSString class]]))
        return [NSNumber numberWithBool:NO];
    NSString	*szDicKey;
    if (iType == 1)
        szDicKey	=  kIADevice_Gyro_GyroY;
    else if (iType == 2)
        szDicKey	=  kIADevice_Gyro_GyroZ;
    else
        szDicKey	= kIADevice_Gyro_GyroTemp;
    [strReturnValue setString:[NSString stringWithFormat:
							   @"%@", [m_dicMemoryValues objectForKey:szDicKey]]];
    GyroTemp	= [strReturnValue  doubleValue];
    if (iType == 1)
        ATSDebug(@"GyroY = %f", GyroTemp);
    else if (iType == 2)
        ATSDebug(@"GyroZ = %f", GyroTemp);
    else 
        ATSDebug(@"GyroTemp = %f", GyroTemp);
    return [NSNumber numberWithBool:YES];
}

// Get gyro data Y from dicMemoryValues
// Param:
//      NSDictionary    *dicSettings        : Settings
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)GetGyroData_Y:(NSDictionary*)dicContents
			  ReturnValue:(NSMutableString*)strReturnValue
{
    return [self GetGyroData_Y_Z_Temperature:1
						   DictionaryContent:dicContents
								 ReturnValue:strReturnValue];
}

// Get gyro data Z from dicMemoryValues
// Param:
//      NSDictionary    *dicSettings        : Settings
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)GetGyroData_Z:(NSDictionary*)dicContents
			  ReturnValue:(NSMutableString*)strReturnValue
{
    return [self GetGyroData_Y_Z_Temperature:2
						   DictionaryContent:dicContents
								 ReturnValue:strReturnValue];
}

// Get gyro data Temperature from dicMemoryValues
// Param:
//      NSDictionary    *dicSettings        : Settings
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)GetGyroData_Temperature:(NSDictionary*)dicContents
						ReturnValue:(NSMutableString*)strReturnValue
{
    return [self GetGyroData_Y_Z_Temperature:3
						   DictionaryContent:dicContents
								 ReturnValue:strReturnValue];
}

// Judge gyro's Temperature from dicMemoryValues
// Param:
//      NSDictionary    *dicSettings        : Settings
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)JudgeGyroTemperature:(NSDictionary*)dicContents
					 ReturnValue:(NSMutableString*)strReturnValue
{
    double GyroTemp;
    ATSDebug(@"JudgeGyroTemperature");
	ATSDebug(@"%@", dicContents);
    
    // Basic judge
    if((![dicContents isKindOfClass:[NSDictionary class]])
       || (![strReturnValue isKindOfClass:[NSString class]]))
        return [NSNumber numberWithBool:NO];
    
    [strReturnValue setString:[NSString stringWithFormat:
							   @"%@",
							   [m_dicMemoryValues objectForKey:kIADevice_Gyro_GyroTemp]]];
    GyroTemp	= [strReturnValue  doubleValue];
    ATSDebug(@"GyroTemp = %f", GyroTemp);
    if(GyroTemp < 0)
        return [NSNumber numberWithBool:NO];
    else
        return [NSNumber numberWithBool:YES];
}


// 2012.04.16 Modified by Andre 
// Descripton:Transform hex value to double value
// Param:
//              aString -> NSString*         :   A hex string with 8 bits
//              i       -> int               :   Not 0:calculate the first 4 bits, represents Temo or Y
//                                               IS 0:calculate the last 4 bits, represents X or Z
- (double)convertHexToFloat:(NSString *)aString
					   Flag:(int)i
{
	uint32_t	iTemp;
	int8_t		integer;
	double		frac;
	NSScanner	*scan	= [NSScanner scannerWithString:aString];
	[scan scanHexInt:&iTemp];
	if (i)
	{
		integer	= iTemp >> 24;
		frac	= ((iTemp >> 16) & 0xff) / 256.0;
	}
	else
	{
		integer	= (iTemp >> 8) & 0xff;
		frac	= (iTemp & 0xff) / 256.0;
	}
	return integer+frac;
}

//linear measurement
//add remark by desikan 2012.4.19
// Descripton: Use the Gyro data do Line Extrapolation
// Parameter :
//           XYZArray: Gyro XYZ Data by Burn in . is an array
//           ReserveTemperatureArray: Gyro Temperature data by Burn in , is   an arrary
//           Temperature:Gyro temperature when init Gyro
//
- (double)LinearExtrapolation:(int)temperature
					 XYZArray:(double *)array
	  ReserveTemperatureArray:(int *)ReserveTemperatureArray
{
	double		tempB			= 0.0;
    //2011.07.11 Add by Ming
    NSNumber	*Temp_quantity	= [m_dicMemoryValues objectForKey:kIADevice_Gyro_iQuantity];
    int			quantity		= [Temp_quantity intValue];
	if (temperature < ReserveTemperatureArray[0]) 
	{
		//fly 2011.1.7 for qt1 crash
		if (0 == (ReserveTemperatureArray[1]
				  - ReserveTemperatureArray[0]))
			tempB	= 0.0;
		else 
			tempB = (array[0]
					 + (temperature - ReserveTemperatureArray[0])
					 / (ReserveTemperatureArray[1]
						- ReserveTemperatureArray[0])
					 * (array[1]-array[0]));
	}
	if (temperature > ReserveTemperatureArray[quantity]) 
	{
		if(0 == (ReserveTemperatureArray[quantity]
				 - ReserveTemperatureArray[quantity - 1]))
			tempB	= 0.0;
		else
		{
			tempB	= (array[quantity - 1]
					   + (temperature - ReserveTemperatureArray[quantity - 1])
					   / (ReserveTemperatureArray[quantity]
						  - ReserveTemperatureArray[quantity - 1])
					   * (array[quantity] - array[quantity - 1]));
		}
	}
	return tempB;	
}

//least square measurement
//add remark by desikan 2012.4.19
//Descripton: use the data get from gyro to do linear fitting
// Parameter :
//           Array:  Gyro data X/Y/Z by Burn in . is an array
//           Flag:(int) if not 0 return the max offset else return the slop of the line
- (double)Polifit:(double *)Array
			 Flag:(int)i
{
    double	dIntercept		= 0.0;
	double	dSlope			= 0.0;
	double	Sum				= 0.0;
	double	numerator		= 0.0;
	double	numSum			= 0.0;
    double	aver			= 0.0;
    double	dMaxOffset		= 0.0;
	double	dCurrentOffset	= 0.0;
    
    //2011.07.11 Add by Ming
    double		calcB		= 0.0;
    NSString	*szGyroTemp;
    double		GyroTemp;
    szGyroTemp	= [NSString stringWithFormat:@"%@",
				   [m_dicMemoryValues objectForKey:kIADevice_Gyro_GyroTemp]];
    GyroTemp	= [szGyroTemp doubleValue];
    
    //2011.07.11 Add by Ming
    NSNumber	*TempiGyroCount	= [m_dicMemoryValues objectForKey:
								   kIADevice_Gyro_Gyro_Count];
	int			iGyroCount		= [TempiGyroCount intValue];
    
    //2011.07.11 Add by Ming
    NSNumber	*TempgyroNum	= [m_dicMemoryValues objectForKey:
								   kIADevice_Gyro_Gyro_Num];
    int			gyroNum			= [TempgyroNum intValue];
    
    //2011.07.11 Add by Ming
    NSNumber	*temperatureValue;
    NSArray		*arrayTemperature	= [m_dicMemoryValues objectForKey:
									   kIADevice_Gyro_Temperature_Array];
    int	temperatureArray[50]; 
    memset(temperatureArray, 0, 50 * sizeof(int));    
    for (int j = 0; j < [arrayTemperature count]; j++)
    {
        temperatureValue	= [arrayTemperature objectAtIndex:j];
        temperatureArray[j]	= [temperatureValue intValue];
    }
    
    //2011.07.11 Add by Ming
    double		averTemp;
    NSNumber	*MyTemp	= [m_dicMemoryValues objectForKey:
						   kIADevice_Gyro_AverTemp];
    averTemp	= [MyTemp doubleValue];
    
    //2011.07.11 Add by Ming
    double	denoSum;
    MyTemp	= [m_dicMemoryValues objectForKey:
			   kIADevice_Gyro_DenoSum];
    denoSum	= [MyTemp doubleValue];
    
	if (gyroNum < iGyroCount)
		return -100.0;
	else
	{
		for(int i = 0; i < gyroNum/2 ; i++)
		{
			Sum	= Sum + Array[i];
		}
		aver	= Sum/(gyroNum/2);
		for(int i=0; i<gyroNum/2; i++)
		{
			numerator	= (temperatureArray[i] - averTemp) * (Array[i] - aver);
			numSum		= numSum+numerator;
		}
		if (denoSum == 0)
            dSlope	= 0;	// added by lucy 11-11-14
		else
            dSlope	= numSum / denoSum;	// added by lucy 11-11-14
        // added by lucy 11-11-14
        dIntercept	= aver - dSlope * averTemp;
		ATSDebug(@"The Formula: y = %f + %f * t", dIntercept, dSlope);
		calcB	= dIntercept + dSlope * GyroTemp;
        //2011.07.20 Add by Ming ,Set the calcB to Dictionary
        [m_dicMemoryValues setObject:[NSNumber numberWithDouble:calcB]
							  forKey:kIADevice_Gyro_calcB];
        for(int i=0; i<gyroNum/2; i++)
        {
			//	calulate each
            dCurrentOffset	= Array[i] - (dIntercept
										  + dSlope
										  * temperatureArray[i]);
            if(fabs(dMaxOffset) < fabs(dCurrentOffset))
                dMaxOffset	= dCurrentOffset;
        }  
    }
    if (i==0)
		return dSlope;
	else if(i == 1)
		return dMaxOffset;
    else 
        return dIntercept;
}

// Calibration Gyro Trend B ->X
// Param:
//      NSDictionary    *dicSettings        : Settings
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)Calc_Gyro_BX:(NSDictionary*)dicContents
			 ReturnValue:(NSMutableString*)strReturnValue
{
    double		temperatureArray[50];
    double		xArray[50];
	double		yArray[50];
	double		zArray[50];
    //2011.07.26 Modify by Ming
    int			quantity	= 0;
    double		averTemp;
    NSString	*szGyroFilePath;
    NSString	*szISNNUM;
    NSString	*szStartTime;
	double		calcBX;
	double		calcB;
	double		denoSum;
	int			gyroNum		= 0;
    BOOL		bIsHaveGyroPath;
    //2011.07.20 Add by Ming 
    NSMutableArray	*ArrayX				= [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray	*ArrayY				= [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray	*ArrayZ				= [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray	*arrayTemperature	= [[[NSMutableArray alloc] init] autorelease];
    ATSDebug(@"Calc_Gyro_BX");
	ATSDebug(@"%@", dicContents);
	//2011.07.20 Add by Ming ,Get dicContents settings
    NSNumber *TeamiGyroCount = [dicContents valueForKey:kIADevice_Gyro_Gyro_Count];
    int iGyroCount = [TeamiGyroCount intValue];
    //2011.07.20 Add by Ming ,Set the iGyroCount to Dictionary
    [m_dicMemoryValues setObject:TeamiGyroCount forKey:kIADevice_Gyro_Gyro_Count];
    
    szISNNUM    = [NSString stringWithFormat:@"%@", m_szISN];
    szStartTime = [NSString stringWithFormat:@"%@", m_szStartTime];
    
    memset(xArray, 0, 50 * sizeof(double));
	memset(yArray, 0, 50 * sizeof(double));
	memset(zArray, 0, 50 * sizeof(double));
	memset(temperatureArray, 0, 50 * sizeof(double));
	double	floatValue	= 0.0;
	double	tSum		= 0.0;
	int		iCount		= 0;
	int		jCount		= 0;
	double	denominator	= 0.0;
	double	gyroBX		= 0.0;
	NSMutableString	*tempString	= [[[NSMutableString alloc] init] autorelease];
	NSMutableString	*xString	= [[[NSMutableString alloc] init] autorelease];
	NSMutableString	*yString	= [[[NSMutableString alloc] init] autorelease];
	NSMutableString	*zString	= [[[NSMutableString alloc] init] autorelease];
	denoSum	= 0.0;
    NSString		*GyroData	= [NSString stringWithString:strReturnValue];
	[m_dicMemoryValues setObject:[NSNumber numberWithInt:gyroNum]
						  forKey:kIADevice_Gyro_Gyro_Num];
	if (![GyroData ContainString:@"0x"]) 
    {
		[strReturnValue setString:@"Cann't catch Burn In table!"];
		return [NSNumber numberWithBool:NO];
    }
    [GyroData stringByReplacingOccurrencesOfString:@"\n\r"
										withString:@""];
	NSArray	*array	= [GyroData componentsSeparatedByString:@" "];
    // Check with Howard, the raw data for the last value will loss, so -1 data. 
    gyroNum	= [array count] - 1;
    //2011.07.20 Add by Ming ,Set the gyroNum to Dictionary
    [m_dicMemoryValues setObject:[NSNumber numberWithInt:gyroNum]
						  forKey:kIADevice_Gyro_Gyro_Num];
    //2011.07.20 Mark by Ming
	if (gyroNum < iGyroCount) 
    {
		[strReturnValue setString:@"Cann't catch Burn In table!"];
		return [NSNumber numberWithBool:NO];;
	}
	else
	{
		for(int i=0; i<gyroNum; i=i+1)
		{
			NSString	*arrayString	= [array objectAtIndex:i];
			if([arrayString length] < 7)
				return [NSNumber numberWithBool:NO];
			floatValue	= [self convertHexToFloat:arrayString
											Flag:1];
			if (i % 2 == 0) 
            {
				temperatureArray[iCount]	= floatValue;
                //2011.07.20 Add by Ming, copy the temperatureArray[iCount] to NSArray arrayTemperature
                [arrayTemperature addObject:[NSNumber numberWithDouble:floatValue]];
				[tempString appendString:[NSString stringWithFormat:
										  @"%.0f ", temperatureArray[iCount]]];
				iCount++;
			}
			else
            {
				yArray[jCount]	= floatValue;
                //2011.07.20 Add by Ming
                [ArrayY addObject:[NSNumber numberWithDouble:floatValue]];
				[yString appendString:[NSString stringWithFormat:
									   @"%f ", yArray[jCount]]];
				jCount++;
			}
		}
        //2011.07.20 Add by Ming ,Set the ArrayY to Dictionary
        [m_dicMemoryValues setObject:ArrayY
							  forKey:kIADevice_Gyro_Array_Y];
		quantity	= jCount - 1;
        //2011.07.20 Add by Ming ,Set the quantity to Dictionary
        [m_dicMemoryValues setObject:[NSNumber numberWithInt:quantity]
							  forKey:kIADevice_Gyro_iQuantity];
		iCount	= 0;
		jCount	= 0;
		for(int i=1; i<=gyroNum; i=i+1)
		{
			NSString	*arrayString	= [array objectAtIndex:i];
			floatValue	= [self convertHexToFloat:arrayString
											Flag:0];
			if (i%2==0)
			{
				zArray[iCount]	= floatValue;
                //2011.07.20 Add by Ming
                [ArrayZ addObject:[NSNumber numberWithDouble:floatValue]];
				[zString appendString:[NSString stringWithFormat:
									   @"%f ", zArray[iCount]]];
				iCount++;
			}
			else
			{
				xArray[jCount]	= floatValue;
                // 2011.07.20 Add by Ming
                [ArrayX addObject:[NSNumber numberWithDouble:floatValue]];
				[xString appendString:[NSString stringWithFormat:
									   @"%f ", xArray[jCount]]];
				jCount++;
			}
		}
        //2011.07.20 Add by Ming ,Set the ArrayZ to Dictionary
        [m_dicMemoryValues setObject:ArrayZ
							  forKey:kIADevice_Gyro_Array_Z];
        //2011.07.20 Add by Ming ,Set the ArrayX to Dictionary
        [m_dicMemoryValues setObject:ArrayX
							  forKey:kIADevice_Gyro_Array_X];
		NSString	*gyroData	= [NSString stringWithFormat:
								   @"Temperature:%@\nX:%@\nY:%@\nZ:%@\n",
								   tempString,	xString,
								   yString,		zString];
        ATSDebug(@"gyroData = %@", gyroData);
		NSString	*Path	= @"/vault/Gyro/";
        //2011.07.20 Modify by Ming ,
        szGyroFilePath	= [NSString stringWithFormat:
						   @"%@Gyrodata_%@_%@.txt",
						   Path, szISNNUM, szStartTime];
        //2011.07.20 Add by Ming ,Set the sz_GyroPath to Dictionary
        [m_dicMemoryValues setObject:[NSString stringWithFormat:
									  @"%@", szGyroFilePath]
							  forKey:kIADevice_Gyro_GyroFilePath];
        //2011.07.20 Add by Ming ,Set the bIsHaveGyroPath to Dictionary
		bIsHaveGyroPath	= YES;
        [m_dicMemoryValues setObject:[NSString stringWithFormat:
									  @"%d", bIsHaveGyroPath]
							  forKey:kIADevice_Gyro_bIsHaveGyroPath];
        //2011.07.25 Add By Ming, check and Create the Path
        NSFileManager	*fileManager	= [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:Path])
            [fileManager createDirectoryAtPath:Path
				   withIntermediateDirectories:YES
									attributes:nil
										 error:nil];
		[gyroData writeToFile:szGyroFilePath
				   atomically:YES
					 encoding:1
						error:nil];
		//calculate	
        // 2011.07.26 Add by Ming, (gyroNum/2)= Gyro Calibration Values (Temp , X, Y, Z)
		for(int i=0; i<gyroNum/2; i++)
			tSum	= tSum + temperatureArray[i];
		averTemp	= tSum / (gyroNum / 2);
        //2011.07.20 Add by Ming ,Set the AverTemp to Dictionary
        [m_dicMemoryValues setObject:[NSNumber numberWithDouble:averTemp]
							  forKey:kIADevice_Gyro_AverTemp];
		for(int i=0; i<gyroNum/2; i++)
		{
			denominator	= ((temperatureArray[i] - averTemp)
						   * (temperatureArray[i] - averTemp));
			denoSum		= denoSum + denominator;
		}
        //2011.07.20 Add by Ming ,Set the denoSum to Dictionary
        [m_dicMemoryValues setObject:[NSNumber numberWithDouble:denoSum]
							  forKey:kIADevice_Gyro_DenoSum];
		gyroBX	= [self Polifit:xArray
						  Flag:1];
        //2011.07.11 Add by Ming, Get the calcB form Dictionary which the value comes from Function Polifit
        NSNumber	*TempcalcB	= [m_dicMemoryValues objectForKey:
								   kIADevice_Gyro_calcB];
        calcB	= [TempcalcB doubleValue];
		calcBX	= calcB;
        //2011.07.20 Add by Ming ,Set the calcBX to Dictionary
        [m_dicMemoryValues setObject:[NSNumber numberWithDouble:calcBX]
							  forKey:kIADevice_Gyro_calcBX];
        //2011.07.20 Add by Ming
        [strReturnValue setString:[NSString stringWithFormat:@"%f", gyroBX]];
        ATSDebug(@"GyroBX = %f", gyroBX);
		return [NSNumber numberWithBool:YES];	
	}
}

// Calibration Gyro Trend B ->Y
// Param:
//      NSDictionary    *dicSettings        : Settings
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)Calc_Gyro_BY:(NSDictionary*)dicContents
			 ReturnValue:(NSMutableString*)strReturnValue
{
    double			gyroBY	= 0.0;
    //2011.07.20 Add by Ming
    double			yArray[50];
    memset(yArray, 0, 50 * sizeof(double));
    NSNumber		*tempValue;
    NSMutableArray	*arraytempValue	= [m_dicMemoryValues objectForKey:
									   kIADevice_Gyro_Array_Y];
	int	iGyroNum	= [[m_dicMemoryValues objectForKey:
						kIADevice_Gyro_Gyro_Num] intValue];
	int	iGyroCount	= [[m_dicMemoryValues valueForKey:
						kIADevice_Gyro_Gyro_Count] intValue];
	if (iGyroNum < iGyroCount) 
    {
		[strReturnValue setString:@"Cann't catch Burn In table!"];
		return [NSNumber numberWithBool:NO];
	}
    for (int j = 0; j < [arraytempValue count]; j++ )
    {         
        tempValue	= [arraytempValue objectAtIndex:j];
        yArray[j]	= [tempValue doubleValue];    
    }
    //2011.07.20 Add by Ming
    double	calcBY	= 0.0;
	gyroBY	= [self Polifit:yArray
					  Flag:1];
    //2011.07.11 Add by Ming, Get the calcB form Dictionary which the value comes from Function Polifit
    double		calcB		= 0.0;
    NSNumber	*TempcalcB	= [m_dicMemoryValues objectForKey:
							   kIADevice_Gyro_calcB];
    calcB	= [TempcalcB doubleValue];
	calcBY	= calcB;
    //2011.07.20 Add by Ming ,Set the calcBY to Dictionary
    [m_dicMemoryValues setObject:[NSNumber numberWithDouble:calcBY]
						  forKey:kIADevice_Gyro_calcBY];
    //2011.07.20 Add by Ming
    [strReturnValue setString:[NSString stringWithFormat:@"%f", gyroBY]];
    ATSDebug(@"GyroBY = %f", gyroBY);
	return [NSNumber numberWithBool:YES];
}

// Calibration Gyro Trend B ->Z
// Param:
//      NSDictionary    *dicSettings        : Settings
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)Calc_Gyro_BZ:(NSDictionary*)dicContents
			 ReturnValue:(NSMutableString*)strReturnValue
{
	double			gyroBZ	= 0.0;
    //2011.07.20 Add by Ming
    double			zArray[50];
    memset(zArray, 0, 50 * sizeof(double));
    NSNumber		*tempValue;
    NSMutableArray	*arraytempValue	= [m_dicMemoryValues objectForKey:
									   kIADevice_Gyro_Array_Z];
	int	iGyroNum	= [[m_dicMemoryValues objectForKey:
						kIADevice_Gyro_Gyro_Num] intValue];
	int	iGyroCount	= [[m_dicMemoryValues valueForKey:
						kIADevice_Gyro_Gyro_Count] intValue];
	if (iGyroNum < iGyroCount) 
    {
		[strReturnValue setString:@"Cann't catch Burn In table!"];
		return [NSNumber numberWithBool:NO];
	}
    for (int j = 0; j < [arraytempValue count]; j++ )
    {         
        tempValue	= [arraytempValue objectAtIndex:j];
        zArray[j]	= [tempValue doubleValue];
    }
    //2011.07.20 Add by Ming
    double		calcBZ		= 0.0;
	gyroBZ	= [self Polifit:zArray
					  Flag:1];
    //2011.07.11 Add by Ming, Get the calcB form Dictionary which the value comes from Function Polifit
    double		calcB		= 0.0;
    NSNumber	*TempcalcB	= [m_dicMemoryValues objectForKey:
							   kIADevice_Gyro_calcB];
    calcB	= [TempcalcB doubleValue];
	calcBZ	= calcB;
    // 2011.07.20 Add by Ming ,Set the calcBZ to Dictionary
    [m_dicMemoryValues setObject:[NSNumber numberWithDouble:calcBZ]
						  forKey:kIADevice_Gyro_calcBZ];
    // 2011.07.20 Add by Ming
    [strReturnValue setString:[NSString stringWithFormat:@"%f", gyroBZ]];
    ATSDebug(@"GyroBZ = %f", gyroBZ);
	return [NSNumber numberWithBool:YES];
}

// Calibration Gyro Trend Q ->X
// Param:
//      NSDictionary    *dicSettings        : Settings
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)Calc_Gyro_QX:(NSDictionary*)dicContents
			 ReturnValue:(NSMutableString*)strReturnValue
{
    double		gyroQX			= 0.0;
    //2011.07.11 Add by Ming
    NSNumber	*TempgyroNum	= [m_dicMemoryValues objectForKey:
								   kIADevice_Gyro_Gyro_Num];
    int			gyroNum			= [TempgyroNum intValue];
    //2011.07.11 Add by Ming
    NSString	*szTempGyroX	= [m_dicMemoryValues objectForKey:
								   kIADevice_Gyro_GyroX];
	double		GyroX			= [szTempGyroX  doubleValue];
    ATSDebug(@"GyroX = %f", GyroX);
    //2011.07.11 Add by Ming
    NSNumber	*TempcalcBX		= [m_dicMemoryValues objectForKey:
								   kIADevice_Gyro_calcBX];
    double		calcBX;
    calcBX	= [TempcalcBX doubleValue];
	if (gyroNum<3) 
    {
        //2011.07.20 Add by Ming
        [strReturnValue setString:[NSString stringWithFormat:
								   @"%f", gyroQX]];
        ATSDebug(@"GyroQX = %f", gyroQX);
		return [NSNumber numberWithBool:NO];
	}
	else
    {
		gyroQX	= GyroX - calcBX;
        //2011.07.20 Add by Ming
        [strReturnValue setString:[NSString stringWithFormat:
								   @"%f", gyroQX]];
        ATSDebug(@"GyroQX = %f", gyroQX);
		return [NSNumber numberWithBool:YES];
	}
}

// Calibration Gyro Trend Q ->Y
// Param:
//      NSDictionary    *dicSettings        : Settings
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)Calc_Gyro_QY:(NSDictionary*)dicContents
			 ReturnValue:(NSMutableString*)strReturnValue
{
    double		gyroQY			= 0.0;
    //2011.07.20 Add by Ming
    NSNumber	*TeamiGyroCount	= [dicContents valueForKey:
								   kIADevice_Gyro_Gyro_Count];
    int			iGyroCount		= [TeamiGyroCount intValue];
    //2011.07.11 Add by Ming
    NSNumber	*TempgyroNum	= [m_dicMemoryValues objectForKey:
								   kIADevice_Gyro_Gyro_Num];
    int			gyroNum			= [TempgyroNum intValue]; 
    NSString	*szTempGyroY	= [m_dicMemoryValues objectForKey:
								   kIADevice_Gyro_GyroY];
	double		GyroY			= [szTempGyroY  doubleValue];
    ATSDebug(@"GyroY = %f", GyroY);
    
    //2011.07.11 Add by Ming
    NSNumber	*TempcalcBY	= [m_dicMemoryValues objectForKey:
							   kIADevice_Gyro_calcBY];
    double		calcBY;
    calcBY	= [TempcalcBY doubleValue];
	if (gyroNum < iGyroCount) 
    {
        //2011.07.20 Add by Ming
        [strReturnValue setString:[NSString stringWithFormat:@"%f", gyroQY]];
        ATSDebug(@"GyroQY = %f", gyroQY);
		return [NSNumber numberWithBool:NO];
	}else
    {
		gyroQY	= GyroY - calcBY;
        //2011.07.20 Add by Ming
        [strReturnValue setString:[NSString stringWithFormat:@"%f", gyroQY]];
        ATSDebug(@"GyroQY = %f", gyroQY);
		return [NSNumber numberWithBool:YES];
	}
}

// Calibration Gyro Trend Q ->Z
// Param:
//      NSDictionary    *dicSettings	: Settings
//      NSMutableString *strReturnValue	: Return value
-(NSNumber*)Calc_Gyro_QZ:(NSDictionary*)dicContents
			 ReturnValue:(NSMutableString*)strReturnValue
{
    double		gyroQZ			= 0.0;
    //2011.07.20 Add by Ming
    NSNumber	*TeamiGyroCount	= [dicContents valueForKey:
								   kIADevice_Gyro_Gyro_Count];
    int			iGyroCount		= [TeamiGyroCount intValue];
    //2011.07.11 Add by Ming
    NSNumber	*TempgyroNum	= [m_dicMemoryValues objectForKey:
								   kIADevice_Gyro_Gyro_Num];
    int			gyroNum			=[TempgyroNum intValue]; 
    NSString	*szTempGyroZ	= [m_dicMemoryValues objectForKey:
								   kIADevice_Gyro_GyroZ];
    double		GyroZ			= [ szTempGyroZ  doubleValue];
    ATSDebug(@"GyroZ = %f", GyroZ);
    //2011.07.11 Add by Ming
    NSNumber	*TempcalcBZ		= [m_dicMemoryValues objectForKey:
								   kIADevice_Gyro_calcBZ];
    double		calcBZ;
    calcBZ	= [TempcalcBZ doubleValue];
	if (gyroNum < iGyroCount) 
    {
        //2011.07.20 Add by Ming
        [strReturnValue setString:[NSString stringWithFormat:
								   @"%f", gyroQZ]];
        ATSDebug(@"GyroQZ = %f", gyroQZ);
		return [NSNumber numberWithBool:NO];
	}
	else
    {
		gyroQZ	= GyroZ - calcBZ;
        //2011.07.20 Add by Ming
        [strReturnValue setString:[NSString stringWithFormat:
								   @"%f", gyroQZ]];
        ATSDebug(@"GyroQZ = %f", gyroQZ);
		return [NSNumber numberWithBool:YES];
	}
}

//added by lucy
// Descripton: Get the index of the max temperature
// Param:
//      NSDictionary    *dicContents        : Settings
//      NSMutableString *strReturnValue     : Return value 
-(NSNumber*)GET_MAX_TEMP:(NSDictionary*)dicContents
			RETURN_VALUE:(NSMutableString*)strReturnValue
{
    double			doubleValue			= 0.0;
    NSMutableArray	*arrayTemperature	= [[NSMutableArray alloc] init];
    NSString		*szReturnValue		= [NSString stringWithString:strReturnValue];
    NSArray			*array				= [szReturnValue componentsSeparatedByString:@" "];
	int				gyroNum				= [array count] - 1;
    //prefect the max temperature algorithem  2012.2.7 andre  ---begin
    int				iCount				= 0;
    int				gyroCount			= [[dicContents valueForKey:
											kIADevice_Gyro_Gyro_Count] intValue];
	if (gyroNum < gyroCount) 
	{
		[strReturnValue setString:@"Cann't catch Burn In table!"];
        [arrayTemperature release];
        ATSDebug(@"the gyroNum is %i", gyroNum);
		return [NSNumber numberWithBool:NO];
	}
    else 
	{
		for(int i = 0; i<gyroNum-1; i++)
		{
			NSString	*arrayString	= [array objectAtIndex:i];
			if([arrayString length] < 7)
			{
                [arrayTemperature release];
				return [NSNumber numberWithBool:NO];
			}
            doubleValue	= [self convertHexToFloat:arrayString
											 Flag:1];
			if (i % 2 == 0) 
			{
                [arrayTemperature addObject:[NSNumber numberWithDouble:doubleValue]];
				iCount++;
			}
		}
        [m_dicMemoryValues setValue:arrayTemperature
							 forKey:kIADevice_Gyro_Temperature_Array];
	}
	int	iMaxTemp	= [[arrayTemperature objectAtIndex:0] intValue];
    int	iMinTemp	= [[arrayTemperature objectAtIndex:0] intValue];
	for(int iIndex = 0;
		(iIndex < iCount)
		&& [[arrayTemperature objectAtIndex:iIndex] intValue];
		iIndex++)
	{
		if (iMaxTemp < [[arrayTemperature objectAtIndex:iIndex] intValue])
			iMaxTemp	= [[arrayTemperature objectAtIndex:iIndex] intValue];
        if (iMinTemp > [[arrayTemperature objectAtIndex:iIndex] intValue]) 
            iMinTemp	= [[arrayTemperature objectAtIndex:iIndex] intValue];
		ATSDebug(@"%i", [[arrayTemperature objectAtIndex:iIndex] intValue]);
	}
    [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%d", iMinTemp]
						  forKey:kIADevice_Gyro_Min_Temp];
    [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%d", iMaxTemp]
						  forKey:kIADevice_Gyro_Max_Temp];
	[strReturnValue  setString:[NSString stringWithFormat:@"%d", iMaxTemp]];
    //prefect the max temperature algorithem  2012.2.7 andre  ---end
    [arrayTemperature release];
	return [NSNumber numberWithBool:YES];
}

// 2011-11-10 added by lucy
// Descripton: Get the index of the min temperature
// Param:
//      NSDictionary    *dicContents        : Settings
//      NSMutableString *strReturnValue     : Return value 
- (NSNumber*)GET_MIN_TEMP:(NSDictionary*)dicContents
			 RETURN_VALUE:(NSMutableString*)strReturnValue
{
	NSArray		*arrayTemp	= [m_dicMemoryValues objectForKey:
							   kIADevice_Gyro_Temperature_Array];
    double		temperatureArray[50]; 
    NSNumber	*temperatureValue;
    memset(temperatureArray, 0, 50 * sizeof(double));    
    for (int j = 0; j < [arrayTemp count]; j++)
    {         
        temperatureValue	= [arrayTemp objectAtIndex:j];
        temperatureArray[j]	= [temperatureValue doubleValue];    
    }
	int		iCountTemp	= sizeof(temperatureArray) / sizeof(double);
	double	dMinTemp	= temperatureArray[0];
	for(int iCount = 0;
		(iCount <= iCountTemp-1)
		&& temperatureArray[iCount];
		iCount++)
	{
		if (dMinTemp > temperatureArray[iCount])
			dMinTemp	= temperatureArray[iCount];
		ATSDebug(@"%lf", temperatureArray[iCount]);
	}
	
	[strReturnValue setString:[NSString stringWithFormat:
							   @"%lf", dMinTemp]];
	return [NSNumber numberWithBool:YES];
}

// 2011-11-10 added by lucy
// Descripton: Get the total count of   temperature that the value is not 0;
// Param:
//      NSDictionary    *dicContents        : Settings
//      NSMutableString *strReturnValue     : Return value 
- (NSNumber*)GET_COUNT_OF_TEMP:(NSDictionary*)dicContents
				  RETURN_VALUE:(NSMutableString*)strReturnValue
{  
    NSArray		*arrayTemp	= [m_dicMemoryValues objectForKey:
							   kIADevice_Gyro_Temperature_Array];
    double		temperatureArray[50]; 
    NSNumber	*temperatureValue;
    memset(temperatureArray, 0, 50 * sizeof(double));    
    for (int j = 0; j < [arrayTemp count]; j++)
    {         
        temperatureValue	= [arrayTemp objectAtIndex:j];
        temperatureArray[j]	= [temperatureValue doubleValue];
    }
    int	iCountTemp			= sizeof(temperatureArray) / sizeof(double);
	int	iCountTempOfGYTT	= 0; 
	for(int iCount = 0;
		(iCount <= iCountTemp-1) && temperatureArray[iCount];
		iCount++)
	{
		iCountTempOfGYTT++;
        ATSDebug(@"%i", iCountTempOfGYTT);
	}
    [strReturnValue setString:[NSString stringWithFormat:
							   @"%i", iCountTempOfGYTT]];
	return [NSNumber numberWithBool:YES];
}

// 2011-11-10 added by lucy
// Descripton: calcute the slope of x 
// Param:
//      NSDictionary    *dicContents        : Settings
//      NSMutableString *strReturnValue     : Return value 
- (NSNumber*)CALC_GYRO_SLOPEX:(NSDictionary*)dicContents
				 RETURN_VALUE:(NSMutableString*)strReturnValue
{
    NSArray		*arrayX	= [m_dicMemoryValues objectForKey:
						   kIADevice_Gyro_Array_X];
    double		xArray[50]; 
    NSNumber	*xValue;
    memset(xArray, 0, 50 * sizeof(double));  
	int	iGyroNum	= [[m_dicMemoryValues objectForKey:
						kIADevice_Gyro_Gyro_Num] intValue];
	int	iGyroCount	= [[m_dicMemoryValues valueForKey:
						kIADevice_Gyro_Gyro_Count] intValue];
	if (iGyroNum < iGyroCount) 
    {
		[strReturnValue setString:@"Cann't catch Burn In table!"];
		return [NSNumber numberWithBool:NO];
	}
    for (int j = 0; j < [arrayX count]; j++ )
    {         
        xValue		= [arrayX objectAtIndex:j];
        xArray[j]	= [xValue doubleValue];  
        ATSDebug(@"the index of %i is %@", j, xValue);
    }
    double	dGyroSlopeX	= 0.0;
	dGyroSlopeX	= [self Polifit:xArray
						   Flag:0];
    [strReturnValue setString:[NSString stringWithFormat:
							   @"%f", dGyroSlopeX]];
	return [NSNumber numberWithBool:YES];
}

// 2011-11-10 added by lucy
// Descripton: calcute the slope of y 
// Param:
//      NSDictionary    *dicContents        : Settings
//      NSMutableString *strReturnValue     : Return value 
- (NSNumber*)CALC_GYRO_SLOPEY:(NSDictionary*)dicContents
				 RETURN_VALUE:(NSMutableString*)strReturnValue
{
    NSArray		*arrayY	= [m_dicMemoryValues objectForKey:
						   kIADevice_Gyro_Array_Y];
    double		yArray[50]; 
    NSNumber	*yValue;
    memset(yArray, 0, 50*sizeof(double)); 
	int	iGyroNum	= [[m_dicMemoryValues objectForKey:
						kIADevice_Gyro_Gyro_Num] intValue];
	int	iGyroCount	= [[m_dicMemoryValues valueForKey:
						kIADevice_Gyro_Gyro_Count] intValue];
	if (iGyroNum < iGyroCount) 
    {
		[strReturnValue setString:@"Cann't catch Burn In table!"];
		return [NSNumber numberWithBool:NO];
	}
    for (int j = 0; j < [arrayY count]; j++ )
    {
        yValue		= [arrayY objectAtIndex:j];
        yArray[j]	= [yValue doubleValue];  
        ATSDebug(@"the index of %i is %@", j, yValue);
    }
	double	dGyroSlopeY	= 0.0;
	dGyroSlopeY	= [self Polifit:yArray
						   Flag:0];
    [strReturnValue setString:[NSString stringWithFormat:
							   @"%f", dGyroSlopeY]];
	return [NSNumber numberWithBool:YES];
}

// 2011-11-10 added by lucy
// Descripton: calcute the slope of z 
// Param:
//      NSDictionary    *dicContents        : Settings
//      NSMutableString *strReturnValue     : Return value 
- (NSNumber*)CALC_GYRO_SLOPEZ:(NSDictionary*)dicContents
				 RETURN_VALUE:(NSMutableString*)strReturnValue
{
    NSArray		*arrayZ	= [m_dicMemoryValues objectForKey:
						   kIADevice_Gyro_Array_Z];
    double		zArray[50]; 
    NSNumber	*zValue;
    memset(zArray, 0, 50 * sizeof(double));   
	int	iGyroNum	= [[m_dicMemoryValues objectForKey:
						kIADevice_Gyro_Gyro_Num] intValue];
	int	iGyroCount	= [[m_dicMemoryValues valueForKey:
						kIADevice_Gyro_Gyro_Count] intValue];
	if (iGyroNum < iGyroCount) 
    {
		[strReturnValue setString:@"Cann't catch Burn In table!"];
		return [NSNumber numberWithBool:NO];
	}
    for (int j = 0; j < [arrayZ count]; j++ )
    {         
        zValue		= [arrayZ objectAtIndex:j];
        zArray[j]	= [zValue doubleValue];  
        ATSDebug(@"the index of %i is %@", j, zValue);
    }
	double	dGyroSlopeZ	= 0.0;
	dGyroSlopeZ	= [self Polifit:zArray
						   Flag:0];
    [strReturnValue setString:[NSString stringWithFormat:
							   @"%f", dGyroSlopeZ]];
	return [NSNumber numberWithBool:YES];
}

//2012-08-27 added by betty
// Descripton: calcute the slope of x 
// Param:
//      NSDictionary    *dicContents        : Settings
//      NSMutableString *strReturnValue     : Return value 
- (NSNumber*)CALC_GYRO_OFFSETX:(NSDictionary*)dicContents
				  RETURN_VALUE:(NSMutableString*)strReturnValue
{
    NSArray		*arrayX	= [m_dicMemoryValues objectForKey:
						   kIADevice_Gyro_Array_X];
    double		xArray[50]; 
    NSNumber	*xValue;
    memset(xArray, 0, 50 * sizeof(double));  
	int	iGyroNum	= [[m_dicMemoryValues objectForKey:
						kIADevice_Gyro_Gyro_Num] intValue];
	int	iGyroCount	= [[m_dicMemoryValues valueForKey:
						kIADevice_Gyro_Gyro_Count] intValue];
	if (iGyroNum < iGyroCount) 
    {
		[strReturnValue setString:@"Cann't catch Burn In table!"];
		return [NSNumber numberWithBool:NO];
	}
    for (int j = 0; j < [arrayX count]; j++ )
    {         
        xValue		= [arrayX objectAtIndex:j];
        xArray[j]	= [xValue doubleValue];  
        ATSDebug(@"the index of %i is %@", j, xValue);
    }
    double dGyroOffsetX=0.0;
	dGyroOffsetX = [self Polifit:xArray
							Flag:2];
    [strReturnValue setString:[NSString stringWithFormat:
							   @"%f", dGyroOffsetX]];
	return [NSNumber numberWithBool:YES];
}

// 2012-08-27 added by betty
// Descripton: calcute the slope of y 
// Param:
//      NSDictionary    *dicContents        : Settings
//      NSMutableString *strReturnValue     : Return value 
- (NSNumber*)CALC_GYRO_OFFSETY:(NSDictionary*)dicContents
				  RETURN_VALUE:(NSMutableString*)strReturnValue
{
    NSArray		*arrayY	= [m_dicMemoryValues objectForKey:
						   kIADevice_Gyro_Array_Y];
    double		yArray[50]; 
    NSNumber	*yValue;
    memset(yArray, 0, 50 * sizeof(double)); 
	int	iGyroNum	= [[m_dicMemoryValues objectForKey:
						kIADevice_Gyro_Gyro_Num] intValue];
	int	iGyroCount	= [[m_dicMemoryValues valueForKey:
						kIADevice_Gyro_Gyro_Count] intValue];
	if (iGyroNum < iGyroCount) 
    {
		[strReturnValue setString:@"Cann't catch Burn In table!"];
		return [NSNumber numberWithBool:NO];
	}
    for (int j = 0; j < [arrayY count]; j++ )
    {         
        yValue		= [arrayY objectAtIndex:j];
        yArray[j]	= [yValue doubleValue];  
        ATSDebug(@"the index of %i is %@", j, yValue);
    }
	double	dGyroOffsetY	= 0.0;
	dGyroOffsetY	= [self Polifit:yArray
							Flag:2];
    [strReturnValue setString:[NSString stringWithFormat:
							   @"%f", dGyroOffsetY]];
	return [NSNumber numberWithBool:YES];
    
}
// 2012-08-27 added by betty
// Descripton: calcute the offset of z 
// Param:
//      NSDictionary    *dicContents        : Settings
//      NSMutableString *strReturnValue     : Return value 
- (NSNumber*)CALC_GYRO_OFFSETZ:(NSDictionary*)dicContents
				  RETURN_VALUE:(NSMutableString*)strReturnValue
{
    NSArray		*arrayZ	= [m_dicMemoryValues objectForKey:
						   kIADevice_Gyro_Array_Z];
    double		zArray[50]; 
    NSNumber	*zValue;
    memset(zArray, 0, 50 * sizeof(double));   
	int	iGyroNum	= [[m_dicMemoryValues objectForKey:
						kIADevice_Gyro_Gyro_Num] intValue];
	int	iGyroCount	= [[m_dicMemoryValues valueForKey:
						kIADevice_Gyro_Gyro_Count] intValue];
	if (iGyroNum < iGyroCount) 
    {
		[strReturnValue setString:@"Cann't catch Burn In table!"];
		return [NSNumber numberWithBool:NO];
	}
    for (int j = 0; j < [arrayZ count]; j++ )
    {         
        zValue		= [arrayZ objectAtIndex:j];
        zArray[j]	= [zValue doubleValue];  
        ATSDebug(@"the index of %i is %@", j, zValue);
    }
	double	dGyroOffsetZ	= 0.0;
	dGyroOffsetZ	= [self Polifit:zArray
							Flag:2];
    [strReturnValue setString:[NSString stringWithFormat:
							   @"%f", dGyroOffsetZ]];
	return [NSNumber numberWithBool:YES];
}

@end




