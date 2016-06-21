//
//  IANet.m
//  Izual_Lu
//
//  Created by Lu Izual on 11-3-25.
//  Copyright 2011 PEGATRON. All rights reserved.
//

#import "IANet.h"


@implementation IANet
#pragma  mark ############################## Memory Control ##############################
-(IANet*)init
{
    self    = [super init];
    if(self)
    {
        // Total properties
        m_iAutoResent = 0;    // Auto resent. Default = None
        m_dTimeOut    = 3;    // Time out. Default = 3
        
        // SFIS, link to Bobcat
        m_dicSFISProperties = [[NSMutableDictionary alloc] init];
        m_arrayQueryItems   = [[NSMutableArray alloc] init];
        m_dicInsertItems    = [[NSMutableDictionary alloc] init];
        
        // DCS, link to pudding
    }
    return self;
}

-(void)dealloc
{
    [m_dicInsertItems release];
    [m_arrayQueryItems release];
    [m_dicSFISProperties release];
    [super dealloc];
}

// Init a SFIS net. With given IP, webservice, command and csd mode
// Param:
//      NSDictionary    *dicGHInfo  : GH Info dictionary, parsered by Lorky
//      int             iAutoResent : Auto resent times
//      double          dTimeOut    : Time out
-(IANet*)initWithGHInfoDictionary:(NSDictionary*)dicGHInfo 
                       AutoResent:(int)iAutoResent 
                          TimeOut:(double)dTimeOut
{
    self    = [super init];
    if(self)
    {
        // Total properties
        if(0 > iAutoResent)
            m_iAutoResent   = 0;
        if((0 >= dTimeOut)
           || (30 < dTimeOut))
            m_dTimeOut  = 3;
        
        // Get properties from dicGHInfo
        if((nil == dicGHInfo)
           || (![dicGHInfo isKindOfClass:[NSDictionary class]]))
        {
            return nil;
        }
        NSDictionary    *dicParsered;
        if((dicParsered = [self ParserPropertiesFromGHInfo:dicGHInfo]))
            m_dicSFISProperties = [[NSMutableDictionary alloc] initWithDictionary:dicParsered];
        else
        {
            m_dicSFISProperties = [[NSMutableDictionary alloc] init];
            m_arrayQueryItems   = [[NSMutableArray alloc] init];
            m_dicInsertItems    = [[NSMutableDictionary alloc] init];
            [self release];
            return nil;
        }
        m_arrayQueryItems   = [[NSMutableArray alloc] init];
        m_dicInsertItems    = [[NSMutableDictionary alloc] init];
    }
    return self;
}



#pragma mark ############################## For SFIS ##############################
// Parser properties from GHInfo
// Param:
//      NSDictionary    *dicGHInfo  : GHInfo dictionary
// Return:
//      NSDictionary*   : A dictionary contains parsered properties
//          URL                 -> NSString*    : Bobcat URL. (Can be nil). 
//                                                  Such as "http://10.16.16.85/ForPerlRequest/SFCTest"
//          PRODUCT             -> NSString*    : Product name. (Can be nil). Such as "N92"
//          STATION_ID          -> NSString*    : Station ID. (Can be nil). 
//                                                  Such as "PGPD_F05-4FT-FlightDeck_1_QT0"
//          STATION_NAME        -> NSString*    : Station name. (Can be nil). Such as "QT0"
//          OS_BUNDLE_VERSION   -> NSString*    : OS_BUNDLE_VERSION. (Can be nil). Such as "8E200"
//          MAC_ADDRESS         -> NSString*    : Station mac address. (Can be nil). 
//                                                  Such as "60:fb:42:f5:2c:80"
-(NSDictionary*)ParserPropertiesFromGHInfo:(NSDictionary*)dicGHInfo
{
    // Basic judge
    NSArray *arrayUpperCaseKeys = [NSArray arrayWithObjects:@"URL", @"PRODUCT", @"STATION_ID", 
                                   @"OS_BUNDLE_VERSION", @"MAC_ADDRESS", nil];
    if((nil == dicGHInfo)
       || (![dicGHInfo isKindOfClass:[NSDictionary class]]))
    {
        return nil;
    }
    for(NSString *string in arrayUpperCaseKeys)
    {
        if((![[dicGHInfo allKeys] containsObject:string])
           || (![[dicGHInfo objectForKey:string] isKindOfClass:[NSString class]]))
        {
            return nil;
        }
    }
    
    // Parser properties
    NSMutableDictionary *dicParseredOK  = [[[NSMutableDictionary alloc] init] autorelease];
    [dicParseredOK setObject:[dicGHInfo objectForKey:@"URL"] forKey:@"url"];
    [dicParseredOK setObject:[dicGHInfo objectForKey:@"PRODUCT"] forKey:@"product"];
    [dicParseredOK setObject:[dicGHInfo objectForKey:@"STATION_ID"] forKey:@"station_id"];
    [dicParseredOK setObject:[dicGHInfo objectForKey:@"STATION_NAME"] forKey:@"test_station_name"];
    [dicParseredOK setObject:[dicGHInfo objectForKey:@"OS_BUNDLE_VERSION"] forKey:@"os_bundle_version"];
    [dicParseredOK setObject:[dicGHInfo objectForKey:@"MAC_ADDRESS"] forKey:@"mac_address"];
    
    // End
    return dicParseredOK;
}

// Query items
// Param:
//      NSArray     *arrayQueryItems    : Query items
//      NSString    *szSN               : Qeury SN
// Return:
//      NSDictionary*   : A dictionary contains receive values with query items be keys
-(NSDictionary*)QueryItems:(NSArray*)arrayQueryItems 
                    WithSN:(NSString*)szSN
{
    // Basic judge
    [m_arrayQueryItems removeAllObjects];
    if((nil ==arrayQueryItems)
       || (![arrayQueryItems isKindOfClass:[NSArray class]])
       || (nil == szSN)
       || (![szSN isKindOfClass:[NSString class]]))
    {
        return nil;
    }
    
    // Get query items
    NSDictionary    *dicQueryItemsMap  = [NSDictionary dictionaryWithObjectsAndKeys:
                                          @"mlbsn",        @"MLBSN", 
                                          @"Color",        @"COLOR", 
                                          @"Nand_size",    @"NANDSIZE", 
                                          @"Vendor_id",    @"VENDORID", 
                                          @"mpn",          @"MPN", 
                                          @"pvendor",      @"PVENDOR", 
                                          @"region_code",  @"REGIONCODE", 
                                          @"device_id",    @"DEVICEID", 
                                          @"band_color",   @"BANDCOLOR", 
                                          @"BandSn",       @"BANDSN", 
                                          [NSArray arrayWithObjects:@"mlbsn", @"Color", @"Nand_size", 
                                           @"Vendor_id", @"mpn", @"pvendor", 
                                           @"region_code", @"device_id", @"BandSn", nil], @"ALL", nil];
    for(int i=0; i<[arrayQueryItems count]; i++)
    {
        if(![[arrayQueryItems objectAtIndex:i] isKindOfClass:[NSString class]])
        {
            return nil;
        }
        NSString    *szQueryItem    = [[arrayQueryItems objectAtIndex:i] uppercaseString];
        if(![[dicQueryItemsMap allKeys] containsObject:szQueryItem])
        {
            return nil;
        }
        if([szQueryItem isEqualToString:@"ALL"])
            [m_arrayQueryItems addObjectsFromArray:[dicQueryItemsMap objectForKey:szQueryItem]];
        else
            [m_arrayQueryItems addObject:[dicQueryItemsMap objectForKey:szQueryItem]];
    }
    
    // Make URL
    NSMutableString *szRequest  = [[[NSMutableString alloc] init] autorelease];
    [szRequest appendString:[m_dicSFISProperties objectForKey:@"url"]];
    [szRequest appendString:@"?command=QUERY_RECORD"];
    [szRequest appendFormat:@"&sn=%@",[szSN uppercaseString]];
    [szRequest appendFormat:@"&station_id=%@",[m_dicSFISProperties objectForKey:@"station_id"]];
    [szRequest appendFormat:@"&test_station_name=%@",[m_dicSFISProperties objectForKey:@"test_station_name"]];
    [szRequest appendString:@"&query="];
    for(NSString *string in m_arrayQueryItems)
        [szRequest appendFormat:@"%@%%20",string];
    NSMutableURLRequest *URLRequest = [[[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:szRequest]] autorelease];
    [URLRequest setHTTPMethod:@"POST"];
    [URLRequest setValue:@"text/html;charset=UTF8" forHTTPHeaderField:@"Content-Type"];
    [URLRequest setTimeoutInterval:m_dTimeOut];
    
    // Sent request and get response
    NSHTTPURLResponse   *URLResponse;
    NSData              *dataResult;
    NSError             *errorQuery;
    dataResult  = [NSURLConnection sendSynchronousRequest:URLRequest 
                                        returningResponse:&URLResponse 
                                                    error:&errorQuery];
    
    // Judge result
    if(200 != [(NSHTTPURLResponse*)URLResponse statusCode])
    {
        return nil;
    }
    NSString    *szResponse = [[[NSString alloc] initWithData:dataResult 
                                                     encoding:NSUTF8StringEncoding] autorelease];
    NSRange range   = [szResponse rangeOfString:@"SFC_OK"];
    if(NSNotFound == range.location || range.length <= 0 || ((range.length + range.location) > [szResponse length]))
    {
        return nil;
    }
    
    // Cut items out
    
    // End
    return nil;
}

// Insert items
// Param:
//      NSDictionary    *dicInsertItems : A dictionary contains items you want to insert
//          
-(BOOL)InsertItems:(NSDictionary*)dicInsertItems
{
    // Basic judge
    
    // Make URL
    
    // Sent URL
    
    // Get response
    
    // Judge result
    
    // End
    return NO;
}

// Get SFIS properties
-(NSDictionary*)SFISProperties
{
    return m_dicSFISProperties;
}



#pragma mark ############################## For DCS ##############################



@end
