//
//  RCTAppDelegate.m
//  RenameCableTool
//
//  Created by raniys on 2/10/14.
//  Copyright (c) 2014 raniys. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "RCTAppDelegate.h"
#import "NSStringCategory.h"

#define RCTLoadVCP				@"LoadVCP"
#define RCTUnloadVCP            @"UnloadVCP"
#define RCTInstallD2XX          @"InstallD2XX"
#define RCTCreateLib            @"CreateLib"


@implementation RCTAppDelegate
@dynamic window;
-(id)init
{
    if (self = [super init])
    {
        m_bJudge                = NO;
        controlPort             = [[RCTControlPort alloc] init];
        m_aryPortPath           = [[NSMutableArray alloc] init];
        m_CurrentUser           = [[NSString stringWithFormat:@"%@",NSFullUserName()]UTF8String];
    }
    return self;
}

- (void)dealloc
{
    [controlPort    release];
    [m_aryPortPath  release];
    [m_strTaskResponse release];
    [super dealloc];
}

-(void)awakeFromNib
{
    if ([[m_textUserName stringValue] isEqualTo:@""])
        [m_textUserName setStringValue: [NSString stringWithUTF8String:m_CurrentUser]];
    [m_textUserName setEditable:NO];
    [m_textLog setEditable:NO];
    
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{ 
    // Insert code here to initialize your application
}



#pragma mark - connect to cable

- (IBAction)connectCable:(id)sender
{
    NSColor	*color	= [NSColor lightGrayColor];
    NSDictionary	*dict	= [NSDictionary dictionaryWithObject:color
                                                     forKey:NSForegroundColorAttributeName];
    NSAttributedString* attr = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@: Connection Starting...\n\n",[self CurrentTime]]
                                                                attributes:dict] autorelease];
    
    [[m_textLog textStorage] appendAttributedString:attr];
    [m_textLog scrollRangeToVisible:NSMakeRange([[m_textLog string] length], 0)];
    //start to connect
    m_bJudge  = [[self connectToCable] boolValue];
    //judge status of connect cable
    if (m_bJudge == YES)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSColor	*color1	= [NSColor greenColor];
            NSColor *color2 = [NSColor lightGrayColor];
            NSDictionary	*dict	= [NSDictionary dictionaryWithObject:color1
                                                             forKey:NSForegroundColorAttributeName];
            NSDictionary    *dict2  = [NSDictionary dictionaryWithObject:color2
                                                                  forKey:NSForegroundColorAttributeName];
            NSAttributedString* attr    = [[[NSAttributedString alloc] initWithString:@"Connect cable OK!\n"
                                                                           attributes:dict] autorelease];
            NSAttributedString* attr2   = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@: Connection End!\n\n",[self CurrentTime]]
                                                                           attributes:dict2] autorelease];
            [[m_textLog textStorage] appendAttributedString:attr];
            [[m_textLog textStorage] appendAttributedString:attr2];
            [m_textLog scrollRangeToVisible:NSMakeRange([[m_textLog string] length], 0)];
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSColor	*color1	= [NSColor redColor];
            NSColor *color2 = [NSColor lightGrayColor];
            NSDictionary	*dict	= [NSDictionary dictionaryWithObject:color1
                                                             forKey:NSForegroundColorAttributeName];
            NSDictionary    *dict2  = [NSDictionary dictionaryWithObject:color2
                                                                  forKey:NSForegroundColorAttributeName];
            NSAttributedString* attr    = [[[NSAttributedString alloc] initWithString:@"error: Connect cable is failed, please check!\n"
                                                                           attributes:dict] autorelease];
            NSAttributedString* attr2   = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@: Connection End!\n\n",[self CurrentTime]]
                                                                           attributes:dict2] autorelease];
            [[m_textLog textStorage] appendAttributedString:attr];
            [[m_textLog textStorage] appendAttributedString:attr2];
            [m_textLog scrollRangeToVisible:NSMakeRange([[m_textLog string] length], 0)];
        });
    }
}



- (NSNumber *)connectToCable
{
    int iPathCount;
    NSMutableString *strSerialPath  = [[NSMutableString alloc]init];
    //load VCP
    BOOL bLoadVCP = NO;
//    bLoadVCP      =[self runTaskPath:@"/usr/bin/sudo"
//					  withArguments:@[@"kextunload", @"/System/Library/Extensions/FTDIUSBSerialDriver.kext"]
//						 AndCommand:nil
//							  Error:nil];
    
//    NSString * strReloadScript = [[NSBundle mainBundle] pathForResource:@"ReloadTest" ofType:@"scpt"];
//	NSAppleScript * appReloadScript = [[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:strReloadScript] error:nil];
//	[appReloadScript executeAndReturnError:NULL];
//	[appReloadScript release];
    if([[m_textPassword stringValue] isEqualToString:@""]
       || [[m_textUserName stringValue] isEqualToString:@""])
    {
        NSLog(@"Warning: Account or Password is empty!");
        dispatch_async(dispatch_get_main_queue(), ^{
            NSColor	*color	= [NSColor redColor];
            NSDictionary	*dict	= [NSDictionary dictionaryWithObject:color
                                                             forKey:NSForegroundColorAttributeName];
            NSAttributedString* attr = [[[NSAttributedString alloc] initWithString:@"error: Account or Password is empty!\n"
                                                                        attributes:dict] autorelease];
            
            [[m_textLog textStorage] appendAttributedString:attr];
            [m_textLog scrollRangeToVisible:NSMakeRange([[m_textLog string] length], 0)];
        });
        
        NSRunAlertPanel(@"警告(Warning)!",
    					@"請輸入具有管理員權限的帳號和密碼。(Please enter an account and password, the account must has administrate permission for this computer.)",
                        @"确认（OK）", nil, nil);
        return [NSNumber numberWithBool:NO];
    }
    bLoadVCP    = [self runAppleScript:RCTUnloadVCP];
    bLoadVCP    &= [self runAppleScript:RCTLoadVCP];
    sleep(1);
    if (bLoadVCP)
    {
        NSLog(@"load VCP ok!");
    }
    else
    {
        NSLog(@"Warning: Load FTDI driver failed!");
        NSRunAlertPanel(@"警告(Warning)!",
    					@"请先安裝usb驅動程序。(Please install FTDI driver first.)",
                        @"确认（OK）", nil, nil);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSColor	*color	= [NSColor redColor];
            NSDictionary	*dict	= [NSDictionary dictionaryWithObject:color
                                                             forKey:NSForegroundColorAttributeName];
            NSAttributedString* attr = [[[[NSAttributedString alloc] initWithString:@"error: Load FTDI driver failed!\n"
                                          attributes: dict] autorelease] autorelease];
            
            [[m_textLog textStorage] appendAttributedString:attr];
            [m_textLog scrollRangeToVisible:NSMakeRange([[m_textLog string] length], 0)];
        });
        [strSerialPath  release];
        return [NSNumber numberWithBool:bLoadVCP];
    }
    
    //find the port
    NSArray *aryPorts   = nil;
    if ([self runTaskPath:[NSString stringWithFormat:@"%@/ftdimv", [[NSBundle mainBundle] resourcePath]]
            withArguments:nil
               AndCommand:nil
                    Error:nil])
    {
//        NSLog(@"%@",m_strTaskResponse);
        m_strTaskResponse = [m_strTaskResponse SubFrom:@"List of FTDI devices on system:" include:NO];
        aryPorts = [m_strTaskResponse componentsSeparatedByString:@"Device "];
    }
    NSMutableArray *arrSerialPort  = [[NSMutableArray alloc]initWithArray:[RCTControlPort SearchSerialPorts]];
    NSLog(@"arrSerialPort=%@", arrSerialPort);
    if ([aryPorts count] > 0)
    {
        [arrSerialPort removeAllObjects];
        for (int i = 1; i < [aryPorts count]; i++)
        {
            NSString *buffer = [[[aryPorts objectAtIndex:i]SubFrom:@"Serial Number - " include:NO]SubTo:@"\n" include:NO];
            [arrSerialPort insertObject:[NSString stringWithFormat:@"/dev/cu.usbserial-%@",buffer] atIndex:i-1];
        }
    }
    NSLog(@"arrSerialPort=%@", arrSerialPort);
    iPathCount = (int)[arrSerialPort count];
    if (!arrSerialPort || iPathCount == 0)
    {
        NSLog(@"Warning: FTDI cable not found!");
        dispatch_async(dispatch_get_main_queue(), ^{
            NSColor	*color	= [NSColor redColor];
            NSDictionary	*dict	= [NSDictionary dictionaryWithObject:color
                                                             forKey:NSForegroundColorAttributeName];
            NSAttributedString* attr = [[[NSAttributedString alloc] initWithString:@"error: FTDI cable not found!\n"
                                         attributes:dict] autorelease];
            
            [[m_textLog textStorage] appendAttributedString:attr];
            [m_textLog scrollRangeToVisible:NSMakeRange([[m_textLog string] length], 0)];
        });
        
        NSRunAlertPanel(@"警告(Warning)!",
						@"请确认FTDI cable已连接OK。(Please confirm if the FTDI cable already connected.)",
						@"确认（OK）", nil, nil);
        [strSerialPath  release]; strSerialPath = nil;
        [arrSerialPort release]; arrSerialPort = nil;
        return [NSNumber numberWithBool:NO];
    }
    else
    {
        [m_aryPortPath  removeAllObjects];
        [m_popOldName   removeAllItems];
        [m_aryPortPath  addObjectsFromArray:arrSerialPort];
        for (int i = 0; i < iPathCount; i++)
        {
            [strSerialPath appendString:[NSString stringWithFormat:@"%@\r", [m_aryPortPath objectAtIndex:i]]];
//            [[m_textLog textStorage] insertAttributedString:[[[NSAttributedString alloc]
//                                                              initWithString:[NSString stringWithFormat:@"%@\r",strSerialPath]] autorelease]
//                                                    atIndex:[[m_textLog string] length]];
            [m_popOldName addItemWithTitle:[m_aryPortPath objectAtIndex:i]];
        }
        //insert cable path to TextView
        dispatch_async(dispatch_get_main_queue(), ^{
            NSColor	*color	= [NSColor blueColor];
            NSDictionary	*dict	= [NSDictionary dictionaryWithObject:color
                                                             forKey:NSForegroundColorAttributeName];
            NSAttributedString* attr = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",strSerialPath]
                                                                        attributes:dict] autorelease];
            
            [[m_textLog textStorage] appendAttributedString:attr];
            [m_textLog scrollRangeToVisible:NSMakeRange([[m_textLog string] length], 0)];
        });
//        NSLog(@"The path is: %@", m_aryPortPath);
        [strSerialPath  release]; strSerialPath = nil;
        [arrSerialPort release]; arrSerialPort = nil;
        return [NSNumber numberWithBool:YES];
    }
}



#pragma mark - change cable name
- (IBAction)changeCableName:(id)sender
{
    [m_textUserName setEditable: NO];
    [m_textPassword setEditable: NO];
    Boolean bCommandResult = NO;
    //Starting to change cable name
    NSColor	*color	= [NSColor lightGrayColor];
    NSDictionary	*dict	= [NSDictionary dictionaryWithObject:color
                                                     forKey:NSForegroundColorAttributeName];
    NSAttributedString* attr = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@: Starting to change...\n\n", [self CurrentTime]]
                                                                attributes:dict] autorelease];
    
    [[m_textLog textStorage] appendAttributedString:attr];
    [m_textLog scrollRangeToVisible:NSMakeRange([[m_textLog string] length], 0)];
    
    bCommandResult = [[self runChangeCableName] boolValue];
    //Judge status of the change cable name
    if (bCommandResult)
    {
        [self connectToCable]; //reconnect to cable
        NSLog(@"Run command OK!");
//        [[[m_textLog textStorage] mutableString] appendString: @"\nChange cable name OK!\n\n"];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSColor	*color1	= [NSColor greenColor];
            NSColor *color2 = [NSColor lightGrayColor];
            NSDictionary	*dict	= [NSDictionary dictionaryWithObject:color1
                                                             forKey:NSForegroundColorAttributeName];
            NSDictionary    *dict2  = [NSDictionary dictionaryWithObject:color2
                                                                  forKey:NSForegroundColorAttributeName];
            NSAttributedString* attr    = [[[NSAttributedString alloc] initWithString:@"Change cable name OK!\n"
                                                                           attributes:dict] autorelease];
            NSAttributedString* attr2   = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@: Changing End!\n\n\n\n",[self CurrentTime]]
                                                                           attributes:dict2] autorelease];
            [[m_textLog textStorage] appendAttributedString:attr];
            [[m_textLog textStorage] appendAttributedString:attr2];
            [m_textLog scrollRangeToVisible:NSMakeRange([[m_textLog string] length], 0)];
        });
//        sleep(1);
        [m_textNewName setStringValue:@""];
    }
    else
    {
        NSLog(@"Running error, please check!");
        dispatch_async(dispatch_get_main_queue(), ^{
            NSColor	*color1	= [NSColor redColor];
            NSColor *color2 = [NSColor lightGrayColor];
            NSDictionary	*dict	= [NSDictionary dictionaryWithObject:color1
                                                             forKey:NSForegroundColorAttributeName];
            NSDictionary    *dict2  = [NSDictionary dictionaryWithObject:color2
                                                                  forKey:NSForegroundColorAttributeName];
            NSAttributedString* attr    = [[[NSAttributedString alloc] initWithString:@"error: Change cable name failed, please check!\n"
                                                                           attributes:dict] autorelease];
            NSAttributedString* attr2   = [[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@: Changing End!\n\n\n\n",[self CurrentTime]]
                                                                           attributes:dict2] autorelease];
            [[m_textLog textStorage] appendAttributedString:attr];
            [[m_textLog textStorage] appendAttributedString:attr2];
            [m_textLog scrollRangeToVisible:NSMakeRange([[m_textLog string] length], 0)];
        });
//        sleep(1);
    }
    [m_textUserName setEditable:YES];
    [m_textPassword setEditable:YES];
}

- (NSNumber *)runChangeCableName
{
    BOOL bChangeName = NO;
    if (!m_bJudge)
    {
        NSLog(@"Warning: FTDI cable not found!.");
        dispatch_async(dispatch_get_main_queue(), ^{
            NSColor	*color	= [NSColor redColor];
            NSDictionary	*dict	= [NSDictionary dictionaryWithObject:color
                                                             forKey:NSForegroundColorAttributeName];
            NSAttributedString* attr = [[[NSAttributedString alloc] initWithString:@"error: FTDI cable not found!\n"
                                         attributes:dict] autorelease];
            
            [[m_textLog textStorage] appendAttributedString:attr];
            [m_textLog scrollRangeToVisible:NSMakeRange([[m_textLog string] length], 0)];
        });
//        sleep(1);
        NSRunAlertPanel(@"警告(Warning)!",
						@"请先連接FTDI cable，並確認連接ok。(Please connect a FTDI cable first.)",
						@"确认（OK）", nil, nil);
        return [NSNumber numberWithBool:bChangeName];
    }
    if([[m_textPassword stringValue] isEqualToString:@""]
       || [[m_textUserName stringValue] isEqualToString:@""])
    {
        NSLog(@"Warning: Account or Password is empty!");
        dispatch_async(dispatch_get_main_queue(), ^{
            NSColor	*color	= [NSColor redColor];
            NSDictionary	*dict	= [NSDictionary dictionaryWithObject:color
                                                             forKey:NSForegroundColorAttributeName];
            NSAttributedString* attr = [[[NSAttributedString alloc] initWithString:@"error: Account or Password is empty!\n"
                                         attributes:dict] autorelease];
            
            [[m_textLog textStorage] appendAttributedString:attr];
            [m_textLog scrollRangeToVisible:NSMakeRange([[m_textLog string] length], 0)];
        });
//        sleep(1);
        
        NSRunAlertPanel(@"警告(Warning)!",
    					@"請輸入具有管理員權限的帳號和密碼。(Please enter an account and password, the account must has administrate permission for this computer.)",
                        @"确认（OK）", nil, nil);
        return [NSNumber numberWithBool:bChangeName];
    }
    //1. If the /usr/local/lib directory does not exist, create it (sudo mkdir /usr/local/lib)
    bChangeName = [self runAppleScript:RCTCreateLib];
    
    //2. Unload FTDIUSBSerialDriver and Install D2XX drivers
//	NSString * strScript = [[NSBundle mainBundle] pathForResource:@"UnloadTest" ofType:@"scpt"];
//	NSAppleScript * appScript = [[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:strScript] error:nil];
//	[appScript executeAndReturnError:NULL];
//	[appScript release];

    bChangeName &= [self runAppleScript:RCTUnloadVCP]; //UnloadVCP
    bChangeName &= [self runAppleScript:RCTInstallD2XX]; //Install D2XX drivers
    
    //3. Rename the serial cable
    NSString    *szOldName  = @"";
    NSString    *szCablePath= [m_popOldName titleOfSelectedItem];
//    NSString    *szCablePath=@"/dev/cu.usbserial-UPCYLINDER";
    NSRange     range       = [szCablePath rangeOfString:@"cu.usbserial-"];
    if (NSNotFound != range.location && range.length > 0 && (range.location + range.length)<= [szCablePath length])
    {
        szOldName  =   [szCablePath substringFromIndex:(range.location + range.length)];
    }
	if ([[m_textNewName stringValue] isEqualToString:@""] || [[m_textNewName stringValue] isEqualToString:szOldName])
    {
        NSLog(@"Warning: New cable name is empty or the new name is equal to the old name!");
        dispatch_async(dispatch_get_main_queue(), ^{
            NSColor	*color	= [NSColor redColor];
            NSDictionary	*dict	= [NSDictionary dictionaryWithObject:color
                                                             forKey:NSForegroundColorAttributeName];
            NSAttributedString* attr = [[[NSAttributedString alloc] initWithString:@"error: New cable name is empty or the new name is equal to the old name!\n"
                                         attributes:dict] autorelease];
            [[m_textLog textStorage] appendAttributedString:attr];
            [m_textLog scrollRangeToVisible:NSMakeRange([[m_textLog string] length], 0)];
        });
//        sleep(1);
        
        NSRunAlertPanel(@"警告(Warning)!",
    					@"請輸入你想要的線名。(Please enter a new cable name.)",
                        @"确认（OK）", nil, nil);
        return NO;
    }
    else if([[m_textNewName stringValue] length] > 8)
    {
        NSLog(@"Warning: Length of the New cable name cannot exceed 8 characters!");
        dispatch_async(dispatch_get_main_queue(), ^{
            NSColor	*color	= [NSColor redColor];
            NSDictionary	*dict	= [NSDictionary dictionaryWithObject:color
                                                             forKey:NSForegroundColorAttributeName];
            NSAttributedString* attr = [[[NSAttributedString alloc] initWithString:@"error: Length of the New cable name cannot exceed 8 characters!!\n"
                                                                        attributes:dict] autorelease];
            [[m_textLog textStorage] appendAttributedString:attr];
            [m_textLog scrollRangeToVisible:NSMakeRange([[m_textLog string] length], 0)];
        });
        //        sleep(1);
        
        NSRunAlertPanel(@"警告(Warning)!",
                        @"線名長度錯誤。(Wrong length of cable name.)",
                        @"确认（OK）", nil, nil);
        return NO;
    }
    else
        bChangeName &= [self runTaskPath:[NSString stringWithFormat:@"%@/ftdimv", [[NSBundle mainBundle] resourcePath]]
                          withArguments:[NSArray arrayWithObjects:szOldName,[m_textNewName stringValue], nil]
                             AndCommand:nil
                                  Error:nil];
    //5. Load FTDIUSBSerialDriver
    bChangeName &= [self runAppleScript:RCTLoadVCP];
    
    //6. Check the cable name if it has changed
    bChangeName &= [self runTaskPath:[NSString stringWithFormat:@"%@/ftdimv", [[NSBundle mainBundle] resourcePath]]
                       withArguments:nil
                          AndCommand:nil
                               Error:nil];
    return [NSNumber numberWithBool:bChangeName];
}

- (BOOL)runAppleScript:(NSString *) scriptName
{
    if(scriptName != nil && [scriptName isEqualToString:RCTLoadVCP])
    {
        NSString        *strScriptReload    = [NSString stringWithFormat:@"set UserName to \"%@\"\n\
                                               set MyPASSWORD to \"%@\"\n\
                                               do shell script \"kextload /System/Library/Extensions/FTDIUSBSerialDriver.kext\"\
                                               user name UserName password MyPASSWORD with administrator privileges\n",[m_textUserName stringValue], [m_textPassword stringValue]];
        
        NSAppleScript   *appReloadScript    = [[NSAppleScript alloc] initWithSource:strScriptReload];
        [appReloadScript executeAndReturnError:nil];
        [appReloadScript release];
        return YES;
    }
    else if (scriptName != nil && [scriptName isEqualToString:RCTUnloadVCP])
    {
        NSString        *strScriptUnload    = [NSString stringWithFormat:@"set UserName to \"%@\"\n\
                                               set MyPASSWORD to \"%@\"\n\
                                               do shell script \"kextunload /System/Library/Extensions/FTDIUSBSerialDriver.kext\" user name UserName password MyPASSWORD with administrator privileges\n",[m_textUserName stringValue], [m_textPassword stringValue]];
        NSAppleScript   *appUnloadScript    = [[NSAppleScript alloc] initWithSource:strScriptUnload];
        [appUnloadScript executeAndReturnError:nil];
        [appUnloadScript release];
        return YES;
    }
    else if (scriptName != nil && [scriptName isEqualToString:RCTCreateLib])
    {
        NSString        *strScriptLib       = [NSString stringWithFormat:@"set UserName to \"%@\"\n\
                                               set MyPASSWORD to \"%@\"\n\
                                               do shell script \"mkdir /usr/local/lib\"\
                                               user name UserName password MyPASSWORD with administrator privileges\n",[m_textUserName stringValue], [m_textPassword stringValue]];
        
        NSAppleScript   *appReloadScript    = [[NSAppleScript alloc] initWithSource:strScriptLib];
        [appReloadScript executeAndReturnError:nil];
        [appReloadScript release];
        return YES;
    }
    else if (scriptName != nil && [scriptName isEqualToString:RCTInstallD2XX])
    {
        NSDictionary    *dictError  = nil;
        NSString        *strScriptD2XX      = [NSString stringWithFormat:@"set UserName to \"%@\"\n\
                                               set MyPASSWORD to \"%@\"\n\
                                               do shell script \"cp %@/libftd2xx.1.0.2.dylib /usr/local/lib\" user name UserName password MyPASSWORD with administrator privileges\n\
                                               do shell script \"cp %@/libd2xx_table.dylib /usr/local/lib\" user name UserName password MyPASSWORD with administrator privileges\n\
                                               do shell script \"cd /usr/local/lib\" user name UserName password MyPASSWORD with administrator privileges\n\
                                               do shell script \"ln -sf libftd2xx.1.0.2.dylib libftd2xx.dylib\" user name UserName password MyPASSWORD with administrator privileges\n",[m_textUserName stringValue], [m_textPassword stringValue], [[NSBundle mainBundle] resourcePath], [[NSBundle mainBundle] resourcePath]];
        NSAppleScript   *appUnloadScript    = [[NSAppleScript alloc] initWithSource:strScriptD2XX];
        NSAppleEventDescriptor* descriptor  = [appUnloadScript executeAndReturnError:&dictError];
        NSLog(@"error: %@, descriptor= %@", dictError, descriptor);
        [appUnloadScript release];
        return YES;
    }
    else
        return NO;
}

- (BOOL)runTaskPath:(NSString *)path
	  withArguments:(NSArray *)arguments
		 AndCommand:(NSString *)command
			  Error:(NSString *)error
{
	NSFileManager * fileManger = [NSFileManager defaultManager];
	if (![fileManger fileExistsAtPath:path])
	{
		error = [NSString stringWithFormat:@"%@ not exist!",path];
		return NO;
	}
	
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:path];
    if (arguments)
        [task setArguments:arguments];
	[task setStandardInput:[NSPipe pipe]];
	[task setStandardOutput:[NSPipe pipe]];
	[task setStandardError:[task standardOutput]];
	[task setStandardInput:[NSPipe pipe]];
	
	@try {
		[task launch];
	}
	@catch (NSException *exception) {
		[task release]; task = nil;
		error = [exception reason];
		return NO;
	}
	// Send command
	if (command)
		[[[task standardInput] fileHandleForWriting] writeData:[command dataUsingEncoding:NSUTF8StringEncoding]];
	usleep(100);
	
	// Get response
	NSData * dataResponse = [[[task standardOutput] fileHandleForReading] availableData];
	
	// Checking
//	NSString * strResponse = [[NSString alloc] initWithData:dataResponse encoding:NSUTF8StringEncoding];
    m_strTaskResponse = [[NSString alloc] initWithData:dataResponse encoding:NSUTF8StringEncoding];
    if((NSNotFound != [m_strTaskResponse rangeOfString:@"dyld:"].location)
            || (NSNotFound != [m_strTaskResponse rangeOfString:@"sudo:"].location))
	{
		NSLog(@"%@", m_strTaskResponse);
//		[m_strTaskResponse release]; m_strTaskResponse = nil;
	}
    else
    {
        NSLog(@"%@", m_strTaskResponse);
//        [[m_textLog textStorage] insertAttributedString:[[[NSAttributedString alloc] initWithString:strResponse] autorelease]
//                                                atIndex:[[m_textLog string] length]];
        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSAttributedString* attr = [[[NSAttributedString alloc] initWithString:strResponse] autorelease];
//            
//            [[m_textLog textStorage] appendAttributedString:attr];
//            [m_textLog scrollRangeToVisible:NSMakeRange([[m_textLog string] length], 0)];
//        });
        if (NSNotFound != [m_strTaskResponse rangeOfString:@"Error"].location)
        {
            NSLog(@"Warning: Wrong Account or password.");
            dispatch_async(dispatch_get_main_queue(), ^{
                NSColor	*color	= [NSColor redColor];
                NSDictionary	*dict	= [NSDictionary dictionaryWithObject:color
                                                                 forKey:NSForegroundColorAttributeName];
                NSAttributedString* attr = [[[NSAttributedString alloc] initWithString:@"error: Wrong Account or password!\n"
                                             attributes:dict] autorelease];
                
                [[m_textLog textStorage] appendAttributedString:attr];
                [m_textLog scrollRangeToVisible:NSMakeRange([[m_textLog string] length], 0)];
            });
//            sleep(1);
            
            [task release];
            return NO;
        }
        else if(NSNotFound != [m_strTaskResponse rangeOfString:@"not found"].location)
        {
            NSLog(@"Warning: Old cable name error, please reconnect cable.");
            dispatch_async(dispatch_get_main_queue(), ^{
                NSColor	*color	= [NSColor redColor];
                NSDictionary	*dict	= [NSDictionary dictionaryWithObject:color
                                                                 forKey:NSForegroundColorAttributeName];
                NSAttributedString* attr = [[[NSAttributedString alloc] initWithString:@"error: Old cable name error, please reconnect cable.\n"
                                             attributes:dict] autorelease];
                
                [[m_textLog textStorage] appendAttributedString:attr];
                [m_textLog scrollRangeToVisible:NSMakeRange([[m_textLog string] length], 0)];
            });
//            sleep(1);
            
            [task release];
            return NO;
        }
//        else
//		{
//            [m_strTaskResponse release]; m_strTaskResponse = nil;
//        }
    }
	[task release];
    return YES;
}

- (NSString *)CurrentTime
{
    NSDate * now = [NSDate date];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *newDateString = [outputFormatter stringFromDate:now];
    [outputFormatter release];
    return newDateString;
}

@end
