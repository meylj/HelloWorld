//
//  CustomTimer.m
//  Muifa
//
//  Created by Lorky on 12/23/13.
//  Copyright (c) 2013 PEGATRON. All rights reserved.
//

#import "CustomTimer.h"

@implementation CustomTimer

@synthesize textField;

- (void)fireTimer
{
	// Set timer
	myClock.hour    = 0;
	myClock.minute  = 0;
	myClock.second  = 0;
	myTimer = [NSTimer timerWithTimeInterval:1.0
									  target:self
									selector:@selector(timerTicks)
									userInfo:nil
									 repeats:YES];
	[[NSRunLoop currentRunLoop] addTimer:myTimer
								 forMode:NSDefaultRunLoopMode];
	[myTimer fire];
}

- (void)invalidateTimer
{
	[myTimer invalidate];
}

- (BOOL)isValid;
{
	return [myTimer isValid];
}

- (void)timerTicks
{
    NSAutoreleasePool       *pool   = [[NSAutoreleasePool    alloc]init];
    myClock.second++;
    if (myClock.second == 60)
	{
        myClock.second  = 0;
        myClock.minute++;
        if (myClock.minute == 60)
		{
            myClock.minute  = 0;
            myClock.hour++;
            if (myClock.hour == 24)
			{
                myClock.hour = 0;
				myClock.day	++;
            }
        }
    }
	
	NSString * strTimer;
	if (myClock.day)
	{
		
		strTimer			= [NSString stringWithFormat:@"%d(days) %@:%@:%@",myClock.day,
							   myClock.hour < 10	?
							   [NSString stringWithFormat:@"0%d",myClock.hour]		:
							   [NSString stringWithFormat:@"%d",myClock.hour],
							   myClock.minute < 10  ?
							   [NSString stringWithFormat:@"0%d",myClock.minute]	:
							   [NSString stringWithFormat:@"%d",myClock.minute],
							   myClock.second < 10	?
							   [NSString stringWithFormat:@"0%d",myClock.second]	:
							   [NSString stringWithFormat:@"%d",myClock.second]];
	}
	else
	{
		strTimer			= [NSString stringWithFormat:@"%@:%@:%@", myClock.hour < 10	?
							   [NSString stringWithFormat:@"0%d",myClock.hour]		:
							   [NSString stringWithFormat:@"%d",myClock.hour],
							   myClock.minute < 10  ?
							   [NSString stringWithFormat:@"0%d",myClock.minute]	:
							   [NSString stringWithFormat:@"%d",myClock.minute],
							   myClock.second < 10	?
							   [NSString stringWithFormat:@"0%d",myClock.second]	:
							   [NSString stringWithFormat:@"%d",myClock.second]];
	}
	
	[textField setStringValue:strTimer];
	[pool    drain];
}


@end
