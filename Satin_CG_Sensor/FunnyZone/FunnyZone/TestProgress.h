//
//  TestProgress.h
//  FunnyZone
//
//  Created by Lorky on 3/30/11.
//  Copyright 2011 PEGATRON. All rights reserved.
//


// **************************************************************************************************** 
// Copyright (C) 2011 Pegatron HHD ODM BU3-ATS
//
// File name	:
//			TestProgress.h TestProgress.m
//
// Description	: 
//			This class was the main class of this framework, It will communicate with all other 
//			class in this project. It called MathFunction class to do some simple calculate. It called 
//			the XML parser class to parser test plan file. It called Device class to do the functions 
//			in each station and communicate with the fixture, DUT, Mikey board .ect. It will call the 
//			net service class to communicate with the SFC, Bobcat, Pudding and so on.
//			This framework was used by UI.
//
// Notes		:
//			Created by Lorky_Luo on 3/30/2011
//
// Change list	:
//
// *************************************************************************************************** 



#import <Foundation/Foundation.h>

#import "publicDefine.h"
#import "IADevice_Define.h"
#import "MathLibrary.h"
#import "NSStringCategory.h"
#import "NSDateCategory.h"
#import "NSPanelCategory.h"
#import "SDPanel.h"
#import "PuddingPDCA/TPuddingPDCA.h"
#import "CBTestBase.h"

//@class CBTestBase;



//notification name
extern NSString* const	TestItemInfoNotification;
extern NSString* const	TiltFixtureNotificationToFZ;
//extern NSString* const	ShowMessage;
//extern NSString* const	CloseMessage;



@interface TestItemStruct : NSObject
{
@private
    NSString	*ItemName;  //测项名
	NSArray		*TestSort;  //子测项
}

@property (copy)	NSString	*ItemName;
@property (retain)	NSArray		*TestSort;
@end



@interface TestProgress : NSOperation
<writeDebugLog>
{
@private
	NSMutableString				*m_szReturnValue;			// Record the return value from the Device class function.
    NSMutableString				*m_szErrorDescription;		// error description for each test case
    NSMutableString				*m_szFailLists;
	TPuddingPDCA				*m_objPudding;				// The object of pudding.
    CBTestBase					*m_CBTestBase;
    MathLibrary					*m_mathLibrary;
    
    BOOL                        m_bIsFinished;
    BOOL                        m_newItemFlag;
    BOOL                        m_itemHasDUTRX;
	
    
    NSMutableDictionary			*m_dicLogPaths;
    NSMutableString             *m_strLogFolderPath;
    
	NSString					*m_szISN;					// The device ISN.
	NSString					*uiVersion;				// UI version.
    NSString					*m_szScriptVersion;			// script file version
    NSString					*m_szScriptName;			// TestScript file name

	NSString					*m_szStartTime;				// Start test progress time.
	NSString					*m_szStartDate;
	NSMutableAttributedString	*m_strConsoleMessage;		// Console message
	NSMutableAttributedString	*m_strSingleUARTLogs;		// UART Logs
	NSMutableArray				*m_arrSingleItemInfo;		// Single Item informations
	NSMutableString				*m_szPortIndex;
	NSArray						*m_arrayScript;				// Array that record Script file.
    NSMutableDictionary			*m_dicPorts;
    NSDictionary				*m_dictPortColor;
    
    NSMutableDictionary			*m_dicMemoryValues;
    NSMutableDictionary         *m_dicMemoryButtonKeyValue;
	NSMutableDictionary			*m_dicButtonBuffer;			// Only for Button test.
    NSMutableString				*m_strSpecName;				// Key name of spec for multiple specs
    int							m_iStatus;
    //for test item
    NSMutableString				*m_szUnit;
    NSInteger					m_iPriority;
    BOOL						m_bNoParametric;
    BOOL						m_bCancelToEnd;
    BOOL						m_bFinalResult;
    BOOL						m_bCancelFlag;
    BOOL						m_bSubTest_PASS_FAIL; //sub test item result
    BOOL						m_bLastItemResult;
    
    //For CG pattern
    BOOL						m_bPatnRFromUI;
    NSInteger					m_iPatnRFromFZ;
    
    
    double						dData[1200][5];				// For QT1 ALS
    
    //Start 2011.10.29 Add by ming 
    NSPanel						*m_panel;
    NSModalSession				m_session;
    bool						m_bPanelThread;
	NSInteger					m_iPanelReturnValue;
    NSString					*m_CGSN;
    //End 2011.10.29 Add by ming 
    
    NSThread					*m_TEST_LIGHTMETER_THREAD;	//Start 2011.10.31 Add By Ming
    
    //Start 2011.11.03 Add By Ming, for compass
    int							m_iCamispFailCount;
    bool						m_bNeedJudgeFailReceive;
    //End 2011.11.03 Add By Ming, for compass
    
    NSMutableArray				*m_arrDisplayPortData;		//for DisplayPort
    NSMutableArray				*m_muArrayCancelCase;		//for will cancel case
    NSMutableArray				*m_muArrayLocalCofCase;		//for will local cof case
    NSMutableArray				*m_muArrayLocalCofTest;		//for use local cof sepc test
    BOOL						m_bIsPuddingCanceled;
    NSMutableDictionary			*m_dicNetWorkCBStation;		//add for remember NetWork CB Station result
    
    /*	Kyle 2012.02.13
     * abstract     : use astrisctl for get kong cable version*/
    NSMutableString				*m_muszValue;
    int							iJudgeMode;
	//A flag for read uart commannd pass/fail, 2012.4.20 add by stephen.
    BOOL						bUartRevPass;
    //A flag for need upload to PDCA or Not. add by betty 2012.4.24
    BOOL						m_bOfflineDisablePudding;
	BOOL						m_bValidationDisablePudding;
    //A flag for checked PDCA or not, 2012.5.23 add by stephen.
    BOOL						m_bIsCheckedPDCA;
   
    //2012 7 16 torres add for MagnetSpine exception spec
    NSInteger					m_exceptCount; 
	
    // for empty response over 3 times.
    BOOL						m_bEmptyResponse;//Leehua
	
	// Added by Izual on 2013-01-16 for DUT in OS mode.
	NSTask						*m_taskTcprelay;
    
    // Add to response that op had made a color choice before test, AE stations.
    BOOL                        m_bFinishChoose;
    
    // record process items
    NSArray                     *m_arrProItems;
	BOOL						m_bProcessIssue;
	
	int							m_iAlsoAllowedCount;
    
    //For Pressure Test, Add by leehua 2013.10.18 begin
    BOOL                        m_bFixtureControlOnhand;
    //For Pressure Test , Leehua
    publicParams                *m_objPublicParams;
    // For MBT station
    int                         m_iAllCount;
    
    // add for usbf task
    NSTask                      *m_UsbfTask;

    //Add for disable query function
    NSMutableDictionary         *m_dicDisableQueryItems;
    
    NSNumber *FlagTchFWNoErr  ;
    NSNumber *FlagTrgFnlBfWhl;
    NSNumber *FlagTrgOrgAfWhl;
    BOOL                        m_bTestItemSYNCContinue;
    
}
//For Pressure Test , Leehua
@property (readwrite,assign)    publicParams        *publicParas;
@property (copy)				NSString			*MobileSerialNumber;//ISN
@property (copy)				NSString			*startTime;//startTime
@property (copy)				NSString			*startDate;
@property (copy)				NSString			*uiVersion;//
@property (copy)				NSString			*scriptVersion;//
@property (copy)				NSString			*scriptName;

@property (retain, nonatomic)	NSArray				*arrayScript;//script
@property (retain, nonatomic)	NSMutableDictionary	*ports;//port
@property (retain, nonatomic)	NSMutableDictionary *memoryValues;//save variables
@property (assign)				BOOL				m_bPatnRFromUI;
@property (retain,nonatomic)	NSMutableString		*portIndex;

@property (readwrite, assign)	int					status;//multi ui status
@property (assign)				BOOL				isCheckedPDCA;

@property (assign)				BOOL				processIssue;

@property (assign)				BOOL				isEmptyResponse;//Leehua
@property (assign)              BOOL                m_bTestItemSYNCContinue;



//get stationINfo
-(NSDictionary*)getStationInfo;

//For Pressure Test
- (id)initWithPublicParam:(publicParams *)publicParams;

- (void)postTestInfoToUI:(NSDictionary *)dictTestInfo;

-(BOOL)performSELToClass:(NSDictionary *)dictItem
			 SubItemName:(NSString *)szSubName
				ItemName:(NSString *)szItemName;
-(NSArray*)parserScriptFile:(NSString *)szScriptFilePath;

// Description	:	
//
//		End test DUT. It will finish the test progress.
//
// Parameter	: 
//
//	dStartTime	:	Record the start time that begin to test progress
//
-(void)endDUTPrg:(double)dStartTime
	  TestResult:(BOOL)bResult;

/*!	Judge value by given limits in given mode. 
 *	@param	iMode
 *			0 means (?,?), SpL < Val < SpR.
 *			1 means [?,?], SpL <= Val <= SpR.
 *			2 means {?,?,?,...}, value contains one of the elements.
 *			3 means (?,?], SpL < Val <= SpR.
 *			4 means [?,?), SpL <= Val < SpR.
 *			5 means <?,?,?,...>, value is one of the elements. */
-(BOOL)JudgeValue:(NSString*)szValue 
	   WithLimits:(NSArray*)arrayLimits 
             Mode:(int)iMode;

// Transform keys in expressions to values in dicMemoryValues
// Key format /*???*/, ??? is the key
// Param:
//      NSString    *szKey  : An expression contains keys
//      NSString   **szValue: value form dict for the szKey
// Return:
//      BOOL   : if value is nil ,return nil
-(BOOL)TransformKeyToValue:(NSString*)szKeyString
			   returnValue:(NSString **)szValue;

// Transform Color string to NSColor
// Param:
//		NSString			*strPortColor	: String color before transform. {WHITE, RED, GREEN, BLUE, YELLOW, ORANGE}
// Return:
//		NSColor				: NSColor after transform
-(NSColor*)TransformPortColor:(NSString*)strPortColor;

//get sub objects from one dictionary
//param:
//  id                  inXml  :   dictionary you want get sub objects from
//  NSString            *inMainKey,... :    sub keys
//Return:
//  id      :           return the value you want
-(id)getValueFromXML:(id)inXml
			 mainKey:(NSString *)inMainKey, ...;

// Get UUT Number from BSD path
// Param:
//      NSString    *szResponse : SFIS response
// Return:
//      Port Number
-(NSInteger) GetUSB_PortNum;

//cFix  :   you can input = , * ....
//szTitle : START TEST QT0b
//return(example) :  ========= START TEST QT0b ========= ; ************ START TEST QT0b *************
- (NSString *)formatLog:(NSString *)cFix
				  title:(NSString *)szTitle;

//tranfer dictionary to string for writing console log
- (NSString *)formatLog_transferObject:(id)objItem;

//You can call this function from UI to do checkSum , if you want to do checkSum for one file , you need to add the absolute path of this file to dicCheckSumFiles
-(NSString *)cal_checkSum:(NSString *)szFilePath;
-(BOOL)do_checkSum;

//set PDCA SN
- (BOOL)setInstantPuddingSerialNumber;

//start pdca flow
- (BOOL)startPuddingUploadFlow;
//rename logs (because in single UI , SN is not exist at the beginning , we use portnumber to identify,at last we need to replace portnumber with SN)
- (void)renameLogs;
//send to PDCA
- (BOOL)write_PDCA;

// If the strSource did not exsist any object at arrayObjs, return NO, otherwise return YES
- (BOOL)ExsistObjects:(NSArray *)arrayObjs
			 AtString:(NSString *)strSource
		   IgnoreCase:(BOOL)bCase;

//handle tiltFixtureResult notification
- (void)PatternResultFromFixture:(NSNotification *)notiInfo;

//**********************************************************for uart*************************************************
//string hex to data
-(NSData *)stringHexToData:(NSString *)szInput;
-(NSString *)catchFromString:(NSString *)szOriString
					   begin:(NSString*)szBegin
						 end:(NSString *)szEnd
			  TheRightString:(BOOL) bTheRight;
-(NSString *)catchFromString:(NSString *)szOriString
					location:(NSInteger)iLocation
					  length:(NSInteger)iLength;
- (void)getSpecFrom:(NSString *)szSpecString
			lowLimt:(NSString **)szDnLimit
		  highLimit:(NSString **)szUpLimit;
- (void)uploadParametric:(NSString *)szItemName
				lowLimit:(NSString *)szDnLimit
			   highLimit:(NSString *)szUpLimit
				  status:(BOOL)bStatus
			errorMessage:(NSMutableString *)szErrorMessage;
-(void)writeForCocoSpecName:(NSString *)szCurrentItemName
					 status:(BOOL)bStatus
					csvPath:(NSString *)szCSVFileName
				   sumNames:(NSMutableString *)szTestNames
				sumUpLimits:(NSMutableString *)szUpperLimits
				sumDnLimits:(NSMutableString *)szDownLimits
			   sumValueList:(NSMutableString *)szValueList
		   errorDescription:(NSMutableString *)szErrorDescription
				   sumError:(NSMutableString *)szErrorInfo
			   CurrentIndex:(int)index;
-(void)writeForNormalSpecName:(NSString*)szCurrentItemName
					   status:(BOOL)bStatus
					  csvPath:(NSString *)szCSVFileName
					 sumNames:(NSMutableString *)szTestNames
				  sumUpLimits:(NSMutableString *)szUpperLimits
				  sumDnLimits:(NSMutableString *)szDownLimits
				 sumValueList:(NSMutableString *)szValueList
			 errorDescription:(NSMutableString *)szErrorDescription
					 sumError:(NSMutableString *)szErrorInfo
				 CurrentIndex:(NSInteger)index;
-(BOOL)ParseSpec:(NSString *)szSpec;

/*!	@author 
 *          Jingfu Ran
 *  @since  
 *          2012_04_06
 *  @brief 
 *          Upload subItem as parametricdata
 *  @param  
 *          dicUploadInfo
 *          The dicInfo should contains below key-values
 *          PARAMETRIC       -------    the name of parametrc(NSString *) ps:must contain
 *          HIGHLMT          -------    High limit(NSString *)
 *          LOWLMT           -------    Low Limit(NSString *)
 *	@return	
 *          NSNumber * */
-(NSNumber*)UPLOADPARAMETEDATAFORSUBITEM:(NSDictionary *)dicUploadInfo
							 RETURNVALUE:(NSMutableString *)szReturn;
-(NSString*)getECIDNumber:(NSString *)strInput;

#pragma mark - For Release Space Of Unit Tool
-(NSNumber*)COMMUNICATE_WITH_TASK:(NSDictionary*)dictParam
					 RETURN_VALUE:(NSMutableString*)strReturnValue;
-(NSNumber *)LOOP_COMMUNICATE_WITH_TASK:(NSDictionary *)dicPara
                           RETURN_VALUE:(NSMutableString *)szReturnValue;

// DEFINE_PRC_ITEMS:RETURN_VALUE:
-(NSNumber*)DEFINE_PRC_ITEMS:(NSDictionary*)dictParam
                RETURN_VALUE:(NSMutableString*)strReturnValue;

@end



#import "IADevice_DetectPort.h"




