#import "PATTests.h"



@implementation PATTests



- (void)setUp
{
    [super setUp];
}



- (void)tearDown
{
    [super tearDown];
}

- (void)testExample
{
	IAKernel	*kernel	= [[IAKernel alloc] init];
	NSDictionary	*dictInfo	= [kernel queryData:[NSDictionary dictionaryWithObject:@"\n" forKey:@"mlbsn"] 
									   fromURL:@"http://172.28.144.98/N94Bobcat/N94SFC?p" 
									  withInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"QUERY_RECORD",	@"c",
												@"C8PGN016DTD7",	@"sn", nil] 
										 error:nil];
	[kernel release];	kernel	= nil;
}



@end


