//
//  AppDelegate.h
//  LimitsSplot
//
//  Created by User on 12-11-3.
//  Copyright (c) 2012年 User. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CorePlot/CorePlot.h>
#import <LibXL/LibXL.h>
#import "CGSPrivate.h"

typedef enum
{
    kNoneRule = 0,
    kConfigRule,
    kStationIdRule,
    kCancelRule,
}SAPickRule;

typedef enum
{
    kNoneType = 0,
    kRowType,
    kColType,
}SAGetType;

typedef struct clock
{
    unsigned    int hour;
    unsigned    int minute;
    unsigned    int second;
}SAClock;

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate, CPTPlotDataSource>
{
    // component
    IBOutlet    NSButton    *btnAdd_Csv;
    IBOutlet    NSButton    *btnPassPick;
    IBOutlet    NSSegmentedControl      *segBtn;
    IBOutlet    NSTableView             *tvSrcList;
    IBOutlet    NSTableView             *tvRawData;
    IBOutlet    NSTableView             *tvCfgList;
    IBOutlet    NSTableView             *tvPckList;
    
    // two views and a window
    IBOutlet    NSWindow    *optWindow;
    IBOutlet    NSView      *firstView;
    IBOutlet    NSView      *secondView;
    IBOutlet    NSProgressIndicator     *indicator;
    
    // which button has clicked
    int                 iSenderTag;
    int                 iSenderTagNoEnter;
    NSInteger           iSrcDataIndex;
        
    // coreplot
    IBOutlet    CPTGraphHostingView     *hostView;
	NSArray                 *plotData;
    
    // data src
    NSOpenPanel             *openPanel;
    NSMutableArray          *arr_fileLogsPath;
    NSMutableArray          *arr_SrcList;
    NSMutableArray          *arr_TestItems;
    NSMutableArray          *arr_LowerLimits;
    NSMutableArray          *arr_UpperLimits;
    NSMutableArray          *arr_TestValues;
    NSMutableArray          *arr_TestValuesCpy;
    NSMutableArray          *arr_ImagePath;
    NSMutableArray          *arr_Config;
    NSMutableArray          *arr_ConfigCpy;
    NSMutableArray          *arr_StationID;
    NSMutableArray          *arr_StationIDCpy;
    NSMutableArray          *arr_TestResult;
    NSMutableArray          *arr_CasePick;
    NSMutableDictionary     *dic_Config;
    NSMutableDictionary     *dic_StationID;
    NSMutableIndexSet       *idx_IndexSetKeep;
    NSMutableIndexSet       *idx_IndexSetFnl;
    NSArray                 *arrSepareted;          // raw data
    
    // other define
    NSInteger               indexoffsetX;
    NSInteger               indexoffsetY;
    
    NSString                *strLowLimit;
    NSString                *strUpLimit;
    NSString                *strItemName;
    
    NSInteger               yRange;
    double                  minScale_x;
    double                  maxScale_x;
    double                  majorticks_x;
    double                  minorticks_x;
    double                  minScale_y;
    double                  maxScale_y;
    double                  majorticks_y;
    double                  minorticks_y;
    double                  minValue_x;
    double                  maxValue_x;
    double                  dlocationoffset_low;
    double                  dlocationoffset_high;
    double                  dProcessPerformed;
    
    NSLock                  *myLock;
    
    NSTimer                 *myTimer;
    SAClock                 myClock;
    
    // feed back some information
    IBOutlet    NSTextField *stctxtTotalCount;
    IBOutlet    NSTextField *stctxtAverageValue;
    IBOutlet    NSTextField *stctxtStdeviation;
    IBOutlet    NSTextField *stctxtUplimit;
    IBOutlet    NSTextField *stctxtDownlimit;
    IBOutlet    NSTextField *stctxtFailCount;
    IBOutlet    NSTextField *stctxtFailHigh;
    IBOutlet    NSTextField *stctxtFailLow;
    IBOutlet    NSTextField *stctxtMaxValue;
    IBOutlet    NSTextField *stctxtMinValue;
    
    IBOutlet    NSTextField *txtTotalCount;
    IBOutlet    NSTextField *txtAverageValue;
    IBOutlet    NSTextField *txtStdeviation;
    IBOutlet    NSTextField *txtUplimit;
    IBOutlet    NSTextField *txtDownlimit;
    IBOutlet    NSTextField *txtFailCount;
    IBOutlet    NSTextField *txtFailHigh;
    IBOutlet    NSTextField *txtFailLow;
    IBOutlet    NSTextField *txtMaxValue;
    IBOutlet    NSTextField *txtMinValue;
    
    IBOutlet    NSTextField *txtProcess;
    IBOutlet    NSTextField *txtTimeCost;
}

@property (assign) IBOutlet NSWindow *window;

- (IBAction)choseCsvData:(id)sender;        // choose raw data from openpanel
- (IBAction)dataFilter:(id)sender;          // choose the mode to deal the data : first , last , all
- (IBAction)dataFilter2:(id)sender;         // choose the mode to deal the data : stationid, line, config

- (IBAction)dataAdd:(id)sender;
- (IBAction)dataDel:(id)sender;
- (IBAction)enterToBack:(id)sender;

- (IBAction)saveImage:(id)sender  FolderName: (NSString *)strFolderName;
- (IBAction)exportToExcel: (id)sender;
- (IBAction)autoSaveAndExport:(id)sender;
- (void)saveAllandExport;

- (NSArray   *)ascendData : (NSMutableArray  *)_marray;

- (NSMutableArray   *)getValuesFromDic :(NSInteger)index   Type: (SAGetType)type;

- (void)drawGraphics;
- (void)saveAllandExport;

- (void)runLoopRun;
- (void)timeTicks;
- (void)runThreadForThePro;
- (void)runTheMop_Up;
- (void)fillTheProAndSave   : (NSInteger)iStart :(NSInteger)iEnd;

@end
