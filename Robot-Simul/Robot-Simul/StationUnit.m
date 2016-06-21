//
//  StationUnit.m
//  Robot-Simul
//
//  Created by Eagle on 2/18/13.
//
//

#import "StationUnit.h"
#import "Optimization.h"

@implementation StationUnit

@synthesize vSingleStation;
@synthesize txteStatus;
@synthesize m_UnitName = m_strUnitName;//havi
@synthesize SCObject=m_SCObject;
@synthesize RunningMLBCount = iRunningNumber;

extern NSString *const BNRPostUpdateStatusNotification;

-(id)initWithStatus:(NSString *)szStatus andStationName:(NSString *)szStationName
{
    if (self = [super init])
    {
        [NSBundle loadNibNamed:@"StationUnit" owner:self];

        [txtsStationIndex setStringValue:[NSString stringWithFormat:@"%@",szStationName]];
        [txteStatus setBackgroundColor:[NSColor yellowColor]];
        [txteStatus setStringValue:szStatus];
        
        m_SCObject = [[StationCline alloc] init];
        nc = [NSNotificationCenter defaultCenter];
//        [nc addObserver:self selector:@selector(TestOver) name:@"RobotTestOver" object:nil];
    }
    return self;
}

-(void)dealloc
{
    [nc removeObserver:self name:BNRPostUpdateStatusNotification object:m_SCObject];
    [m_SCObject release]; m_SCObject = nil;
    [super dealloc];
}

-(IBAction)btnTriangleClick:(id)sender
{
    [panelSetting setTitle:[txtsStationIndex stringValue]];
    [panelSetting setIsVisible:YES];
}

-(IBAction)btnSetClick:(id)sender
{
    //Send value to StationClient
    [m_SCObject setCycleTime_Fail:[IBTxtFailTime stringValue]];
    [m_SCObject setCycleTime_Pass:[IBTxtPassTime stringValue]];
    [m_SCObject setStationFailRate:(float)[IBTxtFailRate floatValue]];
    [m_SCObject setStationRetestRate:(float)[IBTxtRetestRate floatValue]];
    [m_SCObject setStationTestMode:(TestMode)[[IBCobTestMode objectValues] indexOfObject:[IBCobTestMode stringValue]]];
    [self btnCancelClick:nil];
}

-(IBAction)btnCancelClick:(id)sender
{
    [IBTxtFailTime setStringValue:@""];
    [IBTxtPassTime setStringValue:@""];
    [IBTxtFailRate setStringValue:@""];
    [IBTxtRetestRate setStringValue:@""];
    [IBCobTestMode setStringValue:@"Normal"];
    [panelSetting setIsVisible:NO];
    [btnTriangle setState:NSOffState];
}

//add for update test status on UI
-(void)beginSimulTest
{
    [nc addObserver:self selector:@selector(updateStatus:) name:BNRPostUpdateStatusNotification object:m_SCObject];
}

-(void)TestOver
{
    [nc removeObserver:self name:BNRPostUpdateStatusNotification object:nil];
}

-(void)updateStatus:(NSNotification *)note
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSDictionary *dicTemp = [note userInfo];
    
    if ([[dicTemp valueForKey:@"StationName"] isEqualToString:m_strUnitName])
    {
        int istatus = [[dicTemp objectForKey:OPTIMIZATION_STATION_STATUS]intValue];
        NSString *strResult=@"";
        switch (istatus)
        {
            case Station_Empty:
                [txteStatus setBackgroundColor:[NSColor yellowColor]];
                [txteStatus setStringValue:@"Ready"];
				iRunningNumber = 0;
                break;
            case Station_Running:
                [txteStatus setBackgroundColor:[NSColor blueColor]];
                NSString *strNum = [dicTemp objectForKey:@"RunningNo"];
				iRunningNumber = [strNum intValue];
                [txteStatus setStringValue:[NSString stringWithFormat:@"%@ Testing",strNum]];
			    
                break;
            case Station_Pass:
                [txteStatus setBackgroundColor:[NSColor greenColor]];
                strResult = [dicTemp objectForKey:@"Result"];
				iRunningNumber = 0;
                [txteStatus setStringValue:strResult];
                break;
            case Station_Fail:
                [txteStatus setBackgroundColor:[NSColor redColor]];
                strResult = [dicTemp objectForKey:@"Result"];
                [txteStatus setStringValue:strResult];
				iRunningNumber = 0;
                break;
            default:
                break;
        }
    }
    [pool release];
}
//



@end
