//
//  AppDelegate.m
//  SearchErrorResponseLog
//
//  Created by 张斌 on 14-8-21.
//  Copyright (c) 2014年 张斌. All rights reserved.
//

#import "AppDelegate.h"
#import "ParseFile.h"

@implementation AppDelegate


- (id)init
{
    self = [super init];
    if (self) {
        self.m_szDiretory = @"";
        self.m_szMoveDir = @"/vault/parse";
        self.m_dicDescription = [[NSMutableDictionary alloc] init];
    }
    return self;
}
- (void)dealloc
{
    [self.m_dicDescription release]; self.m_dicDescription = nil;
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    NSString *toolName = @"SearchErrorResponseLog";
    NSString * m_strToolVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *strInfo = [NSString stringWithFormat:@"%@ %@",toolName,m_strToolVersion];
    [_window setTitle:strInfo];
    
    [m_process setHidden:YES];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(ParseOK:) name:@"OK" object:nil];
    
}
-(void)ParseOK:(NSNotification *)note
{
    [m_process stopAnimation:self];
    [m_process setHidden:YES];
    [m_btnParse setEnabled:YES];
    [m_tableView reloadData];
}

-(void)ParseFileThread
{
    ParseFile * parseFile = [[ParseFile alloc] init];
    parseFile.m_szMovePath = self.m_szMoveDir;
    parseFile.m_szDiretory = self.m_szDiretory;
    NSArray * aryPath = [parseFile FindDiretory:self.m_szDiretory];
    self.m_dicDescription = [NSMutableDictionary dictionaryWithDictionary:[parseFile ParseAndMoveFile:aryPath]];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"OK" object:self];
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return  YES;
}

-(IBAction)ParseLogFile:(id)sender
{
    if([self.m_szDiretory isEqualToString:@""])
    {
        NSRunAlertPanel(@"warning", @"please add Log diretory", @"OK", nil, nil);
        return;
    }
    else
    {
        NSFileManager * filemanger = [NSFileManager defaultManager];
        if(![filemanger fileExistsAtPath:self.m_szDiretory])
        {
            NSRunAlertPanel(@"warning", @"Please add  correct Log diretory", @"OK", nil,  nil);
            return;
        }
    }
    
    [m_process setHidden:NO];
    [m_process startAnimation:self];
    [m_btnParse setEnabled:NO];
    
    [NSThread detachNewThreadSelector:@selector(ParseFileThread) toTarget:self withObject:nil];
    
}
-(IBAction)AddDiretory:(id)sender
{
    NSOpenPanel     * newCSVPanel = [NSOpenPanel openPanel];
    [newCSVPanel setCanChooseFiles:NO];
    [newCSVPanel setCanChooseDirectories:YES];
   // [newCSVPanel setAllowedFileTypes:[NSArray arrayWithObjects:@"csv",nil]];
    if([newCSVPanel runModal] == NSOKButton)
    {
        NSArray  * aryPath = [newCSVPanel URLs];
        //delete "file://localhost" and avoid name of file in diretory have sapce
        self.m_szDiretory = [[[[aryPath objectAtIndex:0] absoluteString] substringFromIndex:16]stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
        
        [m_textDiretory setStringValue:self.m_szDiretory];
    }

}
-(IBAction)MoveDiretory:(id)sender
{
    NSOpenPanel     * oldCSVPanel = [NSOpenPanel openPanel];
    [oldCSVPanel setCanChooseFiles:NO];
    [oldCSVPanel setCanChooseDirectories:YES];
    if([oldCSVPanel runModal] == NSOKButton)
    {
        NSArray  * aryPath = [oldCSVPanel URLs];
        //delete "file://localhost" and avoid name of file in diretory have sapce
        self.m_szMoveDir = [[[[aryPath objectAtIndex:0] absoluteString] substringFromIndex:16] stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
        [m_textMoveDir setStringValue:self.m_szMoveDir];
        
    }

}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [[self.m_dicDescription allKeys] count];
}

/* This method is required for the "Cell Based" TableView, and is optional for the "View Based" TableView. If implemented in the latter case, the value will be set to the view at a given row/column if the view responds to -setObjectValue: (such as NSControl and NSTableCellView).
 */
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString * szIdentifier = [tableColumn identifier];
    
    if([szIdentifier isEqualToString:@"SN"])
    {
        return [[self.m_dicDescription allKeys] objectAtIndex:row];
    }
    else if([szIdentifier isEqualToString:@"Description"])
    {
        return [self.m_dicDescription objectForKey:[[self.m_dicDescription allKeys] objectAtIndex:row]];
    }
    
    return nil;
}

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    NSString * szReturn = [self.m_dicDescription objectForKey:[[self.m_dicDescription allKeys] objectAtIndex:row]];
    
    NSUInteger count = [[szReturn componentsSeparatedByString:@"\n"] count];
    
    return count*20;
    
}



@end
