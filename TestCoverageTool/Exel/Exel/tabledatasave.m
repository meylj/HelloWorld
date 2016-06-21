//
//  tabledatasave.m
//  FIieRead
//
//  Created by Jane6_Chen on 15/8/13.
//  Copyright (c) 2015年 ykj. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "tabledatasave.h"

@implementation tabledatasave

@synthesize m_target;
@synthesize m_command;
@synthesize m_response;
@synthesize m_spec;


- (instancetype)init
{
    self = [super init];
    if (self) {
        m_target = [[NSMutableString alloc] initWithString:@""];
        m_command = [[NSMutableString alloc] initWithString:@""];
        m_response = [[NSMutableString alloc]initWithString:@""];
        m_spec = [[NSMutableString alloc]initWithString:@""];
    }
    return self;
}


#pragma mark - Basic Methods
- (id)objectForKey:(NSString *)strKey
{
    if ([strKey isEqualToString:@"Target"])
    {
        return m_target;
    }
    if ([strKey isEqualToString:@"Command"])
    {
        return m_command;
    }
    if ([strKey isEqualToString:@"Response"])
    {
        return m_response;
    }
    if ([strKey isEqualToString:@"Spec"])
    {
        return m_spec;
    }
    else
        return nil;
}

#pragma mark - OutputFormat
- (NSString *)description
{
    NSMutableString *t_result = [[NSMutableString alloc]initWithString:m_target];
    
    [t_result appendFormat:m_target,m_response];
    
    NSLog(@"%@",t_result);
    
    return t_result;
}


#pragma mark - NSCoding delegate
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.m_target
                  forKey:@"Target"];
    [aCoder encodeObject:self.m_command
                  forKey:@"Command"];
    [aCoder encodeObject:self.m_response
                  forKey:@"Response"];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.m_target	= [aDecoder decodeObjectForKey:@"Target"];
        self.m_command  = [aDecoder decodeObjectForKey:@"Command"];
        self.m_response	= [aDecoder decodeObjectForKey:@"Response"];
    }
    return self;
}




-(void)setString:(NSString*)target andString:(NSString*)command andString:(NSString*)response andString:(NSString*)spec
{
    target1 = [NSString stringWithString:target];
    command1 = [NSString stringWithString:command];
    response1 = [NSString stringWithString:response];
    spec1 = [NSString stringWithString:spec];
}

-(void)tableviewsave
{
   m_target= [NSMutableString stringWithString:target1];
    m_command = [NSMutableString stringWithString:command1];
    m_response = [NSMutableString stringWithString:response1];
    m_spec = [NSMutableString stringWithString:spec1];
}
@end

