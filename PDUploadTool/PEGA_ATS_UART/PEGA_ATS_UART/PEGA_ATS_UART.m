//
//  PEGA_ATS_UART.m
//  PEGA_ATS_UART
//
//  Created by David_Dai on 4/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PEGA_ATS_UART.h"

@implementation PEGA_ATS_UART

@synthesize delegate;

//****************************************************************************************************
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}
//****************************************************************************************************
- (void)dealloc
{
    [m_szEndSymbol release];
    [super dealloc];
}

//****************************************************************************************************
- (id)init_Uart
{
    self = [super init];
    if (self) 
    {
        m_iRS232FileDescription = -1;
        m_szEndSymbol = nil;
    }
    
    return self;
}

//****************************************************************************************************
- (UInt16)openPort:(NSString *)szPath baudeRate:(int)iBaudRate dataBit:(int)iDataBit parity:(NSString *)szParity stopBits:(int)iStopBit endSymbol:(NSString *)inEndSymbol
{
    UInt16			nRet = kUart_SUCCESS;
    
    if (iBaudRate == 0) {
        iBaudRate = 115200;
    }
    [delegate writeDebugLog:[NSString stringWithFormat:@"PEGA_ATS_UART => start open uart : %@ , baudeRate : %d ",szPath,iBaudRate]];
    //---------------------------------------------------------------------
    if(nil != inEndSymbol)
    {   
        inEndSymbol = [inEndSymbol stringByReplacingOccurrencesOfString:@"\\r" withString:@"\r"];
        inEndSymbol = [inEndSymbol stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
        [m_szEndSymbol release];
        m_szEndSymbol = [[NSString alloc]initWithString:inEndSymbol];          
    }else
    {
        [m_szEndSymbol release];
        m_szEndSymbol = [[NSString alloc]initWithString:@"\r"];
        
    };
    //---------------------------------------------------------------------
    
    if(nil == szPath)
		return kUart_ERROR;
    
    m_iRS232FileDescription = open([szPath UTF8String], O_RDWR|O_NOCTTY|O_NONBLOCK);
    if(m_iRS232FileDescription>= 0)
    {
        [delegate writeDebugLog:@"PEGA_ATS_UART => Open uart ok!"];
        
        tcgetattr(m_iRS232FileDescription,&(m_rsOrigTerm));
        
        memset(&m_rsNewTerm, 0, sizeof(struct termios));
        
        cfmakeraw(&m_rsNewTerm);
        cfsetspeed(&m_rsNewTerm, iBaudRate);
        
        m_rsNewTerm.c_cc[VMIN] = 1;
        m_rsNewTerm.c_cc[VTIME] = 1;        
        m_rsNewTerm.c_cflag |= CREAD | CLOCAL;// turn on READ and ignore modem control lines        
        
        m_rsNewTerm.c_cflag &= ~CSIZE; 
        switch (iDataBit) {
            case 5:	
                m_rsNewTerm.c_cflag |= CS5;	
                break;
            case 6:	
                m_rsNewTerm.c_cflag |= CS6;
                break;
            case 7:	
                m_rsNewTerm.c_cflag |= CS7;
                break;
            default:	
                m_rsNewTerm.c_cflag |= CS8;
                break;
        }
        
        if([szParity isEqualToString:@"EVEN"])
        {
            m_rsNewTerm.c_cflag |= PARENB;
            m_rsNewTerm.c_cflag &= ~PARODD;
        }
        else if([szParity isEqualToString:@"ODD"])
        {
            m_rsNewTerm.c_cflag |= PARENB;
            m_rsNewTerm.c_cflag |= PARODD;
        }
        else 
        {
            m_rsNewTerm.c_cflag &= ~PARENB;
            m_rsNewTerm.c_cflag &= ~PARODD;
        }
        
        switch (iStopBit) {
            case 1:
                m_rsNewTerm.c_cflag &= ~CSTOPB;
                break;
            case 2:
                m_rsNewTerm.c_cflag |= CSTOPB;
                break;
        }
        m_rsNewTerm.c_cflag &= ~CRTSCTS ;//dont need flow control
        
        tcsetattr(m_iRS232FileDescription, TCSANOW, &m_rsNewTerm);
    }
    else
    {
        nRet = kUart_ERROR;
    }
    return nRet;
}

//****************************************************************************************************
-(void)Close_Uart
{
    if (m_iRS232FileDescription >= 0) 
    {
		tcsetattr(m_iRS232FileDescription, TCSANOW, &(m_rsOrigTerm));
		close(m_iRS232FileDescription);
        m_iRS232FileDescription = -1;
	}
}

//****************************************************************************************************
- (UInt16)Clear_UartBuff:(NSTimeInterval) inIntervalTime TimeOut :(NSTimeInterval) inTimeOut readOut:(NSString **)szReadOut
{
    UInt16			nRet = kUart_SUCCESS;
    
	if (m_iRS232FileDescription >= 0) 
    {
		UInt8			ReceiveBuf[kUart_MAX_LEN] = {0x00};
		long			dwResult = 0;
		NSDate			*dtStartTime = [NSDate date];
		NSTimeInterval dEndTime = 0.0;
		NSMutableString *strReadData = [[NSMutableString alloc] initWithString:@""];
		do	
        {
			dwResult = read(m_iRS232FileDescription, ReceiveBuf, sizeof(ReceiveBuf));
			if (dwResult < 0)
				break;
            NSString	*strData = [[NSString alloc] initWithBytes:ReceiveBuf 
														 length:dwResult 
													   encoding:NSASCIIStringEncoding];
			[strReadData appendString:strData];
			[strData release];
			[NSThread sleepForTimeInterval:inIntervalTime];
			dEndTime = [[NSDate date] timeIntervalSinceDate:dtStartTime];
		} while (inTimeOut >= dEndTime);
		if (dEndTime > inTimeOut)
        {
            [delegate writeDebugLog:@"PEGA_ATS_UART => Clear buffer time out!"];
			nRet = kUart_TIMEOUT_Error;
        }
        else 
            [delegate writeDebugLog:@"PEGA_ATS_UART => Clear buffer ok!"];
        if (szReadOut != nil) 
        {
            *szReadOut = [NSString stringWithFormat:@"%@",strReadData];
        }        
        [strReadData release];
	}
	else
		nRet = kUart_ERROR;
    
	return nRet;
}
//****************************************************************************************************

/*!
 *	string hex to data  copy from TestProgress.m
 *  @author         Jingfu Ran
 *
 *  @Since          2012 04 26
 *
 *	@param			szInput
 *                  Hex String  Format as "0x01 0x02 0x03"  
 *	@return			the hex data(NSData *)
 */
-(NSData *)stringHexToData:(NSString *)szInput
{
    NSArray *arrCMD = [szInput componentsSeparatedByString:@" "];
    NSInteger iCount = [arrCMD count];
    unsigned char   *pBuffer = malloc(iCount+1);
    for(NSInteger iIndex=0; iIndex<iCount; iIndex++)
    {
        unsigned int ucBuf = 0;
        NSString *szValue = [arrCMD objectAtIndex:iIndex];
        NSScanner *scan = [NSScanner scannerWithString:szValue];        
        [scan scanHexInt:&ucBuf];
        *(pBuffer+iIndex)=ucBuf;
    }
    NSData *dataRet = [NSData dataWithBytes:pBuffer length:iCount];
    free(pBuffer);
    pBuffer = NULL;
    return dataRet;
}

- (UInt16)Write_UartCommand :(id) inCommand PackedNum : (NSUInteger) nPackNumber 
                   Interval : (NSUInteger) nIntervalTime IsHex : (BOOL)bIsHex
{
    UInt16			nRet = kUart_SUCCESS;
	long			nLen;
    NSMutableData   *dataCmd = [[NSMutableData alloc] initWithLength:0];
	if ([inCommand isKindOfClass:[NSData class]])
        [dataCmd appendData:inCommand];
    else
    if ([inCommand isKindOfClass:[NSString class]])
        [dataCmd appendBytes:[inCommand UTF8String] length:[inCommand length]];
    else
        nRet = kUart_DATA_TYPE_Error;
    if (!bIsHex) 
    {
        [dataCmd appendBytes:[m_szEndSymbol UTF8String] length:[m_szEndSymbol length]];
    }
	
    if (nRet == kUart_SUCCESS) {
        if (m_iRS232FileDescription >= 0) 
        {
         
                NSUInteger nSection = (nPackNumber == 0 ? 1 : [dataCmd length] / nPackNumber);
                void *pData = [dataCmd mutableBytes];
                nPackNumber = nPackNumber == 0 ? [dataCmd length] + 1 : nPackNumber + 1;
                
                for (NSInteger i1 = 0;i1 < nPackNumber;i1 ++) 
                {
                    NSInteger nDataLen;
                    nLen = write(m_iRS232FileDescription, pData, nSection);
                    if (nLen != nSection)
                        nRet = kUart_WRITE_ERROR;
                    pData += nSection;
                    nDataLen = [dataCmd length] - (pData - [dataCmd mutableBytes]); 
                    if (nDataLen < nSection) 
                        nSection = nDataLen;
                    if (nSection <= 0)
                        break;
                    if (nIntervalTime > 0) 
                        usleep(nIntervalTime);
    
            }

        }
        else
            nRet = kUart_ERROR;
    }
    [delegate writeDebugLog:
     [NSString stringWithFormat:@"PEGA_ATS_UART => Call function (Write_UartCommand:%@%@,%d,%d);return value:%d!",
      inCommand,m_szEndSymbol,nPackNumber,nIntervalTime,nRet]];
    [dataCmd release];
	return nRet;
}

//****************************************************************************************************
- (UInt16)Read_UartData:(id) outUartData TerminateSymbol : (NSArray *) inArySymbols 
			 MatchType : (NSInteger) inType IntervalTime :(NSTimeInterval) inIntervalTime 
			   TimeOut :(NSTimeInterval) inTimeOut Ignore:(NSString *)strIgnore
{
    NSInteger       nLen;
    UInt16			nRet = kUart_SUCCESS;
    UInt8			szTempResult[kUart_MAX_LEN] = {0};
    NSDate			*dtStartTime = [NSDate date];
    NSTimeInterval	dEndTime = 0.0;
    NSMutableData   *receiveBuffer = [[NSMutableData alloc] initWithLength:0];
    NSMutableArray	*aryMatchTbl = [NSMutableArray arrayWithArray:inArySymbols];
    
    if (m_iRS232FileDescription >= 0)
    do {
        nLen = read(m_iRS232FileDescription, szTempResult, sizeof(szTempResult));
        if (nLen > 0) 
        {
            //[delegate writeDebugLog:@"Record timeStamp!!"];
            [receiveBuffer appendBytes:szTempResult length:nLen];
            
            if (strIgnore!=nil) {
                NSString *szReceiveBuffer = [[NSString alloc] initWithData:receiveBuffer encoding:NSASCIIStringEncoding];
                NSRange range = [szReceiveBuffer rangeOfString:strIgnore];
                NSString *szTemp = @"";
                if (range.location != NSNotFound) 
                {
                    szTemp = [szReceiveBuffer substringToIndex:range.location-1];
                    [self Write_UartCommand:@"r" PackedNum:1 Interval:0 IsHex:YES];
                }
                if (![szTemp isEqual: @""])
                {
                    [receiveBuffer setData:[NSData dataWithBytes:[szTemp UTF8String] length:[szTemp length]]];
                }
                
                [szReceiveBuffer release];
            }
            
            
            
            if ([aryMatchTbl count] > 0) 
            {
                for (int i1 = [aryMatchTbl count]-1;i1 >= 0;i1 --)  {
                    char        *pSource = [receiveBuffer mutableBytes];
                    char        *pDest = "\0";
                    id      idExpect = [aryMatchTbl objectAtIndex:i1];
                    if([idExpect isKindOfClass:[NSData class]])
                    {
                        pDest = [idExpect mutableBytes];
                    }
                    else
                    {
                        pDest = (char *)[idExpect UTF8String];
                    }
                    /*NSString    *strPattern = [aryMatchTbl objectAtIndex:i1];
                    char        *pDest = (char *)[strPattern UTF8String];*/
                    if ([self memmem:pSource SourceLength:[receiveBuffer length] Symbol:pDest 
                        SymbolLength:[idExpect length]] != NSNotFound)
                    {
                        if (inType == kUart_MatchAnyOne) 
                        {
                            [aryMatchTbl removeAllObjects];
                            nRet = kUart_SUCCESS;
                            break;
                        }
                        else{
                            [aryMatchTbl removeObjectAtIndex:i1];
                        }
                    }
                }
                if ([aryMatchTbl count] == 0)
                    break;
            }
        }
        else
        {
            //[delegate writeDebugLog:@"Record timeStamp , no data!!"];
        }
        
        [NSThread sleepForTimeInterval:inIntervalTime];
		dEndTime = [[NSDate date] timeIntervalSinceDate:dtStartTime];
    } while (inTimeOut >= dEndTime);
    if (dEndTime > inTimeOut && [aryMatchTbl count]!=0)    //modifie by desikan for when timeout and the arySymbol
		nRet = kUart_CommandTimeOut;
    if ([outUartData isKindOfClass:[NSMutableData class]])
        [outUartData setData:receiveBuffer];
    else
    if ([outUartData isKindOfClass:[NSMutableString class]]) {
        NSString *strTemp = [[NSString alloc] initWithBytes:[receiveBuffer bytes] 
                                                     length:[receiveBuffer length] encoding:NSASCIIStringEncoding];
        if(strTemp)
        {
            [outUartData setString:strTemp];
            [strTemp release];
        }
        else
        {
            [outUartData setString:@""];
            nRet = kUart_ERROR;
        }
    }
    else
        nRet = kUart_DATA_TYPE_Error;
    [receiveBuffer release];
    [delegate writeDebugLog:[NSString stringWithFormat:@"PEGA_ATS_UART => Call function (Read_UartData:%@ TerminateSymbol:%@ MatchType:%d IntervalTime:%f TimeOut:%f);return value:%d!",outUartData,inArySymbols,inType,inIntervalTime,inTimeOut,nRet]];
	return nRet;
}

- (NSUInteger)memmem:(const void *)cSource SourceLength:(int)iSourceLength Symbol:(const void *)cSymbol SymbolLength:(int)iSymbolLength{
	
	if(iSourceLength<iSymbolLength)
		return NSNotFound;
	else
	{
        void    *p = (void *)cSource;
        
        while (iSymbolLength <= (iSourceLength - (p - cSource))) {
            if (memcmp(p, cSymbol, iSymbolLength) == 0)
                return (p - cSource);
            p++;
        }
	}	
	return NSNotFound;
}

//****************************************************************************************************
+ (void)GetUartFrameworkVersion:(NSString **)outStrFrameWorkVer
{

    NSBundle		*thisBundle = [NSBundle bundleForClass:[self class]];
    NSDictionary	*mInfo      = [thisBundle infoDictionary];
    
    * outStrFrameWorkVer = [[[NSString alloc] initWithString:[mInfo valueForKey:@"CFBundleVersion"]]autorelease];
    
}

@end
