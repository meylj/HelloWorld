//
//  PEGA_ATS_UART.h
//  PEGA_ATS_UART
//
//  Created by David_Dai on 4/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//



#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#include <termios.h>



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



#ifndef writeDebug
#define writeDebug
@protocol writeDebugLog
-(void)writeDebugLog:(NSString *)szFirstParam;
@end
#endif



@interface PEGA_ATS_UART : NSObject
{
    //delegate for writing debug log
    id<writeDebugLog>	delegate;
    
    int					m_iRS232FileDescription;
	NSString			*m_szEndSymbol;
	struct termios		m_rsNewTerm;
	struct termios		m_rsOrigTerm;
}

@property (assign) id<writeDebugLog>	delegate;//define a property , can use get and set

/** description	: init Uart Framework. */
- (id)init_Uart;

/**
 szPath			: serial port path, such as /dev/cu.usbserial-A6007BMQ
 iBaudRate		: Baudrate
 iDataBit       : Databit
 szParity       : parity
 iStopBit       : stopBit
 inEndSymbol	: such as @"\r\n"
 description	: open serial port. */
-(UInt16)openPort:(NSString *)szPath
		baudeRate:(int)iBaudRate
		  dataBit:(int)iDataBit
		   parity:(NSString *)szParity
		 stopBits:(int)iStopBit
		endSymbol:(NSString *)inEndSymbol;

/** description	: close serial port. */
- (void)Close_Uart;

/**
 inIntervalTime	: How long to clear serial buffer
 inTimeOut		: Max clear time
 description	: Clear all data buffer. */
-(UInt16)Clear_UartBuff:(NSTimeInterval)inIntervalTime
				TimeOut:(NSTimeInterval)inTimeOut
				readOut:(NSString**)szReadOut;

/**
 inCommand      : command
 nPackNumber    : 0 mean send data by one byte, all command divide into nPackNumber sections.
 nIntervalTime  : each section will delay nInteralTime microseconds
 description	: write id data type  to serial port.(data type should be NSString or NSData). */
-(UInt16)Write_UartCommand:(id)inCommand
				 PackedNum:(NSUInteger)nPackNumber
				  Interval:(NSUInteger)nIntervalTime
					 IsHex:(BOOL)bIsHex;

/**
 outUartData	: read from UART buffer data,the data type should be NSMutableString or NSMutableData
 inArySymbols   : terminate symbol, such as :-)
 inType         : 0 : All Macth, 1 : Any one
 inIntervalTime	: How long to read from serial port data
 inTimeOut		: Max read data time
 description	: read data from serial port. */
-(UInt16)Read_UartData:(id)outUartData
	   TerminateSymbol:(NSArray*)inArySymbols
			 MatchType:(NSInteger)inType
		  IntervalTime:(NSTimeInterval)inIntervalTime
			   TimeOut:(NSTimeInterval)inTimeOut;

-(NSUInteger)memmem:(const void *)cSource
	   SourceLength:(int)iSourceLength
			 Symbol:(const void *)cSymbol
	   SymbolLength:(int)iSymbolLength;
/**
 outStrFrameWorkVer: Pass out the version of framework
 description	   : return Uart Framework Version. */
+(void)GetUartFrameworkVersion:(NSString **)outStrFrameWorkVer;

@end




