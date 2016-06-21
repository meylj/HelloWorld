//
//  Device_34970.h
//  InstrumentTest
//
//  Created by 吳 枝霖 on 2009/4/22.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "InstrumentBase.h"
#define		kFetchCountTimeOut		60 * 5
@interface Device_34970 : InstrumentBase {

}
/****************************************************************************************************
 nChannel		: ch_list parameter which allow you to specify one or more channels.
				  such as 101,102,103,...
 bOpenClose		: YES (Close Channcel), NO (Open Channel)
 description	: Open or Close the specified channels on a multiplexer or switch module
 ****************************************************************************************************/
- (int) setRoutSwitch:(BOOL) bOpenClose ChannelLists:(NSString *) aChannels;
/****************************************************************************************************
 nChannel		: ch_list parameter which allow you to specify one or more channels.
 such as 201,202,203,...
 bIsDC_VOLT		: YES (DC Voltage), NO (AC Voltage)
 description	: Configure the specified channels for dc or ac voltage measurements and 
 immediately sweep through the scan list one time
 ****************************************************************************************************/
- (int) getMeasureVoltage:(BOOL) bIsDC_VOLT ChannelLists:(NSString *) aChannels 
				  Voltage:(NSMutableArray *) ArrayVoltage;
/****************************************************************************************************
 nChannel		: ch_list parameter which allow you to specify one or more channels.
 such as 201,202,203,...
bIsDC_VOLT		: YES (DC Current), NO (AC Current)
 description	: Configure the specified channels for dc or ac current measurements and 
 immediately sweep through the scan list one time.
 ****************************************************************************************************/
- (int) getMeasureCurrent:(BOOL) bIsDC_CURR ChannelLists:(NSString *) aChannels 
				  Current:(NSMutableArray *) ArrayCurrent;
/****************************************************************************************************
 nChannel		: ch_list parameter which allow you to specify one or more channels.
 such as 201,202,203,...
 bIsDC_VOLT		: YES (DC Current), NO (AC Current)
 description	: Configure the specified channels for dc or ac current measurements and 
 immediately sweep through the scan list one time.
 ****************************************************************************************************/
- (int) getMeasureAvgCurrent:(BOOL) bIsDC_CURR Quick:(BOOL) bQuick ChannelLists:(NSString *) 
				 aChannels IntervalTime:(float) fIntervalTime 
				 FetchCount :(int) iFetchCount Current:(NSMutableArray *) ArrayCurrent;
/****************************************************************************************************
 nChannel		: ch_list parameter which allow you to specify one or more channels.
 such as 201,202,203,...
 bIsDC_VOLT		: YES (DC Current), NO (AC Current)
 description	: Configure the specified channels for dc or ac current measurements and 
 immediately sweep through the scan list one time.
 ****************************************************************************************************/
- (int) getQuickMeasureCurrent:(BOOL) bIsDC_CURR ChannelLists:(NSString *) aChannels 
				  Current:(NSMutableArray *) ArrayCurrent;
/****************************************************************************************************
 nChannel		: ch_list parameter which allow you to specify one or more channels.
 such as 201,202,203,...
 nRange			: such as kAutoRange, k100ohm, k1Kohm, k10Kohm, k100Kohm, k1Mohm, k10Mohm
 description	: Configure the specified channels for 2-wire measurements and 
 immediately sweep through the scan list one time
 ****************************************************************************************************/
- (int) getMeasureResistance:(NSString *) aChannels Range:(int) nRange Resistance:(NSMutableArray *) ArrayResistance;
/****************************************************************************************************
 nChannel		: ch_list parameter which allow you to specify one or more channels.
 such as 201,202,203,...
 description	: Configure the specified channels for frequency or period measurements 
 and immediately sweep through the scan list one time
 ****************************************************************************************************/
- (int) getMeasureFrequency:(NSString *) aChannels Frequency:(NSMutableArray *) ArrayFrequency;
/****************************************************************************************************
 nChannel		: ch_list parameter which allow you to specify one or more channels.
 such as 201,202,203,...
 IntervalTime	: AC Filter Channel Delay,Slow (3 Hz)=0.6 sec,Medium (20 Hz)=0.3 sec,Fast (200 Hz)=0.1 sec 
 FetchCount		: 10,
 description	: Configure the specified channels for frequency or period measurements 
 and immediately sweep through the scan list one time
 ****************************************************************************************************/
- (int) readMeasureFrequency:(NSString *) aChannels IntervalTime:(float) fIntervalTime 
				 FetchCount : (int) iFetchCount Frequency:(NSMutableArray *) ArrayFrequency;
/****************************************************************************************************
 nChannel		: ch_list parameter which allow you to specify one or more channels.
 such as 201,202,203,...
 IntervalTime	: AC Filter Channel Delay,Slow (3 Hz)=0.6 sec,Medium (20 Hz)=0.3 sec,Fast (200 Hz)=0.1 sec 
 FetchCount		: 10,
 description	: Configure the specified channels for frequency or period measurements 
 and immediately sweep through the scan list one time
 ****************************************************************************************************/
- (int) readMeasureResistance :(NSString *) aChannels Range:(int) nRange IntervalTime:(float) fIntervalTime 
				   FetchCount : (int) iFetchCount Resistance:(NSMutableArray *) ArrayResistance;
@end
