//
//  LFTextView.m
//  OverlayHelper
//
//  Created by Lorky on 2/2/15.
//  Copyright (c) 2015 Lorky. All rights reserved.
//

#import "LFTextView.h"

@implementation LFTextView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)keyDown:(NSEvent *)theEvent
{
	if(13 == [[theEvent characters] characterAtIndex:0]) // enter event
	{
		self.string = [NSString stringWithFormat:@"%@\n - ",self.string];
		return;
	}
	else
		return [super keyDown:theEvent];
}


@end
