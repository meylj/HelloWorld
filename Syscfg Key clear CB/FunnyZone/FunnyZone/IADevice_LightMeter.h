//  IADevice_LightMeter.h
//  FunnyZone
//
//  Created by Cheng Ming on 2011/11/7.
//  Copyright 2011年 PEGATRON. All rights reserved.



#import "TestProgress.h"
#import "IADevice_TestingCommands.h"



@interface TestProgress ( IADevice_LightMeter )

//2011-8-4 add by Gordon
// check lightmeter whether is connected OK
// Param:
//      NSDictionary    *dictSettings   : Settings
//          MULTIPLE    -> int          : multiple for lightmeter
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
- (NSNumber *)CHECK_LIGHTMETER_STATUS:(NSDictionary*)dictSettings
						 RETURN_VALUE:(NSMutableString*)strReturnValue;

//Start 2011.11.14 Add by Ming 
// Descripton:Start the Thread for Light Meter 
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)LIGHT_METER_BEGINREAD:(NSDictionary*)dicContents
					 RETURN_VALUE:(NSMutableString*)strReturnValue;
//End 2011.11.14 Add by Ming

//Start 2011.11.14 Add by Ming 
// Descripton:Get the light meter's value
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)GET_LIGHT_METER_AVERAGE:(NSDictionary*)dicContents
					   RETURN_VALUE:(NSMutableString*)strReturnValue;
//End 2011.11.14 Add by Ming

//2011-11-29 add by desikan
// read data from lightmeter
// Param:
//      NSMutableDictionary  *dictSettings   : Settings
//          MULTIPLE    -> int          : multiple for lightmeter
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
- (NSNumber *)Read_Data_From_LightMeter:(NSMutableDictionary *)dictSettings
						   Return_Value:(NSMutableString *)strReturnValue;

// Start 2012.10.26 Add by Sky
// Description:Send the fixture command to catch the ray from the unit.
// Param:
//      NSDictionany    *dicContents    : Setting in script file
//      NSMutableString *strReturnValue : Return value
-(NSNumber*)START_LED_TEST:(NSDictionary *)dicContents
              RETURN_VALUE:(NSMutableString *)strReturnValue;

-(NSNumber*)CHECK_LED_ON:(NSDictionary *)dicContents
            RETURN_VALUE:(NSMutableString *)strReturnValue;

-(NSNumber*)END_LED_TEST:(NSDictionary *)dicContents
            RETURN_VALUE:(NSMutableString *)strReturnValue;


@end




