//
//  NewTestallFormat.h
//  ToolForModifyTestallFile
//
//  Created by Linda8_Yang on 9/23/16.
//  Copyright © 2016 Linda8_Yang. All rights reserved.
//

#import "ToGetPlistScript.h"

@interface NewTestallFormat : NSObject
{
    ToGetPlistScript *objPlistScript;
}

@property(nonatomic,retain)NSMutableDictionary * dicTestallFile;

-(BOOL)creatNewTestallFileWithNewFormat:(NSString *)strOldTestallPath withJsonPath:(NSString *)strJsonPath;
- (NSMutableArray *)getItemsControlItems:(NSString *)strOldTestallPath;
- (NSMutableDictionary *)getSubItems;
@end
