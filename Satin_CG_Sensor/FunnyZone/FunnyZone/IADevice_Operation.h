//  IADevice_Operation.h
//  Izual_Lu
//
//  Created by Lu Izual on 11-5-5.
//  Copyright 2011年 PEGATRON. All rights reserved.



#import "TestProgress.h"
#import "judgePanel.h"
#import "PEGA_ATS_UART/SearchSerialPorts.h"



@interface TestProgress (IADevice_Operation)

//Start 2011.10.28 Add by Ming 
// Descripton:Set the UI's SN be the test item at csv file
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)GET_ISN_FROM_UI:(NSDictionary*)dicContents
			   RETURN_VALUE:(NSMutableString*)strReturnValue;
//End 2011.10.28 Add by Ming

/*
// marked by torres,functional overlap 1011.11.30
//Start 2011.10.29 Add by Ming 
// Descripton:the function will caluate 2 value in dictionary with MINUS
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)MINUS:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue;
//End 2011.10.29 Add by Ming
*/

//Start 2011.10.29 Add by Ming 
// Descripton: Show a message windows with your setting string
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)MSGBOX_COMMAND:(NSDictionary*)dicContents
			  RETURN_VALUE:(NSMutableString*)strReturnValue;
//End 2011.10.29 Add by Ming


//Start 2011.10.29 Add by Ming 
// Descripton: Close a message windows
// Param:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
-(NSNumber*)CLOSE_MESSAGE_BOX:(NSDictionary*)dicContents
				 RETURN_VALUE:(NSMutableString*)strReturnValue;
//End 2011.10.29 Add by Ming

// torres 2011/11/30
// Descripton : Compare figure value in memory dictionary with the keys or deal with a array in memory dictionary with one key.
// Detail : if only one key in script file,default to be a array value,and make sure the object in array is a NSNumber,
//          bring a up-order to the array,and replace the undicsposed array with the seriation array,return the MAX or MIN.
//          else two or more keys,get each value from memory dictionary,and return the MAX or MIN.
// Param:
//      dicpare   --->  KEY         The keys of the value you memoried
//                                      FORMAT : KeyName /or/ KeyNameOne,keyNameTwo,.......
//                      TYPE        MAX/MIN(default MAX)
//      strReturnValue  ---> Return the max or min.
-(NSNumber *)COMPARE_WITH_KEY:(NSDictionary *)dicpara
				 RETURN_VALUE:(NSMutableString *)szReturnValue;

// torres 2011/11/30
// Descripton : transform the value in memory dictionary with the key to ABS. torres 2011/11/7
//      KEY :  KeyName /or/ NULL
//          if has a key,read value from memory dictionary,else NULL key,deal with the m_szReturnValue. 
//      TYPE:   set the type,default int. 
-(NSNumber *)TRANSFER_DATA_ABS:(NSDictionary *)dicSubSetting
				  RETURN_VALUE:(NSMutableString *)szReturnValue;

// torres 2011/11/30
// Descripton : Calibration average of the memoried values with key,if only one key in script file,default to be a array value,
//              and make sure the object in array is a NSNumber,else two or more keys,get each value from memory dictionary.
// Parameter : 
//          NSDictionary    *dicPara 
//                  KEY     -> NSString*    :   the keys of the value you memoried
//                                              FORMAT : keyNmae /or/ keyNameOne,keyNameTwo,keyNameThree  ...
//                  ABS     ->  BOOL        :   the values that are caculated  will transfer to the absolute value
//          NSMutableString *szReturnValue  :   Return value
//              
//      Return:
//          Actions result            
-(NSNumber *)AVERAGE_WITH_KEYS:(NSDictionary *)dicPara
				  RETURN_VALUE:(NSMutableString *)szReturnValue;

// torres 2011/11/30
// Get the complement value of the previous szReturnValue with bit number
//      Parameter:
//
//          NSDictionary    *dicPara        :   Setting
//              DATABITS    ->  NSString*   :   The bits of the value(8 or 16)
//          NSMutableString  *szReturnValue :   Return value
//
//      Return:
//          Action result
-(NSNumber *)GET_INT_COMPLEMENT_WITH_BIT:(NSDictionary *)dicPara
							 ReturnValue:(NSMutableString *)szReturnValue;

// torres 2011/11/30
//  Do minus arithmetic with two values of keys,the frist value minus the second value
//      Parameter : 
//
//          NSDictionary    *dicPara 
//                  KEY     -> NSString*    :   the keys of the value you memoried
//                                              FORMAT : keyNameOne,keyNameTwo
//                  ABS     -> Boolean      :   if YES,return ABS value,else return normal
//          NSMutableString *szReturnValue  :   Return value
//              
//      Return:
//          Actions result
- (NSNumber *)MINUS_WITH_KEYS:(NSDictionary *)dicPara
				 RETURN_VALUE:(NSMutableString *)szReturnValue;

/*
 * Kyle 2010.12.13
 * method  : ScientificToDouble:RETURN_VALUE:
 * abstract:
 * key     :
 *
 */

// add remark by desikan 2012.4.19
// Descripton : Change one number from scientfic to normal
// Parameter : 
//          NSDictionary    *dicPara   :None
//          NSMutableString *szReturnValue  :   result of the conversion
//              eg.   change  1.2E3  to 1200
//      Return:
//          Actions result 
//  marked by desikan 2012.4.27  combine with "ChangeScientificToNormal:RETURN_VALUE:"
//- (NSNumber *)ScientificToDouble:(NSDictionary *)dicSetting RETURN_VALUE:(NSMutableString *)szReturnValue;

/*
 * Kyle 2012.02.10
 * abstract   : call a task for user system tool
 * parameters :
 *              szPath        ==> path of task
 *              args          ==> parameters of task
 *              EndString     ==> read data until find EndString
 *              iSeconds      ==> time out , unit is second
 *              szReturnValue ==> get string value
 */
- (BOOL)CallTask:(NSString *)szPath
	   Parameter:(NSArray *)args
	   EndString:(NSString *)EndString
		 TimeOut:(NSNumber *)iSeconds
	 ReturnValue:(NSMutableString *)szReturnValue;

/*
 * Kyle 2012.02.13
 * method       : GetKongCableVersion:RETURN_VALUE:
 * abstract     : use astrisctl for get kong cable version
 *
 */
- (NSNumber *)GetKongCableVersion:(NSDictionary*)dictSettings
					 RETURN_VALUE:(NSMutableString*)szReturnValue;

/*
 * Kyle 2012.02.16
 * method     : GetUSBStress:RETURN_VALUE:
 * abstract   : use dfuit tool
 * key        :   
 *               ToolPath ==> path of dfuit
 *               Filepath ==> path of RamDisk_v1.dmg
 */
- (NSNumber *)GetUSBStress:(NSDictionary*)dictSettings
			  RETURN_VALUE:(NSMutableString*)szReturnValue;

- (NSNumber *)CalculateCurrent:(NSDictionary*)dictSettings
				  RETURN_VALUE:(NSMutableString*)szReturnValue;

// Ken 2012/05/26
//  Call Application
//      Parameter : 
//          NSDictionary    *dicSettings
//                  TARGET  -> NSString*    :   the Application path
//          NSMutableString *szReturnValue  :   Return value
//
- (NSNumber *)LAUNCH_APP:(NSDictionary*)dicSettings
			RETURN_VALUE:(NSMutableString*)szReturnValue;

// Open a window to chose unit color
- (NSNumber *)MSG_SINGLECHOICE: (NSDictionary   *)dicPara
                  RETURN_VALUE:(NSMutableString*)szReturnValue;

- (void)ColorChooseFinish: (NSNotification* )noti;

- (NSNumber *)WAIT_HERE:(NSDictionary   *)dicPara
           RETURN_VALUE:(NSMutableString*)szReturnValue;

@end




