//
//  DataBase.m
//  WebServerCenter
//
//  Created by Lorky on 3/28/14.
//  Copyright (c) 2014 PEGATRON. All rights reserved.
//

#import "DataBase.h"

@implementation DataBase
@synthesize DBKey;
@synthesize DBValue;

- (id)init
{
	self = [super init];
	if (self)
	{
		m_arrChildren = [[NSMutableArray alloc] init];
		self.DBKey = @"Key";
		self.DBValue = @"Value";
	}
	return self;
}

- (void)dealloc
{
	[m_arrChildren release]; m_arrChildren = nil;
	[super dealloc];
}

#pragma mark - DataSource Change
- (BOOL)addAChildren:(DataBase *)aChild
{
	[m_arrChildren addObject:aChild];
	return YES;
}

- (BOOL)insertChildren:(DataBase *)aChild atIndex:(NSUInteger)index
{
	[m_arrChildren insertObject:aChild atIndex:index];
	return YES;
}

- (BOOL)removeChildAtIndex:(NSInteger)index
{
	if ([m_arrChildren count] > index)
	{
		[m_arrChildren removeObjectAtIndex:index];
		return YES;
	}
	else
		return NO;
}

- (BOOL)removeChild:(DataBase *)aChild
{
	if ([m_arrChildren containsObject:aChild])
	{
		[m_arrChildren removeObject:aChild];
		return YES;
	}
	else
		return NO;
}

- (NSUInteger)indexOfChildrenItem:(DataBase *)aChild
{
	return [m_arrChildren indexOfObject:aChild];
}

#pragma mark - DataSource Access
- (NSInteger)countOfChildren
{
	return [m_arrChildren count];
}

- (DataBase *)ObjectAtIndex:(NSInteger)index
{
	return [m_arrChildren objectAtIndex:index];
}

- (BOOL)isExpandable
{
	return ([self countOfChildren] > 0);
}

- (NSArray *)children
{
	if (m_arrChildren)
		return m_arrChildren;
	else
		return nil;
}
@end
