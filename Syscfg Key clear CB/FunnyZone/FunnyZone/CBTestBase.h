//
//  CB_TestBase.h
//  FunnyZone
//
//  Created by Eagle on 9/8/11.
//  Copyright 2011 PEGATRON. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "CBAuth_API.h"
#include <dlfcn.h>



/*The following three functions will return false when : 
 *1.switch in json file is setted as "OFF"
 *2.Not any station need to check or to clear     
 */
typedef	bool		_def_ControlBitsToCheck(int *ipControlBitsArray,
											size_t *sLength,
											char ** acpControlBitNames );
typedef	bool		_def_ControlBitsToClearOnPass(int *ipControlBitsArray,
													size_t *sLength );
typedef	bool		_def_ControlBitsToClearOnFail(int *ipControlBitsArray,
													size_t *sLength );

typedef	bool		_def_StationSetControlBit();
typedef  int		_def_StationFailCountAllowed( void );

/*new apis for the ccc-eee codes*/	
typedef int			_def_GetCountCBsToCheckSN(const char * cpSerialNumber);
typedef int			_def_ControlBitsToCheckSN(const char * cpSerialNumber,
												int *ipControlBitsArray,
												size_t *sLength,
												char ** acpControlBitNames );
typedef int			_def_GetCountCBsToClearOnPassSN(const char * cpSerialNumber);
typedef	int			_def_ControlBitsToClearOnPassSN(const char * cpSerialNumber,
													int *ipControlBitsArray,
													size_t *sLength );
typedef int			_def_GetCountCBsToClearOnFailSN(const char * cpSerialNumber);
typedef	int			_def_ControlBitsToClearOnFailSN(const char * cpSerialNumber,
													int *ipControlBitsArray,
													size_t *sLength );
typedef	int			_def_StationSetControlBitSN(const char * cpSerialNumber);
typedef int			_def_StationFailCountAllowedSN(const char * cpSerialNumber);
typedef const char*	_def_cbSNGetVersion(void);
typedef const char*	_def_cbGetErrMsg(int errNum);

_def_ControlBitsToCheck			*f_CB_ControlBitsToCheck;
_def_ControlBitsToClearOnPass	*f_CB_ControlBitsToClearOnPass;
_def_ControlBitsToClearOnFail	*f_CB_ControlBitsToClearOnFail;

_def_StationSetControlBit		*f_CB_StationSetControlBit;
_def_StationFailCountAllowed	*f_CB_StationFailCountAllowed;

/*new apis for the ccc-eee codes*/
_def_cbSNGetVersion				*f_CB_cbSNGetVersion;
_def_GetCountCBsToCheckSN		*f_CB_GetCountCBsToCheckSN;
_def_ControlBitsToCheckSN		*f_CB_ControlBitsToCheckSN;
_def_GetCountCBsToClearOnPassSN	*f_CB_GetCountCBsToClearOnPassSN;
_def_ControlBitsToClearOnPassSN	*f_CB_ControlBitsToClearOnPassSN;
_def_GetCountCBsToClearOnFailSN	*f_CB_GetCountCBsToClearOnFailSN;
_def_ControlBitsToClearOnFailSN	*f_CB_ControlBitsToClearOnFailSN;
_def_StationSetControlBitSN		*f_CB_StationSetControlBitSN;
_def_StationFailCountAllowedSN	*f_CB_StationFailCountAllowedSN;
_def_cbGetErrMsg				*f_CB_cbGetErrMsg;


@interface CB_LoadLibrary : NSObject
{
    void	*lib;
}
@end

@interface CBTestBase : NSObject
{

}

-(BOOL)ControlBitsToCheck:(NSMutableArray *)aryStationIDsHex
			  stationName:(NSMutableArray *)aryStationNames;
-(BOOL)ControlBitsToClearOnPass:(NSMutableArray *)aryStationIDsHex;
-(BOOL)ControlBitsToClearOnFail:(NSMutableArray *)aryStationIDsHex;
-(BOOL)StationSetControlBit;
-(int)getStationFailCountAllowed;

/*new apis for the ccc-eee codes*/	
-(NSString*)cbSNGetVersion;
-(int)GetCountCBsToCheckSN:(NSString*)szSerialNumber;
-(int)ControlBitsToCheckSN:(NSString*)szSerialNumber
			 stationIDsHex:(NSMutableArray*)aryStationIDsHex
			   stationName:(NSMutableArray*)aryStationNames;
-(int)GetCountCBsToClearOnPassSN:(NSString *)szSerialNumber;
-(int)ControlBitsToClearOnPassSN:(NSString *)szSerialNumber
				   stationIDsHex:(NSMutableArray *)aryStationIDsHex;
-(int)GetCountCBsToClearOnFailSN:(NSString *)szSerialNumber;
-(int)ControlBitsToClearOnFailSN:(NSString *)szSerialNumber
				   stationIDsHex:(NSMutableArray *)aryStationIDsHex;
-(int)StationSetControlBitSN:(NSString *)szSerialNumber;
-(int)StationFailCountAllowedSN:(NSString *)szSerialNumber;
-(NSString *)cbGetErrMsg:(int)errNum;

@end




