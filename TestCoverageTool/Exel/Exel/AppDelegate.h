//
//  AppDelegate.h
//  FIieRead
//
//  Created by Jane6_Chen on 15/8/12.
//  Copyright (c) 2015年 ykj. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSStringCategory.h"
#import "NSStringCategoryOfficial.h"
#import "tabledatasave.h"
#import "tabledatasource.h"
@interface AppDelegate : NSObject
<NSApplicationDelegate,NSTableViewDelegate>
{
    IBOutlet NSMatrix *excelFormat;
    IBOutlet NSTextView *m_textfield;                       //存放需要查找的指令
    NSMutableString *strfilestring;
    IBOutlet NSTableView *m_tableview;                      //显示target command response
    IBOutlet NSTextField *m_filetext;                       //显示文件路径
    IBOutlet NSTextField *t_timetext;                       //显示时间的文本框
    NSThread *thread;                                       //显示时间的线程
    tabledatasource *m_datasource;                          //调用tabledatasource类
    NSMutableString *m_file;                                //路径字符
    NSMutableString *t_textfield;                           //用于存放文本的字符串
    NSMutableString *m_strStationName;
    IBOutlet NSView *m_view;                                //自定义UI
    NSString *path;
    NSMutableArray *m_orgary;
    NSMutableArray *m_neededdata;
    IBOutlet NSButton *nf;
    IBOutlet NSButton *of;
    IBOutlet NSButton *OnlyMobile;
    IBOutlet NSButton *OnlyFixture;
    IBOutlet NSButton *Separate;
    IBOutlet NSTextField *m_csvpath;
    NSString *CSVpath;
    NSMutableArray *name_and_time;
    BOOL     boolLoadCSV;
}



-(IBAction)LoadCSV:(id)sender;
-(IBAction)MobileorFixture:(id)sender;
-(IBAction)Load:(id)sender;                                 //载入文件
-(IBAction)Save:(id)sender;                                 //保存文件
-(IBAction)Clean:(id)sender;                                //清除
-(IBAction)Startthread:(id)sender;                          //显示时间
-(void)run:(NSDictionary*)dict;
-(IBAction)Openoriginal:(NSButton*)sender;
@end

