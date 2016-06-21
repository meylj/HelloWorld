//
//  SingleStation.h
//  Robot-Simul
//
//  Created by Eagle on 2/17/13.
//
//

#import <Foundation/Foundation.h>
#import "StationUnit.h"

#define DEFAULT_STATION_UNIT_COUNT  4

@interface SingleStation : NSObject<NSApplicationDelegate>
{
    //view
    IBOutlet NSView       *vStationType;    
    IBOutlet NSTextField  *IBTxtFNRunningCount;
    IBOutlet NSTextField  *IBTxtFUnitsCount;
    IBOutlet NSTextField  *IBTxtFirstFail;
    IBOutlet NSTextField  *IBTxtSecondFail;
    IBOutlet NSComboBox   *IBCobRetestRule;
    IBOutlet NSTextField  *IBTxtFailTestTime;
    IBOutlet NSTextField  *IBTxtPassTestTime;
    IBOutlet NSTextField  *IBTxtFailRate;
    IBOutlet NSTextField  *IBTxtRetestRate;
    IBOutlet NSComboBox   *IBCobTestMode;
//    IBOutlet NSButton     *IBBtnOK;
    IBOutlet NSButton     *IBBtnSet;
    //set window
    IBOutlet NSPanel      *IBPanelMatrix;
    IBOutlet NSTextField  *IBTxtRow;
    IBOutlet NSTextField  *IBTxtColumn;
    
    IBOutlet NSTextField  *IBTxtPassCount;
    IBOutlet NSTextField  *IBTxtInputCount;
    IBOutlet NSTextField  *IBTxtFailCount;
    
    NSString              *m_szStationName;
    NSMutableArray        *m_mtaryStationUnits;
    int                    m_iUnitNumber;
	int                    m_iRunningMLBNumber;
    NSNumber              *m_iRunningNumber;
}

@property (assign) IBOutlet NSView       *vStationType;
//@property (assign) IBOutlet NSButton     *IBBtnOK;
@property (assign) IBOutlet NSButton     *IBBtnSet;
@property (assign) IBOutlet NSTextField  *IBTxtPassCount;
@property (assign) IBOutlet NSTextField  *IBTxtInputCount;
@property (assign) IBOutlet NSTextField  *IBTxtFailCount;
@property (assign) IBOutlet NSTextField  *IBTxtFirstFail;
@property (assign) IBOutlet NSTextField  *IBTxtSecondFail;
@property (assign) IBOutlet NSTextField  *IBTxtFailTestTime;
@property (assign) IBOutlet NSTextField  *IBTxtPassTestTime;
@property (assign) IBOutlet NSTextField  *IBTxtRetestRate;
@property (assign) IBOutlet NSTextField  *IBTxtFailRate;
@property (assign) IBOutlet NSComboBox   *IBCobRetestRule;
@property (retain) NSString              *StationName;
@property (assign) NSMutableArray        *MtaryStationUnits;

@property (assign) int                    RunningMLBNumber;
@property (assign) NSNumber               *RunningNumber;
@property (assign) int                    stationUnitNumber;//havi
-(void)initWithStationNum:(NSInteger)num;//havi
-(void)loadUnitsWithRow:(int)iRow Column:(int)iColumn total:(int)iTotal withContainer:(NSScrollView *)view;
-(void)loadStationUnits:(NSInteger)iUnitNumber withStationName:(NSArray *)stationName;
//-(IBAction)btnStationCountSetOK:(id)sender;
-(IBAction)btnSetOk:(id)sender;
-(IBAction)btnMatrixSet:(id)sender;

//begin Simul test
-(void)beginSimulTest;
-(void)updateRunningCount;
@end
