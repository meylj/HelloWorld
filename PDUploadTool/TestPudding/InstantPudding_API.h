/*
 *  InstantPudding_API.h
 *  
 *  
 *
 *  Copyright 2010 Apple, Inc. All rights reserved.
 *
 */
#ifndef IP_API_VERSION
#define IP_API_VERSION 1
#define IP_API_VERSION_MINOR 1

// Types
//#define IP_UID_TYPE unsigned int 
#define IP_MSG_FLAG unsigned int
#define IP_QUERY_TYPE unsigned int

// LabWindows/CVI doesn't have ANSI support by default
#ifdef _CVI_
#include <ansi_c.h>
#define bool BOOL
#endif

// MSVC does not include time.h by default (XCode seems to)
#ifdef _MSC_VER
	#include "time.h"
#endif


/// Test Results
enum IP_PASSFAILRESULT
{
	
	/// test failed
	IP_FAIL = 0,

	/// test passed
	IP_PASS,

	/// test was not run or was skipped
	IP_NA
	
};
//Following enums are to extract the info from the gh_station_info.json file which exists in the /vault/pudding/ folder
enum IP_ENUM_GHSTATIONINFO
{
	IP_SITE = 1,             //SiteCode for the CM from PDCA (predetermined)
	IP_PRODUCT,              //Product code name such as N88, N82 (predetermined)
	IP_BUILD_STAGE,			 //Build stage
	IP_BUILD_SUBSTAGE,		 //Build sub stage
	IP_REMOTE_ADDR,          //Test Station ip address (DHCP 24 hrs lease)
	IP_LOCATION,             //CM building-Floor-Room and floor DA3-2FL-RM123 (predetermined)
	IP_LINE_NUMBER,          //Official APPLE line name froom PDCA (predetermined)
	IP_STATION_NUMBER,       //Test Station number on the line (setup when ground hogging)
	IP_STATION_TYPE,         //PDCA station id code e.g SHIPPING-SETTINGS-OQC (should be same as GH, set up when ground hogging)
	IP_SCREEN_COLOR,		 //Perferred default background screen color(set up, when ground hogging)
	IP_STATION_IP,           //Test Station ip address (DHCP 24 hrs lease)
	IP_DCS_IP,               //ip address to submit data to the Data Collection server
	IP_PDCA_IP,              //ip address of the PDCA
	IP_KOMODO_IP,            //ip address for monitoring server 
	IP_SPIDERCAB_IP,		 //Spidercab IP
	IP_FUSING_IP,			 //Fusing IP
	IP_DROPBOX_IP,			 //Dropbox IP
	IP_SFC_IP,				 //SFC IP
	IP_SFC_URL,				 //SFC URL
	IP_PROV_IP,				 //PROV IP
	IP_DATE_TIME,            //last time when pudding updated the file
	IP_STATION_ID,			 //GUID of the station SITE+LOCATION+LINE_NUMBER+STATION_NUMBER+STATION_TYPE
	IP_GROUNDHOG_IP,         //ip address of the groundhog server
	IP_MAC,					 //Station mac address
	IP_SAVE_BRICKS,			 //Saving bricks
	IP_LOCAL_CSV,			 //Saving csv locally 
	IP_REALTIME_PARAMETRIC,  //Real time parametic
	IP_SINGLE_CSV_UUT,       //Single CSV UUT
	IP_STATION_DISPLAY_NAME, //station_display_name such as VIDEO-PREBURN
	IP_URI_CONFIG_PATH,		 //URI Station config path
	IP_SFC_QUERY_UNIT_ON_OFF,
	IP_SFC_TIMEOUT,
	IP_GHSI_LASTUPDATE_TIMEOUT,
	IP_FERRET_NOT_RUNNING_TIMEOUT,
	IP_NETWORK_NOT_OK_TIMEOUT,
	IP_STATION_SET_CONTROL_BIT_ON_OFF,
	IP_CONTROL_BITS_TO_CHECK_ON_OFF,
	IP_CONTROL_BITS_TO_CLEAR_ON_PASS_ON_OFF,
	IP_CONTROL_BITS_TO_CLEAR_ON_FAIL_ON_OFF,
	IP_ACTIVATION_IP,		 //ip address of activation server
    IP_LINE_MANAGER_IP,		 //ip for RAFT
	IP_GHSTATIONINFO_COUNT

};

enum IP_ENUM_BLOBPOLICY
{

    IP_FOREVER = 1,		//retain forever 
    IP_30DAYS,			//retain for 30 days 
    IP_60DAYS,			//retain for 60 days 
    IP_90DAYS,			//retain for 90 days 
    IP_180DAYS, 		//retain for 180 days 
    IP_270DAYS,			//retain for 270 days 
    IP_360DAYS			//retain for 360 days 

};
enum IP_ENUM_FIXTURE_ID
{
	IP_FIXTURE_ID_1 = 1,	// FIXTURE ID 1 
	IP_FIXTURE_ID_2,		// FIXTURE ID 2
	IP_FIXTURE_ID_3,		// FIXTURE ID 3
	IP_FIXTURE_ID_4,		// FIXTURE ID 4
	IP_FIXTURE_ID_5,		// FIXTURE ID 5
	IP_FIXTURE_ID_6,		// FIXTURE ID 6
	IP_FIXTURE_ID_7,		// FIXTURE ID 7
	IP_FIXTURE_ID_8,		// FIXTURE ID 8
	IP_FIXTURE_ID_9,		// FIXTURE ID 9
	IP_FIXTURE_ID_10		// FIXTURE ID 10
};

enum IP_ENUM_FIXTURE_HEAD_ID
{
	IP_FIXTURE_HEAD_ID_1 = 1,	//HEAD ID 1 
	IP_FIXTURE_HEAD_ID_2,		//HEAD ID 2
	IP_FIXTURE_HEAD_ID_3,		//HEAD ID 3
	IP_FIXTURE_HEAD_ID_4,		//HEAD ID 4
	IP_FIXTURE_HEAD_ID_5,		//HEAD ID 5
	IP_FIXTURE_HEAD_ID_6		//HEAD ID 6
};


//special strings for results / attributes
#define IP_ATTRIBUTE_SERIALNUMBER				"serialnumber"//"unit_serial_number"			// the FINISHED GOODS serial number
#define IP_ATTRIBUTE_STATIONSOFTWAREVERSION		"softwareversion"//"software_version"
#define IP_ATTRIBUTE_STATIONSOFTWARENAME		"softwarename"//"software_name"
#define IP_ATTRIBUTE_STATIONLIMITSVERSION		"limitsversion"//"limits_version"

/* IP_ATTRIBUTE_STATIONIDENTIFIER define should not be used in IP_addAttribute to set as an attribute, skunk fka InstantPudding does set this attribute automatically */
#define IP_ATTRIBUTE_STATIONIDENTIFIER			"STATION_IDENTIFIER"//"station_id"
/* IP_ATTRIBUTE_STATIONSUBIDENTIFIER define should not be used in IP_addAttribute to set as an attribute, this attribute define is only for DCSD */

#define IP_ATTRIBUTE_STATIONSUBIDENTIFIER		"STATION_SUB_IDENTIFIER"//"sub_station"
#define IP_ATTRIBUTE_BUILD_EVENT				"BUILD_EVENT"			//ex: N82PPVT
#define IP_ATTRIBUTE_BUILD_MATRIX_CONFIG		"BUILD_MATRIX_CONFIG"	//ex: R4
#define IP_ATTRIBUTE_UNIT_NUMBER		 		"unitnumber"			//ex: 120
#define IP_ATTRIBUTE_SPECIAL_BUILD				"S_BUILD"				//ex: N82PPVT_R4_120 ( build_config_unitnumber )

#define IP_ATTRIBUTE_MLBSERIALNUMBER			"MLBSN"					// the BOARD LEVEL serial number
#define IP_ATTRIBUTE_MACADDRESS_WIFI			"WIFI_MAC_ADDR"
#define IP_ATTRIBUTE_MACADDRESS_BT				"BT_MAC_ADDR"
#define IP_ATTRIBUTE_MACADDRESS_ENET			"EOUSB_MAC_ADDR"

#define IP_ATTRIBUTE_BATTERY_SERIAL_NUMBER		"BATTERY_SN"
#define IP_ATTRIBUTE_REGION_CODE				"REGION_CODE"
#define IP_ATTRIBUTE_MPN						"MPN"

#define IP_ATTRIBUTE_IMEI						"IMEI"
#define IP_ATTRIBUTE_BASEBAND_VERSION			"BASEBAND_VERSION"
#define IP_ATTRIBUTE_BOOTCORE_VERSION			"BOOTCORE_VERSION"
#define IP_ATTRIBUTE_OS_BUILD_VERSION			"OS_BUILD_VERSION"
#define IP_ATTRIBUTE_CAMERA_CONFIG				"CAMERA_CONFIG"
#define IP_ATTRIBUTE_ECID						"ECID"

#define IP_ATTRIBUTE_DIAG_DATE					"DIAG_DATE"
#define IP_ATTRIBUTE_DIAG_VERSION				"DIAG_VERSION"
#define IP_ATTRIBUTE_CHIP_SN					"CHIP_SN"

#define IP_ATTRIBUTE_BASEBAND_SN				"BASEBAND_SN"
#define IP_ATTRIBUTE_PRODUCTION_SOC				"PRODUCTION_SOC"
#define IP_ATTRIBUTE_UDID						"UDID"

//very common error strings
#define IP_FAIL_ABOVE_SPEC						"Above spec"
#define IP_FAIL_BELOW_SPEC						"Below spec"
#define IP_FAIL_COMMUNICATION_UUT				"Can't communicate with unit"
#define IP_FAIL_COMMUNICATION_EQUIPMENT			"Can't communicate with test equipment"
#define IP_FAIL_WRITING_NOR						"Failed to write to NOR"
#define IP_FAIL_READING_NOR						"Failed to read from NOR"
#define IP_FAIL_CONTROL_BIT_NOT_SET				"Control bit not set"
#define IP_FAIL_INVALID_SERIAL_NUMBER			"Serial number invalid"
#define IP_FAIL_NO_AUDIO						"No audio from device"


//standard UNIT values

// decibels
#define IP_UNITS_DB			"dB"
#define IP_UNITS_DBV		"dBV"
#define IP_UNITS_DBM		"dBm"
#define IP_UNITS_DBR		"dBr"
#define IP_UNITS_DBW		"dBW"
#define IP_UNITS_DBVPASCAL	"dB(V/Pa)"
#define IP_UNITS_DBPASCALV	"dB(Pa/V)"

// electrical
#define IP_UNITS_VOLTS			"V"
#define IP_UNITS_MILLIVOLTS		"mV"
#define IP_UNITS_WATTS			"W"
#define IP_UNITS_MILLIWATTS		"mW"
#define IP_UNITS_AMPERES		"A"
#define IP_UNITS_MILLIAMPERES	"mA"
#define IP_UNITS_OHMS			"Ohms"
#define IP_UNTIS_MILLIOHMS		"mOhms"
#define IP_UNTIS_KILOOHMS		"kOhms"
#define IP_UNITS_MEGAOHMS		"MOhms"
#define IP_UNITS_RMS			"RMS"

// misc. category
#define IP_UNITS_HZ			"Hz"
#define IP_UNITS_KHZ		"kHz"
#define IP_UNITS_MHZ		"MHz"
#define IP_UNITS_FOOTLBS	"ftLbs"
#define IP_UNITS_PERCENT	"%"

// distances
#define IP_UNITS_MM			"mm"
#define IP_UNITS_INCHES		"inches"
#define IP_UNITS_MILES		"miles"
#define IP_UNITS_PARSECS	"parsecs"
//Misc defines
#define IP_NOVALUE          "NA"

/// PDCA priority definitions
enum IP_PDCA_PRIORITY
{
	IP_PRIORITY_STATION_CALIBRATION_AUDIT	= -2,
	IP_PRIORITY_REALTIME_WITH_ALARMS		= 0,
	IP_PRIORITY_REALTIME					= 1,
	IP_PRIORITY_DELAYED_WITH_DAILY_ALARMS	= 2,
	IP_PRIORITY_DELAYED_IMPORT				= 3,
	IP_PRIORITY_ARCHIVE						= 4,
};
#define IP_PDCA_DEFAULT_PRIORITY IP_PRIORITY_REALTIME_WITH_ALARMS


// Pass/Fail, 2 bits : 31-30
#define IP_MSG_RESULT_OFFSET	31
#define	IP_MSG_RESULT_PASS		0
#define IP_MSG_RESULT_FAIL		1


// message class, 10 bits : 29-20
#define IP_MSG_CLASS_OFFSET		20

// all message classes that we care about
enum IP_MSG_CLASS
{
	IP_MSG_CLASS_UNCLASSIFIED			= 0,
	IP_MSG_CLASS_API_ERROR				= 1,
	IP_MSG_CLASS_COMM_ERR				= 2,	// some kind of communication error
	IP_MSG_CLASS_QUERY					= 4,	// used to initiate a query
	IP_MSG_CLASS_QUERY_RESPONSE			= 8,	// response from a query
	IP_MSG_CLASS_QUERY_DELAYED_RESPONSE	= 16,	// delayed response from a query 
	IP_MSG_CLASS_PROCESS_CONTROL		= 32,
	
	IP_MSG_CLASS_COUNT	// must be the last item in this list (should always be less than 2^10)
};

// reserved, 4 bits: 19 - 16
#define IP_MSG_RESERVED_OFFSET		16

// message identifiers 16 bits : 15-0
#define IP_MSG_IDENTIFIER_OFFSET	0

/// A list of all possible queries
enum IP_QUERY_NUMBER
{
	// queries
	IP_QUERY_AMIOK,			// is Unit 'good to go'?
	IP_QUERY_STATION_SW,	// what is the 'right' software for this unit / station combo? message must contain Unit serial number
	
	IP_QUERY_COUNT			// this must always be the last in the enum

};

enum IP_MSG_NUMBER
{
	// api errors
	IP_MSG_ERROR_API_UNHANDLED,		// unhandled / system exception in catch(...)
	IP_MSG_ERROR_UNIT_ID_INVALID,	// no one has called 'start' or someone called 'done' or 'commit' and is trying to submit more results
	IP_MSG_ERROR_UNIMPLEMENTED,		// API isn't actually there (for some reason)
	IP_MSG_ERROR_API_VERSION,		// API version isn't right (not much resolution here)
	IP_MSG_ERROR_API_SYNTAX,		// API usage isn't right	
	IP_MSG_ERROR_API_NO_ATTRIBUTE,	// API error: attribute does not exist
	IP_MSG_ERROR_FERRET_NOT_RUNNING,	// Pudding hasn't touched its PID file recently
	IP_MSG_ERROR_FILESYSTEM,	
	IP_MSG_ERROR_NETWORK,				// test station <==> servers (PDCA, DCS, GH, etc.)
	IP_MSG_ERROR_INVALID_SERIAL_NUMBER,	// serial number in a bad format
	
	// Data collection AmIOK responses
	IP_MSG_ERROR_DCS_NOT_RESPONDING,	//
	IP_MSG_ERROR_PDCA_NOT_RESPONDING,	//
	IP_MSG_ERROR_GROUNDHOG_NOT_RESPONDING, //
	IP_MSG_ERROR_NETWORK_NOT_RESPONDING, //
	IP_MSG_ERROR_ETHERNET_NOT_RESPONDING, //
	IP_MSG_ERROR_UNIT_OUT_OF_PROCESS,

	IP_MSG_ERROR_INVALID_STATION_TYPE, //
	IP_MSG_ERROR_INVALID_SW_VERSION, //
	IP_MSG_ERROR_INVALID_IP_VERSION, //
	IP_MSG_ERROR_INVALID_FERRET_VERSION, //
	IP_MSG_ERROR_INVALID_GHSTATIONINFO_VALUE,
	
	//Test, sub test, sub sub test name errors
	IP_MSG_ERROR_INVALID_DATA_FORMAT,
	
	// unit AmIOK responses (come down from PDCA, DCS, GH, SFC)
	IP_MSG_UNIT_GOLDEN_UNIT,	// unit is 'golden'
	IP_MSG_UNIT_OUTLIER,		// unit is a statistical outlier
	IP_MSG_UNIT_ESCAPE,			// unit has skipped previous station(s)
	IP_MSG_UNIT_FORCE_FAIL,		// someone is telling you to force this failure
	IP_MSG_UNIT_RECALL,			// Known bad hardware correlated to serial number or behavior
	IP_MSG_UNIT_HOLD,			// Hold this unit for someone (message contains radar# or more info)
	IP_MSG_UNIT_NOT_IN_SFC,		// unit can not be validated from the SFC server

	// responses from queries
	IP_MSG_STATION_SW_MISMATCH,	// your station software ain't right.  The message member contains the version you should be using.
	IP_MSG_STATION_OUTLIER,		// your station is causing a lot of outlier failures. take it offline.
	IP_MSG_ERROR_INVALID_SIGNATURE, //digital signature in gh_station_info.json file is not valid
	IP_MSG_ERROR_INVALID_ATTRIBUTE,
    IP_MSG_ERROR_SFC_QUERY_UNIT,
	IP_MSG_ERROR_UMBRELLA_AMIOKAY,
	IP_MSG_USER,			// put user messages after this one (IP_MSG_USER, IP_MSG_USER+1, +2, +3, etc.)
	
	IP_MSG_COUNT	// this must always be the last in the enum (to determine range of this enum)
};


#ifdef __cplusplus
extern "C" {
#endif

	///a handle that points to an IP_API_Reply object, returned from (almost) all API calls
	typedef void* IP_API_Reply;

	///a handle used to refer to a UUT throughout the API, assigned by IP_UUTStart()
	typedef void* IP_UUTHandle;

	///a handle used to refer to a Test Specification, assigned by IP_testSpec_create()
	typedef void* IP_TestSpecHandle;

	///a handle used to refer to a Test Result, assigned by IP_testResult_create()
	typedef void* IP_TestResultHandle;

	///a handle used to refer to a Query, assigned by IP_query_create()
	typedef void* IP_QueryHandle;


	
	///use this to retrieve the full API version (API + implementation)
	/// return format is PUBLIC(PRIVATE) revision (could be 1(3), 5(5), etc.)
	const char* IP_getVersion( void );
	
	

	// Test cycle functions
	///Opens a new UUT object
	///@param outHandle : the handle to use with every API call that affects this UUT's test status
	IP_API_Reply IP_UUTStart( IP_UUTHandle *outHandle );
	
	///Cancels a UUT (removes all information from the system)
	///@param inHandle : the handle originally returned from IP_UUTStart()
	IP_API_Reply IP_UUTCancel( IP_UUTHandle inHandle );
	
	///Submits the UUT test results to process control
	///@param inHandle : the handle originally returned from IP_UUTStart()
	IP_API_Reply IP_UUTDone( IP_UUTHandle inHandle );
	
	///Commits the UUT test results to the data collection system
	///@param inHandle : the handle originally returned from IP_UUTStart()
	IP_API_Reply IP_UUTCommit( IP_UUTHandle inHandle, enum IP_PASSFAILRESULT inPassFail );
		
	///use this to delete the UID after you have committed its results
	///@param UUTHandle : the handle originally returned from IP_UUTStart()
	void IP_UID_destroy( IP_UUTHandle UUTHandle );

	
		
	// Test result functions
	///Add a result for your UUT
	///@param inHandle : the handle originally returned from IP_UUTStart()
	IP_API_Reply IP_addResult( IP_UUTHandle inHandle, IP_TestSpecHandle testSpec, IP_TestResultHandle testResult );
	
	///Add an attribute for your UUT (such as serial number or station software version)
	///@param inHandle : the handle originally returned from IP_UUTStart()
	IP_API_Reply IP_addAttribute( IP_UUTHandle inHandle, const char* name, const char* value );
	
	
	///Add a blob for your UUT (such as calibration data, or logs)
	///@param inHandle : the handle originally returned from IP_UUTStart()
	///@inBlobName : the name of the blob as it will appear in PDCA
	///@inPathToBlobFile : the aabsolute path to your blob file on-disk
	IP_API_Reply IP_addBlob( IP_UUTHandle inHandle, const char* inBlobName, const char* inPathToBlobFile );
	
	IP_API_Reply IP_addBlobWithPolicy( IP_UUTHandle inHandle, enum IP_ENUM_BLOBPOLICY eIPBlobPolicy, const char* kcpBlobName, 
									  const char* kcpPathToBlobFile );

	///Add a blob for your UUT from a block of memory
	///@param inHandle : the handle originally returned from IP_UUTStart()
	///@inBlobName : the name of the blob as it will appear in PDCA
	///@inBlobPointer : void pointer to your data in memory
	///@inBlobLength : length from inBlobPointer to the end of your blob
	IP_API_Reply IP_addBlobData( IP_UUTHandle inHandle, const char* inBlobName, const void* inBlobPointer, long inBlobLength );
	
	IP_API_Reply IP_addBlobDataWithPolicy( IP_UUTHandle inHandle,enum IP_ENUM_BLOBPOLICY eIPBlobPolicy, const char* kcpBlobName, 
										  const void* kpBlobPointer, long lBlobLength );

	// UUT status functions	
		
	///Submit an AmIOkay query to the process control system
	///@param UUTHandle : the handle originally returned from IP_UUTStart()
	IP_API_Reply IP_amIOkay( IP_UUTHandle inHandle, const char* inUUTSerialNumber );



	///return the error or message/data (if any)
	const char* IP_reply_getError( IP_API_Reply reply );
	
	/// returns the message class of a reply
	///@param replyToCheck : The IP_REPLY to extract the class from
	///@returns IP_MSG_CLASS : The messge class of the IP_REPLY provided
	enum IP_MSG_CLASS IP_reply_getClass( IP_API_Reply replyToCheck );
	
	/// returns true if the class of the IP_REPLY matches
	///@param replyToCheck : The IP_REPLY to extract the class from
	///@param classToCompare : The IP_MSG_FLAG class to compare against the message
	bool IP_reply_isOfClass( IP_API_Reply replyToCheck, IP_MSG_FLAG classToCompare );

	/// returns the numeric message portion of the reply
	///@param replyToChecl : The IP_REPLY to extract the message ID from
	unsigned int IP_reply_getMessageID( IP_API_Reply replyToCheck );

	///use this to delete replies after you are done with them
	///@param reply : the IP_API_Reply handle returned from an API call
	void IP_reply_destroy( IP_API_Reply reply );

	
	
	///returns true if message contains good news
	///@param reply : the IP_API_Reply handle returned from an API call
	bool IP_success( IP_API_Reply reply );
	
	
	
	///create a new testresult pointer (caller needs to delete this later with IP_result_destroy() )
	IP_TestResultHandle IP_testResult_create( void );
	
	///set the 'value' of the TestResult
	///@param testResultHandle : the handle originally returned from IP_testResult_create()
	bool IP_testResult_setResult( void* testResultHandle, enum IP_PASSFAILRESULT result );
	
	///*************** CAUTION PLEASE NOTE************************
	///Call IP_testResult_setValue api ONLY if your test result has parametric values
	///if your test does not have any parametric value, if just pass/fail then DO NOT CALL THIS API
	///set the 'value' of the TestResult
	///@param testResultHandle : the handle originally returned from IP_testResult_create()
	bool IP_testResult_setValue( void* testResultHandle, const char* value, size_t valueLength );
	
	///set the 'value' of the TestResult
	///@param testResultHandle : the handle originally returned from IP_testResult_create()
	bool IP_testResult_setMessage( void* testResultHandle, const char* message, size_t messageLength );

	///use this to delete the testResult after you have used addResult()
	///@param testResultHandle : the handle originally returned from IP_testResult_create()
	void IP_testResult_destroy( IP_TestResultHandle testResultHandle );



	///create a new testspec pointer
	IP_TestSpecHandle IP_testSpec_create( void );

	///set the Test Name
	///@param testSpecHandle : the handle originally returned from IP_testSpec_create()
	bool IP_testSpec_setTestName( IP_TestSpecHandle testSpecHandle, const char* name, size_t nameLength );

	///set the sub Test Name
	///@param testSpecHandle : the handle originally returned from IP_testSpec_create()
	bool IP_testSpec_setSubTestName( IP_TestSpecHandle testSpecHandle, const char* name, size_t nameLength );	

	///set the sub-sub Test name
	///@param testSpecHandle : the handle originally returned from IP_testSpec_create()
	bool IP_testSpec_setSubSubTestName( IP_TestSpecHandle testSpecHandle, const char* name, size_t nameLength );

	///set the test limits	
	///If your parametric measurement has not limits, do not call setLimits, or use NA.
	///@param testSpecHandle : the handle originally returned from IP_testSpec_create()
	bool IP_testSpec_setLimits( IP_TestSpecHandle testSpecHandle,	const char* lowerLimit, size_t lowerLimitLength, 
																	const char* upperLimit, size_t upperLimitLength );

	///set the units that the test result is measured measured in
	///@param testSpecHandle : the handle originally returned from IP_testSpec_create()
	bool IP_testSpec_setUnits( IP_TestSpecHandle testSpecHandle, const char* units, size_t unitsLength );

	///set the PDCA analysis priority for this result
	///@param testSpecHandle : the handle originally returned from IP_testSpec_create()
	bool IP_testSpec_setPriority( IP_TestSpecHandle testSpecHandle, enum IP_PDCA_PRIORITY priority );
	
	///set this item to be a 'non test item' - will only show in TSR and CSV 'Failed Tests' if is a failure
	///@param testSpecHandle : the handle originally returned from IP_testSpec_create()
	bool IP_testSpec_setAsNonTestItem( IP_TestSpecHandle testSpecHandle );

	///use this to delete the testSpec after you have used addResult()
	///@param testSpecHandle : the handle originally returned from IP_testSpec_create()
	void IP_testSpec_destroy( IP_TestSpecHandle testSpecHandle );
	
	///use this to validate your serial number EARLY on.  An invalid serial number will prevent a Done() and a Commit() from succeeding.
	///@param serialNumber : string representation of the unit serial number
	IP_API_Reply IP_validateSerialNumber( IP_UUTHandle inHandle, const char* serialNumber );
	
	///extract the info from gh_station_info.json file and passed back through char ** and strLength
	///validate the length of the char * with strLength. Do not forget the free the memory after using the char *
	IP_API_Reply IP_getGHStationInfo(IP_UUTHandle handleGHStation,enum IP_ENUM_GHSTATIONINFO eGHStationInfo,char** cppValue,size_t *sLength );
	
	///sets the DUT Position provided by the developer
	IP_API_Reply IP_setDUTPosition(IP_UUTHandle handleDUTPosition,enum IP_ENUM_FIXTURE_ID eFixId,enum IP_ENUM_FIXTURE_HEAD_ID eHeadId);
    
    //twin api of the IP_setDUTPosition, instead of enums it takes const char * as arguments
    IP_API_Reply IP_setDUTPos(IP_UUTHandle handleDUTPosition,const char * cpFixId,const char * cpHeadId);

	///getting the json string of results is a 3 step process
	///IP_getJsonResultsObj returns the reply object with string upon success
	///IP_reply_getJsonData can be passed reply object returned from above api to extract the char *
	///call IP_API_destroy to delete the memory else memory will leak
	///this api does not invalidate the internal state-machine
	///IP_getJsonResultsObj can only be called after calling IP_UUTCommit
	///and before IP_UID_destroy
	/*	
	 IP_API_reply replyJson = IP_getJsonResultsObj(UID);
	 
	if(!IP_success(replyJson))
	 {
		std::cout<< IP_reply_getError(replyJson)<<std::endl;
		IP_reply_destroy(replyJson);
	 }
	 else 
	 {
		std::cout<< IP_reply_getJsonData(replyJson )<<std::endl;
		IP_reply_destroy(replyJson);
	 }
	 */
	IP_API_Reply IP_getJsonResultsObj(IP_UUTHandle handleUUT);
	const char* IP_reply_getJsonData( IP_API_Reply reply );

	
	///Use to manually set the start/stop times.  Automatic timestamps will not be used ( usually done through UUTStart() and UUTDone() )
	IP_API_Reply IP_setStartTime( IP_UUTHandle handleStartTime, time_t rawTimeToUse );
	IP_API_Reply IP_setStopTime( IP_UUTHandle handleStopTime, time_t rawTimeToUse );
	
#ifdef __cplusplus
}
#endif

#endif //IP_API_VERSION
