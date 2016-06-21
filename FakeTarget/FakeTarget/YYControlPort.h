//
//  YYControlPort.h
//  OpenUart
//
//  Created by raniys on 12/26/13.
//  Copyright (c) 2013 raniys. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <IOKit/IOKitLib.h>
#include <IOKit/serial/IOSerialKeys.h>
#include <IOKit/IOBSD.h>
#include <IOKit/usb/IOUSBLib.h>
#include <sys/termios.h>

#define	kUart_IntervalTime			0.01
#define kUart_ClearInterval			0.25
#define	kUart_CommandTimeOut		5
#define	kUart_MatchAllItems			0x00
#define	kUart_MatchAnyOne			0x01
#define	kUart_MatchFixture			0x02
#define kUart_ERROR					0xF1
#define	kUart_WRITE_ERROR			0xF2
#define	kUart_MAX_LEN				1024
#define kUart_ReturnPattern			@"\r"
#define	kUart_NewLinePattern		@"\n"
#define kUart_SUCCESS				0x00
#define kUart_MatchLength           0x03
#define kUart_CMD_SUCCESS			0x00
#define kUart_TIMEOUT_Error			0x01
#define	kUart_CMD_TimeOut_Error		0x01
#define	kUart_CMD_CHECK_DUT_FAIL	0x02
#define kUart_DATA_TYPE_Error		0x03



@interface YYControlPort : NSObject
{
    int					m_iRS232FileDescription;
	NSString			*m_szEndSymbol;
	struct termios		m_rsNewTerm;
	struct termios		m_rsOrigTerm;
}

-(id)init_Uart;

//to find the port which has connected DUT
+ (NSArray *)SearchSerialPorts;
//to open serial port
-(UInt16)openPort:(NSString*)szPath
		baudeRate:(int)iBaudRate
		  dataBit:(int)iDataBit
		   parity:(NSString *)szParity
		 stopBits:(int)iStopBit
		endSymbol:(NSString*)inEndSymbol;

-(void)Close_Uart;

-(UInt16)Clear_UartBuff:(NSTimeInterval)inIntervalTime
				TimeOut:(NSTimeInterval)inTimeOut
				readOut:(NSString**)szReadOut;

-(UInt16)Write_UartCommand:(id)inCommand
				 PackedNum:(NSUInteger)nPackNumber
				  Interval:(NSUInteger)nIntervalTime
					 IsHex:(BOOL)bIsHex;

-(UInt16)Read_UartData:(id)outUartData
		  IntervalTime:(NSTimeInterval)inIntervalTime;

////send command and read the value
//- (NSString *)ControlThePort: (NSString *) command;

@end
