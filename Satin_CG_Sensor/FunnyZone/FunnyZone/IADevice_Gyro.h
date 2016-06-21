//  IADevice_Gyro.h
//  Izual_Lu
//
//  Created by Lu Izual on 11-5-5.
//  Copyright 2011年 PEGATRON. All rights reserved.



#import "TestProgress.h"



@interface TestProgress (IADevice_Gyro)

///2011.07.20 Add by Ming 
// Get gyro data from input stream
// Param:
//      NSDictionary    *dicSettings        : Settings
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)GetGyroData:(NSDictionary*)dicContents
			ReturnValue:(NSMutableString*)strReturnValue;

// Get gyro data Y from dicMemoryValues
// Param:
//      NSDictionary    *dicSettings        : Settings
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)GetGyroData_Y:(NSDictionary*)dicContents
			  ReturnValue:(NSMutableString*)strReturnValue;

// Get gyro data Z from dicMemoryValues
// Param:
//      NSDictionary    *dicSettings        : Settings
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)GetGyroData_Z:(NSDictionary*)dicContents
			  ReturnValue:(NSMutableString*)strReturnValue;

// Get gyro data Temperature from dicMemoryValues
// Param:
//      NSDictionary    *dicSettings        : Settings
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)GetGyroData_Temperature:(NSDictionary*)dicContents
						ReturnValue:(NSMutableString*)strReturnValue;
// Judge gyro's Temperature from dicMemoryValues
// Param:
//      NSDictionary    *dicSettings        : Settings
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)JudgeGyroTemperature:(NSDictionary*)dicContents
					 ReturnValue:(NSMutableString*)strReturnValue;

// Calibration Gyro Trend B ->X
// Param:
//      NSDictionary    *dicSettings        : Settings
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)Calc_Gyro_BX:(NSDictionary*)dicContents
			 ReturnValue:(NSMutableString*)strReturnValue;

// Calibration Gyro Trend B ->Y
// Param:
//      NSDictionary    *dicSettings        : Settings
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)Calc_Gyro_BY:(NSDictionary*)dicContents
			 ReturnValue:(NSMutableString*)strReturnValue;

// Calibration Gyro Trend B ->Z
// Param:
//      NSDictionary    *dicSettings        : Settings
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)Calc_Gyro_BZ:(NSDictionary*)dicContents
			 ReturnValue:(NSMutableString*)strReturnValue;

// Calibration Gyro Trend Q ->X
// Param:
//      NSDictionary    *dicSettings        : Settings
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)Calc_Gyro_QX:(NSDictionary*)dicContents
			 ReturnValue:(NSMutableString*)strReturnValue;

// Calibration Gyro Trend Q ->Y
// Param:
//      NSDictionary    *dicSettings        : Settings
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)Calc_Gyro_QY:(NSDictionary*)dicContents
			 ReturnValue:(NSMutableString*)strReturnValue;

// Calibration Gyro Trend Q ->Z
// Param:
//      NSDictionary    *dicSettings        : Settings
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)Calc_Gyro_QZ:(NSDictionary*)dicContents
			 ReturnValue:(NSMutableString*)strReturnValue;
//2011-11-10 added by lucy
// Descripton: Get the index of the max temperature
// Param:
//      NSDictionary    *dicContents        : Settings
//      NSMutableString *strReturnValue     : Return value 

-(NSNumber*)GET_MAX_TEMP:(NSDictionary*)dicContents
			RETURN_VALUE:(NSMutableString*)strReturnValue;
// 2011-11-10 added by lucy
// Descripton: Get the index of the min temperature
// Param:
//      NSDictionary    *dicContents        : Settings
//      NSMutableString *strReturnValue     : Return value 
- (NSNumber*)GET_MIN_TEMP:(NSDictionary*)dicContents
			 RETURN_VALUE:(NSMutableString*)strReturnValue;
// 2011-11-10 added by lucy
// Descripton: Get the total count of temperature
// Param:
//      NSDictionary    *dicContents        : Settings
//      NSMutableString *strReturnValue     : Return value 
- (NSNumber*)GET_COUNT_OF_TEMP:(NSDictionary*)dicContents
				  RETURN_VALUE:(NSMutableString*)strReturnValue;
// 2011-11-10 added by lucy
// Descripton: calcute the slope of x 
// Param:
//      NSDictionary    *dicContents        : Settings
//      NSMutableString *strReturnValue     : Return value 
- (NSNumber*)CALC_GYRO_SLOPEX:(NSDictionary*)dicContents
				 RETURN_VALUE:(NSMutableString*)strReturnValue;

// 2011-11-10 added by lucy
// Descripton: calcute the slope of y 
// Param:
//      NSDictionary    *dicContents        : Settings
//      NSMutableString *strReturnValue     : Return value 
- (NSNumber*)CALC_GYRO_SLOPEY:(NSDictionary*)dicContents
				 RETURN_VALUE:(NSMutableString*)strReturnValue;

// 2011-11-10 added by lucy
// Descripton: calcute the slope of z 
// Param:
//      NSDictionary    *dicContents        : Settings
//      NSMutableString *strReturnValue     : Return value 
- (NSNumber*)CALC_GYRO_SLOPEZ:(NSDictionary*)dicContents
				 RETURN_VALUE:(NSMutableString*)strReturnValue;

@end




