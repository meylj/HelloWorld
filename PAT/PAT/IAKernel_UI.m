#import "IAKernel_UI.h"



@implementation IAKernel (IAKernel_UI)



#pragma mark - Result Communication and Show 
-(void)showResultOnUI:(Bean_Result *)result
{
	NSString	*strValue	= [result.Value description];
	strValue	= [strValue stringByReplacingOccurrencesOfString:@"\r\n" 
												   withString:@" "];
	strValue	= [strValue stringByReplacingOccurrencesOfString:@"\r" 
												   withString:@" "];
	strValue	= [strValue stringByReplacingOccurrencesOfString:@"\n" 
												   withString:@" "];
	NSDictionary	*dictResult	= [NSDictionary dictionaryWithObjectsAndKeys:
								   [NSNumber numberWithUnsignedInteger:result.Index],	@"Index",
								   (result.Result 
									? [NSImage imageNamed:@"PASS.gif"] 
									: [NSImage imageNamed:@"FAIL.gif"]),				@"Result",
								   [result.ItemName subFrom:@"." include:NO],			@"ItemName",
								   result.Limits,	@"Limits",
								   strValue,		@"Value",nil];
	@synchronized(m_aryProcessed)
	{
		[m_aryProcessed addObject:dictResult];
	}
}



#pragma mark - tableResults Delegate 
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [m_aryProcessed count];
}

-(id)tableView:(NSTableView *)tableView 
objectValueForTableColumn:(NSTableColumn *)tableColumn 
		   row:(NSInteger)row
{
	if(row >= [m_aryProcessed count])
		return nil;
	NSString	*strIdentifier	= [tableColumn identifier];
	return [[m_aryProcessed objectAtIndex:row] objectForKey:strIdentifier];
}

-(void)tableView:(NSTableView *)tableView 
sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
	NSArray	*newDescriptors	= [tableView sortDescriptors];
	[m_aryProcessed sortUsingDescriptors:newDescriptors];
}



@end


