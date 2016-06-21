//
//  publicParams.h
//  FunnyZone
//
//  Created by Eagle on 13-10-23.
//  Copyright (c) 2013年 PEGATRON. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface publicParams : NSObject
{
    //For Pressure Test, Add by leehua 2013.10.18 begin
    NSNumber                *m_bFixtureController; //need clear every time
    NSMutableDictionary     *m_dicPublicMemoryValues; //need remove all objects every time
    NSNumber                *m_iPortCount; //no need to clear every time
    NSNumber                *m_iDynamicPortCount;//need to set as 0 every sampling
    //NSString *g_szSampleLogPath;//need init every time
}
//For Pressure Test, Add by leehua 2013.10.18 begin
@property (readwrite,assign)            NSNumber                *fixtureController;
@property (readwrite,assign)            NSMutableDictionary     *publicMemoryValues;
@property (readwrite,assign)            NSNumber                *portCount;
@property (readwrite,assign)            NSNumber                *dynamicPortCount;
//@property (readwrite,assign)            NSString *g_szSampleLogPath;

@end
