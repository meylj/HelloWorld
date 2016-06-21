#import <Cocoa/Cocoa.h>
#import "PuddingPDCA/TPuddingPDCA.h"
@interface TestPudding : NSObject {
	TPuddingPDCA		*m_InstantPudding;
	IBOutlet NSTextField	*m_DisplayVer;
	IBOutlet NSTextField	*m_StationVer;
	IBOutlet NSTextField	*m_StationName;
	IBOutlet NSTextField	*m_MainItem;
	IBOutlet NSTextField	*m_SubItem;
	IBOutlet NSTextField	*m_TestValue;
	IBOutlet NSTextField	*m_LowLimit;
	IBOutlet NSTextField	*m_HighLimit;
	IBOutlet NSTextField	*m_Units;
	IBOutlet NSTextField	*m_ISNumber;
	IBOutlet NSTextField	*m_ErrCode;
	IBOutlet NSTextField	*m_Limits;
	IBOutlet NSTextField	*m_Identifier;
	IBOutlet NSTextField	*m_edtErrCode;
	IBOutlet NSTextField	*m_edtPuddingVer;
}
- (IBAction)TestAct1:(id)sender;
- (IBAction)InitPuddingAct:(id)sender;
- (IBAction)StartPuddingAct:(id)sender;
- (IBAction)SetISN_Number:(id)sender;
- (IBAction)AddTestItemAct:(id)sender;
- (IBAction)SubmmitReslutAct:(id)sender;
- (IBAction)PackageZipAct:(id)sender;
- (IBAction)GetPuddingVerAct:(id)sender;
@end
