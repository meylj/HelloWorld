//
//
//  SFIS_Query.m
//  demo
//
//  Created by User on 12-8-30.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "SFIS_Query.h"
#define kNet_Request            @"http://10.16.16.86/invoke/EmeraldBobcat/EmeraldSFC"
#define kLocal_Request          @"http://172.28.144.77/invoke/EmeraldBobcat/EmeraldSFC"
#define kHTTP_TimeOut           10

@implementation SFIS_Query

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

+ (NSString *)getKeyValue :(NSString *)_key withSN: (NSString *)_sn
{
    NSData				*getData;
    NSHTTPURLResponse	*theResponse;
    NSError				*errors;
    NSString            *szValue; 
    NSMutableURLRequest	*theRequest = [NSMutableURLRequest alloc];
    NSMutableString		*szURL_Addr = [[NSMutableString alloc] initWithString:kNet_Request];
    [szURL_Addr appendFormat:@"?sn=%@&c=query_RECORD&p=%@",_sn,_key];
    theRequest = [theRequest initWithURL:[NSURL URLWithString:szURL_Addr]];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setValue:@"text/html;charset=UTF8" forHTTPHeaderField:@"Content-Type"];
    [theRequest setTimeoutInterval:kHTTP_TimeOut];
    getData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&theResponse error:&errors];
    if ([(NSHTTPURLResponse *)theResponse statusCode] == 200)
    {
        NSString	*szResposeData = [[NSString alloc] initWithData:getData encoding:NSUTF8StringEncoding];
        NSRange range = [szResposeData rangeOfString:_key];
        if(range.location== NSNotFound)
        {
            NSString    *szWarnigMsg = [NSString stringWithFormat:@"SFIS OK, but key:%@ not found.\n%@",_key,szResposeData];
            NSRunAlertPanel(@"Warnig", szWarnigMsg, @"OK", nil,nil);
            szValue = @"NULL";
        }
        else
        {
            szValue = [szResposeData substringFromIndex:(range.location+range.length)];
            szValue = [szValue stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            szValue = [szValue stringByReplacingOccurrencesOfString:@" " withString:@""];
            szValue = [szValue stringByReplacingOccurrencesOfString:@"=" withString:@""];
        }
        [szResposeData release];
    }
    else
    {
        NSRunAlertPanel(@"Warnig", @"SFIS Not OK, Please check the network.", @"OK", nil,nil);
        szValue = @"NULL";
    }
    [theRequest release];
    [szURL_Addr release];
    return [szValue isEqualToString:@""]?@"NULL":szValue;
}

@end
