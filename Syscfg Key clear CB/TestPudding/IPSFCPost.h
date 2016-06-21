//
//  IPSFCPost.h
//  FunnyZone
//
//  Created by 漢青 陳 on 12-4-28.
//  Copyright 2012年 PEGATRON. All rights reserved.
//



#import <Cocoa/Cocoa.h>
#include <stdio.h>



#ifndef writeDebug
#define writeDebug
@protocol writeDebugLog
-(void)writeDebugLog:(NSString *)szFirstParam;
@end
#endif



#ifndef IPSFCPost__API__HH__
#define IPSFCPost__API__HH__
struct QRStruct
{
	char	*Qkey;
	char	*Qval;
};


typedef const char* _def_SFCLibVersion(void);
typedef const char* _def_SFCServerVersion(void);
typedef const char* _def_SFCQueryHistory(const char *acpSerialNumbe);
typedef const char* _def_SFCQueryRecordUnitCheck(const char *acpSerialNumber,
													const char *acpStationID);
typedef int			_def_SFCAddRecord(const char *acpSerialNumber,
										struct QRStruct *apQRStruct[],
										int size);
typedef int			_def_SFCAddAttr(const char * acpSerialNumber,
									struct QRStruct *apQRStruct[],
									int size);
typedef int			_def_SFCQueryRecord(const char * acpSerialNumber,
										struct QRStruct *apQRStruct[],
										int Size);
typedef int			_def_SFCQueryRecordGetTestResult(const char *acpSerialNumber,
														const char *acpTestStationName,
														struct QRStruct *apQRStruct[],
														int size);
typedef int         _def_SFCQueryRecordByStationName(const char *acpSerialNumber,
                                                     const char *acpStationName,
                                                     struct QRStruct *apQRStruct[],
                                                     int    size);
typedef int         _def_SFCQueryRecordByStationID(const char *acpSerialNumber,
                                                   const char *acpTestStationID,
                                                   struct QRStruct *apQRStruct[],
                                                   int    size);

typedef	void		_def_FreeSFCBuffer(const char * cpBuffer);
#endif



typedef int			ErrCode;
typedef const char*	QRType;

#define DYLIB_SUCCESS               0
#define DYLIB_ERROR_SERIALNUMBER    1
#define DYLIB_ERROR_STATIONNAME     2
#define DYLIB_ERROR_STATION_ID      3
#define DYLIB_ERROR_Parameter       4
#define DYLIB_ERROR_LOAD_LIB        5
#define DYLIB_ERROR_LOAD_LIB_API    6



@interface IPSFCPost : NSObject
{
    
    void								*lib_handle;
    
    _def_SFCLibVersion					*f_SFCLibVersion;
    _def_SFCServerVersion				*f_SFCServerVersion;
    _def_SFCQueryHistory				*f_SFCQueryHistory;
    _def_SFCQueryRecordByStationName	*f_SFCQueryRecordByStationName;
    _def_SFCQueryRecordByStationID      *f_SFCQueryRecordByStationID;
    _def_SFCQueryRecordUnitCheck		*f_SFCQueryRecordUnitCheck;
    _def_SFCAddRecord					*f_SFCAddRecord;
    _def_SFCAddAttr						*f_SFCAddAttr;
    _def_SFCQueryRecord					*f_SFCQueryRecord;
    _def_SFCQueryRecordGetTestResult	*f_SFCQueryRecordGetTestResult;
    _def_FreeSFCBuffer					*f_FreeSFCBuffer;
    
    const char							*lib_exp;
    int									lib_errCode;
    
    const char							*IPSFC_SerialNumber;
    const char							*IPSFC_StationName;
    const char							*IPSFC_StationID;
    const char							*IPSFC_Parameter;
    
    id<writeDebugLog>					delegate;

    
}
#pragma mark -
#pragma mark ***************************************** Export APIs *******************************************
- (NSInteger)GetSFCLibVersion:(NSMutableString *)sfcLibVersion;
- (NSInteger)GetSFCServerVersion:(NSMutableString *)sfcSerVersion;
- (NSInteger)GetSFCQueryHistory:(NSMutableString *)sfcHistory
			   WithSerialNumber:(NSString *)acpSerialNumber;
- (NSInteger)GetSFCQueryRecordByStationName:(NSString *)acpStationName
                               SerialNumber:(NSString *)acpSerialNumber
                                 DataStruct:(NSMutableDictionary *)acpQRStruct
                                       Size:(NSInteger)acpSize;
- (NSInteger)GetSFCQueryRecordUnitCheck:(NSMutableString *)sfcRecord
						   SerialNumber:(NSString *)acpSerialNumber
							  StationID:(NSString *)acpStationID;
- (NSInteger)TrySFCAddRecord:(NSString *)acpSerialNumber
				  DataStruct:(NSDictionary *)acpQRStruct
						Size:(NSInteger)acpSize;
- (NSInteger)TrySFCAddAttr:(NSString *)acpSerialNumber
				DataStruct:(NSDictionary *)acpQRStruct
					  Size:(NSInteger)acpSize;
- (NSInteger)TrySFCQueryRecord:(NSString *)acpSerialNumber
					DataStruct:(NSMutableDictionary *)acpQRStruct
						  Size:(NSInteger)acpSize;
- (NSInteger)TrySFCQueryRecordGetTestResult:(NSString *)acpSerialNumber
								StationName:(NSString *) acpStationName
								 DataStruct:(NSMutableDictionary *)acpQRStruct
									   Size:(NSInteger)acpSize;
#pragma mark ***************************************** Export APIs *******************************************



@property (assign) id<writeDebugLog> delegate;//define a property , can use get and set



@end




