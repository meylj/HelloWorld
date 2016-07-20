//
//  DailyWorkMailViewController.m
//  MailsTool
//
//  Created by allen on 20/3/2016.
//  Copyright © 2016 allen. All rights reserved.
//

#import "DailyWorkMailViewController.h"
#import "Modle.h"
#import "CommonDefine.h"


@interface DailyWorkMailViewController ()<NSComboBoxDataSource,NSComboBoxDelegate >
{
    NSDictionary * dicSettings;
    NSDictionary * dicMailList;
    
    NSString * AssignPersonMailAddress;
    
}

@end


@implementation DailyWorkMailViewController
@synthesize tfRadarNumber =_tfRadarNumber;
@synthesize tfComment = _tfComment;
@synthesize tfDailyWorkContent = _tfDailyWorkContent;
@synthesize tfDetailMailTitle = _tfDetailMailTitle;
@synthesize bUrgent = _bUrgent;
@synthesize tfCCMail = _tfCCMail;
@synthesize PopMailList = _PopMailList;


- (void)viewDidLoad {
    Modle *modle =[Modle defaultModle];
    NSLog(@"%@", modle);
    
    
    [super viewDidLoad];
    // Do view setup here.
   [_tfCCMail setStringValue:@"D580120R04@intra.pegatroncorp.com"];
    dicSettings	= [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SettingFile" ofType:@"plist"]];
    
    dicMailList  = [[dicSettings objectForKey:@"MailContract"] objectForKey:@"Coding"];
    
    
    [_PopMailList removeAllItems];
    [_PopMailList addItemsWithTitles:[dicMailList allKeys]];
    [_PopMailList selectItemAtIndex:0];

    AssignPersonMailAddress =[dicMailList objectForKey:[[_PopMailList selectedItem] title]];
    
    
    _bUrgent.state = 0;
    _tfComment.editable = YES;
    

    
}
- (IBAction)MailListChange:(id)sender
{
    NSString * AssignPerson =[[_PopMailList selectedItem] title];
    AssignPersonMailAddress =[dicMailList objectForKey:AssignPerson];
    
}

- (IBAction)SendMail:(id)sender
{
    NSString * strtem =[[_tfComment textStorage] string];
    NSLog(@"%@",strtem);
    
    
    NSString * format = @"YYYYMMdd_HHmmss";
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:format];
    NSString *dateString = [outputFormatter stringFromDate:[NSDate date]];
    NSLog(@"%@",dateString);

    
    NSString * strStage =[dicSettings objectForKey:@"Stage"];
    NSString * strProject =[dicSettings objectForKey:@"Project"];
    NSMutableString * MailTitle =[NSMutableString stringWithFormat:@"[%@][%@]Daily Work Assign to %@ at %@ about 【%@】",strProject,strStage,[[_PopMailList selectedItem] title],dateString,[_tfDailyWorkContent stringValue]];
    
    if (_bUrgent.state == 1)
    {
        [MailTitle appendString:@"[Urgent]"];
    }
    NSLog(@"title is %@",MailTitle);

    
    NSString * TaskContent =[[_tfDailyWorkContent stringValue] length]!= 0? [_tfDailyWorkContent stringValue]:@"";
    
    NSString * DailyMailTitle =[[_tfDetailMailTitle stringValue] length] != 0 ? [_tfDetailMailTitle stringValue] : @"";
    
    NSString * RadarNumber =[[_tfRadarNumber stringValue] length] != 0 ? [_tfRadarNumber stringValue] : @"";
    
    NSString * Commit =[[[_tfComment textStorage] string] length] != 0 ? [[_tfComment textStorage] string] : @"";
    
    NSString * AssignPerson =[[_PopMailList selectedItem] title];
    
    BOOL IfUrgent =_bUrgent.state != 1 ? _bUrgent.state : 0;
    
    NSDictionary * dicMailContent =@{@"buildStage":strStage,
                                     @"TaskContent":TaskContent,
                                     @"DailyMailTitle":DailyMailTitle,
                                     @"RadarNumber":RadarNumber,
                                     @"Commit":Commit,
                                     @"Urgent":[NSNumber numberWithBool:IfUrgent],
                                     @"AssignPerson" : AssignPerson};
    
    NSString *DefaultRtfFilePath  =[NSString  stringWithFormat:@"%@/DailyWorkMail.rtf",[[NSBundle mainBundle] bundlePath]];

    Modle * modle =[[Modle alloc]initWithDictionary:dicMailContent atCategory:@"DailyWorkAssign"];
    [modle formatData:modle intoFile:DefaultRtfFilePath];
    
    [self sendMailWithRtf:DefaultRtfFilePath subject:MailTitle ToAddress:AssignPersonMailAddress];
    
    NSFileManager * fm =[NSFileManager defaultManager];
    if ([fm fileExistsAtPath:DefaultRtfFilePath])
    {
        [fm removeItemAtPath:DefaultRtfFilePath error:nil];
    }
    
    [self dismissController:self];
    
    
}
-(void)sendMailWithRtf:(NSString *)RTFfilePath subject:(NSString *)MailSubject ToAddress:(NSString *)ToAddress
{
    NSString * strAppleScriptPath =[NSString stringWithFormat:@"%@/Contents/Resources/AppleScriptToSendMail.txt",[[NSBundle mainBundle] bundlePath]];
    
    NSMutableString * AppleScriptContent =[NSMutableString stringWithFormat:@"set the clipboard to (read \"%@\" as «class RTF »)\n",RTFfilePath];

    NSString * MailAddress =[NSString stringWithFormat:@"set addressList to {\"%@\"}\n",ToAddress];
        [AppleScriptContent appendString:MailAddress];
    
    [AppleScriptContent appendFormat:@"set theSubject to \"%@\"\n",MailSubject];
    
    [AppleScriptContent appendFormat:@"set ccrecipients to {\"%@\"}\n",[_tfCCMail stringValue]];

    [AppleScriptContent appendString:[NSString stringWithContentsOfFile: strAppleScriptPath encoding:NSUTF8StringEncoding error:nil]];
    [AppleScriptContent appendString:Str_AppleScript_Send];
    
    
    NSAppleScript * AppleScript =[[NSAppleScript alloc]initWithSource:AppleScriptContent];
    
    
    NSLog(@"%@",AppleScript);
    NSDictionary * errorInfo;
    
    [AppleScript compileAndReturnError:&errorInfo] ;
    
    if ([AppleScript isCompiled])
    {
        NSLog(@"Script have be compiled, and waiting excuate");
        [AppleScript executeAndReturnError:&errorInfo];
        NSLog(@"%@",errorInfo);

    }
    
    else
    {
        
        NSLog(@"Apple script have somehing wrong");
        NSLog(@"%@",errorInfo);
        
    }
}


@end
