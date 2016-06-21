//
//  PTDrawing.m
//  tryDraw
//
//  Created by Gordon_Liu on 12/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PTDrawing.h"

@implementation PTDrawing

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        m_bezierPath = [[NSBezierPath alloc] init];
    }
    
    return self;
}

-(void)dealloc
{
    [m_bezierPath release];
    [super dealloc];
}

- (void)drawCircleWithBasePoint:(NSPoint)basePoint Radius:(float)fRadius
{
    NSBezierPath *circlePath = [NSBezierPath bezierPathWithOvalInRect:NSMakeRect(basePoint.x - fRadius, basePoint.y - fRadius, fRadius * 2, fRadius * 2)];
    [m_bezierPath appendBezierPath:circlePath];
    NSLog(@"Hua Yuan");
}

- (void)drawLineFromPoint:(NSPoint)startPoint ToPoint:(NSPoint)endPoint
{
    NSBezierPath *linePath = [[NSBezierPath alloc] init];
    [linePath moveToPoint:startPoint];
    [linePath lineToPoint:endPoint];
    [linePath closePath];
    [m_bezierPath appendBezierPath:linePath];
    [linePath release];
    NSLog(@"Hua Xian");
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    [[NSColor redColor] set];
	[m_bezierPath stroke]; 
    NSLog(@"drawRect");
}

@end
