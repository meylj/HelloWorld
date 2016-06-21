//
//  Device_53131.h
//  InstrumentTest
//
//  Created by 吳 枝霖 on 2009/4/23.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//



#import <Cocoa/Cocoa.h>
#import	"InstrumentBase.h"



#define	kMeasureKHz	1
#define	kMeasureMHz	2



@interface Device_53131 : InstrumentBase
{

}
// pMeasureHz : The value must be kMeasureKHz or kMeasureMHz
- (int) setMeasureFrequency; 
- (int) getMeasureValue:(float *) fFrequency;

@end




