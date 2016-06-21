#import "Bean_Result.h"



@implementation Bean_Result



-(id)init
{
	self	= [super init];
	if(self)
	{
		Index		= 0;
		ItemName	= [[NSString alloc] init];
		Limits		= [[NSString alloc] init];
		Value		= [[NSString alloc] init];
		Result		= YES;
	}
	return self;
}

-(void)dealloc
{
	[Value release];	Value		= nil;
	[Limits release];	Limits		= nil;
	[ItemName release];	ItemName	= nil;
	[super dealloc];
}



@synthesize Index;
@synthesize ItemName;
@synthesize Limits;
@synthesize Value;
@synthesize Result;



@end


