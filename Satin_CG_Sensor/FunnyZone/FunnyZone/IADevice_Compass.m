//  IADevice_Compass.m
//  Izual_Lu
//
//  Created by Lu Izual on 11-5-5.
//  Copyright 2011年 PEGATRON. All rights reserved.



#import "IADevice_Compass.h"



static NSLock	*gs_lockVCM	= nil;



@implementation TestProgress (IADevice_Compass)

//Start 2011.11.03 Add by Ming 
// Descripton: Get the Compass's data, and put those value in dictionary
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)GETDATA_SENSITIVITY:(NSDictionary*)dicContents
				   RETURN_VALUE:(NSMutableString*)strReturnValue
{
    NSArray	*arraySEN;
	double	doubleSEN_X	= 0;
	double	doubleSEN_Y	= 0;
	double	doubleSEN_Z	= 0;
	if([m_dicMemoryValues valueForKey:@"Sensitivity"])
	{
		arraySEN	= [[m_dicMemoryValues valueForKey:@"Sensitivity"]
					   componentsSeparatedByString:@","];
		if([arraySEN count] >= 3)
		{
			doubleSEN_X	= [ [arraySEN objectAtIndex:0] doubleValue];
			doubleSEN_Y	= [ [arraySEN objectAtIndex:1] doubleValue];
			doubleSEN_Z	= [ [arraySEN objectAtIndex:2] doubleValue];
            //new 
            if (doubleSEN_X <0)
                doubleSEN_X	+= 256;
            if (doubleSEN_Y <0)
                doubleSEN_Y	+= 256;
            if (doubleSEN_Z <0)
                doubleSEN_Z	+= 256;
            
            [m_dicMemoryValues setValue:[NSNumber numberWithDouble:doubleSEN_X]
								 forKey:[NSString stringWithFormat:@"COMPASS_SEN_X"]];
			[m_dicMemoryValues setValue:[NSNumber numberWithDouble:doubleSEN_Y]
								 forKey:[NSString stringWithFormat:@"COMPASS_SEN_Y"]];
			[m_dicMemoryValues setValue:[NSNumber numberWithDouble:doubleSEN_Z]
								 forKey:[NSString stringWithFormat:@"COMPASS_SEN_Z"]];
		}
	    else
		{
            [strReturnValue setString:@"Comapss Init Fail"];
			return [NSNumber numberWithBool:NO];
		}
	}
	else
	{
        [strReturnValue setString:@"Get Comapss Init Data Fail"];
        return [NSNumber numberWithBool:NO];
	}
	[strReturnValue setString:@"Get Comapss Sensity Data Succeed!"];
    return [NSNumber numberWithBool:YES];
}

#ifndef N61_Project
#define N61_Project 1
#endif

#if N61_Project
/*Add by soshon_ran 2011-08-04
 description	:	caculate a array standard deviation
 Parameter: 
 arrTemp	:	The array will calculate 
 szReturnValue:	The standard deviation of the array*/
- (bool)Cal_STD:(NSArray *)arrTemp
	ReturnValue:(NSString **)szReturnValue
{
	
	double	doubleTemp	= 0.0;
	double	doubleSum1	= 0.0;
	double	doubleSum2	= 0.0;
	for(int i=0; i<[arrTemp count]; i++)
	{
		doubleTemp	= [[arrTemp objectAtIndex:i] doubleValue];
		doubleSum1	+= doubleTemp*doubleTemp;
		doubleSum2	+= doubleTemp;
		
	}
	NSInteger		iCount	= [arrTemp count];
	double	fResult	= sqrt(((iCount * doubleSum1 - doubleSum2 * doubleSum2)
							/ (iCount * iCount * 1.0)));
	*szReturnValue	= [NSString stringWithFormat:@"%f",fResult];
	return YES; 
}
#else
- (bool)Cal_STD:(NSArray *)arrTemp
	ReturnValue:(NSString **)szReturnValue
{
	
	double	doubleTemp	= 0.0;
	double	doubleSum1	= 0.0;
	double	doubleSum2	= 0.0;
	for(int i=0; i<[arrTemp count]; i++)
	{
		doubleTemp	= [[arrTemp objectAtIndex:i] doubleValue];
		doubleSum1	+= doubleTemp*doubleTemp;
		doubleSum2	+= doubleTemp;
		
	}
	int		iCount	= [arrTemp count];
	double	fResult	= sqrt(((iCount * doubleSum1 - doubleSum2 * doubleSum2)
							/ (iCount * (iCount - 1) * 1.0)));
	*szReturnValue	= [NSString stringWithFormat:@"%f",fResult];
	return YES;
}
#endif

#if 0
//Start 2011.11.03 Add by Ming 
// Descripton:1.skip first two point 
//            2.save average and standard deviation to a array for "baseline,back,front,back_115,back_230"and so on!
//              The type is depended by the value of the dictionary .
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)COMPASS_SAMPLE:(NSDictionary*)dicContents
			  RETURN_VALUE:(NSMutableString*)strReturnValue
{
    int			istart	= [[dicContents valueForKey:@"STARTFROM"] intValue];
    NSString	*szTYPE	= [dicContents valueForKey:@"VALUE"];
	int			count	= [[dicContents valueForKey:@"COUNT"] intValue];
    ATSDebug(@"Hello,I am CompassSample!  szTYPE is %@",szTYPE);
	NSArray			*arrayRawData;
	NSArray			*arrayRawDataItem[count];
	NSMutableArray	*arrayCompassDataX	= [[NSMutableArray alloc] init];
	NSMutableArray	*arrayCompassDataY	= [[NSMutableArray alloc] init];
	NSMutableArray	*arrayCompassDataZ	= [[NSMutableArray alloc] init];
	double	doubleAverageX		= 0;
	double	doubleAverageY		= 0;
	double	doubleAverageZ		= 0;
    double	dCompassAverage_X	= 0;
	double	dCompassAverage_Y	= 0;
	double	dCompassAverage_Z	= 0;
    double	dCompassData_X		= 0;
	double	dCompassData_Y		= 0;
	double	dCompassData_Z		= 0;
	double	doubleSEN_X			= [[m_dicMemoryValues valueForKey:
									@"COMPASS_SEN_X"] doubleValue];
	double  doubleSEN_Y			= [[m_dicMemoryValues valueForKey:
									@"COMPASS_SEN_Y"] doubleValue];
	double  doubleSEN_Z			= [[m_dicMemoryValues valueForKey:
									@"COMPASS_SEN_Z"] doubleValue];
	
	if([strReturnValue length] >= 10)
	{
		[strReturnValue		setString:[strReturnValue	stringByReplacingOccurrencesOfString:@" " withString:@""]];
		arrayRawData	= [strReturnValue componentsSeparatedByString:@"\n"];
		if([arrayRawData count] >= count)
		{
			for(int i = istart; i <  count;i++)
			{
				arrayRawDataItem[i]	= [[[arrayRawData objectAtIndex:i] SubFrom:@"=" include:NO]
									   componentsSeparatedByString:@","];
				if ([arrayRawDataItem[i] count] >= 4)
				{
					if([arrayRawDataItem[i] count] == 4)
					{
						dCompassData_X	= [[arrayRawDataItem[i] objectAtIndex:0]
										   doubleValue];
						dCompassData_Y	= [[arrayRawDataItem[i] objectAtIndex:1]
										   doubleValue];
						dCompassData_Z	= [[arrayRawDataItem[i] objectAtIndex:2]
										   doubleValue];
					}
//					else if([arrayRawDataItem[i] count] == 5)
//					{
//						dCompassData_X	= [[arrayRawDataItem[i] objectAtIndex:2]
//										   doubleValue];
//						dCompassData_Y	= [[arrayRawDataItem[i] objectAtIndex:3]
//										   doubleValue];
//						dCompassData_Z	= [[arrayRawDataItem[i] objectAtIndex:4]
//										   doubleValue];
//					}
                    dCompassAverage_X	+= dCompassData_X / (count - istart) * 1.0;
                    dCompassAverage_Y	+= dCompassData_Y / (count - istart) * 1.0;
                    dCompassAverage_Z	+= dCompassData_Z / (count - istart) * 1.0;
					
					dCompassData_X	= (((doubleSEN_X - 128.0) * 0.5 / 128.0 + 1)
									   * dCompassData_X);
					dCompassData_Y	= (((doubleSEN_Y - 128.0) * 0.5 / 128.0 + 1)
									   * dCompassData_Y);
					dCompassData_Z	= (((doubleSEN_Z - 128.0) * 0.5 / 128.0 + 1)
									   * dCompassData_Z);
					doubleAverageX	+= dCompassData_X;
					doubleAverageY	+= dCompassData_Y;
					doubleAverageZ	+= dCompassData_Z;
					[arrayCompassDataX addObject:[NSNumber numberWithDouble:dCompassData_X]];
					[arrayCompassDataY addObject:[NSNumber numberWithDouble:dCompassData_Y]];
					[arrayCompassDataZ addObject:[NSNumber numberWithDouble:dCompassData_Z]];
				}
				else
				{
					[strReturnValue setString: @"Get Comapss Raw Data Fail"];
					[arrayCompassDataX release];
					[arrayCompassDataY release];
					[arrayCompassDataZ release];
					return [NSNumber numberWithBool:NO];
				}
			}
			/*caculate the average*/
			doubleAverageX	/= (count - istart) * 1.0;
			doubleAverageY	/= (count - istart) * 1.0;
			doubleAverageZ	/= (count - istart) * 1.0;
			if([szTYPE isEqualToString:@"COMPASS_1"])
			{
				[m_dicMemoryValues setValue:[NSString stringWithFormat:
											 @"%.6f", doubleAverageX ]
									 forKey:@"Compass_1_Baseline_X"];
                [m_dicMemoryValues setValue:[NSString stringWithFormat:
											 @"%.6f", dCompassAverage_X]
									 forKey:@"Compass_RAW_X_Average"];
				[m_dicMemoryValues setValue:[NSString stringWithFormat:
											 @"%.6f", doubleAverageY ]
									 forKey:@"Compass_1_Baseline_Y"];
                [m_dicMemoryValues setValue:[NSString stringWithFormat:
											 @"%.6f", dCompassAverage_Y]
									 forKey:@"Compass_RAW_Y_Average"];
				[m_dicMemoryValues setValue:[NSString stringWithFormat:
											 @"%.6f", doubleAverageZ ]
									 forKey:@"Compass_1_Baseline_Z"];
                [m_dicMemoryValues setValue:[NSString stringWithFormat:
											 @"%.6f", dCompassAverage_Z]
									 forKey:@"Compass_RAW_Z_Average"];
                [arrayCompassDataX release];
                [arrayCompassDataY release];
                [arrayCompassDataZ release];
                return [NSNumber numberWithBool:YES];
			}
			//define BA for coco decision standing for the value  when south open
			else if([szTYPE isEqualToString:@"BA"]
					||[szTYPE isEqualToString:@"AA"]
					||[szTYPE isEqualToString:@"NORMAL"])
				// define AA for coco decision standing for the value when north opne
            {
                double	dCompassNMS	= sqrt(pow(doubleAverageX, 2)
										   + pow(doubleAverageY, 2)
										   + pow(doubleAverageZ, 2));
                [m_dicMemoryValues setValue:[NSArray arrayWithObjects:
											 [NSNumber numberWithDouble:doubleAverageX],
											 [NSNumber numberWithDouble:doubleAverageY],
											 [NSNumber numberWithDouble:doubleAverageZ], nil]
									 forKey:[NSString stringWithFormat:
											 KIADeviceKey_COMPASS_FIELD]];
                [m_dicMemoryValues setValue:[NSString stringWithFormat:
											 @"%.6f", doubleAverageX]
									 forKey:[NSString stringWithFormat:
											 @"COMPASS_X_%@", szTYPE]];
                [m_dicMemoryValues setValue:[NSString stringWithFormat:
											 @"%.6f", dCompassAverage_X]
									 forKey:[NSString stringWithFormat:
											 @"Compass_1_RAW_%@_X_Average", szTYPE]];
                [m_dicMemoryValues setValue:[NSString stringWithFormat:
											 @"%.6f", doubleAverageY]
									 forKey:[NSString stringWithFormat:
											 @"COMPASS_Y_%@", szTYPE]];
                [m_dicMemoryValues setValue:[NSString stringWithFormat:
											 @"%.6f", dCompassAverage_Y]
									 forKey:[NSString stringWithFormat:
											 @"Compass_1_RAW_%@_Y_Average", szTYPE]];
                [m_dicMemoryValues setValue:[NSString stringWithFormat:
											 @"%.6f", doubleAverageZ]
									 forKey:[NSString stringWithFormat:
											 @"COMPASS_Z_%@", szTYPE]];
                [m_dicMemoryValues setValue:[NSString stringWithFormat:
											 @"%.6f", dCompassAverage_Z]
									 forKey:[NSString stringWithFormat:
											 @"Compass_1_RAW_%@_Z_Average", szTYPE]];
                [m_dicMemoryValues setValue:[NSString stringWithFormat:
											 @"%.6f", dCompassNMS]
									 forKey:[NSString stringWithFormat:
											 @"%@_M", szTYPE]];
                ATSDebug(@"Calculate field[%@_M] with compass data[%@],result[%f].",
						 szTYPE, KIADeviceKey_COMPASS_FIELD, dCompassNMS);
                [arrayCompassDataX release];
                [arrayCompassDataY release];
                [arrayCompassDataZ release];
                return [NSNumber numberWithBool:YES];
            }
            else 
            {
                [strReturnValue setString:@"Get Compass Data failed!"];
                //andre modified new code
                [arrayCompassDataX release];
                [arrayCompassDataY release];
                [arrayCompassDataZ release];
                return [NSNumber numberWithBool:NO];
            }
        }
        else 
        {
            [strReturnValue setString:@"Compass init failed!"];
            [arrayCompassDataX release];
            [arrayCompassDataY release];
            [arrayCompassDataZ release];
            return [NSNumber numberWithBool:NO];
        }
    }
    else
    {
        ATSDebug(@"worng return value");
        [arrayCompassDataX release];
        [arrayCompassDataY release];
        [arrayCompassDataZ release];
        return [NSNumber numberWithBool:NO];
    }
}
#else
-(NSNumber*)COMPASS_SAMPLE:(NSDictionary*)dicContents
               RETURN_VALUE:(NSMutableString*)strReturnValue
{
    int			istart	= [[dicContents valueForKey:@"STARTFROM"] intValue];
    NSString	*szTYPE	= [dicContents valueForKey:@"VALUE"];
    //  ATSDebug(@"Hello,I am CompassSample!  szTYPE is %@",szTYPE);
    NSString        *szSTD;
	NSArray			*arrayRawData;
	NSMutableArray	*arrayCompassDataX	= [[NSMutableArray alloc] init];
	NSMutableArray	*arrayCompassDataY	= [[NSMutableArray alloc] init];
	NSMutableArray	*arrayCompassDataZ	= [[NSMutableArray alloc] init];
	double	doubleAverageX		= 0;
	double	doubleAverageY		= 0;
	double	doubleAverageZ		= 0;
    double	dCompassStd_X       = 0;
	double	dCompassStd_Y       = 0;
	double	dCompassStd_Z       = 0;
    double	dCompassData_X		= 0;
	double	dCompassData_Y		= 0;
	double	dCompassData_Z		= 0;
	if([strReturnValue length] >= 10)
	{
		[strReturnValue		setString:[strReturnValue	stringByReplacingOccurrencesOfString:@" " withString:@""]];
		arrayRawData	= [strReturnValue componentsSeparatedByString:@"\n"];
        NSInteger iCount = [arrayRawData count] - 1;
        NSArray *arrayRawDataItem[iCount];
		if([arrayRawData count] >= iCount)
		{
			for(int i = istart; i <  iCount;i++)
			{
				arrayRawDataItem[i]	= [[[arrayRawData objectAtIndex:i] SubFrom:@"=" include:NO]
									   componentsSeparatedByString:@","];
				if ([arrayRawDataItem[i] count] >= 4)
				{
                    dCompassData_X	= [[arrayRawDataItem[i] objectAtIndex:0]
                                       doubleValue];
                    dCompassData_Y	= [[arrayRawDataItem[i] objectAtIndex:1]
                                       doubleValue];
                    dCompassData_Z	= [[arrayRawDataItem[i] objectAtIndex:2]
                                       doubleValue];
					doubleAverageX	+= dCompassData_X;
					doubleAverageY	+= dCompassData_Y;
					doubleAverageZ	+= dCompassData_Z;
					[arrayCompassDataX addObject:[NSNumber numberWithDouble:dCompassData_X]];
					[arrayCompassDataY addObject:[NSNumber numberWithDouble:dCompassData_Y]];
					[arrayCompassDataZ addObject:[NSNumber numberWithDouble:dCompassData_Z]];
				}
				else
				{
					[strReturnValue setString: @"Get Comapss Raw Data Fail"];
					[arrayCompassDataX release];
					[arrayCompassDataY release];
					[arrayCompassDataZ release];
					return [NSNumber numberWithBool:NO];
				}
			}
			/*caculate the average*/
			doubleAverageX	/= (iCount - istart) * 1.0;
			doubleAverageY	/= (iCount - istart) * 1.0;
			doubleAverageZ	/= (iCount - istart) * 1.0;
            [self Cal_STD:[NSArray arrayWithArray: arrayCompassDataX] ReturnValue:&szSTD];
            dCompassStd_X = [szSTD doubleValue];
            [self Cal_STD:[NSArray arrayWithArray: arrayCompassDataY] ReturnValue:&szSTD];
            dCompassStd_Y = [szSTD doubleValue];
            [self Cal_STD:[NSArray arrayWithArray: arrayCompassDataZ] ReturnValue:&szSTD];
            dCompassStd_Z = [szSTD doubleValue];
            [m_dicMemoryValues setValue:[NSString stringWithFormat:@"%.6f", doubleAverageX]
                                 forKey:[NSString stringWithFormat:@"Compass_X_%@", szTYPE]];
            [m_dicMemoryValues setValue:[NSString stringWithFormat:@"%.6f", dCompassStd_X]
                                 forKey:[NSString stringWithFormat:@"Compass_X_Std_%@", szTYPE]];
            [m_dicMemoryValues setValue:[NSString stringWithFormat:@"%.6f", doubleAverageY]
                                 forKey:[NSString stringWithFormat:@"Compass_Y_%@", szTYPE]];
            [m_dicMemoryValues setValue:[NSString stringWithFormat:@"%.6f", dCompassStd_Y]
                                 forKey:[NSString stringWithFormat:@"Compass_Y_Std_%@", szTYPE]];
            [m_dicMemoryValues setValue:[NSString stringWithFormat:@"%.6f", doubleAverageZ]
                                 forKey:[NSString stringWithFormat:@"Compass_Z_%@", szTYPE]];
            [m_dicMemoryValues setValue:[NSString stringWithFormat:@"%.6f", dCompassStd_Z]
                                 forKey:[NSString stringWithFormat:@"Compass_Z_Std_%@", szTYPE]];
            if([szTYPE isEqualToString:@"BA"]||[szTYPE isEqualToString:@"AA"]||[szTYPE isEqualToString:@"NORMAL"])
            {
                double	dCompassNMS	= sqrt(pow(doubleAverageX, 2) + pow(doubleAverageY, 2) + pow(doubleAverageZ, 2));
                [m_dicMemoryValues setValue:[NSString stringWithFormat:
											 @"%.6f", dCompassNMS]
									 forKey:[NSString stringWithFormat:
											 @"%@_M", szTYPE]];
            }
            
            [arrayCompassDataX release];
            [arrayCompassDataY release];
            [arrayCompassDataZ release];
            return [NSNumber numberWithBool:YES];
        }
        else
        {
            [strReturnValue setString:@"Compass init failed!"];
            [arrayCompassDataX release];
            [arrayCompassDataY release];
            [arrayCompassDataZ release];
            return [NSNumber numberWithBool:NO];
        }
    }
    else
    {
        //    ATSDebug(@"worng return value");
        [arrayCompassDataX release];
        [arrayCompassDataY release];
        [arrayCompassDataZ release];
        return [NSNumber numberWithBool:NO];
    }
}
#endif

//calculate compass_M

-(NSNumber *)CAL_COMPASS_M:(NSDictionary*)dicsetting
              RETURN_VALUE:(NSMutableString *)szReturnvalue
{
    double doubleAverageX = [[m_dicMemoryValues objectForKey:[dicsetting objectForKey:@"Key1"]]doubleValue];
    double doubleAverageY = [[m_dicMemoryValues objectForKey:[dicsetting objectForKey:@"Key2"]]doubleValue];
    double doubleAverageZ = [[m_dicMemoryValues objectForKey:[dicsetting objectForKey:@"Key3"]]doubleValue];
    double	dCompassNMS	= sqrt(pow(doubleAverageX, 2)+pow(doubleAverageY, 2)+pow(doubleAverageZ, 2));
    [szReturnvalue setString:[NSString stringWithFormat:@"%.6f",dCompassNMS]];
    ATSDebug(@"%f,%f,%f",doubleAverageX,doubleAverageY,doubleAverageZ);
    return [NSNumber numberWithBool:YES];
}

//Start 2012.01.31 Add by Sunny
// Descripton:1.save average and standard deviation to
//            2.Calculate Prox,Centerpoint,Temp,Prox_Adj,SD_Adj,Temp_Adj,Ref,OFFSET of four status (Baseline,90Degree,0Degree,180Degree)
//			  3.Write PBCl,PBTb,PBTa to DUT.
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)PROXBASELINETEST:(NSDictionary*)dicContents
				RETURN_VALUE:(NSMutableString*)strReturnValue
{
    int			iCount		= [[dicContents valueForKey:@"Count"] intValue];
    NSString	*szDegree	= [dicContents valueForKey:@"Degree"];
	NSString	*szSlot		= [dicContents valueForKey:@"slot"];
    double		dBaselineProx			= 0.0,
				dBaselineCenterpoint	= 0.0,
				dBaselineTemp			= 0.0,
				dBaselineProx_Adj		= 0.0,
				dBaselineSD_Adj			= 0.0,
				dBaselineTemp_Adj		= 0.0,
				dBaselineRef			= 0.0,
				dOFFSET					= 0.0,
				dAverageStage[12]		= {0},
				dSDStage[12]			= {0};
	int			iDelta					= 0;
    NSString	*szSTD;
    NSArray		*arrayRowData;
    NSArray		*arraySensorReadingValue[iCount];
    NSString		*strRowData			= @"";
    NSMutableArray	*arrayProx_Adj		= [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray	*arrayStageData[12];
	
    for (int a=0; a<=11; a++)
        arrayStageData[a]	= [[[NSMutableArray alloc] init] autorelease];
	
    //start to get the data.
    if (strReturnValue != nil)
    {
        arrayRowData	= [strReturnValue componentsSeparatedByString:@"\n"];
		ATSDebug(@"%lu", (unsigned long)[arrayRowData count]);
        if ([arrayRowData count] >= iCount)
        {
            for (int i = 0; i < iCount; i++)
            {
                strRowData	= [arrayRowData objectAtIndex:i];
                //catch the sensor reading data.
                NSString	*szSensorReadingValue	= [self catchFromString:strRowData
																 begin:@"Sensor Reading: "
																   end:@" -"
														TheRightString:NO];
                if (![szSensorReadingValue isKindOfClass:[NSString class]]
					|| [szSensorReadingValue isEqualToString:@""])
                {
                    ATSDebug(@"CATCH_VALUE => Catch Fail : Can't Find begin string [Sensor Reading: ] or end string [ -].");
                    return [NSNumber numberWithBool:NO];
                }
                else
                    arraySensorReadingValue[i]	= [szSensorReadingValue
												   componentsSeparatedByString:@", "];
                //catch the prox
                NSString	*szProx	= [self catchFromString:strRowData
												   begin:@"Prox: "
													 end:@","
										  TheRightString:NO];
                if (![szProx isKindOfClass:[NSString class]]
					|| [szProx isEqualToString:@""])
                {
                    ATSDebug(@"CATCH_VALUE => Catch Fail : Can't Find begin string [Prox: ] or end string [,].");
                    return [NSNumber numberWithBool:NO];
                }
                else
                    dBaselineProx	+= [szProx doubleValue];
                
                //catch the Centerpoint.
                NSString	*szCenterpoint	= [self catchFromString:strRowData
														  begin:@"Centerpoint: "
															end:@","
												 TheRightString:NO];
                if (![szCenterpoint isKindOfClass:[NSString class]]
					|| [szCenterpoint isEqualToString:@""])
                {
                    ATSDebug(@"CATCH_VALUE => Catch Fail : Can't Find begin string [Centerpoint: ] or end string [,].");
                    return [NSNumber numberWithBool:NO];
                }
                else
                    dBaselineCenterpoint	+= [szCenterpoint doubleValue];
                
                //catch the Temp.
                NSString	*szTemp	= [self catchFromString:strRowData
												   begin:@"Temp: "
													 end:@","
										  TheRightString:NO];
                if (![szTemp isKindOfClass:[NSString class]]
					|| [szTemp isEqualToString:@""])
                {
                    ATSDebug(@"CATCH_VALUE => Catch Fail : Can't Find begin string [Temp: ] or end string [,].");
                    return [NSNumber numberWithBool:NO];
                }
                else
                    dBaselineTemp	+= [szTemp doubleValue];
                
                //catch the Prox_Adj.
                NSString	*szProx_Adj	= [self catchFromString:strRowData
													   begin:@"Adjusted_Prox: "
														 end:@""
											  TheRightString:NO];
                if (![szProx_Adj isKindOfClass:[NSString class]]
					|| [szProx_Adj isEqualToString:@""])
                {
                    ATSDebug(@"CATCH_VALUE => Catch Fail : Can't Find begin string [Adjusted_Prox: ] or end string [\n].");
                    return [NSNumber numberWithBool:NO];
                }
                else
                {
                    dBaselineProx_Adj	+= [szProx_Adj doubleValue];
                    [arrayProx_Adj addObject:[NSNumber numberWithDouble:
											  [szProx_Adj doubleValue]]];
                }
            }
            
            //calculate stage's average and Standard Deviation
            for (int k=0; k < 12; k++)
            {
                for (int m=0; m<iCount; m++)
                {
                    double	data		= [[arraySensorReadingValue[m]
											objectAtIndex:k ] doubleValue];
                    dAverageStage[k]	+= data; 
                    [arrayStageData[k] addObject:[NSNumber numberWithDouble:data]];
                }
                dAverageStage[k]	/= iCount * 1.0;
                [self Cal_STD:[NSArray arrayWithArray: arrayStageData[k]]
				  ReturnValue:&szSTD];
                dSDStage[k]	= [szSTD doubleValue];
                [m_dicMemoryValues setValue:[NSString stringWithFormat:
											 @"%d", (int)dSDStage[k]]
									 forKey:[NSString stringWithFormat:
											 @"SDStage%d", k+1]];
                [m_dicMemoryValues setValue:[NSString stringWithFormat:
											 @"%d", (int)dAverageStage[k]]
									 forKey:[NSString stringWithFormat:
											 @"averageStage%d", k+1]];
            }
            //average of prox.centerpoint.temp.prox_adj 
            dBaselineProx			/= iCount * 1.0;
            dBaselineCenterpoint	/= iCount * 1.0;
            dBaselineTemp			/= iCount * 1.0;
            dBaselineProx_Adj		/= iCount * 1.0;
            //Standard Deviation of all 50 "Adjusted_Prox" values
            [self Cal_STD:[NSArray arrayWithArray:arrayProx_Adj]
			  ReturnValue:&szSTD];
            dBaselineSD_Adj		= [szSTD doubleValue];
            dBaselineTemp_Adj	= dBaselineTemp - dBaselineCenterpoint;
            dBaselineRef		= dAverageStage[4];
            dOFFSET				= (dAverageStage[2] - dAverageStage[3]) / 4;
            if ([szSlot isEqualToString:@"1"])
            {
				NSArray	*arrValue	= [NSArray arrayWithObjects:
									   [NSString stringWithFormat:
										@"%d", (int)dBaselineProx],
									   [NSString stringWithFormat:
										@"%d", (int)dBaselineCenterpoint],
									   [NSString stringWithFormat:
										@"%d", (int)dBaselineTemp],
									   [NSString stringWithFormat:
										@"%d", (int)dBaselineProx_Adj],
									   [NSString stringWithFormat:
										@"%d", (int)dBaselineSD_Adj] ,
									   [NSString stringWithFormat:
										@"%d", (int)dBaselineTemp_Adj],
									   [NSString stringWithFormat:
										@"%d", (int)dBaselineRef],
									   [NSString stringWithFormat:
										@"%d", (int)dOFFSET], nil];
				NSArray	*arrKeys	= [NSArray arrayWithObjects:
									   @"baselineProx",		@"baselineCenterpoint",
									   @"baselineTemp",		@"baselineProx_Adj",
									   @"baselineSD_Adj",	@"baselineTemp_Adj",
									   @"baselineRef",		@"OFFSET", nil];
				for (int i = 0; i < [arrKeys count]; i++)
					[m_dicMemoryValues setValue:[arrValue objectAtIndex:i]
										 forKey:[arrKeys objectAtIndex:i]];
				ATSDebug(@"baselineProx:%f,baselineCenterpoint:%f,baselineTemp:%f,baselineProx_Adj:%f,baselineSD_Adj:%f,baselineTemp_Adj:%f,baselineRef:%f,OFFSET:%f",
						 dBaselineProx,		dBaselineCenterpoint,
						 dBaselineTemp,		dBaselineProx_Adj,
						 dBaselineSD_Adj,	dBaselineTemp_Adj,
						 dBaselineRef,		dOFFSET);
				[strReturnValue setString:[NSString stringWithFormat:
										   @"%d", (int)dBaselineProx_Adj]];
				return [NSNumber numberWithBool:YES];
            }
            else
            {
                NSString	*szBaselineProx_Adj	= [m_dicMemoryValues valueForKey:
												   @"baselineProx_Adj"];
                if (szBaselineProx_Adj != nil)
                {
                    iDelta	= (int)dBaselineProx_Adj - [szBaselineProx_Adj intValue];
					
                    NSArray	*arrValue	= [NSArray arrayWithObjects:
										   [NSString stringWithFormat:
											@"%d", iDelta],
										   [NSString stringWithFormat:
											@"%d", (int)dBaselineProx],
										   [NSString stringWithFormat:
											@"%d", (int)dBaselineCenterpoint],
										   [NSString stringWithFormat:
											@"%d", (int)dBaselineTemp],
										   [NSString stringWithFormat:
											@"%d", (int)dBaselineProx_Adj],
										   [NSString stringWithFormat:
											@"%d", (int)dBaselineSD_Adj] ,
										   [NSString stringWithFormat:
											@"%d", (int)dBaselineTemp_Adj],
										   [NSString stringWithFormat:
											@"%d", (int)dBaselineRef],
										   [NSString stringWithFormat:
											@"%d", (int)dOFFSET], nil];
					NSArray	*arrKeys	= [NSArray arrayWithObjects:
										   [NSString stringWithFormat:
											@"Delta_%@Degree", szDegree],
										   [NSString stringWithFormat:
											@"baselineProxAtAngle_%@Degree", szDegree],
										   [NSString stringWithFormat:
											@"baselineCenterpointAtAngle_%@Degree", szDegree],
										   [NSString stringWithFormat:
											@"baselineTemp_%@Degree", szDegree],
										   [NSString stringWithFormat:
											@"baselineProxAtAngle_Adj_%@Degree", szDegree],
										   [NSString stringWithFormat:
											@"baselineSDAtAngle_Adj_%@Degree", szDegree],
										   [NSString stringWithFormat:
											@"baselineTempAtAngle_Adj_%@Degree", szDegree],
										   [NSString stringWithFormat:
											@"baselineRefAtAngle_%@Degree", szDegree],
										   [NSString stringWithFormat:
											@"OFFSET_%@Degree", szDegree], nil];
					for (int i = 0; i < [arrKeys count]; i++) 
						[m_dicMemoryValues setValue:[arrValue objectAtIndex:i]
											 forKey:[arrKeys objectAtIndex:i]];
					[strReturnValue setString:[NSString stringWithFormat:@"%d", iDelta]];
					return [NSNumber numberWithBool:YES];
                }
            }
        }
        else
        {
            [strReturnValue setString:@"the return value is less than 50 bing"];
            ATSDebug(@"the strReturnValue is less than 50 bing");
        }
    }
    ATSDebug(@"the strRetuenValue is nil, no data");
    return  [NSNumber numberWithBool:NO];
}

//End 2011.11.03 Add by Ming

//Start 2011.11.03 Add by Ming 
// Descripton:Record the delta value in dictionary for compass
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)RECORD_DELTA:(NSDictionary*)dicContents
			RETURN_VALUE:(NSMutableString*)strReturnValue
{
    NSString	*szTYPE				= [dicContents valueForKey:@"VALUE"];
    NSString	*szAVGFirstTemp		= [m_dicMemoryValues valueForKey:@"COMPASS_BASELINE"];
    NSArray	*arrayBaselineFirstTemp = [szAVGFirstTemp componentsSeparatedByString:@","];
    
    NSMutableArray	*arrayBaselineSecondTemp	= [[NSMutableArray alloc] init];
    [arrayBaselineSecondTemp addObjectsFromArray:
	 [m_dicMemoryValues valueForKey:@"COMPASS_BASELINE"]];
    if ([szTYPE isEqualToString:@"cam mode front"]) 
		[arrayBaselineSecondTemp addObjectsFromArray:
		 [m_dicMemoryValues valueForKey:@"COMPASS_FRONT"]];
	else if([szTYPE isEqualToString:@"cam mode back"])
        [arrayBaselineSecondTemp addObjectsFromArray:
		 [m_dicMemoryValues valueForKey:@"COMPASS_BACK"]];
	else if([szTYPE isEqualToString:@"AF pos (calibrated) 115"])
        [arrayBaselineSecondTemp addObjectsFromArray:
		 [m_dicMemoryValues valueForKey:@"COMPASS_BACK_115"]];
    else if([szTYPE isEqualToString:@"AF pos (calibrated) 230"])
        [arrayBaselineSecondTemp addObjectsFromArray:
		 [m_dicMemoryValues valueForKey:@"COMPASS_BACK_230"]];
	else 
	{
        [arrayBaselineSecondTemp release];
		return [NSNumber numberWithBool:NO];
	}
	if([arrayBaselineFirstTemp count] >=6
	   && [arrayBaselineSecondTemp count] >= 6 )
	{
		for(int i=0; i<=2; ++i)
		{
			[arrayBaselineSecondTemp
			 replaceObjectAtIndex:i
			 withObject:[NSNumber numberWithDouble:([[arrayBaselineSecondTemp
													  objectAtIndex:i] doubleValue]
													- [[arrayBaselineFirstTemp
														objectAtIndex:i] doubleValue])]];
		}
	}
	else
	{
		[strReturnValue setString:@"Get Compass Data error"];
        [arrayBaselineSecondTemp release];
		return [NSNumber numberWithBool:NO];
	}
    //for UI output
    [m_dicMemoryValues setValue:[NSString stringWithFormat:
								 @"%.6f",[[arrayBaselineSecondTemp objectAtIndex:0] doubleValue]]
						 forKey:[NSString stringWithFormat:@"%@_Avg_delta_X",szTYPE]];
    [m_dicMemoryValues setValue:[NSString stringWithFormat:
								 @"%.6f",[[arrayBaselineSecondTemp objectAtIndex:1] doubleValue]]
						 forKey:[NSString stringWithFormat:@"%@_Avg_delta_Y",szTYPE]];
    [m_dicMemoryValues setValue:[NSString stringWithFormat:
								 @"%.6f",[[arrayBaselineSecondTemp objectAtIndex:2] doubleValue]]
						 forKey:[NSString stringWithFormat:@"%@_Avg_delta_Z",szTYPE]];
	[m_dicMemoryValues setObject:arrayBaselineSecondTemp
						  forKey:[NSString stringWithFormat:@"%@",szTYPE]];
    [arrayBaselineSecondTemp release];
	return [NSNumber numberWithBool:YES];
}

//Start 2011.11.03 Add by Ming 
// Descripton:Get Camera SN
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)GET_CAMERA_SN:(NSDictionary*)dicContents
			 RETURN_VALUE:(NSMutableString*)strReturnValue
{
    [strReturnValue setString:[strReturnValue stringByReplacingOccurrencesOfString:@"\r"
																		withString:@""]];
	//add space new code
	NSRange		rangeSensorID	= [strReturnValue rangeOfString:@"sensorID : "];
	NSString	*strSensorID	= @"";
    
	if ((NSNotFound != rangeSensorID.location)
		&& (rangeSensorID.length>0)
		&& ((rangeSensorID.location+rangeSensorID.length)
			<= [strReturnValue length]))
    {
		NSArray	*arrTemp	= [strReturnValue componentsSeparatedByString:@"\n"];
		if ([arrTemp count] >=2 ) 
        {
			//change to 0 new code
			strSensorID	= [NSString stringWithFormat:
						   @"%@",[arrTemp objectAtIndex:0]];
			strSensorID	= [strSensorID substringFromIndex:(rangeSensorID.location
														   + rangeSensorID.length)];
			ATSDebug(@"SensorID:%@",strSensorID);
		}
		else
		{
			[strReturnValue setString:@"Don't get camera SN"];
			return [NSNumber numberWithBool:NO];
		}
	}
    else
    {
        [strReturnValue setString:@"Don't get the right data"];
        return [NSNumber numberWithBool:NO];
    }
	NSMutableString	*strInfo	= [[NSMutableString alloc] initWithString:@""];
	NSString		*strInfoA	= @"";
	NSString		*strInfoB	= @"";
	if ([strSensorID isEqual:@"0x145"]) 
	{
		NSRange	rangeInfoA	= [strReturnValue rangeOfString:@"0x140 : "];
		if ((NSNotFound != rangeInfoA.location)
			&& (rangeInfoA.length>0)
			&& ((rangeInfoA.location+rangeInfoA.length)
				<= [strReturnValue length]))
		{
			strInfoA	= [strReturnValue substringFromIndex:(rangeInfoA.location
															  + rangeInfoA.length)];
			NSArray	*arrInfoTemp	= [strInfoA componentsSeparatedByString:@"\n"];
			if ([arrInfoTemp count] >= 2)
			{
				strInfoA	= [NSString stringWithFormat:@"%@", [arrInfoTemp objectAtIndex:0]];
				strInfoB	= [NSString stringWithFormat:@"%@", [arrInfoTemp objectAtIndex:1]];
			}
			else
			{
				[strReturnValue setString:@"Don't get camera SN"];
				[strInfo release];	strInfo	= nil;
				return [NSNumber numberWithBool:NO];
			}
			NSRange	rangeInfoB	=[strInfoB rangeOfString:@"0x148 : "];
			if ((NSNotFound != rangeInfoB.location)
				&& (rangeInfoB.length>0)
				&& ((rangeInfoB.length+rangeInfoB.location)
					<= [strInfoB length]))
				strInfoB	= [strInfoB substringFromIndex:(rangeInfoB.location
															+ rangeInfoB.length)];
            else
            {
                [strReturnValue setString:@"Don't get camera SN"];
				[strInfo release];	strInfo	= nil;
				return [NSNumber numberWithBool:NO];
            }
			NSString	*strInfoTemp	= [NSString stringWithFormat:
										   @"%@%@", strInfoA,strInfoB];
			ATSDebug(@"Info:%@", strInfoTemp);
			NSArray	*arrInfo	= [strInfoTemp componentsSeparatedByString:@" "];
			if ([arrInfo count] >= 10) 
            {
				for (int i = 3; i <= 10; i++)
				{
					NSString	*strData	= [arrInfo objectAtIndex:i];
					strData	= (([strData length] == 4)
							   ? [strData stringByReplacingOccurrencesOfString:@"0x"
																	withString:@""]
							   : [strData stringByReplacingOccurrencesOfString:@"x"
																	withString:@""]);
					strData = [NSString stringWithFormat:@" %@", strData];
					[strInfo appendString:strData];
				}
			}
			else
			{
				[strReturnValue setString:@"Don't get camera SN"];
                [strInfo release];
				return [NSNumber numberWithBool:NO];
			}
		}
		else
        {
            [strReturnValue setString:@"Don't get camera SN"];
            [strInfo release];
            return [NSNumber numberWithBool:NO];
        }
	}
	else 
	{
		NSRange	rangeInfoA	= [strReturnValue rangeOfString:@"0x0 : "];
		if ((NSNotFound != rangeInfoA.location)
			&& (rangeInfoA.length>0)
			&& ((rangeInfoA.length+rangeInfoA.location)
				<= [strReturnValue length]))
		{
			strInfoA	= [strReturnValue substringFromIndex:(rangeInfoA.location
															  + rangeInfoA.length)];
			NSArray	*arrInfoTemp	= [strInfoA componentsSeparatedByString:@"\n"];
			if ([arrInfoTemp count] >= 1)
				strInfoA	= [NSString stringWithFormat:
							   @"%@", [arrInfoTemp objectAtIndex:0]];
			else
			{
				[strReturnValue setString:@"Don't get camera SN"];
                [strInfo release];
				return [NSNumber numberWithBool:NO];
			}
			NSArray *arrInfo = [strInfoA componentsSeparatedByString:@" "];
			if ([arrInfo count] >= 4)
				for (int i = 0; i <= 4; i++)
				{
					NSString	*strData	= [arrInfo objectAtIndex:i];
					strData	= (([strData length] == 4)
							   ? [strData stringByReplacingOccurrencesOfString:@"0x"
																	withString:@""]
							   : [strData stringByReplacingOccurrencesOfString:@"x"
																	withString:@""]);
					strData	= [NSString stringWithFormat:@" %@", strData];
					[strInfo appendString:strData];
				}
			else
			{
				[strReturnValue setString:@"Don't get camera SN"];
                [strInfo release];
				return [NSNumber numberWithBool:NO];
			}
			
		}
        else
        {
            [strReturnValue setString:@"Don't get camera SN"];
            [strInfo release];
            return [NSNumber numberWithBool:NO];
        }
        [strInfo appendString:@" 00 00 00"];
        
	}
	NSString	*strRF_cam_SN	= [NSString stringWithFormat:@"%@", strInfo];
	[strInfo release];
	[m_dicMemoryValues setValue:strRF_cam_SN
						 forKey:@"RF_cam_SN"];
    return [NSNumber numberWithBool:YES];
}

/****************************************************************************************************
 Start 2012.4.16 Add note by Yaya 
 Descripton:  switch the int data to HEX , and change format from "AABB" to "BB AA".
 Param:
 int iResult : the data need to switch.
 ****************************************************************************************************/
- (NSString *)int_2_2comp:(int)iResult
{
	NSMutableString	*strTemp	= [[NSMutableString alloc] init];
	if (iResult > 32767) 
	{
		NSLog(@"ERROR: Number Too Big.");
        [strTemp release];
		return @"ERROR: Number Too Big.";
	}
	if (iResult < -32768) 
	{
		NSLog(@"ERROR: Number Too Small.");
        [strTemp release];
		return @"ERROR: Number Too Small.";
	}
	else
        [strTemp setString:[NSString stringWithFormat:
							@"%02X %02X",
							iResult&0xFF, (iResult>>8)&0xFF]];//new code
	//modified by jingfu ran 
    NSString  *strResult = [NSString stringWithFormat:@"%@",strTemp];
	[strTemp release];
	return strResult;
}

/****************************************************************************************************
 Start 2012.4.16 Add note by Yaya 
 Descripton: Calculate the CRC 
 Param:
 unsigned char x[] : the para which need in this function.
 unsigned short BufferLen : the data which need in this function.
 ****************************************************************************************************/
unsigned short CalCRC16_1021(unsigned char x[],
							 unsigned short BufferLen)
{
    unsigned short	i;
    unsigned char	j;
    unsigned short	crc16	= 0;
    unsigned short	mask	= 0x1021; 
    unsigned char	*pByteBuffer;
    unsigned char	tmpbyte;
    unsigned short	calval;
    pByteBuffer	= &x[0];
	
    for (i = 0; i < BufferLen; i++)
    {
        tmpbyte	= *pByteBuffer;
        calval	= tmpbyte << 8; 
        for (j = 0; j < 8; j++)
        {
            if ((crc16 ^ calval) & 0x8000) 
                crc16	= (crc16 << 1) ^ mask;
            else
                crc16	<<= 1;
            calval	<<= 1;
        }
        pByteBuffer++;
    }
    return crc16;
}

//add by Jockey for crc tests
unsigned int Calccitt_alps(unsigned int i1,unsigned int i2)
{
    unsigned int poly_ccitt = 0x1021;
    unsigned int cc ;
    cc = (i1 ^ (i2 << 8));
    for (int i=0; i<8; i++) {
        if (cc&0x8000) {
            cc = (cc<<1) ^ poly_ccitt;
        }
        else
        cc<<=1;
    }
    cc&=0xFFFF;
    return cc;
}
-(NSNumber *)Cal_CRC_Value:(NSDictionary*)dicCatchSettings RETURN_VALUE:(NSMutableString *)szReturnValue
{
    //get parameters to calculate crc value
    NSString *szKey             = [dicCatchSettings objectForKey:kFZ_Script_MemoryKey];
    NSString *str = [m_dicMemoryValues objectForKey:szKey];
    NSScanner *str_scan = [NSScanner scannerWithString:str];
    NSDictionary *dicParams = [NSDictionary dictionaryWithObjectsAndKeys:@"16",@"CHANGE",@"10",@"TO",nil];
    
    unsigned int iValue;
    //get current byte
    [str_scan scanHexInt:&iValue];
    
    [szReturnValue setString:@""];
    
    ATSDebug(@"current byte is %u",iValue);
    unsigned int crc;
    //get crc value and calculate for a new one
    if ([[m_dicMemoryValues objectForKey:[dicCatchSettings objectForKey:kFZ_Script_CrcKey]]isKindOfClass:[NSString class]]&&[m_dicMemoryValues objectForKey:[dicCatchSettings objectForKey:kFZ_Script_CrcKey]]!=nil&&![[m_dicMemoryValues objectForKey:[dicCatchSettings objectForKey:kFZ_Script_CrcKey]]isEqualToString:@""]) {
        NSString *str1 = [m_dicMemoryValues objectForKey:kFZ_Script_CrcKey];
        unsigned int iValue1 = [str1 intValue];
        crc = Calccitt_alps(iValue1,iValue);
    }
    else
    {
        crc = Calccitt_alps(0xFFFF, iValue);
    }
    ATSDebug(@"current crc is %u",crc);
    //compare the result with supposed value if both of the keys exsits
    if ([dicCatchSettings objectForKey:kFZ_Script_CrcKey1]&&[dicCatchSettings objectForKey:kFZ_Script_CrcKey2]) {
        if ([m_dicMemoryValues objectForKey:[dicCatchSettings objectForKey:kFZ_Script_CrcKey1]]&&[m_dicMemoryValues objectForKey:[dicCatchSettings objectForKey:kFZ_Script_CrcKey2]]) {
            NSString *strcompare1 = [m_dicMemoryValues objectForKey:[dicCatchSettings objectForKey:kFZ_Script_CrcKey1]];
            NSString *strcompare2 = [m_dicMemoryValues objectForKey:[dicCatchSettings objectForKey:kFZ_Script_CrcKey2]];
            NSMutableString *strcom1 = [NSMutableString stringWithString:[strcompare1 substringFromIndex:2]];
            NSMutableString *strcom2 = [NSMutableString stringWithString:[strcompare2 substringFromIndex:2]];
            NSMutableString *strcrc = [NSMutableString stringWithFormat:@"%u",crc];
            [strcom1 appendString:strcom2];
            [self NumberSystemConvertion:dicParams RETURN_VALUE:strcom1];
            ATSDebug(@"Supposed result is %@",strcom1);
            ATSDebug(@"Programme result is %@",strcrc);
            if ([strcrc isEqualToString:strcom1]) {
                return [NSNumber numberWithBool:YES];
            }
            else
                return [NSNumber numberWithBool:NO];
        }
        else
        {
            return [NSNumber numberWithBool:NO];
        }
    }
    [szReturnValue setString:[NSString stringWithFormat:@"%u",crc]];
    [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%u",crc] forKey:[dicCatchSettings objectForKey:kFZ_Script_CrcKey]];
    return [NSNumber numberWithBool:YES];
}

// 2012.04.16 Modified by Andre 
// Descripton:Transform AA BB CC DD to 0xDDCCBBAA。To generate CPAS value to be written.
// Param:
//      NSString *szNormalOrdered    : Return value(CPAS Value)
- (NSString *)norm2diags_ordering:(NSString *)szNormalOrdered
{
	NSMutableString	*strTemp	= [[NSMutableString alloc] init];
	NSMutableString	*strResult	= [[NSMutableString alloc] init];
	
	[strTemp setString:szNormalOrdered];
	[strResult setString:@""];
    //modified by desikan new code
	while ((([strTemp length] + 1) % 12) != 0) 
		[strTemp setString:[NSString stringWithFormat:@"%@ 00", strTemp]];
	NSInteger	iStep	= ([strTemp length] + 1) / 12;
	NSArray	*arrDiagsOrdered	= [strTemp componentsSeparatedByString:@" "];
	if (68 == [arrDiagsOrdered count] ) 
		for(int i = 0; i < iStep; i++)
		{
			[strResult appendFormat:@" 0x"];
			//Ex: Diags writes 0xAABBCCDD, the OS reads DD CC BB AA.
			for (int j = 3; j >= 0; j--)
				[strResult appendString:[arrDiagsOrdered objectAtIndex:i * 4 + j]];
		}
	NSString	*szReturnValue	= [NSString stringWithFormat:@"%@", strResult];
	[strResult release];
	[strTemp release];
	return szReturnValue;
	
}

// Get compass NMS
//      Parameter:
//
//          NSDictionary    *dicPara        :   Setting
//              TYPE        -> NSString*    :   Get each compass data under magnetic field(NORMAL , SOUTH , NORTH)
//          NSMutableString        *szReturnValue :   Return value
//
//      Return:
//          Action result
- (NSNumber*)CompassValue_NorthMuinsSouth:(NSDictionary*)dicPara
							  ReturnValue:(NSMutableString *)szReturnValue
{
    //Basic judge
    if (![szReturnValue isKindOfClass:[NSString class]]) 
        return [NSNumber numberWithBool:NO];
    //Calculate compass NMS value
    double	fValueX		= 0;
    double	fValueY		= 0;
    double	fValueZ		= 0;
    double	fCompassNMS;
	if ([m_dicMemoryValues valueForKey:@"COMPASS_NMS_X"]
		&& [m_dicMemoryValues valueForKey:@"COMPASS_NMS_Y"]
		&& [m_dicMemoryValues valueForKey:@"COMPASS_NMS_Z"]) 
	{
		fValueX	= [[m_dicMemoryValues valueForKey:@"COMPASS_NMS_X"] doubleValue];
		fValueY	= [[m_dicMemoryValues valueForKey:@"COMPASS_NMS_Y"] doubleValue];
        fValueZ	= [[m_dicMemoryValues valueForKey:@"COMPASS_NMS_Z"] doubleValue];
        fCompassNMS	= sqrt(fValueX * fValueX +fValueY * fValueY + fValueZ * fValueZ);
        [szReturnValue setString:[NSString stringWithFormat:@"%f", fCompassNMS]];
        ATSDebug(@"Calculate field with compass data[COMPASS_NMS_X/Y/Z],result[%f].",
				 fCompassNMS);
        return [NSNumber numberWithBool:YES];
	}
	else
	{
		ATSDebug(@"Don't get COMPASS_NMS_X,COMPASS_NMS_Y,COMPASS_NMS_Z");
		[szReturnValue setString:kFZ_99999_Value_Issue];
		return [NSNumber numberWithBool:NO];
	}
	
}

// Calculate compass each coordinate delta value
//      Parameter:
//
//          NSDictionary    *dicPara        :   Setting
//              AXIS        -> Boolean      :   each coordinate north value minus south value(X , Y , Z , NMS)
//          NSMutableString        *szReturnValue :   Return value
//
//      Return:
//          Action result
- (NSNumber*)Delta_Compass:(NSDictionary*)dicPara
			   ReturnValue:(NSMutableString*)szReturnValue
{
    //Basic judge
    if (![dicPara isKindOfClass:[NSDictionary class]]
        || ![dicPara valueForKey:KIADeviceKey_AXIS]
        || ![szReturnValue isKindOfClass:[NSString class]])
    {
        [szReturnValue setString:[NSString stringWithFormat:
                                  @"Data error"]];
        return [NSNumber numberWithBool:NO];
    }
    
    //Calculate compass delta value 
    NSString	*szType			= [dicPara valueForKey:KIADeviceKey_AXIS];
    NSString	*szNorthValue	= [m_dicMemoryValues valueForKey:KIADeviceKey_NORTH_M];
    NSString	*szSouthValue	= [m_dicMemoryValues valueForKey:KIADeviceKey_SOUTH_M];
    
    // for QT1 item Compass_1_Test_NMS_M0 =  'Compass_1_North_M' - 'Compass_1_South_M'
    if ([szType isEqualToString:KIADeviceKey_NMS]) 
    {
        if (szNorthValue && szSouthValue) 
        {
            double	fValueSubtract	= ([szNorthValue doubleValue]
									   - [szSouthValue doubleValue]);
            [szReturnValue setString:[NSString stringWithFormat:
									  @"%f", fValueSubtract]];
            ATSDebug(@"Calculate delta value with SOUTH_M and NORTH_M,result[%f].",
					 fValueSubtract);
            return [NSNumber numberWithBool:YES];
        }
        else
        {
            [szReturnValue setString:[NSString stringWithFormat:
									  @"Compass Delta calculate error"]];
            return [NSNumber numberWithBool:NO];
        }
    } 
    // for QT1 item Compass_1_Test_NMS_M =  'Compass_1_North_M' + 'Compass_1_South_M'
    else if([szType isEqualToString:kIADeviceKey_NMS_M])
    {
		if (szNorthValue && szSouthValue)
        {
            double	fValueSubtract	= ([szNorthValue doubleValue]
									   + [szSouthValue doubleValue]);
            [szReturnValue setString:[NSString stringWithFormat:
									  @"%f", fValueSubtract]];
            ATSDebug(@"Calculate delta value with SOUTH_M and NORTH_M,result[%f].",
					 fValueSubtract);
            return [NSNumber numberWithBool:YES];
        }	  
        else
        {
            [szReturnValue setString:[NSString stringWithFormat:
									  @"Compass Delta calculate error"]];
            return [NSNumber numberWithBool:NO];
        }
    }
    else
    {
        NSNumber	*numValueBA	= [m_dicMemoryValues valueForKey:
								   [NSString stringWithFormat:@"COMPASS_%@_BA", szType]];
        NSNumber	*numValueAA	= [m_dicMemoryValues valueForKey:
								   [NSString stringWithFormat:@"COMPASS_%@_AA", szType]];
        if(numValueBA && numValueAA)
		{
			double	x	= [numValueAA doubleValue] - [numValueBA doubleValue];
			[szReturnValue setString:[NSString stringWithFormat:@"%f", x]];
			[m_dicMemoryValues setValue:[NSString stringWithString:szReturnValue]
								 forKey:[NSString stringWithFormat:
										 @"COMPASS_NMS_%@", szType]];
			ATSDebug(@"Calculate delta value[%@] with COMPASS_NMS_BA and COMPASS_NMS_AA,and send value to dicMemoryValues with key[COMPASS_NMS_%@].",
					 szReturnValue,szType);
			return [NSNumber numberWithBool:YES];
		}
		else
        {
            [szReturnValue setString:[NSString stringWithFormat:
									  @"Compass Delta calculate error"]];
            return [NSNumber numberWithBool:NO];
        }
    }
}

// Set whether we need to count fail receive
//  Descripton: Count the receive fails, and save the fail count to m_iCamispFailCount. 
//  Param:
//           NSDictionary             *dicPara        :   Setting
//              NEEDJUDGEFAILRECEIVE   -> Boolean    :   Set whether we need to count if the fail receive exits in return value 
- (NSNumber*)Set_Judge_Fail_Receive:(NSDictionary*)dicPara
{
    m_bNeedJudgeFailReceive	= [[dicPara valueForKey:@"NEEDJUDGEFAILRECEIVE"]boolValue];
    return [NSNumber numberWithBool:YES];
}

//Start 2012.01.31 Add by Sunny 
// Descripton:Write CPCL into unit.
// Param:
//      NSDictionary    *dicContents        :   Setting
//              Version Number -> NSString*                     :   Version Number of CPCL
//              Alpha value -> NSString*                        :   Alpha value of CPCL
//              SEND_COMMAND:-> NSDictionary*                   :   Write CPCL command
//              READ_COMMAND:RETURN_VALUE: -> NSDictionary*     :   Receive CPCL command
//      NSMutableString      *szReturnValue :   Return value
-(NSNumber*)WRITECPCL:(NSDictionary*)dicContents
		 RETURN_VALUE:(NSMutableString*)strReturnValue
{
    bool	bFailCancle	= [[dicContents objectForKey:@"FailCancle"] boolValue];
    if(!m_bFinalResult && bFailCancle)
        return [NSNumber numberWithBool:NO];
	NSMutableString	*strCPCL			= [[NSMutableString alloc] init];
	NSString	*strAdditionalInformation;
	NSString	*strCheckSum;
	int			iSum					= 0;	
	NSString	*strVersion				= [dicContents valueForKey:@"Version Number"];
	NSString	*strAlphaValue			= [dicContents valueForKey:@"Alpha value"];
	NSString	*strAlpha1Value			= [dicContents valueForKey:@"Alpha1 value"];
	NSString	*strAlphaFristByte		= [dicContents valueForKey:@"Alpha first byte"];
	NSString	*strAlpha1FristByte		= [dicContents valueForKey:@"Alpha1 first byte"];
	NSString	*strReserved			= [dicContents valueForKey:@"Reserved"];
	// modify by desikan  start
    NSString	*szThreshold2			= [dicContents valueForKey:@"Threshold2"];
    NSString	*szOffsetFactorsElec1	= [dicContents valueForKey:@"OffsetFactorsElec1"];
    NSString	*szOffsetFactorsElec2	= [dicContents valueForKey:@"OffsetFactorsElec2"];
    NSString	*szOffsetFactorsC13		= [dicContents valueForKey:@"OffsetFactorsC13"];
    NSString	*szThresholdPositive	= [dicContents valueForKey:@"ThresholdPositive"];
    NSString	*szThresholdNegative	= [dicContents valueForKey:@"ThresholdNegative"];
    NSString	*szMaxAdjustLimit		= [dicContents valueForKey:@"MaxAdjustLimit"];
    NSString	*szCenterpointTolerance	= [dicContents valueForKey:@"CenterpointTolerance"];
    NSString	*szTempTolerance		= [dicContents valueForKey:@"TempTolerance"];
    NSString	*szCalibrationDataSiza	= [dicContents valueForKey:@"CalibrationDataSiza"];
	// modify by desikan end
	[m_dicMemoryValues setValue:strVersion forKey:@"Version Number"];
	[m_dicMemoryValues setValue:strAlphaValue forKey:@"Alpha value"];
	
	// Determine the Critical Angle, meaning the position that
	//	measured the lowest Delta Value of all Three Position Fixtures
	int	iCurrentProxAt0Degree	= [[m_dicMemoryValues objectForKey:@"Delta_0Degree"]
								   intValue];
	int	iCurrentProxAt90Degree	= [[m_dicMemoryValues objectForKey:@"Delta_90Degree"]
								   intValue];
	int	iCurrentProxAt180Degree	= [[m_dicMemoryValues objectForKey:@"Delta_180Degree"]
								   intValue];
	int	iCriticalAngleDelta		= MIN(iCurrentProxAt0Degree, iCurrentProxAt90Degree);
	ATSDebug(@"min criticalangleDelta is %d", iCriticalAngleDelta);
	//Get AdditionalInformation
	if (iCriticalAngleDelta == iCurrentProxAt0Degree)
	{
		strAdditionalInformation	= @"00 00";
		[m_dicMemoryValues setValue:@"0" forKey:@"Critical position"];
	}
	else if (iCriticalAngleDelta == iCurrentProxAt90Degree)
	{
		strAdditionalInformation	= @"00 01";
		[m_dicMemoryValues setValue:@"1" forKey:@"Critical position"];
	}
	else if (iCriticalAngleDelta == iCurrentProxAt180Degree)
	{
		strAdditionalInformation	= @"00 02";
		[m_dicMemoryValues setValue:@"2" forKey:@"Critical position"];
	}
	NSMutableArray	*arrData	= [[NSMutableArray alloc] initWithObjects:
								   [m_dicMemoryValues objectForKey:@"OFFSET"],
								   [m_dicMemoryValues objectForKey:@"baselineProx"],
								   [m_dicMemoryValues objectForKey:@"baselineCenterpoint"],
								   [m_dicMemoryValues objectForKey:@"baselineTemp"],
								   [NSString stringWithFormat:@"%d", iCriticalAngleDelta],
								   //For the CPCl config, the "baseline ref value (stage 4 output)" at Bits [239:224] will now be a secondary threshold value.   It will be labeled "Threshold2"
								   szThreshold2,
								   strVersion,
								   strAlphaValue,
								   strAlpha1Value, nil];
	
	NSMutableString	*strTemp	= [[NSMutableString alloc]init];
	if ([arrData count] != 9) 
	{
		ATSDebug(@"Get not enough data");
        [arrData release];
        [strCPCL release];
        [strTemp release];
		return [NSNumber numberWithBool:NO];
	}
	for (int i = 0; i < [arrData count]; i++) 
	{
		if (i < 5) //modify by desikan
			[strTemp setString:[[NSString stringWithFormat:
								 @"%08X", [[arrData objectAtIndex:i] intValue]]
								substringFromIndex:4]];
		else
			[strTemp setString:[NSString stringWithFormat:
								@"%@", [arrData objectAtIndex:i]]];
		[strTemp insertString:@" "
					  atIndex:2];
        [arrData replaceObjectAtIndex:i
						   withObject:[NSString stringWithString:strTemp]];
	}
	//Calculate CheckSum = 2's compliment of the (sum of byte9 thru byte39)
	[strTemp setString:[NSString stringWithFormat:
						@"%@ %@ %@ %@ %@ %@ %@ %@ %@ %@ %@ %@ %@ %@ %@ %@ %@ %@",
						[arrData objectAtIndex:0],
						szOffsetFactorsElec1,
						szOffsetFactorsElec2,
						szOffsetFactorsC13,
						[arrData objectAtIndex:7],
						strAlphaFristByte,
						[arrData objectAtIndex:1],
						[arrData objectAtIndex:2],
						[arrData objectAtIndex:3],
						[arrData objectAtIndex:4],
						[arrData objectAtIndex:5],
						szThresholdPositive,
						szThresholdNegative,
						szMaxAdjustLimit,
						szCenterpointTolerance,
						szTempTolerance,
						[arrData objectAtIndex:8],
						strAlpha1FristByte]]; //modify by desikan
	NSString		*strResult		= [NSString stringWithFormat:@"%@", strTemp];
	ATSDebug(@"FirstData is %@", strResult);
	NSDictionary	*dicPara;
	NSArray			*arrCheckSum	= [strTemp componentsSeparatedByString:@" "];
	
	// Sum of byte9 thru byte39
	for (int i = 0; i < [arrCheckSum count]; i++) 
	{
		dicPara	= [NSDictionary dictionaryWithObjectsAndKeys:
				   [NSNumber numberWithInt:16],	@"CHANGE",
				   [NSNumber numberWithInt:10],	@"TO", nil];
		[strTemp setString:[arrCheckSum objectAtIndex:i]];
		[self NumberSystemConvertion:dicPara
						RETURN_VALUE:strTemp];
		iSum	+= [strTemp intValue];
	}
	
	// Get 2's complement,
	strCheckSum	= [NSString stringWithFormat:@"%d", ((iSum ^ 0xffff) + 1)];
	strCheckSum	= [NSString stringWithFormat:@"%02X %02X",
				   ([strCheckSum intValue] >> 8) & 0xFF,
				   [strCheckSum intValue] & 0xFF];
	ATSDebug(@"CheckSum is %@",strCheckSum);
	// modify by desikan
	strResult	= [NSString  stringWithFormat:@"%@ %@ %@ %@ %@ %@",
				   [arrData objectAtIndex:6],
				   strAdditionalInformation,
				   szCalibrationDataSiza,
				   strCheckSum,
				   strResult,
				   strReserved];
	ATSDebug(@"Result:%@",strResult);

	// Ex: Diags writes 0xAABBCCDD, the OS reads CCDD AABB.
	NSArray	*arrCPCl	= [strResult componentsSeparatedByString:@" "];
	if (48 == [arrCPCl count] ) 
	{
		for(int i = 0; i < ([strResult length] + 1)/12; i++)
		{
			[strCPCL appendFormat:@" 0x"];
			for (int j = 1; j >= 0; j--)
			{
				[strCPCL appendString:[arrCPCl objectAtIndex:i * 4 + j * 2]];
				[strCPCL appendString:[arrCPCl objectAtIndex:i * 4 + j * 2 + 1]];
			}
		}
	}	
	[m_dicMemoryValues setValue:[NSString stringWithFormat:@"%@", strCPCL]
						 forKey:@"CPCl"];
	ATSDebug(@"CPCL is %@", strCPCL);
	//Write CPCl to DUT
	NSDictionary	*dicWriteCPCL		= [dicContents objectForKey:@"SEND_COMMAND:"];
	NSDictionary	*dicReceiveFromCPCL	= [dicContents objectForKey:@"READ_COMMAND:RETURN_VALUE:"];
	NSNumber		*retValue;  
	[self SEND_COMMAND:dicWriteCPCL];
	retValue	= [self READ_COMMAND:dicReceiveFromCPCL
					 RETURN_VALUE:strReturnValue];
	if (retValue == [NSNumber numberWithBool:YES])
	{
		[strReturnValue setString:strCPCL]; 
        [arrData release];
        [strTemp release];
		[strCPCL release];
		return [NSNumber numberWithBool:YES];
	}
	else
	{
		[strReturnValue setString:@"Test Fail didn't write CPCL"];
        [arrData release];
        [strTemp release];
		[strCPCL release];
		return [NSNumber numberWithBool:NO];
	}
}

// 2012.04.16 Modified by Andre 
// Descripton:Change test case name with Board ID. 
//      Ex. Orignal:Testcase is AABB. If Board ID is 0x0A, the name should be P105 AABB.
//          Orignal:Testcase is AABB. If Board ID is 0x0C, the name should be P106 AABB.
//          Orignal:Testcase is AABB. If Board ID is 0x0E, the name should be P107 AABB.
// Param:
//      NSDictionary    *dicContents        :   Setting
//               None
//      NSMutableString      *szReturnValue :   Return value
- (NSNumber *)CHANGE_TESTCASENAME_WITH_BOARDID:(NSDictionary *)dicContents
								  RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSString	*szCurrentTestItem;
    NSString	*szBoardId	= [m_dicMemoryValues valueForKey:@"boardid"];
	
    if ([szBoardId isEqualToString:@"0x0C"]) 
    {
		[m_strSpecName setString:kFZ_Script_JudgeCommonP106];
        szCurrentTestItem	= [NSString stringWithFormat:@"P106 %@",
							   [m_dicMemoryValues valueForKey:kFunnyZoneCurrentItemName]];
    }
    else if ([szBoardId isEqualToString:@"0x0E"])
    {
		[m_strSpecName setString:kFZ_Script_JudgeCommonP107];
        szCurrentTestItem	= [NSString stringWithFormat:@"P107 %@",
							   [m_dicMemoryValues valueForKey:kFunnyZoneCurrentItemName]];
    }
    else if([szBoardId isEqualToString:@"0x0A"]) 
    {
        ATSDebug(@"the board shouldn't be tested at this station %@", szBoardId);
        [szReturnValue setString:[NSString stringWithFormat:
								  @"Wrong Board id! %@", szBoardId]];
        NSAlert *alert = [[NSAlert alloc]init];
        alert.messageText = @"警告(Warning)";
        alert.informativeText = @"请停止测试，P105机台。(This unit is P105, Please Stop Test)";
        [alert addButtonWithTitle:@"确认(OK)"];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
        [alert release];
        return [NSNumber numberWithBool:NO];
    }
    else
    {
        [szReturnValue setString:[NSString stringWithFormat:
								  @"Wrong Board id! %@", szBoardId]];
        return [NSNumber numberWithBool:NO];
    }
    [m_dicMemoryValues setObject:szCurrentTestItem
						  forKey:kFZ_UI_SHOWNNAME];
    return [NSNumber numberWithBool:YES];
}

// 2012.04.16 Modified by Andre 
// Descripton:Catch temperature and humility from Device.And save them as "TEM" and "HUM"
//      Return Value is 8 hex values. 
//        The 3rd value is Tem‘s integer part. 
//        The 4th value is Tem's decimal part.
//        The 5rd value is Hum‘s integer part. 
//        The 6th value is Hum's decimal part.
// Param:
//      NSDictionary    *dicContents        :   Setting
//      NSMutableString      *szReturnValue :   Return value
- (NSNumber*)CATCHTEMANDHUM:(NSDictionary *)dicContents
			   RETURN_VALUE:(NSMutableString *)strReturnValue
{
    if (strReturnValue) 
    {
        NSArray	*arrResponse	= [strReturnValue componentsSeparatedByString:@" "];
        if ([arrResponse count] != 9)
            return [NSNumber numberWithBool:NO];
        NSMutableDictionary	*dictConvertion	= [[NSMutableDictionary alloc] init];
        
        [dictConvertion setObject:[NSNumber numberWithInt:16]
						   forKey:@"CHANGE"];
        [dictConvertion setObject:[NSNumber numberWithInt:10]
						   forKey:@"TO"];
        NSMutableString	*strFirTem	= [NSMutableString stringWithFormat:
									   @"%@", [arrResponse objectAtIndex:3]];
        NSMutableString	*strSecTem	= [NSMutableString stringWithFormat:
									   @"%@", [arrResponse objectAtIndex:4]];
        NSMutableString	*strFirHum	= [NSMutableString stringWithFormat:
									   @"%@", [arrResponse objectAtIndex:5]];
        NSMutableString	*strSecHum	= [NSMutableString stringWithFormat:
									   @"%@", [arrResponse objectAtIndex:6]];
        if ([self NumberSystemConvertion:dictConvertion
							RETURN_VALUE:strFirTem]
			&& [self NumberSystemConvertion:dictConvertion
							   RETURN_VALUE:strSecTem]
			&& [self NumberSystemConvertion:dictConvertion
							   RETURN_VALUE:strFirHum]
			&& [self NumberSystemConvertion:dictConvertion
							   RETURN_VALUE:strSecHum])
        {
            NSString	*strTem	= [NSString stringWithFormat:
								   @"%@.%@", strFirTem, strSecTem];
            NSString	*strHum	= [NSString stringWithFormat:
								   @"%@.%@", strFirHum, strSecHum];
            ATSDebug(@"the temperature and humidity is %@, %@",
					 strTem, strHum);
            [m_dicMemoryValues setObject:strTem
								  forKey:@"TEM"];
            [m_dicMemoryValues setObject:strHum
								  forKey:@"HUM"];
            [dictConvertion release];
            return [NSNumber numberWithBool:YES];
        }
        else
        {
            [dictConvertion release];
            return [NSNumber numberWithBool:NO];
        }
    }
    else
        return [NSNumber numberWithBool:NO];
}

// 2012.04.16 Modified by Andre 
// Descripton:Judge if BOARDID is one of BOARDID array objects.
// Param:
//      NSDictionary    *dicContents        :   Setting
//              BOARDID -> NSArray*         :   BOARDIDs that you want
//      NSMutableString      *szReturnValue :   Return value
- (NSNumber *)CHECK_BOARD_ID:(NSDictionary *)dicContents
				RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSArray	*arrBoardID	= [dicContents objectForKey:@"BOARDID"];
    if ([arrBoardID containsObject:szReturnValue])
        return [NSNumber numberWithBool:YES];
    else
        return [NSNumber numberWithBool:NO];
}

// 2012.10.22 add compass vcm 
// Call the Python script : comp_vcm_test.py to get the test result
// str_BsdPath: comp_vcm_test.py need the UART path as the para.
- (NSNumber *)CHECK_VCM_DATA: (NSDictionary *)dicPara
                RETURN_VALUE: (NSMutableString *)szReturnValue
{
    // get current bsd_path
    NSString    *str_BsdPath = [m_dicMemoryValues objectForKey:kPD_Device_BSDPATH];
    
    // get the python.exe path
    NSString    *str_PythonPath = @"/usr/bin/python";
    
    // get the script path
    NSString    *str_ScriptPath = @"/usr/local/bin/comp_vcm_test.py";
    
    // run the script in shell
    NSTask      *task = [[NSTask alloc]init];
    NSPipe      *outPipe = [[NSPipe alloc]init];
    
    [task setLaunchPath:str_PythonPath];
    NSArray     *args = [NSArray arrayWithObjects:str_ScriptPath, str_BsdPath, nil];
    
    [task setArguments:args];
    [task setStandardOutput:outPipe];
    [task launch];
    
    // get the data we need from raw data
    NSData	*data		= [[outPipe fileHandleForReading]
                           readDataToEndOfFile];
    [task waitUntilExit];
    [task release];
    [outPipe release];
    NSString	*szString	= [[NSString alloc]	initWithData:data
                                               encoding:NSUTF8StringEncoding];
    
    // write into uart log
    BOOL		bBinarySave		= [[self getValueFromXML:kPD_UserDefaults
										mainKey:kPD_UserDefaults_SaveBinary,nil] boolValue];
    //NSString    *szPortType     = @"MOBILE";
    //NSString	*szDeviceTarget	= [NSString stringWithFormat:@"Clear Buffer ==> [%@]",szPortType];
    [IALogs CreatAndWriteUARTLog:[NSString stringWithFormat:@"%@\n",szString]
							  atTime:kIADeviceALSFileNameDate
						  fromDevice:nil
							withPath:[NSString stringWithFormat:@"%@/%@_%@/%@_%@_Uart.txt",
									  kPD_LogPath,m_szPortIndex,m_szStartTime,m_szPortIndex,m_szStartTime]
							  binary:bBinarySave];
	NSString	*strInformation = [NSString stringWithFormat:@"[%@] (%@) : %@\n",kIADeviceALSFileNameDate,@"NULL",szString];
	NSDictionary	*dict		= [NSDictionary dictionaryWithObject:[NSColor orangeColor] forKey:NSForegroundColorAttributeName];
	NSAttributedString	*attriUART	= [[NSAttributedString alloc] initWithString:strInformation
																	attributes:dict];
	[m_strSingleUARTLogs appendAttributedString:attriUART];
	[attriUART release];
    NSString    *szRawData = @"NULL";
    
    if ([szString contains:@"Test Value:"] && [szString contains:@"End Test Value"]) {
        szRawData = [szString SubFrom:@"Test Value:" include:YES];
        szRawData = [szRawData subTo:@"End Test Value" include:YES];
    }
    else{
        [szString release];
        ATSDebug(@"VCM format Error!");
        [szReturnValue setString:@"VCM format Error!"];
        return [NSNumber numberWithBool:NO];
    }
    [szString release];
    NSString    *szStringTemp = [NSString stringWithFormat:@"%@",szRawData];
    
    /* to memory some useful data */
    // vcm_at_min(0) the avg and std
    if ([szStringTemp contains:@"vcm_at_min(0):"] && [szStringTemp contains:@"vcm_at_max(230):"]) {
        
        szStringTemp = [szStringTemp SubFrom:@"vcm_at_min(0):" include:NO];
        szStringTemp = [szStringTemp subTo:@"vcm_at_max(230):" include:NO];
        szStringTemp = [szStringTemp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        szStringTemp = [szStringTemp stringByReplacingOccurrencesOfString:@" " withString:@""];
        szStringTemp = [szStringTemp stringByReplacingOccurrencesOfString:@";" withString:@""];
        NSArray     *arrTemp0 = [szStringTemp componentsSeparatedByString:@","];
        // average
        [m_dicMemoryValues setObject:[arrTemp0 objectAtIndex:0] forKey:@"VCM_At_Min(0) CompassX"];
        [m_dicMemoryValues setObject:[arrTemp0 objectAtIndex:1] forKey:@"VCM_At_Min(0) CompassY"];
        [m_dicMemoryValues setObject:[arrTemp0 objectAtIndex:2] forKey:@"VCM_At_Min(0) CompassZ"];
        // stardard
        [m_dicMemoryValues setObject:[arrTemp0 objectAtIndex:3] forKey:@"VCM_At_Min(0) Std_CompassX"];
        [m_dicMemoryValues setObject:[arrTemp0 objectAtIndex:4] forKey:@"VCM_At_Min(0) Std_CompassY"];
        [m_dicMemoryValues setObject:[arrTemp0 objectAtIndex:5] forKey:@"VCM_At_Min(0) Std_CompassZ"];
        
    }
    else{
        ATSDebug(@"VCM Data Lost!");
        [szReturnValue setString:@"VCM Data Lost!"];
        return [NSNumber numberWithBool:NO];
    }
    szStringTemp = [NSString stringWithFormat:@"%@",szRawData];
    
    // vcm_at_min(230) the avg and std
    if ([szStringTemp contains:@"vcm_at_max(230):"] && [szStringTemp contains:@"delta:"]) {
        
        szStringTemp = [szStringTemp SubFrom:@"vcm_at_max(230):" include:NO];
        szStringTemp = [szStringTemp subTo:@"delta:" include:NO];
        szStringTemp = [szStringTemp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        szStringTemp = [szStringTemp stringByReplacingOccurrencesOfString:@" " withString:@""];
        szStringTemp = [szStringTemp stringByReplacingOccurrencesOfString:@";" withString:@""];
        NSArray     *arrTemp230 = [szStringTemp componentsSeparatedByString:@","];
        // average
        [m_dicMemoryValues setObject:[arrTemp230 objectAtIndex:0] forKey:@"VCM_At_Max(230) CompassX"];
        [m_dicMemoryValues setObject:[arrTemp230 objectAtIndex:1] forKey:@"VCM_At_Max(230) CompassY"];
        [m_dicMemoryValues setObject:[arrTemp230 objectAtIndex:2] forKey:@"VCM_At_Max(230) CompassZ"];
        // stardard
        [m_dicMemoryValues setObject:[arrTemp230 objectAtIndex:3] forKey:@"VCM_At_Max(230) Std_CompassX"];
        [m_dicMemoryValues setObject:[arrTemp230 objectAtIndex:4] forKey:@"VCM_At_Max(230) Std_CompassY"];
        [m_dicMemoryValues setObject:[arrTemp230 objectAtIndex:5] forKey:@"VCM_At_Max(230) Std_CompassZ"];
        
    }
    else{
        ATSDebug(@"VCM Data Lost!");
        [szReturnValue setString:@"VCM Data Lost!"];
        return [NSNumber numberWithBool:NO];
    }
    szStringTemp = [NSString stringWithFormat:@"%@",szRawData];
    
    // the delta : vcm_at_min(230) - vcm_at_min(0)
    if ([szStringTemp contains:@"delta:"] && [szStringTemp contains:@"Noise Fail:"]) {
        
        szStringTemp = [szStringTemp SubFrom:@"delta:" include:NO];
        szStringTemp = [szStringTemp subTo:@"Noise Fail:" include:NO];
        szStringTemp = [szStringTemp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        szStringTemp = [szStringTemp stringByReplacingOccurrencesOfString:@" " withString:@""];
        szStringTemp = [szStringTemp stringByReplacingOccurrencesOfString:@";" withString:@""];
        NSArray     *arrTempDelta = [szStringTemp componentsSeparatedByString:@","];
        // average
        [m_dicMemoryValues setObject:[arrTempDelta objectAtIndex:0] forKey:@"Delta CompassX"];
        [m_dicMemoryValues setObject:[arrTempDelta objectAtIndex:1] forKey:@"Delta CompassY"];
        [m_dicMemoryValues setObject:[arrTempDelta objectAtIndex:2] forKey:@"Delta CompassZ"];
        // stardard , which i saw in the script is always zero. (fill three 0 to satisfy the format)
        [m_dicMemoryValues setObject:[arrTempDelta objectAtIndex:3] forKey:@"Delta Std_CompassX"];
        [m_dicMemoryValues setObject:[arrTempDelta objectAtIndex:4] forKey:@"Delta Std_CompassY"];
        [m_dicMemoryValues setObject:[arrTempDelta objectAtIndex:5] forKey:@"Delta Std_CompassZ"];
        
    }
    else{
        ATSDebug(@"VCM Data Lost!");
        [szReturnValue setString:@"VCM Data Lost!"];
        return [NSNumber numberWithBool:NO];
    }
    szStringTemp = [NSString stringWithFormat:@"%@",szRawData];
    
    // the Noise Fail is to check the stardard, which i saw in the script is always zero. (but we maybe judge the noise fail in our script file in the furture)
    if ([szStringTemp contains:@"Noise Fail:"] && [szStringTemp contains:@"Camisp Fail:"]) {
        
        szStringTemp = [szStringTemp SubFrom:@"Noise Fail:" include:NO];
        szStringTemp = [szStringTemp subTo:@"Camisp Fail:" include:NO];
        szStringTemp = [szStringTemp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        szStringTemp = [szStringTemp stringByReplacingOccurrencesOfString:@" " withString:@""];
        szStringTemp = [szStringTemp stringByReplacingOccurrencesOfString:@";" withString:@""];
        [m_dicMemoryValues   setObject:szStringTemp forKey:@"Noise Fail"];
    }
    else{
        ATSDebug(@"VCM Data Lost!");
        [szReturnValue setString:@"VCM Data Lost!"];
        return [NSNumber numberWithBool:NO];
    }
    szStringTemp = [NSString stringWithFormat:@"%@",szRawData];
    
    // the Camisp Fail is to Check the Camisp Command.
    if ([szStringTemp contains:@"Camisp Fail:"] && [szStringTemp contains:@"Test time:"]) {
        
        szStringTemp = [szStringTemp SubFrom:@"Camisp Fail:" include:NO];
        szStringTemp = [szStringTemp subTo:@"Test time:" include:NO];
        szStringTemp = [szStringTemp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        szStringTemp = [szStringTemp stringByReplacingOccurrencesOfString:@" " withString:@""];
        szStringTemp = [szStringTemp stringByReplacingOccurrencesOfString:@";" withString:@""];
        [m_dicMemoryValues   setObject:szStringTemp forKey:@"Camisp Fail"];
    }
    else{
        ATSDebug(@"VCM Data Lost!");
        [szReturnValue setString:@"VCM Data Lost!"];
        return [NSNumber numberWithBool:NO];
    }
    szStringTemp = [NSString stringWithFormat:@"%@",szRawData];
    
    // time cost in vcm test
    if ([szStringTemp contains:@"Test time:"] && [szStringTemp contains:@"seconds"]) {
        
        szStringTemp = [szStringTemp SubFrom:@"Test time:" include:NO];
        szStringTemp = [szStringTemp subTo:@"seconds" include:NO];
        szStringTemp = [szStringTemp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        szStringTemp = [szStringTemp stringByReplacingOccurrencesOfString:@" " withString:@""];
        szStringTemp = [szStringTemp stringByReplacingOccurrencesOfString:@";" withString:@""];
        [m_dicMemoryValues   setObject:szStringTemp forKey:@"Test time"];
    }
    else{
        ATSDebug(@"VCM Data Lost!");
        [szReturnValue setString:@"VCM Data Lost!"];
        return [NSNumber numberWithBool:NO];
    }
    
    return [NSNumber numberWithBool:YES];
}

// 2013.2.1
// Add those two functions to synthesize the compass test items
- (NSNumber	*)START_SYNCHRONIZE:(NSDictionary*)dictParam
				   RETURN_VALUE:(NSMutableString*)strReturnValue
{
	if(!gs_lockVCM)
		gs_lockVCM	= [[NSLock alloc] init];
	[gs_lockVCM lock];
	return [NSNumber numberWithBool:YES];
}

- (NSNumber	*)STOP_SYNCHRONIZE:(NSDictionary*)dictParam
				  RETURN_VALUE:(NSMutableString*)strReturnValue
{
	[gs_lockVCM unlock];
	return [NSNumber numberWithBool:YES];
}
-(NSNumber *)CATCH_MEASURE_VALUE:(NSDictionary* )dicParam RETURN_VALUE:(NSMutableString*)strReturnValue
{
    if([strReturnValue isEqualToString:@""])
    {
        return [NSNumber numberWithBool:NO];
    }
    NSString * szEvValue = [dicParam objectForKey:@"EvValue"];
    NSString * szXKey = [dicParam objectForKey:@"XValue"];
    NSString * szYKey = [dicParam objectForKey:@"YValue"];
    
    [strReturnValue stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSArray * aryKey = [strReturnValue componentsSeparatedByString:@"+"];
    
    if([aryKey count]!= 4)
    {
        return [NSNumber numberWithBool:NO];
    }
    NSString * szEV =[NSString stringWithFormat:@"%.1f",[[aryKey objectAtIndex:1] doubleValue]*0.01];
    NSString * szX = [NSString stringWithFormat:@"0.%@",[aryKey objectAtIndex:2]];
    NSString * szY = [NSString stringWithFormat:@"0.%@",[aryKey objectAtIndex:3]];
    
    [m_dicMemoryValues setObject:szEV forKey:szEvValue];
    [m_dicMemoryValues setObject:szX forKey:szXKey];
    [m_dicMemoryValues setObject:szY forKey:szYKey];
    
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

@end




