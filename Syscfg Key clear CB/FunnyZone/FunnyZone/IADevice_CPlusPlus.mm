//
//  TestProgress+IADevice_CPlusPlus.m
//  FunnyZone
//
//  Created by raniys on 3/19/15.
//  Copyright (c) 2015 PEGATRON. All rights reserved.
//

#import "IADevice_CPlusPlus.h"
#include <iostream>
#include <vector>
#include <CppOrbPost/CppOrbPost.h>
#include "IADevice_Other.h"


@implementation TestProgress (IADevice_CPlusPlus)

/*
 Add by raniys on 3/19/2015
 Description:    Add for ORB data calculate
 Param:
 KEY1             -> string1
 KEY1             -> string2
 OPERATOR         -> the value should be "AND"/"OR"/"XOR"
 MEMORYKEY        -> Memory key
 szReturnValue    -> Caculate result
 */
- (NSNumber *)CALCULATE_ORB_DATA:(NSDictionary *)dicPara
                    RETURN_VALUE:(NSMutableString *)szReturnValue
{
    BOOL bReturn    = YES;
    //Memory keys
    NSDictionary    *dicMemoryKeys  = [dicPara objectForKey:@"MEMORY_KEYS"];
    NSString    *strBaselineGap1    = [dicMemoryKeys objectForKey:@"BASELINEGAP1"];
    NSString    *strBaselineGap2    = [dicMemoryKeys objectForKey:@"BASELINEGAP2"];
    NSString    *strForceGap1       = [dicMemoryKeys objectForKey:@"FORCEGAP1"];
    NSString    *strForceGap2       = [dicMemoryKeys objectForKey:@"FORCEGAP2"];
    NSString    *strDeflection1     = [dicMemoryKeys objectForKey:@"DEFLECTION1"];
    NSString    *strDeflection2     = [dicMemoryKeys objectForKey:@"DEFLECTION2"];
    //Get gap datas
    NSString    *strBaselineData1   = [m_dicMemoryValues objectForKey:[dicPara objectForKey:@"BASELINE_DATA1"]];
    NSString    *strBaselineData2   = [m_dicMemoryValues objectForKey:[dicPara objectForKey:@"BASELINE_DATA2"]];
    NSString    *strForceData1      = [m_dicMemoryValues objectForKey:[dicPara objectForKey:@"FORCE_DATA1"]];
    NSString    *strForceData2      = [m_dicMemoryValues objectForKey:[dicPara objectForKey:@"FORCE_DATA2"]];
    NSString    *strBaselineData    = [NSString stringWithFormat:@"%@%@",strBaselineData1,strBaselineData2];
    NSString    *strForceData       = [NSString stringWithFormat:@"%@%@",strForceData1,strForceData2];
    
    int iFrames     = [[dicPara objectForKey:@"FRAMES"]intValue];
    
    //set single file path
    NSString    *strGapFilePath         = [NSString stringWithFormat:@"%@/%@_%@/orb_gap.txt",kPD_LogPath,m_szPortIndex,m_szStartTime];
    NSString    *strDeflectionFilePath  = [NSString stringWithFormat:@"%@/%@_%@/orb_deflection.txt",kPD_LogPath,m_szPortIndex,m_szStartTime];
    
    
    if ([strBaselineData isEqualTo:@""] || strBaselineData == nil
        || [strForceData isEqualTo:@""] || strForceData == nil)
        bReturn = NO;
    else
    {
        NSMutableArray *arrForceData  = [[NSMutableArray alloc] init];
        NSMutableArray *arrBaselineData  = [[NSMutableArray alloc] init];
        NSArray *aryForceRawData = [strForceData componentsSeparatedByString: @"\n"];
        NSArray *aryBaselineRawData = [strBaselineData componentsSeparatedByString: @"\n"];
        
        if (0 != [aryForceRawData count])
            for (int i = 0; i < [aryForceRawData count]; i++)
            {
                NSArray *aryColData = [[aryForceRawData objectAtIndex:i] componentsSeparatedByString:@"\t"];
                for (int j = 0; j<[aryColData count]; j++)
                {
                    if ([[aryColData objectAtIndex:j] isNotEqualTo:@""] && [aryColData objectAtIndex:j] != nil)
                        [arrForceData addObject:[aryColData objectAtIndex:j]];
                }
            }
        
        if (0 != [aryBaselineRawData count])
            for (int i = 0; i < [aryBaselineRawData count]; i++)
            {
                NSArray *aryColData = [[aryBaselineRawData objectAtIndex:i] componentsSeparatedByString:@"\t"];
                for (int j = 0; j<[aryColData count]; j++)
                {
                    if ([[aryColData objectAtIndex:j] isNotEqualTo:@""] && [aryColData objectAtIndex:j] != nil)
                        [arrBaselineData addObject:[aryColData objectAtIndex:j]];
                }
            }
        
        
        if ([arrBaselineData count] != 96 * iFrames * 2 || [arrForceData count] != 96 * iFrames * 2) //we must have 9600 data
            bReturn = NO;
        else
        {
            using namespace std;
            global_parameters testConfig;
            testConfig.touch_coords = false;
            testConfig.npy = 12;
            testConfig.npx = 8;
            testConfig.nframes = iFrames;
            testConfig.nfx = 1;
            testConfig.nfy = 1;
            testConfig.nforces = 2;
            std::vector<float> forceList = VectOp::linspace((float)100, (float)400, 2);
            testConfig.forces = forceList;
            
            //Reshapes dataSample, which is one dimensional, into the shape we specify
            nDvector<float> forceData   = [self originalData:arrForceData withParameters:testConfig];
            //baseline
            nDvector<float> baseline    = [self originalData:arrBaselineData withParameters:testConfig];
            
            //processes raw data and returns the figures of merit we want to upload in 'r'
            std::map<std::string, nDvector<float> > r = orbcg_post(forceData, baseline,testConfig);
            
            size_t dimension_1[] = {12, 8, 0};
            size_t dimension_2[] = {12, 8, 1};
            std::vector<size_t> position_1(dimension_1, dimension_1 + sizeof(dimension_1)/sizeof(dimension_1[0]));
            std::vector<size_t> position_2(dimension_2, dimension_2 + sizeof(dimension_2)/sizeof(dimension_2[0]));
            
//            std::vector<float> mean_baseline_gap = r["mean_baseline_gap"];
            nDvector<float> mean_baseline_gap_1 = r["mean_baseline_gap"].get_subnDvector(position_1);
            nDvector<float> mean_baseline_gap_2 = r["mean_baseline_gap"].get_subnDvector(position_2);
            
//            std::vector<float> mean_force_gap = r["mean_force_gap"];
            nDvector<float> mean_force_gap_1 = r["mean_force_gap"].get_subnDvector(position_1);
            nDvector<float> mean_force_gap_2 = r["mean_force_gap"].get_subnDvector(position_2);
            
            nDvector<float> deflection_1 = mean_force_gap_1 - mean_baseline_gap_1;
            nDvector<float> deflection_2 = mean_force_gap_2 - mean_baseline_gap_2;
        
            //gap
            [self writeOrbDataToLogPath: strGapFilePath
                                andData: @"------------------  mean_baseline_gap_1  ------------------\n"];
            [self writeOrbDataToLogPath:strGapFilePath
                                andData:[self catchDataFrom:mean_baseline_gap_1]];
            [m_dicMemoryValues setObject:[self catchDataFrom:mean_baseline_gap_1]
                                  forKey:strBaselineGap1];
            
            [self writeOrbDataToLogPath: strGapFilePath
                                andData: @"\n------------------  mean_force_gap_1  ------------------\n"];
            [self writeOrbDataToLogPath:strGapFilePath
                                andData:[self catchDataFrom:mean_force_gap_1]];
            [m_dicMemoryValues setObject:[self catchDataFrom:mean_force_gap_1]
                                  forKey:strForceGap1];
            
            [self writeOrbDataToLogPath: strGapFilePath
                                andData: @"\n------------------  mean_baseline_gap_2  ------------------\n"];
            [self writeOrbDataToLogPath:strGapFilePath
                                andData:[self catchDataFrom:mean_baseline_gap_2]];
            [m_dicMemoryValues setObject:[self catchDataFrom:mean_baseline_gap_2]
                                  forKey:strBaselineGap2];
            
            [self writeOrbDataToLogPath: strGapFilePath
                                andData: @"\n------------------  mean_force_gap_2  ------------------\n"];
            [self writeOrbDataToLogPath:strGapFilePath
                                andData:[self catchDataFrom:mean_force_gap_2]];
            [m_dicMemoryValues setObject:[self catchDataFrom:mean_force_gap_2]
                                  forKey:strForceGap2];
            
            
            NSMutableString *strBuffer      = [[NSMutableString alloc] init];
            //deflection
            [self writeOrbDataToLogPath: strDeflectionFilePath
                                andData: @"----------------------------------  deflection_1  ---------------------------------\n"];
            [self writeOrbDataToLogPath:strDeflectionFilePath
                                andData:[self catchDataFrom:deflection_1]];
            [strBuffer appendString:[self catchDataFrom:deflection_1]];
            [m_dicMemoryValues setObject:[self catchDataFrom:deflection_1]
                                  forKey:strDeflection1];
            
            [self writeOrbDataToLogPath: strDeflectionFilePath
                                andData: @"\n---------------------------------  deflection_2  ---------------------------------\n"];
            [self writeOrbDataToLogPath:strDeflectionFilePath andData:[self catchDataFrom:deflection_2]];
            [strBuffer appendString:[self catchDataFrom:deflection_2]];
            [m_dicMemoryValues setObject:[self catchDataFrom:deflection_2]
                                  forKey:strDeflection2];
            [szReturnValue setString:strBuffer];
            ATSDebug(@"%@",strBuffer);
            [strBuffer release]; strBuffer = nil;
            bReturn = YES;
        }
        
        [arrForceData release]; arrForceData = nil;
        [arrBaselineData release]; arrBaselineData = nil;
    }
    return [NSNumber numberWithBool:bReturn];
}

- (NSNumber *)SINGLE_CALCULATE_ORB_DATA:(NSDictionary *)dicPara
                           RETURN_VALUE:(NSMutableString *)szReturnValue
{
    BOOL bResult = YES;
    //Memory keys
    NSDictionary    *dicMemoryKeys  = [dicPara objectForKey:@"MEMORY_KEYS"];
    NSString        *strKey         = [dicMemoryKeys objectForKey:@"RESULT"];
    
    //Get gap datas
    NSString    *strBaselineData1   = [m_dicMemoryValues objectForKey:[dicPara objectForKey:@"BASELINE_DATA1"]];
    NSString    *strBaselineData2   = [m_dicMemoryValues objectForKey:[dicPara objectForKey:@"BASELINE_DATA2"]];
    NSString    *strForceData1      = [m_dicMemoryValues objectForKey:[dicPara objectForKey:@"FORCE_DATA1"]];
    NSString    *strForceData2      = [m_dicMemoryValues objectForKey:[dicPara objectForKey:@"FORCE_DATA2"]];
    
    NSString    *strBaselineData    = [NSString stringWithFormat:@"%@%@",strBaselineData1,strBaselineData2];
    NSString    *strForceData       = [NSString stringWithFormat:@"%@%@",strForceData1, strForceData2];
    
    int iFrames     = [[dicPara objectForKey:@"FRAMES"]intValue];
    
    //set single file path
    NSString    *strGapFilePath         = [NSString stringWithFormat:@"%@/%@_%@/orb_gap.txt",kPD_LogPath,m_szPortIndex,m_szStartTime];
    
    if ([strBaselineData isEqualTo:@""] || strBaselineData == nil
        || [strForceData isEqualTo:@""] || strForceData == nil)
        bResult = NO;
    else
    {
        NSMutableArray *arrForceData  = [[NSMutableArray alloc] init];
        NSMutableArray *arrBaselineData  = [[NSMutableArray alloc] init];
        NSArray *aryForceRawData = [strForceData componentsSeparatedByString: @"\n"];
        NSArray *aryBaselineRawData = [strBaselineData componentsSeparatedByString: @"\n"];
        
        if ([aryForceRawData count] > 1)
            for (int i = 0; i < [aryForceRawData count]; i++)
            {
                NSArray *aryColData = [[aryForceRawData objectAtIndex:i] componentsSeparatedByString:@"\t"];
                for (int j = 0; j<[aryColData count]; j++)
                {
                    if ([[aryColData objectAtIndex:j] isNotEqualTo:@""]
                        && [aryColData objectAtIndex:j] != nil
                        && ![[aryColData objectAtIndex:j] contains:@"(null)"])
                        [arrForceData addObject:[aryColData objectAtIndex:j]];
                }
            }
        
        if ([aryBaselineRawData count] > 1)
            for (int i = 0; i < [aryBaselineRawData count]; i++)
            {
                NSArray *aryColData = [[aryBaselineRawData objectAtIndex:i] componentsSeparatedByString:@"\t"];
                for (int j = 0; j<[aryColData count]; j++)
                {
                    if ([[aryColData objectAtIndex:j] isNotEqualTo:@""]
                        && [aryColData objectAtIndex:j] != nil
                        && ![[aryColData objectAtIndex:j] contains:@"(null)"])
                        [arrBaselineData addObject:[aryColData objectAtIndex:j]];
                }
            }
        
        
        if ([arrBaselineData count] != 96 * iFrames && [arrForceData count] != 96 * iFrames)
        {
            [szReturnValue setString:@"No data found"];
            bResult = NO;
        }
        else
        {
            using namespace std;
            global_parameters testConfig;
            testConfig.touch_coords = false;
            testConfig.npy = 12;
            testConfig.npx = 8;
            testConfig.nframes = iFrames;
            testConfig.nfx = 1;
            testConfig.nfy = 1;
            testConfig.nforces = 1;
            std::vector<float> forceList = VectOp::linspace((float)100, (float)400, 2);
            testConfig.forces = forceList;
            
            NSMutableString *strBuffer      = [[NSMutableString alloc] init];
            if ([arrBaselineData count] > 1)
            {
                //baseline
                nDvector<float> baseline    = [self originalData:arrBaselineData withParameters:testConfig];
                [self writeOrbDataToLogPath: strGapFilePath
                                    andData: @"------------------  mean_baseline_gap  ------------------\n"];
                [self writeOrbDataToLogPath:strGapFilePath
                                    andData:[self catchDataFrom:baseline]];
                [strBuffer appendString:[self catchDataFrom:baseline]];
            }
            
            if ([arrForceData count] > 1)
            {
                //Reshapes dataSample, which is one dimensional, into the shape we specify
                nDvector<float> forceData   = [self originalData:arrForceData withParameters:testConfig];
                [self writeOrbDataToLogPath: strGapFilePath
                                    andData: @"\n------------------  mean_force_gap  ------------------\n"];
                [self writeOrbDataToLogPath:strGapFilePath
                                    andData:[self catchDataFrom:forceData]];
                [strBuffer appendString:[self catchDataFrom:forceData]];
            }

            [m_dicMemoryValues setObject:strBuffer forKey:strKey];
            [szReturnValue setString:strBuffer];
            ATSDebug(@"%@",strBuffer);
            [strBuffer release]; strBuffer = nil;
            bResult = YES;
        }
        
        [arrForceData release]; arrForceData = nil;
        [arrBaselineData release]; arrBaselineData = nil;
    }
    
    return [NSNumber numberWithBool:bResult];
}

- (nDvector<float>)originalData:(NSMutableArray *)arrData withParameters:(global_parameters)config
{
    using namespace std;
    //Creates a vector with the dimensions that our data will need to be reshaped into
    size_t raw_dimension[] = {config.npy, config.npx, config.nframes, config.nforces, config.nfy, config.nfx};
    std::vector<size_t> raw_shape(raw_dimension, raw_dimension + sizeof(raw_dimension)/sizeof(raw_dimension[0]));
    
    /*
     *Create a one dimensional vector with 12x8x50x2 (pixel_y * pixel_x * frames * forces)
     */
    int i = 0;
    std::vector<float> vData;
    while (i < [arrData count])
    {
        vData.push_back([[arrData objectAtIndex:i]floatValue]);
        i++;
    }
    nDvector<float> gapData(raw_shape, vData);
    return gapData;
}

- (NSString *)catchDataFrom:(nDvector<float>)meanGap
{
    using namespace std;
    std::vector<float> dvector_linear = meanGap.m_nDvector_linear;
    
    NSMutableArray *arrGapData  = [[NSMutableArray alloc] init];
    NSMutableString *strBuffer  = [[NSMutableString alloc] initWithString:@""];
    for(vector<float>::iterator pos = dvector_linear.begin(); pos != dvector_linear.end(); ++pos)
    {
        [arrGapData addObject:[NSNumber numberWithFloat:*pos]];
        [strBuffer appendString:[NSString stringWithFormat:@"%.6f\t", *pos]];
        if ([arrGapData count]%8 == 0)
        {
            [strBuffer appendString:@"\n"];
        }
    }
    [arrGapData release]; arrGapData = nil;
    return strBuffer;
}



@end
