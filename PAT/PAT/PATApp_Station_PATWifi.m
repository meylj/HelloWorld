#import "PATApp_Station_PATWifi.h"



@implementation PATApp (PATApp_Station_PATWifi)



#pragma mark - Listen and Start 
-(void)listenNoteDiagramShouldBegin:(NSNotification*)note
{
	NSArray	*aryMagnitude	= [[note userInfo] objectForKey:@"Magnitude"];
	NSArray	*aryPhase		= [[note userInfo] objectForKey:@"Phase"];
	[self drawDiagramsByMagnitude:aryMagnitude 
						 andPhase:aryPhase];
}

/*create by jingfu ran on 
 description:	 Get  limit info form a arrlimt
 Parameter:
 arrLimit: 
 refer the setting file!
 
 Result:   
 get Uplimit and downlimit value . Store in dictionary!
 arrFreq  Type: NSMutableArray  mean:Freq                       <-------- key value -------->FREQ
 arrLowMag  Type: NSMutableArray  mean: down limit magnitude    <------- key value -------->LOWMAG
 arrLowPhase  Type: NSMutableArray  mean: down limit phase      <----- key value --------->LOWPHASE
 arrHighMag  Type: NSMutableArray  mean: up limit magnitude     <---- key value ---------->HIGHMAG
 arrHighPhase  Type: NSMutableArray  mean: up limit phase       <---  key value  ------->HIGHPHASE
 */
-(NSMutableDictionary *)GetTheDicpointFromArray:(NSArray *)arrLimit
{
	float	fXStartFreq			= 0;
	float	fXEndFreq			= 0;
	float	fFirstLowMag		= 0;
	float	fFirstHighMag		= 0;
	float	fFirstLowPhase		= 0;
	float	fFirstHighPhase		= 0;
	float	fSencendLowPhase	= 0;
	float	fSencendHighPhase	= 0;
	float	fSencendLowMag		= 0;
	float	fSencendHighMag		= 0;
	NSMutableArray	*arrFreq		= [[NSMutableArray alloc] init];
	NSMutableArray	*arrLowMag		= [[NSMutableArray alloc] init];
	NSMutableArray	*arrLowPhase	= [[NSMutableArray alloc] init];
	NSMutableArray	*arrHighMag		= [[NSMutableArray alloc] init];
	NSMutableArray	*arrHighPhase	= [[NSMutableArray alloc] init];
	NSMutableDictionary  *dicTemp	= [[NSMutableDictionary alloc] init];
    for (int i = 0; i < [arrLimit count]; i+=2) 
    {
        if ([arrLimit count] < i+1) 
            return nil;
        NSArray *arrTempOne = [[arrLimit objectAtIndex:i] componentsSeparatedByString:@":"];
        NSArray *arrTempTwo = [[arrLimit objectAtIndex:i+1] componentsSeparatedByString:@":"];
        
        if ([arrTempOne count] < 5 || [arrTempTwo count] < 5) 
            return nil;
        fXStartFreq		= [[arrTempOne objectAtIndex:0] floatValue];
        fXEndFreq		= [[arrTempTwo objectAtIndex:0] floatValue];
        fFirstLowMag	= [[arrTempOne objectAtIndex:1] floatValue];
        fFirstHighMag	= [[arrTempOne objectAtIndex:2] floatValue];
        fFirstLowPhase	= [[arrTempOne objectAtIndex:3] floatValue];
        fFirstHighPhase	= [[arrTempOne objectAtIndex:4] floatValue];
        
        fSencendLowMag		= [[arrTempTwo objectAtIndex:1] floatValue];
        fSencendHighMag		= [[arrTempTwo objectAtIndex:2] floatValue];
        fSencendLowPhase	= [[arrTempTwo objectAtIndex:3] floatValue];
        fSencendHighPhase	= [[arrTempTwo objectAtIndex:4] floatValue];
        
        [arrFreq addObject:[NSNumber numberWithFloat:fXStartFreq]];
        [arrFreq addObject:[NSNumber numberWithFloat:fXEndFreq]];
        [arrLowMag addObject:[NSNumber numberWithFloat:fFirstLowMag]];
        [arrLowMag addObject:[NSNumber numberWithFloat:fSencendLowMag]];
        [arrLowPhase addObject:[NSNumber numberWithFloat:fFirstLowPhase]];
        [arrLowPhase addObject:[NSNumber numberWithFloat:fSencendLowPhase]];
        [arrHighMag addObject:[NSNumber numberWithFloat:fFirstHighMag]];
        [arrHighMag addObject:[NSNumber numberWithFloat:fSencendHighMag]];
        [arrHighPhase addObject:[NSNumber numberWithFloat:fFirstHighPhase]];
        [arrHighPhase addObject:[NSNumber numberWithFloat:fSencendHighPhase]];
    }
    
    [dicTemp setObject:arrFreq forKey:@"FREQ"];
    [dicTemp setObject:arrLowMag forKey:@"LOWMAG"];
    [dicTemp setObject:arrHighMag forKey:@"HIGHMAG"];
    [dicTemp setObject:arrLowPhase forKey:@"LOWPHASE"];
    [dicTemp setObject:arrHighPhase forKey:@"HIGHPHASE"];
	
    return dicTemp;
}

/*create by jingfu ran on 
 description:	 Get  limit info form file
 Parameter:
 filePath: 
 The setting file path!
 
 Result:   
 get limit value alue . Store in dictionary!
 LE  Type: NSMutableDictionary  mean: LE limit info    <-------- key value -------->LE
 LU  Type: NSMutableDictionary  mean: LU limit info    <-------  key value -------->LU
 WE  Type: NSMutableDictionary  mean: WE limit info    <-------  key value -------->WE
 WU  Type: NSMutableDictionary  mean: WU limit info    <-------  key value -------->WU
 */
-(NSMutableDictionary *)ReadLimitFromConfigFile:(NSString *)filePath
{
    NSDictionary	*dicForPlist	= [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSMutableDictionary	*dicLimit	= [[NSMutableDictionary alloc] init];
    if (dicForPlist == nil) 
        return nil;
    
    NSArray	*arrLimit	= [dicForPlist objectForKey:@"LE"];
    [dicLimit setObject:[self GetTheDicpointFromArray:arrLimit] forKey:@"LE"];
    arrLimit	= [dicForPlist objectForKey:@"LU"];
    [dicLimit setObject:[self GetTheDicpointFromArray:arrLimit] forKey:@"LU"];
    arrLimit	= [dicForPlist objectForKey:@"WE"];
    [dicLimit setObject:[self GetTheDicpointFromArray:arrLimit] forKey:@"WE"];
    arrLimit	= [dicForPlist objectForKey:@"WU"];
    [dicLimit setObject:[self GetTheDicpointFromArray:arrLimit] forKey:@"WU"];
    
    [dicLimit retain];
    return dicLimit;
}



#pragma mark - Draw Diagram 
-(BOOL)drawDiagramsByMagnitude:(NSArray*)aryMagnitude 
					  andPhase:(NSArray*)aryPhase
{
	NSString			*filepath	= @"/Users/izualazurewrath/Desktop/PAT/PAT/PAT/Limits.plist";
    NSMutableDictionary *dicLimit	= [self ReadLimitFromConfigFile:filepath];
    NSMutableDictionary *dicLELimit	= [dicLimit objectForKey:@"WE"];
	
	[m_viewPhase DrawChartAccordValue:[dicLELimit objectForKey:@"FREQ"] 
							   Yarray:[dicLELimit objectForKey:@"LOWPHASE"] 
							  IsPhase:YES 
								color:[NSColor greenColor] 
							Operition:NOCANCEL];
	[m_viewPhase DrawChartAccordValue:[dicLELimit objectForKey:@"FREQ"] 
							   Yarray:[dicLELimit objectForKey:@"HIGHPHASE"] 
							  IsPhase:YES 
								color:[NSColor greenColor] 
							Operition:NOCANCEL];
	[m_viewMagnitud DrawChartAccordValue:[dicLELimit objectForKey:@"FREQ"] 
								  Yarray:[dicLELimit objectForKey:@"LOWMAG"] 
								 IsPhase:NO 
								   color:[NSColor greenColor] 
							   Operition:NOCANCEL];
	[m_viewMagnitud DrawChartAccordValue:[dicLELimit objectForKey:@"FREQ"] 
								  Yarray:[dicLELimit objectForKey:@"HIGHMAG"] 
								 IsPhase:NO 
								   color:[NSColor greenColor] 
							   Operition:NOCANCEL];
	
    NSMutableArray	*arrForman		= [[NSMutableArray alloc] init];
    NSMutableArray	*arrForPhase	= [[NSMutableArray alloc] init];
    NSMutableArray	*arrForFeq		= [[NSMutableArray alloc] init];

	float kFreq = 450;
    for (int i = 0; i< [aryPhase count]; i++)
    {
        float  fdata = [[aryPhase objectAtIndex:i] floatValue];
        
        if (fdata < 0 ) 
        {
            fdata = 360+fdata;
        }
        [arrForPhase addObject:[NSNumber numberWithFloat:fdata]];
        [arrForFeq addObject:[NSNumber numberWithFloat:kFreq]];
        
        if (kFreq > 3000) 
        {
            [arrForFeq removeLastObject];
        }
        
        kFreq += (3000-450)/201;
    }
    arrForman = [NSMutableArray arrayWithArray:aryMagnitude];
	
	[m_viewPhase DrawChartAccordValue:arrForFeq 
							   Yarray:arrForPhase 
							  IsPhase:YES 
								color:[NSColor redColor] 
							Operition:NOCANCEL];
	[m_viewMagnitud DrawChartAccordValue:arrForFeq 
								  Yarray:arrForman 
								 IsPhase:NO 
								   color:[NSColor redColor] 
							   Operition:NOCANCEL];
	[m_viewSmith DrawSmithChart:arrForman 
						  Phase:arrForPhase];
	return YES;
}



@end


