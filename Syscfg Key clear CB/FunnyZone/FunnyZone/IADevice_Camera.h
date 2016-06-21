//  IADevice_Camera.h
//  FunnyZone
//
//  Created by Winter on 11/28/11.
//  Copyright 2011 PEGATRON. All rights reserved.



#import "TestProgress.h"



@interface TestProgress (IADevice_Camera)

//2011-12-10 add by Winter
// Combine a serial of hexadecimal datas without "0x".
// Ex:  0x0 : 0x30 0xF4 0x29 0x9F 0x64  
//      0x8 : 0xB4 0x2 0xA 0x81 0x0 0x0
// After combine: 30F4299F64B4020A810000
// Param:
//      NSString **strSourceData     : Numbers Source Data
//      int   iStart           : The start index in these numbers.
//      int   iLast            : The end index in these numbers.
// Return:
//      Actions result
-(BOOL)combineNVMForQT0:(NSString **)strSourceData
			 startIndex:(int)iStart DeleLastIndex:(int)iLast;

//2011-12-10 add by Winter
// Catch useful strings from strReturnValue, and set memories for "FCMB"/"BCMB"
// Param:
//       NSDictionary    *dicContents        : Settings in script
//       NSMutableString *strReturnValue     : Return value
// Return:
//      Actions result
-(NSNumber*)CATCH_NVM_VALUE:(NSDictionary*)dicContents
			   RETURN_VALUE:(NSMutableString*)strReturnValue;

/* combine  string red, green and blue
 * method     : combineVGAsn: ReturnValue
 * abstract   : get values form dicpare ,and combine the values to a string
 * key        : */
- (NSNumber *)combineVGAsn:(NSDictionary *)dicpara
			  RETURN_VALUE:(NSMutableString*)strReturnValue;

// Catch useful strings from strReturnValue, and caculate the "FCMS"/"BCMS"
// Param:
//       NSDictionary    *dicContents        : Settings in script
//       NSMutableString *strReturnValue     : Return value
// Return:
//      Actions result
-(NSNumber*)DOFCMSORBCMS:(NSDictionary*)dicContents
            RETURN_VALUE:(NSMutableString*)strReturnValue;
// Get the Raw data of nvm, devide as array
- (NSArray  *)GET_THENVM_DATA :(NSDictionary *)dicPara;
// Covert from 16 base value to 34 base value
- (NSString *)base16CovertToBase34: (NSString *)szRaw;
/*
 * Compute check digit for Apple serial number. Check digit is appended to end of passed in string.
 * @param serialNumber null terminated serial number to add check digit to. Must contain enough room to append another character. * @return true if serialNumber now has a valid check digit, false if check digit cannot be computed
 */
int addCheckDigit(char *serialNumber);
/*
 * Verify check digit for Apple serial number.
 * @param serialNumber serial number to verify
 * @return true if serialNumber has a valid check digit, false otherwise */
int verifyCheckDigit(const char *serialNumber);
@end




