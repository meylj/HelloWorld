//
//  IADevice_Instrument.h
//  FunnyZone
//
//  Created by Eagle on 12/13/11.
//  Copyright 2011 PEGATRON. All rights reserved.
//

#import "TestProgress.h"

@interface TestProgress (IADevice_Instrument)

/*
 * Kyle 2012.02.21
 * method   : Init_Instrument:RETURN_VALUE:
 * abstract : Init a GPIB and memory
 * key      :
 *              INSTRUMENTTYPE ==> init GPIB type
 *              BOARDIDCOUNT   ==> how many cards will be used
 *              PRIMARYADDRESS ==> init GPIB address
 *              INSTRUMENTNAME ==> GPIB memory key
 *
 */
- (NSNumber *)Init_Instrument:(NSDictionary*)dictSetting RETURN_VALUE:(NSMutableString *)szReturnValue;

/*
 * Kyle 2012.02.21
 * method   : Instrument_Send_Command:RETURN_VALUE:
 * abstract : get a GPIB and send command
 * key      :
 *              GPIBCOMMAND    ==> will be send command
 *              INSTRUMENTNAME ==> the key of GPIB
 *
 */
- (NSNumber *)Instrument_Send_Command:(NSDictionary*)dictSetting RETURN_VALUE:(NSMutableString *)szReturnValue;

/*
 * Kyle 2012.02.21
 * method   : Instrument_Receive_Command:RETURN_VALUE:
 * abstract : get a GPIB and receive command
 * key      :
 *              INSTRUMENTNAME ==> the key of GPIB
 *
 */
- (NSNumber *)Instrument_Receive_Command:(NSDictionary*)dictSetting RETURN_VALUE:(NSMutableString *)szReturnValue;

/*
 * Kyle 2012.02.22
 * method   : SendCommandTimesForAVG:RETURN_VALUE:
 * abstract : send command ? times ,get the values and get AVG
 *
 */
- (NSNumber *)SendCommandTimesForAVG:(NSDictionary*)dictSetting RETURN_VALUE:(NSMutableString *)szReturnValue;

- (NSNumber *)RECEIVE_DATA:(NSDictionary *)dicData RETURN_VALUE:(NSMutableString *)szReturnValue;

// Realqian/Betty 2012.1.2
// Method:      To count data loss in Grounding-1
// abstract:    
// Param:
//      NSDictionary    *dictData           : Settings in script
//      NSMutableString *strReturnValue     : Return value
// 
- (NSNumber *)COUNT_DATA_LOSS:(NSDictionary*)dictData RETURN_VALUE:(NSMutableString *)szReturnValue;

// Realqian/Betty 2012.1.9
// Method:      write cable loss into CSV log
// abstract:    
// Param:
//      NSDictionary    *dictData           : Settings in script
//      NSMutableString *strReturnValue     : Return value
// 
- (NSNumber *)ADD_CABLE_LOSS_TO_CSV:(NSDictionary *)dicData RETURN_VALUE:(NSMutableString *)szReturnValue;
@end
