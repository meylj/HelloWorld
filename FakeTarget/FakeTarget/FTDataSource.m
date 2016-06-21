//
//  FTDataSource.m
//  FakeTarget
//
//  Created by raniys on 4/15/14.
//  Copyright (c) 2014 raniys. All rights reserved.
//

#import "FTDataSource.h"

@implementation FTDataSource
@synthesize contentName;


#pragma  mark - LifeCycle
- (id)init
{
    self = [super init];
    if (self)
    {
        m_arrChildren = [[NSMutableArray alloc] init];
        self.contentName = @"";
    }
    return self;
}

- (id)initWithName:(NSString *)aName
{
    self = [self init];
    self.contentName = aName;
    return self;
}

- (void)dealloc
{
    [super dealloc];
    [m_arrChildren release];
    m_arrChildren = nil;
}

+(FTDataSource *)nodeDataWithName:(NSString *)name
{
    return [[[FTDataSource alloc] initWithName:name] autorelease];
}


#pragma mark - Access Method
- (BOOL)isExpandable
{
    return [m_arrChildren count] > 0;
}
- (NSArray *)children
{
    if (m_arrChildren)
        return m_arrChildren;
    return nil;
}
- (NSUInteger)indexOfChild:(FTDataSource *)child
{
    return [m_arrChildren indexOfObject:child];
}
- (NSInteger)countOfChildren
{
    return [m_arrChildren count];
}

- (FTDataSource *)ChildAtIndex:(NSUInteger)index
{
    if ([m_arrChildren count] > index)
        return [m_arrChildren objectAtIndex:index];
    return nil;
}

#pragma mark - Operator Method
- (BOOL)addAChild:(FTDataSource *)child
{
    [m_arrChildren addObject:child];
    return YES;
}

- (BOOL)removeAChild:(FTDataSource *)child
{
    [m_arrChildren removeObject:child];
    return YES;
}

- (BOOL)insertAChild:(FTDataSource *)child AtIndex:(NSUInteger)index
{
    [m_arrChildren insertObject:child atIndex:index];
    return YES;
}

- (BOOL)clearAllChildren
{
    [m_arrChildren removeAllObjects];
    return YES;
}


@end
