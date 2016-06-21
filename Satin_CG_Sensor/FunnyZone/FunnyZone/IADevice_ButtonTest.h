//  IADevice_ButtonTest.h
//  FunnyZone
//
//  Created by Cheng Ming on 2011/10/28.
//  Copyright 2011年 PEGATRON. All rights reserved.



#import "TestProgress.h"
#import "IADevice_TestingCommands.h"



@interface TestProgress ( IADevice_ButtonTest )

//Start 2011.10.28 Add by Ming 
// Descripton:create a thread to read the DUT's key status, until m_bTestButton = NO
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)TEST_BUTTON_THREAD:(NSDictionary*)dicContents
				  RETURN_VALUE:(NSMutableString*)strReturnValue;

-(NSNumber*)RINGER_POSITION_SETTING:(NSDictionary*)dicContents
					   RETURN_VALUE:(NSMutableString*)strReturnValue;
//End 2011.10.28 Add by Ming

-(NSNumber*)CHECK_BUTTON_STATUS:(NSDictionary*)dicContents
				   RETURN_VALUE:(NSMutableString*)strReturnValue;

-(NSNumber*)END_TEST_BUTTON_THREAD:(NSDictionary*)dicContents
					  RETURN_VALUE:(NSMutableString*)strReturnValue;

-(NSNumber*)RINGER_TEST:(NSDictionary*)dicContents
           RETURN_VALUE:(NSMutableString*)strReturnValue;

//Add for AE stations to count the button pressed times
-(NSNumber*)CHECK_BUTTON_PRESS_TIMES:(NSDictionary*)dicContents
                        RETURN_VALUE:(NSMutableString*)strReturnValue;

//Add by Jean
// Param:
//		NSString: RINGER_DOWN: 1 / 0
//		NSString: RINGRT_ORIGINAL
//		NSString: FixtureUP			fixture ringer up command
//		NSString: FixtureDOWN		fixture ringer down command
// Based on RINGER_UP
-(NSNumber*)CHECK_RINGER_STATUS:(NSDictionary*)dicContents
				   RETURN_VALUE:(NSMutableString*)strReturnValue;

// Add by Jean
/*!
 *@ Description:    If all SubItems' result is PASS, this function's result is PASS.
 *@ Param
        NSArray:    SubItems
 */
-(NSNumber*)BUTTONTEST_FINAL_RESULT:(NSDictionary*)dicContents
                       RETURN_VALUE:(NSMutableString*)strReturnValue;

@end




