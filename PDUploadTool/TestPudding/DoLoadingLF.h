//
//  DoLoadingLF.h
//  TestPudding
//
//  Created by Leehua on 5/7/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//  This file is created for loading library 

#import <Foundation/Foundation.h>
#import "InstantPudding_API.h"

// ======================= PDCA function define ================================
typedef	IP_API_Reply def_IP_UUTStart( IP_UUTHandle *outHandle );
typedef	IP_API_Reply def_IP_UUTCancel( IP_UUTHandle outHandle );
typedef const char* def_IP_getVersion( void );
typedef bool def_IP_success( IP_API_Reply reply );
typedef const char* def_IP_reply_getError( IP_API_Reply reply );
typedef void def_IP_reply_destroy( IP_API_Reply reply );
typedef IP_API_Reply def_IP_addAttribute( IP_UUTHandle inHandle, const char* name, const char* value );
typedef IP_TestSpecHandle def_IP_testSpec_create( void );
typedef bool def_IP_testSpec_setTestName( IP_TestSpecHandle testSpecHandle, const char* name, size_t nameLength );
typedef bool def_IP_testSpec_setSubTestName( IP_TestSpecHandle testSpecHandle, const char* name, size_t nameLength );
typedef bool def_IP_testSpec_setSubSubTestName( IP_TestSpecHandle testSpecHandle, const char* name, size_t nameLength );
typedef bool def_IP_testSpec_setLimits( IP_TestSpecHandle testSpecHandle,	const char* lowerLimit, size_t lowerLimitLength, 
                                       const char* upperLimit, size_t upperLimitLength );
typedef bool def_IP_testSpec_setUnits( IP_TestSpecHandle testSpecHandle, const char* units, size_t unitsLength );
typedef bool def_IP_testSpec_setPriority( IP_TestSpecHandle testSpecHandle, enum IP_PDCA_PRIORITY priority );
typedef IP_TestResultHandle def_IP_testResult_create( void );
typedef bool def_IP_testResult_setResult( void* testResultHandle, enum IP_PASSFAILRESULT result );
typedef bool def_IP_testResult_setValue( void* testResultHandle, const char* value, size_t valueLength );
typedef bool def_IP_testResult_setMessage( void* testResultHandle, const char* message, size_t messageLength );
typedef IP_API_Reply def_IP_addResult( IP_UUTHandle inHandle, IP_TestSpecHandle testSpec, IP_TestResultHandle testResult );
typedef void def_IP_testResult_destroy( IP_TestResultHandle testResultHandle );
typedef void def_IP_testSpec_destroy( IP_TestSpecHandle testSpecHandle );
typedef IP_API_Reply def_IP_addBlob( IP_UUTHandle inHandle, const char* inBlobName, const char* inPathToBlobFile );
typedef IP_API_Reply def_IP_UUTDone( IP_UUTHandle inHandle );
typedef IP_API_Reply def_IP_UUTCommit( IP_UUTHandle inHandle, enum IP_PASSFAILRESULT inPassFail );
typedef IP_API_Reply def_IP_validateSerialNumber( IP_UUTHandle inHandle, const char* serialNumber );
typedef IP_API_Reply def_IP_amIOkay( IP_UUTHandle inHandle, const char* inUUTSerialNumber );
typedef IP_API_Reply def_IP_getGHStationInfo(IP_UUTHandle handleGHStation,enum IP_ENUM_GHSTATIONINFO eGHStationInfo,char** cppValue,size_t *sLength );//Leehua get json file
typedef IP_API_Reply def_IP_setDUTPosition(IP_UUTHandle inHandle,enum IP_ENUM_FIXTURE_ID eFixId,enum IP_ENUM_FIXTURE_HEAD_ID eHeadId);
//typedef IP_API_Reply def_IP_setDUTPosition(IP_UUTHandle inHandle,int eDUTPos);
typedef void def_IP_UID_destroy( IP_UUTHandle UUTHandle );


def_IP_getVersion					*f_IP_getVersion;
def_IP_UUTStart						*f_IP_UUTStart;
def_IP_UUTCancel					*f_IP_UUTCancel;
def_IP_success						*f_IP_success;
def_IP_reply_getError				*f_IP_reply_getError;
def_IP_reply_destroy				*f_IP_reply_destroy;
def_IP_addAttribute					*f_IP_addAttribute;
def_IP_testSpec_create				*f_IP_testSpec_create;
def_IP_testSpec_setTestName			*f_IP_testSpec_setTestName;
def_IP_testSpec_setSubTestName		*f_IP_testSpec_setSubTestName;
def_IP_testSpec_setSubSubTestName	*f_IP_testSpec_setSubSubTestName;
def_IP_testSpec_setLimits			*f_IP_testSpec_setLimits;
def_IP_testSpec_setUnits			*f_IP_testSpec_setUnits;
def_IP_testSpec_setPriority			*f_IP_testSpec_setPriority;
def_IP_testResult_create			*f_IP_testResult_create;
def_IP_testResult_setResult			*f_IP_testResult_setResult;
def_IP_testResult_setValue			*f_IP_testResult_setValue;
def_IP_testResult_setMessage		*f_IP_testResult_setMessage;
def_IP_addResult					*f_IP_addResult;
def_IP_testResult_destroy			*f_IP_testResult_destroy;
def_IP_addBlob						*f_IP_addBlob;
def_IP_UUTDone						*f_IP_UUTDone;
def_IP_UUTCommit					*f_IP_UUTCommit;
def_IP_testSpec_destroy				*f_IP_testSpec_destroy;
def_IP_UID_destroy					*f_IP_UID_destroy;
def_IP_validateSerialNumber			*f_IP_validateSerialNumber;
def_IP_amIOkay						*f_IP_amIOkay;
def_IP_getGHStationInfo             *f_IP_getGHStationInfo;
def_IP_setDUTPosition				*f_IP_setDUTPosition;



@interface DoLoadingLF : NSObject
{
    void								*lib_handle_IP;
}

@end
