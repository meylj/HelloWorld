//
//  tabledatasave.h
//  FIieRead
//
//  Created by Jane6_Chen on 15/8/13.
//  Copyright (c) 2015年 ykj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "tabledatasource.h"

@interface tabledatasave : NSObject
<NSCoding>
{
    NSMutableString *m_target;        //目标
    NSMutableString *m_command;       //指令
    NSMutableString *m_response;      //回复
    NSString *target1;
    NSString *command1;
    NSString *response1;
    NSString *spec1;
}

@property (readwrite, retain) NSMutableString *m_target;
@property (readwrite, retain) NSMutableString *m_command;
@property (readwrite, retain) NSMutableString *m_response;
@property (readwrite,retain)NSMutableString *m_spec;

-(id)objectForKey:(NSString*)strKey;

- (NSString *)description;

-(void)setString:(NSString*)target andString:(NSString*)command andString:(NSString*)response andString:(NSString*)spec;

-(void)tableviewsave;
@end