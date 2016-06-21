#import "TestProgress.h"
extern NSString* const	BNRCounterForAEStationNotification;

/*!	This category is created for some basic testing commands. 
 *	@author	Izual Azurewrath on 2011-04-21. 
 *	@update	Desikan_Ding on 2012-02-20. 
 *			Fixed a Prox-Cal show ready bug(After test ending, before plug out unit, 
 *				UI shows READY but PASS/FAIL. ). */
//extern NSString * const PostDataToMuifaNote;



@interface TestProgress (BasicCommands)

#pragma mark - UART Communication 
/*!	Open the target port. 
 *	@param	dicOpenSettings
 *			TARGET	-> NSString*	: The target name which you want to open. 
 *										{MOBILE, FIXTURE, LIGHTMETER, ...} */
-(NSNumber*)OPEN_TARGET:(NSDictionary*)dicOpenSettings;

//To avoid that the value may be wrong in test button thread

-(NSNumber*)BUTTONREAD_COMMAND:(NSDictionary*)dicReadSettings
                  RETURN_VALUE:(NSMutableString*)szReturnValue;

/*!	Read response from target port.
 *	@param	dicReadSettings
 *			TARGET		-> NSString*	: The target name which you read response from.
 *			TIMEOUT		-> NSNumber*	: read time out(in seconds).
 *											Default is same with port settings.
 *			BEGIN		-> NSString*	: Cut sub string from here, but not include.
 *			END			-> NSString*	: Cut sub string end here, but not include.
 *			REPEAT		-> NSNumber*	: Repeat read for given times.
 *											Default is 1.
 *			DELETE_ENTER-> Boolean		: Remove \n from response or not.
 *			FAIL_RECEIVE-> NSArray*		: Fail if response contains any of them.
 *											(Priority lower than PASS_RECEIVE. )
 *			PASS_RECEIVE-> NSArray*		: Pass if response contains any of them.
 *											(Priority higher than FAIL_RECEIVE. )
 *			END_SYMBOL	-> NSArray*		: Read response until reach end symbol.
 *			MATCHTYPE	-> NSNmber*		: 0: Match all end symbols.
 *											1: Match at least one of end symbols.
 *			RETURN_DATA	-> Boolean		: For CB read...
 *			NUART		-> Boolean		: Save uart log or not.
 *	@param	szReturnValue
 *			The response string/data/byte that has been subed. */
-(NSNumber*)READ_COMMAND:(NSDictionary*)dicReadSettings
			RETURN_VALUE:(NSMutableString*)szReturnValue;

/*!	Clear the target port buffer, both input and output.
 *	@param	dicClearSettings
 *			TARGET	-> NSString*	: The target name which you want to clear.
 *										{MOBILE, FIXTURE, LIGHTMETER, ...} */
-(NSNumber*)CLEAR_TARGET:(NSDictionary*)dicClearSettings;

/*!	Send command to target port with 1 of 4 modes:
 *		STRING, STRING(BYTE), STRING(HEXSTRING), DATA
 *	@param	dicSendContents
 *			TARGET		-> NSString*	: The target name which you send command to.
 *											{MOBILE, FIXTURE, LIGHTMETER, ...}
 *			STRING		-> NSString*	: The string you want to send.
 *			DATA		-> NSData*		: The data you want to send.
 *			HEXSTRING	-> Boolean		: Is STRING a compose of Hex values or not.
 *			BYTE		-> Boolean		: Send characters one by one or not.
 *			NUART		-> Boolean		: Save uart log or not. */
-(NSNumber*)SEND_COMMAND:(NSDictionary*)dicSendContents;

/*!	Close the target port.
 *	@param	dicCloseSettings
 *			TARGET	-> NSString*	: The target name which you want to close.
 *										{MOBILE, FIXTURE, LIGHTMETER, ...} */
-(NSNumber*)CLOSE_TARGET:(NSDictionary*)dicCloseSettings
			RETURN_VALUE:(NSMutableString*)strReturnValue;

#pragma mark - Network Communication
/*!	Upload attribute to pudding. 
 *	@param	dictUploadContents
 *			ATTRIBUTE	-> NSArray*	: Attribute keys. */
-(NSNumber*)UPLOADATTRI:(NSDictionary*)dictUploadContents
		   RETURN_VALUE:(NSMutableString *)szReturn;

/*!	Upload parametric data to pudding. 
 *	@param	dictUploadContents
 * */
-(NSNumber*)UPLOAD_PARAMETRIC:(NSDictionary*)dictUploadContents
				 RETURN_VALUE:(NSMutableString *)szReturn;

/*!	Upload slot number to pdca by calling instant pudding API.
 *	@param	dicInsertItems
 **/
-(NSNumber *)UPLOAD_SLOT_TO_PDCA:(NSDictionary *)dicInsertItems
					RETURN_VALUE:(NSMutableString*)szReturn;

/*!	Call pudding AmIOK. */
-(NSNumber *)AMIOK_CHECK:(NSDictionary *)dicSubSetting
			RETURN_VALUE:(NSMutableString *)szReturnValue;


// For testing button thread to catch the right value
-(NSNumber*)CATCH_BUTTONVALUE:(NSDictionary*)dicCatchSettings
                 RETURN_VALUE:(NSMutableString*)szReturnValue;

#pragma mark - Access Test Value
/*!	Sub string out from class member variable m_szLastReturn.
 *	Keys except REGEX, will be deprecated in the future. 
 *	@param	dicCatchSettings
 *			REGEX		-> NSString*	: The regular expression string to sub your string. 
 *			BEGIN		-> NSString*	: Cut sub string from here, but not include.
 *			END			-> NSString*	: Cut sub string end here, but not include.
 *			LOCATION	-> NSString*	: Cut sub string from given location.
 *											Do after BEGIN&END.
 *			Length		-> NSString*	: Cut sub string with given length.
 *											Do after BEGIN&END. */
-(NSNumber*)CATCH_VALUE:(NSDictionary*)dicCatchSettings
		   RETURN_VALUE:(NSMutableString*)szReturnValue;

/*!	Get max/min value in an array.
 *	@author	Kyle_Yu on 2011-11-18.
 *	@param	dictSettings
 *			MAX	-> Boolean	: YES: get max value.
 *								NO: get min value. */
- (NSNumber *)GetExtremeValue:(NSDictionary*)dictSettings
				 RETURN_VALUE:(NSMutableString *)szReturnValue;

/*!	Catch value by row and column.
 *	@author	Kyle_Yu on 2011-11-11. */
-(NSNumber *)CatchValuebyRowAndColumn:(NSDictionary*)dicpara
						 RETURN_VALUE:(NSMutableString *)szReturnValue;

/*!	Memory the value until test end.
 *	@param	dicMemoryContents
 *			KEY	-> NSString*	: The memory key name. */
-(NSNumber*)MEMORY_VALUE_FOR_KEY:(NSDictionary*)dicMemoryContents
					RETURN_VALUE:(NSMutableString*)szReturnValue;

/*!	Get the memoried value by the given key.
 *	@author	Gordon_Liu on 2011-08-04.
 *	@param	dicMemoryContents
 *			KEY	-> NSString*	: The memoried key name.*/
-(NSNumber*)GET_MEMORY_VALUE_FROM_KEY:(NSDictionary*)dicMemoryContents
						 RETURN_VALUE:(NSMutableString*)szReturnValue;



#pragma mark - Convert Test Value
/*!	Change szReturnValue to PASS/FAIL, depends on last sub test item result.
 @author	Kyle_Yu on 2011-11-11. */
- (NSNumber *)CHANGE_RETURNVALUE_TO_PASS_FAIL:(NSDictionary*)dicPara
								 RETURN_VALUE:(NSMutableString*)szReturnValue;

/*!	Combine strings to a string.
 *	@param	dicSetting
 *			*/
- (NSNumber *)COMBINESTRING:(NSDictionary *)dicSetting
			   RETURN_VALUE:(NSMutableString *)szReturnValue;

#pragma mark - Judge Test Value 
/*!	Judge spec.
 *	@param	dicSpecSettings
 *			COMMON_SPEC	-> NSDictionary*	: Contains many kinds of spec.
 *												It is a math set such as (?,?), [?,?], {?,?,?}.
 *												Which one does it use?
 *												Depends on DUT color.
 *				P_LimitBlack	-> NSString*	: SPEC for Black DUT.
 *				P_LimitWhite	-> NSString*	: SPEC for White DUT.
 *			MODE		-> NSNumber*		: 0: Keep case sensitive.
 *												1: Case insensitive. */
-(NSNumber*)JUDGE_SPEC:(NSDictionary*)dicSpecSettings
		  RETURN_VALUE:(NSMutableString*)szReturnValue;

// the opposite result of judge spec
-(NSNumber*)OPPSITE_JUDGE_SPEC:(NSDictionary*)dicSpecSettings
                  RETURN_VALUE:(NSMutableString*)szReturnValue;

/*!	Compare with a given information.
 *	@param	dicCompareItems
 *			Key	-> NSString*	: The information you want to compare with.
 *									If you want to get some variable value from memory,
 *									please mark the key with comments mark.  */
-(NSNumber*)COMPARE:(NSDictionary*)dicCompareItems
	   RETURN_VALUE:(NSMutableString*)szMatch;



#pragma mark - Control Test Flow 
/*!	Wait for a given time. (in ms. )
 *	@param	dicInsertItems
 *			TIME	-> NSNumber*	: The time length. */
-(NSNumber *)WAIT_MS:(NSDictionary *)dicInsertItems
		RETURN_VALUE:(NSMutableString*)szReturn;

/*!	Set process status such as priority, parimatric, cancel to end and so on. 
 *	@param	dicSettingItems
 **/
-(NSNumber*)SET_PROCESS_STATUS:(NSDictionary*)dicSettingItems
				  RETURN_VALUE:(NSMutableString *)szReturn;

/*!	@author	Kyle_Yu on 2011-12-15.
 *	@param	dicSetting
 *			CASES	-> NSArray*	Names of test items that you want to set to FAIL. */
- (NSNumber *)AddFaileCases:(NSDictionary*)dicSetting
			   RETURN_VALUE:(NSMutableString *)szReturnValue;

/*!	@author	Kyle_Yu on 2012-01-08.
 *	@param	dicSetting
 *			CASES	-> NSArray*	Names of test items that you want to set to FAIL. */
- (NSNumber *)AddPassCases:(NSDictionary*)dicSetting
			  RETURN_VALUE:(NSMutableString *)szReturnValue;

/*!	@author	Kyle_Yu on 2012-01-08.
 *	@param	dicSetting
 *			CASES	-> NSArray*	Names of test items that you want to cancel. */
- (NSNumber *)AddCancelCases:(NSDictionary*)dicSetting
				RETURN_VALUE:(NSMutableString *)szReturnValue;

/*!	Cancel sub test items. */
- (NSNumber *)CancelSubItemsForKong:(NSDictionary*)dicSetting
					   RETURN_VALUE:(NSMutableString *)szReturnValue;

/*!	Cancel below tests if judge spec fail.
 *	@author	Kyle_Yu on 2011-11-11. */
- (NSNumber *)JUDGE_SPEC_CANCEL:(NSDictionary*)dicPara
				   RETURN_VALUE:(NSMutableString*)szReturnValue;



#pragma mark - Access DUT Values 
/*!	Copy method from Magic "CHECK_N92_LIVE"
 *	@author	Ming_Chen on 2011-07-18. 
 *	@param	dicDUTContents
 *			TARGET	-> NSString*	: The target name which you want to check. 
 *										{MOBILE, FIXTURE, LIGHTMETER, ...}
 *			TIMEOUT	-> NSNumber*	: How much time you want to wait? (in seconds. )
 *										Default = 3s. */
-(NSNumber*)CHECK_DUT_ALIVE:(NSDictionary *)dicDUTContents
			   RETURN_VALUE:(NSMutableString*)strReturnValue;
-(NSNumber*)CHECK_DUT_AT_OS_MODE:(NSDictionary *)dicDUTContents
					RETURN_VALUE:(NSMutableString*)strReturnValue;

/*!	Check whether DUT has been disconnected.
 *	@author	Kyle_Yu on 2012-01-09. */
- (NSNumber *)CheckDisConnect:(NSDictionary*)dicSetting
				 RETURN_VALUE:(NSMutableString *)szReturnValue;

/*!	Get SN from DUT, set it to m_szISN. */
-(NSNumber *)GET_SN:(NSDictionary *)dicSubSetting
	   RETURN_VALUE:(NSMutableString *)szReturnValue;

/*!	Get DUT syscfg from m_szLastValue. 
 *	@param	dicInsertItem
 *			CFGKEY	-> NSString*	: The syscfg key. */
-(NSNumber *)GET_SYSCFG:(NSDictionary *)dicInsertItems
		   RETURN_VALUE:(NSMutableString*)szReturn;



#pragma mark - Math Calculation 
/*!	Calculate result of the given expression. 
 *	@author	Sunny_Xing on 2012-04-16. 
 *	@param	dicExpression
 *			
 */
-(NSNumber *)CALCULATOR:(NSDictionary *)dicExpression
		   RETURN_VALUE:(NSMutableString *)szReturnValue;

/*!	Transform hex value to int value.
 *	@param	dicInsertItems
 * */
-(NSNumber *)HEX_TO_INT:(NSDictionary *)dicInsertItems
		   RETURN_VALUE:(NSMutableString *)szReturn;

/*!	Transform given hex to characters. 
 *	@author	Kyle_Yu on 2011-11-10. */
- (NSNumber *)TransformHexTocharacter:(NSDictionary*)dicPara
						 RETURN_VALUE:(NSMutableString*)szReturnValue;

/*!	Convert number system of given number. 
 *	@author	Kyle_Yu on 2011-11-11. 
 *	@param	dictSettings
 *			CHANGE	-> NSNumber*	: Which number system is it?
 *			TO		-> NSNumber*	: Which number system do you want?
 *			FROM	-> NSNumber*	: Which bit is the 1st bit? 
 *			LENGTH	-> NSNumber*	: How many bits do you want to convert? */
- (NSNumber *)NumberSystemConvertion:(NSDictionary*)dictSettings
						RETURN_VALUE:(NSMutableString *)szReturnValue;

/*!	Fuck. */
- (NSNumber *)MultiplyBy:(NSDictionary *)dicSetting
			RETURN_VALUE:(NSMutableString *)szReutrnValue;

#pragma mark - Other 
/*!	Save current time to memory. */
-(NSNumber *)SAVE_NOWTIME:(NSDictionary *)dicContents
			 RETURN_VALUE:(NSMutableString*)strReturnValue;

/*!	Get DUT cable name. */
- (NSNumber *)GetCableName:(NSDictionary*)dicSetting
			  RETURN_VALUE:(NSMutableString *)szReturnValue;
#pragma mark - NV_WRITE
- (NSNumber*)OnTaskWithPython:(NSDictionary *)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue;
- (NSNumber*) ReceiveOutputMessage : (NSNotification *)note ;
- (void) ReceiveErrorMessage : (NSNotification *)note;
@end




