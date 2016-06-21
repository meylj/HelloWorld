//
//  Device_34401A.h
//  InstrumentTest
//
//  Created by wu howard on 09-9-7.
//  Copyright 2009 pegatron. All rights reserved.
//



#import <Cocoa/Cocoa.h>
#import "InstrumentBase.h"



@interface Device_34401A : InstrumentBase
{

}

-(int)_getMeasureVoltage:(bool)bIsDC
				   range:(int)iRange
			  resolution:(float)fResolution
			MeasureValue:(float*)fMeasureValue;
-(int)_getMeasureCurrent:(bool)bIsDC
				   range:(int)iRange
			  resolution:(float)fResolution
			MeasureValue:(float*)fMeasureValue;
-(int)_getMeasureResistence:(int)iRange
			   MeasureValue:(float*)fMeasureValue;

@end




