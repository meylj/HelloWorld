//
//  IADevice_TestingCommands.h
//  Izual_Lu
//
//  Created by Lu Izual on 11-4-21.
//  Copyright 2011Âπ?PEGATRON. All rights reserved.
//

#import "TestProgress.h"

// 2012.2.20 Desikan 
//      Prox-Cal show ready bug(finished test,before plug out unit,ui show READY,but not PASS/FAIL),
//      get SN from Fonnyzone
extern NSString * const PostDataToMuifaNote;

@interface TestProgress (IADevice_TestingCommands)


// Judge spec
-(BOOL)JudgeSpec:(NSString *)szSpec return_value:(NSString *)szCatchedValue caseInsensitive:(BOOL)bCaseMode;

#pragma mark ############################## Testting Commands ##############################
 
// Open target port. {MOBILE, FIXTURE, LIGHTMETER, ...}
// Param:
//		NSDictionary	*dicOpenSettings	: Open target settings
//          TARGET  -> NSString*    : Target you want to open. {MOBILE, FIXTURE, LIGHTMETER, ...}
-(NSNumber*)OPEN_TARGET:(NSDictionary*)dicOpenSettings;

// Close target port. {MOBILE, FIXTURE, LIGHTMETER, ...}
// Param:
//		NSDictionary	*dicCloseSettings	: Close target settings
//          TARGET  -> NSString*    : Target you want to close. {MOBILE, FIXTURE, LIGHTMETER, ...}
-(NSNumber*)CLOSE_TARGET:(NSDictionary*)dicCloseSettings RETURN_VALUE:(NSMutableString*)strReturnValue;

// Clear target buffer. {MOBILE, FIXTURE, LIGHTMETER, ...}
// Param:
//		NSDictionary	*dicClearSettings	: Clear target settings
//          TARGET  -> NSString*    : Target you want to clear. {MOBILE, FIXTURE, LIGHTMETER, ...}
// Return:
//      Actions result
-(NSNumber*)CLEAR_TARGET:(NSDictionary*)dicClearSettings;

// Send command to TARGET, 4 mode: STRING, STRING(BYTE), STRING(HEXSTRING), DATA
// Param:
//		NSDictionary	*dicSendString	: Save contents that need to be send to device
//			TARGET			-> NSString*	: TARGET you send command to. {FIXTURE, MOBILE, LIGHTMETER, ...}
//			STRING			-> NSString*	: STRING you send out. (Can be nil)
//			DATA			-> NSData*      : DATA you send out. (Can be nil)
//			HEXSTRING		-> Boolean      : STRING is composed of Hex Values or not. (Can be nil)
//			BYTE			-> Boolean      : STRING convert to characters and write one by one or not. (Can be nil)
//          NUART           -> Boolean      : this key decide whether to save uart log
// Return:
//		Actions result
-(NSNumber*)SEND_COMMAND:(NSDictionary*)dicSendContents;

// Read values from TARGET
// Param:
//		NSDictionary	*dicReadSettings	: Save read settings
//			TARGET          -> NSString*	: TARGET you receive return values from. {FIXTURE, MOBILE, LIGHTMETER, ...}
//			TIMEOUT         -> NSNumber*	: READ TIME OUT. Default = Same with port setting. (Can be nil) (Unit: s)
//			BEGIN           -> NSString*	: Cut begin
//			END             -> NSString*	: Cut end
//          REPEAT          -> NSNumber*    : Cycle read. Default = 1. (Can be nil)
//          DELETE_ENTER    -> Boolean      : Delete \n or not
//          FAIL_RECEIVE    -> NSArray      : READ_COMMAND fail when the string read out contains the items in FAIL_RECEIVE
//          PASS_RECEIVE    -> NSArray      : READ_COMMAND pass when the string read out contains the items in PASS_RECEIVE
//          END_SYMBOL      -> NSArray      : 
//          MATCHTYPE       -> NSNumber*    : For END_SYMBOL, 0: Match all item, 1: Match any one
//          RETURN_DATA     -> Boolean      : For CB read
//          NUART           -> Boolean      : this key decide whether to save uart log
//      NSMutableString *szReturnValue      : Received return values. {STRING, DATA, BYTE}
// Return:
//		Actions result
-(NSNumber*)READ_COMMAND:(NSDictionary*)dicReadSettings 
			RETURN_VALUE:(NSMutableString*)szReturnValue;


/*! 2014.03.27, add REGEX key 
 *	Sub string out from class member variable m_szLastReturn.
 *	Keys except REGEX, will be deprecated in the future. 
 *	@param	dicCatchSettings
 *			REGEX		-> NSString*	: The regular expression string to sub your string.
 *			BEGIN		-> NSString*	: Cut sub string from here, but not include.
 *			END			-> NSString*	: Cut sub string end here, but not include.
 *			LOCATION	-> NSString*	: Cut sub string from given location.
 *											Do after BEGIN&END.
 *			Length		-> NSString*	: Cut sub string with given length.
 *											Do after BEGIN&END. 
 *	Return:
 *			szReturnValue ->NSMutableString	*     : Catched values
 */
-(NSNumber*)CATCH_VALUE:(NSDictionary*)dicCatchSettings 
		   RETURN_VALUE:(NSMutableString*)szReturnValue;

// Judge spec
// Param:
//		NSDictionary	*dicSpecSettings	: Save judge settings
//			COMMON_SPEC     -> NSDictionary
//              P_LimitBlack  -> NSString   : SPEC for Black Unit. (?,?), [?,?], {?,?,?}
//              P_LimitWhite  -> NSString   : SPEC for White Unit. (?,?), [?,?], {?,?,?}
//
//			MODE			-> NSNumber*	: Default = keep case = 0, ignore case = 1
// Return:
//		Actions result
-(NSNumber*)JUDGE_SPEC:(NSDictionary*)dicSpecSettings RETURN_VALUE:(NSMutableString*)szReturnValue;

// Save catched values to dictionary with given key
// Param:
//		NSDictionary	*dicMemoryContents	: Save memory contents
//			KEY		-> NSString*	: KEY name
// Relate:
//		NSMutableDictionary	*dicMemoryValues	: Save memory values with given key
-(NSNumber*)MEMORY_VALUE_FOR_KEY:(NSDictionary*)dicMemoryContents RETURN_VALUE:(NSMutableString*)szReturnValue;

//2011-8-4 add by Gordon
// get values from dictionary with given key
// Param:
//		NSDictionary	*dicMemoryContents	: Save memory contents
//			KEY		-> NSString*	: KEY name
// Return:
//      NSMutableString        *szReturnValue      : return the value in dicMemoryValues with given Key.
// Relate:
//		NSMutableDictionary	*dicMemoryValues	: Save memory values with given key
-(NSNumber*)GET_MEMORY_VALUE_FROM_KEY:(NSDictionary*)dicMemoryContents RETURN_VALUE:(NSMutableString*)szReturnValue;

// Compare some informations
// Param:
//      NSDictionary    *dicCompareSettings : A dictionary contains compare settings
//          Key         -> NSString*        : Value (The Key and Value should be add prefix: /* and suffix: */)
//          (The Value of Key and Value will be the keys of m_dicMemoryValues.)
//      NSMutableString        *szMatch           : Match information
// Return:
//      Actions result
-(NSNumber*)COMPARE:(NSDictionary*)dicCompareItems RETURN_VALUE:(NSMutableString*)szMatch;

// Upload attribute to the pudding
// Param:
//		NSDictionary	*dictUploadContents	: Upload contents
//          ATTRIBUTE   -> NSArray* : Attribute keys.
// 
-(NSNumber*)UPLOADATTRI:(NSDictionary*)dictUploadContents RETURN_VALUE:(NSMutableString *)szReturn;

// Upload parametric to the pudding
// Param:
//		NSDictionary	*dictUploadContents	: Upload contents
-(NSNumber*)UPLOAD_PARAMETRIC:(NSDictionary*)dictUploadContents RETURN_VALUE:(NSMutableString *)szReturn;

// Transform Hex to Int Value
// Param:
//      NSDictionary    *dicInsertItems : A dictionary contains KEY that indicates to the value in dicMemoryValues
// Return:
//      Actions result
-(NSNumber *)HEX_TO_INT:(NSDictionary *)dicInsertItems RETURN_VALUE:(NSMutableString *)szReturn;

// Wait for ms
// Param:
//      NSDictionary    *dicInsertItems    : TIME as format "ms"
// Return:
//      Actions result
-(NSNumber *)WAIT_MS:(NSDictionary *)dicInsertItems RETURN_VALUE:(NSMutableString*)szReturn;

//description : upload slot number to pdca by calling instant pudding API
//Param:
//    NSDictionary *dicInsertItems: 
// Return:
//      Actions result
-(NSNumber *)UPLOAD_SLOT_TO_PDCA:(NSDictionary *)dicInsertItems RETURN_VALUE:(NSMutableString*)szReturn;

// set prority,parimatric,cancelToEnd and so on
// Param:
//      NSDictionary    *dicSettingItems : A dictionary contains Priority,whether upload parimatric,when fail whether stop 
//      NSMutableString        *szReturn : return value
// Return:
//      Actions result
-(NSNumber*)SET_PROCESS_STATUS:(NSDictionary*)dicSettingItems RETURN_VALUE:(NSMutableString *)szReturn;

//description : AM I OK?
// Param:
//      NSDictionary        ->      *dicSubSetting
// Return:
//      Actions result
-(NSNumber *)AMIOK_CHECK:(NSDictionary *)dicSubSetting RETURN_VALUE:(NSMutableString *)szReturnValue;

// Description  :   save now time to dic
// Param:
//      NSDictionary        ->      *dicSubSetting
// Return:
//      Actions result
-(NSNumber *)SAVE_NOWTIME:(NSDictionary *)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue;
// Description  :   save today date to dic
// Param:
//      NSDictionary        ->      *dicSubSetting
// Return:
//      Actions result
-(NSNumber *)SAVE_NOWDATE:(NSDictionary *)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue;

// 2011.07.18 Add By Ming
// Descripiton:
// Copy Function From Magic "CHECK_N92_LIVE"
// Rename to Check_DUT_Alive
// Param:
// NSDictionary    *dicDUTContents  : Contains insert contents
// TARGET  -> NSString*    : Target you want to open. {MOBILE, FIXTURE, LIGHTMETER, ...}
// TIMEOUT     -> NSNumber*    : Insert time out. (Can be nil). Default = 3s
-(NSNumber*)CHECK_DUT_ALIVE:(NSDictionary *)dicDUTContents RETURN_VALUE:(NSMutableString*)strReturnValue;

//  set SN to m_szISN when we get sn from UNIT
// Param:
//      NSDictionary        ->      *dicSubSetting
// Return:
//      Actions result
-(NSNumber *)GET_SN:(NSDictionary *)dicSubSetting RETURN_VALUE:(NSMutableString *)szReturnValue;

// Get DUT syscfg from m_szLastValue
// Param:
//      NSDictionary    *dicInsertItems     : The item you want to get
//          CFGKEY      -> NSString*        : System config Key
// Return:
//      Actions result
-(NSNumber *)GET_SYSCFG:(NSDictionary *)dicInsertItems RETURN_VALUE:(NSMutableString*)szReturn;

//2012-4-16 add note by Sunny
//		calculator result of one expression
// Parameter:
//      NSDictionary        dicExpression : expression which need to calculate
// Return:
//      Actions result
-(NSNumber *)CALCULATOR:(NSDictionary *)dicExpression RETURN_VALUE:(NSMutableString *)szReturnValue;

// kyle 2011.11.10
// Change Hex To character
- (NSNumber *)TransformHexTocharacter:(NSDictionary*)dicPara RETURN_VALUE:(NSMutableString*)szReturnValue;

// Added  by kyle 2011/11/11
// Cancel Items
- (NSNumber *)JUDGE_SPEC_CANCEL:(NSDictionary*)dicPara RETURN_VALUE:(NSMutableString*)szReturnValue;
// Added  by kyle 2011/11/11
// change szReturnValue to "PASS" or "FAIL"
- (NSNumber *)CHANGE_RETURNVALUE_TO_PASS_FAIL:(NSDictionary*)dicPara RETURN_VALUE:(NSMutableString*)szReturnValue;

/*
 * kyle 2011.11.18
 * method:     GetExtremeValue:RETURN_VALUE:
 * abstract:   get max or min value
 * key:
 *             MAX             : if checked ==> get max value else ==> get min value
 *             Expression      : key of number
 *             ExpressionArray : key of array any number in
 */
- (NSNumber *)GetExtremeValue:(NSDictionary*)dictSettings RETURN_VALUE:(NSMutableString *)szReturnValue;

// kyle 2011.11.11  
// copy function: -(BOOL)CatchValuebyRowAndColumn:(NSDictionary*)dicpara ReturnValue:(NSString **)szReturnValue
// from maggic 
-(NSNumber *)CatchValuebyRowAndColumn:(NSDictionary*)dicpara RETURN_VALUE:(NSMutableString *)szReturnValue;

/*
 //Added  by Kyle 2011/11/11
 @method	 NumberSystemConvertion
 @abstract   binary system、decimal system and hexadecimal system convert each other.     
 @result	
 @key:
 CHANGE   : before convert with format
 TO       : after convert with format
 FROM     : which bit need to start convert
 LENGTH   : how long will be convert
 */
- (NSNumber *)NumberSystemConvertion:(NSDictionary*)dictSettings RETURN_VALUE:(NSMutableString *)szReturnValue;

/*
 * Kyle 2011.12.15
 * method   : AddFaileCases:RETURN_VALUE:
 * abstract : According to the current results of judgment which case will be failed
 * key      :
 *                  CASES --> name of case will be failed
 */
- (NSNumber *)AddFaileCases:(NSDictionary*)dicSetting RETURN_VALUE:(NSMutableString *)szReturnValue;

/*
 * Kyle 2012-01-08
 * method   : AddPassCases:RETURN_VALUE:
 * abstract : According to the current results of judgment which case will be passed
 * key      :
 *                  CASES --> name of case will be passed
 */
- (NSNumber *)AddPassCases:(NSDictionary*)dicSetting RETURN_VALUE:(NSMutableString *)szReturnValue;

/*
 * Kyle 2012-01-08
 * method   : AddCancelCases:RETURN_VALUE:
 * abstract : According to the current results of judgment which case will be canceled
 * key      :
 *                  CASES --> name of case will be canceled
 */
- (NSNumber *)AddCancelCases:(NSDictionary*)dicSetting RETURN_VALUE:(NSMutableString *)szReturnValue;

/*
 * Kyle 2012-01-09
 * method    :  CheckDisConnect:RETURN_VALUE;
 * abstract  :  check disconnect with DUT
 *
 */
- (NSNumber *)CheckDisConnect:(NSDictionary*)dicSetting RETURN_VALUE:(NSMutableString *)szReturnValue;

/*
 *descripe : get calbe name and set to szReturnValue;
 * for canceling Cases , such as "Fixture Init Kong"
 */
- (NSNumber *)GetCableName:(NSDictionary*)dicSetting RETURN_VALUE:(NSMutableString *)szReturnValue;

/*
 *descript : for canceling sub items , such as "SEND_COMMAND"
 */
- (NSNumber *)CancelSubItemsForKong:(NSDictionary*)dicSetting RETURN_VALUE:(NSMutableString *)szReturnValue;

/*
 *description : return value multiply by some number
 */
- (NSNumber *)MultiplyBy:(NSDictionary *)dicSetting RETURN_VALUE:(NSMutableString *)szReutrnValue;

/*
 *save some value to setting file as some key
 *dicSetting : NSDictionary* type , KEY => to save to in setting file
 */
- (NSNumber *)SAVE_TO_SF:(NSDictionary *)dicSetting RETURN_VALUE:(NSMutableString *)szReturnValue;

/*
 *combine string
 *dicSetting : strings need to combine
 */
- (NSNumber *)COMBINESTRING:(NSDictionary *)dicSetting RETURN_VALUE:(NSMutableString *)szReturnValue;

/*Origin objective : add for CT 4-up
 *dicSetting => you must set "TITLE", "MESSAGE"; "ABUTTONS" is optional, if no this key , deal as no button condition
 *Create SDPanel object
 *should consider no button and with button conditions => no button ,must call "CLOSE_PANEL" function to release sdPanel items. 
 */
- (NSNumber *)MESSAGE_PANEL:(NSDictionary *)dicSetting RETURN_VALUE:(NSMutableString *)szReturnValue;

/*Origin objective : add for CT 4-up
 *After call MESSAGE_PANEL no button condition , you must call this function to release sdPanel object.
 */
- (NSNumber *)CLOSE_PANEL:(NSDictionary *)dicSetting RETURN_VALUE:(NSMutableString *)szReturnValue;

- (NSNumber *)EXE_COMMAND_PACK:(NSDictionary *)dicSetting RETURN_VALUE:(NSMutableString *)szReturnValue;

- (NSNumber *)JUDGE_KEY:(NSDictionary *)dicSetting RETURN_VALUE:(NSMutableString *)szReturnValue;
- (NSNumber *)CHANGE_CASENAME_SPEC:(NSDictionary *)dicContents RETURN_VALUE:(NSMutableString *)szReturnValue;
@end
