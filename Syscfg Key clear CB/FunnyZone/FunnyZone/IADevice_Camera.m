//  IADevice_Camera.m
//  FunnyZone
//
//  Created by Winter on 11/28/11.
//  Copyright 2011 PEGATRON. All rights reserved.



#import "IADevice_Camera.h"
#include "IADevice_SFIS.h"



@implementation TestProgress (IADevice_Camera)

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
			 startIndex:(int)iStart DeleLastIndex:(int)iLast
{
    *strSourceData	= [*strSourceData stringByReplacingOccurrencesOfString:@"\r"
															   withString:@""];
	NSArray			*arrCell	= [*strSourceData componentsSeparatedByString:@"\n"];
	NSMutableArray	*aryTemp	= [[NSMutableArray alloc] init];
	for (int i = 0; i< [arrCell count]; i++)
	{
		NSString	*strCell	= [arrCell objectAtIndex:i];
		NSRange		range		= [strCell rangeOfString:@" : "];
		if (NSNotFound != range.location
			&& range.length > 0
			&& (range.location + range.length) <= [strCell length])
		{
			NSString	*strTemp	=[strCell substringFromIndex:(range.location
																  + range.length)];
			NSArray		*arrayUnit	= [strTemp componentsSeparatedByString:@" "];
			for (int iIndex = 0; iIndex < [arrayUnit count]; iIndex++)
				[aryTemp addObject:[arrayUnit objectAtIndex:iIndex]];
		}
	}
	if (iStart + iLast > [aryTemp count])
    {
        [aryTemp release];
        return NO;
    }
    NSMutableString	*strCamera	= [[NSMutableString alloc] initWithString:@""];
	for (int i = iStart; i < [aryTemp count] - iLast; i++)
	{
		NSString	*strData	= [aryTemp objectAtIndex:i];
        strData	= (([strData length] == 4)
				   ? [strData stringByReplacingOccurrencesOfString:@"0x"
														withString:@""]
				   : [strData stringByReplacingOccurrencesOfString:@"x"
														withString:@""]);
        [strCamera appendString:strData];
	}
	*strSourceData	= [NSString stringWithString:strCamera];
    ATSDebug(@"strSourceData value is %@",
			 *strSourceData);
	[aryTemp release];
    [strCamera release];
	return YES;
}

//2011-12-10 add by Winter
// Catch useful strings from strReturnValue, and set memories for "FCMB"/"BCMB"
// Param:
//       NSDictionary    *dicContents        : Settings in script
//       NSMutableString *strReturnValue     : Return value
// Return:
//      Actions result
-(NSNumber*)CATCH_NVM_VALUE:(NSDictionary*)dicContents
			   RETURN_VALUE:(NSMutableString*)strReturnValue
{
	BOOL		bResult			=YES;
    NSString	*szKey			= [dicContents objectForKey:kFZ_Script_MemoryKey];
    NSString	*szCameraKey	= [dicContents objectForKey:@"CAMERAKEY"];
    NSString	*szCatchedValue	= [m_dicMemoryValues objectForKey:szKey];
    if ([szCameraKey isEqualToString:@"FCMB"]) 
    {
        if ([szCatchedValue ContainString:@"Sensor channel 1 detected :"])
		{
            szCatchedValue	= [szCatchedValue SubFrom:@"Sensor channel 1 detected :"
											 include:NO];
            if ([szCatchedValue ContainString:@"NVM Data 1024 bytes :"]
				&& [szCatchedValue ContainString:@"0x20 :"])
            {
                szCatchedValue	= [szCatchedValue SubFrom:@"NVM Data 1024 bytes :"
												 include:NO];
                szCatchedValue	= [szCatchedValue SubTo:@"0x20 :"
											   include:NO];
                bResult			&= [self combineNVMForQT0:&szCatchedValue
										 startIndex:0
									  DeleLastIndex:0];
                ATSDebug(@"strFrontCameraTemp is %@", szCatchedValue);
                [m_dicMemoryValues setObject:szCatchedValue
									  forKey:@"FCMB"];
            }
            else
            {
                ATSDebug(@"NVM format error");
                [strReturnValue setString: @"NVM format Error"];
                return [NSNumber numberWithBool:NO];
            }
        }
        else
        {
            ATSDebug(@"NVM format error");
            [strReturnValue setString:@"NVM format Error"];
            return [NSNumber numberWithBool:NO];
        }
    }
#ifndef N61_Project
#define N61_Project 1
#endif
#if N61_Project
    else if ([szCameraKey isEqualToString:@"BCMB"])
    {
        if ([szCatchedValue ContainString:@"Sensor channel 0 detected :"])
		{
            szCatchedValue	= [szCatchedValue SubFrom:@"Sensor channel 0 detected :"
											 include:NO];
            if ([szCatchedValue ContainString:@"0x0 :"]
				&& [szCatchedValue ContainString:@"0x18 :"])
            {
                szCatchedValue	= [szCatchedValue SubFrom:@"0x0 :"
												 include:YES];
                szCatchedValue	= [szCatchedValue SubTo:@"0x18 :"
											   include:NO];
                bResult			&= [self combineNVMForQT0:&szCatchedValue
										 startIndex:0
									  DeleLastIndex:0];
                ATSDebug(@"strBackCameraTemp is %@", szCatchedValue);
                [m_dicMemoryValues setObject:szCatchedValue
									  forKey:@"BCMB"];
            }
            else
            {
                ATSDebug(@"NVM format error");
                [strReturnValue setString: @"NVM format Error"];
                return [NSNumber numberWithBool:NO];
            }
        }
        else
        {
            ATSDebug(@"NVM format error");
            [strReturnValue setString: @"NVM format Error"];
            return [NSNumber numberWithBool:NO];
        }
    }
#else
    else if ([szCameraKey isEqualToString:@"BCMB"])
    {
        if ([szCatchedValue ContainString:@"Sensor channel 0 detected :"])
		{
            szCatchedValue	= [szCatchedValue SubFrom:@"Sensor channel 0 detected :"
											 include:NO];
            if ([szCatchedValue ContainString:@"0x0 :"]         // from 10 to 0
				&& [szCatchedValue ContainString:@"0x20 :"])    // from 30 to 20
            {
                szCatchedValue	= [szCatchedValue SubFrom:@"0x0 :"
												 include:YES];
                szCatchedValue	= [szCatchedValue SubTo:@"0x20 :"
											   include:NO];
                bResult			&= [self combineNVMForQT0:&szCatchedValue
										 startIndex:2
									  DeleLastIndex:7];
                ATSDebug(@"strBackCameraTemp is %@", szCatchedValue);
                [m_dicMemoryValues setObject:szCatchedValue
									  forKey:@"BCMB"];
            }
            else
            {
                ATSDebug(@"NVM format error");
                [strReturnValue setString: @"NVM format Error"];
                return [NSNumber numberWithBool:NO];
            }
        }
        else
        {
            ATSDebug(@"NVM format error");
            [strReturnValue setString: @"NVM format Error"];
            return [NSNumber numberWithBool:NO];
        }
    }
#endif
    else
    {
        ATSDebug(@"Get the wrong key!");
        return [NSNumber numberWithBool:NO];
    }
    return [NSNumber numberWithBool:bResult];
}

// Get the Raw data of nvm, devide as array
- (NSArray  *)GET_THENVM_DATA :(NSDictionary *)dicPara
{
    NSString	*szValue;
    NSArray		*arrData;
    NSRange		rangeFrontStart;
    NSRange		rangeFrontEnd;
    NSRange		rangeBackStart;
    NSRange		rangeBackEnd;
    
    //get the camera type (front/back)
    NSString    *szCameraKey = [dicPara objectForKey:@"CAMERAKEY"];
    //get the raw data
    NSString    *szCatchedValue = [dicPara objectForKey:@"RAWDATA"];
    
    if ([szCameraKey isEqualToString:@"FCMS"])
    {
        rangeFrontStart	= [szCatchedValue rangeOfString:@"Sensor channel 1 detected :"];
		if (rangeFrontStart.location == NSNotFound
			|| rangeFrontStart.length <=0)
		{
			ATSDebug(@"Front NVM Data Missing!");
            return nil;
		}
		szValue	= [szCatchedValue substringFromIndex:(rangeFrontStart.location
                                                      + rangeFrontStart.length)];
		rangeFrontEnd	= [szValue rangeOfString:@"0x400 :"];  
		if (rangeFrontEnd .location == NSNotFound
			|| rangeFrontEnd.length <= 0)
		{
            ATSDebug(@"Front NVM Format Error!");
            return nil;
		}
		szValue			= [szValue substringToIndex:rangeFrontEnd.location];
		rangeFrontStart	= [szValue rangeOfString:@"NVM Data 1024 bytes : "];   
		if(rangeFrontStart.location == NSNotFound
		   || rangeFrontStart.length <= 0 )
		{
			ATSDebug(@"Front NVM Format Error!");
            return nil;
		}
		szValue	= [szValue substringFromIndex:(rangeFrontStart.location
											   + rangeFrontStart.length)];
    }
    else if ([szCameraKey isEqualToString:@"BCMS"])
    {
        rangeBackStart	= [szCatchedValue rangeOfString:@"Sensor channel 0 detected :"];
        if (rangeBackStart.location == NSNotFound
			|| rangeBackStart.length<=0)
        {
            ATSDebug(@"Back NVM Data Missing!");
            return nil;
        }
        szValue	= [szCatchedValue substringFromIndex:(rangeBackStart.location
                                                      + rangeBackStart.length)];
        rangeBackEnd	= [szValue rangeOfString:@"0xC00 :"];
        if (rangeBackEnd.location == NSNotFound
			|| rangeBackEnd.length<=0)
        {
            ATSDebug(@"Back NVM Format Error!");
            return nil;
        }
        [szValue substringToIndex:rangeBackEnd.location];
        rangeBackStart	= [szValue rangeOfString:@"NVM Data 3072 bytes :"];   
        if(rangeBackStart.location == NSNotFound
		   || rangeBackStart.length <=0 )
        {
            ATSDebug(@"Back NVM Format Error!");
            return nil;
        }
        szValue	= [szValue substringFromIndex:(rangeBackStart.location
											   + rangeBackStart.length)];
    }
    else
    {
        ATSDebug(@"You must decide to  one sensor!");
        return nil;
    }
    
    // devide the raw data into array
    arrData	= [self DealWithNVMData:szValue];
    return arrData;
}

// Catch useful strings from strReturnValue, and caculate the "FCMS"/"BCMS"
// Param:
//       NSDictionary    *dicContents        : Settings in script
//       NSMutableString *strReturnValue     : Return value
// Return:
//      Actions result
-(NSNumber*)DOFCMSORBCMS:(NSDictionary*)dicContents
			RETURN_VALUE:(NSMutableString*)strReturnValue
{
 	BOOL            bResult			= YES;
    NSString        *szKey			= [dicContents objectForKey:kFZ_Script_MemoryKey];
    NSString        *szCameraKey	= [dicContents objectForKey:@"CAMERAKEY"];
    NSString        *szCatchedValue	= [m_dicMemoryValues objectForKey:szKey];
    // Plant code table
    NSDictionary    *dicPlantCode	= [dicContents objectForKey:@"PLANTCODE"];
    // Config code table
    NSDictionary    *dicConfigCode	= [dicContents objectForKey:@"CONFIGCODE"];
    
    // get the data array
    NSDictionary    *dicPara		= [NSDictionary dictionaryWithObjectsAndKeys:
									   szCameraKey,		@"CAMERAKEY",
									   szCatchedValue,	@"RAWDATA", nil];
    NSArray			*arrdata		= [self GET_THENVM_DATA:dicPara];
    NSString		*szValue		= @"nil";
    NSScanner		*scanner;
    
    // the memory the FCMS/BCMS
    NSMutableString	*mlstrSerial	= [[NSMutableString alloc] init];
    
    if (!arrdata || ([arrdata count] < 1024))
    {
        ATSDebug(@"NVM DATA LOSE!");
		[mlstrSerial release];	mlstrSerial	= nil;
        return [NSNumber numberWithBool:NO];
    }
    if ([szCameraKey isEqualToString:@"FCMS"])
    {
        // 1, get the plant code from nvm then convert it
        szValue	= [arrdata objectAtIndex:2];   // 0x002[7:0]
        unsigned int iValue = 0;
        scanner	= [NSScanner scannerWithString:szValue];
        [scanner scanHexInt:&iValue];
        iValue	&= 0xff;
        szValue	= [NSString stringWithFormat:@"%X", iValue];
		
		if ([[dicPlantCode objectForKey:szValue] isKindOfClass:[NSDictionary class]])
		{
			NSString *strConfigNumber = [arrdata objectAtIndex:17];
			szValue = [[dicPlantCode objectForKey:szValue] objectForKey:strConfigNumber];
		}
		else
			szValue = [dicPlantCode objectForKey:szValue];
        
        [mlstrSerial appendString:(szValue ? szValue : @"OOO")];
        NSString	*szPlantCode	= [NSString stringWithFormat:
									   @"%@", (szValue ? szValue : @"NULL")];
        ATSDebug(@"plant code is %@",szPlantCode);
        
        // 2, get the Supplier (YWWD)
        szValue = [arrdata objectAtIndex:18];    // Y: 0x012[3:0]
        scanner	= [NSScanner scannerWithString:szValue];
        [scanner scanHexInt:&iValue];
        iValue	&= 0x0f;
        szValue = [NSString stringWithFormat:@"%d", iValue];
        [mlstrSerial appendString:(szValue ? szValue : @"O")];
        ATSDebug(@"Y is %@",(szValue ? szValue : @"O"));
        
        szValue = [arrdata objectAtIndex:19];    // WW: 0x013[5:0]
        scanner	= [NSScanner scannerWithString:szValue];
        [scanner scanHexInt:&iValue];
        iValue	&= 0x3f;
        szValue = (iValue >= 10
				   ? [NSString stringWithFormat:@"%d", iValue]
				   : [NSString stringWithFormat:@"0%d", iValue]);     // 01~53
        [mlstrSerial appendString:(szValue ? szValue : @"OO")];
        ATSDebug(@"WW is %@",(szValue ? szValue : @"OO"));
        
        szValue = [arrdata objectAtIndex:20];    // D: 0x014[2:0]
        scanner	= [NSScanner scannerWithString:szValue];
        [scanner scanHexInt:&iValue];
        iValue	&= 0x07;
        szValue = [NSString stringWithFormat:@"%d", iValue];
        [mlstrSerial appendString:(szValue ? szValue : @"O")];
        ATSDebug(@"D is %@",(szValue ? szValue : @"O"));
        
        // 3, get the Sequence Number
        szValue = [NSString stringWithFormat:@"%@%@%@",
				   [arrdata objectAtIndex:23],
				   [arrdata objectAtIndex:22],
				   [arrdata objectAtIndex:21]];    //0x017[23:16] 0x016[15:8] 0x015[7:0]
        
        NSMutableDictionary	*dictConvertion		= [[NSMutableDictionary alloc] init];
        NSMutableString		*szMutableCameraSN	= [[NSMutableString alloc]
                                                   initWithString:szValue];
        [dictConvertion setObject:[NSNumber numberWithInt:16]
                           forKey:@"CHANGE"];
        [dictConvertion setObject:[NSNumber numberWithInt:34]
                           forKey:@"TO"];
        [dictConvertion setObject:[NSNumber numberWithInt:4]
                           forKey:@"PLACE"];
        if (![self NumberSystemConvertion:dictConvertion
                             RETURN_VALUE:szMutableCameraSN])
        {
            ATSDebug(@"Catch wrong value,please check!");
            [strReturnValue setString:@"Catch wrong value,please check"];
			[mlstrSerial release];	mlstrSerial	= nil;
            [szMutableCameraSN release];
            [dictConvertion release];
            return [NSNumber numberWithBool:NO];
        }
        [mlstrSerial appendString:(szMutableCameraSN ? szMutableCameraSN : @"OOOO")];
        ATSDebug(@"Sequence Number is %@",(szMutableCameraSN ? szMutableCameraSN : @"OOOO"));
        [szMutableCameraSN release];
        [dictConvertion release];
        
        
        // 4, get the config (EEEER)
		// Mapping the EEEE.
        NSString	*szConfigCode	= [dicConfigCode objectForKey:szPlantCode];
        
		// Calculate the R.
        szValue = [arrdata objectAtIndex:17];	//0x011[7:0] but the [4:0] decide the 'R'
        scanner	= [NSScanner scannerWithString:szValue];
        [scanner scanHexInt:&iValue];
        iValue %= 10;
        szValue	= [NSString stringWithFormat:@"%@%X",
				   (szConfigCode ? szConfigCode : @"OOOO"), iValue];
        [mlstrSerial appendString:szValue];
        ATSDebug(@"EEEER is %@",szValue);
        
        // 5, to caculate and verify the checksum
        const char	*SerialConst	= [mlstrSerial UTF8String];
        char		Serial[20];
        strcpy(Serial, SerialConst);
        int	iAdd	= addCheckDigit(Serial);
        int iVerify	= verifyCheckDigit(Serial);
        if (iAdd && iVerify)
            [mlstrSerial setString:[NSString stringWithUTF8String:Serial]];
        [m_dicMemoryValues setObject:mlstrSerial
							  forKey:@"front_nvm_barcode(unit)"];  // change keyname from "front_nvm_barcode" to "front_nvm_barcode(unit)"
        [strReturnValue setString:[NSString stringWithFormat:
                                   @"front_nvm_barcode(unit) is %@",mlstrSerial]];
    }
    else if ([szCameraKey isEqualToString:@"BCMS"])
    {

        // 1, get the plant code from nvm then convert it
        unsigned int iValue = 0;
        scanner	= [NSScanner scannerWithString:szValue];
        
        szValue = [m_dicMemoryValues objectForKey:[dicContents objectForKey:@"PLANTCODE_KEY"]];
        szValue = [dicPlantCode objectForKey:szValue];
        [mlstrSerial appendString:(szValue ? szValue : @"OOO")];
        NSString	*szPlantCode	= [NSString stringWithFormat:
									   @"%@", (szValue ? szValue : @"NULL")];
        ATSDebug(@"plant code is %@",szPlantCode);
    
        // 2, get the Supplier (YWWD)
        szValue = [arrdata objectAtIndex:19];    // Y: 0x013[3:0]
        scanner	= [NSScanner scannerWithString:szValue];
        [scanner scanHexInt:&iValue];
        iValue	&= 0x0f;
        szValue = [NSString stringWithFormat:@"%d", iValue];
        [mlstrSerial appendString:(szValue ? szValue : @"O")];
        ATSDebug(@"Y is %@",(szValue ? szValue : @"O"));
        
        szValue = [arrdata objectAtIndex:20];    // WW: 0x014[5:0]
        scanner	= [NSScanner scannerWithString:szValue];
        [scanner scanHexInt:&iValue];
        iValue	&= 0x3f;
        szValue = (iValue >= 10
				   ? [NSString stringWithFormat:@"%d", iValue]
				   : [NSString stringWithFormat:@"0%d", iValue]);     // 01~53
        [mlstrSerial appendString:(szValue ? szValue : @"OO")];
        ATSDebug(@"WW is %@",(szValue ? szValue : @"O0"));
        
        szValue = [arrdata objectAtIndex:21];    // D: 0x015[2:0]
        scanner	= [NSScanner scannerWithString:szValue];
        [scanner scanHexInt:&iValue];
        iValue	&= 0x07;
        szValue = [NSString stringWithFormat:@"%d", iValue];
        [mlstrSerial appendString:(szValue ? szValue : @"O")];
        ATSDebug(@"D is %@",(szValue ? szValue : @"O"));
        
        // 3, get the Sequence Number
        szValue = [NSString stringWithFormat:@"%@%@%@",
				   [arrdata objectAtIndex:24],
				   [arrdata objectAtIndex:23],
				   [arrdata objectAtIndex:22]];    //0x018[23:16] 0x017[15:8] 0x016[7:0]
        
        NSMutableDictionary	*dictConvertion		= [[NSMutableDictionary alloc] init];
        NSMutableString		*szMutableCameraSN	= [[NSMutableString alloc]
                                                   initWithString:szValue];
        [dictConvertion setObject:[NSNumber numberWithInt:16]
                           forKey:@"CHANGE"];
        [dictConvertion setObject:[NSNumber numberWithInt:34]
                           forKey:@"TO"];
        [dictConvertion setObject:[NSNumber numberWithInt:4]
                           forKey:@"PLACE"];
        if (![self NumberSystemConvertion:dictConvertion
                             RETURN_VALUE:szMutableCameraSN])
        {
            ATSDebug(@"Catch wrong value,please check!");
            [strReturnValue setString:@"Catch wrong value,please check"];
			[mlstrSerial release];	mlstrSerial	= nil;
            [szMutableCameraSN release];
            [dictConvertion release];
            return [NSNumber numberWithBool:NO];
        }
        [mlstrSerial appendString:(szMutableCameraSN ? szMutableCameraSN : @"OOOO")];
        ATSDebug(@"SSSS is %@",(szMutableCameraSN ? szMutableCameraSN : @"OOOO"));
        [szMutableCameraSN release];
        [dictConvertion release];
        
        
        // 4. Get EEEER code
        NSString    *strKeys;
        strKeys = [NSString stringWithFormat:@"%@_%@",
                   szPlantCode,
                   [m_dicMemoryValues objectForKey:[dicContents objectForKey:@"PLANTCODE_KEY"]]];
        NSString * strEEEER = [dicConfigCode objectForKey:strKeys];
        if (strEEEER)
        {
            [mlstrSerial appendString:strEEEER];
        }
        else
        {
			[mlstrSerial release]; mlstrSerial = nil;
            ATSDebug(@"Can't find [%@] EEEER maintained in mapping table %@. Please check it.",strKeys,[dicConfigCode objectForKey:@"CONFIGCODE"]);
            [strReturnValue setString:[NSString stringWithFormat:@"EEEER can't be find coz %@ not in mapping table",strKeys]];
            return [NSNumber numberWithBool:NO];
        }
  
        
        // 5, to caculate and verify the checksum
        const char	*SerialConst	= [mlstrSerial UTF8String];
        char		Serial[20];
        strcpy(Serial, SerialConst);
        int iAdd = addCheckDigit(Serial);
        int iVerify = verifyCheckDigit(Serial);
        if (iAdd && iVerify)
            [mlstrSerial setString:[NSString stringWithUTF8String:Serial]];
        [m_dicMemoryValues setObject:mlstrSerial
							  forKey:@"back_nvm_barcode(unit)"]; // change keyname from "back_nvm_barcode" to "back_nvm_barcode(unit)"
        [strReturnValue setString:[NSString stringWithFormat:@"back_nvm_barcode(unit) is %@",mlstrSerial]];
    }
    else
    {
        ATSDebug(@"Get the wrong key!");
		[mlstrSerial release];	mlstrSerial	= nil;
        return [NSNumber numberWithBool:NO];
    }
    
    // basic camera sn rule judge
    if ([mlstrSerial length] < 17
		|| [mlstrSerial ContainString:@"O"])
        bResult	= NO;
    
	[mlstrSerial release];	mlstrSerial	= nil;
    return [NSNumber numberWithBool:bResult];
}

/* combine  string red, green and blue
 * method     : combineVGAsn: ReturnValue
 * abstract   : get values form dicpare ,and combine the values to a string
 * key        : */
- (NSNumber *)combineVGAsn:(NSDictionary *)dicpara
			  RETURN_VALUE:(NSMutableString*)strReturnValue
{
	int	iCount	= [dicpara count];
	if ([dicpara valueForKey :@"symbol"] != nil) 
	{
		if([[dicpara valueForKey :@"symbol"] isEqualToString:@"RGB"])
		{
            NSMutableString	*szVGAsn	= [[NSMutableString alloc]
										   initWithString:@"0x"];
			iCount--;
			for(int i=0; i<iCount; i++)
			{
				NSString	*key		= [NSString stringWithFormat:@"item%d",i];
				NSString	*keyName	= [dicpara valueForKey:key];
				NSString	*partVGA	=[m_dicMemoryValues valueForKey:keyName];
				[szVGAsn appendFormat:@"%@/", partVGA ];
			}
            ATSDebug(@"RGB value : %@", szVGAsn);
            [strReturnValue setString:[NSString stringWithString:szVGAsn]];
            [szVGAsn release];
			return [NSNumber numberWithBool:YES];
		}	
		else 
		{
            [strReturnValue setString:@"symbol error!"];
			return [NSNumber numberWithBool:NO];
		}
	}
    return [NSNumber numberWithBool:YES];
}

// Covert from 16 base value to 34 base value
// 1015A0 -> STVA
- (NSString *)base16CovertToBase34: (NSString *)szRaw
{
    char    ch[34] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'};
    NSScanner   *scanner;
    unsigned    int iValue = 0;
    char    a[20], d[20];
    int     b = 0, n = 0;
    int     ac;
    static  unsigned int base = 34;
    NSString            *szRet;
    scanner	= [NSScanner scannerWithString:szRaw];
    [scanner scanHexInt:&iValue];
    while (iValue>base) {
        ac = iValue%base;
        a[b++] = ch[ac];
        iValue/=base;
    }
    a[b] = ch[iValue];
    for(int c = b; c>=0; c--, n++)
        d[n] = a[c];
    szRet = [NSString stringWithUTF8String:d];
    return szRet?szRet:@"NULL";
}

/*
 * Compute check digit for Apple serial number. Check digit is appended to end of passed in string.
 * @param serialNumber null terminated serial number to add check digit to. Must contain enough room to append another character. * @return true if serialNumber now has a valid check digit, false if check digit cannot be computed
 */
int addCheckDigit(char *serialNumber) {
    static char digits[] = "0123456789ABCDEFGHJKLMNPQRSTUVWXYZ";
    int length = strlen(serialNumber);
    int radix = 34; // always base 34
    int total = 0; // Start total at 0
    int index; // loop counter
    // Loop over characters from right to left with the rightmost character being odd
    for (index = 1; index <= length; ++index) {
        char digit = serialNumber[length - index];
        char *foundDigit = strchr(digits, digit);
        if (!foundDigit) { // Invalid digit, check digit can't be calculated
            return 0; }
        int value = foundDigit - digits;
        if ((index & 1) == 1) { // odd digit, add 3 times value
            total += 3*value;
        } else { // even digit, just add value
            total += value; }
    }
    // Compute and append check digit
    int checkValue = total % radix;
    char checkDigit = (checkValue > 0) ? digits[radix - checkValue] : '0';
    serialNumber[length] = checkDigit;
    serialNumber[length+1] = '\0';
    return 1;
}
/*
 * Verify check digit for Apple serial number.
 * @param serialNumber serial number to verify
 * @return true if serialNumber has a valid check digit, false otherwise */
int verifyCheckDigit(const char *serialNumber)
{
    static char digits[] = "0123456789ABCDEFGHJKLMNPQRSTUVWXYZ";
    int length = strlen(serialNumber);
    int radix = 34; // always base 34
    int total = 0; // Start total at 0
    int index; // loop counter
    // Loop over characters from right to left with the rightmost character being even
    for (index = 0; index < length; ++index) {
        char digit = serialNumber[length - index - 1];
        char *foundDigit = strchr(digits, digit);
        if (!foundDigit) {
            // Invalid digit, check digit can't be calculated
            return 0; }
        int value = foundDigit - digits;
        if ((index & 1) == 1) {
            // odd digit, add 3 times value
            total += 3*value;
        } else {
            // even digit, just add value
            // verify that total is an even multiple of radix
            total += value;
        }
    }
    return (total % radix) == 0;
}


@end




