//
//  SingleWindow.m
//  ATSSerialTool
//
//  Created by Lorky Luo on 5/31/12.
//  Copyright 2012 Pegatron. All rights reserved.
//

#import "SingleWindow.h"
#import "SerialController.h"

@interface SingleWindow ()
- (void)modifyShow;
- (void)showInfomation:(NSString *)szInforamtion
				 color:(NSColor *)color;
-(NSData *)stringHexToData:(NSString *)szInput;
-(float) CalculateDistanceFromBytes:(unsigned char) high
								low:(unsigned char) low;
@end

@implementation SingleWindow

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
		mySerialPort = [[SerialController alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
	[super dealloc];
	[mySerialPort release];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
	NSArray * arrayPorts = [SerialController SearchSerialPorts];
	
	if ([arrayPorts count]>0) {
		[btnSerialPort addItemsWithTitles:arrayPorts];
		[self modifyShow];
		[btnSend setEnabled:NO];
	}
	else
	{
		NSRunAlertPanel(@"Error", @"Can't find serial port, please check", @"OK", nil, nil);
		[NSApp terminate:self];
	}
}

#pragma mark - PrivateFunction
- (void)modifyShow
{
	NSString *szParity = [[btnParity selectedItem] title];
	NSString *szShow = [NSString stringWithFormat:@"%@ / %@-%@-%@",
						[[btnBaudRate selectedItem] title],[[btnBits selectedItem] title],
						[[szParity substringToIndex:1] uppercaseString],[[btnStopBits selectedItem] title]];
	[textShow setStringValue:szShow];
}

- (void)showInfomation:(NSString *)szInforamtion color:(NSColor *)color
{
	NSDictionary * dictAttri = [NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
	NSAttributedString * attriStr = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",szInforamtion]
																	attributes:dictAttri];
	
	[[textInfo textStorage] insertAttributedString:attriStr atIndex:[[textInfo string] length]];
}

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

-(float) CalculateDistanceFromBytes:(unsigned char) high low:(unsigned char) low
{
    float sensor_full_scale = 220;
    float sensor_scale_factor = (sensor_full_scale / 4095);
    unsigned short acc = 0;
    // drop bits 7 and 6 from high
    acc = (0x3F & high);
    // move high niblet up 6 bits
    acc <<= 6;
    // drop bits 7 and 6 from low
    acc |= (0x3F & low);
    // scale and return mm's
    return (fabs(sensor_full_scale - (acc * sensor_scale_factor)));
}

#pragma mark - Actions
- (IBAction)ModifiedParameter:(id)sender
{
	[self modifyShow];
}

- (IBAction)ConnectSerialPort:(id)sender 
{
	if (@"Disconnect" == [sender title]) 
	{
		[mySerialPort CloseSerialPort];
		[self showInfomation:@"######################################" color:[NSColor orangeColor]];
		[sender	setTitle:@"Connect"];
		[btnSend setEnabled:NO];
	}
	else
	{
		NSString * strErr = nil;
		
		if ([mySerialPort OpenSerialPort:[[btnSerialPort selectedItem] title]
								 withBit:[[[btnBits selectedItem] title] intValue]
								withStop:[[[btnStopBits selectedItem] title] intValue]
							withBaudRate:[[[btnBaudRate selectedItem] title] intValue]
							  withParity:[[btnParity selectedItem] title] 
							   ErrorMesg:&strErr]) 
		{
			[sender	setTitle:@"Disconnect"];
			[btnSend setEnabled:YES];
			[self showInfomation:[NSString stringWithFormat:@"Connect with the serial port : %@",[[btnSerialPort selectedItem] title]] color:[NSColor brownColor]];
		}
		else
		{
			[self showInfomation:[NSString stringWithFormat:@"Get error message %@",strErr] color:[NSColor redColor]];
			return ;
		}
	}
}

- (IBAction)SendCommand:(id)sender 
{
	if ([mySerialPort isOpen] > 0) {
		id command = [NSString stringWithFormat:@"%@\r",[textCommand stringValue]];
		[self showInfomation:[NSString stringWithFormat:@"Write Command : %@",command] color:[NSColor blueColor]];
	
		if ([bHex state])
		{
			NSLog(@"It was Hex input and output");
			command = [self stringHexToData:[textCommand stringValue]];
		}
		long lengthCmd = [mySerialPort sendCommand:command];
		if (lengthCmd != [command length]) {
			[self showInfomation:@"Write error : Length command != command length" color:[NSColor redColor]];
			return;
		}
		
		NSString *szReadCommand = [mySerialPort readCommand];
		if ([bHex state])
		{
			const char * myBytes = [szReadCommand UTF8String];
			
			NSMutableString * strBytes = [[NSMutableString alloc] initWithCapacity:sizeof(myBytes)];
			for (NSUInteger i = 0; i < sizeof(myBytes); i++) 
				[strBytes appendFormat:@"%d ",(unsigned char)(*(myBytes + i))];
			szReadCommand = [strBytes copy];
			[strBytes release];
			// get distace
			unsigned char high = '\0';
			unsigned char low = '\0';
			if (sizeof(myBytes) >= 5 && [bDistance state])
			{
				high = (unsigned char)(*(myBytes + 4));
				low = (unsigned char)(*(myBytes + 5));
				float sensor_cal_distance = 82;
				float distance_actual = [self CalculateDistanceFromBytes:high low:low];
				float distance = distance_actual *(-1)+sensor_cal_distance;
				[self showInfomation:[NSString stringWithFormat:@"The distance is %.3f",distance] color:[NSColor greenColor]];
			}
		}
		
		[self showInfomation:[NSString stringWithFormat:@"Receive value : %@",szReadCommand] color:[NSColor purpleColor]];
		[self showInfomation:@"----------------------------------------------------------------------------------------------------" color:[NSColor orangeColor]];
	}
	else
	{
		[self showInfomation:@"Write error : The serial port is not connect well" color:[NSColor redColor]];
	}
}

- (NSAttributedString *)information
{
	return [textInfo textStorage];
}

- (NSString *)bsdPath
{
	return [[btnSerialPort selectedItem] title];
}

@end
