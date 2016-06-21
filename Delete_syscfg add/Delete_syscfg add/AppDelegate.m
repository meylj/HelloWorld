//
//  AppDelegate.m
//  Delete_syscfg add
//
//  Created by wangyu on 13-9-12.
//  Copyright (c) 2013年 wangyu. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [self Choose_port:nil];
}
-(id)init
{
    self = [super init];
    if (self) {
        arrSnName2=[[NSMutableArray alloc] init];
        m_szResultOk=[[NSMutableString alloc] init];
        m_fconnect=NO;
    }
    return self;
}
-(void)dealloc
{
    [arrSnName2 release];
    [m_szResultOk release];
    [super dealloc];

}
-(IBAction)Choose_port:(id)sender
{
    m_fconnect=NO;
    NSMutableArray *arrSerialPort=[[NSMutableArray alloc] init];
    [self SearchSerialPorts:arrSerialPort];
    [cbSerialPort removeAllItems];
    [cbSerialPort setStringValue:[arrSerialPort objectAtIndex:0]];
    [cbSerialPort addItemsWithObjectValues:arrSerialPort];
    [btConnect setTitle:@"connect"];
    [arrSerialPort release];
    
}
- (UInt16)SearchSerialPorts:(NSMutableArray *)in_out_arrSerialPorts
{
    int iFound = 0;
	kern_return_t			kernResult;
	CFMutableDictionaryRef	classesToMatch;
	io_iterator_t			serialPortIterator;
	classesToMatch = IOServiceMatching("IOSerialBSDClient");
	if (classesToMatch != NULL) {
		CFDictionarySetValue(classesToMatch, CFSTR("IOSerialBSDClientType"), CFSTR("IOSerialStream"));
		
		// This function decrements缩减 the refcount of the dictionary passed it
		kernResult = IOServiceGetMatchingServices(kIOMasterPortDefault, classesToMatch, &serialPortIterator);
		if (kernResult == KERN_SUCCESS) {
         
            io_object_t serialService = IOIteratorNext(serialPortIterator);
            while (serialService != 0)
            {
                CFStringRef bsdPath = (CFStringRef)IORegistryEntryCreateCFProperty(serialService, CFSTR("IOCalloutDevice"), kCFAllocatorDefault, 0);
                //[in_out_arrSerialPorts addObject:(__bridge NSString*)bsdPath];
                [in_out_arrSerialPorts addObject:(NSString*)bsdPath];
         
                CFRelease(bsdPath);
                
                serialService = IOIteratorNext(serialPortIterator);
            }
			(void)IOObjectRelease(serialPortIterator);
            
		}
    }
   
    //CFRelease(classesToMatch);
	return iFound;
}

-(IBAction)Connect:(id)sender
{
    m_fconnect=YES;
    m_ifd=[self openPort:[cbSerialPort stringValue]];
    if (m_ifd<0)
    {
        perror("open_port error");
        return;
    }
    int iSetPot=[self setOpt_BaudRate:115200 andBits:8 andParity:0 andStopBits:1];
    if (iSetPot<0) {
        perror("set_opt error");
    
        return;
    }
   
}
-(int)setOpt_BaudRate:(int)iBaudRate andBits:(int)iBits andParity:(int)iParity andStopBits:(int)iStopBits
{
    struct termios newtio,oldtio;
    if(tcgetattr(m_ifd, &oldtio)!=0)
    {
        perror("SetupSerial 1");
        return -1;
    }
    bzero( &newtio, sizeof( newtio ) );
    newtio.c_cflag |= CLOCAL | CREAD;
    newtio.c_cflag &= ~CSIZE;
    switch( iBaudRate )
    {
        case 2400:
            cfsetispeed(&newtio, B2400);
            cfsetospeed(&newtio, B2400);
            break;
        case 4800:
            cfsetispeed(&newtio, B4800);
            cfsetospeed(&newtio, B4800);
            break;
        case 9600:
            cfsetispeed(&newtio, B9600);
            cfsetospeed(&newtio, B9600);
            break;
        case 115200:
            cfsetispeed(&newtio, B115200);
            cfsetospeed(&newtio, B115200);
            break;
        default:
            cfsetispeed(&newtio, B9600);
            cfsetospeed(&newtio, B9600);
            break;
    }
    switch( iBits )
    {
        case 7:
            newtio.c_cflag |= CS7;
            break;
        case 8:
            newtio.c_cflag |= CS8;
            break;
        default:
            break;
    }
    
    switch( iParity )
    {
        case 1:                           //奇校验
            newtio.c_cflag |= PARENB;
            newtio.c_cflag |= PARODD;
            newtio.c_iflag |= (INPCK | ISTRIP);
            break;
        case 2:                           //偶校验
            newtio.c_iflag |= (INPCK | ISTRIP);
            newtio.c_cflag |= PARENB;
            newtio.c_cflag &= ~PARODD;
            break;
        case 0:                           //无校验
            newtio.c_cflag &= ~PARENB;
            break;
        default:
            break;
    }
    
    
    if( iStopBits == 1 )
        newtio.c_cflag &= ~CSTOPB;
    else if ( iStopBits == 2 )
        newtio.c_cflag |= CSTOPB;
    
    newtio.c_cc[VTIME] = 0;
    newtio.c_cc[VMIN] = 0;
    tcflush(m_ifd,TCIOFLUSH);
    if((tcsetattr(m_ifd,TCSANOW,&newtio))!=0)
    {
        perror("com set error");
        return -1;
    }
    printf("set done!\n");
    return 0;
}

-(int)openPort:(NSString *)szDev
{
    
    const char *arr=[szDev UTF8String];
    printf("%s",arr);
    m_ifd = open(arr, O_RDWR|O_NOCTTY|O_NDELAY);
    if (-1 == m_ifd)
    {
        perror("Can't Open Serial Port");
        return(-1);
    }
    else
    {
        printf("Open Serial Port success!");
         [btConnect setTitle:@"OK"];
        return m_ifd;
    }
}



-(IBAction)Delete_Item:(id)sender
{

    if (m_fconnect==YES) {
        
    [m_szResultOk setString:@""];
    [arrSnName2 removeAllObjects];
    [tvResult setString:@""];


    NSString *strSnName=[[tvSnName textStorage] string];
    NSString *strName;
    NSString *strCommand;
    NSMutableArray * arrSnName1=[NSMutableArray arrayWithArray:[strSnName componentsSeparatedByString:@"\n"]];
   
    for (int i=0; i<[arrSnName1 count]; i++)
    {
        NSMutableArray *arrSnName3=[NSMutableArray arrayWithArray:[[arrSnName1 objectAtIndex:i] componentsSeparatedByString:@"."]];
        if ([[arrSnName3 objectAtIndex:0] isNotEqualTo:@""])
        {
            strName=[arrSnName3 objectAtIndex:1];
            [arrSnName2 addObject:strName];
        }
    }
    
    for (int j=0; j<[arrSnName2 count]; j++)
    {
        if (![[arrSnName2 objectAtIndex:j] isEqualToString:@"CFG#"]) {
            strCommand=[NSString stringWithFormat:@"syscfg delete %@",[arrSnName2 objectAtIndex:j]];
            [self Sender:strCommand
              DeleteName:[arrSnName2 objectAtIndex:j]];

        }else
        {
            strCommand=[NSString stringWithFormat:@"syscfg print %@",[arrSnName2 objectAtIndex:j]];
            NSLog(@"....");
            [self Sender1:strCommand
               DeleteName:[arrSnName2 objectAtIndex:j]];
        }
    
    }
        NSLog(@"aaaa");
    }else
    {
        NSRunAlertPanel(@"提示：", @"請確定是否有點擊 connect !", @"OK", nil, nil);
    }

}
-(void)Sender1:(NSString *)szBuf DeleteName:(NSString*)Delete
{
    NSString *szWriteBuf=[NSString stringWithFormat:@"%@\r",szBuf];
    NSString *str_signal;
    NSMutableString *ns_signal=[[NSMutableString alloc] init];
    const char *cBuf=[szWriteBuf UTF8String];
    //char *cReBuf = (char *)malloc(4096);
    UInt8 cReBuf[4096]={0};
    long lReadLen  = 0;
    if(-1!=m_ifd)
    {
        long lWriteLen = 0;
        while (cBuf[lWriteLen]!='\0') {
            lWriteLen++;
        }
        if(write(m_ifd, cBuf, lWriteLen)==lWriteLen)
        {
            printf("write success!\n");
        }
        else
        {
            printf("write fail!\n");
        }
        sleep(1);
        bzero(cReBuf, sizeof(cReBuf));
        while (1)
        {
            lReadLen = read(m_ifd, cReBuf, sizeof(cReBuf));
            if (lReadLen > 0)
            {
                //printf("read success!\n");
                NSString  *szReadTemp = [[NSString alloc] initWithBytes:cReBuf length:lReadLen encoding:1];
                    NSMutableArray *arr_signal=[NSMutableArray arrayWithArray:[szReadTemp componentsSeparatedByString:@"\n"]];
                    str_signal=[arr_signal objectAtIndex:1];
                    arr_signal=[NSMutableArray arrayWithArray:[str_signal componentsSeparatedByString:@"/"]];
                    
                    [arr_signal replaceObjectAtIndex:4 withObject:@"*"];
                    [arr_signal replaceObjectAtIndex:5 withObject:@"*"];
                    NSLog(@"%@",arr_signal);
                
                    for (int i=0; i<6; i++) {
                        [ns_signal appendString:[NSString stringWithFormat:@"%@/",[arr_signal objectAtIndex:i]]];
                    }
                    
                    [ns_signal replaceOccurrencesOfString:@"\r" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [ns_signal length])];
                    
                    NSLog(@"%@",ns_signal);
                    [ns_signal setString: [NSString stringWithFormat:@"syscfg add CFG# %@",ns_signal]];
                    [self Sender:ns_signal DeleteName:@"CFG#"];
                    //[tvResult setString:szReadTemp];
                [szReadTemp release];
            }
            else
                break;
        }
        
    }
    [ns_signal release];
}
-(void)Sender:(NSString *)szBuf DeleteName:(NSString*)Delete
{
    NSString *szWriteBuf=[NSString stringWithFormat:@"%@\r",szBuf];
    NSString *szResult;
    
    const char *cBuf=[szWriteBuf UTF8String];
    //char *cReBuf = (char *)malloc(4096);
    UInt8 cReBuf[4096]={0};
    long lReadLen  = 0;
    if(-1!=m_ifd)
    {
        long lWriteLen = 0;
        while (cBuf[lWriteLen]!='\0') {
            lWriteLen++;
        }
        if(write(m_ifd, cBuf, lWriteLen)==lWriteLen)
        {
            printf("write success!\n");
        }
        else
        {
            printf("write fail!\n");
        }
        sleep(1);
        bzero(cReBuf, sizeof(cReBuf));
        while (1)
        {
            lReadLen = read(m_ifd, cReBuf, sizeof(cReBuf));
            if (lReadLen > 0)
            {
                printf("read success!\n");
                NSString  *szReadTemp = [[NSString alloc] initWithBytes:cReBuf length:lReadLen encoding:1];
              
               if([szReadTemp rangeOfString:@"error"].location!=NSNotFound&&[szReadTemp rangeOfString:@"ERROR"].location==NSNotFound)
                {
                    printf("%s",[szReadTemp UTF8String]);
                    szResult=[NSString stringWithFormat:@"%@:Delete Fail=>%@\n***********************\n",Delete,szReadTemp];
                    [m_szResultOk appendString:szResult];
                    [tvResult setString:m_szResultOk];

                }else
                {
                    printf("%s",[szReadTemp UTF8String]);
                    szResult=[NSString stringWithFormat:@"%@:Delete Success\n***********************\n",Delete];
                    [m_szResultOk appendString:szResult];
                    [tvResult setString:m_szResultOk];
                    
                }
                [szReadTemp release];
            }
            else
                break;
        }
        
    }
}

-(IBAction)C_QT0:(id)sender
{
    [tvSnName setString:@"1.SrNm\n2.Mod#\n3.Regn\n4.Batt\n5.OPTS\n6.DClr\n7.CFG#"];
    [self prompt:@"QT0"];

}
-(IBAction)C_QT0b:(id)sender
{
    [tvSnName setString:@"1.HwVr\n2.FCMB\n3.BCMB\n4.FCMS\n5.BCMS\n6.BBSn"];
    [self prompt:@"QT0b"];
}
-(IBAction)C_QT1:(id)sender
{
    [tvSnName setString:@"1.SwBh"];
    [self prompt:@"QT1"];
}
-(IBAction)C_CT:(id)sender
{
    [tvSnName setString:@"1.LCM#\n2.MtSN\n3.MdlC"];
    [self prompt:@"CT1"];
}
-(IBAction)C_Prox_Cal:(id)sender
{
    [tvSnName setString:@"1.CPCl"];
    [self prompt:@"Prox_Cal"];
}




-(IBAction)J_QT0:(id)sender
{
    [tvSnName setString:@"1.SrNm\n2.Batt\n3.OPTS\n4.DClr\n5.CFG#"];
    [self prompt:@"QT0"];
}
-(IBAction)J_QT0b:(id)sender
{
    [tvSnName setString:@"1.HwVr\n2.FCMB\n3.BCMB\n4.FCMS\n5.BCMS\n6.BBSn"];
    [self prompt:@"QT0b"];
}
-(IBAction)J_QT1:(id)sender
{
    [tvSnName setString:@"1.SwBh"];
    [self prompt:@"QT1"];

}
-(IBAction)J_CT:(id)sender
{
    [tvSnName setString:@"1.Mod#\n2.Regn\n3.LCM#\n4.MtSN"];

    [self prompt:@"CT1"];
}
-(IBAction)J_Prox_Cal:(id)sender
{
    [tvSnName setString:@"1.CPCl#"];
    [self prompt:@"Prox_Cal"];
}
-(void)prompt:(NSString *) sta_Name
{
    if (m_fconnect==YES) {
        if(1==(long)NSRunAlertPanel(@"警告：", [NSString stringWithFormat:@"確定刪除 [ %@ ] 所有“syscfg key”?\n若是點擊“YES”。\n若不是點擊“NO”,並在右側框中更改後按“Delete”。",sta_Name], @"YES", @"NO", nil))
            [self Delete_Item:nil];
    }else
    {
        NSRunAlertPanel(@"提示：", @"請確定是否有點擊 connect !", @"OK", nil, nil);
    };

}



@end
