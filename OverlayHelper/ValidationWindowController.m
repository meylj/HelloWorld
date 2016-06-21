//
//  ValidationWindowController.m
//  OverlayHelper
//
//  Created by allen on 30/10/2015.
//  Copyright © 2015 Lorky. All rights reserved.
//

#import "ValidationWindowController.h"
#import "NSStringCategory.h"
#define DefaultRtfFilePath                        [NSString  stringWithFormat:@"%@/validationRequest.rtf",[[NSBundle mainBundle] bundlePath]]

@interface ValidationWindowController ()

@end


@implementation ValidationWindowController
@synthesize NewOverlayVersion = _NewOverlayVersion;
@synthesize BaseOverlayVersion = _BaseOverlayVersion;
@synthesize  NewLiveVersion    = _NewLiveVersion;
@synthesize tfChangeNote = _tfChangeNote;
@synthesize tfRadarNumber = _tfRadarNumber;
@synthesize tfLocalP4Number = _tfLocalP4Number ;
@synthesize tfTestCoverage = _tfTestCoverage;
@synthesize tfBaseLiveVersion = _tfBaseLiveVersion;
@synthesize tfValidateMethod = _tfValidateMethod;

- (void)windowDidLoad
{
    [super windowDidLoad];
    //If just want to send validation mail
    if (_m_ValidationInfo.count == 0) {
        
        NSString * defaultValidateMethod =[NSString stringWithFormat:@"Compare with the overlay before.\nCheck all test item name, commands, spec, attribute and parametric data.\nPlease make sure new overlay doesn’t miss anything."];
        
        [_tfValidateMethod setTextColor:[NSColor blueColor]];
        [_tfValidateMethod setStringValue:defaultValidateMethod];

    }
    // write into basic info about overlay
    else
    {
    [_NewOverlayVersion setStringValue:[NSString stringWithFormat:@"1.0d%@" ,[_m_ValidationInfo objectForKey:@"NewVersion"]]];
    
    [_m_ValidationInfo setObject:[_NewOverlayVersion stringValue] forKey:@"NewVersion"];
    
    [_BaseOverlayVersion setStringValue:[_m_ValidationInfo objectForKey:@"BaseVersion"]];
   
    NSString * StrChangeNote =[_m_ValidationInfo objectForKey:@"ChangeNote"];
    
    [_tfChangeNote setStringValue:[StrChangeNote SubFrom:@"ChangeNotes:\n" include:NO]];
    
    [_m_ValidationInfo setObject:[_tfChangeNote stringValue] forKey:@"ChangeNote"];
    
    NSString * defaultValidateMethod =[NSString stringWithFormat:@"Compare with %@Check all test item name, commands, spec, attribute and parametric data.\nPlease make sure new overlay doesn’t miss anything.",[_m_ValidationInfo objectForKey:@"BaseVersion"]];

    [_tfValidateMethod setTextColor:[NSColor blueColor]];
    [_tfValidateMethod setStringValue:defaultValidateMethod];
    }
    // for Local no live function overlay
    if ([[_m_ValidationInfo objectForKey:@"DisableLiveFunction"] boolValue])
    {
        [_NewLiveVersion setStringValue:@"NO LIVE FILE"];
        [_tfBaseLiveVersion setStringValue:@"NO LIVE FILE"];
        [_NewLiveVersion setTextColor:[NSColor redColor]];
        [_tfBaseLiveVersion setTextColor: [NSColor redColor]];
        [_tfBaseLiveVersion setEditable: NO];
        [_NewLiveVersion setEditable:NO];
    }
    
    
}


-(void)sendMailWithRtf:(NSString *)RTFfilePath subject:(NSString *)MailSubject ToAddress:(NSString *)ToAddress
{
    NSMutableString * AppleScriptContent =[NSMutableString stringWithFormat:@"set the clipboard to (read \"%@\" as «class RTF »)\nset MailAddress to \"%@\"\nset theSubject to \"%@\"\n",RTFfilePath,ToAddress,MailSubject];
    
    [AppleScriptContent appendString:[NSString stringWithContentsOfFile:@"/Users/allen/Work_Space/Other/OverlayHelper/OverlayHelper/AppleScriptToSendMail.txt" encoding:NSUTF8StringEncoding error:nil]];
    
    
    NSAppleScript * AppleScript =[[NSAppleScript alloc]initWithSource:AppleScriptContent];
    
    
    NSLog(@"%@",AppleScript);
    NSDictionary * errorInfo;
    
    [AppleScript compileAndReturnError:&errorInfo] ;
    
    if ([AppleScript isCompiled])
    {
        NSLog(@"Script have be compiled, and waiting excuate");
        [AppleScript executeAndReturnError:&errorInfo];
    }
    
    else
    {
        
        NSLog(@"Apple script have somehing wrong");
        NSLog(@"%@",errorInfo);
        
    }
}


- (IBAction)SendMail:(id)sender
{
    NSString * format = @"YYYYMMdd_HHmmss";
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:format];
    NSString *dateString = [outputFormatter stringFromDate:[NSDate date]];
    NSLog(@"%@",dateString);

    
    if (_m_ValidationInfo.count == 0)
    {
        NSAlert * alert =[[NSAlert alloc]init];
        alert .messageText = @"Project and Station";
        alert.alertStyle =NSWarningAlertStyle;
        [alert addButtonWithTitle:@"YES"];
        NSTextField * InputView  = [[NSTextField alloc]initWithFrame:NSMakeRect(0, 0, 245.0f, 50.0f)];
        InputView.editable       = YES;
        InputView.placeholderString = @"填上站位跟哪个专案哈，格式：Kirin/QT0";
        [alert setAccessoryView: InputView];
        if ([alert runModal] == NSAlertFirstButtonReturn)
        {
            NSString *Project =[InputView.stringValue SubTo:@"/" include:NO];
            NSString *Station =[InputView.stringValue SubFrom:@"/" include:NO];
            [_m_ValidationInfo setObject:Project forKey:@"Project"];
            [_m_ValidationInfo setObject:Station forKey:@"StationID"];
            
        }

        [_m_ValidationInfo setObject:[_NewLiveVersion stringValue] forKey:@"NewVersion"];
        [_m_ValidationInfo setObject:[_BaseOverlayVersion stringValue] forKey:@"BaseVersion"];
        
        [_m_ValidationInfo setObject:[_NewLiveVersion stringValue] forKey:@"NewLiveVersion"];
        [_m_ValidationInfo setObject:[_tfBaseLiveVersion stringValue] forKey:@"BaseLiveVersion"];
        [_m_ValidationInfo setObject:[_tfChangeNote stringValue] forKey:@"ChangeNote"];

        [_m_ValidationInfo setObject:[_tfValidateMethod stringValue] forKey:@"ValidateMethod"];
        [_m_ValidationInfo setObject:[_tfTestCoverage stringValue] forKey:@"TestCoverage"];
        [_m_ValidationInfo setObject:[_tfLocalP4Number stringValue] forKey:@"P4 Number"];
        [_m_ValidationInfo setObject:[_tfRadarNumber stringValue] forKey:@"RadarNumber"];

        
    }
    
    if (![[_m_ValidationInfo objectForKey:@"DisableLiveFunction"]boolValue]  )
    {
        if ([_tfBaseLiveVersion stringValue].length <= 0 || [_NewLiveVersion stringValue].length <= 0)
        {
            NSAlert * alert =[[NSAlert alloc]init];
            alert .messageText = @"Warning";
            alert.informativeText = @"是不是找抽，Live 版本都不寫，想死呢？！";
            alert.alertStyle =NSWarningAlertStyle;
            [alert addButtonWithTitle:@"YES"];
            
            if ([alert runModal] == NSModalResponseOK)
            {
                [alert release];
                
            }
        }
        else
        {
            [_m_ValidationInfo setObject:[_NewLiveVersion stringValue] forKey:@"NewLiveVersion"];
            [_m_ValidationInfo setObject:[_tfBaseLiveVersion stringValue] forKey:@"BaseLiveVersion"];
            
            
        }
        
    }
    
    if ([_tfTestCoverage stringValue].length <= 0 && [_tfLocalP4Number stringValue].length <= 0 && [_tfRadarNumber stringValue].length <=0)
    {
        NSAlert * alert =[[NSAlert alloc]init];
        alert .messageText = @"Warning";
        alert.informativeText = @"Test-Coverage, radar, Local P4 你確定不需要寫嗎？";
        alert.alertStyle =NSWarningAlertStyle;
        [alert addButtonWithTitle:@"YES"];
        [alert addButtonWithTitle:@"NO"];
        
        if ([alert runModal] == NSAlertFirstButtonReturn)
        {
            [_tfLocalP4Number setStringValue:@"N/A"];
            [_tfRadarNumber setStringValue:@"N/A"];
            [_tfTestCoverage setStringValue:@"N/A"];
            
            [alert release];
        }
        else
        {
            [alert release];
            
        }
    }
    else
    {
        [_m_ValidationInfo setObject:[_tfValidateMethod stringValue] forKey:@"ValidateMethod"];
        [_m_ValidationInfo setObject:[_tfTestCoverage stringValue] forKey:@"TestCoverage"];
        [_m_ValidationInfo setObject:[_tfLocalP4Number stringValue] forKey:@"P4 Number"];
        [_m_ValidationInfo setObject:[_tfRadarNumber stringValue] forKey:@"RadarNumber"];
        
        NSString * mailSubject =[NSString stringWithFormat:@"[%@] %@ station validation requirement at %@ ",[_m_ValidationInfo objectForKey:@"Project"],[_m_ValidationInfo objectForKey:@"StationID"],dateString];
        NSLog(@"validation info :\n %@", _m_ValidationInfo);
        
        [self WriteMailDocument];
       
        [self sendMailWithRtf:DefaultRtfFilePath subject:mailSubject ToAddress:@"allen8_liu@pegatroncorp.com"];
        
        [_m_ValidationInfo removeAllObjects];
        
    }
    
    
    
}

-(void)WriteMailDocument
{
    
//    NSString * iPath =[NSString  stringWithFormat:@"%@/validationRequest.rtf",[[NSBundle mainBundle] bundlePath]];
    
    
    NSMutableAttributedString * DocContent =[self SettingDocumentFormat];
    
    
    NSData * data =[DocContent RTFFromRange:NSMakeRange(0, DocContent.length) documentAttributes:@{NSRTFTextDocumentType: NSDocFormatTextDocumentType}];

    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:DefaultRtfFilePath]) {
        
        [fileManager removeItemAtPath:DefaultRtfFilePath error:nil];
        
    }
    
    [data writeToFile:DefaultRtfFilePath atomically:YES];
    
    
    
}

-(NSMutableAttributedString *)SettingDocumentFormat
{
    NSMutableDictionary * dicTitleAttribute =[[NSMutableDictionary alloc]init];
    [dicTitleAttribute setObject:[NSFont fontWithName:@"HelveticaNeue-CondensedBold" size:15.0f] forKey:NSFontAttributeName];
    [dicTitleAttribute setObject:[NSColor blueColor] forKey:NSForegroundColorAttributeName];
    [dicTitleAttribute setObject:[NSNumber numberWithInteger:NSUnderlineStyleSingle] forKey:NSUnderlineStyleAttributeName];
    
    NSMutableDictionary * dicMainInfoAttribute =[[NSMutableDictionary alloc]init];
    [dicMainInfoAttribute setObject:[NSFont fontWithName:@"Consolas" size:15.0] forKey:NSFontAttributeName];
    NSShadow * shadowString =[[NSShadow alloc]init];
    shadowString.shadowColor = [NSColor blackColor];
    [dicMainInfoAttribute setObject:shadowString forKey:NSShadowAttributeName];
    
    
    NSMutableDictionary * dicContentAttributes =[[NSMutableDictionary alloc]init];
    [dicContentAttributes setObject:[NSFont fontWithName:@"Consolas" size:13.0f] forKey:NSFontAttributeName];
    
    // format Attribute string
    NSMutableAttributedString  * DocContent =[[NSMutableAttributedString alloc]init];
    [DocContent appendAttributedString:[[NSAttributedString alloc] initWithString:@"STATION:\n"
                                                                       attributes:dicTitleAttribute]];
    
    [DocContent appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@" ,[_m_ValidationInfo objectForKey:@"StationID"]]
                                                                       attributes:dicMainInfoAttribute]];
    
    [DocContent appendAttributedString:[[NSAttributedString alloc] initWithString:@"\nNew Overlay:\n"
                                                                       attributes:dicTitleAttribute]];
    
    [DocContent appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",[_m_ValidationInfo objectForKey:@"NewVersion"]]
                                                                       attributes:dicMainInfoAttribute]];
    
    [DocContent appendAttributedString:[[NSAttributedString alloc]initWithString:@"\nBase Overlay:\n"
                                                                      attributes:dicTitleAttribute]];
    
    [DocContent appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",[_m_ValidationInfo objectForKey:@"BaseVersion"]]
                                                                       attributes:dicMainInfoAttribute]];
    
   // For Live
    if (![[_m_ValidationInfo objectForKey:@"DisableLiveFunction"]boolValue]  )
    {
        [DocContent appendAttributedString:[[NSAttributedString alloc]initWithString:@"\nNew Live :\n"
                                                                          attributes:dicTitleAttribute]];
        
        [DocContent appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",[_m_ValidationInfo objectForKey:@"NewLiveVersion"]]
                                                                           attributes:dicMainInfoAttribute]];

        
        [DocContent appendAttributedString:[[NSAttributedString alloc]initWithString:@"\nBase Live Version :\n"
                                                                          attributes:dicTitleAttribute]];

        [DocContent appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",[_m_ValidationInfo objectForKey:@"BaseLiveVersion"]]
                                                                           attributes:dicContentAttributes]];

    }
    
    [DocContent appendAttributedString:[[NSAttributedString alloc]initWithString:@"\nChange Note :\n"
                                                                      attributes:dicTitleAttribute]];
    
    [DocContent appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@\n",[_m_ValidationInfo objectForKey:@"ChangeNote"]]
                                                                       attributes:dicContentAttributes]];
    
    
    //For Test-Coverage
    [DocContent appendAttributedString:[[NSAttributedString alloc] initWithString:@"\nTest Coverage:\n"
                                                                       attributes:dicTitleAttribute]];
    
    [DocContent appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@\n" ,[_m_ValidationInfo objectForKey:@"TestCoverage"]]
                                                                       attributes:dicMainInfoAttribute]];
    
    [DocContent appendAttributedString:[[NSAttributedString alloc] initWithString:@"\nRadar Number:"
                                                                       attributes:dicTitleAttribute]];
    
    [DocContent appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@\n" ,[_m_ValidationInfo objectForKey:@"RadarNumber"]]
                                                                       attributes:dicContentAttributes]];
    
    [DocContent appendAttributedString:[[NSAttributedString alloc] initWithString:@"\nLocal P4 Number:"
                                                                       attributes:dicTitleAttribute]];
    
    [DocContent appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@\n" ,[_m_ValidationInfo objectForKey:@"P4 Number"]]
                                                                       attributes:dicContentAttributes]];
    

    [DocContent appendAttributedString:[[NSAttributedString alloc]initWithString:@"\nValidation Method:\n"
                                                                      attributes:dicTitleAttribute]];
    
    [DocContent appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@\n" ,[_m_ValidationInfo objectForKey:@"ValidateMethod"]]
                                                                       attributes:dicContentAttributes]];
    
    
    
    return  DocContent;
    
}

// record CSV about modify histroy


@end
