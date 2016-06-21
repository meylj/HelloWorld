//
//  SDPanel.m
//  FunnyZone
//
//  Created by Leehua on 7/5/12.
//  Copyright 2012 PEGATRON. All rights reserved.
//



#import "SDPanel.h"



// Global Vars
BOOL g_bShowMessageBox = YES;



@implementation SDPanel

@synthesize m_enmRet;
@synthesize m_bNoButton;
@synthesize m_bIsSession;
@synthesize m_iBtnCount;

-(id)init
{
    if ((self = [super init]))
	{
		
    }
    
    return self;
}

-(id)initWithParentWindow:(NSWindow *)window
			panelContents:(NSDictionary*)dicPanelContents
{
    self	= [super init];
    if (self)
	{
        m_enmRet		= SD_NA;
        m_bNoButton		= NO;
        
        m_bIsSession	= NO;
        
        //get window location and width and length
        NSString	*szRect		= [dicPanelContents objectForKey:@"WIN_ORIGIN"];//@"50,20+variable"
        NSArray		*aryNumbers	= [szRect componentsSeparatedByString:@","]; 
        if ([aryNumbers count]<2) 
        {
            NSAlert *alert = [[NSAlert alloc]init];
            alert.messageText = @"警告(Warning)";
            alert.informativeText = @"请为窗口设定正确的初始化位置。(Please set correct window location!)";
            [alert addButtonWithTitle:@"噢(OK)"];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert runModal];
            [alert release];
            return nil;//must larger than 3
        }
        CGFloat				fOriginX			= [[aryNumbers objectAtIndex:0] floatValue];//location.x
        CGFloat				fOriginY			= [[aryNumbers objectAtIndex:1] floatValue];//location.y
        
        //Create window
        NSRect				rc					= NSMakeRect(fOriginX,
															 fOriginY,
															 SDPanelWidth,
															 SDPanelHeight); //win width:350 ; win height:150
        NSUInteger			uiStyle				= NSTitledWindowMask;      
        NSBackingStoreType	backingStoreStyle	= NSBackingStoreBuffered;      
        win	= [[NSWindow alloc] initWithContentRect:rc
										  styleMask:uiStyle
											backing:backingStoreStyle
											  defer:NO];
        
        //set window title
        NSString	*szTitle	= [dicPanelContents objectForKey:@"TITLE"];
        if (!szTitle)
            szTitle	= @"You didn't set TITLE in script file";
        [win setTitle:szTitle];
        
        //add image view
        NSString	*szImgPath	= [NSString stringWithFormat:
								   @"%@/Contents/Resources/Muifa.icns",
								   [[NSBundle mainBundle] bundlePath]];
        NSImage		*image		= [[[NSImage alloc] initWithContentsOfFile:szImgPath] autorelease];
        NSImageView	*imageView	= [[NSImageView alloc] initWithFrame:NSMakeRect(20, 30, 120, 120)];
        [imageView setImage:image];
        [[win contentView] addSubview:imageView];
        [imageView release];
        
        //add mseesage
        NSString	*szMsg		= [dicPanelContents objectForKey:@"MESSAGE"];
        NSTextField	*txtMessage	= [[NSTextField alloc] initWithFrame:NSMakeRect(150,
																				50,
																				SDPanelWidth-140-20,
																				SDPanelHeight-15-50)];
        [txtMessage setStringValue:szMsg];
        [txtMessage setBordered:NO];
		[txtMessage setEditable:NO];
		[txtMessage setBackgroundColor:[NSColor clearColor]];
		
        [[win contentView] addSubview:txtMessage];
        [txtMessage release];
        
        //add buttons        
        NSString	*szButtons	= [dicPanelContents objectForKey:@"ABUTTONS"];
        NSArray		*arrButtons	= [szButtons componentsSeparatedByString:@","];
        m_iBtnCount	= [arrButtons count];
        m_bNoButton	= ((m_iBtnCount == 0) ? YES : NO);
        for (NSInteger iIndex = 0; iIndex<m_iBtnCount; iIndex++)
        {
			NSString *szBtnTitle = [arrButtons objectAtIndex:iIndex];
			if ([szBtnTitle isEqualToString:@""] || [szBtnTitle isEqualToString:@" "])
			{
                if (m_iBtnCount <= 1)
                {
                    m_bNoButton = YES;
                    break;
                }
                else
                {
                    NSAlert *alert = [[NSAlert alloc]init];
                    alert.messageText = @"警告(Warning)";
                    alert.informativeText = @"请在剧本档中设置正确的按键名称。(Please set correct button title in script file!)";
                    [alert addButtonWithTitle:@"噢(OK)"];
                    [alert setAlertStyle:NSWarningAlertStyle];
                    [alert runModal];
                    [alert release];
                    return nil;
                }
			}
            NSButton	*btn	= [[NSButton alloc] initWithFrame:NSMakeRect(170+(70+20)*iIndex, 20, 70, 20)];
            
            [btn setTitle:szBtnTitle];
            SEL	selectorForFunction	= NSSelectorFromString([NSString stringWithFormat:@"%@:",szBtnTitle]);
            [btn setTarget:self];
            [btn setAction:selectorForFunction];
            [[win contentView] addSubview:btn];
            [btn release];
        }
        
        //set background color
        NSColor	*colr	= [dicPanelContents objectForKey:@"BACK_COLOR"];
        if (colr)
            [win setBackgroundColor:colr];
        
        //show window
		for(;;)
			if(g_bShowMessageBox)
				break;
			else
				sleep(1);

		g_bShowMessageBox	= NO;
        [win makeKeyAndOrderFront:nil];
        g_bShowMessageBox	= YES;
        m_bIsSession	= [[dicPanelContents objectForKey:@"SESSION"] boolValue];
        if (m_bNoButton || m_bIsSession) 
        {
            m_session	= [NSApp beginModalSessionForWindow:win];
            [NSApp runModalSession:m_session];
        }
        else
        {
            //wait for user operation    
            [NSApp runModalForWindow:win];
            //after operation , close window
            [NSApp endSheet:win];
			if (win)
			{
				[win orderOut:nil];
				//release window
				[win release];
				win	= nil;
			}
        }
    }
    return self;
}

-(void)TerminateSession
{
    [NSApp endModalSession:m_session];
    [NSApp endSheet:win];
	if (win) 
	{
		[win orderOut:nil];
		[win release];
		win	= nil;
	}
}

//one button "OK" , just close window
//two buttons "OK",  YES
- (IBAction)OK:(NSButton *)sender
{
    if (m_bIsSession) 
    {
        m_enmRet	= SD_PASS;
        return;
    }
    switch (m_iBtnCount) 
    {
        case 0:            
            return;
        case 1:
            break;
        case 2:
            m_enmRet	= SD_PASS;            
            break;
        default:
            break;
    }
    [NSApp stopModalWithCode:NO];
}

//same with OK
-(IBAction)PASS:(NSButton*)sender
{
    if(m_bIsSession) 
    {
        m_enmRet	= SD_PASS;
        return;
    }
    switch (m_iBtnCount) 
    {
        case 0:            
            return;
        case 1:
            break;
        case 2:
            m_enmRet	= SD_PASS;
            break;
        default:
            break;
    }
    [NSApp stopModalWithCode:NO];
}

//one button , just return;
//two buttons , NO
-(IBAction)CANCEL:(NSButton*)sender
{
    if (m_bIsSession) 
    {
        m_enmRet	= SD_FAIL;
        return;
    }
    switch (m_iBtnCount) 
    {
        case 0:            
            return;
        case 1:
            break;
        case 2:
            m_enmRet	= SD_FAIL;
            break;
        default:
            break;
    }
    [NSApp stopModalWithCode:NO];
}

//one button , just return;
//two buttons , NO
-(IBAction)FAIL:(NSButton*)sender
{
    if (m_bIsSession) 
    {
        m_enmRet	= SD_FAIL;
        return;
    }
    switch (m_iBtnCount) 
    {
        case 0:            
            return;
        case 1:
            m_enmRet	= SD_FAIL;
            break;
        case 2:
            m_enmRet	= SD_FAIL;
            break;
        default:
            break;
    }
    [NSApp stopModalWithCode:NO];
}

- (void)dealloc
{
    [super dealloc];
}

@end




