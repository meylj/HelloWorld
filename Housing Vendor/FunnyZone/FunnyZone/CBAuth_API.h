/*
 *  CBAuth_API.h
 *  CBAuth
 *
 *  Created on 9/11/10.
 *  Copyright 2010 Apple Inc. All rights reserved.
 *
 */
#ifndef CBAuth__API__HH__
#define CBAuth__API__HH__

		


#ifdef WIN32
	#define EXPORT __declspec(dllexport)
#else
	#ifndef EXPORT
		#define EXPORT __attribute__((visibility("default")))
	#endif

#endif     //WIN32

#ifdef __OBJC__

	#import <Foundation/Foundation.h>
	EXPORT  unsigned char * CreateSHA1(unsigned char  *aucKey, unsigned char  *aucNounce);
	EXPORT	unsigned char * CreateSHA1File(const char *acpFileName);
	EXPORT	void FreeSHA1Buffer(unsigned char * aucPtr);
	EXPORT  const char * cbauthVersion(void);
	EXPORT	bool ControlBitsToCheck(int *ipControlBitsArray,size_t *sLength, char ** acpControlBitNames );
	EXPORT	bool ControlBitsToClearOnPass(int *ipControlBitsArray,size_t *sLength );
	EXPORT	bool ControlBitsToClearOnFail(int *ipControlBitsArray,size_t *sLength );
	EXPORT	bool StationSetControlBit();
	EXPORT  int  StationFailCountAllowed( void );

	/*new apis for the ccc-eee codes*/		
	
	EXPORT  const char * cbSNGetVersion(void);

	EXPORT 	int GetCountCBsToCheckSN(const char * cpSerialNumber);
	EXPORT	int ControlBitsToCheckSN( const char * cpSerialNumber,int *ipControlBitsArray,size_t *sLength, char ** acpControlBitNames );

	EXPORT 	int GetCountCBsToClearOnPassSN(const char * cpSerialNumber);
	EXPORT	int ControlBitsToClearOnPassSN(const char * cpSerialNumber,int *ipControlBitsArray,size_t *sLength );

	EXPORT 	int GetCountCBsToClearOnFailSN(const char * cpSerialNumber);
	EXPORT	int ControlBitsToClearOnFailSN(const char * cpSerialNumber,int *ipControlBitsArray,size_t *sLength );

	EXPORT	int StationSetControlBitSN(const char * cpSerialNumber);
	EXPORT  int StationFailCountAllowedSN(const char * cpSerialNumber);

	EXPORT  const char * cbGetErrMsg(int errNum);



#else /* __OBJC__ */



#ifdef __cplusplus
	extern "C" {
#else
	#include<stdbool.h>
#endif
		
	/*
	creates a sha1 digest and returns it via allocating memory, after successfully calling it 
	call FreeSHA1Buffer to release the memory else we would have memory leak
	returns NULL if not successfull. aucKey and aucNounce are 20 bytes long, raw data. api also returns 
	20 bytes of raw data.
	*/
	EXPORT	unsigned char * CreateSHA1(unsigned char *aucKey ,unsigned char * aucNounce);

	/*Creates and returns a 160 bit or 20 byte Sha1 digest of a file, given the filename with path
	developer has call FreeSHA1Buffer api to release the memory */
	EXPORT	unsigned char * CreateSHA1File(const char *acpFileName);

	
	/*Call this api to release memory after calling CreateSHA1 api	*/
	EXPORT	void FreeSHA1Buffer(unsigned char * aucPtr);
		
	/* returns version string */
	EXPORT const char * cbauthVersion(void);
		
		
	/*
	 Extract the info from gh_station_info.json file and passed back through int ** and array length
	 validate the length of the array and extract values from ipControlBitsArray. 
	 Do not forget the free the memory after using the int and char arrayy.
	*/
	EXPORT	bool ControlBitsToCheck(int *ipControlBitsArray,size_t *sLength, char ** acpControlBitNames );
	EXPORT	bool ControlBitsToClearOnPass(int *ipControlBitsArray,size_t *sLength );
	EXPORT	bool ControlBitsToClearOnFail(int *ipControlBitsArray,size_t *sLength );
	EXPORT	bool StationSetControlBit();
	EXPORT  int  StationFailCountAllowed( void );
		
/*new apis for the ccc-eee codes*/		
	
	
	EXPORT  const char * cbSNGetVersion(void);
	
	EXPORT 	int GetCountCBsToCheckSN(const char * cpSerialNumber);	
	EXPORT	int ControlBitsToCheckSN( const char * cpSerialNumber,int *ipControlBitsArray,size_t *sLength, char ** acpControlBitNames );

	EXPORT 	int GetCountCBsToClearOnPassSN(const char * cpSerialNumber);
	EXPORT	int ControlBitsToClearOnPassSN(const char * cpSerialNumber,int *ipControlBitsArray,size_t *sLength );
	
	EXPORT 	int GetCountCBsToClearOnFailSN(const char * cpSerialNumber);
	EXPORT	int ControlBitsToClearOnFailSN(const char * cpSerialNumber,int *ipControlBitsArray,size_t *sLength );

	EXPORT	int StationSetControlBitSN(const char * cpSerialNumber);
	EXPORT  int StationFailCountAllowedSN(const char * cpSerialNumber);

	EXPORT  const char * cbGetErrMsg(int errNum);


		

#ifdef __cplusplus
	}
#endif


#endif /* __OBJ__ */
#endif /* CBAuth__API__HH__ */

