//
//  IADevice_DetectPort.h
//  FunnyZone
//
//  Created by Eagle on 10/18/11.
//  Copyright 2011 PEGATRON. All rights reserved.
//

#import "TestProgress.h"
#import "PEGA_ATS_UART/SearchSerialPorts.h"


#define IS_UNIT_CONNECTED 0
#define IS_FIXTURE_CONNECTED 1
#define IS_MIKEY_CONNECTED 2
#define IS_LIGHTERMETER_CONNECTED 3

// 2012.2.20 Desikan 
//      Prox-Cal show ready bug(finished test,before plug out unit,ui show READY,but not PASS/FAIL),
//      get SN from Fonnyzone
extern NSString *const PostDataToMuifaNote;

@interface TestProgress (IADevice_DetectPort)

// 2012-04-19 add description by Winter
// for SFSU
// Used to find out the port type(MOBILE/FIXTURE/MIKEY...).
// Param:
//       NSMutableDictionary    *in_out_dicFlags    : port type status
//       NSString   *in_path        :   path to open port
//       NSArray    *in_arrDevices  :   needed devices
//       PEGA_ATS_UART  *uartObj    :   uart object to open port
// Return:
//      Actions result
-(NSString *)tryPort:(NSMutableDictionary *)in_out_dicFlags serialPath:(NSString *)in_path deviceList:(NSArray *)in_arrDevices uart:(PEGA_ATS_UART *)uartObj;

//2012-04-19 add description by Winter
//for all(SFSU,NFMU,MFMU)
// Used to search and list detected ports.
// Param:
//       NSMutableArray    *aryPorts        : list detected ports
// Return:
//      Actions result
-(void)listSrialPath:(NSMutableArray *)aryPorts;

//2012-04-19 add description by Winter
// For no fixture multi UI, assign ports for each unit. (SerialPort,UartObj,Color,Target)
// Param:
//       NSMutableArray    *in_out_aryPorts    : send out port
//       NSMutableArray    *aryAllProts        : all ports
// Return:
//      Actions result
-(BOOL)forNFMU:(NSMutableArray *)in_out_aryPorts ports:(NSMutableArray *)aryAllProts;

//2012-04-19 add description by Winter
// For single fixture single UI, assigh ports for single unit.(SerialPort,UartObj,Color,Target)
// Param:
//       NSMutableArray    *in_out_aryPorts        : send out port
//       NSMutableArray    *aryAllProts            : all ports
//       aryPorts       : list detected ports
//       in_dicDevice   : needed devices : such as MOBILE,FIXTURE...
// Return:
//      Actions result
-(BOOL)forSFSU:(NSMutableArray *)in_out_aryPorts ports:(NSMutableArray *)aryAllProts;

//2012-04-19 add description by Winter
// For multi fixture multi UI, assigh ports for each unit.(SerialPort,UartObj,Color,Target)
// Param:
//       NSMutableArray    *in_out_aryPorts        : send out port
//       NSMutableArray    *aryAllProts            : all ports
//       aryPorts       : list detected ports
// Return:
//      Actions result
-(BOOL)forMFMU:(NSMutableArray *)in_out_aryPorts ports:(NSMutableArray *)aryAllProts;

//2012-4-16 add note by Sunny
//		Get SerialPorts，dicide use relevant UI through setting file .
// Parameter:
//      NSMutableArray        in_out_aryPorts : send out port
// Return:
//      Actions result
-(BOOL)assignPorts:(NSMutableArray *)in_out_aryPorts;
-(void)monitorSerialPortPlugInWithUartPath:(NSString *)in_szUARTPath withOutputSN:(NSMutableString *) out_szSN;
//2012-4-16 add note by Sunny
//		Check unit plug out.
// Parameter:
//      NSString        in_szUARTPath : serial port path
// Return:
//      the action result
-(void)monitorSerialPortPlugOutWithUartPath:(NSString *)in_szUARTPath;
//2012-4-16 add note by Sunny
//		Check unit connect well with serial port
// Parameter:
//      NSString			in_szUARTPath		: UART Path
//		NSString			in_szCommand		: send command
//		NSMutableString		in_out_szResponse	: receive response
//		NSTimeInterval		inCheckTime			: no use
// Return:
//      the action result
- (BOOL)checkUnitConnectWellWithSerialPort:(NSString *)in_szUARTPath UARTCommand:(NSString *)in_szCommand UartResponse:(NSMutableString *)in_out_szResponse CheckTime:(NSTimeInterval)inCheckTime;
- (NSNumber*)DISORCONNECTUSB:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue;

//2012-4-26 added by Lorky
//		Check the disconnect usb status
// Parameter:
//      NSDictionary    *dicContents        : Settings in script
//      NSMutableString *strReturnValue    : Return value
// Return:
//      the action result
- (NSNumber*)CHECK_USB_CONNECT_STATUS:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue;
//for Prox Cal 
//Add 2012/2/7 by desikan
//2012-4-16 add note by Sunny
//		change current slot and tell op to change slot.
// Parameter:
//      bool        bFailCancle : if not cancle to end
//		double		dTimeLimit	: test time limit
//		NSString	szCurrentSlot	:current slot
//		NSString	szNextSlot	:	next slot
//		NSString	szButtion	:	message box button
//		NSString	szMessage	:	unit plug out message
//		NSString	szMessage2	:	unit plug in message
// Return:
//      the action result
- (NSNumber *)Change_Slot:(NSDictionary *)dicSetting Return_Value:(NSMutableString *)szReturnValue;
//2012/2/15
//add by desikan  used to set KongCable auto enter diags mode
//2012-4-16 add note by Sunny
//		set kong cable auto enter diags mode/
// Parameter:
//      NSMutableArray        arrPorts : serial ports list
// Return:
//      the action result
-(BOOL)Set_KongCable_Auto_diags:(NSMutableArray *)arrPorts;
//2012/2/15
//add by desikan  used to set KongCable auto enter diags mode
//2012-4-16 add note by Sunny
//		set kong cable diags status.
// Parameter:
//      NSString        szToolPath	:	tool path
//		NSString		szBsdPath	:	Uart path
//		NSString		szCurrentAction	:	current action
// Return:
//      the action result
- (NSNumber *)Set_KongCable_diagsStatus:(NSDictionary *)dicPara Return_Value:(NSMutableString *)szReturnValue;
//2012-4-16 add note by Sunny
//		set the "disableOVCheck" status
// Parameter:
//      NSString        szPortType : device target
//		BOOL			bOVCheck	:	if not ov check 
//		NSString		szToolPath	:	tool path
// Return:
//      the action result
- (NSNumber *)DisableOVCheck_Set_Del:(NSDictionary*)dictSettings RETURN_VALUE:(NSMutableString*)szReturnValue;

- (BOOL)checkUnitConnectWellWithFixturePort:(NSString *)in_szUARTPath UARTCommand:(NSString *)in_szCommand UartResponse:(NSMutableString *)in_out_szResponse CheckTime:(NSTimeInterval)inCheckTime;

-(void)monitorSensorStatusInWithUartPath:(NSString *)in_szUARTPath;

-(BOOL)MakeTheTrayIn:(NSString *)in_szUARTPath;

-(NSNumber *)CHECK_FIXTURE_ALIVE:(NSDictionary *)dicSetting RETURN_VALUE:(NSMutableString *)szReturnValue;

@end
