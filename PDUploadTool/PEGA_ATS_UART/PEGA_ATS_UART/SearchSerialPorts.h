//
//  SearchSerialPorts.h
//  PEGA_ATS_UART
//
//  Created by Eagle on 4/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <IOKit/IOKitLib.h>
#include <IOKit/serial/IOSerialKeys.h>
#include <IOKit/IOBSD.h>
#include <IOKit/usb/IOUSBLib.h>

@interface SearchSerialPorts : NSObject {
@private
    
}
/****************************************************************************************************
 in_out_arrSerialPorts: save all the serial ports connected
 description	: serch serial port path
 ****************************************************************************************************/
- (UInt16)SearchSerialPorts:(NSMutableArray *)in_out_arrSerialPorts;
-(UInt16) SearchPortsNumber:(NSMutableDictionary*)dicPortSerialNumber;
@end
