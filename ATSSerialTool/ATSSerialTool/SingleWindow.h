//
//  SingleWindow.h
//  ATSSerialTool
//
//  Created by Lorky Luo on 5/31/12.
//  Copyright 2012 Pegatron. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SerialController;

@interface SingleWindow : NSWindowController
{
	IBOutlet NSPopUpButton * btnBaudRate;
	IBOutlet NSPopUpButton * btnBits;
	IBOutlet NSPopUpButton * btnParity;
	IBOutlet NSPopUpButton * btnStopBits;
	IBOutlet NSPopUpButton * btnSerialPort;
	IBOutlet NSTextField   * textCommand;
	IBOutlet NSTextView	   * textInfo;
	IBOutlet NSTextField   * textShow;
	IBOutlet NSButton	   * btnConnect;
	IBOutlet NSButton	   * btnSend;
	IBOutlet NSButton	   * bHex;
	IBOutlet NSButton	   * bDistance;
	
	SerialController * mySerialPort;
}

- (IBAction)ModifiedParameter:(id)sender;

- (IBAction)ConnectSerialPort:(id)sender;
- (IBAction)SendCommand:(id)sender;

- (NSAttributedString *)information;
- (NSString *)bsdPath;

@end
