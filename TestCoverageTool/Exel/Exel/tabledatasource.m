//
//  tabledatasource.m
//  FIieRead
//
//  Created by Jane6_Chen on 15/8/13.
//  Copyright (c) 2015年 ykj. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "tabledatasource.h"

@implementation tabledatasource

@synthesize m_showdata;
@synthesize FIXTURE;
@synthesize MOBILE;

-(instancetype)init
{
    self = [super init];
    if (self) {
        m_showdata = [[NSMutableArray alloc] initWithCapacity:30];
    }
    return self;
}


- (void)addObject:(id)object
{
    [m_showdata addObject:object];
}


- (void)insertObject:(id)object atIndex:(NSInteger)iIndex
{
    [m_showdata insertObject:object atIndex:iIndex];
}


- (void)deleteSelectedRow:(NSInteger)iRow
{
    [m_showdata removeObjectAtIndex:iRow];
}

- (void)removeallobjects
{
    [m_showdata removeAllObjects];
}

/*-(void)showtableview
{
    [m_showdata removeAllObjects];
    if(FIXTURE && MOBILE)
    {
        m_showdata = [m_allcommands copy];
    }
    else
    {
        for(tabledatasave *datasource in m_allcommands)
        {
            NSString *str = [datasource objectForKey:@"Target"];
            if (str isEqualToString:@"MOBILE") {
                <#statements#>
            }
        }
    }
}*/

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    //返回TableView的行数
    return [m_showdata count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    //返回TableView某一行，某一列的元素对象
    NSString		*strColumn	= [tableColumn identifier];
    return [[m_showdata objectAtIndex:row] objectForKey:strColumn];
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
 {
 NSMutableString * m_target= [[tableView dataSource] tableView:tableView
 objectValueForTableColumn:[tableView tableColumnWithIdentifier:@"Target"]
 row:row];
 NSMutableString * m_command= [[tableView dataSource] tableView:tableView
                                         objectValueForTableColumn:[tableView tableColumnWithIdentifier:@"Command"]
                                                               row:row];
     NSMutableString *m_response = [[tableView dataSource] tableView:tableView objectValueForTableColumn:[tableView tableColumnWithIdentifier:@"Response"] row:row];
 //打印用户选中那一行的内容
     NSMutableString *t_textfield = [[NSMutableString alloc]init];
     [t_textfield appendFormat:m_target,m_command,m_response];
     //NSLog(@"The selected row:\n Target:%@  Command:%@  Response:%@\n",m_target,m_command,m_response);
 return YES;
 }
@end