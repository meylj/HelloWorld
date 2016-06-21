//
//  MuifaWindow.m
//  Muifa
//
//  Created by Lorky on 6/18/14.
//  Copyright (c) 2014 PEGATRON. All rights reserved.
//

#import "MuifaWindow.h"

@implementation MuifaWindow

-(void)keyDown:(NSEvent*)theEvent
{
	if(27 == [[theEvent characters] characterAtIndex:0])
		return;
	else
		return [super keyDown:theEvent];
}

@end
