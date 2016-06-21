//
//  FTAppDelegate+FakeData.m
//  FakeTarget
//
//  Created by raniys on 4/1/14.
//  Copyright (c) 2014 raniys. All rights reserved.
//

#import "FakeData.h"
#import "FakeTagetDefine.h"


@implementation FTAppDelegate (FakeData)

-(NSNumber *)getSerialPorts
{
    NSArray *arySerialPort  = [YYControlPort SearchSerialPorts];
    NSLog(@"arrSerialPort=%@", arySerialPort);
    if (!arySerialPort || [arySerialPort count] == 0)
    {
        NSLog(@"Warning: FTDI cable not found!");
        NSRunAlertPanel(@"警告(Warning)!",
						@"请确认FTDI cable已连接OK。(Please confirm if the FTDI cable already connected.)",
						@"确认（OK）", nil, nil);
        return [NSNumber numberWithInteger:kUart_ERROR];
    }
    [m_dictMemoryValues setObject:arySerialPort forKey:kFT_Cable_Paths];
    return [NSNumber numberWithInteger:kUart_SUCCESS];
}

-(NSNumber *)openTarget:(NSString *)strTarget
{
//    NSInteger   iRet        = [[self getSerialPorts]integerValue];
    NSArray *arySerialPath  = [m_dictMemoryValues objectForKey:kFT_Cable_Paths];
    if ([arySerialPath count] == 0)
    {
        NSLog(@"Error: get serial path failed.");
        return [NSNumber numberWithBool:NO];
    }
    NSString    *strTargetPath = @"";
    for (int i=0; i<[arySerialPath count]; i++)
    {
        NSString *strSinglePath = [arySerialPath objectAtIndex:i];
        if ([strSinglePath contains:[m_dictMemoryValues objectForKey:[NSString stringWithFormat:@"%@ CableName", strTarget]]])
            strTargetPath = strSinglePath;
    }
    if ([strTargetPath isEqualToString:@""])
    {
        NSString *strWarning =[NSString stringWithFormat:@"Did not to find cable %@ from %@, please check.", [m_dictMemoryValues objectForKey:[NSString stringWithFormat:@"%@ CableName", strTarget]], arySerialPath];
        NSLog(@"%@",strWarning);
        NSRunAlertPanel(@"警告(Warning)!",
                        @"%@",
						@"确认（OK）",strWarning,nil, nil);
        return [NSNumber numberWithBool:NO];
    }
    NSInteger   iRet            = kUart_SUCCESS;
    NSString	*szPortType		= strTarget;  
    unsigned int iSpeed			= [kFT_DeviceSet_BaudeRate intValue];
    unsigned int iDataBit		= [kFT_DeviceSet_DataBit intValue];
    NSString	*szParity		= kFT_DeviceSet_Parity;
    unsigned int iStopBit		= [kFT_DeviceSet_StopBit intValue];
    NSString	*szEndsymbol	= kFT_DeviceSet_EndFlag;
    YYControlPort *controlPort  = [[[YYControlPort alloc] init_Uart] autorelease];
    [m_dictMemoryValues setObject:controlPort forKey:strTarget];
    
    [controlPort Close_Uart];
    if (NULL == controlPort)
	{
        iRet	= kUart_CMD_CHECK_DUT_FAIL;
        NSLog(@"OPEN_TARGET : get uart object fail, overleap open port!");
    }
	else
        iRet	=[controlPort openPort:strTargetPath
                          baudeRate:iSpeed
                            dataBit:iDataBit
                             parity:szParity
                           stopBits:iStopBit
                          endSymbol:szEndsymbol];
    if(kUart_SUCCESS == iRet)//iRet== 0 --> successed
    {
        NSLog(@"OPEN_TARGET => Open uart for %@:%@ pass!",
				 szPortType, strTargetPath);
        return [NSNumber numberWithBool:YES];
    }
    else
    {
        NSLog(@"OPEN_TARGET => Open uart for %@:%@ fail!",
				 szPortType, strTargetPath);
        return [NSNumber numberWithBool:NO];
    }
}

-(NSNumber *)closeTarget:(id)target
{
    if ([target isKindOfClass:[NSString class]])
    {
        NSString        *strTarget      = target;
        YYControlPort   *newControlPort = [m_dictMemoryValues objectForKey:strTarget];
        [newControlPort Close_Uart];
        return [NSNumber numberWithBool:YES];
    }
    if ([target isKindOfClass:[NSArray class]])
    {
        for (int i = 0; i < [target count]; i++)
        {
            NSString        *strTarget      = [target objectAtIndex:i];
            YYControlPort   *newControlPort = [m_dictMemoryValues objectForKey:strTarget];
            [newControlPort Close_Uart];
        }
        return [NSNumber numberWithBool:YES];
    }
    return [NSNumber numberWithBool:NO];
}

//keeping receive meesage from port
-(void)readAndSendMessage:(NSString *)strTarget
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSInteger       iRet			= kUart_SUCCESS;
    YYControlPort   *newControlPort = [m_dictMemoryValues objectForKey:strTarget];
    NSInteger       iPackedNum		= 1;
    NSInteger       iIntervalTime	= 0;
    NSString        *szPortType		= strTarget;
    NSString        *szEndSymbol     = @"\r";   //defult end symbol is "\r"
    while (1)
    {
        if (!m_bCheckBox)
        {
            [NSThread exit];
        }
        NSMutableString *szReadString	= [[NSMutableString alloc] init];
        NSMutableString *szSendString   = [[NSMutableString alloc] init];
        NSInteger       iReadFollow     = -1;
        
        //clear uart buff first
        [newControlPort Clear_UartBuff:kUart_ClearInterval
                               TimeOut:kUart_CommandTimeOut
                               readOut:nil];
        //keep reading message until found "\r"
        NSLog(@"Starting to read message...");
        do{
            if (!m_bCheckBox)
            {
                [NSThread exit];
            }
            iRet = [newControlPort Read_UartData:szReadString
                                    IntervalTime:0.01];
            if ([strTarget isEqualToString:@"FIXTURE"])
            {
                szEndSymbol = [kFT_DeviceSet_EndFlag stringByReplacingOccurrencesOfString:@"\\r" withString:@"\r"];
                szEndSymbol = [szEndSymbol stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
                if ([szReadString contains:szEndSymbol])
                    iReadFollow = kUart_CMD_SUCCESS;
            }
            else
            {
                if ([szReadString contains:szEndSymbol])
                    iReadFollow = kUart_CMD_SUCCESS;
            }
            
            usleep(10000);
        }while(iReadFollow != kUart_CMD_SUCCESS);
        
        //check the message if it is a command in uart log 
        if (iRet == kUart_SUCCESS && [szReadString isNotEqualTo:@""])
        {
            NSLog(@"%@", szReadString);
            NSString *strReadString = [NSString stringWithString:szReadString];
            strReadString = [strReadString stringByReplacingOccurrencesOfString:szEndSymbol withString:@"\n"];
            NSArray *aryCommand = [m_dictMemoryValues objectForKey:[NSString stringWithFormat:@"%@Command", strTarget]];
            for (NSDictionary *dicCommand in aryCommand)
            {
                NSString *strCommand = [dicCommand objectForKey:kFT_SEND_COMMAND];
                NSString *strResult  = [dicCommand objectForKey:kFT_READ_COMMAND];
                if ([strReadString isEqualToString:strCommand])
                {
                    szSendString = [NSMutableString stringWithString:strResult];
                    break;
                }
                else
                    szSendString = [NSMutableString stringWithString:@"\n\nCommand error: Did not find the result of the command from your log, please check!"];
            }
            id SendString= [szSendString stringByReplacingOccurrencesOfString:@"\xc2\xa0" withString:@" "];
            if ([SendString length] > 1024)
            {
                NSInteger iCharacterNum = 1024;
                NSInteger iArrayNum     = 0;
                NSInteger iStringLength = [SendString length];
                NSInteger iRemainder    = iStringLength%iCharacterNum;
                if (iRemainder == 0)
                    iArrayNum = iStringLength/iCharacterNum;
                else
                    iArrayNum = iStringLength/iCharacterNum + 1;
//                NSMutableArray *arrString = [[NSMutableArray alloc] init];
                for (int i = 1; i <= iArrayNum; i++)
                {
                    id SubItem = nil;
                    if ([SendString length] <= iCharacterNum)
                    {
                        SubItem = SendString;
                    }
                    else
                    {
                        SubItem = [SendString substringWithRange:NSMakeRange(0, 1024)];
                        SendString = [SendString substringWithRange:
                                      NSMakeRange(1024, ([SendString length] - [SubItem length]))];
                    }
                    iRet = [newControlPort Write_UartCommand:SubItem
                                                   PackedNum:iPackedNum
                                                    Interval:iIntervalTime
                                                       IsHex:YES];
                    usleep(50000);
//                    [arrString addObject:SubItem];
                }
//                [arrString release];
            }
            else
                iRet = [newControlPort Write_UartCommand:SendString
                                               PackedNum:iPackedNum
                                                Interval:iIntervalTime
                                                   IsHex:YES];
        }
        [szReadString release];
        [szSendString release];
    }
    [self closeTarget:[m_dictMemoryValues objectForKey:kFT_Targets]];
    [pool drain];
}

//get sub objects from one dictionary
//param:
//  id                  inXml  :   dictionary you want get sub objects from
//  NSString            *inMainKey,... :    sub keys
//Return:
//  id      :           return the value you want
-(id)getValueFromXML:(id)inXml
			 mainKey:(NSString *)inMainKey, ...
{
    id	returnValue	= nil;
    if([[inXml class] instancesRespondToSelector:@selector(objectForKey:)])
    {
        returnValue	= [inXml objectForKey:inMainKey];
        va_list	ap;
        va_start(ap , inMainKey);
        if (returnValue)
		{
            NSString	*nextKey	= va_arg(ap, NSString *);
            while (nextKey && [returnValue isKindOfClass:[NSDictionary class]])
			{
                returnValue	= [returnValue objectForKey:nextKey];
                nextKey		= va_arg(ap, NSString *);
            }
        }
        va_end(ap);
    }
    return returnValue;
}

@end
