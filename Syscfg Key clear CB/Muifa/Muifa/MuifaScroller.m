//
//  MuifaScroller.m
//  Muifa
//
//  Created by Lorky on 12/20/13.
//  Copyright (c) 2013 PEGATRON. All rights reserved.
//

#import "MuifaScroller.h"

@implementation MuifaScroller

- (id)initWithFrame:(NSRect)frameRect
{
	self=[super initWithFrame:frameRect];
	if(self){
		[self setArrowsPosition:NSScrollerArrowsNone];
		background = [[NSGradient alloc] initWithStartingColor:[NSColor colorWithDeviceWhite:0.7 alpha:1.0]
												   endingColor:[NSColor colorWithDeviceWhite:0.6 alpha:1.0]];
		
	}
	return self;
}

-(BOOL)isOpaque {
	return NO;
}

- (void)drawKnobSlot
{
	[[NSColor colorWithDeviceWhite:255.0/255.0 alpha:1.0] set];
	NSRectFill([self bounds]);
}

- (void)drawKnob
{
	NSRect knobRect =  NSInsetRect([self rectForPart:NSScrollerKnob], 1, 1);
	knobRect.origin.x+=2;
	knobRect.size.width-=5;
	NSBezierPath *path=[NSBezierPath bezierPathWithRoundedRect:knobRect xRadius:4 yRadius:4];
	[background drawInBezierPath:path angle:0];
}

- (void)drawRect:(NSRect)rect
{
	[self drawKnobSlot];
	[self drawKnob];
}

- (void)dealloc
{
	[background release];
	[super dealloc];
}

@end
