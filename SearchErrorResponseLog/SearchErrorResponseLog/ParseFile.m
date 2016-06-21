//
//  ParseFile.m
//  SearchErrorResponseLog
//
//  Created by 张斌 on 14-8-21.
//  Copyright (c) 2014年 张斌. All rights reserved.
//

#import "ParseFile.h"
#import "NSStringCategory.h"

#define BD_X    @"<bd-\\d{1}>"
#define X5      @"<5s-[a-z]+(=[-|+]?\\d+-[a-z]+){6}=[-/+]?\\d,[-/+]?\\d,[-/+]?\\d-[a-z]+(=\\d+-[a-z0-9]+)+=\\d>"

#define MSN     @"<msn-\\*\\*EMPTY\\*\\*>$"
#define SV      @"<sv-\\d\\.\\d\\.\\d>$"
#define HV      @"<hv-[0-9]{1}>$"
#define FSN     @"<fsn-[A-Z0-9]{12}>$"
#define BE      @"<be-\\d+>"
#define SBA_5   @"<sba-5>$"
#define GET_RSTB @"<get-RSTB-\\d>"
#define BI_X    @"<bi-\\d-[a-z]=\\d{5}mWh-v=\\d{5}mV-m=DP-d=[a-z0-9]+-[a-z]=[A-Z0-9]{17}>"
#define BE_C    @"\\[\\d+\\] PM: disable all batteries\n<be-C>$"
#define BE_X    @"\\[\\d+\\] PM: (enable|disable) \\d\n<be-\\d>"
#define BS_X    @"<bs-\\d-v=[0-9]{5}mV-i=[-|+]?[0-9]{4}mA-h=[0-9]{2}-c=[0-9]{3}%-cc=[0-9]{4}-t=[a-z0-9A-Z]+>"
#define OW      @"<ow-1(\\s[A-Z0-9]{2}){8}>"
#define PWR_3   @"<pwr-MAGS-i=[-/+]?[0-9]+mA-v=[0-9]+mV>"
#define TMP_X   @"<tmp(-\\d)?-\\d{4}>$"
#define ML_X_X  @"<ml-[A-Z0-9]+-\\d+>"
#define FSN_REX @"<FSN-[A-Z0-9]{12}>"
#define BURN_X_X @"<burn-60-40>"



@implementation ParseFile

- (id)init
{
    self = [super init];
    if (self)
    {
        
        self.m_szMovePath = @"";
        
        self.m_dicStr = [[NSMutableDictionary alloc] init];
        [self.m_dicStr setObject:BD_X forKey:@"[BD-0]"];
        [self.m_dicStr setObject:BD_X forKey:@"[BD-1]"];
        [self.m_dicStr setObject:X5 forKey:@"[5S]"];
        [self.m_dicStr setObject:MSN forKey:@"[MSN]"];
        [self.m_dicStr setObject:SV forKey:@"[SV]"];
        [self.m_dicStr setObject:HV forKey:@"[HV]"];
        [self.m_dicStr setObject:FSN forKey:@"[FSN]"];
        [self.m_dicStr setObject:FSN forKey:FSN_REX];
        [self.m_dicStr setObject:SBA_5 forKey:@"[SBA-5]"];
        [self.m_dicStr setObject:GET_RSTB forKey:@"[GET-RSTB]"];
        [self.m_dicStr setObject:BI_X forKey:@"[BI-0]"];
        [self.m_dicStr setObject:BI_X forKey:@"[BI-1]"];
        [self.m_dicStr setObject:BI_X forKey:@"[BI-2]"];
        [self.m_dicStr setObject:BI_X forKey:@"[BI-3]"];
        [self.m_dicStr setObject:BI_X forKey:@"[BI-4]"];
        [self.m_dicStr setObject:BE_C forKey:@"[BE-C]"];
        [self.m_dicStr setObject:BE_X forKey:@"[BE-0]"];
        [self.m_dicStr setObject:BE_X forKey:@"[BE-1]"];
        [self.m_dicStr setObject:BE_X forKey:@"[BE-2]"];
        [self.m_dicStr setObject:BE_X forKey:@"[BE-3]"];
        [self.m_dicStr setObject:BE_X forKey:@"[BE-4]"];
        [self.m_dicStr setObject:BS_X forKey:@"[BS-0]"];
        [self.m_dicStr setObject:BS_X forKey:@"[BS-1]"];
        [self.m_dicStr setObject:BS_X forKey:@"[BS-2]"];
        [self.m_dicStr setObject:BS_X forKey:@"[BS-3]"];
        [self.m_dicStr setObject:BS_X forKey:@"[BS-4]"];
        [self.m_dicStr setObject:OW forKey:@"[OW]"];
        [self.m_dicStr setObject:ML_X_X forKey:@"[ML-1-0]"];
        [self.m_dicStr setObject:ML_X_X forKey:@"[ML-0-1]"];
        [self.m_dicStr setObject:ML_X_X forKey:@"[ML-0-0]"];
        [self.m_dicStr setObject:PWR_3 forKey:@"[PWR-3]"];
        [self.m_dicStr setObject:TMP_X forKey:@"[TMP-0]"];
        [self.m_dicStr setObject:TMP_X forKey:@"[TMP-1]"];
        [self.m_dicStr setObject:TMP_X forKey:@"[TMP-2]"];
        [self.m_dicStr setObject:BE forKey:@"[BE]"];
        [self.m_dicStr setObject:BURN_X_X forKey:@"[BURN-60-40]"];
        
        
        
        
    }
    return self;
}

-(NSArray *)FindDiretory:(NSString *)szPath
{
    
    self.m_szDiretory = szPath;
    NSFileManager * fileManger = [NSFileManager defaultManager];
    NSError * error = nil;
    NSArray * aryPath = [fileManger contentsOfDirectoryAtPath:szPath error:&error];
    return aryPath;
}

-(NSDictionary *)ParseAndMoveFile:(NSArray *)aryPath
{
    NSMutableDictionary * m_dic = [[[NSMutableDictionary alloc] init] autorelease];
    for (NSString *szPath in aryPath)
    {
        //one log
        if ([szPath ContainString:@"Uart.txt"])
        {
           // NSString * szSN = [szPath lastPathComponent];
            NSMutableString * szDescription = [NSMutableString stringWithString:@""];
            
            NSString * szContent = [NSMutableString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",self.m_szDiretory,szPath] encoding:NSUTF8StringEncoding error:nil];
            szContent = [szContent stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
            szContent = [szContent stringByReplacingOccurrencesOfString:@"\\r" withString:@"\n"];
            
            
            NSArray * aryContent = [szContent componentsSeparatedByString:@"\n"];
            
            int index = 0;
            
            //don't save content which before item0
            bool obel = NO;
            
            //save all items content
            NSMutableArray * aryItem = [[NSMutableArray alloc] init];
            
            //parse content to one item by one itemd
            NSMutableString * szStr = [NSMutableString stringWithString:@""];
            
            
            NSMutableArray * aryItemName = [[NSMutableArray alloc] init];
            
            NSString * szName = @"";
            for (int i = 0; i <[aryContent count];i++)
            {

                NSString * szContent = [aryContent objectAtIndex:i];
                
                if([szContent ContainString:@"(Item0)"])
                {
                    obel = YES;
                    
                    szName = [[szContent subByRegex:@".*?START TEST\\s(.*?)\\(Item0\\)" name:nil error:nil] copy];
                    [szName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    index++;
                    continue;
                }
                
                if(!obel)
                {
                    continue;
                }
                
                
                
                if(![szContent ContainString:[NSString stringWithFormat:@"(Item%d)",index]])
                {
                    
                    if([szStr isEqualToString:@""])
                    {
                        [szStr setString:szContent];
                    }
                    else
                    {
                        [szStr appendFormat:@"\n%@",szContent];
                    }
                    
                    
                }
                else
                {
                    index++;
                    if(![szStr isEqualToString:@""])
                    {
                        if(([szStr ContainString:@"TX ==> [AUX]"] && [szStr ContainString:@"RX ==> [AUX]"]))
                        {
                            [aryItem addObject:[szStr copy]];
                            [aryItemName addObject:szName];
                            
                        }
                        [szStr setString:@""];
                                               
                    }
                    
                    szName = [[szContent subByRegex:@".*?START TEST(.*?)\\(Item" name:nil error:nil] copy];
                    [szName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                }
                
            }            
            
            BOOL bErrResponse = NO;
            //parse RX content
            for (NSString * szItem in aryItem)
            {
                NSString * szName = [aryItemName objectAtIndex:[aryItem indexOfObject:szItem]];
                
                if([szItem ContainString:@"(Clear Buffer ==> [AUX]):"])
                {
                    do
                    {
                        
                        szItem = [szItem SubFrom:@"Clear Buffer ==> [AUX]):" include:NO];
                        
                        NSString * szStr = @"";
                        
                        if([szItem ContainString:@"(Clear Buffer ==> [AUX]):"])
                        {
                            NSError * error = nil;
                            NSString * rex = @"^(.*?)\\[\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}\\.\\d+\\]\\(Clear Buffer ==> \\[AUX\\]\\)";
                            szStr = [szItem subByRegex:rex name:nil error:&error];
                            
                        }
                        else
                        {
                            szStr = szItem;
                        }
                        
                        NSString * szTx = [szStr subByRegex:@"^.*?\\(TX ==> \\[AUX\\]\\):(.*?)\\[\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}\\.\\d+\\]\\(RX ==> \\[AUX\\]\\)" name:nil error:nil];
                        NSString * szRx = [szStr subByRegex:@"\\[.*?\\]\\(RX ==> \\[AUX\\]\\):(.*?)$" name:nil error:nil];
                        szTx = [szTx stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        szRx = [szRx stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        NSString * szRxValue = [self.m_dicStr objectForKey:szTx];
                        
                        if(!szRxValue)
                        {
                            NSArray * aryKey = [self.m_dicStr allKeys];
                            for (NSString * szRex in aryKey)
                            {
                                if([szTx matches:szRex])
                                {
                                    szRxValue = [self.m_dicStr objectForKey:szRex];
                                }
                            }
                            
                        }
                    
                        
                        if([szRx isEqualToString:@""])
                        {
                            bErrResponse = YES;
                            if([szDescription isEqualToString:@""])
                            {
                                [szDescription setString:[NSString stringWithFormat:@"%@/%@ : Empty",szName,szTx]];
                            }
                            else
                            {
                                [szDescription setString:[NSString stringWithFormat:@"%@\n%@/%@ : Empty",szDescription,szName,szTx]];
                            }
                            
                            continue;
                        }
                        
                        
                        if(![szRx matches:szRxValue])
                        {
                            bErrResponse = YES;
                            if([szDescription isEqualToString:@""])
                            {
                                [szDescription setString:[NSString stringWithFormat:@"%@/%@ : Incomplete",szName,szTx]];
                            }
                            else
                            {
                                [szDescription setString:[NSString stringWithFormat:@"%@\n%@/%@ : Incomplete",szDescription,szName,szTx]];
                            }

                        }

                        
                    } while ([szItem ContainString:@"(Clear Buffer ==> [AUX]):"]);

                }
            }
            
            [aryItem release]; aryItem = nil;
            [aryItemName release]; aryItemName = nil;
             
            if(bErrResponse)
            {
               // NSString * szMoveDir = [NSString stringWithFormat:@"%@/%@",self.m_szDiretory,szPath];
                NSFileManager * fileManager = [NSFileManager defaultManager];
                if(![fileManager fileExistsAtPath:self.m_szMovePath])
                {
                    NSError * error;
                    [fileManager createDirectoryAtPath:self.m_szMovePath withIntermediateDirectories:YES attributes:nil error:&error];
                }
                NSError * error;
                [fileManager copyItemAtPath:[NSString stringWithFormat:@"%@%@",self.m_szDiretory,szPath] toPath:[NSString stringWithFormat:@"%@/%@",self.m_szMovePath,szPath] error:&error];
                
                
                [m_dic setObject:szDescription forKey:szPath];
            }
            
        }
    }

    return m_dic;
}


@end
