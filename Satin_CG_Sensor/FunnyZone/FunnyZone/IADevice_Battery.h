//  IADevice_Battery.h
//  Izual_Lu
//
//  Created by Lu Izual on 11-5-5.
//  Copyright 2011年 PEGATRON. All rights reserved.



#import "TestProgress.h"



@interface TestProgress (IADevice_Battery)

//torres 2011.11.7
// calculate power value,
-(NSNumber *)CALCULATE_POEWR:(NSDictionary*)dicPara
				RETURN_VALUE:(NSMutableString*)szReturnValue;
-(NSNumber *)GET_SLEEP_DATA:(NSDictionary*)dicPara
			   RETURN_VALUE:(NSMutableString*)szReturnValue;

@end




