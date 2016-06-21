//
//  RCTAppDelegate.h
//  RenameCableTool
//
//  Created by raniys on 2/10/14.
//  Copyright (c) 2014 raniys. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RCTControlPort.h"
//#import "RCTRunCommand.h"

@interface RCTAppDelegate : NSObject <NSApplicationDelegate>
{
    RCTControlPort          *controlPort;
    const char              *m_CurrentUser;
    NSMutableArray          *m_aryPortPath;
    Boolean                 m_bJudge;       //judges cable connected
    NSString                *m_strTaskResponse;
    
    IBOutlet NSTextField    *m_textNewName;
    IBOutlet NSTextField    *m_textUserName;
    IBOutlet NSTextField    *m_textOldName;
    IBOutlet NSTextField    *m_textPassword;
    
    IBOutlet NSTextView     *m_textLog;
    IBOutlet NSPopUpButton  *m_popOldName;

}

@property (assign) IBOutlet NSWindow *window;

//connect to cable
- (IBAction)connectCable:(id)sender;
//change the cable name
- (IBAction)changeCableName:(id)sender;

//- (BOOL)runCommand:(NSString *)commandToRun;
- (BOOL)runTaskPath:(NSString *)path
	  withArguments:(NSArray *)arguments
		 AndCommand:(NSString *)command
			  Error:(NSString *)error;
//- (NSString *)doshellscript:(NSString *)cmd_launch_path theCommand:(NSString *)first_cmd_pt;
//- (NSString *)mount_idisk:(NSString *)mac_username;
@end
