//
//  YYControlPort.m
//  OpenUart
//
//  Created by raniys on 12/26/13.
//  Copyright (c) 2013 raniys. All rights reserved.
//

#import "YYControlPort.h"

@implementation YYControlPort

//init
-(id)init
{
    if (self = [super init])
    {
    }
    return self;
}

-(id)init_Uart
{
    if((self = [super init]))
    {
        m_iRS232FileDescription	= -1;
        m_szEndSymbol			= nil;
    }
    return self;
}

-(void)dealloc
{
    [m_szEndSymbol release];
    [super dealloc];
    
}

//to find the port which has connected DUT
+ (NSArray *)SearchSerialPorts
{
	NSMutableArray *arrSerialPorts = [[[NSMutableArray alloc] init] autorelease];
	int iFound = 0;
	NSComparisonResult		iResult;  //enum
	kern_return_t			kernResult;  //int
	CFMutableDictionaryRef	classesToMatch;     //struct
	io_iterator_t			serialPortIterator;  //unsinged int
	
	classesToMatch = IOServiceMatching(kIOSerialBSDServiceValue);
    NSLog(@"classesToMatch: %@", classesToMatch);
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


-(UInt16)openPort:(NSString*)szPath
		baudeRate:(int)iBaudRate
		  dataBit:(int)iDataBit
		   parity:(NSString *)szParity
		 stopBits:(int)iStopBit
		endSymbol:(NSString*)inEndSymbol
{
    UInt16	nRet	= kUart_SUCCESS;
    
    if (iBaudRate == 0)
        iBaudRate = 115200;
    NSLog(@"%@", [NSString stringWithFormat:
                  @"(%s,%d) open uart : %@ , baudeRate : %d ",__FUNCTION__,__LINE__,
                  szPath,iBaudRate]);
    
    if(nil != inEndSymbol)
    {
        inEndSymbol	= [inEndSymbol stringByReplacingOccurrencesOfString:@"\\r" withString:@"\r"];
        inEndSymbol	= [inEndSymbol stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
        [m_szEndSymbol release];
        m_szEndSymbol	= [[NSString alloc]initWithString:inEndSymbol];
    }
	else
    {
        [m_szEndSymbol release];
        m_szEndSymbol	= [[NSString alloc]initWithString:@"\r"];
        
    };
    
    if(nil == szPath)
		return kUart_ERROR;
    
    m_iRS232FileDescription	= open([szPath UTF8String], O_RDWR|O_NOCTTY|O_NONBLOCK);
    if(m_iRS232FileDescription >= 0)
    {
        NSLog(@"%@", [NSString stringWithFormat:@"[%s](%s,%d) Open uart ok!",__FILE__,__FUNCTION__,__LINE__]);
        tcgetattr(m_iRS232FileDescription,&(m_rsOrigTerm));
        
        memset(&m_rsNewTerm, 0, sizeof(struct termios));
        
        cfmakeraw(&m_rsNewTerm);
        cfsetspeed(&m_rsNewTerm, iBaudRate);
        
        m_rsNewTerm.c_cc[VMIN]	= 1;
        m_rsNewTerm.c_cc[VTIME]	= 1;
        m_rsNewTerm.c_cflag		|= CREAD | CLOCAL;// turn on READ and ignore modem control lines
        
        m_rsNewTerm.c_cflag		&= ~CSIZE;
        switch (iDataBit)
		{
            case 5:
                m_rsNewTerm.c_cflag	|= CS5;
                break;
            case 6:
                m_rsNewTerm.c_cflag	|= CS6;
                break;
            case 7:
                m_rsNewTerm.c_cflag	|= CS7;
                break;
            default:
                m_rsNewTerm.c_cflag	|= CS8;
                break;
        }
        
        if([szParity isEqualToString:@"EVEN"])
        {
            m_rsNewTerm.c_cflag	|= PARENB;
            m_rsNewTerm.c_cflag	&= ~PARODD;
        }
        else if([szParity isEqualToString:@"ODD"])
        {
            m_rsNewTerm.c_cflag	|= PARENB;
            m_rsNewTerm.c_cflag	|= PARODD;
        }
        else
        {
            m_rsNewTerm.c_cflag	&= ~PARENB;
            m_rsNewTerm.c_cflag	&= ~PARODD;
        }
        
        switch (iStopBit)
		{
            case 1:
                m_rsNewTerm.c_cflag	&= ~CSTOPB;
                break;
            case 2:
                m_rsNewTerm.c_cflag	|= CSTOPB;
                break;
        }
        m_rsNewTerm.c_cflag	&= ~CRTSCTS ;//dont need flow control
        
        tcsetattr(m_iRS232FileDescription, TCSANOW, &m_rsNewTerm);
    }
    else
        nRet	= kUart_ERROR;
    return nRet;
}

-(void)Close_Uart
{
    if (m_iRS232FileDescription >= 0)
    {
		tcsetattr(m_iRS232FileDescription, TCSANOW, &(m_rsOrigTerm));
		close(m_iRS232FileDescription);
        m_iRS232FileDescription	= -1;
	}
}

-(UInt16)Clear_UartBuff:(NSTimeInterval)inIntervalTime
				TimeOut:(NSTimeInterval)inTimeOut
				readOut:(NSString**)szReadOut
{
    UInt16	nRet	= kUart_SUCCESS;
    
	if (m_iRS232FileDescription >= 0)
    {
		UInt8			ReceiveBuf[kUart_MAX_LEN]	= {0x00};
		long			dwResult					= 0;
		NSDate			*dtStartTime				= [NSDate date];
		NSTimeInterval	dEndTime					= 0.0;
		NSMutableString	*strReadData				= [[NSMutableString alloc] initWithString:@""];
		do
        {
			dwResult	= read(m_iRS232FileDescription, ReceiveBuf, sizeof(ReceiveBuf));
			if (dwResult < 0)
				break;
            NSString	*strData	= [[NSString alloc] initWithBytes:ReceiveBuf
														 length:dwResult
													   encoding:NSASCIIStringEncoding];
			[strReadData appendString:strData];
			[strData release];
			[NSThread sleepForTimeInterval:inIntervalTime];
			dEndTime	= [[NSDate date] timeIntervalSinceDate:dtStartTime];
		}
		while (inTimeOut >= dEndTime);
		tcflush(m_iRS232FileDescription, TCIOFLUSH);
		if (dEndTime > inTimeOut)
        {
            NSLog(@"%@", [NSString stringWithFormat:@"[%s](%s,%d) Clear buffer time out!",__FILE__,__FUNCTION__,__LINE__]);
			nRet	= kUart_TIMEOUT_Error;
        }
        else
           NSLog(@"%@",[NSString stringWithFormat:@"[%s](%s,%d) Clear buffer ok!",__FILE__,__FUNCTION__,__LINE__]);
        if(szReadOut != nil)
			*szReadOut	= [NSString stringWithFormat:@"%@",strReadData];
        [strReadData release];
	}
	else
		nRet	= kUart_ERROR;
    
	return nRet;
}


-(UInt16)Write_UartCommand:(id)inCommand
				 PackedNum:(NSUInteger)nPackNumber
				  Interval:(NSUInteger)nIntervalTime
					 IsHex:(BOOL)bIsHex
{
    UInt16			nRet		= kUart_SUCCESS;
	long			nLen;
    NSMutableData   *dataCmd	= [[NSMutableData alloc] initWithLength:0];
	if ([inCommand isKindOfClass:[NSData class]])
		[dataCmd appendData:inCommand];
    else if([inCommand isKindOfClass:[NSString class]])
		[dataCmd appendBytes:[inCommand UTF8String] length:[inCommand length]];
    else
        nRet	= kUart_DATA_TYPE_Error;
    if (!bIsHex)
        [dataCmd appendBytes:[m_szEndSymbol UTF8String]
					  length:[m_szEndSymbol length]];
	
    if (nRet == kUart_SUCCESS)
	{
        if(m_iRS232FileDescription >= 0)
        {
			NSUInteger	nSection	= (nPackNumber == 0 ? 1 : [dataCmd length] / nPackNumber);
			void		*pData		= [dataCmd mutableBytes];
			nPackNumber	= (nPackNumber == 0 ? [dataCmd length] + 1 : nPackNumber + 1);
			
			for (NSInteger i1 = 0;i1 < nPackNumber;i1 ++)
			{
				NSInteger	nDataLen;
				nLen	= write(m_iRS232FileDescription, pData, nSection);
				if (nLen != nSection)
					nRet	= kUart_WRITE_ERROR;
				pData		+= nSection;
				nDataLen	= [dataCmd length] - (pData - [dataCmd mutableBytes]);
				if (nDataLen < nSection)
					nSection	= nDataLen;
				if (nSection <= 0)
					break;
				if (nIntervalTime > 0)
					usleep((int)nIntervalTime );
            }
        }
        else
			nRet	= kUart_ERROR;
    }
    NSLog(@"%@", [NSString stringWithFormat:
                  @"[%s](%s,%d) Para:%@%@,%ld,%ld;return value:%d!",
                  __FILE__,__FUNCTION__,__LINE__,inCommand,m_szEndSymbol,(unsigned long)nPackNumber,(unsigned long)nIntervalTime,nRet]);
    [dataCmd release];
	return nRet;
}


-(UInt16)Read_UartData:(id)outUartData
		  IntervalTime:(NSTimeInterval)inIntervalTime
{
    UInt16			nRet			= kUart_SUCCESS;
    UInt8			szTempResult[kUart_MAX_LEN] = {0};
    NSDate			*dtStartTime	= [NSDate date];
    NSTimeInterval	dEndTime		= 0.0;
    if (m_iRS232FileDescription >= 0)
    {
        long readLength     =  read(m_iRS232FileDescription, szTempResult, sizeof(szTempResult));
        [outUartData appendString:[NSString stringWithFormat:@"%s", szTempResult]];
        //        [receiveBuffer appendBytes:szTempResult length:nLen];
        [NSThread sleepForTimeInterval:inIntervalTime];
        dEndTime	= [[NSDate date] timeIntervalSinceDate:dtStartTime];
        if (readLength > 0)
            return nRet;
        else
            return nRet = kUart_ERROR;
    }
    return nRet;
}

-(NSUInteger)memmem:(const void *)cSource
	   SourceLength:(int)iSourceLength
			 Symbol:(const void *)cSymbol
	   SymbolLength:(int)iSymbolLength
{
	if(iSourceLength<iSymbolLength)
		return NSNotFound;
	else
	{
        void	*p	= (void *)cSource;
        
        while (iSymbolLength <= (iSourceLength - (p - cSource)))
		{
            if (memcmp(p, cSymbol, iSymbolLength) == 0)
				return (p - cSource);
            p++;
        }
	}
	return NSNotFound;
}


////send command and read the value
//- (NSString *)ControlThePort:(NSString *) command
//{
//    uint8 buffer[1024] = {0};
//    long iLength;
//    iLength = write(m_iRS232, [command UTF8String], [command length]);
//    if (iLength != [command length])
//    {
//        NSLog(@"wrote command %@ error! The command length is:%lu", command,[command length]);
//        exit(1);
//    }
//    NSLog(@"Wrote %ld bytes for the device.", iLength);
//    sleep(1);
//    long readLength     =  read(m_iRS232, buffer, sizeof(buffer));
//    if (readLength > 0)
//        return [NSString stringWithFormat:@"%s",buffer];
//    else
//        return @"";
//}

@end