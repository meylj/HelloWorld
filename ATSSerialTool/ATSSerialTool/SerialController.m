//
//  SerialController.m
//  ATSSerialTool
//
//  Created by Lorky Luo on 5/31/12.
//  Copyright 2012 Pegatron. All rights reserved.
//

#import "SerialController.h"

@implementation SerialController

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
		m_iRS232 = -1;
    }
    
    return self;
}

- (void)CloseSerialPort
{
	if (m_iRS232 > 0) {
		tcsetattr(m_iRS232, TCSANOW, &(m_rsOriTerm));
		close(m_iRS232);
	}
}

- (BOOL)isOpen
{
	return m_iRS232>0;
}

- (long)sendCommand:(id)idCommand
{
	if ([idCommand isKindOfClass:[NSString class]])
		return write(m_iRS232, [idCommand UTF8String], [idCommand length]);
	else if ([idCommand isKindOfClass:[NSData class]])
		return write(m_iRS232, [idCommand bytes], [idCommand length]);
	return 0;
}

- (NSString *)readCommand
{
	UInt8 commandReturn[1024]={0};
	long lengthRead;
	NSDate *dStratTime = [NSDate date];
	NSMutableString *szReturnString = [[[NSMutableString alloc] init] autorelease];
	NSTimeInterval dEndTime = 0.0;
	do
	{
		lengthRead = read(m_iRS232, commandReturn, sizeof(commandReturn));
		if (lengthRead>0) {
			
				NSString *szReturn = [[NSString alloc] initWithBytes:commandReturn length:lengthRead encoding:NSASCIIStringEncoding];
				[szReturnString appendString:szReturn];
				[szReturn release];
		}
		dEndTime = [[NSDate date] timeIntervalSinceDate:dStratTime];
	} while (ReadTimeOut>=dEndTime);
	return szReturnString;
}

- (BOOL)OpenSerialPort:(NSString *)path withBit:(int)iBit withStop:(int)iStop withBaudRate:(int)iBaudRate withParity:(NSString *)szParity ErrorMesg:(NSString **)strErr
{
	BOOL bResult = NO;
	if (nil == path) {
		*strErr = @"Open serial port fail : path is [nil]"; 
		return NO;
	}
	m_iRS232 = open([path UTF8String],  O_RDWR|O_NOCTTY|O_NONBLOCK);
	if (m_iRS232<0) {
		*strErr = @"Open serial port fail : m_iRS232 < 0"; 
		bResult = NO;
	}
	else
	{
		uint8 parity = [szParity characterAtIndex:0];
		tcgetattr(m_iRS232,&(m_rsOriTerm));
		memset(&m_rsNewTerm, 0, sizeof(struct termios));
		cfmakeraw(&m_rsNewTerm);
		
		// set Bits
		switch (iBit) 
		{   
			case 7:		
				m_rsNewTerm.c_cflag |= CS7; 
				break;
			case 8:     
				m_rsNewTerm.c_cflag |= CS8;
				break;   
			default:    
				fprintf(stderr,"Unsupported data size\n");
				return NO;  
		}
		
		// set Parity
		switch (parity) 
		{   
			case 'n':
			case 'N':    
				m_rsNewTerm.c_cflag &= ~PARENB;   /* Clear parity enable */
				m_rsNewTerm.c_iflag &= ~INPCK;     /* Enable parity checking */ 
				break;  
			case 'o':   
			case 'O':     
				m_rsNewTerm.c_cflag |= (PARODD | PARENB); /* ËÆæÁΩÆ‰∏∫Â????*/  
				m_rsNewTerm.c_iflag |= INPCK;             /* Disnable parity checking */ 
				break;  
			case 'e':  
			case 'E':   
				m_rsNewTerm.c_cflag |= PARENB;			/* Enable parity */    
				m_rsNewTerm.c_cflag &= ~PARODD;			/* ËΩ??‰∏∫Â????*/     
				m_rsNewTerm.c_iflag |= INPCK;			/* Disnable parity checking */
				break;
			case 'S': 
			case 's':  /*as no parity*/   
				m_rsNewTerm.c_cflag &= ~PARENB;
				m_rsNewTerm.c_cflag &= ~CSTOPB;break;  
			default:   
				fprintf(stderr,"Unsupported parity\n");    
				return NO;  
		} 
		// Set stop bit
		switch (iStop)
		{   
			case 1:    
				m_rsNewTerm.c_cflag &= ~CSTOPB;  
				break;  
			case 2:    
				m_rsNewTerm.c_cflag |= CSTOPB;  
				break;
			default:    
				fprintf(stderr,"Unsupported stop bit\n");    
				return NO;  
		} 
		
		m_rsNewTerm.c_cc[VMIN] = 1;
		m_rsNewTerm.c_cc[VTIME] = 1;
		cfsetspeed(&m_rsNewTerm, (speed_t)iBaudRate);
		tcsetattr(m_iRS232, TCSANOW, &m_rsNewTerm);
		bResult = YES;
	}
	return bResult;
}

+ (NSArray *)SearchSerialPorts
{
	NSMutableArray *arrSerialPorts = [[[NSMutableArray alloc] init] autorelease];
	int iFound = 0;
	NSComparisonResult		iResult;
	kern_return_t			kernResult;
	CFMutableDictionaryRef	classesToMatch;
	io_iterator_t			serialPortIterator;
	
	classesToMatch = IOServiceMatching(kIOSerialBSDServiceValue);
	if (NULL != classesToMatch)
	{
		CFDictionarySetValue(classesToMatch, CFSTR(kIOSerialBSDTypeKey), CFSTR(kIOSerialBSDAllTypes));
		
		kernResult = IOServiceGetMatchingServices(kIOMasterPortDefault, classesToMatch, &serialPortIterator);
		if (KERN_SUCCESS == kernResult)
		{
			do 
			{
				io_object_t serialService = IOIteratorNext(serialPortIterator);
				if (0 != serialService) 
				{
					CFStringRef modemName = (CFStringRef)IORegistryEntryCreateCFProperty(serialService, CFSTR(kIOTTYDeviceKey), kCFAllocatorDefault, 0);
					CFStringRef bsdPath = (CFStringRef)IORegistryEntryCreateCFProperty(serialService, CFSTR(kIOCalloutDeviceKey), kCFAllocatorDefault, 0);
					CFStringRef serviceType = (CFStringRef)IORegistryEntryCreateCFProperty(serialService, CFSTR(kIOSerialBSDTypeKey), kCFAllocatorDefault, 0);
					iResult = [(NSString *)modemName compare:@"cu.usbserial"];
					
					if ((int) iResult == 1)
					{
						NSString *szPathTemp = [[NSString alloc] initWithFormat:@"%@",(NSString *)bsdPath];
						[arrSerialPorts addObject:szPathTemp];
						[szPathTemp release];
						//iFound = 1;
					}
					NSLog(@"modemName = %@,bsdPath = %@,serviceType = %@",modemName,bsdPath,serviceType);
					CFRelease(modemName);
					CFRelease(bsdPath);
					CFRelease(serviceType);
				}
				else
					break;
			} while (!iFound);
			(void)IOObjectRelease(serialPortIterator);
		}
		NSLog(@"IOServiceGetMatchingServices returned %d", kernResult);
	}
	
	return arrSerialPorts;
}

@end
