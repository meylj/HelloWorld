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

/**
 * @brief - open serial port
 *
 * @param szPath            - Path of serial port (/dev/cu.usbserial.DUT1)
 * @param iBaudRate         - Speed (115200)
 * @param iDataBit          - Data bits (CS8)
 * @param szParity          - Parity bits (PARENB || PARODD)
 * @param iStopBit          - Stop bits (CSTOPB)
 * @param inEndSymbol       - End of symbol (0x13)
 * @return – SUCCESS (kUart_SUCCESS) FAILURE (kUart_ERROR)
 **/
-(UInt16)openPort:(NSString *)szPath
		baudeRate:(int)iBaudRate
		  dataBit:(int)iDataBit
		   parity:(NSString *)szParity
		 stopBits:(int)iStopBit
		endSymbol:(NSString *)inEndSymbol;

/**
 * @brief - close serial port
 **/
- (void)Close_Uart;

/**
 * @brief - Clear all data buffer.
 *
 * @param inIntervalTime    - How long to clear serial buffer
 * @param inTimeOut         - Max clear time
 * @param szReadOut         - Read back Uart buffer data
 * @return                  – SUCCESS (kUart_SUCCESS) FAILURE (kUart_ERROR)
 **/
-(UInt16)Clear_UartBuff:(NSTimeInterval)inIntervalTime
				TimeOut:(NSTimeInterval)inTimeOut
				readOut:(NSString**)szReadOut;

/**
 * @brief - write id data type  to serial port.(data type should be NSString or NSData).
 *
 * @param inCommand         - Uart command
 * @param nPackNumber       - 0 mean send data by one byte, all command divide into nPackNumber sections.
 * @param nIntervalTime     - each section will delay nInteralTime microseconds
 * @param bIsHex            - command format is Hex
 * @return – SUCCESS (kUart_SUCCESS) FAILURE (kUart_ERROR)
 **/
-(UInt16)Write_UartCommand:(id)inCommand
				 PackedNum:(NSUInteger)nPackNumber
				  Interval:(NSUInteger)nIntervalTime
					 IsHex:(BOOL)bIsHex;

/**
 * @brief - read data from serial port.
 *
 * @param outUartData       - read from UART buffer data,the data type should be NSMutableString or NSMutableData
 * @param inArySymbols      - terminate symbol, such as :-)
 * @param inType            - 0 : All Macth, 1 : Any one
 * @param inIntervalTime	- How long to read from serial port data
 * @param inTimeOut         - Max read data time
 * @return – SUCCESS (kUart_SUCCESS) FAILURE (kUart_ERROR)
 **/
-(UInt16)Read_UartData:(id)outUartData
	   TerminateSymbol:(NSArray*)inArySymbols
			 MatchType:(NSInteger)inType
		  IntervalTime:(NSTimeInterval)inIntervalTime
			   TimeOut:(NSTimeInterval)inTimeOut;

/**
 * @brief - search symbo from buffer
 *
 * @param cSource           - data buffer
 * @param iSourceLength     - buffer length
 * @param cSymbol           - symbol data
 * @param iSymbolLength     - symbol length
 * @return – SUCCESS (kUart_SUCCESS) FAILURE (kUart_ERROR)
 **/
-(NSUInteger)memmem:(const void *)cSource
	   SourceLength:(int)iSourceLength
			 Symbol:(const void *)cSymbol
	   SymbolLength:(int)iSymbolLength;
/**
 * @brief - get version from framework
 *
 * @param outStrFrameWorkVer - framework version
 **/
+(void)GetUartFrameworkVersion:(NSString **)outStrFrameWorkVer;

@end




