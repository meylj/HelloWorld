//
//  AppDelegate_FakeTagetDefine.h
//  FakeTaget
//
//  Created by raniys on 3/28/14.
//  Copyright (c) 2014 raniys. All rights reserved.
//

#import "NSStringCategory.h"

#ifndef Fake_Target_Define
#define Fake_Target_Define

#pragma mark ################################## Command ####################################
//#define kFT_ScriptFile_Path                     [NSString stringWithFormat:@"%@/Library/Preferences/ATS_FakeTarget.plist",NSHomeDirectory()]
#define kFT_Script_Setting                      [m_dictMemoryValues objectForKey:@"ScriptSetting"]

#pragma mark ################################## Uart ####################################
#define kFT_Script_Setting_BaudeRate       @"DeviceSetting",szPortType,@"BAUDE_RATE"
#define kFT_Script_Setting_DataBit         @"DeviceSetting",szPortType,@"DATA_BIT"
#define kFT_Script_Setting_Parity          @"DeviceSetting",szPortType,@"PARITY"
#define kFT_Script_Setting_StopBit         @"DeviceSetting",szPortType,@"STOP_BIT"
#define kFT_Script_Setting_Try             @"DeviceSetting",szPortType,@"TRY"
#define kFT_Script_Setting_EndFlag         @"DeviceSetting",szPortType,@"ENDFLAG"
#define kFT_Script_Setting_Expect          @"DeviceSetting",szPortType,@"EXPECT"
#define kFT_Script_Setting_MatchType       @"DeviceSetting",szPortType,@"MATCH_TYPE"
#define kFT_Script_Setting_Type            @"DeviceSetting",szPortType,@"TYPE"
#define kFT_Script_Setting_UartColor       @"DeviceSetting",szPortType,@"UART_COLOR"
//add by jingfu ran on 2012 04 26. For send comand used HEX
#define kFT_Script_Setting_ISHEX           @"DeviceSetting",szPortType,@"HEX"

#define kFT_DeviceSet_BaudeRate         [self getValueFromXML:kFT_Script_Setting mainKey:kFT_Script_Setting_BaudeRate,nil]
#define kFT_DeviceSet_DataBit           [self getValueFromXML:kFT_Script_Setting mainKey:kFT_Script_Setting_DataBit,nil]
#define kFT_DeviceSet_Parity            [self getValueFromXML:kFT_Script_Setting mainKey:kFT_Script_Setting_Parity,nil]
#define kFT_DeviceSet_StopBit           [self getValueFromXML:kFT_Script_Setting mainKey:kFT_Script_Setting_StopBit,nil]
#define kFT_DeviceSet_Try               [self getValueFromXML:kFT_Script_Setting mainKey:kFT_Script_Setting_Try,nil]
#define kFT_DeviceSet_EndFlag           [self getValueFromXML:kFT_Script_Setting mainKey:kFT_Script_Setting_EndFlag,nil]
#define kFT_DeviceSet_Expect            [self getValueFromXML:kFT_Script_Setting mainKey:kFT_Script_Setting_Expect,nil]
#define kFT_DeviceSet_MatchType         [self getValueFromXML:kFT_Script_Setting mainKey:kFT_Script_Setting_MatchType,nil]
#define kFT_DeviceSet_Type              [self getValueFromXML:kFT_Script_Setting mainKey:kFT_Script_Setting_Type,nil]
#define kFT_DeviceSet_UartColor         [self getValueFromXML:kFT_Script_Setting mainKey:kFT_Script_Setting_UartColor,nil]


#define kFT_Cable_Paths                      @"CablePaths"
#define KFT_Device_Setting                   @"DeviceStting"
#define kFT_Target_To_Open                   @"CableToOpen"
#define kFT_Target                           @"TARGET"
#define kFT_Targets                          @"TARGETS"
#define kFT_Data_Parameters                  @"LogParameter"

#pragma mark ############################## Define file attribute ##############################
#define kFT_File_Data               @"AllData"
#define kFT_File_Tile               @"LogTile"
#define kFT_Department_Name         @"DepartmentName"
#define kFT_Station_Name            @"StationName"
#define kFT_Project_Name            @"ProjectName"
#define kFT_TestItem_Count          @"TestItemCount"
#define kFT_TestItem_Names          @"TestItemNames"

#pragma mark ################################## Command ####################################
#define kFT_Mobile_Command          @"MOBILECommand"
#define kFT_Fixture_Command         @"FIXTURECommand"
#define kFT_Mikey_Command           @"MIKEYCommand"
#define kFT_Lightmeter_Command      @"LIGHTMETERCommand"
#define kFT_SEND_COMMAND            @"SendCommand"
#define kFT_READ_COMMAND            @"ReadCommand"


#endif