//
//  Printer.h
//  Printer
//
//  Created by Betty Xie on 13/11/12.
//  Copyright 2012 . All rights reserved.
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
#include    <IOKit/IOBSD.h>
#include    <IOKit/IOKitLib.h>
#include    <IOKit/serial/IOSerialKeys.h>


@interface Printer : NSObject
{
    NSMutableString        *m_strPrint;
    NSMutableString        *m_strTextLocation;
    NSMutableString        *m_strBarcodeLocation;
    NSMutableString        *m_strBarcodeDefinition;
    NSMutableString        *m_strTextDefinition;
    NSMutableString        *m_str2DBarcodeCmd;
}

kern_return_t FindUSB(io_iterator_t *matchingServices);

/**
 *@brief  set serial port information, ex: databits,stopbits,check codes
 *@param  fd  (int) the handle of open serial port file
 *@param  databits  (int) databits, the value is 7 or 8
 *@param  stopbits  (int) stopbits, the value is 1 or 2
 *@param  parity   (int)  validation type, the value is N,E,O,S
 *@return int
 */
int set_Parity(int fd,int databits,int stopbits,int parity);

/**
 *@brief  set serial port communitcate speed
 *@param  fd   (int)  the handle of open serial port file
 *@param  speed  (int) serial port speed
 *@return void
 */
void set_speed(int fd, int speed);

/**
 *@brief open the serial port
 *@param Dev (char) the serial port path
 *@retrun int
 */
int OpenDev(char *Dev);
kern_return_t GetUSBPath(io_iterator_t serialPortIterator,char *bsdPath,CFIndex maxPathSize);

/**
 *@brief set the pre contents of print command ex:"^XA"
 *@param nil
 *@retrun int
 */
- (void)SetPreContents;

/**
 *@brief set the end contents of print command ex:"^XZ"
 *@param nil
 *@retrun int
 */

- (void)SetEndContents;

/**
 *@brief  set print count  (^PQq,p,r,o)
 *@param  iTimes  (NSString) print label count default value is 1
 *@param  iPauseTimes  (NSString) cut or pause after print iCutTimes lable  default is 0(no pause)
 *@param  iCopyTimes  (NSString) every serial num. copy times, default is 1(no copy)
 *@param  ContinusPrint   (BOOL)  continus print the label or not,default value is N
 *@return BOOL
 */
- (BOOL) SetPrinterCount:(NSString *)strTimes PauseTimes: (NSString *)strPauseTimes NumRepeatTimes:(NSString *)strCopyTimes ContinusPrint:(BOOL)bContinusPrint;

/**
 *@brief  set print content location (^FOX,Y)
 *@param  strLocationX  (NSString) the print content x coordinate
 *@param  strLocationY  (NSString) the print content y coordinate
 *@param  iFlag  (int) the flag for setting barcode or text location, 0 is for barcode, 1 is for text
 *@return BOOL
 */
- (BOOL)SetFieldLocationX:(NSString *)strLocationX FiledLocationY:(NSString *)strLocationY BarcodeOrText:(int)iFlag;

/**
 *@brief  set barcode field definition (^BYi,j,b)
 *@param  strNarrowLineLength  (NSString) the narrow line length
 *@param  strRadio  (NSString) the radio of barcode width line and height line
 *@param  strHeight  (NSString) the Barcode height
 *@return BOOL
 */

- (BOOL)SetBarcodeNarrowLineLength: (NSString *)strNarrowLineLength WidthHeightRadio:(NSString *)strRadio BarcodeHeight:(NSString *)strHeight;

/**
 *@brief  set text field definition (^Axa,b,c)
 *@param  strFont  (NSString) set text font A~Z,0...
 *@param  strAngle  (NSString) set font angle   N-->0  R-->90 I-->180 B--> 270
 *@param  strHeight  (NSString) set font height
 *@param  strWidth  (NSString) set font width
 *@return BOOL
 */
- (BOOL)SetTextFont:(NSString *)strFont TextAngle:(NSString *)strAngle TextHeight:(NSString *)strHeight TextWidth:(NSString *)strWidth;


/**
 *@brief  set 2DBarcode command ex:(^BXN,4,200,,,,)
 *@param  strCode  (NSString) barcode rule.ex: X==> 2D barcode matrix 7==> PDF417 barcode
 *@param  strDirection  (NSString) set barcode direction: N==> normal, R==> Roated, I==> Inverted, B==>ottom
 *@param  strLayer  (NSString) set encoding layer
 *@param  strHeight  (NSString) set each layer height
 *@return BOOL
 */
- (BOOL)Set2DBarcodeCommand:(NSString*)strCode Direction:(NSString *)strDirection Layer:(NSString *)strLayer Hight:(NSString *)strHeight;

/**
 *@brief set print darkness
 *@param strDarkness  (NSString) set printer thick darkness
 *@return BOOL
 */

- (BOOL)SetDarkness:(NSString *)strDarkness;

/**
 *@brief combine printer command
 *@param strBarInput   (NSString *) the string you want to print
 *@param strText    (NSString *) the text string you want to print
 *@param iType     type of print: 0 ==> printer barcode and text  1===>only print barcode  2 ==> only print text 3 ==> print 2D barcode
 *@return BOOL
 */

- (BOOL)CombineCmdBarContent:(NSString *)strBarInput TextContent:(NSString *)strText PrintType:(int)iType;

/**
 *@brief  print the lable
 *@return void
 */
- (int)Print;

@end
