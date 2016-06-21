//
//  RCTControlPort.h
//  RenameCableTool
//
//  Created by raniys on 2/10/14.
//  Copyright (c) 2014 raniys. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <IOKit/IOKitLib.h>
#include <IOKit/serial/IOSerialKeys.h>
#include <IOKit/IOBSD.h>
#include <IOKit/usb/IOUSBLib.h>
#include <sys/termios.h>

@interface RCTControlPort : NSObject
{
    int             m_iRS232;
    struct termios  m_rsOriTerm;
    struct termios  m_rsNewTerm;
    //    NSString        *m_strResultValue;
}

@property (nonatomic, assign) int RS232;

//to find the port which has connected DUT
+ (NSArray *)SearchSerialPorts;
//to open serial port
- (BOOL)OpenSerialPort:(NSString *)strPath
               withBit:(int)iBit
              withStop:(int)iStop
          withBaudRate:(int)iBaudRate
            withParity:(NSString *)szParity
             ErrorMesg:(NSString **)strErr;
//send command and read the value
- (NSString *)ControlThePort: (NSString *) command;

@end
