//
//  CAS140Controller.h
//  FunnyZone
//
//  Created by Lorky Luo on 7/23/12.
//  Copyright 2012 PEGATRON. All rights reserved.
//

#import "TestProgress.h"
#import "CAS4.h"
@interface TestProgress (CAS140Controller)

- (NSNumber *)INITCAS140:(NSDictionary *)dictPara RETURNVALUE:(NSMutableString *)retValue;
- (NSNumber *)READCAS140_SERIALNUMBER:(NSDictionary *)dictPara RETURNVALUE:(NSMutableString *)retValue;
- (NSNumber *)DO_DARKCURRENT:(NSDictionary *)dictPara RETURNVALUE:(NSMutableString *)strReturn;
- (NSNumber *)INITCAMERA:(NSDictionary *)dictPara RETURNVALUE:(NSMutableString *)strReturn;


- (NSNumber *)DO_MEASUREMENT:(NSDictionary *)dictPara RETURNVALUE:(NSMutableString *)retValue;
- (NSNumber *)READ_VENDOR:(NSDictionary *) dicPara RETURNVALUE:(NSMutableString *)retValue;
- (NSNumber *)READ_INSTRUMENT_SN:(NSDictionary *)dictPara RETURNVALUE:(NSMutableString *)retValue;
- (NSNumber *)CALCULATE_GAMMA_VALUE:(NSDictionary *)dictPara RETURN_VALUE:(NSMutableString *)retValue;




@end
