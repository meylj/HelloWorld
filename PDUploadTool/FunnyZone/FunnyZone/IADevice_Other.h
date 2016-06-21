//
//  IADevice_Other.h
//  Izual_Lu
//
//  Created by Lu Izual on 11-5-5.
//  Copyright 2011年 PEGATRON. All rights reserved.
//

#import "TestProgress.h"

//#import "iFactoryTest/IFTPlugIn.h"

// 2012.4.21 Sky
//      Separate iPad-1 show voltage of the unit from Prox-Cal show ready bug. 
extern NSString *const ShowVoltageOnUI;

@interface TestProgress (IADevice_Other)



// Get data from mobile in OS mode
// Param:
//      NSDictionary    *dictSettings       : Settings
//          LOCATION    -> NSString*    : Coco tool bundle path
//          TIMEOUT     -> NSNumber*    : Read time out
//      NSMutableString   *strReturnValue    : Return value
-(NSNumber*)GetDataFromOSMode:(NSDictionary*)dictSettings 
                  ReturnValue:(NSMutableString*)strReturnValue;


// Catch and calculate the light meter return value
//      Parameter:
//
//          NSDictionary    *dicPara        :   Setting
//              MULTIPLE    -> NSString*    :   The multiple of the value(10) 
//              ITEMOUT     -> NSString*    :   Set the max time(can be nil) 
//          NSMutableString  *szReturnValue :   Return value
//
//      Return:
//          Action result
//-(NSNumber *)LightMeterValue:(NSDictionary *)dicPara ReturnValue:(NSMutableString *)szReturnValue;


// Calculate temperature of thermistor component
// Param:
//      NSDictionary    *dictSettings   : Settings
//          VALUE       -> NSString*    : {NTC,TEMP}
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
- (NSNumber *)CALCULATE_TEMPERATURE_FOR_THERMISTOR:(NSDictionary *)dictSettings RETURN_VALUE:(NSMutableString*)strReturnValue;

//2011-8-4 add by Gordon
// Transform value from hex to dec
// Param:
//      NSDictionary    *dictSettings   : Settings
//          Mode        -> NSString*    : {RECEIVE,FIXTURE,D_FIXTURE,BATQMAX}
//          CHANNEL     -> NSString*    : save data to key named by channel
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
- (NSNumber *)TRANSFORM_FOR_HEX_TO_DEC:(NSDictionary*)dictSettings RETURN_VALUE:(NSMutableString*)strReturnValue;



//2011-8-4 add by Gordon
// Through get ClrC from Unit to judge whether the unit is white or black
// Param:
//      NSDictionary    *dictSettings   : Settings
//          NO settings in  this function
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
- (NSNumber *)GET_DUT_COLOR:(NSDictionary*)dictSettings RETURN_VALUE:(NSMutableString *)strReturnValue;

//description : load bundle for displayport
- (NSNumber *)LOAD_BUNDLE;

//description : save bundle and iF version ... to dic
- (NSNumber *)SAVE_BUNDLE_INFO;

//run coco displayprot function
- (NSNumber *)DisplayPort_TEST;

//get data form dic or ary
- (NSNumber *)GET_DP_DATA:(NSDictionary *)dicSubSetting RETURN_VALUE:(NSMutableString *)szReturnValue;


//Start 2011.11.04 Add by Ming 
// Descripton:Get the Start Time
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)GET_START_TIME:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue;
//End 2011.11.04 Add by Ming


//Start 2011.11.06 Add by Ming 
// Descripton:Change Test Case Name with Black/White
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)CHANGE_TESTCASENAME_WITH_COLOR:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue;
//End 2011.11.06 Add by Ming

// check root
- (NSNumber *)CURRENT_ROOT_CHECK:(NSDictionary *)dicSubSetting RETURN_VALUE:(NSMutableString *)szReturnValue;

- (NSNumber *)ChangeScientificToNormal:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)szNumber;
- (NSNumber *)CHANGE_CANCLE_FLAG:(NSDictionary *)dicPara RETURN_VALUE:(NSMutableString *)szReturnValue;

//add by desikan at 2011/12/27
// description : do Round (四舍五入) 
- (NSNumber *)DO_ROUND:(NSDictionary *)dicPara RETURN_VALUE:(NSMutableString *)szReturnValue;

/*
 * Kyle 2012.02.14
 * method       : Provisioning:RETURN_VALUE:
 * abstract     : get SN by 3 ways
 * 
 */
- (NSNumber *)Provisioning:(NSDictionary *)dictSettings RETURN_VALUE:(NSMutableString*)szReturnValue;



// 2012.2.21 Winter
// get prox data, and judge.   
- (NSNumber *)CAlCULATOR_PROX_DATA:(NSDictionary *)dicpara RETURN_VALUE:(NSMutableString*)strReturnValue;
- (NSNumber *)MatchReginCode:(NSDictionary *)dicpara RETURN_VALUE:(NSMutableString*)strReturnValue;

// 2012.2.28 Andre
// Descripton:Judge if "XX" exists.
// Param:
//      NSDictionary    *dicContents        : Settings in script
//          XX          -> NSString*    : string which you want to judge
//          WANT        -> NSString*    : controls that if all value is XX, return YES or NO
//          Charactor   -> NSString*    : return value from last function seperated by WHAT
//      NSMutableString *strReturnValue     : Return value 
// Return:
//      Actions result
- (NSNumber *)Judge_If_ALL_Value_Is_XX:(NSDictionary *)dicContents RETURN_VALUE:(NSMutableString *)strReturnValue;

// 2012.3.2 Leehua
// Descripton:show voltage and percentage on UI
-(NSNumber *)SEND_VOL_TO_UI:(NSDictionary *)dicSub RETURN_VALUE:(NSMutableString *)szReturnValue;

-(NSNumber *)ENTER_DIAGS:(NSDictionary *)dicSub RETURN_VALUE:(NSMutableString *)szReturnValue;

- (BOOL)repeatWriteCommand:(NSDictionary *)dicSendCommand ReceiveCommand:(NSDictionary *)dicReveiveCommand PassString:(NSString *)szPass ReturnValue:(NSMutableString *)szReturnValue;

// soshon, 2012/4/19
// calculate offset. combine two Hex value. ex:  KEY1->0xDE KEY2->0x05   combine DE05
// Param:
//      NSDictionary    *dicSubSetting   : Settings
//                KEY1 -> NSString  *    : get the key of first value
//                KEY2 -> NSString  *    : get the key of second value
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
-(NSNumber *)Calculate_Offset:(NSDictionary *)dicParam RETURN_VALUE:(NSMutableString *)strReturnValue;

// soshon, 2012/4/19
// calculate tesla. dTestFlap = (strOffset-strVoltage )/(1.25*10);
// Param:
//      NSDictionary    *dicSubSetting   : Settings
//              OFFSET -> NSString  *    : get the key name for offset
//             VOLTAGE -> NSString  *    : get the key name for Voltage
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
-(NSNumber *)Calculate_Tesla:(NSDictionary *)dicParam RETURN_VALUE:(NSMutableString *)strReturnValue;

//add note by soshon, 2012/4/19
// Convert Voltage. if dFlapVolage > 2048   dReturnValue = 1500 - 1500*(((double)(4096-dFlapVolage))/2048);
//                  else dReturnValue = 1500 + 1500*(((double)(dFlapVolage))/2048)
// Param:
//      NSDictionary    *dicSubSetting   : Settings
//          NO settings in  this function
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
-(NSNumber *)ConvertVoltage:(NSDictionary *)dicParam RETURN_VALUE:(NSMutableString *)strReturnValue;

//betty 2012/4/20
//Split the value Voltage to Two part. for example DE05   after split DE and 05
//Param:
//       NSDictionary    *dicSubSetting   : Settings
//                  KEY1  NSString*  : The key you want to memory in m_dicMemoryValues
//                  KEY2  NSString*  : the key you want to memory in m_dicMemoryValues
//        SplitLocation   NSString*  : the location you want to split the string
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
-(NSNumber *)SplitVoltage:(NSDictionary *)dicParam RETURN_VALUE:(NSMutableString *)strReturnValue;

//betty 2012/4/20
//Write the date in to the path file
//Param:
//       NSDictionary    *dicSubSetting   : Settings
//                  KEY  NSString*   : The name you want to memory in the file
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
-(NSNumber *)WriteToPlist:(NSDictionary *)dicParam RETURN_VALUE:(NSMutableString *)strReturnValue;

//betty 2012/4/20
//caculate a array standard deviation 
//Param:
//       NSDictionary    *dicSubSetting   : Settings
//                  KEY  NSString*   : The key you memory in the m_dicMemoryValue
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
-(NSNumber *)CalculateSTD:(NSDictionary *)dicParam RETURN_VALUE:(NSMutableString *)strReturnValue;

//betty 2012/4/20
//Read the AveVoltage from plist file, and show it On UI
//Param:
//       NSDictionary    *dicSubSetting   : Settings
//                  KEY  NSString*   : The key you want get from plist file
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
-(NSNumber *)ADD_AveVoltage_TO_CSV:(NSDictionary *)dictData RETURN_VALUE:(NSMutableString *)szReturnValue;

//betty 2012/4/24
//change the flag m_bNoUploadPDCA you set
//Param:
//       NSDictionary    *dicSubSetting   : Settings
//                  KEY  NSString*        : set the bool value you want not upload to PDCA or not, default is NO
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
-(NSNumber *)NONEED_UPLOAD_PDCA:(NSDictionary *)dicPara RETURN_VALUE:(NSMutableString *)szReturnValue;
/*!
 *	Find the missed and detect  location. Used for Hall effect
 *	@author			jingfu ran
 *	@Since			2012 04 26
 *	@param			dicSetting
 *					the setting dicationary
 *					
 *	@return			if find return YES,Otherwise return NO
 */
-(NSNumber *)FindTheMissOrDetectLocation:(NSDictionary *)dicSetting ReturnValue:(NSMutableString *)strReturn;

/*!
 *	caculate the distance from return value from prox sensor
 *	@author			jingfu ran
 *	@Since			2012 04 26
 *	@param			dicSetting
 *					the setting dicationary
 *	@return			if get correct return value,return YES
 */
-(NSNumber *)CalculateMoveDistance:(NSDictionary *)dicSetting ReturnVale:(NSMutableString *)strReturn;
/*!
 *	caculate the distance from return value from prox sensor
 *	@author			jingfu ran
 *	@Since			2012 04 26
 *	@param			dicSetting
 *					the setting dicationary
 *	@return			if get correct return value,return YES.strReturn is the get value
 */
-(NSNumber *)GetDistance:(NSDictionary *)dicSetting ReturnValue:(NSMutableString *)strReturn;

/*!
 *	copy from coco's sample code,get the distance
 *	@author			jingfu ran
 *	@Since			2012 04 26
 *	@param			high
 *					high char
 *	@param			low
 *					low char
 *	@return			get the distance
 */
-(float) CalculateDistanceFromBytes:(unsigned int) high low:(unsigned int) low;
/*!
 *	if ISNUMBERINDEX is YES, will get the number of Target,Otherwise get the path of target 
 *	@author			jingfu ran
 *	@Since			2012 04 28
 *	@param			dicSetting
 *                  KEY<---------------------->VALUE
 *                  ISNUMBERINDEX               idWantToNumberIndex(id)
 *                  SeperateChar                strChar(NSNumber)
 *                  TARGET                      The target path you want
 *
 *	@return   if successfully return YES,Otherwise return NO!			
 */
-(NSNumber *)READ_FIXTURESN:(NSDictionary *)dicSetting ReturnValue:(NSMutableString *)strRetur;

- (NSNumber *)JudgeMoveDistance:(NSDictionary *)dicSetting ReturnValue:(NSMutableString *)strReturn;


- (NSNumber *)CheckDistance:(NSDictionary *)dicSetting ReturnValue:(NSMutableString *)strReturn;

- (NSNumber *)CheckMotorStatus:(NSDictionary *)dicSetting ReturnValue:(NSMutableString *)strReturn;

/*calculate average value of some values that saved in dictionary
 *if value is "NA" or "" ,won't be calculated
 */
-(NSNumber *)AVERAGE_FORKEYS:(NSDictionary *)dicSetting RETURN_VALUE:(NSMutableString *)strReturn;

/*!
 *	Check the matrix row count and column count
 *	@author			Lorky Luo
 *	@Since			2012 05 01
 *	@param			strReturn
 *						return from before subitem.
 *						It should can be split by '\n' as rows and each rows should can be split by '\t' as columns
 *					dicSetting
 *						KEY<------------------------>VALUE
 *						RowCount					rowCount(NSNumber)
 *						ColCount					colCount(NSNumber)
 *	@return			whether the strReturn is correct matrix
 */
- (NSNumber *)CHECKMATRIX:(NSDictionary *)dicSetting RETURN_VALUE:(NSMutableString *)strReturn;

/*!
 *	GETDRAGONFLYDATA
 *	@author			Chao
 *	@Since			2012 04 30
 *	@param			dicParam
 *                  KEY<---------------------->VALUE
 *                  DISPOSAL               strValue
 */
-(NSNumber *)GETDRAGONFLYDATA:(NSDictionary *)dicParam RETURN_VALUE:(NSMutableString *)strReturnValue;


/*!
 *	judge the prox data has unsigned char "81 6 59",if has and length > 3. Read data and return YES.
 Otherwise do nothing and return NO!
 *	@author			jingfu ran
 *	@Since			2012 04 30
 *	@param			dicSetting
 *                  KEY<---------------------->VALUE
 *                  PROXHASSTRING               strHasString(NSString *)
 */
-(NSNumber *)JudgeProxSensorData:(NSDictionary*)dicSetting return_Value:(NSMutableString *)strReturn;

/*!
 *	return the abs value(float number)
 *	@author			jingfu ran
 *	@Since			2012 05 10
 *	@param			value 
 *  @return         abs value
 */
-(float)absFloat:(float)value;

/*!
 *	move the motor to the top and read out the real prox sensor distance
 *	@author			jingfu ran
 *	@Since			2012 05 10
 *	@param			dicSetting
 *                  KEY<---------------------->VALUE
 *                  PROXHASSTRING               strHasString(NSString *)
 *                  PROXSENSORTARGET            strProxSensorTarget
 *                  COMMAND                     strFixCommand
 *                  PROXHASSTRING               strProxHasString
 *                  PROXCOMMAND                 strProxCommand
 *                  CALVALUE                           strCalValue
 */
-(NSNumber *)RemoveToPosition:(NSDictionary *)dicSetting Return_Value:(NSMutableString *)strReturn;

/*
 *Fixture move to top
 */
-(NSNumber *)MOVE_TOP:(NSDictionary *)dicSetting RETURN_VALUE:(NSMutableString *)strReturn;
/*
 *Write CSV lOG
 */
-(NSNumber *)JUDGESPEC_CSV_UPLOADPARAMETRIC:(NSDictionary  *)dicPara  RETURN_VALUE:(NSMutableString*)szReturnValue;

- (NSNumber *)CatchWIFISN:(NSDictionary  *)dicPara  RETURN_VALUE:(NSMutableString*)szReturnValue;

- (NSNumber *)READ_EEPROM:(NSDictionary *)dicPara RETURN_VALUE:(NSMutableString *)szReturnValue;

- (NSNumber *)READ_EEPROM_CHECK_SELETED_ITEMS:(NSDictionary *)dicPara RETURN_VALUE:(NSMutableString *)szReturnValue;

-(NSNumber *)JudgeSetChargeOrNot:(NSDictionary *)dicSub RETURN_VALUE:(NSMutableString *)szReturnValue;
/*
 *	check script to make sure the right line run the right script
 *	@author			Lucky Jin
 *	@Since			2012 11 20
 *	@param			dicSetting
 *					key:the key words of StationID(the line name)
 *					value: the key words of script file name
 */
-(NSNumber*)CHECKSCRIPT:(NSDictionary *)dicItemInfo RETURN_VALUE:(NSMutableString *)strReturnValue;
/*
 *	catch value from key in m_dicMeroryValue
 *	@author			sam zhang
 *	@Since			2013 1 15
 *	@param			key     :   key of value in m_dicMemoryValue want to catch
 *                  SAVEKEY : key that value of catched save in m_dicMemoryValue 
 *                  FROM    : index of catch string from
 *                  LENGTH  : length of catch string
 *                  DELETE  : whether delete space
 *					RETURN_VALUE: catched string
 */
-(NSNumber*)CatchString:(NSDictionary *)dicPara RETURN_VALUE:(NSMutableString *)strReturnValue;
/*
 *	check RSKU Fromat correct ot not
 *	@author			sam zhang
 *	@Since			2013 1 16
 *	@param			dicPara
 *					not dicPara
 *					RETURN_VALUE: error code
 */
-(NSNumber*)CheckRSKUFromat:(NSDictionary*)dicPara RETURN_VALUE:(NSMutableString *)strReturnValue;
/*
 *	check RSKU fromat
 *	@author			sam zhang
 *	@Since			2013 1 17
 *	@param			key
 *					sub   : sub string key in m_dicMemoryValue 
 *                  super : super string key in m_dicMemoryValue
 *					RETURN_VALUE: error code
 */
-(NSNumber*)ContainString:(NSDictionary *)dicPara RETURN_VALUE:(NSMutableString *)strReturnValu;
/*
 *	compare value after transfrom in table 
 *	@author			sam zhang
 *	@Since			2013 1 18
 *	@param			key          :   key of comparing value and not transform
 *                  transformkey :   key of compareing value after transform
 *                  table        :  a NSdictionary contain table for transforming 
 *					RETURN_VALUE: error code
 */
-(NSNumber*)CompareTransFeromInTable:(NSDictionary*)dicPara RETURN_VALUE:(NSMutableString *)strReturnValu;
/*combine string
 *  Combine : string want to combine
 *  Special : Special string to Combine
*/
-(NSNumber*)CombineStringBySpecialString:(NSDictionary*)dicPara RETURN_VALUE:(NSMutableString *)strReturnValue;
/*
 *	catch string from strReturnValue in CHANGE_MODE_TO_GRAPECAL item.
 *	@author			Lily Yin
 *	@Since			2013 2 4
 *	@param			key          :   key of value need to catch
 *					RETURN_VALUE :   catched string
 */
-(NSNumber *)RemoveLastContent:(NSDictionary *)dicPara RETURN_VALUE:(NSMutableString*)strReturnValue;

//Change the title show on the muifa window
//Param:
//       NSDictionary    *dicContents   : Settings
//                  KEY  NSString*   : the title you want to show on UI
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
- (NSNumber *)ChangeUITile:(NSDictionary *)dicContents RETURN_VALUE:(NSMutableString *)szReturnValue;

//print the label
//Param:
//       NSDictionary    *dicContents   : Settings
//                  Label   NSArray *   : the array of label you want to print
//                      NSDictionary*   :
//                          PREFIX  NSString*   : the prefix you want add before content
//                          SUFFIX  NSString*   : the suffix you want add after content
//                          PRINTER_KEY  NSString*   : the key you want to print
//                          PRINTER_TYPE  NSString*   : print type  0 -> print barcode and text; 1-> only print barcode;  2-> only print text
//                           PRINTER_PRE_SUF  boolean     : YES -> barcode with prefix and suffix, NO -> barcode only print content
//      NSString *      SettingFileName: printer setting file name
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
- (NSNumber *)Print_Label:(NSDictionary *)dicContents RETURN_VALUE:(NSMutableString *)szReturnValue;

//setting printer command
//Param:
//       NSDictionary    *dicContents   : Settings on PrinterSetting.plist      
//       NSDictionary    *dicPrinter    : setting on script file
// Return:
//      Actions result
- (BOOL)Setting_Printer:(NSDictionary *)dicContents withPrintLabel:(NSDictionary *)dicPrinter;

//Read the data from OS mode
//Param:
//       NSDictionary    *dicContents   : Settings
//                  KEY  NSString*   : the key you want to memory your value
//              Command  NSString*   : command on OS mode for reading information
//                 Path  NSString*   : the mobdev path    
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
- (NSNumber *)OS_MODE_READ:(NSDictionary *)dicOsSetting RETURN_VALUE:(NSMutableString *)szReturnValue;

//Judge Prox spec
//Param:
//       NSDictionary    *dicContents   : Settings
//                  KEY  NSString*   : the key of value which value you want to judge
//                  SPEC NSString*   : spec 
//                 COUNT  NSString*  : count of value judge pass
//                  UP    BOOL       : YES: number of judge pass more than count will pass. NO:oppositite.
// Return:
//      Actions result
-(NSNumber *)JUDGE_PROX_VALUE:(NSDictionary *)dicSetting RETURN_VALUE:(NSMutableString *)szReturnValue;

//Get LCD Vendor
- (NSNumber *)READ_VENDOR:(NSDictionary *) dicPara RETURNVALUE:(NSMutableString *)retValue;

//Get LED BRT
- (NSNumber *)GET_LED_BRT:(NSDictionary *)dicPara RETURNVALUE:(NSMutableString *)retValue;

//Get LED Vendor
- (NSNumber *)READ_LED_VENDOR:(NSDictionary *)dicPara RETURNVALUE:(NSMutableString *)retValue;

//Get LED Color
- (NSNumber *)GET_LED_COLOR:(NSDictionary *)dicPara RETURNVALUE:(NSMutableString *)retValue;

- (BOOL)WriteCommand:(NSDictionary *)dicSendCommand ReceiveCommand:(NSDictionary *)dicReveiveCommand ReturnValue:(NSMutableString *)szReturnValue;

-(NSNumber *)CHECK_UNIT_LIVE:(NSDictionary *)dicSub RETURN_VALUE:(NSMutableString *)szReturnValue;


//add by betty, 2013/09/24 For Gatekeeper, if the result is fail, no need to disconnect battery and check unit shutdown
//Check the above items test result
//Param:
//       NSDictionary    *dicContents   : Settings
//              FailCancel  boolean     : YES  ==> If test result Fail, change the cancel flag to YES
//                                        NO  ==> If test result Pass, change the cancel flag to NO
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
-(NSNumber *)CheckTestResultCancel:(NSDictionary *)dicSub
				RETURN_VALUE:(NSMutableString *)szReturnValue;

//add for MLB CRB station
- (NSNumber *)Fail_Station_Matching:(NSDictionary *)dictPara RETURN_VALUE:(NSMutableString *)szReturnValue;
- (NSNumber *)Query_Fail_Station_WSDL:(NSDictionary *)dictPara RETURN_VALUE:(NSMutableString *)szReturnValue;
- (NSNumber *)Query_Fail_Station_CRB_Result:(NSDictionary *)dictPara RETURN_VALUE:(NSMutableString *)szReturnValue;
- (NSNumber *)WRITE_WSDL:(NSDictionary *)dictPara RETURN_VALUE:(NSMutableString *)szReturnValue;

//add by xiaoyong, 2014/03/22 For Mesa EEPROM Test, if the result count is not 10,fail. if result contain "0x00" or "0xff" fail.
//Check the above items test result
//Param:
//          NSDictionary    *dicContents   :
//
//          NSMutableString *strReturnValue : Return value
// Return:
//      YES.

- (NSNumber *)TEST_MESA_EEPROM:(NSDictionary *)dicContent RETURN_VALUE:(NSMutableString *)szReturnValue;
- (NSNumber *)MESA_CHIPID:(NSDictionary *)dicContent RETURN_VALUE:(NSMutableString *)szReturnValue;
//add by sam, parse barcode for qt0
-(NSNumber *)PARSEBARCODE:(NSDictionary * )dicContent RETURN_VALUE:(NSMutableString *)szReturnValue;

- (NSNumber *)CHECK_SECURITY_LIVE:(NSDictionary *)dicSub RETURN_VALUE:(NSMutableString *)szReturnValue;

- (NSNumber *)READ_TERMINAL:(NSDictionary*)dictSettings RETURN_VALUE:(NSMutableString*)szReturnValue;

-(NSNumber *)CHECK_NANDSIZE_WITH_SPEC:(NSDictionary *)dicContents
                         RETURN_VALUE:(NSMutableString *)szReturnValue;

- (NSNumber *)MAPPING_TABLE:(NSDictionary *)dicSetting
			   RETURN_VALUE:(NSMutableString *)strReturnValue;

// 2013-10-30 add by xiaoyong for pressure function

- (NSNumber *)GET_ROW_FROM_RAWDATA:(NSDictionary *)dicSetting RETURN_VALUE:(NSMutableString *)szReturnValue;
//add by sam
-(NSNumber *)CAL_SQRT:(NSDictionary* )dicParam RETURN_VALUE:(NSMutableString*)strReturnValue;

//Add by Lily
- (NSNumber *)EZ_LINK_TEST:(NSDictionary *)dictPara
              RETURN_VALUE:(NSMutableString *)strReturn;
//add by sam for upload file to PDCA
-(NSNumber*)CREATE_FOLDER:(NSDictionary* )dicParam RETURN_VALUE:(NSMutableString *)strReturnValue;
-(NSNumber*)MOVE_FILE:(NSDictionary* )dicParam RETURN_VALUE:(NSMutableString *)strReturnValue;
//-(NSNumber*)MAKEBLOB_FILE:(NSDictionary* )dicParam RETURN_VALUE:(NSMutableString *)strReturnValue;
-(NSNumber*)UPLOAD_FILE:(NSDictionary* )dicParam RETURN_VALUE:(NSMutableString *)strReturnValue;
-(NSNumber*)REMOVE_FILE:(NSDictionary* )dicParam RETURN_VALUE:(NSMutableString *)strReturnValue;
@end
