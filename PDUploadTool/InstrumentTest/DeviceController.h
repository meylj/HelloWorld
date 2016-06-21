#import <Cocoa/Cocoa.h>
#import "InstrumentLibrary/PPS_Device.h"
#import "InstrumentLibrary/Device_34970.h"
#import "InstrumentLibrary/Device_53131.h"

@interface DeviceController : NSObject {
    IBOutlet NSTextField *edtBoardID;
    IBOutlet NSTextField *edtChannel;
    IBOutlet NSTextField *edtCurrLimit;
    IBOutlet NSTextField *edtCurrent;
    IBOutlet NSTextField *edtPriAddr;
    IBOutlet NSTextField *edtVoltage;
	IBOutlet NSTextField *edtBoardID1;
	IBOutlet NSTextField *edtPriAddr1;
	IBOutlet NSTextField *edtChannel1;
	IBOutlet NSTextField *edtVersion;
	IBOutlet NSComboBox  *cbVoltage;
	IBOutlet NSComboBox  *cbResistance;
	IBOutlet NSComboBox	 *cbCurrent;
	IBOutlet NSComboBox	 *cbFrequency;
	IBOutlet NSComboBox	 *cbResistanceRange;
	IBOutlet NSTextField *edtBoardID2;
	IBOutlet NSTextField *edtPriAddr2;
	IBOutlet NSTextField *edtFrequency;
	NSMutableArray		*aryVoltage;
	NSMutableArray		*aryResistance;
	NSMutableArray		*aryCurrent;
	NSMutableArray		*aryFrequency;
	PPS_Device			*m_PPS_Device;
	Device_34970		*m_Device_34970;
	Device_53131		*m_Device_53131;
}
- (IBAction)GetCurrentAct:(id)sender;
- (IBAction)InitialAct:(id)sender;
- (IBAction)SetCurrLimitAct:(id)sender;
- (IBAction)SetVoltageAct:(id)sender;
- (IBAction)setOutputOffAct:(id)sender;
- (IBAction)setOutputOnAct:(id)sender;
- (IBAction)ReleaseDevice:(id)sender;
- (IBAction)InitialAct1:(id)sender;
- (IBAction)OpenRoutAct:(id)sender;
- (IBAction)CloseRoutAct:(id)sender;
- (IBAction)GetDC_VoltageAct:(id)sender;
- (IBAction)GetAC_VoltageAct:(id)sender;
- (IBAction)GetDC_CurrentAct:(id)sender;
- (IBAction)GetAC_CurrentAct:(id)sender;
- (IBAction)GetFrequencyAct:(id)sender;
- (IBAction)GetResistanceAct:(id)sender;
- (IBAction)RST_Act:(id)sender;
- (IBAction)RST_Act1:(id)sender;
- (IBAction)ReleaseDeviceAct1:(id)sender;
- (IBAction)GetFrameworkVerAct:(id)sneder;
- (IBAction)InitialAct2:(id)sender;
- (IBAction)ReleaseDeviceAct2:(id)sender;
- (IBAction)getFrequency_32KHzAct:(id)sender;
- (IBAction)getFrequency_90MHzAct:(id)sender;
@end
