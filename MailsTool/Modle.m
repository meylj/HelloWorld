//
//  Modle.m
//  MailsTool
//
//  Created by allen on 22/3/2016.
//  Copyright © 2016 allen. All rights reserved.
//


#import "Modle.h"


@implementation Modle

static Modle* defaultModle = nil;

//singleton mode
+(Modle *)defaultModle
{
    if (defaultModle == nil)
    {
        defaultModle =[[super allocWithZone:NULL] init];
    }
    return defaultModle;
    
}
+(id)allocWithZone:(struct _NSZone *)zone
{
    return [self defaultModle];
    
}

// init method
-(instancetype)initWithDictionary:(NSDictionary *)dicContent atCategory:(NSString *)strCategory
{
    self = [super init];
    if (self)
    {
        dicAttributeTitle =[[NSMutableDictionary alloc]init];
        
        [dicAttributeTitle setObject:[NSFont fontWithName:@"Consolas" size:15.0f] forKey:NSFontAttributeName];
        [dicAttributeTitle setObject:[NSColor blueColor] forKey:NSForegroundColorAttributeName];
        [dicAttributeTitle setObject:[NSNumber numberWithInteger:NSUnderlineStyleSingle] forKey:NSUnderlineStyleAttributeName];
        //MainInfo
        dicAttributeMainInfo =[[NSMutableDictionary alloc]init];
        [dicAttributeMainInfo setObject:[NSFont fontWithName:@"Consolas" size:13.0] forKey:NSFontAttributeName];
        NSShadow * shadowString =[[NSShadow alloc]init];
        shadowString.shadowColor = [NSColor blackColor];
        [dicAttributeMainInfo setObject:shadowString forKey:NSShadowAttributeName];
        
        self.dicContent =[dicContent mutableCopy];
        self.category = strCategory;
        
    }
    return self;
    
}
-(NSString *)description
{
    return [NSString stringWithFormat:@"the category is %@, content is %@",self.category,self.dicContent];
    
}
-(NSNumber *)setStrCategory:(NSString *)strCategory
{
    if (!defaultModle)
    {
        NSLog(@"Molde is Null, please initilize at first");
        return [NSNumber numberWithBool:NO];
        
    }
    else
    {
        defaultModle.category = [NSString stringWithString:strCategory];
        NSLog(@"%@",defaultModle.description);
        
        return [NSNumber numberWithBool:YES];
        
        
    }

}

//format data, and write to file
-(NSNumber *)formatData:(Modle *)ModleData intoFile:(NSString *)FilePath
{
    NSString * theMailCategory =ModleData.category;
    NSDictionary * theMailContent = ModleData.dicContent;
    NSFileManager * fm  =[NSFileManager defaultManager];
    NSMutableAttributedString * attStrTmp = [[NSMutableAttributedString alloc]initWithString:@""];

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self writeRecord:[[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SettingFile" ofType:@".plist"]]objectForKey:@"HistoryRecordPath"]
                 withData:ModleData];

        
    });
    
    
    if ([theMailCategory isEqualToString:@"DailyWorkAssign"] && theMailCategory != nil)
    {
        attStrTmp =[[self FormatDaliyWork:theMailContent] mutableCopy];
        // write into file
    }
    
    
    if ([theMailCategory isEqualToString:@"Validation"] && theMailCategory != nil)
    {
        attStrTmp =[[self FormatValidationMail:theMailContent] mutableCopy];
        // write into file
        
    }
    
    NSData * data =[attStrTmp RTFFromRange:NSMakeRange(0, attStrTmp.length) documentAttributes:@{NSRTFTextDocumentType: NSDocFormatTextDocumentType}];
    
    
    if (![fm fileExistsAtPath:FilePath])
    {
        [data writeToFile:FilePath atomically:YES];
    }
    else
    {
        [fm removeItemAtPath:FilePath error:nil];
        [data writeToFile:FilePath atomically:YES];

    }

    
    return [NSNumber  numberWithBool:YES];
    
}

//format different subjects
-(NSAttributedString *)FormatValidationMail:(NSDictionary *)dicContent
{
    NSMutableAttributedString * AttMailContent =[[NSMutableAttributedString alloc]init];
    NSString * strStation = [dicContent objectForKey:@"Station"];
    NSString * strGitcommit =[dicContent objectForKey:@"GitCommit"];
    NSString * strNewOverlay = [dicContent objectForKey:@"Latest Overlay Version"];
    NSString * strBaseOverlay = [dicContent objectForKey:@"Online Overlay Version"];
    NSString * strRadar     = [dicContent objectForKey:@"RadarNumber"];
    NSString * strChangeList =[dicContent objectForKey:@"changelist"];
    NSString * strNewJSON = [dicContent objectForKey:@"Latest Live Version"];
    NSString * strBaseJSON = [dicContent objectForKey:@"Online Live Version"];
    NSString * strLatestTestAll = [dicContent objectForKey:@"Latest Testall Version"];
    NSString * strBaseTestAll   = [dicContent objectForKey:@"Online Testall Version"];
    NSString * strP4Number = [dicContent objectForKey:@"P4Number"];
    
    
    [AttMailContent appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Hi Validation Team,\n\n\t Please help to validate Station %@ new overlay, detail info as below:\n",strStation]
                                                                          attributes:dicAttributeMainInfo]];
    
    [AttMailContent appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\nNew Overlay:\n"]
                                                                          attributes:dicAttributeTitle]];
    [AttMailContent appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@\n",strNewOverlay]
                                                                          attributes:dicAttributeMainInfo]];
    
    [AttMailContent appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\nBase Overlay:\n"]
                                                                          attributes:dicAttributeTitle]];
    [AttMailContent appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@\n",strBaseOverlay]
                                                                          attributes:dicAttributeMainInfo]];

    [AttMailContent appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\nNew JSON version:\n"]
                                                                          attributes:dicAttributeTitle]];
    [AttMailContent appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@\n",strNewJSON]
                                                                          attributes:dicAttributeMainInfo]];
    
    [AttMailContent appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\nBase JSON version:\n"]
                                                                          attributes:dicAttributeTitle]];
    [AttMailContent appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@\n",strBaseJSON]
                                                                          attributes:dicAttributeMainInfo]];
    
    [AttMailContent appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\nNew Testall version:\n"]
                                                                           attributes:dicAttributeTitle]];
    [AttMailContent appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@\n",strLatestTestAll]
                                                                           attributes:dicAttributeMainInfo]];

    [AttMailContent appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\nBase Testall version:\n"]
                                                                          attributes:dicAttributeTitle]];
    [AttMailContent appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@\n",strBaseTestAll]
                                                                           attributes:dicAttributeMainInfo]];
    
    [AttMailContent appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\nChange list\n"]
                                                                          attributes:dicAttributeTitle]];
    [AttMailContent appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@\n",strChangeList]
                                                                          attributes:dicAttributeMainInfo]];
    
    [AttMailContent appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\nRadar Number\n"]
                                                                          attributes:dicAttributeTitle]];
    [AttMailContent appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@\n",strRadar]
                                                                          attributes:dicAttributeMainInfo]];
    
    [AttMailContent appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\nGit Commit\n"]
                                                                          attributes:dicAttributeTitle]];
    [AttMailContent appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@\n",strGitcommit]
                                                                          attributes:dicAttributeMainInfo]];
    
    [AttMailContent appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Coco P4 Commit\n"]
                                                                           attributes:dicAttributeTitle]];
    [AttMailContent appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@\n",strP4Number]
                                                                           attributes:dicAttributeMainInfo]];

    
    
    return AttMailContent;

}

-(NSMutableAttributedString *)FormatDaliyWork:(NSDictionary *) dicContent
{
//    NSString *buildStage =[dicContent objectForKey:@"buildStage"];
//    NSString *TaskContent = [dicContent objectForKey:@"TaskContent"];
    NSString *DailyMailTitle = [dicContent objectForKey:@"DailyMailTitle"];
    NSString *RadarNumber =[dicContent objectForKey:@"RadarNumber"];
    NSString *Commit =[dicContent objectForKey:@"Commit"];
    NSString * AssignPerson =[dicContent objectForKey:@"AssignPerson"];
    BOOL ifUrgent =[[dicContent objectForKey:@"Urgent"] boolValue];
    

    // format Attribute string
    NSMutableAttributedString  * DocContent =[[NSMutableAttributedString alloc]initWithString:@""];
    [DocContent appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Hi %@\n\n",AssignPerson]
                                                                       attributes:dicAttributeTitle]];
    
    [DocContent appendAttributedString:[[NSAttributedString alloc] initWithString:@"\nA TASK ASSIGN TO YOU\n"
                                                                       attributes:dicAttributeMainInfo]];
    
    //if the task is urgent
    if (ifUrgent == 1)
    {
        [DocContent appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n[Urgent!!]\n\n"                                                                       attributes:dicAttributeTitle]];
    }
    
    //Set Mail Detail Title
    [DocContent appendAttributedString:[[NSAttributedString alloc] initWithString:@"\nMail Title\\Task Content:\n"
                                                                       attributes:dicAttributeMainInfo]];
    
    if (DailyMailTitle.length == 0)
    {
        [DocContent appendAttributedString:[[NSAttributedString alloc] initWithString:@"No Content"                                                                           attributes:dicAttributeMainInfo]];
        
    }
    else
    {
        [DocContent appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n" ,DailyMailTitle ]
                                                                           attributes:dicAttributeTitle]];
    }
    //Set Commit about the task
    
    
    [DocContent appendAttributedString:[[NSAttributedString alloc] initWithString:@"\nComment:\n"
                                                                       attributes:dicAttributeMainInfo]];
    
    [DocContent appendAttributedString:[[NSAttributedString alloc] initWithString:Commit
                                                                       attributes:dicAttributeMainInfo]];
    
    if (RadarNumber.length == 0)
    {
        return  DocContent;
    }
    
    else
    {
        [DocContent appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n\nRadar Number is : %@\n",RadarNumber ]
                                                                           attributes:dicAttributeMainInfo]];
    }
    return DocContent;
    
    
}


-(void)writeRecord:(NSString*)filePath withData :(Modle *) modleContent
{
    NSMutableArray * Validation_Mail =[[NSMutableArray alloc]init];
    NSMutableArray * Roll_in_Mail =[[NSMutableArray alloc]init];
    NSMutableArray * Assign_Work_Mail =[[NSMutableArray alloc]init];
    NSFileManager * fm =[NSFileManager defaultManager];
    
    NSString * format = @"YYYYMMdd_HHmmss";
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:format];
    NSString *dateString = [outputFormatter stringFromDate:[NSDate date]];

    [modleContent.dicContent setObject:dateString forKey:@"Time"];
    
    
    if (![fm fileExistsAtPath:filePath])
    {
        NSDictionary * dicFile =@{@"Validation_Mail" : Validation_Mail,
                                  @"Roll_in_Mail" : Roll_in_Mail,
                                  @"Assign_Work_Mail" : Assign_Work_Mail} ;
        dicFile =  [self addData:modleContent.dicContent ForCategory:modleContent.category from:[dicFile mutableCopy]];
        
        [dicFile writeToFile:filePath atomically:YES];

    }
    else
    {
        NSMutableDictionary * dicFile =[[NSDictionary dictionaryWithContentsOfFile:filePath] mutableCopy];

       dicFile =  [self addData:modleContent.dicContent ForCategory:modleContent.category from:dicFile];

        [dicFile writeToFile:filePath atomically:YES];
    }
    
    NSLog(@"%@",[NSDictionary dictionaryWithContentsOfFile:filePath]);

}
-(NSMutableDictionary *)addData:(NSDictionary *)dicContent ForCategory:(NSString *)strCategory from:(NSMutableDictionary *)dicFileContent
{
    
    NSString *dateString =[dicContent objectForKey:@"Time"];


    if ([strCategory isEqualToString:@"DailyWorkAssign"])
    {
        
        
        NSMutableArray * Assign_Work_Mail =[[NSMutableArray alloc]initWithArray:[dicFileContent objectForKey:@"Assign_Work_Mail"]];
        
        NSDictionary * dicDailyWork =[[NSDictionary dictionaryWithObject:dicContent forKey:dateString] copy];
        [Assign_Work_Mail addObject:dicDailyWork ];
        [dicFileContent setObject:Assign_Work_Mail forKey:@"Assign_Work_Mail"];
        
        
    }
    if ([strCategory isEqualToString:@"Validation"])
    {
        NSMutableArray * Validation_Mail =[[NSMutableArray alloc]initWithArray:[dicFileContent objectForKey:@"Validation_Mail"]];
        NSDictionary * dicDailyWork =[[NSDictionary dictionaryWithObject:dicContent forKey:dateString] copy];
        [Validation_Mail addObject:dicDailyWork ];
        [dicFileContent setObject:Validation_Mail forKey:@"Validation_Mail"];
        
       
        
    }
    if ([strCategory isEqualToString:@"RollInMail"])
    {
        NSMutableArray * Roll_in_Mail =[[NSMutableArray alloc]initWithArray:[dicFileContent objectForKey:@"Roll_in_Mail"]];
        NSDictionary * dicDailyWork =[[NSDictionary dictionaryWithObject:dicContent forKey:dateString] copy];
        [Roll_in_Mail addObject:dicDailyWork ];
        [dicFileContent setObject:Roll_in_Mail forKey:@"Roll_in_Mail"];
        
        
    }
    
    return dicFileContent;
    
}

@end
