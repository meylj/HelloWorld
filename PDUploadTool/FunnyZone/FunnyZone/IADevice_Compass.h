//
//  IADevice_Compass.h
//  Izual_Lu
//
//  Created by Lu Izual on 11-5-5.
//  Copyright 2011 PEGATRON. All rights reserved.
//

#import "TestProgress.h"
#import "IADevice_TestingCommands.h"

@interface TestProgress (IADevice_Compass)




//Start 2011.11.03 Add by Ming 
// Descripton:Get the Compass's data, and put those value in dictionary
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)GETDATA_SENSITIVITY:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue;
//End 2011.11.03 Add by Ming


//Start 2011.11.03 Add by Ming 
// Descripton:1.skip first two point 
//            2.save average and standard deviation to a array for "baseline,back,front,back_115,back_230"and so on!The type is depended by the value of the dictionary .
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)COMPASS_SAMPLE:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue;
//End 2011.11.03 Add by Ming


//Start 2011.11.03 Add by Ming 
// Descripton:Record the delta value in dictionary for compass
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)RECORD_DELTA:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue;
//End 2011.11.03 Add by Ming



//Start 2011.11.03 Add by Ming 
// Descripton:Get Camera SN
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)GET_CAMERA_SN:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue;
//End 2011.11.03 Add by Ming





// Mark by torres 2011.12.2
// do this active in function COMPASS_SIMPLE:RETURN_VALUE:
//Start 2011.11.06 Add by Ming 
// Descripton:Get COMPASS VCM DATA from Dictionary
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
//-(NSNumber*)GET_COMPASS_VCM_DATA:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue;
//End 2011.11.06 Add by Ming

// Mark by torres 2011.12.2
// replace with GET_MEMORY_VALUE_FROM_KEY:RETURN_VALUE:
//Start 2011.11.06 Add by Ming 
// Descripton:Get the COMPASS data value from Dictionary's key
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
//-(NSNumber*)GET_COMPASS_DATA:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue;
//End 2011.11.06 Add by Ming

// Mark by torres 2011.12.2
// do this active in function COMPASS_SIMPLE:RETURN_VALUE:
// Calculate compass field
//      Parameter:
//
//          NSDictionary    *dicPara        :   Setting
//              SENSITIVITY -> Boolean      :   if YES,calculate field with sensitivity value,else not
//              TYPE        -> NSString*    :   Set the max time(can be nil,default 3) 
//          NSMutableString        *szReturnValue :   Return value
//
//      Return:
//          Action result
//- (NSNumber*)GetData_Compass:(NSDictionary*)dicPara ReturnValue:(NSMutableString*)szReturnValue;

// Get compass NMS
//      Parameter:
//
//          NSDictionary    *dicPara        :   Setting
//              TYPE        -> NSString*    :   Get each compass data under magnetic field(NORMAL , SOUTH , NORTH)
//          NSMutableString        *szReturnValue :   Return value
//
//      Return:
//          Action result
- (NSNumber*)CompassValue_NorthMuinsSouth:(NSDictionary*)dicPara ReturnValue:(NSMutableString *)szReturnValue;

// Calculate compass each coordinate value
//      Parameter:
//
//          NSDictionary    *dicPara        :   Setting
//              AXIS        -> Boolean      :   each coordinate north value minus south value(X , Y , Z , NMS)
//          NSMutableString        *szReturnValue :   Return value
//
//      Return:
//          Action result
- (NSNumber*)Delta_Compass:(NSDictionary*)dicPara ReturnValue:(NSMutableString*)szReturnValue;

// Set whether we need to count fail receive
//  Descripton: Count the receive fails, and save the fail count to m_iCamispFailCount. 
//  Param:
//           NSDictionary             *dicPara        :   Setting
//              NEEDJUDGEFAILRECEIVE   -> Boolean    :   Set whether we need to count if the fail receive exits in return value 
- (NSNumber*)Set_Judge_Fail_Receive:(NSDictionary*)dicPara;

//Start 2012.01.31 Add by Sunny 
// Descripton:1.save average and standard deviation of the 12 stages
//            2.Calculate Prox,Centerpoint,Temp,Prox_Adj,SD_Adj,Temp_Adj,Ref,OFFSET of four status (Baseline,90Degree,0Degree,180Degree)
// Param:
//      NSDictionary    *dicContents        : Settings in script
//              Degree -> NSString*                     :   Degree of the slot(default is baseline)
//              Count -> NSString*                      :   How many lines need to be calculate
//              slot -> NSString*                       :   Slot Number
//      NSMutableString *strReturnValue    : Return value
- (NSNumber*)PROXBASELINETEST:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue;

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
- (NSNumber*)WRITECPCL:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue;

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
- (NSNumber *)CHANGE_TESTCASENAME_WITH_BOARDID:(NSDictionary *)dicContents RETURN_VALUE:(NSMutableString *)szReturnValue;

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
- (NSNumber*)CATCHTEMANDHUM:(NSDictionary *)dicContents RETURN_VALUE:(NSMutableString *)strReturnValue;

// 2012.04.16 Modified by Andre 
// Descripton:Judge if BOARDID is one of BOARDID array objects.
// Param:
//      NSDictionary    *dicContents        :   Setting
//              BOARDID -> NSArray*         :   BOARDIDs that you want
//      NSMutableString      *szReturnValue :   Return value
- (NSNumber *)CHECK_BOARD_ID:(NSDictionary *)dicContents RETURN_VALUE:(NSMutableString *)szReturnValue;

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
- (NSNumber *)PROXCALDOETEST:(NSDictionary *)dicContents RETURN_VALUE:(NSMutableString *)szReturnValue;

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

- (NSNumber*)PROXBASELINETEST_FOR_LATEST:(NSDictionary *)dicContents RETURN_VALUE:(NSMutableString *)strReturnValue;

/*Start 2013.05.06 Add by Betty
 *	Descripton:change test name with name setting in script file
 *  Ex: If the test name is AABB, the name setting in script file is CC, so the new test name is CC AABB
 *	Param:
 *		NSDictionary	*dicContents		: Setting
 *				name		->NSString*		: the name string you want put in the test name
 *      NSMutableString *szReturnValue	:   Return value
 */
- (NSNumber *)CHANGE_TESTCASENAME_WITH_NAME:(NSDictionary *)dicContents RETURN_VALUE:(NSMutableString *)szReturnValue;

@end
