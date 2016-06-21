//
//  FakeAppDelegate.h
//  WebServerCenter
//
//  Created by Ken_Wu on 2014/3/22.
//  Copyright (c) 2014年 PEGATRON. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <CFNetwork/CFNetwork.h>


typedef enum
{
	SERVER_STATE_IDLE,
	SERVER_STATE_STARTING,
	SERVER_STATE_RUNNING,
	SERVER_STATE_STOPPING
} HTTPServerState;

NSString * const HTTPServerNotificationStateChanged = @"ServerNotificationStateChanged";

@interface FakeAppDelegate : NSObject <NSApplicationDelegate> {
    NSFileHandle                *listeningHandle;
	CFSocketRef                 socket;
	CFMutableDictionaryRef      incomingRequests;
	NSMutableSet                *responseHandlers;
    FSEventStreamRef            m_streamObj;
	NSMutableArray				*m_aryDataBase;
    IBOutlet NSSegmentedControl *m_ServerStatus;
    IBOutlet NSOutlineView      *m_OvDUT_Info;
    IBOutlet NSTextView         *m_txtClientInfo;
    IBOutlet NSTextView         *m_txtServerInfo;
}

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, readonly, retain) NSError *lastError;
@property (readonly, assign) HTTPServerState state;

- (IBAction)OnSwitchStatus:(id)sender;
- (IBAction)ExpandAndCollapseItem:(id)sender;
- (IBAction)AddItem:(id)sender;
- (IBAction)RemoveItem:(id)sender;

- (void)start;
- (void)stop;
- (void)stopReceivingForFileHandle:(NSFileHandle *)incomingFileHandle
                             close:(BOOL)closeFileHandle;
- (void)FindAndReplaceAt_gh_station_info;
@end
