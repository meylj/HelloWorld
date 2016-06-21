//
//  TestProgress+IADevice_CPlusPlus.h
//  FunnyZone
//
//  Created by raniys on 3/19/15.
//  Copyright (c) 2015 PEGATRON. All rights reserved.
//

#import "TestProgress.h"

@interface TestProgress (IADevice_CPlusPlus)

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
                    RETURN_VALUE:(NSMutableString *)szReturnValue;



@end
