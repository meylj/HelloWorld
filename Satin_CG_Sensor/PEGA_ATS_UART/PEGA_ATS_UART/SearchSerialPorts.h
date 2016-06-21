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



@interface SearchSerialPorts : NSObject
{
@private
    
}

/**
 * @brief - search serial port path.
 *
 * @param in_out_arrSerialPorts - save all the serial ports connected
 * @return – SUCCESS (kUart_SUCCESS) FAILURE (kUart_ERROR)
 **/
-(UInt16)SearchSerialPorts:(NSMutableArray *)in_out_arrSerialPorts;

/**
 * @brief - search serial port path.
 *
 * @param dicPortSerialNumber - save all the serial ports path and cable serial number
 * @return – SUCCESS (kUart_SUCCESS) FAILURE (kUart_ERROR)
 **/
-(UInt16)SearchPortsNumber:(NSMutableDictionary*)dicPortSerialNumber;

//Add by sky, 2015.2.9
//a new function that to find the ports from disk
/**
 * @brief - find the ports from Computer.
 *
 * @param in_out_arrSerialPorts - save all the serial ports path
 **/
- (void)FindSerialPortsFromDisk:(NSMutableArray *)in_out_arrSerialPorts;


@end




