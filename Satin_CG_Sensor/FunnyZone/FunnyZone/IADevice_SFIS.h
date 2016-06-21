//  IADevice_SFIS.h
//  FunnyZone
//
//  Created by Eagle on 10/27/11.
//  Copyright 2011 PEGATRON. All rights reserved.



#import "TestProgress.h"
#import "IADevice_TestingCommands.h"



@interface TestProgress (IADevice_SFIS)

// Query SFIS with given contents, and save return values to dicMemoryValues
// Param:
//      NSDictionary    *dicQueryContents   : Contains query contents
//          band_sn         -> NSString*    : 
//          nandcs          -> NSString*    : 
//          nand_id         -> NSString*    : 
//          .....
// Return:
//      Actions result
-(NSNumber*)QUERY_SFIS:(NSDictionary*)dicQueryContents
		  RETURN_VALUE:(NSMutableString *)szReturnValue;

// Catch data with given keys from m_dicMemoryValues
// Param:
//      NSDictionary    *dicQueryContents   : Contains Catch contents
//          area         -> NSString*    : 
//          asku         -> NSString*    : 
//          .....
// Return:
//      Actions result
-(NSNumber*)CATCH_DATA:(NSDictionary*)dicQueryContents
		  RETURN_VALUE:(NSMutableString *)szReturnValue;

// Insert SFIS with given contents, and save return values to dicMemoryValues
// Param:
//      NSDictionary    *dicInsertContents  : Contains insert contents
//          URL         -> NSString*    : Insert URL.
//          SN          -> NSString*    : Insert SN or BandSN.
//          STATIONID   -> NSString*    : Insert station id
//          STATIONNAME -> NSString*    : Insert station name
//          STARTTIME   -> NSString*    : Insert start time
//          STOPTIME    -> NSString*    : Insert stop time. (Can be nil). Default = Current time
//          PRODUCT     -> NSString*    : Insert product.
//          OS          -> NSString*    : Insert OS bundle version
//          MACADDRESS  -> NSString*    : Insert MAC address
//          ECID        -> NSString*    : Insert ECID. (Can be nil)
//          UDID        -> NSString*    : Insert UDID. (Can be nil)
//          FAILLIST    -> NSString*    : Insert list of failing tests. (Can be nil)
//          FAILURE     -> NSString*    : Insert failure messages. (Can be nil)
//          TIMEOUT     -> NSNumber*    : Insert time out. (Can be nil). Default = 3s
//      NSMutableString        *strReturn         : Return values
// Return:
//      Actions result
-(NSNumber*)INSERT_SFIS:(NSDictionary*)dicInsertContents 
           RETURN_VALUE:(NSMutableString*)strReturn;
// Link KP SN with ISN into the SFIS
-(NSNumber*)SFIS_LINK:(NSDictionary*)dicInsertContents
         RETURN_VALUE:(NSMutableString*)strReturn;

// 2011-12-2 added by lucy
// Descripton: judge the nand size spec by the different value from SFC
// Param:
//      NSDictionary    *dicContents        : Settings
//      NSMutableString *strReturnValue     : Return value 
- (NSNumber*)JUDGE_NANDSIZE_SPEC:(NSDictionary*)dicContents
					RETURN_VALUE:(NSMutableString*)strReturnValue;

// 2011-12-2 added by lucy
// Descripton: First step:  query area by sn
//            Second step: query area by ban_sn
//             Third step:  read area from DFU
//             Fouth step:  compare the third value, if the same ,return yes;else, return no;
// Param:
//      NSDictionary    *dicContents        : Settings
//      NSMutableString *strReturnValue     : Return value 
- (NSNumber*)COMPAREAREA:(NSDictionary*)dicContents
			RETURN_VALUE:(NSMutableString*)strReturnValue;

// 2011-12-2 added by lucy
// Descripton: compare grape_sn and Lcm_sn from UI with SFC
//            
// Param:
//      NSDictionary    *dicContents        : Settings
//      NSMutableString *strReturnValue     : Return value 
- (NSNumber*)COMPAREDATAFORUI:(NSDictionary *)dicContents
				 RETURN_VALUE:(NSMutableString *)strReturnValue;
//2011-12-10 add by Winter
// Calculate DUT config, and memory for key "CFG#"
// Param:
//       NSDictionary    *dicContents        : Settings in script
//       NSMutableString *strReturnValue     : Return value
// Return:
//      Actions result
- (NSNumber *)JUDGE_CONFIG:(NSDictionary *)dicContents
			  RETURN_VALUE:(NSMutableString*)strReturnValue;

//2012.1.6 add by winter
//sbuild=BUILD_EVENT +_+BUILD_MATRIX_CONFIG = N94P-DVT_P-PDFC-01
//sbuild_unit = 0064
//CFG# = N94P/DVT/MB03/0186/0064/P-PDFC-01
-(NSNumber*)COMBINE_CONFIG:(NSDictionary*)dicContents
			  RETURN_VALUE:(NSMutableString*)strReturnValue;

//2015-8-20 add by York
//If config are "" NULL nil and "NULL" in SFIS? return NO.
-(NSNumber*)JUDGE_CONFIG_FOR_SUB:(NSDictionary*)dicContents
                    RETURN_VALUE:(NSMutableString*)strReturnValue;

//2011-12-10 add by Winter
// Calculate camera sn from strReturnValue, and compare it with SFIS.
// Param:
//       NSDictionary    *dicContents        : Settings in script
//       NSMutableString *strReturnValue     : Return value
// Return:
//      Actions result
-(NSNumber*)CHECK_CAMERA_SN:(NSDictionary*)dicContents
			   RETURN_VALUE:(NSMutableString*)strReturnValue;
- (BOOL)COMPARE_PLANTANDCONFIG_WITHSFIS:(NSDictionary *)dicContents
						   RETURN_VALUE:(NSMutableString *)strReturnValue;
- (BOOL)COMBINE_CAMERA_SN:(NSArray *)aryContents
			 RETURN_VALUE:(NSString**)strReturnValue;
-(NSNumber*)JUDGE_BBVERSION:(NSDictionary*)dicContents
			   RETURN_VALUE:(NSMutableString*)strReturnValue;
-(NSNumber *)COMBINE_CONFIG_By_UI:(NSDictionary *)dicContents
					 RETURN_VALUE:(NSMutableString *)strReturnValue;
-(NSNumber*)CaculateColorCheckSum:(NSDictionary*)dicContents
					 RETURN_VALUE:(NSMutableString*)strReturnValue;
- (NSArray *)DealWithNVMData:(NSString*)returnValue;
-(NSNumber*)DO_CAMERA_DATA:(NSDictionary*)dicContents
			  RETURN_VALUE:(NSMutableString*)strReturnValue;

//2012-04-19 add description by Winter
// Used to catch number, and convert the number to the bit you want, then memory the return value.
// Param:
//       NSDictionary    *dicQueryContents        : Settings in script
//       NSMutableString *strReturnValue     : Return value
// Return:
//      Actions result
-(NSNumber*)CATCH_BIT:(NSDictionary *)dicQueryContents
		 RETURN_VALUE:(NSMutableString *)szReturnValue;

//2012-04-19 add description by Winter
// Used to combine some string values to a string value, for example(A;B;C =====> ABC)
// Param:
//       NSDictionary    *dicQueryContents        : Settings in script
//       NSMutableString *strReturnValue     : Return value
// Return:
//      Actions result
-(NSNumber*)CONBINE_DATA:(NSDictionary *)dicQueryContents
			RETURN_VALUE:(NSMutableString *)szReturnValue;
-(NSNumber*)CaculateColorCheckSum:(NSDictionary*)dicContents
					 RETURN_VALUE:(NSMutableString*)strReturnValue;

//2012-04-19 add description by Winter
// Used to change test item name by different nand_size. You'll see the changed the name at parametric data and UI.
// Param:
//       NSDictionary    *dicContents        : Settings in script
//       NSMutableString *strReturnValue     : Return value
// Return:
//      Actions result
-(NSNumber *)CHANGE_TESTCASENAME_BY_NANDSIZE:(NSDictionary *)dicContents
								RETURN_VALUE:(NSMutableString *)szReturnValue;

-(NSString *)Mac_Address;
@end




