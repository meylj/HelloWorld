//
//  Robot_SimulAppDelegate.m
//  Robot-Simul
//
//  Created by Eagle on 1/26/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "Robot_SimulAppDelegate.h"
#import "StationCline.h"
#import "SingleStation.h"
#import "StationUnit.h"
#import "normaldefine.h"
@implementation Robot_SimulAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [txtStatusFail setBackgroundColor:[NSColor redColor]];
    [txtStatusPass setBackgroundColor:[NSColor greenColor]];
    [txtStatusReady setBackgroundColor:[NSColor yellowColor]];
    [txtStatusTesting setBackgroundColor:[NSColor blueColor]];
    m_mtaryStations = [[NSMutableArray alloc] init];
    m_aryStationName=[[NSMutableArray alloc]init];
    m_mtarySingleStations = [[NSMutableArray alloc] init];
    m_dicSaveSetting=[[NSMutableDictionary alloc]init];//havi,for save;
    m_dicSetting = [[NSMutableDictionary alloc]init];
    m_RSObject = [[RobotServer alloc] initServer];
    [self setTheOriginalCoordinate:@"Setting"];
    bLock = NO;
  }
- (id)init
{
    self = [super init];
    if (self)
    {
		m_aryConfigation=[[NSMutableArray alloc]init];
        nv = [NSNotificationCenter defaultCenter];
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *strDirectory = [RobotRunningLog stringByDeletingLastPathComponent];
        if ([fm fileExistsAtPath:strDirectory])
        {
            [fm removeItemAtPath:strDirectory error:nil];
        }
        [nv addObserver:self selector:@selector(writeToCsv:) name:@"WriteCsv" object:nil];
        [nv addObserver:self selector:@selector(TestOver) name:@"RobotTestOver" object:nil];

    }
    return self;
}
//to parese the Plist for the setting,havi
-(void)setTheOriginalCoordinate:(NSString *)strCsvName
{
    NSString *strPathName=[[NSBundle mainBundle]pathForResource:strCsvName ofType:@"plist"];
    m_dicSetting = [[NSMutableDictionary dictionaryWithContentsOfFile:strPathName]retain];
    
    [IBTxtRobotCoordinate setStringValue:[m_dicSetting objectForKey:kRobotCoordinate]];
    [IBTxtFailAreaCoordinate setStringValue:[m_dicSetting objectForKey:kFailAreaCoordinate]];
    [IBTxtFSpeed setStringValue:[m_dicSetting objectForKey:kIBTxtFSpeed]];
    [IBTxtPassAreaCoordinate setStringValue:[m_dicSetting objectForKey:kPassAreaCoordinate]];
    [IBTxtUntestAreaCoordinate setStringValue:[m_dicSetting objectForKey:kUntestAreaCoordinate]];
    [IBTxtRobotMoveSpeed setStringValue:[m_dicSetting objectForKey:kRobotMoveSpeed]];
	[IBTestEndTime setStringValue:[m_dicSetting objectForKey:kEndTestTime]];
    [IBTxtUnitSlotNum setStringValue:[m_dicSetting objectForKey:kStationUnitNumber]];
    [IBTxtRobotPicker setStringValue:[m_dicSetting objectForKey:kRobotPickerNumber]];
    [IBtxtInputUnitNumber setStringValue:[m_dicSetting objectForKey:kInputUnitNumber]];
    
    NSDictionary *dicTemp ;
    
    NSUInteger icount = [[m_dicSetting objectForKey:kStationSetting]count];
    for (int i = 0; i < icount; i++)
    {
        NSArray *aryKey = [[[m_dicSetting objectForKey:kStationSetting]objectAtIndex:i]allKeys];
        dicTemp =[[[[m_dicSetting objectForKey:kStationSetting]objectAtIndex:i]objectForKey:[aryKey objectAtIndex:0]]objectForKey:kFailCoordinate];
        [m_RSObject.aryFirstFailPositions addObject:[dicTemp objectForKey:kFirstFailCoordinate]];
        [m_RSObject.arySecondFailPositions addObject:[dicTemp objectForKey:kSecondFailCoordinate]];
        [m_RSObject.aryPassPositions addObject:[dicTemp objectForKey:kPassCoordinate]];
    }

    m_mtaryStations = [m_dicSetting objectForKey:kStationSetting];

}
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

-(void)dealloc
{
    [m_mtaryStations release]; m_mtaryStations=nil;
    [m_mtarySingleStations release]; m_mtarySingleStations=nil;
    [m_RSObject release]; m_RSObject=nil;
    [m_dicSaveSetting release]; m_dicSaveSetting = nil;
    [m_dicSetting release];
	[m_aryConfigation release];
	[nv removeObserver:self name:@"WriteCsv" object:nil];
	[nv removeObserver:self name:@"WriteInputLog" object:nil];
    [super dealloc];
}


-(IBAction)btnSet:(id)sender
{
    G_SPEED = (int)[IBTxtFSpeed intValue];
    [m_RSObject setRobotLocation:[IBTxtRobotCoordinate stringValue]];
    [m_RSObject setFailAreaLocation:[IBTxtFailAreaCoordinate stringValue]];
    [m_RSObject setUntestAreaLocation:[IBTxtUntestAreaCoordinate stringValue]];
    [m_RSObject setMoveSpeed:[IBTxtRobotMoveSpeed floatValue]];
    [m_RSObject setInputUnitNumber:[IBtxtInputUnitNumber intValue]];
    m_RSObject.PickerNumber = [IBTxtRobotPicker intValue];
    m_RSObject.SlotNumber = [IBTxtUnitSlotNum intValue];
    [self saveTheSettingChange:@"Setting"];//add to save the change havi
    NSRect rectTab = [tbvStations frame];
    CGFloat wSize = rectTab.size.width;
    CGFloat hSize = rectTab.size.height;
    
    [m_mtarySingleStations removeAllObjects];
	//write log

	NSString * m_startTime = [[NSDate date] descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M:%S:%F " timeZone:nil locale:nil];
	[LogManager creatAndWriteUnitTestedCount:[NSString stringWithFormat:@"%@,%@,%@,%@ \n",@"TestStaiton",@"Coordinate",@"CycleCount",m_startTime] withPath:UnitRunningCountLog];
	//end

    NSInteger iStationCount = [m_mtaryStations count];
    
    for (NSInteger i=0; i<iStationCount; i++)
    {
        NSDictionary *dicTemp = [m_mtaryStations objectAtIndex:i];
        NSArray *aryKeys = [dicTemp allKeys];
        NSString *szStationType = [aryKeys objectAtIndex:0];
        NSDictionary *dicStation = [dicTemp objectForKey:szStationType];
        NSDictionary *dicStationCoordinate = [dicStation objectForKey:kStationCoordinate];

         NSTabViewItem *tbvSingleItem = [[NSTabViewItem alloc] init];
        [tbvSingleItem setLabel:szStationType];

        SingleStation *singleStation = [[SingleStation alloc] init];//not release
        
        [self setUnitCoordinate:szStationType OfStation:singleStation ofCoordinate:dicStationCoordinate];//havi
        
        [singleStation initWithStationNum:m_stationCount];//havi
        singleStation.stationUnitNumber=m_stationCount;//havi
        [singleStation.vStationType setFrame:NSMakeRect(0, 0, wSize, hSize-45)];
        [[tbvSingleItem view] setAutoresizesSubviews:NO];//important, won't allow to resize sub views
        [singleStation loadStationUnits:m_stationCount withStationName:m_aryStationName];//havi,modify the unit number;
        [[tbvSingleItem view] addSubview:singleStation.vStationType];
        [singleStation setStationName:szStationType];
        [m_mtarySingleStations addObject:singleStation];
        [singleStation.IBTxtPassTestTime setStringValue:[dicStation objectForKey:kStationPassTime]];
        [singleStation.IBTxtFailTestTime setStringValue:[dicStation objectForKey:kStationFailTime]];
        [singleStation.IBTxtFailRate setStringValue:[dicStation objectForKey:kStationFailRate]];
        [singleStation.IBTxtRetestRate setStringValue:[dicStation objectForKey:kStationRetestRate]];
        [singleStation.IBCobRetestRule setStringValue:[dicStation objectForKey:kStationRetestRule]];
        [singleStation release];
        
        [tbvStations addTabViewItem:tbvSingleItem];
        [tbvSingleItem release];
        [m_RSObject.aryStationNames addObject:szStationType];
        [m_RSObject.aryRetestRule addObject:[dicStation objectForKey:kStationRetestRule]];
    }
	//write log new thread,to write the configation csv
	[NSThread detachNewThreadSelector:@selector(writeLog) toTarget:self withObject:nil];

	if (![m_strSettingTime isEqualToString:@"NO"])
	{

		NSRange range=[m_strSettingTime rangeOfString:@":"];
		if (range.location==NSNotFound)
        {
			NSRunAlertPanel(@"警告(Warning)",@"请在EndTime框中输入以下格式：\r hour:minute:second", @"确认(OK)", nil, nil);
			[NSApp terminate:self];
		}
	}
    
	[window close];
	[winMain setIsVisible:YES];
}
//save the setting change havi
-(void)saveTheSettingChange:(NSString *)strCsvName
{
	[m_dicSaveSetting setObject:[IBTxtRobotCoordinate stringValue] forKey:kRobotCoordinate];
	[m_dicSaveSetting setObject:[IBTxtFSpeed stringValue] forKey:kIBTxtFSpeed];
	[m_dicSaveSetting setObject:[IBTxtPassAreaCoordinate stringValue] forKey:kPassAreaCoordinate];
	[m_dicSaveSetting setObject:[IBTxtFailAreaCoordinate stringValue] forKey:kFailAreaCoordinate];
    [m_dicSaveSetting setObject:[IBTxtUntestAreaCoordinate stringValue] forKey:kUntestAreaCoordinate];
    [m_dicSaveSetting setObject:[IBTxtRobotMoveSpeed stringValue] forKey:kRobotMoveSpeed];
	[m_dicSaveSetting setObject:[IBTestEndTime stringValue] forKey:kEndTestTime];
    [m_dicSaveSetting setObject:[IBTxtRobotPicker stringValue] forKey:kRobotPickerNumber];
    [m_dicSaveSetting setObject:[IBTxtUnitSlotNum stringValue] forKey:kStationUnitNumber];
    [m_dicSaveSetting setObject:[IBtxtInputUnitNumber stringValue] forKey:kInputUnitNumber];
    
    [m_dicSaveSetting setObject:[m_dicSetting objectForKey:kStationSetting] forKey:kStationSetting];
    NSString *strSavePathName = [[NSBundle mainBundle]pathForResource:strCsvName ofType:@"plist"];
    [m_dicSaveSetting writeToFile:strSavePathName atomically:NO];
	m_strSettingTime=[m_dicSaveSetting objectForKey:kEndTestTime];
  
}

/*这个函数是读取csv文件*///havi
- (void)setUnitCoordinate:(NSString *)szStationType OfStation:(SingleStation *)station ofCoordinate:(NSDictionary *)dicStationCoordinate //havi
{
    [m_aryStationName removeAllObjects];
  

    NSArray *arrCoordinates=[dicStationCoordinate allKeys];
	[m_aryConfigation addObject:arrCoordinates];
		
    m_stationCount=[arrCoordinates count];//havi

	NSMutableDictionary *dicTemp = [[NSMutableDictionary alloc]init];
 
    for (int i=0; i<[arrCoordinates count]; i++)
    {
        NSString *strTemp=[dicStationCoordinate objectForKey:[arrCoordinates objectAtIndex:i]];
      
        NSArray *arrCoordinates_X_Y_Z=[strTemp componentsSeparatedByString:@":"];
        
        CGFloat fPointX = [[arrCoordinates_X_Y_Z objectAtIndex:0] floatValue];
        CGFloat fPointY = [[arrCoordinates_X_Y_Z objectAtIndex:1] floatValue];
        CGFloat fPointZ = [[arrCoordinates_X_Y_Z objectAtIndex:2] floatValue];
        Station_Position unitPosition = {fPointX,fPointY,fPointZ};
        //Send value to StationClient
        [m_aryStationName addObject:[arrCoordinates objectAtIndex:i]];
        
        StationUnit *unit = [[StationUnit alloc]initWithStatus:@"Ready" andStationName:[arrCoordinates objectAtIndex:i]];
        [unit.SCObject setStationPosition:unitPosition];
        unit.m_UnitName = [arrCoordinates objectAtIndex:i];
        [unit.SCObject setStationName:[arrCoordinates objectAtIndex:i]];
        unit.SCObject.SlotNumber = [IBTxtUnitSlotNum intValue];
        [station.MtaryStationUnits addObject:unit];
//WRITE THE  log
	     NSString * m_startTime = [[NSDate date] descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M:%S:%F " timeZone:nil locale:nil];
		[LogManager creatAndWriteUnitTestedCount:[NSString stringWithFormat:@"%@,%@,%d,%@\n",[arrCoordinates objectAtIndex:i],strTemp,0,m_startTime] withPath:UnitRunningCountLog];
        [dicTemp setObject:unit.SCObject forKey:[arrCoordinates objectAtIndex:i]];
         [unit release];
      
    }
    [m_RSObject.aryAvailableStations addObject:dicTemp];

	[dicTemp release];
}

//write log
- (void)writeLog
{
	NSDictionary *dicCoor = m_dicSaveSetting;

	NSDictionary *dicRobot = [NSDictionary dictionaryWithObject:[[dicCoor objectForKey:@"RobotCoordinate"]stringByReplacingOccurrencesOfString:@"," withString:@":"] forKey:@"RobotCoordinate"];
	NSDictionary *dicInput = [NSDictionary dictionaryWithObject:[[dicCoor objectForKey:@"UntestAreaCoordinate"]stringByReplacingOccurrencesOfString:@"," withString:@":"] forKey:@"InputCoordinate"];
	NSDictionary *dicNoGood = [NSDictionary dictionaryWithObject:[[dicCoor objectForKey:@"FailAreaCoordinate"]stringByReplacingOccurrencesOfString:@"," withString:@":"] forKey:@"NoGoodCoordinate"];
	NSDictionary *dicPassArea = [NSDictionary dictionaryWithObject:[[dicCoor objectForKey:@"PassAreaCoordinate"]stringByReplacingOccurrencesOfString:@"," withString:@":"] forKey:@"PassCoordinate"];
	
	NSArray *dicArray = [dicCoor objectForKey:@"StationSetting"];
	//write table 1:robot to input distance

	NSMutableArray *aryCoordinateStation = [[[NSMutableArray alloc]init]autorelease];
	for (int i=0; i<[dicArray count]; i++) {
		NSDictionary *dicStation = [dicArray objectAtIndex:i];
		NSArray *aryKeys = [dicStation allKeys];
		NSDictionary *dicStationCoordinate = [dicStation objectForKey:[aryKeys objectAtIndex:0]];
		NSDictionary *dicSingleStationCoor = [dicStationCoordinate objectForKey:@"StationCoordinate"];
		[aryCoordinateStation addObject:dicSingleStationCoor];
	}
	[LogManager creatAndWriteTestConfiguration:m_dicSaveSetting withStaion:dicArray andPath:kTestConfigurationLog];
	[LogManager writeTheDistanceTableStart:dicRobot andRow:dicInput withPath:kTestConfigurationLog];

	for (int i=0; i<[aryCoordinateStation count]; i++)
    {
		NSDictionary *dicSingleStationCoor = [aryCoordinateStation objectAtIndex:i];
		if (i==0)
        {	//write table 2:input to test distance

			[LogManager writeTheDistanceTableStart:dicInput andRow:dicSingleStationCoor withPath:kTestConfigurationLog];

		}
		[LogManager writeTheDistanceTableStart:dicSingleStationCoor andRow:dicSingleStationCoor withPath:kTestConfigurationLog];

		[LogManager writeTheDistanceTableStart:dicNoGood andRow:dicSingleStationCoor withPath:kTestConfigurationLog];

		[LogManager writeTheDistanceTableStart:dicPassArea andRow:dicSingleStationCoor withPath:kTestConfigurationLog];
		
	}

}
/****************************/
-(IBAction)btnEnd:(id)sender
{
    [NSApp terminate:self];
}

//Start Simulation
-(IBAction)btnStart:(id)sender
{
   for (SingleStation *singleStation in m_mtarySingleStations) 
    {
        
        [singleStation beginSimulTest];
        [singleStation btnSetOk:nil];
        [singleStation.IBBtnSet setEnabled:NO];
//        [singleStation.IBBtnOK setEnabled:NO];
        [singleStation.IBTxtFailCount setStringValue:@"0"];
        [singleStation.IBTxtFirstFail setStringValue:@"0"];
        [singleStation.IBTxtInputCount setStringValue:@"0"];
        [singleStation.IBTxtPassCount setStringValue:@"0"];
        [singleStation.IBTxtSecondFail setStringValue:@"0"];
    }
    
    NSString *strStationUsage = @"Time,Robot Serving Station";
    
    NSString *strInfo=@"Time";
    for (int i = 0; i < [m_RSObject.aryStationNames count]; i++)
    {
        if (i != 0)
        {
            strInfo = [NSString stringWithFormat:@"%@,",strInfo];
        }
        NSString *strStationName = [m_RSObject.aryStationNames objectAtIndex:i];
        NSString *strInputCount = [NSString stringWithFormat:@"%@ Input Count",strStationName];
        NSString *strPassCount = [NSString stringWithFormat:@"%@ Pass Count",strStationName];
        NSString *strFailCount = [NSString stringWithFormat:@"%@ Fail Count", strStationName];
        NSString *strFirstFailCount = [NSString stringWithFormat:@"%@ First Fail Count",strStationName];
        NSString *strSecondFailCount = [NSString stringWithFormat:@"%@ Second Fail Count",strStationName];
        NSString *strRunningCount = [NSString stringWithFormat:@"%@ Running Count",strStationName];
        strInfo = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@",strInfo,strInputCount,strPassCount,strFailCount,strFirstFailCount,strSecondFailCount,strRunningCount];
        
        NSString *strRunningStations = [NSString stringWithFormat:@"%@ Running Stations",strStationName];
        strStationUsage = [NSString stringWithFormat:@"%@,%@,%@",strStationUsage,strRunningStations,strRunningCount];
    }
    strStationUsage = [NSString stringWithFormat:@"%@,Total Running Stations,Running / Total Station\n",strStationUsage];
    strInfo = [NSString stringWithFormat:@"%@\n",strInfo];
    [LogManager creatAndWriteResultInfo:strInfo withPath:InputStatusLog];
    [LogManager creatAndWriteResultInfo:strStationUsage withPath:StationRunningDetailLog];

  
    [btnStart setEnabled:NO];
    bLock = NO;
    
	if (![m_strSettingTime isEqualToString:@"NO"])
    {
		NSArray *time=[m_strSettingTime componentsSeparatedByString:@":"];
		int itime=[[time objectAtIndex:0]intValue]*3600+[[time objectAtIndex:1]intValue]*60+[[time objectAtIndex:2]intValue];
		[NSTimer scheduledTimerWithTimeInterval:itime target:self selector:@selector(endTest) userInfo:nil repeats:NO];
	}
    [m_RSObject startRobotServer]; // torres for try run
    [NSThread detachNewThreadSelector:@selector(updateTotalRunningCount) toTarget:self withObject:nil];
   
}

- (void)endTest
{
	[NSApp terminate:self];
}
-(void)updateTotalRunningCount
{
    while (!bLock)
    {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        int iRunningCount = 0;
        int iTotalCount = 0;
        float runningRate = 0.0;
        
        for (int i = 0; i < [m_mtarySingleStations count]; i++)
        {
            SingleStation *objSingleStaiton = [m_mtarySingleStations objectAtIndex:i];
            iRunningCount += [objSingleStaiton.RunningNumber intValue];
            iTotalCount += objSingleStaiton.stationUnitNumber;
            int iInputCount = [[m_RSObject.aryInputMLBCount objectAtIndex:i]intValue];
            int iPassCount = [[m_RSObject.aryPassCount objectAtIndex:i]intValue];
            int iFailCount = [[m_RSObject.aryFailCount objectAtIndex:i]intValue];
            int iFirstFailCount = [[m_RSObject.aryFirstFailCount objectAtIndex:i]intValue];
            int iSecondFailCount = [[m_RSObject.arySecondFailCount objectAtIndex:i]intValue];
            [objSingleStaiton.IBTxtInputCount setStringValue:[NSString stringWithFormat:@"%d",iInputCount]];
            [objSingleStaiton.IBTxtPassCount setStringValue:[NSString stringWithFormat:@"%d",iPassCount]];
            [objSingleStaiton.IBTxtFailCount setStringValue:[NSString stringWithFormat:@"%d",iFailCount]];
            [objSingleStaiton.IBTxtFirstFail setStringValue:[NSString stringWithFormat:@"%d",iFirstFailCount]];
            [objSingleStaiton.IBTxtSecondFail setStringValue:[NSString stringWithFormat:@"%d",iSecondFailCount]];
        }
        
        runningRate = (float)iRunningCount/(float)iTotalCount;
        [txtneStationEfficiency setStringValue:[NSString stringWithFormat:@"%d/%d/%.2f",iRunningCount,iTotalCount,runningRate*100]];
        [pool drain];
        //sleep 5s normally
        int iSleepTime = 5 * G_SPEED*1000;
        usleep(iSleepTime);
    }
}

-(void)writeToCsv:(NSNotification *)usInfo
{
    NSDictionary *dicInfo = [usInfo userInfo];
    
	NSString * m_startTime = [[NSDate date] descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M:%S:%F" timeZone:nil locale:nil];
    
    NSString *strStationName = [dicInfo objectForKey:@"stationName"];
    NSString *strStationUsage = [NSString stringWithFormat:@"%@,%@",m_startTime,strStationName];

    NSString *strResultInfo = [NSString stringWithFormat:@"%@",m_startTime];
    NSInteger iRunningTotal = 0;
    NSInteger iTotal = 0;
    
    for (int i = 0 ; i < [m_mtarySingleStations count]; i++)
    {
        if (i != 0)
        {
            strResultInfo = [NSString stringWithFormat:@"%@,",strResultInfo];
        }
        SingleStation *objStation = [m_mtarySingleStations objectAtIndex:i];
        int iRunning = objStation.RunningMLBNumber;
        int iInput = [[m_RSObject.aryInputMLBCount objectAtIndex:i]intValue];
        int iPass = [[m_RSObject.aryPassCount objectAtIndex:i]intValue];
        int iFail = [[m_RSObject.aryFailCount objectAtIndex:i]intValue];
        int iFirstFail = [[m_RSObject.aryFirstFailCount objectAtIndex:i]intValue];
        int iSecondFail = [[m_RSObject.arySecondFailCount objectAtIndex:i]intValue];
        strResultInfo = [NSString stringWithFormat:@"%@,%d,%d,%d,%d,%d,%d",strResultInfo,iInput,iPass,iFail,iFirstFail,iSecondFail,iRunning];
        
        
        NSArray *arrAllKeys = [[[[[m_dicSaveSetting objectForKey:kStationSetting]objectAtIndex:i]objectForKey:[m_RSObject.aryStationNames objectAtIndex:i]]objectForKey:kStationCoordinate]allKeys];
        NSInteger iUnits = [arrAllKeys count];
        NSInteger iRunningUnits = iUnits - [[m_RSObject.aryAvailableStations objectAtIndex:i]count];
        
        NSArray *arrUnTestStation=[[m_RSObject.aryAvailableStations objectAtIndex:i]allKeys];
        
                
        NSPredicate *thePredicate = [NSPredicate predicateWithFormat:@"NOT(SELF IN %@)",arrUnTestStation];
        NSArray *arrUsingStation = [arrAllKeys filteredArrayUsingPredicate:thePredicate];
        
        NSString *strUsingStations = [arrUsingStation componentsJoinedByString:@";"];
        strStationUsage = [NSString stringWithFormat:@"%@,%@,%ld",strStationUsage,strUsingStations,iRunningUnits];
        iTotal += iUnits;
        iRunningTotal += iRunningUnits;
    }
    strResultInfo= [NSString stringWithFormat:@"%@\n",strResultInfo];
    [LogManager creatAndWriteResultInfo:strResultInfo withPath:InputStatusLog];
    float fPercentage = (float)iRunningTotal/iTotal;
    strStationUsage = [NSString stringWithFormat:@"%@,%ld,%f\n",strStationUsage,iRunningTotal,fPercentage];
    [LogManager creatAndWriteResultInfo:strStationUsage withPath:StationRunningDetailLog];
}

- (void)TestOver
{
    bLock = YES;
    [btnStart setEnabled:YES];
    
}


@end
