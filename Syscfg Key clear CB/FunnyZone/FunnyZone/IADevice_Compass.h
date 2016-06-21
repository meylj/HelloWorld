//  IADevice_Compass.h
//  Izual_Lu
//
//  Created by Lu Izual on 11-5-5.
//  Copyright 2011年 PEGATRON. All rights reserved.



#import "TestProgress.h"
#import "IADevice_TestingCommands.h"



@interface TestProgress (IADevice_Compass)

//Start 2011.11.03 Add by Ming 
// Descripton:Get the Compass's data, and put those value in dictionary
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)GETDATA_SENSITIVITY:(NSDictionary*)dicContents
				   RETURN_VALUE:(NSMutableString*)strReturnValue;

//Start 2011.11.03 Add by Ming 
// Descripton:1.skip first two point 
//            2.save average and standard deviation to a array for "baseline,back,front,back_115,back_230"and so on!The type is depended by the value of the dictionary .
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)COMPASS_SAMPLE:(NSDictionary*)dicContents
			  RETURN_VALUE:(NSMutableString*)strReturnValue;

//Start 2011.11.03 Add by Ming 
// Descripton:Record the delta value in dictionary for compass
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)RECORD_DELTA:(NSDictionary*)dicContents
			RETURN_VALUE:(NSMutableString*)strReturnValue;

//Start 2011.11.03 Add by Ming 
// Descripton:Get Camera SN
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)GET_CAMERA_SN:(NSDictionary*)dicContents
			 RETURN_VALUE:(NSMutableString*)strReturnValue;

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
							  ReturnValue:(NSMutableString *)szReturnValue;

// Calculate compass each coordinate value
//      Parameter:
//
//          NSDictionary    *dicPara        :   Setting
//              AXIS        -> Boolean      :   each coordinate north value minus south value(X , Y , Z , NMS)
//          NSMutableString        *szReturnValue :   Return value
//
//      Return:
//          Action result
- (NSNumber*)Delta_Compass:(NSDictionary*)dicPara
			   ReturnValue:(NSMutableString*)szReturnValue;

// Set whether we need to count fail receive
//  Descripton: Count the receive fails, and save the fail count to m_iCamispFailCount. 
//  Param:
//           NSDictionary             *dicPara        :   Setting
//              NEEDJUDGEFAILRECEIVE   -> Boolean    :   Set whether we need to count if the fail receive exits in return value 
- (NSNumber*)Set_Judge_Fail_Receive:(NSDictionary*)dicPara;

//Start 2012.01.31 Add by Sunny 
// Descripton:1.save average and standard deviation to
//            2.Calculate Prox,Centerpoint,Temp,Prox_Adj,SD_Adj,Temp_Adj,Ref,OFFSET of four status (Baseline,90Degree,0Degree,180Degree)
//			  3.Write PBCl,PBTb,PBTa to DUT.
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
- (NSNumber*)PROXBASELINETEST:(NSDictionary*)dicContents
				 RETURN_VALUE:(NSMutableString*)strReturnValue;

//Start 2012.01.31 Add by Sunny 
// Descripton:Write CPCL into unit.
// Param:
//      NSDictionary    *dicContents        :   Setting
//              Version Number -> NSString*                     :   Version Number of CPCL
//              Alpha value -> NSString*                        :   Alpha value of CPCL
//              SEND_COMMAND:-> NSDictionary*                   :   Write CPCL command
//              READ_COMMAND:RETURN_VALUE: -> NSDictionary*     :   Receive CPCL command
//      NSMutableString      *szReturnValue :   Return value
- (NSNumber*)WRITECPCL:(NSDictionary*)dicContents
		  RETURN_VALUE:(NSMutableString*)strReturnValue;

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
								  RETURN_VALUE:(NSMutableString *)szReturnValue;

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
			   RETURN_VALUE:(NSMutableString *)strReturnValue;

// 2012.04.16 Modified by Andre 
// Descripton:Judge if BOARDID is one of BOARDID array objects.
// Param:
//      NSDictionary    *dicContents        :   Setting
//              BOARDID -> NSArray*         :   BOARDIDs that you want
//      NSMutableString      *szReturnValue :   Return value
- (NSNumber *)CHECK_BOARD_ID:(NSDictionary *)dicContents
				RETURN_VALUE:(NSMutableString *)szReturnValue;

// 2012.10.22 add compass vcm
// Call the Python script : comp_vcm_test.py to get the test result
// str_BsdPath: comp_vcm_test.py need the UART path as the para.
- (NSNumber *)CHECK_VCM_DATA: (NSDictionary *)dicPara
                RETURN_VALUE: (NSMutableString *)szReturnValue;
- (bool)Cal_STD:(NSArray *)arrTemp
	ReturnValue:(NSString **)szReturnValue;

// 2013.2.1
// Add those two function to synthesize the compass test items
- (NSNumber	*)START_SYNCHRONIZE:(NSDictionary*)dictParam
				   RETURN_VALUE:(NSMutableString*)strReturnValue;
- (NSNumber	*)STOP_SYNCHRONIZE:(NSDictionary*)dictParam
				  RETURN_VALUE:(NSMutableString*)strReturnValue;

-(NSNumber *)CATCH_MEASURE_VALUE:(NSDictionary* )dicParam RETURN_VALUE:(NSMutableString*)strReturnValue;

//sqrt
-(NSNumber *)CAL_SQRT:(NSDictionary* )dicParam RETURN_VALUE:(NSMutableString*)strReturnValue;

@end




