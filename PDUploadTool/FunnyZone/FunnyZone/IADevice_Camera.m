//
//  IADevice_Camera.m
//  FunnyZone
//
//  Created by Winter on 11/28/11.
//  Copyright 2011 PEGATRON. All rights reserved.
//

#import "IADevice_Camera.h"


@implementation TestProgress (IADevice_Camera)

//2011-12-10 add by Winter
// Combine a serial of hexadecimal datas without "0x".
// Ex:  0x0 : 0x30 0xF4 0x29 0x9F 0x64  
//      0x8 : 0xB4 0x2 0xA 0x81 0x0 0x0
// After combine: 30F4299F64B4020A810000
// Param:
//      NSString **strSourceData     : Numbers Source Data
//      int   iStart           : The start index in these numbers.
//      int   iLast            : The last index to the end index.
// Return:
//      Actions result
-(BOOL)combineNVMForQT0:(NSString **)strSourceData startIndex:(int)iStart DeleLastIndex:(int)iLast
{
    *strSourceData = [*strSourceData stringByReplacingOccurrencesOfString:@"\r" withString:@""];
	NSArray * arrCell = [*strSourceData componentsSeparatedByString:@"\n"];
	NSMutableArray *aryTemp = [[NSMutableArray alloc] init];
	for (int i = 0; i< [arrCell count]; i++)
	{
		NSString * strCell = [arrCell objectAtIndex:i];// get each line, (Ex. 0x0 : 0x30 0xF4 0x29 0x9F 0x64)
		NSRange range = [strCell rangeOfString:@" : "];
		if (NSNotFound != range.location && range.length > 0 && (range.location + range.length) <= [strCell length])
		{
			NSString * strTemp =[strCell substringFromIndex:range.location + range.length];
			NSArray * arrayUnit = [strTemp componentsSeparatedByString:@" "];
			for (int iIndex = 0; iIndex < [arrayUnit count]; iIndex ++)
			{
				[aryTemp addObject:[arrayUnit objectAtIndex:iIndex]];// add each value to aryTemp
			}
		}
	}
	if (iStart + iLast > [aryTemp count])
    {
        ATSDebug(@"iStart + iLast is bigger than values count");
        [aryTemp release];
        return NO;
    }
    
    NSMutableString * strCamera = [[NSMutableString alloc] initWithString:@""];
	for (int i = iStart; i < [aryTemp count] - iLast; i++)
	{
		NSString *strData = [aryTemp objectAtIndex:i];
        
        strData = ([strData length] == 4) ? [strData stringByReplacingOccurrencesOfString:@"0x" withString:@""]: [strData stringByReplacingOccurrencesOfString:@"x" withString:@""];//ex. situation1:0x18=>18; situation2:0x4 => 04;
        [strCamera appendString:strData];
	}
	*strSourceData = [NSString stringWithString:strCamera];
    ATSDebug(@"strSourceData value is %@",*strSourceData);
	[aryTemp release];
    [strCamera release];
	return YES;
}

//2011-12-10 add by Winter
// Catch useful strings from strReturnValue, and set memories for "FCMB"/"BCMB"
// Param:
//       NSDictionary    *dicContents        : Settings in script
//              CAMERAKEY -> (NSString*)     : FCMS or BCMS
//              KEY -> (NSString*)           : catch from what(ex.CAMERA_CONFIG)
//       NSMutableString *strReturnValue     : Return value
// Return:
//      Actions result
-(NSNumber*)CATCH_NVM_VALUE:(NSDictionary*)dicContents RETURN_VALUE:(NSMutableString*)strReturnValue
{
	BOOL bResult =YES;
    NSString    *szKey = [dicContents objectForKey:kFZ_Script_MemoryKey];
    NSString    *szCameraKey = [dicContents objectForKey:@"CAMERAKEY"];
    NSString	*szCatchedValue	= [m_dicMemoryValues objectForKey:szKey];
    
    if ([szCameraKey isEqualToString:@"FCMB"]) 
    {
        if ([szCatchedValue ContainString:@"Sensor channel 1 detected :"]) {//channel 1 : front camera
            szCatchedValue = [szCatchedValue SubFrom:@"Sensor channel 1 detected :" include:NO];
            if ([szCatchedValue ContainString:@"NVM Data 1024 bytes :"] && [szCatchedValue ContainString:@"0x20 :"]) 
            {
                szCatchedValue = [szCatchedValue SubFrom:@"NVM Data 1024 bytes :" include:NO];
                szCatchedValue = [szCatchedValue SubTo:@"0x20 :" include:NO];
                // FCMB is made of 0x0,0x8,0x10,0x18, these 4 lines value
                bResult &= [self combineNVMForQT0:&szCatchedValue startIndex:0 DeleLastIndex:0];
                ATSDebug(@"strFrontCameraTemp is %@",szCatchedValue);
                [m_dicMemoryValues setObject:szCatchedValue forKey:@"FCMB"];
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
    else if ([szCameraKey isEqualToString:@"BCMB"])
    {
        if ([szCatchedValue ContainString:@"Sensor channel 0 detected :"]) {//channel 0 : back camera
            szCatchedValue = [szCatchedValue SubFrom:@"Sensor channel 0 detected :" include:NO];
            if ([szCatchedValue ContainString:@"0x10 :"] && [szCatchedValue ContainString:@"0x28 :"])
            {
                szCatchedValue = [szCatchedValue SubFrom:@"0x10 :" include:YES];
                szCatchedValue = [szCatchedValue SubTo:@"0x28 :" include:NO];
                // BCMB is made of 0x10,0x18,0x20, these 3 lines value
                bResult &= [self combineNVMForQT0:&szCatchedValue startIndex:0 DeleLastIndex:0];
                ATSDebug(@"strBackCameraTemp is %@",szCatchedValue);
                [m_dicMemoryValues setObject:szCatchedValue forKey:@"BCMB"];
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
    else
    {
        ATSDebug(@"Get the wrong key!");
        return [NSNumber numberWithBool:NO];
    }
    
    return [NSNumber numberWithBool:bResult];
}

//2012-12-25 add by Andre
// combine  string red, green and blue
// Param:
//       NSDictionary    *dicContents        : Settings in script
//              item0 -> (NSString*)         : red
//              item1 -> (NSString*)         : green
//              item2 -> (NSString*)         : blue
//              symbol -> (NSString*)        : must be RGB
//       NSMutableString *strReturnValue     : Return value
- (NSNumber *)combineVGAsn:(NSDictionary *)dicpara RETURN_VALUE:(NSMutableString*)strReturnValue
{
	int iCount = [dicpara count];
    	
	if ([dicpara valueForKey :@"symbol"] != nil) 
	{
		if([[dicpara valueForKey :@"symbol"] isEqualToString:@"RGB"])
		{
            NSMutableString *szVGAsn = [[NSMutableString alloc] initWithString:@"0x"];
			iCount--;
			
			for(int i=0; i<iCount; i++)
			{
				NSString *key = [NSString stringWithFormat:@"item%d",i];
				NSString *keyName = [dicpara valueForKey:key];//keyName is red,green or blue
				NSString *partVGA =[m_dicMemoryValues valueForKey:keyName];
				[szVGAsn appendFormat:@"%@/",partVGA ];
			}
            ATSDebug(@"RGB value : %@",szVGAsn);// the finial szVGAsn should be "0xred/green/blue"
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

@end
