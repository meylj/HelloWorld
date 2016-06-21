//
//  DataBase.h
//  WebServerCenter
//
//  Created by Lorky on 3/28/14.
//  Copyright (c) 2014 PEGATRON. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataBase : NSObject
{
	NSMutableArray * m_arrChildren;
}

@property (copy, readwrite, nonatomic) NSString * DBKey;
@property (copy, readwrite, nonatomic) NSString * DBValue;
#pragma mark - DataSource Change
- (BOOL)addAChildren:(DataBase *)aChild;
- (BOOL)insertChildren:(DataBase *)aChild atIndex:(NSUInteger)index;
- (BOOL)removeChildAtIndex:(NSInteger)index;
- (BOOL)removeChild:(DataBase *)aChild;
- (NSUInteger)indexOfChildrenItem:(DataBase *)aChild;

#pragma mark - DataSource Access
- (NSInteger)countOfChildren;
- (DataBase *)ObjectAtIndex:(NSInteger)index;
- (BOOL)isExpandable;
- (NSArray *)children;

@end
