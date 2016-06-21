//
//  judgePanel.m
//  Magic
//
//  Created by Leehua on 10-6-2.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//



#import "judgePanel.h"



@implementation judgePanel

@synthesize m_InputData;

static judgePanel	*cJudgePanel	= nil;

// init and return JudgePanel object
+(id)initJudgePanel
{
	if(cJudgePanel == nil)
        cJudgePanel	= [[self alloc] init];
    return cJudgePanel;	
}

-(void)showMoal:(NSString*)aTitle
	ReturnValue:(NSMutableString*)aValue
{
    if (mPanel == nil)
		[[NSBundle mainBundle]loadNibNamed:@"panel" owner:self topLevelObjects:nil];
    if ((aTitle) && ([aTitle length] > 0))
		[m_Title setStringValue:aTitle];
    m_SaveData	= aValue;
    [m_Title setHidden:NO];
    [m_InputData setHidden:NO];
    [m_OKButton setHidden:NO];
    [NSApp runModalForWindow:mPanel];
}

-(void)beginSheetWithWindow:(NSWindow*)window
			  panelContents:(NSDictionary*)dicPanelContents
{
    NSString	*szMsg		= [dicPanelContents objectForKey:@"MESSAGE"];
    NSString	*szImgName	= [dicPanelContents objectForKey:@"IMAGE"];
    NSString	*szTitle	= [dicPanelContents objectForKey:@"TITLE"];
    NSString	*szButtons	= [dicPanelContents objectForKey:@"ABUTTONS"];//Format:"Button1.Name,Button2.Name"
    NSArray		*arrButtons	= [szButtons componentsSeparatedByString:@","];
    NSString	*szPoint	= [dicPanelContents objectForKey:@"POINT"];//Format:"Point1.x,Point1.y,Point2.x,Point2.y,Radius"
    
    float	fPoint1X	= 0.0f;
    float	fPoint1Y	= 0.0f;
    float	fPoint2X	= 0.0f;
    float	fPoint2Y	= 0.0f;
    float	fRadius		= 0.0f;
    
    if (szPoint!=nil) 
    {
        NSArray	*arrPoint	= [szPoint componentsSeparatedByString:@","];
        if ([arrPoint count] != 5) //Format is wrong
        {
            NSAlert *alert = [[NSAlert alloc]init];
            alert.messageText = @"警告（Warning）";
            alert.informativeText = @"请使用正确的测试点format: Point1.x,Point1.y,Point2.x,Point2.y,Radius。(You didn't follow the Point Format\nFormat:Point1.x,Point1.y,Point2.x,Point2.y,Radius)";
            [alert addButtonWithTitle:@"确认(OK)"];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert runModal];
            [alert release];
        }
        else //Format is right
        {
            fPoint1X	= [[arrPoint objectAtIndex:0] floatValue];
            fPoint1Y	= [[arrPoint objectAtIndex:1] floatValue];
            fPoint2X	= [[arrPoint objectAtIndex:2] floatValue];
            fPoint2Y	= [[arrPoint objectAtIndex:3] floatValue];
            fRadius		= [[arrPoint objectAtIndex:4] floatValue];
        }
    }
    
    NSString	*szImgPath	= [NSString stringWithFormat:
							   @"%@/Contents/Frameworks/FunnyZone.framework/Versions/A/Resources/",
							   [[NSBundle mainBundle] bundlePath]];
	if (mPanel == nil)
        [[NSBundle mainBundle]loadNibNamed:@"panel" owner:self topLevelObjects:nil];
	
    // start the sheet (or window)
    [NSApp beginSheet:mPanel
	   modalForWindow:window
		modalDelegate:self
	   didEndSelector:nil
		  contextInfo:nil];
    [mPanel setFrame:NSMakeRect(212, 184, 600, 400)
			 display:YES];
    [mPanel setTitle:szTitle];
    NSRect	rect	= [mPanel frame];
    
    // remove views
    NSArray	*arrViews	= [NSArray arrayWithArray:[[mPanel contentView] subviews]];
    for (int i = 0; i<[arrViews count]; i++)
        [[arrViews objectAtIndex:i] removeFromSuperview];

    //add Buttons
    if (1 == [arrButtons count]
		&& [[arrButtons objectAtIndex:0] isEqualToString:@" "])
		;
    else if (1 == [arrButtons count]) 
    {
        NSButton	*btnYes	= [[NSButton alloc] initWithFrame:NSMakeRect((rect.size.width - 100)/2, 5, 100, 50)];
        [btnYes setTarget:self];
        [btnYes setTitle:[arrButtons objectAtIndex:0]];
        [btnYes setBezelStyle:NSRoundedBezelStyle];
        [btnYes setKeyEquivalent:@"\r"];
        [btnYes setAction:@selector(btnPassClick:)];
        [[mPanel contentView] addSubview:btnYes];
        [btnYes release];
    }
    else if(2 == [arrButtons count])
    {
        NSButton	*btnPass	= [[NSButton alloc] initWithFrame:NSMakeRect((rect.size.width - 300)/2, 5, 100, 50)];
        [btnPass setTarget:self];
        [btnPass setTitle:[arrButtons objectAtIndex:0]];
        [btnPass setBezelStyle:NSRoundedBezelStyle];
        [btnPass setAction:@selector(btnPassClick:)];
        [[mPanel contentView] addSubview:btnPass];
        [btnPass release];
        
        NSButton	*btnFail	= [[NSButton alloc] initWithFrame:NSMakeRect((rect.size.width + 100)/2, 5, 100, 50)];
        [btnFail setTarget:self];
        [btnFail setTitle:[arrButtons objectAtIndex:1]];
        [btnFail setBezelStyle:NSRoundedBezelStyle];
        [btnFail setAction:@selector(btnFailClick:)];
        [[mPanel contentView] addSubview:btnFail];
        [btnFail release];
    }
    
    //add ImageView
    if (szImgName != nil) 
    {
        NSImageView	*imageView	= [[NSImageView alloc] initWithFrame:NSMakeRect(5, 100, 590, 280)];
        NSImage		*image		= [[NSImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@%@",szImgPath,szImgName]];
        [imageView setTarget:self];
        [imageView setImage:image];
        [[mPanel contentView] addSubview:imageView];
        [image release];
        [imageView release];
    }    
    else
        [mPanel setFrame:NSMakeRect(212, 184, 600, 200) display:YES];
    
    //add Drawing above ImageView
    if (szImgName != nil && szPoint != nil)
    {
        PTDrawing	*objDrawing	= [[PTDrawing alloc] initWithFrame:NSMakeRect(5, 100, 590, 280)];
        // draw a circle
        [objDrawing drawCircleWithBasePoint:NSMakePoint(fPoint1X, fPoint1Y) Radius:fRadius];
        // draw a circle
        [objDrawing drawCircleWithBasePoint:NSMakePoint(fPoint2X, fPoint2Y) Radius:fRadius];
        [[mPanel contentView] addSubview:objDrawing];
        [objDrawing release];
    }
    
    //add TextView
    if (szImgName != nil) 
    {
        NSTextView	*txtMessage	= [[NSTextView alloc] initWithFrame:NSMakeRect(5, 60, 590, 35)];
        [txtMessage setString:szMsg];
        [txtMessage setBackgroundColor:nil];
        [[mPanel contentView] addSubview:txtMessage];
        [txtMessage release];
    }
    else
    {
        NSTextView	*txtMessage	= [[NSTextView alloc] initWithFrame:NSMakeRect(5, 60, 590, 100)];
        [txtMessage setString:szMsg];
        [txtMessage setBackgroundColor:nil];
        [[mPanel contentView] addSubview:txtMessage];
        [txtMessage release];
    }
    
	[NSApp runModalForWindow:mPanel];
	[NSApp endSheet:mPanel];
	[mPanel orderOut:nil];
}

// return a flag for Pass/Fail
- (BOOL)RUNJUDGEPANEL
{
	return bPassFlag;
}

// change the flag to Pass
-(IBAction)btnPassClick:(id)sender
{
	if([m_InputData floatValue] == 0.0f)
	{
        NSAlert *alert = [[NSAlert alloc]init];
        alert.messageText = @"警告（Warning）";
        alert.informativeText = @"请输入电流。(Please input the current!)";
        [alert addButtonWithTitle:@"确认(OK)"];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
        [alert release];
		return;
	}
	bPassFlag	= YES;
    [m_SaveData setString:[m_InputData stringValue]];
	[NSApp stopModalWithCode:NO];
	[mPanel orderOut:nil];
}

// change the flag to Fail
- (IBAction)btnFailClick:(id)sender
{
	bPassFlag	= NO;
	[NSApp stopModalWithCode:NO];
	[mPanel orderOut:nil];
}

- (void)releaseJudgePanel
{
    [cJudgePanel release];
    cJudgePanel	= nil;
}

@end
