//
//  publicDefine.h
//  FunnyZone
//
//  Created by Lorky on 3/30/11.
//  Copyright 2011 PEGATRON. All rights reserved.
//
typedef  enum DeviceColor
{
	blackDevice = 0,
	whiteDevice = 1,
}_deviceColor; //

//For Pressure Test
#import "publicParams.h"

#pragma mark +++++++++++++++       Noitification Keys        ++++++++++++++++
// TableView Keys
#define kAllTableViewIndex				@"CurrentIndex"
#define kAllTableViewResultImage		@"Image"
#define kAllTableViewSpec				@"Spec"
#define kAllTableViewItemName			@"ItemName"
#define kAllTableViewRetureValue		@"ReturnValue"
#define kAllTableViewCostTime			@"Time"

#define kFunnyZoneCurrentIndex			@"FunnyZoneCurrentIndex"
#define kFunnyZoneSumIndex				@"FunnyZoneSumIndex"
#define kFunnyZoneSingleItemResult		@"FunnyZoneSingleItemResult"
#define kFunnyZoneConsoleMessage		@"FunnyZoneConsoleMessage"
#define kFunnyZoneUartLog				@"FunnyZoneUartLog"
#define kFunnyZoneSubitemInfo			@"FunnyZoneSubItemInfo"

#define kFunnyZoneIdentify				@"Identify"
#define kAllTableView					@"AllTableView"
#define kDebugViewInit					@"DebugViewInit"
#define kDebugViewItemRefresh			@"DebugViewItemRefresh"
#define kDebugViewSubRefresh			@"DebugViewSubRefresh"
#define kUartView                       @"UartView"

#define kDebugViewBreakPoint			@"BreakPoint"
#define kDebugViewStatus				@"Status"
#define kDebugViewItemName				@"TestItemName"
#define kDebugViewSubItemName			@"SubItemName"
#define kDebugViewTestValue				@"ReturnValue"
#define kDebugViewTime					@"Time"
#define kDebugViewFullName				@"FullName"

#pragma mark ++++++++++++++   Range strings / separate string  +++++++++++++++
#define kFunnyZoneColon					@":"
#define kFunnyZoneComma					@","
#define kFunnyZoneBlank					@""
#define kFunnyZoneBlank1				@" "
#define kFunnyZoneDot					@"."
#define kFunnyZoneEnter					@"\n"
#define kFunnyZoneNewLine				@"\r"
#define kFunnyZoneSeparate1				@"\n\r"
#define kFunnyZoneSeparate2				@"\r\n"
#define kFunnyZoneTestItem				@"TestItem"
#define kFunnyZoneJudgeSpecItem			@"JUDGE_SPEC:"
#define kFunnyZoneColon1                @": "
#define kFunnyZoneBlank2                @"  "

//#define kFunnyZoneBlackLimit			@"BlackSpec"
#define kFunnyZoneCurrentItemName       @"CurrentItemName"

#pragma mark ++++++++++++++++         Macros define       +++++++++++++++++
// Following macros' define are the dictionary that transfor from UI to framework.


// Following macros' define are the Keys that in memory buffer.
#define kFZ_AllTableViewDictPostToUI	@"FZ_AllTableViewDictPostToUI"
#define kFZ_DebugTableViewDictPostToUI	@"FZ_DebugTableVeiwDictPostToUI"

// Following macros' define are the Keys of dictionary that include log path
#define kFZ_CSVLogPath					@"FZ_CSVLogPath"
#define kFZ_UARTLogPath					@"FZ_UARTLogPath"
#define kFZ_ConsoleLogPath              @"FZ_ConsoleLogPath"
#define kFZ_GyroLogPath                 @"FZ_GyroLogPath"
#define kFZ_CycleTimeLogPath            @"FZ_CycleTimeLogPath"


#pragma mark ++++++++++++++++         Other defines       +++++++++++++++++
#define kFunnyZoneStatusTest				@"Testing..."
#define kFunnyZoneStatusPass				@"Pass"
#define kFunnyZoneStatusFail				@"Fail"
#define kFunnyZoneStatus					@"Status"
#define kFunnyZoneISN						@"ISN"
#define kFunnyZonePortIndex					@"PortIndex"
#define TEST_SUCCESS                        0
#define TEST_FAIL                           1

// the flag "NoNeedForREL" for the no need items for REL line
#define kScriptFileNoNeedForREL             @"NoNeedForREL"
#define kScriptFileJustForREL               @"JustForREL"


// keys read from NSUserDefaults by Leehua begin
#define kPD_Muifa_Plist                 @"Muifa_Plist"

#define kPD_UserDefaults                [m_dicMemoryValues objectForKey:kPD_Muifa_Plist]

#define kPD_UserDefaults_ALSPath        @"Log_Path",@"ALSPath"
#define kPD_UserDefaults_LogPath        @"Log_Path",@"LogPath"
#define kPD_UserDefaults_SaveBinary     @"Log_Path",@"SaveBinary"
#define kPD_UserDefaults_SaveLog        @"Log_Path",@"SaveLog"
#define kPD_UserDefaults_GroundhogInfo  @"ScriptInfo",@"GroundhogInfo"
#define kPD_UserDefaults_ScriptFileName @"ScriptInfo",@"ScriptFileName"
#define kPD_UserDefaults_SaveCycleTimeLog @"Log_Path",@"SaveCycleTimeLog"

#define kPD_LogPath						[NSString stringWithFormat:@"%@/%@",[self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_LogPath,nil],m_szStartDate]

#define kPD_VirtualSerialPrt            @"VirtualUartPath"
#define kPD_UserDefaults_SerialName     @"ModeSetting",@"CableSerial"
#define kPD_ModeSet_CableName           [self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_SerialName,nil]
#define kPD_UserDefaults_UnitsInfo      @"ModeSetting",@"UnitsPreference"
#define kPD_ModeSet_UnitInfo            [self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_UnitsInfo,nil]
#define kPD_UserDefaults_PutInUse       @"EnableUnit"
#define kPD_UserDefaults_DeviceRequire  @"DeviceRequire"
#define kPD_UserDefaults_EnableDevice	@"EnableDevice"
#define kPD_UserDefaults_PortName       @"PortName"


#define kPD_LogPath_Uart                [self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_UartPath,nil]

#define kPD_UserDefaults_BaudeRate      @"DeviceSetting",szPortType,@"BAUDE_RATE"
#define kPD_UserDefaults_DataBit        @"DeviceSetting",szPortType,@"DATA_BIT"
#define kPD_UserDefaults_Parity         @"DeviceSetting",szPortType,@"PARITY"
#define kPD_UserDefaults_StopBit        @"DeviceSetting",szPortType,@"STOP_BIT"
#define kPD_UserDefaults_Try            @"DeviceSetting",szPortType,@"TRY"
#define kPD_UserDefaults_EndFlag        @"DeviceSetting",szPortType,@"ENDFLAG"
#define kPD_UserDefaults_Expect         @"DeviceSetting",szPortType,@"EXPECT"
#define kPD_UserDefaults_MatchType      @"DeviceSetting",szPortType,@"MATCH_TYPE"
#define kPD_UserDefaults_Type           @"DeviceSetting",szPortType,@"TYPE"
#define kPD_UserDefaults_UartColor      @"DeviceSetting",szPortType,@"UART_COLOR"
//add by jingfu ran on 2012 04 26. For send comand used HEX
#define kPD_UserDefaults_ISHEX			@"DeviceSetting",szPortType,@"HEX"

#define kPD_DeviceSet_BaudeRate         [self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_BaudeRate,nil]
#define kPD_DeviceSet_DataBit           [self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_DataBit,nil]
#define kPD_DeviceSet_Parity            [self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_Parity,nil]
#define kPD_DeviceSet_StopBit           [self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_StopBit,nil]
#define kPD_DeviceSet_Try               [self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_Try,nil]
#define kPD_DeviceSet_EndFlag           [self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_EndFlag,nil]
#define kPD_DeviceSet_Expect            [self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_Expect,nil]
#define kPD_DeviceSet_MatchType         [self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_MatchType,nil]
#define kPD_DeviceSet_Type              [self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_Type,nil]
#define kPD_DeviceSet_UartColor         [self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_UartColor,nil]
//add by jingfu ran on 2012 04 26. For send comand used HEX
#define kPD_DeviceSet_Hex				[self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_ISHEX,nil]

#define kPD_DeviceSet_Type_String       0
// keys read from NSUserDefaults by Leehua end

//define public key begin
#define kPD_Device_MOBILE               @"MOBILE"
#define kPD_Device_FIXTURE              @"FIXTURE"
#define kPD_Device_LIGHTMETER           @"LIGHTMETER"
//define public key end

// variables
#define kPD_Notification_Time           @"TIME"
#define kPD_AMIOK_PanelColor            @"PanelColor"
#define kPD_Device_BSDPATH              @"BSDPATH"

//add by jingfu ran on 2012 04 23
#pragma mark +++++++++++++++       UserDefineVabrile        ++++++++++++++++
#define kFunnyZoneHasSubItemParameterData           @"HasSubParameterdata"
#define kFunnyZoneNOWriteCsvToLogFile               @"NOWRITETOCSV"
#define kFunnyZoneShowCoFONUI                       @"NOSHOWUI"

#ifndef kMuifaPlistPath
#define kMuifaPlistPath                         [NSString stringWithFormat:@"%@/Library/Preferences/ATS_Muifa.plist", NSHomeDirectory()]
#define kFZ_UserDefaults                        [NSDictionary dictionaryWithContentsOfFile:kMuifaPlistPath]
#endif

#define	kIASaveLogs	[[[kFZ_UserDefaults objectForKey:@"Log_Path"] objectForKey:@"SaveLog"] boolValue]
