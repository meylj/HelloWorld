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


#pragma mark +++++++++++++++       Noitification Keys        ++++++++++++++++
// TableView Keys
#define kAllTableViewIndex				@"CurrentIndex"
#define kAllTableViewResultImage		@"Image"
#define kAllTableViewSpec				@"Spec"
#define kAllTableViewItemName			@"ItemName"
#define kAllTableViewRetureValue		@"ReturnValue"
#define kAllTableViewCostTime			@"Time"
#define kAllTableViewDisplayMode        @"DisplayMode"

#define kFunnyZoneCurrentIndex			@"FunnyZoneCurrentIndex"
#define kFunnyZoneSumIndex				@"FunnyZoneSumIndex"
#define kFunnyZoneSingleItemResult		@"FunnyZoneSingleItemResult"
#define kFunnyZoneConsoleMessage		@"FunnyZoneConsoleMessage"

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

// for Tableview drawer
#define kDrawerViewFailName				@"LCDFAILITEMS"
#define kDrawerViewOV                   @"OV"


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



// keys read from NSUserDefaults by Leehua begin
#define kPD_Muifa_Plist                 @"Muifa_Plist"

#define kPD_UserDefaults                [m_dicMemoryValues objectForKey:kPD_Muifa_Plist]

#define kPD_UserDefaults_ChangeVersion  [[self getValueFromXML:kPD_UserDefaults mainKey:@"ChangeVer",nil] boolValue]
#define kPD_UserDefaults_NoPudding      [[self getValueFromXML:kPD_UserDefaults mainKey:@"NoPudding",nil] boolValue]
#define kPD_UserDefaults_NoProcessLog   [[self getValueFromXML:kPD_UserDefaults mainKey:@"NoUploadProcessLogForGoodTest",nil] boolValue]
#define kPD_UserDefaults_NoParametricData      [[self getValueFromXML:kPD_UserDefaults mainKey:@"NoParametricData",nil] boolValue]


#define kPD_UserDefaults_ALSPath        @"Log_Path",@"ALSPath"
#define kPD_UserDefaults_ConsolePath    @"Log_Path",@"ConsolePath"
#define kPD_UserDefaults_csvPath        @"Log_Path",@"csvPath"
#define kPD_UserDefaults_UartPath       @"Log_Path",@"UartPath"
#define kPD_UserDefaults_CycleTimePath  @"Log_Path",@"CycleTimePath"
#define kPD_UserDefaults_SaveBinary     @"Log_Path",@"SaveBinary"
#define kPD_UserDefaults_SaveLog        @"Log_Path",@"SaveLog"
#define kPD_UserDefaults_GroundhogInfo  @"ScriptInfo",@"GroundhogInfo"
#define kPD_UserDefaults_ScriptFileName @"ScriptInfo",@"ScriptFileName"
#define kPD_UserDefaults_NoCycleTimeLog @"Log_Path",@"NoCycleTimeLog"

// Do not write log
#define kPD_UserDefaults_NoNeedDebug      @"Log_Path",@"NoNeedDebug"
#define kPD_UserDefaults_NoNeedCSV        @"Log_Path",@"NoNeedCSV"
#define kPD_UserDefaults_NoNeedUart       @"Log_Path",@"NoNeedUart"
#define kPD_UserDefaults_NoNeedConsole    @"Log_Path",@"NoNeedConsole"

#define kPD_LogPath_ALS                 [self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_ALSPath,nil]
#define kPD_LogPath_Console             [self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_ConsolePath,nil]
#define kPD_LogPath_CSV                 [self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_csvPath,nil]
#define kPD_LogPath_Uart                [self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_UartPath,nil]
#define kPD_LogPath_CycleTime           [self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_CycleTimePath,nil]

#define kPD_Mode_SFSU                   @"SFSU"
#define kPD_Mode_NFMU                   @"NFMU"
#define kPD_Mode_MFMU                   @"MFMU"

#define kPD_UserDefaults_CurrentMode    @"ModeSetting",@"CurrentMode",@"DefaultUIMode"
#define kPD_UserDefaults_SerialName     @"ModeSetting",@"CableSerial"
#define kPD_UserDefaults_IS_1_to_N      @"ModeSetting",@"IS_1_to_N",nil
#define kPD_UserDefaults_MonitorFixtureCommand      @"ModeSetting",@"MonitorFixtureCommand",nil
#define kPD_ModeSet_Mode                [self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_CurrentMode,nil]
#define kPD_ModeSet_CableName           [self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_SerialName,nil]
#define kPD_UserDefaults_UnitsInfo      @"ModeSetting",kPD_ModeSet_Mode
#define kPD_ModeSet_UnitInfo            [self getValueFromXML:kPD_UserDefaults mainKey:kPD_UserDefaults_UnitsInfo,nil]
#define kPD_UserDefaults_PutInUse               @"PutUnitInUse"
#define kPD_UserDefaults_DeviceRequire          @"DeviceRequire"
#define kPD_UserDefaults_NoNeed                 @"NoNeed"
#define kPD_UserDefaults_NoResponseCancelCount  @"NoResponseCancelCount"
#define kPD_UserDefaults_PortName               @"PortName"
#define kPD_UserDefaults_CheckPortNameForSFSU   @"ModeSetting",@"CheckPortNameForSFSU"


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

//groundhog file key(saved in m_dicMemoryValues)
#pragma mark +++++++++++   Groundhog parser file keys define   ++++++++++++++++
//#define kPD_GroundhogKey_StationType	[self getValueFromXML:kPD_UserDefaults mainKey:@"STATION_INFO",@"STATION_TYPE",nil]
//#define kPD_GroundhogKey_SfcUrl			[self getValueFromXML:kPD_UserDefaults mainKey:@"STATION_INFO",@"SFC_URL",nil]
//#define kPD_GroundhogKey_StationId		[self getValueFromXML:kPD_UserDefaults mainKey:@"STATION_INFO",@"STATION_ID",nil]
//#define kPD_GroundhogKey_SfcTimeOut     [self getValueFromXML:kPD_UserDefaults mainKey:@"STATION_INFO",@"SFC_TIMEOUT",nil]
//#define kPD_GHInfo_SfcTimeOut           @"5"
#define kPD_GHInfo_SITE                 [NSString stringWithFormat:@"GHIF_%d",IP_SITE]
#define kPD_GHInfo_PRODUCT              [NSString stringWithFormat:@"GHIF_%d",IP_PRODUCT]
#define kPD_GHInfo_BUILD_STAGE          [NSString stringWithFormat:@"GHIF_%d",IP_BUILD_STAGE]
#define kPD_GHInfo_BUILD_SUBSTAGE       [NSString stringWithFormat:@"GHIF_%d",IP_BUILD_SUBSTAGE]
#define kPD_GHInfo_REMOTE_ADDR          [NSString stringWithFormat:@"GHIF_%d",IP_REMOTE_ADDR]
#define kPD_GHInfo_LOCATION             [NSString stringWithFormat:@"GHIF_%d",IP_LOCATION]
#define kPD_GHInfo_LINE_NUMBER          [NSString stringWithFormat:@"GHIF_%d",IP_LINE_NUMBER]
#define kPD_GHInfo_STATION_NUMBER       [NSString stringWithFormat:@"GHIF_%d",IP_STATION_NUMBER]
#define kPD_GHInfo_STATION_TYPE         [NSString stringWithFormat:@"GHIF_%d",IP_STATION_TYPE]
#define kPD_GHInfo_SCREEN_COLOR         [NSString stringWithFormat:@"GHIF_%d",IP_SCREEN_COLOR]
#define kPD_GHInfo_STATION_IP           [NSString stringWithFormat:@"GHIF_%d",IP_STATION_IP]
#define kPD_GHInfo_DCS_IP               [NSString stringWithFormat:@"GHIF_%d",IP_DCS_IP]
#define kPD_GHInfo_PDCA_IP              [NSString stringWithFormat:@"GHIF_%d",IP_PDCA_IP]
#define kPD_GHInfo_KOMODO_IP            [NSString stringWithFormat:@"GHIF_%d",IP_KOMODO_IP]
#define kPD_GHInfo_SPIDERCAB_IP         [NSString stringWithFormat:@"GHIF_%d",IP_SPIDERCAB_IP]
#define kPD_GHInfo_FUSING_IP            [NSString stringWithFormat:@"GHIF_%d",IP_FUSING_IP]
#define kPD_GHInfo_DROPBOX_IP           [NSString stringWithFormat:@"GHIF_%d",IP_DROPBOX_IP]
#define kPD_GHInfo_SFC_IP               [NSString stringWithFormat:@"GHIF_%d",IP_SFC_IP]
#define kPD_GHInfo_SFC_URL              [NSString stringWithFormat:@"GHIF_%d",IP_SFC_URL]
#define kPD_GHInfo_PROV_IP              [NSString stringWithFormat:@"GHIF_%d",IP_PROV_IP]
#define kPD_GHInfo_DATE_TIME            [NSString stringWithFormat:@"GHIF_%d",IP_DATE_TIME]
#define kPD_GHInfo_STATION_ID           [NSString stringWithFormat:@"GHIF_%d",IP_STATION_ID]
#define kPD_GHInfo_GROUNDHOG_IP         [NSString stringWithFormat:@"GHIF_%d",IP_GROUNDHOG_IP]
#define kPD_GHInfo_MAC                  [NSString stringWithFormat:@"GHIF_%d",IP_MAC]
#define kPD_GHInfo_SAVE_BRICKS          [NSString stringWithFormat:@"GHIF_%d",IP_SAVE_BRICKS]
#define kPD_GHInfo_LOCAL_CSV            [NSString stringWithFormat:@"GHIF_%d",IP_LOCAL_CSV]
#define kPD_GHInfo_REALTIME_PARAMETRIC  [NSString stringWithFormat:@"GHIF_%d",IP_REALTIME_PARAMETRIC]
#define kPD_GHInfo_SINGLE_CSV_UUT       [NSString stringWithFormat:@"GHIF_%d",IP_SINGLE_CSV_UUT]
#define kPD_GHInfo_STATION_DISPLAY_NAME [NSString stringWithFormat:@"GHIF_%d",IP_STATION_DISPLAY_NAME]
#define kPD_GHInfo_URI_CONFIG_PATH      [NSString stringWithFormat:@"GHIF_%d",IP_URI_CONFIG_PATH]
#define kPD_GHInfo_SFC_QUERY_UNIT_ON_OFF        [NSString stringWithFormat:@"GHIF_%d",IP_SFC_QUERY_UNIT_ON_OFF]
#define kPD_GHInfo_SFC_TIMEOUT                  [NSString stringWithFormat:@"GHIF_%d",IP_SFC_TIMEOUT]
#define kPD_GHInfo_GHSI_LASTUPDATE_TIMEOUT      [NSString stringWithFormat:@"GHIF_%d",IP_GHSI_LASTUPDATE_TIMEOUT]
#define kPD_GHInfo_FERRET_NOT_RUNNING_TIMEOUT   [NSString stringWithFormat:@"GHIF_%d",IP_FERRET_NOT_RUNNING_TIMEOUT]
#define kPD_GHInfo_NETWORK_NOT_OK_TIMEOUT       [NSString stringWithFormat:@"GHIF_%d",IP_NETWORK_NOT_OK_TIMEOUT]
#define kPD_GHInfo_STATION_SET_CONTROL_BIT_ON_OFF   [NSString stringWithFormat:@"GHIF_%d",IP_STATION_SET_CONTROL_BIT_ON_OFF]
#define kPD_GHInfo_CONTROL_BITS_TO_CHECK_ON_OFF     [NSString stringWithFormat:@"GHIF_%d",IP_CONTROL_BITS_TO_CHECK_ON_OFF]
#define kPD_GHInfo_CONTROL_BITS_TO_CLEAR_ON_PASS_ON_OFF [NSString stringWithFormat:@"GHIF_%d",IP_CONTROL_BITS_TO_CLEAR_ON_PASS_ON_OFF]
#define kPD_GHInfo_CONTROL_BITS_TO_CLEAR_ON_FAIL_ON_OFF [NSString stringWithFormat:@"GHIF_%d",IP_CONTROL_BITS_TO_CLEAR_ON_FAIL_ON_OFF]
#define kPD_GHInfo_ACTIVATION_IP                        [NSString stringWithFormat:@"GHIF_%d",IP_ACTIVATION_IP]
//IP_GHSTATIONINFO_COUNT

//add by jingfu ran on 2012 04 23
#pragma mark +++++++++++++++       UserDefineVabrile        ++++++++++++++++
#define kFunnyZoneHasSubItemParameterData           @"HasSubParameterdata"
#define kFunnyZoneNOWriteCsvToLogFile               @"NOWRITETOCSV"
#define kFunnyZoneShowCoFONUI                       @"SHOWUI"

