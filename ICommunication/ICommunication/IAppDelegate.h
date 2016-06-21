//
//  IAppDelegate.h
//  ICommunication
//
//  Created by chenchao on 13-11-29.
//  Copyright (c) 2013年 chenchao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/ioctl.h>
#include <sys/errno.h>
#include <sys/sockio.h>
#include <net/if.h>

@interface IAppDelegate : NSObject <NSApplicationDelegate>
{
    NSMutableArray  *m_arrCells;
    IBOutlet NSCollectionView   *m_iCollectionView;
    IBOutlet    NSButton    *m_btnSend;
    IBOutlet    NSButton    *m_btnListen;
    
    IBOutlet    NSTextField    *m_txtSendIP;
    IBOutlet    NSTextField    *m_txtSendPort;
    IBOutlet    NSTextField    *m_txtSendMessage;
    IBOutlet    NSTextField    *m_txtListenPort;
    
    
    int m_iListenPort;
    NSMutableString *m_strSendIP;
    int m_iSendPort;

}

@property (assign) IBOutlet NSWindow *window;
@property (assign) NSMutableArray   *cells;

- (IBAction)btnSend:(id)sender;
- (IBAction)btnListen:(id)sender;
@end
