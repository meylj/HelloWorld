//
//  tabledatasource.h
//  FIieRead
//
//  Created by Jane6_Chen on 15/8/13.
//  Copyright (c) 2015年 ykj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "tabledatasave.h"


@interface tabledatasource : NSObject
<NSTableViewDelegate,NSTableViewDataSource>
{
    BOOL FIXTURE;
    BOOL MOBILE;
    NSMutableArray *m_allcommands;
    NSMutableArray *m_alldata;
}

@property(readwrite,retain)NSMutableArray *m_showdata;
@property(readwrite,assign)BOOL FIXTURE;
@property(readwrite,assign)BOOL MOBILE;
- (void)addObject:(id)object;

- (void)insertObject:(id)object atIndex:(NSInteger)iIndex;

- (void)deleteSelectedRow:(NSInteger)iRow;

- (void)removeallobjects;

- (void)showtableview;

@end