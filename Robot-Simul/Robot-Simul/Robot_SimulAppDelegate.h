//
//  Robot_SimulAppDelegate.h
//  Robot-Simul
//
//  Created by Eagle on 1/26/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SingleStation.h"
#import "RobotServer.h"
#import "StationCline.h"
#import "LogManager.h"
int G_SPEED = 100000;

@interface Robot_SimulAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource,NSTableViewDelegate> {
    
    //setting window
    NSWindow *window;
    NSMutableArray          *m_mtaryStations;
    NSInteger                m_stationCount;//havi
    IBOutlet NSTextField    *IBTxtFSpeed;
    IBOutlet NSTextField    *IBTestEndTime;//add for end time;havi
    IBOutlet NSTextField    *IBTxtRobotCoordinate;
    IBOutlet NSTextField    *IBTxtPassAreaCoordinate;
    IBOutlet NSTextField    *IBTxtFailAreaCoordinate;
    IBOutlet NSTextField    *IBTxtUntestAreaCoordinate;
    IBOutlet NSTextField    *IBTxtRobotMoveSpeed;
    IBOutlet NSTextField    *IBTxtUnitSlotNum;
    IBOutlet NSTextField    *IBTxtRobotPicker;
    
    //Controls on Main Window
    IBOutlet NSWindow     *winMain;
    IBOutlet NSTextField  *txtStatusPass;
    IBOutlet NSTextField  *txtStatusFail;
    IBOutlet NSTextField  *txtStatusReady;
    IBOutlet NSTextField  *txtStatusTesting;
    //
    IBOutlet NSTabView    *tbvStations;
    IBOutlet NSTableView  *tblvActionMsg;
    IBOutlet NSTextField  *txtneStationEfficiency;
    IBOutlet NSButton     *btnStart;
    
    IBOutlet NSTextField  *IBtxtInputUnitNumber;
    
    NSMutableArray        *m_mtarySingleStations;
    NSMutableArray        *m_aryStationName;//havi
    NSMutableDictionary   *m_dicSaveSetting;//havi,for save setting
    NSMutableDictionary   *m_dicSetting;
	NSMutableArray        *m_aryConfigation;//for 
    RobotServer           *m_RSObject;
    NSNotificationCenter  *nv;
	NSString              *m_strSettingTime;
    BOOL                  bLock;
}

@property (assign) IBOutlet NSWindow *window;
-(IBAction)btnSet:(id)sender;

-(IBAction)btnEnd:(id)sender;
-(IBAction)btnStart:(id)sender;
-(void)updateTotalRunningCount;
- (void)setUnitCoordinate:(NSString *)szStationType OfStation:(SingleStation *)station ofCoordinate:(NSDictionary *)dicStationCoordinate ;//havi

@end
