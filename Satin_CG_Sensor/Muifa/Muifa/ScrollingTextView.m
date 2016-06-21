//
//  ScrollingTextView.m
//  TextMove
//
//  Created by Shirley on 15/1/26.
//  Copyright (c) 2015年 pegatron. All rights reserved.
//

#import "ScrollingTextView.h"

@implementation ScrollingTextView

@synthesize text = m_strText;
@synthesize speed = m_speed;


- (void) setText:(NSString *)newText
{
    m_strText = [[NSString alloc]initWithString:newText];
    m_point = NSZeroPoint;

    
    m_stringWidth = [newText sizeWithAttributes:nil].width;
    
}

- (void) setSpeed:(NSTimeInterval)newSpeed
{
    if (newSpeed != m_speed)
    {
        m_speed = newSpeed;
        
        [m_scrollTimer invalidate];
        m_scrollTimer = nil;
        if (m_speed > 0 && m_strText != nil)
        {
            m_scrollTimer = [NSTimer scheduledTimerWithTimeInterval:m_speed
                                                          target:self
                                                        selector:@selector(moveText:)
                                                        userInfo:nil
                                                         repeats:YES];
        }
    }
}

- (void) moveText:(NSTimer *)timer
{
    m_point.x = m_point.x - 1.0f;
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect
{
    if (m_point.x + m_stringWidth < 0)
    {
        m_point.x += dirtyRect.size.width;
    }
    
    NSDictionary *dicAttrs = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSFont systemFontOfSize:20], NSFontAttributeName,
                              [NSColor colorWithCalibratedRed: 0/255.0f
                                              green: 0/255.0f
                                               blue: 255/255.0f
                                              alpha: 1.0f], NSForegroundColorAttributeName,
                              nil, nil];

    
    [m_strText drawAtPoint:m_point withAttributes: dicAttrs];
    
    if (m_point.x < 0)
    {
        NSPoint otherPoint = m_point;
        otherPoint.x += dirtyRect.size.width;
        [m_strText drawAtPoint:otherPoint withAttributes: dicAttrs];
    }
    
}



@end
