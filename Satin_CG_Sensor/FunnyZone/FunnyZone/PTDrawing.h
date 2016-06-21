//
//  PTDrawing.h
//  tryDraw
//
//  Created by Gordon_Liu on 12/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//



#import <Foundation/Foundation.h>



@interface PTDrawing : NSView
{
    NSBezierPath *m_bezierPath;
}

- (void)drawCircleWithBasePoint:(NSPoint)basePoint
						 Radius:(float)fRadius;
- (void)drawLineFromPoint:(NSPoint)startPoint
				  ToPoint:(NSPoint)endPoint;

@end




