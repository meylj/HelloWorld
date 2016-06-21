//
//  judgePanel.h
//  Magic
//
//  Created by Leehua on 10-6-2.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "PTDrawing.h"



@interface judgePanel : NSObject
{
	IBOutlet NSWindow		*mPanel;
    IBOutlet NSTextField    *m_Title;
    IBOutlet NSButton       *m_OKButton;
    BOOL					bPassFlag;
    NSTextField				*m_InputData;
    NSMutableString			*m_SaveData;
}

@property (assign) IBOutlet NSTextField	*m_InputData;
// init and return JudgePanel object
+(id)initJudgePanel;
// create a panel with contents
-(void)beginSheetWithWindow:(NSWindow *)window
			  panelContents:(NSDictionary *)dicPanelContents;
// return a flag for Pass/Fail
- (BOOL)RUNJUDGEPANEL;
// change the flag to Pass
- (IBAction) btnPassClick:(id)sender;
// change the flag to Fail
- (IBAction) btnFailClick:(id)sender;
-(void)showMoal:(NSString*)aTitle
	ReturnValue:(NSMutableString*)aValue;
- (void)releaseJudgePanel;

@end




