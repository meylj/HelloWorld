//
//  SerialController.h
//  ATSSerialTool
//
//  Created by Lorky Luo on 5/31/12.
//  Copyright 2012 Pegatron. All rights reserved.
//

#import <Foundation/Foundation.h>
#include     <stdio.h>      /*标准输入输出定义*/
#include     <stdlib.h>     /*标准函数库定义*/
#include     <unistd.h>     /*Unix 标准函数定义*/
#include     <sys/types.h>  
#include     <sys/stat.h>   
#include     <fcntl.h>      /*文件控制定义*/
#include     <termios.h>    /*PPSIX 终端控制定义*/
#include     <errno.h>      /*错误号定义*/
#include <IOKit/IOBSD.h>
#include <IOKit/IOKitLib.h>
#include <IOKit/serial/IOSerialKeys.h>

#define ReadTimeOut 0.5

@interface SerialController : NSObject
{
	int m_iRS232;
	struct termios m_rsNewTerm;
	struct termios m_rsOriTerm;
}

+ (NSArray *)SearchSerialPorts;
- (BOOL)OpenSerialPort:(NSString *)path 
			   withBit:(int)iBit 
			  withStop:(int)iStop
		  withBaudRate:(int)iBaudRate 
			withParity:(NSString *)szParity
			 ErrorMesg:(NSString **)strErr;
- (void)CloseSerialPort;
- (BOOL)isOpen;
- (long)sendCommand:(id)idCommand;
- (NSString *)readCommand;
@end
