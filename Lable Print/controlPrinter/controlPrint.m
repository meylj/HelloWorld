//
//  controlPrint.m
//  controlPrinter
//
//  Created by Leehua on 10-9-6.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "controlPrint.h"


@implementation controlPrint
//#define	kHTTP_Request	@"http://10.16.16.26/ForPerlRequest/SFCTest?"
#define	kHTTP_Request	@"http://172.28.144.97/ForPerlRequest/SFCTest?"
#define	kLABEL_TYPE		0x001

#define kHTTP_TimeOut	10

int speed_arr[] = { B115200, B38400, B19200, B9600, B4800, B2400, B1200, B300};
int name_arr[] = {115200, 38400,  19200,  9600,  4800,  2400,  1200,  300};

int OpenDev(char *Dev)
{
	int	fd = open( Dev, O_RDWR );         //| O_NOCTTY | O_NDELAY	
	if (-1 == fd)	
	{ 			
		perror("Can't Open Serial Port");
		return -1;		
	}	
	else	
		return fd;
}

void set_speed(int fd, int speed){
	int   i; 
	int   status; 
	struct termios   Opt;
	tcgetattr(fd, &Opt); 
	for ( i= 0;  i < sizeof(speed_arr) / sizeof(int);  i++) { 
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

int set_Parity(int fd,int databits,int stopbits,int parity)
{ 
	struct termios options; 
	if  ( tcgetattr( fd,&options)  !=  0) { 
		perror("SetupSerial 1");     
		return(FALSE);  
	}
	options.c_cflag &= ~CSIZE; 
	switch (databits) /*è®¾ç½®?°æ?ä½??*/
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
			options.c_cflag |= (PARODD | PARENB); /* è®¾ç½®ä¸ºå????*/  
			options.c_iflag |= INPCK;             /* Disnable parity checking */ 
			break;  
		case 'e':  
		case 'E':   
			options.c_cflag |= PARENB;     /* Enable parity */    
			options.c_cflag &= ~PARODD;   /* è½??ä¸ºå????*/     
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
	/* è®¾ç½®???ä½?/  
	switch (stopbits)
	{   
		case 1:    
			options.c_cflag &= ~CSTOPB;  
			break;  
		case 2:    
			options.c_cflag |= CSTOPB;  
			break;
		default:    
			fprintf(stderr,"Unsupported stop bits\n");  
			return (FALSE); 
	} 
	/* Set input parity option */ 
	if (parity != 'n')   
		options.c_iflag |= INPCK; 
	tcflush(fd,TCIFLUSH);
	options.c_cc[VTIME] = 150; /* è®¾ç½®è¶??15 seconds*/   
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
	if (classToMatch == NULL) {
		printf("IOServiceMatching returned a NULL dictionary.\n");
	}
	else {
		CFDictionarySetValue(classToMatch, CFSTR(kIOSerialBSDTypeKey), CFSTR(kIOSerialBSDRS232Type));
	}
	kernResult = IOServiceGetMatchingServices(kIOMasterPortDefault,classToMatch,matchingServices);
	if (KERN_SUCCESS!=kernResult) {
		printf("IOServiceGetMatchingServices returned %d\n",kernResult);
		return kernResult;
	}
}

kern_return_t GetUSBPath(io_iterator_t serialPortIterator,char *bsdPath,CFIndex maxPathSize)
{
	NSString	*szUSB_Name = [[NSUserDefaults standardUserDefaults] valueForKey:@"USB_NAME"];	
	if (!szUSB_Name)
		szUSB_Name = @"ftE2H9WJ";
    
    NSLog(@"szUSB_Name----------------%@",szUSB_Name);
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
				kernResult=KERN_SUCCESS;
			}
		}
		printf("\n");
		if (strstr(bsdPath, compareString)!=NULL) {
			(void)IOObjectRelease(USBService);
			break;
		}
	}
	return kernResult;
}

-(int) print : (NSString *)szInput
{
	int fd;
	char sn[512];
	strcpy(sn,[szInput UTF8String]);
	//strcat(sn,"^FS");
	char buff[512];
	char *position;
	char *compareString = "CCH0013004VD004AK000";
	kern_return_t kernResult;
	io_iterator_t serialPortIterator;
	char bsdPath[100];
	kernResult=FindUSB(&serialPortIterator);
	kernResult=GetUSBPath(serialPortIterator,bsdPath,sizeof(bsdPath));
	IOObjectRelease(serialPortIterator);
	fd = OpenDev(bsdPath);
	set_speed(fd,9600);
	if (set_Parity(fd,8,1,'N') == FALSE)  {
		printf("Set Parity Error\n");
		exit (0);
	}
	//char ex1[] ="^XA^FO190,40^BY1,2,20^B1,,N,N,N^FDD0203101H4100001^FS^FO200,70^A0,20,15^FDD0203101H4100001^FS^PQ1^XZ";
	//char *ex1=(char *)malloc(100*sizeof(char));
	//strcpy(ex1,[szInput UTF8String]);
	/*NSString *szFirst = [NSString stringWithFormat:@"^XA^FO45,15^BY1,2,30^BC,,N,N,N^FD"];
	NSString *szEnd = [NSString stringWithFormat:@"^FS^PQ*1^XZ"];
	if([szInput length] <=0 )
	{
		NSRunAlertPanel(@"Warning", @"print error : no input", @"OK", nil, nil);
		return;
	}
	NSString *szToPrint = [NSString stringWithFormat:@"%@%@%@",szFirst,szInput,szEnd];
	write(fd, [szToPrint UTF8String], strlen([szToPrint UTF8String]));*/
	//write(fd,"^XA",strlen("^XA"));
	
	//write(fd,"^PQ*1",strlen("^PQ*1");
	//write(fd,"^XZ",strlen("^XZ");
	int iRet =-1;
	FILE *h = fopen("/usr/local/PRINTER_COMMAND.txt", "r");
	if (h!=NULL) {
		while (fgets(buff, 512, h)!=NULL) {
			if ((position=strstr(buff, compareString))!=NULL) {
				strcpy(position,sn);
				memmove(position+strlen([szInput UTF8String]),position+strlen(compareString),strlen(position+strlen(compareString))+1);
			}
			iRet = write(fd, buff, strlen(buff));
		}
	}
		else {
			printf("Whether the PRINTER_COMMAND.txt is exist!!");
		}
	fclose(h);
	return iRet;
}

- (BOOL)getDataFromSFC:(NSUInteger) nQureyPattern SysNum : (NSString *) pSysNumber 
			 SFC_ResultData : (NSString **) szReturnValue {
	NSArray				*aryQuery = [NSArray arrayWithObjects:
									 [NSNumber numberWithUnsignedInt:kLABEL_TYPE],@"label_type",nil];
	BOOL				bResult = YES;
	NSError				*errors;
	NSString	*szMLBSN;
	m_Response = [NSString stringWithFormat:@""];
	
	if (bResult) {
		NSInteger			nCount;
		NSData				*getData;
		NSHTTPURLResponse	*theResponse;
		NSMutableURLRequest	*theRequest = [NSMutableURLRequest alloc];
		NSMutableString		*szURL_Addr = [[NSMutableString alloc] initWithString:kHTTP_Request];		
		NSNumber			*pNumData;
		NSMutableDictionary	*dictQueryData = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
		
		[szURL_Addr appendFormat:@"command=QUERY_RECORD&sn=%@&query=",pSysNumber];
		for (nCount = 0;nCount < [aryQuery count];nCount += 2) {
			pNumData = [aryQuery objectAtIndex:nCount];
			if (([pNumData unsignedIntegerValue] & nQureyPattern) > 0) {
				[szURL_Addr appendFormat:@"%@%%20",[aryQuery objectAtIndex:nCount+1]];
				[dictQueryData setObject:[aryQuery objectAtIndex:nCount+1] forKey:pNumData];
			}
		}
		NSLog(@"getDataFromSFC : Request URL => %@", szURL_Addr);
		theRequest = [theRequest initWithURL:[NSURL URLWithString:szURL_Addr]];
		[theRequest setHTTPMethod:@"POST"];
		[theRequest setValue:@"text/html;charset=UTF8" forHTTPHeaderField:@"Content-Type"];
		[theRequest setTimeoutInterval:kHTTP_TimeOut];
		getData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&theResponse error:&errors];
		NSLog(@"getDataFromSFC : rangeOfString = %d", [(NSHTTPURLResponse *)theResponse statusCode]);
		if ([(NSHTTPURLResponse *)theResponse statusCode] == 200) {
			NSString	*szResposeData = [[NSString alloc] initWithData:getData encoding:NSUTF8StringEncoding];
			NSLog(@"JSP(1) response : %@",szResposeData);
			m_Response = [NSString stringWithFormat:@"%@", szResposeData];
			NSLog(@"getDataFromSFC : m_Response = %@", m_Response);
			NSRange		nRange;
			NSArray		*aryKeys = [dictQueryData allKeys];
			NSString	*szValue;
			NSLog(@"getDataFromSFC : aryKeys = %d", [aryKeys count]);
			for (nCount = 0;nCount < [aryKeys count];nCount ++) {
				pNumData = [aryKeys objectAtIndex:nCount];
				NSLog(@"getDataFromSFC : pNumData = %d", pNumData);
				szValue = [dictQueryData objectForKey:pNumData];
				NSLog(@"getDataFromSFC : szValue = %@", szValue);
				nRange = [szResposeData rangeOfString:[NSString stringWithFormat:@"%@=",szValue]];
				if (nRange.location == NSNotFound) {
					NSLog(@"getDataFromSFC : rangeOfString = %@", szResposeData);
					[dictQueryData setObject:@"" forKey:pNumData];
					bResult = NO;
					//break;
				}
				else {
					NSString *szNewData = [szResposeData substringFromIndex:nRange.location+nRange.length];
					nRange = [szNewData rangeOfString:@"\n"];
					if (nRange.location == NSNotFound)
						[dictQueryData setObject:szNewData forKey:pNumData];
					else 
						[dictQueryData setObject:[szNewData substringToIndex:nRange.location] forKey:pNumData];	
					NSCharacterSet *chaset = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
					szMLBSN = [[dictQueryData objectForKey:pNumData] stringByTrimmingCharactersInSet:chaset];
					[dictQueryData setObject:szMLBSN forKey:pNumData];
				}		
			}
			[szResposeData release];
		}
		else {
			NSLog(@"getDataFromSFC : statusCode = %d, Response Headers = %@",
				  [(NSHTTPURLResponse *)theResponse statusCode],
				  [(NSHTTPURLResponse *)theResponse allHeaderFields]);
			bResult = NO;
		}
		*szReturnValue = [dictQueryData objectForKey:pNumData];
		if(nil == *szReturnValue)
		{
			*szReturnValue = @"";
		}
		
		[szURL_Addr release];
		[theRequest release];
	}
	return bResult;
}

- (BOOL)judgeJSPResponse:(NSString **)szReturnValue
{
	NSRange range = {0,1};
	NSString *firstStr = nil;
	BOOL bState = YES;
	NSLog(@"JSP(2) response : %@",m_Response);
	if(![m_Response isEqualToString:@""] && [m_Response length]>1)
	{
		firstStr = [m_Response substringWithRange:range];
		NSLog(@"Response:%@",m_Response);
		switch([firstStr intValue])
		{
			case 0:
				if([*szReturnValue length] > 0)
				{
				    NSLog(@"JSP response : OK");
				}
				else
				{
					NSLog(@"Unnormal");
					*szReturnValue = @"Unnormal";
				}				
				bState = YES;
				break;
			case 1:
				*szReturnValue = @"1. Can not link class (GetLinkStr. getQueryString) 2. DB connect Exception";
				bState = NO;
				break;
			case 2:
				*szReturnValue = @"SFC Web Server no response";
				bState = NO;
				break;
			case 3:
				*szReturnValue = @"1. SN: Station ID: Start time: Stop time: result: list_of_failing_tests (if fail):.. format is wrong (length: special characters: ?? or missing 2. Can not find required items (maybe caused by data loss)";
				bState = NO;
				break;
			case 4:
				*szReturnValue = @"Command not define (there are only two commands now: ADD_RECORD and QUERY_RECORD)";
				bState = NO;
				break;
			case 5:
				*szReturnValue = @"Station ID can't find in SFC list";
				bState = NO;
				break;
			case 6:
				*szReturnValue = @"SN not exist";
				bState = NO;
				break;
			case 7:
				*szReturnValue = @"data not exist";
				bState = NO;
				break;
			default:
				*szReturnValue = @"condition is not exist";
				bState = NO;
				break;
		}
	}
	else 
	{
		*szReturnValue = @"JSP No response/ Timeout or no request";
		bState = NO;
	}
	NSLog(@"JudgeJSPResponse : %@",*szReturnValue);
	return bState;
}

@end
