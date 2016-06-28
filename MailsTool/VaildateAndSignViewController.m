//
//  VaildateAndSignViewController.m
//  MailsTool
//
//  Created by allen on 20/3/2016.
//  Copyright © 2016 allen. All rights reserved.
//

#import "VaildateAndSignViewController.h"
#import "Modle.h"
#import "AppDelegate.h"
#import "CommonDefine.h"

@interface VaildateAndSignViewController ()
{
    NSDictionary * dicSetting;
    NSMutableDictionary * dicMailContent;
    NSString * strAttachmentPath;
    
}

@end



@implementation VaildateAndSignViewController

@synthesize tfBaseLive = _tfBaseLive;
@synthesize tfBaseOverlay = _tfBaseOverlay;
@synthesize tfGitCommit = _tfGitCommit;
@synthesize tfNewLive = _tfNewLive;
@synthesize tfNewOverlay = _tfNewOverlay;
@synthesize tfRadarNumber = _tfRadarNumber;
@synthesize tvChangelist = _tvChangelist;
@synthesize PopStation = _PopStation;
@synthesize tfP4Number = _tfP4Number;
@synthesize tfbaseTestall = _tfbaseTestall;
@synthesize tfNewTestall = _tfNewTestall;
@synthesize PopCCmail = _PopCCmail;
@synthesize PCTestcoveragePath = _PCTestcoveragePath;


//for roll in mail
@synthesize PopReceiver = _PopReceiver;
@synthesize labelGit = _labelGit;




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    dicMailContent  =[[NSMutableDictionary alloc]init];
    dicSetting	= [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SettingFile" ofType:@"plist"]];
    
    [_PopStation removeAllItems];
    [_PopStation addItemsWithTitles:[dicSetting objectForKey:@"Station"]];
    [_PopStation selectItemWithTitle:@"NONE"];
    [_PopStation setHighlighted:YES];
    
    [_PopCCmail removeAllItems];
    [_PopCCmail addItemsWithTitles:[[dicSetting objectForKey:@"GroupContract"] allKeys]];
    [_PopCCmail selectItemWithTitle:@"NONE"];
    [_PopCCmail setHighlighted:YES];
    
    [_PopReceiver removeAllItems];
    [_PopReceiver addItemsWithTitles:[[[dicSetting objectForKey:@"MailContract"] objectForKey:@"Validation"]allKeys]];
    [_PopReceiver selectItemWithTitle:@"NONE"];
    [_PopReceiver setHighlighted:YES];
    
    
    [_tfBaseLive setEditable: NO];
    [_tfNewLive setEditable:NO];
    [_tfNewOverlay setEditable:NO];
    [_tfBaseOverlay setEditable:NO];
    [_tfNewTestall setEditable:NO];
    [_tfbaseTestall setEditable:NO];
    
    [_PCTestcoveragePath setEnabled:YES];
     
    [_PCTestcoveragePath setDoubleAction:@selector(pathControlDoubleClick:)];
    
    strAttachmentPath = [dicSetting objectForKey:@"TestCoveragePath"];
    
    NSLog(@"%@",strAttachmentPath);
    [_PCTestcoveragePath setURL:[NSURL URLWithString:strAttachmentPath]];
    
        // Do view setup here.
    Modle * modle =[Modle defaultModle];
    NSLog(@"%@",[modle description]);
    
    [_tvChangelist setEditable:YES];
    [_tfRadarNumber setPlaceholderString:@"Please input Radar Number"];
    [_tfGitCommit setPlaceholderString:@"Please input Git commit"];
    [_tfP4Number setPlaceholderString:@"Please input Coco P4 Number"];

   
    
    
}

/*
 This method is the "double-click" action for the control. Because we are using a standard style or navigation style control we ask for the  path component that was clicked.
 */
- (void)pathControlDoubleClick:(id)sender
{
    if ([_PCTestcoveragePath clickedPathComponentCell] != nil)
    {
        
        NSOpenPanel * panel =[NSOpenPanel openPanel];
        [panel setAllowsMultipleSelection:NO];
        [panel setCanChooseDirectories:YES];
        [panel setResolvesAliases:YES];
        NSString *panelTitle = NSLocalizedString(@"Choose a Folder", @"Title for the open panel");
        [panel setTitle:panelTitle];
        NSString *promptString = NSLocalizedString(@"Choose", @"Prompt for the open panel prompt");
        [panel setPrompt:promptString];
        if ([panel runModal] == NSModalResponseCancel)
        {
            [panel orderOut:self];
            
        }
        else
        {
            [panel orderOut:self];
            NSURL * url =[[panel URLs] objectAtIndex:0];
            if (url != nil)
            {
                strAttachmentPath =[url path];
                NSLog(@"%@",strAttachmentPath);
            }
            [_PCTestcoveragePath setURL:url];
            }
    }
}

- (IBAction)SelectSation:(id)sender
{
    NSFileManager *fm =[NSFileManager defaultManager];
    NSString * GitOverlayListPath =[dicSetting objectForKey:@"GitOverlayListPath"];
    if (![fm fileExistsAtPath:GitOverlayListPath])
    {
        NSAlert *alert =[self showAlertwithTitle:@"警告" withMessage:@"Station 路径设置不对" buttons:@[@"OK"]];
        [alert runModal];
        
    }
    else
    {
        [self loadOverlayStatus:GitOverlayListPath];
    }
}

-(BOOL)loadOverlayStatus:(NSString *)GitOverlayList
{
    NSDictionary * OverlayStatus =[[NSDictionary dictionaryWithContentsOfFile:GitOverlayList] objectForKey:[[_PopStation selectedItem] title]];
    NSString * strSelectedItem =[[_PopStation selectedItem] title];
    
    NSString * strValidationStatus = [OverlayStatus objectForKey:@"Validation Status"];
    
    if (![strValidationStatus isEqualToString:@"OK"])
    {
        
        NSString * strLatestOverlay = [OverlayStatus objectForKey:@"Latest Overlay Version"];
        NSString * strBaseOverlay   = [OverlayStatus objectForKey:@"Online Overlay Version"];
        NSString * strLatestLive    = [OverlayStatus objectForKey:@"Latest Live Version"];
        NSString * strBaseLive      = [OverlayStatus objectForKey:@"Online Live Version"];
        NSString * strLatestTestAll = [OverlayStatus objectForKey:@"Latest Testall Version"];
        NSString * strBaseTestAll   = [OverlayStatus objectForKey:@"Online Testall Version"];
       //set text filed
        [_tfNewOverlay setStringValue:strLatestOverlay];
        [_tfBaseOverlay setStringValue:strBaseOverlay];
        [_tfNewLive setStringValue:strLatestLive];
        [_tfBaseLive setStringValue:strBaseLive];
        [_tfbaseTestall setStringValue:strBaseTestAll];
        [_tfNewTestall setStringValue: strLatestTestAll];
        NSString * MailSubject = @"";
        
        if (![strBaseOverlay isEqualToString:strLatestOverlay])
        {
            MailSubject =@"Overlay validation requirement";
        }
        else
        {
            if (![strLatestLive isEqualToString:strBaseLive] && [strLatestTestAll isEqualToString:strBaseTestAll])
            {
                  MailSubject =@"JSON file validation requirement";

            }
            else if ([strLatestLive isEqualToString:strBaseLive] && ![strLatestTestAll isEqualToString:strBaseTestAll])
            {
                  MailSubject =@"TestAll file validation requirement";
            }
            else if (![strLatestLive isEqualToString:strBaseLive] && ![strLatestTestAll isEqualToString:strBaseTestAll])
            {
                  MailSubject =@"TestAll / JSON file validation requirement";
            }

        }
        
        [dicMailContent setObject:MailSubject forKey:@"MailSubject"];
        
        [dicMailContent addEntriesFromDictionary:OverlayStatus];
        

        return YES;

    }
    
    else
    {
        NSAlert *alert = [[NSAlert alloc]init];
        alert.messageText = @"警告(Warning)";
        alert.informativeText = [NSString stringWithFormat:@"Overlay或者JSON 状态 没有改成Validating,\n 请先标识Overlay或JSON状态"];
        [alert addButtonWithTitle:@"确认(OK)"];
        [alert setAlertStyle:NSWarningAlertStyle];
        if ([alert runModal] == NSAlertFirstButtonReturn)
        {
            [_PopStation selectItemWithTitle:strSelectedItem];
            [self removeAllContent];
            
            
        }
        return NO;
    }


}

-(void)removeAllContent
{
    [_tfNewOverlay setStringValue:@""];
    [_tfBaseOverlay setStringValue:@""];
    [_tfNewLive setStringValue:@""];
    [_tfBaseLive setStringValue:@""];
    [_tfbaseTestall setStringValue:@""];
    [_tfNewTestall setStringValue: @""];
    [_tfP4Number setStringValue:@""];
    [_tfGitCommit setStringValue:@""];
    
    [_tfRadarNumber setStringValue:@""];
    
    
    
    
}

- (IBAction)SelectReceiver:(id)sender
{
    if ([[_PopReceiver title] isEqualToString:@"NONE"])
    {
        [_PopReceiver setTitle:@"NONE"];
        
    }
    else
    {
        NSString * strReceiver =[[_PopReceiver selectedItem] title];
        [dicMailContent setObject:strReceiver forKey:@"Receivers"];
    }
}

- (IBAction)SelectCCGroup:(id)sender
{
    if ([[_PopCCmail title] isEqualToString:@"NONE"])
    {
        [_PopCCmail setTitle:@"NONE"];
        
    }
    else
    {
        NSString * strReceiver =[[_PopCCmail selectedItem] title];
        [dicMailContent setObject:strReceiver forKey:@"CCGroup"];
    }
}

-(NSAlert *)showAlertwithTitle:(NSString *)title withMessage:(NSString *)Message buttons:(NSArray *)arrButtons
{
    NSAlert *alert = [[NSAlert alloc]init];
    alert.messageText = title;
    alert.informativeText = Message;
//    [alert addButtonWithTitle:@"确认(OK)"];
    if (arrButtons.count == 1)
    {
        [alert addButtonWithTitle:arrButtons[0]];
        
    }
    else
    {
        for (int i = 0; i < arrButtons.count; i++)
        {
            [alert addButtonWithTitle:arrButtons[i]];
            
        }
    }
    [alert setAlertStyle:NSWarningAlertStyle];
    
    return alert;
}
- (IBAction)btnSend:(id)sender
{
    void (^send_Mail)(NSString * changeList);
    send_Mail   = ^(NSString * changeList)
    {
        NSString * GitCommit = [_tfGitCommit stringValue];
        NSString * RadarNumber = [_tfRadarNumber stringValue];
        NSString * strP4Number = [_tfP4Number stringValue];
        NSString * Receiver =[[[dicSetting objectForKey:@"MailContract"] objectForKey:@"Validation"]objectForKey:[dicMailContent objectForKey:@"Receivers"]];

        [dicMailContent setObject:changeList forKey:@"changelist"];
        [dicMailContent setObject:GitCommit forKey:@"GitCommit"];
        [dicMailContent setObject:RadarNumber forKey:@"RadarNumber"];
        [dicMailContent setObject:[_PopStation.selectedItem title] forKey:@"Station"];
        [dicMailContent setObject:strP4Number forKey:@"P4Number"];
        
        Modle * modle =[[Modle alloc]initWithDictionary:dicMailContent atCategory:@"Validation"];
        
        NSString *DefaultRtfFilePath =[[NSString alloc]init];
        
        DefaultRtfFilePath  =[NSString  stringWithFormat:@"%@/ValidationMail.rtf",[[NSBundle mainBundle] bundlePath]];
        
        NSLog(@"%@,%@",[modle description],DefaultRtfFilePath);
        
        if ([[modle formatData:modle intoFile:DefaultRtfFilePath] boolValue])
        {
            NSLog(@"YES");
            NSString * strStage = [dicSetting objectForKey:@"Stage"];
            NSString * strProject =[dicSetting objectForKey:@"Project"];
            
            NSMutableString * subject =[NSMutableString stringWithFormat:@"[%@][%@]Latest Station %@ ",strProject,strStage,[[_PopStation selectedItem] title]];
            [subject appendString:[dicMailContent objectForKey:@"MailSubject"]];
            
            [self sendMailWithRtf:DefaultRtfFilePath subject:subject ToAddress:Receiver];
        }};
    NSString * selectSta    =   [[_PopStation selectedItem] title];
    NSString * selectRec    =   [[_PopReceiver selectedItem] title];
    NSString * selectGroup  =   [[_PopCCmail selectedItem] title];
    NSFileManager * fm =[NSFileManager defaultManager];
    
    if ([selectSta isEqualToString:@"NONE"] || [selectRec isEqualToString:@"NONE"] || [selectGroup isEqualToString:@"NONE"])
    {
        NSAlert * alert = [self showAlertwithTitle:@"警告" withMessage:@"请选好基本信息" buttons:@[@"OK"]];
        [alert runModal];
        return;
        
    }


    // judge the error operation
    if ([[[_tvChangelist textStorage]string] length] == 0 )
    {
        NSAlert * alert =[self showAlertwithTitle: @"警告(Warning)" withMessage:@"请先完善Change List  再发验证需求" buttons:@[@"OK"]];
        [alert runModal];
        return;
        
    }
    NSString * changeList =(NSString *)[[_tvChangelist textStorage] string];
    

    if (![fm fileExistsAtPath:strAttachmentPath])
    {
        NSAlert * alert =[self showAlertwithTitle:@"警告" withMessage:@"TEST COVERAGE PATH 不对,请双击选择正确路径" buttons:@[@"OK"]];
        [alert runModal];
        return;
        
        
    }
    else
    {
        NSDate * modificationDate   =   [[fm attributesOfItemAtPath:strAttachmentPath error:nil] fileModificationDate];
        NSDate * date               =   [NSDate date];
        if ([date timeIntervalSinceDate:modificationDate] > 1*60*60 )
        {
            NSAlert * alert =[self showAlertwithTitle:@"警告" withMessage:@"TEST COVERAGE 已经超过1小时没有更新了，你确定你要发这个附件吗" buttons:@[@"OK",@"不能发，我得去修改"]];
            if([alert runModal] == NSAlertSecondButtonReturn)
            {
                NSPasteboard * pasteboard   =   [NSPasteboard generalPasteboard];
                [pasteboard declareTypes:[NSArray arrayWithObject:NSStringPboardType]
                           owner:self];
                [pasteboard setString: changeList forType:NSPasteboardTypeString];
                NSString * message = [NSString stringWithFormat:@"Change list 已经在粘贴板内，可以复制到test coverage 中去了"];
                NSAlert * alert =[self showAlertwithTitle:@"警告" withMessage:message buttons:@[@"OK"]];
                if ([alert runModal] == NSAlertFirstButtonReturn)
                {
                    [[NSWorkspace sharedWorkspace]openFile:strAttachmentPath];

                }
                return;
                
            }
            else
            {
                send_Mail(changeList);
                
            }
        }
        else
        {
            send_Mail(changeList);
            
        }

    }
}
-(void)sendMailWithRtf:(NSString *)RTFfilePath subject:(NSString *)MailSubject ToAddress:(NSString *)ToAddress
{
    NSString * strAppleScriptPath =[NSString stringWithFormat:@"%@/Contents/Resources/AppleScriptToSendMail.txt",[[NSBundle mainBundle] bundlePath]];

    NSMutableString * AppleScriptContent =[NSMutableString stringWithFormat:@"set the clipboard to (read {\"%@\"} as «class RTF »)\n",RTFfilePath];
    NSString * MailAddress =[NSString stringWithFormat:@"set addressList to {\"%@\"}\n",ToAddress];
    [AppleScriptContent appendString:MailAddress];
    [AppleScriptContent appendFormat:@"set theSubject to \"%@\"\n",MailSubject];

    if ([dicMailContent objectForKey:@"CCGroup"]!= nil)
    {
        NSString * CCGroup =[[dicSetting objectForKey:@"GroupContract"] objectForKey:[dicMailContent objectForKey:@"CCGroup"]];
        [AppleScriptContent appendFormat:@"set ccrecipients to {\"%@\"}\n",CCGroup];
    }
    if (strAttachmentPath != nil)
    {
        NSString * SetAttachment =[NSString stringWithFormat:@"set theAttachmentFile to POSIX file \"%@\"\n",strAttachmentPath];
        [AppleScriptContent appendString:SetAttachment];
    }
    NSDictionary * errorInfo;
    
    [AppleScriptContent appendString:[NSString stringWithContentsOfFile:strAppleScriptPath encoding:NSUTF8StringEncoding error:nil]];
    [AppleScriptContent appendString:Str_AppleScript_Attachment];
    
    [AppleScriptContent appendString:Str_AppleScript_Send];
    
    NSLog(@"%@", AppleScriptContent);
    
    [AppleScriptContent writeToFile:@"/Users/allen/Desktop/applescript.txt" atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    NSAppleScript * AppleScript =[[NSAppleScript alloc]initWithSource:AppleScriptContent];
    NSLog(@"%@",AppleScript);
    
    
    [AppleScript compileAndReturnError:&errorInfo] ;
    
    if ([AppleScript isCompiled])
    {
        NSLog(@"Script have be compiled, and waiting excuate");
        if ([AppleScript executeAndReturnError:&errorInfo])
        {
            NSLog(@"Script excuate Successfully");
 
        }
        else
        {
            NSLog(@"Apple script have somehing wrong");
            NSLog(@"%@",errorInfo);
        }
        
    }
    
    else
    {
        
        NSLog(@"Apple script have somehing wrong");
        NSLog(@"%@",errorInfo);
        
    }
}

@end
