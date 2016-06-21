//
//  CSD_QRCode.h
//  FunnyZone
//
//  Created by Sunny on 13-9-25.
//  Copyright (c) 2013年 PEGATRON. All rights reserved.
//

#import "TestProgress.h"
#import "fsb.h"

@interface TestProgress (CSD_QRCode)

-(NSNumber*)ENCODE:(NSDictionary*)dicReadSettings
      RETURN_VALUE:(NSMutableString*)szReturnValue;

-(NSNumber*)DECODE:(NSDictionary*)dicReadSettings
      RETURN_VALUE:(NSMutableString*)szReturnValue;

- (NSData *)stringToData:(NSString *)strTemp;
- (NSString *)DataToString:(NSData *)dataTemp;


@end
