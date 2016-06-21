//
//  IADevice_Define.h
//  Izual_Lu
//
//  Created by Lu Izual on 11-4-20.
//  Copyright 2011�?PEGATRON. All rights reserved.
//

// kyle 2011.11.11  
// copy struct from maggic 
typedef	struct _SELECTRECT{
	int startRow;
	int startColumn;
	int endRow;
	int endColumn;
} SelectRect;

// we can not upload -99999.99999, it may mess up the PDCA map format, so we upload NA instead
#define kFZ_99999_Value_Issue           @"NA"

// current memory key
#define kFZ_GetPullShortI               @"GetPullShortI"
#define kFZ_WCDMA_COMMAND               @"WCDMA_COMMAND"
#define kFZ_FirstBit                    @"FirstBit"
#define kFZ_SecondBit                   @"SecondBit"
#define kFZ_ThirdBit                    @"ThirdBit"
#define kFZ_ZeroBit                     @"ZeroBit"
#define kFZ_MOBILE_PortType             @"MOBILE"

//modify by leehua
#define kFZ_MultiStatus_None            0
#define kFZ_MultiStatus_Run             1
#define kFZ_MultiStatus_Finish          2

//color for filling uart tableview
#define kFZ_UartTableview_WHITE           @"WHITE"
#define kFZ_UartTableview_RED             @"RED"
#define kFZ_UartTableview_GREEN           @"GREEN"
#define kFZ_UartTableview_BLUE            @"BLUE"
#define kFZ_UartTableview_YELLOW          @"YELLOW"
#define kFZ_UartTableview_ORANGE          @"ORANGE"

//define serial object sequence in array
#define kFZ_SerialInfo_SerialPort       0
#define kFZ_SerialInfo_UartObj          1
#define kFZ_SerialInfo_UartTablVColor   2

// Script file
#define kFZ_Script_LoopItem				@"LoopItem"
#define kFZ_Script_LoopStart            @"LoopStart"
#define kFZ_Script_LoopEnd				@"LoopEnd"
#define kFZ_Script_LoopRepeatTime		@"LoopRepeatTime"
#define kFZ_Script_MainName             @"TestName"
#define kFZ_TestItem_MainName           @"MainName"

// End Flag
#define kFZ_EndFlagFormat				[NSString stringWithFormat:@"%@ :-)",[m_dicMemoryValues objectForKey:@"LORKY_DEVICE_ECID"]]


// cancel Items
#define kFZ_Script_CancelItems          @"CancelItems"
#define kFZ_Script_CancelCount          @"CancelCount"
#define kFZ_Script_CancelFlag           @"OUTOFSPEC_CANCEL"

#define kFZ_Script_DeviceTarget         @"TARGET"

// Sent command
#define kFZ_Script_CommandString        @"STRING"
#define kFZ_Script_CommandHexString     @"HEXSTRING"
#define kFZ_Script_WithoutUart          @"NUART"
#define KFZ_Script_WithoutUartLog       @"NOUARTLOG"
#define kFZ_Script_CommandByte          @"BYTE"
#define kFZ_Script_CommandData          @"DATA"
// Receive command
#define kFZ_Script_ReceiveTimeOut       @"TIMEOUT"
#define kFZ_Script_ReceiveInterval      @"INTERVAL"
#define kFZ_Script_ReceiveRepeat        @"REPEAT"
#define kFZ_Script_ReceiveFail          @"FAIL_RECEIVE"
#define kFZ_Script_ReceivePass          @"PASS_RECEIVE"
#define kFZ_Script_ReceiveEndSymbols    @"END_SYMBOL"
// delete \n\r Leehua 2011/07/25
#define kFZ_Script_ReceiveDeleteEnter   @"DELETE_ENTER"
#define kFZ_Script_ReceiveMatchType     @"MATCHTYPE"
// for write control bit pass Leehua 2011/07/26
#define kFZ_Script_ReceiveReturnData    @"RETURN_DATA"
// Catch value
#define kFZ_Script_ReceiveBegin         @"BEGIN"
#define kFZ_Script_ReceiveEnd           @"END"
#define kFZ_Script_ReceiveCatch         @"CATCH_KEY"
#define kFZ_Script_CatchLocation        @"LOCATION"
#define kFZ_Script_CatchLength          @"LENGTH"
#define kFZ_MemKey_ReadCatch            @"READ_CATCH"
#define kFZ_MemKey_ForMobileCatch       @"MOBILE_CATCH"
#define kFZ_MemKey_ForFixtureCatch      @"FIXTURE_CATCH"
#define kFZ_MemKey_ForLTMeterCatch      @"LTMETER_CATCH"

// Judge spec
#define kFZ_Script_JudgeSpec            @"SPEC"
#define kFZ_Script_JudgeMode            @"NoCaseInsensitive"
#define kFZ_Script_JudgeCBSpec          @"CB_SPEC"
#define kFZ_Script_JudgeCommonSpec      @"COMMON_SPEC"
#define kFZ_Script_JudgeCOCOPASSSpec    @"COCOPASS_SPEC"
#define kFZ_Script_JudgeCofSpec         @"COCO_SPEC"
#define kFZ_Script_StatusOnUI           @"STATUS_ON_UI"


//2012 7 16 torres add for MagnetSpine exception spec
#define kFZ_Script_JudgeExceptionSpec   @"EXCEPTION_SPEC"
#define kFZ_Script_JudgeMaxAppearCount  @"MaxAppear"

#define kFZ_Script_JudgeCommonBlack		@"P_LimitBlack"
#define kFZ_Script_JudgeCommonWhite		@"P_LimitWhite"
#define kFZ_Script_JudgeCommonP106		@"P_LimitP106"
#define kFZ_Script_JudgeCommonP107		@"P_LimitP107"
#define kFZ_Script_JudgeCBStatus        @"P_LimitCB_US"
#define kFZ_Script_JudgeCBFailCount     @"P_LimitCB_FC"
#define KFZ_Script_JudgeNandSizeSpec    @"NAND_SIZE_SPEC"
#define kFZ_Script_TestResult           @"TestResult"
// Memory value for key
#define kFZ_Script_MemoryKey            @"KEY"

//get value from memory key
#define kFZ_Script_CBWtnTime            @"CB_WRITTEN_TIME"

// Upload attribute
#define kFZ_Script_UploadAttribute      @"ATTRIBUTE"
#define kFZ_Script_UploadParametric     @"PARAMETRIC"
#define kFZ_Script_ParamLowLimit        @"LOWLMT"
#define kFZ_SCript_ParamHighLimit       @"HIGHLMT"
#define kFZ_Script_ParamUnit            @"UNIT"

// Wait_Ms
#define kFZ_Script_WaitMS               @"TIME"

//set result on screen
#define kUserDefaultSingleOrMulti       @"SINGLE/MULTI"
#define kUserNeedShowSecondPassLogo     @"SHOWSECONDPASSLOGO"

// other variables
#define kFZ_UI_SHOWNVALUE               @"UI_SHOWNVALUE"
#define kFZ_UI_SHOWNNAME                @"UI_SHOWNNAME"
#define kFZ_TestResult                  @"TEST_RESULT"          
#define kFZ_TestLimit                   @"TestLimit"
#define kFZ_TestLimit_KBB               @"TestLimit_KBB"
#define kFZ_EraseStationID              @"EraseStationID"#define kFZ_Cof_TestLimit               @"Cof_TestLimit"
#define kFZ_MP_TestLimit                @"MP_TestLimit"
#define kFZ_SingleTime                  @"SingleTime"
#define kFZ_StationId                   @"StationId"
#define kFZ_NowTime                     @"NowTime"
#define kFZ_SoftVersion                 @"SoftVersion"
#define kFZ_SetCBFlag                   @"SetCBFlag"

//define for pattern receive note from Funnyzone
#define kFZ_Pattern_ReceiveVolDnMsg     0
#define kFZ_Pattern_ReceiveMsg          1
#define kFZ_Pattern_NoMsg               2

#pragma mark ############################## Leehua definition (CB relative)##############################
#define kFZ_TestFail                        @"fail"
#define kFZ_TestPass                        @"pass"

#define kFZ_IPAD1_ID                    @"0x03"
#define kFZ_GROUNDING_ID                @"0xC9"
#define kFZ_QT0_ID                      @"0x80"
#define kFZ_QT0b_ID                     @"0x81"
#define kFZ_CONNECTIVITY_ID             @"0x83"
#define kFZ_QT1_ID                      @"0x82"
#define kFZ_PROXCAL_ID                  @"0xBD"
#define kFZ_MAGNET_COVER_ID             @"0x9C"
#define kFZ_MAGNET_SPINE_ID             @"0x9D"
#define KFZ_GRAPE_OFFSET_ID             @"0x91"  //jeff
//modified by jingfu ran on 2012 05 02 change from 0x9B from 0x9E t 0x9B
#define kFZ_HALL_EFFECT_ID              @"0x9B"
//end by jingfu ran on 2012 05 02
#define kFZ_CONNECTIVITY2_ID            @"0x84"    //12.7.26 Add by betty_xie for writting CT2 CB

#define kFZ_PanelTitle_Error            [NSString stringWithFormat:@"错误(Error) (Slot:%@)",m_szPortIndex]
#define kFZ_PanelTitle_IPError          [NSString stringWithFormat:@"Pudding Error (Slot:%@)",m_szPortIndex]
#define kFZ_PanelTitle_Warning          [NSString stringWithFormat:@"警告(Warning) (Slot:%@)",m_szPortIndex]
#define kFZ_PanelTitle_SFISError        [NSString stringWithFormat:@"SFIS Response Error (Slot:%@)",m_szPortIndex]
#define kFZ_CheckCB_SN                   @"CheckCB_SN"
// for InstantPudding
#define kFZ_InstantPudding_Success                            0
#define kIADevice_InstantPudding_Fail_MakeZIP                       1
#define kIADevice_InstantPudding_Fail_InsetBlob                     2
#define kIADevice_InstantPudding_Fail_AddAttribute                  3
#define kIADevice_InstantPudding_Fail_AddAttributeExtra             4
#define kIADevice_InstantPudding_Fail_JudgeSpec                     5
#define kIADevice_InstantPudding_Fail_AddBlob                       6
#define kIADevice_InstantPudding_Fail_GetVersion                    7

#pragma mark ############################## Notification Key ##############################
#define kIADeviceNotificationTX         @"Info"
#define kIADeviceNotificationRX         @"Info"



#pragma mark ############################## Device Key ##############################
#define kIADeviceDevicePort             @"PORT"
#define kIADeviceDeviceCount            @"COUNT"
#define kIADeviceDeviceBSDDefault       @"usbserial"
#define kIADeviceDeviceSN               @"sn"
#define kIADeviceDeviceColor            @"UnitColor"
#define kIADeviceSNBegin                @"Serial:"
#define kIADeviceLCMColor               @"LCMCOLOR"
#define kIADeviceSysCfgKey              @"CFGKEY"
#define KIADeviceDUT_COLOR              @"DUT_COLOR"
#define KIADeviceDUT_WHITECOLOR         @"WHITE"
#define KIADeviceDUT_BLACKCOLOR         @"BLACK"



#pragma mark ############################## Port Key ##############################
#define kIADevicePortColor				@"PORTCOLOR"
#define kIADevicePortSpeed              @"SPEED"
#define kIADevicePortDataBits           @"DATABITS"
#define kIADevicePortParity             @"PARITY"
#define kIADevicePortStopBits           @"STOPBITS"

#define kIADevicePortEndFlag            @"ENDFLAG"
#define kIADevicePortStopChar           @"STOPCHAR"
#define kIADevicePortByteInterval       @"BYTEINTERVAL"
#define kIADevicePortEncoding           @"ENCODING"
#define kIADevicePortEncodingASCII      @"ASCII"
#define kIADevicePortEncodingNEXTSTEP   @"NEXTSTEP"
#define kIADevicePortEncodingUNICODE    @"UNICODE"
#define kIADevicePortEncodingUTF8       @"UTF8"
#define kIADevicePortEncodingUTF16      @"UTF16"
#define kIADevicePortEncodingUTF32      @"UTF32"
#define kIADevicePortRTS                @"RTS"
#define kIADevicePortDTR                @"DTR"
#define kIADevicePortCTS                @"CTS"
#define kIADevicePortDSR                @"DSR"
#define kIADevicePortCAR                @"CAR"
#define kIADevicePortHangUpOnClose      @"HANGUPONCLOSE"
#define kIADevicePortLocalMode          @"LOCALMODE"
#define kIADevicePortCanonicalMode      @"CANONICALMODE"
#define kIADevicePortTry                @"TRY"
#define kIADevicePortExpect             @"EXPECT"



#pragma mark ############################## Command Key ##############################
// Read command
#define kIADeviceCommandLength          @"LENGTH"

#define KIADeviceCommand_DefaultItmeOut 3



#pragma mark ############################## SFIS Key ##############################
// Base keys
#define kIADeviceSFISItems                  @"ITEMS"
#define kIADeviceSFISMode                   @"MODE"
#define kIADeviceSFISURL                    @"URL"
#define kIADeviceSFISCommandQuery           @"QUERY_RECORD"
#define kIADeviceSFISCommandInsert          @"ADD_RECORD"
#define kIADeviceSFISSN                     @"SN"
#define kIADeviceSFISStationID              @"STATIONID"
#define kIADeviceSFISStationName            @"STATIONNAME"
#define kIADeviceSFISStartTime              @"STARTTIME"
#define kIADeviceSFISStopTime               @"STOPTIME"
#define kIADeviceSFISProduct                @"PRODUCT"
#define kIADeviceSFISOS                     @"OS"
#define kIADeviceSFISMACAddress             @"MACADDRESS"
#define kIADeviceSFISECID                   @"ECID"
#define kIADeviceSFISUDID                   @"UDID"
#define kIADeviceSFISFailList               @"FAILLIST"
#define kIADeviceSFISFailure                @"FAILURE"
#define kIADeviceSFISTimeOut                @"TIMEOUT"
// SFIS items query
#define kIADeviceSFISQueryAll               @"ALL"
#define kIADeviceSFISQueryConfig            @"Config"
#define kIADeviceSFISQueryBom               @"Bom"
#define kIADeviceSFISQueryNandSize          @"Nand_size"
#define kIADeviceSFISQueryColor             @"Color"
#define kIADeviceSFISQueryVendorID          @"vendor_id"
#define kIADeviceSFISQueryProxID            @"proxy_id"
#define kIADeviceSFISQueryMPN               @"mpn"
#define kIADeviceSFISQueryRegionCode        @"region_code"

#define kIADeviceSFISQueryBandSN            @"BandSN"
#define kIADeviceSFISQueryBandColor         @"band_color"
#define kIADeviceSFISQueryMLBSN             @"mlbsn"
#define kIADeviceSFISQueryDeviceID          @"device_id"
//For compare SFIS with UI
#define KIADeviceSFISQueryItems             @"QueryItems"
#define KIADeviceSFISQuerySNKey             @"QuerySNKey"
#define KIADeviceSFISUIItem                 @"UIItems"
#define KIADeviceUILastItem                 @"LastItem"
#define KIADeviceUILength                   @"Length"
#define KIADeviceUILocation                 @"Location"

// SFIS insert key
#define kIADeviceSFISInsertProduct          @"product"
#define kIADeviceSFISInsertStationID        @"station_id"
#define kIADeviceSFISInsertStationName      @"test_station_name"
#define kIADeviceSFISInsertStartTime        @"start_time"
#define kIADeviceSFISInsertStopTime         @"stop_time"
#define kIADeviceSFISInsertOSBundleVersion  @"os_bundle_version"
#define kIADeviceSFISInsertMacAddress       @"mac_address"
#define kIADeviceSFISInsertECID             @"ecid"
#define kIADeviceSFISInsertUDID             @"udid"
#define kIADeviceSFISInsertFailTests        @"list_of_failing_tests"
#define kIADeviceSFISInsertFailureMessage   @"failure_message"
#define kIADeviceSFISInsertResult           @"result"
// For judge and link
#define kIADeviceSFISURLCommand             @"command"
#define kIADeviceSFISURLSN                  @"sn"
#define kIADeviceSFISURLLink                @"?"
#define kIADeviceSFISItemLink               @"&"
#define kIADeviceSFISQueryItemLink          @"%20"
#define kIADeviceSFISValueLink              @"="
#define kIADeviceSFISValueSeparate1         [NSString stringWithFormat:@"%c",127]
#define kIADeviceSFISValueSeparate2         @","
#define kIADeviceSFISValueSeparate3         @"\n"
#define kIADeviceSFISValueBeginAt           @"(TSP_GETVERSION)"
#define kIADeviceSFISQueryOK                @"SFC_OK"
#define kIADeviceSFISQueryNormalCount       14
#define kIADeviceSFISInsertOK               @"Insert OK"



#pragma mark ############################## ALS Key ##############################
#define kIADeviceALSDataSource              @"SOURCE"
#define kIADeviceALSFileLocation            @"LOCATION"
#define kIADeviceALSFileLocationKey         @"ALS"
#define kIADeviceALSFileSNKey               @"SN"
#define kIADeviceALSFileNameLink            @"_"
#define kIADeviceALSFileNameDate            [[NSDate date] descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M:%S.%F" timeZone:nil locale:nil]
#define KIADeviceALS_REDRATIO               @"ALS_REDRATIO"
#define KIADeviceALS_GREENRATIO             @"ALS_GREENRATIO"
#define KIADeviceALS_BLUERATIO              @"ALS_BLUERATIO"
#define KIADeviceALS_JUDGEVALUE             @"ALS_JUDGEVALUE"
#define KIADeviceALS_FIRSTABOVE1200         @"ALS_FIRSTABOVE1200"
#define KIADeviceALS_FIRSTBELOW1200         @"ALS_FIRSTBELOW1200"
#define KIADeviceALS_SECONDABOVE1200        @"ALS_SECONDABOVE1200"
#define KIADeviceALS_SECONDBELOW1200        @"ALS_SECONDBELOW1200"
#define KIADeviceALS_TOTALNUMBER            @"ALS_TOTALNUMBER"
#define KIADeviceALS_DATA                   @"ALS_DATA"
#define KIADeviceALS_FIRSTBELOW1200         @"ALS_FIRSTBELOW1200"
#define KIADeviceALS_PROX                   0
#define KIADeviceALS_RED                    1
#define KIADeviceALS_GREEN                  2
#define KIADeviceALS_BLUE                   3
#define KIADeviceALS_CLEAR                  4
#define KIADeviceALS_CLEAR_CHANNEL          @"ALS_Clear_Channnel"
#define KIADeviceALS_IR_CHANNEL             @"ALS_IR_Channnel"


#pragma mark ############################## User Settings Key ##############################
#define kUserDefaultDeviceProperty			@"Device_Proporty"
#define kUserDefaultDeviceCount				@"COUNT"
#define kUserDefaultDeviceMobile			@"Mobile"

#define kUserDefaultLogPath					@"Log_Path"
#define kUserDefaultSaveLog					@"Saved log"
#define kUserDefaultCSVLogPath				@"csv"
#define kUserDefaultConsolLogPath			@"Console"
#define kUserDefaultUartLogPath				@"Uart"
#define kUserDefaultSaveBinary				@"SaveBinary"
#define kUserDefaultProxLogPath				@"PROX"
#define kUserDefaultALSLogPath				@"ALS"
#define kUserDefaultGyroLogPath				@"GYRO"
#define kUserDefaultProvisionLogPath		@"Provisioning"

#define kUserDefaultScriptInfo				@"ScriptInfo"
#define kUserDefaultGroundhogInfoPath		@"GroundhogInfo"
#define kUserDefaultScriptFileName			@"ScriptFileName"
#define kUserDefaultTestOnceScriptName		@"TestOnceScriptName"
//added by lucy for test once or not once
#define KUserDefaultTestPlistFile           @"PlistFile"
#define KUserDefaultTestIsTestOnce          @"IsTestOnce"

#define kUserDefaultToolMenuItemSetting     @"ToolMenuItemSetting"

#define kUserDefaultISN						@"ISN"
#define kUserDefaultMLBSN                   @"MLBSN"
#define kUserDefaultGrapeSN					@"GrapeSN"
#define kUserDefaultLCMSN					@"LCMSN"
#define kUserDefaultNeedSN					@"Need ISN"
#define kUserDefaultNeedJudgeSn				@"Need Judge Rule"
#define kUserDefaultShowTitle				@"Show title on UI"
#define kUserDefaultShowDebugSN             @"Show Debug SN on UI"

#define kUserDefaultTestMode				@"Test_Mode"
#define kUserDefaultDebugOrMP				@"Debug/MP"
#define kUserDefaultDebugMode				@"DEBUG"
#define kUserDefaultMPMode					@"MP"
#define	kUserDefaultSingleMode				@"SINGLE"
#define	kUserDefaultMultiMode				@"MULTI"

#define kUserDefaultCounter					@"Counter&Cycle_Setting"
#define kUserDefaultCycleTestTime			@"Cycle Counter"
#define kUserDefaultHaveRunCount			@"Total Counter"
#define kUserDefaultPassCount				@"Pass Counter"
#define kUserDefaultFailCount				@"Fail Counter"
#define kUserDefaultPuddingNeed				@"Pudding"

#pragma mark ############################## Key Transform ##############################
#define kIADeviceKey                        @"KEY"
#define kIADeviceKeyBegin                   @"/*"
#define kIADeviceKeyEnd                     @"*/"
#define KIADeviceKey_ABS                    @"ABS"
#define KIADeviceKey_MULTIPLE               @"MULTIPLE"
#define KIADeviceKey_TYPE                   @"TYPE"
#define KIADeviceKey_TYPE_INT               @"int"
#define KIADeviceKey_TYPE_DOUBLE            @"double"
#define KIADeviceKey_COMPARE_MIN            @"MIN"

#pragma mark ############################## IADevice_Compass.m ##############################
#define KIADeviceKey_LEDRESULT              @"LEDRESULT"
#define KIADeviceKey_SENSITIVITY            @"SENSITIVITY"
#define KIADeviceKey_NORMAL                 @"NORMAL"
#define KIADeviceKey_SPECIAL                @"SPECIAL"
#define KIADeviceKey_COMPASS_FIELD          @"COMPASS_FIELD"
#define KIADeviceKey_AXIS                   @"AXIS"
#define KIADeviceKey_NMS                    @"NMS"
#define kIADeviceKey_NMS_M									@"NMS_M"
#define KIADeviceKey_NORTH_M                @"AA_M"
#define KIADeviceKey_SOUTH_M                @"BA_M"

#pragma mark ############################## IADevice_TestingCommands.m ##############################
#define kIADevice_TestingCommands_TIMEOUT                    @"TIMEOUT"
#define kFunnyzone_CatchValue_KEEPVALUE     @"KEEPVALUE" 

//Start 2011.11.02 Add by Ming
#define IADevice_TestingCommands_MOBILE_ID               @"MOBILE_ID"
#define IADevice_TestingCommands_FIXTURE_ID              @"FIXTURE_ID"
#define IADevice_TestingCommands_LIGHTMETER_ID           @"LIGHTMETER_ID"
//End 2011.11.02 Add by Ming


#pragma mark ############################## IADevice_Gyro.m ##############################
#define kIADevice_Gyro_GyroX                @"GyroX"
#define kIADevice_Gyro_GyroY                @"GyroY"
#define kIADevice_Gyro_GyroZ                @"GyroZ"
#define kIADevice_Gyro_GyroTemp             @"GyroTemp"
#define kIADevice_Gyro_iQuantity            @"iQuantity"
#define kIADevice_Gyro_Gyro_Count           @"Gyro_Count"
#define kIADevice_Gyro_Gyro_Num             @"Gyro_Num"
#define kIADevice_Gyro_Temperature_Array    @"Temperature_Array"
#define kIADevice_Gyro_Min_Temp             @"Min_Temp"
#define kIADevice_Gyro_Max_Temp             @"Max_Temp"
#define kIADevice_Gyro_AverTemp             @"AverTemp"
#define kIADevice_Gyro_DenoSum              @"DenoSum"
#define kIADevice_Gyro_bGyroInRange         @"bGyroInRange"
#define kIADevice_Gyro_tIndex               @"tIndex"
#define kIADevice_Gyro_calcB                @"calcB"
//#define kITestProgress_UI_SN                @"UI_SN"
//#define kITestProgress_Start_Time           @"Start_Time"
#define kIADevice_Gyro_Array_X              @"Array_X"
#define kIADevice_Gyro_Array_Y              @"Array_Y"
#define kIADevice_Gyro_Array_Z              @"Array_Z"
#define kIADevice_Gyro_GyroFilePath         @"GyroFilePath"

#define kIADevice_Gyro_bIsHaveGyroPath      @"bIsHaveGyroPath"
#define kIADevice_Gyro_calcBX               @"calcBX"
#define kIADevice_Gyro_calcBY               @"calcBY"
#define kIADevice_Gyro_calcBZ               @"calcBZ"


#pragma mark ############################## IADevice_InstantPudding.m ##############################
#define kIADevice_InstantPudding_AttributeKey                       @"AttributeKey"
#define kIADevice_InstantPudding_AttributeValue                     @"AttributeValue"
#define kIADevice_InstantPudding_BlobFileName                       @"filename"
#define kIADevice_InstantPudding_PDCAFileName                       @"pdcaname"
#define kIADevice_InstantType_34401A                                0
#define kIADevice_InstantType_53131                                 1
#define kIADevice_InstantType_34970                                 2
#define kIADevice_InstantType_PPS                                   3

#pragma mark ############################## Leehua definition (process relative)##############################
#define kIADeviceIP_Priority                @"IP_Priority"
#define kIADeviceIP_Unit                    @"IP_Unit"
#define kIADeviceIP_NoParametric            @"IP_NoParametric"
#define kIADeviceCancelToEnd                @"CancelToEnd"

#pragma mark ############################## Ming definition (Button Test relative)##############################
#define kIADevice_ButtonTest_BoolTestFlag               @"ButtonTestBoolTestFlag"
#define kIADevice_ButtonTest_TARGET                     @"ButtonTestTARGET"

#pragma mark ############################## Ming definition (Operation relative)##############################

#define IADevice_Operation_BoolMSGBOXThread                  @"BoolMSGBOXThread"


//2011.07.22 Modify By Ken & Ming for ATSDebug

#import "IALogs.h"

// Follow macro define are autocreate console message.

//Start to modify by Ming 20111021  ,Change Time Format "kIADeviceALSFileNameDate"

#define ATSDBgLog(...); \
NSString * strInformation = [NSString stringWithFormat:@"\n[%@]\n %@",kIADeviceALSFileNameDate,[NSString stringWithFormat:__VA_ARGS__]];\
NSString * filePath = [NSString stringWithFormat:@"%@/%@_%@_DEBUG.txt",kPD_LogPath_Console,m_szPortIndex,m_szStartTime];\
[IALogs CreatAndWriteConsoleInformation:strInformation withPath:filePath];\
NSColor * color = ([__VA_ARGS__ ContainString:@"(TestResult : FAIL ; Duration "]) ? [NSColor redColor] : [NSColor grayColor];\
NSDictionary * dict = [NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];\
NSAttributedString * attriStrConsole = [[NSAttributedString alloc] initWithString:strInformation attributes:dict];\
[m_strConsoleMessage appendAttributedString:attriStrConsole];\
NSLog(__VA_ARGS__);\
[attriStrConsole release];

#define ATSDebug(...); [self writeDebugLog:[NSString stringWithFormat:__VA_ARGS__]];
//End Ming 20111021
