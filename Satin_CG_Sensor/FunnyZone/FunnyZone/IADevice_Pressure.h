//
//  TestProgress+IADevice_Pressure.h
//  FunnyZone
//
//  Created by Eagle on 13-10-18.
//  Copyright (c) 2013年 PEGATRON. All rights reserved.
//

#import "TestProgress.h"

@interface TestProgress (IADevice_Pressure)

- (NSNumber *) GET_FIXTURE_HANDLES:(NSDictionary *)dicSubItems RETURN_VALUE:(NSMutableString *)szReturnValue;
- (NSNumber *) MEMORY_GLOBAL_VALUE:(NSDictionary *)dicSubItems RETURN_VALUE:(NSMutableString *)szReturnValue;
- (NSNumber *) GET_GLOBAL_VALUE:(NSDictionary *)dicSubItems RETURN_VALUE:(NSMutableString *)szReturnValue;
- (NSNumber *) IS_NUMBER:(NSDictionary *)dicSubItems RETURN_VALUE:(NSMutableString *)szReturnValue;
- (NSNumber *) SYNC_WITH_OTHER_DEVICE:(NSDictionary *)dicSubItems RETURN_VALUE:(NSMutableString *)szReturnValue;
- (NSNumber *) SAMPLE_THREAD:(NSDictionary *)dicSubItems RETURN_VALUE:(NSMutableString *)szReturnValue;
- (NSNumber *) CALCULATE_TEMP_HUM:(NSDictionary *)dicSubItems RETURN_VALUE:(NSMutableString *)szReturnValue;
- (NSNumber *) MEMORY_COUNT:(NSDictionary *)dicSubItems RETURN_VALUE:(NSMutableString *)szReturnValue;
- (NSNumber *) CALCULATE_PRESSURE:(NSDictionary *)dicSubItems RETURN_VALUE:(NSMutableString *)szReturnValue;
- (NSNumber *) CALCULATE_PATCH_DATA:(NSDictionary *)dicSubItems RETURN_VALUE:(NSMutableString *)szReturnValue;
- (NSNumber *) PUBLIC_ROLL:(NSDictionary *)dicSubItems RETURN_VALUE:(NSMutableString *)szReturnValue;
- (NSNumber *) WRITE_SAMPLE_LOG:(NSDictionary *)dicSubItems RETURN_VALUE:(NSMutableString *)szReturnValue;
- (NSNumber *) MESSAGE_BOX:(NSDictionary *)dicSubItems RETURN_VALUE:(NSMutableString *)szReturnValue;
- (NSNumber *) CANCEL_CASE_BY_TARGET:(NSDictionary *)dicSubItems RETURN_VALUE:(NSMutableString *)szReturnValue;
- (NSNumber *) GET_ID_BY_TARGET:(NSDictionary *)dicSubItems RETURN_VALUE:(NSMutableString *)szReturnValue;

// 2013-10-30 add by xiaoyong for pressure function
- (NSNumber *)GET_ROW_FROM_RAWDATA:(NSDictionary *)dicSetting RETURN_VALUE:(NSMutableString *)szReturnValue;

@end
