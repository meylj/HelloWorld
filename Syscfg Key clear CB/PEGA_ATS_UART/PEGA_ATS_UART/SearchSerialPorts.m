//
//  SearchSerialPorts.m
//  PEGA_ATS_UART
//
//  Created by Eagle on 4/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//



#import "SearchSerialPorts.h"



@implementation SearchSerialPorts

-(id)init
{
    if ((self = [super init]))
	{
        
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (UInt16)SearchSerialPorts:(NSMutableArray *)in_out_arrSerialPorts
{
    int						iFound = 0;
	kern_return_t			kernResult; 
	CFMutableDictionaryRef	classesToMatch;
	io_iterator_t			serialPortIterator;
	classesToMatch	= IOServiceMatching(kIOSerialBSDServiceValue);
	if (classesToMatch != NULL)
	{
		CFDictionarySetValue(classesToMatch, CFSTR(kIOSerialBSDTypeKey), CFSTR(kIOSerialBSDAllTypes));
		
		// This function decrements the refcount of the dictionary passed it
		kernResult	= IOServiceGetMatchingServices(kIOMasterPortDefault, classesToMatch, &serialPortIterator);  
		if (kernResult == KERN_SUCCESS)
		{
            io_object_t	serialService	= IOIteratorNext(serialPortIterator);
            while (serialService != 0) 
            {
                CFStringRef	modemName		= (CFStringRef)IORegistryEntryCreateCFProperty(serialService,
																						   CFSTR(kIOTTYDeviceKey),
																						   kCFAllocatorDefault,
																						   0);
                CFStringRef	bsdPath			= (CFStringRef)IORegistryEntryCreateCFProperty(serialService,
																						   CFSTR(kIOCalloutDeviceKey),
																						   kCFAllocatorDefault,
																						   0);
                CFStringRef	serviceType		= (CFStringRef)IORegistryEntryCreateCFProperty(serialService,
																						   CFSTR(kIOSerialBSDTypeKey),
																						   kCFAllocatorDefault,
																						   0);
                NSString	*szModemName	= [NSString stringWithFormat:@"%@",modemName];
                char	*cLoc	= strstr([[szModemName lowercaseString] UTF8String], "kong");
                if (cLoc == NULL)
                    cLoc = strstr([szModemName UTF8String], "usbserial");
                if (cLoc == NULL)
                    cLoc = strstr([szModemName UTF8String], "usbmodem");
                if (cLoc != NULL) //have find The left operand is greater than the right operand(cu.usbserial)
                {
                    NSString	*szUsbSerial	= [NSString stringWithFormat:@"%@",(NSString *)bsdPath];
                    [in_out_arrSerialPorts addObject:szUsbSerial];
                    iFound++;
                }
                NSLog(@"modemName = %@,bsdPath = %@,serviceType = %@",modemName,bsdPath,serviceType);
                CFRelease(modemName);
                CFRelease(bsdPath);
                CFRelease(serviceType);
                serialService	= IOIteratorNext(serialPortIterator);
            }
			(void)IOObjectRelease(serialPortIterator);
		} 
		NSLog(@"IOServiceGetMatchingServices returned %d", kernResult);
	}
	return iFound;
}

- (void)FindSerialPortsFromDisk:(NSMutableArray *)in_out_arrSerialPorts
{
    NSFileManager *fm       = [NSFileManager defaultManager];
    NSArray *dirContents    = [fm contentsOfDirectoryAtPath:@"/dev" error:nil];
    NSPredicate *fltr       = [NSPredicate predicateWithFormat:@"self BEGINSWITH 'cu.usb'"];
    NSArray *serialPorts    = [dirContents filteredArrayUsingPredicate:fltr];
    
    for (NSString *name in serialPorts)
    {
        [in_out_arrSerialPorts addObject:[NSString stringWithFormat:@"/dev/%@", name]];
    }
    
    NSLog(@"Has find all cu.usb port from disk [%@].", in_out_arrSerialPorts);

}

-(UInt16)SearchPortsNumber:(NSMutableDictionary*)dicPortSerialNumber
{    
    int						iFound					=0;
    io_iterator_t			iterator				= IO_OBJECT_NULL, iterDeviceTemp = IO_OBJECT_NULL;
    CFMutableDictionaryRef	myUSBMatchDictionary	= IO_OBJECT_NULL;
    //get the information named "KongSWD"
    myUSBMatchDictionary	= IOServiceNameMatching("KongSWD");
    //find the usb port
    IOServiceGetMatchingServices(kIOMasterPortDefault, myUSBMatchDictionary, &iterator);
	CFMutableDictionaryRef	dicProperty				= nil;
	while((iterDeviceTemp = IOIteratorNext(iterator)))
	{//get the porperties of the device
		kern_return_t	kr = IORegistryEntryCreateCFProperties(iterDeviceTemp,
															   &dicProperty,
															   kCFAllocatorDefault,
															   kNilOptions);
		NSLog(@"%@",(NSDictionary*)dicProperty);
        if(kIOReturnSuccess == kr)
		{
            CFStringRef	bsdPath			= (CFStringRef)IORegistryEntrySearchCFProperty(iterDeviceTemp,
																					   kIOServicePlane,
																					   CFSTR(kIOCalloutDeviceKey),
																					   kCFAllocatorDefault,
																					   kIORegistryIterateRecursively);
            CFStringRef	serialNumber	= (CFStringRef)IORegistryEntrySearchCFProperty(iterDeviceTemp,
																					   kIOServicePlane,
																					   CFSTR(kUSBSerialNumberString),
																					   kCFAllocatorDefault,
																					   kIORegistryIterateRecursively);
            NSString	*szNumber		=[NSString stringWithFormat:@"%@",serialNumber];
            if ( szNumber !=nil&& ![szNumber isEqualToString:@""])
            {
                [dicPortSerialNumber setValue:szNumber forKey:[NSString stringWithFormat:@"%@",bsdPath]];
                iFound++;
            }
            else
                NSLog(@"Can't read serial number,please check the device!");
            NSLog(@"the modename is %@, the serialnumber is %@",bsdPath,serialNumber);
            if (bsdPath)
                CFRelease(bsdPath);
            if (serialNumber)
                CFRelease(serialNumber);
		}
	}
    if (dicProperty)
        CFRelease(dicProperty);
    if (iterDeviceTemp)
        IOObjectRelease(iterDeviceTemp);
    return iFound;
}

@end




