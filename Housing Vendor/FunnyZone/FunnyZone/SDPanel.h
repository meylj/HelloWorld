//
//  SDPanel.h
//  FunnyZone
//
//  Created by Leehua on 7/5/12.
//  Copyright 2012 PEGATRON. All rights reserved.
//

#import <Foundation/Foundation.h>
#define SDPanelWidth 500
#define SDPanelHeight 160
#define SDLeftMargin 50

/// Test Results
enum SD_RESULT
{
	
	/// fail
	SD_FAIL = 0,
    
	/// fail
	SD_PASS,
    
	/// default
	SD_NA
	
};

@interface SDPanel : NSObject
{
    NSInteger m_iBtnCount;
    BOOL      m_bNoButton;
    enum SD_RESULT    m_enmRet;
    //BOOL      m_bFail;
    
    BOOL      m_bIsSession;
    
    NSWindow *win;
    NSModalSession          m_session;
}

@property enum SD_RESULT    m_enmRet;
@property BOOL m_bNoButton;
@property BOOL m_bIsSession;
@property NSInteger m_iBtnCount;
//@property BOOL m_bFail;

- (id)initWithParentWindow:(NSWindow *)window panelContents:(NSDictionary *)
dicPanelContents;
//one button "OK" , just close window
//two buttons "OK",  YES
- (IBAction)OK:(NSButton *)sender;
//same with OK
- (IBAction)PASS:(NSButton *)sender;
//one button , just return;
//two buttons , NO
- (IBAction)CANCEL:(NSButton *)sender;
//one button , just return;
//two buttons , NO
- (IBAction)FAIL:(NSButton *)sender;
//terminate session
- (void)TerminateSession;
@end
