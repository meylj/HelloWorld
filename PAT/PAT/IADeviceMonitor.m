#import "IADeviceMonitor.h"



IADeviceMonitor	*deviceMonitor;



@implementation IADeviceMonitor



#pragma mark - NSObject Override
-(id)init
{
	self	= [super init];
    if (self) 
	{
		
    }
	return self;
}

-(void)dealloc
{
	return;
	[super dealloc];
}



+(IADeviceMonitor*)deviceMonitor
{
	if(!deviceMonitor)
		deviceMonitor	= [[IADeviceMonitor alloc] init];
	return deviceMonitor;
}



@end


