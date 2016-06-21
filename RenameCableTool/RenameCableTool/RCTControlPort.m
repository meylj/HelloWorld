//
//  RCTControlPort.m
//  RenameCableTool
//
//  Created by raniys on 2/10/14.
//  Copyright (c) 2014 raniys. All rights reserved.
//

#import "RCTControlPort.h"

@implementation RCTControlPort
@synthesize RS232 = m_iRS232;

//init
-(id)init
{
    if (self = [super init])
    {
        m_iRS232        = -1;
    }
    return self;
}

-(void)dealloc
{
    [super dealloc];
    
}

//to find the port which has connected DUT
+ (NSArray *)SearchSerialPorts
{
	NSMutableArray *arrSerialPorts = [[[NSMutableArray alloc] init] autorelease];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:@"/dev" error:nil];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self BEGINSWITH 'cu.usbserial'"];
    NSArray *serialPorts = [dirContents filteredArrayUsingPredicate:fltr];
    
    NSMutableArray *tmp = [NSMutableArray new];
    for (NSString *name in serialPorts) {
        [tmp addObject:[NSString stringWithFormat:@"/dev/%@", name]];
    }
    arrSerialPorts = [NSMutableArray arrayWithArray:tmp];
    
//	int iFound = 0;
//	NSComparisonResult		iResult;  //enum
//	kern_return_t			kernResult;  //int
//	CFMutableDictionaryRef	classesToMatch;     //struct
//	io_iterator_t			serialPortIterator;  //unsinged int
//	
//	classesToMatch = IOServiceMatching(kIOSerialBSDServiceValue);
//    NSLog(@"classesToMatch: %@", classesToMatch);
//	if (NULL != classesToMatch)
//	{
//		CFDictionarySetValue(classesToMatch, CFSTR(kIOSerialBSDTypeKey), CFSTR(kIOSerialBSDAllTypes));
//		
//		kernResult = IOServiceGetMatchingServices(kIOMasterPortDefault, classesToMatch, &serialPortIterator);
//		if (KERN_SUCCESS == kernResult)
//		{
//			do
//			{
//				io_object_t serialService = IOIteratorNext(serialPortIterator);
//				if (0 != serialService)
//				{
//					CFStringRef modemName = (CFStringRef)IORegistryEntryCreateCFProperty(serialService, CFSTR(kIOTTYDeviceKey), kCFAllocatorDefault, 0);
//					CFStringRef bsdPath = (CFStringRef)IORegistryEntryCreateCFProperty(serialService, CFSTR(kIOCalloutDeviceKey), kCFAllocatorDefault, 0);
//					CFStringRef serviceType = (CFStringRef)IORegistryEntryCreateCFProperty(serialService, CFSTR(kIOSerialBSDTypeKey), kCFAllocatorDefault, 0);
//					iResult = [(NSString *)modemName compare:@"cu.usbserial"];
//					
//					if ((int) iResult == 1)
//					{
//						NSString *szPathTemp = [[NSString alloc] initWithFormat:@"%@",(NSString *)bsdPath];
//						[arrSerialPorts addObject:szPathTemp];
//						[szPathTemp release];
//						//iFound = 1;
//					}
//					NSLog(@"modemName = %@,bsdPath = %@,serviceType = %@",modemName,bsdPath,serviceType);
//					CFRelease(modemName);
//					CFRelease(bsdPath);
//					CFRelease(serviceType);
//				}
//				else
//					break;
//			} while (!iFound);
//			(void)IOObjectRelease(serialPortIterator);
//		}
//		NSLog(@"IOServiceGetMatchingServices returned %d", kernResult);
//	}
	
	return arrSerialPorts;
}

//to open serial port
- (BOOL)OpenSerialPort:(NSString *)strPath withBit:(int)iBit withStop:(int)iStop withBaudRate:(int)iBaudRate withParity:(NSString *)szParity ErrorMesg:(NSString **)strErr
{
	BOOL bResult = NO;
	if (nil == strPath) {
		*strErr = @"Open serial port fail : path is [nil]";
		return NO;
	}
	m_iRS232 = open([strPath UTF8String],  O_RDWR|O_NOCTTY|O_NONBLOCK);
	if (m_iRS232<0) {
		*strErr = @"Open serial port fail : m_iRS232 < 0";
		bResult = NO;
	}
	else
	{
		uint8 parity = [szParity characterAtIndex:0]; //char
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
				m_rsNewTerm.c_cflag |= (PARODD | PARENB);
				m_rsNewTerm.c_iflag |= INPCK;             /* Disnable parity checking */
				break;
			case 'e':
			case 'E':
				m_rsNewTerm.c_cflag |= PARENB;			/* Enable parity */
				m_rsNewTerm.c_cflag &= ~PARODD;
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

//send command and read the value
- (NSString *)ControlThePort:(NSString *) command
{
    uint8 buffer[1024] = {0};
    long iLength;
    iLength = write(m_iRS232, [command UTF8String], [command length]);
    if (iLength != [command length])
    {
        NSLog(@"wrote command %@ error! The command length is:%d", command,[command length]);
        exit(1);
    }
    NSLog(@"Wrote %ld bytes for the device.", iLength);
    sleep(1);
    long readLength     =  read(m_iRS232, buffer, sizeof(buffer));
    if (readLength > 0)
        return [NSString stringWithFormat:@"%s",buffer];
    else
        return @"";
}

@end
