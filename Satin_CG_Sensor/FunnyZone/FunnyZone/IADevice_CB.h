//  IADevice_CB.h
//  Izual_Lu
//
//  Created by Lu Izual on 11-5-5.
//  Copyright 2011年 PEGATRON. All rights reserved.



#import "TestProgress.h"
#import "IADevice_TestingCommands.h"
#import "CBTestBase.h"
#include <CommonCrypto/CommonDigest.h>



enum BIT_HEX
{
	High_Bit,
	Low_Bit,
};

@interface TestProgress (IADevice_CB)
// set pass or fail control bit
// Param:
//		NSDictionary	*dicSubTestItem	
//			KEY		-> NSString*	: KEY name
//      NSMutableString*   szReturnValue   : return value
// Relate:
//		NSMutableDictionary	*dicMemoryValues	: Save memory values with given key
- (NSNumber*)WRITE_CONTROL_BIT:(NSDictionary *)dicSubTestItem
				  RETURN_VALUE:(NSMutableString*)szReturnValue;

- (NSNumber*)CHECK_CONTROL_BITS:(NSDictionary *)dicSubTestItem
				   RETURN_VALUE:(NSMutableString*)szReturnValue;

//check fail count
- (NSNumber*)WHETHER_STATION_ALLOWED_TEST:(NSDictionary *)dicSubTestItem
							 RETURN_VALUE:(NSMutableString *)szReturnValue;

- (NSNumber*)WRITE_INCOMPLETE_CONTROLBIT:(NSDictionary *)dicSubTestItem
							RETURN_VALUE:(NSMutableString *)szReturnValue;

- (NSNumber*)CLEAR_RELATIVE_CONTROL_BITS:(NSDictionary *)dicSubTestItem
							RETURN_VALUE:(NSMutableString *)szReturnValue;

- (NSNumber*)CB_SETORNOT:(NSDictionary *)dicSubTestItem
			RETURN_VALUE:(NSMutableString *)szReturnValue;

- (NSNumber*)SELF_CB_CHECK:(NSDictionary *)dicSubTestItem
			  RETURN_VALUE:(NSMutableString *)szReturnValue;

@end




