//  IADevice_Other.h
//  Izual_Lu
//
//  Created by Lu Izual on 11-5-5.
//  Copyright 2011年 PEGATRON. All rights reserved.



#import "TestProgress.h"

@interface TestProgress (IADevice_Other)

// Get data from mobile in OS mode
// Param:
//      NSDictionary    *dictSettings       : Settings
//          LOCATION    -> NSString*    : Coco tool bundle path
//          TIMEOUT     -> NSNumber*    : Read time out
//      NSMutableString   *strReturnValue    : Return value
-(NSNumber*)GetDataFromOSMode:(NSDictionary*)dictSettings 
                  ReturnValue:(NSMutableString*)strReturnValue;

// Calculate temperature of thermistor component
// Param:
//      NSDictionary    *dictSettings   : Settings
//          VALUE       -> NSString*    : {NTC,TEMP}
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
- (NSNumber *)CALCULATE_TEMPERATURE_FOR_THERMISTOR:(NSDictionary *)dictSettings
									  RETURN_VALUE:(NSMutableString*)strReturnValue;

//2011-8-4 add by Gordon
// Transform value from hex to dec
// Param:
//      NSDictionary    *dictSettings   : Settings
//          Mode        -> NSString*    : {RECEIVE,FIXTURE,D_FIXTURE,BATQMAX}
//          CHANNEL     -> NSString*    : save data to key named by channel
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
- (NSNumber *)TRANSFORM_FOR_HEX_TO_DEC:(NSDictionary*)dictSettings
						  RETURN_VALUE:(NSMutableString*)strReturnValue;

//2011-8-4 add by Gordon
// Through get ClrC from Unit to judge whether the unit is white or black
// Param:
//      NSDictionary    *dictSettings   : Settings
//          NO settings in  this function
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
- (NSNumber *)GET_DUT_COLOR:(NSDictionary*)dictSettings
			   RETURN_VALUE:(NSMutableString *)strReturnValue;

//Start 2011.11.04 Add by Ming
// Descripton:Get the Start Time
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)GET_START_TIME:(NSDictionary*)dicContents
			  RETURN_VALUE:(NSMutableString*)strReturnValue;

//Start 2011.11.06 Add by Ming 
// Descripton:Change Test Case Name with Black/White
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)CHANGE_TESTCASENAME_WITH_COLOR:(NSDictionary*)dicContents
							  RETURN_VALUE:(NSMutableString*)strReturnValue;

// check root
- (NSNumber *)CURRENT_ROOT_CHECK:(NSDictionary *)dicSubSetting
					RETURN_VALUE:(NSMutableString *)szReturnValue;

- (NSNumber *)ChangeScientificToNormal:(NSDictionary*)dicContents
						  RETURN_VALUE:(NSMutableString*)szNumber;
- (NSNumber *)CHANGE_CANCLE_FLAG:(NSDictionary *)dicPara
					RETURN_VALUE:(NSMutableString *)szReturnValue;

//add by desikan at 2011/12/27
// description : do Round (四舍五入) 
- (NSNumber *)DO_ROUND:(NSDictionary *)dicPara
		  RETURN_VALUE:(NSMutableString *)szReturnValue;

/* Kyle 2012.02.14
 * method       : Provisioning:RETURN_VALUE:
 * abstract     : get SN by 3 ways */
- (NSNumber *)Provisioning:(NSDictionary *)dictSettings
			  RETURN_VALUE:(NSMutableString*)szReturnValue;

// 2012.2.21 Winter
// get prox data, and judge.   
- (NSNumber *)CAlCULATOR_PROX_DATA:(NSDictionary *)dicpara
					  RETURN_VALUE:(NSMutableString*)strReturnValue;
- (NSNumber *)MatchReginCode:(NSDictionary *)dicpara
				RETURN_VALUE:(NSMutableString*)strReturnValue;

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
- (NSNumber *)Judge_If_ALL_Value_Is_XX:(NSDictionary *)dicContents
						  RETURN_VALUE:(NSMutableString *)strReturnValue;

/*!
 */
-(NSNumber *)CHECK_UNIT_LIVE:(NSDictionary *)dicSub
				RETURN_VALUE:(NSMutableString *)szReturnValue;
-(NSNumber *)CHECK_OS_LIVE:(NSDictionary *)dicSub RETURN_VALUE:(NSMutableString *)szReturnValue;
// soshon, 2012/4/19
// calculate offset. combine two Hex value. ex:  KEY1->0xDE KEY2->0x05   combine DE05
// Param:
//      NSDictionary    *dicSubSetting   : Settings
//                KEY1 -> NSString  *    : get the key of first value
//                KEY2 -> NSString  *    : get the key of second value
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
-(NSNumber *)Calculate_Offset:(NSDictionary *)dicParam
				 RETURN_VALUE:(NSMutableString *)strReturnValue;

// soshon, 2012/4/19
// calculate tesla. dTestFlap = (strOffset-strVoltage )/(1.25*10);
// Param:
//      NSDictionary    *dicSubSetting   : Settings
//              OFFSET -> NSString  *    : get the key name for offset
//             VOLTAGE -> NSString  *    : get the key name for Voltage
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
-(NSNumber *)Calculate_Tesla:(NSDictionary *)dicParam
				RETURN_VALUE:(NSMutableString *)strReturnValue;

//add note by soshon, 2012/4/19
// Convert Voltage. if dFlapVolage > 2048   dReturnValue = 1500 - 1500*(((double)(4096-dFlapVolage))/2048);
//                  else dReturnValue = 1500 + 1500*(((double)(dFlapVolage))/2048)
// Param:
//      NSDictionary    *dicSubSetting   : Settings
//          NO settings in  this function
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
-(NSNumber *)ConvertVoltage:(NSDictionary *)dicParam
			   RETURN_VALUE:(NSMutableString *)strReturnValue;

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
-(NSNumber *)SplitVoltage:(NSDictionary *)dicParam
			 RETURN_VALUE:(NSMutableString *)strReturnValue;

//betty 2012/4/20
//Write the date in to the path file
//Param:
//       NSDictionary    *dicSubSetting   : Settings
//                  KEY  NSString*   : The name you want to memory in the file
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
-(NSNumber *)WriteToPlist:(NSDictionary *)dicParam
			 RETURN_VALUE:(NSMutableString *)strReturnValue;

//betty 2012/4/20
//caculate a array standard deviation 
//Param:
//       NSDictionary    *dicSubSetting   : Settings
//                  KEY  NSString*   : The key you memory in the m_dicMemoryValue
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
-(NSNumber *)CalculateSTD:(NSDictionary *)dicParam
			 RETURN_VALUE:(NSMutableString *)strReturnValue;

//betty 2012/4/20
//Read the AveVoltage from plist file, and show it On UI
//Param:
//       NSDictionary    *dicSubSetting   : Settings
//                  KEY  NSString*   : The key you want get from plist file
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
-(NSNumber *)ADD_AveVoltage_TO_CSV:(NSDictionary *)dictData
					  RETURN_VALUE:(NSMutableString *)szReturnValue;

//betty 2012/4/24
//change the flag m_bNoUploadPDCA you set
//Param:
//       NSDictionary    *dicSubSetting   : Settings
//                  KEY  NSString*        : set the bool value you want not upload to PDCA or not, default is NO
//      NSMutableString *strReturnValue : Return value
// Return:
//      Actions result
-(NSNumber *)NONEED_UPLOAD_PDCA:(NSDictionary *)dicPara
				   RETURN_VALUE:(NSMutableString *)szReturnValue;
/*! Find the missed and detect  location. Used for Hall effect
 *	@author			jingfu ran
 *	@Since			2012 04 26
 *	@param			dicSetting
 *					the setting dicationary
 *					
 *	@return			if find return YES,Otherwise return NO */
-(NSNumber *)FindTheMissOrDetectLocation:(NSDictionary *)dicSetting
							 ReturnValue:(NSMutableString *)strReturn;

/*! caculate the distance from return value from prox sensor
 *	@author			jingfu ran
 *	@Since			2012 04 26
 *	@param			dicSetting
 *					the setting dicationary
 *	@return			if get correct return value,return YES */
-(NSNumber *)CalculateMoveDistance:(NSDictionary *)dicSetting
						ReturnVale:(NSMutableString *)strReturn;
/*! caculate the distance from return value from prox sensor
 *	@author			jingfu ran
 *	@Since			2012 04 26
 *	@param			dicSetting
 *					the setting dicationary
 *	@return			if get correct return value,return YES.strReturn is the get value */
-(NSNumber *)GetDistance:(NSDictionary *)dicSetting
			 ReturnValue:(NSMutableString *)strReturn;

/*! copy from coco's sample code,get the distance
 *	@author			jingfu ran
 *	@Since			2012 04 26
 *	@param			high
 *					high char
 *	@param			low
 *					low char
 *	@return			get the distance */
-(float) CalculateDistanceFromBytes:(unsigned int) high
								low:(unsigned int) low;
/*! if ISNUMBERINDEX is YES, will get the number of Target,Otherwise get the path of target 
 *	@author			jingfu ran
 *	@Since			2012 04 28
 *	@param			dicSetting
 *                  KEY<---------------------->VALUE
 *                  ISNUMBERINDEX               idWantToNumberIndex(id)
 *                  SeperateChar                strChar(NSNumber)
 *                  TARGET                      The target path you want
 *
 *	@return   if successfully return YES,Otherwise return NO! */
-(NSNumber *)READ_FIXTURESN:(NSDictionary *)dicSetting
				ReturnValue:(NSMutableString *)strRetur;

- (NSNumber *)JudgeMoveDistance:(NSDictionary *)dicSetting
					ReturnValue:(NSMutableString *)strReturn;

- (NSNumber *)CheckDistance:(NSDictionary *)dicSetting
				ReturnValue:(NSMutableString *)strReturn;

- (NSNumber *)CheckMotorStatus:(NSDictionary *)dicSetting
				   ReturnValue:(NSMutableString *)strReturn;

/*calculate average value of some values that saved in dictionary
 *if value is "NA" or "" ,won't be calculated */
-(NSNumber *)AVERAGE_FORKEYS:(NSDictionary *)dicSetting
				RETURN_VALUE:(NSMutableString *)strReturn;

/*! Check the matrix row count and column count
 *	@author			Lorky Luo
 *	@Since			2012 05 01
 *	@param			strReturn
 *						return from before subitem.
 *						It should can be split by '\n' as rows and each rows should can be split by '\t' as columns
 *					dicSetting
 *						KEY<------------------------>VALUE
 *						RowCount					rowCount(NSNumber)
 *						ColCount					colCount(NSNumber)
 *	@return			whether the strReturn is correct matrix */
- (NSNumber *)CHECKMATRIX:(NSDictionary *)dicSetting
			 RETURN_VALUE:(NSMutableString *)strReturn;

/*! GETDRAGONFLYDATA
 *	@author			Chao
 *	@Since			2012 04 30
 *	@param			dicParam
 *                  KEY<---------------------->VALUE
 *                  DISPOSAL               strValue */
-(NSNumber *)GETDRAGONFLYDATA:(NSDictionary *)dicParam
				 RETURN_VALUE:(NSMutableString *)strReturnValue;

/*! judge the prox data has unsigned char "81 6 59",if has and length > 3. Read data and return YES.
 Otherwise do nothing and return NO!
 *	@author			jingfu ran
 *	@Since			2012 04 30
 *	@param			dicSetting
 *                  KEY<---------------------->VALUE
 *                  PROXHASSTRING               strHasString(NSString *) */
-(NSNumber *)JudgeProxSensorData:(NSDictionary*)dicSetting
					return_Value:(NSMutableString *)strReturn;

/*! return the abs value(float number)
 *	@author			jingfu ran
 *	@Since			2012 05 10
 *	@param			value 
 *  @return         abs value */
-(float)absFloat:(float)value;

/*! move the motor to the top and read out the real prox sensor distance
 *	@author			jingfu ran
 *	@Since			2012 05 10
 *	@param			dicSetting
 *                  KEY<---------------------->VALUE
 *                  PROXHASSTRING               strHasString(NSString *)
 *                  PROXSENSORTARGET            strProxSensorTarget
 *                  COMMAND                     strFixCommand
 *                  PROXHASSTRING               strProxHasString
 *                  PROXCOMMAND                 strProxCommand
 *                  CALVALUE                           strCalValue */
-(NSNumber *)RemoveToPosition:(NSDictionary *)dicSetting
				 Return_Value:(NSMutableString *)strReturn;

/* Fixture move to top */
-(NSNumber *)MOVE_TOP:(NSDictionary *)dicSetting
		 RETURN_VALUE:(NSMutableString *)strReturn;
/* Write CSV lOG */
-(NSNumber *)JUDGESPEC_CSV_UPLOADPARAMETRIC:(NSDictionary  *)dicPara
							   RETURN_VALUE:(NSMutableString*)szReturnValue;

- (NSNumber *)CatchWIFISN:(NSDictionary  *)dicPara
			 RETURN_VALUE:(NSMutableString*)szReturnValue;

- (NSNumber *)AVERAGE_PROX_MEAN:(NSDictionary *)dicSetting
				   RETURN_VALUE:(NSMutableString*)szReturnValue;

- (NSNumber *)CombineHEXData:(NSDictionary*)dicSetting
                RETURN_VALUE:(NSMutableString*)szReturnValue;


/*!
 *@ author:			Jean Bai	2013.03.01
 *@ description:	change return value format
 *@ param:
 *@					NSDictionary			*dictSettings   : Settings
 *@						SeparateString	->	NSString		: " ", "/n", "," ...
						AddString		->	NSString		: 0x
						AddBefore		->	Boolean			: YES/NO
						BeginIndex		->	NSNumber		: begin index
						EndIndex		->	NSNumber		: end index
 *@					NSMutableString			*strReturnValue : Return value
 */
- (NSNumber *)CUSTOM_COMBINE_DATA:(NSDictionary *)dicSetting
					 RETURN_VALUE:(NSMutableString*)szReturnValue;

/*!
 *	@ author:		Jean_Bai	2014.05.09
 *	@ param:		NSDictionary			*dictSettings   : Settings
 *	@					KEY				->	NSString		: KEY name
 *	@					SeperateString	->	NSString		: " ", "/n", "," ...
 *	@					Index			->	NSNumber		: 0,1,2,....
 */
- (NSNumber *)CATCH_VALUE_BY_INDEX:(NSDictionary *)dicSetting
					  RETURN_VALUE:(NSMutableString *)strReturnValue;

// Add by Jean
- (NSNumber *)CALCULATE_LCM_SN:(NSDictionary *)dicSetting
				  RETURN_VALUE:(NSMutableString *)strReturnValue;


- (NSNumber *)CALCULATERESULT:(NSDictionary *)dicSetting
                 RETURN_VALUE:(NSMutableString*)szReturnValue;
- (NSNumber *)SAVE_PLIST:(NSDictionary *)dicPara
			RETURN_VALUE:(NSMutableString *)szReturnValue;
- (NSNumber *)PASER_PDCA_FILE:(NSDictionary *)dicPara
				 RETURN_VALUE:(NSMutableString *)szReturnValue;

- (NSNumber *)CHECKLENGTH:(NSDictionary *)dicSetting
			 RETURN_VALUE:(NSMutableString *)szReturnValue;

- (NSNumber *)CANCEL_ITEM_FOR_REL_OR_OTHERLINE:(NSDictionary *)dicSetting
                                  RETURN_VALUE:(NSMutableString *)szReturnValue;
- (NSNumber *)Contain_String: (NSDictionary *)dicSetting
                RETURN_VALUE:(NSMutableString *)szReturnValue;

- (NSNumber *)COMPARE_CONFIG: (NSDictionary *)dicSetting
                RETURN_VALUE:(NSMutableString *)szReturnValue;

-(NSNumber*)START_JUDGE_PATTERN_TEST:(NSDictionary *)dicContents
                        RETURN_VALUE:(NSMutableString *)strReturnValue;

-(NSNumber*)CHECK_PATTERN_STATUS:(NSDictionary *)dicContents
                    RETURN_VALUE:(NSMutableString *)strReturnValue;

-(NSNumber*)END_JUDGE_PATTERN_TEST:(NSDictionary *)dicContents
                      RETURN_VALUE:(NSMutableString *)strReturnValue;
-(NSNumber*)READ_FILE:(NSDictionary*)dictContents
		 RETURN_VALUE:(NSMutableString*)strReturnValue;
-(NSNumber*)TCPRELAY_START:(NSDictionary*)dictContents
			  RETURN_VALUE:(NSMutableString*)strReturnValue;
-(NSNumber*)TCPRELAY_END:(NSDictionary*)dictContents
			RETURN_VALUE:(NSMutableString*)strReturnValue;

- (NSNumber *)CANCEL_ITEM_FOR_N49_OR_OTHERPRODUCTS:(NSDictionary *)dicSetting
                                      RETURN_VALUE:(NSMutableString *)szReturnValue;
-(NSNumber *)DeleteCommaForData:(NSDictionary*)dictContents
                   RETURN_VALUE:(NSMutableString*)strReturnValue;
-(NSNumber*)DATASTRING_TO_STRING:(NSDictionary*)dictContents
					RETURN_VALUE:(NSMutableString*)strReturnValue;
-(NSNumber*)CL200A_LUX:(NSDictionary*)dictContents
		  RETURN_VALUE:(NSMutableString*)strReturnValue;

/*!
 *@ author:			Jean Bai	2013.03.01
 *@ description:	Set the return value format
 *@ param:
 *@					NSDictionary			*dictSettings   : Settings
 *@						FORMAT_SETTING	->	NSString		: The return value new format
 *@					NSMutableString			*strReturnValue : Return value
 */
- (NSNumber *)SET_RETURNVALUE_FORMAT:(NSDictionary *)dicSetting
						RETURN_VALUE:(NSMutableString *)strReturnValue;


/*!
 *@ author:			Jean Bai	2013.03.04
 *@ description:	Get matched value according PRE_KEY
 *@ param:
 *@					NSDictionary			*dictSettings   : Settings
 *@						PRE_KEY			->	NSString		: previous key
 *@						POST_KEY		->	NSString		: key after matching
 *@						MAPPINF_TABLE	->	NSDictionary	: Mapping table
 *@					NSMutableString			*strReturnValue : Return value
 */
- (NSNumber *)MAPPING_TABLE:(NSDictionary *)dicSetting
			   RETURN_VALUE:(NSMutableString *)strReturnValue;

- (NSNumber *)ASC2Char:(NSDictionary *)dicSetting
		  RETURN_VALUE:(NSMutableString *)strReturnValue;

- (NSNumber *)Char2ASC:(NSDictionary *)dicSetting
		  RETURN_VALUE:(NSMutableString *)strReturnValue;


- (NSNumber *)JUDGESPECFORI2CADDRESS:(NSDictionary *)dicSetting
                        RETURN_VALUE:(NSMutableString *)strReturnValue;

- (NSNumber *)JUDGESPECFORI2CSPEC:(NSDictionary *)dicSetting
                     RETURN_VALUE:(NSMutableString *)strReturnValue;

- (NSNumber *)RECORD_CURRENT_SBURESULT_WITHKEY:(NSDictionary   *)dicPara
                                  RETURN_VALUE:(NSMutableString *)szReturnValue;

/*
 Add by Sky at 2013.6.21
 Description:   Delete the string from the string value if needed, always return YES except the format error.
 Param:
        KEY         ->          The string witch need to be modified. 
        REGEX       ->          Catch the value with need to delete.
 */
- (NSNumber *)DELETE_STRING_FROM_VALUE:(NSDictionary *)dicSetting
                          RETURN_VALUE:(NSMutableString *)strReturnValue;
-(NSNumber*)ADD_UART_LOG:(NSDictionary*)dictSetting
			RETURN_VALUE:(NSMutableString *)strReturnValue;

- (NSNumber *)CANCEL_ITEM_BY_BOOL_VALUE:(NSDictionary *)dicSetting
                           RETURN_VALUE:(NSMutableString *)szReturnValue;

- (NSNumber *)CANCEL_ITEM_BY_LINE_NAME:(NSDictionary *)dicSetting
                          RETURN_VALUE:(NSMutableString *)szReturnValue;

- (NSNumber *)SHOW_PROCESS_ISSUE_MSG_ON_SCREEN:(NSDictionary *)dicSetting
                                  RETURN_VALUE:(NSMutableString *)szReturnValue;

-(NSNumber*)SELECT_BOOTARGS_STATION:(NSDictionary*)dictSetting
					   RETURN_VALUE:(NSMutableString*)szReturnValue;

- (NSNumber *)ALSO_ALLOWED_SPEC:(NSDictionary *)dictPara
				   RETURN_VALUE:(NSMutableString *)szReturnValue;
- (NSNumber *)ALSO_ALLOWED_COUNT:(NSDictionary *)dictPara
					RETURN_VALUE:(NSMutableString *)szReturnValue;
-(NSNumber *)COUNT_CERTAIN_VALUE:(NSDictionary *)dicSetting
                    RETURN_VALUE:(NSMutableString *)szReturnValue;

/*
 Add by sky at 2014.3.10
 Description:    Add for some special spec request, eg. The different color unit need different spec.
 Param:
        KEY             ->      The postfix of the spec name. eg. The KEY is 'Black', the spec name is 'P_LimitBlack'
                                If this param is not exist, just append the szReturenValue as the postfix of the spec name.
        szReturnValue   ->      Do NOT change the return value.
*/
-(NSNumber *)CHANGE_SPECNAME:(NSDictionary*)dicPara
                RETURN_VALUE:(NSMutableString*)szReturenValue;
-(NSNumber *)JUDGE_TOTALNUM_AND_SPEC:(NSDictionary *)dicPara
                        RETURN_VALUE:(NSMutableString *)szReturenValue;

- (NSNumber *)RESTORE_DATE_COMPONENTS:(NSDictionary *)dictPara
						 RETURN_VALUE:(NSMutableString *)szReturnValue;

//Add by Lorky
- (NSNumber *)EZ_LINK_TEST:(NSDictionary *)dictPara
			  RETURN_VALUE:(NSMutableString *)strReturn;


//Add by sky, 2015.1.26
- (NSNumber *)FLTAVERAGE:(NSDictionary *)dicPara
            RETURN_VALUE:(NSMutableString *)strReturn;

//Add by sky, 2015.2.28
- (NSNumber *)LOADLIMITBASEONSOCTYPE:(NSDictionary *)dicPara
                        RETURN_VALUE:(NSMutableString *)strReturn;
//Add by Shirley on 2015-03-07
- (void)writeOrbDataToLogPath:(NSString*)iPath
                      andData:(NSString*)iData;

//Add by Shirley on 2015-03-06
- (NSNumber*)GET_ORB_VALUE:(NSDictionary*)dicMemoryData
              RETURN_VALUE:(NSMutableString*)szReturnValue;


/*
 Add by raniys on 3/11/2015
 Description:    Add for bitwise operators
 Param:
    KEY1             -> string1
    KEY1             -> string2
    OPERATOR         -> the value should be "AND"/"OR"/"XOR"
    MEMORYKEY        -> Memory key
    szReturnValue    -> Caculate result
 */
- (NSNumber *)BITWISE_OPERATOR_WITH_DATA:(NSDictionary *)dicOriginalData
                           RETURN_VALUE:(NSMutableString *)szReturnValue;

//Add by Shirley on 2015-03-14
- (NSNumber*)CACULATE_MUON_VALUE:(NSDictionary*)dicMemoryData
                    RETURN_VALUE:(NSMutableString*)szReturnValue;

//Scanning FCSN as the key for uploading FAIL record at SA_SuperFlex station
-(NSNumber *)SCAN_SN_FOR_UPLOAD_FAIL_RECORD:(NSDictionary *)dicPara
                               RETURN_VALUE:(NSMutableString *)strReturn;

@end




