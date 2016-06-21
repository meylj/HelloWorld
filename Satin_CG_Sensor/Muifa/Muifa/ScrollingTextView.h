//
//  ScrollingTextView.h
//  TextMove
//
//  Created by Shirley on 15/1/26.
//  Copyright (c) 2015年 pegatron. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ScrollingTextView : NSView
{
    NSTimer         *m_scrollTimer;
    NSPoint         m_point;
    NSString        *m_strText;
    CGFloat         m_stringWidth;
    NSTimeInterval  m_speed;
}



@property (nonatomic, copy) NSString *text;
@property (nonatomic) NSTimeInterval speed;



@end
