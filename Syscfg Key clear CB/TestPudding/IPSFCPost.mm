//
//  IPSFCPost.m
//  FunnyZone
//
//  Created by 漢青 陳 on 12-4-28.
//  Copyright 2012年 PEGATRON. All rights reserved.
//



#import "IPSFCPost.h"
#include <dlfcn.h>



static const char * IPSFC_POST_DYLIB = "/usr/local/lib/libIPSFCPost.dylib";



@implementation IPSFCPost
@synthesize	delegate;



#pragma mark -
#pragma mark ***************************************** Initialize *******************************************
- (id)init
{
    self	= [super init];
    if (self)
	{
        lib_handle	= dlopen(IPSFC_POST_DYLIB , RTLD_LAZY | RTLD_LOCAL);
        if (nil == lib_handle)
            [delegate writeDebugLog:[NSString stringWithFormat:
									 @"[%s Line:%d] Unable to load dylib:[%s] ErrorCode:[%s]",
									 __FILE__,__LINE__,IPSFC_POST_DYLIB,dlerror()]];
		else
		{
            [delegate writeDebugLog:[NSString stringWithFormat:
									 @"[%s Line:%d] Done to load dylib:[%s][%s]",
									 __FILE__,__LINE__,IPSFC_POST_DYLIB,dlerror()]];
            // def __cplusplus
            if (NULL == (f_SFCLibVersion = (_def_SFCLibVersion *)dlsym(lib_handle, "SFCLibVersion")))
                NSLog(@"[%s Line:%d] Unable to load api:[%s] ErrorCode:[%s]",
					  __FILE__,__LINE__,"SFCLibVersion",dlerror());
            else
				NSLog(@"[%s Line:%d] Done to load api:[%s]",
					  __FILE__,__LINE__,"SFCLibVersion");
            if (NULL == (f_SFCServerVersion = (_def_SFCServerVersion *)dlsym(lib_handle, "SFCServerVersion")))
                NSLog(@"[%s Line:%d] Unable to load api:[%s] ErrorCode:[%s]",
					  __FILE__,__LINE__,"SFCServerVersion",dlerror());
            else
				NSLog(@"[%s Line:%d] Done to load api:[%s]",
					  __FILE__,__LINE__,"SFCServerVersion");
            if (NULL == (f_SFCQueryHistory = (_def_SFCQueryHistory *)dlsym(lib_handle, "SFCQueryHistory")))
                NSLog(@"[%s Line:%d] Unable to load api:[%s] ErrorCode:[%s]",
					  __FILE__,__LINE__,"SFCQueryHistory",dlerror());
            else
				NSLog(@"[%s Line:%d] Done to load api:[%s]",
					  __FILE__,__LINE__,"SFCQueryHistory");
            if (NULL == (f_SFCQueryRecordByStationName = (_def_SFCQueryRecordByStationName *)dlsym(lib_handle, "SFCQueryRecordByStationName")))
                NSLog(@"[%s Line:%d] Unable to load api:[%s] ErrorCode:[%s]",
					  __FILE__,__LINE__,"SFCQueryRecordByStationName",dlerror());
            else
				NSLog(@"[%s Line:%d] Done to load api:[%s]",
					  __FILE__,__LINE__,"SFCQueryRecordByStationName");
            if (NULL == (f_SFCQueryRecordByStationID = (_def_SFCQueryRecordByStationID *)dlsym(lib_handle, "SFCQueryRecordByStationID")))
                NSLog(@"[%s Line:%d] Unable to load api:[%s] ErrorCode:[%s]",
                      __FILE__,__LINE__,"SFCQueryRecordByStationID",dlerror());
            else
                NSLog(@"[%s Line:%d] Done to load api:[%s]",
                      __FILE__,__LINE__,"SFCQueryRecordByStationID");
            if (NULL == (f_SFCQueryRecordUnitCheck = (_def_SFCQueryRecordUnitCheck *)dlsym(lib_handle, "SFCQueryRecordUnitCheck")))
                NSLog(@"[%s Line:%d] Unable to load api:[%s] ErrorCode:[%s]",
					  __FILE__,__LINE__,"SFCQueryRecordUnitCheck",dlerror());
            else
				NSLog(@"[%s Line:%d] Done to load api:[%s]",
					  __FILE__,__LINE__,"SFCQueryRecordUnitCheck");
            if (NULL == (f_SFCAddRecord = (_def_SFCAddRecord *)dlsym(lib_handle, "SFCAddRecord")))
                NSLog(@"[%s Line:%d] Unable to load api:[%s] ErrorCode:[%s]",
					  __FILE__,__LINE__,"SFCAddRecord",dlerror());
            else
				NSLog(@"[%s Line:%d] Done to load api:[%s]",
					  __FILE__,__LINE__,"SFCAddRecord");
            if (NULL == (f_SFCAddAttr = (_def_SFCAddAttr *)dlsym(lib_handle, "SFCAddAttr")))
                NSLog(@"[%s Line:%d] Unable to load api:[%s] ErrorCode:[%s]",
					  __FILE__,__LINE__,"SFCAddAttr",dlerror());
            else
				NSLog(@"[%s Line:%d] Done to load api:[%s]",
					  __FILE__,__LINE__,"SFCAddAttr");
            if (NULL == (f_SFCQueryRecord = (_def_SFCQueryRecord *)dlsym(lib_handle, "SFCQueryRecord")))
                NSLog(@"[%s Line:%d] Unable to load api:[%s] ErrorCode:[%s]",
					  __FILE__,__LINE__,"SFCQueryRecord",dlerror());
            else
				NSLog(@"[%s Line:%d] Done to load api:[%s]",
					  __FILE__,__LINE__,"SFCQueryRecord");
            if (NULL == (f_SFCQueryRecordGetTestResult = (_def_SFCQueryRecordGetTestResult *)dlsym(lib_handle, "SFCQueryRecordGetTestResult")))
                NSLog(@"[%s Line:%d] Unable to load api:[%s] ErrorCode:[%s]",
					  __FILE__,__LINE__,"SFCQueryRecordGetTestResult",dlerror());
            else
				NSLog(@"[%s Line:%d] Done to load api:[%s]",
					  __FILE__,__LINE__,"SFCQueryRecordGetTestResult");
            if (NULL == (f_FreeSFCBuffer = (_def_FreeSFCBuffer *)dlsym(lib_handle, "FreeSFCBuffer")))
                NSLog(@"[%s Line:%d] Unable to load api:[%s] ErrorCode:[%s]",
					  __FILE__,__LINE__,"FreeSFCBuffer",dlerror());
            else
				NSLog(@"[%s Line:%d] Done to load api:[%s]",
					  __FILE__,__LINE__,"FreeSFCBuffer");      
        }
        assert(lib_handle);
    }
    return self;
}

- (void)dealloc
{
    if (!lib_handle)
		dlclose(lib_handle);
    [super dealloc];
}

#pragma mark -
#pragma mark ***************************************** Export APIs *******************************************

- (NSInteger)GetSFCLibVersion:(NSMutableString *)sfcLibVersion
{
    // get lib version
    NSString	*outErrorCode	= [NSString stringWithFormat:
								   @"[%s Line:%d] Get SFC Library Version:[SFCLibVersion]",
								   __FILE__,__LINE__];
    NSAssert(lib_handle,outErrorCode);
    lib_exp	= f_SFCLibVersion();
    if (NULL == lib_exp)
	{
        [delegate writeDebugLog:[NSString stringWithFormat:
								 @"[%s Line:%d] Error:Try load ipsfc api:[SFCLibVersion] fail!",
								 __FILE__,__LINE__]];
        return DYLIB_ERROR_LOAD_LIB_API;
    }
    
    [sfcLibVersion setString:[NSString stringWithFormat:@"%s",lib_exp]];
    return DYLIB_SUCCESS;
}


- (NSInteger)GetSFCServerVersion:(NSMutableString *)sfcSerVersion
{
    // get sfc server version
    NSString	*outErrorCode	= [NSString stringWithFormat:
								   @"[%s Line:%d] Get SFC Server Version:[SFCServerVersion]",
								   __FILE__,__LINE__];
    NSAssert(lib_handle,outErrorCode);
    lib_exp	= f_SFCServerVersion();
    if (NULL == lib_exp)
	{
        NSLog(@"[%s Line:%d] Error:Try load ipsfc api:[SFCServerVersion] fail!",
			  __FILE__,__LINE__);
        return DYLIB_ERROR_LOAD_LIB_API;
    }
    
    [sfcSerVersion setString:[NSString stringWithFormat:@"%s",lib_exp]];
    return DYLIB_SUCCESS;
}


- (NSInteger)GetSFCQueryHistory:(NSMutableString *)sfcHistory
			   WithSerialNumber:(NSString *)acpSerialNumber
{
    if (nil == acpSerialNumber)
	{
        NSLog(@"[%s Line:%d] Error:Try to get history without a correct serial number.",
			  __FILE__,__LINE__);
        return DYLIB_ERROR_SERIALNUMBER;
    }
    IPSFC_SerialNumber	= [acpSerialNumber cStringUsingEncoding:NSASCIIStringEncoding];
    
    // get sfc history
    NSString	*outErrorCode	= [NSString stringWithFormat:
								   @"[%s Line:%d] Get SFC Query History:[GetSFCQueryHistory]",
								   __FILE__,__LINE__];
    NSAssert(lib_handle,outErrorCode);
    lib_exp	= f_SFCQueryHistory(IPSFC_SerialNumber);
    if (NULL == lib_exp)
	{
        NSLog(@"[%s Line:%d] Error:Try load ipsfc api:[SFCQueryHistory] fail!",
			  __FILE__,__LINE__);
        return DYLIB_ERROR_LOAD_LIB_API;
    }
    
    [sfcHistory setString:[NSString stringWithFormat:@"%s",lib_exp]];
    return DYLIB_SUCCESS;
}


- (NSInteger)GetSFCQueryRecordByStationName:(NSString *)acpStationName
                               SerialNumber:(NSString *)acpSerialNumber
                                 DataStruct:(NSMutableDictionary *)acpQRStruct
                                       Size:(NSInteger)acpSize
{
    if (nil == acpStationName)
	{
        NSLog(@"[%s Line:%d] Error:Try to get record without a correct station name.",
			  __FILE__,__LINE__);
        return DYLIB_ERROR_STATIONNAME;
    }   
    if (nil == acpSerialNumber)
	{
        NSLog(@"[%s Line:%d] Error:Try to get record without a correct serial number.",
			  __FILE__,__LINE__);
        return DYLIB_ERROR_SERIALNUMBER;
    }
    IPSFC_SerialNumber	= [acpSerialNumber cStringUsingEncoding:NSASCIIStringEncoding];
    IPSFC_StationName	= [acpStationName cStringUsingEncoding:NSASCIIStringEncoding];
    
    NSArray		*structKeys		= [acpQRStruct allKeys];
    int			keys			= [structKeys count];
    QRStruct	**ptr2_QRStruct	= (struct QRStruct **)malloc(keys*sizeof(struct QRStruct *));
    for (int i=0 ; i<keys ; i++)
    {
        ptr2_QRStruct[i]		= new struct QRStruct();
        ptr2_QRStruct[i]->Qkey	= new char[1024];
        ptr2_QRStruct[i]->Qval	= new char[1024];
        
        strcpy(ptr2_QRStruct[i]->Qkey,
               [[structKeys objectAtIndex:i] cStringUsingEncoding:NSASCIIStringEncoding]);
        strcpy(ptr2_QRStruct[i]->Qval,
               [[acpQRStruct objectForKey:[structKeys objectAtIndex:i]] cStringUsingEncoding:NSASCIIStringEncoding]);
    }
    
    // get sfc record with station
    NSString	*outErrorCode	= [NSString stringWithFormat:
                                   @"[%s Line:%d] Query Record By Station Name:[SFCQueryRecordByStationName]",
                                   __FILE__,__LINE__];
    NSAssert(lib_handle,outErrorCode);
    
    lib_errCode	= f_SFCQueryRecordByStationName(IPSFC_SerialNumber,
                                                IPSFC_StationName,
                                                ptr2_QRStruct,
                                                acpSize);
    for (int i=0 ; i<keys ; i++)
    {
        [acpQRStruct setValue:[NSString stringWithFormat:@"%s",ptr2_QRStruct[i]->Qval]
                       forKey:[NSString stringWithFormat:@"%s",ptr2_QRStruct[i]->Qkey]];
        delete [] ptr2_QRStruct[i]->Qkey;
        delete [] ptr2_QRStruct[i]->Qval;
        delete [] ptr2_QRStruct[i];
    }
    free(ptr2_QRStruct);
    if (DYLIB_SUCCESS != lib_errCode)
	{
        NSLog(@"[%s Line:%d] Error:Try load ipsfc api:[SFCQueryRecordByStationName] fail!",
			  __FILE__,__LINE__);
        return DYLIB_ERROR_LOAD_LIB_API;
    }
    
    return DYLIB_SUCCESS;
}


- (NSInteger)GetSFCQueryRecordUnitCheck:(NSMutableString *)sfcRecord
						   SerialNumber:(NSString *)acpSerialNumber
							  StationID:(NSString *)acpStationID{
    if (nil == acpStationID)
	{
        NSLog(@"[%s Line:%d] Error:Try to get record without a correct station ID.",
			  __FILE__,__LINE__);
        return DYLIB_ERROR_STATION_ID;
    }   
    if (nil == acpSerialNumber)
	{
        NSLog(@"[%s Line:%d] Error:Try to get record without a correct serial number.",
			  __FILE__,__LINE__);
        return DYLIB_ERROR_SERIALNUMBER;
    }
    IPSFC_SerialNumber	= [acpSerialNumber cStringUsingEncoding:NSASCIIStringEncoding];
    IPSFC_StationID		= [acpStationID cStringUsingEncoding:NSASCIIStringEncoding];
    
    // get sfc record with units
    NSString	*outErrorCode	= [NSString stringWithFormat:
								   @"[%s Line:%d] Get SFC Query Record Unit Check:[GetSFCQueryRecordUnitCheck]",
								   __FILE__,__LINE__];
    NSAssert(lib_handle,outErrorCode);
    lib_exp	= f_SFCQueryRecordUnitCheck(IPSFC_SerialNumber,IPSFC_StationID);
    if (NULL == lib_exp)
	{
        NSLog(@"[%s Line:%d] Error:Try load ipsfc api:[SFCQueryRecordUnitCheck] fail!",
			  __FILE__,__LINE__);
        return DYLIB_ERROR_LOAD_LIB_API;
    }
    
    [sfcRecord setString:[NSString stringWithFormat:@"%s",lib_exp]];
    return DYLIB_SUCCESS;
}


#pragma mark -
#pragma mark ***************************************** Face dylib APIs *******************************************
- (NSInteger)TrySFCAddRecord:(NSString *)acpSerialNumber
				  DataStruct:(NSDictionary *)acpQRStruct
						Size:(NSInteger)acpSize
{
    if (nil == acpSerialNumber)
	{
        [delegate writeDebugLog:[NSString stringWithFormat:
								 @"[%s Line:%d] Error:Try to add record without a correct serial number.",
								 __FILE__,__LINE__]];
        return DYLIB_ERROR_SERIALNUMBER;
    }
    IPSFC_SerialNumber			= [acpSerialNumber cStringUsingEncoding:NSASCIIStringEncoding];
    
    NSArray		*structKeys		= [acpQRStruct allKeys];
    int			keys			= [structKeys count];
    QRStruct	**ptr2_QRStruct	= (struct QRStruct **)malloc(keys*sizeof(struct QRStruct *));
    for (int i=0 ; i<keys ; i++)
	{
        ptr2_QRStruct[i]		= new struct QRStruct();
        ptr2_QRStruct[i]->Qkey	= new char[1024];
        ptr2_QRStruct[i]->Qval	= new char[1024];
        
        strcpy(ptr2_QRStruct[i]->Qkey ,
			   [[structKeys objectAtIndex:i] cStringUsingEncoding:NSASCIIStringEncoding]);
        strcpy(ptr2_QRStruct[i]->Qval ,
			   [[acpQRStruct objectForKey:[structKeys objectAtIndex:i]] cStringUsingEncoding:NSASCIIStringEncoding]);
    }
    
    // add record to sfc 
    lib_errCode	= f_SFCAddRecord(IPSFC_SerialNumber,ptr2_QRStruct,acpSize);
    for (int i=0 ; i<keys ; i++)
	{
        delete [] ptr2_QRStruct[i]->Qkey;
        delete [] ptr2_QRStruct[i]->Qval;
        delete [] ptr2_QRStruct[i];
    }
//    delete [] ptr2_QRStruct;
    free(ptr2_QRStruct);
    if (DYLIB_SUCCESS != lib_errCode)
	{
        [delegate writeDebugLog:[NSString stringWithFormat:
								 @"[%s Line:%d] Add Record FAIL:[SFCAddRecord] ErrorCode:[%d][%s]",
								 __FILE__,__LINE__,lib_errCode,dlerror()]];
        return DYLIB_ERROR_LOAD_LIB_API;
    }
    
    return DYLIB_SUCCESS;
}


- (NSInteger)TrySFCAddAttr:(NSString *)acpSerialNumber
				DataStruct:(NSDictionary *)acpQRStruct
					  Size:(NSInteger)acpSize
{
    if (nil == acpSerialNumber)
	{
        NSLog(@"[%s Line:%d] Error:Try to add attribute without a correct serial number.",
			  __FILE__,__LINE__);
        return DYLIB_ERROR_SERIALNUMBER;
    }
    IPSFC_SerialNumber			= [acpSerialNumber cStringUsingEncoding:NSASCIIStringEncoding];
    
    NSArray		*structKeys		= [acpQRStruct allKeys];
    int			keys			= [structKeys count];
    QRStruct	**ptr2_QRStruct	= (struct QRStruct **)malloc(keys*sizeof(struct QRStruct *));
    for (int i=0 ; i<keys ; i++)
	{
        ptr2_QRStruct[i]		= new struct QRStruct();
        ptr2_QRStruct[i]->Qkey	= new char[1024];
        ptr2_QRStruct[i]->Qval	= new char[1024];
        
        strcpy(ptr2_QRStruct[i]->Qkey,
			   [[structKeys objectAtIndex:i] cStringUsingEncoding:NSASCIIStringEncoding]);
        strcpy(ptr2_QRStruct[i]->Qval,
			   [[acpQRStruct objectForKey:[structKeys objectAtIndex:i]] cStringUsingEncoding:NSASCIIStringEncoding]);
    }
    
    // add record to sfc 
    lib_errCode	= f_SFCAddAttr(IPSFC_SerialNumber,ptr2_QRStruct,acpSize);
    for (int i=0 ; i<keys ; i++)
	{
        delete [] ptr2_QRStruct[i]->Qkey;
        delete [] ptr2_QRStruct[i]->Qval;
        delete [] ptr2_QRStruct[i];
//		free(ptr2_QRStruct[i]->Qkey);
//		free(ptr2_QRStruct[i]->Qval);
//		free(ptr2_QRStruct[i]);
    }
//    delete [] ptr2_QRStruct;
	free(ptr2_QRStruct);
    if (DYLIB_SUCCESS != lib_errCode)
	{
        [delegate writeDebugLog:[NSString stringWithFormat:
								 @"[%s Line:%d] Add Attribute FAIL:[SFCAddAttr] ErrorCode:[%d][%s]",
								 __FILE__,__LINE__,lib_errCode,dlerror()]];
        return DYLIB_ERROR_LOAD_LIB_API;
    }
    
    return DYLIB_SUCCESS;
}


- (NSInteger)TrySFCQueryRecord:(NSString *)acpSerialNumber
					DataStruct:(NSMutableDictionary *)acpQRStruct
						  Size:(NSInteger)acpSize
{
    if (nil == acpSerialNumber)
	{
        [delegate writeDebugLog:[NSString stringWithFormat:
								 @"[%s Line:%d] Error:Try to add attribute without a correct serial number.",
								 __FILE__,__LINE__]];
        return DYLIB_ERROR_SERIALNUMBER;
    }
    IPSFC_SerialNumber			= [acpSerialNumber cStringUsingEncoding:NSASCIIStringEncoding];
    
    NSArray		*structKeys		= [acpQRStruct allKeys];
    int			keys			= [structKeys count];
    QRStruct	**ptr2_QRStruct = (struct QRStruct **)malloc(keys*sizeof(struct QRStruct *));
    for (int i=0 ; i<keys ; i++)
	{
        ptr2_QRStruct[i]		= new struct QRStruct;
        ptr2_QRStruct[i]->Qkey	= new char[1024];
        ptr2_QRStruct[i]->Qval	= new char[1024];
        
        strcpy(ptr2_QRStruct[i]->Qkey,
			   [[structKeys objectAtIndex:i] cStringUsingEncoding:NSASCIIStringEncoding]);
    }
    
    if (IPSFC_SerialNumber == NULL)
    {
        return DYLIB_ERROR_SERIALNUMBER;
    }
    
    lib_errCode	= f_SFCQueryRecord(IPSFC_SerialNumber, ptr2_QRStruct, keys);
    for (int i=0 ; i<keys ; i++)
	{
        [acpQRStruct setValue:[NSString stringWithFormat:@"%s",ptr2_QRStruct[i]->Qval] 
                       forKey:[NSString stringWithFormat:@"%s",ptr2_QRStruct[i]->Qkey]];
        delete [] ptr2_QRStruct[i]->Qkey;
        delete [] ptr2_QRStruct[i]->Qval;
        delete [] ptr2_QRStruct[i];
    }
//    delete [] ptr2_QRStruct;
	free(ptr2_QRStruct);
    if (DYLIB_SUCCESS != lib_errCode)
	{
        [delegate writeDebugLog:[NSString stringWithFormat:
								 @"[%s Line:%d] Query Record FAIL:[SFCQueryRecord] ErrorCode:[%d][%s]",
								 __FILE__,__LINE__,lib_errCode,dlerror()]];
        return DYLIB_ERROR_LOAD_LIB_API;
    }
    return DYLIB_SUCCESS;
}
- (NSInteger)TrySFCQueryRecordGetTestResult:(NSString *)acpSerialNumber
								StationName:(NSString *)acpStationName
								 DataStruct:(NSMutableDictionary *)acpQRStruct
									   Size:(NSInteger)acpSize
{
    if (nil == acpSerialNumber)
	{
        NSLog(@"[%s Line:%d] Error:Try to query test result without a correct serial number.",
			  __FILE__,__LINE__);
        return DYLIB_ERROR_SERIALNUMBER;
    }
    if (nil == acpStationName) {
        NSLog(@"[%s Line:%d] Error:Try to query test result without a correct station name.",
			  __FILE__,__LINE__);
        return DYLIB_ERROR_STATIONNAME;
    }
    IPSFC_SerialNumber	= [acpSerialNumber cStringUsingEncoding:NSASCIIStringEncoding];
    IPSFC_StationName	= [acpStationName cStringUsingEncoding:NSASCIIStringEncoding];
    
    NSArray		*structKeys		= [acpQRStruct allKeys];
    int			keys			= [structKeys count];
    QRStruct	**ptr2_QRStruct	= (struct QRStruct **)malloc(keys*sizeof(struct QRStruct *));
    for (int i=0 ; i<keys ; i++)
	{
        ptr2_QRStruct[i] = new struct QRStruct;
        ptr2_QRStruct[i]->Qkey = new char[1024];
        ptr2_QRStruct[i]->Qval = new char[1024];
        
        strcpy(ptr2_QRStruct[i]->Qkey,
			   [[structKeys objectAtIndex:i] cStringUsingEncoding:NSASCIIStringEncoding]);
    }
    
    lib_errCode	= f_SFCQueryRecordGetTestResult(IPSFC_SerialNumber,
												IPSFC_StationName,
												ptr2_QRStruct,
												keys);
    for (int i=0 ; i<keys ; i++)
	{
        [acpQRStruct removeAllObjects];
        [acpQRStruct setValue:[NSString stringWithFormat:@"%s",ptr2_QRStruct[i]->Qval] 
                       forKey:[NSString stringWithFormat:@"%s",ptr2_QRStruct[i]->Qkey]];
        delete [] ptr2_QRStruct[i]->Qkey;
        delete [] ptr2_QRStruct[i]->Qval;
        delete [] ptr2_QRStruct[i];
    }
//    delete [] ptr2_QRStruct;
	free(ptr2_QRStruct);
    if (DYLIB_SUCCESS != lib_errCode)
	{
        NSLog(@"[%s Line:%d] SFC Query Record Get Test Result FAIL:[SFCQueryRecordGetTestResul] ErrorCode:[%d][%s]",
			  __FILE__,__LINE__,lib_errCode,dlerror());
        return DYLIB_ERROR_LOAD_LIB_API;
    }
    
    return DYLIB_SUCCESS;
}



@end




