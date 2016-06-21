//
//  CSD_QRCode.m
//  FunnyZone
//
//  Created by Sunny on 13-9-25.
//  Copyright (c) 2013年 PEGATRON. All rights reserved.
//

#import "CSD_QRCode.h"

@implementation TestProgress (CSD_QRCode)


-(NSNumber *)ENCODE:(NSDictionary*)dicReadSettings
      RETURN_VALUE:(NSMutableString*)szReturnValue
{
    NSArray             *arrKeys    = [dicReadSettings objectForKey:@"Keys"];
    NSMutableDictionary *dictData   = [NSMutableDictionary dictionary];
    NSError             *error;
    
    for (int i = 0; i < [arrKeys count]; i++)
    {
        NSString        *strKey      = [arrKeys objectAtIndex:i];
        NSString        *strValue    = [m_dicMemoryValues objectForKey:
                                       strKey];
        ATSDebug(@"Encode Key:%@,Value:%@",strKey,strValue);
        
        if(!strValue)
        {
            [szReturnValue setString:[NSString stringWithFormat:
                                      @"Can't get value of %@",strKey]];
            return [NSNumber numberWithBool:NO];
        }
            
         else if(strValue && ![strKey isEqualToString:@"LCM#"])
        {
            NSData *dataValue = [self stringToData:strValue];
            
            [dictData setObject:dataValue
                         forKey:strKey];
        }
        else
        {
            [dictData setObject:strValue
                         forKey:strKey];
        }
    }
    
    NSString *strQCCode = [fsb encodeDataDictionaryToString:dictData error:&error];
    
    if (strQCCode)
    {
        [szReturnValue setString:strQCCode];
        
        return [NSNumber numberWithBool:YES];
    }
    else
    {
        [szReturnValue setString:@"Can't get QR Code"];
        return [NSNumber numberWithBool:NO];
    }
}

-(NSNumber*)DECODE:(NSDictionary*)dicReadSettings
      RETURN_VALUE:(NSMutableString*)szReturnValue
{
    NSString            *strKey     = [dicReadSettings objectForKey:@"QRCodeKey"];
    NSDictionary        *dictData   = [NSDictionary dictionary];
    NSError             *error;
    
    NSString            *strValue   = [m_dicMemoryValues objectForKey:strKey];
    ATSDebug(@"Decode:%@",strValue);
    
    if (strValue)
        dictData        = [fsb decodeStringToDataDictionary:strValue error:&error];
    else
        return [NSNumber numberWithBool:NO];

    NSData              *dataNugt   = [dictData objectForKey:@"Nugt"];
    NSString            *strNugt    = [self DataToString:dataNugt];
    NSLog(@"%@",strNugt);
    
    [m_dicMemoryValues setObject:strNugt forKey:@"Nugt_QRCODE"];
    [m_dicMemoryValues setObject:dictData forKey:@"Decode"];
    
    return [NSNumber numberWithBool:YES];
}

- (NSData *)stringToData:(NSString *)strTemp
{
    NSScanner       *scan       = [NSScanner scannerWithString:strTemp];
    unsigned        uData;
    NSMutableData   *hexData    = [[NSMutableData alloc] init];
    
	while ([scan scanHexInt:&uData])
    {
        unsigned    newData     =   (uData & 0xFF) << 24 |
                                    (uData & 0xFF00) << 8 |
                                    (uData & 0xFF0000) >> 8 |
                                    (uData & 0xFF000000) >> 24;
        [hexData appendBytes:&newData length:sizeof(newData)];
    }
    NSLog(@"Data = %@",hexData);
    NSData *dataValue = [NSData dataWithData:hexData];
    [hexData release];
    return dataValue;
}

//<97162000 00000000 05000000>
//971620000000000005000000
- (NSString *)DataToString:(NSData *)dataTemp
{
    NSMutableString *strTemp   = [[NSMutableString alloc]init];
    Byte            *testByte   = (Byte *)[dataTemp bytes];
    for(int i=0;i<[dataTemp length];i++)
    {
        [strTemp appendFormat:@"%02X",testByte[i]];
    }
    NSLog(@"%@",strTemp);
    
    NSString *strValue  = [NSString stringWithFormat:@"%@",strTemp];
    [strTemp release];   
    return strValue;
}

@end
