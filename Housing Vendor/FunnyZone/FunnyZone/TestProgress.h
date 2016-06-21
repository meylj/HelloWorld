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
#import "PuddingPDCA/TPuddingPDCA.h"
#import "PEGA_ATS_UART/PEGA_ATS_UART.h"
#import "InstrumentLibrary/Device_34401A.h"
#import "InstrumentLibrary/Device_53131.h"
#import "InstrumentLibrary/Device_34970.h"
#import "InstrumentLibrary/PPS_Device.h"

#import "IADevice_Define.h"
#import "publicDefine.h"
#import "MathLibrary.h"
#import "NSStringCategory.h"
#import "SDPanel.h"

@class CB_TestBase;

//notification name
extern NSString * const TestItemInfoNotification;
extern NSString * const TiltFixtureNotificationToFZ;

extern NSString * const ShowMessage;

extern NSString * const CloseMessage;

@interface TestItemStruct : NSObject
{
@private
    NSString	* ItemName;  //测项名
	NSArray		* TestSort;  //子测项
}

@property (copy)	NSString	*	ItemName;
@property (retain)	NSArray		*	TestSort;
@end


@interface TestProgress : NSOperation<writeDebugLog> {
@private
	NSMutableString			*	m_szReturnValue;            // Record the return value from the Device class function.
    NSMutableString         *   m_szErrorDescription;       // error description for each test case
    NSMutableString         *   m_szFailLists;
	TPuddingPDCA            *	m_objPudding;				// The object of pudding.
    CB_TestBase             *m_CB_TestBase;
    MathLibrary             *m_mathLibrary;
    // for GPIB  add by Kyle
    Device_34401A           *m_Device_34401A;
    
	BOOL						m_bAbort;					// Abort App.
    BOOL                        m_bIsFinished;
    BOOL                        m_newItemFlag;
    BOOL                        m_itemHasDUTRX;
    
    NSMutableDictionary    *    m_dicLogPaths;
    
	NSString				*	m_szISN;					// The device ISN.
	NSString				*	m_szUIVersion;				// UI version.
    NSString                *   m_szScriptVersion;          // script file version
    NSString                *   m_szScriptName;             // TestScript file name

	NSString				*	m_szStartTime;				// Start test progress time.	
	NSMutableAttributedString*	m_strConsoleMessage;		// Console message	
	NSMutableString			*	m_szPortIndex;
	NSArray					*	m_arrayScript;				// Array that record Script file.
    NSMutableDictionary     *   m_dicPorts;
    NSDictionary            *   m_dictPortColor;
    /////
    NSMutableDictionary     *m_dicMemoryValues;
    NSMutableString			*m_strSpecName;	// Key name of spec for multiple specs
    int                     m_iStatus;
    //for test item
    NSMutableString         *m_szUnit;
    NSInteger               m_iPriority;
    BOOL                    m_bNoParametric;
    BOOL                    m_bCancelToEnd;
    BOOL                    m_bFinalResult;
    BOOL                    m_bCancelFlag;
    BOOL                    m_bSubTest_PASS_FAIL;
    BOOL                    m_bLastItemResult;
    BOOL                    m_bLastLastItemResult;          // The last two test items' result
    
    //For CG pattern
    BOOL                    m_bPatnRFromUI;
    NSInteger               m_iPatnRFromFZ;
    
    double                  dData[1200][5]; // For QT1 ALS
    
    //Start 2011.10.29 Add by ming 
    NSPanel                 *m_panel;
    NSModalSession          m_session;
    bool					m_bPanelThread;
	bool					m_bIs_FirstError;
	int                     m_iPanelReturnValue;
    NSString                *m_CGSN;
    //End 2011.10.29 Add by ming 
    
    //Start 2011.10.31 Add By Ming
    NSThread                *m_TEST_LIGHTMETER_THREAD;
    //End 2011.10.31 Add By Ming
    
    //Start 2011.11.03 Add By Ming, for compass
    NSMutableArray          *m_arrCompassData;
    int                     m_iNoiseFailCount;
    int                     m_iCamispFailCount;
    double                  m_doubleCompass_VCMTime;
    bool                    m_bNeedJudgeFailReceive;
    
    //NSString                *m_szColor;
    //End 2011.11.03 Add By Ming, for compass
    
    //for DisplayPort
    NSMutableArray			*m_arrDisplayPortData;
    
    //for will be failed case
    NSMutableDictionary     *m_dicForceFaileCase;
    
    //for will be passed case
    NSMutableDictionary     *m_dicForcePassCase;
    
    //for will cancel case
    NSMutableArray          *m_muArrayCancelCase;
    //for Prox Cal
    NSDate                  *dateStartTime;
    BOOL                    m_bIsPuddingCanceled;
    
    //add for remember NetWork CB Station result
    NSMutableDictionary     *m_dicNetWorkCBStation;
    
    /*
     * Kyle 2012.02.13
     * abstract     : use astrisctl for get kong cable version
     */
    NSMutableString  *m_muszValue;
    int			iJudgeMode;
    
    //A flag for read uart commannd pass/fail, 2012.4.20 add by stephen.
    BOOL                    bUartRevPass;
    //A flag for need upload to PDCA or Not. add by betty 2012.4.24
    BOOL                    m_bNoUploadPDCA;
    //A flag for checked PDCA or not, 2012.5.23 add by stephen.
    BOOL                    m_bIsCheckedPDCA;
    
    int                     m_iElderBrother;//for Grape-1 4-Up
    BOOL                    m_bYoungBrother;//for Grape-1 4-Up
    BOOL                    m_bIsElderBrotherPort;//for Grape-1 4-Up
   
    //2012 7 16 torres add for MagnetSpine exception spec
    NSInteger               m_exceptCount; 

    //For CT 4UP
    SDPanel *sdPanel;
    BOOL    m_bForceResult;
    BOOL    m_bOpenPanel;
    BOOL    m_ReturnValue;
    BOOL    m_StopFlag;
    
    //For CT2 Ants Test
    BOOL    m_bEnableKeyDown;
    BOOL    m_bNextPattern;
    BOOL    m_bLastPattern;
    BOOL    m_bAllPatternReady;
    BOOL    m_bCT2PatternFail;
    
    // for 
    BOOL    m_bNoResponse;//Leehua
    
    // for prox cal
    BOOL    m_bHasTestedSlot1;
	
	int		CASID;
    
    NSMutableString *m_szTestNames;
    NSMutableString *m_szUpperLimits;
    NSMutableString *m_szDownLimits;
    NSMutableString *m_szValueList;
    NSMutableString *m_szErrorInfo;
    
    // add for show special status color on UI  --Gordon
    NSString *m_szStatusColor;
    
}
@property (copy)	NSString	*	MobileSerialNumber;//ISN
@property (copy)	NSString	*	m_szStartTime;//startTime
@property (copy)    NSString	*	m_szUIVersion;//
@property (copy)    NSString    *   m_szScriptVersion;//
@property (copy)    NSString    * ScriptName;

@property (retain, nonatomic) NSArray * arrayScript;//script
@property (retain, nonatomic) NSMutableDictionary * m_dicPorts;//port
@property (retain, nonatomic) NSMutableDictionary * m_dicMemoryValues;//save variables
@property (assign)	BOOL			m_bAbort;
@property (assign)  BOOL            m_bPatnRFromUI;
@property (retain,nonatomic) NSMutableString * m_szPortIndex;

@property (assign)	BOOL			m_ReturnValue;;
@property (assign)  BOOL            m_StopFlag;

@property (readwrite, assign)  int  m_iStatus;//multi ui status
@property (assign)  BOOL            isCheckedPDCA;

@property (assign)  BOOL            m_bNoResponse;//Leehua

// add for show special status color on UI  --Gordon
@property (retain, nonatomic) NSString * m_szStatusColor;

//for Grape-1 4-Up
enum GAN
{
    BROTHER_ERROR = -1,
    BROTHER_PASS,
    BROTHER_FAIL,
};
//get stationINfo
- (NSDictionary *)getStationInfo;

- (BOOL)performSELToClass:(NSDictionary *)dictItem SubItemName:(NSString *)szSubName ItemName:(NSString *)szItemName;

- (NSArray *)parserScriptFile:(NSString *)szScriptFilePath;

// Description	:	
//
//		End test DUT. It will finish the test progress.
//
// Parameter	: 
//
//	dStartTime	:	Record the start time that begin to test progress
//
- (void)endDUTPrg:(double)dStartTime  TestResult:(BOOL)bResult;

//common functions
// Judge value with limits and mode
// Param:
//		NSString	*szValue		: Value you want to judge
//		NSArray		*arrayLimits	: Given limits
//		int			iMode			: Spec mode. 0 = (), 1 = [], 2 = {}, 3 = (], 4 = [), 5 = JUDGE CB
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
-(BOOL)TransformKeyToValue:(NSString*)szKeyString returnValue:(NSString **)szValue;

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
-(id)getValueFromXML:(id)inXml mainKey:(NSString *)inMainKey, ...;

// Get UUT Number from BSD path
// Param:
//      NSString    *szResponse : SFIS response
// Return:
//      Port Number
-(NSInteger) GetUSB_PortNum;

//cFix  :   you can input = , * ....
//szTitle : START TEST QT0b
//return(example) :  ========= START TEST QT0b ========= ; ************ START TEST QT0b *************
- (NSString *)formatLog:(NSString *)cFix title:(NSString *)szTitle;

//tranfer dictionary to string for writing console log
- (NSString *)formatLog_transferObject:(id)objItem;

//You can call this function from UI to do checkSum , if you want to do checkSum for one file , you need to add the absolute path of this file to dicCheckSumFiles
- (NSString *)cal_checkSum:(NSString *)szFilePath;

- (BOOL)checkSum:(NSString *)szCheckSumPath withSum:(NSString *)szSum;

- (BOOL)do_checkSum;

//set PDCA SN
- (BOOL)set_PDCA_SN;

//start pdca flow
- (BOOL)start_PDCA;
//rename logs (because in single UI , SN is not exist at the beginning , we use portnumber to identify,at last we need to replace portnumber with SN)
- (void)renameLogs;
//send to PDCA
- (BOOL)write_PDCA;

// If the strSource did not exsist any object at arrayObjs, return NO, otherwise return YES
- (BOOL)ExsistObjects:(NSArray *)arrayObjs AtString:(NSString *)strSource IgnoreCase:(BOOL)bCase;

//handle tiltFixtureResult notification
- (void)PatternResultFromFixture:(NSNotification *)notiInfo;

//**********************************************************for uart*************************************************
//string hex to data
-(NSData *)stringHexToData:(NSString *)szInput;

-(NSString *)catchFromString:(NSString *)szOriString begin:(NSString*)szBegin end:(NSString *)szEnd TheRightString:(BOOL) bTheRight;

-(NSString *)catchFromString:(NSString *)szOriString location:(NSInteger)iLocation length:(NSInteger)iLength;

- (void)getSpecFrom:(NSString *)szSpecString lowLimt:(NSString **)szDnLimit highLimit:(NSString **)szUpLimit;

- (void)uploadParametric:(NSString *)szItemName lowLimit:(NSString *)szDnLimit highLimit:(NSString *)szUpLimit status:(BOOL)bStatus errorMessage:(NSMutableString *)szErrorMessage;

-(void) writeForCocoSpecName:(NSString *)szCurrentItemName status:(BOOL)bStatus csvPath:(NSString *)szCSVFileName sumNames:(NSMutableString *)szTestNames sumUpLimits:(NSMutableString *)szUpperLimits sumDnLimits:(NSMutableString *)szDownLimits sumValueList:(NSMutableString *)szValueList errorDescription:(NSMutableString *)szErrorDescription sumError:(NSMutableString *)szErrorInfo endItem:(BOOL)bEndItem saveSummary:(BOOL)bSaveSum saveCSV:(BOOL)bSaveCSV uploadParametric:(BOOL)bUploadParam CurrentIndex:(int)index;

-(void) writeForNormalSpecName:(NSString *)szCurrentItemName status:(BOOL)bStatus csvPath:(NSString *)szCSVFileName sumNames:(NSMutableString *)szTestNames sumUpLimits:(NSMutableString *)szUpperLimits sumDnLimits:(NSMutableString *)szDownLimits sumValueList:(NSMutableString *)szValueList errorDescription:(NSMutableString *)szErrorDescription sumError:(NSMutableString *)szErrorInfo endItem:(BOOL)bEndItem saveSummary:(BOOL)bSaveSum saveCSV:(BOOL)bSaveCSV uploadParametric:(BOOL)bUploadParam CurrentIndex:(int)index;

-(BOOL)ParseSpec:(NSString *)szSpec;

/*!
 *  @author 
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
 *          NSNumber * 
 *          
 */
-(NSNumber *)UPLOADPARAMETEDATAFORSUBITEM:(NSDictionary *)dicUploadInfo RETURNVALUE:(NSMutableString *)szReturn;

- (NSString *)getECIDNumber:(NSString *)strInput;

// Judge the uart port whether is the port to control fixture(Unit1)
- (NSNumber *)Is_Elder_Brother_port:(NSDictionary*)dicPara RETURNVALUE:(NSMutableString *)szReturnValue;

// Host port post notification to the other port
- (NSNumber *)ELDER_BROTHER_NOTIFY_YOUNG_BROTHER:(NSDictionary*)dicPara RETURNVALUE:(NSMutableString *)szReturnValue;

//elder brother notification function
-(void)elderBrotherIsReady:(NSNotification *)aNote;

// The servo ports post nofitication to the host port
- (NSNumber *)YOUNG_BROTHER_NOTIFY_ELDER_BROTHER:(NSDictionary*)dicPara RETURNVALUE:(NSMutableString *)szReturnValue;

//young brother notification function
-(void)youngBrotherIsReady:(NSNotification *)aNote;

-(void)judgeWhichKeyPressed:(NSNotification *)aNote;

// Ants Test
-(void)judgeAllPatternReadyOrNot:(NSNotification *)aNote;

- (NSNumber *)ANTS_TEST:(NSDictionary*)dicPara RETURNVALUE:(NSMutableString *)szReturnValue;

- (void)getInfomationFromDrawer:(NSNotification *)aNote;

- (void)wakeUpPortsForUnexpectedFail:(NSDictionary *)dicInfo;

- (NSNumber *)SHOW_OTHER_STATUS_ON_UI:(NSDictionary*)dicPara RETURN_VALUE:(NSMutableString *)szReturnValue;


@end
