//
//  StationUnit.h
//  Robot-Simul
//
//  Created by Eagle on 2/18/13.
//
//

#import <Foundation/Foundation.h>
#import "StationCline.h"

@interface StationUnit : NSObject<NSApplicationDelegate>
{
    //control on the view
    IBOutlet NSView       *vSingleStation;
    IBOutlet NSTextField  *txtsStationIndex;
    IBOutlet NSTextField  *txteStatus;
    IBOutlet NSButton     *btnTriangle;
    
    //Unit setting
    IBOutlet NSPanel        *panelSetting;
    IBOutlet NSTextField    *IBTxtFailTime;
    IBOutlet NSTextField    *IBTxtPassTime;
    IBOutlet NSTextField    *IBTxtFailRate;
    IBOutlet NSTextField    *IBTxtRetestRate;    
    IBOutlet NSComboBox     *IBCobTestMode;
    
    NSString * m_strUnitName;
    
    //Station Client initialization
    StationCline            *m_SCObject;
	int                     iRunningNumber;
	NSNotificationCenter *nc;
}

@property (assign) IBOutlet NSView       *vSingleStation;
@property (assign) IBOutlet NSTextField  *txteStatus;
@property (assign) NSString              *m_UnitName;//havi
@property (assign)  StationCline         *SCObject;
@property (assign)  int                  RunningMLBCount;


-(id)initWithStatus:(NSString *)szStatus andStationName:(NSString *)szStationName;
-(IBAction)btnTriangleClick:(id)sender;
-(IBAction)btnSetClick:(id)sender;
-(IBAction)btnCancelClick:(id)sender;

//add for update test status on UI
-(void)beginSimulTest;
-(void)updateStatus:(NSNotification *)note;
//

@end
