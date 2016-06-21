//
//  IANet.h
//  Izual_Lu
//
//  Created by Lu Izual on 11-3-25.
//  Copyright 2011 PEGATRON. All rights reserved.
//



#import <Cocoa/Cocoa.h>



@interface IANet : NSObject
{
    // Total properties
    int                 m_iAutoResent;    // Auto resent times
    double              m_dTimeOut;   // Time out
    
    // SFIS, link to Bobcat
    NSMutableDictionary *m_dicSFISProperties;   // Some properties parsered from GHInfo
    NSMutableArray      *m_arrayQueryItems; // Query items
    NSMutableDictionary *m_dicInsertItems;  // Insert items
    
    // CSD, link to pudding
}

// Init a SFIS net. With given IP, webservice, command and csd mode
// Param:
//      NSDictionary    *dicGHInfo  : GH Info dictionary, parsered by Lorky
//      int             iAutoResent : Auto resent times
//      double          dTimeOut    : Time out
-(IANet*)initWithGHInfoDictionary:(NSDictionary*)dicGHInfo 
                       AutoResent:(int)iAutoResent 
                          TimeOut:(double)dTimeOut;



/*############################## For SFIS ##############################*/
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
-(NSDictionary*)ParserPropertiesFromGHInfo:(NSDictionary*)dicGHInfo;

// Query items
// Param:
//      id          idQueryItems    : Query items
//          nil             : Default = All
//          NSString*       : A query item. Default = All
//          NSArray*        : Many query items
//          NSDictionary*   : Get keys as query items
//      NSString    *szSN           : Qeury SN
// Return:
//      NSDictionary*   : A dictionary contains receive values with query items be keys
-(NSDictionary*)QueryItems:(id)idQueryItems 
                    WithSN:(NSString*)szSN;

// Insert items
// Param:
//      NSDictionary    *dicInsertItems : A dictionary contains items you want to insert
//          
-(BOOL)InsertItems:(NSDictionary*)dicInsertItems;

// Get SFIS properties
-(NSDictionary*)SFISProperties;

@end




