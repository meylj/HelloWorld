#import "FuckDCSD.h"

#import <IOKit/IOKitKeys.h>
#import <IOKit/serial/IOSerialKeys.h>
#import <IOKit/usb/IOUSBLib.h>



static void AddedOSDUT(void *refCon, io_iterator_t AddedIterators)
{
	// Traverse added iterators.
	io_object_t		itorAdded;
	char			*sLocationID	= (char*)malloc(sizeof(char)*128);
	while((itorAdded = IOIteratorNext(AddedIterators)))
	{
		// Get the parent.
		io_registry_entry_t	tParent;
		if(KERN_SUCCESS == IORegistryEntryGetParentEntry(itorAdded, kIOUSBPlane, &tParent))
		{
			// Get the sub devices under parent.
			io_iterator_t	SubIterators;
			if(KERN_SUCCESS == IORegistryEntryGetChildIterator(tParent, kIOUSBPlane, &SubIterators))
			{
				// Traverse all sub devices.
				io_object_t	itorSubs;
				while((itorSubs = IOIteratorNext(SubIterators)))
				{
					// Get LocationID.
					if(KERN_SUCCESS == IORegistryEntryGetLocationInPlane(itorSubs, kIOUSBPlane, sLocationID))
						[[NSNotificationCenter defaultCenter] postNotificationName:kFuckDCSDAddedOSDUTNote
																			object:nil
																		  userInfo:@{kFuckDCSDOSDUTKey:[NSString stringWithUTF8String:sLocationID]}];
				}
			}
		}
	}
	free(sLocationID);
}
static void RemovedOSDUT(void *refCon, io_iterator_t RemovedIterators)
{
    
	// Traverse added iterators.
	io_object_t		itorRemoved;
	char			*sLocationID	= (char*)malloc(sizeof(char)*128);
	while((itorRemoved = IOIteratorNext(RemovedIterators)))
	{
		// Get LocationID.
		if(KERN_SUCCESS == IORegistryEntryGetLocationInPlane(itorRemoved, kIOUSBPlane, sLocationID))
		{
			sLocationID[4]	+= 2;
			[[NSNotificationCenter defaultCenter] postNotificationName:kFuckDCSDRemovedOSDUTNote
																object:nil
															  userInfo:@{kFuckDCSDOSDUTKey:[NSString stringWithUTF8String:sLocationID]}];
		}
	}
	free(sLocationID);
}
static int DetectOSDUT()
{
	kern_return_t			kernResult;
	CFMutableDictionaryRef	classesToMatch;
	io_iterator_t			serialPortIterator;
	int						iVID	= kFuckDCSDDUTVID;
	int						iPID	= kFuckDCSDDUTPID;
	CFNumberRef				numVID	= CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &iVID);
	CFNumberRef				numPID	= CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &iPID);
	
	// A kind of USB device is identified via VID and PID.
	classesToMatch	= IOServiceMatching(kIOUSBDeviceClassName);
	if (classesToMatch != NULL)
	{
		CFDictionarySetValue(classesToMatch,
							 CFSTR(kUSBVendorID),
							 numVID);
		CFDictionarySetValue(classesToMatch,
							 CFSTR(kUSBProductID),
							 numPID);
		// Get all present USB devices.
		kernResult	= IOServiceGetMatchingServices(kIOMasterPortDefault,
												   classesToMatch,
												   &serialPortIterator);
		if (kernResult == KERN_SUCCESS)
		{
			AddedOSDUT(NULL, serialPortIterator);
			(void)IOObjectRelease(serialPortIterator);
		}
	}
	CFRelease(numVID);	numVID	= NULL;
	CFRelease(numPID);	numPID	= NULL;
	return YES;
}
static void registerOSDUTNotification()
{
	int						iVID	= kFuckDCSDDUTVID;
	int						iPID	= kFuckDCSDDUTPID;
	CFNumberRef				numVID	= CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &iVID);
	CFNumberRef				numPID	= CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &iPID);
	// Get the run loop for listening.
	IONotificationPortRef	notificationPort	= IONotificationPortCreate(kIOMasterPortDefault);
	if (notificationPort)
	{
		CFRunLoopSourceRef	notificationSource	= IONotificationPortGetRunLoopSource(notificationPort);
		if (notificationSource)
		{
			// A kind of USB device is identified via VID and PID.
			CFMutableDictionaryRef	classesToMatch1	= IOServiceMatching(kIOUSBDeviceClassName);
			if (classesToMatch1)
			{
				CFDictionarySetValue(classesToMatch1,
									 CFSTR(kUSBVendorID),
									 numVID);
				CFDictionarySetValue(classesToMatch1,
									 CFSTR(kUSBProductID),
									 numPID);
				CFMutableDictionaryRef	classesToMatch2	= CFDictionaryCreateMutableCopy(kCFAllocatorDefault,
																						0,
																						classesToMatch1);
				CFRunLoopAddSource([[NSRunLoop currentRunLoop] getCFRunLoop],
								   notificationSource,
								   kCFRunLoopCommonModes);
				// Register a system notification for new USB device adding.
				io_iterator_t	unused;
				kern_return_t	kernResult	= IOServiceAddMatchingNotification(notificationPort,
																			   kIOPublishNotification,
																			   classesToMatch1,
																			   AddedOSDUT,
																			   NULL,
																			   &unused);
				if (kernResult == KERN_SUCCESS)
					while (IOIteratorNext(unused)) {}
				// Register a system notification for USB device removing.
				if (classesToMatch2)
				{
					kernResult	= IOServiceAddMatchingNotification(notificationPort,
																   kIOTerminatedNotification,
																   classesToMatch2,
																   RemovedOSDUT,
																   NULL,
																   &unused);
					if (kernResult == KERN_SUCCESS)
						while (IOIteratorNext(unused)) {}
				}
			}
		}
	}
	CFRelease(numVID);	numVID	= NULL;
	CFRelease(numPID);	numPID	= NULL;
}



@implementation FuckDCSD
-(id)init
{
	if((self = [super init]))
	{
		DetectOSDUT();
		registerOSDUTNotification();
	}
	return self;
}
-(void)dealloc
{
	[super dealloc];
}
+(id)sharedFuckDCSD
{
	static FuckDCSD	*objDCSD	= nil;
	if(!objDCSD)
		objDCSD	= [FuckDCSD new];
	return objDCSD;
}
+(NSString*)findLocationID:(NSString*)strBSDPath
{
	kern_return_t			kernResult;
	CFMutableDictionaryRef	classesToMatch;
	io_iterator_t			serialPortIterator;
	char					*sLocationID	= (char*)malloc(sizeof(char)*128);
	NSString				*strLocationID	= nil;
	
	// A kind of USB device is identified via VID and PID.
	classesToMatch	= IOServiceMatching(kIOUSBDeviceClassName);
	if (classesToMatch != NULL)
	{
		// Get all present USB devices.
		kernResult	= IOServiceGetMatchingServices(kIOMasterPortDefault,
												   classesToMatch,
												   &serialPortIterator);
		if (kernResult == KERN_SUCCESS)
		{
			// Traverse to find the one.
			io_iterator_t	itorCables;
			while((itorCables = IOIteratorNext(serialPortIterator)))
			{
				// Get BSDPath.
				CFStringRef	bsdPath		= (CFStringRef)IORegistryEntrySearchCFProperty(itorCables,
																					   kIOServicePlane,
																					   CFSTR(kIOCalloutDeviceKey),
																					   kCFAllocatorDefault,
																					   kIORegistryIterateRecursively);
				if(bsdPath)
				{
					// Get location ID.
					if([(NSString*)bsdPath isEqualToString:strBSDPath])
						if(KERN_SUCCESS == IORegistryEntryGetLocationInPlane(itorCables, kIOServicePlane, sLocationID))
							strLocationID	= [NSString stringWithUTF8String:sLocationID];
					CFRelease(bsdPath);
				}
			}
			(void)IOObjectRelease(serialPortIterator);
		}
	}
	free(sLocationID);	sLocationID	= NULL;
	return strLocationID;
}
@end




