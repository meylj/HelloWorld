//  controlPrint.m
//  controlPrinter
//
//  Created by Leehua on 10-9-6.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "controlPrint.h"


@implementation controlPrint

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
	switch (databits) /*ËÆæÁΩÆ?∞Ê?‰Ω??*/
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
			options.c_cflag |= (PARODD | PARENB); /* ËÆæÁΩÆ‰∏∫Â????*/  
			options.c_iflag |= INPCK;             /* Disnable parity checking */ 
			break;  
		case 'e':  
		case 'E':   
			options.c_cflag |= PARENB;     /* Enable parity */    
			options.c_cflag &= ~PARODD;   /* ËΩ??‰∏∫Â????*/     
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
	/* ËÆæÁΩÆ???‰Ω?/  
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
	options.c_cc[VTIME] = 150; /* ËÆæÁΩÆË∂??15 seconds*/   
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
		szUSB_Name = @"PRINTER";
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

@end
