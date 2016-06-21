//
//  IADevice_ALS.h
//  Izual_Lu
//
//  Created by Lu Izual on 11-5-5.
//  Copyright 2011å¹?PEGATRON. All rights reserved.
//

#import "TestProgress.h"

@interface TestProgress (IADevice_ALS)

#pragma mark ############################## ALS ##############################
//2011-8-4 add by Gordon
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
                      RETURN_VALUE:(NSMutableString*)strReturnValue;

//2011-8-4 add by Gordon
// Get Als&Prox data
// Param:
//      NSMutableString        *strReturnValue : Return value
// Return:
//      Actions result
- (NSNumber *)GET_ARRAY_ALS_PROX:(NSDictionary *)dicSub RETURN_VALUE:(NSMutableString *)strReturnValue;

//2011-8-4 add by Gordon
// Calculate the Ratio of ALS
// Param:
//      NSDictionary    *dictSettings   : Settings
//          JudgeValue  -> int          : Als judge value
//      NSMutableString        *strReturnValue : Return value
// Return:
//      Actions result
- (NSNumber *)CALCULATE_RATIO:(NSDictionary*)dictSettings RETURN_VALUE:(NSMutableString*)strReturnValue;

//2011-8-4 add by Gordon
// Calculate the Gain of ALS
// Param:
//      NSDictionary    *dictSettings   : Settings
//          LUX         -> int          : lux
//      NSMutableString        *strReturnValue : Return value
// Return:
//      Actions result
- (NSNumber *)CALCULATE_GAIN:(NSDictionary*)dictSettings RETURN_VALUE:(NSMutableString*)strReturnValue;

//2011-8-4 add by Gordon
// Get the point
// Param:
//      int        row :            the specific row
//      int        column :         the specific column
//      NSString   aboveOrbelow :   above mode or below mode
// Return:
//      return the first point above or below the value "JudgeValue" setting at - (BOOL)CALCULATE_GAIN: RETURN_VALUE:
- (int)CATCH_THE_POINT_LOCATION:(int)row COLUMN:(int)column LABLE:(NSString *)aboveOrbelow;

//2011-8-4 add by Gordon
// Get the average of the row
// Param:
//      int        row : the specific row
// Return:
//      the average value
- (double)AVERAGE_FOR_ALS:(int)row;

/*
 * Kyle 2011.12.15
 * method   : AVERAGE_ALS_Clear:RETURN_VALUE:
 * abstract : get ave clear value from ALS data
 */
- (NSNumber *)AVERAGE_ALS_ClearAndIR:(NSDictionary *)dicSetting RETURN_VALUE:(NSMutableString*)szReturnValue;

#pragma mark ############################## Tool Functions ##############################



@end
