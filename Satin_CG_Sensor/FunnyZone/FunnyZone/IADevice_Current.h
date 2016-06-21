//  IADevice_Current.h
//  FunnyZone
//
//  Created by Winter on 11/10/11.
//  Copyright 2011 PEGATRON. All rights reserved.



#import "TestProgress.h"
#import "IADevice_TestingCommands.h"



@interface TestProgress (IADevice_Current)

//2011-11-10 add by Winter
// Check bit and change NVc5, if bit[0]="4B" and bit[8]="01", return pass. If bit[0]="4B" and bit[8]="05"/"06", send another command.
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue     : Return value
// Return:
//      Actions result
-(NSNumber*)JUDGE_NVC5:(NSDictionary*)dicContents
		  RETURN_VALUE:(NSMutableString*)strReturnValue;

//2011-11-10 add by Winter
// Two numbers from Hex to Dec, then exchange the position of two numbers
// Param:
//      NSArray  *SourceAry     : Numbers Source Array
//      int   *iIndex           : The number's index in Array
// Return:
//      Actions result
-(unsigned short)PULL_SHORT:(NSArray *)SourceAry
					  INDEX:(int)iIndex;

//2011-11-10 add by Winter
// Only get the Hex value from the response
// Param:
//       NSMutableString *strReturnValue     : Return value
// Return:
//      Actions result
-(NSNumber*)CONNECT_ARRAY_FOR_BAND:(NSDictionary*)dicContents
					  RETURN_VALUE:(NSMutableString*)strReturnValue;

//2011-11-10 add by Winter
// Use "PULL_SHORT:Index:" function, if the result >= 900, memory this index
// Param:
//       NSDictionary    *dicContents        : Settings in script
//       NSMutableString *strReturnValue     : Return value
// Return:
//      Actions result
-(NSNumber*)GET_PULL_SHORT_I:(NSDictionary*)dicContents
				RETURN_VALUE:(NSMutableString*)strReturnValue;

//2011-11-10 add by Winter
// Get the index i from m_dicMemoryValues, then calculate the new two indexs to find the WCDMA_COMMAND from the new Array
// Param:
//       NSDictionary    *dicContents        : Settings in script
//       NSMutableString *strReturnValue     : Return value
// Return:
//      Actions result
-(NSNumber*)GET_COMMAND:(NSDictionary*)dicContents
		   RETURN_VALUE:(NSMutableString*)strReturnValue;

// 2011-11-11 added by lucy
// Descripton: get sleep Dlog3,sleep Dlog2,get sleep Dlog1
// Param:
//      NSDictionary    *dicContents        : Settings
//      NSMutableString *strReturnValue     : Return value 
- (NSNumber*)GETSLEEPDATA:(NSDictionary*)dicContents
			 RETURN_VALUE:(NSMutableString*)strReturnValue;
// 2011-11-11 added by lucy
// Descripton: get the temperature by the caculation
// Param:
//      NSDictionary    *dicContents        : Settings
//      NSMutableString *strReturnValue     : Return value 
- (NSNumber*)TEMPERATURE:(NSDictionary*)dicContents
			RETURN_VALUE:(NSMutableString*)strReturnValue;

@end




