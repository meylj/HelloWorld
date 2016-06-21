//
//  CustomTimer.h
//  Muifa
//
//  Created by Lorky on 12/23/13.
//  Copyright (c) 2013 PEGATRON. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef struct clock
{
	unsigned	int day;
    unsigned    int hour;
    unsigned    int minute;
    unsigned    int second;
}CTimer;

@interface CustomTimer : NSObject
{
	CTimer		myClock;
	NSTimer		*myTimer;
	
	NSTextField * textField;
}

@property (nonatomic,retain) NSTextField * textField;

- (void)fireTimer;
- (void)invalidateTimer;

@end
