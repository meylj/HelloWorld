//
//  Muifa_Define.h
//  Muifa
//
//  Created by Gordon Liu on 9/23/11.
//  Copyright 2011 PEGATRON. All rights reserved.
//

#ifndef Muifa_Muifa_Define_h
#define Muifa_Muifa_Define_h

#pragma mark ############################## Muifa Window Size ###########################

#define kMuifa_Window_Point_X                   12
#define kMuifa_Window_Point_Y                   100
#define kMuifa_Window_Size_Width                1000
#define kMuifa_Window_Size_Height               700
#define kMuifa_Left_View_Size_Width             300
#define kMuifa_Left_View_Size_Height            632
#define kMuifa_Right_View_Size_Width            700
#define kMuifa_Right_View_Size_Height           658
#define kMuifa_SN_View_Size_BaseHeight          34
#define kMuifa_BaseBlankHeight                  10

#define kMuifa_IndicatorView_Size_Height        48
#define kMuifa_Window_Mode_SFSU                 @"SFSU"
#define kMuifa_Window_Mode_NFMU                 @"NFMU"
#define kMuifa_Window_Mode_MFMU                 @"MFMU"
#define kMuifa_MaxUnitNumber                    12


#pragma mark ############################## Table view tag ##############################
#define kTag_TableView_CSVLog                   0
#define kTag_TableView_UartLog                  1
#define kTag_TableView_FailItems                2
#define kTag_TableView_Drawer                   3


#pragma mark ######################### Table view column identifier ####################
#define kKey_For_TableColumn_Num                @"Num"
#define kKey_For_TableColumn_Image              @"Image"
#define kKey_For_TableColumn_ItemName           @"ItemName"
#define kKey_For_TableColumn_Spec               @"Spec"
#define kKey_For_TableColumn_Value              @"Value"
#define kKey_For_TableColumn_Time               @"Time"
#define kKey_For_TableColumn_Rx                 @"Rx"
#define kKey_For_TableColumn_Tx                 @"Tx"
#define kKey_ForNotification_ItemResult         @"ItemResult"


#pragma mark ############################# main test ################################
#define kKey_ForThread_SingleUnit               @"SingleUnit"
#define kKey_ForNotification_CSVInfo            @"CSVInfo"
#define kKey_ForNotification_Indicator          @"Indicator"

#pragma mark ############################# UserDefaults Keys ################################
#define kUserDefaultPath                        [NSString stringWithFormat:@"%@/Library/Preferences", NSHomeDirectory()]
//#define kMuifaPlistPath                         [NSString stringWithFormat:@"%@/Library/Preferences/Muifa.plist", NSHomeDirectory()]
#define kMuifaPlistPath                         @"/Library/Preferences/Muifa.plist"
#define kMuifaCounterPlistPath                  [NSString stringWithFormat:@"%@/Library/Preferences/Muifa_Counter.plist", NSHomeDirectory()]
#define kFxitureControlPlistPath                  [NSString stringWithFormat:@"%@/Library/Preferences/Fixture_Control.plist", NSHomeDirectory()]
#define kFZ_UserDefaults                        [NSUserDefaults standardUserDefaults]
#define kUserDefaultModeSetting                 @"ModeSetting"
#define kUserDefaultCurrentMode                 @"CurrentMode"
#define kUserDefaultEnableChangeMode            @"EnableChangeMode"
#define kUserDefaultAutoDetectAndRun            @"AutoDetectAndRun"
#define kUserDefaultAutoInitFixture             @"AutoInitFixture"      // 2012.05.09 add by betty key for AutoInitFixture in Muifa.plist
#define kUserDefaultManualStartTest             @"ManualStartTest"
#define kUserDefaultSN_Manager                  @"SN_Manager"
#define kUserDefaultSN_Arrangement              @"SN_Arrangement"
#define kUserDefaultSNRule_Length               @"SN Rule Lenth"
#define kUserDefaultSNRule_ContainString        @"SN Rule ContainString"
#define kUserDefualtGarbageSN                   @"Garbage SN"
#define kUserDefualtEnableAbort                 @"EnableAbort"

#pragma mark ############################# Keys transfer to Template ################################
#define kTransferKey_Ports                      @"Ports"
#define kTransferKey_UnitColor                  @"UnitColor"

#endif
