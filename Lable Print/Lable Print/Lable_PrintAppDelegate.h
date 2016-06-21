//
//  Lable_PrintAppDelegate.h
//  Lable Print
//
//  Created by user on 9/25/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMSerialFramework/AMSerialPort.h"
#import "AMSerialFramework/AMSerialPortList.h"
#import "AMSerialFramework/AMSerialPortAdditions.h"
#import "controlPrinter/controlPrint.h"

@interface Lable_PrintAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    IBOutlet NSTextField *txtBatterySNShow;
    //IBOutlet NSTextField *txtSNLCDShow;
    
    NSEnumerator* PortLists;
    AMSerialPort* SerialPort;
    AMSerialPort* PortChosen;
    
}

@property (assign) IBOutlet NSWindow *window;
@property (retain) IBOutlet NSTextField *txtBatterySNShow;

-(IBAction)Print:(id)sender;
-(IBAction)Exit:(id)sender;


@end
