//
//  CoreFunction.h
//  FireTestCoverage
//
//  Created by raniys on 11/13/14.
//  Copyright (c) 2014 raniys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CoreFunction : NSObject
{
    NSMutableArray      *m_aryAllData;
    NSDictionary        *m_dicStationStatus;
    NSString            *m_Version;
    
    NSInteger           iCurrentItem;
    NSInteger           iAllCount;
    NSLevelIndicator    *m_lineProgress;
    NSTextField         *m_textProgress;
}

@property (nonatomic, retain) NSLevelIndicator  *lineProgress;
@property (nonatomic, retain) NSTextField   *textProgress;

-(NSArray *)loadDataFromPlistFile:(NSString *)path;
-(id)loadDataFromTxtFile:(NSString *)path;
-(void)writeData: (NSMutableArray *)data
       ToTxtFile: (NSURL *)url
      unitStatus:(id)checkUnitButton
   fixtureStatus:(id)checkFixtureButton;
-(void)writeData:(NSMutableArray *)data
     ToExcelFile:(NSURL *)url
      unitStatus:(id)checkUnitButton
   fixtureStatus:(id)checkFixtureButton
    testCoverageStatus:(id)checkTestCoverageButton
   stationStatus:(NSString *)status;
-(NSNumber *)updateUartData:(NSArray *)arrData
             toTestCoverage:(NSString *)excelPath
         withSpecialSetting:(NSDictionary *)dicSetting;
-(void)runProgress;
@end
