//
//  SingleStation.m
//  Robot-Simul
//
//  Created by Eagle on 2/17/13.
//
//

#import "SingleStation.h"

extern int G_SPEED;

@implementation SingleStation

@synthesize vStationType;
//@synthesize IBBtnOK;
@synthesize IBBtnSet;
@synthesize IBTxtInputCount;
@synthesize IBTxtPassCount;
@synthesize IBTxtFailCount;
@synthesize IBTxtFirstFail;
@synthesize IBTxtSecondFail;
@synthesize IBTxtFailRate;
@synthesize IBTxtFailTestTime;
@synthesize IBCobRetestRule;
@synthesize IBTxtPassTestTime;
@synthesize IBTxtRetestRate;
@synthesize StationName = m_szStationName;
@synthesize MtaryStationUnits = m_mtaryStationUnits;
@synthesize RunningMLBNumber = m_iRunningMLBNumber;
@synthesize RunningNumber = m_iRunningNumber;
@synthesize stationUnitNumber = m_iUnitNumber;//havi

-(id)init
{
    if (self = [super init]) 
    {
        [NSBundle loadNibNamed:@"SingleStation" owner:self];
        m_mtaryStationUnits = [[NSMutableArray alloc] init];
    
        m_iUnitNumber = DEFAULT_STATION_UNIT_COUNT;
        [IBTxtInputCount setStringValue:@"0"];
        [IBTxtPassCount setStringValue:@"0"];
        [IBTxtFailCount setStringValue:@"0"];
        [IBTxtFirstFail setStringValue:@"0"];
        [IBTxtSecondFail setStringValue:@"0"];
        [IBTxtFNRunningCount setStringValue:@"0"];
        [IBTxtFailCount setEditable:NO];
        [IBTxtInputCount setEditable:NO];
        [IBTxtPassCount setEditable:NO];
        [IBTxtFirstFail setEditable:NO];
        [IBTxtSecondFail setEditable:NO];
        [IBTxtFUnitsCount setEditable:NO];
        m_iRunningNumber = 0;
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(updateRunningCount) name:@"UpdateRunningCount" object:nil];
    }
    return self;
}
-(void)initWithStationNum:(NSInteger)num
{
    [IBTxtFUnitsCount setIntValue:(int)num];
}
-(void)dealloc
{
    [m_mtaryStationUnits release]; m_mtaryStationUnits = nil;
    [m_szStationName release]; m_szStationName = nil;
   // [robot_station release];
    [super dealloc];
}

//-(IBAction)btnStationCountSetOK:(id)sender
//{
//    NSInteger iActualCount = [[IBTxtFUnitsCount stringValue] intValue];
//    if (iActualCount <= 0) 
//    {
//        NSRunAlertPanel(@"Warning", @"Please set correct station unit count ,count should be larger than 0!", @"OK", nil, nil);
//        return;
//    }
//    
//    [IBPanelMatrix setIsVisible:YES];
//}

-(IBAction)btnSetOk:(id)sender
{
    for (StationUnit *stationUnit in m_mtaryStationUnits) 
    {
        //Send value to StationClient
//        [stationUnit.SCObject setStationRetestRule:(RetestRule)[[IBCobRetestRule objectValues] indexOfObject:[IBCobRetestRule stringValue]]];
        [stationUnit.SCObject setCycleTime_Fail:[IBTxtFailTestTime stringValue]];
        [stationUnit.SCObject setCycleTime_Pass:[IBTxtPassTestTime stringValue]];
        [stationUnit.SCObject setStationFailRate:(float)[IBTxtFailRate floatValue]];
        [stationUnit.SCObject setStationRetestRate:(float)[IBTxtRetestRate floatValue]];
        [stationUnit.SCObject setStationTestMode:(TestMode)[[IBCobTestMode objectValues] indexOfObject:[IBCobTestMode stringValue]]]; 

    }
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"UpdateRetestRule" object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:m_szStationName,@"StationName",[IBCobRetestRule stringValue],@"RetestRule", nil]];
    
}

-(IBAction)btnMatrixSet:(id)sender
{
    NSInteger iRow = [IBTxtRow intValue];
    NSInteger iColumn = [IBTxtColumn intValue]+1;
    NSInteger iTotal = m_iUnitNumber;//[IBTxtFUnitsCount intValue];
    if (iRow*(iColumn+1) < iTotal ) 
    {
        NSRunAlertPanel(@"Warning", @"Make sure the Matrix you set is matched with the total number!", @"OK", nil, nil);
    }
    else
    {
        m_iUnitNumber = (int)iTotal;
        NSArray *arySubViews = [vStationType subviews];
        for(id subView in arySubViews)
        {
            if([subView isKindOfClass:[NSScrollView class]])
            {
                [self loadUnitsWithRow:(int)iRow Column:(int)iColumn total:(int)iTotal withContainer:subView];
                break;
            }
        }
    }
    [IBPanelMatrix setIsVisible:NO];
}

-(void)loadUnitsWithRow:(int)iRow Column:(int)iColumn total:(int)iTotal withContainer:(NSScrollView *)view
{
    NSArray *arySubContainers = [[view contentView] subviews];
    for(NSInteger iIndex=0; iIndex<[arySubContainers count]; iIndex++)
    {
        [[arySubContainers objectAtIndex:iIndex] removeFromSuperview];
    }
    
    StationUnit *stationUnit = [[StationUnit alloc]initWithStatus:@"Ready" andStationName:@"Test"];
    CGFloat fWidth = [stationUnit.vSingleStation frame].size.width;
    CGFloat fHeight = [stationUnit.vSingleStation frame].size.height;
    [stationUnit release];
    
    NSClipView *clipView = [[NSClipView alloc] init];
    
    CGFloat fParentHeight = [view frame].size.height;
    CGFloat fCustomWidth = iColumn * (fWidth+5);
    //CGFloat fCustomHeight= iRow *(fHeight+5);
#define ViewRightMargin 20
#define ViewBottomMargin 20
    NSView *customView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, fCustomWidth+ViewRightMargin, fParentHeight+ViewBottomMargin)];
    
    
    NSInteger iUnitIndex=0;
    for (NSInteger iColumnIndex=0; iColumnIndex<iColumn; iColumnIndex++) 
    {
        for (NSInteger iRowIndex=0; iRowIndex<iRow; iRowIndex++) 
        {
            CGFloat fPointX = 5+(fWidth+5)*iColumnIndex;
            CGFloat fPointY = fParentHeight-(5+(fHeight+5)*(iRowIndex+1))+ViewBottomMargin;
            
            StationUnit *unit = [m_mtaryStationUnits objectAtIndex:iUnitIndex];;
           
            [unit.vSingleStation setFrame:NSMakeRect(fPointX, fPointY, fWidth, fHeight)];
            [customView addSubview:unit.vSingleStation];
            
            iUnitIndex++;
            if (iUnitIndex == iTotal) 
            {
                iColumnIndex = iColumn;
                break;
            }
        }
    }
    [clipView setDocumentView:customView];
    [view setContentView:clipView];
    [customView release];
    [clipView release];
}

-(void)loadStationUnits:(NSInteger)iUnitNumber withStationName:(NSArray *)stationName
{
    NSRect rect = [self.vStationType frame];
    CGFloat fParentWidth = rect.size.width;
    CGFloat fParentHeight = rect.size.height;
    
    NSScroller *scrollerHorizen = [[NSScroller alloc] initWithFrame:NSMakeRect(0, 0, 20, 15)];
    NSScroller *scrollerVertical = [[NSScroller alloc] initWithFrame:NSMakeRect(0, 0, 15, 20)];
    
    NSScrollView *sc = [[NSScrollView alloc] initWithFrame:NSMakeRect(240, 10, fParentWidth - 240, fParentHeight)];
    [sc setHasHorizontalScroller:YES];
    [sc setHasVerticalScroller:YES];
    [sc setHorizontalScroller:scrollerHorizen];
    [sc setVerticalScroller:scrollerVertical];
    
    int iRow = 4, iColumn = 3;
    iRow = (int)iUnitNumber/iColumn;
    if (iUnitNumber % iColumn != 0)
    {
        iRow = iRow+1;
    }
    [self loadUnitsWithRow:iRow Column:iColumn total:(int)iUnitNumber withContainer:sc];
    [sc setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable | NSViewMaxXMargin | NSViewMaxYMargin | NSViewMinXMargin | NSViewMinYMargin];
    [self.vStationType addSubview:sc];
    [sc release];
    [scrollerHorizen release];
    [scrollerVertical release];
}

//begin Simul test
-(void)beginSimulTest
{
    for (StationUnit *stationUnit in m_mtaryStationUnits) 
    {
        [stationUnit beginSimulTest];
    }
   
}

-(void)updateRunningCount
{

    int iRunningCount = 0;
    m_iRunningMLBNumber =0;
    for (StationUnit *stationUnit in m_mtaryStationUnits)
    {
        if ([[stationUnit.txteStatus backgroundColor] isEqual:[NSColor blueColor]])
        {
            iRunningCount++;
            m_iRunningMLBNumber += stationUnit.RunningMLBCount;
        }
    }
    @synchronized(m_iRunningNumber)
    {
        [IBTxtFNRunningCount setIntValue:iRunningCount];
        m_iRunningNumber = [NSNumber numberWithInt:iRunningCount];
    }

}
//
@end
