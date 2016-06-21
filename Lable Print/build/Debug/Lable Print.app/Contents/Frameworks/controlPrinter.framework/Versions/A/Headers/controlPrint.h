//
//  controlPrint.h
//  controlPrinter
//
//  Created by Leehua on 10-9-6.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
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


@interface controlPrint : NSObject {
	NSString *m_Response;
}
-(int) print : (NSString *)szInput;
- (BOOL)getDataFromSFC:(NSUInteger) nQureyPattern SysNum : (NSString *) pSysNumber 
	   SFC_ResultData : (NSString **) szReturnValue;
- (BOOL)judgeJSPResponse:(NSString **)szReturnValue;
@end
