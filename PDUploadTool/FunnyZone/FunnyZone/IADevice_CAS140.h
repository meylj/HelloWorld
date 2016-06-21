//
//  IADevice_CAS140.h
//  FunnyZone
//
//  Created by Lorky Luo on 7/23/12.
//  Copyright 2012 PEGATRON. All rights reserved.
//

// modify class name to IADevice_CAS140 torres 2013/7/26
#import "TestProgress.h"
#import "CAS4.h"
#import "LoadingCAS140.h"

@interface TestProgress (IADevice_CAS140)

- (NSNumber *)INITCAS140:(NSDictionary *)dictPara RETURNVALUE:(NSMutableString *)retValue;
- (NSNumber *)READCAS140_SERIALNUMBER:(NSDictionary *)dictPara RETURNVALUE:(NSMutableString *)retValue;
- (NSNumber *)DO_DARKCURRENT:(NSDictionary *)dictPara RETURNVALUE:(NSMutableString *)strReturn;
- (NSNumber *)INITCAMERA:(NSDictionary *)dictPara RETURNVALUE:(NSMutableString *)strReturn;


- (NSNumber *)DO_MEASUREMENT:(NSDictionary *)dictPara RETURNVALUE:(NSMutableString *)retValue;
- (NSNumber *)READ_INSTRUMENT_SN:(NSDictionary *)dictPara RETURNVALUE:(NSMutableString *)retValue;
- (NSNumber *)CALCULATE_GAMMA_VALUE:(NSDictionary *)dictPara RETURN_VALUE:(NSMutableString *)retValue;




@end
