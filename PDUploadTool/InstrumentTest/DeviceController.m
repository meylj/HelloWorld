#import "DeviceController.h"

@implementation DeviceController

- (id) init {
	m_PPS_Device = [[PPS_Device alloc] init];
	m_Device_34970 = [[Device_34970 alloc] init];
	m_Device_53131 = [[Device_53131 alloc] init];
    aryCurrent  =   [[NSMutableArray alloc] init];
    aryFrequency    =   [[NSMutableArray alloc]init];
    aryResistance   =   [[NSMutableArray alloc]init];
    aryVoltage  =   [[NSMutableArray alloc]init];
	return [super init];
}

- (void) dealloc {
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter]; 
    [nc removeObserver:self]; 
	[m_Device_34970 release];
	[m_PPS_Device release];
	[m_Device_53131 release];
    [aryCurrent release];
    [aryFrequency release];
    [aryResistance release];
    [aryVoltage release];
	[super dealloc];
}

- (IBAction)GetFrameworkVerAct:(id)sneder {
	[edtVersion setStringValue:[m_Device_34970 getInterfaceVersion]];
}

- (void)handleColorChange:(NSNotification *)note 
{ 
    NSLog(@"Received notification: %@", note); 
} 

- (IBAction)GetCurrentAct:(id)sender {
	float		fCurrent = 0;
    [m_PPS_Device GetCurrent:[edtChannel intValue] Current:&fCurrent];
	[edtCurrent setFloatValue:fCurrent];
}

- (IBAction)InitialAct:(id)sender {
	[m_PPS_Device getInterfaceVersion];
    [m_PPS_Device setInitialDevice:[edtBoardID intValue] 
					   PrimaryAddr:[edtPriAddr intValue]];
}

- (IBAction)SetCurrLimitAct:(id)sender {
    [m_PPS_Device SetCurrLimit:[edtChannel intValue] Current:[edtCurrLimit floatValue]];
}

- (IBAction)SetVoltageAct:(id)sender {
    [m_PPS_Device SetVoltage:[edtChannel intValue] Voltage:[edtVoltage floatValue]];
}

- (IBAction)setOutputOffAct:(id)sender {
    [m_PPS_Device SetPowrSwitch:[edtChannel intValue] PowerON:NO];
}

- (IBAction)setOutputOnAct:(id)sender {
    [m_PPS_Device SetPowrSwitch:[edtChannel intValue] PowerON:YES];
}

- (IBAction)ReleaseDevice:(id)sender {
	[m_PPS_Device releaseDevice];
}

- (IBAction)InitialAct1:(id)sender {
	[m_Device_34970 setInitialDevice:[edtBoardID1 intValue] PrimaryAddr:[edtPriAddr1 intValue]];
}

- (IBAction)OpenRoutAct:(id)sender {
	[m_Device_34970 setRoutSwitch:NO ChannelLists:[edtChannel1 stringValue]];
}

- (IBAction)CloseRoutAct:(id)sender {
	[m_Device_34970 setRoutSwitch:YES ChannelLists:[edtChannel1 stringValue]];
}

- (IBAction)GetDC_VoltageAct:(id)sender {
	[m_Device_34970 getMeasureVoltage:YES ChannelLists:[edtChannel1 stringValue] Voltage:aryVoltage];
}

- (IBAction)GetAC_VoltageAct:(id)sender {
	[m_Device_34970 getMeasureVoltage:NO ChannelLists:[edtChannel1 stringValue] Voltage:aryVoltage];
}

- (IBAction)GetDC_CurrentAct:(id)sender {
	[m_Device_34970 getMeasureCurrent:YES ChannelLists:[edtChannel1 stringValue] Current:aryCurrent];
}

- (IBAction)GetAC_CurrentAct:(id)sender {
	[m_Device_34970 getMeasureCurrent:NO ChannelLists:[edtChannel1 stringValue] Current:aryCurrent];
}

- (IBAction)GetFrequencyAct:(id)sender {
	[m_Device_34970 getMeasureFrequency:[edtChannel1 stringValue] Frequency:aryFrequency];
}

- (IBAction)GetResistanceAct:(id)sender {
	int nRange;
	if ([[cbResistanceRange stringValue] isEqualToString:@"100 MΩ"])
		nRange = k100Mohm;
	else
	if ([[cbResistanceRange stringValue] isEqualToString:@"10 MΩ"])
		nRange = k10Mohm;
	else
	if ([[cbResistanceRange stringValue] isEqualToString:@"1 MΩ"])
		nRange = k1Mohm;
	else
	if ([[cbResistanceRange stringValue] isEqualToString:@"100 kΩ"])
		nRange = k100Kohm;
	else
	if ([[cbResistanceRange stringValue] isEqualToString:@"10 kΩ"])
		nRange = k10Kohm;
	else
	if ([[cbResistanceRange stringValue] isEqualToString:@"1 kΩ"])
		nRange = k1Kohm;
	else
	if ([[cbResistanceRange stringValue] isEqualToString:@"100Ω"])
		nRange = k100ohm;
	else
		nRange = kAutoRange;
/*	[m_Device_34970 getMeasureResistance:[edtChannel1 stringValue] Range:nRange 
							  Resistance:&aryResistance];*/
	[m_Device_34970 readMeasureResistance:[edtChannel1 stringValue] 
									Range:nRange 
							 IntervalTime:0.1 
							   FetchCount:10 
							   Resistance:aryResistance];
}

- (IBAction)RST_Act:(id)sender {
	[m_PPS_Device setRST_Command];
	[m_PPS_Device setCLS_Command];
}

- (IBAction)RST_Act1:(id)sender {
	[m_Device_34970 setRST_Command];
	[m_Device_34970 setCLS_Command];
}

- (IBAction)ReleaseDeviceAct1:(id)sender {
	[m_Device_34970 releaseDevice];
}

- (int)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
	NSLog(@"%d",[aComboBox tag]); 
	switch ([aComboBox tag]) {
		case 101:
			return [aryVoltage count];
		case 102:
			return [aryCurrent count];
		case 103:
			return [aryResistance count];
		case 104:
			return [aryFrequency count];
		default:
			return 0;
	}
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(int)index
{
	NSLog(@"%d",[aComboBox tag]); 
	switch ([aComboBox tag]) {
		case 101:
			return [aryVoltage objectAtIndex:index];
		case 102:
			return [aryCurrent objectAtIndex:index];
		case 103:
			return [aryResistance objectAtIndex:index];
		case 104:
			return [aryFrequency objectAtIndex:index];
		default:
			return @"";
	}
}

- (IBAction)InitialAct2:(id)sender {
	[m_Device_53131 setInitialDevice:[edtBoardID2 intValue] PrimaryAddr:[edtPriAddr2 intValue]];
}

- (IBAction)ReleaseDeviceAct2:(id)sender {
	[m_Device_53131 releaseDevice];
}

- (IBAction)getFrequency_32KHzAct:(id)sender {
	int nRetCode = kSuccessCode;
	float	fFrequency = 0;
	
	nRetCode = [m_Device_53131 setMeasureFrequency];
	if (nRetCode == kSuccessCode)
		nRetCode = [m_Device_53131 getMeasureValue:&fFrequency];
	if (nRetCode == kSuccessCode)
		[edtFrequency setFloatValue:fFrequency];
}

- (IBAction)getFrequency_90MHzAct:(id)sender {

}
@end
