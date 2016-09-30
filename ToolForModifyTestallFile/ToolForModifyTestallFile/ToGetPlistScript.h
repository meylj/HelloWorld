//
//  ToGetPlistScript.h
//  ToolForModifyTestallFile
//
//  Created by Linda8_Yang on 9/23/16.
//  Copyright © 2016 Linda8_Yang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "NSStringCategory.h"

@interface ToGetPlistScript : NSObject

@property (nonatomic,retain)NSMutableArray *arrNewItems;

- (BOOL)ParseAndCombineJson:(NSString *)strLivePath withLiveTestAll:(NSString *)strLiveTestAllPath;
-(BOOL)MatchPistVersion:(NSString *)strTestallPath withJSON:(NSString *)strJSONPath;
- (NSString *)GetLiveVersion:(NSString *)strLivePath;
-(BOOL)CombineScriptFile:(NSString *)szScriptFilePath JsonData:(NSDictionary*)dicJsonData;
- (NSString *)FormatStringToSpecial:(NSString *)StringData;
- (NSArray*)MatchTestAll:(NSDictionary *)dicTestAllItems
                WithName:(NSString *)strName
                 WithCom:(NSArray *)arrCom;
- (void)WriteString: (NSString*)WriteData FilePath:(NSString *)szFilePath;


@end
