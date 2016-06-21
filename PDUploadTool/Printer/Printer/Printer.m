//
//  Printer.m
//  Printer
//
//  Created by Betty Xie on 13/11/12.
//  Copyright 2012 . All rights reserved.
//

#import "Printer.h"

#define LocationX           @"LocationX"
#define LocationY           @"LocationY"
#define LinePoints          @"LinePoints"
#define WidthRadio          @"WidthRadio"
#define Font                @"Font"
#define Angle               @"Angle"
#define Height              @"Height"
#define Width               @"Width"

#define PrinterBegin        @"^XA"
#define PrinterLineEnd      @"^FS"
#define PrinterEnd          @"^XZ"
#define BarcodeDefinition   @"^B3,N,N,N,N"


#define FlagBoth            0
#define FlagBarcode         1
#define FlagText            2
#define Flag2DBarcode       3


@implementation Printer


int speed_arr[] = { B115200, B38400, B19200, B9600, B4800, B2400, B1200, B300};
int name_arr[] = {115200, 38400,  19200,  9600,  4800,  2400,  1200,  300};

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        m_strPrint = [[NSMutableString alloc]init];
        m_strBarcodeLocation = [[NSMutableString alloc]initWithString:@"^FO30,10"];
        m_strTextLocation = [[NSMutableString alloc]initWithString:@"^FO30,50"];
        m_strBarcodeDefinition = [[NSMutableString alloc]initWithString:@"^BY0.8,1.5,25"];
        m_strTextDefinition = [[NSMutableString alloc]initWithString:@"^A0.8,30,30"];
        m_str2DBarcodeCmd  = [[NSMutableString alloc]initWithString:@"^BXN,4,200,,,,"];
    }
    
    return self;
}


-(void)dealloc
{
    [m_strTextDefinition release];
    [m_strTextLocation release];
    [m_strBarcodeLocation release];
    [m_strBarcodeDefinition release];
    [m_strPrint release];
    [m_str2DBarcodeCmd release];
    [super dealloc];
}
 
/**
 *@brief open the serial port
 *@param Dev (char) the serial port path
 *@retrun int
 */
int OpenDev(char *Dev)
{
	int	fd = open( Dev, O_RDWR );         //| O_NOCTTY | O_NDELAY	
	if (-1 == fd)	
	{ 			
		perror("Can't Open Serial Port");
        //[];
		return -1;		
	}	
	else	
        return fd;
}


/**
 *@brief  set serial port communitcate speed
 *@param  fd   (int)  the handle of open serial port file
 *@param  speed  (int) serial port speed
 *@return void
 */

void set_speed(int fd, int speed)
{
	int   i; 
	int   status; 
	struct termios   Opt;
	tcgetattr(fd, &Opt); 
	for ( i= 0;  i < sizeof(speed_arr) / sizeof(int);  i++) 
    { 
		if  (speed == name_arr[i]) {     
			tcflush(fd, TCIOFLUSH);     
			cfsetispeed(&Opt, speed_arr[i]);  
			cfsetospeed(&Opt, speed_arr[i]);   
			status = tcsetattr(fd, TCSANOW, &Opt);  
			if  (status != 0) {        
				perror("tcsetattr fd");  
				return;     
			}    
			tcflush(fd,TCIOFLUSH);   
		}  
	}
}

/**
 *@brief  set serial port information, ex: databits,stopbits,check codes
 *@param  fd  (int) the handle of open serial port file
 *@param  databits  (int) databits, the value is 7 or 8
 *@param  stopbits  (int) stopbits, the value is 1 or 2
 *@param  parity   (int)  validation type, the value is N,E,O,S
 *@return int
 */
int set_Parity(int fd,int databits,int stopbits,int parity)
{ 
	struct termios options; 
	if  ( tcgetattr( fd,&options)  !=  0) { 
		perror("SetupSerial 1");     
		return(FALSE);  
	}
	options.c_cflag &= ~CSIZE; 
	switch (databits) /*set databits*/
	{   
		case 7:		
			options.c_cflag |= CS7; 
			break;
		case 8:     
			options.c_cflag |= CS8;
			break;   
		default:    
			fprintf(stderr,"Unsupported data size\n"); return (FALSE);  
	}
	switch (parity) 
	{   
		case 'n':
		case 'N':    
			options.c_cflag &= ~PARENB;   /* Clear parity enable */
			options.c_iflag &= ~INPCK;     /* Enable parity checking */ 
			break;  
		case 'o':   
		case 'O':     
			options.c_cflag |= (PARODD | PARENB); /*set Odd parity*/  
			options.c_iflag |= INPCK;             /* Disnable parity checking */ 
			break;  
		case 'e':  
		case 'E':   
			options.c_cflag |= PARENB;     /* Enable parity */    
			options.c_cflag &= ~PARODD;   /* set even parity*/     
			options.c_iflag |= INPCK;       /* Disnable parity checking */
			break;
		case 'S': 
		case 's':  /*as no parity*/   
			options.c_cflag &= ~PARENB;
			options.c_cflag &= ~CSTOPB;break;  
		default:   
			fprintf(stderr,"Unsupported parity\n");    
			return (FALSE);  
	}  
	
	if (parity != 'n')   
		options.c_iflag |= INPCK; 
	tcflush(fd,TCIFLUSH);
	options.c_cc[VTIME] = 150; /* set timeout 15 seconds*/   
	options.c_cc[VMIN] = 0; /* Update the options and do it NOW */
	if (tcsetattr(fd,TCSANOW,&options) != 0)   
	{ 
		perror("SetupSerial 3");   
		return (FALSE);  
	} 
	return (TRUE);  
}

kern_return_t FindUSB(io_iterator_t *matchingServices)
{
	kern_return_t kernResult;
	CFMutableDictionaryRef classToMatch;
	classToMatch = IOServiceMatching(kIOSerialBSDServiceValue);
	if (classToMatch == NULL) 
    {
		printf("IOServiceMatching returned a NULL dictionary.\n");
	}
	else {
		CFDictionarySetValue(classToMatch, CFSTR(kIOSerialBSDTypeKey), CFSTR(kIOSerialBSDRS232Type));
	}
	kernResult = IOServiceGetMatchingServices(kIOMasterPortDefault,classToMatch,matchingServices);
	if (KERN_SUCCESS!=kernResult) 
    {
		printf("IOServiceGetMatchingServices error returned %d\n",kernResult);
		return kernResult;
	}
    return kernResult;
}

kern_return_t GetUSBPath(io_iterator_t serialPortIterator,char *bsdPath,CFIndex maxPathSize)
{
//	NSString	*szUSB_Name = [[NSUserDefaults standardUserDefaults] valueForKey:@"USB_NAME"];	
//	if (!szUSB_Name)
//		szUSB_Name = @"PRINTER";
     NSString *szUSB_Name = @"PRINTER";
	char *compareString=(char *)malloc(100*sizeof(char));
	strcpy(compareString, [szUSB_Name UTF8String]);
	char buff[1024];
	io_object_t USBService;
	kern_return_t kernResult=KERN_FAILURE;
	*bsdPath='\0';
	while ((USBService = IOIteratorNext(serialPortIterator))){
		memset(buff,0,1024*sizeof(char));
		CFTypeRef bsdPathAsCFString;
		bsdPathAsCFString = IORegistryEntryCreateCFProperty(USBService, CFSTR(kIOCalloutDeviceKey), kCFAllocatorDefault, 0);
		if (bsdPathAsCFString) {
			BOOL result;
			result = CFStringGetCString(bsdPathAsCFString, bsdPath, maxPathSize, kCFStringEncodingUTF8);
			CFRelease(bsdPathAsCFString);
			if (result) {
				printf("USB path: %s",bsdPath);
			}
		}
        printf("\n");
		if (strstr(bsdPath, compareString)!=NULL) {
			(void)IOObjectRelease(USBService);
            kernResult = KERN_SUCCESS;
			break;
		}
	}
    if (kernResult != KERN_SUCCESS)
    {
        NSRunAlertPanel(@"Warning", @"Can't find printer cable,or the cable name is not correct,please check the cable!", @"OK", nil, nil);
    }
    free(compareString);
	return kernResult;
}

/**
 *@brief set the pre contents of print command ex:"^XA"
 *@param nil
 *@retrun int
 */
- (void)SetPreContents
{
    [m_strPrint setString:@""];
    [m_strPrint appendString:PrinterBegin];
}

/**
 *@brief set the end contents of print command ex:"^XZ"
 *@param nil
 *@retrun int
 */
- (void)SetEndContents
{
    [m_strPrint appendString:PrinterEnd];
}

/**
 *@brief  set print count  (^PQq,p,r,o)
 *@param  iTimes  (NSString) print label count default value is 1
 *@param  iPauseTimes  (NSString) cut or pause after print iCutTimes lable  default is 0(no pause)
 *@param  iCopyTimes  (NSString) every serial num. copy times, default is 1(no copy)
 *@param  ContinusPrint   (BOOL)  continus print the label or not,default value is N
 *@return BOOL
 */
- (BOOL) SetPrinterCount:(NSString *)strTimes PauseTimes: (NSString *)strPauseTimes NumRepeatTimes:(NSString *)strCopyTimes ContinusPrint:(BOOL)bContinusPrint
{
    NSMutableString *strPrintCount = [[NSMutableString alloc]init];
    [strPrintCount appendString:@"^PQ"];
   // set print lables count 
    if (!strTimes || [strTimes isEqualToString:@""]) 
    {
        [strPrintCount appendString:@"1"];
    }
    else
        [strPrintCount appendString:strTimes];
    [strPrintCount appendString:@","];
    //set print pause when print strPauseTimes label
    if (!strPauseTimes || [strPauseTimes isEqualToString:@""])
    {
        [strPrintCount appendString:@"0"];
    }
    else
        [strPrintCount appendString:strPauseTimes];
    [strPrintCount appendString:@","];
    
    //set every num print times
    if (!strCopyTimes || [strCopyTimes isEqualToString:@""])
    {
        [strPrintCount appendString:@"1"];
    }
    else
        [strPrintCount appendString:strCopyTimes];
    [strPrintCount appendString:@","];
    //Continus print or not
    if (bContinusPrint)
    {
        [strPrintCount appendString:@"Y"];
    }
    else
        [strPrintCount appendString:@"N"];
    
    [m_strPrint appendString:[NSString stringWithFormat:@"%@",strPrintCount]];
    [strPrintCount release];
    return YES;
}

/**
 *@brief  set 2DBarcode command ex:(^BXN,4,200,,,,)
 *@param  strCode  (NSString) barcode rule.ex: X==> 2D barcode matrix 7==> PDF417 barcode
 *@param  strDirection  (NSString) set barcode direction: N==> normal, R==> Roated, I==> Inverted, B==>ottom
 *@param  strLayer  (NSString) set encoding layer
 *@param  strHeight  (NSString) set each layer height
 *@return BOOL
 */
- (BOOL)Set2DBarcodeCommand:(NSString*)strCode Direction:(NSString *)strDirection Layer:(NSString *)strLayer Hight:(NSString *)strHeight
{
    if (!strCode || [strCode isEqualToString:@""])
    {
        strCode = @"X";
    }
    
    if (!strDirection || [strDirection isEqualToString:@""])
    {
        strDirection = @"N";
    }
    
    if (!strLayer || [strLayer isEqualToString:@""])
    {
        strLayer = @"4";
    }
    
    if (!strHeight || [strHeight isEqualToString:@""])
    {
        strHeight = @"200";
    }
    
    [m_str2DBarcodeCmd setString:[NSString stringWithFormat:@"^B%@%@,%@,%@,,,,",strCode,strDirection,strLayer,strHeight]];
    return YES;
}

/**
 *@brief  set print content location (^FOX,Y)
 *@param  strLocationX  (NSString) the print content x coordinate
 *@param  strLocationY  (NSString) the print content y coordinate
 *@param  iFlag  (int) the flag for setting barcode or text location, 0 is for barcode, 1 is for text
 *@return BOOL
 */

- (BOOL)SetFieldLocationX:(NSString *)strLocationX FiledLocationY:(NSString *)strLocationY BarcodeOrText:(int)iFlag
{
    if (!strLocationX || [strLocationX isEqualToString:@""] || !strLocationY || [strLocationY isEqualToString:@""])
    {
        NSLog(@"the location definition is error!");
        return NO;
    }
    // iFlag 1--> Barcode  2--> Text
    switch (iFlag) 
    {
        case FlagBarcode:
            {
                [m_strBarcodeLocation setString:[NSString stringWithFormat:@"^FO%@,%@",strLocationX,strLocationY]];
                
                NSLog(@"the loaction of Barcode is %@",m_strBarcodeLocation);
                break;
            }
        case FlagText:
            {
                [m_strTextLocation setString: [NSString stringWithFormat:@"^FO%@,%@",strLocationX,strLocationY]];
                NSLog(@"the loaction of Text is %@",m_strTextLocation);
                break;
            }
        default:
            {
                return NO;
                break;
            }
    }
    return YES;
}

/**
 *@brief  set barcode field definition (^BYi,j,b)
 *@param  strNarrowLineLength  (NSString) the narrow line length
 *@param  strRadio  (NSString) the radio of barcode width line and height line
 *@param  strHeight  (NSString) the Barcode height
 *@return BOOL
 */
- (BOOL)SetBarcodeNarrowLineLength: (NSString *)strNarrowLineLength WidthHeightRadio:(NSString *)strRadio BarcodeHeight:(NSString *)strHeight
{
    if (!strNarrowLineLength || !strRadio || !strHeight || [strNarrowLineLength isEqualToString:@""] || [strRadio isEqualToString:@""] || [strHeight isEqualToString:@""])
    {
        NSLog(@"the setting of barcode field definition is wrong!");
        return NO;
    }
    [m_strBarcodeDefinition setString:[NSString stringWithFormat:@"^BY%@,%@,%@",strNarrowLineLength,strRadio,strHeight]];
    NSLog(@"the barcode definition is %@",m_strBarcodeDefinition);
    return YES;
}

/**
 *@brief  set text field definition (^Axa,b,c)
 *@param  strFont  (NSString) set text font A~Z,0...
 *@param  strAngle  (NSString) set font angle   N-->0  R-->90 I-->180 B--> 270
 *@param  strHeight  (NSString) set font height
 *@param  strWidth  (NSString) set font width
 *@return BOOL
 */
- (BOOL)SetTextFont:(NSString *)strFont TextAngle:(NSString *)strAngle TextHeight:(NSString *)strHeight TextWidth:(NSString *)strWidth
{
    [m_strTextDefinition setString:[NSString stringWithFormat:@"^A%@%@,%@,%@",strFont,strAngle,strHeight,strWidth]];
    NSLog(@"the text file definition is %@",m_strTextDefinition);
    return YES;
}

/**
 *@brief combine printer command
 *@param strBarInput   (NSString *) the string you want to print
 *@param strText    (NSString *) the text string you want to print
 *@param iType     type of print: 0 ==> printer barcode and text  1===>only print barcode  2 ==> only print text 3 ==> print 2D barcode
 *@return BOOL
 */

- (BOOL)CombineCmdBarContent:(NSString *)strBarInput TextContent:(NSString *)strText PrintType:(int)iType
{
    BOOL bRet = YES;
    //Combine the print command
    NSString *strTextContent = [NSString stringWithFormat:@"^FD%@",strText];
    NSString *strBarcodeContent = [NSString stringWithFormat:@"^FD%@",strBarInput];
    switch (iType) 
    {
        case FlagBoth: //print both barcod and text
        {
            [m_strPrint appendString:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@",m_strBarcodeLocation,m_strBarcodeDefinition,BarcodeDefinition,strBarcodeContent,PrinterLineEnd,m_strTextLocation,m_strTextDefinition,strTextContent,PrinterLineEnd]];
            [m_strBarcodeLocation setString:@""];
            [m_strBarcodeDefinition setString:@""];
            [m_strTextLocation setString:@""];
            [m_strTextDefinition setString:@""];
            break;

        }       
        case FlagBarcode: // only print barcode
        {
            [m_strPrint appendString:[NSString stringWithFormat:@"%@%@%@%@%@",m_strBarcodeLocation,m_strBarcodeDefinition,BarcodeDefinition,strBarcodeContent,PrinterLineEnd]];
            [m_strBarcodeDefinition setString:@""];
            [m_strBarcodeLocation setString:@""];
            break;
        }
        case FlagText: // only print text
        {
            [m_strPrint appendString:[NSString stringWithFormat:@"%@%@%@%@",m_strTextLocation,m_strTextDefinition,strTextContent,PrinterLineEnd]];
            [m_strTextLocation setString:@""];
            [m_strTextDefinition setString:@""];
            break;
        }
        case Flag2DBarcode:
        {
            [m_strPrint appendString:[NSString stringWithFormat:@"%@%@%@%@",m_strBarcodeLocation,m_str2DBarcodeCmd,strBarInput,PrinterLineEnd]];
            [m_strBarcodeLocation setString:@""];
            [m_str2DBarcodeCmd setString:@""];
            break;
        }
        default:
        { 
            bRet = NO;
            break;
        }
    }
    return bRet;
}

/**
 *@brief set print darkness
 *@param strDarkness  (NSString) set printer thick darkness
 *@return BOOL
 */

- (BOOL)SetDarkness:(NSString *)strDarkness
{
    if (!strDarkness || [strDarkness isEqualToString:@""])
    {
        return YES;
    }
    // set darkness ex: ^MD10
    [m_strPrint appendString:[NSString stringWithFormat:@"^MD%@",strDarkness]];
    return YES;
}

/**
 *@brief  print the lable
 *@return void
 */
- (int)Print 
{
    int iRet = -1;
    int fd;
    kern_return_t kernResult;
    io_iterator_t serialPortIterator;
    char bsdPath[100];
    // find priter usb port and open the port
    kernResult=FindUSB(&serialPortIterator);
    kernResult=GetUSBPath(serialPortIterator,bsdPath,sizeof(bsdPath));
    if (kernResult != KERN_SUCCESS) 
    {
        return -1;
    }
    IOObjectRelease(serialPortIterator);
    fd = OpenDev(bsdPath);
    set_speed(fd,9600);
    if (set_Parity(fd,8,1,'N') == FALSE)  {
        printf("Set Parity Error\n");
        exit (0);
    }

    char buff[2048];
    strcpy(buff,[m_strPrint UTF8String]);
    NSLog(@"print value is %@",m_strPrint);
    [m_strPrint setString:@""];
    // write command to printer and print the label
    iRet = (int) write(fd,buff,strlen(buff));
    return iRet;
}

@end
