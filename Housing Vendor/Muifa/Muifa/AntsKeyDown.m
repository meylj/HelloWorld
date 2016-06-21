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

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)keyDown:(NSEvent *)theEvent
{
    //NSRunAlertPanel(@"INFO", @"KeyCode=%@ Pressed", @"OK", nil, nil, [NSString stringWithFormat:@"%i", [theEvent keyCode]]);
    NSString *szKeyCode = [NSString stringWithFormat:@"%i", [theEvent keyCode]];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:BNRKeyBoardPressedNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:szKeyCode, @"KeyCode", nil]];
}

@end
