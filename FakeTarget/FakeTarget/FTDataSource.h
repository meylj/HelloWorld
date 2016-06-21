//
//  FTDataSource.h
//  FakeTarget
//
//  Created by raniys on 4/15/14.
//  Copyright (c) 2014 raniys. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FTDataSource : NSObject
{
    NSString        *contentName;
    NSMutableArray  *m_arrChildren;
}

@property (copy, nonatomic) NSString * contentName;

- (id)initWithName:(NSString *)aName;
+ (FTDataSource *)nodeDataWithName:(NSString *)name;

#pragma mark - Access Method
- (BOOL)isExpandable;
- (NSArray *)children;
- (NSUInteger)indexOfChild:(FTDataSource *)child;
- (NSInteger)countOfChildren;
- (FTDataSource *)ChildAtIndex:(NSUInteger)index;


#pragma mark - Operator Method
- (BOOL)addAChild:(FTDataSource *)child;
- (BOOL)removeAChild:(FTDataSource *)child;
- (BOOL)insertAChild:(FTDataSource *)child AtIndex:(NSUInteger)index;
- (BOOL)clearAllChildren;
@end
