//
//  ParseFile.h
//  SearchErrorResponseLog
//
//  Created by 张斌 on 14-8-21.
//  Copyright (c) 2014年 张斌. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParseFile : NSObject
{
    
}
@property(retain)NSMutableDictionary * m_dicStr;
@property(copy)NSString * m_szMovePath;
@property(copy)NSString * m_szDiretory;
-(NSArray *)FindDiretory:(NSString *)szPath;
-(NSDictionary *)ParseAndMoveFile:(NSArray *)aryPath;

@end
