//
//  IADevice_Compass.m
//  Izual_Lu
//
//  Created by Lu Izual on 11-5-5.
//  Copyright 2011 PEGATRON. All rights reserved.
//

#import "IADevice_Compass.h"
#import "math.h"

@implementation TestProgress (IADevice_Compass)


//Start 2011.11.03 Add by Ming 
// Descripton: Get the Compass's data, and put those value in dictionary
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)GETDATA_SENSITIVITY:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue
{

    NSArray *arraySEN;
	
	double	doubleSEN_X = 0,doubleSEN_Y = 0,doubleSEN_Z = 0;
	
	if([m_dicMemoryValues valueForKey:@"Sensitivity"])
	{
		
		arraySEN = [[m_dicMemoryValues valueForKey:@"Sensitivity"] componentsSeparatedByString:@"\n"];
		if([arraySEN count] >= 3)
		{
            //2013/07/22 for J85 new diags response for sensitivity data
            NSString *strSEN_X = [arraySEN objectAtIndex:0];
            NSString *strSEN_Y = [arraySEN objectAtIndex:1];
            NSString *strSEN_Z = [arraySEN objectAtIndex:2];
            
            NSArray *arySEN_X = [strSEN_X componentsSeparatedByString:@" "];
            NSArray *arySEN_Y = [strSEN_Y componentsSeparatedByString:@" "];
            NSArray *arySEN_Z = [strSEN_Z componentsSeparatedByString:@" "];
            
            if ([arySEN_X count] >= 3 && [arySEN_Y count] >= 3  && [arySEN_Z count]>= 3)
            {
                NSScanner *scanerSEN_X = [NSScanner scannerWithString:[arySEN_X objectAtIndex:2]];
                NSScanner *scanerSEN_Y = [NSScanner scannerWithString:[arySEN_Y objectAtIndex:2]];
                NSScanner *scanerSEN_Z = [NSScanner scannerWithString:[arySEN_Z objectAtIndex:2]];
                
                if ([scanerSEN_X scanHexDouble:&doubleSEN_X])
                {
                    [m_dicMemoryValues setValue:[NSNumber numberWithDouble:doubleSEN_X] forKey:[NSString stringWithFormat:@"COMPASS_SEN_X"]];
                }
                
                if ([scanerSEN_Y scanHexDouble:&doubleSEN_Y])
                {
                     [m_dicMemoryValues setValue:[NSNumber numberWithDouble:doubleSEN_Y] forKey:[NSString stringWithFormat:@"COMPASS_SEN_Y"]];
                }
                
                if ([scanerSEN_Z scanHexDouble:&doubleSEN_Z])
                {
                    [m_dicMemoryValues setValue:[NSNumber numberWithDouble:doubleSEN_Z] forKey:[NSString stringWithFormat:@"COMPASS_SEN_Z"]];
                }
                
                ATSDebug(@"x = %f,y = %f,z = %f",doubleSEN_X,doubleSEN_Y,doubleSEN_Z);
                
                //new
                if (doubleSEN_X <0) {
                    doubleSEN_X += 256;
                }
                if (doubleSEN_Y <0) {
                    doubleSEN_Y += 256;
                }
                if (doubleSEN_Z <0) {
                    doubleSEN_Z += 256;
                }
            
            }
			
			
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
//End 2011.11.03 Add by Ming

/*Add by soshon_ran 2011-08-04
 description	:	caculate a array standard deviation
 Parameter: 
 arrTemp	:	The array will calculate 
 szReturnValue:	The standard deviation of the array*/
- (bool)Cal_STD:(NSArray *)arrTemp ReturnValue:(NSString **)szReturnValue
{
	
	double doubleTemp = 0.0, doubleSum1 = 0.0,doubleSum2 = 0.0;
	for(int i=0; i<[arrTemp count]; i++)
	{
		doubleTemp = [[arrTemp objectAtIndex:i] doubleValue];
		doubleSum1 += doubleTemp*doubleTemp;
		doubleSum2 += doubleTemp;
		
	}
	int iCount = [arrTemp count];
	double fResult = sqrt(((iCount*doubleSum1-doubleSum2*doubleSum2)/(iCount*(iCount-1)*1.0)));
	*szReturnValue = [NSString stringWithFormat:@"%f",fResult];
	return YES; 
}



//Start 2011.11.03 Add by Ming 
// Descripton:1.skip first two point 
//            2.save average and standard deviation to a array for "baseline,back,front,back_115,back_230"and so on!
//              The type is depended by the value of the dictionary .
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)COMPASS_SAMPLE:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue
{
    int istart = [[dicContents valueForKey:@"STARTFROM"]intValue];
    NSString *szTYPE = [dicContents valueForKey:@"VALUE"];
	int count = [[dicContents valueForKey:@"COUNT"] intValue];
    // as strReturnValue has a "\n" at the beginning, +1
    istart = istart+1;
    count = count+ istart -1;
    
    ATSDebug(@"Hello,I am CompassSample!  szTYPE is %@",szTYPE);
	NSArray *arrayRawData;
	NSArray *arrayRawDataItem[count];
	NSMutableArray *arrayCompassDataX = [[NSMutableArray alloc] init];
	NSMutableArray *arrayCompassDataY = [[NSMutableArray alloc] init];
	NSMutableArray *arrayCompassDataZ = [[NSMutableArray alloc] init];
	double	doubleAverageX = 0,doubleAverageY = 0,doubleAverageZ = 0;
    double  dCompassAverage_X=0,dCompassAverage_Y=0,dCompassAverage_Z=0;
    double  dCompassData_X = 0,dCompassData_Y = 0,dCompassData_Z = 0;
	
	double	doubleSEN_X = [[m_dicMemoryValues valueForKey:@"COMPASS_SEN_X"] doubleValue];
	double  doubleSEN_Y = [[m_dicMemoryValues valueForKey:@"COMPASS_SEN_Y"] doubleValue];
	double  doubleSEN_Z = [[m_dicMemoryValues valueForKey:@"COMPASS_SEN_Z"] doubleValue];
	ATSDebug(@"double sen x = %f,y =%f,z = %f",doubleSEN_X,doubleSEN_Y,doubleSEN_Z);
	if([strReturnValue length] >= 10)
	{
		//NSString *szParse = [*szReturnValue substringFromIndex:(range.location+range.length)];
		arrayRawData = [strReturnValue componentsSeparatedByString:@"\n"];
		if([arrayRawData count] >= count)
		{
			for(int i = istart; i <= count;i++)
			{
                //Add by mark, for new diag compass
                id compassInfo = [arrayRawData objectAtIndex:i];
                if([compassInfo isKindOfClass:[NSString class]])
                {
                    compassInfo = [compassInfo SubFrom:@"= " include:NO];
                    arrayRawDataItem[i] = [compassInfo componentsSeparatedByString:@","];
                }
				if ([arrayRawDataItem[i] count] >= 4)
				{
					if([arrayRawDataItem[i] count] == 4)
					{
                        //Add for new compass command,get X,Y,Z
                        dCompassData_X = [[arrayRawDataItem[i] objectAtIndex:0] doubleValue];
                        dCompassData_Y = [[arrayRawDataItem[i] objectAtIndex:1] doubleValue];
                        dCompassData_Z = [[arrayRawDataItem[i] objectAtIndex:2] doubleValue];
					}
					else if([arrayRawDataItem[i] count] == 5)
					{
						dCompassData_X = [[arrayRawDataItem[i] objectAtIndex:2]doubleValue];
						dCompassData_Y = [[arrayRawDataItem[i] objectAtIndex:3]doubleValue];
						dCompassData_Z = [[arrayRawDataItem[i] objectAtIndex:4]doubleValue];
					}
					
                    //Add by Lily,modify the compassData count for calculating the average.
                    dCompassAverage_X += dCompassData_X/(count-istart+1)*1.0;
                    dCompassAverage_Y += dCompassData_Y/(count-istart+1)*1.0;
                    dCompassAverage_Z += dCompassData_Z/(count-istart+1)*1.0;
					
                    //Modified by Lily,Remove the 0.15 multiplication due to the output is calculated from chip output to uT.
//					dCompassData_X = ((doubleSEN_X-128.0)*0.5/128.0+1)*dCompassData_X;
//					dCompassData_Y = ((doubleSEN_Y-128.0)*0.5/128.0+1)*dCompassData_Y;
//					dCompassData_Z = ((doubleSEN_Z-128.0)*0.5/128.0+1)*dCompassData_Z;
//
                    //betty 13/07/22 for J85 compass no need the formulat to calculat compass
                    dCompassData_X = dCompassAverage_X;
                    dCompassData_Y = dCompassAverage_Y;
                    dCompassData_Z = dCompassAverage_Z;
					
                    
					doubleAverageX += dCompassData_X;
					doubleAverageY += dCompassData_Y;
					doubleAverageZ += dCompassData_Z;
                    ATSDebug(@"dCompassData x = %f,y = %f,z = %f",dCompassData_X,dCompassData_Y,dCompassData_Z);
                    
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
            //2003/07/22 betty,modify the compassData count for calculating the average.
			doubleAverageX =dCompassAverage_X;
			doubleAverageY =dCompassAverage_Y;
			doubleAverageZ =dCompassAverage_Z;
            
            
			if([szTYPE isEqualToString:@"COMPASS_1"])
			{ 
                ATSDebug(@"szType is COMPASS_1");
				//double fCompass_1_Baseline_M = sqrt(pow(doubleAverageX, 2)+pow(doubleAverageY, 2)+pow(doubleAverageZ, 2));
				[m_dicMemoryValues setValue:[NSString stringWithFormat:@"%.6f",doubleAverageX ] forKey:@"Compass_1_Baseline_X"];
                [m_dicMemoryValues setValue:[NSString stringWithFormat:@"%.6f",dCompassAverage_X] forKey:@"Compass_RAW_X_Average"];
				[m_dicMemoryValues setValue:[NSString stringWithFormat:@"%.6f",doubleAverageY ] forKey:@"Compass_1_Baseline_Y"];
                [m_dicMemoryValues setValue:[NSString stringWithFormat:@"%.6f",dCompassAverage_Y] forKey:@"Compass_RAW_Y_Average"];
				[m_dicMemoryValues setValue:[NSString stringWithFormat:@"%.6f",doubleAverageZ ] forKey:@"Compass_1_Baseline_Z"];
                [m_dicMemoryValues setValue:[NSString stringWithFormat:@"%.6f",dCompassAverage_Z] forKey:@"Compass_RAW_Z_Average"]; 
                
                [arrayCompassDataX release];
                [arrayCompassDataY release];
                [arrayCompassDataZ release];
                return [NSNumber numberWithBool:YES];
				
			}
			else if([szTYPE isEqualToString:@"BA"]||[szTYPE isEqualToString:@"AA"]||[szTYPE isEqualToString:@"NORMAL"])//define BA for coco decision standing for the value  when south open 
                // define AA for coco decision standing for the value when north opne
            {
                double dCompassNMS=sqrt(pow(doubleAverageX, 2)+pow(doubleAverageY, 2)+pow(doubleAverageZ, 2));
                [m_dicMemoryValues setValue:[NSArray arrayWithObjects:[NSNumber numberWithDouble:doubleAverageX],[NSNumber numberWithDouble:doubleAverageY],[NSNumber numberWithDouble:doubleAverageZ],nil] forKey:[NSString stringWithFormat:KIADeviceKey_COMPASS_FIELD]];
                [m_dicMemoryValues setValue:[NSString stringWithFormat:@"%.6f",doubleAverageX] forKey:[NSString stringWithFormat:@"COMPASS_X_%@",szTYPE]];
                [m_dicMemoryValues setValue:[NSString stringWithFormat:@"%.6f",dCompassAverage_X] forKey:[NSString stringWithFormat:@"Compass_1_RAW_%@_X_Average",szTYPE]];
                
                [m_dicMemoryValues setValue:[NSString stringWithFormat:@"%.6f",doubleAverageY] forKey:[NSString stringWithFormat:@"COMPASS_Y_%@",szTYPE]];
                [m_dicMemoryValues setValue:[NSString stringWithFormat:@"%.6f",dCompassAverage_Y] forKey:[NSString stringWithFormat:@"Compass_1_RAW_%@_Y_Average",szTYPE]];
                
                [m_dicMemoryValues setValue:[NSString stringWithFormat:@"%.6f",doubleAverageZ] forKey:[NSString stringWithFormat:@"COMPASS_Z_%@",szTYPE]];
                [m_dicMemoryValues setValue:[NSString stringWithFormat:@"%.6f",dCompassAverage_Z] forKey:[NSString stringWithFormat:@"Compass_1_RAW_%@_Z_Average",szTYPE]];
                
                [m_dicMemoryValues setValue:[NSString stringWithFormat:@"%.6f",dCompassNMS]forKey:[NSString stringWithFormat:@"%@_M",szTYPE]];
                
                ATSDebug(@"Calculate field[%@_M] with compass data[%@],result[%f].",szTYPE,KIADeviceKey_COMPASS_FIELD,dCompassNMS);
                [arrayCompassDataX release];
                [arrayCompassDataY release];
                [arrayCompassDataZ release];
                return [NSNumber numberWithBool:YES];
            }
            
            else 
            {
                [strReturnValue setString: @"Get Compass Data failed!"];
                //andre modified new code
                [arrayCompassDataX release];
                [arrayCompassDataY release];
                [arrayCompassDataZ release];
                return [NSNumber numberWithBool:NO];
            }
        }
        else 
        {
            [strReturnValue setString: @"Compass init failed!"];
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


//Start 2012.01.31 Add by Sunny 
// Descripton:1.save average and standard deviation of the 12 stages
//            2.Calculate Prox,Centerpoint,Temp,Prox_Adj,SD_Adj,Temp_Adj,Ref,OFFSET of four status (Baseline,90Degree,0Degree,180Degree)
// Param:
//      NSDictionary    *dicContents        : Settings in script
//              Degree -> NSString*                     :   Degree of the slot(default is baseline)
//              Count -> NSString*                      :   How many lines need to be calculate
//              slot -> NSString*                       :   Slot Number
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)PROXBASELINETEST:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue
{
    //NSAutoreleasePool   *pool = [[NSAutoreleasePool alloc] init];
	
    int iCount = [[dicContents valueForKey:@"Count"] intValue];
    NSString  *szDegree = [dicContents valueForKey:@"Degree"];
	NSString  *szSlot = [dicContents valueForKey:@"slot"];
	
    //**************** initialize data wait to be calculated ********************
    double dBaselineProx = 0.0 ,   dBaselineCenterpoint =0.0, dBaselineTemp = 0.0,
    dBaselineProx_Adj =0.0, dBaselineSD_Adj =0.0,      dBaselineTemp_Adj =0.0,
    dBaselineRef =0.0,      dOFFSET =0.0;
    double dAverageStage[12] = {0};
    double dSDStage[12] = {0};
	int iDelta = 0;
    
    NSString *szSTD;
    NSArray *arrayRowData;
    NSArray *arraySensorReadingValue[iCount];
    NSString *strRowData = @"";
    NSMutableArray *arrayProx_Adj = [[[NSMutableArray alloc] init] autorelease];
    
    NSMutableArray *arrayStageData[12];
    for (int a=0; a<=11; a++)
    {
        arrayStageData[a] = [[[NSMutableArray alloc] init] autorelease];
    }
	//********************************************************************************
    
    
    //******************** Deal with data ********************************
    if (strReturnValue != nil)
    {
        arrayRowData = [strReturnValue componentsSeparatedByString:@"\n"];////////////*******//////////////////
		ATSDebug(@"Data have %d lines.",[arrayRowData count]);
        
        
        if ([arrayRowData count] >= iCount)
        {
            // ************************ Get data ***************************
            for (int i = 0; i < iCount; i++)
            {
                
                strRowData = [arrayRowData objectAtIndex:i];
                //=========================catch the sensor reading data(12 stages) of one line, and add to array of stages
                //NSString *szSensorReadingValue = [self catchFromString:strRowData begin:@"Sensor Reading: " end:@" -" TheRightString:NO];
                NSString *szSensorReadingValue = [self catchFromString:strRowData begin:@" = " end:@" (0.00) -" TheRightString:NO];//modified by Rachel
                if (![szSensorReadingValue isKindOfClass:[NSString class]] || [szSensorReadingValue isEqualToString:@""])
                {
                    ATSDebug(@"CATCH_VALUE => Catch Fail : Can't Find begin string [Sensor Reading: ] or end string [ -].");
                    return [NSNumber numberWithBool:NO];
                }
                else
                {
                    //arraySensorReadingValue[i] = [szSensorReadingValue componentsSeparatedByString:@", "];
                    arraySensorReadingValue[i] = [szSensorReadingValue componentsSeparatedByString:@" (0.00) "];//modified by Rachel
                }
                
                
                //=========================catch the prox of one line, and add prox together
                NSString *szProx = [self catchFromString:strRowData begin:@"Prox: " end:@","TheRightString:NO];
                if (![szProx isKindOfClass:[NSString class]] || [szProx isEqualToString:@""])
                {
                    ATSDebug(@"CATCH_VALUE => Catch Fail : Can't Find begin string [Prox: ] or end string [,].");
                    return [NSNumber numberWithBool:NO];
                }
                else
                {
                    dBaselineProx += [szProx doubleValue];
                }
                
                //=========================catch the Centerpoint of one line, and add prox together
                NSString *szCenterpoint = [self catchFromString:strRowData begin:@"Centerpoint: " end:@","TheRightString:NO];
                if (![szCenterpoint isKindOfClass:[NSString class]] || [szCenterpoint isEqualToString:@""])
                {
                    ATSDebug(@"CATCH_VALUE => Catch Fail : Can't Find begin string [Centerpoint: ] or end string [,].");
                    return [NSNumber numberWithBool:NO];
                }
                else
                {
                    dBaselineCenterpoint += [szCenterpoint doubleValue];
                }
                
                //=========================catch the Temp of one line, and add prox together
                NSString *szTemp = [self catchFromString:strRowData begin:@"Temp: " end:@","TheRightString:NO];
                if (![szTemp isKindOfClass:[NSString class]] || [szTemp isEqualToString:@""])
                {
                    ATSDebug(@"CATCH_VALUE => Catch Fail : Can't Find begin string [Temp: ] or end string [,].");
                    return [NSNumber numberWithBool:NO];
                }
                else
                {
                    dBaselineTemp += [szTemp doubleValue];
                }
                
                //===========================catch the Prox_Adj of one line, and add prox together
                NSString *szProx_Adj = [self catchFromString:strRowData begin:@"Adjusted_Prox: " end:@""TheRightString:NO];
                if (![szProx_Adj isKindOfClass:[NSString class]] || [szProx_Adj isEqualToString:@""])
                {
                    ATSDebug(@"CATCH_VALUE => Catch Fail : Can't Find begin string [Adjusted_Prox: ] or end string [\n].");
                    return [NSNumber numberWithBool:NO];
                }
                else
                {
                    dBaselineProx_Adj += [szProx_Adj doubleValue];
                    [arrayProx_Adj addObject:[NSNumber numberWithDouble:[szProx_Adj doubleValue]]];
                }
            }
            //*****************************************************
            
            
            //******************** Calculate data *****************
            //calculate stage's average and Standard Deviation
            for (int k=0; k < 12; k++)
            {
                for (int m=0; m<iCount; m++)
                {
                    
                    double data = [[[arraySensorReadingValue[m] objectAtIndex:k] stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%d:",k] withString:@""] doubleValue];//modified by Rachel
                    
                    
                    dAverageStage[k] += data; // sum Stage k from each line
                    [arrayStageData[k] addObject:[NSNumber numberWithDouble:data]];// add Stage k from each line to the stage array
                }
                dAverageStage[k] /=iCount*1.0; // average of Stage k
                [self Cal_STD:[NSArray arrayWithArray: arrayStageData[k]] ReturnValue:&szSTD];// standard deviation of Stage k
                dSDStage[k] = [szSTD doubleValue];
                [m_dicMemoryValues setValue:[NSString stringWithFormat:@"%d",(int)dSDStage[k]] forKey: [NSString stringWithFormat:@"SDStage%d",k+1]];
                [m_dicMemoryValues setValue:[NSString stringWithFormat:@"%d",(int)dAverageStage[k]] forKey:[NSString stringWithFormat:@"averageStage%d",k+1]];
            }
            
            //calculate average of prox.centerpoint.temp.prox_adj
            dBaselineProx /= iCount*1.0;
            dBaselineCenterpoint /= iCount*1.0;
            dBaselineTemp /= iCount*1.0;
            dBaselineProx_Adj /= iCount*1.0;
            
            //calculate Standard Deviation of all 50 "Adjusted_Prox" values
            [self Cal_STD:[NSArray arrayWithArray: arrayProx_Adj] ReturnValue:&szSTD];
            dBaselineSD_Adj = [szSTD doubleValue];
            
            //calculate Offset
            dBaselineTemp_Adj = dBaselineTemp - dBaselineCenterpoint;
            dBaselineRef = dAverageStage[4];
            dOFFSET = (dAverageStage[2]-dAverageStage[3])/4;
            
            if ([szSlot isEqualToString:@"1"])// slot 1 have no iDelta
            {
                
				NSArray *arrValue = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",(int)dBaselineProx],
									 [NSString stringWithFormat:@"%d",(int)dBaselineCenterpoint],
									 [NSString stringWithFormat:@"%d",(int)dBaselineTemp],
									 [NSString stringWithFormat:@"%d",(int)dBaselineProx_Adj],
									 [NSString stringWithFormat:@"%d",(int)dBaselineSD_Adj] ,
									 [NSString stringWithFormat:@"%d",(int)dBaselineTemp_Adj],
									 [NSString stringWithFormat:@"%d",(int)dBaselineRef],
									 [NSString stringWithFormat:@"%d",(int)dOFFSET], nil];
				NSArray *arrKeys = [NSArray arrayWithObjects:@"baselineProx",@"baselineCenterpoint",
									@"baselineTemp",@"baselineProx_Adj",@"baselineSD_Adj",
									@"baselineTemp_Adj",@"baselineRef",@"OFFSET",nil];
				for (int i = 0; i < [arrKeys count]; i++)
				{
					[m_dicMemoryValues setValue:[arrValue objectAtIndex:i] forKey:[arrKeys objectAtIndex:i]];
				}
                
				ATSDebug(@"baselineProx:%f,baselineCenterpoint:%f,baselineTemp:%f,baselineProx_Adj:%f,baselineSD_Adj:%f,baselineTemp_Adj:%f,baselineRef:%f,OFFSET:%f",dBaselineProx,dBaselineCenterpoint,dBaselineTemp,dBaselineProx_Adj,dBaselineSD_Adj,dBaselineTemp_Adj,dBaselineRef,dOFFSET);
				[strReturnValue setString:[NSString stringWithFormat:@"%d",(int)dBaselineProx_Adj]];
				return [NSNumber numberWithBool:YES];
            }
            else
            {
				//NSString *szBaselineProx_Adj = [m_dicProxCalPlist objectForKey:@"baselineProx_Adj"];
                NSString *szBaselineProx_Adj = [m_dicMemoryValues valueForKey:@"baselineProx_Adj"];// get the last baselineProx_Adj for calculate delta
                if (szBaselineProx_Adj != nil)
                {
                    iDelta = (int)dBaselineProx_Adj - [szBaselineProx_Adj intValue];
					
                    NSArray *arrValue = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%d",iDelta],
										 [NSString stringWithFormat:@"%d",(int)dBaselineProx],
										 [NSString stringWithFormat:@"%d",(int)dBaselineCenterpoint],
										 [NSString stringWithFormat:@"%d",(int)dBaselineTemp],
										 [NSString stringWithFormat:@"%d",(int)dBaselineProx_Adj],
										 [NSString stringWithFormat:@"%d",(int)dBaselineSD_Adj] ,
										 [NSString stringWithFormat:@"%d",(int)dBaselineTemp_Adj],
										 [NSString stringWithFormat:@"%d",(int)dBaselineRef],
										 [NSString stringWithFormat:@"%d",(int)dOFFSET], nil];
					NSArray *arrKeys = [NSArray arrayWithObjects:[NSString stringWithFormat:@"Delta_%@Degree",szDegree],
										[NSString stringWithFormat:@"baselineProxAtAngle_%@Degree",szDegree],
										[NSString stringWithFormat:@"baselineCenterpointAtAngle_%@Degree",szDegree],
										[NSString stringWithFormat:@"baselineTemp_%@Degree",szDegree],
										[NSString stringWithFormat:@"baselineProxAtAngle_Adj_%@Degree",szDegree],
										[NSString stringWithFormat:@"baselineSDAtAngle_Adj_%@Degree",szDegree],
										[NSString stringWithFormat:@"baselineTempAtAngle_Adj_%@Degree",szDegree],
										[NSString stringWithFormat:@"baselineRefAtAngle_%@Degree",szDegree],
										[NSString stringWithFormat:@"OFFSET_%@Degree",szDegree],nil];
					for (int i = 0; i < [arrKeys count]; i++)
					{
						[m_dicMemoryValues setValue:[arrValue objectAtIndex:i] forKey:[arrKeys objectAtIndex:i]];
                        
					}
					[strReturnValue setString:[NSString stringWithFormat:@"%d",iDelta]];
					return [NSNumber numberWithBool:YES];
                }
            }
            //*****************************************************
        }
        else
        {
            [strReturnValue setString:@"the return value is less than 50 bing"];
            ATSDebug(@"the strReturnValue is less than 50 bing");
        }
    }
    ATSDebug(@"the strRetuenValue from last command is nil, no data");
    return  [NSNumber numberWithBool:NO];
}





//End 2011.11.03 Add by Ming

//Start 2011.11.03 Add by Ming 
// Descripton:Record the delta value in dictionary for compass
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)RECORD_DELTA:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue
{
    NSString *szTYPE = [dicContents valueForKey:@"VALUE"];
    NSString *szAVGFirstTemp = [m_dicMemoryValues valueForKey:@"COMPASS_BASELINE"];
    NSArray  *arrayBaselineFirstTemp = [szAVGFirstTemp componentsSeparatedByString:@","];
    
    NSMutableArray *arrayBaselineSecondTemp = [[NSMutableArray alloc] init];
    [arrayBaselineSecondTemp addObjectsFromArray: [m_dicMemoryValues valueForKey:@"COMPASS_BASELINE"]];
    if ([szTYPE isEqualToString:@"cam mode front"]) 
	{
		[arrayBaselineSecondTemp addObjectsFromArray: [m_dicMemoryValues valueForKey:@"COMPASS_FRONT"]];
	}
	else if([szTYPE isEqualToString:@"cam mode back"])
	{
        [arrayBaselineSecondTemp addObjectsFromArray: [m_dicMemoryValues valueForKey:@"COMPASS_BACK"]];
	}
	else if([szTYPE isEqualToString:@"AF pos (calibrated) 115"])
	{
        [arrayBaselineSecondTemp addObjectsFromArray: [m_dicMemoryValues valueForKey:@"COMPASS_BACK_115"]];
	}
    else if([szTYPE isEqualToString:@"AF pos (calibrated) 230"])
	{
        [arrayBaselineSecondTemp addObjectsFromArray: [m_dicMemoryValues valueForKey:@"COMPASS_BACK_230"]];
	}
	else 
	{
        ATSDebug(@"szType is not cam mode front");
        [arrayBaselineSecondTemp release];
		return [NSNumber numberWithBool:NO];
	}
	
    //NSMutableArray  *DeltaTemp = [[NSMutableArray alloc] init];
	if([arrayBaselineFirstTemp count] >=6 && [arrayBaselineSecondTemp count] >= 6 )
	{
		for(int i=0; i<=2; ++i)
		{
			[arrayBaselineSecondTemp replaceObjectAtIndex:i withObject: 
             [NSNumber numberWithDouble:([[arrayBaselineSecondTemp objectAtIndex:i] doubleValue]-[[arrayBaselineFirstTemp objectAtIndex:i] doubleValue]) ] ];
			//[DeltaTemp addObject:[NSNumber numberWithDouble:doubleDelta]];
		}
	}
    
	else
	{
        ATSDebug(@"Get compass data error");
		[strReturnValue setString:@"Get Compass Data error"];
		//[DeltaTemp release];
        [arrayBaselineSecondTemp release];
		return [NSNumber numberWithBool:NO];
	}
    //for UI output
    [m_dicMemoryValues setValue:[NSString stringWithFormat:@"%.6f",[[arrayBaselineSecondTemp objectAtIndex:0] doubleValue]] forKey:[NSString stringWithFormat:@"%@_Avg_delta_X",szTYPE]];
    [m_dicMemoryValues setValue:[NSString stringWithFormat:@"%.6f",[[arrayBaselineSecondTemp objectAtIndex:1] doubleValue]] forKey:[NSString stringWithFormat:@"%@_Avg_delta_Y",szTYPE]];
    [m_dicMemoryValues setValue:[NSString stringWithFormat:@"%.6f",[[arrayBaselineSecondTemp objectAtIndex:2] doubleValue]] forKey:[NSString stringWithFormat:@"%@_Avg_delta_Z",szTYPE]];
    
	/*
	szFormtTemp = [NSString stringWithFormat:@"%f,%f,%f,%f,%f,%f",[[DeltaTemp objectAtIndex:0] doubleValue],
				   [[DeltaTemp objectAtIndex:1]doubleValue],[[DeltaTemp objectAtIndex:2] doubleValue],
				   [[arrayBaselineSecondTemp objectAtIndex:3]doubleValue],[[arrayBaselineSecondTemp objectAtIndex:4]doubleValue],
				   [[arrayBaselineSecondTemp objectAtIndex:5]doubleValue]];
    */
	[m_dicMemoryValues setObject:arrayBaselineSecondTemp forKey:[NSString stringWithFormat:@"%@",szTYPE]];
    ATSDebug(@"Set the dictionary with key szType:%@",szTYPE);
	//[DeltaTemp release];
    [arrayBaselineSecondTemp release];
	return [NSNumber numberWithBool:YES];


}
//End 2011.11.03 Add by Ming

//Start 2011.11.03 Add by Ming 
// Descripton:Get Camera SN
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)GET_CAMERA_SN:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue
{
    
    [strReturnValue setString: [strReturnValue stringByReplacingOccurrencesOfString:@"\r" withString:@""]];
    
	NSRange rangeSensorID = [strReturnValue rangeOfString:@"sensorID : "];//add space new code
	NSString *strSensorID = @"";
    
	if ((NSNotFound != rangeSensorID.location) && (rangeSensorID.length>0) && ((rangeSensorID.location+rangeSensorID.length)<=[strReturnValue length])) 
    {
		NSArray *arrTemp = [strReturnValue componentsSeparatedByString:@"\n"];
		if ([arrTemp count] >=2 ) 
        {
			strSensorID = [NSString stringWithFormat:@"%@",[arrTemp objectAtIndex:0]];//change to 0 new code
			strSensorID =[strSensorID substringFromIndex:rangeSensorID.location + rangeSensorID.length];
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
        //
        [strReturnValue setString:@"Don't get the right data"];
        return [NSNumber numberWithBool:NO];
    }
	NSMutableString * strInfo = [[NSMutableString alloc] initWithString:@""];
    //NSMutableString * strTemp = [[NSMutableString alloc] initWithString:@""];
	NSString *strInfoA = @"";
	NSString *strInfoB = @"";
	if ([strSensorID isEqual:@"0x145"]) 
	{
		NSRange rangeInfoA = [strReturnValue rangeOfString:@"0x140 : "];
		if ((NSNotFound != rangeInfoA.location) && (rangeInfoA.length>0) && ((rangeInfoA.location+rangeInfoA.length)<=[strReturnValue length])) 
		{
			strInfoA = [strReturnValue substringFromIndex:rangeInfoA.location + rangeInfoA.length];
			NSArray *arrInfoTemp = [strInfoA componentsSeparatedByString:@"\n"];
			if ([arrInfoTemp count] >= 2) {
				strInfoA = [NSString stringWithFormat:@"%@",[arrInfoTemp objectAtIndex:0]];
				strInfoB = [NSString stringWithFormat:@"%@",[arrInfoTemp objectAtIndex:1]];
			}
			else
			{
				[strReturnValue setString:@"Don't get camera SN"];
                [strInfo release];
				return [NSNumber numberWithBool:NO];
			}
			NSRange rangeInfoB =[strInfoB rangeOfString:@"0x148 : "];
			if ((NSNotFound != rangeInfoB.location) && (rangeInfoB.length>0) && ((rangeInfoB.length+rangeInfoB.location)<=[strInfoB length])) 
            {
				strInfoB = [strInfoB substringFromIndex:rangeInfoB.location + rangeInfoB.length];
			}
            else
            {
                //
                [strInfo release];
                [strReturnValue setString:@"Don't get camera SN"];
				return [NSNumber numberWithBool:NO];
            }
			NSString *strInfoTemp = [NSString stringWithFormat:@"%@%@",strInfoA,strInfoB];			
			ATSDebug(@"Info:%@",strInfoTemp);
			NSArray *arrInfo = [strInfoTemp componentsSeparatedByString:@" "];
			if ([arrInfo count] >= 10) 
            {
				for (int i = 3; i <= 10; i++)
				{
					NSString *strData = [arrInfo objectAtIndex:i];
					strData = ([strData length] == 4) ? [strData stringByReplacingOccurrencesOfString:@"0x" withString:@""]
					: [strData stringByReplacingOccurrencesOfString:@"x" withString:@""];
					strData = [NSString stringWithFormat:@" %@",strData];
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
            //
            [strReturnValue setString:@"Don't get camera SN"];
            [strInfo release];
            return [NSNumber numberWithBool:NO];
        }
	}
	else 
	{
		NSRange rangeInfoA = [strReturnValue rangeOfString:@"0x0 : "];
		if ((NSNotFound != rangeInfoA.location) && (rangeInfoA.length>0) && ((rangeInfoA.length+rangeInfoA.location)<=[strReturnValue length]))
		{
			strInfoA = [strReturnValue substringFromIndex:rangeInfoA.location + rangeInfoA.length];
			NSArray *arrInfoTemp = [strInfoA componentsSeparatedByString:@"\n"];
			if ([arrInfoTemp count] >= 1) {
				strInfoA = [NSString stringWithFormat:@"%@",[arrInfoTemp objectAtIndex:0]];
			}
			else
			{
				[strReturnValue setString:@"Don't get camera SN"];
                [strInfo release];
				return [NSNumber numberWithBool:NO];
			}
			NSArray *arrInfo = [strInfoA componentsSeparatedByString:@" "];
			if ([arrInfo count] >= 4) {
				for (int i = 0; i <= 4; i++)
				{
					NSString *strData = [arrInfo objectAtIndex:i];
					strData = ([strData length] == 4) ? [strData stringByReplacingOccurrencesOfString:@"0x" withString:@""]
					: [strData stringByReplacingOccurrencesOfString:@"x" withString:@""];
					strData = [NSString stringWithFormat:@" %@",strData];
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
            //
            [strReturnValue setString:@"Don't get camera SN"];
            [strInfo release];
            return [NSNumber numberWithBool:NO];
        }
		
        //strInfo = [NSString stringWithFormat:@"%@ 00 00 00",strInfo];				//modified by jingfu ran 
        [strInfo appendString:@" 00 00 00"];
        
	}
	NSString *strRF_cam_SN = [NSString stringWithFormat:@"%@",strInfo];
 
	[strInfo release];
	[m_dicMemoryValues setValue:strRF_cam_SN forKey:@"RF_cam_SN"];

    return [NSNumber numberWithBool:YES];
}
//End 2011.11.03 Add by Ming


/****************************************************************************************************
 Start 2012.4.16 Add note by Yaya 
 Descripton:  switch the int data to HEX , and change format from "AABB" to "BB AA".
 Param:
 int iResult : the data need to switch.
 ****************************************************************************************************/
- (NSString *)int_2_2comp:(int)iResult
{
	NSMutableString *strTemp = [[NSMutableString alloc] init];
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
	{
		//[strTemp setString:[[NSString stringWithFormat:@"%08X",iResult] substringFromIndex:4]];//algorism charge to hex
		//[strTemp setString:[[strTemp substringFromIndex:2]stringByAppendingString:[strTemp substringToIndex:2]]];
		//[strTemp insertString:@" " atIndex:2];
        [strTemp setString:[NSString stringWithFormat:@"%02X %02X",iResult&0xFF,(iResult>>8)&0xFF]];//new code
	}
	//NSString *strResult = strTemp;								//modified by jingfu ran 
    NSString  *strResult = [NSString stringWithFormat:@"%@",strTemp];
	//[strResult retain];
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
unsigned short CalCRC16_1021(unsigned char x[], unsigned short BufferLen)
{
    unsigned short i;
    unsigned char  j;
    unsigned short crc16 = 0;
    unsigned short mask = 0x1021; 
    unsigned char *pByteBuffer;
    unsigned char tmpbyte;
    unsigned short calval;
	
    pByteBuffer = &x[0];
	
    for (i = 0; i < BufferLen; i++)
    {
        tmpbyte = *pByteBuffer;
        calval = tmpbyte << 8; 
        for (j = 0; j < 8; j++)
        {
            if ((crc16 ^ calval) & 0x8000) 
                crc16 = (crc16 << 1) ^ mask;
            else
                crc16 <<= 1;
			
            calval <<= 1;
        }
        pByteBuffer++;
    }
    return crc16;
}

// 2012.04.16 Modified by Andre 
// Descripton:Transform AA BB CC DD to 0xDDCCBBAA. generate CPAS value to be written.
// Param:
//      NSString *szNormalOrdered    : Return value(CPAS Value)
- (NSString *)norm2diags_ordering:(NSString *)szNormalOrdered
{
	NSMutableString *strTemp = [[NSMutableString alloc] init];
	NSMutableString *strResult = [[NSMutableString alloc] init];
	
	[strTemp setString:szNormalOrdered];
	[strResult setString:@""];
	//int iNormalOrdered =[szNormalOrdered length];
    
    //modified by desikan new code
	while ((([strTemp length]+1) % 12) != 0) 
	{
		[strTemp setString:[NSString stringWithFormat:@"%@ 00",strTemp]];
	}
	
	int iStep = ([strTemp length] + 1)/12;
	NSArray *arrDiagsOrdered=[strTemp componentsSeparatedByString:@" "];
	
	if (68 == [arrDiagsOrdered count] ) 
	{
		for(int i = 0; i < iStep; i++)
		{
			[strResult appendFormat:@" 0x"];
			for (int j = 3; j >= 0; j--)
			{
				
				[strResult appendString:[arrDiagsOrdered objectAtIndex:i*4+j]];//Ex: Diags writes 0xAABBCCDD, the OS reads DD CC BB AA.
			}
		}
	}
	
	NSString *szReturnValue = [NSString stringWithFormat:@"%@",strResult];
	//[szReturnValue retain];
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
- (NSNumber*)CompassValue_NorthMuinsSouth:(NSDictionary*)dicPara ReturnValue:(NSMutableString *)szReturnValue
{
    //Basic judge
    if (![szReturnValue isKindOfClass:[NSString class]]) 
    {
        return [NSNumber numberWithBool:NO];
    }
    
    //Calculate compass NMS value
   // NSString *szType = [dicPara valueForKey:KIADeviceKey_TYPE];
    double fValueX = 0;
    double fValueY = 0;
    double fValueZ = 0;
    double fCompassNMS;
    /*
    if([szType isEqualToString:KIADeviceKey_NORMAL])
	{
        NSArray *aryDataWithoutType = [m_dicMemoryValues valueForKey:KIADeviceKey_COMPASS_FIELD];
        fValueX = [[aryDataWithoutType objectAtIndex:0] floatValue];
        fValueY = [[aryDataWithoutType objectAtIndex:1] floatValue];
        fValueZ = [[aryDataWithoutType objectAtIndex:2] floatValue];
        fCompassNMS = sqrt(fValueX*fValueX+fValueY*fValueY+fValueZ*fValueZ);
        [szReturnValue setString:[NSString stringWithFormat:@"%f",fCompassNMS]];
        ATSDebug(@"Calculate field[%@] with compass data[%@],result[%f].",szType,KIADeviceKey_COMPASS_FIELD,fCompassNMS);
        return [NSNumber numberWithBool:YES];
	}
     */
	//if([szType isEqualToString:KIADeviceKey_SPECIAL])
	//{
	if ([m_dicMemoryValues valueForKey:@"COMPASS_NMS_X"]&&
		[m_dicMemoryValues valueForKey:@"COMPASS_NMS_Y"]&&
		[m_dicMemoryValues valueForKey:@"COMPASS_NMS_Z"]) 
	{
		fValueX = [[m_dicMemoryValues valueForKey:@"COMPASS_NMS_X"] doubleValue];
		
		fValueY = [[m_dicMemoryValues valueForKey:@"COMPASS_NMS_Y"] doubleValue];
		
        fValueZ = [[m_dicMemoryValues valueForKey:@"COMPASS_NMS_Z"] doubleValue];
		ATSDebug(@"compass_nms_x = %f, y = %f,z = %f",fValueX,fValueY,fValueZ);
        fCompassNMS = sqrt(fValueX*fValueX+fValueY*fValueY+fValueZ*fValueZ);
        [szReturnValue setString:[NSString stringWithFormat:@"%f",fCompassNMS]];
        ATSDebug(@"Calculate field with compass data[COMPASS_NMS_X/Y/Z],result[%f].",fCompassNMS);
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
- (NSNumber*)Delta_Compass:(NSDictionary*)dicPara ReturnValue:(NSMutableString*)szReturnValue
{
    //Basic judge
    if (![dicPara isKindOfClass:[NSDictionary class]]
        || ![dicPara valueForKey:KIADeviceKey_AXIS]
        || ![szReturnValue isKindOfClass:[NSString class]]) 
    {
        ATSDebug(@"Basic judge error");
        return [NSNumber numberWithBool:NO];
    }
    
    //Calculate compass delta value 
    NSString *szType = [dicPara valueForKey:KIADeviceKey_AXIS];
    NSString *szNorthValue = [m_dicMemoryValues valueForKey:KIADeviceKey_NORTH_M];
    NSString *szSouthValue = [m_dicMemoryValues valueForKey:KIADeviceKey_SOUTH_M];
    
    // for QT1 item Compass_1_Test_NMS_M0 =  'Compass_1_North_M' - 'Compass_1_South_M'
    if ([szType isEqualToString:KIADeviceKey_NMS]) 
    {
        ATSDebug(@"szType is %@",szType);
        if (szNorthValue && szSouthValue) 
        {
            double fValueSubtract = [szNorthValue doubleValue]-[szSouthValue doubleValue];
            [szReturnValue setString:[NSString stringWithFormat:@"%f",fValueSubtract]];
            ATSDebug(@"Calculate delta value with SOUTH_M and NORTH_M,result[%f].",fValueSubtract);
            return [NSNumber numberWithBool:YES];
        }
        else
            return [NSNumber numberWithBool:NO];
    } 
    // for QT1 item Compass_1_Test_NMS_M =  'Compass_1_North_M' + 'Compass_1_South_M'
    else if([szType isEqualToString:kIADeviceKey_NMS_M])
    {
     		if (szNorthValue && szSouthValue)
        {
            double	fValueSubtract = [szNorthValue doubleValue] + [szSouthValue doubleValue];
            [szReturnValue setString:[NSString stringWithFormat:@"%f",fValueSubtract]];
            ATSDebug(@"Calculate delta value with SOUTH_M and NORTH_M,result[%f].",fValueSubtract);
            return [NSNumber numberWithBool:YES];
        }	  
        else
            return [NSNumber numberWithBool:NO];
    }
    else
    {
        NSNumber *numValueBA = [m_dicMemoryValues valueForKey:[NSString stringWithFormat:@"COMPASS_%@_BA",szType]];
        NSNumber *numValueAA = [m_dicMemoryValues valueForKey:[NSString stringWithFormat:@"COMPASS_%@_AA",szType]];
        if(numValueBA && numValueAA)
			{
				 double x=[numValueAA doubleValue]-[numValueBA doubleValue];
         [szReturnValue setString:[NSString stringWithFormat:@"%f",x]];
				 [m_dicMemoryValues setValue:[NSString stringWithString:szReturnValue] forKey:[NSString stringWithFormat:@"COMPASS_NMS_%@",szType]];
         ATSDebug(@"Calculate delta value[%@] with COMPASS_NMS_BA and COMPASS_NMS_AA,and send value to dicMemoryValues with key[COMPASS_NMS_%@].",szReturnValue,szType);
         return [NSNumber numberWithBool:YES];
			}
			else
         return [NSNumber numberWithBool:NO];
    }
}

// Set whether we need to count fail receive
//  Descripton: Count the receive fails, and save the fail count to m_iCamispFailCount. 
//  Param:
//           NSDictionary             *dicPara        :   Setting
//              NEEDJUDGEFAILRECEIVE   -> Boolean    :   Set whether we need to count if the fail receive exits in return value 
- (NSNumber*)Set_Judge_Fail_Receive:(NSDictionary*)dicPara
{
    m_bNeedJudgeFailReceive = [[dicPara valueForKey:@"NEEDJUDGEFAILRECEIVE"]boolValue];
    
    return [NSNumber numberWithBool:YES];
}

//Start 2012.01.31 Add by Sunny 
// Descripton:Write CPCL into unit.
// Param:
//      NSDictionary    *dicContents        :   Setting
//              ***************** These values come from the customer ********************
//              Version Number -> NSString*                     :   Version Number of CPCL
//              CalibrationDataSiza -> NSString*                :   Size of calibration data
//              OffsetFactorsElec1 -> NSString*                 :   Offset factor electrode A (pos, neg)
//              OffsetFactorsElec2 -> NSString*                 :   Offset factor electrode B (pos, neg)
//              OffsetFactorsC13 -> NSString*                   :   Offset factor C13
//              Alpha first byte -> NSString*                   :   Alpha value 1st byte
//              Alpha value -> NSString*                        :   Alpha value 2nd byte
//              Threshold2 -> NSString*                         :   Threshold2
//              ThresholdPositive -> NSString*                  :   Threshold positive
//              ThresholdNegative -> NSString*                  :   Threshold negative
//              MaxAdjustLimit -> NSString*                     :   Max adjust prox limit
//              CenterpointTolerance -> NSString*               :   Tolerance centerpoint
//              TempTolerance -> NSString*                      :   Tolerance temp
//              Alpha1 first byte -> NSString*                  :   Alpha1 value 1st byte
//              Alpha1 value -> NSString*                       :   Alpha1 value 2nd byte
//              Reserved -> NSString*                           :   Reserved value for CPCL
//              ***************************************************************************
//
//              FailCancel -> Boolean                           :   If the process of CPCL fail before, do not write CPCL to unit(YES).
//
//              SEND_COMMAND:-> NSDictionary*                   :   Write CPCL command
//              READ_COMMAND:RETURN_VALUE: -> NSDictionary*     :   Receive CPCL command
//      NSMutableString      *szReturnValue :   Return value
-(NSNumber*)WRITECPCL:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue
{
    bool    bFailCancle    =   [[dicContents objectForKey:@"FailCancle"] boolValue];
    if(!m_bFinalResult && bFailCancle)
    {
        ATSDebug(@"The process of CPCL has failed before this test item, no need to write CPCL into unit");
        return [NSNumber numberWithBool:NO];
    }
	NSMutableString *strCPCL = [[NSMutableString alloc] init];
	NSString *strAdditionalInformation;
	NSString *strCheckSum;
	int iSum = 0;	
    
    //***************** These values come from the customer, setting in plist ********************
	NSString *strVersion            = [dicContents valueForKey:@"Version Number"];
	NSString *strAlphaValue         = [dicContents valueForKey:@"Alpha value"];
	NSString *strAlpha1Value        = [dicContents valueForKey:@"Alpha1 value"];
	NSString *strAlphaFristByte     = [dicContents valueForKey:@"Alpha first byte"];
	NSString *strAlpha1FristByte    = [dicContents valueForKey:@"Alpha1 first byte"];
	NSString *strReserved           = [dicContents valueForKey:@"Reserved"];
    NSString *szThreshold2          = [dicContents valueForKey:@"Threshold2"];   //modify by desikan  start
    NSString *szOffsetFactorsElec1  = [dicContents valueForKey:@"OffsetFactorsElec1"];
    NSString *szOffsetFactorsElec2  = [dicContents valueForKey:@"OffsetFactorsElec2"];
    NSString *szOffsetFactorsC13    = [dicContents valueForKey:@"OffsetFactorsC13"];
    NSString *szThresholdPositive   = [dicContents valueForKey:@"ThresholdPositive"];
    NSString *szThresholdNegative   = [dicContents valueForKey:@"ThresholdNegative"];
    NSString *szMaxAdjustLimit      = [dicContents valueForKey:@"MaxAdjustLimit"];
    NSString *szCenterpointTolerance= [dicContents valueForKey:@"CenterpointTolerance"];
    NSString *szTempTolerance       = [dicContents valueForKey:@"TempTolerance"];
    NSString *szCalibrationDataSiza = [dicContents valueForKey:@"CalibrationDataSiza"];//modify by desikan end
    //***************************************************************************
    
	[m_dicMemoryValues setValue:strVersion forKey:@"Version Number"];
	[m_dicMemoryValues setValue:strAlphaValue forKey:@"Alpha value"];
	
	//****************** Determine the Critical Angle ***************************
    //meaning the position that measured the lowest Delta Value of all Three Position Fixtures
	int iCurrentProxAt0Degree   = [[m_dicMemoryValues objectForKey:@"Delta_0Degree"]intValue];
	int iCurrentProxAt90Degree  = [[m_dicMemoryValues objectForKey:@"Delta_90Degree"]intValue];
	int iCurrentProxAt180Degree = [[m_dicMemoryValues objectForKey:@"Delta_180Degree"]intValue];
	int iCriticalAngleDelta = MIN(iCurrentProxAt0Degree, iCurrentProxAt90Degree);
	//iCriticalAngleDelta = MIN(iCriticalAngleDelta, iCurrentProxAt180Degree);//get min delta of 0,90,180 degree
	ATSDebug(@"min criticalangleDelta is %d",iCriticalAngleDelta);
	//***************************************************************************
    
    
	//******************* Get Critical position value *****************************
	if (iCriticalAngleDelta == iCurrentProxAt0Degree)
	{
		strAdditionalInformation = @"00 00";
		[m_dicMemoryValues setValue:@"0" forKey:@"Critical position"];
	}
	else if (iCriticalAngleDelta == iCurrentProxAt90Degree)
	{
		strAdditionalInformation = @"00 01";
		[m_dicMemoryValues setValue:@"1" forKey:@"Critical position"];
	}
	else if (iCriticalAngleDelta == iCurrentProxAt180Degree)
	{
		strAdditionalInformation = @"00 02";
		[m_dicMemoryValues setValue:@"2" forKey:@"Critical position"];
	}
    ATSDebug(@"Critical position: %@", strAdditionalInformation);
	//***************************************************************************
	
    
    //******************** Getting needed data ********************************** 
	NSMutableArray *arrData = [[NSMutableArray alloc]initWithObjects:
							   [m_dicMemoryValues objectForKey:@"OFFSET"],
							   [m_dicMemoryValues objectForKey:@"baselineProx"],
							   [m_dicMemoryValues objectForKey:@"baselineCenterpoint"],
							   [m_dicMemoryValues objectForKey:@"baselineTemp"],
							   [NSString stringWithFormat:@"%d",iCriticalAngleDelta],
							   //[m_dicMemoryValues objectForKey:@"baselineRef"],   // modify by desikan  change the 
                               //For the CPCl config, the "baseline ref value (stage 4 output)" at Bits [239:224] will now be a secondary threshold value.   It will be labeled "Threshold2"
                               szThreshold2,
							   strVersion,strAlphaValue,strAlpha1Value,
							   nil];
	
	NSMutableString *strTemp = [[NSMutableString alloc]init];
	if ([arrData count] != 9) 
	{
		ATSDebug(@"Get not enough data");
        [arrData release];
        [strCPCL release];
        [strTemp release];
		return [NSNumber numberWithBool:NO];
	}
    //***************************************************************************
    
    
    //****************** Transform the needed data format (ex.@"0A 1B")**********
	for (int i = 0; i < [arrData count]; i++) 
	{
		if (i < 5) //modify by desikan
		{
			// data need to be transformed to 16 bit
            [strTemp setString:[[NSString stringWithFormat:@"%08X",[[arrData objectAtIndex:i] intValue]]substringFromIndex:4]];
		}
		else
		{
            // data already 16 bit
			[strTemp setString:[NSString stringWithFormat:@"%@",[arrData objectAtIndex:i]]];
		}
		[strTemp insertString:@" " atIndex:2];
       // NSString *str = [NSString stringWithString:strTemp];
		//[arrData replaceObjectAtIndex:i withObject:[strTemp copy]];
        [arrData replaceObjectAtIndex:i withObject:[NSString stringWithString:strTemp]];
	}
    //***************************************************************************
    
    
	//***************************** Calculate CheckSum **************************
    //Step: 
    //1.Transfer all the bytes to dec type
    //2.Sum all the dec values
    //3.Calculate 2's compliment of sum
	[strTemp setString:[NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@ %@ %@ %@ %@ %@ %@ %@ %@ %@ %@ %@",
						 [arrData objectAtIndex:0],szOffsetFactorsElec1,szOffsetFactorsElec2,szOffsetFactorsC13,[arrData objectAtIndex:7],strAlphaFristByte,[arrData objectAtIndex:1],[arrData objectAtIndex:2],[arrData objectAtIndex:3],[arrData objectAtIndex:4],[arrData objectAtIndex:5],szThresholdPositive,szThresholdNegative,szMaxAdjustLimit,szCenterpointTolerance,szTempTolerance,[arrData objectAtIndex:8],strAlpha1FristByte]]; //modify by desikan
	NSString *strResult = [NSString stringWithFormat:@"%@",strTemp];
	ATSDebug(@"Data for Calculate Checksum: %@",strResult);
    
    ATSDebug(@"Data to Calculate Checksum are:")
	NSDictionary *dicPara ;
	NSArray *arrCheckSum = [strTemp componentsSeparatedByString:@" "];
	//Sum
	for (int i = 0; i < [arrCheckSum count]; i++) 
	{
		dicPara = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:16],@"CHANGE",[NSNumber numberWithInt:10],@"TO",nil];
		[strTemp setString:[arrCheckSum objectAtIndex:i]];
		[self NumberSystemConvertion:dicPara RETURN_VALUE:strTemp];
        ATSDebug(@" %@ ",strTemp);
		iSum += [strTemp intValue];
	}
	ATSDebug(@"End");
    
	//Get 2's complement,
	strCheckSum = [NSString stringWithFormat:@"%d",((iSum ^ 0xffff) + 1)];
				   //[m_mathLibrary GetComplementOfInt:iSum BitNumber:16]];
	
	strCheckSum = [NSString stringWithFormat:@"%02X %02X",([strCheckSum intValue]>>8)&0xFF,[strCheckSum intValue]&0xFF];

	ATSDebug(@"CheckSum is %@",strCheckSum);
	//***************************************************************************
    
    
    //********************* Combine CPCL ****************************************
	strResult = [NSString  stringWithFormat:@"%@ %@ %@ %@ %@ %@",[arrData objectAtIndex:6],strAdditionalInformation,szCalibrationDataSiza,strCheckSum,strResult,strReserved];//modify by desikan
	ATSDebug(@"Result:%@",strResult);

	//Diags writes 0xAABBCCDD, the OS reads CCDD AABB.
    //ex.0x0702 0x0000 transform to 0x00000702
	NSArray *arrCPCl=[strResult componentsSeparatedByString:@" "];
	if (48 == [arrCPCl count] ) 
	{
		for(int i = 0; i < ([strResult length] + 1)/12; i++)
		{
			[strCPCL appendFormat:@" 0x"];
			for (int j = 1; j >= 0; j--)
			{
				[strCPCL appendString:[arrCPCl objectAtIndex:i*4+j*2]];
				[strCPCL appendString:[arrCPCl objectAtIndex:i*4+j*2+1]];
			}
		}
	}	
	[m_dicMemoryValues setValue:[NSString stringWithFormat:@"%@",strCPCL] forKey:@"CPCl"];
	ATSDebug(@"CPCL is %@",strCPCL);
	//***************************************************************************
    

	//*************************** Write CPCl to DUT *****************************
	NSDictionary *dicWriteCPCL = [dicContents objectForKey:@"SEND_COMMAND:"];
	NSDictionary *dicReceiveFromCPCL = [dicContents objectForKey:@"READ_COMMAND:RETURN_VALUE:"];
	NSNumber *retValue;  
	[self SEND_COMMAND:dicWriteCPCL];
	retValue = [self READ_COMMAND:dicReceiveFromCPCL RETURN_VALUE:strReturnValue];
	if (retValue == [NSNumber numberWithBool:YES])
	{
		[strReturnValue setString:strCPCL]; 
        [arrData release];
        [strTemp release];
		[strCPCL release];
		return [NSNumber numberWithBool:YES];
	}else
	{
		[strReturnValue setString:@"Test Fail didn't write CPCL"];
        [arrData release];
        [strTemp release];
		[strCPCL release];
        ATSDebug(@"Can not write CPCL into unit");
		return [NSNumber numberWithBool:NO];
	}
    //***************************************************************************
}
/*2013.01.22 Modified by Lucky
 *	Descripton:Change test case name and spec with Board ID.
 *		Ex. Orignal:Testcase is AABB. If Board ID is 0x04, the name should be J75 AABB.
 *          Orignal:Testcase is AABB. If Board ID is 0x06, the name should be J76 AABB.
 *          Orignal:Testcase is AABB. If Board ID is 0x08, the name should be J77 AABB.
 * Param:
 *      NSDictionary    *dicContents	:   Setting
 *						CASENAME	:	name as J75/J76/J77
 *						SPEC		:	the name of different specs
 *      NSMutableString *szReturnValue	:   Return value
 */
- (NSNumber *)CHANGE_TESTCASENAME_WITH_BOARDID:(NSDictionary *)dicContents RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSString		*szBoardId		= [m_dicMemoryValues valueForKey:@"boardid"];
	NSDictionary	*dicNameAndSpec	=[dicContents objectForKey:szBoardId];
	NSString		*szUpdatedTestItem;
	NSString		*szCurrentSpec;
	[m_strSpecName setString:kFZ_Script_JudgeCommonP106];	// set default sepc
	
	if (dicNameAndSpec !=nil)
	{
		//change name
		szUpdatedTestItem	= [dicNameAndSpec objectForKey:@"CASENAME"];
		NSString *szCurrentTestItem = [NSString stringWithFormat:@"%@ %@",szUpdatedTestItem,[m_dicMemoryValues valueForKey:kFunnyZoneCurrentItemName]];
		
		[m_dicMemoryValues setObject:szCurrentTestItem forKey:kFZ_UI_SHOWNNAME];
		//set spec
		szCurrentSpec		= [dicNameAndSpec objectForKey:@"SPEC"];
		if (szCurrentSpec != nil)
		{
			[m_strSpecName setString:szCurrentSpec];
		}
	} else
	{
		[szReturnValue setString:[NSString stringWithFormat:@"The board shouldn't be tested at this station or wrong board id.[%@]",szBoardId]];
		ATSDebug(@"The board shouldn't be tested at this station or wrong board id.[%@]",szBoardId);
		m_bAbort = YES;
		return [NSNumber numberWithBool:NO];
	}
    return [NSNumber numberWithBool:YES];
}

- (NSNumber *)CHANGE_TESTCASENAME_WITH_NAME:(NSDictionary *)dicContents RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSString        *szCurrentTestItem;
    
    NSString		*szName = [dicContents valueForKey:@"NAME"];
    NSString		*szKey =[dicContents valueForKey:@"KEY"];
	NSDictionary	*dicNameMapping = [dicContents objectForKey:@"NameMapping"];
    NSString	*szCode= @"";
	[self TransformKeyToValue:szName returnValue:&szName];
	
	// Modified by Lucky, 19/09/14
	// the sub name mapping
	if ([dicNameMapping count]>0)
	{
		for(NSString *szVendor in [dicNameMapping allKeys])
		{
			if ([szVendor isEqualToString:szName])
			{
				szCode = [dicNameMapping objectForKey:szName];
			}
		}
		
		if (szCode ==nil || [szCode isEqualToString:@""])
		{
			ATSDBgLog(@"The vendor is not in the mapping table.");
			return [NSNumber numberWithBool:NO];
		}
	}
	// the middle name
    if ([szKey isEqualToString:@""]||szKey==nil)
	{
		szCurrentTestItem = [NSString stringWithFormat:@"%@%@",szCode,[m_dicMemoryValues valueForKey:kFunnyZoneCurrentItemName]];
    }else
	{
		szCurrentTestItem = [NSString stringWithFormat:@"%@%@%@",szCode,szKey,[m_dicMemoryValues valueForKey:kFunnyZoneCurrentItemName]];
	}
 		
    [m_dicMemoryValues setObject:szCurrentTestItem forKey:kFZ_UI_SHOWNNAME];
    
    return [NSNumber numberWithBool:YES];    
}


// 2012.04.16 Modified by Andre 
// Descripton:Catch temperature and humility from Device.And save them as "TEM" and "HUM"
//      Return Value is 8 hex values. 
//        The 3rd value is Tem's integer part. 
//        The 4th value is Tem's decimal part.
//        The 5rd value is Hum's integer part. 
//        The 6th value is Hum's decimal part.
// Param:
//      NSDictionary    *dicContents        :   Setting
//      NSMutableString      *szReturnValue :   Return value
- (NSNumber*)CATCHTEMANDHUM:(NSDictionary *)dicContents RETURN_VALUE:(NSMutableString *)strReturnValue
{
    if (strReturnValue) 
    {
        NSArray     *arrResponse = [strReturnValue componentsSeparatedByString:@" "];
        
        if ([arrResponse count] != 9)
        {
            return [NSNumber numberWithBool:NO];
        }
        NSMutableDictionary	*dictConvertion	= [[NSMutableDictionary alloc] init];
        
        [dictConvertion setObject:[NSNumber numberWithInt:16] forKey:@"CHANGE"];
        [dictConvertion setObject:[NSNumber numberWithInt:10] forKey:@"TO"];
        NSMutableString *strFirTem = [NSMutableString stringWithFormat:@"%@",[arrResponse objectAtIndex:3]];
        NSMutableString *strSecTem = [NSMutableString stringWithFormat:@"%@",[arrResponse objectAtIndex:4]];
        NSMutableString *strFirHum = [NSMutableString stringWithFormat:@"%@",[arrResponse objectAtIndex:5]];
        NSMutableString *strSecHum = [NSMutableString stringWithFormat:@"%@",[arrResponse objectAtIndex:6]];
        if ([self NumberSystemConvertion:dictConvertion RETURN_VALUE:strFirTem] &&
            [self NumberSystemConvertion:dictConvertion RETURN_VALUE:strSecTem] &&
            [self NumberSystemConvertion:dictConvertion RETURN_VALUE:strFirHum] &&
            [self NumberSystemConvertion:dictConvertion RETURN_VALUE:strSecHum])  
        {
            NSString    *strTem = [NSString stringWithFormat:@"%@.%@",strFirTem,strSecTem];
            NSString    *strHum = [NSString stringWithFormat:@"%@.%@",strFirHum,strSecHum];
            ATSDebug(@"the temperature and humidity is %@, %@",strTem,strHum);
            
            [m_dicMemoryValues setObject:strTem forKey:@"TEM"];
            [m_dicMemoryValues setObject:strHum forKey:@"HUM"];
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
- (NSNumber *)CHECK_BOARD_ID:(NSDictionary *)dicContents RETURN_VALUE:(NSMutableString *)szReturnValue
{
    NSArray     *arrBoardID = [dicContents objectForKey:@"BOARDID"];
    if ([arrBoardID containsObject:szReturnValue])
    {
        return [NSNumber numberWithBool:YES];
    }
    else
    {
        return [NSNumber numberWithBool:NO];
    }
}


//Start 2012.12.25 Add by Andre 
// Descripton:Write CPCL into unit.
// Param:
//      NSDictionary    *dicContents        :   Setting
//              SEND_FIXTURECOMMAND: -> NSDictionary*                       :   Send Fixture Command
//              READ_FIXTURECOMMAND:RETURN_VALUE: -> NSDictionary*          :   Read Fixture Command
//              SEND_UNITCOMMAND: -> NSDictionary*                          :   Send Mobile Command
//              READ_UNITCOMMAND:RETURN_VALUE: -> NSDictionary*             :   Read Mobile Command
//
//              Degree -> NSArray*                                          :   Degrees need to be test
//              X-Position -> NSArray*                                      :   X-Positions need to be test
//              Y-Position -> NSArray*                                      :   Y-Positions need to be test
//              R -> NSArray*                                               :   Distance(R) need to be test
//      NSMutableString      *szReturnValue :   Return value
- (NSNumber *)PROXCALDOETEST:(NSDictionary *)dicContents RETURN_VALUE:(NSMutableString *)szReturnValue
{
	NSMutableArray * aryYPosition = [NSMutableArray arrayWithArray:[dicContents objectForKey:@"Y-Position"]];
	NSMutableArray * aryXPosition = [NSMutableArray arrayWithArray:[dicContents objectForKey:@"X-Position"]];
	NSMutableArray * aryDegree = [NSMutableArray arrayWithArray:[dicContents objectForKey:@"Degree"]];
	NSMutableArray * aryR = [NSMutableArray arrayWithArray:[dicContents objectForKey:@"R"]];
	NSDictionary *dicWriteFixtureCommand = [dicContents objectForKey:@"SEND_FIXTURECOMMAND:"];
	NSDictionary *dicReceiveFromFixtureCommand = [dicContents objectForKey:@"READ_FIXTURECOMMAND:RETURN_VALUE:"];
	NSDictionary *dicWriteUnitCommand = [dicContents objectForKey:@"SEND_UNITCOMMAND:"];
	NSDictionary *dicReceiveFromUnitCommand = [dicContents objectForKey:@"READ_UNITCOMMAND:RETURN_VALUE:"];
	
	NSString *szCSVFileName = [NSString stringWithFormat:@"%@/%@_%@_CSV.csv",kPD_LogPath_CSV,m_szPortIndex,m_szStartTime];
	
	NSString *szFixtureItemName;
	NSString *szTempDeltaItemName;
	NSString *szAdjSDItemName;
	NSString *szDeltaItemName;
    NSString *szLowLimit;
    NSString *szHighLimit;
		
	NSString *szDegree;
	NSString *szXPosition;
	NSString *szYPosition;
	NSString *szFixtureYPosition;
	NSString *szR;
	NSString *szFixtureCommand;
	double   dZ = 0.0;
	double   dX = 0.0;
	NSNumber *numResult = [NSNumber numberWithBool:YES];
	
    // Get all the combinations of (Degree, XPosition, YPosition, Distance) and send to Fixture
	for (int i = 0; i < [aryDegree count]; i++) //Degree
	{
		szDegree = [aryDegree objectAtIndex:i];
		for (int j = 0; j < [aryYPosition count]; j++) //YPosition
		{
			szYPosition = [aryYPosition objectAtIndex:j];
			szFixtureYPosition = [NSString stringWithFormat:@"%0.3f",91.975+[szYPosition doubleValue]];// Calculate YPosition
			int iXPositionCount = 1;
			if ([szDegree isEqualToString:@"0"]||[szDegree isEqualToString:@"180"])
            // Degree 0 and Degree 180 need to test all the XPositions, other Degrees only test the first XPosition 
			{
				iXPositionCount = [aryXPosition count];
			}
			for (int k = 0; k < iXPositionCount; k++) //XPosition
			{
				szXPosition = [aryXPosition objectAtIndex:k];
				for (int r = 0; r < [aryR count]; r++) //Distance
				{
					szR = [aryR objectAtIndex:r];
					dZ = -[szR doubleValue] * cos([szDegree doubleValue]*M_PI/180);// Calculate ZPosition by R
					dX = [szR doubleValue] * sin([szDegree doubleValue]*M_PI/180);// Calculate XPosition by R
					szLowLimit = [NSString stringWithFormat:@"%0.1f",[szR doubleValue] - 0.1];
					szHighLimit = [NSString stringWithFormat:@"%0.1f",[szR doubleValue] + 0.1];
					NSString *szSPEC = [NSString stringWithFormat:@"[%@,%@]",szLowLimit,szHighLimit];// Spec = Distance * 10 +/- 1
					NSDictionary *dicSpec = [NSDictionary dictionaryWithObjectsAndKeys:szSPEC,kFZ_Script_JudgeCommonBlack, nil];
					
					//Combine Item Name
					if ([szDegree isEqualToString:@"0"]||[szDegree isEqualToString:@"180"])//0,180 add X-position,others no need
					{
						if ([szXPosition isEqualToString:@"2"] && [szDegree isEqualToString:@"0"]) // skip this one
						{
							break;
						}
						szFixtureItemName = [NSString stringWithFormat:@"Distance %@(mm)(-%@,%@,%@,%@)",
											 szR,szXPosition,szFixtureYPosition,[NSString stringWithFormat:@"%0.2f",dZ],szDegree];
						szFixtureCommand = [NSString stringWithFormat:@"*DOE/%@/%@/%@/%@#",szR,szYPosition,szDegree,szXPosition];
					}
					else
					{
						if ([szR isEqualToString:@"0.5"]) //avoid power button,skip 0.5mm
						{
							break;
						}
						szFixtureItemName = [NSString stringWithFormat:@"Distance %@(mm)(%@,%@,%@,%@)",
											 szR,[NSString stringWithFormat:@"%0.2f",dX],szFixtureYPosition,[NSString stringWithFormat:@"%0.2f",dZ],szDegree];
						szFixtureCommand = [NSString stringWithFormat:@"*DOE/%@/%@/%@#",szR,szYPosition,szDegree];
					}
					
                    ATSDebug(@"DOE Command: %@", szFixtureCommand);
                    
					szTempDeltaItemName = [NSString stringWithFormat:@"%@ Temp Delta",szFixtureItemName];
					szAdjSDItemName = [NSString stringWithFormat:@"%@ Adj_SD",szFixtureItemName];
					szDeltaItemName = [NSString stringWithFormat:@"%@ Delta",szFixtureItemName];
					
                    
					//Send fixture command and judge spec
					[m_dicMemoryValues setValue:[NSString stringWithFormat:@"%@",szFixtureCommand] forKey:@"FixtureCommand"];		
					[self SEND_COMMAND:dicWriteFixtureCommand];
					numResult = [self READ_COMMAND:dicReceiveFromFixtureCommand RETURN_VALUE:szReturnValue];
					if ([numResult boolValue] && szLowLimit && szHighLimit)
					{
                        numResult = [self JUDGE_SPEC:@{@"COMMON_SPEC": dicSpec} RETURN_VALUE:szReturnValue];
					}
					//write csv
					NSString *szCSVInfoDistance = [NSString stringWithFormat:@"\"%@\",%@,\"%@\",%@,%@,%@\n",
												   szFixtureItemName,[NSNumber numberWithBool:![numResult boolValue]],szReturnValue,szLowLimit,szHighLimit,[m_dicMemoryValues objectForKey:kFZ_SingleTime]];
					[IALogs CreatAndWriteSingleCSVLog:szCSVInfoDistance withPath:szCSVFileName];
					//Update PDCA
					if (!m_bNoUploadPDCA) 
					{
						[m_objPudding SetTestItemStatus:szFixtureItemName
												SubItem:kFunnyZoneBlank
											  TestValue:szReturnValue
											   LowLimit:(szLowLimit == nil)?@"N/A":szLowLimit
											  HighLimit:(szHighLimit == nil)?@"N/A":szHighLimit
											  TestUnits:@""
												ErrDesc:@"skip"
											   Priority:m_iPriority
											 TestResult:[numResult boolValue]];
					}
					
					//send unit command
					[self SEND_COMMAND:dicWriteUnitCommand];
					numResult = [self READ_COMMAND:dicReceiveFromUnitCommand RETURN_VALUE:szReturnValue];
					NSDictionary *dicProxCal = [NSDictionary dictionaryWithObjectsAndKeys:
												@"50",@"Count",
												szDegree,@"Degree",
												@"3",@"slot", nil];// slot can be any number except 1
					
					//Temp delta
					numResult = [self PROXBASELINETEST:dicProxCal RETURN_VALUE:szReturnValue];
					NSString *szBaselineTemp = [m_dicMemoryValues objectForKey:@"baselineTemp"];
					NSString *szDegreeTemp = [m_dicMemoryValues objectForKey:[NSString stringWithFormat:@"baselineTemp_%@Degree",szDegree]];
 					NSMutableString *szTempDelta = [NSMutableString stringWithFormat:@"%d",(int)([szDegreeTemp doubleValue]-[szBaselineTemp doubleValue])];
					NSString *szCSVInfoTempDelta = [NSString stringWithFormat:@"\"%@\",%@,\"%@\",%@,%@,%@\n",
													szTempDeltaItemName,[NSNumber numberWithBool:![numResult boolValue]],(!numResult)?@"NA":szTempDelta,@"NA",@"NA",[m_dicMemoryValues objectForKey:kFZ_SingleTime]];
					[IALogs CreatAndWriteSingleCSVLog:szCSVInfoTempDelta withPath:szCSVFileName];
					if (!m_bNoUploadPDCA) 
					{
						[m_objPudding SetTestItemStatus:(szFixtureItemName==nil) ? @"" : szFixtureItemName
												SubItem:@" Temp Delta"
											  TestValue:(szTempDelta==nil) ? @"NA" : szTempDelta
											   LowLimit:@"N/A"
											  HighLimit:@"N/A"
											  TestUnits:@""
												ErrDesc:@"skip"
											   Priority:m_iPriority
											 TestResult:[numResult boolValue]];
					}
					
					//Adj_SD
					NSMutableString *szAdjSD = [m_dicMemoryValues objectForKey:[NSString stringWithFormat:@"baselineSDAtAngle_Adj_%@Degree",szDegree]];
					NSString *szCSVInfoAdjSD = [NSString stringWithFormat:@"\"%@\",%@,\"%@\",%@,%@,%@\n",
												szAdjSDItemName,[NSNumber numberWithBool:![numResult boolValue]],(!numResult)?@"NA":szAdjSD,@"NA",@"NA",[m_dicMemoryValues objectForKey:kFZ_SingleTime]];
					[IALogs CreatAndWriteSingleCSVLog:szCSVInfoAdjSD withPath:szCSVFileName];
					if (!m_bNoUploadPDCA) 
					{
						[m_objPudding SetTestItemStatus:(szFixtureItemName==nil) ? @"" : szFixtureItemName
												SubItem:@" Adj_SD"
											  TestValue:(szAdjSD == nil) ? @"NA" : szAdjSD
											   LowLimit:@"N/A"
											  HighLimit:@"N/A"
											  TestUnits:@""
												ErrDesc:@"skip"
											   Priority:m_iPriority
											 TestResult:[numResult boolValue]];
					}
					
					//Delta
					NSMutableString *szDelta = [m_dicMemoryValues objectForKey:[NSString stringWithFormat:@"Delta_%@Degree",szDegree]];
					NSString *szCSVInfodelta = [NSString stringWithFormat:@"\"%@\",%@,\"%@\",%@,%@,%@\n",
												szDeltaItemName,[NSNumber numberWithBool:![numResult boolValue]],(!numResult)?@"NA":szDelta,@"NA",@"NA",[m_dicMemoryValues objectForKey:kFZ_SingleTime]];
					[IALogs CreatAndWriteSingleCSVLog:szCSVInfodelta withPath:szCSVFileName];
					if (!m_bNoUploadPDCA) 
					{
						[m_objPudding SetTestItemStatus:(szFixtureItemName==nil) ? @"" : szFixtureItemName
												SubItem:@" Delta"
											  TestValue:(szDelta==nil) ? @"NA" : szDelta
											   LowLimit:@"N/A"
											  HighLimit:@"N/A"
											  TestUnits:@""
												ErrDesc:@"skip"
											   Priority:m_iPriority
											 TestResult:[numResult boolValue]];
					}
					
				}
			}

		}
	}
	return numResult;
}

/*Start 2013.01.28 Add by Lucky
 *	Descripton:Calculate average or standard deviation,and memory the result to m_dicMemoryValues dictionnary.
 *	Param:
 *		NSDictionary	*dicContents		: Setting
 *				start		->NSString*		: the start string cut out from
 *				end			->NSString*		: the end string cut out to
 *				KEY			->NSString*		: the key of data source 
 *				MemoryKey	->NSString*		: the key of the result added in the dictionary
 *				BSTD		->BOOL			: YES,calculate Standard Deviation;NO, calculate average 
 */
- (NSNumber*)PROXBASELINETEST_FOR_LATEST:(NSDictionary *)dicContents RETURN_VALUE:(NSMutableString *)strReturnValue
{
    BOOL	bSTD = NO;
    BOOL    bCalMaxandMin = NO;// add for calculate max and min
    double dProx = 0;
    NSMutableArray	*arrSTDValue	= [[[NSMutableArray alloc] init] autorelease];
    NSString		*szStart		= [dicContents objectForKey:@"start"];
    NSString		*szEnd			= [dicContents objectForKey:@"end"];
	bSTD = [[dicContents objectForKey:@"BSTD"] boolValue];
    bCalMaxandMin = [[dicContents objectForKey:@"CalMaxandMin"] boolValue];
    NSString	*szRawData	= [m_dicMemoryValues objectForKey:[dicContents objectForKey:kFZ_Script_MemoryKey]];
    NSArray		*arrLines	= [szRawData componentsSeparatedByString:@"\n"];

    double iMax = 0;
    double iMin = 10000000;
    
    for (int i = 0; i< [arrLines count]; i++)
    {
		//catch the value of one line and add the value together
        NSString *szRawValue  = [[[arrLines objectAtIndex:i] SubFrom:szStart include:NO] SubTo:szEnd include:NO];
        if (bCalMaxandMin)
        {
            if ([szRawValue doubleValue] > iMax)
            {
                iMax = [szRawValue doubleValue];
            }
            if ([szRawValue doubleValue] < iMin)
            {
                iMin = [szRawValue doubleValue];
            }
        }
        dProx += [szRawValue doubleValue];
        if (bSTD)
        {
			//added the value to array
            [arrSTDValue addObject:[NSNumber numberWithDouble:[szRawValue doubleValue]]];
        }
    }
    if (bSTD)
    {
        NSString	*szSTD;
        [self Cal_STD:arrSTDValue ReturnValue:&szSTD];
        [strReturnValue setString:szSTD];
    }
    else
    {
        double	dAverage = dProx/[arrLines count];
        [strReturnValue setString: [NSString stringWithFormat:@"%f",dAverage]];
    }
    NSString *strMemKey = [dicContents objectForKey:@"MemoryKey"];
    [m_dicMemoryValues setObject:[NSString stringWithFormat:@"%@",strReturnValue] forKey:strMemKey];
    
    if (bCalMaxandMin)
    {
        [m_dicMemoryValues setObject:[NSNumber numberWithDouble:iMax] forKey:[NSString stringWithFormat:@"MAX_%@", strMemKey]];
        [m_dicMemoryValues setObject:[NSNumber numberWithDouble:iMin] forKey:[NSString stringWithFormat:@"MIN_%@", strMemKey]];
        [m_dicMemoryValues setObject:[NSNumber numberWithDouble:(iMax-iMin)] forKey:[NSString stringWithFormat:@"SWING_%@", strMemKey]];
    }
    
    return [NSNumber numberWithBool:YES];
}


@end
