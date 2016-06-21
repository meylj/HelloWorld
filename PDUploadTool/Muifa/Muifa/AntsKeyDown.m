//
//  AntsKeyDown.m
//  Muifa
//
//  Created by Gordon_Liu on 7/28/12.
//  Copyright 2012 PEGATRON. All rights reserved.
//

#import "AntsKeyDown.h"
NSString * const BNRKeyBoardPressedNotification = @"KeyBoardPressed";


@implementation AntsKeyDown

//@synthesize m_iTesting;
//@synthesize m_iPopWindow;
//@synthesize x;
//@synthesize y;
//@synthesize m_bNormalMode;
//
//- (id)init
//{
//    self = [super init];
//    if (self)
//    {
//        // Initialization code here.
//        
//        
//        
//        
//    }
//    
//    return self;
//}
//
//-(id)initWithCoder:(NSCoder *)aDecoder
//{
//    self = [super initWithCoder:aDecoder];
//    if (self)
//    {
//        // Initialization code here.
//        
//        m_iTesting = 0;
//        x=0;
//        y=0;
//        
//        m_iPopWindow = 0;
//        m_bNormalMode = YES;
//        
//    }
//    
//    return self;
//}

- (BOOL)acceptsFirstResponder
{
    
    return YES;
}

//- (void)mouseExited:(NSEvent *)theEvent
//{
//    if(m_bNormalMode)
//    {
//        if((m_iTesting > 0) && (m_iPopWindow == 0))
//        {
//            [NSApp activateIgnoringOtherApps:YES];
//            CGPoint point = {x, y};
//            CGEventRef mouseMoved = CGEventCreateMouseEvent(NULL, kCGEventMouseMoved, point, NULL);
//            CGEventPost(kCGHIDEventTap, mouseMoved);
//            
//            CFRelease(mouseMoved);
//        }
//    }
//}

- (void)keyDown:(NSEvent *)theEvent
{
    //NSRunAlertPanel(@"INFO", @"KeyCode=%@ Pressed", @"OK", nil, nil, [NSString stringWithFormat:@"%i", [theEvent keyCode]]);
    NSString *szKeyCode = [NSString stringWithFormat:@"%i", [theEvent keyCode]];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:BNRKeyBoardPressedNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:szKeyCode, @"KeyCode", nil]];
}

//- (void) createTrackingArea
//{
//    NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:[self frame]
//                                                                options: (NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveInKeyWindow | NSTrackingActiveAlways)
//                                                                  owner:self
//                                                               userInfo:nil];
//    [self addTrackingArea:trackingArea];
//    
//}
@end
